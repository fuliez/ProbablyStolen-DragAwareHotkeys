# Validation and manual acceptance

Automated checks do not launch the game or modify saves. On 2026-11-11 the owner reported completing the official-game manual checks below with no bugs found, on game version **1.1.0**. These are owner-reported results, not agent-observed play tests. Third-party mod compatibility is outside the supported scope. The 0.1.1 update changes compatibility metadata and the display name, with no input logic changes; confirm the updated name/version in the Mods menu after reinstalling and restarting.

## Automated

```powershell
dotnet run --project tests/Contracts/Contracts.csproj -c Release
dotnet run --project tests/Contracts/Contracts.csproj -c Debug
./scripts/check.ps1
./tests/Workshop.ps1
./scripts/check-game.ps1
./package.ps1
```

The contract executable checks 10 lifecycle/state/failure outcomes in each configuration. Its doubles have no Unity implementation and are never used in the production build or package. The installed-game harness verifies the real private static void/no-argument target, public singleton field and boolean drag getter, then scans the runtime DLL with the installed game's scanner. A scan with any error is a failure.

`tests/Workshop.ps1` uses a separate fixture under ignored `.local/publisher-tests/`, a fake packager and fake SteamCMD. It verifies default preparation, required explicit confirmation, hidden visibility, saved identity, update instead of duplicate creation, VDF recovery, and blocked retries after uncertain creation. No network upload occurs; its synthetic ID is not a real Workshop item.

### Initial 0.1.0 local results — 2026-11-11

- Release and Debug actual-reference builds: passed, 0 warnings/errors.
- Release and Debug contract checks: 10 passed each.
- Installed-game signature check and scanner: passed; 14 methods, no capabilities, hard flags, refusals or errors.
- PowerShell syntax/version/repository checks: passed.
- Workshop offline safeguard tests: passed. Real SteamCMD execution remains untested.
- Clean rebuild produced identical Release DLL SHA-256: `E38EA105C93C59DF31FE2C709269E312F1F94F2BB233D8767DC156816238372C`.
- ZIP inspected: exactly `drag_aware_hotkeys/manifest.xml` and `drag_aware_hotkeys/ProbablyStolen.DragAwareHotkeys.dll` (6144 bytes).
- Real hidden VDF prepared with App ID 4348910, visibility 2, item ID 0. No upload or local installation performed.

### 0.1.1 results — 2026-11-11

