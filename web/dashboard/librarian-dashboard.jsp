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
                <!-- Main Statistics Cards -->
                <div class="form-grid four-col" style="margin-bottom: 2rem;">
                    <div class="info-card info-card-primary">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-book"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("total_books") %></div>
                            <div class="info-card-label">Total Books</div>
                        </div>
                    </div>

                    <div class="info-card info-card-success">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-book-open"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("available_copies") %></div>
                            <div class="info-card-label">Available Copies</div>
                        </div>
                    </div>

                    <div class="info-card info-card-info">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-users"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("total_members") %></div>
                            <div class="info-card-label">Total Members</div>
                        </div>
                    </div>

                    <div class="info-card info-card-warning">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-hand-holding"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("current_borrows") %></div>
                            <div class="info-card-label">Current Borrows</div>
                        </div>
                    </div>
                </div>

                <!-- Secondary Statistics -->
                <div class="form-grid four-col" style="margin-bottom: 2rem;">
                    <div class="info-card info-card-danger">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-clock"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("overdue_books") %></div>
                            <div class="info-card-label">Overdue Books</div>
                        </div>
                    </div>

                    <div class="info-card info-card-secondary">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-dollar-sign"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value">$<%= df.format(stats.get("total_unpaid_fines")) %></div>
                            <div class="info-card-label">Unpaid Fines</div>
                        </div>
                    </div>

                    <div class="info-card info-card-warning">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-inbox"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("pending_borrow_requests") != null ? stats.get("pending_borrow_requests") : 0 %></div>
                            <div class="info-card-label">Pending Requests</div>
                        </div>
                    </div>

                    <div class="info-card info-card-info">
                        <div class="info-card-icon">
                            <i class="fa-solid fa-box"></i>
                        </div>
                        <div class="info-card-content">
                            <div class="info-card-value"><%= stats.get("books_ready_for_pickup") != null ? stats.get("books_ready_for_pickup") : 0 %></div>
                            <div class="info-card-label">Ready for Pickup</div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <section class="card">
                    <h2 class="form-section-title">Quick Actions</h2>
                    <div class="form-grid three-col">
                        <a href="<%= request.getContextPath() %>/transaction/requests" class="btn-secondary" style="text-align: center;">
                            <i class="fa-solid fa-inbox"></i> Process Borrow Requests
                        </a>
                        <a href="<%= request.getContextPath() %>/reports/overdue-books" class="btn-secondary" style="text-align: center;">
                            <i class="fa-solid fa-clock"></i> Manage Overdue Books
                        </a>
                        <a href="<%= request.getContextPath() %>/reports/statistics" class="btn-secondary" style="text-align: center;">
                            <i class="fa-solid fa-chart-pie"></i> View Reports
                        </a>
                        <a href="<%= request.getContextPath() %>/transaction/lend" class="btn-secondary" style="text-align: center;">
                            <i class="fa-solid fa-hand-holding"></i> Lend Book
                        </a>
                        <a href="<%= request.getContextPath() %>/transaction/return" class="btn-secondary" style="text-align: center;">
                            <i class="fa-solid fa-arrow-rotate-left"></i> Return Book
                        </a>
                        <a href="<%= request.getContextPath() %>/member/register" class="btn-secondary" style="text-align: center;">
                            <i class="fa-solid fa-user-plus"></i> Register Member
                        </a>
                    </div>
                </section>

                <!-- Action Items -->
                <%
                    Integer overdueBooks = stats.get("overdue_books") != null ? (Integer)stats.get("overdue_books") : 0;
                    Integer pendingBorrows = stats.get("pending_borrow_requests") != null ? (Integer)stats.get("pending_borrow_requests") : 0;
                    Integer pendingRenewals = stats.get("pending_renewal_requests") != null ? (Integer)stats.get("pending_renewal_requests") : 0;
                %>
                <% if (overdueBooks > 0 || pendingBorrows > 0 || pendingRenewals > 0) { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Action Items</h2>
                    <div class="alert-warning" style="margin-bottom: 1rem;">
                        <strong>Attention Required:</strong> You have pending items that need your attention.
                    </div>
                    <ul style="list-style: none; padding: 0;">
                        <% if (overdueBooks > 0) { %>
                        <li style="padding: 0.75rem; border-left: 3px solid var(--danger); background: var(--danger-light); margin-bottom: 0.5rem; border-radius: 4px;">
                            <i class="fa-solid fa-clock"></i>
                            <strong><%= overdueBooks %></strong> overdue books need attention
                            <a href="<%= request.getContextPath() %>/reports/overdue-books" style="float: right; color: var(--danger);">View Details →</a>
                        </li>
                        <% } %>
                        <% if (pendingBorrows > 0) { %>
                        <li style="padding: 0.75rem; border-left: 3px solid var(--warning); background: var(--warning-light); margin-bottom: 0.5rem; border-radius: 4px;">
                            <i class="fa-solid fa-inbox"></i>
                            <strong><%= pendingBorrows %></strong> borrow requests waiting for approval
                            <a href="<%= request.getContextPath() %>/transaction/requests" style="float: right; color: var(--warning);">Review →</a>
                        </li>
                        <% } %>
                        <% if (pendingRenewals > 0) { %>
                        <li style="padding: 0.75rem; border-left: 3px solid var(--info); background: var(--info-light); margin-bottom: 0.5rem; border-radius: 4px;">
                            <i class="fa-solid fa-rotate-right"></i>
                            <strong><%= pendingRenewals %></strong> renewal requests pending
                            <a href="<%= request.getContextPath() %>/transaction/renewal-requests" style="float: right; color: var(--info);">Review →</a>
                        </li>
                        <% } %>
                    </ul>
                </section>
                <% } %>
            <% } else { %>
                <div class="alert-error">Unable to load dashboard statistics.</div>
            <% } %>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/dashboard.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


