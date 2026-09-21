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

## Walker facts from the 13u3 UNIT E walk (2026-09-19)

- **An APP-MODAL alert is invisible to `walk-cap` and swallows every click and keystroke.**
  `Help ▸ Restore Tutorial…` puts up a real modal dialog (AppKit, its own window) which
  `walk-cap`'s layer-0 filter does not list — so the app looks normal in the capture and simply
  stops responding to `cliclick`. **Diagnose it, don't retry:**
  `osascript -e 'tell application "System Events" to tell process "Variorum" to get properties of window 1'`
  → `subrole:AXDialog`, and the `position`/`size` it prints are the frame to capture with
  `screencapture -x -R x,y,w,h out.png`. Press its button by name through System Events
  (`click button "Replace" of window 1`), never by coordinates.
- **`tell application id … to quit` can be REFUSED while that modal is up** (`execution error: …
  User canceled. (-128)`), and a walk that then runs `open -n` ends up with TWO dev instances on
  one dev store — at which point `tell application id` is ambiguous about which one it quits.
  Kill the extra by **PID** (`kill -TERM <pid>` on a pid `pgrep` proved is yours), and re-check
  `pgrep -fl 'Variorum.app/Contents/MacOS'`. Never a keystroke (the UNIT D rule).
- A SwiftUI `.alert` (the restore confirm) DOES draw inside the main window and captures fine —
  so "the dialog is missing from the screenshot" is itself the signal that it is an AppKit modal.
- The Library list's row heights differ between the two voices, so a row's click point measured in
  Terminal misses in Study — re-read the row's y from a capture after every voice flip.

## Walker facts from the 13u3 UNIT F walk (2026-09-19)

- **A `.pdf` the app exported is read back by OPENING it in Preview and capturing Preview's own
  window id** — `open -a Preview <file>`, then `walk-cap $(pgrep -x Preview | head -1) <dir>`.
  `qlmanage -t` thumbnails lose the type rendering, and a thumbnail is not evidence that the page
  draws. Preview stacks windows, so `walk-cap` lists the newest FIRST (`w0.png` is the one you
  just opened) — read the names it prints rather than trusting the index.
- **Driving `NSSavePanel` with `cliclick`:** `kd:cmd,shift t:g ku:cmd,shift` → type the folder path
  → `kp:return` → `kd:cmd t:a ku:cmd` (select the name field) → type the base name → `kp:return`.
  The powerbox honours a path under the user's home; the app is sandboxed but the pick grants it.
- **The shelf quick-entry bar takes markdown characters cleanly** through `cliclick t:` (`*`, `#`,
  `~`, backtick, `[`, `(` all land; no smart-quote mangling) and it does **NOT** auto-continue a
  list on ⇧⏎ — so a typed `- first item` followed by ⇧⏎ leaves an empty paragraph, not a second
  lead. This is the reliable road for staging a markdown fixture; the full-document TK2 editor is
  still not (the UNIT B fact).
- **A block click point measured in one voice misses in the other by about one block**, because
  the two voices' line heights differ — and the miss is silent, so `⌥⌘C` lands a callout on the
  WRONG block and the only way you find out is by exporting the `.md`. Re-read the block's `y`
  from a fresh capture after every voice or appearance flip, and verify a per-block act by its
  projection rather than by the screenshot's wash.
- **A pre-unit build for a before/after pair:** `git worktree add /tmp/<name> <commit>` +
  `xcodebuild build -scheme Variorum -destination platform=macOS -derivedDataPath <dd>` gives a
  second Debug app on the SAME dev store (same bundle id, same container). Run them STRICTLY one
  at a time — `tell application id …` cannot tell two instances apart (the UNIT E fact) — and
  `git worktree remove --force` afterwards.

## Walker facts from the 13u3 UNIT G walk (2026-09-19)

- **TWO DEV INSTANCES ON ONE DEV STORE is the road for staging a sync-shaped race by hand.**
  `open -n <app>` twice gives two PIDs on the same store (WAL, both hold the same SQLCipher key),
  and a ceremony sheet open in instance A **SURVIVES** instance B being activated and writing.
  Her J16 ruling ("the sheet dismisses when another window is raised — it's just cancelled") is
  about another WINDOW of the same app; another PROCESS does not cancel it. This is what makes
  "a row changed in the store while the sheet was open" walkable at all.
