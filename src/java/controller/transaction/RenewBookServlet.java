package controller.transaction;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "RenewBookServlet", urlPatterns = {"/transaction/renew"})
public class RenewBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String transactionIdParam = request.getParameter("id");
        String searchTerm = request.getParameter("search");
        String successParam = request.getParameter("success");

        // Handle success message from redirect
        if ("true".equals(successParam)) {
            request.setAttribute("success", "Book renewed successfully. Due date extended.");
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            if (transactionIdParam != null && !transactionIdParam.trim().isEmpty()) {
                // Show renew form for specific transaction
                int transactionId = Integer.parseInt(transactionIdParam);
                TransactionDAO.BorrowingDetail borrowing = dao.getBorrowingById(transactionId);
                if (borrowing != null) {
                    // Check eligibility
                    String eligibility = dao.checkRenewalEligibility(transactionId);
                    request.setAttribute("borrowing", borrowing);
                    request.setAttribute("eligibility", eligibility);
                    request.setAttribute("isEligible", "Eligible".equals(eligibility));
                    request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Transaction not found.");
                    request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
                    request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
                }
            } else if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Search for current borrowings
                java.util.List<TransactionDAO.BorrowingDetail> allBorrowings = dao.getCurrentBorrowings();
                java.util.List<TransactionDAO.BorrowingDetail> filtered = new java.util.ArrayList<>();
                for (TransactionDAO.BorrowingDetail b : allBorrowings) {
                    if (b.bookTitle.toLowerCase().contains(searchTerm.toLowerCase()) ||
                        b.memberName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                        (b.isbn != null && b.isbn.contains(searchTerm))) {
                        filtered.add(b);
                    }
                }
                request.setAttribute("searchResults", filtered);
                request.setAttribute("searchTerm", searchTerm);
                request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
            } else {
                // Show all current borrowings
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
                request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid transaction ID.");
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String transactionIdParam = request.getParameter("transaction_id");
        if (transactionIdParam == null || transactionIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Transaction ID is required.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
            return;
        }

        int transactionId;
        try {
            transactionId = Integer.parseInt(transactionIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid transaction ID.");
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
            return;
        }

        // Get librarian ID from session
        Integer librarianId = (Integer) request.getSession().getAttribute("authUserId");
        if (librarianId == null) {
            request.setAttribute("error", "Librarian session not found. Please login again.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            // Check eligibility first
            String eligibility = dao.checkRenewalEligibility(transactionId);
            if (!"Eligible".equals(eligibility)) {
                request.setAttribute("error", "Cannot renew: " + eligibility);
                TransactionDAO.BorrowingDetail borrowing = dao.getBorrowingById(transactionId);
                if (borrowing != null) {
                    request.setAttribute("borrowing", borrowing);
                    request.setAttribute("eligibility", eligibility);
                    request.setAttribute("isEligible", false);
                }
            } else {
                boolean success = dao.renewBook(transactionId, librarianId);
                if (success) {
                    // Redirect to success page to avoid showing error messages
                    response.sendRedirect(request.getContextPath() + "/transaction/renew?success=true");
                    return;
                } else {
                    request.setAttribute("error", "Failed to renew book.");
                    TransactionDAO.BorrowingDetail borrowing = dao.getBorrowingById(transactionId);
                    if (borrowing != null) {
                        request.setAttribute("borrowing", borrowing);
                        request.setAttribute("eligibility", "Failed to process renewal");
                        request.setAttribute("isEligible", false);
                    }
                }
            }
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                TransactionDAO.BorrowingDetail borrowing = dao.getBorrowingById(transactionId);
                if (borrowing != null) {
                    request.setAttribute("borrowing", borrowing);
                }
            } catch (SQLException ignored) {}
            request.getRequestDispatcher("/transaction/renew-book.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }
}

