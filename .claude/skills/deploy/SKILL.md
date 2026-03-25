---
name: deploy
description: Build and deploy the site to AWS S3 + CloudFront. Use when the user says "deploy", "publish", "ship it", or "push to production".
---

# Deploy to Production

## Pre-deploy Checks

```bash
git status
pnpm validate
```

Ensure:
- Working tree is clean (all changes committed)
- On `main` branch (or confirm deployment from current branch)
- `pnpm validate` passes (type check + lint + build)

## Build

```bash
pnpm build
```

## Deploy (S3 + CloudFront)

CRITICAL: ALWAYS use `--profile flap1`. NEVER omit it. NEVER use the default profile.

First, retrieve the resource identifiers from Terraform:

```bash
S3_BUCKET=$(terraform -chdir=infra output -raw s3_bucket_name)
CF_DIST_ID=$(terraform -chdir=infra output -raw cloudfront_distribution_id)
```

Then deploy:

```bash
aws s3 sync dist/ "s3://${S3_BUCKET}" --delete --profile flap1
aws cloudfront create-invalidation --distribution-id "${CF_DIST_ID}" --paths "/*" --profile flap1
```

## Post-deploy

- Verify the site loads at the production URL
- Check key pages (home, blog, projects, 404)

## Anti-patterns

- NEVER run any `aws` command without `--profile flap1`
- Never deploy uncommitted changes
- Never deploy without running `pnpm validate` first
- Never deploy from a feature branch without asking the user
