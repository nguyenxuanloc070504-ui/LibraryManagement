<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Borrow Requests</title>
    <link rel="stylesheet" href="<c:url value='/css/main.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/components/modal.css'/>">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="transaction-requests"/>
    </jsp:include>
    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Borrow Requests"/>
            <jsp:param name="pageSubtitle" value="Review and approve/reject online requests"/>
        </jsp:include>
        <div class="main-content">
            <c:if test="${not empty sessionScope.success}">
                <div class="alert-success">${sessionScope.success}</div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert-error">${sessionScope.error}</div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <!-- Pending Requests -->
            <section class="card" style="margin-bottom:1rem;">
                <h2 class="form-section-title" style="margin-top:0">Pending Requests</h2>
                <div class="table-container">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Requested At</th>
                        <th>Member</th>
                        <th>Book</th>
                        <th>Available</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="r" items="${requests}">
                        <tr>
                            <td>#${r.requestId}</td>
                            <td>${r.requestDate}</td>
                            <td>
                                <div>${r.memberName}</div>
                                <small class="muted">${r.email} · ${r.phone}</small>
                            </td>
                            <td>
                                <div>${r.bookTitle}</div>
                                <small class="muted">ISBN: ${r.isbn}</small><br/>
                                <small class="muted">${r.authors}</small>
                            </td>
                            <td>${r.availableCopies}</td>
                            <td>
                                <span class="status-badge status-pending">Pending</span>
                            </td>
                            <td style="white-space: nowrap;">
                                <form method="post" action="<c:url value='/transaction/requests'/>" style="display:inline">
                                    <input type="hidden" name="request_id" value="${r.requestId}" />
                                    <button class="btn-icon-text" type="button" data-modal-open="approveModal" data-request-id="${r.requestId}" data-book-title="${r.bookTitle}" ${r.availableCopies == 0 ? 'disabled' : ''}>
                                        <i class="fa-solid fa-check"></i> Approve
                                    </button>
                                </form>
                                <form method="post" action="<c:url value='/transaction/requests'/>" style="display:inline; margin-left:8px;">
                                    <input type="hidden" name="request_id" value="${r.requestId}" />
                                    <input type="hidden" name="reason" value="Not eligible / other" />
                                    <button class="btn-icon-text danger" type="button" data-modal-open="rejectModal" data-request-id="${r.requestId}" data-book-title="${r.bookTitle}">
                                        <i class="fa-solid fa-xmark"></i> Reject
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <tr><td colspan="7" class="muted" style="text-align:center">No pending requests.</td></tr>
                    </c:if>
                    </tbody>
                </table>
                </div>
            </section>

            <!-- Approved Awaiting Pickup -->
            <section class="card">
                <h2 class="form-section-title" style="margin-top:0">Approved - Awaiting Pickup</h2>
                <div class="table-container">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Pickup Window</th>
                        <th>Member</th>
                        <th>Book</th>
                        <th>Copy</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="r" items="${awaiting}">
                        <tr>
                            <td>#${r.requestId}</td>
                            <td>
                                <div>Ready: ${r.pickupReadyDate}</div>
                                <small class="muted">Expires: ${r.pickupExpiryDate}</small>
                            </td>
                            <td>
                                <div>${r.memberName}</div>
                                <small class="muted">${r.email} · ${r.phone}</small>
                            </td>
                            <td>
                                <div>${r.bookTitle}</div>
                                <small class="muted">ISBN: ${r.isbn}</small>
                            </td>
                            <td>${r.copyNumber}</td>
                            <td>
                                <form method="post" action="<c:url value='/transaction/requests'/>" style="display:inline">
                                    <input type="hidden" name="request_id" value="${r.requestId}" />
                                    <button class="btn-icon-text" type="button" data-modal-open="confirmPickupModal" data-request-id="${r.requestId}" data-book-title="${r.bookTitle}">
                                        <i class="fa-solid fa-box"></i> Confirm Pickup
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty awaiting}">
                        <tr><td colspan="6" class="muted" style="text-align:center">No approved requests awaiting pickup.</td></tr>
                    </c:if>
                    </tbody>
                </table>
                </div>
            </section>
        </div>
    </main>
