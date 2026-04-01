---
description: Review changes and create a commit with a clear message
---
Review the current changes and commit if appropriate.

!`git status --short`

!`git diff --stat`

!`git diff --cached --stat`

1. Look at the staged and unstaged changes
2. If nothing is staged, stage the relevant changed files (never stage .env files or secrets)
3. Write a concise commit message that describes the "why" not the "what"
4. Create the commit
5. Show the result with `git log --oneline -1`

If changes look incomplete or there's nothing meaningful to commit, say so and don't commit.
