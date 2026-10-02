# 13i-c — LADDER ROUND 2 (cold re-review of the round-1 fix pass, `fable-reviewer`, 2026-10-02)

**Scope:** the FIX DIFF `5a7c9c1c..63c8f130` (six commits: ea8b686f the agree/dispute record ·
f29ffd84 · e1dcfa36 · 12e92bdb · 909c8fdb · 2a57b001 the five fix pieces · 63c8f130 the close),
re-reviewed against the round-1 record `notes/plans/13ic-ladder-round1.md` (findings, the
implementer's seven AGREEs, the reviewer's final calls), the plan
`notes/plans/phase-13i-c-owned-finished-sealed.md`, CLAUDE.md + its canon, KnownIssues and
QUESTIONS. The phase's whole diff `ca3b8a85..63c8f130` consulted for context. The fix diff touches
no `Sync/`, schema, custody or editor-seam file (verified against its file list — 8 production
files, 6 test files, the record); TEXTKIT2_NOTES and a SyncSpec re-read not required this round
(round 1 read SyncSpec in full for the phase's lockstep; the fix diff adds no sync-shaped change —
the one new UPDATE rides the existing `dismissPendingArrivals` transaction with triggers live).
No "Review foci" section exists in or beside the plan (re-checked).

**Verification run by THIS review** (zero-instance `pgrep` before every Mac run):

- **Red-on-old VERIFIED BY REVERT** — a detached scratchpad worktree at `5a7c9c1c` with the two new
  core pin files applied: all four core pins FAIL there with exactly the recorded shapes —
  `theConfirmsCountIsTheDismissalsSet…` (promised 0, expected 1), `sealPreviewCountsTheArchivedWaiter`
  (0 vs 1), `mixedWaiters…` (promised 1 vs 2 AND **dismissed 2 ≠ promised 1 — the old mechanism
  shown live: the act tombstoned the archived waiter the confirm never counted**), and
  `aNoteWhoseOnlyRowIsAStrayUnderADeadBookStaysInThePool` (the note excluded from the Pool). The
  worktree removed after. The Mac pins' red-on-old is trace-certain rather than revert-run (the old
  copy functions had no sealed arm, so "unseal" could not appear; the old `offer` assigned nothing
  on nil; the old composite called `createPost`, which has no wing parameter — wing `''` by
  construction) — recorded honestly.
- **Green on tip:** full core `swift test` — **2008 tests / 213 suites passed** (matches the close's
  claim byte-for-byte); Mac `build-for-testing` + BookStateDoors/MembershipChoice/JournalBooks/
  TimelineAndReadings — **46/4 passed** (the three named pins each watched run:
  `finishAsksWhenOnlyAnArchivedNoteWaits`, `theDailyDoorOnASealedJournalNamesUnsealNeverReopen`,
  `aNonDailyEntryIsBornInItsBooksWing`); BookArrivals + ArrivalArms **15/2 passed**. No
  `Co-Authored-By`/`Claude-Session` trailer anywhere in the range (grep over bodies and trailers).

---

## PER-FINDING VERDICTS (round-1 findings × the fix pass)

**[MAJOR] the finish/seal confirm's N vs the dismissal — FIXED.** The shared predicate
`Queries.pendingArrivalRowsWhere` (`OwnershipQueries.swift:279`) sits under BOTH statements:
`pendingArrivalCount`'s COUNT (`:292–296`, one placeholder, alignment checked) and
`dismissPendingArrivals`'s UPDATE (`Operations+Intake.swift:500–504`, arguments `[now, readingID]`,
alignment checked) — the confirm equals the act by construction, exactly the adopted sharper shape.
Caller sweep: the count's ONLY consumers are the two confirm roads (`sealPreview` at
`OwnershipQueries.swift:269` and `BookStateDoors.swift:448`'s `.finishBook` open) — no display
surface reads it, so nothing else changed meaning. The Arrivals LINE's predicate
(`ArrivalQueries.swift` `bookArrivalSource`: `c.deleted_at IS NULL AND c.archived_at IS NULL AND
c.kind='post'`) is untouched and asserted unchanged inside the pins. Act-side consistency traced:
`lockReading` dismisses on every non-sealed finish (`Operations+Reading.swift:236–246`, sealed
no-ops); `sealReading` dismisses only when `!locked` (`Operations+Seal.swift:60–62`), matching
`sealPreview`'s `locked ? 0 : count` — count = act at every door. The undefined spare-the-archived
arm is correctly a pending QUESTIONS #169 paragraph (a question, not a ruling), the (a) arm built
PROVISIONAL — the spec-defensible reading of §24. Red-on-old verified by revert (above); the Mac
door pin asks with N=1 and the confirm dismisses exactly that row. Disposition sound.

