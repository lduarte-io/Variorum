# RUN A — custody & the text-loss doors (17b + 17l items 1–4/6–7 + 17n + 17m)

**STATUS: OPEN — kicked off 2026-09-21 at the author's word (the `/architect-phase` invocation carrying
`notes/plans/pre-beta-standing-fix-runs.md`'s paste-ready kickoff). Batch A1 next.**

An ad-hoc standing-fixes phase under a Fable orchestrator per the runs file (her confirmed grouping,
2026-09-14, R-13u-6). **The entries themselves live in `notes/plans/phase-17-standing-fixes.md` — that
file is the binding item record**; this file is the run's ONE running record (ledger, batch briefs and
records, adjudications, the ladder, the closeout). At close each entry's dispositions are copied into
the 17 file and 17b · 17l (items 1–4, 6–7) · 17n · 17m close; the phase itself never does.

**Baselines at open (the 13u4 closeout's finals, by reference — `notes/plans/phase-13u4-restyle.md`):**
core **1631/175** green · the FULL Mac suite **3045 tests in 504 suites ALL GREEN, zero issues** ·
iOS build green · mobile **626/106 with exactly the 4 known issues** · marker **8** ·
`/Applications` = the 13u4 Release (hashes in `notes/handoffs/phase-13u4-handoff.md`) · git clean at
`50e581fa`.

**FENCES (binding on every batch):**
- **17l item 5 is NOT this run's** (RUN B's — `Sync/`, the double-passphrase re-wrap in
  `CorpusRotation.swift`). Any fix in ANY batch that wants `Sources/VariorumCore/Sync/` lines STOPS
  AND REPORTS to the orchestrator instead of writing them.
- **17r is fenced out** (opens at her word only). 17e's row 66 (the canvas router fact) is NOT this
  run's either.
- Zero schema expected; marker stays 8. A fix that wants a schema change stops and reports.
- Never touch `/Applications` or her real store mid-run; the install refresh is the closeout's,
  AFTER the walk, behind the A1 backup rail.
- Her real login keychain: READ-ONLY inspection only where a brief names it (A2's item 2
  confirmation); never a write, never a delete.

---

## BINDING PRINCIPLES — the 13b constitution (P-1…P-9, copied byte-verbatim per the skill; the application notes bind the same way)

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

