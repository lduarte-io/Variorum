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

**NOT DONE BY THIS UNIT (first line, per the contract):** IN PROGRESS — the full NOT-DONE line is
written at the close. Standing scope fence: no face of any kind (U3/U4), zero `Sync/`, zero schema.

**UNIT STATUS: IN PROGRESS.**

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
  App compile arms for `.waitingAtDoor` + the refusal words: PENDING (piece F).
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
  the record closed; ledger row 3:** IN-PROGRESS. `OwnershipDoorTests` 12/12 DONE (one per row,
  each asserting the consult + the outcome + the exclusivity invariant). The app compile arms
  DONE (2509647d — Mac + phone builds green then). `OwnershipSoakTests` DONE (6 seeds × 250
  steps over own/un-own/add/copy/move/answering arms/remove/seat/dismiss/tag/finish/reopen/seal/
  unseal/delete both ways/restore book/delete+restore note/duplicate both ways/diverge;
  invariants exclusivity · seal · no duplicate pair · I10 · I2 after every step) — it FOUND a bug
  on its first run (seeds 3 and 777): a note deleted while a member, its book SEALED while it lay
  in the Trash, then put back, revived INTO the sealed book unsealed. Pinned red-first
  (`BookSealTests.aNoteInTheTrashWhenItsBookWasSealedComesBackOutsideTheSealedBook` + the
  restoreReading twin `aSealedBookPutBackTakesBackOnlyItsSealedMembers`), fixed by guarding both
  revival roads (a membership revives into a SEALED book only when its note is sealed —
  PROVISIONAL P-13ic-U2-6); soak + seal suite green; the restore-family sweep 848/85 green again.
  REMAINING: the ritual + lessons, the
  shared refusal words (+ a `bookSeal` road — the integrity walk bans the bare "sealed"/"unseal"
  stems in the shared file), the Mac/phone builds + touched suites, the FULL core suite, the close.
- No revert in flight.

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
| 3 | U2 — the Owned + Sealed op family, delete/duplicate/restore-whole, the three readers' scoping, hide-owned + badge facts, `OwnershipDoorTests` rows 1–12, the soak, the R4 ritual | NOT STARTED |
| 4 | U3 — the settings sheet (Collecting + state doors + confirms), the outflow chooser, the gathering mint/empty-save, the spawn prefill face, the shelf menu doors, the registry | NOT STARTED |
| 5 | U4 — the membership doors' faces (rows 14–21), the choice sheet, the delete/duplicate doors, remove/release words, the badges, the Settings rows, the Trash row | NOT STARTED |
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
