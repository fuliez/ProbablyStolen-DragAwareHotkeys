# Codex development rules

Read `agent.md`, README.md, docs/API-INVESTIGATION.md and docs/TESTING.md before changing this project.

- This directory is the independent project root. Keep all development artifacts here. The parent is an installed game, not a source repository.
- Scope: suppress Storage Coordinator container hotkeys only during actual item dragging. Preserve idle hotkeys, native rotation and save data. Prefer a native cancellable hook if one becomes available; otherwise maintain the smallest game-only Harmony patch.
- Support and acceptance cover the official game only. Do not add third-party mod coexistence as a release requirement. Compatibility version is 1.1.0 as reported and tested by the owner; stale internal version constants are not authoritative release labels.
- Verify every game API against the installed binary or authoritative documentation. Do not assume newest online APIs exist locally. Reinspect private `MachineStorageCoordinator.HandleHotkeys` after game updates.
- Use the native IMod loader and automatic Harmony attributes. Do not ship Harmony or game assemblies; do not patch Unity/system/loader/trust code. Keep capabilities empty unless a reviewed feature demonstrably needs more.
- Never overwrite original game assemblies or edit saves. Do not launch tests that mutate saves without an explicit request. Install only the allowlisted DLL and manifest into this mod's folder.
- Use `PROBABLY_STOLEN_GAME_DIR`, `-GameDir`, or ignored config.local.json; never commit machine-specific path configuration, game files, decompiled game code, logs, account information, VDF output, credentials or build artifacts.
- Run appropriate checks after code/script changes: Release/Debug contract executable, scripts/check.ps1, real-reference build, scripts/check-game.ps1 and packaging. Public contract builds are not full game builds. Report manual acceptance as pending unless actually observed.
- Build outputs must be deterministic; compare DLL hashes when changing build logic. Runtime packages are an exact two-file allowlist. Never package source, scripts, development tools, `.git`, contracts, dependencies or secrets.
- Versions follow SemVer. Update props/manifest/changelog together. Use Conventional Commits and annotated `vX.Y.Z` release tags only after acceptance. Review staged files and whitespace before committing.
- Do not create a GitHub remote or push until the owner confirms repository name and visibility. Do not publish Releases, upload Workshop content, or change Workshop visibility without explicit authorization.
- Workshop app ID is 4348910. First upload is hidden. Keep and recover the existing publishedfileid; never silently create a second item. Keep Steam password and Guard codes interactive and out of scripts/logs/repo.
- Update `agent.md` with implementation decisions, validations, failures and open work so another AI can continue. Do not replace pending status with inferred success.
