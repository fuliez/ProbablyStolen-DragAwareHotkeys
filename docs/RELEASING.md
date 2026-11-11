# Release procedure

## Local development to GitHub

1. Develop with Conventional Commits (`feat:`, `fix:`, `docs:`, `build:`, `test:`). Use `main`; create feature branches for subsequent changes.
2. Set the game directory by environment variable or ignored config; run build, contract checks, script checks and installed-game scan.
3. Install with the game closed, restart, complete [manual acceptance](TESTING.md). Record actual results and game compatibility; a headless test is not a play test.
4. Update `Directory.Build.props`, `mod/manifest.xml` and `CHANGELOG.md` together. Follow SemVer; keep new work under Unreleased. Generate the package from Release only.
5. Review `git diff`, `git diff --check` and staged paths. Never stage game assemblies, saves, credentials, decompilation, generated VDF or local config.
6. Commit; after acceptance create annotated tag `v0.1.0` (or the next version). Only tag an accepted version; the latest released mod version is 0.1.5.
7. The owner confirmed `ProbablyStolen-DragAwareHotkeys` as a **public** repository on 2026-11-11. Add `origin`, push `main` and explicitly chosen tags only after authorization.
8. With authorization, create a GitHub Release from the tag and attach the runtime ZIP. Copy the version's changelog section as release notes. This workflow does not automatically publish releases.

Public GitHub Actions checks compile/run contract tests and validate scripts and tracked-file policy. For real builds, a trusted Windows self-hosted runner can set `PROBABLY_STOLEN_GAME_DIR`, use label `probably-stolen`, and repository variable `ENABLE_LOCAL_GAME_BUILD=true`. Only manual dispatch runs that job. Use a private runner/repository or a tightly controlled runner group; never execute untrusted branch content on a machine with personal data. Two builds on that runner compare DLL hashes. Different game reference versions are different build inputs; record the game DLL fingerprint. ZIP container timestamps are not promised to be byte-identical.

## Steam Workshop preparation

Requires SteamCMD, an account that owns App 4348910, a completed cover under 1 MB, and completed game acceptance. See [cover brief](../workshop/COVER-BRIEF.md). SteamCMD has been installed locally under ignored .local/steamcmd and its path is in ignored config.local.json. The scripts do not install it on other machines.

```powershell
./publish-workshop.ps1                     # builds/packages, generates VDF, uploads nothing
./publish-workshop.ps1 -PreviewFile ./cover.png # optional cover for preparation
```

The ignored `.local/workshop/item.vdf` contains `appid=4348910`, runtime content folder, Chinese description followed by its matching English translation, changenote extracted from the current version's changelog, and the requested visibility (Hidden=2 or Public=0). Descriptions keep only a source-code link in the Source section; subscriptions, updates and feedback use Steam. Values use actual line breaks: writing backslash-n text makes Steam display those characters literally. Paths use forward slashes; embedded double quotes/nulls are rejected. Combined description length is checked against 8000 UTF-8 bytes. Local absolute paths exist only in ignored generated files. The generated ZIP contains exactly the mod DLL, manifest.xml and preview.png for the game menu. The Steam page cover.jpg is also uploaded separately.

## Explicitly authorized first upload

The first hidden upload has already completed for this project (item ID in workshop/item.json). The following first-creation command is retained as historical documentation and is now rejected for this project. Do not remove the tracked identity to bypass that protection. For normal updates, omit -NewItem. On a genuinely new independent project, first creation requires explicit owner approval:

```powershell
./publish-workshop.ps1 -Upload -NewItem -ConfirmUpload 'UPLOAD HIDDEN' `
  -SteamCmdPath $env:STEAMCMD_PATH -SteamUser YOUR_ACCOUNT -PreviewFile ./cover.png
```

The script passes only the account name; SteamCMD handles password/Steam Guard interactively. Do not add a password parameter, unattended login config, credentials file, transcript or credential logging. SteamCMD's own account/session handling is outside this repository. Accept Valve's Workshop legal agreement on Steam if prompted, then verify the item's files and intended visibility. A successful exit code alone is insufficient evidence of acceptance.

SteamCMD writes `publishedfileid` back into `item.vdf`. The script preserves it in `.local/workshop/state.json` and recovers it from VDF before any regeneration. Back up **both files** securely; neither contains a password. This project also commits its non-sensitive App ID and item ID in workshop/item.json. Fresh clones use that tracked identity even without local state; conflicting IDs are rejected. Once an ID exists the script updates it and refuses `-NewItem`.

If creation is interrupted and no ID was saved, an upload-pending marker blocks another creation. Inspect the account's Workshop items and SteamCMD output, recover the existing ID into state.json (format below), and only then retry. If no item was created, verify that manually before removing the marker. Never assume a failed process means Steam created nothing.

```json
{ "publishedfileid": "YOUR_EXISTING_NUMERIC_ITEM_ID" }
```

## Updates and public visibility

After testing a new runtime version, update changelog/version, commit, tag and publish the authorized GitHub Release. Documentation and Workshop-description-only changes do not require a new runtime version. Update the existing item **without `-NewItem`**. Changenote is generated from the current version's changelog.

Visibility defaults to the `visibility` setting in `workshop/item.json`, or Hidden when absent. Preparation never uploads. Every real upload must provide `-ConfirmUpload 'UPLOAD HIDDEN'` or `-ConfirmUpload 'UPLOAD PUBLIC'` matching its effective visibility. `-Visibility Hidden` or `-Visibility Public` can explicitly override the configuration. A first creation must always be hidden; the public path accepts only an existing item ID.

On 2026-11-11 the owner explicitly authorized making item **3837800051** public after the bilingual README and source-only description changes. Its configured target is now Public so future updates preserve public visibility instead of silently hiding it. To upload an authorized public update:

```powershell
./publish-workshop.ps1 -Upload -Visibility Public -ConfirmUpload 'UPLOAD PUBLIC' `
  -SteamUser YOUR_ACCOUNT -PreviewFile ./workshop/cover.jpg
```

Do not change visibility without the owner's authorization. Confirm the returned ID, then verify the actual remote visibility with Steam's metadata API and/or the item page. The publication record is kept in agent.md.

## Current delivery record

- [Public GitHub Release v0.1.5](https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases/tag/v0.1.5) contains the current runtime ZIP and checksum file; previous releases remain available.
- [Steam Workshop item 3837800051](https://steamcommunity.com/sharedfiles/filedetails/?id=3837800051) is PUBLIC after explicit owner authorization. Anonymous metadata verification returned result=1, visibility=0 and consumer_app_id=4348910, with the correct underscore title and source-only bilingual description. The item ID is unchanged from the original hidden creation.
- README.md is the Chinese repository homepage; README.en.md provides the equivalent English version with language buttons in both. Workshop subscriptions, updates and feedback use Steam; its Source section only links the repository.
- Runtime package is now 0.1.5 with fuliezi credits and a Chinese-first bilingual in-game description, declaring only 0.46D for the verified public 100-Rev13 / 1.0.0.13 build 26525552; prior packages and tags remain intact. Input behavior is unchanged. The latest verification record is in agent.md.
