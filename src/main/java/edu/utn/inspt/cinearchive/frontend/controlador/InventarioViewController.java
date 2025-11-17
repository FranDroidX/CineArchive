package edu.utn.inspt.cinearchive.frontend.controlador;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Controlador para las vistas del Gestor de Inventario
 * Parte del Developer 3 - Manejo de frontend para gestión de inventarios
 */
@Controller
@RequestMapping("/inventario")
public class InventarioViewController {

    /**
     * Mostrar el panel principal del gestor de inventario
     * Endpoint principal para el rol GESTOR_INVENTARIO
     * REDIRIGE a /inventario (GestorInventarioController) que carga datos reales
     *
     * @param model el modelo para pasar datos a la vista
     * @return redirección al controlador principal
     */
    @GetMapping("/panel")
    public String mostrarPanelInventario(Model model) {
        // Redirigir al controlador que carga datos reales de la BD
        return "redirect:/inventario";
    }

    /**
     * Mostrar la página principal del gestor de inventario (alias de /panel)
     *
     * @param model el modelo para pasar datos a la vista
     * @return redirección al controlador principal
     */
    @GetMapping("/dashboard")
    public String mostrarDashboardInventario(Model model) {
        // Redirigir al controlador que carga datos reales de la BD
        return "redirect:/inventario";
    }

    /**
     * Mostrar formulario para agregar contenido
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/contenido/nuevo")
    public String mostrarFormularioNuevoContenido(Model model) {
        model.addAttribute("pageTitle", "Agregar Contenido - CineArchive");
        model.addAttribute("action", "crear");

        return "gestor-inventario";
    }

    /*
     * Mostrar gestión de categorías
     * NOTA: Este endpoint está comentado porque está duplicado con
     * GestorInventarioController.gestionarCategorias()
     * El método activo es el de GestorInventarioController que incluye
     * la lógica de carga de datos desde los servicios.
     */
    /*
    @GetMapping("/categorias")
    public String mostrarGestionCategorias(Model model) {
        model.addAttribute("pageTitle", "Gestión de Categorías - CineArchive");
        model.addAttribute("activeTab", "categorias");

        return "gestor-inventario";
    }
    */

    /**
     * Mostrar gestión de reseñas
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/resenas")
    public String mostrarGestionResenas(Model model) {
        model.addAttribute("pageTitle", "Gestión de Reseñas - CineArchive");
        model.addAttribute("activeTab", "resenas");

        return "gestor-inventario";
    }

    // Nota: El endpoint /estadisticas está manejado por GestorInventarioController
}
