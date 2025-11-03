/**
 * Radio Component
 * Handles styling of radio options when radio buttons are checked
 */

(function() {
    'use strict';

    /**
     * Initialize radio option styling
     * Adds/removes 'is-checked' class on radio-option when radio is checked/unchecked
     */
    function initRadioOptions() {
        const radioGroups = document.querySelectorAll('.radio-group');
        
        radioGroups.forEach(function(group) {
            const radios = group.querySelectorAll('input[type="radio"]');
            
            radios.forEach(function(radio) {
                // Update on load if already checked
                updateRadioOptionClass(radio);
                
                // Update on change
                radio.addEventListener('change', function() {
                    // Remove is-checked from all options in this group
                    const allOptions = group.querySelectorAll('.radio-option');
                    allOptions.forEach(function(option) {
                        option.classList.remove('is-checked');
                    });
                    
                    // Add is-checked to the selected option
                    updateRadioOptionClass(radio);
                });
            });
        });
    }

    /**
     * Update the is-checked class on radio option based on radio state
     */
    function updateRadioOptionClass(radio) {
        const radioOption = radio.closest('.radio-option');
        if (radioOption) {
            if (radio.checked) {
                radioOption.classList.add('is-checked');
            } else {
                radioOption.classList.remove('is-checked');
            }
        }
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initRadioOptions);
    } else {
        initRadioOptions();
    }
})();


