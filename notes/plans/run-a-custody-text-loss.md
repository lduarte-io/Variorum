# RUN A — custody & the text-loss doors (17b + 17l items 1–4/6–7 + 17n + 17m)

**STATUS: OPEN — kicked off 2026-09-21 at the author's word (the `/architect-phase` invocation carrying
`notes/plans/pre-beta-standing-fix-runs.md`'s paste-ready kickoff). BATCH A1 CLOSED (orchestrator-verified,
adjudication at the record's end). Batch A2 next.**

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

## BATCH A1 RECORD — 17b, the text-loss doors

**WHAT I DID NOT DO (this record's first line, per the standing rule):** **ROW 7 IS NOW BUILT to the
orchestrator's ruling** (Option 1 + the 1b rider, PROVISIONAL, QUESTIONS #137) — what remains undone
there is named at its own record below: the park is MEMORY-ONLY by ruling, so a crash or a forced
second ⌘Q still loses a refused capture, and the close road's new sentence deliberately carries no
reason. The REFUSAL road could not be walked on a healthy dev store and is carried by its pins, as
binding 7 allows. Beyond that: no `Sources/VariorumCore/Sync/` line, no
schema change, no migration (the marker stays 8), nothing touched in `/Applications` or her real
store, no author-only call taken. Row 3's UNDO-side residue was measured and pinned as documented
behaviour rather than fixed (the reason and its owner are below), and neither `restoreNoteVersion`
nor `deleteContainer` was made to REGISTER an undo entry (the brief's stop rule — that is 13j's
product call). No item was dismissed as hollow: all six rows reproduced on the pre-fix tree.

**Session opened 2026-09-21.** Implementer: `opus-implementer` (fresh session, batch A1 only).
Read before any code, in the brief's order: the run file's Status banner · FENCES · BINDING
PRINCIPLES · LEDGER rows 1–7 + the kickoff scope rulings · ENVIRONMENT TRAPS · CAST & DISCIPLINE ·
the A1 brief; `notes/plans/phase-17-standing-fixes.md` § 17b whole (all six items' finder claims +
verifier traces); `notes/KnownIssuesAndTechDebt.md` row 65; `notes/QUESTIONS.md` #120 (esp. (e));
OverallModel §3 and AppSpec §9's structural-undo/REDO paragraphs (auto-loaded canon).

### LIVE STATUS (flipped in the same commit as each piece; unverified claims marked PENDING)

| Row | Item | Status |
|---|---|---|
| 0 | Record skeleton + `run-a-screens/` gitignored | **DONE** — this commit |
| 7 | **row 65** — the pad's close/quit-while-refused loss | **FIXED to the ruling** — Option 1 + the 1b rider, both PROVISIONAL (QUESTIONS #137). Pin `QuickNoteParkTests` (4); revert check follows |
| 1 | **P4** — the phone's comments sheet clears the draft before the write | **FIXED** — pin `MobileCommentDraftTests` (3), the door driven for real on a mounted sheet in a key window; behavioural revert verified after the commit (the field read `""` against her typed paragraph, nothing landed, and `editingID` went nil) |
| 2 | **P5** — `promotePicks` copies an ARCHIVED pick as a block's only take | **FIXED** — pin `PromotePicksArchivedPickTests` (3), red-on-old measured on the pre-fix tree (4 issues; the guard arm green) |
| 3 | **P6** — `restoreNoteVersion`/`deleteContainer` leave the redo future uncleared | **FIXED** — pin `ContentReplacementRedoTests` (5), red-on-old measured (3 defect arms red, 2 guards green); ONE residue pinned as documented behaviour (the undo side) and recorded below |
| 4 | **P7** — the boards' branch/＋new take/⌘T doors copy the STORE past a dirty buffer | **FIXED** — pin `BranchDoorFlushTests` (7), red-on-old measured on the pre-fix tree (6 defect arms red with the stale row in hand, the blank-take guard green); ONE arm's revert re-verified after the commit (below) |
| 5 | **P14** — the phone quick note's `try?` folds a read failure into "nothing to save yet" | **FIXED** — pin `MobileQuickNoteReadFailureTests` (3); behavioural revert verified after the commit — **the double-mint reproduced live (`count → 2`)**, with `"There's nothing to save yet."` spoken over a note in SQLite |
| 6 | **P36** — `applyPendingIfClean` discards the deferred projection on a thrown re-read | **FIXED** — pin `DeferredProjectionRetryTests` (2); behavioural revert verified AFTER the commit (`else { return }` put back ⇒ the marker arm red, the guard green) |
| — | Closing evidence | **DONE** — core **1639/177 green** · full Mac **3059/507 ALL GREEN, zero issues** (re-run with row 7 in; tutorial spine green inside it) · mobile **632/108 PASSED with exactly the 4 known issues** · iOS **BUILD SUCCEEDED** · the walk captured (7 shots) |

**Deaths and resumes:** none yet.

### ROW 3 (17b P6) — THE RESIDUE I DID NOT FIX, and why

The fix clears the redo FUTURE at `restoreNoteVersion` and `deleteContainer` (`UndoStack.clearRedoFuture()`,
called after the write so a refusal changes nothing). **The UNDO side has the same shape and is left
standing, measured and pinned as documented behaviour**
(`ContentReplacementRedoTests.anUndoEntryOlderThanARestoreCanStillReviveIntoTheRestoredNote`): an entry
registered BEFORE the act can still revive a block from the replaced timeline into the restored note
(measured: 2 blocks → 3), or refuse on a take the act tombstoned (the standing failed-inverse
behaviour — visible and retryable, not silent).

**Why not clear both stacks:** the stack is SESSION-WIDE and holds acts on every note, so restoring one
note would silently take her undo history for all the others — a bigger loss than the one it prevents,
and canon asks only for the future (`AppSpec` §9). A guard pin asserts the undo history is untouched.
The real answer is note-scoped entries, which is a design (entries are opaque closures today), not a
line — and I did NOT make either op register an entry, per the brief's stop rule (that is 13j's
Trash-is-the-recovery-door product call).

