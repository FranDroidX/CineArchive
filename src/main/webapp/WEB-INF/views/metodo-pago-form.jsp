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
    <style>
        .form-container {
            max-width: 700px;
            margin: 40px auto;
            padding: 30px;
            background: var(--card-bg);
            border-radius: 12px;
            border: 1px solid var(--border-color);
        }

        .form-header {
            margin-bottom: 30px;
        }

        .form-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: var(--text-color);
            font-weight: 500;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px;
            background: var(--secondary-bg);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-color);
            font-size: 15px;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--primary-color);
        }

        .form-group small {
            display: block;
            margin-top: 5px;
            color: var(--muted-text);
            font-size: 13px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .conditional-fields {
            display: none;
            margin-top: 15px;
            padding: 20px;
            background: rgba(0,0,0,0.2);
            border-radius: 8px;
        }

        .conditional-fields.active {
            display: block;
        }

        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .checkbox-group input[type="checkbox"] {
            width: auto;
            cursor: pointer;
        }

        .form-actions {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 14px 24px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-hover);
        }

        .btn-secondary {
            background: var(--secondary-bg);
            color: var(--text-color);
        }

        .btn-secondary:hover {
            background: #444;
        }

        .required {
            color: #dc3545;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />

<div class="form-container">
    <div class="form-header">
        <h1>${empty metodoPago.id ? '➕ Agregar' : '✏️ Editar'} Método de Pago</h1>
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
                ✖ Cancelar
            </a>
            <button type="submit" class="btn btn-primary">
                ✔ ${empty metodoPago.id ? 'Agregar' : 'Guardar Cambios'}
            </button>
        </div>
    </form>
</div>

<jsp:include page="/WEB-INF/views/fragments/footer.jsp" />

<script>
function updateConditionalFields() {
    const tipo = document.getElementById('tipo').value;
    const tarjetaFields = document.getElementById('tarjetaFields');
    const plataformaFields = document.getElementById('plataformaFields');

    // Ocultar todos
    tarjetaFields.classList.remove('active');
    plataformaFields.classList.remove('active');

    // Mostrar según tipo
    if (tipo === 'TARJETA_CREDITO' || tipo === 'TARJETA_DEBITO') {
        tarjetaFields.classList.add('active');
        // Hacer campos requeridos
        document.getElementById('titular').required = true;
        document.getElementById('numeroTarjeta').required = true;
    } else if (tipo === 'MERCADOPAGO' || tipo === 'PAYPAL') {
        plataformaFields.classList.add('active');
        // Quitar requeridos de tarjeta
        document.getElementById('titular').required = false;
        document.getElementById('numeroTarjeta').required = false;
    } else {
        // Quitar requeridos
        document.getElementById('titular').required = false;
        document.getElementById('numeroTarjeta').required = false;
    }
}

// Llamar al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    updateConditionalFields();
});

// Formatear fecha de vencimiento automáticamente
document.getElementById('fechaVencimiento').addEventListener('input', function(e) {
    let value = e.target.value.replace(/\D/g, '');
    if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 6);
    }
    e.target.value = value;
});

// Validar solo números en últimos 4 dígitos
document.getElementById('numeroTarjeta').addEventListener('input', function(e) {
    e.target.value = e.target.value.replace(/\D/g, '').substring(0, 4);
});
</script>
</body>
</html>

