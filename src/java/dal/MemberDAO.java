package dal;

import model.User;
import model.Membership;

import java.sql.*;

import java.util.ArrayList;
import java.util.List;

public class MemberDAO extends DBContext {

    public static class CreateMemberResult {
        public final int userId;
        public final int membershipId;
        public final String membershipNumber;

        public CreateMemberResult(int userId, int membershipId, String membershipNumber) {
            this.userId = userId;
            this.membershipId = membershipId;
            this.membershipNumber = membershipNumber;
        }
    }

    public List<String> getAvailableMembershipTypes() throws SQLException {
        List<String> types = new ArrayList<>();

        // 1) Try to read distinct values from data
        String sql = "SELECT DISTINCT membership_type FROM Memberships ORDER BY membership_type";
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String t = rs.getString(1);
                if (t != null && !t.trim().isEmpty()) types.add(t);
            }
        }

        // 2) If table has no rows yet, fall back to reading ENUM values from schema (still from database)
        if (types.isEmpty()) {
            String enumSql = "SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Memberships' AND COLUMN_NAME = 'membership_type'";
            try (PreparedStatement ps = connection.prepareStatement(enumSql); ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String columnType = rs.getString(1); // e.g., enum('basic','premium','student')
                    if (columnType != null && columnType.startsWith("enum(")) {
                        String inner = columnType.substring(5, columnType.length() - 1); // remove enum( and )
                        // split by comma not inside quotes (values are simple, so split by , then trim quotes)
                        for (String part : inner.split(",")) {
                            String val = part.trim();
                            if (val.startsWith("'") && val.endsWith("'")) {
                                val = val.substring(1, val.length() - 1);
                            }
                            if (!val.isEmpty()) types.add(val);
                        }
                    }
                }
            }
        }

        return types;
    }

    public CreateMemberResult createMember(User user, Membership membership) throws SQLException {
        String selectMemberRoleSql = "SELECT role_id FROM Roles WHERE role_name = 'Member'";
        String insertUserSql = "INSERT INTO Users (role_id, username, password_hash, email, full_name, phone, address, date_of_birth, account_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'active')";
        String insertMembershipSql = "INSERT INTO Memberships (user_id, membership_number, membership_type, issue_date, expiry_date, max_books_allowed, is_active) VALUES (?, ?, ?, ?, ?, ?, TRUE)";

        PreparedStatement psRole = null;
        PreparedStatement psUser = null;
        PreparedStatement psMembership = null;
        ResultSet rs = null;

        try {
            connection.setAutoCommit(false);

            int memberRoleId;
            try (PreparedStatement ps = connection.prepareStatement(selectMemberRoleSql); ResultSet r = ps.executeQuery()) {
                if (!r.next()) throw new SQLException("Member role not found");
                memberRoleId = r.getInt(1);
            }

            psUser = connection.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS);
            psUser.setInt(1, memberRoleId);
            psUser.setString(2, user.getUsername());
            psUser.setString(3, user.getPasswordHash());
            psUser.setString(4, user.getEmail());
            psUser.setString(5, user.getFullName());
            psUser.setString(6, user.getPhone());
            psUser.setString(7, user.getAddress());
            psUser.setDate(8, user.getDateOfBirth());
            psUser.executeUpdate();

            int newUserId;
            try (ResultSet gen = psUser.getGeneratedKeys()) {
                if (!gen.next()) throw new SQLException("Failed to retrieve user_id");
                newUserId = gen.getInt(1);
            }

            String membershipNumber = generateMembershipNumber(newUserId);

            psMembership = connection.prepareStatement(insertMembershipSql, Statement.RETURN_GENERATED_KEYS);
            psMembership.setInt(1, newUserId);
            psMembership.setString(2, membershipNumber);
            psMembership.setString(3, membership.getMembershipType());
            psMembership.setDate(4, membership.getIssueDate());
            psMembership.setDate(5, membership.getExpiryDate());
            psMembership.setInt(6, membership.getMaxBooksAllowed() != null ? membership.getMaxBooksAllowed() : 5);
            psMembership.executeUpdate();

            int membershipId;
            try (ResultSet gen = psMembership.getGeneratedKeys()) {
                if (!gen.next()) throw new SQLException("Failed to retrieve membership_id");
                membershipId = gen.getInt(1);
            }

            connection.commit();
            return new CreateMemberResult(newUserId, membershipId, membershipNumber);
        } catch (SQLException e) {
            if (connection != null) {
                try { connection.rollback(); } catch (SQLException ignored) {}
            }
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (psRole != null) try { psRole.close(); } catch (SQLException ignored) {}
            if (psUser != null) try { psUser.close(); } catch (SQLException ignored) {}
            if (psMembership != null) try { psMembership.close(); } catch (SQLException ignored) {}
            if (connection != null) try { connection.setAutoCommit(true); } catch (SQLException ignored) {}
        }
    }

    private String generateMembershipNumber(int userId) throws SQLException {
        // Format: MEM + zero-padded userId to 5 digits, ensure uniqueness
        String base = String.format("MEM%05d", userId);
        String checkSql = "SELECT 1 FROM Memberships WHERE membership_number = ?";
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setString(1, base);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return base;
            }
        }
        // Fallback with timestamp suffix
        return base + System.currentTimeMillis();
    }

    /**
     * Find member by user ID with membership details
     */
    public MemberDetail findMemberById(int userId) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.email, u.full_name, u.phone, u.address, " +
                     "u.date_of_birth, u.profile_photo, u.account_status, " +
                     "m.membership_id, m.membership_number, m.membership_type, " +
                     "m.issue_date, m.expiry_date, m.max_books_allowed, m.is_active " +
                     "FROM Users u " +
                     "LEFT JOIN Memberships m ON u.user_id = m.user_id " +
                     "WHERE u.user_id = ? AND u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapToMemberDetail(rs);
                }
            }
        }
        return null;
    }

    /**
     * Fetch basic user info for any role (no membership join requirement)
     */
    public MemberDetail findUserCoreById(int userId) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.email, u.full_name, u.phone, u.address, u.date_of_birth, u.profile_photo, u.account_status " +
                     "FROM Users u WHERE u.user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MemberDetail d = new MemberDetail();
                    d.userId = rs.getInt("user_id");
                    d.username = rs.getString("username");
                    d.email = rs.getString("email");
                    d.fullName = rs.getString("full_name");
                    d.phone = rs.getString("phone");
                    d.address = rs.getString("address");
                    d.dateOfBirth = rs.getDate("date_of_birth");
                    d.profilePhoto = rs.getString("profile_photo");
                    d.accountStatus = rs.getString("account_status");
                    return d;
                }
            }
        }
        return null;
    }

    /**
     * Update core user profile fields. If a provided value is null, the existing
     * value in the database will be preserved via COALESCE.
     */
    public int updateUserProfile(int userId,
                                 String fullName,
                                 String email,
                                 String phone,
                                 String address,
                                 java.sql.Date dateOfBirth,
                                 String profilePhotoPath) throws SQLException {
        String sql = "UPDATE Users SET " +
                "full_name = COALESCE(?, full_name), " +
                "email = COALESCE(?, email), " +
                "phone = COALESCE(?, phone), " +
                "address = COALESCE(?, address), " +
                "date_of_birth = COALESCE(?, date_of_birth), " +
                "profile_photo = COALESCE(?, profile_photo) " +
                "WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, address);
            if (dateOfBirth != null) {
                ps.setDate(5, dateOfBirth);
            } else {
                ps.setNull(5, java.sql.Types.DATE);
            }
            ps.setString(6, profilePhotoPath);
            ps.setInt(7, userId);
            return ps.executeUpdate();
        }
    }

    /**
     * Find member by username with membership details
     */
    public MemberDetail findMemberByUsername(String username) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.email, u.full_name, u.phone, u.address, " +
                     "u.date_of_birth, u.profile_photo, u.account_status, " +
                     "m.membership_id, m.membership_number, m.membership_type, " +
                     "m.issue_date, m.expiry_date, m.max_books_allowed, m.is_active " +
                     "FROM Users u " +
                     "LEFT JOIN Memberships m ON u.user_id = m.user_id " +
                     "WHERE u.username = ? AND u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member')";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapToMemberDetail(rs);
                }
            }
        }
        return null;
    }

    /**
     * Find member by membership number
     */
    public MemberDetail findMemberByMembershipNumber(String membershipNumber) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.email, u.full_name, u.phone, u.address, " +
                     "u.date_of_birth, u.profile_photo, u.account_status, " +
                     "m.membership_id, m.membership_number, m.membership_type, " +
                     "m.issue_date, m.expiry_date, m.max_books_allowed, m.is_active " +
                     "FROM Users u " +
                     "JOIN Memberships m ON u.user_id = m.user_id " +
                     "WHERE m.membership_number = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, membershipNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapToMemberDetail(rs);
                }
            }
        }
        return null;
    }

    private MemberDetail mapToMemberDetail(ResultSet rs) throws SQLException {
        MemberDetail detail = new MemberDetail();
        
        // User fields
        detail.userId = rs.getInt("user_id");
        detail.username = rs.getString("username");
        detail.email = rs.getString("email");
        detail.fullName = rs.getString("full_name");
        detail.phone = rs.getString("phone");
        detail.address = rs.getString("address");
        detail.dateOfBirth = rs.getDate("date_of_birth");
        detail.profilePhoto = rs.getString("profile_photo");
        detail.accountStatus = rs.getString("account_status");
        
        // Membership fields
        if (rs.getObject("membership_id") != null) {
            detail.membershipId = rs.getInt("membership_id");
            detail.membershipNumber = rs.getString("membership_number");
            detail.membershipType = rs.getString("membership_type");
            detail.issueDate = rs.getDate("issue_date");
            detail.expiryDate = rs.getDate("expiry_date");
            detail.maxBooksAllowed = rs.getInt("max_books_allowed");
            detail.isActive = rs.getBoolean("is_active");
        }
        
        return detail;
    }

    /**
     * Update member information (excludes password and account_status)
     */
    public boolean updateMember(int userId, String email, String fullName, String phone, 
                                String address, Date dateOfBirth, String profilePhoto) throws SQLException {
        String sql = "UPDATE Users SET email = ?, full_name = ?, phone = ?, address = ?, " +
                     "date_of_birth = ?, profile_photo = ? WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, fullName);
            ps.setString(3, phone);
            ps.setString(4, address);
            ps.setDate(5, dateOfBirth);
            ps.setString(6, profilePhoto);
            ps.setInt(7, userId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Renew membership - extend expiry date
     * If membership is expired, renew from current date; otherwise extend from current expiry date
     * Ensures expiry_date > issue_date constraint is maintained
     */
    public boolean renewMembership(int userId, int extensionMonths) throws SQLException {
        // Check current expiry date to decide renewal logic
        String checkSql = "SELECT expiry_date, issue_date FROM Memberships WHERE user_id = ?";
        java.sql.Date currentExpiry = null;
        java.sql.Date issueDate = null;
        
        try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    currentExpiry = rs.getDate("expiry_date");
                    issueDate = rs.getDate("issue_date");
                } else {
                    return false; // Membership not found
                }
            }
        }
        
        // Calculate new expiry date
        java.sql.Date newExpiryDate;
        java.util.Date today = new java.util.Date();
        java.sql.Date todaySql = new java.sql.Date(today.getTime());
        
        // If membership is expired, renew from today; otherwise extend from current expiry
        if (currentExpiry != null && currentExpiry.before(todaySql)) {
            // Expired: renew from today
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(todaySql);
            cal.add(java.util.Calendar.MONTH, extensionMonths);
            newExpiryDate = new java.sql.Date(cal.getTimeInMillis());
            
            // Ensure new expiry > issue_date (constraint)
            if (issueDate != null && newExpiryDate.before(issueDate) || newExpiryDate.equals(issueDate)) {
                // If somehow new expiry would be before issue, set to issue_date + extension
                cal.setTime(issueDate);
                cal.add(java.util.Calendar.MONTH, extensionMonths);
                newExpiryDate = new java.sql.Date(cal.getTimeInMillis());
            }
        } else {
            // Not expired: extend from current expiry
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.setTime(currentExpiry);
            cal.add(java.util.Calendar.MONTH, extensionMonths);
            newExpiryDate = new java.sql.Date(cal.getTimeInMillis());
        }
        
        // Update membership
        String sql = "UPDATE Memberships SET expiry_date = ?, is_active = TRUE WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, newExpiryDate);
            ps.setInt(2, userId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Lock or unlock member account
     */
    public boolean lockUnlockAccount(int userId, String newStatus) throws SQLException {
        if (!newStatus.equals("active") && !newStatus.equals("locked") && !newStatus.equals("suspended")) {
            throw new IllegalArgumentException("Invalid account status: " + newStatus);
        }
        
        String sql = "UPDATE Users SET account_status = ? WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, userId);
            
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Check if username exists in database
     * @param username - Username to check
     * @return true if username exists, false otherwise
     * @throws SQLException
     */
    public boolean usernameExists(String username) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE username = ? LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Check if email exists in database
     * @param email - Email to check
     * @return true if email exists, false otherwise
     * @throws SQLException
     */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM Users WHERE email = ? LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, email.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Search members by username, email, or membership number
     */
    public List<MemberDetail> searchMembers(String searchTerm) throws SQLException {
        List<MemberDetail> results = new ArrayList<>();
        String sql = "SELECT u.user_id, u.username, u.email, u.full_name, u.phone, u.address, " +
                     "u.date_of_birth, u.profile_photo, u.account_status, " +
                     "m.membership_id, m.membership_number, m.membership_type, " +
                     "m.issue_date, m.expiry_date, m.max_books_allowed, m.is_active " +
                     "FROM Users u " +
                     "LEFT JOIN Memberships m ON u.user_id = m.user_id " +
                     "WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member') " +
                     "AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ? " +
                     "     OR m.membership_number LIKE ?) " +
                     "ORDER BY u.full_name";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String searchPattern = "%" + searchTerm + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setString(3, searchPattern);
            ps.setString(4, searchPattern);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(mapToMemberDetail(rs));
                }
            }
        }
        return results;
    }

    /**
     * Count members for search/filter
     */
    public int countMembers(String searchTerm, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Users u WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name='Member')"
        );
        List<Object> params = new ArrayList<>();
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ?)");
            String p = "%" + searchTerm + "%";
            params.add(p); params.add(p); params.add(p);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND u.account_status = ?");
            params.add(status);
        }
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return rs.getInt(1); }
        }
        return 0;
    }

    /**
     * Paged search members with status filter
     */
    public List<MemberDetail> searchMembersPaged(String searchTerm, String status, int offset, int limit) throws SQLException {
        List<MemberDetail> results = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT u.user_id, u.username, u.email, u.full_name, u.phone, u.address, " +
            "u.date_of_birth, u.profile_photo, u.account_status, " +
            "m.membership_id, m.membership_number, m.membership_type, m.issue_date, m.expiry_date, m.max_books_allowed, m.is_active " +
            "FROM Users u LEFT JOIN Memberships m ON u.user_id = m.user_id " +
            "WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member')"
        );
        List<Object> params = new ArrayList<>();
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ? OR m.membership_number LIKE ?)");
            String p = "%" + searchTerm + "%";
            params.add(p); params.add(p); params.add(p); params.add(p);
        }
        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status)) {
            sql.append(" AND u.account_status = ?");
            params.add(status);
        }
        sql.append(" ORDER BY u.full_name LIMIT ? OFFSET ?");
        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object o : params) { ps.setObject(idx++, o); }
            ps.setInt(idx++, limit);
            ps.setInt(idx, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) results.add(mapToMemberDetail(rs));
            }
        }
        return results;
    }

    /**
     * One-time corrective task: ensure expiry_date is after issue_date.
     * If expiry_date is null or not greater than issue_date, set it based on membership_type
     * (basic/premium: +12 months, student: +6 months).
     */
    public int fixIncorrectExpiry() throws SQLException {
        String sql = "UPDATE Memberships m SET m.expiry_date = CASE " +
                "WHEN m.membership_type = 'student' THEN DATE_ADD(m.issue_date, INTERVAL 6 MONTH) " +
                "ELSE DATE_ADD(m.issue_date, INTERVAL 12 MONTH) END " +
                "WHERE m.expiry_date IS NULL OR m.expiry_date <= m.issue_date";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            return ps.executeUpdate();
        }
    }

    /**
     * Member detail class combining User and Membership data
     */
    public static class MemberDetail {
        public int userId;
        public String username;
        public String email;
        public String fullName;
        public String phone;
        public String address;
        public Date dateOfBirth;
        public String profilePhoto;
        public String accountStatus;
        
        public Integer membershipId;
        public String membershipNumber;
        public String membershipType;
        public Date issueDate;
        public Date expiryDate;
        public Integer maxBooksAllowed;
        public Boolean isActive;
    }
}


