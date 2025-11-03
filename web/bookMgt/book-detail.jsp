<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<%@ page import="dal.ReservationDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Details</title>
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
                <% Integer currentUserId = (Integer) request.getSession().getAttribute("authUserId"); %>
                <% if (currentUserId != null) { %>
                    <a href="<%= request.getContextPath() %>/books/my-reservations" class="nav-item">
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
                <% } %>
            </div>
            <% if (currentUserId != null) { %>
                <div class="nav-section">
                    <div class="nav-section-title">Account</div>
                    <a href="<%= request.getContextPath() %>/logout" class="nav-item">
                        <i class="fa-solid fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </div>
            <% } else { %>
                <div class="nav-section">
                    <div class="nav-section-title">Account</div>
                    <a href="<%= request.getContextPath() %>/login" class="nav-item">
                        <i class="fa-solid fa-sign-in-alt"></i>
                        <span>Login</span>
                    </a>
                </div>
            <% } %>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Book Details</h1>
                <p class="page-subtitle">View complete book information, availability status, location</p>
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
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% BookDAO.BookDetail book = (BookDAO.BookDetail) request.getAttribute("book"); %>
            <% if (book != null) { %>
                <section class="card">
                    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 2rem;">
                        <div>
                            <% if (book.coverImage != null && !book.coverImage.isEmpty()) { %>
                                <img src="<%= book.coverImage %>" alt="<%= book.title %>" style="width: 100%; max-width: 300px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />
                            <% } else { %>
                                <div style="width: 100%; max-width: 300px; height: 400px; background: var(--color-bg-secondary); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--color-text-muted);">
                                    <i class="fa-solid fa-book" style="font-size: 4rem;"></i>
                                </div>
                            <% } %>
                        </div>
                        <div>
                            <h2 style="margin-top: 0; font-size: 2rem;"><%= book.title %></h2>
                            
                            <div class="member-info-card" style="margin: 1.5rem 0;">
                                <div class="info-row">
                                    <span class="info-label">ISBN:</span>
                                    <span class="info-value"><%= book.isbn != null ? book.isbn : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Authors:</span>
                                    <span class="info-value">
                                        <% if (book.authorNames != null && !book.authorNames.isEmpty()) { %>
                                            <%= String.join(", ", book.authorNames) %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Category:</span>
                                    <span class="info-value"><%= book.categoryName != null ? book.categoryName : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Publisher:</span>
                                    <span class="info-value"><%= book.publisherName != null ? book.publisherName : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Publication Year:</span>
                                    <span class="info-value"><%= book.publicationYear != null ? book.publicationYear : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Edition:</span>
                                    <span class="info-value"><%= book.edition != null ? book.edition : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Language:</span>
                                    <span class="info-value"><%= book.language != null ? book.language : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Pages:</span>
                                    <span class="info-value"><%= book.pages != null ? book.pages : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Shelf Location:</span>
                                    <span class="info-value"><%= book.shelfLocation != null ? book.shelfLocation : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Availability:</span>
                                    <span class="info-value">
                                        <% if (book.availableCopies > 0) { %>
                                            <span class="status-badge status-active"><%= book.availableCopies %> copies available</span>
                                        <% } else { %>
                                            <span class="status-badge status-locked">Currently unavailable</span>
                                        <% } %>
                                        (<%= book.totalCopies %> total copies)
                                    </span>
                                </div>
                            </div>

                            <% if (book.description != null && !book.description.isEmpty()) { %>
                                <div style="margin-top: 1.5rem;">
                                    <h3>Description</h3>
                                    <p style="line-height: 1.6; color: var(--color-text);"><%= book.description %></p>
                                </div>
                            <% } %>

                            <div class="form-actions" style="margin-top: 2rem;">
                                <% Boolean hasReservation = (Boolean) request.getAttribute("hasReservation"); %>
                                <% if (currentUserId != null) { %>
                                    <% if (hasReservation != null && hasReservation) { %>
                                        <span class="text-muted" style="margin-right: 1rem;">
                                            <i class="fa-solid fa-bookmark"></i> You have an active reservation for this book
                                        </span>
                                        <a href="<%= request.getContextPath() %>/books/my-reservations" class="btn-secondary">
                                            View My Reservations
                                        </a>
                                    <% } else if (book.availableCopies > 0) { %>
                                        <span class="text-muted" style="margin-right: 1rem;">Book is available for borrowing</span>
                                    <% } else { %>
                                        <form method="post" action="<%= request.getContextPath() %>/books/reserve" style="display: inline;">
                                            <input type="hidden" name="book_id" value="<%= book.bookId %>" />
                                            <button class="btn-primary" type="submit">
                                                <i class="fa-solid fa-bookmark"></i> Reserve This Book
                                            </button>
                                        </form>
                                    <% } %>
                                <% } else { %>
                                    <p class="text-muted">Please <a href="<%= request.getContextPath() %>/login">login</a> to reserve this book.</p>
                                <% } %>
                                <a href="<%= request.getContextPath() %>/books" class="btn-secondary">
                                    <i class="fa-solid fa-arrow-left"></i> Back to Search
                                </a>
                            </div>
                        </div>
                    </div>
                </section>
            <% } else { %>
                <section class="card">
                    <p>Book not found.</p>
                    <a href="<%= request.getContextPath() %>/books" class="btn-secondary">Back to Search</a>
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

