# Codex Dream Skin

Windows Codex 桌面版完整换肤工具：顶部使用独立视觉横幅，下方功能卡、项目选择器和输入框继续保留 Codex 原生结构与交互。

> 🎁 **免费领取完整 Skill**<br>
> 前往 [世事宜AI · 免费工具](https://ssyai.xytpark.cn/purchase)，选择 **Codex Dream Skin**。领取后，完整 ZIP 会自动发送到收货邮箱。

![Codex Dream Skin 效果预览](assets/dream-reference.png)

## 特点

- 不使用整张截图覆盖界面，按钮、项目选择器和输入框都可正常操作
- 通过本机 CDP 动态注入，不修改官方 `app.asar` 或 WindowsApps 文件
- 支持 Codex 重启、页面刷新和升级后重新应用
- 提供桌面启动快捷方式与一键恢复
- CDP 仅监听 `127.0.0.1`，安装前会检查环境和端口

## 一键导入 Skill

```powershell
npx skills add xnydl/codex-dream-skin -g -y
```

也可以从 [GitHub Releases](https://github.com/xnydl/codex-dream-skin/releases/latest) 获取完整 ZIP。

## Windows 安装

要求：

- Microsoft Store 安装的 Windows Codex 桌面版
- Node.js 22 LTS 或更新版本
- Windows PowerShell

首次安装：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-dream-skin.ps1
```

以后双击桌面的 **Codex Dream Skin** 启动。需要恢复原版时，双击 **Codex Dream Skin - Restore**。

## 安全边界

- 不替换、不接管、不修改 Codex 官方程序文件
- 不读取或上传账号、任务、聊天记录和登录信息
- 调试端口只绑定本机回环地址，请勿转发到局域网或公网
- 官方升级导致结构变化时，可重新运行安装脚本并获取最新版

## 免费 AI 服务与更多工具

Codex Dream Skin 由 [世事宜AI](https://ssyai.xytpark.cn/) 免费提供。站内还可获取 ChatGPT、Claude、Codex 等 AI 服务与实用工具。

## 免责声明

本项目是第三方界面增强工具，与 OpenAI 无隶属或官方合作关系。Codex、ChatGPT 和 OpenAI 是其各自权利人的商标。
