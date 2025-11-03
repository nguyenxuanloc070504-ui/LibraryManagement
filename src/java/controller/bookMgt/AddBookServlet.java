package controller.bookMgt;

import dal.BookDAO;
import model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AddBookServlet", urlPatterns = {"/book/add"})
@MultipartConfig
public class AddBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BookDAO dao = new BookDAO();
        try {
            request.setAttribute("categories", dao.getAllCategories());
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
        String quantityParam = request.getParameter("quantity");
        String acquisitionDateParam = request.getParameter("acquisition_date");
        String conditionStatus = request.getParameter("condition_status");
        String priceParam = request.getParameter("price");
        String authorNamesParam = request.getParameter("author_names");

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
        if (isEmpty(authorNamesParam)) {
            errors.put("author_names", "At least one author is required.");
        }
        if (isEmpty(quantityParam) || Integer.parseInt(quantityParam) <= 0) {
            errors.put("quantity", "Quantity must be at least 1.");
        }

        BookDAO dao = new BookDAO();
        try {
            request.setAttribute("categories", dao.getAllCategories());
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
            // Handle cover image upload
            String savedCoverPath = null;
            Part coverPart = null;
            try { coverPart = request.getPart("cover_file"); } catch (IllegalStateException ignored) {}
            if (coverPart != null && coverPart.getSize() > 0) {
                String fileName = Path.of(getSubmittedFileName(coverPart)).getFileName().toString();
                String ext = "";
                int dot = fileName.lastIndexOf('.');
                if (dot >= 0) ext = fileName.substring(dot);
                String safeName = System.currentTimeMillis() + "_" + Math.abs(fileName.hashCode()) + ext;
                String uploadDir = getServletContext().getRealPath("/uploads/covers");
                if (uploadDir != null) {
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    Path dest = Path.of(uploadDir, safeName);
                    try {
                        Files.copy(coverPart.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);
                        savedCoverPath = request.getContextPath() + "/uploads/covers/" + safeName;
                    } catch (IOException ioe) {
                        // log and ignore, do not block save
                    }
                }
            }
            book.setCoverImage(savedCoverPath);

            // Parse author names -> ensure IDs
            List<String> authorNames = new ArrayList<>();
            if (!isEmpty(authorNamesParam)) {
                for (String part : authorNamesParam.split(",")) {
                    String n = part.trim();
                    if (!n.isEmpty()) authorNames.add(n);
                }
            }
            List<Integer> authorIds = dao.ensureAuthorsByNames(authorNames);

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
            request.setAttribute("publishers", dao.getAllPublishers());
        } catch (SQLException ignored) {}
        request.getRequestDispatcher("/bookMgt/book-add.jsp").forward(request, response);
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String getSubmittedFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) return null;
        for (String seg : cd.split(";")) {
            String s = seg.trim();
            if (s.startsWith("filename")) {
                String fn = s.substring(s.indexOf('=') + 1).trim().replace("\"", "");
                return fn;
            }
        }
        return null;
    }
}

