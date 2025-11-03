package controller.transaction;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ReturnBookServlet", urlPatterns = {"/transaction/return"})
public class ReturnBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String transactionIdParam = request.getParameter("id");
        String searchTerm = request.getParameter("search");
        
        TransactionDAO dao = new TransactionDAO();
        try {
            if (transactionIdParam != null && !transactionIdParam.trim().isEmpty()) {
                // Show return form for specific transaction
                int transactionId = Integer.parseInt(transactionIdParam);
                TransactionDAO.BorrowingDetail borrowing = dao.getBorrowingById(transactionId);
                if (borrowing != null) {
                    request.setAttribute("borrowing", borrowing);
                    request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Transaction not found.");
                    request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
                    request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
                }
            } else if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Search for current borrowings
                List<TransactionDAO.BorrowingDetail> allBorrowings = dao.getCurrentBorrowings();
                List<TransactionDAO.BorrowingDetail> filtered = new ArrayList<>();
                for (TransactionDAO.BorrowingDetail b : allBorrowings) {
                    if (b.bookTitle.toLowerCase().contains(searchTerm.toLowerCase()) ||
                        b.memberName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                        (b.isbn != null && b.isbn.contains(searchTerm))) {
                        filtered.add(b);
                    }
                }
                request.setAttribute("searchResults", filtered);
                request.setAttribute("searchTerm", searchTerm);
                request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
            } else {
                // Show all current borrowings
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
                request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid transaction ID.");
            request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String transactionIdParam = request.getParameter("transaction_id");
        String conditionStatus = request.getParameter("condition_status");

        if (transactionIdParam == null || transactionIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Transaction ID is required.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
            return;
        }

        int transactionId;
        try {
            transactionId = Integer.parseInt(transactionIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid transaction ID.");
            request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
            return;
        }

        if (conditionStatus == null || conditionStatus.trim().isEmpty()) {
            conditionStatus = "good"; // default
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            TransactionDAO.ReturnBookResult result = dao.returnBook(transactionId, conditionStatus);
            if (result.success) {
                if (result.fineAmount.compareTo(java.math.BigDecimal.ZERO) > 0) {
                    request.setAttribute("success", result.message);
                    request.setAttribute("fineAmount", result.fineAmount);
                } else {
                    request.setAttribute("success", result.message);
                }
            } else {
                request.setAttribute("error", result.message);
            }
            request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
            } catch (SQLException ignored) {}
        } finally {
            dao.close();
        }
        request.getRequestDispatcher("/transaction/return-book.jsp").forward(request, response);
    }
}

