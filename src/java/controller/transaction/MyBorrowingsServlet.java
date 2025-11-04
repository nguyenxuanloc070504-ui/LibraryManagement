package controller.transaction;

import dal.TransactionDAO;
import dal.BorrowRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "MyBorrowingsServlet", urlPatterns = {"/transaction/my-borrowings"})
public class MyBorrowingsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("authUserId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/authentication/login.jsp");
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        BorrowRequestDAO requestDAO = new BorrowRequestDAO();
        try {
            List<TransactionDAO.BorrowingDetail> current = dao.getUserCurrentBorrowings(userId);
            List<TransactionDAO.BorrowingDetail> history = dao.getUserBorrowingHistory(userId);
            List<TransactionDAO.RenewalRequestDetail> renewals = dao.getUserRenewalRequests(userId);
            List<BorrowRequestDAO.UserBorrowRequest> borrowRequests = requestDAO.getUserBorrowRequests(userId);

            request.setAttribute("currentBorrowings", current);
            request.setAttribute("borrowingHistory", history);
            request.setAttribute("renewalRequests", renewals);
            request.setAttribute("borrowRequests", borrowRequests);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
            requestDAO.close();
        }

        request.getRequestDispatcher("/transaction/my-borrowings.jsp").forward(request, response);
    }
}


