export const languages = {
  en: "English",
  ja: "Japanese",
} as const;

export type Lang = keyof typeof languages;

export const defaultLang: Lang = "en";

export const ui = {
  en: {
    "site.title": "flap1",
    "site.description": "Developer portfolio and blog",
    "nav.home": "Home",
    "nav.about": "About",
    "nav.projects": "Projects",
    "nav.blog": "Blog",
    "nav.notes": "Notes",
    "nav.uses": "Uses",
    "nav.now": "Now",
    "nav.contact": "Contact",
    "footer.copyright": "All rights reserved.",
    "blog.readingTime": "min read",
    "blog.publishedOn": "Published on",
    "blog.updatedOn": "Updated on",
    "blog.tags": "Tags",
    "blog.draft": "Draft",
    "search.placeholder": "Search...",
    "error.notFound": "Page not found",
    "error.notFoundDescription": "The page you are looking for does not exist.",
    "error.backHome": "Back to home",
  },
  ja: {
    "site.title": "flap1",
    "site.description": "Developer portfolio and blog",
    "nav.home": "Home",
    "nav.about": "About",
    "nav.projects": "Projects",
    "nav.blog": "Blog",
    "nav.notes": "Notes",
    "nav.uses": "Uses",
    "nav.now": "Now",
    "nav.contact": "Contact",
    "footer.copyright": "All rights reserved.",
    "blog.readingTime": "min read",
    "blog.publishedOn": "Published on",
    "blog.updatedOn": "Updated on",
    "blog.tags": "Tags",
    "blog.draft": "Draft",
    "search.placeholder": "Search...",
    "error.notFound": "Page not found",
    "error.notFoundDescription": "The page you are looking for does not exist.",
    "error.backHome": "Back to home",
  },
} as const;

export function useTranslations(lang: Lang) {
  return function t(key: keyof (typeof ui)["en"]): string {
    return ui[lang][key] ?? ui[defaultLang][key];
  };
}

export function getLangFromUrl(url: URL): Lang {
  const [, lang] = url.pathname.split("/");
  if (lang !== undefined && lang in ui) return lang as Lang;
  return defaultLang;
}
