---
name: review
description: Review code quality, accessibility, performance, and design system compliance. Use when the user says "review", "check quality", "audit", or before creating a PR.
---

# Code Review

Perform a thorough review of recent changes.

## Review Checklist

### Type Safety
- [ ] No `any` types (strictest mode)
- [ ] Content collections have Zod schemas
- [ ] Props interfaces defined on all components
- [ ] `astro check` passes with 0 errors

### Performance
- [ ] Images use `<Image>` or `<Picture>` from astro:assets (not raw `<img>`)
- [ ] No unnecessary `client:load` (prefer `client:visible` or `client:idle`)
- [ ] CJK fonts use Google Fonts auto-slicing or subsetting
- [ ] No blocking third-party scripts
- [ ] Page weight under 500KB

### Accessibility (WCAG 2.2 AA)
- [ ] All images have meaningful alt text (or `alt=""` for decorative)
- [ ] Heading hierarchy is correct (no skipped levels)
- [ ] Focus styles are visible
- [ ] `prefers-reduced-motion` respected for animations
- [ ] Color contrast meets 4.5:1 for body text, 3:1 for large text
- [ ] `lang` attribute set correctly (en/ja)

### Design System
- [ ] Uses semantic color tokens (not raw hex/oklch values)
- [ ] Uses font-display / font-body / font-mono (not arbitrary font families)
- [ ] Consistent spacing using Tailwind utilities

### Security
- [ ] No `set:html` with unsanitized input
- [ ] External links have `rel="noopener noreferrer"`
- [ ] No secrets in `PUBLIC_*` env vars

### Content
- [ ] No spelling errors in visible text
- [ ] Links are not broken
- [ ] MDX frontmatter matches Zod schema

## Output

Report findings grouped by severity:
1. Blocking (must fix before merge)
2. Warning (should fix)
3. Suggestion (nice to have)
