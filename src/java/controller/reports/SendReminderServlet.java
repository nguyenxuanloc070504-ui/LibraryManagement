package controller.reports;

import dal.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "SendReminderServlet", urlPatterns = {"/reports/send-reminder"})
public class SendReminderServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // Check authentication
        Integer authUserId = (Integer) request.getSession().getAttribute("authUserId");
        if (authUserId == null) {
            request.getSession().setAttribute("error", "Please login to send reminders.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get parameters
        String userIdParam = request.getParameter("userId");
        String transactionIdParam = request.getParameter("transactionId");

        if (userIdParam == null || transactionIdParam == null) {
            request.getSession().setAttribute("error", "Invalid request parameters.");
            response.sendRedirect(request.getContextPath() + "/reports/overdue-books");
            return;
        }

        ReportDAO dao = new ReportDAO();
        try {
            int userId = Integer.parseInt(userIdParam);
            int transactionId = Integer.parseInt(transactionIdParam);

            boolean success = dao.sendIndividualOverdueReminder(userId, transactionId);

            if (success) {
                request.getSession().setAttribute("success",
                    "Overdue reminder sent successfully to the member.");
            } else {
                request.getSession().setAttribute("error",
                    "Failed to send reminder. The book may not be overdue or transaction not found.");
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "Invalid parameter format.");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        response.sendRedirect(request.getContextPath() + "/reports/overdue-books");
    }
}
