package controller.personal;

import dal.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ViewNotificationsServlet", urlPatterns = {"/personal/notifications"})
public class ViewNotificationsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to view notifications.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        NotificationDAO dao = new NotificationDAO();
        try {
            String filter = request.getParameter("filter");
            Boolean unreadOnly = "unread".equals(filter) ? true : null;
            
            request.setAttribute("notifications", dao.getUserNotifications(userId, unreadOnly));
            request.setAttribute("unreadCount", dao.getUnreadCount(userId));
            request.setAttribute("filter", filter);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        request.getRequestDispatcher("/personal/notifications.jsp").forward(request, response);
    }
}

