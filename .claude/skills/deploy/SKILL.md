---
name: deploy
description: Build and deploy the site to AWS S3 + CloudFront. Use when the user says "deploy", "publish", "ship it", or "push to production".
---

# Deploy to Production

The site is static (no build step). Deploy is a direct sync.

## Pre-deploy Checks

```bash
git status
```

Ensure the working tree is clean (all changes committed), and confirm deployment from a non-`main` branch unless asked otherwise.

## Deploy (S3 + CloudFront)

CRITICAL: ALWAYS use `--profile flap1`. NEVER omit it. NEVER use the default profile.

Retrieve the resource identifiers from Terraform:

```bash
S3_BUCKET=$(terraform -chdir=infra output -raw s3_bucket_name)
CF_DIST_ID=$(terraform -chdir=infra output -raw cloudfront_distribution_id)
```

Then deploy (README.md, tools/, and tests/ are dev-only and excluded):

```bash
aws s3 sync . "s3://${S3_BUCKET}" --exclude "README.md" --exclude "tools/*" --exclude "tests/*" --profile flap1
aws cloudfront create-invalidation --distribution-id "${CF_DIST_ID}" --paths "/*" --profile flap1
```

## Post-deploy

- Verify `https://shoichiseto.com/` loads (200) and `https://flap1.com/` 301-redirects to it
- Check key pages: home, about, work, research, notes, hobbies, 404

## Anti-patterns

- NEVER run any `aws` command without `--profile flap1`
- Never deploy uncommitted changes
- Never sync the whole directory without the README/tools/tests excludes
