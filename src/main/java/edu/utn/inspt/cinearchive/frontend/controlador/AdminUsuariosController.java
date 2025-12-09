package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import edu.utn.inspt.cinearchive.backend.modelo.Usuario.Rol;
import edu.utn.inspt.cinearchive.backend.servicio.UsuarioService;
import edu.utn.inspt.cinearchive.security.SessionRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Controlador para la administración de usuarios
 * Solo accesible para usuarios con rol ADMINISTRADOR
 *
 * Funcionalidades:
 * - Listar usuarios con filtros
 * - Crear nuevos usuarios (cualquier rol)
 * - Editar usuarios existentes
 * - Activar/desactivar usuarios
 * - Eliminar usuarios
 * - Ver detalles de usuarios
 *
 * @author Developer 1 (CHAMA)
 * @version 1.0
 * @since 2025-11-07
 */
@Controller
@RequestMapping("/admin/usuarios")
public class AdminUsuariosController {

    @Autowired
    private UsuarioService usuarioService;

    // No inyectamos SessionRegistry para evitar problemas en contextos no gestionados; usamos la instancia estática.

    // ============================================================
    // LISTADO Y BÚSQUEDA DE USUARIOS
    // ============================================================

    /**
     * Lista todos los usuarios del sistema con filtros opcionales
     * GET /admin/usuarios
     *
     * @param rol Filtro opcional por rol
     * @param activo Filtro opcional por estado (activo/inactivo)
     * @param busqueda Búsqueda opcional por nombre o email
     * @param model Modelo para pasar datos a la vista
     * @param session Sesión HTTP para verificar permisos
     * @return Vista de listado de usuarios (admin/usuarios.jsp)
     */
    @GetMapping
    public String listarUsuarios(
            @RequestParam(value = "rol", required = false) String rol,
            @RequestParam(value = "activo", required = false) Boolean activo,
            @RequestParam(value = "busqueda", required = false) String busqueda,
            Model model,
            HttpSession session) {

        // Verificar que el usuario logueado es administrador
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        // Obtener todos los usuarios
        List<Usuario> usuarios = usuarioService.listarTodos();

        // Aplicar filtros si existen
        if (rol != null && !rol.isEmpty()) {
            try {
                Rol rolEnum = Rol.valueOf(rol);
                usuarios = usuarios.stream()
                        .filter(u -> u.getRol() == rolEnum)
                        .collect(Collectors.toList());
            } catch (IllegalArgumentException e) {
                // Rol inválido, ignorar filtro
            }
        }

        if (activo != null) {
            usuarios = usuarios.stream()
                    .filter(u -> u.getActivo().equals(activo))
                    .collect(Collectors.toList());
        }

        if (busqueda != null && !busqueda.trim().isEmpty()) {
            String busquedaLower = busqueda.trim().toLowerCase();
            usuarios = usuarios.stream()
                    .filter(u -> u.getNombre().toLowerCase().contains(busquedaLower) ||
                                 u.getEmail().toLowerCase().contains(busquedaLower))
                    .collect(Collectors.toList());
        }

        // Calcular estadísticas
        long totalUsuarios = usuarios.size();
        long usuariosActivos = usuarios.stream().filter(Usuario::getActivo).count();
        long usuariosInactivos = totalUsuarios - usuariosActivos;

        // Contar por roles
        long totalAdministradores = usuarios.stream()
                .filter(u -> u.getRol() == Rol.ADMINISTRADOR)
                .count();
        long totalGestores = usuarios.stream()
                .filter(u -> u.getRol() == Rol.GESTOR_INVENTARIO)
                .count();
        long totalAnalistas = usuarios.stream()
                .filter(u -> u.getRol() == Rol.ANALISTA_DATOS)
                .count();
        long totalRegulares = usuarios.stream()
                .filter(u -> u.getRol() == Rol.USUARIO_REGULAR)
                .count();

        // Agregar datos al modelo
        model.addAttribute("usuarios", usuarios);
        model.addAttribute("totalUsuarios", totalUsuarios);
        model.addAttribute("usuariosActivos", usuariosActivos);
        model.addAttribute("usuariosInactivos", usuariosInactivos);
        model.addAttribute("totalAdministradores", totalAdministradores);
        model.addAttribute("totalGestores", totalGestores);
        model.addAttribute("totalAnalistas", totalAnalistas);
        model.addAttribute("totalRegulares", totalRegulares);

        // Mantener valores de filtros en el formulario
        model.addAttribute("rolFiltro", rol);
        model.addAttribute("activoFiltro", activo);
        model.addAttribute("busquedaFiltro", busqueda);

        // Array de roles para el select del filtro
        model.addAttribute("roles", Rol.values());

        // Usuario logueado para el header
        model.addAttribute("usuarioLogueado", usuarioLogueado);

        return "admin/usuarios";
    }

