# 13i-b — LADDER ROUND 2 (cold review of round 1's fixes, fable-reviewer, 2026-10-01)

**Scope:** `git diff 2bc3c205..27723b9b` — the five round-1 fix commits (df25b855 F-R1-1 ·
c5f84d88 F-R1-2 · 223ffaa8 F-R1-3 · 665431ad F-R1-5 · 27723b9b F-R1-8 + dispositions +
ledger), re-reviewed per `notes/REVIEW_PROMPT.md` verbatim by a FRESH reviewer. Anchors read
whole in this session: `notes/plans/13ib-ladder-round1.md` (findings F-R1-1…8, the
implementer's agree/dispute, the DISPOSITIONS), the phase plan's THE LADDER section (the
architect's F-R1-1 ruling) + ledger + morning bundle, CLAUDE.md + AppSpec + OverallModel +
CoreDescription. Code read in full in this session: the whole fix diff, plus (current tree)
`Operations+ReadingConversion.swift`, `Operations+Intake.swift`, `Domain/IntakeDecision.swift`,
`Domain/RuleGrammar.swift`, `ShelfViewModel.spawnBook`, `ShelfQueries.poolListing`'s guard,
`Models/ReadingPost.swift` (status default), `RuleEditor.swift` + `RuleEditing.needsWrite`
(the malformed arm), and the two `Sync/Repairs.swift` passes the flipped rows ride past
(read-only — zero `Sync/` lines in the diff, verified against the diff stat).

**Job:** verdict each round-1 disposition FIXED / NOT-FIXED / REGRESSED; surface any NEW
finding the fix diff introduces (a new BLOCKER/MAJOR earns round 3).

**STATUS: ROUND 2 COMPLETE — LADDER CLOSED AT TWO ROUNDS.** All eight round-1 dispositions
upheld (5 FIXED, 3 record-class sound); ONE new finding, MINOR (NEW-R2-1), confirmed after
the implementer's AGREE and **FIXED in-window by this reviewer (70b8606a)** with its
red-watched pin. No new BLOCKER/MAJOR, so no round 3 under the standing rules; the
implementer's one sanity pass over the reviewer's cumulative fix diff remains, per the
cross-model flow.

---

## PER-DISPOSITION VERDICTS

**F-R1-1 (MAJOR — the un-bind residue deafness) — FIXED, verified whole.**
- Mechanism re-traced end-to-end on the current tree: `revertSmartConversion` flips each
  taken row to `status='arrival'` as it tombstones (`Operations+ReadingConversion.swift:248–250`);
  `intakePairState` then ranks the residue `.dismissed` (live=0, `left` counts only
  member-status tombstones — `Operations+Intake.swift:256–266`); `IntakeDecision.verdict`
  rings `.dismissed` as an ARRIVAL on a fresh EVENT only and `.nothing` on backfill/catch-up
  (`IntakeDecision.swift:148–149`) — exactly P-13ib-U1-1, never auto-seated, never swept back.
- **The pin re-run RED by this reviewer on the pre-fix tree** (worktree at 2bc3c205, the new
  test file overlaid): `anUndoneBindsResidueRingsAgainAsAnArrivalAfterARebind` fails at
  SmartConversionTests.swift:508 — `#require` nil at the fresh act, the exact traced silence;
  green on HEAD. The control (still-matching note re-binds as member) holds on both sides.
- The redo contract: the box carries `(id, undo-time status)`; `reapplySmartConversion`
  restores `membership.status = row.status` (`:307`) — members return members, a waiting
  arrival returns waiting (`undoingABindTakesAWaitingArrivalAndRedoReturnsItWaiting` green);
  both pre-existing redo pins now assert statuses (`allSatisfy { $0.status == .member }`), so
  a status-forgetting redo bites — the implementer's refinement 2, landed.
- Hand-removed members untouched: the revert's fetch is `deleted_at IS NULL` only
  (`:239–246`) — a member-class tombstone stands; removed stays out, as ratified.
- The two recorded-not-built corners verified accurate against the source: (a) the
  remove→re-add-by-hand→undo corner — `intakePairState`'s `left > 0` check does outrank the
  flip (any member tombstone ever), exactly as recorded; (b) the cross-device race — both
  `reading_post` repairs read live rows only (the pair dedupe is gated on
  `!resolved.isTombstoned`, `Sync/Repairs.swift:145`; the ownership pass reads
  `rp.deleted_at IS NULL AND rp.status='member'`, `:944–948`), so a flipped tombstone enters
  neither predicate and lands verbatim — the recorded worst case (her removal ranked as a
  dismissal → rings as an ARRIVAL, never auto-seated) is the true worst case. No `Sync/`
  line in the diff.
- Matches the architect's ruling (the plan's THE LADDER section) letter for letter.

**F-R1-2 (MINOR — the negated-sole-tag outflow) — FIXED, verified.**
- `RuleGrammar.soleOutflowTagID` + `referencesPositively` (`RuleGrammar.swift:190–212`): the
  parity walk is correct on every arm I traced — `NOT #a` → nil; `NOT NOT #a` → a;
  `#a ∧ NOT #b` → nil (two distinct tags — the reviewer's conservative final call, the
  alternative recorded); `#a ∨ NOT #a` → a (positive reference exists); `.tag("")` → nil
  (`tagIDs` drops the dead term). `RuleOutflowTests` 7/7 re-run green; the old mechanism
  (`tagIDs` descending `.not`) is visible verbatim in the diff's removed hunk.
- The business rule left the view model (P-9/CLAUDE.md): `ShelfViewModel` keeps only the
  liveness fact (`tagIsLive` in the gathering's wing). The door pin
  `spawnFromANegatedRuleLeavesTheOutflowUnset` green in this session's BindDoorTests run.

**F-R1-3 (MINOR — the rule-less spawn's false promise) — FIXED for its subject; one NEW
residue in the fix's own words (NEW-R2-1 below).**
- The sheet speaks three truths per `RuleGrammar.read` (`BindCopy.spawnMessage(for:)`), fed
  the same stored spec the receipt's gate reads (both read the row fresh inside the
  serialized closure / the sheet from its item); the receipt reserves "keeps collecting"
  for a readable rule. Pin `spawnFromARuleLessGatheringNeverClaimsItCollects` green,
  BindDoorTests 11/11 re-run by this reviewer; the pre-fix receipt's exact lie is the
  pin's documented red. The question half (should a rule-less gathering offer the spawn)
  confirmed present in the morning bundle beside F-U4-7.

**F-R1-4 (doc letters) — RECORD-ONLY disposition SOUND.** Both canon clauses drafted in the
round-1 file match the as-built code: (a) names the dismissal-record CLASS including the
un-bind's residue; (b) the §9 letter carries "(id, status)" — statuses as well as ids, as
the built redo requires. AppSpec itself untouched by the diff (correct — deltas land at
closeout, ledger row 7).

**F-R1-5 (the dead "(collecting)" surface) — FIXED, verified.** Grep over Sources/, App/
(mobile included), Tests/: zero references to `keepCollecting` / `collectingName` /
`collectingReading` / `collectingID` survive outside one doc comment recording the
retirement. The census matches the implementer's correction: two pins died whole, three
kept trimmed real subjects (the finished refusal still asserts no-second-book; the undo/redo
pin keeps exact-row + gains statuses; the outbox pin its rows), the retirement's own pin
(`theBindMintsNoSiblingAndTheBoundBookKeepsCollecting`) asserts count-unchanged AND the
bound book seating a fresh match at the end. SmartConversionTests 23 green (30/2 with
RuleOutflow). No red-on-old claimed — correctly, per the hallucination guard (no shipped
door's behavior changed).

**F-R1-6 (the `.alreadyTagged` receipt) — DISPUTE-SUSTAINED disposition UPHELD.** Re-verified
this session: `fileAsQuicknote` has exactly ONE caller (`QuickNoteView.swift:477`), filing
the post minted in the same serialized closure; no re-file door. No door reaches the state,
no red-on-old pin can exist — record-don't-fix is the guard's own letter. The future-door
shape (`.alreadyTagged(tagID:, readingID:)`) is recorded.

**F-R1-7 (`membershipElsewhere` kind filter) — RECORDED disposition SOUND.** The probe still
has no `r.kind` filter (`Operations+Intake.swift:271–287`, read this session) — correctly
deferred: unreachable by local doors since P-13ib-6, self-limiting (a bell, never a wrong
seat), and the three member-row readers belong to 13i-c's enumeration together. The carry
lives in the disposition text; ledger row 7's closeout must lift it into the hand-off notes
(it is not yet anywhere else — one line for the closeout checklist).

**F-R1-8 (`poolListing` window: 0) — FIXED as disposed (guard + doc).** The `assert(window >= 1)`
is a DEBUG oracle exactly as the disposition states (release behaves as today — the
deliberate, recorded choice); the doc names the contract and warns off the
`bookArrivals(limit: 0)` idiom. All callers verified ≥ 1 (`PoolPostsView.window` = 200;
`poolPosts(limit:)` → the phone's `listingLimit`, default 200).

---

## NEW FINDINGS (this round's own review of the fix diff)

### NEW-R2-1 · MINOR · `App/Variorum/Variorum/Features/Readings/BookOrderAndConversion.swift:44–48` (`BindCopy.spawned`, the `collects: false` arm) × `ShelfViewModel.swift:202–204` — the MALFORMED-cell receipt instructs an act the rule editor refuses by design

**What's wrong:** the F-R1-3 fix's receipt collapses `.none` and `.malformed` into one Bool,
and the shared `collects: false` text says *"it starts empty; give it a rule (Edit Rule…)
and it will collect."* For a book spawned from a MALFORMED gathering (the spec's bytes copied
verbatim — `normalizedRuleSpec` stores undecodable bytes as-is), Edit Rule cannot do that:
`RuleEditorModel.ruleIsEditable` is false on `.malformed` (`RuleEditor.swift:151`) and
`RuleEditing.needsWrite` returns false (`RuleEditing.swift:237` — "a newer client's rule is
not this build's to destroy"); the sheet shows the malformed notice ("nothing about it will
be changed"). So the receipt names a road that refuses the act it recommends — the same
door-sentence-made-false class F-R1-3 itself fixed, introduced for one cell by its own fix.
The SHEET's malformed arm is honest ("won't collect until the rule is fixed"); only the
RECEIPT's generic fallback lies.

**Evidence (traced):** inputs — a gathering whose `query_spec` is unreadable (a newer
client's rule arriving by sync is the designed producer of `.malformed`; headless writes the
test producer — the fix's own end-to-end test mints one with `querySpec: "not json {{"`).
She spawns → `collects == false` → `lastReport = BindCopy.spawned(name, count: 0,
collects: false)` → "…give it a rule (Edit Rule…) and it will collect." She opens Edit Rule
on the spawned book → the rule rows are read-only, the malformed notice shows, no save path
writes the rule. The instruction is impossible through the named door.

**Red-on-old pin:** door-level words pin — spawn from a malformed gathering; assert the
receipt does NOT instruct "give it a rule (Edit Rule…)" (equivalently: the malformed cell's
receipt speaks the sheet's own truth, "won't collect until the rule is fixed"). RED on the
current words (the existing end-to-end malformed test pins `spawned(..., collects: false)`
verbatim — its expectation flips with the fix).

**Proposed fix:** smallest honest shape — `spawned` takes the rule state (or a three-arm
enum) instead of a Bool; the `.none` cell keeps today's "give it a rule (Edit Rule…)" (true
there — a NULL spec edits fine) and the `.malformed` cell mirrors its sheet ("won't collect
until the rule is fixed"), naming no refusing door. Words only; no operation changes.

**Severity rationale:** MINOR — words-only, on a forward-compat corner cell no shipped Mac
door can mint locally; the same class and severity as F-R1-3 itself. **No round 3 earned**
(the standing rule: a new BLOCKER/MAJOR earns round 3).

*No other new findings. Specifically checked and NOT found: no regression in the surviving
SmartConversion pin set (every retired assertion's subject is either dead with its feature
or pinned elsewhere, per the census I re-checked against the file); no reader of tombstoned
`reading_post` rows mis-reads the new arrival-status tombstones (the Arrivals face, seat/
dismiss, capacity, the Pool exclusion and the sweeps all read live rows; `intakePairState`
and the two sync repairs behave as recorded); the bind's own mint still defaults
`status: .member` (`ReadingPost.swift:32`); the undo-flight and idempotence guards are
untouched; `reapplySmartConversion`'s `now` is still consumed (the reading stamp) — no
dead-code residue beyond the recorded doc mention.*

---

## CLEAN BILL (load-bearing things this round specifically checked and found solid)

- **The dismissal-class flip against the whole read surface:** every consumer of
  `reading_post` tombstones re-read — `intakePairState` (ranks the flip `.dismissed`;
  older member tombstones outrank, exactly as recorded), the verdict table (event-only
  ring, arrival-only — the ruling's two guards), `intakeSweep`'s any-row `NOT EXISTS`
  (residue pairs stay out of backfill/catch-up — deliberate, per P-13ib-U1-1), the live-row
  readers (face, judgment ops, capacity, member-hygiene) untouched by tombstoned rows.
- **Exact-row undo↔redo with statuses:** the `LockIsolated` box carries `(id, status)`;
  ids AND statuses survive the round trip; dead-post and live-pair skip guards intact;
  ping-pong pins green with the new status assertions.
- **Sync posture of the fix pass:** zero `Sync/`/schema/migration lines (diff stat); all
  writes ordinary rows through operations (S1), all deletes tombstones (S2); the status
  flip rides the standing outbox triggers; both `reading_post` repairs verified to pass
  flipped tombstones through verbatim (read-only check of `Sync/Repairs.swift:145/646/944–948`).
- **The parity table:** every `soleOutflowTagID` arm traced by hand and re-run (7/7);
  the door-level pin green; the view model carries no business rule (P-9).
- **The spawn door's gates:** sheet and receipt read the SAME stored spec (the row fetched
  fresh inside the serialized runner closure; the sheet from its item per the F-U2-3
  shape); `createReading` copies the spec verbatim; the sole-tag liveness check is
  wing-scoped.
- **Suites re-run by this reviewer:** SmartConversion + RuleOutflow **30/2 green**; the
  five intake-adjacent core suites (IntakeDecision, IntakeOperations, ArrivalMemberHygiene,
  GatheringRitual, IntakeSoak 6 seeds × 300) **65/5 green**; Mac `BindDoorTests` **11/11
  green** (xcodebuild, suite-scoped); **the F-R1-1 pin re-run RED on the pre-fix tree by
  this reviewer** (worktree at 2bc3c205 + the new test file: fails at
  SmartConversionTests.swift:508, `#require` nil at the fresh act — the exact traced
  silence); end of pass, the FULL core suite — **"Test run with 1913 tests in 200 suites
  passed"** (the record's headline count, confirmed; worktree removed after).
- **Process:** five commits, zero attribution trailers (the 2026-09-04 rule — checked via
  `git log --format='%(trailers)'`); the ledger row 6 flip and the morning-bundle riders
  (F-R1-1's two corners, F-R1-3's question half) present in the diff exactly as the
  dispositions claim; the arithmetic of the test-count delta (1907 + 7 + 1 − 2 = 1913)
  consistent.

## DISPOSITION OF NEW-R2-1 (for the flow)

MINOR — goes to the implementer verbatim per the cross-model flow; the reviewer's final
call and fix (if confirmed) follow in this ladder's fix window or ride the closeout's
structure singles, at the orchestrator's routing. No round 3 is earned by it.

## THE IMPLEMENTER'S AGREE/DISPUTE (round 2)

*The implementer voice (opus-implementer, the same session as round 1's exchange,
2026-10-01). Nothing was implemented; the sites below were read at HEAD 1c5d2bad.*

### NEW-R2-1 — AGREE (the receipt names a door that refuses the act it recommends)

Every link holds:
- **The receipt.** The spawn's receipt gate is one Bool (`ShelfViewModel.swift:201–204`,
  `collects = case .rule`), so `.none` and `.malformed` share `BindCopy.spawned`'s
  `collects: false` arm. That arm says "it starts empty; give it a rule (Edit Rule…) and it
  will collect." It actually lives at `BookOrderAndConversion.swift:244–248`; the finding's
  `:44–48` points into `BookOrderChoices` (a dropped digit).
- **The copied rule.** The spawned book gets the malformed bytes verbatim
  (`normalizedRuleSpec`, `Operations+Reading.swift:71–74`).
- **The editor.** On that book Edit Rule reads the stored value as `.malformed`, so
  `ruleIsEditable` is false (`RuleEditor.swift:151`). `RuleEditing.needsWrite` returns false
  for every draft (`RuleEditing.swift:236–237`). The U3 mounted pin already confirms no rows,
  no add doors and refused edits, while the dial still saves.
- **No other road.** No Mac door can give that book a rule: P-13ib-U3-1 has no clear-the-rule
  door, and Promote to Book and the phone's create-book both mint new readings. So the
  instruction is impossible through the door it names.
- **The sheet is already right.** Its `.malformed` arm (`:230–233`, "won't collect until the
  rule is fixed") names no door and is true; "fixed" is reachable by a client that can read
  the rule. Only the receipt lies.

**Severity:** MINOR is right. It is words only, on a forward-compatibility cell that no
shipped Mac door can create locally.

**Fix-shape note (agreeing with the reviewer's shape):** have `spawned` take
`RuleGrammar.ReadResult` — the type `spawnMessage(for:)` already switches on — rather than a
new enum, so the sheet and the receipt are two arms of one vocabulary. The runner closure can
return the `ReadResult` it already computes (it is `Equatable, Sendable`), so both words read
one value.

**The discriminating pin:** the malformed cell's receipt must not contain "Edit Rule". If the
existing end-to-end malformed test builds its expectation by calling `BindCopy.spawned(...)`
itself, that test is self-referential and cannot go red by itself. The negative assertion is
the red-on-old.

## THE REVIEWER'S FINAL CALL ON NEW-R2-1 (2026-10-01, after the implementer's agree; fix implemented by the reviewer in the same session, per the cross-model flow)

**NEW-R2-1 — CONFIRMED · FIXED (70b8606a), the implementer's three refinements taken
whole.** The line pointer stands corrected (`BindCopy.spawned` is
`BookOrderAndConversion.swift:244–248` pre-fix; the finding's `:44–48` was a dropped digit
into `BookOrderChoices`). The fix is the agreed shape: `spawned(_:count:rule:)` takes
`RuleGrammar.ReadResult` — the type `spawnMessage(for:)` already switches on — so the sheet
and the receipt read ONE value (`ShelfViewModel` computes `RuleGrammar.read` once in the
serialized closure and returns it). The three arms: `.rule` keeps the standing promise;
`.none` keeps "give it a rule (Edit Rule…)" — true there, a NULL spec edits fine, and the
pin holds it as the POSITIVE CONTROL; `.malformed` mirrors its sheet's truth ("starts empty
and won't collect until the rule is fixed"), naming no door. Words only; no operation,
query or stored byte changes.

**The pin (the implementer's discriminating shape):** the malformed cell's end-to-end
assertions are INDEPENDENT strings — never `BindCopy.spawned` itself (a self-referential
equality could not go red) — `!brokenReport.contains("Edit Rule")` plus the
mirror-the-sheet positive, inside `spawnFromARuleLessGatheringNeverClaimsItCollects`.
**RED WATCHED on the pre-fix words** at the exact lie (two issues: Edit Rule present;
the mirror absent — BindDoorTests.swift:369/373 in the watch run), green on the fix.

**The ladder's closure (the reviewer's call, authorized):** CLOSED AT TWO ROUNDS. Round 2
found no new BLOCKER/MAJOR — one MINOR, confirmed and fixed in-window with its red-watched
pin — so no round 3 is earned under the standing rules (a new BLOCKER/MAJOR earns round 3;
hard cap three). Owed next per the cross-model flow: the implementer's ONE sanity pass over
the reviewer's cumulative fix diff (rounds 1+2: df25b855 · c5f84d88 · 223ffaa8 · 665431ad ·
27723b9b's F-R1-8 hunk · 70b8606a); anything it raises returns to the reviewer for the
final word. Then ledger row 7 (closeout) lifts: F-R1-4's two canon clauses, F-R1-7's
13i-c enumeration row, the morning-bundle riders, and NEW-R2-1's record.

### The round-2 fix pass, verified

Commit: 70b8606a (NEW-R2-1 — words + pin, one piece). End of pass, after the last code
edit: Mac `BindDoorTests` — **"Test run with 11 tests in 1 suite passed"** (the pin's two
new assertion groups included; 0 issues); the FULL core suite — **"Test run with 1913
tests in 200 suites passed"** (unchanged — the fix touches only the Mac target's words);
zero instances (`pgrep` clean). No `Sync/`, schema, migration, editor-seam or
`VariorumCore` line in the round-2 fix diff; no attribution trailers.

## THE IMPLEMENTER'S SANITY PASS (the cross-model flow's last step — 2026-10-01)

*The implementer voice (opus-implementer; the same session as both rounds' agree/dispute).
No code changed. Scope: `git diff 2bc3c205..70b8606a` — the six fix commits df25b855 ·
c5f84d88 · 223ffaa8 · 665431ad · 27723b9b · 70b8606a. I read the whole diff (sources, tests,
records) against my own round-1 and round-2 verdicts.*

**OUTCOME: CLEAN BILL.** Every fix matches what I agreed to. Two record-class observations
follow; neither is a regression, and neither is a finding against the fix diff.

### Fix by fix, against my verdicts

- **F-R1-1 (df25b855) — matches.**
  - `revertSmartConversion` flips each taken row to `status='arrival'` in the same write as
    its tombstone.
  - The pre-images are correct by construction: `for var row in standing` mutates copies, so
    `standing` still holds the undo-time statuses for the `(id, status)` box.
  - `reapplySmartConversion` restores each row's captured status.
  - A member removed by hand before the undo is untouched, because `standing` reads
    `deleted_at IS NULL` only.
  - My three asks all landed:
    - the new pin asserts EXACTLY a live arrival, not "arrival or seat";
    - BOTH member redo pins gain a status assertion, so a redo that forgets statuses now
      fails them;
    - the remove-then-re-add corner and the cross-device race are recorded in the op's doc
      and in the bundle.
- **F-R1-2 (c5f84d88) — matches.** It is the polarity check I recommended, not the
  positive-walk widening: `#a ∧ NOT #b` stays unset. Polarity is the parity of `not`s. The
  rule is pure Domain (`RuleGrammar.soleOutflowTagID`), and the view model keeps only the
  liveness fact. The table pins every arm I named, including `★ ∧ NOT #a`.
- **F-R1-3 (223ffaa8) + NEW-R2-1 (70b8606a) — match.**
  - The gate is `RuleGrammar.read == .rule`, and my malformed cell is included.
  - The sheet branches on the item's row; the receipt reads the same `ReadResult`, computed
    once inside the runner.
  - The malformed receipt names no door and mirrors its sheet. The `.none` arm keeps Edit
    Rule, which is true: a NULL spec edits fine.
  - The NEW-R2-1 pin uses INDEPENDENT strings, with Edit Rule as the positive control, as
    I asked.
- **F-R1-4 — record-only, matches.** The drafted (a) names the dismissal CLASS, including
  the un-bind's residue. The drafted (b) carries `(id, status)`.
- **F-R1-5 (665431ad) — matches my corrected census.** Two pins die whole; three keep their
  real subjects trimmed; `withoutTheOfferNoSecondBookExists` folds into the retirement pin
  `theBindMintsNoSiblingAndTheBoundBookKeepsCollecting`, which checks one row flipped in
  place plus a fresh match seating at the end. A grep over `Sources/`, `App/` (Mac, Shared,
  mobile, Mac tests) and `Tests/` finds zero residue beyond the one doc mention recording the
  retirement.
- **F-R1-6 / F-R1-7 — record-only, as disposed.** F-R1-7 is carried across its three readers
  for 13i-c.
- **F-R1-8 (27723b9b) — acceptable.** It uses a doc line plus a DEBUG `assert` rather than
  the `precondition` I floated; release behaviour is unchanged, and that was a deliberate
  recorded choice. No caller or test passes a zero window (grep, including the mobile
  `listingLimit`).

### Suites re-proven by my own hand (2026-10-01, HEAD 13ee7c2a, zero instances before and after)

- **Core:** `swift test --filter` over SmartConversion, RuleOutflow, GatheringRitual,
  IntakeOperations, IntakeDecision, IntakeSoak (6 seeds × 300), ArrivalMemberHygiene and
  PoolTuck — **"Test run with 102 tests in 8 suites passed"**.
- **Mac:** `xcodebuild … test -only-testing:VariorumTests/BindDoorTests
  -only-testing:VariorumTests/RuleEditorTests` — **"Test run with 20 tests in 2 suites
  passed"**, no skipped lines, `** TEST SUCCEEDED **`.

### Two record-class observations (for the reviewer's final word; neither reopens the ladder)

1. **The ruling's second clause is held by construction but has no pin.** The clause: a
   member she REMOVED BY HAND before the undo keeps its member-class tombstone. Nothing
   asserts it. The sequence would be:
   - bind;
   - remove A by hand;
   - untag A, so a re-bind cannot re-materialize it;
   - undo;
   - re-bind;
   - re-tag A;
   - expect NO row: `.leftAsMember` stays silent.

   This would be a CONTROL pin: green on both sides by nature, so not red-on-old. It guards
   against a future revert that grows to flip tombstoned rows too. Optional; it could ride
   the closeout's structure singles. (`GatheringRitualTests`' hand-removal at `:152` is not
   under an undo.)
2. **A residue of F-R1-3's class that predates the fix diff: a rule carrying only LEGACY
   terms.**
   - The cell is a grandfathered v1_18 `{"profile":…}` or date-bound rule with no tag or
     star term. No live door mints one any more: Promote to Book and the phone's create-book
     hand over tag-only v1 drafts.
   - Such a rule reads as `.rule`, so the spawn sheet ("new matches keep joining"), the spawn
     receipt ("it keeps collecting") and the BIND sheet's keeps-collecting sentence all
     promise collection.
   - But no applying act can reach that book. The tagging event's `appliedTag` returns false
     on an empty root set (`Operations+Intake.swift:200`). The starring event needs a star
     term (`:74`). That is P-13ib-U1-6 by design.
   - So such a book collects only at catch-up occasions (rule edit, un-finish, restore), and
     only through Arrivals.
   - This dates from U1/U3 and the fix diff does not touch it. It concerns words, and only on
     grandfathered data. I recommend a bundle or closeout line, owned by 13i-d's vocabulary
     sweep or by whatever retires the legacy terms, rather than a ladder fix.
