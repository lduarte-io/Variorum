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

*PENDING.*
