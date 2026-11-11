[CmdletBinding()]
param([string]$GameDir)
. "$PSScriptRoot/scripts/Common.ps1"
& "$PSScriptRoot/build.ps1" -GameDir $GameDir -Configuration Release
$source = Join-Path $ProjectRoot 'artifacts/Release/drag_aware_hotkeys'
Assert-RuntimeFolder $source
$archive = Join-Path $ProjectRoot "artifacts/ProbablyStolen-DragAwareHotkeys-$(Get-ModVersion).zip"
Compress-Archive -LiteralPath $source -DestinationPath $archive -Force
Write-Host "Packaged $archive"
