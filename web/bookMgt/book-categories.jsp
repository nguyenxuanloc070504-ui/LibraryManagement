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
                <a href="<%= request.getContextPath() %>/book/remove" class="nav-item">
                    <i class="fa-solid fa-trash-can"></i>
                    <span>Remove Book</span>
                </a>
                <a href="<%= request.getContextPath() %>/book/categories" class="nav-item active">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Manage Categories</span>
                </a>
            </div>
        </nav>
    </aside>

    <main class="content">
        <header class="content-header">
            <div>
                <h1 class="page-title">Manage Book Categories</h1>
                <p class="page-subtitle">Classify books by genre, author, publication year</p>
            </div>
        </header>

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
                            <button class="btn-primary" type="submit" style="width:auto;" id="submit-btn">Add Category</button>
                            <button class="btn-secondary" type="button" id="cancel-edit-btn" style="display:none;">Cancel Edit</button>
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
                                        <tr>
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
                                                <button type="button" class="btn-icon-text" onclick="editCategory(<%= cat.getCategoryId() %>, '<%= cat.getCategoryName().replace("'", "\\'") %>', <%= cat.getParentCategoryId() != null ? cat.getParentCategoryId() : 0 %>, '<%= cat.getDescription() != null ? cat.getDescription().replace("'", "\\'") : "" %>')" style="margin-right:0.5rem;">
                                                    <i class="fa-solid fa-edit"></i> Edit
                                                </button>
                                                <a href="<%= request.getContextPath() %>/book/categories?action=delete&id=<%= cat.getCategoryId() %>" 
                                                   class="btn-icon-text" style="background: var(--color-error);"
                                                   onclick="return confirm('Are you sure you want to delete this category?');">
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

