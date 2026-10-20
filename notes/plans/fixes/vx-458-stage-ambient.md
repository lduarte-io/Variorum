# VX-458 — the stage ambient (a 1-bit koi pond on the Pro's screen between stage windows)

**Ticket:** VX-458 (Feature · Tests & tooling · Low · no project, worked at once, at her word).
**Branch:** `vx-458-stage-ambient` (worktree `~/dev/variorum-ambient`). The proposed coordinator-skill diff
sits on the stacked branch `vx-458-coordinator-skill`, for her review.
**Session:** variorum-40 (Opus 5.5), 2026-10-20. The stage was granted by 1018coordinator.
**What shipped:** `Tools/ambient` (wrapper) + `Tools/StageAmbient/` (its own Swift package; `README.md` is
the tool's contract: rails, scene system, measurements).

## Her words

Her message at kickoff (verbatim):

> hi claude fun side project today. use a worktree do not disturb the current work. message the
> 1018coordinator session if you need any advice or help or have more questions. i want it to rotate every
> so often, i never plug secondary displays in so not a concern. I also think a tree that's made out of
> lines of code or ascii characters growing and being pruned (like a bonsai tree) or a landscape going
> through the seasons (also in black and white, code / characters moving around the screen to make the
> scene), would be a cool idea for what to show and I'd like you to propsoe some ideas too.

Her brief, pasted with that message (verbatim):

> Build a small ambient-animation tool for the Pro's stage coordinator: a full-screen, black-and-white pixel
> scene that plays on the Pro's screen while no walk or test run is using it. The coordinator session turns
> it on and off. It is a coordinator tool, NOT part of the Variorum app. First scene: koi in a pond, seen
> from overhead.
>
> SETUP
> - Bout start per CLAUDE.md (pull this repo + the memory repo; Tools/vx sync from ~/dev/variorum on main).
> - File a VX ticket for it (kind Feature, Area Tests & tooling, Priority Low, not Pre-launch, no assignee;
>   ask me which project, or Parked with a reason). Work on branch vx-NNN-stage-ambient in
>   ~/dev/variorum-ambient; merge to main by PR, merge commit only. No Co-Authored-By / Claude-Session
>   trailers.
> - Read first: CLAUDE.md (Tracker & parallel work, Environment), Tools/stage,
>   .claude/skills/stage-coordinator/SKILL.md.
>
> WHERE IT LIVES
> - Tools/ambient/ as its OWN Swift package (its own Package.swift) — never in the app target or
>   VariorumCore. No third-party dependencies: Apple frameworks only (AppKit + Core Graphics, or
>   SpriteKit/Metal — the lightest that works smoothly).
> - A shell wrapper like Tools/stage: `Tools/ambient on [--scene NAME]`, `off`, `status`, `next`.
>   `off` is synchronous: it returns only once the process is verified gone.
>
> HARD RAILS (the stage depends on these — don't bend them without asking me)
> 1. The process and app name must NOT contain "Variorum" — coordinators gate on `pgrep -lx Variorum` and
>    `pgrep -lf "MacOS/Variorum$"`. Something like `StagePond`.
> 2. It must never be on screen while anyone else holds the stage. The coordinator turns it off before
>    every GO; ALSO the app watches ~/.variorum/stage.d/claim and quits itself within ~1 s whenever a claim
>    exists whose reason doesn't start with "HOLD:" (the coordinator's own holds). Propose — don't make
>    unasked — a small change so `Tools/stage claim` stops it too.
> 3. Never use the macOS screensaver mechanism (ScreenSaverEngine / .saver): if a password is required
>    after the screensaver, ending it locks the screen, and a locked screen breaks walks.
> 4. Never post input events or take assertions that fake user activity — the coordinator reads HID idle
>    time to tell whether I'm at the machine.
> 5. Real input from me (mouse move, trackpad, key) quits it at once, so I can just use the Mac.
> 6. Light on the machine — builds and test suites run beside it: a small logical resolution scaled up
>    nearest-neighbour, ~12–15 fps cap, low single-digit % CPU. Measure it and tell me the number.
> 7. Hide the cursor while it's up; restore it on EVERY exit path (quit, input, SIGTERM, crash-safe as far
>    as possible). Leave focus where it was when it quits.
> 8. Burn-in safe: nothing bright stays still for long.
>
> SCENE 1 — THE KOI POND (pure 1-bit black and white; ordered dithering for shading)
> - Overhead view. 5–9 koi, each a segmented body that bends as it swims (head leads, tail follows),
>   patterned with dithered patches standing in for colours. Movement from code, never a loop:
>   smooth-noise wander steering, gentle separation, soft avoidance of edges and lilypads, occasional
>   pauses and drifts, a rare dart.
> - Lilypads (some with a flower) drifting and turning very slowly; ripple rings when a koi surfaces;
>   maybe the odd falling leaf.
>
> SCENES AS A SYSTEM (so more can be added later)
> - A Scene protocol (setup / update(dt) / draw into a 1-bit buffer), a registry, and a JSON config with a
>   WEIGHT per scene; `on` picks a scene by weighted random. Rotating scenes every N minutes with a dissolve
>   is optional — ask me before building it.
> - Build the koi scene WELL; don't build other scenes yet. Bring me a short list of ideas instead.
> - Ask me: cover every display, or the built-in screen only?
>
> COORDINATOR INTEGRATION (a proposed diff for my review)
> - Update .claude/skills/stage-coordinator/SKILL.md: after a RELEASE verifies clean and the coordinator
>   re-holds, `Tools/ambient on`; before every GO, `Tools/ambient off`, with "ambient not running" added
>   to the pre-GO checks; off at window close.
>
> EVIDENCE
> - Showing it on the Pro's screen IS stage use: ask the current stage coordinator for a claim by REQUEST
>   / READY, and wait for its GO with the exact claim line. Window-scoped captures only. Never touch the
>   dev store or /Applications.
> - Show me: a few frames or a short screen recording, the CPU figure, proof it quits within ~1 s of a
>   non-HOLD claim and on a mouse move, and the cursor coming back each time.
>
> OUT OF SCOPE: anything inside the Variorum app, sound, network.

