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
| 12 | **Row 73** — the Open strip's ⌘⇧<n> menu TRAPS at its tenth row in Debug (`EditorCommands.swift:782`; check the `:746` ⌘<n> sibling too); shortcuts for rows 1–9 only (PROVISIONAL), pin mounts the menu with ten open notes | U3 | open |
| 12b | **The microsyntax CRLF edge (adopted from U2's NOTICED 1 — P23's class at a sibling brain, in-theme):** `CaptureMicrosyntax.parse` walks lines on the literal `"\n"` (`App/Variorum/Shared/CaptureMicrosyntax.swift:111`) — in a CRLF capture rule 5 (a token-only line leaves with its newline) never fires and rule 2's one-line promise can be crossed. Fix: read the input through `SegmentationRules.normalizedLineEndings` at `parse`'s entry (App CAN see core; the output already normalises downstream at `bulkSegments`, so no double effect); pins red-on-old for both misread rules | U3 | open |
| 13 | **Row 79** — ⌥⌘⇧M's CEREMONY branch reads the frozen `slots`: a mid-burst take makes it wrongly refuse "needs a fan", and a mid-burst archive falls through `openMergeCeremony`'s truth read into an INSTANT merge instead of its ruled refusal; the P27 fix (`liveActiveFans`, store-read authorization) is the shape (`EditorSurfaceController`, the `.merge` arm) | U3 | open |
| 14 | **Row 78 / R-18k-6, RULED:** a note edited INSIDE A BOOK gets its leaving savepoint when she moves into a different note (or leaves the book), through the existing `savepointOnLeaving` road; Compare peers follow the same rule PROVISIONAL (QUESTIONS row) — the 18k C1 RECORD's machinery (`markLeaving`/`dropAfterLeaving`, the acquisition generation) is required reading | U4 | open |
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
- U3 the two Mac doors (+ row 12b) — IN FLIGHT (implementer spawned 2026-09-30, after the U1 walks).
- U4 the book leaving savepoint (R-18k-6) — NOT-STARTED.
- U5 17t, the two unwired protection doors — NOT-STARTED.
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
