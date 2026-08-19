# CLAUDE.md

Guidance for Claude Code (and human writers) working in this repository.

## Project

An Astro 5 static site that serializes a novel chapter by chapter. Chapters
are Markdown files with frontmatter, listed on the index page, and rendered
through a shared chapter template with prev/next navigation.

## Chapter files

- Location: `src/content/chapters/*.md`
- Filename convention: `NN-slug.md`, e.g. `04-the-crossing.md`. The number
  prefix keeps files sorted in directory listings; it does not need to match
  `chapter` exactly but should stay close to it.
- Required frontmatter:
  ```yaml
  title: The Crossing
  chapter: 4
  pov: kael # one of: kael, riena, damian, sein, rohar
  status: draft # draft | published
  timeline: Year 1, Early Spring
  ```
- `chapter` numbers must be unique and increasing in reading order. Prev/next
  links are derived by sorting published chapters on this field, not on
  filename.
- Only `status: published` chapters appear on the index page or are built as
  standalone routes with working prev/next. Leave a chapter as `draft` until
  it is ready for readers.

## Writing rules

- Write in past tense, close third person, one POV character per chapter.
  Do not head-hop within a chapter.
- Keep the `pov` character's frontmatter value matched to whichever
  character's eyes the chapter is told through — this drives the accent
  colour on the chapter page, so it must be accurate.
- `timeline` is a free-text in-world date/era shown under the chapter title
  (e.g. "Year 1, Early Spring"). Keep phrasing consistent across chapters so
  the reading order stays clear.
- Prefer scene breaks (`---` on its own line) over new chapters for short
  POV-consistent scene shifts; start a new chapter file when the POV
  character changes.
- Do not resolve a chapter's central tension in its final paragraph — end on
  a turn, a question, or a reveal that pulls the reader to the next chapter.

## Adding a POV character

Each POV has a distinct accent colour tinting its chapter pages, defined in
`src/lib/pov.ts` (`POV_THEME`). To add a new POV character:

1. Add the character to `POVS` and `POV_THEME` in `src/lib/pov.ts`.
2. Add the character to the `pov` enum in `src/content.config.ts`.
3. Pick an accent colour distinct from existing POVs (check contrast against
   `--paper` in `src/styles/global.css`).

## Commands

- `npm install` — install dependencies.
- `npm run dev` — local dev server.
- `npm run build` — type-check content and build the static site to `dist/`.
- `npm run preview` — preview the production build locally.

## Code conventions

- Content typing is enforced by the Zod schema in `src/content.config.ts` —
  update it, not individual pages, when frontmatter shape changes.
- Shared page chrome lives in `src/layouts/BaseLayout.astro`; page-specific
  markup stays in `src/pages/**`.
- Keep styling in `src/styles/global.css` using the `--accent` /
  `--accent-soft` CSS custom properties so POV theming keeps working; avoid
  introducing a second styling system (no CSS-in-JS, no utility framework)
  without discussion.
