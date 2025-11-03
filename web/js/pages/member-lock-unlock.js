/**
 * Member Lock/Unlock Page
 * Handles form validation for account lock/unlock
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    const actionRadios = form.querySelectorAll('input[name="action"]');
    
    // Set form to noValidate to handle custom validation
    form.setAttribute('novalidate', 'novalidate');
    
    // Form submission validation
    form.addEventListener('submit', function(e) {
        let hasSelection = false;
        
        actionRadios.forEach(function(radio) {
            if (radio.checked) {
                hasSelection = true;
            }
        });
        
        if (!hasSelection) {
            e.preventDefault();
            const firstRadio = actionRadios[0];
            if (firstRadio && firstRadio.closest('.radio-option')) {
                const holder = firstRadio.closest('.form-field');
                if (holder) {
                    let errorElement = holder.querySelector('.field-error');
                    if (!errorElement) {
                        errorElement = document.createElement('div');
                        errorElement.className = 'field-error';
                        holder.appendChild(errorElement);
                    }
                    errorElement.textContent = 'Please select an action.';
                }
            }
        }
    });
    
    // Clear error on radio change
    actionRadios.forEach(function(radio) {
        radio.addEventListener('change', function() {
            actionRadios.forEach(function(r) {
                const holder = r.closest('.form-field');
                if (holder) {
                    const errorElement = holder.querySelector('.field-error');
                    if (errorElement) {
                        errorElement.remove();
                    }
                }
            });
        });
    });
})();

