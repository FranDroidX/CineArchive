package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.Alquiler;
import edu.utn.inspt.cinearchive.backend.modelo.AlquilerDetalle;
import edu.utn.inspt.cinearchive.backend.modelo.Contenido;
import edu.utn.inspt.cinearchive.backend.modelo.Transaccion;
import edu.utn.inspt.cinearchive.backend.repositorio.AlquilerRepository;
import edu.utn.inspt.cinearchive.backend.repositorio.ContenidoRepository;
import edu.utn.inspt.cinearchive.backend.repositorio.TransaccionRepository;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AlquilerServiceImpl implements AlquilerService {

    private final AlquilerRepository alquilerRepository;
    private final ContenidoRepository contenidoRepository;
    private final TransaccionRepository transaccionRepository;

    @Autowired
    public AlquilerServiceImpl(AlquilerRepository alquilerRepository, ContenidoRepository contenidoRepository, TransaccionRepository transaccionRepository) {
        this.alquilerRepository = alquilerRepository;
        this.contenidoRepository = contenidoRepository;
        this.transaccionRepository = transaccionRepository;
    }

    @Override
    public Alquiler getById(Long id) {
        return alquilerRepository.findById(id);
    }

    @Override
    public List<Alquiler> getByUsuario(Long usuarioId) {
        return alquilerRepository.findByUsuarioId(usuarioId);
    }

    @Override
    public java.util.List<AlquilerDetalle> getByUsuarioConContenido(Long usuarioId) {
        java.util.List<AlquilerDetalle> lista = alquilerRepository.findByUsuarioIdWithContenido(usuarioId);
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        for (AlquilerDetalle d : lista) {
            if (d.getFechaFin() != null) {
                long segundos = java.time.Duration.between(now, d.getFechaFin()).getSeconds();
                d.setSegundosRestantes(segundos);
                long dias = java.time.Duration.between(now, d.getFechaFin()).toDays();
                d.setDiasRestantes(dias);
                d.setExpirado(segundos < 0);
            }
            if (d.getFechaInicio() != null && d.getFechaFin() != null) {
                long total = java.time.Duration.between(d.getFechaInicio(), d.getFechaFin()).getSeconds();
                long transcurrido = java.time.Duration.between(d.getFechaInicio(), now).getSeconds();
                long pct = total > 0 ? Math.min(100, Math.max(0, (transcurrido * 100) / total)) : 0;
                d.setProgresoPct((int) pct);
            }
        }
        lista.sort(java.util.Comparator.comparing(AlquilerDetalle::getFechaFin, java.util.Comparator.nullsLast(java.util.Comparator.naturalOrder())));
        return lista;
    }

    @Override
    @Transactional
    public void create(Alquiler alquiler) {
        alquilerRepository.save(alquiler);
    }

    @Override
    @Transactional
    public void update(Alquiler alquiler) {
        alquilerRepository.update(alquiler);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        alquilerRepository.delete(id);
    }

    @Override
    public boolean existeAlquilerActivo(Long usuarioId, Long contenidoId) {
        return alquilerRepository.existsActiveByUsuarioAndContenido(usuarioId, contenidoId);
    }

    @Override
    @Transactional
    public void rent(Long usuarioId, Long contenidoId, Integer periodoDias, String metodoPago) {
        if (usuarioId == null || contenidoId == null || periodoDias == null || periodoDias <= 0) {
            throw new IllegalArgumentException("Parámetros inválidos para alquiler");
        }

        // Verificar si existe un alquiler activo (no expirado)
        if (alquilerRepository.existsActiveByUsuarioAndContenido(usuarioId, contenidoId)) {
            throw new IllegalStateException("Ya existe un alquiler activo para este contenido");
        }

        // Buscar alquileres expirados y finalizarlos antes de crear uno nuevo
        java.util.List<Alquiler> todosAlquileres = alquilerRepository.findByUsuarioId(usuarioId);
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        int alquileresFinalizados = 0;

        for (Alquiler alq : todosAlquileres) {
            if (alq.getContenidoId() != null
                    && alq.getContenidoId().equals(contenidoId)
                    && alq.getEstado() == Alquiler.Estado.ACTIVO
                    && alq.getFechaFin() != null
                    && alq.getFechaFin().isBefore(now)) {
                // Finalizar el alquiler expirado
                alq.setEstado(Alquiler.Estado.FINALIZADO);
                alquilerRepository.update(alq);
                // Devolver la copia al stock
                contenidoRepository.updateCopiasDisponibles(contenidoId, +1);
                alquileresFinalizados++;
                java.util.logging.Logger.getLogger(AlquilerServiceImpl.class.getName())
                    .log(java.util.logging.Level.INFO,
                        "Alquiler ID {0} finalizado automáticamente al extender para contenido {1}",
                        new Object[]{alq.getId(), contenidoId});
            }
        }

        if (alquileresFinalizados > 0) {
            java.util.logging.Logger.getLogger(AlquilerServiceImpl.class.getName())
                .log(java.util.logging.Level.INFO,
                    "Se finalizaron {0} alquiler(es) expirado(s) antes de crear uno nuevo",
                    alquileresFinalizados);
        }

        Optional<Contenido> contenidoOpt = contenidoRepository.findById(contenidoId);
        if (!contenidoOpt.isPresent() || Boolean.FALSE.equals(contenidoOpt.get().getDisponibleParaAlquiler())) {
            throw new IllegalStateException("Contenido no disponible para alquiler");
        }
        Contenido c = contenidoOpt.get();
        if (c.getCopiasDisponibles() == null || c.getCopiasDisponibles() <= 0) {
            throw new IllegalStateException("No hay copias disponibles");
        }
        int reserved = contenidoRepository.reserveCopy(contenidoId);
        if (reserved == 0) {
            throw new IllegalStateException("Stock agotado al intentar reservar");
        }
        LocalDateTime inicio = LocalDateTime.now();
        LocalDateTime fin = inicio.plusDays(periodoDias);
        BigDecimal precioBase = c.getPrecioAlquiler() != null ? c.getPrecioAlquiler() : BigDecimal.ZERO;
        BigDecimal multiplicador = BigDecimal.valueOf(periodoDias / 3.0d);
        BigDecimal precioFinal = precioBase.multiply(multiplicador).setScale(2, java.math.RoundingMode.HALF_UP);

        Alquiler a = new Alquiler();
        a.setUsuarioId(usuarioId);
        a.setContenidoId(contenidoId);
        a.setPeriodoAlquiler(periodoDias);
        a.setFechaInicio(inicio);
        a.setFechaFin(fin);
        a.setPrecio(precioFinal);
        a.setEstado(Alquiler.Estado.ACTIVO);
        a.setVisto(false);
        a.setFechaVista(null);
        alquilerRepository.save(a);

        Transaccion t = new Transaccion();
        t.setUsuarioId(usuarioId);
        t.setAlquilerId(a.getId());
        t.setMonto(precioFinal);
        t.setMetodoPago(metodoPago != null ? metodoPago : "DESCONOCIDO");
        t.setEstado(Transaccion.Estado.COMPLETADA);
        t.setReferenciaExterna(null);
        transaccionRepository.save(t);
    }
}
