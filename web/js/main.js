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
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();

