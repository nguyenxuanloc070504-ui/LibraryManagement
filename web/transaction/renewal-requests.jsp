<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.TransactionDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Renewal Requests</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/components/modal.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="renewal-requests"/>
    </jsp:include>

    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Renewal Requests"/>
            <jsp:param name="pageSubtitle" value="Review and process renewal requests from members"/>
        </jsp:include>

        <div class="main-content">
            <% if (request.getAttribute("success") != null) { %>
                <div class="alert-success"><%= request.getAttribute("success") %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <%
                List<TransactionDAO.PendingRenewalRequest> pendingRequests =
                    (List<TransactionDAO.PendingRenewalRequest>) request.getAttribute("pendingRequests");
            %>

            <section class="card">
                <div style="display:flex; align-items:center; gap:.5rem; margin-bottom:1rem;">
                    <i class="fa-solid fa-clock-rotate-left" style="color: var(--color-primary);"></i>
                    <h2 class="form-section-title" style="margin:0;">Pending Renewal Requests</h2>
                </div>

                <% if (pendingRequests == null || pendingRequests.isEmpty()) { %>
                    <p class="text-muted">No pending renewal requests at this time.</p>
                <% } else { %>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Request ID</th>
                                    <th>Member</th>
                                    <th>Book</th>
                                    <th>ISBN</th>
                                    <th>Borrowed</th>
                                    <th>Current Due Date</th>
                                    <th>Renewals</th>
                                    <th>Request Date</th>
                                    <th>Eligibility</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                                SimpleDateFormat sdfTime = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                                for (TransactionDAO.PendingRenewalRequest req : pendingRequests) {
                            %>
                                <tr>
                                    <td>#<%= req.requestId %></td>
                                    <td>
                                        <div><%= req.memberName %></div>
                                        <small class="text-muted"><%= req.memberEmail %></small>
                                    </td>
                                    <td><%= req.bookTitle %></td>
                                    <td><%= req.isbn != null ? req.isbn : "N/A" %></td>
                                    <td><%= sdf.format(req.borrowDate) %></td>
                                    <td><%= sdf.format(req.dueDate) %></td>
                                    <td><%= req.renewalCount %> / <%= req.maxRenewals %></td>
                                    <td><%= sdfTime.format(req.requestDate) %></td>
                                    <td>
                                        <% if ("Can be approved".equals(req.eligibilityStatus)) { %>
                                            <span class="status-badge status-success">
                                                <i class="fa-solid fa-check-circle"></i> Can approve
                                            </span>
                                        <% } else { %>
                                            <span class="status-badge status-locked">
                                                <i class="fa-solid fa-times-circle"></i> <%= req.eligibilityStatus %>
                                            </span>
                                        <% } %>
                                    </td>
                                    <td style="white-space: nowrap;">
                                        <% if ("Can be approved".equals(req.eligibilityStatus)) { %>
                                            <button class="btn-icon-text success" data-modal-open="modal-approve-<%= req.requestId %>">
                                                <i class="fa-solid fa-check"></i> Approve
                                            </button>

                                            <!-- Approve Confirmation Modal -->
                                            <div class="modal" id="modal-approve-<%= req.requestId %>">
                                                <div class="modal-overlay">
                                                    <div class="modal-dialog">
                                                        <div class="modal-header" style="text-align:center;">Approve Renewal Request</div>
                                                        <div class="modal-body" style="text-align:center;">
                                                            <p style="margin-bottom:0.5rem;">Are you sure you want to approve the renewal request for:</p>
                                                            <p style="margin-bottom:1rem;"><strong style="font-size:1.1rem;"><%= req.bookTitle %></strong></p>

                                                            <div style="margin:1rem auto; padding:1rem; background:var(--color-background-secondary); border-radius:var(--border-radius); max-width:450px;">
                                                                <div style="display:flex; justify-content:space-between; margin-bottom:0.5rem;">
                                                                    <span class="text-muted">Member:</span>
                                                                    <strong><%= req.memberName %></strong>
                                                                </div>
                                                                <div style="display:flex; justify-content:space-between; margin-bottom:0.5rem;">
                                                                    <span class="text-muted">Current Due Date:</span>
                                                                    <strong><%= sdf.format(req.dueDate) %></strong>
                                                                </div>
                                                                <div style="display:flex; justify-content:space-between; margin-bottom:0.5rem;">
                                                                    <span class="text-muted">Current Renewals:</span>
                                                                    <strong><%= req.renewalCount %> / <%= req.maxRenewals %></strong>
                                                                </div>
                                                                <div style="display:flex; justify-content:space-between;">
                                                                    <span class="text-muted">Request Date:</span>
                                                                    <strong><%= sdfTime.format(req.requestDate) %></strong>
                                                                </div>
                                                            </div>

                                                            <p style="margin-top:1rem; font-size:0.9rem; color:var(--color-success);">
                                                                <i class="fa-solid fa-check-circle"></i> Approval will automatically extend the due date by 14 days.
                                                            </p>
                                                        </div>
                                                        <div class="modal-actions" style="justify-content:center;">
                                                            <button class="btn-secondary inline-btn" data-modal-close>Cancel</button>
                                                            <form method="post" action="<%= request.getContextPath() %>/transaction/renewal-requests" style="display:inline;">
                                                                <input type="hidden" name="request_id" value="<%= req.requestId %>" />
                                                                <input type="hidden" name="action" value="approve" />
                                                                <button type="submit" class="btn-primary inline-btn">
                                                                    <i class="fa-solid fa-check"></i> Confirm Approval
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        <% } %>

                                        <button class="btn-icon-text danger" data-modal-open="modal-reject-<%= req.requestId %>" style="<%= "Can be approved".equals(req.eligibilityStatus) ? "margin-left:0.5rem;" : "" %>">
                                            <i class="fa-solid fa-times"></i> Reject
                                        </button>

                                        <!-- Reject Modal -->
                                        <div class="modal" id="modal-reject-<%= req.requestId %>">
                                            <div class="modal-overlay">
                                                <div class="modal-dialog">
                                                    <div class="modal-header" style="text-align:center;">Reject Renewal Request</div>
                                                    <div class="modal-body" style="text-align:center;">
                                                        <form id="form-reject-<%= req.requestId %>" method="post" action="<%= request.getContextPath() %>/transaction/renewal-requests">
                                                            <input type="hidden" name="request_id" value="<%= req.requestId %>" />
                                                            <input type="hidden" name="action" value="reject" />

                                                            <p style="margin-bottom:0.5rem;">Rejecting renewal request for:</p>
                                                            <p style="margin-bottom:1rem;"><strong style="font-size:1.1rem;"><%= req.bookTitle %></strong></p>
                                                            <p style="margin-bottom:1rem;">Member: <strong><%= req.memberName %></strong></p>

                                                            <div class="form-field" style="text-align:left;">
                                                                <label class="label-muted">Rejection Reason<span class="req">*</span></label>
                                                                <div class="input box">
                                                                    <textarea name="rejection_reason" rows="3" required
                                                                              placeholder="Provide a reason for rejection..."></textarea>
                                                                </div>
                                                            </div>
                                                        </form>
                                                    </div>
                                                    <div class="modal-actions" style="justify-content:center;">
                                                        <button class="btn-secondary inline-btn" data-modal-close>Cancel</button>
                                                        <button class="btn-danger inline-btn" onclick="document.getElementById('form-reject-<%= req.requestId %>').submit();">
                                                            <i class="fa-solid fa-times"></i> Confirm Reject
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </section>
        </div>
    </main>
</div>

<script src="<%= request.getContextPath() %>/js/components/modal.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
