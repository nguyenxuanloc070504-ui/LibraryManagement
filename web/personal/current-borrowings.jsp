<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Current Borrowings</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand-small">Library Management System</div>
        <nav class="nav">
            <div class="nav-section">
                <div class="nav-section-title">Reader Menu</div>
                <a href="<%= request.getContextPath() %>/books" class="nav-item">
                    <i class="fa-solid fa-book"></i>
                    <span>Search Books</span>
                </a>
                <a href="<%= request.getContextPath() %>/books/my-reservations" class="nav-item">
                    <i class="fa-solid fa-bookmark"></i>
                    <span>My Reservations</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/current-borrowings" class="nav-item active">
                    <i class="fa-solid fa-book-open"></i>
                    <span>Current Borrowings</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/borrowing-history" class="nav-item">
                    <i class="fa-solid fa-history"></i>
                    <span>Borrowing History</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/notifications" class="nav-item">
                    <i class="fa-solid fa-bell"></i>
                    <span>Notifications</span>
                </a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Account</div>
                <a href="<%= request.getContextPath() %>/logout" class="nav-item">
                    <i class="fa-solid fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Current Borrowings</h1>
                <p class="page-subtitle">View your currently borrowed books and request renewals</p>
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

            <% List<TransactionDAO.BorrowingDetail> borrowings = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("borrowings"); %>
            <% List<TransactionDAO.RenewalRequestDetail> renewalRequests = (List<TransactionDAO.RenewalRequestDetail>) request.getAttribute("renewalRequests"); %>
            <% SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); %>
            
            <% 
                // Create set of transaction IDs with pending renewal requests
                Set<Integer> pendingRenewalTransactionIds = new HashSet<>();
                if (renewalRequests != null) {
                    for (TransactionDAO.RenewalRequestDetail req : renewalRequests) {
                        if ("pending".equals(req.requestStatus)) {
                            pendingRenewalTransactionIds.add(req.transactionId);
                        }
                    }
                }
            %>

            <% if (borrowings == null || borrowings.isEmpty()) { %>
                <section class="card">
                    <p>You don't have any currently borrowed books.</p>
                    <a href="<%= request.getContextPath() %>/books" class="btn-primary">Search Books</a>
                </section>
            <% } else { %>
                <section class="card">
                    <h2 class="form-section-title">Your Current Borrowings (<%= borrowings.size() %> books)</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Book Title</th>
                                    <th>ISBN</th>
                                    <th>Borrow Date</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                    <th>Renewals</th>
                                    <th>Fine</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (TransactionDAO.BorrowingDetail item : borrowings) { %>
                                    <tr>
                                        <td><strong><%= item.bookTitle %></strong></td>
                                        <td><%= item.isbn != null ? item.isbn : "N/A" %></td>
                                        <td><%= dateFormat.format(item.borrowDate) %></td>
                                        <td>
                                            <%= dateFormat.format(item.dueDate) %>
                                            <% if (item.daysOverdue > 0) { %>
                                                <span class="status-badge status-locked" style="margin-left: 0.5rem;">
                                                    <%= item.daysOverdue %> days overdue
                                                </span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if ("overdue".equals(item.transactionStatus)) { %>
                                                <span class="status-badge status-locked"><%= item.transactionStatus %></span>
                                            <% } else { %>
                                                <span class="status-badge status-active"><%= item.transactionStatus %></span>
                                            <% } %>
                                        </td>
                                        <td><%= item.renewalCount %></td>
                                        <td>
                                            <% if (item.potentialFine != null && item.potentialFine.compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                                                $<%= String.format("%.2f", item.potentialFine) %>
                                            <% } else { %>
                                                $0.00
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if (pendingRenewalTransactionIds.contains(item.transactionId)) { %>
                                                <span class="text-muted">
                                                    <i class="fa-solid fa-clock"></i> Renewal Pending
                                                </span>
                                            <% } else { %>
                                                <form method="post" action="<%= request.getContextPath() %>/personal/request-renewal" style="display: inline;">
                                                    <input type="hidden" name="transaction_id" value="<%= item.transactionId %>" />
                                                    <button type="submit" class="btn-icon-text">
                                                        <i class="fa-solid fa-rotate"></i> Request Renewal
                                                    </button>
                                                </form>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>

                <% if (renewalRequests != null && !renewalRequests.isEmpty()) { %>
                    <section class="card" style="margin-top: 1.5rem;">
                        <h2 class="form-section-title">Renewal Requests</h2>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Book Title</th>
                                        <th>Due Date</th>
                                        <th>Request Date</th>
                                        <th>Status</th>
                                        <th>Notes</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.RenewalRequestDetail req : renewalRequests) { %>
                                        <tr>
                                            <td><strong><%= req.bookTitle %></strong></td>
                                            <td><%= dateFormat.format(req.dueDate) %></td>
                                            <td><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(req.requestDate) %></td>
                                            <td>
                                                <% if ("pending".equals(req.requestStatus)) { %>
                                                    <span class="status-badge status-active">Pending</span>
                                                <% } else if ("approved".equals(req.requestStatus)) { %>
                                                    <span class="status-badge status-success">Approved</span>
                                                <% } else { %>
                                                    <span class="status-badge status-locked">Rejected</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if ("rejected".equals(req.requestStatus) && req.rejectionReason != null) { %>
                                                    <%= req.rejectionReason %>
                                                <% } else if ("approved".equals(req.requestStatus) && req.processedDate != null) { %>
                                                    Approved on <%= new SimpleDateFormat("yyyy-MM-dd").format(req.processedDate) %>
                                                <% } else { %>
                                                    Waiting for approval
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </section>
                <% } %>
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

