package model;

import java.math.BigDecimal;
import java.sql.Date;

public class Fine {
    private Integer fineId;
    private Integer transactionId;
    private Integer userId;
    private BigDecimal fineAmount;
    private String fineReason;
    private Integer daysOverdue;
    private Date fineDate;
    private String paymentStatus;
    private Date paymentDate;
    private String paymentMethod;
    private Integer processedBy;
    private String notes;

    public Integer getFineId() { return fineId; }
    public void setFineId(Integer fineId) { this.fineId = fineId; }

    public Integer getTransactionId() { return transactionId; }
    public void setTransactionId(Integer transactionId) { this.transactionId = transactionId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public BigDecimal getFineAmount() { return fineAmount; }
    public void setFineAmount(BigDecimal fineAmount) { this.fineAmount = fineAmount; }

    public String getFineReason() { return fineReason; }
    public void setFineReason(String fineReason) { this.fineReason = fineReason; }

    public Integer getDaysOverdue() { return daysOverdue; }
    public void setDaysOverdue(Integer daysOverdue) { this.daysOverdue = daysOverdue; }

    public Date getFineDate() { return fineDate; }
    public void setFineDate(Date fineDate) { this.fineDate = fineDate; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Date getPaymentDate() { return paymentDate; }
    public void setPaymentDate(Date paymentDate) { this.paymentDate = paymentDate; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public Integer getProcessedBy() { return processedBy; }
    public void setProcessedBy(Integer processedBy) { this.processedBy = processedBy; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}

