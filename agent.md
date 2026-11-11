# AI handoff / 开发记录

Last updated: 2026-11-11 (Asia/Singapore).

## User intent and boundaries

Create the open-source project **ProbablyStolen-DragAwareHotkeys** inside `my_mod` in the installed game directory. Prevent all Storage Coordinator shortcuts while dragging items, preserve rotation and idle shortcuts, change no saves or original game assemblies. User backed up game data. The owner subsequently authorized creating and pushing the public GitHub repository ProbablyStolen-DragAwareHotkeys and the first **hidden** Workshop upload. The owner subsequently explicitly authorized making existing item 3837800051 public after the bilingual README and source-only description revision; see the latest publication record below. Do not store Steam credentials or Guard codes.

## Completed implementation

- Independent Git repository on main. MIT license, bilingual documentation, SemVer 0.1.4, changelog, Codex rules and CI. GitHub delivery status is recorded below.
- Native IMod entry; one automatic Harmony prefix on private static `MachineStorageCoordinator.HandleHotkeys`. Checks public `ItemMouseDragHandler.current.IsDraggingItem` with Unity null comparison. No native cancellation hook exists in inspected build. All actual API evidence is in docs/API-INVESTIGATION.md.
- Enabled flag, Release lifecycle logs, Debug drag-transition logs, fail-open state-read exception handling with once-per-enable warning. No file/save/network APIs in runtime DLL, empty capabilities.
- Root build/install/package/publish-workshop PowerShell scripts. Configuration via parameter/env/ignored JSON. Exact DLL + manifest packaging. Upload defaults to preparation; explicit confirmation matching Hidden/Public visibility is required. Preserves/recover Workshop ID, refuses duplicate creation after uncertain upload.
- Ignored config.local.json points at this installation for convenient local commands; never stage it. Public config.example.json remains path-free.
- Public CI uses isolated API doubles for contract checks; optional manually dispatched trusted self-hosted CI builds actual mod and compares clean DLL hashes. Game binaries never leave the local machine through this workflow.
- Workshop descriptions updated for official game 1.1.0, bilingual display name and owner-reported acceptance. Original cover in workshop/cover.jpg (1024 square, under 1 MB), provenance in workshop/ARTWORK.md. SteamCMD downloaded from Valve and signature validated; installed under ignored .local/steamcmd. No password/Guard code handled by the agent.

## Development process and evidence

1. Inspected initially empty my_mod, parent game files, installed mods listing, SDK 6.0.410 and Git. Parent had no Git repo; preserved existing game and mod files.
2. Read local developer guide and online reference repositories; installed ILSpy 8.2 locally. Private full decompilation and reference clones are under ignored `.local/` only. Never commit them.
3. Located independent coordinator direct Unity polling and item rotation paths. Chose prefix on only HandleHotkeys to preserve key capture/picking UI. Better Key Bindings handles a different configurable binding path.
4. Built actual Release and Debug DLLs successfully (zero warnings/errors), ran 10 contract checks per configuration. Real signatures verified.
5. Built scanner harness: desktop .NET Framework execution initially failed due to missing netstandard2.1 String.Split overload. Changed execution to .NET 6; actual game scan passes (14 methods, zero capabilities/hard flags, refused false, no error). The harness is a development tool, not shipped.
6. Generated runtime ZIP and hidden VDF in preparation mode. Further verification results are recorded in docs/TESTING.md and final handoff below.
7. Compared Release DLL hashes across clean rebuilds: identical (`E38EA105C93C59DF31FE2C709269E312F1F94F2BB233D8767DC156816238372C`). Inspected ZIP: exactly two allowlisted runtime files. Added/passed offline Workshop regression checks with fake SteamCMD in an isolated ignored fixture; no real account or Workshop item involved. Public CI also runs these offline checks. Script syntax/version/whitespace checks passed. Initial local commit records the complete scaffold and implementation; no tag or remote.
8. Added a Chinese translation after the English manual acceptance checklist in docs/TESTING.md, including setup, all 13 test items and debugging notes. Both language versions describe the same pending tests; keep their checkboxes synchronized when recording results. Documentation-only change; no runtime behavior changed.

## Known limits / required next work

