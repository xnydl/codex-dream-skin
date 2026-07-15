# Runtime notes

- The skin launches the Store-installed `ChatGPT.exe` with `--remote-debugging-address=127.0.0.1 --remote-debugging-port=<port>` and injects through CDP.
- The default production port is `9335`; test instances may use another port plus an isolated `--user-data-dir`.
- CDP is bound to loopback. Do not expose it on a LAN interface.
- The injector polls page targets and reinjects after document loads. In-page route changes use a debounced observer plus a low-frequency safety check to avoid CPU churn during streamed tasks.
- `%LOCALAPPDATA%\CodexDreamSkin\state.json` records the port and daemon PID. Logs stay in the same directory.
- If Codex is already running without the chosen debugging port, close it first or explicitly use `-RestartExisting`.
- Store updates are supported because the launcher queries `Get-AppxPackage OpenAI.Codex` on every launch.
- Node.js 22+ is required. Run `scripts/check-dream-skin.ps1` before installation when diagnosing setup failures.
- The CDP port grants local renderer access while the skinned app is running. Do not publish, proxy, or firewall-forward it.
