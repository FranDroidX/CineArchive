# 🗺️ RUTAS DEL PROYECTO CINEARCHIVE

> **Actualizado:** 2025-11-14 &nbsp;|&nbsp; **Base URL:** `http://localhost:8080/cinearchive` &nbsp;|&nbsp; **Contexto:** Aplicación Spring MVC (WAR) desplegada con Jetty/Tomcat

## 🧭 Convenciones rápidas
- `✔ Implementado`: El endpoint existe y tiene vista/handler disponible.
- `⚠ Parcial`: El handler existe pero depende de vistas o datos aún no creados.
- `❌ No implementado`: La ruta estaba documentada pero no hay handler o la vista falta.
- Todas las rutas están definidas en controladores bajo `src/main/java/edu/utn/inspt/cinearchive/frontend/controlador` salvo indicación explícita.

## 🔒 Seguridad y acceso global
- `SecurityInterceptor` define las rutas públicas: `/`, `/index`, `/login`, `/registro`, `/acceso-denegado`, `/test-acceso-denegado`, cualquier recurso bajo `/api/**`, `/css/**`, `/js/**`, `/img/**` y `/disenio/**`.
- Cualquier otra ruta exige sesión (`usuarioLogueado`).
- Reglas por rol aplicadas antes de invocar al controlador:
  - `/admin/**` → solo `ADMINISTRADOR`.
  - `/inventario/**` → `GESTOR_INVENTARIO` o `ADMINISTRADOR`.
  - `/reportes/**` y `/analytics/**` → `ANALISTA_DATOS` o `ADMINISTRADOR`.
- **Observación:** `/health` no está whitelisteado, por lo que hoy requiere sesión aunque conceptualmente sea un health check.

## 1. Rutas públicas (sin autenticación)
### 1.1 Vistas y acciones
| Ruta | Método | Handler / Vista | Estado | Evidencia / Comentarios |
|------|--------|-----------------|--------|-------------------------|
| `/` y `/index` | GET | `LoginController.inicio()` | ✔ | Redirige según rol o fuerza `/login` sin sesión.
| `/login` | GET | `LoginController.mostrarLogin()` → `login.jsp` | ✔ | Limpia sesión y setea cabeceras anti-cache.
| `/login` | POST | `LoginController.procesarLogin()` | ✔ | Crea sesión y redirige por rol.
| `/logout` | GET | `LoginController.logout()` | ✔ | Invalida sesión y redirige a `/login?mensaje=logout`.
| `/registro` | GET | `RegistroController.mostrarRegistro()` → `registro.jsp` | ✔ | Redirige según rol si ya está autenticado.
| `/registro` | POST | `RegistroController.procesarRegistro()` | ✔ | Crea usuarios regulares.
| `/registro-alt` | POST | `RegistroController.procesarRegistroConModelAttribute()` | ✔ | Variante usando binding.
| `/registro/verificar-email` | GET | `RegistroController.verificarEmail()` | ⚠ | Retorna vista `json-response` **no presente**, responde 500 hasta crearla.
| `/acceso-denegado` | GET | `LoginController.accesoDenegado()` → `acceso-denegado.jsp` | ✔ | Disponible sin sesión para mostrar mensaje.
| `/test-acceso-denegado` | GET | `LoginController.testAccesoDenegado()` | ✔ | Endpoint de diagnóstico JSON.

### 1.2 Recursos estáticos y prototipos (sin sesión)
- `/css/**`, `/js/**`, `/img/**` → recursos servidos desde `src/main/webapp`.
- `/disenio/**` → maquetas HTML en `src/main/webapp/disenio` (no pasan por Spring MVC).

