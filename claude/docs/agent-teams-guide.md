# Claude Code Agent Teams & Custom Agents: Best Practices Guide

## 1. Overview

### What Are the Different Approaches?

| Feature | Single Session | Subagents | Agent Teams |
|---|---|---|---|
| **Concurrency** | Sequential | Parallel (within one session) | Fully parallel (separate processes) |
| **Context** | Shared | Spawned with subset of parent context | Each teammate has own context window |
| **Coordination** | N/A | Parent orchestrates | Lead + task list + mailbox |
| **File safety** | Full access | Shared filesystem (conflict risk) | Can use worktrees for isolation |
| **Cost** | 1x | 2-3x | ~7x |
| **Best for** | Simple tasks, quick edits | Delegating focused subtasks | Large, multi-file changes in parallel |

### When to Use Each

- **Single session** -- Most tasks. Bug fixes, feature additions, code explanations, refactoring a single module.
- **Subagents** -- When you need parallel research or focused subtasks that report back. Code review while continuing other work. Background exploration.
- **Agent teams** -- Large-scale parallel work: multi-module refactors, simultaneous feature development across services, competing hypothesis investigations.

---

## 2. Setup & Configuration

### Enabling Agent Teams

Add to your `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

This is already enabled in your configuration.

### Display Modes

Agent teams can display in two ways:

| Mode | How It Works | Best For |
|---|---|---|
| **In-process** | All output in a single terminal | Quick teams, headless/CI usage |
| **Split-pane** | Each teammate gets its own pane via tmux or iTerm2 | Monitoring parallel work visually |

For split-pane in tmux:

```bash
# Start a tmux session first
tmux new -s work
# Then start Claude Code — teammates will auto-split into panes
claude
```

For iTerm2, teammates automatically open in new tabs when iTerm2 is detected.

---

## 3. Creating Custom Agents

### Agent File Format

Agent definitions are Markdown files with YAML frontmatter:

```markdown
---
name: my-agent
description: What this agent does and when to use it.
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
---

# Purpose

You are a [role]. Your job is to [task].

## Instructions

1. Step one
2. Step two

## Report

