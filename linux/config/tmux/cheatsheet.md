# Tmux Cheat Sheet

**Prefix:** `Ctrl-a` (C-a)

> **Notation:** `C-` = Ctrl, `M-` = Alt/Meta, `S-` = Shift

---

## Sessions

### CLI Commands

| Command | Description |
|---------|-------------|
| `tmux new -s name` | Create new session with name |
| `tmux ls` | List all sessions |
| `tmux attach -t name` | Attach to session |
| `tmux kill-session -t name` | Kill session |

### Session Navigation (prefix + key)

| Key | Description |
|-----|-------------|
| `o` | **Sessionx** - fuzzy session picker (zoxide integrated) |
| `S` | Choose session (built-in picker) |
| `C-a` | Last window (toggle back) |
| `C-d` | Detach from session |

### Session Killing (prefix + key)

| Key | Description |
|-----|-------------|
| `X` | Kill current session (with confirmation) |
| `Q` | FZF session picker to kill |
| `M-x` | Kill all OTHER sessions (keep current) |

---

## Windows

| Key | Description |
|-----|-------------|
| `C-c` | New window (opens in $HOME) |
| `r` | Rename window |
| `w` | List windows |
| `"` | Choose window (interactive picker) |
| `H` | Previous window |
| `L` | Next window |
| `C-a` | Toggle last window |

---

## Panes

### Split

| Key | Description |
|-----|-------------|
| `s` | Split horizontal (top/bottom) |
| `v` | Split vertical (left/right) |
| `\|` | Split vertical (alternative) |

### Navigate

| Key | Description |
|-----|-------------|
| `h` | Move left |
| `j` | Move down |
| `k` | Move up |
| `l` | Move right |
| `M-Left` | Move left (no prefix needed) |
| `M-Right` | Move right (no prefix needed) |
| `M-Up` | Move up (no prefix needed) |
| `M-Down` | Move down (no prefix needed) |

### Resize (repeatable - press prefix once, then repeat key)

| Key | Description |
|-----|-------------|
| `C-h` | Resize left by 5 |
| `C-j` | Resize down by 5 |
| `C-k` | Resize up by 5 |
| `C-l` | Resize right by 5 |
| `S-Left` | Resize left by 5 |
| `S-Down` | Resize down by 5 |
| `S-Up` | Resize up by 5 |
| `S-Right` | Resize right by 5 |

### Actions

| Key | Description |
|-----|-------------|
| `c` | Kill pane |
| `z` | Toggle zoom (fullscreen pane) |
| `x` | Swap pane down |
| `*` | Sync panes (type in all simultaneously) |
| `P` | Toggle pane border status |

---

## Plugins

| Plugin | Key | Description |
|--------|-----|-------------|
| **Sessionx** | `o` | Fuzzy session picker with zoxide & preview |
| **Floax** | `p` | Toggle floating pane |
| **tmux-fzf** | `F` | FZF menu (sessions/windows/panes/commands) |
| **tmux-thumbs** | `Space` | Vimium-style hint picker for text |
| **fzf-url** | `u` | Extract & open URLs from pane |
| **Extrakto** | `Tab` | Fuzzy find & extract text from scrollback |
| **Resurrect** | `C-s` | Save session state |
| **Resurrect** | `C-r` | Restore session state |
| **Continuum** | - | Auto-saves sessions (background) |
| **Yank** | (copy mode) | Clipboard integration |

### Sessionx Internal Bindings

While inside the sessionx picker (`prefix + o`):

| Key | Description |
|-----|-------------|
| `Enter` | Switch to selected session |
| `C-y` | Create new session with zoxide path |
| `C-d` | Delete selected session |
| `C-x` | Kill selected session |
| `C-r` | Rename selected session |
| `C-w` | Switch to window mode |
| `C-e` | Expand preview |
| `C-n/C-p` | Navigate up/down |
| `Esc` | Cancel |

### tmux-fzf Menu Options

Press `prefix + F` to open FZF menu:
- **session** - manage sessions
- **window** - manage windows
- **pane** - manage panes
- **command** - run tmux commands
- **keybinding** - search keybindings
- **clipboard** - access clipboard history

### Floax Settings

