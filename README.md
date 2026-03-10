# tmux-config

Personal tmux configuration with plugin management via [tpm](https://github.com/tmux-plugins/tpm) and an auto-attach shell function.

## Plugins

- **tpm** — plugin manager
- **tmux-resurrect** — persist and restore sessions across restarts
- **tmux-cpu** — CPU/RAM stats in the status bar

## Install

```bash
git clone https://github.com/zarei-dev/tmux-config.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
source ~/.bashrc
```

`setup.sh` will:
1. Install tmux (apt) if missing
2. Symlink `.tmux.conf` to `~/.tmux.conf` (existing file backed up)
3. Clone tpm and install all plugins
4. Add an auto-attach `tmux()` function to `~/.bashrc`

## Auto-Attach

After setup, typing `tmux` with no arguments will reattach to the last session or create a new one. Pass arguments normally (e.g. `tmux ls`) and they work as expected.

## Key Bindings

| Keys | Action |
|------|--------|
| `prefix + r` | Reload config |
| `prefix + \|` | Split vertical (current path) |
| `prefix + -` | Split horizontal (current path) |
| `prefix + c` | New window (current path) |
| `Alt + Arrow` | Navigate panes (no prefix) |
| `Shift + Arrow` | Switch windows (no prefix) |
| `prefix + Ctrl + Arrow` | Resize pane |

Default prefix is `Ctrl + b`.
