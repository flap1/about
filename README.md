# shoichiseto.com

Static site. No build step, just open `index.html`.

## Structure

- `index.html` / `research.html` / `work.html` / `notes.html` / `about.html` / `hobbies.html`
- `style.css`, `script.js` (language toggle, Tokyo clock, email copy)
- `assets/` — images and SVGs
- `tools/make_portable.py` — bundles the site into a single HTML file (`README.md` / `tools/` / `tests/` are excluded from deploys)

## Deploy

`shoichiseto.com` is canonical; `flap1.com` 301-redirects to it. Hosted on AWS (S3 + CloudFront), managed from the `about` repo's `infra/`. URLs are extensionless (`/about`, not `/about.html`).

```sh
aws s3 sync . "s3://<content_bucket_name>" --exclude "README.md" --exclude "tools/*" --exclude "tests/*" --profile flap1
aws cloudfront create-invalidation --distribution-id "<cloudfront_distribution_id>" --paths "/*" --profile flap1
```

Get the bucket name and distribution ID with `terraform -chdir=infra output`.

## Editing

Copy lives in each HTML file's `data-en` / `data-ja` attributes. Colors are CSS variables at the top of `style.css`. If the inline bootstrap script changes, recompute its CSP hash (`infra/main.tf`).

No analytics, cookies, or tracking. Only the language preference is stored in `localStorage`.
