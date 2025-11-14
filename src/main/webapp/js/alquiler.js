// alquiler.js
// Manejo de formularios y acciones de alquiler sin depender de JSON

console.log('alquiler.js loaded');

function endpoint(path) {
  if (window.APP_CTX && path.startsWith('/')) return window.APP_CTX + path;
  return path;
}

// Adjunta manejador al formulario de alquiler en detalle.jsp (si existe)
document.addEventListener('DOMContentLoaded', () => {
  const forms = document.querySelectorAll('form[action$="/alquilar"][method="post"]');
  forms.forEach(form => { form.addEventListener('submit', onAlquilerSubmit); });
});

async function onAlquilerSubmit(event) {
  event.preventDefault();
  const form = event.target;
  const params = new URLSearchParams(new FormData(form));
  // Asegurar método de pago por defecto si no viene
  if (!params.get('metodoPago')) {
    params.set('metodoPago', 'TARJETA');
  }
  try {
    const resp = await fetch(endpoint('/alquilar'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString()
    });

    // El controlador devuelve redirect:/mis-alquileres
    if (resp.redirected) {
      window.location.href = resp.url;
      return;
    }
    if (resp.ok) {
      window.location.href = endpoint('/mis-alquileres');
    } else {
      if (typeof window.showToast === 'function') showToast('No se pudo confirmar el alquiler', 'error');
    }
  } catch (err) {
    console.error('Error de red al alquilar:', err);
    if (typeof window.showToast === 'function') showToast('Error de red al procesar el alquiler', 'error');
  }
}

// Utilidad para alquilar programáticamente (por ejemplo, desde botones en catálogo)
// Nota: no espera JSON; redirige a mis-alquileres en éxito
async function alquilar(contenidoId, periodo = 3, metodoPago = 'TARJETA') {
  try {
    const resp = await fetch(endpoint('/alquilar'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: `contenidoId=${encodeURIComponent(contenidoId)}&periodo=${encodeURIComponent(periodo)}&metodoPago=${encodeURIComponent(metodoPago)}`
    });
    if (resp.redirected) {
      window.location.href = resp.url;
      return;
    }
    if (resp.ok) {
      window.location.href = endpoint('/mis-alquileres');
    } else {
      if (typeof window.showToast === 'function') showToast('No se pudo realizar el alquiler', 'error');
    }
  } catch (e) {
    console.error(e);
    if (typeof window.showToast === 'function') showToast('Error de red al realizar el alquiler', 'error');
  }
}

window.alquilar = alquilar;

// Función para formatear tiempo restante de forma dinámica
function formatearTiempoRestante(segundos) {
    if (segundos < 0) {
        // Tiempo expirado
        const segsPositivos = Math.abs(segundos);
        const dias = Math.floor(segsPositivos / 86400);
        const horas = Math.floor((segsPositivos % 86400) / 3600);
        const minutos = Math.floor((segsPositivos % 3600) / 60);

        if (dias > 0) {
            return `Expirado hace ${dias} día${dias !== 1 ? 's' : ''}`;
        } else if (horas > 0) {
            return `Expirado hace ${horas} hora${horas !== 1 ? 's' : ''}`;
        } else if (minutos > 0) {
            return `Expirado hace ${minutos} minuto${minutos !== 1 ? 's' : ''}`;
        } else {
            return `Expirado hace ${segsPositivos} segundo${segsPositivos !== 1 ? 's' : ''}`;
        }
    } else {
        // Tiempo restante
        const dias = Math.floor(segundos / 86400);
        const horas = Math.floor((segundos % 86400) / 3600);
        const minutos = Math.floor((segundos % 3600) / 60);
        const segs = segundos % 60;

        if (dias > 0) {
            return `Restan ${dias} día${dias !== 1 ? 's' : ''}`;
        } else if (horas > 0) {
            return `Restan ${horas} hora${horas !== 1 ? 's' : ''}`;
        } else if (minutos > 0) {
            return `Restan ${minutos} minuto${minutos !== 1 ? 's' : ''}`;
        } else {
            return `Restan ${segs} segundo${segs !== 1 ? 's' : ''}`;
        }
    }
}

