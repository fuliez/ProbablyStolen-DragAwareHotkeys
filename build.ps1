[CmdletBinding()]
param([string]$GameDir, [ValidateSet('Release','Debug')][string]$Configuration = 'Release')
. "$PSScriptRoot/scripts/Common.ps1"
$game = Resolve-GameDir $GameDir
$project = Join-Path $ProjectRoot 'src/DragAwareHotkeys/DragAwareHotkeys.csproj'
& dotnet build $project -c $Configuration "-p:GameDir=$game" --nologo
if ($LASTEXITCODE -ne 0) { throw 'Build failed.' }
$output = Join-Path $ProjectRoot "artifacts/$Configuration/drag_aware_hotkeys"
New-Item -ItemType Directory -Force $output | Out-Null
# An allowlist prevents accidental game dependency redistribution.
Copy-Item -LiteralPath (Join-Path $ProjectRoot "src/DragAwareHotkeys/bin/$Configuration/netstandard2.1/ProbablyStolen.DragAwareHotkeys.dll") -Destination $output -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'mod/manifest.xml') -Destination $output -Force
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'mod/preview.png') -Destination $output -Force
Assert-RuntimeFolder $output
Write-Host "Built $output"
