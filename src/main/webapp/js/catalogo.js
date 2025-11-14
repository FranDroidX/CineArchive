// Placeholder JS for catalog interactions
console.log('catalogo.js loaded');

function endpoint(path) {
  if (window.APP_CTX && path.startsWith('/')) return window.APP_CTX + path;
  return path;
}

function rentNow(contenidoId) {
    // Usar la utilidad global de alquiler para mantener comportamiento consistente
    if (typeof window.alquilar === 'function') {
        window.alquilar(contenidoId, 3, 'TARJETA');
        return;
    }
    // Fallback: POST directo
    fetch(endpoint('/alquilar'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `contenidoId=${encodeURIComponent(contenidoId)}&periodo=3&metodoPago=TARJETA`
    })
    .then(resp => {
        if (resp.redirected) { window.location.href = resp.url; return; }
        if (resp.ok) { window.location.href = endpoint('/mis-alquileres'); return; }
        throw new Error('Error en la petición de alquiler');
    })
    .catch(err => {
        console.error(err);
        if (typeof window.showToast==='function') showToast('No se pudo realizar el alquiler', 'error');
    });
}

function addToList(contenidoId, lista) {
    const url = endpoint('/lista/add');
    return fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: `contenidoId=${encodeURIComponent(contenidoId)}&lista=${encodeURIComponent(lista)}`
    })
    .then(resp => {
        if (resp.ok) return resp.json();
        throw new Error('Error agregando a la lista');
    });
}

function addToListAjax(contenidoId, lista, btnEl) {
  if (btnEl && (btnEl.classList.contains('added') || btnEl.disabled)) return;
  if (btnEl) btnEl.disabled = true;
  addToList(contenidoId, lista)
    .then(() => {
      // Marcar botón actual como agregado
      if (btnEl) {
        btnEl.classList.add('added');
        btnEl.textContent = '✔ Agregado';
        btnEl.disabled = true;
      } else {
        // fallback por selector si no pasaron el el
        const btns = document.querySelectorAll(`button.btn-link[data-list='${lista}'][data-contenido='${contenidoId}']`);
        btns.forEach(b => { b.classList.add('added'); b.textContent = '✔ Agregado'; b.disabled = true; });
      }
      // Opcional: feedback en el otro botón de lista si existe
      const other = lista === 'mi-lista' ? 'para-ver' : 'mi-lista';
      const otherBtn = document.querySelector(`button.btn-link[data-list='${other}'][data-contenido='${contenidoId}']`);
      if (otherBtn && !otherBtn.classList.contains('added')) {
        otherBtn.textContent = otherBtn.dataset.list === 'mi-lista' ? '➕ Mi Lista' : '📋 Para Ver';
        otherBtn.disabled = false;
      }
    })
    .catch(err => { console.error(err); showToast('No se pudo agregar a la lista', 'error'); if (btnEl) btnEl.disabled = false; });
}

// Debounce búsqueda
const searchInput = document.getElementById('q');
let debounceTimer=null;
if (searchInput) {
  searchInput.addEventListener('input', () => {
    if (debounceTimer) clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      document.getElementById('searchForm').requestSubmit();
    }, 450);
  });
}

function showToast(msg, type='info') {
  let holder = document.getElementById('toast-holder');
  if (!holder) {
    holder = document.createElement('div');
    holder.id = 'toast-holder';
    holder.style.position='fixed';holder.style.bottom='20px';holder.style.right='20px';holder.style.display='flex';holder.style.flexDirection='column';holder.style.gap='8px';holder.style.zIndex='9999';
    document.body.appendChild(holder);
  }
  const el = document.createElement('div');
  el.textContent = msg;
  el.className = 'toast toast-'+type;
  el.style.padding='10px 14px';
  el.style.borderRadius='6px';
  el.style.fontSize='13px';
  el.style.background= type==='error' ? '#dc3545' : (type==='success' ? '#28a745' : '#333');
  el.style.color='#fff';
  el.style.boxShadow='0 4px 12px rgba(0,0,0,.4)';
  holder.appendChild(el);
  setTimeout(()=>{ el.style.opacity='0'; el.style.transition='opacity .4s'; setTimeout(()=> holder.removeChild(el), 500); }, 3000);
}

// Opcional: skeletons si se necesitara
function renderSkeletons(n=8) {
  const grid = document.getElementById('catalogoGrid');
  if (!grid) return;
  grid.innerHTML = '';
  for (let i=0;i<n;i++) {
    const card = document.createElement('div');
    card.className = 'skeleton-card';
    card.innerHTML = `<div class='skeleton-thumb'></div><div class='skeleton-info'><div class='skeleton-line' style='width:80%'></div><div class='skeleton-line' style='width:60%'></div><div class='skeleton-line' style='width:40%'></div></div>`;
    grid.appendChild(card);
  }
}

