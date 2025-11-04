<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get active tab from request parameter
    String activeTab = request.getParameter("activeTab") != null ? request.getParameter("activeTab") : "home";
    String contextPath = request.getContextPath();

    // Get user info from session
    String userName = (String) session.getAttribute("authFullName");
    if (userName == null || userName.isEmpty()) {
        userName = (String) session.getAttribute("authUsername");
    }
    if (userName == null || userName.isEmpty()) {
        userName = "Member";
    }

    // Get user role from session
    String userRole = (String) session.getAttribute("authRole");
    if (userRole == null || userRole.isEmpty()) {
        userRole = "User";
    }

    // Resolve profile photo from session if available
    String profilePhoto = (String) session.getAttribute("authProfilePhoto");

    // Compute initials for default avatar
    String initials = "";
    try {
        String[] parts = userName.trim().split("\\s+");
        for (int i = 0; i < parts.length && i < 2; i++) {
            if (!parts[i].isEmpty()) {
                initials += Character.toUpperCase(parts[i].charAt(0));
            }
        }
        if (initials.isEmpty()) initials = userName.substring(0, 1).toUpperCase();
    } catch (Exception ignored) { initials = "U"; }
%>
<header class="content-header member-header">
    <div class="header-left">
        <div class="system-name">
            <i class="fas fa-book-open" style="margin-right: 8px; color: var(--color-primary);"></i>
            <span>Library Management System</span>
        </div>
    </div>

    <nav class="member-nav">
        <a href="<%= contextPath %>/home" class="member-nav-item <%= "home".equals(activeTab) ? "active" : "" %>">
            <i class="fas fa-home"></i>
            <span>Home</span>
        </a>
        <a href="<%= contextPath %>/book/list" class="member-nav-item <%= "books".equals(activeTab) ? "active" : "" %>">
            <i class="fas fa-book"></i>
            <span>Books</span>
        </a>
        <a href="<%= contextPath %>/transaction/my-borrowings" class="member-nav-item <%= "borrowings".equals(activeTab) ? "active" : "" %>">
            <i class="fas fa-book-reader"></i>
            <span>My Borrowings</span>
        </a>
        <a href="<%= contextPath %>/notifications" class="member-nav-item <%= "notifications".equals(activeTab) ? "active" : "" %>">
            <i class="fas fa-bell"></i>
            <span>Notifications</span>
        </a>
        <a href="<%= contextPath %>/member/profile" class="member-nav-item <%= "profile".equals(activeTab) ? "active" : "" %>">
            <i class="fas fa-user"></i>
            <span>Profile</span>
        </a>
    </nav>

    <div class="header-actions">
        <div class="user-dropdown">
            <button class="user-trigger" type="button" aria-haspopup="true" aria-expanded="false">
                <% if (profilePhoto != null && !profilePhoto.isEmpty()) { %>
                    <img src="<%= contextPath + profilePhoto %>" alt="Avatar" class="user-avatar" style="width:2.25rem;height:2.25rem;border-radius:9999px;object-fit:cover;" />
                <% } else { %>
                    <div class="user-avatar"><%= initials %></div>
                <% } %>
                <div class="user-info">
                    <div class="user-name"><%= userName %></div>
                    <div class="user-role"><%= userRole %></div>
                </div>
                <i class="fa-solid fa-chevron-down" style="font-size:.85rem;color:#6b7280;margin-left:.25rem;"></i>
            </button>
            <div class="user-menu" role="menu">
                <a href="<%= contextPath %>/member/profile" class="menu-item" role="menuitem">
                    <i class="fa-solid fa-user"></i>
                    <span>Profile</span>
                </a>
                <a href="<%= contextPath %>/logout" class="menu-item danger" role="menuitem">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Logout</span>
                </a>
            </div>
        </div>
    </div>
</header>
<script src="<%= contextPath %>/js/components/dropdown.js"></script>
