---
description: Scaffold a complete .claude folder structure in any project
---
Create the full .claude directory structure for this project. Set up all directories, starter files, and local overrides.

Create the following structure:

1. **`.claude/settings.json`** with $schema and basic permissions:
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(make *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(.env)",
      "Read(.env.*)"
    ]
  }
}
```

2. **`.claude/settings.local.json`** with empty overrides:
```json
{}
```

3. **`CLAUDE.md`** at project root — auto-detect the tech stack first, then generate a tailored file:

**Stack detection** — check for these files in order and read them:

| File(s) | Stack | What to extract |
|---------|-------|-----------------|
| `package.json` | Node.js | `scripts` object (run/test/build/lint commands), `dependencies`/`devDependencies` keys to identify framework (Next.js, Express, Vite, React, etc.) |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python | test runner (pytest/unittest), linter (ruff/flake8/pylint), formatter (black/ruff), package manager (poetry/uv/pip) |
| `go.mod` | Go | module name, Go version; commands are standard (`go build`, `go test ./...`, `go vet ./...`) |
| `Cargo.toml` | Rust | workspace vs single crate, features; commands are standard (`cargo build`, `cargo test`, `cargo clippy`) |
| `Makefile` | Any | Parse targets with `make help` or extract lines matching `^[a-zA-Z][^:]*:` |
| `pom.xml` | Java (Maven) | `mvn compile`, `mvn test`, `mvn package` |
| `build.gradle` / `build.gradle.kts` | Java/Kotlin (Gradle) | `./gradlew build`, `./gradlew test` |
| `composer.json` | PHP | `composer install`, `scripts` block |
| `Gemfile` | Ruby | detect Rails vs plain Ruby, RSpec vs minitest |
| `mix.exs` | Elixir | `mix compile`, `mix test`, `mix format` |

If multiple files exist (e.g. `Makefile` + `package.json`), use both — list the Makefile targets in a separate section.

**CLAUDE.md content** — generate based on the detected stack. Include:
- **Commands** section with actual commands from the project (not generic templates). Use copy-pasteable shell lines.
- **Architecture** section with framework-specific notes (e.g. "Next.js App Router — pages live in `app/`, server components by default, use `"use client"` to opt into client rendering").
- **Conventions** section with import patterns, naming conventions, directory layout of main modules.
- **Watch out for** section with stack-specific gotchas:
  - Node.js: note if the project uses ESM vs CJS, any unusual tsconfig paths aliases
  - Python: note if `PYTHONPATH` needs to be set, or if tests require a running service
  - Go: `go mod tidy` after adding imports; `//go:generate` directives if present
  - Rust: note if `build.rs` exists or unusual feature flags
  - Any: note if there's a seed/reset step before tests

Keep the file under 200 lines. Be specific, not generic.

4. **`CLAUDE.local.md`** at project root with a placeholder:
```markdown
# Personal overrides (gitignored)
# Add your personal preferences here
```

5. **`.claude/rules/`** directory with a starter `conventions.md`

6. **`.claude/commands/`** directory with a starter `review.md` that diffs against main

7. Ensure `.gitignore` includes:
```
CLAUDE.local.md
.claude/settings.local.json
```

After creating everything, show a tree view of what was created and confirm the .local files are gitignored.
