---
name: create-pr
description: Create a Pull Request from the current branch. Validates, commits, pushes, and creates PR with proper title format. Use when the user says "create PR", "make PR", "submit PR", or "open PR".
argument-hint: [base-branch]
---

# Create Pull Request

Create a PR from the current branch to the specified base branch.

Arguments: `$ARGUMENTS` (optional, default: `main`)

## PR Title Format (MANDATORY)

```
<type>: <Description starting with capital letter>
```

Types: `feat`, `imprv`, `fix`, `chore`, `docs`

Examples:
- `feat: Add hero section with mascot illustration`
- `fix: Correct dark mode toggle on mobile`
- `imprv: Optimize CJK font loading performance`
- `docs: Update README with deployment instructions`
- `chore: Upgrade Astro to 6.1`

## Workflow

### 0. Parse Arguments

Base branch: Use `$ARGUMENTS` if provided, otherwise default to `main`.

### 1. Pre-PR Validation

Check current state:

```bash
git branch --show-current
git status
git diff origin/<base-branch>..HEAD --name-only
```

Run quality checks:

```bash
pnpm validate
```

This runs: `astro check && biome check src/ && astro build`

If validation fails, fix the issues before proceeding. Do NOT skip validation.

### 2. Commit (if uncommitted changes exist)

```bash
git add <specific-files>
git commit -m "<type>: <Description>"
```

Detect type from branch name:
- Branch `feat-*` -> `feat:`
- Branch `fix-*` -> `fix:`
- Branch `imprv-*` -> `imprv:`
- Branch `chore-*` -> `chore:`
- Branch `docs-*` -> `docs:`

Never use `git add .` or `git add -A`. Add specific files only.

### 3. Push

```bash
git push -u origin HEAD
```

### 4. Create PR

```bash
gh pr create --title "<type>: <Title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points describing what changed and why>

## Changes
<list of notable changes>

## Test Plan
- [ ] `pnpm validate` passes (type check + lint + build)
- [ ] Visual check in browser (`pnpm preview`)
- [ ] <additional checks as needed>
EOF
)" --base <base-branch> --assignee @me
```

## Anti-patterns

- Never skip `pnpm validate`
- Never force push without asking the user
- Never create PRs with generic titles like "Update files" or "Fix stuff"
- Never include `.env` or secrets in commits
- Never amend commits that are already pushed
