/**
 * Add Book Page
 * Handles form validation for adding books
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;
    
    const title = form.querySelector('input[name="title"]');
    const categoryId = form.querySelector('select[name="category_id"]');
    const publisherId = form.querySelector('select[name="publisher_id"]');
    const authorCheckboxes = form.querySelectorAll('input[name="author_ids"]');
    const quantity = form.querySelector('input[name="quantity"]');
    
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
    
    /**
     * Validate at least one author selected
     */
    function validateAuthors() {
        let hasSelection = false;
        authorCheckboxes.forEach(function(cb) {
            if (cb.checked) {
                hasSelection = true;
            }
        });
        
        if (!hasSelection) {
            const firstCheckbox = authorCheckboxes[0];
            if (firstCheckbox && firstCheckbox.closest('.form-field')) {
                const holder = firstCheckbox.closest('.form-field');
                let errorElement = holder.querySelector('.field-error');
                if (!errorElement) {
                    errorElement = document.createElement('div');
                    errorElement.className = 'field-error';
                    holder.appendChild(errorElement);
                }
                errorElement.textContent = 'At least one author is required.';
            }
            return false;
        }
        
        // Clear error if valid
        if (authorCheckboxes.length > 0) {
            const holder = authorCheckboxes[0].closest('.form-field');
            if (holder) {
                const errorElement = holder.querySelector('.field-error');
                if (errorElement) {
                    errorElement.remove();
                }
            }
        }
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
    
    authorCheckboxes.forEach(function(cb) {
        cb.addEventListener('change', validateAuthors);
    });
    
    if (quantity) {
        bindRealtimeValidation(quantity, function() {
            const value = parseInt(quantity.value);
            if (!quantity.value || value <= 0) {
                setFieldError(quantity, 'Quantity must be at least 1.');
                return false;
            }
            clearFieldError(quantity);
            return true;
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
        } else if (categoryId) {
            clearFieldError(categoryId);
        }
        
        if (publisherId && !publisherId.value) {
            setFieldError(publisherId, 'Publisher is required.');
            isValid = false;
        } else if (publisherId) {
            clearFieldError(publisherId);
        }
        
        if (!validateAuthors()) {
            isValid = false;
        }
        
        if (quantity) {
            const value = parseInt(quantity.value);
            if (!quantity.value || value <= 0) {
                setFieldError(quantity, 'Quantity must be at least 1.');
                isValid = false;
            }
        }
        
        if (!isValid) {
            e.preventDefault();
        }
    });
})();

