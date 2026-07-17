---
name: codex-dream-skin
description: Install, customize, switch, verify, or restore a full adaptive theme for the Codex desktop app on macOS or Windows. Use when the user wants a Codex theme beyond official color settings, wants to turn a personal image into a full-window Codex wallpaper with adaptive readability, needs the skin reapplied after a Codex update, wants to switch saved themes from the menu bar or tray, or needs a safe rollback without modifying the official app or app.asar.
---

# Codex Dream Skin (cross-platform router)

Reversible full-window theming for the official Codex desktop app through loopback Chromium DevTools Protocol. Never modify the official `.app`, `WindowsApps`, `app.asar`, or code signatures.

This repository ships two self-contained platform engines. Detect the operating system first, then follow the platform skill:

- **macOS** → [`macos/SKILL.md`](./macos/SKILL.md) (Codex Dream Skin Studio: install, customize-from-image, menu bar, hot theme switch, verify, restore)
- **Windows** → [`windows/SKILL.md`](./windows/SKILL.md) (Store-app discovery, tray, theme repository, verify, restore)

## Workflow

1. Detect the OS before choosing scripts. Never mix platform directories.
2. macOS: run `macos/Install Codex Dream Skin.command` (or `macos/scripts/install-dream-skin-macos.sh`), then use the Desktop launchers or `switch-theme-macos.sh --id preset-ssyai-dream`.
3. Windows: run `windows/scripts/install-dream-skin.ps1`, then `windows/scripts/start-dream-skin.ps1`. The tray controls apply/pause, background import, saved themes, and full restore.
4. Verify after launch with the platform verify script and inspect against the platform `references/qa-inventory.md`.
5. Restore the official appearance with the platform restore entry point.

## Guardrails (both platforms)

- Preserve the official executable, package signature, user threads, pets, plugins, and authentication state.
- Theme images must be UI-free wallpapers; never import an effect screenshot as a background.
- Keep decorative layers `pointer-events: none`; native controls stay interactive above them.
- Bind CDP to `127.0.0.1` only and treat the port as locally sensitive; prefer Restore when done.
- Require explicit user authorization before restarting an already-running Codex instance.

## Bundled default

The featured preset `preset-ssyai-dream`（世事宜梦境）is procedurally generated abstract art (2560 × 1440, no photos, no third-party IP). macOS seeds it into the theme library; Windows seeds it as the active theme and a saved theme.

Provided free by 世事宜AI: https://ssyai.xytpark.cn/purchase