</div>
<!-- Approve Modal -->
<div class="modal" id="approveModal">
    <div class="modal-overlay">
        <div class="modal-dialog">
            <div class="modal-header">Approve Request</div>
            <div class="modal-body">
                <p>Approve borrow request for <strong id="approveBookTitle">this book</strong>? A notification will be sent to the reader.</p>
            </div>
            <div class="modal-actions">
                <form id="approveForm" method="post" action="<c:url value='/transaction/requests'/>" style="margin:0;">
                    <input type="hidden" name="request_id" id="approveRequestId" />
                    <button class="btn-icon-text" type="submit" name="action" value="approve"><i class="fa-solid fa-check"></i> Confirm</button>
                </form>
                <button class="btn-secondary" data-modal-close>Cancel</button>
            </div>
        </div>
    </div>
    </div>

<!-- Reject Modal -->
<div class="modal" id="rejectModal">
    <div class="modal-overlay">
        <div class="modal-dialog">
            <div class="modal-header">Reject Request</div>
            <div class="modal-body">
                <p>Reject borrow request for <strong id="rejectBookTitle">this book</strong>?</p>
                <form id="rejectForm" method="post" action="<c:url value='/transaction/requests'/>" class="auth-form" style="margin-top:.5rem;">
                    <input type="hidden" name="request_id" id="rejectRequestId" />
                    <div class="form-field" style="margin:0;">
                        <label class="label-muted">Reason</label>
                        <div class="input box">
                            <input type="text" name="reason" id="rejectReason" placeholder="Optional reason"/>
                        </div>
                    </div>
                    <input type="hidden" name="action" value="reject" />
                </form>
            </div>
            <div class="modal-actions">
                <button class="btn-icon-text danger" form="rejectForm" type="submit"><i class="fa-solid fa-xmark"></i> Reject</button>
                <button class="btn-secondary" data-modal-close>Cancel</button>
            </div>
        </div>
    </div>
</div>

<!-- Confirm Pickup Modal -->
<div class="modal" id="confirmPickupModal">
    <div class="modal-overlay">
        <div class="modal-dialog">
            <div class="modal-header">Confirm Pickup</div>
            <div class="modal-body">
                <p>Confirm pickup for <strong id="pickupBookTitle">this book</strong>? This will create a borrowing record.</p>
            </div>
            <div class="modal-actions">
                <form id="confirmPickupForm" method="post" action="<c:url value='/transaction/requests'/>" style="margin:0;">
                    <input type="hidden" name="request_id" id="pickupRequestId" />
                    <button class="btn-icon-text" type="submit" name="action" value="confirm_pickup">
                        <i class="fa-solid fa-box"></i> Confirm
                    </button>
                </form>
                <button class="btn-secondary" data-modal-close>Cancel</button>
            </div>
        </div>
    </div>
</div>

<script src="<c:url value='/js/components/modal.js'/>"></script>
<script>
(function(){
  function assignData(e){
    var btn = e.target.closest('[data-modal-open]');
    if (!btn) return;
    var id = btn.getAttribute('data-request-id');
    var title = btn.getAttribute('data-book-title') || 'this book';
    if (btn.getAttribute('data-modal-open') === 'approveModal'){
      document.getElementById('approveRequestId').value = id;
      document.getElementById('approveBookTitle').textContent = title;
    } else if (btn.getAttribute('data-modal-open') === 'rejectModal'){
      document.getElementById('rejectRequestId').value = id;
      document.getElementById('rejectBookTitle').textContent = title;
    } else if (btn.getAttribute('data-modal-open') === 'confirmPickupModal'){
      document.getElementById('pickupRequestId').value = id;
      document.getElementById('pickupBookTitle').textContent = title;
    }
  }
  document.addEventListener('click', assignData);
})();
</script>
<script src="<c:url value='/js/main.js'/>"></script>
</body>
</html>


