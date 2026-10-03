# 13i-d LADDER B — ROUND 1 (cold review, `fable-reviewer`, 2026-10-02)

**Subject:** the combined diff `3e6ed192..ade4df64` (bank 2 — U5 the wing switcher + cross-wing
doors · U5b the book move + the bulk wing move · U6 the vocabulary sweep + ACT 0's cross-wing undo
guard · U7 the tutorial's books chapter + the classics seed + the Welcome mint · the U7
continuation C1–C7 · the architect's ONE `Sync/` commit `17aa1113`, the sample-dedupe seed-tag
skip). Prompt: `notes/REVIEW_PROMPT.md` VERBATIM. Anchor: `notes/plans/phase-13i-d-bookcase.md`
(the U5/U5b/U6/U7 RECORDs + continuation + the five adjudications); the plan carries no "Review
foci" section — the constitution P-1…P-9 and each unit's evidence row were checked in its place,
named in the clean bill. `notes/SyncSpec.md` read IN FULL (the diff touches `Sync/`);
`notes/sync-postmortem-fragments.md` read; no editor seam, no custody, no schema, no
`Persistence/`, no `Server/` in the diff (verified by file list). Later commits on main
(`68f3510a`) are record-keeping, outside the subject. Code identity verified:
`git diff 06a255d7..ade4df64 -- App Sources Tests` is EMPTY, so the C5/C6 builds and this
session's runs exercise the review tree.

**STATUS: ROUND 1 COMPLETE — no BLOCKER; ONE MAJOR, three MINOR, one NIT.**

## FINDINGS (severity-ranked; `[severity] · file:line · what · evidence · fix`)

