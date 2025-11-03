package controller.memberMgt;

import dal.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "LockUnlockAccountServlet", urlPatterns = {"/member/lock-unlock"})
public class LockUnlockAccountServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdParam = request.getParameter("id");
        String searchTerm = request.getParameter("search");
        
        MemberDAO dao = new MemberDAO();
        try {
            if (userIdParam != null && !userIdParam.trim().isEmpty()) {
                // Show lock/unlock form for specific member
                int userId = Integer.parseInt(userIdParam);
                MemberDAO.MemberDetail member = dao.findMemberById(userId);
                if (member != null) {
                    request.setAttribute("member", member);
                    request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Member not found.");
                    request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
                }
            } else if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Search for members
                request.setAttribute("searchResults", dao.searchMembers(searchTerm));
                request.setAttribute("searchTerm", searchTerm);
                request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
            } else {
                // Show search page
                request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid member ID.");
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String userIdParam = request.getParameter("user_id");
        if (userIdParam == null || userIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Member ID is required.");
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid member ID.");
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
            return;
        }

        String action = request.getParameter("action");
        String newStatus;
        
        if ("lock".equals(action)) {
            newStatus = "locked";
        } else if ("unlock".equals(action)) {
            newStatus = "active";
        } else if ("suspend".equals(action)) {
            newStatus = "suspended";
        } else {
            request.setAttribute("error", "Invalid action.");
            MemberDAO dao = new MemberDAO();
            try {
                MemberDAO.MemberDetail member = dao.findMemberById(userId);
                if (member != null) {
                    request.setAttribute("member", member);
                }
            } catch (SQLException ignored) {}
            finally {
                dao.close();
            }
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
            return;
        }

        MemberDAO dao = new MemberDAO();
        try {
            MemberDAO.MemberDetail memberBefore = dao.findMemberById(userId);
            if (memberBefore == null) {
                request.setAttribute("error", "Member not found.");
                request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
                return;
            }

            boolean success = dao.lockUnlockAccount(userId, newStatus);
            if (success) {
                MemberDAO.MemberDetail memberAfter = dao.findMemberById(userId);
                request.setAttribute("member", memberAfter);
                String actionText = "locked".equals(newStatus) ? "locked" : 
                                   "suspended".equals(newStatus) ? "suspended" : "unlocked";
                request.setAttribute("success", "Account " + actionText + " successfully.");
            } else {
                request.setAttribute("error", "Failed to update account status.");
                request.setAttribute("member", memberBefore);
            }
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                MemberDAO.MemberDetail member = dao.findMemberById(userId);
                if (member != null) {
                    request.setAttribute("member", member);
                }
            } catch (SQLException ignored) {}
            request.getRequestDispatcher("/memberMgt/member-lock-unlock.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }
}