**Application notes (13b's build record, binding as stated in the skill):** P-1's scope is the
ROUTED vocabulary, grown incrementally (surface-local doors declare `.surface`, never mis-filed).
P-3 keeps TWO deliberate surface kinds (the full-document editor is never absorbed into the pane
surface; both consult the ONE authority and the ONE per-post autosave coordinator —
`AppSession.autosave(forPost:)`; any liveness extension extends the authority's one-live-ring
contract ON the authority). Storage-coupled code lives feature-side; parity refactors keep every
pre-move name as computed forwards/typealiases so every existing pin compiles UNMODIFIED (the 3C
pattern). Every equality-gated sink delivers its stored state AT WIRE TIME; overlay geometry
refreshes trigger on EVERY input axis. The closing form for a recurring fixed class is the sweep
table: instance × host/path, each cell FIXED-with-named-pin or provably SAFE.

**Run-relevant note:** P-8's chrome-`fixedSize` rule is now pinned by construction
(`VariorumTests/ChromeLineLimitTests`, 13u4 UNIT S3) — new chrome this run adds must pass it.

---

## THE LEDGER (every row owned; a row closes FIXED-with-named-pin · DISMISSED-AS-HOLLOW · DEFERRED-with-owner)

| # | Batch | Item (the binding text is the 17 entry's) | Status |
|---|---|---|---|
| 1 | A1 | **17b P4** — the phone's comments sheet clears the typed draft before the write is attempted (a refused submit destroys her comment; the edit arm loses the target too) — `MobileCommentsSheetView.swift:105` / `MobileComments.swift` | open |
| 2 | A1 | **17b P5** — `promotePicks` copies an ARCHIVED pick as a block's ONLY take (I10 at birth; the copied text is not what the column showed) — `Operations+Versions.swift:674` | open |
| 3 | A1 | **17b P6** — `restoreNoteVersion` (and `deleteContainer`) replace/remove content without clearing the redo future (a redo resurrects a block from the abandoned timeline, or wedges the session's redo stack) — `Operations+NoteVersions.swift:187`, `UndoStack.swift` | open |
| 4 | A1 | **17b P7** — the boards' branch / ＋ new take / ⌘T doors copy the STORE past a dirty buffer where Write's twin flushes first (`branchTake`, `branchIntoColumn`, `blankIntoColumn`, `addWriteColumn`, `replaceColumnWithNewWrite`, `writeNewTakesEverywhere`, `WriteTakesPanel:238`) — verify against OverallModel §3's "branching inherits the current buffer" | open |
| 5 | A1 | **17b P14** — the phone quick note's `try?` folds a read failure into "There's nothing to save yet", orphans a created note, and lets the clock double-mint — `MobileQuickNote.swift:682` | open |
| 6 | A1 | **17b P36** — a failed re-read in `applyPendingIfClean` discards the deferred projection instead of restoring it (the two sibling guards restore) — `EditorViewModel.swift:803` | open |
| 7 | A1 | **17b row 65** — the quick-note pad's close/quit-while-refused road still loses the capture (KnownIssues row 65; #120(e) is the shipped refusal shape). The parking mechanism is a DESIGN FORK: the implementer proposes BEFORE building, the orchestrator rules, PROVISIONAL logged | open |
| 8 | A2 | **17l item 1** — the seeder's discover-then-mint latch + the `purged_row` consult in `SeededBookRestore.ensure` (KnownIssues row 38). Pins: concurrent open + launch seed ⇒ one book; a purged book + the tutorial door ⇒ none | open |
| 9 | A2 | **17l item 2** — the migration drill's escrow leg under a throwaway scope: the drill overrides the escrow pair for its scope; re-run under `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` (KnownIssues row 39). PLUS the read-only confirm from her Mac that the window migration removed the legacy escrow item (Keychain inventory READ — never a write) | open |
| 10 | A2 | **17l item 3** — her four ruled #90 wording changes, each a copy constant + its pin on both platforms: 54 *Pick Up New Keys* · 61/67 the conflict-follow Done's WHY · 46 the Castle-born-into-Standard consent direction (cancel · put the account in Castle · rejoin) · MINOR-6 the website's sign-in road named (13s re-voices all) | open |
| 11 | A2 | **17l item 4** — the dead Replace-All-Keys door from the main window: present `ProtectionController.activeSwitch` from the root (KnownIssues row 40). Pin: the door invoked with no Protection pane mounted ⇒ the ceremony presented (red today) | open |
| 12 | A2 | **17l item 6** — the ceremony's *(0 of 0)* renders *preparing…* until the first pulled window lands. Copy + a face pin | open |
| 13 | A2 | **17l item 7** — the #90-residue copy: NIT-N8's face is BUILT (pre-13x F3) — VERIFY it stands (pin re-run), and land MINOR-N4 (2)'s `.failed`-after-`regenerated` copy PROVISIONAL in the ruled ledger-61 sentence family (#90 item 11 is unruled — the orchestrator's scope ruling below; QUESTIONS row + her ratify list) | open |
| 14 | A2 | **17n** — the encryption passphrase's 12-character floor at every SETTING door (sync setup's first device · change passphrase · the migration's confirm where a new word is set · Replace All Keys' new-passphrase checkbox), one refusal sentence, NEVER at unlock; pins both platforms; the tutorial chapter's Lesson 2 + the book's Chapter 2 say the floor once (re-seed consequence recorded at close) | open |
| 15 | A2 | **The phrase-transit one-arm pin** (KnownIssues row 32, 17l's re-own): prove the store-only-phrase corner unreachable after pre-13x (3a · 3b · 4a), or fix the few lines. NOTE: this pin is a VERIFICATION — green-on-both-sides here is the row's own success criterion (record it as VERIFIED, not hollow), red means fix | open |
| 16 | A3 | **17m** — the Re-link-your-Apple-account door (Standard only): consent sentence naming the Apple account · the passphrase (a key act) · one proof-authorized re-land of the Apple-held copy via the F2 heal road's shape (`EncryptionSession.relandAppleHeldCopy(under:)` behind consent); refuses when `A` is unreadable (the waiting face). Pins as the entry writes them; the book's Chapter 2 / FAQ gain the door's sentence. Settings placement: the Protection pane (the entry's "Account & Encryption" predates the nine-pane split — PROVISIONAL, one move to change) | open |

**Orchestrator scope rulings at kickoff (recorded so no batch re-derives them):**
- **Row 7:** the runs file names the fix shape ("an unfiled-capture parking slot"); the MECHANISM
  (memory vs persisted; what a quit does; where plaintext prose may rest beside an encrypted store)
  is the design fork the implementer proposes and the orchestrator rules. Her text NEVER lands in
  plaintext on disk — the store is encrypted at rest by design, and a parking slot must not become
  the disclosure hole.
- **Row 13:** #90 item 11 awaits her, but the runs file (her confirmed grouping) includes "the
  NIT-N8/#90-residue copy" in A2, and the sentence's FAMILY is ruled (her ruling (3) on 61/67 —
  the Done says why the words aren't the account's). So MINOR-N4 (2)'s copy lands PROVISIONAL in
  that family with a QUESTIONS row; her ratify list carries it. #90 items 12–13 are NOT this run's
  (12 is done-unless-she-objects; 13's seeder-gate posture question is hers — only item 1's latch
  mechanics are ours).
