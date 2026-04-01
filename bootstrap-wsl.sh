#!/usr/bin/env bash
set -euo pipefail

# Bootstrap WSL2 (Ubuntu/Debian) with the full dotfiles setup
# Usage: ./bootstrap-wsl.sh
#
# Run this INSIDE your WSL2 instance.
# It installs all packages, tools, and configs from scratch.

echo "================================"
echo "WSL2 Bootstrap"
echo "================================"

# Detect distro
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="$ID"
else
    echo "Cannot detect distro. Assuming Ubuntu/Debian."
    DISTRO="ubuntu"
fi

echo ">>> Detected distro: $DISTRO"

# ── Package installation ───────────────────────────────────

echo ">>> Updating package lists..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo ">>> Installing system packages via apt..."
sudo apt-get install -y \
    zsh git curl wget unzip build-essential \
    tmux fzf bat ripgrep fd-find ncdu direnv \
    python3 python3-pip nodejs npm

# Packages with different names on apt vs pacman
# bat is installed as 'batcat' on Debian/Ubuntu
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    sudo ln -sf "$(which batcat)" /usr/local/bin/bat
fi

# fd is installed as 'fdfind' on Debian/Ubuntu
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi

# ── Tools not in apt (install from source/binary) ─────────

echo ">>> Installing neovim (latest stable)..."
if ! command -v  &>/dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/-linux-x86_64.tar.gz
    sudo rm -rf /opt/
    sudo tar -C /opt -xzf -linux-x86_64.tar.gz
    sudo ln -sf /opt/-linux-x86_64/bin/ /usr/local/bin/
    rm -f -linux-x86_64.tar.gz
else
    echo "Neovim already installed, skipping."
fi

echo ">>> Installing eza (modern ls)..."
if ! command -v eza &>/dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -y
    sudo apt-get install -y eza
else
    echo "eza already installed, skipping."
fi

echo ">>> Installing lazygit..."
if ! command -v lazygit &>/dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm -f lazygit lazygit.tar.gz
else
    echo "lazygit already installed, skipping."
fi

echo ">>> Installing git-delta..."
if ! command -v delta &>/dev/null; then
    DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    curl -Lo delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
    sudo dpkg -i delta.deb
    rm -f delta.deb
else
    echo "git-delta already installed, skipping."
fi

echo ">>> Installing btop..."
if ! command -v btop &>/dev/null; then
    sudo apt-get install -y btop 2>/dev/null || {
        echo "btop not in apt, installing from snap..."
        sudo snap install btop
    }
else
    echo "btop already installed, skipping."
fi

echo ">>> Installing GitHub CLI..."
if ! command -v gh &>/dev/null; then
    (type -p wget >/dev/null || sudo apt-get install wget -y) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install gh -y
else
    echo "GitHub CLI already installed, skipping."
fi

echo ">>> Installing thefuck..."
if ! command -v thefuck &>/dev/null; then
    pip3 install --user thefuck || sudo pip3 install thefuck
else
    echo "thefuck already installed, skipping."
fi

echo ">>> Installing zoxide..."
if ! command -v zoxide &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
    echo "zoxide already installed, skipping."
fi

# ── Clipboard for WSL2 ────────────────────────────────────

echo ">>> Setting up WSL2 clipboard integration..."
# win32yank bridges WSL2 clipboard to Windows
if ! command -v win32yank.exe &>/dev/null; then
    curl -Lo win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
    unzip -o win32yank.zip win32yank.exe
    sudo mv win32yank.exe /usr/local/bin/
    sudo chmod +x /usr/local/bin/win32yank.exe
    rm -f win32yank.zip
    echo "win32yank installed for clipboard support."
else
    echo "win32yank already available, skipping."
fi

# ── Shell setup ────────────────────────────────────────────

echo ">>> Setting zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo ">>> Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping."
fi

echo ">>> Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# ── Cross-platform installers ─────────────────────────────

echo ">>> Installing Starship prompt..."
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
    echo "Starship already installed, skipping."
fi

echo ">>> Installing Atuin..."
if ! command -v atuin &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
    echo "Atuin already installed, skipping."
fi

echo ">>> Installing mise..."
if ! command -v mise &>/dev/null; then
    curl https://mise.run | sh
else
    echo "mise already installed, skipping."
fi

echo ">>> Installing TPM (Tmux Plugin Manager)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
    echo "TPM already installed, skipping."
fi

# ── Dotfiles ───────────────────────────────────────────────

echo ">>> Cloning dotfiles..."
if [ ! -d "$HOME/dotfiles" ]; then
    git clone git@github.com:Mourey/dotfiles.git "$HOME/dotfiles"
else
    echo "Dotfiles already cloned, updating..."
    git -C "$HOME/dotfiles" pull
fi

echo ">>> Running dotfiles install script..."
cd "$HOME/dotfiles"
chmod +x install.sh
./install.sh --linux

echo ">>> Creating ~/.zshrc.local with WSL2-specific config..."
cat > "$HOME/.zshrc.local" << 'ZSHRC_LOCAL'
# WSL2 clipboard integration (use win32yank instead of xclip)
if command -v win32yank.exe &>/dev/null; then
    alias pbcopy='win32yank.exe -i --crlf'
    alias pbpaste='win32yank.exe -o --lf'
fi

# Windows home directory shortcut
[ -d /mnt/c/Users ] && alias winhome='cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d "\r")'

# Docker (Docker Desktop WSL2 backend)
alias dc="docker compose"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dlogs="docker logs -f"

# System
alias update="sudo apt-get update && sudo apt-get upgrade -y"
ZSHRC_LOCAL

# ── Plugin installation ───────────────────────────────────

echo ">>> Installing Neovim plugins (lazy. sync)..."
 --headless "+Lazy! sync" +qa
echo "Lazy. plugins installed."

echo ">>> Installing Mason LSP servers & formatters..."
 --headless -c "MasonToolsInstallSync" -c "qa"
echo "Mason tools installed."

echo ">>> Installing tmux plugins headlessly..."
if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    "$HOME/.tmux/plugins/tpm/bin/install_plugins"
else
    echo "TPM install_plugins not found, skipping."
fi

# ── Claude Code (optional) ────────────────────────────────

echo ">>> Installing Claude Code..."
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "Claude Code already installed, skipping."
fi

echo ""
echo "================================"
echo "WSL2 bootstrap complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "  1. Close and reopen your WSL2 terminal (or run 'exec zsh')"
echo "  2. Clipboard: win32yank is set up — pbcopy/pbpaste work with Windows"
echo "  3. Optional: add API keys to ~/.claude/.env"
echo ""
