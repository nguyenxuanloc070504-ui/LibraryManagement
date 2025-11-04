(() => {
  const searchInput = document.getElementById('home-search-input');
  const searchBtn = document.getElementById('home-search-btn');

  // Search functionality
  function goSearch() {
    const q = (searchInput?.value || '').trim();
    const url = q ? `books?query=${encodeURIComponent(q)}` : 'books';
    window.location.href = url;
  }

  searchBtn?.addEventListener('click', goSearch);
  searchInput?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      goSearch();
    }
  });

  // Add smooth scroll behavior for internal links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  // Add hover effects to book cards
  const bookCards = document.querySelectorAll('.book-card');
  bookCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
      this.style.transform = 'translateY(-8px)';
    });
    card.addEventListener('mouseleave', function() {
      this.style.transform = 'translateY(0)';
    });
  });

  // Add animation on scroll
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  // Observe sections for animation
  document.querySelectorAll('.quick-action-card, .book-card, .step-card').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
    observer.observe(el);
  });

  // Add CSS for animation
  const style = document.createElement('style');
  style.textContent = `
    .animate-in {
      opacity: 1 !important;
      transform: translateY(0) !important;
    }
  `;
  document.head.appendChild(style);

  // Focus search input on page load for better UX
  if (searchInput && window.innerWidth > 768) {
    setTimeout(() => {
      searchInput.focus();
    }, 500);
  }
})();


