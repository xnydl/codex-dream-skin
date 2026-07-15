[CmdletBinding()]
param([int]$Port = 9335)

$ErrorActionPreference = 'Stop'
$startScript = Join-Path $PSScriptRoot 'start-dream-skin.ps1'
$waitScript = Join-Path $PSScriptRoot 'wait-and-start-windows.ps1'
$checkScript = Join-Path $PSScriptRoot 'check-dream-skin.ps1'
& $checkScript -Port $Port

function Test-CodexDebugPort([int]$CandidatePort) {
  try {
    $targets = Invoke-RestMethod "http://127.0.0.1:$CandidatePort/json/list" -TimeoutSec 1
    return [bool]($targets | Where-Object { $_.type -eq 'page' -and $_.url -like 'app://*' })
  } catch { return $false }
}

if (Test-CodexDebugPort $Port) {
  & $startScript -Port $Port
  exit $LASTEXITCODE
}

$package = Get-AppxPackage OpenAI.Codex | Sort-Object Version -Descending | Select-Object -First 1
if (-not $package) { throw 'The OpenAI.Codex Store package is not installed.' }
$exe = Join-Path $package.InstallLocation 'app\ChatGPT.exe'
$running = @(Get-CimInstance Win32_Process -Filter "Name='ChatGPT.exe'" -ErrorAction SilentlyContinue |
  Where-Object { $_.ExecutablePath -and $_.ExecutablePath.Equals($exe, [System.StringComparison]::OrdinalIgnoreCase) })

if ($running.Count -eq 0) {
  & $startScript -Port $Port
  exit $LASTEXITCODE
}

$powershell = (Get-Command powershell.exe).Source
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$waitScript`" -Port $Port -CodexExecutable `"$exe`""
Start-Process -FilePath $powershell -ArgumentList $arguments -WindowStyle Hidden
Write-Host '启动已排队。请正常退出 Codex；Dream Skin 会自动应用并重新打开。'
