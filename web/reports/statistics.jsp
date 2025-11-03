<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.ReportDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Statistics</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand-small">Library Management System</div>
        <nav class="nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-item">
                    <i class="fa-solid fa-chart-line"></i>
                    <span>Dashboard</span>
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Member Management</div>
                <a href="<%= request.getContextPath() %>/member/register" class="nav-item">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>Register New Member</span>
                </a>
                <a href="<%= request.getContextPath() %>/member/update" class="nav-item">
                    <i class="fa-solid fa-user-pen"></i>
                    <span>Update Member</span>
                </a>
                <a href="<%= request.getContextPath() %>/member/renew" class="nav-item">
                    <i class="fa-solid fa-rotate"></i>
                    <span>Renew Membership</span>
                </a>
                <a href="<%= request.getContextPath() %>/member/lock-unlock" class="nav-item">
                    <i class="fa-solid fa-user-lock"></i>
                    <span>Lock/Unlock Account</span>
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Book Management</div>
                <a href="<%= request.getContextPath() %>/book/add" class="nav-item">
                    <i class="fa-solid fa-book-medical"></i>
                    <span>Add New Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/book/update" class="nav-item">
                    <i class="fa-solid fa-book-open-reader"></i>
                    <span>Update Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/book/remove" class="nav-item">
                    <i class="fa-solid fa-book-skull"></i>
                    <span>Remove Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/book/categories" class="nav-item">
                    <i class="fa-solid fa-tags"></i>
                    <span>Manage Categories</span>
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Transactions</div>
                <a href="<%= request.getContextPath() %>/transaction/lend" class="nav-item">
                    <i class="fa-solid fa-hand-holding-hand"></i>
                    <span>Lend Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/transaction/return" class="nav-item">
                    <i class="fa-solid fa-arrow-rotate-left"></i>
                    <span>Return Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/transaction/renew" class="nav-item">
                    <i class="fa-solid fa-rotate-right"></i>
                    <span>Renew Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/transaction/fines" class="nav-item">
                    <i class="fa-solid fa-dollar-sign"></i>
                    <span>Process Late Fees</span>
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Reports</div>
                <a href="<%= request.getContextPath() %>/reports/statistics" class="nav-item active">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>Reports & Statistics</span>
                </a>
                <a href="<%= request.getContextPath() %>/reports/overdue-books" class="nav-item">
                    <i class="fa-solid fa-clock"></i>
                    <span>Overdue Management</span>
                </a>
            </div>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Reports & Statistics</h1>
                <p class="page-subtitle">Generate and view library statistics and reports</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Report Type Selector -->
            <section class="card">
                <h2 class="form-section-title">Select Report Type</h2>
                <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                    <a href="<%= request.getContextPath() %>/reports/statistics?type=dashboard" 
                       class="btn-secondary <%= "dashboard".equals(request.getAttribute("reportType")) ? "active" : "" %>">
                        <i class="fa-solid fa-tachometer-alt"></i> Dashboard Stats
                    </a>
                    <a href="<%= request.getContextPath() %>/reports/statistics?type=popular-books" 
                       class="btn-secondary <%= "popular-books".equals(request.getAttribute("reportType")) ? "active" : "" %>">
                        <i class="fa-solid fa-star"></i> Popular Books
                    </a>
                    <a href="<%= request.getContextPath() %>/reports/statistics?type=active-members" 
                       class="btn-secondary <%= "active-members".equals(request.getAttribute("reportType")) ? "active" : "" %>">
                        <i class="fa-solid fa-users"></i> Active Members
                    </a>
                    <a href="<%= request.getContextPath() %>/reports/statistics?type=fine-revenue" 
                       class="btn-secondary <%= "fine-revenue".equals(request.getAttribute("reportType")) ? "active" : "" %>">
                        <i class="fa-solid fa-money-bill-wave"></i> Fine Revenue
                    </a>
                    <a href="<%= request.getContextPath() %>/reports/statistics?type=categories" 
                       class="btn-secondary <%= "categories".equals(request.getAttribute("reportType")) ? "active" : "" %>">
                        <i class="fa-solid fa-tags"></i> Category Statistics
                    </a>
                </div>
            </section>

            <% String reportType = (String) request.getAttribute("reportType"); %>
            <% if (reportType == null || "dashboard".equals(reportType)) { %>
                <!-- Dashboard Statistics -->
                <% ReportDAO.DashboardStats stats = (ReportDAO.DashboardStats) request.getAttribute("dashboardStats"); %>
                <% if (stats != null) { %>
                    <section class="card" style="margin-top: 1.5rem;">
                        <h2 class="form-section-title">Dashboard Overview</h2>
                        <div class="form-grid four-col">
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-primary);">
                                    <i class="fa-solid fa-book"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Total Books</div>
                                    <div class="info-card-value"><%= stats.totalBooks %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-success);">
                                    <i class="fa-solid fa-book-open"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Available Copies</div>
                                    <div class="info-card-value"><%= stats.availableCopies %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-info);">
                                    <i class="fa-solid fa-users"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Total Members</div>
                                    <div class="info-card-value"><%= stats.totalMembers %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-warning);">
                                    <i class="fa-solid fa-hand-holding"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Current Borrows</div>
                                    <div class="info-card-value"><%= stats.currentBorrows %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-error);">
                                    <i class="fa-solid fa-exclamation-triangle"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Overdue Books</div>
                                    <div class="info-card-value"><%= stats.overdueBooks %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-secondary);">
                                    <i class="fa-solid fa-bookmark"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Active Reservations</div>
                                    <div class="info-card-value"><%= stats.activeReservations %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-error);">
                                    <i class="fa-solid fa-dollar-sign"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Unpaid Fines</div>
                                    <div class="info-card-value">$<%= String.format("%.2f", stats.totalUnpaidFines) %></div>
                                </div>
                            </div>
                            <div class="info-card">
                                <div class="info-card-icon" style="background: var(--color-warning);">
                                    <i class="fa-solid fa-clock"></i>
                                </div>
                                <div class="info-card-content">
                                    <div class="info-card-label">Pending Renewals</div>
                                    <div class="info-card-value"><%= stats.pendingRenewalRequests %></div>
                                </div>
                            </div>
                        </div>
                    </section>
                <% } %>
            <% } else if ("popular-books".equals(reportType)) { %>
                <!-- Popular Books Report -->
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Popular Books Report</h2>
                    <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="popular-books" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Period (days)</label>
                                <div class="input box">
                                    <input type="number" name="period" value="<%= request.getAttribute("periodDays") != null ? request.getAttribute("periodDays") : 90 %>" min="1" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Limit (top N)</label>
                                <div class="input box">
                                    <input type="number" name="limit" value="<%= request.getAttribute("limit") != null ? request.getAttribute("limit") : 20 %>" min="1" max="100" />
                                </div>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">Generate Report</button>
                        </div>
                    </form>

                    <% List<ReportDAO.PopularBook> books = (List<ReportDAO.PopularBook>) request.getAttribute("popularBooks"); %>
                    <% if (books != null && !books.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Rank</th>
                                        <th>Title</th>
                                        <th>Authors</th>
                                        <th>Category</th>
                                        <th>Total Borrows</th>
                                        <th>Borrows (Last Month)</th>
                                        <th>Active Reservations</th>
                                        <th>Avg Duration (days)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% int rank = 1; %>
                                    <% for (ReportDAO.PopularBook book : books) { %>
                                        <tr>
                                            <td><strong>#<%= rank++ %></strong></td>
                                            <td><strong><%= book.title %></strong></td>
                                            <td><%= book.authors != null ? book.authors : "N/A" %></td>
                                            <td><%= book.categoryName != null ? book.categoryName : "N/A" %></td>
                                            <td><%= book.totalBorrows %></td>
                                            <td><%= book.borrowsLastMonth %></td>
                                            <td><%= book.currentReservations %></td>
                                            <td><%= String.format("%.1f", book.avgBorrowDuration) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <p>No data available for the selected period.</p>
                    <% } %>
                </section>
            <% } else if ("active-members".equals(reportType)) { %>
                <!-- Active Members Report -->
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Most Active Members Report</h2>
                    <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="active-members" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Period (days)</label>
                                <div class="input box">
                                    <input type="number" name="period" value="<%= request.getAttribute("periodDays") != null ? request.getAttribute("periodDays") : 90 %>" min="1" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Limit (top N)</label>
                                <div class="input box">
                                    <input type="number" name="limit" value="<%= request.getAttribute("limit") != null ? request.getAttribute("limit") : 20 %>" min="1" max="100" />
                                </div>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">Generate Report</button>
                        </div>
                    </form>

                    <% List<ReportDAO.ActiveMember> members = (List<ReportDAO.ActiveMember>) request.getAttribute("activeMembers"); %>
                    <% if (members != null && !members.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Rank</th>
                                        <th>Member Name</th>
                                        <th>Email</th>
                                        <th>Membership Type</th>
                                        <th>Total Borrows</th>
                                        <th>Returned</th>
                                        <th>Overdue</th>
                                        <th>Total Fines</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% int rank = 1; %>
                                    <% for (ReportDAO.ActiveMember member : members) { %>
                                        <tr>
                                            <td><strong>#<%= rank++ %></strong></td>
                                            <td><strong><%= member.fullName %></strong></td>
                                            <td><%= member.email %></td>
                                            <td><span class="status-badge status-active"><%= member.membershipType %></span></td>
                                            <td><%= member.totalBorrows %></td>
                                            <td><%= member.returnedCount %></td>
                                            <td>
                                                <% if (member.overdueCount > 0) { %>
                                                    <span class="status-badge status-locked"><%= member.overdueCount %></span>
                                                <% } else { %>
                                                    <%= member.overdueCount %>
                                                <% } %>
                                            </td>
                                            <td>$<%= String.format("%.2f", member.totalFines) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <p>No data available for the selected period.</p>
                    <% } %>
                </section>
            <% } else if ("fine-revenue".equals(reportType)) { %>
                <!-- Fine Revenue Report -->
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Fine Revenue Report</h2>
                    <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="fine-revenue" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Start Date</label>
                                <div class="input box">
                                    <input type="date" name="start_date" value="<%= request.getAttribute("startDate") != null ? request.getAttribute("startDate") : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">End Date</label>
                                <div class="input box">
                                    <input type="date" name="end_date" value="<%= request.getAttribute("endDate") != null ? request.getAttribute("endDate") : "" %>" />
                                </div>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">Generate Report</button>
                        </div>
                    </form>

                    <% List<ReportDAO.FineRevenue> revenues = (List<ReportDAO.FineRevenue>) request.getAttribute("fineRevenue"); %>
                    <% if (revenues != null && !revenues.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Total Fines</th>
                                        <th>Total Amount</th>
                                        <th>Collected</th>
                                        <th>Pending</th>
                                        <th>Waived</th>
                                        <th>Avg Fine Amount</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); %>
                                    <% DecimalFormat df = new DecimalFormat("#,###.00"); %>
                                    <% java.math.BigDecimal totalCollected = java.math.BigDecimal.ZERO; %>
                                    <% java.math.BigDecimal totalPending = java.math.BigDecimal.ZERO; %>
                                    <% java.math.BigDecimal totalWaived = java.math.BigDecimal.ZERO; %>
                                    <% for (ReportDAO.FineRevenue revenue : revenues) { %>
                                        <% 
                                            totalCollected = totalCollected.add(revenue.collectedAmount != null ? revenue.collectedAmount : java.math.BigDecimal.ZERO);
                                            totalPending = totalPending.add(revenue.pendingAmount != null ? revenue.pendingAmount : java.math.BigDecimal.ZERO);
                                            totalWaived = totalWaived.add(revenue.waivedAmount != null ? revenue.waivedAmount : java.math.BigDecimal.ZERO);
                                        %>
                                        <tr>
                                            <td><%= dateFormat.format(revenue.date) %></td>
                                            <td><%= revenue.totalFines %></td>
                                            <td><strong>$<%= df.format(revenue.totalAmount) %></strong></td>
                                            <td style="color: var(--color-success);">$<%= df.format(revenue.collectedAmount) %></td>
                                            <td style="color: var(--color-warning);">$<%= df.format(revenue.pendingAmount) %></td>
                                            <td style="color: var(--color-error);">$<%= df.format(revenue.waivedAmount) %></td>
                                            <td>$<%= df.format(revenue.avgFineAmount) %></td>
                                        </tr>
                                    <% } %>
                                    <tr style="background: var(--color-bg-secondary); font-weight: bold;">
                                        <td colspan="3">Total</td>
                                        <td style="color: var(--color-success);">$<%= df.format(totalCollected) %></td>
                                        <td style="color: var(--color-warning);">$<%= df.format(totalPending) %></td>
                                        <td style="color: var(--color-error);">$<%= df.format(totalWaived) %></td>
                                        <td></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <p>No fine data available for the selected period.</p>
                    <% } %>
                </section>
            <% } else if ("categories".equals(reportType)) { %>
                <!-- Category Statistics -->
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Category Statistics</h2>
                    <% List<ReportDAO.CategoryStat> categoryStats = (List<ReportDAO.CategoryStat>) request.getAttribute("categoryStats"); %>
                    <% if (categoryStats != null && !categoryStats.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Category</th>
                                        <th>Total Books</th>
                                        <th>Available Copies</th>
                                        <th>Total Borrows</th>
                                        <th>Borrows (Last Month)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (ReportDAO.CategoryStat stat : categoryStats) { %>
                                        <tr>
                                            <td><strong><%= stat.categoryName %></strong></td>
                                            <td><%= stat.totalBooks %></td>
                                            <td><%= stat.availableCopies %></td>
                                            <td><%= stat.totalBorrows %></td>
                                            <td><%= stat.borrowsLastMonth %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } else { %>
                        <p>No category statistics available.</p>
                    <% } %>
                </section>
            <% } %>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

