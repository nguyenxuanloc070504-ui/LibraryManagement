package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO extends DBContext {

    /**
     * Create reservation
     */
    public static class CreateReservationResult {
        public final boolean success;
        public final String message;
        public final Integer reservationId;

        public CreateReservationResult(boolean success, String message, Integer reservationId) {
            this.success = success;
            this.message = message;
            this.reservationId = reservationId;
        }
    }

    public CreateReservationResult createReservation(int bookId, int userId) throws SQLException {
        // Check if user already has an active reservation for this book
        String checkSql = "SELECT reservation_id FROM Reservations " +
                         "WHERE book_id = ? AND user_id = ? AND reservation_status = 'active'";
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new CreateReservationResult(false, "You already have an active reservation for this book.", null);
                }
            }
        }

        // Check if book has available copies (no need to reserve if available)
        String availableSql = "SELECT COUNT(*) as count FROM Book_Copies " +
                             "WHERE book_id = ? AND availability_status = 'available'";
        try (PreparedStatement ps = connection.prepareStatement(availableSql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("count") > 0) {
                    return new CreateReservationResult(false, "Book is currently available. No reservation needed.", null);
                }
            }
        }

        // Get reservation expiry days from settings (default 7 days)
        String settingsSql = "SELECT CAST(setting_value AS DECIMAL) as expiry_days " +
                            "FROM System_Settings WHERE setting_key = 'reservation_expiry_days'";
        int expiryDays = 7;
        try (PreparedStatement ps = connection.prepareStatement(settingsSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                expiryDays = rs.getInt("expiry_days");
            }
        }

        // Calculate expiry date
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.add(java.util.Calendar.DAY_OF_MONTH, expiryDays);
        Timestamp expiryDate = new Timestamp(cal.getTimeInMillis());

        // Create reservation
        String insertSql = "INSERT INTO Reservations (book_id, user_id, expiry_date) VALUES (?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);
            ps.setTimestamp(3, expiryDate);
            ps.executeUpdate();

            try (ResultSet gen = ps.getGeneratedKeys()) {
                if (gen.next()) {
                    int reservationId = gen.getInt(1);
                    return new CreateReservationResult(true, "Reservation created successfully.", reservationId);
                }
            }
        }

        return new CreateReservationResult(false, "Failed to create reservation.", null);
    }

    /**
     * Cancel reservation
     */
    public boolean cancelReservation(int reservationId, int userId) throws SQLException {
        // Verify reservation belongs to user and is active
        String sql = "UPDATE Reservations SET reservation_status = 'cancelled' " +
                    "WHERE reservation_id = ? AND user_id = ? AND reservation_status = 'active'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get user's reservations
     */
    public static class ReservationDetail {
        public int reservationId;
        public int bookId;
        public String bookTitle;
        public String isbn;
        public String authors;
        public String categoryName;
        public Timestamp reservationDate;
        public Timestamp expiryDate;
        public String reservationStatus;
        public boolean notified;
        public int availableCopies;
    }

    public List<ReservationDetail> getUserReservations(int userId) throws SQLException {
        List<ReservationDetail> results = new ArrayList<>();
        String sql = "SELECT r.reservation_id, r.book_id, b.title as book_title, b.isbn, " +
                    "GROUP_CONCAT(DISTINCT a.author_name ORDER BY ba.author_order SEPARATOR ', ') as authors, " +
                    "c.category_name, r.reservation_date, r.expiry_date, r.reservation_status, " +
                    "r.notified, " +
                    "SUM(CASE WHEN bc.availability_status = 'available' THEN 1 ELSE 0 END) as available_copies " +
                    "FROM Reservations r " +
                    "JOIN Books b ON r.book_id = b.book_id " +
                    "LEFT JOIN Categories c ON b.category_id = c.category_id " +
                    "LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id " +
                    "LEFT JOIN Authors a ON ba.author_id = a.author_id " +
                    "LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id " +
                    "WHERE r.user_id = ? " +
                    "GROUP BY r.reservation_id, r.book_id, b.title, b.isbn, c.category_name, " +
                    "r.reservation_date, r.expiry_date, r.reservation_status, r.notified " +
                    "ORDER BY r.reservation_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReservationDetail detail = new ReservationDetail();
                    detail.reservationId = rs.getInt("reservation_id");
                    detail.bookId = rs.getInt("book_id");
                    detail.bookTitle = rs.getString("book_title");
                    detail.isbn = rs.getString("isbn");
                    detail.authors = rs.getString("authors");
                    detail.categoryName = rs.getString("category_name");
                    detail.reservationDate = rs.getTimestamp("reservation_date");
                    detail.expiryDate = rs.getTimestamp("expiry_date");
                    detail.reservationStatus = rs.getString("reservation_status");
                    detail.notified = rs.getBoolean("notified");
                    detail.availableCopies = rs.getInt("available_copies");
                    results.add(detail);
                }
            }
        }
        return results;
    }

    /**
     * Check if user has reservation for book
     */
    public boolean hasActiveReservation(int bookId, int userId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Reservations " +
                    "WHERE book_id = ? AND user_id = ? AND reservation_status = 'active'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        }
        return false;
    }
}

