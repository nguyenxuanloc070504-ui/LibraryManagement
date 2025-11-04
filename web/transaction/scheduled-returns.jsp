<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Scheduled Returns</title>
    <link rel="stylesheet" href="<c:url value='/css/main.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/components/button.css'/>">
</head>
<body>
<div class="layout">
    <jsp:include page="/components/sidebar.jsp">
        <jsp:param name="activeItem" value="scheduled-returns"/>
    </jsp:include>
    <main class="content">
        <jsp:include page="/components/header.jsp">
            <jsp:param name="pageTitle" value="Scheduled Returns"/>
            <jsp:param name="pageSubtitle" value="Confirm when readers return books"/>
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

            <div class="card">
                <table class="table">
                    <thead>
                    <tr>
                        <th>Scheduled</th>
                        <th>Member</th>
                        <th>Book</th>
                        <th>Borrowed</th>
                        <th>Due</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="s" items="${scheduled}">
                        <tr>
                            <td>${s.scheduledReturnDate}</td>
                            <td>
                                <div>${s.memberName}</div>
                                <small>${s.email} · ${s.phone}</small>
                            </td>
                            <td>${s.bookTitle}</td>
                            <td>${s.borrowDate}</td>
                            <td>${s.dueDate}</td>
                            <td>${s.returnStatus}</td>
                            <td>
                                <form method="post" action="<c:url value='/transaction/scheduled-returns'/>" style="display:inline">
                                    <input type="hidden" name="action" value="confirm_return" />
                                    <input type="hidden" name="transaction_id" value="${s.transactionId}" />
                                    <select name="condition_status">
                                        <option value="excellent">Excellent</option>
                                        <option value="good" selected>Good</option>
                                        <option value="fair">Fair</option>
                                        <option value="poor">Poor</option>
                                        <option value="damaged">Damaged</option>
                                    </select>
                                    <button class="btn btn-primary" type="submit">Confirm Returned</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty scheduled}">
                        <tr><td colspan="7" style="text-align:center">No scheduled returns.</td></tr>
                    </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
 </div>
</body>
</html>


