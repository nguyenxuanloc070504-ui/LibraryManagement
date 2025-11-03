package controller.reservation;

import dal.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "MyReservationsServlet", urlPatterns = {"/books/my-reservations"})
public class MyReservationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to view your reservations.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        ReservationDAO dao = new ReservationDAO();
        try {
            request.setAttribute("reservations", dao.getUserReservations(userId));
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        request.getRequestDispatcher("/reservation/my-reservations.jsp").forward(request, response);
    }
}

