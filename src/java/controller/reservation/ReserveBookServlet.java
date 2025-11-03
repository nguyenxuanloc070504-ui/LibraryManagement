package controller.reservation;

import dal.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ReserveBookServlet", urlPatterns = {"/books/reserve"})
public class ReserveBookServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to reserve books.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String bookIdParam = request.getParameter("book_id");
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Book ID is required.");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid book ID.");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        ReservationDAO dao = new ReservationDAO();
        try {
            ReservationDAO.CreateReservationResult result = dao.createReservation(bookId, userId);
            if (result.success) {
                request.getSession().setAttribute("success", result.message);
                response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
            } else {
                request.getSession().setAttribute("error", result.message);
                response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
            }
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
        } finally {
            dao.close();
        }
    }
}

