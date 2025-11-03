/**
 * Member Update Page
 * Handles form validation for member update
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    const email = form.querySelector('input[name="email"]');
    const fullName = form.querySelector('input[name="full_name"]');
    const dob = form.querySelector('input[name="date_of_birth"]');
    
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
        if (!dob || !dob.value) {
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
    
    // Bind realtime validation
    if (email) {
        bindRealtimeValidation(email, validateEmailField);
        validateEmailField(); // Run once on load
    }
    
    if (fullName) {
        bindRealtimeValidation(fullName, function() {
            validateRequiredField(fullName);
        });
    }
    
    if (dob) {
        bindRealtimeValidation(dob, validateDateOfBirth);
    }
    
    // Form submission validation
    form.addEventListener('submit', function(e) {
        let isValid = true;
        
        if (email && !validateEmailField()) {
            isValid = false;
        }
        
        if (fullName && !validateRequiredField(fullName)) {
            isValid = false;
        }
        
        if (dob && !validateDateOfBirth()) {
            isValid = false;
        }
        
        if (!isValid) {
            e.preventDefault();
        }
    });
})();

