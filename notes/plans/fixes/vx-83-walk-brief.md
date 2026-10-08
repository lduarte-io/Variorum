# VX-83 — the WALKER's errand (U-A acceptance evidence)

**Who you are:** `vx83walker` — the hands-on walker for the VX-83 run. You EXECUTE this
errand; the `searchfollowup` session (the run's orchestrator) JUDGES the evidence and owns
every decision. You exist because searchfollowup is a background session whose host
(ClaudeCode.app) holds no GUI grants; YOUR terminal world does. **Nothing beyond this
errand: no code edits, no fixes, no record edits outside §WALK EXECUTION, no tickets.**

**Required reading first:** this file WHOLE · `Tools/WalkKit/README.md` WHOLE (every
pitfall in it is binding — especially: quit YOUR instance by bundle id only, NEVER a ⌘Q
keystroke; discriminate instances by PATH; her `/Applications` instance is never touched).
Work in `<home>/dev/variorum-vx-83` (branch `vx-83-search-followup`);
`git pull --ff-only` first.

## Step 0 — grant self-check (before anything)

`swift -e 'import ApplicationServices; import CoreGraphics; print("AX:", AXIsProcessTrusted(), "SCREEN:", CGPreflightScreenCaptureAccess())'`
Both must be true. If either is false, STOP and tell the author which toggle her terminal
app needs (System Settings ▸ Privacy & Security ▸ Accessibility / Screen & System Audio
Recording) — granting is hers, never yours.

## Step 1 — the stage

SendMessage the session named `oct7coordinator`: you are "vx83walker (searchfollowup's
walker)", you need a GUI walk of the Debug app on the dev store, ~25 min, not urgent.
Claim ONLY on its explicit GO:
`Tools/stage claim --who vx83walker --reason "VX-83 U-A acceptance walk (for searchfollowup)" --minutes 30`
Release + message it when done. Never idle a turn waiting; if the GO is pending, say so
to the author and stop cleanly — she relaunches you or the coordinator's GO arrives.

## Step 2 — build + launch (dev store ONLY)

1. `pgrep -fl 'Variorum.app/Contents/MacOS'` — note every instance; the `/Applications`
   one (hers) is NEVER touched, quit, or clicked.
2. Build: `cd App/Variorum && xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' -derivedDataPath DerivedData/vx83-walk build` (Debug = the fenced dev store; NEVER any other configuration).
3. Launch: `open -n DerivedData/vx83-walk/Build/Products/Debug/Variorum.app`; find YOUR
   pid by that path. Every launch takes a dev-store backup — expected.
4. Build the capture helper: `swiftc -O -o /tmp/walk-cap Tools/WalkKit/capture-windows.swift`.
   Capture per step; READ each PNG yourself before moving on (a blank shot = a problem).

## Step 3 — the walk (capture EVERY lettered expectation; the dev store carries the
Sherlock sample library with tags `classics` and `sherlock holmes`)

- **W1 (the sheet):** click into the Library's search field, type `sherlock holmes`.
  EXPECT: the answer sheet — band with honest counts, books section, passages grouped
  under notes with both words marked. SHOT.
- **W2 (land-at-match, VX-85+86):** click a passage DEEP in a long note (the Beryl
  Coronet's "took it up and opened the bureau" line is the one from her report). EXPECT:
  Write opens; the matched line is FULLY VISIBLE with air below the find bar (never
  hidden under it); the find bar's field holds BOTH words ("Sherlock Holmes"); the match
  is selected. SHOT. Then press ⌘G. EXPECT: steps to the next occurrence. SHOT.
- **W3 (the first-line case, VX-85):** back in the Library (⌘K → Library → ⏎ if needed),
  search words that hit a note's FIRST line (her shots: "good-night mister sherlock" hits
  the outline note's first line). Click that first-line passage. EXPECT: the line sits
  BELOW the bar, readable, not flush under it. SHOT.
- **W4 (tag alone, VX-84a):** clear the field, type `#classics`. EXPECT: the books-flow
  section on top ("#classics flows here"), then the TAGGED NOTES as the Library's own
  rows; the sort door reads its live sort (e.g. "edited · newest first ▾"), the scope
  picker is live; NO "Type a word to search inside #classics." line anywhere. SHOT.
- **W5 (the offer chip, VX-84b):** clear, type `classics` (no #). EXPECT: honest text
  results only, and the band offers `tag: #classics ›`. SHOT. Press the chip. EXPECT: the
  field becomes the #classics question and W4's listing appears. SHOT.
- **W6 (spacing, VX-88 + the chips, VX-94):** search `sherlock holmes` again; find a note
  group whose passages include a multi-sentence/multi-line block (her report's uneven
  group). EXPECT: every passage line sits in one even rhythm — no pair of tight lines
  inside one row beside padded neighbours; band chips render as single lines. SHOT.

**If ANY expectation fails:** capture it, write it in §WALK EXECUTION exactly as seen,
and continue the remaining steps (never fix, never retry past one relaunch — the
README's first-launch pitfall allows ONE quit-and-relaunch of YOUR instance if the first
launch eats keystrokes).

## Step 4 — evidence lands repo-first

1. Copy the keeper shots (≤10, one per lettered expectation) to
   `notes/plans/vx83-screens/01-….png` … (committed — the 13o-screens precedent).
2. APPEND a `## §WALK EXECUTION (vx83walker, <date>)` section at the very END of
   `notes/plans/fixes/vx-83-search-followup.md`: per-step one-liners (seen/failed), the
   shots' filenames, any anomaly verbatim. Touch NOTHING else in that file.
3. Quit YOUR instance: `osascript -e 'tell application id "io.lduarte.Variorum.debug" to quit'`,
   re-check pgrep. Commit (`VX-83 walk evidence: … Part of VX-83`, NO attribution
   trailers — CLAUDE.md's rule), push.

## Step 5 — hand back

Release the stage claim; message `oct7coordinator` (done); message `searchfollowup` with:
pass/fail per lettered expectation, the record section is in, the commit hash. The
JUDGMENT is searchfollowup's — report, don't conclude.
