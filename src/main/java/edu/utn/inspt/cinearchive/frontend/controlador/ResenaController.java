package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Resena;
import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import edu.utn.inspt.cinearchive.backend.servicio.ResenaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controlador REST que expone los endpoints para gestionar reseñas
 */
@RestController
@RequestMapping("/api/resenas")
public class ResenaController {

    private final ResenaService resenaService;

    @Autowired
    public ResenaController(ResenaService resenaService) {
        this.resenaService = resenaService;
    }

    @GetMapping
    public ResponseEntity<List<Resena>> listarResenas() {
        return ResponseEntity.ok(resenaService.obtenerTodas());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Resena> obtenerResena(@PathVariable Long id) {
        return resenaService.obtenerPorId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<List<Resena>> listarPorUsuario(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(resenaService.obtenerPorUsuario(usuarioId));
    }

    @GetMapping("/contenido/{contenidoId}")
    public ResponseEntity<List<Resena>> listarPorContenido(@PathVariable Long contenidoId) {
        return ResponseEntity.ok(resenaService.obtenerPorContenido(contenidoId));
    }

    @GetMapping("/contenido/{contenidoId}/promedio")
    public ResponseEntity<Double> obtenerCalificacionPromedio(@PathVariable Long contenidoId) {
        Double promedio = resenaService.obtenerCalificacionPromedio(contenidoId);
        return promedio != null ? ResponseEntity.ok(promedio) : ResponseEntity.notFound().build();
    }

    @GetMapping("/contenido/{contenidoId}/stats")
    public ResponseEntity<Map<String, Object>> obtenerEstadisticas(@PathVariable Long contenidoId) {
        Map<String, Object> stats = new HashMap<>();
        Double promedio = resenaService.obtenerCalificacionPromedio(contenidoId);
        long total = resenaService.contarPorContenido(contenidoId);
        stats.put("promedio", promedio != null ? promedio : 0.0);
        stats.put("total", total);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/calificacion/{minima}")
    public ResponseEntity<List<Resena>> listarPorCalificacionMinima(@PathVariable Double minima) {
        return ResponseEntity.ok(resenaService.obtenerPorCalificacionMinima(minima));
    }

    @PostMapping
    public ResponseEntity<?> crearResena(@RequestBody Map<String, Object> payload, HttpSession session) {
        Usuario usuarioSesion = (Usuario) (session != null ? session.getAttribute("usuarioLogueado") : null);
        if (usuarioSesion == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("No autenticado");
        }

        // Extraer datos del payload
        Long contenidoId = extractLongId(payload.get("contenido"));
        if (contenidoId == null) {
            return ResponseEntity.badRequest().body("Contenido inválido");
        }

        Double calificacion = extractDouble(payload.get("calificacion"));
        String titulo = extractString(payload.get("titulo"));
        String texto = extractString(payload.get("texto"));

        if (titulo == null || titulo.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("El título es obligatorio");
        }
        if (texto == null || texto.trim().isEmpty()) {
            return ResponseEntity.badRequest().body("El texto es obligatorio");
        }

        // Verificar duplicado
        Long usuarioId = usuarioSesion.getId();
        if (resenaService.existePorUsuarioYContenido(usuarioId, contenidoId)) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Ya publicaste una reseña para este contenido");
        }

        // Construir objetos Usuario y Contenido con solo ID
        Usuario usuario = new Usuario();
        usuario.setId(usuarioId);

        edu.utn.inspt.cinearchive.backend.modelo.Contenido contenido = new edu.utn.inspt.cinearchive.backend.modelo.Contenido();
        contenido.setId(contenidoId);

        // Construir Resena
        Resena resena = new Resena();
        resena.setUsuario(usuario);
        resena.setContenido(contenido);
        resena.setCalificacion(calificacion != null ? calificacion : 1.0);
        resena.setTitulo(titulo.trim());
        resena.setTexto(texto.trim());

        try {
            return ResponseEntity.status(HttpStatus.CREATED).body(resenaService.crear(resena));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    // Métodos auxiliares para extraer datos del Map
    private Long extractLongId(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Map) {
            Object id = ((Map<?, ?>) obj).get("id");
            if (id instanceof Number) return ((Number) id).longValue();
            if (id instanceof String) {
                try { return Long.parseLong((String) id); } catch (Exception e) { return null; }
            }
        }
        if (obj instanceof Number) return ((Number) obj).longValue();
        if (obj instanceof String) {
            try { return Long.parseLong((String) obj); } catch (Exception e) { return null; }
        }
        return null;
    }

    private Double extractDouble(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Number) return ((Number) obj).doubleValue();
        if (obj instanceof String) {
            try { return Double.parseDouble((String) obj); } catch (Exception e) { return null; }
        }
        return null;
    }

    private String extractString(Object obj) {
        return obj != null ? obj.toString() : null;
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarResena(
            @PathVariable Long id,
            @RequestBody Map<String, Object> payload,
            HttpSession session) {
        Usuario usuarioSesion = (Usuario) (session != null ? session.getAttribute("usuarioLogueado") : null);
        if (usuarioSesion == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("No autenticado");
        }

        java.util.Optional<Resena> resenaOpt = resenaService.obtenerPorId(id);
        if (!resenaOpt.isPresent()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Reseña no encontrada");
        }

        Resena actual = resenaOpt.get();
        if (actual.getUsuario() == null || !usuarioSesion.getId().equals(actual.getUsuario().getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No tienes permiso para editar esta reseña");
        }

        // Actualizar campos
        Double calificacion = extractDouble(payload.get("calificacion"));
        String titulo = extractString(payload.get("titulo"));
        String texto = extractString(payload.get("texto"));

        if (calificacion != null) actual.setCalificacion(calificacion);
        if (titulo != null && !titulo.trim().isEmpty()) actual.setTitulo(titulo.trim());
        if (texto != null && !texto.trim().isEmpty()) actual.setTexto(texto.trim());

        try {
            Resena resenaActualizada = resenaService.actualizar(id, actual);
            return ResponseEntity.ok(resenaActualizada);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarResena(@PathVariable Long id, HttpSession session) {
        Usuario usuarioSesion = (Usuario) (session != null ? session.getAttribute("usuarioLogueado") : null);
        if (usuarioSesion == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        java.util.Optional<Resena> resenaOpt = resenaService.obtenerPorId(id);
        if (!resenaOpt.isPresent()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        Resena actual = resenaOpt.get();
        if (actual.getUsuario() == null || !usuarioSesion.getId().equals(actual.getUsuario().getId())) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        try {
            resenaService.eliminar(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/usuario/{usuarioId}/contenido/{contenidoId}")
    public ResponseEntity<List<Resena>> buscarPorUsuarioYContenido(
            @PathVariable Long usuarioId,
            @PathVariable Long contenidoId) {
        return ResponseEntity.ok(resenaService.buscarPorUsuarioYContenido(usuarioId, contenidoId));
    }

    @GetMapping("/usuario/{usuarioId}/contenido/{contenidoId}/existe")
    public ResponseEntity<Boolean> verificarExistencia(
            @PathVariable Long usuarioId,
            @PathVariable Long contenidoId) {
        boolean existe = resenaService.existePorUsuarioYContenido(usuarioId, contenidoId);
        return ResponseEntity.ok(existe);
    }
}
