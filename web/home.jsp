<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="dal.BookDAO" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in as member
    String userRole = (String) session.getAttribute("authRole");
    boolean isLoggedInMember = "Member".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Library Home - Discover Your Next Great Read</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="css/base/reset.css" />
    <link rel="stylesheet" href="css/base/typography.css" />
    <link rel="stylesheet" href="css/base/variables.css" />
    <link rel="stylesheet" href="css/components/button.css" />
    <link rel="stylesheet" href="css/components/card.css" />
    <link rel="stylesheet" href="css/components/form.css" />
    <link rel="stylesheet" href="css/layouts/grid.css" />
    <link rel="stylesheet" href="css/layouts/header.css" />
    <link rel="stylesheet" href="css/main.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="css/pages/home.css" />
</head>
<body class="home-page">
    <!-- Header only, no sidebar -->
    <% if (isLoggedInMember) { %>
    <jsp:include page="components/header-member.jsp">
        <jsp:param name="activeTab" value="home"/>
    </jsp:include>
    <% } else { %>
    <jsp:include page="components/header.jsp" />
    <% } %>

    <!-- Hero Section -->
    <section class="hero-section">
        <div class="hero-content">
            <h1 class="hero-title">
                <i class="fas fa-book-open"></i>
                Discover Your Next Great Read
            </h1>
            <p class="hero-subtitle">
                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser}">
                        Welcome back, ${sessionScope.currentUser.fullName}! Explore thousands of books and borrow with ease.
                    </c:when>
                    <c:otherwise>
                        Explore thousands of books, request to borrow online, and get notified for pickup.
                    </c:otherwise>
                </c:choose>
            </p>

            <!-- Search Bar -->
            <div class="hero-search">
                <div class="search-container">
                    <i class="fas fa-search search-icon"></i>
                    <input
                        id="home-search-input"
                        type="text"
                        class="search-input"
                        placeholder="Search by title, author, ISBN, or category..."
                    />
                    <button id="home-search-btn" class="search-btn">
                        <span>Search</span>
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
                <p class="search-hint">
                    <i class="fas fa-lightbulb"></i>
                    Try searching for "Java Programming", "Mystery", or your favorite author
                </p>
            </div>
        </div>
    </section>

    <!-- Quick Actions -->
    <c:if test="${not empty sessionScope.currentUser}">
        <section class="quick-actions-section">
            <div class="container">
                <div class="quick-actions-grid">
                    <a href="personal/current-borrowings" class="quick-action-card">
                        <div class="action-icon action-icon-primary">
                            <i class="fas fa-book-reader"></i>
                        </div>
                        <h3>My Borrowings</h3>
                        <p>View your borrowed books</p>
                        <span class="action-arrow"><i class="fas fa-arrow-right"></i></span>
                    </a>

                    <a href="books/my-reservations" class="quick-action-card">
                        <div class="action-icon action-icon-secondary">
                            <i class="fas fa-bookmark"></i>
                        </div>
                        <h3>My Reservations</h3>
                        <p>Track reserved books</p>
                        <span class="action-arrow"><i class="fas fa-arrow-right"></i></span>
                    </a>

                    <a href="personal/notifications" class="quick-action-card">
                        <div class="action-icon action-icon-tertiary">
                            <i class="fas fa-bell"></i>
                        </div>
                        <h3>Notifications</h3>
                        <p>Check your updates</p>
                        <span class="action-arrow"><i class="fas fa-arrow-right"></i></span>
                    </a>
                </div>
            </div>
        </section>
    </c:if>

    <!-- Featured Books Section -->
    <section class="featured-books-section">
        <div class="container">
            <div class="section-header">
                <h2>
                    <i class="fas fa-book"></i>
                    Featured Books
                </h2>
                <p>Discover popular and recently added books in our collection</p>
            </div>

            <c:choose>
                <c:when test="${not empty featuredBooks}">
                    <div class="books-grid">
                        <c:forEach items="${featuredBooks}" var="book">
                            <a href="books/detail?id=${book.bookId}" class="book-card">
                                <div class="book-cover">
                                    <c:choose>
                                        <c:when test="${not empty book.coverImage}">
                                            <img src="${book.coverImage}" alt="${book.title}" />
                                        </c:when>
                                        <c:otherwise>
                                            <div class="book-cover-placeholder">
                                                <i class="fas fa-book"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <c:if test="${book.availableCopies > 0}">
                                        <span class="availability-badge available">
                                            <i class="fas fa-check-circle"></i> Available
                                        </span>
                                    </c:if>
                                    <c:if test="${book.availableCopies == 0}">
                                        <span class="availability-badge unavailable">
                                            <i class="fas fa-times-circle"></i> Unavailable
                                        </span>
                                    </c:if>
                                </div>

                                <div class="book-info">
                                    <h3 class="book-title">${book.title}</h3>
                                    <p class="book-authors">
                                        <i class="fas fa-user-edit"></i>
                                        <c:choose>
                                            <c:when test="${not empty book.authorNames}">
                                                <c:forEach items="${book.authorNames}" var="author" varStatus="status">
                                                    ${author}<c:if test="${!status.last}">, </c:if>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>Unknown Author</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <c:if test="${not empty book.categoryName}">
                                        <p class="book-category">
                                            <i class="fas fa-tag"></i>
                                            ${book.categoryName}
                                        </p>
                                    </c:if>
                                    <div class="book-meta">
                                        <span>
                                            <i class="fas fa-copy"></i>
                                            ${book.availableCopies}/${book.totalCopies} copies
                                        </span>
                                        <c:if test="${not empty book.publicationYear}">
                                            <span>
                                                <i class="fas fa-calendar"></i>
                                                ${book.publicationYear}
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>

                    <div class="section-footer">
                        <a href="books" class="btn-view-all">
                            View All Books
                            <i class="fas fa-arrow-right"></i>
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-book-open"></i>
                        <p>No books available at the moment. Check back soon!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works-section">
        <div class="container">
            <div class="section-header">
                <h2>
                    <i class="fas fa-question-circle"></i>
                    How It Works
                </h2>
                <p>Borrowing books is simple and convenient</p>
            </div>

            <div class="steps-grid">
                <div class="step-card">
                    <div class="step-number">1</div>
                    <i class="fas fa-search step-icon"></i>
                    <h3>Search & Browse</h3>
                    <p>Find books by title, author, category, or ISBN in our extensive collection</p>
                </div>

                <div class="step-card">
                    <div class="step-number">2</div>
                    <i class="fas fa-hand-pointer step-icon"></i>
                    <h3>Request to Borrow</h3>
                    <p>Click on a book and submit a borrow request online in seconds</p>
                </div>

                <div class="step-card">
                    <div class="step-number">3</div>
                    <i class="fas fa-check-circle step-icon"></i>
                    <h3>Get Approved</h3>
                    <p>A librarian will review and approve your request promptly</p>
                </div>

                <div class="step-card">
                    <div class="step-number">4</div>
                    <i class="fas fa-book-reader step-icon"></i>
                    <h3>Pick Up & Enjoy</h3>
                    <p>Receive a notification and pick up your book at the library</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer CTA -->
    <section class="cta-section">
        <div class="container">
            <div class="cta-content">
                <h2>Ready to Start Reading?</h2>
                <p>Join our library community and explore thousands of books today</p>
                <div class="cta-buttons">
                    <a href="books" class="btn-cta primary">
                        <i class="fas fa-book"></i>
                        Browse Books
                    </a>
                    <c:if test="${empty sessionScope.currentUser}">
                        <a href="login" class="btn-cta secondary">
                            <i class="fas fa-sign-in-alt"></i>
                            Sign In
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </section>

    <script src="js/utils/validate.js"></script>
    <script src="js/utils/format.js"></script>
    <script src="js/pages/home.js"></script>
</body>
</html>


