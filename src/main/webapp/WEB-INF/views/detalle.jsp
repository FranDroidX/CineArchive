<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>Detalle - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <script>window.APP_CTX='${pageContext.request.contextPath}';</script>
</head>
<body class="detail-page">
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />
<div class="container">
    <div class="detail-container" data-contenido-id="${contenido.id}" data-usuario-id="${usuarioLogueado != null ? usuarioLogueado.id : ''}">
        <div class="detail-hero">
            <c:choose>
                <c:when test="${empty contenido.imagenUrl}">
                    <c:url var="imgDetalle" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/>
                </c:when>
                <c:when test="${fn:startsWith(contenido.imagenUrl, 'http')}">
                    <c:set var="imgDetalle" value="${contenido.imagenUrl}"/>
                </c:when>
                <c:otherwise>
                    <c:url var="imgDetalle" value="${contenido.imagenUrl}"/>
                </c:otherwise>
            </c:choose>
            <img src="${imgDetalle}" alt="${contenido.titulo}" class="detail-poster" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
            <div class="detail-info">
                <h1>${contenido.titulo}</h1>
                <div class="detail-meta">
                    <span class="badge">${contenido.genero}</span>
                    <span>•</span>
                    <c:if test="${not empty contenido.duracion}">
                        <span>${contenido.duracion} min</span>
                        <span>•</span>
                    </c:if>
                    <c:if test="${not empty contenido.anio}">
                        <span>${contenido.anio}</span>
                        <span>•</span>
                    </c:if>
                    <span class="rating-large">★★★★★</span>
                </div>
                <div class="rental-section">
                    <c:choose>
                        <c:when test="${alquilerExpirado}">
                            <div class="availability" style="margin:0 0 15px 0;">
                                <p style="margin:0; font-size:18px; font-weight:bold; color:var(--warning-color);">⚠️ Alquiler Expirado</p>
                                <p style="margin:8px 0 12px 0; color:#aaa; font-size:13px;">Tu alquiler ha vencido. Puedes renovarlo para seguir disfrutando de este contenido.</p>
                                <div style="display:flex; gap:10px;">
                                    <button class="rent-btn-large" style="flex:1;" onclick="window.location.href='${pageContext.request.contextPath}/mis-alquileres'">Ver mis alquileres</button>
                                </div>
                            </div>

                            <!-- Alerta si no hay métodos de pago activos -->
                            <c:if test="${empty metodosPago}">
                                <div class="alert alert-danger" style="margin: 20px 0; padding: 15px; background: rgba(220, 53, 69, 0.15); border: 1px solid #dc3545; border-radius: 8px;">
                                    <strong>&#9888; Método de pago requerido</strong>
                                    <p style="margin: 8px 0 12px 0;">Debes agregar al menos un método de pago activo para poder extender tu alquiler.</p>
                                    <a href="${pageContext.request.contextPath}/metodos-pago/nuevo"
                                       class="btn-primary"
                                       style="display: inline-block; padding: 10px 20px; background: var(--primary-color); color: white; text-decoration: none; border-radius: 6px; font-weight: bold;">
                                        &#128179; Agregar Método de Pago
                                    </a>
                                </div>
                            </c:if>

                            <h3 style="margin:24px 0 12px 0; color:var(--text-color);">&#128257; Extender Alquiler</h3>
                            <form action="${pageContext.request.contextPath}/alquilar" method="post">
                                <input type="hidden" name="contenidoId" value="${contenido.id}" />
                                <div class="rental-options">
                                    <div class="rental-option">
                                        <input type="radio" name="periodo" id="rental3ext" value="3" checked ${empty metodosPago ? 'disabled' : ''} />
                                        <label for="rental3ext">
                                            <span class="rental-duration">3 días</span>
                                            <span class="rental-price-large">
                                                <c:if test="${not empty contenido.precioAlquiler}">$<fmt:formatNumber value="${contenido.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                            </span>
                                        </label>
                                    </div>
                                    <div class="rental-option">
                                        <input type="radio" name="periodo" id="rental7ext" value="7" ${empty metodosPago ? 'disabled' : ''} />
                                        <label for="rental7ext">
                                            <span class="rental-duration">7 días</span>
                                            <span class="rental-price-large">
                                                <c:if test="${not empty contenido.precioAlquiler}">$<fmt:formatNumber value="${contenido.precioAlquiler * 2.33}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                            </span>
                                        </label>
                                    </div>
                                </div>
                                <div class="payment-method">
                                    <label for="metodoPagoExt">Método de pago</label>
                                    <c:choose>
                                        <c:when test="${not empty metodosPago}">
                                            <select id="metodoPagoExt" name="metodoPagoId" required>
                                                <c:forEach var="mp" items="${metodosPago}">
                                                    <option value="${mp.id}" ${mp.preferido ? 'selected' : ''}>
                                                        ${mp.descripcion}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </c:when>
                                        <c:otherwise>
                                            <select id="metodoPagoExt" name="metodoPago" disabled>
                                                <option value="">Seleccione un método de pago</option>
                                            </select>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <button class="rent-btn-large" type="submit" ${empty metodosPago ? 'disabled' : ''}
                                        style="${empty metodosPago ? 'opacity: 0.5; cursor: not-allowed;' : ''}">
                                    &#128257; Extender Alquiler
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${alquilado}">
                            <div class="availability" style="margin:0 0 15px 0;">
                                <p style="margin:0; font-size:18px; font-weight:bold; color:var(--success-color);">✔ Alquilado
                                    <c:if test="${not empty diasRestantes && diasRestantes le 0}"><span class="badge-expirado">Por vencer</span></c:if>
                                </p>
                                <c:if test="${not empty segundosRestantes}"><p class="rental-time"><span id="detalle-tiempo-restante" data-segundos="${segundosRestantes}">Actualizando...</span></p></c:if>
                                <c:if test="${not empty fechaFinDate}"><p style="margin:2px 0 10px 0; color:#aaa; font-size:13px;">Vence: <fmt:formatDate value="${fechaFinDate}" pattern="dd/MM/yyyy HH:mm"/></p></c:if>
                                <button class="btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/mis-alquileres#cont-${contenido.id}'">Ver estado de mi alquiler</button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Alerta si no hay métodos de pago activos -->
                            <c:if test="${empty metodosPago}">
                                <div class="alert alert-danger" style="margin-bottom: 20px; padding: 15px; background: rgba(220, 53, 69, 0.15); border: 1px solid #dc3545; border-radius: 8px;">
                                    <strong>&#9888; Método de pago requerido</strong>
                                    <p style="margin: 8px 0 12px 0;">Debes agregar al menos un método de pago activo para poder alquilar contenido.</p>
                                    <a href="${pageContext.request.contextPath}/metodos-pago/nuevo"
                                       class="btn-primary"
                                       style="display: inline-block; padding: 10px 20px; background: var(--primary-color); color: white; text-decoration: none; border-radius: 6px; font-weight: bold;">
                                        &#128179; Agregar Método de Pago
                                    </a>
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/alquilar" method="post" id="formAlquilar">
                                <input type="hidden" name="contenidoId" value="${contenido.id}" />
                                <div class="rental-options">
                                    <div class="rental-option">
                                        <input type="radio" name="periodo" id="rental3" value="3" checked ${empty metodosPago ? 'disabled' : ''} />
                                        <label for="rental3">
                                            <span class="rental-duration">3 días</span>
                                            <span class="rental-price-large">
                                                <c:if test="${not empty contenido.precioAlquiler}">$<fmt:formatNumber value="${contenido.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                            </span>
                                        </label>
                                    </div>
                                    <div class="rental-option">
                                        <input type="radio" name="periodo" id="rental7" value="7" ${empty metodosPago ? 'disabled' : ''} />
                                        <label for="rental7">
                                            <span class="rental-duration">7 días</span>
                                            <span class="rental-price-large">
                                                <c:if test="${not empty contenido.precioAlquiler}">$<fmt:formatNumber value="${contenido.precioAlquiler * 2.33}" minFractionDigits="2" maxFractionDigits="2"/></c:if>
                                            </span>
                                        </label>
                                    </div>
                                </div>
                                <div class="payment-method">
                                    <label for="metodoPago">Método de pago</label>
                                    <c:choose>
                                        <c:when test="${not empty metodosPago}">
                                            <select id="metodoPago" name="metodoPagoId" required>
                                                <c:forEach var="mp" items="${metodosPago}">
                                                    <option value="${mp.id}" ${mp.preferido ? 'selected' : ''}>
                                                        ${mp.descripcion}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <small style="display:block; margin-top:8px; color:#aaa;">
                                                <a href="${pageContext.request.contextPath}/metodos-pago" style="color:var(--primary-color);">Gestionar métodos de pago</a>
                                            </small>
                                        </c:when>
                                        <c:otherwise>
                                            <select id="metodoPago" name="metodoPago" disabled>
                                                <option value="">Seleccione un método de pago</option>
                                            </select>
                                            <small style="display:block; margin-top:8px; color:#ff6b7a;">
                                                &#128179; <a href="${pageContext.request.contextPath}/metodos-pago/nuevo" style="color:var(--primary-color);">Agrega tu método de pago</a> para continuar
                                            </small>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <button class="rent-btn-large" type="submit" ${empty metodosPago ? 'disabled' : ''}
                                        style="${empty metodosPago ? 'opacity: 0.5; cursor: not-allowed;' : ''}">
                                    &#127916; Alquilar ahora
                                </button>
                            </form>
                            <div class="action-buttons">
                                <div class="list-actions" style="width:100%; display:flex; gap:8px;">
                                    <button class="btn-link" data-list="mi-lista" data-contenido="${contenido.id}" onclick="toggleListState(${contenido.id}, 'mi-lista', this)">
                                        <span class="label-default">Mi Lista</span>
                                        <span class="label-add">Agregar</span>
                                        <span class="label-added">✔ Agregado</span>
                                        <span class="label-remove">✖ Quitar</span>
                                    </button>
                                    <button class="btn-link" data-list="para-ver" data-contenido="${contenido.id}" onclick="toggleListState(${contenido.id}, 'para-ver', this)">
                                        <span class="label-default">Para Ver</span>
                                        <span class="label-add">Agregar</span>
                                        <span class="label-added">✔ Agregado</span>
                                        <span class="label-remove">✖ Quitar</span>
                                    </button>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="detail-synopsis">
                    <h3>Sinopsis</h3>
                    <p>${contenido.descripcion}</p>
                </div>
                <div class="reviews-section">
                    <h2>✍️ Reseñas de Usuarios</h2>
                    <div id="reviews-stats" style="margin:8px 0 16px 0; color:#bbb;">
                        Calificación promedio: <strong><span id="avg-rating">-</span></strong>
                        (<span id="review-count">0</span> reseñas)
                    </div>
                    <div class="review-form">
                        <h3>Escribe tu reseña</h3>
                        <div class="rating-input" style="margin:8px 0; display:flex; gap:10px; align-items:center;">
                            <label for="review-rating" style="color:#ccc;">Tu calificación:</label>
                            <select id="review-rating">
                                <option value="5">5 - Excelente</option>
                                <option value="4">4 - Muy buena</option>
                                <option value="3">3 - Buena</option>
                                <option value="2">2 - Regular</option>
                                <option value="1" selected>1 - Mala</option>
                            </select>
                        </div>
                        <input type="text" id="review-title" placeholder="Título de tu reseña" maxlength="100" style="width:100%;padding:10px;margin:6px 0;border-radius:6px;border:1px solid #333;background:#111;color:#eee;" />
                        <textarea id="review-text" placeholder="Comparte tu opinión sobre esta película o serie..." maxlength="2000" style="width:100%;min-height:90px;padding:10px;border-radius:6px;border:1px solid #333;background:#111;color:#eee;"></textarea>
                        <div style="display:flex; gap:10px; align-items:center;">
                            <button id="review-submit" class="btn-primary" type="button">Publicar Reseña</button>
                            <span id="review-msg" style="font-size:12px;color:#aaa;"></span>
                        </div>
                    </div>
                    <div id="reviews-list" style="margin-top:20px; display:flex; flex-direction:column; gap:12px;"></div>
                </div>
                <div class="detail-cast">
                    <h3>Información Adicional</h3>
                    <p><strong>Director:</strong> <c:out value="${not empty contenido.director ? contenido.director : 'N/D'}"/></p>
                    <c:if test="${contenido.tipo == 'SERIE' && not empty seasons}">
                        <p><strong>Temporadas:</strong> ${fn:length(seasons)}</p>
                        <ul style="margin:6px 0 12px 16px; padding:0; list-style:none;">
                            <!-- TODO: ordenar temporadas por número extraído del título si el orden alfabético no coincide. -->
                            <c:forEach var="s" items="${seasons}">
                                <c:set var="isCurrent" value="${s.id == contenido.id}"/>
                                <li style="margin:4px 0;">
                                    <button type="button" onclick="window.location.href='${pageContext.request.contextPath}/contenido/${s.id}'" style="display:inline-block;padding:6px 10px;border:1px solid ${isCurrent ? '#28a745' : '#333'};border-radius:6px;font-size:12px;text-decoration:none;color:${isCurrent ? '#28a745' : '#ccc'};background:${isCurrent ? 'rgba(40,167,69,0.15)' : 'transparent'};cursor:pointer;position:relative;">
                                        ${s.titulo} ${isCurrent ? '✔' : ''}
                                        <c:if test="${seasonActiveMap[s.id]}">
                                            <span style="position:absolute;top:-6px;right:-6px;background:var(--success-color);color:#fff;padding:2px 6px;border-radius:12px;font-size:10px;">Alquilada</span>
                                        </c:if>
                                    </button>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:if>
                    <c:if test="${contenido.capitulosTotales != null && contenido.capitulosTotales > 0}">
                        <p><strong>Capítulos totales:</strong> ${contenido.capitulosTotales}</p>
                    </c:if>
                    <c:if test="${contenido.enEmision != null}">
                        <p><strong>En emisión:</strong> <span>${contenido.enEmision ? 'Sí' : 'No'}</span></p>
                    </c:if>
                </div>
                <div class="availability">
                    <p>✅ <strong>${contenido.disponibleParaAlquiler ? 'Disponible para alquiler' : 'No disponible'}</strong></p>
                    <p>${contenido.copiasDisponibles} copias disponibles • Alta calidad</p>
                </div>
                <c:if test="${not empty contenido.trailerUrl}">
                    <section class="admin-section" style="margin-top:30px;">
                        <h2>🎥 Tráiler Oficial</h2>
                        <div style="background:#000;padding:20px;border-radius:10px;text-align:center;">
                            <iframe src="${contenido.trailerUrl}" style="width:100%;height:420px;border:0;border-radius:8px;" allowfullscreen loading="lazy" title="Trailer"></iframe>
                        </div>
                    </section>
                </c:if>
                <c:if test="${not empty relacionados}">
                    <section class="category">
                        <h2>🎬 Contenido Relacionado</h2>
                        <div class="detail-slide-viewport">
                            <div class="movie-row detail-slide no-select" aria-label="Contenido relacionado">
                                <c:forEach var="r" items="${relacionados}">
                                    <div class="movie-card">
                                        <c:choose>
                                            <c:when test="${empty r.imagenUrl}">
                                                <c:url var="rImg" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/>
                                            </c:when>
                                            <c:when test="${fn:startsWith(r.imagenUrl, 'http')}" >
                                                <c:set var="rImg" value="${r.imagenUrl}"/>
                                            </c:when>
                                            <c:otherwise>
                                                <c:url var="rImg" value="${r.imagenUrl}"/>
                                            </c:otherwise>
                                        </c:choose>
                                        <img loading="lazy" src="${rImg}" alt="${r.titulo}" draggable="false" ondragstart="return false;" />
                                        <div class="movie-info">
                                            <div class="movie-title">${r.titulo}</div>
                                            <div class="movie-rating">★★★★★</div>
                                            <div class="movie-actions">
                                                <button class="btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/contenido/${r.id}'">Ver detalles</button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </section>
                </c:if>
                <c:if test="${not empty masDelDirector}">
                    <section class="category">
                        <h2>🎬 <c:choose><c:when test="${not empty contenido.director}">Más de ${contenido.director}</c:when><c:otherwise>Más del Director</c:otherwise></c:choose></h2>
                        <div class="detail-slide-viewport">
                            <div class="movie-row detail-slide no-select" aria-label="Más del director">
                                <c:forEach var="d" items="${masDelDirector}">
                                    <div class="movie-card">
                                        <c:choose>
                                            <c:when test="${empty d.imagenUrl}">
                                                <c:url var="dImg" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/>
                                            </c:when>
                                            <c:when test="${fn:startsWith(d.imagenUrl, 'http')}" >
                                                <c:set var="dImg" value="${d.imagenUrl}"/>
                                            </c:when>
                                            <c:otherwise>
                                                <c:url var="dImg" value="${d.imagenUrl}"/>
                                            </c:otherwise>
                                        </c:choose>
                                        <img loading="lazy" src="${dImg}" alt="${d.titulo}" draggable="false" ondragstart="return false;" />
                                        <div class="movie-info">
                                            <div class="movie-title">${d.titulo}</div>
                                            <div class="movie-rating">★★★★★</div>
                                            <div class="movie-actions">
                                                <button class="btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/contenido/${d.id}'">Ver detalles</button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </section>
                </c:if>
            </div>
        </div>
    </div>
