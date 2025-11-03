/**
 * API Utilities
 * Helper functions for making API calls
 */

/**
 * Make a fetch request with error handling
 * @param {string} url - URL to fetch
 * @param {Object} options - Fetch options
 * @returns {Promise<Response>} - Fetch response
 */
async function apiRequest(url, options = {}) {
    try {
        const response = await fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response;
    } catch (error) {
        console.error('API request failed:', error);
        throw error;
    }
}

/**
 * Get JSON data from API
 * @param {string} url - URL to fetch
 * @returns {Promise<Object>} - Parsed JSON data
 */
async function apiGet(url) {
    const response = await apiRequest(url);
    return response.json();
}

/**
 * Post JSON data to API
 * @param {string} url - URL to post to
 * @param {Object} data - Data to post
 * @returns {Promise<Object>} - Parsed JSON response
 */
async function apiPost(url, data) {
    const response = await apiRequest(url, {
        method: 'POST',
        body: JSON.stringify(data)
    });
    return response.json();
}

