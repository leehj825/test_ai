import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const chapters = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/chapters' }),
  schema: z.object({
    title: z.string(),
    chapter: z.number().int().positive(),
    pov: z.enum(['kael', 'riena', 'damian', 'sein', 'rohar']),
    status: z.enum(['draft', 'published']),
    timeline: z.string(),
  }),
});

export const collections = { chapters };
