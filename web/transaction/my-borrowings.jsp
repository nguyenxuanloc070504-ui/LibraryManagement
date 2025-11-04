<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="dal.TransactionDAO" %>
<%
    String userRole = (String) session.getAttribute("authRole");
    boolean isMember = "Member".equalsIgnoreCase(userRole);
    boolean isLibrarian = "Librarian".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Borrowings</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/button.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/modal.css">
    <% if (isMember) { %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pages/home.css">
    <% } %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="<%= isMember ? "home-page" : "" %>">
<div class="<%= isMember ? "" : "layout" %>">
    <% if (isLibrarian) { %>
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="my-borrowings"/>
    </jsp:include>
    <% } %>

    <main class="<%= isMember ? "" : "content" %>">
        <% if (isMember) { %>
        <jsp:include page="/components/header-member.jsp">
            <jsp:param name="activeTab" value="borrowings"/>
        </jsp:include>
        <% } else { %>
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="My Borrowings"/>
            <jsp:param name="pageSubtitle" value="View current borrowings and history"/>
        </jsp:include>
        <% } %>

        <div class="<%= isMember ? "container" : "main-content" %>" style="<%= isMember ? "padding-top: 2rem; padding-bottom: 2rem;" : "" %>">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <section class="card" style="width: 100%; margin-bottom: var(--spacing-xl);">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-book-reader" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Current Borrowings</h2>
                </div>
                <div style="width:100%;">
                    <%
                        List<TransactionDAO.BorrowingDetail> current = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("currentBorrowings");
                        if (current == null || current.isEmpty()) {
                    %>
                        <p class="text-muted">You have no current borrowings.</p>
                    <%
                        } else {
                    %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>ISBN</th>
                                    <th>Copy</th>
                                    <th>Borrowed</th>
                                    <th>Due</th>
                                    <th>Status</th>
                                    <th>Potential Fine</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (TransactionDAO.BorrowingDetail b : current) { %>
                                <tr>
                                    <td><a href="<%= request.getContextPath() %>/books/detail?id=<%= b.bookId %>"><%= b.bookTitle %></a></td>
                                    <td><%= b.isbn %></td>
                                    <td>#<%= b.copyNumber %></td>
                                    <td><%= b.borrowDate %></td>
                                    <td>
                                        <div><%= b.dueDate %></div>
                                        <% if (b.scheduledReturnDate != null) { %>
                                            <small class="muted">Scheduled: <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(b.scheduledReturnDate) %></small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("overdue".equalsIgnoreCase(b.transactionStatus)) { %>
                                            <span class="status-badge status-locked">Overdue (<%= b.daysOverdue %>d)</span>
                                        <% } else { %>
                                            <span class="status-badge status-active">Borrowed</span>
                                        <% } %>
                                    </td>
                                    <td class="text-right">
                                        <%= b.potentialFine != null ? ("$" + b.potentialFine) : "$0.00" %>
                                    </td>
                                    <td style="text-align:right; white-space:nowrap;">
                                        <% if (isMember) { %>
                                            <button class="btn-icon-text" data-modal-open="modal-schedule-<%= b.transactionId %>">
                                                <i class="fa-regular fa-calendar-check"></i>
                                                Schedule Return
                                            </button>
                                            <div class="modal" id="modal-schedule-<%= b.transactionId %>">
                                                <div class="modal-overlay">
                                                    <div class="modal-dialog">
                                                        <div class="modal-header" style="text-align:center;">Schedule Return</div>
                                                        <div class="modal-body">
                                                            <form id="form-schedule-<%= b.transactionId %>" method="post" action="<%= request.getContextPath() %>/transaction/schedule-return" style="margin:0; display:flex; flex-direction:column; gap:.5rem; align-items:center; text-align:center;">
                                                                <input type="hidden" name="transaction_id" value="<%= b.transactionId %>" />
                                                                <label for="scheduled-<%= b.transactionId %>">Select date & time</label>
                                                                <input type="datetime-local" id="scheduled-<%= b.transactionId %>" name="scheduled_datetime" required />
                                                            </form>
                                                        </div>
                                                        <div class="modal-actions" style="justify-content:center;">
                                                            <button class="btn-secondary" data-modal-close>Cancel</button>
                                                            <button class="btn-icon-text" onclick="document.getElementById('form-schedule-<%= b.transactionId %>').submit();">
                                                                <i class="fa-regular fa-calendar-check"></i> Confirm
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </section>

            <section class="card" style="width: 100%;">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-clock-rotate-left" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Borrowing History</h2>
                </div>
                <div style="width:100%;">
                    <%
                        List<TransactionDAO.BorrowingDetail> history = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("borrowingHistory");
                        if (history == null || history.isEmpty()) {
                    %>
                        <p class="text-muted">No history yet.</p>
                    <%
                        } else {
                    %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                            <tr>
                                <th>Title</th>
                                <th>ISBN</th>
                                <th>Copy</th>
                                <th>Borrowed</th>
                                <th>Due</th>
                                <th>Returned</th>
                                <th>Status</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (TransactionDAO.BorrowingDetail b : history) { %>
                                <tr>
                                    <td><a href="<%= request.getContextPath() %>/books/detail?id=<%= b.bookId %>"><%= b.bookTitle %></a></td>
                                    <td><%= b.isbn %></td>
                                    <td>#<%= b.copyNumber %></td>
                                    <td><%= b.borrowDate %></td>
                                    <td><%= b.dueDate %></td>
                                    <td><%= b.returnDate %></td>
                                    <td>
                                        <span class="status-badge status-inactive">Returned</span>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </section>

            <%
                java.util.List<dal.BorrowRequestDAO.UserBorrowRequest> borrowRequests =
                    (java.util.List<dal.BorrowRequestDAO.UserBorrowRequest>) request.getAttribute("borrowRequests");
                if (borrowRequests != null && !borrowRequests.isEmpty()) {
            %>
            <section class="card" style="width: 100%; margin-top: var(--spacing-xl);">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-envelope-open-text" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Borrow Requests</h2>
                </div>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Book</th>
                                <th>ISBN</th>
                                <th>Requested</th>
                                <th>Status</th>
                                <th>Pickup Window</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (dal.BorrowRequestDAO.UserBorrowRequest r : borrowRequests) { %>
                            <tr>
                                <td><a href="<%= request.getContextPath() %>/books/detail?id=<%= r.bookId %>"><%= r.bookTitle %></a></td>
                                <td><%= r.isbn != null ? r.isbn : "" %></td>
                                <td><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(r.requestDate) %></td>
                                <td>
                                    <% if ("approved".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-success">Approved</span>
                                    <% } else if ("pending".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-active">Pending</span>
                                    <% } else if ("rejected".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-locked">Rejected</span>
                                    <% } else if ("cancelled".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-inactive">Cancelled</span>
                                    <% } else { %>
                                        <span class="status-badge"><%= r.requestStatus %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (r.pickupReadyDate != null) { %>
                                        Ready: <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(r.pickupReadyDate) %><br/>
                                        Expires: <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(r.pickupExpiryDate) %>
                                    <% } else { %>
                                        <span class="text-muted">Not ready</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("pending".equalsIgnoreCase(r.requestStatus)) { %>
                                        <button class="btn-icon-text danger" data-modal-open="modal-cancel-<%= r.requestId %>">
                                            <i class="fa-solid fa-xmark"></i>
                                            Cancel
                                        </button>

                                        <!-- Confirm Cancel Modal for this request -->
                                        <div class="modal" id="modal-cancel-<%= r.requestId %>">
                                            <div class="modal-overlay">
                                                <div class="modal-dialog">
                                                    <div class="modal-header">Cancel Request</div>
                                                    <div class="modal-body">
                                                        Are you sure you want to cancel this borrow request for <strong><%= r.bookTitle %></strong>?
                                                    </div>
                                                    <div class="modal-actions">
                                                        <button class="btn-secondary inline-btn" data-modal-close>Close</button>
                                                        <form method="post" action="<%= request.getContextPath() %>/transaction/cancel-request" style="display:inline;">
                                                            <input type="hidden" name="request_id" value="<%= r.requestId %>" />
                                                            <input type="hidden" name="book_id" value="<%= r.bookId %>" />
                                                            <button type="submit" class="btn-danger inline-btn">
                                                                Confirm Cancel
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    <% } else { %>
                                        <span class="text-muted">—</span>
                                    <% } %>
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

<script src="<%= request.getContextPath() %>/js/components/modal.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