- Game reference fingerprint is Steam build 26525552, with stale internal VERSION 100-Rev13; the owner reports the supported official release as 1.1.0; game assembly SHA-256 and reference commits recorded in investigation document. Latest online guide describes newer helpers absent from installed build. Do not introduce them without verification.
- The owner reports completing official-game manual acceptance with no bugs on version 1.1.0. Both translated checklists record this user-reported evidence. Third-party mod coexistence is excluded from supported scope. Version 0.1.1 changes metadata/name only; reinstall and restart to confirm the updated Mods menu display. The agent has not independently observed gameplay.
- Contract doubles do not model Unity or load Harmony. Real scanner is a static check, not a gameplay test.
- Close the game before installing the 0.1.1 metadata/name update. Runtime input logic is unchanged from the accepted 0.1.0 implementation.
- SteamCMD path is configured in ignored config.local.json; cover prepared. Steam account login is interactive in a local window. The owner confirmed no Workshop agreement prompt remains; anonymous remote metadata will verify public delivery after the authorized update.
- GitHub remote/push and first hidden Steam upload are authorized. Do not claim a remote release or Workshop ID until verified; record concrete URLs and state after delivery. Public visibility for existing item 3837800051 was explicitly authorized on 2026-11-11 after the bilingual README revision request.
- Generated VDF/state are ignored. Preserve returned publishedfileid after future upload across machines. First creation remains forced Hidden; existing-item uploads now support explicitly confirmed Public visibility. The tracked configuration preserves the selected visibility across future updates.

## Useful commands

From this project root, set `PROBABLY_STOLEN_GAME_DIR` to the parent installed game directory or use ignored config.local.json. Then run:

```powershell
./build.ps1
dotnet run --project tests/Contracts/Contracts.csproj -c Release
dotnet run --project tests/Contracts/Contracts.csproj -c Debug
./scripts/check.ps1
./tests/Workshop.ps1
./scripts/check-game.ps1
./package.ps1
./publish-workshop.ps1 # preparation only
```

Read AGENTS.md before editing; do not include local absolute paths or private log/account data in tracked files.

## 0.1.1 release preparation — 2026-11-11

- Fixed GameVersions to 1.1.0 and added Chinese display name 解决拖拽时按键冲突. Removed the third-party coexistence checklist row, recorded the remaining 12 rows as passed based on owner feedback. No input code changed.
- Rebuilt Release/Debug and passed both sets of 10 contract checks, actual-game scanner (14 methods; no capabilities, hard flags, refusals or errors), script checks and offline Workshop safeguards. Release DLL SHA-256: 7341770A95DE11999F0AD96DACF699790AA86DF8B98AE3BFC5CBA07BBEC982B9.
- Original cover generated and visually reviewed; upload-ready JPEG is tracked, development downloads and Steam login state remain ignored.

- Installed the Release 0.1.1 DLL and corrected manifest into this mod's Mods/drag_aware_hotkeys folder after the game exited. Original game DLL fingerprint remains unchanged. Updated Mods-menu display still needs the owner's quick visual confirmation.
- Created the authorized public repository https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys using authenticated GitHub CLI (the connector lacks repository-creation capability). Local origin configured. Git push and CI verification follow this release commit. Steam login opened in a local interactive window; no password/Guard code stored by the project.

## Delivery status — 2026-11-11

- Public GitHub repository: https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys . main and annotated v0.1.1 pushed; tag/main initial Actions runs passed (43007272811 and 43007273949).
- The owner explicitly authorized public GitHub Release after reviewing the prepared draft. Published https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases/tag/v0.1.1 with runtime ZIP and SHA256SUMS.txt. Downloaded assets and verified ZIP checksum.
- Tag v0.1.1 contains the released runtime source. Subsequent main commits improve release tooling and documentation only; do not move the published tag. No runtime behavior/version changes are needed for these tooling-only fixes.
- First interactive upload attempt stopped before SteamCMD due to Windows PowerShell 5.1 decoding the manifest as ANSI. No upload marker was created, so a duplicate item could not have been created by that failed preparation. Fixed explicit UTF-8 reads in shared helpers and publisher; verified full preparation under 5.1 and offline tests under both shells. CI now covers 5.1 metadata too.
- The authorized first hidden upload completed successfully. SteamCMD returned publishedfileid **3837800051**; .local/workshop/upload-result.json reports finished. The returned VDF retains appid 4348910, visibility 2 and the correct bilingual title. Public Workshop visibility remains unauthorized. The anonymous metadata API returns result 9 (not accessible). The owner subsequently confirmed the page loads normally and there is no legal-agreement prompt.

- Workshop identity is now tracked in workshop/item.json (App ID and item ID only; no local paths or login state). Publisher prefers this identity, rejects conflicting local IDs and refuses NewItem for this project, even in a fresh clone. First-creation, recovery, fresh-clone and conflicting-state tests pass under PowerShell 7 and 5.1. Future updates must omit -NewItem.
- Workshop owner page: https://steamcommunity.com/sharedfiles/filedetails/?id=3837800051 . The owner confirmed the page loads with no legal-agreement problem. Their reported description formatting issues were corrected in the update below; the owner subsequently confirmed the description fixes display correctly. Do not change visibility to public without explicit authorization.

