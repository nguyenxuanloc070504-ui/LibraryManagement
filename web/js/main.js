/**
 * Main JavaScript Entry Point
 * Initializes all components and utilities
 */

(function() {
    'use strict';
    
    /**
     * Initialize all components when DOM is ready
     */
    function init() {
        // Components are auto-initialized, but we can add global initialization here
        
        // Example: Initialize dropdowns (already auto-initialized in dropdown.js)
        // But we can ensure it's called here as well
        if (typeof initAllDropdowns === 'function') {
            initAllDropdowns();
        }
        
        // Auto-dismiss alerts after 3s (pastel alerts)
        const alerts = document.querySelectorAll('.alert-success, .alert-error');
        if (alerts.length) {
            setTimeout(() => {
                alerts.forEach(a => {
                    a.style.transition = 'opacity .3s ease';
                    a.style.opacity = '0';
                    setTimeout(() => a.remove(), 300);
                });
            }, 3000);
        }

        // Add any other global initialization here
        console.log('Library Management System initialized');

        // Global confirm dialog
        window.confirmDialog = function(options) {
            const {
                title = 'Confirm',
                message = 'Are you sure?',
                confirmText = 'Confirm',
                cancelText = 'Cancel'
            } = options || {};
            return new Promise(resolve => {
                const modal = document.createElement('div');
                modal.className = 'modal open';
                modal.innerHTML = `
<div class="modal-overlay">
  <div class="modal-dialog" role="dialog" aria-modal="true" aria-labelledby="confirm-title">
    <div class="modal-header" id="confirm-title">${title}</div>
    <div class="modal-body">${message}</div>
    <div class="modal-actions">
      <button class="btn-secondary inline-btn" data-cancel>${cancelText}</button>
      <button class="btn-icon-text" data-confirm>${confirmText}</button>
    </div>
  </div>
</div>`;
                document.body.appendChild(modal);

                const cleanup = (result) => {
                    modal.classList.remove('open');
                    setTimeout(() => modal.remove(), 0);
                    document.body.style.overflow = '';
                    resolve(result);
                };

                document.body.style.overflow = 'hidden';
                modal.querySelector('[data-cancel]').addEventListener('click', () => cleanup(false));
                modal.querySelector('[data-confirm]').addEventListener('click', () => cleanup(true));
                modal.querySelector('.modal-overlay').addEventListener('click', (e) => {
                    if (e.target.classList.contains('modal-overlay')) cleanup(false);
                });
                document.addEventListener('keydown', function esc(e) {
                    if (e.key === 'Escape') {
                        document.removeEventListener('keydown', esc);
                        cleanup(false);
                    }
                });
            });
        };

        // Delegate data-confirm across the app
        document.addEventListener('click', async function(e) {
            const target = e.target.closest('[data-confirm]');
            if (!target) return;
            const href = target.getAttribute('href');
            const method = (target.getAttribute('data-method') || 'get').toLowerCase();
            const message = target.getAttribute('data-confirm-message') || 'Are you sure?';
            e.preventDefault();
            const ok = await window.confirmDialog({ title: 'Please Confirm', message, confirmText: 'OK', cancelText: 'Cancel' });
            if (!ok) return;
            if (href) {
                if (method === 'post') {
                    const form = document.createElement('form');
                    form.method = 'post';
                    form.action = href;
                    document.body.appendChild(form);
                    form.submit();
                } else {
                    window.location.href = href;
                }
            }
        });
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();

