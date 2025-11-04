package controller.home;

import dal.BookDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        BookDAO bookDAO = null;
        try {
            bookDAO = new BookDAO();
            // Get all books and limit to 8 for featured section
            List<BookDAO.BookDetail> allBooks = bookDAO.getAllBooks();
            List<BookDAO.BookDetail> featuredBooks = allBooks.size() > 8
                ? allBooks.subList(0, 8)
                : allBooks;

            request.setAttribute("featuredBooks", featuredBooks);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to load books: " + e.getMessage());
        } finally {
            if (bookDAO != null) {
                bookDAO.close();
            }
        }

        request.getRequestDispatcher("/home.jsp").forward(request, response);
    }
}


