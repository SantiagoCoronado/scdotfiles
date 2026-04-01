# Dotfiles Conventions

## Platform organization
- macOS-only configs go in `macos/config/` (ghostty, git, npm, tmux, sketchybar, karabiner)
- Linux-only configs go in `linux/config/` (same structure as macos/)
- Cross-platform configs go in `shared/config/` (, atuin, starship, btop, gh, lazygit, thefuck, wezterm)
- Claude Code config lives in `claude/` (top-level, symlinked to ~/.claude/)

## Symlink patterns
- Use **directory symlinks** (rm -rf + ln -sf) when tracking the entire dir (tmux, ghostty, , sketchybar)
- Use **file symlinks** (ln -sf into mkdir'd target) when the dir has generated content (git/config, btop/btop.conf, gh/config.yml)
- Always update `install.sh` when adding new configs

## Shell config
- zoxide init MUST be at the end of .zshrc (after compinit)
- Platform differences: status-position (bottom on macOS, top on Linux), clipboard tools (pbcopy vs xclip)
- Local overrides go in .zshrc.local (not tracked)

## Tmux
- Theme is brutalist monochrome (black/white/grey) - hand-rolled, no theme plugin
- macOS has prefix-highlight and thumbs plugins; Linux does not
