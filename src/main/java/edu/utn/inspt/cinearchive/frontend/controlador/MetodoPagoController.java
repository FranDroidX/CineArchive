package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.modelo.MetodoPago;
import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import edu.utn.inspt.cinearchive.backend.servicio.MetodoPagoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;
import java.util.logging.Level;
import java.util.logging.Logger;

@Controller
@RequestMapping("/metodos-pago")
public class MetodoPagoController {

    private static final Logger logger = Logger.getLogger(MetodoPagoController.class.getName());

    @Autowired
    private MetodoPagoService metodoPagoService;

    /**
     * Obtiene el usuario de la sesión
     */
    private Usuario obtenerUsuarioSesion(HttpSession session) {
        return (Usuario) session.getAttribute("usuarioLogueado");
    }

    /**
     * Lista todos los métodos de pago del usuario
     */
    @GetMapping
    public String listar(Model model, HttpSession session) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        List<MetodoPago> metodosPago = metodoPagoService.obtenerPorUsuario(usuario.getId());
        model.addAttribute("metodosPago", metodosPago);
        model.addAttribute("usuarioLogueado", usuario);

        return "metodos-pago";
    }

    /**
     * Muestra el formulario para agregar un nuevo método de pago
     */
    @GetMapping("/nuevo")
    public String nuevoFormulario(Model model, HttpSession session) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        model.addAttribute("metodoPago", new MetodoPago());
        model.addAttribute("usuarioLogueado", usuario);
        model.addAttribute("tipos", MetodoPago.Tipo.values());
        model.addAttribute("tiposTarjeta", MetodoPago.TipoTarjeta.values());

        return "metodo-pago-form";
    }

    /**
     * Muestra el formulario para editar un método de pago existente
     */
    @GetMapping("/editar/{id}")
    public String editarFormulario(@PathVariable Long id, Model model, HttpSession session, RedirectAttributes ra) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        Optional<MetodoPago> metodoPago = metodoPagoService.buscarPorId(id);

        if (!metodoPago.isPresent()) {
            ra.addFlashAttribute("error", "Método de pago no encontrado");
            return "redirect:/metodos-pago";
        }

        if (!metodoPago.get().getUsuarioId().equals(usuario.getId())) {
            ra.addFlashAttribute("error", "No tiene permisos para editar este método de pago");
            return "redirect:/metodos-pago";
        }

        model.addAttribute("metodoPago", metodoPago.get());
        model.addAttribute("usuarioLogueado", usuario);
        model.addAttribute("tipos", MetodoPago.Tipo.values());
        model.addAttribute("tiposTarjeta", MetodoPago.TipoTarjeta.values());

        return "metodo-pago-form";
    }

    /**
     * Guarda un nuevo método de pago
     */
    @PostMapping("/guardar")
    public String guardar(@ModelAttribute MetodoPago metodoPago,
                         HttpSession session,
                         RedirectAttributes ra) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        try {
            metodoPago.setUsuarioId(usuario.getId());

            if (metodoPago.getId() == null) {
                // Crear nuevo
                metodoPagoService.crear(metodoPago);
                ra.addFlashAttribute("msg", "Método de pago agregado exitosamente");
            } else {
                // Actualizar existente
                metodoPagoService.actualizar(metodoPago);
                ra.addFlashAttribute("msg", "Método de pago actualizado exitosamente");
            }

            return "redirect:/metodos-pago";
        } catch (IllegalArgumentException e) {
            logger.log(Level.WARNING, "Error al guardar método de pago: {0}", e.getMessage());
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/metodos-pago/nuevo";
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error inesperado al guardar método de pago", e);
            ra.addFlashAttribute("error", "Error al guardar el método de pago");
            return "redirect:/metodos-pago/nuevo";
        }
    }

    /**
     * Marca un método de pago como preferido
     */
    @PostMapping("/preferido/{id}")
    public String marcarPreferido(@PathVariable Long id, HttpSession session, RedirectAttributes ra) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        try {
            boolean success = metodoPagoService.marcarComoPreferido(id, usuario.getId());
            if (success) {
                ra.addFlashAttribute("msg", "Método de pago marcado como preferido");
            } else {
                ra.addFlashAttribute("error", "No se pudo marcar como preferido");
            }
        } catch (IllegalArgumentException e) {
            logger.log(Level.WARNING, "Error al marcar preferido: {0}", e.getMessage());
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/metodos-pago";
    }

    /**
     * Desactiva un método de pago
     */
    @PostMapping("/desactivar/{id}")
    public String desactivar(@PathVariable Long id, HttpSession session, RedirectAttributes ra) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        try {
            boolean success = metodoPagoService.desactivar(id, usuario.getId());
            if (success) {
                ra.addFlashAttribute("msg", "Método de pago desactivado");
            } else {
                ra.addFlashAttribute("error", "No se pudo desactivar el método de pago");
            }
        } catch (IllegalArgumentException e) {
            logger.log(Level.WARNING, "Error al desactivar: {0}", e.getMessage());
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/metodos-pago";
    }

    /**
     * Elimina un método de pago
     */
    @PostMapping("/eliminar/{id}")
    public String eliminar(@PathVariable Long id, HttpSession session, RedirectAttributes ra) {
        Usuario usuario = obtenerUsuarioSesion(session);
        if (usuario == null) {
            return "redirect:/login";
        }

        try {
            boolean success = metodoPagoService.eliminar(id, usuario.getId());
            if (success) {
                ra.addFlashAttribute("msg", "Método de pago eliminado");
            } else {
                ra.addFlashAttribute("error", "No se pudo eliminar el método de pago");
            }
        } catch (IllegalArgumentException e) {
            logger.log(Level.WARNING, "Error al eliminar: {0}", e.getMessage());
            ra.addFlashAttribute("error", e.getMessage());
        }

        return "redirect:/metodos-pago";
    }
}

