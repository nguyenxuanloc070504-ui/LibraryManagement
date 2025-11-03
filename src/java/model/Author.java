package model;

public class Author {
    private Integer authorId;
    private String authorName;
    private String biography;
    private String country;

    public Integer getAuthorId() { return authorId; }
    public void setAuthorId(Integer authorId) { this.authorId = authorId; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public String getBiography() { return biography; }
    public void setBiography(String biography) { this.biography = biography; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
}

