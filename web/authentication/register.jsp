<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="auth-body">
<main class="auth-center">
    <section class="auth-card">
        <div class="auth-hero"></div>
        <div class="auth-content">
            <div class="brand">Library Management System</div>
            <h1 class="auth-title">Create Your Account</h1>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <form class="auth-form" method="post" action="register" novalidate>
                <div class="form-field">
                    <label class="sr-only" for="username">Username</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-regular fa-user"></i></span>
                        <input id="username" name="username" placeholder="Username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>" required />
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("username") != null) { %>
                    <div class="field-error"><%= e.get("username") %></div>
                    <% } } %>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="password">Password</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-solid fa-lock"></i></span>
                        <input id="password" name="password" type="password" placeholder="Password" required />
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("password") != null) { %>
                    <div class="field-error"><%= e.get("password") %></div>
                    <% } } %>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="full_name">Full Name</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-regular fa-id-card"></i></span>
                        <input id="full_name" name="full_name" placeholder="Full Name" value="<%= request.getParameter("full_name") != null ? request.getParameter("full_name") : "" %>" required />
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("full_name") != null) { %>
                    <div class="field-error"><%= e.get("full_name") %></div>
                    <% } } %>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="email">Email Address</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-regular fa-envelope"></i></span>
                        <input id="email" name="email" type="email" placeholder="Email Address" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required />
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("email") != null) { %>
                    <div class="field-error"><%= e.get("email") %></div>
                    <% } } %>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="phone">Phone</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-solid fa-phone"></i></span>
                        <input id="phone" name="phone" placeholder="Phone (optional)" value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>" />
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("phone") != null) { %>
                    <div class="field-error"><%= e.get("phone") %></div>
                    <% } } %>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="date_of_birth">Date of Birth</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-regular fa-calendar"></i></span>
                        <input id="date_of_birth" name="date_of_birth" type="date" placeholder="Date of Birth (optional)" value="<%= request.getParameter("date_of_birth") != null ? request.getParameter("date_of_birth") : "" %>" />
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("date_of_birth") != null) { %>
                    <div class="field-error"><%= e.get("date_of_birth") %></div>
                    <% } } %>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="address">Address</label>
                    <div class="input box">
                        <textarea id="address" name="address" rows="3" placeholder="Address (optional)"><%= request.getParameter("address") != null ? request.getParameter("address") : "" %></textarea>
                    </div>
                </div>

                <div class="form-field">
                    <label class="sr-only" for="membership_type">Membership Type</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-solid fa-id-badge"></i></span>
                        <select id="membership_type" name="membership_type" required>
                            <option value="">Select Membership Type</option>
                            <% java.util.List types = (java.util.List) request.getAttribute("membershipTypes"); String sel = request.getParameter("membership_type"); if (types != null) { for (Object t : types) { String v = String.valueOf(t); %>
                                <option value="<%= v %>" <%= (sel != null && sel.equals(v)) ? "selected" : "" %>><%= v.substring(0,1).toUpperCase() + v.substring(1).toLowerCase() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("membership_type") != null) { %>
                    <div class="field-error"><%= e.get("membership_type") %></div>
                    <% } } %>
                </div>

                <button class="btn-primary" type="submit">Register</button>

                <p class="auth-footer">Already have an account? <a href="login">Sign in here</a></p>
            </form>
        </div>
    </section>
</main>
<script>
    // Pass context path to JavaScript
    window.APP_CONTEXT_PATH = '<%= request.getContextPath() %>';
</script>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/member-registration.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

