[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$SteamCmdPath,
    [string]$SteamUser,
    [string]$PreviewFile,
    [switch]$Upload,
    [switch]$NewItem,
    [string]$ConfirmUpload
)
. "$PSScriptRoot/scripts/Common.ps1"
$work = Join-Path $ProjectRoot '.local/workshop'
New-Item -ItemType Directory -Force $work | Out-Null
$vdf = Join-Path $work 'item.vdf'
$statePath = Join-Path $work 'state.json'
$itemId = '0'
if (Test-Path -LiteralPath $statePath) {
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    $itemId = [string]$state.publishedfileid
    if ($itemId -notmatch '^[1-9][0-9]*$') { throw 'Invalid saved Workshop ID; recover it from Steam before continuing.' }
}
# SteamCMD writes its ID into this file. Recover it before regenerating anything,
# even if a prior upload exited unsuccessfully or the process was interrupted.
if (Test-Path -LiteralPath $vdf) {
    $previous = Get-Content -LiteralPath $vdf -Raw
    $match = [regex]::Match($previous, '"publishedfileid"\s+"([1-9][0-9]*)"')
    if ($match.Success) {
        $recovered = $match.Groups[1].Value
        if ($itemId -ne '0' -and $itemId -ne $recovered) { throw 'Conflicting Workshop IDs. Resolve the state manually.' }
        $itemId = $recovered
        @{ publishedfileid = $itemId } | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding utf8
    }
}
$pending = Join-Path $work 'upload-pending'
if ($itemId -eq '0' -and (Test-Path -LiteralPath $pending)) {
    throw 'Previous creation may have reached Steam. Recover its publishedfileid from Steam/item.vdf; do not create a duplicate.'
}
if ($Upload) {
    if ($ConfirmUpload -cne 'UPLOAD HIDDEN') { throw 'Uploading requires -Upload -ConfirmUpload "UPLOAD HIDDEN". This uploads content to Steam.' }
    if (!$SteamUser) { throw 'Provide -SteamUser. SteamCMD prompts interactively for password/Steam Guard; never pass them here.' }
    if ($SteamUser -notmatch '^[A-Za-z0-9_]+$') { throw 'Invalid Steam account name.' }
    if ($itemId -eq '0' -and !$NewItem) { throw 'First creation requires -NewItem; otherwise recover the existing publishedfileid.' }
    if ($itemId -ne '0' -and $NewItem) { throw 'An item already exists; omit -NewItem to update it.' }
    if (!$PreviewFile -or !(Test-Path -LiteralPath $PreviewFile -PathType Leaf)) { throw 'Provide a Workshop cover with -PreviewFile.' }
    if ((Get-Item -LiteralPath $PreviewFile).Length -ge 1MB) { throw 'Preview must be under 1 MB.' }
    if (!$SteamCmdPath) { $SteamCmdPath = $env:STEAMCMD_PATH }
    if (!$SteamCmdPath) { $SteamCmdPath = Get-LocalSetting 'SteamCmdPath' }
    if (!$SteamCmdPath -or !(Test-Path -LiteralPath $SteamCmdPath -PathType Leaf)) { throw 'Set -SteamCmdPath, STEAMCMD_PATH, or local config.' }
}
& "$PSScriptRoot/package.ps1" -GameDir $GameDir
$content = Join-Path $ProjectRoot 'artifacts/Release/drag_aware_hotkeys'
$version = Get-ModVersion
$changelog = Get-Content (Join-Path $ProjectRoot 'CHANGELOG.md') -Raw
$release = [regex]::Match($changelog, '(?ms)^## \[' + [regex]::Escape($version) + '\][^\r\n]*\r?\n(.*?)(?=^## \[|\z)')
if (!$release.Success) { throw "CHANGELOG has no entry for $version." }
$note = "v$version`n" + $release.Groups[1].Value.Trim()
$description = (Get-Content (Join-Path $ProjectRoot 'workshop/description.en.txt') -Raw).Trim() + "`n`n" + (Get-Content (Join-Path $ProjectRoot 'workshop/description.zh-CN.txt') -Raw).Trim()
function Escape-Vdf([string]$Value) { return $Value.Replace('\', '\\').Replace('"', '\"').Replace("`r", '').Replace("`n", '\n') }
$fields = [ordered]@{
    appid = '4348910'
    publishedfileid = $itemId
    contentfolder = $content
    visibility = '2'
    title = 'Drag-Aware Hotkeys（解决拖拽时按键冲突）'
    description = $description
    changenote = $note
}
if ($PreviewFile) { $fields.previewfile = (Resolve-Path -LiteralPath $PreviewFile).Path }
$lines = @('"workshopitem"', '{')
foreach ($key in $fields.Keys) { $lines += '    "' + $key + '" "' + (Escape-Vdf $fields[$key]) + '"' }
$lines += '}'
[System.IO.File]::WriteAllLines($vdf, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "Generated hidden Workshop VDF: $vdf (item $itemId)."
if (!$Upload) { Write-Host 'Preparation only. SteamCMD was not started.'; return }
Set-Content -LiteralPath $pending -Value 'An upload was attempted; recover ID before retrying a creation.' -Encoding utf8
Push-Location (Split-Path -Parent (Resolve-Path -LiteralPath $SteamCmdPath).Path)
try {
    & $SteamCmdPath '+login' $SteamUser '+workshop_build_item' $vdf '+quit'
    $steamExitCode = $LASTEXITCODE
} finally { Pop-Location }
$updated = [regex]::Match((Get-Content -LiteralPath $vdf -Raw), '"publishedfileid"\s+"([1-9][0-9]*)"')
if ($updated.Success) {
    $returnedId = $updated.Groups[1].Value
    if ($itemId -ne '0' -and $itemId -ne $returnedId) { throw 'Steam returned a different ID; inspect item.vdf before continuing.' }
    @{ publishedfileid = $returnedId } | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding utf8
    Remove-Item -LiteralPath $pending
    Write-Host "Saved publishedfileid $returnedId. Future runs update this item."
} else { throw 'No publishedfileid returned. Check Steam manually and recover ID before retrying.' }
if ($steamExitCode -ne 0) { throw "SteamCMD exited with $steamExitCode; ID saved, verify upload on Steam." }
Write-Host 'SteamCMD finished. Verify content and hidden visibility on Steam before any public release.'
