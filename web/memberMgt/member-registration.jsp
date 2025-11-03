<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register New Member</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="member-register"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Register New Member"/>
            <jsp:param name="pageSubtitle" value="Create a library membership for a new user"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
                <script>
                    // Redirect to member list (update page) after 3 seconds
                    setTimeout(function(){ window.location.href = '<%= request.getContextPath() %>/member/update?search=' + encodeURIComponent('<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>'); }, 3000);
                </script>
            <% } %>
            <section class="card" style="width: 100%;">
                <div>
                    <h2 class="form-section-title">Member Details</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Create a library membership for a new user</p>
    <% if (request.getAttribute("membershipNumber") != null) { %>
    <div class="card" style="margin-top:1rem;">
        <p><strong>Full Name:</strong> ${fullName}</p>
        <p><strong>Username:</strong> ${username}</p>
        <p><strong>Membership Number:</strong> ${membershipNumber}</p>
        <p><strong>Expiry Date:</strong> ${expiryDate}</p>
        <div class="social-row" style="margin-top:1rem;">
            <a href="../member/register" class="btn-primary" style="width:auto;">Register Another</a>
            <a href="../dashboard" class="btn-primary" style="width:auto;background:#10b981; box-shadow:none;">Go to Dashboard</a>
        </div>
    </div>
    <% } else { %>
    <div class="card" style="margin-top:1rem;">
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert-error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form method="post" action="../member/register" class="auth-form" novalidate>
            <div class="form-grid two-col">
                <div class="form-field">
                    <label class="label-muted">Username<span class="req">*</span></label>
                    <div class="input box"><input id="username" name="username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>" required /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("username") != null) { %>
                    <div class="field-error"><%= e.get("username") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Password<span class="req">*</span></label>
                    <div class="input box"><input id="password" type="password" name="password" required /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("password") != null) { %>
                    <div class="field-error"><%= e.get("password") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Full Name<span class="req">*</span></label>
                    <div class="input box"><input name="full_name" value="<%= request.getParameter("full_name") != null ? request.getParameter("full_name") : "" %>" required /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("full_name") != null) { %>
                    <div class="field-error"><%= e.get("full_name") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Email<span class="req">*</span></label>
                    <div class="input box"><input id="email" type="email" name="email" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("email") != null) { %>
                    <div class="field-error"><%= e.get("email") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Phone</label>
                    <div class="input box"><input id="phone" name="phone" value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>" /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("phone") != null) { %>
                    <div class="field-error"><%= e.get("phone") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Date of Birth</label>
                    <div class="input box"><input id="date_of_birth" type="date" name="date_of_birth" value="<%= request.getParameter("date_of_birth") != null ? request.getParameter("date_of_birth") : "" %>" /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("date_of_birth") != null) { %>
                    <div class="field-error"><%= e.get("date_of_birth") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Address</label>
                    <div class="input box"><textarea name="address" rows="4"></textarea></div>
                </div>
                <div class="form-field">
                    <label class="label-muted">Membership Type</label>
                    <div class="input box">
                        <select name="membership_type">
                            <% java.util.List types = (java.util.List) request.getAttribute("membershipTypes"); String sel = request.getParameter("membership_type"); if (types != null) { for (Object t : types) { String v = String.valueOf(t); %>
                                <option value="<%= v %>" <%= (sel != null && sel.equals(v)) ? "selected" : "" %>><%= v.substring(0,1).toUpperCase() + v.substring(1).toLowerCase() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("membership_type") != null) { %>
                    <div class="field-error"><%= e.get("membership_type") %></div>
                    <% } } %>
                </div>
            </div>
            <div class="form-actions">
                <button class="btn-primary" type="submit" style="width:auto;">Create Member</button>
                <button class="btn-secondary" type="button" onclick="history.back()">Cancel</button>
            </div>
        </form>
    </div>
    <% } %>
                </div>
            </section>
        </div>
    </main>
</div>
<script>
    // Pass context path to JavaScript
    window.APP_CONTEXT_PATH = '<%= request.getContextPath() %>';
</script>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/member-registration.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/dashboard.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


