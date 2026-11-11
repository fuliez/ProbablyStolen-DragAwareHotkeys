Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:ProjectRoot = Split-Path $PSScriptRoot -Parent
function Get-LocalSetting([string]$Name) {
    $path = Join-Path $script:ProjectRoot 'config.local.json'
    if (Test-Path -LiteralPath $path) {
        $config = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
        if ($config.PSObject.Properties.Name -contains $Name) { return [string]$config.$Name }
    }
    return ''
}
function Resolve-GameDir([string]$GameDir) {
    if (!$GameDir) { $GameDir = $env:PROBABLY_STOLEN_GAME_DIR }
    if (!$GameDir) { $GameDir = Get-LocalSetting 'GameDir' }
    if (!$GameDir) { throw 'Set -GameDir, PROBABLY_STOLEN_GAME_DIR, or GameDir in ignored config.local.json.' }
    $resolved = (Resolve-Path -LiteralPath $GameDir).Path
    foreach ($file in @('Assembly-CSharp.dll', 'UnityEngine.CoreModule.dll', '0Harmony.dll')) {
        if (!(Test-Path -LiteralPath (Join-Path $resolved "Probably Stolen_Data/Managed/$file"))) { throw "Missing game reference: $file" }
    }
    return $resolved
}
function Get-ModVersion {
    [xml]$props = Get-Content (Join-Path $script:ProjectRoot 'Directory.Build.props') -Raw
    return [string]$props.Project.PropertyGroup.Version
}
function Assert-RuntimeFolder([string]$Path, [switch]$AllowOlderVersion) {
    $expected = @('manifest.xml', 'ProbablyStolen.DragAwareHotkeys.dll')
    $actual = @(Get-ChildItem -LiteralPath $Path -Force)
    if ($actual.Count -ne 2 -or @($actual | Where-Object { $_.PSIsContainer -or $_.Name -notin $expected }).Count -gt 0) {
        throw 'Runtime folder must contain exactly the manifest and mod DLL.'
    }
    [xml]$manifest = Get-Content (Join-Path $Path 'manifest.xml') -Raw
    if ($manifest.Manifest.ID -ne 'drag_aware_hotkeys' -or (!$AllowOlderVersion -and $manifest.Manifest.ModVersion -ne (Get-ModVersion))) { throw 'Manifest id/version mismatch.' }
}
