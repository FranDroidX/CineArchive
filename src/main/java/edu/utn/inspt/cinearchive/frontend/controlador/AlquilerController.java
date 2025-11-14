package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import edu.utn.inspt.cinearchive.backend.servicio.AlquilerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.logging.Level;
import java.util.logging.Logger;

@Controller
public class AlquilerController {

    private static final Logger logger = Logger.getLogger(AlquilerController.class.getName());

    private final AlquilerService alquilerService;

    @Autowired
    public AlquilerController(AlquilerService alquilerService) {
        this.alquilerService = alquilerService;
    }

    @GetMapping("/mis-alquileres")
    public String misAlquileres(Model model, HttpSession session) {
        Usuario usuarioLogueado = obtenerUsuarioSesion(session);
        if (usuarioLogueado == null) {
            return "redirect:/login";
        }
        Long usuarioId = usuarioLogueado.getId();

        // Obtener todos los alquileres y filtrar solo los ACTIVOS (incluyendo expirados)
        java.util.List<edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle> todosAlquileres =
            alquilerService.getByUsuarioConContenido(usuarioId);

        java.util.List<edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle> alquileresActivos =
            new java.util.ArrayList<>();

        for (edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle a : todosAlquileres) {
            // Solo mostrar alquileres en estado ACTIVO (aunque estén expirados)
            if (a.getEstado() == edu.utn.inspt.cinearchive.backend.modelo.Alquiler.Estado.ACTIVO) {
                alquileresActivos.add(a);
            }
        }

        model.addAttribute("alquileres", alquileresActivos);
        model.addAttribute("usuarioLogueado", usuarioLogueado);
        return "mis-alquileres";
    }

    @PostMapping("/alquilar")
    public String alquilar(@RequestParam("contenidoId") Long contenidoId,
                           @RequestParam(value = "periodo", required = false, defaultValue = "3") Integer periodo,
                           @RequestParam(value = "metodoPago", required = false) String metodoPago,
                           HttpSession session,
                           RedirectAttributes ra) {
        Usuario usuarioLogueado = obtenerUsuarioSesion(session);
        if (usuarioLogueado == null) {
            ra.addFlashAttribute("error", "Debes iniciar sesión para alquilar contenido");
            return "redirect:/login";
        }
        Long usuarioId = usuarioLogueado.getId();
        try {
            alquilerService.rent(usuarioId, contenidoId, periodo, metodoPago);
            ra.addFlashAttribute("msg", "Alquiler confirmado");
            return "redirect:/mis-alquileres";
        } catch (IllegalArgumentException | IllegalStateException ex) {
            logger.log(Level.WARNING, "Error en alquiler: {0}", ex.getMessage());
            ra.addFlashAttribute("error", ex.getMessage());
            return "redirect:/contenido/" + contenidoId;
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "Error inesperado en alquiler", ex);
            ra.addFlashAttribute("error", "Error interno al procesar alquiler");
            return "redirect:/contenido/" + contenidoId;
        }
    }

    @PostMapping(value = "/alquiler/estado", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public ResponseEntity<java.util.Map<String,Object>> estadoAlquiler(@RequestBody java.util.Map<String,Object> payload, HttpSession session) {
        Usuario usuarioLogueado = obtenerUsuarioSesion(session);
        if (usuarioLogueado == null) {
            java.util.Map<String,Object> err = new java.util.HashMap<>();
            err.put("status", "ERROR");
            err.put("message", "Sesión expirada o no autenticada");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(err);
        }
        Long usuarioId = usuarioLogueado.getId();
        java.util.Map<String,Object> respuesta = new java.util.HashMap<>();
        java.util.Set<Long> solicitados = new java.util.HashSet<>();
        if (payload != null) {
            Object idsPayload = payload.get("ids");
            if (idsPayload instanceof java.util.List<?>) {
                for (Object value : (java.util.List<?>) idsPayload) {
                    try {
                        solicitados.add(Long.valueOf(String.valueOf(value)));
                    } catch (Exception ignored) {}
                }
            }
            respuesta.put("rawPayload", payload);
        }
        java.util.Set<Long> activos = new java.util.HashSet<>();
        try {
            java.util.List<edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle> lista = alquilerService.getByUsuarioConContenido(usuarioId);
            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            for (edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle d : lista) {
                if (d.getContenidoId() != null && d.getFechaFin() != null && d.getFechaFin().isAfter(now) && d.getEstado() == edu.utn.inspt.cinearchive.backend.modelo.Alquiler.Estado.ACTIVO) {
                    activos.add(d.getContenidoId());
                }
            }
        } catch (Exception ignored) {}
        java.util.Set<String> activosIds = new java.util.HashSet<>();
        java.util.stream.Stream<Long> stream = activos.stream();
        if (!solicitados.isEmpty()) {
            stream = stream.filter(solicitados::contains);
        }
        stream.forEach(id -> activosIds.add(String.valueOf(id)));
        respuesta.put("activos", activosIds);
        respuesta.put("requested", solicitados.stream().map(String::valueOf).toArray(String[]::new));
        return ResponseEntity.ok(respuesta);
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
