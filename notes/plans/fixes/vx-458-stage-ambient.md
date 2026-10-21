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
  (seen in an offscreen still at 120 s). It was red on the old fill and is green after. The figures
  at the time were 5725–6086 of 6111 pixels wrong at 40–3600 s, on the then half-res every-pixel test;
  the round-1 reviewer re-verified on the quarter-res test: 1463–1559 of 1568. Round 1 then widened
  its reference (below).
- A first attempt pinned the lit share of the water instead. It was green on both sides (hollow) and was
  replaced.
- **The coordinator's integration test** (1018coordinator, after the window, from its own seat) found a
  real bug before passing. Under its standard hold, "HOLD: coordinator queue — ask 1018coordinator",
  `on` refused with "lock without a claim file". Mechanism: under a UTF-8 locale bash 3.2's `%q` writes
  the em dash's lead byte raw (0xE2) and the continuation bytes as `\200\224`, so the claim file is not
  valid UTF-8, the text read returned nil, and that read as a missing file. The first suite ran
  `Tools/stage` with no `LANG` (C locale: all-octal, valid ASCII). Fixed at 70f095a9c: the claim is
  read and unquoted as bytes, and a file without WHO/REASON is its own `.unreadable` verdict, still
  refused. Pins, red on the old reader and green after: every real-`Tools/stage` probe under both
  `en_US.UTF-8` and `C`, the exact bytes of its hold, and the unreadable case. It passed under an ASCII
  hold with the old build: `on` exited 0 and logged `stage=hold`.

## The proposals, and what became of them

Her word, 2026-10-20 evening: "ok you can merge that draft PR. and I think that doing the small Tools /
stage hook before you do would be a good idea - I'm about to start a new coordinator so it would be fun
to try it out." Both landed together as **VX-459** (PR #181).