Her answers in-session (AskUserQuestion, 2026-10-20):
- **Project:** "No project, built now". The ticket is the whole effort.
- **Scenes:** "koi only + idea list + give me some ideas and I'll choose a couple + provide a couple.
  maybe we can start with like 7-10 different ones and i can watch them all and pick the ones i like
  best." The ten ideas are in the README.
- **Displays:** her kickoff message covers it ("i never plug secondary displays in"). The built-in screen
  only.
- **Rotation:** her kickoff message covers it ("i want it to rotate every so often"). Built: every 10
  minutes with a 3 s pixel dissolve, configurable in `ambient.json`, with `--stay` to pin a scene.

## The coordinator's asks (1018coordinator, adopted as written)

1. `on` is idempotent and returns once the window is verified up. It refuses (exit 1, one line) while any
   claim's reason doesn't start with exactly `HOLD:` (its `HOLD FOR <walk>` hold must keep it off).
2. It launches as a small .app through LaunchServices, so it outlives the calling shell.
3. `off` is synchronous: exit 0 when gone or when it wasn't running, nonzero only if it couldn't stop it.
4. `status` always exits 0 with one line.
5. A self-quit writes one line to its own log (`~/.variorum/ambient.log`), never to `stage.log`.
6. `GO pending:` bridge claims end it.
7. `--allow-claimant` names exactly ONE who and is a self-test option only, never on the coordinator's
   road.

Its wish that the app "come up without taking focus" conflicts with rail 7: macOS hides the cursor only
for the active app. That is resolved below, within her brief's "leave focus where it was when it quits".

## Decisions taken in the build (each one reversible)

- **Where it lives.** A path can't be both the package directory and the `Tools/ambient` command. The
  package is `Tools/StageAmbient/`, matching the CamelCase tool packages (`VisualWalk`, `WalkKit`,
  `StringsWorkbook`). The command is `Tools/ambient`, beside `Tools/stage` and `Tools/vx`. The brief's
  command spelling is kept exactly. The process and bundle are `StageAmbient` (bundle id
  `io.lduarte.StageAmbient`).
- **The lightest stack that works:** AppKit + one Core Animation layer + Core Graphics. No SpriteKit or
  Metal; nothing needed them.
- **Cursor and focus (rail 7).** An agent app launched through LaunchServices and calling
  `NSApp.activate()` was NOT activated (measured), and `CGDisplayHideCursor` without activation left the
  cursor visible (measured). `activate(ignoringOtherApps: true)` activates it. So it takes activation while
  up and hands it back to the app that was frontmost at `on` on every exit. A side effect: the waking
  keystroke is swallowed by the ambient instead of landing in a hidden app. The road not taken is a
  private CoreGraphics connection property that hides the cursor in the background. It is not used, and
  using it would be her call.
