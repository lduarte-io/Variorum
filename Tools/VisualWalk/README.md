# VisualWalk — the opt-in visual regression harness (18l U-VIS)

Her standing ask (2026-09-25): *"tests that can run (don't have to be part of the suite that run every
time) where screenshots are taken of edits, clicks, if the editor has moved unexpectedly between
clicks, etc."* The design is `notes/plans/phase-18l-navigation-feel.md` § U-VIS DESIGN NOTE; the
build record is § U-VIS RECORD there.

**What it is.** An EXTERNAL driver over the REAL window (never a mounted surface — KnownIssues' rows on
the in-process click rig and on pointer injection are the classes that design dodges). It launches its
OWN dev-store Debug build (`io.lduarte.Variorum.debug`, never `/Applications`), drives it with
`cliclick` + System Events, and after every act asks the app where things ARE — the DEBUG oracle
endpoint `App/Variorum/Variorum/Core/Views/VisualWalkProbe.swift` — and asserts on those numbers.
Captures ride beside the numbers as evidence; nothing is ever decided by comparing pixels.

## Run it

```
# the seeded scenarios, both voices (~15 min, measured); --build compiles AND stamps the dev app first
VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --build --voices terminal,study

# one or two scenarios, the voice the dev store already speaks
VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --only note-reopen,index-click

# the harness's own tripwire: a planted, knowingly wrong expectation — must exit 1
VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --selftest

# the same as an env-flagged test (its own package — no default suite). Without the flag it runs only
# the HEADLESS pins (pins/*.zsh: the guard order, the build stamp, the abort's voice, rule (c)'s rows)
cd Tools/VisualWalk && VARIORUM_VISUAL_WALK=1 swift test

Tools/VisualWalk/visual-walk.sh --list      # the scenario table
```

Output: `notes/plans/vis-walks/<date>/<HHMMSS>/` (gitignored) — `report.md` (the per-scenario table and
every assertion with its measured and expected values), `report.tsv`, `run.log` (every act and guard),
`probes.log` (every oracle answer), and the captures `<voice>/<scenario>/NN-*.png`.
Exit: **0** no FAIL/ERROR · **1** a FAIL or ERROR · **4** aborted (a guard fired, or the harness could
not go on — `aborted` in the run folder says which, and names the dev-store voice if it was left
switched) · **5** refused (a precondition; nothing launched) · **9** a second abort (a refusal or
another Ctrl-C) inside the first abort's clean-up — the first already recorded the run and sent the quit.
Ctrl-C, TERM and HUP (the terminal closing) all abort the same way. If the app's menu quit ever fails,
the report says the app was TERMINATED (its quit path skipped) — never silently.

## The build under test (the stamp)

