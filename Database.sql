-- ============================================
-- LIBRARY MANAGEMENT SYSTEM - COMPLETE DATABASE v2.0
-- Normalized to 3NF with Full Features
-- Support for 26 Use Cases
-- ============================================

-- ============================================
-- PART 1: DROP AND CREATE DATABASE
-- ============================================

DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library_management;

-- ============================================
-- PART 2: CREATE ALL TABLES
-- ============================================

-- TABLE 1: ROLES
CREATE TABLE Roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 2: USERS
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    role_id INT NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    profile_photo VARCHAR(255),
    account_status ENUM('active', 'locked', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id),
    INDEX idx_email (email),
    INDEX idx_role (role_id),
    INDEX idx_status (account_status),
    INDEX idx_username (username)
) ENGINE=InnoDB;

-- TABLE 3: MEMBERSHIPS
CREATE TABLE Memberships (
    membership_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    membership_number VARCHAR(50) NOT NULL UNIQUE,
    membership_type ENUM('basic', 'premium', 'student') DEFAULT 'basic',
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    max_books_allowed INT DEFAULT 5,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT chk_expiry_after_issue CHECK (expiry_date > issue_date),
    INDEX idx_membership_number (membership_number),
    INDEX idx_active (is_active)
) ENGINE=InnoDB;

-- TABLE 4: CATEGORIES
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_parent (parent_category_id)
) ENGINE=InnoDB;

-- TABLE 5: AUTHORS
CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL,
    biography TEXT,
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_author_name (author_name)
) ENGINE=InnoDB;

-- TABLE 6: PUBLISHERS
CREATE TABLE Publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_publisher_name (publisher_name)
) ENGINE=InnoDB;

-- TABLE 7: BOOKS
CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    publisher_id INT NOT NULL,
    publication_year YEAR,
    edition VARCHAR(50),
    language VARCHAR(50) DEFAULT 'English',
    pages INT,
    description TEXT,
    shelf_location VARCHAR(50),
    cover_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id),
    INDEX idx_title (title),
    INDEX idx_isbn (isbn),
    INDEX idx_category (category_id),
    FULLTEXT idx_fulltext_search (title, description)
) ENGINE=InnoDB;

-- TABLE 8: BOOK_AUTHORS
CREATE TABLE Book_Authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- TABLE 9: BOOK_COPIES
CREATE TABLE Book_Copies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    copy_number VARCHAR(50) NOT NULL,
    acquisition_date DATE NOT NULL,
    condition_status ENUM('excellent', 'good', 'fair', 'poor', 'damaged') DEFAULT 'excellent',
    availability_status ENUM('available', 'borrowed', 'reserved', 'maintenance', 'lost') DEFAULT 'available',
    price DECIMAL(10, 2),
    notes TEXT,
    last_scanned_at TIMESTAMP NULL COMMENT 'Last time scanned by kiosk/RFID system',
    requires_inspection BOOLEAN DEFAULT FALSE COMMENT 'Flag for manual inspection after self-return',
    UNIQUE KEY unique_copy (book_id, copy_number),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    INDEX idx_status (availability_status),
    INDEX idx_book (book_id),
    INDEX idx_inspection (requires_inspection)
) ENGINE=InnoDB;

-- TABLE 10: BORROW_REQUESTS (NEW - for online borrowing)
CREATE TABLE Borrow_Requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    copy_id INT NULL COMMENT 'Assigned copy when approved',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_status ENUM('pending', 'approved', 'rejected', 'picked_up', 'cancelled', 'expired') DEFAULT 'pending',
    pickup_ready_date TIMESTAMP NULL,
    pickup_expiry_date TIMESTAMP NULL,
    actual_pickup_date TIMESTAMP NULL,
    processed_by INT NULL,
    processed_date TIMESTAMP NULL,
    rejection_reason TEXT,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (copy_id) REFERENCES Book_Copies(copy_id),
    FOREIGN KEY (processed_by) REFERENCES Users(user_id),
    INDEX idx_user (user_id),
    INDEX idx_status (request_status),
    INDEX idx_book (book_id),
    INDEX idx_pickup_ready (pickup_ready_date),
    INDEX idx_status_user (request_status, user_id),
    INDEX idx_pickup_expiry (pickup_expiry_date)
) ENGINE=InnoDB;

-- TABLE 11: BORROWING_TRANSACTIONS
CREATE TABLE Borrowing_Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    copy_id INT NOT NULL,
    user_id INT NOT NULL,
    librarian_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    renewal_count INT DEFAULT 0,
    transaction_status ENUM('borrowed', 'returned', 'overdue', 'lost') DEFAULT 'borrowed',
    borrow_method ENUM('counter', 'online_request', 'self_checkout') DEFAULT 'counter' COMMENT 'Method used to borrow',
    return_method ENUM('counter', 'drop_box', 'kiosk', 'scheduled') DEFAULT 'counter' COMMENT 'Method used to return',
    pickup_date TIMESTAMP NULL COMMENT 'When reader picked up the book (for online requests)',
    borrow_request_id INT NULL COMMENT 'Link to borrow request if borrowed via online',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES Book_Copies(copy_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (librarian_id) REFERENCES Users(user_id),
    FOREIGN KEY (borrow_request_id) REFERENCES Borrow_Requests(request_id) ON DELETE SET NULL,
    CONSTRAINT chk_due_after_borrow CHECK (due_date > borrow_date),
    CONSTRAINT chk_return_after_borrow CHECK (return_date IS NULL OR return_date >= borrow_date),
    INDEX idx_user (user_id),
    INDEX idx_status (transaction_status),
    INDEX idx_dates (borrow_date, due_date),
    INDEX idx_copy (copy_id),
    INDEX idx_user_status (user_id, transaction_status),
    INDEX idx_copy_status (copy_id, transaction_status),
    INDEX idx_borrow_method (borrow_method),
    INDEX idx_return_method (return_method),
    INDEX idx_borrow_request (borrow_request_id)
) ENGINE=InnoDB;

-- TABLE 12: RENEWALS
CREATE TABLE Renewals (
    renewal_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    old_due_date DATE NOT NULL,
    new_due_date DATE NOT NULL,
    renewal_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_by INT NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES Borrowing_Transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (processed_by) REFERENCES Users(user_id),
    INDEX idx_transaction (transaction_id)
) ENGINE=InnoDB;

-- TABLE 13: RENEWAL_REQUESTS
CREATE TABLE Renewal_Requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    user_id INT NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    request_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    processed_by INT NULL,
    processed_date TIMESTAMP NULL,
    rejection_reason TEXT,
    FOREIGN KEY (transaction_id) REFERENCES Borrowing_Transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (processed_by) REFERENCES Users(user_id),
    INDEX idx_status (request_status),
    INDEX idx_user (user_id),
    INDEX idx_transaction (transaction_id)
) ENGINE=InnoDB;

-- TABLE 14: RETURN_SCHEDULES (NEW - for scheduled returns)
CREATE TABLE Return_Schedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    user_id INT NOT NULL,
    scheduled_return_date DATETIME NOT NULL,
    notification_sent BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES Borrowing_Transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    INDEX idx_transaction (transaction_id),
    INDEX idx_scheduled_date (scheduled_return_date),
    INDEX idx_user (user_id)
) ENGINE=InnoDB;

-- Reservations feature removed

-- TABLE 16: FINES
CREATE TABLE Fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    user_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    fine_reason VARCHAR(255) NOT NULL,
    days_overdue INT,
    fine_date DATE NOT NULL,
    payment_status ENUM('unpaid', 'paid', 'waived') DEFAULT 'unpaid',
    payment_date DATE NULL,
    payment_method VARCHAR(50) NULL,
    processed_by INT NULL,
    notes TEXT,
    FOREIGN KEY (transaction_id) REFERENCES Borrowing_Transactions(transaction_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (processed_by) REFERENCES Users(user_id),
    INDEX idx_user (user_id),
    INDEX idx_status (payment_status),
    INDEX idx_transaction (transaction_id),
    INDEX idx_user_payment (user_id, payment_status)
) ENGINE=InnoDB;

-- TABLE 17: NOTIFICATIONS
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    notification_type ENUM('due_reminder', 'overdue', 'reservation_available', 'membership_expiry', 'renewal_approved', 'renewal_rejected', 'general') NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_id INT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_type (notification_type),
    INDEX idx_user_type_read (user_id, notification_type, is_read)
) ENGINE=InnoDB;

