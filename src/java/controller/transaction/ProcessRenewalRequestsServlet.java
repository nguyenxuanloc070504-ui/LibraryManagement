package controller.transaction;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ProcessRenewalRequestsServlet", urlPatterns = {"/transaction/renewal-requests"})
public class ProcessRenewalRequestsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("authRole");
        if (!"Librarian".equalsIgnoreCase(role) && !"Administrator".equalsIgnoreCase(role)) {
            request.setAttribute("error", "Access denied. Librarians only.");
            request.getRequestDispatcher("/transaction/renewal-requests.jsp").forward(request, response);
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            List<TransactionDAO.PendingRenewalRequest> pendingRequests = dao.getPendingRenewalRequests();
            request.setAttribute("pendingRequests", pendingRequests);
            request.getRequestDispatcher("/transaction/renewal-requests.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/transaction/renewal-requests.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("authUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("authRole");
        if (!"Librarian".equalsIgnoreCase(role) && !"Administrator".equalsIgnoreCase(role)) {
            request.setAttribute("error", "Access denied. Librarians only.");
            doGet(request, response);
            return;
        }

        Integer librarianId = (Integer) session.getAttribute("authUserId");
        String action = request.getParameter("action");
        String requestIdParam = request.getParameter("request_id");

        if (requestIdParam == null || requestIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Request ID is required.");
            doGet(request, response);
            return;
        }

        int requestId;
        try {
            requestId = Integer.parseInt(requestIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid request ID.");
            doGet(request, response);
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            if ("approve".equals(action)) {
                boolean success = dao.approveRenewalRequest(requestId, librarianId);
                if (success) {
                    request.setAttribute("success", "Renewal request approved successfully.");
                } else {
                    request.setAttribute("error", "Failed to approve renewal request.");
                }
            } else if ("reject".equals(action)) {
                String rejectionReason = request.getParameter("rejection_reason");
                if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                    rejectionReason = "Rejected by librarian";
                }
                boolean success = dao.rejectRenewalRequest(requestId, librarianId, rejectionReason);
                if (success) {
                    request.setAttribute("success", "Renewal request rejected.");
                } else {
                    request.setAttribute("error", "Failed to reject renewal request.");
                }
            } else {
                request.setAttribute("error", "Invalid action.");
            }
            doGet(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            doGet(request, response);
        } finally {
            dao.close();
        }
    }
}
