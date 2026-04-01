---
description: Review all uncommitted dotfile changes before committing
---
## Current status

!`git status`

## Changes

!`git diff`

## Untracked files

!`git ls-files --others --exclude-standard`

Review the above changes for:
1. Accidentally included secrets, tokens, or .env files
2. Platform-specific configs placed in the wrong directory (macos/ vs linux/ vs shared/)
3. Missing install.sh updates for new configs
4. Missing .gitignore rules for generated files
5. Consistency between macOS and Linux versions

Give specific feedback per file. If everything looks good, say so.
