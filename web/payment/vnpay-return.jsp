<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.DecimalFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Result - VNPay</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .payment-result-container {
            max-width: 800px;
            margin: 3rem auto;
            padding: 2rem;
        }
        .payment-result-card {
            background: var(--color-bg-primary);
            border-radius: 12px;
            padding: 3rem;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .payment-icon {
            font-size: 4rem;
            margin-bottom: 1.5rem;
        }
        .payment-icon.success { color: var(--color-success); }
        .payment-icon.failed { color: var(--color-error); }
        .payment-title {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 1rem;
        }
        .payment-message {
            font-size: 1.1rem;
            color: var(--color-text-muted);
            margin-bottom: 2rem;
        }
        .payment-details {
            background: var(--color-bg-secondary);
            border-radius: 8px;
            padding: 2rem;
            margin: 2rem 0;
            text-align: left;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem 0;
            border-bottom: 1px solid var(--color-border);
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 500;
            color: var(--color-text-muted);
        }
        .detail-value {
            font-weight: 600;
            color: var(--color-text-primary);
        }
        .payment-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            align-items: center;
            margin-top: 2rem;
            flex-wrap: nowrap;
        }
        .payment-actions .btn-primary,
        .payment-actions .btn-secondary {
            flex: 0 0 auto;
            width: auto;
            min-width: fit-content;
            white-space: nowrap;
            padding: 0.75rem 1.5rem;
        }
    </style>
</head>
<body>
    <%
        String paymentStatus = (String) request.getAttribute("paymentStatus");
        String message = (String) request.getAttribute("message");
        Boolean isValidSignature = (Boolean) request.getAttribute("isValidSignature");

        String vnp_TxnRef = (String) request.getAttribute("vnp_TxnRef");
        String vnp_Amount = (String) request.getAttribute("vnp_Amount");
        String vnp_OrderInfo = (String) request.getAttribute("vnp_OrderInfo");
        String vnp_ResponseCode = (String) request.getAttribute("vnp_ResponseCode");
        String vnp_TransactionNo = (String) request.getAttribute("vnp_TransactionNo");
        String vnp_BankCode = (String) request.getAttribute("vnp_BankCode");
        String vnp_PayDate = (String) request.getAttribute("vnp_PayDate");
        String vnp_TransactionStatus = (String) request.getAttribute("vnp_TransactionStatus");

        boolean isSuccess = "success".equals(paymentStatus);

        DecimalFormat df = new DecimalFormat("#,##0");
        long amountInVND = 0;
        if (vnp_Amount != null && !vnp_Amount.isEmpty()) {
            try {
                amountInVND = Long.parseLong(vnp_Amount) / 100;
            } catch (NumberFormatException e) {
                // Handle error
            }
        }

        // Format payment date
        String formattedPayDate = "";
        if (vnp_PayDate != null && vnp_PayDate.length() == 14) {
            try {
                formattedPayDate = vnp_PayDate.substring(6, 8) + "/" +
                                  vnp_PayDate.substring(4, 6) + "/" +
                                  vnp_PayDate.substring(0, 4) + " " +
                                  vnp_PayDate.substring(8, 10) + ":" +
                                  vnp_PayDate.substring(10, 12) + ":" +
                                  vnp_PayDate.substring(12, 14);
            } catch (Exception e) {
                formattedPayDate = vnp_PayDate;
            }
        }
    %>

    <div class="payment-result-container">
        <div class="payment-result-card">
            <!-- Payment Icon -->
            <div class="payment-icon <%= isSuccess ? "success" : "failed" %>">
                <% if (isSuccess) { %>
                    <i class="fa-solid fa-circle-check"></i>
                <% } else { %>
                    <i class="fa-solid fa-circle-xmark"></i>
                <% } %>
            </div>

            <!-- Payment Title -->
            <h1 class="payment-title" style="color: <%= isSuccess ? "var(--color-success)" : "var(--color-error)" %>;">
                <%= isSuccess ? "Payment Successful!" : "Payment Failed" %>
            </h1>

            <!-- Payment Message -->
            <p class="payment-message">
                <%= message != null ? message : (isSuccess ? "Your fine payment has been processed successfully." : "Your payment could not be completed.") %>
            </p>

            <!-- Payment Details -->
            <div class="payment-details">
                <h3 style="margin-top: 0; margin-bottom: 1.5rem; color: var(--color-text-primary);">Transaction Details</h3>

                <div class="detail-row">
                    <span class="detail-label">Transaction Reference:</span>
                    <span class="detail-value"><%= vnp_TxnRef != null ? vnp_TxnRef : "-" %></span>
                </div>

                <div class="detail-row">
                    <span class="detail-label">Amount:</span>
                    <span class="detail-value" style="color: var(--color-primary); font-size: 1.2rem;">
                        <%= df.format(amountInVND) %> VND
                    </span>
                </div>

                <div class="detail-row">
                    <span class="detail-label">Description:</span>
                    <span class="detail-value"><%= vnp_OrderInfo != null ? vnp_OrderInfo : "-" %></span>
                </div>

                <% if (vnp_TransactionNo != null && !vnp_TransactionNo.isEmpty()) { %>
                <div class="detail-row">
                    <span class="detail-label">VNPay Transaction No:</span>
                    <span class="detail-value"><%= vnp_TransactionNo %></span>
                </div>
                <% } %>

                <% if (vnp_BankCode != null && !vnp_BankCode.isEmpty()) { %>
                <div class="detail-row">
                    <span class="detail-label">Bank Code:</span>
                    <span class="detail-value"><%= vnp_BankCode %></span>
                </div>
                <% } %>

                <% if (!formattedPayDate.isEmpty()) { %>
                <div class="detail-row">
                    <span class="detail-label">Payment Time:</span>
                    <span class="detail-value"><%= formattedPayDate %></span>
                </div>
                <% } %>

                <div class="detail-row">
                    <span class="detail-label">Response Code:</span>
                    <span class="detail-value"><%= vnp_ResponseCode != null ? vnp_ResponseCode : "-" %></span>
                </div>

                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="detail-value">
                        <span class="status-badge <%= isSuccess ? "status-success" : "status-locked" %>">
                            <%= isSuccess ? "Success" : "Failed" %>
                        </span>
                    </span>
                </div>

                <% if (isValidSignature != null && !isValidSignature) { %>
                <div class="detail-row">
                    <span class="detail-label" style="color: var(--color-error);">Security Warning:</span>
                    <span class="detail-value" style="color: var(--color-error);">Invalid Signature Detected</span>
                </div>
                <% } %>
            </div>

            <!-- Action Buttons -->
            <div class="payment-actions">
                <a href="<%= request.getContextPath() %>/transaction/fines" class="btn-primary">
                    <i class="fa-solid fa-list"></i> View All Fines
                </a>
                <% if (!isSuccess) { %>
                <a href="<%= request.getContextPath() %>/transaction/fines" class="btn-secondary">
                    <i class="fa-solid fa-rotate-right"></i> Try Again
                </a>
                <% } %>
                <a href="<%= request.getContextPath() %>/home" class="btn-secondary">
                    <i class="fa-solid fa-house"></i> Go Home
                </a>
            </div>
        </div>
    </div>

    <script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
