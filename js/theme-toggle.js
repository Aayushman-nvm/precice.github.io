(function () {
  const KEY  = 'precice-theme';
  const root = document.documentElement;

  function preferred() {
    const s = localStorage.getItem(KEY);
    if (s === 'light' || s === 'dark') return s;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  }

  function apply(theme) {
    root.setAttribute('data-theme', theme);
    localStorage.setItem(KEY, theme);
    const btn  = document.getElementById('theme-toggle');
    if (!btn) return;
    const icon = btn.querySelector('i');
    if (icon) icon.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
    btn.setAttribute('aria-label', theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode');
  }

  // Immediate apply — runs synchronously before first paint
  apply(preferred());

  // Public API for the toggle button
  window.toggleTheme = function () {
    apply(root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
  };

  // Respond to OS changes only when user hasn't explicitly chosen
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function (e) {
    if (!localStorage.getItem(KEY)) apply(e.matches ? 'dark' : 'light');
  });
}());