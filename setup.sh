#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
TMUX_CONF="$HOME/.tmux.conf"
SENTINEL="# >>> tmux-auto-attach >>>"

# Detect user's shell rc file
case "$(basename "${SHELL:-/bin/bash}")" in
    zsh)  SHELL_RC="$HOME/.zshrc" ;;
    *)    SHELL_RC="$HOME/.bashrc" ;;
esac

echo "==> tmux-config setup"

# --- Install tmux if missing ---
if ! command -v tmux &>/dev/null; then
    echo "Installing tmux..."
    sudo apt update -qq && sudo apt install -y tmux
else
    echo "tmux already installed ($(tmux -V))"
fi

# --- Symlink .tmux.conf ---
if [ -L "$TMUX_CONF" ]; then
    echo "Removing existing symlink $TMUX_CONF"
    rm "$TMUX_CONF"
elif [ -f "$TMUX_CONF" ]; then
    echo "Backing up existing $TMUX_CONF → ${TMUX_CONF}.bak"
    mv "$TMUX_CONF" "${TMUX_CONF}.bak"
fi
ln -s "$REPO_DIR/.tmux.conf" "$TMUX_CONF"
echo "Symlinked $TMUX_CONF → $REPO_DIR/.tmux.conf"

# --- Install tpm ---
if [ -d "$TPM_DIR" ]; then
    echo "tpm already installed"
else
    echo "Cloning tpm..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# --- Install plugins ---
echo "Installing plugins..."
STARTED_SERVER=false
if ! tmux list-sessions &>/dev/null; then
    tmux new-session -d -s _setup
    STARTED_SERVER=true
fi
# Ensure TMUX_PLUGIN_MANAGER_PATH is set in the server environment
# (set-environment in .tmux.conf may not take effect without an active client)
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
"$TPM_DIR/bin/install_plugins"
if [ "$STARTED_SERVER" = true ]; then
    tmux kill-server 2>/dev/null || true
else
    tmux source-file "$TMUX_CONF"
    echo "Reloaded tmux config"
fi

# --- Add auto-attach function to shell rc ---
if grep -qF "$SENTINEL" "$SHELL_RC" 2>/dev/null; then
    echo "Auto-attach function already in $SHELL_RC"
else
    echo "Adding auto-attach function to $SHELL_RC"
    cat >> "$SHELL_RC" << 'RCEOF'

# >>> tmux-auto-attach >>>
# Remove any existing tmux alias so the function can be defined
unalias tmux 2>/dev/null || true
tmux() {
    if [ -n "${TMUX:-}" ]; then echo "Already inside tmux."; return 0; fi
    if [ $# -eq 0 ]; then
        command tmux attach-session 2>/dev/null || command tmux new-session
    else
        command tmux "$@"
    fi
}
# <<< tmux-auto-attach <<<
RCEOF
fi

echo "==> Done! Run 'source $SHELL_RC' then type 'tmux' to start."
