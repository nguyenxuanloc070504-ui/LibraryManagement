package controller.notifications;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

import dal.DBContext;

@WebServlet(name = "MarkReadServlet", urlPatterns = {"/notifications/mark-read"})
public class MarkReadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idStr = request.getParameter("id");
        String allStr = request.getParameter("all");

        DBContext db = new DBContext() {};
        try (Connection conn = db.getConnection()) {
            if ("true".equalsIgnoreCase(allStr)) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE Notifications SET is_read=TRUE WHERE user_id=? AND is_read=FALSE")) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            } else {
                int id = Integer.parseInt(idStr);
                try (PreparedStatement ps = conn.prepareStatement("UPDATE Notifications SET is_read=TRUE WHERE notification_id=? AND user_id=?")) {
                    ps.setInt(1, id);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException | NumberFormatException ignored) {
        } finally {
            db.close();
        }

        response.sendRedirect(request.getContextPath() + "/notifications");
    }
}


