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
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "BookListServlet", urlPatterns = {"/book/list"})
public class BookListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String search = request.getParameter("search");
        String categoryIdParam = request.getParameter("category");
        String authorParam = request.getParameter("author");

        BookDAO bookDAO = new BookDAO();
        ReservationDAO reservationDAO = new ReservationDAO();

        try {
            request.setAttribute("categories", bookDAO.getAllCategories());

            Integer userId = (Integer) request.getSession().getAttribute("authUserId");

            if (search != null && !search.trim().isEmpty()) {
                List<BookDAO.BookDetail> results = bookDAO.searchBooks(search.trim());

                if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
                    try {
                        int categoryId = Integer.parseInt(categoryIdParam);
                        List<BookDAO.BookDetail> filtered = new ArrayList<>();
                        for (BookDAO.BookDetail b : results) {
                            if (b.categoryId != null && b.categoryId == categoryId) {
                                filtered.add(b);
                            }
                        }
                        results = filtered;
                    } catch (NumberFormatException ignored) {}
                }

                if (userId != null) {
                    for (BookDAO.BookDetail book : results) {
                        try {
                            if (reservationDAO.hasActiveReservation(book.bookId, userId)) {
                                // reserved flag can be checked in JSP if needed
                            }
                        } catch (SQLException ignored) {}
                    }
                }

                request.setAttribute("books", results);
                request.setAttribute("searchTerm", search.trim());
            } else {
                List<BookDAO.BookDetail> results = bookDAO.getAllBooks();
                request.setAttribute("books", results);
                request.setAttribute("searchTerm", null);
            }

            request.setAttribute("currentUserId", userId);
            request.setAttribute("selectedCategory", categoryIdParam);
            request.setAttribute("selectedAuthor", authorParam);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            bookDAO.close();
            reservationDAO.close();
        }

        request.getRequestDispatcher("/bookMgt/book-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String search = request.getParameter("search");
        String categoryIdParam = request.getParameter("category");
        String authorParam = request.getParameter("author");

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/book/list?");
        if (search != null && !search.trim().isEmpty()) {
            redirectUrl.append("search=").append(java.net.URLEncoder.encode(search.trim(), "UTF-8"));
        }
        if (categoryIdParam != null && !categoryIdParam.trim().isEmpty()) {
            if (redirectUrl.toString().contains("=")) redirectUrl.append("&");
            redirectUrl.append("category=").append(categoryIdParam);
        }
        if (authorParam != null && !authorParam.trim().isEmpty()) {
            if (redirectUrl.toString().contains("=")) redirectUrl.append("&");
            redirectUrl.append("author=").append(java.net.URLEncoder.encode(authorParam, "UTF-8"));
        }

        response.sendRedirect(redirectUrl.toString());
    }
}


