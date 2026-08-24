# The post-13l polish round (EXECUTION PLAN)

**STATUS: AUTHORED 2026-08-24, the morning after 13l closed — from the
author's post-close sitting** (her walk of the shipped surfaces + her
rulings on the 13l walk's P-1…P-9 list, all recorded verbatim below
the same hour they were made). **Her ruling: this round runs NOW,
BEFORE 13u**, standalone (the 13k walk's-build-round precedent), with
EVERYTHING in scope — the small fixes AND the design reworks. A FRESH
orchestrator runs it: invoke `/architect-phase` NAMING THIS FILE
(a bare invocation resolves to the master-plan pointer). Cast at
kickoff as always (her standing preference this era: Opus
implementers · Fable cold reviews). Numbering/slotting of the round
is hers at kickoff; the master plan's running order carries its row.

## Kickoff message (paste-ready — REWRITTEN at her ask after the second morning sitting, 2026-08-24)

> You are running **the post-13l polish round** — the author's two
> morning-after sittings (2026-08-24) turned into ONE round: her
> rulings on the 13l recovery walk's findings, an IA pass, the
> side-panel theme, and **THE RECOVERY MAP** — one home per kind of
> past, ending in the whole-note VERSIONS door. Invoke via
> `/architect-phase` NAMING THIS FILE (a bare invocation resolves to
> the master-plan pointer). Cast at kickoff as always (her standing
> era preference: Opus implementers · Fable cold reviews).
>
> **READ IN FULL FIRST:** `CLAUDE.md` + the canon it loads · THIS
> FILE top to bottom (her rulings are the letter; the ledger is the
> scope — note rows revised the same morning they were made: D1's
> supersession and rows 15–19 are the CURRENT letter) · the 13l
> plan's **Act 7 — WALK RECORD** and Act 2 record
> (`notes/plans/phase-13l-data-safety-floor.md`) · the 13j plan's
> **Environment traps** (binding verbatim) ·
> `notes/handoffs/phase-13l-handoff.md` ·
> `notes/plans/whole-note-history-brief.md` (the automated future
> whose listing row 16's manual door creates now — don't foreclose
> it). Copy the P-1…P-9 constitution in verbatim.
>
> **THE NORTH STAR (hers, this morning):** everything a user ever had
> is in exactly ONE of five places — **where you left it · set aside
> in Archive (forever) · in the Trash (30 days; notes · books ·
> blocks ONLY) · in this note's VERSIONS (moments you saved) · in
> this block's HISTORY (its takes and savepoints).** Every ledger row
> serves that map; her stated fear is the reason it exists: *"people
> are going to conclude that the one thing they really want (my whole
> note at this point in time) … is way too hard to get, even though
> we're actually offering infinitely more ways of saving your
> ideas."* When a build choice is ambiguous, the five-places map is
> the tiebreaker.
>
> **Baselines:** 13l's finals (core 1373/143 · Mac 1691/292 · Mac
> spine 63/8 · mobile 486/78 · mobile spine 33/7 · marker 7) plus the
> post-close commits (the scraps-door removal `cad80b0` and records);
> your kickoff full runs are the verification. Flake carry: the
> Phase-12 latency pin (isolate before concluding);
> `CanvasDragTrackingTests` at ONE recorded red — **a second red
> promotes it** (owner 12). **ZERO schema anywhere** (anything
> firming toward a column is a §12 lockstep STOP); zero
> `Sources/VariorumCore/Sync/`. Her app is LIVE daily again —
> instance checks before any install act; the closeout refreshes
> `/Applications` behind the A1 rail and **RE-SEEDS her field guide**
> (row 19/D2's lesson edits make this mandatory).

## HER RULINGS (2026-08-24 morning sitting — verbatim-faithful; the letter of the round)

**A · THE SMALL FIXES (all ruled "fix"):**
- **A1 (was P-4):** the stale "isn't in this note's tray" line after a
  successful Put back — *"that just seems sloppy, it should show a
  success message if anything."*
- **A2 (was P-5):** the filtered-empty Trash — *"it can say the trash
  is empty, but there should be a filters applied chip or something
  of the sort to make it clear."*
- **A3 (was P-7):** Trash rows name their context — *"a deleted take
  definitely needs to name both note & block or it's kinda useless."*
  (Blocks name their note; takes name note AND block. This also
  dissolves her "why do only some rows say Open note" confusion —
  the button renders only where the home note is alive, and named
  rows make that legible.)
- **A4 (was P-8):** the scraps editor's small honesty wordings —
  *"I'd fix whatever this is."*
- **A5 (was P-9):** the note-delete confirm's two-names-in-one-
  sentence — *"should be fixed."*
- **A6:** success messages painted in the error color — *"the color:
  should be fixed."*
- **A7 (was P-2 — DECLINED, deliberately):** *"I don't think that P2
  is a need: users should learn in the tutorial we'll make where
  they go, it's annoying to see that message every time."* No
  per-merge message is built. One sentence about where a merge's
  originals live joins the tutorial's deletion chapter IF the
  round's lesson edits (D2 below) are already touching it — else it
  rides 13s's rewrite.

**B · THE IA PASS:**
- **B1:** *"I want the ... menu in the upper right of the library to
  be replaced with a trash icon"* — the Trash gets the clear icon;
  *"open tutorial doesn't need to be under the ... menu, it could be
  under help if anything"* — the tutorial door moves to the Help
  menu; the ⋯ menu dissolves.
- **B2 — THE ARCHIVED SIDEBAR ITEM** (her direction + her Q-answer:
  **archived NOTES only**): *"archived should be a different item on
  the left (like where library is, but it says archived)…
  separating archive and trash more makes sense - archive is
  available forever and maybe still valuable even if you don't want
  it in your current library, and it would be nice to be able to
  search it separately."* Archived BLOCKS stay in their note's tray;
  archived TAKES stay in Takes mode's strip — each archived thing
  lives where its context is (the ruled option's letter). The
  search-it-separately half is 13o's BY CONSTRUCTION — this round
  builds the surface; 13o's plan inherits the scope note. **The
  sidebar IA change (R44 + the model's §6 archive/tombstone
  distinction made visible) is a canonical-doc delta at this round's
  closeout, citing her words.**

**C · THE SIDE-PANEL THEME** (*"I think that making use of the side
panel as extra space is needed"*):
- **C1 (was P-1, re-ruled bigger):** *"the note tray should move to
  being an icon next to the scraps and reference icon and open in
  the side bar, with preserved originals separated from deleted…
  if it opened in a pane to the right, it would have the space to
  let you scroll through them at a more reasonable size and would
  keep the top bar from being crowded."* The note ▾ tray menu item
  and ⌫ badge choreography follow the move (the badge may stay as a
  signal; the DOOR is the icon — the kickoff's small call).
- **C2 (was P-3, expanded):** the lineage door shows **ALL** of a
  merge's originals — *"it could be more than two originals even"*
  (the N-way merge chain makes this real) — *"or it should give the
  option to open lineage in the side panel."* Build the side-panel
  lineage view (all originals, Put back + open-tray per original).
  **Mobile:** her floated shape recorded UNCHOSEN — *"maybe pulling
  up a view like the mobile takes view but for seeing lineage…
  either way I think there should be an easier way to see full
  lineage"* — a PARITY NOTE for the next mobile session, never built
  here.

**D · DELETED TAKES IN THE TRASH (her shape, chosen at the sitting):**
- **D1 (SUPERSEDED the same morning, second sitting — her revision,
  confirmed via the question tool):** takes **NEVER appear as rows in
  the Trash or any Archived surface.** Her words: *"I feel like takes
  should never appear in trash or archived alone - even if their
  parent block is live, it's really hard without context and a take
  alone is so small."* **A take's ONE past-home is its block's
  History face** (whose door row 17 makes findable). The Trash
  becomes **notes · books · blocks**, each naming its context (A3).
  The earlier nested-under-block shape is superseded; the deleted-take
  Trash rows and their query arm's LISTING (not the data) come out.
- **D2 — the tutorial consequence (the round's own catch, binding):**
  the tray DOOR moves (C1) and the Trash's shape changes (D1) — the
  field guide's deletion chapter teaches the OLD doors, and the
  spine walks them. **Lesson content updates ride this round** (a
  broken tutorial step is a regression by definition — P-6), the
  spine re-pins to the new doors, **and the closeout RE-SEEDS her
  real store's field guide via the product door behind the A1 rail**
  (the standing lesson-edit rule).

**E · ROUTED, NOT THIS ROUND'S:** #78's shape — her disposition:
*"I think we don't have to solve this right now?"* + the architect's
recommended shape (b) recorded at QUESTIONS #78 and as a rider in
13p's plan (restage stops stamping the sentinel onto dead days —
structural prevention, no Fragments-side change needed). The mobile
lineage shape (C2's parity note). The P-6 archived-strip
DISCOVERABILITY beyond what B2/D1 fix — watch her use; A3's naming
plus the archive/trash separation are expected to dissolve it.

## The ledger

| # | item | status |
|---|---|---|
| 1 | A1 the Put-back success message | open |
| 2 | A2 the filters-applied chip | open |
| 3 | A3 Trash rows name note (+block for takes) | open |
| 4 | A4 scraps-editor wordings | open |
| 5 | A5 the confirm's one-name sentence | open |
| 6 | A6 success-in-error-color | open |
| 7 | B1 the Trash icon + Help-menu tutorial move | open |
| 8 | B2 the Archived sidebar surface (notes only) + the R44 delta at closeout | open |
| 9 | C1 the tray icon → side panel, originals separated | open |
| 10 | C2 the side-panel lineage view, ALL originals | open |
| 11 | D1 takes nested under context-parent block rows | open |
| 12 | D2 the lesson edits + spine re-pins + her-store re-seed at closeout | open |
| 13 | Closeout ritual: records · canonical deltas as ruled · MobileSoul parity notes (C2 mobile shape; PL-11's tray face follows C1's ruled shape) · QUESTIONS for any PROVISIONAL · the running-order row closed | open |
| 14 | **F1 — ARCHIVE RIDES BESIDE DELETE AT EVERY BLOCK DOOR** (her second morning report, 2026-08-24 — later softened: *"no, I see archive there too"*, so this is a VERIFICATION pass, not a rescue). The menu BAR's Block menu pairs them adjacently (13j's letter — verified in `EditorCommands.swift`); the pass confirms every OTHER door that offers a block Delete without the Archive twin (context/row menus — enumerate via the registry, the door-set is checkable). Same pass verifies the TAKE-card menus: Write's panel ⋯ carries Archive · Label · Lock · Delete (verified) — Takes mode's card grammar must match. **Context for the builder: the 13l walk's P-6 sentence ("the only door that deletes a take is inside the archived strip") is OVERSTATED — active take cards carry Delete; do not build against P-6's wording.** Her open musing, verbatim, for the round's checkpoint — *"I don't even know if we need take archiving if I'm not seeing it right now?"* — with the architect's recommendation recorded: KEEP the capability (her own morning argument — archive is forever-valuable and distinct from the clock — applies to takes exactly; the model's I10-rescue and pool-copy semantics also mint archived states), FIX the doors; retiring it is hers to rule if the fixed doors still don't earn it | open |
| 15 | **F2 — RESOLVED BY HER OWN SECOND LOOK, folded into 17:** she FOUND the deleted take in the block's History past region (*"I actually do see the deleted take in history"*) — not a data bug; a DOOR-PLACEMENT problem (*"it's unclear that history is under Note, that makes it seem like the Note's history"*). No Trash-side trace owed (takes leave the Trash by D1-revised anyway). Row 17 is the fix | **resolved → 17** |
| 16 | **G1 — THE WHOLE-NOTE VERSIONS DOOR (her ruling: "yes, in this round").** Her floated shape, adopted: *"an easy door would be to make a copy of the note, archive it, and then let you look through the archived copies made at points in time - not automated, but an easy door for people who want to save the whole note as it is."* **COMPOSE, don't build:** "Save a copy of this note as it is" = `duplicateAsVersion` (exists; mints the `version_of` edge) + note archive (exists) → a **"Versions of this note"** listing (dated, openable, restorable-by-copy) driven by the `version_of` lineage — one query, zero schema, zero new concepts. The copies also appear under the Archived-notes surface (B2) as ordinary archived notes. **`notes/plans/whole-note-history-brief.md` is the AUTOMATED future that later fills this same listing — read it so the manual door's shape doesn't foreclose it.** This is the round's headline: the Google-Docs answer ("my whole note at this point in time"), which her holistic worry named as the one thing people will conclude is missing | open |
| 17 | **G2 — THE ONE BLOCK HISTORY PANE (her second-sitting revision — supersedes the same morning's block-menu ruling, her words: "I know I just ruled that history should go in the block menu, but I think I'm changing my mind and it should be in the bottom chrome - my reasoning is that history is quite similar to commit, it's the natural pair to commit").** The door lives in the BOTTOM CHROME beside Commit (write a moment / see the moments — the bar becomes the block's time controls) and opens ONE cohesive side pane: **each live take's savepoint run (ALL takes, sectioned, the focused take's expanded — her ruling) · archived takes (Unarchive) · deleted takes (clocks + Put back) · came-from (the lineage section: a merge's ALL originals, each with a DIRECT restore button — her fourth-sitting ask: *"add as block again to the note (that's too wordy, you can reword the button, but the idea is that if you just merged something then realized you actually wanted a parent block, you should just be able to pull that parent block back into existence easily)"* — the op is `placeBlock`, the W-reversibility primitive; the round drafts the short wording)**. This pane ABSORBS three doors — J3's lineage peek, the History face's past region, the archived disclosure — and C2's separate lineage-view row FOLDS INTO IT (C2's mobile parity note survives unchanged). It is the round's biggest single build and the map's fifth place made real; her stated teaching intent binds the design: *"the 'Block history' pane will be a strong memory and the expectations are clear"* | open |
| 18 | **G3 — THE "UNPLACED" WORDING FOLD (presentation YES, semantics NO — her fold question answered).** Her words: *"why do we have unplaced as separate from archived? should we fold those two concepts in?"* The SEMANTIC fold is declined with the reason recorded: a preserved original rides its FAMILY's purge clock (her own 13j round-8b ruling — "goes with its deleted blocks") while archived means NEVER purged; folding them breaks one promise or the other. The PRESENTATION folds completely: a preserved original reads as *"set aside automatically by the merge — kept until its family goes"*; the word **"unplaced" must never reach a user's eyes** (debug vocabulary only — sweep every surface and receipt for it) | open |
| 19 | **G4 — A NEW TUTORIAL CHAPTER teaches the map (her third-sitting expansion: "the next polish session should definitely add a new tutorial chapter about this… the user should be encouraged to get comfortable with each of the" places).** A NEW chapter (not just lines in the deletion chapter): the five places — *where you left it · Archive (notes, forever) · the Trash (what's leaving: notes·books·blocks, 30 days) · this note's Versions · this block's History* — each visited by the walk, **plus the take-savepoint story made explicit** (her: "making it clear where commit / that particular history by the take is, is also important" — the commit↔history bottom-chrome pairing is the teaching moment). Walk-asserted; D2's re-pin + her-store re-seed cover it | open |
| 20 | **G5 — THE TRAY'S HONEST "LEAVING" SECTION (her third-sitting ruling):** *"the tray of a note should have an honest trash section with everything being deleted, so it's never a surprise - and takes can be shown in that per note trash, albeit maybe not shown by default, so you can always see a list of what will be deleted."* The note's tray panel (C1) gains the complete per-note pre-purge audit: every clocked thing of THIS note — blocks, AND its takes under a collapsed-by-default disclosure — plus clocked originals when their family clock starts (the 13j 8b nets untouched: the visible move, its receipt, the Trash row). **Her fourth-sitting addition: the take rows HERE carry a Delete Now button** (*"to keep the capability"* — confirm-every-time binds it like every purge door). **This supersedes-IN-PART the 13j round-3 rider** ("inside the Trash only — never a door in a note or the editor, ever"): the evolved rule, hers — **purge doors live in TRASH SURFACES (the global Trash AND this note-level trash section), never in the writing flow** — recorded for the closeout's delta. **Originals while UNCLOCKED are lineage-only** (the Block History pane's came-from section — her earlier instinct, now consistent: the tray audits what is LEAVING; lineage holds what is KEPT) | open |
| 21 | **G6 — EMPTY TRASH PURGES EXACTLY WHAT IT ROWS (her ruling, and it SUPERSEDES 13j round-8's "everything, always" — a canon change, hers, recorded for the closeout's delta):** *"should we make 'empty trash' not delete takes by default? … a deleted take on a living block might be the one item a user does want to keep. I think that delete everything, including takes not displayed here, should be an alternative button if it even exists."* Built shape: Empty Trash takes notes · books · blocks + their families (a rowed block's own takes go with it — family-complete, honest, all rowed); **individually-deleted takes on LIVING blocks are untouched by the door** and expire on their own 30-day janitor clock only. **The honesty caveat the copy must carry: sparing from Empty Trash is NOT keeping — the clock still runs; restoring the take is the keep road.** The "delete absolutely everything" alternative button is NOT built (her "if it even exists" lean; recorded — a future door at her word). Takes' Delete Now capability LIVES in the note-level trash (row 20 — her fourth-sitting placement; Block History still carries no purge door); the in-Trash-only rule evolves as row 20 records. Her confirmations, same sitting: NOT clock-exempt (*"i don't want it to be clock exempt"*), and the door-shows-what-it-takes principle stands (*"I just don't think a 'delete everything' button in the trash should delete items that aren't being shown"*) | open |
| 22 | **G7 — TRASH BLOCK ROWS GROUP UNDER THEIR NOTE (the architect's proposal at her "will it be a bunch of blocks in the trash?" — PROVISIONAL, hers to unwind):** the global Trash's block rows gather under a small note-name header (the note itself only rows if IT is deleted), so a note with many deleted blocks reads as one group, not clutter. Composes with A3's naming; presentation only | open |


## THE ARCHITECT'S REVIEW PASS (2026-08-24, closing the design sitting — her ask: "anything I'm not considering"; recommendations for the round's kickoff to ratify, plus one MUST-PIN trap)

**V1 — Versions must NOT row in the Archived top-level (the recursive
principle answers her own crowding worry).** A note with 15 saved
versions would drown genuinely-archived notes. A version's ONE home is
its note's Versions listing (its past lives where it lived); the
Archived surface = deliberately-set-aside notes. Classification needs
NO schema and NO "version" attribute (her lean confirmed): archived +
`version_of`-edge-to-a-live-note IS the class, as a query. **THE CLASSIFIER — SHARPENED AT HER SIXTH-SITTING CATCH** (her
concern: a user's working draft, archived later, must never read as
version history — especially once V2 makes versions ride deletions):
**version-history = BORN ARCHIVED** — the save-a-version door mints
the copy archived in the SAME transaction (`archived_at ==
created_at`, both stamps from one clock call — a same-row birth fact,
never cross-device clock ordering, so the no-clock-trust doctrine is
untouched and no CAS/repair rewrites the pair). **A note that was
EVER live is NEVER version history**: a duplicate-as-version made to
work with is live at birth — a first-class Library note; archived
later it joins Archive and its search as a set-aside WORK, and **it
never rides any deletion** (the covenant absolute for anything that
ever lived). **Unarchiving a version PROMOTES it** — it goes live,
leaves the Versions listing, becomes first-class forever (her "work
with it as a new note" road, derived not built). The earlier
"rare, arguably fine" ambiguity note is RETIRED — her catch was
right that V2 made it destructive. **Optional explicitness upgrade,
recorded not scheduled:** 13p's already-planned §12 lockstep (marker
7→8) could carry an additive edge `origin_op` value for labeled
classification; the round ships on the birth fact alone.
**Fifth-sitting clarifications, at her questions:** (1) versions are
NOT in the regular Library — they are archived at birth, and the
Library lists live notes via the `archived_at` column **which EXISTS
and always has** (AppSpec §7 — the "attribute" her question reached
for is a Phase-1 schema fact; what needs NO attribute is
version-ness, which is archived + the `version_of` edge). The phone's
listings hide them the same way today, zero new work. A compare-copy
she makes and LEAVES LIVE is an ordinary Library note — live vs
archived-at-birth is the whole difference. (2) **Search scopes, ruled
input handed to 13o:** the main search = live notes; the Archived
surface's search = archived NON-version notes; **versions are
searchable only inside their note's Versions/Compare context** — so a
ten-version note matches ONCE in every global scope (her crowding
worry answered structurally, zero schema).

**V2 — THE ORPHANED-VERSIONS HOLE, DISSOLVED BY HER OWN QUESTION
(fifth sitting): VERSIONS RIDE THE NOTE'S DELETION.** Her question —
should a deleted note's version histories delete too? — has the
recursive answer: versions ARE the note's past, and a thing's past
goes where the thing goes. **RATIFIED (author, sixth sitting: "I agree it should auto delete versions and not ask for a confirmation dialog") — the shape as recommended: deleting a note
takes its versions INTO THE TRASH on the same clock** — recoverable
for 30 days (the Trash's note-group, row 22, shows the note with its
versions), purged together after. The Archive covenant is untouched
because versions never were "items in Archived" (V1 — their home is
Note ▸ Versions, not the Archive surface); the Google-Docs intuition
holds (delete the doc, its history goes); and V2's original
"surface-when-unclaimed" conditional is UNNEEDED — an unclaimed
version can no longer exist. **No extra question at delete time — RATIFIED with the shape** (her
"should the user be asked?" answered in her own words above): the existing confirm
gains one honest line ("its N saved versions go with it"); a
mid-delete dialog nobody can answer well is friction, and the keep
road is restoring the version live before (or Put back within 30
days after). Mechanical detail for the build: versions are separate
containers, so the delete door's compound tombstones each and Put
back of the note revives them via the version_of edges — the round
designs the exact stamp story.

**V3 — THE BRIDGE DUPLICATE-DAY TRAP (MUST-PIN, not a taste call):** a
version copy of a JOURNAL note may carry the copied `entry_date` — if
the bridge's day scan sees it, the duplicate-day pause FIRES and her
journal silently stops pushing that day. The round verifies which way
`duplicateAsVersion` + the sweep compose and PINS it: version copies
must never trip the bridge (exclude archived from the day scan, or
drop `entry_date` on version copies — the design detail is the
build's, the pin is mandatory).

**V4 — Restore-as-swap — RATIFIED (author, fifth sitting: "I really
like the restore as swap idea - ratified and added") — and SHARPENED
at her seventh-sitting catch: the restore is IDENTITY-PRESERVING.**
Her trace was right: if restore swapped CONTAINER roles, the once-live
note would be archived-later — never version-classed, orphaned from
the listing, immune to riding deletions. **So restore never swaps
containers: (1) save a version of NOW (a fresh born-archived copy),
then (2) the live note's CONTENT becomes the chosen version's — same
container, same identity, same books/memberships/sync rows.** No
container ever crosses the live/version line during a restore; the
classifier never strains. **TWO ROADS, distinct meanings:** RESTORE =
the note becomes its past (identity kept, always saves first) ·
PROMOTE = unarchive(+unseal) a version — the past becomes a NEW
first-class note (a fork, her "work with it" road). **Design detail
flagged for the build, not solved here:** step 2's block mechanics —
the outgoing live blocks are preserved inside the just-saved version,
but their rows must leave without noising the Trash on every restore;
the round designs the quiet shape within S2's letter.

**V4b — VERSIONS ARE BORN SEALED AS WELL AS BORN ARCHIVED (her
seventh-sitting question "can archived notes be edited?" — answer:
YES, archive is visibility, the SEAL is the guard — exposed this):**
a version is a frozen moment, so the save door mints it archived +
SEALED in one transaction (the seal already refuses edits/commits/
pointer changes; reversible only as the deliberate PROMOTE act).
Archived WORKS stay editable — correct, they are works. Three
existing mechanisms, each doing its own job: the archive hides it,
the seal freezes it, the edge classifies it.

**V5 — The command: ⌘⇧S proposed** ("Save a Version" — the Mac's
save-as chord, semantically exact) beside ⌘S's take-commit; the
grain pairing (⌘S = this take's moment · ⌘⇧S = this note's moment) is
itself teachable. The round verifies the chord is free.

**V6 — No title mutation on copies** (her "maybe its name should have
the date" mused): the Versions listing and Compare columns show the
DATE via derived display; the copy's title stays untouched (nothing
renamed, nothing denormalized — the 13u snippet-brain precedent).
Compare auto-collapse of versions: parked as her later refinement.

**V7 — The honest costs, named so they are chosen:** a version is a
FULL family copy (blocks/takes/comments) — storage-proportional to
use, fine at personal scale, and the AUTOMATED future (the
whole-note-history brief) owes a retention policy this manual door
does not; version copies SYNC (the phone's live-unarchived listings
auto-hide them — a parity note verifies); search separation (her
instinct) handles the rest.

**V8 — Her confirmation, answered YES:** deleting the LAST descendant
of preserved originals puts the whole family — descendant AND
originals — in the Trash on one clock (the 13j 8b move + receipt),
and Put back of any descendant reads the originals back to
lineage-held automatically (the fences are read-side; the road is
symmetric and self-healing).

## Constraints

Zero schema (B2 is read-side over `archived_at`; if ANYTHING firms
toward a column it is a §12 lockstep event and a STOP). Zero
`Sources/VariorumCore/Sync/`. Registry discipline (P-1) for every
new/moved door (the trash icon, the tray icon, the Archived item, the
Help move); refusal/receipt copy through the shared homes
(`RecoveryCopy` — both platforms inherit). Red-on-old for bug-class
fixes; walk-driven pins for door moves (the 13l lesson: drive the
real surface). Full four gates per batch that touches `Shared/`;
counts quoted. The 13j Environment traps bind by reference. Her app
is LIVE daily again — re-check instances before any install act; the
closeout refreshes `/Applications` behind the A1 rail.
