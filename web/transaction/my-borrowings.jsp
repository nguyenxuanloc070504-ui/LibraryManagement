<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String userRole = (String) session.getAttribute("authRole");
    boolean isMember = "Member".equalsIgnoreCase(userRole);
    boolean isLibrarian = "Librarian".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
    DecimalFormat df = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Borrowings</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/button.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/modal.css">
    <% if (isMember) { %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pages/home.css">
    <% } %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .btn-icon-text.payment {
            background: #ff8c42;
        }
        .btn-icon-text.payment:hover {
            background: #e67a2e;
        }
        .processing-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
            animation: pulse 2s ease-in-out infinite;
        }
        .processing-badge i {
            animation: spin 2s linear infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.9; transform: scale(1.02); }
        }
        @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body class="<%= isMember ? "home-page" : "" %>">
<div class="<%= isMember ? "" : "layout" %>">
    <% if (isLibrarian) { %>
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="my-borrowings"/>
    </jsp:include>
    <% } %>

    <main class="<%= isMember ? "" : "content" %>">
        <% if (isMember) { %>
        <jsp:include page="/components/header-member.jsp">
            <jsp:param name="activeTab" value="borrowings"/>
        </jsp:include>
        <% } else { %>
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="My Borrowings"/>
            <jsp:param name="pageSubtitle" value="View current borrowings and history"/>
        </jsp:include>
        <% } %>

        <div class="<%= isMember ? "container" : "main-content" %>" style="<%= isMember ? "padding-top: 2rem; padding-bottom: 2rem;" : "" %>">
            <%
                String successMsg = (String) session.getAttribute("success");
                String errorMsg = (String) session.getAttribute("error");
                if (successMsg != null) {
                    session.removeAttribute("success");
            %>
                <div class="alert-success"><%= successMsg %></div>
            <% } %>
            <% if (errorMsg != null) {
                    session.removeAttribute("error");
            %>
                <div class="alert-error"><%= errorMsg %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <section class="card" style="width: 100%; margin-bottom: var(--spacing-xl);">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-book-reader" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Current Borrowings</h2>
                </div>
                <div style="width:100%;">
                    <%
                        List<TransactionDAO.BorrowingDetail> current = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("currentBorrowings");
                        List<TransactionDAO.FineDetail> fines = (List<TransactionDAO.FineDetail>) request.getAttribute("fines");

                        // Create a map of transaction_id to fine for quick lookup
                        java.util.Map<Integer, TransactionDAO.FineDetail> fineMap = new java.util.HashMap<>();
                        if (fines != null) {
                            for (TransactionDAO.FineDetail fine : fines) {
                                fineMap.put(fine.transactionId, fine);
                            }
                        }

                        if (current == null || current.isEmpty()) {
                    %>
                        <p class="text-muted">You have no current borrowings.</p>
                    <%
                        } else {
                    %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>ISBN</th>
                                    <th>Copy</th>
                                    <th>Borrowed</th>
                                    <th>Due</th>
                                    <th>Status</th>
                                    <% if (isMember) { %>
                                    <th>Fine Status</th>
                                    <% } else { %>
                                    <th>Potential Fine</th>
                                    <% } %>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for (TransactionDAO.BorrowingDetail b : current) {
                                TransactionDAO.FineDetail associatedFine = fineMap.get(b.transactionId);
                            %>
                                <tr>
                                    <td><a href="<%= request.getContextPath() %>/books/detail?id=<%= b.bookId %>"><%= b.bookTitle %></a></td>
                                    <td><%= b.isbn %></td>
                                    <td>#<%= b.copyNumber %></td>
                                    <td><%= b.borrowDate %></td>
                                    <td>
                                        <div><%= b.dueDate %></div>
                                        <% if (b.scheduledReturnDate != null) { %>
                                            <small class="muted">Scheduled: <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(b.scheduledReturnDate) %></small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("overdue".equalsIgnoreCase(b.transactionStatus)) { %>
                                            <span class="status-badge status-locked">Overdue (<%= b.daysOverdue %>d)</span>
                                        <% } else { %>
                                            <span class="status-badge status-active">Borrowed</span>
                                        <% } %>
                                    </td>
                                    <% if (isMember) { %>
                                    <td>
                                        <% if (associatedFine != null) { %>
                                            <div style="display: flex; flex-direction: column; gap: 0.25rem;">
                                                <div>
                                                    <strong style="color: var(--color-error); font-size: 1.1rem;">$<%= df.format(associatedFine.fineAmount) %></strong>
                                                </div>
                                                <div>
                                                    <% if ("paid".equals(associatedFine.paymentStatus)) { %>
                                                        <span class="status-badge status-success" style="font-weight: 700; text-transform: uppercase; color: white; background: linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);">
                                                            ✓ <%= associatedFine.paymentStatus %>
                                                        </span>
                                                    <% } else { %>
                                                        <span class="status-badge <%=
                                                            "pending".equals(associatedFine.paymentStatus) ? "status-active" :
                                                            "waived".equals(associatedFine.paymentStatus) ? "status-inactive" :
                                                            "status-locked"
                                                        %>">
                                                            <%= associatedFine.paymentStatus %>
                                                        </span>
                                                    <% } %>
                                                </div>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted">No fine</span>
                                        <% } %>
                                    </td>
                                    <% } else { %>
                                    <td class="text-right">
                                        <%= b.potentialFine != null ? ("$" + b.potentialFine) : "$0.00" %>
                                    </td>
                                    <% } %>
                                    <td style="text-align:right; white-space:nowrap;">
                                        <% if (isMember) { %>
                                            <div style="display: flex; gap: 0.5rem; align-items: center; justify-content: flex-end;">
                                                <button class="btn-icon-text" data-modal-open="modal-schedule-<%= b.transactionId %>">
                                                    <i class="fa-regular fa-calendar-check"></i>
                                                    Schedule
                                                </button>
                                                <button class="btn-icon-text" data-modal-open="modal-renewal-<%= b.transactionId %>">
                                                    <i class="fa-solid fa-rotate-right"></i>
                                                    Renew
                                                </button>
                                                <% if (associatedFine != null && "unpaid".equals(associatedFine.paymentStatus)) { %>
                                                <button onclick="openVNPayModal(<%= associatedFine.fineId %>, <%= associatedFine.fineAmount %>)" class="btn-icon-text payment">
                                                    <i class="fa-solid fa-credit-card"></i>
                                                    Pay Fine
                                                </button>
                                                <% } else if (associatedFine != null && "pending".equals(associatedFine.paymentStatus)) { %>
                                                <span class="processing-badge">
                                                    <i class="fa-solid fa-circle-notch"></i>
                                                    Processing...
                                                </span>
                                                <% } %>
                                            </div>
                                        <% } else { %>
                                            <!-- Librarian view - no member actions -->
                                        <% } %>
                                    </td>
                                </tr>

                                <% if (isMember) { %>
                                <!-- Renewal Confirmation Modal -->
                                <div class="modal" id="modal-renewal-<%= b.transactionId %>">
                                    <div class="modal-overlay">
                                        <div class="modal-dialog">
                                            <div class="modal-header" style="text-align:center;">Request Renewal Confirmation</div>
                                            <div class="modal-body" style="text-align:center;">
                                                <p style="margin-bottom:0.5rem;">Are you sure you want to request renewal for:</p>
                                                <p style="margin-bottom:1.5rem;"><strong style="font-size:1.1rem;"><%= b.bookTitle %></strong></p>
                                                <div style="margin:1rem auto; padding:1rem; background:var(--color-background-secondary); border-radius:var(--border-radius); max-width:400px;">
                                                    <div style="display:flex; justify-content:space-between; margin-bottom:0.5rem;">
                                                        <span class="text-muted">Current Due Date:</span>
                                                        <strong><%= b.dueDate %></strong>
                                                    </div>
                                                    <div style="display:flex; justify-content:space-between;">
                                                        <span class="text-muted">Current Renewals:</span>
                                                        <strong><%= b.renewalCount %></strong>
                                                    </div>
                                                </div>
                                                <p style="margin-top:1rem; font-size:0.9rem; color:var(--color-text-muted);">
                                                    <i class="fa-solid fa-info-circle"></i> Your renewal request will be sent to the librarian for approval.
                                                </p>
                                            </div>
                                            <div class="modal-actions" style="justify-content:center;">
                                                <button class="btn-secondary inline-btn" data-modal-close>Cancel</button>
                                                <form method="post" action="<%= request.getContextPath() %>/transaction/create-renewal-request" style="display:inline;">
                                                    <input type="hidden" name="transaction_id" value="<%= b.transactionId %>" />
                                                    <button type="submit" class="btn-primary inline-btn">
                                                        <i class="fa-solid fa-check"></i> Confirm Request
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Schedule Return Modal -->
                                <div class="modal" id="modal-schedule-<%= b.transactionId %>">
                                    <div class="modal-overlay">
                                        <div class="modal-dialog">
                                            <div class="modal-header" style="text-align:center;">Schedule Return</div>
                                            <div class="modal-body">
                                                <form id="form-schedule-<%= b.transactionId %>" method="post" action="<%= request.getContextPath() %>/transaction/schedule-return" style="margin:0; display:flex; flex-direction:column; gap:.5rem; align-items:center; text-align:center;">
                                                    <input type="hidden" name="transaction_id" value="<%= b.transactionId %>" />
                                                    <label for="scheduled-<%= b.transactionId %>">Select date & time</label>
                                                    <input type="datetime-local" id="scheduled-<%= b.transactionId %>" name="scheduled_datetime" required />
                                                </form>
                                            </div>
                                            <div class="modal-actions" style="justify-content:center;">
                                                <button class="btn-secondary" data-modal-close>Cancel</button>
                                                <button class="btn-icon-text" onclick="document.getElementById('form-schedule-<%= b.transactionId %>').submit();">
                                                    <i class="fa-regular fa-calendar-check"></i> Confirm
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <% } %>

                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </section>

            <section class="card" style="width: 100%;">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-clock-rotate-left" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Borrowing History</h2>
                </div>
                <div style="width:100%;">
                    <%
                        List<TransactionDAO.BorrowingDetail> history = (List<TransactionDAO.BorrowingDetail>) request.getAttribute("borrowingHistory");
                        if (history == null || history.isEmpty()) {
                    %>
                        <p class="text-muted">No history yet.</p>
                    <%
                        } else {
                    %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                            <tr>
                                <th>Title</th>
                                <th>ISBN</th>
                                <th>Copy</th>
                                <th>Borrowed</th>
                                <th>Due</th>
                                <th>Returned</th>
                                <th>Status</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% for (TransactionDAO.BorrowingDetail b : history) { %>
                                <tr>
                                    <td><a href="<%= request.getContextPath() %>/books/detail?id=<%= b.bookId %>"><%= b.bookTitle %></a></td>
                                    <td><%= b.isbn %></td>
                                    <td>#<%= b.copyNumber %></td>
                                    <td><%= b.borrowDate %></td>
                                    <td><%= b.dueDate %></td>
                                    <td><%= b.returnDate %></td>
                                    <td>
                                        <span class="status-badge status-inactive">Returned</span>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
                </div>
            </section>

            <%
                java.util.List<dal.TransactionDAO.RenewalRequestDetail> renewalRequests =
                    (java.util.List<dal.TransactionDAO.RenewalRequestDetail>) request.getAttribute("renewalRequests");
                if (renewalRequests != null && !renewalRequests.isEmpty()) {
            %>
            <section class="card" style="width: 100%; margin-top: var(--spacing-xl);">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-rotate-right" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Renewal Requests</h2>
                </div>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Book</th>
                                <th>ISBN</th>
                                <th>Current Due Date</th>
                                <th>Renewals</th>
                                <th>Request Date</th>
                                <th>Status</th>
                                <th>Processed Date</th>
                                <th>Notes</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (dal.TransactionDAO.RenewalRequestDetail rr : renewalRequests) { %>
                            <tr>
                                <td><%= rr.bookTitle %></td>
                                <td><%= rr.isbn != null ? rr.isbn : "" %></td>
                                <td><%= rr.dueDate %></td>
                                <td><%= rr.renewalCount %> / <%= rr.maxRenewals %></td>
                                <td><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(rr.requestDate) %></td>
                                <td>
                                    <% if ("approved".equalsIgnoreCase(rr.requestStatus)) { %>
                                        <span class="status-badge status-success">Approved</span>
                                    <% } else if ("pending".equalsIgnoreCase(rr.requestStatus)) { %>
                                        <span class="status-badge status-active">Pending</span>
                                    <% } else if ("rejected".equalsIgnoreCase(rr.requestStatus)) { %>
                                        <span class="status-badge status-locked">Rejected</span>
                                    <% } else { %>
                                        <span class="status-badge"><%= rr.requestStatus %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (rr.processedDate != null) { %>
                                        <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(rr.processedDate) %>
                                    <% } else { %>
                                        <span class="text-muted">Not processed</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (rr.rejectionReason != null && !rr.rejectionReason.isEmpty()) { %>
                                        <%= rr.rejectionReason %>
                                    <% } else { %>
                                        <span class="text-muted">—</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
            <% } %>

            <%
                java.util.List<dal.BorrowRequestDAO.UserBorrowRequest> borrowRequests =
                    (java.util.List<dal.BorrowRequestDAO.UserBorrowRequest>) request.getAttribute("borrowRequests");
                if (borrowRequests != null && !borrowRequests.isEmpty()) {
            %>
            <section class="card" style="width: 100%; margin-top: var(--spacing-xl);">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-envelope-open-text" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Borrow Requests</h2>
                </div>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Book</th>
                                <th>ISBN</th>
                                <th>Requested</th>
                                <th>Status</th>
                                <th>Pickup Window</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (dal.BorrowRequestDAO.UserBorrowRequest r : borrowRequests) { %>
                            <tr>
                                <td><a href="<%= request.getContextPath() %>/books/detail?id=<%= r.bookId %>"><%= r.bookTitle %></a></td>
                                <td><%= r.isbn != null ? r.isbn : "" %></td>
                                <td><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(r.requestDate) %></td>
                                <td>
                                    <% if ("approved".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-success">Approved</span>
                                    <% } else if ("pending".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-active">Pending</span>
                                    <% } else if ("rejected".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-locked">Rejected</span>
                                    <% } else if ("cancelled".equalsIgnoreCase(r.requestStatus)) { %>
                                        <span class="status-badge status-inactive">Cancelled</span>
                                    <% } else { %>
                                        <span class="status-badge"><%= r.requestStatus %></span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (r.pickupReadyDate != null) { %>
                                        Ready: <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(r.pickupReadyDate) %><br/>
                                        Expires: <%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(r.pickupExpiryDate) %>
                                    <% } else { %>
                                        <span class="text-muted">Not ready</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if ("pending".equalsIgnoreCase(r.requestStatus)) { %>
                                        <button class="btn-icon-text danger" data-modal-open="modal-cancel-<%= r.requestId %>">
                                            <i class="fa-solid fa-xmark"></i>
                                            Cancel
                                        </button>

                                        <!-- Confirm Cancel Modal for this request -->
                                        <div class="modal" id="modal-cancel-<%= r.requestId %>">
                                            <div class="modal-overlay">
                                                <div class="modal-dialog">
                                                    <div class="modal-header">Cancel Request</div>
                                                    <div class="modal-body">
                                                        Are you sure you want to cancel this borrow request for <strong><%= r.bookTitle %></strong>?
                                                    </div>
                                                    <div class="modal-actions">
                                                        <button class="btn-secondary inline-btn" data-modal-close>Close</button>
                                                        <form method="post" action="<%= request.getContextPath() %>/transaction/cancel-request" style="display:inline;">
                                                            <input type="hidden" name="request_id" value="<%= r.requestId %>" />
                                                            <input type="hidden" name="book_id" value="<%= r.bookId %>" />
                                                            <button type="submit" class="btn-danger inline-btn">
                                                                Confirm Cancel
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    <% } else { %>
                                        <span class="text-muted">—</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
            <% } %>
        </div>
    </main>
</div>

<!-- VNPay Payment Modal -->
<div id="vnpayModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; justify-content: center; align-items: center;">
    <div style="background: white; padding: 2rem; border-radius: 12px; max-width: 500px; width: 90%; max-height: 90vh; overflow-y: auto;">
        <h2 style="margin-top: 0; color: #667eea;">
            <i class="fa-solid fa-credit-card"></i> VNPay Payment Gateway
        </h2>
        <p style="color: var(--color-text-muted); margin-bottom: 1.5rem;">
            Pay your fine securely via VNPay. Select your preferred payment method.
        </p>

        <form id="vnpayForm" action="<%= request.getContextPath() %>/vnpay-payment" method="post">
            <input type="hidden" name="fine_id" id="vnpay_fine_id" />

            <div class="form-field">
                <label class="label-muted">Amount to Pay</label>
                <div style="font-size: 2rem; font-weight: bold; color: #667eea; margin-bottom: 1rem; padding: 1rem; background: #f8f9ff; border-radius: 8px; text-align: center;">
                    $<span id="vnpay_amount">0.00</span>
                </div>
            </div>

            <div class="form-field">
                <label class="label-muted">Payment Method</label>
                <div style="margin-bottom: 1rem;">
                    <label style="display: block; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; cursor: pointer; margin-bottom: 0.5rem; transition: all 0.2s;">
                        <input type="radio" name="bankCode" value="" checked style="margin-right: 0.5rem;" />
                        <i class="fa-solid fa-qrcode"></i> VNPay QR (All methods)
                    </label>
                    <label style="display: block; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; cursor: pointer; margin-bottom: 0.5rem; transition: all 0.2s;">
                        <input type="radio" name="bankCode" value="VNPAYQR" style="margin-right: 0.5rem;" />
                        <i class="fa-solid fa-mobile-alt"></i> VNPay QR Code
                    </label>
                    <label style="display: block; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; cursor: pointer; margin-bottom: 0.5rem; transition: all 0.2s;">
                        <input type="radio" name="bankCode" value="VNBANK" style="margin-right: 0.5rem;" />
                        <i class="fa-solid fa-university"></i> ATM Card / Bank Account
                    </label>
                    <label style="display: block; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; cursor: pointer; transition: all 0.2s;">
                        <input type="radio" name="bankCode" value="INTCARD" style="margin-right: 0.5rem;" />
                        <i class="fa-brands fa-cc-visa"></i> International Card
                    </label>
                </div>
            </div>

            <div style="background: #e8f4fd; padding: 1rem; border-radius: 8px; margin: 1rem 0; font-size: 0.9rem;">
                <i class="fa-solid fa-shield-alt" style="color: #0288d1;"></i>
                <strong>Secure Payment:</strong> Your payment is processed securely through VNPay gateway.
            </div>

            <div style="display: flex; gap: 0.5rem; margin-top: 1.5rem;">
                <button type="submit" class="btn-primary" style="flex: 1;">
                    <i class="fa-solid fa-lock"></i> Proceed to Payment
                </button>
                <button type="button" onclick="closeVNPayModal()" class="btn-secondary" style="flex: 1;">
                    <i class="fa-solid fa-times"></i> Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openVNPayModal(fineId, amount) {
    document.getElementById('vnpay_fine_id').value = fineId;
    document.getElementById('vnpay_amount').textContent = parseFloat(amount).toFixed(2);
    document.getElementById('vnpayModal').style.display = 'flex';
}

function closeVNPayModal() {
    document.getElementById('vnpayModal').style.display = 'none';
}

// Close modal when clicking outside
document.getElementById('vnpayModal')?.addEventListener('click', function(e) {
    if (e.target === this) {
        closeVNPayModal();
    }
});

// Highlight selected payment method
document.querySelectorAll('input[name="bankCode"]').forEach(radio => {
    radio.addEventListener('change', function() {
        document.querySelectorAll('input[name="bankCode"]').forEach(r => {
            r.parentElement.style.borderColor = '#e0e0e0';
            r.parentElement.style.background = 'white';
        });
        this.parentElement.style.borderColor = '#667eea';
        this.parentElement.style.background = '#f8f9ff';
    });
});

</script>

<script src="<%= request.getContextPath() %>/js/components/modal.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>


