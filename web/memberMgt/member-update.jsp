<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.MemberDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Member Information</title>
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
                <a href="<%= request.getContextPath() %>/member/register" class="nav-item">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>Register New Member</span>
                </a>
                <a href="<%= request.getContextPath() %>/member/update" class="nav-item active">
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
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Update Member Information</h1>
                <p class="page-subtitle">Edit contact details, address, and profile information</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% MemberDAO.MemberDetail member = (MemberDAO.MemberDetail) request.getAttribute("member"); %>
            <% java.util.List<MemberDAO.MemberDetail> searchResults = (java.util.List<MemberDAO.MemberDetail>) request.getAttribute("searchResults"); %>

            <% if (member == null && searchResults == null) { %>
                <!-- Search Form -->
                <section class="card">
                    <h2 class="form-section-title">Search Member</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Search by username, email, name, or membership number</p>
                    <form method="get" action="<%= request.getContextPath() %>/member/update" class="auth-form">
                        <div class="form-field">
                            <label class="label-muted">Search</label>
                            <div class="input box">
                                <input type="text" name="search" placeholder="Enter username, email, name, or membership number" 
                                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" required />
                            </div>
                        </div>
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Search</button>
                        </div>
                    </form>
                </section>
            <% } else if (searchResults != null) { %>
                <!-- Search Results -->
                <section class="card">
                    <h2 class="form-section-title">Search Results</h2>
                    <% if (searchResults.isEmpty()) { %>
                        <p>No members found.</p>
                    <% } else { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Username</th>
                                        <th>Full Name</th>
                                        <th>Email</th>
                                        <th>Membership Number</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (MemberDAO.MemberDetail m : searchResults) { %>
                                        <tr>
                                            <td><%= m.username %></td>
                                            <td><%= m.fullName %></td>
                                            <td><%= m.email %></td>
                                            <td><%= m.membershipNumber != null ? m.membershipNumber : "N/A" %></td>
                                            <td><span class="status-badge status-<%= m.accountStatus != null ? m.accountStatus : "active" %>"><%= m.accountStatus != null ? m.accountStatus : "active" %></span></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/member/update?id=<%= m.userId %>" class="btn-icon-text">
                                                    <i class="fa-solid fa-edit"></i> Update
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                    <div class="form-actions" style="margin-top:1rem;">
                        <a href="<%= request.getContextPath() %>/member/update" class="btn-secondary">New Search</a>
                    </div>
                </section>
            <% } else if (member != null) { %>
                <!-- Update Form -->
                <section class="card">
                    <h2 class="form-section-title">Member Details</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Update member information</p>
                    <form method="post" action="<%= request.getContextPath() %>/member/update" class="auth-form" novalidate>
                        <input type="hidden" name="user_id" value="<%= member.userId %>" />
                        
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Username</label>
                                <div class="input box"><input type="text" value="<%= member.username != null ? member.username : "" %>" disabled /></div>
                                <small class="muted">Username cannot be changed</small>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Email<span class="req">*</span></label>
                                <div class="input box">
                                    <input type="email" name="email" value="<%= member.email != null ? member.email : "" %>" required />
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("email") != null) { %>
                                    <div class="field-error"><%= e.get("email") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Full Name<span class="req">*</span></label>
                                <div class="input box">
                                    <input type="text" name="full_name" value="<%= member.fullName != null ? member.fullName : "" %>" required />
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("full_name") != null) { %>
                                    <div class="field-error"><%= e.get("full_name") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Phone</label>
                                <div class="input box">
                                    <input type="text" name="phone" value="<%= member.phone != null ? member.phone : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Date of Birth</label>
                                <div class="input box">
                                    <input type="date" name="date_of_birth" value="<%= member.dateOfBirth != null ? member.dateOfBirth.toString() : "" %>" />
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("date_of_birth") != null) { %>
                                    <div class="field-error"><%= e.get("date_of_birth") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Profile Photo URL</label>
                                <div class="input box">
                                    <input type="text" name="profile_photo" value="<%= member.profilePhoto != null ? member.profilePhoto : "" %>" placeholder="https://..." />
                                </div>
                            </div>
                            <div class="form-field" style="grid-column: 1 / -1;">
                                <label class="label-muted">Address</label>
                                <div class="input box">
                                    <textarea name="address" rows="4"><%= member.address != null ? member.address : "" %></textarea>
                                </div>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Update Member</button>
                            <a href="<%= request.getContextPath() %>/member/update" class="btn-secondary">Cancel</a>
                        </div>
                    </form>
                </section>
            <% } %>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/member-update.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

