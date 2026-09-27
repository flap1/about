---
name: review
description: Review code quality, accessibility, performance, and security. Use when the user says "review", "check quality", "audit", or before creating a PR.
---

# Code Review

Perform a thorough review of recent changes.

## Review Checklist

### Performance
- Images are compressed and served as webp/svg
- CloudFront serves Brotli/gzip (`content-encoding` header) and long cache for `assets/`
- No blocking third-party scripts, no external font/CDN loads

### Accessibility (WCAG 2.2 AA)
- All images have meaningful alt text (or `alt=""` for decorative)
- Heading hierarchy is correct (no skipped levels)
- Focus styles are visible; nothing traps focus
- `prefers-reduced-motion` respected for animations
- `lang` attribute set correctly (en/ja) via `data-lang`
- `aria-current="page"` on the active nav link

### Security
- No inline `style=""` (CSP has no `unsafe-inline` for styles)
- If the inline bootstrap `<script>` changes, its CSP hash in `infra/main.tf` must be recomputed
- External links have `rel="noopener noreferrer"`
- No secrets, API keys, or credentials in any tracked file (`gitleaks dir .`)

### Content
- Both `data-en` and `data-ja` attributes updated together
- No spelling errors in visible text
- Internal links use the extensionless form (`about`, not `about.html`)
- No broken links

## Output

Report findings grouped by severity:
1. Blocking (must fix before merge)
2. Warning (should fix)
3. Suggestion (nice to have)
