package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Contenido;
import edu.utn.inspt.cinearchive.backend.servicio.ContenidoService;
import edu.utn.inspt.cinearchive.backend.servicio.AlquilerService;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class CatalogoController {

    private final ContenidoService contenidoService;
    private final AlquilerService alquilerService;

    @Autowired
    public CatalogoController(ContenidoService contenidoService, AlquilerService alquilerService) {
        this.contenidoService = contenidoService;
        this.alquilerService = alquilerService;
    }

    @GetMapping("/catalogo")
    public String catalogo(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "genero", required = false) String genero,
            @RequestParam(value = "tipo", required = false) String tipo,
            @RequestParam(value = "orden", required = false) String orden,
            @RequestParam(value = "page", required = false, defaultValue = "1") int page,
            HttpSession session,
            Model model) {
        // Normalizar parámetros
        if (orden == null || orden.trim().isEmpty()) orden = "nombre"; // default
        if (page < 1) page = 1;
        final int size = 50; // fijo por requerimiento

        // Obtener lista paginada ligera para catálogo
        List<Contenido> lista = contenidoService.searchPagedLight(q, genero, tipo, orden, page, size);
        long total = contenidoService.searchCount(q, genero, tipo);
        long totalPages = (long) Math.ceil(total / (double) size);

        model.addAttribute("contenidos", lista);
        model.addAttribute("query", q);
        model.addAttribute("genero", genero);
        model.addAttribute("tipo", tipo);
        model.addAttribute("orden", orden);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("total", total);
        model.addAttribute("totalPages", totalPages);

        // IDs alquilados activos para el usuario (para marcar estado en tarjetas)
        edu.utn.inspt.cinearchive.backend.modelo.Usuario usuarioLogueado = obtenerUsuarioSesion(session);
        Long usuarioId = usuarioLogueado != null ? usuarioLogueado.getId() : null;
        java.util.Set<Long> alquilados = new java.util.HashSet<>();
        if (usuarioId != null) {
            try {
                java.util.List<edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle> ads = alquilerService.getByUsuarioConContenido(usuarioId);
                java.time.LocalDateTime now = java.time.LocalDateTime.now();
                for (edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle d : ads) {
                    if (d.getContenidoId() != null && d.getFechaFin() != null && d.getFechaFin().isAfter(now) && d.getEstado() == edu.utn.inspt.cinearchive.backend.modelo.Alquiler.Estado.ACTIVO && !d.isExpirado()) {
                        alquilados.add(d.getContenidoId());
                    }
                }
            } catch (Exception ignore) {}
        }
        java.util.Map<Long, Boolean> alquiladoMap = new java.util.HashMap<>();
        for (Long idC : alquilados) alquiladoMap.put(idC, Boolean.TRUE);
        model.addAttribute("alquiladoMap", alquiladoMap);

        // Secciones destacadas para portada de catálogo (diseño dev2) - siempre primera página para cada sección
        try {
            java.util.List<Contenido> novedades = contenidoService.searchPagedLight(null, null, null, "fecha", 1, 12);
            model.addAttribute("novedades", novedades);
        } catch (Exception ignore) {}
        try {
            java.util.List<Contenido> populares = contenidoService.searchPagedLight(null, null, null, "nombre", 1, 12);
            model.addAttribute("populares", populares);
        } catch (Exception ignore) {}
        try {
            java.util.List<Contenido> accionList = contenidoService.searchPagedLight(null, "accion", null, "nombre", 1, 12);
            model.addAttribute("accionList", accionList);
        } catch (Exception ignore) {}
        try {
            java.util.List<Contenido> seriesRecomendadas = contenidoService.searchPagedLight(null, null, "SERIE", "fecha", 1, 12);
            model.addAttribute("seriesRecomendadas", seriesRecomendadas);
        } catch (Exception ignore) {}

        // Usuario logueado para el header
        if (usuarioLogueado != null) {
            model.addAttribute("usuarioLogueado", usuarioLogueado);
        }

        return "catalogo";
    }

    private edu.utn.inspt.cinearchive.backend.modelo.Usuario obtenerUsuarioSesion(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object usuario = session.getAttribute("usuarioLogueado");
        if (usuario instanceof edu.utn.inspt.cinearchive.backend.modelo.Usuario) {
            return (edu.utn.inspt.cinearchive.backend.modelo.Usuario) usuario;
        }
        return null;
    }
}
