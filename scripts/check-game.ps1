[CmdletBinding()]
param([string]$GameDir)
. "$PSScriptRoot/Common.ps1"
$game = Resolve-GameDir $GameDir
$managed = Join-Path $game 'Probably Stolen_Data/Managed'
& "$ProjectRoot/build.ps1" -GameDir $game
$sdk = (& dotnet --list-sdks | Select-Object -Last 1)
if ($sdk -notmatch '^([^ ]+) \[(.+)\]$') { throw 'Cannot locate Roslyn compiler.' }
$csc = Join-Path $Matches[2] "$($Matches[1])/Roslyn/bincore/csc.dll"
$output = Join-Path $ProjectRoot '.local/checks'
New-Item -ItemType Directory -Force $output | Out-Null
$exe = Join-Path $output 'GameCheck.exe'
$arguments = @($csc, '-nologo', '-noconfig', '-nostdlib+', '-target:exe', "-out:$exe")
foreach ($reference in @('mscorlib.dll','System.dll','System.Core.dll','netstandard.dll','Assembly-CSharp.dll','UnityEngine.CoreModule.dll')) {
    $arguments += "-r:$(Join-Path $managed $reference)"
}
$arguments += Join-Path $ProjectRoot 'tools/GameCheck.cs'
& dotnet @arguments
if ($LASTEXITCODE -ne 0) { throw 'Harness compilation failed.' }
@{ runtimeOptions = @{ tfm = 'net6.0'; framework = @{ name = 'Microsoft.NETCore.App'; version = '6.0.0' } } } |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'GameCheck.runtimeconfig.json') -Encoding utf8
# The scanner uses netstandard2.1 APIs absent from desktop .NET Framework.
& dotnet $exe $managed (Join-Path $ProjectRoot 'artifacts/Release/drag_aware_hotkeys')
if ($LASTEXITCODE -ne 0) { throw 'Game API or scanner check failed; see output.' }
