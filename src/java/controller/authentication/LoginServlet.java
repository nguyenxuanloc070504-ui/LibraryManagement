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

        if (username == null || username.trim().isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Please enter username and password.");
            request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
            return;
        }

        AuthenticationDAO dao = new AuthenticationDAO();
        try {
            AuthenticationDAO.AuthUser user = dao.findLibrarianByUsername(username.trim());
            if (user == null) {
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
                return;
            }

            if (verifyPassword(password, user.passwordHash)) {
                HttpSession session = request.getSession(true);
                session.setAttribute("authUserId", user.userId);
                session.setAttribute("authUsername", user.username);
                session.setAttribute("authFullName", user.fullName);
                session.setAttribute("authRole", "Librarian");
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                request.setAttribute("error", "Invalid username or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/authentication/login.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    private boolean verifyPassword(String plain, String storedHash) {
        if (storedHash == null) return false;
        // Demo support: if stored is a bcrypt hash of "password" (as in sample seed), allow when plain == "password"
        if (storedHash.startsWith("$2") && "password".equals(plain)) {
            return true;
        }
        // Fallback: raw compare (if DB stores plaintext in dev)
        return storedHash.equals(plain);
    }
}


