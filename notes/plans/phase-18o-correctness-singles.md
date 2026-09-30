# Phase 18o — CORRECTNESS & HONESTY SINGLES (opened 2026-09-29 at her word)

**STATUS: OPEN — unit U1 next.** Fresh FABLE orchestrator/architect (her R-18k-10 remedy: *"18o
gets a fresh FABLE orchestrator at her word"* — this session is that word). Record file authored
as the phase's first act per her kickoff instruction (the file was referenced in many places and
never written; every referenced issue is pulled together below).

**What this phase is:** the correctness-singles session minted at the 18k kickoff sitting
(R-18k-1, her words: *"plan a single extra session, split items appropriately between them, give
it an 18 name"*) — 17e's non-concurrency remainder + **17t** (the two unwired protection doors,
R-18k-2) + the ruled builds #138(f) (R-18k-5) and R-18k-6 + the provisional #146 + the three rows
18k's units handed forward (the Open strip's tenth-row trap · the ⌥⌘⇧M ceremony branch's stale
read · the future-stamped backup). Every item below is pre-ruled or pre-traced; nothing here is a
design phase. Master plan row 18 carries the mint; `notes/plans/post-13u-health-rounds.md` row
"18o" points here.

---

## THE SITTING RECORD (kickoff, 2026-09-29)

- **Her paste, verbatim:** */architect-phase* *"18o - I believe the plan file is referenced in
  many places but hasn't been written, so your first act as architect will be to pull all of the
  referenced issues together & write a plan file for yourself. Implementers Opus, cold review
  fable at the end, cold review Fable where needed (sync, etc.)"*