- **The dev store is ENCRYPTED** (SQLCipher since 13p — `head -c 16 …/Variorum-dev/variorum.sqlite`
  shows no `SQLite format 3` header), so an external `sqlite3` writer cannot stage a row change.
  Two instances are the substitute; don't waste time looking for the plaintext road.
- Quit the EXTRA instance by **PID** (`kill -TERM <pid>` on a pid `pgrep` proved is yours), then
  the last one by identity (`tell application id "io.lduarte.Variorum.debug" to quit`) — never a
  keystroke (the UNIT D rule). Verify `pgrep -fl 'Variorum.app/Contents/MacOS'` after each.
- **A second instance does NOT pick up a voice change made in the first** (the voice is a synced
  store `setting`; the second process kept rendering Terminal while the first went Study). Read
  each instance's voice from its own capture rather than assuming they match.
- Settings ▸ Appearance at `(200,120) 560×548`: **Terminal = (614, 280), Study = (686, 280)** in
  SCREEN points. Restore the voice you found when you are done — it is her dev store's state.
- **The Library ▸ Notes cards mode is the cheapest place to verify a take-RESOLUTION change**: the
  card's second line is the note's opening blocks, so archiving/re-pointing a chosen take shows up
  there without opening the note.
- `walk-cap` refuses silently-ish if the outdir does not exist (`screencapture: cannot write file`)
  — `mkdir -p` it first.

## Walker facts from the 13u4 units + the orchestrator's own walk (2026-09-20/21)

- **`cliclick t:` DROPS characters in the shelf's quick-entry bar** even at 70 ms spacing, and ⌘A
  does not select that field (C1; met again at the orchestrator's walk). The reliable road is
  `osascript … keystroke "…"` — with a RE-ACTIVATION before every burst (a capture steals focus).
- **Multi-modifier `cliclick` chords are UNPROVEN** (`kd:cmd,shift t:m` silently did nothing at the
  orchestrator's walk) — chords go through `osascript keystroke "m" using {command down, shift down}`.
- **The capture boxes substitute typed quotes** (U+201D), so a screenshot cannot tell straight from
  curly — read the box's AX value and `xxd` it (C1's find; the microsyntax brain now accepts both).
- **Voice flips move the geometry**: the quick-entry bar's y moves ~70 screen points between
  Terminal and Study (C1), and the shelf's book rows move too (Sherlock at screen y 349 Terminal /
  384 Study at 1700×1000 — F3); the signpost's `rows=` is the tell for a wrong-book click. Re-read
  every point from a fresh capture after a voice or appearance flip.
- **A fresh launch always lands on `~/shelf`, and a book always opens in Outline** (mode is session
  state — F3).
- **Capture arithmetic** (C2): a full-screen `screencapture -x -o` is screen pixels with NO window
  offset (point = px/2); `walk-cap`'s window capture needs the window's Y added back (point =
  px/2 + windowY). Mixing the two conventions puts a click one bar-height off, silently.
- **A `.contextMenu`'s rows land relative to the right-click point** — re-measure from a fresh
  full-screen capture after every open (S2). Better: menu rows are TYPE-SELECTABLE — `keystroke
  "<row name>"` then `key code 36` avoids coordinate risk entirely (the orchestrator's walk).
- **`sips --cropOffset` is unreliable two ways**: S1 saw crops land mid-image; S2 saw it work
  EXCEPT past the image's own height, which returns a blank PNG reading exactly like "the surface
  drew nothing". Prefer reading the full capture or `sips -Z`.
- **`cliclick t:[` fails as a zsh glob** — bracket chords via `osascript … keystroke "[" using
  command down` (S1).
- **⌘, is swallowed by the full-document editor** — open Settings via the app menu's item (F2).
  The Settings window comes up 720×552 at (200,120); `screencapture -l <note window id>` is
  unoccluded by Settings sitting on top (F2; both re-verified at the orchestrator's walk).
- **`walk-scroll` is positive-is-down**; ±260 lines crosses a 10k-word note (F2).
- **RETIRED: the 13u3 UNIT E fact about the Restore Tutorial door's AppKit modal** — that door is
  a SwiftUI `.alert` since 13u4 S3 (ESC cancels; it draws inside the window and captures normally).
