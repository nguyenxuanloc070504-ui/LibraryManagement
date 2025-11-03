package controller.personal;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "RequestRenewalServlet", urlPatterns = {"/personal/request-renewal"})
public class RequestRenewalServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.getSession().setAttribute("error", "Please login to request renewals.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String transactionIdParam = request.getParameter("transaction_id");
        if (transactionIdParam == null || transactionIdParam.trim().isEmpty()) {
            request.getSession().setAttribute("error", "Transaction ID is required.");
            response.sendRedirect(request.getContextPath() + "/personal/current-borrowings");
            return;
        }

        int transactionId;
        try {
            transactionId = Integer.parseInt(transactionIdParam);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid transaction ID.");
            response.sendRedirect(request.getContextPath() + "/personal/current-borrowings");
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            TransactionDAO.CreateRenewalRequestResult result = dao.createRenewalRequest(transactionId, userId);
            if (result.success) {
                request.getSession().setAttribute("success", result.message);
            } else {
                request.getSession().setAttribute("error", result.message);
            }
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        response.sendRedirect(request.getContextPath() + "/personal/current-borrowings");
    }
}