### 1.3 APIs públicas (sin sesión)
| Ruta base | Métodos claves | Controlador | Estado | Notas |
|-----------|----------------|-------------|--------|-------|
| `/api/session` | `POST /invalidate`, `GET /check` | `SessionController` | ✔ | Usado por el login para invalidar/verificar sesiones.
| `/api/categorias` | GET/POST/PUT/DELETE | `CategoriaController` | ✔ | Todo el CRUD está accesible sin autenticación (revisar seguridad a futuro).
| `/api/contenidos` | GET/POST/PUT/DELETE | `ContenidoController` | ✔ | Incluye subrutas `/titulo`, `/genero`, `/tipo`, `/gestor`, `/reservar`, `/devolver`.
| `/api/resenas` | GET/POST/PUT/DELETE | `ResenaController` | ✔ | Incluye filtros por usuario/contenido y verificación de existencia.
| **Nota de riesgo:** al marcar `/api/**` como público, cualquier cliente externo puede ejecutar estas operaciones sin autenticarse.

## 2. Rutas para usuarios autenticados (cualquier rol)
| Ruta | Método | Handler / Vista | Estado | Comentarios |
|------|--------|-----------------|--------|-------------|
| `/home` | GET | `HomeController.index()` → `index.jsp` | ✔ | Dashboard simple para usuarios logueados.
| `/catalogo` | GET | `CatalogoController.catalogo()` → `catalogo.jsp` | ✔ | Filtrado/paginado y secciones destacadas.
| `/contenido/{id}` | GET | `DetalleContenidoController.detalle()` → `detalle.jsp` | ✔ | Incluye lógica para temporadas y alquiler activo.
| `/mi-lista` | GET | `ListaController.miLista()` → `mi-lista.jsp` | ✔ | Requiere que `ListaService` cree la lista si no existe.
| `/para-ver` | GET | `ListaController.paraVer()` → `para-ver.jsp` | ✔ | `ParaVerController` fue deprecado.
| `/lista/add` | POST | `ListaController.addContenido()` (JSON) | ✔ | Alta de contenido; exige sesión.
| `/lista/remove` | POST | `ListaController.removeContenido()` (JSON) | ✔ | Baja de contenido.
| `/lista/estado` | POST JSON | `ListaController.estadoListas()` | ✔ | Devuelve intersección de IDs en listas.
| `/mis-alquileres` | GET | `AlquilerController.misAlquileres()` → `mis-alquileres.jsp` | ✔ | Lista los alquileres activos.
| `/alquilar` | POST | `AlquilerController.alquilar()` | ✔ | Redirige y usa flash messages.
| `/alquiler/estado` | POST JSON | `AlquilerController.estadoAlquiler()` | ✔ | Marca tarjetas alquiladas.
| `/perfil` | GET | `LoginController.mostrarPerfil()` → `perfil.jsp` | ✔ | Refresca datos desde DB.

## 3. Rutas exclusivas por rol
### 3.1 Administrador (`/admin/**`)
| Ruta | Método | Handler / Vista | Estado | Comentarios |
|------|--------|-----------------|--------|-------------|
| `/admin/panel` | GET | `AdminPanelController.mostrarPanelAdmin()` | ✔ | Redirige a `/admin/usuarios` tras validar rol.
| `/admin/usuarios` | GET | `AdminUsuariosController.listarUsuarios()` → `admin/usuarios.jsp` | ✔ | Incluye filtros y métricas.
| `/admin/usuarios/crear` | GET | `AdminUsuariosController.mostrarFormularioCrear()` → `admin/usuario-form.jsp` | ✔ | Formulario.
| `/admin/usuarios/crear` | POST | `AdminUsuariosController.crearUsuario()` | ✔ | Alta de usuarios.
| `/admin/usuarios/editar/{id}` | GET/POST | `AdminUsuariosController` | ✔ | Edición con misma vista `usuario-form.jsp`.
| `/admin/usuarios/{accion}/{id}` | POST | Cambiar estado/rol/restablecer password/eliminar | ✔ | Acciones: `cambiar-estado`, `activar`, `desactivar`, `eliminar`, `cambiar-rol`, `restablecer-password`.
| `/admin/usuarios/detalle/{id}` | GET | `AdminUsuariosController.mostrarDetalleUsuario()` → `admin/usuario-detalle.jsp` | ✔ | Vista de lectura.

