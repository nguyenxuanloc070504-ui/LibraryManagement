<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="member-update"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="My Profile"/>
            <jsp:param name="pageSubtitle" value="Update your personal information and avatar"/>
        </jsp:include>

        <div class="main-content">
            <% dal.MemberDAO.MemberDetail p = (dal.MemberDAO.MemberDetail) request.getAttribute("profile"); %>
            <section class="card" style="width: 100%;">
                <% String mode = request.getParameter("mode"); boolean edit = "edit".equalsIgnoreCase(mode); %>
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:1rem;">
                    <h2 class="form-section-title" style="margin:0;">Profile Details</h2>
                    <% if (!edit) { %>
                        <a class="btn-primary" style="width:auto; text-decoration:none;" href="<%= request.getContextPath() %>/member/profile?mode=edit">Edit</a>
                    <% } %>
                </div>
                <% if (!edit) { %>
                <!-- VIEW MODE -->
                <div class="member-info-card">
                    <% String userName = (p != null && p.fullName != null && !p.fullName.isEmpty()) ? p.fullName : (session.getAttribute("authFullName")!=null? (String)session.getAttribute("authFullName") : (session.getAttribute("authUsername")!=null? (String)session.getAttribute("authUsername") : "User"));
                       String initials = "";
                       try {
                           String[] parts = userName.trim().split("\\s+");
                           for (int i = 0; i < parts.length && i < 2; i++) { if (!parts[i].isEmpty()) initials += Character.toUpperCase(parts[i].charAt(0)); }
                           if (initials.isEmpty()) initials = userName.substring(0,1).toUpperCase();
                       } catch (Exception ignored) { initials = "U"; }
                       String avatar = (p != null && p.profilePhoto != null && !p.profilePhoto.isEmpty()) ? p.profilePhoto : (session.getAttribute("authProfilePhoto")!=null?(String)session.getAttribute("authProfilePhoto"):null); %>
                    <div style="display:flex; justify-content:center; margin: 0 0 1rem;">
                        <% if (avatar != null) { %>
                            <img src="<%= request.getContextPath() + avatar %>" alt="Avatar" style="width:120px; height:120px; border-radius:50%; object-fit:cover; box-shadow:0 2px 8px rgba(0,0,0,.08);" />
                        <% } else { %>
                            <div class="user-avatar" style="width:120px;height:120px; font-size:2.25rem;">
                                <%= initials %>
                            </div>
                        <% } %>
                    </div>

                    <div class="form-grid two-col">
                        <div class="info-row"><span class="info-label">Username:</span><span class="info-value"><%= p != null ? p.username : (session.getAttribute("authUsername")!=null?session.getAttribute("authUsername"):"") %></span></div>
                        <div class="info-row"><span class="info-label">Full Name:</span><span class="info-value"><%= p != null && p.fullName != null ? p.fullName : (session.getAttribute("authFullName")!=null?session.getAttribute("authFullName"):"") %></span></div>
                        <div class="info-row"><span class="info-label">Email:</span><span class="info-value"><%= p != null && p.email != null ? p.email : (session.getAttribute("authEmail")!=null?session.getAttribute("authEmail"):"") %></span></div>
                        <div class="info-row"><span class="info-label">Phone:</span><span class="info-value"><%= p != null && p.phone != null ? p.phone : "-" %></span></div>
                        <div class="info-row"><span class="info-label">Address:</span><span class="info-value"><%= p != null && p.address != null ? p.address : "-" %></span></div>
                        <div class="info-row"><span class="info-label">Date of Birth:</span><span class="info-value"><%= p != null && p.dateOfBirth != null ? p.dateOfBirth : "-" %></span></div>
                        <div class="info-row"><span class="info-label">Membership #:</span><span class="info-value"><%= p != null && p.membershipNumber != null ? p.membershipNumber : "-" %></span></div>
                        <div class="info-row"><span class="info-label">Type:</span><span class="info-value"><%= p != null && p.membershipType != null ? p.membershipType : "-" %></span></div>
                        <div class="info-row"><span class="info-label">Expiry:</span><span class="info-value"><%= p != null && p.expiryDate != null ? p.expiryDate : "-" %></span></div>
                    </div>
                </div>
                <% } else { %>
                <!-- EDIT MODE -->
                <form class="auth-form" method="post" action="<%= request.getContextPath() %>/member/profile" enctype="multipart/form-data">
                    <% String userName2 = (p != null && p.fullName != null && !p.fullName.isEmpty()) ? p.fullName : (session.getAttribute("authFullName")!=null? (String)session.getAttribute("authFullName") : (session.getAttribute("authUsername")!=null? (String)session.getAttribute("authUsername") : "User"));
                       String initials2 = "";
                       try {
                           String[] parts = userName2.trim().split("\\s+");
                           for (int i = 0; i < parts.length && i < 2; i++) { if (!parts[i].isEmpty()) initials2 += Character.toUpperCase(parts[i].charAt(0)); }
                           if (initials2.isEmpty()) initials2 = userName2.substring(0,1).toUpperCase();
                       } catch (Exception ignored) { initials2 = "U"; }
                       String avatar2 = (p != null && p.profilePhoto != null && !p.profilePhoto.isEmpty()) ? p.profilePhoto : (session.getAttribute("authProfilePhoto")!=null?(String)session.getAttribute("authProfilePhoto"):null); %>
                    <div style="display:flex; justify-content:center; margin: 0 0 1rem;">
                        <% if (avatar2 != null) { %>
                            <img src="<%= request.getContextPath() + avatar2 %>" alt="Avatar" style="width:120px; height:120px; border-radius:50%; object-fit:cover; box-shadow:0 2px 8px rgba(0,0,0,.08);" />
                        <% } else { %>
                            <div class="user-avatar" style="width:120px;height:120px; font-size:2.25rem;">
                                <%= initials2 %>
                            </div>
                        <% } %>
                    </div>
                    <div class="form-grid two-col">
                        <div class="info-row"><span class="info-label">Full Name:</span><span class="info-value"><div class="input box"><input type="text" name="full_name" value='<%= p != null && p.fullName != null ? p.fullName : (session.getAttribute("authFullName") != null ? session.getAttribute("authFullName") : "") %>' /></div></span></div>
                        <div class="info-row"><span class="info-label">Email:</span><span class="info-value"><div class="input box"><input type="email" name="email" value='<%= p != null && p.email != null ? p.email : (session.getAttribute("authEmail") != null ? session.getAttribute("authEmail") : "") %>' /></div></span></div>
                        <div class="info-row"><span class="info-label">Phone:</span><span class="info-value"><div class="input box"><input type="text" name="phone" value='<%= p != null && p.phone != null ? p.phone : "" %>' /></div></span></div>
                        <div class="info-row"><span class="info-label">Address:</span><span class="info-value"><div class="input box"><input type="text" name="address" value='<%= p != null && p.address != null ? p.address : "" %>' /></div></span></div>
                        <div class="info-row"><span class="info-label">Date of Birth:</span><span class="info-value"><div class="input box"><input type="date" name="dob" value='<%= p != null && p.dateOfBirth != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(p.dateOfBirth) : "" %>' /></div></span></div>
                        <div class="info-row" style="grid-column: 1 / -1;"><span class="info-label">Avatar:</span><span class="info-value"><div class="input box"><input type="file" name="avatar" accept="image/*" /></div></span></div>
                    </div>
                    <div class="form-actions">
                        <button class="btn-primary" type="submit" style="width:auto;">
                            <i class="fa-solid fa-floppy-disk"></i> Save Changes
                        </button>
                        <a class="btn-secondary" href="<%= request.getContextPath() %>/member/profile" style="text-decoration:none;">Cancel</a>
                    </div>
                </form>
                <% } %>
            </section>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


