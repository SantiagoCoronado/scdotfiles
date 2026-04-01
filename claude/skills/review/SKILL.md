---
name: review
description: Run a code review on current changes or a PR. Usage: /review [PR number or branch]
context: fork
---

Run a code review on the current changes.

Target: $ARGUMENTS (default: uncommitted changes)

Use the `code-reviewer` agent to review the changes. Before invoking the agent:

1. Determine the review scope:
   - No arguments: review uncommitted changes (`git diff` + `git diff --cached`)
   - PR number: fetch PR diff with `gh pr diff <number>`
   - Branch name: compare with `git diff main...<branch>`

2. If this is a PR, also fetch:
   - PR description: `gh pr view <number>`
   - Existing review comments: `gh api repos/{owner}/{repo}/pulls/{number}/comments`

3. Pass all context to the `code-reviewer` agent for analysis.

4. Present the review results. For PRs, offer to post the review as a GitHub comment.
