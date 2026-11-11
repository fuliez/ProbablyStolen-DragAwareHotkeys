# Validation and manual acceptance

Automated checks do not launch the game or modify saves. Runtime acceptance is **pending**. Record results, game build, other mods, date and logs here before tagging a release.

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

### Recorded local results — 2026-11-11

- Release and Debug actual-reference builds: passed, 0 warnings/errors.
- Release and Debug contract checks: 10 passed each.
- Installed-game signature check and scanner: passed; 14 methods, no capabilities, hard flags, refusals or errors.
- PowerShell syntax/version/repository checks: passed.
- Workshop offline safeguard tests: passed. Real SteamCMD execution remains untested.
- Clean rebuild produced identical Release DLL SHA-256: `E38EA105C93C59DF31FE2C709269E312F1F94F2BB233D8767DC156816238372C`.
- ZIP inspected: exactly `drag_aware_hotkeys/manifest.xml` and `drag_aware_hotkeys/ProbablyStolen.DragAwareHotkeys.dll` (6144 bytes).
- Real hidden VDF prepared with App ID 4348910, visibility 2, item ID 0. No upload or local installation performed.

## Manual matrix

Install with the game closed. Use an existing test save with a reachable Storage Coordinator and presets bound to Q/W/E/R. Note the baseline with the mod disabled first. All rows below remain unchecked.

- [ ] Mods menu lists the right name/version; enable, approve and restart; logs confirm one patch, no scanner warning.
- [ ] Idle: Q/W/E/R open/close exactly the same preset containers as vanilla, including multiple presets sharing one key.
- [ ] Drag an asymmetrical item: Q and E rotate correctly, opening or closing no preset containers. Test each direction several times.
- [ ] During drag W/R and any additional coordinator bindings also do nothing; flip/reset/placement remain functional.
- [ ] Release the item, then press Q/W/E/R: storage shortcuts work again without an extra click.
- [ ] Cancel with Escape/right click; test a second drag. No stuck suppression.
- [ ] Press rotation on the first movement-threshold frame and on release/cancel frames. Record any input-order edge cases.
- [ ] Mouse down without reaching drag threshold: shortcut behavior remains vanilla.
- [ ] Coordinator binding capture, container pick mode and Escape handling work normally.
- [ ] Dragging a UI window alone does not suppress container hotkeys.
- [ ] Main menu, scene transitions, focus loss, destroyed drag target and loading a save produce no exceptions or stuck input.
- [ ] Repeat with Better Key Bindings enabled, including remapped rotation and modifier combinations. Raw Coordinator bindings remain subject to its own vanilla rules.
- [ ] Disable/restart, then uninstall/restart: vanilla behavior restored, no save migration or missing-data errors.

For debugging install `-Configuration Debug` and inspect the transition logs. Do not commit raw Player.log (it may contain local paths and other mods' data). Game-native `mod-scan drag_aware_hotkeys` is an additional check if dev tools are enabled. Avoid calling the release fully tested until the matrix is completed.
