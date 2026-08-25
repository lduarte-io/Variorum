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
| 9 | C1 the tray icon → side panel, originals separated | **done** `29e9876` — `PostDetailView.InspectorPanel` gains `.tray(revealBlockID:)`; the masthead renders a three-door table (tray · scraps · references); the `note ▾` item is gone from BOTH bars and `.showNoteTray` is `.surface`-only with three renderers; the badge opens the same panel through a dedicated `CommandRouter` seam (parking for an unfocused pane); the walk's P-1 squeeze fixed by STACKING the row |
| 10 | C2 the side-panel lineage view, ALL originals | **done** `06263d1` — FOLDED into 17 as planned: the Block History pane's **Came from** region reads the whole `unplacedOrigins` array (the 13l walk's P-3), each original with its text and a one-button way back. Her mobile parity note survives untouched to the closeout |
| 11 | D1 takes nested under context-parent block rows | **done** `47c0cb7` — superseded shape built: takes NEVER row in the global Trash (`TrashScope`, shared, so the phone inherits). Data and clock untouched. **Transient CORRECTED at the ladder (LR1-3, `12b5942`'s record):** in-round for the MAC (batches 3–4 gave takes their two homes); **OPEN-ENDED for the PHONE**, whose homes are mobile batch 6, paused until after 13u — the dark window is named in batch 2's record, and the product half is hers |
| 12 | D2 the lesson edits + spine re-pins + her-store re-seed at closeout | **done (lessons + spine)** `2c16797` — the tray & Trash lesson stopped teaching *"No door inside a note ever deletes something for good"* (her G5 ruling superseded it) and the books lesson stopped naming the ⋯ menu B1 dissolved; A7's merge sentence landed; the pins now check the sentence against the two surfaces' own capability tables. **The her-store RE-SEED is still the CLOSEOUT's** (row 13) |
| 13 | Closeout ritual: records · canonical deltas as ruled · MobileSoul parity notes (C2 mobile shape; PL-11's tray face follows C1's ruled shape; a Note ▸ Versions phone-face note) · QUESTIONS for any PROVISIONAL · the running-order row closed · **annotate `notes/plans/whole-note-history-brief.md`** (its manual half is FULFILLED by V-family; its automated future = her floated auto-rotating versions, feeding the same listing) · **🔴 HER INSTRUCTION (eighth sitting, verbatim-faithful): AT CLOSEOUT — AND ONLY AT CLOSEOUT, "not earlier in the process, so I don't burn tokens on every message by loading it first" — read `notes/MobileSoul.md` and UPDATE the mobile round's BATCH 6 plans** (the per-note tray · deleted takes/History past · archive doors · the lineage door · the guide's deletion chapter) **to the design this round built** — the tray panel + leaving section, the Block History pane, takes-never-global, the five-places map — so mobile inherits the ruled design and never builds the mid-design (*"It's really good we got such a strong design done before a mid design had propagated to mobile"*) | open |
| 14 | **F1 — ARCHIVE RIDES BESIDE DELETE AT EVERY BLOCK DOOR** (her second morning report, 2026-08-24 — later softened: *"no, I see archive there too"*, so this is a VERIFICATION pass, not a rescue). The menu BAR's Block menu pairs them adjacently (13j's letter — verified in `EditorCommands.swift`); the pass confirms every OTHER door that offers a block Delete without the Archive twin (context/row menus — enumerate via the registry, the door-set is checkable). Same pass verifies the TAKE-card menus: Write's panel ⋯ carries Archive · Label · Lock · Delete (verified) — Takes mode's card grammar must match. **Context for the builder: the 13l walk's P-6 sentence ("the only door that deletes a take is inside the archived strip") is OVERSTATED — active take cards carry Delete; do not build against P-6's wording.** Her open musing, verbatim, for the round's checkpoint — *"I don't even know if we need take archiving if I'm not seeing it right now?"* — with the architect's recommendation recorded: KEEP the capability (her own morning argument — archive is forever-valuable and distinct from the clock — applies to takes exactly; the model's I10-rescue and pool-copy semantics also mint archived states), FIX the doors; retiring it is hers to rule if the fixed doors still don't earn it | **done** `200981f` — five block-door renderers verified/fixed, the scrap rows given the pair through a new `.archiveScrap`, and the take-card grammar made uniform; the pass's real finding was that FOUR acts (`.lockTake`, `.deleteTake`, and `.archiveTake`/`.labelTake`'s surface renderer) had been rendered UNDECLARED since Phase 7, which is why the drift was invisible. |
| 15 | **done** `06263d1` (via 17). **F2 — RESOLVED BY HER OWN SECOND LOOK, folded into 17:** she FOUND the deleted take in the block's History past region (*"I actually do see the deleted take in history"*) — not a data bug; a DOOR-PLACEMENT problem (*"it's unclear that history is under Note, that makes it seem like the Note's history"*). No Trash-side trace owed (takes leave the Trash by D1-revised anyway). Row 17 is the fix | **resolved → 17** |
| 16 | **G1 — THE WHOLE-NOTE VERSIONS DOOR (her ruling: "yes, in this round").** Her floated shape, adopted: *"an easy door would be to make a copy of the note, archive it, and then let you look through the archived copies made at points in time - not automated, but an easy door for people who want to save the whole note as it is."* **COMPOSE, don't build:** "Save a copy of this note as it is" = `duplicateAsVersion` (exists; mints the `version_of` edge) + note archive (exists) → a **"Versions of this note"** listing (dated, openable, restorable-by-copy) driven by the `version_of` lineage — one query, zero schema, zero new concepts. The copies also appear under the Archived-notes surface (B2) as ordinary archived notes. **`notes/plans/whole-note-history-brief.md` is the AUTOMATED future that later fills this same listing — read it so the manual door's shape doesn't foreclose it.** This is the round's headline: the Google-Docs answer ("my whole note at this point in time"), which her holistic worry named as the one thing people will conclude is missing | **done** `2212c36` `7e3e763` — composed exactly as her shape names it, zero schema. The classifier is the BIRTH FACT (`archived_at == created_at` from ONE clock read) + the `version_of` edge; the copies do NOT appear under Archived (V1 corrected the row's older sentence, and batch 2's exclusion is its other half). `NoteVersionItem` carries a `cadence` from birth, so 13w's automated rows fill this listing with nothing to redesign |
| 17 | **G2 — THE ONE BLOCK HISTORY PANE (her second-sitting revision — supersedes the same morning's block-menu ruling, her words: "I know I just ruled that history should go in the block menu, but I think I'm changing my mind and it should be in the bottom chrome - my reasoning is that history is quite similar to commit, it's the natural pair to commit").** The door lives in the BOTTOM CHROME beside Commit (write a moment / see the moments — the bar becomes the block's time controls) and opens ONE cohesive side pane: **each live take's savepoint run (ALL takes, sectioned, the focused take's expanded — her ruling) · archived takes (Unarchive) · deleted takes (clocks + Put back) · came-from (the lineage section: a merge's ALL originals, each with a DIRECT restore button — her fourth-sitting ask: *"add as block again to the note (that's too wordy, you can reword the button, but the idea is that if you just merged something then realized you actually wanted a parent block, you should just be able to pull that parent block back into existence easily)"* — the op is `placeBlock`, the W-reversibility primitive; the round drafts the short wording)**. This pane ABSORBS three doors — J3's lineage peek, the History face's past region, the archived disclosure — and C2's separate lineage-view row FOLDS INTO IT (C2's mobile parity note survives unchanged). It is the round's biggest single build and the map's fifth place made real; her stated teaching intent binds the design: *"the 'Block history' pane will be a strong memory and the expectations are clear"* | **done** `06263d1` — the pane built with all four regions, the door on both bars beside commit, the act declared BLOCK-scoped (F2's defect closed at the declaration), and THREE surfaces absorbed (Write's inline strip, the Takes history sheet, the J3 peek incl. its nested tray sheet). |
| 18 | **G3 — THE "UNPLACED" WORDING FOLD (presentation YES, semantics NO — her fold question answered).** Her words: *"why do we have unplaced as separate from archived? should we fold those two concepts in?"* The SEMANTIC fold is declined with the reason recorded: a preserved original rides its FAMILY's purge clock (her own 13j round-8b ruling — "goes with its deleted blocks") while archived means NEVER purged; folding them breaks one promise or the other. The PRESENTATION folds completely: a preserved original reads as *"set aside automatically by the merge — kept until its family goes"*; the word **"unplaced" must never reach a user's eyes** (debug vocabulary only — sweep every surface and receipt for it) | **done** `47c0cb7` — exactly two user-facing sentences said it; both reworded, and `goesWithItsFamily` folded to her sense. Queries keep their names. |
| 19 | **G4 — A NEW TUTORIAL CHAPTER teaches the map (her third-sitting expansion: "the next polish session should definitely add a new tutorial chapter about this… the user should be encouraged to get comfortable with each of the" places).** A NEW chapter (not just lines in the deletion chapter): the five places — *where you left it · Archive (notes, forever) · the Trash (what's leaving: notes·books·blocks, 30 days) · this note's Versions · this block's History* — each visited by the walk, **plus the take-savepoint story made explicit** (her: "making it clear where commit / that particular history by the take is, is also important" — the commit↔history bottom-chrome pairing is the teaching moment). Walk-asserted; D2's re-pin + her-store re-seed cover it | **done** `2c16797` — the chapter **"where things go"** (three lessons) sits after the deletion chapter; the spine GREW 63/8 → **68/9**, `TutorialWherePlacesActsTests` visiting all five places through real acts |
| 20 | **G5 — THE TRAY'S HONEST "LEAVING" SECTION (her third-sitting ruling):** *"the tray of a note should have an honest trash section with everything being deleted, so it's never a surprise - and takes can be shown in that per note trash, albeit maybe not shown by default, so you can always see a list of what will be deleted."* The note's tray panel (C1) gains the complete per-note pre-purge audit: every clocked thing of THIS note — blocks, AND its takes under a collapsed-by-default disclosure — plus clocked originals when their family clock starts (the 13j 8b nets untouched: the visible move, its receipt, the Trash row). **Her fourth-sitting addition: the take rows HERE carry a Delete Now button** (*"to keep the capability"* — confirm-every-time binds it like every purge door). **This supersedes-IN-PART the 13j round-3 rider** ("inside the Trash only — never a door in a note or the editor, ever"): the evolved rule, hers — **purge doors live in TRASH SURFACES (the global Trash AND this note-level trash section), never in the writing flow** — recorded for the closeout's delta. **Originals while UNCLOCKED are lineage-only** (the Block History pane's came-from section — her earlier instinct, now consistent: the tray audits what is LEAVING; lineage holds what is KEPT) | **done (staged)** `29e9876` — the three sections built (Archived · Leaving · Preserved originals); the note-scoped `Queries.trayTakes` rides a collapsed-by-default disclosure whose rows name their BLOCK and carry Put back + Delete Now (confirm every time, the payload riding `presenting:`). ~~**The ORIGINALS section is STAGED, not removed**~~ — **STAGING FINISHED at batch 4** (`06263d1`): the section is gone in the same commit came-from landed, exactly as the dark-window rule required. `Snapshot.originals` stays (the STRANDED arm is derived from it — an original whose family died IS leaving), and `TrayPath.originalsPath` now names the pane's came-from region, which the eight quoting copy sites followed for free |
| 21 | **G6 — EMPTY TRASH PURGES EXACTLY WHAT IT ROWS (her ruling, and it SUPERSEDES 13j round-8's "everything, always" — a canon change, hers, recorded for the closeout's delta):** *"should we make 'empty trash' not delete takes by default? … a deleted take on a living block might be the one item a user does want to keep. I think that delete everything, including takes not displayed here, should be an alternative button if it even exists."* Built shape: Empty Trash takes notes · books · blocks + their families (a rowed block's own takes go with it — family-complete, honest, all rowed); **individually-deleted takes on LIVING blocks are untouched by the door** and expire on their own 30-day janitor clock only. **The honesty caveat the copy must carry: sparing from Empty Trash is NOT keeping — the clock still runs; restoring the take is the keep road.** The "delete absolutely everything" alternative button is NOT built (her "if it even exists" lean; recorded — a future door at her word). Takes' Delete Now capability LIVES in the note-level trash (row 20 — her fourth-sitting placement; Block History still carries no purge door); the in-Trash-only rule evolves as row 20 records. Her confirmations, same sitting: NOT clock-exempt (*"i don't want it to be clock exempt"*), and the door-shows-what-it-takes principle stands (*"I just don't think a 'delete everything' button in the trash should delete items that aren't being shown"*) | **done** `47c0cb7` — `TrashScope.emptyTrashTakes` is the one rule; the confirm totals what it takes and carries her sparing-is-not-keeping caveat; two shipped pins strengthened in place. |
| 22 | **G7 — TRASH BLOCK ROWS GROUP UNDER THEIR NOTE (the architect's proposal at her "will it be a bunch of blocks in the trash?" — PROVISIONAL, hers to unwind):** the global Trash's block rows gather under a small note-name header (the note itself only rows if IT is deleted), so a note with many deleted blocks reads as one group, not clutter. Composes with A3's naming; presentation only. **EXTENDED at her tenth-sitting ruling — the round's LAST refinement:** when deleting a live block strands its preserved ANCESTORS onto the family clock, **the Trash shows those ancestors NESTED UNDER the just-deleted block's row** — her words: *"those ancestors [go] under the live block that was most recently deleted - so if you had 30 ancestors on one live block's history and you delete that one live block, going to trash shows you what you just deleted rather than suddenly being overwhelmed by 31 random items … a more visible UI for 'your ancestors die with you' (lol)"*. The 8b nets (the move, its receipt) unchanged — this is their FACE | **done** `47c0cb7` — `TrashGrouping` (shared, pure): note headers, the deleted note heading its own group, groups-of-one flattened, and ancestors nested under the deletion that stranded them via a new query-supplied `anchorBlockID`. |
| 23 | **THE VERSIONS FAMILY (the V-rulings built):** the ⌘⇧S Save-a-Version door (chord verified free) · the Note ▸ Versions listing (dated, derived display, no title mutation) · copies born ARCHIVED + SEALED in one transaction · RESTORE identity-preserving (saves-now-first; outgoing blocks on the Delete Now road) · PROMOTE (unarchive+unseal → first-class) · versions RIDE the note's deletion (one confirm line, no dialog) · deleted single versions → Trash rows grouped under their note (RATIFIED) · the search-scope exclusions (main = live; Archived = non-version; versions in-context only — handed to 13o) | **done** `2212c36` `7e3e763` `53b4edb` `60c5bcc` — all nine V-rulings built. The restore is identity-preserving AND **re-anchors every version link** (a defect the round would otherwise have shipped: the link rides the note's first block, which the restore deletes). `deleteContainer`/`restoreContainer` carry the ride, so no door can forget it |
| 24 | **V3's MUST-PIN:** version copies of journal notes never trip the bridge's duplicate-day pause — verified whichever way the machinery composes, pinned either way | **done** `2212c36` — **THE TRAP WAS REAL, and the revert proves it**: without the fix the day PAUSES and pushes nothing (`pausedDays → ["2026-07-09"]`, `pushed → 0`). Fixed at the MINT (`entry_date` dropped — a saved moment is not a day), never in the engine: **zero `Sources/VariorumCore/Sync/` lines**, and the bridge's day scan is byte-unchanged |
| 25 | Found-item 2: the archive-a-note door verified/ensured (one clear door, receipt naming the Archived surface) — rides B1's registry pass | **done** `47c0cb7` — the door existed in two row menus, undeclared and SILENT; now `.archiveNote` is declared, both renderers read its verb, and `LibraryViewModel` gained a receipt slot that names Archived and its absence of a clock |
| 26 | The tutorial chapter (row 19) teaches the VERSIONS story too: ⌘S vs ⌘⇧S — this take's moment vs this note's moment — the grain pairing as the lesson | **done** `2c16797` — the lesson **"saving a moment"**; both chords read from the registry in its pin, and the walk drives BOTH doors and asks where each moment landed |
| 28 | **THE Aa BOTTOM-CHROME CONDENSATION (her kickoff addition, 2026-08-24 — verbatim in the kickoff record; SCOPE RULED at the kickoff sitting via the question tool): FORMATTING ONLY BEHIND Aa.** The `FormatBar` cluster + the newlines chip condense into one Aa button; clicking Aa slides the formatting row out (the phone's Aa expanding-row idiom, now on the Mac — a reverse-parity face like dark mode). Block ▾ · Takes · commit ⌘S · **History (row 17's new door)** · note ▾ · comments · counts · ? all stay visible at rest — the "bar becomes the block's time controls" reading survives by construction. Both bars (`CommitBar` + `TakesBottomBar`) take the same treatment; registry discipline P-1 (doors move, declarations unchanged — the R6-2/13g slide-out precedent is exactly this class); expansion state is session UI state | **done** `7220086` — nine controls behind one `Aa` chip on both bars, the row sliding out ABOVE the flat row; registry ids unchanged (the R6-2/13g class); measured 9 at rest / 18 open on the real mounted bar. |
| 33 | **THE PANE'S CURRENT-BLOCK JUMP (her 2026-08-25 refinement on the ratified request-scoping):** when the caret has moved to a different block than the Block History pane shows, a small in-pane button jumps to the current block's history — no close-and-reopen. Batch 6 rider | **done** `aa47d6d` — a FACT the writing surfaces report (`FocusedBlock` on the router, on a block change only) + a pure `jumpTarget` rule + the door, drawn only when it can act; the host re-points its own occupant |
| 32 | **THE FENCE SENTENCE (#77(a), her ruling "Name the road instead"):** the scraps-area delete fence's refusal becomes *"Scraps go one at a time — delete the scraps themselves."* — one string in the shared home, pin updated. Batch 4 | **done** `014f409` — one string in the shared home, its pin strengthened to assert the road is named. |
| 31 | **GENTLE GREEN ON FULLY SYNCED (#75(c) rider, her words: "a gentle green on fully synced might look nice"):** the sync-status line's everything-sent state wears a gentle green — via the voice vocabulary (a quiet positive tint beside row 29's error token; no literal colours). Batch 4 | **done** `014f409` — the STANDING decides its own tone (`.quiet`/`.settled`/`.attention`, shared with the phone) and the pane renders a voice token; the literal `Color.orange` is gone and signed-out stays quiet (#75(d)). |
| 30 | **ANCESTORS COLLAPSIBLE (her mid-round refinement on the ratified G7):** the nested-ancestors run under a just-deleted block's Trash row gains a dropdown-arrow disclosure — expanded by default, collapsible at will. Builds in batch 5 (already in the grouping for version rows) | **done** `53b4edb` — a `DisclosureGroup` that starts OPEN, keyed by the anchor row so one deletion's fold never folds another's; the label carries the COUNT (a fold that hides its own size is not an audit) and says what the run IS |
| 29 | **THE ERROR VOICE TOKEN (her mid-round ruling: "Add it this round"):** one named error/danger slot per voice in the shared token vocabulary; refusal/error surfaces adopt it through the voice (no literal reds return); both platforms share the file; hues revisable at 13s, dark mode (13u) inherits the slot. Builds in batch 4 | **done** `014f409` — `alarm` + `positive` in all four voices, swept through `.alarmVoice()`/`.positiveVoice()` across 21 Mac and 12 mobile sites plus the `tokens.accent` refusal slots batch 1 and 3 shipped. |
| 27 | **THE TWO-EXITS LESSON (her eleventh-sitting mandate — "I deleted a paragraph, is it in deleted or in lineage? and lineage of what block" must be legible):** the chapter teaches **"Deletion goes to the Trash; transformation goes to lineage"** — a block you DELETED is on the clock, Put back real; a block that BECAME something else (merged, divided) lives in the new block's History came-from, one button back. Taught by DOING (her idea, adopted: the lesson walks the user through deleting a whole block, then making an edit that merges two — and finding each in its exit). Covers TODAY's truth incl. the shipped merge-then-edit; **the fanned cross-block matrix is 13u's** (its sitting + its own lesson update — the split is recorded there). The merge's own silence stays HER declined P-2 — the tutorial carries the teaching, not a per-merge message | **done** `2c16797` — the lesson **"the two exits"**, and the walk does what it asks: a triple-click delete lands in the tray AND the Trash; a cross-seam edit joins two blocks and BOTH turn up in the joined block's came-from with no clock anywhere |


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

**THE #75–#79 SITTING (same day — she asked for each with full
detail via the question tool; dispositions recorded in
`notes/QUESTIONS.md` at the entries, riders where they land):**
- **#75(a):** the automatic plaintext export **ENDS AT 13P** — her
  words verbatim at the QUESTIONS entry; rider added to 13p's
  R13p-8 (off by default once encryption is present; opt-in
  survives). Weekly-keep-4 stands until then.
- **#75(b):** folder-only RATIFIED. **#75(c)(d)(f):** ratified,
  plus *"a gentle green on fully synced might look nice"* —
  **ledger row 31** (batch 4, via the voice vocabulary — no
  literal colours return).
- **#76:** all three shapes RATIFIED as shipped.
- **#77(a):** the fence sentence becomes the door-naming shape —
  *"Scraps go one at a time — delete the scraps themselves."* —
  **ledger row 32** (batch 4, one string in the shared home + pin).
- **#78:** the standing disposition CONFIRMED (prevention rides
  13p). **#79:** all three shapes RATIFIED; her "where is this?"
  answered at the sitting (the Library's List view mode).

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

> **🔴 CORRECTED BY THE LADDER (LR1-3, fix wave 2026-08-25) — the paragraph
> above is TRUE FOR THE MAC AND FALSE FOR THE PHONE, and the correction is
> recorded rather than the sentence quietly rewritten.** `TrashScope` is
> SHARED, so removing the take rows removed them from `MobileTrashView` in the
> same commit — but the two replacement homes are **Mac-only faces** (the tray
> panel's Leaving section, batch 3; the Block History pane, batch 4). The
> phone's equivalents are **mobile batch 6**, and the mobile round is paused
> until after 13u by her sequencing ruling. So on the phone the window is not
> in-round: **a take deleted on the phone is invisible and un-restorable THERE
> for as long as that batch waits** (its clock keeps running; it stays
> recoverable from the Mac, and nothing about the data changed). The
> closeout's mobile update, the MobileSoul parity line and her handoff each
> owe this window by name — and the PRODUCT half (interim phone take rows, or
> wait for batch 6) is HERS, not the fix wave's.

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

### THE ARCHITECT'S ADJUDICATION OF BATCH 3's FLAGGED ITEMS (2026-08-24, before batch 4 dispatches)

1. **The book spread's missing tray door → `.showNoteTray` gains a
   `.palette` door in batch 4.** The ⌘K palette is the standing
   universal fallback (R15) and costs zero new surface; a book
   pane's inline note reaches its tray through it. The icon stays
   the named door on the detail surfaces.
2. **The held-observation frequency class (the tray panel open
   while typing reads `variant` at autosave rate) → RECORD-ONLY
   with owner 12**, the standing P1-tension parking class (bounded
   listing, off-main, P1's letter intact — the FREQUENCY changed,
   not the scaling). Batch 4's Block History pane is the SAME class
   — one verdict covers both; the closeout writes ONE KnownIssues
   row naming both panes. No new debounce machinery this round.
   **AUTHOR-CONFIRMED 2026-08-25 (via the question tool, the
   mechanism explained in full): "Park for Phase 12"** — the
   adjudication stands with her authority; the other two flagged
   items she asked about were already batch 4's to build (the
   palette tray door; the nested-sheet dissolution), confirmed at
   the same exchange.
3. **`OriginPeek`'s nested tray sheet dissolves in batch 4** as the
   pane absorbs J3 (already the plan; confirmed).

### BATCH 4 — THE BLOCK HISTORY PANE + THE BOTTOM CHROME: the brief (fresh Opus session; dispatches after batch 3's record)

**Read in full first:** `CLAUDE.md` + canon · THIS FILE top to
bottom (your rulings: ledger rows 17, 10, 14, 28, 29, 31, 32 + the
adjudication above; the LIFECYCLE TABLE rows T1, T5, T6, B3, B4 are
your acceptance shape; row 15/F2 resolves through you) · the 13j
**Environment traps** (binding verbatim) · the 13l plan's **ACT 7 —
WALK RECORD** (P-3's single-original mechanism; P-6's context) ·
batches 1–3's records (batch 3's staging note lists exactly what
you delete when came-from lands; its `CommandRouter` seam and
`inspectorDoors` table are your precedents).

**Scope — ledger rows 17 (G2) · 10 (C2, folds in) · 14 (F1) · 28
(Aa) · 29 (error token) · 31 (gentle green) · 32 (fence sentence),
plus adjudications 1 and 3 above.** Fences: zero schema · zero
`Sync/` · versions are batch 5's · the tutorial's content is batch
6's (mechanical spine re-pins for moved doors are yours). Land in
MULTIPLE commits by theme (the pane · the bars/Aa · the
token+copy sweep · F1) — one giant commit is the failure mode.

- **Row 17 (G2 — the round's biggest single build; her rulings
  verbatim in the ledger):** the **Block History pane**.
  - **The door: bottom chrome, beside Commit** (*"history is the
    natural pair to commit — the bar becomes the block's time
    controls"*). BOTH bars. The note ▾ "History" item and the
    under-bar `CommitHistoryView` strip are ABSORBED — the pane is
    the one home (this also resolves row 15/F2: *"it's unclear
    that history is under Note"*). Registry: the history act's
    doors move; a `.palette` door too.
  - **The pane: ONE cohesive inspector occupant**
    (`InspectorPanel.blockHistory`, batch 3's seam), scoped to the
    CARET/focused block, four regions in order: **(1) savepoint
    runs — ALL live takes, sectioned, the focused take's expanded**
    (her ruling; restore-to-buffer per row, the existing
    `restoreCommit` road); **(2) archived takes** (Unarchive; A3
    naming); **(3) deleted takes** (clocks + Put back — NO purge
    door here, row 21's letter: Block History carries no Delete
    Now); **(4) came-from** — the lineage section: ALL of a
    merge's originals (the FULL `Queries.unplacedOrigins` array —
    the walk P-3 fix), each with its text peek and a **DIRECT
    one-button restore** (`placeBlock`) — her too-wordy "add as
    block again to the note" redrafted SHORT (draft it; candidate
    family: "Bring back into the note"; record your draft for her
    checkpoint) — plus Open this note's tray where the original is
    clocked.
  - **Absorptions, same commits:** `OriginPeek`'s nested tray sheet
    dissolves (adjudication 3); the tray's STAGED Preserved-
    originals section is REMOVED in the same commit came-from lands
    (batch 3's staging note lists the pieces); C2's separate
    lineage-view row folds in (its mobile parity note survives to
    closeout untouched).
  - **P3/P8 bind:** the pane is read-tier only (no live editor in
    it), bounded queries, overlays never rendering attributes.
    The held-observation frequency class: adjudication 2 —
    record-only, no debounce machinery.
- **Row 28 (Aa — her kickoff ruling, recorded above):** the
  `FormatBar` cluster + the newlines chip condense into ONE **Aa**
  button on both bars; clicking slides the formatting row out (the
  phone's Aa expanding-row idiom); expansion is session UI state;
  registry ids unchanged (rendering moved — the R6-2/13g class);
  the freed room is where the History door lives.
- **Row 14 (F1 — verification/parity pass; the take-archiving
  musing is RESOLVED KEEP, no retirement question):** every door
  offering block Delete has Archive beside it (enumerate via the
  registry's door-sets; fix stragglers); the take-card grammar
  UNIFORM (Write's panel ⋯ carries Archive · Label · Lock · Delete
  — Takes mode's cards must match); batch 1's deferred enumeration:
  `ScrapsPanel`/canvas scrap rows' delete-door parity. Record the
  table (instance × door → OK/FIXED).
- **Row 29 (error token — her ruling):** ONE named error/danger
  slot per voice (Terminal + Study) in the shared vocabulary;
  every refusal/error surface adopts it (sweep batch 1's and 3's
  `tokens.accent` refusal slots, the Trash's error styling, any
  literal reds left anywhere); hues are placeholders revisable at
  13s — pick quiet, voice-consistent ones.
- **Row 31 (gentle green — her words):** the sync-status line's
  everything-sent state wears a gentle green via the vocabulary
  (a quiet positive slot beside the error one; NO literal
  colours). Signed-out stays quiet (her #75(d) ratification).
- **Row 32 (fence sentence — her ruling):** the scraps-area delete
  fence's refusal becomes *"Scraps go one at a time — delete the
  scraps themselves."* — the shared home's string + its pin.
- **Adjudication 1:** `.showNoteTray` gains its `.palette` door.

**Discipline:** the standing loop — red-on-old by behavioural
revert for bug-class fixes; walk-driven pins for door moves (drive
the real mounted surface — batch 3's AppKit-class-names technique
is the precedent; the AX tree is EMPTY in the test host, so an
AX-based pin passes vacuously — do not use one); spine green BY
TYPE NAME (mechanical re-pins yours); full four gates with counts
quoted (mobile runs — `Shared/` is touched; baselines now core
1383/144 · Mac 1728/294 · spine 63/8 · mobile 486/78); instance
check before build-adjacent acts; commits staged by explicit path,
NEVER push. **Append "### BATCH 4 — RECORD"**, flip rows 10, 14,
15, 17, 28, 29, 31, 32 (+ finish row 20's staging), and STOP.

### THE ARCHITECT'S ADJUDICATION OF BATCH 4's FLAGGED ITEMS (2026-08-25, before batch 5 dispatches)

1. **The live DerivedData-Release instance (PID 98884):** correctly
   untouched (a Release product runs the REAL store — by store,
   never addressed). Environment note standing: every later act
   re-checks; the closeout's `/Applications` refresh gates on a
   zero-instance window as always. **Checkpoint note for her:** her
   running copy is a DerivedData product, not `/Applications` — a
   DerivedData clean would take it; worth telling her.
2. **`WriteTakesPanel`'s un-classed status slot → batch 5.** Row
   6's class one surface over; her "the color: should be fixed"
   covers the sibling. The fix is `TrayViewModel.Status`' split
   applied to `TakesViewModel` — behavior-preserving classing, not
   board surgery.
3. **`BridgeStatusViews`' literal red → batch 5, fix-if-clean:**
   adopt the tone/token plumbing if it lands cleanly in `Shared/`;
   else RECORD with the closeout (owner: 13s's voice pass).
4. **The canvas's missing block-delete door → PRODUCT CALL, hers**
   — a surface that has never offered deletion gaining doors is
   invented behavior; bundled for the checkpoint, not built.
5. The two retired pins: accepted, reasons recorded in the batch
   record. 6. The two PROVISIONALs (request-scoped pane; the
   came-from tray door on every origin row): checkpoint bundle.

**THE CHECKPOINT BUNDLE so far (hers, at the round's taste
checkpoint):** the came-from wording draft ("Bring back") · the
came-from tray door on unclocked rows · the walk of everything
built. *(Three items RESOLVED at her 2026-08-25 sitting — below.)*

### Her 2026-08-25 sitting rulings (mid-batch-5; verbatim-faithful)

- **Canvas block-delete: NO** — *"I don't think canvas needs block
  delete."* The F1 RECORDED item closes as a ruling: the canvas
  keeps no deletion door; nothing built, nothing owed.
- **The History pane's scoping RATIFIED with one refinement:**
  *"i think the history pane staying on the block you asked about
  is fine, but if you've changed blocks there should be a small
  button or something to show current block's history, so you
  don't have to close it and reopen it."* — request-scoped stands;
  when the caret sits in a DIFFERENT block than the pane shows, a
  small in-pane button jumps the pane to the current block.
  **Ledger row 33**, batch 6 (a small build rider before the
  teaching).
- **The `/Applications` refresh authorized at the round's close:**
  *"i've also closed the variorum i was running, you can refresh
  applications when this whole note is done."* — her explicit
  authorization for the closeout's refresh (behind the A1 rail,
  zero-instance re-check as always). The DerivedData-copy note is
  discharged — she closed it herself.

### BATCH 5 — THE VERSIONS FAMILY: the brief (fresh Opus session; dispatches after batch 4's record)

**Read in full first:** `CLAUDE.md` + canon · THIS FILE top to
bottom — your letter is ledger rows **16 (G1) · 23 (the V-family) ·
24 (V3's MUST-PIN) · 30 (ancestors disclosure)** plus the REVIEW
PASS **V1–V9 in full** (it IS your spec: the classifier, the
deletion ride, identity-preserving restore, born sealed, ⌘⇧S, no
title mutation, the honest costs) and LIFECYCLE TABLE rows **N1,
N2, N6 + FOUND-ITEM 1** (your acceptance shape) · the 13j
**Environment traps** (binding verbatim) ·
`notes/plans/whole-note-history-brief.md` (the AUTOMATED future —
13w — that later fills the SAME listing; don't foreclose it: the
listing must not assume manual-only) · batches 1–4's records
(batch 2's classifier exclusion + `TrashGrouping`, batch 3–4's
inspector idiom and walk-pin technique are your precedents).

**Scope — rows 16, 23, 24, 30 + batch 4's routed flags 2 and 3
(adjudication above).** Fences: **ZERO SCHEMA — hard.** V1's
classifier is a BIRTH FACT (`archived_at == created_at`, ONE clock
call, + the `version_of` edge), never a column; anything firming
toward a column is a §12 STOP. Zero `Sources/VariorumCore/Sync/` —
**and note V3 carefully: the bridge engine lives in `Sync/`-adjacent
code; if the duplicate-day fix cannot land outside
`Sources/VariorumCore/Sync/`, STOP that half and report — the
standing rider routes engine surgery elsewhere.** Tutorial content
is batch 6's.

- **The save door (G1/V5/V4b):** "Save a Version" — **⌘⇧S** (free,
  verified at kickoff) + a note ▾ menu item + a `.palette` door,
  registry-declared. ONE transaction: a `duplicateAsVersion`-shaped
  FULL family copy (blocks · takes · comments — V7's honest cost,
  chosen) minted **ARCHIVED + SEALED at birth** (`archived_at ==
  created_at` from one clock call — the classifier; the seal is the
  freeze, the archive the hiding, the edge the classification —
  V4b's three-mechanisms line). No title mutation (V6) — the
  listing shows DATES via derived display. Compose as an
  operations-layer composite (`Operations`), zero new concepts.
- **The listing (G1):** **Note ▸ Versions** — an inspector occupant
  on batches 3–4's idiom (the side-panel theme; propose differently
  in-record if the IA argues), opened from note ▾ "Versions…" (+
  palette). Dated rows, derived display, openable (read-tier),
  **RESTORE** and **PROMOTE** per row, **Delete** per row (→ the
  Trash, grouped under its note — FOUND-ITEM 1's ratified shape;
  Put back returns it to the listing). The listing must render
  AUTOMATED versions indistinguishably except labeling (13w's
  future — the brief's constraint).
- **RESTORE (V4, her eighth-sitting ruling made S2-safe — the
  ledger row's letter):** identity-preserving, ONE transaction:
  (1) save a fresh born-archived version of NOW first, (2) the
  live note's content becomes the chosen version's — same
  container, same identity, same books/memberships; the OUTGOING
  blocks take the **DELETE NOW road** (tombstone + purge intent
  per family, in the restore's own transaction — never a raw row
  DELETE); the incoming content is a fresh family copied from the
  version (the version itself stays sealed/archived/untouched).
  Fully repeatable. Flush the pending buffer first (the batch-2
  NoteDeletion flush precedent — the version of NOW must carry
  the keystrokes).
- **PROMOTE:** unarchive + unseal → the copy leaves the listing
  and is first-class forever (the classifier holds by derivation:
  a later re-archive stamps a NEW `archived_at ≠ created_at`).
  Pin that derivation.
- **VERSIONS RIDE THE NOTE'S DELETION (V2, ratified):** the
  note-delete act extends — its compound tombstones each of the
  note's version containers in the SAME transaction (design the
  exact stamp story so `restoreContainer`/Put back revives the
  note WITH its versions, and independently-dead versions stay
  dead — the 13l exact-stamp doctrine); the confirm gains ONE
  honest line ("its N saved versions go with it") — NO dialog
  (her ruling verbatim in V2). Empty-versions notes read
  unchanged. The Trash's note group shows the versions (batch 2's
  `TrashGrouping` extends).
- **Row 24 — V3's MUST-PIN:** a version copy of a JOURNAL note
  must never trip the bridge's duplicate-day pause. VERIFY which
  way `duplicateAsVersion` + the day sweep compose TODAY, then
  pin it whichever way is true after your build (exclude archived
  from the day scan, or drop `entry_date` on version copies — your
  design detail, the pin is mandatory; mind the `Sync/` fence
  above).
- **Row 30:** the Trash's nested-ancestors run gains a
  dropdown-arrow disclosure — EXPANDED by default, collapsible
  (her ruling verbatim in the sitting record).
- **Routed flag 2:** `TakesViewModel` adopts the
  receipt-vs-refusal `Status` split (behavior-preserving; the
  boards' slots stop reading receipts as alarms). **Routed flag
  3:** `BridgeStatusViews`' literal red — fix via the tone/token
  plumbing if clean, else record for the closeout.
- **Search scopes (V1's fifth-sitting ruling):** verify the built
  exclusions hold (main search = live; Archived search =
  non-version — batch 2); versions searchable ONLY inside the
  note's Versions context; write the 13o handoff note in your
  record.

**Discipline:** the standing loop — red-on-old by behavioural
revert (the deletion-ride and restore are bug-class-adjacent:
pin the exact-stamp revival, the flush, the Delete Now road's
invisibility-at-once, the classifier edges); walk-driven pins on
the real mounted surface (AppKit class names — the AX tree is
empty in the test host); spine green BY TYPE NAME; full four gates
with counts quoted (mobile runs — `Shared/` is touched; baselines
now core 1384/144 · Mac 1741/294 · spine 63/8 · mobile 486/78);
**a live real-store instance exists (DerivedData Release, PID
98884) — by store: never address it, no install acts, suites may
run beside it**; commits by theme, staged by explicit path, NEVER
push. **Append "### BATCH 5 — RECORD"**, flip rows 16, 23, 24, 30,
and STOP.

### THE ARCHITECT'S ADJUDICATION OF BATCH 5's FLAGGED ITEMS (2026-08-25, before batch 6 dispatches)

1. **PROVISIONALs 1, 2, 4 (restore takes stranded ancestors on the
   Delete Now road · a version put back alone becomes an ordinary
   archived note · restore confirms):** all three STAND — each is a
   derivation from her rulings (the eighth-sitting instant-hard-
   delete + "ancestors die with you"; the classifier; the
   confirmation-consistency principle's container-scale clause) —
   and all three join the CHECKPOINT BUNDLE for her to feel and
   strike at will.
2. **PROVISIONAL 3 (Empty Trash counts a version as "a note") →
   FIXED in batch 6** as a copy-honesty rider: the confirm/receipt
   counts name saved versions when present (the
   door-shows-what-it-takes principle, G6's letter).
3. **The 1-of-3 `TakesSlotDragTests` red:** recorded as a THIRD
   flake candidate (the real-mouse-drag class beside
   `PoolDragTests` and the latency pin); passed isolated and on
   re-run; nothing batch 5 touched reaches it. **A second red in
   any later run this round promotes it to a KnownIssues row
   (owner 12)** — the ladder and batch 6 watch for it.
4. **The parity note (the phone owes a Versions face):** closeout's
   mobile update (row 13), joining the archive/trash-separation
   design-session note.
5. **The 13o handoff** (the one classifier both search scopes
   read): recorded in batch 5's record; the closeout carries it
   into 13o's row/plan.

**THE CHECKPOINT BUNDLE (final form — hers at the taste
checkpoint):** the came-from wording ("Bring back") · the came-from
tray door on unclocked rows · restore-takes-ancestors ·
version-put-back-alone-goes-ordinary · restore's confirm · the
walk of everything built (the pane, the tray panel, and the
Versions listing are HAND-CHECK items — `ImageRenderer` cannot
draw a `List`, so no automated screenshot covers them).

### OVERNIGHT AUTHORIZATION (author, 2026-08-25 — recorded verbatim-faithful for any successor)

Her words: *"I'm going to sleep now, so proceed through the end
without gating on questions for me. please leave a note with
everything that I should look over - since your context is full, I
tend to not wake large contexts on a cold cache. I'll look over
everything and all the changes in the morning and probably handle
any fixes in a new session or a different phsae."*

What this authorizes and shapes: the round runs THROUGH THE END —
batch 6 → the ladder → fixes → closeout — with NO author gating;
ambiguity is PROVISIONAL-and-continue (the standing author-only
hard stops still bind). **The CHECKPOINT BUNDLE converts to the
AUTHOR HANDOFF NOTE** (`notes/handoffs/post-13l-polish-round-handoff.md`),
self-contained for a fresh morning session — her checklist at the
top, every look-over item, every PROVISIONAL, the hand-check
surfaces, and the fixes-land-elsewhere expectation (a new session
or another phase — this session is not to be woken). The
`/Applications` refresh stays authorized (her earlier ruling);
the A1 rail and zero-instance check bind as always.

### BATCH 6 — THE TUTORIAL: the brief (fresh Opus session; dispatches after batch 5's record; the round's LAST build batch)

**Read in full first:** `CLAUDE.md` + canon · THIS FILE top to
bottom — your letter is ledger rows **12 (D2) · 19 (G4) · 26 · 27 ·
33**, §D2's binding catch, the NORTH STAR five-places map in the
kickoff message, and EVERY batch record above (you are teaching
what batches 1–5 built — the doors as they ARE, not as any older
lesson remembers them) · the 13j **Environment traps** (binding
verbatim) · the tutorial machinery itself (`TutorialSeeder`,
`TutorialWalkTests` — P-6: the tutorial is the executable spec;
your chapter GROWS the spine).

**Scope — rows 12, 19, 26, 27, 33 + two riders: A7's one merge
sentence (§A — her declined per-merge message; the tutorial
carries the teaching instead) and adjudication 2 above (Empty
Trash's counts name saved versions).** Fences: zero schema · zero
`Sync/` · NO re-seed of her real store (that is the CLOSEOUT's,
behind the A1 rail) · the fanned cross-block matrix is 13u's (row
27's letter — teach today's truth including shipped
merge-then-edit, and stop there).

- **Row 33 FIRST (the small build):** the Block History pane's
  current-block jump — when the caret sits in a different block
  than the pane shows, a small in-pane button jumps to the current
  block's history (her words in the sitting record: no
  close-and-reopen). Walk-driven pin on the real surface.
- **Row 12 (D2):** the field guide's deletion chapter teaches the
  OLD doors — rewrite its content to the built truth: the tray
  ICON + ⌫ badge (not the note ▾ item) · the Library's Trash icon
  (not the ⋯ menu) · the Archived sidebar surface · takes never in
  the global Trash (their homes: Block History + the tray's
  leaving section) · Empty Trash's exact-rows scope. Spine
  re-pins to the new content. A7's rider lands here: ONE sentence
  on where a merge's originals live (the came-from region).
- **Row 19 (G4, her words in the ledger):** a NEW chapter teaching
  the FIVE PLACES — *where you left it · Archive (notes, forever)
  · the Trash (notes·books·blocks, 30 days) · this note's
  Versions · this block's History* — **each visited by the walk**
  (the lesson takes the reader to each surface), plus the
  take-savepoint story made EXPLICIT: the commit↔history
  bottom-chrome pairing is the teaching moment (write a moment
  with ⌘S, see the moments beside it).
- **Row 26:** the same chapter teaches **⌘S vs ⌘⇧S** — this
  TAKE's moment vs this NOTE's moment; the grain pairing is
  itself the lesson.
- **Row 27 (her eleventh-sitting mandate, verbatim in the
  ledger):** the TWO-EXITS lesson, **taught by DOING** (her idea,
  adopted): the lesson walks the user through (1) deleting a
  whole block and finding it in the Trash/tray with Put back,
  then (2) making an edit that merges two blocks and finding the
  originals in the new block's History came-from, one button
  back. "Deletion goes to the Trash; transformation goes to
  lineage." Covers today's truth incl. shipped merge-then-edit;
  the merge itself stays silent (her declined P-2).
- **The Empty-Trash counts rider:** the confirm and receipt name
  saved versions when the Trash holds them ("2 notes, 1 saved
  version, 3 blocks go for good") — shared copy home, both
  surfaces.

**Discipline:** the standing loop — the spine green BY TYPE NAME
and GROWN (the new chapter's steps are walk-asserted; a broken
step is a regression by definition); red-on-old where bug-class;
walk-driven pins for row 33 (AppKit class names — the AX tree is
empty in the test host); full four gates with counts quoted
(mobile runs if `Shared/` is touched; baselines now core 1402/146
· Mac 1754/295 · spine 63/8 · mobile 486/78; the flake watch:
`TakesSlotDragTests` at ONE recorded red — a second promotes it);
instance check before build-adjacent acts; commits by theme,
staged by explicit path, NEVER push. **Append "### BATCH 6 —
RECORD"**, flip rows 12, 19, 26, 27, 33, and STOP — the ladder
dispatches next, then the closeout.

### BATCH 6 — RECORD (Opus implementer, 2026-08-25)

**Three commits, staged by explicit path, none pushed.** Tree clean at start
(`d078887`) and at finish. A separate brand session committed `39ab7dd` and
`0e6da79` in the same window; nothing under `notes/brand/` was read, staged or
touched here.

| commit | theme |
|---|---|
| `aa47d6d` | the pane's current-block jump — row 33 |
| `5aeea41` | Empty Trash's counts name saved versions — the adjudication-2 rider |
| `2c16797` | the tutorial — rows 12, 19, 26, 27, and A7's merge sentence |

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1402 tests / 146 suites PASSED** (36.4 s) | 1402/146 ✔ exact — no core line changed this batch |
| Mac full (`-project`, `platform=macOS`) | **1764 / 296 PASSED — TEST SUCCEEDED** (233.9 s, zero reds) | 1754/295 → **+10 tests, +1 suite** (`TutorialWherePlacesActsTests`) |
| **Mac spine (`TutorialWalkTests` types, suite-level `-only-testing`)** | **68 / 9 PASSED — TEST SUCCEEDED** (27.4 s) | 63/8 → **GROWN: +5 tests, +1 type** |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (83.9 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**ALL THREE FLAKE CANDIDATES SILENT** in the full Mac run — the Phase-12
latency pin, `CanvasDragTrackingTests`, and `TakesSlotDragTests` (batch 5's
third candidate). **No second red**, so nothing is promoted; the run had zero
reds of any kind.

**Fences held:** ZERO schema · ZERO `Sources/VariorumCore/Sync/` · ZERO
`Sources/` lines of any kind — the whole batch is app-target + `Shared/` +
tests · **no re-seed of her real store** (the closeout's, behind the A1 rail)
· no Release build, no `/Applications` act · the fanned cross-block matrix
untouched (13u's — row 27's letter).

**INSTANCE CHECKS.** `pgrep -fl 'Variorum.app/Contents/MacOS'` was empty at
the batch's start and before every build and every full run. No install act
was owed or taken.

---

#### Row 33 — the pane's current-block jump

**The shape.** Her ruling ratified the pane's REQUEST scoping and asked for
the one way out of it, so the door is exactly that and nothing more. Three
pieces:

- **A FACT, not a request.** `FocusedBlock` (post · block · take) is what a
  mounted writing surface REPORTS; `CommandRouter.focusedBlock` holds it,
  observable, beside the three panel seams batches 3–5 opened. It is its own
  type rather than a `BlockHistoryRequest` deliberately — a fact that could be
  mistaken for a request invites a surface to open a panel by reporting a
  caret move.
- **A PURE RULE.** `BlockHistoryModel.jumpTarget(_:postID:blockID:)` — same
  note, different block, or nothing. Everything else is no door at all (P-2):
  an unknown caret, another note's caret, a caret in the block on screen. It
  returns a ready-made request, so the take she is standing in rides along and
  her *"the focused take's expanded"* ruling survives the jump.
- **A DOOR THE HOST ANSWERS.** `onJump` beside `onOpenTray`, for its reason:
  the pane is scoped by its request, so re-scoping is the host's act. The
  inspector swaps its own case (the `.id` rebuilds the pane on the new block);
  both sheet hosts swap their pending request.

**Cheapness, by construction.** Both surfaces report inside a changed-BLOCK
guard — Write in `updateCaretContext` (the same guard the editing-indicator
pass uses) and the boards at `TakesViewModel.focus`, the ONE authority door
(P-3), so Takes and Lenses both feed it without a second liveness mechanism.
The router assigns only on a real change. A caret walking inside one paragraph
therefore writes nothing and re-renders nothing.

**Registry (P-1): nothing to declare, and the precedent is stated rather than
assumed.** The jump re-points a panel — NAVIGATION, which batch 2's record
already ruled lives in composition and not the registry (`RootView
.wirePaletteCommands`' own stated rule), and the came-from region's *Open this
note's tray* button is the same class one region down.

**Pins** (`BlockHistoryPaneTests`, +4):
`theJumpOffersItselfOnlyWhenTheCaretIsInAnotherBlockOfThisNote` (the rule's
four readings) · `theCaretFactIsRecordedForTheOpenNoteAndNobodyElse` (a
background pane's caret never speaks for the note on screen; the fact leaves
with the note) · **`movingTheCaretIntoAnotherBlockReportsItToTheRouter`** (the
plumbing, through a REAL editor and a real caret move) ·
**`theMountedPaneDrawsItsJumpDoorOnlyWhenTheCaretIsElsewhere`** (walk-driven).
**RED ON OLD**, two behavioural reverts in one run (the button gated off; the
editor's report gated off): `focusedBlock → nil` and `(elsewhere → 1) == (here
+ 1 → 2)`.

**ONE MEASURED HARNESS FACT, recorded at the pin because it cost the time and
will cost it again.** The walk-driven pin mounts the pane TWICE rather than
toggling the caret under one mount, because **this headless host does not
rebuild a hosted tree in place on an `@Observable` change**. I did not assume
that: the first version of the pin toggled in place and read 1 → 1, so I
probed with a change that has nothing to do with row 33 — adopting a history
carrying a deleted take, which adds a Put back button — and the count stayed
at 1 through a full settle as well. Mounted fresh with the caret elsewhere,
the pane draws the door every time. **It is the host, not the read** — and it
is also why batch 4's Aa pin mounts its bar twice instead of toggling the
fold, one screen up in the same file.

---

#### The Empty-Trash counts rider (the architect's adjudication 2)

**Batch 5 recorded the defect in its own words** — *"the sentence reads '3
notes go for good' when one is a moment"*. The total was never wrong: a
version IS a `.note`-kind row and it really does go. What was wrong is that
the one sentence whose whole job is to show exactly what the door takes (G6)
counted a note's PAST among the notes, while the grouping one line below it
says which rows are moments.

**Build:** `versions` is read from the row's own `version_of` link (the
projection already carries it — nothing re-derived), and the receipt reads it
back from the **act-time** listing rather than the confirm's, because a confirm
is a pause (the R3-1 lesson). Both `versions:` parameters are **defaulted to
zero**, which is what batch 5 feared would be impossible: a Trash holding no
moments reads byte-identically to what shipped, and every pin asserting one
rode unmodified.

**Two shipped pins edited in place, both mechanical:** the `Confirm.emptyTrash`
case gained a member, so `case .emptyTrash(let counts)` becomes `(let counts,
_)` in `TrashPurgeDoorsTests` and `IAAndTrashShapeTests`. Neither claim moved.

**Pin:** `IAAndTrashShapeTests
.emptyTrashCountsANotesSavedMomentAsAMomentAndNotAsANote` — a note and its
saved moment, both in the Trash, through the real confirm and the real act.
**RED ON OLD** (both `versions:` ignored): *"Empty the Trash? 2 things go for
good: 2 notes."* reads back, and the receipt names nothing.

---

#### Rows 12 · 19 · 26 · 27 — the tutorial

**THE NEW CHAPTER: "where things go"**, three lessons, seated immediately
after the deletion chapter — because it is that chapter's question widened.
The reader has just learned where a deleted block goes; the honest next
question is where everything ELSE goes, including the two places this round
built and the one the app never had to build.

- **"the five places"** — the map, each place visited: *where you left it ·
  Archive (notes, forever) · the Trash (notes · books · blocks, 30 days) ·
  this note's Versions · this block's History*. It names what each place
  promises about TIME, because that is the only thing that tells them apart,
  and it says out loud the one nobody says — a note you wrote and did nothing
  else to is where you left it. The take's absence from the Trash is taught as
  an ANSWER (its block's History is its home — her D1 ruling), never a hole.
  A `PRACTICE ME` block is staged for the history door.
- **"saving a moment"** (row 26 + row 19's savepoint half) — the grain
  pairing: ⌘S saves this TAKE's moment, ⌘⇧S saves this NOTE's, *"one grain
  apart, one shift key apart"*. Her G4 teaching moment is the paragraph that
  follows: commit WRITES a moment and history SHOWS them, side by side in the
  bottom chrome, *"so the bar reads as the block's own time controls"*. Then
  Restore's append-only promise, ⌘⇧S's Versions listing with Restore and
  Promote, which key to reach for, and the quiet savepoints leaving a note
  takes for her. A `PRACTICE TAKE` block is staged for ⌘S.
- **"the two exits"** (row 27, TAUGHT BY DOING as she suggested) — the rule
  first, in her shape: **DELETION GOES TO THE TRASH; TRANSFORMATION GOES TO
  LINEAGE.** Then the reader does both. `EXIT ONE` is triple-clicked and
  deleted, and found in two listings of one fact (the tray's Leaving section,
  the Library's Trash) with Put back in either. `EXIT TWO`'s two halves are
  joined by selecting across the seam and pressing ⌫ — an ordinary edit — and
  the joined block's **Came from** lists BOTH originals, each with **Bring
  back**. The lesson then says what did NOT happen: nothing counted down,
  nothing was in the Trash, nothing announced itself — *"a message on every
  join would be noise, and this panel is the app keeping its side of that
  bargain"* (her declined P-2, from the other end). It closes on the one place
  the two exits meet: an original has no clock only while a descendant lives.
  **The fanned cross-block matrix is not taught — 13u's, per row 27's letter.**
  Both staged halves are deliberately SINGLE-TAKE, because a cross-block edit
  joins the halves only where no fan hangs on the seam (the #11a ruling), and
  the staging pin asserts exactly that so a future take added to either one
  fails loudly instead of quietly breaking the lesson.

**THE RE-TEACHING (row 12).** Batches 2–4 made mechanical door-path
corrections and left the re-teaching here; two things were still being taught
that the app had stopped doing:

1. **"No door inside a note ever deletes something for good"** — an absolute
   her G5 ruling superseded when the note's own Leaving section gained Delete
   Now *"to keep the capability"*. The lesson now teaches the rule that
   replaced it: ending something early lives in exactly two kinds of place —
   the Trash, and a note's own trash section — and **nowhere you write**. The
   pin checks that sentence against the two surfaces' own capability tables
   (`TrayPanel.surfaceCapabilities` carries `.deleteNow`; `BlockHistoryPane`'s
   does not), so the lesson is verified against the app rather than against
   itself.
2. **The books lesson still sent her to "Library ▸ Archived & Deleted"** — a
   menu B1 dissolved, three chapters away from the change that dissolved it.

**A7's rider** landed in *"what a block leaves behind"*: one paragraph saying
that merging keeps its blocks the same way divide does, **says nothing at the
time on purpose**, and lists BOTH (or all three) in `Came from` with their own
Bring back. Her declined per-merge message is thereby carried by the tutorial,
which is exactly the trade she named.

**A found-by-the-walk detail, worth recording because it is the class:**
adding A7's paragraph shifted the staged-take index in that lesson
(`past.blocks[3]` → `[4]`), and the SPINE caught it — two assertions in
`theDeletedSpareTakeWaitsInTheBlocksPastAndComesBack` went red on a fan of 1.
A seeder that stages by index is exactly what P-6 exists to guard, and it did.

**Pins.** New suite `TutorialWherePlacesActsTests` (5):
`everyPlaceTheChapterNamesIsAPlaceTheAppHas` (every place and door read from
its own constant — the deletion chapter's J8-bar pin, one chapter down) ·
`theMapsChapterIsStagedForItsActs` (incl. the adjacency and single-take
conditions the join needs) · `theFivePlacesAreFivePlacesTheAppReallyHas`
(archive → ARCHIVED and never the Trash → back to the Library; a block's
30-day row; a saved version in NEITHER global listing; a savepoint in its
block's History) · `theTwoSavesKeepTwoSizesOfMoment` (both doors driven; the
note's moment carries every block, not the one she was in; the chords really
are shifted twins) · **`theTwoExitsLandInTwoDifferentPlaces`** (the lesson's
own two gestures, and the assertion that transformation leaves NO clock and NO
Trash row, then `Bring back` really putting the original into the note).
Strengthened in place: the deletion chapter's door pin gained the purge-door
rule and A7's two sentences.

**RED ON OLD** (both corrected paragraphs restored to their shipped text): 4
issues, reading the retired absolute and the missing merge sentence back.

**THE SPINE: 63/8 → 68/9, green.**

---

#### OBSERVATIONS — nothing built, for the architect

1. **The closeout still owes the RE-SEED of her real store's field guide**
   (row 12's second half, row 13). This batch changed lesson CONTENT in three
   chapters, so her installed copy teaches the old doors until the closeout
   re-seeds it through the product door behind the A1 rail. Row 12 is flipped
   as *done (lessons + spine)* to keep that visible.
2. **The three panes are still hand-check items for the visual loop** (batch
   4's finding: `ImageRenderer` draws a placeholder for `List`-backed views).
   Row 33's door joins them — its position in the header, above the status
   line and below the explainer, is unverified by eye. It is one control on a
   surface already on the checkpoint's hand-check list.
3. **The tutorial's word target is unchanged at 4 000** while the book grew a
   chapter; nothing asserts the total, and the shelf row's progress face will
   simply read further along. Recorded rather than adjusted — the number is
   hers.
4. **The new chapter teaches Versions before the "compare & versions" lesson**
   (which is two chapters later and is about a different thing — the
   `version_of` LINK between two live notes). The two words now name two
   different features in one book. The map lesson says *"it is not another
   note, it is this note's past"*, which is the distinction stated; whether
   the older lesson wants a sentence pointing at the newer one is a taste call
   and is left for her checkpoint.
5. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/`, `App/Variorum/Shared/`,
   `App/Variorum/VariorumMobile/` and `Sources/VariorumCore/` returns only the
   two pre-existing doc comments (`NoteWindowView`, `QuickNoteView`).

### THE END-OF-ROUND LADDER — ROUND 1 (fresh Fable cold reviewer, 2026-08-25): findings, recorded repo-first before any fix session sees them

Reviewer ran `notes/REVIEW_PROMPT.md` verbatim (round-name
substitution only), zero framing; its own suite runs: core 1402/146
PASSED · Mac full TEST SUCCEEDED, zero reds, all three flake
candidates silent.

**[BLOCKER · LR1-1] `Queries/NoteVersions.swift:94–112` +
`Queries/Timeline.swift:227–243` — the versions classifier rides
the note's FIRST-BLOCK anchor through LIVE placements, so everyday
gestures on the note's first block silently EXPEL every saved
version from Note ▸ Versions into the Archived surface, orphan
them from the V2 deletion ride, and make Restore/Promote refuse.**
Mechanism (reviewer-traced, full detail in its report):
`saveNoteVersion` → `copyPost` anchors the ONE `version_of` edge
on the note's first block; the classifier requires a LIVE
placement of that block in the note AND a live edge — but merge /
divide-W tombstone the source placement, `archiveBlock` tombstones
the placement, `deleteBlock` cascade-tombstones the EDGE,
`moveBlock` rewrites `container_id`. Any of these on the first
block (incl. the shipped seam-⌫ join the round's own tutorial
teaches) flips the predicate: the version leaves `noteVersions`,
LISTS in `archivedPosts` (V1 falsified both ways), escapes
`noteVersionIDs` (V2's "an unclaimed version can no longer exist"
falsified), and `isVersionHistory` refuses Restore/Promote;
ArchivedView's Unarchive on the leaked row mints a live SEALED
duplicate she never sealed. Only `restoreNoteVersion` re-anchors;
no structural op does. Red-on-old shape: save a version → merge
blocks 1+2 (or archive block 1) → assert the listing keeps it and
Archived excludes it — fails on this tree. Proposed fix (zero
schema, zero `Sync/`): classify the note side by container
identity read PAST placement tombstones (the shape the deleted
road already uses), the "live note" half carried by the
container's own `deleted_at IS NULL`; and/or re-anchor on
structural consumption. Rider: the same fragility mis-homes
`versionOfNote` (Trash grouping) after an anchor moves container.
*(The anchor fragility predates the round — QUESTIONS #19 — but
the round built the classifier, exclusion, deletion ride, and two
door authorizations on it; the stakes changed class.)*

**[MAJOR · LR1-2] `Operations+NoteVersions.swift:72–73 / 241–253`
— a version is SEALED without the seal doctrine's insurance
commit, so PROMOTE hands back a note whose takes carry ZERO
savepoints; one edit after promote can destroy the moment's text
unrecoverably.** AppSpec §9's ruled doctrine (lockPost/lockVariant:
"the guard insures exactly what it protects"). Concrete loss: T
saved as version → note edited away from T → Promote → one edit →
T gone, no savepoint, no Trash row. Fix: one quiet auto-commit per
copied take in the mint's transaction (the sealing-a-post occasion
APPLIED, not a new occasion), or insurance at promote before
unsealing. Red-on-old: promote → each take carries a savepoint of
the moment's text — red today.

**[MAJOR · LR1-3] `MobileTrashModel.swift:81–90` + the batch-2
record — the PHONE lost its only deleted-take surface for an
OPEN-ENDED window; the record's "in-round only" transient claim is
FALSE for the phone.** The shared `TrashScope` removed the phone's
take rows; the Mac's replacement homes are Mac-only; the phone's
equivalents are mobile batch 6, paused until after 13u by her
ruling. A take deleted on the phone is invisible and
un-restorable ON THE PHONE while its clock runs (Mac-recoverable).
Fix half: correct the record; name the dark window in the
closeout's mobile update + MobileSoul line + her handoff. Product
half (interim phone rows vs wait for batch 6): HERS — handoff.

**[MINOR · LR1-4]** per-row Delete Now is version-blind: a
saved-version row's confirm says "note"; a NOTE's Delete Now
doesn't take (or mention) its version rows (`expandContainer` is
`Sync/`-fenced this round — versions linger their window, and
post-purge the orphaned rows degrade to anonymous "note" labels).
Fix the WORDING half now (an `isVersion` confirm arm + one honest
clause); the purge-family expansion routes to a `Sync/`-owning
phase via KnownIssues at closeout.

**[MINOR · LR1-5]** the classifier is NOT written once —
`archivedPosts`' fence is an inline near-copy of
`versionHistoryPredicate` (with real structural differences); the
BLOCKER's fix would have to land twice. Fold onto the shared
predicate; correct batch 5's record before 13o inherits its claim.

**[MINOR · LR1-6]** restore never rebaselines churn —
`baseline_length`/`churn_accumulator` describe the pre-restore
text after a whole-content swap (§10's threshold runs against a
phantom baseline). One-line fix in step 5; pinnable.

**[MINOR · LR1-7]** Promote is the pane's only permanent one-way
act and the only row act with NO confirm (product-flavored — HERS;
handoff, not fixed autonomously).

**[MINOR · LR1-8]** ledger bookkeeping: rows 14, 17, 28, 29, 31,
32 carry "done + hash" in the item cell while the STATUS column
reads "open". Reconcile (mechanical).

**[NIT · LR1-9]** Terminal's `positive` is byte-identical to
`accent` (== `chosen`'s hex) while the token doc claims
distinctness — the doc's claim is false for the leading voice, and
the settled sync line wears the "✓ chosen" hue. Fix the doc's
honesty (hues themselves are 13s's) or nudge the hue; the fixer's
call, PROVISIONAL fine.

**[NIT · LR1-10]** `RecoveryView.swift:617` `ForEach(…enumerated,
id: \.offset)` — positional row identity in a reordering listing
(identity churn only; disclosure state safely keyed). Small fix or
record.

**Clean bill (reviewer's, abridged):** fences held (zero schema,
zero `Sync/` verified by diff; the classifier birth-fact
mechanism sound); V3's pin real against the real engine;
`restoreNoteVersion`'s transaction shape, S2-safety, re-anchor,
refusals, repeatability all verified; the versions-ride in the
OPERATION with exact-stamp both ways; `TrashScope`/G6/G7 honest
and pure; confirm→act discipline honored at every new door;
registry declarations real; the batch records "unusually honest —
verified claims matched the tree everywhere probed."

**THE ARCHITECT'S ROUTING (recorded before the fix wave):** the
fix wave owns LR1-1 (+ its LR1-5 fold, ONE classifier), LR1-2,
LR1-3's record half, LR1-4's wording half, LR1-6, LR1-8, LR1-9,
LR1-10. HERS via the handoff: LR1-3's product half (interim phone
take rows?), LR1-7 (Promote confirm), and batch-5 PROVISIONAL 1
(the reviewer's emphasis: restore's Delete Now takes stranded
ancestors whose fan texts then survive nowhere — "the sharpest
thing on her list", verbatim into the handoff). CLOSEOUT:
LR1-4's purge-family KnownIssues row (owner decided there).

### THE LADDER FIX WAVE: the brief (fresh Opus session)

**Read in full first:** `CLAUDE.md` + canon · THIS FILE top to
bottom — the ROUND-1 FINDINGS + ROUTING above are your letter; the
batch records are your map of what was built · the 13j
**Environment traps** (binding verbatim). Scope: exactly the
routed findings (LR1-1 with LR1-5's fold · LR1-2 · LR1-3's record
correction · LR1-4's wording arm · LR1-6 · LR1-8 · LR1-9 ·
LR1-10). Fences unchanged: ZERO schema · ZERO
`Sources/VariorumCore/Sync/` (LR1-4's expansion half is
explicitly NOT yours) · nothing product-flavored (the routed
HERS items are not yours to build).

**Discipline:** the hallucination guard at full strength — TRACE
each finding's mechanism yourself before fixing (a finding you
cannot reproduce/trace goes back as disputed-with-reasons, never
silently dropped); every bug-class fix lands with a red-on-old pin
VERIFIED BY BEHAVIOURAL REVERT (LR1-1's pin shape is written in
the finding; LR1-2's likewise); the spine green BY TYPE NAME; full
four gates with counts quoted (mobile runs — `Shared/` and the
mobile record claim are touched; baselines: core 1402/146 · Mac
1764/296 · spine 68/9 · mobile 486/78; flake watch: three
candidates, a second red on any promotes at closeout); instance
check; commits by theme, explicit paths, NEVER push. **Append
"### LADDER FIX WAVE — RECORD"** with per-finding dispositions
(FIXED + pin + revert evidence, or DISPUTED + trace), reconcile
the ledger cells (LR1-8), and STOP — round 2 re-reviews next.

### LADDER FIX WAVE — RECORD (fresh Opus session, 2026-08-25)

**Two commits, staged by explicit path, neither pushed.** Tree clean at start
(`c6972eb`) and at finish.

| commit | theme |
|---|---|
| `bf7fe04` | the STORE half — LR1-1 (+ LR1-5's fold), LR1-2, LR1-6 |
| `12b5942` | the FACE half — LR1-4's wording arm, LR1-9, LR1-10 |

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1411 tests / 146 suites PASSED** (35.8 s) | 1402/146 → **+9**, my nine new core pins; suite count unmoved |
| Mac full (`-project`, `platform=macOS`) | **1768 / 296 PASSED — TEST SUCCEEDED** (233.1 s, zero reds) | 1764/296 → **+4**, my four new Mac pins; suite count unmoved |
| Mac spine (9 `TutorialWalkTests` types, suite-level `-only-testing`) | **68 / 9 PASSED — TEST SUCCEEDED** (27.0 s) | 68/9 ✔ exact |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (85.4 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**ALL THREE FLAKE CANDIDATES SILENT** in the full Mac run — the Phase-12
latency pin, `CanvasDragTrackingTests`, and `TakesSlotDragTests`. **No second
red**, so nothing is promoted; the run had zero reds of any kind.

**Fences held:** ZERO schema (the classifier is still the birth fact and the
`version_of` edge — no column came near) · ZERO `Sources/VariorumCore/Sync/`
lines (LR1-4's purge-family expansion was NOT attempted — it is `PurgeFamily`'s
and it is fenced) · nothing product-flavored built (LR1-3's product half and
LR1-7 are hers, untouched) · nothing under `notes/brand/` read, staged or
touched.

**INSTANCE CHECKS.** `pgrep -fl 'Variorum.app/Contents/MacOS'` was empty before
every `build-for-testing` and before every full Mac run. No Release build, no
`/Applications` act was owed or taken.

**One method note, because it shaped the evidence below.** Every bug-class
finding here was pinned FIRST and run against the pre-fix tree, so the
"behavioural revert" is the natural order rather than a re-enactment — the OLD
behaviour under the pin is the tree the reviewer read. Where a fix had already
landed (LR1-4) the revert was performed explicitly and is recorded as such.

---

#### LR1-1 (BLOCKER) — the classifier rode the first-block anchor · **TRACE CONFIRMED · FIXED**

**Traced myself against the tree before touching anything**, and it is worse
than a listing bug: `saveNoteVersion` → `copyPost` mints ONE `version_of` edge
anchored on the note's FIRST live placed block (`Operations+Versions.swift`,
`outcome.firstPair`), and `versionHistoryPredicate(liveOnly: true)` required
**a live placement of that block in the note, a live placement of its twin in
the version, and a live edge**. Each of those is ordinary prose under her
hands:

| gesture | what it does to the anchor | verified where |
|---|---|---|
| `merge` / `divideW` | releases the source placement — tombstoned, `last_container_id` stamped | `Operations+Structural.swift:379/554/686/945` |
| `archiveBlock` | tombstones the placement, stamps `last_container_id` | `Operations+BlockArchive.swift:75-80` |
| `deleteBlock` | the trigger cascade tombstones the **EDGE** | `Persistence/Triggers.swift:44` (`cascade_block_tombstone`) |
| `moveBlock` | REWRITES `container_id` in place — no tombstone, no stamp | `Operations+Placement.swift:171-200` |

**RED ON OLD, measured (three pins written first, run on `c6972eb`):**
`mergingTheNotesFirstBlockKeepsItsMoments` — **4 issues**, the whole defect in
one test: the listing empty, the Archived surface holding it, `isVersionHistory`
false (so Restore and Promote refuse), `noteVersionIDs` empty (so V2's deletion
ride no longer claims it) —
`✘ Expectation failed: try db.read { try Queries.noteVersions($0, of: note.id) }.map(\.postID) == [version.id]` ·
`✘ !(try db.read { try Queries.archivedPosts($0) }.map(\.postID).contains(version.id))` ·
`✘ try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) }` ·
`✘ try db.read { try Queries.noteVersionIDs($0, of: note.id) } == [version.id]`.
`archivingTheNotesFirstBlockKeepsItsMoments` — **3 issues** (same first three, at
`:427/:429/:431`). `deletingTheNotesFirstBlockKeepsItsMoments` — **3 issues** (at
`:450/:452/:454`), the EDGE-cascade leg rather than the placement one.

**The fix, and why it is this one.** The note side now asks lineage's question —
**was this block this note's** — reading `container_block` past its tombstone,
which is the `strandedOriginals` doctrine verbatim (*lineage is a fact about
what happened*) and the reading `versionOfNote` has always used one screen down.
Liveness that still matters moved to where it belongs: the CONTAINERS
(`v.deleted_at`, and the peer's own `deleted_at` under `.anyLiveNote`).

**The edge needed a sharper rule than "read past it", and it got one.** A
`version_of` edge dies two ways that mean opposite things: the block cascade
(the copy still happened) and a deliberate `unmarkPostsAsVersions` (the pair
really did come apart — R60/R68's door, reachable from `CompareBoardView` and
`LibraryViewModel`). The cascade stamps the edge with its dead endpoint's OWN
`deleted_at`; the unmark stamps a time no endpoint shares. So the predicate
reads past **exactly the cascade signature** — the 13l exact-stamp doctrine,
the same one `versionHistoryDeletedWith` already leans on — and
`adeliberateUnmarkStillUnlinksAVersion` pins the other direction (it was green
before the fix and is green after, deliberately: it is the guard that proves
the tolerance is precise rather than blanket).

**moveBlock is the one leg no read-side means can answer, and it is PINNED as
documented behaviour rather than hand-waved.** It rewrites `container_id` in
place, so nothing survives saying the block was ever this note's; the moments
follow the anchor and read as the destination's (moved to a POOL they would list
nowhere, since only posts are asked). `movingTheAnchorBlockTakesTheMomentsWithItAndThatIsRecorded`
states today's truth so a later change that fixes it says so out loud instead of
passing quietly. **Not fixed here, deliberately:** re-anchoring inside
`moveBlock` would mint an edge during a placement move — a semantic change to a
structural op, which the friction doctrine says to DESIGN rather than patch —
and QUESTIONS #19 ratified this coarse anchor with *re-mark to relink* as the
escape, which version HISTORY has no door for. **A KnownIssues row now owns it
(owner 13w** — that phase owns this same listing and opens with its own design
sitting; the closeout may re-home it beside LR1-4's purge row**)**, naming #19's
option (c) — a post-level link, a schema call and hers — as the durable road.

**The `versionOfNote` rider is DISPUTED-as-already-true for three of its four
legs, and that is recorded rather than dressed up.** The finding says *"the same
fragility mis-homes `versionOfNote` (Trash grouping) after an anchor moves
container"* — and `versionOfNote` never had liveness fences, so merge, archive
and deleteBlock never touched it. I pinned it anyway
(`aDeletedMomentStillNamesItsNoteAfterAMerge`) as a guard, and it is **green on
both sides of the fix** — which by the hallucination guard's own rule is exactly
what a hollow finding looks like, so it is named as one. The rider's real
content is the words *"after an anchor moves container"*, i.e. moveBlock, and
that is the pin and the KnownIssues row above.

**Pins** (`NoteVersionsTests`, +6): `mergingTheNotesFirstBlockKeepsItsMoments` ·
`archivingTheNotesFirstBlockKeepsItsMoments` ·
`deletingTheNotesFirstBlockKeepsItsMoments` (incl. Put back leaving it
untouched) · `adeliberateUnmarkStillUnlinksAVersion` ·
`aDeletedMomentStillNamesItsNoteAfterAMerge` ·
`movingTheAnchorBlockTakesTheMomentsWithItAndThatIsRecorded`.

**Files:** `Sources/VariorumCore/Queries/NoteVersions.swift`,
`Sources/VariorumCore/Queries/Timeline.swift`.

---

#### LR1-5 (MINOR) — the classifier was not written once · **TRACE CONFIRMED · FIXED (folded into LR1-1)**

**Verified by reading both**, and the drift was structural, not cosmetic:
`archivedPosts`' inline fence required `mine.deleted_at IS NULL`,
`theirs.deleted_at IS NULL`, `e.deleted_at IS NULL` **and** a joined live peer
container of kind `post`; `versionHistoryPredicate` fenced the same three but
took a NAMED note and never looked at the peer container at all. Two questions,
two answers, one concept — and LR1-1's fix would have had to land in both.

**Fixed** by giving the predicate an `alias:` and a `peer:` (`.note` /
`.anyLiveNote`), and having the fence read it: `AND NOT
(versionHistoryPredicate(alias: "container", of: .anyLiveNote))`. The two scopes
are now exact complements *by construction* rather than by care.

**The signature changed** (`liveOnly:` is gone — tombstone tolerance and the
peer are separate questions now), so **batch 5's 13o handoff has been corrected
in place**: its claim that *"every scope reads it"* was not true when it was
written, and the correction says so and names the current signature, because
13o is meant to inherit that sentence.

**Pin:** carried by LR1-1's — every one of those six asserts BOTH scopes (the
listing keeps it AND Archived excludes it), which is what "exact complements"
means operationally.

---

#### LR1-2 (MAJOR) — a moment was sealed without the seal's insurance · **TRACE CONFIRMED · FIXED**

**Traced myself.** `copyFan` copies takes and never their commits (the
pool-drag rule, and right), and `mintNoteVersion` then set `locked = true`
directly — so the copy was sealed WITHOUT the auto-commit that AppSpec §9's
ruled doctrine attaches to sealing (*"the guard insures exactly what it
protects"*). The seal hid it, PROMOTE takes the seal off, and the first edit
afterwards overwrites `working_text` with nothing behind it: no savepoint, no
Trash row, no undo — the one unrecoverable shape in an app built so that
nothing is.

**RED ON OLD, measured** (pin written first, run on `c6972eb`):
`aMomentsTakesAreInsuredAtBirthSoPromoteCannotDestroyThem` — **3 issues**,
`✘ Expectation failed: (saved → []) == ([take.workingText] → ["The moment's words."])`
twice (both takes of the fan) and then the consequence itself,
`✘ (commits.map(\.text) → []) == (["The moment's words."])` — the moment's text
gone after one edit past a promote. `anEmptyTakeInAMomentTakesNoSavepoint` — **1
issue**, `((row["saved"] as Int) → 0) == ((text.isEmpty ? 0 : 1) → 1)`.

**The fix is the occasion APPLIED, not a new one** (the brief's design note, and
it is the whole reason it is three lines): `mintNoteVersion` calls
`autoCommitDirtyVariants(db, containerID: version.id, now: version.createdAt)`
— `lockPost`'s own helper — immediately before the row write that seals, in
`lockPost`'s own order (commit, then freeze). Consequences it inherits for free
rather than re-deciding: locked takes are skipped, a take whose buffer already
matches its last commit writes nothing, and an EMPTY take takes no savepoint
(`isDirty`'s answer, which is the landed-deletion rule from the bridge). Cost is
the fan's, never the corpus's; the stamps come from the copy's own
`created_at`, so the moment's savepoints carry the moment's time and no second
clock read enters the transaction (the birth fact next door depends on there
being only one).

**`restoreNoteVersion` inherits it** — step 1 is `mintNoteVersion`, so the
version-of-NOW a restore always saves is insured too.

**Pins** (`NoteVersionsTests`, +2): as above.
**Files:** `Sources/VariorumCore/Operations/Operations+NoteVersions.swift`.

---

#### LR1-6 (MINOR) — restore never rebaselined the churn · **TRACE CONFIRMED · FIXED**

**Traced.** `restoreNoteVersion`'s step 5 touched `last_touched_at` and nothing
else, while steps 2–3 replaced the note's ENTIRE content. So `baseline_length`
and `churn_accumulator` went on describing text that is no longer in the note,
and AppSpec §10's `churn / max(baseline, 1) ≥ threshold` ran against a phantom:
a long note restored to a short moment crosses on the next typo; a short one
restored to a long moment never crosses at all. `copyPost` rebaselines its copy
for exactly this reason (`copy.baselineLength = outcome.renderedLength`) — the
restore is the same act on the same container and was missing it.

**RED ON OLD, measured:** `restoringAVersionRebaselinesTheNotesChurn` —
`✘ Expectation failed: (after.baselineLength → 360) == ("Short.".count → 6)`.
*(The first draft of this pin also asserted a standing accumulator and read 0 —
because the big autosave had CROSSED the threshold and rebaselined. Corrected
by adding a second small edit so an accumulator really is standing when the
restore lands; recorded because the pin would otherwise have been asserting a
state the harness never reaches.)*

**Fix:** step 5 sets `churnAccumulator = 0` and `baselineLength =
landed.renderedLength` — the number the copy loop already returned, so it is the
same measure `copyPost` uses rather than a second one.
**`last_major_revision_at` is deliberately NOT stamped:** restructuring must
never reshuffle the meaningful sort, which is the same rule the touch obeys.

**Files:** `Sources/VariorumCore/Operations/Operations+NoteVersions.swift`.

---

#### LR1-4 (MINOR, WORDING HALF ONLY) — the purge door was version-blind · **TRACE CONFIRMED · FIXED (wording); expansion NOT attempted**

**Traced both halves.** (a) `RecoveryCopy.deleteNowConfirm(_ kind:)` read only
the KIND, and a saved moment IS a `.note`-kind row (that is what made the
versions family need no new door machinery) — so its confirm said *"Delete this
note for good?"* while the Trash's own grouping one line above called it a
saved version. (b) `PurgeFamily.expandContainer` (read, not touched —
`Sources/VariorumCore/Sync/PurgeFamily.swift:87-125`) expands a container into
its lenses, layouts, references, tags, memberships, placements and its
**exact-stamp cascade-victim blocks** — never into another container. So a
note's Delete Now leaves its saved versions in the Trash and said nothing about
them.

**RED ON OLD, by explicit behavioural revert** (the fix had landed, so the
revert was performed: `message` back to `RecoveryCopy.deleteNowConfirm(item.kind)`).
`IAAndTrashShapeTests.theDeleteNowConfirmNamesAMomentAndSaysWhatItLeaves` —
**4 issues**, reading the blind sentence back verbatim:
`✘ (momentAsk → "Delete this note for good? It skips the rest of its 30 days — there's no putting it back.").contains("saved version")` ·
`✘ !(momentAsk.contains("this note") → true)` ·
`✘ (noteConfirm.message → "Delete this note for good? …").contains("1 saved version")` ·
`✘ (noteConfirm.message → "…").contains("stays in the Trash")`.
Restored, re-run green; `grep -rn "REVERT PROBE"` clean.

**Fix.** `deleteNowConfirm(_ kind:isVersion:savedVersions:)` — both parameters
DEFAULTED, which is batch 6's `versions:` precedent and is what keeps a block, a
book and a take byte-identical (pinned by `anOrdinaryRowsDeleteNowIsUnchanged`,
and the three shipped copy pins rode unmodified). `TrashPurge.Confirm.deleteNow`
gains `savedVersions: Int = 0` — a defaulted associated value, so every shipped
construction still compiles and `.deleteNow(block) == …` still holds; the two
pattern-match sites gained a `_`. The COUNT comes from
`TrashGrouping.savedVersions(of:in:)` — a pure shared rule read from the listing
she is looking at, which is the same listing showing those moments grouped under
this note, so the sentence and the screen cannot disagree. **The phone inherits
it** through the shared confirm with a one-line caller change (its Trash lists
the same `.note`-kind rows).

**What the sentence deliberately does NOT claim:** that those rows keep their
note's NAME afterwards. They do not — once the note's blocks are physically
purged, the edge `versionOfNote` groups by is gone with them, and the moments
degrade to anonymous note rows for the rest of their window. **Taking them WITH
the note is the honest repair and it lives in `PurgeFamily`** — `Sync/`-fenced
this round, and the ROUTING sends its KnownIssues row to the CLOSEOUT (owner
decided there). This record is the trace that row should carry.

**Pins** (`IAAndTrashShapeTests`, +2): `theDeleteNowConfirmNamesAMomentAndSaysWhatItLeaves`
(drives the real observation, the real confirms, and the real act — asserting
the note went and the moment stayed) · `anOrdinaryRowsDeleteNowIsUnchanged`.

**Files:** `Shared/RecoveryCopy.swift`, `Shared/RecoveryActs.swift`,
`Features/Library/RecoveryView.swift`,
`VariorumMobile/Features/Shell/MobileTrashModel.swift`,
`VariorumTests/TrashPurgeDoorsTests.swift` (one pattern-match site).

---

#### LR1-3 (MAJOR, RECORD HALF ONLY) — the phone's dark window is open-ended · **TRACE CONFIRMED · RECORD CORRECTED**

**Verified in the tree, and the finding is exactly right.** `TrashScope` is
SHARED (`Shared/RecoveryActs.swift`), and both models ask it — so batch 2's
`listedKinds` change removed the take rows from `MobileTrashView` in the same
commit it removed them from the Mac's. The two replacement homes are **Mac-only
faces**: the tray panel's Leaving section (`Features/Tray/TrayPanel.swift`,
batch 3) and the Block History pane (`Features/Tray/BlockHistoryPane.swift`,
batch 4). The phone's equivalents are mobile batch 6, and the mobile round is
paused until after 13u by her sequencing ruling. So batch 2's *"in-round only"*
is true for the Mac and **false for the phone**, where a take deleted on the
phone is invisible and un-restorable THERE while its clock runs (the data, the
clock and `restoreVariant` are all intact, and it stays recoverable from the
Mac).

**Corrected in place, twice, marked as ladder corrections rather than quietly
rewritten:** batch 2's record paragraph (a call-out under the original, which
survives verbatim) and ledger row 11's status cell. **The product half —
interim phone take rows, or wait for batch 6 — is HERS**, and is not built here.
**Still owed by the CLOSEOUT, by name:** the mobile batch-6 update, the
MobileSoul parity line, and her handoff each carry this window.

---

#### LR1-9 (NIT) — the positive token's doc claimed a distinctness the leading voice lacks · **TRACE CONFIRMED · FIXED (doc + a pin), PROVISIONAL**

**Traced by reading the four voices.** Terminal light: `accent`, `positive` and
`chosen` are all `0x2F7D5F`; Terminal dark: all three are `0x6FBF94`. Study
light/dark keep a green `positive` beside a blue `accent`. The doc said
*"Distinct from `chosen` … and from `accent`"* — false for the voice that leads,
and it means the settled sync line wears the "✓ chosen" hue.

**Fixed the DOC, not the hue, and the reason is on the record:** Terminal has
ONE green on purpose, so a second one beside it would read as a *different
signal* rather than a gentler one; and hues are 13s's by her own ruling on the
sibling token. The doc now says where the slot resolves in each voice and why
the slot still exists (so the three can move independently without a sweep).
**PROVISIONAL for her:** whether Terminal's settled state should wear a hue
apart from "✓ chosen" is taste, and it is 13s's natural home.

**Pin** (`ThemeTokenTests`, +1):
`theQuietPositiveIsItsOwnSlotEvenWhereItSharesTheVoicesGreen` — Terminal's two
schemes assert the SHARING (so a silent divergence announces itself), Study's
assert the distinctness, and every voice asserts `positive != alarm`. The doc is
now checkable against the app rather than against itself (batch 6's pattern).
No red-on-old is owed: this is the doc-honesty class, and its mechanism is the
hex comparison above.

---

#### LR1-10 (NIT) — positional row identity in a reordering listing · **TRACE CONFIRMED · FIXED**

**Traced.** `RecoveryView.swift:621` read
`ForEach(Array(entries.enumerated()), id: \.offset)` over a listing that
reorders under her hands: a Put back or a Delete Now removes a row and
everything below it shifts up, so SwiftUI is told that every entry below the
change became a different entry — identity churn, lost animation continuity, and
a trap for any per-row state added later (the disclosure state is safely keyed
by the anchor row, which is what kept this a NIT rather than a bug).

**Fix:** `TrashGrouping.Entry` is `Identifiable` off the store's own ids
(`group:<noteID>` / `row:<itemID>`, prefixed because a note can be both a group's
name and a row elsewhere), and the `ForEach` reads it.

**Pin** (`IAAndTrashShapeTests`, +1):
`trashEntriesCarryStableIdentitiesThatSurviveARemoval` — ids unique across a
listing, and unchanged for everything below a removal.

---

#### LR1-8 (MINOR) — ledger bookkeeping · **RECONCILED**

Rows **14, 17, 28, 29, 31, 32** carried *"**done** `hash` — …"* at the head of
the ITEM cell while the STATUS column read `open`; every other row carries the
item in cell 2 and the done blurb in cell 3. The six were swapped into the
house shape (item description in the item cell, the done blurb with its hash in
the status cell) — no words changed, nothing re-claimed. **After it, the only
row still `open` is 13, the closeout ritual itself**, and 15 reads
`resolved → 17` as it always did.

---

#### ROUTED AWAY, AND NOT TOUCHED (so round 2 can check the fence rather than the intent)

- **LR1-3's product half** (interim phone take rows vs waiting for batch 6) — hers.
- **LR1-7** (Promote is the pane's only permanent one-way act with no confirm) — product-flavored, hers; nothing built, no wording nudged.
- **LR1-4's purge-family expansion** — `Sources/VariorumCore/Sync/PurgeFamily.swift`, read only; its KnownIssues row is the CLOSEOUT's (owner decided there), and the trace it needs is written above.
- **Batch 5's PROVISIONAL 1** (restore's Delete Now road takes stranded ancestors) — the reviewer's "sharpest thing on her list"; untouched, hers.

#### OBSERVATIONS — nothing built, for the architect

1. **`ArchivedView`'s Unarchive leaves a born-sealed row SEALED.** The reviewer
   met this as a consequence of the leak (*"mints a live SEALED duplicate she
   never sealed"*). The leak is fixed for every gesture read-side means can
   answer, but the moveBlock residue can still put a moment on that surface, and
   `LibraryViewModel.unarchive` clears `archived_at` without touching the seal
   (`promoteNoteVersion` clears both — it is the door that knows). One line if
   she wants it; NOT taken here, because deciding what Unarchive means for a row
   that is version history is the same product question LR1-7 is, and it is
   hers.
2. **A version that outlives its note still becomes an ordinary archived note**
   (batch 5's PROVISIONAL 2) — unchanged by this wave and still a derivation:
   the peer half of the classifier stops holding when the note is dead, and
   `.anyLiveNote` is what carries it. Recorded so round 2 does not read it as
   new.
3. **The predicate's cost is unchanged in shape** — an `EXISTS` over `edge`
   joined to `container_block` twice, plus (only on the live road) one
   correlated `block` lookup for a tombstoned edge. It is per candidate ROW on
   the Archived surface, which is bounded by that surface's own limit, and per
   note on the versions listing. P1's letter is untouched (never the corpus);
   the constant grew by one indexed lookup on rows whose edge is tombstoned.
4. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/`, `App/Variorum/Shared/`,
   `App/Variorum/VariorumMobile/` and `Sources/VariorumCore/` returns only the
   two pre-existing doc comments (`NoteWindowView`, `QuickNoteView`).

### THE END-OF-ROUND LADDER — ROUND 2 (fresh Fable re-reviewer, 2026-08-25): every round-1 fix HOLDS · the dispute SOUND · ONE NEW MAJOR ⇒ round 3

Reviewer's own runs: core **1411/146** · Mac **1768/296 TEST
SUCCEEDED** (xcresult-verified) · mobile **486/78** · red-on-old
INDEPENDENTLY re-proven in a detached scratch worktree at the
pre-fix tree (LR1-1's three legs red at the exact recorded counts;
the dispute's guard pin green-on-old, confirming the rider was
hollow exactly as recorded). Fences verified by diff. Per-finding:
LR1-1/2/3/4/5/6/8/9/10 ALL HOLD (LR1-9 with a residue, below);
LR1-7 correctly routed; the `versonOfNote` DISPUTE verdict: SOUND
— "naming the hollow pin as hollow instead of dressing it as a fix
is the hallucination guard applied correctly."

**[MAJOR · LR2-1] `Operations+NoteVersions.swift:176,213-225` +
`Queries/Lineage.swift:216-224` + `Sync/PurgeFamily.swift` (read
only) — the LR1-1 fix's tombstone-reading cannot survive PHYSICAL
PURGE, and `restoreNoteVersion`'s re-anchor misses exactly the
versions LR1-1 keeps alive.** Restore's step-4 peers come from
`versionPeerPosts`, which still fences all three liveness reads —
so a version whose anchor was merged/archived/deleted is NOT
re-anchored at restore (falsifying the op's own doc), survives
only via the released original's tombstoned rows, and the
restore's own Delete Now road then purges that original WITH its
`version_of` edges (`joinStrandedOriginals` → `expandBlock` sweeps
all edges): once the janitor executes — effectively at once on a
single-device account — the moment silently unlinks: expelled from
the listing, LISTED IN ARCHIVED as a sealed anonymous note,
orphaned from V2's ride, Restore/Promote refusing. Self-inflicted
by save-a-version → merge first block → restore. *Plain leg:* an
anchor block purged at its ordinary 30-day clock severs a LIVE
note's version links the same way — a second no-read-side-answer
leg the new KnownIssues row's "moveBlock is the one leg" claim
misses. **Fix (round 3's input): restore step 4 enumerates peers
the CLASSIFIER's way** (`noteVersionIDs` read before step 2, union
live compare peers — LR1-5's one-classifier doctrine applied to
the op's own read); the KnownIssues row names the purge leg beside
moveBlock with the same #19(c)/13w durable road (the plain leg's
real fix is a schema call, hers — correctly parked).

**[MINOR · LR2-2]** LR1-9's honesty fix stops one voice short:
STUDY's `positive` equals STUDY's `chosen` too (all four voices
wear the ✓-chosen hue on the settled line) while the rewritten doc
concedes only Terminal; the pin never asserts the `chosen`
relation. One doc sentence + extend the pin; hues stay 13s's.

**[NIT · LR2-3]** `savedVersions(of:in:)` counts from the WINDOWED
listing — past the window a note's Delete Now confirm can
under-count its versions. Deliberate; record one sentence so
12/13o don't rediscover it. **[NIT · LR2-4]** the phone's Put
back/Delete Now accessibility labels are version-blind — one line
in the closeout's mobile batch-6 inheritance note. **[NIT ·
LR2-5]** the new KnownIssues row's "would list nowhere" under-
describes (such moments LIST on Archived, sealed) — fix the
wording with LR2-1's row edit.

**Clean bill (abridged):** "the fix wave is disciplined, honest
work… red-on-old genuine (reproduced to the digit)… the LR1-1
predicate rewrite is architecturally right… fences held
everywhere; nothing product-flavored leaked."

**ROUTING:** fix wave 2 owns LR2-1's restore-leg fix + KnownIssues
wording (incl. LR2-5), LR2-2, LR2-3's recorded sentence. LR2-4
rides the closeout's mobile update. Round 3 (fresh Fable) then
re-reviews the wave-2 fixes per the ladder's still-HIGH rule; hard
cap reached after it — anything open lands recorded for her.

### LADDER FIX WAVE 2: the brief (fresh Opus session)

Read: `CLAUDE.md` + canon · THIS FILE top to bottom (ROUND 2's
findings above are your letter; the fix-wave-1 record and LR1-1's
mechanism are your map) · the 13j Environment traps. Scope:
LR2-1's restore-leg fix exactly as proposed (classifier-read
peers before step 2; op doc corrected; the KnownIssues 13w row
gains the purge leg + the LR2-5 wording) · LR2-2 (doc + pin
extension) · LR2-3 (one recorded sentence at the code + in your
record). Fences: ZERO schema · ZERO `Sources/VariorumCore/Sync/`
(PurgeFamily stays read-only — the fix is in the OP's read) ·
nothing product-flavored. Discipline: trace first; red-on-old by
behavioural revert (LR2-1's pin: save version → merge first block
→ restore → every version of the note carries a live edge anchored
on a live block, the listing still claims it — red on the current
tree); four gates quoted (baselines core 1411/146 · Mac 1768/296 ·
spine 68/9 · mobile 486/78); flake watch three candidates;
explicit-path commits, NEVER push. Append "### LADDER FIX WAVE 2
— RECORD", then STOP — round 3 dispatches next.

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

### BATCH 3 — RECORD (Opus implementer, 2026-08-24)

**Commit `29e9876`**, staged by explicit path, not pushed. Tree clean at start
(`9ce4d27`) and at finish. **No Variorum instance at any instance check**
(`pgrep -fl 'Variorum.app/Contents/MacOS'` empty — before each
`build-for-testing` and before each full Mac run); no Release build, no
`/Applications` act.

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1383 tests / 144 suites PASSED** (34.5 s) | 1376/143 → **+7 tests, +1 suite** (`NoteTrayTakesTests`) |
| Mac full (`-project`, `platform=macOS`) | **1728 / 294 PASSED — TEST SUCCEEDED** (223.1 s, zero reds) | 1717/293 → **+11 tests, +1 suite** (`TrayPanelMoveTests`) |
| Mac spine (8 `TutorialWalkTests` types, suite-level `-only-testing`) | **63 / 8 PASSED — TEST SUCCEEDED** (22.6 s) | 63/8 ✔ exact |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (82.5 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**Both known flakes silent** in both full Mac runs — the Phase-12 latency pin
(`EditorWindowSmokeTests/rewriteStrategyLatencies`) and
`CanvasDragTrackingTests`. Neither needed isolating; `CanvasDragTrackingTests`
stays at ONE recorded red for the era.

**Fences held:** ZERO schema (the one core change is a new read-side query over
existing columns) · ZERO `Sources/VariorumCore/Sync/` lines · the Block History
pane and the came-from section are UNBUILT (batch 4's) · no version machinery
(batch 5's) · the unclocked-originals section is STAGED, never removed.

---

#### Row 9 (C1) — the tray becomes the third inspector icon

**Mechanism / shape.** The tray was a `TrayPanel` presented four ways — a
popover on the pane's context bar (the ⌫ badge) and three sheets (both bars'
`note ▾` items, the Blocks-mode section, the origin peek). Her ruling makes the
POST DETAIL'S INSPECTOR its home: `PostDetailView.InspectorPanel` becomes an
enum with `.tray(revealBlockID:)` beside `.references` and `.scraps`, and the
masthead renders its icon cluster from **`PostDetailView.inspectorDoors`** — a
table, iterated, so *"the tray icon sits with scraps and references"* is a claim
a pin holds rather than a comment beside one (batch 2's `mastheadDoors`
precedent). The panel gets `.inspectorColumnWidth(min: 280, ideal: 420)`.

**How the badge reaches a panel it does not own.** The badge lives on
`ContextBar`, inside `PaneHost`, ABOVE the detail — so it cannot touch that
`@State`. It goes through the router, and through a DEDICATED seam rather than
the `RoutedCommand` handler stack: `EditorView` registers a handler INSIDE the
detail and therefore later, so a LIFO dispatch would reach the editor's own
sheet first and the same door would land in two different places depending on
mount order. `CommandRouter.registerDetail` gains `showTray:` (defaulted nil —
every existing caller and pin compiles unchanged) and `requestNoteTray(_:)
-> Bool`, which **never parks by itself**: a caller with its own fallback must
be told "no". The ONE caller that parks is the badge, which has just focused its
pane and knows a detail is arriving — `pendingTrayRequest` is stamped with its
post and consumed at `registerDetail`, exactly the `pendingWriteIntent`
choreography, with the same staleness clearing on a post change and on teardown.

**The doors that moved.** `.showNoteTray`'s `.bottomBar` door is gone and both
bars lost the item in the same commit (R6-2's one-grammar rule applied to a
removal); the act is `.surface`-only with three renderers — `PostDetailView`
(the named door), `ContextBar` (the glance), `PoolDetailView` (the scraps
area's own). The two view models' `requestNoteTray()` and the Blocks-mode
section now ask the router first and fall back to their sheet, which is NOT
vestigial: the same editor is composed where no post detail exists (the book
spread's inline form, the scraps hosts), and a door that could not act there
should not have been rendered (P-2).

**The walk's P-1 squeeze, fixed by shape rather than by width.** The row was one
`HStack` and the flexible `Text` compresses first, so the preview read
`"The sea took t…"` while the stamp and countdown kept their room. Her move
makes the container NARROWER (a column, not a 420-wide sheet), so a
`layoutPriority` would only move the squeeze around. The row STACKS: the preview
owns a full-width line (up to two), and `TrayRowFace.meta` — a pure value —
carries the stamp, the clock and the label onto the quiet line under it, with
empty pieces dropped.

**Pins:** Mac `TrayPanelMoveTests.theTrayIsDeclaredWithSurfaceDoorsOnlyAndTheBarsLostTheirItem`
· `.theMastheadCarriesTheTrayIconBesideScrapsAndReferences` ·
**`.theMountedDetailOpensTheTrayInItsRealSidePanel`** (the walk-driven one) ·
`.aTrayRequestForAnUnmountedPostIsRefusedAndCanBeParked` ·
`.theRowsPreviewNeverSharesALineWithItsMetadata`.

**The walk-driven pin's evidence, and one honest measurement.** It mounts the
REAL `PostDetailView` in a real window (the `PostDetailRoutingTests` harness),
asserts the inspector is absent at rest, fires the router's request, and asserts
the view tree really gained it. **AppKit's accessibility tree is EMPTY in this
test host** — measured, not assumed: an AX walk returned `[]` both before and
after, which would have made the pin pass vacuously. So the evidence is the
AppKit class names in the mounted subtree, which are unambiguous: at rest the
tree holds `EditorTextView` and no `…InspectorStyleContext…` pane and no
`…OutlineList…`; after the request it holds
`NSHostingView<…NavigationPaneModifier<InspectorStyleContext>>`,
`SwiftUIOutlineListView`, `ListTableHeaderView` (the Section headers) **and**
`EditorTextView` still — a panel beside the page, not a sheet over it.

**RED ON OLD** (behavioural revert: `showTray: nil` at the detail's
registration — the pre-C1 world where nothing hands the router a seam):
4 issues — `requestNoteTray(…)` returns false, and the tree gains no
`InspectorStyleContext`, no `OutlineList`, no `ListTableHeaderView`.
**RED ON OLD** (revert `.showNoteTray`'s doors to `[.surface, .bottomBar]`):
the declaration pin and `CapabilityRegistryTests.theBottomBarsRenderExactlyTheDeclaredBarDoors`
both red.

**Files:** `Features/Takes/PostDetailView.swift`, `Registry/CommandRouter.swift`,
`Workspace/PaneHost.swift`, `Features/Editor/CommitBar.swift`,
`Features/Takes/TakesBottomBar.swift`, `Features/Editor/EditorViewModel.swift`,
`Features/Takes/TakesViewModel.swift`, `Features/TOC/BlockTOCView.swift`,
`Features/Editor/EditorView.swift`, `Registry/CapabilityRegistry.swift`,
`Features/Tray/TrayPanel.swift`.

---

#### Row 20 (G5) — the Leaving section, and a purge door in a note

**The three sections.** `Archived — kept, no clock` (B1's row: forever, never
global) · `Leaving — on the 30-day clock` with a one-line explainer naming every
population it holds (her *"never a surprise"*) · `Preserved originals`, staged.
The single `"Deleted & archived"` header is retired: it held a forever-list and
a countdown under one name, which is the blur her B2 ruling split one level up.

**The takes.** New core query **`Queries.trayTakes(_:postID:now:limit:)`** —
every take of this note's blocks on its OWN clock, newest first, bounded in SQL
like its siblings. Four fences, each a rule about what a Put back can honour and
each pinned: the 30-day window; `b.deleted_at IS NULL` (a take that died WITH
its block carries the block's stamp, comes back with `restoreBlock`, and is
already represented one section up — listing it would offer a door that
refuses); the purge-intent fence; and the home read as the LIVE PLACEMENT
falling back to `last_container_id`, so a moved block audits at its new home and
a released original audits where its own row already is. The rows ride the SAME
observation as the rest of the panel — deliberately, because `trayBlocks`
already joins `variant` and a second lifecycle would buy nothing while costing
the collapsed section its count, and a fold that hides its own size is not an
audit. Each row names its block through `Queries.tocHandle`, the ONE
block-naming rule, and an empty take says **take**, never "block".

**Delete Now, in a note, for the first time.** `TrashPurge.deleteNowConfirm` +
`TrashPurge.confirm` unchanged — the take is handed over as an ordinary
`Queries.TrashItem(kind: .take, …)`, which is what a purge target already is.
It confirms EVERY time; the confirm's value **rides into the act through
`presenting:`** and `confirmPendingPurge(_:)` takes it as a parameter, so the
door is born with 13l Act 2's fix rather than repeating the read-back that left
four confirm doors dead. **The registry note is the consequential part:**
`.deleteNow`'s `unavailableNote` said *"never a note"*; her G5 ruling supersedes
that IN PART and the new rule is written at the capability, at the panel, and in
the walk's justified edit — **purge doors live in TRASH SURFACES (the global
Trash and this note-level trash section), never in the writing flow.**
`.emptyTrash` is untouched and stays global.

**Pins:** core `NoteTrayTakesTests` (7: the everyday case + block naming · the
cascade-victim exclusion · note scoping · the window · the purge fence · an
archived-then-deleted take · a released original's takes) · Mac
`.aTakeRowNamesItsBlockItsStampAndItsClock` · `.theLeavingSectionPutsATakeBack`
(drives the panel's REAL `start()` observation, not the read-straight seam) ·
`.theLeavingSectionsDeleteNowConfirmsThenPurgesForGood` ·
`.thePurgeDoorRendersOnTrashSurfacesAndNowhereElse`.

**RED ON OLD** (revert the `b.deleted_at IS NULL` fence): the cascade pin reds
with two rows listed — `(takes → [TrayTake(…000002…), TrayTake(…000004…)]).isEmpty → false`.
**RED ON OLD** (revert the observation's `takes:` arm to `[]`): 2 issues —
`(model.takes.map(\.variantID) → []) == ["…0004"]` and `nothingIsLeaving → true`.
**RED ON OLD** (revert `requestDeleteNowTake` to a no-op — the pre-G5 world
where no take had a purge door): `#require(model.pendingPurge)` reds at nil.

**Files:** `Sources/VariorumCore/Queries/PoolAndTray.swift`,
`Features/Tray/TrayPanel.swift`, `Shared/RecoveryCopy.swift`,
`Registry/CapabilityRegistry.swift`.

---

#### The STAGING note (batch 4 reads this)

The **Preserved originals** section still renders, and it is marked in code with
the reason: her G5 ruling puts UNCLOCKED originals in lineage (the Block History
pane's came-from), that pane is batch 4's, and deleting the section a batch
early would leave the population with no door at all for the length of a batch —
a dark window, the one thing a recovery surface may never have. **Batch 4
deletes the section in the same commit came-from lands**, and takes with it:
`TrayViewModel.originals` / `originalsTruncated`, the `originals:` arm of the
snapshot (`Queries.preservedOriginals` stays — the stranded arm reads it), the
`TrayPath.originalsSection` header, and the tutorial's *"The tray has three
sections"* sentence. `TrayPath.originalsPath` / `originalsPathWithDoor` are
quoted by eight copy sites and the tutorial; they will need a destination in the
Block History pane's vocabulary, not deletion.

---

#### Batch 1's two deferred items — both landed

**(a) The ARCHIVE receipt.** It named *"This Note's Tray (the note menu)"* — a
door her C1 ruling removed. It now names the tray icon, through
`TrayPath.doorPhrase(for:)`, and it may never name the ⌫ badge: the badge is
DELETED-only by her #67(a) ruling, so a receipt pointing at it would point at a
door that is not on screen for a note that has only archived something. That
reasoning is the OLD comment's, unchanged — which is exactly why the sentence
had to follow the door. **(b) The scraps editor's tray.** `PoolDetailView` gains
the same icon and its own inspector, and `TrayPath.menuLabel(for:)` gives a pool
its own noun — *"This Scraps Area's Tray"* — with the panel's four sentences
(the explainer, both empty states, the reveal's line) taking the home's kind
through `RecoveryCopy.homeWord`, the 13l row-26 machinery applied to the door's
own name. **RED ON OLD** for both (restore the old sentence; make
`menuLabel(for:)` return one name): 6 issues across the two pins.

**Files:** `Registry/OpsRefusalCopy.swift`,
`Features/Editor/EditorSurfaceController.swift`, `Features/Canvas/CanvasView.swift`,
`Features/Tray/TrayPanel.swift`, `Shared/RecoveryCopy.swift`.

---

#### THE TUTORIAL — mechanical door-path corrections only (the brief's fence)

Four edits, each forced by a door that moved, and **no lesson re-teaching**
(batch 6 / D2's): the *"the note ▾ menu in the bottom bar carries This Note's
Tray…"* sentence becomes the icon and the panel on the right (the badge kept, as
the glance that opens the same panel); *"the tray's Deleted & archived section"*
becomes the **Archived** section in the archive lesson and the **Leaving**
section in the delete lesson; the tray & Trash lesson's opening door and its
*"The tray has two sections"* paragraph become three, with the collapsed takes
disclosure named. The spine is green by TYPE name (63/8), and the two spine
assertions that read the retired constant were re-pinned to the new headers.

---

#### FOUR SHIPPED PINS EDITED IN PLACE — every one a graduation, none weakened

- **`NoteTrayTests.theTrayIsDeclaredOnceWithBothItsDoors`** →
  `…WithAllItsDoors`: the door table is her ruling, so the pin asserts the new
  one and now also asserts the bars do NOT carry it (a claim it could not make
  before).
- **`NoteTrayTests.theDeleteReceiptNamesTheRealTrayAndItsRealDoor`** asserted
  `doorPhrase.contains(doorGlyph)` — the phrase named the BADGE. It now asserts
  the property that mattered all along and is stronger for it: the phrase names
  a door that is ALWAYS there, never the badge, and that icon is really rendered
  from the masthead's table.
- **`NoteTrayTests.theNoteMenuDoorRaisesTheTrayForThisNote`** →
  `aTrayDoorWithNoSidePanelToOpenFallsBackToItsOwnSheet`: the door it named is
  gone; what it actually exercises is the fallback road, and it now says so and
  asserts the precondition (no detail registered).
- **`UndoHintAndRefusalTests.everyDeleteReceiptNamesTheTrayAndTheTrayHasARealDoor`**:
  same door-table graduation, same claim — *a receipt may only name a surface
  that has a door* — with the renderers updated.
- **`TrashSurfaceTests.theCountdownWordsAreTheWindowsOwnAnswer`** and
  **`TutorialWalkTests`' section assertions**: re-pinned to the split headers.

---

#### OBSERVATIONS — nothing built, for the architect

1. **The BOOK SPREAD's inline editor now has no tray door.** `CommitBar` is
   composed there and lost the `note ▾` item with everything else; a book pane's
   `workspace.selection` is `.reading(…)`, so `PaneHost` renders no ⌫ badge
   either, and `.showNoteTray` has no `.palette` door. So inside a book, the
   tray is unreachable. I did NOT invent a door for it: her ruling's letter is
   that the item follows the move, and the honest alternatives (a palette row, a
   spread-header icon) are both new surface. **Flagged as the one discoverability
   cost of the move.**
2. **The tray's held observation reads `variant`, and the panel can now stay
   open while she types.** As a sheet it was modal; as an inspector column it is
   not. `trayBlocks` joins the default take's text and `trayTakes` reads
   `variant` directly, so GRDB re-runs the panel's observation when a buffer is
   autosaved. **P1 is not breached** — the re-read's cost is ∝ the tray's own
   bounded listing, never the note's length or the corpus — but the FREQUENCY
   class changed, and it is the exact hazard `Queries.trayCounts`' doc comment
   avoids for the badge. Recorded rather than mitigated: a debounce or a
   pause-while-typing would be new machinery, and this is the architect's call.
3. **`OriginPeek` still opens the tray as a nested SHEET**, deliberately: the
   peek is itself a sheet, so routing its "Open this note's tray" to the
   inspector would open a panel BEHIND the sheet she is looking at. Batch 4
   absorbs the peek into the Block History pane, which dissolves the question.
4. **`TrayPath.doorPhrase` is now `doorPhrase(for: .post)`**, and every copy
   site that quoted it followed for free — the delete receipt, the registry's
   `.showOriginBlock` note, `originalsPathWithDoor` (the ceremonies, the
   helper). One constant, exactly as that enum's own comment promised.
5. **`RecoveryCopy` gained the tray's semantic vocabulary** (the two section
   names, the explainer, the disclosure label, the block-naming phrase, the
   empty-take noun) — so mobile's batch-6 tray inherits the ruled design rather
   than re-writing it. **A closeout parity note**, and the phone's own faces are
   unbuilt here by design.
6. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/`, `App/Variorum/Shared/` and `Sources/VariorumCore/`
   returns only the two pre-existing doc comments (`NoteWindowView`,
   `QuickNoteView`).

### BATCH 4 — RECORD (Opus implementer, 2026-08-24/25)

**Four commits, staged by explicit path, none pushed.** Tree clean at start
(`33f5234`) and at finish.

| commit | theme |
|---|---|
| `014f409` | the token + copy sweep — rows 29, 31, 32 |
| `06263d1` | the Block History pane — rows 17, 10, 15, adjudications 1 + 3, row 20's staging finished |
| `7220086` | the Aa condensation — row 28 |
| `200981f` | F1's parity pass — row 14 |

**The order is not the brief's, and the reason is a dependency:** the pane's
status slot needs row 29's `alarm` token, so the chrome hand landed first. It
was verified in isolation — the pane file was held out of the tree for that
build — so the sweep commit stands on its own suites.

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1384 tests / 144 suites PASSED** (36.8 s) | 1383/144 → **+1**, the new `Queries.blockHistory` pin |
| Mac full (`-project`, `platform=macOS`) | **1741 / 294 PASSED — TEST SUCCEEDED** (230.7 s, zero reds) | 1728/294 → **+13**; suite count unmoved (`BlockHistoryPaneTests` in, `RecoveryFaceCaptureTests` out) |
| Mac spine (8 `TutorialWalkTests` types, suite-level `-only-testing`) | **63 / 8 PASSED — TEST SUCCEEDED** (23.9 s) | 63/8 ✔ exact |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (86.4 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**Both known flakes silent** in the full Mac run — the Phase-12 latency pin
(`EditorWindowSmokeTests/rewriteStrategyLatencies`) and
`CanvasDragTrackingTests`. Neither needed isolating; `CanvasDragTrackingTests`
stays at ONE recorded red for the era.

**Fences held:** ZERO schema · ZERO `Sources/VariorumCore/Sync/` lines · the
one core change is a read-side query over existing tables · no version
machinery (batch 5's) · tutorial edits are MECHANICAL door-path corrections
only (batch 6 owns the re-teaching) · the pane is read-tier throughout (every
take in it is a `Text`; no live editor, P3).

**INSTANCE CHECKS.** `pgrep -fl 'Variorum.app/Contents/MacOS'` was empty before
each `build-for-testing` and before the first three full Mac runs. **Before the
final gate run a Variorum was live** — PID 98884, at
`…/DerivedData/…/Build/Products/Release/Variorum.app`, i.e. a Release product
outside `/Applications`. It was NOT addressed, quit or killed (the standing
rule: never by process name, never at all for a real-store instance), and this
batch took no Release build and no `/Applications` act, so nothing was owed.
Recorded because the traps say a real-store instance is discriminated by STORE
rather than path, and a Release product runs the real store — **the closeout's
`/Applications` refresh must re-check before it acts.**

---

#### Row 29 (the error voice token) — a refusal was wearing the app's success green

**Mechanism, traced myself:** with no alarm token, a themed surface that wanted
one reached for `accent` — and in the TERMINAL voice `accent` and `chosen` are
the SAME hex (`0x2F7D5F`), the colour the "✓ chosen" mark wears. So
`TrayPanel`'s refusal slot painted *"This note is sealed…"* in the app's own
success colour, and that was the closest thing to right that existed (batch 1
shipped it as a recorded PROVISIONAL and flagged exactly this). Beside it,
~30 error slots painted a literal `.foregroundStyle(.red)` in themed surfaces.

**Build:** `VoiceTokens` gains `alarm` and `positive`, distinct per voice and
per scheme. The sweep is a MODIFIER, not thirty token hand-offs —
`.alarmVoice()` / `.positiveVoice()` resolve the voice where the app already
resolves it, because most of those slots live in nested private structs that
hold no tokens (which is exactly why they reached for the literal). **21 Mac
sites · 12 mobile sites · `SharedPageStyle`'s error caption in its STYLED
branch · the `tokens.accent` refusal slots in `TrayPanel`, `BlocksAreaView`
and `ScrapsPanel`.**

**DELIBERATELY LEFT, with the reason written at the modifier:** the TK2
fallback CANARY banners (`EditorView`, `ReadPostView`, `PaneSurface`,
`MobileWriteView`) keep white-on-red — a build-integrity alarm aimed at a
developer, deliberately the loudest thing the app can draw. Also left, and
recorded rather than swept: `DiffView`'s red/green (diff SEMANTICS, its own
vocabulary), `MobileNoteActions`' swipe tint (a destructive-role control, not
a message), and the `.orange` STALENESS slots in `DataSafetyPane` /
`BlockTOCView` / the ceremony sheets — warning is a third signal class she has
not ruled on, and inventing one would be inventing product behaviour.

**Pin:** `ThemeTokenTests.everyVoiceNamesAnAlarmThatIsNobodyElsesColour`.
**RED ON OLD** (behavioural revert: `alarm := accent`, batch 1's actual
shipped behaviour): 3 issues, reading the collision back.

**Files:** `Shared/Theme/VoiceTokens.swift`, `Shared/Theme/SharedPageStyle.swift`,
`Theme/VoiceControls.swift`, + 21 Mac and 12 mobile surfaces.

---

#### Row 31 (gentle green) — and why `isCalm` could not carry it

**Mechanism, verified:** the sync line asked `face.isCalm`, a TWO-WAY answer,
and painted `Color.orange` for "not calm". Her ruling wants a gentle green on
the settled state — but #75(d) also ratified that **signed-out stays quiet**,
and "calm" would have painted a local-only Mac the same green as one that had
sent everything. Being local-only is a complete state, not an accomplishment.

**Build:** `SyncSafetyStanding.tone` — `.quiet` / `.settled` / `.attention` —
decided once in `Shared/` so the phone inherits the rule, carried onto
`SyncSafetyFace`, and rendered through the voice tokens. `isCalm` survives
unchanged beside it, answering its own question; its pins ride unmodified.

**Pin:** `SyncSafetyFaceTests.onlyTheSettledStateWearsTheGentlePositiveAndSignedOutStaysQuiet`.
**RED ON OLD** (revert `tone` to derive from `isCalm`): 4 issues — every quiet
standing reading back `.settled`.

---

#### Row 32 (the fence sentence) — naming the road

The fence itself is untouched (it lives at the ACT, so all four doors pass
through it); its words are hers: *"Scraps go one at a time — delete the scraps
themselves."* **Pin edited in place, STRENGTHENING:**
`NoteDeletionActTests.theScrapsAreaCannotBeDeletedThroughTheNoteDoor` kept its
whole claim and gained the property her ruling asks for, which reading the
constant alone could never carry. **RED ON OLD** (restore the refusal-only
sentence): 2 issues.

---

#### Row 17 (G2) — the Block History pane

**The door.** `history` beside `commit ⌘S` on BOTH bars; the `note ▾` item
gone from both in the same commit (R6-2's one-grammar rule, which matters most
for a removal). The act is declared **BLOCK-scoped**, which is her F2 report
answered at the declaration rather than in copy: *"it's unclear that history is
under Note, that makes it seem like the Note's history."* Doors
`[.bottomBar, .palette]`; never disabled — with no block in reach it SPEAKS the
registry's note (P-2).

**The pane** (`Features/Tray/BlockHistoryPane.swift`), one occupant of batch
3's `InspectorPanel` seam, four regions in her order: (1) **savepoints** — ALL
live takes, sectioned, the focused one expanded, restore per row with the
pre-split confirm; (2) **archived takes**, Unarchive; (3) **deleted takes**,
clocks + Put back and **no purge door** (row 21's letter, with the deleted
region's own copy naming where Delete Now does live); (4) **came from** — every
original, its text, **Bring back**, and an Open-this-note's-tray door the HOST
answers.

**The read** is one new core projection, `Queries.blockHistory` +
`observeBlockHistory`: the fan, each live take's savepoints, the split dates,
the deleted takes, and the origins WITH their preview text. Cost is the
block's, never the corpus (P1) — and the fact that it is proportional to this
block's own history is stated at the query.

**THE THREE ABSORPTIONS, and what each of them cost.**

- **Write's inline `CommitHistoryView` strip** and **the Takes bar's history
  sheet**: deleted with `BlockPastSection.swift`'s two types
  (`BlockPastModel`, `BlockPastSection`), whose only two hosts they were.
  `BlockPastCopy` MOVED into the pane's file unchanged — the sentences are
  semantic and every one is still true, and `KnownIssuesAndTechDebt.md` names
  it as a still-Mac-local deletion-copy home, which stays exactly as true.
  `EditorViewModel` lost `commitList`, `pendingRestore`, `blockPast`,
  `CommitListItem`, `commitListVariantID`, `toggleCommitHistory`,
  `loadCommitHistory` and `restore` — three pieces of state for two faces that
  each showed part of one block's time.
- **The J3 peek**: `OriginPeekModel` and `OriginPeekPanel` deleted;
  `OriginPeekCopy` stays as the lineage vocabulary (the registry's verb, the
  context row, the pane's own region all read it). The nested tray sheet
  DISSOLVES rather than moving — the pane raises the tray as a callback, so the
  inspector swaps the column's occupant (adjudication 3).

**Adjudication 1** landed with it: `.showNoteTray` gains a `.palette` door,
for the one place batch 3 recorded the move as costing reach — a book spread's
inline note, which mounts an editor with no masthead and no context bar.

**Row 20's staging, finished in the same commit** as batch 3's note required:
the tray's Preserved-originals section is gone. `Snapshot.originals` STAYS —
`stranded` is derived from it, and an original whose family has died IS
leaving. `revealMissing` reads the snapshot rather than a stored listing, so a
reveal naming an unclocked original is still answered honestly.

**A DESIGN FORK the brief did not settle, resolved and recorded:** the pane is
scoped to the block the REQUEST names, not to a live caret. Following the caret
would mean a panel that jumps while she types and an observation re-scoped at
caret rate; re-pressing `history` opens the pane on the new block, and the
request carries the focused take so her "the focused take's expanded" ruling
has something to name. A second, smaller one: the came-from's **Open this
note's tray** renders on EVERY origin row rather than only clocked ones — a
door that can always act, and the clock is the tray's own face to wear.

**Pins:** `BlockHistoryPaneTests` (9 at this commit) —
`theHistoryActIsDeclaredOnBothBarsBesideCommit` ·
`theHistoryPaneOffersPutBackAndUnarchiveAndNoPurgeDoor` ·
**`theMountedDetailOpensTheHistoryPaneInItsRealSidePanel`** (walk-driven) ·
`aHistoryRequestForAnUnmountedPostIsRefusedSoTheBarCanFallBack` ·
`theCameFromRegionShowsEveryOriginOfAMerge` ·
`everyLiveTakesSavepointRunIsInThePane` ·
`anOrdinaryBlockHasAnEmptyHistoryAndTheCopySaysWhat` ·
`aRestoreFlushesThePendingBufferBeforeItLands` ·
`theRowFacesSayWhenAndWhatAndNothingElse` — plus core
`TrashAndArchiveTests.theBlockHistoryProjectionCarriesEveryTakesRunAndItsOrigins`.

**The walk-driven pin's evidence, and one honest correction to it.** It mounts
the REAL `PostDetailView`, fires the router's request, and asserts the tree
gained `InspectorStyleContext` + `SwiftUIOutlineListView` + `ListTableHeaderView`
with `EditorTextView` still beside it. **Its settle predicate waits for the
REGION HEADERS, not for the column** — measured, not guessed: settling on the
column and reading immediately found the list built and its section views not
yet, so the first version of the pin was asserting about a half-built panel.
The harness block is also given a savepoint and a deleted take, so more than
one region renders and "the four regions" is a claim the class names can carry.

**RED ON OLD**, two behavioural reverts:
- origins truncated to `.first` (the peek's actual shipped behaviour) — the
  came-from pin reds TWICE, reading back one of two and one of three:
  `Set(history.origins…) → ["…0007"] == ["…0007", "…000A"]`.
- `flushExistingAutosave` dropped from `restore` — `(text → "words typed
  since") == "the saved words"`: the restore lands and the pending flush
  writes over it, exactly the race the absorbed strip flushed to avoid.

**GRADUATED PINS** (claims kept, several strengthened): `EditorSessionTests`'
NIT-12 restore-targeting (now STRUCTURAL — a row hands its own take to the
act, so the caret is not part of the address) and the pre-split ask ·
`RecoveryDoorsTests`' whole peek + past-region family (7 tests) ·
`OriginBlockDoorTests` (2) · `NoteTrayTests` (3) · `TutorialWalkTests` (2) ·
`CapabilityRegistryTests`' surface union · `TrayPanelMoveTests` +
`UndoHintAndRefusalTests` (the tray's new palette door).

**TWO PINS RETIRED, each with its reason written where it stood:**
`TrashSurfaceTests.theHistorySheetStopsPayingForAnEmptyPastSection` (13j ladder
A's R2-N2 — the sheet it defended is gone, and the pane's regions build nothing
when empty, so there is no spacing left to defend and no constant left to
hold), and **`RecoveryFaceCaptureTests`** (its own header records that
`ImageRenderer` draws a placeholder for `List`-backed views, so the pane joins
the tray panel and the peek as a **hand-check item** — named here rather than
faked).

---

#### Row 28 (the Aa condensation)

Nine controls behind one `Aa` chip on both bars; the formatting row slides out
**above** the flat row, upward, away from the page's bottom edge — so nothing
she was already reaching for moves under her cursor. `block ▾` · Takes ·
commit · **history** · `note ▾` · comments · the counts · `?` all stay visible
at rest, which is what keeps row 17's reading true.

**Registry ids UNCHANGED**, deliberately — the R6-2/13g slide-out class:
rendering a door behind an expansion is still rendering it.

Two decisions worth naming. The fold is **per-bar session UI state**, seeded at
birth through an init parameter so a pin can mount the bar in either state (a
`@State` toggle is otherwise unreachable — the `TrayPanel(model:)` seam
pattern). And the Takes bar's segmentation-refresh `.task` **moved off the chip
onto the bar**: the chip is behind a fold now, and a setting that only learned
the truth when she opened the fold would be a stale face wearing a confident
one.

**Pins:** `onlyFormattingCondensesBehindTheAaDoor` (her ruled scope as a
VALUE — `FormattingDoor.condensed` IS `FormatBar`'s act table, so a ninth
formatting act joins the fold automatically and a non-formatting act cannot
wander in silently; plus what stays visible asserted per bar) ·
**`theRealBarDrawsFewerDoorsAtRestThanWithAaOpen`**, walk-driven over the real
mounted `CommitBar`: **9 focusable controls folded, 18 open.** The probe is
`KeyViewProxy` and it was MEASURED rather than assumed — the doors are
SwiftUI-drawn, so an `is NSButton` walk returned zero on a bar plainly full of
doors, and this host's AX tree is empty (batch 3's finding).
**RED ON OLD** (the cluster back in the flat row, no fold): **17 and 17**.

---

#### Row 14 (F1) — the parity pass, and its real finding

Her pass was a VERIFICATION (*"no, I see archive there too"*), and it found one
class of straggler in each half. **In both cases the reason nothing had caught
it was the same: the acts were rendered and never declared**, so there was no
door set for the registry walk to compare — which is the strongest argument for
P-1 this round has produced.

**THE BLOCK-DOOR TABLE (instance × door → verdict):**

| surface | block Delete | block Archive | verdict |
|---|---|---|---|
| Menu bar ▸ Block | ✔ declared | ✔ declared, adjacent | **OK** |
| Block context menu (notes AND the scraps editor — one shared builder) | ✔ (batch 1) | ✔ | **OK** |
| `CommitBar` `block ▾` | ✔ | ✗ | **FIXED** — `.archiveBlock` gains `.bottomBar` |
| `TakesBottomBar` `block ▾` | ✔ | ✗ | **FIXED** — same commit (R6-2) |
| Blocks mode row menu (`BlockTOCView`) | ✔ but **undeclared since 13c** | ✗ | **FIXED** — the pair added AND declared; the view joins the surface walk |
| ⌘K palette | ✔ | — | **OK by decision**, stated in the pin: a palette row is typed by name and "Archive Block" is one line away |
| Snippets list rows (`BlocksAreaView`) | ✔ (batch 1) | ✗ | **FIXED** — new `.archiveScrap` |
| Scraps side-panel rows (`ScrapsPanel`) | ✗ (Tags… only) | ✗ | **FIXED — both**; batch 1 named this listing as F1's to enumerate |
| Canvas cards + bank rows (`CanvasView`) | ✗ — no delete door at all | ✗ | **OK by vacuity**, and RECORDED: the canvas offers Tags… · Place on the board · Return to bank · Reset size and no way to get rid of a block. F1's rule is satisfied because there is no Delete to ride beside; whether a canvas card SHOULD carry one is a product call, not this pass's |
| Takes card ⋯ / Write's selection banner (`.deleteSelectedBlocks`) | ✔ (selection-scoped) | — | **RECORDED**: no bulk-archive act exists, and minting one is inventing product behaviour. The block-grain pair is one menu away in `block ▾` |

**THE TAKE-CARD GRAMMAR (surface × act):**

| surface | Archive | Label | Lock | Delete | verdict |
|---|---|---|---|---|---|
| `WriteTakesPanel` card ⋯ | ✔ | ✔ | ✔ | ✔ | rendered since Phase 7, **ALL FOUR UNDECLARED** → **FIXED** (declared) |
| `TakesCellView` card menu (Takes **and** Lenses boards) | ✔ | ✔ | ✗ | ✗ | **FIXED** — the missing two added |
| `WriteTakesPanel` archived card | — | — | — | ✔ | **OK** → declared |
| `TakesBoardView` archived card | Unarchive ✔ | — | — | ✔ | **OK** → declared |

New declarations: `.archiveScrap`, `.lockTake`, `.deleteTake`; new doors:
`.archiveBlock` +`.bottomBar` +`.surface`, `.deleteBlock` +`.surface`,
`.archiveTake` +`.surface`, `.labelTake` +`.surface`. The card rows now read
their verbs from the registry (`TakeCardMenuCopy` gained `lockVerb(locked:)`
and `deleteTake`), so a rename lands once — and the lock row says WHICH WAY it
points, as Write's panel always did. **Takes do not confirm** (13j's
confirmation-consistency principle, second clause), stated at the declaration.

**Pins:** `everyDoorThatDeletesABlockOffersToArchiveItToo` ·
`theTakeCardsCarryTheSameFourActsOnBothSurfaces`. **RED ON OLD** (archive's two
new doors dropped; both take surfaces back to their pre-pass tables): **5
issues** — the bar and the row menu reading back an archive that is not there,
and the grammar reading back two of four on each surface.

---

#### THE CAME-FROM WORDING DRAFT — for her checkpoint

Her fourth-sitting ask named the idea and rejected her own wording for it:
*"add as block again to the note (that's too wordy, you can reword the button,
but the idea is that if you just merged something then realized you actually
wanted a parent block, you should just be able to pull that parent block back
into existence easily)"*.

**My draft: `Bring back`.**

Two words, the verb first, and deliberately the tray's own **Put back** grammar
one grain over — the same shape, a different word, because the two acts differ
in a way she may want to feel: *Put back* returns something that was TAKEN
AWAY, while *Bring back* returns something that was never deleted at all, only
set aside whole. Its help sentence carries the rest so the button does not have
to: *"Puts this original back into the note, beside the blocks it became — it
was kept whole and set aside, never deleted."*

Candidates weighed and not chosen, so she can see the space: **Put back** (one
word from perfect, but it would make two different acts identical in the same
panel family) · **Restore** (already means a savepoint in the region directly
above it) · **Add back to the note** (four words, and "add" reads as minting
something new — the one thing this act is not) · **Bring it back** (warmer, but
a button that says "it" beside a list of several originals is ambiguous).

---

#### ADJUDICATION 2 — the frequency class, RECORDED (nothing built)

The Block History pane is the SAME class the architect adjudicated for batch
3's tray, and the verdict covers it unchanged: **record-only, owner 12, no
debounce machinery.** Concretely, the pane's projection reads `variant` AND
`commit_point`, so GRDB re-runs it whenever a buffer is autosaved — and as a
side panel it can now stand open while she types, where the two faces it
replaces were a sheet and a summoned strip.

**P1 is not breached, and the distinction is worth keeping straight:** the
re-read's cost is ∝ this block's own fan and savepoint history, never the
note's length and never the corpus. What changed is the FREQUENCY, not the
scaling. The one honest caveat beyond the tray's: a block with many takes and
long savepoint runs reads all of them per re-run, so this pane's constant is
larger than the tray's bounded listing. Both are off-main and both are
summoned. **The closeout writes ONE KnownIssues row naming both panes.**

*(Her confirmation landed mid-batch and matches what was built:
**"Park for Phase 12"**, recorded at the adjudication itself in `e1a3714`.
Nothing here changed for it — it is the same disposition, now with her
authority behind it.)*

---

#### OBSERVATIONS — nothing built, for the architect

1. **`WriteTakesPanel`'s status slot is still a single un-classed line**
   (`tokens.accent` for receipts and refusals alike) — ledger row 6's exact
   defect, one surface over. It was deliberately NOT swept into `alarm`:
   `TakesViewModel.statusMessage` carries both classes, so painting it alarm
   wholesale would make every receipt read as an error, which is the defect
   row 6 fixed rather than the fix. The honest repair is `TrayViewModel
   .Status`' split applied to `TakesViewModel`, which touches every board.
   **Recorded, not attempted.**
2. **`BridgeStatusViews`' "Bridge error" keeps its literal red.** It is in
   `Shared/`, so it cannot use the Mac's `.alarmVoice()`, and it takes no
   `SharedPageStyle` — the hoisted road that would give it a token. One line;
   flagged rather than left silent.
3. **The canvas has no way to delete a block** (observation row 9 of the F1
   table). Not F1's to invent, and worth her eye: a surface that arranges
   blocks spatially and cannot remove one is a door-shaped hole, and Blocks
   mode's row menu is the nearest thing to a precedent.
4. **`BlockTOCView`'s other row acts stay undeclared** — move to top/bottom,
   move to ordinal, move out to a pool. The round's own scope note excludes
   placement moves as *"ordinary reversible editing, not past-creating"*, and
   the view's new declaration comment says so; it is now a recorded gap rather
   than an invisible one.
5. **The pane and the tray are hand-check items for the visual loop**, and
   after `RecoveryFaceCaptureTests`' retirement nothing in the suite renders
   either offscreen. `ImageRenderer` cannot draw a `List`; a capture harness
   for these two would need a real window and a screenshot, which is the
   walk's road, not a test's.
6. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/`, `App/Variorum/Shared/`,
   `App/Variorum/VariorumMobile/` and `Sources/VariorumCore/` returns only the
   two pre-existing doc comments (`NoteWindowView`, `QuickNoteView`).

### BATCH 5 — RECORD (Opus implementer, 2026-08-25)

**Four commits, staged by explicit path, none pushed.** Tree clean at start
(`0414834`) and at finish.

| commit | theme |
|---|---|
| `2212c36` | the store — the ops, the queries, the V3 fix (rows 16, 23, 24) |
| `7e3e763` | the door, the pane and the listing (rows 16, 23) |
| `53b4edb` | the deletion ride's face + the ancestors fold (rows 23, 30) |
| `60c5bcc` | the routed flags 2 + 3, and the batch's Mac pins |

*(Two files carry a second theme each, and the commit messages say so: the
bars gained the async delete-ask, and `TakesViewModel` gained flag 2's
classing beside its versions doors. Only the last commit is independently
buildable — the split is by THEME, as the brief asked, not by build.)*

**Gates — all four, my own runs:**

| gate | result | baseline |
|---|---|---|
| core (`swift test`) | **1402 tests / 146 suites PASSED** (34.9 s) | 1384/144 → **+18 tests, +2 suites** (`NoteVersionsTests`, `BridgeVersionTests`) |
| Mac full (`-project`, `platform=macOS`) | **1754 / 295 PASSED — TEST SUCCEEDED** (238.6 s) | 1741/294 → **+13 tests, +1 suite** (`NoteVersionsPaneTests`) |
| Mac spine (8 `TutorialWalkTests` types, suite-level `-only-testing`) | **63 / 8 PASSED — TEST SUCCEEDED** (22.2 s) | 63/8 ✔ exact |
| mobile (`VariorumMobile`, iPhone 16e) | **486 / 78 PASSED — TEST SUCCEEDED** (85.2 s), the 2 recorded `withKnownIssue`s only | 486/78 ✔ exact |

**🔴 ONE RED, RECORDED PROMINENTLY AS THE BRIEF REQUIRES — and it is a THIRD
flake candidate, not a regression.** `TakesSlotDragTests`
`.theSlotHeightHandleFollowsThePointerOneToOneInsteadOfHalfOfIt` reds in ONE
of my three full Mac runs (`mid → 345.0` where 305.0 was expected — the drag
landed a feedback step short). **Measured, not assumed:** it passed in my
first full run, failed in the second, passed ISOLATED (1/1), and passed in
the third full run. It drives a REAL mouse drag with real timing through
`SlotDragRig`, which is the same load-sensitive class as `PoolDragTests`'
physical-⌥ dependency and the Phase-12 latency pin. Nothing this batch
touched can reach it — the only file in its path I changed is
`TakesViewModel`, whose change is the status CLASSING (a `String?` becoming
an enum with a forwarder); slot heights, the drag rig and
`TakesBoardLayout.clampedSlotHeight` are untouched. **Recorded rather than
dismissed**, because a perf/timing pin that flips under load costs every
future session the time it costs to decide which kind of red it is — the
exact argument the KnownIssues row for the latency pin already makes. The
architect's call whether it joins that row; a SECOND red under a later
batch should promote it.

**Both known flakes silent** in all three full Mac runs — the Phase-12
latency pin and `CanvasDragTrackingTests`. `CanvasDragTrackingTests` stays at
ONE recorded red for the era.

**Fences held:** **ZERO schema** — the classifier is a BIRTH FACT and never
came near a column · **ZERO `Sources/VariorumCore/Sync/` lines** (V3's fix
landed at the MINT; see below) · the tutorial is untouched (batch 6's) · the
pane is read-tier throughout (P3 — every version in it is a `Text`, and a
version is sealed at birth precisely so it cannot be edited).

**INSTANCE CHECKS.** `pgrep -fl 'Variorum.app/Contents/MacOS'` ran before
every `build-for-testing` and every full Mac run. A Release DerivedData
product (PID 98884, her real store) was live for the first four checks and
was **never addressed** — no Release build, no `/Applications` act was owed
or taken. It was gone by the final gate run (her own doing, recorded at her
2026-08-25 sitting: *"i've also closed the variorum i was running"*).

---

#### The store (rows 16, 23, 24) — `2212c36`

**`saveNoteVersion`** — ONE transaction: `copyPost`'s full family copy, then
three column writes that make it a MOMENT rather than a copy.

- **Born archived, from ONE clock read.** `archived_at` is set to the copy's
  own `created_at`, not to a second `date.now`. That is the whole classifier,
  so it may never depend on how fast the machine is — and the harness clock
  ticks a second per read, which is exactly the world that catches a second
  read. **RED ON OLD** (revert to `date.now`): `(row.archivedAt → …:03) ==
  (row.createdAt → …:02)`, and the listing goes empty while the Archived
  surface gains the moment — the defect end to end in one revert.
- **Born sealed** (V4b): the archive hides, the seal freezes, the edge
  classifies — three existing mechanisms, each doing its own job.
- **No `entry_date`** — V3, below.

**`restoreNoteVersion`** — identity-preserving, ONE transaction, in her
eighth-sitting order: save the moment of NOW → the outgoing blocks take the
**Delete Now road** → the version's family is copied INTO the same container
→ **every version link is re-anchored** → touch without churn.

**The re-anchor is the finding of this batch, and the brief did not name
it.** A post-level version link RIDES a block-level edge anchored on the
note's FIRST block (I8: posts are edges-only across versions). Step 2 deletes
that block. So without re-anchoring, restoring a version **silently severs
the note from every moment it has** — including the one saved seconds
earlier — and the orphans then surface on the Archived list, because the
classifier's peer half stops holding. **RED ON OLD** (drop the re-anchor
loop): `(Set(listed) → []) == [first, second, savedNow]` and
`archivedPosts.isEmpty` both fail. The peers are read while their links are
still live; each gets one fresh edge to the new first block; an
already-joined peer is skipped.

**The Delete Now road, S2-safe.** Her ruling was *"it's fine to just
instantly hard delete those remaining blocks"*; the implementation is a
tombstone **plus a purge intent per block**, in the restore's own
transaction — which is what "instant hard delete" MEANS in this system: the
intent's read-side fence hides the row from the Trash, the tray and
everything else at once, and the janitor takes the bytes on its ordinary
horizon. `requestPurge`'s body split into `mintPurgeIntents(_ db:…)` so the
public door keeps its whole contract (refusals, dedup, already-purged skip)
and a composite can share it. **RED ON OLD** (drop the intent write): 3
issues — no intent, and the block ROWS in both the Trash and the tray, which
is the Trash noise the brief forbids.

**What the restore deliberately leaves alone:** archived blocks and preserved
originals have no live placement, so they are not outgoing. Archive is
forever and rides no deletion — the covenant, unbroken.

**No undo entry** (the recovery-door class, with `restoreReading` and
`restoreSection` as precedent): the door IS the recovery, its road back is
the moment of NOW that step 1 always saves, and an inverse would be a lie —
the purge intents are the one act in this app with no way back, which is
exactly why step 1 comes first.

**`promoteNoteVersion`** — two column writes, and "forever" is a DERIVATION
rather than a rule: clearing `archived_at` breaks the birth fact, and
re-archiving stamps a LATER `archived_at`, which is what a set-aside WORK
looks like. Pinned in both directions.

**THE EXACT-STAMP STORY, in two sentences (the brief's ask).** Deleting a
note tombstones each of its versions with the note's **exact `deleted_at`**,
in the same transaction and from one clock read, so a version that rode is
identifiable by nothing but that stamp. Restoring the note runs the ordinary
restore body for itself and then again for every born-archived,
version-linked container carrying that same stamp — which brings back what
rode, leaves dead anything that diverged (a version she cut earlier carries a
different stamp; so does one deleted after), and needs no bookkeeping,
because each version's own blocks, takes, edges and lenses carry that stamp
too. **RED ON OLD** for both halves: dropping the sweep leaves the versions
alive (`stamps[first] → nil`); dropping the revival leaves them dead
(`listed → []`).

*(The revival's version query reads edges and placements PAST their
tombstones — the `strandedOriginals` doctrine, *lineage is a fact about what
happened* — because the note's own cascade took them down. The STAMP is what
makes that safe: two born-archived containers cannot share an ISO stamp to
the second unless one transaction wrote both, which is precisely the case it
identifies.)*

**Files:** `Operations+NoteVersions.swift` (new), `Operations+Versions.swift`
(the `copyPlacements` extraction — `copyPost`'s body verbatim, over an
existing target container), `Operations+Container.swift`,
`Operations+Purge.swift`, `OperationError.swift`, `Queries/NoteVersions.swift`
(new), `Queries/Timeline.swift`, `Queries/Trash.swift`.

---

#### Row 24 — V3's MUST-PIN: **the trap was real**

**Verified before fixing, as the brief required.** The bridge's day scan
(`BridgeEngine`, ~line 762) reads every **live** journal-profile container
with an `entry_date` and PAUSES any day holding more than one — *never*
newest-wins, because a slipped push would overwrite one body with the other
on the Fragments side. `copyPost` copies `entry_date` verbatim. So a saved
moment of a journal day was a second live row on that day, and the day would
have gone quiet **with no visible cause**.

**The fix is at the MINT, not the engine:** `mintNoteVersion` clears
`entry_date`, because **a saved moment is not a day**. The day belongs to the
live note, the notebook rule allows exactly one entry per day, the listing
dates a moment by when it was SAVED (V6), and it survives PROMOTE correctly —
a promoted version becomes a first-class note that does not claim a day
another note already holds. The alternative the review pass offered
(excluding archived from the day scan) was declined: it would have changed
the push behaviour of archived-only days, which no ruling asked for.

**`Sources/VariorumCore/Sync/` untouched** — the standing rider never came
into play, because the bridge lives in `Sources/VariorumCore/Bridge/` and
even that is byte-unchanged.

**Pins (`BridgeVersionTests`, the real fake server, the real engine):**
`aSavedVersionOfAJournalDayNeverPausesThatDay` ·
`aVersionNeitherCausesNorReleasesADuplicateDayPause` (the other half, so the
fix cannot be mistaken for luck: a REAL duplicate still pauses, and the
hand-merge still releases it — with the duplicate's own saved moment riding
its deletion).
**RED ON OLD** (drop the one line): **7 issues**, reading the trap back
literally — `(report.pausedDays → ["2026-07-09"]).isEmpty → false`,
`(report.pushed → 0) == 1`, and the day's Fragments body stuck at the old
text.

---

#### The door, the pane and the listing (rows 16, 23) — `7e3e763`

**⌘⇧S** — free at the kickoff sweep and pinned free now
(`theSaveAVersionChordIsTheShiftedTwinOfCommitAndNothingElseTakesIt` walks
every declared shortcut and asserts exactly TWO `s` chords exist). The
pairing IS the teaching, so the chord had to be commit's shifted twin. The
File menu carries it beside ⌘S, the cheat sheet shows it under commit's own
line, both `note ▾` menus carry the pair, and ⌘K carries both.

**TWO acts, deliberately** — `.saveNoteVersion` (an instant, keyable thing)
and `.showNoteVersions` (a panel). One declaration could not carry both a key
and a surface, and the pairing that teaches is ⌘S↔⌘⇧S, not save↔list.

**The pane** (`Features/Versions/NoteVersionsPane.swift`) is the inspector's
FOURTH occupant on batch 3's seam, with its own router seam beside the tray's
and the history pane's (same ordering reason: the detail owns the inspector,
so the detail is what registers it). Rows lead with the DATE (V6 — no title
mutation anywhere), carry a preview, and offer **Read · Restore · Promote ·
Delete**.

- **Read** is an inline disclosure of the moment's rendered text, capped at
  4 000 characters with an honest ellipsis. *A DESIGN FORK the brief left
  open, resolved and recorded:* "openable" could have meant navigating to the
  version as a note, which needs a workspace seam the inspector does not
  have; reading it in place is what a side panel is FOR (her C1 note), costs
  no new surface, and keeps the whole family in one column.
- **Restore CONFIRMS**, on the confirmation-consistency principle's SCALE
  clause (notes confirm; blocks and takes do not) — and the ask is where the
  save-first promise is readable BEFORE the press rather than only after.
- **Delete** wears the ordinary move-to-Trash ellipsis and detail.

**WALK-DRIVEN PIN**
(`theMountedDetailOpensTheVersionsPaneInItsRealSidePanel`): it mounts the
REAL `PostDetailView` in a real window, asserts the inspector is absent at
rest, fires the router's request, and asserts the tree gained
`InspectorStyleContext` + an outline list **with `EditorTextView` still
beside it** — a panel beside the page, not a sheet over it. AX is not used:
this host's accessibility tree is empty (batch 3's measurement), so an AX pin
would pass vacuously.
**RED ON OLD** (`showVersions: nil` at the detail's registration — the world
before the seam): 4 issues across two tests, the request returning false and
no column appearing.

**The acts live in `Shared/`** (`VersionActs`, `VersionsCopy`), so the phone
inherits the DECISIONS and not merely the sentences — **flush-first above
all**, because a moment missing the keystroke that summoned it is not the
moment she asked for, and the restore's save-of-NOW is worse, since the
restore then deletes the blocks those bytes belonged to. Through the
EXISTING-ONLY autosave entry (13l's L-d growth class).

---

#### The deletion ride's face and the fold (rows 23, 30) — `53b4edb`

**V2's one honest line, and NOT a dialog.** `NoteDeleteConfirm` gains a
`versionCount` read at ASK time through a new shared `NoteDeletion.ask`,
which **all six doors** now raise their confirm through — so no door has to
remember that a note's past travels with it. Zero versions ⇒ the sentence is
byte-identical to what shipped, which is what keeps every ordinary deletion
unchanged. **RED ON OLD** (drop the rider): the detail reads back without
*"2 saved versions go with it"*.

**The Trash's version rows.** A version IS a container, so it rides the
`.note` arm and every `.note` door unchanged (Put back returns it to the
listing; Delete Now ends its days; Empty Trash takes it because it is rowed).
What the FACE owes is context: the row calls itself a **saved version** and
gathers under the note whose moment it is. That needed ONE word changed in
`TrashGrouping` — the question a row is asked there was *"are you a note"*
and it should have been *"do you point at one"*. **RED ON OLD** (revert the
two lines): two moments render as two loose note rows rather than one group.

`TrashItem` gains `versionOfNoteID`, filled by a correlated read that runs
ONLY for rows that are born archived (selected as `born_archived`, so an
ordinary note pays nothing for it).

**Row 30 — the fold.** A `DisclosureGroup` that starts OPEN (her *"not
collapsed by default"*), keyed by the anchor row so folding one deletion's
ancestors never folds another's, with the COUNT in the label because a fold
that hides its own size is not an audit — and it says what the run IS,
because *"3 more"* under a deleted block would be a riddle.

---

#### The routed flags, and the batch's pins — `60c5bcc`

**Flag 2 — a receipt is not a refusal, on the boards too.** Row 6's defect
one surface over, and batch 4 was right not to sweep it: `TakesViewModel`
carried BOTH classes on one `String?`, so painting the slot alarm wholesale
would have made every receipt read as an error. The class is decided **where
the message is produced** now — `status: TrayViewModel.Status?` with
`statusMessage` surviving as a computed forwarder (the 3C parity pattern:
**zero edits to any shipped pin**, and `TakesFindReplaceTests`' nine
assertions rode unmodified). The two doors:

- `setStatus` — what a door that DID something says;
- `speak` — **fire-and-speak's refusal**, which is all it has ever been used
  for: every one of its callers is *"Click into a block first…"*, *"This
  block has no renderable take to divide."*, or a registry unavailable note.

`TakesStructureController`'s 18 refusal sites moved to a new `setRefusal`;
`WriteTakesPanel`'s slot reads the class. **RED ON OLD** (revert `speak` to
`setStatus`): `(takes.status?.isRefusal → false) == true`.

**One naming collision found and fixed while converting:** the lens-fallback
restore had a local `let status = try ops.restoreVariant(…)` that the new
property would have shadowed; the local is `restored` now.

**Flag 3 — the bridge row's last literal red, fixed the only way that
works.** It is in `Shared/`, and **neither of batch 4's two roads reaches
it**: `.alarmVoice()` is defined only in the Mac target (the mobile target
would not compile a call to it), and `\.sharedPageStyle` is **nil on macOS BY
CONSTRUCTION** — a pinned one-seam law — so routing through
`pageCaptionError` would have compiled to the SAME literal red and dressed a
no-op as a fix. It takes `VoiceTokens?` as a defaulted parameter (the nil arm
draws exactly what shipped; every pin rides unmodified) and the ONE caller
hands over the live voice. The pause keeps its literal orange
**deliberately**, with the reason written at the line: warning is a third
signal class she has not ruled on, and inventing one would be inventing
product behaviour (batch 4's own disposition).

---

#### THE 13o SEARCH-SCOPE HANDOFF (the brief's ask, V1's fifth-sitting ruling)

Her ruling: **the main search = live notes · the Archived surface's search =
archived NON-version notes · versions are searchable only inside their note's
Versions/Compare context** — so a ten-version note matches ONCE in every
global scope. **What is BUILT and what 13o inherits:**

1. **Both exclusions hold, and they are now exact COMPLEMENTS** (pinned).
   `Queries.library` reads `archived_at IS NULL`, so a version is invisible
   to the main scope by the birth fact alone.
   `Queries.archivedPosts(excludingVersionHistory:)` excludes exactly what
   `Queries.noteVersions` lists. **Batch 5 dropped one clause from batch 2's
   fence** — the peer's `archived_at IS NULL` — because with it, archiving a
   note pushed every one of its moments onto the Archived surface **while its
   own Versions pane still listed them**: double-listed, her crowding worry
   reborn on the surface it was answered for. An archived note is a WORK she
   set aside; its past is still its own.
2. **13o's index must ask the same question**, and the query to ask it with
   exists: `Queries.versionHistoryPredicate(liveOnly:)` is the classifier
   written ONCE, and every scope reads it rather than re-typing the join. A
   body-text index that indexes containers must exclude version history from
   the global scopes and carry it in the note-scoped one — which is the same
   rule, not a second one.

   > **🔴 CORRECTED BY THE LADDER (LR1-5, fix wave 2026-08-25).** The claim
   > "every scope reads it" was **not true when it was written**:
   > `Queries.archivedPosts`' fence was an inline NEAR-copy of the predicate
   > that had drifted from it structurally (it fenced both placements and the
   > edge to live rows and joined a live peer container; the predicate fenced
   > differently and took a named note), so the classifier could disagree with
   > itself — and LR1-1's fix would have had to land twice. It is true NOW:
   > the fence reads `versionHistoryPredicate(alias:of:pastTombstones:)`, with
   > `of: .anyLiveNote` where the scope is "any live note" instead of a named
   > one. **The signature CHANGED with the fix** (`liveOnly:` is gone;
   > tombstone tolerance and the peer are separate questions now), so 13o
   > should read the current one — the rule it names is unchanged.
3. **The honest caveat for that phase:** a version is a FULL family copy, so
   an index that walks blocks will meet a note's moments as N copies of its
   text. That is V7's chosen cost seen from the search side, and it is the
   strongest argument for scoping the index by the classifier rather than
   filtering results after the fact.

---

#### PROVISIONALs and observations — for her checkpoint

1. **PROVISIONAL — the restore's Delete Now road takes stranded ancestors
   with it.** Two of her own rulings meet here: *"instantly hard delete those
   remaining blocks"* (eighth sitting) and *"your ancestors die with you"*
   (13j round 8b, which `PurgeFamily.expand` implements by pulling a purged
   block's preserved originals into the family). So restoring a version on a
   note whose blocks were MERGED or DIVIDED also purges the originals those
   blocks came out of. Her *"there's no loss risk"* premise holds for the
   note's TEXT — the moment of NOW carries it — and does not hold for
   lineage originals, whose words survive only as the merged/divided text.
   **Built to the letter and recorded**, because the alternative (sparing
   them) means the outgoing blocks ROW in the Trash, which the brief
   explicitly forbids ("no Trash noise"). Rare by construction: a note that
   has never merged or divided has no originals to strand.
2. **A version that outlives its note becomes an ordinary archived note.**
   Put back ONE version from the Trash while its note stays deleted, and the
   classifier's peer half stops holding — so it lists in Archived as a
   set-aside work. Derivation, not a special case, and arguably right: it is
   no longer history OF anything. Recorded rather than fenced.
3. **Empty Trash counts a version as a note.** True (it IS a note-kind row
   and it does go), and the grouping says which rows are moments — but the
   sentence reads *"3 notes go for good"* when one is a moment. Naming them
   would mean a new parameter on a confirm two shipped pins assert verbatim;
   left alone, flagged.
4. **The restore CONFIRMS** — my call under the confirmation-consistency
   principle's scale clause, and the ask is where the save-first promise
   becomes readable before the press. Hers to strike if a note-scale content
   swap should be as quiet as a block edit.
5. **The Versions pane is a hand-check item** for the visual loop, joining
   the tray panel and the History pane: `ImageRenderer` draws a placeholder
   for `List`-backed views (batch 4's finding), so nothing in the suite
   renders it offscreen.
6. **A parity note for the closeout:** the phone owes a Versions face. The
   DECISIONS are already shared (`VersionActs`, `VersionsPath`), and the
   store side is entirely core — so mobile inherits the ruled design rather
   than re-deciding it, which is exactly what row 13's batch-6 update is for.
   Its `.note`-kind Trash rows already carry `versionOfNoteID` through the
   shared `TrashScope`/`TrashGrouping`, so the phone's grouping inherits for
   free the moment it renders it.
7. **No behavioural-revert residue** — `grep -rn "REVERT"` over
   `App/Variorum/Variorum/`, `App/Variorum/Shared/`,
   `App/Variorum/VariorumMobile/` and `Sources/VariorumCore/` returns only
   the two pre-existing doc comments (`NoteWindowView`, `QuickNoteView`).
