package edu.utn.inspt.cinearchive.backend.servicio;

import edu.utn.inspt.cinearchive.backend.modelo.Alquiler;
import edu.utn.inspt.cinearchive.backend.repositorio.AlquilerRepository;
import edu.utn.inspt.cinearchive.backend.repositorio.ContenidoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Component
public class AlquilerMaintenanceScheduler {

    private static final Logger logger = Logger.getLogger(AlquilerMaintenanceScheduler.class.getName());

    private final AlquilerRepository alquilerRepository;
    private final ContenidoRepository contenidoRepository;

    @Autowired
    public AlquilerMaintenanceScheduler(AlquilerRepository alquilerRepository, ContenidoRepository contenidoRepository) {
        this.alquilerRepository = alquilerRepository;
        this.contenidoRepository = contenidoRepository;
    }

    // Corre cada minuto
    @Scheduled(fixedDelay = 21600_000)
    @Transactional
    public void finalizarAlquileresVencidos() {
        try {
            List<Alquiler> vencidos = alquilerRepository.findExpiredActivos(LocalDateTime.now());
            for (Alquiler a : vencidos) {
                a.setEstado(Alquiler.Estado.FINALIZADO);
                alquilerRepository.update(a);
                // devolver copia al stock
                contenidoRepository.updateCopiasDisponibles(a.getContenidoId(), +1);
            }
            if (!vencidos.isEmpty()) {
                logger.log(Level.INFO, "Alquileres finalizados por vencimiento: {0}", vencidos.size());
            }
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "Error finalizando alquileres vencidos", ex);
        }
    }
}