- **An idle gate on `on`.** It refuses while HID idle is under 120 s (`--min-idle` overrides). Because the
  ambient swallows the waking keystroke, popping up while she types would eat one.
- **Input detection reads** `CGEventSource.secondsSinceLastEventType(.hidSystemState, anyInput)` ten
  times a second, with a 0.75 s launch grace. Nothing is posted or asserted.

## Evidence (the stage window, vx-458-ambient, 01:29:44–01:43:19 MDT, GO from 1018coordinator)

- On screen: window-scoped captures (`screencapture -l <its window>`) in `~/vx458-ambient/window/`,
  including `on-screen-burst.gif`, `first.png` and `dissolve-mid.png`. An offscreen render of the same
  Director, 30 s at 12 fps, is `~/vx458-ambient/koi-offscreen-30s.gif`.
- **CPU:** 3.8% of one core on screen over 90 s, with RSS 50 MB. WindowServer was 14.4% with it up, vs
  13.3% baseline with it off. The first build measured 12.5%. The fixes found by sampling: Core Animation
  re-rendered the 8-bit gray image into the display colour space every frame (now 32-bit frames in the
  screen's colour space from three reused buffers), the caustic web is computed at quarter resolution once
  a second, and lilypads are cached sprites.
- **Quit proofs:**
  - Real-lock probe swap (release vx-458-ambient && claim vx-458-probe): gone in **375 ms**.
  - One `cliclick m:+1,+0` at **01:35:22**: gone in **248 ms**.
  - `Tools/ambient off`: **213–253 ms**.
  - `kill -9`: gone in 23 ms, and the window server restored the cursor.
  - After every exit: `CGCursorIsVisible` = 1 and the terminal frontmost again. While up: StageAmbient
    frontmost, cursor hidden.
- **The coordinator's HOLD semantics** were proven headless against the real `Tools/stage` in a
  throwaway HOME (`StageClaimTests`: `HOLD:` permits; `HOLD FOR`, `GO pending:` and ordinary claims end
  it; a lock without its claim file is pending).

## Pins

- `WaterTests.theCellSearchFindsTheTrueNearestPoints`. The caustic lattice was filled from the wrong
  drift base, so after a minute or two the 3×3 cell search compared the wrong points and whole blocks lit
  (seen in an offscreen still at 120 s). It was red on the old fill (5725–6086 of 6111 pixels wrong at
  40–3600 s) and is green after.
- A first attempt pinned the lit share of the water instead. It was green on both sides (hollow) and was
  replaced.

## Proposed, not applied (hers to rule)

- **The `Tools/stage` hook** (her rail 2: "propose — don't make unasked"). On a claim whose reason isn't
  `HOLD:`, take the ambient down synchronously. The ambient already goes within about 0.3 s by itself;
  this makes the handoff instant.

  ```diff
  +# VX-458: a claim that isn't the coordinator's HOLD takes the screen back from the stage ambient at
  +# once (the ambient also quits itself within ~0.3 s of seeing such a claim).
  +ambient_off() {
  +  pgrep -x StageAmbient >/dev/null 2>&1 || return 0
  +  if [ -x "$(dirname "$0")/ambient" ]; then "$(dirname "$0")/ambient" off >/dev/null 2>&1
  +  else pkill -TERM -x StageAmbient; fi
  +}
  ...
       if mkdir "$LOCK" 2>/dev/null; then
         write_meta "$WHO_ARG" "$REASON_ARG" "$MINUTES"
         logline "CLAIMED   who=$WHO_ARG reason=$REASON_ARG minutes=$MINUTES"
  +      case "$REASON_ARG" in HOLD:*) ;; *) ambient_off ;; esac
  ```

  The same line goes after the holder's renew-by-reclaim, since a renew can change the reason.
- **The coordinator-skill diff:** branch `vx-458-coordinator-skill`. It turns the ambient on after a
  verified RELEASE and re-hold when nobody is READY, off before every GO ("ambient not running" joins the
  pre-GO checks) and at window close, and adds a short section on the ambient.

## Review ladder

(Appended per round.)
