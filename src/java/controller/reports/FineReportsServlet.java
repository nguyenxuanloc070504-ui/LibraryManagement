package controller.reports;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

@WebServlet(name = "FineReportsServlet", urlPatterns = {"/reports/fine-reports"})
public class FineReportsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            request.setAttribute("error", "Please login to view fine reports.");
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            // Get parameters
            String reportType = request.getParameter("type");
            if (reportType == null || reportType.isEmpty()) {
                reportType = "summary";
            }

            // Date range parameters
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DAY_OF_MONTH, -30);
            Date defaultStartDate = cal.getTime();
            Date defaultEndDate = new Date();

            java.sql.Date startDate = new java.sql.Date(defaultStartDate.getTime());
            java.sql.Date endDate = new java.sql.Date(defaultEndDate.getTime());

            String startParam = request.getParameter("start_date");
            String endParam = request.getParameter("end_date");

            try {
                if (startParam != null && !startParam.isEmpty()) {
                    startDate = new java.sql.Date(sdf.parse(startParam).getTime());
                }
                if (endParam != null && !endParam.isEmpty()) {
                    endDate = new java.sql.Date(sdf.parse(endParam).getTime());
                }
            } catch (ParseException e) {
                request.setAttribute("error", "Invalid date format. Using default dates.");
            }

            request.setAttribute("startDate", sdf.format(startDate));
            request.setAttribute("endDate", sdf.format(endDate));
            request.setAttribute("reportType", reportType);

            // Generate reports based on type
            if ("summary".equals(reportType)) {
                // Fine summary
                TransactionDAO.FineSummary summary = dao.getFineSummary(startDate, endDate);
                request.setAttribute("fineSummary", summary);
            } else if ("detailed".equals(reportType)) {
                // Detailed fine list with filters
                String paymentStatus = request.getParameter("payment_status");
                String searchTerm = request.getParameter("search");

                java.util.List<TransactionDAO.FineDetail> fines = dao.getFinesWithFilter(
                    paymentStatus, startDate, endDate, searchTerm
                );
                request.setAttribute("fines", fines);
                request.setAttribute("paymentStatus", paymentStatus);
                request.setAttribute("searchTerm", searchTerm);
            } else if ("member-history".equals(reportType)) {
                // Member fine history
                java.util.List<TransactionDAO.MemberFineHistory> histories = dao.getMemberFineHistories();
                request.setAttribute("memberHistories", histories);
            }

        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }

        request.getRequestDispatcher("/reports/fine-reports.jsp").forward(request, response);
    }
}
