/**
 * Member Registration Page
 * Handles form validation for member registration
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    // Import validation utilities
    // Note: In a real build system, these would be imported
    // For now, we'll use the global functions from validate.js
    
    const email = form.querySelector('input[name="email"]');
    const requiredFields = ['username', 'password', 'full_name', 'email'];
    const dob = form.querySelector('input[name="date_of_birth"]');
    const membership = form.querySelector('select[name="membership_type"]');
    
    // Set form to noValidate to handle custom validation
    form.setAttribute('novalidate', 'novalidate');
    
    /**
     * Validate email field
     */
    function validateEmailField() {
        const value = email.value.trim();
        if (!value) {
            setFieldError(email, 'This field is required.');
            return false;
        }
        
        // Use native HTML5 validation if available, otherwise use regex
        if (email.checkValidity && !email.checkValidity()) {
            setFieldError(email, 'Email format is invalid.');
            return false;
        } else if (!validateEmail(value)) {
            setFieldError(email, 'Email format is invalid.');
            return false;
        }
        
        clearFieldError(email);
        return true;
    }
    
    /**
     * Validate required field
     */
    function validateRequiredField(input) {
        if (!input.value.trim()) {
            setFieldError(input, 'This field is required.');
            return false;
        }
        clearFieldError(input);
        return true;
    }
    
    /**
     * Validate date of birth
     */
    function validateDateOfBirth() {
        if (!dob.value) {
            clearFieldError(dob);
            return true; // Optional field
        }
        
        const selected = new Date(dob.value);
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        if (!(selected < today)) {
            setFieldError(dob, 'Date of Birth must be in the past.');
            return false;
        }
        
        clearFieldError(dob);
        return true;
    }
    
    // Bind realtime validation to required fields
    requiredFields.forEach(fieldName => {
        const field = form.querySelector(`[name="${fieldName}"]`);
        if (!field) return;
        
        if (fieldName === 'email') {
            bindRealtimeValidation(field, validateEmailField);
            // Run once on load to clear server-side errors if already valid
            validateEmailField();
        } else {
            bindRealtimeValidation(field, function() {
                if (field.value.trim()) {
                    clearFieldError(field);
                } else {
                    setFieldError(field, 'This field is required.');
                }
            });
        }
    });
    
    // Validate date of birth
    if (dob) {
        bindRealtimeValidation(dob, validateDateOfBirth);
    }
    
    // Validate membership type
    if (membership) {
        membership.addEventListener('change', function() {
            if (membership.value && membership.value.trim().length > 0) {
                clearFieldError(membership);
            }
        });
    }
    
    // Form submission validation
    form.addEventListener('submit', function(e) {
        let isValid = true;
        
        // Validate all required fields
        requiredFields.forEach(fieldName => {
            const field = form.querySelector(`[name="${fieldName}"]`);
            if (field) {
                if (fieldName === 'email') {
                    if (!validateEmailField()) {
                        isValid = false;
                    }
                } else {
                    if (!validateRequiredField(field)) {
                        isValid = false;
                    }
                }
            }
        });
        
        // Validate date of birth
        if (dob && !validateDateOfBirth()) {
            isValid = false;
        }
        
        if (!isValid) {
            e.preventDefault();
        }
    });
})();

