---
name: electron-app
description: Use when building a production Electron desktop app with a secure main, renderer, and preload split, context isolation, IPC patterns, auto-updater, electron-builder packaging for Windows, macOS, and Linux, security hardening, testing, and distribution.
---

# Electron App

Build a production Electron desktop app that is secure, testable, and
easy to install. Keep the main process small, keep Node.js out of the
renderer, and expose only a narrow, reviewed API through the preload
script. A feature is not done until it works in the packaged app, has an
error state, passes the security checks, and updates cleanly.

## When to Use This Skill

- The user asks for an Electron app, a desktop app, or a Windows/macOS/Linux app.
- An existing Electron app needs IPC, auto-update, packaging, or security fixes.
- A web app must be shipped as a desktop app with file access or system integration.
- The user asks for electron-builder, auto-updater, context isolation, or preload scripts.

## Stack Decisions

- Runtime: Electron 30 or newer, Node.js 20 or newer, TypeScript throughout.
- Build: Vite or webpack for the renderer, esbuild or tsc for the main process.
- UI: React, Vue, or plain HTML in the renderer; pick one and use it everywhere.
- Packaging: electron-builder for installers, auto-update, and code signing.
- Updates: electron-updater with a GitHub Releases, S3, or generic HTTP feed.
- Storage: electron-store for settings, SQLite (better-sqlite3) for local data.
- Testing: Vitest for unit tests, Playwright for end-to-end tests, Spectron is retired.
- Tooling: ESLint, Prettier, TypeScript strict mode, and `electron --version` pinned in `package.json`.

## Project Layout

```text
package.json
electron/
  main.ts                   # app lifecycle, windows, menus, tray
  preload.ts                # contextBridge only, no Node.js in renderer
  ipc/
    files.ts                # file handlers, one file per domain
    settings.ts
  updater.ts                # auto-update checks and prompts
  security.ts               # CSP, navigation guards, permission handler
src/renderer/
  App.tsx
  components/
  pages/
  api/electron.ts           # typed wrapper around window.electron
  store/
assets/icon.png, icon.ico, icon.icns
build/
  entitlements.mac.plist
  installer.nsh
```

Rules: the main process owns windows, menus, tray, and native APIs.
The renderer owns UI only and never imports Node.js modules. The preload
script is the only bridge, and it exposes a small typed API. One IPC
channel per action, named `domain:action`, for example `files:open`.

## Security Rules

These rules are not optional; a violation is a ship-blocker.

- Never enable `nodeIntegration`. It must stay `false` in every window.
- Always enable `contextIsolation: true` in every window.
- Never use `remote` (removed in modern Electron) or expose `require` to the renderer.
- Enable `sandbox: true` for windows that do not need a preload bridge.
- Set a strict Content Security Policy in the HTML and in `security.ts`.
- Validate every IPC argument in the main process; never trust the renderer.
- Only allow navigation to the app origin; block `window.open` to unknown URLs.
- Set a permission handler that denies camera, microphone, and geolocation unless the feature needs them.
- Never load remote code with `eval`, `new Function`, or a remote script tag.
- Keep Electron updated; check for a new version before every release.

Window creation, the only safe pattern: `new BrowserWindow({ width: 1200, height: 800, webPreferences: { preload: path.join(__dirname, 'preload.js'), contextIsolation: true, nodeIntegration: false, sandbox: true } })`.

## Preload and IPC Patterns

Expose a narrow API with `contextBridge`, and nothing else: `contextBridge.exposeInMainWorld('electron', { openFile: () => ipcRenderer.invoke('files:open'), saveFile: (path, content) => ipcRenderer.invoke('files:save', path, content), onFileOpened: (cb) => ipcRenderer.on('files:opened', (_e, p) => cb(p)) })`.

IPC rules: use `ipcMain.handle` for request/response and `webContents.send`
for main-to-renderer events. Use `ipcRenderer.invoke` in the renderer,
never `sendSync`, which blocks the UI. Validate arguments with a schema
(such as Zod) before acting on them. Return a typed result object with
`ok` and either `data` or `error`, never a raw exception. Log IPC errors
in the main process with the channel name, never with file contents.
Remove listeners when a window closes to avoid duplicate handlers.

## Main Process

- Create one main window on `app.whenReady`, and recreate it on macOS when the dock icon is clicked and no window is open.
- Quit on `window-all-closed` on Windows and Linux; stay running on macOS.
- Put menu, tray, and global shortcuts in the main process, behind a feature flag where they are optional.
- Keep long work (file parsing, downloads, hashing) off the UI thread: use a worker thread or a child process.
- Handle `before-quit` to save state and cancel in-flight work cleanly.
- Never block the main process with synchronous file or network calls.

