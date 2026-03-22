// Infinite scroll / load-more for mobile listings
// Uses IntersectionObserver to auto-trigger "Load More" when sentinel enters viewport.
// On desktop, standard pagy page links are shown instead.

(function() {
  function initInfiniteScroll() {
    var btn = document.getElementById('load-more-btn');
    var sentinel = document.getElementById('load-more-sentinel');
    if (!btn || !sentinel) return;

    // Only auto-trigger on mobile screens
    var isMobile = window.matchMedia('(max-width: 767px)').matches;
    if (!isMobile) return;

    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting && !btn.disabled && !btn.classList.contains('loading')) {
          triggerLoadMore(btn);
        }
      });
    }, { rootMargin: '300px' });

    observer.observe(sentinel);

    // Also handle manual button clicks
    btn.addEventListener('click', function(e) {
      // rails-ujs handles the AJAX request; just show loading state
      if (!btn.disabled && !btn.classList.contains('loading')) {
        setLoadingState(btn);
      }
    });

    // Reset loading state after rails-ujs completes the ajax request
    document.addEventListener('ajax:success', function() {
      // index.js.erb has already updated btn state, nothing extra needed
    });

    document.addEventListener('ajax:error', function() {
      btn.classList.remove('loading');
      btn.disabled = false;
      btn.textContent = 'Load More';
    });
  }

  function triggerLoadMore(btn) {
    setLoadingState(btn);
    // Fire the rails-ujs ajax request by dispatching a click
    btn.click();
  }

  function setLoadingState(btn) {
    btn.classList.add('loading');
    btn.disabled = true;
    btn.textContent = 'Loading\u2026';
  }

  // Init on first page load and after Turbolinks navigation
  document.addEventListener('turbolinks:load', initInfiniteScroll);
})();
