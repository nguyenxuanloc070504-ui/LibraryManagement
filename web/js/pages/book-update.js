/**
 * Update Book Page
 * Handles form validation for updating books
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    const title = form.querySelector('input[name="title"]');
    const categoryId = form.querySelector('select[name="category_id"]');
    const publisherId = form.querySelector('select[name="publisher_id"]');
    
    // Set form to noValidate to handle custom validation
    form.setAttribute('novalidate', 'novalidate');
    
    /**
     * Validate required field
     */
    function validateRequiredField(input, fieldName) {
        if (!input.value.trim()) {
            setFieldError(input, fieldName + ' is required.');
            return false;
        }
        clearFieldError(input);
        return true;
    }
    
    // Bind realtime validation
    if (title) {
        bindRealtimeValidation(title, function() {
            validateRequiredField(title, 'Title');
        });
    }
    
    if (categoryId) {
        categoryId.addEventListener('change', function() {
            if (categoryId.value) {
                clearFieldError(categoryId);
            }
        });
    }
    
    if (publisherId) {
        publisherId.addEventListener('change', function() {
            if (publisherId.value) {
                clearFieldError(publisherId);
            }
        });
    }
    
    // Form submission validation
    form.addEventListener('submit', function(e) {
        let isValid = true;
        
        if (title && !validateRequiredField(title, 'Title')) {
            isValid = false;
        }
        
        if (categoryId && !categoryId.value) {
            setFieldError(categoryId, 'Category is required.');
            isValid = false;
        }
        
        if (publisherId && !publisherId.value) {
            setFieldError(publisherId, 'Publisher is required.');
            isValid = false;
        }
        
        if (!isValid) {
            e.preventDefault();
        }
    });
})();

