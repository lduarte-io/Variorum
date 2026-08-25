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
> FILE top to bottom (her rulings are the letter; the ledger — rows 1–26 —
> is the scope; **the REVIEW PASS (V1–V9) and THE LIFECYCLE TABLE are
> binding, and the TABLE is the round's ACCEPTANCE MAP: every row
> verified and flipped to *completed* at the close.** Rows were
> revised across ten same-day sittings — supersessions are marked in
> place; the latest marking wins) · the 13l
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
| 1 | A1 the Put-back success message | **done** `85e1a54` — `revealMissing` latched at arrival, so a successful Put back no longer prints a not-found line under its own receipt |
| 2 | A2 the filters-applied chip | **done** `85e1a54` — her chip (clicking clears the filter), an honest filtered-empty sentence, and Empty Trash's visibility on a second unfiltered observation; purge SCOPE untouched (G6) |
| 3 | A3 Trash rows name note (+block for takes) | **done** `47c0cb7` — the naming became G7's GROUPING: a note's rows gather under its name, said once instead of on every line (takes leave the Trash by D1, so their half rides batches 3–4) |
| 4 | A4 scraps-editor wordings | **done** `85e1a54` — all three: the scrap receipt names the Trash (home-aware); a registry-declared `.deleteScrap` door on the Snippets rows (#77 fence by construction); `.deleteBlock` gains its context-menu door beside Archive |
| 5 | A5 the confirm's one-name sentence | **done** `85e1a54` — one noun for one road across the whole move-to-Trash family, plus the phone's book confirm which carried the same shape |
| 6 | A6 success-in-error-color | **done** `85e1a54` — `TrayViewModel.Status` classes receipts apart from refusals where they are produced; both colours are voice tokens (the `.red` literals go, tray + origin peek) |
| 7 | B1 the Trash icon + Help-menu tutorial move | **done** `47c0cb7` — the ⋯ dissolves; the masthead renders a trash icon from a door table the header iterates. **The tutorial half was a REMOVAL, not a move** — Help ▸ Open the Tutorial has carried it since 13b Stage 2 |
| 8 | B2 the Archived sidebar surface (notes only) + the R44 delta at closeout | **done (build)** `47c0cb7` — `ArchivedView` + `SidebarSelection.archived` after Snippets, its own name search, Unarchive/Delete rows; the V1 classifier built as the EXCLUSION (`archivedPosts(excludingVersionHistory:)`, default true) with a hand-seeded pin. **The R44 canonical delta is still the CLOSEOUT's** |
| 9 | C1 the tray icon → side panel, originals separated | open |
| 10 | C2 the side-panel lineage view, ALL originals | open |
| 11 | D1 takes nested under context-parent block rows | **done** `47c0cb7` — superseded shape built: takes NEVER row in the global Trash (`TrashScope`, shared, so the phone inherits). Data and clock untouched; known in-round transient recorded (no take listing until batches 3–4) |
| 12 | D2 the lesson edits + spine re-pins + her-store re-seed at closeout | open |
| 13 | Closeout ritual: records · canonical deltas as ruled · MobileSoul parity notes (C2 mobile shape; PL-11's tray face follows C1's ruled shape; a Note ▸ Versions phone-face note) · QUESTIONS for any PROVISIONAL · the running-order row closed · **annotate `notes/plans/whole-note-history-brief.md`** (its manual half is FULFILLED by V-family; its automated future = her floated auto-rotating versions, feeding the same listing) · **🔴 HER INSTRUCTION (eighth sitting, verbatim-faithful): AT CLOSEOUT — AND ONLY AT CLOSEOUT, "not earlier in the process, so I don't burn tokens on every message by loading it first" — read `notes/MobileSoul.md` and UPDATE the mobile round's BATCH 6 plans** (the per-note tray · deleted takes/History past · archive doors · the lineage door · the guide's deletion chapter) **to the design this round built** — the tray panel + leaving section, the Block History pane, takes-never-global, the five-places map — so mobile inherits the ruled design and never builds the mid-design (*"It's really good we got such a strong design done before a mid design had propagated to mobile"*) | open |
| 14 | **F1 — ARCHIVE RIDES BESIDE DELETE AT EVERY BLOCK DOOR** (her second morning report, 2026-08-24 — later softened: *"no, I see archive there too"*, so this is a VERIFICATION pass, not a rescue). The menu BAR's Block menu pairs them adjacently (13j's letter — verified in `EditorCommands.swift`); the pass confirms every OTHER door that offers a block Delete without the Archive twin (context/row menus — enumerate via the registry, the door-set is checkable). Same pass verifies the TAKE-card menus: Write's panel ⋯ carries Archive · Label · Lock · Delete (verified) — Takes mode's card grammar must match. **Context for the builder: the 13l walk's P-6 sentence ("the only door that deletes a take is inside the archived strip") is OVERSTATED — active take cards carry Delete; do not build against P-6's wording.** Her open musing, verbatim, for the round's checkpoint — *"I don't even know if we need take archiving if I'm not seeing it right now?"* — with the architect's recommendation recorded: KEEP the capability (her own morning argument — archive is forever-valuable and distinct from the clock — applies to takes exactly; the model's I10-rescue and pool-copy semantics also mint archived states), FIX the doors; retiring it is hers to rule if the fixed doors still don't earn it | open |
| 15 | **F2 — RESOLVED BY HER OWN SECOND LOOK, folded into 17:** she FOUND the deleted take in the block's History past region (*"I actually do see the deleted take in history"*) — not a data bug; a DOOR-PLACEMENT problem (*"it's unclear that history is under Note, that makes it seem like the Note's history"*). No Trash-side trace owed (takes leave the Trash by D1-revised anyway). Row 17 is the fix | **resolved → 17** |
| 16 | **G1 — THE WHOLE-NOTE VERSIONS DOOR (her ruling: "yes, in this round").** Her floated shape, adopted: *"an easy door would be to make a copy of the note, archive it, and then let you look through the archived copies made at points in time - not automated, but an easy door for people who want to save the whole note as it is."* **COMPOSE, don't build:** "Save a copy of this note as it is" = `duplicateAsVersion` (exists; mints the `version_of` edge) + note archive (exists) → a **"Versions of this note"** listing (dated, openable, restorable-by-copy) driven by the `version_of` lineage — one query, zero schema, zero new concepts. The copies also appear under the Archived-notes surface (B2) as ordinary archived notes. **`notes/plans/whole-note-history-brief.md` is the AUTOMATED future that later fills this same listing — read it so the manual door's shape doesn't foreclose it.** This is the round's headline: the Google-Docs answer ("my whole note at this point in time"), which her holistic worry named as the one thing people will conclude is missing | open |
| 17 | **G2 — THE ONE BLOCK HISTORY PANE (her second-sitting revision — supersedes the same morning's block-menu ruling, her words: "I know I just ruled that history should go in the block menu, but I think I'm changing my mind and it should be in the bottom chrome - my reasoning is that history is quite similar to commit, it's the natural pair to commit").** The door lives in the BOTTOM CHROME beside Commit (write a moment / see the moments — the bar becomes the block's time controls) and opens ONE cohesive side pane: **each live take's savepoint run (ALL takes, sectioned, the focused take's expanded — her ruling) · archived takes (Unarchive) · deleted takes (clocks + Put back) · came-from (the lineage section: a merge's ALL originals, each with a DIRECT restore button — her fourth-sitting ask: *"add as block again to the note (that's too wordy, you can reword the button, but the idea is that if you just merged something then realized you actually wanted a parent block, you should just be able to pull that parent block back into existence easily)"* — the op is `placeBlock`, the W-reversibility primitive; the round drafts the short wording)**. This pane ABSORBS three doors — J3's lineage peek, the History face's past region, the archived disclosure — and C2's separate lineage-view row FOLDS INTO IT (C2's mobile parity note survives unchanged). It is the round's biggest single build and the map's fifth place made real; her stated teaching intent binds the design: *"the 'Block history' pane will be a strong memory and the expectations are clear"* | open |
| 18 | **G3 — THE "UNPLACED" WORDING FOLD (presentation YES, semantics NO — her fold question answered).** Her words: *"why do we have unplaced as separate from archived? should we fold those two concepts in?"* The SEMANTIC fold is declined with the reason recorded: a preserved original rides its FAMILY's purge clock (her own 13j round-8b ruling — "goes with its deleted blocks") while archived means NEVER purged; folding them breaks one promise or the other. The PRESENTATION folds completely: a preserved original reads as *"set aside automatically by the merge — kept until its family goes"*; the word **"unplaced" must never reach a user's eyes** (debug vocabulary only — sweep every surface and receipt for it) | **done** `47c0cb7` — exactly two user-facing sentences said it; both reworded, and `goesWithItsFamily` folded to her sense. Queries keep their names. |
| 19 | **G4 — A NEW TUTORIAL CHAPTER teaches the map (her third-sitting expansion: "the next polish session should definitely add a new tutorial chapter about this… the user should be encouraged to get comfortable with each of the" places).** A NEW chapter (not just lines in the deletion chapter): the five places — *where you left it · Archive (notes, forever) · the Trash (what's leaving: notes·books·blocks, 30 days) · this note's Versions · this block's History* — each visited by the walk, **plus the take-savepoint story made explicit** (her: "making it clear where commit / that particular history by the take is, is also important" — the commit↔history bottom-chrome pairing is the teaching moment). Walk-asserted; D2's re-pin + her-store re-seed cover it | open |
| 20 | **G5 — THE TRAY'S HONEST "LEAVING" SECTION (her third-sitting ruling):** *"the tray of a note should have an honest trash section with everything being deleted, so it's never a surprise - and takes can be shown in that per note trash, albeit maybe not shown by default, so you can always see a list of what will be deleted."* The note's tray panel (C1) gains the complete per-note pre-purge audit: every clocked thing of THIS note — blocks, AND its takes under a collapsed-by-default disclosure — plus clocked originals when their family clock starts (the 13j 8b nets untouched: the visible move, its receipt, the Trash row). **Her fourth-sitting addition: the take rows HERE carry a Delete Now button** (*"to keep the capability"* — confirm-every-time binds it like every purge door). **This supersedes-IN-PART the 13j round-3 rider** ("inside the Trash only — never a door in a note or the editor, ever"): the evolved rule, hers — **purge doors live in TRASH SURFACES (the global Trash AND this note-level trash section), never in the writing flow** — recorded for the closeout's delta. **Originals while UNCLOCKED are lineage-only** (the Block History pane's came-from section — her earlier instinct, now consistent: the tray audits what is LEAVING; lineage holds what is KEPT) | open |
| 21 | **G6 — EMPTY TRASH PURGES EXACTLY WHAT IT ROWS (her ruling, and it SUPERSEDES 13j round-8's "everything, always" — a canon change, hers, recorded for the closeout's delta):** *"should we make 'empty trash' not delete takes by default? … a deleted take on a living block might be the one item a user does want to keep. I think that delete everything, including takes not displayed here, should be an alternative button if it even exists."* Built shape: Empty Trash takes notes · books · blocks + their families (a rowed block's own takes go with it — family-complete, honest, all rowed); **individually-deleted takes on LIVING blocks are untouched by the door** and expire on their own 30-day janitor clock only. **The honesty caveat the copy must carry: sparing from Empty Trash is NOT keeping — the clock still runs; restoring the take is the keep road.** The "delete absolutely everything" alternative button is NOT built (her "if it even exists" lean; recorded — a future door at her word). Takes' Delete Now capability LIVES in the note-level trash (row 20 — her fourth-sitting placement; Block History still carries no purge door); the in-Trash-only rule evolves as row 20 records. Her confirmations, same sitting: NOT clock-exempt (*"i don't want it to be clock exempt"*), and the door-shows-what-it-takes principle stands (*"I just don't think a 'delete everything' button in the trash should delete items that aren't being shown"*) | **done** `47c0cb7` — `TrashScope.emptyTrashTakes` is the one rule; the confirm totals what it takes and carries her sparing-is-not-keeping caveat; two shipped pins strengthened in place. |
| 22 | **G7 — TRASH BLOCK ROWS GROUP UNDER THEIR NOTE (the architect's proposal at her "will it be a bunch of blocks in the trash?" — PROVISIONAL, hers to unwind):** the global Trash's block rows gather under a small note-name header (the note itself only rows if IT is deleted), so a note with many deleted blocks reads as one group, not clutter. Composes with A3's naming; presentation only. **EXTENDED at her tenth-sitting ruling — the round's LAST refinement:** when deleting a live block strands its preserved ANCESTORS onto the family clock, **the Trash shows those ancestors NESTED UNDER the just-deleted block's row** — her words: *"those ancestors [go] under the live block that was most recently deleted - so if you had 30 ancestors on one live block's history and you delete that one live block, going to trash shows you what you just deleted rather than suddenly being overwhelmed by 31 random items … a more visible UI for 'your ancestors die with you' (lol)"*. The 8b nets (the move, its receipt) unchanged — this is their FACE | **done** `47c0cb7` — `TrashGrouping` (shared, pure): note headers, the deleted note heading its own group, groups-of-one flattened, and ancestors nested under the deletion that stranded them via a new query-supplied `anchorBlockID`. |
| 23 | **THE VERSIONS FAMILY (the V-rulings built):** the ⌘⇧S Save-a-Version door (chord verified free) · the Note ▸ Versions listing (dated, derived display, no title mutation) · copies born ARCHIVED + SEALED in one transaction · RESTORE identity-preserving (saves-now-first; outgoing blocks on the Delete Now road) · PROMOTE (unarchive+unseal → first-class) · versions RIDE the note's deletion (one confirm line, no dialog) · deleted single versions → Trash rows grouped under their note (RATIFIED) · the search-scope exclusions (main = live; Archived = non-version; versions in-context only — handed to 13o) | open |
| 24 | **V3's MUST-PIN:** version copies of journal notes never trip the bridge's duplicate-day pause — verified whichever way the machinery composes, pinned either way | open |
| 25 | Found-item 2: the archive-a-note door verified/ensured (one clear door, receipt naming the Archived surface) — rides B1's registry pass | **done** `47c0cb7` — the door existed in two row menus, undeclared and SILENT; now `.archiveNote` is declared, both renderers read its verb, and `LibraryViewModel` gained a receipt slot that names Archived and its absence of a clock |
| 26 | The tutorial chapter (row 19) teaches the VERSIONS story too: ⌘S vs ⌘⇧S — this take's moment vs this note's moment — the grain pairing as the lesson | open |
| 28 | **THE Aa BOTTOM-CHROME CONDENSATION (her kickoff addition, 2026-08-24 — verbatim in the kickoff record; SCOPE RULED at the kickoff sitting via the question tool): FORMATTING ONLY BEHIND Aa.** The `FormatBar` cluster + the newlines chip condense into one Aa button; clicking Aa slides the formatting row out (the phone's Aa expanding-row idiom, now on the Mac — a reverse-parity face like dark mode). Block ▾ · Takes · commit ⌘S · **History (row 17's new door)** · note ▾ · comments · counts · ? all stay visible at rest — the "bar becomes the block's time controls" reading survives by construction. Both bars (`CommitBar` + `TakesBottomBar`) take the same treatment; registry discipline P-1 (doors move, declarations unchanged — the R6-2/13g slide-out precedent is exactly this class); expansion state is session UI state | open |
| 30 | **ANCESTORS COLLAPSIBLE (her mid-round refinement on the ratified G7):** the nested-ancestors run under a just-deleted block's Trash row gains a dropdown-arrow disclosure — expanded by default, collapsible at will. Builds in batch 5 (already in the grouping for version rows) | open |
| 29 | **THE ERROR VOICE TOKEN (her mid-round ruling: "Add it this round"):** one named error/danger slot per voice in the shared token vocabulary; refusal/error surfaces adopt it through the voice (no literal reds return); both platforms share the file; hues revisable at 13s, dark mode (13u) inherits the slot. Builds in batch 4 | open |
| 27 | **THE TWO-EXITS LESSON (her eleventh-sitting mandate — "I deleted a paragraph, is it in deleted or in lineage? and lineage of what block" must be legible):** the chapter teaches **"Deletion goes to the Trash; transformation goes to lineage"** — a block you DELETED is on the clock, Put back real; a block that BECAME something else (merged, divided) lives in the new block's History came-from, one button back. Taught by DOING (her idea, adopted: the lesson walks the user through deleting a whole block, then making an edit that merges two — and finding each in its exit). Covers TODAY's truth incl. the shipped merge-then-edit; **the fanned cross-block matrix is 13u's** (its sitting + its own lesson update — the split is recorded there). The merge's own silence stays HER declined P-2 — the tutorial carries the teaching, not a per-merge message | open |


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
first-class note (a fork, her "work with it" road). **Step 2's block mechanics — RULED (author, eighth sitting):**
*"since the whole note is being saved as a version at that moment
right before restore, it's fine to just instantly hard delete those
remaining blocks - … there's no loss risk, and it doesn't really
make that much sense to not hard delete those blocks."* **The
S2-safe implementation of her ruling, stated so nobody writes a raw
row DELETE and breaks sync:** the outgoing blocks take the DELETE
NOW road in the restore's own transaction — tombstone + purge
intent per family — which is exactly "instant hard delete" as the
system means it: **gone from every surface immediately** (the
intent's read-side fence already hides intented rows from the Trash,
the tray, everything), physically removed on the janitor's ordinary
horizon (effectively at once on a single-device account). Zero new
machinery; the purge memo's honest unreachable-until-swept sentence
covers the interval as it covers every Delete Now.

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

**V9 — The one-home completeness sweep (her closing question,
answered YES with two threads tied):** every grain now has exactly
one findable home — takes → Block History · blocks → the note's
tray (+ the Trash while leaving) · originals → lineage until clocked
· notes → Library/Archive/Trash · a note's moments → Versions ·
what's-leaving of a note → the tray's leaving section. The two
threads tied at this sweep: **BOOKS never archive by schema fact**
(`reading` has no `archived_at` — a book's set-aside is FINISH, its
end is Delete; consistent, and the Archive surface being notes-only
already said so — **her ninth-sitting note, recorded:** *"when I do my
future sitting on books I might add the ability to archive them but
I'll handle that later if I do … if I do change it, the schema would
change, but that's a later issue that i'm not handling soon"*), and the **whole-note-history brief** is annotated
at closeout (row 13) as fulfilled-in-manual by this design.

## THE LIFECYCLE TABLE (her ninth-sitting deliverable — the post-round truth, grain-ordered; EVERY row is verified and marked *completed* at the round's close; two found-items beneath it)

*Scope note: placement moves (reorder, move-to-scraps, pool-drag) are
ordinary reversible editing, not past-creating — excluded by design.*

| # | Grain | Action | Where you act (doors) | Where the result lives | The result's capabilities | Status |
|---|---|---|---|---|---|---|
| T1 | take | Commit (savepoint) | ⌘S in the bottom chrome + the six quiet occasions | this take's savepoint run in **Block History** | restore-to-buffer (append-only; ⌘S ones never pruned) | pending |
| T2 | take | Branch / new blank take | take card + growth doors | the fan, live | full editing; choosable | pending |
| T3 | take | Choose ✓ | take card / board | the pointer (the note shows it everywhere) | re-choose anytime | pending |
| T4 | take | Label · Lock | take ⋯ | on the take | unlock; edit-by-branch while locked | pending |
| T5 | take | Archive | take ⋯ (Write panel + Takes mode, uniform per row 14) | **Block History → archived takes** — never global | Unarchive; Delete | pending |
| T6 | take | Delete | take ⋯ + the archived row's Delete | **Block History → deleted takes** (clock shown) + the note-level trash's collapsed takes disclosure (the note-scoped AUDIT lens, row 20) — **never the global Trash** | Put back (status-aware receipt); **Delete Now** (note-level trash only); expires at 30 days (Empty Trash never touches it) | pending |
| B1 | block | Archive | Block menu + every door that offers Delete (row 14) | **the note's tray only** — forever, no clock, never global | Put back (returns where it stood) | pending |
| B2 | block | Delete | Block menu · ⋯/row menus · ⌘-click multi · editor gestures | the note's tray (leaving section) + **the global Trash, grouped under its note** (row 22) | Put back (where it was); Delete Now; its takes ride the family BOTH directions | pending |
| B3 | block | Divide (duplicating default / the ceremony) | editor gestures + doors | successors in place; **the preserved ORIGINAL → lineage only** (each successor's Block History came-from) | the original: ONE-BUTTON restore (`placeBlock`); joins tray-leaving + Trash when its family dies (8b nets); plain single-take divide releases NO original (in-place) | pending |
| B4 | block | Merge (carry-all default / pairing ceremony) | editor doors | merged block in place; **ALL N parents → lineage** (came-from, N-way) | per-parent restore button; family clock as B3 | pending |
| B5 | block | Extract | the selection gesture | new block adjacent; the source SURVIVES in place | ordinary blocks; the lineage edge shows derivation | pending |
| N1 | note | **Save a Version** | ⌘⇧S + its door | **Note ▸ Versions only** — born archived + SEALED; hidden from Library, Archive, and every global search | open/read; RESTORE; PROMOTE (→ a new first-class note); Delete (→ the Trash, grouped under its note — **RATIFIED, tenth sitting:** *"agree that deleting a single version from the listing should go into trash for 30 days"*) | pending |
| N2 | note | Restore a version | the Versions listing | **the note becomes its past** — same identity, books, memberships; the outgoing blocks take the Delete Now road (no Trash noise); a fresh version of "now" appears first | fully repeatable — restore the restore | pending |
| N3 | note | Archive | Library/note doors (**FOUND-ITEM 2:** the registry pass verifies a clear door exists) | **the Archived sidebar surface** + its own search | edit in place (it is a WORK); Unarchive → Library; Delete → Trash; **never rides any deletion** | pending |
| N4 | note | Delete | note ▾ · Library · ⌘-click multi | **the Trash**, 30 days — its blocks and takes as family, its VERSIONS riding with it | Put back (family + versions whole); Delete Now; Empty Trash takes it (it is rowed) | pending |
| N5 | note | Seal (complete) | note doors | in place, frozen (auto-commits first) | unseal; everything content-level refuses under it | pending |
| N6 | note | Duplicate as version (live fork) | the compare/version doors | **the Library, first-class** + the `version_of` link for Compare | everything; archived-later = a WORK, never version history | pending |
| K1 | book | Finish (lock) | shelf/book doors | the shelf, finished | unfinish; structure frozen while finished | pending |
| K2 | book | Delete | shelf/book doors | **the Trash** (book rows) | Put back (`restoreReading` — chapters + memberships revive); Delete Now; member notes are NOT deleted (membership is pointers) | pending |
| K3 | book | Archive | **— does not exist** (schema fact; a book's set-aside IS Finish) | — | her recorded future-maybe (V9): a books sitting may add it — schema change, deliberately later | standing fact |

**FOUND-ITEM 1 — RATIFIED (tenth sitting, her words above):** deleting ONE version from the listing. Versions
hide from global surfaces *while archived-alive* — but a DELETED
version is ON THE CLOCK, and the Trash is the deadline surface that
shows what's leaving, whatever it was. So: **a deleted version rows in
the Trash, grouped under its note, honestly labeled; Put back returns
it to the Versions listing.** (The instant-hard-delete alternative was
weighed and declined by derivation: a version's moment is
UNRECAPTURABLE — unlike the restore's outgoing blocks, which had just
been saved — so the 30-day regret net applies.)

**FOUND-ITEM 2:** the archive-a-note door's home has never been
walked — the round's registry pass verifies one clear door exists
(the Library row menu is the natural candidate) and that its receipt
names the Archived surface.

## The architectural rules (the 13b constitution, P-1…P-9 — copied verbatim per `/architect-phase`, 2026-08-24 kickoff; the skill file's application notes bind beside them)

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

*(Note on the constitution's phase-specific names — D3/D4, Stage 0/1,
`TakesViewModel` — they are the rules' provenance and worked examples,
kept as written per the skill file; the rules themselves are general
and binding here.)*

## RUN RECORD

### Kickoff (2026-08-24) — the opening sitting, author-attended

Orchestrator: Fable under `/architect-phase`, at her invocation naming
this file. Mandatory reading done IN FULL before anything else:
CLAUDE.md + the canon it loads; THIS file top to bottom (the 27 ledger
rows — the kickoff message's "1–26" predates row 27's eleventh-sitting
addition; supersessions honored as marked); the 13l plan's Act 7 WALK
RECORD + Act 2 record; the 13j Environment traps (bind verbatim by
reference — `notes/plans/phase-13j-deletion-and-trash.md`, "Environment
traps"); `notes/handoffs/phase-13l-handoff.md`;
`notes/plans/whole-note-history-brief.md`. Constitution copied in
verbatim (above).

**Environment facts at kickoff:** git clean at `9772dc0`
(main == origin/main); **no Variorum instance live at the check**
(`pgrep -fl 'Variorum.app/Contents/MacOS'` empty) — her app is
LIVE-daily this era, so the check re-runs before ANY install act;
baselines launched at kickoff (results recorded below when green).

**HER KICKOFF ADDITION (verbatim, the invocation message):** *"One
element to add - for more space on the bottom chrome, please condense
all the current options into an Aa style button that when clicked
expands into the full bar"* — recorded as **ledger row 28**. Both
bottom bars compose the same clusters (block ▾ · Takes/+take · commit
· note ▾ · comments · the 13k K7 `FormatBar` · counts · ?), so the
item applies to both; its SCOPE (what exactly condenses behind Aa,
and how it composes with row 17's History-beside-Commit placement)
was the sitting's question. **HER RULING (question tool, same
sitting): "Formatting only behind Aa"** — the option's letter: Aa
replaces just the formatting toolbar + newlines chip (the phone's
Aa expanding-row idiom); block ▾ / Takes / note ▾ / comments /
commit / History stay visible. Row 28 carries the built shape.

**The sitting's other kickoff facts:** cast CONFIRMED as her
invocation stated it — **Opus implementers · Fable cold reviews**
(her standing era preference, named in the kickoff message).
Numbering: the round stays unnumbered — "the post-13l polish
round"; the master plan's running-order row 4b already carries it
(she may assign a number at any time). **The C1 small call, made
within the mandate:** the ⌫ N badge STAYS as the glance signal and
clicking it opens the same side panel the new tray icon opens (a
rendered signal that also acts — P-2; two doors, one panel, zero
choreography drift), while the ICON beside scraps/reference is the
named, always-present door per her ruling.

**Baselines (the orchestrator's own runs, launched at kickoff):**
core **1373/143 PASSED** (35.3 s) · Mac full **1691/292 PASSED,
TEST SUCCEEDED** (223.8 s, zero reds; the spine's 8
`TutorialWalkTests` types green INSIDE the run by inclusion — the
13j kickoff precedent; batches quote it separately) · mobile
**486/78 PASSED, TEST SUCCEEDED** (83.7 s, the 2 recorded
`withKnownIssue`s only). **Both known flakes silent** in the Mac
run. ALL FOUR baselines reproduce the 13l finals exactly, verified
by the orchestrator's own runs.

**Build-fact verifications at kickoff:** **V5 — ⌘⇧S IS FREE**
(`grep`: the only `"s"` chord is ⌘S at `EditorCommands.swift:277`)
· the side-panel seam is `PostDetailView.InspectorPanel`
(`.references` / `.scraps` — C1's tray and G2's History pane extend
this enum) · **row 20's per-take Delete Now composes with ZERO
schema** (`Operations.requestPurge` already accepts `variant`-rooted
targets — 13j's shipped machinery).

### Mid-round sitting (2026-08-24, during batch 3's run) — her mobile ruling

**HER WORDS (verbatim):** *"the phone will also have archive and
delete separated and on mimicking the surfaces that the mac has
decided on, in some way that works for mobile (make a note that it
can have a design session and propose different designs to me with
html when the time comes)"*

**What this rules:** the phone ADOPTS this round's separation —
Archive and Trash as distinct surfaces, mimicking what the Mac
decides here, **in a shape that works for mobile** (not a literal
copy). The mobile shape is NOT designed in this round: it gets **its
own design session, which proposes different designs to her as HTML
mockups** — her explicit instruction, recorded for the closeout's
mobile batch-6 update (row 13) and the MobileSoul parity line. This
CONFIRMS batch 2's parity note (the phone's combined "Archived &
Deleted" surface is now known-interim by her word) and extends it:
the whole five-places design (Archive · Trash · tray/leaving · Block
History · Versions) reaches the phone through that design-session
road, not by silent inheritance.

**SECOND RULING, same sitting (the batch-1 PROVISIONAL put to her
via the question tool): "Add it this round" — the voice vocabulary
GAINS an error/danger token.** One named slot per voice (Terminal +
Study); refusal surfaces adopt it on both platforms; the exact hues
stay revisable at 13s's design review, and 13u's dark mode inherits
the slot. Recorded as **ledger row 29**, built in batch 4 (the
chrome hand).

**THIRD + FOURTH RULINGS, same sitting:**
- **Take archiving: KEEP — her words verbatim:** *"yeah we can keep
  archive takes, I think it's useful and I was unsure about it
  before we had resolved a lot of other design elements."* Row 14's
  open musing is RESOLVED — F1 is now purely the verification/parity
  pass; nothing retires. (The checkpoint no longer owes her this
  question.)
- **G7's grouping shape RATIFIED** (*"the trash grouping shape
  works"*) **with one refinement, hers:** *"I think the ancestors
  should be collapsible with a dropdown arrow style toggle or
  something like that optionally (not collapsed by default)"* —
  the nested-ancestors run under a just-deleted block gets a
  disclosure toggle, **expanded by default**, collapsible at will.
  Recorded as **ledger row 30**, built in batch 5 (which is already
  in the Trash grouping for deleted-version rows).

### The batch plan (the architect's, within the mandate — acts may merge at dispatch; the ledger is the truth)

Cast per batch: a FRESH Opus implementer session, briefed ONLY by
this file's named sections; ONE end-of-round Fable cold-review
ladder over the combined diff (the 13k precedent), then closeout.
Every batch: the standing loop (build → red-on-old pins for
bug-class fixes, walk-driven pins for door moves → the spine green
by TYPE name → full suites with counts quoted; mobile when
`Shared/`/`Sources/` is touched). The 13j Environment traps bind
verbatim in every brief.

| batch | scope (ledger rows) | order rationale |
|---|---|---|
| **1 — the small fixes** | 1 (A1) · 2 (A2) · 4 (A4) · 5 (A5) · 6 (A6) — every one with its traced mechanism already in the 13l Act 7 walk record (P-4, P-5a/b, P-8, P-9). A7 stays DECLINED — nothing built; its one tutorial sentence lands in batch 6. *(Dispatch note: rows 3, 7, 25 moved to batch 2 — A3's row-naming IS G7's grouping structurally, and B1's Trash icon lands with B2's split so the icon never fronts a combined surface.)* | independent; smallest; retires the sloppiness class first |
| **2 — the IA pass + the Trash reshaped** | 7 (B1: Trash icon, Help-menu tutorial move, the ⋯ dissolves) · 8 (B2 notes-only Archived sidebar item) · 3 (A3 naming — folds into G7's headers; take-naming discipline rides batches 3–4's surfaces) · 11 (D1 takes leave the Trash → notes·books·blocks) · 18 (G3 "unplaced" wording sweep) · 21 (G6 Empty Trash purges exactly what it rows) · 22 (G7 grouping + tenth-sitting ancestor nesting) · 25 (found-item 2: the archive-a-note door + receipt naming the new surface) | the global surfaces' new truth, which batches 3–5 reference; may land as two commits (IA doors · the Trash reshape) |
| **3 — the tray goes to the side panel** | 9 (C1 icon + panel + originals separated; the badge call as recorded above) · 20 (G5 the leaving section; collapsed takes disclosure; per-take Delete Now — confirm-every-time) | extends the inspector seam; D1's takes-audit lens lands where D1 removed the global rows |
| **4 — the Block History pane + the bottom chrome** | 17 (G2 — the round's biggest single build; absorbs J3's peek, the History face's past region, the archived disclosure; came-from with per-original one-button `placeBlock` restore, wording drafted in-batch) · 10 (C2 folds in; its mobile parity note survives to closeout) · 14 (F1 verification pass + take-card menu parity) · 28 (the Aa condensation — same two bar files as G2's door) | needs 3's panel seam; the bar work lands in one hand |
| **5 — the Versions family** | 16 (G1) · 23 (the full V-family per V1–V8: ⌘⇧S door · the listing · born archived+SEALED one transaction · identity-preserving restore, outgoing blocks on the Delete Now road · PROMOTE · versions ride deletion, one confirm line · deleted versions → Trash rows grouped · search-scope exclusions recorded for 13o) · 24 (V3's bridge MUST-PIN) | after 2 (the Trash grouping its deleted-version rows join) |
| **6 — the tutorial** | 12 (D2 lesson edits + spine re-pins) · 19 (G4 the five-places chapter) · 26 (⌘S vs ⌘⇧S) · 27 (the two-exits lesson, taught by doing) — plus A7's one merge sentence in the deletion chapter | last: it teaches only built doors; P-6 makes it the acceptance spine |
| **ladder + closeout** | ONE Fable cold ladder (combined diff, `notes/REVIEW_PROMPT.md` verbatim) → fixes → round 2 → row 13's closeout: records · canonical deltas as ruled (B2's R44 delta; G5's evolved purge-door rule; G6's Empty-Trash supersession) · the LIFECYCLE TABLE walked, every row flipped `completed` · MobileSoul + mobile batch-6 update AT CLOSEOUT ONLY (her token instruction) · the whole-note-history-brief annotation · her-store field-guide re-seed + `/Applications` refresh behind the A1 rail (instance check first) | the standing ritual |

### BATCH 1 — THE SMALL FIXES: the brief (fresh Opus session)

**Read in full first:** `CLAUDE.md` + the canon it loads · THIS FILE
top to bottom (her rulings are the letter; the lifecycle table is the
acceptance map) · the 13j plan's **Environment traps** (binding
verbatim — `notes/plans/phase-13j-deletion-and-trash.md`) · the 13l
plan's **ACT 7 — WALK RECORD** (`notes/plans/phase-13l-data-safety-floor.md`,
§"ACT 7") — **every item below has its traced mechanism there
already**; verify each trace against the tree before fixing (never
trust, always verify).

**Scope — ledger rows 1 · 2 · 4 · 5 · 6, nothing else.** Rows 3/7/25
are batch 2's (see the dispatch note in the batch table). Do NOT
touch: Empty Trash's purge SCOPE (G6, batch 2) · the tray's door
placement (C1, batch 3) · anything in the takes/editor seam.

- **Row 1 (A1, walk P-4):** a successful Put back from a revealed row
  prints the stale *"The block you asked to see isn't in this note's
  tray."* — `revealMissing` is an arrival-time explanation evaluated
  live. Fix per the walk's candidates (latch at load, or clear
  `revealBlockID` once its row is acted on) AND show a success
  receipt per her ruling (*"it should show a success message if
  anything"*). Bug-class → red-on-old pin.
- **Row 2 (A2, walk P-5b):** with a kind filter on, an empty result
  still says **"The Trash is empty"**, and **Empty Trash…**
  disappears because `!model.trash.isEmpty` reads the FILTERED list.
  Build her chip (*"a filters applied chip or something of the
  sort"*) + honest filtered-empty wording; the Empty Trash button's
  visibility reads the UNFILTERED truth. **Scope fence: the button's
  visibility read only — what Empty Trash TAKES is G6, batch 2's.**
  Bug-class (the visibility read) → red-on-old pin.
- **Row 4 (A4, walk P-8 — all three sub-items; her "I'd fix whatever
  this is"):** (a) a deleted scrap's receipt names *"This Note's Tray
  — the ⌫ door in the note's bar"* on a surface that has neither —
  name the REAL road (the Trash, where scraps row "from scraps");
  the copy lives in the shared homes (`RecoveryCopy` — the phone
  inherits; mobile gates apply). (b) the Snippets list rows' context
  menu offers only "Tags…" — add the delete door. (c) the block
  context menu there omits "Delete Block" while a note's carries it —
  parity. New doors take registry discipline (P-1); **the #77 fence
  is untouchable: no door may tombstone the POOL** (the act-level
  fence stays the belt; walk-driven pins for the new doors).
- **Row 5 (A5, walk P-9):** the note-delete confirm holds two nouns
  for one road (*"…goes to the **Trash**… put it back from
  **Archived & Deleted**…"*). Rewrite to ONE noun — the Trash —
  in `Shared/RecoveryCopy.swift` (batch 2 renames the surface to
  match; "the Trash" is forward-compatible). Copy-assertion pins
  update in place (strengthening, not weakening).
- **Row 6 (A6, walk P-5a):** the tray's status slot paints
  `.foregroundStyle(.red)` for every message class — a success reads
  as an error — and it is a literal colour in a themed surface. Fix
  per the Trash surface's own precedent one file over (error red,
  receipt secondary), through voice tokens. Red-on-old pin (the
  success message's style class).

**Discipline (the standing loop):** zero schema · zero
`Sources/VariorumCore/Sync/` · red-on-old verified by behavioural
revert for bug-class fixes · the spine green BY TYPE NAME
(`TutorialWalkTests`) · full four gates with counts quoted (mobile
runs — `Shared/RecoveryCopy.swift` is touched) · commits staged by
explicit path, conventional trailer, NEVER push · instance check
before anything build-adjacent (her app is live-daily). **Append
your record as "### BATCH 1 — RECORD" below this brief** (per-row:
mechanism verified · fix · pin · red-on-old evidence), flip the
ledger rows, and STOP — the orchestrator reviews before batch 2.

### BATCH 1 — RECORD (Opus implementer, 2026-08-24)

**Commit `85e1a54`**, staged by explicit path, not pushed. Tree clean at
start (`22a3e43`) and at finish. **No Variorum instance at the instance
check** (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty), re-checked
before the Mac suite; no Release/install act was owed or taken.

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1373 tests / 143 suites PASSED** (35.4 s) | 1373/143 ✔ exact |
| Mac full (`-project`, `platform=macOS`) | **1699 / 292 PASSED — TEST SUCCEEDED** (229.2 s, zero reds) | 1691/292 → **+8**, my 8 new pins; suite count unmoved |
| Mac spine (8 `TutorialWalkTests` types, suite-level `-only-testing`) | **63 / 8 PASSED — TEST SUCCEEDED** (23.9 s) | 63/8 ✔ exact |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (85.2 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**Both known flakes were silent** in the full Mac run — the Phase-12
latency pin (`EditorWindowSmokeTests/rewriteStrategyLatencies`) and
`CanvasDragTrackingTests`. Neither needed isolating. **Zero schema, zero
`Sources/VariorumCore/Sync/`, zero `Sources/` lines of any kind** — the
whole batch is app-target + `Shared/` + tests.

---

#### Row 1 (A1, walk P-4) — the Put back that apologised

**Mechanism, verified myself in the tree** (not taken from the record):
`TrayViewModel.revealMissing` was a COMPUTED property over the live
listings (`TrayPanel.swift:230-236` pre-fix). The observation re-emits
after any act, so a successful Put back of the revealed row removed it
from `deleted`/`originals` and `revealMissing` flipped to true **in the
same breath as the receipt** — the sentence is an arrival-time
explanation being asked of a listing she had just changed herself.

**Fix:** `revealMissing` is a stored property decided ONCE, inside
`adopt`, on the first loaded snapshot (`if !loaded, let revealBlockID`).
Every later snapshot leaves it alone. Her ruling's second half — *"it
should show a success message if anything"* — is served by the receipt
that was always produced (`RecoveryCopy.landingReceipt`) and by row 6,
which stops painting it as an error.

**Pin:** `NoteTrayTests.aRevealThatSucceedsIsNotFollowedByTheNotFoundLine`
— arrive with the row present, then adopt the listing a successful Put
back produces.
**RED ON OLD** (behavioural revert: restore the computed property and
drop the `adopt` latch):
`✘ Expectation failed: !((model → TrayViewModel).revealMissing → true → true)`
at `NoteTrayTests.swift:461`.

**Files:** `Features/Tray/TrayPanel.swift`.

---

#### Row 2 (A2, walk P-5b) — the filtered Trash

**Mechanism, verified:** the kind filter is applied IN SQL
(`observeTrash(kinds:)`), so `model.trash` is the FILTERED listing, and
BOTH reads on the surface asked it — `if model.trash.isEmpty { Text("The
Trash is empty.") }` (`RecoveryView.swift:521` pre-fix) and
`if !model.trash.isEmpty { Button(emptyTrashVerb) }` (`:577` pre-fix).
Consequence exactly as walked: **Notes** selected with a block in the
Trash gave "The Trash is empty" AND hid a door that acts on the whole
Trash.

**Fix, three parts:**
1. `RecoveryViewModel.trashIsEmptyUnfiltered`, fed by a **second,
   deliberately tiny observation** (`startTrashTotal` — all kinds,
   `limit: 1`) that is **never restarted by the filter**. It is not a
   read riding the first observation on purpose: the filtered
   observation only re-emits when the FILTERED set changes, so anything
   deleted or purged in another kind would have left such a read stale —
   the same bug one layer down. Its error path errs OPEN (never hide the
   door; the ask-time read is the authority on what Empty Trash takes
   and says "nothing to delete" honestly).
2. `RecoveryCopy.trashEmptyLine(filteredBy:holdsOtherKinds:)` — three
   readings, and only one of them is "The Trash is empty."
3. Her chip: `RecoveryCopy.filterAppliedChip` renders whenever the
   listing is narrowed (not only when narrowed-and-empty), and clicking
   it clears the filter, so the signal is also the way out (P-2).
   The Empty Trash visibility read is named
   (`RecoveryView.showsEmptyTrashDoor`) so a pin drives the DECISION.

**Scope fence honoured:** what Empty Trash TAKES is untouched — G6,
batch 2's. This changes only whether the door is on screen.

**Pins:** `TrashSurfaceTests.aKindFilterWithNoMatchesNeitherEmptiesTheTrashNorHidesItsDoor`
(drives BOTH real observations against a real deleted block) +
`anEmptyTrashStillSaysSoWithOrWithoutAFilter` (the over-correction
guard — an empty Trash still says so, filtered or not).
**RED ON OLD** (behavioural revert: `trashIsEmptyUnfiltered =
trash.isEmpty`, `showsEmptyTrashDoor` → `!model.trash.isEmpty`, the
literal empty line) — **5 issues**, reading back the whole defect:
`!(model.trashIsEmptyUnfiltered → true)` · `(line → "The Trash is
empty.") != "The Trash is empty."` · the two `contains` on that line ·
`RecoveryView.showsEmptyTrashDoor(model)`.

**Files:** `Features/Library/RecoveryView.swift`, `Shared/RecoveryCopy.swift`.

---

#### Row 4 (A4, walk P-8) — all three sub-items

**(a) the scrap's receipt.** *Mechanism, verified:* the scraps editor is
`PoolDetailView` → **`EditorView` over the pool container**
(`CanvasView.swift:916`), so `EditorSurfaceController`'s delete doors
run there and spoke `BlockSelectionCopy.deletedNote`, which hard-coded
`"then in This Note's Tray — the ⌫ door in the note's bar."` I checked
the walk's screen `50-crop.png` and reproduced the sentence from the
code. Two facts settled the fix: the ⌫ badge is a note-bar face the
scraps pane has no seam for, and a deleted scrap **really does row in
the Trash**, labelled "from scraps" with an **Open scraps** door (13l
§8b, walked CLEAN). *Fix:* `deletedNote(_:home:)`, `.post` defaulted so
every shipped caller and pin rides byte-unmodified; the two
`EditorSurfaceController` delete sites read `model.header?.kind`
(observed — free).

**(b) the Snippets row's delete door.** *Mechanism, verified:*
`BlocksAreaView.scrapRow`'s `.contextMenu` held exactly one row,
`Button("Tags…")` (`:142` pre-fix) — matching walk screen
`45-crop.png`. *Fix:* `PoolViewModel.deleteScrap` (ordinary
`deleteBlock`; receipt from the one home; refusal through
`DeletionRefusal.words`), a registry-declared **`.deleteScrap`**
capability, and the row. **Registry discipline (P-1):** its own act
rather than a `.surface` door on `.deleteBlock`, for `.tagBlock`'s exact
reason — `.deleteBlock`'s availability is `takeFamily` (it needs an open
note) while a scrap row is POINTED AT DIRECTLY, so `availability:
always`. It joins `.tagBlock` in the R118 exemption set with the reason
written out. **The #77 fence rides by construction:** the act deletes a
BLOCK and has no road to `deleteContainer`. `BlocksAreaView` also gained
a status line — it rendered the MODEL's messages nowhere at all before —
with the row-6 receipt/refusal split and a `lineLimit` beside its
`fixedSize` (the b6dae25 class, P-8).

**(c) the block context menu's missing delete.** *Mechanism, verified —
and the walk's wording needs one correction for the record:* P-8 says
*"the block context menu there omits 'Delete Block' while a note's
carries it"*, which reads as a scraps-vs-note difference. It is not:
`contextMenuItems()` is ONE shared method and **a NOTE's context menu
omitted it too** — confirmed against walk screens `16-block-context.png`
(a note) and `47-crop.png` (the scraps editor), which show the same nine
rows. The real parity gap is **context menu vs the block ▾ bar menu**
(`49-crop.png` shows the bar menu's "− Delete this block"), and sharper
still: the context menu **carried `Archive Block` with no delete beside
it** — the two verbs that exist to be told apart, one of them missing
from the door you reach by right-clicking the block itself.
`.archiveBlock`'s registry doors were `[.menuBar, .contextMenu]`;
`.deleteBlock`'s were `[.menuBar, .bottomBar, .palette]`. *Fix:*
`.contextMenu` joins `.deleteBlock`'s doors and `.deleteBlock` joins
`EditorViewModel.contextMenuCapabilities`; the caret row renders **only
when no blocks are picked** — because `deleteVerb(picked: 1)` is
literally the string "Delete Block", so rendering both would put two
identically-worded rows on one menu aiming at two different targets.

**Pins:** `TrashSurfaceTests.deletingAScrapNamesTheTrashAndNotTheNotesTrayDoor`
(a) · `.theSnippetsRowDeletesItsScrapAndNeverItsPool` (b — drives the
act; asserts the block tombstoned, **the pool still live** (#77), and
the row present in the Trash) · `.theBlockContextMenuCarriesDeleteBesideArchive`
(c — both verbs present, and never two delete rows with or without a
pick).
**RED ON OLD** (reverts: drop the `.pool` arm; no-op the door; drop the
`picked.isEmpty` arm) — **8 issues**, e.g.
`(scrap → "Block deleted — ⌥⌘Z puts it back, then in This Note's Tray —
the ⌫ door in the note's bar.").contains("Trash")` ·
`Expectation failed: blockGone` ·
`(titles → [… "Archive Block"]).contains(verb → "Delete Block")`.

**Files:** `Registry/OpsRefusalCopy.swift`, `Registry/Capability.swift`,
`Registry/CapabilityRegistry.swift`,
`Features/Editor/EditorSurfaceController.swift`,
`Features/Editor/EditorViewModel.swift`,
`Features/Pool/PoolSection.swift`, `Features/Pool/BlocksAreaView.swift`,
`VariorumTests/CapabilityRegistryTests.swift` (the exemption line).

---

#### Row 5 (A5, walk P-9) — one road, one noun

**Mechanism, verified:** `RecoveryCopy.moveToTrashDetail` read *"The
note goes to the **Trash** for 30 days. You can put it back from
**Archived & Deleted** until then."* Both names are real, so nothing was
false — the sentence asks the reader to hold two nouns for one road, in
the confirm she reads while deciding whether to delete her writing.

**Fix:** the place is named once; the second clause points back at it
("from there"). Same for `deleteNotesConfirmDetail`. **"the Trash" is
the forward-compatible half deliberately** — batch 2's IA pass gives the
Trash its own icon and retires the ⋯ menu "Archived & Deleted" labels.
**Also fixed, same shape, one line:** `MobileShelfFaces.deleteBookConfirmDetail`,
a phone-local sibling carrying the identical two-noun ending — recorded
here rather than left, because leaving it is the drift class the shared
home exists to kill.

**Pin:** `NoteDeletionDoorsTests.theMoveToTrashConfirmsNameTheRoadExactlyOnce`
(the whole family — note, notes(5), block, book, take — so the shape
cannot return one kind at a time).
**Pin edited in place, STRENGTHENING:** `MobileDeletionTests.swift:99`
asserted the message ALSO contained `surfaceName`, i.e. it pinned the
defect; it now asserts the road is named once.
**RED ON OLD** (revert the two sentences): **5 issues**, each reading
back the two-noun sentence, e.g. `!((detail → "The note goes to the
Trash for 30 days. You can put it back from Archived & Deleted until
then.").contains("Archived & Deleted") → true)`.

**Files:** `Shared/RecoveryCopy.swift`,
`VariorumMobile/Features/Shell/MobileShelfFaces.swift`,
`VariorumMobileTests/MobileDeletionTests.swift`.

---

#### Row 6 (A6, walk P-5a) — a receipt is not a refusal

**Mechanism, verified:** `TrayPanel`'s status slot was
`Text(status).foregroundStyle(.red)` (`:455` pre-fix) over ONE
`statusMessage: String?` that receipts and refusals both wrote — so
*"Put back where it was."*, the whole point of the surface, read as an
error. The Trash surface one file over had already split them
(`lastError` red beside `receipt` secondary).

**Fix:** `TrayViewModel.Status` — `.receipt` / `.refusal`, **classed
where the message is produced**, never guessed by the view from the
text; `statusMessage` survives as a computed forwarder so every shipped
pin rides unmodified (the 3C parity pattern — and it did: zero edits to
the existing tray pins). Both colours are VOICE TOKENS
(`tokens.accent` / `tokens.muted`), which is the second half of the
defect the brief names — a literal colour in a themed surface.
`OriginPeek`'s `.red` literal went the same way (it already told the two
apart via `placed`; only the literal remained).

**One PROVISIONAL, recorded:** the app has **no error/danger voice
token** — `VoiceTokens` carries no alarm colour, and the two nearest
themed surfaces (`BlocksAreaView`, `ScrapsPanel`) already use
`tokens.accent` for their error slots, so that is the established themed
alarm voice and this follows it. Adding a real `alarm` token would touch
`Shared/Theme/VoiceTokens.swift` and every voice definition on both
platforms — a design call, not a small fix. Flagged for the orchestrator.

**Pin:** `NoteTrayTests.theTrayTellsAReceiptFromARefusal` (a landing
classes as a receipt; a sealed refusal classes as a refusal, in the same
slot; the forwarder still answers).
**RED ON OLD** (revert: the three put-back doors set `.refusal(…)` on
success — the pre-fix single red slot): **2 issues**,
`(model.status → .refusal("Put back where it was.")) == .receipt("Put
back where it was.")` and `(model.status?.isRefusal → true) == false`.

**Files:** `Features/Tray/TrayPanel.swift`, `Features/Tray/OriginPeek.swift`.

---

#### TWO SHIPPED PINS EDITED IN PLACE — both justified, both caught by the full run

Row 4(c) moved a door table, so two pins that asserted the OLD table
went red. Neither was weakened:

- **`StructuralGestureTests.contextMenuItemsFireAndSpeak`** asserted the
  menu's exact title list. `"Delete Block"` appended, with the comment
  the file's own convention wants — **and it is worth saying that this
  list is where the defect was visible all along**: nine expected values
  ending in `"Archive Block"`, with no delete anywhere.
- **`BlockManagementTests.theContextRowRendersOnlyWithAPickAndNamesTheCount`**
  asserted `deleteRows().isEmpty` with no selection. That is no longer
  the fact; what the test is actually about — and what it asserts now —
  is that there is **exactly one delete row, always**, and that a
  standing pick REPLACES the caret's row rather than adding to it.

---

#### OBSERVATIONS — nothing built, for the orchestrator

1. **The ARCHIVE receipt has row 4(a)'s exact defect and was deliberately
   left.** `BlockSelectionCopy.archivedNote` names *"This Note's Tray
   (the note menu)"* and the scraps editor reaches `archiveCaretBlock`
   through the same context menu. It is NOT the same fix, though: an
   archived scrap has no clock and never reaches the Trash, so its road
   really is the tray — reachable there via `note ▾ → This Note's Tray…`,
   which renders on a pool with no kind fence. The honest fix is the
   tray's NAMING on a non-note surface, and **batch 3 (C1) is moving that
   door entirely**, so fixing the sentence now would mean fixing it
   twice.
2. **The scraps editor's `note ▾` menu still says "This Note's Tray…" on
   a pool** — same class, same owner (C1).
3. **`TrayViewModel`'s generic catch still dumps `String(describing:)`**,
   including for `RecoveryRefusal` (a preserved original with no note) —
   the twin surface uses `DeletionRefusal.fallback`. I classed it
   `.refusal` but did not change the words: out of the named scope, and
   it is the A1-MINOR-2 class 13l Act 1 already fixed one file over.
4. **The phone's Trash has row 2's defect verbatim** —
   `MobileTrashView.swift:69` (`emptyTrashLine` on the filtered list) and
   `:138` (the Empty Trash button on the same). I put the brain in
   `RecoveryCopy` so the phone's adoption is one line, and did NOT touch
   the phone's face: a chip plus a second observation is a mobile batch,
   and mobile's round is paused. **A parity note for the closeout.**
5. **Sibling scrap surfaces not given the new delete door:**
   `ScrapsPanel`'s rows and the canvas cards carry `.tagBlock` with the
   same "Tags…"-only menu. The walk named the Snippets list; row 14's F1
   verification pass is the one that enumerates block-delete doors, so
   these belong to it.
6. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/` and `App/Variorum/Shared/` returns only two
   pre-existing doc comments (`NoteWindowView`, `QuickNoteView`).

### BATCH 2 — THE IA PASS + THE TRASH RESHAPED: the brief (fresh Opus session; dispatches after batch 1's record)

**Read in full first:** `CLAUDE.md` + canon · THIS FILE top to bottom
(the rulings are the letter; the LIFECYCLE TABLE is the acceptance
map — your rows are B2, K2, N3/N4's surface halves, T6's
never-global clause) · the 13j **Environment traps** (binding
verbatim) · the 13l plan's **ACT 7 — WALK RECORD** (context for A3's
naming and the Trash surfaces) · batch 1's record above (its
`RecoveryCopy` additions and `.deleteScrap` pattern are your
precedents).

**Scope — ledger rows 3 · 7 · 8 · 11 · 18 · 21 · 22 · 25.** May land
as two commits (the IA doors · the Trash reshape). Fences: zero
schema (EVERYTHING here is read-side over `archived_at`/existing
rows) · zero `Sources/VariorumCore/Sync/` (`Queries`/`Operations`
changes are fine) · G5/C1's tray panel is batch 3's · the Block
History pane is batch 4's · versions are batch 5's (but see row 8's
classifier note below — you build the EXCLUSION now).

- **Row 7 (B1, her words in §B):** the Library's upper-right ⋯ menu
  DISSOLVES — the Trash door becomes a **trash icon** in the Library
  masthead; "Open the Tutorial" moves to the **Help menu** (the
  shell's fire-and-DO act, unchanged). Registry P-1: doors move,
  declarations updated. The tutorial SPINE may assert the old door
  mechanically — re-pin the door path (mechanical only; lesson
  CONTENT re-teaching is batch 6's/D2).
- **Row 8 (B2, her words in §B):** **the Archived sidebar item —
  archived NOTES only.** A sidebar item beside the standing four
  (place it after Blocks — propose differently in-batch if the IA
  argues otherwise: implementer proposes, architect rules). The
  surface: archived, non-deleted, `kind='post'` notes, Library-shaped
  (cards/list + the CATALOG-level search scoped to it — her
  "search it separately"; body-text search stays 13o's).
  **The V1 classifier, built here as the exclusion:** version
  history = BORN ARCHIVED (`archived_at == created_at`, the
  same-clock birth fact) AND carrying a `version_of` edge to a live
  note — such rows NEVER list here (their home is Note ▸ Versions,
  batch 5). Build the query arm + pin now (no such rows exist yet —
  batch 5 mints them; your pin seeds one by hand). Unarchive →
  Library; Delete → the Trash (N3's row). The naming through shared
  copy homes. The recovery surface it leaves behind becomes **the
  Trash, plainly** — `RecoveryPath`'s label and every sentence that
  said "Archived & Deleted" follow (A5's one-noun confirm already
  says the Trash — keep them aligned). Mobile gates run (shared copy
  moves).
- **Row 11 (D1, her ruling in §D):** **takes leave the global
  Trash** — the deleted-take LISTING arm and its filter chip come
  out (the DATA and the clock are untouched; T6's homes are batch
  3's note-level audit + batch 4's Block History). The Trash lists
  **notes · books · blocks**. Record the known transient: until
  batches 3–4 land, deleted takes have no listing (mid-round state,
  in-round only).
- **Row 3 (A3) + row 22 (G7, incl. the tenth-sitting extension):**
  block rows **group under a small note-name header** (the note
  itself rows only if IT is deleted) — the grouping IS the naming;
  "Open note" renders only where the home note is alive, legible
  under named headers. **The ancestors clause:** when deleting a
  live block strands preserved ANCESTORS onto the family clock, the
  Trash shows those ancestors NESTED UNDER the just-deleted block's
  row (her words: *"going to trash shows you what you just deleted
  rather than suddenly being overwhelmed by 31 random items"*). The
  8b nets (the move, its receipt) byte-unchanged — this is their
  FACE.
- **Row 21 (G6, her ruling verbatim in the ledger):** **Empty Trash
  purges exactly what it rows** — notes · books · blocks + their
  families (a rowed block's own takes go with it); individually-
  deleted takes on LIVING blocks are untouched by the door and
  expire on their own 30-day clock. The confirm counts what it
  rows. **The honesty caveat in the copy:** sparing from Empty
  Trash is NOT keeping — the clock still runs; restoring is the
  keep road. NO "delete absolutely everything" button (her lean;
  recorded, unbuilt). This SUPERSEDES 13j round-8's
  everything-always — the canon delta is the CLOSEOUT's to write;
  you build and pin the new scope. Red-on-old: the old scope's pin
  flips — strengthen in place with the mechanism stated.
- **Row 25 (found-item 2):** verify ONE clear archive-a-note door
  exists (the Library row menu is the natural candidate — add it
  there if missing, registry-declared); its receipt names the
  Archived surface by its new name. N3's lifecycle row is your
  acceptance: Archive → the Archived surface; Unarchive → Library;
  Delete → Trash; never rides any deletion.
- **Row 18 (G3):** sweep **"unplaced"** from every user-facing
  surface, receipt, and menu label (debug vocabulary only — grep
  the app targets; `Queries.unplacedBlocks`/`unplacedOrigins` etc.
  KEEP their names, they are code). A preserved original reads as
  *set aside by the merge — kept until its family goes* (draft the
  final strings through the shared copy homes; her wording in the
  ledger row is the sense, yours is the sentence). The SEMANTIC
  fold is DECLINED (the ledger row records why) — presentation
  only.

**Discipline:** the standing loop — red-on-old by behavioural revert
for bug-class fixes, walk-driven pins for door moves (drive the real
surface — the 13l lesson) · spine green BY TYPE NAME · full four
gates with counts quoted (mobile runs — shared copy is touched) ·
instance check before build-adjacent acts · commits staged by
explicit path, conventional trailer, NEVER push. **Append "### BATCH
2 — RECORD" below this brief**, flip your ledger rows, and STOP.


### BATCH 2 — RECORD (Opus implementer, 2026-08-24)

**Commit `47c0cb7`**, staged by explicit path, not pushed. Tree clean at
start (`b2b1b96`) and at finish. **No Variorum instance at either instance
check** (`pgrep -fl 'Variorum.app/Contents/MacOS'` empty — before the first
`build-for-testing` and again before the full Mac run); no Release build, no
`/Applications` act.

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1376 tests / 143 suites PASSED** (35.1 s) | 1373/143 → **+3**, my three new core pins; suite count unmoved |
| Mac full (`-project`, `platform=macOS`) | **1717 / 293 PASSED — TEST SUCCEEDED** (226.0 s, zero reds) | 1699/292 → **+18 tests, +1 suite** (`IAAndTrashShapeTests`) |
| Mac spine (8 `TutorialWalkTests` types, suite-level `-only-testing`) | **63 / 8 PASSED — TEST SUCCEEDED** (22.4 s) | 63/8 ✔ exact |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (85.1 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**Both known flakes silent** in the full Mac run — the Phase-12 latency pin
(`EditorWindowSmokeTests/rewriteStrategyLatencies`) and
`CanvasDragTrackingTests`. Neither needed isolating; `CanvasDragTrackingTests`
stays at ONE recorded red for the era.

**Fences held:** ZERO schema (every change is read-side over `archived_at`,
`deleted_at` and the existing `edge` rows) · ZERO
`Sources/VariorumCore/Sync/` lines · the tray side panel untouched (batch 3)
· no Block History pane (batch 4) · **no version MINTING** — batch 5's, and
what landed here is only the Archived surface's EXCLUSION query and its
hand-seeded pin, exactly as the brief scoped it.

---

#### Row 7 (B1) — the ⋯ menu dissolves

**Mechanism, verified in the tree:** `LibraryCatalogView.header` held a
`Menu { … } label: { Image(systemName: "ellipsis.circle") }` with exactly two
rows — `Button(RecoveryPath.menuLabel) { onOpen(.recovery) }` and
`Button("Open the Tutorial") { onOpenTutorial() }`.

**The finding that changed the shape of the work:** the tutorial door was a
**DUPLICATE**, not a door needing a new home. `EditorCommands`'
`CommandGroup(after: .help)` has rendered `Button("Open the Tutorial")` since
13b Stage 2, and ⌘K's composition row has carried it as long. So her *"it
could be under help if anything"* was already true, and B1's tutorial half is
a REMOVAL: one door fewer for one act, nothing re-homed. Recorded rather than
quietly done, because "moved to Help" and "was already in Help" are different
claims about the build.

**Build:** the ⋯ is gone; the masthead renders a `trash` icon Button.
`LibraryCatalogView.onOpenTutorial` — the callback — is **removed**, and
`RootView` no longer passes one, so the compiler now keeps the record that the
door left. Registry (P-1): both are NAVIGATION, which lives in composition, not
the registry — `RootView.wirePaletteCommands`' own stated rule ("navigation
rows here in composition, ACT rows from the capability registry"), and the
palette's Go-to rows are its precedent. What IS declared: the door table.
`LibraryCatalogView.mastheadDoors` — the header `ForEach`es it, so it is the
render source, not a comment beside one (batch 1's `showsEmptyTrashDoor`
precedent, one step stronger).

**Pin:** `IAAndTrashShapeTests.theLibraryMastheadCarriesTheTrashIconAndNoTutorialDoor`.
**RED ON OLD:** the revert here is a COMPILE failure by construction — restoring
the `Menu` means deleting `mastheadDoors`, and the pin references it. Recorded
honestly as such rather than dressed as a runtime red; the runtime half that
does exist (the label reads from `RecoveryPath`) is asserted beside it.

**Files:** `Features/Library/LibraryCatalogView.swift`, `RootView.swift`.

---

#### Row 8 (B2) — Archived becomes its own room

**Mechanism, verified:** `RecoveryView` rendered `Section(archivedSection)` and
`Section(trashSection)` in ONE list under one name, `RecoveryPath.menuLabel =
"Archived & Deleted"` — a forever-list and a 30-day countdown on one screen,
with the difference left to her to hold. Her B2 direction splits them.

**Build:** `SidebarSelection.archived` joins the standing four (after Snippets
— the brief's default placement; **no counter-proposal, and the reason is
stated**: Shelf · Library · Pool · Snippets is R44's ruled order and this is an
addition to it, not a re-ranking of it). `ArchivedView` is a new surface —
archived NOTES only, header + its own name search (`ArchivedView.matches`, a
pure rule so a pin can drive it), rows carrying Open · Unarchive · Delete Note…
through the shared confirm host. `RecoveryView` keeps the Trash and loses the
archived section; `RecoveryViewModel` is UNTOUCHED in shape (both listings stay
on it, `ArchivedView` starts only `startArchived`), so all 13j/13l model pins
ride unmodified. `RecoveryPath.menuLabel` now forwards to
`RecoveryCopy.trashSection` ("Trash") and `RecoveryPath.archivedSurface` is the
new name; `RecoveryCopy.surfaceName` stays for the PHONE, whose surface still
holds both — **a parity note for the closeout, and the doc says so at the
constant**. Palette gains the Archived Go-to row beside the Trash's.

**The V1 classifier, built as the exclusion:** `Queries.archivedPosts` gains
`excludingVersionHistory: Bool = true` — born archived (`archived_at =
created_at`, one clock call) AND version-linked to a live, unarchived note,
read exactly the way `versionPeerPosts` reads the edge. **Default TRUE**
deliberately: it is the product truth wherever archived notes are listed, and a
caller wanting the raw column says so (the pin exercises both).

**Pins:** core
`TrashAndArchiveTests.versionHistoryNeverListsAmongTheArchivedNotes` (the
born-archived state hand-seeded, since batch 5 mints it) ·
`.aCopySheWorkedWithAndArchivedLaterIsAnArchivedNote` (the classifier's other
half — her sixth-sitting catch: a note that was EVER live is never version
history) · Mac `IAAndTrashShapeTests.archivedIsItsOwnSidebarDestination` ·
`.theArchivedSurfaceSearchesItsOwnListing` ·
`.anArchivedNoteListsInArchivedAndNeverInTheTrash` (both real observations).
**RED ON OLD** (behavioural revert: `let versionFence = false ? …`):
`Expectation failed: !((listed.map(\.postID) → [...0008, ...0004]).contains(copy.post.id → ...0008) → true)`.

**Files:** `Sources/VariorumCore/Queries/Timeline.swift`, `Observations.swift`,
`Features/Library/ArchivedView.swift` (new), `RecoveryView.swift`,
`SidebarView.swift`, `RootView.swift`, `Workspace/WorkspaceModel.swift`,
`Workspace/WorkspaceNavigation.swift`, `Features/Stars/StarsModel.swift`.

---

#### Row 11 (D1) — takes leave the global Trash

**Mechanism, verified:** both surfaces computed their kinds the same way —
`kindFilter.map { [$0] } ?? Set(Queries.TrashItem.Kind.allCases)` — so the
ENUM decided what the Trash listed, on the Mac and the phone independently.

**Build:** `TrashScope` in `Shared/RecoveryActs.swift` — `listedKinds` (note ·
book · block · preservedOriginal), `filterKinds`, `kinds(filter:)`. Both models
adopt it in one line each and both pickers read `filterKinds`, so the phone
inherits D1 with no face change (its chip row and its two lists stay mobile's
own round to reshape). The DATA is untouched: `Queries.trash(kinds: [.take])`
still answers, which is what batches 3–4 will read.

**KNOWN TRANSIENT, in-round only (the brief names it):** until batch 3's
note-level audit and batch 4's Block History pane land, a deleted take has NO
listing anywhere. The tombstone, the clock and `restoreVariant` are all intact
— it is a findability gap for the length of the round, and the tutorial lesson
already says where it will live.

**Pin:** `IAAndTrashShapeTests.aDeletedTakeIsAbsentFromTheTrashListingButNotFromTheStore`
(drives the real observation; then asserts the variant is still tombstoned and
still answered for by the query) + `.theTrashScopeIsOneDecisionForBothSurfaces`.
**RED ON OLD** (revert `listedKinds` to `allCases`): 5 issues, e.g.
`Expectation failed: !(model.trash.contains { $0.kind == .take } → <not evaluated>)`.

**Files:** `Shared/RecoveryActs.swift`, `Features/Library/RecoveryView.swift`,
`VariorumMobile/Features/Shell/MobileTrashModel.swift`, `MobileTrashView.swift`.

---

#### Rows 3 + 22 (A3 + G7) — the grouping IS the naming

**Mechanism, verified:** every row carried its own `from ‹note›` suffix, so a
note with many deleted blocks read as N identical context lines — her G7
clutter exactly — and A3's *"a deleted take definitely needs to name both note
& block"* had no structural answer for blocks either.

**Build:** `TrashGrouping` (shared, pure): rows with a home note gather under a
header; the note's OWN row heads its group when the note is in the Trash too;
**a group of ONE flattens back to a plain row** (a header repeating what the
row already says is the clutter, not the cure); groups sit where their first row
fell, so "newest first" still reads newest first. Her tenth-sitting extension:
stranded ancestors NEST under the deletion that stranded them — and the anchor
is the QUERY's answer, not a stamp match at the face, which is what makes it
survive a multi-delete where several blocks share a stamp.

`Queries.TrashItem` gains `anchorBlockID` (read-side projection field, defaulted
— every existing construction compiles unchanged), filled by an explicit ordered
correlated read in `strandedOriginals` rather than by leaning on SQLite's
bare-column-beside-`MAX()` convenience, so the answer is deterministic by the
statement's own words. The face renders headers, indents group rows, and
suppresses the per-row `from ‹note›` inside a group only (`namesItsHome`).

**Pins:** core `.aStrandedOriginalNamesTheDeletionThatStrandedIt` · Mac
`.blocksFromOneNoteGatherUnderThatNote` · `.aLoneBlockStaysAPlainRow` ·
`.aDeletedNoteHeadsItsOwnGroup` ·
`.strandedAncestorsNestUnderTheDeletionThatStrandedThem` (her 30-ancestor
scenario, literally) · `.anOriginalWithNoListedAnchorStillRows` ·
`.groupsSitWhereTheirFirstRowFell`.
**RED ON OLD** — core (drop `anchor_block_id`):
`Expectation failed: (original.anchorBlockID → nil) == (w.second.block.id → …0009)`;
Mac (guard the nesting map off): the 30-ancestor pin reds.

**Files:** `Sources/VariorumCore/Queries/Trash.swift`,
`Shared/RecoveryActs.swift`, `Features/Library/RecoveryView.swift`.

---

#### Row 21 (G6) — the door takes exactly what it rows

**Mechanism, verified:** `TrashPurge.emptyTrashConfirm` and `.confirm` both
read `Queries.trash(db, now:)` over EVERY kind and filtered only
`.preservedOriginal`, so Empty Trash purged deleted takes on living blocks —
rows the Trash no longer shows at all after D1.

**Build:** `TrashScope.emptyTrashTakes` is the one rule (note · book · block
TRUE; take and preserved original FALSE, for two different reasons, both
stated). The ask-time read still counts EVERY kind, deliberately — the take
count is what lets the sentence be honest. `RecoveryCopy.emptyTrashConfirm`
totals only what the door takes and turns the take count into **her caveat**:
*"N deleted takes on living blocks stay — but not kept: each still runs out its
own 30 days, and putting one back is what keeps it."* (Her words on both halves:
*"i don't want it to be clock exempt"* and the door-shows-what-it-takes
principle.) The "delete absolutely everything" alternative is NOT built — her
lean, recorded.

**Pins:** `IAAndTrashShapeTests.emptyTrashSparesADeletedTakeOnALivingBlockAndSaysWhy`
(drives the real confirm and the real act; asserts the block purged and the take
alive) · `.theBulkDoorsScopeIsNamedRatherThanInlined`. **Two shipped pins
STRENGTHENED IN PLACE, both with the mechanism written into them** (the brief's
instruction): `TrashPurgeDoorsTests
.emptyTrashsConfirmNamesTheFullCountByKindAndTheActTakesEverything` →
`…TakesEverythingItRows`, its world gaining the take her ruling protects; and
`.theEmptyTrashWordsCountByKindAndNameRidingOriginals`, whose `41 things go for
good` becomes `38` with the caveat asserted beside it. Neither was weakened —
both assert MORE than before.
**RED ON OLD** (revert `emptyTrashTakes` to include `.take`):
`(message → "…2 things go for good: 1 block…").contains("1 thing goes for good")`
and `(takeAlive → 0) == 1`.

**Files:** `Shared/RecoveryActs.swift`, `Shared/RecoveryCopy.swift`.

---

#### Row 18 (G3) — "unplaced" never reaches her eyes

**Mechanism, verified by grep over both app targets:** exactly TWO user-facing
strings said it, both in `RecoveryCopy.putBackUnplaced` (*"…so it's waiting
unplaced."*). Everything else carrying the word is code (`Queries.unplacedBlocks`,
`unplacedOrigins`, `UnplacedOrigin`) or a comment, and those keep their names —
they are the model's vocabulary, which is exactly the distinction her fold
question drew.

**Build:** both sentences reworded to say the true thing without the debug noun
("…so it's set aside on its own for now"), and
`RecoveryCopy.goesWithItsFamily` folded to her sense — *"set aside by a divide
or merge — kept until its family goes"*, replacing *"preserved original — goes
with its deleted blocks"*, which led with the internal noun and left the "why"
to be guessed. The SEMANTIC fold stays DECLINED (the ledger row records why: an
original rides its family's purge clock while archived means never purged).

**Pins:** `.noSentenceSheCanReadSaysUnplaced` (nine sentences incl. both
landing receipts and the registry's own note) · `.aPreservedOriginalReadsAsWhatTheMergeDidToIt`.
**One shipped pin edited in place, JUSTIFIED:** `TrashSurfaceTests
.theDeleteReceiptNamesAnOriginalItJustStranded` asserted the OLD label verbatim;
the CLAIM is unchanged (the moved row wears a label saying it goes with its
family) and the words changed by her ruling — it now asserts the claim plus the
absence of the retired word.
**RED ON OLD** (restore both sentences + the old label): 8 issues across the two
pins, each reading the word back.

**Files:** `Shared/RecoveryCopy.swift`, `Features/Tutorial/TutorialSeeder.swift`
(the lesson quotes the label verbatim, so the quote moved with it).

---

#### Row 25 (found-item 2) — the archive-a-note door

**Mechanism, verified:** the door EXISTS in two row menus (`LibraryCatalogView
.postMenu`, `PoolPostsView`) as a bare `Button("Archive")` — undeclared, and
acting in **silence**. On a list that then drops the row, silence reads exactly
like a deletion, which is the one thing archive is not.

**Build:** `.archiveNote` declared (`verb: "Archive"`, scope `.post`, doors
`[.contextMenu]`, `takesAccess: .native`, `availability: always` — the
`.deleteSelectedNotes` shape, since the target is the row she right-clicked;
no R118 exemption needed, and the walk's union covers it through
`SidebarView.contextMenuCapabilities` where `.deleteNote` already lives). Both
renderers read the registry verb. `LibraryViewModel` gains a `receipt` slot
apart from `lastError` (row 6's finding, one surface over) and
`archive`/`unarchive` set it; the Library's overlay and `ArchivedView`'s render
it in the muted voice.

**Pins:** `.theArchiveNoteActIsDeclaredWithItsDoors` ·
`.archivingANoteNamesTheArchivedSurfaceInItsReceipt`.
**RED ON OLD** (drop the `receipt:` argument from `LibraryViewModel.archive`):
`receipt` stays nil and `#require` reds.

**Files:** `Registry/Capability.swift`, `Registry/CapabilityRegistry.swift`,
`Features/Library/LibraryCatalogView.swift`, `Features/Library/LibraryViewModel.swift`,
`Features/Library/SidebarView.swift`, `Features/Pool/PoolPostsView.swift`,
`Shared/RecoveryCopy.swift`.

---

#### THE TUTORIAL — mechanical door-path corrections only (the brief's fence)

Four edits, each forced by a door that moved, and **no lesson re-teaching**
(that is batch 6 / D2):

1. *"Library ▸ ⋯ ▸ Archived & Deleted opens two lists"* → the two rooms, named
   by their new doors (the sidebar item, the trash icon), with the kinds list
   corrected to notes · books · blocks and ONE parenthetical saying where a
   deleted take waits instead. A lesson naming a dissolved menu is a P-6
   regression, so this is the minimum that stops it lying.
2. *"Empty Trash for all of it"* → *"for everything it lists"*, plus *"and says
   what it leaves alone"* — G6 made the old clause false about a destructive
   door.
3. The practice step's *"open Archived & Deleted"* → *"open the Trash"*.
4. The quoted preserved-original LABEL, which the lesson carries verbatim and
   the spine asserts from the constant.

**The spine is green by TYPE name (63/8)** and every `RecoveryPath` / `TrayPath`
assertion in `TutorialDeletionActsTests` still resolves — deliberately, because
those read from the constants rather than from re-typed prose.

---

#### OBSERVATIONS — nothing built, for the architect

1. **The phone's recovery surface still holds BOTH lists under "Archived &
   Deleted".** The Mac split it; `RecoveryCopy.surfaceName` survives for that
   face alone, with the split named at the constant as what mobile owes. **A
   parity note for the closeout** (it composes with PL-13 and the batch-6
   updates row 13 already schedules).
2. **`RecoveryCopy.archivedNotesReceipt(_:)` is written and unused.** Its
   singular sibling ships; the plural exists because a bulk archive door is the
   obvious next ask beside `.deleteSelectedNotes` and writing it now cost one
   line. Flagged rather than left to be discovered.
3. **The Archived surface's search is a NAME filter**, not body text — her
   *"search it separately"* half at the level the Library's own catalog search
   works. **13o inherits the scope note**: the archived surface is a second
   scope, and the index must exclude nothing it should hold.
4. **`Queries.archivedPosts`' default flipped to excluding version history.**
   It is a core query with a changed default, which is a real (if small)
   semantic change; the raw column stays reachable by argument and the pin
   exercises both readings. Recorded because a future caller inheriting the
   default should know it is a product rule, not a performance one.
5. **The Trash's group headers use `model.homeTitle`**, so a scrap's group
   reads as the scraps area rather than a note (13l §8b's brain, reused). A
   group whose rows all came from a pool therefore reads correctly with no new
   code.
6. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/`, `App/Variorum/Shared/` and
   `Sources/VariorumCore/` returns only the two pre-existing doc comments
   (`NoteWindowView`, `QuickNoteView`).


### BATCH 3 — THE TRAY GOES TO THE SIDE PANEL: the brief (fresh Opus session; dispatches after batch 2's record)

**Read in full first:** `CLAUDE.md` + canon · THIS FILE top to bottom
(your rulings: §C1, ledger rows 9 and 20; the LIFECYCLE TABLE rows
B1, B2, B3, T6 are your acceptance shape) · the 13j **Environment
traps** (binding verbatim) · the 13l plan's **ACT 7 — WALK RECORD**
(the tray's walked state; P-1's squeezed-preview mechanism) ·
batches 1–2's records above (batch 1's deferred items below are
YOURS; batch 2's `TrashScope`/`TrashGrouping` and naming are your
precedents).

**Scope — ledger rows 9 (C1) · 20 (G5), plus batch 1's two deferred
items routed here.** Fences: zero schema · zero `Sync/` · the Block
History pane and came-from are batch 4's · versions batch 5's.

- **Row 9 (C1, her words in §C):** the note tray becomes **an icon
  beside the scraps and reference icons**, opening **in the side
  panel** (`PostDetailView.InspectorPanel` gains `.tray`; the icon
  toggles like its two siblings). The note ▾ menu's "This Note's
  Tray…" item **follows the move** (removed — the icon is the named
  door); the **⌫ N badge STAYS as the glance signal and clicking it
  opens the same panel** (the kickoff call, recorded above).
  Registry P-1: `.showNoteTray`'s doors update. The panel gets the
  room her ruling names — the preview no longer loses to its
  metadata (the walk's P-1 mechanism: the flexible `Text` compresses
  first; give it `layoutPriority`/the panel's width).
- **Row 20 (G5, her rulings verbatim in the ledger):** the tray
  panel's sections become the map's letter:
  - **Archived blocks** — kept, forever, no clock (B1's row).
  - **The LEAVING section** — the complete per-note pre-purge
    audit: every clocked thing of THIS note — deleted **blocks**;
    **its deleted takes under a collapsed-by-default disclosure**
    (each row naming its BLOCK — A3's discipline; each carrying
    **Put back** (status-aware receipt — the restore machinery
    exists from 13j) AND **Delete Now** with confirm-every-time
    (the purge-door class; `requestPurge` takes `variant` targets —
    verified at kickoff)); and **clocked originals** once their
    family clock starts (the 13j 8b nets untouched — this is their
    note-side face).
  - **Unclocked preserved originals:** their RULED home is
    lineage-only (batch 4's came-from). **To avoid a dark window,
    KEEP the existing originals section listing them in this batch**,
    marked in code for batch 4's removal — batch 4 deletes the
    section the same commit came-from lands. Record this staging.
  - Purge doors live in TRASH SURFACES only (the global Trash +
    this leaving section) — never in the writing flow; nothing else
    gains one.
- **Batch 1's two deferred items (its record, "deliberately not
  fixed"):** the ARCHIVE receipt still names the note-menu door —
  rewrite to name the tray's NEW door (the icon); the scraps
  editor's `note ▾` "This Note's Tray…" label — the scraps surface
  takes the same icon door with home-kind-aware wording (the 13l
  row-26 `BlockRestoreLanding` kind machinery is the precedent; a
  pool's tray is the scraps area's own).

**Discipline:** the standing loop — red-on-old by behavioural revert
for bug-class fixes; walk-driven pins for the door moves (drive the
real surface); spine green BY TYPE NAME (mechanical re-pins for the
moved door are yours; lesson content is batch 6's); full four gates
with counts quoted (mobile runs if `Shared/` is touched — baselines
now core 1376/143 · Mac 1717/293 · spine 63/8 · mobile 486/78);
instance check before build-adjacent acts; commits staged by
explicit path, NEVER push. **Append "### BATCH 3 — RECORD"**, flip
rows 9 and 20, and STOP.

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
