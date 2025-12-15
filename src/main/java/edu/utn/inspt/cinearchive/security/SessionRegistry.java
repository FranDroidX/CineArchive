package edu.utn.inspt.cinearchive.security;

import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpSession;
import java.util.Collections;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/**
 * Registry sencillo para mapear userId -> sesiones HTTP activas
 * Permite invalidar todas las sesiones de un usuario cuando su rol/estado cambia
 */
@Component
public class SessionRegistry {

    private final ConcurrentMap<Long, Set<HttpSession>> sessionsByUser = new ConcurrentHashMap<>();

    private static SessionRegistry INSTANCE;

    @PostConstruct
    public void init() {
        INSTANCE = this;
        System.out.println("[SessionRegistry] initialized");
    }

    /** Obtener la instancia desde listeners no gestionados por Spring */
    public static SessionRegistry getInstance() {
        return INSTANCE;
    }

    public void registerSession(Long userId, HttpSession session) {
        if (userId == null || session == null) return;
        sessionsByUser.compute(userId, (k, set) -> {
            if (set == null) {
                set = Collections.newSetFromMap(new ConcurrentHashMap<>());
            }
            set.add(session);
            return set;
        });
        System.out.println("[SessionRegistry] Registered session " + session.getId() + " for userId=" + userId);
    }

    public void unregisterSession(HttpSession session) {
        if (session == null) return;
        Object attr = session.getAttribute("usuarioId");
        if (attr instanceof Long) {
            Long userId = (Long) attr;
            Set<HttpSession> set = sessionsByUser.get(userId);
            if (set != null) {
                set.remove(session);
                if (set.isEmpty()) {
                    sessionsByUser.remove(userId);
                }
            }
            System.out.println("[SessionRegistry] Unregistered session " + session.getId() + " for userId=" + userId);
        } else {
            System.out.println("[SessionRegistry] Unregister session " + session.getId() + " but no usuarioId attribute");
        }
    }

    public void invalidateSessionsForUser(Long userId) {
        if (userId == null) return;
        Set<HttpSession> set = sessionsByUser.remove(userId);
        System.out.println("[SessionRegistry] invalidateSessionsForUser called for userId=" + userId + ", sessionsFound=" + (set != null ? set.size() : 0));
        if (set != null) {
            for (HttpSession s : set) {
                try {
                    System.out.println("[SessionRegistry] Invalidating session " + s.getId() + " for userId=" + userId);
                    s.invalidate();
                } catch (IllegalStateException e) {
                    // ya inválida, ignorar
                    System.out.println("[SessionRegistry] Session " + s.getId() + " already invalidated");
                } catch (Exception e) {
                    // proteger contra sesiones que lancen excepciones
                    System.err.println("Error invalidando sesión para usuario " + userId + ": " + e.getMessage());
                }
            }
        }
    }
}
