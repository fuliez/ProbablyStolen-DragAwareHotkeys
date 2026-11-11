[CmdletBinding()]
param([string]$GameDir, [ValidateSet('Release','Debug')][string]$Configuration = 'Release')
. "$PSScriptRoot/scripts/Common.ps1"
$game = Resolve-GameDir $GameDir
if (Get-Process -Name 'Probably Stolen' -ErrorAction SilentlyContinue) { throw 'Close the game before installing.' }
& "$PSScriptRoot/build.ps1" -GameDir $game -Configuration $Configuration
$source = Join-Path $ProjectRoot "artifacts/$Configuration/drag_aware_hotkeys"
$destination = Join-Path $game 'Mods/drag_aware_hotkeys'
if (Test-Path -LiteralPath $destination) { Assert-RuntimeFolder $destination -AllowOlderVersion }
New-Item -ItemType Directory -Force $destination | Out-Null
foreach ($file in Get-ChildItem -LiteralPath $source -File) { Copy-Item -LiteralPath $file.FullName -Destination $destination -Force }
Write-Host 'Installed. Enable Drag-Aware Hotkeys in Mods, review permissions, and restart the game.'
