package controller.reservation;

import dal.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CancelReservationServlet", urlPatterns = {"/books/cancel-reservation"})
public class CancelReservationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to cancel reservations.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String reservationIdParam = request.getParameter("reservation_id");
        if (reservationIdParam == null || reservationIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Reservation ID is required.");
            response.sendRedirect(request.getContextPath() + "/books/my-reservations");
            return;
        }

        int reservationId;
        try {
            reservationId = Integer.parseInt(reservationIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid reservation ID.");
            response.sendRedirect(request.getContextPath() + "/books/my-reservations");
            return;
        }

        ReservationDAO dao = new ReservationDAO();
        try {
            boolean success = dao.cancelReservation(reservationId, userId);
            if (success) {
                request.getSession().setAttribute("success", "Reservation cancelled successfully.");
            } else {
                request.getSession().setAttribute("error", "Failed to cancel reservation. It may not exist or already be processed.");
            }
            response.sendRedirect(request.getContextPath() + "/books/my-reservations");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/books/my-reservations");
        } finally {
            dao.close();
        }
    }
}

