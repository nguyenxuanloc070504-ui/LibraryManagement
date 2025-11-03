<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Remove Book from System</title>
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
                <a href="<%= request.getContextPath() %>/book/remove" class="nav-item active">
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
                <h1 class="page-title">Remove Book from System</h1>
                <p class="page-subtitle">Delete damaged or obsolete books</p>
            </div>
        </header>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% BookDAO.BookDetail book = (BookDAO.BookDetail) request.getAttribute("book"); %>
            <% List<BookDAO.BookDetail> searchResults = (List<BookDAO.BookDetail>) request.getAttribute("searchResults"); %>

            <% if (book == null && searchResults == null) { %>
                <!-- Search Form -->
                <section class="card">
                    <h2 class="form-section-title">Search Book</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Search by title, ISBN, or author</p>
                    <form method="get" action="<%= request.getContextPath() %>/book/remove" class="auth-form">
                        <div class="form-field">
                            <label class="label-muted">Search</label>
                            <div class="input box">
                                <input type="text" name="search" placeholder="Enter title, ISBN, or author name" 
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
                        <p>No books found.</p>
                    <% } else { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>ISBN</th>
                                        <th>Category</th>
                                        <th>Publisher</th>
                                        <th>Year</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (BookDAO.BookDetail b : searchResults) { %>
                                        <tr>
                                            <td><%= b.title %></td>
                                            <td><%= b.isbn != null ? b.isbn : "N/A" %></td>
                                            <td><%= b.categoryName != null ? b.categoryName : "N/A" %></td>
                                            <td><%= b.publisherName != null ? b.publisherName : "N/A" %></td>
                                            <td><%= b.publicationYear != null ? b.publicationYear : "N/A" %></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/book/remove?id=<%= b.bookId %>" class="btn-icon-text" style="background: var(--color-error);">
                                                    <i class="fa-solid fa-trash"></i> Remove
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                    <div class="form-actions" style="margin-top:1rem;">
                        <a href="<%= request.getContextPath() %>/book/remove" class="btn-secondary">New Search</a>
                    </div>
                </section>
            <% } else if (book != null) { %>
                <!-- Remove Confirmation -->
                <section class="card">
                    <h2 class="form-section-title">Confirm Removal</h2>
                    <div class="alert-error" style="margin-bottom: 1rem;">
                        <strong>Warning:</strong> This action cannot be undone. The book and all its copies will be permanently deleted.
                    </div>
                    
                    <div class="member-info-card">
                        <div class="info-row">
                            <span class="info-label">Title:</span>
                            <span class="info-value"><%= book.title %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">ISBN:</span>
                            <span class="info-value"><%= book.isbn != null ? book.isbn : "N/A" %></span>
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
                            <span class="info-label">Total Copies:</span>
                            <span class="info-value"><%= book.totalCopies %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Available Copies:</span>
                            <span class="info-value"><%= book.availableCopies %></span>
                        </div>
                        <% if (book.totalCopies > book.availableCopies) { %>
                            <div class="info-row">
                                <span class="info-label">Status:</span>
                                <span class="status-badge status-locked">Has Active Borrowings</span>
                            </div>
                        <% } %>
                    </div>
                    
                    <form method="post" action="<%= request.getContextPath() %>/book/remove" class="auth-form" novalidate style="margin-top:1.5rem;">
                        <input type="hidden" name="book_id" value="<%= book.bookId %>" />
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto; background: var(--color-error);">
                                <i class="fa-solid fa-trash"></i> Confirm Removal
                            </button>
                            <a href="<%= request.getContextPath() %>/book/remove" class="btn-secondary">Cancel</a>
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
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

