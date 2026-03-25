// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import react from '@astrojs/react';
import expressiveCode from 'astro-expressive-code';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import pagefind from 'astro-pagefind';
import icon from 'astro-icon';

import rehypeSlug from 'rehype-slug';
import rehypeAutolinkHeadings from 'rehype-autolink-headings';
import rehypeExternalLinks from 'rehype-external-links';
import remarkSmartypants from 'remark-smartypants';
import remarkDirective from 'remark-directive';
import { remarkReadingTime } from './src/plugins/remark-reading-time.mjs';

export default defineConfig({
  site: 'https://flap1.com',
  output: 'static',
  trailingSlash: 'ignore',

  prefetch: {
    prefetchAll: false,
    defaultStrategy: 'hover',
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'ja'],
    routing: {
      prefixDefaultLocale: false,
    },
    fallback: {
      ja: 'en',
    },
  },

  integrations: [
    react(),
    expressiveCode({
      themes: ['github-dark', 'github-light'],
      styleOverrides: {
        borderRadius: '0.5rem',
      },
    }),
    mdx(),
    sitemap({
      i18n: {
        defaultLocale: 'en',
        locales: { en: 'en-US', ja: 'ja-JP' },
      },
    }),
    pagefind(),
    icon(),
  ],

  markdown: {
    remarkPlugins: [
      /** @type {any} */ (remarkSmartypants),
      remarkDirective,
      remarkReadingTime,
    ],
    rehypePlugins: [
      rehypeSlug,
      [rehypeAutolinkHeadings, { behavior: 'wrap' }],
      [rehypeExternalLinks, { target: '_blank', rel: ['noopener', 'noreferrer'] }],
    ],
  },

  vite: {
    plugins: [tailwindcss()],
  },

  server: {
    port: 4321,
  },

  build: {
    format: 'directory',
    inlineStylesheets: 'auto',
  },
});