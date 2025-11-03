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
    <title>Add New Book</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="book-add"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Add New Book"/>
            <jsp:param name="pageSubtitle" value="Enter new book information, ISBN, author, publisher, quantity"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <section class="card">
                <h2 class="form-section-title">Book Information</h2>
                <form method="post" action="<%= request.getContextPath() %>/book/add" class="auth-form" enctype="multipart/form-data" novalidate>
                    <div class="form-grid two-col">
                        <div class="form-field">
                            <label class="label-muted">Title<span class="req">*</span></label>
                            <div class="input box">
                                <input type="text" name="title" value="<%= request.getParameter("title") != null ? request.getParameter("title") : "" %>" required />
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
                                <input type="text" name="isbn" value="<%= request.getParameter("isbn") != null ? request.getParameter("isbn") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Category<span class="req">*</span></label>
                            <div class="input box">
                                <select name="category_id" required>
                                    <option value="">Select category</option>
                                    <% List<Category> categories = (List<Category>) request.getAttribute("categories");
                                       if (categories != null) {
                                           String sel = request.getParameter("category_id");
                                           for (Category cat : categories) { %>
                                        <option value="<%= cat.getCategoryId() %>" <%= (sel != null && sel.equals(String.valueOf(cat.getCategoryId()))) ? "selected" : "" %>>
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
                                           String sel = request.getParameter("publisher_id");
                                           for (Publisher pub : publishers) { %>
                                        <option value="<%= pub.getPublisherId() %>" <%= (sel != null && sel.equals(String.valueOf(pub.getPublisherId()))) ? "selected" : "" %>>
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
                                <input type="text" name="author_names" placeholder="Enter author names, separated by commas" value="<%= request.getParameter("author_names") != null ? request.getParameter("author_names") : "" %>" required />
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
                                       value="<%= request.getParameter("publication_year") != null ? request.getParameter("publication_year") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Edition</label>
                            <div class="input box">
                                <input type="text" name="edition" value="<%= request.getParameter("edition") != null ? request.getParameter("edition") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Language</label>
                            <div class="input box">
                                <input type="text" name="language" value="<%= request.getParameter("language") != null ? request.getParameter("language") : "English" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Pages</label>
                            <div class="input box">
                                <input type="number" name="pages" min="1" value="<%= request.getParameter("pages") != null ? request.getParameter("pages") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Shelf Location</label>
                            <div class="input box">
                                <input type="text" name="shelf_location" value="<%= request.getParameter("shelf_location") != null ? request.getParameter("shelf_location") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Cover Image</label>
                            <div class="input box">
                                <input type="file" name="cover_file" accept="image/*" />
                            </div>
                        </div>
                        <div class="form-field" style="grid-column: 1 / -1;">
                            <label class="label-muted">Description</label>
                            <div class="input box">
                                <textarea name="description" rows="4"><%= request.getParameter("description") != null ? request.getParameter("description") : "" %></textarea>
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Quantity<span class="req">*</span></label>
                            <div class="input box">
                                <input type="number" name="quantity" min="1" value="<%= request.getParameter("quantity") != null ? request.getParameter("quantity") : "1" %>" required />
                            </div>
                            <% if (request.getAttribute("errors") != null) { 
                                java.util.Map e = (java.util.Map)request.getAttribute("errors"); 
                                if (e.get("quantity") != null) { %>
                                <div class="field-error"><%= e.get("quantity") %></div>
                            <% } } %>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Acquisition Date</label>
                            <div class="input box">
                                <input type="date" name="acquisition_date" value="<%= request.getParameter("acquisition_date") != null ? request.getParameter("acquisition_date") : "" %>" />
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Condition Status</label>
                            <div class="input box">
                                <select name="condition_status">
                                    <option value="excellent" selected>Excellent</option>
                                    <option value="good">Good</option>
                                    <option value="fair">Fair</option>
                                    <option value="poor">Poor</option>
                                    <option value="damaged">Damaged</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-field">
                            <label class="label-muted">Price</label>
                            <div class="input box">
                                <input type="number" name="price" min="0" step="0.01" value="<%= request.getParameter("price") != null ? request.getParameter("price") : "" %>" />
                            </div>
                        </div>
                    </div>
                    <div class="form-actions">
                        <button class="btn-primary" type="submit" style="width:auto;">Add Book</button>
                        <a href="<%= request.getContextPath() %>/book/add" class="btn-secondary">Reset</a>
                    </div>
                </form>
            </section>
        </div>
    </main>
</div>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/pages/book-add.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

