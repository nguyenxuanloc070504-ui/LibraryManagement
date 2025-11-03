package controller.bookMgt;

import dal.BookDAO;
import model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "UpdateBookServlet", urlPatterns = {"/book/update"})
public class UpdateBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookIdParam = request.getParameter("id");
        String searchTerm = request.getParameter("search");
        
        BookDAO dao = new BookDAO();
        try {
            if (bookIdParam != null && !bookIdParam.trim().isEmpty()) {
                // Show update form for specific book
                int bookId = Integer.parseInt(bookIdParam);
                BookDAO.BookDetail book = dao.findBookById(bookId);
                if (book != null) {
                    request.setAttribute("book", book);
                    request.setAttribute("categories", dao.getAllCategories());
                    request.setAttribute("authors", dao.getAllAuthors());
                    request.setAttribute("publishers", dao.getAllPublishers());
                    request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Book not found.");
                    request.setAttribute("categories", dao.getAllCategories());
                    request.setAttribute("authors", dao.getAllAuthors());
                    request.setAttribute("publishers", dao.getAllPublishers());
                    request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
                }
            } else if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Search for books
                request.setAttribute("searchResults", dao.searchBooks(searchTerm));
                request.setAttribute("searchTerm", searchTerm);
                request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
            } else {
                // Show search page
                request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid book ID.");
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
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
            BookDAO dao = new BookDAO();
            try {
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("authors", dao.getAllAuthors());
                request.setAttribute("publishers", dao.getAllPublishers());
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid book ID.");
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
            return;
        }

        String isbn = request.getParameter("isbn");
        String title = request.getParameter("title");
        String categoryIdParam = request.getParameter("category_id");
        String publisherIdParam = request.getParameter("publisher_id");
        String publicationYearParam = request.getParameter("publication_year");
        String edition = request.getParameter("edition");
        String language = request.getParameter("language");
        String pagesParam = request.getParameter("pages");
        String description = request.getParameter("description");
        String shelfLocation = request.getParameter("shelf_location");
        String coverImage = request.getParameter("cover_image");
        String[] authorIdsParam = request.getParameterValues("author_ids");

        // Validation
        java.util.Map<String, String> errors = new java.util.HashMap<>();
        if (isEmpty(title)) {
            errors.put("title", "Title is required.");
        }
        if (isEmpty(categoryIdParam)) {
            errors.put("category_id", "Category is required.");
        }
        if (isEmpty(publisherIdParam)) {
            errors.put("publisher_id", "Publisher is required.");
        }

        BookDAO dao = new BookDAO();
        if (!errors.isEmpty()) {
            try {
                BookDAO.BookDetail book = dao.findBookById(bookId);
                if (book != null) {
                    request.setAttribute("book", book);
                }
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("authors", dao.getAllAuthors());
                request.setAttribute("publishers", dao.getAllPublishers());
            } catch (SQLException ignored) {}
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
            return;
        }

        try {
            Book book = new Book();
            book.setIsbn(isEmpty(isbn) ? null : isbn.trim());
            book.setTitle(title.trim());
            book.setCategoryId(Integer.parseInt(categoryIdParam));
            book.setPublisherId(Integer.parseInt(publisherIdParam));
            book.setPublicationYear(isEmpty(publicationYearParam) ? null : Integer.parseInt(publicationYearParam));
            book.setEdition(isEmpty(edition) ? null : edition.trim());
            book.setLanguage(isEmpty(language) ? null : language.trim());
            book.setPages(isEmpty(pagesParam) ? null : Integer.parseInt(pagesParam));
            book.setDescription(isEmpty(description) ? null : description.trim());
            book.setShelfLocation(isEmpty(shelfLocation) ? null : shelfLocation.trim());
            book.setCoverImage(isEmpty(coverImage) ? null : coverImage.trim());

            List<Integer> authorIds = new ArrayList<>();
            if (authorIdsParam != null) {
                for (String authorIdStr : authorIdsParam) {
                    authorIds.add(Integer.parseInt(authorIdStr));
                }
            }

            boolean success = dao.updateBook(bookId, book, authorIds);
            if (success) {
                BookDAO.BookDetail updatedBook = dao.findBookById(bookId);
                request.setAttribute("book", updatedBook);
                request.setAttribute("success", "Book updated successfully.");
            } else {
                request.setAttribute("error", "Failed to update book.");
            }
            request.setAttribute("categories", dao.getAllCategories());
            request.setAttribute("authors", dao.getAllAuthors());
            request.setAttribute("publishers", dao.getAllPublishers());
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                BookDAO.BookDetail book = dao.findBookById(bookId);
                if (book != null) {
                    request.setAttribute("book", book);
                }
                request.setAttribute("categories", dao.getAllCategories());
                request.setAttribute("authors", dao.getAllAuthors());
                request.setAttribute("publishers", dao.getAllPublishers());
            } catch (SQLException ignored) {}
            request.getRequestDispatcher("/bookMgt/book-update.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}

