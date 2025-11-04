<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="dal.BookDAO" %>
<%
    Integer currentUserId = (Integer) request.getSession().getAttribute("authUserId");
    // Get user role from session
    String userRole = (String) session.getAttribute("authRole");
    boolean isMember = "Member".equalsIgnoreCase(userRole);
    boolean isLibrarian = "Librarian".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Details</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <% if (isMember) { %>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/pages/home.css">
    <% } %>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="<%= isMember ? "home-page" : "" %>">
<div class="<%= isMember ? "" : "layout" %>">
    <% if (isLibrarian) { %>
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="book-list"/>
    </jsp:include>
    <% } %>

    <main class="<%= isMember ? "" : "content" %>">
        <% if (isMember) { %>
        <jsp:include page="/components/header-member.jsp">
            <jsp:param name="activeTab" value="books"/>
        </jsp:include>
        <% } else { %>
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Book Details"/>
            <jsp:param name="pageSubtitle" value="View complete book information, availability status, location"/>
        </jsp:include>
        <% } %>

        <div class="<%= isMember ? "container" : "main-content" %>" style="<%= isMember ? "padding-top: 2rem; padding-bottom: 2rem;" : "" %>">
            <% 
                String successMsg = (String) request.getSession().getAttribute("success");
                String errorMsg = (String) request.getSession().getAttribute("error");
                if (successMsg != null) {
                    request.getSession().removeAttribute("success");
            %>
                <div class="alert-success"><%= successMsg %></div>
            <% } %>
            <% if (errorMsg != null) {
                    request.getSession().removeAttribute("error");
            %>
                <div class="alert-error"><%= errorMsg %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert-error"><%= request.getAttribute("error") %></div>
            <% } %>

            <% BookDAO.BookDetail book = (BookDAO.BookDetail) request.getAttribute("book"); %>
            <% if (book != null) { %>
                <section class="card">
                    <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 2rem;">
                        <div>
                            <% if (book.coverImage != null && !book.coverImage.isEmpty()) { %>
                                <img src="<%= book.coverImage %>" alt="<%= book.title %>" style="width: 100%; max-width: 300px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />
                            <% } else { %>
                                <div style="width: 100%; max-width: 300px; height: 400px; background: var(--color-bg-secondary); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--color-text-muted);">
                                    <i class="fa-solid fa-book" style="font-size: 4rem;"></i>
                                </div>
                            <% } %>
                        </div>
                        <div>
                            <h2 style="margin-top: 0; font-size: 2rem;"><%= book.title %></h2>
                            
                            <div class="member-info-card" style="margin: 1.5rem 0;">
                                <div class="info-row">
                                    <span class="info-label">ISBN:</span>
                                    <span class="info-value"><%= book.isbn != null ? book.isbn : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Authors:</span>
                                    <span class="info-value">
                                        <% if (book.authorNames != null && !book.authorNames.isEmpty()) { %>
                                            <%= String.join(", ", book.authorNames) %>
                                        <% } else { %>
                                            N/A
                                        <% } %>
                                    </span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Category:</span>
                                    <span class="info-value"><%= book.categoryName != null ? book.categoryName : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Publisher:</span>
                                    <span class="info-value"><%= book.publisherName != null ? book.publisherName : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Publication Year:</span>
                                    <span class="info-value"><%= book.publicationYear != null ? book.publicationYear : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Edition:</span>
                                    <span class="info-value"><%= book.edition != null ? book.edition : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Language:</span>
                                    <span class="info-value"><%= book.language != null ? book.language : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Pages:</span>
                                    <span class="info-value"><%= book.pages != null ? book.pages : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Shelf Location:</span>
                                    <span class="info-value"><%= book.shelfLocation != null ? book.shelfLocation : "N/A" %></span>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Availability:</span>
                                    <span class="info-value">
                                        <% if (book.availableCopies > 0) { %>
                                            <span class="status-badge status-active"><%= book.availableCopies %> copies available</span>
                                        <% } else { %>
                                            <span class="status-badge status-locked">Currently unavailable</span>
                                        <% } %>
                                        (<%= book.totalCopies %> total copies)
                                    </span>
                                </div>
                            </div>

                            <% if (book.description != null && !book.description.isEmpty()) { %>
                                <div style="margin-top: 1.5rem;">
                                    <h3>Description</h3>
                                    <p style="line-height: 1.6; color: var(--color-text);"><%= book.description %></p>
                                </div>
                            <% } %>

                            <div class="form-actions" style="margin-top: 2rem;">
                                <% Boolean hasReservation = (Boolean) request.getAttribute("hasReservation"); %>
                                <% dal.BorrowRequestDAO.BorrowRequestDetail borrowRequest = (dal.BorrowRequestDAO.BorrowRequestDetail) request.getAttribute("borrowRequest"); %>
                                <% if (currentUserId != null) { %>
                                    <% if (hasReservation != null && hasReservation) { %>
                                        <span class="text-muted" style="margin-right: 1rem;">
                                            <i class="fa-solid fa-bookmark"></i> You have an active reservation for this book
                                        </span>
                                        <a href="<%= request.getContextPath() %>/books/my-reservations" class="btn-secondary">
                                            View My Reservations
                                        </a>
                                    <% } else if (borrowRequest != null) { %>
                                        <!-- <span class="text-muted" style="margin-right: 1rem;">
                                            <i class="fa-solid fa-hourglass-half"></i>
                                            Request status: <strong><%= borrowRequest.requestStatus %></strong>
                                        </span> -->
                                        <% if ("pending".equalsIgnoreCase(borrowRequest.requestStatus)) { %>
                                            <form id="cancelRequestForm-<%= borrowRequest.requestId %>" method="post" action="<%= request.getContextPath() %>/transaction/cancel-request" style="display: inline; margin-right: 1rem;">
                                                <input type="hidden" name="request_id" value="<%= borrowRequest.requestId %>" />
                                                <input type="hidden" name="book_id" value="<%= book.bookId %>" />
                                                <button class="btn-danger inline-btn" type="button" onclick="openCancelModal('<%= borrowRequest.requestId %>')">
                                                    <i class="fa-solid fa-xmark"></i> Cancel Request
                                                </button>
                                            </form>

                                            <!-- Cancel Request Confirmation Modal -->
                                            <div id="cancelConfirmModal-<%= borrowRequest.requestId %>" class="modal">
                                                <div class="modal-overlay" onclick="closeModal('cancelConfirmModal-<%= borrowRequest.requestId %>')">
                                                    <div class="modal-dialog" onclick="event.stopPropagation()">
                                                        <div class="modal-header">
                                                            <i class="fa-solid fa-triangle-exclamation" style="color: var(--color-error); margin-right: 8px;"></i>
                                                            Confirm Cancel Request
                                                        </div>
                                                        <div class="modal-body">
                                                            <p>Are you sure you want to cancel your borrow request for <strong><%= book.title %></strong>?</p>
                                                        </div>
                                                        <div class="modal-actions">
                                                            <button class="btn-secondary inline-btn" type="button" onclick="closeModal('cancelConfirmModal-<%= borrowRequest.requestId %>')">Close</button>
                                                            <button class="btn-danger inline-btn" type="button" onclick="submitCancelRequest('cancelRequestForm-<%= borrowRequest.requestId %>')">
                                                                <i class="fa-solid fa-xmark"></i> Confirm Cancel
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        <% } %>
                                    <% } else if (book.availableCopies > 0) { %>
                                        <form id="borrowRequestForm" method="post" action="<%= request.getContextPath() %>/transaction/request" style="display: inline; margin-right: 1rem;">
                                            <input type="hidden" name="book_id" value="<%= book.bookId %>" />
                                            <button class="btn-primary" type="button" onclick="showBorrowConfirmModal('<%= book.title != null ? book.title.replace("'", "\\'") : "" %>', '<%= book.bookId %>')">
                                                <i class="fa-solid fa-handshake"></i> Request to Borrow
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <span class="text-muted" style="margin-right: 1rem;">
                                            <i class="fa-solid fa-circle-info"></i> Currently unavailable. Reservations are disabled.
                                        </span>
                                    <% } %>
                                <% } %>
                                <a href="<%= request.getContextPath() %><%= isMember ? "/book/list" : "/books" %>" class="btn-secondary inline-btn no-underline">
                                    <i class="fa-solid fa-arrow-left"></i> Back to List
                                </a>
                            </div>
                        </div>
                    </div>
                </section>
            <% } else { %>
                <section class="card">
                    <p>Book not found.</p>
                    <a href="<%= request.getContextPath() %><%= isMember ? "/book/list" : "/books" %>" class="btn-secondary inline-btn no-underline">Back to Search</a>
                </section>
            <% } %>
        </div>
    </main>
