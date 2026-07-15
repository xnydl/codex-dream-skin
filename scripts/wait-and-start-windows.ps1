[CmdletBinding()]
param(
  [int]$Port = 9335,
  [Parameter(Mandatory = $true)][string]$CodexExecutable
)

$ErrorActionPreference = 'Stop'
$startScript = Join-Path $PSScriptRoot 'start-dream-skin.ps1'

while ($true) {
  $running = @(Get-CimInstance Win32_Process -Filter "Name='ChatGPT.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.ExecutablePath -and $_.ExecutablePath.Equals($CodexExecutable, [System.StringComparison]::OrdinalIgnoreCase) })
  if ($running.Count -eq 0) { break }
  Start-Sleep -Seconds 1
}

& $startScript -Port $Port
exit $LASTEXITCODE
