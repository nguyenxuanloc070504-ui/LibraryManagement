<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.NotificationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications</title>
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
                <a href="<%= request.getContextPath() %>/personal/borrowing-history" class="nav-item">
                    <i class="fa-solid fa-history"></i>
                    <span>Borrowing History</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/notifications" class="nav-item active">
                    <i class="fa-solid fa-bell"></i>
                    <span>Notifications</span>
                    <% Integer unreadCount = (Integer) request.getAttribute("unreadCount"); %>
                    <% if (unreadCount != null && unreadCount > 0) { %>
                        <span class="status-badge status-locked" style="margin-left: 0.5rem;"><%= unreadCount %></span>
                    <% } %>
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
                <h1 class="page-title">Notifications</h1>
                <p class="page-subtitle">View and manage your notifications</p>
            </div>
            <div>
                <form method="post" action="<%= request.getContextPath() %>/personal/mark-notification-read" style="display: inline;">
                    <input type="hidden" name="action" value="read_all" />
                    <button type="submit" class="btn-secondary">
                        <i class="fa-solid fa-check-double"></i> Mark All as Read
                    </button>
                </form>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% 
                String successMsg = (String) request.getSession().getAttribute("success");
                if (successMsg != null) {
                    request.getSession().removeAttribute("success");
            %>
                <div class="alert-success"><%= successMsg %></div>
            <% } %>

            <!-- Filter buttons -->
            <section class="card" style="margin-bottom: 1.5rem;">
                <div style="display: flex; gap: 1rem;">
                    <a href="<%= request.getContextPath() %>/personal/notifications" 
                       class="btn-secondary <%= request.getAttribute("filter") == null ? "active" : "" %>">
                        All Notifications
                    </a>
                    <a href="<%= request.getContextPath() %>/personal/notifications?filter=unread" 
                       class="btn-secondary <%= "unread".equals(request.getAttribute("filter")) ? "active" : "" %>">
                        Unread Only
                    </a>
                </div>
            </section>

            <% List<NotificationDAO.NotificationDetail> notifications = (List<NotificationDAO.NotificationDetail>) request.getAttribute("notifications"); %>
            <% SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm"); %>
            
            <% if (notifications == null || notifications.isEmpty()) { %>
                <section class="card">
                    <p>You don't have any notifications.</p>
                </section>
            <% } else { %>
                <section class="card">
                    <h2 class="form-section-title">Your Notifications (<%= notifications.size() %>)</h2>
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                        <% for (NotificationDAO.NotificationDetail notif : notifications) { %>
                            <div class="card" style="padding: 1rem; <%= !notif.isRead ? "border-left: 4px solid var(--color-primary); background: var(--color-bg-secondary);" : "" %>">
                                <div style="display: flex; justify-content: space-between; align-items: start;">
                                    <div style="flex: 1;">
                                        <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                                            <% 
                                                String iconClass = "fa-bell";
                                                if ("due_reminder".equals(notif.notificationType)) iconClass = "fa-calendar-day";
                                                else if ("overdue".equals(notif.notificationType)) iconClass = "fa-exclamation-triangle";
                                                else if ("reservation_available".equals(notif.notificationType)) iconClass = "fa-bookmark";
                                                else if ("renewal_approved".equals(notif.notificationType)) iconClass = "fa-check-circle";
                                                else if ("renewal_rejected".equals(notif.notificationType)) iconClass = "fa-times-circle";
                                                else if ("membership_expiry".equals(notif.notificationType)) iconClass = "fa-id-card";
                                            %>
                                            <i class="fa-solid <%= iconClass %>"></i>
                                            <h3 style="margin: 0; font-size: 1.1rem;">
                                                <%= notif.title %>
                                                <% if (!notif.isRead) { %>
                                                    <span class="status-badge status-active" style="font-size: 0.75rem; margin-left: 0.5rem;">New</span>
                                                <% } %>
                                            </h3>
                                        </div>
                                        <p style="margin: 0.5rem 0; color: var(--color-text);"><%= notif.message %></p>
                                        <p style="margin: 0; color: var(--color-text-muted); font-size: 0.9rem;">
                                            <i class="fa-solid fa-clock"></i> <%= dateFormat.format(notif.sentDate) %>
                                        </p>
                                    </div>
                                    <div style="margin-left: 1rem;">
                                        <% if (!notif.isRead) { %>
                                            <form method="post" action="<%= request.getContextPath() %>/personal/mark-notification-read" style="display: inline;">
                                                <input type="hidden" name="notification_id" value="<%= notif.notificationId %>" />
                                                <button type="submit" class="btn-icon-text" style="font-size: 0.9rem;">
                                                    <i class="fa-solid fa-check"></i> Mark as Read
                                                </button>
                                            </form>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        <% } %>
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

