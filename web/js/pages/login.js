/**
 * Login Page
 * Handles login page specific functionality
 */

(function() {
    'use strict';
    
    // Initialize email validation for login form using system-wide function
    initEmailValidation('email', {
        message: 'Invalid email format',
        realtime: true,
        form: document.querySelector('.auth-form')
    });
    
    // Check if there are any error messages and focus on first input
    const errorAlert = document.querySelector('.alert-error');
    if (errorAlert) {
        const firstInput = document.querySelector('form input[type="text"], form input[type="email"]');
        if (firstInput) {
            setTimeout(() => firstInput.focus(), 100);
        }
    }
})();

