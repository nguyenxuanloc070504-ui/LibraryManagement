package controller.payment;

import dal.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.VNPayConfig;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.*;

/**
 * Servlet for handling VNPay payment return callback
 */
@WebServlet(name = "VNPayReturnServlet", urlPatterns = {"/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get all parameters from VNPay
        // IMPORTANT: For hash verification, parameters must be URL encoded (per VNPay spec)
        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
            String fieldName = params.nextElement();
            String fieldValue = request.getParameter(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                // URL encode both field name and value for hash verification
                try {
                    String encodedName = java.net.URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString());
                    String encodedValue = java.net.URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString());
                    fields.put(encodedName, encodedValue);
                } catch (Exception e) {
                    System.err.println("ERROR: Failed to encode field " + fieldName + ": " + e.getMessage());
                    fields.put(fieldName, fieldValue); // Fallback to non-encoded
                }
            }
        }

        // Get secure hash from VNPay (original, not encoded)
        String vnp_SecureHash = request.getParameter("vnp_SecureHash");

        // Remove hash fields before validating (using encoded keys)
        try {
            String encodedHashType = java.net.URLEncoder.encode("vnp_SecureHashType", StandardCharsets.UTF_8.toString());
            String encodedHash = java.net.URLEncoder.encode("vnp_SecureHash", StandardCharsets.UTF_8.toString());
            if (fields.containsKey(encodedHashType)) {
                fields.remove(encodedHashType);
            }
            if (fields.containsKey(encodedHash)) {
                fields.remove(encodedHash);
            }
        } catch (Exception e) {
            // Fallback to non-encoded keys
            fields.remove("vnp_SecureHashType");
            fields.remove("vnp_SecureHash");
        }

        System.out.println("DEBUG: VNPay SecureHash from response: " + vnp_SecureHash);
        
        // Validate signature
        String signValue = VNPayConfig.hashAllFields(fields);
        boolean isValidSignature = signValue.equals(vnp_SecureHash);
        
        System.out.println("DEBUG: Signature validation result: " + isValidSignature);

        // Get payment details
        String vnp_TxnRef = request.getParameter("vnp_TxnRef");
        String vnp_Amount = request.getParameter("vnp_Amount");
        String vnp_OrderInfo = request.getParameter("vnp_OrderInfo");
        String vnp_ResponseCode = request.getParameter("vnp_ResponseCode");
        String vnp_TransactionNo = request.getParameter("vnp_TransactionNo");
        String vnp_BankCode = request.getParameter("vnp_BankCode");
        String vnp_PayDate = request.getParameter("vnp_PayDate");
        String vnp_TransactionStatus = request.getParameter("vnp_TransactionStatus");
        String vnp_CardType = request.getParameter("vnp_CardType");

        // Set attributes for JSP display
        request.setAttribute("vnp_TxnRef", vnp_TxnRef);
        request.setAttribute("vnp_Amount", vnp_Amount);
        request.setAttribute("vnp_OrderInfo", vnp_OrderInfo);
        request.setAttribute("vnp_ResponseCode", vnp_ResponseCode);
        request.setAttribute("vnp_TransactionNo", vnp_TransactionNo);
        request.setAttribute("vnp_BankCode", vnp_BankCode);
        request.setAttribute("vnp_PayDate", vnp_PayDate);
        request.setAttribute("vnp_TransactionStatus", vnp_TransactionStatus);
        request.setAttribute("vnp_CardType", vnp_CardType);
        request.setAttribute("isValidSignature", isValidSignature);

        // Process payment result
        TransactionDAO dao = new TransactionDAO();
        String paymentStatus = "failed";
        String message = "";

        try {
            if (isValidSignature) {
                // Check transaction status
                if ("00".equals(vnp_ResponseCode) && "00".equals(vnp_TransactionStatus)) {
                    // Payment successful
                    paymentStatus = "success";
                    message = "Payment successful!";

                    // Update VNPay payment record
                    dao.updateVNPayPayment(
                        vnp_TxnRef,
                        vnp_BankCode,
                        vnp_CardType,
                        vnp_PayDate,
                        vnp_ResponseCode,
                        vnp_TransactionNo,
                        vnp_TransactionStatus,
                        vnp_SecureHash,
                        "success"
                    );

                    // Get fine ID from transaction reference
                    int fineId = extractFineIdFromTxnRef(vnp_TxnRef);
                    if (fineId > 0) {
                        // Update fine status to paid
                        dao.updateFinePaymentStatus(fineId, "paid", "VNPay", vnp_TxnRef);

                        // Get librarian user ID (if any) for processed_by
                        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
                        if (userId != null) {
                            dao.updateFineProcessedBy(fineId, userId);
                        }
                    }

                } else {
                    // Payment failed
                    paymentStatus = "failed";
                    
                    // Get friendly error message based on response code
                    String errorMessage = getVNPayErrorMessage(vnp_ResponseCode);
                    message = "Payment failed: " + errorMessage + " (Code: " + vnp_ResponseCode + ")";

                    // Update VNPay payment record
                    dao.updateVNPayPayment(
                        vnp_TxnRef,
                        vnp_BankCode,
                        vnp_CardType,
                        vnp_PayDate,
                        vnp_ResponseCode,
                        vnp_TransactionNo,
                        vnp_TransactionStatus,
                        vnp_SecureHash,
                        "failed"
                    );

                    // IMPORTANT: Reset fine status to unpaid so user can retry
                    int fineId = extractFineIdFromTxnRef(vnp_TxnRef);
                    if (fineId > 0) {
                        try {
                            dao.updateFinePaymentStatus(fineId, "unpaid", null, null);
                            System.out.println("DEBUG: Fine #" + fineId + " status reset to 'unpaid' after payment failure");
                        } catch (SQLException e) {
                            System.err.println("ERROR: Failed to reset fine #" + fineId + " to unpaid: " + e.getMessage());
                            message += " Warning: Please contact librarian to reset fine status.";
                        }
                    } else {
                        System.err.println("ERROR: Could not extract fine ID from transaction reference: " + vnp_TxnRef);
                    }
                }
            } else {
                // Invalid signature
                paymentStatus = "failed";
                message = "Invalid payment signature. This transaction may be fraudulent. Please contact support.";

                // Update VNPay payment record
                dao.updateVNPayPayment(
                    vnp_TxnRef,
                    vnp_BankCode,
                    vnp_CardType,
                    vnp_PayDate,
                    vnp_ResponseCode,
                    vnp_TransactionNo,
                    vnp_TransactionStatus,
                    vnp_SecureHash,
                    "failed"
                );

                // IMPORTANT: Reset fine status to unpaid so user can retry
                int fineId = extractFineIdFromTxnRef(vnp_TxnRef);
                if (fineId > 0) {
                    try {
                        dao.updateFinePaymentStatus(fineId, "unpaid", null, null);
                        System.out.println("DEBUG: Fine #" + fineId + " status reset to 'unpaid' after invalid signature");
                    } catch (SQLException e) {
                        System.err.println("ERROR: Failed to reset fine #" + fineId + " to unpaid: " + e.getMessage());
                        message += " Warning: Please contact librarian to reset fine status.";
                    }
                } else {
                    System.err.println("ERROR: Could not extract fine ID from transaction reference: " + vnp_TxnRef);
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Database error in VNPay return: " + e.getMessage());
            e.printStackTrace();
            message = "Database error: " + e.getMessage();
            paymentStatus = "failed";
            
            // Try to reset fine status even on database error
            try {
                int fineId = extractFineIdFromTxnRef(vnp_TxnRef);
                if (fineId > 0 && dao != null) {
                    dao.updateFinePaymentStatus(fineId, "unpaid", null, null);
                    System.out.println("DEBUG: Fine #" + fineId + " status reset to 'unpaid' after database error");
                }
            } catch (Exception ex) {
                System.err.println("ERROR: Could not reset fine status after error: " + ex.getMessage());
            }
        } finally {
            dao.close();
        }

        request.setAttribute("paymentStatus", paymentStatus);
        request.setAttribute("message", message);

        // Forward to result page
        request.getRequestDispatcher("/payment/vnpay-return.jsp").forward(request, response);
    }

    /**
     * Extract fine ID from VNPay transaction reference
     * Format: FINE{fineId}_{randomNumber}
     */
    private int extractFineIdFromTxnRef(String txnRef) {
        try {
            if (txnRef != null && txnRef.startsWith("FINE")) {
                String idPart = txnRef.substring(4); // Remove "FINE" prefix
                int underscoreIndex = idPart.indexOf('_');
                if (underscoreIndex > 0) {
                    int fineId = Integer.parseInt(idPart.substring(0, underscoreIndex));
                    System.out.println("DEBUG: Extracted fine ID " + fineId + " from txn ref: " + txnRef);
                    return fineId;
                }
            }
        } catch (Exception e) {
            System.err.println("ERROR: Failed to extract fine ID from txn ref '" + txnRef + "': " + e.getMessage());
        }
        return 0;
    }
    
    /**
     * Get friendly error message for VNPay response codes
     */
    private String getVNPayErrorMessage(String responseCode) {
        if (responseCode == null) return "Unknown error";
        
        switch (responseCode) {
            case "07": return "Transaction was successful but the transaction confirmation request was rejected by the issuing bank";
            case "09": return "Card/Account has not been registered for Internet Banking service at the bank";
            case "10": return "Customer authenticated the card/account incorrectly more than 3 times";
            case "11": return "Transaction timeout. Please try again";
            case "12": return "Card/Account is locked";
            case "13": return "Incorrect OTP. Please try again";
            case "24": return "Transaction cancelled by user";
            case "51": return "Insufficient funds in account";
            case "65": return "Transaction limit exceeded";
            case "75": return "Payment gateway is under maintenance";
            case "79": return "Transaction timeout, please try again";
            default: return "Transaction failed";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
