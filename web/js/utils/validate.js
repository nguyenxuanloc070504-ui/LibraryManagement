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
 * Validate password minimum length
 * @param {string} password - Password to validate
 * @param {number} minLength - Minimum length (default: 6)
 * @returns {boolean} - True if valid
 */
function validatePassword(password, minLength = 6) {
    return password != null && password.length >= minLength;
}

/**
 * Validate phone number format (exactly 10 digits)
 * @param {string} phone - Phone number to validate
 * @returns {boolean} - True if valid
 */
function validatePhone(phone) {
    if (!phone || phone.trim() === '') return true; // Optional field
    return /^\d{10}$/.test(phone.trim());
}

/**
 * Check if username exists in database (async)
 * @param {string} username - Username to check
 * @param {string} contextPath - Application context path
 * @returns {Promise<boolean>} - True if username exists (duplicate)
 */
async function checkUsernameExists(username, contextPath) {
    if (!username || username.trim() === '') return false;
    
    try {
        const response = await fetch(`${contextPath}/api/check-username?username=${encodeURIComponent(username.trim())}`);
        const data = await response.json();
        return data.exists === true;
    } catch (error) {
        console.error('Error checking username:', error);
        return false; // On error, don't block submission (server will validate)
    }
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

/**
 * Initialize email validation for an input field
 * Can be used system-wide for any email input
 * @param {HTMLInputElement|string} inputOrId - Input element or its ID
 * @param {Object} options - Configuration options
 * @param {string} options.message - Custom error message (default: "Invalid email format")
 * @param {boolean} options.realtime - Enable real-time validation (default: true)
 * @param {HTMLElement} options.form - Form element to validate on submit (optional)
 */
function initEmailValidation(inputOrId, options = {}) {
    const input = typeof inputOrId === 'string' 
        ? document.getElementById(inputOrId) || document.querySelector(inputOrId)
        : inputOrId;
    
    if (!input) return;
    
    const {
        message = 'Invalid email format',
        realtime = true,
        form = null
    } = options;
    
    const validateEmailField = function() {
        const email = input.value.trim();
        
        // Clear error if empty (let HTML5 required handle it)
        if (email === '') {
            clearFieldError(input);
            return true;
        }
        
        // Validate email format
        if (!validateEmail(email)) {
            setFieldError(input, message);
            return false;
        }
        
        clearFieldError(input);
        return true;
    };
    
    // Bind realtime validation if enabled
    if (realtime) {
        bindRealtimeValidation(input, validateEmailField);
    }
    
    // Validate on form submit if form is provided
    const formElement = form || input.closest('form');
    if (formElement) {
        formElement.addEventListener('submit', function(e) {
            if (!validateEmailField()) {
                e.preventDefault();
                input.focus();
            }
        });
    }
    
    return validateEmailField;
}

/**
 * Initialize password validation for an input field
 * @param {HTMLInputElement|string} inputOrId - Input element or its ID
 * @param {Object} options - Configuration options
 * @param {number} options.minLength - Minimum password length (default: 6)
 * @param {string} options.message - Custom error message
 * @param {boolean} options.realtime - Enable real-time validation (default: true)
 * @param {HTMLElement} options.form - Form element to validate on submit (optional)
 */
function initPasswordValidation(inputOrId, options = {}) {
    const input = typeof inputOrId === 'string' 
        ? document.getElementById(inputOrId) || document.querySelector(inputOrId)
        : inputOrId;
    
    if (!input) return;
    
    const {
        minLength = 6,
        message = `Password must be at least ${minLength} characters`,
        realtime = true,
        form = null
    } = options;
    
    const validatePasswordField = function() {
        const password = input.value;
        
        // Clear error if empty (let HTML5 required handle it)
        if (password === '') {
            clearFieldError(input);
            return true;
        }
        
        // Validate password length
        if (!validatePassword(password, minLength)) {
            setFieldError(input, message);
            return false;
        }
        
        clearFieldError(input);
        return true;
    };
    
    // Bind realtime validation if enabled
    if (realtime) {
        bindRealtimeValidation(input, validatePasswordField);
    }
    
    // Validate on form submit if form is provided
    const formElement = form || input.closest('form');
    if (formElement) {
        formElement.addEventListener('submit', function(e) {
            if (!validatePasswordField()) {
                e.preventDefault();
                input.focus();
            }
        });
    }
    
    return validatePasswordField;
}

/**
 * Initialize phone validation for an input field
 * @param {HTMLInputElement|string} inputOrId - Input element or its ID
 * @param {Object} options - Configuration options
 * @param {string} options.message - Custom error message (default: "Phone must be 10 digits")
 * @param {boolean} options.realtime - Enable real-time validation (default: true)
 * @param {HTMLElement} options.form - Form element to validate on submit (optional)
 */
function initPhoneValidation(inputOrId, options = {}) {
    const input = typeof inputOrId === 'string' 
        ? document.getElementById(inputOrId) || document.querySelector(inputOrId)
        : inputOrId;
    
    if (!input) return;
    
    const {
        message = 'Phone must be exactly 10 digits',
        realtime = true,
        form = null
    } = options;
    
    const validatePhoneField = function() {
        const phone = input.value.trim();
        
        // Clear error if empty (optional field)
        if (phone === '') {
            clearFieldError(input);
            return true;
        }
        
        // Validate phone format
        if (!validatePhone(phone)) {
            setFieldError(input, message);
            return false;
        }
        
        clearFieldError(input);
        return true;
    };
    
    // Bind realtime validation if enabled
    if (realtime) {
        bindRealtimeValidation(input, validatePhoneField);
    }
    
    // Validate on form submit if form is provided
    const formElement = form || input.closest('form');
    if (formElement) {
        formElement.addEventListener('submit', function(e) {
            if (!validatePhoneField()) {
                e.preventDefault();
                input.focus();
            }
        });
    }
    
    return validatePhoneField;
}

/**
 * Initialize date of birth validation (must be in the past)
 * @param {HTMLInputElement|string} inputOrId - Input element or its ID
 * @param {Object} options - Configuration options
 * @param {string} options.message - Custom error message
 * @param {boolean} options.realtime - Enable real-time validation (default: true)
 * @param {HTMLElement} options.form - Form element to validate on submit (optional)
 */
function initDateOfBirthValidation(inputOrId, options = {}) {
    const input = typeof inputOrId === 'string' 
        ? document.getElementById(inputOrId) || document.querySelector(inputOrId)
        : inputOrId;
    
    if (!input) return;
    
    const {
        message = 'Date of Birth must be in the past',
        realtime = true,
        form = null
    } = options;
    
    const validateDateField = function() {
        if (!input.value) {
            clearFieldError(input);
            return true; // Optional field
        }
        
        if (!validateDatePast(input)) {
            setFieldError(input, message);
            return false;
        }
        
        clearFieldError(input);
        return true;
    };
    
    // Bind realtime validation if enabled
    if (realtime) {
        bindRealtimeValidation(input, validateDateField);
    }
    
    // Validate on form submit if form is provided
    const formElement = form || input.closest('form');
    if (formElement) {
        formElement.addEventListener('submit', function(e) {
            if (!validateDateField()) {
                e.preventDefault();
                input.focus();
            }
        });
    }
    
    return validateDateField;
}

/**
 * Initialize username validation with duplicate check
 * @param {HTMLInputElement|string} inputOrId - Input element or its ID
 * @param {Object} options - Configuration options
 * @param {string} options.message - Custom error message for required
 * @param {string} options.duplicateMessage - Custom error message for duplicate
 * @param {string} options.contextPath - Application context path
 * @param {boolean} options.realtime - Enable real-time validation (default: true)
 * @param {number} options.debounceMs - Debounce time for duplicate check in ms (default: 500)
 * @param {HTMLElement} options.form - Form element to validate on submit (optional)
 */
function initUsernameValidation(inputOrId, options = {}) {
    const input = typeof inputOrId === 'string' 
        ? document.getElementById(inputOrId) || document.querySelector(inputOrId)
        : inputOrId;
    
    if (!input) return;
    
    const {
        message = 'Username is required',
        duplicateMessage = 'Username already exists',
        contextPath = '',
        realtime = true,
        debounceMs = 500,
        form = null
    } = options;
    
    let checkTimeout = null;
    let isChecking = false;
    
    const validateUsernameField = async function() {
        const username = input.value.trim();
        
        // Clear error if empty (let HTML5 required handle it)
        if (username === '') {
            clearFieldError(input);
            return true;
        }
        
        // Required validation
        if (username.length === 0) {
            setFieldError(input, message);
            return false;
        }
        
        // Check for duplicate (with debounce)
        if (contextPath) {
            clearTimeout(checkTimeout);
            
            checkTimeout = setTimeout(async () => {
                if (isChecking) return;
                isChecking = true;
                
                const exists = await checkUsernameExists(username, contextPath);
                
                if (exists) {
                    setFieldError(input, duplicateMessage);
                } else {
                    clearFieldError(input);
                }
                
                isChecking = false;
            }, debounceMs);
        }
        
        // Don't wait for async check - let it run in background
        clearFieldError(input);
        return true;
    };
    
    // Bind realtime validation if enabled
    if (realtime) {
        bindRealtimeValidation(input, validateUsernameField);
    }
    
    // Validate on form submit if form is provided
    const formElement = form || input.closest('form');
    if (formElement) {
        formElement.addEventListener('submit', async function(e) {
            const username = input.value.trim();
            
            if (username === '') {
                setFieldError(input, message);
                e.preventDefault();
                input.focus();
                return;
            }
            
            // Check duplicate synchronously on submit
            if (contextPath) {
                const exists = await checkUsernameExists(username, contextPath);
                if (exists) {
                    setFieldError(input, duplicateMessage);
                    e.preventDefault();
                    input.focus();
                    return;
                }
            }
        });
    }
    
    return validateUsernameField;
}

