# API investigation — 2026-11-11

> Current correction (0.1.4): the supported public build is 100-Rev13 / 1.0.0.13, build 26525552. The former 1.1.0 game-version assumption is withdrawn; manifest now declares only the actual runtime identifier 0.46D. See [verified sources](GAME-VERSIONS.md). Earlier sections below retain historical investigation context.

## Evidence and environment

- Installed full-game Steam App ID: **4348910**, build ID **26525552** (read from local Steam app manifest; no account data copied).
- `PlayerStore.VERSION_NUMBER` and `PlayerStore.VERSION`: **VERSION 100-Rev13**. The first manifest incorrectly inferred `1.0.0.13` from this internal constant. The owner reports the actual supported official game version is **1.1.0**; 0.1.1 declares `1.1.0` based on the owner's completed in-game acceptance. The internal constant and serialized Unity Application.version (`0.46D`) are stale and are not treated as authoritative release labels. The installed revision predates the guide's newer game-version helper; no `ModHelper.GetGameVersion()` is used. The later screenshot confirmed that 0.46D is authoritative for this build's menu matching; 0.1.3 retains it alongside 1.1.0 as corrected below.
- `Assembly-CSharp.dll` SHA-256: `725CB999D019DFF1FF31BED353C7F9BB8D81A7605A15DE1F80F5A3A6CF7B1D05`.
- Git and .NET SDK **6.0.410** available. SteamCMD not found on PATH. ILSpy CLI **8.2.0.7535** installed under ignored `.local/tools` for read-only inspection.
- Local guide commit: `3541332ad755a07e423077659863268256ccd233`.
- Reference collection inspected at `4b1eac7eacc781ee7849284fec016e023bf198c1`; Better Key Bindings at `ac1633ccb0d62bdf0c8dce876f3e7f5e2b5b6f3f`.

## Verified call paths

These are factual descriptions of inspected code, not reproduced proprietary source. Private decompilation remains in ignored `.local/game-source/` and `.local/investigation/` only.

| Concern | Verified member | Observation |
| --- | --- | --- |
| Coordinator dispatch | `StoreUIManager.Update()` | Calls `MachineStorageCoordinator.HandleInput()` when not typing. |
| Coordinator modes | `MachineStorageCoordinator.HandleInput()` | Restores Escape handling; routes key capture, container picking, or normal hotkeys separately. |
| Shortcut target | `private static void MachineStorageCoordinator.HandleHotkeys()` | Returns on no key down/dialogue choice, finds coordinator in reach, loads presets, tests Unity `Input.GetKeyDown` directly, groups matches and calls `TogglePresets`. No drag check. |
| Drag singleton | `public static ItemMouseDragHandler current` | Assigned in `Awake`. It is a Unity component, so use Unity-aware null comparison. |
| Drag state | `public bool ItemMouseDragHandler.IsDraggingItem` | Read-only getter of private `isDragging`; no reflection needed. |
| Drag start/end | `StartDrag`, `EndDrag`, `AbortDrag`, `Reset` | Start sets drag state true; finish, abort and reset clear it. State begins after movement threshold, not merely holding the mouse button. |
| Rotation | `ItemMouseDragHandler.OnEventPress(ISet<KeyCode>)` | While dragging, uses `rotate_cw` / `rotate_ccw` and changes item orientation through its own input handler. |
| Native hooks | `ModHook` events | Inspected installed event list and guide. No cancellable Storage Coordinator hotkey hook or drag input gate. |
| Mod lifecycle | `IMod`, `ModLog`, `ModLoader` | `Init`, automatic Harmony attribute patching, then `OnEnable`; loader manages patch lifecycle. |

## Decision

One bool Harmony prefix on **only `MachineStorageCoordinator.HandleHotkeys`** returns false during an active item drag. It does not patch `HandleInput`, `TogglePresets`, key binding helpers, Unity input, or rotation. Capture/pick UI remains intact. All coordinator hotkeys are blocked during drag, including W/R, not just Q/E. Null/destroyed handler permits vanilla; state-read exceptions permit vanilla and warn once per enable. An enable flag makes any still-present prefix inert after `OnDisable`.