- **The `Tools/stage` hook**, now APPLIED. Rail 2 had said "propose — don't make unasked", and she has
  now asked. On a claim or re-claim whose reason isn't `HOLD:`, it takes the ambient down before the
  claim returns. Beyond the proposal below, it acts only when `$HOME/.variorum/ambient.state` exists.
  That keeps sandboxed `Tools/stage` runs (the ambient's own `StageClaimTests` use a throwaway HOME) from
  ever killing the real ambient. It always returns 0, so a successful claim never exits 1 under `set -e`.
  Proven with fakes only (a copy of `Tools/stage`, a fake `ambient`, fake `pgrep`/`pkill`):
  - a non-HOLD claim calls `ambient off`;
  - `HOLD:` doesn't;
  - a holder's re-claim to `HOLD FOR …` does;
  - `ambient off` failing still gives `STAGE CLAIMED`, exit 0;
  - with no state file it does nothing;
  - with no wrapper it falls back to `pkill`.

  The live trial is her new coordinator. The proposal as first written:

  ```diff
  +# VX-458: a claim that isn't the coordinator's HOLD takes the screen back from the stage ambient at
  +# once (the ambient also quits itself within ~0.3 s of seeing such a claim).
  +# (|| true throughout: Tools/stage runs under set -e, and a claim that succeeded must never exit 1.)
  +ambient_off() {
  +  pgrep -x StageAmbient >/dev/null 2>&1 || return 0
  +  if [ -x "$(dirname "$0")/ambient" ]; then "$(dirname "$0")/ambient" off >/dev/null 2>&1 || true
  +  else pkill -TERM -x StageAmbient || true; fi
  +}
  ...
       if mkdir "$LOCK" 2>/dev/null; then
         write_meta "$WHO_ARG" "$REASON_ARG" "$MINUTES"
         logline "CLAIMED   who=$WHO_ARG reason=$REASON_ARG minutes=$MINUTES"
  +      case "$REASON_ARG" in HOLD:*) ;; *) ambient_off || true ;; esac
  ```

  The same line goes after the holder's renew-by-reclaim, since a renew can change the reason.
- **The coordinator-skill diff**, MERGED at her word with the hook (PR #181): branch `vx-458-coordinator-skill`. It turns the ambient on after a
  verified RELEASE and re-hold when nobody is READY, off before every GO ("ambient not running" joins the
  pre-GO checks) and at window close, and adds a short section on the ambient.

## Review ladder

Same-model (Opus implemented, an Opus reviewer cold): the orchestrator, the implementing session itself,
arbitrates against her brief. Every round's reviewer is fresh, and the prompt is `notes/REVIEW_PROMPT.md`
verbatim with VX-458 substituted. The only addition is one logistics line: where the branch is checked
out, and not to run `Tools/ambient` or the window, because the coordinator's live instance runs from
this worktree.

**Integration re-run on the round-1 build (8b67312f5), from the coordinator's seat under its em-dash
HOLD:**
- `off` stopped the old pid in 316 ms;
- `on` came up "AMBIENT ON — RUNNING scene=koi pid=61216";
- `status` exited 0;
- the log line reads `ON … stage=hold who=1018coordinator return-to=Ghostty`.

The coordinator treats an `on` refused for "display asleep" as expected overnight.

### Round 1 — 0 BLOCKER · 0 MAJOR · 5 MINOR · 6 NIT; all agreed except one SPECULATIVE (recorded)

| # | Finding | Disposition |
|---|---|---|
| R1-1 MINOR | The idle gate went stale before launch: idle was read before the build, and the app counted input only from its own launch, so a touch during the build was ignored and the ambient came up over her. | FIXED. `on` re-reads the claim AND the idle after the build, then passes that moment as `--input-since`. The app counts any HID event after the gate (`InputRule.watching(uptime:gateAge:)`); with no gate it counts from launch + 0.75 s (documented). Pin `aTouchBetweenTheGateAndLaunchEndsIt`: red with the gate ignored (revert R-a), green after. The wrapper half has no shell harness and is not pinnable headlessly. |
| R1-2 MINOR | An already-asleep display drew at full rate unseen; the README's "pauses while the display sleeps" held only for a sleep after launch. | FIXED: refuse at launch (`LaunchRule`, exit 7 "display asleep"), via `CGDisplayIsAsleep` on the built-in display. Pin `anAsleepDisplayRefuses`: red with the clause removed (R-c), green after. |
| R1-3 MINOR | Process-name identity collided with the offscreen dev aids (same binary name): `on` said already-on, `off`/`next` killed a render, and the pre-GO pgrep and the proposed hook saw it. | FIXED structurally. The offscreen aids moved to their own executable, `AmbientRender`, so the window app is the only process named `StageAmbient`, and `list` runs AmbientRender. Not pinnable headlessly (the identity is in the build products); recorded as structural. |
| R1-4 MINOR | The rail-2 mid-write debounce (what survives the coordinator's own renews) lived untested in the host. | FIXED: moved into `StageWatch` (AmbientKit) and pinned three ways (renew mid-write stays up; unsettled for 0.5 s or more ends it; foreign ends it at once). All three go red with the grace removed (R-b). The host only feeds it. |
| R1-5 MINOR | The proposed `Tools/stage` hook could make a successful claim exit 1 under `set -e`. | FIXED in the proposal text above (`\|\| true`). Still a proposal, hers. |
| R1-6 NIT | The skill never spells out that `HOLD:` is the coordinator's idle hold only. | FIXED on the stacked skill branch: one line ("a hold on someone else's behalf never starts with `HOLD:`"). The tip was merged into the branch, not rebased, because pushed history is never rewritten. |
| R1-7 NIT | The caustic lattice was one column/row short at the far edges, and the pin's reference shared the short lattice. | FIXED: `+ 4`, and the reference became an exhaustive search over a wider lattice. Red on `+ 3` (10 of 13775 at 3600 s, 5 at 7211 s), green after. |
| R1-8 NIT | `on`'s "verified up" could fire before the window was ordered front; UNVERIFIED left the process running; the quoted log line could be stale. | FIXED. State is written only after order-front, activation and the cursor hide (`isUp`), and a window that isn't visible refuses (exit 8). UNVERIFIED now takes the process down, so exit 1 always means "not up". The log line is quoted only if this launch wrote it. |
| R1-9 NIT | The record's pin figures came from an earlier version of the test. | FIXED (Pins, above). |
| R1-10 NIT SPECULATIVE | The reused frame buffers are rewritten while older CGImages may still reference them. | RECORDED, no change. Core Animation copies at commit (the sampled commit path shows a send, not a re-read), and three buffers keep a margin. The code comment says never cut it to one. |
| R1-11 NIT | A quit Apple Event skipped `finish`: no OFF line, no focus hand-back. | FIXED: `applicationShouldTerminate` routes through `finish` ("quit request"). |

### Round 2 — 0 BLOCKER · 0 MAJOR · 2 MINOR · 6 NIT; all agreed. No new BLOCKER or MAJOR, so the ladder closes (no round 3)

These are the final round's fixes, so per the ladder the orchestrator checked each one line by line
against its finding. The two host findings also get a stage probe (below).

| # | Finding | Disposition |
|---|---|---|
| R2-1 MINOR | The R1-11 fix answered a quit Apple Event with `.terminateCancel`, which by AppKit's contract aborts a logout/restart/shutdown (Apple: "To abort the termination sequence … return NSTerminateCancel"). | FIXED. `applicationShouldTerminate` runs the synchronous wrap-up (cursor, window, focus hand-back, state, log) and returns `.terminateNow`. `finish` is split into `wrapUp` + the exit beat. Probe: `osascript -e 'quit app "StageAmbient"'` should exit 0 with `OFF quit request` logged (the stage window below). |
| R2-2 MINOR | "Up" was declared before activation was confirmed (activation is a request), so a declined activation would say ON with the cursor visible and the waking keystroke landing in the hidden front app. And the exit-8 refusal didn't hand focus back. | FIXED. `declareUp()` runs only once the app is active (`applicationDidBecomeActive`, or already active). It writes the state file, so `on` says ON only then. With no activation in 2 s it refuses (exit 9, "activation was declined"). `refuse` now restores the screen and hands focus back like `finish`. Probe: after `on`, the front pid equals the ambient pid. |
| R2-3 NIT | The second gate read idle before `since` was stamped, leaving a gap of tens of ms. | FIXED: `since` is stamped first, so the two overlap. No shell harness. |
| R2-4 NIT | `usage()` printed a stray `set -uo pipefail`. | FIXED: it prints the header comment block and stops at the first code line (checked: `ambient help`). |
| R2-5 NIT | The host header said "a device pixel or two" (it's up to 2.5 points), and README rail 7 said "losing focus" hands activation back (it deliberately doesn't). | FIXED: both reworded. |
| R2-6 NIT | `build()` compared only the binary, could swap the bundle under a live ambient, and hid codesign's errors. | FIXED: the Info.plist is compared too; no swap while the ambient runs (it says so and refreshes at the next `on`); codesign errors are shown. |
| R2-7 NIT | The idle gate failed open on an unreadable idle or a non-numeric `--min-idle`. | FIXED: `--min-idle` must be whole seconds (exit 2), and an unreadable idle refuses. |
| R2-8 NIT | The `HOLD FOR <who>` spelling lived only in the skill's new ambient section, not where an expired claim's hold is written. | FIXED on the stacked skill branch: the "An expired claim" section says it too. |

**Round-2 stage probe** (vx-458-probe2, 02:26:11–02:26:31 MDT; GO from 1018coordinator; no input posted):
- R2-2: `on` printed ON with the front app = StageAmbient (pid 67630, the ambient's own) and the cursor
  hidden.
- R2-1: `osascript -e 'quit app "StageAmbient"'` exited **0** (not cancelled). The app was gone in 136
  ms, logged `OFF quit request (up 6.3 s, return-to=Ghostty)`, the cursor came back, the terminal was
  frontmost again, and the state file was cleared.
- On/off round trip: ON with StageAmbient frontmost; `off` 221 ms.
- End: stage free, 0 StageAmbient, 0 Variorum.
- One cosmetic leak found and fixed: codesign's routine "replacing existing signature" reached `on`'s
  output after R2-6. It is now shown only on failure.

**The ladder is closed.** Round 1: 0 BLOCKER, 0 MAJOR, 5 MINOR, 6 NIT. Round 2: 0 BLOCKER, 0 MAJOR,
2 MINOR, 6 NIT. Every finding fixed or recorded, the coordinator's integration test passed twice, and
the final round's host fixes were proven on the screen.

