/**
 * Dashboard Page
 * Handles dashboard page specific functionality and chart rendering
 */

(function() {
    'use strict';

    // Wait for DOM to be loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDashboard);
    } else {
        initDashboard();
    }

    function initDashboard() {
        // Check if Chart.js is loaded
        if (typeof Chart === 'undefined') {
            console.error('Chart.js is not loaded');
            return;
        }

        // Check if dashboardData exists (passed from JSP)
        if (typeof dashboardData === 'undefined') {
            console.log('Dashboard data not available');
            return;
        }

        console.log('Initializing dashboard charts with data:', dashboardData);

        // Initialize charts
        try {
            initBookStatusChart();
            initBorrowStatusChart();
            console.log('Charts initialized successfully');
        } catch (error) {
            console.error('Error initializing charts:', error);
        }
    }

    /**
     * Initialize Book Status Pie Chart
     */
    function initBookStatusChart() {
        const ctx = document.getElementById('bookStatusChart');
        if (!ctx) return;

        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Available Books', 'Borrowed Books'],
                datasets: [{
                    data: [
                        dashboardData.availableCopies,
                        dashboardData.borrowedCopies
                    ],
                    backgroundColor: [
                        'rgba(16, 185, 129, 0.8)',  // Green
                        'rgba(59, 130, 246, 0.8)'   // Blue
                    ],
                    borderColor: [
                        'rgba(16, 185, 129, 1)',
                        'rgba(59, 130, 246, 1)'
                    ],
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 15,
                            font: {
                                size: 13,
                                family: "'Segoe UI', Roboto, Arial, sans-serif"
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return `${label}: ${value} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });
    }

    /**
     * Initialize Borrow Status Bar Chart
     */
    function initBorrowStatusChart() {
        const ctx = document.getElementById('borrowStatusChart');
        if (!ctx) return;

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Active Borrows', 'Overdue', 'Pending Requests', 'Ready for Pickup'],
                datasets: [{
                    label: 'Count',
                    data: [
                        dashboardData.currentBorrows,
                        dashboardData.overdueBooks,
                        dashboardData.pendingRequests,
                        dashboardData.readyForPickup
                    ],
                    backgroundColor: [
                        'rgba(245, 158, 11, 0.8)',  // Warning - Yellow
                        'rgba(239, 68, 68, 0.8)',   // Danger - Red
                        'rgba(59, 130, 246, 0.8)',  // Primary - Blue
                        'rgba(14, 165, 233, 0.8)'   // Info - Cyan
                    ],
                    borderColor: [
                        'rgba(245, 158, 11, 1)',
                        'rgba(239, 68, 68, 1)',
                        'rgba(59, 130, 246, 1)',
                        'rgba(14, 165, 233, 1)'
                    ],
                    borderWidth: 2,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `${context.label}: ${context.parsed.y}`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            stepSize: 1,
                            font: {
                                size: 12,
                                family: "'Segoe UI', Roboto, Arial, sans-serif"
                            }
                        },
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)'
                        }
                    },
                    x: {
                        ticks: {
                            font: {
                                size: 12,
                                family: "'Segoe UI', Roboto, Arial, sans-serif"
                            }
                        },
                        grid: {
                            display: false
                        }
                    }
                }
            }
        });
    }
})();