- **The cast, as she directed (read faithfully):** `opus-implementer` per unit, strictly
  sequential, fresh per unit · **ONE FABLE cold-review ladder AT THE END over the phase's
  combined diff** (a fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md` verbatim, zero
  framing; hard cap three rounds) — the Fable seat satisfies the custody rider (17t), the editor
  seam's pair (row 79) and R-18k-6's Fable-review note in one ladder · Fable orchestrates (this
  session) and writes no feature code EXCEPT unit U6 (next bullet).
- **U6's seat (#146) — the orchestrator's cast call, pre-authorized by the ruling's own text**
  (QUESTIONS #146 build note: *"the retirement is decided where the arriving tombstone meets the
  local copy, which is likely `Sources/VariorumCore/Sync/` … Fable implements and reviews it, and
  18o's orchestrator casts accordingly or re-owns it to 18a with the ruling attached"*): the home
  IS `Sync/` (`SampleLibraryDedupe.swift`), so **this Fable seat implements U6 itself** under
  CLAUDE.md's standing rider ("any change inside `Sources/VariorumCore/Sync/` is Fable work");
  the end ladder's fresh `fable-reviewer` cold-reviews it with everything else. Her kickoff's
  "cold review Fable where needed (sync, etc.)" anticipates exactly this. If she prefers the
  re-own to 18a, it is one word — flagged in her bundle.
- **Superseded line, noted:** the master plan's "runs right after 18k under the same
  orchestrator" was superseded by R-18k-10 (the 18k seat was Opus; her remedy names a fresh Fable
  orchestrator, which this is).
- **Her real-store instance:** state UNKNOWN at kickoff — checked by PATH before every
  GUI/refresh act; the closing install refresh (R-18k-3: *both 18k and 18o close with the
  Release → `/Applications` refresh*) runs only at a verified zero-instance window, else HELD
  and bundled.
- **Autonomy:** PROVISIONAL-and-continue for non-gating ambiguity (each logged to
  `notes/QUESTIONS.md`; next free number **#160**); author-only calls are hard stops, HELD and
  BUNDLED. Her standing bundle from 18m (#155–#159, row 70's redirect, F-4's priority eye) is
  SURFACED at the closeout, never re-decided here.
- **HER AWAY GRANT (2026-09-30, after U1's close, verbatim):** *"i've now closed my real store
  and am stepping away from the computer, so go ahead and run whatever you need to"* — verified
  the same minute: `pgrep -fl 'Variorum.app/Contents/MacOS'` empty. Read as: the away-run rule
  governs (PROVISIONAL-and-continue; author-only calls HELD and BUNDLED); GUI driving and the
  HELD U1 walks are free (the per-step guard still runs as machinery hygiene — she may return
  at any moment); the phase-close install refresh has its window when the ritual reaches it,
  instances re-verified at execution time as always. Her app is NEVER relaunched by a session.

## BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied byte-verbatim per the skill's rule; the application notes in `.claude/skills/architect-phase/SKILL.md` bind with them)

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

## STANDING RULES (restated VERBATIM in every unit brief — they bind every session)

Pin before fix — the red-on-old pin binds exactly as in a phase review, verified by behavioural
revert; a pin green on both sides dismisses the item as hollow (recorded, not fixed). No finding
is fixed until the fixer has traced the concrete mechanism themselves. Commit per coherent piece,
LIVE STATUS in this file from the first commit, push after every commit, synchronous foreground
waits only (poll logs with a `grep -q … && break; sleep 5` loop, never `tail -f | grep -m1`),
never spawn subagents (repo reading is never delegated; at most ONE Sonnet lookup for EXTERNAL
facts, read-only). NO commit trailers (her 2026-09-04 rule — overrides the harness reminder).
Tests at the END of a unit against the last recorded finals, never the full suite at a session's
start. PROVISIONAL-and-continue for non-gating ambiguity (log to `notes/QUESTIONS.md`);
stop-and-report for gating ambiguity and every author-only call. A unit closes only on use-shaped
evidence of its kind — a pin or a mount smoke alone never closes it; the orchestrator walks (or
runs the drill for) each unit before its record closes. `notes/SessionResiliencyProtocol.md`
binds whole (commit before any revert; pre-revert state committed; deaths recorded).

## READ-FIRST (every implementer, in this order; per-unit additions in the briefs)

`CLAUDE.md` + its auto-loaded canon · this file WHOLE (it is readable in full — that is a rule) ·
`notes/KnownIssuesAndTechDebt.md` (the header rule; you will edit rows) ·
`notes/SessionResiliencyProtocol.md` · the 17-file's **17e** section
(`notes/plans/phase-17-standing-fixes.md` — the P-item briefs with their verifier traces are the
binding finding records) and **17t** section · the 18k kickoff sitting
(`notes/plans/phase-18k-runtime-hygiene.md` "THE KICKOFF SITTING" — R-18k-1…R-18k-10). U4 adds
the 18k UNIT C1 RECORD; U5 adds QUESTIONS #86(c)/#87; U6 adds `notes/SyncSpec.md` IN FULL +
`notes/sync-postmortem-fragments.md` + QUESTIONS #146. **TEXTKIT2_NOTES is NOT required** — no
unit touches `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/the read tier; if any diff drifts
onto that seam, STOP, read it, and tell the orchestrator (the ladder seat is already Fable).

## ENVIRONMENT TRAPS (carried into every unit brief VERBATIM — 18m's set, with this kickoff's dated notes)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — NEVER quit or
  kill one; no Release builds or `/Applications` refreshes while one lives. Xcode Run = Debug =
  the fenced dev store (`io.lduarte.Variorum.debug`). **Dated note (updated 2026-09-30, her
  away grant): her real-store app is QUIT at her word and she is away — zero instances verified
  by pgrep; GUI driving is free behind the per-step guard (run it anyway — she may return);
  re-verify instances before every Release build / refresh / walk burst as always.**
- **An old build must NEVER open the dev store** — bisect by harness in a scratch worktree
  (in-memory store), never by running an old build against a live store (the 18k C2 precedent).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test`
  with SUITE-LEVEL `-only-testing` only; confirm the "Test run with N tests" line (Swift Testing
  counts SKIPPED tests in N — read the `skipped:` lines). `build-for-testing` compiles without the
  runner. zsh: `pipestatus`. NEVER add a custom build configuration (any configuration not named
  exactly "Debug" builds the SPM packages Release and silently strips VariorumCore's DEBUG
  oracles). **Mobile tests: `xcodebuild -scheme VariorumMobile` against the iPhone 17 Pro
  simulator; the generic-iOS build (`-destination generic/platform=iOS`) proves compilation where
  a unit touches `Shared/` or `Sources/` without a simulator run in between.**
- Suites running beside a live session flash the test host's windows; the pointer-injection
  suites (KnownIssues row 93) red if anyone uses the machine — a full run that must be trusted
  runs with nobody at it. Prefer zero-instance windows for timing-sensitive measurements. The C2
  inline pins red when the DEV STORE's voice is Study (row 91) — restore Terminal after any walk.
  **Every Mac test run's host launch runs the dev store's backup tick (the 18k C7 trap) — never
  read the dev `Backups/` folder's contents as a unit's own evidence without checking stamps.**
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only. Accessibility + Screen
  Recording are granted to Ghostty. Walker facts bind: a single `cliclick` click is sometimes
  swallowed by activation — click twice on an idempotent row; the landing signpost reads back via
  `/usr/bin/log show --predicate 'eventMessage CONTAINS "landing surface"'` filtered on `end=`;
  `walk-scroll` positive line count = DOWN; the ← → history bar appears after the first
  navigation and pushes rows ~17 pt down. Screenshots into gitignored dirs
  (`notes/plans/18o-screens/…`). **Dated note: until U3's fix lands, a Debug walk must keep
  FEWER THAN TEN notes open in one window (KnownIssues row 73 traps the Debug build at the Open
  strip's tenth row — 18m's walks hit it; a crash-reporter window from that may still be on her
  screen, hers to dismiss).**
- **SYSTEM DIALOGS:** before any GUI burst, check for foreign dialogs over the work area; never
  click a point a system dialog covers; never type unless OUR window is key. **A consent dialog
  is ANSWERED BY THE AUTHOR ONLY**; if one appears, record it, work around it or hold, and put it
  at the top of her bundle. Never osascript an app that is not ours.
- **NO GUI DRIVING WHILE THE AUTHOR IS AT THE MACHINE:** (1) check HID idle BEFORE EVERY GUI
  step — recent input (< a few seconds) means STOP and wait or go harness-only; (2) verify the
  TARGET window immediately before each click; (3) any doubt → harness-only until the machine is
  genuinely author-free (drives need unlocked + author-free + own `caffeinate -d`).
- **VisualWalk (17w's hazards, until 17w runs):** a scenario must never TYPE after a failed
  keyboard probe; the full-suite `takes-find` is order-dependent; prefer `--only` scenario
  subsets; verify fixture preconditions before trusting a red.
- Backups: WAL-safe, UTC names, ALWAYS before touching the real store; into the SUBFOLDER
  `Backups/safety-copies/` (R-18k-8), never loose in `Backups/`.
- Never `git checkout` over uncommitted work (commit before any revert — resiliency addendum 11);
  push after every commit; never rewrite pushed history. Staging is pathspec-limited
  (`git add <files>`, never `-A`). The harness's instance check can self-match a caller's own
  compound command line containing the pattern text — run drivers in a command that does not
  spell `Variorum.app/Contents/MacOS`.

## BASELINES (the last recorded finals — never rerun at a session's start)

18m's (2026-09-29): Mac per-unit closing sets green (U3's widest **1,145/144**); the FULL mobile
suite **654/112 = the 4 known + F-1** (F-1 is #155's, attributed — NEVER re-attribute); core
~~untouched since 18k's finals (1723/180)~~ **1730/181 pre-U1** (this line was stale as written —
18l U0 `83f6f317` +6/+1 and 18l-c U8 `dfe5a895` +1 touched core after 18k; caught by U1's
closing-run arithmetic, corrected here 2026-09-29; **1737/182 after U1**, +7/+1 = P34's 2 + P35's
5); the last full Mac run 18k's **3168/522** (the only reds the row-93 pointer-injection class
with someone at the machine); iOS generic build green; install `/Applications` binary
`3b116e5c…` (18m's refresh). VisualWalk baseline unchanged from 18l-c.

---

## THE LEDGER (every row owned; dispositions land here; the 17-file gets the 17e/17t copies at close)

| # | Item (source) | Unit | Status |
|---|---|---|---|
| 1 | **P29** — the phone's redo door documents a mechanism the code does not have (`MobileUndoDoor.swift:225` false comment; behaviour deliberate, comment owed) | U1 | **FIXED (doc-only) `e2a6ecf0`** — no pin (a comment cannot fail a test; none minted) |
| 2 | **P32** — scratch-column picks ARE persisted, so `danglingPick`'s lens-only scoping rests on a false premise (`TakesViewModel.swift:1196`); fix the comment, NAME the UX gap (R-18k-1's letter: "P32's UX gap named" — a QUESTIONS row with options, not a build) | U1 | **FIXED (doc) + RECORDED `a1479bba`** — QUESTIONS **#160** (options, (i) recommended; OPEN, hers) |
| 3 | **P34** — `BoundarySnapping.settle` overrides an exact placement when a strong boundary sits exactly `settlePull` earlier; the absolutist doc parenthetical + the missing boundary pin (doc + pin; behaviour stands PROVISIONAL, QUESTIONS row) | U1 | **FIXED (doc) + PINNED `9068f624`/`54f91c72`** — documented-behaviour pins, proven able to fail (M-exact → 3 issues); QUESTIONS **#161** |
| 4 | **P35** — `shelf_pins` never self-heals; a deleted book's pin is stuck forever (`Operations+Appearance.swift:117`; `starred` in the same file is the model) | U1 | **FIXED `915e8124`** (pins `0ae75e59` — red-on-old 4 issues; R-P35 identical; orchestrator re-ran 47/4 green) |
| 5 | **P37** — the tray's ARCHIVED listing silently truncates at 500 while its siblings render markers (`TrayPanel.swift:400`) | U1 | **FIXED `6c61d562`** (pins `74d4c45a` — red-on-old 1 issue; R-P37 identical) |
| 6 | **17e (12)** — `.toggleSidebar` declared `availability: always` while its menu item greys on `activeWindowKind != .full`; a `windowKind` field on `CapabilityContext` makes the grey a registry fact (P-1) | U1 | **FIXED `e724032f`** (pins `b24d801a` — red-on-old 3; R-T12 reds all four, 8 issues). The sweep's second family (creation/restore) NOTICED 1 → KnownIssues at closeout, owner 12's registry-walk family |
| 7 | **Row 84** — a backup copy stamped in the FUTURE silently stops automatic backups and the freshness face never turns stale (`StoreBackup` due-checks; 18k C7's noticed item 1) | U1 | **FIXED `1c18420d`** (pins `09f9e199` — red-on-old 14 issues; R-84 identical; C7's pins rode UNMODIFIED; widened to the weekly export — judgement call 2, accepted). QUESTIONS **#162** (PROVISIONAL (a)) |
| 8 | **Row 64 — RECORD-ONLY (R-18k-4, *leave it for now*):** re-verify the documented-behaviour pin (`ContentReplacementRedoTests.anUndoEntryOlderThanARestoreCanStillReviveIntoTheRestoredNote`) green; record the ruling in the ledger + the 17e copy; no build | U1 | **RECORDED** — pin green 5/5 (re-verified by the orchestrator too); closeout adopts the row's option (i) close-as-ruled wording |
| 9 | **17e (11) — RECORD-ONLY:** partly discharged by 18d (`RecoveryView.swift:489`); the remainder ACCEPTED on KnownIssues' per-note-view-state row (owner 12) — 18o records the disposition in the 17e copy; no build | U1 | **RECORDED** — with the NOTICED-3 correction (postMode/readFace/takesViewMemory evicted by no road); the per-note-view-state row's text amends at closeout |
| 10 | **P23** — a CRLF file imports as ONE block: `SegmentationRules` splits on `"\n"` only (`Sources/VariorumCore/Domain/SegmentationRules.swift:67`; MAJOR; the family keys on `Character.isNewline` — only the segmenter disagrees) | U2 | **FIXED `12d61080`** (pins `40c3aafc` — red-on-old core 29 · Mac 6 · mobile 3; R-P23 identical ×3; M-isNewline proves the rejected design breaks the typed-road guards; normalise-at-entry, judgement call 1). Walk W1 both voices |
| 11 | **Row 66 / #138(f), RULED R-18k-5 (*honour the tombstone at launch*):** the LAUNCH seeder declines on a tombstoned seeded book exactly as the tutorial door's silent ensure does (`SampleLibrarySeeder.seedIfNeeded`, launch call `VariorumApp.swift:196`) | U2 | **FIXED `14822213`** (ONE predicate `readerDeletedTheBook`, both deciding reads, decision recorded in the mark; pins red-on-old Mac 15 · mobile 2; R-66 identical; M-early/M-late each red their own pin). Walks W2 + W3 (explicit restore still mints) |
| 12 | **Row 73** — the Open strip's ⌘⇧<n> menu TRAPS at its tenth row in Debug (`EditorCommands.swift:782`; check the `:746` ⌘<n> sibling too); shortcuts for rows 1–9 only (PROVISIONAL), pin mounts the menu with ten open notes | U3 | **FIXED `ee2e1292`** (scaffolding `060cc060`; pins `112921bc` — red-on-old 25 issues; R-73 identical; the table shape makes the trap a test failure, not a runner abort; the ⌘<n> mode-key sibling verdicted SAFE by its cap + pinned; **a second real defect on the same row found and fixed** — rows 10+ never OPENED on click, now every row opens the note it names). Walk W1 |
| 12b | **The microsyntax CRLF edge (adopted from U2's NOTICED 1 — P23's class at a sibling brain, in-theme):** `CaptureMicrosyntax.parse` walks lines on the literal `"\n"` (`App/Variorum/Shared/CaptureMicrosyntax.swift:111`) — in a CRLF capture rule 5 (a token-only line leaves with its newline) never fires and rule 2's one-line promise can be crossed. Fix: read the input through `SegmentationRules.normalizedLineEndings` at `parse`'s entry (App CAN see core; the output already normalises downstream at `bulkSegments`, so no double effect); pins red-on-old for both misread rules | U3 | **FIXED `cefde52b`** (core access `d2a63c43` — `normalizedLineEndings` public, body byte-unchanged; pins `b21b0c7f` — red-on-old 22 issues incl. the swallowed-capture worst case; R-12b identical; M-afterfast pins the placement; both existing microsyntax suites UNMODIFIED). Walk W3 both voices |
| 13 | **Row 79** — ⌥⌘⇧M's CEREMONY branch reads the frozen `slots`: a mid-burst take makes it wrongly refuse "needs a fan", and a mid-burst archive falls through `openMergeCeremony`'s truth read into an INSTANT merge instead of its ruled refusal; the P27 fix (`liveActiveFans`, store-read authorization) is the shape (`EditorSurfaceController`, the `.merge` arm) | U3 | **FIXED `fbd5c55f`** (pins `539d830f` — red-on-old 4 issues 2/2 + the stale receipt; R-79 identical; M-guard/M-fallthrough each red their own half; `FannedDefaultsTests` UNMODIFIED). **Design divergence ADJUDICATED ACCEPTED** — the U3 adjudication. Walk W2 both voices |
| 14 | **Row 78 / R-18k-6, RULED:** a note edited INSIDE A BOOK gets its leaving savepoint when she moves into a different note (or leaves the book), through the existing `savepointOnLeaving` road; Compare peers follow the same rule PROVISIONAL (QUESTIONS row) — the 18k C1 RECORD's machinery (`markLeaving`/`dropAfterLeaving`, the acquisition generation) is required reading | U4 | **FIXED `f3ab836e`** (pins `385fbaeb` — red-on-old 13 issues, all five bug pins; R-U4 9 issues identical; three guard mutations each red their own guard; `BookNoteTrail` pure over the note box's state; roads 5–6 declared in `SavepointOnLeave`'s own registry, ONE entry, zero AppSession/Operations lines; C1/L-d/J11 files UNMODIFIED; orchestrator re-ran 26/5 green). QUESTIONS **#163** (both PROVISIONAL readings). Walks W1–W3 PASS |
| 15 | **17t item 1** — the typed NEAR-EMPTY sync confirmation (#86(c), ruled: warn + TYPED phrase, never refuse, never click-through; home #87: "with the rebuilt Replace Keys"): `Sources/VariorumCore/Sync/RekeyRecencyProbe.swift` has ZERO app consumers — wire the warning face + typed confirmation into the rebuilt Replace All Keys. Consume the probe from App; ZERO `Sync/` edits (a needed probe change is a stop-and-report → Fable work) | U5 | open |
| 16 | **17t item 2** — COPY ALL on the recovery phrase exists in ONE place (Mac `ProtectionPane`, 60 s clipboard clear): wire the SHARED `SyncEnrollmentView`'s dead "Copied" branch + the Mac call sites (`KeyDoorModel.markWordsCopied` · `SyncEnrollmentModel.markWordsCopied` · `PostureSwitchModel.markWordsCopied` declare it; one call site exists). The phone's three word-screen doors stay the MOBILE APP ROW's — zero phone faces here | U5 | open |
| 17 | **#146, PROVISIONAL (hers to overturn):** the signed-out-first phone's seeded copy — at first sync where the account holds the shipped book DELETED, an UNTOUCHED (pristine, by the dedupe's own test) local copy is retired quietly into this device's Trash; an EDITED copy is never retired. Home: `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift` — **FABLE work, this seat** | U6 | open |
| 18 | The end LADDER (fresh `fable-reviewer` per round over the combined diff; cap three; every finding gets a written disposition here) | ladder | open |
| 19 | Closeout: dispositions copied into the 17-file (17e + 17t); KnownIssues rows 54 · 55 · 64 · 66 · 73 · 78 · 79 · 84 resolved or re-owned; QUESTIONS rows landed (#160+); master plan row 18 + closeout-log paragraph (18m's paragraph rolls to the archive); MOBILE PARITY line; the author handoff; the install refresh per R-18k-3 at a verified zero-instance window (else HELD + bundled) | closeout | open |

## SIZING (the guidance statement, said out loud per `notes/PhaseSizingGuidance.md`)

Zero phase-sized units — this is a singles roster (the 18k / RUN A shape: one roster, each item
independently scoped, cast, run and closed). Seven build sessions (six Opus units + one
Fable-seat unit), one acceptance unit per implementer session, each closing on evidence of its
kind (pins + walks; U6 on convergence suites). Within the guidance as read; if any unit grows a
second unit mid-flight, it hands off with a record rather than "also doing" it.

---

## THE UNIT ROSTER (strictly sequential: U1 → U2 → U3 → U4 → U5 → U6 → the ladder → closeout)

### U1 — the honesty & paper-cuts batch (`opus-implementer`)

Ledger rows 1–9. Seven small fixes + two record-only dispositions, no shared mechanism — the
catch-all half of 17e, each item's binding brief the 17-file's own P-section (read the VERIFIER's
trace for each; where the finder and verifier differ, the verifier wins).

- **P29:** correct `MobileUndoDoor.swift:224-226`'s doc to the truth its own family already
  states (`StructuralUndoCopy.discardingUndoQuestion`'s vocabulary; `reapplyStructural` DOES
  overwrite a since-edited buffer behind a quiet insurance commit). Comment-only; no behaviour
  change is owed (A12 named undo alone, deliberately). No pin possible for a comment — say so in
  the record rather than minting a hollow one.
- **P32:** fix the false-premise comment at `TakesViewModel.swift:1196-1198` (scratch picks ARE
  persisted via `TakesViewMemory`); land a QUESTIONS row (#160+) NAMING the UX gap with options —
  (i) extend the J5 dangling-pick notice + Restore button to scratch columns, (ii) prune scratch
  picks at archive/delete, (iii) accept-and-record — recommended option first. Do NOT build the
  extension (R-18k-1's letter is "P32's UX gap named"; the J5 ruling as recorded is lens-scoped,
  so extending is a product call).
- **P34:** correct `BoundarySnapping.swift:130-131`'s absolutist parenthetical ("the deliberate
  placement always wins" is false at strong-boundary gap ≤ `settlePull`); add the missing
  BOUNDARY pin (the ". I " / ". A " configuration — `settle(7, in: "Yes. I went home.")` returns
  5, pinned as documented behaviour, red if it ever changes silently). Behaviour stands
  (the verifier's read: the pull doing its job); a QUESTIONS row records the exact-wins
  alternative as hers. Core `Domain` → `swift test` at the unit's end.
- **P35:** `setShelfPinned` self-heals like its sibling `starred` (`Operations+Appearance.swift:164-167`
  is the model): every write prunes ids with no live reading; the unpin door works on a deleted
  book (the `liveReading` guard is the unpin-blocker — re-shape so removal never requires a live
  row). `setting` is synced metadata (server-wins CAS) — ordinary op writes, zero `Sync/` lines.
  Pin red-on-old: pin a book, delete it, unpin refuses on old / heals on new; the stored JSON
  sheds the dead id. Note `MobileTutorialSeeder.swift:179`'s caller-side workaround — leave it
  (harmless), name it in the record.
- **P37:** the ARCHIVED arm adopts its siblings' windowing (`TrashListing.windowed` or the
  `deletedTruncated` shape) + a `truncation("archived")` marker row; pin at window+1 rows
  red-on-old. ("Bounded view windows show markers, not more" — the standing rule this drifted
  from.)
- **17e (12):** `CapabilityContext` gains `windowKind`; `.toggleSidebar` declares the rule its
  menu item already enforces; the registry-walk suite asserts it (P-1: gating is data). Check for
  other capabilities silently gated the same way while there — enumerate in the record, fix only
  `.toggleSidebar` unless another is one line.
- **Row 84:** the due-checks treat a newest stamp LATER than now as due (or ignore future-stamped
  copies for freshness), and the freshness face turns stale honestly on a future stamp; pin
  red-on-old (a future-stamped fixture file; the 18k C7 `BackupOwnFilesTests` form). Data-safety
  class — the fix must not disturb C7's own-dated-names rule (its pins ride unmodified).
- **Records:** row 64's pin re-verified green + R-18k-4 recorded; 17e (11)'s disposition line
  drafted for the 17-file copy.

**Scope fence:** zero `Sources/VariorumCore/Sync/`; zero editor seam; P34/P23-class core edits
are `Domain` only. **Evidence:** red-on-old pins per fix (behavioural revert verified); focused
Mac suites + `swift test` (P34) + the mobile build (P29 touches a phone file — run the FULL
mobile suite); orchestrator walk of the tray marker + shelf unpin + the Settings sidebar door
where the machine allows.

### U2 — the import & launch-seed batch (`opus-implementer`)

Ledger rows 10–11.

- **P23 (MAJOR):** make `SegmentationRules` key on `Character.isNewline` (the family's own rule —
  `BoundarySnapping.paragraphBoundaries`, `MarkdownSyntax`, `MarkdownEditing`, `MarkdownRendering`
  all agree; only the segmenter uses a literal `"\n"`), or normalise at the segmenter's entry —
  implementer's call, traced and stated. Pin red-on-old with a CRLF fixture (none exists anywhere
  in the suite — the verifier checked): a CRLF `.md` imports as one-block-per-paragraph in
  `.paragraph` mode; cover `.sentence` and `one_block` arms + the quick-note and mobile-capture
  doors (same `importPost` road). Core `Domain` → `swift test`; the phone inherits the fix
  through the shared op — FULL mobile suite at the unit's end; name it for the MOBILE PARITY
  line.
- **Row 66 (R-18k-5):** `SampleLibrarySeeder.seedIfNeeded`'s LAUNCH road declines on a tombstoned
  seeded book exactly as the tutorial door's silent ensure has since pre-13x F3 (MINOR-N3) — read
  that mechanism first and reuse it, never a second tombstone-reading rule. Pin red-on-old: a
  store holding the book TOMBSTONED (arrived by sync, no local mark) is not re-minted at launch;
  guards: a store with NO copy and no tombstone still seeds; a purged-tombstone store (the (e)
  residual) stays the documented gap — record, don't widen (the travelling marker was option
  (iii), not taken). Explicit doors (Help ▸ Restore) stay unchanged — pinned as guards.

**Scope fence:** zero `Sync/` (the seeder is `App/Variorum/Shared/SampleLibrary/`); the dedupe
is U6's — do not touch it. **Evidence:** pins + `swift test` + FULL mobile suite; an in-app
launch-road check on a scratch store if cheap (never the dev store with an old build).

### U3 — the two Mac doors (`opus-implementer`)

Ledger rows 12–13.

- **Row 73:** `EditorCommands.swift:782` builds `Character("\(index + 1)")` for every open note
  (strip holds up to 20 since `a9772471`); Debug traps at row ten (`_debugPrecondition` in
  `Character.init`, compiled out at -O — Release most likely builds a malformed two-grapheme key
  equivalent). Fix: key equivalents for rows 1–9 only (rows 10+ render without shortcuts) —
  PROVISIONAL (QUESTIONS row if any alternative is materially different); check the `:746` ⌘<n>
  sibling site and verdict it in the record (fix if the same class, prove safe if capped). Pin:
  mount the menu with ten open notes — red-on-old (the crash report is
  `notes/plans/18k-screens/c1/open-strip-tenth-note-crash.ips`).
- **Row 79:** the ⌥⌘⇧M / "Merge choosing takes…" branch authorizes its CHOICE from the store
  (`liveActiveFans` — its own doc: "From the store — never `model.slots`") exactly as P27's fix
  did for the unfanned branch (`dee61938`; pin `FannedDefaultsTests.aFanArrivingWhileSheIsTypingIsCarriedByTheMerge`
  is the form). Both directions pinned red-on-old: a take born mid-burst → the door opens the
  ceremony instead of refusing "needs a fan"; a take archived elsewhere mid-burst → the door
  speaks its ruled refusal (`mergedBlockWouldHaveNoTake` family) instead of falling through to an
  instant merge. Note for the record + ladder: this adds one more await before `runStructural`'s
  flight flag — the same window the carry-all/seam roads already carry (18k C5 NOTICED 5); a
  second structural act inside it is refused by `runStructural`'s own guard.

- **Row 12b (adopted at U2's adjudication):** `CaptureMicrosyntax.parse` reads its input through
  `SegmentationRules.normalizedLineEndings` (core, U2's own function) at entry — the ledger row
  carries the mechanism; pins red-on-old for the two misread rules (a token-only CRLF line
  leaves with its line break; an unclosed `{#` never scans across a CRLF); the existing
  microsyntax pins ride UNMODIFIED (LF behaviour byte-identical); both Mac capture doors and
  the shared brain covered — zero phone files (the phone's capture face is the catch-up's).

**Scope fence:** `EditorSurfaceController` is the editor seam's PAIR — the end Fable ladder
covers it (per the cast); `EditorTextView`/`BlockRangeIndex`/`PaneSurface` untouched. **Evidence:**
pins red-on-old + a walk: open ten notes (the fix makes the walk survivable — this unit retires
the walk trap), fire ⌘⇧M/⌥⌘⇧M on a fanned pair through the menu.

### U4 — the book leaving savepoint, R-18k-6 (`opus-implementer`)

Ledger row 14. Her ruling verbatim: *"a note edited inside a book should get a savepoint when you
open it"*, clarified at once to **"When I move to another note"** — in a book, the note she
edited gets its leaving savepoint when she moves into a different note (or leaves the book),
exactly as leaving a note on its own already does.

**Required reading before any line:** the 18k UNIT C1 RECORD whole
(`notes/plans/phase-18k-runtime-hygiene.md` — T1–T5, the fix, the residuals). The machinery: the
Mac registry entry leaves only through a leaving savepoint that LANDED after the last holder let
go (`markLeaving`/`dropAfterLeaving`, the acquisition generation); book/Compare notes today have
NO leaving road before ⌘Q/lock/idle (C1's T3 case 2 and named residual 1 — this unit is their
ruled discharge). The build: the book surfaces (Index's edited note, the book's focused-note
selection — wherever the note-switch fact actually lives; trace it, name it) report a
note-switch and a leave-the-book as a LEAVING through the existing `savepointOnLeaving` road —
never a second savepoint mechanism; the C1 drop conditions then retire the entry for free.
Compare peers follow the same rule (a peer swapped out / the board left), PROVISIONAL — QUESTIONS
row quoting the ruling's own PROVISIONAL clause. `closeAutoCommit`'s dedupe (one quiet savepoint
per edited take, deduped against the take's last commit) is the semantics — byte-preserved;
`savepoint_cadence` governs it as a CADENCE occasion (AppSpec §9) — the setting's OFF mode must
keep refusing it (pin a guard).

**Pins red-on-old:** edit a note inside a book, switch to another note → the leaving savepoint
lands (old code: nothing until ⌘Q/lock/idle — the C1 pin style measures it); leave the book →
same; a note NOT edited gets nothing (dedupe guard); the registry entry drops after the landed
savepoint (C1's count pins extended, not modified); the Compare-peer arm. **Evidence:** pins +
the FULL `AutosaveRegistryLifecycleTests` + `AutosaveRegistryReleaseTests` suites riding (C1's
pins must pass UNMODIFIED except where an assertion's own meaning changes — justify any edit in
the record) + an orchestrator walk in a book (edit, switch note, check Block History shows the
quiet savepoint). **Custody-adjacent (the autosave/savepoint seam) → the end FABLE ladder is the
review**, per the ruling's own note.

### U5 — 17t, the two unwired protection doors (`opus-implementer`; custody — the Fable rider fires on the ladder)

Ledger rows 15–16. The 17-file's 17t section is the entry's brief; both rows found at 13u2 UNIT
D's roster-item-8 verification.

- **Item 1 (the typed near-empty confirmation):** wire `RekeyRecencyProbe` (its file stays
  byte-untouched in `Sync/` — consume it from App; if the probe's shape doesn't fit, STOP and
  report, that becomes Fable work) into the rebuilt Replace All Keys flow: when the probe reads
  this store as near-empty against a fuller server, the warning face speaks the count-and-dates
  (#86(c)'s T1 guard grammar) and the act demands a TYPED confirmation phrase — the
  delete-account door's shape — before proceeding. **Warn, never refuse, never click-through**
  (her ruling verbatim: *"I would add a typed confirmation phrase for the near empty case"*).
  The ordinary (not-near-empty) road is byte-unchanged and pinned as a guard.
- **Item 2 (COPY ALL):** the shared `SyncEnrollmentView` gets its copy door so `markWordsCopied()`
  / the "Copied" caption branch is reachable (the `ProtectionPane:1193` wiring + its 60 s
  clipboard clear is the model — ONE clipboard-clear rule, shared, never a second copy);
  `KeyDoorModel` / `PostureSwitchModel`'s declared-but-uncalled `markWordsCopied()` get their
  call sites or a recorded reason. **The phone's three word screens are NOT this unit's** (the
  mobile app row's, beside PL-23) — zero phone faces.

**Scope fence:** ZERO `Sync/` edits; ZERO key-custody semantics changes (no key leg, no wrap, no
Keychain write changes — faces and gates over existing machinery only; anything deeper is a
stop-and-report). **Evidence:** pins red-on-old (the near-empty gate: typed-phrase-required,
wrong-phrase-refuses, ordinary-road-unchanged; the enrollment page's caption branch reachable —
the composition-pin form `ProtectionSurfaceRenderTests` uses); a walk of the Protection pane's
copy door where the machine allows; the re-key DRILL is NOT re-run (no key machinery changes) —
say so in the record; if the diff DOES touch a key leg, the drill rule fires and the orchestrator
re-scopes.

### U6 — #146, the signed-out-first retirement (FABLE — this orchestrator seat; `Sync/`)

Ledger row 17. The ruling (PROVISIONAL, hers to overturn — QUESTIONS #146 verbatim): **the
account's deletion wins over an UNTOUCHED local copy, and never over a touched one.** At the
device's first sync after sign-in, a locally seeded copy that is still PRISTINE (the dedupe's own
test: every story's text matches the shipped manifest, no manual savepoint, comment, tag,
reference or extra take) is retired quietly when the account already holds that book DELETED —
into this device's Trash (Put back and Help ▸ Restore both still work). An EDITED copy is never
retired; it survives and syncs (Sherlock reappears on both devices — accepted).

**Pre-work (this seat, before any line):** `notes/SyncSpec.md` re-read in full ·
`notes/sync-postmortem-fragments.md` · `SampleLibraryDedupe.swift` + its convergence suites ·
the RUN B #143(b) crossing-race defense (the revive window) — the new leg must not fight it.
**Design sketch (verified against the real machinery before building):** a new dedupe leg firing
ONLY under a PULL, on the occasion an arriving TOMBSTONED reading matching the shipped-book
identity predicate meets a LIVE local copy of the same shipped book (manifest-matched); the local
copy classifies through the existing pristine/edited classifier (err toward EDITED, all its
existing indeterminate legs apply); **seq-ranked later-intent guards the deliberate-restore
case** — retire only when the tombstoned copy's authority is NEWER than the live copy's rows
(`sync_row_seq`; a never-accepted local row ranks 0 — which IS the signed-out-first phone), so a
copy she deliberately restored AFTER the deletion is never taken by a third device's first pull.
Retirement is ordinary tombstones with EXPLICIT outbox rows (SyncSpec §7's repair rule), exact
one stamp so `restoreContainer` revives it whole; deterministic and idempotent on every device;
zero schema, marker stays 9, zero server lines. **Convergence suites (the two-client fake-server
harness; any sync change without one is unreviewed):** the scenario itself (Mac deletes → phone
seeds signed out → signs in → first pull retires to Trash, tombstones push, Mac unchanged); the
edited-copy survival; Put back; the deliberate-restore-then-third-device guard; arrival-order
independence; idempotence; the outbox rows asserted (§7's rule); the #143(b) revive defense
untouched (its pins ride unmodified). Red-on-old by the scenario pin (today's code: Sherlock
reappears on both devices — the pin's old-tree run shows it).

**Evidence:** the convergence suites + `swift test` whole + the FULL mobile suite (the engine is
shared); a LIVE two-device round is HERS (bundled — the sync-kind acceptance's live leg; the
suites are the floor). The end ladder's fresh `fable-reviewer` reviews this diff cold with the
rest; same-model disputes are adjudicated by the orchestrator against SyncSpec — the spec
outranks both.

### THE LADDER (after U6; ledger row 18)

ONE ladder over the phase's combined diff: a fresh `fable-reviewer` per round running
`notes/REVIEW_PROMPT.md` VERBATIM with zero framing ({PHASE} = 18o); findings land in
`notes/plans/18o-ladder-round<N>.md` repo-first before any fix session sees them. Cross-model
flow for the Opus units' findings (verbatim to a fresh implementer where fixes are owed, its
agree/dispute back to the reviewer, which makes the final call and implements its confirmed fixes
itself); the orchestrator arbitrates same-model (U6) disputes against the canonical docs. Round
2 re-reviews the fixes (fresh reviewer); a new BLOCKER/MAJOR earns round 3; hard cap three. Every
finding gets a written disposition in the round file + this ledger. Then the suite finals green
and one implementer sanity pass.

### CLOSEOUT (ledger row 19 — the standing ritual, unabridged)

Results + counts in this file (PHASE RESULTS) · dispositions copied into
`notes/plans/phase-17-standing-fixes.md` (the 17e entry + the 17t entry — their status lines flip
CLOSED with pointers here) · KnownIssues rows 54 · 55 · 64 · 66 · 73 · 78 · 79 · 84 resolved or
re-owned (the header rule: no blank owner) · QUESTIONS rows (#160+) landed and the tail marker
moved · master plan row 18 gains the 18o DONE entry; the closeout-log paragraph written; the
outgoing 18m paragraph rolls VERBATIM to `notes/PhaseCloseoutArchive.md`; zero AppSpec deltas
expected (nothing here changes canon — if a delta emerges it lands as a contract line + pointer,
never a paragraph) · `notes/plans/post-13u-health-rounds.md` row 18o struck DONE · **MOBILE
PARITY line** (expected: P23's segmenter fix reaches the phone's capture through the shared op —
mobile-visible, named; P29 is a phone doc line; U6 is engine-side both platforms; 17t's phone
word-screen doors REMAIN the mobile row's; the rest Mac-only) · the author handoff
`notes/handoffs/phase-18o-handoff.md`, her checklist at the top (the #146 ratify, the new
QUESTIONS rows, the R-18k-6 Compare-peer PROVISIONAL, the live two-device round, anything HELD)
· the install refresh per R-18k-3 behind the A1 rail (`Backups/safety-copies/`,
`xcodebuild -scheme Variorum -configuration Release build`, copy, `codesign --verify --deep
--strict`, both keychain access groups) at a VERIFIED zero-instance window — else HELD and
bundled · commit, push, **hard stop** — the author kicks off what's next (18n holds row 70's
remainder INTERIM; the mobile catch-up resumes on PL-40's ground at her word).

---

## LIVE STATUS (flipped in the same commit as each piece — the resiliency protocol's rule)

- PLAN FILE authored + committed — **DONE** (this commit).
- U1 the honesty & paper-cuts batch — **CLOSED; walks W1–W3 RUN AND PASSED 2026-09-30 under her away grant (the adjudication's walk section), W4 on its pins.**
- U2 the import & launch-seed batch — **CLOSED (orchestrator adjudication 2026-09-30; rows 10–11 dispositioned; the microsyntax edge adopted as row 12b → U3)**.
- U3 the two Mac doors (+ row 12b) — **CLOSED (orchestrator adjudication 2026-09-30; rows 12/12b/13 dispositioned; the row-13 design divergence accepted and named a ladder focus)**.
- U4 the book leaving savepoint (R-18k-6) — **CLOSED (orchestrator adjudication 2026-09-30; row 14 dispositioned; ladder foci named — the ladder's first read)**.
- U5 17t, the two unwired protection doors — IN FLIGHT (implementer 2026-09-30; the UNIT U5 RECORD carries its LIVE STATUS — item 1 STOP-AND-REPORT with a documented-behaviour pin + QUESTIONS #164; item 2 building).
- U6 #146 (Fable seat) — NOT-STARTED (SyncSpec + postmortem re-read precede any line).
- THE LADDER — NOT-STARTED.
- CLOSEOUT + the install refresh — NOT-STARTED (refresh window unverified; her app's state unknown).

---

## UNIT U1 RECORD — the honesty & paper-cuts batch (implementer: `opus-implementer`, 2026-09-29)

**NOT DONE (first line, per the contract):** (1) **NO GUI WALK and NO CAPTURES** — her real-store app was running the whole session (`/Applications/Variorum.app`, pid 21496, untouched), and WalkKit's own guard refuses every GUI step while it lives (`Tools/WalkKit/guard.sh --author` → *"GUARD: her app is running — STOP"*, exit 3), so the use-shaped walks are HELD for the orchestrator (the U1 section already names them the orchestrator's, "where the machine allows") — the ready script is THE WALK SCRIPT below; `notes/plans/18o-screens/u1/` was not created. (2) The ledger table's rows 1–9, the 17e copies into the 17-file and the KnownIssues edits (rows 64 · 84, and the per-note-view-state row's correction) are the orchestrator's closeout acts — each line is drafted below, none applied. (3) 17e (12)'s same-class sweep found ONE more silently-gated family (the creation/restore menu items) — enumerated, NOT fixed (not one line; NOTICED 1). Everything else the brief asks for is done.

### READING (done in-session before any code)

`CLAUDE.md` + its auto-loaded canon (CoreDescription, OverallModel, AppSpec) · this file WHOLE · `notes/KnownIssuesAndTechDebt.md`
(the header rule; rows 64 and 84 read in full) · `notes/SessionResiliencyProtocol.md` whole · the 17-file's 17e section whole (the
P29/P32/P34/P35/P37 briefs with their VERIFIER traces; items (11) and (12)) · `notes/plans/phase-18k-runtime-hygiene.md` THE
KICKOFF SITTING (R-18k-1…R-18k-10) and the UNIT C7 RECORD whole (NOTICED 1 = row 84's mechanism) · `notes/QUESTIONS.md`'s tail
(next free **#160**) and #146–#159's shape. **Instance state at start:** her real-store app IS RUNNING
(`/Applications/Variorum.app/Contents/MacOS/Variorum`, pid 21496) — never touched; no Release build, no refresh; GUI only on the
Debug dev store behind the per-step guard.

### LIVE STATUS

- Reading + this record opened — DONE (this commit).
- P29 (phone redo-door comment) — DONE (this commit): `MobileUndoDoor.redo()`'s doc now states the truth its family already states — redo is NOT discard-free (`Operations.reapplyStructural` overwrites a since-edited buffer with the post-op text behind a quiet insurance savepoint, `Operations+UndoInverses.swift:434-446`, its own doc :344-348), the undo warning's "set aside" vocabulary, no warning by A12's letter. Comment-only; zero behaviour; **no pin — a comment cannot fail a test, and a hollow pin is not minted.** Siblings checked: `ShellActions.swift:136` / `StructuralUndoCopy.swift:64` ("redo is untouched" — by the WARNING, true) and `UndoStack.swift:53` (entries restoring no buffer discard nothing on UNDO, true) — no other false copy. PENDING: the FULL mobile suite at the unit's end.
- P32 (false-premise comment + QUESTIONS row) — DONE (this commit): the premise re-traced false at the code (`TakesColumn.picks` is `Codable` inside `TakesViewMemory`, JSON into `UserDefaults` `takesViewMemory.<postID>` by `saveMemory()` on every pick write; the ONLY clearing site is lens promotion, `TakesViewModel.swift` ~:1184; `resolvedTake` falls through silently; the notice renders only at `LensesBoardView.swift:653`). `danglingPick`'s doc now gives the TRUE reason for the lens-only scope (J5 as recorded names a SAVED lens) and states that scratch picks can dangle. **QUESTIONS #160** names the UX gap, options (i) extend the notice + Restore to scratch columns — RECOMMENDED (R83: an unnamed column IS visibly an unnamed lens) · (ii) prune at archive/delete · (iii) accept; OPEN, nothing built (R-18k-1's letter). The downstream P5 damage was fixed at RUN A (`PromotePicksArchivedPickTests`). Tail marker → **#161**. No pin (comment + question only).
- P34 (BoundarySnapping doc + boundary pin + QUESTIONS row) — DONE (pins `9068f624`; doc + QUESTIONS this commit): the pins `BoundarySnappingTests.aStrongBoundaryExactlySettlePullEarlierTakesAnExactPlacement` (". I " → 5, ". A " → 4, "\nI " → 4) + the guard `anExactPlacementWinsBeyondThePullAndAgainstALaterStrongBoundary`; the test comment's "always wins" corrected. **Documented-behaviour pins, so green on today's tree by design** (`Test run with 37 tests in 2 suites passed`); proven able to fail: the named mutation **M-exact** (a raw-0 candidate wins outright — the exact-wins alternative) → **`Test run with 37 tests in 2 suites failed … with 3 issues`**, all three in the boundary pin, the guards green; restored by `git checkout HEAD --`, `git status` clean. `settlePull`'s doc now states the one configuration where the pull overrides an exact placement (and that a LATER strong boundary loses the tie). **QUESTIONS #161** records exact-wins as hers (PROVISIONAL: behaviour stands). Tail marker → **#162**. Zero `Sync/`; `Domain` only. PENDING: `swift test` whole at the unit's end.
- P35 (`setShelfPinned` self-heal) — DONE: pins `0ae75e59` · fix `915e8124` (`Operations+Appearance.swift` only). Pre-fix **`Test run with 5 tests in 1 suite failed … with 4 issues`**; fixed: the 5 + `AppearanceSettingsTests` + `StarsTests` + `ShelfQueryTests` **`41 tests in 6 suites passed`**; **R-P35** (the file from `0ae75e59` over the fix) → **`5 tests … failed … with 4 issues`**, the same three tests with the same counts (2·1·1); restored by `git checkout HEAD --`, `git status` clean. The shape: pin requires `liveReading`, unpin never does; the db-level writer persists the LIVE list in pin order (`liveShelfPins`, one `IN` read ∝ the pins); a no-op writes nothing (guard on the value). Both in-transaction pinners (`insertDailyJournalBook`, `ensureQuicknotesBook`) ride the same writer — pinned (their fresh reading is live in-transaction) and pinned. `setting` is synced metadata (server-wins CAS): ordinary op writes, **zero `Sync/` lines**, zero schema. **Named, left as the brief says:** `MobileTutorialSeeder.cleanup`'s caller-side workaround (`try? ops.setShelfPinned(readingID, pinned: false)` before `deleteReading`, doc at :179-180) — now redundant but harmless (an unpin of a live pinned book is exactly what it was); untouched. The phone's shelf (`MobileShelfViewModel.swift:120`) inherits the heal through the shared op. Consequence, the same one `starred` documents: a deleted book RESTORED later comes back pinned only if no pin write happened in between (stated at the writer's doc). PENDING: `swift test` whole + the FULL mobile suite at the unit's end.
- P37 (tray ARCHIVED truncation marker) — DONE: pins `74d4c45a` · fix `6c61d562` (`Features/Tray/TrayPanel.swift` only). Pre-fix **`Test run with 3 tests in 1 suite failed … with 1 issue`**; fixed: the 3 + `NoteTrayTests` + `TrayFilterTests` + `TrayPanelShapeTests` + `TrayPanelMoveTests` + `TrashPurgeDoorsTests` **`58 tests in 6 suites passed`**; **R-P37** (`TrayPanel.swift` from `74d4c45a` over the fix) → **`3 tests … failed … with 1 issue`**, the same test, the guards green; restored by `git checkout HEAD --`, `git status` clean. The shape: `archivedTruncated` beside `archived`; `adopt` windows the arm with `TrashListing.windowed` (the takes arm's shape); the archived view renders `truncation("archived")` — *"Showing the 500 most recently archived — older ones aren't listed."* — under its rows on the deleted marker's exact condition (view + non-empty rows + the flag), so the takes filter (which lists nothing in the archived view) shows no marker. The Archived tab's count still reads the windowed 500 — the Leaving tab's standing shape, unchanged. Mac-only (the phone has no tray panel).
- 17e (12) (`CapabilityContext.windowKind`) — DONE: pins `b24d801a` · fix + new-tree pins `e724032f`. Pre-fix **`Test run with 26 tests in 1 suite failed … with 3 issues`**; fixed: `CapabilityRegistryTests` + `ShellChromeTests` + `NoteVersionsPaneTests` **`49 tests in 3 suites passed`**, the window/quick-note family **`21 tests in 8 suites passed`**; **R-T12** (the two behavioural lines only — the declaration back to `always`, the menu back to `.disabled(session == nil || windows.activeWindowKind != .full)`) → **`Test run with 28 tests in 1 suite failed … with 8 issues`**: all four sidebar pins red (`theSidebarToggleIsGreyWhereNoFullWindowIsKey` 1 · `theSidebarMenuItemReadsItsGreyFromTheRegistry` 2 · `theSidebarToggleActsOnlyInAFullWindow` 3 · `theRoutersContextCarriesTheKeyWindowsKind` 2), the other 24 green; restored by `git checkout HEAD --`, `git status` clean. What she sees is unchanged by design (the menu greyed correctly before; the grey now comes from the registry).
  **THE SAME-CLASS SWEEP** (every View/File/Edit/Help menu item in `EditorCommands.swift` whose grey is NOT `enabled(id)`, at `e724032f`):
  1. `.toggleSidebar` — **FIXED** (above).
  2. **The creation/restore family — SAME CLASS, NOT FIXED (not one line):** `.newPost` · `.todaysEntry` · `.findAnything` · `.restoreTutorial` · `.restoreSampleLibrary` · `.restoreEncryptionBook` · `.restoreJekyllBook` each declare `always` while the menu greys them on `!canReachCreationTarget` (`session != nil && windows.hasNavigationTarget` — NO full window exists at all). It is a DIFFERENT window fact from `windowKind` (by 13f cold review R1-3's ruling the note-only-KEY case stays ENABLED and lands in the full window), so the fix is a second context field (`hasNavigationTarget`), its wiring, seven declarations and seven menu edits. Reachable only with the main window closed and a note-only or quick-note window open; the menu already greys correctly — registry-honesty (P-1) only. **NOTICED-NOT-TOUCHED 1 below, for an owner.**
  3. `.structuralUndo` / `.structuralRedo` — the menu reads `undoMenuState.topLabel` / `topRedoLabel == nil`; the registry declares `ctx.undoAvailable` / `redoAvailable`, wired from the SAME state (`AppSession.swift:766-767`). **Not silently gated** — the walk sees the gate; a second spelling of one rule, left.
  4. `.importFiles` · `.exportLibrary` · `.quickNote` (`session == nil`) and `.helper` (ungated) — `always` in the registry, and `enabled()` itself is false with no session: **equivalent, not the class.**
  5. Undeclared menu items (a different class — declared ⇔ rendered — not this row's): **New Window** (undeclared by 13f 5b ruling (e)), **Open the Tutorial** (literal title, no registry id), **Lock Library Now** (rendered only under `bootstrap.canLock`, no registry id). NOTICED-NOT-TOUCHED 2.
- Row 84 (future-stamped backup copy) — DONE (pins `09f9e199` · fix `1c18420d`): THE TRACE (at the code): every due-check in the backup run asks `now.timeIntervalSince(newest) < interval` of the newest of the app's own copies — `StoreBackup.performPrimaryLeg` (:550), `performSecondLeg` (the far folder, :388-391), `performLockTimeCopyIfDue` (:637-639) — and the weekly export's `MarkdownInsurance.performExport` (:137-139) is the same clock one cadence up; a copy stamped ahead makes the difference NEGATIVE, so each reads "fresh" until the clock passes the stamp plus an interval, writing nothing and saying nothing. The face's `FolderSummary.isStale(after:)` asks `Date().timeIntervalSince(newest) > interval` of `summarize`'s `dated.max()` — negative too, never orange (`summarizeExports` the same). Retention checked for a second defect and found none: the far folder's 14+4 keeps the most recent DAYS THAT HAVE A FILE (not relative to now), so a future copy costs one slot, never a real copy. **Pins `09f9e199`**, `BackupFutureStampTests` (8, its own file — C7's `DataSafetyTests.swift` untouched): pre-fix (`18o-u1-r84-prefix.log`) **`Test run with 8 tests in 1 suite failed … with 14 issues`** — primary 3 · second folder 2 · lock-time 1 · weekly export 2 · face 2 · only-future face 2 · exports row 2; the guard `anOrdinaryRecentCopyStillReadsFresh` green. **Fix committed (this commit)** — ONE rule, "a stamp later than now is not evidence of freshness": the due-checks and the face read the newest copy stamped NO LATER than now (the brief's "ignore future-stamped copies for freshness" arm — its other arm, treat-as-due, alone would write at EVERY hourly check while the future copy stays `.last`, C7's reader-3 storm). Built: `StoreBackup.stampIsTrusted(_:now:)` (`stamp <= now`) + `newestTrustedBackup(in:now:)` (the newest own copy it trusts); the three `StoreBackup` due-checks read it; `MarkdownInsurance.performExport` reads its newest export through the same `stampIsTrusted`; `DataSafetyModel.summarize` / `summarizeExports` take `now: Date = Date()` and read `newest`/`oldest` from trusted stamps only (the count still counts every real file); `FolderSummary.isStale(after:now:)` reads a future newest as stale (the belt). Fixed tree: `BackupFutureStampTests` + C7's `BackupOwnFilesTests` (UNMODIFIED — `DataSafetyTests.swift` has zero diff) + `BackupRetentionTests` `BackupRunTests` `BackupSingleFlightTests` `DataSafetyRunbookTests` `MarkdownInsuranceTests` `SyncSafetyFaceTests` `SecretCheckTests` `SnapshotPairTests` `ICloudDriveOfferTests` `MarkdownInsuranceFlipTests` `Phase13pBackupEnvelopeTests` `Phase13pInsuranceFaceTests` `StoreBackupTests` `PostureSwitchTests` **`Test run with 135 tests in 16 suites passed`**, zero skipped. **R-84** (the four production files from `09f9e199` over the fix) → **`Test run with 8 tests in 1 suite failed … with 14 issues`**, the same seven pins with the same counts (3·2·1·2·2·2·2), the guard green; restored by `git checkout HEAD --`, `git status` clean. **One judgement widened the row, stated:** the weekly plain-text export's due-check (`MarkdownInsurance.performExport`) and the exports row of the same face are the identical clock one cadence up on the same backup run and the same pane — fixed by the same one rule and pinned (`aFutureDatedExportNeverStopsTheWeeklyExport`, `theExportsRowTurnsStaleWhenOnlyAFutureFolderLooksFresh`); reverse by dropping those two call sites. **PROVISIONAL, QUESTIONS #162** (what the Data Safety row shows about a future-dated copy — (a) built: newest/reach from trusted stamps, the copy counted; (b) orange-until-the-date; (c) (a) + a naming line). Tail marker → **#163**. Data-safety class: no file is ever deleted by the rule; the prune and the 14+4 retention are byte-untouched; forced runs (Back Up Now, the toggle, a folder pick) are untouched (they skip the due-check). Mac-wired only (the phone compiles `StoreBackup`/`MarkdownInsurance` and never wires them) — the mobile suite at the unit's end proves compilation.
- Row 64 RECORD-ONLY (pin re-verify + R-18k-4) — DONE (this commit): `swift test --filter ContentReplacementRedoTests` on U1's tree (`edbb359c`, carrying this unit's P34/P35 core edits) → **`Test run with 5 tests in 1 suite passed`**, `anUndoEntryOlderThanARestoreCanStillReviveIntoTheRestoredNote` green (the documented behaviour — 2 blocks → 3 — stands, pinned) beside its guard `clearingTheFutureNeverTouchesHerUndoHistory`. **The ruling, recorded:** R-18k-4 (her pick of the recommended option at the 18k kickoff sitting, 2026-09-25, on QUESTIONS #136(b)) — *leave it for now*: an undo entry registered before a content-replacing act (`restoreNoteVersion` / `deleteContainer`) may still revive its block into the replaced note (or refuse visibly and retryably on a take the act tombstoned); the stack stays SESSION-WIDE; a note-scoped undo is a future DESIGN at her word, never built by a correctness session. **Drafted for the closeout (the orchestrator's KnownIssues act, not this unit's):** row 64 is no longer deferred WORK — it is ruled, documented and pinned behaviour — so either (i) the row closes as *"RULED R-18k-4 (leave it for now) — documented behaviour, pinned `ContentReplacementRedoTests.anUndoEntryOlderThanARestoreCanStillReviveIntoTheRestoredNote`; a note-scoped undo is a design at her word (QUESTIONS #136(b))"*, or (ii) it stays with a named owner for the future design (the file's rule forbids a blank one). The 17e copy line: *"KnownIssues row 64 — RECORD-ONLY, R-18k-4 recorded; the documented-behaviour pin re-verified green at 18o U1 (5/5)."*
- 17e (11) RECORD-ONLY (disposition line) — DONE (this commit), the claim re-read at the code first. **The drafted 17e copy line:** *"(11) — PARTLY DISCHARGED at 18d: the Mac's Delete Now on a note (`RecoveryViewModel.forgetLocalMemories`, `RecoveryView.swift:489`) calls `CommandRouter.forgetCurrentBlock`, which evicts `currentBlock.<id>` and the persisted `surfaceSize.outline|flow.<id>`; the remainder (Empty Trash's targets, a note purged on another device, a note never purged) is ACCEPTED at its arithmetic on KnownIssues' per-note-view-state row (owner 12). No build at 18o. **Correction found at 18o U1 (re-read at the code):** `postMode.<id>` (`PostDetailView.swift:103/580`), `readFace.<id>` (`ReadModeView.faceKey`) and `takesViewMemory.<id>` (`TakesViewMemory`) are evicted by NO production road — not even Delete Now — so the per-note-view-state row's 'ONE production occasion evicts them' and `forgetCurrentBlock`'s 'One door, every memory' overstate; the same accepted arithmetic covers them (tens of bytes a key), and the text correction (or the two/three-line eviction the door's own doc invites) is that row's owner's."* — NOTICED-NOT-TOUCHED 3 carries it.
- Closing runs — DONE, on the final code tree `b36e93b2` (her real-store app live and untouched throughout; logs in `App/Variorum/DerivedData/`):
  - **Core `swift test` (whole)** (`18o-u1-core.log`): **`✔ Test run with 1737 tests in 182 suites passed`**, 1 skipped (`basicOfflineEditsConvergeOverTheRealServer` — the standing env-gated live-server pin). Arithmetic: the plan's BASELINES line ("core untouched since 18k's finals, 1723/180") is stale — 18l U0 (`83f6f317`, +6 tests / +1 suite) and 18l-c U8 (`dfe5a895`, +1 test) touched core after 18k; + this unit's 7 tests / 1 suite (P34 +2, P35 +5) = 1737/182 exactly.
  - **Mac closing set** (`18o-u1-closing.log`) — 49 literal suites: the tray (`TrayArchivedTruncationTests` `NoteTrayTests` `TrayFilterTests` `TrayPanelShapeTests` `TrayPanelMoveTests` `TrashPurgeDoorsTests`), the dangling pick (`RecoveryDoorsTests`), the registry + windows (`CapabilityRegistryTests` `ShellChromeTests` `NoteVersionsPaneTests` `WindowRegistryTests` `PaneMountWindowTests` `NoteOnlyWindowTests` `IndependentWorkspaceTests` `TwoWindowMountTests` `QuickNoteWindowTests` `QuickNoteDoorTests` `QuickNoteMintTests`), the backup/Data Safety family (`BackupFutureStampTests` `BackupOwnFilesTests` `BackupRetentionTests` `BackupRunTests` `BackupSingleFlightTests` `DataSafetyRunbookTests` `MarkdownInsuranceTests` `SyncSafetyFaceTests` `SecretCheckTests` `SnapshotPairTests` `ICloudDriveOfferTests` `MarkdownInsuranceFlipTests` `Phase13pBackupEnvelopeTests` `Phase13pInsuranceFaceTests` `StoreBackupTests` `PostureSwitchTests`), the shelf's Mac consumers (`ShelfModelTests` `PromoteAndPaletteTests` `JournalBooksTests` `BookStructureModelTests`) and the eleven Tutorial suites — **`✔ Test run with 385 tests in 49 suites passed`**, 0 skipped.
  - **FULL mobile suite, iPhone 17 Pro simulator** (`18o-u1-mobile.log`): **`✘ Test run with 654 tests in 112 suites failed … with 5 issues (including 4 known issues)`** — EXACTLY the attributed baseline: the 4 known (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` ×2, `MobileTutorialStructureWalkTests.theFannedDivideLessonLandsTheDuplicateShape` ×2) + **F-1** (`nothingUserFacingNamesTheMac`, its one offender still `SampleLibraryJekyllBook.swift`'s disclaimer — #155's, attributed, NOT re-attributed); 0 skipped. The count is the 18m baseline's own (U1 added no mobile test); it compiles every shared change (`MobileUndoDoor` doc, `StoreBackup`, `MarkdownInsurance`) and runs the phone's shelf pins through the healed op.
- Walk captures (`notes/plans/18o-screens/u1/`) — HELD: her app running, `guard.sh --author` exit 3 (THE WALK SCRIPT below is the orchestrator's).
- The record closed — DONE (this commit).
- Deaths / resumes: none.

### THE WALK SCRIPT (HELD — for the orchestrator at a verified zero-instance window; the dev-store Debug build of this tree, WalkKit's guarded order: `guard.sh --author` FIRST, then activate, then `guard.sh <pid> [x y]`, acts ≥ 2 s apart)

- **W1 — 17e (12), the sidebar toggle's grey (voice-independent: system menu chrome; one capture):** with the main (full) window key, read `enabled of menu item "Toggle Sidebar" of menu 1 of menu bar item "View" of menu bar 1` → **true**; ⌃⌘S hides/shows the sidebar. Open a note in its own window (the Open strip's context menu ▸ Open in New Window — the 800×720 window), make it key, read the same item → **false** (the grey, now the registry's answer). Close that window by its AXCloseButton (README's recipe).
- **W2 — P35, the shelf pins (both voices):** pin two books on the shelf, delete the second (Library ▸ Trash), pin a third → the shelf's pinned books read first-then-third in pin order. Then Put back the deleted book → it returns UNPINNED (the documented consequence the writer's doc states, `starred`'s own; worth her eye — NOTICED 6). Unpin/re-pin on a live book behaves as before.
- **W3 — row 84, the Data Safety face (the pane is system-styled — one capture per appearance is enough):** in the dev container's `…/Variorum-dev/Backups/`, copy the newest REAL dated copy (and its `.keys.json` pair) to the same name with a stamp THREE DAYS AHEAD (`variorum-backup-<today+3d>-<fp8>.sqlite`); open Settings ▸ Data Safety → "Beside your library" reads **Newest: <today's real copy>** (never the future date), the count includes the stand-in, the row is not orange. Remove the stand-in pair afterwards and re-read the pane. (The test host's launch writes dev copies too — read stamps, not presence: the ENVIRONMENT TRAPS line.)
- **W4 — P37, the tray's archived marker:** staging > 500 archived blocks in one dev note is a store-polluting fixture, so the marker's evidence is the composition pins (`TrayArchivedTruncationTests`, red-on-old + revert). The cheap regression walk: a note with one archived block → This Note's Tray ▸ Archived shows the row and NO marker, both voices.
- P29 · P32 · P34 are documentation (P34's behaviour is unchanged and pinned); rows 64 and (11) are records — nothing to walk.

### SEAM FILES THIS DIFF TOUCHES (the ladder reads this first)

| File | What changed | What did NOT |
|---|---|---|
| `App/Variorum/VariorumMobile/Features/Write/MobileUndoDoor.swift` | P29: `redo()`'s doc only | every line of code |
| `App/Variorum/Variorum/Features/Takes/TakesViewModel.swift` | P32: `danglingPick`'s doc only | every line of code |
| `Sources/VariorumCore/Domain/BoundarySnapping.swift` | P34: `settlePull`'s doc only | `settle`, every scanner |
| `Sources/VariorumCore/Operations/Operations+Appearance.swift` | P35: `setShelfPinned` (public door: liveness for PIN only) + the db-level writer (heal + value-guarded no-op) + `liveShelfPins` | `setStarred`, every other setter, `upsertSetting`, the two in-transaction callers |
| `App/Variorum/Variorum/Features/Tray/TrayPanel.swift` | P37: `archivedTruncated`; `adopt`'s archived arm windowed; one `truncation("archived")` line | the other arms, every row, the purge doors |
| `App/Variorum/Variorum/Registry/Capability.swift` · `CapabilityRegistry.swift` · `CommandRouter.swift` · `EditorCommands.swift` · `RootView.swift` · `Workspace/WindowRegistry.swift` | 17e (12): `CapabilityContext.windowKind`; `.toggleSidebar`'s availability; the router closure + `currentContext`; the menu item reads `enabled(.toggleSidebar)`; the shell wires the key window's kind; `WindowRegistry.Kind` `nonisolated` | every other declaration and door; the toolbar door; `activeWindowKind` itself (still the source) |
| `App/Variorum/Shared/StoreBackup.swift` · `MarkdownInsurance.swift` · `Variorum/Features/Settings/DataSafetyModel.swift` · `DataSafetyPane.swift` | row 84: `stampIsTrusted` + `newestTrustedBackup`; the three `StoreBackup` due-checks, the export's due-check, `summarize`/`summarizeExports`' newest/oldest, `isStale`'s belt | `existingBackups` / `date(fromBackupURL:)` (C7's own-names rule), every prune, retention, the copy/pair/runbook/key-file code, forced runs |

**Zero `Sources/VariorumCore/Sync/`, zero `Server/`, zero schema/migrations (marker 9 unchanged), zero new settings.** Editor seam untouched (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `EditorSurfaceController`). **Custody-adjacent, named for the Fable ladder:** the Castle lock-time copy's due-check (`performLockTimeCopyIfDue`) now reads the trusted newest — its WAL/key-file/pair/pending-check legs are byte-untouched; `PostureSwitch`'s offer listing (C7's reader 5) is untouched (it lists through `existingBackups`, which this unit did not change).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **Row 84 — "ignore future stamps for freshness", not "treat a future newest as due":** the latter alone writes at EVERY hourly check while the future copy stays `.last` by stamp (C7's reader-3 storm). *Reverse by* `stampIsTrusted` returning true and a due arm on `newest.date > now`.
2. **Row 84 widened to the weekly export** (its due-check + the exports row): the same clock, the same run, the same pane, the same one rule. *Reverse by* restoring `performExport`'s `existing.last` read and `summarizeExports`' `dated.max()`.
3. **Row 84 — the face counts the future copy but never names it as newest** (PROVISIONAL, QUESTIONS #162); `isStale` reads a future newest stale as a belt.
4. **P35 — the no-op guard is on the VALUE** (`setStarred`'s shape): an otherwise no-op pin/unpin DOES write when dead ids are present (that write is the heal). *Reverse by* the old per-id early returns (and the heal only on a changing write).
5. **17e (12) — `windowKind` nil means GREY** (no key window known), matching the menu's old `activeWindowKind != .full`; the walk's sampled contexts gained a full-window context (every gate's own pattern). `WindowRegistry.Kind` became `nonisolated` so the nonisolated context can hold it (pure data).
6. **17e (12) — the source-walk pin matches the menu item's three lines exactly**: a reformat of those lines reds it loudly (by design — it is the "the grey is read from the registry" fact); a reviewer may prefer a looser predicate.
7. **P37 — the marker's condition mirrors the deleted marker's** (the view + non-empty rows + the flag); the Archived tab's count still reads the windowed 500 (the Leaving tab's standing shape).
8. **P34 — the documented-behaviour pin hard-codes a pull of 2** and says so with its own `#expect(settlePull == 2)`.

### NOTICED, NOT TOUCHED (U1's scope fence)

1. **The creation/restore menu family is silently gated the same way `.toggleSidebar` was** — `.newPost` · `.todaysEntry` · `.findAnything` · `.restoreTutorial` · `.restoreSampleLibrary` · `.restoreEncryptionBook` · `.restoreJekyllBook` declare `always` while the menu greys them on `!canReachCreationTarget` (no FULL window exists — a different window fact from `windowKind`; the note-only-KEY case stays enabled by 13f cold review R1-3). The fix is a `hasNavigationTarget` context field + wiring + seven declarations + seven menu edits — not one line, so not taken. Registry-honesty only (the menu greys correctly). Needs an owner (12's registry-walk family, or a 17 entry).
2. **Three menu items are undeclared in the registry** (the declared ⇔ rendered class, not this row's): New Window (undeclared by 13f 5b ruling (e) — deliberate), **Open the Tutorial** (a literal title, no id) and **Lock Library Now** (rendered only under `bootstrap.canLock`, no id). The walk's `menuRendered` list is hand-kept, so it cannot see them.
3. **17e (11)'s premise is partly overstated in two places:** `postMode.<id>`, `readFace.<id>` and `takesViewMemory.<id>` are evicted by NO production road, Delete Now included — KnownIssues' per-note-view-state row says Delete Now evicts them, and `CommandRouter.forgetCurrentBlock`'s doc says "One door, every memory". Same accepted arithmetic (tens of bytes a key); the text correction (or the eviction the door's doc invites — two or three lines) is that row's owner's (12). The drafted 17e line above carries it.
4. **The plan's BASELINES core line is stale:** "core untouched since 18k's finals (1723/180)" — 18l U0 (`83f6f317`) and 18l-c U8 (`dfe5a895`) touched core after 18k, so the pre-U1 core baseline was 1730/181. The closing run's arithmetic above shows it.
5. **`MobileTutorialSeeder.cleanup`'s unpin-before-delete** (doc :179-180, call :184) is now redundant with P35's heal but harmless — left, as the brief says.
6. **P35's consequence, for her eye (and the ladder's):** a book deleted and later PUT BACK comes back pinned only if no pin write happened in between (the heal dropped its id) — exactly `starred`'s documented behaviour, which the brief named as the model; stated at the writer's doc, not a QUESTIONS row (the brief's ruling makes the shape). If she wants restored books to keep their pin, the remedy is a restore-side re-pin, a product call.
7. **`DataSafetyModel`'s summaries read the wall clock** (`now: Date = Date()`), unlike `StoreBackup`'s injected `now` closure — the face pins therefore place fixtures around the real clock. Harmless; a model-level clock seam is the next toucher's if a pin ever needs a fixed now.
8. **Row 84's future copy keeps a retention slot** (the 14 beside the library; one daily slot of the far folder's 14+4) until the clock passes it — by design (never the rule's to delete), recorded.

### DISPOSITION (one line per ledger row)

1. **P29 — FIXED (doc-only)** `e2a6ecf0`: `MobileUndoDoor.redo()`'s doc states redo overwrites a since-edited buffer behind a quiet insurance savepoint (the undo warning's "set aside"); no behaviour change owed (A12 named undo alone). **No pin — a comment cannot fail a test, and no hollow pin was minted.** The FULL mobile suite green at the attributed baseline.
2. **P32 — FIXED (doc) + RECORDED** `a1479bba`: `danglingPick`'s doc gives the true reason for the lens-only scope; **QUESTIONS #160** names the silent-fallback gap, options (i) extend the notice + Restore to scratch columns — RECOMMENDED · (ii) prune at archive/delete · (iii) accept; OPEN, nothing built. No pin (doc + question only).
3. **P34 — FIXED (doc) + PINNED as documented behaviour + RECORDED** `9068f624` · `54f91c72`: `settlePull`'s doc states the one override configuration; `BoundarySnappingTests.aStrongBoundaryExactlySettlePullEarlierTakesAnExactPlacement` + the guard `anExactPlacementWinsBeyondThePullAndAgainstALaterStrongBoundary` — green on today's tree BY DESIGN; proven able to fail: mutation M-exact → 3 issues; **QUESTIONS #161** (exact-wins, hers; PROVISIONAL — behaviour stands).
4. **P35 — FIXED** `0ae75e59` · `915e8124`: `ShelfPinsSelfHealTests` (5) — red-on-old **4 issues** (3 tests), R-P35 identical, restored clean; zero `Sync/`.
5. **P37 — FIXED** `74d4c45a` · `6c61d562`: `TrayArchivedTruncationTests` (3) — red-on-old **1 issue** (1 test), R-P37 identical, restored clean.
6. **17e (12) — FIXED** `b24d801a` · `e724032f`: `CapabilityRegistryTests` +4 (`theSidebarToggleIsGreyWhereNoFullWindowIsKey`, `theSidebarMenuItemReadsItsGreyFromTheRegistry` — red-on-old **3 issues**; `theSidebarToggleActsOnlyInAFullWindow`, `theRoutersContextCarriesTheKeyWindowsKind` — with the fix); R-T12 → **8 issues**, all four red; the same-class sweep enumerated (one more family — NOTICED 1).
7. **Row 84 — FIXED** `09f9e199` · `1c18420d`: `BackupFutureStampTests` (8) — red-on-old **14 issues** (7 tests), R-84 identical, restored clean; C7's `BackupOwnFilesTests` rode UNMODIFIED (`DataSafetyTests.swift` zero diff) and green; **QUESTIONS #162** (the face's reading, PROVISIONAL (a)).
8. **Row 64 — RECORDED** `b36e93b2`: R-18k-4 (*leave it for now*) recorded; the documented-behaviour pin re-verified green (5/5); the closeout's two options drafted.
9. **17e (11) — RECORDED** `b36e93b2`: the disposition line drafted, with the correction found at the code (NOTICED 3).

QUESTIONS rows landed: **#160 · #161 · #162**; the tail marker reads **#163**.

- Deaths / resumes: none.

**U1 — DONE (implementer), awaiting the orchestrator's spot-check.**

### UNIT U1 — ORCHESTRATOR ADJUDICATION (2026-09-30; the unit CLOSES here, walks HELD)

**Verified by spot-check, not trusted:** 20 commits `044a6bb0`…`24aabd68`, all pushed, ZERO
trailers (grep over every message), tree clean at `24aabd68`. Diff scope matches the record's
seam table exactly — 22 files; **zero `Sources/VariorumCore/Sync/`, zero `Server/`, zero
schema (marker 9), zero editor-seam files** (grep-verified against the fence list). The P35
operations diff read line by line: pin-needs-live/unpin-never, the value-guarded no-op, the
live-list heal ∝ the pins (P1) — exactly the `starred` shape the brief named. **Re-run by this
seat on the final tree:** `swift test --filter ShelfPinsSelfHealTests|BoundarySnappingTests|
ContentReplacementRedoTests` → **`Test run with 47 tests in 4 suites passed`**. QUESTIONS
#160–#162 read in place; the tail marker reads #163. The closing-run counts accepted as
recorded (core 1737/182 with the 1 standing skip; Mac set 385/49; mobile 654/112 = the
attributed baseline exactly). The BASELINES core line's staleness was the plan's own error —
corrected above, credited to U1's arithmetic.

**THE HELD WALKS — RUN 2026-09-30 by the orchestrator under her away grant (zero instances
verified; the per-step guard OK on every act; the dev-store Debug build from `18o-u1`'s
DerivedData, 03:09 — postdates U2's last production-code commit, so both units' fixes aboard;
captures `notes/plans/18o-screens/u1/`, gitignored):**
- **W1 — PASS.** Full window key → `Toggle Sidebar` menu item reads **true**; ⌃⌘S toggled the
  sidebar twice; the Quick Note window key → reads **false** (the registry's answer in the real
  menu); pad closed → **true** again. *(Walker fact: the dev window came up 1440×1000 at Y=117
  this session, not the README's 1728×1084 — noted for the next walker.)*
- **W2 — PASS, every leg.** Pinned *essays in progress* (context menu "Pin to Shelf Top"),
  pinned *field notes*, **deleted field notes** (Delete Book), pinned *dream journal* → the
  shelf's pinned run read journal · quicknotes · **essays · dream journal** — first-then-third
  in pin order, the dead id healed by the third pin's write. **Put back from the Trash → field
  notes returned UNPINNED** (capture `w2b…`) — the documented `starred`-shape consequence
  (NOTICED 6, in her bundle). The shelf was then restored to its found state (both walk pins
  unpinned; journal + quicknotes remain as found).
- **W3 — PASS.** A +3-day future-stamped copy pair placed beside the library's 14 dated copies →
  Settings ▸ Data Safety read **"Newest: Sep 30, 2026 at 1:42 AM · 15 copies"** — the future
  copy COUNTED but never named newest, the row never stale-orange (#162 (a) exactly; capture
  `w3-…`). Fixture removed + Settings reopened → **14 copies**, same newest (`w3c-…`).
  *(One pre-existing pane fact, not a finding: the summary computes at WINDOW appearance — a
  pane bounce inside one Settings window re-shows the cached numbers; reopening recomputes.
  `DataSafetyModel.summarize`'s standing occasions, unchanged by row 84's fix.)*
- **W4** — accepted on its composition pins per the script's own reasoning (unchanged).
- Walk residue: none added (the fixture pair removed; the shelf restored; my dev instance quit).

**ACCEPTED — U1 CLOSED**, all nine rows dispositioned (the ledger carries them). Judgement
calls 1–8 stand as recorded — call 2 (row 84 widened to the weekly export: same clock, same
run, same pane, one rule) is the correct breadth and is flagged FOR THE LADDER with the
custody-adjacent line the record names (the Castle lock-time due-check now reads the trusted
newest). **The GUI walks W1–W3 are HELD, not waived** — her real-store app ran the whole unit
(pid 21496, untouched; WalkKit's guard refused correctly) — they run at the first verified
zero-instance window (the closeout refresh's window at the latest), from THE WALK SCRIPT
above; W4's evidence is the composition pins by the record's own reasoning, accepted.
**Owners assigned for the noticed items:** NOTICED 1 (the creation/restore silently-gated
family) → a KnownIssues row at closeout, owner 12 (the registry-walk/harness family, beside
the status-seam audit row); NOTICED 2 (the three undeclared menu items) → recorded in the
same row's text; NOTICED 3 (the per-note-view-state row's overstatement) → that row's text
amended at closeout (owner 12 unchanged); NOTICED 6 (a restored book returns unpinned) → in
her bundle as an awareness line, not a defect (starred's own documented shape). **FOR THE
FABLE LADDER:** the lock-time due-check change (custody-adjacent), judgement call 2's
widening, and 17e (12)'s source-walk pin tightness (call 6).

---

## UNIT U2 RECORD — the import & launch-seed batch (implementer: `opus-implementer`, 2026-09-30)

**NOT DONE (first line, per the contract):** (1) The KnownIssues row-66 edit, the ledger rows 10–11, the 17e copy
lines and the MOBILE PARITY line are the orchestrator's closeout acts — each is DRAFTED below, none applied. (2) Two
same-class CRLF edges found OUTSIDE the segmenter are NOTICED, not fixed — the capture microsyntax's line walk and the
phone box's `one_block` write-back (NOTICED 1–2): other surfaces, a second unit. (3) The #146 signed-out-first road is
U6's and untouched (zero `Sync/`); the purged-tombstone residual (#138(e)) stays the recorded gap, pinned as such, not
widened. (4) No QUESTIONS row was needed — both designs follow a standing answer (the family's line-break rule; the
ensure's tombstone rule), so the tail marker stays **#163**. Everything else the brief asks for is done, walks included
(her away grant, `c523caa6`, opened the window mid-unit).

### READING (done in-session before any code)

`CLAUDE.md` + its auto-loaded canon (CoreDescription, OverallModel, AppSpec — §7's segmentation/Return contract, §9's
`newBlock`/import conventions) · this file WHOLE (the U1 RECORD's seam table included) · `notes/KnownIssuesAndTechDebt.md`
(the header rule; row 66 — "The LAUNCH seeder re-mints a seeded book the reader deleted" — in full, its owner cell's
R-18k-5 + the #146 neighbour, which is U6's) · `notes/SessionResiliencyProtocol.md` whole · the 17-file's 17e section
with P23's finder claim AND verifier trace · `notes/QUESTIONS.md` #138(e)/(f) and #146 (next free **#163**) · the
tutorial door's silent ensure (`SeededBookRestore.ensure`, pre-13x F3 MINOR-N3 + RUN A A2's durable-decision record),
`SampleLibrarySeeder.swift` whole, the launch call site `VariorumApp.swift:196`, `Queries.readingTombstoneExists`,
`AppSession.markSeededBook`/`seededBookMarkIsSet`, the phone's `MobileFirstWriteFurniture` (the same brain's second
occasion). P23's trace: `SegmentationRules.swift` whole, `Operations+Import.swift`, `ImportModel.readFiles`,
`QuickNoteView.file`, `MobileQuickNote.mintNow`/`adopt`/`frozenPrefix`, `CrystallizationPlanner` (the editor's
`.bulk`/`.idle` plans call `bulkSegments`), `EditorTextView.paste`, `PlainPaste`, `NewlineSplitting`'s doc,
`CaptureMicrosyntax.parse`, `CaptureSurfaceTests`' ⇧⏎ pin. **Instance state at start:** her real-store app IS
RUNNING (`/Applications/Variorum.app/Contents/MacOS/Variorum`, pid 21496 — the same instance U1 met); never touched.
`Tools/WalkKit/guard.sh --author` refuses every GUI step while it lives (exit 3) → GUI walks HELD; harness-first.

### THE TWO DESIGNS (settled at the code before any line — the ladder reads these)

**P23 — NORMALISE AT THE SEGMENTER'S ENTRY, not `Character.isNewline`.** `bulkSegments` reads `"\r\n"` and a bare
`"\r"` as `"\n"` before it does anything else (all three arms); `crystallizedBoundary` (type-time) is byte-untouched.
*Why not `isNewline`:* the family is TWO families. The within-text scanners (`BoundarySnapping`, `MarkdownSyntax`,
`MarkdownEditing`, `MarkdownRendering`) key on `isNewline`; the BLOCK-BOUNDARY family keys on `"\n"` ONLY —
`NewlineSplitting`'s own doc: *"Newlines here are `"\n"` only — the separator the whole editor brain uses
(`BlockRangeIndex`, `crystallizedBoundary`) … Consistent by design (a Control-Return's U+2028 is content everywhere in
this app, never a block boundary); stated so the mismatch is not 'fixed' into a break the rest of the brain would not
recognize"*, and `CaptureSurfaceTests`' ⇧⏎ pin says U+2028 "would not segment". The segmenter decides block
boundaries, so it belongs to the second family — and `isNewline` would ALSO have changed the editor: the tail's
`.idle(.paragraph)` durability mint runs `bulkSegments` over TYPED text, so a typed Control-Return (U+2028) would have
become a block boundary at the idle tick while `.typing` kept it content. The CR/CRLF answer is the family's own:
`PlainPaste` rule 1 — *"`\r\n` and a bare `\r` normalize to `\n` first — a clipboard from Windows or a classic-Mac-era
file is the same text"*. **U+0085 / U+2028 / U+2029 stay CONTENT** (pinned as documented behaviour).
*Why the editor's newline handling cannot change:* (1) `crystallizedBoundary` is not touched; (2) a newline inside an
existing block never reaches `bulkSegments` (a paste into a block is a content edit — `EditorViewModel` arms bulk
entry only on a `.tail` verdict; Return is content or `TypedReturn`'s structural door); (3) the keyboard cannot type
`"\r"` or `"\r\n"` (Return inserts `"\n"`; ⌃⏎/⌥⏎ insert U+2028, which stays content), so the `.idle` mint over typed
text is byte-identical. The one editor road the fix DOES reach is a CRLF/CR **paste into the open tail** (`.bulk` —
AppSpec §7 names paste as bulk entry): it now segments like the LF paste it is — the same defect at a sibling bulk door,
pinned. **The phone's capture** (`MobileQuickNote.adopt`) anchors the owned block's STORED text inside the RAW snapshot
(`frozenPrefix`); the owned last piece never carries a newline, so the invariant `text == frozenPrefix + tail` holds.

**Row 66 — ONE tombstone rule, both silent roads.** The ensure's rule is lifted into one named predicate beside its
`Declined.deletedByTheReader` (`SeededBookRestore.readerDeletedTheBook` — `Queries.readingTombstoneExists` on the
book's reserved name), which the ensure and the launch seed BOTH read. The launch reads it at the DECIDING point —
inside the seed latch, after the account gate's wait (the tombstone can arrive DURING the first round: that is the
row's own "arrived by sync" road) and after the complete-copy check (a live whole copy stays `.alreadyPresent`); a
decline RECORDS the decision through the launch's own mark leaf (`save(true)` — A2's "record it while the evidence
stands", so the decision outlives the purge exactly as the ensure's does) and answers a new `Outcome.declinedByTheReader`.
The explicit doors (`SeededBookRestore.restore` — Help ▸ Restore, the phone's Settings row) are byte-untouched. The
purged-tombstone residual (#138(e)) stays the recorded gap. The phone's first-write occasion calls the same
`seedIfNeeded`, so it inherits the rule (one brain — MobileSoul §3). Zero `Sync/`; the dedupe (U6's) untouched.

### LIVE STATUS

- Reading + this record opened — DONE (this commit).
- P23 pins — DONE `40c3aafc` (all three in their OWN files, so every existing suite rides unmodified):
  core `SegmentationLineEndingTests` (10 — every arm, both import ops, the exotic-newline guard, the spacing promise);
  Mac `CRLFImportDoorTests` (5 — the finding's FILE road through `ImportModel.importFiles`, `QuickNoteMint.file`,
  `QuickEntryModel.submit`, the open-tail `.bulk` paste plan, the typed-road guard); mobile `MobileCRLFCaptureTests`
  (1 — the phone's pre-mint CRLF paste + the box's ownership). **Pre-fix (red-on-old):** core
  (`18o-u2-p23-core-prefix.log`) **`Test run with 10 tests in 1 suite failed … with 29 issues`** — 9 red
  (`aCRLFDocumentSegmentsOneBlockPerParagraph` 1 · `aBareCRSegmentsExactlyAsItsLFTwin` 8 ·
  `sentenceModeReadsACRLFLineBreakAsTheBreakItIs` 1 · `oneBlockKeepsTheTextWholeWithItsLineEndingsReadAsLF` 2 ·
  `blankForeignTextStillMintsNothingAndEdgeRunsDrop` 1 (its edge-run half; the two blank halves are guards) ·
  `theSpacingPromiseHoldsForForeignLineEndings` 8 · `aCRLFFileImportsOneBlockPerParagraph` 4 ·
  `aCRLFDropIntoAPoolSegmentsToo` 2 · `theSentenceAndOneBlockDefaultsReadCRLFThroughTheOp` 2), the guard
  `theExoticNewlinesStayContent` green; Mac (`18o-u2-p23-mac-prefix.log`) **`Test run with 5 tests in 1 suite failed …
  with 6 issues`** — the file road 1 · the pad 1 · the bar 1 · the tail paste 3, the guard
  `theTypedRoadKeepsAControlReturnAsContent` green; mobile (`18o-u2-p23-mobile-prefix.log`) **`Test run with 1 test in 1
  suite failed … with 3 issues`** (one block, empty frozen prefix, the edit landing in the whole-capture block).
- P23 fix — DONE (this commit), `Sources/VariorumCore/Domain/SegmentationRules.swift` only: `bulkSegments` reads its
  text through `normalizedLineEndings` first (`"\r\n"` → `"\n"`, then `"\r"` → `"\n"` — `PlainPaste` rule 1's two
  steps in its order; a no-CR text passes untouched by a UTF-8 byte test); `crystallizedBoundary` byte-untouched; the
  type header states which characters are line breaks here and why. **Fixed tree:** core
  `SegmentationLineEndingTests` + `SegmentationRulesTests` + `ImportOperationTests` + the `NewlineSplitting`/
  `BoundarySnapping` suites **`Test run with 90 tests in 6 suites passed`**; Mac `CRLFImportDoorTests` +
  `CrystallizationPlannerTests` + `CrystallizationReconcilerTests` + `ImportFacesTests` + `QuickNoteMintTests` +
  `QuickNoteParkTests` + `CaptureMicrosyntaxDoorTests` + `SpaceEaterTests` **`Test run with 66 tests in 8 suites
  passed`**; mobile `MobileCRLFCaptureTests` + `MobileQuickNoteTests` **`Test run with 35 tests in 2 suites passed`**.
- **R-P23 (behavioural revert) — DONE, restored clean:** `SegmentationRules.swift` from `40c3aafc` over the fix →
  core (`18o-u2-rp23-core.log`) **`Test run with 10 tests in 1 suite failed … with 29 issues`**, the same nine tests
  with the same counts (1·8·1·2·1·8·4·2·2), the guard green; Mac (`18o-u2-rp23-mac.log`) **`5 tests … failed … with
  6 issues`** (1·1·1·3, the guard green); mobile (`18o-u2-rp23-mobile.log`) **`1 test … failed … with 3 issues`** —
  every count identical to the pre-fix run. Restored by `git checkout HEAD --`, `git status` clean.
- **M-isNewline (the REJECTED design, run as a mutation — proof the guards bite):** the fixed tree with `bulkSegments`'
  split keyed on `\.isNewline` → core (`18o-u2-m-isnewline-core.log`) **`10 tests … failed … with 3 issues`**, all
  three in `theExoticNewlinesStayContent` (U+2028, U+2029, U+0085 each became a block boundary); Mac
  (`18o-u2-m-isnewline-mac.log`) **`5 tests … failed … with 1 issue`** — `theTypedRoadKeepsAControlReturnAsContent`:
  the idle durability mint split a TYPED Control-Return into `["a", "b"]` — exactly the editor-newline change the
  brief forbade. Every CRLF door pin stayed green under it (`isNewline` also covers CRLF), so the design choice is
  decided by the guards alone, as stated. Restored by `git checkout HEAD --`, `git status` clean.
- Row 66 scaffolding (behaviour-neutral) — DONE `59460a98`: the ensure's rule lifted into ONE predicate,
  `SampleLibrarySeeder.readerDeletedTheBook(db, book:)` (= `Queries.readingTombstoneExists` on the reserved name), the
  ensure now reading it (its 8 pins in `EncryptionBookDoorTests` green on this tree, unmodified);
  `Outcome.deletedByTheReader` declared, unreachable until the fix. Landed first so the pins compile on the pre-fix tree.
- Row 66 pins — DONE `be0ad315` (+ a `try`-hoist out of two `#expect`s in `14822213` — Swift infers a closure whose only
  `try` sits inside the macro as non-throwing; assertions unchanged): Mac `LaunchSeedTombstoneTests` (6 tests, three of
  them parameterized over `Book.all` = Sherlock · Encryption Explained · Jekyll/takemania) + mobile
  `MobileFirstWriteTombstoneTests` (1). **Pre-fix (red-on-old, the scaffolding tree):** Mac
  (`18o-u2-r66-mac-prefix.log`, with `EncryptionBookDoorTests`) **`Test run with 14 tests in 2 suites failed … with 13
  issues`** — `aBookDeletedWhereverIsNotReMintedAtLaunch` 9 (3 per book: outcome `.seeded`, a live copy, a book re-made
  for the surviving notes) · `aTombstoneThatLandsDuringTheFirstRoundIsHonoured` 2 · `theLaunchsDecisionOutlivesThePurge`
  2; GREEN (the guards, by design): `aStoreWithNoCopyAndNoTombstoneStillSeeds` ×3 ·
  `theExplicitRestoreStillMintsAndAWholeCopyReadsPresent` ×3 · `aPurgedTombstoneLeavesNoEvidence_theRecordedGap`, and
  all 8 ensure pins; mobile (`18o-u2-r66-mobile-prefix.log`) **`1 test … failed … with 2 issues`** (`.seeded`, a live
  copy).
- Row 66 fix — DONE `14822213`, `SampleLibrarySeeder.swift` only: `perform` reads `facts` (discover +
  `readerDeletedTheBook`, ONE read transaction) at BOTH deciding reads — the early read and the latch's read after the
  account gate — and `decidedWithoutMinting` answers `.alreadyPresent` for a whole copy (first), else
  `.deletedByTheReader` on a tombstone, recording the decision through the launch's own `save` leaf; the header's
  "honest residual" amended (dated). **Fixed tree:** Mac `LaunchSeedTombstoneTests` + `EncryptionBookDoorTests` +
  `SampleLibraryTests` + `JekyllTakemaniaSeedTests` + `SampleLibraryDedupeFactsTests` (`18o-u2-r66-mac-fixed.log`)
  **`Test run with 49 tests in 5 suites passed`**; mobile `MobileFirstWriteTombstoneTests` +
  `MobileFirstWriteFurnitureTests` + `MobileSeededBookRestoreTests` **`Test run with 15 tests in 3 suites passed`**.
- **R-66 (behavioural revert) — DONE, restored clean:** `SampleLibrarySeeder.swift` from `be0ad315` (the scaffolding
  tree) over the fix → Mac (`18o-u2-r66-revert-mac.log`) **`Test run with 6 tests in 1 suite failed … with 13 issues`**
  (9·2·2 — identical to the pre-fix run, the three guards green); mobile (`18o-u2-r66-revert-mobile.log`) **`1 test …
  failed … with 2 issues`** — identical. Restored by `git checkout HEAD --`, `git status` clean.
- **M-early-only (mutation) — DONE, restored clean:** the fixed tree with the LATCH-side decision reduced to the old
  complete-only check → (`18o-u2-m-early-only-mac.log`) **`6 tests … failed … with 2 issues`**, both in
  `aTombstoneThatLandsDuringTheFirstRoundIsHonoured` (`.seeded` + a live copy): the latch-side read is load-bearing
  and pinned.
- **A seventh pin for the EARLY read** — `aTombstoneAlreadyHereDeclinesWithoutWaitingForTheRound` (an account store
  whose tombstone is already local declines at the first read and records now, instead of `.awaitingFirstSync` with
  nothing recorded), committed `a45b0655`; fixed tree **`7 tests … passed`**;
  R-66 re-run with it (`18o-u2-r66-revert2-mac.log`) **`7 tests … failed … with 15 issues`** (9·2·2·2 — the new pin 2:
  `.awaitingFirstSync`, mark unset); **M-late-only** (the EARLY decision reduced to complete-only, the latch read kept —
  `18o-u2-m-late-only-mac.log`) **`7 tests … failed … with 2 issues`**, both in the new pin. Both deciding reads are
  pinned, each by its own pin. Restored by `git checkout HEAD --`, `git status` clean.
- Closing runs — DONE, on the final code tree `a2166c7f` (logs in `App/Variorum/DerivedData/`):
  - **Core `swift test` (whole)** (`18o-u2-core.log`): **`✔ Test run with 1747 tests in 183 suites passed`**, 1 skipped
    (`basicOfflineEditsConvergeOverTheRealServer` — the standing env-gated live-server pin). Arithmetic: U1's corrected
    baseline 1737/182 + this unit's `SegmentationLineEndingTests` (10 tests / 1 suite) = 1747/183 exactly.
  - **Mac closing set** (`18o-u2-closing.log`) — 40 literal suites: P23's doors and neighbours (`CRLFImportDoorTests`
    `ImportFacesTests` `QuickNoteMintTests` `QuickNoteDoorTests` `QuickNoteWindowTests` `QuickNoteWordTests`
    `QuickNoteParkTests` `CaptureMicrosyntaxDoorTests` `CaptureMicrosyntaxTests` `CaptureKeysTests`
    `CaptureTextViewKeyTests` `CaptureHandOffTests` `ContextBarCaptureTests` `CrystallizationPlannerTests`
    `CrystallizationReconcilerTests` `SpaceEaterTests` `RefontGapTopTests`, and the editor's tail-paste drivers
    `EditorSessionTests` `ReviewRoundFixTests` `GestureSoakTests` `DropAndRefusalCopyTests` `PlainPasteDoorTests`
    `PlainPasteRuleTests`), row 66's seeder family (`LaunchSeedTombstoneTests` `EncryptionBookDoorTests`
    `SampleLibraryTests` `EncryptionExplainedSeedTests` `JekyllTakemaniaSeedTests` `SampleLibraryDedupeFactsTests`) and
    the eleven Tutorial suites — **`✔ Test run with 292 tests in 40 suites passed`**, 0 skipped.
  - **FULL mobile suite, iPhone 17 Pro simulator** (`18o-u2-mobile.log`): **`✘ Test run with 656 tests in 114 suites
    failed … with 5 issues (including 4 known issues)`** — EXACTLY the attributed baseline: the 4 known
    (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` ×2,
    `MobileTutorialStructureWalkTests.theFannedDivideLessonLandsTheDuplicateShape` ×2) + **F-1**
    (`nothingUserFacingNamesTheMac`, its one offender still `SampleLibraryJekyllBook.swift`'s disclaimer — #155's,
    attributed, NOT re-attributed); 0 skipped. 656/114 = 18m's 654/112 + this unit's `MobileCRLFCaptureTests` and
    `MobileFirstWriteTombstoneTests` (1 test / 1 suite each). It runs the phone's capture and first-write occasion
    through both fixes.
- Walks — HELD at start (her app running; guard exit 3). **At the closing runs' end her app was GONE** (no
  `/Applications` instance — not touched by this session; `guard.sh --author` → *"GUARD OK (author: idle 4005s)"*):
  a walk window opened, and the walks RAN — DONE below.
- **THE WALK — DONE** (the dev-store Debug build of this tree, `App/Variorum/DerivedData/18o-u1/Build/Products/Debug/
  Variorum.app`, built 03:09 from the final code; captures in `notes/plans/18o-screens/u2/`, gitignored at `97e0785b`;
  the dev store is fenced from the production mirror (A4) and its footer read "Sync off (dev store)" throughout;
  WalkKit's guarded order before every act — `guard.sh --author` then the pid/point guard, acts ≥ 2 s apart; no foreign
  dialog on screen at the start; no `/Applications` instance at any point; both dev instances quit BY IDENTITY, `pgrep`
  clean after each).
  - **W1 — P23, both voices (dev pid 56737):** File ▸ **Import Files…** → the Open panel → ⌘⇧G the fixture's path
    (`App/Variorum/DerivedData/18o-u2-walk/CRLF-walk-note.md`, three paragraphs, 3 CRLF — `od -c` verified) → Return →
    `Import` pressed by name → ⌘K "CRLF-walk-note" (exactly ONE match) → ⏎ → ⌘6 Blocks: **"3 blocks · 21 words"**, rows
    01 "CRLF walk: the first paragraph, written on Windows." · 02 "The second paragraph, after a blank line." · 03 "The
    third paragraph, one CRLF later." — one block per paragraph. `W1-p23-crlf-import-three-blocks-terminal.png` ·
    `W1-p23-crlf-import-three-blocks-study.png` (voice flipped by the palette's "Use Study Voice", then "Use Terminal
    Voice" — **Terminal RESTORED**, re-captured). Residue: the note "CRLF-walk-note" (in no book) stays in the dev store.
  - **W2 — row 66, the LAUNCH road (faceless; one voice):** shelf ▸ right-click *encryption explained* ▸ **Delete
    Book** (9 books → 8); quit OUR instance by identity; `defaults delete io.lduarte.Variorum.debug
    SampleLibrarySeeded.Variorum-dev.encryption-explained` (was `1` — "this device never seeded it", the row's own
    no-mark device); relaunch (dev pid 57844) → the launch's `sample-library` log (`W2-launch-sample-library.log`):
    **`sample library (Encryption Explained): deletedByTheReader`** beside Sherlock's and the Jekyll book's
    `alreadySeeded`; the shelf still reads **8 books, no *encryption explained*** (`W2-r66-launch-honours-tombstone-
    shelf-terminal.png`); the mark reads `1` again — the decision RECORDED by the launch. (The old build is never run
    on the dev store — the before/after is the harness's R-66.)
  - **W3 — the EXPLICIT door, byte-unchanged (guard):** Help ▸ **Restore "Encryption Explained"** → the book minted
    afresh and opened by the door: *encryption explained · book · 9 chapters · 9 notes*
    (`W3-explicit-restore-door-still-mints-terminal.png`); the mark `1`. The dev store is back to holding the book (a
    fresh reading; the deleted one sits in its Trash).
  - Voices: W1 is the one surface this unit changes the look of (a note's block list) — both voices. W2/W3 are the
    faceless launch road and faces this unit did not touch (the shelf, the book) — one voice (Terminal), by the brief's
    "both voices where the surface has a face".
- Deaths / resumes: none.
- The record closed — DONE (this commit).

### SEAM FILES THIS DIFF TOUCHES (the ladder reads this first — verified by `git diff --stat cf887299..HEAD`)

| File | What changed | What did NOT |
|---|---|---|
| `Sources/VariorumCore/Domain/SegmentationRules.swift` | P23: `normalizedLineEndings` (`"\r\n"`→`"\n"`, then `"\r"`→`"\n"`, a no-CR fast path by UTF-8 byte); `bulkSegments` reads its text through it first (every arm); the type header states which characters are line breaks here and why | `crystallizedBoundary` (type-time — byte-untouched), `trimmedPiece`, the sentence scanner, both split loops, `isBlank` |
| `App/Variorum/Shared/SampleLibrary/SampleLibrarySeeder.swift` | row 66: `readerDeletedTheBook` (the ensure's rule, lifted — `Queries.readingTombstoneExists` on the reserved name); `Outcome.deletedByTheReader`; `perform`'s two deciding reads go through `facts` (one read transaction) + `decidedWithoutMinting`; the header's residual note amended (dated) | `seed`, `discover`, `withSeedLatch`, the account gate and its wait, the marks' keys, the manifest, `dedupeFacts`/`allDedupeFacts` (byte-identical — the engine sees nothing new), `Book` |
| `App/Variorum/Shared/SampleLibrary/SeededBookRestore.swift` | the ensure reads `SampleLibrarySeeder.readerDeletedTheBook` (an address change — its 8 pins rode unmodified) | `restore` (the explicit doors — byte-unchanged), `Declined`, `failureLine`, the ensure's mark-first order |
| `.gitignore` | `notes/plans/18o-screens/` (each phase's own line) | — |
| Tests (NEW files only) | `Tests/VariorumCoreTests/SegmentationLineEndingTests.swift` · `VariorumTests/CRLFImportDoorTests.swift` · `VariorumTests/LaunchSeedTombstoneTests.swift` · `VariorumMobileTests/MobileCRLFCaptureTests.swift` · `VariorumMobileTests/MobileFirstWriteTombstoneTests.swift` | every existing test file (zero edits) |

**Zero `Sources/VariorumCore/Sync/`** (the dedupe is U6's; `allDedupeFacts` unchanged), zero `Server/`, zero schema /
migrations (marker 9), zero new settings. **Editor seam untouched** (`EditorTextView`, `BlockRangeIndex`,
`PaneSurface`, `PaneTextAuthority`, the read tier, `EditorSurfaceController`) — and `Shared/EditorBrain/
CrystallizationPlanner.swift` is not edited: its `.bulk` plan (a paste into the open tail) calls `bulkSegments`, so it
now reads a CR/CRLF paste like its LF twin (pinned `aCRLFPasteIntoTheOpenTailSegmentsLikeItsLFTwin`), while its
`.typing` and `.idle` plans over TYPED text are byte-identical (pinned `theTypedRoadKeepsAControlReturnAsContent`;
`M-isNewline` shows that guard biting). The phone's `MobileQuickNote` and `MobileFirstWriteFurniture` are untouched —
they inherit both fixes through the shared brains (pinned).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **P23 — normalise at `bulkSegments`' entry, never `Character.isNewline`.** The segmenter decides BLOCK boundaries;
   that family keys on `"\n"` only (`NewlineSplitting`'s doc; `CaptureSurfaceTests`' ⇧⏎ pin), and `isNewline` would
   have turned a TYPED Control-Return into a block boundary at the idle mint. Proven by mutation (M-isNewline: the two
   guards red, 3 + 1). *Reverse by* keying the split on `\.isNewline` (and accepting the idle-mint change).
2. **P23 — `one_block` reads its line endings too** (the text otherwise verbatim), so the one block the rest of the
   brain sees has the `"\n"` breaks `NewlineSplitting`/`BlockRangeIndex` recognise. Invisible on the page (TextKit
   breaks a paragraph at either). *Reverse by* normalising only in the `.paragraph`/`.sentence` arm.
3. **P23 — the fix reaches the editor's open-tail PASTE** (the `.bulk` plan) — the same defect at a sibling bulk door,
   AppSpec §7's own list ("bulk entry (paste, import, drop, mobile capture) segments on entry"). *Reverse by* moving
   the normalisation into `importPost`/`importBlocks` (the tail paste then keeps minting one block).
4. **P23 — the exotic newlines (U+0085, U+2028, U+2029) stay CONTENT**, the family's standing answer, pinned as
   documented behaviour (`theExoticNewlinesStayContent`).
5. **P23 — the normalisation mirrors `PlainPaste` rule 1 textually** (the same two steps, same order) rather than
   sharing code: core cannot see `App/Shared`, and moving `PlainPaste` onto a core function is another surface (NOTICED
   4).
6. **Row 66 — the one rule lives on `SampleLibrarySeeder`** (beside `isMarkedSeeded`, the device's evidence; this is
   the store's), read by the ensure AND the launch — "never a second tombstone-reading rule". *Reverse by* moving the
   predicate into `SeededBookRestore` (pure address).
7. **Row 66 — BOTH deciding reads decide** (the early read and the latch's read after the account gate), each pinned
   by its own mutation (M-early-only → the first-round pin; M-late-only → the early-read pin). The early decision
   declines an account-owned store BEFORE its first round when the tombstone is already local — safe, because nothing
   that round could bring would make a mint right (a copy restored elsewhere arrives by sync, never by seed), and it
   records the decision instead of leaving it to a later launch. *Reverse by* dropping the early decision.
8. **Row 66 — a WHOLE live copy answers `.alreadyPresent` before the tombstone is consulted** (a book she deleted and
   then restored): both answers mint nothing and mark; only the outcome's name differs.
9. **Row 66 — a PARTIAL live copy beside a tombstone is not healed at launch** — the ensure's own answer (it declines
   on the tombstone before discovery): such a copy is arriving from a device that restored it (sync brings the rest) or
   is residue of the pre-18o launch's re-mint; Help ▸ Restore completes it on request. *Reverse by* checking the
   tombstone only when no live book exists.
10. **Row 66 — the decision is recorded through the launch's OWN mark leaf** (`save`, injectable), never
    `session.markSeededBook` — the same key in production, and the launch's pins keep their injected-leaf discipline
    (no headless run writes the test host's defaults — the row-36/42 class).
11. **Row 66 — the rule reads the reserved NAME** (as the ensure does): a book SHE created with that exact name and
    deleted also stops the seed on a no-mark device. The seeder's rules make the reserved name the identity.
12. **Row 66 — the phone's first-write occasion inherits the rule** (same brain — MobileSoul §3), pinned rather than
    fenced off: her ruling is about what "deleted" means, which is not per-platform.
13. **The scaffolding landed as its own behaviour-neutral commit** (`59460a98`) so the pins compile on the pre-fix
    tree and R-66 reverts exactly the behavioural hunk (the U1 R-T12 shape).

### NOTICED, NOT TOUCHED (U2's scope fence)

1. **`CaptureMicrosyntax.parse` walks lines on the literal `"\n"`** (`App/Variorum/Shared/CaptureMicrosyntax.swift:111`)
   — P23's class at a sibling brain. In a CRLF capture, rule 5 (a token-only line leaves with its newline) never fires
   and rule 2's one-line promise can be crossed (an unclosed `{#` scans across a CRLF). After this fix the leftover
   CR/CRLF around a removed token reads as an ordinary line break (an edge run drops), so the common case files
   cleanly; the rule-2 edge stands. Needs an owner (the microsyntax's next toucher — 12, or a 17 entry).
2. **The phone box's `one_block` write-back:** in `one_block` mode `MobileQuickNote.adopt` owns the whole capture
   (`frozenPrefix == ""`), the mint stores LF, but the box's raw text keeps the CRs and the first post-mint keystroke
   autosaves that raw text back — CRLF returns to the block. No loss (it was CRLF before this unit); paragraph mode (the
   default) is unaffected (the owned last piece never carries a newline — pinned). `adopt`'s comment "the SNAPSHOT is …
   what the store holds" is no longer byte-exact for a CR capture. The phone's (the mobile app row's).
3. **CR/CRLF pasted INSIDE an existing block stays CRLF content** on both platforms — the I4 road, deliberately
   untouched; the `"\n"`-keyed block brains (Split at Newlines, `TypedReturn`) do not see those breaks. Pre-existing.
4. **`PlainPaste` rule 1 and `SegmentationRules.normalizedLineEndings` are one rule in two homes** — the next toucher
   of `PlainPaste` can call the core function (its pins would ride unmodified).
5. **A no-mark device where she deleted the NOTES but kept the BOOK** re-mints the missing notes into the live book at
   launch — exactly as the ensure/restore road would; R-18k-5 and the ensure read the BOOK's tombstone only.
6. **`SeededBookRestore`'s header residual** still says "a device that never ran either road" — there are now three
   silent/asking roads that record (the launch too). Accurate in substance; a one-word touch-up for the next toucher.
7. **Walk residue in the dev store:** the note "CRLF-walk-note" (in no book); *Encryption Explained* is a fresh reading
   (the deleted one in the dev Trash).

### DRAFTED FOR THE CLOSEOUT (the orchestrator's acts — none applied here)

- **KnownIssues row 66 → RESOLVED at 18o U2:** *"Built per R-18k-5 (honour the tombstone at launch): the launch reads
  the tutorial door's rule — now ONE predicate, `SampleLibrarySeeder.readerDeletedTheBook`, which the ensure reads too —
  at both deciding reads and declines (`deletedByTheReader`), recording the decision in the mark; the phone's
  first-write occasion inherits it. Pins `LaunchSeedTombstoneTests` (per `Book.all`) + `MobileFirstWriteTombstoneTests`.
  The purged-tombstone residual (#138(e)) stays recorded; the SIGNED-OUT-FIRST neighbour is QUESTIONS #146 / 18o U6."*
- **17e copy lines:** *"P23 — FIXED at 18o U2 (`12d61080`): `bulkSegments` reads CRLF/CR as LF at its entry;
  `crystallizedBoundary` untouched; pins `SegmentationLineEndingTests` · `CRLFImportDoorTests` · `MobileCRLFCaptureTests`;
  walk W1."* · *"KnownIssues row 66 — FIXED at 18o U2 (`14822213`, R-18k-5)."*
- **MOBILE PARITY:** P23 reaches the phone's capture (pinned `MobileCRLFCaptureTests`) and row 66 the phone's
  first-write occasion (pinned `MobileFirstWriteTombstoneTests`) — both MOBILE-VISIBLE, both through shared brains,
  zero phone files changed.

### DISPOSITION (one line per ledger row)

10. **P23 — FIXED** `12d61080` (pins `40c3aafc`): core `SegmentationLineEndingTests` (10) — red-on-old **29 issues**
    (9 tests; the exotic-newline guard green); Mac `CRLFImportDoorTests` (5) — **6 issues** (4 tests; the typed-road
    guard green); mobile `MobileCRLFCaptureTests` (1) — **3 issues**. R-P23 identical on all three, restored clean;
    M-isNewline reds exactly the two guards (3 + 1). Walk W1, both voices.
11. **Row 66 (R-18k-5) — FIXED** `14822213` (scaffolding `59460a98`, pins `be0ad315` + `a45b0655`): Mac
    `LaunchSeedTombstoneTests` (7; three parameterized over `Book.all`) — red-on-old **15 issues** (4 tests: the row
    pin 3 per book ×3, the first-round pin 2, the early-read pin 2, the purge pin 2; the three guards green); mobile
    `MobileFirstWriteTombstoneTests` (1) — **2 issues**. R-66 identical, restored clean; M-early-only and M-late-only
    each red their own pin alone (2 · 2). Walks W2 (the launch road on a no-mark dev store logs `deletedByTheReader`,
    the book stays gone, the mark re-recorded) and W3 (Help ▸ Restore still mints).

QUESTIONS rows landed: **none** (no PROVISIONAL arose); the tail marker still reads **#163**.

### UNIT U2 — ORCHESTRATOR ADJUDICATION (2026-09-30; the unit CLOSES here)

**Verified by spot-check, not trusted:** the full range `cf887299..0a082390` read (my away-grant
commit `c523caa6` landed mid-unit — the first scope diff was re-run over the whole range): 9
code/test files + the plan + `.gitignore`; **zero `Sources/VariorumCore/Sync/`, zero `Server/`,
zero editor-seam files, zero trailers** (grep over every message), tree clean, pushed. **Re-run
by this seat:** `swift test --filter SegmentationLineEndingTests` → **10/1 green**. The
`SegmentationRules` diff read whole: the normalise-at-entry design (judgement call 1) is the
RIGHT divergence from the finding's isNewline framing — the block-boundary family keys on `"\n"`
alone and the M-isNewline mutation PROVES the alternative breaks the typed Control-Return guards;
the doc at the code carries the reason. Call 7 (both deciding reads decide, each pinned by its
own mutation) and call 13 (behaviour-neutral scaffolding commit so pins compile pre-fix) are
exemplary; calls 8–11 accepted as recorded (call 11 — a book SHE created wearing the reserved
name — is the seeder's standing identity rule, not new exposure). Closing runs accepted: core
**1747/183** (+10/+1, arithmetic shown), Mac set **292/40**, mobile **656/114 = the attributed
baseline + this unit's 2** — the walks ran under her away grant with the per-step guard.

**ACCEPTED — U2 CLOSED**, rows 10–11 dispositioned (the ledger carries them). **Owners for the
noticed items:** NOTICED 1 (the microsyntax CRLF edge) — ADOPTED INTO THE PHASE as ledger row
12b, riding U3 (P23's class, in-theme, small; the header rule's "unowned ⇒ fix it now" read
honestly); NOTICED 2 (the phone box's `one_block` CRLF write-back) → the MOBILE APP project row
at closeout (phone face; no loss); NOTICED 3 (CR inside an existing block stays content) —
correct under I4, no row; NOTICED 4 (`PlainPaste` rule 1 ↔ core, one rule two homes) — the
next-toucher note stands, no row (the touch rule owns it); NOTICED 5 — the ensure's own standing
behaviour, no row; NOTICED 6 — the header touch-up rides row 12b's commit if free, else stays a
note; NOTICED 7 (walk residue: "CRLF-walk-note" + the deleted *Encryption Explained* in the dev
Trash) → her bundle's residue line. **FOR THE FABLE LADDER:** judgement call 7's early-decision
arm (declining an account-owned store BEFORE its first round — traced safe here, worth cold
eyes), call 2 (`one_block` normalises too), and the drafted KnownIssues row-66 wording.

**U2 — DONE (implementer), awaiting the orchestrator's spot-check.**

---

## UNIT U3 RECORD — the two Mac doors + the microsyntax CRLF rider (implementer: `opus-implementer`, 2026-09-30)

**NOT DONE (first line, per the contract):** (1) The ledger table's rows 12 · 12b · 13, the KnownIssues edits (rows
73 and 79 → RESOLVED), the 17e copy line and the MOBILE PARITY line are the orchestrator's closeout acts — each is
DRAFTED below, none applied. (2) The mid-burst race of row 79 is not hand-walkable (synthetic typing into the TK2
editor drops keys; the window is the autosave debounce) — the pins drive it; the walk covers the doors' ordinary
behaviour through the real menu, P27's precedent. (3) The full Mac suite was not run (the unit's focused closing set
was; the full run is the phase finals'). Everything else the brief asks for is done — both rows, the rider, pins
red-on-old with behavioural reverts, the closing runs, and the walks (her away grant held throughout).

### READING (done in-session before any code)

`CLAUDE.md` + its auto-loaded canon (CoreDescription, OverallModel, AppSpec — §9's `merge`/`mergeCeremony` contract,
§12's ceremony-sheet lines) · this file WHOLE (the U1/U2 records, seam tables and adjudications; the U3 section with the
row-12b bullet) · `notes/KnownIssuesAndTechDebt.md` (the header rule; rows 73 and 79 in full) ·
`notes/SessionResiliencyProtocol.md` whole · `notes/plans/phase-18k-runtime-hygiene.md` — the UNIT C1 RECORD's "FOUND ON
THE WAY" (row 73's trace + its CORRECTION: `_debugPrecondition`, compiled out at -O) and the UNIT C5 RECORD whole (THE
TRACE item 3, NOTICED 1 = row 79's two outcomes, NOTICED 5, JUDGMENT CALL 6) · the 17-file's 17e P27 brief + verifier
trace and its C5 disposition lines · P27's fix `dee61938` · `App/Variorum/Shared/CaptureMicrosyntax.swift` whole +
`CaptureMicrosyntaxTests` + `CaptureMicrosyntaxDoorTests` · `SegmentationRules.swift` whole (U2's
`normalizedLineEndings`). The code at HEAD `89935c26`: `EditorCommands.swift` (the ⌘<n> and ⌘⇧<n> sites),
`WorkspaceNavigation.swift`'s `OpenNotes` (`ordinalCap`, `id(atOrdinal:)`), `ShellRouter.openNote(ordinal:)`,
`SidebarView.openRow`, `PostMode`, `EditorSurfaceController`'s `.merge` arm / `openMergeCeremony` / `openMergeRunChoice`
/ `liveActiveFans(AndRendered)` / `runKeepOnTopDivide`'s cross-reference, `FannedDefaultsCopy`, `FannedDefaultsTests`,
`MergeCeremonySheetTests`' header, both capture doors (`QuickEntryModel.submit`, `QuickNotePad.take`),
`NoteCardFace.firstWords`. **Instance state at start:** `pgrep -fl Variorum` → nothing (her away grant stands).

### LIVE STATUS

- Reading + this record opened — DONE (this commit).
- Row 73 (the Open strip's tenth row) — DONE: scaffolding `060cc060` · pins `112921bc` · fix `ee2e1292`.
  **THE TRACE (at the code, HEAD `89935c26`):** `EditorCommands.swift:776-787` rendered View ▸ Open Note as
  `ForEach(openNotes.shown.enumerated())` with `.keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), …)` on
  EVERY row; `OpenNotes.shown` is every open note (up to `trackedCap` = 20 since Act 10 item 9, `a9772471`), so the
  tenth row builds `Character("10")` → `Character.init(_: String)`'s `_debugPrecondition` (one grapheme) traps the
  Debug app — the crash report's frames read exactly `Character.init(_:)` ← `closure … in EditorCommands.body.getter` ←
  `ForEachState.item(at:offset:)`; compiled out at -O (18k C1's CORRECTION), so Release builds a malformed two-grapheme
  key. **A SECOND defect on the same row, found tracing it:** the row's click called `router?.openNote(ordinal: 10)`,
  and `OpenNotes.id(atOrdinal:)` stops at `ordinalCap` (9 — pinned `OpenNotesTests.theOrdinalsCoverTheFirstNineRows`),
  so rows 10+ were rendered doors that landed nothing (P-2), in Release today and in Debug once the trap is gone.
  **THE SHAPE (why the pin reds without aborting the runner):** the menu now renders a TABLE,
  `OpenNotes.menuRows` → `[OpenStripMenuRow(noteID, ordinal, keyText: String?)]`, one item per row — title, key and act
  all read the row — and the key rides as TEXT; the ONE `Character` conversion is `OpenStripMenuRow.keyboardShortcut`,
  used only by the menu. The pins read the table (never building a `Character`), so on the old rule the tenth row's
  `"10"` is a test FAILURE, not a trap. The behaviour-neutral scaffolding `060cc060` expressed the OLD rule through the
  table (key text on every row, the ordinal act through the new `ShellRouter.openStripRow`) — the Debug trap preserved
  byte-for-byte — so the pins compile and red on it (U2's call-13 shape). A source-walk guard
  (`theOpenNoteMenuRendersTheTable`) holds the menu to the table.
  **THE FIX (`ee2e1292`):** `menuRows` keys only `ordinal <= OpenNotes.ordinalCap` — the model's OWN key cap, which the
  sidebar's ordinal badges (`SidebarView.openRow`) and the ⌘⇧n address already honoured; rows 10+ render by name,
  keyless. `openStripRow` opens the note the row NAMES (`pendingSelection = .post(row.noteID)`), so the tenth row acts.
  **The `:748` ⌘<n> sibling — VERDICT: SAFE BY ITS CAP, not the same class:** the same construction over
  `PostMode.allCases`, a CLOSED enum of seven, so `"\(i + 1)"` is always one character; pinned as the cap
  (`theModeKeysCanNeverReachTen` — a tenth mode reds here instead of trapping the Debug app at launch) + a comment at the
  site; code untouched. Sweep: no other `KeyEquivalent(Character(…))` in the app (grep).
  **Pre-fix (`18o-u3-r73-prefix.log`, the scaffolding tree):** **`Test run with 6 tests in 1 suite failed … with 25
  issues`** — `theMenuWithTenOpenNotesKeysOnlyTheFirstNine` 1 · `everyKeyTheMenuWearsIsOneCharacterUpToTheTrackedCap`
  22 (rows 10–20 × two) · `aRowPastNineStillOpensTheNoteItNames` 2; the three guards green. **Fixed**
  (`18o-u3-r73-fixed.log`): `OpenStripMenuTests` + `NavigationHistoryTests` `OpenNotesTests` `WorkspaceNamingTests`
  `WorkspaceModelTests` `NavigationDoorsTests` `CapabilityRegistryTests` `ShellChromeTests` **`Test run with 71 tests in
  8 suites passed`**. **R-73** (the three production files from `112921bc` over the fix, `18o-u3-r73-revert.log`):
  **`6 tests … failed … with 25 issues`**, the same three tests with the same counts (1·22·2), the guards green; restored
  by `git checkout HEAD --`, `git status` clean. No QUESTIONS row: the key cap is the model's standing rule
  (`ordinalCap`'s own doc: "rows past nine are click/scroll rows"), and a rendered row acting is P-2 — no product
  decision was made.
- Row 13 / KnownIssues 79 (⌥⌘⇧M's choice from the store) — DONE: pins `539d830f` · fix `fbd5c55f`.
  **THE TRACE (at the code, HEAD `89935c26`, `EditorSurfaceController.applyStructural`'s `.merge` arm):** the ceremony
  branch gated on `leadingArity`/`trailingArity` = `model.slots[i].activeVariantCount`, which `EditorProjectionPolicy`
  freezes while the buffer is dirty (every delivery `.deferUntilClean`). (a) A take BORN mid-burst → arity 1/1 → the
  guard refused `FannedDefaultsCopy.mergeCeremonyNeedsAFan` ("These blocks have one take each…") while the store held a
  fan. (b) A take ARCHIVED mid-burst → arity still 2 → `openMergeCeremony` → `flushNow` → `liveActiveFansAndRendered`
  (the truth) says 1/1 → its fallthrough `runInstantMerge` → an INSTANT merge from the ceremony door, and its receipt
  read the same stale slots: *"Merged the visible takes — 1 other take stays with the released block…"* about a take
  that was archived, not active (the pre-fix log shows it). `openMergeCeremony` has ONE caller (this branch); its
  instant fallthrough dates from 13b 4B, when ⌘⇧M itself opened the sheet and an unfanned pair's instant merge was that
  door's everyday answer — since 13j J4b the sheet is ⌥⌘⇧M's alone, whose ruled answer for an unfanned pair is the
  needs-a-fan refusal (`FannedDefaultsTests.theMergeCeremonyDoorOnAnUnfannedPairRefuses`).
  **THE FIX (`fbd5c55f`) — ONE store read decides, both ways:** the arm's slots guard is removed; `openMergeCeremony`'s
  existing post-flush read (`liveActiveFansAndRendered` — `liveActiveFans`' sibling, the same fans + the rendered pair)
  IS the authorization: fanned → the sheet (as ever); unfanned → `mergeCeremonyNeedsAFan`, never the instant merge.
  This is P27's rule (never authorize from `slots`) in the shape `openMergeRunChoice` (the run door, one branch over)
  already has: flush, one store read, refuse on no fan. **Judgement call 1 below** says why this and not a second
  `liveActiveFans` read in the arm. **The await window (the brief's note for the ladder), stated:** this fix adds NO
  await — the arm previously awaited nothing before its gate and then awaited the open's flush + read; now it awaits
  only the open's flush + read. And the press no longer reaches `runStructural` at all (the old (b) road reached it
  through `runInstantMerge`, behind two awaits); the sheet's confirm roads are byte-unchanged and keep
  `runStructural`'s own in-flight guard. Three doc cross-references that described the retired fallthrough were kept
  honest (the `.merge` arm's header parenthetical, `runKeepOnTopDivide`'s and `runCarryAllMerge`'s "same shape" notes)
  — comment-only.
  **Pre-fix (`18o-u3-r79-prefix.log`):** **`Test run with 4 tests in 1 suite failed … with 4 issues`** —
  `aTakeBornMidBurstOpensTheCeremonyInsteadOfRefusing` 2 (the false refusal spoken; no sheet) ·
  `aTakeArchivedMidBurstRefusesInsteadOfMergingInstantly` 2 (one block where two stood; the stale receipt instead of
  the refusal); the guards `aStandingFanStillOpensTheCeremonyMidBurst` · `anUnfannedPairMidBurstStillRefusesAndKeeps
  HerTyping` green. **Fixed** (`18o-u3-r79-fixed.log`): the 4 + `FannedDefaultsTests` (UNMODIFIED — P27's pin and
  guard, `theMergeCeremonyDoorStillOpensTheSheetPrePaired`, `theMergeCeremonyDoorOnAnUnfannedPairRefuses` included) +
  `FannedDefaultsBoardTests` + `MergeCeremonySheetTests` + `MergeArrangementTests` + `SeamMergeTests` **`Test run with
  90 tests in 6 suites passed`**. **R-79** (`EditorSurfaceController.swift` from `539d830f` over the fix,
  `18o-u3-r79-revert.log`): **`4 tests … failed … with 4 issues`**, identical (2·2), guards green; restored by `git
  checkout HEAD --`, clean. **M-guard** (the fixed tree with ONLY the arm's slots guard put back,
  `18o-u3-r79-m-guard.log`): **`… failed … with 2 issues`**, all in (a) — (b) green. **M-fallthrough** (the fixed tree
  with ONLY the instant fallthrough put back, `18o-u3-r79-m-fallthrough.log`): **`… failed … with 5 issues`** — (b) 2
  and the unfanned guard 3 (with the arm's gate gone, the refusal in the open is what every unfanned ⌥⌘⇧M now meets —
  load-bearing, and pinned twice). Each half is pinned by its own pin; both restored clean. No QUESTIONS row: both
  outcomes are the door's ruled behaviour (the sheet for a fan, the refusal for none) — only the fact it reads changed.
- Row 12b (the microsyntax reads CRLF) — DONE: pins `b21b0c7f` · core access `d2a63c43` · fix `cefde52b`.
  **THE TRACE (at the code, `CaptureMicrosyntax.swift:111`):** `parse` walks `raw.split(separator: "\n")`; `"\r\n"` is
  ONE `Character` ≠ `"\n"` and a bare `"\r"` is not `"\n"` either, so a CRLF/CR capture is ONE line to the parse.
  **Rule 5 misread** — a token-only line is never alone on a line, so its breaks stay: `"Paragraph one.\r\n{#dream}\r\n
  Paragraph two."` parsed to `"Paragraph one.\r\n\r\nParagraph two."`, which U2's CRLF-reading `bulkSegments` stores as
  `["Paragraph one.\n", "Paragraph two."]` — an invented BLANK PARAGRAPH (the spacing ruling keeps it). **Rule 2
  misread** — `token(in:at:)`'s scan for `}` crosses the CRLF: `"{#dream\r\nHad a weird dream about the ocean}"` parsed
  to tag path `"dream\r\nHad a weird dream about the ocean"` and text `""`, so the shelf box took its EMPTY branch —
  box cleared, `submit()` nil, NOTHING FILED: the capture lost (the pad's `.nothingToFile` twin). Mid-capture, the
  swallowed words left the note and rode a tag path. **A third consequence of the same reading, found tracing the
  doors:** both doors derive the first-words title from the PARSED text (`NoteCardFace.suggestedTitle` →
  `firstWords`, which splits its "first line" on `"\n"`), so a CRLF capture stored a NAME running across the line
  break with the break inside it (`"Garden plans\r\nthe roses need water"`). Pinned with the rest.
  **THE FIX:** rule 0 — `parse` reads its input through `SegmentationRules.normalizedLineEndings` FIRST (before the
  fast path; judgement call 5), so every rule after it sees `"\n"` lines. `normalizedLineEndings` was `internal` in
  core: **the one legal core line — `public`, body byte-unchanged (`d2a63c43`, its own behaviour-neutral commit)**;
  `CaptureMicrosyntax.swift` gains `import VariorumCore`. The rule doc gains rule 0 and rule 6's byte-identical promise
  is restated "apart from rule 0's line endings". Zero phone files (the phone's capture face does not call the parse
  yet — grep: only `QuickEntryModel.submit` and `QuickNotePad.take`).
  **Pre-fix (`18o-u3-r12b-prefix.log`):** **`Test run with 8 tests in 2 suites failed … with 22 issues`** — brain:
  `aTokenOnlyCRLFLineLeavesWithItsLineBreak` 3 · `anUnclosedTokenNeverScansAcrossACRLF` 6 ·
  `aForeignLineEndingCaptureParsesExactlyAsItsLFTwin` 8; doors: `theShelfBoxInventsNoBlankParagraphWhereACRLFTokenLine
  Stood` 1 · `anUnclosedTagAtACRLFNeverCostsHerTheCapture` 1 (`submit() → nil`) · `thePadFilesACRLFCaptureLikeItsLFTwin`
  1 · `theOfferedTitleIsTheFirstLineOfACRLFCapture` 2; the guard `theExoticSeparatorsStayContent` green. **Fixed**
  (`18o-u3-r12b-fixed.log`): the 8 + `CaptureMicrosyntaxTests` + `CaptureMicrosyntaxDoorTests` (BOTH UNMODIFIED — LF
  byte-identical, the 3C proof) + `CRLFImportDoorTests` `QuickNoteMintTests` `QuickNoteDoorTests` `QuickNoteParkTests`
  `QuickNoteWordTests` `CaptureKeysTests` `CaptureHandOffTests` `ContextBarCaptureTests` **`Test run with 75 tests in 12
  suites passed`**. **R-12b** (`CaptureMicrosyntax.swift` from `b21b0c7f` over the fix, the core `public` kept —
  `18o-u3-r12b-revert.log`): **`8 tests … failed … with 22 issues`**, identical (3·6·8 · 1·1·1·2), the guard green;
  restored clean. **M-afterfast** (normalise only AFTER the no-brace fast path, `18o-u3-r12b-m-afterfast.log`): **`…
  failed … with 3 issues`** — exactly the brace-free arms (the twin test's no-brace fixture ×2, the no-token title
  arm ×1): the placement is pinned. Restored clean.
- U2's NOTICED 6 (assigned to ride row 12b at U2's adjudication) — DONE `ff1f85ab`: `SeededBookRestore`'s header
  residual names the three roads that record (the ensure, the explicit doors, the launch seed since U2) — comment-only.
- Closing runs — DONE, on the final code tree `ff1f85ab` (zero app instances before each; logs in
  `App/Variorum/DerivedData/`):
  - **Mac closing set** (`18o-u3-closing.sh` → `18o-u3-closing.log`) — 106 literal suites: row 73's menu/router/window
    family (`OpenStripMenuTests`, the five `WorkspaceNavigationTests` suites, `CapabilityRegistryTests`
    `ShellChromeTests` `ChordLegibilityTests` `NewModesTests`, the nine `CommandRoutingTests` suites, the seven
    `WindowsTests` suites, the eight `PaneSplitTests` suites, the three `ShellLandingTests` and three `SystemHotKeyTests`
    suites), row 79's merge-door family (this unit's `MergeCeremonyDoorAuthorityTests` + 18k C5's merge-door list:
    `FannedDefaultsTests` `FannedDefaultsBoardTests` `SeamMergeTests` `MergeArrangementTests` `MergeCeremonySheetTests`,
    the four `SeamEdit*`, `BoundaryFluidityTests` `EditorSeamCostTests` `EditorSeamMountedCostTests`
    `EditorWindowSmokeTests` `GestureSoakTests`, the ten `StructuralGestureTests` suites, the seven planner suites,
    `DestructiveUndoWarningTests` `BlockDeletionAndRedoTests` `CrossBlockCompoundTests` `MenuFlightDoorAwaitTests`
    `ReturnKeyUndoSignTests` `ShellConfirmTests` `UndoHintAndRefusalTests`), row 12b's capture family (this unit's two
    suites + `CaptureMicrosyntaxTests` `CaptureMicrosyntaxDoorTests` `CRLFImportDoorTests` `QuickEntryBarTests`, the four
    `QuickNoteTests` suites, `QuickNoteParkTests` `TitleSuggestionChipTests`, the three `CaptureSurfaceTests` suites,
    `ContextBarCaptureTests`) and **the eleven Tutorial suites** — **`✔ Test run with 666 tests in 106 suites passed`**,
    0 skipped. DONE.
  - **Core `swift test` (whole — owed by the one `public` line)** (`18o-u3-core.log`): **`✔ Test run with 1747 tests in
    183 suites passed`**, 1 skipped (`basicOfflineEditsConvergeOverTheRealServer`, the standing env-gated pin) —
    U2's 1747/183 exactly (this unit added no core test). DONE.
  - **iOS generic build** (`18o-u3-ios-build.log`): **`** BUILD SUCCEEDED **`** (`Shared/CaptureMicrosyntax.swift` now
    imports VariorumCore; `SeededBookRestore.swift` comment). DONE.
  - **FULL mobile suite, iPhone 17 Pro simulator** (`18o-u3-mobile.sh` → `18o-u3-mobile.log`): **`✘ Test run with 656
    tests in 114 suites failed … with 5 issues (including 4 known issues)`** — EXACTLY the attributed baseline: the 4
    known (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor` ×2,
    `MobileTutorialStructureWalkTests.theFannedDivideLessonLandsTheDuplicateShape` ×2) + **F-1**
    (`nothingUserFacingNamesTheMac`, its one offender still `SampleLibraryJekyllBook.swift`'s disclaimer — #155's,
    attributed, NOT re-attributed); 0 skipped. 656/114 = U2's count (this unit added no phone test; it compiles and runs
    the shared `CaptureMicrosyntax` + `SeededBookRestore` changes). DONE.
- Walks — the run (her away grant; the dev-store Debug build `App/Variorum/DerivedData/18o-u1/Build/Products/Debug/
  Variorum.app`, built 04:40 from the final code tree — the last code commit is 04:36; zero instances by path before
  launch; `guard.sh --author` then the pid guard before every act, acts ≥ 3 s apart; no foreign dialog on screen
  (`W0` full-screen check); `caffeinate -d` for the walk; captures in `notes/plans/18o-screens/u3/`, gitignored):
  - **W1 — row 73, ten open notes in one window — PASS (Terminal; the menu is system chrome, voice-independent).**
    Ten notes opened through ⌘K (the Sherlock stories, *A Scandal in Bohemia* … *The Noble Bachelor*); the app
    SURVIVED the tenth (the pre-fix Debug build trapped exactly here — 18k C1's crash report); the Open strip scrolls
    with ⌘⇧ badges on rows 1–9 (`W1a-ten-open-notes-strip-terminal.png`). **The real menu read back through
    Accessibility** (`View ▸ Open Notes (⌘⇧1–9)`, enabled): rows 1–9 `AXMenuItemCmdChar` = "1"…"9" with
    `AXMenuItemCmdModifiers` = 1 (⇧⌘); row 10 *The Adventure of the Noble Bachelor* — `AXMenuItemCmdChar` = missing
    value, modifiers 8 (no ⌘) — KEYLESS. The submenu captured open (`W1b-open-notes-submenu-ten-rows.png` + `…-full.png`,
    which also shows the ⌘1–⌘7 mode keys — the `:748` sibling). **⌘⇧1** opened *A Scandal in Bohemia*
    (`W1c-…png`); **pressing the keyless tenth row** (AX press on menu item 10) opened *The Adventure of the Noble
    Bachelor* (`W1d-tenth-row-click-opens-its-note-terminal.png`) — the row acts (P-2); on the old road it asked the
    ordinal address and landed nothing.
  - **W2 — row 79, ⌘⇧M and ⌥⌘⇧M through the real Block menu — PASS, both voices.** A scratch note staged through the
    shelf's quick-entry bar (`U3 walk alpha.` ⇧⏎ `U3 walk beta.` ⏎ → two blocks, in no book). (a) ⌘A, **Block ▸ Merge
    choosing takes…** on the UNFANNED pair → the ruled refusal *"These blocks have one take each — ⌘⇧M joins them.
    Merge choosing takes is for arranging the takes when either side has a fan."*, both blocks intact
    (`W2a-…-terminal.png`, `W2a-…-study.png`). (b) Caret into block 2, **Block ▸ New Take (Branch)** (the fan badge
    appears), ⌘A, **Merge choosing takes…** → the sheet *"Merge choosing takes · 2 blocks · 1 + 2 takes"*, pre-paired,
    Bring every take selected, no rows touched (`W2b-…-terminal.png`, `W2b-…-study.png`); Esc cancelled it. (c) ⌘A,
    **Block ▸ Merge Blocks** (⌘⇧M's item) → one block wearing the carried fan, receipt *"Blocks merged — the takes you
    were looking at joined, an…"* (`W2c-merge-blocks-carries-the-fan-terminal.png`). **Not hand-walkable, said
    plainly:** the mid-burst race itself (a take born or archived INSIDE a typing burst's defer window) — synthetic
    typing into the TK2 editor drops keys (WalkKit's standing fact) and the window is the autosave debounce; the pins
    drive exactly that race, P27's precedent (18k C5 THE GUI WALK step 6).
  - **W3 — row 12b, a CRLF paste through the shelf's quick-entry bar — PASS, both voices.** Her clipboard was EMPTY (no
    types) before the walk; each fixture was placed with `pbcopy`, pasted with ⌘V, and the box's own AX value read back
    by bytes (`0d 0a` present — the CRLF reached the model; the box is a plain-text `NSTextView` whose `textDidChange`
    hands `view.string` straight on); the clipboard was cleared to no types afterwards (as found). (a) **`{#dream⏎U3
    walk: a weird dream about the ocean}` (CRLF)** — the old parse swallowed it whole into a tag path, cleared the box
    and filed NOTHING; now ⏎ files it: Blocks mode reads **"2 blocks · 9 words"**, 01 `{#dream` · 02 `U3 walk: a weird
    dream about the ocean}`, no tag applied (`W3a-crlf-unclosed-tag-capture-in-box-terminal.png`,
    `W3a-crlf-unclosed-tag-files-two-blocks-terminal.png`). (b) **`U3 walk: paragraph one.⏎{#u3walk}⏎U3 walk: paragraph
    two.` (CRLF)** → the `u3walk` chip on the note and the two paragraphs ADJACENT in Write (block 1/2) — no blank
    paragraph where the token line stood (`W3b-…-terminal.png`, `W3b-…-study.png`). A unique tag was used rather than
    `{#dream}` so the dev store's *dream journal* smart book is not fed walk residue.
  - Voices: W1 is system menu chrome (voice-independent — one capture set). W2's refusal toast and sheet and W3b's note
    captured in BOTH voices (flipped by the palette's "Use Study Voice", then **"Use Terminal Voice" — Terminal
    RESTORED** and re-verified by capture).
  - Closing state: the dev instance quit BY IDENTITY (`tell application id "io.lduarte.Variorum.debug" to quit`),
    `pgrep -fl 'Variorum.app/Contents/MacOS'` empty afterwards; no `/Applications` instance at any point; this walk's
    `caffeinate -d` stopped (the two other `caffeinate` processes are not this session's and were left). **Walk
    residue in the dev store:** three scratch notes titled *2026-09-30* (in no book): the W2 note (merged, one block
    carrying a two-take fan), the W3a note (`{#dream` / `U3 walk: …}`), the W3b note (two blocks, a second take on block
    2, tagged `u3walk` — a NEW tag in the dev taxonomy); the window's Open strip holds the ten Sherlock stories
    (session state).
- Walks — DONE (W1 · W2 · W3 above).
- Deaths / resumes: none.
- The record closed — DONE (this commit).

### SEAM FILES THIS DIFF TOUCHES (the ladder reads this first — verified by `git diff --stat 89935c26..HEAD`)

| File | What changed | What did NOT |
|---|---|---|
| `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` | **The editor seam's PAIR (row 79):** the `.merge` arm's ceremony branch loses its `slots`-arity gate and calls `openMergeCeremony` directly; `openMergeCeremony`'s unfanned arm refuses (`FannedDefaultsCopy.mergeCeremonyNeedsAFan`) instead of `runInstantMerge`; its doc says the read IS the door's authorization. Doc-only: the arm's header parenthetical, P27's comment's last sentence, `runKeepOnTopDivide`'s and `runCarryAllMerge`'s "same shape" cross-references (they cited the retired fallthrough) | the non-ceremony branches (P27's store read, the fanned default), `runInstantMerge`, `runCarryAllMerge`'s code, `runStructural`, `liveActiveFans(AndRendered)`, `openMergeRunChoice`, the sheet's confirm roads, every signature |
| `App/Variorum/Variorum/EditorCommands.swift` | **Row 73:** View ▸ Open Notes renders `openNotes.menuRows` (title, key and act read the row); `OpenStripMenuRow.keyboardShortcut` — the one `Character` conversion; a comment at the ⌘<n> mode-key site naming its cap | the mode-key construction itself (verdicted safe by its cap), every other menu item |
| `App/Variorum/Variorum/Workspace/WorkspaceNavigation.swift` | **Row 73:** `OpenNotes.menuRows` (keys only within `ordinalCap`) + the `OpenStripMenuRow` value type | `ordinalCap`, `trackedCap`, `id(atOrdinal:)`, `opened`/`close`/`move`, eviction |
| `App/Variorum/Variorum/ShellRouter.swift` | **Row 73:** `openStripRow(_:)` — opens the note the row names | `openNote(ordinal:)` (kept; its pins ride), every other door |
| `App/Variorum/Shared/CaptureMicrosyntax.swift` (shared — the phone compiles it) | **Row 12b:** `import VariorumCore`; `parse` reads its input through `SegmentationRules.normalizedLineEndings` first (rule 0); the rule doc (rule 0 added, rule 6 and `Capture.text` restated) | every scanner, rules 1–5's code, `applyTags`, `tagRefusal`, `isQuote`, `isHorizontal` |
| `Sources/VariorumCore/Domain/SegmentationRules.swift` (core) | **Row 12b:** `normalizedLineEndings` becomes `public` (+ one doc sentence) — the brief's legal one-line access change | its body, `bulkSegments`, `crystallizedBoundary`, every other rule |
| `App/Variorum/Shared/SampleLibrary/SeededBookRestore.swift` (shared) | U2's NOTICED 6 (assigned to ride 12b): the header residual names the three roads that record — comment-only | every line of code |
| Tests (NEW files only) | `VariorumTests/OpenStripMenuTests.swift` · `VariorumTests/MergeCeremonyDoorAuthorityTests.swift` · `VariorumTests/CaptureMicrosyntaxLineEndingTests.swift` (two suites) | every existing test file (zero edits — `FannedDefaultsTests`, `CaptureMicrosyntaxTests`, `CaptureMicrosyntaxDoorTests`, `WorkspaceNavigationTests` ride UNMODIFIED) |

**Zero `Sources/VariorumCore/Sync/`, zero `Server/`, zero schema / migrations (marker 9), zero settings.** Editor seam
proper untouched (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, the read tier) —
`EditorSurfaceController` changed only in the `.merge` arm's ceremony authorization (+ the doc cross-references
above). Core touched by ONE access modifier (so `swift test` whole was run). Zero phone files.

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **Row 79 — ONE store read decides (the open's), not a second `liveActiveFans` read in the arm (the brief's letter,
   "P27's exact shape").** (i) One read for one question — this file's own lesson (13u3 UNIT G's R3-6 note beside
   `runFansAndRendered`: *"Two reads for one question is how the open-time lag window was born"*); (ii) an arm read
   alone still leaves the open's post-flush fallthrough to decide an archive landing DURING the flush, so the
   fallthrough had to become the refusal anyway — and once it is, the arm's read decides nothing the open does not;
   (iii) the run door (`openMergeRunChoice`) already has exactly this shape; (iv) it ADDS NO AWAIT, so the brief's
   ladder note about "one more await before `runStructural`'s flight flag" does not apply — the press no longer
   reaches `runStructural` at all (the old (b) road reached it through `runInstantMerge`). P27's rule — never
   authorize from `slots` — is honoured exactly. *Reverse by* restoring the arm gate as a `liveActiveFans` read.
2. **Row 79 — "its ruled refusal" is `FannedDefaultsCopy.mergeCeremonyNeedsAFan`.** The brief's parenthetical names
   the `mergedBlockWouldHaveNoTake` family; that is the op's and the sheet's I10-at-birth refusal for a CONFIRM with
   no pairing and no carry, which an unfanned pair never reaches. The door's ruled answer for an unfanned pair is the
   needs-a-fan sentence, pinned `FannedDefaultsTests.theMergeCeremonyDoorOnAnUnfannedPairRefuses` (and it is what
   18k C5's NOTICED 1 meant by "its ruled refusal"). *Reverse by* a different copy constant.
3. **Row 79 — an unfanned ⌥⌘⇧M now FLUSHES before it refuses** (the open's standing flush-first). Consequences,
   stated: her pending buffer is written a moment earlier than the debounce would have; if that flush fails, the door
   speaks *"Unsaved changes couldn't be written…"* rather than needs-a-fan (a real problem she should hear first).
   Guard pinned: `anUnfannedPairMidBurstStillRefusesAndKeepsHerTyping`.
4. **Row 73 — every row opens the note it NAMES** (by id), keyed rows included — one road; the row's title, key and
   act read one captured id, so what the menu shows is what it opens. `openNote(ordinal:)` is kept (its pins ride;
   see NOTICED 1). *Reverse by* `openStripRow` delegating to `openNote(ordinal:)` within the cap and by id beyond.
5. **Row 73 — rows past nine RENDER (keyless)** rather than being dropped from the menu — the brief's "render
   without shortcuts", and the menu then lists every open note exactly as the strip shows every one (Act 10 item 9).
6. **Row 73 — the key rides as TEXT; the one conversion has no count guard.** A future cap change reds
   `everyKeyTheMenuWearsIsOneCharacterUpToTheTrackedCap` loudly (and traps Debug) rather than silently dropping a key.
7. **Row 73 — scaffolding first** (`060cc060`, the old rule through the new table, the trap preserved) so the pins
   compile and red on the pre-fix rule without aborting the runner — U2's call-13 shape.
8. **Row 73 — the `:748` ⌘<n> sibling verdicted SAFE BY ITS CAP** (a closed enum of seven) with a pin and a comment;
   its construction untouched.
9. **Row 12b — normalise BEFORE the no-brace fast path.** Every capture's output reads its lines as `"\n"`; the stored
   note is identical either way (the segmenter reads them so since U2), and the hand-off's first-words title — derived
   from the PARSED text — is then right for a brace-free CRLF capture too. Pinned by M-afterfast (3 issues). *Reverse
   by* moving the line below the guard (and accepting the brace-free title edge).
10. **Row 12b — the core change is ONE access modifier, its own behaviour-neutral commit** (`d2a63c43`), body
    byte-unchanged; `swift test` whole run for it.
11. **Row 12b — U+2028 / U+2029 / U+0085 stay content** (the block-boundary family's rule; guard
    `theExoticSeparatorsStayContent`), so rule 0 is exactly `PlainPaste` rule 1's reading, never `isNewline`.
12. **U2's NOTICED 6 landed as its own comment-only commit** (`ff1f85ab`) — U2's adjudication assigned it to ride
    12b "if free"; 12b's fix commit had already landed, so it rides beside it.
13. **Every pin in its own NEW file**, so every existing suite rides unmodified (the 3C proof, U2's practice).

### NOTICED, NOT TOUCHED (U3's scope fence)

1. **`ShellRouter.openNote(ordinal:)` now has NO production caller** — the Open Notes menu acts through `openStripRow`
   by id; the ⌘⇧n keys ARE the menu items. Its pin (`NavigationDoorsTests`' router arm) rides unmodified. Retire it
   (with its pin re-pointed at `openStripRow`) at the next touch, or keep it as the ordinal address's named door.
2. **The capture boxes' LIVE title chip reads the RAW box text** (`QuickEntryModel.suggestedTitle` /
   `QuickNotePad.suggestedTitle` → `NoteCardFace.suggestedTitle` → `firstWords`, which splits its "first line" on the
   literal `"\n"` in core): on a CRLF paste the chip OFFERS a name running across the line break while she types (by
   reading the code; not walked). The STORED name is right since this unit (the hand-off re-derives from the parsed
   text — pinned). The durable fix is `firstWords` reading lines by the family's rule (core `Domain`, its own pin) — a
   second surface, so not taken. Needs an owner (12, or a 17 entry).
3. **CR/CRLF INSIDE an existing block** (U2's NOTICED 3) also meets `firstWords` on a card's or chip's first line — the
   same core edge as item 2, recorded with it.
4. **The sheet's "Bring every take" confirm still falls back to the INSTANT merge** when the fan vanished between the
   open and the confirm (`runCarryAllMerge`'s unfanned fallback). Correct as it stands — she CONFIRMED a merge, and the
   instant merge is the merge of what is there — but it is the one road on which the ceremony surface can still end in
   an instant merge; named for the ladder, not a defect.
5. **The mid-burst race of row 79 is not hand-walkable** (see the NOT-DONE line); a two-instance staging (13u3 UNIT G's
   fact) would still need synthetic typing inside the debounce, which the TK2 editor drops.
6. **Walk residue in the dev store** (named under Walks): three *2026-09-30* scratch notes and the new tag `u3walk`.

### DRAFTED FOR THE CLOSEOUT (the orchestrator's acts — none applied here)

- **KnownIssues row 73 → RESOLVED at 18o U3:** *"Built: View ▸ Open Notes renders `OpenNotes.menuRows`; only rows the
  model's own key cap reaches (`ordinalCap`, 9) wear ⌘⇧1–9, rows past nine render keyless — no `Character("10")`, no
  Debug trap, no malformed Release key — and every row opens the note it names (the tenth row's click had been inert
  too: the ordinal address stops at nine). The ⌘<n> mode keys verdicted safe by their cap (a closed enum of seven),
  pinned. Pins `OpenStripMenuTests`; walk W1 — ten notes in one Debug window, the real menu read back by
  Accessibility."*
- **KnownIssues row 79 → RESOLVED at 18o U3:** *"⌥⌘⇧M's choice is the ceremony open's own post-flush store read:
  fanned → the sheet, unfanned → the ruled needs-a-fan refusal, never the instant merge (the 13b-4B fallthrough
  retired — the sheet is ⌥⌘⇧M's alone since 13j J4b). One read for one question; no await added. Pins
  `MergeCeremonyDoorAuthorityTests` (both directions red-on-old; M-guard / M-fallthrough each red their own half)."*
- **17e copy line** (beneath 18k C5's P27 line, which routed the residue here): *"The ceremony branch's residue
  (KnownIssues 79) — FIXED at 18o U3 (`fbd5c55f`; pins `MergeCeremonyDoorAuthorityTests`)."*
- **MOBILE PARITY:** *nothing mobile-visible* — rows 73 and 79 are Mac-only surfaces; row 12b changed the SHARED
  `CaptureMicrosyntax`, which the phone compiles but does not call yet (its capture face is the mobile catch-up's —
  when it lands it inherits rule 0 for free). The FULL mobile suite ran at the attributed baseline.
- **Owners wanted:** NOTICED 1 (the orphaned ordinal door — next touch), NOTICED 2–3 (`firstWords`' line reading —
  12 or a 17 entry).

### DISPOSITION (one line per ledger row)

12. **Row 73 — FIXED** `ee2e1292` (scaffolding `060cc060`, pins `112921bc`): `OpenStripMenuTests` (6) — red-on-old
    **25 issues** (3 tests: ten notes 1 · to the tracked cap 22 · the tenth row's act 2; the three guards green, no
    trap); R-73 identical, restored clean; the `:748` sibling verdicted SAFE by its cap (pinned). Walk W1.
12b. **The microsyntax CRLF edge — FIXED** `cefde52b` (pins `b21b0c7f`, core access `d2a63c43`):
    `CaptureMicrosyntaxLineEndingTests` + `CaptureLineEndingDoorTests` (8) — red-on-old **22 issues** (7 tests; the
    exotic-separator guard green), including the lost-capture road (`submit()` nil); R-12b identical, restored clean;
    M-afterfast pins the placement (3). The existing microsyntax suites UNMODIFIED and green. Walk W3, both voices.
13. **Row 79 — FIXED** `fbd5c55f` (pins `539d830f`): `MergeCeremonyDoorAuthorityTests` (4) — red-on-old **4 issues**
    (both directions, 2·2; both guards green); R-79 identical, restored clean; M-guard reds (a) alone (2),
    M-fallthrough reds (b) + the unfanned guard (5). `FannedDefaultsTests` UNMODIFIED and green. Walk W2, both voices.

QUESTIONS rows landed: **none** (no product decision arose — the key cap is the model's standing rule, a rendered row
acting is P-2, both ⌥⌘⇧M outcomes are the door's ruled behaviour, and rule 0 is the family's reading); the tail marker
still reads **#163**.

**U3 — DONE (implementer), awaiting the orchestrator's spot-check.**

### UNIT U3 — ORCHESTRATOR ADJUDICATION (2026-09-30; the unit CLOSES here)

**Verified by spot-check, not trusted:** 17 commits `139d9846`…`7c1ef5a0`, pushed, ZERO trailers,
tree clean. Scope exact (10 code/test files + the plan; zero `Sync/`, zero `Server/`, zero
editor-seam files beyond `EditorSurfaceController`'s `.merge` arm, which row 13 names in-scope).
**The row-13 diff read IN FULL by this seat** (the `.merge` arm, `openMergeCeremony`, both
fallback comments): one caller (`applyStructural`'s ceremony branch — grep-verified), the doc
cross-references honest at all four sites.

**THE DESIGN DIVERGENCE — ADJUDICATED ACCEPTED (the in-batch fork rule, applied after the
fact):** the brief sketched P27's shape (a `liveActiveFans` read in the branch); the implementer
instead REMOVED the frozen-slots gate and made `openMergeCeremony`'s own post-flush store read
the door's one authorization — fanned → the sheet, unfanned → `mergeCeremonyNeedsAFan`, NEVER
the instant merge. This is judged the BETTER design against the spec: (1) ONE read for one
question, and FRESHER (post-flush) than a branch-side read; (2) no added await — the press never
reaches `runStructural`, so the C5-NOTICED-5 window this seat's brief warned about does not
exist on this road at all; (3) the retired instant-merge fallthrough was 13b-4B residue from
when ⌘⇧M owned the sheet — since 13j J4b the sheet is the ceremony door's alone, and P-2's
fire-and-DO says a door performs ITS act or delivers the real refusal, never a different act;
(4) both directions + the stale receipt are pinned red-on-old with per-half mutations.
**Process note, recorded not waived:** the fork rule says the implementer returns with its
proposal BEFORE building that half; under the away-run it built with full transparency in the
record instead. The compensating control is this adjudication plus the ladder — **the divergence
is a NAMED LADDER FOCUS** (cold eyes on: the retired fallthrough's reachability from any other
road; the sheet's confirm-time fallback the implementer flagged — a fan vanishing between open
and confirm still merges on confirm, believed correct because she confirmed a merge).

**Rows 12/12b accepted as recorded** — row 73's second found defect (rows 10+ never opened on
click) is a real P-2 fix on the same door, in-scope; the mode-key sibling's prove-safe verdict
accepted; 12b's one-line core access change (internal → public, body byte-unchanged, own commit)
is the legal shape the brief named. Closing runs accepted (Mac 666/106 · core 1747/183 · iOS
green · mobile 656/114 = the attributed baseline); walks W1–W3 run under the grant, both voices,
residue named. **Owners for the noticed items (applied at closeout):** `ShellRouter.openNote(ordinal:)`
zero-consumer forward → 18n (structure singles' class, beside row 70's remainder);
`NoteCardFace.firstWords`' live title-chip preview across a CR (cosmetic, core face) → 12 (the
polish/cosmetic family) — the FILED title is already pinned to stop at the break; dev-store
residue (three "2026-09-30" scratch notes + the `u3walk` tag) → her bundle's residue line.
**ACCEPTED — U3 CLOSED.**


---

## UNIT U4 RECORD — the book leaving savepoint, R-18k-6 (implementer: `opus-implementer`, 2026-09-30)

**NOT DONE (first line, per the contract):** (1) The ledger row 14, the KnownIssues row-78 edit, the 17-file / closeout
lines and the MOBILE PARITY line are the orchestrator's closeout acts — each is DRAFTED below, none applied. (2) The walk
ran in ONE voice (Terminal): this unit changes no face (the note box, Block History and the Compare board are untouched
surfaces — U2's one-voice reasoning for faceless roads). (3) The Index arm and Book (spread) mode were not hand-walked —
the walk covers Outline (W1, W2) and Compare (W3); the Index arm is carried by its MOUNTED red-on-old pin, the spread by
the rule (it reads the same focus authority as Outline). (4) The registry DROP is not observable in the running app
without instrumentation — the walk shows the savepoints; the drop is pinned (and C1's in-app walk measured the entries
already). (5) The full Mac suite was not run (the phase finals'). Everything else the brief asks for is done.

### READING (done in-session before any code)

`CLAUDE.md` + its auto-loaded canon (OverallModel §3's savepoint occasions; AppSpec §9's quiet auto-commit list —
`closeAutoCommit` is a CADENCE occasion governed by `savepoint_cadence`) · this file WHOLE (the U1–U3 records, seam
tables and adjudications; the U4 section; the ledger's row 14) · `notes/KnownIssuesAndTechDebt.md` (the header rule; row
78 in full, her ruling verbatim) · `notes/SessionResiliencyProtocol.md` whole · `notes/plans/phase-18k-runtime-hygiene.md`
— THE KICKOFF SITTING (R-18k-6) and the **UNIT C1 RECORD WHOLE** (T1–T5, the fix, LIVE STATUS, DISPOSITION, the three
named residuals, NOTICED 3, the adjudication), the C1 held-walk results, and `18k-ladder-round1.md`'s C1 stress-trace
dismissals · `notes/QUESTIONS.md`'s tail (next free **#163**). The code at HEAD `3c3becc2`: `AppSession` (`autosave(forPost:)`,
`Hold`, `releaseAutosave`, `markLeaving`/`dropAfterLeaving`, `savepointOnLeaving`, `flushExistingAutosave`),
`Workspace/SavepointOnLeave.swift`, `WorkspaceModel` (`shownNoteIDs`, `reportingDepartures`, `select`), `Operations+Variant`
(`closeAutoCommit`, `idleAutoCommit`, `autoCommitDirtyVariants`, `isDirty`), `SavepointCadence`, the book —
`BookView` (the modes, `noteBoxReport`, `publishNoteBox`, `editHere`, `switchMode`, onAppear/onDisappear),
`BookViewModel` (`focus`, `collapse(All)`, `openSpread`/`releaseFocusIfItLeft…`, `liveFocusedPostID`, the Index reports,
`carryPlace`), `BookNoteBox` + `NoteBoxState`, `BookIndexView` (`landOrSeed`, `select`, the row's `onSelect`, the
`edit.livePostID` report, onDisappear), `BookIndexEditModel` whole, `SpreadBookView`'s focus sites, the Outline row's
live/read-cheap fork; `RootView.paneDetail` (how a book is mounted: `.id(readingID)`, `paneFocused: live`) — and Compare:
`CompareViewModel` (`peerSlots`, `coordinator(for:)`, `setPeer`, `removePeerSlot`, `releaseLivePane`, `teardown`,
`isolated deinit`), `CompareBoardView`'s onAppear/onDisappear. The pins' neighbours: `AutosaveRegistryLifecycleTests`,
`AutosaveRegistryReleaseTests`, `SavepointOnLeaveTests`, `BookIndexEditingTests`' mount, `BookOutlineLandingTests`'
`writingEditor`, `NoteBoxMountTests`' book mount, `DebugOracleTwoWindowTests`' unmount. **Instance state at start:**
`pgrep -fl Variorum` → nothing (her away grant stands).

### THE TRACE (inputs → the missing savepoint; every claim re-read at the code)

**Why a note edited in a book is never "left" today.** The Mac's leaving roads are four (`SavepointOnLeave`'s header):
(1) `WorkspaceModel.reportingDepartures` — which compares `shownNoteIDs`, and `shownNoteIDs` is
`panes.compactMap { selections[$0]?.noteID }`: a pane showing `.reading(id)` contributes NOTHING, so no note inside a book
can ever depart that set; (2) a window closing — the same `shownNoteIDs`; (3) ⌘Q (+ the lock, `macWillLock`) — the
registry's quit closure; (4) the quick note's filing. So a note she edits in a book reaches `savepointOnLeaving` only
through (3) or the 2 h idle backstop — C1's T3 case 2, pinned green as `aNoteEditedInABookKeepsItsQuitAndLockSavepoint`
("the lock walk still reached the book-edited note"), and C1's named residual 1 (the entry stays registered until then).
The same for a Compare PEER: the anchor is the pane's own note (road 1 covers it), a peer is not in `shownNoteIDs`.

**Where the book's note-switch fact actually lives (named, not guessed).** The book has ONE published answer to "which
note is she in": **the sidebar note box's state** (18d, her U-10 — `NoteBoxState` `.empty` / `.selected(id)` / `.live(id)`),
computed by `BookView.noteBoxReport` through the pure `BookNoteBox` rule from facts the modes already hold:
- **Outline** — `BookViewModel.focusedPostID` (the book's single focus authority, 13b 3E: "which POST holds the live
  inline editor"; `focus(_:)` is the door every click, navigator row, badge tap and "edit here" funnels through);
  `.live` via `liveFocusedPostID` (nil in an unfocused pane), `.empty` after a click-out / collapse / chapter row.
- **Book (the spread)** — the same focus authority (the active page); a leaf turn releases focus
  (`releaseFocusIfItLeftTheSpread`), after which the box points at the left page (`.selected`).
- **Index** — `BookIndexEditModel.livePostID` (the ONE live pane's note — `authority.livePane?.context`, reported up by
  `BookIndexView`'s `.onChange(of: edit.livePostID)` → `noteIndexLive`) and the column's selection (`noteIndexSelection`);
  by the Index's own rule (13u2 UNIT B / QUESTIONS #110) the two never name different notes — a row click on another
  note BLURS the ring first.
- **Read** — no editing surface (A43): the box shows nothing (`.empty`), whatever `focus` means for the paged reader.
The report is also nil in an UNFOCUSED pane (the split's other pane — `paneFocused`). **Scrolling changes none of these
facts** — the Outline's focus is a click, the Index's selection does not follow scroll ("NO SELECTION-FOLLOW HERE" —
`BookIndexView`), and a far-scrolled focused note's editor unmounting (`NearViewportObserver`) is a surface letting go, not
a leaving (C1's release rule keeps the entry).

**Where Compare's fact lives.** `CompareViewModel.peerSlots` — the model's own picked-peer set (`setPeer`,
`removePeerSlot`, the outline door, the version-peer auto-fill all write it; its `didSet` already acquires every picked
peer's coordinator). The board being LEFT is its `teardown()` (`CompareBoardView.onDisappear` — a mode switch away from
Compare, the pane navigating away, the pane going unfocused, the window closing; the board is re-created fresh on the next
mount, so its peers are genuinely gone).

**The machinery this rides (C1, unchanged).** `savepointOnLeaving(id)`: `markLeaving` (the note is LEFT at the current
acquisition generation) → flush → `closeAutoCommit` → if it LANDED and nobody held the note as it began,
`dropAfterLeaving` (same generation, zero holders, clean coordinator). If a surface still holds the note, the savepoint
lands and the entry stays; that surface's LAST release of a left note re-takes the savepoint (it carries whatever the
departing surface wrote on its way out) and the entry drops then. So reporting a book/Compare leaving through
`savepointOnLeaving` is the whole build — "the C1 drop conditions then retire the registry entry for free".

**What `closeAutoCommit` decides (byte-preserved).** One quiet `kind:'auto'` savepoint per live, unlocked take that
`isDirty` — the buffer differs from the take's last savepoint, OR the take has never been savepointed and is non-empty
(`Operations+Variant.isDirty`); a sealed or vanished note answers `[]`; `savepoint_cadence` ≠ `.everySession` answers `[]`
(the cadence gate is INSIDE the op — no caller can miss it). The flush before it runs in every mode.

### THE DESIGN (settled at the code before any line — the ladder reads this)

1. **The book reports a note LEFT through `SavepointOnLeave` exactly as the workspace does** (a signal on the model, a
   no-op by default, wired by the view to `session.savepointOnLeaving` — `SavepointOnLeave.wire`'s own shape, so a book
   built in a test or a preview writes nothing). **The rule is a pure type, `BookNoteTrail`**, over the box's state:
   the trail remembers the note her CARET was last in (`.live(id)` only); **a `.live` in a DIFFERENT note** departs the
   remembered one (she moved into another note); **a `.selected` naming a different note** departs it too and forgets it
   (she moved to another note without the caret — the Index column's row click, which releases the ring; a leaf turn in
   Book mode); `.empty` departs nothing (clicking out is not moving to another note; Read; an unfocused pane); **leaving
   the book** (`BookView.onDisappear` — the pane navigating away, the split closing, another book taking the pane, the
   window closing) departs the remembered note. A note only LOOKED at (the Index's arrival seed, a row selected with no
   caret, a spread page) never enters the trail, so it is never reported — no savepoint for a note her caret never
   entered, which is also exactly the set of notes today's ⌘Q/lock walk reaches (each note her caret entered holds a
   registry entry by then). A mode switch within one note keeps the same state → nothing.
2. **Compare peers follow the same rule, PROVISIONAL (QUESTIONS #163):** a peer that leaves the picked set (swapped out
   by `setPeer`, removed by `removePeerSlot`) and every picked peer when the board tears down are reported LEFT through the
   same entry; the ANCHOR never is (it is the pane's own note — road 1's; a mode switch away from Compare is not the
   anchor's leaving). Every picked peer already holds a registry entry (the pick acquires), so this too savepoints only
   notes today's ⌘Q/lock walk reaches — earlier.
3. **Zero change to `AppSession`, `Operations`, the editor seam, `Sync/`, schema or settings.** Files expected:
   `Features/BookView/BookNoteTrail.swift` (new, pure) · `BookViewModel.swift` (the trail + signal) · `BookView.swift`
   (feed the box's state; leave on disappear; wire) · `Features/Takes/CompareBoardView.swift` (`CompareViewModel`'s
   signal; wire in the board's onAppear) · `Workspace/SavepointOnLeave.swift` (two `wire` overloads + the header's mapping).

### LIVE STATUS

- Reading + the trace + the design + this record opened — DONE (this commit).
- Pins (red-on-old, MOUNTED — they drive only doors that exist on the pre-fix tree: `BookView` hosted with its model,
  `model.focus`, `requestLanding`, typing into the real live editor / pane, unmounting; `CompareBoardView` hosted,
  `setPeer`, `paneEdited`) — DONE (this commit): `VariorumTests/BookLeavingSavepointTests.swift` (NEW file, two suites):
  `BookLeavingSavepointTests` — bug pins `movingIntoAnotherNoteInOutlineSavepointsTheNoteSheEdited` ·
  `movingIntoAnotherNoteInIndexSavepointsTheNoteSheEdited` · `leavingTheBookSavepointsTheNoteSheWasIn` (each with the
  registry half — C1's `openAutosaveCount` / `quitFinalize.count` extended, C1's own pins untouched); guards
  `aNoteSheWasInButDidNotChangeGetsNothing` (the dedupe) · `aNoteSheOnlyLookedAtGetsNothing` (never-savepointed takes,
  so a wrongly-reported note WOULD be written) · `aModeSwitchInsideOneNoteIsNotALeaving` ·
  `theCadenceSettingStillGovernsTheBooksLeaving` (×2: "Only when I commit", "Idle only");
  `CompareLeavingSavepointTests` — `aPeerSwappedOutGetsItsLeavingSavepoint` ·
  `leavingTheBoardSavepointsItsPeersButNotItsAnchor`. The fixture savepoints every take at setup, so any quiet row is
  the leaving's own.
- Pre-fix run of the pins — DONE (`18o-u4-pins-prefix.log`, tree `88d27529` + the pins): **`Test run with 9 tests in 2
  suites failed … with 13 issues`** — the five bug pins RED: Outline 3 (no savepoint · entries 2 ≠ 1 · quit closures
  2 ≠ 1) · Index 3 (no savepoint · 2 ≠ 0 · 2 ≠ 0) · leave-the-book 3 (no savepoint · 1 ≠ 0 · 1 ≠ 0) · peer swap 1 (no
  savepoint) · board left 3 (no savepoint · 2 ≠ 1 · 2 ≠ 1); the four guards GREEN (the cadence pin's two cases
  included) — green on old by construction (nothing was ever reported); their teeth are shown against mutations after
  the fix. Every premise held on old (the typed text reached the store — the unmount's own flush).
- The fix — DONE `f3ab836e`, verified (below): `Features/BookView/BookNoteTrail.swift` (NEW, pure — the
  rule over `NoteBoxState`) · `BookViewModel` (`noteTrail`, `onNoteLeft` — no-op by default — `notePlaceChanged(_:)`,
  `leaveBook()`) · `BookView` (onAppear: `SavepointOnLeave.wire(book:)` then `reportNotePlace()`; the
  `noteBoxReport` onChange also reports; onDisappear: `model.leaveBook()`) · `CompareViewModel` (`onNotesLeft`, no-op by
  default; `peerSlots.didSet` reports the departed peers — never the anchor; `teardown()` reports every peer before the
  holds go back) + `CompareBoardView.onAppear` wires it · `SavepointOnLeave` (roads 5 and 6 in the header's mapping;
  `wire(book:)`, `wire(compare:)`). Pure rule pins `VariorumTests/BookNoteTrailTests.swift` (NEW, 6 — the rule's table;
  a separate file so the behavioural revert below keeps them compiling). Zero `AppSession`, zero `Operations`, zero
  editor seam, zero `Sync/`, schema, settings.
- **Fixed-tree run — DONE (`18o-u4-pins-fixed2.log`): `✔ Test run with 49 tests in 8 suites passed`** —
  `BookLeavingSavepointTests` 7 · `CompareLeavingSavepointTests` 2 · `BookLeavingRegistryTests` 2 · `BookNoteTrailTests` 6
  · C1's `AutosaveRegistryLifecycleTests` 9 + `AutosaveRegistryReleaseGuardTests` 7 · L-d's `AutosaveRegistryReleaseTests`
  6 · J11's `SavepointOnLeaveTests` 10 — **C1's, L-d's and J11's files UNMODIFIED** (`git diff 3c3becc2 --` over the
  three is empty; `aModeSwitchIsNotALeaving` and `aNoteEditedInABookKeepsItsQuitAndLockSavepoint` ride as they were —
  the second is still true: the Index's teardown alone is not a leaving). **One mid-course adjustment, traced and
  recorded (the pins commit after this one):** the first fixed run (`18o-u4-pins-fixed.log`, 47/7, 4 issues) had every
  SAVEPOINT half green and the two Outline pins' REGISTRY halves red — traced by a diagnostic assertion
  (`18o-u4-diag1.log`): the note's `autosaveHolderCount` read **1** after the switch and **2** after an unmount, i.e. the
  mounted inline editor's `EditorViewModel`s are still ALIVE in the harness for the rest of the async test body (18k C8's
  autorelease-pool class; in the app they die — C1's in-app walk, inits = deinits), so their holds never return there and
  no drop is observable. The Outline pins keep their savepoint halves (the pre-fix reds that matter — the savepoint row);
  the registry claim for the Outline's editor moved to C1's own bare-model shape (`BookLeavingRegistryTests`, both
  orders: the leaving before and after the editor dies); the Index and Compare pins keep theirs (deterministic teardown
  — mounted and red-on-old). The file header states the measured limit.
- Behavioural revert R-U4 — DONE, restored clean (`git checkout HEAD --` the two; `git diff HEAD` empty). Run
  (`18o-u4-r-u4.log`): **`Test run with 17 tests in 4 suites failed … with 9 issues`** — the five bug pins RED, each with
  exactly its pre-fix count for the halves it still carries: Outline 1 (no savepoint) · Index 3 (no savepoint · 2 ≠ 0 ·
  2 ≠ 0) · leave-the-book 1 · peer swap 1 · board left 3 (no savepoint · 2 ≠ 1 · 2 ≠ 1); the four mounted guards green;
  `BookLeavingRegistryTests` (2) and `BookNoteTrailTests` (6) green — by design, they drive the model and the rule
  directly, which R-U4 leaves in place (their teeth are the mutations below). The shape as it ran:
- (R-U4's shape, as named before it ran (the pre-revert state is committed, `9a4e5afc`;
  corrected before starting — the first-named shape would not compile, since the bare-model registry pins call
  `SavepointOnLeave.wire(book:)`): R-U4 = `BookView.swift` checked out from `385fbaeb` (the pins commit — the book never
  wires nor reports its note state) + in `CompareBoardView.swift` the THREE behavioural hunks removed (the
  `peerSlots.didSet` report, the `teardown()` report, the board's `onAppear` wire — `onNotesLeft` stays declared, so
  `SavepointOnLeave` compiles unchanged); `BookViewModel`'s trail, `BookNoteTrail` and the two `wire` overloads stay
  (inert with no caller). Restore by `git checkout HEAD -- <the two>`, verified by `git diff`.)
- The guards' teeth — DONE, every mutation restored clean (`git diff HEAD` empty after each):
  - **M-selected** (`18o-u4-m-selected.log`): **`13 tests … failed … with 2 issues`** — `aNoteSheOnlyLookedAtGetsNothing`
    RED (the Index's arrival seed entered the trail and the never-savepointed note she only looked at was WRITTEN when
    she moved on) + the rule row `aNoteOnlyLookedAtIsNeverRemembered`; every other pin green.
  - **M-empty** (`18o-u4-m-empty.log`): **`13 tests … failed … with 5 issues`** — `aModeSwitchInsideOneNoteIsNotALeaving`
    RED (1): an Outline → Index switch PUBLISHES an empty note-box frame between the two modes (the Index has not seeded
    yet), so a rule that read `.empty` as leaving savepoints the note on a mode switch — measured, which is why `.empty`
    departs nothing; + the rule rows `noNoteIsNotAnotherNote` (3) and `leavingTheBookLeavesTheNoteSheWasInOnce` (1).
  - **M-idle** (the idle occasion, no flush — `18o-u4-m-idle.log`): a POOR mutation, recorded as such: without the
    flush the idle op reads the pre-keystroke rows and writes nothing, so the cadence guard stayed green for the wrong
    reason (the Outline and leave-the-book savepoint halves red instead, 4 issues). Re-run as **M-idle′** — flush, then
    `idleAutoCommit` (`18o-u4-m-idle-prime.log`): **`7 tests … failed … with 3 issues`** — the cadence guard's **"Idle
    only" case RED** (the idle occasion writes under "Idle only"; the leaving occasion never does), its "Only when I
    commit" case green (both occasions are off there), and the Index pin's registry half RED 2 (only
    `savepointOnLeaving` marks a note LEFT, so another writer never retires the entry).
- (The mutations' names, as recorded before they ran (each on the committed fixed tree `35983b36`,
  one at a time, restored by `git checkout HEAD --` and verified by `git diff`): **M-selected** — `BookNoteTrail`
  remembers a `.selected` note too (a looked-at note enters the trail); **M-empty** — `.empty` departs the remembered
  note (clicking out / a mode switch's empty frame counts as leaving); **M-idle** — the book's road runs the IDLE
  occasion (`idleAutoCommit`) instead of the leaving one (the wrong cadence occasion reused).)
- QUESTIONS #163 (the Compare-peer PROVISIONAL, quoting the ruling's own clause, + the book's note-switch reading) —
  DONE (this commit): (1) what counts as moving — (a) built, (b) caret-only, (c) click-out counts too; (2) Compare's
  peers — (a) built, the one-line alternative "peers keep today's timing"; the never-savepointed consequence stated.
  Tail marker → **#164**.
- Closing runs — DONE, on the final code tree `78f9091d` (zero app instances; logs in `App/Variorum/DerivedData/`):
  - **Mac closing set** (`18o-u4-closing.log`; the list `18o-u4-closing-suites.txt` — every suite in every test file
    that constructs or mounts a touched type: `BookView(` · `BookViewModel(` · `BookStructureModel(` · `SpreadBookView(` ·
    `BookIndexView(` · `CompareViewModel(` · `CompareBoardView(` · `SavepointOnLeave.` · `RootView(session` — 35 files,
    96 suites, + L-d's `AutosaveRegistryReleaseTests` + `BookNoteTrailTests`; it carries C1's
    `AutosaveRegistryLifecycleTests` + `AutosaveRegistryReleaseGuardTests` WHOLE, J11's `SavepointOnLeaveTests`, the
    book (`BookViewTests`, `BookIndexEditingTests`, `NoteBoxMountTests`, the landing / outline / index-tier suites,
    `PaneSplitTests`' eight incl. `PaneBookBlurTests`), Compare (`CompareBoardTests`, `CompareLensesCorrectionTests`,
    `TakesBoardSoakTests`), `SavepointNamingTests`' seven, the shell (`ShellChromeTests`, `ShellLandingTests`,
    `WorkspaceNavigationTests`) and **the eleven Tutorial suites**): **`✔ Test run with 466 tests in 98 suites passed
    after 242.119 seconds with 4 known issues`** — the 4 are `IndexTierMetricsTests`' `withKnownIssue` rows (the TK2
    `overTwoBlankLines` residual, #154 (b), recorded since 18l-c U5); 0 skipped. (A 99th name, `NoteBoxTests`, is a
    file, not a type — it selected nothing; its four suites ran on their own: `NoteBoxStateTests`
    `BookNoteBoxSubjectTests` `NoteBoxHeightTests` `NoteBoxCopyTests` **`✔ Test run with 17 tests in 4 suites passed`**,
    `18o-u4-closing-notebox.log`.)
  - **No `swift test`, no iOS build, no mobile suite — owed by nothing:** `git diff --name-only 3c3becc2..HEAD` holds
    zero `Sources/`, zero `App/Variorum/Shared/`, zero `VariorumMobile/` (every production file is Mac-target:
    `Features/BookView/`, `Features/Takes/CompareBoardView.swift`, `Workspace/SavepointOnLeave.swift`); the attributed
    mobile baseline 656/114 stands untouched.
- **Walk — DONE, all three PASS** (her away grant; the dev-store Debug build `DerivedData/18o-u1/…/Debug/Variorum.app`,
  built 06:22 from the final code tree — the last code commit is 05:34; zero instances by path before launch (dev pid
  80703); `guard.sh --author` then the pid/point guard before every act, acts ≥ 2 s apart; no foreign dialog on screen
  (full-screen check first); `caffeinate -d` for the walk; the book *essays in progress* (2 notes: A "2026-09-13" — one
  block "A book not", two hand savepoints from Sep 13; B "2026-09-18" — three blocks, an EMPTY first block); captures
  `notes/plans/18o-screens/u4/`, gitignored; Terminal voice):
  - **W1 — in a book, edit a note, move into another → the quiet savepoint lands — PASS.** Shelf ▸ *essays in progress*
    (opens in Outline, the note box "no note selected"); the navigator row A → A live ("editing · 1 of 2 · block 1/1");
    the box's **history** door BEFORE: 2 savepoints, both "A book not", saved by hand (`W1a-…`). Caret to the block's
    end; " u4walk" typed (paced keystrokes — landed whole, "A book not u4walk", 4w — `W1b-…`). The navigator row B → B
    live, A read-cheap (`W1c-…`). Then (after W2's leave, A opened on its own from the Library, Write, block 1/1) A's
    history reads **3 — "A book not u4walk · sep 30, 2026 at 6:26 am · quiet"** above the two hand savepoints
    (`W1d-noteA-history-after-switch-terminal.png`). Pre-fix this row would not exist until ⌘Q / the lock / 2 h idle
    (the old build is never run on the dev store — the before/after is the harness's R-U4).
  - **W2 — leave the book, a second note → the same — PASS.** In B (caret in its empty first block) "u4book" typed
    (`W2a-…`); B's history BEFORE leaving: **0** — "no saved moments yet" (`W2b-…`, the control: an unleft note owes
    its savepoint). Sidebar ▸ **library** — the book left (`W2c-…`). B opened from the Library: its first block's
    history reads **1 — "u4book · sep 30, 2026 at 6:27 am · quiet"** (`W2d-noteB-history-after-leaving-book-terminal.png`).
  - **W3 — a Compare peer (PROVISIONAL #163) — PASS.** B ▸ **compare**; "related blocks only" turned OFF (the two notes
    share no lineage, so the filter would hide the peer's blocks); **＋ choose a note** ▸ A — the peer column ("there is
    no relationship here"); a click into A's pane (live), " peer" typed → "A book not u4walk peer" (`W3a-…`); the peer
    column's **✕** (removed — `W3b-…`). A opened from the Open strip: history **4, "2 quiet savepoints · show"** (J11's
    quiet-run fold — `W3c-…`); expanded: **"A book not u4walk peer · sep 30, 2026 at 6:30 am · quiet"** above the 6:26
    one (`W3d-peer-history-quiet-run-expanded-terminal.png`). The only road that could write A at 6:30 is the peer's
    departure (the pane then navigated B → A: road 1 leaves B, and A was the arriving note).
  - Closing state: A RESTORED to "A book not" through its own history's **Restore** (the 8:35 hand savepoint); B's
    first block cleared back to EMPTY (six paced backspaces — "0w block · 30w in note", three blocks, as found) and its
    mode set back to Write; the dev instance quit BY IDENTITY (`tell application id "io.lduarte.Variorum.debug" to
    quit`) — `pgrep -fl Variorum` empty afterwards; no `/Applications` instance at any point; this walk's `caffeinate
    -d` stopped (two other `caffeinate` processes are not this session's and were left). **Walk residue:** the walk's
    quiet savepoints stay in A's and B's histories (A: "A book not u4walk" 6:26 · "A book not u4walk peer" 6:30, and the
    ⌘Q walk's own "A book not" after the restore; B: "u4book" 6:27 and the quit's empty savepoint) — history is
    append-only by design; the two notes' TEXT is as found; the Open strip holds the two notes (session state).
- Deaths / resumes: none.

### SEAM FILES THIS DIFF TOUCHES (the ladder reads this first — CUSTODY-ADJACENT; verified by `git diff --stat 3c3becc2..HEAD`)

| File | What changed | What did NOT |
|---|---|---|
| `App/Variorum/Variorum/Features/BookView/BookNoteTrail.swift` (NEW) | The pure rule: the caret's note is remembered (`.live` only); `.live` in a different note, or `.selected` naming a different note, reports it LEFT; `.empty` and the same note report nothing; `leaveBook()` reports the remembered note | — |
| `…/Features/BookView/BookViewModel.swift` | `noteTrail` (`@ObservationIgnored`), `onNoteLeft` (no-op by default), `notePlaceChanged(_:)`, `leaveBook()` — beside the Index reports | `focus`, `collapse(All)`, the spread, the Index reports, `carryPlace`, every observed property |
| `…/Features/BookView/BookView.swift` | onAppear: `SavepointOnLeave.wire(book:)` then `reportNotePlace()`; the `noteBoxReport` onChange also reports; onDisappear: `model.leaveBook()`; `reportNotePlace()` (the box's state → the model) | `noteBoxReport`, `publishNoteBox`, `editHere`, `switchMode`, every mode's body |
| `…/Features/Takes/CompareBoardView.swift` | `CompareViewModel`: `onNotesLeft` (no-op by default); `peerSlots.didSet` reports departed peers (never the anchor); `teardown()` reports every peer before the holds go back; the board's onAppear wires it | `coordinator(for:)`, the cache, `releaseLivePane`, `setPeer`/`removePeerSlot` bodies, `teardown`'s flush-then-release, `isolated deinit`, every gesture |
| `…/Workspace/SavepointOnLeave.swift` | roads 5 (book) and 6 (Compare peers) in the header's mapping; `wire(book:)`, `wire(compare:)` — each a closure onto the existing `leaving(_:session:)` spawn | `wire(workspace:)`, `windowClosing`, `leaving` |
| Tests (NEW files only) | `VariorumTests/BookLeavingSavepointTests.swift` (three suites: book 7 · Compare 2 · registry 2) · `VariorumTests/BookNoteTrailTests.swift` (6) | every existing test file — C1's `AutosaveRegistryLifecycleTests.swift`, L-d's `AutosaveRegistryReleaseTests.swift` and J11's `SavepointOnLeaveTests.swift` have ZERO diff |

**Zero `AppSession` (C1's registry — `markLeaving`/`dropAfterLeaving`/`savepointOnLeaving`/`releaseAutosave` — byte-
untouched), zero `Operations` (`closeAutoCommit` byte-untouched), zero editor seam (`EditorTextView`, `BlockRangeIndex`,
`PaneSurface`, `PaneTextAuthority`, `EditorSurfaceController`), zero `Sources/`, zero `App/Variorum/Shared/`, zero
`VariorumMobile/`, zero `Sync/`, `Server/`, schema / migrations (marker 9), settings.** The custody-adjacent content is
WHEN `savepointOnLeaving` is called (two new callers), never what it does.

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **The book's note-switch fact is the note box's state** (`NoteBoxState`, via `BookView.noteBoxReport` / the pure
   `BookNoteBox`) — the one answer the book already publishes to "which note is she in", so the leaving and the box can
   never disagree; the shell cannot learn it (it must not hold a feature's view model — the box's own doc), so the book
   reports its own leavings, as the workspace does its own. *Reverse by* feeding the trail from `focusedPostID` /
   `indexLivePostID` directly (and re-deriving the mode's rule).
2. **Only the CARET's note enters the trail** (`.live`): a note she only looked at is never reported. This keeps the
   reported set to notes that hold a registry entry by then — exactly the set today's ⌘Q/lock walk savepoints — so the
   fix changes WHEN, never WHICH. (One measured-by-reading edge: a focused Outline note whose editor never mounted — far
   off the viewport — is reported though it held no entry; `closeAutoCommit` decides as on every road.) Pinned by
   `aNoteSheOnlyLookedAtGetsNothing` (M-selected reds it). *Reverse by* remembering `.selected` too.
3. **A `.selected` naming a different note is a move** (the Index's row click, which releases the ring; a leaf turn in
   Book mode) — PROVISIONAL, QUESTIONS #163 (1)(a); (b) caret-only.
4. **`.empty` is never a move** — clicking out, Read, an unfocused pane, and (measured, M-empty) the empty frame an
   Outline → Index switch publishes before the Index seeds. #163 (1)(c) records "clicking out counts" as hers.
5. **Leaving the book = `BookView.onDisappear`** — the book's view is `.id(readingID)`-stable and stays mounted in an
   unfocused pane (`paneFocused: false`), so it disappears only when the pane stops showing it: navigating away, the
   split closing, another book, the window closing. The book's "Open in the full editor" also leaves the book — the
   note is savepointed while its pane now shows it on its own: the `SavepointOnLeave` header's accepted consequence
   (the same note shown elsewhere), and C1's generation guard keeps the pane's own entry. *Reverse by* a workspace-side
   departure for `.reading` selections (a second fact).
6. **The signal lives on the model, no-op by default, wired by the view** (`SavepointOnLeave.wire(book:)` /
   `wire(compare:)`) — `WorkspaceModel.onNotesLeft`'s shape: a model built in a test writes nothing (every existing
   book/Compare test rides unchanged), and dead wiring is caught by the MOUNTED pins (the view wires it; R-U4 reds them).
7. **Compare reports EVERY departing peer**, not only one her caret was in: every picked peer already holds a registry
   entry (the pick acquires), so ⌘Q/lock would savepoint each — same WHICH, earlier WHEN (#163 (2)(a)). The anchor never.
8. **A swapped-out peer's HOLD stays with the board until its teardown** (C1's per-post cache lifetime, unchanged), so
   the savepoint lands at the swap and the registry entry retires at the board's teardown. *Reverse by* releasing that
   post from the cache at the swap (flush, then one release) — a new C1-class release site, deliberately not taken.
9. **The board reports its peers BEFORE its holds go back** — either order ends the same (C1: the last release of a
   LEFT note re-takes the savepoint and drops the entry).
10. **The Outline pins' registry half moved to C1's bare-model shape** after a TRACED harness limit (the mounted inline
    editor's model stays alive for the async test body — holders 1 / 2 measured); the savepoint halves stayed mounted and
    red-on-old; the Index and Compare mounted pins keep their registry halves red-on-old. Not a weakening: every claim is
    pinned where its lifetime is deterministic.
11. **The fixture savepoints every take at setup**, so any quiet row is the leaving's own; the one pin that needs
    never-savepointed takes (the looked-at note) says so.
12. **A named consequence of the Index's per-post cache (the C1 ladder's stale-mark class):** after the Index departs a
    note, re-entering that SAME note inside the same Index session is a cache hit — no new acquisition — so the entry
    stays marked LEFT; when the Index later tears down (a mode switch included) its release re-takes the savepoint and
    drops the entry. At worst one extra quiet savepoint (deduped when nothing changed) at a mode switch; nothing can be
    lost (a drop still needs a landed savepoint, zero holders, an unchanged generation, a clean coordinator), and the next
    surface's acquisition mints a fresh entry. Named for the ladder.
13. **One voice for the walk** (no face changed); the Index arm and Book mode are carried by pins/rule, not the walk.

### NOTICED, NOT TOUCHED (U4's scope fence)

1. **The Outline's focus survives an Index excursion to another note** (pre-existing): Outline(A) → Index, work in B →
   back to Outline mounts A's editor (the book's stale `focusedPostID`) while the carry scrolls to B's anchor. Under this
   unit that reads as moving back into A — so B is left then (correct by the rule; B's savepoint lands). The stale focus
   itself is the book's navigation brain's — an owner for the next toucher of the carry (12, or 18n beside row 70).
2. **C1's named residual 1 is PARTIALLY discharged:** a book / peer note now leaves the ⌘Q/lock walk once it is LEFT
   (the switch, leaving the book, the peer's departure). What remains registered by design: the note she is still IN
   (it is open), a swapped-out peer until its board tears down (call 8), and notes the Index cached until the Index tears
   down. All on the safe side (an entry kept, never dropped early).
3. **The phone was not traced for the same gap** — the phone's book reading surfaces and its own leaving road
   (`MobileSavepointOnLeaving`) are the mobile app row's; this unit is Mac-only (zero phone or shared files). Whether a
   phone book's note switch savepoints is a question for the mobile catch-up.
4. **A harness fact for future pins (record-only, not a defect):** a mounted Outline/Book-mode `EditorViewModel` stays
   alive for the rest of the async test body in the Mac test host (18k C8's autorelease-pool class), so no pin can watch
   its release through a mounted book — use C1's bare-model shape (this file's header says so).
5. **Walk residue** (named under the walk): the walk's quiet savepoints in the two *essays in progress* notes' histories.

### DRAFTED FOR THE CLOSEOUT (the orchestrator's acts — none applied here)

- **KnownIssues row 78 → RESOLVED at 18o U4:** *"Built per R-18k-6: a note edited inside a book gets its leaving
  savepoint when she moves into a different note or leaves the book — `BookNoteTrail` over the book's note-box state,
  through `SavepointOnLeave` (road 5, the one `savepointOnLeaving` entry); Compare peers swapped out, removed, or left
  with the board likewise (road 6, PROVISIONAL, QUESTIONS #163). Once left, the note leaves the ⌘Q/lock walk (18k C1's
  drop — its named residual 1 partly discharged). Pins `BookLeavingSavepointTests` · `CompareLeavingSavepointTests` ·
  `BookLeavingRegistryTests` · `BookNoteTrailTests`; walk W1–W3."*
- **18k C1 residual line** (wherever the closeout carries C1's residuals): *"Residual 1 (book / Compare-peer notes stay
  registered until ⌘Q/lock) — partly discharged at 18o U4: they now leave when LEFT; what stays registered is open by
  design (U4 NOTICED 2)."*
- **MOBILE PARITY:** *nothing mobile-visible* — every production file is Mac-target; the phone's book road is the mobile
  app row's (NOTICED 3).
- **Her bundle:** QUESTIONS #163 (the book's reading of "moving to another note" and the Compare-peer PROVISIONAL).

### DISPOSITION (one line per ledger row)

14. **Row 78 / R-18k-6 — FIXED** `f3ab836e` (pins `385fbaeb`, the registry half's move `9a4e5afc`):
    `BookLeavingSavepointTests` + `CompareLeavingSavepointTests` (mounted) — red-on-old **13 issues** (the five bug pins:
    Outline 3 · Index 3 · leave-the-book 3 · peer swap 1 · board left 3; the four guards green); **R-U4** (BookView from
    the pins commit + the three Compare hunks) **9 issues**, every remaining half at its pre-fix count, restored clean;
    the guards' teeth by mutation — M-selected (2), M-empty (5), M-idle′ (3); `BookLeavingRegistryTests` (2) +
    `BookNoteTrailTests` (6) green; C1's / L-d's / J11's suites UNMODIFIED and green; closing set **466/98** (4 known =
    #154(b)). Walk W1–W3 PASS (Terminal). QUESTIONS **#163** (PROVISIONAL); tail marker **#164**.

- Deaths / resumes: none.

**U4 — DONE (implementer), awaiting the orchestrator's spot-check**

### UNIT U4 — ORCHESTRATOR ADJUDICATION (2026-09-30; the unit CLOSES here)

**Verified by spot-check, not trusted:** 11 commits `88d27529`…`4316a0c2`, pushed, ZERO trailers,
tree clean. Scope exact and TIGHT for a custody-adjacent unit: 7 code/test files; **zero
`Sources/`, zero `Shared/`, zero mobile, zero `Sync/`, zero AppSession/Operations/editor-seam
lines** (fence grep 0); `SavepointOnLeave` +33/−2, its diff read WHOLE by this seat — roads 5–6
declared in the file's own road registry beside the original four, both wired through the ONE
entry with weak-session closures, the not-a-leaving list untouched. **Re-run by this seat:**
the five suites (the U4 pins + `BookLeavingRegistryTests` + C1's `AutosaveRegistryLifecycleTests`)
→ **26 tests / 5 suites green.** The mid-course pin adjustment (the Outline's registry half moved
to C1's bare-model shape after a TRACED harness limit — holders measured 1/2 through the mounted
model's lifetime) is the honest shape, not a weakening: the mounted pins keep the savepoint
half red-on-old, and the registry half is pinned where lifetimes are deterministic.

**ACCEPTED — U4 CLOSED**, row 14 dispositioned. The design reads her ruling narrowly and
correctly: the trigger is the note box's state (the book's REAL focused-note authority since
18d), the trail remembers the CARET's note, and click-out/Read/mode-switch/scroll deliberately
never count — the spec-defensible narrow reading, PROVISIONAL at #163 with the alternative
recorded. C1's named residual 1 is PARTLY DISCHARGED (book/Compare notes now retire their
registry entries through landed leavings — the ⌘Q-walk population shrinks to what is genuinely
still open). **FOR THE FABLE LADDER (custody-adjacent — this unit is the ladder's first read):**
judgment call 5 (leaving-the-book includes "Open in the full editor"), call 8 (a swapped-out
peer's entry retires only at board close though its savepoint lands at the swap), call 12 (an
Index re-entry can cost one extra quiet savepoint at the Index's later close — dedupe permitting),
NOTICED 1 (the Outline keeps stale focus after an Index excursion — pre-existing). **NOTICED 3
(the PHONE was not traced for the same gap)** → the closeout's MOBILE PARITY line states it as
OWED (the phone's book faces + its leaving roads — the mobile catch-up's trace), never
"nothing mobile-visible". Walk residue (the u4walk notes' quiet savepoints in their histories)
→ her bundle's residue line.

---

## UNIT U5 RECORD — 17t, the two unwired protection doors (implementer: `opus-implementer`, 2026-09-30)

**NOT DONE (first line, per the contract — kept current as the unit runs):** (1) **Item 1 (ledger row 15) — the typed
near-empty gate is NOT BUILT: STOP-AND-REPORT.** Traced at the code, the hazard her #86(c) ruling guards does not exist on
the rebuilt Replace All Keys road (THE TRACE below): the road pulls to head FIRST and then re-encrypts the SERVER's own rows
in place (`sync_reencrypt`) — local content never replaces server content — and the settled postures design (hers, "final
as of 2026-09-04") DELETED the probe's UI caller for exactly that reason (§13). A typed gate here would warn of a loss that
cannot happen. The finding is pinned as documented behaviour (green on today's tree = HOLLOW as a defect) and the product
call goes to her as QUESTIONS #164. Zero `Sync/` lines (the probe is untouched). (2) The ledger rows, KnownIssues 54/55
edits, the 17t copy lines and the MOBILE PARITY line are the orchestrator's closeout acts — DRAFTED below, none applied.

### READING (done in-session before any code)

`CLAUDE.md` + its auto-loaded canon (CoreDescription, OverallModel, AppSpec) · this file WHOLE (U1–U4 records, seam tables
and adjudications; the U5 section; ledger rows 15–16) · the 17-file's 17t section · `notes/KnownIssuesAndTechDebt.md`
(header rule; rows 54 and 55 in full) · `notes/QUESTIONS.md` #86 whole (her (c) ruling verbatim: *"I would add a typed
confirmation phrase for the near empty case - maybe a 13u item"*) and #87 (the pointer: *"#86(c)'s typed confirmation lands
with the rebuilt Replace Keys (one home)"*); tail marker **#164** · `notes/SessionResiliencyProtocol.md` whole. **Custody
seam reading:** `Sources/VariorumCore/Sync/RekeyRecencyProbe.swift` whole (READ-ONLY) + `RekeyRecencyProbeTests`; the
probe's history (`b21db5bf` — built with its UI caller on the 14c truncate road, 2026-08-31; `e9e27adb` — the caller
RETIRED at pre-13x 2b.3a, 2026-09-05); `notes/plans/pre-13x-postures-design.md` §0 decision 6, §4 steps 1–3, §5's Replace
All Keys row, §13 WHAT GETS DELETED, the §13 sweep table; `pre-13x-design-history.md` §G + corner 5; 13u2 UNIT D's roster
item 8 verdict table (`phase-13u2-feel.md`); `App/Variorum/Shared/PostureSwitch.swift` (the runner's header, `checkDoor`,
`runCeremony` step 1), `Sources/VariorumCore/Sync/CorpusRotation.swift` `reencryptRemainder` (read-only), every
`resyncReinitialize`/`truncateAccountData` caller. Item 2: `ProtectionPane.swift` (`PassphraseSetSheet`,
`ProtectionNoticeBar`, `PhraseOnlySheet`, `PostureSwitchSheet` — the one live Copy All at `:1188`), the three
`markWordsCopied()` models, `SyncEnrollmentView`, `KeyDoorView`, `PassphraseSetModel`, `SharedPageStyle.PageDoor`,
`EncryptionViews`/`AuthViews`/`SyncStatusViews` (who renders the shared faces — the phone does too, via Settings ▸ Sync ▸
the Account sheet), `pre-13x-copy.md` §2a Screen 3 (*"[the words, numbered] · Copy All (sub-line after copying: Copied.
Your clipboard clears in 60 seconds.)"*) and §4 Regenerate (*"Then 2a's Screens 3/3b"*), decision 23, the pin precedents
`ProtectionSurfaceRenderTests` (`SurfaceComposition`) and `ComposedSliders` (find a node by its own TYPE, drive what a click
drives). **Instance state at start:** `pgrep` → no instances (her away grant stands).

### THE TRACE — ITEM 1 (inputs → the loss #86(c) guards; every claim re-read at the code)

**The hazard her ruling answered** (#86(c), 2026-09-01, about the door AS IT WAS): the 14c `AccountRekey` road TRUNCATED the
server mirror and re-pushed LOCAL truth ("the re-key door is the one local-as-truth road"), so a near-EMPTY store re-keying
over a full server would have flattened it. T1's probe (`b21db5bf`) warned before that truncate.

**The road today** (`PostureSwitchRunner.replaceAllKeys` → `run(entersCastle: false)` → `runCeremony`, `PostureSwitch.swift`):
1. **Step 1 PULL TO HEAD** (`:492-510`) — push what this device owes, then `engine.pullToHead()`, up to three rounds until
   the outbox is empty; refuse otherwise. A near-empty store therefore RECEIVES every server row before anything rotates.
2. **Step 3 RE-ENCRYPT THE SERVER COPY** (`CorpusRotation.reencryptRemainder`, `CorpusRotation.swift:541-610`) — pulls the
   SERVER's rows below the rotation seq, opens each under the previous key, re-seals it under the new key AT THE VERSION IT
   WAS PULLED AT, and writes it back through `sync_reencrypt` (version-neutral; "no truncation" — design §4 step 3). No local
   row's content is ever written over a server row by this road.
3. The file's own header (`:11-15`): *"It REPLACES the 14c `AccountRekey` brain: that road TRUNCATED the mirror and re-pushed
   local truth; this one rotates IN PLACE through `sync_reencrypt` … and never truncates."*

**No other road carries local-as-truth semantics:** `truncateAccountData` has no app caller; `resyncReinitialize`'s one app
caller is `adoptLibrary` (Connect / *Move It to This Account*) — it re-stamps the owner and enqueues every row for an
additive push under the account (sync_version 0 inserts), deleting nothing server-side; `VaultBootstrap`/`PurgeJanitor`
callers are the headless tool and the purge's own reinit, neither a near-empty-clobber door.

**The records' timeline (why the row says "never wired"):** 09-01 her ruling + #87's pointer (the rebuild not yet designed
in detail) → 09-03 the postures design settled (decision 6: re-encryption in place, version-neutral) and its §13 lists
*"`RekeyRecencyProbe`'s UI caller"* under WHAT GETS DELETED → 09-05 2b.3a retires the caller: *"the T1 recency guard RETIRED
with the truncate road it guarded — an in-place rotation clobbers nothing on the server, so there is no server-ahead copy to
warn about"* → 09-15 13u2 UNIT D's verification greps zero consumers and records NOT BUILT — RETURNS (the retirement's reason
not cited) → KnownIssues row 54 → R-18k-2 schedules 17t. The design history's §G/corner 5 (09-01) planned the typed gate
WITH the rebuild; the settled design file "never overrides"-ranks above the history, and it deleted the caller.

**Also the shape does not fit:** the probe reports SERVER-AHEAD counts (`notesOnlyOnServer`, `notesNewerOnServer`,
`latestServerChange`); it has no notion of "near-empty" (no local count, no threshold) — a near-empty reading would need a
new rule (product invention) and, if placed in the probe, a `Sync/` edit (Fable work).

**Disposition path (the contract's hollow rule):** the loss is pinned as ABSENT — a near-empty sibling's Replace All Keys over
a fuller server, the probe reading it exactly as #86(c)'s corner (server ahead by N notes), then every server note still
live on the server under the NEW keys and pulled into the near-empty copy. Green on today's tree ⇒ the row is HOLLOW as a
defect; not fixed. The typed gate itself (friction with honest copy, or none) is hers: QUESTIONS #164.

### THE DESIGN — ITEM 2 (settled at the code before any line)

**The Mac shows the twelve words on FIVE surfaces; one has Copy All.** (1) `PostureSwitchSheet` `.wordsShow` (Castle /
Replace All Keys ceremony; `PostureSwitchModel`) — HAS the door + caption (`ProtectionPane.swift:1188`, the one call
site). (2) `SyncEnrollmentView` `.wordsShow` (SHARED — sync setup, copy §2a Screen 3, which RULES *Copy All* + the sub-line;
`SyncEnrollmentModel`) — the caption branch exists, no door. (3) `KeyDoorView` `.wordsShow` (SHARED — Regenerate Twelve
Words; copy §4: *"Then 2a's Screens 3/3b"*; `KeyDoorModel`) — no door, no caption. (4) `PassphraseSetSheet` `.showPhrase`
(Mac, 13p-era set sheet; `PassphraseSetModel`) — no door. (5) `PhraseOnlySheet` (Mac, the nudge's phrase-only road; no
model) — no door. Her need, verbatim at 13u2's roster: *"we NEED a copy all button on the recovery phrase - i had to copy
them one by one"*, scoped *"everywhere the twelve words are shown"*.

1. **ONE rule, hoisted** — `App/Variorum/Shared/WordsCopyDoor.swift` (a shared-folder file whose whole body is
   `#if os(macOS)`; the phone compiles it empty, and its UIPasteboard arm lands beside it when the mobile row builds it):
   `WordsClipboard.copy(_:to:clearAfter:)` is the existing closure's four statements verbatim (clear, write the words
   joined by one space, read `changeCount`, clear after 60 s ONLY if the count is unmoved) with the pasteboard and the
   interval injectable for pins (production: `.general`, 60 s — decision 23). `WordsCopyDoor(words:pageStyle:onCopied:)`
   renders `PageDoor(ProtectionCopy.wordsCopyAll, style:)` — whose nil arm (the Mac, always) is BYTE-FOR-BYTE
   `Button(title, action:)`, the construction the pane already had — and its one act `copy(to:clearAfter:)` runs the rule
   then `onCopied()`.
2. **The existing door moves onto it** (behaviour-neutral: same title, same construction, same four statements, same
   `markWordsCopied()`), so there is no second copy of the timer.
3. **The four missing faces gain it**, each reporting to its own flag: (2) `model.markWordsCopied()` — the dead caption
   branch becomes reachable; (3) `model.markWordsCopied()` + the caption branch added (copy §2a's sub-line); (4)
   `PassphraseSetModel` gains the siblings' exact `copiedWords` / `markWordsCopied()` + the caption; (5) the flag lives with
   its presenter (`ProtectionNoticeBar`'s `@State`, beside `phraseWords`), handed in as `copied`/`onCopied`, so the sheet's
   caption is a pure function of its inputs (pinnable) — `PhraseOnlySheet` loses its `private` for the pin.
4. **The shared faces' door is `#if os(macOS)`** — the phone renders `SyncEnrollmentView`/`KeyDoorView` too, and the
   phone's word-screen doors (their UIPasteboard semantics — `expirationDate`, `.localOnly` — a call) are the MOBILE APP
   ROW's by the brief; the phone's rendering of the two shared faces stays exactly as today.

**Pins (form: `SurfaceComposition` + `ComposedSliders`' find-by-type-and-drive):** per face, the words screen's composition
carries a `WordsCopyDoor` whose words are the shown words; driving its act (a PRIVATE named pasteboard — her clipboard is
never touched) puts the words on that board and flips the face's flag, after which the recomposed face carries
`ProtectionCopy.wordsCopied`. Red-on-old for faces (2)–(5) on a behaviour-neutral scaffolding tree (the door type + the
hoist + `PassphraseSetModel`'s flag + `PhraseOnlySheet`'s inputs land first, so the pins compile pre-fix — U2/U3's shape);
guards green on both: the hoisted rule's two arms (clears when unmoved; never clears what something else wrote) and face
(1)'s door (the one existing road, byte-unchanged).

### LIVE STATUS

- Reading + the item-1 trace + the item-2 design + this record opened — DONE (this commit).
- Item 1 — the documented-behaviour pin — DONE (this commit): `PostureSwitchTests.aNearEmptyCopysReplaceAllKeysLosesNothingTheFullerServerHolds`
  (an extension appended to `PostureSwitchTests.swift` — the world builders are file-private; no existing test edited).
  A full device pushes 15 notes; a sibling on the same account holds only its own 3, never pulled; the probe reads it
  as #86(c)'s corner (`notesOnlyOnServer == 15`, `RekeyGuardRule` → `.warnFirst`); the sibling runs Replace All Keys;
  then all 18 notes are still live on the mirror, a fresh device under the NEW keys reads all 18 in the clear, and the
  sibling itself now holds all 18. **Run on today's tree (`18o-u5-item1-pin.log`): `✔ Test run with 45 tests in 1 suite
  passed` — the pin GREEN (1.949 s) ⇒ HOLLOW as a defect: the loss the gate would guard does not occur.** Not fixed (the
  contract's hollow rule).
- Item 1 — the pin's teeth (M-noPull: step 1's `pullToHead()` removed) — IN-PROGRESS (named before it runs; the
  pre-mutation state is this commit). Then QUESTIONS #164 — NOT-STARTED.
- Item 2 scaffolding (behaviour-neutral: `WordsCopyDoor.swift`, the hoist, `PassphraseSetModel` flag, `PhraseOnlySheet`
  inputs) — NOT-STARTED.
- Item 2 pins (red-on-old on the scaffolding tree) — NOT-STARTED.
- Item 2 fix (the door in faces 2–5) — NOT-STARTED.
- R-U5 behavioural revert — NOT-STARTED.
- Closing runs (focused Mac suites + the eleven Tutorial suites; iOS generic build; FULL mobile suite — shared files change)
  — NOT-STARTED.
- Walk (Protection pane's copy door + the enrollment page's caption where reachable on the dev store) — NOT-STARTED.
- The re-key DRILL is NOT re-run: no key leg changes (no wrap/unwrap/Keychain write semantics touched) — stated.
- Deaths / resumes: none.
