<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.MemberDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lock/Unlock Account</title>
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
                <a href="<%= request.getContextPath() %>/member/update" class="nav-item">
                    <i class="fa-solid fa-user-pen"></i>
                    <span>Update Member</span>
                </a>
                <a href="<%= request.getContextPath() %>/member/renew" class="nav-item">
                    <i class="fa-solid fa-rotate"></i>
                    <span>Renew Membership</span>
                </a>
                <a href="<%= request.getContextPath() %>/member/lock-unlock" class="nav-item active">
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
                <h1 class="page-title">Lock/Unlock Account</h1>
                <p class="page-subtitle">Temporarily lock or unlock member accounts</p>
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
                    <form method="get" action="<%= request.getContextPath() %>/member/lock-unlock" class="auth-form">
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
                                                <a href="<%= request.getContextPath() %>/member/lock-unlock?id=<%= m.userId %>" class="btn-icon-text">
                                                    <i class="fa-solid fa-user-lock"></i> Manage
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                    <div class="form-actions" style="margin-top:1rem;">
                        <a href="<%= request.getContextPath() %>/member/lock-unlock" class="btn-secondary">New Search</a>
                    </div>
                </section>
            <% } else if (member != null) { %>
                <!-- Lock/Unlock Form -->
                <section class="card">
                    <h2 class="form-section-title">Account Management</h2>
                    <div class="member-info-card">
                        <div class="info-row">
                            <span class="info-label">Member:</span>
                            <span class="info-value"><%= member.fullName %> (<%= member.username %>)</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Email:</span>
                            <span class="info-value"><%= member.email %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Membership Number:</span>
                            <span class="info-value"><%= member.membershipNumber != null ? member.membershipNumber : "N/A" %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Current Status:</span>
                            <span class="status-badge status-<%= member.accountStatus != null ? member.accountStatus : "active" %>">
                                <%= member.accountStatus != null ? member.accountStatus.toUpperCase() : "ACTIVE" %>
                            </span>
                        </div>
                    </div>
                    
                    <form method="post" action="<%= request.getContextPath() %>/member/lock-unlock" class="auth-form" novalidate style="margin-top:1.5rem;">
                        <input type="hidden" name="user_id" value="<%= member.userId %>" />
                        
                        <div class="form-field">
                            <label class="label-muted">Action<span class="req">*</span></label>
                            <div class="radio-group">
                                <% if (!"active".equals(member.accountStatus)) { %>
                                    <label class="radio-option">
                                        <input type="radio" name="action" value="unlock" required />
                                        <span class="radio-label">
                                            <i class="fa-solid fa-unlock"></i>
                                            <strong>Unlock Account</strong>
                                            <small>Restore full access to library services</small>
                                        </span>
                                    </label>
                                <% } %>
                                <% if (!"locked".equals(member.accountStatus)) { %>
                                    <label class="radio-option">
                                        <input type="radio" name="action" value="lock" required />
                                        <span class="radio-label">
                                            <i class="fa-solid fa-lock"></i>
                                            <strong>Lock Account</strong>
                                            <small>Temporarily restrict access (can be unlocked later)</small>
                                        </span>
                                    </label>
                                <% } %>
                                <% if (!"suspended".equals(member.accountStatus)) { %>
                                    <label class="radio-option">
                                        <input type="radio" name="action" value="suspend" required />
                                        <span class="radio-label">
                                            <i class="fa-solid fa-ban"></i>
                                            <strong>Suspend Account</strong>
                                            <small>Permanent restriction for serious violations</small>
                                        </span>
                                    </label>
                                <% } %>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">
                                <i class="fa-solid fa-save"></i> Apply Change
                            </button>
                            <a href="<%= request.getContextPath() %>/member/lock-unlock" class="btn-secondary">Cancel</a>
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
<script src="<%= request.getContextPath() %>/js/components/radio.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/member-lock-unlock.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

