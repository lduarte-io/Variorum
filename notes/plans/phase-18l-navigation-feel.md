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
`/Applications/Variorum.app` = **`c09f81be…`** (17u's glyph-rain refresh from `6efd9cbc`,
2026-09-26 — it superseded 18k's `79c7688b…` of 05:09 UTC the same morning; 17u touched the lobby
only). **Her 2026-09-25 reports were made on the PRE-18k install (13y's `9e15f8bf…`), so
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
- **NO GUI DRIVING WHILE THE AUTHOR IS AT THE MACHINE — hardened 2026-09-26 after a live incident
  (18l U0, ~01:37 local):** a double `cliclick` meant for the dev-store window fired while she was
  actively using the Mac; the dev window had gone off the current Space, her `/Applications`
  instance was frontmost and covered the point, so the click may have landed in HER app
  (window-relative ~(263,171) — the note header/mode-tab strip; worst case a mode/tab switch or a
  selection; nothing destructive; her app never quit/killed; reported to her the same minute).
  THE RULE, binding every walk step from now on: (1) check HID idle BEFORE EVERY GUI step, not
  once per walk — recent input (< a few seconds) means STOP and wait or go harness-only; (2)
  verify the TARGET window immediately before each click — the dev pid is frontmost AND its
  window is on the current Space at the expected frame (a screen point alone is never a target);
  (3) any doubt → harness-only until the machine is genuinely author-free (the drives rule:
  unlocked + author-free + own `caffeinate -d`). **Her go-ahead, 2026-09-26 (after the incident,
  verbatim): "i've now quit my app so the implementer can do its own GUI driving and i won't be
  touching my computer again for quite a while. so go ahead freely" — zero real-store instances
  verified by pgrep at that moment; GUI driving resumed with the per-step checks still binding.**
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

## THE SITTING RECORD (kickoff, 2026-09-26 — her rulings, verbatim-faithful)

- **CAST ratified in her kickoff message** (quoted above): Opus 5.5 implements, Fable cold-reviews
  the editor-seam diffs. Standing default confirmed.
- **R-18l-1 (Q1 — U0c's product rule): START ON FIRST OPEN, RESTORE IN-SESSION.** Her selection of
  the offered option: *"First open of a note each session shows the start; re-opening a note you
  already visited this session restores where you were."* This SUPERSEDES the
  every-door-into-Write-lands-at-the-caret rule (17o) for the NOTE-OPEN act only, and bounds the
  RAISE-M1 session anchor to in-session re-opens. In-app deep links (a fan panel's "go there", a
  Read sentence click, a search hit) still land at their targets — stated in the question she
  answered. The remembered caret itself survives (editing state), only the OPENING viewport
  changes. Takes' own R-Q20/R-Q21 pair: the "restore in-session" half IS that pair's memory; the
  first-open-per-session half now outranks it at the session's first open of a note — flag any
  pin this collides with to the orchestrator rather than editing it silently.
- **R-18l-2 (Q2 — U0c's facts): seen AFTER this morning's update too; multiple modes.** Her words,
  verbatim: *"it was in multiple modes, and different notes had different behaviors. notes with a
  newline at the end tended to jump to the end, the sherlock holmes note went to the middle (maybe
  that was the saved carat behavaior, but the note jumping to the end of the note did that even
  when i hadn't clicked anywhere in particular)"*. Read: (1) the END-jump correlates with a
  TRAILING NEWLINE / empty tail block and does NOT require a remembered caret there — so a
  landing target is being DERIVED from the tail (an empty last block as "current block", a stamp
  written by a non-click path, or the tail's crystallization state), which is the U0c trace's
  first suspect; (2) the Sherlock MIDDLE case is plausibly the ruled saved-caret restore doing its
  job — under R-18l-1 that becomes correct only for in-session re-opens; (3) 18k C6/C6b's changes
  (`JumpPrimitive`, `topVisibleOffset()`) are INSIDE the suspect window (still reproduces on
  `c09f81be…`), though the behavior may equally predate them — bisect, don't assume.
- **R-18l-3 (Q3 — sizing): RUN ALL, SPLIT IF HEAVY.** Her selection of the recommended option:
  strictly sequential U0 family → U-VIS → U1 → U2 → U3 → U4; if the round runs heavy after U1, the
  remainder closes as a follow-on 18l-b under a fresh orchestrator at a clean seam — declared now,
  never a silent split.
- **Her follow-up at the sitting (2026-09-26, verbatim — the round's bar):** *"there was supposed
  to be a new plan made as well for a style of testing to deal with the different editor
  regressions and ensuring that clicking around and editing doesn't lead to jumps that are not
  supposed to be created - have you located that note? … I know that this phase came out of a
  session examining the editor core for high levels of commit and churn and I think it's just a
  hard problem we're getting closer to having solved but I do want it to be handled well and
  thoroughly - the inability to click on text to edit it in index mode did alarm me."* The
  testing-style plan IS U-VIS (the charter's unit, her 2026-09-25 verbatim ask; ledger row 6) —
  located, confirmed to her at the sitting; its DESIGN is this round's to propose (a design note
  lands in this file before U-VIS builds, per the charter's "its design is 18l's to propose").
  Her "handled well and thoroughly" bar and the Index-click alarm are the round's tone: U0 runs
  first, the sweep reports every regression found (never only the reported ones), and U-VIS seeds
  each reproduction as a standing tripwire.

## U0 BRIEF (session 1 — the Index click refusal + the clipped descenders + the regression sweep; written by the orchestrator 2026-09-26)

You are the `opus-implementer` for **18l UNIT U0**. One acceptance unit; U0b and U0c are LATER
sessions — if your sweep finds their mechanisms, RECORD the findings in your record for those
sessions and do not build their fixes.

**Read first, in this order (reading is never delegated):**
(1) `notes/plans/post-13u-health-rounds.md` KICKOFF 2, its **U0 section IN FULL** — your unit's
charter, her two verbatim reports, and the three things U0 carries. (2) THIS file whole (it is
short): HER KICKOFF MESSAGE, BINDING PRINCIPLES, CAST & DISCIPLINE, BASELINES, ENVIRONMENT TRAPS
(they bind you verbatim), THE LEDGER rows 1–3, THE SITTING RECORD (R-18l-2's facts touch your
sweep). (3) `notes/KnownIssuesAndTechDebt.md` rows: the Index-click row (her report, owner 18l),
the Write-padding row, the note-open row (U0c — context only), row 85 (the O-2 ring — a MAY-take),
row 89 (the pointer-injection idle rule). (4) **`notes/TEXTKIT2_NOTES.md` IN FULL** — mandatory
for editor-seam work; §3's macOS-27 findings are your era's facts (the `layoutViewport()` clip
displacement; the baseline-decides rule #147; the fragment-frame/trailing-spacing fact; the
first-full-measure-differs fact — the last is the descender clip's named suspect). (5) The 18k
records for the era you are sweeping: `notes/plans/phase-18k-runtime-hygiene.md` UNIT C2 (the
inline editor's unsettled measure — the ~85-pt-TALL residual is KnownIssues-owned; your descender
clip may be the SHORT direction of the same class), UNIT C6 + C6b (the jump primitive fix, the
`topVisibleOffset()` reading-line rule, the walk protocol). (6) The captures:
`notes/plans/18l-inputs/` (all three). (7) The code, read end to end before touching it:
`BookIndexView.swift` (the pane, the read-tier rows, F1/F3's landing adoption),
`Surface/PaneSurface.swift` + `InlineEditorSurface` (the inline editor the book's editing tier
mounts; the read-tier → live-editor swap), the click → caret road (where a read-tier click
converts its point and hands the caret to the live editor — trace it yourself; the 13c 1A
container-inset class that `ScrollAnchorTests` guards is the FIRST suspect, per the charter),
`Surface/LandingAuthority.swift` (context; your unit does not tune policies).

**Your three items (the charter's numbering):**
1. **The click REFUSES the text** — deterministic (her words: *"it's a refusal of clicking into
   the text"*, never a near-miss). REPRODUCE first on the dev-store Debug build (Sherlock ▸ Index ▸
   click a line; walker facts in ENVIRONMENT TRAPS). Then FIND WHEN it regressed — bisect by
   HARNESS in a scratch worktree (in-memory store; an old build must never open the dev store)
   over the 13u2…13y/18k commits that touched the book surfaces, the inline editor, `PaneSurface`,
   the read-tier → live swap and landing. Trace the mechanism yourself; fix with a red-on-old pin
   verified by behavioral revert; walk it (both voices; lines at the top, middle and bottom of a
   note; the first and last line of a block; a line directly above/below an empty separator
   paragraph — Sherlock's blank-between-blocks shape is the trigger fixture).
2. **The clipped descenders** (her capture) — the book view with a note expanded cuts the last
   line's descenders. Check BOTH sides of 18k C2's height-write deferral (her build was pre-C2);
   the named suspect is TK2's first-full-measure-differs fact (a frame sized from an unsettled
   SHORT measure clips exactly like this; C2 measured the TALL direction). Same discipline:
   reproduce → trace → pin red-on-old → fix → walk (both voices, a short note and a long one, the
   last line with and without descenders).
3. **The regression SWEEP** (her ask, verbatim in the charter): identify what ELSE regressed in
   the 13u2…13y/18k window on the book surfaces, the inline editor, `PaneSurface`, the read-tier →
   live swap and landing — macOS-27 deltas and recent fixes are CO-EQUAL suspects (her kickoff
   words + 18k C6's precedent: one of five deltas was a REAL 27 regression). Each finding:
   reproduced, traced, pinned red-on-old, FIXED (if in your unit's scope) or OWNED (a ledger row
   with a named owner — U0b/U0c findings go to their sessions). The sweep's deliverable is a
   table: finding × mechanism × **ATTRIBUTION** × disposition. **The ATTRIBUTION column is
   REQUIRED per finding** (her sitting follow-up, 2026-09-26: *"it is unclear to me which of these
   bugs come from the upgrade to mac os 27 - that could definitely be a significant part of it"*)
   and takes exactly one of: **macOS-27** (the harness bisect reproduces it on EVERY tree in the
   window including the oldest, and the machine's 26.x era never showed it — the OS is the moving
   part; 18k's clean attribution point stands: the machine moved 26.x → 27.0 with the tree
   unchanged since RUN B's all-green finals) · **our-commit(hash)** (the bisect flips at a named
   commit) · **pre-existing** (reproduces on trees older than the window) · **undetermined(why)**
   (stated honestly with what blocked the bisect). An OS-attributed finding still gets FIXED the
   same way (we own the defensive workaround — C6's `JumpPrimitive` re-assert is the form); the
   attribution changes the fix's shape and what TEXTKIT2_NOTES §3 records for the 27.1 re-verify,
   never whether it is fixed.

**Discipline (the resiliency protocol, restated — it binds you):** commit per coherent piece,
push after EVERY commit, NO trailers; append a `## U0 RECORD` section to THIS file with LIVE
STATUS from your FIRST commit (per-piece lines: DONE (hash) / IN-PROGRESS / NOT-STARTED; every
unverified claim marked PENDING); records before final verification; synchronous foreground waits
only (poll the log — never end your turn awaiting a background run); NEVER spawn subagents; tests
at the END (the touched Mac suites + `TutorialWalkTests`, suite-level `-only-testing`), never the
full suite at start. Pathspec-limited staging. PROVISIONAL-and-continue for non-gating ambiguity
(log to `notes/QUESTIONS.md`); STOP and report for gating ambiguity, any product-behavior
invention, anything wanting `Sources/VariorumCore/Sync/`, and every author-only call. Your diff is
editor-seam by definition → a FABLE cold review follows; your self-assessment closes your record.

## LIVE STATUS (orchestrator; flipped per piece)

| Piece | Status |
|---|---|
| Preflight (canon + charter + KnownIssues + QUESTIONS + resiliency + TK2 notes + health review §1 + sizing guidance + 18k handoff + captures + code headers + F3 record) | DONE (this session, 2026-09-26) |
| This plan file + KnownIssues row for U0c | DONE (`fcf97ad5`) |
| Kickoff sitting (Q1–Q3) | DONE — R-18l-1 · R-18l-2 · R-18l-3 above (this commit) |
| U0 (session 1 — brief above) | SPAWNING |
| U0b → U0c → U-VIS → U1 → U2 → U3 → U4 | NOT-STARTED (briefs written just-in-time, one ahead) |

## U0 RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line, kept current):** everything below marked NOT-STARTED / IN-PROGRESS / PENDING.
U0b and U0c are NOT this session's (findings for them are recorded, never built).

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's list, in order, in this session's own context) | DONE — this file whole; the charter's KICKOFF 2 (U0 in full + the rest for context); KnownIssues rows 85/86/87/89/90; `notes/TEXTKIT2_NOTES.md` whole; 18k UNIT C2 brief+record+adjudication, UNIT C6 brief+record+adjudication, UNIT C6b brief+record+adjudication, the held-walk C6 rows; the three captures in `notes/plans/18l-inputs/`; `BookIndexView.swift`, `BookIndexEditModel.swift`, `Surface/PaneSurface.swift`, `EditorView.swift` (`InlineEditorSurface`) end to end; `Tools/WalkKit/README.md` |
| 2 | Item 1 — the Index click: REPRODUCE | **DONE — REPRODUCED BY HARNESS** (GUI paused, the incident below): `IndexClickCaretTests` (real clicks through `NSApp.sendEvent`, the canvas rig's window) on her note's shape (every block but the last ends in `\n`) — the book Index parks EVERY click at the block's END (366 of 366: the EMPTY line under the text, whichever line was clicked; the last block's END = its last line); the note's Read ▸ edit parks every click at the block's START (line 0). 9 issues, `DerivedData/18l-u0-pin1-prefix2.log`. The charter's first suspect (a vertically offset hit-test / the 13c 1A inset class) is RULED OUT by measurement: a y-scan of clicks across the block seam switches block 1 → none (the 8-pt spacing) → block 2 exactly at the frames' edges (`18l-u0-probe2.log`) |
| 3 | Item 1 — trace + bisect by harness | **DONE — TRACED; ATTRIBUTION: pre-existing** (details in ITEM 1 below). The road: the read tier is SwiftUI `Text` + a bare `.onTapGesture` (knows the block, never the point) → `makeLive` → a freshly mounted `PaneSurfaceView` whose `caretOnGoingLive` is `.leave` (book Index) / the note's entry rule `.start` (Read ▸ edit) — so the caret goes where `string =` left it (the END: the empty line under a trailing `\n`) or to line 0. Line history (`git log -L`): the tap handler is `c768c08e` (2026-09-01, the Index edits in place), the `.leave`/`.start` landing branch `a0aade08`/`3ded9683`/`41a75000` (17o batch b, 2026-09-07) — BOTH before the 13u2…18k window; inside the window `blockView` changed only at `7d44eda6` (13u2 B, tier paddings) and `9fe6ae5d` (18k C4, oracle owners), neither on the road. A whole-old-tree harness run is NOT possible here: every Mac test run launches the tree's own app as the test host, which opens the DEV STORE at launch (18k C7's trap) — an old build must never open it — so the bisect is the line history plus the red pin on HEAD (C6b's constraint, stated) |
| 4 | Item 1 — red-on-old pin, fix, behavioural revert | **DONE** — pin RED on the pre-fix tree (`51824a08`, 9 issues); core support `83f6f317`; THE FIX `7553dd93` (`Surface/ReadTierClickPlace.swift` + `ReadTierClickTarget` on both read tiers; the book Index hands the pane `.offset`, landings keep `.leave`; Read ▸ edit lets the click outrank the entry rule). Pins GREEN both voices (`18l-u0-pin3-fixed.log`). **R-U0-1 RED — 26 issues** (`18l-u0-R1.log`: both hosts `clickOffset: nil` → the book Index at END, the empty line in both voices, 339–345 chars from the pointer; Read ▸ edit at START, line 0, 21–28 chars off on the first line) → restored from `7553dd93` (`git status` clean) → GREEN (`18l-u0-R1-restored.log`). Walk PENDING (row 7) |
| 5 | Item 2 — the clipped descenders: reproduce, trace, pin, fix, revert | NOT-STARTED |
| 6 | Item 3 — the regression sweep (table) | NOT-STARTED |
| 7 | Walk (both voices) + captures | NOT-STARTED |
| 8 | Closing runs (touched suites + TutorialWalkTests) | NOT-STARTED |
| 9 | Self-assessment | NOT-STARTED |

- Deaths / resumes: none.
- **INCIDENT (machinery honesty, ~01:37 local):** a walk double-click (`cliclick c:318,226`, meant for the dev window's `index` tab) fired while the author was at the machine; her `/Applications` window covered that point and my dev window had left the current Space, so the click MAY have landed in her real-store window (worst case a mode/tab switch). Reported to the orchestrator at once; she was told. GUI driving stopped; harness-only until the machine is author-free; the per-step rule is ENVIRONMENT TRAPS' hardened entry (`615b833a`).
