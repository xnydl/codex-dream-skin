# Notices

Codex Dream Skin Studio is an **unofficial** customization project and is **not affiliated with, endorsed by, or sponsored by OpenAI**.

## Software license

The MIT License in `LICENSE` applies to the **software source code** in this repository (scripts, CSS, injectors, docs that describe the software, and the abstract demo asset generated for this repo).

It does **not** grant rights to:

- OpenAI or Codex trademarks, product names, logos, or trade dress
- Official Codex / ChatGPT application binaries, `.app` bundles, or `app.asar`
- Any user-supplied images or third-party artwork you drop into a theme
- Character likenesses, franchise art, or celebrity imagery

## Demo artwork

`assets/portal-hero.png` is original abstract geometric art generated for this open-source repository (no characters). Replace it with your own image before shipping a branded theme to customers.

## 世事宜AI distribution note

This distribution is maintained by 世事宜AI (https://ssyai.xytpark.cn) and is
based on the open-source Codex Dream Skin Studio project
(https://github.com/Fei-Away/Codex-Dream-Skin, MIT). Changes in this
distribution:

- The maintainer-supplied "Romantic Rose" preset and related photographic
  material from the upstream repository are **not included**. All bundled
  preset artwork here is procedurally generated abstract art
  (`presets/generate-presets.mjs`, `presets/generate-ssyai-preset.mjs`) with
  no photos, likenesses, or third-party IP.
- Default preset and promo metadata reference 世事宜AI instead of upstream
  sponsors.

## Community preset artwork

`presets/preset-caishen-readable/background.jpg` is a public-safe community
theme background contributed from `ChannelerH/codex-skin-packs`. It contains
original/generated artwork only and does not include private Codex workspace
screenshots, sidebars, task names, chats, file paths, or project files.

## Runtime

This project does not redistribute Node.js. At runtime it validates and uses the Node.js executable already signed and bundled inside the user's official Codex desktop application.

## Security model

Themes are applied through Chromium DevTools Protocol on **loopback only**. While a themed session is running, treat the local debugging port as sensitive: do not run untrusted local software that could attach to it. Use the Restore launcher to tear down the themed session and debugging port.
