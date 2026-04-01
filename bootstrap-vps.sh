#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a VPS with the full dotfiles setup
# Usage: ./bootstrap-vps.sh <ssh-host>
# Example: ./bootstrap-vps.sh moujo
#
# Strategy: scp a remote script to the VPS, then ssh -t to execute it.
# This keeps stdin free for the TTY so sudo can prompt for a password.

HOST="${1:?Usage: $0 <ssh-host>}"
REMOTE_SCRIPT=$(mktemp)
LOCAL_CLEANUP() { rm -f "$REMOTE_SCRIPT"; }
trap LOCAL_CLEANUP EXIT

cat > "$REMOTE_SCRIPT" << 'REMOTE_SCRIPT_BODY'
#!/usr/bin/env bash
set -euo pipefail

echo ">>> Installing system packages via pacman..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed \
    neovim tmux fzf zoxide bat eza glow ncdu lazygit ripgrep fd git-delta xclip direnv thefuck \
    btop github-cli \
    base-devel npm unzip wget curl

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

echo ">>> Cloning dotfiles..."
if [ ! -d "$HOME/dotfiles" ]; then
    git clone git@github-mourey:Mourey/dotfiles.git "$HOME/dotfiles"
else
    echo "Dotfiles already cloned, updating..."
    git -C "$HOME/dotfiles" pull
fi

echo ">>> Running dotfiles install script..."
cd "$HOME/dotfiles"
chmod +x install.sh
./install.sh --linux

echo ">>> Creating ~/.zshrc.local with VPS-specific aliases..."
cat > "$HOME/.zshrc.local" << 'ZSHRC_LOCAL'
# Docker shortcuts
alias dc="docker compose"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dlogs="docker logs -f"

# Nginx proxy management
alias nginx-reload="cd ~/nginx-proxy && docker compose exec nginx nginx -s reload"
alias nginx-test="cd ~/nginx-proxy && docker compose exec nginx nginx -t"

# System
alias update="sudo pacman -Syu"
ZSHRC_LOCAL

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

echo "================================"
echo "VPS bootstrap complete!"
echo "Log out and back in (or run 'exec zsh') to activate everything."
REMOTE_SCRIPT_BODY

echo "Bootstrapping VPS: $HOST"
echo "================================"

echo ">>> Copying bootstrap script to $HOST..."
scp "$REMOTE_SCRIPT" "$HOST:/tmp/bootstrap-vps-remote.sh"

echo ">>> Running bootstrap on $HOST (sudo will prompt for password)..."
ssh -t "$HOST" "chmod +x /tmp/bootstrap-vps-remote.sh && /tmp/bootstrap-vps-remote.sh; rm -f /tmp/bootstrap-vps-remote.sh"

echo "Done! SSH into $HOST to verify."
