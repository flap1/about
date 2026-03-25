import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

const topics = defineCollection({
  loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/topics" }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
    lang: z.enum(["en", "ja"]).default("en"),
    ogImage: z.string().optional(),
  }),
});

const projects = defineCollection({
  loader: glob({ pattern: "**/*.{md,mdx}", base: "./src/content/projects" }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    url: z.string().url().optional(),
    repo: z.string().url().optional(),
    pubDate: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    featured: z.boolean().default(false),
    lang: z.enum(["en", "ja"]).default("en"),
    ogImage: z.string().optional(),
  }),
});

export const collections = { topics, projects };
