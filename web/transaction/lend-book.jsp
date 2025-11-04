<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="dal.MemberDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lend Book</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="transaction-lend"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Lend Book"/>
            <jsp:param name="pageSubtitle" value="Process book borrowing requests, update book status and due date"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Lend Form -->
            <section class="card">
                <h2 class="form-section-title">Lend Book</h2>
                <form method="post" action="<%= request.getContextPath() %>/transaction/lend" class="auth-form" novalidate>
                    <%
                        List<TransactionDAO.AvailableBook> availableBooks = (List<TransactionDAO.AvailableBook>) request.getAttribute("availableBooks");
                        List<MemberDAO.MemberDetail> activeMembers = (List<MemberDAO.MemberDetail>) request.getAttribute("activeMembers");
                    %>
                    <div class="form-grid two-col">
                        <div class="form-field">
                            <label class="label-muted">Select Book<span class="req">*</span></label>
                            <div class="input box">
                                <select name="book_id" id="book_id" required>
                                    <option value="">-- Select a Book --</option>
                                    <% if (availableBooks != null && !availableBooks.isEmpty()) {
                                        for (TransactionDAO.AvailableBook book : availableBooks) { %>
                                            <option value="<%= book.bookId %>">
                                                <%= book.title %>
                                                <% if (book.isbn != null && !book.isbn.isEmpty()) { %>
                                                    (ISBN: <%= book.isbn %>)
                                                <% } %>
                                                - <%= book.availableCopies %> available
                                            </option>
                                        <% }
                                    } %>
                                </select>
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Select Member<span class="req">*</span></label>
                            <div class="input box">
                                <select name="user_id" id="user_id" required>
                                    <option value="">-- Select a Member --</option>
                                    <% if (activeMembers != null && !activeMembers.isEmpty()) {
                                        for (MemberDAO.MemberDetail member : activeMembers) { %>
                                            <option value="<%= member.userId %>">
                                                <%= member.fullName %>
                                                (<%= member.email %>) -
                                                Membership #<%= member.membershipNumber %>
                                            </option>
                                        <% }
                                    } %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn-primary" type="submit" style="width:auto;">
                            <i class="fa-solid fa-hand-holding"></i> Lend Book
                        </button>
                        <button class="btn-secondary" type="reset">
                            <i class="fa-solid fa-rotate-left"></i> Reset
                        </button>
                    </div>
                </form>
            </section>

            <!-- Current Borrowings -->
            <% List<TransactionDAO.BorrowingDetail> currentBorrowings = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("currentBorrowings"); %>
            <% if (currentBorrowings != null && !currentBorrowings.isEmpty()) { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">Current Borrowings</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Member</th>
                                    <th>Book</th>
                                    <th>Borrow Date</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
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

