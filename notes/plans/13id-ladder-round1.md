# 13i-d LADDER A — ROUND 1 (cold review, `fable-reviewer`, 2026-10-02)

**Subject:** the combined diff `d8f7c452..8b41f667` (47 commits — U1 the Bookcase board · U2 the
union star + the Book Panel · U3 the Collecting doors + grouped-by + filter bar · U4 the (c) arm +
archived members · the architect's F-U2-1 fix). Prompt: `notes/REVIEW_PROMPT.md` VERBATIM.
Anchor: `notes/plans/phase-13i-d-bookcase.md` (the four unit RECORDs + three adjudications); the
plan carries no "Review foci" section — the constitution P-1…P-9 and each unit's evidence row were
checked in its place, named in the clean bill. No editor seam, no custody, no `Sync/`, no schema in
the diff (verified by file list — `Sources/VariorumCore/Persistence/` and `Sync/` untouched).

**STATUS: ROUND 1 COMPLETE — no BLOCKER, no MAJOR; two MINOR, two NIT.**

## FINDINGS (severity-ranked; `[severity] · file:line · what · evidence · fix`)

- **[MINOR] · `App/Variorum/Variorum/Features/Tags/MastheadTagCluster.swift` (`MastheadTagsModel.track`/`adopt`,
  the new model at the file's foot) · the superseded-observation stomp the sibling models guard
  against is unguarded here · **Mechanism (traced):** `track` runs from the cluster's
  `.task(id: postID)`; when the open note changes A→B, SwiftUI cancels A's task and starts B's — but
  a value already yielded to A's loop body still runs `adopt`, which sets `subject = A` and
  `applied = A's tags` UNCONDITIONALLY. Both tasks hop database-queue → MainActor, so A's late adopt
  can land AFTER B's initial adopt; then `tags(for: B)` answers `[]` and B's masthead draws NO tag
  cards (plus a stale taxonomy for the inline field's suggestions) until the next `post_tag`/`tag`
  write anywhere or a reopen. This is exactly the race `NoteMembershipModel.track` guards with
  `guard !Task.isCancelled else { return }` and names as "the `NoteBoxFactsModel` lesson"
  (NoteMembershipModel.swift:71–74), and `BookPanelModel.observe` guards the same way
  (BookPanelModel.swift:352). Same shape at lower consequence in two more of this diff's models:
  `BookArchivedModel.start`/`adopt` (BookArchived.swift:146–164 — a late collapsed-limit delivery
  after the `.task(id: expanded)` restart can transiently blank an expanded line's rows; same
  subject, self-healing on the next delivery) and `BookIndexGroupingModel.track`/`adopt`
  (BookIndexGrouping.swift:293–312 — the partition is guarded downstream by `sectionsRoot`
  (BookIndexView's `groups` checks it), so only `worn`/`live` go transiently stale). ·
  **Pin (bug-class):** the red-on-old pin is the sibling's own shape — drive the model's loop with a
  task cancelled after a delivery is in flight and assert the earlier subject never overwrites the
  later (or, if the interleaving can't be forced deterministically through the real observation,
  pin `adopt`-after-cancellation directly by checking `Task.isCancelled` inside a cancelled task
  context); if the ladder judges no deterministic pin exists, the finding stands on the written
  justification — the guard exists in the two sibling models in this very diff for this named
  reason. · **Fix:** the sibling's one-line guard (`guard !Task.isCancelled else { return }` before
  `adopt`) in the three observation loops.

- **[MINOR] · `Sources/VariorumCore/Queries/ShelfQueries.swift` (`bookcaseArrivalCountsSQL`, ~line
  119, and `bookcaseAggregates`' member-stamp statement) · two board statements aggregate EVERY
  wing's rows while their written contracts say wing-scoped — cost-contract drift, not a bug ·
  **Evidence:** `bookcaseArrivalCountsSQL` is `SELECT reading_id, COUNT(*) FROM reading_post WHERE
  deleted_at IS NULL AND status='arrival' GROUP BY reading_id` — no wing restriction — and it runs
  inside the HELD `bookshelf(db, wingID:)` on every delivery, under a header that sells the listing
  as "one wing's"; the aggregates' member-stamp statement (`FROM reading_post rp JOIN container c …
  GROUP BY rp.reading_id`) aggregates the whole store's memberships while its own doc says "one
  GROUP BY over the wing's book memberships". Contrast `wingArchivedCountsSQL` in the same unit,
  which correctly drives from `reading r WHERE r.wing_id = ?`. Today only Home exists, so nothing
  misbehaves; U5 mints real wings, after which the Home Bookcase's held read re-aggregates every
  other wing's arrival rows per delivery and the one-shot stamps every other wing's memberships —
  work beyond the board's viewport, against the P1 wording this bank itself pinned elsewhere ("the
  work is ∝ the BOOK's live pair rows"). Author-scale, no user-visible failure — no red-on-old pin
  exists for a pure cost claim, so this is labeled honestly as architectural (the traced degradation
  is the statement text vs. the stated contract, and the U5 inheritance). · **Fix:** drive both
  statements from the wing's readings (the `wingArchivedCountsSQL` shape — one extra indexed join),
  or re-word both contracts to say store-wide; the former keeps U5 from inheriting a silent
  cross-wing cost into a HELD read.

- **[NIT] · `App/Variorum/Variorum/Features/Shelf/ShelfView.swift:562 (`bookMenu`) · an EMPTY
  "Move to Shelf ▸" submenu renders in a shelf-less wing on an unshelved book (P-2: a door that can
  never act isn't rendered) · **Evidence:** the `Menu` is unconditional; its items are
  `ForEach(model.shelves)` (none on a fresh store) plus the Unshelved button gated on
  `here != unshelvedKey` (false for an unshelved book) — zero items, the submenu still draws. ·
  **Fix:** gate the `Menu` on `!model.shelves.isEmpty || here != BookcaseBoard.unshelvedKey`.

- **[NIT] · `Sources/VariorumCore/Queries/AppearanceQueries.swift` (`starredReadingRows`' `ORDER BY
  name COLLATE NOCASE, id`) vs `Sources/VariorumCore/Domain/BookcaseOrdering.swift:32`
  (`nameAscending`, `localizedStandardCompare`) · two "A–Z" rules now face the user · **Evidence:**
  the Starred section's column-only tail sorts by SQL NOCASE (so "Book 10" < "Book 2"), while the
  Bookcase's A–Z is Finder's digit-aware compare (so "Book 2" < "Book 10") — two surfaces both
  described as A–Z order the same names differently. Cosmetic; pre-existing collation on the old
  `shelfPins`, newly user-visible because the tail now shows in the Starred section. · **Fix:** sort
  the column-only tail with `BookcaseOrdering.nameAscending` after fetching (the tail is
  author-scale), or leave and note it for 13s.

## DISPOSITION OF THE RECORDS' OWN OPEN THREADS (checked, nothing new owed)

- F-U4-5 (the gathering mint still accepting extents) — adjudicated to U5 rider R1; verified the
  guard is genuinely absent at `createReading` and unreachable from any face in this tree (grepped
  call sites); correctly out of this bank's scope.
- F-U3-4 ("in 2 books" counting a gathering), F-U4-4 (the Library Archived view's undeclared inline
  Unarchive — confirmed undeclared at `ArchivedView.swift`, and `.unarchiveNote` now exists for it),
  F-U4-7 (the untitled-note naming split), the "smart book" spellings in `BookView.bookMetaLine` and
  the mint prompt — all routed to U6 and still true of this tree; no silent regression beyond the
  routing.
- The known sync-stray corner (a dead note's live arrival): the Bookcase badge reads `reading_post`
  alone, so it would count such a stray while the Arrivals line (live-note join) would not list it —
  the same documented "safe direction" class as `pendingArrivalCount`'s (OwnershipQueries.swift
  comment); requires a sync anomaly to exist at all; recorded here, not a finding.

## CLEAN BILL (load-bearing things specifically checked and found solid)

**Checked by running** (`swift test --filter`, 50 tests in 8 suites green in this session):
`GatheringExtentRefusalTests`, `ArchivedMembersTests`, `UnionStarTests`, `BookcaseShelfTests`
(including the revert-verified P1 pin `theHeldSnapshotsRegionIsBlindToAutosave` — read: it asserts
through GRDB's `willTrackRegion` that a `container`/`variant` update never wakes the held Bookcase
while `shelf`/`reading_post` inserts do), `FilterBarCoreTests`, `TagFamilySectionsTests`.

**Checked by reading the code and pins myself:**
- **The union star (ACT 0, the diff's one default's-meaning change):** `writeStar` traced at every
  edge — star/un-star on list-only, column-only, both, dead; the column clears BEFORE the list's
  no-op guard (so un-starring a column-only book works); the cap counts the union; re-star of an
  already-starred book converges the two stores; liveness refuses starring the dead; un-star of the
  dead stays legal; `starredNoteIDs` deliberately reads the list alone (notes never in the column);
  intake fires only on a NEW note star. The read side (`starredReadingRows`/`starred`/`shelfPins`)
  is live-rows-only with the IN-list bounded by the cap. Sync shape: two CAS'd stores (upsert-only
  setting + per-row reading CAS), each converging independently, union read — S1–S5 clean; no
  schema, no `Sync/`. `starLimit` (15) NOT changed by this diff — only its counting base, as ruled.
  The pins (`UnionStarTests`, 9) assert both stores, the cap over the union, pin-is-star both ways,
  and R-13id-5's born-starred mints verbatim.
- **The (c) arm:** `lockReading`'s kind guard answers FIRST (before the sealed no-op); non-nil
  extents refuse before the finished guard and positivity; clearing and `unlockReading` stay legal —
  exactly the F-U3-1 ruling; the pins assert byte-identical rows and an empty outbox on refusal; the
  six legacy fixtures re-staged as raw rows with assertions untouched (read each diff hunk —
  honest, commented in place).
- **Archived members (item 9):** ONE predicate (`archivedMemberJoin` + `archivedMemberRowFilter`),
  book-only (a gathering answers `.none` even with a stray member row — pinned), member-only (an
  archived WAITER is the Arrivals line's — pinned), live-note-only; the rows/count/wing shapes share
  it; EXPLAIN-QUERY-PLAN pins assert SEARCH-not-SCAN on all three statements; `seatArrival` seats an
  archived waiter archived (same row, END, unsectioned, never unarchives — pinned) and intake never
  seats or bells one (event/backfill/catch-up + an un-archived control — pinned);
  `Operations+Intake.swift` and `OwnershipQueries.swift` verified comments-only in the diff.
- **The P-13ib-U2-2 reversal:** the predicate flip is exactly `c.archived_at IS NULL` dropped from
  `bookArrivalSource` plus the `archived` column; the three pin flips (core
  `anArchivedWaiterStaysAtTheDoorMarkedArchived`, `PendingArrivalDismissalTests`' line arm
  `shown == promised`, Mac `finishAsksWhenOnlyAnArchivedNoteWaits`) each flip the OLD assertion with
  the ruling cited in place; the finish confirm's N, the line and the board badge now agree (modulo
  the documented stray class above). The build matches her #169(a) ruling in QUESTIONS word for
  word (re-read there, not from the plan alone).
- **The shelf operations:** tombstone-only delete (books keep dangling pointers = unshelved, §7's
  shelf contract); wing fences on create/move/re-shelve/context-mint; identity-metadata convention
  (no touch/churn; no-op writes nothing); raw UPDATEs still ride the outbox triggers; the shared
  `listPosition` resolver for strip order; `BookcaseOrdering.placementWrites` traced at its edges
  (nil only for a missing anchor, `[]` for a true no-op — so `placeReading`'s refusal mapping is
  sound; the never-placed materialization and the equal-keys strict-below rule check out);
  `ShelfGlyph.normalize` (one grapheme, emoji-presentation and U+FE0F refused) shared by op and
  sheet so the sheet can never offer what the op refuses.
- **The Bookcase board:** `BookcaseBoard` pure and composed from `BookcaseOrdering` (starred float
  outside the position sequence — §20's rule stated and honored); census over the scope; the
  dangling-solo fallback; the context mint's solo rule; §23's details-off hides meta AND arrival
  count through ONE pure value (`BookcaseRowMeta.drawn`); honest counts (`postCount − archived`,
  clamped; "M archived" only when M > 0).
- **The Book Panel:** composes the book view's own planners (`BookStructureModel.postDropPlan` /
  `chapterDropTarget`) and the EXISTING ops only; the click-through is the ascent road (no second
  landing mechanism); the drag token is a private `Transferable` type no other drop site accepts, so
  no membership-creating drag exists and the ownership-consult obligation is satisfied by
  construction (the brief's "missing one is a ladder finding" — none missing); every drag has a
  rendered menu twin gated by the brain (edge moves hidden, P-2); P-13id-U2-8 honored (structure
  doors on a finished book render and speak the op's refusal with the road).
- **Row 104 / row 112:** `NoteMembershipModel` held observation owned by `PostDetailView`, handed to
  chip and panel (one read per note, the composition rule honored — shared home `Core/Views/`);
  `MastheadTagsModel`'s region is `post_tag` + `tag` only (core-pinned region test read); the one
  MINOR above is the missing cancellation guard, not the design.
- **The grouped-by control and the filter bar:** display-only pinned with teeth (reading_section
  count + sync_outbox count + every reading's `updated_at` unchanged — read the assertions); the
  never-chosen path reads NOTHING of the held read (the landing families' fixtures see byte-identical
  rows; the five landing suites verified absent from the diff); the tag-family rule is ONE SQL
  fragment extracted byte-identical with correct placeholder order (the subquery's `?` precedes
  `json_each`'s in statement text — checked); the filter rides `assembleReading(…, filter:)` as a
  task input (the window applies over the narrowed assembly, never post-fetch); the filter never
  writes (outbox-pinned, core and Mac); cleared when the Index leaves; the save door's preview IS
  what the op conjoins (`Queries.filterAssociation` extracted unchanged, called by the op inside its
  transaction — pinned ×4 association shapes).
- **Row 107's faces + the one table:** `BookSettingsFace` + `BookStateDoorSet.rendered` — an open
  gathering renders NO state door, a legacy-finished one Reopen alone; legacy extent fields stay
  only while a value exists (the way out); the two JUSTIFIED FLIPS in `BookStateDoorsTests`
  commented with the ruling; the never-seeded settings sheet writes nothing (`seeded` flag + the
  nil-reading guard in `save()` — the Bookcase road arrives pre-LOADED so empty fields can never
  clear a stored extent).
- **The registry (P-1):** all 22 new acts declared once with doors, verbs, refusal copy; renderers
  declare them (`BookcaseStrip`, `ShelfView`, `BookPanelView`, `PostDetailView`, `BookView`,
  `BookIndexColumn`, `BookSettingsSheet`, `BookFilterBar`, `BookArchivedLine`); the walk's union
  edits are each a commented JUSTIFIED line; view-local looks (solo, №, order, details, grouping,
  filter terms) deliberately not acts — the Library `sort ▾` precedent, consistently applied.
- **The F-U2-1 fix:** the seeder tolerates `starLimitReached` ALONE (every other refusal still
  aborts); the pin (`MobileTutorialStarCapTests.restoreCompletesUnstarredWhenTheCapIsFull`) fills
  the cap exactly and asserts the restore completes whole and unstarred.
- **Bookkeeping:** KnownIssues rows 104/112 struck RESOLVED with dates; rows 13/103/107/109/110
  annotated as the records claim; QUESTIONS #170–#173 carry the provisionals; `.gitignore` gains the
  walk-capture folder; the sidebar/⌘K/navigation renames (Shelf→Bookcase) are the ruled §7 words —
  AppSpec §12's sidebar line still says "Shelf", which is the standing docs-lag-the-UI pattern and
  the closeout's canon delta, not a finding.
- **Commit hygiene:** spot-checked commits across the range — no `Co-Authored-By`/`Claude-Session`
  trailers; per-piece commits with LIVE STATUS flips as the resiliency protocol requires.

**Verified-by-run vs verified-by-read, said honestly:** core claims were verified by running the six
new/changed suites and reading the pins; the Mac counts (732/117) and the walk captures were
verified by reading the test sources, the flip diffs and the records — not by re-running xcodebuild
in this session (the suites were green at the unit closes per the records, whose specific
load-bearing assertions I located and read).
