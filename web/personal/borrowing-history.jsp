<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Borrowing History</title>
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
                <a href="<%= request.getContextPath() %>/personal/current-borrowings" class="nav-item">
                    <i class="fa-solid fa-book-open"></i>
                    <span>Current Borrowings</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/borrowing-history" class="nav-item active">
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
                <h1 class="page-title">Borrowing History</h1>
                <p class="page-subtitle">View your previously borrowed books</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% List<TransactionDAO.BorrowingDetail> history = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("history"); %>
            <% SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); %>
            
            <% if (history == null || history.isEmpty()) { %>
                <section class="card">
                    <p>You don't have any borrowing history yet.</p>
                    <a href="<%= request.getContextPath() %>/books" class="btn-primary">Search Books</a>
                </section>
            <% } else { %>
                <section class="card">
                    <h2 class="form-section-title">Your Borrowing History (<%= history.size() %> books)</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Book Title</th>
                                    <th>ISBN</th>
                                    <th>Borrow Date</th>
                                    <th>Due Date</th>
                                    <th>Return Date</th>
                                    <th>Status</th>
                                    <th>Renewals</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (TransactionDAO.BorrowingDetail item : history) { %>
                                    <tr>
                                        <td><strong><%= item.bookTitle %></strong></td>
                                        <td><%= item.isbn != null ? item.isbn : "N/A" %></td>
                                        <td><%= dateFormat.format(item.borrowDate) %></td>
                                        <td><%= dateFormat.format(item.dueDate) %></td>
                                        <td>
                                            <% if (item.returnDate != null) { %>
                                                <%= dateFormat.format(item.returnDate) %>
                                                <% if (item.daysOverdue > 0) { %>
                                                    <span class="status-badge status-locked" style="margin-left: 0.5rem;">
                                                        <%= item.daysOverdue %> days late
                                                    </span>
                                                <% } %>
                                            <% } else { %>
                                                N/A
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="status-badge status-success"><%= item.transactionStatus %></span>
                                        </td>
                                        <td><%= item.renewalCount %></td>
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

