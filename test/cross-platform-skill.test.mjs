import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync, statSync } from "node:fs";
import { join } from "node:path";
import test from "node:test";

const root = new URL("../", import.meta.url).pathname;
const read = (relativePath) => readFileSync(join(root, relativePath), "utf8");

const macScripts = [
  "scripts/check-dream-skin.command",
  "scripts/install-dream-skin.command",
  "scripts/start-after-quit.command",
  "scripts/start-dream-skin.command",
  "scripts/restore-dream-skin.command",
  "scripts/verify-dream-skin.command",
  "scripts/wait-and-start-macos.sh",
  "scripts/lib/dream-skin-macos.sh",
];

const windowsScripts = [
  "scripts/check-dream-skin.ps1",
  "scripts/install-dream-skin.ps1",
  "scripts/restore-dream-skin.ps1",
  "scripts/start-after-exit.ps1",
  "scripts/start-dream-skin.ps1",
  "scripts/verify-dream-skin.ps1",
  "scripts/wait-and-start-windows.ps1",
];

test("Skill metadata advertises macOS and Windows support", () => {
  const skill = read("SKILL.md");
  assert.match(skill, /macOS or Windows/);
  assert.match(skill, /check-dream-skin\.command/);
  assert.match(skill, /check-dream-skin\.ps1/);
  assert.doesNotMatch(skill, /^compatibility:/m);
});

test("macOS scripts are executable and pass zsh syntax validation", () => {
  for (const relativePath of macScripts) {
    const absolutePath = join(root, relativePath);
    assert.ok(statSync(absolutePath).mode & 0o111, `${relativePath} must be executable`);
    execFileSync("/bin/zsh", ["-n", absolutePath]);
  }
});

test("Windows PowerShell scripts include a UTF-8 BOM for PowerShell 5.1", () => {
  for (const relativePath of windowsScripts) {
    const bytes = readFileSync(join(root, relativePath));
    assert.deepEqual([...bytes.subarray(0, 3)], [0xef, 0xbb, 0xbf], `${relativePath} must start with UTF-8 BOM`);
  }
});

test("both launchers bind CDP to loopback and never patch ASAR", () => {
  const macStart = read("scripts/start-dream-skin.command");
  const windowsStart = read("scripts/start-dream-skin.ps1");
  assert.match(macStart, /--remote-debugging-address=127\.0\.0\.1/);
  assert.match(windowsStart, /--remote-debugging-address=127\.0\.0\.1/);
  for (const relativePath of [...macScripts, "scripts/start-dream-skin.ps1", "scripts/install-dream-skin.ps1"]) {
    assert.doesNotMatch(read(relativePath), /app\.asar|WindowsApps.*(?:Set-Content|Copy-Item|Move-Item)/i);
  }
});

test("queued launchers wait for a normal app exit", () => {
  const macQueue = read("scripts/wait-and-start-macos.sh");
  const windowsQueue = read("scripts/wait-and-start-windows.ps1");
  const windowsInstall = read("scripts/install-dream-skin.ps1");
  assert.match(macQueue, /while dream_skin_app_is_running/);
  assert.match(windowsQueue, /while \(\$true\)/);
  assert.match(windowsInstall, /start-after-exit\.ps1/);
  assert.doesNotMatch(windowsInstall, /-RestartExisting/);
});

test("state files record the injector path before PID cleanup", () => {
  const macLib = read("scripts/lib/dream-skin-macos.sh");
  const windowsStart = read("scripts/start-dream-skin.ps1");
  assert.match(macLib, /injectorPath/);
  assert.match(macLib, /command_line.*injector_path/s);
  assert.match(windowsStart, /injectorPath/);
  assert.match(windowsStart, /CommandLine/);
});

test("README exposes both platform install paths and the storefront CTA", () => {
  const readme = read("README.md");
  assert.match(readme, /## Windows 安装/);
  assert.match(readme, /## macOS 安装/);
  assert.match(readme, /https:\/\/ssyai\.xytpark\.cn\/purchase/);
  assert.match(readme, /npx skills add xnydl\/codex-dream-skin -g -y/);
});
