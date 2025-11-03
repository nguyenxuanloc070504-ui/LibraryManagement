package controller.memberMgt;

import dal.MemberDAO;
import model.Membership;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@WebServlet(name = "RegisterMemberServlet", urlPatterns = {"/member/register"})
public class RegisterMemberServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        MemberDAO dao = new MemberDAO();
        try {
            request.setAttribute("membershipTypes", dao.getAvailableMembershipTypes());
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
        } finally {
            dao.close();
        }
        request.getRequestDispatcher("/memberMgt/member-registration.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String fullName = request.getParameter("full_name");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String dob = request.getParameter("date_of_birth");
        String membershipType = request.getParameter("membership_type");

        // Basic + detailed validation
        java.util.Map<String, String> errors = new java.util.HashMap<>();
        
        // Username validation
        if (isEmpty(username)) {
            errors.put("username", "Username is required.");
        } else {
            MemberDAO checkDao = new MemberDAO();
            try {
                if (checkDao.usernameExists(username.trim())) {
                    errors.put("username", "Username already exists.");
                }
            } catch (SQLException e) {
                errors.put("username", "Error checking username: " + e.getMessage());
            } finally {
                checkDao.close();
            }
        }
        
        // Password validation
        if (isEmpty(password)) {
            errors.put("password", "Password is required.");
        } else if (password.length() < 6) {
            errors.put("password", "Password must be at least 6 characters.");
        }
        
        // Full name validation
        if (isEmpty(fullName)) {
            errors.put("full_name", "Full name is required.");
        }
        
        // Email validation
        if (isEmpty(email)) {
            errors.put("email", "Email is required.");
        } else if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Invalid email format.");
        }
        
        // Phone validation (optional field, but must be 10 digits if provided)
        if (!isEmpty(phone) && !phone.trim().matches("^\\d{10}$")) {
            errors.put("phone", "Phone must be exactly 10 digits.");
        }
        
        // Date of birth validation
        if (!isEmpty(dob)) {
            try {
                java.time.LocalDate parsed = java.time.LocalDate.parse(dob);
                if (!parsed.isBefore(java.time.LocalDate.now())) {
                    errors.put("date_of_birth", "Date of Birth must be in the past.");
                }
            } catch (Exception e) {
                errors.put("date_of_birth", "Date of Birth is invalid.");
            }
        }

        MemberDAO daoTypes = new MemberDAO();
        java.util.List<String> allowedTypes;
        try {
            allowedTypes = daoTypes.getAvailableMembershipTypes();
            request.setAttribute("membershipTypes", allowedTypes);
        } catch (SQLException e) {
            allowedTypes = java.util.Arrays.asList("basic","premium","student");
        } finally {
            daoTypes.close();
        }
        if (isEmpty(membershipType) || !allowedTypes.contains(membershipType)) {
            errors.put("membership_type", "Please choose a valid membership type.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/memberMgt/member-registration.jsp").forward(request, response);
            return;
        }

        User user = new User();
        user.setUsername(username.trim());
        user.setPasswordHash(password); // NOTE: Replace with hashing in production
        user.setEmail(email.trim());
        user.setFullName(fullName.trim());
        user.setPhone(isEmpty(phone) ? null : phone.trim());
        user.setAddress(isEmpty(address) ? null : address.trim());
        if (!isEmpty(dob)) {
            user.setDateOfBirth(Date.valueOf(dob));
        }

        LocalDate issue = LocalDate.now();
        int validityMonths = membershipTypeValidityMonths(membershipType);
        int maxBooks = membershipTypeMaxBooks(membershipType);
        // Ensure expiry is strictly after issue date
        LocalDate expiry = issue.plusMonths(validityMonths);
        if (!expiry.isAfter(issue)) {
            expiry = issue.plusMonths(Math.max(1, validityMonths));
        }

        Membership m = new Membership();
        m.setMembershipType(membershipType);
        m.setIssueDate(Date.valueOf(issue));
        m.setExpiryDate(Date.valueOf(expiry));
        m.setMaxBooksAllowed(maxBooks);

        MemberDAO dao = new MemberDAO();
        try {
            MemberDAO.CreateMemberResult result = dao.createMember(user, m);
            // Redirect immediately to members list with success flag
            // Redirect to members list (show full list) with success flag
            response.sendRedirect(request.getContextPath() + "/member/list?success=1");
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("membershipTypes", allowedTypes);
            request.getRequestDispatcher("/memberMgt/member-registration.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    private boolean isEmpty(String s) { return s == null || s.trim().isEmpty(); }

    private int membershipTypeValidityMonths(String membershipType) {
        if ("student".equalsIgnoreCase(membershipType)) return 6;
        return 12; // basic and premium default to 12 months
    }

    private int membershipTypeMaxBooks(String membershipType) {
        if ("premium".equalsIgnoreCase(membershipType)) return 10;
        if ("student".equalsIgnoreCase(membershipType)) return 7;
        return 5; // basic
    }
}


