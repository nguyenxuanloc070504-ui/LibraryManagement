<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% 
    // Get active menu item from request parameter
    String activeItem = request.getParameter("activeItem") != null ? request.getParameter("activeItem") : "";
    String contextPath = request.getContextPath();
%>
<aside class="sidebar">
    <div class="brand-small">Library Management System</div>

    <nav class="nav">
        <div class="nav-section">
            <div class="nav-section-title">Main Menu</div>
            <a href="<%= contextPath %>/dashboard" class="nav-item <%= "dashboard".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-chart-line"></i>
                <span>Dashboard</span>
            </a>
        </div>

        <div class="nav-section">
            <div class="nav-section-title">Member Management</div>
            <a href="<%= contextPath %>/member/list" class="nav-item <%= "member-list".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-users"></i>
                <span>Members</span>
            </a>
            <a href="<%= contextPath %>/member/register" class="nav-item <%= "member-register".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-user-plus"></i>
                <span>Register New Member</span>
            </a>
            <a href="<%= contextPath %>/member/update" class="nav-item <%= "member-update".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-user-pen"></i>
                <span>Update Member</span>
            </a>
            <a href="<%= contextPath %>/member/renew" class="nav-item <%= "member-renew".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-rotate"></i>
                <span>Renew Membership</span>
            </a>
            <a href="<%= contextPath %>/member/lock-unlock" class="nav-item <%= "member-lock-unlock".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-user-lock"></i>
                <span>Lock/Unlock Account</span>
            </a>
        </div>

        <div class="nav-section">
            <div class="nav-section-title">Book Management</div>
            <a href="<%= contextPath %>/book/add" class="nav-item <%= "book-add".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-book-medical"></i>
                <span>Add New Book</span>
            </a>
            <a href="<%= contextPath %>/book/update" class="nav-item <%= "book-update".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-pen-to-square"></i>
                <span>Update Book</span>
            </a>
            <a href="<%= contextPath %>/book/remove" class="nav-item <%= "book-remove".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-trash-can"></i>
                <span>Remove Book</span>
            </a>
            <a href="<%= contextPath %>/book/categories" class="nav-item <%= "book-categories".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-layer-group"></i>
                <span>Manage Categories</span>
            </a>
            <a href="<%= contextPath %>/book/list" class="nav-item <%= "book-list".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-list"></i>
                <span>Book List</span>
            </a>
        </div>

        <div class="nav-section">
            <div class="nav-section-title">Borrowing & Returning</div>
            <a href="<%= contextPath %>/transaction/requests" class="nav-item <%= "transaction-requests".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-inbox"></i>
                <span>Borrow Requests</span>
            </a>
            <a href="<%= contextPath %>/transaction/lend" class="nav-item <%= "transaction-lend".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-hand-holding"></i>
                <span>Lend Book</span>
            </a>
            <a href="<%= contextPath %>/transaction/return" class="nav-item <%= "transaction-return".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-arrow-rotate-left"></i>
                <span>Return Book</span>
            </a>
            <a href="<%= contextPath %>/transaction/renew" class="nav-item <%= "transaction-renew".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-rotate-right"></i>
                <span>Renew Book (Direct)</span>
            </a>
            <a href="<%= contextPath %>/transaction/renewal-requests" class="nav-item <%= "renewal-requests".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-clock-rotate-left"></i>
                <span>Renewal Requests</span>
            </a>
            <a href="<%= contextPath %>/transaction/fines" class="nav-item <%= "transaction-fines".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-dollar-sign"></i>
                <span>Process Late Fees</span>
            </a>
        </div>

        <div class="nav-section">
            <div class="nav-section-title">Reports</div>
            <a href="<%= contextPath %>/reports/statistics" class="nav-item <%= "reports-statistics".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-chart-pie"></i>
                <span>Reports & Statistics</span>
            </a>
            <a href="<%= contextPath %>/reports/overdue-books" class="nav-item <%= "reports-overdue".equals(activeItem) ? "active" : "" %>">
                <i class="fa-solid fa-clock"></i>
                <span>Overdue Management</span>
            </a>
        </div>
    </nav>
</aside>

