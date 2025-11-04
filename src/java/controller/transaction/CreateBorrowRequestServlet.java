package controller.transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

import dal.DBContext;

@WebServlet(name = "CreateBorrowRequestServlet", urlPatterns = {"/transaction/request"})
public class CreateBorrowRequestServlet extends HttpServlet {

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

        DBContext db = new DBContext() {};
        try (Connection conn = db.getConnection()) {
            String sql = "{CALL sp_create_borrow_request(?, ?, ?, ?)}";
            try (CallableStatement cs = conn.prepareCall(sql)) {
                cs.setInt(1, userId);
                cs.setInt(2, bookId);
                cs.registerOutParameter(3, Types.VARCHAR);
                cs.registerOutParameter(4, Types.INTEGER);

                cs.execute();

                String result = cs.getString(3);
                Integer requestId = cs.getInt(4);
                if (cs.wasNull()) requestId = null;

                if (result != null && result.startsWith("Success")) {
                    session.setAttribute("success", result);
                } else {
                    session.setAttribute("error", result != null ? result : "Request failed");
                }
            }
        } catch (SQLException e) {
            session.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
    }
}


