# AI handoff / 开发记录

Last updated: 2026-11-11 (Asia/Singapore).

## User intent and boundaries

Create the open-source project **ProbablyStolen-DragAwareHotkeys** inside `my_mod` in the installed game directory. Prevent all Storage Coordinator shortcuts while dragging items, preserve rotation and idle shortcuts, change no saves or original game assemblies. User backed up game data. Current authorization: local investigation, implementation, builds, documents and Git initialization; **no GitHub remote/push, public Release or Steam upload**. Remote name/visibility and publication require later explicit user confirmation.

## Completed implementation

- Independent Git repository on main; no remote. MIT license, English README with Chinese explanation, SemVer 0.1.0 development candidate, changelog, Codex rules, CI.
- Native IMod entry; one automatic Harmony prefix on private static `MachineStorageCoordinator.HandleHotkeys`. Checks public `ItemMouseDragHandler.current.IsDraggingItem` with Unity null comparison. No native cancellation hook exists in inspected build. All actual API evidence is in docs/API-INVESTIGATION.md.
- Enabled flag, Release lifecycle logs, Debug drag-transition logs, fail-open state-read exception handling with once-per-enable warning. No file/save/network APIs in runtime DLL, empty capabilities.
- Root build/install/package/publish-workshop PowerShell scripts. Configuration via parameter/env/ignored JSON. Exact DLL + manifest packaging. Upload defaults to preparation; explicit hidden upload flags required. Preserves/recover Workshop ID, refuses duplicate creation after uncertain upload.
- Ignored config.local.json points at this installation for convenient local commands; never stage it. Public config.example.json remains path-free.
- Public CI uses isolated API doubles for contract checks; optional manually dispatched trusted self-hosted CI builds actual mod and compares clean DLL hashes. Game binaries never leave the local machine through this workflow.
- Workshop descriptions in English/Chinese and cover design brief. Hidden VDF generated locally under `.local/workshop/`, publishedfileid currently 0. No cover created, no SteamCMD launched.

## Development process and evidence

1. Inspected initially empty my_mod, parent game files, installed mods listing, SDK 6.0.410 and Git. Parent had no Git repo; preserved existing game and mod files.
2. Read local developer guide and online reference repositories; installed ILSpy 8.2 locally. Private full decompilation and reference clones are under ignored `.local/` only. Never commit them.
3. Located independent coordinator direct Unity polling and item rotation paths. Chose prefix on only HandleHotkeys to preserve key capture/picking UI. Better Key Bindings handles a different configurable binding path.
4. Built actual Release and Debug DLLs successfully (zero warnings/errors), ran 10 contract checks per configuration. Real signatures verified.
5. Built scanner harness: desktop .NET Framework execution initially failed due to missing netstandard2.1 String.Split overload. Changed execution to .NET 6; actual game scan passes (14 methods, zero capabilities/hard flags, refused false, no error). The harness is a development tool, not shipped.
6. Generated runtime ZIP and hidden VDF in preparation mode. Further verification results are recorded in docs/TESTING.md and final handoff below.
7. Compared Release DLL hashes across clean rebuilds: identical (`E38EA105C93C59DF31FE2C709269E312F1F94F2BB233D8767DC156816238372C`). Inspected ZIP: exactly two allowlisted runtime files. Added/passed offline Workshop regression checks with fake SteamCMD in an isolated ignored fixture; no real account or Workshop item involved. Public CI also runs these offline checks. Script syntax/version/whitespace checks passed. Initial local commit records the complete scaffold and implementation; no tag or remote.

## Known limits / required next work

- Game is Steam build 26525552, VERSION 100-Rev13; game assembly SHA-256 and reference commits recorded in investigation document. Latest online guide describes newer helpers absent from installed build. Do not introduce them without verification.
- **No game has been launched by this project, and no local installation has been performed.** Full input matrix, automatic Harmony application, first drag frame/release ordering, destroyed components and Better Key Bindings coexistence remain unverified.
- Contract doubles do not model Unity or load Harmony. Real scanner is a static check, not a gameplay test.
- User should close the game, run install-local.ps1 with configured GameDir, enable and restart, then complete docs/TESTING.md. Debug install helps inspect transition logs.
- SteamCMD absent from PATH; user must install/configure it later. Cover and first Steam agreement still pending. Upload/update live Steam behavior is untested.
- No Git tag, remote, GitHub Release or Workshop item exists. Do not claim publication or acceptance. Before a release update statuses to reflect actual game tests, verify author display name, cover, repo permissions, and separate explicit upload authorization.
- Generated VDF/state are ignored. Preserve returned publishedfileid after future upload across machines. Script keeps every upload hidden, including later updates; public visibility is a separate manual authorized action.

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
