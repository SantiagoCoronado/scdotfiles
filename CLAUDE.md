# Dotfiles

Multi-platform dotfiles repo (macOS + Arch Linux) using symlink-based installation.

## Structure

- `macos/` - macOS-specific configs (ghostty, git, npm, tmux, sketchybar, karabiner, zsh)
- `linux/` - Linux-specific configs (same layout as macos/)
- `shared/` - Cross-platform configs (atuin, starship, btop, gh, lazygit, thefuck, wezterm)
- `claude/` - Claude Code config (settings, agents, skills, docs) - symlinked to ~/.claude/

## Commands

```
./install.sh --macos    # Symlink all configs for macOS
./install.sh --linux    # Symlink all configs for Linux
./bootstrap-vps.sh <host>  # Full Arch Linux VPS setup from scratch
```

## Symlink conventions

- **Directory symlinks** (rm + ln -sf): tmux, ghostty, sketchybar, karabiner, atuin, wezterm, claude agents/skills/docs
- **File symlinks** (ln -sf into existing dir): git/config, npm/npmrc, btop/btop.conf, gh/config.yml, lazygit/config.yml, thefuck/settings.py
- File-level symlinks are used when the target dir has generated content we don't want to track

## Code intelligence

Prefer LSP over Grep/Glob/Read for code navigation:
- Use `goToDefinition` / `goToImplementation` to jump to source
- Use `findReferences` to see all usages before renaming or changing signatures
- Use `workspaceSymbol` to find definitions across the project
- Use `documentSymbol` to list functions in a file
- Use `hover` for type information
- Use `incomingCalls` / `outgoingCalls` for call hierarchies
- Fall back to Grep/Glob only for text searches (comments, strings, config values)
- Check LSP diagnostics after editing to fix type errors and missing imports immediately

## Rules

- NEVER commit .env files, API tokens, secrets, or credentials
- Platform-specific configs go in macos/ or linux/, never shared/
- Shared configs must work on both platforms (or gracefully degrade)
- The .gitignore blocks: .env*, gh/hosts.yml, karabiner backups, thefuck cache, Claude runtime data
- Test install.sh idempotency after changes (run it twice, no errors)
