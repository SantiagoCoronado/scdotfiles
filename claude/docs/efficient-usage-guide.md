# How to Use These Dotfiles Efficiently with Claude Code

This guide explains how to leverage the custom Claude Code configuration in this repository to speed up your development workflow.

## 1. Installation & Setup

The Claude configuration is located in the `claude/` directory and is designed to be symlinked to `~/.claude/`.

- **To install:** Run `./install.sh --macos` (or `--linux`). This symlinks `agents/`, `skills/`, and `docs/` to your home directory.
- **Global Settings:** `claude/settings.json` is your global configuration. It includes:
  - **LSP Integration:** `ENABLE_LSP_TOOL=1` and several LSP plugins (TypeScript, Python, Go, C++).
  - **Agent Teams:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` enabled.
  - **Tmux Integration:** `teammateMode: "tmux"` for parallel agent visualization.
  - **Custom Hooks:** Automated logging, context loading, and notifications via Python scripts.

## 2. Custom Slash Commands

These are specialized shortcuts for common workflows. Type `/` in Claude to see them.

- **`/commit`**: Reviews staged changes, writes a "why-focused" message, and commits.
- **`/review`**: Performs a deep dive into your current changes, checking for bugs, security, and quality.
- **`/scaffold`**: Quickly sets up new project structures or modules based on templates.
- **`/sync`**: Synchronizes your local configuration with the repository.

## 4. Specialized Agents (The "Expert" Team)

Instead of asking the main Claude session to do everything, delegate to specialized agents for higher quality and speed.

| Agent | When to use it |
|---|---|
| **`researcher`** (Haiku) | Use for fast, read-only exploration of unfamiliar code. It maps architecture without editing. |
| **`debugger`** (Sonnet) | Use when you have a specific bug. It focuses on root cause analysis and implementing a fix. |
| **`code-reviewer`** (Sonnet) | Use to get an objective second opinion on your PR or diff. |
| **`claude-md-maintainer`** | Use to audit and update your project's `CLAUDE.md` files. |
| **`meta-agent` / `meta-skill`** | Use these to **self-evolve** your dotfiles. Ask them to create new agents or skills for you. |

**Example:** `Agent(researcher) "How does the hook system work in this repo?"`

## 5. Agent Teams (Parallel Excellence)

With `agent-teams` enabled and `tmux` mode active:
1. Start a tmux session: `tmux new -s work`.
2. Start Claude: `claude`.
3. Ask for a complex task: *"Refactor the auth module and update the documentation in parallel."*
4. Claude will spawn teammates in **new tmux panes**, allowing you to watch them work simultaneously.

## 6. Code Intelligence (LSP First)

The `CLAUDE.md` in this repo mandates an **LSP-First** approach. Claude is configured to prefer LSP over Grep/Glob.

- **Always ask Claude to:** "Check types", "Find all references", or "Go to definition".
- **LSP Benefits:** Higher precision, understands cross-file dependencies, and identifies type errors immediately after an edit.

## 7. Automated Hooks

Your setup includes several automated "life-cycle" hooks:
- **SessionStart:** Automatically loads relevant project context.
- **PreToolUse:** Blocks destructive commands like `rm -rf` or `git push --force`.
- **PostToolUse:** Can be configured to run formatters (Prettier, Black) after every edit.
- **Stop:** Plays a sound (`Purr.aiff`) when a task is finished or a subagent completes.

## 8. Best Practices for Efficiency

1. **Keep `CLAUDE.md` lean:** Update it frequently but keep it under 200 lines. Use `/claude-md-maintainer` to help.
2. **Use Haiku for Research:** It's 10x cheaper and 2x faster than Sonnet for reading code.
3. **Path-Scoped Rules:** Add rules to `.claude/rules/` that only load for specific directories (e.g., `linux/` vs `macos/`).
4. **Git Isolation:** For agent teams, use `isolation: "worktree"` to avoid file conflicts.

---
*Created by Gemini CLI to help you master your Claude Code environment.*
