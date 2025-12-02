<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>Panel de Administración - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />

    <div class="container">
        <div class="admin-panel">
            <h1>Panel de Administración</h1>

            <!-- Mensajes Flash -->
            <c:if test="${not empty mensaje}">
                <div class="alert alert-success alert-dismissible fade show" role="alert" style="background-color: #28a745; color: white; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                    <strong>✓ ${mensaje}</strong>
                    <button type="button" class="close" style="color: white;" onclick="this.parentElement.style.display='none'">
                        <span>&times;</span>
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="background-color: #dc3545; color: white; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                    <strong>✗ ${error}</strong>
                    <button type="button" class="close" style="color: white;" onclick="this.parentElement.style.display='none'">
                        <span>&times;</span>
                    </button>
                </div>
            </c:if>

            <!-- Estadísticas Generales -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-content">
                        <h3>Total Usuarios</h3>
                        <p class="stat-number">${totalUsuarios}</p>
                        <span class="stat-change">Usuarios registrados</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-content">
                        <h3>Usuarios Activos</h3>
                        <p class="stat-number">${usuariosActivos}</p>
                        <span class="stat-change positive">Activos en sistema</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">🛡️</div>
                    <div class="stat-content">
                        <h3>Administradores</h3>
                        <p class="stat-number">${totalAdministradores}</p>
                        <span class="stat-change">Con permisos totales</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon">📊</div>
                    <div class="stat-content">
                        <h3>Otros Roles</h3>
                        <p class="stat-number">${totalGestores + totalAnalistas + totalRegulares}</p>
                        <span class="stat-change">Gestores, Analistas y Regulares</span>
                    </div>
                </div>
            </div>

            <!-- Gestión de Usuarios -->
            <section class="admin-section">
                <div class="section-header">
                    <h2>👥 Gestión de Usuarios</h2>
                    <button class="btn-primary" onclick="window.location.href='${pageContext.request.contextPath}/admin/usuarios/crear'">➕ Crear Usuario</button>
                </div>

                <form method="get" action="${pageContext.request.contextPath}/admin/usuarios" id="filtrosForm">
                    <div class="search-filter-bar">
                        <input type="text"
                               id="busqueda"
                               name="busqueda"
                               class="search-input"
                               placeholder="Buscar usuario..."
                               value="${busquedaFiltro}">

                        <select id="rol" name="rol" class="filter-select">
                            <option value="">Todos los roles</option>
                            <option value="USUARIO_REGULAR" ${rolFiltro == 'USUARIO_REGULAR' ? 'selected' : ''}>Usuario Regular</option>
                            <option value="ADMINISTRADOR" ${rolFiltro == 'ADMINISTRADOR' ? 'selected' : ''}>Administrador</option>
                            <option value="GESTOR_INVENTARIO" ${rolFiltro == 'GESTOR_INVENTARIO' ? 'selected' : ''}>Gestor de Inventario</option>
                            <option value="ANALISTA_DATOS" ${rolFiltro == 'ANALISTA_DATOS' ? 'selected' : ''}>Analista de Datos</option>
                        </select>

                        <select id="activo" name="activo" class="filter-select">
                            <option value="">Estado</option>
                            <option value="true" ${activoFiltro == 'true' ? 'selected' : ''}>Activo</option>
                            <option value="false" ${activoFiltro == 'false' ? 'selected' : ''}>Inactivo</option>
                        </select>

                        <button type="submit" class="search-btn">Buscar</button>
                    </div>
                </form>

                <div class="table-container">
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nombre</th>
                                <th>Email</th>
                                <th>Rol</th>
                                <th>Estado</th>
                                <th>Fecha Registro</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty usuarios}">
                                    <c:forEach var="usuario" items="${usuarios}">
                                        <tr>
                                            <td>#${usuario.id}</td>
                                            <td>${usuario.nombre}</td>
                                            <td>${usuario.email}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${usuario.rol == 'ADMINISTRADOR'}">
                                                        <span class="badge badge-admin">Administrador</span>
                                                    </c:when>
                                                    <c:when test="${usuario.rol == 'GESTOR_INVENTARIO'}">
                                                        <span class="badge badge-gestor">Gestor Inventario</span>
                                                    </c:when>
                                                    <c:when test="${usuario.rol == 'ANALISTA_DATOS'}">
                                                        <span class="badge badge-analista">Analista Datos</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-user">Usuario Regular</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${usuario.activo}">
                                                        <span class="status-badge active">Activo</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge inactive">Inactivo</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${usuario.fechaRegistro}</td>
                                            <td>
                                                <button class="btn-icon"
                                                        onclick="window.location.href='${pageContext.request.contextPath}/admin/usuarios/editar/${usuario.id}'"
                                                        title="Editar">✏️</button>
                                                <button class="btn-icon"
                                                        onclick="window.location.href='${pageContext.request.contextPath}/admin/usuarios/detalle/${usuario.id}'"
                                                        title="Ver detalles">👁️</button>
                                                <!-- Botón Activar/Desactivar -->
                                                <c:choose>
                                                    <c:when test="${usuario.id == usuarioLogueado.id}">
                                                        <!-- Usuario logueado: no puede desactivarse a sí mismo -->
                                                        <button class="btn-icon"
                                                                onclick="alert('🚫 No puedes desactivar tu propia cuenta')"
                                                                title="No puedes desactivarte a ti mismo"
                                                                style="opacity: 0.5; cursor: not-allowed;">🚫</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:choose>
                                                            <c:when test="${usuario.activo}">
                                                                <button class="btn-icon"
                                                                        onclick="confirmarDesactivar(${usuario.id})"
                                                                        title="Desactivar">🚫</button>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button class="btn-icon"
                                                                        onclick="confirmarActivar(${usuario.id})"
                                                                        title="Activar">✅</button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:otherwise>
                                                </c:choose>

                                                <!-- Botón Eliminar -->
                                                <c:choose>
                                                    <c:when test="${usuario.id == usuarioLogueado.id}">
                                                        <!-- Usuario logueado: no puede eliminarse a sí mismo -->
                                                        <button class="btn-icon"
                                                                onclick="alert('🚫 NO PUEDES ELIMINAR TU PROPIA CUENTA\n\nPide a otro administrador que lo haga si realmente es necesario.')"
                                                                title="No puedes eliminarte a ti mismo"
                                                                style="opacity: 0.5; cursor: not-allowed;">🗑️</button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn-icon"
                                                                onclick="confirmarEliminar(${usuario.id}, '${usuario.nombre}')"
                                                                title="Eliminar">🗑️</button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: 40px;">
                                            <p style="font-size: 18px; color: #888;">
                                                No se encontraron usuarios que coincidan con los filtros.
                                            </p>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="pagination">
                    <button class="btn-secondary">← Anterior</button>
                    <span>Mostrando ${usuarios.size()} de ${totalUsuarios} usuarios</span>
                    <button class="btn-secondary">Siguiente →</button>
                </div>
            </section>

        </div>
    </div>

    <!-- JavaScript -->
    <script>
        // ID del usuario logueado
        var usuarioLogueadoId = ${usuarioLogueado.id};

        function confirmarDesactivar(id) {
            // Validar que no sea el propio usuario
            if (id === usuarioLogueadoId) {
                alert('🚫 NO PUEDES DESACTIVAR TU PROPIA CUENTA\n\n' +
                      'Esto te dejaría sin acceso al sistema.\n\n' +
                      'Si realmente necesitas desactivar esta cuenta, pide a otro administrador que lo haga.');
                return;
            }

            if (confirm('¿Estás seguro de que deseas desactivar este usuario?\n\n' +
                       'El usuario no podrá iniciar sesión hasta que sea reactivado.')) {
                // Crear y enviar formulario dinámicamente
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/admin/usuarios/desactivar/' + id;
                document.body.appendChild(form);
                form.submit();
            }
        }

        function confirmarActivar(id) {
            if (confirm('¿Estás seguro de que deseas activar este usuario?\n\n' +
                       'El usuario podrá iniciar sesión nuevamente.')) {
                // Crear y enviar formulario dinámicamente
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/admin/usuarios/activar/' + id;
                document.body.appendChild(form);
                form.submit();
            }
        }

        function confirmarEliminar(id, nombre) {
            // Validar que no sea el propio usuario
            if (id === usuarioLogueadoId) {
                alert('🚫 NO PUEDES ELIMINAR TU PROPIA CUENTA\n\n' +
                      'Esta es una medida de seguridad para prevenir:\n' +
                      '• Pérdida accidental de acceso administrativo\n' +
                      '• Bloqueo del sistema\n\n' +
                      'Si realmente necesitas eliminar esta cuenta, pide a otro administrador que lo haga.');
                return;
            }

            if (confirm('⚠️ ADVERTENCIA: ELIMINACIÓN PERMANENTE ⚠️\n\n' +
                       '¿Estás seguro de que deseas eliminar al usuario "' + nombre + '"?\n\n' +
                       'Esta acción:\n' +
                       '• NO se puede deshacer\n' +
                       '• Eliminará TODOS los datos del usuario\n' +
                       '• Es PERMANENTE\n\n' +
                       '¿Continuar con la eliminación?')) {

                // Crear y enviar formulario dinámicamente con el ID en la URL
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/admin/usuarios/eliminar/' + id;
                document.body.appendChild(form);
                form.submit();
            }
        }

        // Auto-ocultar mensajes después de 5 segundos
        setTimeout(function() {
            var alerts = document.querySelectorAll('.alert');
            alerts.forEach(function(alert) {
                alert.style.transition = 'opacity 0.5s';
                alert.style.opacity = '0';
                setTimeout(function() {
                    alert.style.display = 'none';
                }, 500);
            });
        }, 5000);
    </script>

    <jsp:include page="/WEB-INF/views/fragments/footer.jsp" />
</body>
</html>

