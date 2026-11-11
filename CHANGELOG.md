# Changelog

All notable changes are recorded here. Versions follow Semantic Versioning.

## [Unreleased]

- No changes yet.

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
