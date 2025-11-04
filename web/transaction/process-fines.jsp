<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Process Late Fees</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="transaction-fines"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Process Late Fees"/>
            <jsp:param name="pageSubtitle" value="Calculate and collect fines when members return books overdue"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% TransactionDAO.FineDetail fine = (TransactionDAO.FineDetail) request.getAttribute("fine"); %>
            <% String paymentStatus = request.getParameter("status"); %>
            <% List<TransactionDAO.FineDetail> fines = (List<TransactionDAO.FineDetail>) request.getAttribute("fines"); %>

            <% if (fine == null) { %>
                <!-- Filter Dropdown -->
                <section class="card" style="margin-bottom: 1.5rem;">
                    <form method="get" action="<%= request.getContextPath() %>/transaction/fines" style="margin: 0;">
                        <div class="form-field" style="margin: 0;">
                            <label class="label-muted">Filter by Status</label>
                            <div class="input box">
                                <select name="status" onchange="this.form.submit()">
                                    <option value="" <%= paymentStatus == null || paymentStatus.isEmpty() ? "selected" : "" %>>All Fines</option>
                                    <option value="unpaid" <%= "unpaid".equals(paymentStatus) ? "selected" : "" %>>Unpaid</option>
                                    <option value="paid" <%= "paid".equals(paymentStatus) ? "selected" : "" %>>Paid</option>
                                    <option value="waived" <%= "waived".equals(paymentStatus) ? "selected" : "" %>>Waived</option>
                                </select>
                            </div>
                        </div>
                    </form>
                </section>

                <!-- Fines List -->
                <section class="card">
                    <h2 class="form-section-title">Fines</h2>
                    <% if (fines == null || fines.isEmpty()) { %>
                        <p>No fines found.</p>
                    <% } else { %>
                        <div class="table-container">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Member</th>
                                        <th>Book</th>
                                        <th>Fine Amount</th>
                                        <th>Days Overdue</th>
                                        <th>Fine Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (TransactionDAO.FineDetail f : fines) { %>
                                        <tr>
                                            <td><%= f.memberName %></td>
                                            <td><%= f.bookTitle %></td>
                                            <td><strong>$<%= f.fineAmount %></strong></td>
                                            <td><%= f.daysOverdue %> days</td>
                                            <td><%= f.fineDate %></td>
                                            <td>
                                                <span class="status-badge <%= 
                                                    "paid".equals(f.paymentStatus) ? "status-active" : 
                                                    "waived".equals(f.paymentStatus) ? "status-success" : 
                                                    "status-locked" 
                                                %>">
                                                    <%= f.paymentStatus %>
                                                </span>
                                            </td>
                                            <td>
                                                <% if ("unpaid".equals(f.paymentStatus)) { %>
                                                    <a href="<%= request.getContextPath() %>/transaction/fines?id=<%= f.fineId %>" class="btn-icon-text">
                                                        <i class="fa-solid fa-dollar-sign"></i> Process
                                                    </a>
                                                <% } else { %>
                                                    <span class="text-muted">Processed</span>
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </section>
            <% } else { %>
                <!-- Process Fine Form -->
                <section class="card">
                    <h2 class="form-section-title">Process Fine</h2>
                    <div class="member-info-card" style="margin-bottom: 1.5rem;">
                        <div class="info-row">
                            <span class="info-label">Member:</span>
                            <span class="info-value"><%= fine.memberName %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Book:</span>
                            <span class="info-value"><%= fine.bookTitle %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Fine Amount:</span>
                            <span class="info-value" style="color: var(--color-error); font-weight: bold; font-size: 1.2em;">$<%= fine.fineAmount %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Days Overdue:</span>
                            <span class="info-value"><%= fine.daysOverdue %> days</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Fine Date:</span>
                            <span class="info-value"><%= fine.fineDate %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Current Status:</span>
                            <span class="info-value">
                                <span class="status-badge status-locked"><%= fine.paymentStatus %></span>
                            </span>
                        </div>
                    </div>
                    
                    <form method="post" action="<%= request.getContextPath() %>/transaction/fines" class="auth-form" novalidate>
                        <input type="hidden" name="fine_id" value="<%= fine.fineId %>" />
                        
                        <div class="form-field">
                            <label class="label-muted">Action<span class="req">*</span></label>
                            <div class="input box">
                                <select name="action" id="action-select" required>
                                    <option value="">Select action</option>
                                    <option value="pay">Mark as Paid</option>
                                    <option value="waive">Waive Fine</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-field" id="payment-method-field" style="display:none;">
                            <label class="label-muted">Payment Method</label>
                            <div class="input box">
                                <select name="payment_method">
                                    <option value="">Select method</option>
                                    <option value="cash">Cash</option>
                                    <option value="credit_card">Credit Card</option>
                                    <option value="debit_card">Debit Card</option>
                                    <option value="check">Check</option>
                                    <option value="online">Online Payment</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="form-field">
                            <label class="label-muted">Notes</label>
                            <div class="input box">
                                <textarea name="notes" rows="3" placeholder="Optional notes"><%= fine.notes != null ? fine.notes : "" %></textarea>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button class="btn-primary" type="submit" style="width:auto;">Process Fine</button>
                            <a href="<%= request.getContextPath() %>/transaction/fines" class="btn-secondary">Cancel</a>
                        </div>
                    </form>
                </section>
            <% } %>
        </div>
    </main>
</div>
<script>
document.getElementById('action-select')?.addEventListener('change', function() {
    const paymentMethodField = document.getElementById('payment-method-field');
    if (this.value === 'pay') {
        paymentMethodField.style.display = 'block';
    } else {
        paymentMethodField.style.display = 'none';
    }
});
</script>
<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>

