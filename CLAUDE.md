# CLAUDE.md

## Project Overview

Static site for `shoichiseto.com` (`flap1.com` 301-redirects to it). No build step, no framework -- plain HTML/CSS/JS. See `README.md` for structure and editing.

## AWS

- Profile: `flap1` -- ALWAYS use `--profile flap1` for every `aws` CLI command
- NEVER run `aws` commands without `--profile flap1` (never use default profile)
- S3 bucket name and CloudFront distribution IDs are defined in `infra/outputs.tf`
- Run `terraform -chdir=infra output` to retrieve them
- Two CloudFront distributions: content (`shoichiseto.com`) and redirect (`flap1.com` -> `shoichiseto.com`)

## Coding Conventions

- No emoji in code, comments, or documentation
- No bold formatting in generated content
- EditorConfig: LF, UTF-8, 2 spaces, final newline
- Use absolute/project-relative paths, avoid cd

## Git Branch Naming

Pattern: `<type>-<short-description>`
Example: `feat-hero-section`, `fix-dark-mode`
