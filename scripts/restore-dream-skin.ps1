[CmdletBinding()]
param(
  [int]$Port = 9335,
  [switch]$Uninstall,
  [switch]$RestoreBaseTheme
)

$ErrorActionPreference = 'Stop'
$node = (Get-Command node -ErrorAction Stop).Source
$injector = Join-Path $PSScriptRoot 'injector.mjs'
$StateRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin'
$StatePath = Join-Path $StateRoot 'state.json'

function Stop-RecordedInjector([object]$State) {
  if (-not $State -or -not $State.injectorPid) { return }
  $pidValue = [int]$State.injectorPid
  $process = Get-CimInstance Win32_Process -Filter "ProcessId=$pidValue" -ErrorAction SilentlyContinue
  if (-not $process) { return }
  $expected = if ($State.injectorPath) { [string]$State.injectorPath } else { $injector }
  $commandLine = [string]$process.CommandLine
  if ($process.Name -ne 'node.exe' -or -not $expected -or $commandLine.IndexOf($expected, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
    Write-Warning "忽略旧 PID $pidValue：它已不再是 Codex Dream Skin 注入进程。"
    return
  }
  Stop-Process -Id $pidValue -Force -ErrorAction SilentlyContinue
}

if (Test-Path -LiteralPath $StatePath) {
  try {
    $state = Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json
    Stop-RecordedInjector $state
  } catch {}
  Remove-Item -LiteralPath $StatePath -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Milliseconds 250
try { & $node $injector --remove --port $Port --timeout-ms 3000 } catch {}

if ($Uninstall) {
  $desktop = [Environment]::GetFolderPath('Desktop')
  $startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
  @(
    (Join-Path $desktop 'Codex Dream Skin.lnk'),
    (Join-Path $desktop 'Codex Dream Skin - Restore.lnk'),
    (Join-Path $startMenu 'Codex Dream Skin.lnk')
  ) | ForEach-Object { Remove-Item -LiteralPath $_ -Force -ErrorAction SilentlyContinue }
}

if ($RestoreBaseTheme) {
  $backup = Join-Path $StateRoot 'config.before-dream-skin.toml'
  $config = Join-Path $HOME '.codex\config.toml'
  if (-not (Test-Path -LiteralPath $backup)) { throw 'No pre-install config backup is available.' }
  $backupContent = Get-Content -LiteralPath $backup -Raw
  $currentContent = Get-Content -LiteralPath $config -Raw
  foreach ($key in @('appearanceTheme', 'appearanceLightCodeThemeId', 'appearanceLightChromeTheme')) {
    $pattern = "(?m)^$([regex]::Escape($key))\s*=.*(?:\r?\n)?"
    $saved = [regex]::Match($backupContent, $pattern)
    if ([regex]::IsMatch($currentContent, $pattern)) {
      $replacement = if ($saved.Success) { $saved.Value.TrimEnd("`r", "`n") + "`r`n" } else { '' }
      $currentContent = [regex]::Replace($currentContent, $pattern, $replacement, 1)
    } elseif ($saved.Success) {
      $desktop = [regex]::Match($currentContent, '(?ms)^\[desktop\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
      if (-not $desktop.Success) {
        $currentContent = $currentContent.TrimEnd() + "`r`n`r`n[desktop]`r`n"
        $desktop = [regex]::Match($currentContent, '(?ms)^\[desktop\]\s*\r?\n(?<body>.*?)(?=^\[|\z)')
      }
      $body = $desktop.Groups['body'].Value.TrimEnd() + "`r`n" + $saved.Value.TrimEnd("`r", "`n") + "`r`n"
      $currentContent = $currentContent.Substring(0, $desktop.Groups['body'].Index) + $body +
        $currentContent.Substring($desktop.Groups['body'].Index + $desktop.Groups['body'].Length)
    }
  }
  Set-Content -LiteralPath $config -Value $currentContent -Encoding utf8
}

Write-Host 'Codex Dream Skin 已还原。官方程序、账号和任务数据均未修改。'
