(function(){
  const ctx = window.APP_CTX || '';
  function q(sel, root){ return (root||document).querySelector(sel); }
  function ce(tag, cls){ const el = document.createElement(tag); if (cls) el.className = cls; return el; }
  function esc(s){
    if (s == null) return '';
    return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;','\'':'&#39;'}[c]));
  }
  async function fetchJSON(url, opts){
    const res = await fetch(url, Object.assign({credentials:'include'}, opts));
    if (!res.ok){
      const text = await res.text();
      throw new Error('HTTP '+res.status+' - '+text);
    }
    const ct = res.headers.get('content-type')||'';
    if (ct.includes('application/json')) return res.json();
    return null;
  }

  function renderReviewItem(r, usuarioActualId){
    const item = ce('div','review-item');
    item.style.border = '1px solid #333'; item.style.padding = '12px'; item.style.borderRadius='8px'; item.style.background='#0a0a0a';

    // Encabezado con título y estrellas
    const head = ce('div'); head.style.display='flex'; head.style.justifyContent='space-between'; head.style.alignItems='flex-start'; head.style.marginBottom='8px';
    const titleSection = ce('div'); titleSection.style.flex='1';
    const stars = '★★★★★☆☆☆☆☆'.slice(5 - Math.round(r.calificacion), 10 - Math.round(r.calificacion));
    titleSection.innerHTML = `<strong style="font-size:15px;">${esc(r.titulo||'')}</strong> <span style="color:#f5c518;">${stars}</span>`;
    head.appendChild(titleSection);

    // Botón eliminar si es del usuario actual
    if (r.usuario && r.usuario.id && String(r.usuario.id) === String(usuarioActualId)){
      const actions = ce('div');
      const del = ce('button','btn-link');
      del.textContent = 'Eliminar';
      del.style.color='#f55';
      del.style.padding='4px 10px';
      del.style.fontSize='12px';
      del.addEventListener('click', async ()=>{
        if (confirm('¿Eliminar esta reseña?')) {
          try {
            await fetchJSON(`${ctx}/api/resenas/${r.id}`, { method:'DELETE' });
            setMsg('Reseña eliminada ✓');
            await loadStats();
            await loadReviews();
          } catch(e){ setMsg('Error al eliminar: '+e.message, true); }
        }
      });
      actions.appendChild(del);
      head.appendChild(actions);
    }
    item.appendChild(head);

    // Información del usuario y fecha
    const meta = ce('div');
    meta.style.fontSize='12px';
    meta.style.color='#888';
    meta.style.marginBottom='8px';
    const userName = r.usuario && r.usuario.nombre ? esc(r.usuario.nombre) : 'Usuario';
    const fecha = r.fechaCreacion ? esc(r.fechaCreacion) : '';
    meta.innerHTML = `<span style="color:#aaa;">Por <strong style="color:#ccc;">${userName}</strong></span>` +
                     (fecha ? ` <span style="margin-left:8px;">• ${fecha}</span>` : '');
    item.appendChild(meta);

    // Texto de la reseña
    const body = ce('div');
    body.style.color='#bbb';
    body.style.fontSize='14px';
    body.style.lineHeight='1.5';
    body.textContent = r.texto || '';
    item.appendChild(body);

    return item;
  }

  function setMsg(msg, isErr){ const el = q('#review-msg'); if (el){ el.textContent = msg||''; el.style.color = isErr? '#f66':'#aaa'; } }
  function getIds(){
    const cont = q('.detail-container');
    return {
      contenidoId: cont ? cont.getAttribute('data-contenido-id') : null,
      usuarioId: cont ? cont.getAttribute('data-usuario-id') : null
    };
  }

  async function loadStats(){
    const {contenidoId} = getIds(); if (!contenidoId) return;
    try{
      const data = await fetchJSON(`${ctx}/api/resenas/contenido/${contenidoId}/stats`);
      q('#avg-rating').textContent = data && typeof data.promedio === 'number' ? data.promedio.toFixed(1) : '-';
      q('#review-count').textContent = data && typeof data.total === 'number' ? data.total : '0';
    }catch{ /* ignore */ }
  }

  async function loadReviews(){
    const {contenidoId, usuarioId} = getIds(); if (!contenidoId) return;
    const list = q('#reviews-list'); if (!list) return; list.innerHTML = '';
    try{
      const arr = await fetchJSON(`${ctx}/api/resenas/contenido/${contenidoId}`);
      if (!arr || !arr.length){
        const empty = ce('div'); empty.style.color='#888'; empty.textContent = 'Aún no hay reseñas. ¡Sé el primero en opinar!';
        list.appendChild(empty);
      } else {
        arr.forEach(r => list.appendChild(renderReviewItem(r, usuarioId)));
      }
    }catch(e){
      const err = ce('div'); err.style.color='#f66'; err.textContent = 'No se pudieron cargar las reseñas.';
      list.appendChild(err);
    }
  }

  async function createReview(){
    const {contenidoId, usuarioId} = getIds();
    if (!usuarioId){ setMsg('Necesitas iniciar sesión para publicar una reseña.', true); return; }
    const calif = parseInt((q('#review-rating')||{}).value||'1',10);
    const titulo = (q('#review-title')||{}).value||'';
    const texto = (q('#review-text')||{}).value||'';
    if (!titulo.trim()){ setMsg('El título es obligatorio.', true); return; }
    if (!texto.trim()){ setMsg('El texto es obligatorio.', true); return; }
    const body = {
      usuario: { id: Number(usuarioId) },
      contenido: { id: Number(contenidoId) },
      calificacion: calif,
      titulo: titulo.trim(),
      texto: texto.trim()
    };
    try{
      await fetchJSON(`${ctx}/api/resenas`, {
        method:'POST',
        headers: { 'Content-Type':'application/json' },
        body: JSON.stringify(body)
      });
      setMsg('Reseña publicada ✓');
      (q('#review-title')||{}).value='';
      (q('#review-text')||{}).value='';
      await loadStats();
      await loadReviews();
    }catch(e){
      if (String(e.message).includes('409')) setMsg('Ya publicaste una reseña para este contenido.', true);
      else if (String(e.message).includes('401')) setMsg('Inicia sesión para publicar reseñas.', true);
      else setMsg('Error al publicar: '+e.message, true);
    }
  }

  document.addEventListener('DOMContentLoaded', function(){
    const btn = q('#review-submit');
    if (btn) btn.addEventListener('click', createReview);
    loadStats();
    loadReviews();
  });
})();