- **Row 15:** the standing "a pin green on both sides = DISMISSED AS HOLLOW" rule applies to
  DEFECT claims; row 15 is a verification the KnownIssues row itself requests ("a ONE-ARM PIN
  proves it") — a green pin there is the deliverable.
- **Row 16:** live iCloud Keychain cannot be exercised by an agent; 17m's acceptance evidence is
  the DRILL kind — harness worlds through the runner/controller seams (the pre-13x
  `Phase13pControllerTests` pattern), plus a WalkKit walk of the door's face on the dev store as
  far as the dev store's posture allows, recorded honestly.

---

## ENVIRONMENT TRAPS (every batch brief carries this section verbatim — the skill's rule; adapted from 13u4's at the runs file's instruction)

- **Instance checks:** `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — **NEVER quit or
  kill one** (quit-by-bundle-identity is walker law since 13u3's breach); no Release builds or
  `/Applications` refreshes while one lives; the install refresh follows the closeout's walk, at a
  sanctioned zero-instance window (her app quit by HER, never by a session).
- **Builds/tests:** Mac tests run from `App/Variorum/`, suite-level `-only-testing` only; confirm
  the "Test run with N tests" line (Swift Testing COUNTS skipped tests — read the `skipped:` lines);
  `xcodebuild build-for-testing` compiles without the runner; **NEVER add a custom build
  configuration** (any configuration not named exactly "Debug" builds SPM dependencies RELEASE and
  silently strips VariorumCore's DEBUG-gated oracles); zsh `pipestatus` for pipeline exit codes.
- **Suites beside a live session flash the test host's windows** — prefer zero-instance windows for
  timing-sensitive measurements. The flake list (adjudicate by the paired interleaved protocol,
  never a single isolated run): the differential-latency pin · `CanvasDragTrackingTests` ·
  `BlocksWorkbenchFaceTests`' single-click · the row-49 landing arm (`BookOutlineLandingTests`'
  collapsed-story cell) · `ModeSwitchCarryTests`' top-of-Write arm. *(The read-click members are
  OFF the list — both closed at 13u4 F3, paired-verified.)*
- **The keychain drills are OPT-IN suites** (`TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` and kin) and
  run under throwaway `drill-<uuid>` scopes — never the real scope. The Mac suites write the
  DEV-STORE app's `UserDefaults.standard` (the row-42 class): scrub or use own suites where a test
  reads per-note keys.
- **Walks:** dev-store Debug build only (`io.lduarte.Variorum.debug`), `Tools/WalkKit/` + `cliclick`;
  **READ `Tools/WalkKit/README.md` WHOLE before any walk** — two 13u4 rigs paid for ignoring the
  walker facts. Screenshots in gitignored dirs (`notes/plans/run-a-screens/`). The Debug domain's
  `surfaceSize.*` keys may be wiped to stage cold runs (they regenerate) — NEVER the real store's.
  **Settings is NINE PANES with a leading search since 13u4 S1** (720×552 at (200,120); Protection
  and Data Safety are their own panes) — any older walk instruction naming the Appearance/Encryption
  tabs is stale. **⌘[ / ⌘] are OUTDENT/INDENT; back/forward is ⌥⌘[ / ⌥⌘]** (13u4 S1). The dev
  store's custody posture is whatever she left it in (it stood in Castle behind Touch ID at
  pre-13x's close, which no agent can pass) — check at walk time, record honestly, and carry
  custody evidence by drills + pins where the live road is gated.
- **Git:** never `git checkout` over uncommitted work; commit per piece and **PUSH after every
  commit** (CLAUDE.md's 2026-08-03 push rule). **No commit trailers** (her 2026-09-04 rule).
  **Stage PATHSPEC-LIMITED (`git add <your files>`), never `git add -A`** — the orchestrator edits
  shared records between your commits (the 13u4 standing rule).
- **Backups:** any act near the real store takes the A1 rail first (WAL-safe, UTC-named) — this run
  never touches it before the closeout refresh.

---

## CAST & DISCIPLINE

**Orchestrator: Fable — this session** (writes no feature code beyond adjudication/record acts).
**Implementer: `opus-implementer`, a FRESH session per batch, strictly sequential, one at a time,
ONE batch each** (A1 → A2 → A3). **Cold review: ONE `fable-reviewer` ladder over the run's COMBINED
diff** at the end (fresh reviewer per round; the CROSS-MODEL flow — findings to the implementer
side verbatim, the reviewer makes the final call on disputes and implements its confirmed findings'
fixes itself; cap three rounds; custody in the diff makes Fable mandatory, R-cor-14).

**PIN BEFORE FIX on every item** — the hallucination guard: trace the mechanism yourself; every
bug-class fix lands with a red-on-old pin verified by BEHAVIOURAL REVERT; a pin green on both sides
is DISMISSED AS HOLLOW and recorded (row 15's verification excepted, per its scope ruling). The
acceptance spine (`TutorialWalkTests`) rides every batch's closing run. PROVISIONALs log to
`notes/QUESTIONS.md` (next free number — check the file's end marker). Author-only calls are hard
stops. Drills are the custody evidence; walks on the dev-store Debug build only. Batches close only
on use-shaped evidence of their kind (the orchestrator verifies each batch — record spot-checks +
the walk/drill — before its record closes); the install refresh follows the closeout walk.

**Session resiliency (the checkpoint protocol — RESTATED IN EVERY BRIEF, per her 2026-09-06
ruling):** commit per coherent piece + push after every commit · the batch record's LIVE STATUS
section written at the START and flipped in the same commit as each piece, unverified claims marked
PENDING · synchronous foreground waits only, via the grep-poll loop (`grep -q '<EXIT LINE>' <log>
&& break; sleep 5` — never `tail -f | grep -m1`, never a backgrounded run you end your turn on) ·
never spawn subagents (ONE Sonnet lookup for external facts only, no repo reading delegated) · no
revert starts until the record names it and the pre-revert state is COMMITTED · every death and
resume noted in the record.

---

## BATCH A1 BRIEF — 17b, the text-loss doors (self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · FENCES · BINDING PRINCIPLES · THE LEDGER
rows 1–7 (incl. the kickoff scope ruling on row 7) · ENVIRONMENT TRAPS · CAST & DISCIPLINE;
(2) `notes/plans/phase-17-standing-fixes.md` § "17b — Doors that lose or mis-copy her text" WHOLE —
the six items' finder claims AND verifier traces are your mechanism briefs (you still re-trace each
yourself before fixing — the guard binds); (3) `notes/KnownIssuesAndTechDebt.md` row 65 (the pad)
and `notes/QUESTIONS.md` #120 (the pad's ruled grammar, esp. (e)); (4) OverallModel §3 (the
mutability rule + "branching inherits the current buffer" — P7's contract) and AppSpec §9's
structural-undo/REDO paragraphs (P6's contract); (5) the named code, in your own context.

**Scope: ledger rows 1–7. One batch, one consequence class — doors that lose or mis-copy her
text.** Mac and phone both. No `Sync/` lines (stop and report). No schema.

Per item: trace the mechanism yourself → red-on-old pin (behavioural-revert verified) → the
narrowest honest fix → the pin green. Item notes beyond the entry text:

- **P4 (row 1):** the fix class is #120(e)'s / the quick note's Q2 rule ("no refusal is ever
  reached by a road that discarded her text") — restore-on-refusal or clear-only-after-accept;
  match the pad's shipped pattern (13u3 UNIT C fixed the pad's FILE road the same way — read
  `MobileQuickNote`'s current shape first). The edit arm's `editingID` loss rides the same fix.
- **P5 (row 2):** the asymmetry is the fix's shape — `promotePicks` alone lacks the `.active`
  validation its siblings have (`adoptPicksPreservingChosen`, `effectiveLensSelection`). Decide
  fallback semantics from what the COLUMN actually showed (`resolvedTake` falls through to chosen)
  — the door's label ("only what this column shows") is the contract; a fix that copies what was
  shown satisfies it without product invention. I10 at birth must be impossible on every arm.
- **P6 (row 3):** the canonized contract is "any new structural act clears the redo future"
  (AppSpec §9). `restoreNoteVersion` and `deleteContainer` are content-replacing acts that register
  nothing — the spec-defensible fix is clearing the redo future (and the undo stack's coherence —
  check what the undo side does on the same road) at these acts. If you find yourself wanting to
  make either op REGISTER an entry instead, STOP — that is the 13j Trash-is-the-recovery-door
  product call (KnownIssues row 23's precedent), not this batch's. Pin both flavours: the silent
  resurrection AND the wedge.
- **P7 (row 4):** flush-first at every named door (the `mintCaretTake`/`runCopying` pattern —
  `AppSession` already owns the vocabulary). Close the CLASS: the entry names seven sites; sweep
  for others on the same bare-`runner.run`-mints-from-`working_text` shape and verdict each in a
  sweep table (FIXED or provably SAFE — the constitution's closing form).
- **P14 (row 5):** distinguish the read failure from the genuinely-empty result instead of folding
  them; on failure keep the mint's identity (`postID`) so the clock cannot double-mint and typing
  is not silently dropped. The A1-19 arm's ordering is the in-file precedent.
- **P36 (row 6):** the one-line restore, matching the two sibling guards. NIT-class — pin it
  cheaply (the marker restored on a thrown read), no drama.
- **Row 65 (row 7) — DESIGN FORK, the in-batch fork rule:** BEFORE building, write your proposed
  parking mechanism into this file's A1 record (options with tradeoffs: memory-only vs
  quit-surviving; where a quit-surviving capture may rest — NEVER plaintext prose on disk beside an
  encrypted store; what the next summon shows) and STOP for the orchestrator's ruling. Then build
  to it, PROVISIONAL, QUESTIONS row logged.

**Evidence to close:** every row's pin named in the record; the full targeted suites of every
touched surface green; `TutorialWalkTests` green; the phone: the mobile suite's relevant suites +
`generic/platform=iOS` build; a WalkKit walk of the pad road (row 7) and the board-branch road
(P7's user-visible half) on the dev-store Debug build, captured to `notes/plans/run-a-screens/a1/`.
The orchestrator walks/verifies before the record closes.

**CHECKPOINT PROTOCOL (restated — binding from your FIRST commit):** commit per coherent piece,
pathspec-limited (`git add <your files>`, never `-A`), PUSH after every commit, no trailers. Write
this file's `## BATCH A1 RECORD` LIVE STATUS section at the START (per-piece lines: DONE (hash) ·
IN-PROGRESS — exactly what remains · NOT-STARTED — the settled design), flip lines in the same
commit as each piece, mark every unverified claim PENDING. Records before final verification.
Synchronous foreground waits ONLY, by grep-poll (`grep -q '<EXIT LINE>' <log> && break; sleep 5`
in a loop, repeated past the Bash timeout) — never end your turn on a backgrounded run. Never spawn
subagents (one Sonnet lookup for external facts allowed; repo reading is never delegated). No
revert starts until the record names it and the pre-revert state is COMMITTED. Note every death and
resume in the record.

