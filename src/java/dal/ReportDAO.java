package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO extends DBContext {

    /**
     * Dashboard statistics
     */
    public static class DashboardStats {
        public int totalBooks;
        public int availableCopies;
        public int totalMembers;
        public int currentBorrows;
        public int overdueBooks;
        public int activeReservations;
        public java.math.BigDecimal totalUnpaidFines;
        public int pendingRenewalRequests;
    }

    public DashboardStats getDashboardStatistics() throws SQLException {
        DashboardStats stats = new DashboardStats();
        try (CallableStatement cs = connection.prepareCall("CALL sp_dashboard_statistics()")) {
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        stats.totalBooks = rs.getInt("total_books");
                        stats.availableCopies = rs.getInt("available_copies");
                        stats.totalMembers = rs.getInt("total_members");
                        stats.currentBorrows = rs.getInt("current_borrows");
                        stats.overdueBooks = rs.getInt("overdue_books");
                        stats.activeReservations = rs.getInt("active_reservations");
                        stats.totalUnpaidFines = rs.getBigDecimal("total_unpaid_fines");
                        stats.pendingRenewalRequests = rs.getInt("pending_renewal_requests");
                    }
                }
            }
        }
        return stats;
    }

    /**
     * Popular books report
     */
    public static class PopularBook {
        public int bookId;
        public String title;
        public String isbn;
        public String categoryName;
        public String authors;
        public int totalBorrows;
        public int borrowsLastMonth;
        public int currentReservations;
        public double avgBorrowDuration;
    }

    public List<PopularBook> getPopularBooks(int periodDays, int limit) throws SQLException {
        List<PopularBook> results = new ArrayList<>();
        try (CallableStatement cs = connection.prepareCall("CALL sp_most_borrowed_books(?, ?)")) {
            cs.setInt(1, periodDays);
            cs.setInt(2, limit);
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        PopularBook book = new PopularBook();
                        book.bookId = rs.getInt("book_id");
                        book.title = rs.getString("title");
                        book.isbn = rs.getString("isbn");
                        book.categoryName = rs.getString("category_name");
                        book.authors = rs.getString("authors");
                        book.totalBorrows = rs.getInt("borrow_count");
                        book.borrowsLastMonth = rs.getInt("borrows_last_month");
                        book.currentReservations = rs.getInt("current_reservations");
                        book.avgBorrowDuration = rs.getDouble("avg_borrow_duration");
                        results.add(book);
                    }
                }
            }
        }
        return results;
    }

    /**
     * Most active members report
     */
    public static class ActiveMember {
        public int userId;
        public String fullName;
        public String email;
        public String phone;
        public String membershipType;
        public int totalBorrows;
        public int returnedCount;
        public int overdueCount;
        public java.math.BigDecimal totalFines;
    }

    public List<ActiveMember> getMostActiveMembers(int periodDays, int limit) throws SQLException {
        List<ActiveMember> results = new ArrayList<>();
        try (CallableStatement cs = connection.prepareCall("CALL sp_most_active_members(?, ?)")) {
            cs.setInt(1, periodDays);
            cs.setInt(2, limit);
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        ActiveMember member = new ActiveMember();
                        member.userId = rs.getInt("user_id");
                        member.fullName = rs.getString("full_name");
                        member.email = rs.getString("email");
                        member.phone = rs.getString("phone");
                        member.membershipType = rs.getString("membership_type");
                        member.totalBorrows = rs.getInt("total_borrows");
                        member.returnedCount = rs.getInt("returned_count");
                        member.overdueCount = rs.getInt("overdue_count");
                        member.totalFines = rs.getBigDecimal("total_fines");
                        results.add(member);
                    }
                }
            }
        }
        return results;
    }

    /**
     * Fine revenue report
     */
    public static class FineRevenue {
        public java.sql.Date date;
        public int totalFines;
        public java.math.BigDecimal totalAmount;
        public java.math.BigDecimal collectedAmount;
        public java.math.BigDecimal pendingAmount;
        public java.math.BigDecimal waivedAmount;
        public java.math.BigDecimal avgFineAmount;
    }

    public List<FineRevenue> getFineRevenueReport(java.sql.Date startDate, java.sql.Date endDate) throws SQLException {
        List<FineRevenue> results = new ArrayList<>();
        try (CallableStatement cs = connection.prepareCall("CALL sp_fine_revenue_report(?, ?)")) {
            cs.setDate(1, startDate);
            cs.setDate(2, endDate);
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        FineRevenue revenue = new FineRevenue();
                        revenue.date = rs.getDate("date");
                        revenue.totalFines = rs.getInt("total_fines");
                        revenue.totalAmount = rs.getBigDecimal("total_amount");
                        revenue.collectedAmount = rs.getBigDecimal("collected_amount");
                        revenue.pendingAmount = rs.getBigDecimal("pending_amount");
                        revenue.waivedAmount = rs.getBigDecimal("waived_amount");
                        revenue.avgFineAmount = rs.getBigDecimal("avg_fine_amount");
                        results.add(revenue);
                    }
                }
            }
        }
        return results;
    }

    /**
     * Category statistics
     */
    public static class CategoryStat {
        public int categoryId;
        public String categoryName;
        public int totalBooks;
        public int availableCopies;
        public int totalBorrows;
        public int borrowsLastMonth;
    }

    public List<CategoryStat> getCategoryStatistics() throws SQLException {
        List<CategoryStat> results = new ArrayList<>();
        try (CallableStatement cs = connection.prepareCall("CALL sp_category_statistics()")) {
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        CategoryStat stat = new CategoryStat();
                        stat.categoryId = rs.getInt("category_id");
                        stat.categoryName = rs.getString("category_name");
                        stat.totalBooks = rs.getInt("total_books");
                        stat.availableCopies = rs.getInt("available_copies");
                        stat.totalBorrows = rs.getInt("total_borrows");
                        stat.borrowsLastMonth = rs.getInt("borrows_last_month");
                        results.add(stat);
                    }
                }
            }
        }
        return results;
    }

    /**
     * Get overdue books from view
     */
    public static class OverdueBookDetail {
        public int transactionId;
        public int userId;
        public String memberName;
        public String email;
        public String phone;
        public String address;
        public int bookId;
        public String bookTitle;
        public String isbn;
        public String copyNumber;
        public java.sql.Date borrowDate;
        public java.sql.Date dueDate;
        public int daysOverdue;
        public java.math.BigDecimal calculatedFine;
        public java.math.BigDecimal recordedFine;
        public String fineStatus;
    }

    public List<OverdueBookDetail> getOverdueBooks() throws SQLException {
        List<OverdueBookDetail> results = new ArrayList<>();
        String sql = "SELECT * FROM vw_Overdue_Books";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                OverdueBookDetail detail = new OverdueBookDetail();
                detail.transactionId = rs.getInt("transaction_id");
                detail.userId = rs.getInt("user_id");
                detail.memberName = rs.getString("member_name");
                detail.email = rs.getString("email");
                detail.phone = rs.getString("phone");
                detail.address = rs.getString("address");
                detail.bookId = rs.getInt("book_id");
                detail.bookTitle = rs.getString("book_title");
                detail.isbn = rs.getString("isbn");
                detail.copyNumber = rs.getString("copy_number");
                detail.borrowDate = rs.getDate("borrow_date");
                detail.dueDate = rs.getDate("due_date");
                detail.daysOverdue = rs.getInt("days_overdue");
                detail.calculatedFine = rs.getBigDecimal("calculated_fine");
                detail.recordedFine = rs.getBigDecimal("recorded_fine");
                detail.fineStatus = rs.getString("fine_status");
                results.add(detail);
            }
        }
        return results;
    }

    /**
     * Send due date reminders using stored procedure
     */
    public int sendDueDateReminders() throws SQLException {
        try (CallableStatement cs = connection.prepareCall("CALL sp_send_due_date_reminders()")) {
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        return rs.getInt("reminders_sent");
                    }
                }
            }
        }
        return 0;
    }

    /**
     * Mark overdue books using stored procedure
     */
    public int markOverdueBooks() throws SQLException {
        try (CallableStatement cs = connection.prepareCall("CALL sp_mark_overdue_books()")) {
            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        return rs.getInt("books_marked_overdue");
                    }
                }
            }
        }
        return 0;
    }
}

