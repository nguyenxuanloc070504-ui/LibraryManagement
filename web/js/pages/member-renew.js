/**
 * Member Renew Page
 * Handles form validation for membership renewal
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    const extensionMonths = form.querySelector('select[name="extension_months"]');
    
    // Set form to noValidate to handle custom validation
    if (form) {
        form.setAttribute('novalidate', 'novalidate');
        
        // Form submission validation
        form.addEventListener('submit', function(e) {
            if (!extensionMonths || !extensionMonths.value) {
                e.preventDefault();
                if (extensionMonths) {
                    setFieldError(extensionMonths, 'Please select an extension period.');
                }
            }
        });
    }
})();

