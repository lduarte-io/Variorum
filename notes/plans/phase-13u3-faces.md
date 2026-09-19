# Phase 13u3 — FACES (EXECUTION PLAN)

**Status: OPEN 2026-09-18, at her word** (*"hello fable! you'll be the orchestrator for this
session. /architect-phase 13u3 - the faces phase. I believe that's what we're on, let me know if
any questions come up. Standard Opus implementer Fable cold review standards should apply."* —
confirmed at the kickoff preflight: 13u2b closed the same day and the master plan's pointer names
13u3 next). Authored 2026-09-14 at the 13u1 kickoff (the R-cor-12 four-way split; the shared
sitting's rulings live in `phase-13u1-editor-seam.md`'s SITTING RECORD and bind here). **The
running record is the GOVERNANCE / SITTING RECORD / UNIT PLAN / LEDGER sections below the
closeout-refresh blocks.**
**The binding item record is the master plan's `### 13u` section** (items 3 · 4 · 14 · 15 · 16,
item 9's Mac face, plus the 2026-09-14 item 20). Where this file and that section disagree, that
section wins.

## Roster (R-cor-12's 13u3 list + what accrued since)

1. **Item 3 — the comments-area rework, NOW CARRYING R-13u-9 (her 2026-09-14 gutter reversal —
   the master plan's item 20 has her words verbatim; SUPERSEDES #102's built direction (a) and
   R-Q16):** comments and callouts render in the margin/whitespace gutter, OUTSIDE the text
   area; the text's measure and left edge NEVER move because a note carries a comment or a
   callout glyph — the 17p-b lane-reserves-measure approach is out on every surface it reached
   (`reservesDecorLane`; the #102 sweep pin names the cells). Her standing item-3 ask rides the
   same rework: the add box grows into the area it owns; the whole comment surface behaves like
   a text editor; "the comments still also aren't spaced well." The decoration-lane residuals
   row (KnownIssues — Write's minGutter badge room; the multi-glyph clip) dissolves INTO this
   rework or is re-verdicted by it. R9's sacred margins bind: the gutter is the whitespace the
   page already owns, not new chrome.
2. **Item 4 — note-list skimmability, RULED** (derived display-name snippet; ONE pure Domain
   brain; journal cards stay date-led; the title-suggestion chip at capture; stored auto-title
   rejected). Sitting residue is detail only (snippet length / ellipsis / typography). The Pool
   card preview is BUILT (Act 10 row 87) — the one-brain card family is still this item's.
3. **Item 9's Mac face** — the quick-capture surface built to R-13u-4 (⏎ files · ⇧⏎ paragraph;
   many-paragraph capture; hand-off through `importPost`'s bulk rule). The phone's face is the
   mobile catch-up's, built to the same ruling.
4. **Item 14 — named commits** (`commit_point.message` gets its face: optional name at the
   manual-commit door, enter-to-skip keeps ⌘S instant; names in Block History + listings; the
   name-editability detail is the sitting's).
5. **Item 15 — the #80(e) ratification's two faces** (the restore confirm names what it takes;
   the tutorial's versions-copy-placed-only lesson).
6. **Item 16 — the PDF export renders formatting** (reuse the Mac's markdown display brain for
   the export's attributed strings; projection change only; typographic pass stays 13m's).
7. **KnownIssues row re-owned here at the split: the merge sheet's RUN arm drift check + the
   four 18f-ladder residuals** (the ceremony sheets are the faces phase's after the use-report
   round).

## Cast, evidence, discipline

Cast at its kickoff (expected: `opus-implementer` per unit · `opus-reviewer`, with
`fable-reviewer` if any diff reaches the editor seam or `PaneTextAuthority` — the gutter rework
may, via the read-tier factory). Faces close on USE evidence (walks, captures, both voices, both
appearances); red-on-old for defect-shaped rows; zero `Sync/`, zero schema. The checkpoint
protocol restated in every brief.

## REFRESHED AT THE 13u2 CLOSEOUT (2026-09-15 — the overnight run; kickoff-ready)

**BASELINES AT OPEN (13u2's finals — the previous close's recorded result; never run the full
suite at a session's start):** core `swift test` **1567 / 171** all green · the FULL Mac suite
**2744 / 459** — green with **1 KNOWN ISSUE** (`BookOutlineLandingTests`' wrapped far-below arm,
`abs(below) → 73.0` — the scale-mix residual, KnownIssues owner 12; it reports on every run and
trips as an UNEXPECTED PASS if it comes right) and **1 recorded environment red**
(`theReadClickLandsInIndexAtThatBlock` — its KnownIssues row, owner 12: 3/3 red isolated on every
tree measured at the 13u2 close incl. zero-code scratch worktrees; the product road walked clean
twice; treat a red there as that condition unless your diff touches the book Index) · iOS build
**green** · the FULL mobile suite **626 / 106 PASSED with 4 known issues** · lockstep marker
**8** · installed `/Applications/Variorum.app` = the 13u2 Release (hashes in
`notes/handoffs/phase-13u2-handoff.md`). **Flake list (13u2 UPDATED it):** the
differential-latency pin · `CanvasDragTrackingTests` · `BlocksWorkbenchFaceTests`' single-click
budget · the read-click row above. `MastheadLayoutTests`' open-field arm is OFF the list (fixed
at 13u2 unit E — an until-clause settle; do not re-add it on rumor).

**WHAT 13u2 CHANGED UNDER YOU — read before touching these surfaces:**
1. **The status seam's doors are RENAMED** (`StatusCenter.refuse/offer/direct`;
   `EditorViewModel.refuse/direct/directTransiently`; `setReceipt`/`clearStatus`) and
   `TakesViewModel.status` is UNWRITABLE outside its three classed doors (`statusSlot` private;
   `status = …` does not compile). `StatusSeamVocabularyTests` fails the suite if a banned
   spelling returns. Item 14's commit face and item 3's rework speak through these doors; the
   registry-walk shape (row 56's step 3) is owner 12's — do not start it here, but new doors you
   mint should be trivially classifiable.
2. **`EditorRouter.active` is claimed by the text view that REACHES A WINDOW** (the shadow fix);
   `editingOrActive` semantics unchanged. The Outline's double realization survives (owner 12) —
   if the gutter rework touches `InlineEditorSurface`, know it realizes twice on long notes under
   Outline and the probe question is `window != nil` + `index.entries.count`, never "the first
   editor".
3. **`BookViewModel.adopt` is `async` and PRIMES card previews before publishing**
   (`Queries.leadingBlockTexts`, bounded); `OutlinePostRow.excerpt` reads the book's map. Item
   4's card family should CONSUME this road, not re-derive previews per row.
4. **The DEBUG oracles are scoped by session identity** (`DebugProbeScope`, environment-travelled;
   readers per oracle; `unscoped` fails loud). New geometry pins follow that pattern — never a
   bare static.
5. **`TakesArticleScroll` is its own type** (876 lines out of `TakesBoardLayout`; every pre-move
   name forwarded) with ONE structural arm at `adopt` ending a pending landing on any projection
   change (#113 records the metadata-arrival caveat, PROVISIONAL).
6. **The R14/R22 editing-indicator setting now governs the during-editing mark on the index
   surfaces too** (#110(c)); the left-column highlight and the first-click wash sit deliberately
   OUTSIDE it. Item 3's gutter rework composes with this grammar — do not mint a rival register.
7. **⇧⌘V is taken** (paste-without-line-breaks, `Shared/PlainPaste.swift`). Item 9's capture face
   and item 14's commit field must not claim it.
8. **Item 13's title room was measured HEALED on the Mac** (~48 chars, ends at the scraps icons,
   pinned at two widths) — item 4's card-identity work settles WITH that as the standing state;
   the ~30-char constraint is the PHONE's (PL-24 (b)).

**HER OPEN ITEMS THAT TOUCH THIS PHASE (from the 13u2 morning bundle — check QUESTIONS before
building):** #112(b) the STAR CAP (if she raises it, the starred scroll's first real-app exercise
should get a quick walk — the 13u2 ladder's note); the ⇧⌘V grey-vs-refuse taste call (a
13u4/13s-class item unless she routes it here); #110(c)'s `off`-value consequence. The
lane-reserves-measure residuals row (KnownIssues) dissolves into item 3's rework exactly as the
roster says.

## REFRESHED AT THE 13u2b CLOSEOUT (2026-09-18 — the landing-seam overnight run; kickoff-ready)

**BASELINES SUPERSEDE the 13u2 block above:** the FULL Mac suite is now **2794 / 466** — green with
**ZERO known issues** (row 64's wrapped far-below arm is GONE: unwrapped, ≤4, green under full-suite
load — do NOT re-add it on rumor; its harness-timing note lives in KnownIssues row 49) and **1
recorded environment red** (`theReadClickLandsInIndexAtThatBlock`, row 58, unchanged) · core
1567/171 (the star-cap commit's symbolic pin edit; counts unchanged) · mobile 626/106 w/4 known
(untouched — nothing mobile-visible shipped) · marker 8 · `/Applications/Variorum.app` = the 13u2b
Release (hashes in `notes/handoffs/phase-13u2b-handoff.md`; includes the star cap 5→15).

**WHAT 13u2b CHANGED UNDER YOU — read before touching the book columns, landings, or mode switches:**
1. **The Outline's small-row runs are EXACT-GEOMETRY plain stacks** (placeholders from
   `Surface/BookHeightManifest.swift`; near-viewport realization via the row-53 pattern). NO lazy
   estimate remains in the book columns — a new row kind must supply a height source (constant,
   remembered, or lengths-derived) or realize eagerly. Item 3's gutter rework must keep decorations
   OUT of the height model or TEACH the manifest about them — a decoration that changes a row's
   height without the manifest knowing reintroduces the drift class this phase killed.
2. **`Surface/LandingAuthority.swift` is THE settle discipline** (pure `LandingSettle.decide` +
   per-surface `LandingPolicy`; the DEBUG story and the content-free RELEASE SIGNPOST come free
   with adoption). Outline and the Read▸Scroll flow consume it; Takes/Index adopt at their next
   touch — **never fork a new aim/hold/hop loop.**
3. **Mode switches carry a viewport fraction** (`Surface/ViewportCarry.swift`; in-memory one-shot
   slot on the router with three doors — take/take-place/drop). Write and Read consume; Takes is
   OUTRANKED by R-Q20/21 by ruling. **A new mode-writing road must join the re-decide or the drop**
   (the excluded-roads comment at `PostDetailView.switchMode` names the rule).
4. **Open PROVISIONALs on this seam:** QUESTIONS #114 (U3's scope edges) · #115 (the width-change
   keep; (b) the VOICE re-land RECORDED UNBUILT with two load-bearing guards — item 3's rework may
   adopt it if it touches that road) · #116 (the fraction's three sub-calls). The Write-direction
   carry mirror is a KnownIssues row, owner 12 — do not fix it casually; the honest fix heals the
   router's fact-staleness asymmetry and both directions come right for free.
5. **`ProseHeightModel` is the ONE prose height model** (Outline + flow). The re-font/typography
   work this phase's items touch must go through it, never a second estimate.

---

## GOVERNANCE (2026-09-18, the kickoff)

**The author invoked `/architect-phase 13u3` — her cast, from her kickoff message: *"Standard Opus
implementer Fable cold review standards should apply."*** So: the orchestrating session holds the
ARCHITECT MANDATE (the R117 shape; `.claude/skills/architect-phase/SKILL.md` governs beside
CLAUDE.md — CLAUDE.md wins on conflict); implementers are **`opus-implementer`**, one FRESH session
per unit, ONE acceptance unit per session (the sizing guidance's rule 1); the ladder's cold
reviewer is **`fable-reviewer`**. *(The roster's earlier "expected: opus-reviewer, with
fable-reviewer if the seam is reached" is superseded by her kickoff word — and item 3's gutter
rework likely reaches the read-tier factory anyway, so Fable review was the right call under the
old wording too.)* The 13b constitution below is BINDING; the skill's application notes (P-1's
routed-vocabulary scope, P-3's two deliberate surface kinds, the layer-placement and overlay/sink
laws) bind by reference.

## BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied verbatim per the skill's rule)

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


**How the constitution bites HERE (application, not modification):** **P-5 FIRES on item 3** — the
comments area has the friction doctrine's exact signature (the small-add-box complaint → 17p-b's
lane build to R-Q4 → her 2026-09-14 reversal, item 20: *"I approved comments moving all of the text
to the right but now that I see it, I think it's ugly and weirdly spaced"*), so the gutter rework
gets a DESIGN MEMO before its build (`notes/plans/phase-13u3-memo-gutter.md`): behavior whole,
edges enumerated (narrow widths, Write's minGutter, the multi-glyph callout — KnownIssues row 50's
residuals dissolve or re-verdict here — the add-box-as-editor, her "not spaced well"), her rulings
on the product edges, then the build follows the memo. **P-8 + the 13u2b manifest rule bind the
gutter's geometry:** decorations stay OUT of the book columns' height model or TEACH
`BookHeightManifest` about them (the 13u2b closeout's own warning); overlays, never rendering
attributes; the text's measure and left edge NEVER move (R-13u-9's letter). **P-3 is a FENCE:** the
rework composes on the read tier / pane surface and Write's full editor; it extends NO liveness
mechanism, and any touch of `PaneTextAuthority` / the read-tier factory is exactly why the ladder
is Fable. **P-2/P-1:** the new doors (the commit-name field, the rename door, ⇧⏎ in capture) fire
and DO, speak through the status seam's three classed doors (13u2's rename — refuse/offer/receipt,
trivially classifiable), and declare registry entries where they route through shared doors.
**P-6:** the tutorial spine rides every unit's end verification — and item 15(b) EDITS a lesson
deliberately (a content change WITH its pins, never a broken step; the closeout's re-seed note
applies). **P-9:** item 4's snippet brain is ONE pure Domain function; no card derives its own.

## THE KICKOFF SITTING RECORD (2026-09-18 — author present at kickoff; rulings verbatim-faithful)

The ONE shared 13u sitting (2026-09-14, R-13u-1…R-13u-11) already rules this phase's substance;
today's kickoff added the cast (GOVERNANCE above) and two calls:

- **R-13u3-1 — NAMED COMMITS ARE EDITABLE AFTER THE FACT.** Asked as item 14's reserved sitting
  detail ("should a savepoint's name be editable after the fact?"); she chose **"Editable
  (Recommended)"** — a rename door in Block History beside the savepoint; the snapshot TEXT stays
  immutable (I5 untouched); `message` is metadata under server-version-wins CAS, so sync is
  trivial either way. (The offered alternatives — frozen once written; editable-manual-only — were
  declined by the selection. The recommended option's description, which she selected, includes
  the auto-commit question implicitly: the door renames; auto-commits keep their occasion label as
  the DEFAULT display, and a rename applies to `message` wherever the door is offered. Whether the
  rename door is offered on AUTO savepoints too is a build-time detail — the unit brief says offer
  it everywhere `message` exists, since her selection was the unqualified "Editable" over the
  manual-only alternative.)
- **R-13u3-2 — STANDARD METHOD + THE REFRESH PRE-AUTHORIZED.** She chose **"Standard + refresh
  pre-authorized (Recommended)"**: PROVISIONAL-and-continue binds the run (judgment calls recorded
  here + QUESTIONS; no stop-and-ask except the standing author-only hard stops and item 3's memo
  edges, which she is present to rule); the **`/Applications` refresh is PRE-AUTHORIZED** at the
  phase's finish on the standing rails (A1 backup FIRST, zero instances verified at every step,
  Release from a clean worktree, codesign + hashes recorded, her store never opened); the author
  handoff written LAST, her checklist at the top.