### 3.2 Gestor de inventario (`/inventario/**`)
**Vistas**
| Ruta | Método | Handler / Vista | Estado | Comentarios |
|------|--------|-----------------|--------|-------------|
| `/inventario` | GET | `GestorInventarioController.mostrarGestorInventario()` → `gestor-inventario.jsp` | ✔ | Dashboard principal con estadísticas básicas.
| `/inventario/panel` | GET | `InventarioViewController.mostrarPanelInventario()` → `gestor-inventario.jsp` | ✔ | Alias del dashboard.
| `/inventario/dashboard` | GET | `InventarioViewController.mostrarDashboardInventario()` | ✔ | Redirige al panel.
| `/inventario/contenido/nuevo` | GET | `InventarioViewController.mostrarFormularioNuevoContenido()` → `gestor-inventario.jsp` | ✔ | Reutiliza la misma JSP.
| `/inventario/resenas` | GET | `InventarioViewController.mostrarGestionResenas()` → `gestor-inventario.jsp` | ✔ | Cambia pestaña activa.
| `/inventario/contenidos` | GET | `GestorInventarioController.listarContenidosVista()` → `lista-contenidos.jsp` | ❌ | La vista **no existe** en `WEB-INF/views`.
| `/inventario/categorias` | GET | `GestorInventarioController.gestionarCategorias()` → `gestion-categorias.jsp` | ❌ | Vista ausente.
| `/inventario/estadisticas` | GET | `GestorInventarioController.mostrarEstadisticas()` → `estadisticas-inventario.jsp` | ❌ | Vista ausente.

**APIs bajo `/inventario/api/**` (requiere rol Gestor/Admin)**
- Contenidos: `GET /contenidos`, `GET /contenidos/{id}`, `POST /contenidos`, `PUT /contenidos/{id}`, `DELETE /contenidos/{id}`, `GET /contenidos/buscar`, `GET /contenidos/tipo/{tipo}`, `GET /contenidos/disponibles`.
- Categorías: `GET /categorias`, `POST /categorias`, `GET /categorias/tipo/{tipo}`.
- Reseñas: `GET /contenidos/{contenidoId}/resenas`, `POST /resenas`.
- Estadística: `GET /estadisticas`, `GET /resumen/generos`, `GET /resumen/disponibilidad`.

### 3.3 Analista de datos (`/reportes/**`)
**Vistas**
| Ruta | Método | Handler / Vista | Estado | Comentarios |
|------|--------|-----------------|--------|-------------|
| `/reportes/panel` | GET | `ReportesViewController.mostrarPanelReportes()` → `analista-datos.jsp` | ✔ | Configura fechas y KPIs.
| `/reportes/analytics` | GET | `ReportesViewController.mostrarAnalyticsConFiltros()` → `analista-datos.jsp` | ✔ | Acepta filtros.
| `/reportes/personalizados` | GET | `ReportesViewController.mostrarReportesPersonalizados()` | ✔ | Reusa `analista-datos.jsp`.
| `/reportes/demografico` | GET | `ReportesViewController.mostrarAnalisisDemografico()` | ✔ | Cambia secciones activas.
| `/reportes/tendencias` | GET | `ReportesViewController.mostrarTendenciasTemporales()` | ✔ | Idem.
| `/reportes/comportamiento` | GET | `ReportesViewController.mostrarComportamientoUsuarios()` | ✔ | Idem.
| `/reportes` | GET | `ReporteController.mostrarReportes()` → `analista-datos.jsp` | ✔ | Carga datos desde servicios.
| `/reportes/dashboard` | GET | `ReporteController.mostrarDashboard()` → `dashboard-analytics.jsp` | ❌ | Vista no existe, provoca error.

