[CmdletBinding()]
param(
  [int]$Port = 9335
)

$ErrorActionPreference = 'Stop'
$issues = @()

if ($PSVersionTable.PSVersion.Major -lt 5) {
  $issues += '需要 Windows PowerShell 5.1 或更高版本。'
}

$node = Get-Command node.exe -ErrorAction SilentlyContinue
if (-not $node) {
  $issues += '未找到 Node.js。请先安装 Node.js 22 LTS：https://nodejs.org/'
} else {
  $major = 0
  try { $major = [int]((& $node.Source --version).TrimStart('v').Split('.')[0]) } catch {}
  if ($major -lt 22) {
    $issues += "Node.js 版本过低（当前 $major），需要 Node.js 22 LTS 或更高版本。"
  }
}

$package = Get-AppxPackage OpenAI.Codex | Sort-Object Version -Descending | Select-Object -First 1
if (-not $package) {
  $issues += '未找到 Microsoft Store 安装的 OpenAI Codex。'
}

if ($Port -lt 1024 -or $Port -gt 65535) {
  $issues += "端口无效：$Port（可用范围 1024-65535）。"
} else {
  $listener = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue
  if ($listener) {
    try {
      $targets = Invoke-RestMethod "http://127.0.0.1:$Port/json/list" -TimeoutSec 1
      $isCodex = [bool]($targets | Where-Object { $_.type -eq 'page' -and $_.url -like 'app://*' })
      if (-not $isCodex) { $issues += "端口 $Port 已被其他程序占用，请改用 -Port 指定其他端口。" }
    } catch {
      $issues += "端口 $Port 已被其他程序占用，请改用 -Port 指定其他端口。"
    }
  }
}

if ($issues.Count -gt 0) {
  $issues | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host "环境检查通过：Codex $($package.Version)，Node.js $(& $node.Source --version)，CDP 端口 $Port 可用。"
