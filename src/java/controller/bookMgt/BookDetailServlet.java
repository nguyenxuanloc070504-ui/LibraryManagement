package controller.bookMgt;

import dal.BookDAO;
import dal.BorrowRequestDAO;
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
        BorrowRequestDAO borrowRequestDAO = new BorrowRequestDAO();

        try {
            BookDAO.BookDetail book = bookDAO.findBookById(bookId);
            if (book == null) {
                request.setAttribute("error", "Book not found.");
                response.sendRedirect(request.getContextPath() + "/books");
                return;
            }

            request.setAttribute("book", book);

            // Check if user has active reservation or borrow request
            Integer userId = (Integer) request.getSession().getAttribute("authUserId");
            if (userId != null) {
                // Reservations feature removed; always false
                request.setAttribute("hasReservation", false);

                // Check for pending borrow request
                BorrowRequestDAO.BorrowRequestDetail borrowRequest = borrowRequestDAO.getPendingRequest(bookId, userId);
                request.setAttribute("borrowRequest", borrowRequest);
            } else {
                request.setAttribute("hasReservation", false);
                request.setAttribute("borrowRequest", null);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            bookDAO.close();
            borrowRequestDAO.close();
        }

        request.getRequestDispatcher("/bookMgt/book-detail.jsp").forward(request, response);
    }
}

