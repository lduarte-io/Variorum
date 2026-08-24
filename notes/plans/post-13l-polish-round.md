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

## Kickoff message (paste-ready)

> You are running **the post-13l polish round** — the author's
> morning-after rulings on 13l's recovery-walk findings plus an IA
> pass she ruled the same sitting. READ IN FULL FIRST: `CLAUDE.md` +
> the canon it loads · THIS FILE top to bottom (her rulings are the
> letter) · the 13l plan's **Act 7 — WALK RECORD** (the P-1…P-9
> details + the screenshot paths; `notes/plans/phase-13l-data-safety-floor.md`)
> and its Act 2 record (the trash-surface work you build on) · the
> 13j plan's **Environment traps** section (binding verbatim) ·
> `notes/handoffs/phase-13l-handoff.md` (what just shipped). Copy the
> P-1…P-9 constitution in verbatim per `/architect-phase`.
> Baselines: 13l's finals (core 1373/143 · Mac 1691/292 · Mac spine
> 63/8 · mobile 486/78 · mobile spine 33/7 · marker 7) plus one
> post-close commit (`cad80b0`, the scraps-door removal — verified by
> its two neighboring suites; your kickoff full runs are the standing
> verification). Flake carry: the Phase-12 latency pin; and
> `CanvasDragTrackingTests` at ONE recorded red — **a second red
> promotes it** to a KnownIssues row (owner 12), disposition standing.
> ZERO schema expected anywhere in this round (the Archived surface
> is read-side over `archived_at`); zero `Sources/VariorumCore/Sync/`.

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
- **D1:** takes NEST under their block's row — her words: *"nested
  under their block, with a clear note or color change if the block
  itself isn't deleted"* — i.e. when the BLOCK is alive and only the
  take died, the parent row must visually read as context-not-victim
  (a note line or color distinction, never the same face as a
  deleted block). Top level of the Trash = notes · books · blocks
  (+ context-parents); this satisfies her earlier *"trash should
  default to showing blocks"* instinct by construction — record the
  default's reasoning in the build; if she still wants a Blocks
  default filter after seeing it, it is a one-line change at her
  word.
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
| 14 | **F1 — ARCHIVE RIDES BESIDE DELETE AT EVERY BLOCK DOOR** (her second morning report, 2026-08-24: *"I only see delete this block in the block menu"*). The menu BAR's Block menu already pairs them adjacently (13j's letter — verified in `EditorCommands.swift`); the gap is every OTHER door that offers a block Delete without the Archive twin (context/row menus — enumerate via the registry, the door-set is checkable). Same pass verifies the TAKE-card menus: Write's panel ⋯ carries Archive · Label · Lock · Delete (verified) — Takes mode's card grammar must match. **Context for the builder: the 13l walk's P-6 sentence ("the only door that deletes a take is inside the archived strip") is OVERSTATED — active take cards carry Delete; do not build against P-6's wording.** Her open musing, verbatim, for the round's checkpoint — *"I don't even know if we need take archiving if I'm not seeing it right now?"* — with the architect's recommendation recorded: KEEP the capability (her own morning argument — archive is forever-valuable and distinct from the clock — applies to takes exactly; the model's I10-rescue and pool-copy semantics also mint archived states), FIX the doors; retiring it is hers to rule if the fixed doors still don't earn it | open |
| 15 | **F2 — HER MISSING-TAKE REPORT: verify or trace.** She deleted a take from Write's take-card ⋯ and cannot find it in the Trash (*"it's not in trash"*) — and the block now shows no fan. The take MUST be findable in (a) the block's History-face past region (13j J3) and (b) the Trash (Takes/Everything). Reproduce on the dev store FIRST: if rows list but are unrecognizable, A3/D1 are the fix; **if a deleted take genuinely does not list, that is a DEFECT — trace it red-on-old** (the take arm's conditions: tombstone, cutoff, live block, no intent). Either way the checkpoint answers her plainly: where a deleted take goes, in one sentence, verified by driving it | open |

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
