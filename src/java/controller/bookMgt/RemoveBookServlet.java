package controller.bookMgt;

import dal.BookDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "RemoveBookServlet", urlPatterns = {"/book/remove"})
public class RemoveBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookIdParam = request.getParameter("id");
        String searchTerm = request.getParameter("search");
        
        BookDAO dao = new BookDAO();
        try {
            if (bookIdParam != null && !bookIdParam.trim().isEmpty()) {
                // Show remove confirmation for specific book
                int bookId = Integer.parseInt(bookIdParam);
                BookDAO.BookDetail book = dao.findBookById(bookId);
                if (book != null) {
                    request.setAttribute("book", book);
                    request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Book not found.");
                    request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
                }
            } else if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Search for books
                request.setAttribute("searchResults", dao.searchBooks(searchTerm));
                request.setAttribute("searchTerm", searchTerm);
                request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
            } else {
                // Show search page
                request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid book ID.");
            request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String bookIdParam = request.getParameter("book_id");
        if (bookIdParam == null || bookIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Book ID is required.");
            request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid book ID.");
            request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
            return;
        }

        BookDAO dao = new BookDAO();
        try {
            BookDAO.BookDetail bookBefore = dao.findBookById(bookId);
            if (bookBefore == null) {
                request.setAttribute("error", "Book not found.");
                request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
                return;
            }

            boolean success = dao.removeBook(bookId);
            if (success) {
                request.setAttribute("success", "Book removed successfully.");
            } else {
                request.setAttribute("error", "Cannot remove book: It has active borrowings or is currently borrowed.");
                request.setAttribute("book", bookBefore);
            }
            request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                BookDAO.BookDetail book = dao.findBookById(bookId);
                if (book != null) {
                    request.setAttribute("book", book);
                }
            } catch (SQLException ignored) {}
            request.getRequestDispatcher("/bookMgt/book-remove.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }
}

