// Toggle menu móvil
document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelector('.nav-links');

    if (menuToggle) {
        menuToggle.addEventListener('click', function() {
            navLinks.classList.toggle('active');
        });
    }

    // Sistema de calificación con estrellas
    const starsInput = document.querySelector('.stars-input');
    if (starsInput) {
        starsInput.addEventListener('click', function(e) {
            const rect = this.getBoundingClientRect();
            const clickX = e.clientX - rect.left;
            const starWidth = rect.width / 5;
            const rating = Math.ceil(clickX / starWidth);

            let stars = '';
            for (let i = 0; i < 5; i++) {
                stars += i < rating ? '★' : '☆';
            }
            this.textContent = stars;
            this.dataset.rating = rating;
        });
    }

    // Selección de opciones de alquiler
    const rentalOptions = document.querySelectorAll('.rental-option');
    rentalOptions.forEach(option => {
        option.addEventListener('click', function() {
            rentalOptions.forEach(opt => opt.classList.remove('selected'));
            this.classList.add('selected');
            const radio = this.querySelector('input[type="radio"]');
            if (radio) radio.checked = true;
        });
    });

    // Smooth scroll para movie-row
    const movieRows = document.querySelectorAll('.movie-row');
    movieRows.forEach(row => {
        let isDown = false;
        let startX;
        let scrollLeft;

        row.addEventListener('mousedown', (e) => {
            isDown = true;
            row.style.cursor = 'grabbing';
            startX = e.pageX - row.offsetLeft;
            scrollLeft = row.scrollLeft;
        });

        row.addEventListener('mouseleave', () => {
            isDown = false;
            row.style.cursor = 'grab';
        });

        row.addEventListener('mouseup', () => {
            isDown = false;
            row.style.cursor = 'grab';
        });

        row.addEventListener('mousemove', (e) => {
            if (!isDown) return;
            e.preventDefault();
            const x = e.pageX - row.offsetLeft;
            const walk = (x - startX) * 2;
            row.scrollLeft = scrollLeft - walk;
        });
    });

    // Confirmación para acciones de eliminación
    const deleteButtons = document.querySelectorAll('[title="Eliminar"], .btn-remove');
    deleteButtons.forEach(btn => {
        btn.addEventListener('click', function(e) {
            if (!confirm('¿Estás seguro de que deseas eliminar este elemento?')) {
                e.preventDefault();
                e.stopPropagation();
            }
        });
    });

    // Mensajes de éxito para acciones
    function showMessage(message, type = 'success') {
        const messageDiv = document.createElement('div');
        messageDiv.className = `notification notification-${type}`;
        messageDiv.textContent = message;
        messageDiv.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 25px;
            background-color: ${type === 'success' ? '#28a745' : '#e50914'};
            color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            z-index: 1000;
            animation: slideIn 0.3s ease;
        `;
        document.body.appendChild(messageDiv);

        setTimeout(() => {
            messageDiv.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => messageDiv.remove(), 300);
        }, 3000);
    }

    // Re-exponer showMessage como window.showToast si no existe (para integraciones de listas/alquiler)
    if (typeof window.showToast !== 'function') {
        window.showToast = function(message, type='info'){ showMessage(message, type === 'error' ? 'error' : (type==='success'?'success':'info')); };
    }

    // Agregar a favoritos
    const addToFavButtons = document.querySelectorAll('.btn-add');
    addToFavButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const movieTitle = this.closest('.movie-card').querySelector('.movie-title').textContent;
            showMessage(`"${movieTitle}" agregado a tu lista ✓`);
        });
    });

    // Botón de alquilar (removida confirmación para flujo directo)
    const rentButtons = document.querySelectorAll('.rent-btn-large');
    rentButtons.forEach(btn => {
        // No interceptamos el submit: si el botón está dentro de un form con action /alquilar, dejamos que el form se envíe
        // Opcionalmente podemos reflejar estado visual inmediato sin bloquear
        btn.addEventListener('click', function() {
            // No confirm(), no preventDefault(). El form se enviará y alquiler.js gestionará la redirección.
            // Si se quisiera feedback instantáneo antes de redirección, se puede descomentar:
            // if (typeof window.showToast === 'function') showToast('Procesando alquiler...', 'info');
        }, { once: false });
    });

    // Validación de formularios
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            const inputs = form.querySelectorAll('input[required]');
            let isValid = true;

            inputs.forEach(input => {
                if (!input.value.trim()) {
                    isValid = false;
                    input.style.borderColor = '#dc3545';
                } else {
                    input.style.borderColor = '';
                }
            });

            if (!isValid) {
                e.preventDefault();
                showMessage('Por favor completa todos los campos requeridos', 'error');
            }
        });
    });

    // Búsqueda en tiempo real (simulada)
    const searchInputs = document.querySelectorAll('.search-input');
    searchInputs.forEach(input => {
        let timeout;
        input.addEventListener('input', function() {
            clearTimeout(timeout);
            const searchTerm = this.value.toLowerCase();

            if (searchTerm.length > 2) {
                timeout = setTimeout(() => {
                    console.log('Buscando:', searchTerm);
                    // Aquí iría la lógica de búsqueda real
                }, 500);
            }
        });
    });

    // Tabs para formularios
    const tabButtons = document.querySelectorAll('.tab-btn');
    tabButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            tabButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });

    // Animaciones CSS
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }

        .movie-row {
            cursor: grab;
        }

        .movie-row:active {
            cursor: grabbing;
        }
    `;
    document.head.appendChild(style);

    // Contador de caracteres para textarea
    const textareas = document.querySelectorAll('textarea');
    textareas.forEach(textarea => {
        const maxLength = 500;
        const counter = document.createElement('div');
        counter.style.cssText = 'text-align: right; color: #888; font-size: 12px; margin-top: 5px;';
        counter.textContent = `0 / ${maxLength}`;
        textarea.setAttribute('maxlength', maxLength);
        textarea.parentNode.insertBefore(counter, textarea.nextSibling);

        textarea.addEventListener('input', function() {
            counter.textContent = `${this.value.length} / ${maxLength}`;
        });
    });

    // Filtros dinámicos
    const filterSelects = document.querySelectorAll('.filter-select');
    filterSelects.forEach(select => {
        select.addEventListener('change', function() {
            console.log('Filtro aplicado:', this.value);
            // Aquí iría la lógica de filtrado real
            showMessage('Filtros aplicados ✓');
        });
    });

    // Animación de carga para tablas
    const tables = document.querySelectorAll('.admin-table tbody');
    tables.forEach(tbody => {
        const rows = tbody.querySelectorAll('tr');
        rows.forEach((row, index) => {
            row.style.opacity = '0';
            row.style.animation = `fadeIn 0.3s ease forwards ${index * 0.05}s`;
        });
    });

    // Añadir animación fadeIn
    const fadeInStyle = document.createElement('style');
    fadeInStyle.textContent = `
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    `;
    document.head.appendChild(fadeInStyle);

    // Modo de visualización para reportes
    const reportGenerator = document.querySelector('.report-generator');
    if (reportGenerator) {
        const generateBtn = reportGenerator.querySelector('.btn-primary');
        if (generateBtn) {
            generateBtn.addEventListener('click', function() {
                showMessage('Generando reporte... ⏳');
                setTimeout(() => {
                    showMessage('Reporte generado exitosamente 📊');
                }, 2000);
            });
        }
    }

    // Tooltips simples
    document.querySelectorAll('[title]').forEach(element => {
        element.addEventListener('mouseenter', function(e) {
            const tooltip = document.createElement('div');
            tooltip.className = 'tooltip';
            tooltip.textContent = this.getAttribute('title');
            tooltip.style.cssText = `
                position: absolute;
                background-color: #333;
                color: white;
                padding: 5px 10px;
                border-radius: 4px;
                font-size: 12px;
                z-index: 1000;
                pointer-events: none;
                white-space: nowrap;
            `;
            document.body.appendChild(tooltip);

            const rect = this.getBoundingClientRect();
            tooltip.style.left = rect.left + (rect.width / 2) - (tooltip.offsetWidth / 2) + 'px';
            tooltip.style.top = rect.top - tooltip.offsetHeight - 5 + 'px';

            this.addEventListener('mouseleave', () => tooltip.remove(), { once: true });
        });
    });

    // ============================================
    // VALIDACIÓN DE FORMULARIO DE LOGIN
    // ============================================

    const loginForm = document.querySelector('.login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', function(e) {
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            if (!email || !password) {
                e.preventDefault();
                alert('Por favor, completa todos los campos');
                return false;
            }

            // Validación básica de email
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('Por favor, ingresa un email válido');
                return false;
            }
        });
    }

    // ============================================
    // VALIDACIÓN DE FORMULARIO DE REGISTRO
    // ============================================

    const registroForm = document.getElementById('registroForm');
    if (registroForm) {
        const passwordInput = document.getElementById('password');
        const passwordConfirmInput = document.getElementById('passwordConfirm');
        const passwordRequirements = document.getElementById('passwordRequirements');
        const passwordMatch = document.getElementById('passwordMatch');
        const submitBtn = document.getElementById('submitBtn');
        const fechaNacimientoInput = document.getElementById('fechaNacimiento');

        // Requisitos de contraseña
        const requirements = {
            length: document.getElementById('req-length'),
            uppercase: document.getElementById('req-uppercase'),
            lowercase: document.getElementById('req-lowercase'),
            number: document.getElementById('req-number')
        };

        // Mostrar requisitos cuando el usuario comienza a escribir la contraseña
        if (passwordInput) {
            passwordInput.addEventListener('focus', function() {
                if (passwordRequirements) {
                    passwordRequirements.style.display = 'block';
                }
            });

            // Validar contraseña mientras el usuario escribe
            passwordInput.addEventListener('input', function() {
                const password = this.value;

                // Validar longitud mínima (8 caracteres)
                if (password.length >= 8) {
                    requirements.length.classList.remove('invalid');
                    requirements.length.classList.add('valid');
                } else {
                    requirements.length.classList.remove('valid');
                    requirements.length.classList.add('invalid');
                }

                // Validar al menos una mayúscula
                if (/[A-Z]/.test(password)) {
                    requirements.uppercase.classList.remove('invalid');
                    requirements.uppercase.classList.add('valid');
                } else {
                    requirements.uppercase.classList.remove('valid');
                    requirements.uppercase.classList.add('invalid');
                }

                // Validar al menos una minúscula
                if (/[a-z]/.test(password)) {
                    requirements.lowercase.classList.remove('invalid');
                    requirements.lowercase.classList.add('valid');
                } else {
                    requirements.lowercase.classList.remove('valid');
                    requirements.lowercase.classList.add('invalid');
                }

                // Validar al menos un número
                if (/[0-9]/.test(password)) {
                    requirements.number.classList.remove('invalid');
                    requirements.number.classList.add('valid');
                } else {
                    requirements.number.classList.remove('valid');
                    requirements.number.classList.add('invalid');
                }

                // Verificar coincidencia si ya hay algo en el campo de confirmación
                if (passwordConfirmInput && passwordConfirmInput.value) {
                    checkPasswordMatch();
                }
            });
        }

        // Verificar si las contraseñas coinciden
        function checkPasswordMatch() {
            const password = passwordInput.value;
            const confirmPassword = passwordConfirmInput.value;

            // Si el campo de confirmación está vacío, ocultar mensaje
            if (confirmPassword === '') {
                if (passwordMatch) {
                    passwordMatch.style.display = 'none';
                }
                return;
            }

            // Mostrar mensaje
            if (passwordMatch) {
                passwordMatch.style.display = 'block';

                // Verificar coincidencia
                if (password === confirmPassword) {
                    passwordMatch.textContent = '✓ Las contraseñas coinciden';
                    passwordMatch.classList.remove('no-match');
                    passwordMatch.classList.add('match');
                } else {
                    passwordMatch.textContent = '✗ Las contraseñas no coinciden';
                    passwordMatch.classList.remove('match');
                    passwordMatch.classList.add('no-match');
                }
            }
        }

        // Ejecutar verificación cuando el usuario escribe en el campo de confirmación
        if (passwordConfirmInput) {
            passwordConfirmInput.addEventListener('input', checkPasswordMatch);
        }

        // Validar formulario antes de enviar
        registroForm.addEventListener('submit', function(e) {
            const nombre = document.getElementById('nombre').value.trim();
            const email = document.getElementById('email').value.trim();
            const password = passwordInput.value;
            const passwordConfirm = passwordConfirmInput.value;
            const terms = document.getElementById('terms').checked;

            // Validar nombre (mínimo 3 caracteres)
            if (nombre === '' || nombre.length < 3) {
                alert('⚠️ El nombre debe tener al menos 3 caracteres');
                e.preventDefault();
                return false;
            }

            // Validar email (formato válido)
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert('⚠️ Por favor, ingresa un email válido');
                e.preventDefault();
                return false;
            }

            // Validar contraseña (mínimo 8 caracteres)
            if (password.length < 8) {
                alert('⚠️ La contraseña debe tener al menos 8 caracteres');
                e.preventDefault();
                return false;
            }

            // Validar que las contraseñas coincidan
            if (password !== passwordConfirm) {
                alert('⚠️ Las contraseñas no coinciden');
                e.preventDefault();
                return false;
            }

            // Validar términos y condiciones
            if (!terms) {
                alert('⚠️ Debes aceptar los Términos y Condiciones para continuar');
                e.preventDefault();
                return false;
            }

            // Deshabilitar botón para evitar doble envío
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.textContent = 'Creando cuenta...';
            }

            return true;
        });

        // Establecer fecha máxima para fecha de nacimiento (hoy)
        if (fechaNacimientoInput) {
            const today = new Date().toISOString().split('T')[0];
            fechaNacimientoInput.setAttribute('max', today);
        }
    }

    // ============================================
    // AUTO-OCULTAR MENSAJES DE ALERTA
    // ============================================
    // Auto-ocultar mensajes después de 5 segundos (funciona en todas las páginas)
    setTimeout(function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(function() {
                alert.style.display = 'none';
            }, 500);
        });
    }, 5000);

    // ============================================
    // PÁGINA ACCESO DENEGADO
    // ============================================
    // Efecto de shake en el icono al cargar
    const errorIcon = document.querySelector('.error-icon');
    if (errorIcon) {
        errorIcon.classList.add('animated', 'shake');
    }

    // Efecto hover en botones de la página de acceso denegado
    const btnHome = document.querySelectorAll('.btn-home');
    btnHome.forEach(btn => {
        btn.addEventListener('mouseenter', function() {
            this.classList.add('shadow-lg');
        });
        btn.addEventListener('mouseleave', function() {
            this.classList.remove('shadow-lg');
        });
    });

    // ============================================
    // MÉTODOS DE PAGO - FORMULARIO
    // ============================================

    // Función para actualizar campos condicionales según el tipo de método de pago
    function updateConditionalFields() {
        const tipo = document.getElementById('tipo');
        const tarjetaFields = document.getElementById('tarjetaFields');
        const plataformaFields = document.getElementById('plataformaFields');

        // Verificar que los elementos existan antes de manipularlos
        if (!tipo || !tarjetaFields || !plataformaFields) return;

        // Ocultar todos
        tarjetaFields.classList.remove('active');
        plataformaFields.classList.remove('active');

        const tipoValue = tipo.value;

        // Mostrar según tipo
        if (tipoValue === 'TARJETA_CREDITO' || tipoValue === 'TARJETA_DEBITO') {
            tarjetaFields.classList.add('active');
            // Hacer campos requeridos
            const titular = document.getElementById('titular');
            const numeroTarjeta = document.getElementById('numeroTarjeta');
            if (titular) titular.required = true;
            if (numeroTarjeta) numeroTarjeta.required = true;
        } else if (tipoValue === 'MERCADOPAGO' || tipoValue === 'PAYPAL') {
            plataformaFields.classList.add('active');
            // Quitar requeridos de tarjeta
            const titular = document.getElementById('titular');
            const numeroTarjeta = document.getElementById('numeroTarjeta');
            if (titular) titular.required = false;
            if (numeroTarjeta) numeroTarjeta.required = false;
        } else {
            // Quitar requeridos
            const titular = document.getElementById('titular');
            const numeroTarjeta = document.getElementById('numeroTarjeta');
            if (titular) titular.required = false;
            if (numeroTarjeta) numeroTarjeta.required = false;
        }
    }

    // Llamar updateConditionalFields al cargar la página si estamos en el formulario de métodos de pago
    const tipoSelect = document.getElementById('tipo');
    if (tipoSelect) {
        updateConditionalFields();

        // Agregar listener para cambios
        tipoSelect.addEventListener('change', updateConditionalFields);
    }

    // Formatear fecha de vencimiento automáticamente
    const fechaVencimientoInput = document.getElementById('fechaVencimiento');
    if (fechaVencimientoInput) {
        fechaVencimientoInput.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 6);
            }
            e.target.value = value;
        });
    }

    // Validar solo números en últimos 4 dígitos de tarjeta
    const numeroTarjetaInput = document.getElementById('numeroTarjeta');
    if (numeroTarjetaInput) {
        numeroTarjetaInput.addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '').substring(0, 4);
        });
    }
});

console.log('🎬 CineArchive - Sistema cargado correctamente');