## Workshop description correction — 2026-11-11

- Owner inspected the hidden page: it loaded normally with no legal-agreement prompt, but displayed literal backslash-n characters, had unequal translations, and needed Chinese first plus a GitHub link.
- Root cause: the initial serializer escaped newlines for a SteamCMD KeyValues path that displays those sequences verbatim. Changed to literal multiline quoted values, forward-slash paths, and rejection of embedded double quotes/nulls. Reference collection scripts/workshop.py independently uses literal multiline values.
- Rewrote Chinese/English descriptions with matching feature, install/uninstall, compatibility, saves/permissions and source/feedback sections. Chinese appears first, followed by English. Both link repository, Releases and Issues. Description is 3393 UTF-8 bytes, below the checked 8000-byte limit.
- Added regression checks for literal newlines, language order, bilingual section/bullet/link parity and repository link. All pass under PowerShell 7 and Windows PowerShell 5.1.
- Successfully updated existing item **3837800051** using the saved/tracked identity, omitting NewItem. Local upload result reports finished at 2026-11-11T10:59:46Z. Visibility remains 2 (hidden). Runtime files and public GitHub Release 0.1.1 are unchanged; only publishing text/tooling changed.
- The owner confirmed the corrected description now displays normally; no further description issues were reported. Do not make Workshop public without a separate explicit instruction.

## Display-title refinement — 2026-11-11

- The owner confirmed the previous Workshop description corrections and requested replacing parentheses with an underscore in the title. New exact display name: **Drag-Aware Hotkeys_解决拖拽时按键冲突**.
- Apply as metadata-only version 0.1.2 across manifest, README and Workshop title/description. Input source and official game 1.1.0 support are unchanged. Preserve immutable 0.1.1 tag and published assets; use a separate 0.1.2 package/tag. Update the same Workshop item 3837800051 with visibility 2; public Workshop visibility remains unauthorized.

- 0.1.2 Release build, installed-game signature/scanner (14 methods, no capabilities/hard flags/refusals/errors), offline publisher checks and repository checks passed. Installed locally with game closed. Hidden update finished successfully at 2026-11-11T11:04:30Z; returned VDF and state retain item 3837800051 with exact underscore title and visibility 2. GitHub 0.1.2 package/tag follows this maintenance commit; do not rewrite 0.1.1 assets or tag.

## Chinese-first README and public-launch preparation — 2026-11-11

- The owner confirmed the mod has no obvious remaining issues and requested complete matching Chinese/English READMEs, default Chinese, with language buttons. README.md and README.en.md now have the same eight sections, command blocks, link targets and technical content. Local SVG buttons link between the files; GitHub renders README.md as the repository default. No runtime scripts are needed for language switching.
- Workshop's final section now contains only Source/源码 and one repository link in each language. Removed separate download and issue links as requested; subscriptions and feedback belong on Steam. Both Workshop translations remain aligned, Chinese first.
- The owner explicitly authorized changing existing item 3837800051 from hidden to PUBLIC. Public visibility is no longer prohibited for this item. No new item is created. Runtime version stays 0.1.2 because only docs, description and publishing controls changed.
- Publisher now resolves Hidden/Public visibility from an explicit parameter or tracked item configuration, defaults to Hidden without configuration, refuses first creation as Public, and requires UPLOAD HIDDEN / UPLOAD PUBLIC matching the requested visibility. Tracked target is Public so later updates do not inadvertently hide it. Offline tests cover those controls under PowerShell 7 and 5.1; no credentials are added.

## Verified public Workshop publication — 2026-11-11

- The public update completed successfully. Anonymous Steam GetPublishedFileDetails returned result=1, visibility=0, publishedfileid=3837800051, consumer_app_id=4348910 and the exact title Drag-Aware Hotkeys_解决拖拽时按键冲突. This confirms actual public accessibility, not only the local VDF request. Returned description has real line breaks, Chinese first, Source/源码 headings, and only repository links in that final section. No Releases/Issues links remain there. Full response is kept in ignored .local/workshop/public-verification.json.
- Public player page: https://steamcommunity.com/sharedfiles/filedetails/?id=3837800051 . The item remains the original item; do not recreate it. Future updates preserve configured Public visibility and require UPLOAD PUBLIC confirmation. Password/Guard input stays interactive and outside the repository.
- GitHub main now serves Chinese README.md by default. README.en.md provides the equivalent complete English content; both have local SVG language buttons. Checked eight-section parity, matching command blocks/link targets, and local destinations. GitHub API confirms default README.md and its rendered HTML includes the English button and Chinese body.
- GitHub source commit 402bea4 includes the README, source-only descriptions and public-upload controls. Local PowerShell 7/5.1 checks passed. Final CI status is reported with the task result. Runtime is still 0.1.2; no new package version or published tag rewrite is needed for these documentation/description changes.

