package dal;

import java.sql.*;

public class BorrowRequestDAO extends DBContext {

    /**
     * Check if user has a pending or approved borrow request for a book
     */
    public boolean hasPendingRequest(int bookId, int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Borrow_Requests " +
                    "WHERE book_id = ? AND user_id = ? " +
                    "AND request_status IN ('pending', 'approved') " +
                    "AND (actual_pickup_date IS NULL OR actual_pickup_date > NOW())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * List borrow requests for a user (member view)
     */
    public java.util.List<UserBorrowRequest> getUserBorrowRequests(int userId) throws SQLException {
        java.util.List<UserBorrowRequest> results = new java.util.ArrayList<>();
        String sql = "SELECT br.request_id, br.request_status, br.request_date, " +
                     "br.pickup_ready_date, br.pickup_expiry_date, " +
                     "b.book_id, b.title as book_title, b.isbn " +
                     "FROM Borrow_Requests br " +
                     "JOIN Books b ON br.book_id = b.book_id " +
                     "WHERE br.user_id = ? " +
                     "ORDER BY br.request_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserBorrowRequest r = new UserBorrowRequest();
                    r.requestId = rs.getInt("request_id");
                    r.requestStatus = rs.getString("request_status");
                    r.requestDate = rs.getTimestamp("request_date");
                    r.pickupReadyDate = rs.getTimestamp("pickup_ready_date");
                    r.pickupExpiryDate = rs.getTimestamp("pickup_expiry_date");
                    r.bookId = rs.getInt("book_id");
                    r.bookTitle = rs.getString("book_title");
                    r.isbn = rs.getString("isbn");
                    results.add(r);
                }
            }
        }
        return results;
    }

    /**
     * Get pending request details for a user and book
     */
    public BorrowRequestDetail getPendingRequest(int bookId, int userId) throws SQLException {
        String sql = "SELECT request_id, request_status, request_date, pickup_ready_date, pickup_expiry_date " +
                    "FROM Borrow_Requests " +
                    "WHERE book_id = ? AND user_id = ? " +
                    "AND request_status IN ('pending', 'approved') " +
                    "AND (actual_pickup_date IS NULL OR actual_pickup_date > NOW()) " +
                    "ORDER BY request_date DESC LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BorrowRequestDetail detail = new BorrowRequestDetail();
                    detail.requestId = rs.getInt("request_id");
                    detail.requestStatus = rs.getString("request_status");
                    detail.requestDate = rs.getTimestamp("request_date");
                    detail.pickupReadyDate = rs.getTimestamp("pickup_ready_date");
                    detail.pickupExpiryDate = rs.getTimestamp("pickup_expiry_date");
                    return detail;
                }
            }
        }
        return null;
    }

    /**
     * Create a borrow request (alternative to stored procedure)
     */
    public CreateRequestResult createBorrowRequest(int bookId, int userId) throws SQLException {
        CreateRequestResult result = new CreateRequestResult();

        try {
            connection.setAutoCommit(false);

            // Check membership validity
            String membershipSql = "SELECT expiry_date >= CURDATE() AND is_active = TRUE AS is_valid " +
                                  "FROM Memberships WHERE user_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(membershipSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next() || !rs.getBoolean("is_valid")) {
                        result.success = false;
                        result.message = "Error: Membership expired or inactive";
                        connection.rollback();
                        return result;
                    }
                }
            }

            // Check if already has pending request for this book
            if (hasPendingRequest(bookId, userId)) {
                result.success = false;
                result.message = "Error: You already have a pending request for this book";
                connection.rollback();
                return result;
            }

            // Check pending request limit (max 3)
            String requestLimitSql = "SELECT COUNT(*) FROM Borrow_Requests " +
                                    "WHERE user_id = ? AND request_status IN ('pending', 'approved')";
            try (PreparedStatement ps = connection.prepareStatement(requestLimitSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) >= 3) {
                        result.success = false;
                        result.message = "Error: Maximum pending requests reached";
                        connection.rollback();
                        return result;
                    }
                }
            }

            // Check borrow limit
            String borrowLimitSql = "SELECT COUNT(*) as current_borrows, m.max_books_allowed " +
                                   "FROM Borrowing_Transactions bt " +
                                   "JOIN Memberships m ON m.user_id = bt.user_id " +
                                   "WHERE bt.user_id = ? AND bt.transaction_status IN ('borrowed', 'overdue') " +
                                   "GROUP BY m.max_books_allowed";
            try (PreparedStatement ps = connection.prepareStatement(borrowLimitSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int currentBorrows = rs.getInt("current_borrows");
                        int maxAllowed = rs.getInt("max_books_allowed");
                        if (currentBorrows >= maxAllowed) {
                            result.success = false;
                            result.message = "Error: Borrow limit reached";
                            connection.rollback();
                            return result;
                        }
                    }
                }
            }

            // Check available copies
            String availableSql = "SELECT COUNT(*) FROM Book_Copies " +
                                 "WHERE book_id = ? AND availability_status = 'available'";
            try (PreparedStatement ps = connection.prepareStatement(availableSql)) {
                ps.setInt(1, bookId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        result.success = false;
                        result.message = "Error: No available copies. Please reserve this book instead.";
                        connection.rollback();
                        return result;
                    }
                }
            }

            // Create the borrow request
            String insertSql = "INSERT INTO Borrow_Requests (user_id, book_id, request_status) VALUES (?, ?, 'pending')";
            try (PreparedStatement ps = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, userId);
                ps.setInt(2, bookId);
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        result.requestId = rs.getInt(1);
                    }
                }
            }

            connection.commit();
            result.success = true;
            result.message = "Success: Borrow request created. Wait for librarian approval.";

        } catch (SQLException e) {
            connection.rollback();
            result.success = false;
            result.message = "Error: Request failed - " + e.getMessage();
            throw e;
        } finally {
            connection.setAutoCommit(true);
        }

        return result;
    }

    /**
     * Cancel a borrow request (only if pending)
     */
    public CancelResult cancelRequest(int requestId, int userId) throws SQLException {
        CancelResult result = new CancelResult();

        // First check if request belongs to user and is pending
        String checkSql = "SELECT request_status FROM Borrow_Requests " +
                         "WHERE request_id = ? AND user_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    result.success = false;
                    result.message = "Request not found or you don't have permission to cancel it.";
                    return result;
                }

                String status = rs.getString("request_status");
                if (!"pending".equalsIgnoreCase(status)) {
                    result.success = false;
                    result.message = "Only pending requests can be cancelled. Current status: " + status;
                    return result;
                }
            }
        }

        // Update request status to cancelled
        String updateSql = "UPDATE Borrow_Requests SET request_status = 'cancelled' " +
                          "WHERE request_id = ? AND user_id = ? AND request_status = 'pending'";

        try (PreparedStatement ps = connection.prepareStatement(updateSql)) {
            ps.setInt(1, requestId);
            ps.setInt(2, userId);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                result.success = true;
                result.message = "Borrow request cancelled successfully.";
            } else {
                result.success = false;
                result.message = "Failed to cancel request.";
            }
        }

        return result;
    }

    public void close() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Inner classes for return types
    public static class BorrowRequestDetail {
        public int requestId;
        public String requestStatus;
        public Timestamp requestDate;
        public Timestamp pickupReadyDate;
        public Timestamp pickupExpiryDate;
    }

    public static class UserBorrowRequest {
        public int requestId;
        public String requestStatus;
        public Timestamp requestDate;
        public Timestamp pickupReadyDate;
        public Timestamp pickupExpiryDate;
        public int bookId;
        public String bookTitle;
        public String isbn;
    }

    public static class CancelResult {
        public boolean success;
        public String message;
    }

    public static class CreateRequestResult {
        public boolean success;
        public String message;
        public Integer requestId;
    }
}
