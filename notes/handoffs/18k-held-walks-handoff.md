# 18k (+18o) — THE HELD WALKS: a handoff for a session with Accessibility + Screen Recording

**Why this exists (2026-09-25):** 18k ran overnight in Ghostty, which held NEITHER Accessibility NOR
Screen Recording, so no session could drive or capture the app. Every unit closed on in-app scripted
+ harness evidence, and each unit's hands-on GUI walk was HELD with its steps written into the run
record. The author granted both to Ghostty mid-run: Screen Recording took effect live, while
Accessibility needs Ghostty restarted, and restarting would have killed the running orchestrator. **This
file is the paste-ready kickoff for the session that runs those walks afterwards**, in Terminal.app or
a restarted Ghostty.

**UPDATE (2026-09-25, same night): BOTH grants took effect without a restart** (re-checked by the orchestrator: `AX: true SCREEN: true`). So the walks run INSIDE the 18k orchestration, after C5 closes and before the ladder, as a walk session spawned by the orchestrator with this kickoff; the orchestrator spot-checks the captures. The original timing note below stands only if that does not happen.

**When to run it:** after the 18k orchestrator session has ENDED (or at least after 18k's closeout
commit — check `notes/plans/phase-18k-runtime-hygiene.md`'s STATUS line and LIVE STATUS). If 18o has
also closed, fold 18o's held walks in the same way (its record: `notes/plans/phase-18o-correctness-singles.md`).
Never run it while an orchestrator or implementer session is live on the tree (the two-writers rule).

---

## PASTE-READY KICKOFF (paste this into the fresh session)

> You are the WALK session for Variorum's 18k run (and 18o if it has closed). Repo:
> `<home>/dev/variorum`. Read `CLAUDE.md`, then this file
> (`notes/handoffs/18k-held-walks-handoff.md`) whole, then `Tools/WalkKit/README.md` WHOLE, then in
> `notes/plans/phase-18k-runtime-hygiene.md`: the ENVIRONMENT TRAPS section, HER MORNING BUNDLE, and
> every section titled `THE GUI WALK — HELD for the author` or `walk steps` inside the UNIT C1…C6 and
> C5 RECORDS (grep `HELD`). Do the same for 18o's record if it exists and has closed.
>
> **Step 0 — prove the grants first.** Compile and run this (it prints both):
> ```swift
> import ApplicationServices; import CoreGraphics
> print("AX:", AXIsProcessTrusted(), "SCREEN:", CGPreflightScreenCaptureAccess())
> ```
> Both must be `true`. If either is false, STOP and tell the author which, and walk nothing.
>
> **Step 1 — the fences.** Walk ONLY the DEV-STORE Debug build (`io.lduarte.Variorum.debug`), built
> from the current `main` into its own DerivedData. NEVER open, quit, kill or touch
> `/Applications/Variorum.app` or her real store; check instances with
> `pgrep -fl 'Variorum.app/Contents/MacOS'` and discriminate by PATH. A directly launched Debug binary
> needs `OS_ACTIVITY_DT_MODE=YES` for SwiftUI log lines. Captures go to the gitignored
> `notes/plans/18k-screens/walks/`. Walk in BOTH voices (Terminal, Study) and, where a step says so,
> both appearances. The dev store's custody posture may be Touch-ID-gated: if a step needs a gate no
> session can pass, record it honestly and move on.
>
> **Step 2 — walk each unit's held steps, in the record's order** (C1 registry · C2 inline editor ·
> C3 index/outline/canvas/windows · C6 the re-font reading position on *The Adventure of the Copper
> Beeches* · C5 Canvas ⌘K Block History, ⌥⌘Z double-press, Back Up Now vs the insurance toggle; then
> 18o's). For each step: the capture file name, what you saw, PASS / FINDING. A FINDING is recorded
> verbatim with its capture and NOT fixed in this session.
>
> **Step 3 — record, commit, push.** Append `## THE HELD WALKS — RESULTS (<date>)` to the END of
> `notes/plans/phase-18k-runtime-hygiene.md` (and 18o's section to its own record): one table row per
> step, the grants you proved at Step 0, the build commit you walked. Flip the MORNING BUNDLE's
> "held walks" line to DONE (or to the findings list). Commit pathspec-limited, **no commit trailers of
> any kind**, push. Any FINDING goes to the author as a short list in your final message, and gets a
> KnownIssues row with an owner (a 17 letter at her word, or 12) — never a fix in this session.
>
> Synchronous foreground waits only. Never spawn subagents. Stop and ask the author for anything
> product-flavoured.

---

## What the walks are checking (one line each, so she can read along)

- **C1:** opening and closing many notes, then ⌘Q, feels instant, and nothing you typed is lost.
- **C2:** in a book's Outline, a long story's inline editor opens at full height with no jump; typing and resizing leave no clipped last line (a gap of ~85 pt after a narrow → restore is the known residual).
- **C3:** nothing visible changed; the walk confirms the book Index, Outline, Canvas and windows behave as before.
- **C6:** on *Copper Beeches*, changing inline comments or the paragraph gap keeps the same line at the top of the page (mid-note and at the end, both voices).
- **C5:** Canvas selection → ⌘K "Block History" opens on the selected block; ⌥⌘Z pressed twice fast never skips its confirm; Back Up Now while flipping the insurance toggle makes ONE backup and no false "failed".
