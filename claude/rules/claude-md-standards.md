---
paths:
  - "**/CLAUDE.md"
  - "**/CLAUDE.local.md"
---
# CLAUDE.md Standards

When creating or editing CLAUDE.md files, follow these rules:

## Structure
- Keep under 200 lines. Longer files eat context and reduce instruction adherence.
- Use these sections in order: Commands, Architecture, Conventions, Watch out for
- Start with the project name as an H1 heading
- Use code blocks for commands, not inline code

## What to include
- Build, test, lint, and deploy commands with brief descriptions
- Key architectural decisions (monorepo? framework? ORM? API style?)
- Non-obvious gotchas that would waste time without knowing
- Import conventions, naming patterns, error handling styles
- File and folder structure for the main modules

## What NOT to include
- Anything a linter or formatter already enforces (eslint, prettier, black)
- Full documentation — link to it instead
- Long explanatory paragraphs or theory
- Dependency lists (package.json/go.mod already has those)
- Generic programming advice ("write clean code", "use meaningful names")

## Style
- Be direct and specific, not vague ("use zod for validation" not "validate inputs")
- Use bullet points, not paragraphs
- Commands should be copy-pasteable
- Gotchas should explain WHY, not just WHAT ("tests use a real DB, not mocks — run db:reset first")

## CLAUDE.local.md
- Only personal preferences that differ from the team standard
- Never duplicate what's in CLAUDE.md
- Keep even shorter — under 20 lines
