(() => {
  const main = document.querySelector('main');
  if (main && !main.id) main.id = 'main-content';

  if (main && !document.querySelector('.skiplink')) {
    const skip = document.createElement('a');
    skip.className = 'skiplink';
    skip.href = '#main-content';
    skip.textContent = 'Skip to main content';
    document.body.prepend(skip);
  }

  const menu = document.querySelector('.menu');
  const links = document.querySelector('.navlinks');
  if (!menu || !links) return;

  if (!links.id) links.id = 'primary-navigation';
  menu.setAttribute('type', 'button');
  menu.setAttribute('aria-controls', links.id);
  menu.setAttribute('aria-expanded', 'false');
  menu.setAttribute('aria-label', 'Open primary navigation');

  const isMobile = () => window.matchMedia('(max-width: 980px)').matches;

  const closeMenu = ({ restoreFocus = false } = {}) => {
    links.classList.remove('navlinks-open');
    menu.setAttribute('aria-expanded', 'false');
    menu.setAttribute('aria-label', 'Open primary navigation');
    if (restoreFocus) menu.focus();
  };

  const openMenu = () => {
    links.classList.add('navlinks-open');
    menu.setAttribute('aria-expanded', 'true');
    menu.setAttribute('aria-label', 'Close primary navigation');
    const first = links.querySelector('a');
    if (first) first.focus({ preventScroll: true });
  };

  menu.addEventListener('click', () => {
    const open = menu.getAttribute('aria-expanded') === 'true';
    open ? closeMenu() : openMenu();
  });

  links.addEventListener('click', event => {
    if (isMobile() && event.target.closest('a')) closeMenu();
  });

  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && menu.getAttribute('aria-expanded') === 'true') {
      closeMenu({ restoreFocus: true });
    }
  });

  document.addEventListener('click', event => {
    if (!isMobile() || menu.getAttribute('aria-expanded') !== 'true') return;
    if (!links.contains(event.target) && !menu.contains(event.target)) closeMenu();
  });

  window.addEventListener('resize', () => {
    if (!isMobile()) closeMenu();
  });
})();