**[MINOR] `poolListing`'s probe missing liveness — FIXED.** `ShelfQueries.swift:330–334`: the
probe's EXISTS now carries `r.deleted_at IS NULL` beside `r.kind='book'`, matching the two sibling
readers letter-for-letter (`membershipElsewhere`, `noteMemberships` — re-read both). P1 shape
unchanged (a primary-key probe; `PoolTuck`'s plan pin green inside the full run). Red-on-old
verified by revert. The HOME doc updated honestly (a tombstoned book's stray is named a SyncSpec §5
tolerance state, which matches round 1's reachability trace). Disposition sound.

**[MINOR] the F-5 wing class at `newEntry` — FIXED (non-daily arm) · the daily arm's recording
stands.** `BookStructureModel.swift:639–649`: the assert → `createPost` → `addPostToReading`
composite replaced by `ops.newPostInReading(readingID, profile: .generic, entryDate: entryDay)` +
the explicit `setSegmentationDefault(.oneBlock)`. Equivalence traced gate-for-gate at the op
(`Operations+Reading.swift:634–688`): missing (`liveReading`) / `wrongReadingKind` / `lockedReading`
/ `readingAtCapacity` on the SAME member-count predicate `assertReadingAcceptsPosts` used — the
refusal set is unchanged; `entryDate` validates and threads through to `insertPost`; the mint takes
`reading.wingId` (R-13ic-2); membership lands BEFORE `applyAutoTag`, and the old road's
`addPostToReading` applied the auto-tag too (`Operations+Reading.swift:620`), so the outflow
behavior is byte-equal — the swap fixes the wing and makes REFUSE-BEFORE-MINT one real transaction,
nothing else moves. Pin green; red-on-old compile-certain (`createPost` has no wing parameter —
`Operations+Container.swift:16–19`). The DAILY arm's CONFIRMED-RECORDED call re-checked and
AGREED: `canonicalJournalEntry` is wing-blind, so a wing threaded into the mint alone would still
open a Home day-entry into a W Journal — the one-entry-per-day rule's SCOPE is a product question
(13i-d's switcher), not a fix. Obligation restated below.

**[MINOR] a sealed blocking book named "reopen" — FIXED (the reachable class) · the generic-table
recording stands.** Every named arm verified in code: `NoteMembership`/`SeveredMembership` carry
`sealed` (`r.sealed_at IS NOT NULL`, one column in the existing statement; `moveInPreview` threads
it); the choice sheet's blocked line forks through `moveBlockedRow`
(`MembershipChoice.swift:203–207/221–223`); `moveRefusedFinished(_:sealed:)` forks, and BOTH `?? ""`
catch arms are gone — `MembershipDoors.moveIn` (`:385–392`) and `BookArrivalsModel.moveIn`
(`BookArrivals.swift:367–378`) fall back to the operation's shared words when the blocking book
cannot be named, never "“” is finished"; the chip's add/collect/diverge arms pass
`book.sealedAt != nil` into `ChipRefusals.message(for:bookName:sealed:)` / `DivergeCopy.refusal`
(the diverge arm's `book` is a fresh-loaded `Reading`; staleness is race-only — the recorded
class); the daily door's both roads fork (⌘J's `JournalBooks.shelvingNote` `.bookFinished` arm
reads the designated book's seal; `newEntry`'s daily catch reads the book's — both inside the
runner, which serializes without wrapping a write, so the pool read is legal and the pins exercise
both). The chip's `duplicate()` arm (`MembershipChip.swift:415`, `bookName: nil`) correctly keeps
the default — no reading op on that road throws `lockedReading`. Pins green (two DB-driven + the
pure fork signature, recorded honestly as such). The generic word-table arms
(`ReadingsViewModel.message`'s `.lockedReading`, `ArrivalsCopy.refusal`, `MembershipChoiceCopy
.refusal`'s target arm, `RecoveryActs`) remain unfixed BY DISPOSITION with owner 13i-d — note that
`newEntry`'s NON-daily arm on a sealed book surfaces `lockedReading` through
`ReadingsViewModel.message` (same as pre-fix), i.e. it is inside that recorded class, not a
regression. Disposition sound.

**[MINOR] dead `ReadingsViewModel.delete` — FIXED.** The method retired with a pointing comment
(`ReadingsViewModel.swift:89–93`); compile proves no caller; the one test moved onto the REAL road
— `BookStateDoors.open(.deleteBook)` + `confirm()` — and now also asserts the plain book's ask
(`TimelineAndReadingsTests.swift:105–112`, `pending != nil`), the honest edit, subject preserved.
Ran green.

**[NIT] the stale/over-saying delete receipt — RECORDED stands.** Re-checked: the clean shape is
an op-signature change (`deleteReading` returning the released count) plus a re-word — correctly
out of a fix pass's scope; the 13s owner with the op-return note is the right disposition.

**[NIT] `MembershipDoors.offer` silent on a vanished book — FIXED.** `offer` returns whether it
opened and speaks `readingNotFound`'s shared words on `load`'s nil (`MembershipChoice.swift:311–
330`) — and `load`'s nil is EXACTLY the vanished-reading case (`:337` is its only guard; the post's
absence never nils it), so the chosen words fit the mechanism. The catch arm speaks too. Pin green.

**Verdict line: 5 FIXED · 2 RECORDED-as-disposed — 0 NOT FIXED, 0 REGRESSED.** The fix diff stayed
strictly inside the seven findings' scope (file sweep: 8 production files, all named by the
dispositions; no `Sync/`, no schema, no editor seam). Nothing in it tracks word-level change or
copies text across entities; the one new query is a per-book indexed COUNT
(`idx_reading_post_order`'s leading column) — P1 holds.

---

## NEW FINDINGS (the fix diff reviewed cold)

**[NIT] · `App/Variorum/Variorum/Core/Views/MembershipChoice.swift:290–294 (`addOrOffer`'s doc)` ·
The doc line "True when the note joined; false when the sheet is up instead" is stale since the
offer fix: `addOrOffer` discards `offer`'s new Bool, so false now also covers "the book vanished
and a refusal was spoken — no sheet". · Traced harmless: every host uses false only to skip its own
receipt, and the refusal reaches the status seam either way (the round-1 pin asserts it) — a wrong
"sheet is up" belief drives no act. Doc-only; no pin could ever be red on it. · Fix (one line,
optional — the fix pass or the closeout tidy): "…false when the sheet is up instead, or when the
book vanished and the refusal was spoken."**

No BLOCKER, no MAJOR, no MINOR — round 3 is not earned; the ladder may close at the cross-model
flow's remaining step (the implementer's sanity pass over `5a7c9c1c..63c8f130`, which the close's
commit already queues).

---

## OBLIGATIONS RESTATED (pending at the CLOSEOUT — owners already named in the round-1 record; not
findings, restated so no message drop loses them)

1. QUESTIONS #169: the two ready paragraphs (the archived-arrival spare-it arm WITH P-13ib-U2-2's
   "unless finished meanwhile" exception; the daily Journal's wing / `canonicalJournalEntry` scope).
2. KnownIssues, TWO rows → 13i-d: the daily arm's wing; the generic `lockedReading` word-table arms
   (ReadingsViewModel.message · ArrivalsCopy · MembershipChoiceCopy's target arm · RecoveryActs).
3. ONE 13s copy row: the delete receipt's count/"in the Pool" over-statement + the optional
   "(M of them archived)" suffix on §24's confirm line.
4. Round 1's standing closeout list (its clean-bill item 10): AppSpec §7/§9 contract lines, the
   SyncSpec §12 running-record entry at the deploy, the §4 row-15 text correction, the MOBILE
   PARITY line, the KnownIssues rule-less-gathering flip, and the DerivedData tidy (`13ic-ladder`,
   `13ic-ladder-ios` — this round reused `13ic-ladder`; its red-on-old worktree is already removed).

---

## CLEAN BILL (load-bearing things this round specifically checked and found solid)

1. **The shared-WHERE construction** — one `static let`, both statements read it, placeholders
   align, and no third consumer of `pendingArrivalCount` exists to inherit the new meaning
   unawares; the LINE's display predicate untouched and pinned unchanged on both sides.
2. **Red-on-old by revert** for all four core pins (the project's own verify-by-revert standard),
   with the MAJOR's mechanism demonstrated live on the old tree (act 2 ≠ promise 1).
3. **Act-side consistency of every dismissal door**: lockReading (sealed no-op), sealReading
   (skip-when-finished), sealPreview's locked→0 — count = act at each.
4. **The `newPostInReading` swap's equivalence**: gate set, capacity predicate, outflow, entry_date,
   title, segmentation — all traced equal; the wing and the one-transaction shape are the only
   changes, both the finding's point.
5. **The sealed forks' facts are real facts**: one column on the existing statements, fresh reads
   at the catch arms, shared-words fallbacks where no fact is at hand; `load`'s nil = exactly
   `readingNotFound`'s meaning.
6. **The retirement** is compile-proven callerless and the moved test gained an assertion (the
   plain-book ask) rather than losing its subject.
7. **Suite claims re-run, not trusted**: full core 2008/213 (byte-equal to the close's claim), the
   four Mac pin suites 46/4 with each named pin watched, Arrivals 15/2; zero instances at every
   Mac run; no trailers in the range.
8. **Scope discipline**: the fix diff touches nothing outside the seven dispositions; no `Sync/`,
   schema, custody or editor-seam file; no corpus-proportional cost introduced.

**Round-2 verdict: the fix pass HOLDS — 5/5 fixes verified FIXED with honest pins, both recordings
verified as the right dispositions, one doc-line NIT found, no new BLOCKER/MAJOR. From the
reviewer's side the ladder closes at the cap's discretion once the implementer's sanity pass over
`5a7c9c1c..63c8f130` returns.**
