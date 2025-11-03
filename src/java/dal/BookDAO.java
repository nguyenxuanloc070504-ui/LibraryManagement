package dal;

import model.Book;
import model.Category;
import model.Author;
import model.Publisher;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashSet;
import java.util.Set;

public class BookDAO extends DBContext {

    /**
     * Get all categories
     */
    public List<Category> getAllCategories() throws SQLException {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT category_id, category_name, description, parent_category_id FROM Categories ORDER BY category_name";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setCategoryName(rs.getString("category_name"));
                cat.setDescription(rs.getString("description"));
                cat.setParentCategoryId(rs.getObject("parent_category_id") != null ? rs.getInt("parent_category_id") : null);
                categories.add(cat);
            }
        }
        return categories;
    }

    /**
     * Get all authors
     */
    public List<Author> getAllAuthors() throws SQLException {
        List<Author> authors = new ArrayList<>();
        String sql = "SELECT author_id, author_name, biography, country FROM Authors ORDER BY author_name";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Author author = new Author();
                author.setAuthorId(rs.getInt("author_id"));
                author.setAuthorName(rs.getString("author_name"));
                author.setBiography(rs.getString("biography"));
                author.setCountry(rs.getString("country"));
                authors.add(author);
            }
        }
        return authors;
    }

    /**
     * Ensure authors exist by names and return their IDs (in input order, de-duplicated)
     */
    public List<Integer> ensureAuthorsByNames(List<String> authorNames) throws SQLException {
        List<Integer> result = new ArrayList<>();
        if (authorNames == null || authorNames.isEmpty()) return result;
        Set<String> seen = new LinkedHashSet<>();
        for (String name : authorNames) {
            if (name == null) continue;
            String trimmed = name.trim();
            if (trimmed.isEmpty() || !seen.add(trimmed.toLowerCase())) continue;
            Integer id = findAuthorIdByName(trimmed);
            if (id == null) {
                id = insertAuthor(trimmed);
            }
            if (id != null) result.add(id);
        }
        return result;
    }

    private Integer findAuthorIdByName(String name) throws SQLException {
        String sql = "SELECT author_id FROM Authors WHERE LOWER(author_name) = LOWER(?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return null;
    }

    private Integer insertAuthor(String name) throws SQLException {
        String sql = "INSERT INTO Authors (author_name) VALUES (?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.executeUpdate();
            try (ResultSet gen = ps.getGeneratedKeys()) {
                if (gen.next()) return gen.getInt(1);
            }
        }
        // In case of race condition where another insert happened, try to re-query
        return findAuthorIdByName(name);
    }

    /**
     * Get all publishers
     */
    public List<Publisher> getAllPublishers() throws SQLException {
        List<Publisher> publishers = new ArrayList<>();
        String sql = "SELECT publisher_id, publisher_name, address, phone, email, website FROM Publishers ORDER BY publisher_name";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Publisher pub = new Publisher();
                pub.setPublisherId(rs.getInt("publisher_id"));
                pub.setPublisherName(rs.getString("publisher_name"));
                pub.setAddress(rs.getString("address"));
                pub.setPhone(rs.getString("phone"));
                pub.setEmail(rs.getString("email"));
                pub.setWebsite(rs.getString("website"));
                publishers.add(pub);
            }
        }
        return publishers;
    }

    /**
     * Add new book with authors and copies
     */
    public static class AddBookResult {
        public final int bookId;
        public final int copiesCreated;

        public AddBookResult(int bookId, int copiesCreated) {
            this.bookId = bookId;
            this.copiesCreated = copiesCreated;
        }
    }

    public AddBookResult addBook(Book book, List<Integer> authorIds, int quantity, 
                                 Date acquisitionDate, String conditionStatus, 
                                 java.math.BigDecimal price) throws SQLException {
        String insertBookSql = "INSERT INTO Books (isbn, title, category_id, publisher_id, publication_year, " +
                              "edition, language, pages, description, shelf_location, cover_image) " +
                              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String insertBookAuthorSql = "INSERT INTO Book_Authors (book_id, author_id, author_order) VALUES (?, ?, ?)";
        String insertCopySql = "INSERT INTO Book_Copies (book_id, copy_number, acquisition_date, " +
                              "condition_status, availability_status, price) VALUES (?, ?, ?, ?, 'available', ?)";

        PreparedStatement psBook = null;
        PreparedStatement psAuthor = null;
        PreparedStatement psCopy = null;

        try {
            connection.setAutoCommit(false);

            // Insert book
            psBook = connection.prepareStatement(insertBookSql, Statement.RETURN_GENERATED_KEYS);
            psBook.setString(1, book.getIsbn());
            psBook.setString(2, book.getTitle());
            psBook.setInt(3, book.getCategoryId());
            psBook.setInt(4, book.getPublisherId());
            psBook.setObject(5, book.getPublicationYear());
            psBook.setString(6, book.getEdition());
            psBook.setString(7, book.getLanguage() != null ? book.getLanguage() : "English");
            psBook.setObject(8, book.getPages());
            psBook.setString(9, book.getDescription());
            psBook.setString(10, book.getShelfLocation());
            psBook.setString(11, book.getCoverImage());
            psBook.executeUpdate();

            int newBookId;
            try (ResultSet gen = psBook.getGeneratedKeys()) {
                if (!gen.next()) throw new SQLException("Failed to retrieve book_id");
                newBookId = gen.getInt(1);
            }

            // Insert authors
            if (authorIds != null && !authorIds.isEmpty()) {
                psAuthor = connection.prepareStatement(insertBookAuthorSql);
                int order = 1;
                for (Integer authorId : authorIds) {
                    psAuthor.setInt(1, newBookId);
                    psAuthor.setInt(2, authorId);
                    psAuthor.setInt(3, order++);
                    psAuthor.addBatch();
                }
                psAuthor.executeBatch();
            }

            // Insert copies
            int copiesCreated = 0;
            if (quantity > 0) {
                psCopy = connection.prepareStatement(insertCopySql);
                for (int i = 1; i <= quantity; i++) {
                    String copyNumber = "C" + String.format("%03d", i);
                    psCopy.setInt(1, newBookId);
                    psCopy.setString(2, copyNumber);
                    psCopy.setDate(3, acquisitionDate != null ? acquisitionDate : new Date(System.currentTimeMillis()));
                    psCopy.setString(4, conditionStatus != null ? conditionStatus : "excellent");
                    psCopy.setBigDecimal(5, price);
                    psCopy.addBatch();
                    copiesCreated++;
                }
                psCopy.executeBatch();
            }

            connection.commit();
            return new AddBookResult(newBookId, copiesCreated);
        } catch (SQLException e) {
            if (connection != null) {
                try { connection.rollback(); } catch (SQLException ignored) {}
            }
            throw e;
        } finally {
            if (psBook != null) try { psBook.close(); } catch (SQLException ignored) {}
            if (psAuthor != null) try { psAuthor.close(); } catch (SQLException ignored) {}
            if (psCopy != null) try { psCopy.close(); } catch (SQLException ignored) {}
            if (connection != null) try { connection.setAutoCommit(true); } catch (SQLException ignored) {}
        }
    }

    /**
     * Find book by ID with full details
     */
    public static class BookDetail {
        public int bookId;
        public String isbn;
        public String title;
        public Integer categoryId;
        public String categoryName;
        public Integer publisherId;
        public String publisherName;
        public Integer publicationYear;
        public String edition;
        public String language;
        public Integer pages;
        public String description;
        public String shelfLocation;
        public String coverImage;
        public List<Integer> authorIds;
        public List<String> authorNames;
        public int totalCopies;
        public int availableCopies;
    }

    public BookDetail findBookById(int bookId) throws SQLException {
        String sql = "SELECT b.book_id, b.isbn, b.title, b.category_id, c.category_name, " +
                     "b.publisher_id, p.publisher_name, b.publication_year, b.edition, " +
                     "b.language, b.pages, b.description, b.shelf_location, b.cover_image " +
                     "FROM Books b " +
                     "LEFT JOIN Categories c ON b.category_id = c.category_id " +
                     "LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id " +
                     "WHERE b.book_id = ?";
        
        BookDetail detail = null;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    detail = new BookDetail();
                    detail.bookId = rs.getInt("book_id");
                    detail.isbn = rs.getString("isbn");
                    detail.title = rs.getString("title");
                    detail.categoryId = rs.getInt("category_id");
                    detail.categoryName = rs.getString("category_name");
                    detail.publisherId = rs.getInt("publisher_id");
                    detail.publisherName = rs.getString("publisher_name");
                    detail.publicationYear = rs.getObject("publication_year") != null ? rs.getInt("publication_year") : null;
                    detail.edition = rs.getString("edition");
                    detail.language = rs.getString("language");
                    detail.pages = rs.getObject("pages") != null ? rs.getInt("pages") : null;
                    detail.description = rs.getString("description");
                    detail.shelfLocation = rs.getString("shelf_location");
                    detail.coverImage = rs.getString("cover_image");

                    // Get authors
                    detail.authorIds = new ArrayList<>();
                    detail.authorNames = new ArrayList<>();
                    String authorSql = "SELECT a.author_id, a.author_name " +
                                      "FROM Book_Authors ba " +
                                      "JOIN Authors a ON ba.author_id = a.author_id " +
                                      "WHERE ba.book_id = ? ORDER BY ba.author_order";
                    try (PreparedStatement psAuthor = connection.prepareStatement(authorSql)) {
                        psAuthor.setInt(1, bookId);
                        try (ResultSet rsAuthor = psAuthor.executeQuery()) {
                            while (rsAuthor.next()) {
                                detail.authorIds.add(rsAuthor.getInt("author_id"));
                                detail.authorNames.add(rsAuthor.getString("author_name"));
                            }
                        }
                    }

                    // Get copy counts
                    String copySql = "SELECT COUNT(*) as total, " +
                                    "SUM(CASE WHEN availability_status = 'available' THEN 1 ELSE 0 END) as available " +
                                    "FROM Book_Copies WHERE book_id = ?";
                    try (PreparedStatement psCopy = connection.prepareStatement(copySql)) {
                        psCopy.setInt(1, bookId);
                        try (ResultSet rsCopy = psCopy.executeQuery()) {
                            if (rsCopy.next()) {
                                detail.totalCopies = rsCopy.getInt("total");
                                detail.availableCopies = rsCopy.getInt("available");
                            }
                        }
                    }
                }
            }
        }
        return detail;
    }

    /**
     * Search books by title, ISBN, or author
     */
    public List<BookDetail> searchBooks(String searchTerm) throws SQLException {
        List<BookDetail> results = new ArrayList<>();
        String sql = "SELECT DISTINCT b.book_id, b.isbn, b.title, b.category_id, c.category_name, " +
                     "b.publisher_id, p.publisher_name, b.publication_year, b.shelf_location, b.cover_image, " +
                     "(SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id = b.book_id) AS total_copies, " +
                     "(SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id = b.book_id AND bc.availability_status = 'available') AS available_copies " +
                     "FROM Books b " +
                     "LEFT JOIN Categories c ON b.category_id = c.category_id " +
                     "LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id " +
                     "LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id " +
                     "LEFT JOIN Authors a ON ba.author_id = a.author_id " +
                     "WHERE b.title LIKE ? OR b.isbn LIKE ? OR a.author_name LIKE ? " +
                     "ORDER BY b.title";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + searchTerm + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookDetail detail = new BookDetail();
                    detail.bookId = rs.getInt("book_id");
                    detail.isbn = rs.getString("isbn");
                    detail.title = rs.getString("title");
                    detail.categoryId = rs.getInt("category_id");
                    detail.categoryName = rs.getString("category_name");
                    detail.publisherId = rs.getInt("publisher_id");
                    detail.publisherName = rs.getString("publisher_name");
                    detail.publicationYear = rs.getObject("publication_year") != null ? rs.getInt("publication_year") : null;
                    detail.shelfLocation = rs.getString("shelf_location");
                    detail.coverImage = rs.getString("cover_image");
                    detail.totalCopies = rs.getInt("total_copies");
                    detail.availableCopies = rs.getInt("available_copies");
                    results.add(detail);
                }
            }
        }
        return results;
    }

    /**
     * Get all books with basic details for listing
     */
    public List<BookDetail> getAllBooks() throws SQLException {
        List<BookDetail> results = new ArrayList<>();
        String sql = "SELECT b.book_id, b.isbn, b.title, b.category_id, c.category_name, " +
                     "b.publisher_id, p.publisher_name, b.publication_year, b.shelf_location, b.cover_image, " +
                     "(SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id = b.book_id) AS total_copies, " +
                     "(SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id = b.book_id AND bc.availability_status = 'available') AS available_copies " +
                     "FROM Books b " +
                     "LEFT JOIN Categories c ON b.category_id = c.category_id " +
                     "LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id " +
                     "ORDER BY b.title";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                BookDetail detail = new BookDetail();
                detail.bookId = rs.getInt("book_id");
                detail.isbn = rs.getString("isbn");
                detail.title = rs.getString("title");
                detail.categoryId = rs.getInt("category_id");
                detail.categoryName = rs.getString("category_name");
                detail.publisherId = rs.getInt("publisher_id");
                detail.publisherName = rs.getString("publisher_name");
                detail.publicationYear = rs.getObject("publication_year") != null ? rs.getInt("publication_year") : null;
                detail.shelfLocation = rs.getString("shelf_location");
                detail.coverImage = rs.getString("cover_image");
                detail.totalCopies = rs.getInt("total_copies");
                detail.availableCopies = rs.getInt("available_copies");
                results.add(detail);
            }
        }
        return results;
    }

    /**
     * Update book information
     */
    public boolean updateBook(int bookId, Book book, List<Integer> authorIds) throws SQLException {
        String updateBookSql = "UPDATE Books SET isbn = ?, title = ?, category_id = ?, publisher_id = ?, " +
                              "publication_year = ?, edition = ?, language = ?, pages = ?, " +
                              "description = ?, shelf_location = ?, cover_image = ? WHERE book_id = ?";
        String deleteAuthorsSql = "DELETE FROM Book_Authors WHERE book_id = ?";
        String insertAuthorSql = "INSERT INTO Book_Authors (book_id, author_id, author_order) VALUES (?, ?, ?)";

        PreparedStatement psUpdate = null;
        PreparedStatement psDeleteAuthors = null;
        PreparedStatement psInsertAuthor = null;

        try {
            connection.setAutoCommit(false);

            // Update book
            psUpdate = connection.prepareStatement(updateBookSql);
            psUpdate.setString(1, book.getIsbn());
            psUpdate.setString(2, book.getTitle());
            psUpdate.setInt(3, book.getCategoryId());
            psUpdate.setInt(4, book.getPublisherId());
            psUpdate.setObject(5, book.getPublicationYear());
            psUpdate.setString(6, book.getEdition());
            psUpdate.setString(7, book.getLanguage() != null ? book.getLanguage() : "English");
            psUpdate.setObject(8, book.getPages());
            psUpdate.setString(9, book.getDescription());
            psUpdate.setString(10, book.getShelfLocation());
            psUpdate.setString(11, book.getCoverImage());
            psUpdate.setInt(12, bookId);
            psUpdate.executeUpdate();

            // Update authors
            if (authorIds != null) {
                psDeleteAuthors = connection.prepareStatement(deleteAuthorsSql);
                psDeleteAuthors.setInt(1, bookId);
                psDeleteAuthors.executeUpdate();

                if (!authorIds.isEmpty()) {
                    psInsertAuthor = connection.prepareStatement(insertAuthorSql);
                    int order = 1;
                    for (Integer authorId : authorIds) {
                        psInsertAuthor.setInt(1, bookId);
                        psInsertAuthor.setInt(2, authorId);
                        psInsertAuthor.setInt(3, order++);
                        psInsertAuthor.addBatch();
                    }
                    psInsertAuthor.executeBatch();
                }
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            if (connection != null) {
                try { connection.rollback(); } catch (SQLException ignored) {}
            }
            throw e;
        } finally {
            if (psUpdate != null) try { psUpdate.close(); } catch (SQLException ignored) {}
            if (psDeleteAuthors != null) try { psDeleteAuthors.close(); } catch (SQLException ignored) {}
            if (psInsertAuthor != null) try { psInsertAuthor.close(); } catch (SQLException ignored) {}
            if (connection != null) try { connection.setAutoCommit(true); } catch (SQLException ignored) {}
        }
    }

    /**
     * Remove book from system (cascade delete will handle related records)
     */
    public boolean removeBook(int bookId) throws SQLException {
        // Check if book has active borrowings
        String checkBorrowingsSql = "SELECT COUNT(*) as count FROM Borrowing_Transactions bt " +
                                   "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                                   "WHERE bc.book_id = ? AND bt.transaction_status IN ('borrowed', 'overdue')";
        try (PreparedStatement ps = connection.prepareStatement(checkBorrowingsSql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("count") > 0) {
                    return false; // Cannot delete if has active borrowings
                }
            }
        }

        // Delete book (cascade will delete copies and book_authors)
        String deleteSql = "DELETE FROM Books WHERE book_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteSql)) {
            ps.setInt(1, bookId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Add new category
     */
    public int addCategory(String categoryName, String description, Integer parentCategoryId) throws SQLException {
        String sql = "INSERT INTO Categories (category_name, description, parent_category_id) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, categoryName);
            ps.setString(2, description);
            ps.setObject(3, parentCategoryId);
            ps.executeUpdate();
            try (ResultSet gen = ps.getGeneratedKeys()) {
                if (gen.next()) {
                    return gen.getInt(1);
                }
            }
        }
        return -1;
    }

    /**
     * Update category
     */
    public boolean updateCategory(int categoryId, String categoryName, String description, Integer parentCategoryId) throws SQLException {
        String sql = "UPDATE Categories SET category_name = ?, description = ?, parent_category_id = ? WHERE category_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, categoryName);
            ps.setString(2, description);
            ps.setObject(3, parentCategoryId);
            ps.setInt(4, categoryId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Delete category (only if no books use it)
     */
    public boolean deleteCategory(int categoryId) throws SQLException {
        // Check if category is used by any books
        String checkSql = "SELECT COUNT(*) as count FROM Books WHERE category_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("count") > 0) {
                    return false; // Cannot delete if used by books
                }
            }
        }

        // Check if category has children
        String checkChildrenSql = "SELECT COUNT(*) as count FROM Categories WHERE parent_category_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(checkChildrenSql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("count") > 0) {
                    return false; // Cannot delete if has children
                }
            }
        }

        String deleteSql = "DELETE FROM Categories WHERE category_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(deleteSql)) {
            ps.setInt(1, categoryId);
            return ps.executeUpdate() > 0;
        }
    }
}

