package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO extends DBContext {

    /**
     * Notification detail
     */
    public static class NotificationDetail {
        public int notificationId;
        public String notificationType;
        public String title;
        public String message;
        public boolean isRead;
        public Timestamp sentDate;
        public Integer referenceId;
    }

    /**
     * Get all notifications for a user
     */
    public List<NotificationDetail> getUserNotifications(int userId, Boolean unreadOnly) throws SQLException {
        List<NotificationDetail> results = new ArrayList<>();
        String sql = "SELECT notification_id, notification_type, title, message, is_read, " +
                     "sent_date, reference_id " +
                     "FROM Notifications " +
                     "WHERE user_id = ? " +
                     (unreadOnly != null && unreadOnly ? "AND is_read = FALSE " : "") +
                     "ORDER BY sent_date DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NotificationDetail detail = new NotificationDetail();
                    detail.notificationId = rs.getInt("notification_id");
                    detail.notificationType = rs.getString("notification_type");
                    detail.title = rs.getString("title");
                    detail.message = rs.getString("message");
                    detail.isRead = rs.getBoolean("is_read");
                    detail.sentDate = rs.getTimestamp("sent_date");
                    Integer refId = rs.getInt("reference_id");
                    detail.referenceId = rs.wasNull() ? null : refId;
                    results.add(detail);
                }
            }
        }
        return results;
    }

    /**
     * Mark notification as read
     */
    public boolean markAsRead(int notificationId, int userId) throws SQLException {
        String sql = "UPDATE Notifications SET is_read = TRUE " +
                     "WHERE notification_id = ? AND user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Mark all notifications as read for a user
     */
    public boolean markAllAsRead(int userId) throws SQLException {
        String sql = "UPDATE Notifications SET is_read = TRUE WHERE user_id = ? AND is_read = FALSE";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Get unread notification count
     */
    public int getUnreadCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Notifications " +
                     "WHERE user_id = ? AND is_read = FALSE";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        return 0;
    }

    /**
     * Delete notification
     */
    public boolean deleteNotification(int notificationId, int userId) throws SQLException {
        String sql = "DELETE FROM Notifications WHERE notification_id = ? AND user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }
}