## 0.1.3 compatibility-warning fix — 2026-11-11

- User supplied an actual Mods-menu screenshot showing 1.1.0 in red and a warning against running game 0.46D. Current Player.log confirms the local 0.1.2 mod initialized with running=True, so this was a metadata warning, not patch failure. Do not copy raw logs into Git.
- Root cause: the previous metadata change discarded the runtime identifier based on the release label. Installed ModUIManager actually compares GameVersions to Application.version. Retain both 1.1.0 and 0.46D; do not remove the latter as merely stale. Overall warning uses Any(match), while individual entries are independently colored.
- Added an optional ReportedGameVersion argument to the development harness. It invokes the actual installed NormalizeVersion method and requires an exact normalized manifest match. Reproduced failure with old 0.1.2 manifest for 0.46D before applying the alias fix. No game source is copied and no game methods are patched by this check.
- Metadata-only version 0.1.3; input source unchanged. Updated bilingual README, Workshop descriptions and changelog. Preserve prior release tags/packages; update existing public item 3837800051 only. Visual post-restart confirmation remains pending until actually observed.

- Validation after the fix passed for both explicitly reported values 0.46D and 1.1.0 using the real installed normalizer. Actual-game scanner: 14 methods, no capabilities/hard flags/refusals/errors. Release and Debug builds and 10 behavioral checks per configuration passed. Offline publication checks, README parity and script checks passed; the game-version regression also passed under Windows PowerShell 5.1. Installed 0.1.3 locally while the game was closed; package contains the fixed manifest. Actual restarted menu appearance is still pending owner observation.

- Published https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases/tag/v0.1.3 with runtime ZIP and checksum file. Public Workshop update completed at 2026-11-11T11:26:51Z; anonymous metadata confirms the same item 3837800051 remains public and now describes 0.1.3 / 0.46D. Local installed manifest equals the packaged fixed manifest. Restarted menu observation remains pending; do not claim the owner has already seen the warning disappear.

## Verified release-number correction — 2026-11-11

- The owner reconsidered the 1.1.0 label and supplied screenshots proving Battery Manager 1.1.0 is a ModVersion, with its GameVersions showing 0.46D. Earlier owner-reported 1.1.0 game-version assumptions and rules are now withdrawn. Historical entries above record the mistake, not current compatibility policy.
- Web research: official Steam news' newest public patch is 100-Rev13 Hotfix; developer APIChanges labels 100-Rev14 / 1.0.0.14 as beta and explains the stale 0.46D runtime value. By the documented numbering rule Rev13 is 1.0.0.13. Direct anonymous SteamCMD app_info_print confirms public build 26525552 and open_beta build 26556045. Local installed build 26525552 and PlayerStore VERSION 100-Rev13 agree. Source links and date are in docs/GAME-VERSIONS.md; raw public queries remain ignored locally.
- New metadata-only 0.1.4: manifest GameVersions contains ONLY 0.46D for the current old matcher. README/Workshop clearly identify tested public 100-Rev13 / 1.0.0.13 / build 26525552. No claim of beta compatibility. Never reintroduce 1.1.0 based on the older logs above. Runtime input patch unchanged.
- The screenshot of 0.1.3 confirms the 0.46D entry is green and the prior overall warning is absent. Removing the false 1.1.0 entry also removes its individual red entry. New 0.1.4 post-restart observation remains separate.

- 0.1.4 Release build, actual-game API/scanner, exact normalized 0.46D match, offline publishing and README link/command parity checks passed. Manifest has exactly one GameVersions entry: 0.46D. Installed with game closed and packaged; current user screenshot independently confirms that legacy identifier is green in the installed menu. Old 1.1.0 references above are historical errors, not support claims.

- Published GitHub Release v0.1.4 and updated the same PUBLIC Workshop item 3837800051; upload finished at 2026-11-11T11:36:01Z. Anonymous metadata confirms visibility=0 and the new 0.1.4 / 100-Rev13 / build 26525552 statement. Source, package and installed manifest bytes agree and declare only 0.46D. Added factual-correction notices to 0.1.1–0.1.3 release notes while preserving their original assets and tags.
