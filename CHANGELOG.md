# Changelog

All notable changes are recorded here. Versions follow Semantic Versioning.

## [Unreleased]

- No changes yet.

## [0.1.6] - 2026-11-11

### Fixed

- Bundle preview.png at the mod root so the native Mods menu displays the existing cover for local copies and as an offline/failed-download fallback for Workshop copies.
- Include the preview in build, install and release packages; permit safe upgrades from the exact legacy two-file installation layout.
- Reuse the existing cover without changing its pixels. Input behavior, author and compatibility declaration are unchanged.

## [0.1.5] - 2026-11-11

### Changed

- Set the in-game mod author to fuliezi and align current README credits, copyright, assembly/package metadata and artwork attribution.
- Provide equivalent Chinese-first and English-second in-game descriptions, separated by a blank line.
- Input behavior and the verified public-game compatibility declaration are unchanged.

## [0.1.4] - 2026-11-11

### Fixed

- Withdraw the unsupported 1.1.0 game-version claim, which confused another mod's ModVersion with the game version. Declare only the installed public build's actual menu identifier 0.46D.
- Document verified public release 100-Rev13 (1.0.0.13), build 26525552, using official Steam news, live SteamCMD branch metadata and installed code. Keep beta 100-Rev14 explicitly untested.
- Correct bilingual README, Workshop text and AI rules; input logic is unchanged.

## [0.1.3] - 2026-11-11

### Fixed

- Declare the installed build's runtime version 0.46D alongside the owner-reported 1.1.0 release label, fixing the overall Mods-menu version-mismatch warning without changing the input patch.
- Add an installed-game normalization check using the actual ModUIManager method and an explicitly supplied reported game version; reproduce the old mismatch and verify the fixed manifest.

### Included publishing and documentation improvements

- Align Chinese/English README content with Chinese as the default and local language-switch buttons.
- Limit the Workshop Source section to the repository link; keep downloads and feedback on Steam.
- Support explicitly confirmed public updates for the existing Workshop item while forcing first creations to remain hidden.

- Preserve bilingual Workshop metadata in Windows PowerShell 5.1 by reading manifests and descriptions explicitly as UTF-8; add matching CI coverage. Runtime DLL and mod version are unchanged.
- Keep the created Workshop identity in source control and reject conflicting local state, so fresh clones update the existing item.
- Fix literal backslash-n text in Workshop descriptions by writing actual multiline VDF strings; place Chinese first, align both translations and add repository, release and issue links.

## [0.1.2] - 2026-11-11

### Changed

- Rename the game and Workshop display title to Drag-Aware Hotkeys_解决拖拽时按键冲突, replacing the parentheses with an underscore.
- Input behavior and official game 1.1.0 compatibility are unchanged.

## [0.1.1] - 2026-11-11

### Fixed

- Declare game compatibility as 1.1.0, matching the version reported and tested by the owner, instead of inferring it from a stale internal version constant.

### Changed

- Display the bilingual name Drag-Aware Hotkeys（解决拖拽时按键冲突）in the game and on the Workshop.
- Scope acceptance to the official game; remove the Better Key Bindings coexistence requirement.
- Record the owner's completed official-game acceptance with no bugs reported. Input behavior is unchanged from 0.1.0.

## [0.1.0] - 2026-11-11

### Added

- Suppress Storage Coordinator hotkeys while the game's item drag state is active.
- Preserve idle storage shortcuts and the original rotation input path.
- Lifecycle logs, Debug drag diagnostics, and a one-time fallback warning.
- Local build/install/package tools, hidden Workshop preparation and item ID recovery.
- Contract checks, installed-game scanner harness, CI and bilingual documentation.

### Validation status

- Development candidate; game interaction tests and Workshop upload remain pending.
