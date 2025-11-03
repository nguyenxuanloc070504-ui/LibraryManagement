/**
 * Toast Notification Component
 * Displays temporary notification messages
 */

/**
 * Show a toast notification
 * @param {string} message - Message to display
 * @param {string} type - Toast type: 'success', 'error', 'info', 'warning'
 * @param {number} duration - Duration in milliseconds (default: 3000)
 */
function showToast(message, type = 'info', duration = 3000) {
    // Create toast container if it doesn't exist
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 10000; display: flex; flex-direction: column; gap: 10px;';
        document.body.appendChild(container);
    }
    
    // Create toast element
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.style.cssText = `
        background: ${type === 'error' ? '#fee2e2' : type === 'success' ? '#d1fae5' : '#dbeafe'};
        color: ${type === 'error' ? '#b91c1c' : type === 'success' ? '#065f46' : '#1e40af'};
        padding: 12px 16px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        min-width: 250px;
        animation: slideIn 0.3s ease-out;
    `;
    toast.textContent = message;
    
    // Add animation
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    `;
    if (!document.getElementById('toast-animations')) {
        style.id = 'toast-animations';
        document.head.appendChild(style);
    }
    
    container.appendChild(toast);
    
    // Auto remove after duration
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => {
            toast.remove();
            // Remove container if empty
            if (container.children.length === 0) {
                container.remove();
            }
        }, 300);
    }, duration);
}

/**
 * Show success toast
 */
function showSuccessToast(message, duration) {
    showToast(message, 'success', duration);
}

/**
 * Show error toast
 */
function showErrorToast(message, duration) {
    showToast(message, 'error', duration);
}

/**
 * Show info toast
 */
function showInfoToast(message, duration) {
    showToast(message, 'info', duration);
}

/**
 * Show warning toast
 */
function showWarningToast(message, duration) {
    showToast(message, 'warning', duration);
}

