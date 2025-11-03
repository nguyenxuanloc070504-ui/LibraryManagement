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
    <aside class="sidebar">
        <div class="brand-small">Library Management System</div>

        <nav class="nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="<%= request.getContextPath() %>/dashboard" class="nav-item">
                    <i class="fa-solid fa-chart-line"></i>
                    <span>Dashboard</span>
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Member Management</div>
                <a href="<%= request.getContextPath() %>/member/register" class="nav-item active">
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
                <div class="nav-section-title">Transactions</div>
                <a href="#" class="nav-item">
                    <i class="fa-solid fa-hand-holding"></i>
                    <span>Lend Book</span>
                </a>
                <a href="#" class="nav-item">
                    <i class="fa-solid fa-arrow-rotate-left"></i>
                    <span>Return Book</span>
                </a>
                <a href="#" class="nav-item">
                    <i class="fa-solid fa-coins"></i>
                    <span>Process Late Fees</span>
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Reports</div>
                <a href="#" class="nav-item">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>Reports & Statistics</span>
                </a>
                <a href="#" class="nav-item">
                    <i class="fa-solid fa-clock"></i>
                    <span>Overdue Management</span>
                </a>
            </div>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Register New Member</h1>
                <p class="page-subtitle">Create a library membership for a new user</p>
            </div>
            <div class="header-actions">
                <div class="user-dropdown">
                    <button class="user-trigger" type="button" aria-haspopup="true" aria-expanded="false">
                        <div class="user-avatar">
                            <i class="fa-solid fa-user-tie"></i>
                        </div>
                        <div class="user-info">
                            <div class="user-name"><%= session.getAttribute("authFullName") != null ? session.getAttribute("authFullName") : "Librarian" %></div>
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
                    <div class="input box"><input name="username" value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>" required /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("username") != null) { %>
                    <div class="field-error"><%= e.get("username") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Password<span class="req">*</span></label>
                    <div class="input box"><input type="password" name="password" required /></div>
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
                    <div class="input box"><input type="email" name="email" value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required /></div>
                    <% if (request.getAttribute("errors") != null) { java.util.Map e = (java.util.Map)request.getAttribute("errors"); if (e.get("email") != null) { %>
                    <div class="field-error"><%= e.get("email") %></div>
                    <% } } %>
                </div>
                <div class="form-field">
                    <label class="label-muted">Phone</label>
                    <div class="input box"><input name="phone" /></div>
                </div>
                <div class="form-field">
                    <label class="label-muted">Date of Birth</label>
                    <div class="input box"><input type="date" name="date_of_birth" value="<%= request.getParameter("date_of_birth") != null ? request.getParameter("date_of_birth") : "" %>" /></div>
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
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/member-registration.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/dashboard.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


