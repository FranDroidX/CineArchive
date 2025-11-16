package edu.utn.inspt.cinearchive.backend.repositorio;

import edu.utn.inspt.cinearchive.backend.modelo.MetodoPago;
import java.util.List;
import java.util.Optional;

public interface MetodoPagoRepository {

    /**
     * Guarda un nuevo método de pago
     */
    MetodoPago save(MetodoPago metodoPago);

    /**
     * Actualiza un método de pago existente
     */
    MetodoPago update(MetodoPago metodoPago);

    /**
     * Busca un método de pago por su ID
     */
    Optional<MetodoPago> findById(Long id);

    /**
     * Obtiene todos los métodos de pago de un usuario
     */
    List<MetodoPago> findByUsuarioId(Long usuarioId);

    /**
     * Obtiene todos los métodos de pago activos de un usuario
     */
    List<MetodoPago> findActiveByUsuarioId(Long usuarioId);

    /**
     * Obtiene el método de pago preferido de un usuario
     */
    Optional<MetodoPago> findPreferidoByUsuarioId(Long usuarioId);

    /**
     * Desactiva un método de pago
     */
    boolean deactivate(Long id);

    /**
     * Elimina un método de pago
     */
    boolean delete(Long id);

    /**
     * Marca un método de pago como preferido y desmarca los demás del usuario
     */
    boolean setPreferido(Long id, Long usuarioId);
}

