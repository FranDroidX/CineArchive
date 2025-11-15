package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.Resena;
import java.util.List;
import java.util.Optional;

/**
 * Interfaz que define las operaciones disponibles para el servicio de Reseña
 */
public interface ResenaService {

    List<Resena> obtenerTodas();

    Optional<Resena> obtenerPorId(Long id);

    List<Resena> obtenerPorUsuario(Long usuarioId);

    List<Resena> obtenerPorContenido(Long contenidoId);

    List<Resena> obtenerPorCalificacionMinima(Double calificacion);

    Resena crear(Resena resena);

    Resena actualizar(Long id, Resena resena);

    void eliminar(Long id);

    Double obtenerCalificacionPromedio(Long contenidoId);

    boolean existePorUsuarioYContenido(Long usuarioId, Long contenidoId);

    List<Resena> buscarPorUsuarioYContenido(Long usuarioId, Long contenidoId);

    // Nuevo: contar reseñas por contenido
    long contarPorContenido(Long contenidoId);
}
