package controller.reports;

import dal.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(name = "ExportReportServlet", urlPatterns = {"/reports/export"})
public class ExportReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check authentication
        Integer userId = (Integer) request.getSession().getAttribute("authUserId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String reportType = request.getParameter("type");
        String format = request.getParameter("format"); // csv, excel, pdf

        if (reportType == null || format == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        ReportDAO dao = new ReportDAO();
        try {
            switch (format.toLowerCase()) {
                case "csv":
                    exportToCSV(request, response, dao, reportType);
                    break;
                case "excel":
                    exportToExcel(request, response, dao, reportType);
                    break;
                case "pdf":
                    exportToPDF(request, response, dao, reportType);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid format");
            }
        } catch (SQLException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Database error: " + e.getMessage());
        } catch (Exception e) {
            // Fallback error to avoid opaque browser errors like ERR_INVALID_RESPONSE
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("text/plain;charset=UTF-8");
            e.printStackTrace(response.getWriter());
        } finally {
            dao.close();
        }
    }

    private void exportToCSV(HttpServletRequest request, HttpServletResponse response,
                            ReportDAO dao, String reportType) throws SQLException, IOException {
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + reportType + "_report.csv\"");

        PrintWriter writer = response.getWriter();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

        switch (reportType) {
            case "dashboard":
                ReportDAO.DashboardStats stats = dao.getDashboardStatistics();
                writer.println("Metric,Value");
                writer.println("Total Books," + stats.totalBooks);
                writer.println("Available Copies," + stats.availableCopies);
                writer.println("Total Members," + stats.totalMembers);
                writer.println("Current Borrows," + stats.currentBorrows);
                writer.println("Overdue Books," + stats.overdueBooks);
                writer.println("Active Reservations," + stats.activeReservations);
                writer.println("Total Unpaid Fines," + stats.totalUnpaidFines);
                writer.println("Pending Renewal Requests," + stats.pendingRenewalRequests);
                break;

            case "popular-books":
                int periodDays = getIntParameter(request, "period", 90);
                int limit = getIntParameter(request, "limit", 20);
                List<ReportDAO.PopularBook> books = dao.getPopularBooks(periodDays, limit);

                writer.println("Book ID,Title,ISBN,Category,Authors,Total Borrows,Borrows Last Month,Current Reservations,Avg Borrow Duration");
                for (ReportDAO.PopularBook book : books) {
                    writer.println(String.format("%d,\"%s\",\"%s\",\"%s\",\"%s\",%d,%d,%d,%.2f",
                        book.bookId, escapeCsv(book.title), escapeCsv(book.isbn),
                        escapeCsv(book.categoryName), escapeCsv(book.authors),
                        book.totalBorrows, book.borrowsLastMonth, book.currentReservations,
                        book.avgBorrowDuration));
                }
                break;

            case "active-members":
                periodDays = getIntParameter(request, "period", 90);
                limit = getIntParameter(request, "limit", 20);
                List<ReportDAO.ActiveMember> members = dao.getMostActiveMembers(periodDays, limit);

                writer.println("User ID,Full Name,Email,Phone,Membership Type,Total Borrows,Returned Count,Overdue Count,Total Fines");
                for (ReportDAO.ActiveMember member : members) {
                    writer.println(String.format("%d,\"%s\",\"%s\",\"%s\",\"%s\",%d,%d,%d,%.2f",
                        member.userId, escapeCsv(member.fullName), escapeCsv(member.email),
                        escapeCsv(member.phone), escapeCsv(member.membershipType),
                        member.totalBorrows, member.returnedCount, member.overdueCount,
                        member.totalFines));
                }
                break;

            case "fine-revenue":
                String startDateStr = request.getParameter("start_date");
                String endDateStr = request.getParameter("end_date");
                java.sql.Date startDate = startDateStr != null ?
                    java.sql.Date.valueOf(startDateStr) :
                    new java.sql.Date(System.currentTimeMillis() - 30L * 24 * 60 * 60 * 1000);
                java.sql.Date endDate = endDateStr != null ?
                    java.sql.Date.valueOf(endDateStr) :
                    new java.sql.Date(System.currentTimeMillis());

                List<ReportDAO.FineRevenue> revenues = dao.getFineRevenueReport(startDate, endDate);

                writer.println("Date,Total Fines,Total Amount,Collected Amount,Pending Amount,Waived Amount,Avg Fine Amount");
                for (ReportDAO.FineRevenue revenue : revenues) {
                    writer.println(String.format("%s,%d,%.2f,%.2f,%.2f,%.2f,%.2f",
                        dateFormat.format(revenue.date), revenue.totalFines,
                        revenue.totalAmount, revenue.collectedAmount, revenue.pendingAmount,
                        revenue.waivedAmount, revenue.avgFineAmount));
                }
                break;

            case "categories":
                List<ReportDAO.CategoryStat> categoryStats = dao.getCategoryStatistics();

                writer.println("Category ID,Category Name,Total Books,Available Copies,Total Borrows,Borrows Last Month");
                for (ReportDAO.CategoryStat stat : categoryStats) {
                    writer.println(String.format("%d,\"%s\",%d,%d,%d,%d",
                        stat.categoryId, escapeCsv(stat.categoryName), stat.totalBooks,
                        stat.availableCopies, stat.totalBorrows, stat.borrowsLastMonth));
                }
                break;

            case "overdue-books":
                List<ReportDAO.OverdueBookDetail> overdueBooks = dao.getOverdueBooks();

                writer.println("Transaction ID,Member Name,Email,Phone,Book Title,ISBN,Copy Number,Borrow Date,Due Date,Days Overdue,Calculated Fine,Fine Status");
                for (ReportDAO.OverdueBookDetail detail : overdueBooks) {
                    writer.println(String.format("%d,\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%s,%s,%d,%.2f,\"%s\"",
                        detail.transactionId, escapeCsv(detail.memberName), escapeCsv(detail.email),
                        escapeCsv(detail.phone), escapeCsv(detail.bookTitle), escapeCsv(detail.isbn),
                        escapeCsv(detail.copyNumber), dateFormat.format(detail.borrowDate),
                        dateFormat.format(detail.dueDate), detail.daysOverdue, detail.calculatedFine,
                        escapeCsv(detail.fineStatus)));
                }
                break;

            default:
                writer.println("Error: Unknown report type");
        }

        writer.flush();
    }

    private void exportToExcel(HttpServletRequest request, HttpServletResponse response,
                              ReportDAO dao, String reportType) throws SQLException, IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + reportType + "_report.xlsx\"");

        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Report");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

        // Create header style
        CellStyle headerStyle = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerFont.setFontHeightInPoints((short) 12);
        headerStyle.setFont(headerFont);
        headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        headerStyle.setBorderBottom(BorderStyle.THIN);
        headerStyle.setBorderTop(BorderStyle.THIN);
        headerStyle.setBorderLeft(BorderStyle.THIN);
        headerStyle.setBorderRight(BorderStyle.THIN);

        // Create data style
        CellStyle dataStyle = workbook.createCellStyle();
        dataStyle.setBorderBottom(BorderStyle.THIN);
        dataStyle.setBorderTop(BorderStyle.THIN);
        dataStyle.setBorderLeft(BorderStyle.THIN);
        dataStyle.setBorderRight(BorderStyle.THIN);

        int rowNum = 0;

        switch (reportType) {
            case "dashboard":
                ReportDAO.DashboardStats stats = dao.getDashboardStatistics();
                createExcelRow(sheet, rowNum++, headerStyle, "Metric", "Value");
                createExcelRow(sheet, rowNum++, dataStyle, "Total Books", String.valueOf(stats.totalBooks));
                createExcelRow(sheet, rowNum++, dataStyle, "Available Copies", String.valueOf(stats.availableCopies));
                createExcelRow(sheet, rowNum++, dataStyle, "Total Members", String.valueOf(stats.totalMembers));
                createExcelRow(sheet, rowNum++, dataStyle, "Current Borrows", String.valueOf(stats.currentBorrows));
                createExcelRow(sheet, rowNum++, dataStyle, "Overdue Books", String.valueOf(stats.overdueBooks));
                createExcelRow(sheet, rowNum++, dataStyle, "Active Reservations", String.valueOf(stats.activeReservations));
                createExcelRow(sheet, rowNum++, dataStyle, "Total Unpaid Fines", String.format("%.2f", stats.totalUnpaidFines));
                createExcelRow(sheet, rowNum++, dataStyle, "Pending Renewal Requests", String.valueOf(stats.pendingRenewalRequests));
                break;

            case "popular-books":
                int periodDays = getIntParameter(request, "period", 90);
                int limit = getIntParameter(request, "limit", 20);
                List<ReportDAO.PopularBook> books = dao.getPopularBooks(periodDays, limit);

                createExcelRow(sheet, rowNum++, headerStyle, "Rank", "Title", "ISBN", "Category", "Authors",
                              "Total Borrows", "Borrows Last Month", "Current Reservations", "Avg Duration (days)");

                int rank = 1;
                for (ReportDAO.PopularBook book : books) {
                    createExcelRow(sheet, rowNum++, dataStyle,
                        String.valueOf(rank++), book.title, book.isbn, book.categoryName, book.authors,
                        String.valueOf(book.totalBorrows), String.valueOf(book.borrowsLastMonth),
                        String.valueOf(book.currentReservations), String.format("%.2f", book.avgBorrowDuration));
                }
                break;

            case "active-members":
                periodDays = getIntParameter(request, "period", 90);
                limit = getIntParameter(request, "limit", 20);
                List<ReportDAO.ActiveMember> members = dao.getMostActiveMembers(periodDays, limit);

                createExcelRow(sheet, rowNum++, headerStyle, "Rank", "Full Name", "Email", "Phone",
                              "Membership Type", "Total Borrows", "Returned Count", "Overdue Count", "Total Fines");

                rank = 1;
                for (ReportDAO.ActiveMember member : members) {
                    createExcelRow(sheet, rowNum++, dataStyle,
                        String.valueOf(rank++), member.fullName, member.email, member.phone, member.membershipType,
                        String.valueOf(member.totalBorrows), String.valueOf(member.returnedCount),
                        String.valueOf(member.overdueCount), String.format("%.2f", member.totalFines));
                }
                break;

            case "fine-revenue":
                String startDateStr = request.getParameter("start_date");
                String endDateStr = request.getParameter("end_date");
                java.sql.Date startDate = startDateStr != null ?
                    java.sql.Date.valueOf(startDateStr) :
                    new java.sql.Date(System.currentTimeMillis() - 30L * 24 * 60 * 60 * 1000);
                java.sql.Date endDate = endDateStr != null ?
                    java.sql.Date.valueOf(endDateStr) :
                    new java.sql.Date(System.currentTimeMillis());

                List<ReportDAO.FineRevenue> revenues = dao.getFineRevenueReport(startDate, endDate);

                createExcelRow(sheet, rowNum++, headerStyle, "Date", "Total Fines", "Total Amount",
                              "Collected Amount", "Pending Amount", "Waived Amount", "Avg Fine Amount");

                for (ReportDAO.FineRevenue revenue : revenues) {
                    createExcelRow(sheet, rowNum++, dataStyle,
                        dateFormat.format(revenue.date), String.valueOf(revenue.totalFines),
                        String.format("%.2f", revenue.totalAmount), String.format("%.2f", revenue.collectedAmount),
                        String.format("%.2f", revenue.pendingAmount), String.format("%.2f", revenue.waivedAmount),
                        String.format("%.2f", revenue.avgFineAmount));
                }
                break;

            case "categories":
                List<ReportDAO.CategoryStat> categoryStats = dao.getCategoryStatistics();

                createExcelRow(sheet, rowNum++, headerStyle, "Category ID", "Category Name", "Total Books",
                              "Available Copies", "Total Borrows", "Borrows Last Month");

                for (ReportDAO.CategoryStat stat : categoryStats) {
                    createExcelRow(sheet, rowNum++, dataStyle,
                        String.valueOf(stat.categoryId), stat.categoryName, String.valueOf(stat.totalBooks),
                        String.valueOf(stat.availableCopies), String.valueOf(stat.totalBorrows),
                        String.valueOf(stat.borrowsLastMonth));
                }
                break;

            case "overdue-books":
                List<ReportDAO.OverdueBookDetail> overdueBooks = dao.getOverdueBooks();

                createExcelRow(sheet, rowNum++, headerStyle, "Transaction ID", "Member Name", "Email", "Phone",
                              "Book Title", "ISBN", "Copy Number", "Borrow Date", "Due Date",
                              "Days Overdue", "Calculated Fine", "Fine Status");

                for (ReportDAO.OverdueBookDetail detail : overdueBooks) {
                    createExcelRow(sheet, rowNum++, dataStyle,
                        String.valueOf(detail.transactionId), detail.memberName, detail.email, detail.phone,
                        detail.bookTitle, detail.isbn, detail.copyNumber,
                        dateFormat.format(detail.borrowDate), dateFormat.format(detail.dueDate),
                        String.valueOf(detail.daysOverdue), String.format("%.2f", detail.calculatedFine),
                        detail.fineStatus);
                }
                break;
        }

        // Auto-size columns
        for (int i = 0; i < sheet.getRow(0).getLastCellNum(); i++) {
            sheet.autoSizeColumn(i);
        }

        // Write to output stream
        OutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        workbook.close();
        outputStream.close();
    }

    private void createExcelRow(Sheet sheet, int rowNum, CellStyle style, String... values) {
        Row row = sheet.createRow(rowNum);
        for (int i = 0; i < values.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(values[i] != null ? values[i] : "");
            cell.setCellStyle(style);
        }
    }

    private void exportToPDF(HttpServletRequest request, HttpServletResponse response,
                            ReportDAO dao, String reportType) throws SQLException, IOException {
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "attachment; filename=\"" + reportType + "_report.pdf\"");

        try {
            Document document = new Document(PageSize.A4.rotate()); // Landscape for wider tables
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Add title
            com.itextpdf.text.Font titleFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 18, com.itextpdf.text.Font.BOLD, BaseColor.BLACK);
            com.itextpdf.text.Font headerFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 12, com.itextpdf.text.Font.BOLD, BaseColor.WHITE);
            com.itextpdf.text.Font dataFont = new com.itextpdf.text.Font(com.itextpdf.text.Font.FontFamily.HELVETICA, 10, com.itextpdf.text.Font.NORMAL, BaseColor.BLACK);
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

            // Title
            Paragraph title = new Paragraph(getReportTitle(reportType), titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            // Generated date
            Paragraph date = new Paragraph("Generated: " + dateFormat.format(new java.util.Date()), dataFont);
            date.setAlignment(Element.ALIGN_RIGHT);
            date.setSpacingAfter(15);
            document.add(date);

            PdfPTable table;

            switch (reportType) {
                case "dashboard":
                    ReportDAO.DashboardStats stats = dao.getDashboardStatistics();
                    table = new PdfPTable(2);
                    table.setWidthPercentage(60);
                    addPdfHeaderCell(table, headerFont, "Metric", "Value");
                    addPdfDataRow(table, dataFont, "Total Books", String.valueOf(stats.totalBooks));
                    addPdfDataRow(table, dataFont, "Available Copies", String.valueOf(stats.availableCopies));
                    addPdfDataRow(table, dataFont, "Total Members", String.valueOf(stats.totalMembers));
                    addPdfDataRow(table, dataFont, "Current Borrows", String.valueOf(stats.currentBorrows));
                    addPdfDataRow(table, dataFont, "Overdue Books", String.valueOf(stats.overdueBooks));
                    addPdfDataRow(table, dataFont, "Active Reservations", String.valueOf(stats.activeReservations));
                    addPdfDataRow(table, dataFont, "Total Unpaid Fines", "$" + String.format("%.2f", stats.totalUnpaidFines));
                    addPdfDataRow(table, dataFont, "Pending Renewal Requests", String.valueOf(stats.pendingRenewalRequests));
                    document.add(table);
                    break;

                case "popular-books":
                    int periodDays = getIntParameter(request, "period", 90);
                    int limit = getIntParameter(request, "limit", 20);
                    List<ReportDAO.PopularBook> books = dao.getPopularBooks(periodDays, limit);

                    table = new PdfPTable(9);
                    table.setWidthPercentage(100);
                    table.setWidths(new float[]{5, 20, 12, 12, 15, 10, 10, 10, 10});
                    addPdfHeaderCell(table, headerFont, "#", "Title", "ISBN", "Category", "Authors",
                                    "Borrows", "Last Month", "Reservations", "Avg Days");

                    int rank = 1;
                    for (ReportDAO.PopularBook book : books) {
                        addPdfDataRow(table, dataFont,
                            String.valueOf(rank++), truncate(book.title, 40),
                            truncate(book.isbn, 15), truncate(book.categoryName, 15),
                            truncate(book.authors, 25), String.valueOf(book.totalBorrows),
                            String.valueOf(book.borrowsLastMonth), String.valueOf(book.currentReservations),
                            String.format("%.1f", book.avgBorrowDuration));
                    }
                    document.add(table);
                    break;

                case "active-members":
                    periodDays = getIntParameter(request, "period", 90);
                    limit = getIntParameter(request, "limit", 20);
                    List<ReportDAO.ActiveMember> members = dao.getMostActiveMembers(periodDays, limit);

                    table = new PdfPTable(9);
                    table.setWidthPercentage(100);
                    table.setWidths(new float[]{5, 18, 20, 12, 12, 10, 10, 10, 10});
                    addPdfHeaderCell(table, headerFont, "#", "Name", "Email", "Phone",
                                    "Type", "Borrows", "Returned", "Overdue", "Fines");

                    rank = 1;
                    for (ReportDAO.ActiveMember member : members) {
                        addPdfDataRow(table, dataFont,
                            String.valueOf(rank++), truncate(member.fullName, 25),
                            truncate(member.email, 30), truncate(member.phone, 15),
                            member.membershipType, String.valueOf(member.totalBorrows),
                            String.valueOf(member.returnedCount), String.valueOf(member.overdueCount),
                            "$" + String.format("%.2f", member.totalFines));
                    }
                    document.add(table);
                    break;

                case "fine-revenue":
                    String startDateStr = request.getParameter("start_date");
                    String endDateStr = request.getParameter("end_date");
                    java.sql.Date startDate = startDateStr != null ?
                        java.sql.Date.valueOf(startDateStr) :
                        new java.sql.Date(System.currentTimeMillis() - 30L * 24 * 60 * 60 * 1000);
                    java.sql.Date endDate = endDateStr != null ?
                        java.sql.Date.valueOf(endDateStr) :
                        new java.sql.Date(System.currentTimeMillis());

                    List<ReportDAO.FineRevenue> revenues = dao.getFineRevenueReport(startDate, endDate);

                    table = new PdfPTable(7);
                    table.setWidthPercentage(100);
                    addPdfHeaderCell(table, headerFont, "Date", "Count", "Total",
                                    "Collected", "Pending", "Waived", "Avg");

                    for (ReportDAO.FineRevenue revenue : revenues) {
                        addPdfDataRow(table, dataFont,
                            dateFormat.format(revenue.date), String.valueOf(revenue.totalFines),
                            "$" + String.format("%.2f", revenue.totalAmount),
                            "$" + String.format("%.2f", revenue.collectedAmount),
                            "$" + String.format("%.2f", revenue.pendingAmount),
                            "$" + String.format("%.2f", revenue.waivedAmount),
                            "$" + String.format("%.2f", revenue.avgFineAmount));
                    }
                    document.add(table);
                    break;

                case "categories":
                    List<ReportDAO.CategoryStat> categoryStats = dao.getCategoryStatistics();

                    table = new PdfPTable(6);
                    table.setWidthPercentage(100);
                    addPdfHeaderCell(table, headerFont, "ID", "Category Name",
                                    "Total Books", "Available", "Total Borrows", "Last Month");

                    for (ReportDAO.CategoryStat stat : categoryStats) {
                        addPdfDataRow(table, dataFont,
                            String.valueOf(stat.categoryId), truncate(stat.categoryName, 30),
                            String.valueOf(stat.totalBooks), String.valueOf(stat.availableCopies),
                            String.valueOf(stat.totalBorrows), String.valueOf(stat.borrowsLastMonth));
                    }
                    document.add(table);
                    break;

                case "overdue-books":
                    List<ReportDAO.OverdueBookDetail> overdueBooks = dao.getOverdueBooks();

                    table = new PdfPTable(8);
                    table.setWidthPercentage(100);
                    table.setWidths(new float[]{15, 15, 20, 12, 10, 10, 8, 10});
                    addPdfHeaderCell(table, headerFont, "Member", "Book Title", "Email",
                                    "Borrow Date", "Due Date", "Days Late", "Fine", "Status");

                    for (ReportDAO.OverdueBookDetail detail : overdueBooks) {
                        addPdfDataRow(table, dataFont,
                            truncate(detail.memberName, 20), truncate(detail.bookTitle, 30),
                            truncate(detail.email, 25), dateFormat.format(detail.borrowDate),
                            dateFormat.format(detail.dueDate), String.valueOf(detail.daysOverdue),
                            "$" + String.format("%.2f", detail.calculatedFine),
                            truncate(detail.fineStatus, 10));
                    }
                    document.add(table);
                    break;
            }

            document.close();
        } catch (DocumentException e) {
            throw new IOException("Error generating PDF: " + e.getMessage(), e);
        }
    }

    private String getReportTitle(String reportType) {
        switch (reportType) {
            case "dashboard": return "Dashboard Statistics Report";
            case "popular-books": return "Popular Books Report";
            case "active-members": return "Active Members Report";
            case "fine-revenue": return "Fine Revenue Report";
            case "categories": return "Category Statistics Report";
            case "overdue-books": return "Overdue Books Report";
            default: return "Library Report";
        }
    }

    private void addPdfHeaderCell(PdfPTable table, com.itextpdf.text.Font font, String... values) {
        for (String value : values) {
            PdfPCell cell = new PdfPCell(new Phrase(value, font));
            cell.setBackgroundColor(BaseColor.DARK_GRAY);
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            cell.setPadding(8);
            table.addCell(cell);
        }
    }

    private void addPdfDataRow(PdfPTable table, com.itextpdf.text.Font font, String... values) {
        for (String value : values) {
            PdfPCell cell = new PdfPCell(new Phrase(value != null ? value : "", font));
            cell.setPadding(5);
            cell.setHorizontalAlignment(Element.ALIGN_LEFT);
            table.addCell(cell);
        }
    }

    private String truncate(String str, int maxLength) {
        if (str == null) return "";
        return str.length() > maxLength ? str.substring(0, maxLength - 3) + "..." : str;
    }

    private String escapeCsv(String value) {
        if (value == null) {
            return "";
        }
        // Escape quotes by doubling them
        return value.replace("\"", "\"\"");
    }

    private int getIntParameter(HttpServletRequest request, String paramName, int defaultValue) {
        try {
            String param = request.getParameter(paramName);
            if (param != null && !param.isEmpty()) {
                return Integer.parseInt(param);
            }
        } catch (NumberFormatException e) {
            // Use default
        }
        return defaultValue;
    }
}
