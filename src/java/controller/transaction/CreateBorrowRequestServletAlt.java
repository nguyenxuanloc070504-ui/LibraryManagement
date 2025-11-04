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

/**
 * Alternative implementation that doesn't use stored procedure
 * Use this by changing the URL mapping if the stored procedure version has issues
 * Change @WebServlet urlPatterns to "/transaction/request" to use this version
 */
@WebServlet(name = "CreateBorrowRequestServletAlt", urlPatterns = {"/transaction/request-alt"})
public class CreateBorrowRequestServletAlt extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("authUserId") : null;
        String role = (session != null) ? (String) session.getAttribute("authRole") : null;

        String bookIdStr = request.getParameter("book_id");
        Integer bookId = null;
        try {
            bookId = Integer.parseInt(bookIdStr);
        } catch (Exception ignored) {}

        if (userId == null || bookId == null) {
            session.setAttribute("error", "You must be logged in and choose a book.");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        if (role != null && "Librarian".equalsIgnoreCase(role)) {
            session.setAttribute("error", "Librarians cannot create borrow requests as readers.");
            response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
            return;
        }

        BorrowRequestDAO dao = new BorrowRequestDAO();
        try {
            BorrowRequestDAO.CreateRequestResult result = dao.createBorrowRequest(bookId, userId);

            if (result.success) {
                session.setAttribute("success", result.message);
            } else {
                session.setAttribute("error", result.message);
            }
        } catch (SQLException e) {
            session.setAttribute("error", "Database error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            dao.close();
        }

        response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
    }
}
