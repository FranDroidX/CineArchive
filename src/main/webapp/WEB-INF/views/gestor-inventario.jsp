<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Inventario - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <%-- Incluir header del proyecto --%>
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />

    <div class="container">
        <div class="admin-panel">
            <h1>Gestión de Inventario</h1>

            <%-- Estadísticas de Inventario --%>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">🎬</div>
                    <div class="stat-content">
                        <h3>Total Películas</h3>
                        <p class="stat-number" id="total-peliculas">
                            <c:choose>
                                <c:when test="${not empty estadisticas.totalPeliculas}">
                                    <fmt:formatNumber value="${estadisticas.totalPeliculas}" type="number"/>
                                </c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <span class="stat-change">En catálogo</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">📺</div>
                    <div class="stat-content">
                        <h3>Total Series</h3>
                        <p class="stat-number" id="total-series">
                            <c:choose>
                                <c:when test="${not empty estadisticas.totalSeries}">
                                    <fmt:formatNumber value="${estadisticas.totalSeries}" type="number"/>
                                </c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <span class="stat-change">En catálogo</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-content">
                        <h3>Disponibles</h3>
                        <p class="stat-number" id="total-disponibles">
                            <c:choose>
                                <c:when test="${not empty estadisticas.contenidosDisponibles}">
                                    <fmt:formatNumber value="${estadisticas.contenidosDisponibles}" type="number"/>
                                </c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <c:set var="porcentajeDisponibles" value="${estadisticas.totalContenidos > 0 ? (estadisticas.contenidosDisponibles * 100.0 / estadisticas.totalContenidos) : 0}" />
                        <span class="stat-change positive">
                            <fmt:formatNumber value="${porcentajeDisponibles}" maxFractionDigits="0"/>% del total
                        </span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⚠️</div>
                    <div class="stat-content">
                        <h3>Stock Bajo</h3>
                        <p class="stat-number" id="total-stock-bajo">
                            <c:choose>
                                <c:when test="${not empty contenidosStockBajo}">
                                    ${fn:length(contenidosStockBajo)}
                                </c:when>
                                <c:otherwise>0</c:otherwise>
                            </c:choose>
                        </p>
                        <span class="stat-change warning">Requiere atención</span>
                    </div>
                </div>
            </div>

            <%-- Agregar Nuevo Contenido --%>
            <section class="admin-section">
                <div class="section-header">
                    <h2>➕ Agregar Nuevo Contenido</h2>
                </div>

                <div class="add-content-tabs">
                    <button class="tab-btn active" onclick="showAddTab('manual')">Manual</button>
                    <button class="tab-btn" onclick="showAddTab('api')">Importar desde API</button>
                    <button class="tab-btn" onclick="showAddTab('masivo')">Importación Masiva</button>
                </div>

                <%-- Tab Manual --%>
                <div id="tab-manual" class="add-content-form" style="display: block;">
                    <form id="form-agregar-contenido" onsubmit="agregarContenido(event)">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Título:</label>
                                <input type="text" name="titulo" required placeholder="Nombre de la película o serie">
                            </div>
                            <div class="form-group">
                                <label>Tipo:</label>
                                <select name="tipo" required>
                                    <option value="">Seleccionar</option>
                                    <option value="PELICULA">Película</option>
                                    <option value="SERIE">Serie</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Año:</label>
                                <input type="number" name="anio" min="1900" max="2030" placeholder="2024">
                            </div>
                            <div class="form-group">
                                <label>Duración (minutos):</label>
                                <input type="number" name="duracion" min="1" placeholder="150">
                                <small style="color: #888;">Ejemplo: 150 minutos = 2h 30min</small>
                            </div>
                            <div class="form-group">
                                <label>Director:</label>
                                <input type="text" name="director" placeholder="Nombre del director">
                            </div>
                            <div class="form-group">
                                <label>Géneros:</label>
                                <select name="genero" id="select-generos">
                                    <option value="">Seleccionar género</option>
                                    <c:forEach items="${generos}" var="genero">
                                        <option value="${genero.nombre}">${genero.nombre}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group full-width">
                                <label>Sinopsis:</label>
                                <textarea name="sinopsis" rows="4" placeholder="Descripción de la película o serie..."></textarea>
                            </div>
                            <div class="form-group">
                                <label>URL del Poster:</label>
                                <input type="url" name="imagenUrl" placeholder="https://...">
                            </div>
                            <div class="form-group">
                                <label>Copias Totales:</label>
                                <input type="number" name="copiasTotales" min="1" value="10">
                            </div>
                            <div class="form-group">
                                <label>Copias Disponibles:</label>
                                <input type="number" name="copiasDisponibles" min="0" value="10">
                            </div>
                            <div class="form-group">
                                <label>Precio de Alquiler:</label>
                                <input type="number" name="precioAlquiler" step="0.01" min="0" placeholder="3.99">
                            </div>
                            <div class="form-group">
                                <label>Clasificación:</label>
                                <select name="clasificacion">
                                    <option value="">Seleccionar</option>
                                    <option value="ATP">ATP - Apto para todo público</option>
                                    <option value="+13">+13 - Mayores de 13 años</option>
                                    <option value="+16">+16 - Mayores de 16 años</option>
                                    <option value="+18">+18 - Solo adultos</option>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="btn-primary">💾 Guardar Contenido</button>
                    </form>
                </div>

                <%-- Tab Importar desde API --%>
                <div id="tab-api" class="add-content-form" style="display: none;">
                    <form id="form-importar-api" onsubmit="importarDesdeAPI(event)">
                        <div class="form-grid">
                            <div class="form-group">
                                <label>API Externa:</label>
                                <select name="apiSource">
                                    <option value="tmdb">The Movie Database (TMDb)</option>
                                    <option value="omdb">OMDb API</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>ID o Título:</label>
                                <input type="text" name="searchQuery" placeholder="Buscar por título o ID" required>
                            </div>
                            <div class="form-group full-width">
                                <button type="submit" class="btn-primary">🔍 Buscar</button>
                            </div>
                        </div>
                        <div id="api-results" style="display: none; margin-top: 20px;">
                            <%-- Resultados de búsqueda se cargan aquí --%>
                        </div>
                    </form>
                </div>

                <%-- Tab Importación Masiva --%>
                <div id="tab-masivo" class="add-content-form" style="display: none;">
                    <form id="form-importar-masivo" onsubmit="importarMasivo(event)">
                        <div class="form-group full-width">
                            <label>Archivo CSV o JSON:</label>
                            <input type="file" name="archivo" accept=".csv,.json" required>
                            <small>Formato: titulo, tipo, anio, genero, director, sinopsis, imagenUrl, copias, precio</small>
                        </div>
                        <button type="submit" class="btn-primary">📥 Importar Contenidos</button>
                    </form>
                </div>
            </section>

            <%-- Gestión de Catálogo --%>
            <section class="admin-section">
                <div class="section-header">
                    <h2>📋 Gestión de Catálogo</h2>
                    <div class="header-actions">
                        <button class="btn-secondary" onclick="sincronizarAPIs()">🔄 Sincronizar con API</button>
                        <button class="btn-secondary" onclick="exportarCatalogo()">📥 Exportar Catálogo</button>
                    </div>
                </div>

                <form id="form-filtros" class="search-filter-bar" method="get" action="${pageContext.request.contextPath}/inventario">
                    <input type="text" class="search-input" id="search-catalogo" name="busqueda"
                           placeholder="Buscar contenido..." value="${filtroBusqueda}">
                    <select class="filter-select" id="filter-tipo" name="tipo">
                        <option value="">Todos los tipos</option>
                        <option value="PELICULA" ${filtroTipo == 'PELICULA' ? 'selected' : ''}>Películas</option>
                        <option value="SERIE" ${filtroTipo == 'SERIE' ? 'selected' : ''}>Series</option>
                    </select>
                    <select class="filter-select" id="filter-genero" name="genero">
                        <option value="">Todos los géneros</option>
                        <c:forEach items="${generos}" var="genero">
                            <option value="${genero.nombre}" ${filtroGenero == genero.nombre ? 'selected' : ''}>${genero.nombre}</option>
                        </c:forEach>
                    </select>
                    <select class="filter-select" id="filter-estado" name="estado">
                        <option value="">Todos los estados</option>
                        <option value="disponible" ${filtroEstado == 'disponible' ? 'selected' : ''}>Disponible</option>
                        <option value="no-disponible" ${filtroEstado == 'no-disponible' ? 'selected' : ''}>No Disponible</option>
                        <option value="stock-bajo" ${filtroEstado == 'stock-bajo' ? 'selected' : ''}>Stock Bajo</option>
                    </select>
                    <button type="submit" class="btn-primary" style="padding: 10px 20px;">🔍 Buscar</button>
                    <button type="button" class="btn-secondary" onclick="limpiarFiltros()" style="padding: 10px 20px;">🔄 Limpiar</button>
                </form>

                <c:if test="${not empty filtroBusqueda or not empty filtroTipo or not empty filtroGenero or not empty filtroEstado}">
                    <div style="margin: 10px 0; padding: 10px; background: rgba(229, 9, 20, 0.1); border-left: 3px solid #e50914; border-radius: 5px;">
                        <strong>🔍 Filtros activos:</strong>
                        <c:if test="${not empty filtroBusqueda}">
                            <span class="badge" style="margin-left: 10px;">Búsqueda: "${filtroBusqueda}"</span>
                        </c:if>
                        <c:if test="${not empty filtroTipo}">
                            <span class="badge" style="margin-left: 10px;">Tipo: ${filtroTipo == 'PELICULA' ? 'Películas' : 'Series'}</span>
                        </c:if>
                        <c:if test="${not empty filtroGenero}">
                            <span class="badge" style="margin-left: 10px;">Género: ${filtroGenero}</span>
                        </c:if>
                        <c:if test="${not empty filtroEstado}">
                            <span class="badge" style="margin-left: 10px;">Estado: ${filtroEstado}</span>
                        </c:if>
                        <span style="margin-left: 10px; color: #28a745; font-weight: bold;">(${totalResultados} resultado${totalResultados != 1 ? 's' : ''})</span>
                    </div>
                </c:if>

                <div class="table-container">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Poster</th>
                                <th>Título</th>
                                <th>Tipo</th>
                                <th>Año</th>
                                <th>Género</th>
                                <th>Copias Disp.</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody id="tabla-contenidos">
                            <c:choose>
                                <c:when test="${not empty contenidos}">
                                    <c:forEach items="${contenidos}" var="c">
                                        <tr data-id="${c.id}">
                                            <td>#${c.id}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty c.imagenUrl}">
                                                        <img src="${c.imagenUrl}" alt="Poster ${c.titulo}" class="table-img"
                                                             onerror="this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg'">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"
                                                             alt="Poster ${c.titulo}" class="table-img">
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${c.titulo}</td>
                                            <td>
                                                <span class="badge ${c.tipo == 'PELICULA' ? 'badge-movie' : 'badge-series'}">
                                                    ${c.tipo == 'PELICULA' ? 'Película' : 'Serie'}
                                                </span>
                                            </td>
                                            <td>${c.anio}</td>
                                            <td>${c.genero}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty c.copiasDisponibles and not empty c.copiasTotales}">
                                                        ${c.copiasDisponibles} / ${c.copiasTotales}
                                                    </c:when>
                                                    <c:otherwise>N/A</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${c.copiasDisponibles == 0}">
                                                        <span class="status-badge inactive">No Disponible</span>
                                                    </c:when>
                                                    <c:when test="${c.copiasDisponibles <= (c.copiasTotales * 0.2)}">
                                                        <span class="status-badge warning">Stock Bajo</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge active">Disponible</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <button class="btn-icon" title="Editar" onclick="editarContenido(${c.id})">✏️</button>
                                                <button class="btn-icon" title="Gestionar Copias" onclick="gestionarCopias(${c.id})">📦</button>
                                                <button class="btn-icon" title="Eliminar" onclick="eliminarContenido(${c.id})">🗑️</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" style="text-align: center; padding: 40px;">
                                            No hay contenidos en el catálogo.
                                            <a href="#" onclick="document.getElementById('form-agregar-contenido').scrollIntoView({behavior: 'smooth'})">
                                                Agregar el primero
                                            </a>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <%-- Paginación --%>
                <c:if test="${totalPaginas > 1}">
                    <div class="pagination">
                        <c:choose>
                            <c:when test="${paginaActual > 1}">
                                <button class="btn-secondary" onclick="cambiarPagina(${paginaActual - 1})">← Anterior</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn-secondary" disabled>← Anterior</button>
                            </c:otherwise>
                        </c:choose>

                        <span>Página ${paginaActual} de ${totalPaginas}</span>

                        <c:choose>
                            <c:when test="${paginaActual < totalPaginas}">
                                <button class="btn-secondary" onclick="cambiarPagina(${paginaActual + 1})">Siguiente →</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn-secondary" disabled>Siguiente →</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </section>

            <%-- Alertas de Stock Bajo --%>
            <c:if test="${not empty contenidosStockBajo}">
                <section class="admin-section">
                    <div class="section-header">
                        <h2>⚠️ Alertas de Stock Bajo</h2>
                    </div>

                    <div class="alerts-container">
                        <c:forEach items="${contenidosStockBajo}" var="contenido">
                            <div class="alert-item ${contenido.copiasDisponibles == 0 ? 'critical' : 'warning'}">
                                <span class="alert-icon">
                                    ${contenido.copiasDisponibles == 0 ? '🚨' : '⚠️'}
                                </span>
                                <div class="alert-content">
                                    <strong>${contenido.titulo}</strong>
                                    <p>
                                        <c:choose>
                                            <c:when test="${contenido.copiasDisponibles == 0}">
                                                0 copias disponibles. Contenido agotado - alta demanda.
                                            </c:when>
                                            <c:otherwise>
                                                Solo ${contenido.copiasDisponibles} copias disponibles de ${contenido.copiasTotales} totales.
                                                Considere aumentar el inventario.
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                                <button class="btn-${contenido.copiasDisponibles == 0 ? 'primary' : 'secondary'}"
                                        onclick="aumentarStock(${contenido.id})">
                                    ${contenido.copiasDisponibles == 0 ? 'Renovar Licencias' : 'Aumentar Stock'}
                                </button>
                            </div>
                        </c:forEach>
                    </div>
                </section>
            </c:if>
        </div>
    </div>

    <%-- Modal de Edición de Contenido --%>
    <div id="modal-editar-contenido" class="modal" style="display: none;">
        <div class="modal-content">
            <span class="close" onclick="cerrarModalEditar()">&times;</span>
            <h2>✏️ Editar Contenido</h2>

            <form id="form-editar-contenido" onsubmit="guardarEdicionContenido(event)">
                <input type="hidden" id="edit-id" name="id">

                <div class="form-grid">
                    <div class="form-group">
                        <label>Título:</label>
                        <input type="text" id="edit-titulo" name="titulo" required>
                    </div>
                    <div class="form-group">
                        <label>Tipo:</label>
                        <select id="edit-tipo" name="tipo" required>
                            <option value="PELICULA">Película</option>
                            <option value="SERIE">Serie</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Año:</label>
                        <input type="number" id="edit-anio" name="anio" min="1900" max="2030">
                    </div>
                    <div class="form-group">
                        <label>Duración (minutos):</label>
                        <input type="number" id="edit-duracion" name="duracion" min="1">
                        <small style="color: #888;">Ejemplo: 150 minutos = 2h 30min</small>
                    </div>
                    <div class="form-group">
                        <label>Director:</label>
                        <input type="text" id="edit-director" name="director">
                    </div>
                    <div class="form-group">
                        <label>Género:</label>
                        <select id="edit-genero" name="genero">
                            <option value="">Seleccionar género</option>
                            <c:forEach items="${generos}" var="genero">
                                <option value="${genero.nombre}">${genero.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group full-width">
                        <label>Sinopsis:</label>
                        <textarea id="edit-sinopsis" name="sinopsis" rows="4"></textarea>
                    </div>
                    <div class="form-group">
                        <label>URL del Poster:</label>
                        <input type="url" id="edit-imagenUrl" name="imagenUrl">
                    </div>
                    <div class="form-group">
                        <label>Copias Totales:</label>
                        <input type="number" id="edit-copiasTotales" name="copiasTotales" min="0">
                    </div>
                    <div class="form-group">
                        <label>Copias Disponibles:</label>
                        <input type="number" id="edit-copiasDisponibles" name="copiasDisponibles" min="0">
                    </div>
                    <div class="form-group">
                        <label>Precio de Alquiler:</label>
                        <input type="number" id="edit-precioAlquiler" name="precioAlquiler" step="0.01" min="0">
                    </div>
                    <div class="form-group">
                        <label>Disponible para Alquilar:</label>
                        <select id="edit-disponible" name="disponibleParaAlquiler">
                            <option value="true">Sí</option>
                            <option value="false">No</option>
                        </select>
                    </div>
                </div>

                <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn-secondary" onclick="cerrarModalEditar()">Cancelar</button>
                    <button type="submit" class="btn-primary">💾 Guardar Cambios</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Incluir footer del proyecto --%>
    <jsp:include page="/WEB-INF/views/fragments/footer.jsp" />

    <%-- Scripts --%>
    <script src="${pageContext.request.contextPath}/js/inventario.js?v=5.0"></script>
    <script>
        // Variables globales
        const APP_CONTEXT = '${pageContext.request.contextPath}';

        // Inicializar dashboard cuando carga la página
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Inicializando Gestor de Inventario...');

            // Cargar estadísticas desde el servidor si no están disponibles
            <c:if test="${empty estadisticas}">
                cargarEstadisticasDashboard();
            </c:if>

            // Cargar géneros dinámicamente para los filtros
            cargarGenerosFiltro();

            // Si hay contenidos, aplicar listeners
            <c:if test="${not empty contenidos}">
                console.log('Contenidos cargados: ${fn:length(contenidos)}');
            </c:if>

            // Configurar envío automático del formulario de filtros
            const formFiltros = document.getElementById('form-filtros');
            const filterTipo = document.getElementById('filter-tipo');
            const filterGenero = document.getElementById('filter-genero');
            const filterEstado = document.getElementById('filter-estado');

            // Enviar formulario al cambiar los selectores
            if (filterTipo) {
                filterTipo.addEventListener('change', function() {
                    formFiltros.submit();
                });
                console.log('Event listener agregado a filter-tipo');
            }

            if (filterGenero) {
                filterGenero.addEventListener('change', function() {
                    formFiltros.submit();
                });
                console.log('Event listener agregado a filter-genero');
            }

            if (filterEstado) {
                filterEstado.addEventListener('change', function() {
                    formFiltros.submit();
                });
                console.log('Event listener agregado a filter-estado');
            }

            // Enviar formulario con Enter en el campo de búsqueda
            const searchInput = document.getElementById('search-catalogo');
            if (searchInput) {
                searchInput.addEventListener('keypress', function(event) {
                    if (event.key === 'Enter') {
                        event.preventDefault();
                        formFiltros.submit();
                    }
                });
                console.log('Event listener agregado a search-catalogo');
            }

            console.log('Gestor de Inventario inicializado correctamente');

            // Event listener para cerrar modal al hacer clic fuera de él
            window.addEventListener('click', function(event) {
                const modal = document.getElementById('modal-editar-contenido');
                if (event.target === modal) {
                    cerrarModalEditar();
                }
            });
        });

        // Funciones para tabs de agregar contenido
        function showAddTab(tabName) {
            // Ocultar todos los tabs
            document.getElementById('tab-manual').style.display = 'none';
            document.getElementById('tab-api').style.display = 'none';
            document.getElementById('tab-masivo').style.display = 'none';

            // Mostrar el tab seleccionado
            document.getElementById('tab-' + tabName).style.display = 'block';

            // Actualizar botones activos
            const buttons = document.querySelectorAll('.add-content-tabs .tab-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');
        }

        // Función para cambiar de página manteniendo los filtros
        function cambiarPagina(pagina) {
            const params = new URLSearchParams(window.location.search);
            params.set('pagina', pagina);
            window.location.href = '${pageContext.request.contextPath}/inventario?' + params.toString();
        }

        // Función para limpiar filtros
        function limpiarFiltros() {
            window.location.href = '${pageContext.request.contextPath}/inventario';
        }

        // Función para cargar géneros en filtro
        function cargarGenerosFiltro() {
            // Ya están cargados desde el servidor
            console.log('Géneros disponibles en filtro');
        }
    </script>
</body>
</html>

