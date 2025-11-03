<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<%@ page import="model.Category" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Book Categories</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="book-categories"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Manage Book Categories"/>
            <jsp:param name="pageSubtitle" value="Classify books by genre, author, publication year"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                <!-- Add/Edit Category Form -->
                <section class="card">
                    <h2 class="form-section-title">Add/Edit Category</h2>
                    <form method="post" action="<%= request.getContextPath() %>/book/categories" class="auth-form" novalidate>
                        <input type="hidden" name="action" id="form-action" value="add" />
                        <input type="hidden" name="category_id" id="edit-category-id" value="" />
                        
                        <div class="form-field">
                            <label class="label-muted">Category Name<span class="req">*</span></label>
                            <div class="input box">
                                <input type="text" name="category_name" id="category-name" required />
                            </div>
                        </div>
                        
                        <div class="form-field">
                            <label class="label-muted">Parent Category</label>
                            <div class="input box">
                                <select name="parent_category_id" id="parent-category-id">
                                    <option value="0">None (Top-level)</option>
                                    <% List<Category> categories = (List<Category>) request.getAttribute("categories");
                                       if (categories != null) {
                                           for (Category cat : categories) { %>
                                        <option value="<%= cat.getCategoryId() %>"><%= cat.getCategoryName() %></option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-field">
                            <label class="label-muted">Description</label>
                            <div class="input box">
                                <textarea name="description" id="category-description" rows="4"></textarea>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn-primary inline-btn" type="submit" id="submit-btn">Add Category</button>
                            <button class="btn-secondary inline-btn" type="button" id="cancel-edit-btn" style="display:none;">Cancel Edit</button>
                        </div>
                    </form>
                </section>

                <!-- Categories List -->
                <section class="card">
                    <h2 class="form-section-title">Existing Categories</h2>
                    <% if (categories == null || categories.isEmpty()) { %>
                        <p>No categories found.</p>
                    <% } else { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Name</th>
                                        <th>Parent</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Category cat : categories) { %>
                                        <tr data-id="<%= cat.getCategoryId() %>" data-name="<%= cat.getCategoryName() != null ? cat.getCategoryName().replace("&", "&amp;").replace("\"", "&quot;") : "" %>" data-parent-id="<%= cat.getParentCategoryId() != null ? cat.getParentCategoryId() : 0 %>" data-description="<%= cat.getDescription() != null ? cat.getDescription().replace("&", "&amp;").replace("\"", "&quot;") : "" %>">
                                            <td><strong><%= cat.getCategoryName() %></strong></td>
                                            <td>
                                                <% 
                                                    String parentName = "None";
                                                    if (cat.getParentCategoryId() != null) {
                                                        for (Category p : categories) {
                                                            if (p.getCategoryId() == cat.getParentCategoryId()) {
                                                                parentName = p.getCategoryName();
                                                                break;
                                                            }
                                                        }
                                                    }
                                                %>
                                                <%= parentName %>
                                            </td>
                                            <td>
                                                <button type="button" class="btn-icon-text" onclick="editCategoryFromRow(this)" style="margin-right:0.5rem;">
                                                    <i class="fa-solid fa-edit"></i> Edit
                                                </button>
                                                <a href="<%= request.getContextPath() %>/book/categories?action=delete&id=<%= cat.getCategoryId() %>" 
                                                   class="btn-icon-text danger" data-confirm data-method="get" data-confirm-message="Are you sure you want to delete this category?">
                                                    <i class="fa-solid fa-trash"></i> Delete
                                                </a>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </section>
            </div>
        </div>
    </main>
</div>
<script>
function editCategoryFromRow(btn) {
    var tr = btn.closest('tr');
    if (!tr) return;
    var id = parseInt(tr.getAttribute('data-id')) || 0;
    var name = tr.getAttribute('data-name') || '';
    var parentId = parseInt(tr.getAttribute('data-parent-id')) || 0;
    var description = tr.getAttribute('data-description') || '';
    editCategory(id, name, parentId, description);
}
function editCategory(id, name, parentId, description) {
    document.getElementById('form-action').value = 'update';
    document.getElementById('edit-category-id').value = id;
    document.getElementById('category-name').value = name;
    document.getElementById('parent-category-id').value = parentId || 0;
    document.getElementById('category-description').value = description || '';
    document.getElementById('submit-btn').textContent = 'Update Category';
    document.getElementById('cancel-edit-btn').style.display = 'inline-block';
    document.getElementById('category-name').focus();
}

document.getElementById('cancel-edit-btn').addEventListener('click', function() {
    document.getElementById('form-action').value = 'add';
    document.getElementById('edit-category-id').value = '';
    document.getElementById('category-name').value = '';
    document.getElementById('parent-category-id').value = '0';
    document.getElementById('category-description').value = '';
    document.getElementById('submit-btn').textContent = 'Add Category';
    document.getElementById('cancel-edit-btn').style.display = 'none';
});
</script>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

