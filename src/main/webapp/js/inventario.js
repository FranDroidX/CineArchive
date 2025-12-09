/**
 * Cargar géneros en filtro
 */
function cargarGenerosEnFiltro() {
    const generos = [...new Set(contenidosData.map(c => c.genero).filter(g => g))];
    const select = document.getElementById('filter-genero');

    select.innerHTML = '<option value="">Todos los géneros</option>' +
        generos.map(genero => `<option value="${genero}">${genero}</option>`).join('');
}

/**
 * Cargar estadísticas detalladas
 */
async function cargarEstadisticasDetalladas() {
    // Esta función se llamaría cuando se abre la pestaña de estadísticas
    showInfo('Cargando estadísticas detalladas...');
}

// =====================================
// FUNCIONES DE UTILIDAD
// =====================================

function showLoading(elementId) {
    document.getElementById(elementId).innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
}

function showTableLoading(elementId) {
    document.getElementById(elementId).innerHTML =
        '<tr><td colspan="8" style="text-align: center; padding: 40px;"><i class="fas fa-spinner fa-spin"></i> Cargando...</td></tr>';
}

function setDefaultValues() {
    document.getElementById('total-contenidos').textContent = '0';
    document.getElementById('contenidos-disponibles').textContent = '0';
    document.getElementById('total-categorias').textContent = '0';
    document.getElementById('total-resenas').textContent = '0';
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('es-AR', {
        style: 'currency',
        currency: 'ARS'
    }).format(amount);
}

function formatDate(dateString) {
    return new Date(dateString).toLocaleDateString('es-AR');
}

function generateStars(rating) {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 !== 0;
    let starsHtml = '';

    for (let i = 0; i < fullStars; i++) {
        starsHtml += '<i class="fas fa-star" style="color: #ffc107;"></i>';
    }

    if (hasHalfStar) {
        starsHtml += '<i class="fas fa-star-half-alt" style="color: #ffc107;"></i>';
    }

    const remainingStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    for (let i = 0; i < remainingStars; i++) {
        starsHtml += '<i class="far fa-star" style="color: #ffc107;"></i>';
    }

    return starsHtml;
}

function getBadgeColorByType(tipo) {
    switch (tipo) {
        case 'GENERO': return 'primary';
        case 'TAG': return 'success';
        case 'CLASIFICACION': return 'warning';
        default: return 'secondary';
    }
}

// =====================================
// FUNCIONES DE NOTIFICACIÓN
// =====================================

function showSuccess(message) {
    // Implementar sistema de notificaciones
    alert('✅ ' + message);
}

function showError(message) {
    alert('❌ ' + message);
}

function showInfo(message) {
    alert('ℹ️ ' + message);
}

// =====================================
// EVENT LISTENERS
// =====================================

// Cerrar modales al hacer clic fuera
window.onclick = function(event) {
    if (event.target.classList.contains('modal')) {
        event.target.style.display = 'none';
    }
};

// Funciones adicionales que se pueden implementar
function gestionarCategorias(contenidoId) {
    showInfo(`Gestionar categorías para contenido ID: ${contenidoId} (Funcionalidad pendiente)`);
}

function verResenaCompleta(resenaId) {
    showInfo(`Ver reseña completa ID: ${resenaId} (Funcionalidad pendiente)`);
}

function eliminarResena(resenaId) {
    if (confirm('¿Estás seguro de que deseas eliminar esta reseña?')) {
        showInfo(`Eliminar reseña ID: ${resenaId} (Funcionalidad pendiente)`);
    }
}
/**
 * CineArchive - Gestión de Inventario
 * JavaScript para el módulo de gestión de inventario del Developer 3
 * Funcionalidades: CRUD de contenidos, categorías, reseñas y estadísticas
 */

// =====================================
// VARIABLES GLOBALES
// =====================================
let contenidosData = [];
let categoriasData = [];
let resenasData = [];
let estadisticasData = {};

// =====================================
// INICIALIZACIÓN Y CARGA DE DATOS
// =====================================

/**
 * Cargar estadísticas del dashboard principal
 */
