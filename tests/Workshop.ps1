# Offline tests of publishing safeguards. SteamCMD is replaced with a local fake.
. "$PSScriptRoot/../scripts/Common.ps1"
$fixture = Join-Path $ProjectRoot ('.local/publisher-tests/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force (Join-Path $fixture 'scripts'), (Join-Path $fixture 'workshop'), (Join-Path $fixture 'mod') | Out-Null
foreach ($name in @('publish-workshop.ps1','Directory.Build.props','CHANGELOG.md')) {
    Copy-Item -LiteralPath (Join-Path $ProjectRoot $name) -Destination $fixture
}
Copy-Item -LiteralPath "$ProjectRoot/scripts/Common.ps1" -Destination "$fixture/scripts"
Copy-Item -LiteralPath "$ProjectRoot/mod/manifest.xml" -Destination "$fixture/mod"
Copy-Item -LiteralPath "$ProjectRoot/workshop/description.en.txt", "$ProjectRoot/workshop/description.zh-CN.txt" -Destination "$fixture/workshop"
@'
param([string]$GameDir)
New-Item -ItemType Directory -Force "$PSScriptRoot/artifacts/Release/drag_aware_hotkeys" | Out-Null
'@ | Set-Content "$fixture/package.ps1"
@'
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Arguments)
$vdf = $Arguments[3]
$text = Get-Content -LiteralPath $vdf -Raw -Encoding utf8
$text.Replace('"publishedfileid" "0"', '"publishedfileid" "123456789"') | Set-Content -LiteralPath $vdf
$global:LASTEXITCODE = 0
'@ | Set-Content "$fixture/fake-steamcmd.ps1"
Set-Content "$fixture/cover.png" 'test placeholder; never sent to Steam'
$publisher = Join-Path $fixture 'publish-workshop.ps1'
function Expect-Rejected([scriptblock]$Action, [string]$Expected) {
    try { & $Action } catch {
        if ($_.Exception.Message -like "*$Expected*") { Write-Host "PASS: $Expected"; return }
        throw
    }
    throw "Expected rejection: $Expected"
}
& $publisher
$vdf = Join-Path $fixture '.local/workshop/item.vdf'
if ((Get-Content $vdf -Raw -Encoding utf8) -notmatch '"visibility" "2"') { throw 'Preparation must be hidden.' }
[xml]$manifest = Get-Content "$fixture/mod/manifest.xml" -Raw -Encoding utf8
if (!(Get-Content $vdf -Raw -Encoding utf8).Contains('"title" "' + $manifest.Manifest.Name + '"')) { throw 'Bilingual title was not preserved as UTF-8.' }
$prepared = (Get-Content $vdf -Raw -Encoding utf8).Replace("`r`n", "`n")
$expectedDescription = (Get-Content "$fixture/workshop/description.zh-CN.txt" -Raw -Encoding utf8).Trim().Replace("`r`n", "`n") + "`n`n[hr][/hr]`n`n" + (Get-Content "$fixture/workshop/description.en.txt" -Raw -Encoding utf8).Trim().Replace("`r`n", "`n")
if (!$prepared.Contains('"description" "' + $expectedDescription + '"')) { throw 'Description must retain literal newlines, Chinese first and English second.' }
if ($prepared.Contains('\n')) { throw 'VDF must not contain escaped newline text.' }
if (!$prepared.Contains('[url=https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys]')) { throw 'Description must link the source repository.' }
$zh = Get-Content "$fixture/workshop/description.zh-CN.txt" -Raw -Encoding utf8
$en = Get-Content "$fixture/workshop/description.en.txt" -Raw -Encoding utf8
foreach ($marker in @('\[h2\]', '\[\*\]')) {
    if ([regex]::Matches($zh, $marker).Count -ne [regex]::Matches($en, $marker).Count) { throw 'Bilingual section/bullet structure must match.' }
}
foreach ($link in [regex]::Matches($zh, '\[url=([^\]]+)\]')) {
    if (!$en.Contains($link.Value)) { throw 'Both descriptions must provide the same links.' }
}
if (Test-Path "$fixture/.local/workshop/state.json") { throw 'Preparation must not invent an item ID.' }
Expect-Rejected { & $publisher -Upload } 'requires -Upload'
Expect-Rejected { & $publisher -Upload -ConfirmUpload 'UPLOAD HIDDEN' -SteamUser test } 'requires -NewItem'
$upload = @{
    Upload = $true
    ConfirmUpload = 'UPLOAD HIDDEN'
    SteamUser = 'offline_test'
    SteamCmdPath = "$fixture/fake-steamcmd.ps1"
    PreviewFile = "$fixture/cover.png"
}
& $publisher @upload -NewItem
$statePath = "$fixture/.local/workshop/state.json"
if ((Get-Content $statePath -Raw -Encoding utf8 | ConvertFrom-Json).publishedfileid -ne '123456789') { throw 'Mock ID was not saved.' }
Expect-Rejected { & $publisher @upload -NewItem } 'already exists'
& $publisher @upload
if ((Get-Content $vdf -Raw -Encoding utf8) -notmatch '"publishedfileid" "123456789"') { throw 'Update changed item identity.' }
# Test crash recovery: an existing VDF id must survive a lost state file.
Remove-Item -LiteralPath $statePath
& $publisher
if ((Get-Content $statePath -Raw -Encoding utf8 | ConvertFrom-Json).publishedfileid -ne '123456789') { throw 'VDF recovery failed.' }
# Fresh clones must use the committed identity, even without private local state.
$identityPath = "$fixture/workshop/item.json"
@{ appid = '4348910'; publishedfileid = '123456789' } | ConvertTo-Json | Set-Content $identityPath -Encoding utf8
Remove-Item -LiteralPath $statePath, $vdf
& $publisher
if ((Get-Content $vdf -Raw -Encoding utf8) -notmatch '"publishedfileid" "123456789"') { throw 'Tracked identity was not used on a fresh clone.' }
Expect-Rejected { & $publisher @upload -NewItem } 'already exists'
@{ publishedfileid = '987654321' } | ConvertTo-Json | Set-Content $statePath -Encoding utf8
Expect-Rejected { & $publisher } 'conflicts with tracked identity'
Remove-Item -LiteralPath $identityPath
# A creation with unknown server outcome must never silently retry as a new item.
Remove-Item -LiteralPath $statePath
(Get-Content $vdf -Raw -Encoding utf8).Replace('123456789','0') | Set-Content $vdf
Set-Content "$fixture/.local/workshop/upload-pending" 'offline test'
Expect-Rejected { & $publisher } 'Previous creation may have reached Steam'
Write-Host 'PASS: offline preparation, hidden creation/update, saved identity, crash recovery and uncertain-upload protection.'
