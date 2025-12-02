<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>Mi Perfil - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .profile-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 40px;
            background: var(--surface-color);
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
        }

        .profile-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .profile-title {
            color: var(--primary-color);
            font-size: 28px;
            margin-bottom: 10px;
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            background: var(--primary-color);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: white;
            font-size: 32px;
            font-weight: bold;
        }

        .profile-info {
            background: var(--background-color);
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 25px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid var(--secondary-color);
        }

        .info-row:last-child {
            border-bottom: none;
        }

        .info-label {
            font-weight: bold;
            color: var(--text-color);
            flex: 1;
        }

        .info-value {
            color: #aaa;
            flex: 2;
            text-align: right;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .status-active {
            background: rgba(34, 197, 94, 0.2);
            color: #4ade80;
            border: 1px solid rgba(34, 197, 94, 0.3);
        }

        .status-inactive {
            background: rgba(220, 38, 38, 0.2);
            color: #ff6b6b;
            border: 1px solid rgba(220, 38, 38, 0.3);
        }

        .role-badge {
            padding: 4px 12px;
            border-radius: 5px;
            font-size: 12px;
            font-weight: bold;
            background: var(--primary-color);
            color: white;
        }

        .profile-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 24px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            transition: all 0.3s;
            border: 2px solid;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        .btn-primary:hover {
            background: #f40612;
            border-color: #f40612;
        }

        .btn-secondary {
            background: transparent;
            color: var(--text-color);
            border-color: var(--secondary-color);
        }

        .btn-secondary:hover {
            background: var(--secondary-color);
            border-color: var(--secondary-color);
        }

        .no-user-message {
            text-align: center;
            color: var(--text-color);
            font-size: 18px;
            margin: 50px 0;
        }

        .no-user-message h2 {
            color: var(--primary-color);
            margin-bottom: 15px;
        }

        /* Responsive para móviles */
        @media (max-width: 768px) {
            .profile-container {
                max-width: 100%;
                margin: 15px 10px;
                padding: 25px 20px;
                border-radius: 8px;
            }

            .profile-title {
                font-size: 24px;
            }

            .profile-avatar {
                width: 60px;
                height: 60px;
                font-size: 24px;
                margin-bottom: 15px;
            }

            .profile-info {
                padding: 15px;
            }

            .info-row {
                flex-direction: column;
                align-items: flex-start;
                padding: 10px 0;
                gap: 8px;
            }

            .info-label {
                font-size: 14px;
            }

            .info-value {
                text-align: left;
                font-size: 14px;
                word-break: break-word;
            }

            .profile-actions {
                flex-direction: column;
                gap: 10px;
                width: 100%;
            }

            .btn {
                width: 100%;
                padding: 12px 20px;
                text-align: center;
            }
        }

        @media (max-width: 480px) {
            .profile-container {
                margin: 10px 8px;
                padding: 20px 15px;
            }

            .profile-title {
                font-size: 20px;
            }

            .profile-avatar {
                width: 50px;
                height: 50px;
                font-size: 20px;
            }

            .profile-info {
                padding: 15px;
            }

            .info-row {
                padding: 8px 0;
            }

            .info-label,
            .info-value {
                font-size: 13px;
            }

            .status-badge,
            .role-badge {
                font-size: 11px;
                padding: 3px 10px;
            }

            .btn {
                padding: 10px 16px;
                font-size: 14px;
            }
        }

        @media (max-width: 360px) {
            .profile-container {
                margin: 10px 5px;
                padding: 18px 12px;
            }

            .profile-title {
                font-size: 18px;
            }

            .profile-header {
                margin-bottom: 20px;
            }

            .profile-info {
                padding: 12px;
            }

            .info-label,
            .info-value {
                font-size: 12px;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragments/header.jsp" />
    <div class="profile-container">
        <c:choose>
            <c:when test="${empty usuario}">
                <div class="no-user-message">
                    <h2>No hay usuario en sesión</h2>
                    <p>Por favor inicia sesión para ver tu perfil.</p>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                        Iniciar Sesión
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="profile-header">
                    <div class="profile-avatar">
                        ${usuario.nombre.substring(0, 1).toUpperCase()}
                    </div>
                    <h1 class="profile-title">Mi Perfil</h1>
                </div>

                <div class="profile-info">
                    <div class="info-row">
                        <span class="info-label">ID de Usuario:</span>
                        <span class="info-value">#${usuario.id}</span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">Nombre Completo:</span>
                        <span class="info-value">${usuario.nombre}</span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">Correo Electrónico:</span>
                        <span class="info-value">${usuario.email}</span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">Rol en el Sistema:</span>
                        <span class="info-value">
                            <span class="role-badge">
                                <c:choose>
                                    <c:when test="${usuario.rol == 'ADMINISTRADOR'}">Administrador</c:when>
                                    <c:when test="${usuario.rol == 'GESTOR_INVENTARIO'}">Gestor de Inventario</c:when>
                                    <c:when test="${usuario.rol == 'ANALISTA_DATOS'}">Analista de Datos</c:when>
                                    <c:otherwise>Usuario Regular</c:otherwise>
                                </c:choose>
                            </span>
                        </span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">Estado de la Cuenta:</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${usuario.activo}">
                                    <span class="status-badge status-active">Activa</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-inactive">Inactiva</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <div class="profile-actions">
                    <a href="${pageContext.request.contextPath}/catalogo" class="btn btn-primary">
                        Ir al Inicio
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-secondary">
                        Cerrar Sesión
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
    <jsp:include page="/WEB-INF/views/fragments/footer.jsp" />
</body>
</html>