**APIs bajo `/reportes/api/**` (Analista/Admin)**
Incluyen: `GET /api`, `GET /api/{id}`, `POST /api`, `DELETE /api/{id}`, `GET /api/analista/{analistaId}`, `GET /api/tipo/{tipo}`, generación de reportes (`POST /api/generar/...`) y endpoints de analytics (`GET /api/dashboard`, `/api/analytics/*`). Todos devuelven JSON vía `ReporteService`.

### 3.4 Integraciones (`/api-integracion/**`)
| Ruta | Método | Handler / Vista | Estado | Comentarios |
|------|--------|-----------------|--------|-------------|
| `/api-integracion` | GET | `ApiIntegracionController.mostrarIntegracionApis()` → `api-integracion.jsp` | ❌ | JSP inexistente (solo hay prototipos en `/disenio`).
| `/api-integracion/buscar` | GET | `ApiIntegracionController.mostrarBusquedaContenido()` → `busqueda-contenido.jsp` | ❌ | Vista ausente.
| `/api-integracion/importar` | GET | `ApiIntegracionController.mostrarImportacionMasiva()` → `importacion-masiva.jsp` | ❌ | Vista ausente.
| `/api-integracion/sincronizacion` | GET | `ApiIntegracionController.mostrarEstadoSincronizacion()` → `estado-sincronizacion.jsp` | ❌ | Vista ausente.
| `/api-integracion/api/**` | GET/POST/PUT | `ApiIntegracionController` | ✔ | Endpoints JSON para buscar/importar/sincronizar contenidos externos (requieren sesión porque la ruta no cae bajo `/api/**`).

## 4. API REST detallada
### 4.1 `/api/categorias` (pública)
| Endpoint | Método | Estado | Notas |
|----------|--------|--------|-------|
| `/api/categorias` | GET | ✔ | Lista todas las categorías.
| `/api/categorias/{id}` | GET | ✔ | 404 si no existe.
| `/api/categorias/tipo/{tipo}` | GET | ✔ | Tipo es `GENERO`, `TAG`, `CLASIFICACION`.
| `/api/categorias/generos`, `/tags`, `/clasificaciones` | GET | ✔ | Listados específicos.
| `/api/categorias` | POST | ✔ | Valida duplicados.
| `/api/categorias/{id}` | PUT | ✔ | Actualiza.
| `/api/categorias/{id}` | DELETE | ✔ | Baja.
| `/api/categorias/nombre/{nombre}` | GET | ✔ | Busca por nombre exacto.

### 4.2 `/api/contenidos` (pública)
Endpoints para listar, filtrar por ID/título/género/tipo/gestor, listar disponibles, crear/editar/eliminar, asignar categorías (`POST/DELETE /{id}/categorias`), gestionar stock (`POST /{id}/reservar`, `POST /{id}/devolver`). Todos implementados en `ContenidoController`.

### 4.3 `/api/resenas` (pública)
Incluye listados generales, por usuario/contenido, filtros por calificación, promedio de contenido, creación, actualización, eliminación y verificación de existencia (`/usuario/{usuarioId}/contenido/{contenidoId}` y `/existe`).

### 4.4 `/api/session` (pública)
- `POST /api/session/invalidate` → invalida sesión activa.
- `GET /api/session/check` → indica si hay sesión y devuelve nombre/rol.

### 4.5 `/inventario/api/**` (Gestor/Admin)
Ver sección 3.2. Todos los handlers devuelven `ResponseEntity` con modelos de contenido, categoría, reseña o métricas.

### 4.6 `/reportes/api/**` (Analista/Admin)
Endpoints para CRUD de reportes, generación (más alquilados, demográfico, géneros, tendencias, comportamiento) y dashboards (`/api/dashboard`, `/api/analytics/*`). Todos devuelven JSON.

