<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Get page title and subtitle from request parameters
    String pageTitle = request.getParameter("pageTitle") != null ? request.getParameter("pageTitle") : "";
    String pageSubtitle = request.getParameter("pageSubtitle") != null ? request.getParameter("pageSubtitle") : "";
    String contextPath = request.getContextPath();

    // Get user info from session
    String userName = (String) session.getAttribute("authFullName");
    if (userName == null || userName.isEmpty()) {
        userName = (String) session.getAttribute("authUsername");
    }
    if (userName == null || userName.isEmpty()) {
        userName = "Librarian";
    }

    // Get user role from session
    String userRole = (String) session.getAttribute("authRole");
    if (userRole == null || userRole.isEmpty()) {
        userRole = "User";
    }

    // Resolve profile photo from session if available
    String profilePhoto = (String) session.getAttribute("authProfilePhoto");

    // Compute initials for default avatar
    String initials = "";
    try {
        String[] parts = userName.trim().split("\\s+");
        for (int i = 0; i < parts.length && i < 2; i++) {
            if (!parts[i].isEmpty()) {
                initials += Character.toUpperCase(parts[i].charAt(0));
            }
        }
        if (initials.isEmpty()) initials = userName.substring(0, 1).toUpperCase();
    } catch (Exception ignored) { initials = "U"; }
%>
<header class="content-header">
    <div class="header-left<%= "Librarian".equalsIgnoreCase(userRole) ? " header-left--stack" : "" %>">
        <% if (pageTitle != null && !pageTitle.isEmpty()) { %>
            <h1 class="page-title"><%= pageTitle %></h1>
            <% if (pageSubtitle != null && !pageSubtitle.isEmpty()) { %>
                <p class="page-subtitle"><%= pageSubtitle %></p>
            <% } %>
        <% } else { %>
            <div class="system-name">
                <i class="fas fa-book-open" style="margin-right: 8px; color: var(--color-primary);"></i>
                <span>Library Management System</span>
            </div>
        <% } %>
    </div>
    <div class="header-actions">
        <% if ("Member".equalsIgnoreCase(userRole)) { %>
        <div id="notif-container" style="position:relative; margin-right:.5rem;">
            <button id="notif-bell" class="btn-icon" title="Notifications" type="button">
                <i class="fa-regular fa-bell"></i>
            </button>
            <div id="notif-panel" class="card" style="display:none; position:absolute; right:0; top:2.75rem; width:22rem; max-height:24rem; overflow:auto; z-index:1001;">
                <div style="padding:.75rem; border-bottom:1px solid var(--color-border); font-weight:700;">Notifications</div>
                <div id="notif-list" style="padding:.5rem 0;"></div>
                <div style="padding:.5rem .75rem; border-top:1px solid var(--color-border); text-align:right;">
                    <a href="<%= contextPath %>/notifications" class="btn-secondary inline-btn" style="text-decoration:none;">View all</a>
                </div>
            </div>
        </div>
        <% } %>
        <div class="user-dropdown">
            <button class="user-trigger" type="button" aria-haspopup="true" aria-expanded="false">
                <% if (profilePhoto != null && !profilePhoto.isEmpty()) { %>
                    <img src="<%= contextPath + profilePhoto %>" alt="Avatar" class="user-avatar" style="width:2.25rem;height:2.25rem;border-radius:9999px;object-fit:cover;" />
                <% } else { %>
                    <div class="user-avatar"><%= initials %></div>
                <% } %>
                <div class="user-info">
                    <div class="user-name"><%= userName %></div>
                    <div class="user-role"><%= userRole %></div>
                </div>
                <i class="fa-solid fa-chevron-down" style="font-size:.85rem;color:#6b7280;margin-left:.25rem;"></i>
            </button>
            <div class="user-menu" role="menu">
                <a href="<%= contextPath %>/member/profile" class="menu-item" role="menuitem">
                    <i class="fa-solid fa-user"></i>
                    <span>Profile</span>
                </a>
                <a href="<%= contextPath %>/logout" class="menu-item danger" role="menuitem">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Logout</span>
                </a>
            </div>
        </div>
    </div>
</header>
<script src="<%= contextPath %>/js/components/dropdown.js"></script>
<% if ("Member".equalsIgnoreCase(userRole)) { %>
<script>
(function notificationsUI(){
  var bell = document.getElementById('notif-bell');
  var panel = document.getElementById('notif-panel');
  var list = document.getElementById('notif-list');
  function render(items){
    if (!list) return;
    if (!items || items.length === 0){
      list.innerHTML = '<div style="padding:.75rem; color:var(--color-text-light); text-align:center;">No notifications</div>';
      return;
    }
    list.innerHTML = items.map(function(n){
      var unreadDot = !n.isRead ? '<span style="width:.5rem;height:.5rem;background:var(--color-primary);display:inline-block;border-radius:9999px;margin-right:.5rem;"></span>' : '';
      var actionBtn = !n.isRead ? '<button class="btn-secondary inline-btn" data-mark-id="'+ n.id +'" style="margin-left:auto;">Mark</button>' : '';
      return '<div style="padding:.5rem .75rem; display:flex; align-items:flex-start; gap:.5rem;">'
        + unreadDot
        + '<div style="flex:1;">'
        + '<div style="font-weight:600;">' + escapeHtml(n.title) + '</div>'
        + '<div style="font-size:.85rem;color:var(--color-text-light);margin-top:.125rem;">' + escapeHtml(n.message) + '</div>'
        + '<div style="font-size:.75rem;color:var(--color-text-muted);margin-top:.125rem;">' + escapeHtml(n.sentDate) + '</div>'
        + '</div>'
        + actionBtn
        + '</div>'; 
    }).join('');
  }
  function fetchLatest(){
    fetch('<%= contextPath %>/api/notifications/latest', { credentials: 'same-origin' })
      .then(function(r){ return r.json(); })
      .then(function(data){ render(data); })
      .catch(function(){ render([]); });
  }
  function toggle(){
    if (!panel) return;
    var open = panel.style.display === 'block';
    if (open){ panel.style.display = 'none'; }
    else { fetchLatest(); panel.style.display = 'block'; }
  }
  function outside(e){
    if (!panel) return;
    if (!panel.contains(e.target) && !bell.contains(e.target)){
      panel.style.display = 'none';
    }
  }
  function escapeHtml(s){ return (s||'').replace(/[&<>"]+/g, function(c){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]); }); }
  if (bell){
    bell.addEventListener('click', toggle);
    document.addEventListener('click', outside);
    // delegate mark read clicks inside panel
    if (panel){
      panel.addEventListener('click', function(e){
        var btn = e.target.closest('[data-mark-id]');
        if (!btn) return;
        var id = btn.getAttribute('data-mark-id');
        fetch('<%= contextPath %>/notifications/mark-read', {
          method: 'POST', credentials: 'same-origin',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: 'id=' + encodeURIComponent(id)
        }).then(function(){ fetchLatest(); }).catch(function(){});
      });
    }
  }
})();
</script>
<% } %>

