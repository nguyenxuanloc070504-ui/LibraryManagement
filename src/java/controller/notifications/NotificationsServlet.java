package controller.notifications;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import dal.DBContext;

@WebServlet(name = "NotificationsServlet", urlPatterns = {"/notifications"})
public class NotificationsServlet extends HttpServlet {

    public static class Item {
        public int id;
        public String type;
        public String title;
        public String message;
        public boolean isRead;
        public Timestamp sentDate;
        public Integer ref;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int page = 1;
        int size = 10;
        try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
        try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
        if (page < 1) page = 1;
        if (size < 5) size = 5; if (size > 50) size = 50;
        int offset = (page - 1) * size;

        int total = 0;
        List<Item> items = new ArrayList<>();
        DBContext db = new DBContext() {};
        String countSql = "SELECT COUNT(*) FROM Notifications WHERE user_id=?";
        String pageSql = "SELECT notification_id, notification_type, title, message, is_read, sent_date, reference_id " +
                "FROM Notifications WHERE user_id=? ORDER BY sent_date DESC LIMIT ? OFFSET ?";
        try (Connection conn = db.getConnection()) {
            try (PreparedStatement cps = conn.prepareStatement(countSql)) {
                cps.setInt(1, userId);
                try (ResultSet crs = cps.executeQuery()) {
                    if (crs.next()) total = crs.getInt(1);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(pageSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, size);
                ps.setInt(3, offset);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Item it = new Item();
                        it.id = rs.getInt("notification_id");
                        it.type = rs.getString("notification_type");
                        it.title = rs.getString("title");
                        it.message = rs.getString("message");
                        it.isRead = rs.getBoolean("is_read");
                        it.sentDate = rs.getTimestamp("sent_date");
                        Object r = rs.getObject("reference_id");
                        it.ref = (r == null) ? null : rs.getInt("reference_id");
                        items.add(it);
                    }
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            db.close();
        }

        int totalPages = (int) Math.ceil(total / (double) size);
        request.setAttribute("items", items);
        request.setAttribute("page", page);
        request.setAttribute("size", size);
        request.setAttribute("total", total);
        request.setAttribute("totalPages", totalPages);
        request.getRequestDispatcher("/notifications/notifications.jsp").forward(request, response);
    }
}