Provide output in this format:
...
```

### Frontmatter Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | Yes | Kebab-case identifier (e.g., `code-reviewer`) |
| `description` | string | Yes | When to delegate to this agent. Critical for automatic routing. Use action-oriented language: "Use this when..." |
| `tools` | comma-separated | Yes | Minimal set of tools the agent can access |
| `model` | string | No | `haiku`, `sonnet`, or `opus`. Default: inherits from parent |
| `color` | string | No | Terminal color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `permissionMode` | string | No | `default`, `plan`, `acceptEdits`, `bypassPermissions`, `dontAsk`, `auto` |
| `maxTurns` | number | No | Maximum conversation turns before the agent stops |
| `hooks` | object | No | Agent-specific hooks (same format as `settings.json` hooks) |
| `memory` | boolean | No | Whether the agent can access memory files |
| `background` | boolean | No | Whether the agent runs in the background by default |
| `isolation` | string | No | Set to `"worktree"` for git worktree isolation |

### Storage Scopes

Agents are loaded from three locations, in order of precedence:

| Scope | Path | Use Case |
|---|---|---|
| **Session** | `--agents` CLI flag | Temporary, one-off agents |
| **Project** | `.claude/agents/*.md` | Agents specific to a repository |
| **User** | `~/.claude/agents/*.md` | Agents available across all projects |

Your current user-level agents:

```
~/.claude/agents/
  code-reviewer.md    # Sonnet — universal code review
  debugger.md         # Sonnet — root cause analysis + fix
  researcher.md       # Haiku  — fast read-only codebase exploration
  meta-agent.md       # Opus   — generates new agent definitions
  meta-skill.md       # Opus   — generates new skill definitions
  claude-md-maintainer.md  # Sonnet — CLAUDE.md audit and cleanup
```

### Creating Agents

**Option 1: Write the file directly.** Create a `.md` file in the appropriate scope directory following the format above.

**Option 2: Use the `/agents` interface.** Type `/agents` in Claude Code to browse, create, and manage agents interactively.

**Option 3: Use the `meta-agent`.** Ask Claude to create an agent and it will delegate to `meta-agent`, which scrapes current documentation and generates a well-structured agent definition.

### Real Examples from Your Configuration

**Read-only research agent (Haiku -- cheap and fast):**

```yaml
---
name: researcher
description: Fast, read-only codebase explorer for understanding unfamiliar code.
tools: Read, Grep, Glob
model: haiku
color: green
---
```

Key decisions: Haiku is ideal because research is high-volume, low-complexity. No `Edit`, `Write`, or `Bash` tools -- the agent can't modify anything.

**Code review agent (Sonnet -- balanced):**

```yaml
---
name: code-reviewer
description: Universal code reviewer for any language. Use this when the user
  wants a code review, PR review, or quality check on changed files.
tools: Read, Grep, Glob, Bash
model: sonnet
color: yellow
---
```

Key decisions: Sonnet balances quality and cost for review work. `Bash` is included for running `git diff` commands. No `Edit` or `Write` -- reviewers report, they don't fix.

**Debugging agent (Sonnet -- needs Edit for fixes):**

```yaml
---
name: debugger
description: Root cause analysis and fix implementation for bugs and errors.
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
color: red
---
```

Key decisions: Includes `Edit` because debuggers need to implement fixes. `Bash` for reproducing errors and running tests.

---

## 4. Agent Teams Workflow

### Starting a Team

Ask naturally. Claude will recognize when a task benefits from parallel work:

```
"Refactor the auth module, update the API routes, and fix the failing tests --
all in parallel."
```

Or be explicit:

```
"Create a team to work on this. One teammate for the backend API,
one for the frontend components, one for the test suite."
```

### Team Architecture

```
┌─────────────────────────────────────────┐
│                  Lead                    │
│  (orchestrates, creates tasks, spawns)   │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────┐  ┌──────────┐  ┌────────┐│
│  │Teammate A│  │Teammate B│  │Teammate││
│  │(backend) │  │(frontend)│  │  C     ││
│  │          │  │          │  │(tests) ││
│  └──────────┘  └──────────┘  └────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Shared Task List           ││
│  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  ││
│  │  │Task1│ │Task2│ │Task3│ │Task4│  ││
│  │  └─────┘ └─────┘ └─────┘ └─────┘  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │             Mailbox                  ││
│  │  Messages between teammates         ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

**Lead**: The main Claude session. Creates the team, defines tasks, spawns teammates, monitors progress, and synthesizes results.

**Teammates**: Independent Claude processes, each with their own context window. They work on assigned tasks and communicate via the mailbox.

**Task List**: Shared state tracking what needs to be done, who's doing it, and what's finished.

**Mailbox**: Asynchronous message passing between teammates using `SendMessage`.

### Spawning Teammates

The lead uses the `Agent` tool (or `TeamCreate` for the full team) to spawn teammates:

```javascript
// Via Agent tool
Agent({
  description: "Refactor auth module",
  prompt: "Refactor the authentication module in src/auth/...",
  name: "auth-refactor",        // addressable name for messaging
  model: "sonnet",              // model override
  mode: "acceptEdits",          // permission mode
  isolation: "worktree",        // git worktree for safety
  run_in_background: true       // don't block the lead
})
```

### Task Management

Tasks flow through these states:

```
pending → in_progress → completed
                     → failed
                     → blocked
```

Tasks can have dependencies -- a task won't start until its dependencies are completed. The lead assigns tasks to teammates and monitors their progress.

### Direct Messaging Between Teammates

Teammates communicate asynchronously via `SendMessage`:

```javascript
// Teammate A sends to Teammate B
SendMessage({
  to: "frontend-team",
  message: "The API endpoint changed from /api/v1/users to /api/v2/users.
            Update your fetch calls accordingly."
})
```

This is how teammates coordinate when their work intersects -- for example, when a backend change affects the frontend.

### Plan Approval Flow

When a teammate's `mode` is set to `"plan"`, they must submit their plan for approval before executing:

1. Teammate analyzes the task and creates a plan
2. Plan is sent to the lead (or user) for review
3. Once approved, the teammate executes
4. Good for high-risk changes where you want human oversight

### Shutting Down

The lead waits for all tasks to complete, reviews results, and synthesizes a final summary. Teammates exit automatically when their work is done. Worktrees are cleaned up if no changes were made; if changes exist, the worktree path and branch are returned for merging.

---

## 5. Best Practices

### Team Sizing

- **3-5 teammates** is the sweet spot. More than 5 creates coordination overhead that outweighs parallelism gains.
- **5-6 tasks per teammate** keeps each focused without context thrashing.
- If a task needs more than 6 subtasks, it should probably be split into multiple teammates.

### Give Teammates Enough Context

Each teammate starts fresh with no prior context. The spawn prompt is everything they know. Include:

- **What** they need to do (specific files, specific changes)
- **Why** they're doing it (business context, architectural rationale)
- **Constraints** (don't touch X, must be backwards compatible, etc.)
- **How to verify** (run these tests, check this behavior)

Bad:
```
"Fix the auth bug"
```

Good:
```
"Fix the authentication bug in src/auth/middleware.ts where JWT tokens
with expired refresh tokens are not being rejected. The issue is in the
validateToken() function around line 45. After fixing, run
'npm test -- --grep auth' to verify. Don't modify the token generation
logic in src/auth/tokens.ts."
```

### Avoiding File Conflicts

**The #1 source of team failures is teammates editing the same files.**

Strategies:
- **Assign clear file ownership.** Each teammate owns specific files/directories. No overlap.
- **Use `isolation: "worktree"`** to give each teammate their own copy of the repo. Changes are made on separate branches and merged afterward.
- **Sequence dependent changes.** If Teammate B needs Teammate A's output, make B's task depend on A's completion.

### Foreground vs Background Agents

| Mode | When to Use |
|---|---|
| **Foreground** (default) | When you need the result before proceeding. Research that informs next steps. |
| **Background** (`run_in_background: true`) | When work is genuinely independent. Don't poll -- you'll be notified on completion. |

Rule of thumb: If the lead can do useful work while waiting, use background. If it's blocked until the result arrives, use foreground.

### Model Selection Strategy

| Model | Cost | Speed | Use For |
|---|---|---|---|
| **Haiku** | Lowest | Fastest | Research, grep-and-report, simple transformations, read-only tasks |
| **Sonnet** | Medium | Balanced | Most coding tasks, reviews, debugging, standard implementation |
| **Opus** | Highest | Slowest | Complex architectural decisions, multi-step reasoning, agent generation |

Your existing agents follow this pattern well:
- `researcher` uses Haiku (read-only exploration)
- `code-reviewer`, `debugger`, `claude-md-maintainer` use Sonnet (balanced coding work)
- `meta-agent`, `meta-skill` use Opus (complex generation requiring deep reasoning)

### Permission Modes

| Mode | Behavior | Use For |
|---|---|---|
| `default` | Prompts user for risky operations | Interactive sessions |
| `plan` | Must get plan approved before executing | High-risk automated changes |
| `acceptEdits` | Auto-approves file edits, prompts for Bash | Trusted code modification tasks |
| `bypassPermissions` | No prompts at all | Fully trusted, well-tested agents |
| `dontAsk` | Skips instead of prompting | Background agents that shouldn't block |
| `auto` | Automatically selects based on context | General-purpose |

For teams, `acceptEdits` is a good default -- teammates can write code without blocking on every edit, but dangerous shell commands still need approval.

### Token Cost Awareness

Agent teams consume significantly more tokens than single sessions:

- Each teammate has its own full context window
- The lead maintains context for coordination overhead
- Expect **~7x token usage** compared to doing the same work sequentially
- Use teams only when the parallelism genuinely saves time or when the task is too large for a single context

Cost reduction strategies:
- Use Haiku for research/read-only teammates
- Keep spawn prompts focused (less context = fewer input tokens)
- Set `maxTurns` to prevent runaway agents
- Use `dontAsk` mode for background agents to avoid blocking (which wastes idle tokens)

### Monitoring and Steering Active Teams

- **Check task status** to see what each teammate is working on and their progress
- **Send messages** to teammates to course-correct without restarting them
- **Cancel tasks** that are going in the wrong direction
- Watch for teammates that seem stuck (repeated errors, no progress) and intervene early

---

## 6. Hooks for Quality Enforcement

### Relevant Hook Events for Teams

| Hook | When It Fires | Use For |
|---|---|---|
| `SubagentStart` | When a subagent is spawned | Logging, resource tracking |
| `SubagentStop` | When a subagent finishes | Cleanup, result validation |
| `TeammateIdle` | When a teammate has no more tasks | Reassignment, shutdown |
| `TaskCompleted` | When a task is marked done | Validation gates |
| `PreToolUse` | Before any tool call | Blocking dangerous operations |
| `PostToolUse` | After any tool call | Auto-formatting, notifications |

### Your Current Hooks (Reference)

Your `settings.json` already has well-structured hooks:

```json
{
  "PreToolUse": [{
    "matcher": "Bash",
    "hooks": [{
      "type": "command",
      "command": "// blocks rm -rf, git push --force, git reset --hard, git clean -f"
    }]
  }],
  "PostToolUse": [{
    "matcher": "Edit|MultiEdit|Write",
    "hooks": [
      { "command": "black . --quiet 2>/dev/null || true" },
      { "command": "npx prettier --write '**/*.{ts,tsx,js,jsx}' --log-level silent 2>/dev/null || true" }
    ]
  }]
}
```

These hooks apply to all agents (including teammates), giving you:
- Destructive command protection across all teammates
- Auto-formatting after any file modification

### Agent-Specific Hooks

You can define hooks inside an agent's frontmatter for agent-scoped enforcement:

```yaml
---
name: safe-deployer
description: Deploys to staging with safety checks.
tools: Bash, Read
model: sonnet
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "bash -c 'input=$(cat); cmd=$(echo \"$input\" | jq -r \".tool_input.command\"); if echo \"$cmd\" | grep -q \"production\"; then echo \"BLOCK: No production commands allowed\" >&2; exit 2; fi'"
---
```

### Example: Block Task Completion Without Tests

```bash
#!/bin/bash
# Hook: TaskCompleted
# Block task completion if tests haven't been run
input=$(cat)
task_id=$(echo "$input" | jq -r '.task_id')
# Check if test results exist for this task
if ! find /tmp/test-results -name "${task_id}*" -newer /tmp/task-start 2>/dev/null | grep -q .; then
  echo "BLOCK: Task $task_id cannot be completed without running tests" >&2
  exit 2
