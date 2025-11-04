<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="controller.notifications.NotificationDetailServlet.DetailItem" %>
<%
    String userRole = (String) session.getAttribute("authRole");
    boolean isMember = "Member".equalsIgnoreCase(userRole);
    boolean isLibrarian = "Librarian".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
    DetailItem n = (DetailItem) request.getAttribute("item");
%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Notification Detail</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/button.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/card.css">
    <% if (isMember) { %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pages/home.css">
    <% } %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .n-detail-actions { display:flex; gap:.5rem; flex-wrap:wrap; }
    </style>
    </head>
<body class="<%= isMember ? "home-page" : "" %>">
<div class="<%= isLibrarian ? "layout" : "" %>">
    <% if (isLibrarian) { %>
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="notifications"/>
    </jsp:include>
    <% } %>
    <main class="<%= isLibrarian ? "content" : "" %>">
        <% if (isMember) { %>
        <jsp:include page="/components/header-member.jsp">
            <jsp:param name="activeTab" value="notifications"/>
        </jsp:include>
        <% } else { %>
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Notification Detail"/>
            <jsp:param name="pageSubtitle" value="View notification information"/>
        </jsp:include>
        <% } %>

        <div class="<%= isMember ? "container" : "main-content" %>" style="<%= isMember ? "padding-top: 2rem; padding-bottom: 2rem;" : "" %>">
            <section class="card" style="padding:1rem;">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:.5rem;">
                    <i class="fa-solid fa-bell" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;"> <%= n != null ? n.title : "Notification" %> </h2>
                </div>
                <div class="muted" style="margin-bottom:1rem;">
                    <i class="fa-regular fa-clock"></i>
                    <span style="margin-left:.25rem;"><%= n != null ? n.sentDate : "" %></span>
                </div>
                <div style="white-space:pre-wrap; word-break:break-word;">
                    <%= n != null ? n.message : "" %>
                </div>
                <div class="n-detail-actions" style="margin-top:1rem;">
                    <a class="btn-secondary inline-btn no-underline" href="<%= request.getContextPath() %>/notifications">Back to list</a>
                    <% if (n != null && n.referenceId != null) { %>
                        <!-- Contextual navigation based on known types -->
                        <% if ("general".equalsIgnoreCase(n.type) && n.title != null && n.title.contains("Approved")) { %>
                            <a class="btn-primary inline-btn no-underline" href="<%= request.getContextPath() %>/transaction/my-borrowings">Go to My Borrowings</a>
                        <% } %>
                    <% } %>
                </div>
            </section>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


