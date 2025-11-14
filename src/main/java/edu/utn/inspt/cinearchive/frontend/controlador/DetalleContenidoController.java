package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Contenido;
import edu.utn.inspt.cinearchive.backend.servicio.ContenidoService;
import edu.utn.inspt.cinearchive.backend.servicio.AlquilerService;
import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import javax.servlet.http.HttpSession;
import java.util.Optional;

@Controller
public class DetalleContenidoController {

    private final ContenidoService contenidoService;
    private final AlquilerService alquilerService;

    @Autowired
    public DetalleContenidoController(ContenidoService contenidoService, AlquilerService alquilerService) {
        this.contenidoService = contenidoService;
        this.alquilerService = alquilerService;
    }

    @GetMapping("/contenido/{id}")
    public String detalle(@PathVariable("id") Long id, Model model, HttpSession session, @org.springframework.web.bind.annotation.RequestParam(value = "season", required = false) Integer season) {
        Optional<Contenido> contenidoOpt = contenidoService.getById(id);
        if (!contenidoOpt.isPresent()) {
            // Si no existe el contenido, redirigimos al catálogo en lugar de provocar 500
            return "redirect:/catalogo";
        }
        Contenido c = contenidoOpt.get();
        Usuario usuarioLogueado = obtenerUsuarioSesion(session);
        Long usuarioId = null;
        if (usuarioLogueado != null) {
            model.addAttribute("usuarioLogueado", usuarioLogueado);
            usuarioId = usuarioLogueado.getId();
        }
        if (usuarioId == null) {
            return "redirect:/login";
        }
        boolean alquilado = false;
        try { alquilado = alquilerService.existeAlquilerActivo(usuarioId, id); } catch (Exception ignored) {}
        Integer selectedSeason = null;
        if (season != null && c.getTemporadas() != null && season >= 1 && season <= c.getTemporadas()) {
            selectedSeason = season;
        }
        java.util.List<Contenido> seasons = java.util.Collections.emptyList();
        if (c.getTipo() == edu.utn.inspt.cinearchive.backend.modelo.Contenido.Tipo.SERIE) {
            String titulo = c.getTitulo();
            String prefix = titulo;
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("^(.*?)( - Temporada \\d+)?$").matcher(titulo);
            if (m.find()) {
                prefix = m.group(1);
            }
            seasons = contenidoService.getSeasonsByTitlePrefix(prefix);
        }
        // Mapa de temporadas alquiladas activas para este usuario
        java.util.Map<Long, Boolean> seasonActiveMap = new java.util.HashMap<>();
        try {
            java.util.List<edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle> lista = alquilerService.getByUsuarioConContenido(usuarioId);
            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            java.util.Set<Long> seasonIds = new java.util.HashSet<>();
            for (Contenido sc : seasons) { seasonIds.add(sc.getId()); }
            for (edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle d : lista) {
                if (d.getContenidoId() != null && seasonIds.contains(d.getContenidoId()) && d.getFechaFin() != null && d.getFechaFin().isAfter(now) && d.getEstado() == edu.utn.inspt.cinearchive.backend.modelo.Alquiler.Estado.ACTIVO) {
                    seasonActiveMap.put(d.getContenidoId(), Boolean.TRUE);
                }
            }
        } catch (Exception ignore) {}
        model.addAttribute("contenido", c);
        model.addAttribute("alquilado", alquilado);
        model.addAttribute("selectedSeason", selectedSeason);
        model.addAttribute("seasons", seasons);
        model.addAttribute("seasonActiveMap", seasonActiveMap);
        // Relacionados por género/tipo (excluyendo el actual)
        java.util.List<Contenido> relacionados = new java.util.ArrayList<>();
        try {
            String genero = c.getGenero();
            String tipo = c.getTipo() != null ? c.getTipo().name() : null;
            if (genero != null && !genero.trim().isEmpty()) {
                for (Contenido cx : contenidoService.search(null, genero, tipo, "nombre")) {
                    if (!cx.getId().equals(c.getId())) relacionados.add(cx);
                    if (relacionados.size() >= 12) break;
                }
            }
        } catch (Exception ignore) {}
        model.addAttribute("relacionados", relacionados);
        // Más del director
        java.util.List<Contenido> masDelDirector = new java.util.ArrayList<>();
        try {
            if (c.getDirector() != null && !c.getDirector().trim().isEmpty()) {
                for (Contenido cx : contenidoService.getAll()) {
                    if (cx.getId() != null && !cx.getId().equals(c.getId()) && c.getDirector().equalsIgnoreCase(cx.getDirector())) {
                        masDelDirector.add(cx);
                        if (masDelDirector.size() >= 12) break;
                    }
                }
            }
        } catch (Exception ignore) {}
        model.addAttribute("masDelDirector", masDelDirector);
        return "detalle";
    }

    private Usuario obtenerUsuarioSesion(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object usuario = session.getAttribute("usuarioLogueado");
        if (usuario instanceof Usuario) {
            return (Usuario) usuario;
        }
        return null;
    }
}
