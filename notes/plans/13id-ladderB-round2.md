# 13i-d LADDER B — ROUND 2 (fresh cold re-review of round 1's fixes, `fable-reviewer`, 2026-10-02)

**Subject:** the ROUND 1 FIX DIFF `8b2def94..eaee3143` — fix A `9b9d604e` (the Trash take arm's
live-placement join), fix B `cb7bfc3f` (the postID-gated wing context), fix C `06d450ee` (the
wing-aware sample restore), record D `11dcd2f7` (MINOR 1's documented residual), fix E `006ee025`
(the attribute NIT), the sanity NIT's fix `0aac9f6f` (`reloadAdopts`), and the round's record
commits (`01940a60`, `341b9bb3`, `4b2adc4e`, `eaee3143` — ten commits, all accounted). Round 1's
findings, agree/dispute responses and final calls (`notes/plans/13id-ladder-round2B.md`) are the
anchor; the wider bank diff (`3e6ed192..ade4df64`) is context, not the target. Prompt:
`notes/REVIEW_PROMPT.md` VERBATIM (the plan carries no "Review foci" section — grepped).
`notes/SyncSpec.md` read IN FULL (the diff touches `Sync/`). HEAD verified `eaee3143` ==
`origin/main`, tree clean; every hunk of the fix range read in this session.

**STATUS: ROUND 2 COMPLETE — no BLOCKER, no MAJOR; ONE NIT. Nothing reaches the round-3 bar.**

## SCOPE FENCES VERIFIED FIRST

- **The ONE `Sync/` touch is record D's doc paragraph, NO engine line:** the whole
  `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift` hunk is +14 lines of `///` doc comment on
  the `seedTagPaths` field (the SECOND-residual paragraph beside the standing retag/untag class);
  every added line begins `///` — zero executable lines, verified at the hunk itself. The
  documenting pin (`SampleLibraryDedupeRepairTests.documentedResidual_…`) lives in Tests, not
  `Sync/`. SyncSpec §7's R-pre13u-8 matrix is untouched; the pin is §7's review-finding-#6 idiom
  exactly (a test documenting a converged outcome, endorsing nothing).
- **Zero schema, zero `Persistence/`, zero `Server/`, zero editor seam** in the fix range
  (file list read whole: Seeder / WingsModel / CommitBar / TakesBottomBar / Queries/Trash.swift /
  Operations+Import / the Sync doc + tests + notes). CommitBar/TakesBottomBar are bar chrome,
  not the editor seam (`EditorTextView`/`BlockRangeIndex`/`PaneTextAuthority` untouched).
- **Commit hygiene:** no `Co-Authored-By`/`Claude-Session` trailer on any of the ten commits
  (full bodies checked); pushed (`origin/main` == HEAD).

## FINDINGS (severity-ranked; `[severity] · file:line · what · evidence · fix`)

- **[NIT] · `App/Variorum/Variorum/Core/Views/WingsModel.swift:413–414` · the modifier-level doc
  went stale one fix later — "Both writes are cancellation-guarded (fix B)" is no longer true of
  the second write · **Evidence:** `0aac9f6f` replaced the confirm-reload's dead
  `!Task.isCancelled` guard with the subject gate (`reloadAdopts`, :430–435), and that site's own
  inline comment says the opposite of the modifier doc eight lines above it ("An UNSTRUCTURED
  task: cancellation never reaches it, so the subject check is the guard"). Only the `.task(id:)`
  write (:420–423) is cancellation-guarded now. The hazard is a future reader trusting the
  modifier doc and "restoring" a dead cancellation guard at the unstructured site — the exact
  confusion the sanity NIT just removed. Doc-only; no behavior, no pin (cleanliness class, the
  same as round 1's own NIT). · **Fix:** reword :413–414 to say the structured load is
  cancellation-guarded and the post-act reload adopts by subject (`reloadAdopts`).

## COMPLETENESS AGAINST ROUND 1 (every finding → its fix/record, re-verified cold)

| Round 1 finding | Disposition | Round 2 verdict |
|---|---|---|
| MAJOR→MINOR (take arm wing fence) | fix A `9b9d604e` | **CORRECT AND COMPLETE** (trace below; pin genuine; the severity downgrade's two premises re-verified on my own read) |
| MINOR 1 (asymmetric dedupe meeting) | record D `11dcd2f7`, ruled (b) | **CORRECT AND COMPLETE** (residual at the field doc; KnownIssues row with a VALID owner — the R2-7 header rule names "the mobile app" as an unslotted first-class project row; QUESTIONS #178 with the author-only flag on the keeper-preference arm; the documenting pin green and non-endorsing; next-free number bumped to #179) |
| MINOR 2 (wing-context stomp) + the sanity NIT | fix B `cb7bfc3f` + `0aac9f6f` | **CORRECT AND COMPLETE** (all four write sites guarded by the right guard for their structure; both renderers gated; one stale doc line left — the NIT above) |
| MINOR 3 (wing-moved sample restore) | fix C `06d450ee` | **CORRECT AND COMPLETE** (trace below; the dangling-wing corner composes with `sameEffectiveWing`; strays structurally confined to the book's wing) |
| NIT (attribute placement) | fix E `006ee025` | **CORRECT** (doc block contiguous, attribute declaration-adjacent) |
| The sanity pass's declined dead-wing control | accepted, not filed | **ACCEPTED HERE TOO:** the take arm's dead-wing behavior rides the SHARED `fence()` builder (one generated SQL for every arm), already pinned on the wing fence by `theTrashIsPerWingAndADeletedWingsRowsComeHome`; a take-specific dead-wing state needs `deleteWing` on a non-empty wing (refused — sync-race only) |

## VERIFICATION LOG (verified-by-run vs verified-by-read, said honestly)

**Run in this session (HEAD's exact code — `git diff 0aac9f6f..eaee3143 -- App Sources Tests`
is EMPTY, so the prebuilt `DerivedData/13id-ladderB` bundle, built 20:44 against `0aac9f6f`'s
tree, exercises the review tree):**
- Core: `WingScopedReadsTests` + `TrashAndArchiveTests` + `SampleLibraryDedupeRepairTests` (+
  the facts suite riding the filter) — **47 tests in 4 suites passed**; the three named pins run
  individually — `aDeletedTakeBelongsToItsNotesWing`,
  `documentedResidual_aRawCopyCanRetireAnArrangedOnesDemoState`,
  `theTrashNamesANamelessNoteByItsDayAndNeverByThePlaceholder` (the justified flip) — all green.
- Mac (`test-without-building` on the ladder bundle, zero instances checked first):
  `VocabularySweepTests` + `SampleLibraryTests` + `WingSwitcherTests` — **43 tests in 3 suites
  passed**, fix B's two pure-gate pins, fix C's `aMovedBooksRestoreIsWingAware` and
  `emptyTrashTakesOnlyTheCurrentWingsRows` among them.
- The record's core-FULL claim (2127/234) carries to HEAD by construction:
  `git diff 341b9bb3..eaee3143 -- Sources Tests` is EMPTY (the two later code-bearing commits
  touch App-side files only), so the fix session's full run and the sanity pass's own ran this
  exact core tree.

**The red-on-old/revert-red claims, each re-derived from the mechanism rather than taken:**
- **Fix A (red-on-old, "1 test / 3 issues"):** on the old join the staged never-released block
  has a NULL stamp → the take reads as Home's → assertion 1 (`takeIDs(wing) == [spare]`) fails
  empty, assertion 2 (`takeIDs("").isEmpty`) fails listed, assertion 3 (`row?.noteID`) fails nil
  — EXACTLY three issues, and the two post-move assertions pass on old (still Home's). The
  recorded red count is the trace's own.
- **Fix B (revert-red, 1 issue):** `matching` flipped to pass-through fails only the middle
  expectation (own-context and nil cases still pass) — exactly 1 issue, as recorded.
- **`reloadAdopts` (revert-red, 2 issues):** adopt-always fails exactly the two negative
  expectations — 2 issues, as recorded.
- **Fix C (red-on-old):** old `discover` resolved the tag across wings and old `place` minted in
  Home; `addPostToReading` → `requireSameWing` → `crossWingMembership` thrown partway — the
  pin's restore call throws, "Caught error" — the exact recorded shape.
- **Record D's pin is green-by-design** (documenting, the review-finding-#6 idiom — no red
  exists or should).

**Re-traced cold, mechanism by mechanism:**
- **Fix A:** `last_container_id` is a deletion/release stamp (NULL for a never-released placed
  block), so the old `LEFT JOIN container c ON c.id = b.last_container_id` read every such take
  as Home's. The new scalar subquery is DETERMINISTIC by I2's live-unique index
  (`uq_cblock_ownership(block_id) WHERE deleted_at IS NULL` — at most one live row) and INDEXED
  by the same partial index (one probe per candidate row; candidates bounded by the 30-day
  deleted-take window — P1 untouched). COALESCE keeps the stamp for a released block;
  `fence("c.wing_id", nullIsHome: true)` still reads a no-note take as Home's and a dead-wing
  note's as Home's (the shared `NOT IN (live wings)` arm). The snippet corner is byte-identical:
  `createPool` mints wing `''`, so a scraps take attributes to Home exactly as before.
- **The severity downgrade's premises, MY OWN READ:** `TrashScope.listedKinds`
  (RecoveryActs.swift:489) excludes `.take` and `kinds(filter:)` can never widen past it (:503)
  — no Trash view lists a take (her D1); `emptyTrashTakes(.take) == false` (:511) filters BOTH
  the confirm's acted count (:383) and the act's `requestPurge` targets (:431) — no Empty Trash
  can mint a purge intent for a take (her G6). The reachable harm was the confirm's wrong-wing
  "N takes stay" count. MINOR was the right call; no MAJOR stood.
- **Fix B:** `NoteMenuWingContext.matching` is the ONE render condition at both renderers
  (grepped the whole tree — CommitBar:827 and TakesBottomBar:480 are the only `WingNoteDoors`
  renderers from this context), so a stale or nil-stomped context draws NOTHING rather than
  another note's doors/title. All four `load` write sites carry the structurally-right guard:
  the `.task(id:)` site a REAL cancellation guard (structured; no suspension point between
  guard and write — MainActor-atomic, so no slip window), the three unstructured reload sites
  (the modifier's confirm-reload + both bars' `onDone`) the subject gate `reloadAdopts` applied
  AFTER the await. A stale adopt landing before the subject's own load is filtered by the
  render gate; the nil-standing-context drop is safe because `onDone` can only fire from a
  rendered (matching) context. The `MoveAsk` built at click time carries the MATCHED context's
  postID/title, so even a click racing a note switch acts on the note whose door was clicked.
- **Fix C:** `discover` reads the book's effective wing via `Queries.wingIsLive` (`''` → true —
  Home; a dangling pointer → `''`, the surfaces' rule), resolves the reserved tag via
  `allTags(db, wingID:)` (wingScope — Home also lists a dangling wing's row), and `place` mints
  via `importPost(wingId: wing)` after the same `assertReadingAcceptsPosts` gate.
  `requireSameWing` compares EFFECTIVE wings (`sameEffectiveWing`,
  Operations+Reading.swift:892), so the dangling-book corner composes: book-wing dangles →
  discover says `''` → the mint lands `''` → passes. Stray discovery flows through the
  wing-resolved `existing.tagID` (`everythingTagged`), so a cross-wing stray is structurally
  not found and its title mints fresh — lesson 11's fence held (the only residue is the
  pre-existing, already-recorded F-U5-9/sync-race application class, not this diff's). The
  fresh-seed shape (`wing == ''`) is behavior-identical — and strictly better in one corner:
  the OLD all-wings tag lookup could resolve a hand-minted same-path tag in ANOTHER wing and
  then refuse at `applyTag` (same-wing-only); the Home-scoped lookup mints Home's own row.
  Takemania verified wing-safe through `newPostInReading` (Operations+Reading.swift:740 — born
  in `reading.wingId`, R-13ic-2); a two-wing name collision restores coherently into whichever
  book `discover` finds (pre-fix it failed partway — strictly improved). The C2 ownership arms
  (`noteMemberedElsewhere`/`noteOwnedElsewhere` → copy-in) are untouched and still rethrow
  everything else loudly.
- **Record D:** the field doc names the residual beside the retag/untag class it extends; the
  KnownIssues owner is valid under the file's own R2-7 header rule; QUESTIONS #178 routes BOTH
  stronger remedies to her bundle with the keeper-preference arm correctly flagged author-only
  (it would amend R-pre13u-8's "both pristine → smaller id"); the pin stages the exact
  asymmetric meeting (raw smaller-id copy vs #classics-arranged copy) and asserts the converged
  outcome without endorsing it. SyncSpec §3's outbox discipline, §7's matrix and the occasion
  gating are untouched — no engine line in the range.
- **Fix E:** the doc block is contiguous and `@discardableResult` declaration-adjacent
  (Operations+Import.swift:55–63).
- **The TrashAndArchiveTests flip is JUSTIFIED:** the old arm's own comment recorded this exact
  gap as propose-only ("needs a join through the live placement, which is a query change of its
  own"); the fix IS that join, the flip adopts the day-name rule its three siblings keep, and
  the old comment is quoted in place. No product behavior invented — D1/G6 untouched; the
  per-wing attribution was U5's own recorded contract for takes.
- **Nothing new introduced:** `NoteMenuWingContext`'s `Equatable` gaining `postID` has no
  equality-dependent consumer (grepped); the existing load pin's constructor edit is mechanical
  with its subject intact; no other consumer of `Queries.trash` depends on the old NULL
  attribution (takes are excluded from every listing by `TrashScope`; the phone's all-wings
  read is unfenced and unaffected); `discover`'s only callers are the seeder's own entry and
  `SeededBookRestore.restore` (both want the wing-aware shape; `isComplete` reads
  bookID+titles only).

## CLEAN BILL (load-bearing things specifically checked and found solid)

- The Sync/ fence: record D's touch is doc-only; SyncSpec read in full against it.
- The severity call that dissolved the round-3 question (D1/G6, re-read at the source).
- All four context-write sites and both renderers — the guard matches each site's structure.
- The pins' red counts re-derived from the mechanisms and matching the records exactly.
- The pin runs: core 47/4 + the three named pins, Mac 43/3 — this session's own, on HEAD's code.
- Record-keeping: LIVE STATUS flipped per commit; the END-record suite list corrected honestly
  against the xcresult (`4b2adc4e`); the KnownIssues owner rule honored; #178/#179 numbering.
- Commit hygiene and push discipline (no trailers; `origin/main` current).

## SUMMARY BY SEVERITY

- **BLOCKER:** none.
- **MAJOR:** none — **nothing reaches the round-3 bar.**
- **MINOR:** none.
- **NIT:** 1 — `noteMenuWingDoors`' modifier-level doc still says "Both writes are
  cancellation-guarded" one fix after that stopped being true of the unstructured write
  (WingsModel.swift:413–414); doc-only, fix is a two-line rewording.

Round 1's five fixes and one record are **correct and complete against their findings**; the
sanity NIT's fix is correct; nothing new of MINOR or above was introduced by the fix diff.

---

## THE ROUND-2 NIT'S DISPOSITION (the orchestrator, 2026-10-02 — the architect's small-code allowance: doc-only, no behavior, no pin possible, so the full cross-model arm is not run for it)

CONFIRMED and FIXED in this commit: `noteMenuWingDoors`' modifier doc now says what holds —
the structured `.task` write is cancellation-guarded, the unstructured reloads are
subject-guarded (`reloadAdopts`), either way no stale stomp — ending the eight-line
contradiction with the inline comment. **LADDER B CLOSES: two rounds, zero disputes on
mechanism anywhere, one severity dispute upheld on the reviewer's own recheck, no round 3.**
