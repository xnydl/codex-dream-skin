# 预设主题 · Preset packs

这个目录放 **Codex Dream Skin 的内置预设主题**。安装时 `install-dream-skin-macos.sh` 会把每个 `preset-*/` 幂等地播种到用户主题库 `~/Library/Application Support/CodexDreamSkinStudio/themes/`，装完即可在**菜单栏「已保存的主题」**或 `switch-theme-macos.sh --id <id>` 里直接切换。

> This folder holds the bundled preset themes. Install seeds each `preset-*/` into the user theme library, so a fresh install ships with ready-to-use skins.

## 置顶：世事宜梦境（本发行版默认）

`preset-ssyai-dream/`（世事宜梦境）是本发行版的置顶预设：`2560 × 1440`（16:9）程序化生成的粉紫梦幻光晕，左侧低信息留白承载 Codex 原生内容，主光斑集中在右侧。由 [`generate-ssyai-preset.mjs`](./generate-ssyai-preset.mjs) 确定性生成（纯 Node + zlib，无照片、无人物、无第三方 IP），重跑输出字节一致。

安装后可直接切换：

```bash
~/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh \
  --id preset-ssyai-dream
```

Windows 端的默认壁纸（`windows/assets/dream-reference.jpg`）与本预设同源同字节。

## 社区预设：财神护航 · 清爽可读

`preset-caishen-readable/` 是一套 public-safe 财神主题预设：主视觉放在右侧，
左侧留出低信息阅读区，任务页使用更安静的 banner 模式。背景不包含 Codex
私有截图、任务名、聊天、侧栏或文件路径。

安装后可直接切换：

```bash
~/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh \
  --id preset-caishen-readable
```

## 一套预设的结构

```
preset-<slug>/
├── theme.json        # schemaVersion 1，与 assets/theme.json 同一格式
└── background.jpg    # 背景图（横向，JPEG）
```

- 目录名与 `theme.json` 的 `id` **必须**都是 `preset-<slug>` 形式（`slug` 用小写英文 + 连字符）。播种只管理 `preset-*`，绝不会碰用户自己「换一张图」保存的 `custom-*` 主题。
- `image` 字段只能是**本目录内**的文件名（不能是路径），格式 `png` / `jpg` / `jpeg` / `webp`，≤ 16 MB（建议 < 1 MB）。
- 人物/场景背景优先提交 `2560 × 1440`（16:9）母版；主视觉放在右侧约 58%～88%，左侧约 50%～58% 保持低信息、低对比。禁止把效果截图、窗口 mockup 或任何带 UI 的图片命名为 `background.*`。

## 素材红线（务必阅读）

内置预设会随仓库分发，**不是**「个人本地示意」。为避免把维护者和使用者拖进法律风险，只接受：

- ✅ **原创**或你**拥有授权**的图像；
- ✅ 明确 **CC0 / 公有领域 / 允许再分发**的素材；
- ✅ 纯程序化生成的抽象 / 渐变 / 几何背景（见下）。
- ✅ 原创虚构的成年人物形象，且能说明生成/授权来源、没有模仿可识别真人。

除非维护者事先完成独立权利审核并在 `NOTICE.md` 逐项记录，否则**不接受**（PR 会被拒绝）：

- ❌ 真人肖像（明星、网红、AV 演员等）——涉肖像权，且本仓库带 MIT 与商业赞助；
- ❌ 受版权保护的动漫 / 游戏 / 影视角色与截图；
- ❌ 任何你无权再分发的第三方素材。

提交预设即视为你声明：对该素材拥有分发与再授权的权利。

## 两种贡献方式

### A. 程序化生成（推荐，零版权）

`generate-presets.mjs` 是一个**纯 Node + 内置 zlib** 的确定性生成器（无第三方依赖），用多层渐变 + 光晕 + 暗角画出五套抽象背景，再用 macOS `sips` 压成 JPEG。同样的输入永远产出同样的字节，所以提交的资产 diff 稳定。它只管理脚本 `PRESETS` 数组中的程序化主题，不会处理或覆盖社区贡献的精选主题。

加一套：在 `PRESETS` 数组追加一项（`slug` / `name` / `bg` / `lights` / `colors` …），然后：

```bash
node macos/presets/generate-presets.mjs
```

- 深色底用默认 `screen` 混合；浅色底请设 `blend: "tint"`（`screen` 在亮底上几乎不显光晕）。
- 用 Quick Look 或直接打开 `background.jpg` 核对观感；左侧留一片相对干净的区域给原生首页标题。

### B. 直接提供图片

没有 mac 或想用自制原图，也可以直接放 `preset-<slug>/background.jpg` + 手写 `theme.json`（照抄任一现有预设改配色即可）。

生成纯背景前建议直接使用 [`docs/reference-background-prompt-guide.md`](../../docs/reference-background-prompt-guide.md) 的 16:9 通用模板、浅/暗兼容约束和负面词；八种概念图的逐张拆解另见 [`docs/background-generation-prompts.md`](../../docs/background-generation-prompts.md)。

## 提交前自检

```bash
# 单独校验一套预设是否是合法可注入的主题包
node macos/scripts/injector.mjs --check-payload --theme-dir macos/presets/preset-<slug>/

# 跑完整测试（含预设合法性 + 播种幂等）
cd macos && npm test
```

`theme.json` 字段含义见 `../assets/theme.json` 与 `scripts/write-theme.mjs`；`colors` 十个键请与背景图协调（`accent` / `secondary` / `highlight` 会体现在原生控件的强调色上）。
