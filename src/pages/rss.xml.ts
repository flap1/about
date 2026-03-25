import { getCollection } from "astro:content";
import rss from "@astrojs/rss";
import type { APIContext } from "astro";

export async function GET(context: APIContext) {
  const topics = await getCollection("topics");
  const published = topics
    .filter((t) => !t.data.draft)
    .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());

  return rss({
    title: "flap1",
    description: "Developer, builder, exploring the intersection of structure and nature.",
    site: context.site?.toString() ?? "https://flap1.com",
    items: published.map((topic) => ({
      title: topic.data.title,
      pubDate: topic.data.pubDate,
      description: topic.data.description,
      link: `/topics/${topic.id}/`,
    })),
    customData: "<language>en-us</language>",
  });
}
