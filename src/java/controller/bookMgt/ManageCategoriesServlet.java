package controller.bookMgt;

import dal.BookDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ManageCategoriesServlet", urlPatterns = {"/book/categories"})
public class ManageCategoriesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String categoryIdParam = request.getParameter("id");
        
        BookDAO dao = new BookDAO();
        try {
            if ("delete".equals(action) && categoryIdParam != null) {
                // Handle delete via GET (with confirmation)
                int categoryId = Integer.parseInt(categoryIdParam);
                boolean success = dao.deleteCategory(categoryId);
                if (success) {
                    request.setAttribute("success", "Category deleted successfully.");
                } else {
                    request.setAttribute("error", "Cannot delete category: It is used by books or has child categories.");
                }
            }
            request.setAttribute("categories", dao.getAllCategories());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                request.setAttribute("categories", dao.getAllCategories());
            } catch (SQLException ignored) {}
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid category ID.");
            try {
                request.setAttribute("categories", dao.getAllCategories());
            } catch (SQLException ignored) {}
        } finally {
            dao.close();
        }
        request.getRequestDispatcher("/bookMgt/book-categories.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        BookDAO dao = new BookDAO();

        try {
            if ("add".equals(action)) {
                String categoryName = request.getParameter("category_name");
                String description = request.getParameter("description");
                String parentCategoryIdParam = request.getParameter("parent_category_id");

                if (categoryName == null || categoryName.trim().isEmpty()) {
                    request.setAttribute("error", "Category name is required.");
                } else {
                    Integer parentCategoryId = null;
                    if (parentCategoryIdParam != null && !parentCategoryIdParam.trim().isEmpty() && !parentCategoryIdParam.equals("0")) {
                        parentCategoryId = Integer.parseInt(parentCategoryIdParam);
                    }
                    
                    int newCategoryId = dao.addCategory(categoryName.trim(), 
                            description != null ? description.trim() : null, parentCategoryId);
                    if (newCategoryId > 0) {
                        request.setAttribute("success", "Category added successfully.");
                    } else {
                        request.setAttribute("error", "Failed to add category.");
                    }
                }
            } else if ("update".equals(action)) {
                String categoryIdParam = request.getParameter("category_id");
                String categoryName = request.getParameter("category_name");
                String description = request.getParameter("description");
                String parentCategoryIdParam = request.getParameter("parent_category_id");

                if (categoryIdParam == null || categoryIdParam.trim().isEmpty()) {
                    request.setAttribute("error", "Category ID is required.");
                } else if (categoryName == null || categoryName.trim().isEmpty()) {
                    request.setAttribute("error", "Category name is required.");
                } else {
                    int categoryId = Integer.parseInt(categoryIdParam);
                    Integer parentCategoryId = null;
                    if (parentCategoryIdParam != null && !parentCategoryIdParam.trim().isEmpty() && !parentCategoryIdParam.equals("0")) {
                        parentCategoryId = Integer.parseInt(parentCategoryIdParam);
                    }
                    
                    boolean success = dao.updateCategory(categoryId, categoryName.trim(),
                            description != null ? description.trim() : null, parentCategoryId);
                    if (success) {
                        request.setAttribute("success", "Category updated successfully.");
                    } else {
                        request.setAttribute("error", "Failed to update category.");
                    }
                }
            }
            
            request.setAttribute("categories", dao.getAllCategories());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                request.setAttribute("categories", dao.getAllCategories());
            } catch (SQLException ignored) {}
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format.");
            try {
                request.setAttribute("categories", dao.getAllCategories());
            } catch (SQLException ignored) {}
        } finally {
            dao.close();
        }
        
        request.getRequestDispatcher("/bookMgt/book-categories.jsp").forward(request, response);
    }
}

