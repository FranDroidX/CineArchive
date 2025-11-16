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
</head>
<body>
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />

<div class="payment-methods-container">
    <div class="page-header">
        <h1>&#128179; Mis Métodos de Pago</h1>
    </div>

    <c:if test="${not empty metodosPago}">
        <div style="margin-top: 30px; margin-bottom: 30px; text-align: center;">
            <a href="${pageContext.request.contextPath}/metodos-pago/nuevo" class="btn-add-payment">
                <span>+</span> Agregar Método de Pago
            </a>
        </div>
    </c:if>

    <c:if test="${not empty msg}">
        <div class="alert alert-success">${msg}</div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-error">${error}</div>
    </c:if>

    <c:choose>
        <c:when test="${empty metodosPago}">
            <div class="empty-state">
                <div class="empty-state-icon">&#128179;</div>
                <h2>No tienes métodos de pago registrados</h2>
                <p>Agrega un método de pago para facilitar tus futuros alquileres</p>
                <a href="${pageContext.request.contextPath}/metodos-pago/nuevo" class="btn-add-payment" style="margin-top: 20px;">
                    <span>+</span> Agregar Método de Pago
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
                                            <c:when test="${mp.tipo == 'TARJETA_CREDITO' || mp.tipo == 'TARJETA_DEBITO'}">&#128179;</c:when>
                                            <c:when test="${mp.tipo == 'MERCADOPAGO'}">&#128309;</c:when>
                                            <c:when test="${mp.tipo == 'PAYPAL'}">&#127359;</c:when>
                                            <c:when test="${mp.tipo == 'TRANSFERENCIA'}">&#127974;</c:when>
                                            <c:when test="${mp.tipo == 'EFECTIVO'}">&#128181;</c:when>
                                            <c:otherwise>&#128176;</c:otherwise>
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
                                    <span class="preferred-badge">&#11088; Preferido</span>
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
                                        <c:if test="${not empty mp.tipoTarjeta}">${mp.tipoTarjeta} </c:if>**** **** **** ${mp.numeroTarjeta}
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
                                    <button type="submit" class="btn-action btn-primary-action">&#11088; Preferido</button>
                                </form>
                            </c:if>

                            <a href="${pageContext.request.contextPath}/metodos-pago/editar/${mp.id}" class="btn-action btn-secondary-action" style="text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center;">
                                &#9998; Editar
                            </a>

                            <c:choose>
                                <c:when test="${mp.activo}">
                                    <form action="${pageContext.request.contextPath}/metodos-pago/desactivar/${mp.id}" method="post" style="flex: 1;">
                                        <button type="submit" class="btn-action btn-secondary-action">&#10060; Desactivar</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/metodos-pago/eliminar/${mp.id}" method="post" style="flex: 1;" onsubmit="return confirm('¿Está seguro que desea eliminar este método de pago?');">
                                        <button type="submit" class="btn-action btn-danger-action">&#128465; Eliminar</button>
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