`build.sh` (what `--build` runs) compiles the Debug app and stamps it with what it was compiled FROM:
App/ and the core (Sources/ + the package manifests), each as the committed tree plus any uncommitted
diff or untracked file (names and contents — both build systems compile untracked sources). The report's header names that origin, and the driver **refuses** a build that is not this
tree's. `VW_DD=<derived data>` points the harness at a SCRATCH build — how it proves it can red on a
real reverted fix (`build.sh --src <worktree> --dd <worktree>/dd`, then `VW_DD=<worktree>/dd …`) — and
that build may differ from the tree **only under App/**: its core is what opens the dev store, and the
standing trap is absolute — **an old build must NEVER open the dev store** (bisect old trees by
harness in a scratch worktree with an in-memory store instead).

## When to run it (the standing cadence, design decision 6)

On demand at the close of any phase that touches the editor, and **ONCE AFTER EVERY macOS UPDATE on
the then-unchanged tree** — TEXTKIT2_NOTES §5's re-verify rule made executable: tree unchanged + a
red = the OS moved (her attribution question, answered by construction).

## Preconditions (loud refusals, never workarounds)

`VARIORUM_VISUAL_WALK=1`; her `/Applications` app NOT running; no other Variorum instance; a stamped
build of THIS tree; this terminal holds Accessibility, Screen Recording and the Automation grant for
System Events (all three CHECKED, never prompted — `helpers/vis-tcc.swift`; granting is hers); the
machine author-free (10 s with no input — it waits up to a minute). The dev app itself is sent no
Apple Event (it quits through its own menu, by accessibility, addressed to its pid). A system dialog
on screen is noted and never touched. Never ask the Automation state of a target whose consent prompt
is PENDING — the check blocks until she answers it (measured with Finder); so every check runs under a
time limit, and a check that times out is reported as exactly that — "a consent prompt may be pending"
— never as a missing Accessibility grant (round 2, MINOR-R2-3).

## The per-step safety (every GUI act)

`Tools/WalkKit/guard.sh`, consumed in place (one guard, one home), IN THIS ORDER: `guard.sh --author`
(her app absent · HID idle ≥ 2 s) BEFORE anything touches the GUI; only then the activation; then the
target checks (our pid frontmost · our window on this Space with the click point inside it); then the
act. "Someone is at the machine" ends the run — it is never retried with a re-activation (that would
move HER keyboard focus). Plus two rules this harness adds, born of a real incident (a stale "wants access to control Finder" consent prompt sat over the
window; a click landed on it and it took keyboard focus, so a ⏎ would have pressed *Allow*):
**never click a point any system dialog covers** (`helpers/vis-foreign.swift`), and **never type
unless the probe says our window is key**. Settings controls are pressed by AXPress (no screen point).
A guard that fires aborts the run (exit 4) — as does Ctrl-C — and the app it launched is quit; if the
pass had switched the dev store's voice, the abort restores it only when no author refusal caused it
and the author checks pass again, and otherwise writes "RESTORE OWED" (a Study store reds KnownIssues
row 90's pins on the next Mac suite).

## The assertions (her three rules)

(a) the first visible line and the caret's line move ONLY when the act moves them (line offset +
screen y, ±0.5 pt); (b) the last line's glyph box lies inside its surface — the inline editor's frame
equals the one measurement brain's height (±1 pt) and its last line's descenders are inside;
(c) a click lands the caret on the clicked line (the click's y inside the caret's line box; the caret x
within 12 pt of the click; never the blank line under the text).

Statuses: **PASS** · **FAIL** (a regression) · **XFAIL** (an OWNED KnownIssues row reproduced — shown
with its number, not red) · **XPASS** (a known row did NOT reproduce — flagged; re-examine the row) ·
**ERROR** (a fixture or harness precondition — red). A KNOWN label is placed only where the row
REPRODUCES (S3 on both read-tier hosts; B5 on the carve road in Study) — elsewhere the same assertion
is plain, so a standing non-reproduction does not raise an XPASS every run.

## The seeded scenarios (`scenarios.zsh`; add one = a `vw_def` row + a `scn_<name>` function)

| scenario | seeded from | asserts |
|---|---|---|
| `note-reopen` | U0c (R-18l-1) | first open at the START; palette and ⌥⌘[ / ⌥⌘] re-opens land the exact page |
| `write-typing` | her ask | a click lands on its line; three typed characters all land; the page and the caret's line do not move |
| `write-newline-roundtrip` | U0b (row 87) | ⏎ then ⌫ at a short note's end keep the first line and the page's top air |
| `write-divide-merge` | the design note | ⏎ mid-line divides, ⌫ merges back; the page never moves; the caret lands at the join |
| `mode-roundtrip` | the design note | Write → Read → Write returns the page and the caret exactly |
| `index-click` | U0 item 1 (row 86) | a read-tier click in the book Index goes live with the caret ON the clicked line, never the blank line |
| `readedit-click` | U0 item 1 | the same on Read ▸ edit |
| `read-landing` | 18l U1 (the F3 shape on note Read) | deep clicks through the contents column's filter, both faces (`RL_FACES` orders them; the first is truly cold): each landed block rests at its face's anchor (±3 pt) 6 s later, and its SHIPPING signpost (`landing surface=ReadNote…`) says `end=settled` — the probe's `rl` read |
| `outline-narrow-restore` | U0 item 2(a) | the live inline note keeps its whole text at 1440 → 1100 → 900 → back |
| `outline-long-story-settle` | U0 item 2(b) | the 212-block story, live, holds its SETTLED layout after each resize (its end scrolled into view) |
| `b5-return-after-cmd-down` | row 88 (B5) | ⏎ at the tail after ⌘↓ on a carve-invalidated layout must not move the page — KNOWN in Study (where it reproduces), plain in Terminal |
| `b5-refont` | row 88's re-font road | the same after a whole-document re-font — plain (it has never reproduced) |
| `selftest-red` (`--selftest`) | the guard rule | a planted wrong expectation must FAIL |

**Every seeded U0/U0b/U0c tripwire has been shown to RED on its own regression** — scratch builds with
the fix reverted (`build.sh --src`, `VW_DD`): R-full (U0b/U0c), R-U0-1 (both click scenarios), R-U0-2+3
(the short note's cut tail — R-U0-2 alone is healed by the settle net), R-U0-3 (the long story).
The U-VIS record holds the numbers.

Fixtures are the dev store's sample library (Sherlock). Mutating scenarios restore their TEXT, but not
every identity (N9): each pass per voice leaves, in *About this book* and *A Scandal in Bohemia*'s
trays, the carve's empty blocks and — `write-divide-merge`'s ⌫ at the seam being a MERGE (a fresh
block, both sources released to lineage) — two released blocks, and swaps one fixture block's
identity; leaving an edited note appends its quiet `closeAutoCommit` savepoints. Harmless to the
geometry; the walks' accepted residue.

**Read-tier targets and stale frames.** The Index / Read ▸ edit oracles keep a row's last frame until
its surface leaves, so a lazily de-realized row can leave a GHOST. Frames that overlap any other frame
are dropped as suspect (rows never overlap); a ghost overlapping nothing is caught after the click — the
live pane must stand within 12 pt of the frame, else a harness ERROR (red), never a product PASS. Two
edges, both fail-closed: frames are compared BY VALUE, so a ghost byte-identical to a live row survives
as "itself" (the post-click check still catches it); and the probe lists at most 40 frames top-down, so
accumulated ghosts could crowd the band's lower rows out (an ERROR, not a false pass). Chrome controls are found by their accessibility labels
(`helpers/vis-ax.swift`), never by remembered coordinates.

## The pieces

`visual-walk.sh` (entry, preconditions, per-voice FRESH launches — a pass's first opens are real first
opens) · `build.sh` (compile + stamp) · `lib.zsh` (acts, guard, probe + settle, assertions, report,
the stamp's verdict) · `scenarios.zsh` (the table) · `pins/` (the headless pins) ·
`helpers/` (`vis-probe` asks the app, `vis-win` finds its window, `vis-foreign` lists system dialogs,
`vis-ax` finds/presses a control by label, `vis-tcc` checks the grants; compiled into `bin/`,
gitignored) · `Package.swift` + `Tests/` (the env-flagged wrapper + the always-on headless pins).
