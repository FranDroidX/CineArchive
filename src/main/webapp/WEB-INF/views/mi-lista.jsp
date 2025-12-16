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
    <title>Mi Lista - CineArchive</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <script>window.APP_CTX='${pageContext.request.contextPath}';</script>
</head>
<body>
<jsp:include page="/WEB-INF/views/fragments/header.jsp" />
<div class="container">
    <h1 class="page-title">🎬 Contenidos en Mi Lista</h1>
    <!-- Contenidos en Mi Lista -->
    <section class="category">
        <div class="movie-row no-select">
            <c:choose>
                <c:when test="${not empty contenidos}">
                    <c:forEach var="c" items="${contenidos}">
                        <div class="movie-card">
                            <c:choose>
                                <c:when test="${empty c.imagenUrl}">
                                    <c:url var="imgSrc" value="/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg"/>
                                </c:when>
                                <c:when test="${fn:startsWith(c.imagenUrl, 'http')}">
                                    <c:set var="imgSrc" value="${c.imagenUrl}"/>
                                </c:when>
                                <c:otherwise>
                                    <c:url var="imgSrc" value="${c.imagenUrl}"/>
                                </c:otherwise>
                            </c:choose>
                            <img loading="lazy" src="${imgSrc}" alt="${c.titulo}" draggable="false" ondragstart="return false;" onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/img/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_FMjpg_UX1000_.jpg';" />
                            <div class="movie-info">
                                <div class="movie-title">${c.titulo}</div>
                                <div class="movie-actions">
                                    <div class="details-wrapper"><button class="btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/contenido/${c.id}'">Ver detalles</button></div>
                                    <button class="btn-link" onclick="removeFromListAjax(${c.id}, 'mi-lista', this)">✖ Quitar</button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p>No hay contenidos aún en tu lista. Agrega desde el catálogo.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</div>
<jsp:include page="/WEB-INF/views/fragments/footer.jsp" />
<script src="${pageContext.request.contextPath}/js/listas.js"></script>
</body>
</html>
