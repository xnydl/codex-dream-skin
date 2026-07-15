---
name: codex-dream-skin
description: Apply, launch, verify, repair, update, or restore a full decorative skin for the Codex desktop app on macOS or Windows. Use when the user asks for a Codex theme that goes beyond official color settings, wants the pink-purple Dream/Fiona-style interface, needs the skin reapplied after a Codex update, or needs a safe rollback without modifying the official app or app.asar.
---

# Codex Dream Skin

Apply a reversible renderer skin through Chromium DevTools Protocol while launching the official Codex app. Keep the official application bundle, `WindowsApps`, and `app.asar` unchanged.

## Workflow

1. Detect the operating system before choosing scripts.
2. On Windows, run `scripts/check-dream-skin.ps1`, then `scripts/install-dream-skin.ps1`. Launch through `scripts/start-after-exit.ps1` or the installed shortcut.
3. On macOS, run `scripts/check-dream-skin.command`, then `scripts/install-dream-skin.command`. Launch through `scripts/start-after-quit.command` or the installed shortcut.
4. If Codex is already open without the Dream Skin CDP port, queue the launch and ask the user to quit Codex normally. Never force-kill Codex as part of the default workflow.
5. Verify after launch:
   - Windows: `scripts/verify-dream-skin.ps1 -ScreenshotPath <absolute-path>`
   - macOS: `scripts/verify-dream-skin.command --screenshot <absolute-path>`
   Treat a missing hero, native composer, sidebar skin, or injection marker as failure. The native suggestion count is responsive and may be two to four.
6. Inspect the screenshot against `references/qa-inventory.md`. Verify both the home screen and a normal task before signing off.
7. Restore with `scripts/restore-dream-skin.ps1` on Windows or `scripts/restore-dream-skin.command` on macOS. Use the platform-specific uninstall flag to remove shortcuts.

## Guardrails

- Preserve the official executable/app bundle, package signature, user threads, pets, plugins, and authentication state.
- Do not use the full reference screenshot as a fake whole-window overlay. It is only a cropped hero/polaroid asset; all controls remain live Codex controls.
- Keep the reference image confined to the single top banner and decorative crop. Keep the cards below it as native Codex suggestion buttons with native labels/icons.
- Attach the "选择项目" treatment to Codex's real project-selector toolbar and keep the current project button clickable; never draw a disconnected replacement.
- Keep decorative layers `pointer-events: none` and keep real buttons, navigation, and composer above them.
- On app updates, rerun install and launch. Windows discovers the current Appx package dynamically; macOS discovers `ChatGPT.app` or `Codex.app` in system and user Applications folders.
- If port `9335` is occupied, choose another port consistently for start, verify, and restore.
- Keep the injection daemon running for navigation/reload resilience. State and logs live under `%LOCALAPPDATA%\CodexDreamSkin` on Windows and `~/Library/Application Support/CodexDreamSkin` on macOS.
- Require Node.js 22 or newer because `injector.mjs` uses the built-in Fetch and WebSocket APIs.
- Treat the loopback CDP endpoint as locally sensitive: bind it explicitly to `127.0.0.1` and never expose the port through firewall or router rules.
- Do not copy the macOS ASAR-patching approach used by other themes. Cross-platform support must keep the non-destructive CDP architecture.

## Resources

- `scripts/injector.mjs`: CDP connection, renderer injection, verification, screenshot, and removal.
- `scripts/*.ps1`: Windows preflight, queued launch, install, verify, and restore.
- `scripts/*.command`: macOS preflight, queued launch, install, verify, and restore.
- `assets/dream-skin.css`: full visual layer.
- `assets/renderer-inject.js`: idempotent DOM integration and cleanup.
- `assets/dream-reference.png`: user-provided visual reference used only in cropped decorative regions.
- `references/qa-inventory.md`: required functional and visual signoff coverage.
- `references/runtime-notes.md`: troubleshooting and update behavior.
