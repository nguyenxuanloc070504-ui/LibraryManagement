package controller.reports;

import dal.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "OverdueBooksServlet", urlPatterns = {"/reports/overdue-books"})
public class OverdueBooksServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to view overdue books.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        ReportDAO dao = new ReportDAO();
        try {
            // Mark overdue books first
            dao.markOverdueBooks();
            
            // Get overdue books
            request.setAttribute("overdueBooks", dao.getOverdueBooks());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        request.getRequestDispatcher("/reports/overdue-books.jsp").forward(request, response);
    }
}