No save API, file I/O, external reflection, dynamic code, background tasks, bundled Harmony or game DLLs are used by the runtime mod. `<Capabilities />` is empty.

Better Key Bindings reads the same public drag property for rotation contexts, but patches the game's configurable key binding/input paths. The Coordinator's direct Unity polling bypasses that path. This explains why rebinding changes alone do not address this conflict. No reference implementation code was copied.

## Validation and limits

- Release and Debug compiled successfully against actual installed references, zero warnings/errors.
- Installed-game signature check passed; actual `ModScanner.Scan` reported **14 methods, refused=false, capabilities=0, hard flags=0, error=none** for Release.
- The first scanner harness attempt under desktop .NET Framework failed on `String.Split(char, StringSplitOptions)`, a runtime mismatch. The final script runs under .NET 6 and the scan completes without that error.
- Contract checks passed in Release and Debug. The owner subsequently reported passing the official-game manual matrix with no bugs on 1.1.0. This is owner-reported gameplay evidence. Third-party mod coexistence is excluded from support; Workshop delivery remains a separate validation.
- `StoreUIManager.Update` and `InputActionManager.Update` are separate Unity updates. First-threshold frame and drop/cancel frame order are included in the owner-reported manual acceptance; this patch checks the game's current logical drag state and does not invent a second mouse-drag state machine.
- This is a private target, so re-inspect after game updates. A compile success alone does not establish continued behavior compatibility.

## Sources

- [Developer modding guide](https://github.com/dragonpan2/probably-stolen-modding/blob/main/ModdingGuide.md): native hooks, Harmony lifecycle, manifest, capabilities and SteamCMD publishing.
- [Reference collection](https://github.com/KCN-judu/ProbablyStolen-Mods): project/build/scanner workflow patterns.
- [Better Key Bindings source](https://github.com/KCN-judu/ProbablyStolen-BetterKeyBindings/blob/main/src/Bindings.cs): input scope and public drag-state use.

Local installed assemblies are authoritative where the latest guide differs.

## 0.1.3 correction: runtime compatibility identifiers

The owner's screenshot and current Player.log establish that the local 0.1.2 mod runs, but the menu warns that it is not made for game version **0.46D**. The earlier decision to keep only the owner-reported 1.1.0 label was incomplete: Application.version is authoritative for this build's menu matching even when it differs from the release label.

Inspected ModUIManager.VersionMatchesGame normalizes its argument and Application.version to a leading numeric/dot prefix, then accepts equal or compatible dot-prefix values. GetModIssue adds the version warning only when no declared GameVersions entry matches. Thus 0.46D normalizes to 0.46 and exactly matches the runtime value; 1.1.0 alone cannot match. The 0.1.3 manifest retains 1.1.0 and adds 0.46D without modifying the game or its UI.

The development harness can call the installed game's actual private, pure NormalizeVersion method without accessing Unity's native Application.version getter. Run scripts/check-game.ps1 -ReportedGameVersion 0.46D with the reported value explicitly supplied. It verifies that at least one packaged manifest entry produces the same normalized value, which guarantees the equality branch of the inspected matcher. The old manifest failed this check as expected. This is a headless check; actual post-restart menu appearance still requires observation. The old UI colors each entry separately, so 1.1.0 can remain red while 0.46D is green and the overall warning is cleared.

## 0.1.6 native in-game preview

Verified in installed ModUIManager: GetLocalPreview reads preview.png from LoadedMod.FolderPath and decodes it with Texture2D.LoadImage, then creates a sprite. Local copies do not automatically use their associated Steam page cover; Workshop copies prefer the Steam preview URL and use the packaged PNG as fallback. Missing previews are cached, so a restart is needed after installation. The fix supplies this native asset rather than patching UI or adding runtime image-loading code.
