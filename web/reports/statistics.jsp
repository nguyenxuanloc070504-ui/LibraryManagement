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
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/button.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="reports-statistics"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Reports & Statistics"/>
            <jsp:param name="pageSubtitle" value="Generate and view library statistics and reports"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Report Type Selector -->
            <section class="card">
                <h2 class="form-section-title">Select Report Type</h2>
                <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="width: 100%;">
                    <div class="form-field" style="width: 100%;">
                        <label class="label-muted">Report Type</label>
                        <div class="input box" style="width: 100%;">
                            <select name="type" onchange="this.form.submit()">
                                <option value="" disabled <%= (request.getAttribute("reportType") == null || "dashboard".equals(request.getAttribute("reportType"))) ? "selected" : "" %>>Please select a report type</option>
                                <option value="popular-books" <%= "popular-books".equals(request.getAttribute("reportType")) ? "selected" : "" %>>Popular Books</option>
                                <option value="active-members" <%= "active-members".equals(request.getAttribute("reportType")) ? "selected" : "" %>>Active Members</option>
                                <option value="fine-revenue" <%= "fine-revenue".equals(request.getAttribute("reportType")) ? "selected" : "" %>>Fine Revenue</option>
                                <option value="categories" <%= "categories".equals(request.getAttribute("reportType")) ? "selected" : "" %>>Category Statistics</option>
                            </select>
                        </div>
                </div>
                </form>
            </section>

            <% String reportType = (String) request.getAttribute("reportType"); %>

            <% if ("popular-books".equals(reportType)) { %>
                <!-- Popular Books Report -->
                    <section class="card" style="margin-top: 1.5rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem;">
                        <h2 class="form-section-title" style="margin: 0;">Popular Books Report</h2>
                        <%
                            String exportPopularBase = request.getContextPath() + "/reports/export?type=popular-books" +
                                    (request.getAttribute("periodDays") != null ? "&period=" + request.getAttribute("periodDays") : "") +
                                    (request.getAttribute("limit") != null ? "&limit=" + request.getAttribute("limit") : "");
                        %>
                        <div style="display: flex; gap: .5rem;">
                            <a href="<%= exportPopularBase %>&format=excel" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-excel"></i> Excel
                            </a>
                            <a href="<%= exportPopularBase %>&format=pdf" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-pdf"></i> PDF
                            </a>
                            </div>
                        </div>
                    <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="popular-books" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Period (days)</label>
                                <div class="input box">
                                    <input type="number" name="period" value="<%= request.getAttribute("periodDays") != null ? request.getAttribute("periodDays") : 90 %>" min="1" onchange="this.form.submit()" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Limit (top N)</label>
                                <div class="input box">
                                    <input type="number" name="limit" value="<%= request.getAttribute("limit") != null ? request.getAttribute("limit") : 20 %>" min="1" max="100" onchange="this.form.submit()" />
                                </div>
                            </div>
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
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem;">
                        <h2 class="form-section-title" style="margin: 0;">Most Active Members Report</h2>
                        <%
                            String exportActiveBase = request.getContextPath() + "/reports/export?type=active-members" +
                                    (request.getAttribute("periodDays") != null ? "&period=" + request.getAttribute("periodDays") : "") +
                                    (request.getAttribute("limit") != null ? "&limit=" + request.getAttribute("limit") : "");
                        %>
                        <div style="display: flex; gap: .5rem;">
                            <a href="<%= exportActiveBase %>&format=excel" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-excel"></i> Excel
                            </a>
                            <a href="<%= exportActiveBase %>&format=pdf" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-pdf"></i> PDF
                            </a>
                        </div>
                    </div>
                    <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="active-members" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Period (days)</label>
                                <div class="input box">
                                    <input type="number" name="period" value="<%= request.getAttribute("periodDays") != null ? request.getAttribute("periodDays") : 90 %>" min="1" onchange="this.form.submit()" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Limit (top N)</label>
                                <div class="input box">
                                    <input type="number" name="limit" value="<%= request.getAttribute("limit") != null ? request.getAttribute("limit") : 20 %>" min="1" max="100" onchange="this.form.submit()" />
                                </div>
                            </div>
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
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem;">
                        <h2 class="form-section-title" style="margin: 0;">Fine Revenue Report</h2>
                        <%
                            String exportFineBase = request.getContextPath() + "/reports/export?type=fine-revenue" +
                                    (request.getAttribute("startDate") != null ? "&start_date=" + request.getAttribute("startDate") : "") +
                                    (request.getAttribute("endDate") != null ? "&end_date=" + request.getAttribute("endDate") : "");
                        %>
                        <div style="display: flex; gap: .5rem;">
                            <a href="<%= exportFineBase %>&format=excel" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-excel"></i> Excel
                            </a>
                            <a href="<%= exportFineBase %>&format=pdf" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-pdf"></i> PDF
                            </a>
                        </div>
                    </div>
                    <form method="get" action="<%= request.getContextPath() %>/reports/statistics" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="fine-revenue" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Start Date</label>
                                <div class="input box">
                                    <input type="date" name="start_date" value="<%= request.getAttribute("startDate") != null ? request.getAttribute("startDate") : "" %>" onchange="this.form.submit()" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">End Date</label>
                                <div class="input box">
                                    <input type="date" name="end_date" value="<%= request.getAttribute("endDate") != null ? request.getAttribute("endDate") : "" %>" onchange="this.form.submit()" />
                                </div>
                            </div>
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
                    <div style="display: flex; justify-content: space-between; align-items: center; gap: 1rem;">
                        <h2 class="form-section-title" style="margin: 0;">Category Statistics</h2>
                        <div style="display: flex; gap: .5rem;">
                            <a href="<%= request.getContextPath() %>/reports/export?type=categories&format=excel" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-excel"></i> Excel
                            </a>
                            <a href="<%= request.getContextPath() %>/reports/export?type=categories&format=pdf" class="btn-primary inline-btn">
                                <i class="fa-solid fa-file-pdf"></i> PDF
                            </a>
                        </div>
                    </div>
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




