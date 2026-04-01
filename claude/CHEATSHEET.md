# Claude Code Cheatsheet

Quick reference for setting up and configuring Claude Code. Share this with your team.

---

## Directory structure

```
your-project/
├── CLAUDE.md                    # Team instructions (committed)
├── CLAUDE.local.md              # Personal overrides (gitignored)
└── .claude/
    ├── settings.json            # Permissions + config (committed)
    ├── settings.local.json      # Personal overrides (gitignored)
    ├── commands/                 # Custom slash commands
    ├── rules/                   # Modular instruction files
    ├── skills/                  # Auto-invoked workflows
    └── agents/                  # Specialized subagent personas

~/.claude/                       # Global (all projects)
├── CLAUDE.md                    # Personal global instructions
├── settings.json                # Global settings
├── commands/                    # Personal commands
├── skills/                      # Personal skills
├── agents/                      # Personal agents
└── projects/                    # Session history + auto-memory
```

---

## CLAUDE.md template

Keep it under 200 lines. Focus on what Claude can't infer from the code.

```markdown
# Project: My App

## Commands

npm run dev # Start dev server
npm run test # Run tests
npm run lint # Lint check
npm run build # Production build

## Architecture

- Express REST API, Node 20
- PostgreSQL via Prisma ORM
- Handlers in src/handlers/
- Shared types in src/types/

## Conventions

- Use zod for request validation
- Return shape: { data, error }
- Never expose stack traces to clients
- Use the logger module, not console.log

## Watch out for

- Tests use a real DB, not mocks. Run `npm run db:test:reset` first
- Strict TypeScript: no unused imports
```

---

## settings.json template

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
      "Bash(git branch *)",
      "Read",
      "Write",
      "Edit",
      "MultiEdit",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/.env)",
      "Read(**/.env.*)"
    ]
  }
}
```

**allow** = runs without asking. **deny** = blocked entirely. Everything else = Claude asks first.

---

## Custom commands template

File: `.claude/commands/review.md` -> becomes `/project:review`

```markdown
---
description: Review current branch diff before merging
---

## Changes

!`git diff --name-only main...HEAD`

## Diff

!`git diff main...HEAD`

Review for:

1. Code quality issues
2. Security vulnerabilities
3. Missing test coverage
4. Performance concerns

Give specific, actionable feedback per file.
```

### With arguments

File: `.claude/commands/fix-issue.md` -> `/project:fix-issue 234`

```markdown
---
description: Investigate and fix a GitHub issue
argument-hint: [issue-number]
---

Look at issue #$ARGUMENTS in this repo.

!`gh issue view $ARGUMENTS`

Find the root cause, fix it, and write a test that would have caught it.
```

---

## Skills template

File: `.claude/skills/security-review/SKILL.md`

Skills are auto-invoked when the task matches the description.

```markdown
---
name: security-review
description: Security audit. Use when reviewing code for vulnerabilities,
  before deployments, or when the user mentions security concerns.
allowed-tools: Read, Grep, Glob
---

Analyze the codebase for:

1. SQL injection and XSS risks
2. Exposed credentials or secrets
3. Insecure configurations
4. Authentication and authorization gaps

Report findings with severity ratings and remediation steps.
Reference @DETAILED_GUIDE.md for standards.
```

**Key:** Skills can bundle supporting files (referenced with `@filename`). Commands are single files.

---

## Agents template

File: `.claude/agents/code-reviewer.md`

Agents are spawned as isolated subagents with their own context window.

```markdown
---
name: code-reviewer
description: Expert code reviewer. Use PROACTIVELY when reviewing PRs,
  checking for bugs, or validating implementations before merging.
model: sonnet
tools: Read, Grep, Glob
---

You are a senior code reviewer focused on correctness and maintainability.

When reviewing code:

