<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<%@ page import="dal.ReservationDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<%
    // Get user role from session
    String userRole = (String) session.getAttribute("authRole");
    boolean isMember = "Member".equalsIgnoreCase(userRole);
    boolean isLibrarian = "Librarian".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Books</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <% if (isMember) { %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pages/home.css">
    <% } %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="<%= isMember ? "home-page" : "" %>">
<div class="<%= isMember ? "" : "layout" %>">
    <% if (isLibrarian) { %>
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="book-list"/>
    </jsp:include>
    <% } %>

    <main class="<%= isMember ? "" : "content" %>">
        <% if (isMember) { %>
        <jsp:include page="/components/header-member.jsp">
            <jsp:param name="activeTab" value="books"/>
        </jsp:include>
        <% } else { %>
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Book List"/>
            <jsp:param name="pageSubtitle" value="Browse all books in the library"/>
        </jsp:include>
        <% } %>

        <div class="<%= isMember ? "container" : "main-content" %>" style="<%= isMember ? "padding-top: 2rem; padding-bottom: 2rem;" : "" %>">
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <!-- Search and Filter Form -->
            <section class="card">
                <h2 class="form-section-title">Search & Filter</h2>
                <form id="searchForm" method="get" action="<%= request.getContextPath() %>/book/list" class="auth-form">
                    <div class="form-grid search-layout">
                        <div class="form-field inline">
                            <label class="label-muted">Search</label>
                            <div class="input box">
                                <input type="text" name="search" placeholder="Title, ISBN, or Author"
                                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field inline">
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
                        <div class="form-field inline">
                            <label class="label-muted label-hidden">.</label>
                            <button class="btn-primary inline-btn" type="submit">
                                <i class="fa-solid fa-search"></i> Search
                            </button>
                        </div>
                        <div class="form-field inline">
                            <label class="label-muted label-hidden">.</label>
                            <a href="<%= request.getContextPath() %>/books" class="btn-secondary inline-btn no-underline">
                                Clear
                            </a>
                        </div>
                    </div>
                </form>
            </section>

            <!-- Books Card Grid -->
            <% List<BookDAO.BookDetail> books = (List<BookDAO.BookDetail>) request.getAttribute("books"); %>
            <% String searchTerm = (String) request.getAttribute("searchTerm"); %>
            
            <section class="card" style="margin-top: 1.5rem;">
                <h2 class="form-section-title">
                    <%= (searchTerm != null && !searchTerm.isEmpty()) ? ("Search Results for \"" + searchTerm + "\"") : "All Books" %>
                    <% if (books != null) { %>(<%= books.size() %> books)<% } %>
                </h2>
                <% if (books != null && !books.isEmpty()) { %>
                    <div class="grid" style="display:grid;grid-template-columns:repeat(3,1fr);gap:16px;">
                        <% for (BookDAO.BookDetail book : books) { %>
                            <div class="card" style="padding:0;overflow:hidden;display:flex;flex-direction:column;">
                                <div style="aspect-ratio:3/4;background:#f5f5f5;display:flex;align-items:center;justify-content:center;overflow:hidden;">
                                    <% if (book.coverImage != null && !book.coverImage.trim().isEmpty()) { %>
                                        <img src="<%= book.coverImage %>" alt="<%= book.title %>" style="width:100%;height:100%;object-fit:cover;" />
                                    <% } else { %>
                                        <i class="fa-solid fa-book" style="font-size:48px;color:#bbb;"></i>
                                    <% } %>
                                </div>
                                <div style="padding:12px 14px;display:flex;flex-direction:column;gap:6px;">
                                    <a href="<%= request.getContextPath() %>/books/detail?id=<%= book.bookId %>"
                                       style="font-weight:600;line-height:1.3;min-height:2.6em;color:inherit;text-decoration:none;cursor:pointer;"
                                       onmouseover="this.style.color='#2563eb'"
                                       onmouseout="this.style.color='inherit'">
                                        <%= book.title %>
                                    </a>
                                    <div class="text-muted" style="font-size:0.9rem;">
                                        <%= book.categoryName != null ? book.categoryName : "Unknown Category" %>
                                    </div>
                                    <div style="margin-top:4px;">
                                        <% if (book.availableCopies > 0) { %>
                                            <span class="status-badge status-active"><%= book.availableCopies %> available</span>
                                        <% } else { %>
                                            <span class="status-badge status-locked">Unavailable</span>
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <p>No books found.</p>
                <% } %>
            </section>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

