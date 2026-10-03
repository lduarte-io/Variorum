# 13i-e — LADDER ROUND 1 (cold review, `fable-reviewer`, 2026-10-03)

**Charter:** `notes/REVIEW_PROMPT.md` verbatim, {PHASE} = 13i-e. Diff under review: `git diff
cdc21e1e..HEAD` (tip `e5188e3c` at review start — U0 schema event + U1 op family/daily rulings +
U2 faces/lesson 9, 31 commits, 56 files). Plan anchor: `notes/plans/phase-13i-e-daily-journal.md`.
No "Review foci" section exists in the plan or any brief beside it.

**STATUS: REVIEW COMPLETE.** Verdict: **0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT** (one of the NITs
is a question for the #179 bundle, not a ruling). This is a clean round — the op family, the
daily rulings, the lockstep event and the faces are built to the letter of R-13ie-1…4, her two
riders, and the sitting record §10, with exact pins and honest red-on-old evidence throughout.

## READ LOG (this reviewer, this session — nothing delegated)

- `notes/REVIEW_PROMPT.md` whole; the phase plan whole (1,240 lines: the kickoff rulings
  R-13ie-1…4 + both riders, scope, the EDGES list, the U0/U1/U2 records, both adjudications).
- CLAUDE.md + the auto-loaded canon (CoreDescription, OverallModel, AppSpec).
- **`notes/SyncSpec.md` in full** (the diff touches `Sync/SyncSchema.swift`, a migration, and
  `Server/`), incl. §2 (dumb mirror), §6 (metadata CAS), §7 (the keeper repair + its 13i-a
  marker re-key), §12 (the lockstep grammar + the running record through marker 11).
- KnownIssues row 32 (this phase's owned row) + the file's header rule; QUESTIONS #89 whole,
  #166–#178 headers; the sitting record §10 whole (+ §25's lesson-9 context);
  `notes/plans/pre-13u-memo-daily-journal-identity.md` whole (§0 rulings, §3–§5 edges);
  `notes/plans/13i-e-deploy-checklist.md` whole; `Server/supabase/15_phase13ie_archive.sql`
  whole, shape-compared against the proven `14_phase13i_c_outflow.sql` template.
- The production diff read file-by-file: `Operations+ReadingArchive.swift` (new, whole),
  `Operations+Reading.swift` (the guard + the `addPostToReading` extraction, plus the current
  `updateLiveReading` body for behaviour-preservation), `Operations+Container.swift` (the
  comes-back + the whole `shelveInDailyJournalBook` incl. the outcome mapping and
  `insertDailyJournalBook`), `Operations+Appearance.swift` (ACT 0, both levels),
  `AppearanceQueries.swift` (the derivation + `isDailyJournalMintShape` +
  `dailyJournalBookCandidates` bodies), `IntakeDecision.swift` + `Operations+Intake.swift`
  (the pause + the current `intakeSweep` body), `ReadingAssembly.swift` (the gathering arm,
  `archivedReadings`, `readings` doc), `ShelfQueries.swift` (the choke point, word counts,
  pool tuck, chip, card feed, catalog), `WingQueries.swift` + `wingScope`,
  `Observations.swift`, `Reading.swift`, `OperationError.swift`, `Migrations.swift` (v1_21),
  `SyncSchema.swift` (marker 12 + the PLAIN classification), `VariorumRecord.swift` (the
  date encode/decode strategy — the exact-stamp mechanism's substrate).
- The Mac faces diff whole: `BookStateDoors.swift` (facts/table/copy/acts incl. `perform`'s
  fresh pre-act read), `Capability.swift` + `CapabilityRegistry.swift`, `ArchivedView.swift`
  (+ `ArchivedBooksModel`/`ArchivedBookCopy`), `BookSettingsSheet.swift` (the Archived row,
  the visible pause, the probe), `ShelfView.swift` (the row menu from the table),
  `MembershipChip`, `BookPanelModel/View`, `BookView` (navigator chip), `NotePicker`,
  `ContextBar`, `BookStructureModel.swift` (`JournalBooks.openToday` + the receipt decision),
  `ShellActions`, `LibraryViewModel`, `RootView` (the `.reading` route), `TutorialSeeder`
  (lesson 9's sentence), `BookArchiveCopy.swift`, `OpsRefusalTable`, `RecoveryActs`,
  `WingWords`; the phone diff whole (`MobileShelfFaces/View/ViewModel`, `MobileBookDetails`).
- The test diff whole: `BookArchiveTests.swift` (4 suites), `DailyJournalRulingsTests.swift`
  (5 suites incl. the ACT 0 pin and the two fake-server keeper pins), the four re-premised
  pins (`ThemeAndShelfQueryTests`, `FurnitureConvergenceRepairTests`,
  `MobileStarterJournalTests`, `MobileBooksTests`), `TutorialBooksChapterTests` (the flipped
  lesson-9 pin), `VocabularySweepTests` (the justified edit), `AuthRLSDDLTests` (the file
  list + the regex marker pin at :626–641), `BookArchiveFacesCoreTests`,
  `BookArchiveFacesTests` (structure + key acts), `MobileDailyJournalArchiveTests`.
- Verification runs (foreground, targeted — never the full suite at review start):
  `swift test --filter "DailyJournal|BookArchive|ArchivedIntake|ArchivedGathering|ArchivedListing|ArchivedJournalKeeper"`
  → **"✔ Test run with 53 tests in 17 suites passed"** on the tip.
- Commit-trailer sweep over `cdc21e1e..HEAD`: zero `Co-Authored-By`/`Claude-Session` lines.

## FINDINGS (severity-ranked)

### F-R1-1 · MINOR · `Sources/VariorumCore/Operations/Operations+Appearance.swift:421` · the db-level designation guard checks KIND but not LIVENESS, so its own "any future db-level caller" promise is half-kept

**What.** ACT 0's guard in the db-level `setDailyJournalBook(_ db:_:)` reads
`SELECT kind FROM reading WHERE id = ?` with no `deleted_at IS NULL` — a TOMBSTONED book's row
passes it. The write that follows is the marker move: UPDATE 1 demotes EVERY live `'daily'`
bearer to the trait (`WHERE profile='daily' AND id <> ? AND deleted_at IS NULL`); UPDATE 2
stamps the designee only `WHERE … deleted_at IS NULL` — a dead designee is NOT stamped; the
cache is then written with the dead id.

**Mechanism (inputs → wrong state).** A db-level call with a tombstoned book id ⇒ the live
daily Journal is demoted to the trait, NO live marker-bearer remains, and
`daily_journal_book` names a dead book ⇒ `Queries.dailyJournalBookID` (the derivation) reads
nil ⇒ the next ⌘J mints a FRESH Journal beside the demoted original — exactly the F-U1-2
double-mint class ACT 0 was ruled to close, through the liveness door instead of the kind
door. The doc comment above the guard states the promise explicitly: *"a NON-BOOK refuses …
ahead of every write — so neither the public door nor any future db-level caller can demote
the live daily book"* — the kind half is enforced at the db level, the liveness half is not.

**Reachability, honestly.** NOT reachable today: the public door
(`setDailyJournalBook(_ readingID:)`) runs `liveReading` first (throws `readingNotFound` on a
dead row, in the same write transaction — no race window), and the only other db-level caller
(`insertDailyJournalBook`) passes the row it just inserted. This is a latent hazard at an
internal seam, the same seam ACT 0 itself chose to harden — hence MINOR, not MAJOR.

**Pin (red-on-old).** A test driving the internal seam (the suites already construct
`Operations` and the db-level twins are `@testable`-visible):
`database.write { try ops.setDailyJournalBook(db, deadBookID) }` after tombstoning a book
raw (the `tombstoneAsAnOlderBuildWould` fixture) — expect a refusal; on today's tree there is
no throw, the live Journal's profile reads `'journal'` after the call, and
`dailyJournalBookID` reads nil. Red on old at the traced mechanism.

**Fix.** One clause: the guard's SELECT gains `AND deleted_at IS NULL` (a missing/dead row
then refuses — `wrongReadingKind` as today for shape symmetry, or `readingNotFound` if the
honest word is preferred; either is fine since no live caller can reach it).

### F-R1-2 · NIT · `Sources/VariorumCore/Operations/Operations+Appearance.swift:421` · the guard is one ~175-character line

Everything else in the file wraps at the repo's width; the one load-bearing guard ACT 0 added
is the file's longest line. Wrap it (guard let + two lines). Style only.

### F-R1-3 · NIT (a QUESTION for the #179 bundle, not a ruling) · Quicknotes and the archive — should the quicknote door have a comes-back of its own?

Traced, all shipped-coherent, no wrong state: archiving the designated QUICKNOTES book (the
walk did exactly this — the U2 record's F-U2-10 residue line) leaves the quicknote door
filing into it indefinitely — the designation (`designatedBookID(db, key: "quicknote_book")`)
reads a live-archived book, the filing is an EXPLICIT add (lands, her R-13ie-4 amendment),
the notes stay live in the Library, the born-starred book stays in Starred, and the book
itself sits under Archived with no comes-back — the comes-back is §10's and keyed to the
daily marker alone (`shelveInDailyJournalBook`), by the ruling's own words ("it returns when
a day arrives"). Whether Quicknotes should mirror it (un-archive on the next quick note) is
UNDEFINED product behavior — the sitting ruled the daily Journal only — so this is a
question for her bundle, not a finding against the build. One line to add if she wants it
(the shelving-door pattern is already shared).

## DISPOSITION OF THE ITEMS ROUTED TO THIS LADDER'S EYE (the adjudications' explicit sends)

- **F-U1-3 — the four re-premised pins keep their intent: CONFIRMED, all four.**
  (1) `ThemeAndShelfQueryTests.dailyJournalBookDanglesToNil` — still pins "a dead designated
  book reads as none"; the dead state now arrives as the raw row write a pre-guard build's
  delete is, and the pin additionally asserts the door refuses first (strengthened, not
  weakened). (2) `JournalKeeperRepairTests.aDanglingDesignationAdoptsTheArrivingJournal` —
  the subject (the dangling designation adopting the arriving Journal) is byte-unchanged
  after the fixture swap; the raw tombstone fires the same cascade triggers and outbox
  capture the old op did. (3) `MobileStarterJournalTests.aDeletedStarterJournalNeverComesBack`
  — the seeder clause under test is unchanged; the starter IS the daily Journal, so the raw
  write is the only honest road to the premise. (4)
  `MobileBooksTests.designateDailyIsTheRoadOutOfTheTodayRefusals` — the gathering-as-daily
  premise is genuinely retired by the derivation + ACT 0 (a gathering can no longer BE a
  designation), and the FINISHED daily book is a real, reachable refusal of the same Today
  class; both asserted halves (a phone road named, never "Mac"; designate-daily heals) keep
  their subject. The now-unreachable `.wrongKind` Today wording (F-U1-2's "harmless dead
  copy") is correctly left in place.
- **The one justified test edit (`VocabularySweepTests.theArchivedViewDeclaresItsUnarchive`)
  — CONFIRMED justified:** the pin's own subject (the note row's Unarchive is declared) is
  asserted exactly as before; the expected set grew by the two acts the view genuinely
  renders now, and the registry walk (`CapabilityRegistryTests`, batch B) holds the
  declared ⇔ rendered contract around it.
- **F-U2-2 (the "+ new entry" inside an archived Journal does not bring it back) — the
  architect's leave-as-built ruling is SOUND against the record:** the comes-back's ruled
  wording binds the TODAY doors; `BookStructureModel.newEntry`'s daily branch files through
  `addPostToReading` — an explicit add, which her amendment makes land WITHOUT un-archiving
  as the general rule. The counter-argument is recorded in the adjudication; PROVISIONAL at
  #179 is the right disposition. Nothing to add.

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The lockstep event, end to end (SyncSpec read in full).** v1_21 is additive/nullable, no
   data migration, schema-first commit (`b2e8b1c2`) BEFORE any consuming code;
   `SyncSchema.lockstepVersion` 12 with the honest why (a marker-11 whole-row CAS push would
   null the column); `archived_at` classified PLAIN in the reading table's column list (the
   `container.archived_at` class — the PRAGMA completeness walk would fail the build on an
   unclassified column, and the full core suite is green); `15_phase13ie_archive.sql` follows
   the proven 14-template exactly (re-run guard with override + prerequisite arms, ONE
   transaction, marker LAST, read-only verification tail); `AuthRLSDDLTests.lockstepFiles`
   carries the file and the regex marker pin equates the LAST artifact's marker with
   `SyncSchema.lockstepVersion` (12 ≡ 12); the deploy checklist is the 13i-c shape with the
   F-U1-1 mirror-side exposure probe adopted (read-only, `reading.profile`/`setting.value`
   both PLAIN there), the A1 rail, the stranding rule (install held behind the mirror), and
   the §12 running-record entry deliberately deferred to the window — the grammar's own
   order, not an omission. **No new §7 repair is needed and none was written:** archive/
   unarchive races are plain metadata CAS (server-wins), the standing class; the keeper
   repair's candidate set is live-rows-only so an archived Journal converges exactly as a
   visible one — pinned headless both ways (`ArchivedJournalKeeperTests`, keeper-archived and
   loser-archived arms, against the fake server).
2. **The exact-stamp mechanism is byte-stable.** `archived_at` strings are written through
   the one `variorumISO8601` formatter (millisecond precision; `VariorumRecord`'s encode AND
   decode strategy), so parse→re-serialize round-trips identically and the
   archive-with-notes / unarchive stamp-join (`c.archived_at = ?`) can never miss its own
   rows — locally or across devices (the strings travel verbatim, PLAIN). The
   individually-archived member (own stamp, stays), the left-the-book member, and the
   version fence (born-archived ⇒ never re-stamped, `archived_at == created_at` preserved)
   are each pinned with exact row assertions.
3. **The op family.** One stamp per act; refusals typed and honest
   (`readingAlreadyArchived`/`readingNotArchived` — and a re-stamp would genuinely orphan the
   exact-stamp key, so the refusal is load-bearing, not taste); arrivals never taken (not
   membership); sealed members archive (AppSpec §9's seal letter); no tombstone anywhere
   (archive is visibility, never lifecycle); no undo entry and the redo future kept (pinned
   with a real stranded-redo fixture); the confirm's N and the act's set are ONE SQL fragment
   (`archiveWithNotesSource`) read by both — the 13i-c ladder's discipline, pinned
   (`theConfirmsNIsExactlyTheSetTheActArchives`, incl. the delete-N contrast).
4. **The pause lives in the one table and nowhere else.** `IntakeDecision.intakeRuns` gains
   `!archived` (defaulted false so every pre-13i-e fact-builder reads unchanged);
   `livingBooks` carries the same truth as the cheap SQL pre-filter; the catch-up after
   unarchive runs on the post-clear struct (traced through `intakeSweep` → `intakeBookFacts`
   over the PASSED reading) and bells, never seats — every occasion pinned (event, backfill,
   rule-edit, un-finish, restore), plus R4's extra revert proving the pause pins bite.
5. **Explicit adds stay open — no `readingArchived` refusal exists anywhere** (grep-verified:
   the error enum gains exactly the three new cases). All eight hand doors pinned landing on
   an archived book (`assertReadingAcceptsPosts`, add, mint-inside, seatArrival of a
   pre-archive waiter, move-in with severance, copy-in, the outflow riding the add).
6. **The archived gathering answers empty at EVERY rule consumer — I enumerated the
   consumers myself** (`grep RuleGrammar.read` over Sources): the assembly arm (early
   `return []` — every through-the-assembly reader follows by construction), and the four
   outside-the-assembly readers each handled (`notePoolListingSQL` re-classing the notes
   loose, `readingsContaining`'s gathering leg, `smartBookMembership`, `bookWordCounts`) —
   all five pinned in ONE before/during/after state test. The remaining consumers are
   correct untouched: `ruleTagPaths` (display, consumed by shelf faces an archived book never
   reaches), `Operations+StarredGathering` (the seeded-gathering ensure treats a
   live-archived copy as PRESENT — never re-mints, the P-13ie-U1-7 seeder letter),
   `Operations+SmartCollect` (an explicit door, open by the amendment),
   `Operations+ReadingFilter` (the mint), intake (gated), the rule editor (domain), the wing
   move preview (deliberately stricter-safe, recorded).
7. **The Bookcase choke point and the listings.** `bookcaseReadings` excludes archived on
   BOTH arms (Mac wing-scoped + the phone's all-wings) so `bookshelf`/`bookcase`/
   `bookcaseAggregates`/the census/strip counts follow by construction; the pickers KEEP
   archived (her second rider — marked, never refused; the seeders' existence reads must see
   them); `archivedReadings` is wing-scoped through the shared `wingScope` (dangling wing =
   Home, verified against the helper's SQL), newest-first, windowed with a truncation line;
   the ⌘K catalog's book arm drops archived exactly as the note arm always has; E13's name
   guard skips archived ("archived/deleted books don't count" — her own words, finally with
   something to bite); `bookWordCounts`' ONLY production consumer is the shelf aggregate
   (grep-verified), so dropping archived readings there is coherent and costs nothing a face
   shows. Membership stays a FACT everywhere (Pool exclusion, `readingsContaining`,
   ownership enforcement from an archived owned book — pinned).
8. **The daily rulings.** The derivation reads `dailyJournalBookCandidates.first` — the
   keeper repair's OWN pick through the ONE predicate (`isDailyJournalMintShape`, shared
   with `Sync/Repairs.swift` unchanged — the no-drift seam intact); the setting is written
   as a cache byte-unchanged and read by nothing but Quicknotes' sibling key; the guard sits
   INSIDE both delete transactions, keyed on the marker (rename-proof, setting-proof —
   pinned three ways incl. the marker-move-moves-the-protection case); the comes-back is ONE
   write — un-archive body first (exact-stamp entries return, catch-up bells), the filing
   under a savepoint whose OperationError refusal is caught-and-returned so the un-archive
   COMMITS (P-13ie-U1-12's ruled reading: the day arrived) while a non-OperationError rolls
   back whole; the refusal re-throws into the SHIPPED outcome mapping (bookFinished /
   bookAtCapacity / wrongKind / the ownership bell / refused — all arms traced); a decided
   pair brings nothing back; a dead Journal mints fresh. `DailyBookShelving` unchanged
   (F-U1-6's ruling honored: the receipt is decided at the doors from before/after reads —
   same-id + archived→live, never a fresh mint — and spoken on BOTH Mac roads as
   receipt-kind).
9. **ACT 0.** The guard at the db level ahead of every write; the traced double-mint
   mechanism pinned with a natural red AND a behavioural revert (7 issues each, the control
   green both sides — the record's counts match the test's assertions one for one). The one
   liveness gap at the same seam is F-R1-1 above (latent, MINOR).
10. **The faces honor P-1/P-2/P-3.** WHICH of Archive·Unarchive·Delete renders is DATA
    (`BookArchiveDoorSet` over facts built on `Queries.isDailyJournalMintShape` — the SAME
    predicate the op guard keys on, so no face can offer a delete the op refuses: P-2 by
    shared predicate, not by parallel copy); the two acts declared in the registry and every
    renderer's `surfaceCapabilities` updated (ShelfView context menu, the sheet, the
    Archived surface) with the registry walk green in batch B; the Archived surface's books
    group holds a `reading`-only observation (autosave never wakes it) + one-shot member
    counts (the 13i-d archived-counts precedent), windowed at 200 with a visible truncation
    marker; the W-1 receipt host closes the row-103 class on this surface; the daily
    Journal's Delete is REPLACED by Archive on the Mac (table-driven) and on the phone's two
    doors (the shared predicate + shared words through `OpsRefusalTable`/`DeletionRefusal`,
    both arms reading `BookArchiveCopy.cannotDeleteDailyJournal`); the "(archived)" mark is
    ONE shared copy symbol consumed by chip rows/label/Add menu, Book Panel, context bar,
    picker annotation; the visible pause leads the Collecting section with the ruled words
    (book-with-rule / gathering / nothing on a rule-less book); the navigator chip says
    "archived" on a book opened from Archived. The raw `ReadingsViewModel`/`Queries.readings`
    consumers were traced: the Mac ones all mark or are op-only; the phone's unmarked
    membership list falls inside F-U2-6's adopted MobileSoul enumeration (the marks are the
    catch-up's, `BookArchiveCopy` shared and ready).
11. **Lesson 9 (P-6).** The seeder's sentence is §10's wording verbatim; the flipped pin
    asserts presence AND executes the behaviour whole (archive → off the Bookcase → delete
    refuses in the table's words AND no face draws the door → Today's Entry → the SAME book
    back, live, entry filed, receipt spoken) — naturally red on the pre-sentence tree per
    the record. The re-seed consequence correctly held for her Restore Tutorial press.
12. **Verification on the tip:** the 53 new/touched core tests re-run green by this reviewer
    (17 suites, incl. both fake-server keeper pins). The Mac/phone batch counts (97/13 ·
    1396/214 · 99/8 · 70/16) were not re-executed here — their test code was read, the
    architect's spot-checks stand, and nothing in the read contradicts them.
13. **Process:** fences empty (`Sync/` diff = `SyncSchema.swift` alone, the architect's U0
    under the standing rider; `Persistence/` = v1_21 alone; editor seam untouched — TEXTKIT2
    read not required); commit-per-piece with LIVE STATUS flipped per commit; reverts
    announced before, verified clean after; zero attribution trailers on all 31 commits;
    KnownIssues row 32 and QUESTIONS #89(b)/#179 are ledger row 7's (the closeout — not yet
    due at this round, correctly not pre-written).

## WHAT THIS ROUND ASKS OF THE FLOW

Under the cross-model flow, F-R1-1 (+ the F-R1-2 style line beside it) goes to the implementer
verbatim for agree/dispute; this reviewer makes the final call and implements its confirmed
fix with the red-on-old pin named above. F-R1-3 is a question for the #179 bundle (the
closeout routes it), not a fix. No round-3 trigger exists in this round's findings.