fi
```

### Example: Block Teammate Idle Without Build Verification

```bash
#!/bin/bash
# Hook: TeammateIdle
# Ensure the build passes before a teammate is considered done
input=$(cat)
teammate=$(echo "$input" | jq -r '.teammate_name')
if ! npm run build --silent 2>/dev/null; then
  echo "BLOCK: Teammate $teammate has a broken build. Fix before idling." >&2
  exit 2
fi
```

---

## 7. Use Case Patterns

### Pattern 1: Parallel Code Review

**Scenario:** Review a large PR touching multiple subsystems.

```
Team structure:
  Lead: Coordinates and synthesizes final review
  Teammate 1 (Haiku): Review backend changes (src/api/, src/models/)
  Teammate 2 (Haiku): Review frontend changes (src/components/, src/pages/)
  Teammate 3 (Haiku): Review test changes (tests/)
```

Each teammate uses a read-only tool set (`Read, Grep, Glob`) and reports findings. The lead merges the reviews into a single summary. Cost-effective because Haiku handles the volume.

### Pattern 2: Competing Hypothesis Investigation

**Scenario:** A performance regression appeared. You're not sure of the cause.

```
Team structure:
  Lead: Evaluates hypotheses and decides which fix to pursue
  Teammate 1 (Sonnet): Investigate database query regression
  Teammate 2 (Sonnet): Investigate memory leak in new caching layer
  Teammate 3 (Sonnet): Investigate network latency from new middleware
