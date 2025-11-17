/**
 * CineArchive - Sistema de Reportes
 * JavaScript para el módulo de reportes y analytics del Developer 3
 * Funcionalidades: Dashboard, KPIs, generación de reportes y análisis de datos
 */

// =====================================
// VARIABLES GLOBALES
// =====================================
let dashboardData = {};
let reportesCache = {};
let filtrosActuales = {};

// =====================================
// INICIALIZACIÓN DEL DASHBOARD
// =====================================

/**
 * Cargar dashboard completo con todos los datos
 */
async function cargarDashboardCompleto() {
    try {
        mostrarCargandoDashboard();

        // Cargar datos en paralelo
        await Promise.all([
            cargarKPIsPrincipales(),
            cargarTopContenidos(),
            cargarTopGeneros(),
            cargarMetricasRapidas(),
            cargarMetricasTemporales(),
            cargarMetricasNegocio()
        ]);

        ocultarCargandoDashboard();
    } catch (error) {
        console.error('Error al cargar dashboard completo:', error);
        mostrarErrorDashboard('Error al cargar los datos del dashboard');
    }
}

/**
 * Cargar KPIs principales
 */
async function cargarKPIsPrincipales() {
    try {
        const params = new URLSearchParams(filtrosActuales);
        const response = await fetch(`/cinearchive/reportes/api/dashboard?${params}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const data = await response.json();
            dashboardData.kpis = data;
            actualizarKPIsEnVista(data);
        } else {
            // Datos simulados para demostración
            const datosPrueba = {
                totalVisualizaciones: 15420,
                ingresosTotales: 245680.50,
                usuariosActivos: 1847,
                calificacionPromedio: 4.2,
                tendencias: {
                    visualizaciones: 12,
                    ingresos: 8,
                    usuarios: 0,
                    calificacion: 0.2
                }
            };
            actualizarKPIsEnVista(datosPrueba);
        }
    } catch (error) {
        console.error('Error al cargar KPIs:', error);
        cargarKPIsSimulados();
    }
}

/**
 * Cargar top contenidos más alquilados
 */
async function cargarTopContenidos() {
    try {
        const params = new URLSearchParams({
            ...filtrosActuales,
            limite: 5
        });

        const response = await fetch(`/cinearchive/reportes/api/analytics/contenidos-populares?${params}`);

        if (response.ok) {
            const contenidos = await response.json();
            renderizarTopContenidos(contenidos);
        } else {
            renderizarTopContenidosSimulados();
        }
    } catch (error) {
        console.error('Error al cargar top contenidos:', error);
        renderizarTopContenidosSimulados();
    }
}

/**
 * Cargar géneros más populares
 */
async function cargarTopGeneros() {
    try {
        const params = new URLSearchParams({
            ...filtrosActuales,
            limite: 5
        });

        const response = await fetch(`/cinearchive/reportes/api/analytics/categorias-populares?${params}`);

        if (response.ok) {
            const generos = await response.json();
            renderizarTopGeneros(generos);
        } else {
            renderizarTopGenerosSimulados();
        }
    } catch (error) {
        console.error('Error al cargar top géneros:', error);
        renderizarTopGenerosSimulados();
    }
}

/**
 * Cargar métricas rápidas
 */
async function cargarMetricasRapidas() {
    try {
        const metrics = {
            tasaConversion: '68%',
            duracionPromedio: '7.2 días',
            retencion: '84%'
        };

        document.getElementById('tasa-conversion').textContent = metrics.tasaConversion;
        document.getElementById('duracion-promedio').textContent = metrics.duracionPromedio;
        document.getElementById('retencion').textContent = metrics.retencion;
    } catch (error) {
        console.error('Error al cargar métricas rápidas:', error);
    }
}

/**
 * Cargar métricas temporales
 */
async function cargarMetricasTemporales() {
    try {
        const metricas = {
            horaPico: '21:00 - 23:00',
            diaActivo: 'Viernes',
            temporadaAlta: 'Diciembre - Febrero',
            duracionAlquiler: '6.8 días'
        };

        document.getElementById('hora-pico').textContent = metricas.horaPico;
        document.getElementById('dia-activo').textContent = metricas.diaActivo;
        document.getElementById('temporada-alta').textContent = metricas.temporadaAlta;
        document.getElementById('duracion-alquiler').textContent = metricas.duracionAlquiler;
    } catch (error) {
        console.error('Error al cargar métricas temporales:', error);
    }
}

/**
 * Cargar métricas de negocio
 */
async function cargarMetricasNegocio() {
    try {
        const metricas = {
            valorUsuario: '$2,840',
            tasaRetorno: '73%',
            satisfaccion: '4.2/5',
            crecimiento: '+15.3%'
        };

        document.getElementById('valor-usuario').textContent = metricas.valorUsuario;
        document.getElementById('tasa-retorno').textContent = metricas.tasaRetorno;
        document.getElementById('satisfaccion').textContent = metricas.satisfaccion;
        document.getElementById('crecimiento').textContent = metricas.crecimiento;
    } catch (error) {
        console.error('Error al cargar métricas de negocio:', error);
    }
}

// =====================================
// RENDERIZADO DE DATOS
// =====================================

/**
 * Actualizar KPIs en la vista
 */
function actualizarKPIsEnVista(data) {
    // Actualizar números principales
    document.getElementById('kpi-visualizaciones').textContent = formatNumber(data.totalVisualizaciones || 0);
    document.getElementById('kpi-ingresos').textContent = formatCurrency(data.ingresosTotales || 0);
    document.getElementById('kpi-usuarios-activos').textContent = formatNumber(data.usuariosActivos || 0);
    document.getElementById('kpi-calificacion-promedio').textContent = (data.calificacionPromedio || 0).toFixed(1);

    // Actualizar tendencias si están disponibles
    if (data.tendencias) {
        actualizarTendencias(data.tendencias);
    }
}

/**
 * Actualizar indicadores de tendencia
 */
function actualizarTendencias(tendencias) {
    actualizarTendenciaElemento('trend-visualizaciones', tendencias.visualizaciones, 'visualizaciones');
    actualizarTendenciaElemento('trend-ingresos', tendencias.ingresos, 'ingresos');
    actualizarTendenciaElemento('trend-usuarios', tendencias.usuarios, 'usuarios');
    actualizarTendenciaElemento('trend-calificacion', tendencias.calificacion, 'calificación', true);
}

/**
 * Actualizar elemento individual de tendencia
 */
function actualizarTendenciaElemento(elementId, valor, tipo, esDecimal = false) {
    const elemento = document.getElementById(elementId);
    if (!elemento) return;

    let icono, clase, signo = '';

    if (valor > 0) {
        icono = 'fa-arrow-up';
        clase = 'up';
        signo = '+';
    } else if (valor < 0) {
        icono = 'fa-arrow-down';
        clase = 'down';
    } else {
        icono = 'fa-minus';
        clase = 'neutral';
    }

    const valorFormateado = esDecimal ? valor.toFixed(1) : Math.abs(valor);
    elemento.className = `trend ${clase}`;
    elemento.innerHTML = `<i class="fas ${icono}"></i> ${signo}${valorFormateado}${esDecimal ? '' : '%'} vs período anterior`;
}

/**
 * Renderizar top contenidos
 */
function renderizarTopContenidos(contenidos) {
    const lista = document.getElementById('top-contenidos');

    if (!contenidos || contenidos.length === 0) {
        lista.innerHTML = '<li style="text-align: center; color: #666;">No hay datos disponibles</li>';
        return;
    }

    lista.innerHTML = contenidos.map(contenido => `
        <li>
            <div>
                <div class="content-title">${contenido.titulo}</div>
                <small style="color: #666;">${contenido.tipo}</small>
            </div>
            <div class="content-metric">${contenido.totalAlquileres} alquileres</div>
        </li>
    `).join('');
}

/**
 * Renderizar top géneros
 */
function renderizarTopGeneros(generos) {
    const lista = document.getElementById('top-generos');

    if (!generos || generos.length === 0) {
        lista.innerHTML = '<li style="text-align: center; color: #666;">No hay datos disponibles</li>';
        return;
    }

    lista.innerHTML = generos.map(genero => `
        <li>
            <div>
                <div class="content-title">${genero.nombre}</div>
                <small style="color: #666;">Género</small>
            </div>
            <div class="content-metric">${genero.popularidad}%</div>
        </li>
    `).join('');
}

// =====================================
// GENERACIÓN DE REPORTES - SECCIÓN ELIMINADA
// =====================================


// =====================================
// GESTIÓN DE FILTROS
// =====================================

/**
 * Actualizar filtros actuales
 */
function actualizarFiltrosActuales() {
    const periodo = document.getElementById('periodo-filter').value;
    const fechaInicio = document.getElementById('fecha-inicio').value;
    const fechaFin = document.getElementById('fecha-fin').value;
    const tipoContenido = document.getElementById('tipo-contenido-filter').value;

    filtrosActuales = {};

    if (periodo === 'custom') {
        if (fechaInicio) filtrosActuales.fechaInicio = fechaInicio;
        if (fechaFin) filtrosActuales.fechaFin = fechaFin;
    } else {
        filtrosActuales.periodo = periodo;
    }

    if (tipoContenido) {
        filtrosActuales.tipoContenido = tipoContenido;
    }
}

/**
 * Actualizar analytics con filtros actuales
 */
function actualizarAnalytics() {
    actualizarFiltrosActuales();
    cargarDashboardCompleto();
}

/**
 * Resetear filtros a valores por defecto
 */
function resetearFiltros() {
    document.getElementById('periodo-filter').value = '30';
    document.getElementById('tipo-contenido-filter').value = '';

    // Resetear fechas
    inicializarFechas();

    // Limpiar filtros actuales y recargar
    filtrosActuales = {};
    cargarDashboardCompleto();
}

// =====================================
// FUNCIONES DE DATOS SIMULADOS
// =====================================

/**
 * Cargar KPIs simulados cuando no hay conexión
 */
function cargarKPIsSimulados() {
    const datosSimulados = {
        totalVisualizaciones: 12350,
        ingresosTotales: 185420.75,
        usuariosActivos: 1523,
        calificacionPromedio: 4.1,
        tendencias: {
            visualizaciones: 8,
            ingresos: -3,
            usuarios: 15,
            calificacion: 0.1
        }
    };

    actualizarKPIsEnVista(datosSimulados);
}

/**
 * Renderizar top contenidos simulados
 */
function renderizarTopContenidosSimulados() {
    const contenidosSimulados = [
        { titulo: 'Avengers: Endgame', tipo: 'PELICULA', totalAlquileres: 245 },
        { titulo: 'Stranger Things T4', tipo: 'SERIE', totalAlquileres: 198 },
        { titulo: 'The Batman', tipo: 'PELICULA', totalAlquileres: 176 },
        { titulo: 'Breaking Bad', tipo: 'SERIE', totalAlquileres: 154 },
        { titulo: 'Top Gun: Maverick', tipo: 'PELICULA', totalAlquileres: 132 }
    ];

    renderizarTopContenidos(contenidosSimulados);
}

/**
 * Renderizar top géneros simulados
 */
function renderizarTopGenerosSimulados() {
    const generosSimulados = [
        { nombre: 'Acción', popularidad: 34 },
        { nombre: 'Drama', popularidad: 28 },
        { nombre: 'Comedia', popularidad: 22 },
        { nombre: 'Ciencia Ficción', popularidad: 18 },
        { nombre: 'Terror', popularidad: 15 }
    ];

    renderizarTopGeneros(generosSimulados);
}

// Función generarReporteSimulado eliminada

// =====================================
// FUNCIONES DE UTILIDAD
// =====================================

/**
 * Mostrar estado de carga del dashboard
 */
function mostrarCargandoDashboard() {
    const kpiElements = ['kpi-visualizaciones', 'kpi-ingresos', 'kpi-usuarios-activos', 'kpi-calificacion-promedio'];
    kpiElements.forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
        }
    });
}

/**
 * Ocultar estado de carga del dashboard
 */
function ocultarCargandoDashboard() {
    // La carga se oculta automáticamente cuando se actualizan los datos
}

/**
 * Mostrar error del dashboard
 */
function mostrarErrorDashboard(mensaje) {
    mostrarNotificacion('error', mensaje);
    // Cargar datos simulados como fallback
    cargarKPIsSimulados();
    renderizarTopContenidosSimulados();
    renderizarTopGenerosSimulados();
}

/**
 * Formatear números
 */
function formatNumber(num) {
    return new Intl.NumberFormat('es-AR').format(num);
}

/**
 * Formatear moneda
 */
function formatCurrency(amount) {
    return new Intl.NumberFormat('es-AR', {
        style: 'currency',
        currency: 'ARS'
    }).format(amount);
}

/**
 * Formatear fecha
 */
function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('es-AR');
}

// =====================================
// SISTEMA DE NOTIFICACIONES
// =====================================

/**
 * Mostrar notificación
 */
function mostrarNotificacion(tipo, mensaje) {
    // Sistema de notificaciones simple (se puede mejorar con librerías)
    const iconos = {
        success: '✅',
        error: '❌',
        info: 'ℹ️',
        warning: '⚠️'
    };

    const icono = iconos[tipo] || 'ℹ️';

    // Por ahora usar alert, en producción usar un sistema más sofisticado
    console.log(`${icono} ${mensaje}`);

    // Se podría implementar un sistema de toast notifications aquí
    if (tipo === 'error') {
        alert(`${icono} ${mensaje}`);
    }
}

// =====================================
// EXPORTACIÓN DE FUNCIONES GLOBALES
// =====================================

// Hacer funciones disponibles globalmente para uso en HTML
window.cargarDashboardCompleto = cargarDashboardCompleto;
window.actualizarAnalytics = actualizarAnalytics;
window.resetearFiltros = resetearFiltros;

// =====================================
// INICIALIZACIÓN AUTOMÁTICA
// =====================================

// Se ejecutará cuando se cargue el DOM (ya está en el HTML)
document.addEventListener('DOMContentLoaded', function() {
    console.log('Sistema de reportes inicializado');
});
