package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO extends DBContext {

    /**
     * Lend book using stored procedure
     */
    public static class LendBookResult {
        public final boolean success;
        public final String message;
        public final Integer transactionId;

        public LendBookResult(boolean success, String message, Integer transactionId) {
            this.success = success;
            this.message = message;
            this.transactionId = transactionId;
        }
    }

    public LendBookResult lendBook(int userId, int bookId, int librarianId) throws SQLException {
        String sql = "{CALL sp_borrow_book(?, ?, ?, ?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            // Register OUT parameters first
            cs.registerOutParameter(4, Types.VARCHAR);
            cs.registerOutParameter(5, Types.INTEGER);

            // Then set IN parameters
            cs.setInt(1, userId);
            cs.setInt(2, bookId);
            cs.setInt(3, librarianId);

            cs.execute();

            String result = cs.getString(4);
            Integer transactionId = cs.getInt(5);
            if (cs.wasNull()) {
                transactionId = null;
            }

            boolean success = result != null && result.startsWith("Success");
            return new LendBookResult(success, result != null ? result : "Unknown error", transactionId);
        }
    }

    /**
     * Return book using stored procedure
     */
    public static class ReturnBookResult {
        public final boolean success;
        public final String message;
        public final java.math.BigDecimal fineAmount;

        public ReturnBookResult(boolean success, String message, java.math.BigDecimal fineAmount) {
            this.success = success;
            this.message = message;
            this.fineAmount = fineAmount;
        }
    }

    public ReturnBookResult returnBook(int transactionId, String conditionStatus) throws SQLException {
        String sql = "{CALL sp_return_book(?, ?, ?, ?)}";
        try (CallableStatement cs = connection.prepareCall(sql)) {
            // Register OUT parameters first
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.registerOutParameter(4, Types.DECIMAL);

            // Then set IN parameters
            cs.setInt(1, transactionId);
            cs.setString(2, conditionStatus);

            cs.execute();
            
            String result = cs.getString(3);
            java.math.BigDecimal fineAmount = cs.getBigDecimal(4);
            if (fineAmount == null) {
                fineAmount = java.math.BigDecimal.ZERO;
            }
            
            boolean success = result != null && result.startsWith("Success");
            return new ReturnBookResult(success, result != null ? result : "Unknown error", fineAmount);
        }
    }

    /**
     * Get current borrowing transactions detail
     */
    public static class BorrowingDetail {
        public int transactionId;
        public int copyId;
        public int userId;
        public String memberName;
        public String memberEmail;
        public int bookId;
        public String bookTitle;
        public String isbn;
        public String copyNumber;
        public java.sql.Date borrowDate;
        public java.sql.Date dueDate;
        public java.sql.Date returnDate;
        public int renewalCount;
        public String transactionStatus;
        public int daysOverdue;
        public java.math.BigDecimal potentialFine;
        public java.sql.Timestamp scheduledReturnDate;
    }

    public List<BorrowingDetail> getCurrentBorrowings() throws SQLException {
        List<BorrowingDetail> results = new ArrayList<>();
        String sql = "SELECT bt.transaction_id, bt.copy_id, bt.user_id, u.full_name as member_name, " +
                     "u.email as member_email, b.book_id, b.title as book_title, b.isbn, " +
                     "bc.copy_number, bt.borrow_date, bt.due_date, bt.renewal_count, " +
                     "bt.transaction_status, " +
                     "DATEDIFF(CURDATE(), bt.due_date) as days_overdue, " +
                     "CASE " +
                     "  WHEN DATEDIFF(CURDATE(), bt.due_date) > 0 THEN " +
                     "    DATEDIFF(CURDATE(), bt.due_date) * " +
                     "    (SELECT CAST(setting_value AS DECIMAL(10,2)) FROM System_Settings WHERE setting_key = 'fine_per_day') " +
                     "  ELSE 0 " +
                     "END as potential_fine, " +
                     "rs.scheduled_return_date " +
                     "FROM Borrowing_Transactions bt " +
                     "JOIN Users u ON bt.user_id = u.user_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     "LEFT JOIN Return_Schedules rs ON rs.transaction_id = bt.transaction_id " +
                     "WHERE bt.transaction_status IN ('borrowed', 'overdue') " +
                     "ORDER BY bt.due_date ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                BorrowingDetail detail = new BorrowingDetail();
                detail.transactionId = rs.getInt("transaction_id");
                detail.copyId = rs.getInt("copy_id");
                detail.userId = rs.getInt("user_id");
                detail.memberName = rs.getString("member_name");
                detail.memberEmail = rs.getString("member_email");
                detail.bookId = rs.getInt("book_id");
                detail.bookTitle = rs.getString("book_title");
                detail.isbn = rs.getString("isbn");
                detail.copyNumber = rs.getString("copy_number");
                detail.borrowDate = rs.getDate("borrow_date");
                detail.dueDate = rs.getDate("due_date");
                detail.renewalCount = rs.getInt("renewal_count");
                detail.transactionStatus = rs.getString("transaction_status");
                detail.daysOverdue = rs.getInt("days_overdue");
                detail.potentialFine = rs.getBigDecimal("potential_fine");
                try { detail.scheduledReturnDate = rs.getTimestamp("scheduled_return_date"); } catch (SQLException ignore) {}
                results.add(detail);
            }
        }
        return results;
    }

    /**
     * Get overdue books
     */
    public List<BorrowingDetail> getOverdueBooks() throws SQLException {
        List<BorrowingDetail> results = new ArrayList<>();
        String sql = "SELECT bt.transaction_id, bt.copy_id, bt.user_id, u.full_name as member_name, " +
                     "u.email as member_email, u.phone, b.book_id, b.title as book_title, b.isbn, " +
                     "bc.copy_number, bt.borrow_date, bt.due_date, bt.renewal_count, " +
                     "bt.transaction_status, " +
                     "DATEDIFF(CURDATE(), bt.due_date) as days_overdue, " +
                     "(DATEDIFF(CURDATE(), bt.due_date) * " +
                     " (SELECT CAST(setting_value AS DECIMAL(10,2)) FROM System_Settings WHERE setting_key = 'fine_per_day')) " +
                     "as calculated_fine, " +
                     "COALESCE(f.fine_amount, 0) as recorded_fine, " +
                     "COALESCE(f.payment_status, 'not_generated') as fine_status " +
                     "FROM Borrowing_Transactions bt " +
                     "JOIN Users u ON bt.user_id = u.user_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     "LEFT JOIN Fines f ON bt.transaction_id = f.transaction_id " +
                     "WHERE bt.transaction_status = 'overdue' " +
                     "ORDER BY days_overdue DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                BorrowingDetail detail = new BorrowingDetail();
                detail.transactionId = rs.getInt("transaction_id");
                detail.copyId = rs.getInt("copy_id");
                detail.userId = rs.getInt("user_id");
                detail.memberName = rs.getString("member_name");
                detail.memberEmail = rs.getString("member_email");
                detail.bookId = rs.getInt("book_id");
                detail.bookTitle = rs.getString("book_title");
                detail.isbn = rs.getString("isbn");
                detail.copyNumber = rs.getString("copy_number");
                detail.borrowDate = rs.getDate("borrow_date");
                detail.dueDate = rs.getDate("due_date");
                detail.renewalCount = rs.getInt("renewal_count");
                detail.transactionStatus = rs.getString("transaction_status");
                detail.daysOverdue = rs.getInt("days_overdue");
                detail.potentialFine = rs.getBigDecimal("calculated_fine");
                results.add(detail);
            }
        }
        return results;
    }

    /**
     * Get borrowing transaction by ID
     */
    public BorrowingDetail getBorrowingById(int transactionId) throws SQLException {
        String sql = "SELECT bt.transaction_id, bt.copy_id, bt.user_id, u.full_name as member_name, " +
                     "u.email as member_email, b.book_id, b.title as book_title, b.isbn, " +
                     "bc.copy_number, bt.borrow_date, bt.due_date, bt.renewal_count, " +
                     "bt.transaction_status, " +
                     "DATEDIFF(CURDATE(), bt.due_date) as days_overdue " +
                     "FROM Borrowing_Transactions bt " +
                     "JOIN Users u ON bt.user_id = u.user_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     "WHERE bt.transaction_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BorrowingDetail detail = new BorrowingDetail();
                    detail.transactionId = rs.getInt("transaction_id");
                    detail.copyId = rs.getInt("copy_id");
                    detail.userId = rs.getInt("user_id");
                    detail.memberName = rs.getString("member_name");
                    detail.memberEmail = rs.getString("member_email");
                    detail.bookId = rs.getInt("book_id");
                    detail.bookTitle = rs.getString("book_title");
                    detail.isbn = rs.getString("isbn");
                    detail.copyNumber = rs.getString("copy_number");
                    detail.borrowDate = rs.getDate("borrow_date");
                    detail.dueDate = rs.getDate("due_date");
                    detail.renewalCount = rs.getInt("renewal_count");
                    detail.transactionStatus = rs.getString("transaction_status");
                    detail.daysOverdue = rs.getInt("days_overdue");
                    return detail;
                }
            }
        }
        return null;
    }

    /**
     * Check renewal eligibility using function
     */
    public String checkRenewalEligibility(int transactionId) throws SQLException {
        String sql = "SELECT fn_check_renewal_eligibility(?) as eligibility";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("eligibility");
                }
            }
        }
        return "Unknown";
    }

    /**
     * Renew borrowed book
     */
    public boolean renewBook(int transactionId, int librarianId) throws SQLException {
        // Check eligibility first
        String eligibility = checkRenewalEligibility(transactionId);
        if (!"Eligible".equals(eligibility)) {
            throw new SQLException(eligibility);
        }

        // Get current transaction details
        BorrowingDetail transaction = getBorrowingById(transactionId);
        if (transaction == null) {
            throw new SQLException("Transaction not found");
        }

        // Get extension days from settings
        String settingsSql = "SELECT CAST(setting_value AS DECIMAL) as extend_days " +
                            "FROM System_Settings WHERE setting_key = 'renewal_extend_days'";
        int extendDays = 14; // default
        try (PreparedStatement ps = connection.prepareStatement(settingsSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                extendDays = rs.getInt("extend_days");
            }
        }

        // Calculate new due date
        java.sql.Date oldDueDate = transaction.dueDate;
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(oldDueDate);
        cal.add(java.util.Calendar.DAY_OF_MONTH, extendDays);
        java.sql.Date newDueDate = new java.sql.Date(cal.getTimeInMillis());

        connection.setAutoCommit(false);
        try {
            // Update transaction
            String updateSql = "UPDATE Borrowing_Transactions SET due_date = ?, renewal_count = renewal_count + 1 " +
                              "WHERE transaction_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(updateSql)) {
                ps.setDate(1, newDueDate);
                ps.setInt(2, transactionId);
                ps.executeUpdate();
            }

            // Insert renewal record
            String insertRenewalSql = "INSERT INTO Renewals (transaction_id, old_due_date, new_due_date, processed_by) " +
                                     "VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = connection.prepareStatement(insertRenewalSql)) {
                ps.setInt(1, transactionId);
                ps.setDate(2, oldDueDate);
                ps.setDate(3, newDueDate);
                ps.setInt(4, librarianId);
                ps.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }
    }

    /**
     * Get all fines (unpaid, paid, waived)
     */
    public static class FineDetail {
        public int fineId;
        public int transactionId;
        public int userId;
        public String memberName;
        public String memberEmail;
        public String bookTitle;
        public java.math.BigDecimal fineAmount;
        public String fineReason;
        public int daysOverdue;
        public java.sql.Date fineDate;
        public String paymentStatus;
        public java.sql.Date paymentDate;
        public String paymentMethod;
        public String notes;
    }

    public List<FineDetail> getAllFines(String paymentStatus) throws SQLException {
        List<FineDetail> results = new ArrayList<>();
        String sql = "SELECT f.fine_id, f.transaction_id, f.user_id, u.full_name as member_name, " +
                     "u.email as member_email, b.title as book_title, f.fine_amount, " +
                     "f.fine_reason, f.days_overdue, f.fine_date, f.payment_status, " +
                     "f.payment_date, f.payment_method, f.notes " +
                     "FROM Fines f " +
                     "JOIN Users u ON f.user_id = u.user_id " +
                     "JOIN Borrowing_Transactions bt ON f.transaction_id = bt.transaction_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     (paymentStatus != null ? "WHERE f.payment_status = ? " : "") +
                     "ORDER BY f.fine_date DESC, f.payment_status";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (paymentStatus != null) {
                ps.setString(1, paymentStatus);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    FineDetail detail = new FineDetail();
                    detail.fineId = rs.getInt("fine_id");
                    detail.transactionId = rs.getInt("transaction_id");
                    detail.userId = rs.getInt("user_id");
                    detail.memberName = rs.getString("member_name");
                    detail.memberEmail = rs.getString("member_email");
                    detail.bookTitle = rs.getString("book_title");
                    detail.fineAmount = rs.getBigDecimal("fine_amount");
                    detail.fineReason = rs.getString("fine_reason");
                    detail.daysOverdue = rs.getInt("days_overdue");
                    detail.fineDate = rs.getDate("fine_date");
                    detail.paymentStatus = rs.getString("payment_status");
                    detail.paymentDate = rs.getDate("payment_date");
                    detail.paymentMethod = rs.getString("payment_method");
                    detail.notes = rs.getString("notes");
                    results.add(detail);
                }
            }
        }
        return results;
    }

    /**
     * Update fine payment status
     */
    public boolean updateFinePayment(int fineId, String paymentStatus, String paymentMethod, 
                                     java.sql.Date paymentDate, Integer processedBy, String notes) throws SQLException {
        String sql = "UPDATE Fines SET payment_status = ?, payment_method = ?, " +
                     "payment_date = ?, processed_by = ?, notes = ? WHERE fine_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            ps.setString(2, paymentMethod);
            ps.setDate(3, paymentDate);
            ps.setObject(4, processedBy);
            ps.setString(5, notes);
            ps.setInt(6, fineId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Search books available for lending
     */
    public static class AvailableBook {
        public int bookId;
        public String title;
        public String isbn;
        public String categoryName;
        public String authors;
        public String publisherName;
        public int availableCopies;
    }

    public List<AvailableBook> searchAvailableBooks(String searchTerm) throws SQLException {
        List<AvailableBook> results = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.isbn, c.category_name, " +
                     "GROUP_CONCAT(DISTINCT a.author_name ORDER BY ba.author_order SEPARATOR ', ') as authors, " +
                     "p.publisher_name, " +
                     "SUM(CASE WHEN bc.availability_status = 'available' THEN 1 ELSE 0 END) as available_copies " +
                     "FROM Books b " +
                     "LEFT JOIN Categories c ON b.category_id = c.category_id " +
                     "LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id " +
                     "LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id " +
                     "LEFT JOIN Authors a ON ba.author_id = a.author_id " +
                     "LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id " +
                     "WHERE (b.title LIKE ? OR b.isbn LIKE ? OR a.author_name LIKE ?) " +
                     "GROUP BY b.book_id, b.title, b.isbn, c.category_name, p.publisher_name " +
                     "HAVING available_copies > 0 " +
                     "ORDER BY b.title";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + searchTerm + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AvailableBook book = new AvailableBook();
                    book.bookId = rs.getInt("book_id");
                    book.title = rs.getString("title");
                    book.isbn = rs.getString("isbn");
                    book.categoryName = rs.getString("category_name");
                    book.authors = rs.getString("authors");
                    book.publisherName = rs.getString("publisher_name");
                    book.availableCopies = rs.getInt("available_copies");
                    results.add(book);
                }
            }
        }
        return results;
    }

    /**
     * Search members for lending
     */
    public List<dal.MemberDAO.MemberDetail> searchMembersForLending(String searchTerm) throws SQLException {
        dal.MemberDAO memberDAO = new dal.MemberDAO();
        memberDAO.connection = this.connection; // Share connection
        try {
            return memberDAO.searchMembers(searchTerm);
        } finally {
            memberDAO.connection = null; // Don't close shared connection
        }
    }

    /**
     * Get current borrowings for a specific user
     */
    public List<BorrowingDetail> getUserCurrentBorrowings(int userId) throws SQLException {
        List<BorrowingDetail> results = new ArrayList<>();
        String sql = "SELECT bt.transaction_id, bt.copy_id, bt.user_id, u.full_name as member_name, " +
                     "u.email as member_email, b.book_id, b.title as book_title, b.isbn, " +
                     "bc.copy_number, bt.borrow_date, bt.due_date, bt.renewal_count, " +
                     "bt.transaction_status, " +
                     "DATEDIFF(CURDATE(), bt.due_date) as days_overdue, " +
                     "CASE " +
                     "  WHEN DATEDIFF(CURDATE(), bt.due_date) > 0 THEN " +
                     "    DATEDIFF(CURDATE(), bt.due_date) * " +
                     "    (SELECT CAST(setting_value AS DECIMAL(10,2)) FROM System_Settings WHERE setting_key = 'fine_per_day') " +
                     "  ELSE 0 " +
                     "END as potential_fine, " +
                     "rs.scheduled_return_date " +
                     "FROM Borrowing_Transactions bt " +
                     "JOIN Users u ON bt.user_id = u.user_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     "LEFT JOIN Return_Schedules rs ON rs.transaction_id = bt.transaction_id " +
                     "WHERE bt.user_id = ? AND bt.transaction_status IN ('borrowed', 'overdue') " +
                     "ORDER BY bt.due_date ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BorrowingDetail detail = new BorrowingDetail();
                    detail.transactionId = rs.getInt("transaction_id");
                    detail.copyId = rs.getInt("copy_id");
                    detail.userId = rs.getInt("user_id");
                    detail.memberName = rs.getString("member_name");
                    detail.memberEmail = rs.getString("member_email");
                    detail.bookId = rs.getInt("book_id");
                    detail.bookTitle = rs.getString("book_title");
                    detail.isbn = rs.getString("isbn");
                    detail.copyNumber = rs.getString("copy_number");
                    detail.borrowDate = rs.getDate("borrow_date");
                    detail.dueDate = rs.getDate("due_date");
                    detail.renewalCount = rs.getInt("renewal_count");
                    detail.transactionStatus = rs.getString("transaction_status");
                    detail.daysOverdue = rs.getInt("days_overdue");
                    detail.potentialFine = rs.getBigDecimal("potential_fine");
                    try { detail.scheduledReturnDate = rs.getTimestamp("scheduled_return_date"); } catch (SQLException ignore) {}
                    results.add(detail);
                }
            }
        }
        return results;
    }

    /**
     * Get borrowing history (returned books) for a specific user
     */
    public List<BorrowingDetail> getUserBorrowingHistory(int userId) throws SQLException {
        List<BorrowingDetail> results = new ArrayList<>();
        String sql = "SELECT bt.transaction_id, bt.copy_id, bt.user_id, u.full_name as member_name, " +
                     "u.email as member_email, b.book_id, b.title as book_title, b.isbn, " +
                     "bc.copy_number, bt.borrow_date, bt.due_date, bt.return_date, bt.renewal_count, " +
                     "bt.transaction_status, " +
                     "DATEDIFF(bt.return_date, bt.due_date) as days_overdue " +
                     "FROM Borrowing_Transactions bt " +
                     "JOIN Users u ON bt.user_id = u.user_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     "WHERE bt.user_id = ? AND bt.transaction_status = 'returned' " +
                     "ORDER BY bt.return_date DESC, bt.borrow_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BorrowingDetail detail = new BorrowingDetail();
                    detail.transactionId = rs.getInt("transaction_id");
                    detail.copyId = rs.getInt("copy_id");
                    detail.userId = rs.getInt("user_id");
                    detail.memberName = rs.getString("member_name");
                    detail.memberEmail = rs.getString("member_email");
                    detail.bookId = rs.getInt("book_id");
                    detail.bookTitle = rs.getString("book_title");
                    detail.isbn = rs.getString("isbn");
                    detail.copyNumber = rs.getString("copy_number");
                    detail.borrowDate = rs.getDate("borrow_date");
                    detail.dueDate = rs.getDate("due_date");
                    detail.returnDate = rs.getDate("return_date");
                    detail.renewalCount = rs.getInt("renewal_count");
                    detail.transactionStatus = rs.getString("transaction_status");
                    detail.daysOverdue = rs.getInt("days_overdue");
                    results.add(detail);
                }
            }
        }
        return results;
    }

    /**
     * Create renewal request
     */
    public static class CreateRenewalRequestResult {
        public final boolean success;
        public final String message;
        public final Integer requestId;

        public CreateRenewalRequestResult(boolean success, String message, Integer requestId) {
            this.success = success;
            this.message = message;
            this.requestId = requestId;
        }
    }

    public CreateRenewalRequestResult createRenewalRequest(int transactionId, int userId) throws SQLException {
        // Verify transaction belongs to user
        BorrowingDetail transaction = getBorrowingById(transactionId);
        if (transaction == null) {
            return new CreateRenewalRequestResult(false, "Transaction not found.", null);
        }
        if (transaction.userId != userId) {
            return new CreateRenewalRequestResult(false, "You can only request renewal for your own transactions.", null);
        }
        if (!"borrowed".equals(transaction.transactionStatus) && !"overdue".equals(transaction.transactionStatus)) {
            return new CreateRenewalRequestResult(false, "Only borrowed books can be renewed.", null);
        }

        // Check if there's already a pending request
        String checkSql = "SELECT request_id FROM Renewal_Requests " +
                         "WHERE transaction_id = ? AND request_status = 'pending'";
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CreateRenewalRequestResult(false, "You already have a pending renewal request for this book.", null);
                }
            }
        }

        // Create renewal request
        String insertSql = "INSERT INTO Renewal_Requests (transaction_id, user_id) VALUES (?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, transactionId);
            ps.setInt(2, userId);
            ps.executeUpdate();

            try (ResultSet gen = ps.getGeneratedKeys()) {
                if (gen.next()) {
                    int requestId = gen.getInt(1);
                    return new CreateRenewalRequestResult(true, "Renewal request submitted successfully.", requestId);
                }
            }
        }

        return new CreateRenewalRequestResult(false, "Failed to create renewal request.", null);
    }

    /**
     * Get renewal requests for a user
     */
    public static class RenewalRequestDetail {
        public int requestId;
        public int transactionId;
        public String bookTitle;
        public String isbn;
        public java.sql.Date borrowDate;
        public java.sql.Date dueDate;
        public int renewalCount;
        public java.sql.Timestamp requestDate;
        public String requestStatus;
        public java.sql.Timestamp processedDate;
        public String rejectionReason;
        public int maxRenewals;
    }

    public List<RenewalRequestDetail> getUserRenewalRequests(int userId) throws SQLException {
        List<RenewalRequestDetail> results = new ArrayList<>();
        String sql = "SELECT rr.request_id, rr.transaction_id, b.title as book_title, b.isbn, " +
                     "bt.borrow_date, bt.due_date, bt.renewal_count, rr.request_date, " +
                     "rr.request_status, rr.processed_date, rr.rejection_reason, " +
                     "(SELECT CAST(setting_value AS DECIMAL) FROM System_Settings WHERE setting_key = 'max_renewal_count') as max_renewals " +
                     "FROM Renewal_Requests rr " +
                     "JOIN Borrowing_Transactions bt ON rr.transaction_id = bt.transaction_id " +
                     "JOIN Book_Copies bc ON bt.copy_id = bc.copy_id " +
                     "JOIN Books b ON bc.book_id = b.book_id " +
                     "WHERE rr.user_id = ? " +
                     "ORDER BY rr.request_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RenewalRequestDetail detail = new RenewalRequestDetail();
                    detail.requestId = rs.getInt("request_id");
                    detail.transactionId = rs.getInt("transaction_id");
                    detail.bookTitle = rs.getString("book_title");
                    detail.isbn = rs.getString("isbn");
                    detail.borrowDate = rs.getDate("borrow_date");
                    detail.dueDate = rs.getDate("due_date");
                    detail.renewalCount = rs.getInt("renewal_count");
                    detail.requestDate = rs.getTimestamp("request_date");
                    detail.requestStatus = rs.getString("request_status");
                    detail.processedDate = rs.getTimestamp("processed_date");
                    detail.rejectionReason = rs.getString("rejection_reason");
                    detail.maxRenewals = rs.getInt("max_renewals");
                    results.add(detail);
                }
            }
        }
        return results;
    }
}

