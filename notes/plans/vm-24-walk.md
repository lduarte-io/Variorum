# VM-24 — the simulator walk (the brief, and then its record)

**STATUS: BRIEF WRITTEN 2026-11-20; the walk has not run.** Part of the VM-24 run
(`notes/plans/vm-24-unwarned-edit-routing.md`, ledger row L9). The walk is the run's use-shaped evidence on the
simulator for both units: VM-24 (an edit the editor was not asked about no longer snaps back) and VM-243 (text typed
after a dash line is in full ink). It does not replace her phone: the simulator's keyboard is not her keyboard, and
the "after" session on her phone is still owed (the run record's §10).

## What the walk must show

Two passes of the SAME driver, one after the other, on one dedicated simulator device:

- **BEFORE** — the phone app built from main's code as the run found it (`8ff1d08af`'s code, which is the wave-1
  merge's).
- **AFTER** — the phone app built from the run's branch at the commit both batches' windows proved.

Each pass, in the Debug phone app (the dev store; signed out; Resume never pressed; no test account), in Study, light:

| Row | The act | What is captured | PASS on the AFTER pass |
|---|---|---|---|
| a | A new note; four short paragraphs typed with a Return between them; back out; open it again | the note | four paragraphs, full ink |
| b | Settings ▸ Diagnostics ▸ Record edit trace on; Edit trace… ▸ Clear | the readout, empty | the switch on, the readout empty |
| c | By the software keyboard's own keys (not `typeText`): at the end of the second paragraph, about twenty keys including a misspelling the keyboard may correct ("teh ", "recieve "); then a few keys in the middle of the third paragraph | the note after | every key typed is on the page; nothing typed is missing |
| d | Paste (the pasteboard set by the driver; the system's Paste) at the end of the second paragraph, then over a selected word in the third | the note after | the pasted words are on the page |
| e | Edit trace… | the readout's first screen | "desync recoveries 0"; on the AFTER pass the three new lines are drawn (widened, rescued, no capture) and "no capture" is 0. The numbers are written into the record for both passes |
| f | At the very end of the note: `- one`, Return twice, `two` | the note's end | only the dash is faint; "one" and "two" in full ink |
| g | On a new line at the end: `# Head`, Return, `word`; then on a new line `*a* b` | the note's end | "word" in the body font and full ink; " b" in full ink |
| h | Back out and open the note again | the note's end | the same words, the same inks |

On the BEFORE pass rows f and g are expected to show the bug (the dash line's words and the lines after it faint;
"word" in the heading's font). That pair of captures — before and after — is the picture of VM-243. Rows c–e on the
BEFORE pass are read, not predicted: if the simulator's keyboard ever lands an edit unarmed with a widened report,
"desync recoveries" is above zero there and zero after; if it does not, both are zero and the record says so plainly.

**A row that cannot be driven is said, never skipped silently** ("NOT WALKED", with the reason, and what stands in
for it).

## The instruments (throwaway — they never enter the PR)

- A UI driver in `VariorumMobileUITests`, written in a snapshot worktree (`~/dev/variorum-vm-24-walk`, detached at
  the AFTER commit) and kept only there. `MobileKeyboardRevealUITests.swift` (committed) is the model for launching
  the Debug app, opening a note and typing by the keyboard's own keys with the software keyboard up; reuse its
  helpers by copying, not by editing that file.
- A second snapshot (or a checkout of the same worktree at the BEFORE commit with the driver file copied in) for the
  BEFORE build. Two `build-for-testing` products, `DerivedData/vm24-walk-before` and `DerivedData/vm24-walk-after`,
  under the snapshot's own `App/Variorum/DerivedData/`.
- Captures as `XCUIScreen` screenshots written to
  `~/dev/variorum-vm-24/App/Variorum/DerivedData/vm24-walk-screens/<before|after>/<row>-<what>.png` (inside the
  gitignored DerivedData, VM-55's choice), with a `walk-log.txt` beside them (row, time, what was read from the
  readout — numbers only).
- A dedicated simulator device, created for the walk (`vm24-walk`, iPhone 17 Pro, iOS 26.2) and deleted after it.
  The driver must leave the host's Simulator preferences as it found them; anything it changes (the hardware
  keyboard connection, for one) is restored and said in the record.

## Who does what

- A fresh `opus-implementer` (the closer) writes and builds the instruments headless, then ends its turn with a
  READY report: the two products, the exact `test-without-building` commands (the UI test CLASS names, one argument
  each), what each pass leaves on the device, and the claim length it needs.
- The stage window is the orchestrator's to ask of nov18. The closer runs the walk only if the orchestrator relays
  the GO to it with the claim line; otherwise the orchestrator runs it from the closer's products.
- The orchestrator judges every row from its capture and writes the verdicts below. The closer does not judge.
- After the verdicts: the snapshot worktree(s), their DerivedData and the device are removed; the captures stay
  until the merge (then they are deleted with the rest of the run's evidence, unless she asks to keep them).

## The record (filled when the walk runs)

### The closer's instruments — LIVE STATUS

Closer: `opus-implementer` (Opus, xhigh), one session, started 2026-11-20. It writes and builds the instruments
headless and ends with a READY report; it does not boot a simulator, run a test, launch the app or judge a capture.
Reading done first, in full: this brief; CLAUDE.md and its loaded canon; `notes/SessionResiliencyProtocol.md`; the run
record's §1, §4, §7 and §10; `MobileKeyboardRevealUITests.swift` whole; the Settings sheet's Diagnostics group and the
edit trace's readout; the VM-55 record's walk-instrument section; the VM-44 runbook (the scheme-order trap).

| Piece | State |
|---|---|
| Record skeleton | DONE (`830d8d2d5`) |
| The two snapshots (AFTER at `562f815bd`, BEFORE at `8ff1d08af`), detached, nothing committed in either | DONE — `~/dev/variorum-vm-24-walk` and `~/dev/variorum-vm-24-walk-before`; `git status` in each shows only the untracked driver |
| The driver `VM24Walk.swift` (rows a–h), in both snapshots' `VariorumMobileUITests/` only, untracked | DONE — the same bytes in both snapshots (one checksum); 0 warnings and 0 errors from it in either build. The UI test folder is a synchronized group, so the file joins the target by being there (no project edit) |
| `build-for-testing`, AFTER (`vm24-walk-after`) and BEFORE (`vm24-walk-before`) | DONE — "** TEST BUILD SUCCEEDED **" in both, headless, no boot. Checked: the AFTER app carries the readout's new VM-24 line and the BEFORE app does not; each bundle holds both test selectors; each snapshot's tree is its commit plus the untracked driver only |
| `walk.sh` (untracked, in the AFTER snapshot) | DONE — syntax-checked; its pure pieces (the id shape test, the scrub, the runtime parse, the holder check, the prefs compare and restore road, the no-capture xctestrun copies) tested alone; its refusal path dry-run (a holder that cannot match: refused at the stage check, no device made, the closing line printed). Never run past the stage check |
| READY report | DONE (the session's final message) — the walk itself has NOT run |

### What the closer built (nothing of it enters the PR)

**The snapshots.** `~/dev/variorum-vm-24-walk` (detached at `562f815bd`, the run's tip — the AFTER code) and
`~/dev/variorum-vm-24-walk-before` (detached at `8ff1d08af`, main as the run found it — the BEFORE code). Each holds one
untracked file, `App/Variorum/VariorumMobileUITests/VM24Walk.swift`; the AFTER snapshot also holds `walk.sh` at its
root. Their products: `App/Variorum/DerivedData/vm24-walk-after` and `…/vm24-walk-before`, built for
`platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`.

**The scheme (a deviation from the brief's words, stated):** the `VariorumMobile` scheme's test action holds only
`VariorumMobileTests`, so its `build-for-testing` cannot carry the UI tests without a scheme edit. The products are
the `TK2SpikeUITests` scheme's — its build action is the same `VariorumMobile` app target, its test action is
`VariorumMobileUITests` (the committed model's own road and VM-55's). No scheme or project file is touched. The app
it builds lacks the hosted unit-test PlugIn (the VM-44 ordering trap), which this walk never uses.

**The driver — two classes, one argument each:** `VariorumMobileUITests/VM24WalkFirstRun` (the fresh install's first
launch, past the once-shown words card with no capture and no label read; the app terminated) and
`VariorumMobileUITests/VM24Walk` (the rows). The pass name and the screens folder arrive as `TEST_RUNNER_VM24_PASS`
and `TEST_RUNNER_VM24_SCREENS`. Every capture is a PNG written straight to
`~/dev/variorum-vm-24/App/Variorum/DerivedData/vm24-walk-screens/<before|after>/<row>-<what>.png` (ignored), with
`walk-log.txt` beside them: numbers and yes/no, and the note's text only when every word in it is the walk's own fixture.
A row that cannot be driven writes "NOT WALKED" with its reason, the on-screen chrome labels from one read of the
accessibility tree (never a key, never a text view's value, never while the words card is up) and a capture named
`<row>-NOT-WALKED-diagnostic.png`; the walk goes on, and the test never fails on a soft miss. The model it copies, never
edits: `MobileKeyboardRevealUITests.swift` (the launch, the lobby, the GraphicsServices hardware-keyboard setter, the
keyboard card, the on-screen finders, the keyboard-down drag).

**How each row is driven** (one launch for the whole walk, so the edit trace's in-memory counters run from b to e):

| Row | How | Captures |
|---|---|---|
| a | Library ▸ "+ New Note" (opens focused); the four paragraphs "Walk one alpha" … "Walk four delta" by `typeText`, a Return between each with a 1.2 s pause (the open tail crystallizes before the next words); keyboard down by a drag; Back; the note re-opened from its Library row (an untitled note's row title is its creation day) | `a-note-typed`, `a-note-reopened` |
| b | Library ▸ ⋯ (More) ▸ Settings; reads the Study and Follow system choices' selected state; "Record edit trace" switched on at its trailing edge (read back from its value); "Edit trace…" ▸ "Clear" | `b-switch-on`, `b-readout-empty` |
| c | The note re-opened; the text's drawn lines found from the screen's pixels inside the editor (XCUITest gives no line geometry), required to equal the paragraph count; a tap past the end of the second line puts the caret at the end of paragraph two; " ok teh recieve it" by the software keyboard's own keys (18 keys; a character with no key on screen falls back to `typeText` and is counted); then a tap mid-line on the third paragraph and " mid" by keys (4) | `c-note-after-typing` |
| d | Still in the note: the pasteboard set to " kilo"; the caret to the end of paragraph two, a second tap raises the system edit menu (a press if not), its Paste pressed; the pasteboard set to "lima"; a double-tap on paragraph three's last word ("charlie") selects it, the menu's Paste pressed. An "Allow Paste" ask is answered if the system raises one (it should not for her own Paste) | `d-note-after-paste` |
| e | Back to the Library ▸ ⋯ ▸ Settings ▸ "Edit trace…"; the headline read from the readout's text: every count by name, the three VM-24 lines read when drawn and never required | `e-readout` |
| f | The note re-opened; the caret to the end of its last drawn line; Return, "- one", Return, Return, "two" by `typeText` | `f-note-end` (keyboard up) |
| g | Return, "# Head", Return, "word", Return, "*a* b" by `typeText`; then the keyboard down | `g-note-end`, `g-note-end-keyboard-down` |
| h | Back; the note re-opened; its text compared with the text before leaving | `h-note-reopened` |
| z | EXTRA, not a table row: the readout again after rows c–h (the numbers for f–h) | `z-readout-after-all` |

Rows a, f and g type by `typeText` (the same keyboard input road; the brief asks for the keyboard's own keys in row c
only). Every Return is followed by a pause, so no typed character can meet a crystallization's flight in a way her
typing would not.

**`walk.sh`, in order:** prints the stage line and refuses on a free stage (or, with `VM24_WALK_WHO` set, on any other
holder) and warns under 35 minutes left; refuses unless both products are in place and each matches its tree (the
readout's new line present in the AFTER app, absent from the BEFORE one); writes, beside each built xctestrun, a copy
with XCTest's automatic capture off (`SystemAttachmentLifetime` keepNever, screenshots not screen recordings — the
built one asks for screen recordings, which in the first-run class would hold the words card); reads the host's
Simulator preferences; creates `vm24-walk` (iPhone 17 Pro, the iOS 26.2 runtime it resolves), boots it, sets light
appearance and the keyboard's auto-correction and predictions on (iOS's own defaults, written so no pass depends on
them), settles 30 s; the BEFORE pass (the first-run class, its result bundle and raw log deleted at once; then the walk
class); shuts the device down and ERASES it (a clean install: no app, no store, no keychain, no learned words, no
pasteboard), boots and settles again; the AFTER pass; then, on every exit road, stops only its own xcodebuild, shuts the
device down and deletes it, compares the host's Simulator preferences with what it found and restores them if anything
changed (naming the top-level keys, never their values), prints the host's after-state (no Mac Variorum instance, no
phone process, no Problem Reporter, new `Variorum*.ips` count), deletes its temp folder and prints "VM24 WALK END".
Each test run is polled for its verdict line (at most 7 minutes for the first-run class, 20 for the walk class), then
given at most 90 s to exit before its own PID alone is stopped. The device's id lives only in the script's variables;
every simctl and xcodebuild line it prints or keeps is scrubbed of it, and the raw logs and result bundles that name it
are deleted.

**What each pass leaves.** *On the device:* the Debug phone app on a fresh dev store, signed out, holding the walk's
one note (fixture words only), the starter Journal and the sample library its first write minted, the edit trace armed,
the keyboard's learned words, the pasteboard's "lima" — all of it gone at the erase between the passes and at the
deletion after. *On the host:* the captures, each pass's `walk-log.txt` and its two xcodebuild logs (scrubbed) under
`…/vm24-walk-screens/before/` and `…/after/`, and the script's own run log `…/vm24-walk-screens/walk-run.txt`; the two
`VM24Walk-noautocapture.xctestrun` copies inside the snapshots' products (removed with the snapshots). Nothing in git.
A re-run moves an earlier pass folder aside (`<pass>-earlier-<time>`) rather than over-writing it.

**The command** (inside a held stage claim, nothing else running on the stage):

    zsh ~/dev/variorum-vm-24-walk/walk.sh

About 25 minutes in the ordinary case (a ceiling near an hour if every run met its limit). It tees everything to
`~/dev/variorum-vm-24/App/Variorum/DerivedData/vm24-walk-screens/walk-run.txt`, whose last line is "VM24 WALK END": a
caller limited to short waits starts it in the background and polls that file for that line. By hand, for one class
(the device's id from `xcrun simctl list devices`, never written down):
`TEST_RUNNER_VM24_PASS=after TEST_RUNNER_VM24_SCREENS=~/dev/variorum-vm-24/App/Variorum/DerivedData/vm24-walk-screens
xcodebuild test-without-building -xctestrun <products>/VM24Walk-noautocapture.xctestrun -destination "id=<device>"
-only-testing:VariorumMobileUITests/VM24Walk`.

**Rows that may come back NOT WALKED on the first stage run** (the driver was never run; each is said, never faked):
row c's and d's placement if the drawn lines do not equal the paragraphs (a decoration or an extra drawn line inside
the editor); row d's Paste if the edit menu's Paste is not exposed as a menu item, button or text; rows b, e and z if the
readout's headline is not readable from its text element; every row from c on if the note's Library row is not
titled by its day.
