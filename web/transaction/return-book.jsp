<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Return Book</title>
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
                    <i class="fa-solid fa-pen-to-square"></i>
                    <span>Update Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/book/remove" class="nav-item">
                    <i class="fa-solid fa-trash-can"></i>
                    <span>Remove Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/book/categories" class="nav-item">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Manage Categories</span>
                </a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Borrowing & Returning</div>
                <a href="<%= request.getContextPath() %>/transaction/lend" class="nav-item">
                    <i class="fa-solid fa-hand-holding"></i>
                    <span>Lend Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/transaction/return" class="nav-item active">
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
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Return Book</h1>
                <p class="page-subtitle">Receive returned books, check condition, update system</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success">
                    <%= request.getAttribute("success") %>
                    <% if (request.getAttribute("fineAmount") != null) { %>
                        <br/><strong>Fine Amount: $<%= request.getAttribute("fineAmount") %></strong>
                    <% } %>
                </div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% TransactionDAO.BorrowingDetail borrowing = (TransactionDAO.BorrowingDetail) request.getAttribute("borrowing"); %>
            <% List<TransactionDAO.BorrowingDetail> searchResults = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("searchResults"); %>
            <% List<TransactionDAO.BorrowingDetail> currentBorrowings = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("currentBorrowings"); %>

            <% if (borrowing == null && searchResults == null) { %>
                <!-- Search Form -->
                <section class="card">
                    <h2 class="form-section-title">Search Current Borrowing</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Search by book title, member name, or ISBN</p>
                    <form method="get" action="<%= request.getContextPath() %>/transaction/return" class="auth-form">
                        <div class="form-field">
                            <label class="label-muted">Search</label>
                            <div class="input box">
                                <input type="text" name="search" placeholder="Enter search term" 
                                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" required />
                            </div>
                        </div>
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Search</button>
                        </div>
                    </form>
                </section>

                <!-- Current Borrowings List -->
                <% if (currentBorrowings != null && !currentBorrowings.isEmpty()) { %>
                    <section class="card" style="margin-top: 1.5rem;">
                        <h2 class="form-section-title">All Current Borrowings</h2>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Member</th>
                                        <th>Book</th>
                                        <th>Borrow Date</th>
                                        <th>Due Date</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.BorrowingDetail b : currentBorrowings) { %>
                                        <tr>
                                            <td><%= b.memberName %></td>
                                            <td><%= b.bookTitle %></td>
                                            <td><%= b.borrowDate %></td>
                                            <td><%= b.dueDate %> <% if (b.daysOverdue > 0) { %>
                                                <span class="status-badge status-locked">(<%= b.daysOverdue %> days overdue)</span>
                                            <% } %></td>
                                            <td><span class="status-badge <%= "overdue".equals(b.transactionStatus) ? "status-locked" : "status-active" %>">
                                                <%= b.transactionStatus %>
                                            </span></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/transaction/return?id=<%= b.transactionId %>" class="btn-icon-text">
                                                    <i class="fa-solid fa-arrow-rotate-left"></i> Return
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </section>
                <% } %>
            <% } else if (searchResults != null) { %>
                <!-- Search Results -->
                <section class="card">
                    <h2 class="form-section-title">Search Results</h2>
                    <% if (searchResults.isEmpty()) { %>
                        <p>No borrowings found.</p>
                    <% } else { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Member</th>
                                        <th>Book</th>
                                        <th>Due Date</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.BorrowingDetail b : searchResults) { %>
                                        <tr>
                                            <td><%= b.memberName %></td>
                                            <td><%= b.bookTitle %></td>
                                            <td><%= b.dueDate %> <% if (b.daysOverdue > 0) { %>
                                                <span class="status-badge status-locked">(<%= b.daysOverdue %> days overdue)</span>
                                            <% } %></td>
                                            <td><span class="status-badge <%= "overdue".equals(b.transactionStatus) ? "status-locked" : "status-active" %>">
                                                <%= b.transactionStatus %>
                                            </span></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/transaction/return?id=<%= b.transactionId %>" class="btn-icon-text">
                                                    <i class="fa-solid fa-arrow-rotate-left"></i> Return
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                    <div class="form-actions" style="margin-top:1rem;">
                        <a href="<%= request.getContextPath() %>/transaction/return" class="btn-secondary">New Search</a>
                    </div>
                </section>
            <% } else if (borrowing != null) { %>
                <!-- Return Form -->
                <section class="card">
                    <h2 class="form-section-title">Return Book</h2>
                    <div class="member-info-card" style="margin-bottom: 1.5rem;">
                        <div class="info-row">
                            <span class="info-label">Member:</span>
                            <span class="info-value"><%= borrowing.memberName %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Book:</span>
                            <span class="info-value"><%= borrowing.bookTitle %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">ISBN:</span>
                            <span class="info-value"><%= borrowing.isbn != null ? borrowing.isbn : "N/A" %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Copy Number:</span>
                            <span class="info-value"><%= borrowing.copyNumber %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Borrow Date:</span>
                            <span class="info-value"><%= borrowing.borrowDate %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Due Date:</span>
                            <span class="info-value">
                                <%= borrowing.dueDate %>
                                <% if (borrowing.daysOverdue > 0) { %>
                                    <span class="status-badge status-locked">(<%= borrowing.daysOverdue %> days overdue)</span>
                                <% } %>
                            </span>
                        </div>
                        <% if (borrowing.daysOverdue > 0 && borrowing.potentialFine != null && borrowing.potentialFine.compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                            <div class="info-row">
                                <span class="info-label">Potential Fine:</span>
                                <span class="info-value" style="color: var(--color-error); font-weight: bold;">$<%= borrowing.potentialFine %></span>
                            </div>
                        <% } %>
                    </div>
                    
                    <form method="post" action="<%= request.getContextPath() %>/transaction/return" class="auth-form" novalidate>
                        <input type="hidden" name="transaction_id" value="<%= borrowing.transactionId %>" />
                        
                        <div class="form-field">
                            <label class="label-muted">Book Condition After Return<span class="req">*</span></label>
                            <div class="input box">
                                <select name="condition_status" required>
                                    <option value="excellent">Excellent</option>
                                    <option value="good" selected>Good</option>
                                    <option value="fair">Fair</option>
                                    <option value="poor">Poor</option>
                                    <option value="damaged">Damaged</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Confirm Return</button>
                            <a href="<%= request.getContextPath() %>/transaction/return" class="btn-secondary">Cancel</a>
                        </div>
                    </form>
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

