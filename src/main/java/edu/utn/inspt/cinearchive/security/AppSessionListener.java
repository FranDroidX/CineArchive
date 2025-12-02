package edu.utn.inspt.cinearchive.security;

import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

/**
 * Listener para limpiar el registro cuando una sesión se destruye
 */
@WebListener
public class AppSessionListener implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // no es necesario hacer nada al crear
        System.out.println("[AppSessionListener] sessionCreated: " + se.getSession().getId());
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        try {
            System.out.println("[AppSessionListener] sessionDestroyed: " + se.getSession().getId());
            SessionRegistry registry = SessionRegistry.getInstance();
            if (registry != null) {
                registry.unregisterSession(se.getSession());
            }
        } catch (Exception e) {
            System.err.println("Error en sessionDestroyed: " + e.getMessage());
        }
    }
}
