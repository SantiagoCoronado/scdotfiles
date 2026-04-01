---
description: Run install script and verify all symlinks are correct
argument-hint: [--macos | --linux]
---
Run the install script for the specified platform and verify everything is linked correctly.

!`./install.sh $ARGUMENTS`

Now verify all symlinks point to the dotfiles repo:

!`for f in ~/.config/{tmux,ghostty,,atuin,wezterm,sketchybar,karabiner}; do [ -L "$f" ] && echo "OK: $f -> $(readlink "$f")" || echo "MISSING: $f"; done`

!`for f in ~/.config/{git/config,npm/npmrc,btop/btop.conf,gh/config.yml,lazygit/config.yml,thefuck/settings.py,starship.toml}; do [ -L "$f" ] && echo "OK: $f -> $(readlink "$f")" || echo "MISSING: $f"; done`

!`for f in ~/.claude/{settings.json,agents,skills,docs}; do [ -L "$f" ] && echo "OK: $f -> $(readlink "$f")" || echo "MISSING: $f"; done`

Report any missing or broken symlinks. If everything is linked correctly, confirm success.
