package controller.dashboard;

import dal.DBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        DBContext ctx = new DBContext() {};
        try {
            Connection conn = ctx.getConnection();
            try (CallableStatement cs = conn.prepareCall("CALL sp_dashboard_statistics()")) {
                boolean hasResult = cs.execute();
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        if (rs.next()) {
                            Map<String, Object> stats = new HashMap<>();
                            stats.put("total_books", rs.getInt("total_books"));
                            stats.put("available_copies", rs.getInt("available_copies"));
                            stats.put("total_members", rs.getInt("total_members"));
                            stats.put("current_borrows", rs.getInt("current_borrows"));
                            stats.put("overdue_books", rs.getInt("overdue_books"));
                            stats.put("active_reservations", rs.getInt("active_reservations"));
                            stats.put("total_unpaid_fines", rs.getBigDecimal("total_unpaid_fines"));
                            stats.put("pending_renewal_requests", rs.getInt("pending_renewal_requests"));
                            stats.put("pending_borrow_requests", rs.getInt("pending_borrow_requests"));
                            stats.put("books_ready_for_pickup", rs.getInt("books_ready_for_pickup"));
                            request.setAttribute("stats", stats);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            ctx.close();
        }
        request.getRequestDispatcher("/dashboard/librarian-dashboard.jsp").forward(request, response);
    }
}


