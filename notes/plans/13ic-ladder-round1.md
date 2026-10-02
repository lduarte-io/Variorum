# 13i-c — LADDER ROUND 1 (cold review, `fable-reviewer`, 2026-10-01)

**Scope reviewed:** the combined diff `ca3b8a85..e34922f1` (U1 Fable · U2–U4 Opus · both
adjudications), read against the plan `notes/plans/phase-13i-c-owned-finished-sealed.md` (its §1–§11
and the four unit RECORDs), the sitting record §1/§2/§5/§6/§18/§20/§24/§25, CLAUDE.md + its canon,
`notes/SyncSpec.md` IN FULL (the diff carries a §12 lockstep: `v1_20`, marker 10→11,
`Server/supabase/14_phase13i_c_outflow.sql`, the serializer's one PLAIN column), KnownIssues and
QUESTIONS. No "Review foci" section exists in the plan or beside it (checked). TEXTKIT2_NOTES not
required — the diff touches no editor-seam file (verified against the diff's file list).

**Verification run by this review (zero-instance window confirmed by `pgrep` before every Mac run):**
full core `swift test` — **2004 tests / 212 suites passed** (1 standing env-gated skip), matching the
records byte-for-byte; targeted re-runs of `Phase13icOutflowTests` (13), the ownership suites
(OwnershipSoak/Door/Decision/MembershipReadersBookScope — 21), the seal/ownership-op suites
(BookSeal/OwnershipOperations/OwnershipBookDoors/OwnershipHideAndBadges/OwnershipRitual/
SealedBookMemberUnlock — 55), AuthRLSDDL + Phase13iRepair (98), the touched regression suites (115);
Mac `build-for-testing` + the thirteen new/central face suites — **114 tests / 13 suites passed** —
and the full tutorial spine — **79 tests / 11 suites passed** (P-6). The walk captures exist on disk
(u3: 50 · u4: 53). No `Co-Authored-By`/`Claude-Session` trailer anywhere in the range; tree clean.

---

## FINDINGS (severity-ranked; format: `[severity] · file:line · what · evidence · fix`)

**[MAJOR] · `Sources/VariorumCore/Queries/OwnershipQueries.swift:267` (`pendingArrivalCount`, via
`ArrivalQueries.swift:116–123`) vs `Sources/VariorumCore/Operations/Operations+Intake.swift:491–498`
(`dismissPendingArrivals`) · The finish/seal confirm's "N waiting at the door will be dismissed"
counts a DIFFERENT set than the act dismisses: the count predicate (`bookArrivals`) excludes
arrivals whose note is ARCHIVED (`c.archived_at IS NULL`, P-13ib-U2-2's display rule), while
`lockReading`'s and `sealReading`'s dismissal tombstones EVERY live arrival row of the book. ·
Mechanism: a living book (dial `arrivals`) bells a matching note → a live arrival row; she archives
the note (the row "stands untouched" and should "return on unarchive" — P-13ib-U2-2's letter); she
presses Finish → `BookStateDoors.open(.finishBook)` (`BookStateDoors.swift:466–474`) reads
`pendingArrivalCount` = 0 → `finishNeedsConfirm` false → the door ACTS WITHOUT ASKING →
`dismissPendingArrivals` tombstones the archived note's arrival as a PERMANENT dismissal
(tombstone-means-decided; it returns only on a fresh tagging act — §24's recorded consequence). The
pair is decided silently, uncounted, unconfirmed; with a mix of archived and unarchived waiters the
§24 line under-counts. This phase's own stated discipline ("the door can never promise a different
number than the act takes" — `liveMemberNoteCount`'s doc; `pendingArrivalCount`'s doc claims the
confirm "can never disagree" with the line, but the ACT is the contract) is broken at this one door.
`sealPreview` (`OwnershipQueries.swift:253–261`) carries the same count into the seal confirm. ·
Red-on-old pin: one live arrival whose note is archived → expect `Queries.pendingArrivalCount == 1`
(fails on this tree: reads 0). Fix shape (the spec-safe arm, no new ruling needed): count the
DISMISSAL's own set — every live `status='arrival'` row of the book, archived notes included (§24
says "waiting at the door", and the archived note IS waiting; the Arrivals LINE keeps its display
filter untouched). If the implementer disputes toward "the finish should SPARE an archived note's
arrival instead", that is undefined product behavior → `notes/QUESTIONS.md`, not a ruling here.**

**[MINOR] · `App/Variorum/Variorum/Features/BookView/BookStructureModel.swift:591–637` (`newEntry`,
both arms) + `Sources/VariorumCore/Operations/Operations+Container.swift:52/68`
(`createOrOpenJournalEntry` → `insertPost` with the default wing `''`) · The F-5 wing class
(R-13ic-2's "one-line correctness fix") was fixed at `newPostInReading`
(`Operations+Reading.swift:669–672`) but not at its sibling mint-into-a-book roads: `newEntry`'s
non-daily arm mints via `createPost` (wing `''`) then members the post into `readingID`'s book, and
the daily arm's `createOrOpenJournalEntry` mints the entry in wing `''` before shelving it into the
designated daily book — so a note born inside a non-Home book (or filed into a non-Home daily
Journal) would live in the WRONG WING (§9's total isolation: a book never spans wings). · Mechanism:
set a book's `wing_id = 'W'` (today only reachable by direct row write — no wing-mint door exists
until 13i-d, the same latency the phase itself accepted when it fixed `copyPost`'s wing
"unreachable until 13i-d; pinned"), call the arm → the minted post's `wingId == ''` while its
membership sits in W's book; W's search/tag listings then miss the note the book shows. ·
Red-on-old pin (headless, the `copyPost` wing pin's shape): a book with `wing_id='W'` →
`createOrOpenJournalEntry`+`shelveInDailyJournalBook` (and the `newEntry` non-daily shape:
`assertReadingAcceptsPosts` → `createPost` → `addPostToReading`) → expect the post's wing == the
book's. Fix: thread the book's wing through these two mint roads exactly as `newPostInReading`
does (`insertPost(wingId:)` exists already). `Operations+Import.swift:64` is deliberately NOT in
scope (the Imports wing is 13h/13i-d's recorded lean).**

**[MINOR] · `Sources/VariorumCore/Queries/ShelfQueries.swift:326–331` (`poolListing`'s bookless
probe) · The third of the "three readers ruled together" (13i-b F-R1-7) gained `r.kind='book'`
WITHOUT the `r.deleted_at IS NULL` liveness check its two siblings carry (`membershipElsewhere` —
`Operations+Intake.swift:282–284`; `noteMemberships` — `OwnershipQueries.swift:57–59`;
`readingsContaining` — `ShelfQueries.swift:351–356`): a LIVE member row under a TOMBSTONED book
counts as "a home" for the Pool exclusion, so the note would vanish from the Pool while no book
lists it. · Mechanism (reachability caveat, stated honestly): no LOCAL door produces that state
(`restoreContainer` revives into live readings only; `revertDiverge` guards the reading live —
checked), and the apply-path's cascade/orphan repair closes it in-transaction — it exists only as a
sync-stray/mid-batch tolerance state (SyncSpec §5's "render gaps, never crash" class), seedable
directly. · Red-on-old pin: insert a live `reading_post` member row under a tombstoned book →
expect the note in `poolListing` (fails on this tree: excluded). Fix: add
`AND r.deleted_at IS NULL` to the probe, matching the siblings.**

**[MINOR] · `App/Variorum/Variorum/Core/Views/MembershipChoice.swift:113–120 (`moveBlocked`),
163–167 (`moveRefusedFinished`), 194–199 (`moveBlockedBy` reads `finished` only)` +
`OwnershipQueries.swift:146–158` (`SeveredMembership` carries no `sealed` fact) +
`BookArrivals.swift` (`moveIn`'s catch: `name ?? ""`) · A SEALED book among the memberships Move In
would sever reads "“X” is finished, so the note can't leave it — … reopen “X” first" — but Reopen
REFUSES on a sealed book (`readingSealed`; the one door is Unseal, which reopens it too, R-13ic-3),
so the sentence names a road that cannot act — the P-2 class in copy form. Reachable today: seal
book S (members forked sole), hand-add S's sealed member to plain book B (legal — S is not owned),
then Move In to an owned book → the sheet's blocked line names Reopen on S. `BookStateCopy.refusal`
(`BookStateDoors.swift:396–404`) already gets this right (sealed → "unseal it first (that reopens
it too)") — the choice sheet and the arrivals arm don't. Secondary: `BookArrivalsModel.moveIn`'s
catch falls back to `""` → "“” is finished…" when the blocking book isn't found. ·
Red-on-old sentence pin: a sealed blocking book → expect the blocked line to name Unseal (fails on
this tree: names Reopen). Fix: carry `sealed` on `SeveredMembership` (r.sealed_at is one column
away) and fork the sentence; default the missing-name fallback to the shared words.**

**[MINOR] · `App/Variorum/Variorum/Features/Readings/ReadingsViewModel.swift:89` (`delete`) · Dead
production code: the shelf's Delete Book routes through `BookStateDoors.open(.deleteBook)` since
U4; `ReadingsViewModel.delete` has exactly one caller left and it is a test
(`TimelineAndReadingsTests.swift:105`). Already adjudicated (F-U4-8 → "the ladder's fix pass
retires it"). · Confirmed by caller sweep across `App/Variorum/Variorum`. · Fix: retire the method;
move the test onto `deleteReading` through the state doors or the op directly. (Cleanliness — no
pin owed; this is the adjudicated retirement, not a bug.)**

**[NIT] · `App/Variorum/Variorum/Features/Readings/BookStateDoors.swift:539–560`
(`perform(.deleteBook)`) · The book-only delete's receipt count (`released`) and the book's name
are read in separate reads BEFORE the act inside the same runner closure — a membership change in
the window makes the receipt's "its N notes are in the Pool now" stale (receipt-level only; the op
and the confirm's own N are safe). · Traced read-then-act in `perform`. · Fix (optional): have
`deleteReading` return the released member count the way `deleteReadingWithNotes` returns its
notes, or read the count in the same write.**

**[NIT] · `App/Variorum/Variorum/Core/Views/MembershipChoice.swift:299–309` (`MembershipDoors.offer`)
· When `load` returns nil (the book vanished between the refusal and the offer) the door goes
SILENT — `pending` stays nil, no sheet, no refusal (P-2 would want the operation's words). ·
Traced: `load` returns `MembershipChoice?`; nil assigns nothing and says nothing. · Fix (optional):
speak `readingNotFound`'s words when the item cannot be built.**

No BLOCKER. Nothing in the diff tracks word-level change; the only cross-entity text copies are the
ruled ceremony-copy class (lineage-edged, §2's "copies are always ceremonies"); no operation's cost
scales with the corpus (every new query traced ∝ one note's rows, one book's rows, or the page).

---

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The lockstep event (SyncSpec §12, marker 10→11), read against SyncSpec in full.** `v1_20`:
   additive `ALTER TABLE` only; the carry-over touches LIVE rows only (`json_array(auto_tag_id)`,
   dead rows untouched — no tombstone repush); the rule-less sweep is an ordinary tombstone on a
   real clock (S2; the Trash's window reads it; malformed rules and rule-less BOOKS untouched);
   both run with the outbox triggers live so every touched row pushes after the window.
   `SyncSchema.lockstepVersion = 11` and `auto_tag_ids` classified PLAIN (ids-only — the class of
   the column it replaces; the ENCRYPTED-like-`query_spec` alternative is recorded as PROVISIONAL
   P-13ic-8 and surfaces in the deploy checklist's pre-deploy summary, the honest exit). The mirror
   artifact: dumb nullable column, NO constraint, NO RPC/registry change needed (allowlists are
   table-level; the column is plain), marker bump the last statement inside the transaction, re-run
   guard byte-shaped like the PROVEN 13i-a artifact, read-only verify tail; registered in
   `AuthRLSDDLTests.lockstepFiles` with the marker-equality pin (ran green). The apply-side
   null-normalize (an old mirror row reads as no outflow) and the two-device server-wins CAS
   convergence are pinned and green. NO new §7 repair is needed (plain metadata CAS) — correct.
   The deploy checklist mirrors the 13i-a window shape, holds the `/Applications` refresh behind
   the window, and the dev store stays fenced.
2. **The retirement discipline.** `auto_tag_id` retired-as-read with a SOURCE-WALK pin (no
   production read outside model/migration/serializer — ran green); the `setReadingAutoTag`
   forwarder retired with its own walk pin; `Reading.encodeOutflow` is the one spelling of "no
   outflow" (dedupe, order kept, empty→NULL) so no-op guards compare honestly; `decodeOutflow`
   fails closed on malformed bytes.
3. **R-13ic-4 end-to-end.** The op guards (mint, rule write, `saveFilterAsGathering`'s empty-spec
   guard — a book's clear stays the kill switch); EVERY gathering reader flipped to
   no-rule-shows-nothing (assembly, `bookshelf`, the Pool tuck, `readingsContaining`, the page
   listing, the collect door's refusal); the honest pin flips each commented with the superseded
   letter; the two seeders mint with rules (pinned).
4. **The ownership core.** `Domain/OwnershipDecision` is genuinely the ONE table (the consult at
   `addPostToReading` AND `seatArrival`, both after the capacity gate so no door offers a ceremony
   a full book refuses — P-2); intake's owned arms agree cell-for-cell (pinned); the three
   membership readers gained `kind='book'` together with red-on-old pins. COPY IN / MOVE IN:
   membership inserted FIRST then the outflow (so the pair is decided before any tag fires intake
   elsewhere — and intake's owned arms bell rather than seat after an owned claim, so a ceremony's
   own auto-tag can't break exclusivity in-transaction); the answering arms tombstone the arrival
   as the ruled decision classes (member-class = permanent, P-13ic-3); Move In's severed set is
   exactly `moveInPreview`'s rows, the finished-book guard names THAT book, and the daily Journal
   severs like any other (§10). `forkInPlace` takes the exact slot (position AND chapter) and
   tombstones the original member-class. The revival pass (`enforceOwnershipAfterRevival`) runs at
   all six revival doors — including `revertDiverge`, the plan-list gap U2 itself caught (F-U2-4)
   — ranked `created_at, id` (P-13ic-9, R2's shape; the SHIPPED R2 repair in `Sync/Repairs.swift`
   untouched, as the plan requires), writes through live triggers (outbox captured), and is
   idempotent by construction.
5. **The seal family (R-13ic-3, §5, §24).** `sealReading`: forks → finish + dismissal (skipped on
   an already-finished book) → `sealed_at` → every member sealed on the EXACT stamp through the
   shared `sealPost` body with the dirty-buffer insurance; an independently-sealed member keeps its
   stamp. `unsealReading`: exact-stamp members unseal, the book reopens in one step, the catch-up
   fires on the now-open row. The contradiction guards (`unlockReading` → `readingSealed`;
   `lockReading` no-op on sealed) and the adjudicated `noteInSealedBook` on `unlockPost` (live
   sealed book, member rows only — a Trash'd book suspends its promise; `unsealReading` bypasses
   via the shared body, no circularity). The soak-found sealed-revival breach is closed in BOTH
   revival roads (`restoreContainer`'s locked-gate parameter, `restoreReading`'s `sealedOnly` arm)
   with red-first pins (P-13ic-U2-6).
6. **Delete · duplicate · the Trash (§6, §18.3).** `deleteReadingWithNotes`: ONE stamp through the
   shared `tombstoneNoteFamily` (versions ride), then the book (the cascade stamps the rest);
   gathering-only refusal op-side with the door discipline recorded (F-U2-7) and BUILT (the owned
   book's two-choice confirm is the only host of the alternate; the keyboard default is the SAFE
   choice). `restoreReading` returns WHOLE in the right order (stamp-matched notes first through
   `restoreNoteFamily`, then memberships, then the revival pass, then the catch-up);
   `trashBookNoteCount` is stamp-keyed and read BEFORE the flip in `TrashPutBack`.
   `duplicateReading` copies configuration never state, re-points chapters, never copies arrivals,
   refuses shallow-on-owned, demotes the daily marker to the trait (P-13ic-U2-5); E13's name guard
   runs in the SAME runner closure as the op.
7. **Hide-owned + the badges (§6).** ONE argument-free SQL fragment composed by the assembly, the
   chip's and the page's gathering legs, and `taggedPostItems` (global default only); the Library
   exempt (R32 — pinned); the two settings are the `arrival_flash` class exactly (synced,
   not-seeded, read-time defaults SHOW/ON, fail toward her default on unrecognized values; the
   `setting` E2EE "enum semantics, no prose" promise kept). `ownershipFacts` is ONE page-driven
   `json_each` statement (the P1 plan pin runs over the shipped SQL text).
8. **The faces.** ONE choice sheet + ONE presentation road hosted by §4 rows 14/16/17/18 (each
   host's offer pinned through the real host); the Arrivals arms as DATA from the one verdict (a
   row never offers an Add the seat refuses); the remove/release vocabulary with the
   bookless-answer receipts; the edit law said AT the door; the registry declares every new act
   once and the walk is green; the navigator chip says sealed (F-U3-7). Rows 15/20/21 are honest
   RECORDS verified against the code (the drag roads decode `BookDrag` payloads only; ⌘K has no
   add-to-book road; the Book Panel is 13i-d's) — F-U4-1's row-15 text correction is adjudicated
   for the closeout.
9. **Evidence integrity.** The soak is real (6 seeds × 250 steps over 20 act kinds; exclusivity,
   seal-membership, duplicate-pair, I10, I2 asserted after EVERY step; exercise assertions so it
   cannot silently soak nothing) and it FOUND a real breach pre-ladder, fixed red-first. Every
   suite count I re-ran matches the records exactly (core 2004/212; the 13 face suites 114/13; the
   tutorial spine 79/11; the outflow/ownership/repair/DDL filters). The walk capture counts match
   (50 + 53). No commit in the range carries a trailer. Zero instances before every Mac run.
10. **Closeout obligations are correctly PENDING, not missed** (ledger rows 6–8): AppSpec §7/§9
    contract lines, the SyncSpec §12 running-record entry (written AT the deploy — correct per
    §12's grammar), QUESTIONS #169 (next free number confirmed), KnownIssues row flips (the
    rule-less-gathering row is this phase's and resolves at closeout; P-13ic-U3-2's gathering
    finish/extent faces row goes to 13i-d as adjudicated), the §4 row-15 text correction, the
    MOBILE PARITY row (F-U2-8/F-U4-6's content), and the DerivedData tidy (this review's
    `13ic-ladder` folder included).

**Round-1 verdict: one MAJOR (the archived-arrival confirm/act mismatch), four MINOR, two NIT — no
BLOCKER, no invariant violation, no spec drift found. The cross-model flow proceeds: findings to
the implementer verbatim for agree/dispute; the reviewer makes the final calls and implements its
confirmed fixes with red-on-old pins; suite green; one implementer sanity pass.**

---

## IMPLEMENTER'S RESPONSE (round 1)

*(The implementer's voice: a fresh Opus session, 2026-10-01. I read these in my own context:
CLAUDE.md + its canon, the 13i-c plan whole (§1–§11, the U1–U4 RECORDs, the three
adjudications), the sitting record §4/§5/§6/§9/§18/§20/§24, P-13ib-U2-2 in the 13i-b record,
QUESTIONS #168 (next free number: #169), and every file:line each finding names, each traced
independently. I touched no source or test file and ran no suite; the fix pass and its suites are
the reviewer's. **Verdict: seven AGREE (three with a note), zero DISPUTE.**)*

### [MAJOR] `pendingArrivalCount` vs `dismissPendingArrivals` — AGREE WITH A NOTE
- **Trace:** I followed the mechanism from end to end and it holds. `archiveContainer` writes only
  `archived_at` (`Operations+Container.swift:376`), so the arrival row stays live. `bookArrivalSource`
  (`ArrivalQueries.swift:116`) filters `c.archived_at IS NULL`, and `pendingArrivalCount` (`:267`) is
  `bookArrivals(limit: 0).count`. `dismissPendingArrivals` (`Operations+Intake.swift:491`) tombstones
  on reading/liveness/status alone. `open(.finishBook)` (`BookStateDoors.swift:466–474`) acts at once
  on 0. `sealPreview` under-counts the same way; the seal always asks, so there the line understates
  the count but nothing happens silently. The proposed pin is red on this tree (it reads 0) and green
  after the fix. One correction to "PERMANENT": under the 13i-b ratification (AppSpec §7
  `reading_post`), a FRESH tagging act re-poses a dismissed pair. What the silent finish breaks is
  P-13ib-U2-2's "returns on unarchive" (and the un-finish catch-up never resurrects a decided pair).
  A ruled confirm is still skipped, so MAJOR stands. **The root is mine:** U2 counted with the
  Arrivals FACE's predicate to keep the confirm and the line equal. The act is the contract.
- **Sharper fix:** write the WHERE text once, as a `static let` in `Queries` that both the UPDATE
  and the COUNT use (the `bookArrivalSource` discipline). Then the confirm equals the act by
  construction. Leave `bookArrivals` (the line) untouched, and rewrite `pendingArrivalCount`'s doc:
  by design it may now exceed the line. Counting a sync-stray row (a dead note's live arrival) as
  well is the safe direction, because the door then asks. Corner: `lockReading` still finishes a
  GATHERING until 13i-d (P-13ic-U3-2), and a stray arrival row there would then show the line on a
  gathering's confirm. Guard the count with `kind = 'book'` or accept it; both are race-only.
- **Pins beside the query pin:** (1) the DOOR: `open(.finishBook)` with only an archived waiter
  gives `pending != nil` (red-on-old: it acts without asking); (2) `sealPreview.pendingArrivals`
  counts the archived waiter; (3) a mixed fixture (one archived waiter, one shown) where the count
  equals the rows `lockReading` tombstones.
- **Copy (PROVISIONAL, 13s-revoicable):** P-13ib-U2-2 says an archived waiter "leaves the door while
  archived". So "N waiting at the door" can now count notes the door does not show. Suggest "N
  waiting at the door will be dismissed (M of them archived)." when M > 0, where M is the act's
  count minus the line's.
- **The UNDEFINED arm (spare the archived arrival instead) — QUESTIONS-ready for #169:** "A note
  waiting at a book's door that you have ARCHIVED stays hidden from the door until you unarchive it.
  If you finish or seal the book meanwhile, should finishing (a) dismiss it with the others? The
  finish asks and counts it, and it comes back only if it is tagged again (the review's fix:
  finishing 'dismisses its pending arrivals', §24). (b) Leave it waiting, so it reappears at the
  finished book's door when you unarchive it? You would then dismiss it by hand, since a finished
  book cannot take it in. (c) Dismiss the visible ones and ask separately about the archived ones?"
  Whichever arm lands, #169 must record that P-13ib-U2-2's "returns on unarchive" now carries an
  exception: "unless the book was finished meanwhile".

### [MINOR] the F-5 wing class at `newEntry` / `createOrOpenJournalEntry` — AGREE WITH A NOTE (non-daily arm: fix; daily arm: a product edge → 13i-d)
- **Trace (non-daily arm):** `BookStructureModel.swift:629–635` runs `assertReadingAcceptsPosts`,
  then `createPost` (which calls `insertPost` with the default `wingId: ""`), then
  `addPostToReading`. `addPostToReading` has no wing guard, so the note is minted in Home under a W
  book. There is a second consequence the pin can assert: `applyAutoTag` skips a tag whenever
  `post.wingId != tag.wingId` (`Operations+Intake.swift:312`), so the note also silently misses W's
  outflow tags. The pin is red on this tree and green after the fix.
- **Sharper fix for that arm:** replace the three-call composite with
  `ops.newPostInReading(readingID, profile: .generic, entryDate: entryDay)`, keeping the existing
  `setSegmentationDefault`. That op already does the gate, the mint and the membership in ONE
  transaction, mints in the book's wing (R-13ic-2) and applies the outflow. It refuses the same
  errors, and the round-3 "REFUSE BEFORE MINT" composite becomes structural.
- **The DAILY arm is NOT the same one-line fix.** `createOrOpenJournalEntry` opens the day's entry
  through `Queries.canonicalJournalEntry` (`Timeline.swift:255`), and that lookup is wing-blind.
  Threading `wingId:` into the mint branch alone would still OPEN an existing Home day-entry and
  shelve it into a W Journal, which is a cross-wing membership again. Scoping the lookup changes the
  notebook rule's scope (one entry per day, or per day per wing?) for ⌘J, "+ new entry" and the
  phone's capture. CoreDescription's ratified wings line says Home "holds … the daily Journal book",
  and `setDailyJournalBook` has no wing guard. That decision is 13i-d's (its switcher decides what
  ⌘J does while another wing is open). Recommend a KnownIssues row with owner 13i-d and a line on
  13i-d's carry list, not a fix here. The proposed daily-arm pin goes green only once the lookup is
  scoped.
- **QUESTIONS-ready (13i-d's kickoff):** "Your daily Journal lives in Home, and ⌘J looks for the
  day's entry across the whole library. Once other wings exist, should (a) the daily Journal stay
  Home-only, with 'Use as Daily Journal' refusing a book in another wing (the closest reading of
  'Home holds the daily Journal'); (b) the designated Journal be allowed to live in any wing, with
  ⌘J opening or minting the day's entry in THAT wing (one entry per day per wing); or (c) each wing
  get its own daily Journal, with ⌘J filing into the open wing's?"

### [MINOR] `poolListing`'s probe is missing `r.deleted_at IS NULL` — AGREE
- **Trace:** `ShelfQueries.swift:325–331` gained `r.kind = 'book'` but no liveness clause. Its
  siblings carry one: `membershipElsewhere` (`Operations+Intake.swift:282–284`), `noteMemberships`
  (`OwnershipQueries.swift:57–58`) and `readingsContaining` (`ShelfQueries.swift:353–356`). The
  pre-phase probe (at `ca3b8a85`, `:324–326`) did not read the reading at all, so the gap predates
  U2. But F-R1-7's edit was the moment the three readers were ruled together, and I missed the
  clause there.
- **Reachability:** agreed that only a stray or a seeded row produces this state. SyncSpec §5's
  orphan repair (2) gives a live child arriving under a dead parent that parent's exact stamp inside
  the apply transaction, and no local door makes the state. The fix is defense in depth plus
  consistency with the sibling readers. MINOR (arguably NIT) is fair.
- **Pin:** the proposed pin is red on this tree (the note is excluded) and green after. Its natural
  home is `MembershipReadersBookScopeTests` (the three readers' suite). The added check is a
  primary-key probe, so `PoolTuckTests`' P1 plan pin should stay green; re-run it.

### [MINOR] a sealed blocking book named "reopen" — AGREE WITH A NOTE (the class is wider than the two named arms)
- **Trace:** `NoteMembership.finished` is `r.locked` (`OwnershipQueries.swift:67`), and a sealed
  book is always locked. `SeveredMembership` carries no sealed fact. `moveBlocked` and
  `moveRefusedFinished` name Reopen, which `unlockReading` refuses on a sealed book
  (`readingSealed`). The reachability chain holds: a sealed note may still be added to readings
  (AppSpec §9, `lockPost`). The red-on-old sentence pin is honest.
- **The same `lockedReading` → "reopen" class reaches further.** Two more arms are reachable
  directly, with no race. (1) The chip renders "diverge" on every book row (`MembershipChip.swift:114`).
  On a sealed book, `divergePostForReading` throws `lockedReading`, and `ChipRefusals` (`:476`) says
  "is finished — reopen it". (2) The daily door on a SEALED daily Journal (`sealReading` has no
  daily guard): "+ new entry" (`BookStructureModel.swift:603–606`) and ⌘J's `.bookFinished` mapping
  (`:719–721`) both say reopen. Two more arms are race-only: `MembershipChoiceCopy.refusal`'s
  target arm (`MembershipChoice.swift:149`; the chip filters locked targets at
  `MembershipChip.swift:308`) and `ArrivalsCopy.refusal` (`BookArrivals.swift:148`). I did not
  verify `RecoveryActs.swift:193`.
- **Sharper fix:** don't fork a second sentence family. `BookStateCopy.refusal(for:name:sealed:)`
  (`BookStateDoors.swift:396–404`) already forks correctly. Carry `sealed` (`r.sealed_at IS NOT
  NULL`, one column) on `NoteMembership`/`SeveredMembership`, and route every Reopen-naming arm
  through that one helper. If the fix pass keeps to the two named arms, the rest need a recorded
  owner (13i-d or 13s), never silence: naming a road that refuses is the P-2 class, not copy taste.
- **The `?? ""` fallback** sits in TWO places: `BookArrivals.swift:366–370` (named) and
  `MembershipChoice.swift:361` (`choice.severed.first { … }?.book.name ?? ""`, reached when a book
  finished after the sheet opened is missing from the preview). Fall back to the shared words in
  both.

### [MINOR] dead `ReadingsViewModel.delete` — AGREE
- **Trace:** no app caller. I swept the four holders of a `ReadingsViewModel` (`RootView`,
  `ShelfView`, `Readings/`, `PoolPostsView`). The only call left is
  `TimelineAndReadingsTests.readingCRUDThroughTheUIPathEmitsExactStateTransitions` (`:105`). The
  adjudication after U4 already routed the retirement here.
- **Test shape:** that pin's subject is CRUD "through the UI path", so move its delete step onto the
  real UI road: `BookStateDoors(session:).open(.deleteBook, readingID:)`, then `confirm()` (a plain
  book asks, P-13ic-U4-6). Calling the raw op would quietly weaken the subject. Comment the honest
  edit. No pin is owed.

### [NIT] `perform(.deleteBook)`'s stale receipt count — AGREE WITH A NOTE
- **Trace:** precisely, `named` (name, owned, kind, sealed) is read BEFORE the runner
  (`BookStateDoors.swift:542`). `released` is read INSIDE the runner, but in its own read before
  `deleteReading` (`:575`). The only writer that can land in between is sync apply, which runs
  outside the runner. The effect is receipt-level only, so NIT is right.
- **A second receipt nit in the same sentence:** `liveMemberNoteCount` counts ARCHIVED members
  (correct for the with-notes arm), but the book-only receipt says they "are in the Pool now", and
  the Pool lists only unarchived notes (`poolListing`, `c.archived_at IS NULL`). So the receipt
  over-states when an archived member is released. Optional fix: return the released count from the
  op's own transaction (the `deleteReadingWithNotes` shape), and word the receipt to match what the
  Pool shows (13s-revoicable).

### [NIT] `MembershipDoors.offer` is silent on a nil item — AGREE
- **Trace:** `load` returns nil exactly when `Queries.reading` does. That query filters tombstones
  (`ReadingAssembly.swift:189–192`), so nil means the book was deleted between the refusal and the
  offer. `offer` (`MembershipChoice.swift:301`) assigns nil and says nothing. The chip host has
  already closed its popover, so the press just vanishes (P-2).
- **Sharper:** `addOrOffer` (`:281`) also returns false ("the sheet is up instead") in that case, so
  the Pool, shelf-drop and Manage Notes hosts believe a sheet is up. Have `offer` return whether it
  opened and propagate that. On nil, speak `readingNotFound`'s words through the shared table.

## REVIEWER'S FINAL CALLS AND FIX PASS (round 1)

*(The reviewer's voice, authorized by the orchestrator after the implementer's seven AGREEs. Final
call per finding, each bug-class fix red-on-old first; dispositions written as the pieces land.)*

### [MAJOR] the finish/seal confirm's N vs the dismissal — **CONFIRMED-FIXED**
- **Final call:** CONFIRMED, the implementer's sharper shape adopted whole — ONE shared WHERE
  (`Queries.pendingArrivalRowsWhere`) used by both `dismissPendingArrivals`'s UPDATE and
  `pendingArrivalCount`'s COUNT, so the confirm equals the act by construction. The Arrivals LINE
  (`bookArrivals`) keeps its display filter untouched and the new pins assert BOTH sides (the line
  shows 0 while the count says 1). The "permanent" framing corrected per the implementer's trace:
  what the silent finish broke is P-13ib-U2-2's "returns on unarchive" (a FRESH act still re-poses);
  the dismissal doc now records the exception ("unless the book was finished meanwhile"). No
  `kind='book'` guard added to the shared WHERE: the act never had one (a gathering's `lockReading`
  still dismisses stray rows until 13i-d's P-13ic-U3-2 build), and count-the-act is the contract —
  a stray row making the door ASK is the safe direction, as the implementer noted.
- **Deliberately NOT built (recorded):** the "(M of them archived)" copy suffix — §24's line is
  RULED VERBATIM ("N waiting at the door will be dismissed"); the fixed N keeps it true, and adding
  words to a ruled line is 13s/author territory. Recorded as a 13s copy candidate: when the count
  exceeds the line's visible rows, the confirm may read oddly beside an empty-looking door.
- **The UNDEFINED arm** (should finishing SPARE an archived note's arrival instead) is NOT ruled
  here — the implementer's QUESTIONS-ready paragraph above goes to #169 at the closeout; the build
  is the (a) arm (finish dismisses, the confirm asks and counts), the spec-defensible reading of
  §24's "finishing a book dismisses its pending arrivals", marked PROVISIONAL.
- **Pins (watched RED on the pre-fix tree, green after):** core
  `PendingArrivalDismissalTests` (3 — the archived waiter counted [red: 0==1 failed];
  `sealPreview.pendingArrivals` [red]; the mixed fixture where the promised N equals the rows the
  finish tombstones [red: 1 vs 2] — plus the LINE's display rule asserted unchanged both times);
  Mac `BookStateDoorsTests.finishAsksWhenOnlyAnArchivedNoteWaits` (red: `pending == nil`, the door
  acted at once; green: it asks with N=1 and the confirm dismisses exactly that row).
- **Changed:** `Sources/VariorumCore/Queries/OwnershipQueries.swift` (the shared WHERE +
  `pendingArrivalCount` rewritten on it, doc honest about exceeding the line),
  `Sources/VariorumCore/Operations/Operations+Intake.swift` (`dismissPendingArrivals` on the shared
  WHERE; the P-13ib-U2-2 exception recorded at the act). Suites after: core
  PendingArrivalDismissal + BookSeal + IntakeOperations + OwnershipDoor + OwnershipSoak 69/6 green;
  Mac BookStateDoors + BookSettingsSheet + BookArrivals 29/3 green.
