package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.MetodoPago;
import java.util.List;
import java.util.Optional;

public interface MetodoPagoService {

    /**
     * Crea un nuevo método de pago para un usuario
     */
    MetodoPago crear(MetodoPago metodoPago);

    /**
     * Actualiza un método de pago existente
     */
    MetodoPago actualizar(MetodoPago metodoPago);

    /**
     * Busca un método de pago por su ID
     */
    Optional<MetodoPago> buscarPorId(Long id);

    /**
     * Obtiene todos los métodos de pago de un usuario
     */
    List<MetodoPago> obtenerPorUsuario(Long usuarioId);

    /**
     * Obtiene solo los métodos de pago activos de un usuario
     */
    List<MetodoPago> obtenerActivosPorUsuario(Long usuarioId);

    /**
     * Obtiene el método de pago preferido de un usuario
     */
    Optional<MetodoPago> obtenerPreferido(Long usuarioId);

    /**
     * Desactiva un método de pago (soft delete)
     */
    boolean desactivar(Long id, Long usuarioId);

    /**
     * Elimina permanentemente un método de pago
     */
    boolean eliminar(Long id, Long usuarioId);

    /**
     * Marca un método de pago como preferido
     */
    boolean marcarComoPreferido(Long id, Long usuarioId);

    /**
     * Valida que el método de pago pertenezca al usuario
     */
    boolean perteneceAlUsuario(Long metodoPagoId, Long usuarioId);
}

