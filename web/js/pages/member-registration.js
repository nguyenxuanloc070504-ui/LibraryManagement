/**
 * Member Registration Page
 * Handles form validation for member registration
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    // Get context path for API calls
    // Try to get from window.APP_CONTEXT_PATH first (set by JSP)
    let contextPath = window.APP_CONTEXT_PATH || '';
    
    // Fallback: extract from form action or current location
    if (!contextPath) {
        if (form.action) {
            try {
                const url = new URL(form.action, window.location.origin);
                const parts = url.pathname.split('/').filter(p => p);
                if (parts.length > 0) {
                    contextPath = '/' + parts[0];
                }
            } catch (e) {
                // Extract from current location
                const path = window.location.pathname;
                const parts = path.split('/').filter(p => p);
                if (parts.length > 0) {
                    contextPath = '/' + parts[0];
                }
            }
        } else {
            const path = window.location.pathname;
            const parts = path.split('/').filter(p => p);
            if (parts.length > 0) {
                contextPath = '/' + parts[0];
            }
        }
    }
    
    // Initialize all validations using system-wide validation functions
    initUsernameValidation('username', {
        message: 'Username is required',
        duplicateMessage: 'Username already exists',
        contextPath: contextPath,
        realtime: true,
        debounceMs: 500,
        form: form
    });
    
    initPasswordValidation('password', {
        minLength: 6,
        message: 'Password must be at least 6 characters',
        realtime: true,
        form: form
    });
    
    initEmailValidation('email', {
        message: 'Invalid email format',
        realtime: true,
        form: form
    });
    
    initPhoneValidation('phone', {
        message: 'Phone must be exactly 10 digits',
        realtime: true,
        form: form
    });
    
    initDateOfBirthValidation('date_of_birth', {
        message: 'Date of Birth must be in the past',
        realtime: true,
        form: form
    });
    
    // Validate membership type on change
    const membership = form.querySelector('select[name="membership_type"]');
    if (membership) {
        membership.addEventListener('change', function() {
            if (membership.value && membership.value.trim().length > 0) {
                clearFieldError(membership);
            }
        });
    }
})();

