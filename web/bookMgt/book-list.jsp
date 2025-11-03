<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<%@ page import="dal.ReservationDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Books</title>
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
                <a href="<%= request.getContextPath() %>/books" class="nav-item active">
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
                <h1 class="page-title">Search Books</h1>
                <p class="page-subtitle">Look up books by title, author, genre, ISBN</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Search and Filter Form -->
            <section class="card">
                <h2 class="form-section-title">Search & Filter</h2>
                <form method="get" action="<%= request.getContextPath() %>/books" class="auth-form">
                    <div class="form-grid two-col">
                        <div class="form-field">
                            <label class="label-muted">Search</label>
                            <div class="input box">
                                <input type="text" name="search" placeholder="Title, ISBN, or Author" 
                                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Category</label>
                            <div class="input box">
                                <select name="category">
                                    <option value="">All Categories</option>
                                    <% List<Category> categories = (List<Category>) request.getAttribute("categories");
                                       if (categories != null) {
                                           String selectedCat = (String) request.getAttribute("selectedCategory");
                                           for (Category cat : categories) { %>
                                        <option value="<%= cat.getCategoryId() %>" <%= (selectedCat != null && selectedCat.equals(String.valueOf(cat.getCategoryId()))) ? "selected" : "" %>>
                                            <%= cat.getCategoryName() %>
                                        </option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn-primary" type="submit" style="width:auto;">
                            <i class="fa-solid fa-search"></i> Search
                        </button>
                        <a href="<%= request.getContextPath() %>/books" class="btn-secondary">Clear</a>
                    </div>
                </form>
            </section>

            <!-- Books List -->
            <% List<BookDAO.BookDetail> books = (List<BookDAO.BookDetail>) request.getAttribute("books"); %>
            <% String searchTerm = (String) request.getAttribute("searchTerm"); %>
            
            <% if (books != null && !books.isEmpty()) { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <h2 class="form-section-title">
                        Search Results
                        <% if (searchTerm != null) { %>
                            for "<%= searchTerm %>"
                        <% } %>
                        (<%= books.size() %> books)
                    </h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>ISBN</th>
                                    <th>Authors</th>
                                    <th>Category</th>
                                    <th>Available</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                    ReservationDAO reservationDAO = new ReservationDAO();
                                    for (BookDAO.BookDetail book : books) {
                                        boolean hasReservation = false;
                                        if (currentUserId != null) {
                                            try {
                                                hasReservation = reservationDAO.hasActiveReservation(book.bookId, currentUserId);
                                            } catch (Exception ignored) {}
                                        }
                                %>
                                    <tr>
                                        <td><strong><%= book.title %></strong></td>
                                        <td><%= book.isbn != null ? book.isbn : "N/A" %></td>
                                        <td>
                                            <% if (book.authorNames != null && !book.authorNames.isEmpty()) { %>
                                                <%= String.join(", ", book.authorNames) %>
                                            <% } else { %>
                                                N/A
                                            <% } %>
                                        </td>
                                        <td><%= book.categoryName != null ? book.categoryName : "N/A" %></td>
                                        <td>
                                            <% if (book.availableCopies > 0) { %>
                                                <span class="status-badge status-active"><%= book.availableCopies %> available</span>
                                            <% } else { %>
                                                <span class="status-badge status-locked">Unavailable</span>
                                            <% } %>
                                        </td>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/books/detail?id=<%= book.bookId %>" class="btn-icon-text">
                                                <i class="fa-solid fa-eye"></i> View Details
                                            </a>
                                            <% if (hasReservation) { %>
                                                <span class="text-muted" style="margin-left: 0.5rem;">
                                                    <i class="fa-solid fa-bookmark"></i> Reserved
                                                </span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } 
                                    reservationDAO.close();
                                %>
                            </tbody>
                        </table>
                    </div>
                </section>
            <% } else if (searchTerm != null) { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <p>No books found matching your search.</p>
                </section>
            <% } else { %>
                <section class="card" style="margin-top: 1.5rem;">
                    <p>Enter a search term to find books.</p>
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