-- TABLE 18: ACTIVITY_LOGS
CREATE TABLE Activity_Logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    table_affected VARCHAR(50),
    record_id INT,
    description TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    INDEX idx_user (user_id),
    INDEX idx_action (action_type),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- TABLE 19: SYSTEM_SETTINGS
CREATE TABLE System_Settings (
    setting_id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================
-- PART 3: INSERT INITIAL DATA
-- ============================================

-- Insert Roles
INSERT INTO Roles (role_name, description) VALUES
('Librarian', 'Library staff with full administrative access'),
('Member', 'Library member with borrowing privileges');

-- Insert System Settings (including new settings)
INSERT INTO System_Settings (setting_key, setting_value, description) VALUES
('max_borrow_days', '14', 'Maximum days for borrowing books'),
('max_renewal_count', '2', 'Maximum number of renewals allowed'),
('fine_per_day', '1.00', 'Fine amount per day for overdue books'),
('max_books_per_member', '5', 'Maximum books a member can borrow'),
('membership_validity_months', '12', 'Membership validity in months'),
('renewal_extend_days', '14', 'Number of days to extend on renewal'),
('pickup_expiry_days', '3', 'Days to pickup approved borrow request before expiry'),
('max_pending_requests', '3', 'Maximum pending borrow requests per member'),
('require_inspection_after_self_return', 'true', 'Flag copies for inspection after self-return');

-- ============================================
-- PART 4: CREATE ALL FUNCTIONS
-- ============================================

DELIMITER //

-- Function 1: Check Borrow Limit
CREATE FUNCTION fn_check_borrow_limit(p_user_id INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE current_borrows INT;
    DECLARE max_allowed INT;

    SELECT COUNT(*) INTO current_borrows
    FROM Borrowing_Transactions
    WHERE user_id = p_user_id
    AND transaction_status IN ('borrowed', 'overdue');

    SELECT max_books_allowed INTO max_allowed
    FROM Memberships
    WHERE user_id = p_user_id AND is_active = TRUE;

    IF max_allowed IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN current_borrows < max_allowed;
END//

-- Function 2: Calculate Fine Amount
CREATE FUNCTION fn_calculate_fine(p_transaction_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_days_overdue INT;
    DECLARE v_fine_per_day DECIMAL(10,2);
    DECLARE v_total_fine DECIMAL(10,2);

    SELECT DATEDIFF(CURDATE(), due_date) INTO v_days_overdue
    FROM Borrowing_Transactions
    WHERE transaction_id = p_transaction_id
    AND return_date IS NULL;

    IF v_days_overdue IS NULL OR v_days_overdue <= 0 THEN
        RETURN 0.00;
    END IF;

    SELECT CAST(setting_value AS DECIMAL(10,2)) INTO v_fine_per_day
    FROM System_Settings
    WHERE setting_key = 'fine_per_day';

    SET v_total_fine = v_days_overdue * v_fine_per_day;

    RETURN v_total_fine;
END//

-- Function 3: Check Renewal Eligibility
CREATE FUNCTION fn_check_renewal_eligibility(p_transaction_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_renewal_count INT;
    DECLARE v_max_renewals INT;

    SELECT bt.renewal_count INTO v_renewal_count
    FROM Borrowing_Transactions bt
    WHERE bt.transaction_id = p_transaction_id;

    SELECT CAST(setting_value AS DECIMAL) INTO v_max_renewals
    FROM System_Settings
    WHERE setting_key = 'max_renewal_count';

    IF v_renewal_count >= v_max_renewals THEN
        RETURN 'Maximum renewals reached';
    END IF;

    RETURN 'Eligible';
END//

-- Function 4: Get Available Copy for Book
CREATE FUNCTION fn_get_available_copy(p_book_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_copy_id INT;

    SELECT copy_id INTO v_copy_id
    FROM Book_Copies
    WHERE book_id = p_book_id
    AND availability_status = 'available'
    AND condition_status IN ('excellent', 'good', 'fair')
    ORDER BY condition_status DESC, copy_id ASC
    LIMIT 1;

    RETURN v_copy_id;
END//

-- Function 5: Check Membership Validity
CREATE FUNCTION fn_check_membership_valid(p_user_id INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_is_valid BOOLEAN;

    SELECT (expiry_date >= CURDATE() AND is_active = TRUE) INTO v_is_valid
    FROM Memberships
    WHERE user_id = p_user_id;

    RETURN COALESCE(v_is_valid, FALSE);
END//

-- Function 6: Check if user has pending borrow requests (NEW)
CREATE FUNCTION fn_has_pending_borrow_request(p_user_id INT, p_book_id INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_has_request INT;

    SELECT COUNT(*) INTO v_has_request
    FROM Borrow_Requests
    WHERE user_id = p_user_id
    AND book_id = p_book_id
    AND request_status IN ('pending', 'approved');

    RETURN v_has_request > 0;
END//

-- Function 7: Check borrow request limit (NEW)
CREATE FUNCTION fn_check_borrow_request_limit(p_user_id INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_pending_requests INT;
    DECLARE v_max_requests INT DEFAULT 3;

    SELECT COUNT(*) INTO v_pending_requests
    FROM Borrow_Requests
    WHERE user_id = p_user_id
    AND request_status IN ('pending', 'approved');

    RETURN v_pending_requests < v_max_requests;
END//

-- Function 8: Get days until pickup expiry (NEW)
CREATE FUNCTION fn_days_until_pickup_expiry(p_request_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_days INT;

    SELECT DATEDIFF(pickup_expiry_date, NOW()) INTO v_days
    FROM Borrow_Requests
    WHERE request_id = p_request_id
    AND request_status = 'approved';

    RETURN COALESCE(v_days, 0);
END//

DELIMITER ;

-- ============================================
-- PART 5: CREATE ALL VIEWS
-- ============================================

-- View 1: Available Books
CREATE VIEW vw_Available_Books AS
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    c.category_name,
    GROUP_CONCAT(a.author_name ORDER BY ba.author_order SEPARATOR ', ') as authors,
    p.publisher_name,
    b.publication_year,
    b.language,
    b.shelf_location,
    COUNT(bc.copy_id) as total_copies,
    SUM(CASE WHEN bc.availability_status = 'available' THEN 1 ELSE 0 END) as available_copies,
    SUM(CASE WHEN bc.availability_status = 'borrowed' THEN 1 ELSE 0 END) as borrowed_copies,
    SUM(CASE WHEN bc.availability_status = 'reserved' THEN 1 ELSE 0 END) as reserved_copies
FROM Books b
LEFT JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id
LEFT JOIN Authors a ON ba.author_id = a.author_id
LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id
GROUP BY b.book_id, b.isbn, b.title, c.category_name, p.publisher_name, 
         b.publication_year, b.language, b.shelf_location;

-- View 2: Current Borrowings
CREATE VIEW vw_Current_Borrowings AS
SELECT 
    bt.transaction_id,
    u.user_id,
    u.full_name as member_name,
    u.email,
    u.phone,
    b.book_id,
    b.title as book_title,
    b.isbn,
    bc.copy_number,
    bc.copy_id,
    bt.borrow_date,
    bt.due_date,
    bt.renewal_count,
    bt.borrow_method,
    DATEDIFF(CURDATE(), bt.due_date) as days_overdue,
    bt.transaction_status,
    CASE 
        WHEN DATEDIFF(CURDATE(), bt.due_date) > 0 THEN 
            DATEDIFF(CURDATE(), bt.due_date) * (SELECT CAST(setting_value AS DECIMAL(10,2)) FROM System_Settings WHERE setting_key = 'fine_per_day')
        ELSE 0 
    END as potential_fine
FROM Borrowing_Transactions bt
JOIN Users u ON bt.user_id = u.user_id
JOIN Book_Copies bc ON bt.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE bt.transaction_status IN ('borrowed', 'overdue');

-- View 3: Overdue Books Detail
CREATE VIEW vw_Overdue_Books AS
SELECT 
    bt.transaction_id,
    u.user_id,
    u.full_name as member_name,
    u.email,
    u.phone,
    u.address,
    b.book_id,
    b.title as book_title,
    b.isbn,
    bc.copy_number,
    bt.borrow_date,
    bt.due_date,
    DATEDIFF(CURDATE(), bt.due_date) as days_overdue,
    (DATEDIFF(CURDATE(), bt.due_date) * 
     (SELECT CAST(setting_value AS DECIMAL(10,2)) FROM System_Settings WHERE setting_key = 'fine_per_day')) as calculated_fine,
    COALESCE(f.fine_amount, 0) as recorded_fine,
    COALESCE(f.payment_status, 'not_generated') as fine_status
FROM Borrowing_Transactions bt
JOIN Users u ON bt.user_id = u.user_id
JOIN Book_Copies bc ON bt.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
LEFT JOIN Fines f ON bt.transaction_id = f.transaction_id
WHERE bt.transaction_status = 'overdue'
ORDER BY days_overdue DESC;

-- View 4: Member Statistics
CREATE VIEW vw_Member_Statistics AS
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.phone,
    u.account_status,
    m.membership_type,
    m.expiry_date,
    m.is_active as membership_active,
    COUNT(DISTINCT bt.transaction_id) as total_borrowings,
    SUM(CASE WHEN bt.transaction_status IN ('borrowed', 'overdue') THEN 1 ELSE 0 END) as current_borrowings,
    SUM(CASE WHEN bt.transaction_status = 'overdue' THEN 1 ELSE 0 END) as overdue_count,
    COALESCE(SUM(f.fine_amount), 0) as total_fines,
    COALESCE(SUM(CASE WHEN f.payment_status = 'unpaid' THEN f.fine_amount ELSE 0 END), 0) as unpaid_fines,
    0 as active_reservations
FROM Users u
LEFT JOIN Memberships m ON u.user_id = m.user_id
LEFT JOIN Borrowing_Transactions bt ON u.user_id = bt.user_id
LEFT JOIN Fines f ON u.user_id = f.user_id
-- Reservations removed
WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member')
GROUP BY u.user_id, u.full_name, u.email, u.phone, u.account_status, 
         m.membership_type, m.expiry_date, m.is_active;

-- View 5: Popular Books
CREATE VIEW vw_Popular_Books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    c.category_name,
    GROUP_CONCAT(DISTINCT a.author_name ORDER BY ba.author_order SEPARATOR ', ') as authors,
    COUNT(DISTINCT bt.transaction_id) as total_borrows,
    COUNT(DISTINCT CASE WHEN bt.borrow_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN bt.transaction_id END) as borrows_last_month,
    0 as current_reservations,
    AVG(DATEDIFF(COALESCE(bt.return_date, CURDATE()), bt.borrow_date)) as avg_borrow_duration
FROM Books b
LEFT JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id
LEFT JOIN Authors a ON ba.author_id = a.author_id
LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id
LEFT JOIN Borrowing_Transactions bt ON bc.copy_id = bt.copy_id
-- Reservations removed
GROUP BY b.book_id, b.title, b.isbn, c.category_name
HAVING total_borrows > 0
ORDER BY total_borrows DESC;

-- View 6: Pending Renewal Requests
CREATE VIEW vw_Pending_Renewal_Requests AS
SELECT 
    rr.request_id,
    rr.request_date,
    u.user_id,
    u.full_name as member_name,
    u.email,
    b.title as book_title,
    bt.borrow_date,
    bt.due_date,
    bt.renewal_count,
    (SELECT CAST(setting_value AS DECIMAL) FROM System_Settings WHERE setting_key = 'max_renewal_count') as max_renewals,
    CASE 
        WHEN bt.renewal_count >= (SELECT CAST(setting_value AS DECIMAL) FROM System_Settings WHERE setting_key = 'max_renewal_count') 
        THEN 'Maximum renewals reached'
        ELSE 'Can be approved'
    END as eligibility_status
FROM Renewal_Requests rr
JOIN Borrowing_Transactions bt ON rr.transaction_id = bt.transaction_id
JOIN Users u ON rr.user_id = u.user_id
JOIN Book_Copies bc ON bt.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE rr.request_status = 'pending'
ORDER BY rr.request_date ASC;

-- View 7 removed: Active Reservations (Reservations module deprecated)

-- View 8: Pending Borrow Requests (NEW)
CREATE VIEW vw_Pending_Borrow_Requests AS
SELECT 
    br.request_id,
    br.request_date,
    br.request_status,
    u.user_id,
    u.full_name as member_name,
    u.email,
    u.phone,
    b.book_id,
    b.title as book_title,
    b.isbn,
    c.category_name,
    GROUP_CONCAT(DISTINCT a.author_name ORDER BY ba.author_order SEPARATOR ', ') as authors,
    (SELECT COUNT(*) 
     FROM Book_Copies bc 
     WHERE bc.book_id = b.book_id 
     AND bc.availability_status = 'available') as available_copies,
    CASE 
        WHEN NOT fn_check_membership_valid(u.user_id) THEN 'Membership expired'
        WHEN NOT fn_check_borrow_limit(u.user_id) THEN 'Borrow limit reached'
        WHEN (SELECT COUNT(*) FROM Book_Copies bc WHERE bc.book_id = b.book_id AND bc.availability_status = 'available') = 0 
        THEN 'No available copies'
        ELSE 'Ready to approve'
    END as approval_status
FROM Borrow_Requests br
JOIN Users u ON br.user_id = u.user_id
JOIN Books b ON br.book_id = b.book_id
LEFT JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id
LEFT JOIN Authors a ON ba.author_id = a.author_id
WHERE br.request_status = 'pending'
GROUP BY br.request_id, br.request_date, br.request_status, u.user_id, 
         u.full_name, u.email, u.phone, b.book_id, b.title, b.isbn, c.category_name
ORDER BY br.request_date ASC;

-- View 9: Books Ready for Pickup (NEW - FIXED)
CREATE VIEW vw_Books_Ready_For_Pickup AS
SELECT 
    br.request_id,
    br.pickup_ready_date,
    br.pickup_expiry_date,
    u.user_id,
    u.full_name as member_name,
    u.email,
    u.phone,
    b.book_id,
    b.title as book_title,
    b.shelf_location,
    bc.copy_id,
    bc.copy_number,
    bc.condition_status,
    DATEDIFF(br.pickup_expiry_date, NOW()) as days_until_expiry,
    CASE 
        WHEN DATEDIFF(br.pickup_expiry_date, NOW()) < 1 THEN 'Urgent - Expires today'
        WHEN DATEDIFF(br.pickup_expiry_date, NOW()) < 2 THEN 'Expires tomorrow'
        ELSE 'Normal'
    END as urgency_level
FROM Borrow_Requests br
JOIN Users u ON br.user_id = u.user_id
JOIN Books b ON br.book_id = b.book_id
JOIN Book_Copies bc ON br.copy_id = bc.copy_id
WHERE br.request_status = 'approved'
AND br.actual_pickup_date IS NULL
ORDER BY br.pickup_ready_date ASC;

-- View 10: Scheduled Returns (NEW)
CREATE VIEW vw_Scheduled_Returns AS
SELECT 
    rs.schedule_id,
    rs.scheduled_return_date,
    rs.notification_sent,
    u.user_id,
    u.full_name as member_name,
    u.email,
    u.phone,
    b.title as book_title,
    bt.borrow_date,
    bt.due_date,
    bt.transaction_id,
    CASE 
        WHEN rs.scheduled_return_date > bt.due_date THEN 'Will be late'
        ELSE 'On time'
    END as return_status
FROM Return_Schedules rs
JOIN Borrowing_Transactions bt ON rs.transaction_id = bt.transaction_id
JOIN Users u ON rs.user_id = u.user_id
JOIN Book_Copies bc ON bt.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE bt.return_date IS NULL
ORDER BY rs.scheduled_return_date ASC;

-- View 11: Member Outstanding Fines (NEW)
CREATE VIEW vw_Member_Outstanding_Fines AS
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    COUNT(f.fine_id) as total_fines_count,
    SUM(CASE WHEN f.payment_status = 'unpaid' THEN 1 ELSE 0 END) as unpaid_count,
    SUM(CASE WHEN f.payment_status = 'unpaid' THEN f.fine_amount ELSE 0 END) as total_unpaid_amount,
    SUM(CASE WHEN f.payment_status = 'paid' THEN f.fine_amount ELSE 0 END) as total_paid_amount,
    MAX(f.fine_date) as latest_fine_date
FROM Users u
LEFT JOIN Fines f ON u.user_id = f.user_id
WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member')
GROUP BY u.user_id, u.full_name, u.email
HAVING unpaid_count > 0
ORDER BY total_unpaid_amount DESC;

-- View 12: Borrowing Methods Statistics (NEW)
CREATE VIEW vw_Borrowing_Methods_Stats AS
SELECT 
    borrow_method,
    COUNT(*) as total_transactions,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(DATEDIFF(COALESCE(return_date, CURDATE()), borrow_date)) as avg_borrow_days,
    SUM(CASE WHEN transaction_status = 'overdue' THEN 1 ELSE 0 END) as overdue_count
FROM Borrowing_Transactions
GROUP BY borrow_method;

-- View 13: Librarian Daily Tasks (NEW)
CREATE VIEW vw_Librarian_Daily_Tasks AS
SELECT 
    'Pending Borrow Requests' as task_type,
    COUNT(*) as count,
    'Review and approve/reject' as action_needed
FROM Borrow_Requests
WHERE request_status = 'pending'

UNION ALL

SELECT 
    'Books Ready for Pickup',
    COUNT(*),
    'Prepare books and notify members'
FROM Borrow_Requests
WHERE request_status = 'approved'
AND actual_pickup_date IS NULL
AND pickup_expiry_date >= NOW()

UNION ALL

SELECT 
    'Expired Pickup Requests',
    COUNT(*),
    'Release reserved copies'
FROM Borrow_Requests
WHERE request_status = 'approved'
AND actual_pickup_date IS NULL
AND pickup_expiry_date < NOW()

UNION ALL

SELECT 
    'Pending Renewal Requests',
    COUNT(*),
    'Approve or reject renewals'
FROM Renewal_Requests
WHERE request_status = 'pending'

UNION ALL

SELECT 
    'Overdue Books',
    COUNT(*),
    'Send reminders and process fines'
FROM Borrowing_Transactions
WHERE transaction_status = 'overdue'

UNION ALL

SELECT 
    'Books Requiring Inspection',
    COUNT(*),
    'Check condition after self-return'
FROM Book_Copies
WHERE requires_inspection = TRUE

;

-- ============================================
-- PART 6: CREATE ALL TRIGGERS
-- ============================================

DELIMITER //

-- Trigger 1: Update Copy Status on Borrow
CREATE TRIGGER trg_update_copy_on_borrow
AFTER INSERT ON Borrowing_Transactions
FOR EACH ROW
BEGIN
    UPDATE Book_Copies 
    SET availability_status = 'borrowed'
    WHERE copy_id = NEW.copy_id;
    
    -- Log activity
    INSERT INTO Activity_Logs (user_id, action_type, table_affected, record_id, description)
    VALUES (NEW.librarian_id, 'BORROW_BOOK', 'Borrowing_Transactions', NEW.transaction_id, 
            CONCAT('Book borrowed by user_id: ', NEW.user_id));
END//

-- Trigger 2: Update Copy Status on Return
CREATE TRIGGER trg_update_copy_on_return
AFTER UPDATE ON Borrowing_Transactions
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE Book_Copies 
        SET availability_status = 'available'
        WHERE copy_id = NEW.copy_id;
        
        -- Log activity
        INSERT INTO Activity_Logs (user_id, action_type, table_affected, record_id, description)
        VALUES (NEW.user_id, 'RETURN_BOOK', 'Borrowing_Transactions', NEW.transaction_id, 
                'Book returned successfully');
    END IF;
END//

-- Trigger 3: Check Overdue and Create Notification
CREATE TRIGGER trg_check_overdue
AFTER UPDATE ON Borrowing_Transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_status = 'overdue' AND OLD.transaction_status != 'overdue' THEN
        -- Create notification
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (NEW.user_id, 'overdue', 'Book Overdue', 
                CONCAT('Your borrowed book is now overdue. Please return it as soon as possible. Transaction ID: ', NEW.transaction_id),
                NEW.transaction_id);
        
        -- Auto-generate fine
        INSERT INTO Fines (transaction_id, user_id, fine_amount, fine_reason, days_overdue, fine_date)
        SELECT 
            NEW.transaction_id,
            NEW.user_id,
            fn_calculate_fine(NEW.transaction_id),
            'Late return penalty',
            DATEDIFF(CURDATE(), NEW.due_date),
            CURDATE()
        WHERE NOT EXISTS (
            SELECT 1 FROM Fines WHERE transaction_id = NEW.transaction_id
        );
    END IF;
END//

-- Reservations trigger removed

-- Trigger 5: Update Membership Status on Expiry
CREATE TRIGGER trg_check_membership_expiry
BEFORE UPDATE ON Memberships
FOR EACH ROW
BEGIN
    IF NEW.expiry_date < CURDATE() AND OLD.is_active = TRUE THEN
        SET NEW.is_active = FALSE;
        
        -- Create notification
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (NEW.user_id, 'membership_expiry', 'Membership Expired', 
                'Your library membership has expired. Please renew to continue borrowing.',
                NEW.membership_id);
    END IF;
END//

-- Reservations trigger removed

-- Trigger 7: Log User Account Changes
CREATE TRIGGER trg_log_user_changes
AFTER UPDATE ON Users
FOR EACH ROW
BEGIN
    IF OLD.account_status != NEW.account_status THEN
        INSERT INTO Activity_Logs (user_id, action_type, table_affected, record_id, description)
        VALUES (NEW.user_id, 'ACCOUNT_STATUS_CHANGE', 'Users', NEW.user_id, 
                CONCAT('Account status changed from ', OLD.account_status, ' to ', NEW.account_status));
    END IF;
END//

-- Trigger 8: Prevent Borrowing with Invalid Membership
CREATE TRIGGER trg_check_membership_before_borrow
BEFORE INSERT ON Borrowing_Transactions
FOR EACH ROW
BEGIN
    IF NOT fn_check_membership_valid(NEW.user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot borrow: Membership is expired or inactive';
    END IF;
    
    IF NOT fn_check_borrow_limit(NEW.user_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot borrow: Maximum book limit reached';
    END IF;
END//

-- Trigger 9: Update Fine on Payment
CREATE TRIGGER trg_log_fine_payment
AFTER UPDATE ON Fines
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'paid' AND OLD.payment_status = 'unpaid' THEN
        INSERT INTO Activity_Logs (user_id, action_type, table_affected, record_id, description)
        VALUES (NEW.processed_by, 'FINE_PAYMENT', 'Fines', NEW.fine_id, 
                CONCAT('Fine paid: $', NEW.fine_amount, ' by user_id: ', NEW.user_id));
        
        -- Create notification
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (NEW.user_id, 'general', 'Fine Payment Confirmed', 
                CONCAT('Your fine payment of $', NEW.fine_amount, ' has been processed.'),
                NEW.fine_id);
    END IF;
END//

-- Trigger 10: Process Renewal Request Approval
CREATE TRIGGER trg_process_renewal_approval
AFTER UPDATE ON Renewal_Requests
FOR EACH ROW
BEGIN
    DECLARE v_old_due_date DATE;
    DECLARE v_new_due_date DATE;
    DECLARE v_extend_days INT;
    
    IF NEW.request_status = 'approved' AND OLD.request_status = 'pending' THEN
        -- Get current due date
        SELECT due_date INTO v_old_due_date
        FROM Borrowing_Transactions
        WHERE transaction_id = NEW.transaction_id;
        
        -- Get extension days from settings
        SELECT CAST(setting_value AS DECIMAL) INTO v_extend_days
        FROM System_Settings
        WHERE setting_key = 'renewal_extend_days';
        
        -- Calculate new due date
        SET v_new_due_date = DATE_ADD(v_old_due_date, INTERVAL v_extend_days DAY);
        
        -- Update borrowing transaction
        UPDATE Borrowing_Transactions
        SET due_date = v_new_due_date,
            renewal_count = renewal_count + 1
        WHERE transaction_id = NEW.transaction_id;
        
        -- Insert renewal record
        INSERT INTO Renewals (transaction_id, old_due_date, new_due_date, processed_by)
        VALUES (NEW.transaction_id, v_old_due_date, v_new_due_date, NEW.processed_by);
        
        -- Create notification
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (NEW.user_id, 'renewal_approved', 'Renewal Approved', 
                CONCAT('Your renewal request has been approved. New due date: ', v_new_due_date),
                NEW.request_id);
                
    ELSEIF NEW.request_status = 'rejected' AND OLD.request_status = 'pending' THEN
        -- Create notification for rejection
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (NEW.user_id, 'renewal_rejected', 'Renewal Rejected', 
                CONCAT('Your renewal request has been rejected. Reason: ', COALESCE(NEW.rejection_reason, 'Not specified')),
                NEW.request_id);
    END IF;
END//

-- Trigger 11: Notify on Borrow Request Status Change (NEW)
CREATE TRIGGER trg_notify_borrow_request_status
AFTER UPDATE ON Borrow_Requests
FOR EACH ROW
BEGIN
    IF NEW.request_status = 'rejected' AND OLD.request_status = 'pending' THEN
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (
            NEW.user_id,
            'general',
            'Borrow Request Rejected',
            CONCAT('Your borrow request for "',
                   (SELECT title FROM Books WHERE book_id = NEW.book_id),
                   '" has been rejected. Reason: ', 
                   COALESCE(NEW.rejection_reason, 'Not specified')),
            NEW.request_id
        );
    END IF;
END//

-- Trigger 12: Log Self-Service Activities (NEW)
CREATE TRIGGER trg_log_self_service
AFTER INSERT ON Borrowing_Transactions
FOR EACH ROW
BEGIN
    IF NEW.borrow_method IN ('self_checkout', 'online_request') THEN
        INSERT INTO Activity_Logs (user_id, action_type, table_affected, record_id, description)
        VALUES (
            NEW.user_id,
            CONCAT('SELF_SERVICE_BORROW_', UPPER(NEW.borrow_method)),
            'Borrowing_Transactions',
            NEW.transaction_id,
            CONCAT('Self-service borrow via ', NEW.borrow_method)
        );
    END IF;
END//

DELIMITER ;

-- ============================================
-- PART 7: CREATE ALL STORED PROCEDURES
-- ============================================

DELIMITER //

-- Procedure 1: Most Borrowed Books Report
CREATE PROCEDURE sp_most_borrowed_books(
    IN p_period_days INT,
    IN p_limit INT
)
BEGIN
    SELECT 
        b.book_id,
        b.title,
        b.isbn,
        c.category_name,
        GROUP_CONCAT(DISTINCT a.author_name ORDER BY ba.author_order SEPARATOR ', ') as authors,
        COUNT(bt.transaction_id) as borrow_count,
        COUNT(DISTINCT bt.user_id) as unique_borrowers,
        AVG(DATEDIFF(COALESCE(bt.return_date, CURDATE()), bt.borrow_date)) as avg_borrow_duration
    FROM Books b
    JOIN Categories c ON b.category_id = c.category_id
    LEFT JOIN Book_Authors ba ON b.book_id = ba.book_id
    LEFT JOIN Authors a ON ba.author_id = a.author_id
    JOIN Book_Copies bc ON b.book_id = bc.book_id
    JOIN Borrowing_Transactions bt ON bc.copy_id = bt.copy_id
    WHERE bt.borrow_date >= DATE_SUB(CURDATE(), INTERVAL p_period_days DAY)
    GROUP BY b.book_id, b.title, b.isbn, c.category_name
    ORDER BY borrow_count DESC
    LIMIT p_limit;
END//

-- Procedure 2: Most Active Members Report
CREATE PROCEDURE sp_most_active_members(
    IN p_period_days INT,
    IN p_limit INT
)
BEGIN
    SELECT 
        u.user_id,
        u.full_name,
        u.email,
        u.phone,
        m.membership_type,
        COUNT(bt.transaction_id) as total_borrows,
        SUM(CASE WHEN bt.transaction_status = 'returned' THEN 1 ELSE 0 END) as returned_count,
        SUM(CASE WHEN bt.transaction_status = 'overdue' THEN 1 ELSE 0 END) as overdue_count,
        COALESCE(SUM(f.fine_amount), 0) as total_fines
    FROM Users u
    JOIN Memberships m ON u.user_id = m.user_id
    JOIN Borrowing_Transactions bt ON u.user_id = bt.user_id
    LEFT JOIN Fines f ON bt.transaction_id = f.transaction_id
    WHERE bt.borrow_date >= DATE_SUB(CURDATE(), INTERVAL p_period_days DAY)
    GROUP BY u.user_id, u.full_name, u.email, u.phone, m.membership_type
    ORDER BY total_borrows DESC
    LIMIT p_limit;
END//

-- Procedure 3: Fine Revenue Report
CREATE PROCEDURE sp_fine_revenue_report(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        DATE(fine_date) as date,
        COUNT(*) as total_fines,
        SUM(fine_amount) as total_amount,
        SUM(CASE WHEN payment_status = 'paid' THEN fine_amount ELSE 0 END) as collected_amount,
        SUM(CASE WHEN payment_status = 'unpaid' THEN fine_amount ELSE 0 END) as pending_amount,
        SUM(CASE WHEN payment_status = 'waived' THEN fine_amount ELSE 0 END) as waived_amount,
        AVG(fine_amount) as avg_fine_amount
    FROM Fines
    WHERE fine_date BETWEEN p_start_date AND p_end_date
    GROUP BY DATE(fine_date)
    ORDER BY date DESC;
END//

-- Procedure 4: Category-wise Statistics
CREATE PROCEDURE sp_category_statistics()
BEGIN
    SELECT 
        c.category_id,
        c.category_name,
        COUNT(DISTINCT b.book_id) as total_books,
        SUM(CASE WHEN bc.availability_status = 'available' THEN 1 ELSE 0 END) as available_copies,
        COUNT(DISTINCT bt.transaction_id) as total_borrows,
        COUNT(DISTINCT CASE 
            WHEN bt.borrow_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) 
            THEN bt.transaction_id 
        END) as borrows_last_month
    FROM Categories c
    LEFT JOIN Books b ON c.category_id = b.category_id
    LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id
    LEFT JOIN Borrowing_Transactions bt ON bc.copy_id = bt.copy_id
    GROUP BY c.category_id, c.category_name
    ORDER BY total_borrows DESC;
END//

-- Procedure 5: Send Due Date Reminders
CREATE PROCEDURE sp_send_due_date_reminders()
BEGIN
    -- Send reminders for books due in 2 days
    INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
    SELECT 
        bt.user_id,
        'due_reminder',
        'Book Due Soon',
        CONCAT('Your borrowed book "', b.title, '" is due on ', bt.due_date, '. Please return it on time.'),
        bt.transaction_id
    FROM Borrowing_Transactions bt
    JOIN Book_Copies bc ON bt.copy_id = bc.copy_id
    JOIN Books b ON bc.book_id = b.book_id
    WHERE bt.transaction_status = 'borrowed'
    AND bt.due_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY)
    AND NOT EXISTS (
        SELECT 1 FROM Notifications n 
        WHERE n.user_id = bt.user_id 
        AND n.reference_id = bt.transaction_id
        AND n.notification_type = 'due_reminder'
        AND DATE(n.sent_date) = CURDATE()
    );
    
    SELECT ROW_COUNT() as reminders_sent;
END//

-- Procedure 6: Auto-mark Overdue Books
CREATE PROCEDURE sp_mark_overdue_books()
BEGIN
    UPDATE Borrowing_Transactions
    SET transaction_status = 'overdue'
    WHERE transaction_status = 'borrowed'
    AND due_date < CURDATE()
    AND return_date IS NULL;
    
    SELECT ROW_COUNT() as books_marked_overdue;
END//

-- Reservations procedure removed

-- Procedure 8: Borrow Book (Complete Transaction)
CREATE PROCEDURE sp_borrow_book(
    IN p_user_id INT,
    IN p_book_id INT,
    IN p_librarian_id INT,
    OUT p_result VARCHAR(255),
    OUT p_transaction_id INT
)
BEGIN
    DECLARE v_copy_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_borrow_days INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Transaction failed';
        SET p_transaction_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Check membership validity
    IF NOT fn_check_membership_valid(p_user_id) THEN
        SET p_result = 'Error: Membership is expired or inactive';
        SET p_transaction_id = NULL;
        ROLLBACK;
    ELSE
        -- Check borrow limit
        IF NOT fn_check_borrow_limit(p_user_id) THEN
            SET p_result = 'Error: Maximum book limit reached';
            SET p_transaction_id = NULL;
            ROLLBACK;
        ELSE
            -- Get available copy
            SET v_copy_id = fn_get_available_copy(p_book_id);
            
            IF v_copy_id IS NULL THEN
                SET p_result = 'Error: No available copies';
                SET p_transaction_id = NULL;
                ROLLBACK;
            ELSE
                -- Get borrow days from settings
                SELECT CAST(setting_value AS DECIMAL) INTO v_borrow_days
                FROM System_Settings
                WHERE setting_key = 'max_borrow_days';
                
                SET v_due_date = DATE_ADD(CURDATE(), INTERVAL v_borrow_days DAY);
                
                -- Create borrowing transaction
                INSERT INTO Borrowing_Transactions (copy_id, user_id, librarian_id, borrow_date, due_date)
                VALUES (v_copy_id, p_user_id, p_librarian_id, CURDATE(), v_due_date);
                
                SET p_transaction_id = LAST_INSERT_ID();
                SET p_result = 'Success: Book borrowed successfully';
                
                COMMIT;
            END IF;
        END IF;
    END IF;
END//

-- Procedure 9: Return Book (Complete Transaction)
CREATE PROCEDURE sp_return_book(
    IN p_transaction_id INT,
    IN p_condition_status ENUM('excellent', 'good', 'fair', 'poor', 'damaged'),
    OUT p_result VARCHAR(255),
    OUT p_fine_amount DECIMAL(10,2)
)
BEGIN
    DECLARE v_copy_id INT;
    DECLARE v_user_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_calculated_fine DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Transaction failed';
        SET p_fine_amount = 0;
    END;
    
    START TRANSACTION;
    
    -- Get transaction details
    SELECT copy_id, user_id, due_date INTO v_copy_id, v_user_id, v_due_date
    FROM Borrowing_Transactions
    WHERE transaction_id = p_transaction_id
    AND return_date IS NULL;
    
    IF v_copy_id IS NULL THEN
        SET p_result = 'Error: Transaction not found or already returned';
        SET p_fine_amount = 0;
        ROLLBACK;
    ELSE
        -- Update transaction
        UPDATE Borrowing_Transactions
        SET return_date = CURDATE(),
            transaction_status = 'returned'
        WHERE transaction_id = p_transaction_id;
        
        -- Update copy condition
        UPDATE Book_Copies
        SET condition_status = p_condition_status
        WHERE copy_id = v_copy_id;
        
        -- Calculate fine if overdue
        SET v_calculated_fine = fn_calculate_fine(p_transaction_id);
        SET p_fine_amount = v_calculated_fine;
        
        IF v_calculated_fine > 0 THEN
            INSERT INTO Fines (transaction_id, user_id, fine_amount, fine_reason, days_overdue, fine_date)
            VALUES (
                p_transaction_id, 
                v_user_id, 
                v_calculated_fine, 
                'Late return penalty',
                DATEDIFF(CURDATE(), v_due_date),
                CURDATE()
            );
            SET p_result = CONCAT('Success: Book returned with fine of $', v_calculated_fine);
        ELSE
            SET p_result = 'Success: Book returned on time';
        END IF;
        
        COMMIT;
    END IF;
END//

-- Procedure 10: Dashboard Statistics
CREATE PROCEDURE sp_dashboard_statistics()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM Books) as total_books,
        (SELECT COUNT(*) FROM Book_Copies WHERE availability_status = 'available') as available_copies,
        (SELECT COUNT(*) FROM Users WHERE role_id = (SELECT role_id FROM Roles WHERE role_name = 'Member')) as total_members,
        (SELECT COUNT(*) FROM Borrowing_Transactions WHERE transaction_status IN ('borrowed', 'overdue')) as current_borrows,
        (SELECT COUNT(*) FROM Borrowing_Transactions WHERE transaction_status = 'overdue') as overdue_books,
        0 as active_reservations,
        (SELECT COALESCE(SUM(fine_amount), 0) FROM Fines WHERE payment_status = 'unpaid') as total_unpaid_fines,
        (SELECT COUNT(*) FROM Renewal_Requests WHERE request_status = 'pending') as pending_renewal_requests,
        (SELECT COUNT(*) FROM Borrow_Requests WHERE request_status = 'pending') as pending_borrow_requests,
        (SELECT COUNT(*) FROM Borrow_Requests WHERE request_status = 'approved' AND actual_pickup_date IS NULL) as books_ready_for_pickup;
END//

-- Procedure 11: Create Borrow Request (Reader) (NEW)
CREATE PROCEDURE sp_create_borrow_request(
    IN p_user_id INT,
    IN p_book_id INT,
    OUT p_result VARCHAR(255),
    OUT p_request_id INT
)
BEGIN
    DECLARE v_has_available_copy INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Request failed';
        SET p_request_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Check membership
    IF NOT fn_check_membership_valid(p_user_id) THEN
        SET p_result = 'Error: Membership expired or inactive';
        SET p_request_id = NULL;
        ROLLBACK;
    
    -- Check if already has pending request for this book
    ELSEIF fn_has_pending_borrow_request(p_user_id, p_book_id) THEN
        SET p_result = 'Error: You already have a pending request for this book';
        SET p_request_id = NULL;
        ROLLBACK;
    
    -- Check request limit
    ELSEIF NOT fn_check_borrow_request_limit(p_user_id) THEN
        SET p_result = 'Error: Maximum pending requests reached';
        SET p_request_id = NULL;
        ROLLBACK;
    
    -- Check borrow limit
    ELSEIF NOT fn_check_borrow_limit(p_user_id) THEN
        SET p_result = 'Error: Borrow limit reached';
        SET p_request_id = NULL;
        ROLLBACK;
    
    ELSE
        -- Check available copies
        SELECT COUNT(*) INTO v_has_available_copy
        FROM Book_Copies
        WHERE book_id = p_book_id
        AND availability_status = 'available';
        
        IF v_has_available_copy = 0 THEN
            SET p_result = 'Error: No available copies. Please reserve this book instead.';
            SET p_request_id = NULL;
            ROLLBACK;
        ELSE
            -- Create request
            INSERT INTO Borrow_Requests (user_id, book_id, request_status)
            VALUES (p_user_id, p_book_id, 'pending');
            
            SET p_request_id = LAST_INSERT_ID();
            
            -- Notify librarians
            INSERT INTO Notifications (
                user_id, 
                notification_type, 
                title, 
                message, 
                reference_id
            )
            SELECT 
                u.user_id,
                'general',
                'New Borrow Request',
                CONCAT('New borrow request #', p_request_id, ' from ', 
                       (SELECT full_name FROM Users WHERE user_id = p_user_id)),
                p_request_id
            FROM Users u
            WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Librarian');
            
            SET p_result = 'Success: Borrow request created. Wait for librarian approval.';
            COMMIT;
        END IF;
    END IF;
END//

-- Procedure 12: Approve Borrow Request (Librarian) (NEW)
CREATE PROCEDURE sp_approve_borrow_request(
    IN p_request_id INT,
    IN p_librarian_id INT,
    OUT p_result VARCHAR(255)
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_book_id INT;
    DECLARE v_copy_id INT;
    DECLARE v_pickup_days INT DEFAULT 3;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Approval failed';
    END;
    
    START TRANSACTION;
    
    -- Get request details
    SELECT user_id, book_id INTO v_user_id, v_book_id
    FROM Borrow_Requests
    WHERE request_id = p_request_id
    AND request_status = 'pending';
    
    IF v_user_id IS NULL THEN
        SET p_result = 'Error: Request not found or already processed';
        ROLLBACK;
    ELSE
        -- Get available copy
        SET v_copy_id = fn_get_available_copy(v_book_id);
        
        IF v_copy_id IS NULL THEN
            -- Reject if no copy available
            UPDATE Borrow_Requests
            SET request_status = 'rejected',
                rejection_reason = 'No available copies at this time',
                processed_by = p_librarian_id,
                processed_date = NOW()
            WHERE request_id = p_request_id;
            
            SET p_result = 'Error: No available copies';
            COMMIT;
        ELSE
            -- Reserve the copy
            UPDATE Book_Copies
            SET availability_status = 'reserved'
            WHERE copy_id = v_copy_id;
            
            -- Update request
            UPDATE Borrow_Requests
            SET request_status = 'approved',
                copy_id = v_copy_id,
                pickup_ready_date = NOW(),
                pickup_expiry_date = DATE_ADD(NOW(), INTERVAL v_pickup_days DAY),
                processed_by = p_librarian_id,
                processed_date = NOW()
            WHERE request_id = p_request_id;
            
            -- Notify reader
            INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
            VALUES (
                v_user_id,
                'general',
                'Borrow Request Approved',
                CONCAT('Your borrow request #', p_request_id, ' for "',
                       (SELECT title FROM Books WHERE book_id = v_book_id),
                       '" has been approved. Please pickup within ', v_pickup_days, ' days.'),
                p_request_id
            );
            
            SET p_result = 'Success: Request approved. Book reserved for pickup.';
            COMMIT;
        END IF;
    END IF;
END//

-- Procedure 13: Confirm Book Pickup (Librarian) (NEW)
CREATE PROCEDURE sp_confirm_book_pickup(
    IN p_request_id INT,
    IN p_librarian_id INT,
    OUT p_result VARCHAR(255),
    OUT p_transaction_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_copy_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_borrow_days INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Pickup confirmation failed';
        SET p_transaction_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Get request details
    SELECT user_id, copy_id INTO v_user_id, v_copy_id
    FROM Borrow_Requests
    WHERE request_id = p_request_id
    AND request_status = 'approved'
    AND actual_pickup_date IS NULL;
    
    IF v_user_id IS NULL THEN
        SET p_result = 'Error: Request not found or already picked up';
        SET p_transaction_id = NULL;
        ROLLBACK;
    ELSE
        -- Get borrow days from settings
        SELECT CAST(setting_value AS DECIMAL) INTO v_borrow_days
        FROM System_Settings
        WHERE setting_key = 'max_borrow_days';
        
        SET v_due_date = DATE_ADD(CURDATE(), INTERVAL v_borrow_days DAY);
        
        -- Create borrowing transaction
        INSERT INTO Borrowing_Transactions (
            copy_id, user_id, librarian_id, borrow_date, due_date, 
            borrow_method, pickup_date, borrow_request_id
        )
        VALUES (
            v_copy_id, v_user_id, p_librarian_id, CURDATE(), v_due_date,
            'online_request', NOW(), p_request_id
        );
        
        SET p_transaction_id = LAST_INSERT_ID();
        
        -- Update request status
        UPDATE Borrow_Requests
        SET request_status = 'picked_up',
            actual_pickup_date = NOW()
        WHERE request_id = p_request_id;
        
        -- Notify reader
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (
            v_user_id,
            'general',
            'Book Pickup Confirmed',
            CONCAT('Your book "',
                   (SELECT b.title FROM Books b JOIN Book_Copies bc ON b.book_id = bc.book_id WHERE bc.copy_id = v_copy_id),
                   '" has been checked out. Due date: ', v_due_date),
            p_transaction_id
        );
        
        SET p_result = 'Success: Book pickup confirmed';
        COMMIT;
    END IF;
END//

-- Procedure 14: Schedule Return (Reader) (NEW)
CREATE PROCEDURE sp_schedule_return(
    IN p_transaction_id INT,
    IN p_user_id INT,
    IN p_scheduled_date DATETIME,
    OUT p_result VARCHAR(255),
    OUT p_schedule_id INT
)
BEGIN
    DECLARE v_transaction_exists INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Schedule failed';
        SET p_schedule_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Verify transaction belongs to user
    SELECT COUNT(*) INTO v_transaction_exists
    FROM Borrowing_Transactions
    WHERE transaction_id = p_transaction_id
    AND user_id = p_user_id
    AND return_date IS NULL;
    
    IF v_transaction_exists = 0 THEN
        SET p_result = 'Error: Transaction not found or already returned';
        SET p_schedule_id = NULL;
        ROLLBACK;
    ELSEIF p_scheduled_date < NOW() THEN
        SET p_result = 'Error: Scheduled date must be in the future';
        SET p_schedule_id = NULL;
        ROLLBACK;
    ELSE
        -- Check if schedule already exists
        IF EXISTS (SELECT 1 FROM Return_Schedules WHERE transaction_id = p_transaction_id) THEN
            -- Update existing schedule
            UPDATE Return_Schedules
            SET scheduled_return_date = p_scheduled_date,
                notification_sent = FALSE,
                notes = 'Rescheduled by reader'
            WHERE transaction_id = p_transaction_id;
            
            SELECT schedule_id INTO p_schedule_id
            FROM Return_Schedules
            WHERE transaction_id = p_transaction_id;
        ELSE
            -- Create new schedule
            INSERT INTO Return_Schedules (transaction_id, user_id, scheduled_return_date)
            VALUES (p_transaction_id, p_user_id, p_scheduled_date);
            
            SET p_schedule_id = LAST_INSERT_ID();
        END IF;
        
        -- Notify librarians
        INSERT INTO Notifications (
            user_id,
            notification_type,
            title,
            message,
            reference_id
        )
        SELECT 
            u.user_id,
            'general',
            'Return Scheduled',
            CONCAT('Member ', (SELECT full_name FROM Users WHERE user_id = p_user_id),
                   ' scheduled return for ', DATE_FORMAT(p_scheduled_date, '%Y-%m-%d %H:%i')),
            p_schedule_id
        FROM Users u
        WHERE u.role_id = (SELECT role_id FROM Roles WHERE role_name = 'Librarian');
        
        SET p_result = 'Success: Return scheduled';
        COMMIT;
    END IF;
END//

-- Procedure 15: Self-Return Book (Automated) (NEW)
CREATE PROCEDURE sp_self_return_book(
    IN p_copy_id INT,
    IN p_return_method ENUM('drop_box', 'kiosk'),
    OUT p_result VARCHAR(255),
    OUT p_transaction_id INT
)
BEGIN
    DECLARE v_user_id INT;
    DECLARE v_due_date DATE;
    DECLARE v_fine_amount DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'Error: Self-return failed';
        SET p_transaction_id = NULL;
    END;
    
    START TRANSACTION;
    
    -- Find active transaction for this copy
    SELECT transaction_id, user_id, due_date 
    INTO p_transaction_id, v_user_id, v_due_date
    FROM Borrowing_Transactions
    WHERE copy_id = p_copy_id
    AND return_date IS NULL
    AND transaction_status IN ('borrowed', 'overdue')
    ORDER BY borrow_date DESC
    LIMIT 1;
    
    IF p_transaction_id IS NULL THEN
        SET p_result = 'Error: No active borrowing found for this copy';
        ROLLBACK;
    ELSE
        -- Update transaction
        UPDATE Borrowing_Transactions
        SET return_date = CURDATE(),
            transaction_status = 'returned',
            return_method = p_return_method
        WHERE transaction_id = p_transaction_id;
        
        -- Mark copy for inspection
        UPDATE Book_Copies
        SET requires_inspection = TRUE,
            last_scanned_at = NOW(),
            availability_status = 'maintenance'
        WHERE copy_id = p_copy_id;
        
        -- Calculate fine if overdue
        SET v_fine_amount = fn_calculate_fine(p_transaction_id);
        
        IF v_fine_amount > 0 THEN
            INSERT INTO Fines (transaction_id, user_id, fine_amount, fine_reason, days_overdue, fine_date)
            VALUES (
                p_transaction_id,
                v_user_id,
                v_fine_amount,
                'Late return penalty',
                DATEDIFF(CURDATE(), v_due_date),
                CURDATE()
            );
        END IF;
        
        -- Notify reader
        INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
        VALUES (
            v_user_id,
            'general',
            'Book Return Processed',
            CONCAT('Your book return has been processed via ', p_return_method, '. ',
                   IF(v_fine_amount > 0, CONCAT('Fine: $', v_fine_amount), 'No fine.')),
            p_transaction_id
        );
        
        SET p_result = CONCAT('Success: Book returned via ', p_return_method,
                             IF(v_fine_amount > 0, CONCAT('. Fine: $', v_fine_amount), ''));
        COMMIT;
    END IF;
END//

-- Procedure 16: Auto-expire Pickup Requests (NEW)
CREATE PROCEDURE sp_expire_pickup_requests()
BEGIN
    DECLARE v_expired_count INT;
    
    -- Expire requests not picked up in time
    UPDATE Borrow_Requests br
    SET request_status = 'expired'
    WHERE request_status = 'approved'
    AND pickup_expiry_date < NOW()
    AND actual_pickup_date IS NULL;
    
    SET v_expired_count = ROW_COUNT();
    
    -- Free up reserved copies
    UPDATE Book_Copies bc
    JOIN Borrow_Requests br ON bc.copy_id = br.copy_id
    SET bc.availability_status = 'available'
    WHERE br.request_status = 'expired'
    AND bc.availability_status = 'reserved';
    
    -- Notify users
    INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
    SELECT 
        br.user_id,
        'general',
        'Pickup Request Expired',
        'Your approved borrow request has expired. Please submit a new request if still interested.',
        br.request_id
    FROM Borrow_Requests br
    WHERE br.request_status = 'expired'
    AND br.pickup_expiry_date >= DATE_SUB(NOW(), INTERVAL 1 HOUR);
    
    SELECT v_expired_count as expired_requests;
END//

DELIMITER ;

-- ============================================
-- PART 8: CREATE ALL EVENTS (Automated Tasks)
-- ============================================

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

DELIMITER //

-- Event 1: Daily task to mark overdue books
CREATE EVENT evt_daily_mark_overdue
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL sp_mark_overdue_books();
END//

-- Event 2: Daily task to send due date reminders
CREATE EVENT evt_daily_due_reminders
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL sp_send_due_date_reminders();
END//

-- Reservations event removed

-- Event 4: Check and notify expiring memberships (weekly)
CREATE EVENT evt_weekly_membership_check
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO Notifications (user_id, notification_type, title, message, reference_id)
    SELECT 
        m.user_id,
        'membership_expiry',
        'Membership Expiring Soon',
        CONCAT('Your membership will expire on ', m.expiry_date, '. Please renew to continue borrowing.'),
        m.membership_id
    FROM Memberships m
    WHERE m.expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
    AND m.is_active = TRUE;
END//

-- Event 5: Hourly task to expire pickup requests (NEW)
CREATE EVENT evt_hourly_expire_pickup_requests
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL sp_expire_pickup_requests();
END//

DELIMITER ;

-- ============================================
-- PART 9: SAMPLE DATA (For Testing)
-- ============================================

-- Sample Librarian
INSERT INTO Users (role_id, username, password_hash, email, full_name, phone, account_status)
VALUES 
(1, 'librarian', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
 'librarian@library.com', 'John Librarian', '+1234567890', 'active');

-- Sample Members
INSERT INTO Users (role_id, username, password_hash, email, full_name, phone, date_of_birth, address, account_status)
VALUES 
(2, 'alice_smith', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
 'alice@email.com', 'Alice Smith', '+1234567891', '1995-05-15', '123 Main St, City', 'active'),
(2, 'bob_jones', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
 'bob@email.com', 'Bob Jones', '+1234567892', '1988-08-20', '456 Oak Ave, City', 'active'),
(2, 'carol_white', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
 'carol@email.com', 'Carol White', '+1234567893', '1992-03-10', '789 Pine Rd, City', 'active');

-- Sample Memberships
INSERT INTO Memberships (user_id, membership_number, membership_type, issue_date, expiry_date, max_books_allowed)
VALUES 
(2, 'MEM001', 'premium', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 12 MONTH), 10),
(3, 'MEM002', 'basic', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 12 MONTH), 5),
(4, 'MEM003', 'student', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 6 MONTH), 7);

-- Sample Categories
INSERT INTO Categories (category_name, description) VALUES
('Fiction', 'Fictional literature including novels and short stories'),
('Non-Fiction', 'Factual books including biographies and essays'),
('Science', 'Scientific literature and research'),
('Technology', 'Technology and computer science books'),
('History', 'Historical books and references'),
('Children', 'Books for children and young readers'),
('Reference', 'Reference materials and encyclopedias');

-- Sample Authors
INSERT INTO Authors (author_name, biography, country) VALUES
('George Orwell', 'English novelist and essayist', 'United Kingdom'),
('J.K. Rowling', 'British author, best known for Harry Potter series', 'United Kingdom'),
('Stephen Hawking', 'Theoretical physicist and cosmologist', 'United Kingdom'),
('Isaac Asimov', 'Science fiction author and biochemistry professor', 'United States'),
('Yuval Noah Harari', 'Israeli historian and author', 'Israel');

-- Sample Publishers
INSERT INTO Publishers (publisher_name, address, phone, email) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '+1-212-782-9000', 'info@penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY', '+1-212-207-7000', 'info@harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, NY', '+1-212-698-7000', 'info@simonandschuster.com'),
('Oxford University Press', 'Great Clarendon Street, Oxford', '+44-1865-556767', 'info@oup.com');

-- Sample Books
INSERT INTO Books (isbn, title, category_id, publisher_id, publication_year, language, pages, description, shelf_location)
VALUES
('978-0-452-28423-4', '1984', 1, 1, 1949, 'English', 328, 'Dystopian social science fiction novel', 'A-101'),
('978-0-7475-3269-9', 'Harry Potter and the Philosopher\'s Stone', 1, 2, 1997, 'English', 223, 'Fantasy novel', 'B-205'),
('978-0-553-10953-5', 'A Brief History of Time', 3, 3, 1988, 'English', 256, 'Popular science book', 'C-312'),
('978-0-553-29337-0', 'Foundation', 1, 3, 1951, 'English', 255, 'Science fiction novel', 'A-115'),
('978-0-062-31609-1', 'Sapiens', 5, 2, 2011, 'English', 443, 'History of humankind', 'D-420');

-- Link Books to Authors
INSERT INTO Book_Authors (book_id, author_id, author_order) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1);

-- Sample Book Copies
INSERT INTO Book_Copies (book_id, copy_number, acquisition_date, condition_status, availability_status, price)
VALUES
(1, 'C001', '2023-01-15', 'excellent', 'available', 15.99),
(1, 'C002', '2023-01-15', 'good', 'available', 15.99),
(2, 'C003', '2023-02-20', 'excellent', 'available', 19.99),
(2, 'C004', '2023-02-20', 'excellent', 'available', 19.99),
(3, 'C005', '2023-03-10', 'good', 'available', 18.50),
(4, 'C006', '2023-04-05', 'excellent', 'available', 16.75),
(5, 'C007', '2023-05-12', 'excellent', 'available', 22.00);

-- ============================================
-- DATABASE SETUP COMPLETE!
-- ============================================

SELECT '✅ Library Management Database v2.0 Setup Complete!' as `Status`;
SELECT '' as `---`;
SELECT '📊 DATABASE SUMMARY:' as `Info`;
SELECT '  ✓ PART 1: Database created' as `Detail`;
SELECT '  ✓ PART 2: Tables: 19 (including Borrow_Requests for online borrowing)' as `Detail`;
SELECT '  ✓ PART 3: System Settings: 9 configured' as `Detail`;
SELECT '  ✓ PART 4: Functions: 8 created (MUST be before Views)' as `Detail`;
SELECT '  ✓ PART 5: Views: 12 created (uses Functions)' as `Detail`;
SELECT '  ✓ PART 6: Triggers: 12 created' as `Detail`;
SELECT '  ✓ PART 7: Stored Procedures: 16 created' as `Detail`;
SELECT '  ✓ PART 8: Events: 5 automated tasks scheduled' as `Detail`;
SELECT '  ✓ PART 9: Sample Data: Inserted for testing' as `Detail`;
SELECT '' as `---`;
SELECT '🎯 SUPPORTS ALL 26 USE CASES:' as `Info`;
SELECT '  • Traditional counter service (Librarian)' as `Feature`;
SELECT '  • Online borrow requests (Reader → Librarian)' as `Feature`;
SELECT '  • Self-checkout capability (Reader - optional)' as `Feature`;
SELECT '  • Self-return via drop box/kiosk (Reader - optional)' as `Feature`;
SELECT '  • Scheduled returns (Reader)' as `Feature`;
SELECT '  • Complete renewal workflow' as `Feature`;
SELECT '  • Advanced reporting and analytics' as `Feature`;
SELECT '' as `---`;
SELECT '🧪 Testing dashboard...' as `Info`;

-- Test dashboard with new features
CALL sp_dashboard_statistics();

SELECT '' as `---`;
SELECT '🎉 Database is ready for production use!' as `Status`;
SELECT '💡 Next steps: Configure your application to connect to this database' as `Tip`;