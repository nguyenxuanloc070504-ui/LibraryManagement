package controller.transaction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import dal.DBContext;

@WebServlet(name = "ScheduleReturnServlet", urlPatterns = {"/transaction/schedule-return"})
public class ScheduleReturnServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("authUserId") : null;

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String transactionIdStr = request.getParameter("transaction_id");
        String scheduledDateStr = request.getParameter("scheduled_datetime"); // HTML datetime-local

        Integer transactionId = null;
        try {
            transactionId = Integer.parseInt(transactionIdStr);
        } catch (Exception ignored) {}

        if (transactionId == null || scheduledDateStr == null || scheduledDateStr.trim().isEmpty()) {
            session.setAttribute("error", "Please select a valid date/time to schedule return.");
            response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
            return;
        }

        // Parse datetime-local (e.g., 2025-11-05T14:30) to Timestamp
        Timestamp scheduledTs;
        try {
            LocalDateTime ldt = LocalDateTime.parse(scheduledDateStr, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
            scheduledTs = Timestamp.valueOf(ldt);
        } catch (Exception e) {
            session.setAttribute("error", "Invalid date format.");
            response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
            return;
        }

        DBContext db = new DBContext() {};
        try (Connection conn = db.getConnection()) {
            // Validate scheduled date <= due date (end of day)
            java.sql.Date dueDate = null;
            try (PreparedStatement dps = conn.prepareStatement("SELECT due_date FROM Borrowing_Transactions WHERE transaction_id=? AND user_id=? AND return_date IS NULL")) {
                dps.setInt(1, transactionId);
                dps.setInt(2, userId);
                try (ResultSet drs = dps.executeQuery()) {
                    if (drs.next()) {
                        dueDate = drs.getDate(1);
                    }
                }
            }
            if (dueDate == null) {
                session.setAttribute("error", "Transaction not found or already returned.");
                response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
                return;
            }
            // End of due date day 23:59:59
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(dueDate);
            cal.set(java.util.Calendar.HOUR_OF_DAY, 23);
            cal.set(java.util.Calendar.MINUTE, 59);
            cal.set(java.util.Calendar.SECOND, 59);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            Timestamp dueEndTs = new Timestamp(cal.getTimeInMillis());
            if (scheduledTs.after(dueEndTs)) {
                session.setAttribute("error", "Scheduled return must be on or before the due date.");
                response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
                return;
            }

            try (CallableStatement cs = conn.prepareCall("{CALL sp_schedule_return(?, ?, ?, ?, ?)}")) {
                cs.setInt(1, transactionId);
                cs.setInt(2, userId);
                cs.setTimestamp(3, scheduledTs);
                cs.registerOutParameter(4, Types.VARCHAR); // p_result
                cs.registerOutParameter(5, Types.INTEGER); // p_schedule_id
                cs.execute();
                String result = cs.getString(4);
                if (result != null && result.startsWith("Success")) {
                    session.setAttribute("success", result);
                } else {
                    session.setAttribute("error", result != null ? result : "Schedule failed");
                }
            }
        } catch (SQLException e) {
            session.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        response.sendRedirect(request.getContextPath() + "/transaction/my-borrowings");
    }
}


