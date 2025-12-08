package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.MetodoPago;
import edu.utn.inspt.cinearchive.backend.repositorio.MetodoPagoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

@Service
@Transactional
public class MetodoPagoServiceImpl implements MetodoPagoService {

    private static final Logger logger = Logger.getLogger(MetodoPagoServiceImpl.class.getName());

    @Autowired
    private MetodoPagoRepository metodoPagoRepository;

    @Override
    public MetodoPago crear(MetodoPago metodoPago) {
        if (metodoPago == null) {
            throw new IllegalArgumentException("El método de pago no puede ser nulo");
        }

        if (metodoPago.getUsuarioId() == null) {
            throw new IllegalArgumentException("El usuario es requerido");
        }

        if (metodoPago.getTipo() == null) {
            throw new IllegalArgumentException("El tipo de método de pago es requerido");
        }

        if (metodoPago.getAlias() == null || metodoPago.getAlias().trim().isEmpty()) {
            throw new IllegalArgumentException("El alias es requerido");
        }

        // Si es tarjeta, validar campos adicionales
        if (metodoPago.esTarjeta()) {
            if (metodoPago.getTitular() == null || metodoPago.getTitular().trim().isEmpty()) {
                throw new IllegalArgumentException("El titular de la tarjeta es requerido");
            }
            if (metodoPago.getNumeroTarjeta() == null || metodoPago.getNumeroTarjeta().length() != 4) {
                throw new IllegalArgumentException("Los últimos 4 dígitos de la tarjeta son requeridos");
            }
        }

        // Si se marca como preferido, desmarcar otros
        if (metodoPago.getPreferido() != null && metodoPago.getPreferido()) {
            metodoPagoRepository.setPreferido(null, metodoPago.getUsuarioId());
        }

        logger.info("Creando método de pago: " + metodoPago.getAlias() + " para usuario: " + metodoPago.getUsuarioId());
        return metodoPagoRepository.save(metodoPago);
    }

    @Override
    public MetodoPago actualizar(MetodoPago metodoPago) {
        if (metodoPago == null || metodoPago.getId() == null) {
            throw new IllegalArgumentException("El método de pago y su ID son requeridos");
        }

        Optional<MetodoPago> existente = metodoPagoRepository.findById(metodoPago.getId());
        if (!existente.isPresent()) {
            throw new IllegalArgumentException("Método de pago no encontrado");
        }

        // Validar que el método de pago pertenece al usuario
        if (!existente.get().getUsuarioId().equals(metodoPago.getUsuarioId())) {
            throw new IllegalArgumentException("No tiene permisos para modificar este método de pago");
        }

        logger.info("Actualizando método de pago ID: " + metodoPago.getId());
        return metodoPagoRepository.update(metodoPago);
    }

    @Override
    public Optional<MetodoPago> buscarPorId(Long id) {
        if (id == null) {
            return Optional.empty();
        }
        return metodoPagoRepository.findById(id);
    }

    @Override
    public List<MetodoPago> obtenerPorUsuario(Long usuarioId) {
        if (usuarioId == null) {
            throw new IllegalArgumentException("El ID de usuario es requerido");
        }
        return metodoPagoRepository.findByUsuarioId(usuarioId);
    }

    @Override
    public List<MetodoPago> obtenerActivosPorUsuario(Long usuarioId) {
        if (usuarioId == null) {
            throw new IllegalArgumentException("El ID de usuario es requerido");
        }
        return metodoPagoRepository.findActiveByUsuarioId(usuarioId);
    }

    @Override
    public Optional<MetodoPago> obtenerPreferido(Long usuarioId) {
        if (usuarioId == null) {
            return Optional.empty();
        }
        return metodoPagoRepository.findPreferidoByUsuarioId(usuarioId);
    }

    @Override
    public boolean desactivar(Long id, Long usuarioId) {
        if (id == null || usuarioId == null) {
            throw new IllegalArgumentException("ID de método de pago y usuario son requeridos");
        }

        // Validar que pertenece al usuario
        if (!perteneceAlUsuario(id, usuarioId)) {
            throw new IllegalArgumentException("No tiene permisos para desactivar este método de pago");
        }

        logger.info("Desactivando método de pago ID: " + id);
        return metodoPagoRepository.deactivate(id);
    }

    @Override
    public boolean activar(Long id, Long usuarioId) {
        if (id == null || usuarioId == null) {
            throw new IllegalArgumentException("ID de método de pago y usuario son requeridos");
        }

        // Validar que pertenece al usuario
        if (!perteneceAlUsuario(id, usuarioId)) {
            throw new IllegalArgumentException("No tiene permisos para activar este método de pago");
        }

        logger.info("Activando método de pago ID: " + id);
        return metodoPagoRepository.activate(id);
    }

    @Override
    public boolean eliminar(Long id, Long usuarioId) {
        if (id == null || usuarioId == null) {
            throw new IllegalArgumentException("ID de método de pago y usuario son requeridos");
        }

        // Validar que pertenece al usuario
        if (!perteneceAlUsuario(id, usuarioId)) {
            throw new IllegalArgumentException("No tiene permisos para eliminar este método de pago");
        }

        logger.info("Eliminando método de pago ID: " + id);
        return metodoPagoRepository.delete(id);
    }

    @Override
    public boolean marcarComoPreferido(Long id, Long usuarioId) {
        if (id == null || usuarioId == null) {
            throw new IllegalArgumentException("ID de método de pago y usuario son requeridos");
        }

        // Validar que pertenece al usuario
        if (!perteneceAlUsuario(id, usuarioId)) {
            throw new IllegalArgumentException("No tiene permisos para modificar este método de pago");
        }

        logger.info("Marcando método de pago ID: " + id + " como preferido");
        return metodoPagoRepository.setPreferido(id, usuarioId);
    }

    @Override
    public boolean perteneceAlUsuario(Long metodoPagoId, Long usuarioId) {
        if (metodoPagoId == null || usuarioId == null) {
            return false;
        }

        Optional<MetodoPago> mp = metodoPagoRepository.findById(metodoPagoId);
        return mp.isPresent() && mp.get().getUsuarioId().equals(usuarioId);
    }
}