- **[MAJOR] · `Sources/VariorumCore/Queries/Trash.swift:334–336` (the take arm's wing fence) · a
  take deleted from a LIVE, PLACED block is attributed to HOME, not its note's wing — it is
  missing from its own wing's Trash, and HOME's Empty Trash purges another wing's content ·
  **Mechanism (traced):** the take arm joins the note as `LEFT JOIN container c ON c.id =
  b.last_container_id` and the new fence reads `fence("c.wing_id", nullIsHome: true)`. But
  `last_container_id` is stamped ONLY at delete/release/archive events (grepped every write:
  `Operations+Deletion.swift:253`, `Operations+Structural.swift:454/613/928/1189`,
  `Operations+BlockArchive.swift:77`, `Operations+NoteVersions.swift:240`,
  `Operations+Import.swift:150`, `Operations+UndoInverses.swift:304` — none on ordinary
  placement). The take arm's own filter is `b.deleted_at IS NULL` — a take "deleted on its OWN"
  (the arm's doc), whose block is live and still placed — so in the ordinary case (delete one
  take of a block sitting in a wing-X note, block never previously released/restored) `c` is
  NULL and the fence reads the take as HOME's. Inputs → wrong output: stand in wing X, delete a
  take from X's note, open X's Trash → the take is ABSENT; open Home's Trash → it lists there
  (with no note name — the same NULL join); press Home's Empty Trash → the act takes exactly
  what the view shows (F-U5-3's ruled scoping, `Shared/RecoveryActs.swift:373–437`) and mints a
  purge intent for wing-X content — lesson 11's pinned sentence ("Nothing crosses between wings
  except what you move or copy yourself") broken by Home's destruction road, and the record's
  own contract ("blocks, takes and stranded originals by their note's") not met for takes. The
  U5 pins cover the note/book arms and the dead-wing dangle (`WingScopedReadsTests`); no pin
  stages a deleted take under a live placed block beside a second wing. The BLOCK and
  stranded-original arms are correct (their rows are exactly the stamped cases). ·
  **Red-on-old pin:** core — mint wing X, a note in it, a block with two takes, `deleteVariant`
  one; `Queries.trash(db, now:, kinds: [.take], wingID: X)` must list it and `wingID: ""` must
  not — RED on this tree (it lists under `""` and not under X), green with the fix; plus the
  dead-wing control (a take whose note's wing died still lists in Home's). · **Fix:** attribute
  the take's note by the block's LIVE placement first, falling back to the stamp — e.g.
  `LEFT JOIN container c ON c.id = COALESCE((SELECT cb.container_id FROM container_block cb
  WHERE cb.block_id = b.id AND cb.deleted_at IS NULL), b.last_container_id)` — which also heals
  the arm's pre-existing NULL `note_id`/`noteTitle` for the same rows (same mechanism, same
  join; the per-wing Trash is what makes it newly wrong rather than merely unlabeled).

- **[MINOR] · `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift:43–60` (the seed-tag skip's
  convergence premise) + `App/Variorum/Shared/SampleLibrary/SampleLibraryWelcome.swift` (the
  Mac-only arrangement) · at a dedupe meeting with an UNARRANGED copy, the arranged copy is
  exactly as retirable as a raw one, so the Welcome arrangement's Sherlock half (the owned flag,
  the `#classics` applications, the Welcome placement) can be silently lost — the adjudication's
  stated convergence shape ("two fresh devices each seeding the triad classify both copies
  PRISTINE") assumed a symmetric triad, and the phone's seeder produces an asymmetric one ·
  **Mechanism (traced):** the phone seeds the sample library at first write
  (`MobileFirstWriteFurniture.swift:230/246/265` → `SampleLibrarySeeder.seedIfNeeded`) and never
  calls `SampleLibraryWelcome.arrange` (P-13id-U7-14 — the arrangement is the Mac's alone; the
  shared brain is compiled there and called by nothing). A phone-seeded Sherlock therefore
  carries no `#classics`, no owned flag, no shelf. The classifier reads the arranged Mac copy
  PRISTINE too (the 17aa1113 skip covers `#classics`; `owned`/`shelf_id`/`starred` are
  deliberately invisible to it — the U7 RECORD's own trace). Both pristine → the smaller-id
  keeper (`SyncSpec` §7's ruled matrix). When the raw copy's id sorts smaller, the arranged
  family tombstones whole: the `#classics` applications die with their notes (cascade), the
  owned flag and Welcome placement die with the reading row — so, converged, Sherlock stands
  plain and unshelved, and the classics gathering (not part of the family; its rule is
  `#classics`) shows ONLY Jekyll's notes; lesson 1's seeded truth ("Both classic books' notes
  wear the tag #classics") and ritual R1's walk are false of that store, with no self-heal (the
  launch mark is settled `done`/`declined`; only a restore door re-arranges). "Both pristine →
  byte-identical, nothing lost" (the file's own header) no longer holds in the arrangement
  dimension. · **Window, stated honestly:** exactly the dedupe's own window — a second device
  seeding before its first clean sync (the account-store road defers seeding until a clean
  round, so this needs a local-only phone store that later signs in, or a pre-U7 build's copy);
  rare, but it is the precise window the whole classifier was ruled worth defending. Two
  arranged Macs meeting lose nothing (both copies arranged; the keeper is too). ·
  **Red-on-old pin (bug-class shape):** the two-client harness — device A seeds + arranges
  (tag/own/shelve as `SampleLibraryWelcomeTests` stages it) with the LARGER book id, device B
  seeds raw with the smaller; converge; assert the surviving copy's stories wear `#classics`
  (or that the arranged copy is the keeper) — RED on this tree. · **Fix options (the call is
  partly product-flavored — if not fixed, RECORD it):** (a) the keeper rule prefers the copy
  carrying the seed's own declared applications before falling to smaller-id (deterministic —
  both devices see the same rows; one more arm of the ruled matrix, a §7-class change for the
  author's nod); (b) record the corner beside the engagement-chunk residual (the facts doc's
  residual paragraph names only her re-tag/untag today) with the phone-arrangement catch-up as
  its closer; (c) fold the arrangement into the SEEDER itself so every platform's seed is the
  triad (removes the asymmetry at the root).

- **[MINOR] · `App/Variorum/Variorum/Core/Views/WingsModel.swift:381–390`
  (`noteMenuWingDoors`'s task) · the note ▾ menu's wing context has the superseded-observation
  stomp this phase's own ladder A fixed in three sibling models — a cancelled task's late write
  can leave the bars' wing doors reading the WRONG note's wing (or wipe them to nil) until the
  next note switch · **Mechanism (traced):** `.task(id: postID) { context.wrappedValue = await
  NoteMenuWingContext.load(session, postID: postID) }` — when the open note changes A→B, A's
  task is cancelled and B's starts, but a value A's `load` already produced still lands
  (`context.wrappedValue = A's context`), and can land AFTER B's own load (both hop
  database-queue → MainActor); conversely a cancellation mid-read makes `try? await` answer nil
  and the CANCELLED task writes `context = nil`, wiping B's already-loaded context. There is no
  self-heal: the context reloads only on a postID change or after one of these doors' own acts
  (no held observation). Consequence: `CommitBar.swift:816–834` / `TakesBottomBar.swift:471–487`
  render `WingNoteDoors(postID: model.postID, title: context.title, fromWing: context.wingID)` —
  the ACT aims at the right note (postID is current) but the destination list is computed from
  the stale wing (offering the note's own wing, which the op refuses `postAlreadyInWing` — a
  refusal from a door P-2 says should not exist — or omitting a legal destination) and the
  confirm/receipt speak the WRONG title ("Moved “A-title”…" while B moved). This is byte-for-byte
  the `NoteBoxFactsModel` class ladder A round 1 filed (MINOR 1) and fixed in
  `MastheadTagsModel`/`BookIndexGroupingModel`/`BookArchivedModel` — "the guard… now on every
  observation loop of this bank" (round 1's record) — and this bank's U6 then added a new
  unguarded instance. · **Pin:** give `NoteMenuWingContext` its `postID` and gate the doors on
  `context.postID == model.postID` (a pure gate — pinnable without the race), or guard the
  assignment with `!Task.isCancelled` and pin ladder A's deterministic way; if the ladder judges
  the inline-modifier race unpinnable deterministically, the finding stands on this written
  justification plus the bank's own precedent (round 1's MINOR 1, same mechanism, same fix). ·
  **Fix:** the one-line guard (drop a load whose postID is no longer the subject / whose task is
  cancelled) in `noteMenuWingDoors` and its `onDone` reload.

- **[MINOR] · `App/Variorum/Shared/SampleLibrary/SampleLibrarySeeder.swift:1157–1180` (`place`'s
  consult catch) + `:640–646` (`discover`'s wing-blind reads) · Help ▸ Restore on a sample book
  MOVED to another wing fails partway with a refusal that cannot succeed — the exact class
  F-U7-3 was ruled to close, with a third arm the C2 fix does not catch · **Mechanism
  (traced):** U5b's `moveReadingToWing` is drawn on every book but the daily Journal, the seeded
  classics included — so "Sherlock in wing X" is one legal door away. `discover` finds the book
  across wings (`Queries.readings(db)` — nil wing) and the restore then mints each missing story
  via `place` → `quiet.importPost(title:text:undoLabel:segmentation:)` with NO `wingId` — born
  in HOME — then `addPostToReading(noteID, to: bookID)` → `requireSameWing` (post `''` vs book
  X) → `crossWingMembership` → C2's catch handles only `.noteMemberedElsewhere` /
  `.noteOwnedElsewhere` and RETHROWS everything else → the restore throws partway and the door
  speaks the "refused a change partway… try again in a moment" sentence, which can never
  succeed (the same press repeats the refusal; one Pool-stranded note per missing title is left
  behind, bounded exactly as the F1 class records — the stray road then refuses instead of
  re-minting). The tag leg is wing-blind the same way (`existing.tagID` = the FIRST live tag at
  the reserved path across all wings — after a book move both wings hold one). Pre-U5b this road
  could not meet a cross-wing book; the collision is this bank's. · **Red-on-old pin:** Mac —
  seed the library, `moveReadingToWing(sherlock, to: X)`, delete one story, Help ▸ Restore (or
  `SeededBookRestore.restore` headless): RED today (`crossWingMembership` thrown partway), green
  when the restore is wing-aware. · **Fix:** pass the book's effective wing through the restore
  road — `importPost(wingId: bookWing)` at `place`'s mint, the reserved tag resolved in the
  book's wing (and a cross-wing STRAY answered like C2's arms: skip-and-mint-fresh, or a
  wing-aware copy) — or, minimally, catch `crossWingMembership` in `place` beside the two
  ownership arms with the same copy-in road after a `copyNoteToWing`-shaped hop; either way the
  door stops promising a retry that cannot succeed.

- **[NIT] · `Sources/VariorumCore/Operations/Operations+Import.swift:55–60` · the
  `@discardableResult` attribute is separated from `importPost`'s declaration by the new
  doc-comment block (the 13i-d `wingId` paragraph was inserted BETWEEN the attribute and the
  `public func`) · **Evidence:** lines 55–63 read `@discardableResult` → `///` ×5 → `public
  func importPost(...)`. It compiles (attributes may precede comments), but the doc block is
  orphaned from the symbol for DocC/quick-help purposes and the file's every other declaration
  keeps attribute-adjacent-to-func. No pin (cleanliness only). · **Fix:** move
  `@discardableResult` below the doc block.

## DISPOSITION OF TRACED NON-FINDINGS (checked, judged sound — recorded so the tracing isn't lost)

- **The seed-tag skip's trailing-tag-row corner is CLOSED BY CONSTRUCTION:** I traced the one
  structural hazard the skip could add — a `#classics` APPLICATION landing before its TAG row
  (the application would read as hers → spurious EDITED → cross-device keeper disagreement). It
  is unreachable: the push order (`SyncSchema.tables` — `tag` at index 4, `post_tag` at 12) puts
  the tag row at a lower `server_seq` than any application from the same seed, pulls apply in
  seq order, and the reserved-path completeness leg separately defers the whole pass while the
  tag chunk is missing. Not a finding; named here because it is the first question a future
  reader of the skip should ask.
- **Two fresh ARRANGED stores still double the classics gathering and the seeded quicknote**
  (both minted per device; no natural key, no repair class — two identical "classics" rows on
  Welcome, two "a first quick note"s). This is the standing unjudged-furniture doubling class
  (Jekyll — `joinsPristineDedupe: false` — doubles the same way, pre-existing), not this diff's;
  the window is the dedupe's own. Recorded, not filed.
- **`WingsModel.track`'s `adopt` carries no cancellation guard** — deliberate pass: the model
  has no subject key (it tracks the whole `wing` table; no `.task(id:)` restarts it with a
  different subject), so the ladder-A stomp shape cannot arise; a post-disappear late adopt
  writes to a model nobody reads.
- **`moveWingContents`' catch-all `UPDATE container … WHERE wing_id = source`** — safe: it can
  only touch `kind='post'` rows the relocation loop already moved (idempotent) or orphan
  versions (dead-note versions are dead; the belt is honest), and the raw UPDATE rides the
  outbox triggers.
- **Pre-U5 cross-wing tag applications via `applyTag(toBlock:)`** — F-U5-9, already recorded and
  routed to her bundle (#174); the stray sweep in the bulk move handles them; not re-filed.
- **`bookFrozen`'s door words say "finished — reopen it (or unseal it)" for a SEALED
  stay-behind** — the core op distinguishes (`readingSealed`); the door's preview hedges with
  both roads; P-13id-U5b-9 makes the wording 13s-revoicable. Not filed.

## CLEAN BILL (load-bearing things specifically checked and found solid)

**Checked by running in this session (the review tree — code byte-identical to the C5/C6
builds):**
- Core: the bank's 16 new/changed suites — `swift test --filter` over `WingUndoRevivalTests ·
  WingRevivalTests · BookWingMoveTests · WingContentsMoveTests · WingTagCarryTests ·
  WingOperationsTests · WingScopedReadsTests · WingMembershipAndJournalTests · WingMoveTests ·
  TagWingScopeTests · SampleLibraryDedupeRepairTests · WelcomeShelfTests ·
  GatheringExtentRefusalTests · CatalogDetailWordsTests · RuleHearsActsTests` — **88 tests in 16
  suites passed**, the two 17aa1113 convergence pins among them.
- Mac (`DerivedData/13id-u7`, `test-without-building`, zero instances checked first): the
  registry walk (`CapabilityRegistryTests`) + `WingSwitcherTests` + `WingBookMoveDoorTests` +
  `SampleLibraryWelcomeTests` + `TutorialBooksLessonTests` + `TutorialBooksRitualTests` +
  `VocabularySweepTests` + `DeadVocabularyTests` — **92 tests, 0 failed, 0 skipped**. The full
  Mac batches (1406/224 at U6; 1486/236 + 278/33 at U7/C5) and the phone runs are the records',
  not re-run here — their specific load-bearing pins I located and read.

**Checked by reading and tracing myself (every diff hunk of the range was read in this
session):**
- **The `Sync/` commit `17aa1113` (the closest read, per the rider):** the skip is BOUNDED to
  declared paths resolved live-by-path at BOTH call doors; empty = inert (every pre-13i-d facts
  construction byte-identical — default `[]`); the engagement arm's JSON `NOT IN` degrades to
  the old `<> reservedTagID` semantics when no seed paths resolve (`[reservedTagID ?? ""]`); the
  reserved-path completeness leg is untouched and still defers the pass while the tag chunk is
  in flight; the all-wings `seedTagIDs` resolution is SAFE and actually necessary (a U5b-moved
  copy's applications point at the destination wing's twin — the wider set covers them); the
  err-toward-EDITED letter is bent for the declared set ONLY, with the her-retag/untag residual
  documented at the field (its class already recorded at the 18a KnownIssues row); both
  convergence pins are genuine two-client fake-server pins and the first goes red by exactly the
  both-survive mechanism the finding traced (run green here; the revert-red is the record's).
  SyncSpec §7's matrix, §3's outbox discipline (repairs enqueue explicitly — unchanged code),
  and the pull-only occasion gating are untouched by the diff.
- **The membership-revival map is COMPLETE:** every write that clears a `reading_post` tombstone
  was grepped — `restoreContainerRows` + `restoreReading` (F-U5b-1's shared
  `revivalWingScope`, applied AFTER each re-home), `revertDiverge` + `reapplyDiverge` +
  `reapplySmartConversion` (ACT 0's `membershipRevivalStaysInOneWing`, checked before any write
  and before the finished throw), `reapplyMintedContainer` (the honest control — guarded through
  the Put-back road). The two other `deletedAt = nil` revival sites (`UndoInverses:322`,
  `Placement:158`) are `container_block` placements, never memberships. The bind-redo's
  entry-level all-or-nothing matches the ruled letter exactly (P-13id-U6-1 records the
  row-level alternative), and its re-ordered locked-check still writes nothing before throwing.
- **The one relocation (`relocateNote`) and its two compositions:** frozen stay-behind refusals
  checked BEFORE any write; severed arrivals are the dismissal-record class; tags re-point as
  row copies (no intake — P-13ic-U2-1's letter held); versions ride their note; the bulk move's
  `keeping:` = every reading of the wing, so nothing severs; the stray sweep makes "the wing
  ends genuinely empty" true (snippet and version blocks included); the tag retire runs LAST, so
  rule adoption still reads live source tags; the daily-Journal belt refuses by designation AND
  marker on both doors (unreachable from any face by construction — the op is the belt);
  `adoptReadingTags` rewrites only ids that changed (dead/foreign terms stay — P-13id-U5b-10)
  and `RuleGrammar.mapTagIDs` preserves the tree shape. The confirms are the acts' own
  predicates (`bookWingMovePreview`/`wingContentsMovePreview` read the same rows the ops take;
  `WingTagCarry` is pure and shared).
- **The wing ops and the scope fragment:** Home is virtual everywhere (`''` refused by every
  wing op; `requireLiveWing('')` legal); `wingScope`'s dangling-reads-as-Home rule is ONE
  fragment every scoped read composes; the delete refuses-unless-empty with the SAME read the
  face names (`wingContents` — notes exclude versions, archived included); an empty delete
  tombstones the wing's shelves on one stamp; the Put-back re-homes (note AND book, the book
  unshelved) before the same-wing revival scope reads it.
- **Cross-wing membership closed at every road:** `addPostToReading`, `seatArrival`
  (`Operations+Intake.swift:454`), `copyPostIntoReading`, `movePostIntoReading`
  (`Operations+Ownership.swift:305/399`) all pass `requireSameWing`; the choosers list only the
  note's/subject's wing (`MembershipChip.load`, `NotePicker`, `ManageReadingPostsSheet`), so the
  op is the belt, not the door.
- **The tag ops' wing honesty (F-U5-2):** per-wing path uniqueness (`ensureNoLiveTagPath` takes
  the wing), rename/delete subtrees fenced to the tag's wing with the Unicode-scalar substr
  arithmetic kept, the three subtree reads fenced to the root's wing, `applyTag` same-wing-only
  (compared as surfaces read — dangling = Home), `insertTag`'s child-inherits-parent's-wing rule
  (a mismatched explicit wing refuses), and `TypedTagPath` resolving AND minting in the NOTE's
  wing.
- **The re-scoped reads are nil-safe additively:** `library`, `searchCatalog` (books/notes/named
  blocks fenced; SNIPPET hits deliberately every wing — P-13id-U5-4), `notePoolListing` (renamed
  honestly; the scraps `poolListing(poolID:)` keeps the model term; the phone's callers
  untouched), `archivedPosts`, `trash` (notes/books/blocks arms correct; the TAKE arm is the
  MAJOR above), `notePickerNotes`, `readings`, `allTags`, `starred(wingID:)` (≤ cap point
  reads), `canonicalJournalEntry` now HOME's day (#169(b) — ⌘J from any wing opens Home's entry;
  the journal mint's `wingId: ""` deliberate at the code; row 105's mechanism pinned red-on-old
  per the record and the suite runs green here).
- **The Mac composition:** ONE `WingsModel` owned by the composition root (the note window its
  own — R118), handed to the Bookcase/Library/Pool and reaching the bars via the environment;
  the switcher's acts as DATA (`currentWingActs` — none on Home); every wing-scoped surface
  task re-keyed on `session.wing.currentID`; the Bookcase a new board per wing (`.id`);
  `WingState` memory attached by the bootstrap only with a liveness revalidate at ready and on
  every wings delivery; `readScope` honest per platform (nil on the phone — its Trash shows all
  wings and its Empty Trash takes all, the G6 letter kept per platform).
- **The registry (P-1):** the seven new acts declared once with doors/verbs/refusal copy
  (`.newWing .renameWing .deleteWing` surface; `.moveNoteToWing .copyNoteToWing` contextMenu +
  bottomBar; `.moveBookToWing` contextMenu; `.moveWingContents` surface); `.deleteNote` gains
  `.surface` with `ArchivedView` rendering both its row doors from the registry (F-U6-4); the
  registry walk ran green HERE. Switching wings undeclared as a view choice — the Library
  `sort ▾` precedent, consistently applied.
- **The vocabulary sweep's teeth:** `DeadVocabularyTests` walks every code line with a NAMED
  allow-list now reduced to the migrations' SQL only (the seeder's line removed at U7 as
  promised), plus a matcher control; the word tables are pure/static so the pins read the
  sentences the faces draw (`BookViewCopy`, `BookcaseCopy`, `WingCopy`, `MembershipChip.label`/
  `headline`, `ArrivalsCopy.dismissed` — the ruled road-back sentence verbatim); the sealed-vs-
  finished roads are book-known where a book is in hand and two-road where not (row 106's
  letter); `RuleGrammar.hearsApplyingActs` matches the two intake listeners' own reach (verified
  against `intakeAfterTagging`/`intakeAfterStarring` — tag subtree and star terms exactly).
- **The Welcome arrangement:** idempotent (a second arrangement writes no outbox row — pinned),
  never a silent retrofit (the launch mark's decide table traced: fresh = this launch's Sherlock
  minted EVERY story; `pending` resumes; anything else `declined`), adopt-by-role (the R5
  keeper's exact key — smallest live `role='welcome'` id; a hand-named "Welcome" never taken),
  Sherlock owned only fork-free-and-open, her filings never moved (only unshelved/dangling
  seeded books go onto Welcome), the quicknote via the pad's own road (born the ordinary way —
  §19.3/R-13id-5), and `ensureWelcomeShelf`'s two-device convergence pinned through the real
  furniture harness (`WelcomeShelfTests`, run green here).
- **The books chapter's pins are the H pattern, genuinely:** each lesson's prose asserted as
  plain strings, every named door tied to its OWN constant, and the TRUTH executed headless
  (lesson 1 executes the three kinds on the seeded classics, incl. the owned refusal; lesson 2
  counts containers across an add to prove adding never copies) — spot-read lessons 1/2/4/9 and
  ritual R1; lesson 9's second sentence verifiably withheld (F-U7-2's pin). The C4 dismissal of
  F-U7-5 is sound: `BookView.swift:817–849` routes a gathering's "+ new chapter" through
  `openBindOffer(followUp: .createChapter)` — the 13c 2D choreography, two standing pins green
  on both sides; gating it would have deleted a ruled door.
- **The C1 flip and C2 fix:** the two-sided classics pin drives the REAL classifier
  (`SampleLibraryWelcomeTests:278` — arranged seed pristine, a foreign tag still edits); the
  seed-shape drift guard stayed green across C1 (the skip and the seed read ONE constant,
  `SampleLibrarySeeder.classicsTagPath`); C2's copy-in catches exactly the two ownership arms
  and keeps every other refusal loud (the third arm is the MINOR above, a different recipe).
- **Bookkeeping:** KnownIssues rows 105/103/106/111 flipped/annotated as the records claim
  (row 105 struck RESOLVED with the mechanism's pin named); QUESTIONS #174–#177 carry the four
  provisional bundles; the ledger rows flipped in-commit; LIVE STATUS flipped per commit with
  the reverts' states recorded ("no revert in flight" verified against a clean tree here).
- **Commit hygiene:** zero `Co-Authored-By`/`Claude-Session` trailers across all 73 commits of
  the range (grepped full bodies); per-piece commits pushed; `origin/main` current; zero
  `Persistence/`, zero `Server/`, zero editor seam in the diff; the one `Sync/` commit is the
  rider's, reviewed above.

**Verified-by-run vs verified-by-read, said honestly:** the 88-core/92-Mac runs above are this
session's own, on a test bundle verified byte-identical to the review tree; the remaining Mac/
phone counts are the records', whose specific load-bearing assertions I located and read. The
red-on-old tables (R1's 4 issues, the tag half's 8, the membership half's 16, ACT 0's 16, the
combined reverts' 15/10/14, C1–C3's) are the records' — each one's PIN exists in the tree and I
read its assertions; none contradicted the code.

## SUMMARY BY SEVERITY

- **BLOCKER:** none.
- **MAJOR:** 1 — the per-wing Trash's TAKE arm attributes a live placed block's deleted take to
  Home (`last_container_id` is a deletion stamp, not a placement pointer): missing from its own
  wing's Trash, purgeable from Home's — a destruction road crossing the wing fence, red-on-old
  pinnable.
- **MINOR:** 3 — (1) the dedupe meeting with an unarranged copy can silently strip the Welcome
  arrangement's Sherlock half (the ruling's symmetric-triad premise vs the phone's raw seed;
  fix or record); (2) the note ▾ menu's wing-context stomp (ladder A's own guarded class,
  re-introduced unguarded in U6's new code); (3) Help ▸ Restore on a wing-moved sample book
  fails partway on `crossWingMembership` — the F-U7-3 class's third arm, promising a retry that
  cannot succeed.
- **NIT:** 1 — `importPost`'s attribute/doc-comment ordering.
