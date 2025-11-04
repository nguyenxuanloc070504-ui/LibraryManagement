package controller.notifications;

import dal.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet(name = "NotificationDetailServlet", urlPatterns = {"/notifications/detail"})
public class NotificationDetailServlet extends HttpServlet {

    public static class DetailItem {
        public int id;
        public String type;
        public String title;
        public String message;
        public boolean isRead;
        public Timestamp sentDate;
        public Integer referenceId;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/notifications");
            return;
        }

        DBContext db = new DBContext() {};
        DetailItem item = null;
        try (Connection conn = db.getConnection()) {
            String sql = "SELECT notification_id, notification_type, title, message, is_read, sent_date, reference_id " +
                         "FROM Notifications WHERE notification_id=? AND user_id=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(idStr));
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        item = new DetailItem();
                        item.id = rs.getInt("notification_id");
                        item.type = rs.getString("notification_type");
                        item.title = rs.getString("title");
                        item.message = rs.getString("message");
                        item.isRead = rs.getBoolean("is_read");
                        item.sentDate = rs.getTimestamp("sent_date");
                        Object ref = rs.getObject("reference_id");
                        item.referenceId = (ref == null) ? null : rs.getInt("reference_id");
                    }
                }
            }

            // Mark as read when opened
            if (item != null && !item.isRead) {
                try (PreparedStatement ups = conn.prepareStatement("UPDATE Notifications SET is_read=TRUE WHERE notification_id=? AND user_id=?")) {
                    ups.setInt(1, item.id);
                    ups.setInt(2, userId);
                    ups.executeUpdate();
                    item.isRead = true;
                }
            }
        } catch (SQLException | NumberFormatException e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        if (item == null) {
            request.setAttribute("error", "Notification not found");
            response.sendRedirect(request.getContextPath() + "/notifications");
            return;
        }

        request.setAttribute("item", item);
        request.getRequestDispatcher("/notifications/notification-detail.jsp").forward(request, response);
    }
}


