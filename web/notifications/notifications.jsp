<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="controller.notifications.NotificationsServlet.Item" %>
<%
    String userRole = (String) session.getAttribute("authRole");
    boolean isMember = "Member".equalsIgnoreCase(userRole);
    boolean isLibrarian = "Librarian".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Notifications</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/button.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/table.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/card.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/alert.css">
    <% if (isMember) { %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pages/home.css">
    <% } %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
            <jsp:param name="pageTitle" value="Notifications"/>
            <jsp:param name="pageSubtitle" value="Your recent alerts and updates"/>
        </jsp:include>
        <% } %>

        <div class="<%= isMember ? "container" : "main-content" %>" style="<%= isMember ? "padding-top: 2rem; padding-bottom: 2rem;" : "" %>">
            <section class="card" style="width: 100%; margin-bottom: var(--spacing-xl);">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-bell" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Notifications</h2>
                </div>
                <p class="text-muted" style="margin:0;">Your recent alerts and updates.</p>
            </section>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- <div class="form-actions" style="justify-content:flex-end; margin-bottom:.75rem;">
                <form method="post" action="<%= request.getContextPath() %>/notifications/mark-read" style="margin:0;">
                    <input type="hidden" name="all" value="true" />
                    <button class="btn-secondary inline-btn" type="submit">
                        <i class="fa-regular fa-square-check"></i> Mark all as read
                    </button>
                </form>
            </div> -->

            <div class="card">
                <%
                    List<Item> items = (List<Item>) request.getAttribute("items");
                    if (items == null || items.isEmpty()) {
                %>
                    <div class="empty-state" style="text-align:center; padding:1.25rem; color:var(--color-text-light);">
                        <i class="fa-regular fa-bell" style="font-size:1.25rem; margin-right:.25rem;"></i>
                        No notifications
                    </div>
                <%
                    } else {
                        for (Item n : items) {
                %>
                    <div class="card" style="display:flex; align-items:flex-start; gap:1rem; padding:1rem; margin-bottom:.75rem;">
                        <div style="flex:0 0 auto;">
                            <i class="fa-solid fa-bell" style="color: var(--color-primary);"></i>
                        </div>
                        <div style="flex:1 1 auto; min-width:0;">
                            <div style="display:flex; align-items:center; gap:.5rem; flex-wrap:wrap;">
                                <h3 style="margin:0; font-size:1.05rem;">
                                    <a href="<%= request.getContextPath() %>/notifications/detail?id=<%= n.id %>" style="text-decoration:none; color:inherit;">
                                        <%= n.title %>
                                    </a>
                                </h3>
                                <% if (!n.isRead) { %>
                                    <span class="status-badge status-active">New</span>
                                <% } else { %>
                                    <span class="status-badge">Read</span>
                                <% } %>
                            </div>
                            <p class="text-muted" style="margin:.25rem 0 0; white-space:normal; word-break:break-word;">
                                <%= n.message %>
                            </p>
                            <div class="muted" style="margin-top:.5rem; font-size:.9rem;">
                                <i class="fa-regular fa-clock"></i>
                                <span style="margin-left:.25rem;"><%= n.sentDate %></span>
                            </div>
                        </div>
                        <div style="flex:0 0 auto; white-space:nowrap;">
                            <% if (!n.isRead) { %>
                                <form method="post" action="<%= request.getContextPath() %>/notifications/mark-read" style="display:inline;">
                                    <input type="hidden" name="id" value="<%= n.id %>" />
                                    <button class="btn-primary inline-btn" type="submit">
                                        <i class="fa-regular fa-envelope-open"></i> Mark read
                                    </button>
                                </form>
                            <% } else { %>
                                <span class="text-muted">—</span>
                            <% } %>
                        </div>
                    </div>
                <%
                        }
                    }
                %>
            </div>

            <%
                Integer pageNum = (Integer) request.getAttribute("page");
                Integer pageSize = (Integer) request.getAttribute("size");
                Integer totalCount = (Integer) request.getAttribute("total");
                Integer totalPagesNum = (Integer) request.getAttribute("totalPages");
                if (pageNum == null) pageNum = 1;
                if (pageSize == null) pageSize = 10;
                if (totalPagesNum == null) totalPagesNum = 1;
            %>
            <div class="form-actions" style="justify-content: space-between; align-items:center; margin-top:1rem;">
                <div class="muted">Total: <%= totalCount != null ? totalCount : 0 %></div>
                <div>
                    <a class="btn-secondary" href="<%= request.getContextPath() %>/notifications?page=<%= Math.max(1, pageNum-1) %>&size=<%= pageSize %>">Prev</a>
                    <span style="margin:0 .5rem;">Page <%= pageNum %> / <%= Math.max(1, totalPagesNum) %></span>
                    <a class="btn-secondary" href="<%= request.getContextPath() %>/notifications?page=<%= pageNum+1 %>&size=<%= pageSize %>">Next</a>
                </div>
            </div>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


