package controller.reports;

import dal.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SendRemindersServlet", urlPatterns = {"/reports/send-reminders"})
public class SendRemindersServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.getSession().setAttribute("error", "Please login to send reminders.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        ReportDAO dao = new ReportDAO();
        try {
            int remindersSent = dao.sendDueDateReminders();
            request.getSession().setAttribute("success", 
                "Successfully sent " + remindersSent + " due date reminder(s).");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        response.sendRedirect(request.getContextPath() + "/reports/overdue-books");
    }
}

