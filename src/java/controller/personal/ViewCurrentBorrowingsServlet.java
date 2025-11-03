package controller.personal;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ViewCurrentBorrowingsServlet", urlPatterns = {"/personal/current-borrowings"})
public class ViewCurrentBorrowingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to view your current borrowings.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            request.setAttribute("borrowings", dao.getUserCurrentBorrowings(userId));
            request.setAttribute("renewalRequests", dao.getUserRenewalRequests(userId));
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        request.getRequestDispatcher("/personal/current-borrowings.jsp").forward(request, response);
    }
}

