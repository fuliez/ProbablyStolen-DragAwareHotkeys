# Release procedure

## Local development to GitHub

1. Develop with Conventional Commits (`feat:`, `fix:`, `docs:`, `build:`, `test:`). Use `main`; create feature branches for subsequent changes.
2. Set the game directory by environment variable or ignored config; run build, contract checks, script checks and installed-game scan.
3. Install with the game closed, restart, complete [manual acceptance](TESTING.md). Record actual results and game compatibility; a headless test is not a play test.
4. Update `Directory.Build.props`, `mod/manifest.xml` and `CHANGELOG.md` together. Follow SemVer; keep new work under Unreleased. Generate the package from Release only.
5. Review `git diff`, `git diff --check` and staged paths. Never stage game assemblies, saves, credentials, decompilation, generated VDF or local config.
6. Commit; after acceptance create annotated tag `v0.1.0` (or the next version). Only tag an accepted version; current release preparation is 0.1.1.
7. The owner confirmed `ProbablyStolen-DragAwareHotkeys` as a **public** repository on 2026-11-11. Add `origin`, push `main` and explicitly chosen tags only after authorization.
8. With authorization, create a GitHub Release from the tag and attach the runtime ZIP. Copy the version's changelog section as release notes. This workflow does not automatically publish releases.

Public GitHub Actions checks compile/run contract tests and validate scripts and tracked-file policy. For real builds, a trusted Windows self-hosted runner can set `PROBABLY_STOLEN_GAME_DIR`, use label `probably-stolen`, and repository variable `ENABLE_LOCAL_GAME_BUILD=true`. Only manual dispatch runs that job. Use a private runner/repository or a tightly controlled runner group; never execute untrusted branch content on a machine with personal data. Two builds on that runner compare DLL hashes. Different game reference versions are different build inputs; record the game DLL fingerprint. ZIP container timestamps are not promised to be byte-identical.

## Steam Workshop preparation

Requires SteamCMD, an account that owns App 4348910, a completed cover under 1 MB, and completed game acceptance. See [cover brief](../workshop/COVER-BRIEF.md). SteamCMD has been installed locally under ignored .local/steamcmd and its path is in ignored config.local.json. The scripts do not install it on other machines.

```powershell
./publish-workshop.ps1                     # builds/packages, generates VDF, uploads nothing
./publish-workshop.ps1 -PreviewFile ./cover.png # optional cover for preparation
```

The ignored `.local/workshop/item.vdf` contains `appid=4348910`, runtime content folder, English and Chinese description, changenote extracted from the current version's changelog, and **visibility=2 (hidden)**. Local absolute paths exist only in ignored generated files. The generated ZIP contains only the mod DLL and manifest. Cover is uploaded separately.

## Explicitly authorized first upload

The first hidden upload has already completed for this project (item ID in workshop/item.json). The following first-creation command is retained as historical documentation and is now rejected for this project. Do not remove the tracked identity to bypass that protection. For normal updates, omit -NewItem. On a genuinely new independent project, first creation requires explicit owner approval:

```powershell
./publish-workshop.ps1 -Upload -NewItem -ConfirmUpload 'UPLOAD HIDDEN' `
  -SteamCmdPath $env:STEAMCMD_PATH -SteamUser YOUR_ACCOUNT -PreviewFile ./cover.png
```

The script passes only the account name; SteamCMD handles password/Steam Guard interactively. Do not add a password parameter, unattended login config, credentials file, transcript or credential logging. SteamCMD's own account/session handling is outside this repository. Accept Valve's Workshop legal agreement on Steam if prompted, then verify the item's files and hidden visibility manually. A successful exit code alone is insufficient evidence of acceptance.

SteamCMD writes `publishedfileid` back into `item.vdf`. The script preserves it in `.local/workshop/state.json` and recovers it from VDF before any regeneration. Back up **both files** securely; neither contains a password. This project also commits its non-sensitive App ID and item ID in workshop/item.json. Fresh clones use that tracked identity even without local state; conflicting IDs are rejected. Once an ID exists the script updates it and refuses `-NewItem`.

If creation is interrupted and no ID was saved, an upload-pending marker blocks another creation. Inspect the account's Workshop items and SteamCMD output, recover the existing ID into state.json (format below), and only then retry. If no item was created, verify that manually before removing the marker. Never assume a failed process means Steam created nothing.

```json
{ "publishedfileid": "YOUR_EXISTING_NUMERIC_ITEM_ID" }
```

## Updates and public visibility

After testing a new version, update changelog/version, commit, tag, publish the authorized GitHub Release, then run the same upload command **without `-NewItem`**. Changenote is generated from that version's changelog. This script always keeps the item hidden, including updates; it has no public setting. If the item is later intentionally made public, using this script hides it again until you explicitly change visibility on Steam. This conservative behavior must be considered when planning public updates.

**Changing an item to public requires separate explicit owner authorization and a manual visibility change on Steam.** The first hidden upload was authorized on 2026-11-11; actual upload results and item identity are recorded in agent.md and ignored .local/workshop state.

## Current delivery record

- [Public GitHub Release v0.1.1](https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases/tag/v0.1.1) is published with runtime ZIP and checksum file.
- First hidden Workshop upload completed: item 3837800051, app 4348910, submitted visibility 2. Local result and returned VDF confirm success and saved identity. Owner-authenticated page/Workshop agreement verification is still required; anonymous queries cannot view this hidden item.
- Public Workshop visibility is not authorized. Updating through this script retains hidden visibility.
