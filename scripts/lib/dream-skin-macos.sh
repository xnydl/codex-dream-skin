#!/bin/zsh

set -euo pipefail

DREAM_SKIN_LIB_PATH="${${(%):-%N}:A}"
DREAM_SKIN_ROOT="${DREAM_SKIN_LIB_PATH:h:h:h}"
DREAM_SKIN_SCRIPTS="$DREAM_SKIN_ROOT/scripts"
DREAM_SKIN_INJECTOR="$DREAM_SKIN_SCRIPTS/injector.mjs"
DREAM_SKIN_STATE_ROOT="$HOME/Library/Application Support/CodexDreamSkin"
DREAM_SKIN_STATE_PATH="$DREAM_SKIN_STATE_ROOT/state.json"
DREAM_SKIN_LOG_PATH="$DREAM_SKIN_STATE_ROOT/injector.log"
DREAM_SKIN_ERROR_LOG_PATH="$DREAM_SKIN_STATE_ROOT/injector-error.log"

dream_skin_find_app() {
  local candidate
  for candidate in \
    "/Applications/ChatGPT.app" \
    "/Applications/Codex.app" \
    "$HOME/Applications/ChatGPT.app" \
    "$HOME/Applications/Codex.app"; do
    if [[ -d "$candidate" && ( -x "$candidate/Contents/MacOS/ChatGPT" || -x "$candidate/Contents/MacOS/Codex" ) ]]; then
      print -r -- "$candidate"
      return 0
    fi
  done
  return 1
}

dream_skin_require_node() {
  local node_path major
  node_path="$(command -v node 2>/dev/null || true)"
  [[ -n "$node_path" ]] || { print -u2 -- "未找到 Node.js，请先安装 Node.js 22 LTS。"; return 1; }
  major="$($node_path -p 'Number(process.versions.node.split(".")[0])')"
  (( major >= 22 )) || { print -u2 -- "需要 Node.js 22 或更新版本，当前为 $($node_path -v)。"; return 1; }
  print -r -- "$node_path"
}

dream_skin_port_has_codex() {
  local port="$1" node_path response
  node_path="$(dream_skin_require_node)" || return 1
  response="$(/usr/bin/curl -fsS --max-time 1 "http://127.0.0.1:${port}/json/list" 2>/dev/null || true)"
  [[ -n "$response" ]] || return 1
  DREAM_TARGETS_JSON="$response" "$node_path" -e '
    const targets = JSON.parse(process.env.DREAM_TARGETS_JSON);
    process.exit(targets.some((item) => item?.type === "page" && String(item?.url || "").startsWith("app://")) ? 0 : 1);
  '
}

dream_skin_port_is_used() {
  /usr/sbin/lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1
}

dream_skin_app_is_running() {
  local app_path="$1"
  /bin/ps -axo command= | /usr/bin/awk -v prefix="$app_path/Contents/" 'index($0, prefix) { found=1; exit } END { exit found ? 0 : 1 }'
}

dream_skin_stop_recorded_injector() {
  local node_path pid injector_path command_line
  [[ -f "$DREAM_SKIN_STATE_PATH" ]] || return 0
  node_path="$(dream_skin_require_node)" || return 0
  pid="$($node_path -e '
    const fs=require("fs");
    try { const s=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); process.stdout.write(String(s.injectorPid||"")); } catch {}
  ' "$DREAM_SKIN_STATE_PATH")"
  injector_path="$($node_path -e '
    const fs=require("fs");
    try { const s=JSON.parse(fs.readFileSync(process.argv[1],"utf8")); process.stdout.write(String(s.injectorPath||"")); } catch {}
  ' "$DREAM_SKIN_STATE_PATH")"
  [[ "$pid" == <-> && -n "$injector_path" ]] || return 0
  command_line="$(/bin/ps -p "$pid" -o command= 2>/dev/null || true)"
  if [[ "$command_line" == *"node"* && "$command_line" == *"$injector_path"* ]]; then
    /bin/kill "$pid" 2>/dev/null || true
  else
    print -u2 -- "忽略旧 PID $pid：它已不再是 Codex Dream Skin 注入进程。"
  fi
}

dream_skin_write_state() {
  local node_path="$1" port="$2" pid="$3" app_path="$4" temp_path
  /bin/mkdir -p "$DREAM_SKIN_STATE_ROOT"
  temp_path="$DREAM_SKIN_STATE_PATH.$$.tmp"
  "$node_path" -e '
    const fs=require("fs");
    const state={
      platform:"macos",
      port:Number(process.argv[2]),
      injectorPid:Number(process.argv[3]),
      injectorPath:process.argv[4],
      appPath:process.argv[5],
      skillRoot:process.argv[6],
      startedAt:new Date().toISOString()
    };
    fs.writeFileSync(process.argv[1], JSON.stringify(state,null,2)+"\n", {mode:0o600});
  ' "$temp_path" "$port" "$pid" "$DREAM_SKIN_INJECTOR" "$app_path" "$DREAM_SKIN_ROOT"
  /bin/mv -f "$temp_path" "$DREAM_SKIN_STATE_PATH"
}
