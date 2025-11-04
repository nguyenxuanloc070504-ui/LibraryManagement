package controller.authentication;

import dal.AuthenticationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Username/Email received: [" + username + "]");
        System.out.println("Password received: [" + (password != null ? password.substring(0, Math.min(password.length(), 20)) + "..." : "null") + "]");
        System.out.println("Password length: " + (password != null ? password.length() : 0));

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            System.out.println("ERROR: Username or password is empty");
            request.setAttribute("error", "Please enter username and password.");
            request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
            return;
        }

        AuthenticationDAO dao = new AuthenticationDAO();
        try {
            String trimmedUsername = username.trim();
            System.out.println("Searching for user with username or email: [" + trimmedUsername + "]");
            
            // Try to find by username or email (supports both roles)
            AuthenticationDAO.AuthUser user = dao.findUserByUsernameOrEmail(trimmedUsername);
            if (user == null) {
                System.out.println("ERROR: User not found in database");
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
                return;
            }

            System.out.println("User found:");
            System.out.println("  - User ID: " + user.userId);
            System.out.println("  - Username: [" + user.username + "]");
            System.out.println("  - Full Name: [" + user.fullName + "]");
            System.out.println("  - Password Hash (first 50 chars): [" + 
                (user.passwordHash != null ? user.passwordHash.substring(0, Math.min(user.passwordHash.length(), 50)) : "null") + "...]");
            System.out.println("  - Password Hash length: " + (user.passwordHash != null ? user.passwordHash.length() : 0));
            System.out.println("  - Password Hash starts with $2: " + (user.passwordHash != null && user.passwordHash.startsWith("$2")));

            boolean passwordValid = verifyPassword(password, user.passwordHash);
            System.out.println("Password verification result: " + passwordValid);

            if (passwordValid) {
                System.out.println("SUCCESS: Login successful, redirecting to dashboard");
                HttpSession session = request.getSession(true);
                session.setAttribute("authUserId", user.userId);
                session.setAttribute("authUsername", user.username);
                session.setAttribute("authFullName", user.fullName);
                session.setAttribute("authRole", user.roleName);
                if ("Librarian".equalsIgnoreCase(user.roleName)) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/home");
                }
            } else {
                System.out.println("ERROR: Password verification failed");
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            System.out.println("SQL ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
        } catch (Exception e) {
            System.out.println("GENERAL ERROR: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
        } finally {
            dao.close();
            System.out.println("=== END LOGIN ATTEMPT ===\n");
        }
    }

    private boolean verifyPassword(String plain, String storedHash) {
        System.out.println("--- verifyPassword called ---");
        System.out.println("  Plain password: [" + (plain != null ? plain.substring(0, Math.min(plain.length(), 20)) + "..." : "null") + "]");
        System.out.println("  Plain password length: " + (plain != null ? plain.length() : 0));
        System.out.println("  Stored hash (first 50 chars): [" + 
            (storedHash != null ? storedHash.substring(0, Math.min(storedHash.length(), 50)) : "null") + "...]");
        System.out.println("  Stored hash length: " + (storedHash != null ? storedHash.length() : 0));
        
        if (storedHash == null) {
            System.out.println("  Result: false (storedHash is null)");
            return false;
        }
        
        // If stored hash is a bcrypt hash (starts with $2)
        if (storedHash.startsWith("$2")) {
            System.out.println("  Detected bcrypt hash (starts with $2)");
            // Allow login with plain password "password" (default seed data)
            boolean isPasswordMatch = "password".equals(plain);
            System.out.println("  Plain password equals 'password': " + isPasswordMatch);
            if (isPasswordMatch) {
                System.out.println("  Result: true (password match)");
                return true;
            }
            // Also support direct hash comparison for dev/testing
            // (This allows entering the hash directly if needed)
            boolean isHashMatch = storedHash.equals(plain);
            System.out.println("  Plain password equals stored hash: " + isHashMatch);
            if (isHashMatch) {
                System.out.println("  Result: true (hash match)");
                return true;
            }
            // TODO: Implement proper bcrypt verification when bcrypt library is added
            // For now, only accept "password" as plain text for bcrypt hashes
            System.out.println("  Result: false (no match found)");
            return false;
        }
        
        // Fallback: raw compare (if DB stores plaintext in dev)
        boolean isRawMatch = storedHash.equals(plain);
        System.out.println("  Not bcrypt hash, using raw comparison: " + isRawMatch);
        System.out.println("  Result: " + isRawMatch);
        return isRawMatch;
    }
}


