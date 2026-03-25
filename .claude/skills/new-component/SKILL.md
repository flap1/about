---
name: new-component
description: Create a new Astro or React component following project conventions. Use when the user says "create component", "new component", "add component".
argument-hint: <ComponentName>
---

# Create New Component

Arguments: `$ARGUMENTS` (PascalCase component name)

## Astro Component (default)

Create at `src/components/$ARGUMENTS.astro`:

```astro
---
interface Props {
  // Define props here
}

const { } = Astro.props;
---

<div>
  <!-- Component content -->
</div>

<style>
  /* Scoped styles - use Tailwind utilities in the template instead when possible */
</style>
```

## React Island (when interactivity is needed)

Create at `src/components/$ARGUMENTS.tsx`:

```tsx
interface Props {
  // Define props here
}

export function $ARGUMENTS({ }: Props) {
  return (
    <div>
      {/* Component content */}
    </div>
  );
}
```

## Rules

- Always define `interface Props` (even if empty initially)
- Prefer `.astro` unless client-side interactivity is required
- Use semantic color tokens (`text-foreground`, `bg-surface`), not raw colors
- Use `font-display` / `font-body` / `font-mono` classes
- React islands must use `client:visible` or `client:idle` (not `client:load` unless critical)
- File name matches component name in PascalCase
