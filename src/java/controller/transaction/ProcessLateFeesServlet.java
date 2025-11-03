package controller.transaction;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

@WebServlet(name = "ProcessLateFeesServlet", urlPatterns = {"/transaction/fines"})
public class ProcessLateFeesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String paymentStatus = request.getParameter("status");
        String fineIdParam = request.getParameter("id");
        
        TransactionDAO dao = new TransactionDAO();
        try {
            if (fineIdParam != null && !fineIdParam.trim().isEmpty()) {
                // Show fine details for payment
                int fineId = Integer.parseInt(fineIdParam);
                java.util.List<TransactionDAO.FineDetail> allFines = dao.getAllFines(null);
                TransactionDAO.FineDetail fine = null;
                for (TransactionDAO.FineDetail f : allFines) {
                    if (f.fineId == fineId) {
                        fine = f;
                        break;
                    }
                }
                if (fine != null) {
                    request.setAttribute("fine", fine);
                    request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Fine not found.");
                    request.setAttribute("fines", dao.getAllFines(paymentStatus));
                    request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
                }
            } else {
                // Show fines list
                request.setAttribute("fines", dao.getAllFines(paymentStatus));
                request.setAttribute("overdueBooks", dao.getOverdueBooks());
                request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid fine ID.");
            request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fineIdParam = request.getParameter("fine_id");
        String action = request.getParameter("action"); // pay, waive

        if (fineIdParam == null || fineIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Fine ID is required.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("fines", dao.getAllFines(null));
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
            return;
        }

        int fineId;
        try {
            fineId = Integer.parseInt(fineIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid fine ID.");
            request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
            return;
        }

        if (!"pay".equals(action) && !"waive".equals(action)) {
            request.setAttribute("error", "Invalid action.");
            request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
            return;
        }

        // Get librarian ID from session
        Integer librarianId = (Integer) request.getSession().getAttribute("authUserId");
        if (librarianId == null) {
            request.setAttribute("error", "Librarian session not found. Please login again.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("fines", dao.getAllFines(null));
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
            return;
        }

        String paymentStatus = "pay".equals(action) ? "paid" : "waived";
        String paymentMethod = request.getParameter("payment_method");
        String notes = request.getParameter("notes");
        Date paymentDate = new Date(System.currentTimeMillis());

        TransactionDAO dao = new TransactionDAO();
        try {
            boolean success = dao.updateFinePayment(fineId, paymentStatus, paymentMethod, 
                    "pay".equals(action) ? paymentDate : null, librarianId, notes);
            if (success) {
                request.setAttribute("success", "Fine " + ("pay".equals(action) ? "paid" : "waived") + " successfully.");
            } else {
                request.setAttribute("error", "Failed to update fine payment.");
            }
            request.setAttribute("fines", dao.getAllFines(null));
            request.setAttribute("overdueBooks", dao.getOverdueBooks());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                request.setAttribute("fines", dao.getAllFines(null));
            } catch (SQLException ignored) {}
        } finally {
            dao.close();
        }
        request.getRequestDispatcher("/transaction/process-fines.jsp").forward(request, response);
    }
}

