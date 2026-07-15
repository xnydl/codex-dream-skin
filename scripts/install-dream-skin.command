#!/bin/zsh

set -euo pipefail
SCRIPT_DIR="${0:A:h}"

"$SCRIPT_DIR/check-dream-skin.command"
/bin/mkdir -p "$HOME/Applications"

/bin/ln -sfn "$SCRIPT_DIR/start-after-quit.command" "$HOME/Applications/Codex Dream Skin.command"
/bin/ln -sfn "$SCRIPT_DIR/restore-dream-skin.command" "$HOME/Applications/Codex Dream Skin - Restore.command"

if [[ -d "$HOME/Desktop" ]]; then
  /bin/ln -sfn "$SCRIPT_DIR/start-after-quit.command" "$HOME/Desktop/Codex Dream Skin.command"
  /bin/ln -sfn "$SCRIPT_DIR/restore-dream-skin.command" "$HOME/Desktop/Codex Dream Skin - Restore.command"
fi

print -r -- "Codex Dream Skin 安装完成。双击桌面的 Codex Dream Skin 启动；需要还原时双击 Restore。"
