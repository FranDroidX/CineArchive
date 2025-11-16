<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>Analista de Datos - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <%@ include file="fragments/header.jsp" %>

    <div class="container">
        <div class="admin-panel">
            <h1>Panel de Analítica y Reportes</h1>

            <!-- KPIs Principales -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">📊</div>
                    <div class="stat-content">
                        <h3>Total Alquileres</h3>
                        <p class="stat-number" id="alquileres-mes">
                            <fmt:formatNumber value="${estadisticas.total_alquileres}" type="number"/>
                        </p>
                        <span class="stat-change">Todos los tiempos</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-content">
                        <h3>Total Usuarios</h3>
                        <p class="stat-number" id="usuarios-activos">
                            <fmt:formatNumber value="${estadisticas.total_usuarios}" type="number"/>
                        </p>
                        <span class="stat-change">Registrados en el sistema</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">⭐</div>
                    <div class="stat-content">
                        <h3>Calificación Promedio</h3>
                        <p class="stat-number" id="calificacion-promedio">
                            <fmt:formatNumber value="${estadisticas.calificacion_promedio_global}" maxFractionDigits="1"/>/5
                        </p>
                        <span class="stat-change">En todo el catálogo</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">💰</div>
                    <div class="stat-content">
                        <h3>Ingresos Totales</h3>
                        <p class="stat-number" id="ingresos-totales">
                            $<fmt:formatNumber value="${estadisticas.ingresos_totales}" maxFractionDigits="2"/>
                        </p>
                        <span class="stat-change">Acumulado histórico</span>
                    </div>
                </div>
            </div>

            <!-- Generador de Reportes -->
            <section class="admin-section">
                <div class="section-header">
                    <h2>📄 Generador de Reportes</h2>
                </div>

                <div class="report-generator">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="tipo-reporte">Tipo de Reporte:</label>
                            <select id="tipo-reporte">
                                <option value="">Seleccionar tipo...</option>
                                <option value="mas-alquilados">Contenido Más Alquilado</option>
                                <option value="rendimiento-generos">Rendimiento por Género</option>
                                <option value="comportamiento-usuarios">Comportamiento de Usuarios</option>
                                <option value="tendencias">Tendencias Temporales</option>
                                <option value="demografico">Análisis Demográfico</option>
                                <option value="ingresos">Análisis de Ingresos</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="periodo-reporte">Período:</label>
                            <select id="periodo-reporte">
                                <option value="ultima-semana">Última Semana</option>
                                <option value="ultimo-mes" selected>Último Mes</option>
                                <option value="ultimo-trimestre">Último Trimestre</option>
                                <option value="ultimo-año">Último Año</option>
                                <option value="personalizado">Personalizado</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="fecha-inicio">Fecha Inicio:</label>
                            <input type="date" id="fecha-inicio">
                        </div>
                        <div class="form-group">
                            <label for="fecha-fin">Fecha Fin:</label>
                            <input type="date" id="fecha-fin">
                        </div>
                        <div class="form-group">
                            <label for="formato-reporte">Formato:</label>
                            <select id="formato-reporte">
                                <option value="pdf">PDF</option>
                                <option value="excel">Excel</option>
                                <option value="csv">CSV</option>
                                <option value="html">HTML</option>
                            </select>
                        </div>
                    </div>
                    <button class="btn-primary" onclick="generarReporte()">📊 Generar Reporte</button>
                </div>
            </section>

            <!-- Top 10 Más Alquilados -->
            <section class="admin-section">
                <div class="section-header">
                    <h2>🏆 Top 10 Contenido Más Alquilado</h2>
                    <label for="filtro-top" style="display:inline-block; margin-right:10px;">Filtrar por:</label>
                    <select class="filter-select" id="filtro-top">
                        <option value="mes" selected>Este Mes</option>
                        <option value="trimestre">Este Trimestre</option>
                        <option value="año">Este Año</option>
                    </select>
                </div>

                <div class="table-container">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Título</th>
                                <th>Tipo</th>
                                <th>Género</th>
                                <th>Alquileres</th>
                                <th>Ingresos</th>
                                <th>Calificación</th>
                                <th>Tendencia</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty topContenidos}">
                                    <c:forEach items="${topContenidos}" var="contenido" varStatus="status">
                                        <tr>
                                            <td>${status.index + 1}</td>
                                            <td><strong>${contenido.titulo}</strong></td>
                                            <td>
                                                <span class="badge badge-${contenido.tipo == 'PELICULA' ? 'movie' : 'series'}">
                                                    ${contenido.tipo}
                                                </span>
                                            </td>
                                            <td>${contenido.genero != null ? contenido.genero : 'N/A'}</td>
                                            <td><fmt:formatNumber value="${contenido.total_alquileres}" type="number"/></td>
                                            <td>
                                                $<fmt:formatNumber value="${contenido.total_alquileres * 4.99}" maxFractionDigits="2"/>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${contenido.calificacion_promedio != null}">
                                                        <c:set var="rating" value="${contenido.calificacion_promedio}"/>
                                                        <c:choose>
                                                            <c:when test="${rating >= 4.5}">★★★★★</c:when>
                                                            <c:when test="${rating >= 3.5}">★★★★☆</c:when>
                                                            <c:when test="${rating >= 2.5}">★★★☆☆</c:when>
                                                            <c:when test="${rating >= 1.5}">★★☆☆☆</c:when>
                                                            <c:otherwise>★☆☆☆☆</c:otherwise>
                                                        </c:choose>
                                                        <fmt:formatNumber value="${rating}" maxFractionDigits="1"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        Sin calificar
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="trend-stable">➡️</span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="8" style="text-align: center; color: #666; padding: 20px;">
                                            📊 No hay datos de alquileres en el período seleccionado
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- Sección de Análisis por Género ELIMINADA -->


        </div>
    </div>

    <%@ include file="fragments/footer.jsp" %>

    <script src="${pageContext.request.contextPath}/js/script.js"></script>
    <script>
        function generarReporte() {
            const tipo = document.getElementById('tipo-reporte').value;
            const formato = document.getElementById('formato-reporte').value;

            if (!tipo) {
                alert('Por favor selecciona un tipo de reporte');
                return;
            }

            alert('Generando reporte de tipo: ' + tipo + ' en formato ' + formato);
        }
    </script>
</body>
</html>

