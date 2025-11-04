package controller.transaction;

import dal.BorrowRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CancelBorrowRequestServlet", urlPatterns = {"/transaction/cancel-request"})
public class CancelBorrowRequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("authUserId") : null;

        String requestIdStr = request.getParameter("request_id");
        String bookIdStr = request.getParameter("book_id");

        Integer requestId = null;
        Integer bookId = null;

        try {
            requestId = Integer.parseInt(requestIdStr);
            bookId = Integer.parseInt(bookIdStr);
        } catch (Exception ignored) {}

        if (userId == null || requestId == null || bookId == null) {
            session.setAttribute("error", "Invalid request parameters.");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        BorrowRequestDAO dao = new BorrowRequestDAO();
        try {
            BorrowRequestDAO.CancelResult result = dao.cancelRequest(requestId, userId);

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

        response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
    }
}
