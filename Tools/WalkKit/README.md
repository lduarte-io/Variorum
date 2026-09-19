# WalkKit — driving the dev-store Debug build for an orchestrator's hands-on walk

Two tiny Swift helpers plus the `osascript` recipe that worked on 2026-09-04 (the bridge retirement's walk),
so no session re-derives them. Everything here targets the DEBUG build on the fenced dev store
(`App/Variorum/DerivedData/<dd>/Build/Products/Debug/Variorum.app`, bundle `io.lduarte.Variorum.debug`) and
NEVER her installed `/Applications/Variorum.app` — discriminate instances by PATH:
`pgrep -f 'DerivedData/<dd>/Build/Products/Debug/Variorum.app/Contents/MacOS'`.

## Build the helpers (seconds; no install, no PyObjC)
```
swiftc -O -o /tmp/walk-cap    Tools/WalkKit/capture-windows.swift
swiftc -O -o /tmp/walk-scroll Tools/WalkKit/scroll.swift
```
- `walk-cap <pid> <outdir>` — lists the process's on-screen layer-0 windows (id · name · bounds in POINTS) and
  saves each as `<outdir>/w<n>.png` via `screencapture -l`. Read the PNG with the Read tool. The main window
  is captured at 2× (a 1728-pt window → 3456 px).
- `walk-scroll <x> <y> <lines>` — posts real scroll-wheel events at a screen point (points). SwiftUI Settings
  forms do not expose an addressable scroll area to AppleScript and page-down keys do not reach them; this does.

## The osascript recipe (System Events; Accessibility is already granted to the terminal host)
- Activate: `set frontmost of (first application process whose unix id is <pid>) to true`.
- Click at screen POINTS: `click at {x, y}` — convert from a 2× screenshot: `x_pt = x_px/2`, `y_pt = y_px/2 + windowY`
  (the window's Y from `walk-cap`; the main window sat at Y=33 under the menu bar).
- Menus: `click menu item "Today's Entry" of menu 1 of menu bar item "File" of menu bar 1` — enumerate with
  `name of menu items of menu 1 of menu bar item "File" of menu bar 1`.
- Settings tabs: `click button <i> of toolbar 1 of window 1` (by INDEX — by name failed when the window's title
  changes with the tab). Keys: `keystroke "," using command down` (Settings), `"w"` (close), `"j"` (⌘J),
  `"2"` (Takes mode), `"q"` (quit YOUR instance only).
- Rendered text: `entire contents of window 1` → static texts; fragile when a window is re-referenced by name
  after its title changed — reference `window 1` while it is frontmost.

## Pitfalls met (so they are not met twice)
- The FIRST launch of a fresh build once ate every keystroke and showed an empty Library catalog for minutes;
  three relaunches never reproduced it (the bridge retirement record §8, W-1/W-2). If a walk's first launch
  misbehaves, quit YOUR instance and relaunch before concluding anything.
- `open -n <app>` launches a second instance beside hers; `pgrep -fl 'Variorum.app/Contents/MacOS'` then shows
  both — never quit or kill the `/Applications` one.
- Every launch of the Debug build takes a dev-store backup (`…/Variorum-dev/Backups/`); harmless, expected.
- `cliclick` 5.1 IS INSTALLED (she ran `brew install cliclick`, 2026-09-04): the one-binary road for
  click/type/drag/scroll — `cliclick c:x,y` (click at points), `kd:cmd t:j ku:cmd` (⌘J), `t:text` (type),
  `dd:x,y du:x,y` (drag), `w:ms` (wait). Prefer it over the osascript keystroke road for typing into fields.

## Walker facts from the 13u3 UNIT B walk (2026-09-19)

- The dev-store window comes up **1728×1084 at Y=33** on this machine (any older size note is stale).
- A fresh launch shows a **40 pt phantom window** in `walk-cap`'s listing — skip it.
- `cliclick` keystrokes go to the FRONTMOST app: re-activate the target after every capture before typing.
- Synthetic typing into the full-document TK2 editor drops most characters even at 150 ms spacing, and ⌘V never lands there; the quick-entry bar and the quick-note pad take full strings fine — stage editor prose through the store, not the keyboard.

## Walker facts from the 13u3 UNIT C walk (2026-09-19)

- **The quick-note pad is a FLOATING window (CG layer 19)**, so `walk-cap` — which filters to layer 0 —
  never lists or captures it. List every layer (a 12-line `CGWindowListCopyWindowInfo` dump) and capture it
  by id: `screencapture -x -o -l <id> out.png`.
- **`walk-cap` writes `w0.png`, `w1.png`… by INDEX, and never cleans up**: a run that finds fewer windows
  than the previous one leaves STALE files under the old names, which reads as "the app did not change".
  Prefer capturing by window id once you know it.
- The dev window comes back at **1700×1000 at Y=33** after a quit/relaunch (not the 1728×1084 of a first
  launch) — read the bounds from the listing every time rather than reusing a note's numbers.
- A sidebar row click right after `open -n` + activate can be swallowed while the workspace restores;
  **⌘K → type the destination → ⏎** is the reliable navigation road.
- `osascript -e 'set frontmost of (first application process whose unix id is <pid>) to true'` is a SYNTAX
  ERROR on its own — it needs `tell application "System Events" to …`.
- **The appearance (follow system · light · dark) is a LOCAL `UserDefaults` preference**, so a walk can stage
  it without touching the UI: `defaults write io.lduarte.Variorum.debug appearanceChoice dark|light|system`
  then relaunch (restore it afterwards). The VOICE is a synced store setting and must be clicked in Settings.

## Walker facts from the 13u3 UNIT D walk (2026-09-19)

- **NEVER quit your dev instance with a blind `⌘Q` keystroke.** `osascript … keystroke "q" using
  command down` goes to whatever is FRONTMOST, and during this walk one of those presses ended the
  author's own `/Applications/Variorum.app` session (her container's hourly backups stop between
  04:19 and 05:19; no crash report; her store file untouched). Quit YOUR instance by identity:
  `osascript -e 'tell application id "io.lduarte.Variorum.debug" to quit'`, and re-check
  `pgrep -fl 'Variorum.app/Contents/MacOS'` after every quit — the standing rule is that her
  instance is never quit, and a keystroke cannot tell two windows apart.
- A SwiftUI `.popover` IS captured by `screencapture -l <window id>` of the MAIN window: it draws
  inside the window's frame here, so no separate layer hunt is needed (unlike the quick-note pad).
- `sips --cropOffset <Y> <X>` takes the offsets in that order (top, then left) — the opposite of
  the (x, y) reflex — and a crop that lands outside the image returns a blank PNG rather than an
  error, which reads exactly like "the surface drew nothing".
- The dev app's Settings window opens at **560 × 548 at (200, 120)** and its voice control sits at
  window-relative (486, 160) / (414, 160) for Study / Terminal — click points, not pixels.
