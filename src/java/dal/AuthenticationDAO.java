package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AuthenticationDAO extends DBContext {

    public static class AuthUser {
        public final int userId;
        public final String username;
        public final String fullName;
        public final String passwordHash;
        public final String roleName;

        public AuthUser(int userId, String username, String fullName, String passwordHash, String roleName) {
            this.userId = userId;
            this.username = username;
            this.fullName = fullName;
            this.passwordHash = passwordHash;
            this.roleName = roleName;
        }
    }

    public AuthUser findLibrarianByUsername(String username) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.password_hash, r.role_name " +
                "FROM Users u JOIN Roles r ON u.role_id = r.role_id " +
                "WHERE r.role_name = 'Librarian' AND u.username = ? AND u.account_status = 'active'";
        try (Connection conn = this.connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new AuthUser(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("full_name"),
                            rs.getString("password_hash"),
                            rs.getString("role_name")
                    );
                }
            }
        }
        return null;
    }

    /**
     * Find librarian by username or email (supports both login methods)
     * @param usernameOrEmail - Username or email address
     * @return AuthUser if found, null otherwise
     * @throws SQLException
     */
    public AuthUser findLibrarianByUsernameOrEmail(String usernameOrEmail) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.password_hash, r.role_name " +
                "FROM Users u JOIN Roles r ON u.role_id = r.role_id " +
                "WHERE r.role_name = 'Librarian' AND " +
                "(u.username = ? OR u.email = ?) AND u.account_status = 'active'";
        try (Connection conn = this.connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new AuthUser(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("full_name"),
                            rs.getString("password_hash"),
                            rs.getString("role_name")
                    );
                }
            }
        }
        return null;
    }

    /**
     * Find any active user by username or email (Librarian or Member)
     */
    public AuthUser findUserByUsernameOrEmail(String usernameOrEmail) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.full_name, u.password_hash, r.role_name " +
                "FROM Users u JOIN Roles r ON u.role_id = r.role_id " +
                "WHERE (u.username = ? OR u.email = ?) AND u.account_status = 'active'";
        try (Connection conn = this.connection; PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new AuthUser(
                            rs.getInt("user_id"),
                            rs.getString("username"),
                            rs.getString("full_name"),
                            rs.getString("password_hash"),
                            rs.getString("role_name")
                    );
                }
            }
        }
        return null;
    }
}


