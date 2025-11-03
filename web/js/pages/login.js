/**
 * Login Page
 * Handles login page specific functionality
 */

(function() {
    'use strict';
    
    // Add any login-specific JavaScript here
    // For example: remember me functionality, auto-fill, etc.
    
    // Check if there are any error messages and focus on first input
    const errorAlert = document.querySelector('.alert-error');
    if (errorAlert) {
        const firstInput = document.querySelector('form input[type="text"], form input[type="email"]');
        if (firstInput) {
            setTimeout(() => firstInput.focus(), 100);
        }
    }
})();

