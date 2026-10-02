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

---

## IMPLEMENTER'S SANITY PASS (over 5a7c9c1c..63c8f130)

*(A fresh Opus implementer session, 2026-10-02. Read in my own context first: CLAUDE.md and its
canon, the round-1 and round-2 records whole, and the plan's §1–§7 with the U2/U3/U4 RECORDs and
the adjudications. Then I read `git diff 5a7c9c1c..63c8f130` whole, cold, and traced every call
site it touches. I edited no source or test file. Round 2's one NIT, `addOrOffer`'s stale doc line,
is skipped as briefed.)*

**Run in this session (`pgrep` showed zero instances before and after every Mac run):**
- Core: `swift test --filter` over PendingArrivalDismissal, MembershipReadersBookScope, BookSeal,
  PoolTuck and OwnershipOperations. Result: **45 tests / 6 suites passed**.
- Mac: `build-for-testing` (DerivedData `13ic-ladder`, the round's folder) **GREEN**. Then
  `test-without-building` over BookStateDoors, MembershipChoice, JournalBooks, TimelineAndReadings,
  BookArrivals and ArrivalArms. Result: **61 tests / 6 suites passed**. Each of the seven named
  pins was confirmed by name in the log.

**What I checked, with a verdict for each:**

1. **The MAJOR (one shared WHERE): CLEAN.**
   - The act did not change. `pendingArrivalRowsWhere` is the old UPDATE's own predicate. Only the
     count moved onto it.
   - The count now equals the act at both dismissal roads. The only Mac call sites of
     `lockReading`/`sealReading` are `BookStateDoors.perform` (:552/:558). `sealPreview` returns 0
     when the book is locked, and `sealReading` skips the dismissal when locked.
   - The count lost two guards it had through `bookArrivals`: the reading must be live, and its
     kind must be book. That drop is the reviewer's recorded choice: count what the act takes, and
     a stray row makes the door ask.
   - The three core pins and the Mac door pin each pin what their names say. The mixed pin is the
     one that proves count = act (cosmetic only: `archivedWaiter` returns an unused `pairID: ""`).
2. **The Pool probe's liveness clause: CLEAN.** It is one clause on the existing primary-key probe,
   and the pin is honest.
   - *Observation, not a concern (it predates the fix pass):* the doc line right below the edited
     HOME paragraph, `ShelfQueries.swift:242–243` ("NO rule shows every note in its wing"), has been
     stale since U1. The code reads `case .malformed, .none: continue // shows nothing` (:306). It
     belongs to the closeout tidy, beside round 2's NIT.
3. **The wing fix (`newEntry`'s non-daily arm → `newPostInReading`): CLEAN.** I traced the old and
   new roads against each other:
   - `createPost` is `insertPost` with wing `''` and the same date validation, and neither road
     registers an undo entry.
   - The gate set, the capacity predicate and the outflow are the same, and the segmentation is
     still set explicitly afterwards. The wing and the single transaction are the only changes.
   - One difference: an invalid day is now refused before the gate. That is unreachable, because
     `entryDay` is always a valid key.
4. **The sealed-named-reopen arms that were FIXED: CLEAN as far as they go.**
   - `sealed` is a real fact: one column on the existing statement, and no other constructor of
     the two structs exists.
   - The chip's three arms pass `book.sealedAt != nil` (`MembershipChip.swift:329/354/393`). The
     collect arm only ever sees a gathering, so its flag is always false, which is harmless.
   - Both daily roads read fresh inside the runner (the U4 `waitingAtDoor` precedent; the runner
     wraps no write).
   - `MembershipDoors.moveIn`'s found-row branch uses the sheet's PREVIEW `sealed`, while
     `BookArrivals` reads fresh. A book sealed after the sheet opened therefore still reads
     "finished — reopen". That is race-only, the stale-preview class round 2 named.
5. **CONCERN 1: the two new fallbacks speak a raw dump, and the record's "shared words" claim is
   false for this error.**
   - The sites: `MembershipChoice.swift:392` (the blocking book is not in the sheet's preview) and
     `BookArrivals.swift:377` (the blocking book cannot be read). Both speak
     `OpsRefusalCopy.message(for: lockedReading)`.
   - Trace: `message(for:)` (`Registry/OpsRefusalCopy.swift:409`) is `macWords(for:) ??
     message(for:roads:.mac)`. `macWords` has no `lockedReading` arm (it falls to `default: nil`,
     :461). The shared `words(for:roads:)` has none either: a grep of both tables for
     `lockedReading` finds nothing. `OperationError` carries no custom description. So
     `OpsRefusalTable.swift:322` returns `"Refused: \(error)"`, which reads **"Refused:
     lockedReading(id: "<uuid>")"**.
   - That is the "Refused: error(…)" class retired at R93 (`MembershipChip.swift:471–472`; "no
     face may speak one", `SeededBookRestore.swift:104/109`). The pre-fix fallback said "“” is
     finished…": worse words, but no dump.
   - Both sites are race-only: the note joined a finished book after the sheet opened, or the
     blocking book died between the refusal and the read. No pin exercises either fallback.
   - The round-1 fix pass ("fall back to the SHARED words") and round 2 ("the operation's shared
     words") both assumed the table has words for this error. It does not. The root is my own
     round-1 note, which proposed "fall back to the shared words in both" without checking the
     table.
   - Suggested shape (the reviewer's call): a book-less sentence, e.g. "One of the books this note
     would leave is finished, so it can't move — copy it in instead." Severity: NIT (race-only),
     but it is the banned class.
6. **CONCERN 2: the widened sealed-names-Reopen class has more call sites than the four arms
   RECORDED for 13i-d. These are record-only; no fix in this phase.**
   - (a) **`Shared/SampleLibrary/SeededBookRestore.swift:128–129`** ("The book is finished —
     reopen it, then restore again.", both platforms). It is directly reachable: seal a seeded
     book (Sherlock, *Encryption Explained* or Jekyll), trash one of its notes, then press Help ▸
     Restore or the phone's restore row. The mint refuses with `lockedReading`, but a sealed book
     renders no Reopen and `unlockReading` refuses `readingSealed`. It is a generic table with no
     book facts, the recorded row's exact class: **add it to that 13i-d KnownIssues row.**
   - (b) **The phone's arms, owned by no one.** F-U2-8, F-U4-6 and PL-43 do not name them.
     - `VariorumMobile/Features/Shell/MobileTodayDoor.swift:65–66`: `.bookFinished` says "reopen it
       from its book details". On a Journal sealed on the Mac and synced, the phone's book-details
       row reads "Reopen" (`MobileBookDetails.swift:343`, driven by `locked`), and
       `unlockReading` refuses with "This book is sealed, so it can't be reopened here." This is
       directly reachable once her deploy window has run.
     - `VariorumMobile/Features/Write/MobileMembership.swift:183–184`: reached through the sheet's
       "diverge" button, which renders on EVERY book row (`:291–293`). On a sealed book it says
       "“X” is finished — reopen it to change what's in it." This is the phone twin of the Mac
       chip's diverge arm that the fix pass fixed. The phone's add filters out locked books
       (`:99–100`), so its add arm is race-only.
     - The phone has no Unseal door, so the honest phone sentence is the mobile catch-up's to
       word: **add these to the closeout's MOBILE PARITY / MobileSoul row.**
7. **The retirement and the silent-offer fix: CLEAN.**
   - The retirement is compile-proven, and the moved CRUD test gained an assertion (the plain
     book asks) without losing its subject.
   - `offer`: `load` returns nil exactly when `Queries.reading` does, and `readingNotFound` has
     real shared words (`OpsRefusalTable.swift:175`).
8. **Test edits and scope: CLEAN.** The one existing test edited (TimelineAndReadings) gained an
   assertion. Every other test change is an addition, and no assertion was weakened. Nothing
   touches `Sync/`, the schema, custody or the editor seam.

SANITY PASS: 2 CONCERNS (for the reviewer's final word)

## REVIEWER'S FINAL WORD ON THE SANITY PASS

*(The reviewer, 2026-10-02 — the cross-model flow's last step, authorized. Each concern re-traced
before the call; the fix red-first by behavioral revert.)*

### CONCERN 1 — the two move-in fallbacks speak the R93-banned dump — **CONFIRMED-FIXED**
- **Final call:** CONFIRMED. The trace re-verified myself before fixing: neither `OpsRefusalCopy.
  macWords` nor the shared `OpsRefusalTable.words` carries a `lockedReading` arm, and
  `OperationError` has no custom description, so `OpsRefusalCopy.message(for:)` falls to
  `OpsRefusalTable.swift:322`'s `"Refused: \(error)"` — watched LIVE on the red run:
  `Refused: lockedReading(id: "00000000-…-0009")`. Round 1's "falls back to the shared words"
  claim was false for this error; the implementer's honesty about its own round-1 note is noted.
- **The fix (sharper than a sentence swap):** `MembershipDoors.moveIn`'s catch now reads the
  blocking book FRESH (the `BookArrivalsModel.moveIn` shape) — so the stale-preview race the
  round-2 verdict had recorded for this arm ALSO closes (a book sealed after the sheet opened now
  reads "sealed — unseal") — and only a book that cannot be read at all falls to the new BOOK-LESS
  sentence `MembershipChoiceCopy.moveRefusedUnnamed` ("A book this note would leave is finished,
  so it can't move — copy it in instead." — TRUE for a sealed blocker too, since Sealed = Finished
  + text immutability, and with no book there is no door to name, so it names the ceremony that
  works). `BookArrivalsModel.moveIn`'s nil-book arm speaks the same sentence. No generic-table
  road remains on either site.
- **Pins:** `MembershipChoiceTests.aBlockingBookTheSheetNeverSawIsNamedFreshNeverDumped` —
  **watched RED by behavioral revert** (the round-1 catch shape restored temporarily; the dump
  spoken live, both assertions failing; the revert marker grepped 0 after restore), green on the
  fix: the staged race (the note joins a third book while the sheet is up; the book is finished)
  now names "Late" with its own road. The LAST RUNG (a blocking book that died between the op's
  refusal and the read) has no deterministic stage — recorded honestly; its words are pinned pure
  (`theUnnamedMoveRefusalIsASentenceNotADump`: a sentence, no dump, true for both blocker states,
  names the ceremony).
- **Changed:** `App/Variorum/Variorum/Core/Views/MembershipChoice.swift` (the sentence + the
  fresh-read catch), `App/Variorum/Variorum/Features/BookView/BookArrivals.swift` (the nil-book
  arm). Suites: MembershipChoice + BookArrivals + ArrivalArms 35/3 green.

### CONCERN 2 — more sealed-named-reopen sites than the four recorded — **CONFIRMED-RECORDED**
- **Final call:** CONFIRMED on all three sites, each re-read in code before the call; record-only,
  exactly as briefed — no phone fix (the mobile catch-up owns the phone's faces, F-U2-8/F-U4-6's
  standing letter).
  - **(a) `App/Variorum/Shared/SampleLibrary/SeededBookRestore.swift:128–129`** — "The book is
    finished — reopen it, then restore again." — a platform-neutral table with no book facts, and
    the restore mint's `lockedReading` is directly reachable on a SEALED sample book (seal → trash
    a note → Help ▸ Restore / the phone's restore row); a sealed book renders no Reopen and
    `unlockReading` refuses. **JOINS the 13i-d KnownIssues row** (the generic `lockedReading`
    word-table arms) at the closeout — the row's list is now: `ReadingsViewModel.message` ·
    `ArrivalsCopy.refusal` · `MembershipChoiceCopy.refusal`'s target arm · `RecoveryActs` ·
    `SeededBookRestore` (both platforms).
  - **(b) the PHONE's two arms** — `VariorumMobile/Features/Shell/MobileTodayDoor.swift:65–66`
    (".bookFinished … reopen it from its book details"; directly reachable once the deploy window
    runs and a synced Journal arrives sealed — the phone's details row says Reopen and the op
    refuses `readingSealed` with the phone's no-verb sentence) and
    `VariorumMobile/Features/Write/MobileMembership.swift:183–184` (the sheet's diverge button on
    every book row — the Mac chip arm's phone twin; the phone's add filters locked books, so its
    add arm is race-only). The phone has no book-Unseal door, so the honest sentence is the mobile
    catch-up's to word. **GO ON THE CLOSEOUT'S MOBILE PARITY / MobileSoul row**, beside F-U4-6's
    list.

### The two doc-only NITs — **FIXED in passing (as briefed)**
- `addOrOffer`'s doc line now says false also covers "the book vanished and the refusal was
  spoken" (round 2's NIT); `ShelfQueries.swift`'s Pool-doc "NO rule shows every note in its wing"
  re-worded to the R-13ic-4 truth (shows NOTHING — stale since U1; the sanity pass's observation).
  Doc-only; no pin possible on either (nothing executable changed).
