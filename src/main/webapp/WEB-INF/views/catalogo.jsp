<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>CineArchive - Catálogo</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <script>window.APP_CTX='${pageContext.request.contextPath}';</script>
</head>
<body>
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />
<div class="container">
    <section class="search-section">
        <form action="${pageContext.request.contextPath}/catalogo" method="get" id="searchForm">
            <div class="search-container">
                <label for="q" class="sr-only">Buscar</label>
                <input id="q" type="text" name="q" class="search-input" placeholder="Buscar películas, series, actores..." value="${query}" />
                <button type="submit" class="search-btn">🔍 Buscar</button>
            </div>
            <div class="filter-container">
                <label for="genero" class="sr-only">Género</label>
                <select id="genero" name="genero" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="" ${empty genero ? 'selected' : ''}>Todos los géneros</option>
                    <option value="accion" ${genero == 'accion' ? 'selected' : ''}>Acción</option>
                    <option value="comedia" ${genero == 'comedia' ? 'selected' : ''}>Comedia</option>
                    <option value="drama" ${genero == 'drama' ? 'selected' : ''}>Drama</option>
                    <option value="terror" ${genero == 'terror' ? 'selected' : ''}>Terror</option>
                    <option value="ciencia-ficcion" ${genero == 'ciencia-ficcion' ? 'selected' : ''}>Ciencia Ficción</option>
                    <option value="romance" ${genero == 'romance' ? 'selected' : ''}>Romance</option>
                    <option value="thriller" ${genero == 'thriller' ? 'selected' : ''}>Thriller</option>
                    <option value="animacion" ${genero == 'animacion' ? 'selected' : ''}>Animación</option>
                </select>
                <label for="tipo" class="sr-only">Tipo</label>
                <select id="tipo" name="tipo" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="" ${empty tipo ? 'selected' : ''}>Tipo de contenido</option>
                    <option value="PELICULA" ${tipo == 'PELICULA' ? 'selected' : ''}>Películas</option>
                    <option value="SERIE" ${tipo == 'SERIE' ? 'selected' : ''}>Series</option>
                </select>
                <label for="orden" class="sr-only">Orden</label>
                <select id="orden" name="orden" class="filter-select" onchange="document.getElementById('searchForm').submit()">
                    <option value="nombre" ${orden == 'nombre' ? 'selected' : ''}>Nombre A-Z</option>
                    <option value="fecha" ${orden == 'fecha' ? 'selected' : ''}>Más Reciente</option>
                </select>
                <!-- Tamaño fijo a 50 por página, se elimina selector -->
                <button type="button" class="btn-secondary" onclick="clearFilters()">Limpiar filtros</button>
            </div>
        </form>
        <div class="results-bar">
            <span class="results-count">${total} resultados</span>
            <c:if test="${totalPages > 1}"><span class="results-pages">Página ${page} de ${totalPages}</span></c:if>
        </div>
    </section>
    <section class="category">
        <h2>Resultados</h2>
        <div class="catalogo-slide-viewport">
            <div class="movie-row catalogo-slide no-select" id="catalogoRow" tabindex="0">
                <c:choose>
                    <c:when test="${not empty contenidos}">
                        <c:forEach var="c" items="${contenidos}">
                            <c:set var="estaAlquilado" value="${alquiladoMap[c.id]}"/>
                            <div class="movie-card" data-alquilado="${estaAlquilado}" data-expirado="${alquiladoMap[c.id] != null ? 'true' : 'false'}" data-contenido="${c.id}">
                                <c:choose>
                                    <c:when test="${empty c.imagenUrl}"><c:url var="imgSrc" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/></c:when>
                                    <c:when test="${fn:startsWith(c.imagenUrl, 'http')}"><c:set var="imgSrc" value="${c.imagenUrl}"/></c:when>
                                    <c:otherwise><c:url var="imgSrc" value="${c.imagenUrl}"/></c:otherwise>
                                </c:choose>
                                <img loading="lazy" src="${imgSrc}" alt="${c.titulo}" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
                                <div class="movie-info">
                                    <div class="movie-title">${c.titulo}</div>
                                    <div class="movie-rating">★★★★★</div>
                                    <div class="rental-price">
                                        <c:if test="${not empty c.precioAlquiler && !estaAlquilado}">$<fmt:formatNumber value="${c.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/> / 3 días</c:if>
                                    </div>
                                    <div class="movie-actions">
                                        <button class="rent-btn fade-in" data-action="rent" data-contenido="${c.id}" data-alquilado="${estaAlquilado ? 'true' : 'false'}" onclick="event.stopPropagation(); if(this.getAttribute('data-alquilado') !== 'true') rentNow(${c.id}); return false;">${estaAlquilado ? 'Alquilado' : 'Alquilar'}</button>
                                        <div class="list-actions">
                                            <button class="btn-link fade-in" data-list="mi-lista" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'mi-lista', this)">
                                                <span class="label-default">Mi Lista</span>
                                                <span class="label-add">Agregar</span>
                                                <span class="label-added">✔ Agregado</span>
                                                <span class="label-remove">✖ Quitar</span>
                                            </button>
                                            <button class="btn-link fade-in" data-list="para-ver" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'para-ver', this)">
                                                <span class="label-default">Para Ver</span>
                                                <span class="label-add">Agregar</span>
                                                <span class="label-added">✔ Agregado</span>
                                                <span class="label-remove">✖ Quitar</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise><p style="padding:20px;">No se encontraron contenidos para la búsqueda.</p></c:otherwise>
                </c:choose>
            </div>
        </div>
        <c:if test="${totalPages > 1}">
            <div class="pagination">
                <c:forEach var="p" begin="1" end="${totalPages}">
                    <c:url var="pageUrl" value="/catalogo">
                        <c:if test="${not empty query}"><c:param name="q" value="${query}"/></c:if>
                        <c:if test="${not empty genero}"><c:param name="genero" value="${genero}"/></c:if>
                        <c:if test="${not empty tipo}"><c:param name="tipo" value="${tipo}"/></c:if>
                        <c:if test="${not empty orden}"><c:param name="orden" value="${orden}"/></c:if>
                        <c:param name="page" value="${p}"/>
                    </c:url>
                    <a class="page-link ${p == page ? 'active' : ''}" href="${pageUrl}">${p}</a>
                </c:forEach>
            </div>
        </c:if>
    </section>
    <section class="category">
        <c:if test="${not empty novedades}">
            <h2>🆕 Novedades</h2>
            <div class="catalogo-slide-viewport">
                <div class="movie-row catalogo-slide no-select" aria-label="Novedades">
                    <c:forEach var="c" items="${novedades}">
                        <c:set var="estaAlquilado" value="${alquiladoMap[c.id]}"/>
                        <div class="movie-card" data-alquilado="${estaAlquilado}" data-expirado="${alquiladoMap[c.id] != null ? 'true' : 'false'}" data-contenido="${c.id}">
                            <c:choose>
                                <c:when test="${empty c.imagenUrl}"><c:url var="imgSrc" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/></c:when>
                                <c:when test="${fn:startsWith(c.imagenUrl, 'http')}"><c:set var="imgSrc" value="${c.imagenUrl}"/></c:when>
                                <c:otherwise><c:url var="imgSrc" value="${c.imagenUrl}"/></c:otherwise>
                            </c:choose>
                            <img loading="lazy" src="${imgSrc}" alt="${c.titulo}" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
                            <div class="movie-info">
                                <div class="movie-title">${c.titulo}</div>
                                <div class="movie-rating">★★★★★</div>
                                <div class="rental-price"><c:if test="${not empty c.precioAlquiler && !estaAlquilado}">$<fmt:formatNumber value="${c.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/> / 3 días</c:if></div>
                                <div class="movie-actions">
                                    <button class="rent-btn fade-in" data-contenido="${c.id}" data-alquilado="${estaAlquilado ? 'true' : 'false'}" onclick="event.stopPropagation(); if(this.getAttribute('data-alquilado') !== 'true') rentNow(${c.id}); return false;">${estaAlquilado ? 'Alquilado' : 'Alquilar'}</button>
                                    <div class="list-actions">
                                        <button class="btn-link fade-in" data-list="mi-lista" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'mi-lista', this)">
                                            <span class="label-default">Mi Lista</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                        <button class="btn-link fade-in" data-list="para-ver" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'para-ver', this)">
                                            <span class="label-default">Para Ver</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>
        <c:if test="${not empty populares}">
            <h2>🔥 Más Populares</h2>
            <div class="catalogo-slide-viewport">
                <div class="movie-row catalogo-slide no-select" aria-label="Más Populares">
                    <c:forEach var="c" items="${populares}">
                        <c:set var="estaAlquilado" value="${alquiladoMap[c.id]}"/>
                        <div class="movie-card" data-alquilado="${estaAlquilado}" data-expirado="${alquiladoMap[c.id] != null ? 'true' : 'false'}" data-contenido="${c.id}">
                            <c:choose>
                                <c:when test="${empty c.imagenUrl}"><c:url var="imgSrc" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/></c:when>
                                <c:when test="${fn:startsWith(c.imagenUrl, 'http')}"><c:set var="imgSrc" value="${c.imagenUrl}"/></c:when>
                                <c:otherwise><c:url var="imgSrc" value="${c.imagenUrl}"/></c:otherwise>
                            </c:choose>
                            <img loading="lazy" src="${imgSrc}" alt="${c.titulo}" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
                            <div class="movie-info">
                                <div class="movie-title">${c.titulo}</div>
                                <div class="movie-rating">★★★★★</div>
                                <div class="rental-price"><c:if test="${not empty c.precioAlquiler && !estaAlquilado}">$<fmt:formatNumber value="${c.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/> / 3 días</c:if></div>
                                <div class="movie-actions">
                                    <button class="rent-btn fade-in" data-contenido="${c.id}" data-alquilado="${estaAlquilado ? 'true' : 'false'}" onclick="event.stopPropagation(); if(this.getAttribute('data-alquilado') !== 'true') rentNow(${c.id}); return false;">${estaAlquilado ? 'Alquilado' : 'Alquilar'}</button>
                                    <div class="list-actions">
                                        <button class="btn-link fade-in" data-list="mi-lista" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'mi-lista', this)">
                                            <span class="label-default">Mi Lista</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                        <button class="btn-link fade-in" data-list="para-ver" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'para-ver', this)">
                                            <span class="label-default">Para Ver</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>
        <c:if test="${not empty accionList}">
            <h2>💥 Acción</h2>
            <div class="catalogo-slide-viewport">
                <div class="movie-row catalogo-slide no-select" aria-label="Acción">
                    <c:forEach var="c" items="${accionList}">
                        <c:set var="estaAlquilado" value="${alquiladoMap[c.id]}"/>
                        <div class="movie-card" data-alquilado="${estaAlquilado}" data-expirado="${alquiladoMap[c.id] != null ? 'true' : 'false'}" data-contenido="${c.id}">
                            <c:choose>
                                <c:when test="${empty c.imagenUrl}"><c:url var="imgSrc" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/></c:when>
                                <c:when test="${fn:startsWith(c.imagenUrl, 'http')}"><c:set var="imgSrc" value="${c.imagenUrl}"/></c:when>
                                <c:otherwise><c:url var="imgSrc" value="${c.imagenUrl}"/></c:otherwise>
                            </c:choose>
                            <img loading="lazy" src="${imgSrc}" alt="${c.titulo}" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
                            <div class="movie-info">
                                <div class="movie-title">${c.titulo}</div>
                                <div class="movie-rating">★★★★★</div>
                                <div class="rental-price"><c:if test="${not empty c.precioAlquiler && !estaAlquilado}">$<fmt:formatNumber value="${c.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/> / 3 días</c:if></div>
                                <div class="movie-actions">
                                    <button class="rent-btn fade-in" data-contenido="${c.id}" data-alquilado="${estaAlquilado ? 'true' : 'false'}" onclick="event.stopPropagation(); if(this.getAttribute('data-alquilado') !== 'true') rentNow(${c.id}); return false;">${estaAlquilado ? 'Alquilado' : 'Alquilar'}</button>
                                    <div class="list-actions">
                                        <button class="btn-link fade-in" data-list="mi-lista" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'mi-lista', this)">
                                            <span class="label-default">Mi Lista</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                        <button class="btn-link fade-in" data-list="para-ver" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'para-ver', this)">
                                            <span class="label-default">Para Ver</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>
        <c:if test="${not empty seriesRecomendadas}">
            <h2>📺 Series Recomendadas</h2>
            <div class="catalogo-slide-viewport">
                <div class="movie-row catalogo-slide no-select" aria-label="Series Recomendadas">
                    <c:forEach var="c" items="${seriesRecomendadas}">
                        <c:set var="estaAlquilado" value="${alquiladoMap[c.id]}"/>
                        <div class="movie-card" data-alquilado="${estaAlquilado}" data-expirado="${alquiladoMap[c.id] != null ? 'true' : 'false'}" data-contenido="${c.id}">
                            <c:choose>
                                <c:when test="${empty c.imagenUrl}"><c:url var="imgSrc" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/></c:when>
                                <c:when test="${fn:startsWith(c.imagenUrl, 'http')}"><c:set var="imgSrc" value="${c.imagenUrl}"/></c:when>
                                <c:otherwise><c:url var="imgSrc" value="${c.imagenUrl}"/></c:otherwise>
                            </c:choose>
                            <img loading="lazy" src="${imgSrc}" alt="${c.titulo}" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
                            <div class="movie-info">
                                <div class="movie-title">${c.titulo}</div>
                                <div class="movie-rating">★★★★★</div>
                                <div class="rental-price"><c:if test="${not empty c.precioAlquiler && !estaAlquilado}">$<fmt:formatNumber value="${c.precioAlquiler}" minFractionDigits="2" maxFractionDigits="2"/> / 3 días</c:if></div>
                                <div class="movie-actions">
                                    <button class="rent-btn fade-in" data-contenido="${c.id}" data-alquilado="${estaAlquilado ? 'true' : 'false'}" onclick="event.stopPropagation(); if(this.getAttribute('data-alquilado') !== 'true') rentNow(${c.id}); return false;">${estaAlquilado ? 'Alquilado' : 'Alquilar'}</button>
                                    <div class="list-actions">
                                        <button class="btn-link fade-in" data-list="mi-lista" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'mi-lista', this)">
                                            <span class="label-default">Mi Lista</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                        <button class="btn-link fade-in" data-list="para-ver" data-contenido="${c.id}" onclick="event.stopPropagation(); toggleListState(${c.id}, 'para-ver', this)">
                                            <span class="label-default">Para Ver</span>
                                            <span class="label-add">Agregar</span>
                                            <span class="label-added">✔ Agregado</span>
                                            <span class="label-remove">✖ Quitar</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>
    </section>
</div>
<jsp:include page="/WEB-INF/views/fragments/footer.jsp" />
<script src="${pageContext.request.contextPath}/js/catalogo.js"></script>
<script src="${pageContext.request.contextPath}/js/alquiler.js"></script>
<script src="${pageContext.request.contextPath}/js/listas.js"></script>
<script>
(function cleanCatalogUrl(){
  if(window.APP_CTX){
    var pathOk = window.location.pathname.endsWith('/catalogo');
    if(pathOk && window.location.search && window.location.search.length > 0){
      var clean = window.APP_CTX + '/catalogo';
      try { history.replaceState(null,'', clean); } catch(e){}
    }
  }
})();
</script>
</body>
</html>
