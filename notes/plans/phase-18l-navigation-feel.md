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
- **SYSTEM DIALOGS (added at U-VIS's incident, 2026-09-26):** before any GUI burst, check for
  foreign dialogs over the work area (the VisualWalk helper does; `guard.sh` CANNOT see them);
  never click a point a system dialog covers; never type unless OUR window is key (a consent
  prompt with keyboard focus turns a ⏎ into Allow). **A consent dialog is ANSWERED BY THE AUTHOR
  ONLY — never by a session**, whatever it blocks; if one appears, record it, work around it or
  hold, and put it at the top of her bundle. And never osascript an app that is not ours (U0b's
  accidental Finder call is what minted the stale prompt).
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
| 1 | The Index click lands the caret on the EMPTY paragraph (deterministic — *"a refusal of clicking into the text"*) — KnownIssues row 86 | U0(1) | **CLOSED 2026-09-26** — fixed (pre-existing; `IndexClickCaretTests`, R-U0-1 red 26), walked twice, ladder closed (R1 0/0/2/4-agreed-fixed + sanity PASS `2753e741`) |
| 2 | The book view clips the last line's descenders with a note expanded (her capture) | U0(2) | **CLOSED 2026-09-26** — both mechanisms fixed (the width door + the settle net), walked twice, KnownIssues row 75 closed with it; same ladder |
| 3 | The editor-regression SWEEP over 13u2…13y/18k (her ask: *"investigate editor regressions that must've happened during recent fixes"*) — every finding reproduced, traced, pinned, fixed or owned | U0(3) | **CLOSED 2026-09-26** — S1–S9 with ATTRIBUTION per finding (U0 RECORD); S3 → KnownIssues (taste call, morning bundle) · S5 → KnownIssues (12) · row 75 closed |
| 4 | WRITE: removing a newline collapses the top padding (block 4/4 → 3/3 captures) — KnownIssues row 87 | U0b | **CLOSED 2026-09-26** — fixed (`998f7d7d` ReadingAnchor; B1–B3 pre-existing, B4 our-commit(`4ae12a59`)), double-walked, ladder closed (R1 0/0/2/2 all agreed → the reviewer's four fixes `f207f97a..cd01c428` incl. the delegate refinement → sanity PASS `f81dcc67`, 110/14 blast radius) |
| 4b | B5 (U0b's find): ⏎ after a ⌘↓ landing on invalidated geometry moves the page (+109/+166 pt, both builds, differential road, UNTRACED) | U-VIS scenario + the U3 `layoutViewport()` exam (or its own slot — decided at U3) | open — KnownIssues row filed, owner 18l |
| 5 | NOTE-OPEN lands middle/end instead of the start, ignoring where she was (her 2026-09-26 report) — product rule = R-18l-1 | U0c | **CLOSED 2026-09-26** — built to R-18l-1 (+ the #150 pair, confirmed by orchestrator AND reviewer), double-walked, ladder PASS in one round (0/0/0/3 NIT `452ab9ea` — no fix pass owed; NIT-1/2 are closeout-pen doc lines, NIT-3 = the Persian-search observation is 13o's recorded deferral, row 27, designed behavior) |
| 6 | The opt-in VISUAL REGRESSION HARNESS (env-gated; real window; geometry assertions — first-visible-line y, caret line, glyph box inside the surface, click lands on the clicked line; seeded with U0/U0b/U0c reproductions) | U-VIS | **CLOSED 2026-09-26** — `Tools/VisualWalk/` (11 scenarios × 2 voices, 0 FAIL/ERROR/XPASS; can-red proven; every seeded U0-family tripwire teeth-verified on reverted scratch builds); ladder closed at two rounds (R1 0/1/8/9 all fixed incl. the guard-before-activate MAJOR in harness AND WalkKit; R2 verified + 0/0/3/8 all fixed; no round 3 earned); orchestrator ran subset + selftest by hand |
| 7 | Note Read adopts the F3 shape — SHIPPED AS THE WATCH (both faces through `LandingAuthority`, signpost/watchdog/hand-over; anchors KEPT; the placeholder half built, measured worse, rejected — JC1/#151) | U1 | **BUILT + WALKED** (impl. 72/72 settled hops=0 + orch. hands-on; pre-fix baseline honest: §1.2 did not reproduce on real prose) — Opus review pending |
| 8 | Takes' landing half adopts the authority (aim kind grows: top · minimal-reveal · viewport-fraction); the restore half BYTE-PRESERVED (R-Q20/R-Q21); ~15 gesture-end pins + projection arm ride UNMODIFIED (the 3C proof). **MAY-take (U0c's find):** a Takes pane born live reports AppKit's END before its `.start` landing, so the persisted copy holds the take's END until the note leaves (no viewport effect) — else 12 at the closeout | U2 | open |
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
- **R-18l-4 — THE OVERNIGHT MANDATE (her last message before sleep, 2026-09-26, verbatim):** *"I'm
  stepping away and going to sleep for the evening - rule everything provisionally in my absence
  and continue your progress through the night. If this phase ends before I wake, ensure there's
  a handoff for me to use to communicate with a fresh session so I don't have to wake you."*
  Applied as the skill's away-run rule: PROVISIONAL-and-continue everything short of an
  author-only hard stop; anything genuinely hers is HELD and BUNDLED into the morning checklist
  (the handoff's first section); if the round closes overnight, the author handoff
  (`notes/handoffs/phase-18l-handoff.md`) is written per the closeout ritual — self-contained for
  a fresh session. Machine setup: her app quit (zero real-store instances), a detached
  `caffeinate -dims` running (pid noted in the orchestrator's log), GUI driving authorized with
  the per-step checks binding.
- **R-18l-5 (orchestrator, PROVISIONAL under R-18l-4 — the U0 ladder's MINOR-1 escalation,
  2026-09-26): THE 13g SURFACE RULE GAINS A CARVE-OUT, option (b).** The read tiers KEEP the
  fully-formatted face AND may seed a caret, provided the click's offset travels ONLY through the
  pinned display→source translation (`MarkdownRendering.sourceOffset` + the replica-fidelity
  pin). Why this is the rule's own answer, not its repeal: F-5's rationale clause reads *"display
  ≠ stored is safe exactly where no gesture maps clicks to text offsets"* — U0 built exactly that
  mapping, pinned both ways, so the hazard the letter fenced is discharged by machinery rather
  than by hiding markers. The alternative (a) — switching the Index and Read ▸ edit tiers to the
  dimmed-marker face — is a visible look change she never asked for; her report demanded the
  caret land where she clicked ON the formatted face she has been reading for weeks. HERS TO
  OVERTURN: QUESTIONS #149 (the (a)/(b) pair, morning bundle); the 13g F-5 entry carries the
  dated pointer; the reviewer's MINOR-1 fix writes the carve-out into the MarkdownRendering
  header in the rule's own terms.
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
| Kickoff sitting (Q1–Q3) | DONE — R-18l-1 · R-18l-2 · R-18l-3 above |
| U0 (session 1) | **CLOSED 2026-09-26 (overnight)** — built · double-walked · ladder round 1 (0 BLOCKER / 0 MAJOR / 2 MINOR / 4 findings all agreed; the reviewer's four fixes `70588f2c..a941b5f8`) · sanity PASS (`2753e741`); R-18l-5 ruled en route (#149, morning bundle) |
| U0b (session 2) | **CLOSED 2026-09-26 (overnight)** — built · double-walked · ladder R1 (0/0/2/2, all agreed; reviewer fixes incl. the pin-sites-run-production-arithmetic delegate) · sanity PASS; row 87 closed, B5 filed (row 88, owner 18l), #134(a) carries the dated carve-out pointer |
| U0c (session 3) | **CLOSED 2026-09-26 (overnight)** — built · double-walked · ladder PASS one round (0/0/0/3 NIT; both #150 PROVISIONALs confirmed independently); the note-open KnownIssues row closed; NIT-1/NIT-2 ride the closeout pen (the `scrollAnchors` doc parenthetical; the `LandingOffsetTests` header edit beside the AppSpec §12 line) |
| U-VIS (session 4) | **CLOSED 2026-09-26 (overnight)** — built to the design note; ladder two rounds, no round 3 earned; the harness is a standing instrument from here on (post-macOS-update cadence per the design note's decision 6) |
| U1 (session 5) | **BUILT + WALKED** — Opus review round 1 IN FLIGHT; 18l CLOSES at this unit's ladder (her check-in ruling) |
| U2 → U3 → U4 | NOT-STARTED — the R-18l-3 SEAM JUDGMENT follows U1's close |

## U0b BRIEF (session 2 — WRITE: removing a newline collapses the top padding; written by the orchestrator 2026-09-26, spawned after U0's ladder round settles)

You are the `opus-implementer` for **18l UNIT U0b**. One acceptance unit: her report — *"when I am
in write and remove a newline, the editor's height adjusts removing the whitespace between the
*[removed for publication]*
`notes/plans/18l-inputs/2026-09-25-write-{before,after}-removing-newline.png` — block 4/4 (caret
on an empty last block, first line ~40 pt below the masthead's divider) → one backspace → block
3/3, the first line ~14 pt below it; the page's top air GONE. KnownIssues row 87.

**Read first, in this order:** (1) THIS file whole — especially HER KICKOFF MESSAGE, THE SITTING
RECORD (R-18l-1/2/4), ENVIRONMENT TRAPS (they bind verbatim, including the per-step GUI guard and
the history-bar walker fact in the U0 acceptance), CAST & DISCIPLINE, BASELINES, the **U0 RECORD
whole** (the freshest editor-seam facts: the settle net, `onWidthReflow`, the C2-pin adaptation —
your diff must not fight them) and the U0 ladder round-1 file if it exists
(`notes/plans/18l-u0-ladder-round1.md`). (2) The charter's U0b section
(`notes/plans/post-13u-health-rounds.md` KICKOFF 2). (3) `notes/TEXTKIT2_NOTES.md` in full —
mandatory (editor seam); §3's 27.0 findings and the new settle-net line are your era. (4) The 18k
C6/C6b records (`notes/plans/phase-18k-runtime-hygiene.md`) — `topVisibleOffset()`'s
baseline-decides rule and the jump primitive's re-assert are on the candidate road. (5) The code:
the Write surface's TOP INSET / first-block air (trace where the ~40 pt above the first line comes
from — `EditorTextView`'s container inset, the masthead seam, or a first-block spacing rule), the
typewriter room (the tail's page of air — its sizing may share machinery with the top), the
deletion road for an empty last block (`wholeBlockDeletion` / the seam carve / `deleteBlock`'s
`.emptyWithNothingUnshown`), and any scroll-anchor restore that runs after a structural delete
(`ScrollAnchorController` / `parkAnchorRestore` / `JumpPrimitive`).

**The unit:** REPRODUCE first (her exact shape: a short note, an empty last block, caret on it,
one backspace — dev store, both voices); TRACE the mechanism yourself (is the top air a real
INSET that changes with block count, or a scroll offset the deletion's re-render moves? — the two
have different fixes and her capture cannot distinguish them); **ATTRIBUTION per the U0 sweep's
required column** (macOS-27 / our-commit(hash) / pre-existing / undetermined(why) — her build was
13y's, pre-18k, so 18k commits cannot be the ORIGIN, but check whether 18k C6b's
`topVisibleOffset` change ALTERS the shape on today's tree); pin red-on-old, verified by
behavioral revert; fix; WALK (both voices: her repro sequence; a long note's same gesture
mid-note and at the tail; add-then-remove round trip — the first line must not move when the act
doesn't move it). Product fence: WHERE the page rests after a deletion at the tail may interact
with R-18l-1 (note-open = start) and #116(c)'s caret-visible doctrine — if your fix wants to
CHANGE a ruled resting rule rather than stop an un-asked-for jump, STOP and report (that fork is
the orchestrator's). Discipline: identical to the U0 brief's paragraph (checkpoint protocol from
the first commit; `## U0b RECORD` appended to THIS file; commit+push per piece; no subagents;
synchronous waits; tests at end; pathspec-limited staging). Your diff is editor-seam → a FABLE
cold review follows.

## U0c BRIEF (session 3 — NOTE-OPEN lands mid-note or at the end; built to R-18l-1; written by the orchestrator 2026-09-26 one-ahead — re-check against the U0b RECORD before spawning)

You are the `opus-implementer` for **18l UNIT U0c**. One acceptance unit: her kickoff report
(HER KICKOFF MESSAGE above, verbatim) — opening a note sometimes lands mid-note or at the end
(one line of text at the top, blank below); it should show the START. **The ruled product rule is
R-18l-1 (THE SITTING RECORD): START on the session's FIRST open of a note; restore
where-she-was on a RE-open within the session; in-app deep links (fan "go there", a Read sentence
click, a search hit) land at their targets unchanged; the remembered caret survives as editing
state — only the OPENING VIEWPORT changes.** R-18l-2 carries her repro facts: multiple modes;
notes with a TRAILING NEWLINE tend to jump to the END *"even when i hadn't clicked anywhere in
particular"* (so the end-jump needs no remembered caret there — a landing target is being
DERIVED from the tail; your trace's first suspect); Sherlock opened to the MIDDLE (plausibly the
ruled saved-caret restore — correct under R-18l-1 only for in-session re-opens); still
reproduces on the post-18k install.

**Read first, in this order:** (1) THIS file whole — R-18l-1/2/4/5, ENVIRONMENT TRAPS (verbatim
binding), the U0 and U0b RECORDs + both ladder files (the freshest seam facts). (2) The charter's
U0c-adjacent text (the KnownIssues note-open row is the canonical statement). (3)
`notes/TEXTKIT2_NOTES.md` in full (editor seam — mandatory). (4) The rulings your build must not
break: 17o batch b's RAISE-M1 (Write's session scroll anchor) and R-Q20/R-Q21
(`notes/plans/use-report-round-2026-09-12.md`, the R-8 section — the Takes entry-landing/memory
pair; **byte-preserved machinery: R-18l-1 adds a first-open-per-session outrank ABOVE it, never
an edit inside it — flag any pin collision to the orchestrator rather than editing a pin
silently**). (5) The code: `CurrentBlockMemory` (`currentBlock.<id>` = blockID|variantID|offset)
and every WRITER of it (a non-click writer stamping the tail is the end-jump's likeliest
mechanism — find who writes it on close/leaving/savepoint roads); `CommandRouter`'s open/landing
roads; each mode's entry landing (Write's caret-anchored entry, Takes' `TakesArticleScroll`
restore half, Read's landing); the Open strip / Library / shelf door roads into a note.

**The unit, in order:** (1) TRACE the opening-viewport decision per mode — who decides, from
what stored fact. (2) REPRODUCE both her shapes (a trailing-newline fixture note → END; a
mid-note-caret note → MIDDLE) and any others the trace predicts. (3) The END-jump is a BUG
independent of the rule change if the memory holds a tail the author never placed — ATTRIBUTION
(the four-value column, U0's evidence bars) and a red-on-old pin for that mechanism REGARDLESS
of the new rule (the wrong-stamp writer stays wrong even under R-18l-1's restore-in-session
arm). (4) BUILD R-18l-1: a per-app-run (in-memory, never persisted, never synced) first-open
set; the session's first open of a note shows the START in every mode; a re-open restores by the
standing machinery; deep links and back/forward history keep their targets (**PROVISIONAL call
you may make: ← → history counts as re-open, not first open** — log it to QUESTIONS with one
line either way). (5) Pins: the end-jump red-on-old; state-transition pins for
first-open/re-open/deep-link per mode; the R-Q20/R-Q21 and RAISE-M1 pins ride UNMODIFIED (any
that cannot is a STOP-and-flag, not an edit). (6) WALK, both voices: her exact shapes (trailing
newline; Sherlock), first-open vs re-open per door (Library, shelf, Open strip), a deep link
landing unchanged. Discipline: the U0 brief's paragraph verbatim (checkpoint from first commit;
`## U0c RECORD` in THIS file; commit+push per piece; no subagents; synchronous waits; tests at
end; pathspec-limited). Editor seam → Fable review.

## U-VIS DESIGN NOTE (the orchestrator's proposal, 2026-09-26 — owed to her in-file per her sitting follow-up; PROVISIONAL under R-18l-4: the overnight build proceeds on this design, hers to overturn at the morning bundle)

**What it is (her words bind):** an OPT-IN visual regression harness — *"tests that can run
(don't have to be part of the suite that run every time) where screenshots are taken of edits,
clicks, if the editor has moved unexpectedly between clicks, etc."*

**The design, in six decisions:**
1. **An EXTERNAL driver over the real window, not a mounted-surface test.** KnownIssues rows 35
   (whole surfaces crash/hang under the in-process click rig) and 89 (pointer-injection suites go
   red under real machine input) are exactly the classes an in-suite harness would inherit. So
   U-VIS is `Tools/VisualWalk/`: a driver script in the WalkKit mold (cliclick + osascript +
   `walk-cap`), launching its OWN dev-store Debug build, with the U0 incident's `guard.sh`
   promoted into it (per-step: her app absent · HID idle · dev pid frontmost · window on this
   Space) — the walk discipline, mechanized once.
2. **Assertions on MEASURED GEOMETRY, pictures as evidence beside them.** Pixel-diffing screenshots
   is voice/palette/AA-fragile; the app already knows its own geometry. The driver reads a small
   DEBUG oracle surface (existing oracles first — `topVisibleOffset`'s line, the caret's line, the
   last fragment's bottom, the surface frame; any NEW oracle follows 18k C4's owner-keyed shape)
   and asserts HER three rules: (a) the first visible line's y and the caret's line move ONLY when
   the act moves them; (b) the last line's glyph box lies inside the surface — no clipped
   descenders, no gap beyond the designed air; (c) a click lands the caret on the clicked line.
3. **The scripted acts, seeded from this round's reproductions** (each a standing tripwire):
   typing into a block · a newline added then removed at the tail (U0b's shape) · a click on a
   read-tier line in Index and in Read ▸ edit (U0's) · a window narrow → restore (U0's item 2) ·
   a divide and a merge · a mode switch round trip (Write → Read → Write) · a note close → reopen
   (U0c's, asserting R-18l-1 once built). Growable by adding a scenario block to one table.
4. **Opt-in gating:** the driver runs by hand or by an env-flagged wrapper test
   (`VARIORUM_VISUAL_WALK=1`, the keychain-drill gating pattern) — NEVER in the default suite.
   Its preconditions refuse loudly (author-free, zero real-store instances, Accessibility +
   Screen Recording granted).
5. **Output:** captures + a per-scenario PASS/FAIL report (the assertion values printed) into a
   gitignored folder (`notes/plans/vis-walks/<date>/`); non-zero exit on any failure. The record
   of a run that gates a close is pasted into the closing record (numbers, not pictures).
6. **The standing cadence:** on demand at phase closes touching the editor, and ONCE AFTER EVERY
   macOS UPDATE on the then-unchanged tree — which makes TK2 NOTES §5's re-verify rule executable
   and answers her attribution question by construction next time (tree unchanged + suite red =
   the OS moved).

**Deliberately NOT in v1:** pixel-diff baselines (fragile), phone scenarios (the phone has no
driver road; a parity row at close), and any default-suite membership. **Sizing:** one unit
(driver + oracle endpoints + the seeded scenarios + one full evidenced run); its first run doubles
as U0/U0b/U0c's standing evidence.

## U-VIS BRIEF (session 4 — the visual regression harness, built to the DESIGN NOTE above; written by the orchestrator 2026-09-26 one-ahead — spawned after U0c's ladder settles)

You are the `opus-implementer` for **18l UNIT U-VIS**. One acceptance unit: build the harness THE
DESIGN NOTE ABOVE specifies — read it as your contract (its six decisions are settled,
PROVISIONAL under R-18l-4; deviations are STOP-and-report, not judgment calls). Her verbatim ask
is in the charter's U-VIS section and the design note's first line.

**Read first:** (1) THIS file whole — the DESIGN NOTE (your contract), ENVIRONMENT TRAPS
(verbatim binding; the walker facts in the U0/U0b acceptance sections), the U0 · U0b · U0c
RECORDs (your scenarios' reproductions, measured numbers, and fixtures — the replica notes, the
Sherlock shapes). (2) `Tools/WalkKit/` WHOLE — README, `guard.sh`/`click.sh`/`keys.sh`/`wl2.swift`
(committed at `75ce81cd`; your driver PROMOTES these into `Tools/VisualWalk/` or consumes them in
place — either is fine, say which and why), `capture-windows.swift`, `scroll.swift`. (3) The
DEBUG oracles you will read (18k C4's owner-keyed shape binds any NEW oracle;
`notes/plans/phase-18k-runtime-hygiene.md` UNIT C4): `topVisibleOffset`'s line,
the caret facts, the last fragment's bottom, the surface frame — find the existing endpoints
first; add the smallest new one only where none exists. (4) KnownIssues rows 35 · 88 · 89 (the
classes your externals-not-in-process design exists to dodge; row 88 = B5, one of your seeded
scenarios).

**The build:** `Tools/VisualWalk/` — a scenario table (each row: name · fixture · scripted acts ·
the geometry assertions from the design note's three rules) · the driver (launches its OWN
dev-store Debug build; per-step guard; captures + a per-scenario PASS/FAIL report with the
measured values into a gitignored `notes/plans/vis-walks/<date>/`; non-zero exit on failure) ·
the seeded scenarios (the design note's list: typing · U0b's newline round-trip · U0's two click
scenarios · the narrow→restore · a divide and a merge · the mode-switch round trip · U0c's
note-open first/re-open — plus **B5** (row 88): ⌘↓ then ⏎ on invalidated geometry, asserted
EXPECTED-FAIL or PASS as the tree actually behaves, honestly labelled either way) · the env-flag
wrapper (`VARIORUM_VISUAL_WALK=1`, keychain-drill gating; NEVER default-run membership). **The
harness must prove it can RED:** one deliberate self-test (an assertion against a knowingly-wrong
expected value, or a scenario against a scratch build with a fix reverted) demonstrating a
failure is caught, captured, and reported non-zero — a tripwire that cannot fire is hollow by
the standing guard rule. **Acceptance:** the full seeded run on the current tree, evidenced
(the report + captures), plus the self-test's red. Zero `Sources/` changes expected EXCEPT
minimal DEBUG oracle endpoints (owner-keyed; if anything wider looks necessary, stop and
report); zero `Sync/`. Discipline: the U0 brief's paragraph verbatim (`## U-VIS RECORD` in THIS
file; checkpoint from first commit; no subagents; synchronous waits; pathspec-limited). Review:
Opus cold review unless the diff's oracle endpoints touch the editor seam beyond DEBUG — then
Fable (R-cor-14's letter; expected: the DEBUG-only blast radius keeps it Opus).

## U1 BRIEF (session 5 — note Read adopts the F3 shape; written by the orchestrator 2026-09-26 one-ahead — spawned after U-VIS's review settles; re-check against the U-VIS RECORD before spawning)

You are the `opus-implementer` for **18l UNIT U1**. One acceptance unit, PHASE-SIZED: the note
Read mode (BOTH faces) adopts the landing shape 13u4 UNIT F3 proved on the book Index — heights
known before the aim, one authority watching the landing. **The charter's U1 text is your unit
charter, read it IN FULL:** `notes/plans/post-13u-health-rounds.md` KICKOFF 2, the U1 bullet
(the `LandingPolicy.readNote`, the per-note BLOCK manifest from the already-cached
`Queries.blockExtents` through `ProseHeightModel`, rows as placeholders at asserted heights, the
authority's aim/hold/correct/watchdog loop replacing the one-shot `scrollTo` in BOTH faces
(`ReadModeView.land`, `ReadEditPane.land`), the signpost for free; **the shipped resting anchors
KEPT — page 0.08, edit `.center`: where a landing puts the block is PRODUCT, not this round's
call**; the contents columns may adopt the same aim if cheap, else record).

**Read first, beyond the charter:** (1) THIS file whole — the SITTING RECORD, ENVIRONMENT TRAPS
(verbatim binding), and the **U0c RECORD**: Read's opening landing changed there
(`ReadModeView`'s seed/select and the `openingLanding` arm) — your adoption COMPOSES with the
opening arm, never fights it (a first open still shows the start; a landing asked for still
lands; if the two want different machinery, stop and report the fork). (2)
`notes/codebase-health-review-2026-09-21.md` §1 whole — §1.2's diagnosis IS your unit's target
(the one-shot aim against a lazy estimate, the identical jump every time, the no-`landing`-line
Console signature); §1.3 item 1 your shape; §1.4 the warming refusal (OUT of scope, §W's
protocol). (3) The 13u4 **UNIT F3 BRIEF + RECORD** in `notes/plans/phase-13u4-restyle.md` — the
pattern being transplanted AND the acceptance protocol's form (the cold-trial table; red-on-old
by behavioral revert on a probe-only tree). (4) The code: `Surface/LandingAuthority.swift` whole
(a new `LandingSurface` case is a CLOSED-enum addition — the signpost stays content-free),
`Surface/BookHeightManifest.swift` + `ProseHeightModel`, `BookIndexView`'s F3 adoption (the
worked example one surface over), `ReadModeView` + `ReadEditPane` end to end,
`Queries.blockExtents` (`Sources/VariorumCore/Queries/PageExtents.swift`) and
`BookViewModel.flowExtents` (the cache-key precedent for a PER-NOTE cache home). (5)
`notes/TEXTKIT2_NOTES.md` §2–§3.

**Acceptance is MEASURED, F3's own protocol:** cold and warm deep-click runs on the real
long-note fixture (a Sherlock story; U0c's walk facts name the fixtures), N-of-N settling at the
anchor with `hops=0` cold, the warm set too, plus a hands-on walk (both voices); and the review
§1.2 Console diagnostic FLIPS — the note-Read stutter path now EMITS `landing` lines (capture
the log line in the record). P1: the manifest consult is ∝ the note, once per note model
(the `flowExtents` cache shape); nothing new at autosave rate. Zero `Sync/`; `Sources/` only if
a `Queries` read needs a new bounded form (say so; schema untouched). Discipline: the U0 brief's
paragraph verbatim (`## U1 RECORD` in THIS file; checkpoint from first commit; pathspec-limited;
no subagents; synchronous waits; tests at END + `TutorialWalkTests`). Review per the charter:
**Opus cold review unless your diff drifts onto the editor seam** (`EditorTextView` /
`PaneSurface` / `PaneTextAuthority` bodies) — state plainly which it is. NOTE FOR THE RECORD:
after U1 closes, the orchestrator makes the R-18l-3 SEAM JUDGMENT (continue to U2/U3/U4 in this
round, or close 18l and hand the remainder to 18l-b) — your record's final state is that
judgment's input; close it self-contained.

## U0 RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line):** (1) no whole-old-tree harness bisect — every Mac test run launches the
tree's own app as the test host, which opens the DEV STORE at launch (18k C7's trap; an old build must
never open it), so attribution rests on LINE HISTORY plus red pins and behavioural reverts on today's
tree (C6b's stated constraint, the same); (2) U0b and U0c were NOT investigated (not this session's);
(3) no KnownIssues / TEXTKIT2_NOTES / canon edits — every row close and the measured TK2 fact are
handed to the orchestrator below; (4) the book Index LANDING's caret (sweep S4) and the tiers'
vertical-metric mismatch (S3) are OWNED elsewhere, not fixed; (5) the U3 rider (`PaneSurface`'s render
restore under 27's `layoutViewport()` displacement) was NOT examined — U0 does not touch `PaneSurface`;
(6) row 85 (O-2) not taken — U0 does not touch the ring's refresh. Closing runs: see LIVE STATUS 8.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's list, in order, own context) | DONE — this file whole; the charter's KICKOFF 2; KnownIssues rows 85/86/87/89/90 (+75, found relevant); `TEXTKIT2_NOTES.md` whole; 18k C2 / C6 / C6b briefs + records + adjudications + the held-walk C6 rows; the three captures; `BookIndexView.swift`, `BookIndexEditModel.swift`, `Surface/PaneSurface.swift`, `EditorView.swift` (`InlineEditorSurface`) end to end; `ReadEditPane.swift`, `BlockTOCView.swift` (the caret-landing half), `StableSurface.swift`, `Tools/WalkKit/README.md` |
| 2 | Item 1 — reproduce | DONE — harness (`51824a08`, 9 issues) and in the app on the pre-fix build (ITEM 1) |
| 3 | Item 1 — trace + attribution | DONE — pre-existing (ITEM 1) |
| 4 | Item 1 — pin, fix, revert | DONE — pin `51824a08` · core `83f6f317` · fix `7553dd93` · R-U0-1 RED 26 → green (`653877ce`) |
| 5 | Item 2 — reproduce, trace, pin, fix, revert (TWO mechanisms) | DONE — (a) the missing width trigger: pin `54fb5d47` (+ both directions `f46ceac8`), fix `0d9ac91d`, R-U0-2 / R-U0-2b RED → green; (b) the unsettled first measure (the brief's named suspect): pin `08aa8d0c`, fix `8b86232a` (the settle net), R-U0-3 RED → green (`17e07015`) |
| 6 | Item 3 — the regression sweep | DONE — THE SWEEP below (with ATTRIBUTION per finding) |
| 7 | Walk (both voices) + captures | DONE — PASS on the final product code (THE WALK below); captures `notes/plans/18l-screens/u0/` (gitignored) |
| 8 | Closing runs | **DONE** on the final tree (`0e1cbd65`, product code `8b86232a`), zero app instances, the machine idle (HID 721 s): **Mac — 59 suites named literally (the touched and neighbouring suites: the Index, Read ▸ edit / TOC, the inline editor's hosts, the C6/C6b jump family, and the eleven Tutorial suites): ✔ Test run with 341 tests in 59 suites passed**, 0 skipped (`DerivedData/18l-u0-closing1.log`); 112 `Modifying state during view update` lines, all from pane-mounting tests (32 in the new parameterized pins, whose live panes publish through `PanePublisher` — the A1 family, U3's). **Core `swift test`: 1729 tests / 181 suites passed** (`18l-u0-core.log`; +6 = `MarkdownRenderingSourceOffsetTests`). **iOS: BUILD SUCCEEDED** (`18l-u0-ios.log`). **Mobile (the suites that consume `FlowParagraph` / `MarkdownRendering`): 34 tests / 8 suites passed with 2 known issues** — the phone tutorial's duplicate-divide lesson, KnownIssues row 51 (`18l-u0-mobile.log`) |
| 9 | Self-assessment | DONE (below) |

- Deaths / resumes: none.
- **INCIDENT (machinery honesty, ~01:37 local):** a walk double-click (`cliclick c:318,226`, meant for the
  dev window's `index` tab) fired while the author was at the machine; her `/Applications` window covered
  that point and my dev window had left the current Space, so the click MAY have landed in her real-store
  window (worst case a mode/tab switch). Reported to the orchestrator at once; she was told. GUI driving
  stopped until her go-ahead (`eee99b8f`), then resumed under the hardened per-step rule (`615b833a`),
  mechanized as `guard.sh` (her app absent · HID idle ≥ 2 s · the dev pid frontmost · the dev window on
  this Space with the click point inside it) — which fired once more (~03:50, HID input: someone at the
  machine) and stopped the walk until the orchestrator's R-18l-4 all-clear.

### ITEM 1 — the click REFUSES the text (KnownIssues row 86)

**The mechanism (traced at the code, then measured).** The two index-like surfaces — the book Index
and the note's Read ▸ edit — draw each block at rest as read-cheap SwiftUI `Text`
(`FlowParagraph`, markers hidden) and upgrade the clicked one to THE live pane (P-3). The upgrade was a
bare `.onTapGesture { … makeLive(…) }`: it knew WHICH block, never WHERE. The freshly mounted
`PaneSurfaceView` then placed its caret by its host's rule: the book Index passed no
`caretOnGoingLive`, i.e. `.leave` — the selection `string =` leaves, the END of the take — and in her
notes the END is the EMPTY LINE under the text, because the sample library keeps the blank line between
paragraphs as content (211 of 212 blocks end in `\n`); Read ▸ edit passed the note's entry rule
(`PaneCaretLanding.entering` → `.start`, or the remembered offset on the current block). A click whose
place never reaches the pane is exactly her *"refusal of clicking into the text"*; the second click
worked because by then the pane was a real text view. `PaneCaretLanding`'s own doc says *"a click
always keeps the place the click brought"* — true of TK2 read panes, unreachable from a `Text`.
**The charter's first suspect is RULED OUT by measurement:** a y-scan of real clicks across the block
seam switched block 1 → none (the 8-pt gap) → block 2 exactly at the frames' edges — no vertical
offset in the hit-test (`18l-u0-probe2.log`). (One rig fact on the way, recorded in the pin: SwiftUI's
`.global` frame is the WINDOW's y-down space, titlebar included.)

**Reproduced:** the pin RED (`51824a08`, 9 issues: the Index at 366 of 366 — the empty line, whichever
line was clicked; Read ▸ edit at line 0); in the app on the pre-fix build, Study, Sherlock ▸ Index, a
click on *"mind. He was, I take it…"* → the caret on the empty line under the paragraph
(`18l-screens/u0/repro/item1-prefix-study-click.png`).

**ATTRIBUTION: pre-existing.** Line history (`git log -L`): the tap road is `c768c08e` (2026-09-01,
the Index edits in place — its first form), the `.leave` / `.start` landing branch `a0aade08` ·
`3ded9683` · `41a75000` (17o batch b, 2026-09-07), the k−1 blank lines older still (Phase 10 Step 9,
2026-07-12) — all before the 13u2…18k window. Inside the window `blockView` changed only at `7d44eda6`
(13u2 B, tier paddings) and `9fe6ae5d` (18k C4, oracle owners), neither on the road. The mechanism is
macOS-independent (a tap with no point; a text view's selection after `string =`). Whole-old-tree
harness bisect barred (first line). It reads as a regression because the Index only became editable at
`c768c08e` and she met it on the Sherlock notes.

**THE FIX (`7553dd93`, on core support `83f6f317`) — the click brings its PLACE.**
`Surface/ReadTierClickPlace.swift` (new): the tap's location, in the read tier's own geometry, is laid
out again OFF-SCREEN exactly as the tier drew it — `FlowParagraph`'s display, the voice's body font,
the tier's `lineSpacing(4)`, its 8-pt paragraph gap and list indents (both now named constants the two
tiers draw with), at the column's measured width — TextKit 2's own click-to-caret question
(`textSelectionNavigation.textSelections(interactingAt:…)`) names the display character, and
`MarkdownRendering.sourceOffset(forDisplayOffset:in:)` (new, core, pure — read off the SAME walk
`render` builds the display from; the loop factored into `walkLines` byte-for-byte) carries it back to
the stored text. `ReadTierClickTarget` replaces the bare tap on both tiers; the book Index hands the pane
`.offset(place)` for that take (`BookIndexEditModel.caretLanding(forVariant:)`, `.leave` for every
landing — byte-unchanged); Read ▸ edit lets the click's offset outrank the entry rule
(`BlockTOCViewModel.makeLive(_:variantID:clickOffset:)`). One off-screen block layout per click (P1:
bounded by the block clicked); TK2 API only.

**Pins — `IndexClickCaretTests` (new), 2 tests × {Terminal, Study} × {first line, last line}**, real
clicks on her note's shape, a block over a blank line AND the last block: the caret is on the clicked
line, never parked at the END; on the first line the caret is the SAME character the live pane's own
hit-test names at the click's x (±1); and (book Index) the replica's block height is within 0.5 pt of
the frame SwiftUI drew — the replica's fidelity is measured, not assumed (a point release that moves
SwiftUI's text metrics goes red). Core: `MarkdownRenderingSourceOffsetTests` (6; the 11 render pins ride
unmodified). **R-U0-1** (both hosts `clickOffset: nil`): RED 26 issues, the pre-fix shape in both voices
(339–345 chars from the pointer at the Index; 21–28 on Read ▸ edit's first line) → restored → green.

### ITEM 2 — the clipped descenders (her capture) — TWO mechanisms, both fixed

**(a) The missing width trigger.** The Outline's (and the spread's) live note is `InlineEditorSurface`,
a content-sized TK2 view whose frame height is whatever its coordinator last REPORTED. It re-measured on
a storage edit or a SwiftUI update pass only; a WIDTH change re-wraps the text with neither, and the
update pass a resize runs was traced measuring an INTERMEDIATE width (`updateNSView` at 902 pt, the
final 629 pt applied in layout after it). So the frame kept the old wrap's height: narrowing cut the
tail (her capture — descenders, then lines not drawn); widening left a gap (KnownIssues row 75's tall
side). **Pin `InlineEditorWidthReflowTests`** (new; the real Outline, her *About this book*, a
fifteen-width walk per voice) RED on the pre-fix tree — `54fb5d47` (51 / 66 pt short), strengthened to
both directions `f46ceac8` (R-U0-2b: 4 SHORT −51…−102 pt, 2 TALL +51/+66). **Fix `0d9ac91d`:** the
coordinator composes the height onto the text view's own width door (`onWidthReflow`, fired from
`setFrameSize` once the prose column is placed — the model's overlay handler first, then the one
coalescing hop). **R-U0-2** RED (identical) → green. **Also reproduced in the app on the pre-fix build**
(Study, 1440 → 900: the last paragraph's fourth line cut through its middle, the ring hanging below it —
`repro/item2-prefix-study-narrow3.png`). **ATTRIBUTION: pre-existing** — the trigger set is the
inline editor's since its birth (`8c700402`, Phase 10 Step 3, 2026-07-12); 17p b's lane re-report
(`4e21cde0`) and its removal at 13u3 A1 (`f93d1bd9`, in the window) concerned decoration-lane changes,
never width; and the strand measured identically on the PRE-C2 road (`EditorView.swift` reverted to
`48297899`'s behaviour in the working tree: the same 17-pt short at 1200 → 820) — C2 changed WHEN a
report is made, never WHAT triggers one.

**(b) The unsettled first measure — the brief's named suspect.** On the width-hop build the walk found
the long live story's end BLANK after a resize + scroll (5 of ~9; 0 of 6 on the pre-hop build — the
hop measured at the earliest, most unsettled moment). An instrumented scratch build (never committed)
logged it: after 1000 → 1440 the report carried **22,884 pt** (TextKit's first full measure at the new
width) where the laid-out end settled at **23,082 pt** once a scroll laid it out — and nothing
re-reported, so the frame kept the first number: short → the tail cut; tall → a blank page above the
footer. In the bare inline rig the same class is large: **631 pt SHORT at 420, 229 pt TALL at 700,
126 pt at 520** (a fresh TK2 view of the same text at the same width agrees with the SETTLED numbers at
420/700 — and TextKit's own settled layout sat 338 pt off a fresh view's at 520: layout-history
dependent, the fenced measurement brain's, recorded not chased). **Pin
`InlineHeightReportTests.aReflowsLateSettleIsReportedToo`** RED on the width-hop tree (`08aa8d0c`). **Fix
`8b86232a` — THE SETTLE NET:** the coordinator composes onto the display-pass door (`onLayoutSettle` ←
`viewWillDraw`, the model's overlay refresh first) an O(1) read of the LAST layout fragment's bottom;
when it has MOVED since the last look and disagrees with the last report, the one report hop runs.
Edge-triggered (a stable disagreement can never spin), bounded 8 per occasion (re-armed by a width
change, the mount, a storage edit), terminating (a report changes only the height, which moves no
fragment). **R-U0-3** (`displayPassSettled` returns at once) RED 4, identical → green. **ATTRIBUTION:
undetermined** — the class is TextKit's own (§2 documents wrong fragment heights since 15.6; §3 records
the first-measure fact from 18k C2 on 27.0), no commit in the window changed `PaneMeasurement`, and no
26.x tree or OS is available to measure its magnitude before 27.0. **For TEXTKIT2_NOTES §3 (the
orchestrator's canon edit):** *on 27.0 the inline editor's first full `.ensuresLayout` measure after a
reflow can be 1–5 % off the layout the next display pass settles to (bare rig 631 / 229 / 126 pt; the
app 198 pt on 23k) — the inline editor now re-reports on the display pass (the settle net); re-measure
at 27.1.*

**One existing pin adapted (flag for the Fable ladder):** C2's
`anUpdatePassReportsOnTheTurnAfterItNeverInsideIt` asserted `reports.count == 1`; with the settle net
the pass still reports once and the SETTLE reports after it — the pin's own note had recorded the 631 pt
as "not an equality". Now: `(1...3).contains(count)`, the first report still on the narrow side of the
midpoint (its teeth against the stranded wide height kept), plus a new arm — the LAST report equals the
settled height (RED on the pre-net tree, 631 pt).

**Harness fact (sweep S5):** C2's two inline pins go RED when the DEV STORE's voice is Study — the
test host adopts the dev store's typography at launch. My walk had left the dev voice Study mid-session;
back in Terminal (as found), the suite passes. My pins pin their own voice (their own store +
`ThemeStore`, the global restored after).

### THE WALK (USE) — dev-store Debug, per-step guarded, both voices

Final product code = `8b86232a` (build `DerivedData/18l-u0-walk` at `17e07015`); the item-1 rows
were walked on `0d9ac91d`'s product code (item 1's code unchanged since). Captures under
`notes/plans/18l-screens/u0/` (gitignored). Settings as found: Terminal voice, window 1440×1000; left the same.

| Voice | Surface · row | Result | Captures (`walk/`) |
|---|---|---|---|
| Study | Index · a mid-paragraph line | the caret at the clicked character (*"I take it, t\|he"*) | `s-index-click-midline` |
| Study | Index · the next block's FIRST line | on that line | `s-index-click-firstline-next` |
| Study | Index · a block's LAST line, directly above its empty separator (her trigger) | on the line (*"twel\|ve"*), never the blank | `s-index-click-lastline-above-separator` |
| Terminal | Index · the same three shapes | all three on their lines (*"abhorrent \|to"*, *"questionabl\|e"*) | `t-index-click-*` |
| Study | Read ▸ edit · a mid line; then a line of the next block (after the first click's block went live and reflowed, the pointer sat on that block's line 2) | on the clicked character each time (*"introdu\|ce"*, *"happiness\|,"*) | `s-readedit-click-*` |
| Terminal | Read ▸ edit · a block's last line | *"q\|uestionable memory."* (was: line 0) | `t-readedit-click-lastline` |
| Terminal | Outline · *About this book* live · 1440 → 1180 → 1000 → 900 → 820 | whole text at every width, "tagged" whole | `t-outline-about-live-w*` |
| Study | Outline · *About this book* live · the pre-fix repro's own sequence + far scrolls | whole at every step | `rep2/`, `net-s-about/` |
| Terminal / Study | Outline · *Copper Beeches* (212 blocks) live · 1440 ↔ 1000 ×3, scrolled to the end each time | the story's end drawn, the footer after it — **12 of 12** (the width-hop build: blank 5 of ~9) | `net-t-blank/`, `net-s-blank/` |

### THE SWEEP — finding × mechanism × ATTRIBUTION × disposition

| # | Finding | Mechanism | ATTRIBUTION | Disposition |
|---|---|---|---|---|
| S1 | Index / Read ▸ edit click lands on the empty line / at the block's start (row 86 — item 1) | a bare tap with no point; the pane's `.leave` (END = the blank line) / entry rule | **pre-existing** (line history: `c768c08e` 2026-09-01 + 17o b 2026-09-07, both before the window; macOS-independent) | **FIXED** `7553dd93` · pins `IndexClickCaretTests` (+ core `MarkdownRenderingSourceOffsetTests`) · R-U0-1 red 26 |
| S2 | The live note's frame not re-measured on a width change — the tail cut (her capture) / a gap (row 75's tall side) | the trigger set never included width; the update pass can measure an intermediate width | **pre-existing** (the trigger set since `8c700402`, 2026-07-12; identical on the pre-C2 road) | **FIXED** `0d9ac91d` · pin `InlineEditorWidthReflowTests` · R-U0-2/2b red |
| S2b | TextKit's first full measure after a reflow differs from the settled layout; nothing re-reported (the brief's named suspect; the once-seen Study clip; the blank end on the width-hop build) | TK2 layout-history variance, no convergence re-report on the inline editor | **undetermined** — TK2's class (§2 since 15.6; measured on 27.0 by 18k C2); no commit in the window changed `PaneMeasurement`; no 26.x to compare | **FIXED** `8b86232a` (the settle net) · pin `aReflowsLateSettleIsReportedToo` · R-U0-3 red · §3 line handed over |
| S3 | A click on the Index / Read ▸ edit read tier REFLOWS the block under the pointer (the live pane: TK2 line metrics, no 4-pt line spacing, dimmed markers shown — the text jumps a few lines' worth) | the two tiers' VERTICAL metrics were never aligned (13u2 B aligned the leading x only) | **pre-existing** (the tiers since `c768c08e`; 13u2 B `7d44eda6` touched paddings only) | **OWNED — PROPOSED:** 12 (Hardening) or an 18l rider; whether the live pane should match the read tier's line spacing is a TASTE call → HELD-FOR-HER as a question, not built |
| S4 | A book Index LANDING (a Read click-through, `requestLanding`) parks the caret at the block END — her blank line | the landing's pane gets `.leave`; `LandingTarget.utf16Offset` is not wired | **pre-existing** (`c768c08e`) | **OWNED — U4** (ledger row 11: `LandingTarget.utf16Offset` wired-or-deleted is exactly the question of where a landing's caret goes); measured by a scratch probe (caret 329 of 329 → the blank line) |
| S5 | C2's inline pins go RED when the dev store's voice is Study | the test host adopts the dev store's typography at launch; the pins read the process-global | **our-commit(`48297899`)** — the C2 pins' harness never pinned its voice | **OWNED — PROPOSED 12** (the harness-calibration family, beside rows 36 / 88) |
| S6 | KnownIssues row 75 (the ~85-pt tall gap after narrow → restore) | S2's tall side + S2b | as S2 / S2b | **FIXED by S2 + S2b** — pins show the tall strands red-on-old (+51/+66; +229); **the row's close is the orchestrator's** |
| S7 | The U3 rider: `PaneSurface`'s render-restore `layoutViewport()` under 27's clip displacement | — | — | **NOT EXAMINED** — U0 does not touch `PaneSurface`; stays U3's |
| S8 | Row 85 (O-2, the ⌘↓ ring drawn high) | — | — | **NOT TAKEN** — U0 does not touch the ring's refresh; stays 12 |
| S9 | U0b (Write top padding) / U0c (note-open landing) | not investigated | — | their sessions, unchanged |

### SEAM FILES THIS DIFF TOUCHES (the Fable reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Features/Editor/EditorView.swift` (`InlineEditorSurface.Coordinator`) | the width door composition (`onWidthReflow`) + the settle net (`onLayoutSettle` composition, `displayPassSettled`, `lastReportedHeight`, the budget); `remeasure` records its report | `EditorTextView`, `EditorViewModel`'s storage seam, `BlockRangeIndex`, `PaneSurface`, `PaneMeasurement`, `scheduleRemeasure`'s newest-wins, the binding gate |
| `Surface/ReadTierClickPlace.swift` | NEW — the click's place (the off-screen replica) + `ReadTierClickTarget` | — |
| `Features/BookView/BookIndexView.swift` | the read tier's tap → `ReadTierClickTarget`; `caretOnGoingLive` wired; the two tier metrics named; a DEBUG frame oracle | the pane, landing, manifest, liveness authority |
| `Features/BookView/BookIndexEditModel.swift` | `makeLive(…, clickOffset:)` + `caretLanding(forVariant:)` | the authority, flush, landing |
| `Features/ReadMode/ReadEditPane.swift` · `Features/TOC/BlockTOCView.swift` | the same tap; `makeLive(_:variantID:clickOffset:)` — a click outranks the entry rule | `PaneCaretLanding.entering`, `notePaneCaret` |
| `Shared/FlowParagraph.swift` | `displayStarts(of:)` + the blank rule as one private function | the transform (byte-identical) |
| `Sources/VariorumCore/Domain/MarkdownRendering.swift` | `sourceOffset(forDisplayOffset:in:)`; the walk factored into `walkLines` | `render`'s output (11 pins unmodified) |
| Tests | NEW `IndexClickCaretTests`, `InlineEditorWidthReflowTests`, `MarkdownRenderingSourceOffsetTests`; `InlineHeightReportTests` + 1 test, 1 arm adapted | — |

Zero `Sync/`, zero schema, zero `Server/`. No TK1 API (the replica is `NSTextContentStorage` +
`NSTextLayoutManager`; the net reads `enumerateTextLayoutFragments(options: [.reverse])`).

### JUDGMENT CALLS (each reversible in a line)

1. **A click's place is found by an off-screen REPLICA of the read tier**, not handed to the live pane's
   own hit-test: the live pane lays the take out differently (markers shown, tighter lines), so a point
   passed through drifts a line per few lines down a long paragraph. The replica's agreement with what
   SwiftUI drew is pinned (±0.5 pt, both voices). *Reverse by* passing the point to the pane
   (`characterIndexForInsertion`) — simpler, measurably worse below a paragraph's first line.
2. **Headings are measured in the body font** (the tier's title/heading fonts live only in SwiftUI):
   a click inside a heading lands on that heading's line with its x approximate. Stated in the file.
3. **Read ▸ edit: a click outranks the entry rule** even on the note's current block (it used to land
   at the remembered offset there). `PaneCaretLanding`'s own ruled doc says a click keeps the place it
   brought; this makes that true for the `Text` tier. *Reverse by* consulting the entry rule when the
   clicked block is the current block.
4. **Both item-2 fixes live in the inline coordinator**, not `PaneMeasurement` (fenced). *Reverse by*
   the width hop alone (the settle net is what makes the walk's 12/12).
5. **The settle net is edge-triggered on the last fragment's bottom** (O(1) per display pass) with an
   8-per-occasion budget. *Reverse by* a fixed N-pass re-measure after a width change (costlier, misses
   the scroll-into-view settle the app showed).
6. **C2's update-pass pin's count arm adapted** (above) — flagged.

### NOTICED, NOT TOUCHED

1. The book Index landing's caret (S4 → U4). 2. The tiers' vertical metrics (S3 → her call).
3. The C2 harness voice leak (S5 → 12). 4. `InlineEditorSurface`'s two compositions assume the model's
`attach` runs before `install` (true in `makeNSView`); a re-attach would drop them — not a road today.
5. Deep links / Read click-through still use `.leave` (U4). 6. KnownIssues row 75 → close as FIXED by U0
(the orchestrator's edit). 7. The TEXTKIT2 §3 paragraph for S2b (above) — canon, the orchestrator's.

### SELF-ASSESSMENT

Strong: every fix has a traced mechanism, a red-on-old pin and a behavioural revert red identically;
the walk is use-shaped, both voices, per-step guarded, on the final product code; attribution is stated
per finding with its evidence and its limits. Weakest points for the reviewer: (a) the replica is a
second LAYOUT of the read tier's text (not a second measurement brain for any frame — it only answers
"which character"), pinned for fidelity but approximate for headings; (b) the settle net adds per-display-
pass work to the inline editor (O(1)) and composes two model doors in `install`; (c) the adapted C2 pin;
(d) the item-1 attribution rests on line history, not an old-tree run (barred). The width hop alone
measured WORSE in the app than the pre-hop road (the blank end, 5 of ~9) until the net landed — the two
must ship together. Closing runs green (LIVE STATUS 8). **U0 — DONE (implementer); the Fable cold review follows.**

### U0 — ORCHESTRATOR ACCEPTANCE (the hands-on walk, 2026-09-26 overnight; the verify-never-trust pass)

**Claims verified against git before the walk:** all commits `4dfd84eb…3fd62455` present and pushed,
tree clean, the five new files exist, the record's LIVE STATUS fully flipped with hashes and red
counts. **The walk, on a fresh Debug build of `3fd62455` (dev store, zero other instances, machine
idle, per-step guard):**
- **Item 1 PASS.** Sherlock ▸ Index, read tier: a click ON "eclipses" (line 2 of A Scandal in
  Bohemia's first paragraph) went live with the caret ON that line at the clicked word — not the
  empty paragraph, not the block end; a second click on a lower line of the NEXT block ("were
  sufficient to absorb…") landed the caret on that line likewise. One click each; her "refusal"
  shape is gone in my hands.
- **Item 2 PASS.** Outline, About this book LIVE: window 1440 → 1000 — the note re-wrapped whole,
  last line's descenders intact, no cut tail; 1000 → 1440 — no anomalous gap under the last line
  (row 75's tall side). Final capture kept at `notes/plans/18l-screens/u0/orch-walk-widen-restore.png`.
- **Observed en route, consistent with the record:** the live pane re-wraps slightly under the
  pointer on going live — the S3 class, recorded, deliberately not built, HELD for her (the
  morning bundle). Also one walker fact for the traps: the ← → history bar appears after the
  first navigation and pushes the shelf rows ~17 pt down — measure click targets from a capture
  taken in the CURRENT navigation state.

**Orchestrator adjudications landed with this acceptance (R-18l-4 provisional authority):**
row 75 CLOSED — RESOLVED at 18l U0 (S2 + S2b, pins named in the row); S5 filed as a new
KnownIssues row (owner 12, the harness-calibration family); S3 filed as a new KnownIssues row
(owner: the Design & UI review project row, flagged AS A TASTE CALL for her — the tiers' shared
metrics are product); the TEXTKIT2_NOTES §3 settle-net line added (a measurement record). Ledger
rows 1–3 flip to BUILT+WALKED — the Fable cold review is the remaining gate.

## U0b RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line):** (1) no whole-old-tree harness bisect (the C7 dev-store trap, as U0/C6b) — attribution rests on R-13y / R-F2 / R-room plus line history; (2) the LIVE corner-drag resize was not walked in the app (the drag hit the overlay scroller) — B3 rests on its pin (AppKit's own live-resize notifications, red-on-old 24.0) and a walked AX resize round trip; (3) **B5** (⏎ right after a ⌘↓ on invalidated geometry moves the page) NOT traced and NOT built — a second mechanism on the differential road, owner proposed below; (4) U0c NOT investigated beyond recording B6; (5) no KnownIssues / TEXTKIT2_NOTES / WalkKit / canon edits — row 87's close, B5's row and the walker facts are handed to the orchestrator; (6) no core / iOS / mobile runs — zero `Sources/`, zero `Shared/`; (7) the U3 rider (`PaneSurface`'s render restore) and row 85 (O-2) untouched — U0b touches neither.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, SITTING RECORD R-18l-1/2/4/5, ENVIRONMENT TRAPS, CAST, BASELINES, the U0 RECORD whole + its acceptance); `18l-u0-ladder-round1.md` whole; the charter's KICKOFF 2 (U0 + U0b); `TEXTKIT2_NOTES.md` whole; the 18k C6 brief + record ITEM 1 and the C6b brief + record + adjudication; KnownIssues row 87; `SessionResiliencyProtocol.md`; both captures; the code: `EditorTextView.swift` whole (the 24-pt top inset `makeEditor`, the typewriter room, β1), `JumpPrimitive.swift` whole, `ViewportCarry.swift`, `EditorSurfaceController` (`renderFull`, `runStructural`, `applyStructuralResult`, the A7 carve `planEmptyBlockDeletion`/`runEmptyBlockDeletion`, `insertEmptyBlock`, the typed Return's act), `EditorViewModel` (`topVisibleOffset` + helpers, `restoreTopVisibleOffset`, `keepingReadingPosition`, the parks and their consumers, `teardown`, the keystroke's carve dispatch), `EditorView.swift`'s `ScrollAnchorController`, `EditorDocument.swift` |
| 2 | Reproduce (harness, her shape, both voices) | DONE — **in the app on the pre-fix build** (dev store, her sequence typed through the shelf's quick entry → Write → click the last line's end → ⏎ → ⌫; the receipt *"Empty block deleted — ⌥⌘Z undoes it."*, the tray badge ⌫ 1): the first line's ink **27.5 → 3.5 pt** below the masthead hairline in Terminal, **29.5 → 5.5 pt** in Study — Δ 24.0 in both, the same row signature (`18l-screens/u0b/pre/{t,s}-her-0{1,2}-*.png`, measured by `DerivedData/c6bmeasure.py`); and `WriteTopAirTests` RED on today's tree `b4b978cd` (`DerivedData/18l-u0b-pin-prefix2.log`: 7 tests, 6 red, **14 issues**): her gesture — the page scrolls **24.0 pt** (Terminal AND Study; exactly the container's top inset) and the first line moves 24.0; the round trip — ⏎ moves nothing, ⌫ moves 24.0; a long note's same gesture mid-note and at the tail — the page moves **5.0 pt** (the edge's offset inside its line, snapped away); the siblings — a LIVE resize at the page top 24.0, a re-font (voice switch) at the page top 24.0; a NON-live width reflow at the page top GREEN (hollow as a defect — below) |
| 3 | Trace + attribution | DONE — the mechanism (THE TRACE below) confirmed by the pins' numbers; **R-13y RED with the same shape** (`18l-u0b-R-13y.log`: 14 issues — 24.0 ×10, mid 5.0 ×2, tail 5.0 Terminal / **25.0** Study: 13y's road without C6's re-assert lands the tail a line further off); restored, `git status` clean. **R-room probe** (the test's own room switched off, test-side only, restored): her two short-note pins GREEN — the page cannot scroll past 0 without the typewriter room, so the room is what lets her short note collapse. ATTRIBUTION: **pre-existing** (below) |
| 4 | Pin red-on-old | DONE — `WriteTopAirTests` committed RED (this commit) |
| 5 | Fix + behavioural revert | FIX DONE (this commit) — `ReadingAnchor` (the reading position with its place); `renderFull` restores EXACTLY; the re-layout keepers (live resize / width reflow, re-font) keep the ruled line-at-the-top rule except in the page's top air. `WriteTopAirTests` **7/7 GREEN** (`18l-u0b-pin-fixed1.log`). Behavioural reverts DONE: **R-full RED — 14 issues, identical to the pre-fix run** (`18l-u0b-R-full.log`); **R-top RED — exactly the live-resize and re-font pins, 4 issues (24.0)**, her gesture / round trip / mid / tail GREEN (`18l-u0b-R-top.log`); each restored with `git checkout HEAD --`, `git status` clean |
| 6 | Walk (both voices: her sequence; a long note mid + tail; add-then-remove) | **DONE — PASS** on the fixed build (THE WALK below; every row both voices, measured by row signature); the pre-fix build reproduced her shape first (row 2) and, en route, a 40.0-pt tail snap on ⌫ |
| 7 | Closing runs (touched suites + the eleven Tutorial suites) | **DONE** on the final tree (product code `998f7d7d`), zero app instances, machine idle: `DerivedData/18l-u0b-closing.sh` — 18k C6b's closing set (the jump / anchor / landing / re-font / typewriter family, the structural and seam suites, the eleven Tutorial suites) + `WriteTopAirTests` + the `renderFull` / structural-door consumers (`StructuralRewriteDoorTests` … `ReviewRound3FixTests`, `BlockDeletionAndRedoTests`, `DeferredProjectionRetryTests`, `FocusHandoffTests`) + the typed Return's (`ReturnKeyTraceTests`, `TypedReturnTests`): **✔ Test run with 694 tests in 87 suites passed** (`18l-u0b-closing1.log`), 0 skipped (the two `skipped` lines are AppIntents metadata warnings), 87 suites counted; 50 `Modifying state during view update` lines (the pane-mounting family, U3's — C6b's closing set logged 51). Every pre-existing pin of the anchor family (`RefontGapTopTests`, `RefontViewportTests`, `ScrollAnchorTests`, `LandingOffsetTests`, `JumpViewportLayoutTests`, `ModeSwitchCarryTests`) rode UNMODIFIED. Core / iOS / mobile: not owed (zero `Sources/`, zero `Shared/`) |
| 8 | Self-assessment | DONE (below) |

- Deaths / resumes: none.

**THE ATTRIBUTION REVERT (named before it runs; the pre-revert state is the pin commit):** **R-13y** —
18k's two road changes behaviourally reverted in the working tree ONLY, so the Write road is her 13y
build's: `JumpPrimitive.jump`'s C6 re-assert forced off (`if false, …`) and its C6b live scroll range
read ONCE at entry; `topVisibleOffset()`'s C6b reading-line branches forced off (`if false, …` — the
box rule answers, exactly 13y's body). Then `WriteTopAirTests` runs; expected: RED with the same
shape (the mechanism predates 18k); then `git checkout HEAD --` both files and `git status` clean.

**THE BEHAVIOURAL REVERTS (named before they run; the pre-revert state is the fix commit):**
- **R-full** — `EditorViewModel.readingAnchor()` captures `inset: 0` (the place thrown away: every
  restore is the old line-at-the-top). Expected: `WriteTopAirTests` red exactly as on the pre-fix
  tree (14 issues: 24.0 ×10, 5.0 ×4), the non-live width guard green.
- **R-top** — `ReadingAnchor.reflowLandingInset` answers 0 always (the keepers' top-air carve
  removed; the full re-render's exact restore kept). Expected: ONLY the live-resize and re-font pins
  red (4 issues, 24.0); her gesture, the round trip, mid-note and tail GREEN.
Each is a working-tree edit only, then `git checkout HEAD --` the file and `git status` clean.

### THE TRACE (inputs → wrong state; every number from a run in this session)

**The top air is a SCROLL offset, not an inset that changes with the block count** — the brief's
fork, decided by measurement. Write's text container carries a fixed 24-pt top inset
(`EditorTextView.makeEditor`, R9's "generous top air"); at rest the page is scrolled to 0 so that air
shows above the first line. The inset never changed (the pins read `textContainerOrigin.y` = 24 before
and after); the clip's origin did — by exactly 24.0.
1. Caret on her EMPTY last block; ⌫ deletes the separator before it → `shouldChangeText` refuses the
   cross-block keystroke and plans A7's carve (`planEmptyBlockDeletion` → `runEmptyBlockDeletion`).
2. The carve runs through `runStructural` with `seam: nil` → `applyStructuralResult` → **`renderFull`**
   (the full re-render; the everyday gestures' differential road — her ⏎ took it, `seam: .divide` —
   has no restore step at all, which is why ⏎ never moved anything).
3. `renderFull` captures `topVisibleOffset()` — at scroll 0 the probe is 23 pt ABOVE the container, the
   first fragment answers, and the reading line is line 0: **offset 0** — then replaces the storage and
   replays it through `JumpPrimitive.jump(toOffset: 0)`, whose contract is "the line AT the viewport
   top". Line 0's top is at view y 24 → the loop converges to **scroll 24**: the page's air, gone.
   The anchor names the LINE; it never knew where the line SAT.
4. The same restore on a wheel-scrolled long note snaps the reading line to the top: the page moves by
   the edge's offset inside that line (the pins' 5.0), or, at a gap top, by the gap (40.0 pt measured
   in the app on the pre-fix build — `pre/s-tail-0{1,2}`).
5. The class, beyond her path: the same line-at-the-top replay drives the two re-layout keepers —
   `ScrollAnchorController`'s live-resize restore and `keepingReadingPosition`'s re-font park — so a
   page resting in its top air lost it to a window drag-resize (24.0) and to a voice switch (24.0).
**Why her SHORT note could collapse at all:** without the typewriter room a note shorter than the page
has a frame floored at the viewport, `maxScroll` is 0 and the jump clamps there (the **R-room** probe:
her two pins GREEN with the room off). L5's room (`314ac454`, 2026-07-30) grew the document by a page,
so the jump's 24 became reachable.

### ATTRIBUTION (the U0 sweep's required column)

- **Her report (the carve at the page top) — pre-existing.** Evidence: **R-13y** — 18k's two road
  changes (C6's re-assert, C6b's live range and reading-line rule) reverted behaviourally → RED with
  the same 24.0 in both voices: her 13y build's road collapses identically, so 18k neither caused nor
  altered it (C6b's rule changes WHICH line mid-note, never offset 0 at the page top). Line history: the
  restore is `renderFull`'s since Phase 7 (`02052d8c`, 2026-07-06); it lands the line at the INSET-
  converted top since 13c 1A (`01e26020`, 2026-07-25 — before it, both halves carried the same inset
  error and cancelled, so offset 0 restored to scroll 0); the carve lands through the full re-render
  since 13c 1B (`7df0795d`, 2026-07-25); a short note can scroll past 0 since L5 (`314ac454`,
  2026-07-30; R-room). All before the 13u2…18k window. macOS-independent (arithmetic on the inset and
  the clamp). No whole-old-tree run (the C7 dev-store trap, as U0 and C6b).
- **The mid-note / tail snap on the same gesture — pre-existing** (the same restore since Phase 7; R-13y
  red: 5.0 Terminal, 25.0 Study — 13y's road without C6's re-assert lands the Study tail a line further off).
- **The live-resize collapse — pre-existing** (`ScrollAnchorController` since Phase 7 `02052d8c`; the
  collapse since 13c 1A's conversion `01e26020`).
- **The re-font collapse — our-commit(`4ae12a59`)** — 13u4 UNIT F2 (2026-09-21), inside the window.
  **R-F2**: the pre-fix road with the re-font keeper switched off (pre-F2: a re-font kept the pixel
  offset, so scroll 0 stayed 0) → the re-font pin GREEN, her gesture's still RED (`18l-u0b-R-F2.log`).
  F2's keeper replays "the line at the top", which at the page top means scroll 24.

### THE FIX (`998f7d7d`) — the reading position carries its PLACE

`ReadingAnchor` (pure, `JumpPrimitive.swift`): the offset `topVisibleOffset` names (the C6b rule,
UNCHANGED), the line's `inset` below the viewport's top edge at capture, and `inPageTopAir` (the edge
above the text container — the container's inset, where no text layout can move anything).
`EditorViewModel.readingAnchor()` captures it (one single-fragment `lineSpan` of a line on screen — P1).
Two landings, one per kind of restore:
- **The full re-render (`renderFull`) lands EXACTLY** (`exactLandingInset`) — a structural result
  changed nothing above the anchor that the offset does not carry, so the page does not move: the
  differential road's promise ("untouched text never moves", 2026-07-07) kept on the fallback road.
- **The re-layout keepers** (`ScrollAnchorController`'s width/live-resize restore via
  `restoreReadingAnchor`; `keepingReadingPosition`'s park via `parkAnchorRestore(_:landingInset:)`)
  keep the RULED rule — the reading line AT the top (13c 1A · 13u4 F2 · 18k C6b · #147) — everywhere it
  was written for, and keep the page's top air as it was (`reflowLandingInset`): the first line was never
  at the top there. The cold mount's session anchor stays an offset (inset 0 — U0c's road, untouched).
`JumpPrimitive.jump`'s `landingInset` (13u2b UNIT 3's own parameter) carries both; no new scroll machinery.

### THE WALK (USE) — dev-store Debug, per-step guarded (`guard.sh`), both voices, measured

Fixed build `DerivedData/18l-u0b-walk` (HEAD `95a16746`; product code `998f7d7d`). "Moved" is MEASURED:
`DerivedData/c6bmeasure.py` lists each text row's ink in points below the masthead hairline with a
pixel signature, so a line is followed across captures. Captures `notes/plans/18l-screens/u0b/{pre,walk}/`
(gitignored). Settings as found: Terminal · Rose & moss · 1440×1000 — **left as found** (voice restored
to Terminal and read back `1, 0`).

| Voice | Row | Before → after (the first line's / reference rows' ink, pt below the hairline) | Verdict |
|---|---|---|---|
*[removed for publication]*
| Study | her sequence (same) | **29.5 → 29.5 → 29.5** (pre-fix: 29.5 → **5.5**) | **PASS** (`walk/s-her-0*`; pre `pre/s-her-0*`) |
| Study → Terminal | **a voice switch at the page top** (the re-font sibling) | Terminal's resting 27.5 kept (the fix's pin reads 24.0 red-on-old) | **PASS** (`walk/t-refont-at-top`) |
| Terminal | **long note mid-note** (*A Scandal in Bohemia*, 262 blocks; wheel-scrolled so the edge cuts a line; click a blank line mid-page → ⏎ → ⌫) | every row above the act identical across ⏎ and ⌫ (the edge's sliver 0.5–4.0 included); rows below +24 on ⏎ (the act's own block), back on ⌫ | **PASS** (`walk/t-mid-0*`) |
| Study | long note mid-note (edge in a gap) | rows above identical across ⏎ and ⌫; below +30 on ⏎, back on ⌫ | **PASS** (`walk/s-mid-0*`) |
| Terminal | **long note at the tail** (⌘↓ → ⏎ → ⌫) | **⌫ moved nothing**; the ⏎ moved the page **+109 pt** — FINDING B5 below (not the carve; seen on the pre-fix build too) | ⌫ **PASS**; ⏎ → B5 |
| Study | long note at the tail (⌘↓ → ⏎ → ⌫) | ⌫ moved nothing; ⏎ **+166 pt** (B5) | ⌫ **PASS**; ⏎ → B5 |
| Study | long note at the tail on SETTLED geometry (⌘↓, wheel ±3 lines, then ⏎ → ⌫) | all rows identical across ⏎ AND ⌫ | **PASS** (`walk/s-tail2-0*`) |
| Study | **a window resize at the page top** (AX `set size` 1440 → 1300 → 1440 — the non-live road) | the top air kept at 1300; rows identical after the round trip | **PASS** (`walk/s-resize-0*`) |
| — | a LIVE corner drag | NOT walked: the drag point (1437,1114) hit the overlay scroller, not the resize edge (the window's corner sits on the screen's bottom edge); the pin drives AppKit's own live-resize notifications (red-on-old 24.0) | pin only — stated |
| Study (pre-fix build) | the pre-fix tail on settled geometry (⌘↓ → ⏎ → ⌫) | ⌫ moved the page **40.0 pt** (the reading line snapped to the top at a gap edge) | the mid/tail snap, in the app, pre-fix |

**Round trip (add-then-remove): the first line never moved in either voice on the short note**; on the
long note the ⌫ half never moved anything; the ⏎ half is B5 on unsettled geometry only.

### THE SWEEP — finding × mechanism × ATTRIBUTION × disposition

| # | Finding | Mechanism | ATTRIBUTION | Disposition |
|---|---|---|---|---|
| B1 | **Her report** — ⌫ on an empty block at the page top collapses the top air (24.0, both voices) | A7's carve lands through `renderFull`, whose anchor replays offset 0 as "line at the top" | **pre-existing** (R-13y red identically; `02052d8c` + `01e26020` + `7df0795d` + `314ac454`, all before the window) | **FIXED** `998f7d7d` · pins `WriteTopAirTests.removingTheEmptyLastBlockKeepsTheTopAir`, `addThenRemoveLeavesTheFirstLineWhereItWas` · R-full red |
| B2 | Every `seam: nil` structural act (the carve, the delete compound, the cross-block compound, takes↔blocks, the W confirm, a full projection re-render) snaps a scrolled page by the edge's offset in its line (5.0 pins; 40.0 in the app) | the same restore | **pre-existing** (Phase 7's restore; R-13y red) | **FIXED** `998f7d7d` · pins `aMidNoteCarveMovesNothingOnThePage`, `aTailCarveOnALongNoteMovesNothingOnThePage` · R-full red |
| B3 | A LIVE window resize at the page top collapses the air (24.0) | `ScrollAnchorController`'s live-resize restore, the same line-at-the-top replay | **pre-existing** (`02052d8c` + `01e26020`) | **FIXED** `998f7d7d` · pin `aLiveResizeAtThePageTopKeepsTheTopAir` · R-top red |
| B4 | A voice switch (re-font) at the page top collapses the air (24.0) | 13u4 F2's keeper parks offset 0 for the line-at-the-top jump | **our-commit(`4ae12a59`)** (R-F2: pre-F2 road green) | **FIXED** `998f7d7d` · pin `aRefontAtThePageTopKeepsTheTopAir` · R-top red |
| B4b | A NON-live width reflow at the page top | a frame-only change at scroll 0 posts no clip bounds notification; the width branch never runs | — | **DISMISSED AS HOLLOW** (green on both sides; kept as a guard pin, labelled); walked PASS by an AX resize round trip |
| B5 | **⏎ right after a ⌘↓ landing moves the page** (+109 Terminal, +166 Study on the fixed build; +190 on the pre-fix build) — only when a full re-render (or re-font) had invalidated the layout before the ⌘↓; on settled geometry ⏎ moves nothing | NOT TRACED — the typed Return's DIFFERENTIAL road (no restore step), so a TK2 geometry settle: the ⌘↓ landed on estimated heights and the edit's layout pass corrected them under a fixed clip (TEXTKIT2 §2's estimate class) or 27's `layoutViewport()` clip displacement (§3) | **undetermined** — seen on the pre-fix build (not this diff); no 26.x to compare; untraced | **OWNED — PROPOSED:** a KnownIssues row, owner 18l (U-VIS seeds it as a scenario — "⌘↓ after a full re-render, then ⏎"; the trace belongs with U3's `layoutViewport()` examination or its own unit); **not built** (a second mechanism, outside U0b's surface) |
| B6 | **U0c's shape reproduced on the shipped road**: opening *A Scandal in Bohemia* (pre-fix build) landed at the END with ONE line on screen (`pre/s-tail-nav.png`) — the remembered caret was at 262/262 (my earlier ⌘↓), the landing put its line at the top, the typewriter room below | the note-open landing over `CurrentBlockMemory` (R-18l-1's subject) | — (U0c's) | **U0c's session** — recorded, nothing built. Also for U0c: the session anchor across teardown (`scrollAnchors[postID]`) is still an OFFSET, so an in-session re-open of a note left resting in its top air replays offset 0 as "line at the top"; `ReadingAnchor` now exists for it |

### SEAM FILES THIS DIFF TOUCHES (the Fable reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Features/Editor/JumpPrimitive.swift` | NEW pure `ReadingAnchor` (offset · inset · `inPageTopAir`; `exactLandingInset`, `reflowLandingInset`) | `JumpCorrectionLoop`, `FragmentLines`, `lineSpan`, `jump` (its body and every signature), C6's re-assert, C6b's live range |
| `Features/Editor/EditorViewModel.swift` | `readingAnchor()`, `restoreReadingAnchor(_:)`; `keepingReadingPosition` parks the place (`parkAnchorRestore(_:landingInset:)`, default 0); `consumePendingAnchorRestore` jumps with the parked inset | `topVisibleOffset()` (byte-unchanged — C6b's rule), `restoreTopVisibleOffset`, `teardown`'s session anchor, the reveal and carried-placement parks, the storage seam |
| `Features/Editor/EditorSurfaceController.swift` | `renderFull` captures `readingAnchor()` and lands with `exactLandingInset` | the cold mount's saved-anchor branch, the caret by identity, `runStructural`, the carve, the differential road |
| `Features/Editor/EditorView.swift` (`ScrollAnchorController`) | `stableAnchor: ReadingAnchor?`; captures `readingAnchor()`, restores through `restoreReadingAnchor` | the width/live-resize branching, the long-block consideration, the inline editor (U0's) |
| `VariorumTests/WriteTopAirTests.swift` | NEW — 7 tests × 2 voices (her gesture, the round trip, mid-note, tail, non-live width guard, live resize, re-font) | — |

`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `runStructural`: untouched.
Zero `Sources/`, `Sync/`, `Shared/`, schema. No TK1 API (the new read is `JumpPrimitive.lineSpan`,
the existing single-fragment `.ensuresLayout` idiom).

### JUDGMENT CALLS (each reversible in a line)

1. **The full re-render lands EXACTLY, not "line at the top"** — B2 fixed with B1. The brief's own walk
   criterion ("the first line must not move when the act doesn't move it", mid-note and at the tail)
   and the 2026-07-07 decision ("untouched text never moves") are the basis; no ruling makes a
   structural re-render snap. *Reverse by* `landingInset: anchor.reflowLandingInset` in `renderFull`
   (keeps B1's fix, drops B2's).
2. **The re-layout keepers keep the ruled line-at-the-top rule** (13u4 F2, 18k C6b, #147 untouched —
   `RefontGapTopTests` and `RefontViewportTests` ride unmodified and green) **except in the page's top
   air.** Reading that zone as "not a reading position the rule meant to take" is my call, stated for the
   ladder: before the act the first line was 24 pt BELOW the top, so the rule's own promise ("the same
   line at the top") was never true there. *Reverse by* `reflowLandingInset → 0` (R-top's shape).
3. **"The page's top air" = the edge above the text container** (`clipTop < textContainerOrigin.y`):
   geometry no text layout moves, O(1). An edge inside the FIRST line (below 24) is not top air and keeps
   the ruled rule.
4. **B3/B4 fixed inside U0b** (the siblings): the same mechanism on the same surface, one capture rule,
   no extra code beyond consuming it; leaving them would hand her the same symptom through a voice switch.
   Pinned red-on-old, R-top red.
5. **The session anchor across teardown stays an offset** (U0c's road — B6).

### NOTICED, NOT TOUCHED

1. **B5** (⏎ after ⌘↓ on invalidated geometry) — proposed owner above; the orchestrator's KnownIssues edit.
2. **B6** — U0c's session: the note-open end landing reproduced; the Int session anchor.
3. **The carve's caret** lands at the NEXT block's start mid-note (`caretLandingAfterRemoving`), not back
   at the end of the block above — the carve's ruled landing (13c 1B), unchanged; noted only.
*[removed for publication]*
   *[removed for publication]*
   note, ten on *A Scandal in Bohemia*, which is back at 262 blocks). Nothing else changed; the voice restored to Terminal.
5. **Walker fact for `Tools/WalkKit/README.md`** (the orchestrator's): the dev window's bottom-right
   corner sits on the screen's bottom edge at 1440×1000 @ (0,117) on this 1728×1117 screen, so a corner
   drag lands on the overlay scroller — a live resize needs the RIGHT edge (with a guard that admits a
   point just outside the window) or a smaller window first. Also: `osascript` to Finder hung on an
   AppleEvent timeout — avoid it on walks.
6. **`guard.sh` fires on the walker's OWN synthetic input** (HID idle resets on `cliclick`) — wait ≥ 2.5 s
   between steps, as the U0 walk did.

### SELF-ASSESSMENT

Strong: the mechanism is traced and MEASURED (24.0 = the container's inset exactly, both voices, in the
harness and in the app on the pre-fix build); the brief's fork (inset vs scroll offset) is decided by
the pins' numbers; every row has a red-on-old pin, two named behavioural reverts red exactly as
predicted (R-full identical 14; R-top exactly the two keeper pins), and the attribution is per finding
with three discriminating runs (R-13y, R-F2, R-room). The fix adds no scroll machinery — it hands the
place the capture already had to the `landingInset` the jump already takes — and leaves
`topVisibleOffset()` byte-unchanged, so C6b's rule and #147 ride as ruled. Weakest points for the
reviewer: **(a)** judgment call 1 — the full re-render now restores EXACTLY where it used to snap the
reading line to the top; that is broader than her report (B2) and is justified by the brief's own walk
criterion and the 2026-07-07 decision, not by a ruling that names `renderFull`; **(b)** judgment call 2
— reading the page's top air as outside the ruled line-at-the-top rule for the two re-layout keepers
(B3/B4 fixed inside U0b as siblings of one mechanism); **(c)** `readingAnchor()` adds one
single-fragment `lineSpan` per scroll event through `ScrollAnchorController` (a laid-out, on-screen
fragment — P1-bounded, but a new per-scroll cost); **(d)** the live corner drag was not walked (pin
only); **(e)** B5 is real, seen on both builds, untraced — the round trip's ⏎ half on a long note after
⌘↓ still moves the page on invalidated geometry. **U0b — DONE (implementer); the Fable cold review
follows.**

*(DATED NOTE, 2026-09-26, the orchestrator's pen — U-VIS ladder NIT-R2-7 routed here: the U0
record's item-2 sentence "the width fix without the net measured worse … the two must ship
together" stands for what it measured (the width hop ALONE was worse in the app). U-VIS's teeth
runs added the OTHER direction: with ONLY the width door reverted (R-U0-2) and the settle net
kept, both item-2 harness scenarios still PASS — the net alone covers that revert's assertions
at the walked widths. Both facts are true; neither weakens the shipped pair. The measurement is
`notes/plans/18l-uvis-ladder-round1.md`'s MINOR-7 fix table.)*

### U0b — ORCHESTRATOR ACCEPTANCE (the hands-on walk, 2026-09-26 overnight; verify-never-trust)

**Claims verified against git:** commits `b4b978cd…5241d8d4` present and pushed, tree clean, the
pin file exists, LIVE STATUS flipped with hashes and red counts (6 tests / 14 issues red-on-old;
two targeted reverts R-full / R-top red in their own shapes; the hollow width-reflow row
dismissed and kept as a labelled guard — the guard discipline working as written).
**The walk, on a fresh Debug build of `5241d8d4`** (dev store, zero other instances, per-step
*[removed for publication]*
captures' shape) — open in Write (block 2/2) → ⏎ (3/3, empty tail, caret on it) → ⌫ (2/2, the
quiet "Empty block deleted — ⌥⌘Z undoes it" receipt): **the first line's y is IDENTICAL in all
three captures; the top air never moves.** Acceptance captures beside the unit's:
`notes/plans/18l-screens/u0b/u0b-step{0,2}.png`. The note left as found; instance quit.

**Orchestrator adjudications (R-18l-4):** KnownIssues row 87 CLOSED (the ladder-pending re-open
clause, row 86's form); **B5 filed as a NEW KnownIssues row, owner 18l** (⏎ after a ⌘↓ landing
on invalidated geometry moves the page ~+109/+166 pt — on the DIFFERENTIAL road, both builds,
untraced; U-VIS seeds it as a scenario; the trace rides U3's `layoutViewport()` examination or
its own slot — the round decides at U3); **B6 folded into the U0c brief** (the 262/262
remembered-caret reproduction of her shape is CONFIRMED evidence; `ReadingAnchor` now exists for
the in-session reopen restore — the offset-only teardown anchor is U0c's to upgrade); the
walker facts added to the traps (corner drags near the screen's bottom edge land on the
overlay scroller; ≥2.5 s between steps or the guard fires on the walker's own clicks). Ledger
row 4 flips to BUILT+WALKED — the Fable cold review is the remaining gate.

## U0c RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line):** (1) **the build departs from the sitting record's gloss** *"the remembered
caret itself survives (editing state), only the OPENING viewport changes"* — it was built to that
letter first (`5d7c8bb6`) and the walk measured it putting the blank END back on screen at the first
⌘1 (`walk/letter/t-11`); the build now reads R-18l-1 by its supersession sentence (the first open
seeds NO fact) — **flagged for the orchestrator, PROVISIONAL, QUESTIONS #150(a)**; (2) the re-open's
caret reveal is not run when the re-open restored her page — against the brief's "a re-open restores
by the standing machinery" where that machinery contradicts "restores where you were" (`pre-a10`) —
**flagged, #150(b)**; (3) no whole-old-tree bisect (the C7 dev-store trap, as U0/U0b) — attribution
rests on line history + the pre-fix app reproduction + red pins; (4) Takes' transient END report
(the TRACE's (i)) NOT fixed — owner proposed below; (5) Read's first open and the room re-open are
pinned, not walked; the shelf door walked in Terminal only; (6) no KnownIssues / AppSpec / canon
edits — the note-open row's close, the canon line and the R-cor-3 pointer are drafted below for the
orchestrator; (7) zero `Sources/`, `Shared/`, `Sync/`, schema — no core / iOS / mobile runs owed;
(8) the U3 rider (`PaneSurface`'s render restore) and row 85 (O-2) untouched — U0c touches neither.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, SITTING RECORD R-18l-1/2/4/5, ENVIRONMENT TRAPS, the U0 + U0b RECORDs + acceptances); `18l-u0-ladder-round1.md` + `18l-u0b-ladder-round1.md` whole; KnownIssues' note-open row; `TEXTKIT2_NOTES.md` whole; R-Q1/R-Q20/R-Q21 (`use-report-round-2026-09-12.md` §7); 17o batch b's RAISE-M1 record + round-3 R3-1 (`use-report-round-2026-09-06.md`); QUESTIONS #97 · #98 · #116 · #134 · #147 · #149; `SessionResiliencyProtocol.md` (implementer half); the code: `CurrentBlockMemory`, `CommandRouter` whole, `EditorRouter` whole, `EditorViewModel` (teardown, `applyProjection`, `applyFocusSeeds`, the parks + the hop, `topVisibleOffset`/`readingAnchor`, `updateCaretContext`), `EditorSurfaceController.renderFull`, `JumpPrimitive`'s `ReadingAnchor`, `PostDetailView` (mount/registration/`jump(to:)`), `RootView`'s post arm, `ShellRouter` (adopt/park/spend), `WorkspaceModel` whole, `TakesChoreographer.consumeLandings`, `TakesViewModel` (focus/landing/pane reports), `ReadModeView` (seed/select/reports), `BlockTOCView`'s pane report, `BlocksWorkbenchView`/`CanvasViewModel` reports, `BookView.editHere`, `PaneCaretLanding` |
| 2 | Trace the opening-viewport decision per mode | DONE — THE TRACE below (the per-mode opening map) |
| 3 | Reproduce her two shapes (+ what the trace predicts) | DONE — in the app on the pre-fix build (`DerivedData/18l-u0c-prefix`, HEAD `ac52081d` = product code `985371b2`), Terminal: END (Write `pre-a6`, Takes `pre-c2`), MIDDLE (`pre-b4`), the in-session END after scrolling to the top (`pre-a10`); and in the harness (the scratch probe — below) |
| 4 | The END-jump: find the tail writer (or disprove it) — attribution + red-on-old pin | TRACED — the non-click-writer hypothesis is DISPROVED for the single-window app (below); what derives the tail landing is the note-open landing over a caret she left there. The red-on-old pins are the rule's own (piece 6) — PENDING |
| 5 | Build R-18l-1 (first-open set; re-open restore by the standing machinery + the place) | DONE (`5d7c8bb6`) — THE BUILD below; `NoteOpenLandingTests` **11/11 GREEN** on the fixed tree (`App/Variorum/DerivedData/18l-u0c-pin-fixed3.log`); the three behavioural reverts RED in their named shapes (below); the ruled pins' first run green (`18l-u0c-neighbors1.log`, 97 tests / 10 suites: TakesArticleScrollTests (R-Q20/R-Q21), LandingOffsetTests (RAISE-M1), CurrentBlockContinuityTests, ModeSwitchCarryTests, ScrollAnchorTests, WriteTopAirTests, ReadModeTests, CommandRouterTests, TakesLandingTests + the new suite — every one byte-unmodified) |
| 6 | Pins (end-jump red-on-old; first-open / re-open / deep-link per mode; R-Q20/R-Q21 + RAISE-M1 ride unmodified) | DONE — 11 tests (the room pin added at `this commit`); the A/B sections re-shaped at `5d7c8bb6` to the ruled letter (the caret SURVIVES; the viewport opens at the start) — their viewport arms are the red-on-old cores, re-proved by R-open; the two router pins are state-transition pins of the new bookkeeping (new API). The pre-fix run: `NoteOpenLandingTests` (10 tests) committed RED on the pre-fix tree (this commit; `App/Variorum/DerivedData/18l-u0c-pin-prefix1.log`): **8 red / 18 issues**, the 2 guards green — the router's first open restores the earlier run's fact (block 5 @12) and a re-open restores it too; Write's first open: clip **2904.0** (the ⏎ shape — caret 8691/8691), **2880.0** (the last line's end), **1588.0** (the middle); Takes: article clip **1866.0**, the empty last block's pane live; Read: the last block selected, scrolls **[1149, 3819]**; re-open at the top: **24.0**; re-open after scrolling away from a tail caret: **2904.0**; re-open mid-note: left 1391.0 → back **24.0**; the mode-round-trip-after-re-open guard and the deep-link guard green |
| 7 | Walk (both voices; her shapes; first-open vs re-open per door; a deep link) | DONE — PASS on the supersession build (product code `cf5334cf`, build `DerivedData/18l-u0c-walk` at `26d0a5f6`), both voices — THE WALK below |
| 8 | Closing runs (touched suites + the eleven Tutorial suites) | **DONE** on the final product tree (`3c6f7d47`), zero app instances, machine idle (HID 79 s): `App/Variorum/DerivedData/18l-u0c-closing.sh` = U0b's closing set (the jump / anchor / landing / re-font / typewriter family, the structural and seam suites, the editor family, the eleven Tutorial suites) + `NoteOpenLandingTests` + the note-open / landing / workspace / detail consumers (TakesArticleScrollTests — R-Q20/R-Q21 — CommandRoutingTests' suites, ReadModeTests, the Shell/Pane/Window/Workspace/NoteBox/Masthead/BlockHistory/Library panel suites): **✔ Test run with 989 tests in 146 suites passed** (`18l-u0c-closing1.log`), 146 suites counted, 0 skipped (the two `skipped` lines are AppIntents metadata warnings). 1139 `Modifying state during view update` lines — the Takes/pane family's (U3's class): `TakesArticleScrollTests`' neighbour run alone logged 1016, and the new suite logs FEWER on the fixed tree (100) than on the pre-fix one (124). Every ruled pin rode UNMODIFIED — `LandingOffsetTests` (RAISE-M1 + R3-1), `TakesArticleScrollTests` (R-Q20/R-Q21), `CurrentBlockContinuityTests`, `ModeSwitchCarryTests`, `ScrollAnchorTests`, `WriteTopAirTests`. Core / iOS / mobile: not owed |
| 9 | Self-assessment | DONE (below) |

- Deaths / resumes: none.

### THE TRACE (inputs → the opening viewport; every claim read at the code, then measured)

**Who decides the opening viewport, per mode, from what stored fact.** A note opens when a pane's
`PostDetailView` appears (every door — Library, shelf, Open strip, ⌘K, ← →, ⌘⇧n — funnels through
`ShellRouter.adopt` → `WorkspaceModel.select` → the pane's detail) and calls
`CommandRouter.registerDetail`. For a note DIFFERENT from the active one, `registerDetail` seeds the
LIVE fact (`focusedBlock`) from `CurrentBlockMemory.current(for:)` — the session dict, else the
PERSISTED `currentBlock.<id>` (`blockID|variantID|utf16Offset`, written at block changes and when a
note leaves the screen, read at the next launch). Every mode's arrival then reads that one fact:

| Mode | The arrival's landing | Stored inputs |
|---|---|---|
| **Write** | `applyProjection(.initialRender)` reads the fact BEFORE the fill; `applyFocusSeeds`' bare arrival puts the caret at the fact's block start + offset and PARKS `revealLanding` — at the N14 settle hop, if the caret's line is off screen, `JumpPrimitive.jump` puts it at the viewport TOP (#98(a)'s shape) with the typewriter room below | the fact; the session scroll anchor `EditorRouter.scrollAnchors[post]` (session-only, an OFFSET, written at `teardown`; parked by `renderFull`'s cold mount and consumed BEFORE the reveal — RAISE-M1) |
| **Takes** | `TakesChoreographer.consumeLandings`' N9 arm rings the fact's block (`landAuthorityFocus`, the pane's caret at the remembered offset) and `landArticle` REVEALS its row at the nearest page edge (R-Q1); no fact ⇒ the first slot, `.start`, no scroll | the fact; `takesArticlePlaces` + `takesArticleCurrentRows` (session-only — R-Q20/R-Q21 decide restore vs landing) |
| **Read** (both faces) | the rows' first delivery seeds `select(fact's block ?? rows[0], scrollFace: true)` — the edit face lands it CENTERED, the page at 0.08 | the fact (no page memory) |
| **Blocks** | focuses the fact's row (the context panel); no scroll | the fact |
| **Lenses · Compare · Canvas** | no current-block viewport landing (landings are enabled on THE takes board only; Canvas has its own fit-all arrival) | — |

**Her two shapes, reproduced in the app on the pre-fix build** (captures `notes/plans/18l-screens/u0c/pre/`, gitignored):
- **END** — *A Case of Identity* (137 blocks, no memory): ⌘↓ → ⏎ (the segmentation chip ON: an EMPTY
  block 138 below, the caret in it — the note now visibly ends with a newline; `pre-a3`) → quit (by
  identity) → the persisted memory read back by `defaults read`: block 138, offset 0 → relaunch →
  Library → the note: **the empty last line at the viewport top and NOTHING else on screen**
  (`pre-a6`, block 138/138). Put in Takes the same way (`pre-c1`) → relaunch → the board opens at the
  END, block 138's pane live at the foot (`pre-c2`) — *"multiple modes"*.
- **MIDDLE** — *A Scandal in Bohemia*: a click on "I know where it is." (block 199) → quit → relaunch →
  Library → block 199 at the viewport top (`pre-b4`) — the ruled saved-caret landing.
- **The IN-SESSION END (the trace's prediction):** in the same run, *A Case of Identity* scrolled by
  the wheel to its first line WITHOUT a click (`pre-a9`) → the Open strip's other note → back through
  the Open strip → **the END again, the blank screen** (`pre-a10`). The cold mount restored the page
  she left (the top), then the parked reveal found the remembered caret (block 138) off that page and
  jumped to it — *"it's ignoring where I previously was"*, in one session.

**The END-jump's "wrong-stamp writer" hypothesis — DISPROVED for the single-window app.** A scratch
probe (`U0cOpenProbeTests`, never committed: 40-block note × {last block ending in `\n`, an empty
last block, plain} × {Write, Takes, Read}; the real `PostDetailView`, open → wait → leave → re-open,
touching nothing; `DerivedData/18l-u0c-probe1.log`) found **no non-click road that stamps the tail**:
Write's arrival reports block 1 / offset 0 (the fill's end-of-document report is overwritten by the
landing in the same turn — `renderFull`'s `updateCaretContext` then `applyFocusSeeds`), Takes' N9
fall-through reports block 1, Read's seed reports nothing, and every left/re-open leaves the memory
at block 1. Every other writer of `noteFocusedBlock` (Write's caret, the boards' pane caret + ring,
Read's selection + click-through, Blocks' row click, Canvas' card click) follows a click, a keystroke
or a structural act. **What derives the tail landing** is the caret she left there — typing at the
end (the journaling norm), the ⏎ at the end (chip ON: an empty last block holding the caret; chip
OFF: an empty open tail whose caret reports no block, so the memory keeps the last block's END), or a
click in the empty room below the text (which puts an NSTextView's caret at the document end —
*"when i hadn't clicked anywhere in particular"*) — plus the note-open landing over the remembered
caret. **That is why the trailing newline correlates:** the newline and the tail memory are born of
ONE gesture. The two landings that turn it into her screen: (1) across sessions, the note-open
landing at the remembered caret (the one R-18l-1 supersedes); (2) in session, the re-open's parked
caret reveal overriding the restored page (`pre-a10`).

**Two smaller facts the probe measured (recorded, not this unit's surface):** (i) a Takes pane BORN
live reports AppKit's END of its take (`string =` in `makeNSView`) before its `.start` landing
applies, so the PERSISTED copy holds block 1's END (`off 113`) until the note leaves (the leaving
`persist` heals it; only a hard kill keeps it — within block 1, no viewport effect); (ii) an
in-session re-open of a note left at its very top lands 24 pt down (`clip 0.0` → `clip 24.0`): the
teardown anchor is an offset, replayed as "that line at the viewport top" (U0b's B6 hand-forward).

**ATTRIBUTION (the four-value column):**
- **The note-open END/MIDDLE landing across sessions — pre-existing (by design until R-18l-1).** The
  persisted memory + `registerDetail`'s restore: `c174d194` (2026-09-01, the correction round batch C,
  rows 39/49); the offset inside the block: `a0aade08` (2026-09-07, 17o b, U-20); the reveal:
  `d3bcbd33` (2026-09-07); Takes' article landing: `68632d31` (2026-09-07). All before the
  13u2…18k window; macOS-independent (a stored fact and a jump's arithmetic). Her build (13y or 18k)
  makes no difference.
- **The in-session re-open END — pre-existing.** The cold mount restores the anchor exactly since
  `c60d1d66` (2026-09-07, RAISE-M1) and the reveal runs at every remembered landing since `67fdced1`
  (2026-09-08, 17o d row 47); before those the anchor clamped at ~24 pt and the reveal still jumped to
  the caret. Before the window; macOS-independent.
- **The re-open's lost top air — pre-existing** (`02052d8c` Phase 7's offset anchor + `01e26020`
  13c 1A's inset conversion + `c60d1d66`'s exact cold-mount restore; U0b's B6).

### THE BUILD — R-18l-1 as ruled: the caret survives, only the OPENING's viewport changes

**The note's OPENING, recorded where the fact is restored** (`CommandRouter.registerDetail`): a
per-app-run set `notesOpenedThisRun` (in memory — never persisted, never synced) and a
`NoteOpening` value beside the restored fact: `isReopen` (the run had opened the note before),
the registered `mode`, the `seeded` fact, and `seededThisRun` (the session memory held it — vs a
place an earlier run persisted, `CurrentBlockMemory.sessionFact`). **The restored fact is
byte-unchanged** — the remembered caret survives as editing state, her R-cor-3's *"the place
where your cursor was saved"* with it. `openingLanding(postID:fact:)` answers "is this arrival
the opening's own landing?" — the opening's note AND the very fact it seeded (a place reported
since the note arrived is a place someone chose, and lands by the standing rules); a mode switch
ends the opening (`noteMode`, the registration's own mode reported back keeps it), and so does
the detail leaving. Every door reaches `registerDetail`, so the rule is door-agnostic.

**Per mode — the VIEWPORT only, each an outrank ABOVE the standing landing, never an edit inside it:**
- **Write** (`applyFocusSeeds`' bare arrival): an opening landing parks NO caret reveal. The page
  is the one this run left for the note — the cold mount's parked session place — else the
  note's start (nothing parked: the page rests in its top air). The caret still lands at the
  remembered place.
- **Takes** (`TakesChoreographer.consumeLandings`' N9 arm): the ring still lands on the current
  block; an opening landing asks for no `landArticle` — the article is R-Q1's restored place this
  run (R-Q20/R-Q21's step machine untouched), else the top.
- **Read** (the seed): the current block is still selected; an opening landing scrolls to it only
  when it is THIS run's place (Read keeps no page of its own — on a re-open this run's current
  block IS where she was).
- **Blocks · Lenses · Compare · Canvas**: no current-block viewport landing exists — unchanged.

**The page she left, WITH ITS PLACE** (U0b's `ReadingAnchor`, handed forward by B6):
`EditorRouter.scrollPlaces` (session-only) replaces the offset-only anchor; `teardown` writes
`readingAnchor()` — or, for a page resting in the typewriter room below the last line (no reading
line there), `placeBelowTheLastLine()` (the last line and its negative inset) — and only for a
LOADED full-document editor (a transient mount or an inline editor never erases the page's
editor's place); `renderFull`'s cold mount (and its warm fallback) restores `exactLandingInset`.
`scrollAnchors` survives as an offset-only facade over it (the RAISE-M1 pins seed through it and
ride unmodified; an offset lands at inset 0 — exactly as before).

**THE BEHAVIOURAL REVERTS (named before they run; the pre-revert state is `5d7c8bb6`):**
- **R-open** — `CommandRouter.openingLanding` answers nil always (the opening arm off; every mode
  lands its opening by the standing reveal). Expected RED: Write's three first opens (clip at the
  remembered line), Takes' first open (the article at the end), Read's first open (scrolled), the
  re-open after scrolling away (the END), the re-open mid-note (the reveal to block 1), and the two
  router pins' `openingLanding` arms; GREEN: the re-open at the top (the place alone keeps it), the
  two guards.
- **R-place** — `teardown` stores the place with its inset thrown away (`inset: 0, inPageTopAir:
  false` — the old offset anchor). Expected RED: the re-open at the top (24.0) and mid-note (the
  line snapped, ~7 pt); everything else GREEN.
Each is a working-tree edit only, then `git checkout HEAD --` the file and `git status` clean.

**THE REVERTS, RUN (each restored with `git checkout HEAD --`, `git status` clean):**
- **R-open** (`18l-u0c-R-open.log`): **RED — 7 tests / 8 issues, exactly the predicted shapes**:
  Write's three first opens at clip **2904.0 / 2880.0 / 1588.0** (the pre-fix numbers, identical),
  Takes **1866.0**, Read **[1149, 3819]**, the re-open after scrolling away **2904.0**, the
  re-open mid-note **1391 → 24.0**, and the first router pin's `openingLanding` arm; GREEN: the
  re-open at the top (the place alone keeps it — as predicted), both guards, and the second router
  pin (it asserts the opening's record, not its landing — my prediction listed it; it has no
  `openingLanding` arm).
- **R-place** (`18l-u0c-R-place.log`): **RED — 3 tests / 3 issues**: the re-open at the top
  **24.0**, mid-note **1391 → 1384 (7.0)** as predicted, and — beyond the prediction, the same
  mechanism — the scrolled-away re-open's page lands at **24.0** (its page was the top: the air
  eaten). Everything else green.
- **R-room** (`18l-u0c-R-room.log`, the room's place dropped from `teardown`): the new
  `aReopenOfANoteLeftRestingBelowItsLastLineComesBackThere` **RED — back 0.0** (the note's top)
  where the fixed tree comes back at **2880.0** (the last line at the viewport top; she left the
  page at 3017.0, and at the re-open's settle hop the room's maximum scroll is the last line's top —
  the jump's live clamp; the pin asserts the END, never the start, and says why).

### THE WALK'S FIRST PASS FOUND THE LETTER-READING WRONG — and the build returned to the supersession reading (Terminal, the fixed build `5d7c8bb6`)

The first walk pass (Terminal, fresh launch, captures `18l-screens/u0c/walk/`, gitignored) passed
every opening row (these captures now live in `walk/letter/`): Scandal's first open from the Library at its START with the caret remembered at
block 199 (`t-01`; pre-fix `pre-b4` landed block 199 at the top), A Case of Identity's first open at
its START (`t-02`; pre-fix `pre-a6`, the blank END), the page left mid-note → the Open strip's
other note → back: both re-opens **pixel-identical** to the pages left (`t-04` = `t-01`, `t-05` =
`t-03`, a text-body diff with an empty bounding box), ⌥⌘[ / ⌥⌘] the same (`t-06`, `t-07`), the Blocks
panel's *open in Write* (a deep link) landing block 199 at the top (`t-09`), and Takes' first open
at the top (`t-10`; pre-fix `pre-c2`, the END). **Then ONE ⌘1 from that Takes first open landed
Write on the blank END** (`t-11`): the letter-reading kept the remembered caret (block 138, the
empty last block) as the live fact, and a MODE SWITCH is not an opening — every mode enters on the
current block and Write reveals it (#98(a)). Her report, one keystroke later.

**So the build now reads R-18l-1 by its supersession sentence** — *"This SUPERSEDES the
every-door-into-Write-lands-at-the-caret rule (17o) for the NOTE-OPEN act"*, and that 17o rule is
exactly *"every door into Write lands at the REMEMBERED CARET OFFSET … and the arrival REVEALS it"*
(`LandingOffsetTests`' header): the session's FIRST open of a note seeds NO fact, so every mode
arrives as a note with nothing remembered does (Write's caret AND page at the start; Takes' first
slot; Read's first row) and whatever she does next is what the memory follows — a mode switch
included. A RE-open restores THIS run's fact only (`CurrentBlockMemory.sessionFact`), never an
earlier run's. The memory machinery itself survives untouched (persisted, restored on re-opens,
read by the book's edit-here door and the panes' entry caret) — the sense in which I read *"the
remembered caret itself survives (editing state)"*. **This is a PROVISIONAL call against the
sitting record's gloss, flagged for the orchestrator** (QUESTIONS #150(a) carries both readings
with `t-11` as the measured reason). Her earlier R-cor-3 (the Library peek's *"the place where your
cursor was saved"*) is superseded for the session's first open by the same ruling — flagged for
canon hygiene. The opening machinery (`NoteOpening`, `openingLanding`) is unchanged and still
decides the re-open arm (the page she left wins over a caret reveal).

**THE SUPERSESSION BUILD (this commit) — pins and reverts:** `registerDetail` seeds nothing on the
run's first open and only `sessionFact` on a re-open; `NoteOpening.seededThisRun` retired (a seeded
fact is now always this run's; Read scrolls on an opening landing iff `seeded != nil`). The pin
file's A/B sections are back to the start-landing expectations (`fe4473bf`'s, whose pre-fix run is
their red-on-old evidence: 8 red / 18 issues) plus the opening-record arms, and a new pin pins the
walk's finding — `aModeSwitchRightAfterAFirstOpenStaysAtTheStart` (Takes first open → ⌘1 → Write
at 0.0). **`NoteOpenLandingTests` 12/12 GREEN** (`18l-u0c-pin-fixed5.log`). **R-letter** (the
first open seeding `current(for:)` again — the letter-reading, one line, `18l-u0c-R-letter.log`):
**RED 7 tests / 16 issues** — both router pins, Write's three first opens on the caret arm (8691 /
8690 / 4926 where 0 is owed — their clip arm stays 0.0, the opening's no-reveal), Takes (no live
pane at the top: the ring sits on the unrealized last block), Read (the last block selected,
scrolled [1149, 3819]), and **the mode-switch pin: Write clip 2904.0** — `t-11`'s blank END,
reproduced in the harness; the re-open and guard pins green.

**Machinery honesty (a mistake, caught and repaired in the same minute):** the R-letter revert's
`git checkout HEAD -- CommandRouter.swift` restored the COMMITTED file over the uncommitted
supersession edits (the trap the resiliency protocol names). The four edits (the seeding + its
comment, `NoteOpening`'s field, two docs) were re-applied from this session's own record of them
and re-verified: 12/12 green on the re-applied tree (`18l-u0c-pin-fixed5.log`). Every later revert
runs only on a COMMITTED tree.

**R-open, re-run on the committed supersession tree** (`18l-u0c-R-open2.log`; its first run above
was on the letter build): **RED 4 tests / 4 issues — the re-open arm exactly**: the router pin's
`openingLanding` arm, the scrolled-away re-open **2904.0**, mid-note **1391 → 24.0**, the room
re-open **24.0** (the reveal to block 1 wins over the room's place); the first-open pins GREEN under
it (that arm is the seeding — R-letter's). R-place and R-room stand as run (their mechanism, the
teardown place, is unchanged by the seeding). QUESTIONS #150 rewritten to the built reading, (a)
carrying the letter-reading as the alternative with `t-11` as the measured reason.

### THE WALK (USE) — the supersession build, dev-store Debug, per-step guarded, both voices

Build `App/Variorum/DerivedData/18l-u0c-walk` at `26d0a5f6` (product code `cf5334cf`). Each session
is a FRESH LAUNCH (a new run: every note's first open). Staged by the local preferences only (the
WalkKit appearance-staging precedent): *A Case of Identity*'s mode (`postMode.<id>`) and, before
the Takes rows, its persisted memory re-set to the empty last block 138 (the ⏎-at-the-end shape an
earlier session leaves). "Identical" = a text-body crop diff with an EMPTY bounding box, or the
text-row tops measured equal. Captures `notes/plans/18l-screens/u0c/walk/` (gitignored); the pre-fix
repros `…/u0c/pre/`; the letter-reading pass `…/u0c/walk/letter/`.

| Voice | Door · row | Result | Verdict | Captures |
|---|---|---|---|---|
| Terminal | **Library → *A Scandal in Bohemia*** (first open; remembered caret block 199 — the MIDDLE shape) | the START, top air showing, block 1/262 (pre-fix: block 199 at the top) | **PASS** | `t-01` (pre `pre-b4`) |
| Terminal | **Library → *A Case of Identity*** (first open; remembered caret the empty last block — the END shape) | the START, block 1/138 (pre-fix: the empty last line alone on a blank screen) | **PASS** | `t-02` (pre `pre-a6`) |
| Terminal | Case wheel-scrolled mid-note (no click) → **Open strip → Scandal** (re-open) | the page she left — IDENTICAL to `t-01` | **PASS** | `t-03`, `t-04` |
| Terminal | **Open strip → Case** (re-open) | the mid-note page she left — IDENTICAL to `t-03` | **PASS** | `t-05` |
| Terminal | **⌥⌘[ → Scandal, ⌥⌘] → Case** (history = re-open, #150(c)) | both IDENTICAL to the pages left (bodies and titles) | **PASS** | `t-06`, `t-07` |
| Terminal | **Shelf → today's entry** (first open — it minted today's journal note) → Open strip → Case → **Shelf → today's entry** (re-open) | the new note at its start; Case IDENTICAL on the way through; the re-open IDENTICAL | **PASS** | `t-08`, `t-09`, `t-10` |
| Terminal | **a deep link** — Scandal ▸ Blocks, row 13 ▸ the panel's *open in Write* | block 13 at the top, its ring on — the target, unchanged | **PASS** | `t-11a`, `t-11` |
| Terminal | **Takes: Library → Case** on a fresh launch (first open, remembered caret the empty last block) → **⌘1** | Takes at the top with block 1's pane live; ⌘1 → Write at the START, block 1/138 (the letter build: the blank END — `letter/t-11`) | **PASS** | `t-12`, `t-13` (pre `pre-c2`) |
| Terminal | **her in-session END** — Case ⌘↓ (the caret at the end), wheel back to the top, Open strip away → back | the top page she left (text rows 368/402/436 = the first open's; 0.5 pt from the wheel's own settle), the caret still block 138/138 | **PASS** | `t-14a`, `t-14`, `t-15` (pre `pre-a10`) |
| Study | Library → Scandal (first open; remembered caret block 13) | the START, block 1/262 | **PASS** | `s-01` |
| Study | Library → Case (first open; remembered caret the empty last block) | the START, block 1/138 | **PASS** | `s-02` |
| Study | Case mid-note → Open strip → Scandal → Open strip → Case → ⌥⌘[ | every re-open IDENTICAL to the page left | **PASS** | `s-03`…`s-06` |
| Study | her in-session END (Case ⌘↓, read back to the top, away, back) | the top page, rows identical to the first open's (166/203/384); caret block 138/138 kept | **PASS** | `s-07`, `s-08` |
| Study | a deep link — Scandal ▸ Blocks ▸ double-click row 13 | block 13 at the top — unchanged | **PASS** | `s-09a`, `s-09b`, `s-09` |
| Study | Takes: Library → Case on a fresh launch (first open, the END shape) → ⌘1 | Takes at the top, block 1 live; ⌘1 → Write at the START | **PASS** | `s-10`, `s-11` |

**Not walked (pin only, stated):** Read's first open (`readOpensAtTheStart`, both faces' scroll
views measured 0.0), a page left resting in the typewriter room (`aReopenOfANoteLeftRestingBelowItsLastLineComesBackThere`),
the shelf door in Study (the same registration road as Terminal's). **Walk residue in the dev
store, deliberate:** *A Case of Identity*'s empty block 138 (my repro's ⏎) was carved back at the
end (`s-12` → `s-13`: 137/137, the tray ⌫ 1); today's entry minted an empty journal note
**2026-09-26**; the memories of Case / Scandal moved with the walk. The voice restored to Terminal
and read back (`1, 0`); every dev instance quit by identity; `pgrep` clean.

### FINDINGS — mechanism × ATTRIBUTION × disposition

| # | Finding | Mechanism | ATTRIBUTION | Disposition |
|---|---|---|---|---|
| C1 | **Her report** — a note's first open (a new session) lands at the caret an earlier session left: the END with one line / a blank screen after ⏎ at the end; the Sherlock MIDDLE; in Write, Takes and Read | `registerDetail` seeds the live fact from the PERSISTED memory; every mode's entry landing reveals it (Write's `revealLanding` → the line at the top; Takes' `landArticle`; Read's scroll) | **pre-existing** — by design until R-18l-1 (`c174d194` 2026-09-01; `a0aade08` · `d3bcbd33` · `68632d31` 2026-09-07), all before the 13u2…18k window; macOS-independent | **FIXED** `cf5334cf` · pins `theRunsFirstOpenOfANoteRestoresNothingAnEarlierRunLeft`, `writeOpensAtTheStart` ×3, `takesOpensAtTheStart`, `readOpensAtTheStart`, `aModeSwitchRightAfterAFirstOpenStaysAtTheStart` · pre-fix RED 8/18 (`fe4473bf`'s run), R-letter RED 7/16 |
| C2 | **Her in-session END** — a re-open after reading back up from a caret at the end lands at the end again (`pre-a10`) | the cold mount restores the page, then the parked caret reveal (#98(a)) jumps to the caret off that page | **pre-existing** (`c60d1d66` + `67fdced1`, 2026-09-07/08) | **FIXED** `5d7c8bb6` (`openingLanding`) · pins `aReopenAfterScrollingAwayFromTheCaretComesBackToThePageSheLeft`, `aReopenMidNoteComesBackToThePageExactly` · R-open2 RED 4/4 |
| C3 | A re-open of a page left at its top loses the 24-pt top air; mid-note it snaps by the edge's cut | the teardown anchor was an OFFSET replayed as "line at the top" (U0b's B6) | **pre-existing** (`02052d8c` + `01e26020` + `c60d1d66`) | **FIXED** `5d7c8bb6` (`EditorRouter.scrollPlaces`, `ReadingAnchor.exactLandingInset`) · pins `aReopenOfANoteLeftAtItsTopKeepsTheTopAir` + mid-note · R-place RED 3/3 |
| C4 | A page left resting in the typewriter room re-opens at the note's TOP | no reading line in the room ⇒ no anchor saved | **pre-existing** (the A22 batch-5 nil) | **FIXED** `5d7c8bb6` (`placeBelowTheLastLine`) · pin `aReopenOfANoteLeftRestingBelowItsLastLineComesBackThere` · R-room RED (0.0) |
| C5 | The "non-click writer stamps the tail" hypothesis | — | — | **DISPROVED** (THE TRACE — the no-click probe; every writer of the fact enumerated) |
| C6 | A Takes pane BORN live reports AppKit's END of its take before its `.start` landing, so the PERSISTED memory holds that END until the note leaves (a hard kill keeps it) | `makeNSView`'s `string =` notifies the selection before `noteLiveness` applies the landing | **pre-existing** (#97's class, 17o b) | **NOT FIXED — OWNED, PROPOSED U2** (Takes' landing half, the Fable-reviewed pane landing unit) or 12; no viewport effect (within the landing block; healed by the leaving `persist`) |
| C7 | The letter-reading build's mode-switch END (`walk/letter/t-11`) | the surviving caret is what a mode switch enters on | **our-commit(`5d7c8bb6`)** — this unit's own first build, never installed | **FIXED** `cf5334cf` · pin `aModeSwitchRightAfterAFirstOpenStaysAtTheStart` (R-letter RED: Write clip 2904.0) |

### THE OPENING-LANDING MAP, AFTER (per mode)

| Mode | The run's FIRST open | A RE-open this run | A mode switch / deep link |
|---|---|---|---|
| Write | caret + page at the start (top air), no reveal | the page she left, exactly (`scrollPlaces`), her caret where she left it, no reveal; no page ⇒ the standing reveal | standing (RAISE-M1 anchor — now exact — then #98(a)); deep links reveal their targets |
| Takes | the first slot rung, the article at the top | the ring on her block, the article at R-Q1's restored place (no landing asked) | standing (N9 + reveal; the bloom arm) |
| Read (both faces) | the first row, no scroll | scrolls to this run's current block | standing (carry / fact / click-through) |
| Blocks · Lenses · Compare · Canvas | unchanged (no current-block viewport landing; Blocks focuses no row with no fact) | unchanged | unchanged |

### SEAM FILES THIS DIFF TOUCHES (the Fable reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Registry/CommandRouter.swift` | `registerDetail`: the per-run `notesOpenedThisRun` set; the first open seeds NO fact, a re-open `sessionFact`; `NoteOpening` + `openingLanding(postID:fact:)`; `noteMode` ends the opening on a switch; `unregisterDetail` clears it; two docs | `noteFocusedBlock`, `currentBlock(for:)`'s body, the carry, the parcels |
| `Registry/CurrentBlockMemory.swift` | `sessionFact(for:)`; the header | `current`, `remember`, `persist`, `forget`, the persisted format |
| `EditorRouter.swift` | `scrollPlaces: [String: ReadingAnchor]`; `scrollAnchors` an offset-only facade over it | `takesArticlePlaces`, `takesArticleCurrentRows` |
| `Features/Editor/EditorViewModel.swift` | `teardown` writes the place (loaded full-document editors only; the room as `placeBelowTheLastLine`); the bare arrival skips the reveal on an opening landing; `parkAnchorRestore`'s doc | `topVisibleOffset`, `readingAnchor`, `restoreReadingAnchor`, the parks' consumers, the hop order, `revealLanding` |
| `Features/Editor/EditorSurfaceController.swift` | `renderFull`'s saved-anchor branch restores `exactLandingInset` (cold park and warm jump) | the live `readingAnchor` branch, the caret by identity, `runStructural`, the differential road |
| `Features/Takes/TakesChoreographer.swift` | the N9 arm asks no `landArticle` on an opening landing | the bloom arm, `landAuthorityFocus`, `TakesArticleScroll`'s step machine, R-Q20/R-Q21 |
| `Features/ReadMode/ReadModeView.swift` | the seed scrolls on an opening landing only when it restored this run's place | `select`, the carry, the click-through, `landIfPending` |
| `Features/Library/LibraryCatalogView.swift` · `LibraryInfoPanel.swift` | docs only | — |
| `VariorumTests/NoteOpenLandingTests.swift` | NEW — 12 tests | — |

`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `JumpPrimitive`: untouched.
Zero `Sources/`, `Shared/`, `Sync/`, schema. No TK1 API (the one new layout read is
`JumpPrimitive.lineSpan` at teardown — single-fragment, P1).

### JUDGMENT CALLS (each reversible in a line)

1. **The run's first open seeds NO fact** (the supersession reading) — *reverse by* `let restored =
   currentBlocks.current(for: postID)` in `registerDetail` (the letter-reading; `walk/letter/t-11`
   is its measured cost). QUESTIONS #150(a). Against the sitting record's gloss — FLAGGED.
2. **A re-open's page wins over an off-page caret** (no reveal on an opening landing) — *reverse by*
   dropping `!isOpeningLanding` in `applyFocusSeeds`. #150(b). Scope: note-open only — the
   mode-round-trip guard pin keeps #98(a) there.
3. **A re-open restores THIS run's fact only** (`sessionFact`) — #150(e).
4. **Every cold mount restores the page EXACTLY** (`exactLandingInset`) — mode round trips included
   (the line where it sat, not snapped to the top: ≤ one line's difference; #116's carry still
   outranks). *Reverse by* `reflowLandingInset` in `renderFull`'s saved branch.
5. **The room re-opens at the end** (the last line's place, clamped at the hop's live maximum) — #150(d).
6. **`scrollAnchors` kept as an offset-only facade** so the RAISE-M1 pins ride byte-unmodified.
7. **An opening's own landing = an arrival on exactly the seeded fact** — a place reported since the
   note arrived lands by the standing rules (which is also what keeps the RAISE-M1 / R3-1 rigs, which
   register and then report, on the standing road).
8. **Only a loaded full-document editor writes the page at teardown** — a transient mount (a detail
   opening in another mode mounts Write for a beat) or an inline editor never erases it.
9. **← → is a re-open** (#150(c)) — by construction (any re-registration of a note already opened).

### NOTICED, NOT TOUCHED

1. **C6** (Takes' transient END report) — proposed owner U2 (or 12). 2. **Two windows share ONE
   `activePostID`** (the router is session-scoped): with a note window open, the other window's note
   reports nothing, so its memory freezes — the recorded two-windows keying family; not investigated.
3. **`LandingOffsetTests`' header** still states 17o's "ONE rule: every door into Write lands at the
   REMEMBERED CARET OFFSET" — true for every door but the note-open since R-18l-1; a ruled pin's doc,
   left byte-unmodified (the orchestrator's edit if wanted). 4. **The Library's search** found no hit
   for "Persian" (a word in *A Case of Identity*'s last block) in either scope on the walk, and the
   scope's segmented control did not take `cliclick` — not investigated (walk tooling or search; not
   this unit's surface). 5. **The book's edit-here door** (`BookView.editHere`) still lands the
   remembered block — an in-book editing door that names its place, not a note-open (kept by design;
   the orchestrator may classify it otherwise).

### OWED AT CLOSE (drafted for the orchestrator)

- **AppSpec §12** (a contract line + pointer): *"Opening a note (R-18l-1, 18l U0c — the plan file's
  U0c RECORD): the session's first open shows the start in every mode (the note-open door no longer
  lands at the remembered caret — 17o's rule is superseded for this act); a re-open this session
  restores the page she left (Write's session place with its inset, Takes' R-Q1 place, Read's
  this-run current block), never revealing a caret off it; ← → and every door into a note already
  opened this session is a re-open; deep links keep their targets. QUESTIONS #150."*
- **KnownIssues**: the note-open row → CLOSED at 18l U0c (with the ladder-pending re-open clause, as
  rows 86/87).
- **R-cor-3** (the Act 10 correction round's Library peek, *"the place where your cursor was
  saved"*): a dated pointer that R-18l-1 supersedes it for the session's first open.
- **MOBILE PARITY**: the phone's note open is its own (PL-22's family) — R-18l-1 wants a
  `notes/MobileSoul.md` row (the mobile project's).

### SELF-ASSESSMENT

Strong: the mechanism is traced per mode and REPRODUCED in the app on the pre-fix build in both of
her shapes (and a third, in-session, that the trace predicted); the wrong-stamp hypothesis is
disproved by a probe rather than assumed; every fix has a red-on-old pin and a named behavioural
revert that went red in its predicted shape (R-letter 7/16, R-open 4/4, R-place 3/3, R-room); the
ruled pins ride byte-unmodified (989 / 146 green); the walk is use-shaped, per-step guarded, both
voices, and it CAUGHT the first build's reading error before a reviewer or she did. Weakest points
for the reviewer: **(a)** judgment call 1 departs from the sitting record's gloss — the evidence is
`t-11` and the ruling's own supersession sentence, but it is a call the orchestrator should
confirm; **(b)** judgment call 2 departs from the brief's "standing machinery" phrase for re-opens
(the caret may sit off screen after a re-open until she types — #98(c)'s trade, scoped to
re-opens); **(c)** judgment call 4 changes mode-round-trip landings by up to a line (exact instead of
snapped); **(d)** the room restore clamps at the hop's live maximum (the end, not the exact room
offset); **(e)** the pins share `UserDefaults.standard` with the test host (post id "0", cleaned on
`defer`, the R1-7 class); **(f)** attribution is by line history (the C7 trap); **(g)** a machinery
slip mid-unit (a revert's `git checkout HEAD --` over uncommitted edits) — repaired and re-verified
within minutes, recorded above. **U0c — DONE (implementer); the Fable cold review follows.**

### U0c — ORCHESTRATOR ACCEPTANCE (the hands-on walk, 2026-09-26 overnight; verify-never-trust)

**Claims verified against git:** all 11 commits present and pushed, tree clean, the pin file and
#150 exist, LIVE STATUS fully flipped, the reverts' logs named. **The walk, on a fresh Debug
build of `aa317d99`** (dev store, per-step guard via the now-durable `Tools/WalkKit/guard.sh`):
- **First open → START, PASS.** *A Scandal in Bohemia*, first open this run from the Library:
  block 1/262, the page at its very top — the persisted MIDDLE caret (this orchestrator's own U0
  walk left it mid-note) did not move the viewport.
- **In-session re-open → the exact page, PASS.** Wheel-scrolled deep into the note, left to the
  Library (captured — the leave is evidenced), re-opened: the same page, same first line.
  Captures `notes/plans/18l-screens/u0c/u0c-{firstopen,scrolled,mid-library,reopen2}.png`.

**The two PROVISIONAL judgment calls — CONFIRMED by the orchestrator under R-18l-4** (the
reviewer weighs them independently): (1) the supersession reading (a first open seeds NO fact) —
the evidence is measured and pinned (`t-11`; R-letter red 7/16), and a start that evaporates one
⌘1 later is not the START her sentence asked for; (2) the re-open restores the PAGE without
revealing an off-page caret — "restores where you were" read literally. Both ride QUESTIONS
#150 for her morning bundle. The book's `editHere` door's classification (an in-book editing
door naming its place, not a note-open) is also confirmed.

**Orchestrator adjudications:** the KnownIssues note-open row CLOSED (ladder-pending clause,
rows 86/87's form); **the R-cor-3 dated pointer landed** (the Act 10 plan — the Library peek's
"place where your cursor was saved" superseded for the session's first open); the Takes-born-live
persisted-END residue OWNED (ledger row 8's cell — U2 may-take, else 12 at the closeout); the
AppSpec §12 contract line and the MOBILE PARITY row ride the CLOSEOUT as drafted in OWED AT
CLOSE. The machinery slip (a revert's `git checkout HEAD --` over uncommitted edits — the exact
class the resiliency protocol's addendum 11 names) was self-repaired and recorded; noted here so
the next brief's traps line lands with emphasis. Ledger row 5 flips to BUILT+WALKED — the Fable
cold review is the remaining gate.

## U-VIS RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line):** (1) **B5 (row 88) NOT traced** — the harness seeds it on two roads and MEASURED it (below), but the trace is row 88's owner's (U3's `layoutViewport()` exam or its own slot); (2) the WalkKit README / ENVIRONMENT TRAPS / KnownIssues edits the incident and the measurements call for are drafted under OWED, not made (the orchestrator's pen); (3) **the stale TCC prompt is still on screen, unanswered** — hers (below); (4) no phone scenarios (the design note's own exclusion: no phone driver road); (5) no pixel baselines (excluded by design); (6) core / iOS / mobile runs not owed — zero `Sources/`, `Shared/`, `Sync/`, schema.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (own context, the brief's order) | DONE — this file whole (HER KICKOFF MESSAGE, SITTING RECORD, ENVIRONMENT TRAPS, the U-VIS DESIGN NOTE + BRIEF, the U0 · U0b · U0c RECORDs + acceptances); the charter's U-VIS section (`post-13u-health-rounds.md` KICKOFF 2); `Tools/WalkKit/` whole (README, `guard.sh`, `click.sh`, `keys.sh`, `wl2.swift`, `capture-windows.swift`, `scroll.swift`); 18k UNIT C4 brief + record + adjudication (the owner-keyed shape); KnownIssues rows 35 (the in-process click rig) · 88 (B5) · 89 (pointer injection); `TEXTKIT2_NOTES.md` whole; `SessionResiliencyProtocol.md`; the code the probe reads (`JumpPrimitive`/`FragmentLines`/`ReadingAnchor`, `EditorViewModel.topVisibleOffset`, `PaneMeasurement`, the settle net's O(1) last-fragment read, `BookIndexGeometry.paneReadTierFrames`, `ReadModeOracle`, `IndexClickCaretTests`' click geometry, `CommandRouter.activeMode`, `VariorumAppDelegate`) |
| 2 | The oracle endpoint (DEBUG, env-gated, pull-only) | DONE (`e949e2a1`, grown `8ac80daf`) — `Core/Views/VisualWalkProbe.swift` + one DEBUG line in `VariorumAppDelegate`; verified against captures (coordinates exact to the point) |
| 3 | `Tools/VisualWalk/` — driver, scenario table, report, env gate | DONE (`5e79c641`, fixed `8ac80daf`) — every scenario ran end to end in Terminal; the foreign-dialog rule added after the incident below |
| 4 | The seeded scenarios | DONE (`8ac80daf` … `cc23b016`) — ten: the design note's list (typing · U0b's newline round trip · U0's two clicks · narrow→restore · divide + merge · mode round trip · U0c's first open / re-open) + B5 on two roads; both voices in piece 6 |
| 5 | The self-test RED (caught, captured, reported non-zero) | **DONE, both halves.** (a) THE PLANTED FAILURE: `--selftest` (a knowingly wrong expectation) → FAIL, two captures, report, **exit 1** (`vis-walks/2026-09-26/112606-selftest/`). (b) THE TEETH — **R-full-scratch** (named before it ran, `b11d1cf4`): U0b's R-full (`readingAnchor()` captures `inset: 0`) applied ONLY in a scratch worktree at `4ccfd13c` with its own derived data, the harness pointed at it by `VW_DD`: **`write-newline-roundtrip` RED — ⌫'s first line 298.0 → 274.0 (−24.0) and clip 0 → 24.0, her report's collapse exactly (U0b measured 24.0); `note-reopen` RED — the re-open snapped the line (offset 11536 → 11458, y 287.0 → 274.0), U0c's C3 shape; exit 1** (`vis-walks/2026-09-26/112830/`). Worktree removed (`git worktree list`: the two standing ones), the main tree clean throughout |
| 6 | The full seeded run on the current tree, both voices, evidenced | **DONE** — THE FINAL RUN, through the wrapper (below): `vis-walks/2026-09-26/114921/` on tree `17bed3e2` (product code `8ac80daf`): **20 scenario-passes, 0 FAIL, 0 ERROR** — PASS 12 · XFAIL 4 (S3 ×3, B5 ×1 in Study) · XPASS 4 (B5 ×3, S3 ×1) — THE TABLE below. The first run (`113042/`, tree `d5162751`) is the same shape with B5 Study reported as FAIL (before the relabel): identical B5 numbers ±0.3 pt |
| 7 | The env-flag wrapper test (`VARIORUM_VISUAL_WALK=1`) | **DONE** (`cc23b016`) — `Tools/VisualWalk/Package.swift`, its own package. Unset: `✔ Test run with 2 tests in 1 suite passed`, BOTH `skipped:` with the reason. Set (`App/Variorum/DerivedData/18l-uvis-wrapper-final.log`): `✔ Test theHarnessCanRed() passed after 18.334 seconds` (the self-test exited 1 — `114902-selftest/`) · `✔ Test theSeededWalkPasses() passed after 836.575 seconds` · `✔ Test run with 2 tests in 1 suite passed after 854.910 seconds` |
| 8 | Closing runs (the app suites the diff could reach + the Tutorial suites) | **DONE** on the final product tree (`8ac80daf`; nothing app-side changed after), zero app instances, machine idle: the eleven Tutorial suites + the app's source-walk pins (`ChromeLineLimitTests`, `OneInputPathTests`, `NoLiteralColourTests`, `MarkdownPaletteWritersTests`, `StatusSeamVocabularyTests`, `SnapshotPairTests`) + C4's oracle suites the probe reads (`DebugOracleOwnershipTests`, `DebugOracleTwoWindowTests`): **`✔ Test run with 115 tests in 19 suites passed after 59.217 seconds`**, `** TEST SUCCEEDED **`, 0 skipped (the two `skipped` lines are AppIntents metadata warnings) — `App/Variorum/DerivedData/18l-uvis-closing1.log`. Zero warnings in the new file. Core / iOS / mobile not owed |
| 9 | Self-assessment | DONE (below) |

- Deaths / resumes: none.
- **INCIDENT (machinery honesty, 10:45 local) — a stale system consent prompt on screen.** A macOS
  TCC prompt, *"“Ghostty” wants access to control “Finder”… A program running within Ghostty would like
  to use AppleScript"* (UserNotificationCenter, layer 8, 260×298 at (734,222)), sat over the middle of
  the dev window. It predates this session (the owning process started Sep 24; no Finder AppleEvent in
  this session's `tccd` log; U0b's record notes an `osascript` to Finder that *"hung on an AppleEvent
  timeout"* — the likely origin). Two exploration clicks at (868,459) landed on it (its log shows
  `sendAction:` at both times) — **neither on a button** (it still stands, unanswered: Allow/Don't
  Allow sit at y≈476–505), but the second left it holding keyboard focus, so a ⏎ would have pressed
  **Allow**. Caught by the probe's `key=0`; focus handed back by a click on our own titlebar; the
  prompt is LEFT for the author (a TCC decision is hers). **The harness now refuses to click any point
  a foreign dialog covers (`vis-foreign`), refuses to type unless the probe says OUR window is key, and
  presses Settings by AXPress (no screen point)** — the guard's gap, mechanized. Recorded for the
  WalkKit traps (the orchestrator's pen): `guard.sh` does not see foreign dialogs.
- **MACHINERY SLIP (repaired, recorded):** commit `17bed3e2`'s record edit took its end marker from the
  FIRST `| 8 | Closing runs` in this file — the U0 RECORD's — so the edit duplicated ~900 lines (U0's row
  8 through the end) into the U-VIS record. Found at the close; this file restored from `d5162751` (the
  last good version; no other writer touched it in between — `git log`) and the record rewritten in the
  same commit. No history rewritten.

### WHAT WAS BUILT, AGAINST THE DESIGN NOTE'S SIX DECISIONS

1. **External driver over the real window** — `Tools/VisualWalk/visual-walk.sh` (zsh, the WalkKit mold:
   `cliclick` + System Events + window captures) launches its OWN dev-store Debug build
   (`App/Variorum/DerivedData/vis-walk`, `open -n --env VARIORUM_VISUAL_WALK=1`), one FRESH launch per
   voice pass (so every note's first open inside a pass is a real first open, R-18l-1), and quits it by
   identity. **WalkKit is CONSUMED IN PLACE, not promoted** (`lib.zsh` calls `Tools/WalkKit/guard.sh`
   before every GUI act): one guard, one home — a promoted copy would fork the rule the orchestrator's
   own walks run, the forked-brain class. Two rules the harness ADDS around it, from the incident: no
   click on a point a foreign dialog covers; no keystroke unless the probe says our window is key.
2. **Assertions on measured geometry** — the DEBUG oracle endpoint `Core/Views/VisualWalkProbe.swift`
   (below). Every assertion reads its numbers; captures (two to four per scenario) ride beside.
3. **The seeded scenarios** — the design note's list, all ten, plus B5 on both of U0b's roads (THE
   TABLE). Growable: one `vw_def` row + one `scn_<name>` function in `scenarios.zsh`.
4. **Opt-in gating** — the driver refuses without `VARIORUM_VISUAL_WALK=1`; the wrapper test is
   `.enabled(if:)` on the same flag, in its own package (JUDGMENT CALL 1). Loud refusals: her app
   running, another instance, no Accessibility / Screen Recording (`vis-tcc` checks, never prompts),
   the machine not author-free.
5. **Output** — `notes/plans/vis-walks/<date>/<HHMMSS>/` (gitignored): `report.md` (per-scenario table,
   every assertion with measured / expected / tolerance / known row), `report.tsv`, `run.log` (every
   act, every guard), `probes.log` (every oracle answer), captures. Exit 0 / 1 (FAIL or ERROR) / 4
   (aborted by a guard) / 5 (refused).
6. **The cadence** — README: on demand at editor-touching closes, and once after every macOS update on
   the unchanged tree (TK2 §5 made executable).

### THE ORACLE ENDPOINT (the one app-side change — DEBUG, and inside DEBUG env-gated)

`App/Variorum/Variorum/Core/Views/VisualWalkProbe.swift` (new; the WHOLE file, imports included, inside
`#if DEBUG` — a Release build compiles it to nothing) + three lines in `VariorumAppDelegate.
applicationDidFinishLaunching` inside `#if DEBUG`. The observer exists only when the process was
launched with `VARIORUM_VISUAL_WALK=1` — Xcode Run, the test host and every other walk never register
it (the closing run's 115 tests launch the test host through it: a no-op). **Pull, never push:** the
driver posts a distributed notification (a request id + flags); the app answers with one
(a content-free `key=value` line: numbers and fixed words, plus an 8-character note-id prefix so a
re-open can be matched). The answer is computed at request time from: the key window's first-responder
text view (TK2 API only — `textLayoutManager`, never `.layoutManager`; no `.ensuresLayout` — the
first visible line, the middle text line, the first blank line below it, the caret's line and x, the
last fragment read O(1) the settle net's way); the editor's own `topVisibleOffset()` and caret ordinal;
`CommandRouter.activeMode` / `activePostID`; `EditorTypography.current.voice`; and C4's oracles
`BookIndexGeometry.paneReadTierFrames`, `ReadModeOracle.face` / `liveBlockID` / `editBlockFrames` /
`faceFrames`. The ONE layout it may cause is opt-in per request (`measure`, pane/inline editors only):
`PaneMeasurement.height` — the app's one measurement brain, what the inline editor already runs per
keystroke — taken AFTER the frame is read. **C4's owner-keyed rule has nothing to apply to:** no
surface writes any slot here (its class is a registration with no record of who registered it; a
pull-read registers nothing); the file's two statics are the process's own observer token and session
provider, set once at launch. Read ▸ edit's rows live in the host's NAMED space, whose window place no
oracle records — calibrated from the live pane when one exists (13u2 B's pinned alignment), else from
the AppKit scroll view whose size is the face's (`rtRcal=pane:` / `face:` in the line); no calibration
⇒ `uncal`, never a guess.

### THE TABLE — the final run (`vis-walks/2026-09-26/114921/`), both voices, measured

| scenario | seeded from | Terminal | Study | the numbers (Terminal · Study) |
|---|---|---|---|---|
| `note-reopen` | U0c · R-18l-1 | PASS | PASS | first open: clip 0.0, line 0, caret 0,0 · the same; palette re-open and ⌥⌘[/⌥⌘] re-open: line 11536 at y 287.0 = left · line 10596 at 282.0 = left |
| `write-typing` | her ask | PASS | PASS | click y 697.5 in the caret box [688, 707], caret x 560.6 vs 557 · 735.0 in [723, 747], 555.5 vs 557; 3 of 3 characters landed (46376 → 46379); line 7152 at 282.0 and the caret line 689.0 unmoved · 6296 at 294.0, 724.0 unmoved; ⌫×3 back to 46376 |
| `write-newline-roundtrip` | U0b (row 87) | PASS | PASS | About this book 3/3 → 4/4 → 3/3; the first line at y 298.0 and clip 0.0 through ⏎ and ⌫ · 304.0 and 0.0 |
| `write-divide-merge` | the design note | PASS | PASS | divide 262 → 263: line 14341 at 285.0 unmoved, the caret down 24.0 onto line 0 · 12636 at 288.0, down 30.0; merge back to 262, text 46376, the caret at the join (15438 · 13312), the page unmoved |
| `mode-roundtrip` | the design note | PASS | PASS | Write → Read → Write: line 16878 at 288.2 vs 288.0, the caret 17531 unchanged · 16000 at 305.8 vs 306.0, 16113 unchanged |
| `index-click` | U0 item 1 (row 86) | XFAIL (S3) | XFAIL (S3) | last line of a ≥5-line block: a pane live, the caret on a text line, NOT the blank line (U0's regression: PASS) — but the line rose under the pointer: click 680.0 vs its live box [654, 673] · 751.0 vs [720, 744] (S3); first line of the block above: caret line 0, y 264.0 in [255, 274], x 730.3 vs 732 · 313.0 in [304, 328], 730.8 vs 732 |
| `readedit-click` | U0 item 1 | XFAIL (S3) | XPASS (S3) | last line: not the blank line (PASS); click 745.9 vs [720, 739] (S3) · 736.0 inside [728, 752] (that block's shift stayed inside its line); first line: y 629.9 in [621, 640], x 792.2 vs 790 · 356.0 in [342, 366], 715.0 vs 712 |
| `outline-narrow-restore` | U0 item 2 | PASS | PASS | the live inline note at 1440 → 1100 → 900 → 1440: frame − measured = 0.0 at every width, the last line's glyph box inside (223/240/325/223 · 282/282/348/282 pt) |
| `b5-return-after-cmd-down` | row 88 (B5), the carve road | XPASS | **XFAIL** | ⌘↓ then ⏎ at the tail: line 45482 at 290.3 unmoved · **line 45591 at 298.0 → line 45509 at 302.0: the lines above the caret moved DOWN ~30 pt under an unmoved clip** (the frame +94 for one new line) |
| `b5-refont` | row 88, the re-font road | XPASS | XPASS | after a whole-document voice switch, ⌘↓ then ⏎: unmoved in both |
| `selftest-red` (`--selftest`) | the guard rule | FAIL (as it must) | — | the window's top "moved 40 pt": measured 117.0 vs 157.0 → FAIL, captured, exit 1 |

S3 = KnownIssues' *"Clicking a read-tier block RE-WRAPS it under the pointer as it goes live"* (18l U0
S3; owner the Design & UI review; her taste call). The harness now MEASURES it every run on a block of
five or more lines (the live pane drops the tier's 4-pt line spacing: line k rises ~4k pt, and shows
markers the tier hides, so it can wrap a line longer). It never reds; XPASS where a block's shift stays
inside its line.

### B5's HONEST VERDICT (row 88)

**Reproduced — in Study, deterministically inside the full seeded pass, and nowhere else so far.** The
full Study pass (after the eight scenarios before it in the same session) moved the page on BOTH full
runs with the same numbers (45591 @ 298.3 → 45509 @ 302.3; 45591 @ 298.0 → 45509 @ 302.0): the clip
did NOT move, the frame grew 94 pt for one ~30-pt line, the text above the caret slid down — **U0b's
untraced hypothesis ("the edit's layout pass corrected [estimated heights] under a fixed clip"),
measured.** Not reproduced: Terminal (2 of 2 full passes), a fresh-launch Study run with NO probe between
⌘↓ and ⏎ (captures compared row by row — also ruling out the probe as the cause in Terminal),
`outline-narrow-restore → B5` alone and `readedit-click → B5` alone in Study, and the re-font road in
either voice. **Its magnitude is smaller than U0b's (+109 / +166 on `998f7d7d`)** — whether U0c's
landing changes narrowed it is not established. Labelled KNOWN (row 88): XFAIL when it moves, XPASS
when it does not; the recipe for the owner's trace is `VARIORUM_VISUAL_WALK=1
Tools/VisualWalk/visual-walk.sh --voices study` (the full pass) with `probes.log` holding every frame,
clip and line number around the act.

### THE HARNESS CAN RED (the brief's non-negotiable)

(a) The planted failure: `--selftest` → FAIL, captures, report, exit 1 (`112606-selftest/`, and again
inside the wrapper, `114902-selftest/`). (b) **The teeth, on a real regression:** U0b's R-full revert
built in a scratch worktree and walked by `VW_DD` — `write-newline-roundtrip` RED at −24.0 pt (her report,
exactly as U0b measured) and `note-reopen` RED (the re-open's place lost, U0c's C3) — exit 1
(`112830/`). (c) The first full run's B5 Study FAIL was a real red on the unmodified tree before the
relabel. (d) A comparator self-check runs before any GUI act of every run (a knowingly wrong pair must
compare FAIL, or the run refuses — exit 5). (e) The foreign-dialog guard fired for real and aborted a
run (`111249/`: exit 4, the app quit, nothing further touched).

### FINDINGS (harness calibration and product facts met on the way)

| # | Finding | Disposition |
|---|---|---|
| V1 | A mid-word ⏎ divides at the word's END, not at the caret (the ruled snapping, S4-22) — the merge's caret lands at the join, 3 characters after the click | harness expectation CORRECTED (the caret at the join); product behaviour as ruled |
| V2 | S3 measured every run (16–19 pt on 5-line blocks; 64 pt on a 17-line block in an exploratory run) | reported as XFAIL against its owned row; OWED: the row gains the numbers |
| V3 | B5 reproduced on the current tree (Study, full pass) with the fixed-clip signature | OWED: row 88 gains the measurement + the recipe; the trace stays its owner's |
| V4 | A stale TCC consent prompt from an earlier walk has been on screen for hours; a walk click can land on it and give it keyboard focus | STOPPED short of harm (the incident); the harness's foreign-dialog rule; OWED: her morning bundle + the WalkKit trap line |
| V5 | `mode-roundtrip` lands 0.2 pt off exact in both voices (288.2 vs 288.0; 305.8 vs 306.0) | inside the ±0.5 tolerance; noted, not a finding |

### THE DIFF

| Path | What |
|---|---|
| `App/Variorum/Variorum/Core/Views/VisualWalkProbe.swift` | NEW — the oracle endpoint (all `#if DEBUG`, env-gated) |
| `App/Variorum/Variorum/VariorumAppDelegate.swift` | three lines inside `#if DEBUG`: `installIfRequested` |
| `Tools/VisualWalk/` | NEW — `visual-walk.sh`, `lib.zsh`, `scenarios.zsh`, `README.md`, `helpers/` (`vis-probe`, `vis-win`, `vis-foreign`, `vis-ax`, `vis-tcc`), `Package.swift` + `Tests/VisualWalkTests/` |
| `.gitignore` | `Tools/VisualWalk/bin/`, `Tools/VisualWalk/.build/`, `notes/plans/vis-walks/` |

Zero `Sources/`, `Shared/`, `Sync/`, schema, `Server/`. The editor seam is READ, never written: the probe
reads the first-responder text view's TK2 geometry and calls `EditorViewModel.topVisibleOffset()`
(a production read) and, opt-in, `PaneMeasurement.height`; `EditorTextView`, `BlockRangeIndex`,
`PaneSurface`, `PaneTextAuthority`, `runStructural` untouched. **Review: Opus per the brief's letter**
(the endpoint touches the seam only in DEBUG, read-only, and only in a harness-launched process); the
orchestrator may prefer Fable because the reads sit ON the seam's objects — stated, not decided here.

### JUDGMENT CALLS (each reversible in a line or a file)

1. **The wrapper is its own tiny SPM package**, not a suite in `VariorumTests`: the Mac test host is the
   SANDBOXED app, which cannot launch `cliclick`/`osascript` against itself; `swift test` in
   `Tools/VisualWalk` runs under the terminal that holds the grants. Same gate (`.enabled(if:)` on the
   flag); by construction in no default run. *Reverse by* moving the two tests into `VariorumTests` —
   they would skip there too, but could never pass.
2. **WalkKit consumed in place** (above). *Reverse by* copying `guard.sh` into `Tools/VisualWalk/`.
3. **Pull over distributed notifications** (no registration, no file in her container, no log scrape).
4. **Tolerances:** page stillness ±0.5 pt (sub-pixel; the mode round trip's 0.2 passes); the caret under
   a click inside its line box ±1 pt; caret x ±12 pt (about one character); frame vs measure ±1 pt.
5. **The read-tier targets are chosen, not fixed:** the lowest fully visible block of ≥5 lines (so S3 is
   measured, not a coin toss), then the block ABOVE it on its first line (the first swap's reflow cannot
   move it). The click x avoids any foreign dialog.
6. **B5 labelled KNOWN (XFAIL/XPASS), not plain** — its reproduction is history-dependent; a plain
   assertion would red the standing run for a known, owned, intermittent row.
7. **XPASS never sets the exit code** — flagged loudly in the report's result line instead.
8. **Fixtures are the sample library** (Sherlock; *About this book*), not harness-minted notes: the walks'
   own fixtures, text-restoring round trips; residue = the carved empty blocks in those notes' trays
   (two per full pass per voice on *About this book* / *A Scandal in Bohemia*), as every walk has left.

### NOTICED, NOT TOUCHED

1. **The stale TCC prompt** — still up at (734,222): *"“Ghostty” wants access to control “Finder”"*.
   Answering it is hers. 2. `guard.sh` cannot see foreign dialogs (the harness's own rules cover it; the
   orchestrator's walks do not). 3. B5's trace (row 88's owner). 4. The Read ▸ edit host space has no
   window-origin oracle; the harness calibrates (a one-line `.global` registration would make it exact —
   not built: the calibration measures true and no new registration was needed). 5. A book's mode row
   has no keyboard shortcut; the harness presses it by accessibility label.

### OWED AT CLOSE (drafted for the orchestrator)

- **KnownIssues row 88 (B5):** + *"Reproduced by U-VIS (2026-09-26) in the full Study pass, deterministic
  there (45591 @ 298 → 45509 @ 302, clip unmoved, frame +94 — the fixed-clip hypothesis measured); not in
  Terminal, not from a fresh launch; recipe: `VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh
  --voices study`."*
- **KnownIssues, the S3 row:** + *"Measured every U-VIS run (`index-click` / `readedit-click`, XFAIL):
  16–19 pt on a 5-line block, ~64 pt on a 17-line block."*
- **ENVIRONMENT TRAPS / WalkKit README:** a stale system consent prompt (UserNotificationCenter, layer 8)
  can sit over the dev window for hours; a click on it gives it keyboard focus and a ⏎ would answer it;
  `guard.sh` does not see it — check `Tools/VisualWalk/bin/vis-foreign <pid>` (or the CG window list)
  before walking; never answer it.
- **Her morning bundle:** the prompt itself (Allow / Don't Allow is hers; its origin is almost certainly
  an earlier walk's `osascript` to Finder).
- **MOBILE PARITY:** nothing mobile-visible (a Mac-only harness; the design note's own "phone scenarios —
  a parity row at close": the phone has no driver road).

### SELF-ASSESSMENT

Strong: the harness does what her sentence asked — real window, real edits and clicks, captures of each,
and a report that says in numbers whether the editor moved between acts; it proved it can red on a
planted failure AND on a real reverted fix (her own −24.0 pt), and on its first full run it caught a real
intermittent regression (B5) that the round had only seen by eye, with the numbers that confirm U0b's
hypothesis. Every assertion reads the app's own geometry; nothing is decided by pixels. The only
app-side code is a DEBUG, env-gated, read-only endpoint. Weakest points for the reviewer: **(a)** the
harness is zsh with a lot of float arithmetic and string parsing — one parsing bug (`(z)` splitting on
`;`) was found and fixed in-session; others may hide; **(b)** the probe CALLS production reads
(`topVisibleOffset`, opt-in `PaneMeasurement.height`) — read-only, but on the seam's objects;
**(c)** Read ▸ edit's calibration by scroll-view SIZE is a heuristic (it reports `uncal` rather than
guess, but a future layout with two equal-sized scroll views could match the wrong one); **(d)** B5's
reproduction is history-dependent, so the XFAIL/XPASS label is honest but the tripwire never reds;
**(e)** a full two-voice run takes ~15 minutes and leaves tray residue; **(f)** my own machinery slip
(the `17bed3e2` record duplication), repaired from the last good version. **U-VIS — DONE (implementer);
the cold review follows.**

### U-VIS — ROUND-1 FIX PASS (implementer; the orchestrator confirmed every finding of `notes/plans/18l-uvis-ladder-round1.md`, `bdc770c8`)

LIVE STATUS (flipped per piece; the fix table lands in the ladder file at the end):

| # | Piece | Findings | Status |
|---|---|---|---|
| F1 | Guard BEFORE activate; an author-at-the-machine refusal aborts, never re-activates; relaunch + Settings close guarded; WalkKit `click.sh`/`keys.sh` the same order; headless stub-rig pin red on the old order | MAJOR-1, N5 (guard half) | **DONE** — pin `50e215cf` (`pins/guard-order.zsh`: 8/8 RED on the shipped lib — activation before the guard, 3 activations across an exit-4 refusal), fix `7e9b0f35` (`guard.sh --author`; `vw_step` = gap → author → activate → target → act; 3/4/6/7 abort, only 5 retries after a fresh author check; `open -n` and the Settings close guarded; WalkKit `click.sh`/`keys.sh` reordered + README) → 8/8 GREEN, run always-on by the wrapper package (`✔ Test run with 3 tests in 2 suites passed`, the GUI pair skipped) |
| F2 | The probe reads nothing off-screen on the document editor (the last-fragment read opt-in; an off-screen caret reports `caretState=off`); the probe's facts factored for an in-suite pin; the env-gate + TK2-arithmetic pins | MINOR-8 (fix), N7 | **DONE** `25a9c3c5` — the caret read only inside the laid-out viewport, the last fragment only on `last`/`measure`; `VisualWalkProbeTests` (new, DEBUG) 4/4 GREEN (`App/Variorum/DerivedData/18l-uvis-f2-pins.log`): the env gate (none / `0` / `1`), a caret at 0 on the first visible line, a caret after the trailing newline on TK2's EXTRA empty line fragment below the text, the last fragment only when asked (red on old by non-compilation — no `last` door existed) |
| F3 | The build stamp (App/, Sources/, the package manifests + the uncommitted diff) printed in the report; the driver REFUSES a binary that is not the current tree's (a `VW_DD` scratch build may differ only under `App/`) | MINOR-3, MINOR-4, N6 | **DONE** `e9bdb5b8` — `build.sh` stamps (app = App/ tree + diff, core = Sources/ + manifests + diff); the report's header names the build's own origin; `pins/build-stamp.zsh` 9/9 on a throwaway repo; **measured for real:** the stamped build + one uncommitted App/ line → `visual-walk REFUSES: the build's App/ is not this tree's (built from e9bdb5b8 … dirty VisualWalkProbe.swift) — rebuild with --build`, exit 5, no run folder (restored by `git checkout`, committed file) |
| F4 | Abort/INT/TERM: quit, record the voice left, restore only when the author checks pass; the Automation grants checked without prompting | MINOR-5, MINOR-6 | **DONE** `31a36d36` — `pins/abort-voice.zsh` 5/5 (4 RED on the pre-fix lib); System Events' Automation grant checked without prompting (`granted` here); the dev app now gets NO Apple Event (quit via its own menu by AX, pid-addressed) after `vis-tcc` measured its grant `undetermined` even for `aevt/quit`; a real `--selftest` through the new quit → FAIL, exit 1, zero instances (`125732-selftest/`). **A machinery fact met:** an Automation check against a target whose consent prompt is PENDING (Finder — the stale prompt) BLOCKED until killed; it minted nothing new (the one dialog stands); every check now runs under a 15-s limit and Finder is never asked |
| F5 | Plain last-line line-index row; `b5-refont` plain; the NITs as written | MINOR-1, MINOR-2, N1–N5, N8, N9 | **DONE** `a35b3a45` — `pins/read-tier-assertions.zsh` 4/4: the pre-fix Read ▸ edit landing (line 0) REDS (the OLD row set on the same planted answer: `PASS PASS PASS XFAIL` — MINOR-1 confirmed), the Index's blank-line landing REDS, S3 alone XFAIL, the one extra marker-wrap line PASS; ≥8-line targets; `b5-refont` plain, the carve road KNOWN in Study only; N1 #150(a) cited; N2 dead helpers out; N3 README/exit 4; N4 6.2/macOS 26; N5 the mid-line require; N8 every layer ≥ 1 (Screenshot's capture surface excluded — measured click-through); N9 the full residue |
| F6 | B5's discriminating re-run (the full Study pass under the gated probe) → KnownIssues row 88 either way | MINOR-8 (measurement) | **DONE** — `vis-walks/2026-09-26/130055/` (build `e9bdb5b8`, the gated probe): **B5 REPRODUCED byte-identically** (45591 @ 298.0 → 45509 @ 302.0) — the recipe does not need the probe's off-screen reads; KnownIssues row 88 carries it (this commit). **Found on the way (a harness defect, fixed):** the Study `readedit-click` had clicked a STALE oracle frame — a 360-pt ghost of a de-realized paragraph standing over a run of one-line rows (C4 keeps a row's last frame until its surface leaves; a re-open's landing scroll de-realizes rows it had laid out at the top) — its "last line" was a one-line block and its XPASS meaningless. Fix: overlapping frames are dropped as suspect, the live pane must stand where the frame said (±12 pt, else the HARNESS errors), and `readedit-click` opens a note first-opened in the pass (no landing scroll). Re-run in Study (`131046/`): both read-tier scenarios XFAIL on S3 alone (751 vs [720, 744]; 1051 vs [1024, 1048]), every plain row PASS |
| F7 | U0 item 2(b) seeded (the long story's settle); teeth runs for items 1, 2a, 2b (R-U0-1, R-U0-2, R-U0-3 in scratch worktrees) | MINOR-7 | **DONE** — `outline-long-story-settle` SEEDED (`003f467d`; the navigator lands *The Adventure of the Copper Beeches* live, 1000/1440 ×2, its end scrolled into view, the frame vs the laid-out bottom read O(1)): PASS 8/8 on the tree (`131538/`). **THE TEETH — every seeded U0 tripwire now reds on its own regression** (scratch worktrees at `003f467d` (R-U0-1/2/3) and `6dfde0f1` (R-U0-23), built + stamped by `build.sh`, walked by `VW_DD`; worktrees REMOVED, the main tree untouched): **item 1 — R-U0-1** (`clickOffset: nil` at both hosts, `132033/`): `index-click` RED — the caret on the blank line under the text (line 6 of [4, 5]); the first-line click on line 15 at the block's end, y 264 outside [517, 536], x 687 vs 732 — and `readedit-click` RED — the caret at line 0 of [3, 4] (the MINOR-1 row), x 697 vs 790; exit 1. **item 2a — R-U0-2 alone** is HEALED by the settle net in the app (`132221/`: both item-2 scenarios PASS — U0's own record: the two fixes ship together), so **R-U0-23** (both off — the pre-U0 road, `132822/`): `outline-narrow-restore` RED — at 1100 the frame 17 pt short and the last line's glyph box (240) outside the frame (223.5); at 900 **102 pt short** (325 vs 223.5): her capture's cut tail, U0's measured −51…−102; exit 1. **item 2b — R-U0-3** (the settle net off, `132447/`): `outline-long-story-settle` RED — at 1000 pt the frame **1,256 pt SHORT** of the laid-out text and the story's last line off the reachable page (2227 vs 1117); exit 1 |
| F8 | The final wrapper run (both voices) + the touched suites; the fix table in the ladder file | — | **DONE** — **the wrapper** (`App/Variorum/DerivedData/18l-uvis-wrapper-r1fix.log`): `✔ Test "every headless pin holds" with 4 test cases passed` · `✔ Test theHarnessCanRed() passed` (the planted failure exit 1, `133011-selftest/`) · `✔ Test theSeededWalkPasses() passed after 1000.393 seconds` · `✔ Test run with 3 tests in 2 suites passed`. **The final run** `vis-walks/2026-09-26/133031/` (build `e9bdb5b8`, the gated probe; 11 scenarios × 2 voices): **0 FAIL · 0 ERROR · 0 XPASS** — PASS 17 · XFAIL 5: S3 ×4 (Index 680 vs [654, 673] · 751 vs [720, 744]; Read ▸ edit 1050 vs [1024, 1043] · 1054 vs [1027, 1051]) and **B5 in Study** (45591 @ 297.7 → 44477 @ 296.1 — a LARGER slide this run, ~1,100 characters of text above the caret moved down: the magnitude follows the pass's history, the long-story scenario now running before it; U0b saw +166). **The app suites** (`18l-uvis-closing2.log`): the eleven Tutorial suites + the six source-walk pins + C4's two oracle suites + `VisualWalkProbeTests`: **`✔ Test run with 119 tests in 20 suites passed after 57.183 seconds`**, `** TEST SUCCEEDED **`, 0 skipped. Zero app instances after every run; the voice restored to Terminal |

### U-VIS — ORCHESTRATOR ACCEPTANCE (2026-09-26; verify-never-trust)

**Claims verified:** all 12 commits pushed; the plan-file duplication slip verified REPAIRED
(every `##` section appears exactly once; `59689c4e` restored from `d5162751` with no other
writer in between — honest machinery note, no history rewritten). **The acceptance is a run in
the ORCHESTRATOR'S OWN HANDS:** `--only note-reopen,write-newline-roundtrip --voices terminal`
→ both PASS (7 and 9 assertions, 0 fail, exit 0; the report's measured values match the
implementer's evidence run) and `--selftest` → the planted failure FAILS, captured, **exit 1** —
the tripwire fires. The harness is real.

**Adjudications (R-18l-4):** the review cast is **OPUS** per the brief's letter (the oracle
endpoint is DEBUG-only and read-only; it CALLS `topVisibleOffset()`/`PaneMeasurement.height`
but modifies no seam body — if the Opus round flags a seam concern, a Fable pass follows).
**B5's measured recipe lands on KnownIssues row 88** (deterministic in the full STUDY pass;
frame +94 pt for one new line; the text above the caret slides ~30 pt; scroll unchanged —
U0b's "corrected under a fixed clip" hypothesis now measured; the trace stays with the row's
owner). **THE STALE CONSENT PROMPT is a HELD-FOR-HER item** (morning bundle, top): a macOS
dialog "Ghostty wants access to control Finder" sits on screen at ~(734,222), left by U0b's
accidental Finder osascript; two exploration clicks landed on it harmlessly, one gave it
keyboard focus (a ⏎ would have pressed Allow — focus was taken back at once); NO session may
answer a consent dialog (author-only, the traps' own rule); recommended answer when she wakes:
**Don't Allow** (nothing in the tooling needs Finder control). The traps gain the dialog rule;
WalkKit's README gains the VisualWalk pointer. Ledger row 6 flips to BUILT+WALKED — Opus
review is the remaining gate.

## HER CHECK-IN (2026-09-26, mid-U1 — rulings verbatim-faithful)

Her words: *"excellent! continue through U1, I prefer a clean seam and the context cutoff is
more for guidance anyway. I saw the prompt and clicked Don't Allow. Would it be best if I
stepped away from the computer for your GUI driving to finish U1? sounds good on the plan,
please give me the kickoff message here in chat and I'll send the kickoff at your word."*
Applied: **R-18l-3's split CONFIRMED at the pre-declared seam** — 18l closes after U1
(ladder + acceptance + the closeout ritual incl. the install refresh); **18l-b** (U2 · U3 ·
U4 · the B5 trace) runs under a FRESH orchestrator on her paste of the kickoff (given to her
in chat; she sends it at the orchestrator's word, after the closeout push). The consent
prompt is RESOLVED (she clicked Don't Allow) — bundle item 1 closes. She may step away for
the walk windows; the per-step guard keeps her return safe at any moment.

## U1 RECORD (implementer: `opus-implementer`, 2026-09-26)

**NOT DONE (first line — re-stated at the close against what shipped):** (1) **the charter's
"rows as placeholders at asserted heights" is NOT built** — it was built in the working tree,
MEASURED (a cold landing on her story stood 59 pt off, then needed a correction hop, where the
pre-fix lazy column lands exactly in one step) and REJECTED; the lazy columns stay and the
authority watches them (JUDGMENT CALL 1 — PROVISIONAL, **QUESTIONS #151**, the orchestrator's
confirmation and her bundle); (2) the contents column (`NoteIndexColumn`'s one-shot `.center`)
is NOT adopted — recorded, the charter's "else record" (JC 5); (3) the authority's aim KIND is
NOT grown — the fraction's arithmetic lives beside note Read (`ReadLandingResidual`), for
18l-b U2 to hoist (JC 2); (4) the health review §1.2's stutter is NOT reproduced on the real
fixture before the fix (piece 2b) — the only reproduction is the harness's synthetic shape,
which the fix corrects; (5) no KnownIssues / AppSpec / TEXTKIT2 / canon / review edits — drafted
under OWED AT CLOSE; (6) zero `Sources/`, `Shared/`, `Sync/`, schema, mobile — no core / iOS /
mobile runs owed; the U3 rider and row 85 untouched; (7) the `pages` form (`NotePagesView`, the
book's paged engine) is not a scroll landing and is untouched.

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| 1 | Reading (the brief's list, in order, own context) | DONE — this file whole (HER KICKOFF MESSAGE, SITTING RECORD R-18l-1…5, ENVIRONMENT TRAPS, THE LEDGER, the U0 · U0b · U0c · U-VIS RECORDs + acceptances, the MORNING BUNDLE); the charter's KICKOFF 2 U1 bullet in full (`post-13u-health-rounds.md`) + §W; the health review §1 whole (§1.1 map, §1.2 the one-shot-aim diagnosis, §1.3 item 1, §1.4 the warming refusal, §1.5 traps); the 13u4 UNIT F3 BRIEF + RECORD whole (`phase-13u4-restyle.md`); `TEXTKIT2_NOTES.md` §2–§3; `SessionResiliencyProtocol.md` (implementer half + addenda); the code: `Surface/LandingAuthority.swift` whole, `Surface/BookHeightManifest.swift`, `Surface/ProseHeightModel.swift`, `Surface/ViewportCarry.swift`, `Surface/IndexProseColumn.swift`, `Surface/ReadTierClickPlace.swift` (the tier's metrics), `BookIndexView`'s F3 adoption (the pane column, `IndexPaneRow`, `land`/`paneFacts`, `BookIndexPaneNote`'s reservation), `BookIndexPaneHeights.swift` whole, `BookViewModel`'s Outline + Index heights plumbing and `flowExtents`, `ReadingFlowView`'s `FlowExtentsCache` + its landing adoption, `Core/Views/StableSurface.swift`'s `NearBand`, `ReadModeView.swift` + `ReadEditPane.swift` end to end, `NoteIndexColumn`'s landing, `BlockTOCViewModel` (rows, prime, liveness), `Queries.blockExtents` + `Queries.TOCRow`, `Shared/FlowParagraph.swift`; the pins that ride this surface (`ReadLandingTests`, `ReadModeTests`, `ReadArrivalMeasureTests`, `ReadPageRoomTests`, `ModeSwitchCarryTests`' Read arms, `LandingAuthorityTests`/`LandingSignpostTests`) |
| 2 | The red-on-old pins (written BEFORE the fix, run on the pre-fix tree) | **DONE (this commit)** — `ReadNoteLandingTests` (new, 2 tests): a Sherlock-shaped 260-block note (40 short dialogue lines, then long narrative paragraphs of 1–9 sentences — the class's own shape: the lazy column's average of what it has realized is WRONG for the rows it has not), the row-39 arrival at block 201 (the coldest landing: nothing below the first screenful ever drawn), the landed block's distance from its face's SHIPPED anchor sampled at +3 s and +4.5 s. **Pre-fix, 2 runs** (`App/Variorum/DerivedData/18l-u1-pin-prefix{1,2}.log`): **edit face RED 2/2 — the landing MISSED ENTIRELY**: block 201 never drew; the pane's last-drawn rows were 212–215 (an overshoot of 11–14 blocks — the one-shot aim on the lazy estimate, nothing re-aiming). **Page face GREEN 2/2** (−0.005 / −0.03 pt): the harness does NOT reproduce a page-face displacement for an arrival landing — recorded as measured (the page pin stays as a guard the fix must keep green; the page face's adoption rests on the charter + the app trials, piece 5) |
| 2b | THE PRE-FIX APP BASELINE, measured on this tree (F3's piece 2b) — the probe-only commit `7d3a83f1`+`0bf54efe` (the DEBUG `rl` read + the harness's `read-landing` scenario; no fix) | **DONE** — `vis-walks/2026-09-26/152108/` (Terminal) + `152416/` (Study), A Scandal in Bohemia, 1440×1000, the contents column's filter road (deep click): **12 of 12 landings AT their anchor at +1.5 s and +6 s (|rl| ≤ 0.2 pt), cold and warm, both faces, both voices — and ZERO `landing` lines** (the §1.2 Console signature). A burst of window captures after a cold deep click (`18l-screens/u1/pre-burst-edit/`, ~110 ms apart): the page goes from the start to its final place in ONE step (0.12 → 0.25 s) and never moves again. **The §1.2 stutter mechanism does NOT reproduce on the real fixture**; the harness's synthetic shape (piece 2) is the one reproduction |
| 3 | The fix — the authority's loop in BOTH faces, `LandingPolicy.readNote`/`.readNoteEdit`, the per-note block manifest | **DONE (`5e7cbf34`) — design (B): the authority WATCHES the lazy columns' own landing; rows as asserted-height placeholders (design (A), the charter's letter) MEASURED and REJECTED** (below: JUDGMENT CALL 1). `ReadNoteLandingTests` 4/4 GREEN (`18l-u1-B1.log`): the synthetic edit-face miss now `settled at top=0.0 after 1 hops, 1005 ms`; the real story `settled … after 0 hops` both faces; `LandingSignpostTests` green (surface count 3 → 5, the pin's own 'the next adds its case here' line). **Design (A) measured** in the working tree (never committed; `18l-u1-experiment-A-rows-at-asserted-heights.log`): the REAL story's cold arrival stood **59 pt off its anchor** after the rows around it traded their derived heights for real ones, then **1 correction hop** moved it home at ~1 s (path [59, 0]); synthetic [100, 0]; realized rows 65–79 vs (B)'s 14–15 |
| 3b | The fix's own pins | **DONE (this commit)** — `ReadNoteLandingTests` gains the WATCHED arm (the DEBUG story's last DONE line is this face's, `settled`, hops ≤ budget on the synthetic miss, **hops = 0 on the real story in both faces** — the charter's cold line, and the pin that reds design (A)); NEW `ReadNoteHeightsTests.swift`: `ReadNoteLandingArithmeticTests` 6/6 (the residual's home + the ends' clamp; **P1: extents taken ONCE per block-id list, an autosave-shaped re-delivery takes nothing**; the manifest's precedence and its measure; the extent = `Queries.blockExtents`' numbers; the signpost content-free on both new surfaces) and `ReadNoteHeightsCalibrationTests` 3/3 (the real story, Σderived/Σdrawn: **edit 0.975 Terminal · 0.996 Study · page 0.988** — within F3's fifth) — `18l-u1-pins2.log` / `18l-u1-calib1.log` |
| 4 | The behavioural revert (red-on-old by revert) | **DONE — R-watch RED exactly as predicted: 4 tests / 10 issues** (`App/Variorum/DerivedData/18l-u1-R-watch.log`): the synthetic edit-face arrival MISSED again (block 201 never drew — the pre-fix shape, byte for byte) and all four watched arms red (story `NONE`), while the three real-story/page residual arms stayed green (0.18 / 0.02 / −0.03 pt — the lazy column's own exact landing, as pre-fix) and the arithmetic (6) + calibration (3) suites green; restored with `git checkout HEAD --`, `git status` clean. The named plan it ran to: **R-watch, named before it runs** (the pre-revert state is THIS commit): both faces' `land` put back to the one-shot `proxy.scrollTo(placementID, anchor:)` (the authority neither asked nor told), everything else kept. Expected RED: the synthetic edit-face arrival (the block never draws — the pre-fix miss) and all four `expectWatched` arms (no landing is watched, so no story line); GREEN: the three real-story/page residual arms (the lazy column lands them exactly, as pre-fix), the arithmetic and calibration suites. Working-tree edit only; restored by `git checkout HEAD --` of the two committed files; `git status` clean after |
| 5 | The measured acceptance — cold + warm deep-click trials on the real long-note fixture, the Console line | **DONE** — the harness's `read-landing` scenario on the stamped post-fix build (product code `5e7cbf34`), *A Scandal in Bohemia* (262 blocks), 1440×1000, a fresh launch per voice: six runs × {Terminal, Study} (`vis-walks/2026-09-26/155949` · `160626` · `162649` edit-first; `161316` · `162000` · `163324` read-first) — **72 of 72 landings `end=settled top=0` with `hops=0`**, every one at its anchor at +1.5 s and +6 s (|rl| ≤ 0.2 pt). **Truly cold** (the run's first face — `derived=251`, nothing below the first screen ever drawn): **edit 6/6 · page 6/6**; the second face's first click (its column already landed once by the face switch): 6/6 + 6/6; the rest warm or second-region: 48/48. **THE CONSOLE FLIP:** pre-fix ZERO `landing` lines (piece 2b); post-fix 21 in ten minutes of Read (every landing, the face switches' parked ones included), e.g. `2026-09-26 16:39:32.127 Df Variorum[26040:6f85f2] [io.lduarte.Variorum:landing] landing surface=ReadNoteEdit rows=262 target=208 offset=16943 total=20749 derived=155 exact=0 hops=0 content=1 ms=1032 end=settled top=0` |
| 6 | The walk (both voices) + captures | **DONE** — the stamped post-fix build (`905ee936`; product code `5e7cbf34` + the policy doc line), dev store, every act through VisualWalk's guarded doors; captures + `walk.txt` under `notes/plans/18l-screens/u1/walk/{terminal,study}/` (gitignored). THE WALK table below. Plus the harness's standing regression cover over the surfaces the diff reaches — `vis-walks/2026-09-26/164901/`: **note-reopen PASS · mode-roundtrip PASS · read-landing PASS · readedit-click XFAIL (S3 alone, its owned row — unchanged), both voices, exit 0**. The dev store's voice restored to Terminal (read back by the probe) |
| 7 | Closing runs (touched suites + the eleven Tutorial suites) | **DONE** on the final product tree (`905ee936`), zero app instances, the machine author-free: `App/Variorum/DerivedData/18l-u1-closing.sh` = the three new suites + the Read surfaces (`ReadLandingTests` R1-3, `ReadModeTests`, `ReadArrivalMeasureTests` R1-9, `ReadPageRoomTests`, `NewModesTests`, `PageTurnKeysRuleTests`, `PagesArrowKeysHostTests`, `BlocksWorkbenchTests`, `BlockTOCTests`, `BlockTOCStatusTests`) + the landing family (`LandingAuthorityTests`, `LandingSignpostTests`, `BookIndexLandingTests`, `BookOutlineLandingTests`, `ReadingFlowLandingTests`, `ModeSwitchCarryTests`, `NoteOpenLandingTests` — U0c's R-18l-1 pins, `CurrentBlockContinuityTests`, `IndexClickCaretTests`) + the oracle/probe suites the diff reaches (`VisualWalkProbeTests`, `DebugOracleOwnershipTests`, `DebugOracleScopingTests`, `DebugOracleTwoWindowTests`) + the eleven Tutorial suites: **✔ Test run with 210 tests in 37 suites passed** (`18l-u1-closing1.log`; 37 `Suite … started` counted against 37 asked; 0 skipped — the two `skipped` lines are AppIntents metadata warnings); 170 `Modifying state during view update` lines (the pane-mounting family, U3's class — none from this diff's files); zero warnings in the touched files. Every pre-existing pin rode UNMODIFIED except `LandingSignpostTests`' surface count (3 → 5 — its own "the next adds its case here" line). Core / iOS / mobile: not owed |
| 8 | Self-assessment | DONE (below) |

- Deaths / resumes: none.
- **Machinery notes (honesty):** (1) a persistent macOS banner (*"App Running in Background — "Claude" is running in the background"*, Notification Center, top-right) held Notification Center's FULL-SCREEN overlay window on screen, and VisualWalk's foreign-dialog rule refused every click of the first baseline run (`151232/`, aborted, nothing clicked). Not a consent dialog and never touched: the rule was narrowed to the banner's COLUMN (`vis-foreign`, `3e8a17aa` — the top-right 440 × 480 stays covered, so no click can land on a notification; the Screenshot surface's precedent, answered narrower); every later run's first click was probed as having reached the app. (2) Read's face segments are AXRadioButtons, not AXButtons (measured) — `read-landing` presses them by AX right of the sidebar, and `readedit-click`'s latent `AXButton` lookup (never exercised: its note opened on edit) was corrected in the same commit (`9bea5c6d`). (3) One harness run (`164901/`) outlived the Bash tool's 600-s limit and was moved to the background BY THE TOOL; I waited on it in the FOREGROUND by polling its output file for the report line (the resiliency protocol's rule — the turn never ended on it). (4) The design-(A) experiment lived only in the working tree and was removed with `git checkout HEAD --` of two COMMITTED files (`git status` clean after); R-watch the same way.

### THE ADOPTION MAP — what each face does now

| Face | Before (pre-fix) | After |
|---|---|---|
| **Read ▸ read (the calm page, continuous)** — `ReadPageColumn.land` | one unanimated `scrollTo(placementID, anchor: 0.08 or the carried fraction)`, the request nil'd, nothing watched, nothing logged | the SAME act, handed to `LandingAuthority` (`LandingPolicy.readNote`, surface `ReadNote`): the block's distance from where its anchor puts it (`ReadLandingResidual`, clamped by the page's ends) is reported from the row's EXISTING geometry observer; the column's content height re-arms the quiet interval; a correction re-aims (blind allowed — the lazy column may not have built the block); a scroll of hers ends it (`handedover`); the watchdog ends a landing that cannot arrive (`gaveup`); every landing files the shipping signpost with the face's manifest facts |
| **Read ▸ edit (the editable index surface)** — `ReadEditPane.land` | the same one-shot at `.center` (or the carried fraction) | the same adoption under `LandingPolicy.readNoteEdit` (surface `ReadNoteEdit`) |
| **Both** | — | the columns stay LAZY (JC 1); `.onDisappear { landing.end() }` (R2-12); the face switch's parked landing (a request set while the other face was mounted) is watched too; the U0c opening arm is UNTOUCHED — whether a seed scrolls is still `CommandRouter.openingLanding`'s answer, and a landing that happens now is watched |
| **Read ▸ read, `pages` form** (`NotePagesView`) | the book's paged engine | untouched (no scroll landing) |
| **The contents column** (`NoteIndexColumn`) | one-shot `.center` on uniform one-line rows | untouched — recorded (JC 5) |

### THE TRIAL TABLE (F3's form) — pre-fix vs post-fix, the real fixture

| | Pre-fix (probe-only build `0bf54efe`) | Post-fix (`905ee936`) |
|---|---|---|
| Harness pin, synthetic shape, edit arrival | **RED** — block 201 never drew; the pane stopped at 212–215 | **GREEN** — `settled at top=0.0 after 1 hops, 1005 ms` |
| Harness pin, real story, both faces | 0.0 / 0.02 pt — exact, **no story** | 0.18 / 0.02 pt, **`settled … after 0 hops`** |
| App, cold deep click, both voices | the run's first face (edit) 2/2 and the second face's first click (page) 2/2 at the anchor (|rl| ≤ 0.2) — **no signpost** | **edit 6/6, page 6/6 `end=settled top=0 hops=0`**, at the anchor at +1.5 s and +6 s |
| App, the rest (second face / second region / warm) | 8/8 at the anchor — no signpost | **48/48 `settled hops=0`** + the 12 second-face first clicks 12/12 |
| Console, ten minutes of Read | **0 `landing` lines** | **21** (every landing, the face switches' parked ones included) |
| Design (A) — rows at asserted heights (the charter's letter), harness | — | **real story: 59 pt off, then 1 hop (path [59, 0]); synthetic [100, 0]; 65–79 rows realized** — rejected |

### THE WALK (USE) — both voices, `18l-screens/u1/walk/{terminal,study}/`

| Voice | Row | What the app did | Signpost | Capture |
|---|---|---|---|---|
| Terminal | W1 — *A Case of Identity* opened, then ⌘3 (a mode switch right after the first open) | the page at the start, block 1 washed | `ReadNoteEdit target=0 … exact=1 hops=0 end=settled top=0` (block 1, centred ⇒ clamped home at the page's top) | `w1-first-open-read-edit` |
| Study | W1 — Case re-launched: its remembered mode is Read, so this IS the first open in Read (R-18l-1: seeds nothing) | the page at the start | **none** — no landing asked, none made (U0c's arm, composed) | `w1-…` |
| both | W2 — a VISIBLE column row (18) in edit; the face switch to read (its parked landing); a visible row (24) in read | each block at its face's anchor (rl 0.0 / −0.1 / −0.1) | 3 × `settled hops=0` | `w2-*` |
| both | W3 — a deep row (209) in read via the filter; then a paragraph CLICK on the page (R-cor-7's click-through) | 209 at 0.08; the edit face opens with the clicked block LIVE and centred (rl 0.1 / −0.0) | `ReadNote … settled`, `ReadNoteEdit … content=4 … settled hops=0` | `w3-read-209`, `w3-clickthrough-edit` |
| both | W4 — ⌘1 Write, ⌘3 back (the 13u2b carry) | the carried block back at its fraction (~0.5) | `ReadNoteEdit … settled hops=0` | `w4-write`, `w4-read-carried` |
| both | W5 — a deep row (245), then HER wheel 0.35 s later (one guarded act) | the page where her wheel put it | **`end=handedover`** at 569 / 546 ms | `w5-handedover` |

### JUDGMENT CALLS (each reversible, the reversal named)

1. **The lazy columns are KEPT; the authority watches them — the charter's "rows as
   placeholders at asserted heights" is NOT built (PROVISIONAL, QUESTIONS #151).** The
   charter's shape was written from the review §1.2's diagnosis ("a one-shot aim against
   SwiftUI's lazy estimate … the identical jump every time"), a diagnosis *without a repro*.
   Measured here: on her story the lazy column's `scrollTo` lands exactly, in one step, cold and
   warm (12/12 pre-fix; a burst of captures shows no intermediate frame). The F3 shape exists
   for the Index, whose rows were whole NOTES loading their text asynchronously (the column
   oscillated by tens of thousands of points); a note's rows are its blocks, drawn from text in
   hand, so the lazy column realizes each at its real height as it lands. Built and measured
   anyway (working tree): asserted-height rows made the real story's cold arrival stand 59 pt off
   and need a correction hop a second later — a visible regression and a miss of the charter's
   own acceptance line (`hops=0` cold) — and a plain column puts a geometry observer on EVERY
   row that fires on every scroll frame, where the lazy column's fire only for the realized ones
   (P1). *Reverse by* the working-tree experiment's shape (`ExperimentRow` in the record's log
   name: a `VStack` of `NearBand` rows at `ReadNoteHeights.height`), accepting the hop.
2. **The anchor is carried as ARITHMETIC in the surface, not as an authority concept.** The
   authority converges a reported number to 0; note Read reports its block's distance from its
   face's anchor (`ReadLandingResidual`, `ViewportCarry.topInset` — the carry's own definition),
   clamped by the page's ends. The aim KIND is 18l-b U2's to grow (the charter); this is the
   fraction arm's pure, pinned arithmetic for U2 to hoist. *Reverse by* nothing — U2 moves it.
3. **`correctsAnUnreportedTarget` TRUE (the Outline's answer).** A lazy column's missed block
   never reports; the second aim is what reached the synthetic miss (1 hop). Budget 3 and the
   watchdog keep a hopeless landing honest. The other constants are the measured family's and
   the trials kept them (72/72 settled at the one-second hold). *Reverse by* `false` (the
   synthetic miss then ends `gaveup` after the watchdog, honestly, without arriving).
4. **Two surface words, one per face** (`ReadNote`, `ReadNoteEdit`) with identical constants —
   the charter allowed a second policy "if its `.center` anchor wants its own constants"; it did
   not, but a Console line must say which face landed. *Reverse by* one case for both.
5. **The contents column is not adopted** — its rows are uniform one-line handles, its one-shot
   `.center` was never implicated, and its landing is not the reading position. *Reverse by*
   a sixth surface case and the same watch.
6. **The manifest's lengths are read off the rows the host already holds** (`BlockTOCViewModel.rows`
   — `renderPost`'s take, the one `Queries.blockExtents` resolves), as `Queries.BlockExtent`
   values (scalars = SQLite `LENGTH()`'s code points), ONCE per block-id list — no second
   statement for text in memory, and nothing at autosave rate. `Sources/` untouched. *Reverse by*
   a `Queries.blockExtents(db, containerIDs: [postID])` read per id list.
7. **The manifest feeds the FACTS only** (the signpost's `offset/total/derived/exact`) — with
   the rows lazy, no row stands on it. The calibration pin holds it within a fifth of what the
   rows draw (0.975 / 0.996 / 0.988), so `offset=` is an honest estimate and `derived=` the
   honest count of blocks the face has never drawn (251 cold → 155 warm).
8. **The harness grew the `read-landing` scenario (in the seeded order) and one DEBUG probe
   read (`rl`)** — the brief's "one table row IF cheap": it was, and it is the unit's trial
   instrument and a standing tripwire. `ReadModeView.pageRestingAnchor` names the page's 0.08
   (unchanged) so the probe reads the product's constant.

### COST SHAPE (P1 / P3), stated

- **The extents:** O(the note's text) ONCE per block-id list, at a LANDING (never at a rows
  delivery, so never at autosave rate — pinned: an autosave-shaped re-delivery takes nothing).
- **The manifest:** arithmetic over the rows in hand at a LANDING — O(rows), no read, no layout;
  a per-block derived memo dropped on a new measure / voice / type scale.
- **Per scroll frame:** only the REALIZED rows' existing geometry observer does anything new
  (one closure: a box write, a no-op-guarded height learn, one string compare); the face's one
  scroll-geometry observer writes a box and, only while a landing is pending, one residual.
  P3 unchanged — the columns realize exactly what they realized before (14–15 rows on a landing).

### THE DRIFT CLASS (row 64's lesson), answered

Nothing she SEES stands on arithmetic: the lazy column draws every visible row at its real
height. The manifest's derived heights govern only the signpost's facts; a row that draws
reports its measured height (MEASURED > DERIVED), a new measure/voice/scale drops everything
learned (the stamp), and the lengths are taken again whenever the block-id list changes. The one
staleness: a block whose TEXT changes while the note stays in Read keeps its old length until the
id list changes — and that block is by construction the realized one, measured.

### SEAM FILES THIS DIFF TOUCHES (the reviewer reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `Surface/LandingAuthority.swift` | two `LandingSurface` cases (`ReadNote`, `ReadNoteEdit` — the closed vocabulary), two policies | `LandingSettle.decide`, the loop, the signpost's format and its content-free guard |
| `Features/ReadMode/ReadNoteLanding.swift` | NEW — `ReadLandingResidual` (pure), `ReadScrollFacts`, `ReadNoteHeightModel` (pure), `ReadNoteHeights` (the per-face manifest), `ReadLandingBox`, the DEBUG `ReadLandingStory`, `LandingAuthority.readNote(_:)` | — |
| `Features/ReadMode/ReadEditPane.swift` | the authority + box; `land` hands the SAME act to it; the scroll observer; `onScrollPhaseChange`; `onDisappear { landing.end() }`; `ReadEditBlock.onPlace` from its EXISTING observer + `onDisappear` | the `LazyVStack`, the rows, `PaneSurfaceView`'s mount and every argument, the click road (U0), the carry's capture |
| `Features/ReadMode/ReadModeView.swift` | the host holds the two manifests; `ReadPageColumn` the same adoption as the edit face; `ReadPageBlock.onPlace`; `ReadCarryGeometry.viewportFrame`; `pageRestingAnchor` named | the seed, `select`, the U0c opening arm, the carry, the click-through, `landIfPending`, the page's look |
| `Core/Views/VisualWalkProbe.swift` | the DEBUG `rl` read (+ `import SwiftUI`) | every existing field |
| `Tools/VisualWalk/` | `read-landing` (+ seeded order, README row), the Notification-Center column rule, `readedit-click`'s AX role | the guard order, the stamp, every other scenario |
| Tests | NEW `ReadNoteLandingTests` (4), `ReadNoteHeightsTests.swift` (`ReadNoteLandingArithmeticTests` 6, `ReadNoteHeightsCalibrationTests` 3); `LandingSignpostTests`' count | every other pin byte-unmodified |

**Not the editor seam:** `EditorTextView`, `EditorViewModel`, `PaneSurface`/`PaneTextView`,
`PaneTextAuthority`, `BlockRangeIndex`, `runStructural`, `JumpPrimitive` — none in the diff (the
edit face HOSTS the live pane exactly as before). **Review cast per the brief: OPUS.** (The
cast's letter also names "landing … code" for Fable; the authority's loop is untouched — two
vocabulary cases and two policies — the orchestrator's call if it reads that line strictly.)
Zero `Sources/`, `Shared/`, `Sync/`, schema, `Server/`, mobile.

### NOTICED, NOT TOUCHED

1. **The health review §1.2's note-Read diagnosis did not reproduce** on the real fixture
   (piece 2b) — the review is not this unit's pen; a dated line there is the orchestrator's.
2. **The face switch lands the other face on the selected block** (a request parked for the
   unmounted face) — pre-existing, now watched; noted because the trials' "second face" rows
   ride it.
3. **A mode switch right after a first open lands block 1** (W1 Terminal — the opening ends at
   the switch, so the seed scrolls to the first row; clamped home, the page at its start) — U0c's
   rules composed exactly; nothing visible.
4. **`readedit-click`'s AX lookup was latently wrong** (fixed, machinery note 2).

### OWED AT CLOSE (drafted for the orchestrator)

- **THE LEDGER row 7:** BUILT+WALKED as (B) — the watch in both faces, the manifest for the
  facts, the lazy columns kept (#151); the cold line met: 12/12 truly cold `hops=0`.
- **QUESTIONS #151** → her bundle (the one departure from the charter's letter, with both
  measurements).
- **AppSpec:** none required (no contract line names landing internals); optional §12 pointer:
  *"note Read's landings are watched by the one landing authority (18l U1)."*
- **KnownIssues:** none opened, none closed (no row owned note Read's landing).
- **The health review §1.2** (optional, the orchestrator's pen): a dated line that note Read's
  one-shot was measured exact on the real fixture at 18l U1; the synthetic class is the one
  reproduction, now corrected.
- **MOBILE PARITY:** the phone's long-note Read inherits THIS shape, not the Index's — the one
  authority watching its lazy column's own landing, the fraction residual, the signpost; a
  `notes/MobileSoul.md` row (the mobile project's pen). Nothing mobile-visible changed.

### ROUND-1 FIX PASS (2026-09-26 — the ladder file `notes/plans/18l-u1-ladder-round1.md` carries the table)

All six confirmed findings fixed, each pin red-first: **MAJOR-1** her click / her edit in Read ▸ edit's
pane ends a landing in flight (`5a7e5ce5`; `ReadEditPane`'s closures only — `PaneSurfaceView` untouched);
**MINOR-1** `LandingPolicy.seedsFromLastReport` false on note Read (`901392d9`); **MINOR-2** the story reset
per mount + matched by placement id (`6f1172c7`); **MINOR-3 — option (a), PROVISIONAL (one line, as the
orchestrator asked): the manifest keeps its place with the REAL content-space leading and a documented
meaning for note Read's offset/total, rather than honest unknowns, until #151 rules** (`7678a362`);
**NIT-1** (`9e887d50`), **NIT-2** (`66dcf17d`). Closing set 214 / 37 green; harness `read-landing` 12/12 +
12/12. Round 2 is a fresh reviewer's.

### SELF-ASSESSMENT

Strong: the unit measured before it built and built what the measurement said — a pre-fix app
baseline (12/12 exact, zero Console lines, a burst of captures), the charter's own shape built
and measured on the real story (59 pt off + a hop) before being rejected, and a post-fix table
of 72/72 `settled hops=0` with the Console flip captured; red-on-old is the pre-fix pin run
(RED 2/2) AND a named behavioural revert that red exactly as predicted (4 tests / 10 issues);
the resting anchors, the U0c opening arm, the carry and the click road are untouched; the diff
is off the editor seam. **Weakest points for the reviewer:** (a) **JC 1 departs from the
charter's letter** — the evidence is strong but it is a ratified unit's shape, so the
orchestrator must confirm it (and #151 carries it to her); (b) the red-on-old rests on a
SYNTHETIC shape — the real fixture had nothing to fix before, so the unit's user-visible gain on
her story is the watch itself (the signpost, the hand-over, the watchdog) plus robustness for
shapes like the synthetic; (c) the residual trusts SwiftUI's `scrollTo(_:anchor:)` fraction
semantics and a zero content inset (verified only by 72 settles at |rl| ≤ 0.2 and the pins, not
by an inset-bearing window); (d) `correctsAnUnreportedTarget` true allows blind re-aims on a
lazy column (budget 3; the Index measured blind hops FLINGING its oscillating column — note Read's
column does not oscillate, but a pathological note could make three blind hops visible); (e) the
harness scenario's filter road is a real user road but not the only deep-click road (the walk
covered visible-row clicks, the click-through, the carry and the hand-over). **U1 — DONE
(implementer); the cold review follows.**

## MORNING BUNDLE (accumulating — the handoff's first section copies this)

1. ~~A macOS consent prompt on screen~~ **RESOLVED at her check-in** — she clicked Don't
   Allow. (The traps' system-dialog rules remain standing law for every future run.)
2. **#149** — the 13g surface-rule carve-out (R-18l-5): formatted read tiers may seed a caret
   through the pinned translation, vs. switching those tiers to the dimmed-marker face.
3. **#150** — U0c's two refinements of your R-18l-1 (first open seeds no fact — `t-11` is the
   measured reason; a re-open restores the page without revealing an off-page caret).
4. **S3, a taste call** — the read tier and the live pane wrap slightly differently, so a
   clicked block shifts a little as it goes live (the caret still lands right). Share metrics,
   or keep the tiers distinct? (KnownIssues row, Design & UI review owner.)
5. **The U-VIS design ratification** — the design note + the built harness (its first full run:
   10 scenarios × 2 voices, 0 unexplained failures; it can red — proven twice).
6. **Your four sitting rulings to confirm as standing:** R-18l-1 (note-open), R-18l-2 (facts),
   R-18l-3 (run all, split if heavy), R-18l-5 (the carve-out) — plus R-18l-4 discharged.
7. **B5 / KnownIssues row 88** — the one UNTRACED find (⏎ after ⌘↓ on invalidated geometry
   moves the text above the caret ~30 pt; Study, deterministic recipe in the harness); owner
   18l, trace at U3 or its own slot — or re-owned at closeout if the round splits.

### U1 — ORCHESTRATOR ACCEPTANCE (2026-09-26; verify-never-trust)

**Claims verified:** all 15 commits pushed, tree clean, pins present, LIVE STATUS flipped.
**The walk, in the orchestrator's own hands on a fresh build of `2eff1b27`:** *A Case of
Identity* (137 blocks) — first open at the START (U0c holding); Read ▸ edit; a deep outline
click (row 24) landed the block AT the center anchor, visually confirmed; the Console signpost
now SPEAKS on note Read — two lines captured live (`surface=ReadNoteEdit … end=settled top=0
hops=0` for both the mode entry and the deep click). The health review §1.2 diagnostic is
FLIPPED in my hands as well as the implementer's.

**JUDGMENT CALL 1 — CONFIRMED (PROVISIONAL, QUESTIONS #151, hers to overturn):** the charter's
placeholder-manifest half was BUILT, MEASURED WORSE (a 59-pt cold miss + a ~1 s jump — failing
the charter's own hops=0 line), and rejected; the watch alone shipped. The charter's remedy
assumed the Index's disease (whole-note rows, heights oscillating by tens of thousands of
points); Read's rows are BLOCKS and the lazy estimate is near-exact on real prose (calibration
0.975–0.996). The acceptance metric outranks the letter, on measurement — the round's standing
hierarchy (R-18l-5's own form). The honest baseline is also recorded: §1.2's stutter did NOT
reproduce on the real story pre-fix; U1's durable gain is the WATCH (signpost + watchdog +
hand-over) and the synthetic-note class fixed. Ledger row 7 flips to BUILT+WALKED — the Opus
cold review is the remaining gate; the review cast stays OPUS (no seam body touched;
`LandingAuthority` gained two surface names + policies, data not loop).