## THE UNIT PLAN (acceptance units + evidence, named at plan time per the sizing guidance)

ONE phase-sized unit (A) + six batch-sized units, one implementer session each, strictly
sequential. Every unit: red-on-old for defect-shaped rows; the standing suites + the tutorial
spine green at its end; the implementer walks and captures on the dev-store Debug build (both
voices, both appearances where chrome changes); the orchestrator verifies by record and walks the
phase's acceptance before the ladder (the C-rules shape she amended at the first use-report round).

| unit | scope | acceptance evidence |
|---|---|---|
| **A — the GUTTER rework (item 3 + row 50)** | Comments + callouts render in the whitespace gutter OUTSIDE the text area on every surface the lane reached (`reservesDecorLane` retired); the text's measure/left edge never moves; the add box grows into the area it owns; the comment surface behaves like a text editor; spacing per the memo; row 50's two residuals dissolved or re-verdicted. **Builds only AFTER the memo's edges are ruled.** | USE: the orchestrator's hands-on walk — a commented note, a callout note, a multi-glyph callout, Write + book Outline + Read tier + note window + spread book, both voices, both appearances, narrow + wide windows; the #102 sweep pin cells re-verdicted; book-column landings still land (13u2b's suites green under load) |
| **B — note-list skimmability (item 4)** | ONE pure Domain snippet brain (cap + word-boundary trim; explicit title wins; journal cards stay date-led); the Library List + Notes cards + Pool card family consume it (and `BookViewModel.adopt`'s primed previews, never per-row derivation); the title-suggestion chip at quick-note/capture (offered, one tap, ignorable; never an action taken for her); detail residue (snippet length / ellipsis / typography) built PROVISIONAL | USE: Library walk over her-shaped fixtures (titled, untitled, journal, long-first-sentence notes); the brain's edge-case tests; stamps/#103 arrangement unharmed at both widths |
| **C — the quick-capture Mac face (item 9, R-13u-4)** | ⏎ files · ⇧⏎ adds a paragraph; many-paragraph capture TYPED, not only pasted; hand-off segments via `importPost`'s bulk rule; both Mac capture surfaces (the shelf quick-entry bar + the system-wide quick note) to ONE rule; ⇧⌘V untouched (taken) | USE: type a three-paragraph capture in both surfaces, file it, verify the blocks; the lost-prose class from her 2026-08-23 report cannot reproduce (caret into an earlier paragraph, then ⏎ — files, drops nothing) |
| **D — named commits (item 14, R-13u3-1)** | Optional name at the manual-commit door, enter-to-skip keeps ⌘S instant; names in Block History savepoint runs + listings; the RENAME door beside the savepoint (editable per R-13u3-1); auto-commits keep their occasion as the default label; zero schema (`message` has existed since v1) | USE: ⌘S skip-fast, ⌘S with a name, rename after the fact, an auto savepoint's label untouched; state-transition tests for the op's `message` writes |
| **E — the #80(e) two faces (item 15)** | (a) the restore confirm NAMES what it takes (set-aside originals + never-traveled takes) and points at PROMOTE as the zero-loss road; (b) the tutorial's versions-copy-placed-only lesson (copies carry neither history nor commits — one lesson covers both) | USE: the confirm read in the flow it interrupts; the tutorial spine green WITH the new lesson's pins; the closeout re-seed note recorded for her store |
| **F — the PDF export renders formatting (item 16)** | The export's attributed strings built from the Mac's own markdown display brain; projection change ONLY (`renderedText` / bridge / `.md`-export semantics byte-untouched, pinned); typographic pass stays 13m's | USE: export a formatted note + a book to PDF, open both — bold/italic/headings/lists render, no raw syntax; `.md` export byte-identical before/after |
| **G — the ceremony-sheet residuals (row 42)** | The merge sheet's RUN arm gains the shown-take drift check (the pair arm's class); the four 18f-ladder NITs per the round-3 record's fix shapes (open-time projection read; the stale pre-pair under "Pair by hand…"; the board's instant road's `variants[0]` park; `renderPost`'s two-id read) | Red-on-old for the drift check (a store write between open and confirm); the sheet walked on a fanned run; the 18f pins green |

