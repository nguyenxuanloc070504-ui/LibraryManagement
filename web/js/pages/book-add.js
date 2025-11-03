/**
 * Add Book Page
 * Handles form validation for adding books
 */

(function() {
    'use strict';
    
    const form = document.querySelector('form.auth-form');
    if (!form) return;

    // If server set success alert, redirect to list after 3s
    const successAlert = document.querySelector('.alert-success');
    if (successAlert) {
        const actionUrl = form.getAttribute('action') || '';
        let base = '';
        const idx = actionUrl.indexOf('/book/');
        if (idx >= 0) base = actionUrl.substring(0, idx);
        setTimeout(() => {
            window.location.href = base + '/books';
        }, 3000);
    }
    
    const title = form.querySelector('input[name="title"]');
    const isbn = form.querySelector('input[name="isbn"]');
    const categoryId = form.querySelector('select[name="category_id"]');
    const publisherId = form.querySelector('select[name="publisher_id"]');
    const authorNamesInput = form.querySelector('input[name="author_names"]');
    const publicationYear = form.querySelector('input[name="publication_year"]');
    const edition = form.querySelector('input[name="edition"]');
    const language = form.querySelector('input[name="language"]');
    const pages = form.querySelector('input[name="pages"]');
    const shelfLocation = form.querySelector('input[name="shelf_location"]');
    const coverFile = form.querySelector('input[name="cover_file"]');
    const description = form.querySelector('textarea[name="description"]');
    const quantity = form.querySelector('input[name="quantity"]');
    const acquisitionDate = form.querySelector('input[name="acquisition_date"]');
    const conditionStatus = form.querySelector('select[name="condition_status"]');
    const price = form.querySelector('input[name="price"]');
    
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

    function isInteger(value) {
        return /^-?\d+$/.test(String(value).trim());
    }

    function isDecimal(value) {
        return /^\d+(?:\.\d{1,2})?$/.test(String(value).trim());
    }

    function validateIsbnField() {
        if (!isbn) return true;
        const v = isbn.value.trim();
        if (v === '') { clearFieldError(isbn); return true; }
        const ok = /^(?:\d[\-\s]?){9}[\dxX]$/.test(v) || /^(?:\d[\-\s]?){13}$/.test(v);
        if (!ok) { setFieldError(isbn, 'ISBN must be 10 or 13 digits.'); return false; }
        clearFieldError(isbn); return true;
    }

    function validatePublicationYearField() {
        if (!publicationYear) return true;
        const v = publicationYear.value.trim();
        if (v === '') { clearFieldError(publicationYear); return true; }
        if (!isInteger(v)) { setFieldError(publicationYear, 'Publication year must be an integer.'); return false; }
        const num = parseInt(v, 10);
        const current = new Date().getFullYear() + 1;
        if (num < 1000 || num > current) {
            setFieldError(publicationYear, `Year must be between 1000 and ${current}.`);
            return false;
        }
        clearFieldError(publicationYear); return true;
    }

    function validatePagesField() {
        if (!pages) return true;
        const v = pages.value.trim();
        if (v === '') { clearFieldError(pages); return true; }
        if (!isInteger(v) || parseInt(v,10) < 1) {
            setFieldError(pages, 'Pages must be an integer >= 1.');
            return false;
        }
        clearFieldError(pages); return true;
    }

    function validateQuantityField() {
        if (!quantity) return true;
        const v = quantity.value.trim();
        if (!isInteger(v) || parseInt(v,10) < 1) {
            setFieldError(quantity, 'Quantity must be an integer >= 1.');
            return false;
        }
        clearFieldError(quantity); return true;
    }

    function validatePriceField() {
        if (!price) return true;
        const v = price.value.trim();
        if (v === '') { clearFieldError(price); return true; }
        if (!isDecimal(v)) { setFieldError(price, 'Price must be a number with up to 2 decimals.'); return false; }
        if (parseFloat(v) < 0) { setFieldError(price, 'Price must be >= 0.'); return false; }
        clearFieldError(price); return true;
    }

    function validateAcquisitionDateField() {
        if (!acquisitionDate) return true;
        const v = acquisitionDate.value;
        if (!v) { clearFieldError(acquisitionDate); return true; }
        const sel = new Date(v);
        const today = new Date(); today.setHours(0,0,0,0);
        if (isNaN(sel.getTime())) { setFieldError(acquisitionDate, 'Invalid date.'); return false; }
        if (sel > today) { setFieldError(acquisitionDate, 'Date cannot be in the future.'); return false; }
        clearFieldError(acquisitionDate); return true;
    }

    function validateConditionStatusField() {
        if (!conditionStatus) return true;
        const allowed = ['excellent','good','fair','poor','damaged'];
        const v = (conditionStatus.value || '').toLowerCase();
        if (!allowed.includes(v)) { setFieldError(conditionStatus, 'Invalid condition status.'); return false; }
        clearFieldError(conditionStatus); return true;
    }

    function validateCoverFileField() {
        if (!coverFile) return true;
        const f = coverFile.files && coverFile.files[0];
        if (!f) { clearFieldError(coverFile); return true; }
        if (!f.type || !f.type.startsWith('image/')) { setFieldError(coverFile, 'Cover must be an image file.'); return false; }
        const maxSize = 5 * 1024 * 1024; // 5MB
        if (f.size > maxSize) { setFieldError(coverFile, 'Image must be <= 5MB.'); return false; }
        clearFieldError(coverFile); return true;
    }
    
    function validateAuthors() {
        if (!authorNamesInput) return true;
        const value = authorNamesInput.value.trim();
        if (!value) {
            setFieldError(authorNamesInput, 'At least one author is required.');
            return false;
        }
        // Basic format: at least one non-empty name after splitting commas
        const names = value.split(',').map(s => s.trim()).filter(Boolean);
        if (names.length === 0) {
            setFieldError(authorNamesInput, 'At least one author is required.');
            return false;
        }
        clearFieldError(authorNamesInput);
        return true;
    }
    
    // Bind realtime validation
    if (title) {
        bindRealtimeValidation(title, function() {
            validateRequiredField(title, 'Title');
        });
    }

    if (isbn) { bindRealtimeValidation(isbn, validateIsbnField); }
    
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
    
    if (authorNamesInput) {
        bindRealtimeValidation(authorNamesInput, validateAuthors);
    }

    if (publicationYear) { bindRealtimeValidation(publicationYear, validatePublicationYearField); }
    if (pages) { bindRealtimeValidation(pages, validatePagesField); }
    if (quantity) { bindRealtimeValidation(quantity, validateQuantityField); }
    if (price) { bindRealtimeValidation(price, validatePriceField); }
    if (acquisitionDate) { bindRealtimeValidation(acquisitionDate, validateAcquisitionDateField); }
    if (conditionStatus) { conditionStatus.addEventListener('change', validateConditionStatusField); }
    if (coverFile) { coverFile.addEventListener('change', validateCoverFileField); }
    
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
        if (isbn && !validateIsbnField()) { isValid = false; }
        
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
        if (!validatePublicationYearField()) { isValid = false; }
        if (!validatePagesField()) { isValid = false; }
        if (!validateQuantityField()) { isValid = false; }
        if (!validatePriceField()) { isValid = false; }
        if (!validateAcquisitionDateField()) { isValid = false; }
        if (!validateConditionStatusField()) { isValid = false; }
        if (!validateCoverFileField()) { isValid = false; }
        
        if (!isValid) {
            e.preventDefault();
        }
    });
})();

