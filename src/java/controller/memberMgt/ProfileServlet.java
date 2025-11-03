package controller.memberMgt;

import dal.MemberDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/member/profile"})
@MultipartConfig
public class ProfileServlet extends HttpServlet {

    private void loadProfile(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("authUserId") : null;
        if (userId == null) return;

        MemberDAO dao = new MemberDAO();
        try {
            MemberDAO.MemberDetail detail = dao.findMemberById(userId);
            if (detail == null) {
                // fallback for non-member roles (e.g., Librarian)
                detail = dao.findUserCoreById(userId);
            }
            request.setAttribute("profile", detail);
            if (session != null && detail != null && detail.profilePhoto != null && !detail.profilePhoto.isEmpty()) {
                session.setAttribute("authProfilePhoto", detail.profilePhoto);
            }
        } catch (SQLException ignored) {
        } finally {
            dao.close();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        loadProfile(request);
        request.getRequestDispatcher("/memberMgt/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("authUserId") : null;

        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String dobParam = request.getParameter("dob");
        java.sql.Date dob = null;
        try {
            if (dobParam != null && !dobParam.isEmpty()) {
                dob = java.sql.Date.valueOf(dobParam);
            }
        } catch (IllegalArgumentException ignored) { }

        // Handle avatar upload
        String savedAvatarPath = null; // context-relative path like /uploads/avatars/xxx.jpg
        try {
            Part avatarPart = request.getPart("avatar");
            if (avatarPart != null && avatarPart.getSize() > 0) {
                String contentType = avatarPart.getContentType();
                String ext = ".png";
                if (contentType != null) {
                    if (contentType.endsWith("jpeg") || contentType.endsWith("jpg")) ext = ".jpg";
                    else if (contentType.endsWith("png")) ext = ".png";
                    else if (contentType.endsWith("gif")) ext = ".gif";
                }
                String fileName = "avatar-" + userId + "-" + UUID.randomUUID() + ext;
                String relativeDir = "/uploads/avatars";
                String realDir = getServletContext().getRealPath(relativeDir);
                if (realDir == null) realDir = getServletContext().getRealPath("/") + "uploads/avatars";
                Path dirPath = Paths.get(realDir);
                if (!Files.exists(dirPath)) Files.createDirectories(dirPath);
                Path filePath = dirPath.resolve(fileName);
                try (InputStream is = avatarPart.getInputStream()) {
                    Files.copy(is, filePath);
                }
                savedAvatarPath = relativeDir + "/" + fileName; // store context-relative
            }
        } catch (Exception ignored) { }

        if (userId != null) {
            MemberDAO dao = new MemberDAO();
            try {
                dao.updateUserProfile(userId,
                        (fullName != null && !fullName.trim().isEmpty()) ? fullName.trim() : null,
                        (email != null && !email.trim().isEmpty()) ? email.trim() : null,
                        (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null,
                        (address != null && !address.trim().isEmpty()) ? address.trim() : null,
                        dob,
                        savedAvatarPath);
            } catch (SQLException ignored) { }
            finally { dao.close(); }
        }

        if (session != null) {
            if (fullName != null && !fullName.trim().isEmpty()) session.setAttribute("authFullName", fullName.trim());
            if (email != null && !email.trim().isEmpty()) session.setAttribute("authEmail", email.trim());
            if (savedAvatarPath != null && !savedAvatarPath.isEmpty()) session.setAttribute("authProfilePhoto", savedAvatarPath);
        }

        response.sendRedirect(request.getContextPath() + "/member/profile");
    }
}


