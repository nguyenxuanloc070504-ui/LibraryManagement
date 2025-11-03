/**
 * Modal Component
 * Handles modal dialog functionality
 */

/**
 * Initialize a modal
 * @param {HTMLElement} modalElement - Modal container element
 */
function initModal(modalElement) {
    if (!modalElement) return;
    
    const openTriggers = document.querySelectorAll(`[data-modal-open="${modalElement.id}"]`);
    const closeTriggers = modalElement.querySelectorAll('[data-modal-close]');
    const overlay = modalElement.querySelector('.modal-overlay');
    
    /**
     * Open the modal
     */
    function openModal() {
        modalElement.classList.add('open');
        document.body.style.overflow = 'hidden';
    }
    
    /**
     * Close the modal
     */
    function closeModal() {
        modalElement.classList.remove('open');
        document.body.style.overflow = '';
    }
    
    // Open triggers
    openTriggers.forEach(trigger => {
        trigger.addEventListener('click', function(e) {
            e.preventDefault();
            openModal();
        });
    });
    
    // Close triggers
    closeTriggers.forEach(trigger => {
        trigger.addEventListener('click', function(e) {
            e.preventDefault();
            closeModal();
        });
    });
    
    // Close on overlay click
    if (overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                closeModal();
            }
        });
    }
    
    // Close on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && modalElement.classList.contains('open')) {
            closeModal();
        }
    });
}

/**
 * Initialize all modals on the page
 */
function initAllModals() {
    const modals = document.querySelectorAll('.modal, [data-modal]');
    modals.forEach(modal => {
        initModal(modal);
    });
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAllModals);
} else {
    initAllModals();
}

