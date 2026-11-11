# Drag-Aware Hotkeys_解决拖拽时按键冲突

[![简体中文](docs/assets/language-zh.svg)](README.md) [![English](docs/assets/language-en.svg)](README.en.md)

A lightweight mod for *Probably Stolen*: suppress Storage Coordinator container shortcuts while dragging an item, so rotating it does not accidentally open storage. This repository makes the source available for players to review, understand and build themselves.

| Item | Status |
| --- | --- |
| Mod version | **0.1.5** |
| Author | **fuliezi** |
| Tested game | Public **100-Rev13 / 1.0.0.13**, build **26525552** |
| Menu compatibility identifier | **0.46D** (the legacy runtime version retained by this public build) |
| Acceptance | The owner completed official-game acceptance with no obvious issues reported |
| Support scope | Official game; third-party mod compatibility is not promised |

See [game-version verification](docs/GAME-VERSIONS.md) for evidence. The earlier game-version claim `1.1.0` confused another mod's version with the game version and is withdrawn. `100-Rev14 / 1.0.0.14` is beta, remains untested and is not claimed as supported.

## Features

- Blocks all Storage Coordinator container shortcuts while dragging an item.
- Preserves Q/E rotation, flipping, orientation reset and placement; storage shortcuts work normally when no item is being dragged.
- Does not edit saves, replace original game assemblies, require another mod or request extra capabilities. Uses the native loader and the game's own Harmony library.

## Install and uninstall

Use the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3837800051) for subscriptions, updates and feedback. After subscribing, enable this mod in the game's Mods menu, review permissions and restart the game.

For manual installation, standalone packages are also available on [GitHub Releases](https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases): close the game and extract the archive's `drag_aware_hotkeys/` folder into the game's `Mods/` directory. Packages contain only the mod DLL and `manifest.xml`; do not copy the source repository into Mods.

Disable and restart to restore vanilla behavior. To uninstall, unsubscribe or close the game and remove the local `Mods/drag_aware_hotkeys` folder. A local copy with the same mod ID takes priority over the Workshop copy. Restart after rebuilding or updating; local Developer mode in the Mods menu can reduce repeated trust prompts during development.

## Build from source

Requires Windows PowerShell 5.1+ or PowerShell 7+, Git, a .NET SDK supporting C# 10 / netstandard2.1, and a legally installed full game. CI pins SDK 6.0.410; .NET 6 is out of support, so future maintenance should consider upgrading the development SDK. The runtime mod still targets the game's netstandard2.1 contract.

Set the game path from the project root (this example assumes the repository is in the game's `my_mod` subdirectory), then run:

```powershell
$env:PROBABLY_STOLEN_GAME_DIR = (Resolve-Path '..').Path
./build.ps1
./install-local.ps1
./package.ps1
```

Alternatively pass `-GameDir`, or copy `config.example.json` to ignored `config.local.json` and fill `GameDir`. Building does not install automatically; exit the game before installation. Machine-specific absolute path configuration, game DLLs, saves, logs and login state stay out of Git.

## Checks and diagnostics

```powershell
dotnet run --project tests/Contracts/Contracts.csproj -c Release
./scripts/check.ps1
./tests/Workshop.ps1
./scripts/check-game.ps1 -ReportedGameVersion '0.46D'
./install-local.ps1 -Configuration Debug
```

Contract checks use hand-written doubles to verify lifecycle, drag state and exception fallback; they do not establish real Unity input timing or Harmony application. `check-game.ps1` validates the installed game's actual APIs and runs its mod scanner under .NET 6. Workshop checks run entirely offline with fake SteamCMD and cover item identity, explicit upload confirmation, visibility, UTF-8 and newline safeguards.

Debug builds log drag transitions; Release builds log lifecycle and the first state-read failure per enable. Logs are in `%USERPROFILE%/AppData/LocalLow/Questing Goose Studio/Probably Stolen/Player.log`. An optional `dev.txt` in the game root enables F8/F9; the project neither creates nor ships it.

Public CI runs contract, script and offline publishing checks. Real game builds run only in a manually dispatched trusted self-hosted job, which compares clean-rebuild DLL hashes. Public runners do not download game assemblies and cannot build the real mod without those references; game references are never uploaded to GitHub.

## Project layout

| Path | Purpose |
| --- | --- |
| `src/`, `mod/` | C# source and native-loader manifest |
| `tests/`, `scripts/` | Behavioral checks, offline publishing checks and development tools |
| `docs/` | [API investigation](docs/API-INVESTIGATION.md), [acceptance checklist](docs/TESTING.md), [release process](docs/RELEASING.md) |
| `workshop/` | Matching Chinese/English descriptions, cover and non-sensitive item identity |
| `AGENTS.md`, `agent.md` | AI development rules and handoff record |

## Versions and publishing

Uses Semantic Versioning, Conventional Commits and the `main` branch; published tags and packages retain their history. See [CHANGELOG.md](CHANGELOG.md). The patch targets only the Storage Coordinator's private hotkey handler; revalidate its API and behavior after game updates.

`publish-workshop.ps1` only prepares SteamCMD configuration by default and does not upload. Uploading requires `UPLOAD HIDDEN` or `UPLOAD PUBLIC` confirmation matching the intended visibility; first creation must be hidden. The existing item ID is kept in `workshop/item.json`, so fresh clones update the same item and conflicting IDs are rejected. Steam passwords and Guard codes are entered interactively on the local machine, never written into the project. See the [release instructions](docs/RELEASING.md) for the full process.

## References

- [Game Modding Guide](https://github.com/dragonpan2/probably-stolen-modding/blob/main/ModdingGuide.md)
- [Reference mod collection](https://github.com/KCN-judu/ProbablyStolen-Mods)
- [Better Key Bindings source reference](https://github.com/KCN-judu/ProbablyStolen-BetterKeyBindings); used for technical investigation, not a compatibility promise

## License

Project code is [MIT licensed](LICENSE). Probably Stolen, Unity, Harmony and third-party assets belong to their respective owners; no game code or assemblies are distributed here. See [ARTWORK.md](workshop/ARTWORK.md) for the generated cover's provenance and usage terms.
