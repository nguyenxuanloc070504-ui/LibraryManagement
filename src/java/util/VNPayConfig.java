package util;

import jakarta.servlet.http.HttpServletRequest;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * VNPay Configuration and Utility Class
 * @author Library Management System
 */
public class VNPayConfig {

    // VNPay Configuration
    // NOTE: These credentials MUST match your VNPay Merchant Account
    // Get them from: https://sandbox.vnpayment.vn/merchantv2/
    public static String vnp_PayUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    // DEPRECATED: Use getReturnUrl(HttpServletRequest request) instead for dynamic URL
    // This static field is kept for backward compatibility but should not be used
    // public static String vnp_ReturnUrl = "http://localhost:8080/LibraryManagement/vnpay-return";
    public static String vnp_TmnCode = "4YUP19I4";  // TODO: Replace with your TMN Code from VNPay Merchant Portal
    public static String secretKey = "MDUIFDCRAKLNBPOFIAFNEKFRNMFBYEPX";  // TODO: Replace with your Hash Secret from VNPay Merchant Portal
    public static String vnp_ApiUrl = "https://sandbox.vnpayment.vn/merchant_webapi/api/transaction";

    /**
     * Generate MD5 hash
     */
    public static String md5(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(message.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder(2 * hash.length);
            for (byte b : hash) {
                sb.append(String.format("%02x", b & 0xff));
            }
            digest = sb.toString();
        } catch (UnsupportedEncodingException | NoSuchAlgorithmException ex) {
            digest = "";
        }
        return digest;
    }

    /**
     * Generate SHA256 hash
     */
    public static String sha256(String message) {
        String digest = null;
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(message.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder(2 * hash.length);
            for (byte b : hash) {
                sb.append(String.format("%02x", b & 0xff));
            }
            digest = sb.toString();
        } catch (UnsupportedEncodingException | NoSuchAlgorithmException ex) {
            digest = "";
        }
        return digest;
    }

    /**
     * Hash all fields for VNPay signature
     * NOTE: Fields should already be URL encoded before passing to this method
     */
    public static String hashAllFields(Map<String, String> fields) {
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        List<String> hashDataList = new ArrayList<>();
        
        for (String fieldName : fieldNames) {
            String fieldValue = fields.get(fieldName);
            if ((fieldValue != null) && (fieldValue.length() > 0)) {
                // Fields are already URL encoded, just concatenate
                hashDataList.add(fieldName + "=" + fieldValue);
            }
        }
        
        String hashData = String.join("&", hashDataList);
        System.out.println("DEBUG hashAllFields - Hash Data: " + hashData);
        String hash = hmacSHA512(secretKey, hashData);
        System.out.println("DEBUG hashAllFields - Generated Hash: " + hash);
        return hash;
    }

    /**
     * Generate HMAC SHA512 signature
     */
    public static String hmacSHA512(final String key, final String data) {
        try {
            if (key == null || data == null) {
                throw new NullPointerException();
            }
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            byte[] hmacKeyBytes = key.getBytes();
            final SecretKeySpec secretKeySpec = new SecretKeySpec(hmacKeyBytes, "HmacSHA512");
            hmac512.init(secretKeySpec);
            byte[] dataBytes = data.getBytes(StandardCharsets.UTF_8);
            byte[] result = hmac512.doFinal(dataBytes);
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }

    /**
     * Get client IP address
     */
    public static String getIpAddress(HttpServletRequest request) {
        String ipAddress;
        try {
            ipAddress = request.getHeader("X-FORWARDED-FOR");
            if (ipAddress == null) {
                ipAddress = request.getRemoteAddr();
            }
        } catch (Exception e) {
            ipAddress = "Invalid IP:" + e.getMessage();
        }
        return ipAddress;
    }

    /**
     * Generate random number string
     */
    public static String getRandomNumber(int len) {
        Random rnd = new Random();
        String chars = "0123456789";
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    /**
     * Get return URL dynamically from request
     * This ensures the return URL works on any machine (localhost, IP, or domain)
     * 
     * @param request HttpServletRequest to extract server information
     * @return Full return URL for VNPay callback
     */
    public static String getReturnUrl(HttpServletRequest request) {
        String scheme = request.getScheme(); // http or https
        String serverName = request.getServerName(); // localhost, IP, or domain
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath(); // /LibraryManagement
        
        // Build base URL
        StringBuilder url = new StringBuilder();
        url.append(scheme).append("://").append(serverName);
        
        // Add port if it's not the default port (80 for http, 443 for https)
        if ((scheme.equals("http") && serverPort != 80) || 
            (scheme.equals("https") && serverPort != 443)) {
            url.append(":").append(serverPort);
        }
        
        // Add context path and return path
        url.append(contextPath).append("/vnpay-return");
        
        return url.toString();
    }
}
