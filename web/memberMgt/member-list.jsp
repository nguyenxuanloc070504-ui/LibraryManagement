<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Members</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="member-list"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Members"/>
            <jsp:param name="pageSubtitle" value="Browse, search and manage members"/>
        </jsp:include>

        <div class="main-content">
            <% if ("1".equals(request.getParameter("success"))) { %>
                <div class="alert-success">Member created successfully.</div>
            <% } %>

            <!-- Filter Card -->
            <section class="card" style="margin-bottom: 1rem;">
                <form method="get" action="<%= request.getContextPath() %>/member/list" class="auth-form" style="margin:0 0 1rem; display:grid; grid-template-columns: 1.4fr 1fr auto; gap: 1rem; align-items: end;">
                    <div>
                        <div class="form-field" style="margin:0;">
                            <label class="label-muted">Search</label>
                            <div class="input box">
                                <input type="text" name="search" placeholder="Username, Email or Name" value="<%= request.getAttribute("search") != null ? request.getAttribute("search") : "" %>">
                            </div>
                        </div>
                    </div>
                    <div>
                        <div class="form-field" style="margin:0;">
                            <label class="label-muted">Status</label>
                            <div class="input box">
                                <select name="status">
                                    <%
                                        String s = (String)request.getAttribute("status");
                                        if (s == null) s = "all";
                                    %>
                                    <option value="all" <%= "all".equals(s) ? "selected" : "" %>>All</option>
                                    <option value="active" <%= "active".equals(s) ? "selected" : "" %>>Active</option>
                                    <option value="locked" <%= "locked".equals(s) ? "selected" : "" %>>Locked</option>
                                    <option value="suspended" <%= "suspended".equals(s) ? "selected" : "" %>>Suspended</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="form-actions" style="margin:0; display:flex; gap:.5rem; justify-content:flex-end; align-self:end;">
                        <button class="btn-primary" type="submit" style="width:auto;">Search</button>
                        <a class="btn-secondary" href="<%= request.getContextPath() %>/member/list" style="text-decoration:none;">Reset</a>
                    </div>
                </form>
            </section>

            <!-- Results Card -->
            <section class="card">
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Username</th>
                                <th>Full Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Membership</th>
                                <th>Type</th>
                                <th>Expiry</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            java.util.List list = (java.util.List) request.getAttribute("members");
                            if (list == null || list.isEmpty()) {
                        %>
                            <tr><td colspan="5" class="muted">No members found</td></tr>
                        <%
                            } else {
                                for (Object o : list) {
                                    dal.MemberDAO.MemberDetail m = (dal.MemberDAO.MemberDetail) o;
                        %>
                            <tr>
                                <td><%= m.username %></td>
                                <td><%= m.fullName %></td>
                                <td><%= m.email %></td>
                                <td><%= m.phone != null ? m.phone : "-" %></td>
                                <td><%= m.membershipNumber != null ? m.membershipNumber : "-" %></td>
                                <td><%= m.membershipType != null ? m.membershipType : "-" %></td>
                                <td><%= m.expiryDate != null ? m.expiryDate : "-" %></td>
                                <td><span class="status-badge status-<%= m.accountStatus != null ? m.accountStatus : "active" %>"><%= m.accountStatus != null ? m.accountStatus : "active" %></span></td>
                                 <td>
                                     <div class="action-group">
                                         <a class="btn-icon-text" href="<%= request.getContextPath() %>/member/update?id=<%= m.userId %>"><i class="fa-solid fa-pen"></i></a>
                                         <a class="btn-icon-text" href="<%= request.getContextPath() %>/member/renew?id=<%= m.userId %>"><i class="fa-solid fa-rotate"></i></a>
                                         <a class="btn-icon-text" href="<%= request.getContextPath() %>/member/lock-unlock?id=<%= m.userId %>"><i class="fa-solid fa-user-lock"></i></a>
                                     </div>
                                 </td>
                            </tr>
                        <%
                                }
                            }
                        %>
                        </tbody>
                    </table>
                </div>

                <div class="form-actions" style="justify-content: space-between; align-items:center;">
                    <div class="muted">Total: <%= request.getAttribute("total") != null ? request.getAttribute("total") : 0 %></div>
                    <div>
                        <%
                            int currentPage = request.getAttribute("page") != null ? (Integer)request.getAttribute("page") : 1;
                            int totalPages = request.getAttribute("totalPages") != null ? (Integer)request.getAttribute("totalPages") : 1;
                            String q = request.getAttribute("search") != null ? (String)request.getAttribute("search") : "";
                            String st = request.getAttribute("status") != null ? (String)request.getAttribute("status") : "all";
                        %>
                        <a class="btn-secondary" href="<%= request.getContextPath() %>/member/list?search=<%= java.net.URLEncoder.encode(q, "UTF-8") %>&status=<%= st %>&page=<%= Math.max(1, currentPage-1) %>">Prev</a>
                        <span style="margin:0 .5rem;">Page <%= currentPage %> / <%= Math.max(1,totalPages) %></span>
                        <a class="btn-secondary" href="<%= request.getContextPath() %>/member/list?search=<%= java.net.URLEncoder.encode(q, "UTF-8") %>&status=<%= st %>&page=<%= currentPage+1 %>">Next</a>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


