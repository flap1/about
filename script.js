/* No framework, build runtime, external requests, or analytics. */
(() => {
  'use strict';
  const root = document.documentElement;
  root.classList.add('js');
  const body = document.body;
  const standalone = body.hasAttribute('data-standalone');
  const email = 'shoichi.seto@syntopic.io';
  const pageNames = {home:'Shoichi Seto — Engineer / Researcher / Founder', research:'Research — Shoichi Seto', work:'Work — Shoichi Seto', notes:'Notes — Shoichi Seto', about:'About — Shoichi Seto', hobbies:'Off hours — Shoichi Seto'};
  let language = 'en';
  let toastTimeout;

  // Storage is optional: file://, private browsing and restricted contexts still work.
  try { if (localStorage.getItem('seto-language') === 'ja') language = 'ja'; } catch (_) {}

  function setLanguage(next, persist = false) {
    language = next === 'ja' ? 'ja' : 'en';
    root.lang = language;
    root.dataset.lang = language;
    document.querySelectorAll('[data-en][data-ja]').forEach(el => {
      el.textContent = el.getAttribute(`data-${language}`) || '';
    });
    document.querySelectorAll('[data-aria-en][data-aria-ja]').forEach(el => {
      el.setAttribute('aria-label', el.getAttribute(`data-aria-${language}`) || '');
    });
    document.querySelectorAll('[data-language]').forEach(button => {
      button.textContent = language === 'en' ? '日本語' : 'English';
      button.setAttribute('aria-label', language === 'en' ? '日本語に切り替える' : 'Switch to English');
      button.lang = language === 'en' ? 'ja' : 'en';
    });
    if (persist) { try { localStorage.setItem('seto-language', language); } catch (_) {} }
  }
  setLanguage(language);
  document.querySelectorAll('[data-language]').forEach(button => {
    button.addEventListener('click', () => setLanguage(language === 'en' ? 'ja' : 'en', true));
  });

  function announce(message) {
    const toast = document.querySelector('[data-toast]');
    if (!toast) return;
    clearTimeout(toastTimeout);
    toast.textContent = message;
    toast.classList.add('is-visible');
    toastTimeout = setTimeout(() => { toast.classList.remove('is-visible'); }, 3200);
  }

  function updateClock() {
    try {
      const now = new Date();
      const time = new Intl.DateTimeFormat('en-GB', {
        timeZone:'Asia/Tokyo', hour:'2-digit', minute:'2-digit', hour12:false
      }).format(now);
      document.querySelectorAll('[data-tokyo-time]').forEach(el => {
        el.textContent = time;
        el.dateTime = now.toISOString();
      });
    } catch (_) {
      document.querySelectorAll('[data-tokyo-time]').forEach(el => { el.hidden = true; });
    }
  }
  updateClock();
  setInterval(updateClock, 60000);
  document.addEventListener('visibilitychange', () => { if (!document.hidden) updateClock(); });

  async function copyEmail() {
    let copied = false;
    if (navigator.clipboard?.writeText && window.isSecureContext) {
      try { await navigator.clipboard.writeText(email); copied = true; } catch (_) {}
    }
    if (!copied) {
      const previous = document.activeElement;
      const field = document.createElement('textarea');
      field.value = email;
      field.setAttribute('readonly', '');
      field.style.cssText = 'position:fixed;left:-9999px;top:0;opacity:0';
      document.body.appendChild(field);
      field.select();
      try { copied = document.execCommand('copy'); } catch (_) {}
      field.remove();
      if (previous instanceof HTMLElement) previous.focus({preventScroll:true});
    }
    announce(copied
      ? (language === 'ja' ? 'メールアドレスをコピーしました。' : 'Email address copied.')
      : (language === 'ja' ? 'コピーできませんでした。表示中のメールアドレスを選択してください。' : 'Copy was unavailable. Please select the email address.'));
  }
  document.querySelectorAll('[data-copy-email]').forEach(button => button.addEventListener('click', copyEmail));

  document.querySelector('.skip-link')?.addEventListener('click', event => {
    event.preventDefault();
    const main = document.getElementById('content');
    main?.focus({preventScroll:true});
    main?.scrollIntoView({block:'start', behavior:'instant'});
  });

  function markNavigation(page) {
    document.querySelectorAll('[data-nav]').forEach(a => {
      if (a.dataset.nav === page) a.setAttribute('aria-current', 'page');
      else a.removeAttribute('aria-current');
    });
  }

  // The editable version uses normal HTML pages. Only the portable preview needs a router.
  if (standalone) {
    function showRoute(initial = false) {
      const raw = location.hash.slice(1) || 'home';
      const [candidate = 'home', anchor = ''] = raw === 'space' ? ['work', 'space'] : raw.split('/');
      const page = Object.prototype.hasOwnProperty.call(pageNames, candidate) ? candidate : 'home';
      if (page !== candidate) history.replaceState(null, '', '#home');
      document.querySelectorAll('[data-route]').forEach(section => {
        const active = section.dataset.route === page;
        section.hidden = !active;
        section.classList.toggle('is-current', active);
      });
      body.dataset.page = page;
      document.title = pageNames[page];
      markNavigation(page);
      const section = document.querySelector(`[data-route="${page}"]`);
      const target = anchor ? document.getElementById(anchor) : null;
      if (target && section?.contains(target)) {
        if (target instanceof HTMLDetailsElement) target.open = true;
        target.scrollIntoView({block:'start', behavior:'instant'});
        if (!initial) target.querySelector('summary')?.focus({preventScroll:true});
      } else {
        window.scrollTo({top:0, left:0, behavior:'instant'});
      }
      if (!initial && !(target && section?.contains(target))) {
        const heading = document.querySelector(`[data-route="${page}"] h1`);
        heading?.focus({preventScroll:true});
      }
    }
    window.addEventListener('hashchange', () => showRoute(false));
    showRoute(true);
  } else {
    markNavigation(body.dataset.page || 'home');
  }

  // Restore details to their latest state on history navigation; the browser handles focus.
  window.addEventListener('pageshow', updateClock);
  window.addEventListener('pagehide', () => {
    clearTimeout(toastTimeout);
    // The clock is cheap and remains valid through a BFCache restore.
  });
})();
