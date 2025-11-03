<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<%@ page import="model.Category" %>
<%@ page import="model.Author" %>
<%@ page import="model.Publisher" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Book Information</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="book-update"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Update Book Information"/>
            <jsp:param name="pageSubtitle" value="Edit book details, status, shelf location"/>
        </jsp:include>

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
                    <form method="get" action="<%= request.getContextPath() %>/book/update" class="auth-form">
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
                                                <a href="<%= request.getContextPath() %>/book/update?id=<%= b.bookId %>" class="btn-icon-text">
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
                        <a href="<%= request.getContextPath() %>/book/update" class="btn-secondary">New Search</a>
                    </div>
                </section>
            <% } else if (book != null) { %>
                <!-- Update Form -->
                <section class="card">
                    <h2 class="form-section-title">Book Details</h2>
                    <p class="page-subtitle" style="margin:0 0 1rem;">Update book information</p>
                    <form method="post" action="<%= request.getContextPath() %>/book/update" class="auth-form" enctype="multipart/form-data" novalidate>
                        <input type="hidden" name="book_id" value="<%= book.bookId %>" />
                        
                        <div class="form-grid two-col">
                            <div class="form-field">
                                <label class="label-muted">Title<span class="req">*</span></label>
                                <div class="input box">
                                    <input type="text" name="title" value="<%= book.title != null ? book.title : "" %>" required />
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("title") != null) { %>
                                    <div class="field-error"><%= e.get("title") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">ISBN</label>
                                <div class="input box">
                                    <input type="text" name="isbn" value="<%= book.isbn != null ? book.isbn : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Category<span class="req">*</span></label>
                                <div class="input box">
                                    <select name="category_id" required>
                                        <option value="">Select category</option>
                                        <% List<Category> categories = (List<Category>) request.getAttribute("categories");
                                           if (categories != null) {
                                               for (Category cat : categories) { %>
                                            <option value="<%= cat.getCategoryId() %>" <%= (book.categoryId != null && book.categoryId == cat.getCategoryId()) ? "selected" : "" %>>
                                                <%= cat.getCategoryName() %>
                                            </option>
                                        <% } } %>
                                    </select>
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("category_id") != null) { %>
                                    <div class="field-error"><%= e.get("category_id") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Publisher<span class="req">*</span></label>
                                <div class="input box">
                                    <select name="publisher_id" required>
                                        <option value="">Select publisher</option>
                                        <% List<Publisher> publishers = (List<Publisher>) request.getAttribute("publishers");
                                           if (publishers != null) {
                                               for (Publisher pub : publishers) { %>
                                            <option value="<%= pub.getPublisherId() %>" <%= (book.publisherId != null && book.publisherId == pub.getPublisherId()) ? "selected" : "" %>>
                                                <%= pub.getPublisherName() %>
                                            </option>
                                        <% } } %>
                                    </select>
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("publisher_id") != null) { %>
                                    <div class="field-error"><%= e.get("publisher_id") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Authors<span class="req">*</span></label>
                                <div class="input box">
                                    <input type="text" name="author_names" placeholder="Enter author names, separated by commas" 
                                           value="<%= (book.authorNames != null && !book.authorNames.isEmpty()) ? String.join(", ", book.authorNames) : "" %>" required />
                                </div>
                                <% if (request.getAttribute("errors") != null) { 
                                    java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                    if (e.get("author_names") != null) { %>
                                    <div class="field-error"><%= e.get("author_names") %></div>
                                <% } } %>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Publication Year</label>
                                <div class="input box">
                                    <input type="number" name="publication_year" min="1000" max="<%= java.util.Calendar.getInstance().get(java.util.Calendar.YEAR) + 1 %>" 
                                           value="<%= book.publicationYear != null ? book.publicationYear : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Edition</label>
                                <div class="input box">
                                    <input type="text" name="edition" value="<%= book.edition != null ? book.edition : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Language</label>
                                <div class="input box">
                                    <input type="text" name="language" value="<%= book.language != null ? book.language : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Pages</label>
                                <div class="input box">
                                    <input type="number" name="pages" min="1" value="<%= book.pages != null ? book.pages : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Shelf Location</label>
                                <div class="input box">
                                    <input type="text" name="shelf_location" value="<%= book.shelfLocation != null ? book.shelfLocation : "" %>" />
                                </div>
                            </div>
                            <div class="form-field">
                                <label class="label-muted">Cover Image</label>
                                <div class="input box">
                                    <input type="file" name="cover_file" accept="image/*" />
                                </div>
                                <% if (book.coverImage != null && !book.coverImage.trim().isEmpty()) { %>
                                <div style="margin-top: .5rem;">
                                    <img src="<%= book.coverImage %>" alt="Current Cover" style="max-width: 180px; height: auto; border-radius: 4px; border: 1px solid #eee;" />
                                </div>
                                <% } %>
                            </div>
                            <div class="form-field" style="grid-column: 1 / -1;">
                                <label class="label-muted">Description</label>
                                <div class="input box">
                                    <textarea name="description" rows="4"><%= book.description != null ? book.description : "" %></textarea>
                                </div>
                            </div>
                            <div class="form-field" style="grid-column: 1 / -1;">
                                <div class="info-row">
                                    <span class="info-label">Total Copies:</span>
                                    <span class="info-value"><%= book.totalCopies %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Available Copies:</span>
                                    <span class="info-value"><%= book.availableCopies %></span>
                                </div>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Update Book</button>
                            <a href="<%= request.getContextPath() %>/book/update" class="btn-secondary">Cancel</a>
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
<script src="<%= request.getContextPath() %>/js/pages/book-update.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