</div>
<jsp:include page="/WEB-INF/views/fragments/footer.jsp" />
<script src="${pageContext.request.contextPath}/js/alquiler.js"></script>
<script src="${pageContext.request.contextPath}/js/listas.js"></script>
<script src="${pageContext.request.contextPath}/js/resenas.js"></script>
<script>
(function(){
  function formatearTiempoRestante(segundos) {
    if (segundos < 0) {
      var segsPositivos = Math.abs(segundos);
      var dias = Math.floor(segsPositivos / 86400);
      var horas = Math.floor((segsPositivos % 86400) / 3600);
      var minutos = Math.floor((segsPositivos % 3600) / 60);
      if (dias > 0) return 'Expirado hace ' + dias + ' día' + (dias != 1 ? 's' : '');
      if (horas > 0) return 'Expirado hace ' + horas + ' hora' + (horas != 1 ? 's' : '');
      if (minutos > 0) return 'Expirado hace ' + minutos + ' minuto' + (minutos != 1 ? 's' : '');
      return 'Expirado hace ' + segsPositivos + ' segundo' + (segsPositivos != 1 ? 's' : '');
    } else {
      var diasPos = Math.floor(segundos / 86400);
      var horasPos = Math.floor((segundos % 86400) / 3600);
      var minutosPos = Math.floor((segundos % 3600) / 60);
      var segs = segundos % 60;
      if (diasPos > 0) return 'Restan ' + diasPos + ' día' + (diasPos != 1 ? 's' : '');
      if (horasPos > 0) return 'Restan ' + horasPos + ' hora' + (horasPos != 1 ? 's' : '');
      if (minutosPos > 0) return 'Restan ' + minutosPos + ' minuto' + (minutosPos != 1 ? 's' : '');
      return 'Restan ' + segs + ' segundo' + (segs != 1 ? 's' : '');
    }
  }
  function tick(){
    var span = document.getElementById('detalle-tiempo-restante');
    if (!span) return;
    var segIni = parseInt(span.getAttribute('data-segundos'),10);
    if (isNaN(segIni)) return;
    if (span._ts0 == null) span._ts0 = Date.now();
    var trans = Math.floor((Date.now() - span._ts0)/1000);
    span.textContent = formatearTiempoRestante(segIni - trans);
  }
  document.addEventListener('DOMContentLoaded', function(){
    tick();
    setInterval(tick, 1000);
  });
})();
</script>
</body>
</html>
