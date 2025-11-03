package controller.memberMgt;

import dal.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

@WebServlet(name = "UpdateMemberServlet", urlPatterns = {"/member/update"})
public class UpdateMemberServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String userIdParam = request.getParameter("id");
        String searchTerm = request.getParameter("search");
        
        MemberDAO dao = new MemberDAO();
        try {
            if (userIdParam != null && !userIdParam.trim().isEmpty()) {
                // Show update form for specific member
                int userId = Integer.parseInt(userIdParam);
                MemberDAO.MemberDetail member = dao.findMemberById(userId);
                if (member != null) {
                    request.setAttribute("member", member);
                    request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
                } else {
                    request.setAttribute("error", "Member not found.");
                    request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
                }
            } else if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                // Search for members
                request.setAttribute("searchResults", dao.searchMembers(searchTerm));
                request.setAttribute("searchTerm", searchTerm);
                request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
            } else {
                // Show search page
                request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid member ID.");
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
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
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(userIdParam);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid member ID.");
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
            return;
        }

        String email = request.getParameter("email");
        String fullName = request.getParameter("full_name");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String dob = request.getParameter("date_of_birth");
        String profilePhoto = request.getParameter("profile_photo");

        // Validation
        java.util.Map<String, String> errors = new java.util.HashMap<>();
        if (isEmpty(email)) {
            errors.put("email", "Email is required.");
        } else if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Email format is invalid.");
        }
        if (isEmpty(fullName)) {
            errors.put("full_name", "Full name is required.");
        }

        Date dateOfBirth = null;
        if (!isEmpty(dob)) {
            try {
                java.time.LocalDate parsed = java.time.LocalDate.parse(dob);
                if (!parsed.isBefore(java.time.LocalDate.now())) {
                    errors.put("date_of_birth", "Date of Birth must be in the past.");
                } else {
                    dateOfBirth = Date.valueOf(dob);
                }
            } catch (Exception e) {
                errors.put("date_of_birth", "Date of Birth is invalid.");
            }
        }

        if (!errors.isEmpty()) {
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
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
            return;
        }

        MemberDAO dao = new MemberDAO();
        try {
            boolean success = dao.updateMember(userId, email.trim(), fullName.trim(),
                    isEmpty(phone) ? null : phone.trim(),
                    isEmpty(address) ? null : address.trim(),
                    dateOfBirth,
                    isEmpty(profilePhoto) ? null : profilePhoto.trim());

            if (success) {
                MemberDAO.MemberDetail updatedMember = dao.findMemberById(userId);
                request.setAttribute("member", updatedMember);
                request.setAttribute("success", "Member information updated successfully.");
            } else {
                request.setAttribute("error", "Failed to update member information.");
            }
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            try {
                MemberDAO.MemberDetail member = dao.findMemberById(userId);
                if (member != null) {
                    request.setAttribute("member", member);
                }
            } catch (SQLException ignored) {}
            request.getRequestDispatcher("/memberMgt/member-update.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
}

