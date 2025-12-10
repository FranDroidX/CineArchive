package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.Reporte;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Interfaz que define las operaciones disponibles para el servicio de Reportes
 */
public interface ReporteService {

    // ==================== CRUD BÁSICO ====================

    List<Reporte> obtenerTodos();

    Optional<Reporte> obtenerPorId(Integer id);

    Reporte guardar(Reporte reporte);

    void eliminar(Integer id);

    boolean existePorId(Integer id);

    // ==================== GENERACIÓN DE REPORTES ====================

    /**
     * Genera un reporte de contenidos más alquilados
     */
    Reporte generarReporteContenidosMasAlquilados(Integer analistaId, LocalDate fechaInicio, LocalDate fechaFin, int limite);

    // ==================== ANALYTICS Y CONSULTAS ====================

    /**
     * Obtiene estadísticas generales del dashboard
     */
    Map<String, Object> obtenerEstadisticasGenerales();

    /**
     * Obtiene los contenidos más alquilados
     */
    List<Map<String, Object>> obtenerTopContenidos(LocalDate fechaInicio, LocalDate fechaFin, int limite);

    /**
     * Obtiene las categorías más populares
     */
    List<Map<String, Object>> obtenerCategoriasPopulares(int limite);
}
