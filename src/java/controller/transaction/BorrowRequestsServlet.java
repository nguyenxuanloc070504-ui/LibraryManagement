package controller.transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import dal.DBContext;

@WebServlet(name = "BorrowRequestsServlet", urlPatterns = {"/transaction/requests"})
public class BorrowRequestsServlet extends HttpServlet {

    public static class PendingRequest {
        public int requestId;
        public Timestamp requestDate;
        public String memberName;
        public String email;
        public String phone;
        public int bookId;
        public String bookTitle;
        public String isbn;
        public String authors;
        public int availableCopies;
        public String approvalStatus;

        // JavaBean getters for JSP EL
        public int getRequestId() { return requestId; }
        public Timestamp getRequestDate() { return requestDate; }
        public String getMemberName() { return memberName; }
        public String getEmail() { return email; }
        public String getPhone() { return phone; }
        public int getBookId() { return bookId; }
        public String getBookTitle() { return bookTitle; }
        public String getIsbn() { return isbn; }
        public String getAuthors() { return authors; }
        public int getAvailableCopies() { return availableCopies; }
        public String getApprovalStatus() { return approvalStatus; }
    }

    public static class ApprovedAwaitingPickup {
        public int requestId;
        public Timestamp pickupReadyDate;
        public Timestamp pickupExpiryDate;
        public String memberName;
        public String email;
        public String phone;
        public String bookTitle;
        public String isbn;
        public String copyNumber;

        // JavaBean getters for JSP EL
        public int getRequestId() { return requestId; }
        public Timestamp getPickupReadyDate() { return pickupReadyDate; }
        public Timestamp getPickupExpiryDate() { return pickupExpiryDate; }
        public String getMemberName() { return memberName; }
        public String getEmail() { return email; }
        public String getPhone() { return phone; }
        public String getBookTitle() { return bookTitle; }
        public String getIsbn() { return isbn; }
        public String getCopyNumber() { return copyNumber; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("authRole") : null;
        if (role == null || !"Librarian".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<java.util.Map<String, Object>> items = new ArrayList<>();
        List<java.util.Map<String, Object>> awaiting = new ArrayList<>();
        DBContext db = new DBContext() {};
        String sql = "SELECT br.request_id, br.request_date, u.full_name, u.email, u.phone, b.book_id, b.title, b.isbn, " +
                "(SELECT GROUP_CONCAT(a.author_name SEPARATOR ', ') FROM Book_Authors ba JOIN Authors a ON ba.author_id=a.author_id WHERE ba.book_id=b.book_id) as authors, " +
                "(SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id=b.book_id AND bc.availability_status='available') as available_copies, " +
                "CASE WHEN NOT fn_check_membership_valid(u.user_id) THEN 'Membership expired' " +
                "WHEN NOT fn_check_borrow_limit(u.user_id) THEN 'Borrow limit reached' " +
                "WHEN (SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id=b.book_id AND bc.availability_status='available') = 0 THEN 'No available copies' " +
                "ELSE 'Ready to approve' END as approval_status " +
                "FROM Borrow_Requests br JOIN Users u ON br.user_id=u.user_id JOIN Books b ON br.book_id=b.book_id WHERE br.request_status='pending' ORDER BY br.request_date ASC";
        try (Connection conn = db.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("requestId", rs.getInt("request_id"));
                    row.put("requestDate", rs.getTimestamp("request_date"));
                    row.put("memberName", rs.getString("full_name"));
                    row.put("email", rs.getString("email"));
                    row.put("phone", rs.getString("phone"));
                    row.put("bookId", rs.getInt("book_id"));
                    row.put("bookTitle", rs.getString("title"));
                    row.put("isbn", rs.getString("isbn"));
                    row.put("authors", rs.getString("authors"));
                    row.put("availableCopies", rs.getInt("available_copies"));
                    row.put("approvalStatus", rs.getString("approval_status"));
                    items.add(row);
                }
            }

            String approvedSql = "SELECT br.request_id, br.pickup_ready_date, br.pickup_expiry_date, u.full_name, u.email, u.phone, b.title, b.isbn, bc.copy_number " +
                    "FROM Borrow_Requests br JOIN Users u ON br.user_id=u.user_id JOIN Books b ON br.book_id=b.book_id JOIN Book_Copies bc ON br.copy_id=bc.copy_id " +
                    "WHERE br.request_status='approved' AND br.actual_pickup_date IS NULL ORDER BY br.pickup_ready_date ASC";
            try (PreparedStatement ps2 = conn.prepareStatement(approvedSql); ResultSet rs2 = ps2.executeQuery()) {
                while (rs2.next()) {
                    java.util.Map<String, Object> row = new java.util.HashMap<>();
                    row.put("requestId", rs2.getInt("request_id"));
                    row.put("pickupReadyDate", rs2.getTimestamp("pickup_ready_date"));
                    row.put("pickupExpiryDate", rs2.getTimestamp("pickup_expiry_date"));
                    row.put("memberName", rs2.getString("full_name"));
                    row.put("email", rs2.getString("email"));
                    row.put("phone", rs2.getString("phone"));
                    row.put("bookTitle", rs2.getString("title"));
                    row.put("isbn", rs2.getString("isbn"));
                    row.put("copyNumber", rs2.getString("copy_number"));
                    awaiting.add(row);
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        request.setAttribute("requests", items);
        request.setAttribute("awaiting", awaiting);
        request.getRequestDispatcher("/transaction/borrow-requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Integer librarianId = (session != null) ? (Integer) session.getAttribute("authUserId") : null;
        String role = (session != null) ? (String) session.getAttribute("authRole") : null;
        if (librarianId == null || role == null || !"Librarian".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        int requestId = Integer.parseInt(request.getParameter("request_id"));

        DBContext db = new DBContext() {};
        try (Connection conn = db.getConnection()) {
            // DB-level procedures/triggers handle notifications
            if ("approve".equalsIgnoreCase(action)) {
                try (CallableStatement cs = conn.prepareCall("{CALL sp_approve_borrow_request(?, ?, ?)}")) {
                    cs.setInt(1, requestId);
                    cs.setInt(2, librarianId);
                    cs.registerOutParameter(3, Types.VARCHAR);
                    cs.execute();
                    String result = cs.getString(3);
                    session.setAttribute(result != null && result.startsWith("Success") ? "success" : "error", result);
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                String reason = request.getParameter("reason");
                try (PreparedStatement ps = conn.prepareStatement("UPDATE Borrow_Requests SET request_status='rejected', rejection_reason=?, processed_by=?, processed_date=NOW() WHERE request_id=? AND request_status='pending'")) {
                    ps.setString(1, reason);
                    ps.setInt(2, librarianId);
                    ps.setInt(3, requestId);
                    int updated = ps.executeUpdate();
                    session.setAttribute(updated > 0 ? "success" : "error", updated > 0 ? "Request rejected" : "Failed to reject");
                }
            } else if ("confirm_pickup".equalsIgnoreCase(action)) {
                try (CallableStatement cs = conn.prepareCall("{CALL sp_confirm_book_pickup(?, ?, ?, ?)}")) {
                    cs.setInt(1, requestId);
                    cs.setInt(2, librarianId);
                    cs.registerOutParameter(3, Types.VARCHAR);
                    cs.registerOutParameter(4, Types.INTEGER);
                    cs.execute();
                    String result = cs.getString(3);
                    session.setAttribute(result != null && result.startsWith("Success") ? "success" : "error", result);
                }
            }
        } catch (SQLException e) {
            session.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        response.sendRedirect(request.getContextPath() + "/transaction/requests");
    }

    
}


