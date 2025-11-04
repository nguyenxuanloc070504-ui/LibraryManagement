<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    DecimalFormat df = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Librarian Dashboard</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="dashboard"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Dashboard Overview"/>
            <jsp:param name="pageSubtitle" value="Welcome back! Here's what's happening with your library today."/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% if (stats != null) { %>
                <!-- Key Metrics Row -->
                <div class="metrics-row">
                    <div class="metric-box metric-primary">
                        <div class="metric-icon"><i class="fa-solid fa-book"></i></div>
                        <div class="metric-info">
                            <div class="metric-value"><%= stats.get("total_books") %></div>
                            <div class="metric-label">Total Books</div>
                        </div>
                    </div>
                    <div class="metric-box metric-success">
                        <div class="metric-icon"><i class="fa-solid fa-users"></i></div>
                        <div class="metric-info">
                            <div class="metric-value"><%= stats.get("total_members") %></div>
                            <div class="metric-label">Total Members</div>
                        </div>
                    </div>
                    <div class="metric-box metric-warning">
                        <div class="metric-icon"><i class="fa-solid fa-hand-holding"></i></div>
                        <div class="metric-info">
                            <div class="metric-value"><%= stats.get("current_borrows") %></div>
                            <div class="metric-label">Active Borrows</div>
                        </div>
                    </div>
                    <div class="metric-box metric-danger">
                        <div class="metric-icon"><i class="fa-solid fa-clock"></i></div>
                        <div class="metric-info">
                            <div class="metric-value"><%= stats.get("overdue_books") %></div>
                            <div class="metric-label">Overdue Books</div>
                        </div>
                    </div>
                </div>

                <!-- Charts Row -->
                <div class="charts-grid">
                    <!-- Book Status Pie Chart -->
                    <div class="chart-card">
                        <h3 class="chart-title">
                            <i class="fa-solid fa-chart-pie"></i>
                            Book Status Distribution
                        </h3>
                        <div class="chart-container">
                            <canvas id="bookStatusChart"></canvas>
                        </div>
                    </div>

                    <!-- Borrow Status Bar Chart -->
                    <div class="chart-card">
                        <h3 class="chart-title">
                            <i class="fa-solid fa-chart-bar"></i>
                            Borrow Status Overview
                        </h3>
                        <div class="chart-container">
                            <canvas id="borrowStatusChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Library Statistics Summary Table -->
                <div class="summary-table-card">
                    <h3 class="chart-title">
                        <i class="fa-solid fa-table"></i>
                        Library Statistics Summary
                    </h3>
                    <div class="table-container">
                        <table class="dashboard-table">
                            <thead>
                                <tr>
                                    <th>Category</th>
                                    <th>Metric</th>
                                    <th class="text-center">Count</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><i class="fa-solid fa-book text-primary"></i> Books</td>
                                    <td>Available Copies</td>
                                    <td class="text-center"><strong><%= stats.get("available_copies") %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/books" class="table-link">View Books →</a></td>
                                </tr>
                                <tr>
                                    <td><i class="fa-solid fa-book text-primary"></i> Books</td>
                                    <td>Borrowed Copies</td>
                                    <td class="text-center"><strong><%= (Integer)stats.get("total_books") - (Integer)stats.get("available_copies") %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/transaction/scheduled-returns" class="table-link">View Details →</a></td>
                                </tr>
                                <tr class="<%= (Integer)stats.get("overdue_books") > 0 ? "row-danger" : "" %>">
                                    <td><i class="fa-solid fa-clock text-danger"></i> Overdue</td>
                                    <td>Overdue Books</td>
                                    <td class="text-center"><strong class="text-danger"><%= stats.get("overdue_books") %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/reports/overdue-books" class="table-link">Manage →</a></td>
                                </tr>
                                <tr class="<%= ((Integer)stats.get("pending_borrow_requests") != null && (Integer)stats.get("pending_borrow_requests") > 0) ? "row-warning" : "" %>">
                                    <td><i class="fa-solid fa-inbox text-warning"></i> Requests</td>
                                    <td>Pending Borrow Requests</td>
                                    <td class="text-center"><strong class="text-warning"><%= stats.get("pending_borrow_requests") != null ? stats.get("pending_borrow_requests") : 0 %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/transaction/requests" class="table-link">Process →</a></td>
                                </tr>
                                <tr class="<%= ((Integer)stats.get("pending_renewal_requests") != null && (Integer)stats.get("pending_renewal_requests") > 0) ? "row-info" : "" %>">
                                    <td><i class="fa-solid fa-rotate-right text-info"></i> Renewals</td>
                                    <td>Pending Renewal Requests</td>
                                    <td class="text-center"><strong class="text-info"><%= stats.get("pending_renewal_requests") != null ? stats.get("pending_renewal_requests") : 0 %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/transaction/renewal-requests" class="table-link">Review →</a></td>
                                </tr>
                                <tr>
                                    <td><i class="fa-solid fa-box text-info"></i> Pickup</td>
                                    <td>Books Ready for Pickup</td>
                                    <td class="text-center"><strong><%= stats.get("books_ready_for_pickup") != null ? stats.get("books_ready_for_pickup") : 0 %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/transaction/requests" class="table-link">View →</a></td>
                                </tr>
                                <tr>
                                    <td><i class="fa-solid fa-dollar-sign text-secondary"></i> Fines</td>
                                    <td>Total Unpaid Fines</td>
                                    <td class="text-center"><strong>$<%= df.format(stats.get("total_unpaid_fines")) %></strong></td>
                                    <td><a href="<%= request.getContextPath() %>/transaction/process-fines" class="table-link">Manage →</a></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Quick Actions Grid -->
                <div class="quick-actions-compact">
                    <a href="<%= request.getContextPath() %>/transaction/lend" class="action-link">
                        <i class="fa-solid fa-hand-holding"></i>
                        Lend Book
                    </a>
                    <a href="<%= request.getContextPath() %>/transaction/return" class="action-link">
                        <i class="fa-solid fa-arrow-rotate-left"></i>
                        Return Book
                    </a>
                    <a href="<%= request.getContextPath() %>/member/register" class="action-link">
                        <i class="fa-solid fa-user-plus"></i>
                        Register Member
                    </a>
                    <a href="<%= request.getContextPath() %>/reports/statistics" class="action-link">
                        <i class="fa-solid fa-chart-line"></i>
                        View Reports
                    </a>
                </div>
            <% } else { %>
                <div class="alert-error">Unable to load dashboard statistics.</div>
            <% } %>
        </div>
    </main>
</div>
<!-- Load Chart.js first -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<% if (stats != null) { %>
<script>
    // Dashboard statistics data
    const dashboardData = {
        totalBooks: <%= stats.get("total_books") %>,
        availableCopies: <%= stats.get("available_copies") %>,
        borrowedCopies: <%= (Integer)stats.get("total_books") - (Integer)stats.get("available_copies") %>,
        totalMembers: <%= stats.get("total_members") %>,
        currentBorrows: <%= stats.get("current_borrows") %>,
        overdueBooks: <%= stats.get("overdue_books") %>,
        pendingRequests: <%= stats.get("pending_borrow_requests") != null ? stats.get("pending_borrow_requests") : 0 %>,
        readyForPickup: <%= stats.get("books_ready_for_pickup") != null ? stats.get("books_ready_for_pickup") : 0 %>
    };
</script>
<% } %>

<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/dashboard.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