## Renderer

- Build the renderer as a normal web app: components, routing, and state in one framework.
- Call the main process only through the typed `window.electron` wrapper in `src/renderer/api/electron.ts`.
- Show loading, empty, and error states for every async action; a failed IPC call shows a retry button, never a blank screen.
- Keep the renderer fast: lazy-load heavy pages, virtualise long lists, and avoid re-rendering the whole tree on each keystroke.
- Persist window size and position in electron-store and restore them on launch.

## Auto-Updater

Configure electron-updater once, in `electron/updater.ts`:

```typescript
import { autoUpdater } from 'electron-updater';
autoUpdater.autoDownload = false;
autoUpdater.on('update-available', (info) => {
  dialog.showMessageBox({ message: `Version ${info.version} is available. Download now?` });
});
```

Rules: check for updates on launch and once a day, never more often.
Download only after the user agrees, except for a critical security fix.
Install on quit, never in the middle of unsaved work. Log the current
version and the update channel at startup. Test the full update path on a
real machine before release: install version N, publish N+1, and confirm
the app updates and keeps its settings and data. Sign every release;
unsigned updates are rejected on macOS and warned about on Windows.

## Packaging with electron-builder

```json
{
  "appId": "com.example.shop",
  "productName": "Shop",
  "directories": { "output": "dist" },
  "files": ["dist-electron/**/*", "dist/**/*", "package.json"],
  "mac": { "category": "public.app-category.productivity", "target": "dmg" },
  "win": { "target": "nsis" },
  "linux": { "target": "AppImage" }
}
```

Build commands: `npm run build` compiles the renderer and the main
process, `npm run dist` runs electron-builder, and `npm run dist:win`,
`dist:mac`, and `dist:linux` build one platform each. Rules: build macOS
on a Mac, Windows on Windows or with a Windows runner, and Linux on Linux;
cross-building installers is unreliable. Code-sign macOS with a Developer
ID certificate and notarise the app, or Gatekeeper blocks it. Code-sign
Windows with an EV certificate where possible, or users see a SmartScreen
warning. Keep icons in all three formats: `.icns` for macOS, `.ico` for
Windows, `.png` for Linux. Test the installer on a clean machine, not
only on the developer machine.

## Testing

- Unit tests (Vitest): pure functions, IPC argument validation, and the store layer. Mock `electron` in the renderer tests.
- Integration tests: IPC round trips with a test main process, and file operations against a temporary directory.
- End-to-end tests (Playwright): launch the packaged app, click through the main journey, and check the window title and key text.
- Manual checks: install the packaged app on a clean machine, launch it, quit it, relaunch it, and confirm settings persist.
- Run `npm test`, `npm run lint`, and `npm run typecheck` before every release.
- Never test auto-update against the production feed; use a staging feed.

## Distribution

- Publish releases on GitHub Releases with the installer, a checksum file, and release notes.
- Keep a changelog with version, date, and user-visible changes for every release.
- Support the last two major versions for updates; older versions get a prompt to download the latest installer.
- Provide a portable build (ZIP or AppImage) for users who cannot install software.
- Answer support questions with the app version, platform, and log location: `%APPDATA%/<app>/logs` on Windows, `~/Library/Logs/<app>` on macOS, `~/.config/<app>/logs` on Linux.

## Pre-Ship Checklist

- [ ] `nodeIntegration` is false and `contextIsolation` is true in every window.
- [ ] Preload exposes only the reviewed API; no `require` reaches the renderer.
- [ ] IPC arguments are validated in the main process, and errors return a typed result.
- [ ] Auto-update tested end to end: version N installs, N+1 updates, settings survive.
- [ ] Installers built and signed for Windows, macOS, and Linux, and tested on clean machines.
- [ ] App launches, quits, and relaunches with settings and data intact.
- [ ] `npm test`, `npm run lint`, and `npm run typecheck` all pass.
- [ ] Release notes, changelog, and checksums are published with the release.

## Pitfalls

- Enabling `nodeIntegration` for convenience hands the renderer full system access.
- Exposing the whole `ipcRenderer` in preload lets any script call any channel.
- Trusting renderer input in the main process lets a compromised page read arbitrary files.
- Skipping code signing means macOS blocks the app and Windows warns every user.
- Testing only the unpacked app hides installer, signing, and update failures.
- Downloading an update without asking interrupts work and loses unsaved data.
- Blocking the main process with synchronous work freezes the whole app.