// Actualizar contadores de tiempo en tiempo real
function inicializarContadoresTiempo() {
    const elementos = document.querySelectorAll('.tiempo-restante[data-segundos]');
    if (!elementos.length) return;

    // Guardar el timestamp inicial del servidor
    const timestampInicial = Date.now();

    elementos.forEach(elem => {
        const segundosIniciales = parseInt(elem.getAttribute('data-segundos'), 10);
        if (isNaN(segundosIniciales)) return;

        // Guardar datos en el elemento
        elem._segundosServidor = segundosIniciales;
        elem._timestampInicial = timestampInicial;
    });

    // Actualizar cada segundo
    function actualizarContadores() {
        const ahora = Date.now();

        elementos.forEach(elem => {
            if (!elem._segundosServidor || !elem._timestampInicial) return;

            // Calcular segundos transcurridos desde la carga inicial
            const segundosTranscurridos = Math.floor((ahora - elem._timestampInicial) / 1000);
            const segundosActuales = elem._segundosServidor - segundosTranscurridos;

            // Formatear y actualizar el texto (mantener el bullet point)
            const textoFormateado = formatearTiempoRestante(segundosActuales);
            elem.textContent = ' • ' + textoFormateado;

            // Si el alquiler acaba de expirar, actualizar el badge y botones
            if (elem._segundosServidor >= 0 && segundosActuales < 0) {
                const alquilerId = elem.getAttribute('data-alquiler-id');
                actualizarEstadoExpirado(alquilerId);
            }
        });
    }

    // Primera actualización inmediata
    actualizarContadores();

    // Actualizar cada segundo
    setInterval(actualizarContadores, 1000);
}

// Actualizar UI cuando un alquiler expira en tiempo real
function actualizarEstadoExpirado(alquilerId) {
    // Buscar la tarjeta por el data-alquiler-id en el elemento de tiempo
    const tiempoElem = document.querySelector(`.tiempo-restante[data-alquiler-id="${alquilerId}"]`);
    if (!tiempoElem) return;

    const card = tiempoElem.closest('.movie-card');
    if (!card) return;

    // Actualizar el badge de estado
    const badge = card.querySelector('.badge-estado');
    if (badge && !badge.classList.contains('estado-expirado')) {
        badge.textContent = 'EXPIRADO';
        badge.classList.remove('estado-activo', 'estado-finalizado', 'estado-cancelado');
        badge.classList.add('estado-expirado');
    }

    // Actualizar el botón de acciones
    const actionsDiv = card.querySelector('.movie-actions');
    if (actionsDiv) {
        const contenidoId = card.getAttribute('data-contenido-id');
        if (contenidoId) {
            actionsDiv.innerHTML = `<button class="rent-btn" onclick="window.location.href='${window.APP_CTX || ''}/contenido/${contenidoId}'">🔄 Extender Alquiler</button>`;
        }
    }
}

// Inicializar al cargar la página
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inicializarContadoresTiempo);
} else {
    inicializarContadoresTiempo();
}

// Autoslide para carruseles en detalle
(function setupDetailAutoSlide(){
  if (!document.body.classList.contains('detail-page')) return;
  const sliders = Array.from(document.querySelectorAll('.detail-slide'));
  if (!sliders.length) return;

  sliders.forEach(slider => {
    const state = { paused: false };
    let intervalId = null;
    const STEP_CARDS = 1;
    const TICK_MS = 4000;

    function cardMetrics(){
      const card = slider.querySelector('.movie-card');
      if (!card) return { w:0, gap:0 };
      const next = card.nextElementSibling;
      let gap = 20;
      if (next) gap = Math.max(0, next.getBoundingClientRect().left - card.getBoundingClientRect().right);
      return { w: card.offsetWidth, gap };
    }
    function visibleCards(){
      const { w, gap } = cardMetrics();
      if (!w) return 0;
      return Math.max(1, Math.floor((slider.clientWidth + gap) / (w + gap)));
    }
    function totalCards(){ return slider.querySelectorAll('.movie-card').length; }
    function shouldRun(){
      if (state.paused) return false;
      if (totalCards() <= visibleCards()) return false;
      return true;
    }
    function nextStep(){
      if (!shouldRun()) return;
      const { w, gap } = cardMetrics();
      const delta = (w + gap) * STEP_CARDS;
      const maxScroll = slider.scrollWidth - slider.clientWidth;
      let target = slider.scrollLeft + delta;
      if (target > maxScroll + 4) target = 0;
      slider.scrollTo({ left: target, behavior: 'smooth' });
    }
    function start(){ if (!intervalId) intervalId = setInterval(nextStep, TICK_MS); }
    function stop(){ if (intervalId){ clearInterval(intervalId); intervalId=null; } }

    function attachCardHover(){
      slider.querySelectorAll('.movie-card').forEach(card => {
        card.addEventListener('mouseenter', () => { state.paused = true; });
        card.addEventListener('mouseleave', () => { state.paused = false; });
      });
    }

    const mo = new MutationObserver(() => { attachCardHover(); });
    mo.observe(slider, { childList:true, subtree:true });
    attachCardHover();
    start();
  });
})();
