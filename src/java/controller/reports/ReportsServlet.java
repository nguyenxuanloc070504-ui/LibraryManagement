package controller.reports;

import dal.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet(name = "ReportsServlet", urlPatterns = {"/reports/statistics"})
public class ReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to view reports.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        ReportDAO dao = new ReportDAO();
        try {
            // Get report type
            String reportType = request.getParameter("type");
            if (reportType == null || reportType.isEmpty()) {
                reportType = "dashboard";
            }

            // Dashboard statistics
            if ("dashboard".equals(reportType)) {
                request.setAttribute("dashboardStats", dao.getDashboardStatistics());
                request.setAttribute("reportType", "dashboard");
            }
            // Popular books
            else if ("popular-books".equals(reportType)) {
                int periodDays = 90; // default 90 days
                int limit = 20; // default top 20
                try {
                    String periodParam = request.getParameter("period");
                    if (periodParam != null && !periodParam.isEmpty()) {
                        periodDays = Integer.parseInt(periodParam);
                    }
                    String limitParam = request.getParameter("limit");
                    if (limitParam != null && !limitParam.isEmpty()) {
                        limit = Integer.parseInt(limitParam);
                    }
                } catch (NumberFormatException e) {
                    // Use defaults
                }
                request.setAttribute("popularBooks", dao.getPopularBooks(periodDays, limit));
                request.setAttribute("periodDays", periodDays);
                request.setAttribute("limit", limit);
                request.setAttribute("reportType", "popular-books");
            }
            // Active members
            else if ("active-members".equals(reportType)) {
                int periodDays = 90; // default 90 days
                int limit = 20; // default top 20
                try {
                    String periodParam = request.getParameter("period");
                    if (periodParam != null && !periodParam.isEmpty()) {
                        periodDays = Integer.parseInt(periodParam);
                    }
                    String limitParam = request.getParameter("limit");
                    if (limitParam != null && !limitParam.isEmpty()) {
                        limit = Integer.parseInt(limitParam);
                    }
                } catch (NumberFormatException e) {
                    // Use defaults
                }
                request.setAttribute("activeMembers", dao.getMostActiveMembers(periodDays, limit));
                request.setAttribute("periodDays", periodDays);
                request.setAttribute("limit", limit);
                request.setAttribute("reportType", "active-members");
            }
            // Fine revenue
            else if ("fine-revenue".equals(reportType)) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date startDate = new Date(System.currentTimeMillis() - 30L * 24 * 60 * 60 * 1000); // default 30 days ago
                Date endDate = new Date(); // today
                
                try {
                    String startParam = request.getParameter("start_date");
                    if (startParam != null && !startParam.isEmpty()) {
                        startDate = sdf.parse(startParam);
                    }
                    String endParam = request.getParameter("end_date");
                    if (endParam != null && !endParam.isEmpty()) {
                        endDate = sdf.parse(endParam);
                    }
                } catch (ParseException e) {
                    // Use defaults
                }
                
                request.setAttribute("fineRevenue", dao.getFineRevenueReport(
                    new java.sql.Date(startDate.getTime()), 
                    new java.sql.Date(endDate.getTime())
                ));
                request.setAttribute("startDate", new SimpleDateFormat("yyyy-MM-dd").format(startDate));
                request.setAttribute("endDate", new SimpleDateFormat("yyyy-MM-dd").format(endDate));
                request.setAttribute("reportType", "fine-revenue");
            }
            // Category statistics
            else if ("categories".equals(reportType)) {
                request.setAttribute("categoryStats", dao.getCategoryStatistics());
                request.setAttribute("reportType", "categories");
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        request.getRequestDispatcher("/reports/statistics.jsp").forward(request, response);
    }
}

