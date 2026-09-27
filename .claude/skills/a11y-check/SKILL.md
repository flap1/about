---
name: a11y-check
description: Run accessibility audit on the site. Use when the user says "check accessibility", "a11y audit", "WCAG check", or "accessibility review".
---

# Accessibility Audit

## Quick Check

```bash
python3 -m http.server 8080 &
sleep 1
npx pa11y http://localhost:8080/
npx pa11y http://localhost:8080/about
npx pa11y http://localhost:8080/research
```

## Manual Review Points

- Skip-to-content link exists and works
- Tab order is logical
- All interactive elements are keyboard-accessible
- Focus is never trapped
- `aria-current="page"` on active nav link
- `<html lang="en">` (or `lang="ja"` for Japanese pages)
- No auto-playing media without user control
- Zoom to 200% works without horizontal scroll

## Report Format

Group by:
1. Critical (blocks users)
2. Serious (significant barrier)
3. Moderate (inconvenience)
4. Minor (best practice)
