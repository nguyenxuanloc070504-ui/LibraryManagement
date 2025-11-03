<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="auth-body">
<main class="auth-center">
    <section class="auth-card">
        <div class="auth-hero"></div>
        <div class="auth-content">
            <div class="brand">Library Management System</div>
            <h1 class="auth-title">Sign Into Your Account</h1>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <form class="auth-form" method="post" action="login">
                <div class="form-field">
                    <label class="sr-only" for="email">Email Address</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-regular fa-envelope"></i></span>
                        <input id="email" name="username" placeholder="Email Address" required>
                    </div>
                </div>
                <div class="form-field">
                    <label class="sr-only" for="password">Password</label>
                    <div class="input with-icon">
                        <span class="icon"><i class="fa-solid fa-lock"></i></span>
                        <input id="password" name="password" type="password" placeholder="Password" required>
                    </div>
                </div>

                <div class="form-meta">
                    <label class="checkbox">
                        <input type="checkbox" name="remember"> <span>Remember me</span>
                    </label>
                    <a class="link-muted" href="#">Forgot your password?</a>
                </div>

                <button class="btn-primary" type="submit">Login</button>

                <p class="auth-footer">Don't have an account? <a href="../memberMgt/member-registration.jsp">Register here</a></p>
            </form>
        </div>
    </section>
</main>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/login.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


