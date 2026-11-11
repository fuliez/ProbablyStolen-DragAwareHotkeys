# ProbablyStolen-DragAwareHotkeys

A small native-loader mod for **Probably Stolen**: Storage Coordinator shortcuts are ignored while an item is being dragged. Item rotation (including Q/E), flipping, and placement stay with the game. When no item is being dragged, storage shortcuts work normally.

**Status: 0.1.0 development candidate. Compiles against Steam build 26525552 / 100-Rev13; in-game acceptance is pending.** No save edits or replacement game assemblies. No dependency on Better Key Bindings. Uses the game's own Harmony library.

## Build and install

Requires Windows PowerShell 5.1+ or PowerShell 7+, Git, .NET SDK 6.0.410+ supporting C# 10 and netstandard2.1, and a legally installed full game. CI uses SDK 6.0.410; .NET 6 is out of support, so upgrading the development SDK is recommended as future maintenance. The runtime mod targets the game's netstandard2.1 contract.

Set the game directory once in the current shell:

```powershell
$env:PROBABLY_STOLEN_GAME_DIR = (Resolve-Path '..').Path # when my_mod is inside the game directory
./build.ps1
./install-local.ps1
./package.ps1
```

Alternatively pass `-GameDir` or copy `config.example.json` to ignored `config.local.json` and fill `GameDir`. No machine-specific paths are committed. Building does not install. Close the game before installation. Enable **Drag-Aware Hotkeys** in the game's Mods menu, review its declared permissions (none), and restart. For updates, rebuild/install and restart; local Developer mode can avoid repeated trust prompts during development. Remove `Mods/drag_aware_hotkeys` and restart to uninstall. Local copies with the same mod ID take priority over Workshop subscriptions.

The release ZIP contains one `drag_aware_hotkeys/` folder with only the mod DLL and `manifest.xml`. Do not copy the repository into `Mods`.

## Checks and diagnostics

```powershell
dotnet run --project tests/Contracts/Contracts.csproj -c Release
./scripts/check.ps1
./tests/Workshop.ps1
./scripts/check-game.ps1
./install-local.ps1 -Configuration Debug
```

Contract tests use hand-authored doubles; they check enable/disable, idle/drag, state failure and diagnostic throttling. They do **not** prove Harmony application, Unity lifetime behavior or input ordering. `check-game.ps1` validates signatures and runs the actual installed game's mod scanner outside Unity under .NET 6. Debug builds log drag transitions; Release logs lifecycle and one state-read failure per enable. See the game's Player.log under `%USERPROFILE%/AppData/LocalLow/Questing Goose Studio/Probably Stolen/`. Optional `dev.txt` in the game root enables F8/F9; it is not created or shipped by this project.

See [investigation](docs/API-INVESTIGATION.md), [manual tests](docs/TESTING.md), [release process](docs/RELEASING.md), and [changelog](CHANGELOG.md). Public CI runs contract compilation and repository/script checks. An optional manually triggered trusted self-hosted job performs a real game build and compares clean-build DLL hashes. No game references are uploaded. Public runners cannot build the real DLL without game references.

## Workshop and GitHub

The local repository starts on `main` and uses Semantic Versioning and Conventional Commits. No remote is configured. Create/push a remote only after the owner confirms its name and visibility. Do not publish Releases or Workshop uploads without explicit authorization.

`publish-workshop.ps1` prepares a hidden (`visibility=2`) SteamCMD VDF by default and does not start SteamCMD. Its ignored `.local/workshop/` folder preserves the item ID. It intentionally has no public visibility option. See [release instructions](docs/RELEASING.md) before any upload.

## 中文说明

拖动物品时，屏蔽储物协调器的全部容器快捷键；未拖动时恢复正常。Q/E 旋转、翻转、放置仍由游戏处理。无需 Better Key Bindings，不修改存档、不覆盖原始程序集，只通过游戏原生 Mod 加载器应用一个小范围 Harmony 前置补丁。

当前是 **0.1.0 待游戏内验收版本**，已针对本机 `100-Rev13 / Steam build 26525552` 编译。构建、安装、打包命令见上方。安装后请在 Mods 菜单启用并重启；先按[测试清单](docs/TESTING.md)验证功能。未创建远程仓库、Release 或 Workshop 物品；首次上传强制隐藏，必须显式确认。请保管 `.local/workshop/` 中返回的物品 ID，后续只更新该物品。

## References and license

- [Game modding guide](https://github.com/dragonpan2/probably-stolen-modding/blob/main/ModdingGuide.md)
- [Reference mod collection](https://github.com/KCN-judu/ProbablyStolen-Mods)
- [Better Key Bindings](https://github.com/KCN-judu/ProbablyStolen-BetterKeyBindings)

Project code is [MIT licensed](LICENSE). Probably Stolen, Unity, Harmony and third-party assets belong to their respective owners. No game code or assemblies are redistributed.
