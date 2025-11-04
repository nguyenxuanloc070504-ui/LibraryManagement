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
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="transaction-return"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Return Book"/>
            <jsp:param name="pageSubtitle" value="Receive returned books, check condition, update system"/>
        </jsp:include>

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
                            <div style="display: flex; gap: 0.75rem; align-items: stretch;">
                                <div class="input box" style="flex: 1;">
                                    <input type="text" name="search" placeholder="Enter search term"
                                           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" required />
                                </div>
                                <button class="btn-primary inline-btn" type="submit">
                                    <i class="fa-solid fa-search"></i> Search
                                </button>
                                <button class="btn-secondary inline-btn" type="button" onclick="window.location.href='<%= request.getContextPath() %>/transaction/return'">
                                    <i class="fa-solid fa-times"></i> Clear
                                </button>
                            </div>
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
                            <button class="btn-primary" type="button" data-modal-open="confirmReturnModal" style="width:auto;">Confirm Return</button>
                            <a href="<%= request.getContextPath() %>/transaction/return" class="btn-secondary">Cancel</a>
                        </div>
                    </form>

                    <!-- Confirm Return Modal -->
                    <div class="modal" id="confirmReturnModal">
                        <div class="modal-overlay">
                            <div class="modal-dialog">
                                <div class="modal-header" style="text-align:center;">Confirm Return</div>
                                <div class="modal-body">
                                    <p>Confirm receiving the book <strong><%= borrowing.bookTitle %></strong> from <strong><%= borrowing.memberName %></strong>?</p>
                                    <p class="muted" style="margin:.5rem 0 0;">This will update the transaction and free the copy for lending.</p>
                                </div>
                                <div class="modal-actions" style="justify-content:center;">
                                    <button class="btn-secondary" data-modal-close>Cancel</button>
                                    <button class="btn-icon-text" onclick="document.querySelector('form[action$=\'/transaction/return\']').submit();">
                                        <i class="fa-solid fa-arrow-rotate-left"></i> Confirm
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            <% } %>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/components/modal.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