async function cargarEstadisticasDashboard() {
    try {
        showLoading('total-contenidos');
        showLoading('contenidos-disponibles');
        showLoading('total-categorias');
        showLoading('total-resenas');

        // Cargar estadísticas generales
        const response = await fetch('/cinearchive/inventario/api/estadisticas', {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const stats = await response.json();
            estadisticasData = stats;

            // Actualizar elementos del dashboard
            document.getElementById('total-contenidos').textContent = stats.totalContenidos || 0;
            document.getElementById('contenidos-disponibles').textContent = stats.contenidosDisponibles || 0;
            document.getElementById('total-categorias').textContent = stats.totalCategorias || 0;
            document.getElementById('total-resenas').textContent = stats.totalResenas || 0;

            // Estadísticas detalladas
            document.getElementById('stat-peliculas').textContent = stats.totalPeliculas || 0;
            document.getElementById('stat-series').textContent = stats.totalSeries || 0;
            document.getElementById('stat-visualizaciones').textContent = stats.totalAlquileres || 0;
            document.getElementById('stat-ingresos').textContent = formatCurrency(stats.ingresosTotales || 0);
        } else {
            console.warn('No se pudieron cargar las estadísticas');
            // Mostrar datos por defecto
            setDefaultValues();
        }
    } catch (error) {
        console.error('Error al cargar estadísticas:', error);
        setDefaultValues();
    }
}

/**
 * Cargar todos los contenidos
 */
async function cargarContenidos() {
    try {
        showTableLoading('contenidos-tbody');

        const response = await fetch('/cinearchive/inventario/api/contenidos');

        if (response.ok) {
            contenidosData = await response.json();
            renderizarContenidos(contenidosData);
            cargarGenerosEnFiltro();
        } else {
            showError('No se pudieron cargar los contenidos');
        }
    } catch (error) {
        console.error('Error al cargar contenidos:', error);
        showError('Error de conexión al cargar contenidos');
    }
}

/**
 * Cargar todas las categorías
 */
async function cargarCategorias() {
    try {
        const response = await fetch('/cinearchive/api/categorias');

        if (response.ok) {
            categoriasData = await response.json();
            renderizarCategorias(categoriasData);
        } else {
            showError('No se pudieron cargar las categorías');
        }
    } catch (error) {
        console.error('Error al cargar categorías:', error);
        showError('Error de conexión al cargar categorías');
    }
}

/**
 * Cargar todas las reseñas
 */
async function cargarResenas() {
    try {
        showTableLoading('resenas-tbody');

        // Simulación de datos hasta que el endpoint esté disponible
        const resenasSimuladas = [
            {
                id: 1,
                usuario: { nombre: 'Juan Pérez' },
                contenido: { titulo: 'Inception' },
                calificacion: 4.5,
                titulo: 'Excelente película',
                fechaCreacion: '2024-01-15'
            },
            {
                id: 2,
                usuario: { nombre: 'María García' },
                contenido: { titulo: 'El Padrino' },
                calificacion: 5.0,
                titulo: 'Una obra maestra',
                fechaCreacion: '2024-01-20'
            }
        ];

        resenasData = resenasSimuladas;
        renderizarResenas(resenasData);
    } catch (error) {
        console.error('Error al cargar reseñas:', error);
        showError('Error de conexión al cargar reseñas');
    }
}

// =====================================
// RENDERIZADO DE DATOS
// =====================================

/**
 * Renderizar tabla de contenidos
 */
function renderizarContenidos(contenidos) {
    const tbody = document.getElementById('contenidos-tbody');

    if (!contenidos || contenidos.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 40px; color: #666;">No hay contenidos disponibles</td></tr>';
        return;
    }

    tbody.innerHTML = contenidos.map(contenido => `
        <tr>
            <td>${contenido.id}</td>
            <td>
                <strong>${contenido.titulo}</strong>
                ${contenido.descripcion ? `<br><small style="color: #666;">${contenido.descripcion.substring(0, 50)}...</small>` : ''}
            </td>
            <td>
                <span class="badge badge-${contenido.tipo === 'PELICULA' ? 'primary' : 'info'}">
                    ${contenido.tipo}
                </span>
            </td>
            <td>${contenido.genero || '-'}</td>
            <td>${contenido.anio || '-'}</td>
            <td>
                <span class="badge badge-${contenido.disponibleParaAlquiler ? 'success' : 'secondary'}">
                    ${contenido.disponibleParaAlquiler ? 'Disponible' : 'No disponible'}
                </span>
            </td>
            <td>${formatCurrency(contenido.precioAlquiler || 0)}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-sm btn-info" onclick="editarContenido(${contenido.id})" title="Editar">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-sm btn-success" onclick="gestionarCategorias(${contenido.id})" title="Categorías">
                        <i class="fas fa-tags"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="eliminarContenido(${contenido.id})" title="Eliminar">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

/**
 * Renderizar grid de categorías
 */
function renderizarCategorias(categorias) {
    const grid = document.getElementById('categories-grid');

    if (!categorias || categorias.length === 0) {
        grid.innerHTML = '<p style="text-align: center; padding: 40px; color: #666;">No hay categorías disponibles</p>';
        return;
    }

    grid.innerHTML = categorias.map(categoria => `
        <div class="category-card" data-tipo="${categoria.tipo}">
            <h4>${categoria.nombre}</h4>
            <p class="category-type">
                <span class="badge badge-${getBadgeColorByType(categoria.tipo)}">${categoria.tipo}</span>
            </p>
            ${categoria.descripcion ? `<p class="category-description">${categoria.descripcion}</p>` : ''}
            <div class="category-actions" style="margin-top: 15px;">
                <button class="btn btn-sm btn-info" onclick="editarCategoria(${categoria.id})" title="Editar">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-danger" onclick="eliminarCategoria(${categoria.id})" title="Eliminar">
                    <i class="fas fa-trash"></i>
                </button>
            </div>
        </div>
    `).join('');
}

/**
 * Renderizar tabla de reseñas
 */
function renderizarResenas(resenas) {
    const tbody = document.getElementById('resenas-tbody');

    if (!resenas || resenas.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; padding: 40px; color: #666;">No hay reseñas disponibles</td></tr>';
        return;
    }

    tbody.innerHTML = resenas.map(resena => `
        <tr>
            <td>${resena.id}</td>
            <td>${resena.usuario?.nombre || 'Usuario desconocido'}</td>
            <td>${resena.contenido?.titulo || 'Contenido desconocido'}</td>
            <td>
                <div class="rating">
                    ${generateStars(resena.calificacion)}
                    <span class="rating-number">${resena.calificacion}</span>
                </div>
            </td>
            <td>
                <strong>${resena.titulo}</strong>
                ${resena.texto ? `<br><small style="color: #666;">${resena.texto.substring(0, 50)}...</small>` : ''}
            </td>
            <td>${formatDate(resena.fechaCreacion)}</td>
            <td>
                <div class="action-buttons">
                    <button class="btn btn-sm btn-info" onclick="verResenaCompleta(${resena.id})" title="Ver completa">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="eliminarResena(${resena.id})" title="Eliminar">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

// =====================================
// FUNCIONES DE GESTIÓN DE PESTAÑAS
// =====================================

/**
 * Mostrar pestaña específica
 */
function showTab(tabName) {
    // Ocultar todas las pestañas
    const tabs = document.querySelectorAll('.tab-content');
    tabs.forEach(tab => tab.classList.remove('active'));

    // Remover clase active de todos los botones
    const buttons = document.querySelectorAll('.tab-button');
    buttons.forEach(btn => btn.classList.remove('active'));

    // Mostrar pestaña seleccionada
    document.getElementById(`${tabName}-tab`).classList.add('active');
    event.target.classList.add('active');

    // Cargar datos específicos si es necesario
    if (tabName === 'estadisticas') {
        cargarEstadisticasDetalladas();
    }
}

// =====================================
// FUNCIONES DE FILTRADO Y BÚSQUEDA
// =====================================

/**
 * Filtrar contenidos basado en criterios de búsqueda
 * NOTA: Esta función está duplicada más abajo con los IDs correctos del nuevo JSP
 * Esta versión se mantiene por compatibilidad con otras vistas
 */
function filtrarContenidosOLD() {
    const searchTerm = document.getElementById('search-contenidos')?.value.toLowerCase() || '';
    const tipoFilter = document.getElementById('filter-tipo')?.value || '';
    const generoFilter = document.getElementById('filter-genero')?.value || '';
    const disponibilidadFilter = document.getElementById('filter-disponibilidad')?.value || '';

    let contenidosFiltrados = contenidosData.filter(contenido => {
        const matchSearch = contenido.titulo.toLowerCase().includes(searchTerm) ||
                           (contenido.descripcion && contenido.descripcion.toLowerCase().includes(searchTerm));

        const matchTipo = !tipoFilter || contenido.tipo === tipoFilter;
        const matchGenero = !generoFilter || contenido.genero === generoFilter;
        const matchDisponibilidad = disponibilidadFilter === '' ||
                                   contenido.disponibleParaAlquiler.toString() === disponibilidadFilter;

        return matchSearch && matchTipo && matchGenero && matchDisponibilidad;
    });

    renderizarContenidos(contenidosFiltrados);
}

/**
 * Filtrar categorías por tipo
 */
function filtrarCategoriasPorTipo(tipo) {
    // Actualizar botones activos
    document.querySelectorAll('.category-type-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');

    // Filtrar categorías
    let categoriasFiltradas = categoriasData;
    if (tipo !== 'TODOS') {
        categoriasFiltradas = categoriasData.filter(cat => cat.tipo === tipo);
    }

    renderizarCategorias(categoriasFiltradas);
}

/**
 * Filtrar reseñas
 */
function filtrarResenas() {
    const searchTerm = document.getElementById('search-resenas').value.toLowerCase();
    const calificacionFilter = document.getElementById('filter-calificacion').value;

    let resenasFiltradas = resenasData.filter(resena => {
        const matchSearch = resena.contenido?.titulo.toLowerCase().includes(searchTerm) ||
                           resena.titulo.toLowerCase().includes(searchTerm);

        const matchCalificacion = !calificacionFilter || resena.calificacion >= parseFloat(calificacionFilter);

        return matchSearch && matchCalificacion;
    });

    renderizarResenas(resenasFiltradas);
}

// =====================================
// FUNCIONES DE MODALES
// =====================================

/**
 * Abrir modal
 */
function openModal(modalId) {
    document.getElementById(modalId).style.display = 'block';
}

/**
 * Cerrar modal
 */
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';

    // Limpiar formularios
    const form = document.querySelector(`#${modalId} form`);
    if (form) {
        form.reset();
    }
}

// =====================================
// FUNCIONES CRUD - CONTENIDOS
// =====================================

/**
 * Agregar nuevo contenido
 */
async function agregarContenido(event) {
    event.preventDefault();

    const formData = new FormData(event.target);
    const contenidoData = {
        titulo: formData.get('titulo'),
        tipo: formData.get('tipo'),
        genero: formData.get('genero'),
        anio: parseInt(formData.get('anio')),
        descripcion: formData.get('descripcion'),
        precioAlquiler: parseFloat(formData.get('precioAlquiler')),
        copiasTotales: parseInt(formData.get('copiasTotales')),
        copiasDisponibles: parseInt(formData.get('copiasTotales')), // Inicialmente iguales
        disponibleParaAlquiler: true
    };

    try {
        const response = await fetch('/cinearchive/inventario/api/contenidos', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(contenidoData)
        });

        if (response.ok) {
            showSuccess('Contenido agregado exitosamente');
            closeModal('add-content-modal');
            cargarContenidos();
            cargarEstadisticasDashboard();
        } else {
            showError('Error al agregar el contenido');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión al agregar contenido');
    }
}

/**
 * Editar contenido
 */
async function editarContenido(id) {
    // Implementar modal de edición
    const contenido = contenidosData.find(c => c.id === id);
    if (!contenido) return;

    // Aquí se abriría un modal de edición prellenado
    showInfo(`Editando contenido: ${contenido.titulo} (Funcionalidad pendiente de implementar)`);
}

/**
 * Eliminar contenido
 */
async function eliminarContenido(id) {
    if (!confirm('¿Estás seguro de que deseas eliminar este contenido?')) {
        return;
    }

    try {
        const response = await fetch(`/cinearchive/inventario/api/contenidos/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            showSuccess('Contenido eliminado exitosamente');
            cargarContenidos();
            cargarEstadisticasDashboard();
        } else {
            showError('Error al eliminar el contenido');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión al eliminar contenido');
    }
}

// =====================================
// FUNCIONES CRUD - CATEGORÍAS
// =====================================

/**
 * Agregar nueva categoría
 */
async function agregarCategoria(event) {
    event.preventDefault();

    const formData = new FormData(event.target);
    const categoriaData = {
        nombre: formData.get('nombre'),
        tipo: formData.get('tipo'),
        descripcion: formData.get('descripcion')
    };

    try {
        const response = await fetch('/cinearchive/inventario/api/categorias', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(categoriaData)
        });

        if (response.ok) {
            showSuccess('Categoría creada exitosamente');
            closeModal('add-category-modal');
            cargarCategorias();
            cargarEstadisticasDashboard();
        } else {
            showError('Error al crear la categoría');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión al crear categoría');
    }
}

/**
 * Editar categoría
 */
async function editarCategoria(id) {
    const categoria = categoriasData.find(c => c.id === id);
    if (!categoria) return;

    showInfo(`Editando categoría: ${categoria.nombre} (Funcionalidad pendiente de implementar)`);
}

/**
 * Eliminar categoría
 */
async function eliminarCategoria(id) {
    if (!confirm('¿Estás seguro de que deseas eliminar esta categoría?')) {
        return;
    }

    try {
        const response = await fetch(`/cinearchive/inventario/api/categorias/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            showSuccess('Categoría eliminada exitosamente');
            cargarCategorias();
            cargarEstadisticasDashboard();
        } else {
            showError('Error al eliminar la categoría');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión al eliminar categoría');
    }
}

// =====================================
// FUNCIONES AUXILIARES
// =====================================

/**
 * Exportar contenidos a CSV
 */
async function exportarContenidos() {
    try {
        const response = await fetch('/cinearchive/inventario/api/contenidos/export');
        const blob = await response.blob();

        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'contenidos_cinearchive.csv';
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);

        showSuccess('Contenidos exportados exitosamente');
    } catch (error) {
        console.error('Error al exportar:', error);
        showError('Error al exportar contenidos');
    }
}

/**
 * Sincronizar con APIs externas
 */
async function sincronizarAPIs() {
    try {
        showInfo('Iniciando sincronización con APIs externas...');

        const response = await fetch('/cinearchive/api-integracion/api/sincronizar', {
            method: 'POST'
        });

        if (response.ok) {
            showSuccess('Sincronización completada exitosamente');
            cargarContenidos();
        } else {
            showError('Error durante la sincronización');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión durante la sincronización');
    }
}

// =====================================
// FUNCIONES PARA EL NUEVO JSP GESTOR-INVENTARIO
// =====================================

/**
 * Agregar nuevo contenido (formulario manual)
 */
async function agregarContenido(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);

    // Obtener duración en minutos (ahora es un campo numérico)
    const duracionMinutos = parseInt(formData.get('duracion')) || null;

    const contenido = {
        titulo: formData.get('titulo'),
        tipo: formData.get('tipo'),
        anio: parseInt(formData.get('anio')) || null,
        duracion: duracionMinutos, // Enviar como Integer (minutos)
        director: formData.get('director') || null,
        genero: formData.get('genero') || null,
        descripcion: formData.get('sinopsis') || null, // Backend usa 'descripcion'
        imagenUrl: formData.get('imagenUrl') || null,
        copiasTotales: parseInt(formData.get('copiasTotales')) || 10,
        copiasDisponibles: parseInt(formData.get('copiasDisponibles')) || 10,
        precioAlquiler: parseFloat(formData.get('precioAlquiler')) || 3.99,
        disponibleParaAlquiler: true
    };

    console.log('📤 Enviando contenido:', contenido);

    try {
        const response = await fetch(APP_CONTEXT + '/inventario/api/contenidos', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(contenido)
        });

        console.log('📨 Respuesta del servidor:', response.status, response.statusText);

        if (response.ok) {
            const resultado = await response.json();
            console.log('✅ Contenido creado:', resultado);
            showSuccess('Contenido agregado exitosamente');
            form.reset();
            // Recargar la página para ver el nuevo contenido
            setTimeout(() => {
                window.location.reload();
            }, 1500);
        } else {
            // Intentar leer el mensaje de error del servidor
            let errorMsg = 'Error al agregar el contenido';
            try {
                const errorData = await response.json();
                console.error('❌ Error del servidor:', errorData);
                errorMsg = errorData.message || errorData.error || errorMsg;
            } catch (e) {
                const errorText = await response.text();
                console.error('❌ Error del servidor (texto):', errorText);
            }
            showError(errorMsg + ' (Status: ' + response.status + ')');
        }
    } catch (error) {
        console.error('❌ Error de conexión:', error);
        showError('Error de conexión al agregar contenido: ' + error.message);
    }
}

/**
 * Importar contenido desde API externa
 */
async function importarDesdeAPI(event) {
    event.preventDefault();

    const form = event.target;
    const apiSource = form.querySelector('[name="apiSource"]').value;
    const searchQuery = form.querySelector('[name="searchQuery"]').value;

    showInfo('Buscando en ' + apiSource + '...');

    try {
        // Aquí se haría la llamada real a la API externa
        // Por ahora solo mostramos un mensaje
        showInfo('Funcionalidad de importación desde API en desarrollo');
    } catch (error) {
        console.error('Error:', error);
        showError('Error al buscar en API externa');
    }
}

/**
 * Importación masiva desde archivo
 */
async function importarMasivo(event) {
    event.preventDefault();

    const form = event.target;
    const archivo = form.querySelector('[name="archivo"]').files[0];

    if (!archivo) {
        showError('Por favor selecciona un archivo');
        return;
    }

    showInfo('Procesando archivo ' + archivo.name + '...');

    // Aquí se procesaría el archivo CSV o JSON
    // Por ahora solo mostramos un mensaje
    showInfo('Funcionalidad de importación masiva en desarrollo');
}

/**
 * Filtrar contenidos en la tabla (VERSIÓN CORRECTA PARA NUEVO JSP)
 */
function filtrarContenidos() {
    // Obtener valores de los filtros
    const searchInput = document.getElementById('search-catalogo');
    const filterTipoSelect = document.getElementById('filter-tipo');
    const filterGeneroSelect = document.getElementById('filter-genero');
    const filterEstadoSelect = document.getElementById('filter-estado');

    // Verificar que existen los elementos
    if (!searchInput || !filterTipoSelect || !filterGeneroSelect || !filterEstadoSelect) {
        console.error('No se encontraron los elementos de filtro');
        return;
    }

    const searchText = searchInput.value.toLowerCase().trim();
    const filterTipo = filterTipoSelect.value;
    const filterGenero = filterGeneroSelect.value;
    const filterEstado = filterEstadoSelect.value;

    const rows = document.querySelectorAll('#tabla-contenidos tr');
    let contadorVisibles = 0;

    rows.forEach(row => {
        // Solo procesar filas con datos (no headers ni mensajes vacíos)
        if (row.querySelector('td') && row.cells.length >= 9) {
            const titulo = row.cells[2]?.textContent.toLowerCase().trim() || '';
            const tipoBadge = row.querySelector('.badge')?.textContent.trim() || '';
            const genero = row.cells[5]?.textContent.trim() || '';
            const estadoBadge = row.querySelector('.status-badge')?.textContent.trim() || '';

            let mostrar = true;

            // Filtro de búsqueda por título
            if (searchText && !titulo.includes(searchText)) {
                mostrar = false;
            }

            // Filtro de tipo (PELICULA/SERIE)
            if (filterTipo) {
                // Normalizar comparación
                const tipoNormalizado = filterTipo === 'PELICULA' ? 'película' : 'serie';
                if (!tipoBadge.toLowerCase().includes(tipoNormalizado)) {
                    mostrar = false;
                }
            }

            // Filtro de género
            if (filterGenero && genero !== filterGenero) {
                mostrar = false;
            }

            // Filtro de estado
            if (filterEstado) {
                if (filterEstado === 'disponible' && !estadoBadge.toLowerCase().includes('disponible')) {
                    mostrar = false;
                }
                if (filterEstado === 'no-disponible' && !estadoBadge.toLowerCase().includes('no disponible')) {
                    mostrar = false;
                }
                if (filterEstado === 'stock-bajo' && !estadoBadge.toLowerCase().includes('stock bajo')) {
                    mostrar = false;
                }
            }

            // Aplicar visibilidad
            if (mostrar) {
                row.style.display = '';
                contadorVisibles++;
            } else {
                row.style.display = 'none';
            }
        }
    });

    // Mostrar mensaje si no hay resultados
    console.log(`Filtrado completo: ${contadorVisibles} filas visibles`);
}

/**
 * Editar contenido existente - IMPLEMENTACIÓN COMPLETA
 */
async function editarContenido(id) {
    console.log('📝 Abriendo editor para contenido ID:', id);

    try {
        // Obtener datos del contenido desde el servidor
        const response = await fetch(APP_CONTEXT + '/inventario/api/contenidos/' + id);

        if (!response.ok) {
            showError('No se pudo cargar el contenido');
            return;
        }

        const contenido = await response.json();
        console.log('✅ Contenido cargado:', contenido);

        // Llenar el formulario con los datos actuales
        document.getElementById('edit-id').value = contenido.id || '';
        document.getElementById('edit-titulo').value = contenido.titulo || '';
        document.getElementById('edit-tipo').value = contenido.tipo || 'PELICULA';
        document.getElementById('edit-anio').value = contenido.anio || '';
        document.getElementById('edit-duracion').value = contenido.duracion || '';
        document.getElementById('edit-director').value = contenido.director || '';
        document.getElementById('edit-genero').value = contenido.genero || '';
        document.getElementById('edit-sinopsis').value = contenido.descripcion || '';
        document.getElementById('edit-imagenUrl').value = contenido.imagenUrl || '';
        document.getElementById('edit-copiasTotales').value = contenido.copiasTotales || 0;
        document.getElementById('edit-copiasDisponibles').value = contenido.copiasDisponibles || 0;
        document.getElementById('edit-precioAlquiler').value = contenido.precioAlquiler || 0;
        document.getElementById('edit-disponible').value = contenido.disponibleParaAlquiler ? 'true' : 'false';

        // Mostrar el modal
        document.getElementById('modal-editar-contenido').style.display = 'block';

    } catch (error) {
        console.error('❌ Error al cargar contenido:', error);
        showError('Error de conexión al cargar el contenido');
    }
}

/**
 * Cerrar modal de edición
 */
function cerrarModalEditar() {
    document.getElementById('modal-editar-contenido').style.display = 'none';
    document.getElementById('form-editar-contenido').reset();
}

/**
 * Guardar cambios del contenido editado
 */
async function guardarEdicionContenido(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const id = formData.get('id');

    const contenido = {
        id: parseInt(id),
        titulo: formData.get('titulo'),
        tipo: formData.get('tipo'),
        anio: parseInt(formData.get('anio')) || null,
        duracion: parseInt(formData.get('duracion')) || null,
        director: formData.get('director') || null,
        genero: formData.get('genero') || null,
        descripcion: formData.get('sinopsis') || null,
        imagenUrl: formData.get('imagenUrl') || null,
        copiasTotales: parseInt(formData.get('copiasTotales')) || 0,
        copiasDisponibles: parseInt(formData.get('copiasDisponibles')) || 0,
        precioAlquiler: parseFloat(formData.get('precioAlquiler')) || 0,
        disponibleParaAlquiler: formData.get('disponibleParaAlquiler') === 'true'
    };

    console.log('📤 Actualizando contenido:', contenido);

    try {
        const response = await fetch(APP_CONTEXT + '/inventario/api/contenidos/' + id, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(contenido)
        });

        console.log('📨 Respuesta del servidor:', response.status);

        if (response.ok) {
            const resultado = await response.json();
            console.log('✅ Contenido actualizado:', resultado);
            showSuccess('Contenido actualizado exitosamente');
            cerrarModalEditar();
            // Recargar la página para ver los cambios
            setTimeout(() => {
                window.location.reload();
            }, 1500);
        } else {
            let errorMsg = 'Error al actualizar el contenido';
            try {
                const errorData = await response.json();
                console.error('❌ Error del servidor:', errorData);
                errorMsg = errorData.message || errorData.error || errorMsg;
            } catch (e) {
                const errorText = await response.text();
                console.error('❌ Error del servidor (texto):', errorText);
            }
            showError(errorMsg + ' (Status: ' + response.status + ')');
        }
    } catch (error) {
        console.error('❌ Error de conexión:', error);
        showError('Error de conexión al actualizar contenido: ' + error.message);
    }
}