| Setting | Value |
|---------|-------|
| Size | 80% x 80% |
| Border | magenta |
| Text | blue |
| Change path | enabled |

### Extrakto Filters

While in extrakto picker (`prefix + Tab`):

| Key | Description |
|-----|-------------|
| `Tab` | Cycle through filters (word/path/url/line) |
| `C-f` | Toggle filter mode |
| `C-g` | Grab area mode |
| `C-l` | Filter: lines |
| `C-o` | Open selected item |
| `C-i` | Insert selected item |
| `Enter` | Copy to clipboard |

---

## Copy Mode (vi keys)

Enter with `prefix + [`

### Navigation

| Key | Description |
|-----|-------------|
| `h/j/k/l` | Move cursor |
| `w/b` | Word forward/back |
| `0/$` | Start/end of line |
| `g/G` | Top/bottom of buffer |
| `C-u/C-d` | Page up/down |
| `/` | Search forward |
| `?` | Search backward |
| `n/N` | Next/prev search result |

### Selection & Copy

| Key | Description |
|-----|-------------|
| `v` | Start selection |
| `V` | Select line |
| `y` | Yank selection (to clipboard via tmux-yank) |
| `Y` | Yank line |
| `Enter` | Copy and exit |
| `q` | Exit copy mode |

---

## Utility

| Key | Description |
|-----|-------------|
| `R` | Reload tmux.conf |
| `K` | Clear screen (send clear + enter) |
| `:` | Command prompt |
| `C-l` | Refresh client |
| `C-x` | Lock server |

---

## Status Bar (Catppuccin)

| Position | Content |
|----------|---------|
| Left | Session name |
| Center | Window list |
| Right | Directory, Time (HH:MM) |

Window indicator shows `()` when zoomed.

---

## Quick Reference

```
┌─────────────────────────────────────────────────────────────┐
│  TMUX QUICK REFERENCE                    Prefix: Ctrl-a    │
├─────────────────────────────────────────────────────────────┤
│  SESSIONS                    │  PANES                      │
│  C-a o    Sessionx picker    │  C-a s    Split horizontal  │
│  C-a S    Choose session     │  C-a v    Split vertical    │
│  C-a C-a  Last window        │  C-a hjkl Navigate          │
│  C-a X    Kill session       │  C-a c    Kill pane         │
│  C-a C-d  Detach             │  C-a z    Zoom toggle       │
├──────────────────────────────┼─────────────────────────────┤
│  WINDOWS                     │  RESIZE (repeatable)        │
│  C-a C-c  New window         │  C-a C-hjkl  Resize ±5      │
│  C-a H/L  Prev/Next          │  M-arrows    No prefix nav  │
│  C-a w    List windows       │  S-arrows    Resize ±5      │
├──────────────────────────────┼─────────────────────────────┤
│  PLUGINS                     │  COPY MODE (prefix + [)     │
│  C-a o    Sessionx           │  v         Start select     │
│  C-a p    Floax (float)      │  y         Yank             │
│  C-a F    tmux-fzf menu      │  /         Search           │
│  C-a u    URL picker         │  q         Exit             │
│  C-a Space  Thumbs hints     │                             │
│  C-a Tab  Extrakto (text)    │                             │
├──────────────────────────────┴─────────────────────────────┤
│  C-a C-s  Save session       │  C-a C-r  Restore session   │
│  C-a R    Reload config      │  C-a K    Clear screen      │
└─────────────────────────────────────────────────────────────┘
```

---

## Common Workflows

### Start a New Project Session
```bash
tmux new -s myproject
# or inside tmux: C-a o → type project name → C-y (creates with zoxide)
```

### Navigate Efficiently
```bash
C-a o          # Switch sessions with fuzzy search
M-arrows       # Quick pane navigation (no prefix!)
C-a z          # Zoom current pane for focus
```

### Session Cleanup
```bash
C-a Q          # FZF picker to select & kill sessions
C-a M-x        # Kill all sessions except current
C-a X          # Kill current session (with confirm)
```

### Copy Text
```bash
C-a [          # Enter copy mode
v              # Start selection
y              # Yank to clipboard
# Paste with system clipboard (Cmd+V / Ctrl+V)
```
