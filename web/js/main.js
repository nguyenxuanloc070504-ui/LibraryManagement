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

