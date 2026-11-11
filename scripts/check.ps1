. "$PSScriptRoot/Common.ps1"
$failed = $false
foreach ($file in Get-ChildItem -LiteralPath $ProjectRoot -Filter '*.ps1' -File -Recurse | Where-Object { $_.FullName -notmatch '[\\/](\.local|artifacts|bin|obj)[\\/]' }) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { $errors | Write-Host; $failed = $true }
}
[xml]$manifest = Get-Content (Join-Path $ProjectRoot 'mod/manifest.xml') -Raw
if ($manifest.Manifest.ModVersion -ne (Get-ModVersion)) { throw 'Manifest version mismatch.' }
if ($failed) { throw 'PowerShell syntax errors.' }
& git -C $ProjectRoot diff --check
if ($LASTEXITCODE -ne 0) { throw 'Whitespace check failed.' }
$tracked = & git -C $ProjectRoot ls-files
if (@($tracked | Where-Object { $_ -match '(?i)(\.(dll|exe|pdb|zip|vdf|acf|log)$|(^|/)(\.local|artifacts|bin|obj)/|config\.local\.json$|\.env$)' }).Count) {
    throw 'Forbidden generated, private, or binary files tracked.'
}
Write-Host 'Script syntax, manifest version, whitespace and tracked-file policy passed.'
