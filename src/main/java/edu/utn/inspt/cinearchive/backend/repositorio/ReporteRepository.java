package edu.utn.inspt.cinearchive.backend.repositorio;

import edu.utn.inspt.cinearchive.backend.modelo.Reporte;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface ReporteRepository {
    // Métodos CRUD básicos
    List<Reporte> findAll();
    Optional<Reporte> findById(Integer id);
    Reporte save(Reporte reporte);
    void deleteById(Integer id);
    boolean existsById(Integer id);

    // Métodos específicos para analytics y reportes
    List<Map<String, Object>> obtenerContenidosMasAlquilados(LocalDate fechaInicio, LocalDate fechaFin, int limite);
    Map<String, Object> obtenerEstadisticasGenerales();
    List<Map<String, Object>> obtenerCategoriasPopulares(int limite);
}
