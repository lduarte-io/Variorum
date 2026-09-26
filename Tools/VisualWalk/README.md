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
# the seeded scenarios, both voices (~20 min); the dev app is built first if --build
VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --build --voices terminal,study

# one or two scenarios, the voice the dev store already speaks
VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --only note-reopen,index-click

# the harness's own tripwire: a planted, knowingly wrong expectation — must exit 1
VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh --selftest

# the same as an env-flagged test (skipped unless the flag is set; its own package — no default suite)
cd Tools/VisualWalk && VARIORUM_VISUAL_WALK=1 swift test

Tools/VisualWalk/visual-walk.sh --list      # the scenario table
```

Output: `notes/plans/vis-walks/<date>/<HHMMSS>/` (gitignored) — `report.md` (the per-scenario table and
every assertion with its measured and expected values), `report.tsv`, `run.log` (every act and guard),
`probes.log` (every oracle answer), and the captures `<voice>/<scenario>/NN-*.png`.
Exit: **0** no FAIL/ERROR · **1** a FAIL or ERROR · **4** aborted (a guard fired) · **5** refused.

## When to run it (the standing cadence, design decision 6)

On demand at the close of any phase that touches the editor, and **ONCE AFTER EVERY macOS UPDATE on
the then-unchanged tree** — TEXTKIT2_NOTES §5's re-verify rule made executable: tree unchanged + a
red = the OS moved (her attribution question, answered by construction).

## Preconditions (loud refusals, never workarounds)

`VARIORUM_VISUAL_WALK=1`; her `/Applications` app NOT running; no other Variorum instance; this
terminal holds Accessibility + Screen Recording (granting is hers); the machine author-free (10 s with
no input — it waits up to a minute). A system dialog on screen is noted and never touched.

## The per-step safety (every GUI act)

`Tools/WalkKit/guard.sh`, consumed in place (one guard, one home): her app absent · HID idle ≥ 2 s · our
pid frontmost · our window on this Space with the click point inside it — plus two rules this harness
adds, born of a real incident (a stale "wants access to control Finder" consent prompt sat over the
window; a click landed on it and it took keyboard focus, so a ⏎ would have pressed *Allow*):
**never click a point any system dialog covers** (`helpers/vis-foreign.swift`), and **never type
unless the probe says our window is key**. Settings controls are pressed by AXPress (no screen point).
A guard that fires aborts the run (exit 4); the app it launched is quit by identity/pid.

## The assertions (her three rules)

(a) the first visible line and the caret's line move ONLY when the act moves them (line offset +
screen y, ±0.5 pt); (b) the last line's glyph box lies inside its surface — the inline editor's frame
equals the one measurement brain's height (±1 pt) and its last line's descenders are inside;
(c) a click lands the caret on the clicked line (the click's y inside the caret's line box; the caret x
within 12 pt of the click; never the blank line under the text).

Statuses: **PASS** · **FAIL** (a regression) · **XFAIL** (an OWNED KnownIssues row reproduced — shown
with its number, not red) · **XPASS** (a known row did NOT reproduce — flagged; re-examine the row) ·
**ERROR** (a fixture or harness precondition — red).

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
| `outline-narrow-restore` | U0 item 2 | the live inline note keeps its whole text at 1440 → 1100 → 900 → back |
| `b5-return-after-cmd-down` | row 88 (B5) | ⏎ at the tail after ⌘↓ on a carve-invalidated layout must not move the page — known, intermittent |
| `b5-refont` | row 88's re-font road | the same after a whole-document re-font |
| `selftest-red` (`--selftest`) | the guard rule | a planted wrong expectation must FAIL |

Fixtures are the dev store's sample library (Sherlock). Mutating scenarios restore their text; the
carve leaves its empty block in the note's tray (the walks' accepted residue). Chrome controls are
found by their accessibility labels (`helpers/vis-ax.swift`), never by remembered coordinates.

## The pieces

`visual-walk.sh` (entry, preconditions, per-voice FRESH launches — a pass's first opens are real first
opens) · `lib.zsh` (acts, guard, probe + settle, assertions, report) · `scenarios.zsh` (the table) ·
`helpers/` (`vis-probe` asks the app, `vis-win` finds its window, `vis-foreign` lists system dialogs,
`vis-ax` finds/presses a control by label, `vis-tcc` checks the grants; compiled into `bin/`,
gitignored) · `Package.swift` + `Tests/` (the env-flagged wrapper). `VW_DD=<derived data>` points the
harness at another build — how it was shown to RED on a real reverted fix (U-VIS RECORD).
