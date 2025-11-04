package controller.transaction;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CreateRenewalRequestServlet", urlPatterns = {"/transaction/create-renewal-request"})
public class CreateRenewalRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer userId = (Integer) session.getAttribute("authUserId");
        String transactionIdParam = request.getParameter("transaction_id");

        if (transactionIdParam == null || transactionIdParam.trim().isEmpty()) {
            session.setAttribute("error", "Transaction ID is required.");
            response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
            return;
        }

        int transactionId;
        try {
            transactionId = Integer.parseInt(transactionIdParam);
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Invalid transaction ID.");
            response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            TransactionDAO.CreateRenewalRequestResult result =
                dao.createRenewalRequest(transactionId, userId);

            if (result.success) {
                session.setAttribute("success", result.message);
            } else {
                session.setAttribute("error", result.message);
            }
        } catch (SQLException e) {
            session.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
    }
}
