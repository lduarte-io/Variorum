# Phase 13i-c — OWNED · FINISHED/SEALED · THE OUTFLOW EVENT · the convert/delete/duplicate doors · the DOOR ENUMERATION · the edit-law refusals

**STATUS: OPEN — kicked off 2026-10-01 by the author's `/architect-phase 13i-c` invocation (her
app quit and ready). The BINDING DESIGN is `notes/plans/phase-13i-sitting-record-2026-09-30.md`
(§1 the three-noun ladder, §2 the edit law, §5 Finished/Sealed, §6 Owned + the door enumeration,
§14.10, §18.3 the Trash lifecycle, §18.4 competing owned books, §20 the remove/release doors, §24
the finish confirm's one line) read THROUGH the 13i-a execution record
(`notes/plans/phase-13i-a-schema-event.md` — schema deployed, marker 10; the owned/sealed_at
columns and the R2 exclusivity repair live) AND the 13i-b record
(`notes/plans/phase-13i-b-gatherings.md` — intake's owned arms built headless). This file carries
the EXECUTION: her kickoff rulings (§1), the concrete design (§2–§6), the enumeration checklist
(§4), the units (§7), the traps (§8), the PROVISIONALs (§9), the ledger (§10), LIVE STATUS.**

**Cast (CLAUDE.md's standing default, confirmed at the kickoff):** the Fable orchestrator-architect
(this session) IMPLEMENTS U1 itself (the lockstep event is `Sync/` work — the Sync rider; the 13i-a
precedent); `opus-implementer` at xhigh per unit for U2–U4, one fresh session each; ONE
`fable-reviewer` ladder over the combined diff (the diff touches `Sync/` and the default's meaning —
the Fable-review rule binds). Cross-model flow: findings to the implementer verbatim, agree/dispute
back to the reviewer, which makes the final call and implements its confirmed fixes; the suite green;
one implementer sanity pass. Hard cap three rounds.

**The lockstep:** ONE SyncSpec §12 event, marker **10 → 11** — HER authorization at the 13i-b
closing sitting ("now is the time"). Choreography as at 13i-a: the LADDER first, then HER window
(mirror first by her hand or the PAT at her word, then the Mac Release + the phone build in the
SAME window). The `/Applications` refresh HOLDS behind the window (a marker-11 client against the
marker-10 mirror refuses to sync by design — never strand her daily drive). The checklist is §11.

**Sizing (PhaseSizingGuidance, said rather than assumed):** FOUR acceptance units, one implementer
session each, strictly sequential. TWO are phase-sized — U1 (a lockstep event) and U2 (an op
family); U3 and U4 are door-family UI units (sheets, confirms, choice doors, badges — no new mode,
board or token pass). Within the guidance's letter; the cross-wing doors that the 13i-a fences also
named for this phase were RE-SLOTTED to 13i-d at her kickoff word (R-13ic-2) to keep it so.

---

## THE BINDING PRINCIPLES (the 13b constitution, copied per the architect-phase skill; its application notes bind alongside)

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

Also binding whole: the sitting record §1–§25 (every ruling), the §25 tutorial curriculum as
secondary acceptance criteria (lessons 5, 6, 8 and ritual R4 are THIS phase's sentences — no act
may make one false; U2 pins R4 headless), SyncSpec in full for U1, and the hallucination guard
(red-on-old by behavioural revert for every bug-class fix).

## §1 THE KICKOFF RULINGS (2026-10-01, at this run's open — recorded verbatim-faithful)

- **R-13ic-1 — THE OUTFLOW IS ONE JSON COLUMN.** Asked for the shape, she asked first: *"what shape
  do you think is the best long term? give me advice on this choice and an informed view of the
  tradeoffs with the perspective that I will be using this app 5 years from now."* The advice given
  (recorded in short): the join table's advantages — per-tag merge granularity, an indexed reverse
  lookup, a home for per-tag options — solve problems a per-book tag set edited rarely by one
  person does not have, at a permanent cost (a new synced table through every lockstep, repair,
  purge and RLS surface); the JSON column is the rule's own shape (`query_spec` is a JSON tree of
  tag ids), additive, repair-free, and can grow to carry objects under the same §12 discipline the
  rule grammar grew under; its one weakness (whole-set CAS — two devices editing one book's
  outflow offline at once lose one edit, visibly) is the standing metadata class since Phase 5.
  **She chose the JSON column.** So: `reading.auto_tag_ids TEXT` — a JSON array of tag ids, NULL =
  no outflow; PLAIN under E2EE (ids, the class of the column it replaces — recorded for her at §9);
  the migration carries each existing `auto_tag_id` into a one-element array; the old column
  RETIRES-AS-READ (left in place — SQLite refuses to drop a column that carries a foreign key; the
  `shelf_pins` precedent) and no writer touches it again.
- **R-13ic-2 — THE CROSS-WING DOORS GO TO 13i-d**, beside the wing switcher (her pick of the
  recommended option): no wing can exist until a switcher/mint door does, so move/copy-across-wings
  + tag adoption would have no reachable use here. This phase keeps ONLY the one-line correctness
  fix: `newPostInReading` mints the note in the BOOK's wing (13i-b U1 F-5). 13i-d's plan carries
  the doors at its authoring (the closeout writes the pointer).
- **R-13ic-3 — UNSEAL REOPENS THE BOOK TOO.** Her pick: *"Unseal reopens the book too"* — one door
  takes a book from Sealed straight to OPEN: its members unseal on the exact stamp AND the
  assembly unfreezes (the un-finish catch-up fires). Sealing an open book FINISHES it first in the
  same gesture (so the ladder reads open → finished → sealed up, and sealed → open in one step
  down; Reopen on a FINISHED book is the other down-step). The two states never contradict:
  `unlockReading` on a SEALED book refuses (`readingSealed`) — the one door there is Unseal.
- **R-13ic-4 — A GATHERING'S EMPTY SAVE REFUSES AND OFFERS DELETE; RULE-LESS GATHERINGS GO TO THE
  TRASH AT MIGRATION; NO RULE = SHOWS NOTHING.** Her words: *"refuse, offer delete, but are there
  even any of these gatherings? i'm the only user and i only have a few books. we can maybe just
  drop the book, it won't drop the note anyway - and then we don't have to keep "grandfathered in"
  in mind forever"* — then, offered the concrete shape, she picked it: *"Trash them at migration;
  NULL = shows nothing."* So: v1_20 tombstones every live gathering with no rule (to the Trash —
  Put back available, no note touched); from then on a gathering with NO rule assembles EMPTY
  everywhere (assembly, the Pool tuck, the chip, the bind count) — the malformed rule's own closed
  reading; the mint door requires a rule (the op guards it); the rule editor refuses an empty save
  on a gathering and offers "Delete this gathering…". The match-all tolerance letter DIES; nothing
  is grandfathered. (Her post-close ruling 1 and KnownIssues row "A RULE-LESS gathering shows every
  note…" resolve here.)

**Also recorded at the kickoff (hers, from 13i-b's closing sitting — the charter):** the outflow is
a CHOSEN, OPTIONAL SET of tags on a book, independent of the intake rule — *"you should be able to
choose if you want a, b, a but not b, tag c, whatever"*; the spawn OFFERS the choice (prefilled
with the rule's positive tags — her item (i)) rather than silently deriving.

## §2 THE SCHEMA EVENT — U1 (Fable; `v1_20_outflow_and_ruleless`, marker 10 → 11)

**The migration (ONE, additive — no rebuild):**
1. `ALTER TABLE reading ADD COLUMN auto_tag_ids TEXT;` — JSON array of tag ids; NULL = none.
2. Carry-over (live rows only — a dead row's value is irrelevant and an UPDATE on it would repush
   a tombstone for nothing): `UPDATE reading SET auto_tag_ids = json_array(auto_tag_id) WHERE
   deleted_at IS NULL AND auto_tag_id IS NOT NULL`. The outbox captures it; the rows push after the
   window (the engine refuses until the marker reads 11 — the 13i-a pattern). `auto_tag_id` is left
   as it is: retired-as-read.
3. **The rule-less sweep (R-13ic-4):** `UPDATE reading SET deleted_at = :now, updated_at = :now WHERE
   deleted_at IS NULL AND kind = 'gathering' AND query_spec IS NULL` — an ordinary tombstone on a
   real clock (the Trash's 30-day window reads it); the cascade triggers stamp any stray membership
   with the exact stamp; the outbox captures the rows. A MALFORMED rule is untouched (it already
   fails closed and the editor shows it).
4. `SyncSchema.lockstepVersion = 11`; the `reading` serializer's PLAIN list gains `auto_tag_ids`
   (the PRAGMA completeness walk demands it); the fake server (registry-derived) mirrors it.
   **Apply of an OLD mirror row** (NULL / absent `auto_tag_ids`) reads as no outflow — pinned, the
   13i-a null-normalize class.

**The mirror artifact `Server/supabase/14_phase13i_c_outflow.sql`** — ONE transaction: `alter table
reading add column auto_tag_ids text;` (nullable, no default, no constraint — §2's dumb mirror); the
marker 10 → 11 as the LAST statement; the re-run guard below the marker; the read-only verify tail
(`sync_schema_version()` = 11; the column present). No RPC changes: the allowlists and registries
are TABLE-level and the column is PLAIN (no ciphertext registry entry). The deploy checklist is §11.

**The model + ops recast (same unit):**
- `Reading.autoTagIds: String?` (the raw column) + `Reading.autoTagIDs: [String]` (decoded,
  tolerant: malformed → `[]`, fail closed). `Reading.autoTagId` stays on the record (the column is
  still synced) but NO code reads it after this unit — a grep pin (`OutflowRetirementTests`) asserts
  no production read of `autoTagId`/`auto_tag_id` outside the migration, the serializer and the
  model.
- **`Operations.setReadingOutflow(_ id, tagIDs: [String])`** — books only (`wrongReadingKind`);
  every tag live in the book's wing (`tagNotFound` otherwise — §9's isolation); de-duplicated,
  ORDER PRESERVED (the chooser's order is hers); `[]` stores NULL; no-op-guarded on the decoded
  array. Setting it tags NOTHING by itself; clearing never untags (ruled). `setReadingAutoTag(id,
  tagID:)` becomes a FORWARDER (`tagIDs: tagID.map { [$0] } ?? []`) so the 13i-b rule-editor face
  keeps compiling and working until U3 rebuilds its row — retired with U3.
- `createReading(… autoTagIDs: [String] = [])` (the old `autoTagId:` parameter kept as a forwarding
  convenience, merged in).
- **`applyAutoTag`** applies EVERY outflow tag the note does not yet wear, each through the one
  application road (`insertPostTag` — so each fires intake on OTHER living books; this book's pair
  is already decided). Silent arms unchanged per tag (dead tag, other wing, already worn).
- **`tagAllMembers(readingID, tagID: nil)`** — nil now means EVERY outflow tag: for each outflow
  tag, every live MEMBER (archived included) not wearing it, ONE transaction; returns the count of
  NOTES that newly wear at least one (the receipt's number — PROVISIONAL P-13ic-11); `readingHasNoAutoTag`
  when the outflow is empty and no tag given. The "also tag the N current members" offer's N =
  members missing at least one outflow tag (`Queries.outflowMissingMemberCount`).
- **The spawn's prefill is a pure function:** `RuleGrammar.positiveTagIDs(of:)` — the tag ids NOT
  under a `not` (her item (i): `#a AND NOT #b` → `#a`; an OR fan → all its tags; star-only → none).
  `ShelfViewModel.spawnBook` passes `autoTagIDs: positiveTagIDs` headless now (the sole-tag arm and
  `Queries.tagIsLive`'s role fold into it — dead ids are dropped by `setReadingOutflow`'s own
  liveness check); U3 lets her EDIT the prefill before the mint.
- **NO RULE = NOTHING, on a gathering (R-13ic-4):** every `case .none` arm that read "shows every
  note" flips to the closed reading — `Queries.assembleReading`'s gathering arm, `poolListing`'s
  tuck, `readingsContaining`'s gathering leg, the bind's count/materialization,
  `saveFilterAsGathering`'s association (a rule-less gathering's association is NOTHING — the
  filter alone, as before), the rule editor's empty-state sentence (U3 re-words). Pinned: a
  NULL-rule gathering assembles empty, tucks nothing, lists on no chip. **The op guards:**
  `createReading(kind: .gathering, querySpec: nil)` refuses `gatheringRequiresRule`;
  `setReadingQuerySpec(gathering, nil)` and a write that normalizes to NULL refuse the same (the
  refusal behind the editor's offer); the two seeders (quicknotes, starred notes) already pass
  rules — verified by pin. A rule-less gathering can exist live ONLY as a Trash restoree (and then
  shows nothing until it gets a rule — U3's empty state says so; its bind/spawn doors hide, P-2).
- The one-line F-5 fix (R-13ic-2): `insertPost` gains a `wingId:` and `newPostInReading` passes
  the book's — pinned on a non-Home book inserted directly.
- **Convergence pins (`Phase13icOutflowTests`):** the migration's column + carry-over + the
  rule-less sweep (its outbox rows asserted; the Trash lists the swept gathering; Put back works
  and the restoree assembles EMPTY); two clients editing one book's outflow converge by server-wins
  CAS (documented, the metadata class); an arriving old row with NULL `auto_tag_ids` reads as no
  outflow and its `auto_tag_id` is ignored; the serializer completeness walk green at marker 11.

## §3 OWNED (U2 — the op family; the sitting §6, §2, §18.4, §20; the brief's round-4 rulings stand)

**One pure Domain rule, `Domain/OwnershipDecision.swift`:** given the TARGET book's `owned` and the
NOTE's facts (membered in another BOOK? owned elsewhere?) → `.add` (a plain pointer — bookless
notes "move in clean"; an ordinary note into a plain book), `.needsChoice(.copyOrMove)` (an OWNED
target, a note membered elsewhere — copy in / move in), `.needsChoice(.copyOnly)` (a PLAIN target,
a note owned elsewhere — copy in). ONE table read by every membership-creating road (§4). The
intake table's owned arms (13i-b, shipped) are the same semantics for the event occasions.

**The ops (every one ONE transaction; the standing conventions inherit):**
- **`setReadingOwned(id, owned: true)` — the CONVERT door.** Refuses a gathering
  (`wrongReadingKind` — a category error, §6), a finished or sealed book (`lockedReading` —
  converting diverges members, a structural act; un-finish first — PROVISIONAL P-13ic-2); no-op if
  owned. For every live MEMBER also membered in another live BOOK: a DIVERGE IN PLACE (the
  `divergePostForReading` body inlined: a full family copy takes this book's exact slot — position
  AND chapter; the original's membership here tombstoned; `version_of` + per-block `derived_from`
  edges; **TAGS RIDE the copy** — ruled §6, P-13ic-5); sole/bookless members become owned in place
  (no row changes). Then `owned = 1`. Returns `OwnConversionResult { copied: [(original, copy,
  bookNamesElsewhere)] }`. **No structural-undo entry** (P-13ic-1): the copies are real notes
  ("conversion-time copies persist as the independent notes they are" — round 4) and un-owning is
  the symmetric door. `Queries.ownConversionPreview(readingID)` lists the members that WILL fork
  (name + where else they live) for the confirm — the confirm LISTS them (ruled).
- **`setReadingOwned(id, owned: false)`** — `owned = 0`; members stay; exclusivity lifts. No-op
  guarded. (A note still carries its memberships; nothing else moves.)
- **`addPostToReading` consults ownership** (the ONE choke point every face routes through):
  `.needsChoice(.copyOrMove)` → throws `noteMemberedElsewhere(postID:, readingID:, elsewhere:
  [readingID])`; `.needsChoice(.copyOnly)` → throws `noteOwnedElsewhere(postID:, readingID:,
  owner: readingID)`. A waiting ARRIVAL's seating path inside the same op consults the same table.
  The refusals carry the names the door needs (`OpsRefusalTable` words — shared, platform-neutral:
  the phone's membership face inherits honest words for free).
- **`copyPostIntoReading(postID, into readingID, at:)` — COPY IN, the ceremony.** `copyPost` (the
  whole family; tags ride — P-13ic-5), its membership row inserted FIRST at the asked position (so
  this pair is decided before any tag fires intake elsewhere — the `newPostInReading` order), then
  the auto-tag. The original is untouched. When the act answers an ARRIVAL, the arrival row is
  tombstoned as a MEMBER-class decision (permanent — a second copy must never be offered on a fresh
  act; P-13ic-3). Returns the copy. Refuses finished/sealed (`lockedReading`), capacity, a dead
  note. Registers the `duplicateAsVersion`-shaped undo entry (un-mint the copy; redo revives it
  exact-row — the diverge precedent).
- **`movePostIntoReading(postID, into readingID, at:)` — MOVE IN (claim-move).** Tombstones every
  OTHER live `reading_post` row of the note (members AND arrivals, in books; a gathering has none)
  — the SEVERED memberships, returned by id so the receipt names them; then the add here (a waiting
  arrival here flips to member at the asked position; the auto-tag rides). The daily Journal's
  membership is one of the severed when the note is claimed out of it (§10's ruling). Refuses
  finished/sealed/capacity. `Queries.moveInPreview(postID)` lists what will be severed for the
  confirm. No structural-undo entry (the memberships are the `addPostToReading` class; the Trash is
  not involved — a re-add by hand is the road back; PROVISIONAL P-13ic-12).
- **The judgment arms:** `seatArrival` consults the table and throws the same two refusals (the
  faces then offer Copy in / Move in on an owned book's arrival of a membered note, and Copy in /
  Dismiss on a plain book's arrival of an owned-elsewhere note — §4's "claim-move / copy in /
  leave" and "copy in / dismiss"). `copyPostIntoReading(answering: pairID)` /
  `movePostIntoReading(answering: pairID)` take the arrival's row id as the position source.
- **`shelveInDailyJournalBook` BELLS, never throws (§6):** on `noteOwnedElsewhere` (the Journal
  plain, the entry claimed elsewhere) or `noteMemberedElsewhere` (an OWNED Journal, the entry
  membered elsewhere) it inserts an ARRIVAL row for the pair and returns a new
  `.waitingAtDoor(readingID:)` outcome; ⌘J's note speaks it ("Today's entry opened — it's waiting
  at the Journal's door, because “X” owns it."). The decided read (ANY row) is unchanged.
- **The REVIVAL PASS — `enforceOwnershipAfterRevival(db, postIDs:)`, one function, R2's shape
  applied locally:** after any door that REVIVES membership rows — `restoreContainer` (the note's
  own memberships), `restoreReading` (the book's), `reapplySmartConversion` (the bind's redo),
  `reapplyDiverge`, `reapplyMintedContainer` — for every note with more than one live member row
  where any is owned: the EARLIEST-CREATED membership stands (`created_at, id` — the local "earlier
  act"; the repair ranks by `server_seq` for the same reason); a later OWNED-side row demotes to
  `status='arrival'`; a later PLAIN-side row beside a standing owned claim is tombstoned. Nothing
  destroyed, nothing silent — the book shows the bell, the row is recoverable. (PROVISIONAL
  P-13ic-9; pinned per door in `OwnershipDoorTests`.)
- **The bind's owned-notes limb** (fenced out of 13i-b): `convertSmartReadingToCurated(…,
  ownedNotes: .leaveOut | .copyIn)` — the assembly's notes OWNED ELSEWHERE cannot materialize as a
  plain book's members: `.leaveOut` (DEFAULT — copies are ceremonies, never silent; P-13ic-4)
  materializes nothing for them; `.copyIn` mints a family copy per such note (tags ride) in the
  assembly's slot. `Queries.bindOwnedNotesPreview(readingID)` lists them for the confirm (the sheet
  gains the limb in U3). The un-bind's inverse takes the copies' rows like any other (they are
  rows standing on the book; the copies themselves persist as notes — the ceremony's letter).
- **The remove/release doors (§20):** `removePostFromReading` is unchanged op-side (a membership
  tombstone; on an owned book the note is bookless by construction and lands in the Pool); it
  RETURNS whether the note is now bookless so the receipt can say "Released — it's in the Pool
  now." A gathering has no remove door; the honest door "Remove the #tag" is `removeTag` through
  the chip (U4) — no new op.
- **The three membership readers gain `kind='book'` TOGETHER** (ladder F-R1-7, ruled here as one):
  `membershipElsewhere`, `poolListing`'s exclusion, `readingsContaining`'s membership leg —
  membership means a BOOK's row; a sync-stray member row on a gathering is never a home.
- **Hide-owned (§6):** `setReadingHideOwned(gathering, Bool?)` (gatherings only; nil = follow the
  global default); the global default is the setting `hide_owned_default` ("0" = SHOW, badged —
  the Welcome lesson depends on it; "1" hides), read in `Queries.AppearanceQueries` with the
  not-seeded family. Scope: gathering assemblies, tag listings, search; **Library EXEMPT** (R32).
  The predicate is ONE pure SQL fragment (`Queries.ownedElsewhereExclusion`) every scoped reader
  composes. (Search is 13o's; the fragment is its hand-off.)
- **The badge facts:** `Queries.ownershipFacts(for postIDs)` → per note: `ownedBy: (readingID,
  name)?` and `otherBookCount` + names — one statement for a listing page (P1: ∝ the page).
- **The setting `ownership_badges`** ("1" default; synced document semantics like `arrival_flash`
  — P-13ic-10): the badge family toggles as a SET.

## §4 THE DOOR ENUMERATION — the checklist (the sitting §6: "missing one is a ladder finding")

Every membership-creating road, what it consults, and its pin. The ops layer is the choke point;
a FACE's job is to OFFER the choice the refusal names (P-2 — never a bare refusal where a ceremony
exists). U2 pins the op rows; U4 pins each face's offer.

| # | road | consults | outcome | pin |
|---|---|---|---|---|
| 1 | `addPostToReading` (every hand-add) | the table | plain add · `noteMemberedElsewhere` · `noteOwnedElsewhere` | U2 |
| 2 | the arrival seat (`seatArrival`) | the table | seat · the two refusals → Copy in / Move in / Dismiss | U2 |
| 3 | intake's event/backfill/catch-up | the intake table's owned arms (13i-b) | claim · bell | 13i-b pins; U2 re-runs them through a REAL owned book |
| 4 | `shelveInDailyJournalBook` (⌘J, Today's Entry, the phone's capture, the quick-note filing) | the table | add · `.waitingAtDoor` (never throws) | U2 |
| 5 | `copyPostIntoReading` / `movePostIntoReading` (the ceremonies) | by construction | copy with tags · severed list | U2 |
| 6 | the bind (`convertSmartReadingToCurated`) | owned-elsewhere notes in the assembly | leave out (default) · copy in | U2 |
| 7 | `restoreReading` membership revival | the revival pass | demote / tombstone per R2's shape | U2 |
| 8 | `restoreContainer` membership revival | the revival pass | same | U2 |
| 9 | the bind's redo (`reapplySmartConversion`), `reapplyDiverge`, `reapplyMintedContainer` | the revival pass | same | U2 |
| 10 | `divergePostForReading` | none needed | allowed — it copies | U2 (a control pin) |
| 11 | `newPostInReading` on an owned book | none needed | the mint is sole by construction (+ the book's wing) | U2 |
| 12 | `duplicateReading` shallow/deep | the source's ownership | shallow refuses on an owned source | U2 |
| 13 | sync apply | the R2 repair (13i-a) | converges | `Phase13iRepairTests` (standing) |
| 14 | the membership chip's Add (Mac) | row 1's refusals | the choice sheet | U4 |
| 15 | the book Index/Outline DRAG roads (`BookStructureModel` ×2) | row 1 | the choice sheet | U4 |
| 16 | the Pool's drop onto a book (`PoolPostsView`) | row 1 | the choice sheet | U4 |
| 17 | the shelf row's drop (`ShelfView`) | row 1 | the choice sheet | U4 |
| 18 | Manage Notes… (`ManageReadingPostsSheet`) | row 1 | the choice sheet | U4 |
| 19 | the Arrivals line's Add (`BookArrivals`) | row 2 | Copy in / Move in / Dismiss; the "owned by [Book]" line (§18.4's face) | U4 |
| 20 | ⌘K | — | NO add-to-book road exists in the palette today (it opens books); nothing to consult — recorded, not invented | U4 (record) |
| 21 | the Book Panel's drag powers (the sidebar note box, 18d) | — | reorder/assign within a book only — creates no membership; recorded | U4 (record) |
| 22 | the phone's membership face (`MobileMembership`) | row 1's refusals through the shared words | an honest refusal naming the copy/move ceremony (the sheets are the mobile catch-up's) | MobileSoul row at closeout |

## §5 FINISHED AND SEALED (U2 ops; U3 faces — the sitting §5, §24; R-13ic-3)

- **Finished** = `locked` (shipped): the assembly frozen, intake paused, arrivals dismissed on the
  finish's stamp (13i-b). The CONFIRM (U3) carries §24's one line — "N waiting at the door will be
  dismissed" — only when N > 0 (`Queries.pendingArrivalCount`); else the door acts without asking.
- **`sealReading(id)` — SEAL = Finished + text immutability (EDITION ZERO).** Refuses a gathering;
  no-op if sealed. In ONE transaction: (1) **the FORKS** — every live member membered in another
  live BOOK is diverged in place (the `setReadingOwned` body's step; tags ride) — an OWNED book has
  none (the composition prize: fork-free); (2) if not finished: `locked = 1` + the pending arrivals
  dismissed (the finish); (3) `sealed_at = now`; (4) every live member post not already sealed is
  SEALED with `locked_at = now` — the EXACT STAMP (the shared `lockPost` body: dirty buffers insured
  by one quiet auto commit each — the standing seal insurance); a member already sealed on its
  own (a different stamp) is untouched. Returns `SealResult { forked: [(original, copy)] }`.
  `Queries.sealPreview(readingID)` → the notes that WILL fork (named, with where else they live) +
  the pending-arrival count — the confirm LISTS the forks (ruled: the one copy-as-consequence is
  never silent) and carries §24's line. No structural-undo entry (unseal is the door).
- **`unsealReading(id)` (R-13ic-3):** refuses when not sealed (`readingNotSealed`); members whose
  `locked_at == sealed_at` UNSEAL (the `unlockPost` body); `sealed_at = nil`; `locked = 0`; the
  un-finish CATCH-UP fires (the book is OPEN again). A member sealed independently stays sealed.
- **`unlockReading` on a SEALED book refuses `readingSealed`** — the face shows Unseal there, never
  Reopen (P-2). `lockReading` on a sealed book is a no-op (already finished).
- **Deleting a sealed book (book-only)** leaves its members' seals in place as real post seals she
  can unseal per note; Put back on the book restores a sealed book whose stamps still match, so
  Unseal works again (PROVISIONAL P-13ic-6).
- **Edition zero (§13's future):** `sealed_at` is the edition's stamp and the members' matching
  `locked_at` its membership-level freeze; a future "cut an edition" is a saved snapshot of
  membership + note versions keyed on such a stamp — nothing here forecloses it.

## §6 DELETE · DUPLICATE · THE TRASH (U2 ops; U4 faces — the sitting §6, §18.3)

- **`deleteReading(id)`** unchanged: book only; the cascade frees members (an owned book's notes
  land in the Pool — "nothing of hers destroyed").
- **`deleteReadingWithNotes(id)` — "Delete book and its N notes", ONE STAMP:** for each live member
  post, the `deleteContainer` body on the SAME `now` (versions ride, as that door's letter says);
  then the reading's tombstone on that `now` (the cascade stamps memberships with it). Offered by
  the door ONLY on an owned book (ruled — the asymmetry is the concept, visible at the door); the
  op itself refuses a gathering and nothing else.
- **`restoreReading` returns WHOLE:** after the reading flips, member posts whose `deleted_at ==`
  the book's stamp are revived through `restoreContainerRows` (exact-stamp — a note independently
  deleted later carries a different stamp and stays dead: the standing documented corner) BEFORE
  the membership revival (the live-post guard then passes), then the revival pass (§3). Each note
  also lists in the Trash as its own row with its own Put back (an independent road; a note put
  back alone comes back bookless until the book returns — recorded).
- **`duplicateReading(id, name:, deep: Bool)`:** a NEW reading row — kind book, the given name
  (the door asserts it free, E13), profile/sort/grouping/`query_spec`/`max_posts`/`word_target`/
  `intake_seating`/`auto_tag_ids` COPIED (the book's configuration), same wing; UNSHELVED,
  unstarred, open, unsealed, `owned = 0` (the duplicate is born non-owned — ruled); chapters copied
  (fresh ids, positions kept) with the membership → chapter mapping; MEMBER rows copied at their
  positions (arrivals never). **Shallow** (`deep: false`): the same notes (a sibling pointing at
  them); refuses on an OWNED source (`ownedBookDuplicatesDeep`). **Deep** (`deep: true`, "with
  copies"): a family copy per member (tags ride), each copy the member — the divergent fork; the
  only shape for an owned source. A gathering refuses (§3: no duplicate op). No creation-time
  backfill (the copied membership IS the state), no structural-undo entry (the Trash is the road —
  the `createReading` class). PROVISIONAL P-13ic-7. `Queries` gets nothing new: the preview is the
  member count.
- **The Trash (§18.3):** book rows are already kind-labeled; a book deleted WITH its notes shows
  "and N notes" in its row (the exact-stamp count — `Queries.trashBookNoteCount`); Put back's
  receipt names it. Shelves are never Trash objects (13i-d). The purge family for a book stays
  version-blind as recorded (the notes' own Trash rows carry their own Delete Now).

## §7 ACCEPTANCE UNITS (four; evidence named before the first spawn)

- **U1 — THE OUTFLOW EVENT + NO-RULE-IS-NOTHING + THE OUTFLOW OPS (Fable, this session; §2
  whole).** Evidence: the migration pins; the serializer walk at marker 11; `Phase13icOutflowTests`
  (carry-over, the rule-less sweep's outbox + Trash + restoree-assembles-empty, CAS convergence,
  null-normalize); the op pins (`setReadingOutflow` guards/no-op, `applyAutoTag` over a set,
  `tagAllMembers` nil-means-all + N, `positiveTagIDs`, the gathering guards, F-5); the FULL core
  suite green; Mac + mobile BUILDS green with the touched suites; the mirror artifact + §11
  checklist line-read; a dev-store walk (the store migrates live; a rule-less gathering lands in
  the Trash; a book's outflow carried and still tagging; nothing else visibly changed).
- **U2 — THE OWNED + SEALED OP FAMILY + THE ENUMERATION (`opus-implementer`; §3, §5, §6 whole; the
  §4 rows 1–12).** Evidence: exact state-transition suites per op; `OwnershipDoorTests` (the §4
  table, one test per row 1–12, each asserting the consult and the outcome); a headless soak
  (randomized own/un-own/add/copy/move/seal/unseal/delete/restore sequences — invariants: no note
  is a member of an owned book AND anywhere else; every seal stamp matches or is independent; no
  live pair duplicates); **the R4 ritual headless** (`OwnershipRitualTests`: flip a book to Owned →
  add one of its notes to another book → meet the copy choice → remove a note → find it in the
  Pool) + lesson sentences 5/6/8 as pins; FULL core suite green; Mac + mobile build.
- **U3 — THE SETTINGS SHEET + THE OUTFLOW CHOOSER + THE MINT (`opus-implementer`; UI).** The Book
  Settings sheet (and the gathering's — the SAME pane): Name · Word target · Note cap · a
  COLLECTING section written as sentences ("Gathers from: …" · "New matches: …" · "Notes written
  here are tagged: #a #b") with its Edit… door into the rule editor (her discoverability report);
  the STATE doors — Finished (the §24 confirm line when N > 0) · Seal… (the listed-forks confirm +
  the line) / Unseal (says it reopens) · Own its notes… (the listed-copies confirm) / Stop owning;
  the gathering's hide-owned toggle; the rule editor's auto-tag row REBUILT as the OUTFLOW CHOOSER
  (a multi-tag picker over the wing's live tags, ordered as chosen, "none" legal, independent of
  the rule; `setReadingAutoTag` retired); the gathering's empty-save refusal + "Delete this
  gathering…" (R-13ic-4) and its rule-less empty state ("No rule — this gathering shows nothing
  until it has one"); the MINT door requires a rule (the mint flow carries the editor inline;
  Create disabled until a term exists; the retired "Create Smart Book" wording may stay until
  13i-d's sweep); the spawn sheet's outflow chooser prefilled with the positive tags; the shelf
  row's menu gains Seal/Unseal · Own/Stop owning; the registry declares every act (P-1).
  Evidence: mounted pins (each confirm's sentences as static copy; the N>0 gate; the chooser's
  save; the empty-save refusal; the mint's gate) + the registry walk + the orchestrator's dev-store
  walk, both voices × both appearances, captured.
- **U4 — THE MEMBERSHIP DOORS' FACES (`opus-implementer`; UI; §4 rows 14–21).** ONE choice sheet
  (`MembershipChoiceSheet`: copy in / move in with the severed list · copy in only) hosted by every
  face in rows 14–18; the Arrivals line's Copy in / Move in / Dismiss arms + the "owned by [Book]"
  line (§18.4); the two-choice delete confirm on an owned book (the shelf menu + the sheet) and
  the plain book's confirm naming the Trash; Duplicate Book… (with-copies checkbox; owned →
  with-copies only); the remove/release vocabulary + receipts on the chip, the Index/Outline note
  row, the note box ("Release from this book" on owned; the gathering's honest "Remove the #tag");
  the badge family — the shared-membership badge in book views (hover names them), the owned-by
  badge in gatherings/Pool/tag listings/Library (click-through = open the book at the note, the
  panel bridge); the `ownership_badges` and `hide_owned_default` Settings rows; the Trash's
  "and N notes" row + receipt; the registry (P-1); refusal words in the shared table.
  Evidence: mounted pins per host (each face OFFERS the choice on the refusal — the §4 rows), the
  registry walk, the tutorial spine green, the orchestrator's walk (R4 by hand: own a book → add
  its note elsewhere → the choice → release → the Pool; delete an owned book both ways → the Trash
  → Put back whole), both voices × both appearances, captured.

Then: ONE `fable-reviewer` ladder over the combined diff (REVIEW_PROMPT verbatim, zero framing;
findings repo-first; cross-model flow; cap three rounds) → HER WINDOW (§11; the install refresh
rides it) → closeout (canon deltas as ruled: AppSpec §7's column + §9's op lines + §12's doors,
OverallModel §2 untouched; SyncSpec §7 (no new repair — the entry says so) + the §12 entry AT the
deploy; the MOBILE PARITY row; KnownIssues rows 67/69 dispositioned; QUESTIONS #169; the master
plan; 13i-d's plan + kickoff (carrying R-13ic-2's doors and the running for-the-combined-walk
list); the handoff).

## U1 RECORD — THE OUTFLOW EVENT + NO-RULE-IS-NOTHING + THE OUTFLOW OPS (Fable, the orchestrator's own build, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** the dev-store GUI walk — HELD at the
author guard (`guard.sh --author`: HID idle 0 s, she is at the machine; the standing rule is
STOP, never re-activate) and FOLDED into the next author-free window (U3's walk at the latest —
the same Debug build `App/Variorum/DerivedData/13ic-u1-walk`, already built); the rule editor's
outflow CHOOSER face (U3 — the 13i-b row rides on the forwarder meanwhile, showing the set's
first tag); the mint door's inline rule editor and the editor's empty-save refusal face (U3 —
the OP refuses today and the Create Smart Book door speaks the shared words); the mirror
DEPLOY (her window, §11); the §12 running-record entry (written AT the deploy); the AppSpec
§7/§9 contract lines (the closeout). Zero `Sync/` lines beyond the registry's one column and
the marker — no repair was needed (the column is plain CAS metadata), as §2 designed.

**UNIT STATUS: BUILT AND PINNED 2026-10-01 — core 1927/202 GREEN (1 standing env-gated skip) ·
Mac `build-for-testing` + the touched suites 83/9 GREEN · the phone target BUILD SUCCEEDED ·
the walk HELD (above).** Commits `b4cb639b` (core) + `19eb55c0` (Mac).

### What U1 built (the design as shipped — a fresh session's map)

- **`v1_20_outflow_and_ruleless`** (`Persistence/Migrations.swift`): `ALTER TABLE reading ADD
  COLUMN auto_tag_ids TEXT`; the LIVE carry-over (`json_array(auto_tag_id)` where set; dead rows
  untouched; `auto_tag_id` left as it is — retired-as-read); the RULE-LESS SWEEP (every live
  gathering with `query_spec IS NULL` tombstoned on a real clock → the Trash, Put back available;
  malformed rules untouched; rule-less BOOKS untouched). The outbox captures every touched row;
  they push after the window. `SyncSchema.lockstepVersion = 11`; `reading`'s PLAIN list gains
  `auto_tag_ids` (completeness walk green). The mirror artifact
  `Server/supabase/14_phase13i_c_outflow.sql` (the re-run guard; ONE `add column`; marker 11
  last; the verify tail) registered in `AuthRLSDDLTests.lockstepFiles`.
- **`Reading.autoTagIds`** (the raw column) + **`autoTagIDs: [String]`** (decoded, malformed →
  `[]`) + `Reading.encodeOutflow` / `decodeOutflow` (dedupe, order kept, empty → NULL — ONE
  spelling of "no outflow").
- **`Operations.setReadingOutflow(id, tagIDs:)`** — books only; every tag live in the book's
  wing; ordered + deduped; `[]` → NULL; no-op-guarded on the decoded set. `setReadingAutoTag` is
  a FORWARDER (one-element set; retired with U3). `createReading(autoTagIDs:)` beside the
  forwarding `autoTagId:` (merged in front). `applyAutoTag` applies EVERY outflow tag the note
  lacks (dead/other-wing/already-worn skipped per tag). `tagAllMembers(nil)` = every outflow
  tag, returns NOTES newly wearing ≥1 (P-13ic-11); `Queries.membersMissingAnyOutflowTag` is the
  offer's N. `saveFilterAsGathering`'s book association = the conjunction of the live outflow
  tags (`.autoTag`), and it refuses to mint a rule-less gathering.
- **`RuleGrammar.positiveTagIDs(of:)`** replaces `soleOutflowTagID` (tree order, deduped, parity
  kept: `#a ∧ ¬#b` → `[a]`; an OR fan → all; star-only → `[]`). `ShelfViewModel.spawnBook`
  passes the live-filtered prefill as the spawned book's outflow (U3 lets her edit it).
- **A gathering REQUIRES a rule (R-13ic-4):** `createReading(kind: .gathering)` with a spec that
  normalizes to NULL refuses `gatheringRequiresRule`; `setReadingQuerySpec(gathering, NULL)`
  refuses the same (the editor's refusal stands on it; a BOOK's clear stays the kill switch).
  `OpsRefusalTable` carries the words. The two seeders already mint with rules.
- **NO rule = NOTHING on a gathering:** `assembleReading`'s gathering arm, `bookshelf`'s word
  counts, `poolListing`'s tuck, `readingsContaining`, `smartBookMembership` names, and the
  collect door (refuses "it has no rule yet") all read NULL as the closed state malformed
  already had. `ruleMatchSQL(nil, …)` keeps its wing-only shape but no gathering reader passes
  nil any more.
- **F-5 closed:** `insertPost(wingId:)`; `newPostInReading` mints in the BOOK's wing.
- **`ReadingsViewModel.create(querySpec:)`** so the Mac mint can pass a rule; the Create Smart
  Book door speaks the refusal until U3 rebuilds it with the inline editor.

### Evidence (each named before the build — the plan §7 U1 row)

- `Phase13icOutflowTests` (12): the column + carry-over (+ the untouched dead row + the enqueue),
  the rule-less sweep (real stamp; ruled/malformed/book/dead rows untouched; outbox; the Trash
  lists it), the setter's guards/order/dedupe/NULL/no-op, the forwarding merge, every tag riding
  a mint and a hand-add with a dead one skipped, `tagAllMembers(nil)` + the offer's N, the
  gathering guards vs the book's kill switch, a rule-less gathering assembling EMPTY / listing
  nowhere / refusing the collect door and ROUND-TRIPPING through the Trash, the wing fix, two
  devices' outflow edits converging by server-wins, a pre-window NULL row landing as no outflow.
- `OutflowRetirementTests`: a source walk — no production read of the retired column outside
  the model, the migration and the serializer.
- `RuleOutflowTests` rewritten to the positive-set table (an honest rewrite — the sole-tag letter
  was superseded, not broken).
- HONEST FLIPS of the match-all letter, each commented at the pin: `PoolTuckTests`
  (`eachGatheringsLetterHolds`), `ReadingFilterTests` (the rule-less association → `.none`),
  `ReadingAssemblyQueryTests` (`smartWithNoSpecMatchesNoPosts…`), `SmartQueryTagsAllTests`
  (`emptyTagsAllIsNoRule…`), `TimelineAndReadingsTests` (a gathering's clear REFUSES at save),
  `BindDoorTests` (the OR fan flows out every tag; a dead one drops; a negated one never; the
  rule-less spawn words read through a raw-NULLed restoree); `WingsMigrationTests`' recast
  fixture carries a rule (its subject is the kind/CAS/stamp preservation).
- Fixture hygiene (no assertion weakened): every test that minted a gathering with no rule now
  mints it WITH one (`… querySpec: try RuleGrammar.encode(.star)) // 13i-c: minted with a rule`),
  or reproduces the restoree state raw where the no-rule state IS the pin's subject.
- Suites: core `swift test` **1927 tests / 202 suites passed** (baseline 1913/200 at 13i-b's
  close → +14 tests / +2 suites); Mac `xcodebuild … build-for-testing` + `test-without-building`
  over BindDoor · RuleEditor · DoorSet · TimelineAndReadings · WalkBuildRound ·
  StarredGatheringSeeder · PoolTuckFace · BookArrivals · TutorialWalk · ShelfAndPalette —
  **83 / 9 passed** (the tutorial spine included); mobile `VariorumMobile` generic iOS
  Simulator **BUILD SUCCEEDED**. Zero instances throughout (`pgrep` clean).

### FINDINGS (for the record; none a STOP condition)

- **F-U1-1 (U3 carries it):** the 13i-b rule editor's auto-tag row now reads the set's FIRST
  tag and writes a one-element set — a book given two outflow tags headless would show one and
  a save there would overwrite the set with one. No door mints two until U3's chooser, which
  retires the row and the forwarder together.
- **F-U1-2 (U3 carries it):** the Mac's "Create Smart Book" door REFUSES now (the op's guard)
  with the shared words — honest, but a refusal where a mint flow belongs; U3's inline editor is
  the door. The phone's gathering mint already requires ≥1 tag (`MobileCreateBook.canCreate`),
  so it never meets the refusal.
- **F-U1-3 (recorded):** `RuleEditorCopy`'s gathering empty-state sentence still says "shows
  every note" — false since R-13ic-4; U3 re-words it ("shows nothing until it has a rule").
- **F-U1-4 (recorded, the walk's to confirm):** the dev store may carry rule-less gatherings
  from 13i-b's walks (F-U4-7's shape); the first Debug launch sweeps them to the Trash. Her REAL
  store: unknown (encrypted; never touched) — the window's first launch does the same, and the
  Trash is the record (her words: "we can maybe just drop the book, it won't drop the note").
- **Tutorial (P-6):** no lesson sentence went false; no lesson prose rewritten — no re-seed
  consequence.

## U2 BRIEF — THE OWNED + SEALED OP FAMILY + THE DOOR ENUMERATION (`opus-implementer`; read this whole file first)

**Read, in your own context, before any code:** CLAUDE.md + its canon; this plan WHOLE (§1 her
rulings · §3 Owned · §4 the enumeration rows 1–12 · §5 Finished/Sealed · §6 delete/duplicate/Trash
· §7 the U2 row's evidence · §8 traps · §9 the PROVISIONALs already made · the U1 RECORD);
`notes/plans/phase-13i-sitting-record-2026-09-30.md` §1, §2, §5, §6, §14.10, §18.3, §18.4, §20,
§24 (the binding design); `notes/plans/phase-13i-b-gatherings.md` §2 + its U1 RECORD (intake as
built — your owned arms' host); `notes/SyncSpec.md` §7's OWNED-exclusivity paragraph (R2 — the
revival pass mirrors its shape locally; you write ZERO `Sync/` lines); `notes/SessionResiliencyProtocol.md`.
Code to orient on: `Domain/IntakeDecision.swift`, `Operations+Intake.swift`,
`Operations+Reading.swift`, `Operations+ReadingConversion.swift`, `Operations+Diverge.swift`
(the inlined-copy pattern you reuse), `Operations+Versions.swift` (`copyPost`), `Operations+Locks.swift`
(`lockPost`/`unlockPost` bodies to share), `Operations+Container.swift` (`deleteContainer`,
`restoreContainerRows`, `shelveInDailyJournalBook`), `Sync/Repairs.swift`'s
`repairOwnedExclusivity` (read-only — the semantics you mirror), `Queries/ShelfQueries.swift`
(`poolListing`, `readingsContaining`), `Queries/Trash.swift`, `Queries/AppearanceQueries.swift` +
`Operations+Appearance.swift` (`setArrivalFlash` — the not-seeded setting pattern for the two new
keys), `Tests/VariorumCoreTests/IntakeOperationsTests.swift` + `Phase13iRepairTests.swift` (the
harness idioms).

**Scope (ONE unit — operations/domain, headless):** everything §3, §5 and §6 name as an OP or a
QUERY, plus §4 rows 1–12, the three readers' `kind='book'` scoping, the two settings
(`hide_owned_default` "0"=SHOW, `ownership_badges` "1"; synced, not-seeded, read in
`Queries.AppearanceQueries` like `arrival_flash`), the hide-owned SQL fragment, the badge-facts
query, the `OpsRefusalTable` words for every new refusal (platform-neutral sentences — name no Mac
door). NOT yours: any face (U3/U4), any `Sync/` line, any schema (a need for either is a STOP —
write the record and report). Suggested homes: `Domain/OwnershipDecision.swift`,
`Operations+Ownership.swift` (own/un-own, the add consult, copy-in, move-in, the judgment arms,
the revival pass, the bind limb), `Operations+Seal.swift`, the delete/duplicate ops beside
`deleteReading` in `Operations+Reading.swift`, `Queries/OwnershipQueries.swift` (previews, facts,
the fragment, `trashBookNoteCount`). New `OperationError` cases (each with words):
`noteMemberedElsewhere(postID:readingID:elsewhere:)`, `noteOwnedElsewhere(postID:readingID:owner:)`,
`readingSealed(id:)`, `readingNotSealed(id:)`, `ownedBookDuplicatesDeep(id:)`;
`DailyBookShelving` gains `.waitingAtDoor(readingID:)`.

**The design forks reserved for the architect** (the implementer proposes, the architect rules —
stop and report BEFORE building that half if you find one): any place where §3/§5/§6 are silent
on a product-flavored edge. Everything the sections DO say is settled — build it; a doubt about a
settled line goes in your FINDINGS, not into a different build.

**Evidence (the §7 U2 row, restated):** exact state-transition suites per op; `OwnershipDoorTests`
(rows 1–12 of §4 — one test per row, named for the row, each asserting the consult AND the
outcome); the headless soak (`OwnershipSoakTests`: randomized own/un-own/add/copy/move/seal/unseal/
delete/restore over several books; invariants — no note live-membered in an owned book AND
elsewhere; every member's seal stamp equals its book's or is independent; no duplicate live pair;
I10 untouched); `OwnershipRitualTests` (the R4 ritual headless + lesson sentences 5/6/8 as pins);
the FULL core suite green at the END; the Mac app + the phone BUILD (`xcodebuild -scheme Variorum
-destination 'platform=macOS' build` from `App/Variorum/`; `-scheme VariorumMobile -destination
'generic/platform=iOS Simulator' build`) and every Mac/mobile suite that exercises a changed op.
A pin green on both sides of a claimed fix is hollow — record, don't fix.

**Your record:** a `## U2 RECORD` section in THIS file directly above `## §8 ENVIRONMENT TRAPS`,
in the U1 RECORD's shape — the NOT-DONE line FIRST, the design map as shipped, PROVISIONALs (each
with a QUESTIONS-ready paragraph; numbered P-13ic-U2-n), FINDINGS (for the orchestrator; name the
owner you suggest), then your LIVE STATUS (per commit; unverified claims PENDING). Flip ledger
row 3 in the same commit as the close. Commit per piece, `git pull --rebase` then push after every
commit, foreground waits only, no subagents (one Sonnet read-only lookup at most). The §8 traps
bind verbatim: zero instances before any suite that mounts windows; never touch `/Applications`;
the dev store never syncs; `pipestatus`; never a custom build configuration.

## U2 RECORD — THE OWNED + SEALED OP FAMILY + THE DOOR ENUMERATION (`opus-implementer`, 2026-10-01)


**NOT DONE BY THIS UNIT (first line, per the contract):** no face of any kind (U3/U4 — the confirms,
the choice sheet, the badges, the Settings rows, the Trash's "and N notes" row; the ⌘J/phone
`.waitingAtDoor` notes are generic compile arms, U4 names the owner); no dev-store GUI walk (U2 is a
headless op family — its evidence-of-kind is the plan §7 U2 row's headless set; the first visible walk
of these ops is U3's/U4's); NO `notes/QUESTIONS.md` entries written (the brief's rule — each
PROVISIONAL below carries its QUESTIONS-ready paragraph for #169 at close); NOT the `unlockPost`-
inside-a-sealed-book question (FINDING F-U2-1 — a fork reserved for the architect, unbuilt); zero
`Sync/`, zero schema, zero `Server/` — none was needed, no STOP condition met.

**UNIT STATUS: CLOSED 2026-10-01 — every evidence item of the plan §7 U2 row green (below): core
2001 tests / 211 suites (1 standing env-gated skip) · Mac 772/135 · phone 102/16 · both apps build.**

### What U2 built (the design as shipped — a fresh session's map)

- **`Domain/OwnershipDecision.swift`** — the pure table: `verdict(targetOwned:note:)` → `.add` ·
  `.needsChoice(.copyOrMove)` (owned target, note membered elsewhere — a competing owned book
  included, §18.4) · `.needsChoice(.copyOnly)` (plain target, note owned elsewhere). Pinned cell-
  for-cell against intake's owned arms (every choice is a bell there, every add a seat).
- **The three readers' `kind='book'` (13i-b F-R1-7, ruled as one):** `membershipElsewhere`, the
  Pool's exclusion (a correlated reading probe — the P1 plan pin holds), `readingsContaining`'s
  member leg. Red-on-old pins `MembershipReadersBookScopeTests`.
- **`Operations+Ownership.swift`:** `consultOwnership` (the one consult — wired into
  `addPostToReading` and `seatArrival` AFTER the capacity gate); `ceremonyCopy` (the `copyPost`
  family + the note's live tags copied as ROWS — P-13ic-U2-1; a blockless note copies BARE —
  P-13ic-U2-2); `forkInPlace` (the diverge body inlined: the copy takes the exact slot — position
  AND chapter; the original's row here a member-class tombstone); `setReadingOwned` both ways
  (`OwnConversionResult.copied: [OwnershipFork]`); `copyPostIntoReading(_:into:at:)` +
  `(answering:)` (`CopyInResult`; the copy's membership FIRST, then the target's outflow; ONE undo
  entry, `duplicateAsVersion`-shaped); `movePostIntoReading(_:into:at:)` + `(answering:)`
  (`MoveInResult.severed` — every other live row in live books, members AND arrivals; refuses while
  a severed MEMBER sits in a FINISHED book — P-13ic-U2-4; no undo, P-13ic-12);
  `enforceOwnershipAfterRevival` (THE REVIVAL PASS — R2's shape locally, ranked `created_at, id`,
  P-13ic-9); `setReadingHideOwned` (gatherings only, nil = follow the default); `bellAtDailyDoor`;
  `isBookless`.
- **`Operations+Seal.swift`:** `sealReading` (forks the shared members · finishes + dismisses
  pending arrivals · `sealed_at = now` · every member sealed with `locked_at = now` through the
  shared `sealPost` body — dirty buffers insured; independent seals untouched; `SealResult`);
  `unsealReading` (exact-stamp members unseal, `sealed_at` clears, `locked = 0`, the catch-up
  fires — R-13ic-3); `liveMemberPostIDs`.
- **Guards on the finish ladder:** `unlockReading` on a sealed book refuses `readingSealed`;
  `lockReading` on a sealed book is a no-op; `setReadingOwned(true)` on finished/sealed refuses
  `lockedReading` (P-13ic-2); `lockPost`/`unlockPost` now call the shared `sealPost`/`unsealPost`.
- **Book doors (`Operations+Reading.swift`):** `deleteReadingWithNotes` (each member through the
  shared `tombstoneNoteFamily` body — versions ride — then the book, ONE stamp; refuses only a
  gathering; clears the redo future); `duplicateReading(_:name:deep:)` (configuration not state —
  P-13ic-7; chapters copied and re-pointed; members at their positions, arrivals never; shallow
  refuses an owned source `ownedBookDuplicatesDeep`; the daily marker → the trait, P-13ic-U2-5);
  `restoreReading` returns WHOLE (stamp-matched member notes first through the shared
  `restoreNoteFamily`, then memberships — a SEALED book takes back only sealed members, P-13ic-U2-6
  — then the revival pass, then the catch-up); `removePostFromReading` returns BOOKLESS.
- **Revival-pass call sites:** `restoreContainer` (+ a sealed book takes back only a sealed note,
  P-13ic-U2-6), `restoreReading`, `reapplySmartConversion` (AFTER the kind flip), `revertDiverge`
  (an ADDITION to the plan's list — the diverge UNDO revives the original's row), `reapplyDiverge`;
  `reapplyMintedContainer` rides `restoreContainer`.
- **The bind's owned-notes limb:** `convertSmartReadingToCurated(_:order:ownedNotes:)` —
  `.leaveOut` (default, P-13ic-4; `result.leftOut`) · `.copyIn` (`result.copied`, the copy in the
  note's slot).
- **`shelveInDailyJournalBook`** → `.waitingAtDoor(readingID:)` (an arrival rung, never a throw);
  the Mac's ⌘J and the phone's Today door gained honest compile arms.
- **`Operations+Appearance`:** `setHideOwnedDefault` / `setOwnershipBadges` (synced, not seeded —
  the `arrival_flash` pattern); `ThemeSettings.hideOwnedByDefault` (only "1" hides) /
  `.ownershipBadges` (only "0" silences).
- **`Queries/OwnershipQueries.swift`:** `noteMemberships`, `sharedMembers` (THE fork set — the op
  and every confirm read it), `ownConversionPreview`, `moveInPreview` (flags finished books),
  `bindOwnedNotesPreview`, `trashBookNoteCount`, `sealPreview` + `pendingArrivalCount` (the
  Arrivals face's own predicate), `ownedElsewhereExclusion` (THE fragment), `hideOwnedDefault`,
  `hidesOwned`, `ownershipFacts(postIDs:inBook:)` (one page-driven statement). The fragment is
  composed by the gathering assembly, the chip's and the listing page's gathering legs
  (`smartMembershipSQL(hidesOwned:)`) and `taggedPostItems` (global default only); the Library is
  untouched (R32).
- **`copyPost`** — every copy now born in its SOURCE's wing (§9 isolation; unreachable until 13i-d).
- **The shared refusal words** (`App/Variorum/Shared/OpsRefusalTable.swift`) for all five new
  refusals, platform-neutral; a new `bookSeal` ROAD (`OpsRefusalRoads.BookSealWords`) because the
  integrity walk bans the seal's stem in the shared file — the Mac passes `sealed`/`unseal`, the
  phone `sealed` with no verb (no book-seal door there yet; the sentence promises none). The phone's
  membership face inherits the ownership words through its existing table fall-through (§4 row 22).

### Evidence (each named before the build — the plan §7 U2 row)

- **Exact state-transition suites per op:** `OwnershipOperationsTests` (20 — the consult, own/
  stop owning, the empty fork, the wing, copy in + tags-as-rows-not-acts + answering + undo/redo,
  move in + answering + the finished guard + the daily Journal claim, the daily bell both ways,
  release), `OwnershipBookDoorsTests` (14 — the revival pass per door, the bind limb both ways,
  delete-with-notes + restore whole + a note put back alone, duplicate shallow/deep/daily/gathering),
  `BookSealTests` (9 — seal, owned seal fork-free, finished/gathering/no-op, unseal reopens with the
  catch-up, the contradiction guards, a deleted sealed book, lesson 6's first sentence, and the
  soak's two found pins), `OwnershipHideAndBadgesTests` (6 — the default SHOW, the global switch
  across the assembly/chip/page/tag listing with the Library exempt, the per-gathering override,
  the toggle's guards, the two settings, the badge facts + their P1 plan pin),
  `OwnershipDecisionTests` (5), `MembershipReadersBookScopeTests` (3, red-on-old).
- **`OwnershipDoorTests`** — the §4 table rows 1–12, ONE test per row, named for the row, each
  asserting the consult, the outcome and the exclusivity invariant.
- **`OwnershipSoakTests`** — 6 seeds × 250 steps over own / stop owning / add / copy in / move in /
  both answering arms / remove / seat / dismiss / tag / finish / reopen / seal / unseal / delete
  both ways / restore a book / delete + restore a note / duplicate both ways / diverge; invariants
  after EVERY step: exclusivity, every member of a sealed book sealed, no duplicate live pair, I10,
  I2; and the machinery must actually have been exercised (own, copy in, move in, seal, unseal, a
  choice refusal, a book restore, delete-with-notes). **It found a real breach on its first run**
  (seeds 3 and 777 — see P-13ic-U2-6), fixed red-first.
- **`OwnershipRitualTests`** — R4 headless (own → the copy choice → copy in → release → the Pool) and
  lessons 5, 6, 8 as sentence pins.
- **Red-on-old, by behavioural revert** (committed tree; an early `return` in the revival pass AND
  the consult; restored by `git checkout`, the marker grep 0, green again): every revival pin and
  every consult pin red (18 issues / 34 tests). The three readers' pins and the soak's two sealed-
  revival pins were red on the pre-fix tree before their fixes.
- **Honest test edits (subject untouched, each commented at the pin):**
  `Phase13iRepairTests.aLaterPlainAddBesideAStandingOwnedClaimTombstones` (its fixture pulled A's
  claim onto B and then hand-added — row 1 now refuses that road by design; B now adds without
  having seen the claim, which IS the race R2 pins); `SampleLibrarySignedOutRetirementTests.
  putBackReturnsTheRetiredCopy` (pinned #85(e)(ii)'s recorded "fourteen put-backs" — the question it
  recorded is answered by §18.3 / this plan §6: the book returns WHOLE).
- **Suites:** core `swift test` FULL — **"Test run with 2001 tests in 211 suites passed"** (1
  skipped: the standing env-gated Supabase integration test; baseline 1927/202 at U1's close →
  +74 tests / +9 suites, this unit's nine new suites exactly); the per-piece
  regression sweeps green (639/67 · 848/85 twice · 654/61 · 370/39). Mac `build` + `build-for-
  testing` GREEN; the 135 Mac suites naming an op whose behaviour changed (63 files —
  `addPostToReading`, the arrival judgment, the daily door, `restoreReading`/`restoreContainer`,
  the bind, finish/reopen, the refusal tables, the theme settings, the Pool/chip/listing/tag
  readers, recovery/deletion words) — **"Test run with 772 tests in 135 suites passed"** (4 known
  issues = the pre-existing `withKnownIssue` TK2 marks in `IndexTierMetricsTests`; zero skips). The
  phone generic-sim BUILD SUCCEEDED; the 16 phone suites naming a changed op on the iPhone 17 Pro
  simulator — **"Test run with 102 tests in 16 suites passed"** (2 known issues = the deliberate
  marks in `MobileTrashTests`). Zero app instances before and after (`pgrep` clean). DerivedData:
  `App/Variorum/DerivedData/13ic-u2`, `13ic-u2-ios`, `13ic-u2-iossim` (+ their `.log`s) — the
  phase is open; the closeout's tidy sweeps them.

### PROVISIONALs made in U2 (each QUESTIONS-ready for #169; the plan's §9 P-13ic-1…12 were built as written)

- **P-13ic-U2-1 — A ceremony copy's riding tags are a ROW COPY, not a tagging act.** The tags land
  on the copy, but no living book "hears" them (intake fires only on applying acts); the target
  book's OWN outflow (copy in) IS an act and is heard. Why: the plan inserts the copy's membership
  FIRST so the pair is decided "before any tag fires intake elsewhere", which only makes sense if
  the riding tags fire nothing; and it keeps a seal's forks from being re-shared by another book's
  intake the moment they are minted. *QUESTIONS paragraph:* "When a copy is made for an owned-book
  reason (owning a book, copying a note in, sealing, a deep duplicate), its tags come with it. Should
  those tags also pull the COPY into your living books the way tagging a note by hand does? (a) No —
  the copy just wears them; only tagging by hand (or a book's own auto-tag) pulls notes in — BUILT;
  (b) yes, the copy's tags count as fresh tagging (then a sealed book's copies could land in other
  books immediately)."
- **P-13ic-U2-2 — An EMPTY note forks as a bare note** (its row and its tags; no blocks, so no
  lineage edge — an edge joins blocks). `copyPost` refuses a blockless note, and a ceremony obliged
  to fork must not fail on one. *QUESTIONS paragraph:* "If a book you own or seal shares an EMPTY
  note with another book, it still gets its own copy — (a) an empty copy with no 'came from' link
  (there's no text to come from) — BUILT; (b) refuse the whole act until the empty note has text;
  (c) give the empty original a blank first line so the copy can link to it."
- **P-13ic-U2-3 — Answering an arrival with Copy in / Move in lands at the END, unsectioned** (the
  `seatArrival` rule, §4 "arrivals land at the end"), and Copy in's copy gets the book's OUTFLOW (a
  hand-add's class — her hand made the copy) while a plain seat never does (P-13ib-U1-3). *QUESTIONS
  paragraph:* "When you answer something waiting at a book's door by copying it in, the copy goes to
  the end of the book and gets the book's auto-tags — (a) as built; (b) no auto-tags, to match
  'Add' on an arrival (which never tags); (c) auto-tags on Add too."
- **P-13ic-U2-4 — Move in REFUSES while one of the memberships it would sever is in a FINISHED (or
  sealed) book** (`lockedReading` naming THAT book): finishing froze that book's contents and a
  move is a removal there; Copy in stays open; the preview flags the row. Waiting arrivals elsewhere
  are severed freely (they are not contents); Move in onto a PLAIN book is legal (release + add —
  the faces offer it only on owned books). *QUESTIONS paragraph:* "If a note you want to MOVE into an
  owned book is also in a book you've marked Finished, should the move (a) refuse and offer Copy in
  instead — BUILT; (b) take it out of the finished book anyway (the claim outranks the finish); or
  (c) move it but leave the finished book's membership standing?"
- **P-13ic-U2-5 — Duplicating the daily Journal makes an ordinary journal-trait book**, never a
  second daily Journal (the `'daily'` marker names THE one book; only `setDailyJournalBook` moves
  it). *QUESTIONS paragraph:* "Duplicate the daily Journal and you get a journal-style book that is
  NOT where ⌘J files — (a) as built; (b) make the duplicate the new daily Journal."
- **P-13ic-U2-6 — A membership revives into a SEALED book only when its note is itself sealed**
  (`restoreContainer` and `restoreReading` both) — found by the soak: a note in the Trash when its
  book was sealed came back INTO the sealed book, editable. The door's own answer (a sealed book
  refuses every add) is that it comes back outside the edition; a note sealed with the book comes
  home with it as before. *QUESTIONS paragraph:* "A note that was in the Trash when you sealed its
  book is put back. Should it (a) come back on its own, NOT inside the sealed book (unseal the book
  and add it by hand if you want it) — BUILT; (b) rejoin the sealed book and be sealed with it (its
  text then freezes everywhere it lives); (c) rejoin unsealed (the book would then hold an editable
  note)?"
- **P-13ic-U2-7 — Hide-owned's reach includes the membership chip's and the listing page's
  gathering legs** (so no surface claims a gathering shows a note it hides), and tag listings follow
  the GLOBAL default only (they have no per-listing toggle); `everythingTagged` (an ops-facing
  lookup) is not composed. *QUESTIONS paragraph:* "When a gathering hides owned notes, the 'appears
  in' chip on such a note stops listing that gathering too — (a) as built; (b) keep listing it."
- **P-13ic-U2-8 — Stop owning is allowed on a finished or sealed book** (it moves no row; P-13ic-2
  governs owning only). *QUESTIONS paragraph:* "(a) Allowed — BUILT; (b) refuse until reopened."
- **P-13ic-U2-9 — Ceremony copies are born UNARCHIVED** (the copy family's letter — `copyPost`
  copies title/profile/date/notes/segmentation, never the archive state; the older diverge door
  behaves the same). Consequence: forking an ARCHIVED shared member makes the copy visible in the
  book where the original was hidden. *QUESTIONS paragraph:* "If a book you own or seal shares a note
  you had ARCHIVED, its copy (a) arrives unarchived, so the book now shows it — BUILT; (b) arrives
  archived too, so the book reads exactly as before."

### FINDINGS (for the orchestrator; none is a STOP condition)

- **F-U2-1 (a reserved fork — the architect's; suggested owner U3):** `unlockPost` on a member of a
  LIVE SEALED book is still allowed — a single note can be unsealed while its book says Sealed,
  which softens "Sealed = the book is done" (required text immutability). Options: refuse while the
  note's `locked_at` equals a live sealed book's `sealed_at` (a new refusal, the op-level belt), or
  leave the op and have the faces hide per-note Unseal inside a sealed book. NOT built (a product
  edge the plan is silent on); the soak's seal invariant excludes per-note unseal for this reason.
- **F-U2-2 (closeout):** QUESTIONS #85(e)(ii) ("should `restoreReading` revive stamp-matched member
  containers?") is ANSWERED by §18.3 / this plan §6 and built here — the closeout marks it.
- **F-U2-3 (recorded):** the `copyPost` wing fix reaches every copy door (duplicate-as-version,
  promote, outline mint, diverge) — all now born in the source's wing; unreachable until 13i-d mints
  a second wing; pinned on the ownership ceremonies.
- **F-U2-4 (recorded):** the plan's revival-pass list missed `revertDiverge` (the diverge UNDO
  revives the original's membership) — built and pinned (row 9 + `OwnershipBookDoorsTests`).
- **F-U2-5 (recorded, pre-existing):** a FINISHED (not sealed) book still takes back a revived
  membership from `restoreContainer` (the freeze is her doors'; the exact-stamp revival predates
  it). The sealed guard (P-13ic-U2-6) is deliberately narrower. Suggested owner: 13i-d's look at the
  finish faces, if she wants the freeze to bind recovery too.
- **F-U2-6 (U4 carries it):** the ownership refusals carry ids only (the brief's signatures); the
  faces name the books through `noteMemberships` / `moveInPreview` / `ownershipFacts`. The ⌘J and
  phone `.waitingAtDoor` notes are generic until U4 names the owner.
- **F-U2-7 (U4's face discipline):** `deleteReadingWithNotes` refuses only a gathering (the plan's
  letter) — on a PLAIN book it would delete notes that live in other books; the door must offer it
  only on an owned book (ruled).
- **F-U2-8 (MobileSoul row at closeout):** the phone's membership face now speaks the shared
  ownership words through `MobileMembershipModel.refusal`'s table fall-through (§4 row 22) — "it can
  come in as a copy…" names the ceremony, not a door; the phone's sheets are the mobile catch-up's.
- **F-U2-9 (recorded):** after a book returns whole, a stale Trash row for one of its notes answers
  "That note is already back." (the shipped `DeletionRefusal` words) — honest.
- **Tutorial (P-6):** no lesson sentence went false; lessons 5, 6, 8 and R4 are now pinned true
  headless. No lesson prose rewritten.

### LIVE STATUS (per commit; every unverified claim PENDING)

- **Piece A — `Domain/OwnershipDecision` + the three readers' `kind='book'` (F-R1-7):**
  DONE (the commit that opened this record). `OwnershipDecisionTests` (5, pure, incl. the
  cell-for-cell agreement with intake's owned arms); `MembershipReadersBookScopeTests` (3) RED on
  the pre-fix tree, each reader (owned book belled a free note → `arrival`; the Pool dropped the
  note; the chip listed `[g, g, quiet]`), GREEN after `AND r.kind='book'` in `membershipElsewhere`,
  the Pool's exclusion (a correlated reading probe — the P1 plan pin `PoolTuckTests` still green)
  and `readingsContaining`'s membership leg. Filtered run: 58 tests / 5 suites green.
- **Piece B — the membership roads:** DONE (commit "13i-c U2 piece B"). The five
  `OperationError` cases; `Operations+Ownership.swift` (the consult, `ceremonyCopy` + tags as
  rows, `forkInPlace`, `setReadingOwned` both ways, copy-in + its answering arm + undo/redo,
  move-in + its answering arm, the daily bell); `addPostToReading` + `seatArrival` consult after
  the capacity gate; `shelveInDailyJournalBook` → `.waitingAtDoor(readingID:)`;
  `removePostFromReading` → `Bool` (bookless); `copyPost` born in the source's wing;
  `Queries/OwnershipQueries.swift` (`noteMemberships`, `sharedMembers`, `ownConversionPreview`,
  `moveInPreview`). `OwnershipOperationsTests` 20/20 green; every core suite naming a touched op
  (639 tests / 67 suites) green after ONE honest fixture re-order:
  `Phase13iRepairTests.aLaterPlainAddBesideAStandingOwnedClaimTombstones` pulled A's claim onto B
  and THEN hand-added — a road row 1's consult now refuses by design; the race it pins is B adding
  WITHOUT having seen the claim, so B now pulls the note before A claims it (repair untouched).
  App compile arms for `.waitingAtDoor` DONE (2509647d); the refusal words DONE (the closing
  commit, piece F).
- **Piece C — the revival pass + its call sites, the bind's owned-notes limb, restore-whole,
  delete-with-notes, duplicate, the Trash count:** DONE (commit "13i-c U2 piece C").
  `enforceOwnershipAfterRevival` called from `restoreContainer`, `restoreReading`,
  `reapplySmartConversion` (AFTER the kind flip — the pass reads books only; caught by its own pin),
  `revertDiverge` (an addition to the plan's list: the diverge UNDO revives the original's row) and
  `reapplyDiverge`; `reapplyMintedContainer` rides `restoreContainer`. `deleteContainer`'s and
  `restoreContainer`'s bodies shared (`tombstoneNoteFamily`, `restoreNoteFamily`);
  `deleteReadingWithNotes` (one stamp); `restoreReading` returns WHOLE (stamp-matched member notes
  first, versions riding); `duplicateReading` shallow/deep; the bind's
  `ownedNotes: .leaveOut | .copyIn`; `Queries.bindOwnedNotesPreview`, `trashBookNoteCount`.
  `OwnershipBookDoorsTests` 14/14; the regression sweep over every suite naming a touched op
  (848 tests / 85 suites) green after ONE honest flip:
  `SampleLibrarySignedOutRetirementTests.putBackReturnsTheRetiredCopy` pinned #85(e)(ii)'s
  recorded "fourteen put-backs" shape — the question it recorded (should `restoreReading` revive
  stamp-matched member containers?) is answered by §18.3 / this plan §6, so the book's Put back
  now brings the notes home and a member's own Put back refuses `containerNotDeleted`.
  **Red-on-old, by behavioural revert** (committed tree; an early `return` in
  `enforceOwnershipAfterRevival` AND in `consultOwnership`; restored by `git checkout`, the
  marker grep 0, green again): all FIVE revival pins red (owned-restore's later plain row stayed
  live; plain-restore's owned claim stayed a member; the note restore; the bind redo; the diverge
  undo — twice), and every consult pin red (row-1 add ×2, the seat, the daily bell ×2) — 18
  issues / 34 tests. No revert in flight.
- **Piece D — Seal / Unseal, the lock/unlock guards:** DONE (commit "13i-c U2 piece D").
  `Operations+Seal.swift` (`sealReading` — forks · finish+dismiss · stamp · members sealed on the
  exact stamp; `unsealReading` — exact-stamp members, open in one step, the catch-up);
  `lockPost`/`unlockPost` bodies shared (`sealPost`/`unsealPost`); `unlockReading` refuses
  `readingSealed`; `lockReading` on a sealed book a no-op; `Queries.sealPreview` +
  `pendingArrivalCount` (the Arrivals face's own predicate). `BookSealTests` 7/7 (lesson 6's
  first sentence pinned there); the lock-op regression sweep 654 tests / 61 suites green.
- **Piece E — hide-owned (fragment + setter + the setting), the badge facts, `ownership_badges`:**
  DONE (commit "13i-c U2 piece E"). `setReadingHideOwned` (gatherings only, nil = follow the
  default, no-op-guarded); `setHideOwnedDefault` / `setOwnershipBadges` (synced, not seeded, the
  `arrival_flash` pattern; `ThemeSettings.hideOwnedByDefault` (only "1" hides) /
  `.ownershipBadges` (only "0" silences)); `Queries.ownedElsewhereExclusion` (ONE argument-free
  fragment) composed by the gathering assembly, the chip's gathering leg, the listing page's
  gathering leg (`smartMembershipSQL(hidesOwned:)`) and `taggedPostItems` (global default only);
  the Library untouched (R32 — pinned); `Queries.hidesOwned`, `hideOwnedDefault`;
  `Queries.ownershipFacts(postIDs:inBook:)` (one page-driven statement, P1 plan-pinned).
  `OwnershipHideAndBadgesTests` 6/6; the readers/settings regression sweep 370 tests / 39 suites
  green.
- **Piece F — `OwnershipDoorTests` rows 1–12, the soak, the R4 ritual + lessons 5/6/8; the shared
  refusal words + the app compile arms; Mac + phone builds + touched suites; the FULL core suite;
  the record closed; ledger row 3:** DONE (the closing commit). `OwnershipDoorTests` 12/12;
  `OwnershipSoakTests` (6 seeds × 250 steps — it found the sealed-revival breach, fixed red-first,
  P-13ic-U2-6); `OwnershipRitualTests` 4/4 (R4 + lessons 5, 6, 8); the shared refusal words for all
  five new refusals + the `bookSeal` road (Mac `sealed`/`unseal`, phone `sealed`/no verb); the
  app compile arms (2509647d). Mac `build-for-testing` GREEN + 135 suites — 772 tests passed (4
  pre-existing known-issue marks, zero skips); phone generic-sim BUILD SUCCEEDED + 16 suites on the
  iPhone 17 Pro simulator — 102 tests passed (2 deliberate known-issue marks); FULL core — 2001 tests
  / 211 suites passed (1 standing skip). Zero app instances throughout. Ledger row 3 flipped in
  this commit.
- No revert in flight.

## THE ARCHITECT'S ADJUDICATION AFTER U2 (2026-10-01 — the mandate's small-code allowance; the ladder reviews it cold)

- **F-U2-1 RULED AND BUILT: a note's own Unseal refuses inside a live sealed book.** "Sealed = the
  book is done" is text immutability for EVERY member, so `unlockPost` throws the new
  `noteInSealedBook(postID:readingID:)` while a LIVE sealed book holds the note as a live member —
  its own seal stamp or an independent one alike (the book's promise is about its members, not
  about who sealed them); a sealed book in the Trash suspends its promise with it. The road out is
  the book's Unseal (which reopens it, R-13ic-3). The shared words ride the `bookSeal` road ("This
  note is in a book that is sealed — unseal the book to change it."). Pin
  `SealedBookMemberUnlockTests` (2; RED-ON-OLD watched: four issues on the pre-fix tree). Core
  2003/212 green after it; the Mac refusal-table integrity + convergence + spine suites 32/4 green.
  U3's faces: the note's Unseal door inside a sealed book shows the refusal (P-2 — or hides, the
  implementer's call with the registry's availability rule).
- **The U2 RECORD's PROVISIONALs P-13ic-U2-1…9 stand as built** (each spec-defensible on its
  stated ground; filed at QUESTIONS #169 at close). **F-U2-5** (a FINISHED book takes back a
  revived membership) stays recorded with its suggested owner. **F-U2-2** (#85(e)(ii) answered)
  lands at the closeout.

## U3 BRIEF — THE SETTINGS SHEET · THE OUTFLOW CHOOSER · THE STATE DOORS · THE MINT (`opus-implementer`; read this whole file first)

**Read, in your own context, before any code:** CLAUDE.md + its canon; this plan WHOLE — §1 her
rulings · §2 (the outflow as shipped) · §3/§5/§6 (the ops you put faces on) · §7 the U3 row ·
§8 traps · §9 · the U1 RECORD (its F-U1-1/2/3 are YOURS) · the U2 RECORD (the op names and
signatures as built; its F-U2-6 names the preview queries your confirms read) · the adjudication
above; the sitting record `notes/plans/phase-13i-sitting-record-2026-09-30.md` §4 (the Collecting
pane's sentences — "Gathers from: …" · "New matches: …" · "Notes written here are tagged: …"), §5,
§6, §21–§24 (the design-language anchor: the app's own shipped idioms, its tokens and spacing —
never the mockup's rounded edges; `Theme/VoiceControls.swift` is the chrome vocabulary; chrome
`fixedSize` texts carry a `lineLimit`); her post-close ruling 2 in this file (the settings sheet
carries the Collecting section — her discoverability report); `notes/SessionResiliencyProtocol.md`.
Code to orient on: `Features/BookView/BookView.swift` (`BookSettingsSheet`, ~line 2491),
`Features/Shelf/ShelfView.swift` (the book menu, the Create Smart Book door, the spawn prompt),
`Features/Readings/RuleEditor.swift` (the model, the auto-tag row, `RuleEditorCopy`),
`Features/Readings/BookOrderAndConversion.swift` (`BindCopy`, the spawn sheet),
`Features/Shelf/ShelfViewModel.swift` (`spawnBook`, `setFinished`), `Registry/CapabilityRegistry.swift`
(every act declared ONCE — P-1; the registry walk test), `Registry/OpsRefusalCopy.swift` (the
Mac's roads incl. `bookSeal`), `Shared/OpsRefusalTable.swift`, `Queries/OwnershipQueries.swift`
(`sealPreview`, `pendingArrivalCount`, `ownConversionPreview`, `sharedMembers`),
`Queries/CollectingQueries.swift` (`membersMissingAnyOutflowTag`), the 18i status seam (`StatusCenter`:
refusal · offer · receipt; receipts honor `receipt_style`).

**Scope (ONE unit — the book's SETTINGS surface and its doors; no membership-door face, no
badge, no delete/duplicate face — those are U4's):**
1. **The Book Settings sheet** (and the gathering's — the SAME pane, §4): Name · Word target ·
   Note cap (as today) · a **COLLECTING** section written as sentences — "Gathers from: <the rule's
   live paths, or 'nothing by itself'>" · "New matches: join quietly / wait at Arrivals" ·
   "Notes written here are tagged: #a #b / nothing" — with ONE "Edit…" door opening the rule
   editor sheet (her report: the sheet carried no rule/dial/outflow; this is the fix); on a
   gathering the section shows the rule + the HIDE-OWNED toggle (`setReadingHideOwned`; nil =
   follow the default, "0"/"1" explicit — three states, worded) and no dial/outflow. · A **STATE**
   section: **Finished** (the toggle; when `pendingArrivalCount` > 0 the flip asks with §24's one
   line "N waiting at the door will be dismissed", else acts; Reopen is the same toggle off) ·
   **Sealed**: "Seal…" (the confirm LISTS the notes that will FORK — `sealPreview` names them with
   where else they live — and carries the N-waiting line; on an owned book it says no copies are
   needed; sealing an open book says it finishes it too) / "Unseal" (the confirm says it REOPENS
   the book — R-13ic-3; `unlockReading` on a sealed book refuses, so the Reopen control is hidden
   or disabled with the sealed words while sealed, P-2) · **Owned**: "Own its notes…" (the
   confirm LISTS the shared members that will be COPIED — `ownConversionPreview` — with where else
   they live; "nothing to copy" when none; refused on a finished/sealed book with the op's words)
   / "Stop owning" (plain, no confirm — members stay). Every confirm's sentences are static copy
   on a pure type (the `BindCopy` precedent) so pins read them without a window.
2. **The rule editor's auto-tag row → the OUTFLOW CHOOSER:** a multi-tag picker over the wing's
   live tags, ordered as chosen (append order), each removable, "none" legal, INDEPENDENT of the
   rule (R-13ic-1); writes through `setReadingOutflow` (retire the `setReadingAutoTag` forwarder
   and every `autoTagID` single read — F-U1-1); the "also tag the N current members" offer now
   asks when the outflow set or the rule changed and `membersMissingAnyOutflowTag` > 0 (its N),
   and `tagAllMembers(nil)` tags every outflow tag (the receipt counts notes). Dead ids show
   "(deleted tag)" and drop on the next save.
3. **R-13ic-4's faces:** on a GATHERING, removing the last term disables the save with the words
   "A gathering needs a rule" and offers **"Delete this gathering…"** (the ordinary Trash road,
   confirmed); the gathering's empty state re-worded — "No rule — this gathering shows nothing
   until it has one." (F-U1-3; a Trash restoree is the only way to see it). **The MINT door
   requires a rule:** the shelf's Create Smart Book flow becomes a mint sheet carrying the rule
   editor INLINE (name + the rule; Create disabled until a term exists; mints through
   `ReadingsViewModel.create(querySpec:)` — the op guard stands behind it); its wording may stay
   "Create Smart Book"/"smart" until 13i-d's vocabulary sweep (say so in the record if you leave
   it). F-U1-2 closes with it.
4. **The spawn sheet's outflow chooser:** the "Make a Book from This Gathering…" prompt gains the
   chooser PREFILLED with `RuleGrammar.positiveTagIDs` (live-filtered) and editable before the
   mint (her ruling: the spawn OFFERS the choice).
5. **The shelf row's menu** gains the state doors beside Finish/Reopen: Seal… / Unseal and Own
   its notes… / Stop owning (the same confirms; one declaration each in the registry — P-1:
   `.finishBook`/`.reopenBook` if not yet declared, `.sealBook`, `.unsealBook`, `.ownBook`,
   `.unownBook`, each with scope `.book`, doors `.contextMenu` (+ the sheet as `.surface`), its
   availability rule as DATA, its refusal copy; the registry walk stays green).
6. **The note's own Unseal door inside a sealed book** (the adjudication above): shows
   `noteInSealedBook`'s words through the status seam, or hides per the registry's availability
   rule — your call, recorded.

**Evidence (the §7 U3 row):** mounted pins per piece (each confirm's sentences; the N>0 gate; the
chooser's save round-trip incl. order and removal; the empty-save refusal + the delete offer; the
mint's gate; the spawn's prefill), the registry walk, the tutorial spine (`TutorialWalkTests`)
green, the FULL core suite green at the END (you may touch core only for copy types/queries the
faces need — no op semantics), Mac `build-for-testing` + every touched suite, the phone BUILD;
and **YOUR OWN dev-store walk** on the Debug build (`io.lduarte.Variorum.debug`; `Tools/WalkKit/`
+ `cliclick`; the author guard `Tools/WalkKit/guard.sh --author` FIRST — if it says someone is at
the machine, STOP, record "walk HELD", and close on pins; never re-activate and retry): open a
book's settings → the Collecting sentences → Edit… → choose two outflow tags → save → the offer
→ Finish with an arrival waiting (the line) → Seal (the listed forks on a shared book; fork-free
on an owned one) → Unseal (reopens) → Own its notes (the listed copies) → Stop owning → a
gathering's settings (hide-owned) → Edit Rule → remove the last term → the refusal + the delete
offer → Create Smart Book → the inline editor gate → spawn with the prefilled chooser. Both
voices (Terminal · Study) × both appearances, captures into `notes/plans/13ic-screens/u3/`
(gitignored). **Also fold in U1's HELD walk:** confirm the first Debug launch's v1_20 ran (any
rule-less gathering now in the Trash; a book's carried outflow shows in the Collecting sentence).

**Your record:** a `## U3 RECORD` section directly above `## §8 ENVIRONMENT TRAPS`, in the U2
RECORD's shape (NOT-DONE first · the design map · PROVISIONALs P-13ic-U3-n with QUESTIONS-ready
paragraphs · FINDINGS with suggested owners · THE WALK with its capture list · LIVE STATUS per
commit, unverified claims PENDING). Flip ledger row 4 at the close. Commit per piece; `git pull
--rebase` then push after every commit; no trailers; foreground waits only; no subagents (one
read-only Sonnet lookup at most); the §8 traps verbatim.

## U3 RECORD — THE SETTINGS SHEET · THE OUTFLOW CHOOSER · THE STATE DOORS · THE MINT (`opus-implementer`, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** no membership-door face, no badge, no
delete-with-notes / two-choice delete / duplicate face, no Trash "and N notes" row (all U4's — the
shelf's "Delete Book" still acts without a confirm, now drawn from the `.deleteBook` declaration U4
extends); no phone face (the phone has no Collecting sentences or state doors — the mobile
catch-up's); NO `notes/QUESTIONS.md` entries written (each PROVISIONAL below carries its
QUESTIONS-ready paragraph for #169); the book navigator's "+ new chapter" road on a RULE-LESS
gathering not hidden (F-U3-4); the "Create Smart Book" / "smart" wording LEFT for 13i-d's vocabulary
sweep (the brief's allowance); zero `Sync/`, zero schema, zero `Server/`; core touched ONLY to retire
the `setReadingAutoTag` forwarder the brief named (no op semantics) and to move its test call sites.

**UNIT STATUS: CLOSED 2026-10-01 — core FULL 2004 tests / 212 suites (1 standing env-gated skip) ·
Mac 445 tests / 73 suites (4 pre-existing known issues, zero skips) incl. the registry walk and all
ten tutorial-walk suites · the phone BUILD green · THE WALK DONE (three defects it found, fixed:
W-1, W-2, W-3) — fifty captures, both voices × both appearances.**

Preflight read in this session's own context: CLAUDE.md + its canon, this plan WHOLE (§1–§11, the
U1/U2 RECORDs, the adjudication, the U3 BRIEF), the sitting record §1–§6, §10, §18, §20–§25, her
post-close ruling 2 (commit 2241d670 — the kickoff rewrite carried it into §7's U3 row),
`notes/SessionResiliencyProtocol.md`, `Tools/WalkKit/README.md`. No editor seam, no `Sync/`, no
schema (TEXTKIT2_NOTES / SyncSpec not required).

### What U3 built (the design as shipped — a fresh session's map)

- **The registry (P-1):** six STATE acts declared once — `.finishBook` `.reopenBook` `.sealBook`
  `.unsealBook` `.ownBook` `.unownBook` (scope `.book`, doors `.contextMenu` + `.surface`, `always`,
  `.native`); `.deleteBook` (`.contextMenu` — the shelf's shipped "Delete Book", now drawn from here
  — + `.surface` — the rule editor's gathering gate); `.editRule` gains `.surface` (the settings
  sheet's "Edit…"). WHICH of each pair renders is DATA — `BookStateDoorSet.rendered(for:)`: Finish
  open / Reopen finished / NEITHER sealed (Reopen refuses there); Seal/Unseal and Own/Stop Owning on
  BOOKS only (both refuse a gathering); Own still renders on a finished/sealed book and speaks the
  op's refusal with its road. The walk's surface union names `BookSettingsSheet` and
  `RuleEditorSheet`; the context union names the shelf's new acts.
- **`Features/Readings/BookStateDoors.swift`** — `BookStateCopy` (every confirm's sentences, every
  receipt, the refusal named for its book — static copy on a pure type, `BookStateConfirm` the
  sheet's whole item), `BookStateDoors` (the one brain: read the book FRESH + the preview its act
  lists — `pendingArrivalCount`, `sealPreview`, `ownConversionPreview` — then confirm or act;
  perform through exactly one op; receipt or refusal on the 18i seam), `BookStateConfirmSheet` + the
  `.bookStateConfirms(_:onLanded:)` modifier (ONE presentation road for the shelf, the settings sheet
  and the rule editor's gate). Finish asks ONLY when N > 0 (§24's one line verbatim); Seal, Unseal,
  Own and the gathering's Delete always ask; Reopen and Stop Owning act at once. The shelf's and the
  book view's `setFinished` RETIRED onto it.
- **`Features/BookView/BookSettingsSheet.swift`** (moved out of `BookView.swift`, P-9) — the SAME
  pane for a book and a gathering: Name · Word target · Note cap (as shipped) · **COLLECTING** as
  sentences (`CollectingCopy`: "Gathers from: <the rule read aloud — `#a and not #b`, `(…)` for a
  nested group, ★ starred, '(deleted tag)'>", or "nothing by itself" on a rule-less book, or the
  whole sentence "No rule — this gathering shows nothing until it has one." on a restoree · "New
  matches: …" · "Notes written here are tagged: #a #b / nothing" — app words voiced, her paths not,
  W-3) with ONE "Edit…" door; on a gathering the rule + the three-state HIDE-OWNED row ("Notes an
  owned book holds:" · "as the app does (shown|hidden)" · "show them" · "hide them" →
  `setReadingHideOwned(nil|false|true)`) and no dial/outflow · **STATE**: the Finished toggle (the
  confirm when arrivals wait; disabled with "A sealed book stays finished — Unseal reopens it." while
  sealed), the seal row (Seal… / Unseal), the own row (Own Its Notes… / Stop Owning).
  `BookSettingsModel` holds the paths + the global default (one-shot, keyed on rule/outflow/toggle)
  and makes the rule editor; **Edit… HANDS it to the book view and closes the settings sheet (W-1)**.
- **The outflow chooser** (`Features/Readings/OutflowChooser.swift`) — `OutflowDraft` (her append
  order, de-duplicated, removable, "none" legal, `written(live:)` drops a dead id) + `OutflowChooser`
  (a row per chosen tag — "#path" / "(deleted tag)" + "remove" — and a "+ tag" menu of the wing's
  live tags not yet chosen). The rule editor writes `setReadingOutflow` (a dead stored id drops on
  ANY save of the sheet); the offer asks when the rule or the set changed and
  `membersMissingAnyOutflowTag` > 0, its act `tagAllMembers(nil)`, its receipt counting notes.
  **`setReadingAutoTag` RETIRED** (core) with a retirement pin.
- **R-13ic-4's faces** — `RuleTreeEditor` (the tree, extracted: one face for the editor and the mint);
  the GATE (`gatheringNeedsRule` → Save gated, "A gathering needs a rule.", "Delete this gathering…"
  → the confirm "It goes to the Trash — Put back returns it for 30 days." · "No note is touched: a
  gathering holds none." → `deleteReading` → the editor closes); the empty-state re-word (F-U1-3);
  **THE MINT** (F-U1-2): `RuleEditorModel(session:mintingIn:)` + `MintGatheringSheet` (name · the
  tree · Create disabled until a term exists · a taken name refuses and keeps), opened by the shelf's
  "Create Smart Book…"; `ReadingsViewModel.create(…, wingId:)`.
- **The spawn sheet** — `SpawnOffer` (the gathering, the suggested name, the wing's live tags, the
  PREFILL = `ShelfViewModel.spawnPrefill`: the rule's positive tags, tree order, live-filtered) +
  `SpawnBookSheet` (the truth per rule state · the chooser, editable before the mint);
  `spawnBook(from:named:outflow:)` writes her set (a chosen tag that died meanwhile drops at the act;
  nil = the prefill). `BindCopy.spawnMessage(.none)` re-worded to the R-13ic-4 truth. The shelf hides
  Bind / Make-a-Book on a RULE-LESS gathering (the plan §2's line).
- **The bind sheet's owned-notes limb** (the plan §3: "the sheet gains the limb in U3" — omitted from
  the brief's six pieces, built because this unit's Own door is what makes owned notes reachable in a
  gathering's assembly; without it the sheet's count promise would be false the moment one exists) —
  `BindOffer.ownedElsewhere` (from `bindOwnedNotesPreview`), "Title — owned by “Book”" listed, the
  choice leave them out (DEFAULT, P-13ic-4) · copy them in, each said whole, the count promise and
  the receipt (`BindCopy.bound(_:count:copied:leftOut:)`) following it; both hosts pass the choice.
- **The note's own Unseal inside a sealed book** (the adjudication): stays RENDERED and speaks
  `noteInSealedBook`'s words on every road — no code needed; pinned per road (P-13ic-U3-1).

### Evidence (the plan §7 U3 row, each named before the build)

- **Mounted pins / static copy:** `BookStateDoorsTests` (13 — the pair table cell for cell; the
  finish line + the N>0 gate; the seal confirm's lead, finishes-too, forks lead + list, waiting line,
  the owned fork-free line; unseal's "reopens"; own's copies / nothing-to-copy; every act through the
  one model incl. Finish asking with an arrival and dismissing it, Seal forking a shared member,
  Unseal reopening, Own + Stop Owning, the refusal naming its road on finished/sealed; the confirm
  sheet draws exactly its item) · `BookSettingsSheetTests` (6 — the rule read aloud; the sentences per
  kind and state incl. W-3's voicing; the mounted book sheet's sentences + state doors; a sealed
  book's Unseal and disabled Finished; the gathering pane; the hide-owned round trip hiding an owned
  note) · `OutflowChooserTests` (6 — the draft; the chooser's save round-trip incl. order and removal;
  the dead tag drawn and dropped; none legal and never untagging; the offer's N over the set and its
  act; a rule change re-asking) · `GatheringRuleGateTests` (7 — the re-word; the gate + the delete
  offer; a book's clear not gated; a restoree opening gated; the delete confirm landing in the Trash
  with no note touched; the mint's Create gate; the mint's rule + a taken name refusing and keeping) ·
  `SpawnAndBindLimbTests` (7 — the spawn's prefill; the mounted spawn sheet's chooser; her edited set
  minted; the limb's words and counts; the offer + mounted limb; leave-out and copy-in with their
  receipts) · `SealedBookMemberDoorTests` (5 — the shared words; Write's, the Takes board's and the
  shell's roads each speak them and the note stays sealed; the control).
- **The registry walk** (`CapabilityRegistryTests`) green with the two new surface renderers and the
  shelf's new context doors. **The tutorial spine**: all ten suites of `TutorialWalkTests.swift` green.
- **Honest test edits (subject untouched, each commented):** `ShelfModelTests.
  finishAndExtentFacesCallTheOps` (the face's road moved onto `stateDoors`); the two `RuleEditorTests`
  auto-tag pins drive `OutflowDraft` (their words unchanged); core — `setReadingAutoTag`'s 10 call
  sites → `setReadingOutflow` one-for-one (IntakeOperations ×8, ReadingFilter ×2, Phase13icOutflow ×1).
  Fixture fixes in MY new pins only (a member joining before the outflow; the Trash window read on the
  world's clock).
- **Suites:** core `swift test` FULL — "Test run with 2004 tests in 212 suites passed" (1 skipped:
  the standing env-gated Supabase integration test; baseline 2003/212 → +1, the retirement pin); Mac
  73 suites — "Test run with 445 tests in 73 suites passed … with 4 known issues" (twice: at 7d82a1e7
  and again after the walk fixes, zero instances); the phone `VariorumMobile` generic iOS Simulator
  BUILD SUCCEEDED. DerivedData `App/Variorum/DerivedData/13ic-u3`, `13ic-u3-ios` (+ logs) — the
  closeout's tidy sweeps them.
- **No bug-class row in this unit's brief** (a face unit) — red-on-old applied to nothing; the three
  walk defects (W-1/2/3) are presentation-layer (a modal sheet's event blocking, a truncating row,
  voicing) and are evidenced by the walk's before/after captures, W-3 additionally pinned both ways.

### PROVISIONALs made in U3 (each QUESTIONS-ready for #169)

- **P-13ic-U3-1 — A note's own Unseal inside a sealed book stays visible and explains itself.** The
  adjudication left "refuse or hide" to this unit. *QUESTIONS paragraph:* "A note that belongs to a
  sealed book still shows its Unseal button; pressing it says 'This note is in a book that is sealed
  — unseal the book to change it.' (a) As built — the button explains the road; (b) hide the note's
  Unseal entirely while its book is sealed."
- **P-13ic-U3-2 — A gathering keeps the shipped Finish/Reopen doors and the Word target / Note cap
  fields** in its settings and shelf menu (13i-b shipped them; the ops act on a gathering), though the
  sitting record §3 lists finish, word targets and capacity among what a gathering does NOT have.
  *QUESTIONS paragraph:* "Gatherings can still be marked Finished and given a word target or note cap,
  as before this phase. (a) Keep them — BUILT; (b) remove them from a gathering's settings and menu
  (the design record's letter); (c) also make the operations refuse them on a gathering."
- **P-13ic-U3-3 — "Own Its Notes…" stays on a finished or sealed book's menu and says how to get
  there** ("“X” is finished — reopen it first." / "…sealed — unseal it first (that reopens it
  too).") rather than hiding (the brief's "refused … with the op's words"). *QUESTIONS paragraph:*
  "(a) As built — the door explains; (b) hide Own Its Notes… until the book is open."
- **P-13ic-U3-4 — The settings sheet's "Edit…" closes the settings sheet and opens the rule editor
  over the book** (W-1: a nested editor's "Also tag the N members" offer appeared under the still-open
  settings sheet and could not be pressed). Back to settings is one more gear press. *QUESTIONS
  paragraph:* "(a) As built; (b) return to the settings sheet after the editor closes and show the
  'also tag' question inside it; (c) keep the editor inside the settings sheet and move the question
  into the editor itself."
- **P-13ic-U3-5 — A dead outflow tag drops on ANY save of the rule editor**, not only one that touched
  the chooser (its row read "(deleted tag)"; the setter refuses a dead id). *QUESTIONS paragraph:*
  "(a) As built; (b) drop it only when you edit the tag list itself."
- **P-13ic-U3-6 — Reopen and Stop Owning act without asking** (Reopen moves nothing she wrote — the
  gap's matches wait at Arrivals; Stop Owning moves no row — the brief's "plain, no confirm").
  *QUESTIONS paragraph:* "(a) As built; (b) Reopen asks too, naming what may arrive."
- **P-13ic-U3-7 — The confirm/receipt/Collecting wording** (e.g. "Sealing finishes the book too.",
  "These notes also live in other books, so each gets its own copy here, sealed with the book — the
  originals stay where they are, still editable:", "Notes an owned book holds: as the app does
  (shown) · show them · hide them", the mint's "Add a tag or ★ starred — a gathering is made from its
  rule…") — all 13s-revoicable; the TRUTHS are ruled. *QUESTIONS paragraph:* "The new sentences in
  book settings and the seal/own/finish confirms are first drafts — re-voice at 13s?"

### FINDINGS (for the orchestrator; none a STOP condition)

- **F-U3-1 (suggested owner: 13i-d, the Collecting-pane re-home):** P-13ic-U3-2's gap between the
  sitting record §3 (gatherings have no finish/targets/capacity) and the shipped ops + faces.
- **F-U3-2 (U4):** the shelf's "Delete Book" is now drawn from `.deleteBook` and still acts on ANY
  book without a confirm; U4's two-choice confirm extends this declaration and should route through
  `BookStateDoors.open(.deleteBook)` (today its confirm words are the gathering's — U4 adds the
  book's plain + owned arms).
- **F-U3-3 (pre-existing; suggested owner: a standing-fixes entry or 13i-d's Bookcase rebuild):** the
  shelf's `lastReport`/`lastError` overlay draws ON TOP of the ⌘K hint bar at the window bottom
  (walked: "made “u3 spawn walk” — 5 notes joined…" over "⌘k — find anything…", u3-24).
- **F-U3-4 (13i-d):** the plan §2's "a rule-less gathering's bind/spawn doors hide" is built on the
  shelf menu (the declared doors); the book navigator's "+ new chapter" on a rule-less gathering still
  opens the bind (it acts — binds nothing into an empty book).
- **F-U3-5 (13s / 13i-d copy):** the fork/copy lists name notes by `DisplayTitle`, so two untitled
  notes of one day read "2026-10-01 — also in …" twice (u3-12/13) — true, ambiguous; an excerpt would
  disambiguate.
- **F-U3-6 (13i-d / the 18i seam's owner):** a REFUSAL spoken from inside the settings sheet (e.g.
  Own on a finished book) lands as the shell's toast under the window-modal sheet — readable but
  dimmed. OFFERS were the blocking class (W-1, fixed); no other offer is raised from inside the sheet.
- **F-U3-7 (U4 / 13i-d — the badges):** the book navigator's chip reads "✓ finished" on a SEALED book
  (the shipped chip knows only `locked`); a sealed face there is the badge family's.
- **F-U3-8 (her call, recorded):** the offer toast's 6 s clock (18i) is tight for reading "Also tag
  the 2 current members with #a #b now?" and pressing — the walk met it twice under its own pacing.
- **F-U3-9 (recorded):** one Mac run (W-2/W-3's 18/2) had MY dev instance alive (a quit refused while
  its sheet was up); the close's 73-suite run re-ran everything on a zero-instance window.
- **F-U3-10 (walk residue — dev store only):** books "u3 spawn walk", "u3 mint walk"; the note
  "arrival walk"; fork copies of "spawn one"/"spawn two" (Own on `spawn walk (book)`); that book's
  outflow now [#again, #u3walk] and its dial "wait at Arrivals"; `dream journal`'s hide-owned toggled
  and restored to follow-the-default. Her voice + appearance preference restored.
- **F-U1-4 answered for the dev store:** v1_20 found NO rule-less gathering there (the Trash holds
  none); her REAL store stays unknown until the window.
- **Tutorial (P-6):** no lesson sentence went false; lessons 1, 5 and 6 now appear as the confirms'
  leads (`BookStateCopy.ownLead`, `.sealLead`, the settings captions). No tutorial prose rewritten.
- **MOBILE PARITY (for the closeout's row):** nothing mobile-visible changed (Mac faces only; the
  shared refusal table untouched); the phone has no Collecting sentences or state doors — the mobile
  catch-up's.

### THE WALK — captures under `notes/plans/13ic-screens/u3/` (gitignored)

u3-01 book settings (Collecting) · u3-02 the rule editor from settings (pre-W-1, nested) · u3-03 the
outflow menu · u3-04 two tags chosen · u3-05 the sentence updated + the offer BLOCKED under the sheet
(W-1's before) · u3-06 a removal · u3-07 the offer on an unblocked window (W-1's after) · u3-08 Tag
Them landed (#again #u3walk on the note) · u3-09 an arrival waiting · u3-10 Finish's one line ·
u3-11 finished, arrival dismissed · u3-12 Seal… lists the forks · u3-13 Own Its Notes… lists the
copies · u3-14 owned (Stop Owning) · u3-15 sealing an owned book: no copies needed · u3-16 sealed:
Unseal, Finished disabled, no Reopen · u3-17 Unseal says it reopens · u3-18 open again · u3-19 Stop
Owning acted · u3-20 the shelf menu's book state doors · u3-21 a gathering's menu (Finish only) ·
u3-22 the spawn sheet prefilled · u3-23 edited · u3-24 the book made with her set (+ F-U3-3) · u3-25
the gathering's hide-owned TRUNCATED (W-2's before) · u3-26 hide-owned set · u3-27 the gate's refusal
+ delete offer · u3-28 the delete confirm · u3-29 the mint gated · u3-30 enabled · u3-31 minted ·
u3-32/33 the Trash: no swept gathering · u3-34 a rule-less book's voiced sentences (W-3's after) ·
u3-35 the gathering sheet whole (W-2's after) · Terminal·dark u3-36…40 · Study·dark u3-41…45 ·
Study·light u3-46…50 (each: a book's settings, the seal confirm, a gathering's settings, the gate,
the mint).

### LIVE STATUS (per commit; every unverified claim PENDING)

- **Piece A — THE STATE DOORS:** DONE (commit "13i-c U3 pieces A+B"). Registry: `.finishBook`
  `.reopenBook` `.sealBook` `.unsealBook` `.ownBook` `.unownBook` (scope `.book`, doors `.contextMenu` +
  `.surface`, `always`, `.native`) and `.deleteBook` (`.contextMenu` for now — the rule editor's
  `.surface` door lands with Piece D). `Features/Readings/BookStateDoors.swift`: `BookStateDoorSet`
  (the pure pair table), `BookStateCopy` (every confirm + receipt + the refusal named for its book),
  `BookStateConfirm` (the sheet's item), `BookStateDoors` (preview → confirm-or-act → receipt /
  refusal), `BookStateConfirmSheet` + `.bookStateConfirms(_:)` (ONE presentation road). The shelf menu
  renders the pairs from the table; `ShelfViewModel.setFinished` and `BookStructureModel.setFinished`
  RETIRED onto the shared road (one honest pin edit: `ShelfModelTests.finishAndExtentFacesCallTheOps`
  drives `stateDoors.open(.finishBook…)`). The shelf hides Bind/Make-a-Book on a RULE-LESS gathering
  (the plan §2's P-2 line). `BookStateDoorsTests` (13) green.
- **Piece B — THE SETTINGS SHEET:** DONE (same commit). `Features/BookView/BookSettingsSheet.swift`
  (moved out of `BookView.swift`): `CollectingCopy` (the rule read aloud as a sentence; the three
  Collecting lines; the hide-owned three words), `BookSettingsModel` (paths + the global default,
  one-shot, keyed on rule/outflow/toggle; the Edit… door; `setHideOwned`), the sheet (Name · Word
  target · Note cap as shipped · Collecting · State — the Finished control disabled with the sealed
  words while sealed). `.editRule` gains `.surface`; the registry walk's surface union names
  `BookSettingsSheet`. `BookSettingsSheetTests` (6) green. Touched suites: BookStateDoors ·
  BookSettingsSheet · CapabilityRegistry (the walk) · ShelfModelTests — **49 tests / 4 suites passed**;
  zero instances before and after.
- **Piece C — THE OUTFLOW CHOOSER:** DONE (commit "13i-c U3 piece C"). `Features/Readings/
  OutflowChooser.swift`: `OutflowDraft` (pure — her append order, de-duplicated, each removable, "none"
  legal, `written(live:)` drops a dead id) + `OutflowChooser` (a row per chosen tag in the term-row
  grammar — "#path" or "(deleted tag)", a quiet "remove" — and one "+ tag" menu of the wing's live
  tags not yet chosen). `RuleEditorModel.autoTagID` → `outflow: OutflowDraft`; writes
  `setReadingOutflow(id, tagIDs:)` (a dead stored id drops on ANY save of the sheet); the offer asks
  when the rule or the set changed, N = `membersMissingAnyOutflowTag` (read after the write), its act
  `tagAllMembers(nil)`, the receipt counting notes; words `tagMembersOffer(count:paths:)` /
  `taggedMembers(count:paths:)` (one tag reads exactly as before). **Core:** the
  `setReadingAutoTag` FORWARDER RETIRED (F-U1-1) — its 10 core-test call sites moved one-for-one onto
  `setReadingOutflow` (subjects untouched, each commented); `OutflowRetirementTests.
  theSingleTagForwarderIsRetired` pins no production caller or definition survives. The two
  `RuleEditorTests` auto-tag pins drive the draft (their words unchanged). Core filtered run
  (IntakeOperations · Phase13icOutflow · ReadingFilter · OutflowRetirement) **66 / 4 green**; Mac
  `OutflowChooserTests` (6) + RuleEditor + BindDoor + BookSettingsSheet green (one fixture-order fix
  in my own new pin: a hand-add rides the outflow, so the member joins before it exists).
- **Piece D — R-13ic-4's FACES:** DONE (commit "13i-c U3 piece D"). The rule editor's tree
  extracted as `RuleTreeEditor` (one face for one grammar — the editor sheet and the mint sheet).
  THE GATE: `RuleEditorModel.gatheringNeedsRule` (a gathering, editable rule, no term) → Save gated
  (`canSave`) with "A gathering needs a rule." and the "Delete this gathering…" door (`.deleteBook`'s
  `.surface` door — the registry gains it, the walk names `RuleEditorSheet`) → `BookStateDoors`'
  confirm ("It goes to the Trash — Put back returns it for 30 days." · "No note is touched: a
  gathering holds none.") → `deleteReading` → the editor closes (`.bookStateConfirms(_:onLanded:)`).
  A BOOK's clear stays legal (the kill switch). The empty-state re-word (F-U1-3): "No rule — this
  gathering shows nothing until it has one." THE MINT (F-U1-2): `RuleEditorModel(session:mintingIn:)`
  (the mint mode — the wing's live tags, the name held on the model, `mint(through:)` via
  `ReadingsViewModel.create(querySpec:wingId:)`), `MintGatheringSheet` (name · the tree · Create
  disabled until a term exists · a refusal refuses-and-keeps); the shelf's "Create Smart Book…"
  opens it (its "smart" wording LEFT for 13i-d's vocabulary sweep — the brief's allowance).
  `GatheringRuleGateTests` (7) green; with RuleEditor · the registry walk · OutflowChooser ·
  BookStateDoors · BookSettingsSheet — **68 tests / 6 suites passed** (one clock fix in my own new
  pin: the Trash window reads the world's `now`, not the wall's).
- **Piece E — THE SPAWN SHEET + THE BIND'S OWNED-NOTES LIMB:** DONE (commit "13i-c U3 piece E").
  The spawn's 13i-b name-only `.alert` → `SpawnBookSheet` over a `SpawnOffer` item (the gathering, the
  suggested name, the wing's live tags, the PREFILL — `ShelfViewModel.spawnPrefill`: the rule's positive
  tags, tree order, live-filtered; ONE function for the sheet and the no-answer default) with the
  `OutflowChooser`, editable before the mint; `spawnBook(from:named:outflow:)` writes her chosen set (a
  chosen tag that died meanwhile drops at the act; nil = the prefill). `BindCopy.spawnMessage(.none)`
  re-worded ("…it shows nothing" — the R-13ic-4 truth; the door itself hides there). THE LIMB:
  `BindOffer.ownedElsewhere` (from `Queries.bindOwnedNotesPreview`, mapped to `BindCopy.OwnedNote`),
  the sheet lists "Title — owned by “Book”" with the two-way choice (leave them out — DEFAULT,
  P-13ic-4 · copy them in), each said whole, the count promise following the choice
  (`BindCopy.memberCount`); `onConfirm` carries the choice to `ShelfViewModel.bind(_:ownedNotes:)` /
  `BookStructureModel.bind(order:ownedNotes:)`; the receipt names the limb's outcome
  (`BindCopy.bound(_:count:copied:leftOut:)` — the plain bind's words unchanged). `SpawnAndBindLimbTests`
  (7) green; with BindDoor · BookOrderConversion · DuplicateBookNameDoor · BookAscentDeclaration —
  **38 tests / 5 suites passed**.
- **Piece F — the note's own Unseal inside a sealed book + the close:** the DOOR half DONE (commit
  "13i-c U3 piece F (1/2)"). THE CALL (the adjudication left it to this unit): the door stays RENDERED
  and SPEAKS the operation's refusal — "This note is in a book that is sealed — unseal the book to
  change it." (the shared table, the Mac's `bookSeal` road) — because the refusal names the road out
  and a hidden Unseal on a visibly sealed note would leave her no word on why; hiding would also need a
  per-target fact ("a live sealed book holds this note") pushed into `CapabilityContext` for every
  surface, a gate no other note door carries. No code change was needed: all three roads already route
  the op's refusal through the one table. `SealedBookMemberDoorTests` (5) pins Write's bar door, the
  Takes board's door and the shell's fallback (each speaks the words; the note stays sealed) + the
  control (an independently sealed note outside a sealed book unseals by its own door) — green.
  **Suites (the close's evidence, run on the committed tree 7d82a1e7):** core `swift test` FULL —
  **"Test run with 2004 tests in 212 suites passed"** (1 skipped: the standing env-gated Supabase
  integration test; baseline 2003/212 after the adjudication → +1, `theSingleTagForwarderIsRetired`);
  Mac `build-for-testing` GREEN + 73 suites (every new and touched suite, every suite naming the book
  view / shelf / readings / rule editor / seal doors, the registry walk, the refusal-table integrity +
  convergence suites, and all ten tutorial-walk suites of `TutorialWalkTests.swift`) — **"Test run
  with 445 tests in 73 suites passed … with 4 known issues"** (the 4 = the pre-existing
  `withKnownIssue` TK2 marks in `IndexTierMetricsTests`; zero skips); the phone `VariorumMobile`
  generic iOS Simulator **BUILD SUCCEEDED**. Zero app instances before and after every run.
  The walk and the close: DONE (below).
- **THE WALK — DONE (guard OK at every act, AX + Screen grants true, dev-store Debug build
  `DerivedData/13ic-u3`, `io.lduarte.Variorum.debug`; her app absent throughout).** **W-1 FOUND AND FIXED (commit "13i-c U3 walk fix W-1"):** the Book
  Settings sheet NESTED the rule editor; after a save the editor's "Also tag the 2 current members with
  #u3walk #walked now? · Tag Them" OFFER rendered as the shell's toast UNDER the still-open,
  window-modal settings sheet — her press could not land (walked: the note still wore only
  `#spawn13ib`; captures u3-05). Fix: Edit… HANDS the editor to the book view and closes the settings
  sheet (`BookSettingsModel.makeRuleEditor` + `onEditRule`; the book view presents it on the settings
  sheet's dismissal), so the offer lands on an unblocked window. Not pinnable headlessly (a modal
  sheet's event-blocking is AppKit's, not the test host's) — the walk's before/after captures are its
  evidence; the model pin reads `makeRuleEditor()`. Settings · state doors · the registry walk 46/3
  green after it.
  **W-2 + W-3 FOUND AND FIXED (commit "13i-c U3 walk fixes W-2 W-3"):** W-2 — the gathering's
  hide-owned chips TRUNCATED on one line at the sheet's width ("as the a…" · "show th…"; capture
  u3-25) → the label on its own line, the chips under it, each `fixedSize`. W-3 — app-word values
  ("wait at Arrivals", "nothing", "nothing by itself") stood unvoiced beside Terminal's lowercased
  labels → `CollectingLine.appWords` voices them; her paths stay un-voiced (pinned both ways).
  BookSettingsSheet + BookStateDoors 18/2 green (that run had MY dev instance alive — a quit refused
  while its sheet was up; recorded; the suites re-run at the close on a zero-instance window).
  **Walked so far (Terminal · light), each a capture:** the book sheet's Collecting sentences
  (u3-01) → Edit… opens the editor (u3-02, before W-1; after W-1 over the book) → the chooser's menu
  (u3-03) → two tags chosen in her order (u3-04) → the sentence updates + the offer (u3-05, blocked —
  W-1) → removal (u3-06) → the offer on an unblocked window (u3-07) → Tag Them LANDED (u3-08: the
  note wears #again #u3walk) → an arrival waiting (u3-09) → Finish asks with §24's one line (u3-10)
  → finished, the arrival dismissed (u3-11) → Reopen acted at once → Seal… lists the forks (u3-12,
  cancelled) → Own Its Notes… lists the copies (u3-13) → owned (u3-14) → Seal on the owned book:
  "It owns its notes, so nothing needs copying." (u3-15) → sealed: Finished disabled with the sealed
  words, Unseal, no Reopen (u3-16) → Unseal says it reopens (u3-17) → open again (u3-18) → Stop Owning
  acted (u3-19) → the shelf menu's state doors on a book (u3-20) and Finish only on a gathering
  (u3-21) → the spawn sheet prefilled (u3-22) → edited (u3-23) → the book made with her set (u3-24) →
  the gathering's settings + hide-owned (u3-25 truncated, u3-26 set) → the gate's refusal + the
  delete offer (u3-27) → the delete confirm (u3-28, cancelled) → Create Smart Book… → the mint sheet
  gated (u3-29) → enabled (u3-30) → minted (u3-31). **U1's held walk folded in:** the Trash holds NO
  swept gathering (u3-32/33 — the dev store had none rule-less, F-U1-4 answered for it); the carried
  outflow reads "notes written here are tagged: #spawn13ib" on `refresh walk (book)`, a 13i-b single
  auto-tag carried by v1_20. **The fixed faces and the voice × appearance matrix (after W-2/W-3):**
  the rule-less book's voiced sentences (u3-34) and the gathering sheet whole (u3-35) in Terminal ·
  light; Terminal · dark (u3-36 a gathering's sheet, u3-37 a book's, u3-38 the seal confirm, u3-39 the
  gate, u3-40 the mint); Study · dark (u3-41…45, the same five); Study · light (u3-46…50, the same
  five). Her dev store's voice (Terminal) and appearance preference (`system`) RESTORED and read back.
- **THE CLOSE (the closing commit):** after W-1/W-2/W-3 the Mac `build-for-testing` re-ran GREEN and
  the same 73 suites re-ran on a ZERO-instance window — **"Test run with 445 tests in 73 suites passed
  … with 4 known issues"** (the 4 pre-existing `IndexTierMetricsTests` marks; zero skips). Core and the
  phone stand on their 7d82a1e7 runs: no line under `Sources/`, `Tests/`, `App/Variorum/Shared/` or
  `App/Variorum/VariorumMobile/` changed after them (`git diff --stat 7d82a1e7..HEAD` over those
  paths — empty). The record written whole; ledger row 4 flipped.
- **Machinery honesty:** this record's first commit (163b9545) landed INSIDE the U2 BRIEF's sentence
  — the insertion matched the brief's backticked "`## §8 ENVIRONMENT TRAPS`" mention, the same class
  that swallowed U2's heading. Moved here at the close; the plan was verified byte-identical to its
  pre-U3 tip (26414772) before this record went in. No revert was ever in flight; zero app instances
  at open and at close.


## THE ARCHITECT'S ADJUDICATION AFTER U3 (2026-10-01)

- **U3 VERIFIED:** ten commits (163b9545…831e4a2a), no trailers, the record whole, fifty captures
  on disk, its six new Mac suites + BindDoor + RuleEditor + the tutorial spine re-run by the
  orchestrator — 62/8 green on a zero-instance window.
- **P-13ic-U3-2 RULED — the record's letter stands; the faces go at 13i-d.** The sitting record §3
  is binding: a gathering has NO finish, word target or note cap. The shipped Finish/Reopen and
  Length & Extent faces on a GATHERING are a 13i-b carry-over the Bookcase rebuild (13i-d) removes
  with the shelf menu it rebuilds; the ops may refuse them on a gathering there too (the (c) arm —
  13i-d's call, a KnownIssues row with that owner at this closeout). Not a U4 rider (a different
  surface; U4 is the membership doors).
- **P-13ic-U3-1, -3, -4, -5, -6, -7 stand as built** (each spec-defensible; -4 is the walk's own
  finding fixed the honest way; filed at #169).
- **F-U3-2 and F-U3-7 → U4** (the delete confirm through `BookStateDoors.open(.deleteBook)` with
  the plain + owned arms; the navigator chip's sealed face joins the badge family). **F-U3-1 → 13i-d
  (KnownIssues). F-U3-3 → a standing-fixes entry or 13i-d (KnownIssues). F-U3-4 → 13i-d. F-U3-5 →
  13s/13i-d copy. F-U3-6 → the 18i seam's owner (recorded). F-U3-8 → her bundle (the offer clock).**
- **The bind sheet's owned-notes limb** (built by U3 though the brief's six pieces omitted it — the
  plan §3 assigned it): ACCEPTED; its pins stand; the ladder reviews it cold with the rest.

## U4 BRIEF — THE MEMBERSHIP DOORS' FACES · THE BADGES · DELETE/DUPLICATE · REMOVE/RELEASE · THE TRASH (`opus-implementer`; read this whole file first)

**Read, in your own context, before any code:** CLAUDE.md + its canon; this plan WHOLE — §1 her
rulings · §3 (Owned — the ops you put faces on) · §4 THE DOOR ENUMERATION (rows 14–21 are YOURS;
rows 1–12 are U2's pins you render) · §6 (delete · duplicate · the Trash) · §7 the U4 row · §8
traps · §9 · the U1/U2/U3 RECORDs (the op names and signatures as built; U2's F-U2-6/7/8 and
U3's F-U3-2/7 are YOURS) · both adjudications; the sitting record
`notes/plans/phase-13i-sitting-record-2026-09-30.md` §2 (the edit law — the words at the doors),
§6 (the add doors · the two-choice delete · duplicate · the badge family), §18.3 (the Trash
lifecycle), §18.4 (competing owned books — "claimed by [Book]"), §20 (the remove/release doors'
vocabulary), §21–§24 (the design-language anchor: the app's own idioms and tokens; chrome
`fixedSize` texts carry a `lineLimit`; no literal colour outside the token layer);
`notes/SessionResiliencyProtocol.md`. Code to orient on: `Features/BookView/MembershipChip.swift`
(the chip: add/remove/collect/diverge + `ChipRefusals`), `Features/BookView/BookStructureModel.swift`
(the two drag roads + the daily shelving), `Features/Pool/PoolPostsView.swift` (the drop),
`Features/Shelf/ShelfView.swift` (the drop; `bookMenu`; Delete Book), `Features/Readings/ReadingViews.swift`
(`ManageReadingPostsSheet`), `Features/BookView/BookArrivals.swift` (the Arrivals line + its
model), `Features/Readings/BookStateDoors.swift` (U3's one confirm road — `BookStateDoors.open`,
`BookStateCopy`, `.deleteBook`), `Features/BookView/BookNoteBox.swift` + `BookOutlineRows.swift` /
`BookIndexView.swift` (the note rows' context menus), `Features/Tray/` + `Shared/RecoveryActs.swift`
+ `Shared/RecoveryCopy.swift` (the Trash's rows and receipts), `Features/Settings/` (the panes —
the `arrival_flash` row's pattern), `Registry/CapabilityRegistry.swift` (P-1; the walk),
`Registry/OpsRefusalCopy.swift` + `Shared/OpsRefusalTable.swift` (the words),
`Queries/OwnershipQueries.swift` (`noteMemberships`, `moveInPreview`, `ownershipFacts(postIDs:inBook:)`,
`trashBookNoteCount`, `sharedMembers`), the 18i status seam.

**Scope (ONE unit — every face that CREATES or REMOVES membership, the badges, delete/duplicate,
the Trash; no settings-sheet work — U3 shipped it):**
1. **ONE choice sheet** (`MembershipChoiceSheet`, static copy on a pure type — the `BookStateCopy`
   precedent): on `noteMemberedElsewhere` from an OWNED target — "“Book” owns its notes. This note
   also lives in “X”, “Y”." · **Copy it in** (a linked copy; the originals stay — `copyPostIntoReading`)
   · **Move it in** (it leaves X and Y — `movePostIntoReading`; the severed list from `moveInPreview`;
   a finished book among them → the op's refusal, Copy in offered); on `noteOwnedElsewhere` from a
   PLAIN target — "This note belongs to “X”, which owns its notes." · **Copy it into “B”** only. The
   edit-law words at the door (§2): adding never copies; a copy is a ceremony she chose. HOSTED by
   every road in §4 rows 14–18: the chip's Add, the Index/Outline drag roads (`BookStructureModel`
   ×2), the Pool's drop, the shelf row's drop, Manage Notes…. Each host: the refusal → the sheet →
   the act → the receipt (the status seam). The names come from `noteMemberships`/`ownershipFacts`
   (F-U2-6 — the refusals carry ids).
2. **The Arrivals line's arms (§4 row 19, §18.4):** per arrival row, the facts decide the doors —
   a membered-elsewhere note at an OWNED book's door: **Copy in · Move in · Dismiss** (no Add); an
   owned-elsewhere note at a PLAIN book's door: **Copy in · Dismiss** — and the row carries the line
   **"owned by “Book”"** / "also in “X”" (the competing-owned-books face: "claimed by [Book]" in the
   record's words — use "owned by"); the arrival-answering ops (`copyPostIntoReading(answering:)`,
   `movePostIntoReading(answering:)`) are the acts; Add stays where the plain seat is legal.
3. **Delete (§6; F-U3-2):** the shelf's Delete Book routes through `BookStateDoors.open(.deleteBook)`
   with THREE arms in `BookStateCopy`: a PLAIN book's confirm ("Deleting a plain book never touches a
   note" — names the Trash and its 30 days); an OWNED book's TWO-CHOICE confirm — **Delete book only**
   (its N notes go to the Pool — `deleteReading`) · **Delete book and its N notes** (both to the Trash
   on one stamp — `deleteReadingWithNotes`; offered ONLY on an owned book, F-U2-7); the gathering's
   arm as U3 built it. The same door on the book view's gear/settings if one exists there.
4. **Duplicate Book… (§6):** on the shelf row's menu (+ the settings sheet's State section if it
   fits): a name prompt (E13's guard) with a "with copies of its notes" checkbox — shallow by
   default on a plain book; an OWNED book offers "Duplicate with Copies…" only (`duplicateReading
   (_:name:deep:)`); receipts name the result ("“X copy” — N notes, the same notes" / "… N copies").
5. **The remove/release vocabulary (§20):** the chip's remove row, the Index/Outline note-row context
   menu and the note box's book context carry **"Remove from this book"** — on an OWNED book
   **"Release from this book"** — with receipts ("Removed from “X” — the note itself is untouched." /
   "Released from “X” — it's in the Pool now." — `removePostFromReading` returns bookless); on a
   GATHERING the chip offers the honest **"Remove the #tag"** (the rule's positive tags the note
   wears; one row per tag, `removeTag`) and never a remove.
6. **The badge family (§6; toggleable as a set — the `ownership_badges` setting):** in BOOK views
   (Index/Outline/Book rows, the navigator chip) the shared-membership badge (a small glyph when the
   note has OTHER book memberships; hover names them) + the navigator chip's **sealed** face
   (F-U3-7: "✓ finished" must read sealed on a sealed book); in gatherings, the Pool, tag listings
   and the Library cards the **owned-by** badge ("owned by “X”"; click-through opens the book at the
   note — the panel bridge, `MembershipChip.ascend`). Silence the common case: an ordinary free note
   shows nothing. `ownershipFacts(postIDs:inBook:)` is ONE page-driven read per listing (P1).
   Direction ruled: the badge marks shared membership IN the book view; owned-by marks it OUTSIDE.
7. **Settings rows:** `ownership_badges` (on/off, default on) and `hide_owned_default` (show, badged
   / hide — default show) in the pane where `arrival_flash` lives, each worded in one sentence.
8. **The Trash (§18.3):** a book deleted WITH its notes shows "and N notes" on its row
   (`trashBookNoteCount`); Put back's receipt says it came back whole ("“X” is back with its N
   notes"); kind labels stay.
9. **The registry (P-1):** every new act declared once (`.copyIn`, `.moveIn`, `.duplicateBook`,
   `.removeFromBook`/`.releaseFromBook` as ONE act whose verb is a per-target function, `.removeTag…`
   as the chip's honest door, the badge as a surface renderer), doors as data, refusal copy, the
   walk green. The phone: nothing (its membership face already speaks the shared words — F-U2-8);
   say so in the record's MOBILE PARITY line.

**Evidence (the §7 U4 row):** mounted pins per host (each face OFFERS the choice on its refusal —
§4 rows 14–18 one test each, named for the row; the Arrivals arms per fact; the three delete arms;
duplicate's two shapes; the remove/release words per surface; the badge facts drawn + the setting
silencing them; the Trash row + receipt), the registry walk, `TutorialWalkTests` green, the FULL
core suite green at the END (core touched only for copy types/queries the faces need), Mac
`build-for-testing` + every touched suite, the phone BUILD; and **YOUR OWN dev-store walk** (the
author guard FIRST — `Tools/WalkKit/guard.sh --author`; STOP and record "walk HELD" if someone is
at the machine): **R4 by hand** — own a book → from another book, add one of its notes → the choice
→ Copy in → the badge on the copy's row and the owned-by badge in the Pool → Move in a different
note → the severed list → Release a note → the Pool; an arrival at an owned book's door with Copy
in / Move in / Dismiss; delete an owned book both ways → the Trash's "and N notes" → Put back whole;
Duplicate both shapes; the badges off in Settings. Both voices × both appearances, captures into
`notes/plans/13ic-screens/u4/` (gitignored).

**Your record:** a `## U4 RECORD` section directly above `## §8 ENVIRONMENT TRAPS`, in the U3
RECORD's shape (NOT-DONE first · the design map · PROVISIONALs P-13ic-U4-n with QUESTIONS-ready
paragraphs · FINDINGS with suggested owners · THE WALK with its capture list · LIVE STATUS per
commit, unverified claims PENDING) — put the heading on its OWN line, never inside a sentence that
quotes `## §8` (the U2/U3 swallow). Flip ledger row 5 at the close. Commit per piece; `git pull
--rebase` then push after every commit; no trailers; foreground waits only; no subagents (one
read-only Sonnet lookup at most); the §8 traps verbatim.

## U4 RECORD — THE MEMBERSHIP DOORS' FACES · THE BADGES · DELETE/DUPLICATE · REMOVE/RELEASE · THE TRASH (`opus-implementer`, 2026-10-01)

**NOT DONE BY THIS UNIT (first line, per the contract):** no Delete or Duplicate door added to the book
view's gear/settings sheet (none exists there today; the spawn message's fence — "no settings-sheet work"
— outranks the brief's "if it fits"; F-U4-3 → 13i-d); no owned-by badge in the POOL (it lists bookless
notes, so no Pool row can be owned — structurally silent, P-13ic-U4-9); §4 row 15 NOT hosted by the choice
sheet as the brief's text says — its named "drag roads" create no membership and its one add road (the
daily book's "+ new entry") BELLS like ⌘J (P-13ic-U4-1, F-U4-1); no "Book Panel" remove door (the Book Panel
is 13i-d's — F-U4-5); no phone face (MOBILE PARITY below); the shelf-row DROP pinned mounted but not
dragged by hand in the walk (F-U4-7); NO `notes/QUESTIONS.md` entries written (each PROVISIONAL carries
its #169 paragraph); zero `Sync/`, zero schema, zero `Server/`. Core touched ONLY for face needs:
`Queries.liveMemberNoteCount` (the delete confirm's N) and a public memberwise init on the value type
`Queries.OwnershipFacts` (so the badge rule is pinned cell for cell) — no op semantics.

**UNIT STATUS: CLOSED 2026-10-01 — core FULL 2004 tests / 212 suites (1 standing env-gated skip) · Mac
575 tests / 82 suites (4 pre-existing known issues) incl. the registry walk and all eleven tutorial-walk
suites · the phone BUILD green + the four phone suites on the shared Trash road 72/5 (2 deliberate known
issues) · THE WALK DONE (three defects found and fixed — W-1, W-2, W-3) — 53 captures, both voices × both
appearances.**

Preflight read in this session's own context: CLAUDE.md + its canon, this plan WHOLE (§1–§11, the
U1/U2/U3 RECORDs, both adjudications, the U4 BRIEF), the sitting record §1–§6, §18–§25,
`notes/SessionResiliencyProtocol.md`, `Tools/WalkKit/README.md`. No editor seam, no `Sync/`, no schema
(TEXTKIT2_NOTES / SyncSpec not required).

### What U4 built (the design as shipped — a fresh session's map)

- **THE MEMBERSHIP CHOICE** (`Core/Views/MembershipChoice.swift` — the shared home: four features host
  it): `MembershipChoiceCopy` (static words — the brief's two leads verbatim, "“Book” owns its notes. This
  note also lives in “X” and “Y”." / "This note belongs to “X”, which owns its notes."; the edit law said
  AT the door — "Adding a note to a book never copies it — a copy only happens because you choose one, and
  it always remembers where it came from."; Move's severed list, members it LEAVES and doors it stops
  WAITING at; the finished-book block; the receipts), `MembershipChoice` (the sheet's whole item, read
  from `noteMemberships` + `moveInPreview` — the ops' own predicates), `MembershipDoors` (`add` → nil or
  the named choice; `addOrOffer`; `offer`; `copyIn` / `moveIn` through `copyPostIntoReading` /
  `movePostIntoReading`, receipts on the 18i seam; a finished book among the severed refuses with THAT
  book's road), `MembershipChoiceSheet` (Copy In · Move In — disabled with the reason when a finished book
  holds it — or the single "Copy Into “B”") + `.membershipChoices(_:onLanded:)` (ONE presentation road).
  HOSTS (P-2 — the refusal OPENS the ceremony): the chip's Add (row 14 — closes its popover; the sheet
  hangs off the chip), the Pool's add-to-book (row 16), the shelf row's drop (row 17), Manage Notes…'s
  Add (row 18, through `ReadingsViewModel.addPost`; the copy joins the sheet's list on landing).
- **ROW 15, as the code is** (F-U4-1): `BookStructureModel`'s two DRAG roads (navigator + Outline rows)
  only file and reorder MEMBERS — a foreign payload decodes to nothing (pinned); its one ADD road is the
  daily book's "+ new entry", whose ownership refusal now BELLS exactly as ⌘J does (sitting §6 — "an
  owned-elsewhere note bells, never throws"): the entry opens, the note names who holds it, and the
  Arrivals line offers the choice (row 19). `JournalBooks.shelvingNote` is ONE mapping for ⌘J and that
  door; `JournalWaitingCopy` names the owner (F-U2-6 — "…waiting at “Journal”'s door, because “X” owns
  it."). The non-daily mint is sole by construction.
- **THE ARRIVALS ARMS** (row 19, §18.4): `ArrivalArms` — each waiting row's doors as DATA from the one
  `OwnershipDecision` verdict (a row never offers an Add the seat refuses): Add · Dismiss (ordinary);
  **Copy In · Move In · Dismiss** (membered note at an OWNED door); **Copy In · Dismiss** (owned-elsewhere
  note at a PLAIN door); the row's line "owned by “X”" (competing owned books) / "also in “X”…" (its
  hover gives the whole list). `BookArrivalsModel` reads the LISTED rows' facts in one page-driven
  statement and answers through `copyPostIntoReading(answering:)` / `movePostIntoReading(answering:)`.
- **REMOVE / RELEASE** (§20 — `Core/Views/RemoveFromBook.swift`): ONE act, its word the book's —
  "Remove from This Book" / "Release from This Book" (owned); receipts from `removePostFromReading`'s
  bookless answer ("Removed from “X” — the note itself is untouched." [+ " It's in the Pool now." when
  bookless] / "Released from “X” — it's in the Pool now."); refusals named for the book's road
  (`BookStateCopy.refusal` — finished → reopen, sealed → unseal). Renderers: the chip's rows
  ("remove"/"release"), the navigator + Outline note-row context menus, the Index row's ⋯ menu, the
  sidebar note box's book context (a context menu; `NoteBoxDoor.removeFromBook`, nil on a gathering),
  Manage Notes…'s row (outcome said IN the sheet). A GATHERING row on the chip offers the honest
  "remove #tag" per worn POSITIVE rule tag (subtree) — never a remove; its receipt says whether the
  gathering still shows the note.
- **DELETE — three arms** (F-U3-2; F-U2-7): the shelf's "Delete Book…" routes through
  `BookStateDoors.open(.deleteBook)`; the arm follows the book: a gathering's (U3's words); a PLAIN book's
  confirm (lesson 8's first sentence + the Trash's 30 days; book-only, never offers note deletion); an
  OWNED book's TWO-CHOICE confirm — "Delete Book Only" (its N notes to the Pool — `deleteReading`) ·
  "Delete Book and Its N Notes" (`deleteReadingWithNotes`, one stamp) — via `BookStateConfirm
  .alternateLabel` + `confirm(alternate:)` + the sheet's second button. N = `Queries.liveMemberNoteCount`
  (exactly the set the act takes).
- **DUPLICATE BOOK…** (`Features/Readings/DuplicateBook.swift`): the shelf menu, books only;
  "Duplicate Book…" / "Duplicate with Copies…" (owned); the sheet — name prefilled "X copy" (E13's guard
  in the SAME runner closure as `duplicateReading`; a taken name refuses IN the sheet), "With copies of
  its notes" (off on a plain book; on and fixed on an owned one — never a shallow offer the op refuses);
  receipts "“X copy” — N notes, the same notes." / "“X copy” — N copies.".
- **THE BADGE FAMILY** (§6 — `Core/Views/OwnershipBadge.swift`): `OwnershipBadgeFace` (the rule —
  INSIDE a book the shared mark naming the other books; OUTSIDE — a gathering's view, the Library's rows
  and cards, the tag listing — "owned by “X”", a click opening that book at the note; a free note, or a
  note only here, wears nothing; `ownership_badges` off silences the set), `OwnershipFactsModel` (ONE
  page-driven observation per listing, membership tables only), `OwnershipBadgeView` (`.openBookAtNote`'s
  third renderer), `OwnershipBadgeCopy.rowHelp` (W-2). The navigator chip says "✓ sealed" on a sealed
  book (`BookStateCopy.navigatorChip`, F-U3-7).
- **SETTINGS**: the Editor pane (where `arrival_flash` lives) gains a "Books" section — "Show ownership
  badges" (`ownership_badges`) and "Hide notes an owned book holds, in gatherings and tag listings"
  (`hide_owned_default`), each with one sentence that does not overclaim; two `SettingsCatalog` rows;
  `ThemeStore.setOwnershipBadges` / `setHideOwnedDefault`.
- **THE TRASH** (§18.3): shared words (`RecoveryCopy.bookRowNotes` — "and N notes"; `bookPutBackWhole` —
  "“X” is back with its N notes.") and the shared act (`TrashPutBack` reads `trashBookNoteCount` BEFORE
  `restoreReading` clears the stamp — `Outcome.bookWhole(notes:)`); the Mac Trash row draws the count
  beside its kind label (`RecoveryViewModel.bookNoteCounts`, ∝ the book rows listed).
- **THE REGISTRY (P-1)**: `.copyIn`, `.moveIn` (`.surface` — the sheet + the Arrivals line),
  `.removeFromBook` (`.contextMenu` + `.surface`), `.removeRuleTag` (`.surface` — the chip),
  `.duplicateBook` (`.contextMenu` — the shelf); renderers declared on `MembershipChoiceSheet`,
  `BookArrivalsLine`, `BookView` + `SidebarNoteBox` (context menus), `MembershipChip`, `BookIndexColumn`,
  `ManageReadingPostsSheet`, `OwnershipBadgeView`, `ShelfView`; the walk names every one.

### §4 rows 14–21 — dispositions

| # | road | as built | pin / walk |
|---|---|---|---|
| 14 | the chip's Add | the sheet (copy·move or copy-only) | `row14_theChipsAddOffersTheChoice` · u4-03, u4-12, u4-42, u4-46, u4-52 |
| 15 | `BookStructureModel` | drag roads add nothing; the daily "+ new entry" BELLS (P-13ic-U4-1) | `row15_…AddNothingByDragAndBellAtTheDailyDoor` |
| 16 | the Pool's add | the sheet (a race-only meeting — Pool notes are bookless) | `row16_thePoolsAddOffersTheChoice` · u4-17 (the clean move-in) |
| 17 | the shelf row's drop | the sheet | `row17_theShelfRowsDropOffersTheChoice` (mounted; not hand-dragged — F-U4-7) |
| 18 | Manage Notes… | the sheet; the copy joins the list | `row18_manageNotesAddOffersTheChoice` · u4-38, u4-39 |
| 19 | the Arrivals line | Copy In · Move In · Dismiss / Copy In · Dismiss + the "owned by"/"also in" line | `ArrivalArmsTests` (5, one mounted) · u4-20, u4-21, u4-43, u4-47, u4-50, u4-51 |
| 20 | ⌘K | no add-to-book road exists (it opens notes and books) — nothing to consult; recorded | — |
| 21 | the Book Panel's drag powers | the Book Panel is 13i-d's; the note box carries no drag; the book view's drags are within-book only (row 15's pin) — recorded | — |

### Evidence

- **Mounted pins / static copy:** `MembershipChoiceTests` (15 — the words; the copy button's voicing,
  W-1; the model's plain add, both choices, Copy In, Move In, the finished block; the sheet draws its item;
  rows 14–18 one test each through the REAL hosts; ⌘J names the owner) · `RemoveReleaseDoorTests` (5) ·
  `ArrivalArmsTests` (5) · `BookDeleteAndDuplicateTests` (9) · `OwnershipBadgeTests` (7 — the rule cell for
  cell, the facts page-driven, the MOUNTED Index row's shared mark and a gathering view's owned-by mark,
  W-2's row help, the chip's sealed face, the Settings rows) · `TrashBookNotesTests` (3); core:
  `OwnershipBookDoorsTests` gains the delete count's pin.
- **Honest test edits (subject untouched, each commented):** `BookArrivalsTests.theLineIsTheTwoActsOne
  RendererAndTheyAreDeclaredAsDrawn` (the line's declared set grows by the two arms, row 19);
  `CapabilityRegistryTests` (the walk's unions name the new renderers — the JUSTIFIED-EDIT class).
- **Suites (the close, on the committed tree + the one-line arrivals hover):** core `swift test` FULL —
  "Test run with 2004 tests in 212 suites passed" (1 skipped: the standing env-gated Supabase test);
  Mac `build-for-testing` GREEN + "Test run with 575 tests in 82 suites passed … with 4 known issues" (the
  pre-existing `IndexTierMetricsTests` marks) — every new suite, every suite naming a touched surface
  (book view, Outline/Index/landing, Library, Pool, shelf, readings, settings, Trash/recovery, note box,
  arrivals, state doors), the registry walk and all eleven `TutorialWalkTests.swift` suites; the phone
  `VariorumMobile` generic iOS Simulator BUILD SUCCEEDED + the four phone suites on the shared Trash road
  (iPhone 17 Pro sim) "72 tests in 5 suites passed … with 2 known issues" (the deliberate
  `MobileTrashTests` marks). Zero app instances before every mounted run (`pgrep` clean).
- **No bug-class row in this brief** (a face unit) — red-on-old applied to nothing; W-1/W-2/W-3 are
  presentation defects the walk found, evidenced by before/after captures and pinned.

### PROVISIONALs made in U4 (each QUESTIONS-ready for #169)

- **P-13ic-U4-1 — The daily Journal's own "+ new entry" BELLS on an ownership conflict** (⌘J's ruled
  shape) instead of opening the choice sheet. *QUESTIONS paragraph:* "If today's entry already belongs to
  an owned book and you press '+ new entry' inside your daily Journal, the entry opens and waits at the
  Journal's door (where you can copy it in, move it in or dismiss it) — (a) as built, the same as ⌘J;
  (b) ask right there with the copy/move sheet."
- **P-13ic-U4-2 — Move In from the Arrivals line acts at once** — the row's own line already names the
  books it will leave (the sheet hosts show the full severed list before Move). *QUESTIONS paragraph:*
  "(a) As built; (b) Move In on a waiting row asks first, listing what it leaves."
- **P-13ic-U4-3 — Manage Notes… carries the remove/release door too** (beyond §20's three named places),
  its outcome said inside the sheet. *QUESTIONS paragraph:* "(a) As built — the same word everywhere a
  note leaves a book; (b) Manage Notes keeps a plain 'Remove'."
- **P-13ic-U4-4 — The two ownership settings live in Settings ▸ Editor ▸ Books** (the brief: "where
  arrival_flash lives"). *QUESTIONS paragraph:* "(a) Editor ▸ Books — as built; (b) General; (c) a new
  Books pane."
- **P-13ic-U4-5 — The marks' look:** the shared mark is a small muted two-squares glyph with the books on
  hover; the owned-by mark is the words "owned by “X”", clickable. *QUESTIONS paragraph:* "(a) As built;
  (b) a different glyph or words (13s)."
- **P-13ic-U4-6 — A plain book's Delete now asks** (it acted at once before; the brief's plain confirm),
  and the owned confirm's keyboard default is the SAFE choice, "Delete Book Only". *QUESTIONS paragraph:*
  "(a) As built; (b) a plain book deletes without asking (the Trash is the undo)."
- **P-13ic-U4-7 — Duplicate's defaults:** the name "X copy"; "With copies" off on a plain book. Alt:
  copies on by default.
- **P-13ic-U4-8 — The gathering's honest door offers only the rule's POSITIVE tags the note wears** (by
  subtree), none for a note matched through ★ alone, and its receipt says whether the gathering still
  shows it. *QUESTIONS paragraph:* "(a) As built; (b) also offer 'Unstar' when the match is the star."
- **P-13ic-U4-9 — No owned-by mark in the Pool** (the brief listed it): Pool notes are bookless by
  definition, so the mark could only ever show for a race. *QUESTIONS paragraph:* "(a) As built —
  silent, no read paid; (b) wire it anyway."
- **P-13ic-U4-10 — A plain remove that leaves the note in no book says so** ("…untouched. It's in the
  Pool now."). Alt: the brief's sentence alone.
- **P-13ic-U4-11 — The new door/receipt/badge/confirm wording** (all 13s-revoicable; the truths ruled).

### FINDINGS (for the orchestrator; none a STOP condition)

- **F-U4-1 (the plan's text; recorded):** §4 row 15 names `BookStructureModel`'s "drag roads ×2" as
  membership-creating; they are within-book reorder/assign roads (BookDrag payloads only). The model's
  add roads are `newEntry`'s two — dispositioned above. Suggest the closeout corrects the row's text.
- **F-U4-2 (the 18i seam's owner / 13i-d):** with `receipt_style` = quiet (her default), a receipt
  spoken from a book view, the shelf or the Library has NO line to land on (the quiet line lives in the
  editors' bottom bars) — the note box's Remove landed silently on screen (u4-09). Pre-existing seam
  shape; the walk switched receipts to toasts to capture them, then restored "quiet".
- **F-U4-3 (13i-d):** no Delete/Duplicate door on the book view's gear/settings sheet (fenced here).
- **F-U4-4 (recorded):** the Pool's owned-by mark is structurally silent (P-13ic-U4-9).
- **F-U4-5 (13i-d):** §20's "Book Panel's row menu" remove door awaits the Book Panel itself.
- **F-U4-6 (the mobile catch-up — MobileSoul row):** the phone's Trash row lacks "and N notes" (its Put
  back receipt IS whole — the shared road); its Today/⌘J-equivalent waiting note stays generic; its
  membership face speaks the shared ownership refusal words, no sheet (F-U2-8).
- **F-U4-7 (recorded):** the shelf-row drop was proven through the mounted `ShelfView` pin, not by a
  hand drag (a cliclick list-row → shelf-row drag is unproven in WalkKit); the same `MembershipDoors`
  road was walked through the chip and Manage Notes.
- **F-U4-8 (recorded):** `ReadingsViewModel.delete` has no caller now (the shelf's delete routes through
  the state doors); kept, harmless — the ladder may retire it.
- **F-U4-9 (13s copy):** a long "also in …" arrival line truncates mid-list (the hover, added at the
  close, gives it whole).
- **F-U4-10 (walk residue — dev store only):** books "u4 owned" (owned, rule #u4ring), "u4 other", "u4
  other copy" (FINISHED), "u4 owned copy", "u4 third", the gathering "u4 ring gathering"; "u4 owned two"
  in the Trash (book-only delete); notes "u4 alpha"…"u4 eta" and their copies; the tag #u4ring. Her dev
  store's voice (Terminal), appearance preference (`system`), receipts ("quiet") and badges (on)
  RESTORED and read back.
- **Tutorial (P-6):** no lesson sentence went false; lessons 2, 5 and 8 are now said at the doors (the
  sheet's edit law; the release receipt; the plain delete's first sentence; the owned delete's two
  choices and "whatever went in together, together"). No tutorial prose rewritten.
- **MOBILE PARITY (for the closeout's row):** the phone gains no face; the shared `TrashPutBack` now
  tells it a with-notes book "is back with its N notes" (shared road, free); everything else the phone
  owes is F-U4-6's list — the mobile catch-up's.

### THE WALK — captures under `notes/plans/13ic-screens/u4/` (gitignored)

Guard OK at every act (`guard.sh --author` FIRST; her app absent; HID idle 4303 s at the open), AX +
Screen grants true, the dev-store Debug build `DerivedData/13ic-u4` (`io.lduarte.Variorum.debug`), my own
`caffeinate -d`; quit by bundle identity, never a keystroke; zero instances at the end.
**Terminal · light (R4 by hand, end to end):** u4-01 the owned book's shelf menu (Stop Owning, Duplicate
with Copies…, Delete Book…) · u4-02 the chip's "release" word on an owned book · u4-03 ROW 14 — Add an
owned note to a plain book → the copy-only sheet · u4-04 Copy Into landed · u4-05 the Outline's shared mark
· u4-06 the Index row's shared mark + the note box · u4-07 **W-2's before** (the row's hover shadowed the
mark's) · u4-08 the note box's book context "Remove from This Book" · u4-09 the remove landed silently
(F-U4-2) · u4-10/11 Settings ▸ Editor ▸ Books · u4-12 ROW 14 — copy·move with the severed list · u4-13 Move
In's receipt names what it left · u4-14 the Index row menu's "Release from This Book" · u4-15 "Released
… it's in the Pool now." · u4-16 the Pool holds it · u4-17 ROW 16 — a bookless note moves into an owned
book clean · u4-18 the Library's owned-by marks · u4-19 the mark's click opened the book · u4-20 ROW 19 —
an arrival at the owned door: Copy In · Move In · Dismiss + "also in “u4 other”" · u4-21 Copy In landed ·
u4-22 a PLAIN book's delete confirm · u4-23 the OWNED book's two-choice confirm · u4-24 book-only → "its 2
notes are in the Pool now" · u4-25 with its notes → one stamp · u4-26 the Trash's "book and 4 notes" row ·
u4-27 Put back: "“u4 owned” is back with its 4 notes." · u4-28/29 Duplicate (shallow) + receipt · u4-30/31
Duplicate with Copies only (checkbox fixed) + "4 copies." · u4-32 a gathering's view wears owned-by marks
· u4-33 its click opened the owner · u4-34 the chip's gathering row "remove #u4ring" · u4-35 its receipt
· u4-36 badges OFF → the Library silent · u4-37 badges back on · u4-38 ROW 18 — Manage Notes' Add → the
sheet (W-1's before: the button lowercased her book's name) · u4-39 the copy joined the list.
**Terminal · dark (after W-1/W-2/W-3):** u4-40 Library marks · u4-41 the chip over three books · u4-42 the
copy·move sheet · u4-43 the arrival arms · u4-44 the owned delete. **Study · dark:** u4-45 Library · u4-46
the sheet (Copy In / Move In voiced) · u4-47 the arrival arms · u4-48 the owned delete. **Study · light:**
u4-49 the owned delete · u4-50 the arrival arms · u4-51 Dismissed · u4-52 Move In DISABLED, the sheet
naming the finished book that holds it · u4-53 Library marks.

### LIVE STATUS (per commit; every unverified claim PENDING)

- **Piece A — THE CHOICE SHEET + the add doors (§4 rows 14–18):** DONE (45557e8d). MembershipChoice +
  the registry walk 42/2; the regression sweep 104/24.
- **Piece B — remove/release + the gathering's "remove #tag":** DONE (8a6af026). 65/6 + 44/7.
- **Piece C — the Arrivals arms (§4 row 19):** DONE (6245ba0e). 43/3.
- **Piece D — Delete (three arms) + Duplicate Book…:** DONE (33cbe567). 80/8 + core 14/1.
- **Piece E — the badge family + the sealed chip + the Settings rows:** DONE (24d74a36). 281/44.
- **Piece F — the Trash's "and N notes" + Put back's receipt:** DONE (d870d2b1). 245/25.
- **Piece G — THE WALK + W-1/W-2/W-3 (8f35a60c) + the close:** DONE (the closing commit). The walk's four
  legs captured (53); the arrivals line's hover (the close's one-line nit); core FULL 2004/212 · Mac
  575/82 · phone build + 72/5 — all green on the committed tree; ledger row 5 flipped in this commit.
- **Machinery honesty:** the record's heading was inserted on its OWN line by a whole-line match (the
  U2/U3 swallow avoided); one walk step clicked a stale coordinate (forgot the window's Y offset) and
  sent stray keystrokes — checked afterwards: no note, book or text changed (the Library showed no new
  note; the book's cards unchanged), the step redone at the right point. No revert was ever in flight;
  zero app instances at open and at close.

## §8 ENVIRONMENT TRAPS (binding; the standing invariant core, carried per the skill)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store
instances are treated by STORE, never quit/killed; no Release builds or `/Applications` refreshes
while one lives — and THIS run's refresh is HELD for the deploy window (§11; a marker-11 build
against the marker-10 mirror refuses to sync). `xcodebuild build-for-testing` compiles without the
runner; Mac tests from `App/Variorum/` with suite-level `-only-testing` only, confirming the "Test
run with N tests" line (skips counted — read the `skipped:` lines); zsh `pipestatus`; NEVER a
custom build configuration (non-"Debug" names strip the DEBUG oracles); suites beside a live
session flash test windows — prefer zero-instance windows; backups WAL-safe, UTC names, into
`Backups/safety-copies/` (the A1 rail) before ANY real-store touch; never `git checkout` over
uncommitted work; push after every commit; never force-push. The dev store
(`io.lduarte.Variorum.debug`) NEVER syncs (fenced) — sync evidence is the fake-server suites, never
the production mirror. Foreground waits only; poll logs with `grep -q … && break` loops (the
`tail -f` trap). Background-wait = death for subagents. Known full-run flake rows (KnownIssues: the
latency pin, `CanvasDragTrackingTests`, the per-note-defaults family): adjudicate by isolation +
attribution before treating any red as this phase's. Walk drives (cliclick/WalkKit) are DEV-STORE
Debug only, author-free, own `caffeinate -d`.

## §9 PROVISIONALS MADE AT THIS KICKOFF (each logged in QUESTIONS #169 at close; each one line to overturn)

- **P-13ic-1 — the Own conversion registers NO structural-undo entry**: its copies are real notes
  (round 4: "conversion-time copies persist"); Stop owning is the symmetric door. *Alt:* one
  compound entry un-minting the copies and reviving the originals' rows.
- **P-13ic-2 — owning a FINISHED or SEALED book refuses** (`lockedReading`): the conversion
  diverges members, a structural act. *Alt:* allow when no member would fork.
- **P-13ic-3 — a copy-in that answers an ARRIVAL decides the pair PERMANENTLY** (a member-class
  tombstone): a fresh act never offers a second copy. *Alt:* the dismissal class (rings again).
- **P-13ic-4 — the bind's owned-notes limb defaults to LEAVE OUT** (copies are ceremonies, never
  silent); copy-in is the explicit choice. *Alt:* default copy-in.
- **P-13ic-5 — TAGS RIDE every OWNERSHIP-CEREMONY copy** (the Own conversion's forks, copy-in, the
  seal's forks, the deep duplicate) — ruled §6; the OLDER copy doors (`duplicateAsVersion`, the
  chip's Diverge for book) keep NOT carrying tags (their recorded letter). *Open for her:* should
  those two carry tags now too?
- **P-13ic-6 — deleting a sealed book (book-only) leaves its members' seals** as real post seals;
  Put back restores a sealed book with matching stamps. *Alt:* unseal members at book deletion.
- **P-13ic-7 — Duplicate copies the book's CONFIGURATION, not its STATE** (rule, outflow, dial,
  extents, trait, chapters; never finished/sealed/owned/star/shelf), runs no backfill, registers no
  undo (the Trash is the road). *Alts:* copy the star/shelf; backfill a duplicate born with a rule.
- **P-13ic-8 — `auto_tag_ids` travels PLAIN** (ids — the class of the column it replaces, and of
  every reading flag); the disclosure delta is "how many tags a book flows into," content-free.
  *Alt:* ENCRYPTED like `query_spec` (ids too, sealed by precedent).
- **P-13ic-9 — the revival pass ranks by `created_at, id`** (the local "earlier act" — R2 ranks by
  `server_seq` for the same reason). *Alt:* the revived row always yields.
- **P-13ic-10 — the badge family's one switch is a SYNCED setting** `ownership_badges` (default
  on; the `arrival_flash` class). *Alt:* local-only.
- **P-13ic-11 — `tagAllMembers(nil)` means EVERY outflow tag**, and its receipt counts NOTES newly
  wearing at least one; the offer's N counts members missing any. *Alt:* count applications.
- **P-13ic-12 — Move in registers no structural-undo entry** (the `addPostToReading` class; the
  severed list is named in the confirm and the receipt; a re-add by hand is the road back).
  *Alt:* one entry reviving the severed rows.

## §10 LEDGER (every row owned; statuses flip in the same commit as the work)

| # | Item | Status |
|---|---|---|
| 1 | Plan authored; her four kickoff rulings recorded (§1); PROVISIONALs (§9) | DONE (this commit) |
| 2 | U1 — the outflow event (migration v1_20, model, serializer, marker 11, the mirror artifact + §11 checklist), no-rule-is-nothing, the outflow ops, F-5, the pins | **BUILT + PINNED 2026-10-01** (the U1 RECORD above; core 1927/202 · Mac 83/9 · phone build green; commits b4cb639b + 19eb55c0; the deploy checklist `notes/plans/13i-c-deploy-checklist.md`). **The dev-store WALK is HELD** (author at the machine) and folded into U3's walk window |
| 3 | U2 — the Owned + Sealed op family, delete/duplicate/restore-whole, the three readers' scoping, hide-owned + badge facts, `OwnershipDoorTests` rows 1–12, the soak, the R4 ritual | **BUILT + PINNED 2026-10-01** (the U2 RECORD above; core 2001/211 · Mac 772/135 · phone 102/16 · both builds green; commits 936f8cf9 → the closing commit; nine PROVISIONALs P-13ic-U2-1…9 for #169; FINDINGS F-U2-1…9 — F-U2-1, `unlockPost` inside a sealed book, is a reserved fork for the architect). Headless — no walk owed by this unit |
| 4 | U3 — the settings sheet (Collecting + state doors + confirms), the outflow chooser, the gathering mint/empty-save, the spawn prefill face, the shelf menu doors, the registry | **BUILT + PINNED + WALKED 2026-10-01** (the U3 RECORD above; core 2004/212 · Mac 445/73 · phone build green; commits 163b9545 → the closing commit; the walk found and fixed W-1/W-2/W-3; fifty captures, both voices × both appearances; seven PROVISIONALs P-13ic-U3-1…7 for #169; FINDINGS F-U3-1…10 — F-U3-2 is U4's delete door; the bind sheet's owned-notes limb built here per §3) |
| 5 | U4 — the membership doors' faces (rows 14–21), the choice sheet, the delete/duplicate doors, remove/release words, the badges, the Settings rows, the Trash row | **BUILT + PINNED + WALKED 2026-10-01** (the U4 RECORD above; core 2004/212 · Mac 575/82 · phone build + 72/5 green; commits e45d19d6 → the closing commit; the walk found and fixed W-1/W-2/W-3; 53 captures, both voices × both appearances; eleven PROVISIONALs P-13ic-U4-1…11 for #169; FINDINGS F-U4-1…10 — F-U4-1 corrects §4 row 15's text, F-U4-2 is the 18i seam's quiet-receipt gap) |
| 6 | The ladder (fresh `fable-reviewer`, combined diff; cross-model flow) | NOT STARTED |
| 7 | Her deploy window (§11) + the install refresh + the phone's tail | HELD for her go |
| 8 | Closeout + handoff + 13i-d's plan (carrying R-13ic-2's doors + the combined-walk list) | NOT STARTED |

## §11 THE DEPLOY CHECKLIST (HER WINDOW — mirror → Mac → phone, one sitting; the 13i-a shape)

1. The ladder closed green; the full core + Mac + mobile suites green at the tip.
2. Zero-instance window (SHE quits the real-store app); the A1 WAL-safe safety copy into
   `Backups/safety-copies/` with a UTC name.
3. Her one-line PRE-DEPLOY SUMMARY: the §9 PROVISIONALs that touch the wire (P-13ic-8 only).
4. **The mirror:** `Server/supabase/14_phase13i_c_outflow.sql` whole (her hand via the `!` road —
   the 13i-a checklist's commands with the file name swapped — or the architect through the PAT at
   her word; on a live error, the read-fix-re-run road). Verify: `sync_schema_version()` = 11; the
   column present; the post-deploy grant sweep every-row OK/INFO.
5. **The Mac:** Release build (lockstep 11) → the A1-railed copy to `/Applications` → codesign
   verify → SHE relaunches; first open runs `v1_20` (the carry-over; any rule-less gathering to the
   Trash); her first round pushes the carried rows; verify a clean round.
6. **The phone:** her Xcode run to device; its first round converges.
7. Both directions proven live; the §12 running-record entry written THEN; ledger row 7 flipped.

## LIVE STATUS (the resiliency protocol's record — updated per commit; every unverified claim marked PENDING)

- 2026-10-01 · kickoff: preflight complete (CLAUDE.md + canon, the master plan, KnownIssues
  whole, QUESTIONS #166–#168, the sitting record whole, the 13i-a record + handoff + deploy
  checklist, the 13i-b record whole + handoff + the ladder's F-R1-7 thread, SyncSpec in full, the
  resiliency protocol, the sizing guidance; TEXTKIT2_NOTES not required — no editor seam). Code
  orientation done (IntakeDecision + the intake ops, the reading/conversion/diverge/deletion/lock
  ops, Repairs' R2, SyncSchema's reading entry, the v1_18 migration, the 13 mirror artifact, the
  Book Settings sheet, the shelf menu, the chip, the drag roads, the Trash). Her four kickoff
  rulings recorded (§1). This plan authored as the first act. No revert in flight. U1 (Fable)
  opens next.
- **U1 BUILT + PINNED (2026-10-01):** commits b4cb639b (core) + 19eb55c0 (Mac); the U1 RECORD
  written; the deploy checklist authored; the walk HELD at the author guard (folded to U3's
  window). No revert in flight; zero instances. U2 (`opus-implementer`) spawns next from the
  plan's §3/§5/§6/§4 rows 1–12/§7 U2/§8/§9.
- **U2 VERIFIED + ADJUDICATED (2026-10-01):** U2's twelve commits spot-checked (record on disk,
  no trailers, its suites re-run green); the swallowed record heading restored; F-U2-1 ruled and
  built with its red-on-old pin (core 2003/212; Mac refusal/spine suites 32/4); the U3 BRIEF
  written. No revert in flight; zero instances. U3 (`opus-implementer`) spawns next.
- **U3 VERIFIED + ADJUDICATED (2026-10-01):** ten commits spot-checked (record whole, no
  trailers, fifty captures, its suites re-run 62/8 green); P-13ic-U3-2 ruled to the record's letter
  with 13i-d as the faces' owner; the U4 BRIEF written. No revert in flight; zero instances. U4
  (`opus-implementer`) spawns next — then the ladder.
