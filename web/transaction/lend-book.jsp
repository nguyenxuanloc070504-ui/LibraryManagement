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
                <a href="<%= request.getContextPath() %>/transaction/lend" class="nav-item active">
                    <i class="fa-solid fa-hand-holding"></i>
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
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Lend Book</h1>
                <p class="page-subtitle">Process book borrowing requests, update book status and due date</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <!-- Search Book -->
                <section class="card">
                    <h2 class="form-section-title">Search Available Book</h2>
                    <form method="get" action="<%= request.getContextPath() %>/transaction/lend" class="auth-form">
                        <div class="form-field">
                            <label class="label-muted">Search Book</label>
                            <div class="input box">
                                <input type="text" name="book_search" placeholder="Title, ISBN, or Author" 
                                       value="<%= request.getParameter("book_search") != null ? request.getParameter("book_search") : "" %>" />
                            </div>
                        </div>
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Search</button>
                        </div>
                    </form>
                    <% List<TransactionDAO.AvailableBook> bookResults = (List<TransactionDAO.AvailableBook>) request.getAttribute("bookResults"); %>
                    <% if (bookResults != null && !bookResults.isEmpty()) { %>
                        <div class="table-container" style="margin-top:1rem; max-height: 400px; overflow-y: auto;">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>ISBN</th>
                                        <th>Available</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.AvailableBook book : bookResults) { %>
                                        <tr>
                                            <td><strong><%= book.title %></strong></td>
                                            <td><%= book.isbn != null ? book.isbn : "N/A" %></td>
                                            <td><span class="status-badge status-active"><%= book.availableCopies %> copies</span></td>
                                            <td>
                                                <button type="button" class="btn-icon-text" onclick="selectBook(<%= book.bookId %>, '<%= book.title.replace("'", "\\'") %>')">
                                                    <i class="fa-solid fa-check"></i> Select
                                                </button>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </section>

                <!-- Search Member -->
                <section class="card">
                    <h2 class="form-section-title">Search Member</h2>
                    <form method="get" action="<%= request.getContextPath() %>/transaction/lend" class="auth-form">
                        <input type="hidden" name="book_search" value="<%= request.getParameter("book_search") != null ? request.getParameter("book_search") : "" %>" />
                        <div class="form-field">
                            <label class="label-muted">Search Member</label>
                            <div class="input box">
                                <input type="text" name="member_search" placeholder="Username, Email, Name, or Membership #" 
                                       value="<%= request.getParameter("member_search") != null ? request.getParameter("member_search") : "" %>" />
                            </div>
                        </div>
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Search</button>
                        </div>
                    </form>
                    <% List<MemberDAO.MemberDetail> memberResults = (List<MemberDAO.MemberDetail>) request.getAttribute("memberResults"); %>
                    <% if (memberResults != null && !memberResults.isEmpty()) { %>
                        <div class="table-container" style="margin-top:1rem; max-height: 400px; overflow-y: auto;">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Email</th>
                                        <th>Membership #</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (MemberDAO.MemberDetail member : memberResults) { %>
                                        <tr>
                                            <td><strong><%= member.fullName %></strong></td>
                                            <td><%= member.email %></td>
                                            <td><%= member.membershipNumber %></td>
                                            <td>
                                                <button type="button" class="btn-icon-text" onclick="selectMember(<%= member.userId %>, '<%= member.fullName.replace("'", "\\'") %>')">
                                                    <i class="fa-solid fa-check"></i> Select
                                                </button>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </section>
            </div>

            <!-- Lend Form -->
            <section class="card" style="margin-top: 1.5rem;">
                <h2 class="form-section-title">Lend Book</h2>
                <form method="post" action="<%= request.getContextPath() %>/transaction/lend" class="auth-form" novalidate>
                    <div class="form-grid two-col">
                        <div class="form-field">
                            <label class="label-muted">Selected Book<span class="req">*</span></label>
                            <div class="input box">
                                <input type="text" id="selected-book-display" readonly placeholder="Search and select a book" />
                                <input type="hidden" id="book_id" name="book_id" required />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Selected Member<span class="req">*</span></label>
                            <div class="input box">
                                <input type="text" id="selected-member-display" readonly placeholder="Search and select a member" />
                                <input type="hidden" id="user_id" name="user_id" required />
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn-primary" type="submit" style="width:auto;">Lend Book</button>
                        <button class="btn-secondary" type="button" onclick="clearSelection()">Clear Selection</button>
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
<script>
function selectBook(bookId, title) {
    document.getElementById('book_id').value = bookId;
    document.getElementById('selected-book-display').value = title;
}

function selectMember(userId, name) {
    document.getElementById('user_id').value = userId;
    document.getElementById('selected-member-display').value = name;
}

function clearSelection() {
    document.getElementById('book_id').value = '';
    document.getElementById('selected-book-display').value = '';
    document.getElementById('user_id').value = '';
    document.getElementById('selected-member-display').value = '';
}
</script>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

