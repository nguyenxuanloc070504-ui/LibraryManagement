<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% 
    // Get page title and subtitle from request parameters
    String pageTitle = request.getParameter("pageTitle") != null ? request.getParameter("pageTitle") : "Page";
    String pageSubtitle = request.getParameter("pageSubtitle") != null ? request.getParameter("pageSubtitle") : "";
    String contextPath = request.getContextPath();
    
    // Get user info from session
    String userName = (String) session.getAttribute("authFullName");
    if (userName == null || userName.isEmpty()) {
        userName = (String) session.getAttribute("authUsername");
    }
    if (userName == null || userName.isEmpty()) {
        userName = "Librarian";
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
<header class="content-header">
    <div>
        <h1 class="page-title"><%= pageTitle %></h1>
        <% if (pageSubtitle != null && !pageSubtitle.isEmpty()) { %>
            <p class="page-subtitle"><%= pageSubtitle %></p>
        <% } %>
    </div>
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
                    <div class="user-role">Administrator</div>
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

