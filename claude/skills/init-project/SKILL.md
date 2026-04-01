---
name: init-project
description: Quick project onboarding — scans a new repo and generates a minimal CLAUDE.md with only the quirks.
disable-model-invocation: true
---

Scan this project and create (or update) a minimal CLAUDE.md.

$ARGUMENTS

Use the `claude-md-maintainer` agent to:

1. Scan the project structure, build system, and configuration
2. Identify quirks that Claude would get wrong without being told
3. Generate a CLAUDE.md that is:
   - 50-80 lines max
   - Conversational tone (like notes to a coworker)
   - Only project-specific quirks, no generic advice
   - Organized by: Build/Run, Architecture, Gotchas

If a CLAUDE.md already exists, audit and slim it down rather than starting from scratch.
