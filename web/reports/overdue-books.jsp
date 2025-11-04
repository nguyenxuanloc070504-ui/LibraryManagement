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
    <title>Overdue Books Management</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="reports-overdue"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Overdue Books Management"/>
            <jsp:param name="pageSubtitle" value="View and manage overdue books, send reminders to members"/>
        </jsp:include>

        <div class="main-content">
            <%
                String successMsg = (String) request.getSession().getAttribute("success");
                String errorMsg = (String) request.getSession().getAttribute("error");
                if (successMsg != null) {
                    request.getSession().removeAttribute("success");
            %>
                <div class="alert-success"><%= successMsg %></div>
            <% } %>
            <% if (errorMsg != null) {
                    request.getSession().removeAttribute("error");
            %>
                <div class="alert-error"><%= errorMsg %></div>
            <% } %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% List<ReportDAO.OverdueBookDetail> overdueBooks = (List<ReportDAO.OverdueBookDetail>) request.getAttribute("overdueBooks"); %>
            <% SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); %>
            <% DecimalFormat df = new DecimalFormat("#,###.00"); %>
            
            <% if (overdueBooks == null || overdueBooks.isEmpty()) { %>
                <section class="card">
                    <p>No overdue books at this time. Great job!</p>
                </section>
            <% } else { %>
                <section class="card">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <h2 class="form-section-title" style="margin: 0;">Overdue Books (<%= overdueBooks.size() %> books)</h2>
                        <div style="display: flex; gap: 0.5rem;">
                            <a href="<%= request.getContextPath() %>/reports/export?type=overdue-books&format=excel" class="btn-secondary">
                                <i class="fa-solid fa-file-excel"></i> Excel
                            </a>
                            <a href="<%= request.getContextPath() %>/reports/export?type=overdue-books&format=pdf" class="btn-secondary">
                                <i class="fa-solid fa-file-pdf"></i> PDF
                            </a>
                        </div>
                    </div>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Member</th>
                                    <th>Contact</th>
                                    <th>Book Title</th>
                                    <th>ISBN</th>
                                    <th>Copy Number</th>
                                    <th>Borrow Date</th>
                                    <th>Due Date</th>
                                    <th>Days Overdue</th>
                                    <th>Calculated Fine</th>
                                    <th>Recorded Fine</th>
                                    <th>Fine Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (ReportDAO.OverdueBookDetail book : overdueBooks) { %>
                                    <tr>
                                        <td>
                                            <strong><%= book.memberName %></strong>
                                        </td>
                                        <td>
                                            <div><%= book.email %></div>
                                            <% if (book.phone != null) { %>
                                                <div class="text-muted"><%= book.phone %></div>
                                            <% } %>
                                            <% if (book.address != null && !book.address.isEmpty()) { %>
                                                <div class="text-muted" style="font-size: 0.85rem;"><%= book.address %></div>
                                            <% } %>
                                        </td>
                                        <td><strong><%= book.bookTitle %></strong></td>
                                        <td><%= book.isbn != null ? book.isbn : "N/A" %></td>
                                        <td><%= book.copyNumber %></td>
                                        <td><%= dateFormat.format(book.borrowDate) %></td>
                                        <td><%= dateFormat.format(book.dueDate) %></td>
                                        <td>
                                            <span class="status-badge status-locked">
                                                <%= book.daysOverdue %> days
                                            </span>
                                        </td>
                                        <td>
                                            <strong style="color: var(--color-error);">
                                                $<%= df.format(book.calculatedFine) %>
                                            </strong>
                                        </td>
                                        <td>
                                            <% if (book.recordedFine != null && book.recordedFine.compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                                                $<%= df.format(book.recordedFine) %>
                                            <% } else { %>
                                                <span class="text-muted">Not generated</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if ("paid".equals(book.fineStatus)) { %>
                                                <span class="status-badge status-success">Paid</span>
                                            <% } else if ("unpaid".equals(book.fineStatus)) { %>
                                                <span class="status-badge status-warning">Unpaid</span>
                                            <% } else if ("waived".equals(book.fineStatus)) { %>
                                                <span class="status-badge status-secondary">Waived</span>
                                            <% } else { %>
                                                <span class="status-badge status-locked">Not Generated</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <form method="post" action="<%= request.getContextPath() %>/reports/send-reminder" style="display: inline;">
                                                <input type="hidden" name="userId" value="<%= book.userId %>">
                                                <input type="hidden" name="transactionId" value="<%= book.transactionId %>">
                                                <button type="submit" class="btn-secondary" style="padding: 0.25rem 0.5rem; font-size: 0.85rem;">
                                                    <i class="fa-solid fa-paper-plane"></i> Send
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
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

