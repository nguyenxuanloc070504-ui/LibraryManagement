package controller.memberMgt;

import dal.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet(name = "CheckUsernameServlet", urlPatterns = {"/api/check-username"})
public class CheckUsernameServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        
        if (username == null || username.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            PrintWriter out = response.getWriter();
            out.print("{\"exists\":false,\"error\":\"Username parameter is required\"}");
            out.flush();
            return;
        }
        
        MemberDAO dao = new MemberDAO();
        try {
            boolean exists = dao.usernameExists(username.trim());
            
            PrintWriter out = response.getWriter();
            out.print("{\"exists\":" + exists + "}");
            out.flush();
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            PrintWriter out = response.getWriter();
            out.print("{\"exists\":false,\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
            out.flush();
        } finally {
            dao.close();
        }
    }
}

