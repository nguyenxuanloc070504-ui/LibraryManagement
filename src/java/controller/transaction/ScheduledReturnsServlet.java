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

@WebServlet(name = "ScheduledReturnsServlet", urlPatterns = {"/transaction/scheduled-returns"})
public class ScheduledReturnsServlet extends HttpServlet {

    public static class ScheduledItem {
        public int scheduleId;
        public Timestamp scheduledReturnDate;
        public boolean notificationSent;
        public int userId;
        public String memberName;
        public String email;
        public String phone;
        public String bookTitle;
        public Date borrowDate;
        public Date dueDate;
        public int transactionId;
        public String returnStatus;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("authRole") : null;
        if (role == null || !"Librarian".equalsIgnoreCase(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<ScheduledItem> items = new ArrayList<>();
        DBContext db = new DBContext() {};
        String sql = "SELECT schedule_id, scheduled_return_date, notification_sent, user_id, member_name, email, phone, book_title, borrow_date, due_date, transaction_id, return_status FROM vw_Scheduled_Returns ORDER BY scheduled_return_date ASC";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ScheduledItem si = new ScheduledItem();
                si.scheduleId = rs.getInt("schedule_id");
                si.scheduledReturnDate = rs.getTimestamp("scheduled_return_date");
                si.notificationSent = rs.getBoolean("notification_sent");
                si.userId = rs.getInt("user_id");
                si.memberName = rs.getString("member_name");
                si.email = rs.getString("email");
                si.phone = rs.getString("phone");
                si.bookTitle = rs.getString("book_title");
                si.borrowDate = rs.getDate("borrow_date");
                si.dueDate = rs.getDate("due_date");
                si.transactionId = rs.getInt("transaction_id");
                si.returnStatus = rs.getString("return_status");
                items.add(si);
            }
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        request.setAttribute("scheduled", items);
        request.getRequestDispatcher("/transaction/scheduled-returns.jsp").forward(request, response);
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
        if ("confirm_return".equalsIgnoreCase(action)) {
            int transactionId = Integer.parseInt(request.getParameter("transaction_id"));
            String condition = request.getParameter("condition_status");
            if (condition == null || condition.trim().isEmpty()) {
                condition = "good";
            }

            DBContext db = new DBContext() {};
            try (Connection conn = db.getConnection(); CallableStatement cs = conn.prepareCall("{CALL sp_return_book(?, ?, ?, ?)}")) {
                cs.setInt(1, transactionId);
                cs.setString(2, condition);
                cs.registerOutParameter(3, Types.VARCHAR);
                cs.registerOutParameter(4, Types.DECIMAL);
                cs.execute();
                String result = cs.getString(3);
                session.setAttribute(result != null && result.startsWith("Success") ? "success" : "error", result);
            } catch (SQLException e) {
                session.setAttribute("error", e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/transaction/scheduled-returns");
    }
}