```

Each teammate investigates independently and reports findings. The lead evaluates which hypothesis is correct and assigns the fix. Use `isolation: "worktree"` so each teammate can try experimental fixes without conflicting.

### Pattern 3: Multi-Module Refactoring

**Scenario:** Rename a core type used across the entire codebase.

```
Team structure:
  Lead: Coordinates ordering and resolves conflicts
  Teammate 1 (Sonnet, worktree): Refactor src/api/
  Teammate 2 (Sonnet, worktree): Refactor src/services/
  Teammate 3 (Sonnet, worktree): Refactor src/models/ and migrations
  Teammate 4 (Sonnet, worktree): Update tests/
```

Each works in an isolated worktree. After all finish, the lead merges branches sequentially, resolving any conflicts. Task dependencies ensure `models/` finishes before `services/` starts (if there are interface changes).

### Pattern 4: Research and Synthesis

**Scenario:** Evaluate three different approaches to implementing a feature.

```
Team structure:
  Lead: Synthesizes research into a recommendation
  Teammate 1 (Haiku): Research approach A (pros, cons, examples)
  Teammate 2 (Haiku): Research approach B (pros, cons, examples)
  Teammate 3 (Haiku): Research approach C (pros, cons, examples)
```

Cheap, fast, parallel research. Each teammate explores one approach using `Read, Grep, Glob, WebSearch, WebFetch`. The lead compares findings and presents a recommendation.

### Pattern 5: Full-Stack Feature Development

**Scenario:** Build a new feature end-to-end across backend, frontend, and tests.

```
Team structure:
  Lead: Coordinates API contract, merges results
  Teammate 1 (Sonnet, worktree): Backend API endpoints + database schema
  Teammate 2 (Sonnet, worktree): Frontend components + state management
  Teammate 3 (Sonnet, worktree): Integration and unit tests
