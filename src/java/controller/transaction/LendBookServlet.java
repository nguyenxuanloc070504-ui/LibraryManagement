package controller.transaction;

import dal.TransactionDAO;
import dal.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "LendBookServlet", urlPatterns = {"/transaction/lend"})
public class LendBookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookSearch = request.getParameter("book_search");
        String memberSearch = request.getParameter("member_search");
        
        TransactionDAO dao = new TransactionDAO();
        try {
            if (bookSearch != null && !bookSearch.trim().isEmpty()) {
                request.setAttribute("bookResults", dao.searchAvailableBooks(bookSearch));
                request.setAttribute("bookSearch", bookSearch);
            }
            if (memberSearch != null && !memberSearch.trim().isEmpty()) {
                request.setAttribute("memberResults", dao.searchMembersForLending(memberSearch));
                request.setAttribute("memberSearch", memberSearch);
            }
            request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
        } finally {
            dao.close();
        }
        request.getRequestDispatcher("/transaction/lend-book.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String userIdParam = request.getParameter("user_id");
        String bookIdParam = request.getParameter("book_id");
        
        if (userIdParam == null || userIdParam.trim().isEmpty() || 
            bookIdParam == null || bookIdParam.trim().isEmpty()) {
            request.setAttribute("error", "User ID and Book ID are required.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/lend-book.jsp").forward(request, response);
            return;
        }

        int userId, bookId;
        try {
            userId = Integer.parseInt(userIdParam);
            bookId = Integer.parseInt(bookIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid user ID or book ID.");
            TransactionDAO dao = new TransactionDAO();
            try {
                request.setAttribute("currentBorrowings", dao.getCurrentBorrowings());
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/transaction/lend-book.jsp").forward(request, response);
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
            request.getRequestDispatcher("/transaction/lend-book.jsp").forward(request, response);
            return;
        }

        TransactionDAO dao = new TransactionDAO();
        try {
            TransactionDAO.LendBookResult result = dao.lendBook(userId, bookId, librarianId);
            if (result.success) {
                request.setAttribute("success", result.message + " Transaction ID: " + result.transactionId);
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
        request.getRequestDispatcher("/transaction/lend-book.jsp").forward(request, response);
    }
}

