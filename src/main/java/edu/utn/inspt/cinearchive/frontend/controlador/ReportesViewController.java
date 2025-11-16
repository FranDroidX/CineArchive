package edu.utn.inspt.cinearchive.frontend.controlador;

import edu.utn.inspt.cinearchive.backend.servicio.ReporteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controlador para las vistas del Analista de Datos
 * Parte del Developer 3 - Manejo de frontend para reportes y analytics
 * ACTUALIZADO: Ahora carga datos reales desde el servicio
 */
@Controller
@RequestMapping("/reportes")
public class ReportesViewController {

    @Autowired
    private ReporteService reporteService;

    /**
     * Mostrar el panel principal del analista de datos
     * Endpoint principal para el rol ANALISTA_DATOS
     * ACTUALIZADO: Carga datos reales desde la base de datos
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/panel")
    public String mostrarPanelReportes(Model model) {
        // Agregar metadatos para la vista
        model.addAttribute("pageTitle", "Centro de Análisis de Datos - CineArchive");
        model.addAttribute("pageDescription", "Dashboard integral para análisis de comportamiento, tendencias y métricas de negocio");
        model.addAttribute("currentSection", "reportes");

        // Configurar fechas por defecto (últimos 30 días)
        LocalDate fechaFin = LocalDate.now();
        LocalDate fechaInicio = fechaFin.minusDays(30);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        model.addAttribute("fechaInicio", fechaInicio.format(formatter));
        model.addAttribute("fechaFin", fechaFin.format(formatter));
        model.addAttribute("periodoSeleccionado", 30);

        // CARGAR ESTADÍSTICAS GENERALES
        try {
            Map<String, Object> estadisticas = reporteService.obtenerEstadisticasGenerales();
            model.addAttribute("estadisticas", estadisticas);
        } catch (Exception e) {
            System.err.println("Error cargando estadísticas: " + e.getMessage());
            e.printStackTrace();
            // Valores por defecto si falla
            Map<String, Object> estadisticasDefault = new HashMap<>();
            estadisticasDefault.put("total_alquileres", 0);
            estadisticasDefault.put("total_usuarios", 0);
            estadisticasDefault.put("calificacion_promedio_global", 0.0);
            estadisticasDefault.put("ingresos_totales", 0.0);
            estadisticasDefault.put("total_contenidos", 0);
            estadisticasDefault.put("total_resenas", 0);
            model.addAttribute("estadisticas", estadisticasDefault);
        }

        // CARGAR TOP 10 CONTENIDOS MÁS ALQUILADOS
        try {
            List<Map<String, Object>> topContenidos = reporteService.obtenerTopContenidos(
                fechaInicio, fechaFin, 10
            );
            model.addAttribute("topContenidos", topContenidos);
        } catch (Exception e) {
            System.err.println("Error cargando top contenidos: " + e.getMessage());
            model.addAttribute("topContenidos", Collections.emptyList());
        }

        // Secciones eliminadas: rendimientoGeneros, demografico, tendencias, categoriasPopulares

        return "analista-datos";
    }

    /*
     * Mostrar el dashboard principal del analista de datos (alias de /panel)
     * NOTA: Este endpoint está comentado porque está duplicado con
     * ReporteController.mostrarDashboard()
     * El método activo es el de ReporteController que incluye
     * la lógica completa de carga de datos desde los servicios.
     */
    /*
    @GetMapping("/dashboard")
    public String mostrarDashboardAnalytics(Model model) {
        // Redirigir al endpoint principal /panel
        return mostrarPanelReportes(model);
    }
    */

    /**
     * Mostrar analytics con filtros específicos
     * ACTUALIZADO: Carga datos filtrados desde la base de datos
     *
     * @param periodo período de análisis en días
     * @param fechaInicio fecha de inicio personalizada
     * @param fechaFin fecha de fin personalizada
     * @param tipoContenido tipo de contenido a analizar
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/analytics")
    public String mostrarAnalyticsConFiltros(
            @RequestParam(required = false, defaultValue = "30") int periodo,
            @RequestParam(required = false) String fechaInicio,
            @RequestParam(required = false) String fechaFin,
            @RequestParam(required = false) String tipoContenido,
            Model model) {

        model.addAttribute("pageTitle", "Analytics Avanzados - CineArchive");
        model.addAttribute("currentSection", "reportes");

        // Configurar filtros
        model.addAttribute("periodoSeleccionado", periodo);
        model.addAttribute("tipoContenidoSeleccionado", tipoContenido != null ? tipoContenido : "");

        // Calcular fechas
        LocalDate fin;
        LocalDate inicio;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        if (fechaInicio == null || fechaFin == null) {
            fin = LocalDate.now();
            inicio = fin.minusDays(periodo);
        } else {
            inicio = LocalDate.parse(fechaInicio);
            fin = LocalDate.parse(fechaFin);
        }

        model.addAttribute("fechaInicio", inicio.format(formatter));
        model.addAttribute("fechaFin", fin.format(formatter));

        // CARGAR DATOS CON FILTROS (solo estadísticas y top contenidos)
        try {
            Map<String, Object> estadisticas = reporteService.obtenerEstadisticasGenerales();
            model.addAttribute("estadisticas", estadisticas);

            List<Map<String, Object>> topContenidos = reporteService.obtenerTopContenidos(inicio, fin, 10);
            model.addAttribute("topContenidos", topContenidos);
        } catch (Exception e) {
            System.err.println("Error cargando analytics con filtros: " + e.getMessage());
        }

        return "analista-datos";
    }

    /**
     * Mostrar página de reportes personalizados
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/personalizados")
    public String mostrarReportesPersonalizados(Model model) {
        model.addAttribute("pageTitle", "Reportes Personalizados - CineArchive");
        model.addAttribute("currentSection", "reportes");
        model.addAttribute("focusSection", "reportes");

        return "analista-datos";
    }

    /**
     * Mostrar análisis demográfico detallado
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/demografico")
    public String mostrarAnalisisDemografico(Model model) {
        model.addAttribute("pageTitle", "Análisis Demográfico - CineArchive");
        model.addAttribute("currentSection", "reportes");
        model.addAttribute("focusChart", "demografico");

        return "analista-datos";
    }

    /**
     * Mostrar análisis de tendencias temporales
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/tendencias")
    public String mostrarTendenciasTemporales(Model model) {
        model.addAttribute("pageTitle", "Tendencias Temporales - CineArchive");
        model.addAttribute("currentSection", "reportes");
        model.addAttribute("focusChart", "tendencias");

        return "analista-datos";
    }

    /**
     * Mostrar análisis de comportamiento de usuarios
     *
     * @param model el modelo para pasar datos a la vista
     * @return el nombre de la vista JSP
     */
    @GetMapping("/comportamiento")
    public String mostrarComportamientoUsuarios(Model model) {
        model.addAttribute("pageTitle", "Comportamiento de Usuarios - CineArchive");
        model.addAttribute("currentSection", "reportes");
        model.addAttribute("focusAnalytics", "comportamiento");

        return "analista-datos";
    }
}
