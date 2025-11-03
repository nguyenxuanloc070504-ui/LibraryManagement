<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.MemberDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Renew Membership</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="member-renew"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Renew Membership"/>
            <jsp:param name="pageSubtitle" value="Extend library card validity period for members"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% MemberDAO.MemberDetail member = (MemberDAO.MemberDetail) request.getAttribute("member"); %>
            <% java.util.List<MemberDAO.MemberDetail> searchResults = (java.util.List<MemberDAO.MemberDetail>) request.getAttribute("searchResults"); %>
            <% SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd"); %>

            <% if (member == null && searchResults == null) { %>
                <!-- Search Form -->
                <section class="card">
                    <h2 class="form-section-title">Search Member</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Search by username, email, name, or membership number</p>
                    <form method="get" action="<%= request.getContextPath() %>/member/renew" class="auth-form">
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
                                        <th>Membership Number</th>
                                        <th>Expiry Date</th>
                                        <th>Status</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (MemberDAO.MemberDetail m : searchResults) { %>
                                        <tr>
                                            <td><%= m.username %></td>
                                            <td><%= m.fullName %></td>
                                            <td><%= m.membershipNumber != null ? m.membershipNumber : "N/A" %></td>
                                            <td><%= m.expiryDate != null ? sdf.format(m.expiryDate) : "N/A" %></td>
                                            <td>
                                                <% if (m.expiryDate != null && m.expiryDate.before(new java.util.Date())) { %>
                                                    <span class="status-badge status-expired">Expired</span>
                                                <% } else if (m.isActive != null && m.isActive) { %>
                                                    <span class="status-badge status-active">Active</span>
                                                <% } else { %>
                                                    <span class="status-badge status-inactive">Inactive</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/member/renew?id=<%= m.userId %>" class="btn-icon-text">
                                                    <i class="fa-solid fa-rotate"></i> Renew
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                    <div class="form-actions" style="margin-top:1rem;">
                        <a href="<%= request.getContextPath() %>/member/renew" class="btn-secondary">New Search</a>
                    </div>
                </section>
            <% } else if (member != null) { %>
                <!-- Renew Form -->
                <section class="card">
                    <h2 class="form-section-title">Membership Information</h2>
                    <% if (member.membershipId == null) { %>
                        <div class="alert-error">This member does not have an active membership.</div>
                    <% } else { %>
                        <div class="member-info-card">
                            <div class="info-row">
                                <span class="info-label">Member:</span>
                                <span class="info-value"><%= member.fullName %> (<%= member.username %>)</span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Membership Number:</span>
                                <span class="info-value"><%= member.membershipNumber %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Membership Type:</span>
                                <span class="info-value"><%= member.membershipType != null ? member.membershipType.toUpperCase() : "N/A" %></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Current Expiry Date:</span>
                                <span class="info-value"><%= member.expiryDate != null ? sdf.format(member.expiryDate) : "N/A" %></span>
                            </div>
                            <% if (member.expiryDate != null && member.expiryDate.before(new java.util.Date())) { %>
                                <div class="info-row">
                                    <span class="info-label">Status:</span>
                                    <span class="status-badge status-expired">Expired</span>
                                </div>
                            <% } %>
                        </div>
                        
                        <form method="post" action="<%= request.getContextPath() %>/member/renew" class="auth-form" novalidate style="margin-top:1.5rem;">
                            <input type="hidden" name="user_id" value="<%= member.userId %>" />
                            
                            <div class="form-field">
                                <label class="label-muted">Extension Period<span class="req">*</span></label>
                                <div class="input box">
                                    <select name="extension_months" required>
                                        <option value="">Select extension period</option>
                                        <%
                                            int defMonths = (member.membershipType != null && "student".equalsIgnoreCase(member.membershipType)) ? 6 : 12;
                                        %>
                                        <option value="1" <%= defMonths==1?"selected":"" %>>1 Month</option>
                                        <option value="3" <%= defMonths==3?"selected":"" %>>3 Months</option>
                                        <option value="6" <%= defMonths==6?"selected":"" %>>6 Months</option>
                                        <option value="12" <%= defMonths==12?"selected":"" %>>12 Months</option>
                                        <option value="24" <%= defMonths==24?"selected":"" %>>24 Months</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="form-actions">
                                <button class="btn-primary" type="submit" style="width:auto;">
                                    <i class="fa-solid fa-rotate"></i> Renew Membership
                                </button>
                                <a href="<%= request.getContextPath() %>/member/renew" class="btn-secondary">Cancel</a>
                            </div>
                        </form>
                    <% } %>
                </section>
            <% } %>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/member-renew.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

