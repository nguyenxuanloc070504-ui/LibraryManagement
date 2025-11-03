package controller.personal;

import dal.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "MarkNotificationReadServlet", urlPatterns = {"/personal/mark-notification-read"})
public class MarkNotificationReadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.getSession().setAttribute("error", "Please login to mark notifications as read.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String notificationIdParam = request.getParameter("notification_id");
        String action = request.getParameter("action"); // "read" or "read_all"

        NotificationDAO dao = new NotificationDAO();
        try {
            if ("read_all".equals(action)) {
                dao.markAllAsRead(userId);
                request.getSession().setAttribute("success", "All notifications marked as read.");
            } else if (notificationIdParam != null && !notificationIdParam.trim().isEmpty()) {
                int notificationId = Integer.parseInt(notificationIdParam);
                if (dao.markAsRead(notificationId, userId)) {
                    request.getSession().setAttribute("success", "Notification marked as read.");
                } else {
                    request.getSession().setAttribute("error", "Failed to mark notification as read.");
                }
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid notification ID.");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/personal/notifications");
        }
    }
}

