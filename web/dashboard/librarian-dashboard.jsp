<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Librarian Dashboard</title>
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
                <a href="../dashboard" class="nav-item active">
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
                <a href="<%= request.getContextPath() %>/reports/overdue-books" class="nav-item">
                    <i class="fa-solid fa-clock"></i>
                    <span>Overdue Management</span>
                </a>
            </div>
        </nav>

        
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Dashboard Overview</h1>
                <p class="page-subtitle">Welcome back! Here's what's happening with your library today.</p>
            </div>
            <div class="header-actions">
                <div class="user-dropdown">
                    <button class="user-trigger" type="button" aria-haspopup="true" aria-expanded="false">
                        <div class="user-avatar">
                            <i class="fa-solid fa-user-tie"></i>
                        </div>
                        <div class="user-info">
                            <div class="user-name"><%= session.getAttribute("username") != null ? session.getAttribute("username") : "Librarian" %></div>
                            <div class="user-role">Administrator</div>
                        </div>
                        <i class="fa-solid fa-chevron-down" style="font-size:.85rem;color:#6b7280;margin-left:.25rem;"></i>
                    </button>
                    <div class="user-menu" role="menu">
                        <a href="#" class="menu-item" role="menuitem">
                            <i class="fa-regular fa-id-badge"></i>
                            <span>Profile</span>
                        </a>
                        <a href="#" class="menu-item" role="menuitem">
                            <i class="fa-solid fa-gear"></i>
                            <span>Setting</span>
                        </a>
                        <a href="<%= request.getContextPath() %>/logout" class="menu-item danger" role="menuitem">
                            <i class="fa-solid fa-right-from-bracket"></i>
                            <span>Logout</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>

        <div class="main-content">
            <p>Dashboard content will be displayed here.</p>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/dashboard.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