- Official game 1.1.0 manual acceptance: passed according to the owner; third-party mod coexistence is excluded from scope. Input logic is unchanged from 0.1.0.
- Actual-reference Release/Debug builds: passed with no warnings/errors; both sets of 10 contract checks passed.
- Actual-game API signatures and scanner: passed (14 methods, no capabilities, hard flags, refusals or errors).
- Offline Workshop safeguards: passed under PowerShell 7 and Windows PowerShell 5.1. Real preparation/build/package also passed under 5.1 after adding explicit UTF-8 reads.
- Installed 0.1.1 into Mods/drag_aware_hotkeys with the game closed. Corrected manifest declares 1.1.0 and the bilingual display name; updated menu appearance awaits the owner's visual confirmation.
- Release DLL SHA-256: `7341770A95DE11999F0AD96DACF699790AA86DF8B98AE3BFC5CBA07BBEC982B9`.
- First hidden Workshop upload completed; Steam returned item ID 3837800051. VDF preserves visibility 2 and the bilingual title. Owner-authenticated page/cover/agreement confirmation remains pending.
- [Public GitHub Release](https://github.com/fuliez/ProbablyStolen-DragAwareHotkeys/releases/tag/v0.1.1) uploaded with runtime ZIP and SHA256SUMS.txt; downloaded ZIP verified against that checksum. ZIP timestamps may differ between later local packaging runs.

## Manual matrix

Install with the game closed. Use an existing test save with a reachable Storage Coordinator and presets bound to Q/W/E/R. Note the baseline with the mod disabled first. All remaining rows were reported passed by the owner before the metadata/name update.

- [x] Mods menu lists the right name/version; enable, approve and restart; logs confirm one patch, no scanner warning.
- [x] Idle: Q/W/E/R open/close exactly the same preset containers as vanilla, including multiple presets sharing one key.
- [x] Drag an asymmetrical item: Q and E rotate correctly, opening or closing no preset containers. Test each direction several times.
- [x] During drag W/R and any additional coordinator bindings also do nothing; flip/reset/placement remain functional.
- [x] Release the item, then press Q/W/E/R: storage shortcuts work again without an extra click.
- [x] Cancel with Escape/right click; test a second drag. No stuck suppression.
- [x] Press rotation on the first movement-threshold frame and on release/cancel frames. Record any input-order edge cases.
- [x] Mouse down without reaching drag threshold: shortcut behavior remains vanilla.
- [x] Coordinator binding capture, container pick mode and Escape handling work normally.
- [x] Dragging a UI window alone does not suppress container hotkeys.
- [x] Main menu, scene transitions, focus loss, destroyed drag target and loading a save produce no exceptions or stuck input.
- [x] Disable/restart, then uninstall/restart: vanilla behavior restored, no save migration or missing-data errors.

For debugging install `-Configuration Debug` and inspect the transition logs. Do not commit raw Player.log (it may contain local paths and other mods' data). Game-native `mod-scan drag_aware_hotkeys` is an additional check if dev tools are enabled. Official-game acceptance is recorded above; Workshop delivery verification remains separate.

## 手动验收清单（中文翻译）

请关闭游戏后再安装 Mod。使用已有的测试存档，确保储物协调器处于可操作范围内，并将预设容器快捷键绑定到 Q/W/E/R。先停用本 Mod，记录原版行为作为对照。项目所有者于 2026-11-11 反馈：已在官方游戏 1.1.0 中完成以下测试，未发现问题。勾选状态依据用户反馈记录，并非 AI 现场观察。第三方 Mod 兼容性不在支持范围内；本次 0.1.1 仅修改版本声明和显示名称，重新安装并重启后还需确认 Mods 菜单中的名称和适配版本显示正确。中英文清单对应同一组测试。

- [x] Mods 菜单显示正确的 Mod 名称和版本；启用、确认授权并重启游戏后，日志确认应用了一个补丁，且没有扫描器警告。
- [x] 未拖动物品时：Q/W/E/R 打开或关闭的预设容器与原版完全一致，包括多个预设共用同一按键的情况。
- [x] 拖动一个形状不对称的物品：Q 和 E 均能正确旋转物品，且不会打开或关闭任何预设容器。两个方向各测试多次。
- [x] 拖动物品时，W/R 及其他储物协调器快捷键也不触发容器操作；翻转、重置朝向和放置功能仍正常。
- [x] 松开并放下物品后，再按 Q/W/E/R：储物快捷键立即恢复正常，无需额外点击鼠标。
- [x] 使用 Escape 或鼠标右键取消拖拽，再进行第二次拖拽，确认快捷键不会一直处于被屏蔽状态。
- [x] 在鼠标移动刚达到拖拽阈值的第一帧，以及松开或取消拖拽的帧中按旋转键，记录任何与输入处理顺序有关的边界问题。
- [x] 仅按住鼠标、移动距离尚未达到拖拽阈值时：快捷键行为与原版一致。
- [x] 储物协调器的快捷键绑定录入、容器选择模式以及 Escape 键处理均正常。
- [x] 仅拖动 UI 窗口时，不会屏蔽容器快捷键。
- [x] 在主菜单、场景切换、游戏窗口失去焦点、拖拽目标被销毁以及读取存档等情况下，不出现异常或输入卡住的问题。
- [x] 停用 Mod 并重启，再卸载并重启：原版行为恢复，且没有存档迁移或数据缺失错误。

调试时可使用 `-Configuration Debug` 安装，并查看拖拽状态切换日志。不要提交原始 `Player.log`，其中可能含有本机路径和其他 Mod 的数据。若已启用开发工具，还可使用游戏内的 `mod-scan drag_aware_hotkeys` 进行额外检查。上述记录表示官方版本功能验收通过；创意工坊实际下载与交付验证需要另行完成。
