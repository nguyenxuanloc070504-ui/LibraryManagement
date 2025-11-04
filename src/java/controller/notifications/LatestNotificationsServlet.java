package controller.notifications;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import dal.DBContext;

@WebServlet(name = "LatestNotificationsServlet", urlPatterns = {"/api/notifications/latest"})
public class LatestNotificationsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        response.setContentType("application/json;charset=UTF-8");
        if (userId == null) {
            response.getWriter().write("[]");
            return;
        }

        DBContext db = new DBContext() {};
        String sql = "SELECT notification_id, notification_type, title, message, is_read, sent_date, reference_id " +
                "FROM Notifications WHERE user_id=? ORDER BY sent_date DESC LIMIT 5";
        try (Connection conn = db.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery(); PrintWriter out = response.getWriter()) {
                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                while (rs.next()) {
                    if (!first) json.append(',');
                    first = false;
                    json.append('{')
                        .append("\"id\":").append(rs.getInt("notification_id")).append(',')
                        .append("\"type\":\"").append(escape(rs.getString("notification_type"))).append("\",")
                        .append("\"title\":\"").append(escape(rs.getString("title"))).append("\",")
                        .append("\"message\":\"").append(escape(rs.getString("message"))).append("\",")
                        .append("\"isRead\":").append(rs.getBoolean("is_read")).append(',')
                        .append("\"sentDate\":\"").append(escape(String.valueOf(rs.getTimestamp("sent_date")))).append("\",")
                        .append("\"ref\":").append(rs.getObject("reference_id") == null ? "null" : rs.getInt("reference_id"))
                        .append('}');
                }
                json.append(']');
                out.write(json.toString());
            }
        } catch (SQLException e) {
            response.getWriter().write("[]");
        } finally {
            db.close();
        }
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }
}