- Flag bugs, not style issues
- Suggest specific fixes, not vague improvements
- Check edge cases and error handling
- Note performance concerns only when they matter at scale
```

**model:** Use `haiku` for fast read-only tasks, `sonnet` for balanced work, `opus` for complex reasoning.
**tools:** Restrict to what the agent actually needs. Read-only agents don't need Write/Edit.

---

## Rules template (path-scoped)

File: `.claude/rules/api-conventions.md`

```markdown
---
paths:
  - "src/api/**/*.ts"
  - "src/handlers/**/*.ts"
---

# API Design Rules

- All handlers return { data, error } shape
- Use zod for request body validation
- Never expose internal error details to clients
- Log errors with request ID for tracing
```

Rules without `paths:` frontmatter load every session. Rules with `paths:` only load when Claude works on matching files.

---

## Hooks template

Hooks in `settings.json` run shell commands on tool events.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "your-validation-script.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write '**/*.{ts,tsx}' --log-level silent 2>/dev/null || true"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Purr.aiff 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

**Events:** `PreToolUse` (validate/block), `PostToolUse` (format/lint), `Stop` (notify).
**Exit code 2** from PreToolUse = block the tool call.

---

## MCP servers

MCP (Model Context Protocol) connects Claude to external tools and services. Configure in `.claude/settings.json` or project-level `.mcp.json`.

### In settings.json (global)

```json
{
  "servers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "your-token-here"
      }
    }
  }
}
```

### In .mcp.json (project-level, committed)

```json
{
  "mcpServers": {
    "postgres": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost:5432/mydb"
      }
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./docs"]
    }
  }
}
```

### Server types

| Type | Use case | Example |
|------|----------|---------|
| `stdio` | Local process, communicates via stdin/stdout | Most npm-based servers |
| `sse` | Remote server, Server-Sent Events | Self-hosted services |
| `http` | Remote server, HTTP streaming | Cloud-hosted APIs |

### Popular MCP servers

```
@modelcontextprotocol/server-github      # GitHub issues, PRs, repos
@modelcontextprotocol/server-postgres    # PostgreSQL queries
@modelcontextprotocol/server-filesystem  # Scoped file access
@modelcontextprotocol/server-brave-search # Web search
@modelcontextprotocol/server-memory      # Persistent key-value memory
@anthropic/mcp-server-fetch              # Fetch web content
```

### Tips

- Put tokens in `env` inside the server config, NOT in shell environment
- Use `.mcp.json` for project-specific servers (DB, APIs). Use `settings.json` for global ones (GitHub, search).
- Test with `claude mcp list` to see active servers
- Use `claude mcp add <name>` for interactive setup

---

## Getting started (5 steps)

1. **Run `/init`** in Claude Code. It generates a starter CLAUDE.md. Edit it down to essentials.
2. **Add `.claude/settings.json`** with allow/deny rules for your stack. At minimum: allow run commands, deny .env reads.
3. **Create 1-2 commands** for workflows you repeat. Code review and issue fixing are good starters.
4. **Split CLAUDE.md into `.claude/rules/`** once it gets crowded. Scope rules by path where it makes sense.
5. **Add `~/.claude/CLAUDE.md`** with personal preferences that apply across all projects.

That covers 95% of use cases. Add skills and agents when you have recurring complex workflows worth packaging.

---

## Best practices

- **CLAUDE.md is highest leverage.** Get that right first. Everything else is optimization.
- **Keep CLAUDE.md under 200 lines.** Longer files eat context and reduce instruction adherence.
- **Don't duplicate linter/formatter rules.** Claude reads your eslintrc and prettier config already.
- **Use `CLAUDE.local.md` for personal quirks.** It's auto-gitignored.
- **Path-scope your rules.** API rules shouldn't load when editing React components.
- **Restrict agent tools.** A security auditor doesn't need Write access.
- **Use cheaper models for simple agents.** Haiku handles read-only exploration well.
- **Treat .claude/ like infrastructure.** Set it up once, refine as you go, it pays dividends daily.