/**
 * Gestionar copias de un contenido
 */
async function gestionarCopias(id) {
    const nuevasCopias = prompt('¿Cuántas copias totales desea tener?');

    if (nuevasCopias === null) {
        // Usuario canceló
        return;
    }

    const copiasTotales = parseInt(nuevasCopias, 10);

    if (isNaN(copiasTotales) || copiasTotales < 0) {
        showError('Por favor, ingrese un número válido mayor o igual a 0');
        return;
    }

    try {
        const response = await fetch(APP_CONTEXT + '/inventario/api/contenidos/' + id + '/copias', {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({ copiasTotales: copiasTotales })
        });

        const data = await response.json();

        if (response.ok && data.success) {
            showSuccess('Copias actualizadas exitosamente.\n' +
                'Título: ' + data.titulo + '\n' +
                'Copias totales: ' + data.copiasTotales + '\n' +
                'Copias disponibles: ' + data.copiasDisponibles);

            // Recargar la página para mostrar los cambios
            setTimeout(() => {
                window.location.reload();
            }, 1500);
        } else {
            showError(data.message || 'Error al actualizar las copias');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión al actualizar las copias');
    }
}

/**
 * Eliminar contenido
 */
async function eliminarContenido(id) {
    if (!confirm('¿Está seguro de que desea eliminar este contenido?')) {
        return;
    }

    try {
        const response = await fetch(APP_CONTEXT + '/inventario/api/contenidos/' + id, {
            method: 'DELETE'
        });

        if (response.ok) {
            showSuccess('Contenido eliminado exitosamente');
            // Recargar la página
            setTimeout(() => {
                window.location.reload();
            }, 1500);
        } else {
            showError('Error al eliminar el contenido');
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión al eliminar contenido');
    }
}

/**
 * Sincronizar con APIs externas
 */
async function sincronizarAPIs() {
    showInfo('Sincronizando con APIs externas...');

    try {
        // Aquí se llamaría al backend para sincronizar
        showInfo('Funcionalidad de sincronización en desarrollo');
    } catch (error) {
        console.error('Error:', error);
        showError('Error al sincronizar con APIs');
    }
}

/**
 * Exportar catálogo
 */
function exportarCatalogo() {
    const formato = prompt('¿En qué formato desea exportar? (CSV/JSON)', 'CSV');

    if (formato) {
        showInfo('Exportando catálogo en formato ' + formato.toUpperCase() + '...');
        // Aquí se haría la exportación real
    }
}

/**
 * Aumentar stock de un contenido
 */
function aumentarStock(id) {
    const cantidad = prompt('¿Cuántas copias desea agregar?');

    if (cantidad !== null && !isNaN(cantidad)) {
        showInfo('Agregando ' + cantidad + ' copias al contenido ID: ' + id + ' (Funcionalidad en desarrollo)');
    }
}

/**
 * Cargar géneros en el filtro desde el servidor
 */
async function cargarGenerosFiltro() {
    try {
        const response = await fetch(APP_CONTEXT + '/api/categorias/tipo/GENERO');

        if (response.ok) {
            const generos = await response.json();
            const select = document.getElementById('filter-genero');

            if (select && select.options.length <= 1) { // Solo tiene "Todos los géneros"
                generos.forEach(genero => {
                    const option = document.createElement('option');
                    option.value = genero.nombre;
                    option.textContent = genero.nombre;
                    select.appendChild(option);
                });
            }

            // También actualizar el select del formulario
            const selectForm = document.getElementById('select-generos');
            if (selectForm && selectForm.options.length <= 1) {
                generos.forEach(genero => {
                    const option = document.createElement('option');
                    option.value = genero.nombre;
                    option.textContent = genero.nombre;
                    selectForm.appendChild(option);
                });
            }
        }
    } catch (error) {
        console.error('Error al cargar géneros:', error);
    }
}
