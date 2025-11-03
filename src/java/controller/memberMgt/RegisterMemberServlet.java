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
        if (isEmpty(username)) errors.put("username", "Username is required.");
        if (isEmpty(password)) errors.put("password", "Password is required.");
        if (isEmpty(fullName)) errors.put("full_name", "Full name is required.");
        if (isEmpty(email)) {
            errors.put("email", "Email is required.");
        } else if (!email.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
            errors.put("email", "Email format is invalid.");
        }

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
        LocalDate expiry = issue.plus(validityMonths, ChronoUnit.MONTHS);

        Membership m = new Membership();
        m.setMembershipType(membershipType);
        m.setIssueDate(Date.valueOf(issue));
        m.setExpiryDate(Date.valueOf(expiry));
        m.setMaxBooksAllowed(maxBooks);

        MemberDAO dao = new MemberDAO();
        try {
            MemberDAO.CreateMemberResult result = dao.createMember(user, m);
            request.setAttribute("membershipNumber", result.membershipNumber);
            request.setAttribute("username", username);
            request.setAttribute("fullName", fullName);
            request.setAttribute("expiryDate", expiry.toString());
            request.setAttribute("membershipTypes", allowedTypes);
            request.getRequestDispatcher("/memberMgt/member-registration.jsp").forward(request, response);
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