### 4.7 `/api-integracion/api/**` (requiere sesión)
- Conectividad: `GET /api/conectividad`.
- Búsqueda TMDb/OMDb: `GET /api/buscar/{peliculas|series|contenido}`.
- Detalles externos: `GET /api/detalles/{pelicula|serie}/{fuente}/{idExterno}`.
- Importaciones: `POST /api/importar/{pelicula|serie}`, `POST /api/importar/lote`.
- Actualizaciones/sincronización: `PUT /api/actualizar/{contenidoId}`, `POST /api/sincronizar`.
- Utilitarios: `GET /api/generos`, `GET /api/popular/{tipo}`, `POST /api/validar`.

### 4.8 Endpoints AJAX auxiliares (requieren login)
| Endpoint | Método | Uso |
|----------|--------|-----|
| `/lista/add` | POST form | Añadir contenido a lista.
| `/lista/remove` | POST form | Quitar contenido.
| `/lista/estado` | POST JSON | Consultar estado de IDs.
| `/alquiler/estado` | POST JSON | Marcar contenidos con alquiler activo.

## 5. Rutas faltantes o incidencias detectadas
1. **Health Check** (`/health`): existe en `HealthController` pero no está incluido en `esRutaPublica`, por lo que responde redirección a `/login` si no hay sesión. Ajustar interceptor para usarlo externamente.
2. **Vista `json-response.jsp`**: imprescindible para que `/registro/verificar-email` entregue JSON.
3. **Vistas de inventario**: `lista-contenidos.jsp`, `gestion-categorias.jsp`, `estadisticas-inventario.jsp` no existen; mientras tanto esos endpoints devuelven error.
4. **Vistas de integración externa**: faltan `api-integracion.jsp`, `busqueda-contenido.jsp`, `importacion-masiva.jsp`, `estado-sincronizacion.jsp`.
5. **Dashboard de analytics**: `ReporteController.mostrarDashboard()` referencia `dashboard-analytics.jsp`, inexistente.
6. **Exposición pública de `/api/**`**: actualmente cualquier usuario anónimo puede crear/editar contenidos, categorías y reseñas. Evaluar protegerlos o exponer solo los GET.
7. **Controladores legados**: `ParaVerController` está deshabilitado; la lógica vive en `ListaController`. Documentado para evitar confusiones.
8. **Sesión mixta en listas/alquileres**: `ListaController` y `AlquilerController` siguen buscando `session.getAttribute("usuario")` en lugar de `usuarioLogueado`; puede generar inconsistencias si sólo se setea este último atributo.

## 6. Recursos estáticos y vistas disponibles
Vistas confirmadas en `src/main/webapp/WEB-INF/views`:
- Raíz: `index.jsp`.
- Autenticación: `login.jsp`, `registro.jsp`, `acceso-denegado.jsp`, `perfil.jsp`.
- Usuario regular: `catalogo.jsp`, `detalle.jsp`, `mi-lista.jsp`, `para-ver.jsp`, `mis-alquileres.jsp`.
- Administración: `admin/usuarios.jsp`, `admin/usuario-form.jsp`, `admin/usuario-detalle.jsp`.
- Gestor inventario: `gestor-inventario.jsp`.
- Analista: `analista-datos.jsp` (+ respaldo `.backup`).
- Fragmentos comunes: `fragments/header.jsp`, `fragments/footer.jsp`.
- Recursos de diseño adicionales en `src/main/webapp/disenio` para prototipos HTML.

## 7. Notas de testing y referencias
- **Guía de pruebas de categorías:** `src/main/resources/docs/pruebas_api_categorias.md` incluye comandos `curl` listos para verificar `/api/categorias` (CRUD completo).
- **Ejecución local:**
  ```bash
  mvn clean compile
  mvn jetty:run
  ```
- **BD:** configurar credenciales en `src/main/resources/application.properties` (`jdbc:mysql://localhost:3306/cinearchive_v2`).

Con esta actualización el documento refleja todas las rutas reales registradas en los controladores, identifica los endpoints faltantes o sin vista y deja constancia del estado de seguridad actual para cada grupo.
