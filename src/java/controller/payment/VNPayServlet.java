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
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Servlet for initiating VNPay payment for fines
 */
@WebServlet(name = "VNPayServlet", urlPatterns = {"/vnpay-payment"})
public class VNPayServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get fine ID from request
            String fineIdStr = request.getParameter("fine_id");
            if (fineIdStr == null || fineIdStr.isEmpty()) {
                request.setAttribute("error", "Fine ID is required");
                response.sendRedirect(request.getContextPath() + "/transaction/fines");
                return;
            }

            int fineId = Integer.parseInt(fineIdStr);

            // Get fine details
            TransactionDAO dao = new TransactionDAO();
            TransactionDAO.FineDetail fine = dao.getFineById(fineId);
            dao.close();

            if (fine == null) {
                request.setAttribute("error", "Fine not found");
                response.sendRedirect(request.getContextPath() + "/transaction/fines");
                return;
            }

            // Check if fine belongs to user or user is librarian
            String userRole = (String) request.getSession().getAttribute("authRole");
            if (!userId.equals(fine.userId) && !"Librarian".equals(userRole)) {
                request.setAttribute("error", "Unauthorized access");
                response.sendRedirect(request.getContextPath() + "/transaction/fines");
                return;
            }

            // Check if fine is already paid
            if (!"unpaid".equals(fine.paymentStatus)) {
                request.setAttribute("error", "Fine has already been processed");
                response.sendRedirect(request.getContextPath() + "/transaction/fines");
                return;
            }

            // VNPay payment parameters
            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String orderType = "other";

            // Amount in VND cents (multiply by 100)
            // Assuming fine amount is in USD, convert to VND (1 USD = 25,000 VND approximately)
            // Then multiply by 100 for VNPay format (cents)
            long amount = (long) (fine.fineAmount.doubleValue() * 25000 * 100);

            // Generate unique transaction reference
            String vnp_TxnRef = "FINE" + fineId + "_" + VNPayConfig.getRandomNumber(8);
            String vnp_IpAddr = VNPayConfig.getIpAddress(request);
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;

            // Build VNPay parameters
            Map<String, String> vnp_Params = new HashMap<>();
            vnp_Params.put("vnp_Version", vnp_Version);
            vnp_Params.put("vnp_Command", vnp_Command);
            vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amount));
            vnp_Params.put("vnp_CurrCode", "VND");

            String bankCode = request.getParameter("bankCode");
            if (bankCode != null && !bankCode.trim().isEmpty()) {
                vnp_Params.put("vnp_BankCode", bankCode.trim());
            }

            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", "Thanh toan phi tre han #" + fineId + " - " + fine.memberName);
            vnp_Params.put("vnp_OrderType", orderType);

            String locale = request.getParameter("language");
            if (locale != null && !locale.isEmpty()) {
                vnp_Params.put("vnp_Locale", locale);
            } else {
                vnp_Params.put("vnp_Locale", "vn");
            }

            vnp_Params.put("vnp_ReturnUrl", VNPayConfig.getReturnUrl(request));
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            // Set expiry time (15 minutes)
            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnp_CreateDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

            cld.add(Calendar.MINUTE, 15);
            String vnp_ExpireDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

            // Build query string and hash
            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);
            
            List<String> hashDataList = new ArrayList<>();
            List<String> queryList = new ArrayList<>();

            for (String fieldName : fieldNames) {
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    // Build hash data (URL encoded with UTF-8, following VNPay sample code)
                    hashDataList.add(fieldName + "=" + URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString()));

                    // Build query (URL encoded)
                    queryList.add(URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString()) 
                                + "=" 
                                + URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString()));
                }
            }

            String hashData = String.join("&", hashDataList);
            String queryUrl = String.join("&", queryList);
            
            // Debug logging
            System.out.println("=== VNPay Payment Debug ===");
            System.out.println("Hash Data: " + hashData);
            System.out.println("Secret Key: " + VNPayConfig.secretKey);
            
            String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.secretKey, hashData);
            System.out.println("Secure Hash: " + vnp_SecureHash);
            
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;
            
            System.out.println("Payment URL: " + paymentUrl);
            System.out.println("=========================");

            // Save payment record as pending
            TransactionDAO transactionDAO = new TransactionDAO();
            try {
                transactionDAO.createVNPayPayment(fineId, fine.userId, vnp_TxnRef, amount, vnp_Params.get("vnp_OrderInfo"));

                // Update fine status to pending
                transactionDAO.updateFinePaymentStatus(fineId, "pending", null, vnp_TxnRef);
            } catch (SQLException e) {
                request.setAttribute("error", "Failed to create payment record: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/transaction/fines");
                return;
            } finally {
                transactionDAO.close();
            }

            // Redirect to VNPay payment gateway
            response.sendRedirect(paymentUrl);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid fine ID");
            response.sendRedirect(request.getContextPath() + "/transaction/fines");
        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/transaction/fines");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/transaction/fines");
    }
}