</div>

<!-- Borrow Confirmation Modal -->
<div id="borrowConfirmModal" class="modal">
    <div class="modal-overlay" onclick="closeModal('borrowConfirmModal')">
        <div class="modal-dialog" onclick="event.stopPropagation()">
            <div class="modal-header">
                <i class="fa-solid fa-handshake" style="color: var(--color-primary); margin-right: 8px;"></i>
                Confirm Borrow Request
            </div>
            <div class="modal-body">
                <p>Are you sure you want to request to borrow this book?</p>
                <p style="font-weight: 600; margin-top: 12px;" id="borrowBookTitle"></p>
                <p style="font-size: 0.9rem; color: var(--color-text-muted); margin-top: 8px;">
                    <i class="fa-solid fa-info-circle"></i>
                    You will be notified when the book is ready for pickup.
                </p>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-secondary" onclick="closeModal('borrowConfirmModal')">
                    Cancel
                </button>
                <button type="button" class="btn-primary" onclick="submitBorrowRequest()">
                    <i class="fa-solid fa-check"></i> Confirm Request
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Reserve Confirmation Modal -->
<!-- Removed reserveConfirmModal -->
<!-- <div id="reserveConfirmModal" class="modal">
    <div class="modal-overlay" onclick="closeModal('reserveConfirmModal')">
        <div class="modal-dialog" onclick="event.stopPropagation()">
            <div class="modal-header">
                <i class="fa-solid fa-bookmark" style="color: var(--color-primary); margin-right: 8px;"></i>
                Confirm Book Reservation
            </div>
            <div class="modal-body">
                <p>Are you sure you want to reserve this book?</p>
                <p style="font-weight: 600; margin-top: 12px;" id="reserveBookTitle"></p>
                <p style="font-size: 0.9rem; color: var(--color-text-muted); margin-top: 8px;">
                    <i class="fa-solid fa-info-circle"></i>
                    This book is currently unavailable. You will be notified when it becomes available.
                </p>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-secondary" onclick="closeModal('reserveConfirmModal')">
                    Cancel
                </button>
                <button type="button" class="btn-primary" onclick="submitReservation()">
                    <i class="fa-solid fa-check"></i> Confirm Reservation
                </button>
            </div>
        </div>
    </div>
