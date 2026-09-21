# 13u4 LADDER — ROUND 2 (fable-reviewer, cold, fresh session, 2026-09-21)

**Scope (the ladder's own rule):** re-review of the ROUND-1 FIXES and what they touched — a real
pass, not a rubber stamp. **Diff under re-review:** `bb710840..19e54555` (four commits: the R1-1
records move `608182cc` · the R1-4 one-liner `b3dd6c3d` · the R1-2 hit-widening `1d20ce25` · the
round record's flip `19e54555`). **Anchor:** `notes/plans/13u4-ladder-round1.md` — its findings
R1-1…R1-4 and the fix-pass dispositions table at its end. Prompt: `notes/REVIEW_PROMPT.md`
verbatim; the standing context read in this session's own context (CLAUDE.md + the four canonical
docs are session-loaded; the round-1 record, the phase plan's E2/E3 record regions, and both fix
sites with their surrounding code read directly).

**What was verified, mechanically, in this session (not taken from the record):**

- **R1-1 (the records move) is a PURE MOVE, byte-verbatim:** the commit's 72 deleted lines were
  extracted and diffed against its 72 inserted lines — **identical, in order** (`diff` exit 0),
  so not one word changed in flight. The heading walk of `phase-13u4-restyle.md` confirms the
  landing: the UNIT E2 record region (720–913) now runs LIVE STATUS → VERDICT → MECHANISM →
  CLASS SWEEP → **one** SEAM FILES list (824, saying NONE) → WALK → JUDGMENT CALLS → CLOSING
  RUNS → fresh-session, with no build section and nothing merge-join-flavored left in it — the
  "IT CHANGED NO PRODUCT CODE AT ALL" first line now reads coherent top to bottom. The UNIT E3
  record region (974–1199) carries THE BUILD (1085) · SEAM FILES (1112) · JUDGMENT CALLS (1130)
  where every other unit keeps its own, and the placement claim holds: THE BUILD's item 5
  ("the differential road, **described above**") points at the walk section's differential-seam
  paragraph (1077–1083) directly above it — after LIVE STATUS the reference would have dangled.
  One immaterial prose discrepancy noted below (71 vs 72), not a finding.
- **R1-4 (the chrome constant reads the model):** `BookIndexPaneHeightModel.Metrics` is a struct
  with every property defaulted (`BookIndexPaneHeights.swift:57–84`), so `Metrics()` is the
  ordinary nonisolated default init and `noteChrome` defaults to **60** — the new expression is
  value-identical to the old literal (zero behavior change today; the drift seam closed for
  tomorrow). Same target, internal access, compiles by construction. The one consumer
  (`BookIndexView.swift:1225`, the reservation's `Color.clear` spacer) is unchanged.
- **R1-2 (the hit-target widening):** `.contentShape(Rectangle().inset(by: -6))` sits on the
  Button's LABEL group inside `WordTargetFace.body` — hit-testing only, so zero layout movement
  is literally true (`contentShape` never participates in layout). Neighbor-steal checked at
  every render site: the flat rows' HStacks use **spacing 10** (`CommitBar.swift:495/516`), the
  note-box footer **spacing 6** (`CommitBar.swift:409`), and the takes bar's trailing cluster
  puts the `?` door AFTER the counter — a −6 inset therefore reaches at most a neighbor's edge,
  never inside its frame, and the later-drawn sibling (`helperDoor`/`?`) wins hit-testing in its
  own bounds regardless. No steal mechanism exists; the comfort is real at the icon face.
- **The record flip (`19e54555`)** changed only the STATUS banner and appended the fix-pass
  table + closing run — the four findings' text is untouched (diff read line by line).
- **Scope fences re-verified over the fix range:** zero `Sources/VariorumCore/Sync/`, zero
  `Server/`, zero core, zero editor-seam files, zero schema — the range touches exactly
  `WordTargetFace.swift`, `BookIndexView.swift`, and the two notes files (`git log --stat`).

**Verification run (this session's own — the closing-run claim re-proven, not trusted):**
`xcodebuild test -scheme Variorum -destination platform=macOS` from `App/Variorum/` on the warm
`DerivedData/13u4walk`, `-only-testing:` for `BookIndexColumnHeightsTests` ·
`BarCountsFaceTests` · `CommitBarLayoutTests` → **17 tests in 3 suites passed** (exit 0; every
suite's tests visibly ran — no silently-ignored name). `pgrep` confirmed zero running Variorum
instances before the run; `/Applications/Variorum.app` untouched. No full suite, per the
standing rule.

---

## FINDINGS

**NONE — 0 BLOCKER · 0 MAJOR · 0 MINOR · 0 NIT.** No new finding at any severity; round 3 is
NOT triggered (the ladder's trigger is a NEW BLOCKER/MAJOR out of round 2 — there is none).

One observation recorded for honesty, deliberately NOT a finding: the round-1 fix-pass table's
R1-1 cell says "(71 lines)" while the same cell's stat and the commit say 72/72 — both are
defensible from their own angles (the finding named lines 831–901, a 71-line span; the actual
move carried 72 lines including a boundary blank), the authoritative stat in the same cell is
correct, and this session verified the stronger fact (byte-identical in order). No consumer can
be misled; a records edit for one digit would be churn, not clarity.

## CLEAN BILL (what this round specifically checked and found solid)

1. **R1-1's move is pure and correctly placed** — 72 deleted lines diffed byte-identical, in
   order, against the 72 inserted; both record regions' heading walks are now canonical; the
   "described above" reference reads true only at the chosen placement, and that placement was
   chosen.
2. **R1-4 is value-identical today and drift-proof tomorrow** — `Metrics()` all-defaulted,
   `noteChrome = 60`, one consumer unchanged, the reason at the site.
3. **R1-2 moves zero layout and steals zero clicks** — spacing 10 / 6 at every render site vs
   the −6 inset; the later-drawn neighbor wins its own frame under SwiftUI's reverse hit-test
   order; the comment at the site states the un-pinnable nature honestly.
4. **The record flip is records-only** — STATUS banner + appended fix-pass table; the four
   findings' text byte-untouched.
5. **Scope fences hold over `bb710840..19e54555`** — zero `Sync/`, zero `Server/`, zero core,
   zero editor-seam files, zero schema/migrations; the range touches exactly the two chrome
   files and the two notes files.
6. **The fix pass's closing-run claim reproduces at HEAD** — this session's own 17/3 green.
7. **R1-3's carry cannot drop** — the duty is recorded in three places (KnownIssues row 51's own
   cell text, the plan's post-S2 ORCHESTRATOR NOTE at `phase-13u4-restyle.md:3463`, and the
   round-1 record's disposition table), all naming the same closeout act: mint the lettered 17
   entry and put the letter in the cell. Correctly the orchestrator's, correctly still open.

**VERDICT: the round-1 fix pass stands as landed. The ladder closes at round 2 with nothing new.
Open for the CLOSEOUT only: R1-3's lettered 17 entry (orchestrator records act).**
