#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Determine platform
if [[ "$1" == "--macos" ]]; then
    PLATFORM="macos"
elif [[ "$1" == "--linux" ]]; then
    PLATFORM="linux"
else
    echo "Usage: ./install.sh [--macos | --linux]"
    exit 1
fi

PLATFORM_DIR="$DOTFILES_DIR/$PLATFORM"
SHARED_DIR="$DOTFILES_DIR/shared"

echo "Installing dotfiles for $PLATFORM from $DOTFILES_DIR"

mkdir -p "$CONFIG_DIR"/{git,npm,gh,btop,lazygit,thefuck}
mkdir -p "$HOME/.claude"

# Shell files (platform-specific + shared)
ln -sf "$PLATFORM_DIR/zshrc" "$HOME/.zshrc"
ln -sf "$PLATFORM_DIR/zprofile" "$HOME/.zprofile"
ln -sf "$SHARED_DIR/zshenv" "$HOME/.zshenv"

# Platform-specific configs
ln -sf "$PLATFORM_DIR/config/git/config" "$CONFIG_DIR/git/config"
ln -sf "$PLATFORM_DIR/config/npm/npmrc" "$CONFIG_DIR/npm/npmrc"

# Platform-specific directories
for dir in tmux ghostty; do
    rm -rf "$CONFIG_DIR/$dir"
    ln -sf "$PLATFORM_DIR/config/$dir" "$CONFIG_DIR/$dir"
done

# macOS-only directories
if [[ "$PLATFORM" == "macos" ]]; then
    for dir in sketchybar karabiner; do
        rm -rf "$CONFIG_DIR/$dir"
        ln -sf "$PLATFORM_DIR/config/$dir" "$CONFIG_DIR/$dir"
    done
fi

# Shared configs
ln -sf "$SHARED_DIR/config/starship.toml" "$CONFIG_DIR/starship.toml"
rm -rf "$CONFIG_DIR/"
ln -sf "$SHARED_DIR/config/" "$CONFIG_DIR/"
rm -rf "$CONFIG_DIR/atuin"
ln -sf "$SHARED_DIR/config/atuin" "$CONFIG_DIR/atuin"

# Shared single-file configs
ln -sf "$SHARED_DIR/config/btop/btop.conf" "$CONFIG_DIR/btop/btop.conf"
ln -sf "$SHARED_DIR/config/gh/config.yml" "$CONFIG_DIR/gh/config.yml"
ln -sf "$SHARED_DIR/config/lazygit/config.yml" "$CONFIG_DIR/lazygit/config.yml"
ln -sf "$SHARED_DIR/config/thefuck/settings.py" "$CONFIG_DIR/thefuck/settings.py"

# Shared directory configs
rm -rf "$CONFIG_DIR/wezterm"
ln -sf "$SHARED_DIR/config/wezterm" "$CONFIG_DIR/wezterm"

# Claude Code configuration
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
rm -rf "$HOME/.claude/agents"
ln -sf "$DOTFILES_DIR/claude/agents" "$HOME/.claude/agents"
rm -rf "$HOME/.claude/skills"
ln -sf "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"
rm -rf "$HOME/.claude/docs"
ln -sf "$DOTFILES_DIR/claude/docs" "$HOME/.claude/docs"
rm -rf "$HOME/.claude/scripts"
ln -sf "$DOTFILES_DIR/claude/scripts" "$HOME/.claude/scripts"
rm -rf "$HOME/.claude/commands"
ln -sf "$DOTFILES_DIR/claude/commands" "$HOME/.claude/commands"
rm -rf "$HOME/.claude/rules"
ln -sf "$DOTFILES_DIR/claude/rules" "$HOME/.claude/rules"
rm -rf "$HOME/.claude/hooks"
ln -sf "$DOTFILES_DIR/claude/hooks" "$HOME/.claude/hooks"

echo "Dotfiles installed successfully for $PLATFORM!"
echo "Run: source ~/.zshrc"
