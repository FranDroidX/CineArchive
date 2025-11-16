<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mis Métodos de Pago - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <script>window.APP_CTX='${pageContext.request.contextPath}';</script>
    <style>
        .payment-methods-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .payment-methods-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .payment-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            position: relative;
            transition: all 0.3s ease;
        }

        .payment-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(0,0,0,0.3);
        }

        .payment-card.inactive {
            opacity: 0.6;
            background: var(--secondary-bg);
        }

        .payment-card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }

        .payment-type-icon {
            font-size: 32px;
            margin-right: 10px;
        }

        .payment-alias {
            font-size: 18px;
            font-weight: bold;
            color: var(--text-color);
            margin-bottom: 5px;
        }

        .payment-type {
            font-size: 13px;
            color: var(--muted-text);
        }

        .preferred-badge {
            background: var(--primary-color);
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }

        .inactive-badge {
            background: #666;
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
        }

        .payment-details {
            margin: 15px 0;
            padding: 15px 0;
            border-top: 1px solid var(--border-color);
            border-bottom: 1px solid var(--border-color);
        }

        .payment-detail-row {
            display: flex;
            justify-content: space-between;
            margin: 8px 0;
            font-size: 14px;
        }

        .payment-detail-label {
            color: var(--muted-text);
        }

        .payment-detail-value {
            color: var(--text-color);
            font-weight: 500;
        }

        .payment-actions {
            display: flex;
            gap: 8px;
            margin-top: 15px;
        }

        .btn-action {
            flex: 1;
            padding: 8px 12px;
            border: none;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-primary-action {
            background: var(--primary-color);
            color: white;
        }

        .btn-primary-action:hover {
            background: var(--primary-hover);
        }

        .btn-secondary-action {
            background: var(--secondary-bg);
            color: var(--text-color);
        }

        .btn-secondary-action:hover {
            background: #444;
        }

        .btn-danger-action {
            background: #dc3545;
            color: white;
        }

        .btn-danger-action:hover {
            background: #c82333;
        }

        .btn-add-payment {
            background: var(--primary-color);
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-add-payment:hover {
            background: var(--primary-hover);
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--muted-text);
        }

        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .alert-success {
            background: rgba(40, 167, 69, 0.2);
            border: 1px solid #28a745;
            color: #28a745;
        }

        .alert-error {
            background: rgba(220, 53, 69, 0.2);
            border: 1px solid #dc3545;
            color: #dc3545;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />

<div class="payment-methods-container">
    <div class="page-header">
        <h1>💳 Mis Métodos de Pago</h1>
        <a href="${pageContext.request.contextPath}/metodos-pago/nuevo" class="btn-add-payment">
            <span>+</span> Agregar Método de Pago
        </a>
    </div>

    <c:if test="${not empty msg}">
        <div class="alert alert-success">${msg}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <c:choose>
        <c:when test="${empty metodosPago}">
            <div class="empty-state">
                <div class="empty-state-icon">💳</div>
                <h2>No tienes métodos de pago registrados</h2>
                <p>Agrega un método de pago para facilitar tus futuros alquileres</p>
                <a href="${pageContext.request.contextPath}/metodos-pago/nuevo" class="btn-add-payment" style="margin-top: 20px;">
                    <span>+</span> Agregar Primer Método de Pago
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="payment-methods-grid">
                <c:forEach var="mp" items="${metodosPago}">
                    <div class="payment-card ${!mp.activo ? 'inactive' : ''}">
                        <div class="payment-card-header">
                            <div style="flex: 1;">
                                <div style="display: flex; align-items: center;">
                                    <span class="payment-type-icon">
                                        <c:choose>
                                            <c:when test="${mp.tipo == 'TARJETA_CREDITO' || mp.tipo == 'TARJETA_DEBITO'}">💳</c:when>
                                            <c:when test="${mp.tipo == 'MERCADOPAGO'}">🔵</c:when>
                                            <c:when test="${mp.tipo == 'PAYPAL'}">🅿️</c:when>
                                            <c:when test="${mp.tipo == 'TRANSFERENCIA'}">🏦</c:when>
                                            <c:when test="${mp.tipo == 'EFECTIVO'}">💵</c:when>
                                            <c:otherwise>💰</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <div>
                                        <div class="payment-alias">${mp.alias}</div>
                                        <div class="payment-type">
                                            <c:choose>
                                                <c:when test="${mp.tipo == 'TARJETA_CREDITO'}">Tarjeta de Crédito</c:when>
                                                <c:when test="${mp.tipo == 'TARJETA_DEBITO'}">Tarjeta de Débito</c:when>
                                                <c:otherwise>${fn:replace(mp.tipo, '_', ' ')}</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div>
                                <c:if test="${mp.preferido}">
                                    <span class="preferred-badge">⭐ Preferido</span>
                                </c:if>
                                <c:if test="${!mp.activo}">
                                    <span class="inactive-badge">Inactivo</span>
                                </c:if>
                            </div>
                        </div>

                        <div class="payment-details">
                            <c:if test="${not empty mp.titular}">
                                <div class="payment-detail-row">
                                    <span class="payment-detail-label">Titular:</span>
                                    <span class="payment-detail-value">${mp.titular}</span>
                                </div>
                            </c:if>

                            <c:if test="${not empty mp.numeroTarjeta}">
                                <div class="payment-detail-row">
                                    <span class="payment-detail-label">Número:</span>
                                    <span class="payment-detail-value">
                                        <c:if test="${not empty mp.tipoTarjeta}">${mp.tipoTarjeta}</c:if>
                                        **** **** **** ${mp.numeroTarjeta}
                                    </span>
                                </div>
                            </c:if>

                            <c:if test="${not empty mp.fechaVencimiento}">
                                <div class="payment-detail-row">
                                    <span class="payment-detail-label">Vencimiento:</span>
                                    <span class="payment-detail-value">${mp.fechaVencimiento}</span>
                                </div>
                            </c:if>

                            <c:if test="${not empty mp.emailPlataforma}">
                                <div class="payment-detail-row">
                                    <span class="payment-detail-label">Email:</span>
                                    <span class="payment-detail-value">${mp.emailPlataforma}</span>
                                </div>
                            </c:if>
                        </div>

                        <div class="payment-actions">
                            <c:if test="${mp.activo && !mp.preferido}">
                                <form action="${pageContext.request.contextPath}/metodos-pago/preferido/${mp.id}" method="post" style="flex: 1;">
                                    <button type="submit" class="btn-action btn-primary-action">⭐ Preferido</button>
                                </form>
                            </c:if>

                            <a href="${pageContext.request.contextPath}/metodos-pago/editar/${mp.id}" class="btn-action btn-secondary-action" style="text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center;">
                                ✏️ Editar
                            </a>

                            <c:choose>
                                <c:when test="${mp.activo}">
                                    <form action="${pageContext.request.contextPath}/metodos-pago/desactivar/${mp.id}" method="post" style="flex: 1;">
                                        <button type="submit" class="btn-action btn-secondary-action">🚫 Desactivar</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/metodos-pago/eliminar/${mp.id}" method="post" style="flex: 1;" onsubmit="return confirm('¿Está seguro que desea eliminar este método de pago?');">
                                        <button type="submit" class="btn-action btn-danger-action">🗑️ Eliminar</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp" />
</body>
</html>

