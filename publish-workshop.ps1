[CmdletBinding()]
param(
    [string]$GameDir,
    [string]$SteamCmdPath,
    [string]$SteamUser,
    [string]$PreviewFile,
    [switch]$Upload,
    [switch]$NewItem,
    [ValidateSet('Hidden','Public')][string]$Visibility,
    [string]$ConfirmUpload
)
. "$PSScriptRoot/scripts/Common.ps1"
$work = Join-Path $ProjectRoot '.local/workshop'
New-Item -ItemType Directory -Force $work | Out-Null
$vdf = Join-Path $work 'item.vdf'
$statePath = Join-Path $work 'state.json'
$itemId = '0'
$configuredVisibility = 'Hidden'
$identityPath = Join-Path $ProjectRoot 'workshop/item.json'
if (Test-Path -LiteralPath $identityPath) {
    $identity = Get-Content -LiteralPath $identityPath -Raw -Encoding utf8 | ConvertFrom-Json
    if ([string]$identity.appid -ne '4348910' -or [string]$identity.publishedfileid -notmatch '^[1-9][0-9]*$') {
        throw 'Invalid tracked Workshop identity. Restore workshop/item.json before continuing.'
    }
    $itemId = [string]$identity.publishedfileid
    if ($identity.PSObject.Properties.Name -contains 'visibility') {
        if ([string]$identity.visibility -notin @('Hidden','Public')) { throw 'Invalid tracked Workshop visibility.' }
        $configuredVisibility = [string]$identity.visibility
    }
}
if (Test-Path -LiteralPath $statePath) {
    $state = Get-Content -LiteralPath $statePath -Raw -Encoding utf8 | ConvertFrom-Json
    $savedId = [string]$state.publishedfileid
    if ($savedId -notmatch '^[1-9][0-9]*$') { throw 'Invalid saved Workshop ID; recover it from Steam before continuing.' }
    if ($itemId -ne '0' -and $itemId -ne $savedId) { throw 'Saved Workshop ID conflicts with tracked identity; resolve it before uploading.' }
    $itemId = $savedId
}
# SteamCMD writes its ID into this file. Recover it before regenerating anything,
# even if a prior upload exited unsuccessfully or the process was interrupted.
if (Test-Path -LiteralPath $vdf) {
    $previous = Get-Content -LiteralPath $vdf -Raw -Encoding utf8
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
if (!$Visibility) { $Visibility = $configuredVisibility }
if ($itemId -eq '0' -and $Visibility -eq 'Public') { throw 'First Workshop creation must use Hidden visibility.' }
$confirmation = 'UPLOAD ' + $Visibility.ToUpperInvariant()
if ($Upload) {
    if ($ConfirmUpload -cne $confirmation) { throw "Uploading requires -Upload -ConfirmUpload '$confirmation'. This uploads content to Steam." }
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
$changelog = Get-Content (Join-Path $ProjectRoot 'CHANGELOG.md') -Raw -Encoding utf8
$release = [regex]::Match($changelog, '(?ms)^## \[' + [regex]::Escape($version) + '\][^\r\n]*\r?\n(.*?)(?=^## \[|\z)')
if (!$release.Success) { throw "CHANGELOG has no entry for $version." }
$note = "v$version`n" + $release.Groups[1].Value.Trim()
$description = (Get-Content (Join-Path $ProjectRoot 'workshop/description.zh-CN.txt') -Raw -Encoding utf8).Trim() + "`n`n[hr][/hr]`n`n" + (Get-Content (Join-Path $ProjectRoot 'workshop/description.en.txt') -Raw -Encoding utf8).Trim()
if ([System.Text.Encoding]::UTF8.GetByteCount($description) -gt 8000) { throw 'Workshop description exceeds 8000 UTF-8 bytes.' }
[xml]$manifest = Get-Content (Join-Path $ProjectRoot 'mod/manifest.xml') -Raw -Encoding utf8
function Format-VdfValue([string]$Value) {
    # SteamCMD's KeyValues reader uses literal multiline strings. Escaped \n is shown verbatim on Steam.
    if ($Value.Contains('"') -or $Value.Contains([string][char]0)) { throw 'VDF values cannot contain double quotes or null characters.' }
    return $Value.Replace("`r`n", "`n").Replace("`r", "`n")
}
$fields = [ordered]@{
    appid = '4348910'
    publishedfileid = $itemId
    contentfolder = $content.Replace('\', '/')
    visibility = $(if ($Visibility -eq 'Public') { '0' } else { '2' })
    title = [string]$manifest.Manifest.Name
    description = $description
    changenote = $note
}
if ($PreviewFile) { $fields.previewfile = (Resolve-Path -LiteralPath $PreviewFile).Path.Replace('\', '/') }
$lines = @('"workshopitem"', '{')
foreach ($key in $fields.Keys) { $lines += '    "' + $key + '" "' + (Format-VdfValue $fields[$key]) + '"' }
$lines += '}'
[System.IO.File]::WriteAllLines($vdf, [string[]]$lines, [System.Text.UTF8Encoding]::new($false))
Write-Host "Generated $Visibility Workshop VDF: $vdf (item $itemId)."
if (!$Upload) { Write-Host 'Preparation only. SteamCMD was not started.'; return }
Set-Content -LiteralPath $pending -Value 'An upload was attempted; recover ID before retrying a creation.' -Encoding utf8
Push-Location (Split-Path -Parent (Resolve-Path -LiteralPath $SteamCmdPath).Path)
try {
    & $SteamCmdPath '+login' $SteamUser '+workshop_build_item' $vdf '+quit'
    $steamExitCode = $LASTEXITCODE
} finally { Pop-Location }
$updated = [regex]::Match((Get-Content -LiteralPath $vdf -Raw -Encoding utf8), '"publishedfileid"\s+"([1-9][0-9]*)"')
if ($updated.Success) {
    $returnedId = $updated.Groups[1].Value
    if ($itemId -ne '0' -and $itemId -ne $returnedId) { throw 'Steam returned a different ID; inspect item.vdf before continuing.' }
    @{ publishedfileid = $returnedId } | ConvertTo-Json | Set-Content -LiteralPath $statePath -Encoding utf8
    Remove-Item -LiteralPath $pending
    Write-Host "Saved publishedfileid $returnedId. Future runs update this item."
} else { throw 'No publishedfileid returned. Check Steam manually and recover ID before retrying.' }
if ($steamExitCode -ne 0) { throw "SteamCMD exited with $steamExitCode; ID saved, verify upload on Steam." }
Write-Host "SteamCMD finished. Verify content and $Visibility visibility on Steam."
