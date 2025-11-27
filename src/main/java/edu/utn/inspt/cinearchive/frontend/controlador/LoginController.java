package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import edu.utn.inspt.cinearchive.backend.servicio.UsuarioService;
import edu.utn.inspt.cinearchive.security.SessionRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletResponse;

/**
 * Controlador para gestionar el login y logout de usuarios
 * Maneja la autenticación y gestión de sesiones HTTP
 */
@Controller
public class LoginController {

    @Autowired
    private UsuarioService usuarioService;

    /**
     * Muestra el formulario de login
     * GET /login
     *
     * @param error Parámetro opcional para mostrar mensajes de error
     * @param mensaje Parámetro opcional para mostrar mensajes informativos
     * @param model Modelo para pasar datos a la vista
     * @return Nombre de la vista JSP (login.jsp)
     */
    @GetMapping("/login")
    public String mostrarLogin(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "mensaje", required = false) String mensaje,
            Model model,
            HttpSession session,
            HttpServletResponse response) {

        // IMPORTANTE: Configurar headers para evitar caché del navegador
        // Esto asegura que el navegador SIEMPRE haga una petición al servidor
        // y ejecute la invalidación de sesión cada vez que se accede a /login
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // IMPORTANTE: Invalidar cualquier sesión existente al acceder a /login
        // Esto fuerza al usuario a volver a iniciar sesión siempre
        if (session != null && session.getAttribute("usuarioLogueado") != null) {
            try {
                session.invalidate();
            } catch (IllegalStateException e) {
                // La sesión ya fue invalidada, continuar normalmente
            }
        }

        // Agregar mensajes si existen
        if (error != null) {
            model.addAttribute("error", "Credenciales inválidas o cuenta desactivada");
        }

        // Nota: El mensaje 'logout' se maneja mediante param.mensaje en el JSP
        // Solo agregamos al modelo otros mensajes
        if (mensaje != null && !mensaje.equals("logout")) {
            if (mensaje.equals("registroExitoso")) {
                model.addAttribute("mensaje", "¡Registro exitoso! Ya puedes iniciar sesión");
            }
        }

        return "login"; // Retorna login.jsp en /WEB-INF/views/
    }

    /**
     * Procesa el formulario de login
     * POST /login
     *
     * @param email Email ingresado por el usuario
     * @param password Contraseña ingresada por el usuario
     * @param session Sesión HTTP para almacenar datos del usuario
     * @param model Modelo para pasar datos a la vista
     * @return Redirección según el resultado de autenticación
     */
    @PostMapping("/login")
    public String procesarLogin(
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            HttpSession session,
            Model model) {

        // 1. Validar que los campos no estén vacíos
        if (email == null || email.trim().isEmpty()) {
            model.addAttribute("error", "El email es obligatorio");
            model.addAttribute("email", email);
            return "login";
        }

        if (password == null || password.trim().isEmpty()) {
            model.addAttribute("error", "La contraseña es obligatoria");
            model.addAttribute("email", email);
            return "login";
        }

        try {
            // 2. Llamar al servicio para autenticar (hace TODAS las validaciones)
            Usuario usuario = usuarioService.autenticar(email.trim(), password);

            // 3. Si retorna null, las credenciales son inválidas o el usuario está inactivo
            if (usuario == null) {
                model.addAttribute("error", "Email o contraseña incorrectos, o cuenta desactivada");
                model.addAttribute("email", email);
                return "login";
            }

            // 4. Login exitoso - Crear sesión
            session.setAttribute("usuarioLogueado", usuario);
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("usuarioNombre", usuario.getNombre());
            session.setAttribute("usuarioEmail", usuario.getEmail());
            session.setAttribute("usuarioRol", usuario.getRol().toString());

            // Registrar sesión en el SessionRegistry para invalidaciones futuras
            try {
                SessionRegistry reg = SessionRegistry.getInstance();
                if (reg != null) {
                    reg.registerSession(usuario.getId(), session);
                }
            } catch (Exception e) {
                System.err.println("No se pudo registrar sesión en SessionRegistry: " + e.getMessage());
            }

            // 5. Establecer tiempo de sesión (30 minutos)
            session.setMaxInactiveInterval(30 * 60);

            // 6. Redirigir según el rol del usuario
            switch (usuario.getRol()) {
                case ADMINISTRADOR:
                    return "redirect:/admin/usuarios";

                case GESTOR_INVENTARIO:
                    return "redirect:/inventario/panel";

                case ANALISTA_DATOS:
                    return "redirect:/reportes/panel";

                default: // USUARIO_REGULAR
                    return "redirect:/catalogo";
            }

        } catch (Exception e) {
            // Manejar cualquier error inesperado
            System.err.println("ERROR EN LOGIN: " + e.getMessage());
            model.addAttribute("error", "Error en el sistema. Por favor, intenta nuevamente.");
            model.addAttribute("email", email);
            return "login";
        }
    }

    /**
     * Cierra la sesión del usuario
     * GET /logout
     *
     * @param session Sesión HTTP a invalidar
     * @return Redirección a la página de login con mensaje
     */
    @GetMapping("/logout")
    public String logout(HttpSession session, RedirectAttributes redirectAttributes) {
        // Invalidar la sesión (destruye todos los atributos)
        session.invalidate();

        // Agregar mensaje de confirmación
        redirectAttributes.addAttribute("mensaje", "logout");

        return "redirect:/login";
    }

    /**
     * Página de acceso denegado
     * GET /acceso-denegado
     *
     * @param model Modelo para pasar datos a la vista
     * @return Vista de acceso denegado
     */
    @GetMapping("/acceso-denegado")
    public String accesoDenegado(Model model, HttpSession session) {
        System.out.println("DEBUG: Accediendo a acceso-denegado");

        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");

        if (usuario != null) {
            model.addAttribute("mensaje",
                "No tienes permisos para acceder a esta sección. " +
                "Tu rol actual es: " + usuario.getRol());
            System.out.println("DEBUG: Usuario encontrado: " + usuario.getNombre());
        } else {
            model.addAttribute("mensaje",
                "Debes iniciar sesión para acceder a esta sección.");
            System.out.println("DEBUG: No hay usuario en sesión");
        }

        model.addAttribute("pageTitle", "Acceso Denegado - CineArchive");
        System.out.println("DEBUG: Retornando vista acceso-denegado");

        return "acceso-denegado"; // Crear esta vista o usar una existente
    }

    /**
     * Página de inicio después del login
     * GET /index o GET /
     *
     * @param session Sesión para verificar el usuario
     * @param model Modelo para pasar datos
     * @return Vista de inicio según el rol
     */
    @GetMapping({"/", "/index"})
    public String inicio(HttpSession session, Model model) {
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");

        // Si no hay sesión, redirigir a login
        if (usuario == null) {
            return "redirect:/login";
        }

        // Agregar datos del usuario al modelo
        model.addAttribute("usuario", usuario);

        // Redirigir según el rol
        switch (usuario.getRol()) {
            case ADMINISTRADOR:
                return "redirect:/admin/panel";

            case GESTOR_INVENTARIO:
                return "redirect:/inventario/panel";

            case ANALISTA_DATOS:
                return "redirect:/reportes/panel";

            default: // USUARIO_REGULAR
                return "redirect:/catalogo"; // Redirigir al catálogo para usuarios regulares
        }
    }

    /**
     * Muestra el perfil del usuario logueado
     * GET /perfil
     *
     * @param session Sesión para obtener el usuario
     * @param model Modelo para pasar datos
     * @return Vista del perfil
     */
    @GetMapping("/perfil")
    public String mostrarPerfil(HttpSession session, Model model) {
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");

        if (usuario == null) {
            return "redirect:/login";
        }

        // Obtener datos actualizados del usuario desde la BD
        Usuario usuarioActualizado = usuarioService.buscarPorId(usuario.getId());

        if (usuarioActualizado != null) {
            model.addAttribute("usuario", usuarioActualizado);
            // Actualizar sesión con datos frescos
            session.setAttribute("usuarioLogueado", usuarioActualizado);
        } else {
            model.addAttribute("usuario", usuario);
        }

        return "perfil"; // Vista del perfil (crear perfil.jsp)
    }

    /**
     * Método de prueba para verificar el funcionamiento del controlador
     */
    @GetMapping("/test-acceso-denegado")
    @ResponseBody
    public String testAccesoDenegado() {
        return "{ \"status\": \"OK\", \"message\": \"El controlador funciona correctamente\" }";
    }
}