**Order: memo → A → B → C → D → E → F → G → the ladder (fable-reviewer, combined diff) → walks →
closeout + refresh.** A is first (deep surgery before polish — the 13u split's own reasoning);
D/E/F/G are independent and may reorder if a death makes that cheaper. Fences phase-wide: **zero
`Sync/` · zero `Persistence/` · zero schema · zero migrations · the marker stays 8 · nothing
touches her real store outside the pre-authorized refresh.**

## THE LEDGER (every row owned; statuses flip in the same commit as the work)

| # | item | status → owner |
|---|---|---|
| 1 | The gutter DESIGN MEMO (P-5) + her edge rulings | OPEN — the orchestrator, next act |
| 2 | UNIT A — the gutter rework (item 3 + KnownIssues row 50) | NOT STARTED — gated on row 1 |
| 3 | UNIT B — note-list skimmability (item 4) | NOT STARTED |
| 4 | UNIT C — the quick-capture Mac face (item 9 / R-13u-4) | NOT STARTED |
| 5 | UNIT D — named commits (item 14 / R-13u3-1) | NOT STARTED |
| 6 | UNIT E — the #80(e) two faces (item 15) | NOT STARTED |
| 7 | UNIT F — PDF renders formatting (item 16) | NOT STARTED |
| 8 | UNIT G — the ceremony-sheet residuals (KnownIssues row 42) | NOT STARTED |
| 9 | The ladder — `fable-reviewer`, combined diff, standing rounds | NOT STARTED |
| 10 | The orchestrator's walks + closeout ritual + the pre-authorized `/Applications` refresh (R-13u3-2) | NOT STARTED |
