package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Categoria;
import edu.utn.inspt.cinearchive.backend.modelo.Contenido;
import edu.utn.inspt.cinearchive.backend.modelo.Resena;
import edu.utn.inspt.cinearchive.backend.servicio.CategoriaService;
import edu.utn.inspt.cinearchive.backend.servicio.ContenidoService;
import edu.utn.inspt.cinearchive.backend.servicio.ResenaService;
import edu.utn.inspt.cinearchive.backend.servicio.ApiExternaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Controlador para gestión de inventario de contenidos, categorías y reseñas
 */
@Controller
@RequestMapping("/inventario")
public class GestorInventarioController {

    private final ContenidoService contenidoService;
    private final CategoriaService categoriaService;
    private final ResenaService resenaService;
    private final ApiExternaService apiExternaService;

    @Autowired
    public GestorInventarioController(
            ContenidoService contenidoService,
            CategoriaService categoriaService,
            ResenaService resenaService,
            ApiExternaService apiExternaService) {
        this.contenidoService = contenidoService;
        this.categoriaService = categoriaService;
        this.resenaService = resenaService;
        this.apiExternaService = apiExternaService;
    }

    // ==================== GESTIÓN DE CONTENIDO ====================

    /**
     * Listar todos los contenidos (REST)
     */
    @GetMapping("/api/contenidos")
    @ResponseBody
    public ResponseEntity<List<Contenido>> listarContenidos() {
        try {
            List<Contenido> contenidos = contenidoService.obtenerTodos();
            return ResponseEntity.ok(contenidos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Obtener contenido por ID (REST)
     */
    @GetMapping("/api/contenidos/{id}")
    @ResponseBody
    public ResponseEntity<Contenido> obtenerContenido(@PathVariable Long id) {
        try {
            Optional<Contenido> contenido = contenidoService.obtenerPorId(id);
            return contenido.map(ResponseEntity::ok)
                           .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Crear nuevo contenido (REST)
     */
    @PostMapping("/api/contenidos")
    @ResponseBody
    public ResponseEntity<Contenido> crearContenido(@Valid @RequestBody Contenido contenido) {
        try {
            contenidoService.guardar(contenido);
            return ResponseEntity.status(HttpStatus.CREATED).body(contenido);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Actualizar contenido existente (REST)
     */
    @PutMapping("/api/contenidos/{id}")
    @ResponseBody
    public ResponseEntity<Contenido> actualizarContenido(
            @PathVariable Long id,
            @Valid @RequestBody Contenido contenido) {
        try {
            if (!contenidoService.existePorId(id)) {
                return ResponseEntity.notFound().build();
            }

            contenido.setId(id);
            contenidoService.guardar(contenido);
            return ResponseEntity.ok(contenido);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Eliminar contenido (REST)
     */
    @DeleteMapping("/api/contenidos/{id}")
    @ResponseBody
    public ResponseEntity<Void> eliminarContenido(@PathVariable Long id) {
        try {
            contenidoService.eliminar(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Buscar contenidos por título (REST)
     */
    @GetMapping("/api/contenidos/buscar")
    @ResponseBody
    public ResponseEntity<List<Contenido>> buscarContenidos(@RequestParam String titulo) {
        try {
            if (titulo == null || titulo.trim().isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            List<Contenido> contenidos = contenidoService.buscarPorTitulo(titulo);
            return ResponseEntity.ok(contenidos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Filtrar contenidos por tipo (REST)
     */
    @GetMapping("/api/contenidos/tipo/{tipo}")
    @ResponseBody
    public ResponseEntity<List<Contenido>> filtrarPorTipo(@PathVariable String tipo) {
        try {
            Contenido.Tipo tipoContenido = Contenido.Tipo.valueOf(tipo.toUpperCase());
            List<Contenido> contenidos = contenidoService.buscarPorTipo(tipoContenido);
            return ResponseEntity.ok(contenidos);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Obtener contenidos disponibles para alquiler (REST)
     */
    @GetMapping("/api/contenidos/disponibles")
    @ResponseBody
    public ResponseEntity<List<Contenido>> obtenerContenidosDisponibles() {
        try {
            List<Contenido> contenidos = contenidoService.obtenerDisponiblesParaAlquiler();
            return ResponseEntity.ok(contenidos);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== GESTIÓN DE CATEGORÍAS ====================

    /**
     * Listar todas las categorías (REST)
     */
    @GetMapping("/api/categorias")
    @ResponseBody
    public ResponseEntity<List<Categoria>> listarCategorias() {
        try {
            List<Categoria> categorias = categoriaService.obtenerTodas();
            return ResponseEntity.ok(categorias);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Crear nueva categoría (REST)
     */
    @PostMapping("/api/categorias")
    @ResponseBody
    public ResponseEntity<Categoria> crearCategoria(@Valid @RequestBody Categoria categoria) {
        try {
            Categoria categoriaGuardada = categoriaService.guardar(categoria);
            return ResponseEntity.status(HttpStatus.CREATED).body(categoriaGuardada);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Obtener categorías por tipo (REST)
     */
    @GetMapping("/api/categorias/tipo/{tipo}")
    @ResponseBody
    public ResponseEntity<List<Categoria>> obtenerCategoriasPorTipo(@PathVariable String tipo) {
        try {
            Categoria.Tipo tipoCategoria = Categoria.Tipo.valueOf(tipo.toUpperCase());
            List<Categoria> categorias = categoriaService.obtenerPorTipo(tipoCategoria);
            return ResponseEntity.ok(categorias);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== GESTIÓN DE RESEÑAS ====================

    /**
     * Obtener reseñas de un contenido (REST)
     */
    @GetMapping("/api/contenidos/{contenidoId}/resenas")
    @ResponseBody
    public ResponseEntity<List<Resena>> obtenerResenasPorContenido(@PathVariable Long contenidoId) {
        try {
            List<Resena> resenas = resenaService.obtenerPorContenido(contenidoId);
            return ResponseEntity.ok(resenas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Crear nueva reseña (REST)
     */
    @PostMapping("/api/resenas")
    @ResponseBody
    public ResponseEntity<Resena> crearResena(@Valid @RequestBody Resena resena) {
        try {
            Resena resenaGuardada = resenaService.crear(resena);
            return ResponseEntity.status(HttpStatus.CREATED).body(resenaGuardada);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== ESTADÍSTICAS DE INVENTARIO ====================

    /**
     * Obtener estadísticas del inventario (REST)
     */
    @GetMapping("/api/estadisticas")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> obtenerEstadisticasInventario() {
        try {
            Map<String, Object> estadisticas = new HashMap<>();

            // Estadísticas de contenido
            List<Contenido> todosLosContenidos = contenidoService.obtenerTodos();
            List<Contenido> disponibles = contenidoService.obtenerDisponiblesParaAlquiler();
            List<Contenido> peliculas = contenidoService.buscarPorTipo(Contenido.Tipo.PELICULA);
            List<Contenido> series = contenidoService.buscarPorTipo(Contenido.Tipo.SERIE);

            estadisticas.put("total_contenidos", todosLosContenidos.size());
            estadisticas.put("contenidos_disponibles", disponibles.size());
            estadisticas.put("total_peliculas", peliculas.size());
            estadisticas.put("total_series", series.size());

            // Estadísticas de categorías
            List<Categoria> todasLasCategorias = categoriaService.obtenerTodas();
            List<Categoria> generos = categoriaService.obtenerGeneros();
            List<Categoria> tags = categoriaService.obtenerTags();
            List<Categoria> clasificaciones = categoriaService.obtenerClasificaciones();

            estadisticas.put("total_categorias", todasLasCategorias.size());
            estadisticas.put("total_generos", generos.size());
            estadisticas.put("total_tags", tags.size());
            estadisticas.put("total_clasificaciones", clasificaciones.size());

            // Estadísticas de reseñas
            List<Resena> todasLasResenas = resenaService.obtenerTodas();
            estadisticas.put("total_resenas", todasLasResenas.size());

            // Estado de conectividad con APIs
            Map<String, Boolean> conectividad = apiExternaService.verificarConectividadApis();
            estadisticas.put("conectividad_apis", conectividad);

            return ResponseEntity.ok(estadisticas);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Obtener resumen de inventario por géneros (REST)
     */
    @GetMapping("/api/resumen/generos")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> obtenerResumenPorGeneros() {
        try {
            List<Contenido> contenidos = contenidoService.obtenerTodos();
            Map<String, Integer> conteoGeneros = new HashMap<>();

            for (Contenido contenido : contenidos) {
                String genero = contenido.getGenero();
                if (genero != null && !genero.trim().isEmpty()) {
                    conteoGeneros.put(genero, conteoGeneros.getOrDefault(genero, 0) + 1);
                }
            }

            List<Map<String, Object>> resumen = conteoGeneros.entrySet().stream()
                .map(entry -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("genero", entry.getKey());
                    map.put("cantidad", entry.getValue());
                    return map;
                })
                .sorted((a, b) -> Integer.compare((Integer) b.get("cantidad"), (Integer) a.get("cantidad")))
                .collect(Collectors.toList());

            return ResponseEntity.ok(resumen);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Obtener contenidos por estado de disponibilidad (REST)
     */
    @GetMapping("/api/resumen/disponibilidad")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> obtenerResumenDisponibilidad() {
        try {
            List<Contenido> contenidos = contenidoService.obtenerTodos();

            int disponibles = 0;
            int noDisponibles = 0;
            int sinCopias = 0;

            for (Contenido contenido : contenidos) {
                if (Boolean.TRUE.equals(contenido.getDisponibleParaAlquiler())) {
                    if (contenido.getCopiasDisponibles() != null && contenido.getCopiasDisponibles() > 0) {
                        disponibles++;
                    } else {
                        sinCopias++;
                    }
                } else {
                    noDisponibles++;
                }
            }

            Map<String, Object> resumen = new HashMap<>();
            resumen.put("disponibles", disponibles);
            resumen.put("no_disponibles", noDisponibles);
            resumen.put("sin_copias", sinCopias);
            resumen.put("total", contenidos.size());

            return ResponseEntity.ok(resumen);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    // ==================== VISTAS JSP ====================

    /**
     * Vista principal del gestor de inventario con filtrado
     */
    @GetMapping
    public String mostrarGestorInventario(
            @RequestParam(defaultValue = "1") int pagina,
            @RequestParam(required = false) String busqueda,
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) String genero,
            @RequestParam(required = false) String estado,
            Model model) {
        try {
            // Cargar todos los contenidos
            List<Contenido> todosLosContenidos = contenidoService.obtenerTodos();

            // Aplicar filtros si existen
            List<Contenido> contenidosFiltrados = todosLosContenidos.stream()
                .filter(c -> {
                    // Filtro por búsqueda (título)
                    if (busqueda != null && !busqueda.trim().isEmpty()) {
                        if (!c.getTitulo().toLowerCase().contains(busqueda.toLowerCase().trim())) {
                            return false;
                        }
                    }

                    // Filtro por tipo
                    if (tipo != null && !tipo.isEmpty()) {
                        if (!c.getTipo().toString().equals(tipo)) {
                            return false;
                        }
                    }

                    // Filtro por género
                    if (genero != null && !genero.isEmpty()) {
                        if (c.getGenero() == null || !c.getGenero().equals(genero)) {
                            return false;
                        }
                    }

                    // Filtro por estado
                    if (estado != null && !estado.isEmpty()) {
                        Integer copiasDisp = c.getCopiasDisponibles();
                        Integer copiasTot = c.getCopiasTotales();

                        if ("disponible".equals(estado)) {
                            if (copiasDisp == null || copiasDisp <= 0) {
                                return false;
                            }
                        } else if ("no-disponible".equals(estado)) {
                            if (copiasDisp == null || copiasDisp > 0) {
                                return false;
                            }
                        } else if ("stock-bajo".equals(estado)) {
                            if (copiasDisp == null || copiasTot == null || copiasTot == 0) {
                                return false;
                            }
                            double porcentaje = (double) copiasDisp / copiasTot;
                            if (porcentaje > 0.2) {
                                return false;
                            }
                        }
                    }

                    return true;
                })
                .collect(Collectors.toList());

            // Paginación sobre los contenidos filtrados
            int elementosPorPagina = 20;
            int totalElementos = contenidosFiltrados.size();
            int totalPaginas = (int) Math.ceil((double) totalElementos / elementosPorPagina);

            int inicio = (pagina - 1) * elementosPorPagina;
            int fin = Math.min(inicio + elementosPorPagina, totalElementos);

            List<Contenido> contenidosPaginados = totalElementos > 0
                ? contenidosFiltrados.subList(inicio, fin)
                : new ArrayList<>();

            // Cargar categorías y géneros
            List<Categoria> todasCategorias = categoriaService.obtenerTodas();
            List<Categoria> generos = categoriaService.obtenerGeneros();

            // Identificar contenidos con stock bajo (menos del 20% disponible)
            List<Contenido> contenidosStockBajo = todosLosContenidos.stream()
                .filter(c -> {
                    Integer copiasTotales = c.getCopiasTotales();
                    Integer copiasDisponibles = c.getCopiasDisponibles();
                    if (copiasTotales != null && copiasTotales > 0 && copiasDisponibles != null) {
                        double porcentaje = (double) copiasDisponibles / copiasTotales;
                        return porcentaje <= 0.2; // 20% o menos
                    }
                    return false;
                })
                .collect(Collectors.toList());

            model.addAttribute("contenidos", contenidosPaginados);
            model.addAttribute("categorias", todasCategorias);
            model.addAttribute("generos", generos);
            model.addAttribute("contenidosStockBajo", contenidosStockBajo);
            model.addAttribute("paginaActual", pagina);
            model.addAttribute("totalPaginas", totalPaginas);
            model.addAttribute("totalResultados", totalElementos);

            // Mantener valores de filtros en el formulario
            model.addAttribute("filtroBusqueda", busqueda != null ? busqueda : "");
            model.addAttribute("filtroTipo", tipo != null ? tipo : "");
            model.addAttribute("filtroGenero", genero != null ? genero : "");
            model.addAttribute("filtroEstado", estado != null ? estado : "");

            // Estadísticas completas
            List<Contenido> peliculas = contenidoService.buscarPorTipo(Contenido.Tipo.PELICULA);
            List<Contenido> series = contenidoService.buscarPorTipo(Contenido.Tipo.SERIE);
            List<Contenido> disponibles = contenidoService.obtenerDisponiblesParaAlquiler();

            Map<String, Object> estadisticas = new HashMap<>();
            estadisticas.put("totalContenidos", totalElementos);
            estadisticas.put("totalPeliculas", peliculas.size());
            estadisticas.put("totalSeries", series.size());
            estadisticas.put("contenidosDisponibles", disponibles.size());
            estadisticas.put("totalCategorias", todasCategorias.size());
            estadisticas.put("totalResenas", resenaService.obtenerTodas().size());

            model.addAttribute("estadisticas", estadisticas);

            return "gestor-inventario";
        } catch (Exception e) {
            model.addAttribute("error", "Error al cargar el gestor de inventario: " + e.getMessage());
            return "error";
        }
    }

    /**
     * Vista de listado completo de contenidos
     */
    @GetMapping("/contenidos")
    public String listarContenidosVista(
            @RequestParam(required = false) String busqueda,
            @RequestParam(required = false) String tipo,
            Model model) {
        try {
            List<Contenido> contenidos;

            if (busqueda != null && !busqueda.trim().isEmpty()) {
                contenidos = contenidoService.buscarPorTitulo(busqueda);
                model.addAttribute("busqueda", busqueda);
            } else if (tipo != null && !tipo.isEmpty()) {
                try {
                    Contenido.Tipo tipoContenido = Contenido.Tipo.valueOf(tipo.toUpperCase());
                    contenidos = contenidoService.buscarPorTipo(tipoContenido);
                    model.addAttribute("tipoFiltro", tipo);
                } catch (IllegalArgumentException e) {
                    contenidos = contenidoService.obtenerTodos();
                }
            } else {
                contenidos = contenidoService.obtenerTodos();
            }

            model.addAttribute("contenidos", contenidos);

            return "lista-contenidos";
        } catch (Exception e) {
            model.addAttribute("error", "Error al cargar la lista de contenidos");
            return "error";
        }
    }

    /**
     * Vista de gestión de categorías
     */
    @GetMapping("/categorias")
    public String gestionarCategorias(Model model) {
        try {
            List<Categoria> categorias = categoriaService.obtenerTodas();
            model.addAttribute("categorias", categorias);

            // Agrupar por tipo
            List<Categoria> generos = categoriaService.obtenerGeneros();
            List<Categoria> tags = categoriaService.obtenerTags();
            List<Categoria> clasificaciones = categoriaService.obtenerClasificaciones();

            model.addAttribute("generos", generos);
            model.addAttribute("tags", tags);
            model.addAttribute("clasificaciones", clasificaciones);

            return "gestion-categorias";
        } catch (Exception e) {
            model.addAttribute("error", "Error al cargar la gestión de categorías");
            return "error";
        }
    }

    /**
     * Vista de estadísticas del inventario
     */
    @GetMapping("/estadisticas")
    public String mostrarEstadisticas(Model model) {
        try {
            // Obtener estadísticas completas
            ResponseEntity<Map<String, Object>> estadisticasResponse = obtenerEstadisticasInventario();
            if (estadisticasResponse.getStatusCode() == HttpStatus.OK) {
                model.addAttribute("estadisticas", estadisticasResponse.getBody());
            }

            // Obtener resumen por géneros
            ResponseEntity<List<Map<String, Object>>> generosResponse = obtenerResumenPorGeneros();
            if (generosResponse.getStatusCode() == HttpStatus.OK) {
                model.addAttribute("resumenGeneros", generosResponse.getBody());
            }

            // Obtener resumen de disponibilidad
            ResponseEntity<Map<String, Object>> disponibilidadResponse = obtenerResumenDisponibilidad();
            if (disponibilidadResponse.getStatusCode() == HttpStatus.OK) {
                model.addAttribute("resumenDisponibilidad", disponibilidadResponse.getBody());
            }

            return "estadisticas-inventario";
        } catch (Exception e) {
            model.addAttribute("error", "Error al cargar las estadísticas");
            return "error";
        }
    }
}

