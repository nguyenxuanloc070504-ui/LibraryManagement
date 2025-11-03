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
                <a href="<%= request.getContextPath() %>/reports/statistics" class="nav-item">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>Reports & Statistics</span>
                </a>
                <a href="<%= request.getContextPath() %>/reports/overdue-books" class="nav-item active">
                    <i class="fa-solid fa-clock"></i>
                    <span>Overdue Management</span>
                </a>
            </div>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Overdue Books Management</h1>
                <p class="page-subtitle">View and manage overdue books, send reminders to members</p>
            </div>
            <div>
                <form method="post" action="<%= request.getContextPath() %>/reports/send-reminders" style="display: inline;">
                    <button type="submit" class="btn-primary">
                        <i class="fa-solid fa-paper-plane"></i> Send Due Date Reminders
                    </button>
                </form>
            </div>
        </header>

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
                    <h2 class="form-section-title">Overdue Books (<%= overdueBooks.size() %> books)</h2>
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
                                </tr>
                            </thead>
                            <tbody>
                                <% for (ReportDAO.OverdueBookDetail book : overdueBooks) { %>
                                    <tr>
                                        <td>
                                            <strong><%= book.memberName %></strong><br>
                                            <small class="text-muted">ID: <%= book.userId %></small>
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
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- Summary Statistics -->
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Summary</h2>
                    <div class="form-grid four-col">
                        <div class="info-card">
                            <div class="info-card-icon" style="background: var(--color-error);">
                                <i class="fa-solid fa-exclamation-triangle"></i>
                            </div>
                            <div class="info-card-content">
                                <div class="info-card-label">Total Overdue</div>
                                <div class="info-card-value"><%= overdueBooks.size() %></div>
                            </div>
                        </div>
                        <div class="info-card">
                            <div class="info-card-icon" style="background: var(--color-warning);">
                                <i class="fa-solid fa-dollar-sign"></i>
                            </div>
                            <div class="info-card-content">
                                <div class="info-card-label">Total Calculated Fines</div>
                                <div class="info-card-value">
                                    $<%
                                        java.math.BigDecimal totalCalculated = java.math.BigDecimal.ZERO;
                                        for (ReportDAO.OverdueBookDetail book : overdueBooks) {
                                            if (book.calculatedFine != null) {
                                                totalCalculated = totalCalculated.add(book.calculatedFine);
                                            }
                                        }
                                        out.print(df.format(totalCalculated));
                                    %>
                                </div>
                            </div>
                        </div>
                        <div class="info-card">
                            <div class="info-card-icon" style="background: var(--color-info);">
                                <i class="fa-solid fa-clock"></i>
                            </div>
                            <div class="info-card-content">
                                <div class="info-card-label">Avg Days Overdue</div>
                                <div class="info-card-value">
                                    <%
                                        int totalDays = 0;
                                        for (ReportDAO.OverdueBookDetail book : overdueBooks) {
                                            totalDays += book.daysOverdue;
                                        }
                                        double avgDays = overdueBooks.size() > 0 ? (double) totalDays / overdueBooks.size() : 0;
                                        out.print(String.format("%.1f", avgDays));
                                    %> days
                                </div>
                            </div>
                        </div>
                        <div class="info-card">
                            <div class="info-card-icon" style="background: var(--color-secondary);">
                                <i class="fa-solid fa-users"></i>
                            </div>
                            <div class="info-card-content">
                                <div class="info-card-label">Affected Members</div>
                                <div class="info-card-value">
                                    <%
                                        java.util.Set<Integer> uniqueMembers = new java.util.HashSet<>();
                                        for (ReportDAO.OverdueBookDetail book : overdueBooks) {
                                            uniqueMembers.add(book.userId);
                                        }
                                        out.print(uniqueMembers.size());
                                    %>
                                </div>
                            </div>
                        </div>
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

