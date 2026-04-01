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

3. **`CLAUDE.md`** at project root — run `/init` first if it doesn't exist, or create a minimal one by reading the project's package.json, Makefile, or equivalent to detect build/test/lint commands and project structure.

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
