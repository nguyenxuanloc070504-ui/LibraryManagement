package model;

import java.sql.Date;

public class Membership {
    private Integer membershipId;
    private Integer userId;
    private String membershipNumber;
    private String membershipType; // basic | premium | student
    private Date issueDate;
    private Date expiryDate;
    private Integer maxBooksAllowed;
    private Boolean isActive;

    public Integer getMembershipId() { return membershipId; }
    public void setMembershipId(Integer membershipId) { this.membershipId = membershipId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getMembershipNumber() { return membershipNumber; }
    public void setMembershipNumber(String membershipNumber) { this.membershipNumber = membershipNumber; }

    public String getMembershipType() { return membershipType; }
    public void setMembershipType(String membershipType) { this.membershipType = membershipType; }

    public Date getIssueDate() { return issueDate; }
    public void setIssueDate(Date issueDate) { this.issueDate = issueDate; }

    public Date getExpiryDate() { return expiryDate; }
    public void setExpiryDate(Date expiryDate) { this.expiryDate = expiryDate; }

    public Integer getMaxBooksAllowed() { return maxBooksAllowed; }
    public void setMaxBooksAllowed(Integer maxBooksAllowed) { this.maxBooksAllowed = maxBooksAllowed; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
}