(function enhanceAllCatalogSlides(){
  const rows = Array.from(document.querySelectorAll('.catalogo-slide'));
  if (!rows.length) return;

  function onWheelFactory(row){
    return function(e){
      // Cualquier wheel dentro del carrusel se transforma en scroll horizontal
      // Evitamos el scroll vertical de la página mientras el puntero esté sobre el carrusel
      e.preventDefault();

      const factor = row.id === 'catalogoRow' ? 6.5 : 4.0;
      // Preferimos deltaY para simular arrastre horizontal con la rueda vertical; sumamos deltaX si existe
      const raw = (e.deltaY || 0) + (e.deltaX || 0);
      const delta = raw * factor;
      if (delta !== 0) {
        row.scrollBy({ left: delta, behavior: 'auto' });
      }

      // Pausa temporal del autoslide en carruseles secundarios
      try { row.__ca_userInteraction = Date.now(); } catch(_){}
    };
  }

  rows.forEach(row => {
    row.addEventListener('wheel', onWheelFactory(row), { passive: false });
    row.classList.add('no-select');
  });
})();

(function setupCatalogAutoSlide(){
  const sliders = Array.from(document.querySelectorAll('.catalogo-slide'));
  if (!sliders.length) return;
  sliders.forEach(slider => {
    // Excluir el carrusel principal de resultados del autoslide
    if (slider.id === 'catalogoRow') return;
    const state = { paused:false };
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

    function attachCardHover(){
      slider.querySelectorAll('.movie-card').forEach(card => {
        card.addEventListener('mouseenter', () => { state.paused = true; });
        card.addEventListener('mouseleave', () => { state.paused = false; });
      });
    }

    const mo = new MutationObserver(() => { attachCardHover(); });
    mo.observe(slider, { childList:true, subtree:true });
    attachCardHover();
    setInterval(nextStep, TICK_MS);
  });
})();

// Agregar click handler a todas las tarjetas de película para navegar al detalle
(function setupCardClickHandlers() {
    const cards = document.querySelectorAll('.movie-card');
    cards.forEach(card => {
        // Extraer el ID del contenido desde el atributo data
        const contenidoId = card.getAttribute('data-contenido') || (card.querySelector('.rent-btn[data-contenido]')?.getAttribute('data-contenido'));

        if (contenidoId) {
            // Hacer que la tarjeta sea clickeable con cursor pointer
            card.style.cursor = 'pointer';

            // Agregar evento de clic a toda la tarjeta
            card.addEventListener('click', function(e) {
                // Verificar que no se hizo clic en un botón o elemento interactivo
                const target = e.target;
                const isButton = target.tagName === 'BUTTON' || target.closest('button');
                const isLink = target.tagName === 'A' || target.closest('a');

                if (!isButton && !isLink) {
                    // Navegar a la página de detalles
                    window.location.href = endpoint('/contenido/' + contenidoId);
                }
            });
        }
    });
})();

function clearFilters(){
  const base = (window.APP_CTX||'') + '/catalogo';
  window.location.href = base;
}

function goToDetails(id){
  const rentBtn = document.querySelector(`.rent-btn[data-contenido='${id}']`);
  if (rentBtn && rentBtn.getAttribute('data-alquilado') === 'true') {
    window.location.href = endpoint('/mis-alquileres');
  } else {
    window.location.href = endpoint('/contenido/'+id);
  }
}

function marcarAlquilados(ids){
  fetch(endpoint('/alquiler/estado'), {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify({ids:ids})
  }).then(r=> r.ok ? r.json() : Promise.reject())
    .then((data) => {
      // Normalizar ids a String para comparar con atributos data-contenido
      const activos = new Set((data.activos||[]).map(String));
      activos.forEach(id => {
        const btn = document.querySelector(`.rent-btn[data-contenido='${id}']`);
        const det = document.querySelector(`.details-btn[data-contenido='${id}']`);
        if (btn){
          btn.setAttribute('data-alquilado','true');
          btn.classList.add('animating');
          btn.textContent='Alquilado';
          btn.disabled = true; // adicional a pointer-events para indicar estado
          const card = btn.closest('.movie-card');
          if (card) card.setAttribute('data-alquilado','true');
        }
        if (det){ det.textContent='Ver alquiler'; }
      });
    }).catch(()=>{});
}

function initEstadoAlquiler(){
  const rentButtons = Array.from(document.querySelectorAll('.rent-btn[data-contenido]'));
  if(!rentButtons.length) return;
  const ids = rentButtons.map(b=>b.getAttribute('data-contenido'));
  marcarAlquilados(ids);
}

if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', initEstadoAlquiler); else initEstadoAlquiler();

// Blur en Enter y bandera para no restaurar foco tras recarga
(function setupSearchEnterBlur(){
  const input = document.getElementById('q');
  if (!input) return;
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.keyCode === 13) {
      try { sessionStorage.setItem('ca_blurSearch', '1'); } catch(_){}
      input.blur();
      // dejar continuar el submit normal
    }
  });
})();

function restoreSearchFocus(){
  // Si el último submit fue por Enter, no restaurar foco
  try {
    if (sessionStorage.getItem('ca_blurSearch') === '1') {
      sessionStorage.removeItem('ca_blurSearch');
      return; // no enfocamos
    }
  } catch(_){}
  const input = document.getElementById('q');
  if (!input) return;
  const v = input.value || '';
  // Enfocar sin desplazar la página y ubicar el cursor al final
  try { input.focus({ preventScroll:true }); } catch(e){ input.focus(); }
  try { input.setSelectionRange(v.length, v.length); } catch(e){}
}

if (document.readyState==='loading') {
  document.addEventListener('DOMContentLoaded', restoreSearchFocus, { once:true });
} else {
  restoreSearchFocus();
}
