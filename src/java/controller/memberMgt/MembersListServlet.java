package controller.memberMgt;

import dal.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "MembersListServlet", urlPatterns = {"/member/list"})
public class MembersListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String search = getParam(request, "search");
        String status = getParam(request, "status"); // active, locked, suspended, all
        int page = parseInt(getParam(request, "page"), 1);
        int size = parseInt(getParam(request, "size"), 10);
        if (size <= 0) size = 10;
        int offset = (page - 1) * size;

        MemberDAO dao = new MemberDAO();
        try {
            // Correct legacy rows where expiry_date was stored incorrectly
            try {
                dao.fixIncorrectExpiry();
            } catch (SQLException ignored) { /* non-critical */ }
            int total = dao.countMembers(search, status);
            List<MemberDAO.MemberDetail> items = dao.searchMembersPaged(search, status, offset, size);
            int totalPages = (int) Math.ceil(total / (double) size);

            request.setAttribute("members", items);
            request.setAttribute("total", total);
            request.setAttribute("page", page);
            request.setAttribute("size", size);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("search", search == null ? "" : search);
            request.setAttribute("status", status == null ? "all" : status);

            request.getRequestDispatcher("/memberMgt/member-list.jsp").forward(request, response);
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
            request.getRequestDispatcher("/memberMgt/member-list.jsp").forward(request, response);
        } finally {
            dao.close();
        }
    }

    private String getParam(HttpServletRequest r, String k) {
        String v = r.getParameter(k);
        return v == null ? null : v.trim();
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}


