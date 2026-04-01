---
paths:
  - "**/*.json"
  - "**/*.yml"
  - "**/*.yaml"
  - "**/*.toml"
  - "**/*.conf"
  - "**/*.sh"
  - "**/*.zshrc"
  - "**/*.zprofile"
---
# Security Rules

- NEVER commit API keys, tokens, passwords, or credentials
- NEVER commit .env files or files matching .env.*
- NEVER commit gh/hosts.yml (contains OAuth tokens)
- NEVER commit karabiner/automatic_backups/ or karabiner/assets/
- NEVER commit Claude runtime data (sessions, telemetry, cache, history)
- Always check `git diff --cached` for secrets before committing
- Raycast config contains API tokens and must never be tracked
- When in doubt, add the file pattern to .gitignore first
