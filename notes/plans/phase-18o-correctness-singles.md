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
  the fenced dev store (`io.lduarte.Variorum.debug`). **Dated note (this kickoff): her
  real-store instance state is UNKNOWN — check before every GUI act; assume she may be at the
  machine at any moment; GUI driving only behind the per-step guard, harness-only when in doubt.**
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
untouched since 18k's finals (**1723/180**); the last full Mac run 18k's **3168/522** (the only
reds the row-93 pointer-injection class with someone at the machine); iOS generic build green;
install `/Applications` binary `3b116e5c…` (18m's refresh). VisualWalk baseline unchanged from
18l-c.

---

## THE LEDGER (every row owned; dispositions land here; the 17-file gets the 17e/17t copies at close)

| # | Item (source) | Unit | Status |
|---|---|---|---|
| 1 | **P29** — the phone's redo door documents a mechanism the code does not have (`MobileUndoDoor.swift:225` false comment; behaviour deliberate, comment owed) | U1 | open |
| 2 | **P32** — scratch-column picks ARE persisted, so `danglingPick`'s lens-only scoping rests on a false premise (`TakesViewModel.swift:1196`); fix the comment, NAME the UX gap (R-18k-1's letter: "P32's UX gap named" — a QUESTIONS row with options, not a build) | U1 | open |
| 3 | **P34** — `BoundarySnapping.settle` overrides an exact placement when a strong boundary sits exactly `settlePull` earlier; the absolutist doc parenthetical + the missing boundary pin (doc + pin; behaviour stands PROVISIONAL, QUESTIONS row) | U1 | open |
| 4 | **P35** — `shelf_pins` never self-heals; a deleted book's pin is stuck forever (`Operations+Appearance.swift:117`; `starred` in the same file is the model) | U1 | open |
| 5 | **P37** — the tray's ARCHIVED listing silently truncates at 500 while its siblings render markers (`TrayPanel.swift:400`) | U1 | open |
| 6 | **17e (12)** — `.toggleSidebar` declared `availability: always` while its menu item greys on `activeWindowKind != .full`; a `windowKind` field on `CapabilityContext` makes the grey a registry fact (P-1) | U1 | open |
| 7 | **Row 84** — a backup copy stamped in the FUTURE silently stops automatic backups and the freshness face never turns stale (`StoreBackup` due-checks; 18k C7's noticed item 1) | U1 | open |
| 8 | **Row 64 — RECORD-ONLY (R-18k-4, *leave it for now*):** re-verify the documented-behaviour pin (`ContentReplacementRedoTests.anUndoEntryOlderThanARestoreCanStillReviveIntoTheRestoredNote`) green; record the ruling in the ledger + the 17e copy; no build | U1 | open |
| 9 | **17e (11) — RECORD-ONLY:** partly discharged by 18d (`RecoveryView.swift:489`); the remainder ACCEPTED on KnownIssues' per-note-view-state row (owner 12) — 18o records the disposition in the 17e copy; no build | U1 | open |
| 10 | **P23** — a CRLF file imports as ONE block: `SegmentationRules` splits on `"\n"` only (`Sources/VariorumCore/Domain/SegmentationRules.swift:67`; MAJOR; the family keys on `Character.isNewline` — only the segmenter disagrees) | U2 | open |
| 11 | **Row 66 / #138(f), RULED R-18k-5 (*honour the tombstone at launch*):** the LAUNCH seeder declines on a tombstoned seeded book exactly as the tutorial door's silent ensure does (`SampleLibrarySeeder.seedIfNeeded`, launch call `VariorumApp.swift:196`) | U2 | open |
| 12 | **Row 73** — the Open strip's ⌘⇧<n> menu TRAPS at its tenth row in Debug (`EditorCommands.swift:782`; check the `:746` ⌘<n> sibling too); shortcuts for rows 1–9 only (PROVISIONAL), pin mounts the menu with ten open notes | U3 | open |
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
- U1 the honesty & paper-cuts batch — IN-PROGRESS (`opus-implementer`; the UNIT U1 RECORD below carries its own LIVE STATUS).
- U2 the import & launch-seed batch — NOT-STARTED.
- U3 the two Mac doors — NOT-STARTED.
- U4 the book leaving savepoint (R-18k-6) — NOT-STARTED.
- U5 17t, the two unwired protection doors — NOT-STARTED.
- U6 #146 (Fable seat) — NOT-STARTED (SyncSpec + postmortem re-read precede any line).
- THE LADDER — NOT-STARTED.
- CLOSEOUT + the install refresh — NOT-STARTED (refresh window unverified; her app's state unknown).

---

## UNIT U1 RECORD — the honesty & paper-cuts batch (implementer: `opus-implementer`, 2026-09-29)

**NOT DONE (first line, per the contract):** PENDING — filled at the unit's close.

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
- Row 84 (future-stamped backup copy) — IN-PROGRESS: THE TRACE (at the code): every due-check in the backup run asks `now.timeIntervalSince(newest) < interval` of the newest of the app's own copies — `StoreBackup.performPrimaryLeg` (:550), `performSecondLeg` (the far folder, :388-391), `performLockTimeCopyIfDue` (:637-639) — and the weekly export's `MarkdownInsurance.performExport` (:137-139) is the same clock one cadence up; a copy stamped ahead makes the difference NEGATIVE, so each reads "fresh" until the clock passes the stamp plus an interval, writing nothing and saying nothing. The face's `FolderSummary.isStale(after:)` asks `Date().timeIntervalSince(newest) > interval` of `summarize`'s `dated.max()` — negative too, never orange (`summarizeExports` the same). Retention checked for a second defect and found none: the far folder's 14+4 keeps the most recent DAYS THAT HAVE A FILE (not relative to now), so a future copy costs one slot, never a real copy. **Pins `09f9e199`**, `BackupFutureStampTests` (8, its own file — C7's `DataSafetyTests.swift` untouched): pre-fix (`18o-u1-r84-prefix.log`) **`Test run with 8 tests in 1 suite failed … with 14 issues`** — primary 3 · second folder 2 · lock-time 1 · weekly export 2 · face 2 · only-future face 2 · exports row 2; the guard `anOrdinaryRecentCopyStillReadsFresh` green. **Fix committed (this commit)** — ONE rule, "a stamp later than now is not evidence of freshness": the due-checks and the face read the newest copy stamped NO LATER than now (the brief's "ignore future-stamped copies for freshness" arm — its other arm, treat-as-due, alone would write at EVERY hourly check while the future copy stays `.last`, C7's reader-3 storm). Built: `StoreBackup.stampIsTrusted(_:now:)` (`stamp <= now`) + `newestTrustedBackup(in:now:)` (the newest own copy it trusts); the three `StoreBackup` due-checks read it; `MarkdownInsurance.performExport` reads its newest export through the same `stampIsTrusted`; `DataSafetyModel.summarize` / `summarizeExports` take `now: Date = Date()` and read `newest`/`oldest` from trusted stamps only (the count still counts every real file); `FolderSummary.isStale(after:now:)` reads a future newest as stale (the belt). Fixed tree: `BackupFutureStampTests` + C7's `BackupOwnFilesTests` (UNMODIFIED — `DataSafetyTests.swift` has zero diff) + `BackupRetentionTests` `BackupRunTests` `BackupSingleFlightTests` `DataSafetyRunbookTests` `MarkdownInsuranceTests` `SyncSafetyFaceTests` `SecretCheckTests` `SnapshotPairTests` `ICloudDriveOfferTests` `MarkdownInsuranceFlipTests` `Phase13pBackupEnvelopeTests` `Phase13pInsuranceFaceTests` `StoreBackupTests` `PostureSwitchTests` **`Test run with 135 tests in 16 suites passed`**, zero skipped. NEXT — the named revert **R-84**: the four production files from `09f9e199` over the fix, run `BackupFutureStampTests`, expect the pre-fix 14 issues; restore `git checkout HEAD --`. **No revert in flight at this commit.**
- Row 64 RECORD-ONLY (pin re-verify + R-18k-4) — NOT-STARTED.
- 17e (11) RECORD-ONLY (disposition line) — NOT-STARTED.
- Closing runs (focused Mac suites · `swift test` · FULL mobile suite) — NOT-STARTED.
- Walk captures (`notes/plans/18o-screens/u1/`) — NOT-STARTED.
- Deaths / resumes: none.
