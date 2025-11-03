/**
 * Validation Utilities
 */

/**
 * Validate email format
 * @param {string} email - Email to validate
 * @returns {boolean} - True if valid
 */
function validateEmail(email) {
    return /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email);
}

/**
 * Validate required field
 * @param {HTMLInputElement} input - Input element to validate
 * @returns {boolean} - True if valid
 */
function validateRequired(input) {
    return input.value.trim().length > 0;
}

/**
 * Validate date is in the past
 * @param {HTMLInputElement} dateInput - Date input element
 * @returns {boolean} - True if valid
 */
function validateDatePast(dateInput) {
    if (!dateInput.value) return true; // Optional field
    const selected = new Date(dateInput.value);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    return selected < today;
}

/**
 * Set error message for a field
 * @param {HTMLInputElement} input - Input element
 * @param {string} message - Error message
 */
function setFieldError(input, message) {
    const holder = input.closest('.form-field');
    if (!holder) return;
    
    let errorElement = holder.querySelector('.field-error');
    if (!errorElement) {
        errorElement = document.createElement('div');
        errorElement.className = 'field-error';
        holder.appendChild(errorElement);
    }
    errorElement.textContent = message;
}

/**
 * Clear error message for a field
 * @param {HTMLInputElement} input - Input element
 */
function clearFieldError(input) {
    const holder = input.closest('.form-field');
    if (!holder) return;
    
    const errorElement = holder.querySelector('.field-error');
    if (errorElement) {
        errorElement.remove();
    }
}

/**
 * Bind realtime validation to an input
 * @param {HTMLInputElement} element - Input element
 * @param {Function} handler - Validation handler function
 */
function bindRealtimeValidation(element, handler) {
    ['input', 'change', 'keyup', 'blur', 'paste'].forEach(eventType => {
        element.addEventListener(eventType, handler);
    });
}

