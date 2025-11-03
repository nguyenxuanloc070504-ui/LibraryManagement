<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.ReservationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reservations</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand-small">Library Management System</div>
        <nav class="nav">
            <div class="nav-section">
                <div class="nav-section-title">Reader Menu</div>
                <a href="<%= request.getContextPath() %>/books" class="nav-item">
                    <i class="fa-solid fa-book"></i>
                    <span>Search Books</span>
                </a>
                <a href="<%= request.getContextPath() %>/books/my-reservations" class="nav-item active">
                    <i class="fa-solid fa-bookmark"></i>
                    <span>My Reservations</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/current-borrowings" class="nav-item">
                    <i class="fa-solid fa-book-open"></i>
                    <span>Current Borrowings</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/borrowing-history" class="nav-item">
                    <i class="fa-solid fa-history"></i>
                    <span>Borrowing History</span>
                </a>
                <a href="<%= request.getContextPath() %>/personal/notifications" class="nav-item">
                    <i class="fa-solid fa-bell"></i>
                    <span>Notifications</span>
                </a>
            </div>
            <div class="nav-section">
                <div class="nav-section-title">Account</div>
                <a href="<%= request.getContextPath() %>/logout" class="nav-item">
                    <i class="fa-solid fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">My Reservations</h1>
                <p class="page-subtitle">View and manage your book reservations</p>
            </div>
        </header>

        <div class="main-content">
            <% 
                String successMsg = (String) request.getSession().getAttribute("success");
                String errorMsg = (String) request.getSession().getAttribute("error");
                if (successMsg != null) {
                    request.getSession().removeAttribute("success");
            %>
                <div class="alert-success"><%= successMsg %></div>
            <% } %>
            <% if (errorMsg != null) {
                    request.getSession().removeAttribute("error");
            %>
                <div class="alert-error"><%= errorMsg %></div>
            <% } %>

            <% List<ReservationDAO.ReservationDetail> reservations = (List<ReservationDAO.ReservationDetail>) request.getAttribute("reservations"); %>
            <% SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm"); %>
            
            <% if (reservations == null || reservations.isEmpty()) { %>
                <section class="card">
                    <p>You don't have any reservations yet.</p>
                    <a href="<%= request.getContextPath() %>/books" class="btn-primary">Search Books</a>
                </section>
            <% } else { %>
                <section class="card">
                    <h2 class="form-section-title">Your Reservations</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Book</th>
                                    <th>ISBN</th>
                                    <th>Category</th>
                                    <th>Reserved Date</th>
                                    <th>Expires On</th>
                                    <th>Status</th>
                                    <th>Available</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (ReservationDAO.ReservationDetail res : reservations) { %>
                                    <tr>
                                        <td><strong><%= res.bookTitle %></strong></td>
                                        <td><%= res.isbn != null ? res.isbn : "N/A" %></td>
                                        <td><%= res.categoryName != null ? res.categoryName : "N/A" %></td>
                                        <td><%= dateFormat.format(res.reservationDate) %></td>
                                        <td>
                                            <%= dateFormat.format(res.expiryDate) %>
                                            <% 
                                                long now = System.currentTimeMillis();
                                                long expiry = res.expiryDate.getTime();
                                                if (expiry < now && "active".equals(res.reservationStatus)) {
                                            %>
                                                <span class="status-badge status-locked">Expired</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <span class="status-badge <%= 
                                                "active".equals(res.reservationStatus) ? "status-active" : 
                                                "fulfilled".equals(res.reservationStatus) ? "status-success" : 
                                                "status-locked" 
                                            %>">
                                                <%= res.reservationStatus %>
                                            </span>
                                        </td>
                                        <td>
                                            <% if (res.availableCopies > 0) { %>
                                                <span class="status-badge status-active">Yes (<%= res.availableCopies %>)</span>
                                            <% } else { %>
                                                <span class="status-badge status-locked">No</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <% if ("active".equals(res.reservationStatus)) { %>
                                                <form method="post" action="<%= request.getContextPath() %>/books/cancel-reservation" style="display: inline;">
                                                    <input type="hidden" name="reservation_id" value="<%= res.reservationId %>" />
                                                    <button type="submit" class="btn-icon-text" style="background: var(--color-error);" 
                                                            onclick="return confirm('Are you sure you want to cancel this reservation?');">
                                                        <i class="fa-solid fa-times"></i> Cancel
                                                    </button>
                                                </form>
                                            <% } else { %>
                                                <span class="text-muted">-</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>
            <% } %>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

