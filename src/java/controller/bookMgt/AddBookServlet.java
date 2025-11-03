package controller.bookMgt;

import dal.BookDAO;
import model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AddBookServlet", urlPatterns = {"/book/add"})
public class AddBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BookDAO dao = new BookDAO();
        try {
            request.setAttribute("categories", dao.getAllCategories());
            request.setAttribute("authors", dao.getAllAuthors());
            request.setAttribute("publishers", dao.getAllPublishers());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }
        request.getRequestDispatcher("/bookMgt/book-add.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

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
        String quantityParam = request.getParameter("quantity");
        String acquisitionDateParam = request.getParameter("acquisition_date");
        String conditionStatus = request.getParameter("condition_status");
        String priceParam = request.getParameter("price");

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
        if (authorIdsParam == null || authorIdsParam.length == 0) {
            errors.put("author_ids", "At least one author is required.");
        }
        if (isEmpty(quantityParam) || Integer.parseInt(quantityParam) <= 0) {
            errors.put("quantity", "Quantity must be at least 1.");
        }

        BookDAO dao = new BookDAO();
        try {
            request.setAttribute("categories", dao.getAllCategories());
            request.setAttribute("authors", dao.getAllAuthors());
            request.setAttribute("publishers", dao.getAllPublishers());
        } catch (SQLException ignored) {}

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/bookMgt/book-add.jsp").forward(request, response);
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
            for (String authorIdStr : authorIdsParam) {
                authorIds.add(Integer.parseInt(authorIdStr));
            }

            int quantity = Integer.parseInt(quantityParam);
            Date acquisitionDate = isEmpty(acquisitionDateParam) ? 
                new Date(System.currentTimeMillis()) : Date.valueOf(acquisitionDateParam);
            java.math.BigDecimal price = isEmpty(priceParam) ? null : 
                new java.math.BigDecimal(priceParam);

            BookDAO.AddBookResult result = dao.addBook(book, authorIds, quantity, 
                    acquisitionDate, conditionStatus != null ? conditionStatus : "excellent", price);

            request.setAttribute("success", "Book added successfully! Book ID: " + result.bookId + 
                    ", Copies created: " + result.copiesCreated);
            request.setAttribute("bookId", result.bookId);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid number format.");
        } finally {
            dao.close();
        }

        try {
            request.setAttribute("categories", dao.getAllCategories());
            request.setAttribute("authors", dao.getAllAuthors());
            request.setAttribute("publishers", dao.getAllPublishers());
        } catch (SQLException ignored) {}
        request.getRequestDispatcher("/bookMgt/book-add.jsp").forward(request, response);
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}