    // ============================================================
    // CREAR NUEVO USUARIO
    // ============================================================

    /**
     * Muestra el formulario para crear un nuevo usuario
     * GET /admin/usuarios/crear
     *
     * @param model Modelo para pasar datos a la vista
     * @param session Sesión HTTP para verificar permisos
     * @return Vista del formulario (admin/usuario-form.jsp)
     */
    @GetMapping("/crear")
    public String mostrarFormularioCrear(Model model, HttpSession session) {
        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        // Crear usuario vacío para el formulario
        Usuario usuario = new Usuario();
        usuario.setActivo(true); // Por defecto activo
        usuario.setRol(Rol.USUARIO_REGULAR); // Rol por defecto

        model.addAttribute("usuario", usuario);
        model.addAttribute("roles", Rol.values());
        model.addAttribute("esNuevo", true);
        model.addAttribute("titulo", "Crear Nuevo Usuario");
        model.addAttribute("usuarioLogueado", usuarioLogueado);

        return "admin/usuario-form";
    }

    /**
     * Procesa la creación de un nuevo usuario
     * POST /admin/usuarios/crear
     *
     * @param nombre Nombre completo del usuario
     * @param email Email único del usuario
     * @param password Contraseña en texto plano
     * @param passwordConfirm Confirmación de contraseña
     * @param rol Rol del usuario
     * @param fechaNacimiento Fecha de nacimiento (opcional)
     * @param activo Estado inicial del usuario
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/crear")
    public String crearUsuario(
            @RequestParam String nombre,
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String passwordConfirm,
            @RequestParam Rol rol,
            @RequestParam(required = false) String fechaNacimiento,
            @RequestParam(defaultValue = "true") Boolean activo,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            // Validar que los campos obligatorios no estén vacíos
            if (nombre == null || nombre.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "El nombre es obligatorio");
                return "redirect:/admin/usuarios/crear";
            }

            if (email == null || email.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "El email es obligatorio");
                return "redirect:/admin/usuarios/crear";
            }

            if (password == null || password.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "La contraseña es obligatoria");
                return "redirect:/admin/usuarios/crear";
            }

            // Validar que las contraseñas coincidan
            if (!password.equals(passwordConfirm)) {
                redirectAttributes.addFlashAttribute("error", "Las contraseñas no coinciden");
                redirectAttributes.addFlashAttribute("nombre", nombre);
                redirectAttributes.addFlashAttribute("email", email);
                return "redirect:/admin/usuarios/crear";
            }

            // Validar formato de email básico
            if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                redirectAttributes.addFlashAttribute("error", "El formato del email no es válido");
                redirectAttributes.addFlashAttribute("nombre", nombre);
                return "redirect:/admin/usuarios/crear";
            }

            // Crear el usuario a través del service
            Usuario nuevoUsuario = usuarioService.registrar(
                    nombre.trim(),
                    email.trim().toLowerCase(),
                    password,
                    rol
            );

            // Establecer fecha de nacimiento si se proporcionó
            if (fechaNacimiento != null && !fechaNacimiento.trim().isEmpty()) {
                try {
                    LocalDate fecha = LocalDate.parse(fechaNacimiento);
                    // Validar que no sea fecha futura
                    if (fecha.isAfter(LocalDate.now())) {
                        redirectAttributes.addFlashAttribute("warning",
                                "Usuario creado pero la fecha de nacimiento no puede ser futura");
                    } else {
                        nuevoUsuario.setFechaNacimiento(fecha);
                        usuarioService.actualizar(nuevoUsuario);
                    }
                } catch (Exception e) {
                    // Fecha inválida, ignorar
                    redirectAttributes.addFlashAttribute("warning",
                            "Usuario creado pero la fecha de nacimiento no es válida");
                }
            }

            // Si el usuario debe estar inactivo desde el inicio
            if (!activo) {
                usuarioService.desactivar(nuevoUsuario.getId());
            }

            // Mensaje de éxito
            redirectAttributes.addFlashAttribute("mensaje",
                    "Usuario '" + nuevoUsuario.getNombre() + "' creado exitosamente");
            redirectAttributes.addFlashAttribute("tipoMensaje", "success");

            return "redirect:/admin/usuarios";

        } catch (IllegalArgumentException e) {
            // Error de validación del service (email duplicado, password débil, etc.)
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            redirectAttributes.addFlashAttribute("nombre", nombre);
            redirectAttributes.addFlashAttribute("email", email);
            return "redirect:/admin/usuarios/crear";

        } catch (Exception e) {
            // Error inesperado
            redirectAttributes.addFlashAttribute("error",
                    "Error al crear usuario: " + e.getMessage());
            return "redirect:/admin/usuarios/crear";
        }
    }

    // ============================================================
    // EDITAR USUARIO EXISTENTE
    // ============================================================

    /**
     * Muestra el formulario para editar un usuario existente
     * GET /admin/usuarios/editar/{id}
     *
     * @param id ID del usuario a editar
     * @param model Modelo para pasar datos a la vista
     * @param session Sesión HTTP
     * @param redirectAttributes Atributos para mensajes flash
     * @return Vista del formulario de edición
     */
    @GetMapping("/editar/{id}")
    public String mostrarFormularioEditar(
            @PathVariable Long id,
            Model model,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            // Buscar el usuario
            Usuario usuario = usuarioService.buscarPorId(id);

            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Agregar datos al modelo
            model.addAttribute("usuario", usuario);
            model.addAttribute("roles", Rol.values());
            model.addAttribute("esNuevo", false);
            model.addAttribute("usuarioLogueado", usuarioLogueado);
            model.addAttribute("titulo", "Editar Usuario");

            return "admin/usuario-form";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al cargar usuario: " + e.getMessage());
            return "redirect:/admin/usuarios";
        }
    }

    /**
     * Procesa la edición de un usuario
     * POST /admin/usuarios/editar/{id}
     *
     * @param id ID del usuario a editar
     * @param nombre Nuevo nombre
     * @param email Nuevo email
     * @param passwordNueva Nueva contraseña (opcional, dejar vacío para no cambiar)
     * @param passwordConfirm Confirmación de nueva contraseña
     * @param rol Nuevo rol
     * @param activo Nuevo estado
     * @param fechaNacimiento Nueva fecha de nacimiento (opcional)
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/editar/{id}")
    public String editarUsuario(
            @PathVariable Long id,
            @RequestParam String nombre,
            @RequestParam String email,
            @RequestParam(required = false) String passwordNueva,
            @RequestParam(required = false) String passwordConfirm,
            @RequestParam Rol rol,
            @RequestParam(required = false, defaultValue = "false") Boolean activo,
            @RequestParam(required = false) String fechaNacimiento,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            // Buscar usuario existente
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Validar campos obligatorios
            if (nombre == null || nombre.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "El nombre es obligatorio");
                return "redirect:/admin/usuarios/editar/" + id;
            }

            if (email == null || email.trim().isEmpty()) {
                redirectAttributes.addFlashAttribute("error", "El email es obligatorio");
                return "redirect:/admin/usuarios/editar/" + id;
            }

            // Validar formato de email
            if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
                redirectAttributes.addFlashAttribute("error", "El formato del email no es válido");
                return "redirect:/admin/usuarios/editar/" + id;
            }

            // Validar que no se esté desactivando o degradando al último administrador
            if (usuario.getRol() == Rol.ADMINISTRADOR) {
                long totalAdminsActivos = usuarioService.listarTodos().stream()
                        .filter(u -> u.getRol() == Rol.ADMINISTRADOR && u.getActivo())
                        .count();

                if (totalAdminsActivos <= 1) {
                    if (!activo) {
                        redirectAttributes.addFlashAttribute("error",
                                "No se puede desactivar al último administrador activo");
                        return "redirect:/admin/usuarios/editar/" + id;
                    }
                    if (rol != Rol.ADMINISTRADOR) {
                        redirectAttributes.addFlashAttribute("error",
                                "No se puede cambiar el rol del último administrador activo");
                        return "redirect:/admin/usuarios/editar/" + id;
                    }
                }
            }

            // Prevenir que un admin se desactive a sí mismo
            if (usuario.getId() != null && usuarioLogueado.getId() != null && usuario.getId().equals(usuarioLogueado.getId()) && !activo) {
                redirectAttributes.addFlashAttribute("error",
                        "No puedes desactivar tu propia cuenta");
                return "redirect:/admin/usuarios/editar/" + id;
            }

            // Si se proporcionó una nueva contraseña, validarla y actualizarla
            if (passwordNueva != null && !passwordNueva.trim().isEmpty()) {
                if (passwordConfirm == null || !passwordNueva.equals(passwordConfirm)) {
                    redirectAttributes.addFlashAttribute("error", "Las contraseñas no coinciden");
                    return "redirect:/admin/usuarios/editar/" + id;
                }

                // La validación de fortaleza la hace el service
                usuario.setContrasena(passwordNueva); // Se encriptará en el service
            }

            // Actualizar campos básicos
            usuario.setNombre(nombre.trim());
            usuario.setEmail(email.trim().toLowerCase());
            usuario.setRol(rol);
            usuario.setActivo(activo);

            // Actualizar fecha de nacimiento si se proporcionó
            if (fechaNacimiento != null && !fechaNacimiento.trim().isEmpty()) {
                try {
                    LocalDate fecha = LocalDate.parse(fechaNacimiento);
                    if (fecha.isAfter(LocalDate.now())) {
                        redirectAttributes.addFlashAttribute("warning",
                                "Usuario actualizado pero la fecha de nacimiento no puede ser futura");
                    } else {
                        usuario.setFechaNacimiento(fecha);
                    }
                } catch (Exception e) {
                    // Fecha inválida, mantener la anterior
                }
            }

            // Guardar cambios
            usuarioService.actualizar(usuario);

            // Invalidar sesiones del usuario actualizado para que sus permisos se revaliden
            try {
                SessionRegistry reg = SessionRegistry.getInstance();
                if (reg != null) reg.invalidateSessionsForUser(id);
            } catch (Exception e) {
                System.err.println("Error invalidando sesiones tras editar usuario " + id + ": " + e.getMessage());
            }

            // Mensaje de éxito
            redirectAttributes.addFlashAttribute("mensaje",
                    "Usuario '" + usuario.getNombre() + "' actualizado exitosamente");
            redirectAttributes.addFlashAttribute("tipoMensaje", "success");

            return "redirect:/admin/usuarios";

        } catch (IllegalArgumentException e) {
            // Error de validación
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/usuarios/editar/" + id;

        } catch (Exception e) {
            // Error inesperado
            redirectAttributes.addFlashAttribute("error",
                    "Error al actualizar usuario: " + e.getMessage());
            return "redirect:/admin/usuarios/editar/" + id;
        }
    }

    // ============================================================
    // CAMBIAR ESTADO (ACTIVAR/DESACTIVAR)
    // ============================================================

    /**
     * Cambia el estado de un usuario (toggle activo/inactivo)
     * POST /admin/usuarios/cambiar-estado/{id}
     *
     * @param id ID del usuario
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/cambiar-estado/{id}")
    public String cambiarEstado(
            @PathVariable Long id,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Prevenir que un admin se desactive a sí mismo
            if (usuario.getId() != null && usuarioLogueado.getId() != null && usuario.getId().equals(usuarioLogueado.getId())) {
                redirectAttributes.addFlashAttribute("error",
                        "No puedes cambiar el estado de tu propia cuenta");
                return "redirect:/admin/usuarios";
            }

            // Validar que no se esté desactivando al último administrador
            if (usuario.getRol() == Rol.ADMINISTRADOR && usuario.getActivo()) {
                long totalAdminsActivos = usuarioService.listarTodos().stream()
                        .filter(u -> u.getRol() == Rol.ADMINISTRADOR && u.getActivo())
                        .count();

                if (totalAdminsActivos <= 1) {
                    redirectAttributes.addFlashAttribute("error",
                            "No se puede desactivar al último administrador activo");
                    return "redirect:/admin/usuarios";
                }
            }

            boolean exito = usuarioService.cambiarEstado(id, !usuario.getActivo());

            if (exito) {
                // Invalidar sesiones del usuario cuyo estado cambió
                try {
                    SessionRegistry reg = SessionRegistry.getInstance();
                    if (reg != null) reg.invalidateSessionsForUser(id);
                } catch (Exception e) {
                    System.err.println("Error invalidando sesiones tras cambiar estado usuario " + id + ": " + e.getMessage());
                }

                String accion = !usuario.getActivo() ? "activado" : "desactivado";
                redirectAttributes.addFlashAttribute("mensaje",
                        "Usuario '" + usuario.getNombre() + "' " + accion + " exitosamente");
                redirectAttributes.addFlashAttribute("tipoMensaje", "success");
            } else {
                redirectAttributes.addFlashAttribute("error",
                        "Error al cambiar el estado del usuario");
            }

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al cambiar estado: " + e.getMessage());
        }

        return "redirect:/admin/usuarios";
    }

    /**
     * Activa un usuario específico
     * POST /admin/usuarios/activar/{id}
     *
     * @param id ID del usuario a activar
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/activar/{id}")
    public String activarUsuario(
            @PathVariable Long id,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            boolean exito = usuarioService.activar(id);

            if (exito) {
                // Invalidar sesiones para forzar reload (aunque activación probablemente no necesite logout)
                try {
                    SessionRegistry reg = SessionRegistry.getInstance();
                    if (reg != null) reg.invalidateSessionsForUser(id);
                } catch (Exception e) {
                    System.err.println("Error invalidando sesiones tras activar usuario " + id + ": " + e.getMessage());
                }

                redirectAttributes.addFlashAttribute("mensaje",
                        "Usuario '" + usuario.getNombre() + "' activado exitosamente");
                redirectAttributes.addFlashAttribute("tipoMensaje", "success");
            } else {
                redirectAttributes.addFlashAttribute("error",
                        "Error al activar el usuario");
            }

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al activar usuario: " + e.getMessage());
        }

        return "redirect:/admin/usuarios";
    }

    /**
     * Desactiva un usuario específico
     * POST /admin/usuarios/desactivar/{id}
     *
     * @param id ID del usuario a desactivar
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/desactivar/{id}")
    public String desactivarUsuario(
            @PathVariable Long id,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Prevenir auto-desactivación
            if (usuario.getId() == usuarioLogueado.getId()) {
                redirectAttributes.addFlashAttribute("error",
                        "No puedes desactivar tu propia cuenta");
                return "redirect:/admin/usuarios";
            }

            // Validar que no sea el último admin activo
            if (usuario.getRol() == Rol.ADMINISTRADOR && usuario.getActivo()) {
                long totalAdminsActivos = usuarioService.listarTodos().stream()
                        .filter(u -> u.getRol() == Rol.ADMINISTRADOR && u.getActivo())
                        .count();

                if (totalAdminsActivos <= 1) {
                    redirectAttributes.addFlashAttribute("error",
                            "No se puede desactivar al último administrador activo");
                    return "redirect:/admin/usuarios";
                }
            }

            boolean exito = usuarioService.desactivar(id);

            if (exito) {
                // Invalidar sesiones del usuario desactivado
                try {
                    SessionRegistry reg = SessionRegistry.getInstance();
                    if (reg != null) reg.invalidateSessionsForUser(id);
                } catch (Exception e) {
                    System.err.println("Error invalidando sesiones tras desactivar usuario " + id + ": " + e.getMessage());
                }

                redirectAttributes.addFlashAttribute("mensaje",
                        "Usuario '" + usuario.getNombre() + "' desactivado exitosamente");
                redirectAttributes.addFlashAttribute("tipoMensaje", "success");
            } else {
                redirectAttributes.addFlashAttribute("error",
                        "Error al desactivar el usuario");
            }

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al desactivar usuario: " + e.getMessage());
        }

        return "redirect:/admin/usuarios";
    }

    // ============================================================
    // ELIMINAR USUARIO (FÍSICAMENTE)
    // ============================================================

    /**
     * Elimina un usuario permanentemente de la base de datos
     * POST /admin/usuarios/eliminar/{id}
     *
     * ADVERTENCIA: Esta es una eliminación física (hard delete).
     * Los datos se perderán permanentemente.
     * Se recomienda usar desactivar() en su lugar.
     *
     * @param id ID del usuario a eliminar
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/eliminar/{id}")
    public String eliminarUsuario(
            @PathVariable Long id,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            // Buscar usuario
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Prevenir auto-eliminación
            if (usuario.getId() == usuarioLogueado.getId()) {
                redirectAttributes.addFlashAttribute("error",
                        "No puedes eliminar tu propia cuenta");
                return "redirect:/admin/usuarios";
            }

            // Validar que no sea el último administrador
            if (usuario.getRol() == Rol.ADMINISTRADOR) {
                long totalAdmins = usuarioService.listarTodos().stream()
                        .filter(u -> u.getRol() == Rol.ADMINISTRADOR)
                        .count();

                if (totalAdmins <= 1) {
                    redirectAttributes.addFlashAttribute("error",
                            "No se puede eliminar al último administrador del sistema");
                    return "redirect:/admin/usuarios";
                }
            }

            String nombreUsuario = usuario.getNombre();
            boolean exito = usuarioService.eliminar(id);

            if (exito) {
                // Invalidar sesiones del usuario eliminado
                try {
                    SessionRegistry reg = SessionRegistry.getInstance();
                    if (reg != null) reg.invalidateSessionsForUser(id);
                } catch (Exception e) {
                    System.err.println("Error invalidando sesiones tras eliminar usuario " + id + ": " + e.getMessage());
                }

                redirectAttributes.addFlashAttribute("mensaje",
                        "Usuario '" + nombreUsuario + "' eliminado permanentemente");
                redirectAttributes.addFlashAttribute("tipoMensaje", "warning");
            } else {
                redirectAttributes.addFlashAttribute("error",
                        "Error al eliminar el usuario");
            }

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al eliminar usuario: " + e.getMessage());
        }

        return "redirect:/admin/usuarios";
    }

    // ============================================================
    // VER DETALLES DE USUARIO
    // ============================================================

    /**
     * Muestra la información detallada de un usuario
     * GET /admin/usuarios/detalle/{id}
     *
     * @param id ID del usuario
     * @param model Modelo para pasar datos a la vista
     * @param session Sesión HTTP
     * @param redirectAttributes Atributos para mensajes flash
     * @return Vista de detalle del usuario
     */
    @GetMapping("/detalle/{id}")
    public String verDetalle(
            @PathVariable Long id,
            Model model,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            // Buscar usuario
            Usuario usuario = usuarioService.buscarPorId(id);

            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Agregar datos al modelo
            model.addAttribute("usuario", usuario);

            // Información adicional
            model.addAttribute("esUltimoAdmin",
                    usuario.getRol() == Rol.ADMINISTRADOR &&
                    usuarioService.listarTodos().stream()
                            .filter(u -> u.getRol() == Rol.ADMINISTRADOR && u.getActivo())
                            .count() <= 1);
            model.addAttribute("usuarioLogueado", usuarioLogueado);

            model.addAttribute("esMismaCuenta", usuario.getId() != null && usuarioLogueado.getId() != null && usuario.getId().equals(usuarioLogueado.getId()));

            return "admin/usuario-detalle";

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al cargar detalles del usuario: " + e.getMessage());
            return "redirect:/admin/usuarios";
        }
    }

    // ============================================================
    // CAMBIAR ROL DE USUARIO
    // ============================================================

    /**
     * Cambia el rol de un usuario
     * POST /admin/usuarios/cambiar-rol/{id}
     *
     * @param id ID del usuario
     * @param nuevoRol Nuevo rol a asignar
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/cambiar-rol/{id}")
    public String cambiarRol(
            @PathVariable Long id,
            @RequestParam Rol nuevoRol,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Validar que no se esté degradando al último administrador
            if (usuario.getRol() == Rol.ADMINISTRADOR && nuevoRol != Rol.ADMINISTRADOR) {
                long totalAdminsActivos = usuarioService.listarTodos().stream()
                        .filter(u -> u.getRol() == Rol.ADMINISTRADOR && u.getActivo())
                        .count();

                if (totalAdminsActivos <= 1) {
                    redirectAttributes.addFlashAttribute("error",
                            "No se puede cambiar el rol del último administrador activo");
                    return "redirect:/admin/usuarios";
                }
            }

            usuarioService.cambiarRol(id, nuevoRol);

            // cambiarRol en el service ya invalida sesiones, pero dejamos este llamado por compatibilidad
            try {
                SessionRegistry reg = SessionRegistry.getInstance();
                if (reg != null) reg.invalidateSessionsForUser(id);
            } catch (Exception e) {
                System.err.println("Error invalidando sesiones tras cambiar rol usuario " + id + ": " + e.getMessage());
            }

            redirectAttributes.addFlashAttribute("mensaje",
                    "Rol de '" + usuario.getNombre() + "' cambiado a " + nuevoRol + " exitosamente");
            redirectAttributes.addFlashAttribute("tipoMensaje", "success");

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al cambiar rol: " + e.getMessage());
        }

        return "redirect:/admin/usuarios";
    }

    // ============================================================
    // RESTABLECER CONTRASEÑA
    // ============================================================

    /**
     * Restablece la contraseña de un usuario (sin requerir la contraseña actual)
     * POST /admin/usuarios/restablecer-password/{id}
     *
     * @param id ID del usuario
     * @param passwordNueva Nueva contraseña
     * @param passwordConfirm Confirmación de contraseña
     * @param redirectAttributes Atributos para mensajes flash
     * @param session Sesión HTTP
     * @return Redirección al listado de usuarios
     */
    @PostMapping("/restablecer-password/{id}")
    public String restablecerPassword(
            @PathVariable Long id,
            @RequestParam String passwordNueva,
            @RequestParam String passwordConfirm,
            RedirectAttributes redirectAttributes,
            HttpSession session) {

        // Verificar permisos
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");
        if (usuarioLogueado == null || usuarioLogueado.getRol() != Rol.ADMINISTRADOR) {
            return "redirect:/acceso-denegado";
        }

        try {
            Usuario usuario = usuarioService.buscarPorId(id);
            if (usuario == null) {
                redirectAttributes.addFlashAttribute("error", "Usuario no encontrado");
                return "redirect:/admin/usuarios";
            }

            // Validar que las contraseñas coincidan
            if (!passwordNueva.equals(passwordConfirm)) {
                redirectAttributes.addFlashAttribute("error", "Las contraseñas no coinciden");
                return "redirect:/admin/usuarios/detalle/" + id;
            }

            // Restablecer contraseña (el service valida que sea segura)
            usuarioService.restablecerContrasena(id, passwordNueva);

            redirectAttributes.addFlashAttribute("mensaje",
                    "Contraseña de '" + usuario.getNombre() + "' restablecida exitosamente");
            redirectAttributes.addFlashAttribute("tipoMensaje", "success");

        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/usuarios/detalle/" + id;

        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error",
                    "Error al restablecer contraseña: " + e.getMessage());
            return "redirect:/admin/usuarios/detalle/" + id;
        }

        return "redirect:/admin/usuarios";
    }
}

