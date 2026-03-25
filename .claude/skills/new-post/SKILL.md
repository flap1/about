---
name: new-post
description: Create a new blog post or note with proper frontmatter and file structure. Use when the user says "new post", "write a post", "create blog post", "new note", or "new TIL".
argument-hint: <title>
---

# Create New Content

Create a new blog post or note entry.

Arguments: `$ARGUMENTS` (title of the post)

## Blog Post

Create at `src/content/blog/<slug>.mdx`:

```mdx
---
title: "<Title>"
description: "<1-2 sentence description>"
pubDate: <today YYYY-MM-DD>
tags: []
draft: true
---

Content here.
```

## Note / TIL

Create at `src/content/notes/<slug>.md`:

```md
---
title: "<Title>"
pubDate: <today YYYY-MM-DD>
tags: []
---

Content here.
```

## Slug Rules

- Lowercase, hyphenated
- No special characters
- English only (even for Japanese content)
- Max 60 characters

## After Creation

- Open the file for editing
- Remind: set `draft: false` when ready to publish
