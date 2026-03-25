# CLAUDE.md

## Project Overview

Personal portfolio and blog site for flap1. Built with Astro 6, Tailwind CSS v4, shadcn/ui, React islands.

Design theme: Shih Tzu dog mascot, space/cosmos, coffee, music, nature.
Design philosophy: Wabi-sabi (warm, organic, imperfect beauty).
Default mode: Dark (cosmic theme).

## Tech Stack

- Astro 6 (Node 22+, Vite 7)
- Tailwind CSS v4 (@tailwindcss/vite, CSS-first @theme)
- shadcn/ui (React islands with client:visible)
- Biome (linter/formatter)
- Expressive Code (code blocks)
- Pagefind (search)
- Content Layer API (Zod 4 from astro/zod)

## Build Commands

```bash
pnpm dev          # Start dev server (port 4321)
pnpm build        # Build for production
pnpm preview      # Preview production build
pnpm astro check  # Type check
```

## Design System

Colors (OKLCH):
- Brown (coffee): seed #8B5A2B
- Green (nature): seed #047857
- Stone (neutral): Tailwind stone scale
- Background light: Kinari #FBFAF3
- Background dark: Sumi #1C1C1C

Fonts:
- Display: Space Grotesk
- Body: Inter
- Mono: Space Mono
- Japanese: Noto Sans JP

## Coding Conventions

- No emoji in code, comments, or documentation
- No bold formatting in generated content
- EditorConfig: LF, UTF-8, 2 spaces, final newline
- Use absolute/project-relative paths, avoid cd

## AWS

- Profile: `flap1` -- ALWAYS use `--profile flap1` for every `aws` CLI command
- NEVER run `aws` commands without `--profile flap1` (never use default profile)
- S3 bucket name and CloudFront distribution ID are defined in `infra/outputs.tf`
- Run `terraform -chdir=infra output` to retrieve them

## Git Branch Naming

Pattern: `<type>-<short-description>`
Example: `feat-hero-section`, `fix-dark-mode`
