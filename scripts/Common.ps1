Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:ProjectRoot = Split-Path $PSScriptRoot -Parent
function Get-LocalSetting([string]$Name) {
    $path = Join-Path $script:ProjectRoot 'config.local.json'
    if (Test-Path -LiteralPath $path) {
        $config = Get-Content -LiteralPath $path -Raw -Encoding utf8 | ConvertFrom-Json
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
    [xml]$props = Get-Content (Join-Path $script:ProjectRoot 'Directory.Build.props') -Raw -Encoding utf8
    return [string]$props.Project.PropertyGroup.Version
}
function Assert-RuntimeFolder([string]$Path, [switch]$AllowOlderVersion) {
    $expected = @('manifest.xml', 'ProbablyStolen.DragAwareHotkeys.dll', 'preview.png')
    $actual = @(Get-ChildItem -LiteralPath $Path -Force)
    # Existing pre-0.1.6 installations contain only two files. Accept that exact
    # legacy shape for upgrade validation, but require the preview in new builds.
    if ($AllowOlderVersion -and $actual.Count -eq 2) { $expected = @('manifest.xml', 'ProbablyStolen.DragAwareHotkeys.dll') }
    if ($actual.Count -ne $expected.Count -or @($actual | Where-Object { $_.PSIsContainer -or $_.Name -notin $expected }).Count -gt 0) {
        throw 'Runtime folder must contain exactly the manifest, mod DLL and preview.png (legacy two-file installs may be upgraded).'
    }
    [xml]$manifest = Get-Content (Join-Path $Path 'manifest.xml') -Raw -Encoding utf8
    if ($manifest.Manifest.ID -ne 'drag_aware_hotkeys' -or (!$AllowOlderVersion -and $manifest.Manifest.ModVersion -ne (Get-ModVersion))) { throw 'Manifest id/version mismatch.' }
}
