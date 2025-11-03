/**
 * Dropdown Component
 * Handles dropdown menu functionality
 */

/**
 * Initialize dropdown menu
 * @param {HTMLElement} dropdownElement - Dropdown container element
 */
function initDropdown(dropdownElement) {
    if (!dropdownElement) return;
    
    const trigger = dropdownElement.querySelector('.user-trigger, [data-dropdown-trigger]');
    const menu = dropdownElement.querySelector('.user-menu, [data-dropdown-menu]');
    
    if (!trigger || !menu) return;
    
    /**
     * Close the dropdown menu
     */
    function closeMenu() {
        dropdownElement.classList.remove('open');
        trigger.setAttribute('aria-expanded', 'false');
    }
    
    /**
     * Open the dropdown menu
     */
    function openMenu() {
        dropdownElement.classList.add('open');
        trigger.setAttribute('aria-expanded', 'true');
    }
    
    /**
     * Toggle the dropdown menu
     */
    function toggleMenu() {
        const isOpen = dropdownElement.classList.toggle('open');
        trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    }
    
    // Toggle on trigger click
    trigger.addEventListener('click', function(e) {
        e.stopPropagation();
        toggleMenu();
    });
    
    // Close on outside click
    document.addEventListener('click', function(e) {
        if (!dropdownElement.contains(e.target)) {
            closeMenu();
        }
    });
    
    // Close on Escape key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeMenu();
        }
    });
}

/**
 * Initialize all dropdowns on the page
 */
function initAllDropdowns() {
    const dropdowns = document.querySelectorAll('.user-dropdown, [data-dropdown]');
    dropdowns.forEach(dropdown => {
        initDropdown(dropdown);
    });
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAllDropdowns);
} else {
    initAllDropdowns();
}

