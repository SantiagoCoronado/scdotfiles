#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> scdotfiles bootstrap"
echo "    Repo: $DOTFILES"
echo ""

# Keep sudo alive for the duration of the script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!
trap "kill $SUDO_PID 2>/dev/null; exit" INT TERM EXIT

# ── 1. Homebrew ───────────────────────────────────────────────────────────────
echo "==> Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for the rest of this script
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  echo "    Installed"
else
  echo "    Already installed"
fi

# ── 2. Dependencies ───────────────────────────────────────────────────────────
echo "==> brew bundle"
brew bundle --file="$DOTFILES/Brewfile"

# ── 3. Oh My Zsh ─────────────────────────────────────────────────────────────
echo "==> Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  git clone --depth=1 https://github.com/zsh-users/zsh-completions          "$ZSH_CUSTOM/plugins/zsh-completions"
  echo "    Installed + plugins cloned"
else
  echo "    Already installed"
fi

# ── 4. Dotfile symlinks ───────────────────────────────────────────────────────
echo "==> Symlinking configs"
OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
  "$DOTFILES/install.sh" --macos
elif [ "$OS" = "Linux" ]; then
  "$DOTFILES/install.sh" --linux
else
  echo "    Unknown OS: $OS — skipping install.sh" >&2
fi

# ── 5. .cursorrules ───────────────────────────────────────────────────────────
echo "==> .cursorrules"
ln -sf "$DOTFILES/.cursorrules" "$HOME/.cursorrules"
echo "    Linked → $HOME/.cursorrules"

# ── 6. Claude Code CLI ───────────────────────────────────────────────────────
echo "==> Claude Code CLI"
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
  echo "    Installed"
else
  echo "    Already installed"
fi

# ── 7. TMux Plugin Manager ───────────────────────────────────────────────────
echo "==> TPM (tmux plugins)"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  echo "    Installed — press prefix+I inside tmux to load plugins"
else
  echo "    Already installed"
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "Done! Open a new terminal or run:"
echo "  source ~/.zshrc"
