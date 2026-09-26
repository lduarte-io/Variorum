# 18l — NAVIGATION FEEL (the post-13u health rounds' KICKOFF 2, opened 2026-09-26)

**STATUS: OPEN — kickoff sitting in progress (the author attending).** Orchestrator: Fable
(`/architect-phase 18l`, her kickoff message below). The ratified charter is
`notes/plans/post-13u-health-rounds.md` KICKOFF 2 (author-ratified 2026-09-22; U0/U0b/U-VIS added
2026-09-25 from her evening reports, commit `5d97d1d6`) — read it IN FULL before anything here;
this file is the running record and adds ONE new unit (U0c, her 2026-09-26 kickoff report) plus the
riders named in THE LEDGER. This file must stay readable in full (the reading rule).

**The round in one sentence:** finish the landing subsystem's perimeter so the author can *"click
around everywhere with no issues"* — her regression family first (U0 · U0b · U0c), the visual
harness she asked for (U-VIS), then the ratified perimeter work (U1 · U2 · U3 · U4).

---

## HER KICKOFF MESSAGE (2026-09-26, verbatim where it rules)

Cast: *"You can use opus 5.5 as the implementer with the Fable cold reviews that the these editor
seam sessions always have."* Context: *"I'm concerned by some of the changes, not sure if they're
because of the update in macOS or if it's just due to other changes to the editor."* (Both axes are
live: 18k C6 proved one REAL macOS-27 regression — the jump primitive landing a line off — and
fixed two more pre-existing reading-position cases at C6b. The U0 sweep treats macOS-27 deltas and
recent editor fixes as co-equal suspects.)

**THE NEW ISSUE (U0c), her words verbatim:** *"One issue that hasn't been mentioned yet that will
be yours to fix as well: When opening the note, sometimes you're randomly autonavigated to the
middle of the note, sometimes the end, but opening a note should just show you the START of a note.
With the behavior where it goes to the bottom, it's auto navigating to the bottom of the note and
only leaving a single line of text on the screen. I'm not sure why that is, and it's ignoring where
I previously was in the note to do so. Other notes are opening in the middle - not really clear
why."*

Her three earlier reports (2026-09-25, re-pasted by her at this kickoff and confirmed identical)
are already recorded verbatim in the charter's U0/U0b/U-VIS sections and in KnownIssues rows 86/87;
her captures are committed in `notes/plans/18l-inputs/` (all three verified readable at this
kickoff: the clipped "tagged" descenders; Write block 4/4 with ~40 pt of top air; Write block 3/3
one backspace later with the air collapsed).

---

## BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied verbatim per the architect-phase skill; the application notes in `.claude/skills/architect-phase/SKILL.md` bind with them)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

---

## CAST & DISCIPLINE

- **Fable orchestrates** (this session; writes no feature code beyond adjudication/record acts) ·
  **`opus-implementer` per unit**, one at a time, strictly sequential, briefed ONLY by this file's
  named sections + the charter's · **cold review per R-cor-14 with her kickoff ratification:**
  Fable (`fable-reviewer`) on every unit whose diff touches the editor seam
  (`EditorTextView` / the `EditorViewModel` storage seam / `PaneSurface` / `BlockRangeIndex` /
  `PaneTextAuthority`), landing/reading-position capture code, or U3 — expected: U0 · U0b · U0c ·
  U2 · U3 (and U-VIS if its harness touches the seam); `opus-reviewer` acceptable for U1/U4 unless
  their diffs drift onto the seam. Zero `Sync/` by design — if any fix wants it, stop and report.
- **Standing rules, restated because they bind every unit:** pin before fix — the red-on-old pin
  binds and is verified by BEHAVIORAL REVERT; a pin green on both sides dismisses the finding as
  hollow (recorded, not fixed). No fix without a self-traced concrete mechanism. Commit per piece,
  LIVE STATUS in this file from each unit's first commit, push after every commit, NO trailers.
  Synchronous foreground waits only (poll the log; never end a turn awaiting a background run).
  Tests at the END against the baselines below. PROVISIONAL-and-continue for non-gating ambiguity
  (log to `notes/QUESTIONS.md`); stop-and-report for gating ambiguity and every author-only call.
  One unit per implementer session. The round closes on USE-shaped evidence — the orchestrator's
  hands-on walk per unit; the install refresh follows the walk at a zero-instance window
  (A1 safety copy into `Backups/safety-copies/` first).
- **`notes/SessionResiliencyProtocol.md` binds every session** — checkpoint per piece, records
  before final verification with PENDING marks, no subagents from implementers.

## BASELINES (18k's finals, 2026-09-25/26 — read, never re-run at start)