```

Task dependencies: Teammate 1 defines the API contract first. Teammates 2 and 3 start after the contract is finalized (or the lead messages them the contract).

---

## 8. Troubleshooting & Limitations

### Common Issues

| Issue | Cause | Fix |
|---|---|---|
| Teammates editing the same file | No file ownership boundaries | Assign explicit file ownership in spawn prompts or use `isolation: "worktree"` |
| Teammate seems stuck | Waiting for user permission prompt | Use `acceptEdits` or `dontAsk` mode for background teammates |
| Team costs are very high | Too many teammates, wrong model choices | Reduce team size, use Haiku for read-only work, set `maxTurns` |
| Merge conflicts after worktree work | Overlapping changes across worktrees | Sequence dependent tasks, keep changes orthogonal |
| Teammate doesn't have enough context | Spawn prompt was too brief | Include specific files, rationale, constraints, and verification steps in the prompt |
| Hooks blocking teammates | Global hooks apply to all agents | Use `matcher` patterns to scope hooks appropriately or add agent-specific overrides |
| Teammate output is cut off | Hit `maxTurns` limit | Increase `maxTurns` or break the task into smaller pieces |

### Known Limitations

- **No session resumption for teams.** If the lead session ends, teammates are terminated. There's no way to resume a team.
- **No nested teams.** A teammate cannot spawn its own team. Teammates can spawn subagents (via the `Agent` tool), but not full teams.
- **No shared filesystem locking.** Two teammates can write to the same file simultaneously. There's no built-in conflict prevention -- you must design around this with file ownership or worktrees.
- **Single machine only.** All teammates run on the same machine. There's no distributed team execution.
- **No teammate-to-teammate direct calls.** Teammates communicate only via the mailbox (`SendMessage`), not by invoking each other.
- **Worktree cleanup is manual if changes exist.** When a worktree teammate makes changes, the worktree and branch persist. You must merge or delete them manually.
- **Context window per teammate.** Each teammate has its own context limit. Very large tasks may still exceed a single teammate's window.
- **No real-time streaming between teammates.** A teammate's output is only visible when it completes (foreground) or finishes (background). You can't watch a background teammate's progress in real-time.

### Debugging Tips

1. **Start small.** Test with 2 teammates before scaling to 5.
2. **Use foreground first.** Easier to debug than background agents. Switch to background once the workflow is proven.
3. **Check task states.** If things seem stuck, inspect the task list for `blocked` or `failed` tasks.
4. **Read teammate output carefully.** When a background teammate finishes, its full output is returned. Check for errors or unexpected behavior.
5. **Use `maxTurns` as a safety net.** Prevents runaway agents from consuming unlimited tokens.

---

## Quick Reference

### Minimal Agent Template

```markdown
---
name: my-agent
description: One-line description of when to use this agent.
tools: Read, Grep, Glob
model: sonnet
---

# Purpose

You are a [role]. You [do what].

## Instructions

1. First step
2. Second step

## Report

Output format here.
```

### Tool Reference for Agents

| Tool | What It Does | Give To |
|---|---|---|
| `Read` | Read files | Almost every agent |
| `Grep` | Search file contents | Research, review agents |
| `Glob` | Find files by pattern | Research, review agents |
| `Edit` | Modify existing files | Agents that fix/change code |
| `Write` | Create new files | Agents that generate code |
| `Bash` | Run shell commands | Agents that need to build/test/run |
| `Agent` | Spawn sub-agents | Lead agents, orchestrators |
| `WebFetch` | Fetch web pages | Research agents |
| `WebSearch` | Search the web | Research agents |
| `SendMessage` | Message teammates | Team members |

### Team Spawn Checklist

Before spawning a team, verify:

- [ ] Each teammate has a clear, non-overlapping scope
- [ ] Spawn prompts include enough context (files, rationale, constraints)
- [ ] File ownership boundaries are explicit
- [ ] Task dependencies are defined (what must finish before what)
- [ ] Model selection matches task complexity
- [ ] Permission mode won't block background work
- [ ] `maxTurns` is set to prevent runaway agents
- [ ] Worktree isolation is enabled if teammates touch overlapping areas
