package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.Resena;
import edu.utn.inspt.cinearchive.backend.repositorio.ResenaRepositoryImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Implementación del servicio de Reseña
 */
@Service
@Transactional
public class ResenaServiceImpl implements ResenaService {

    private final ResenaRepositoryImpl resenaRepository;

    @Autowired
    public ResenaServiceImpl(ResenaRepositoryImpl resenaRepository) {
        this.resenaRepository = resenaRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Resena> obtenerTodas() {
        return resenaRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<Resena> obtenerPorId(Long id) {
        return resenaRepository.findById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Resena> obtenerPorUsuario(Long usuarioId) {
        return resenaRepository.findByUsuarioId(usuarioId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Resena> obtenerPorContenido(Long contenidoId) {
        return resenaRepository.findByContenidoId(contenidoId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Resena> obtenerPorCalificacionMinima(Double calificacion) {
        return resenaRepository.findByCalificacionGreaterThanEqual(calificacion);
    }

    @Override
    public Resena crear(Resena resena) {
        validarResena(resena);
        resena.setFechaCreacion(LocalDate.now());
        return resenaRepository.save(resena);
    }

    @Override
    public Resena actualizar(Long id, Resena resena) {
        if (!resenaRepository.existsById(id)) {
            throw new IllegalArgumentException("No existe una reseña con el ID: " + id);
        }

        validarResena(resena);
        resena.setId(id);
        resena.setFechaModificacion(LocalDate.now());
        return resenaRepository.save(resena);
    }

    @Override
    public void eliminar(Long id) {
        if (!resenaRepository.existsById(id)) {
            throw new IllegalArgumentException("No existe una reseña con el ID: " + id);
        }
        resenaRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public Double obtenerCalificacionPromedio(Long contenidoId) {
        return resenaRepository.calcularCalificacionPromedio(contenidoId);
    }

    @Override
    @Transactional(readOnly = true)
    public boolean existePorUsuarioYContenido(Long usuarioId, Long contenidoId) {
        return resenaRepository.existsByUsuarioIdAndContenidoId(usuarioId, contenidoId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Resena> buscarPorUsuarioYContenido(Long usuarioId, Long contenidoId) {
        return resenaRepository.findByUsuarioIdAndContenidoId(usuarioId, contenidoId);
    }

    @Override
    @Transactional(readOnly = true)
    public long contarPorContenido(Long contenidoId) {
        return resenaRepository.countByContenidoId(contenidoId.intValue());
    }

    private void validarResena(Resena resena) {
        if (resena == null) {
            throw new IllegalArgumentException("La reseña no puede ser null");
        }
        if (resena.getUsuario() == null) {
            throw new IllegalArgumentException("El usuario es obligatorio");
        }
        if (resena.getContenido() == null) {
            throw new IllegalArgumentException("El contenido es obligatorio");
        }
        if (resena.getCalificacion() == null) {
            throw new IllegalArgumentException("La calificación es obligatoria");
        }
        // Ajuste a 1..5 para coincidir con la restricción de la BD
        if (resena.getCalificacion() < 1 || resena.getCalificacion() > 5) {
            throw new IllegalArgumentException("La calificación debe estar entre 1 y 5");
        }
        if (resena.getTitulo() == null || resena.getTitulo().trim().isEmpty()) {
            throw new IllegalArgumentException("El título es obligatorio");
        }
        if (resena.getTexto() == null || resena.getTexto().trim().isEmpty()) {
            throw new IllegalArgumentException("El texto es obligatorio");
        }
        if (resena.getTitulo().length() > 100) {
            throw new IllegalArgumentException("El título no puede exceder 100 caracteres");
        }
        if (resena.getTexto().length() > 2000) {
            throw new IllegalArgumentException("El texto no puede exceder 2000 caracteres");
        }
    }
}
