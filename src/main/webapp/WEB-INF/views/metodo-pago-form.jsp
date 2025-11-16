<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${empty metodoPago.id ? 'Agregar' : 'Editar'} Método de Pago - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <script>window.APP_CTX='${pageContext.request.contextPath}';</script>
</head>
<body>
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />

<div class="form-container">
    <div class="form-header">
        <h1>${empty metodoPago.id ? '&#10133; Agregar' : '&#9998; Editar'} Método de Pago</h1>
        <p style="color: var(--muted-text);">Complete los datos de su método de pago</p>
    </div>

    <form action="${pageContext.request.contextPath}/metodos-pago/guardar" method="post" id="paymentForm">
        <input type="hidden" name="id" value="${metodoPago.id}" />

        <div class="form-group">
            <label for="tipo">Tipo de Método de Pago <span class="required">*</span></label>
            <select id="tipo" name="tipo" required onchange="updateConditionalFields()">
                <option value="">Seleccione un tipo</option>
                <c:forEach var="tipo" items="${tipos}">
                    <option value="${tipo}" ${metodoPago.tipo == tipo ? 'selected' : ''}>
                        <c:choose>
                            <c:when test="${tipo == 'TARJETA_CREDITO'}">Tarjeta de Crédito</c:when>
                            <c:when test="${tipo == 'TARJETA_DEBITO'}">Tarjeta de Débito</c:when>
                            <c:when test="${tipo == 'MERCADOPAGO'}">MercadoPago</c:when>
                            <c:when test="${tipo == 'PAYPAL'}">PayPal</c:when>
                            <c:when test="${tipo == 'TRANSFERENCIA'}">Transferencia Bancaria</c:when>
                            <c:when test="${tipo == 'EFECTIVO'}">Efectivo</c:when>
                            <c:otherwise>${tipo}</c:otherwise>
                        </c:choose>
                    </option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <label for="alias">Alias <span class="required">*</span></label>
            <input type="text" id="alias" name="alias" value="${metodoPago.alias}"
                   placeholder="Ej: Mi Visa Principal" required maxlength="100" />
            <small>Un nombre para identificar este método de pago</small>
        </div>

        <!-- Campos para Tarjeta -->
        <div id="tarjetaFields" class="conditional-fields">
            <h3 style="margin-top: 0; margin-bottom: 15px;">Datos de la Tarjeta</h3>

            <div class="form-group">
                <label for="titular">Titular de la Tarjeta <span class="required">*</span></label>
                <input type="text" id="titular" name="titular" value="${metodoPago.titular}"
                       placeholder="Nombre como aparece en la tarjeta" maxlength="255" />
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="tipoTarjeta">Tipo de Tarjeta</label>
                    <select id="tipoTarjeta" name="tipoTarjeta">
                        <option value="">Seleccione</option>
                        <c:forEach var="tipoT" items="${tiposTarjeta}">
                            <option value="${tipoT}" ${metodoPago.tipoTarjeta == tipoT ? 'selected' : ''}>
                                ${tipoT}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label for="numeroTarjeta">Últimos 4 Dígitos <span class="required">*</span></label>
                    <input type="text" id="numeroTarjeta" name="numeroTarjeta"
                           value="${metodoPago.numeroTarjeta}"
                           placeholder="1234" maxlength="4" pattern="[0-9]{4}" />
                </div>
            </div>

            <div class="form-group">
                <label for="fechaVencimiento">Fecha de Vencimiento</label>
                <input type="text" id="fechaVencimiento" name="fechaVencimiento"
                       value="${metodoPago.fechaVencimiento}"
                       placeholder="MM/YYYY" maxlength="7" pattern="(0[1-9]|1[0-2])/20[0-9]{2}" />
                <small>Formato: MM/YYYY</small>
            </div>
        </div>

        <!-- Campos para Plataformas Digitales -->
        <div id="plataformaFields" class="conditional-fields">
            <h3 style="margin-top: 0; margin-bottom: 15px;">Datos de la Plataforma</h3>

            <div class="form-group">
                <label for="emailPlataforma">Email de la Cuenta</label>
                <input type="email" id="emailPlataforma" name="emailPlataforma"
                       value="${metodoPago.emailPlataforma}"
                       placeholder="usuario@ejemplo.com" maxlength="255" />
            </div>
        </div>

        <div class="form-group checkbox-group">
            <input type="checkbox" id="preferido" name="preferido"
                   ${metodoPago.preferido ? 'checked' : ''} value="true" />
            <label for="preferido" style="margin: 0;">Marcar como método de pago preferido</label>
        </div>

        <div class="form-group checkbox-group">
            <input type="checkbox" id="activo" name="activo"
                   ${empty metodoPago.id || metodoPago.activo ? 'checked' : ''} value="true" />
            <label for="activo" style="margin: 0;">Método de pago activo</label>
        </div>

        <div class="form-actions">
            <a href="${pageContext.request.contextPath}/metodos-pago" class="btn btn-secondary">
                &#10006; Cancelar
            </a>
            <button type="submit" class="btn btn-primary">
                &#10004; ${empty metodoPago.id ? 'Agregar' : 'Guardar Cambios'}
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp" />

<script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>

