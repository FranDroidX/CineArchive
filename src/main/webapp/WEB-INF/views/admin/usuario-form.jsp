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
    <title><c:choose><c:when test="${not empty usuario.id}">Editar</c:when><c:otherwise>Crear</c:otherwise></c:choose> Usuario - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />

    <div class="container">
        <div class="admin-panel">
            <h1>
                <c:choose>
                    <c:when test="${not empty usuario.id}">✏️ Editar Usuario</c:when>
                    <c:otherwise>➕ Crear Nuevo Usuario</c:otherwise>
                </c:choose>
            </h1>

            <!-- Mensajes -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger" style="background-color: #dc3545; color: white; padding: 15px; border-radius: 8px; margin-bottom: 20px;">
                    <strong>✗ ${error}</strong>
                    <button type="button" class="close" style="color: white; float: right; background: none; border: none; font-size: 20px; cursor: pointer;" onclick="this.parentElement.style.display='none'">
                        <span>&times;</span>
                    </button>
                </div>
            </c:if>

            <!-- Formulario -->
            <section class="admin-section">
                <form method="post"
                      action="${pageContext.request.contextPath}/admin/usuarios/<c:choose><c:when test='${not empty usuario.id}'>editar/${usuario.id}</c:when><c:otherwise>crear</c:otherwise></c:choose>"
                      id="formularioUsuario"
                      onsubmit="return validarFormulario()">

                    <!-- ID oculto para edición -->
                    <c:if test="${not empty usuario.id}">
                        <input type="hidden" name="id" value="${usuario.id}">
                    </c:if>

                    <!-- Sección 1: Información Personal -->
                    <div style="margin-bottom: 40px;">
                        <h2>👤 Información Personal</h2>

                        <div class="form-grid">
                            <!-- Nombre -->
                            <div class="form-group">
                                <label for="nombre">
                                    <strong>Nombre Completo</strong> <span style="color: #dc3545;">*</span>
                                </label>
                                <input type="text"
                                       id="nombre"
                                       name="nombre"
                                       class="search-input"
                                       placeholder="Ej: Juan Pérez"
                                       value="${usuario.nombre}"
                                       required
                                       minlength="3"
                                       maxlength="100">
                            </div>

                            <!-- Email -->
                            <div class="form-group">
                                <label for="email">
                                    <strong>Email</strong> <span style="color: #dc3545;">*</span>
                                </label>
                                <input type="email"
                                       id="email"
                                       name="email"
                                       class="search-input"
                                       placeholder="usuario@ejemplo.com"
                                       value="${usuario.email}"
                                       required>
                            </div>

                            <!-- Fecha de Nacimiento -->
                            <div class="form-group">
                                <label for="fechaNacimiento">
                                    <strong>Fecha de Nacimiento</strong>
                                </label>
                                <input type="date"
                                       id="fechaNacimiento"
                                       name="fechaNacimiento"
                                       class="search-input"
                                       value="${usuario.fechaNacimiento}">
                            </div>
                        </div>
                    </div>

                    <!-- Sección 2: Credenciales -->
                    <div style="margin-bottom: 40px;">
                        <h2>🔐 Credenciales de Acceso</h2>

                        <!-- Checkbox para cambiar contraseña (solo al editar) -->
                        <c:if test="${not empty usuario.id}">
                            <div style="background-color: rgba(255, 193, 7, 0.1); border-left: 4px solid #ffc107; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
                                <label style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
                                    <input type="checkbox"
                                           id="cambiarPassword"
                                           onchange="togglePasswordFields()"
                                           style="width: 20px; height: 20px;">
                                    <div>
                                        <strong>🔑 Cambiar Contraseña</strong>
                                        <p style="margin: 0; font-size: 12px; color: #888;">
                                            Marca esta casilla si deseas establecer una nueva contraseña para este usuario
                                        </p>
                                    </div>
                                </label>
                            </div>
                        </c:if>

                        <div id="passwordSection" style="${not empty usuario.id ? 'display: none;' : ''}">
                            <c:if test="${not empty usuario.id}">
                                <p style="color: #888; margin-bottom: 15px;">
                                    <strong>Nota:</strong> Establece una nueva contraseña para el usuario.
                                    El usuario deberá usar esta nueva contraseña para iniciar sesión.
                                </p>
                            </c:if>

                            <div class="form-grid">
                                <!-- Contraseña -->
                                <div class="form-group">
                                    <label for="password">
                                        <strong><c:choose><c:when test="${empty usuario.id}">Contraseña</c:when><c:otherwise>Nueva Contraseña</c:otherwise></c:choose></strong>
                                        <c:if test="${empty usuario.id}">
                                            <span style="color: #dc3545;">*</span>
                                        </c:if>
                                    </label>
                                    <input type="password"
                                           id="password"
                                           name="${empty usuario.id ? 'password' : 'passwordNueva'}"
                                           class="search-input"
                                           placeholder="Mínimo 6 caracteres"
                                           ${empty usuario.id ? 'required' : ''}
                                           minlength="6"
                                           onkeyup="validarFortalezaPassword()">
                                    <div id="passwordStrength" style="height: 5px; margin-top: 5px; border-radius: 3px;"></div>
                                    <small id="passwordMessage" style="display: block; margin-top: 5px;"></small>
                                </div>

                                <!-- Confirmar Contraseña -->
                                <div class="form-group">
                                    <label for="confirmPassword">
                                        <strong>Confirmar Contraseña</strong>
                                        <c:if test="${empty usuario.id}">
                                            <span style="color: #dc3545;">*</span>
                                        </c:if>
                                    </label>
                                    <input type="password"
                                           id="confirmPassword"
                                           name="passwordConfirm"
                                           class="search-input"
                                           placeholder="Repite la contraseña"
                                           ${empty usuario.id ? 'required' : ''}
                                           minlength="6">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Sección 3: Rol del Sistema -->
                    <div style="margin-bottom: 40px;">
                        <h2>🎭 Rol del Sistema</h2>

                        <div style="margin-top: 15px;">
                            <p style="margin-bottom: 15px; color: #888;">Selecciona el rol que tendrá este usuario:</p>

                            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                                <!-- Usuario Regular -->
                                <label style="cursor: pointer;">
                                    <input type="radio"
                                           name="rol"
                                           value="USUARIO_REGULAR"
                                           ${empty usuario.id || usuario.rol == 'USUARIO_REGULAR' ? 'checked' : ''}
                                           required>
                                    <div style="padding: 20px; background-color: var(--surface-color); border: 2px solid var(--secondary-color); border-radius: 8px; text-align: center; transition: all 0.3s;">
                                        <div style="font-size: 30px; margin-bottom: 10px;">👤</div>
                                        <strong>Usuario Regular</strong>
                                        <p style="font-size: 12px; color: #888; margin-top: 5px;">Acceso básico al catálogo</p>
                                    </div>
                                </label>

                                <!-- Gestor -->
                                <label style="cursor: pointer;">
                                    <input type="radio"
                                           name="rol"
                                           value="GESTOR_INVENTARIO"
                                           ${usuario.rol == 'GESTOR_INVENTARIO' ? 'checked' : ''}>
                                    <div style="padding: 20px; background-color: var(--surface-color); border: 2px solid var(--secondary-color); border-radius: 8px; text-align: center; transition: all 0.3s;">
                                        <div style="font-size: 30px; margin-bottom: 10px;">📦</div>
                                        <strong>Gestor Inventario</strong>
                                        <p style="font-size: 12px; color: #888; margin-top: 5px;">Gestión de contenido</p>
                                    </div>
                                </label>

                                <!-- Analista -->
                                <label style="cursor: pointer;">
                                    <input type="radio"
                                           name="rol"
                                           value="ANALISTA_DATOS"
                                           ${usuario.rol == 'ANALISTA_DATOS' ? 'checked' : ''}>
                                    <div style="padding: 20px; background-color: var(--surface-color); border: 2px solid var(--secondary-color); border-radius: 8px; text-align: center; transition: all 0.3s;">
                                        <div style="font-size: 30px; margin-bottom: 10px;">📊</div>
                                        <strong>Analista Datos</strong>
                                        <p style="font-size: 12px; color: #888; margin-top: 5px;">Reportes y estadísticas</p>
                                    </div>
                                </label>

                                <!-- Administrador -->
                                <label style="cursor: pointer;">
                                    <input type="radio"
                                           name="rol"
                                           value="ADMINISTRADOR"
                                           ${usuario.rol == 'ADMINISTRADOR' ? 'checked' : ''}>
                                    <div style="padding: 20px; background-color: var(--surface-color); border: 2px solid var(--secondary-color); border-radius: 8px; text-align: center; transition: all 0.3s;">
                                        <div style="font-size: 30px; margin-bottom: 10px;">🛡️</div>
                                        <strong>Administrador</strong>
                                        <p style="font-size: 12px; color: #888; margin-top: 5px;">Control total del sistema</p>
                                    </div>
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Sección 4: Estado -->
                    <div style="margin-bottom: 40px;">
                        <h2>✅ Estado del Usuario</h2>

                        <div style="margin-top: 15px;">
                            <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 15px; background-color: var(--surface-color); border-radius: 8px;">
                                <input type="checkbox"
                                       name="activo"
                                       value="true"
                                       ${empty usuario.id || usuario.activo ? 'checked' : ''}
                                       style="width: 20px; height: 20px;">
                                <div>
                                    <strong>Usuario Activo</strong>
                                    <p style="margin: 0; font-size: 12px; color: #888;">El usuario podrá iniciar sesión y usar el sistema</p>
                                </div>
                            </label>
                        </div>
                    </div>

                    <!-- Información adicional para edición -->
                    <c:if test="${not empty usuario.id}">
                        <div style="background-color: rgba(23, 162, 184, 0.1); border-left: 4px solid #17a2b8; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
                            <h3 style="margin-top: 0;">ℹ️ Información del Usuario</h3>
                            <p><strong>ID:</strong> ${usuario.id}</p>
                            <p><strong>Fecha de Registro:</strong> ${usuario.fechaRegistro}</p>
                            <p style="margin-bottom: 0;">
                                <strong>💡 Tip:</strong> Puedes establecer una nueva contraseña para este usuario
                                marcando la casilla "Cambiar Contraseña" en la sección de credenciales.
                            </p>
                        </div>
                    </c:if>

                    <!-- Botones de Acción -->
                    <div class="action-buttons" style="margin-top: 40px;">
                        <button type="submit" class="btn-primary" style="font-size: 16px; padding: 15px 40px;">
                            💾 <c:choose><c:when test="${not empty usuario.id}">Guardar Cambios</c:when><c:otherwise>Crear Usuario</c:otherwise></c:choose>
                        </button>

                        <button type="button" class="btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/admin/usuarios'" style="font-size: 16px; padding: 15px 40px;">
                            ✖ Cancelar
                        </button>

                        <c:if test="${not empty usuario.id}">
                            <button type="button" class="btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/admin/usuarios/detalle/${usuario.id}'" style="font-size: 16px; padding: 15px 40px;">
                                👁️ Ver Detalle
                            </button>
                        </c:if>
                    </div>
                </form>
            </section>
        </div>
    </div>

    <!-- JavaScript -->
    <script>
        // Mostrar/ocultar campos de contraseña al editar
        function togglePasswordFields() {
            const checkbox = document.getElementById('cambiarPassword');
            const passwordSection = document.getElementById('passwordSection');
            const passwordInput = document.getElementById('password');
            const confirmPasswordInput = document.getElementById('confirmPassword');

            if (checkbox && checkbox.checked) {
                passwordSection.style.display = 'block';
                passwordInput.required = true;
                confirmPasswordInput.required = true;
            } else {
                passwordSection.style.display = 'none';
                passwordInput.required = false;
                confirmPasswordInput.required = false;
                passwordInput.value = '';
                confirmPasswordInput.value = '';
                // Limpiar indicadores de fortaleza
                document.getElementById('passwordStrength').style.width = '0';
                document.getElementById('passwordMessage').textContent = '';
            }
        }

        // Validar fortaleza de contraseña
        function validarFortalezaPassword() {
            const password = document.getElementById('password').value;
            const strengthBar = document.getElementById('passwordStrength');
            const message = document.getElementById('passwordMessage');

            if (!password) {
                strengthBar.style.width = '0';
                message.textContent = '';
                return;
            }

            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^a-zA-Z0-9]/.test(password)) strength++;

            if (strength <= 2) {
                strengthBar.style.backgroundColor = '#dc3545';
                strengthBar.style.width = '33%';
                message.textContent = 'Contraseña débil';
                message.style.color = '#dc3545';
            } else if (strength <= 4) {
                strengthBar.style.backgroundColor = '#ffc107';
                strengthBar.style.width = '66%';
                message.textContent = 'Contraseña media';
                message.style.color = '#ffc107';
            } else {
                strengthBar.style.backgroundColor = '#28a745';
                strengthBar.style.width = '100%';
                message.textContent = 'Contraseña fuerte';
                message.style.color = '#28a745';
            }
        }

        // Validar formulario antes de enviar
        function validarFormulario() {
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            const cambiarPasswordCheckbox = document.getElementById('cambiarPassword');

            // Validar contraseñas si:
            // 1. Estamos creando (no hay checkbox)
            // 2. Estamos editando Y el checkbox está marcado
            const debeValidarPassword = !cambiarPasswordCheckbox || cambiarPasswordCheckbox.checked;

            if (debeValidarPassword && password && confirmPassword) {
                // Solo validar si hay valor en el campo de contraseña
                if (password.value || confirmPassword.value) {
                    if (password.value !== confirmPassword.value) {
                        alert('⚠️ Las contraseñas no coinciden\n\nPor favor verifica que ambas contraseñas sean iguales.');
                        return false;
                    }

                    if (password.value.length < 6) {
                        alert('⚠️ Contraseña muy corta\n\nLa contraseña debe tener al menos 6 caracteres.');
                        return false;
                    }

                    // Validar que no sea muy débil
                    if (password.value.length < 8) {
                        if (!confirm('⚠️ La contraseña es corta\n\nSe recomienda usar al menos 8 caracteres.\n\n¿Deseas continuar de todas formas?')) {
                            return false;
                        }
                    }
                }
            }

            // Validar email
            const email = document.getElementById('email');
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email.value)) {
                alert('⚠️ Email inválido\n\nPor favor ingresa un email válido (ej: usuario@ejemplo.com)');
                return false;
            }

            return true;
        }

        // Resaltar opción de rol seleccionada
        document.querySelectorAll('input[name="rol"]').forEach(radio => {
            radio.addEventListener('change', function() {
                document.querySelectorAll('input[name="rol"]').forEach(r => {
                    const div = r.nextElementSibling;
                    if (r.checked) {
                        div.style.borderColor = '#e50914';
                        div.style.backgroundColor = 'rgba(229, 9, 20, 0.1)';
                    } else {
                        div.style.borderColor = 'var(--secondary-color)';
                        div.style.backgroundColor = 'var(--surface-color)';
                    }
                });
            });

            // Aplicar estilo inicial
            if (radio.checked) {
                const div = radio.nextElementSibling;
                div.style.borderColor = '#e50914';
                div.style.backgroundColor = 'rgba(229, 9, 20, 0.1)';
            }
        });
    </script>
</body>
</html>