</div> -->

<script src="<%= request.getContextPath() %>/js/utils/validate.js"></script>
<script src="<%= request.getContextPath() %>/js/utils/format.js"></script>
<script src="<%= request.getContextPath() %>/js/components/dropdown.js"></script>
<script src="<%= request.getContextPath() %>/js/main.js"></script>

<script>
// Modal control functions
function showBorrowConfirmModal(bookTitle, bookId) {
    document.getElementById('borrowBookTitle').textContent = bookTitle;
    document.getElementById('borrowConfirmModal').classList.add('open');
    document.body.style.overflow = 'hidden';
}

// reservation modal removed

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('open');
    document.body.style.overflow = '';
}

function submitBorrowRequest() {
    document.getElementById('borrowRequestForm').submit();
}

function submitReservation() {
    document.getElementById('reserveForm').submit();
}

function openCancelModal(requestId) {
    var id = 'cancelConfirmModal-' + requestId;
    document.getElementById(id).classList.add('open');
    document.body.style.overflow = 'hidden';
}

function submitCancelRequest(formId) {
    document.getElementById(formId).submit();
}

// Close modal on ESC key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        closeModal('borrowConfirmModal');
        // closeModal('reserveConfirmModal'); // removed
        // Close any cancel modal if present (best-effort)
        var cancelModals = document.querySelectorAll('[id^="cancelConfirmModal-"]');
        cancelModals.forEach(function(el){ el.classList.remove('open'); });
    }
});
</script>

</body>
</html>