**DEFERRED with an owner: 17e** (correctness & honesty singles — a standing entry; the product half,
whether structural undo should be note-scoped at all, is the author's). A KnownIssues row lands at the
batch's close with that owner, and the call is on her ratify list (QUESTIONS #136).

**Two pre-existing pins were rewritten, both the ruled-change class, neither a defect:**
`RedoStackTests.anObsoleteRedoPopsQuietlyInsteadOfWedgingTheStack` and
`SmartConversionTests.aRedoWhoseMemberPostDiedLeavesThatMembershipDead` both STAGED their state by
pressing `deleteContainer` between an undo and a redo — the exact behaviour this row calls a defect
(one of them asserted it in words: *"an unregistered op leaves the redo future alone"*). Each keeps its
own subject and moves its vehicle to a tombstone arriving BELOW the operations layer — a sync apply's
shape, which registers nothing and clears nothing, and is the road that can still produce the state.

### ROW 4 (17b P7) — THE SWEEP TABLE (the constitution's closing form)

Every door in the tree that mints from STORED take text, verdicted. The rule the table applies: a
door that READS stored text to mint from it is a member of the copy family and rides
`AppSession.runCopying`; a door that mints EMPTY is not, because no stale row can spoil it and her
pending keystrokes still land on the take she typed them into.

| Door | Site | Reads stored text? | Verdict |
|---|---|---|---|
| `branchTake` (＋ new take, ⌘T, the block ▾ menu, the card menu, `WriteTakesPanel`'s growth door) | `TakesViewModel:1327` | yes — `branchVariant` copies the row | **FIXED** (`runCopying`) |
| `branchTakeRevealed` → takes arm | `TakesViewModel:2390` | via `branchTake` | **FIXED** (by the above) |
| `branchIntoColumn` (Lenses' diverge-here) | `TakesViewModel:1051` | yes | **FIXED** |
| `addWriteColumn` (+ Column → write new takes) | `TakesViewModel:864` | yes — `branchAllFans` mints from the shown take's row | **FIXED** |
| `replaceColumnWithNewWrite` | `TakesViewModel:914` | yes | **FIXED** |
| `writeNewTakesEverywhere` (the Takes tab's door) | `TakesViewModel:1249` | yes | **FIXED** |
| `newBlankTake` / `blankIntoColumn` / `newBlankTakeRevealed` | `TakesViewModel:1343`, `:1080` | **no** — `newBlankVariant` mints `''` | SAFE, and pinned as such (`aBlankTakeMintsEmptyAndLeavesThePendingTextOnItsOwnTake`) |
| `newBlankTakeAsChosen` (⇧⌥⌘T) | `TakesViewModel:2239` | no — blank; `chooseVariant` moves a pointer, and a pending flush still lands on the take she typed in | SAFE |
| `EditorViewModel.mintCaretTake` (Write's ⌘T twin) | `EditorViewModel:3337` | yes — and it has ALWAYS awaited `flushNow()` first | SAFE (the pattern the fix adopts) |
| `duplicateAsVersion` · `promoteLens` · `promotePicks` · `poolDragCopy` · `divergePostForReading` | various | yes | SAFE — already the 13e E10 family |
| `saveNoteVersion` / `restoreNoteVersion` (⌘⇧S and the Versions door) | `VersionActs` | yes — a full family copy | SAFE — the composition flushes (*"a moment missing the keystroke that summoned it is not the moment she asked for"*) |
| `MobileTakesBrowser.branchDisplayed` (the phone) | `MobileTakesBrowser:367` | yes | SAFE — flushed at the mobile Stage-2 ladder, for this exact mechanism |
| `MobileTakesBrowser` blank door | `:389` | no | SAFE |
| `TutorialSeeder` / `MobileTutorialSeeder` / `MobilePerfFixtureSeeder` | various | yes, but from rows they just wrote | SAFE — no surface, no buffer |

The family's ONE entry (`AppSession.runCopying`) carries the widened rule in its doc, including where
the line sits and why it is not "flush before every ops call" (that reason was already written there;
what is new is that a BRANCH is a copy).

**RED-ON-OLD, both ways.** On the pre-fix tree all six defect arms were red with the stale row in hand
(`mintedText → "Alpha beta."` where the pane held `"Alpha beta. NEW"`), the blank-take guard green.
One arm's first red was confounded (the `addWriteColumn` pin loaded a COLUMN MEMORY another test had
saved into `UserDefaults.standard` — the row-42 class; the pins now take their own suite), so after
the fix was COMMITTED (`2e464abe`) the three `branchAllFans` doors were reverted behaviourally in the
working tree and re-run: exactly those three tests red, both takes in the fan holding the stale row,
the other four green — discriminating. Restored with `git checkout --`; tree clean.

### THE CLOSING RUNS — what the first full Mac run found (and one of the two was MINE)

**Full Mac suite, run 1: 3054 tests in 506 suites, 4 issues across 2 tests.** Both adjudicated at
their mechanism, neither a defect in this batch's fixes:

1. **`TakeToBlockDoorTests.aBoardDoorThatCouldNotActStillSpeaksUnderEverySetting` — MY OWN RESIDUE,
   the row-42 class, recorded rather than quietly cleaned.** The pin drives Adopt on the column that
   IS the note and expects a refusal; it got the ADOPT RECEIPT, because `columns.first` was not the
   main column. `withTakesWorld` builds its `TakesViewModel` on `UserDefaults.standard` (the dev-store
   Debug domain) under the deterministic post id `00000000-…-000000000000`, and **my own P7 pins, in
   the runs BEFORE I isolated their defaults, had called `addWriteColumn`/`replaceColumnWithNewWrite`
   — whose `saveMemory()` wrote four scratch columns ("Lens 1", "Lens 2", "Lens 4", picks on
   `…-0001`) into that shared key.** Verified as test residue by reading the value (deterministic
   block/variant ids throughout, auto-generated column names), then deleted:
   `defaults delete io.lduarte.Variorum.debug "takesViewMemory.00000000-0000-0000-0000-000000000000"`
   — that one key only; the two real-UUID entries beside it are the dev store's own and were left
   alone. **Re-run after the scrub: `TakeToBlockDoorTests` GREEN.** The pins themselves have taken
   their own `UserDefaults` suite since the P7 commit, so the class cannot recur from this batch.
2. **`BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded`** — the
   **row-49 landing arm**, named on this run's own ENVIRONMENT TRAPS flake list. `abs(top) = 3424`
   under full-suite load; **green in the isolated re-run** (8/8, then 17/2 with its neighbour). This
   batch's diff holds zero lines in any book, outline, landing or manifest file — the touched files
   are the operations layer, `UndoStack`, `TakesViewModel`, `EditorViewModel`, `AppSession`'s doc, and
   the two phone surfaces.

### ROW 7 — THE BUILD (to the ruling; PROVISIONAL, QUESTIONS #137)

**What landed, binding by binding.**

- **The park** — `QuickNotePark`, a session-scoped `@Observable` on `AppSession` beside
  `quitFinalize` (`App/Variorum/Shared/AppSession.swift`, inside the existing macOS fence), holding
  `text` + `titleFromFirstWords` + the refusal's sentence. Memory-only by the ruling; its doc carries
  the reason a disk-backed park would refuse in exactly the case it exists for.
- **Binding 1 (refused captures only)** — `QuickNotePad.take()` parks in its `.refused` arm and
  nowhere else, from `submitted` rather than `text` (keystrokes landing during the mint are not part
  of what was refused — the discipline `submitted` already carried). Guard pin (iv) + the walk.
- **Binding 2 (clear at restore)** — `QuickNotePark.restore()` returns the held capture and clears in
  the same breath (`defer { clear() }`); `.filed` and `.nothingToFile` clear it too, so a landed
  capture can never come back as a ghost. Pinned both ways.
- **Binding 3 (both sentences)** — the restored pad shows `QuickNoteCopy.restoredCapture` in its own
  (accent, non-alarm) register with `lineLimit` beside `fixedSize` for the P-8 b6dae25 class; the
  close road now speaks `QuickNoteCopy.parkedOnClose` instead of `refusal(for:)`, whose
  *"Your text is still here"* was **false** the moment that window went. The new line deliberately
  carries no REASON — stated at the code and in #137(e) — because she is not looking at the pad on
  that road and the reason is actionable only where the retry is.
- **Binding 4 (the 1b rider)** — `declineQuitOnce()` on the park; consumed by the delegate's
  `declineQuitIfACaptureStands()`, which `applicationShouldTerminate` consults on **both** of its
  roads. The early `.terminateNow` path had to consult it too: a refusal can stand with the pad
  CLOSED, whose quit closure went with the window, so that road would otherwise have quit straight
  past the one case the park exists for. The decision runs AFTER `finalizeAll()`, because the pad's
  own quit closure is what ARMS the park. With no pad on screen the status seam carries the same
  sentence (a quit that quietly refuses to quit is its own defect); with the pad up it is already
  speaking its refusal line, so nothing is said twice.

**Pins — `QuickNoteParkTests` (5), the ruling's four with (iii) split in two.**

| Pin | What it holds | Red-on-old |
|---|---|---|
| (i) `aRefusedCaptureComesBackAtTheNextSummon` | refused → closed → a FRESH pad restores her words, her name decision and the line saying why | **RED** — `next.text → ""` against the capture; no restored line |
| (ii) `filingOrEmptyingClearsThePark` | `.filed` / `.nothingToFile` clear it | **RED** — nothing was ever held |
| (iii) `aRefusedCaptureAtQuitDeclinesOnceAndThenProceeds` | the one-shot: declined once, the second consecutive ⌘Q proceeds, a re-arisen refusal re-arms | **RED** — nothing held, the decline never fires |
| (iii-b) `theQuitDoorsOwnDecisionDeclinesOnceAndSpeaks` | the DELEGATE's decision on both arms, and that it speaks only when no pad is on screen | (same mechanism) |
| (iv) `aCloseWithNothingRefusedKeepsNothing` | **the guard** — her ruled abandon grammar untouched | **GREEN on both sides, by design** |

**The behavioural revert** (run after the build was COMMITTED at `3cd6d2cf`): the `park(...)` call
removed from `take()`'s `.refused` arm ⇒ **8 issues across pins (i), (ii) and (iii), with (iv)
green** — discriminating in exactly the direction binding 1 asks for. Restored with
`git checkout --`; tree clean.

**`applicationShouldTerminate` is deliberately NOT driven by a pin:** that would mean calling
`reply(toApplicationShouldTerminate:)` on the real `NSApp` inside the test host. The decision it
consults is what the pin drives, which is why `declineQuitIfACaptureStands()` is internal rather
than private (the same "a fact that is checkable" move as row 6's `hasDeferredProjection`).

### CLOSING EVIDENCE (all runs on the final tree)

| Gate | Command | Result |
|---|---|---|
| Core | `swift test` | **1639 tests in 177 suites — ALL GREEN** (baseline 1631/175; +8/+2 = this batch's two core suites) |
| Full Mac | `xcodebuild test -scheme Variorum -destination platform=macOS` | **3059 tests in 507 suites — ALL GREEN, ZERO ISSUES** (baseline 3045/504; +14/+3 = `BranchDoorFlushTests` 7 + `DeferredProjectionRetryTests` 2 + `QuickNoteParkTests` 5). The rows-1–6 run read 3054/506, likewise all green. |
| The acceptance spine | inside the full run | `Tutorial book shape` · `Tutorial doors` · `Tutorial acts — writing` all **passed** |
| Mobile | `xcodebuild test -scheme VariorumMobile -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` | **632 tests in 108 suites PASSED with exactly the 4 known issues** (baseline 626/106, same 4; +6/+2 = this batch's two mobile suites) |
| iOS build | `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` | **BUILD SUCCEEDED** |

**THE WALK — dev-store Debug build (`io.lduarte.Variorum.debug`, built at `DerivedData/a1walk`), the
store unlocked, Terminal voice.** Captures in `notes/plans/run-a-screens/a1/` (gitignored):

1. `01-takes-board-before-branch.png` — a note staged through the shelf's quick-entry bar, opened in
   Takes (⌘2): one block, one take, the pane live.
2. `02-branch-carries-pending-keystrokes.png` — **P7's acceptance, by hand.** Typed
   `" LATE WORDS"` into the live pane and pressed **⌘T in the same `osascript` burst** (inside the
   500 ms debounce). The board came back with **two takes**, and the MINTED one reads
   *"The branch road: first sentence. LATE WORDS"* — it carries the keystrokes that were still in
   the buffer. On the pre-fix code that card would have read *"The branch road: first sentence."*
   and the ring would have moved onto it.
3. `03-pad-holding-an-unfiled-capture.png` — **the row-7 surface, photographed.** The quick-note pad
   (⌘⇧N) holding a typed capture that exists NOWHERE else: `340×260` floating window, captured by
   its AX frame (`screencapture -R`) because `walk-cap`'s layer-0 filter cannot see it (the 13u3
   UNIT C walker fact). This is the state the parking proposal is about.
4. `04-pad-filed-the-capture.png` — ⏎ filed it: the pad is gone, the bottom bar speaks the quiet
   receipt *"Filed in Quicknotes — tagged #quicknote."*, and the branch from (2) still stands (∨2).
5. `05-pad-typed-before-close.png` · `06-close-filed-it-nothing-parked.png` ·
   `07-next-summon-is-a-fresh-pad.png` — **row 7's binding-1 GUARD, walked on the rebuilt app**: a
   capture typed into the pad, then ⌘W with a healthy store. The close FILED it (the shelf's
   Quicknotes row moved 89w → 103w across the two filings) and the next ⌘⇧N came up EMPTY — no
   restored line, "File It" grey. Her ruled grammar (*closing files it*; a summon she abandons
   keeps nothing) is untouched by the park, on the real surface.

**What the walk could NOT stage, said rather than faked:** the pad's REFUSAL road needs the store to
refuse `importPost`, which on a healthy unlocked dev store cannot be provoked without breaking the
store under a live app — so the refusal-then-close loss (row 7) is carried by its trace and by the
pins on the same class, not by a photograph. The phone's two rows were driven at their real doors in
the simulator instead (the comments sheet's own submit button, on a mounted sheet in a key window).

**Instance discipline:** `pgrep -fl 'Variorum.app/Contents/MacOS'` empty before the launch, one PID
(mine, at the `a1walk` path) during, empty after — quit by identity
(`tell application id "io.lduarte.Variorum.debug" to quit`), never a keystroke, never hers.
`/Applications/Variorum.app` untouched throughout.

### ROW 7 (KnownIssues 65) — THE TRACE, AND THE PARKING MECHANISM PROPOSED (the design fork; NOT built)

**The mechanism, traced in the code itself (`App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift`).**
`QuickNotePad` is `@State` inside `QuickNoteView`, and `pad.text` is **the only place her capture
exists** until a note holds it (the file's own header says so: *"a summon she abandons keeps nothing,
and re-summoning gives a fresh pad rather than the last note"*; the scene is a SINGLETON `Window`,
`VariorumApp.swift:331`, so a close tears the view and its `@State` down and the next summon
re-runs `init`). 13u3 UNIT C made a refusal KEEP the text (`take()`'s `.refused` arm sets
`lastError` and leaves `text` alone, :181-182) — which is exactly right on the ⏎/⌘⏎ road, where the
pad stays open. **Two roads have no pad left afterwards:**

1. **CLOSE** — `.onDisappear` (:321-335) unregisters the quit token and spawns
   `Task { if case .refused(let message) = await pad.close() { status.refuse(message) } }`.
   `close()` → `take()` → the store refuses → `text` is faithfully preserved **on an object whose
   last strong reference is that task**, which returns and releases it. The words are unreachable
   from anywhere in the app. Worse, the sentence the status seam then speaks is
   `QuickNoteCopy.refusal(for:)` — *"Your text is still here — try again in a moment."* — which on
   THIS road is **false**: there is no "here" left. (That sentence is the pad's own, correct where
   it was written and reused where its premise does not hold.)
2. **QUIT** — `.onAppear` registers `finalizeAtQuit` with `QuitFinalizeRegistry`
   (`AppSession.swift:597-621`), whose `finalizeAll()` is `for flush in entries.values { await flush() }`
   — the `@discardableResult` outcome is **discarded outright**, and
   `VariorumAppDelegate.applicationShouldTerminate` replies `true` unconditionally after it
   (`VariorumAppDelegate.swift:80-88`). A refusal at quit is not even observable; the process exits
   with her words in a released object.

Both roads are reachable exactly as #120(e) says the refusal is reachable (a mid-round failure, the
store unreachable, a 13p re-lock closing the pool). **Nothing in the tree parks a capture today** —
grep for "unfiled"/"held capture" finds only the book-chapter vocabulary.

**THE FORK — where a refused capture may live. Three options, then the recommendation.**

**Option 1 — MEMORY-ONLY PARKING, restored at the next summon (RECOMMENDED).** A tiny
session-scoped holder (`@MainActor @Observable`, owned by `AppSession` beside `quitFinalize`, Mac-only
like it) keeps the refused capture: her text, the name decision (`titleFromFirstWords`), and the
refusal sentence. `take()`'s `.refused` arm parks; `.filed` and `.nothingToFile` clear it, so a
successful retry can never leave a ghost. `QuickNoteView` restores it into the fresh pad at summon
and says why the box is not empty.
*What a quit does:* nothing survives the process — the loss window shrinks from "any close or quit
after a refusal" to "a quit or a crash while a refusal is standing".
*Disclosure:* **zero new at-rest surface.** Her prose never leaves RAM, nothing is written beside the
encrypted store, no key is needed — which matters because the commonest cause of the refusal (a
locked or unreachable store) is exactly the state in which no key is available to seal anything.
*What the next summon shows:* her words back in the box, the caret in them, and one line saying the
last capture was not filed and is still here. **It also makes the existing sentence true** — the
close road's *"Your text is still here"* stops being a lie, because it is.
*Cost, stated honestly:* a force-quit, a crash, or a ⌘Q while the refusal stands still loses it —
bounded by one summon, which is the pad's stated cost model already.

**Option 1b — the RIDER on the quit road (PROVISIONAL, product-flavoured, the orchestrator's call).**
When `finalizeAtQuit` refuses and words remain, `applicationShouldTerminate` declines the
termination **once**, leaving the pad on screen with its refusal line (at ⌘Q the pad window is still
up — windows close after termination is approved), and a second ⌘Q proceeds so she can never be
trapped by a store that will not take it. This is macOS's ordinary unsaved-work grammar, and it is
the only shape that saves the capture at quit WITHOUT writing prose to disk.
*Against:* a quit that does not quit is a surprise, and it is product behaviour the app does not
have anywhere else today.

**Option 2 — QUIT-SURVIVING, SEALED ON DISK.** Park the capture as a file in Application Support,
AES-256-GCM under the existing key custody, deleted the moment it files.
*Why I do not recommend it:* the refusal's commonest cause is the store being locked/unreachable,
and that is **the same condition that makes the key unavailable** — so the park would refuse in
precisely the case it exists for, covering only the "healthy key, failed round" arm. It also opens a
SECOND at-rest home for her prose, which is a disclosure-envelope decision (14b's classification
list), needs its own stale-blob lifecycle, and an unsealed fallback is forbidden by the run's own
fence. Plaintext parking (UserDefaults/a plist) is ruled out outright by that fence.

**Option 3 — MINT EARLY (the phone's model).** Arm a clock on the first keystroke and mint a real
note, as `MobileQuickNote` does, so the text is durable from the first second.
*Why I do not recommend it:* it changes what the pad IS. Her ruled grammar is ONE SUMMON = ONE NOTE
and *"a summon she abandons keeps nothing"* (round-14.2, restated in #120(a)/(d)); early minting
creates notes she abandoned and needs a withdrawal road (which is itself KnownIssues row 23's open
product question on the phone). That is a product change, not a fix for row 65.

**RECOMMENDATION: Option 1, with Option 1b offered as its rider.** Option 1 alone closes the road
row 65 actually names (a refusal then a close) with no new at-rest surface and no product invention
beyond "the pad gives back what it could not file"; 1b is the only honest answer to the quit half and
is the part that wants her ruling. Both land PROVISIONAL with a QUESTIONS row (next free **#136**).

**STATUS: awaiting the orchestrator's ruling. Rows 1–6 continue meanwhile; nothing of row 7 is
built.**

### ROW 7 — THE ORCHESTRATOR'S RULING (2026-09-21, recorded repo-first before the build)

**Build Option 1 WITH the 1b rider. Both PROVISIONAL, one QUESTIONS row (#137).** The reasoning,
so the ratify list carries it whole: Option 1 closes the close road with zero new at-rest surface
and makes the shipped sentence true; Option 2 is rejected on the implementer's own trace (the
refusal's commonest cause is the state in which no key can seal the park — a mechanism that fails
exactly when needed, plus a new disclosure-envelope surface, is not a fix); Option 3 is rejected
as a product change to the pad's ruled grammar (round-14.2, #120(a)/(d)). The 1b rider is taken
because row 65's title names BOTH roads — close AND quit — and 1b is the only shape that answers
the quit half without prose on disk; it is macOS's ordinary unsaved-work grammar, and the
second-⌘Q-always-proceeds arm keeps her un-trapped. The class rule outranks the surprise
("nothing typed in either app can be permanently lost" — AppSpec §9's own doctrine).

**Bindings on the build (the edges decided now, not discovered):**
1. **The park holds REFUSED captures only.** The deliberate-abandon grammar is untouched: a close
   with no refusal standing keeps nothing, exactly as ruled — and a GUARD PIN asserts that, so the
   park can never silently widen into a general draft-keeper.
2. **Restore makes the pad the only home again** — the park clears at restore, no ghost copy, no
   double-restore; a re-refusal re-parks. After restore, abandoning the pad is her ruled abandon.
3. **The restored pad says why the box is not empty** (one line; wording PROVISIONAL, 13s
   re-voices), and the close road's status-seam sentence changes to say where the words went —
   the current *"Your text is still here"* is false on that road today and must not stay false.
4. **1b's one-shot semantics:** the decline fires when a refused capture with words stands at
   quit; a second consecutive ⌘Q always proceeds; a refusal resolved and later re-arising re-arms
   the decline. Decline leaves the pad on screen speaking its refusal line.
5. **Pins:** (i) refused → close → fresh summon restores and speaks (red on old — the words are
   unreachable today); (ii) `.filed`/`.nothingToFile` clear the park; (iii) refused-at-quit →
   terminate declined once, second proceeds (red on old — `applicationShouldTerminate` replies
   true unconditionally today); (iv) the no-refusal abandon keeps nothing (the guard).
6. **QUESTIONS #137** carries the ratify bundle: the park's session scope (a crash or force-quit
   still loses it — the pad's stated cost model), the 1b decline + second-⌘Q rule, the
   clear-at-restore semantics, and both PROVISIONAL sentences.
7. The walk's honesty rule stands: the refusal road is carried by its pins and trace; walk what
   is walkable and say what is not.

### BATCH A1 — ORCHESTRATOR ADJUDICATION (2026-09-21; the batch CLOSES here)

**Verified, never trusted:** all 17 batch commits spot-checked against the report (head `fd2856e5`,
tree clean, pushed); the P6 wiring confirmed by grep (`clearRedoFuture()` at both recovery-door
acts); the two rewritten redo pins confirmed the ruled-change class (both had STAGED their state by
the exact behaviour row 3 fixes; each keeps its subject on a below-operations vehicle); the
KnownIssues residue row confirmed on disk with owner 17e; QUESTIONS #136/#137 confirmed logged.
**The orchestrator's own verification acts:** `QuickNoteParkTests` + `BranchDoorFlushTests` re-run
directly — **12/12 green**; capture `02` read — the minted take carries the debounce-window
keystrokes on the real board, which is P7's acceptance in a photograph.

**Adjudications sustained:** (1) the implementer's self-caught defaults residue (the row-42 class)
was verified by contents, scrubbed one-key-only, and the pins isolated — exactly the honest form;
(2) the row-49 landing flake adjudicated per the traps list (green isolated, zero diff lines in its
files); (3) row 3's undo-side residue correctly NOT fixed (session-wide stack; 13j's product call)
— DEFERRED to 17e, on her ratify list at #136; (4) row 7 built to the ruling with the early
`.terminateNow` road's consult as a correct widening the trace demanded, and the no-reason close
sentence accepted as the flagged judgment call (rides #137(e), one line to change).

**Dispositions (ledger rows 1–7):** rows 1–6 **FIXED** with named red-on-old pins
(`MobileCommentDraftTests` 3 · `PromotePicksArchivedPickTests` 3 · `ContentReplacementRedoTests` 5 ·
`BranchDoorFlushTests` 7 · `MobileQuickNoteReadFailureTests` 3 · `DeferredProjectionRetryTests` 2);
row 7 **FIXED** to the recorded ruling (`QuickNoteParkTests` 5, revert-verified, the guard green on
both sides by design). One residue DEFERRED (17e). Nothing dismissed as hollow. Evidence: core
1639/177 · full Mac **3059/507 ALL GREEN** · mobile 632/108 (the 4 knowns) · iOS build green · 7
walk captures with the un-walkable refusal road said, not faked. **KnownIssues row 65 resolves at
the run's closeout** (with rows 32/38/39/40), per the closeout duties.

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

## BATCH A2 RECORD — 17l items 1–4/6–7 + 17n + the phrase-transit pin

**WHAT I DID NOT DO (this record's first line, per the standing rule):** *(written at the skeleton;
flipped to the true statement as the batch proceeds.)* At this line's first writing: nothing built
yet. Standing fences honoured throughout and re-stated so the closing line can be checked against
them — zero `Sources/VariorumCore/Sync/` lines (17l item 5's `CorpusRotation.swift` is RUN B's), zero
schema, zero migration (the marker stays 8), nothing touched in `/Applications` or her real store,
no write or delete anywhere in her login keychain (row 9's confirmation is a READ-ONLY `security`
inventory, never `-w`), no author-only call taken.

**Session opened 2026-09-21.** Implementer: `opus-implementer` (fresh session, batch A2 only).
Read before any code, in the brief's order: the run file's Status banner · FENCES · BINDING
PRINCIPLES · LEDGER rows 8–15 + the kickoff scope rulings on rows 13 and 15 · ENVIRONMENT TRAPS ·
CAST & DISCIPLINE · the BATCH A1 RECORD; `notes/plans/phase-17-standing-fixes.md` § 17l (items 1–4,
6–7; item 5 read only to know its fence) and § 17n; `notes/QUESTIONS.md` #90 whole incl. HER
RULINGS block; `notes/KnownIssuesAndTechDebt.md` rows 32 · 38 · 39 · 40 (+ 41, the fenced one);
`notes/plans/pre-13x-postures-design.md` §16, THE LADDER's rows MINOR-N1 · N3 · N4 · NIT-N8 ·
MAJOR-3 and the F3 record's eight items; the copy constants' homes; the named code.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims marked PENDING)

| Row | Item | Status |
|---|---|---|
| 0 | Record skeleton + `run-a-screens/a2/` | **DONE** — this commit |
| 8 | **17l item 1** — the seeder's discover-then-mint latch + the ensure's purge consult | NOT-STARTED |
| 9 | **17l item 2** — the migration drill's escrow leg + her-Mac READ-ONLY confirmation | NOT-STARTED |
| 10 | **17l item 3** — her four ruled #90 wording changes, both platforms | NOT-STARTED |
| 11 | **17l item 4** — the dead Replace-All-Keys door: present from the root | NOT-STARTED |
| 12 | **17l item 6** — the ceremony's *(0 of 0)* → *preparing…* face | NOT-STARTED |
| 13 | **17l item 7** — NIT-N8's face VERIFIED post-13u4 + MINOR-N4 (2)'s copy PROVISIONAL | NOT-STARTED |
| 14 | **17n** — the encryption passphrase's 12-character floor at every SETTING door | NOT-STARTED |
| 15 | **KnownIssues 32** — the phrase-transit one-arm VERIFICATION pin | NOT-STARTED |
| — | Closing evidence | NOT-STARTED |

**Deaths and resumes:** none yet.

**Reverts:** NO REVERT IN FLIGHT. Every behavioural revert is announced HERE before it starts, taken
from a COMMITTED state, and restored by `git checkout --` from the REPO ROOT with `git diff` empty
before "restored" is written. If a later session reads "revert starting" here with no "restored"
after it, check `git diff` first: an uncommitted diff in a mechanism file is a revert in flight —
restore it from git, never adopt it.

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
