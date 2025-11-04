<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fine Reports</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="reports-fine-reports"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Fine Reports"/>
            <jsp:param name="pageSubtitle" value="View and export comprehensive fine collection reports"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <%
                String reportType = (String) request.getAttribute("reportType");
                if (reportType == null) reportType = "summary";
                DecimalFormat df = new DecimalFormat("#,##0.00");
            %>

            <!-- Report Type & Date Range Selector -->
            <section class="card">
                <h2 class="form-section-title">Report Configuration</h2>
                <form method="get" action="<%= request.getContextPath() %>/reports/fine-reports" class="auth-form">
                    <div class="form-grid two-col">
                        <div class="form-field">
                            <label class="label-muted">Report Type</label>
                            <div class="input box">
                                <select name="type" onchange="this.form.submit()">
                                    <option value="summary" <%= "summary".equals(reportType) ? "selected" : "" %>>Fine Summary</option>
                                    <option value="detailed" <%= "detailed".equals(reportType) ? "selected" : "" %>>Detailed Fine List</option>
                                    <option value="member-history" <%= "member-history".equals(reportType) ? "selected" : "" %>>Member Fine History</option>
                                </select>
                            </div>
                        </div>
                        <div></div>
                        <% if (!"member-history".equals(reportType)) { %>
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
                        <% } %>
                    </div>
                    <% if (!"member-history".equals(reportType)) { %>
                        <div class="form-actions">
                            <button class="btn-primary inline-btn" type="submit">
                                <i class="fa-solid fa-filter"></i> Apply Filters
                            </button>
                        </div>
                    <% } %>
                </form>
            </section>

            <!-- Fine Summary Report -->
            <% if ("summary".equals(reportType)) { %>
                <% TransactionDAO.FineSummary summary = (TransactionDAO.FineSummary) request.getAttribute("fineSummary"); %>
                <% if (summary != null) { %>
                    <section class="card" style="margin-top: 1.5rem;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                            <h2 class="form-section-title" style="margin: 0;">Fine Summary Report</h2>
                            <div style="display: flex; gap: .5rem;">
                                <button class="btn-primary inline-btn" onclick="window.print()">
                                    <i class="fa-solid fa-print"></i> Print
                                </button>
                            </div>
                        </div>

                        <!-- Summary Cards -->
                        <div style="display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: nowrap;">
                            <div style="flex: 1; min-width: 0; background: var(--color-bg-secondary); padding: 1.5rem; border-radius: 8px; border: 1px solid var(--color-border);">
                                <div style="color: var(--color-text-muted); margin-bottom: 0.5rem; font-size: 0.9rem;">Total Fines</div>
                                <div style="font-size: 2rem; font-weight: bold; color: var(--color-primary);"><%= summary.totalFines %></div>
                                <div style="color: var(--color-text-muted); font-size: 0.9rem; margin-top: 0.5rem;">
                                    Amount: $<%= df.format(summary.totalAmount) %>
                                </div>
                            </div>
                            <div style="flex: 1; min-width: 0; background: var(--color-bg-secondary); padding: 1.5rem; border-radius: 8px; border: 1px solid var(--color-border);">
                                <div style="color: var(--color-text-muted); margin-bottom: 0.5rem; font-size: 0.9rem;">Unpaid Fines</div>
                                <div style="font-size: 2rem; font-weight: bold; color: var(--color-error);"><%= summary.unpaidCount %></div>
                                <div style="color: var(--color-error); font-size: 0.9rem; margin-top: 0.5rem;">
                                    Amount: $<%= df.format(summary.unpaidAmount) %>
                                </div>
                            </div>
                            <div style="flex: 1; min-width: 0; background: var(--color-bg-secondary); padding: 1.5rem; border-radius: 8px; border: 1px solid var(--color-border);">
                                <div style="color: var(--color-text-muted); margin-bottom: 0.5rem; font-size: 0.9rem;">Collection Rate</div>
                                <div style="font-size: 2rem; font-weight: bold; color: var(--color-success);">
                                    <%= summary.totalFines > 0 ? String.format("%.1f%%", (summary.paidCount * 100.0 / summary.totalFines)) : "0.0%" %>
                                </div>
                                <div style="color: var(--color-text-muted); font-size: 0.9rem; margin-top: 0.5rem;">
                                    <%= summary.paidCount %> of <%= summary.totalFines %> paid
                                </div>
                            </div>
                        </div>

                        <!-- Breakdown Table -->
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Status</th>
                                        <th>Count</th>
                                        <th>Amount</th>
                                        <th>Percentage</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><span class="status-badge status-success">Paid</span></td>
                                        <td><strong><%= summary.paidCount %></strong></td>
                                        <td style="color: var(--color-success);"><strong>$<%= df.format(summary.paidAmount) %></strong></td>
                                        <td><%= summary.totalFines > 0 ? String.format("%.1f%%", (summary.paidCount * 100.0 / summary.totalFines)) : "0.0%" %></td>
                                    </tr>
                                    <tr>
                                        <td><span class="status-badge status-locked">Unpaid</span></td>
                                        <td><strong><%= summary.unpaidCount %></strong></td>
                                        <td style="color: var(--color-error);"><strong>$<%= df.format(summary.unpaidAmount) %></strong></td>
                                        <td><%= summary.totalFines > 0 ? String.format("%.1f%%", (summary.unpaidCount * 100.0 / summary.totalFines)) : "0.0%" %></td>
                                    </tr>
                                    <tr>
                                        <td><span class="status-badge status-active">Waived</span></td>
                                        <td><strong><%= summary.waivedCount %></strong></td>
                                        <td style="color: var(--color-warning);"><strong>$<%= df.format(summary.waivedAmount) %></strong></td>
                                        <td><%= summary.totalFines > 0 ? String.format("%.1f%%", (summary.waivedCount * 100.0 / summary.totalFines)) : "0.0%" %></td>
                                    </tr>
                                    <tr style="background: var(--color-bg-secondary); font-weight: bold; border-top: 2px solid var(--color-border);">
                                        <td>Total</td>
                                        <td><%= summary.totalFines %></td>
                                        <td>$<%= df.format(summary.totalAmount) %></td>
                                        <td>100%</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </section>
                <% } else { %>
                    <section class="card" style="margin-top: 1.5rem;">
                        <p>No fine data available for the selected period.</p>
                    </section>
                <% } %>
            <% } %>

            <!-- Detailed Fine List -->
            <% if ("detailed".equals(reportType)) { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                        <h2 class="form-section-title" style="margin: 0;">Detailed Fine List</h2>
                        <div style="display: flex; gap: .5rem;">
                            <button class="btn-primary inline-btn" onclick="window.print()">
                                <i class="fa-solid fa-print"></i> Print
                            </button>
                        </div>
                    </div>

                    <!-- Additional Filters -->
                    <form method="get" action="<%= request.getContextPath() %>/reports/fine-reports" style="margin-bottom: 1.5rem;">
                        <input type="hidden" name="type" value="detailed" />
                        <input type="hidden" name="start_date" value="<%= request.getAttribute("startDate") %>" />
                        <input type="hidden" name="end_date" value="<%= request.getAttribute("endDate") %>" />
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Payment Status</label>
                                <div class="input box">
                                    <select name="payment_status" onchange="this.form.submit()">
                                        <option value="">All</option>
                                        <option value="unpaid" <%= "unpaid".equals(request.getAttribute("paymentStatus")) ? "selected" : "" %>>Unpaid</option>
                                        <option value="paid" <%= "paid".equals(request.getAttribute("paymentStatus")) ? "selected" : "" %>>Paid</option>
                                        <option value="waived" <%= "waived".equals(request.getAttribute("paymentStatus")) ? "selected" : "" %>>Waived</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Search (Member/Book)</label>
                                <div style="display: flex; gap: 0.5rem;">
                                    <div class="input box" style="flex: 1;">
                                        <input type="text" name="search" value="<%= request.getAttribute("searchTerm") != null ? request.getAttribute("searchTerm") : "" %>" placeholder="Search member or book..." />
                                    </div>
                                    <button class="btn-primary inline-btn" type="submit">
                                        <i class="fa-solid fa-search"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </form>

                    <% List<TransactionDAO.FineDetail> fines = (List<TransactionDAO.FineDetail>) request.getAttribute("fines"); %>
                    <% if (fines != null && !fines.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Fine ID</th>
                                        <th>Member</th>
                                        <th>Book</th>
                                        <th>Fine Date</th>
                                        <th>Days Overdue</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                        <th>Payment Date</th>
                                        <th>Payment Method</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.FineDetail fine : fines) { %>
                                        <tr>
                                            <td>#<%= fine.fineId %></td>
                                            <td><%= fine.memberName %></td>
                                            <td><%= fine.bookTitle %></td>
                                            <td><%= fine.fineDate %></td>
                                            <td><%= fine.daysOverdue %> days</td>
                                            <td><strong>$<%= df.format(fine.fineAmount) %></strong></td>
                                            <td>
                                                <span class="status-badge <%=
                                                    "paid".equals(fine.paymentStatus) ? "status-success" :
                                                    "waived".equals(fine.paymentStatus) ? "status-active" :
                                                    "status-locked"
                                                %>">
                                                    <%= fine.paymentStatus %>
                                                </span>
                                            </td>
                                            <td><%= fine.paymentDate != null ? fine.paymentDate : "-" %></td>
                                            <td><%= fine.paymentMethod != null ? fine.paymentMethod : "-" %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <p style="margin-top: 1rem; color: var(--color-text-muted);">
                            Total: <%= fines.size() %> fine(s)
                        </p>
                    <% } else { %>
                        <p>No fines found matching the selected criteria.</p>
                    <% } %>
                </section>
            <% } %>

            <!-- Member Fine History -->
            <% if ("member-history".equals(reportType)) { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                        <h2 class="form-section-title" style="margin: 0;">Member Fine History</h2>
                        <div style="display: flex; gap: .5rem;">
                            <button class="btn-primary inline-btn" onclick="window.print()">
                                <i class="fa-solid fa-print"></i> Print
                            </button>
                        </div>
                    </div>

                    <% List<TransactionDAO.MemberFineHistory> histories = (List<TransactionDAO.MemberFineHistory>) request.getAttribute("memberHistories"); %>
                    <% if (histories != null && !histories.isEmpty()) { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Member</th>
                                        <th>Email</th>
                                        <th>Total Fines</th>
                                        <th>Total Amount</th>
                                        <th>Unpaid</th>
                                        <th>Paid</th>
                                        <th>Waived</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.MemberFineHistory history : histories) { %>
                                        <tr>
                                            <td><strong><%= history.memberName %></strong></td>
                                            <td><%= history.memberEmail %></td>
                                            <td><%= history.totalFinesCount %></td>
                                            <td><strong>$<%= df.format(history.totalFinesAmount) %></strong></td>
                                            <td>
                                                <% if (history.unpaidCount > 0) { %>
                                                    <span class="status-badge status-locked">
                                                        <%= history.unpaidCount %> ($<%= df.format(history.unpaidAmount) %>)
                                                    </span>
                                                <% } else { %>
                                                    <%= history.unpaidCount %>
                                                <% } %>
                                            </td>
                                            <td>
                                                <span style="color: var(--color-success);">
                                                    <%= history.paidCount %> ($<%= df.format(history.paidAmount) %>)
                                                </span>
                                            </td>
                                            <td>
                                                <%= history.waivedCount %> ($<%= df.format(history.waivedAmount) %>)
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <p style="margin-top: 1rem; color: var(--color-text-muted);">
                            Total: <%= histories.size() %> member(s) with fine history
                        </p>
                    <% } else { %>
                        <p>No member fine history available.</p>
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