Core **1723/180 ALL PASSED** · iOS **BUILD SUCCEEDED** · mobile **643/109 with exactly the 4
known** · full Mac **3168/522** (the only reds: three pointer-injection suites that fail when
someone is using the machine during the run — KnownIssues row 89; green 3/3 idle). Install:
`/Applications/Variorum.app` refreshed 2026-09-26 05:09 UTC, Release from `11e7614f`, binary
`79c7688b…`. **Her 2026-09-25 reports were made on the PRE-18k install (13y's `9e15f8bf…`), so
U0/U0b predate 18k; her U0c report's build is a kickoff-sitting question** (18k C6/C6b changed
`JumpPrimitive` and `topVisibleOffset()` — exactly the reading-position machinery — so whether U0c
reproduces on `79c7688b…` bounds the bisect window).

## THE UNIT ROSTER (order of execution; U0-family first, per the charter and her word)

The charter (`post-13u-health-rounds.md` KICKOFF 2) carries the full unit text for U0 · U0b ·
U-VIS · U1 · U2 · U3 · U4 — it is not duplicated here. This file adds:

- **U0c — NOTE-OPEN LANDING (NEW, her 2026-09-26 kickoff report above).** Opening a note sometimes
  lands the viewport mid-note or at the end (the end case: one line of text at the top and blank
  below — Write's typewriter-room signature over a caret-anchored landing at the note's tail);
  she expects the START, and it is *"ignoring where I previously was."*
  **Unit shape:** REPRODUCE first (dev store; also try her real-store repro conditions — note
  opened from Library/shelf/Open strip, Write and Takes both); establish WHICH machinery lands the
  opening viewport (candidates, to trace not assume: the every-door-into-Write-lands-at-the-caret
  rule over `CurrentBlockMemory` (`currentBlock.<id>` = blockID|variantID|utf16Offset — a
  remembered caret at the tail + typewriter room IS "one line on screen"); Write's session scroll
  anchor (17o batch b RAISE-M1) and its `topVisibleOffset()` capture (changed at 18k C6b); the
  Takes entry-landing/memory pair (R-Q20/R-Q21 — byte-preserved, author-ruled); the row-56
  fact-staleness asymmetry (a stale `FocusedBlock` writing another block's offset); a leaving
  savepoint/close path stamping the memory wrong). **The PRODUCT RULE is the kickoff sitting's
  question Q1 — build to her answer, recorded below in THE SITTING RECORD.** Pin red-on-old; part
  of U0's regression sweep; editor seam → Fable review. Runs with/inside the U0 family.
- **U3 rider — the macOS-27 `layoutViewport()` clip-displacement examination of `PaneSurface`'s
  render restore.** TEXTKIT2_NOTES §3 (18k's macOS-27 findings) records: *"`PaneSurface`'s render
  restore is the other `layoutViewport()` caller and was NOT examined (18l's)."* U3's unit (or the
  U0 sweep, whichever touches it first) examines that caller under the 27 finding and records
  fixed / provably-safe with the mechanism stated.
- **Adjacent, MAY-take (not owed):** KnownIssues row 85 — the ⌘↓ editing-ring drawn too high
  (O-2), owner 12, *"18l may take it if its landing work touches the ring's refresh."* Decide at
  the unit that touches the landing-settle/overlay refresh; record either way.

**Sizing note (the guidance's raise-it rule):** with U0c added, the round holds a three-report
regression family + a new harness + two phase-sized units (U1, U2) + U3/U4. This is AT/OVER the
two-phase-sized-units line — flagged to the author at the kickoff sitting (Q3); her ruling below.

## ENVIRONMENT TRAPS (carried into every unit brief VERBATIM)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — NEVER quit or
  kill one; no Release builds or `/Applications` refreshes while one lives. Xcode Run = Debug =
  the fenced dev store (`io.lduarte.Variorum.debug`).
- **An old build must NEVER open the dev store** — bisect by harness in a scratch worktree
  (in-memory store), never by running an old build against a live store (the 18k C2 precedent).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test`
  with SUITE-LEVEL `-only-testing` only; confirm the "Test run with N tests" line (Swift Testing
  counts SKIPPED tests in N — read the `skipped:` lines). `build-for-testing` compiles without the
  runner. zsh: `pipestatus`. NEVER add a custom build configuration (any configuration not named
  exactly "Debug" builds the SPM packages Release and silently strips VariorumCore's DEBUG
  oracles).
- Suites running beside a live session flash the test host's windows; the three pointer-injection
  suites (row 89) red if anyone uses the machine — a full run that must be trusted runs with
  nobody at it. Prefer zero-instance windows for timing-sensitive measurements.
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only. Accessibility + Screen
  Recording are granted to Ghostty (since 18k — live, no restart needed). Walker facts from the
  13u4 F1/F2/F3 records bind: a single `cliclick` click is sometimes swallowed by activation —
  click twice on an idempotent row; the landing signpost reads back via
  `/usr/bin/log show --predicate 'eventMessage CONTAINS "landing surface"'` filtered on `end=`;
  `walk-scroll` positive line count = DOWN. Screenshots into gitignored dirs
  (`notes/plans/18l-screens/…`).
- Backups: WAL-safe, UTC names, ALWAYS before touching the real store; into the SUBFOLDER
  `Backups/safety-copies/` (R-18k-8), never loose in `Backups/`. Drives need unlocked +
  author-free + own `caffeinate -d`.
- Never `git checkout` over uncommitted work; push after every commit; never rewrite pushed
  history. Staging is pathspec-limited (`git add <files>`, never `-A`).

## THE LEDGER (every row owned; dispositions land here)

| # | Item | Unit | Status |
|---|---|---|---|
| 1 | The Index click lands the caret on the EMPTY paragraph (deterministic — *"a refusal of clicking into the text"*) — KnownIssues row 86 | U0(1) | open |
| 2 | The book view clips the last line's descenders with a note expanded (her capture) | U0(2) | open |
| 3 | The editor-regression SWEEP over 13u2…13y/18k (her ask: *"investigate editor regressions that must've happened during recent fixes"*) — every finding reproduced, traced, pinned, fixed or owned | U0(3) | open |
| 4 | WRITE: removing a newline collapses the top padding (block 4/4 → 3/3 captures) — KnownIssues row 87 | U0b | open |
| 5 | NOTE-OPEN lands middle/end instead of the start, ignoring where she was (her 2026-09-26 report) — product rule = sitting Q1 | U0c | open |
| 6 | The opt-in VISUAL REGRESSION HARNESS (env-gated; real window; geometry assertions — first-visible-line y, caret line, glyph box inside the surface, click lands on the clicked line; seeded with U0/U0b/U0c reproductions) | U-VIS | open |
| 7 | Note Read adopts the F3 shape (`LandingPolicy.readNote`, block manifest, aim/hold/correct/watchdog in BOTH faces; resting anchors KEPT — page 0.08, edit `.center`) | U1 | open |
| 8 | Takes' landing half adopts the authority (aim kind grows: top · minimal-reveal · viewport-fraction); the restore half BYTE-PRESERVED (R-Q20/R-Q21); ~15 gesture-end pins + projection arm ride UNMODIFIED (the 3C proof) | U2 | open |
| 9 | PanePublisher frame-synchronous / state-deferred (her ratified shape; gate = walk the boards under load, REVERT on any felt regression; measure the ~1,989-warning count both ways — C3 says they are ALL `PaneSurface`'s) | U3 | open |
| 10 | The macOS-27 `layoutViewport()` clip-displacement examination of `PaneSurface`'s render restore (TEXTKIT2_NOTES §3's hand-forward) | U3 rider | open |
| 11 | The one-liners: Outline `.onDisappear { landing.end() }`; `LandingTarget.utf16Offset` wired-or-deleted (lean: delete + comment naming the `FocusedBlock` road; PROVISIONAL, QUESTIONS row); `FlowStoryRow` reads `BookHeightManifest.resolve` (D1) unless 13i took it — check first | U4 | open |
| 12 | MAY-take: KnownIssues row 85 (the ⌘↓ ring drawn too high, O-2) — decide at the touching unit, record either way | rider | open |

## THE SITTING RECORD (kickoff, 2026-09-26 — her rulings land here verbatim-faithful)

- **CAST ratified in her kickoff message** (quoted above): Opus 5.5 implements, Fable cold-reviews
  the editor-seam diffs. Standing default confirmed.
- **Q1 (U0c's product rule), Q2 (U0c's build/surface facts), Q3 (sizing/split)** — asked at the
  sitting; answers PENDING → recorded here when given.

## LIVE STATUS (orchestrator; flipped per piece)

| Piece | Status |
|---|---|
| Preflight (canon + charter + KnownIssues + QUESTIONS + resiliency + TK2 notes + health review §1 + sizing guidance + 18k handoff + captures + code headers + F3 record) | DONE (this session, 2026-09-26) |
| This plan file + KnownIssues row for U0c | DONE (this commit) |
| Kickoff sitting (Q1–Q3) | IN PROGRESS |
| U0 (incl. U0c per Q1/Q2) → U0b → U-VIS → U1 → U2 → U3 → U4 | NOT-STARTED |
