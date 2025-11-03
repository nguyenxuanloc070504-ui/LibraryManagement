package model;

import java.sql.Date;

public class BorrowingTransaction {
    private Integer transactionId;
    private Integer copyId;
    private Integer userId;
    private Integer librarianId;
    private Date borrowDate;
    private Date dueDate;
    private Date returnDate;
    private Integer renewalCount;
    private String transactionStatus;
    private String notes;

    public Integer getTransactionId() { return transactionId; }
    public void setTransactionId(Integer transactionId) { this.transactionId = transactionId; }

    public Integer getCopyId() { return copyId; }
    public void setCopyId(Integer copyId) { this.copyId = copyId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getLibrarianId() { return librarianId; }
    public void setLibrarianId(Integer librarianId) { this.librarianId = librarianId; }

    public Date getBorrowDate() { return borrowDate; }
    public void setBorrowDate(Date borrowDate) { this.borrowDate = borrowDate; }

    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }

    public Date getReturnDate() { return returnDate; }
    public void setReturnDate(Date returnDate) { this.returnDate = returnDate; }

    public Integer getRenewalCount() { return renewalCount; }
    public void setRenewalCount(Integer renewalCount) { this.renewalCount = renewalCount; }

    public String getTransactionStatus() { return transactionStatus; }
    public void setTransactionStatus(String transactionStatus) { this.transactionStatus = transactionStatus; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}

