---
name: electron-development
description: Build secure, maintainable Electron desktop applications with safe process boundaries, IPC, packaging, auto-update strategy and cross-platform testing.
---

# Electron Development

## Architecture

- Treat the renderer as an untrusted web environment.
- Keep privileged operating-system access in the main process or narrowly scoped preload APIs.
- Use context isolation and sandboxing; keep Node integration disabled in renderers unless a thoroughly justified exception exists.
- Expose minimal, typed IPC methods through preload.
- Validate IPC payloads in the privileged process.
- Never expose arbitrary filesystem, shell or process execution capabilities to renderer code.
- Define window lifecycle, navigation policy and external-link handling explicitly.

## Security baseline

- Follow current Electron security guidance and review every enabled web preference.
- Restrict navigation and new-window creation to trusted destinations.
- Apply a restrictive Content Security Policy.
- Do not load untrusted remote content with privileged capabilities.
- Keep Electron and dependencies updated.
- Protect secrets using OS-appropriate facilities; do not hardcode them.
- Validate file paths and defend against traversal.
- Treat downloaded content and update artifacts as untrusted until verified.

## Application structure

Separate UI, main-process services, preload bridges and shared contract types. Keep IPC channel names and payload schemas centralized. Avoid business logic duplicated across main and renderer.

## Packaging and updates

- Choose a maintained packaging tool compatible with the Electron release.
- Define code signing and notarization requirements per platform.
- Use a secure update channel and verify update provenance.
- Test clean install, upgrade, rollback/recovery and data migration.
- Avoid assuming filesystem paths or permissions are identical across operating systems.

## Testing

- Unit-test pure logic and IPC contracts.
- Integration-test main/preload/renderer boundaries.
- Test permissions, file access, external navigation and malformed IPC.
- Run packaged-app smoke tests on each supported OS.
- Verify app lifecycle, crash reporting and update behavior.
- Inspect production build for debug endpoints, source-map exposure policy and accidental secrets.