---

## BATCH A2 BRIEF — 17l items 1–4/6–7 + 17n + the phrase-transit pin (self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · FENCES · BINDING PRINCIPLES · THE LEDGER
rows 8–15 (incl. the kickoff scope rulings on rows 13 and 15) · ENVIRONMENT TRAPS · CAST &
DISCIPLINE · the BATCH A1 RECORD (what moved before you); (2) `notes/plans/phase-17-standing-fixes.md`
§ 17l (items 1–4, 6–7 — item 5 is FENCED, RUN B's) and § 17n; (3) `notes/QUESTIONS.md` #90 WHOLE
including HER RULINGS block — items 10–14's status is the ledger's row-13 scope ruling;
(4) `notes/KnownIssuesAndTechDebt.md` rows 32 (phrase-transit) · 38 (seeder latch) · 39 (drill
escrow leg) · 40 (dead door); (5) `notes/plans/pre-13x-postures-design.md` — §16, THE LADDER
section's rows for MINOR-N1 · MINOR-N3 · MINOR-N4 · NIT-N8 · MAJOR-3, and the F3 record's items
(NIT-N8's built face; MINOR-N4 (1)'s door refusal) — the mechanisms you verify against;
(6) `notes/plans/pre-13x-copy.md` (the copy file — where the constants live) if present, else the
copy constants' homes in `ProtectionCopy` / the phone's twins; (7) the named code.

**Scope: ledger rows 8–15.** Custody/keychain surfaces and copy. No `Sync/` lines — note
especially: item 5's `CorpusRotation.swift` is ADJACENT to your surfaces; if any fix you write
wants a line there or anywhere under `Sources/VariorumCore/Sync/`, STOP AND REPORT. No schema.

Item notes beyond the entry text:

- **Row 8 (seeder latch):** two pins as the entry writes them. The latch is per-book in-flight in
  `SampleLibrarySeeder`; the ensure's `purged_row` consult reads 13j's ledger — a READ of a synced
  table's local rows, not engine work; if the honest implementation wants engine lines, stop and
  report.
- **Row 9 (drill escrow leg):** fix the DRILL (override the escrow pair for the throwaway scope as
  it already overrides the plain-item leaves), then run under
  `TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1` and record the leg's expectation firing. The
  her-Mac confirmation is READ-ONLY: a `security`-CLI inventory listing proving the legacy escrow
  item absent — never a write or delete; record the command and its answer verbatim.
- **Row 10 (the four wording changes):** each is a copy constant + its pin on BOTH platforms
  (`ProtectionCopyTests` / `MobilePhoneProtectionCopyTests` are the pattern). Her rulings are the
  binding text (QUESTIONS #90's RULINGS block); 13s re-voices later — land her meaning plainly,
  don't over-write.
- **Row 11 (the root presenter):** the pin is the entry's — the door invoked with no Protection
  pane mounted ⇒ the ceremony presented (red today). Present from the root (`RootView` / the
  notice bar's host) so EVERY road presents; the Settings-pane presenter stays (two presenters,
  one pending model — make double-presentation impossible and pin that too).
- **Row 12 (the *(0 of 0)* face):** copy + face pin; *preparing…*-class wording until the first
  pulled window lands (the count exists but reads 0 of 0 — gate on the first window, not on zero).
- **Row 13 (#90 residue):** NIT-N8's face — re-run its pin
  (`ProtectionTierFaceTests.aWaitingDeviceHearsTheWaitingSentenceNotTheExposedNudge`) and verify
  the face still stands post-13u4's Settings restructure; MINOR-N4 (2)'s copy lands PROVISIONAL
  per the ledger's scope ruling (the ledger-61 family: the words shown are not the account's, and
  why), copy pin, QUESTIONS row for her ratify list.
- **Row 14 (17n, the floor):** the entry enumerates the four SETTING doors — enumerate them in a
  sweep table in your record (door × platform × pin), each FIXED or provably not-a-setting-door;
  one refusal sentence (a copy constant, both platforms); NEVER at unlock (pin the negative: an
  existing shorter word still opens). The tutorial Lesson 2 / book Chapter 2 sentence lands once;
  RECORD the re-seed consequence in your record (her one `Help ▸ Restore Tutorial…` press covers
  the 13u4 lesson edits AND this — the closeout bundles it).
- **Row 15 (phrase-transit):** the one-arm pin over `PhraseOffer.take`/`advanceToPhraseHalf` in a
  vault-enrolled-no-recovery-wrap world: after pre-13x's 3a/3b/4a the store-only mint should be
  unreachable. GREEN = the row's verification succeeds (record VERIFIED, remove/re-own the
  KnownIssues row at close); RED = the fix is the few lines the row prices, red-on-old then.

**Evidence to close:** custody kind — the drill (row 9's, run and quoted), the pins, both
platforms' copy pins; the targeted suites green; `TutorialWalkTests` green; iOS build green; a
WalkKit walk of the faces reachable on the dev store (the Protection pane's waiting face, the
root-presented ceremony door, the *(0 of 0)* → *preparing…* face where stageable), captured to
`notes/plans/run-a-screens/a2/`, with the dev store's custody posture recorded honestly (a
Touch-ID-gated road no agent can pass is carried by its drill + pins — say so rather than fake it).

**CHECKPOINT PROTOCOL (restated — binding from your FIRST commit):** commit per coherent piece,
pathspec-limited, PUSH after every commit, no trailers. Write `## BATCH A2 RECORD`'s LIVE STATUS at
the START and flip per piece; PENDING for unverified claims. Foreground grep-poll waits only; never
end a turn on a backgrounded run. Never spawn subagents (one Sonnet lookup for external facts
allowed). No revert without the record naming it and a COMMITTED pre-revert state. Note deaths and
resumes.

---

## BATCH A3 BRIEF — 17m, the Re-link-your-Apple-account door (self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · FENCES · BINDING PRINCIPLES · THE LEDGER
row 16 (incl. its scope ruling) · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the A1/A2 RECORDs;
(2) `notes/plans/phase-17-standing-fixes.md` § 17m — the entry text IS the spec;
(3) `notes/QUESTIONS.md` #90 item (10) + its ruling context; (4) `notes/plans/pre-13x-postures-design.md`
— the MAJOR-3-as-REFINED record (the heal's shape: `healAppleHeldCopy` →
`EncryptionSession.relandAppleHeldCopy(under:)`, `leaveCastle`'s shape — M from custody,
`settingAppleHeldCopy`, the CAS on the fetched revision, the proof), MINOR-N1's row, §3.3's custody
model, §5 THE DOORS (the authorization grammar a new door must speak); (5) the named code
(`ProtectionController`, `PostureSwitchRunner`/`Model`, `EncryptionSession`, `ProtectionCopy`).

**Scope: ledger row 16 alone.** ONE door, built from EXISTING machinery behind consent — the entry
is explicit: the `relandAppleHeldCopy` road F2 built for the heal, the same shape, behind a consent
sentence + the passphrase (a key act). No new custody semantics; no `Sync/` lines (the road's
existing engine seams are consumed, not edited — if the door wants an engine change, STOP AND
REPORT); no schema.

Item notes:

- **Placement:** Settings ▸ Protection pane, Standard only (the entry's "Account & Encryption"
  wording predates 13u4's nine-pane split — PROVISIONAL, recorded on the ledger; one move if she
  wants it elsewhere). The door renders only in Standard (a Castle account has no Apple-held copy
  owed — the door is not rendered, P-2's letter: a door that can never act isn't rendered).
- **The consent sentence** names WHICH Apple account will hold the key from now on (copy constant;
  13s re-voices; PROVISIONAL wording in the family of pre-13x copy §2's consent grammar). The
  passphrase is the key act (the ceremony's existing passphrase step pattern). Refuses when `A` is
  unreadable HERE with the waiting face's sentence (NIT-N8's vocabulary — reuse, don't mint a
  sibling).
- **Pins, as the entry writes them:** (i) the orphaned state → the door → a new device enrolls
  with nothing typed; (ii) a different-Apple-ID device's door names ITS account in the sentence;
  plus (iii) the refusal arm (A unreadable ⇒ the waiting face, nothing written, the vault's
  revision unchanged — MINOR-N4 (1)'s door-refusal pattern: refuse BEFORE any screen). Harness
  worlds through the controller/runner seams (the `Phase13pControllerTests` pattern) — live iCloud
  is not exercisable by an agent; say so in the record.
- **The book's Chapter 2 / the FAQ gain the door's sentence** — content edits join the one re-seed
  consequence (record it; the closeout bundles her single press).

**Evidence to close:** custody kind — the pins above (red-on-old where a defect arm exists; the
door is NEW capability, so its pins are its state-transition suite — assert refusals, the vault
write's CAS + proof, and the no-write arms exactly); targeted suites + `TutorialWalkTests` green;
iOS build green (the phone gains no door this run — 17m's entry names Settings, Mac-first; if you
find the phone owes a twin NOW, record it as a question rather than building it); a WalkKit walk
of the door's face on the dev store as its posture allows, captured to
`notes/plans/run-a-screens/a3/`.

**CHECKPOINT PROTOCOL (restated — binding from your FIRST commit):** commit per coherent piece,
pathspec-limited, PUSH after every commit, no trailers. Write `## BATCH A3 RECORD`'s LIVE STATUS at
the START and flip per piece; PENDING for unverified claims. Foreground grep-poll waits only; never
end a turn on a backgrounded run. Never spawn subagents (one Sonnet lookup for external facts
allowed). No revert without the record naming it and a COMMITTED pre-revert state. Note deaths and
resumes.

---

## THE LADDER (ONE Fable ladder over the run's combined diff; opens after A3's record closes)

Fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing from the
orchestrator (the isolation is the point). Cross-model flow: findings to the implementer side
verbatim → agree/dispute with rationale → back to the REVIEWER for the final call; the reviewer
implements its confirmed findings' fixes in its own session; after its fix pass the suite must be
green and the implementer side gets one sanity pass over the reviewer's diff. Round 2 re-reviews;
a NEW BLOCKER/MAJOR earns round 3; hard cap three rounds — anything open after round 3 is recorded
for the author, never looped. Every finding gets a written disposition here.

*(Rounds recorded here as they run.)*

---

## CLOSEOUT DUTIES (the standing ritual, run-shaped — nothing here runs until the ladder ends)

1. Every ledger row dispositioned (FIXED-with-named-pin / DISMISSED-AS-HOLLOW / VERIFIED (row 15's
   class) / DEFERRED-with-owner); no orphans.
2. Each entry's dispositions COPIED into `notes/plans/phase-17-standing-fixes.md`; 17b · 17l
   (with item 5 explicitly re-owned to RUN B) · 17n · 17m CLOSED there; the allocation register
   updated (17l/17m/17n rows added/flipped — the register never listed them).
3. KnownIssues rows resolved or re-owned: 32 (phrase-transit) · 38 · 39 · 40 · 65; row 41 (the
   double-ask) stays, RE-AFFIRMED to RUN B (17l item 5).
4. The orchestrator's closing walk (the batches' acceptance, hands-on where the store's posture
   allows), THEN the full closing runs (core · full Mac · iOS build · mobile), THEN the install
   refresh behind the A1 backup rail at a zero-instance window (her app quit by HER).
5. The master plan's active-order line: RUN A's row 2 ticked ✔.
6. Canon deltas exactly as ruled, no further (copy constants are not canon; QUESTIONS rows for
   every PROVISIONAL; the re-seed consequence bundled into her checklist — one
   `Help ▸ Restore Tutorial… ▸ Replace` press covers 13u4's pending edits + this run's).
7. The checkpoint report to the author with her ratify list (the PROVISIONALs; #90 item 11's
   sentence; row 7's parking mechanism; 17m's pane placement; anything the ladder left open).
8. Memory (`variorum-phase-9-run-state`) refreshed. Hard stop — RUN B is a fresh invocation at
   her word.
