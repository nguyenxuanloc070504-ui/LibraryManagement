package controller.bookMgt;

import dal.BookDAO;
import dal.ReservationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "BookDetailServlet", urlPatterns = {"/books/detail"})
public class BookDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookIdParam = request.getParameter("id");
        
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

        BookDAO bookDAO = new BookDAO();
        ReservationDAO reservationDAO = new ReservationDAO();
        
        try {
            BookDAO.BookDetail book = bookDAO.findBookById(bookId);
            if (book == null) {
                request.setAttribute("error", "Book not found.");
                response.sendRedirect(request.getContextPath() + "/books");
                return;
            }
            
            request.setAttribute("book", book);
            
            // Check if user has active reservation
            Integer userId = (Integer) request.getSession().getAttribute("authUserId");
            if (userId != null) {
                boolean hasReservation = reservationDAO.hasActiveReservation(bookId, userId);
                request.setAttribute("hasReservation", hasReservation);
            } else {
                request.setAttribute("hasReservation", false);
            }
            
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            bookDAO.close();
            reservationDAO.close();
        }
        
        request.getRequestDispatcher("/bookMgt/book-detail.jsp").forward(request, response);
    }
}

