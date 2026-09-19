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
- **R-13u3-3…R-13u3-6 — THE GUTTER MEMO'S FOUR EDGES, all ruled the same sitting** (the memo's §3
  carries them in full, her words verbatim): **R-13u3-3** the callout glyph and the comment face
  STACK VERTICALLY AT EVERY WIDTH (her words: *"stack them at any width, I think it would look
  better."* — stronger than the memo's proposed narrow-only stacking; `commentClearance`'s
  horizontal-clearance arithmetic retires); **R-13u3-4** a callout's leading glyph is ONE GRAPHEME
  (the prompt keeps the first and says so; row 50's clip residual dissolves); **R-13u3-5** the
  inline-comments setting SURVIVES as her explicit opt-in (the law governs the default margin
  presentation); **R-13u3-6** comment editing lives in the PANEL ONLY (the margin card stays a
  read face and a door; one live-text home).

## THE UNIT PLAN (acceptance units + evidence, named at plan time per the sizing guidance)

ONE phase-sized unit (A) + six batch-sized units, one implementer session each, strictly
sequential. Every unit: red-on-old for defect-shaped rows; the standing suites + the tutorial
spine green at its end; the implementer walks and captures on the dev-store Debug build (both
voices, both appearances where chrome changes); the orchestrator verifies by record and walks the
phase's acceptance before the ladder (the C-rules shape she amended at the first use-report round).

| unit | scope | acceptance evidence |
|---|---|---|
| **A1 — the GUTTER geometry rework (item 3's page half + row 50)** | Comments + callouts render in the whitespace gutter OUTSIDE the text area on every surface the lane reached (`reservesDecorLane`/`DecorLaneReservation` retired); the text's measure/left edge never moves (the memo's one law); the R-13u3-3 stack at every width; the R-13u3-4 one-grapheme guard; margin-card spacing rhythm; row 50's two residuals dissolved. **Built to the memo — its §2/§3 are the design.** | USE: the orchestrator's hands-on walk — a commented note, a callout note, a multi-comment block, Write + book Outline + Read tier + note window + spread book, both voices, both appearances, narrow + wide windows; the #102 sweep pin cells re-verdicted; book-column landings still land (13u2b's suites green under load) |
| **A2 — the comments PANEL as a text editor (item 3's panel half, memo §2 D)** | The panel re-formed as ONE writing surface: comments edit in place (no bordered-field swap), the add area owns all remaining space (click anywhere → caret; grows; ⌘⏎/Add files; Esc clears), deleted fold + restore kept, status-seam classed doors; R-13u3-6 (panel-only editing) binds | USE: the panel exercised as an editor on a multi-comment block (click-anywhere, grow, file, edit in place, delete/restore), both voices, both appearances |
*(The plan's original single "UNIT A" split at plan time per the sizing guidance's one-unit-per-session rule — item 3 holds two acceptance units, said out loud rather than bundled.)*
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
| 1 | The gutter DESIGN MEMO (P-5) + her edge rulings | **DONE 2026-09-18** — `notes/plans/phase-13u3-memo-gutter.md` (`73a6ea17` + the rulings commit); all four edges RULED at the sitting (R-13u3-3…6) |
| 2 | UNIT A1 — the gutter geometry rework (item 3's page half + KnownIssues row 50) | **DONE 2026-09-18** — `bb31912e`…`3263a1e6`; the UNIT A1 RECORD is at the end of this file (host table · traced mechanisms · 15 pins with red-on-old · 12 walk captures · finals). Row 50 RESOLVED; QUESTIONS #117 opened |
| 2b | UNIT A2 — the comments panel as a text editor (item 3's panel half, memo §2 D) | **DONE 2026-09-18** — `52cd0cc4`…`afc108ee` + this record's close; the UNIT A2 RECORD is at the end of this file (the writing semantics as one brain · 16 pins with the red-on-old table · the walk's four finds and 19 captures · finals). QUESTIONS #118 opened |
| 3 | UNIT B — note-list skimmability (item 4) | **DONE 2026-09-19** — `2d083439`…`7aac721c` + this record's close; the UNIT B RECORD is at the end of this file (the contract as built · 27 pins in 4 suites · the walk's 18 captures and its one defect · the suite find traced on two trees · three things handed up · finals). QUESTIONS #119 opened |
| 4 | UNIT C — the quick-capture Mac face (item 9 / R-13u-4) | **DONE 2026-09-19** — `cf3d86c2`…`9da5bec3` + this record's close; the UNIT C RECORD is at the end of this file (the contract as built and why the box is AppKit · the traced refusal defect with its red-on-old · 18 pins in 3 new suites · the walk's 16 captures in both voices and both appearances and the two things it found · three things handed up). QUESTIONS #120 opened |
| 5 | UNIT D — named commits (item 14 / R-13u3-1) | NOT STARTED |
| 6 | UNIT E — the #80(e) two faces (item 15) | NOT STARTED |
| 7 | UNIT F — PDF renders formatting (item 16) | NOT STARTED |
| 8 | UNIT G — the ceremony-sheet residuals (KnownIssues row 42) | NOT STARTED |
| 9 | The ladder — `fable-reviewer`, combined diff, standing rounds | NOT STARTED |
| 10 | The orchestrator's walks + closeout ritual + the pre-authorized `/Applications` refresh (R-13u3-2) | NOT STARTED |

## ENVIRONMENT TRAPS (every unit brief carries this section verbatim — the skill's rule)

- **Instance checks:** `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — **NEVER quit or
  kill one**; no Release builds or `/Applications` refreshes while one lives; install refreshes only
  at sanctioned zero-instance windows (this phase's is the closeout's, pre-authorized R-13u3-2).
- **Builds/tests:** Mac tests run from `App/Variorum/`, suite-level `-only-testing` only; confirm
  the "Test run with N tests" line (Swift Testing COUNTS skipped tests — read the `skipped:` lines);
  `xcodebuild build-for-testing` compiles without the runner; **NEVER add a custom build
  configuration** (any configuration not named exactly "Debug" builds SPM dependencies RELEASE and
  silently strips VariorumCore's DEBUG-gated oracles); zsh `pipestatus` for pipeline exit codes.
- **Suites beside a live session flash the test host's windows** — prefer zero-instance windows for
  timing-sensitive measurements; the differential-latency, `CanvasDragTrackingTests`,
  `BlocksWorkbenchFaceTests` single-click and read-click (row 58) reds are the load-flake list —
  adjudicate by the paired protocol, never a single isolated run.
- **Walks:** dev-store Debug build only (`io.lduarte.Variorum.debug`), `Tools/WalkKit/` + `cliclick`;
  screenshots in gitignored dirs (`notes/plans/13u3-screens/`); the Debug domain's `surfaceSize.*`
  keys may be wiped to stage cold runs (they regenerate) — NEVER the real store's.
- **Git:** never `git checkout` over uncommitted work; commit per piece and **PUSH after every
  commit** (CLAUDE.md's 2026-08-03 push rule; the skill's 13b-era "never push" line is superseded —
  CLAUDE.md wins). No commit trailers.
- **Backups:** any act near the real store takes the A1 rail first (WAL-safe, UTC-named) — this
  phase should never touch it before the closeout refresh.

## CAST & DISCIPLINE

**Orchestrator: Fable — this session** (her kickoff word; writes no feature code beyond
adjudication/record acts). **Implementer: `opus-implementer`, a FRESH session per unit, strictly
sequential, one at a time, ONE acceptance unit each.** **Cold review: `fable-reviewer`** over the
combined diff at the phase's end (her kickoff word; the standing ladder — fresh reviewer per
round, the cross-model flow since the implementers are Opus, cap three rounds). The hallucination
guard binds every fix (trace the mechanism yourself; red-on-old pins, behavioral-revert verified;
a pin green on both sides is DISMISSED as hollow and recorded). PROVISIONALs log to
`notes/QUESTIONS.md` (next free **#117**). Author-only calls are hard stops. **Session resiliency
(the checkpoint protocol, RESTATED in every brief):** commit per coherent piece + push after every
commit · the unit record's LIVE STATUS section written at the START and flipped in the same commit
as each piece, unverified claims marked PENDING · synchronous foreground waits only, via the
grep-poll loop (`grep -q '<EXIT LINE>' <log> && break; sleep 5` — never `tail -f | grep -m1`,
never a backgrounded run you end your turn on) · never spawn subagents · no revert starts until
the record names it and the pre-revert state is COMMITTED (never scratchpad copies) · every death
and resume noted in the record.

**The walk vs. her walk.** The IMPLEMENTER walks and captures each unit on the dev-store Debug
build (both voices, both appearances where chrome changes); the ORCHESTRATOR verifies by record
and walks the phase's acceptance before the ladder (the C-rules shape she amended at the first
use-report round); HER one walk rides the refreshed install at the end.

---

## UNIT A1 BRIEF — THE GUTTER GEOMETRY REWORK (self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 1 · GOVERNANCE + the
constitution + "how the constitution bites here" · THE KICKOFF SITTING RECORD (R-13u3-1…6) · both
"REFRESHED AT THE …" closeout blocks (the 13u2b one's item 1 — the height-manifest warning — and
item 5 — `ProseHeightModel` — bind your geometry directly; the 13u2 one's items 1/2/6 name the
status seam, the Outline's double realization, and the indicator grammar you compose with) · the
ENVIRONMENT TRAPS and CAST & DISCIPLINE sections above. (2) **`notes/plans/phase-13u3-memo-gutter.md`
IN FULL — it is the design; you build to it.** §2 A is your mechanism, §3's rulings R-13u3-3/4 are
binding product law. (3) `notes/TEXTKIT2_NOTES.md` §3–§4 (overlays never rendering attributes; no
TK1 APIs; the 17o `usageBoundsForTextContainer` ratchet — `PaneMeasurement` reads fragments) and
the macOS-26 attribute-fixing note (clamp to the verdict's range, never the report's). (4) The
code the memo §1 traces: `Surface/DecorLane.swift` · `Features/Editor/BlockDecor.swift` (geometry
+ `BlockDecorOverlayController`) · `Features/Editor/EditorTextView.swift` (`updateGutters`,
`reservesDecorLane`, the contained factory) · `Surface/PaneSurface.swift` (the read factory + the
measurement brain and its width gate) · `Theme/EditorTypography.swift` (the constants) ·
`VariorumTests/BlockDecorLaneTests.swift` (the cells you re-verdict) and the #102 sweep pin.

**Scope (ONE acceptance unit — the page-side geometry; the PANEL is unit A2's, not yours):**
1. **The one law** (memo §2, opening): no decoration moves the prose column's measure or left
   edge, on any surface, ever. Contained surfaces adopt Write's own gutter shape — the text
   view's frame absorbs the host row's whitespace; the container origin is computed so
   `containerWidth = min(maxColumnWidth, viewWidth − 16)`, **byte-identical to today's
   clamp-then-inset at every window width** (prove it: heights unchanged ⇒ `BookHeightManifest`
   learns nothing; if you find ANY width where the measure would differ, STOP and return to the
   orchestrator with the arithmetic — the in-batch design fork is the architect's, never yours).
   Enumerate the HOSTS by sweep (the #102 pin's cells + a fresh grep — the known cells: the book
   Outline's inline editor and read tier, the workspace read-cheap pane, the note window's read
   face, the spread/paged book): a per-cell table in your record, each cell CONVERTED or provably
   N/A. `DecorLaneReservation`, `reservesDecorLane`, `onProseColumnChanged` and `updateGutters`'
   laned-surface precondition retire dead — no dormant machinery.
2. **The stack (R-13u3-3, at every width):** glyph at the block's first line, the comment face
   (card ≥ 150, badge below that) directly under it; one block with one decoration shows it at
   the first line; below badge room the badge clamps to the page edge, never over prose.
   `commentClearance`'s horizontal arithmetic retires.
3. **The callout wash hugs the prose column** (no leading extension into the gutter); the glyph
   moves fully into the gutter (memo §2 C).
4. **The one-grapheme guard (R-13u3-4)** at `promptEmoji`, with the field saying so.
5. **Margin-card spacing rhythm** (memo §2 B): first-line top alignment, fixed inner pad, minimum
   air between stacked neighbours (two commented blocks' cards never abut), the drag-handle lane
   respected. Taste details PROVISIONAL with captures.
6. **The mechanism riders:** the width-gated remeasure gates on CONTAINER width, not frame width;
   `SurfaceSizeMemory`'s old-width entries read absent once (record it, harmless); DEBUG geometry
   oracles follow the `DebugProbeScope` pattern (13u2's item 4 — never a bare static).
7. **Pins:** the one-law pin (same note ± comment ± glyphed callout on every surface kind —
   `textLeft`/`textRight`/fragment origins byte-identical); the stack geometry pin at wide AND
   `minGutter`; the card-rhythm pin; the one-grapheme guard pin; the #102 sweep pin cells
   re-verdicted to the new law; red-on-old (behavioral revert) for every defect-shaped cell
   (row 50's collision and clip are defect-shaped: show them red on the pre-fix tree). Retire
   `BlockDecorLaneTests`' lane cells INTO the successor pins — zero orphaned test names.
8. **KnownIssues row 50:** rewrite it RESOLVED at your close (both residuals dissolved by
   R-13u3-3/4), in the same commit as the work that resolves it.
9. **Fences:** zero `Sync/` · zero `Persistence/` · zero schema · the marker stays 8 · the full
   editor's identity machinery (`BlockRangeIndex`, crystallization, the reconciler) untouched —
   your diff is geometry and overlay code; if you find yourself editing the identity seam, stop
   and report. iOS build must stay green (shared files you touch compile there).

**End verification (yours, before the record closes):** the FULL Mac suite (expect 2794/466 ±
your additions; the ONE tolerated red is row 58's environment condition — anything else is
yours); the tutorial spine green in-run; iOS build green; YOUR walk with captures on the
dev-store Debug build — the memo §4 walk (both voices, both appearances, wide + `minGutter`
windows), captures to `notes/plans/13u3-screens/` (gitignored). Record: a **UNIT A1 RECORD**
section appended to this file — LIVE STATUS from the first commit, the host table, the traced
mechanisms, pin list with red-on-old evidence, walk notes + capture names, finals, and a UNIT
CLOSED banner when done.

---

## UNIT A1 RECORD — THE GUTTER GEOMETRY REWORK (opus-implementer, 2026-09-18)

**WHAT THIS UNIT DOES NOT DO (the record's first line):** the comments PANEL is untouched
(unit A2's, memo §2 D); no `Sync/`, no `Persistence/`, no schema, no migration, the marker stays
8; the full editor's identity machinery (`BlockRangeIndex`, crystallization, the reconciler) is
not touched; the inline-comments SETTING's tinted strips are unchanged (R-13u3-5); item 3's
"add box grows / whole comment surface is a text editor" is A2's half.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | the record + `13u3-screens/` gitignored | **DONE** |
| 1 | `ProseGutter` — the ONE gutter brain; both contained surfaces + Write adopt it; `DecorLane` retires | **DONE** (`ProseGutterTests` 20/20 green with its two neighbours; `BlockDecorLaneTests` retired INTO it) |
| 2 | the four HOST cells converted (bleed + preset), the host table proved byte-identical | **DONE** (the table below; `theProseColumnIsAPureFunctionOfTheSurfacesWidth` pins every cell at ten widths) |
| 3 | the decoration geometry: wash hugs the prose, the R-13u3-3 stack, the badge that never covers prose, the card rhythm | **DONE** |
| 4 | the R-13u3-4 one-grapheme guard | **DONE** (`CalloutMenu.firstGrapheme` at the door, `BlockDecor.leadingGlyph` at the renderer; pinned incl. family/skin-tone/flag clusters) |
| 5 | pins (one-law · stack · rhythm · grapheme), `BlockDecorLaneTests` retired INTO successors | **DONE** — 15 cells, red-on-old measured on 10 of them (the table below); zero orphaned test names |
| 6 | KnownIssues row 50 RESOLVED + QUESTIONS #117 | PENDING |
| 7 | the walk + captures, the full Mac suite, iOS build | **DONE** — 12 captures in `notes/plans/13u3-screens/`; finals below |

### THE HOST TABLE (the sweep — every host of `BlockDecorOverlayController`, plus every host of a contained surface)

The sweep found **three** production hosts of `BlockDecorOverlayController` (`grep`ped —
`EditorSurface`, `InlineEditorSurface`, `ReadPostSurface`) and **five** host CELLS, because the
read tier is mounted by four different pages. Every cell is CONVERTED; nothing is N/A.

`W` = the host PANE's width. "was" = today's clamp-then-inset; "now" = the frame's bleed + the
placement. `C = min(W − 40, BookView.proseColumn)` is the host's clamped column.

| # | cell | host | was (left · measure) | now (bleed · preset) | verdict |
|---|---|---|---|---|---|
| 1 | book Outline, FOCUSED — `InlineEditorSurface` | `BookView` → `OutlinePostRow` → `EditorView(inline:)` | `(W − C)/2 + 8` · `C − 16` | bleed `max(20, (W − 696)/2)` · `.outline` (centred, cap 680, floor 28) | **CONVERTED** — identical at every width: for `W ≥ 736` both read `(W − 680)/2` · `680`; below it both read `28` · `W − 56` |
| 2 | book Outline, EXPANDED-UNFOCUSED — the read tier | same row, `ReadPostView` | as above | as above | **CONVERTED** — the same numbers by the same rule (one brain) |
| 3 | spread/paged book — both tiers | `SpreadBookView.pageBody` | `28` · `min(W − 56, 680)` | bleed `20` · `.page` (leading, cap 680, floor 28) | **CONVERTED** — the page's LEADING anchor kept deliberately (its whitespace has always been trailing; re-centring it is a face change nobody ruled) |
| 4 | workspace read-cheap pane | `RootView.readCheapProse` | `28` · `W − 56` | bleed `20` · `.pane` (no cap, floor 28) | **CONVERTED** — NO cap, deliberately: capping this page's measure to 680 is the one thing the memo's quoted formula would have done and the one thing no ruling makes (QUESTIONS #117) |
| 5 | note window's read face | `NoteWindowView` | `28` · `W − 56` | bleed `20` · `.pane` | **CONVERTED** — cell 4's twin |
| — | Write's full-document editor | `EditorSurface` | `gutterInset` | `.write`, bleed 0 | **UNMOVED** — `gutterInset` forwards to the same rule; its LEFT edge is identical at every width. ONE recorded difference: at an ODD view width the container is now exactly 680 where the symmetric inset made it 681 (the odd half-point goes to the trailing gutter). ≤ 1 pt, and 680 is the designed measure |
| — | take panes (`makeTakeSurface`) | every board | inset 6 | `.contained`-shaped, floor 6, bleed 0 | **N/A, proved** — a take pane hosts no decoration controller at all (the grep above); it carries the one rule so no second arithmetic exists |

**THE FORK I DID NOT TAKE (the brief's stop-and-report clause), recorded rather than decided:**
the memo §2 A's formula `containerWidth = min(maxColumnWidth, viewWidth − 16)` is byte-identical
for the CENTRED clamp-then-inset cells (1 · 2) *only once the host's 20 pt pane padding is
absorbed too* — with the padding left outside, it puts the prose at 8–10 pt where the host puts
it at 28 on any pane under 736. Absorbing BOTH gives **Write's own rule** (`min(680, W − 56)`),
which is what the memo's own sentence asks for ("contained surfaces adopt WRITE'S OWN SHAPE") and
what 13c 2A has always claimed the Outline renders. Applied to cells 4 · 5 the quoted formula
would NARROW a measure that has never been capped (a 1200-pt pane: 1144 → 680), which is a face
ruling; those cells therefore keep `maxColumn: nil` and only their padding becomes gutter. That
leaves a standing inconsistency that is NOT this unit's: the workspace pane's READ face runs the
full measure while the same pane's LIVE editor (Write) caps at 680, so focusing it re-wraps the
whole note. Logged as **QUESTIONS #117**, PROVISIONAL, for her.


### THE RED-ON-OLD VERIFICATION — NAMED BEFORE IT RUNS (the checkpoint protocol)

Pre-revert state COMMITTED at `620998c1`. The revert is a **behavioural revert of the pre-fix
mechanism**, applied to the current tree and then undone — the standing method, because the
pre-13u3 tree cannot compile these pins (they name types that did not exist). Four edits, each
restoring exactly what the 17p batch b / 13 C1 code did:

1. **the lane** — `BlockDecorOverlayController.render` moves the surface's prose column when the
   note carries a comment or a callout glyph (the `setDecorLane` door, in its one-line form);
2. **the wash** — `calloutRect` spreads `12` into each gutter again (`calloutGutterPad`);
3. **the glyph** — drawn inside the wash's leading pad, clamped at 2, never yielding;
4. **the badge** — the fixed 32 pt rect clamped at `max(2, textLeft − 4 − 32)`, never narrowing.

Expected red: `noDecorationMovesTheProseColumnOnAnySurface`, both production-loop cells,
`nothingInTheGutterEverCoversProse`, `theCalloutWashHugsTheProseColumn`,
`theGlyphSitsInTheGutterAndYieldsWhereThereIsNone`, `theBadgeNeverStandsOnProse`,
`theStackPutsTheGlyphFirstAndTheCommentFaceUnderIt`. Measurements recorded below; the tree is
restored by `git checkout` of the four files against `620998c1` and re-verified green.

**RED-ON-OLD, MEASURED (2026-09-18).** The five reverts applied to the tree at `620998c1`, the
suite run, the tree restored by `git checkout` of `BlockDecor.swift` and re-verified: **15/15
green** before, **15 tests / 36 issues, 9 cells red** under the reverts, **15/15 green** after.
Cell by cell — no pin passed on both sides, and no pin is hollow:

| pin | under the revert | the number |
|---|---|---|
| `noDecorationMovesTheProseColumnOnAnySurface` | **RED**, 12 issues | `proseLeft 72` vs `160` at 1000 pt and vs `28` at 620 — a comment or a glyph moved her text 64 pt, four combinations × two widths |
| `theReadTiersProseIsUnmovedByACommentThroughTheProductionLoop` | **RED** | `proseLeft 72` vs `160` — through the REAL wiring: the operations-layer comment, the model's decor observation, the controller's render |
| `theContainedEditorsProseIsUnmovedByACommentThroughTheProductionLoop` | **RED** | the same, one host over |
| `aGutteredSurfaceStaysOnTextKit2` | **RED** | `proseLeft 72` vs `160` (the canary stayed silent either way — the override was never a downgrade trigger) |
| `nothingInTheGutterEverCoversProse` | **RED**, 9 issues | the badge's `maxX 34` over prose beginning at `28`; the wash reaching into the gutter at all six cells |
| `theCalloutWashHugsTheProseColumn` | **RED**, 2 | `minX 288` vs `300`, `16` vs `28` — the 12 pt spread |
| `theGlyphSitsInTheGutterAndYieldsWhereThereIsNone` | **RED**, 3 | `maxX 288` vs `296`; and at `textLeft` 8 and 20 it drew at `(6, 0, 18, 17)` — **on her first characters**, which is her image 11 |
| `theBadgeNeverStandsOnProse` | **RED**, 2 | at Write's `minGutter`: `maxX 34` where the prose starts at `28` — KnownIssues row 50's first residual, measured |
| `theStackPutsTheGlyphFirstAndTheCommentFaceUnderIt` | **RED** | `rect.maxX 34 > textLeft 28` |
| `twoCommentedBlocksCardsNeverAbut` | **RED** (revert 5), 2 | `first.maxY 54` where the next card's top is `46` — an 8 pt OVERLAP between two commented blocks' cards, which is the measured shape of her *"the comments still also aren't spaced well"* |
| `theProseColumnIsAPureFunctionOfTheSurfacesWidth` · `theGutterMovesOnlyWithTheSurfacesOwnWidth` · `everyTextSurfaceCarriesTheOneGutterRule` · `theTwoContainedSurfacesPlaceTheirProseIdentically` · `aLeadingGlyphIsExactlyOneGrapheme` | green under the reverts, by construction | they pin the NEW rule's own arithmetic and the grapheme guard, which the reverts do not touch; they are not bug-class pins and are not claimed as such |

### THE TRACED MECHANISMS (what was actually wrong, measured before it was fixed)

1. **A decoration could WRITE the prose column.** `BlockDecorOverlayController.render` asked its
   surface `setDecorLane(needed:)` — and `needed` was `BlockDecor.needsLane(state)`, i.e. "does
   this note carry a comment or a callout glyph". A true answer moved `textContainerInset` by
   64 pt and overrode `textContainerOrigin`, so the note's prose started at 72 where an
   undecorated note's started at 8. Measured on the current tree with the lane restored:
   `proseLeft 72` against `160` at a 1000-pt surface and against `28` at 620, with every
   fragment's origin moving with it, through the REAL wiring on both contained hosts (the
   operations-layer comment → the model's decor observation → the controller's render).
   *The fix is structural, not a patch:* the placement is now a pure function of the view's own
   width (`ProseGutter.insets`), and there is no door for a decoration to write through.
2. **The gutter a decoration needed was OUTSIDE the view.** Each contained surface was sized BY
   ITS HOST to the prose column itself (`BookView.proseColumn` = 696 for the Outline and the
   spread page; `paneWidth − 40` for the workspace pane and the note window), so the view's own
   bounds held 8 pt of margin — which is why 17p batch b had to move text to make room. The fix
   grows the FRAME into the host's whitespace (`.padding(.horizontal, -bleed)` around the text
   surface alone) and puts the container back on the same point, so the gutter that was always
   on screen is now INSIDE the view where an overlay can stand in it.
3. **Every gutter face aimed at `max(2, …)`.** The badge's rect was a fixed 32 pt clamped at the
   view's edge and the glyph sat inside the callout wash's leading pad, also clamped — so at any
   gutter narrower than the face, the face stood ON the words. Measured: at Write's own
   `minGutter` (28) the badge occupied `[2, 34]` with the prose beginning at 28 (KnownIssues row
   50's first residual, as a number); at a contained surface's 8 pt the glyph drew at
   `(6, 0, 18, 17)` — her image 11. Now each face asks `gutterRoom` first and YIELDS: the badge
   narrows to the room and disappears below a legible width, the glyph is not drawn where it
   would touch prose, and the prose keeps every point of its measure.
4. **Two commented blocks' cards overlapped.** `leftCardRect`'s height was `min(blockHeight + 24,
   96)` from the block's own top, with no knowledge of the next commented block. Measured on
   adjacent 30-pt blocks 40 pt apart: the first card's bottom at 54 against the next card's top
   at 40 — an 8 pt overlap, which is the measured shape of her *"the comments still also aren't
   spaced well"*. Now a card's room reaches to the next face's top less the rhythm's air, and a
   card clamped below a card's worth of height falls back to the badge.

### THE PINS (15 cells in `ProseGutterTests`; the lane suite retired INTO them, zero orphaned names)

| cell | what it holds | red-on-old |
|---|---|---|
| `theProseColumnIsAPureFunctionOfTheSurfacesWidth` | the host table's arithmetic at ten widths, per preset | not bug-class (the new rule's own arithmetic) |
| `theGutterMovesOnlyWithTheSurfacesOwnWidth` | the placement's change-gate, the zero-width guard, the exact unrounded mean | not bug-class |
| `everyTextSurfaceCarriesTheOneGutterRule` | the sweep: Write · inline editor · read tier · take pane | not bug-class |
| `theTwoContainedSurfacesPlaceTheirProseIdentically` | one brain, two surfaces | not bug-class |
| `aGutteredSurfaceStaysOnTextKit2` | the `textContainerOrigin` override is no downgrade trigger, driven through a real edit | RED (`proseLeft 72` vs `160`) |
| `noDecorationMovesTheProseColumnOnAnySurface` | THE ONE LAW, four decoration combinations × two widths, fragment origins included | RED, 12 issues |
| `theReadTiersProseIsUnmovedByACommentThroughTheProductionLoop` | the law through the REAL read-tier wiring | RED |
| `theContainedEditorsProseIsUnmovedByACommentThroughTheProductionLoop` | the law through the REAL inline-editor wiring | RED |
| `theCalloutWashHugsTheProseColumn` | memo §2 C; R17's vertical rule untouched | RED, 2 |
| `theGlyphSitsInTheGutterAndYieldsWhereThereIsNone` | memo §2 C + §3 edge 1 | RED, 3 |
| `theStackPutsTheGlyphFirstAndTheCommentFaceUnderIt` | her R-13u3-3, at three gutter widths | RED |
| `theBadgeNeverStandsOnProse` | row 50's first residual; the shipped 32 pt rect unmoved where it fits | RED, 2 |
| `twoCommentedBlocksCardsNeverAbut` | the rhythm; the shipped card byte-identical where there is room | RED (revert 5), 2 |
| `nothingInTheGutterEverCoversProse` | mounted, two presets × three widths, faces and wash | RED, 9 |
| `aLeadingGlyphIsExactlyOneGrapheme` | her R-13u3-4, door and renderer, incl. family/skin-tone/flag clusters | not bug-class (a new rule) |

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-18; `cliclick` + `Tools/WalkKit`)

A note with three blocks: block 2 wears a SAND callout with a glyph AND a comment; block 3 wears
a comment. Walked in Write (wide and at `minGutter`), the book Outline's read tier, the
spread/paged book's page, and the note window's read face — in BOTH voices and BOTH appearances.
Captures in `notes/plans/13u3-screens/` (gitignored):

| capture | what it shows |
|---|---|
| `02-emoji-prompt-one-grapheme.png` | the prompt with "💡🔥🔥" typed and the field saying *"Just the first one is kept."* — R-13u3-4 at the door |
| `03-write-callout-glyph-in-gutter.png` | ONE glyph stored (the two 🔥 dropped), in the gutter at the block's first line; the wash HUGGING the prose column |
| `04-write-terminal-light-stack-and-cards.png` | Write wide: the glyph, the `#1` badge stacked under it, block 3's margin card |
| `05-write-narrow-mingutter-badge-yields.png` | Write at `minGutter` 28: both badges narrowed to 22 pt, reading "#1", CLEAR of the words — row 50's first residual, gone |
| `06-book-outline-read-tier-cards.png` | **the headline:** the Outline's read tier with a real margin CARD for the first time, and the decorated note's prose starting on exactly the same x as the undecorated note above it |
| `07-spread-book-page-badges.png` | the spread page: the leading anchor unmoved, badges in its 28 pt gutter |
| `08-note-window-read-face.png` | the note window's READ face (`.pane`): stack in the gutter, prose at 28, full measure |
| `09-study-dark-note-window.png` | Study voice, DARK: a fully black room, the glyph and both badges in the gutter |
| `10-book-outline-study-dark.png` | Study + dark Outline: TWO margin cards, stacked with air, never abutting — the rhythm |
| `11-book-outline-study-light-two-cards.png` · `12-…-terminal-light-after-voice-round-trip.png` | the same after a light flip and a voice round trip |

**WALK VERDICT: the memo's one law holds on every surface I could reach, and the gutter buys what
it was meant to buy.** Three things the walk decided rather than the desk (all PROVISIONAL, all
recorded at their lines): the rhythm's air and a card's minimum height (two adjacent commented
blocks kept their cards in Study where they had fallen to badges), and the badge's own label
inset (a 22 pt badge read "#" with the count clipped).

**What the walk could NOT stage:** the workspace's SPLIT read-cheap pane — `View ▸ Open Beside`
opened the note in place rather than beside on this store, so that cell is covered by its pin and
by the note window, which mounts the same `ReadPostView` under the same `.pane` preset. Recorded
rather than claimed.

### FINALS (2026-09-18)

- core `swift test` — **Test run with 1567 tests in 171 suites passed after 56.099 seconds.**
- the FULL Mac suite — **Test run with 2794 tests in 466 suites failed after 768.677 seconds with
  2 issues.** The two issues are ONE test: `theReadClickLandsInIndexAtThatBlock`, the recorded
  environment red (KnownIssues row 58, owner 12) the brief names as the single tolerated one.
  Nothing else failed; `Suite "The prose gutter — the one law (13u3 UNIT A1)" passed`.
- the TUTORIAL SPINE — green in-run (every `Tutorial…` suite passed).
- iOS build — **BUILD SUCCEEDED** (zero shared/mobile/core files touched; the diff is Mac-only).
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO.

### DEFERRED / NOT MINE (handed up, not done)

- **QUESTIONS #117** — the workspace read pane and the note window run prose at the pane's full
  width where every other surface caps at 680, so a note re-wraps completely when that pane goes
  live. PROVISIONAL, a face call; the conversion kept both measures exactly as they were.
- **The three taste numbers** (`cardRhythmAir` 6 · `cardMinHeight` 19 · the badge's yielding
  label inset + `commentBadgeMinWidth` 19) are the walk's, not a ruling's.
- **A recorded consequence, deliberately not softened:** where the page has NO gutter — a
  contained surface at a window narrow enough to leave 8 pt — a comment's margin face is not
  drawn at all, because the alternative is standing on her words. Every other door to that
  comment stays (the block menu, ⌘⇧', the panel, and the inline-strip setting she keeps under
  R-13u3-5). It is the one law's other side, and it is new behaviour.
- **The editing indicator's ring overhangs the prose by 8 pt** (`indicatorRect`), so on the caret
  block the ring's left edge crosses the gutter glyph. Pre-existing (`indicatorRect` is
  unchanged since Phase 13 C1) and outside this unit's surface; noted for whoever owns the
  indicator's geometry next.
- **UNIT A2** (the comments PANEL as a text editor, memo §2 D) is untouched, as the brief fences.

---

## UNIT A1 CLOSED — 2026-09-18

The gutter geometry rework is built to `notes/plans/phase-13u3-memo-gutter.md` §2 A/B/C and her
rulings R-13u3-3 (the stack at every width) and R-13u3-4 (one grapheme). 17p batch b's decoration
lane is retired WHOLE — no dormant machinery — and with it QUESTIONS #102's entire option space.
KnownIssues row 50 is RESOLVED. One new PROVISIONAL (#117). Suites and walk above.

---

## UNIT A2 BRIEF — THE COMMENTS PANEL AS A TEXT EDITOR (self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 1 · GOVERNANCE + the
constitution · THE KICKOFF SITTING RECORD (R-13u3-1…6) · both "REFRESHED AT THE …" blocks (item 1
of the 13u2 block — the status seam's classed doors — binds your strings directly) · ENVIRONMENT
TRAPS · CAST & DISCIPLINE · the UNIT A1 RECORD's "handed up" list (context: the page half is
DONE; the margin card is a read face and a door — R-13u3-6). (2) **`notes/plans/phase-13u3-memo-gutter.md`
IN FULL** — §2 D is your design; §1's item 4 is the surface you replace; R-13u3-6 (panel-only
editing) is binding law. (3) The code: `Features/Editor/CommentsPanel.swift` (the whole file —
view + `CommentsPanelModel`), the comment ops it calls (`addBlockComment` family — semantics
UNTOUCHED, seal refusals intact), `Theme/VoiceControls.swift` (P-8: THE chrome vocabulary — the
row-46 lesson: an unvoiced sheet is a defect class; this panel must read as the voice in both
voices and both appearances).

**Scope (ONE acceptance unit — the panel, nothing page-side):** the panel re-forms as ONE writing
surface per memo §2 D — her words the north star (*"the comment add box is so small and it
doesn't make sense given how big the overall comment box is that the whole thing isn't more of
the text editor that you can write and click on"*):
1. Each comment renders as an editable text area IN PLACE — click it, type; no bordered-field
   swap; a hairline + a muted stamp line separate comments (the panel-side answer to *"the
   comments still also aren't spaced well"* — one vertical rhythm, real padding).
2. Below the last comment, the ADD AREA owns ALL remaining space: click anywhere in it → the
   caret lands there; the draft grows as you type; **⌘⏎ and the Add button file it; Esc clears**;
   plain ⏎ inside the draft is a newline (a comment can hold paragraphs — `text` is free prose).
   Decide edit-commit semantics the same way (⌘⏎ / focus-loss saves an in-place edit; Esc
   reverts) and record the choice PROVISIONAL.
3. The deleted fold + restore stay ("never skimpy"); every refusal/receipt speaks through the
   status seam's classed doors (refuse/offer/receipt — trivially classifiable).
4. Voice + appearance: `VoiceTokens` throughout, both voices, both appearances — no system-chrome
   `List`/`.roundedBorder` residue.
5. Comment OPERATION semantics byte-unchanged (add/edit/delete/restore; refuse under seal; the
   travel rules are core's and untouched). Zero `Sync/`, zero schema.

**Pins:** the model's flows unchanged (existing `CommentsPanelModel` coverage rides; extend where
your edit-in-place path adds states); red-on-old ONLY where a cell is defect-shaped (a face
redesign is not a bug pin — do not manufacture reds); a keyboard-contract pin for ⌘⏎/Esc if the
harness can drive it, else the walk covers it and says so.

**End verification:** FULL Mac suite (row 58's environment red is the one tolerated); tutorial
spine green in-run; iOS build green; YOUR walk with captures on the dev-store Debug build — a
multi-comment block: click-anywhere, grow, file with ⌘⏎, edit in place, delete + restore, both
voices, both appearances; captures to `notes/plans/13u3-screens/`. Record: a **UNIT A2 RECORD**
appended to this file (LIVE STATUS from the first commit; PENDING until verified; UNIT CLOSED
banner), ledger row 2b flipped in the same commit. The checkpoint protocol binds from your first
commit (CAST & DISCIPLINE restates it).

## UNIT A2 RECORD — THE COMMENTS PANEL AS A TEXT EDITOR (opus-implementer, 2026-09-18)

**WHAT THIS UNIT DOES NOT DO (the record's first line):** nothing page-side — UNIT A1's gutter
geometry, the margin card, the count badge, the callout glyph and the inline-comments setting are
untouched (R-13u3-6: the margin card stays a READ face and a door; editing has ONE home, and this
unit is that home). Comment OPERATION semantics are byte-unchanged (`addBlockComment` /
`editBlockComment` / `deleteBlockComment` / `restoreBlockComment`, the seal refusals, the travel
rules): zero `Sources/VariorumCore/` behaviour change, zero `Sync/`, zero `Persistence/`, zero
schema, zero migrations, the marker stays 8. The PHONE's comments sheet (`MobileComments`) is not
touched — it owes a version of this face (a mobile-parity row, the orchestrator's to file). No new
door claims a shortcut outside the panel's own key window.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | the record + LIVE STATUS | **DONE** |
| 1 | `CommentComposition` — the pure edit/file/escape brain + its pins | **DONE** |
| 2 | the model: per-comment drafts, the classed status slot, the receipt/refusal doors + pins | **DONE** (13 cells in 2 suites green: `CommentCompositionTests` · `CommentsPanelModelEditorTests`) |
| 3 | the view: ONE writing surface (edit in place · the add area owns the rest · ⌘⏎/Esc · deleted fold) | **DONE** (29 cells green across the panel's 3 new suites + the 3 they must not disturb) |
| 4 | the red-on-old measurement (the one defect-shaped cell) | **DONE** — named, measured, restored (the table below) |
| 5 | QUESTIONS #118 (the PROVISIONAL calls) | **DONE** — four lettered calls + the taste numbers |
| 6 | the walk + captures, the full Mac suite, the tutorial spine, iOS build | **DONE** — 19 captures; finals below |

### THE RED-ON-OLD VERIFICATION — NAMED BEFORE IT RUNS (the checkpoint protocol)

Pre-revert state COMMITTED at `c9129b0d`. **This unit is a FACE REDESIGN, and a face redesign is
not a bug pin** — the brief says so and I am not manufacturing reds for it. Exactly ONE cell here
is defect-shaped, and it is the one I traced while reading the shipped panel:

> **The add road trimmed and the edit road did not.** `CommentsPanel.addDraft()` filed
> `draft.trimmingCharacters(in: .whitespacesAndNewlines)`; the edit row's Save button handed
> `editDraft` to `editBlockComment` RAW. So the same keystrokes stored different text depending on
> which box they were typed in, and a comment saved with a trailing newline then rendered with a
> dangling blank line wherever it is shown (the panel, the margin card, the inline strip). Two
> rules for one thing — F-0's drift class, in eight characters of difference.

The revert is a **behavioural revert of that one mechanism**, applied to the current tree and then
undone (the standing method — the pre-13u3 tree cannot compile pins that name types it does not
have): `CommentComposition.commit` returns `.save(draft)` — the RAW draft — instead of
`.save(text)`. That restores exactly what the shipped Save button did, and nothing else: the
comparison arm (`trimmed(draft) == stored` ⇒ `.unchanged`) is untouched, and the ADD road's own
trim is untouched, so only the edit road's payload moves.

Expected red: `aCommentEditsInPlaceAndStoresTheTrimmedText`. Expected GREEN under the same revert
(and recorded as such, so the measurement is honest rather than a blanket): the add-road cell, the
no-write cell, the emptied cell, the escape cell, the receipts cell, the drafts-survive cell, the
seal cell, and all five brain cells — they pin what the redesign DECIDED, not a defect.

**RED-ON-OLD, MEASURED (2026-09-18).** The revert applied to the tree at `7bf2a7ed`, the two
suites run, the tree restored by `git checkout` of `CommentComposition.swift` and re-verified:
**13/13 green** before, **13 tests / 2 issues, 2 cells red** under the revert, **13/13 green**
after. No cell passed on both sides *and* claims to be a bug pin; the eleven that stayed green are
listed above as the redesign's own decisions and are not claimed as reds.

| pin | under the revert | the number |
|---|---|---|
| `aCommentEditsInPlaceAndStoresTheTrimmedText` | **RED** | through the REAL op: the store held `"  quieter ending \n"` where the add road would have stored `"quieter ending"` — her own keystrokes, two different rows, depending only on which box she typed them in |
| `aCommitWritesOnlyWhatWouldChange` | **RED** | the brain's own cell: `.save(" new ")` vs `.save("new")` |
| the other 11 cells | green under the revert, by construction | they pin what this redesign DECIDED (what ⌘⏎ files, what an emptied comment means, what ⎋ undoes, which drafts survive an arrival, which class each message carries, what the seal does) — a face redesign is not a bug pin, and none of them is claimed as one |

### THE TRACED MECHANISMS (what the shipped panel actually did, before anything was changed)

1. **The add box could not be written in.** `CommentsPanel`'s add door was a ONE-LINE
   `TextField(axis: .vertical)` capped at four lines, with `.onSubmit(addDraft)` on it — so ⏎
   FILED the comment instead of making a paragraph, and a comment with two paragraphs was
   impossible to TYPE (only to paste). Under it sat a `List` of rows that took every point of the
   440 × 320 panel, which is the measured shape of her *"the comment add box is so small and it
   doesn't make sense given how big the overall comment box is."*
2. **Editing swapped the row for a bordered field.** A row's Edit button replaced the text with a
   second `TextField` plus Save/Cancel — a different control, a different geometry, and a
   different place for the caret than where she had just been reading. That is the "not a text
   editor" half of the same complaint.
3. **Two rules for one thing (the defect-shaped cell).** The add road trimmed
   (`draft.trimmingCharacters(in: .whitespacesAndNewlines)`); the edit road handed `editDraft` to
   `editBlockComment` RAW. Same keystrokes, different stored text, depending on which box she
   typed them in — and a trailing newline then rendered as a dangling blank line wherever the
   comment shows. Measured red-on-old above: the store held `"  quieter ending \n"`.
4. **One status slot, one register.** `statusMessage` was a bare `String?` painted
   `.alarmVoice()` — so any message the panel ever spoke would read as a refusal. The panel spoke
   only refusals, so nothing was wrong ON SCREEN; what was wrong was that a receipt had nowhere
   to go, which is why delete and restore said nothing at all. (This is the tray panel's own
   ledger-row-6 defect, one file over, in its dormant form.)

### WHAT THE PANEL IS NOW (the contract, in her words where they exist)

ONE scrolling writing surface. **Every comment is an editable area in place** — click it and
type; no Edit button, no field swap; a hairline and a muted stamp line (when it was written, its
doors) separate them. **Below them the ADD AREA owns every point they leave** and never less than
its floor, so there is always somewhere to write; click anywhere in it and the caret lands there.
**⏎ is a newline everywhere** (a comment is free prose and holds paragraphs). **⌘⏎ commits what
you are writing** — files the add draft, saves the comment. **⎋ undoes the most local thing** —
clears the draft, puts a comment back, else closes. Moving away from a changed comment SAVES it;
moving away from a half-written new one does not file it (#118(a)). Emptying a comment puts it
back and says which door removes it (#118(b)). The deleted fold and its restore door keep their
place at the FOOT, outside the writing surface, so the add area's space is never theirs. Delete
and restore speak RECEIPTS in the voice's muted ink; refusals speak in its alarm; the class is
decided at the door (`RecoveryStatus`, the tray panel's precedent — a sheet's refusal cannot live
in a toast behind it). `VoiceTokens` throughout, both voices, both appearances; no `List`, no
`.roundedBorder`, no system-chrome residue.

**Operations: byte-unchanged.** `addBlockComment` / `editBlockComment` / `deleteBlockComment` /
`restoreBlockComment` are called exactly as before, with their seal refusals and travel rules
intact. Zero `Sources/VariorumCore/` change, zero `Sync/`, zero `Persistence/`, zero schema, zero
migrations, marker 8.

### THE PINS (16 cells in three suites; the shipped `CommentsAndReorderTests` coverage rides unmodified)

| cell | what it holds | red-on-old |
|---|---|---|
| `theAddDoorFilesTrimmedProseAndIsSilentOnNothing` | ⌘⏎ on nothing is silent; the ends trim; inner paragraphs survive | not bug-class (a new rule) |
| `aCommitWritesOnlyWhatWouldChange` | unchanged · emptied · save, by the one trim rule | **RED** (`.save(" new ")` vs `.save("new")`) |
| `dirtyMeansCommittingWouldDoSomething` | the mark says exactly what a commit would do | not bug-class |
| `escapeIsALadderMostLocalFirst` | #118(c), all five shapes | not bug-class |
| `aProjectionArrivalKeepsHerProseAndDropsWhatIsSettled` | her typing survives an arrival; a settled draft and a dead comment's draft go | not bug-class |
| `onlyCommandReturnAndBareEscapeAreClaimed` | the two keys, keypad Enter included | not bug-class |
| `everyOtherKeyReachesTheTextUntouched` | ⏎ · ⇧⏎ · ⌥⌘⏎ · ⌃⏎ · ⌘⎋ · letters — the panel claims NONE of them | not bug-class |
| `theAddAreaFilesWithTheOneTrimRuleAndClearsItself` | the add road end to end, and its silence | not bug-class |
| `aCommentEditsInPlaceAndStoresTheTrimmedText` | the edit road end to end + the no-flicker rule | **RED** (the store held `"  quieter ending \n"`) |
| `aCommitThatWouldWriteNothingWritesNothing` | the row's stamp untouched, nothing said | not bug-class |
| `anEmptiedCommentRefusesAndGoesBackToWhatIsStored` | #118(b), and the refusal NAMES Delete | not bug-class |
| `escapeRevertsAnEditAndClearsTheAddDraft` | the ladder through the model's own doors | not bug-class |
| `deleteAndRestoreSpeakReceiptsThatNameTheRoad` | the receipt CLASS (not the words), both doors | not bug-class |
| `aDraftSurvivesAProjectionArrivalAndASavedOneStopsBeingDirty` | the drafts' lifetime through the real ops | not bug-class |
| `escapesMeaningIsAFunctionOfFocusDraftsAndTheStore` | the keyboard contract as a VALUE: focus + drafts + store → the act | not bug-class |
| `theSealRefusesEveryWriteAndKeepsWhatSheTyped` | the seal refuses both roads and throws away nothing | not bug-class |

**Why so few reds, said plainly:** this unit is a FACE REDESIGN. The brief says a face redesign is
not a bug pin and tells me not to manufacture reds; the one defect-shaped cell I traced is the
two-trim-rules drift, and it is measured above. Everything else above pins a decision the
redesign had to MAKE — which is what a later reader needs, and what a reviewer can hold me to.

**What is NOT pinned, and why:** the keyboard ROUTING (⌘⏎ / ⎋ actually reaching the focused area
through a live window) is AppKit key dispatch into a focused `TextEditor`, which this harness has
no honest way to drive. It is the walk's, and the walk drove it (below). What the pins hold is
what each key MEANS, as a value.

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-18; `cliclick` + `Tools/WalkKit`)

Walked the panel as an editor on a multi-comment block in BOTH voices and BOTH appearances:
click-anywhere-and-write, a two-paragraph draft, file with ⌘⏎, edit in place, save with ⌘⏎, ⎋ to
put it back, delete, the deleted fold, restore, and focus-loss saving. 19 captures in
`notes/plans/13u3-screens/` (gitignored), `a2-01`…`a2-19`.

| capture | what it shows |
|---|---|
| `a2-17-the-empty-panel-is-all-writing-area.png` | **the headline:** "comments 0" and then nothing but writing area — the whole panel IS the box she asked for |
| `a2-18-a-two-paragraph-draft-typed-straight-in.png` | ⏎ making a paragraph inside the draft, typed (not pasted) |
| `a2-19-filed-with-cmd-return-paragraphs-kept.png` | ⌘⏎ files it as ONE comment with its paragraph break, the add area cleared and still owning the rest |
| `a2-04-three-comments-and-the-add-area-terminal-light.png` | three comments, each an area in place with its stamp line, and a real add area under them |
| `a2-05-…-the-unsaved-mark-and-its-doors.png` · `a2-06-saved-in-place-…` | typing into a comment raises `unsaved · ⌘⏎` + save/revert; ⌘⏎ saves and the mark goes out, silently |
| `a2-07-before-escape.png` · `a2-08-escape-put-it-back.png` | ⎋ putting a changed comment back |
| `a2-09-delete-speaks-a-receipt-and-the-fold-appears.png` | the delete receipt in MUTED ink (not alarm) + `▸ deleted (1)` at the foot |
| `a2-10-the-deleted-fold-takes-only-what-it-holds.png` · `a2-11-restore-speaks-a-receipt.png` | the open fold, the restore door, the restore receipt |
| `a2-12`…`a2-14` (Study · dark) | the panel, an in-place edit with its mark, and **focus-loss saving it** |
| `a2-15` (Terminal · dark) · `a2-16` (Study · light) | the remaining two voice × appearance cells; dark is a fully black room in both (R51) |
| `a2-01`…`a2-03` | the first pass, kept for the record: the panel as it looked before the walk's two layout fixes |

**WALK VERDICT: the panel reads and behaves as one writing surface in both voices and both
appearances, and every door on it does what it says.** The walk also FOUND FOUR THINGS the desk
could not, three of which were defects in what I had just built:

1. **The add area fell BELOW THE FOLD.** One scroll (comments then the add area) put a real
   writing box under three comments in a 320 pt panel — she would have had to scroll to find the
   thing the unit exists to give her. Fixed by splitting the surface in two: the comments take
   what they need and scroll past it; the add area takes the rest and never less than 132 pt.
2. **The comments never rendered.** The list's height came from measuring its content, and the
   measuring view only mounted once the list HAD a height — so the panel drew "comments 3" over
   an empty page. Fixed by giving the unmeasured list its whole cap for one frame.
3. **The deleted fold ate the page.** A `ScrollView` takes every point it is offered, so opening
   the fold to show ONE struck-through line stole 132 pt from the writing surface and clipped the
   live comments. Fixed: the fold takes what it holds, up to the cap.
4. **The panel could come up NON-KEY** — its auto-focused caret blinking while every keystroke
   went nowhere (measured: ten characters typed at 150 ms intervals, none landed; one click in
   the area and everything landed). A caret you cannot type into is worse than no caret, so the
   panel now asks for key status once, when it lands. Re-walked after the fix: two full
   paragraphs typed straight into a freshly opened panel with no click at all (`a2-18`).

**What the walk could NOT stage:** nothing in the panel. (Two staging notes, both mine and
neither an app defect: `cliclick` keystrokes go to the frontmost app, so a capture that steals
focus must be followed by a re-activate before typing; and a ⏎ typed with the caret at a block's
START mints an empty block ABOVE it — U-1's own rule — which is what left the walk note with an
empty first block.)

### FINALS (2026-09-18)

- core `swift test` — **Test run with 1567 tests in 171 suites passed after 59.497 seconds.**
- the FULL Mac suite — **Test run with 2810 tests in 469 suites failed after 757.068 seconds with
  2 issues.** Both issues are ONE test: `theReadClickLandsInIndexAtThatBlock`, the recorded
  environment red (KnownIssues row 58, owner 12) the brief names as the single tolerated one.
  Nothing else failed; all three of this unit's suites passed, and so did
  `StatusSeamVocabularyTests` and `ChromeMinHeightTests`. (Baseline 2794/466 + 16 cells in 3
  suites = 2810/469, exactly.)
- the TUTORIAL SPINE — green in-run (every `Tutorial…` suite passed; zero failures).
- iOS build — **BUILD SUCCEEDED**.
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Sources/VariorumCore/`: ZERO.

### DEFERRED / NOT MINE (handed up, not done)

- **QUESTIONS #118** — the four rules the redesign had to decide (focus-loss saves an edit but
  never files the add draft · an emptied comment goes back rather than deleting · ⎋'s ladder ·
  the one trim rule), plus the two taste numbers (the panel's 460 × 440 minimum, the add area's
  132 pt floor). All PROVISIONAL, each one line to change.
- **The PHONE owes this face.** `MobileComments` mirrors the Mac panel's shipped semantics
  (list + a draft field, edit through the field) and is untouched here. A mobile-parity row is
  the orchestrator's to file; when the phone builds it, `CommentComposition` hoists to
  `App/Variorum/Shared/` rather than being copied (the hoist-at-next-touch rule; said at the
  file's head).
- **A comment ROW is a live text area whenever it is on screen**, so a block with very many
  comments mounts very many small text views. Bounded by her own writing on ONE block (not by
  corpus size, so P1 is untouched) and the panel scrolls, but the rows are NOT lazy — a later
  touch that wants them lazy must move the drafts' survival story with it (they already live on
  the model, which is half of that work).
- **The panel's status line has no clock** (the tray panel's shape): a message stays until the
  next act clears it. The shell's 6 s dismissal belongs to `StatusCenter`, which a sheet cannot
  use. Recorded rather than invented.
- **Not touched, as the brief fences:** the page-side gutter (UNIT A1's), the margin card, the
  count badge, the callout glyph, the inline-comments setting (R-13u3-5), and every other unit
  in this phase.

---

## UNIT A2 CLOSED — 2026-09-18

The comments panel is a text editor: the memo's §2 D built, her item 3 answered, R-13u3-6's
one-live-text-home honoured (the margin card stays a read face and a door). The writing semantics
are ONE pure brain; the panel's messages are classed at the door; the operations are
byte-unchanged. 16 pins in three suites with the one defect-shaped cell measured red-on-old; a
walk in both voices and both appearances that found four things the desk could not, three of them
fixed in the same session. One new PROVISIONAL bundle (#118). Suites and finals above.

---

---

## UNIT B BRIEF — NOTE-LIST SKIMMABILITY (self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 2 · GOVERNANCE + the
constitution · THE KICKOFF SITTING RECORD · both "REFRESHED AT THE …" blocks (the 13u2 one's
items 3 and 8 bind directly: `BookViewModel.adopt` PRIMES card previews via
`Queries.leadingBlockTexts` and your card family CONSUMES that road, never re-derives per row;
the title room is HEALED at ~48 chars and your work settles WITH it) · ENVIRONMENT TRAPS · CAST
& DISCIPLINE. (2) The master plan's `### 13u` **item (4)** — the RULED design, her words verbatim
(the derived display-name shape adopted; *"it can't be the whole first sentence if that sentence
is super long"*; journal cards stay date-led; the title-suggestion chip at capture — *"a
suggestion, never an action taken for her"*; STORED auto-title definitively rejected — *"what I
hate is battling the apple notes title"*), and item (13)'s note that title room and card identity
settle together. (3) QUESTIONS **#103/#104/#105** (the Library stamps' built arrangement — your
cards must not disturb it) and the 18h Library machinery (`LibraryTimeFace`/`TimeStampFace` —
the stamps are the ONE words brain; your snippet is a SECOND brain beside it, never a rival
stamp). (4) The code: `Features/Library/LibraryCatalogView.swift` (`NoteCards`, the List rows,
`LibraryCatalogModel`) · the Pool card preview (Act 10 row 87 — BUILT; find its brain and
CONSUME/align, never fork) · `Sources/VariorumCore/Queries/ShelfQueries.swift`'s search-row
`snippet` (row CONTEXT under a search — a DIFFERENT thing from your display name; do not merge
them; its own doc says titles stay as they are).

**Scope (ONE acceptance unit — the note-list card identity):**
1. **ONE pure Domain brain** (`Sources/VariorumCore/Domain/` — e.g. `DisplayName.swift`): given
   an explicit title and the note's first words, answer what a card LEADS with — explicit title
   where set, else a length-capped snippet of the first words (cap + word-boundary trim +
   ellipsis; pick the cap against the healed ~48-char title room and record it PROVISIONAL),
   derived at read time, NEVER stored, nothing ever renamed. Edge-case tests (empty note,
   whitespace-only, one long word, markdown lead-in — strip syntax? decide, record PROVISIONAL —
   emoji/grapheme boundaries).
2. **The Mac consumers:** the Library's Notes cards + List rows (untitled notes lead with the
   snippet; the date demotes to the metadata line; JOURNAL-profile notes stay date-led — a daily
   entry's date IS its identity); the Pool/bookless cards align to the same brain; the book
   Outline's `OutlinePostRow.excerpt` road stays as-is unless it already disagrees with the brain
   (then consume it — one brain). The 18h stamps arrangement (#103/#105) byte-unharmed, pinned.
3. **The title-suggestion chip at quick-note/capture:** first words offered as a CHIP, one tap
   adopts it as the explicit title, ignorable forever — never applied for her. Build it on the
   capture surfaces' EXISTING shape (QuickNoteView + QuickEntryBar) WITHOUT reworking their
   ⏎/⇧⏎ model — that is UNIT C's; if the chip cannot land without touching the filing model,
   STOP and hand the chip to C with a note instead of building C's half.
4. **Mobile:** the brain is core Domain — the phone CONSUMES it at its catch-up (a parity note
   in your record; do not build phone faces).
5. **Data cost (P1):** the snippet's source is bounded (first block's leading text — the primed
   previews road on the book side; a bounded read on the Library side). No per-row query storms:
   if the Library needs a new read, it is ONE bounded query for the visible window, measured.

**Pins:** the brain's edge cases; the journal/date-led split; the never-stored rule (no schema,
no writes — assert the card path performs zero writes); the stamps-arrangement pins ride
unmodified (#103/#105's two-width pins green untouched). Red-on-old only where defect-shaped.

**End verification:** FULL Mac suite (row 58's environment red the one tolerated) · tutorial
spine green in-run · iOS build green · YOUR walk with captures: the Library over her-shaped
fixtures (titled · untitled · journal · a note whose first sentence is very long · an empty
note), List AND Notes modes, both voices, both appearances; captures to
`notes/plans/13u3-screens/`. Record: **UNIT B RECORD** appended here, LIVE STATUS from the first
commit, UNIT CLOSED banner, ledger row 3 flipped in the same commit.


---

## UNIT B RECORD — NOTE-LIST SKIMMABILITY (opus-implementer, 2026-09-19)

**WHAT I DID NOT DO (the record's first line, per the contract):** I did not touch the gutter
surfaces or the comments panel (UNITS A1/A2, closed); I did not rework either capture surface's
⏎/⇧⏎ filing model (UNIT C's); I did not change the 18h/17q stamps arrangement (#103/#104/#105 —
byte-unharmed, their pins green untouched); I did not build phone faces (the brain is core Domain,
the phone consumes it at its catch-up); zero `Sync/`, zero `Persistence/`, zero schema, zero
migrations, marker stays 8.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | This record + LIVE STATUS | **DONE** |
| 1 | The BRAIN — `Sources/VariorumCore/Domain/NoteCardFace.swift` + its edge-case pins | **DONE** `f466995d` — 12 cells green |
| 2 | The two facts the card needs — `CatalogHit.profile` · `TimelineItem.profile` (additive, nil-defaulted) | **DONE** `ddbd6407` — 13 cells green; adjacent core suites green |
| 3 | The Library consumers — Notes cards + List rows (one composition, `LibraryCardName`) | **DONE** `b7cd8f10` — 6 new cells green; the stamps/#103/#105 pins green UNMODIFIED |
| 4 | The Pool card aligns to the same brain (`PoolCardFace` retires into it) | **DONE** `96a0607c` — row 87's rule re-expressed over the lead; 2 cells green |
| 5 | The title-suggestion chip at capture (QuickEntryBar + QuickNote pad) | **DONE** `9aa2970e` — BUILT (the ⏎/⇧⏎ filing model untouched; 6 cells green) |
| 6 | THE WALK (dev-store Debug, both voices, both appearances, her-shaped fixtures) + captures | **DONE** — 18 captures; ONE defect found and fixed (`abb79b12`) |
| 7 | FINALS (core · FULL Mac suite · tutorial spine · iOS build) + QUESTIONS #119 + ledger row 3 | **DONE** — one suite find fixed (`7aac721c`); finals below |

**The design, decided before the code (so the record is not written backwards):**
a card LEADS with the explicit title where set; else a JOURNAL-profile note leads with its day (a
daily entry's date IS its identity); else the note's FIRST WORDS, length-capped at a word edge with
an ellipsis; else the day; else "Untitled". The words are the app's own markdown DISPLAY text (no
raw `#`/`**` in a name), the preview line under the lead is the CONTINUATION (nothing said twice),
and nothing is ever stored or renamed — derived at read time, every time.

### WHAT THE CARD IS NOW (the contract, in her words where they exist)

**ONE pure Domain brain** — `Sources/VariorumCore/Domain/NoteCardFace.swift` — answers what a
note-list card LEADS with, and every note renderer asks it:

1. **The title she typed**, exactly as stored — journal or not, long or short.
2. else **a journal-profile note's day** (her rule, riding with item 4: *a daily entry's date IS
   its identity*). The marker is `container.profile`, the daily mint's own, never "this note has a
   date" — a note she merely dated is not a diary entry.
3. else **the note's own FIRST WORDS**, capped at 48 characters, cut at a word edge, with an
   ellipsis (*"it can't be the whole first sentence if that sentence is super long"*).
4. else **the day**, exactly as every other surface names the note (`DisplayTitle`'s own chain).
5. else **"Untitled"**.

The words are the app's own markdown DISPLAY text, so a note that opens `# Garden plans` is called
*Garden plans*; the line under the lead **carries on from where it stopped**, so no card says the
same words twice; and **nothing is stored, nothing is renamed, ever** — derived at read time, every
time (her *"what I hate is battling the apple notes title"*).

**Why this is not `DisplayTitle`** (the question a cold reader asks first): `DisplayTitle.note`
answers *what a note is CALLED* — its title, else its date — and that answer is load-bearing far
outside any list (the masthead, export headings, the bulk manifest's filenames, every picker). It
is untouched. This answers a different question that only a LIST asks: *what does a card lead with
when it has a row to spend and fifty neighbours to be told apart from.* A date is a fine name for a
note and a poor way to tell fifty notes apart, which is the report item 4 came from.

**The consumers, one composition each:** the Library's Notes cards and List rows through
`LibraryCardName` (one function, both renderers — the `LibrarySortFace` shape, so the two modes can
never call a note two different things); the Pool's cards through `PoolCardFace`, whose row-87 rule
(*no derived line under a card she NAMED*) is re-expressed over the lead rather than the raw title.
The book Outline's `cardPreview` was left alone: it answers *what does this note SAY* (forty words
across blocks, skipping a lone heading) — a different question from *what is it called*, and it
does not disagree with the brain.

**What each mode pays for (P1):** `LibraryCardRead.plan` is a pure rule — Notes reads every listed
note's leading blocks plus its book names (13g's shape, unchanged); **List reads the words only for
the rows that would otherwise be a bare date, and never the memberships**, so a library of named
notes pays nothing at all; Timeline pays nothing. One bounded statement over the window on screen
(`NoteCards.load`, the shipped window-function read, now keeping every leading block instead of
throwing all but the first away).

**The capture half** — her *"first words offered, one tap to adopt, ignorable forever — a
suggestion, never an action taken for her"*: both Mac capture surfaces (the shelf/Library
quick-entry bar and the floating Quick Note) show `TitleSuggestionChip`; one click takes the words
as the note's title; a capture she never clicks files UNTITLED exactly as it always did. **The
⏎/⇧⏎ filing model is UNIT C's and is untouched** — the chip rides beside it and adds one optional
argument to the mint.

### THE PINS (27 cells in 4 suites + 2 shipped suites amended)

| suite | cells | what they hold |
|---|---|---|
| `NoteCardFaceTests` (core) | 13 | the precedence (title · journal day · words · day · Untitled); a blank title is no title; the cap cut at a word edge with its ellipsis; a short opening left whole and unmarked; ONE long word cut where the cap falls; **graphemes never split** (a family emoji survives whole); markdown rendered not printed (headings, emphasis, links, list glyphs); the lead is the first LINE and the preview is what follows; the 400-character bound whatever it is handed; the typed suggestion is the same rule **without** the ellipsis; and the journal marker riding the catalog + Pool rows |
| `LibraryCardNameTests` (Mac) | 6 | the Library asks the one rule with its own row's facts; a heading-led card still has prose to preview; the second line carries on or stands down; **each mode reads what it draws** (and the model obeys the plan); the words-only read leaves the books alone; and **drawing a card writes NOTHING** — no title, the note's `updated_at` unmoved, the sync outbox unchanged, the rename door still seeded from the stored title |
| `TitleSuggestionChipTests` (Mac) | 7 | an offer is not an act (filing untouched files untitled); one click makes the first words the title through the REAL operation; the decision rides the text, survives a refusal and resets with the box; an emptied box forgets it; the pad makes the same offer with the same default; **the chip draws her words verbatim and folds only the app's** (the walk's find, red-on-old below); a long opening offered and stored without the ellipsis |
| `PoolCardPreviewTests` (amended) | 2 | row 87's rule re-expressed over the lead: a titleless card leads with its words and the line under carries on; a daily entry keeps its day and shows its words; a card she named shows no derived line |
| `QuickEntryBarTests` (amended) | 5 | unchanged in substance — the mint seam gained the title parameter, so its five closures did |
| `LibraryCardStampsTests` · `LibraryRowAlignmentTests` · `MorningListTests` | — | **green UNMODIFIED** — #103/#105's arrangement and 13g's card facts are byte-unharmed (the brief's standing requirement) |

**RED ON OLD, where the row was defect-shaped.** Item 4 is a FACE, so most cells are construction
rather than red-on-old. The one defect-shaped row is the walk's find, and it was measured both
ways: with the name segment marked as the app's words (the pre-fix composition, one line), the
Terminal voice draws `name it “garden plans for the spring”?` and
`theChipDrawsHerWordsVerbatimAndOnlyFoldsItsOwn` fails on BOTH arms (offer and adopted); with the
fix it passes. The suite find below was measured the same way, on two trees.

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

Walked the Library over her-shaped fixtures in **both voices and both appearances**, List AND Notes
modes, plus the Pool and both capture surfaces. 18 captures in `notes/plans/13u3-screens/`
(gitignored), `b-01`…`b-18`.

| capture | what it shows |
|---|---|
| `b-07-library-notes-terminal-light.png` | **the headline:** every untitled note now says what it starts with — *The lighthouse keeper counted the storms that…* over its own continuation, *Garden fence options* (a `# heading` note, rendered), and an empty note still reading `2026-09-15 · No text yet` |
| `b-06-library-list-terminal-light.png` | the same names one line each in List mode, with the 18h stamps and the tag `+` untouched beside them |
| `b-01-the-offer-terminal-light.png` · `b-02-one-click-adopts-it.png` | the chip: `name it “Garden plans for the spring, and what to do”?` → `✓ title: …` in accent ink |
| `b-03-filed-and-opened.png` | ⏎ files it and the note opens **titled** — the whole typed text still its first block |
| `b-12-pool-terminal-dark.png` | the Pool, which was a wall of bare dates: the words lead and the day steps down to the quiet slot beside them |
| `b-13-quick-note-pad-offers-the-name.png` · `b-14-quick-note-pad-name-taken.png` | the floating pad makes the same offer in a 300 pt window — truncating the drawn name, storing the whole one |
| `b-15-the-filed-quick-note-is-named.png` | the filed quick note in the Library, named, tagged `#quicknote` |
| `b-08` (Study light) · `b-09` (Study dark) · `b-10` (Terminal dark) | the Notes cards in the other three voice × appearance cells; dark is a fully black room in both voices (R51) |
| `b-11` (Terminal dark) · `b-16` (Study dark) · `b-17` (Study light) | the List rows in the other three cells |
| `b-04` · `b-05` | the heading note being made (its second block is the walk's own mangled typing — see the staging note) |
| `b-18-restored-terminal-follow-system.png` | the dev store left as I found it: Terminal voice, appearance following the system |

**WALK VERDICT: the note lists read as she asked — a card leads with what the note starts with,
the date steps down, a daily entry stays its day, and the capture surfaces offer a name without
ever taking one.** The walk FOUND ONE DEFECT in what I had just built, fixed and re-walked:

1. **The chip showed a name she would not get.** `VoicedChip` draws its label through
   `chromeLabel`, which LOWERCASES in the Terminal voice — right for the chrome vocabulary, wrong
   for a chip quoting her prose: the offer read *name it “garden plans for the spring, and what to
   do”?* over a note that would be titled *“Garden plans…”*. The label is now SEGMENTS (the app's
   words voiced, hers verbatim), pinned red-on-old (`abb79b12`).

**What the walk could NOT stage** (mine, not the app's): synthetic typing into the full-document
TK2 editor drops most characters even at 150 ms spacing, and `⌘V` never landed there at all, so the
heading note's second block reads `B s  t Bs t.` instead of the sentence I meant — the Library
captures show the cards over that text rather than over prose. The quick-entry bar and the pad took
full strings reliably. Two geometry notes for the next walker: the dev-store window is **1728×1084
at Y=33** (the WalkKit README's 1700×1000 is stale), and the app's own **40 pt phantom window**
appears in `walk-cap`'s listing on a fresh launch.

### FOUND, NOT MINE (handed up rather than carried)

1. **THE FULL-DOCUMENT EDITOR SPUN ON A `deleteBackward`.** Mid-walk the dev build stopped
   responding (99% CPU, AppleEvents timing out). `sample` caught it with **1,839 of 1,839 samples
   in one stack**: `EditorTextView.keyDown` → `NSTextView.deleteBackward:` →
   `NSTextStorage.processEditing` → `EditorSurfaceDelegate.textStorage(_:didProcessEditing:…)`
   (`EditorView.swift:655`) → `EditorViewModel.storageDidEdit` (`:1273`) → `updateCaretContext`
   (`:3303`) → **`refreshDecorations` (`:3527`) → `offsetAt(y:)` (`:3520`) →
   `NSTextLayoutManager.textLayoutFragmentForPosition` → `ensureLayoutForBounds:` →
   `_estimatedTextLocationForVerticalOffset:`** — i.e. TEXTKIT2 §2's own class, forcing layout from
   inside a text-storage callback. Seen ONCE, not reproduced (I killed my instance and relaunched);
   nothing in this unit's diff is on that path, and the decoration road is A1's neighbourhood. The
   full sample is at `/tmp/13u3b-editor-hang-sample.txt` for as long as that survives; the frames
   above are the record. **Owner: the editor-seam/decoration owner (A1's ladder round, or
   KnownIssues owner 12).**
2. **A chip inside an expanded book story WRAPS today** — which is a row height the book's manifest
   does not know about (13u2b's own warning). Found because clamping the shared chip to one line
   moved a settled Outline landing by 3,424 pt. **Owner: the manifest/landing owner.**
3. **Two reads of a note's opening disagree about which take they render:** `NoteCards.load` uses
   `COALESCE(cb.chosen_variant_id, b.default_variant_id)` while the note picker's snippet uses
   `b.default_variant_id` alone, and neither is `renderPost`'s full resolution (chosen-if-live-and-
   active-and-same-block, else default). Pre-existing, cosmetic (a preview), untouched here.

### THE SUITE FIND (traced on two trees, not guessed)

The full Mac suite red-flagged `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTop
WithThreeStoriesExpanded` (`abs(top) → 3424.0 <= 4`) — a suite the 13u2b baseline calls green with
zero known issues. It reproduced ISOLATED, so it was not the load-flake class. Traced properly:
**green on a scratch worktree at this unit's start point (`4f7af04c`), red on mine, green again
with the one modifier removed** — my `.lineLimit(1)` on the SHARED `VoicedChip`. Some chip inside
an expanded story wraps today, so clamping the family changed a book row's height and a landing
that had settled moved during its hold. The clamp is now OPT-IN (`VoicedChip.lines`) and only the
title-suggestion chip takes it (`7aac721c`); the wrapping chip is recorded above for its owner.
*(The lesson, stated for the next unit: P-8's chrome rule is right, and applying it to a shared
control is a GEOMETRY change to every surface that control stands on.)*

### FINALS (2026-09-19)

- core `swift test` — **Test run with 1580 tests in 172 suites passed after 52.611 seconds.**
  (Baseline 1567/171 + 13 cells in 1 new suite = exactly this.)
- the FULL Mac suite — **Test run with 2823 tests in 471 suites failed after 763.099 seconds with
  2 issues.** Both issues are ONE test: `theReadClickLandsInIndexAtThatBlock`, the recorded
  environment red (KnownIssues row 58, owner 12) the brief names as the single tolerated one.
  Nothing else failed. (Baseline 2810/469 + 13 cells in 2 new suites = 2823/471, exactly.)
- the TUTORIAL SPINE — green in-run (every `Tutorial…` suite passed; zero failures).
- iOS build — **BUILD SUCCEEDED**.
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Server/`: ZERO.

### MOBILE PARITY (a note, not a build — the brief's rule)

The brain is core `Domain` and the phone can consume it as-is at its catch-up: `NoteCardFace.card`
+ `suggestedTitle` are pure and platform-free, and `TimelineItem.profile` (the journal marker) now
rides the shared listing row. What the phone owes: its note lists leading with the same answer, and
the capture chip on `MobileQuickNote`. **The cap is the one number to re-decide there** — 48 is
measured against the MAC's title room, and PL-24(b) records the phone's own as ~30.

### DEFERRED / NOT MINE (stated rather than done)

- **The title-suggestion chip's phone face** — the mobile catch-up's, per the parity note above.
- **Surfaces I did not align**, deliberately, because the brief names the Library + Pool card
  family and one unit is one surface: the Library's TIMELINE mode (a time-ordered surface where a
  date IS the organizing fact), the Trash/Archived listings, the note picker (a picker, not a note
  list — its snippet is row context under a search, and its own doc says titles stay as they are),
  and the shelf's book rows. The brain is ready for any of them.
- **The three "found, not mine" rows above.**

---

## UNIT B CLOSED — 2026-09-19

Item 4 built to her ruling and walked on the dev-store Debug build in both voices and both
appearances: ONE pure Domain brain for what a note-list card leads with, the Library's two
renderers and the Pool's cards consuming it through one composition each, the capture surfaces
offering the first words as a name without ever taking one, and nothing stored or renamed anywhere.
27 pins across four suites, the shipped stamps/#103/#105 arrangement byte-unharmed, one walk defect
found and fixed red-on-old, one suite find traced on two trees and fixed, three things found and
handed up rather than carried. New PROVISIONAL bundle: QUESTIONS **#119** (six calls). Suites and
finals above.

---

## UNIT C BRIEF — THE QUICK-CAPTURE MAC FACE (R-13u-4; self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 3 · GOVERNANCE + the
constitution · THE KICKOFF SITTING RECORD · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the 13u2
block's item 7 (**⇧⌘V is TAKEN** — your face must not claim it). (2) The 13u1 SITTING RECORD's
**R-13u-4 verbatim** (`notes/plans/phase-13u1-editor-seam.md`): *"the capture surface holds MANY
paragraphs; ⏎ FILES the note, ⇧⏎ adds a paragraph; the hand-off segments through `importPost`'s
bulk rule."* (3) The master plan's `### 13u` **item (9)** IN FULL — the phone's lost-prose
evidence and the ownership question this ruling answered (the capture surface owns MANY
paragraphs; the phone's face is the mobile catch-up's, built to the same ruling — you build the
MAC's only). (4) The code: `Features/QuickNote/QuickNoteView.swift` (note its deliberate
no-`.onSubmit` comment — the current model) · `Features/Shelf/QuickEntryBar.swift` +
`ShelfViewModel` (the shelf's bottom bar, R3) · `importPost`'s bulk segmentation rule (core) ·
the UNIT B RECORD if B landed a title-suggestion chip or handed it to you (consume B's brain
either way).

**Scope (ONE acceptance unit — the Mac's capture surfaces to ONE rule):**
1. **⏎ FILES · ⇧⏎ adds a paragraph**, on BOTH Mac capture surfaces (the shelf's quick-entry bar
   and the system-wide quick note window) — one rule, one shared brain where the two surfaces
   would otherwise fork (the forked-brains lesson; hoist to `App/Variorum/Shared/` if both need
   it and it is not platform chrome).
2. **Many-paragraph capture TYPED, not only pasted:** the box grows with its paragraphs (bounded
   — pick a sane max height and record it PROVISIONAL); the hand-off carries EVERYTHING through
   `importPost`'s bulk rule (segmentation on entry — the surface's ownership model, not a
   segmentation change).
3. **The lost-prose class must be impossible by construction:** moving the caret INTO an earlier
   paragraph must not change what ⏎ means or what the hand-off carries (the phone's 2026-08-23
   disaster — *"complete disaster, lost prose class of bug"* — is the anti-spec; write its Mac
   twin as a pin: caret into paragraph 1 of 3, ⏎ → the note files with ALL THREE paragraphs,
   nothing dropped).
4. **The title-suggestion chip** (item 4's, if B handed it to you): first words offered, one tap
   adopts, ignorable — on both capture surfaces, consuming B's Domain brain.
5. **Refusals/receipts** through the status seam's classed doors; the QuickEntryBar's
   text-preserving refusal behaviour (13l's fix) byte-preserved — a refusal NEVER destroys the
   typed capture (pin it if not already pinned on the new road).
6. **Keys:** ⇧⏎ is the paragraph; ⏎ files; ⇧⌘V stays PlainPaste's; no new chord claims without
   checking the registry + a grep (P-1: new doors declared).

**Pins:** the ⏎/⇧⏎ contract on both surfaces; the three-paragraph hand-off (segmented per bulk
rule — exact block count + texts); the caret-position independence pin (the lost-prose twin);
the refusal-preserves-text pin. Red-on-old where defect-shaped (the single-paragraph limitation
is a missing capability, not a bug — no manufactured reds).

**End verification:** FULL Mac suite (row 58 the one tolerated red) · tutorial spine green ·
iOS build green (shared files compile there) · YOUR walk with captures: type a three-paragraph
capture in BOTH surfaces, file each, verify the blocks in the note; the caret-into-paragraph-1
case; both voices, both appearances; captures to `notes/plans/13u3-screens/`. Record: **UNIT C
RECORD** appended here, LIVE STATUS from the first commit, UNIT CLOSED banner, ledger row 4
flipped in the same commit.

---

## UNIT C RECORD — THE QUICK-CAPTURE MAC FACE (opus-implementer, 2026-09-19)

**WHAT THIS UNIT DOES NOT DO (the record's first line):** it does not touch the PHONE's capture
face (R-13u-4 rules both platforms; the phone's face is the mobile catch-up's and is named as a
parity row below, not built here). It does not touch `Sources/VariorumCore/` behaviour —
`importPost`, `SegmentationRules.bulkSegments` and the spacing ruling are consumed byte-unchanged;
this unit changes what a capture SURFACE owns, never how text segments. Zero `Sync/`, zero
`Persistence/`, zero schema, zero migrations, the marker stays 8. It does not claim ⇧⌘V (taken —
`Shared/PlainPaste.swift`), does not touch the gutter (A1), the comments panel (A2) or B's Library
card work, and it leaves `TitleSuggestionChip` and `NoteCardFace.suggestedTitle` exactly as UNIT B
built them (consumed, never rebuilt). No new app-wide chord is claimed: ⏎ and ⇧⏎ act only inside a
capture box that has the caret.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | the record + LIVE STATUS | **DONE** |
| 1 | `CaptureKeys` — the ONE pure ⏎/⇧⏎ rule + its pins | **DONE** (5 cells green) |
| 2 | `CaptureTextView` — the ONE Mac capture surface (both hosts compose it) + its hosted-window key pins | **DONE** (5 cells green, real `NSEvent`s through production `keyDown`) |
| 3 | the QUICK NOTE pad on the one rule (⏎ files · ⇧⏎ paragraph; the refusal that keeps her text) | **DONE** |
| 4 | the SHELF/LIBRARY quick-entry bar on the same rule (the 13l text-preserving refusal byte-preserved) | **DONE** (29 cells green across 5 suites: the 3 new + the 2 they must not disturb) |
| 5 | the red-on-old measurement (the one defect-shaped row: a refused quick-note filing destroyed the capture) | **DONE** — measured, restored, re-verified (the table below) |
| 6 | the copy that teaches the keys — the helper dictionary + the tutorial's workspace lesson, with pins | **DONE** (2 new cells; `TutorialBookShapeTests` + `NodSetTests` + the quick-note word suite green) |
| 7 | QUESTIONS #120 (the PROVISIONAL calls) + the marker moved | **DONE** — six lettered calls; the stale mid-file marker retired and the live one moved to the file's end (#121) |
| 8 | the walk + captures, the full Mac suite, the tutorial spine, iOS build | **DONE** — 16 captures; finals below |

*(Nothing below this line is claimed until its row says DONE.)*

### THE RED-ON-OLD VERIFICATION — NAMED BEFORE IT RUNS (the checkpoint protocol)

**This unit is mostly a MISSING CAPABILITY, and the brief says so:** a capture box that could not
type a second paragraph was never a bug, and I am not manufacturing reds for the ⏎/⇧⏎ contract,
the growth bound or the hand-off. Exactly ONE row here is defect-shaped, and I traced it while
reading the shipped pad rather than looking for something to pin:

> **A REFUSED QUICK-NOTE FILING DESTROYED THE CAPTURE.** `QuickNotePad.take()` wrote
> `self.text = ""` and `titleFromFirstWords = false` **before** calling `QuickNoteMint.file`,
> which then `try`s `importPost` and CATCHES: on any throw the note does not exist, and her words
> are already gone from the only place they lived. `fileAndClose()` dismissed the window in the
> same breath, and the refusal was spoken into `session.status` — the MAIN window's status line,
> not the pad she was looking at. **This is 13l's L-b defect, one file over**, and the shipped
> comment explaining why the pad was left out of that fix — *"that pad mints as you type, so the
> text is already a note by the time it files"* — describes a pad that has not existed since 13f
> W5 shipped mint-on-close/⌘⏎/quit.

**The revert is a BEHAVIOURAL revert of that one mechanism**, applied to the current tree and then
undone (the standing method — the pre-13u3 tree cannot compile pins naming types it does not
have): restore the clear-before-the-mint pair at the top of `take()`. Nothing else moves.

- **Expected RED:** `aRefusedQuickNoteFilingKeepsTheCaptureInThePad` (its first two expectations —
  the text and the adopted name).
- **Expected GREEN under the same revert, and recorded as such so the measurement is honest
  rather than a blanket:** every other cell in the three new suites. They pin what this unit
  DECIDED (which key does what, what the box measures, what the hand-off segments to, what both
  doors teach) — a new capability is not a bug pin.

**RED-ON-OLD, MEASURED (2026-09-19).** Pre-revert state committed at `a0b1957d`. The revert
applied to that tree, the five suites run, the revert undone and the tree re-verified: **29/29
green** before · **29 tests, 3 issues, 1 cell red** under the revert · **29/29 green** after
(`git status` clean against `a0b1957d` + the record's own edit).

| pin | under the revert | what the measurement showed |
|---|---|---|
| `aRefusedQuickNoteFilingKeepsTheCaptureInThePad` | **RED**, 3 issues | `pad.text` came back `""` where she had typed three paragraphs; `titleFromFirstWords` came back `false`, so the name she had chosen was gone too; and the RETRY (`close()` after the refusal) minted **nothing** — `postID → nil` — because there was nothing left in the pad to file. That third issue is the defect's real shape: the refusal did not merely fail to save, it removed the last road back |
| the other 28 cells | green under the revert, by construction | they pin what this unit DECIDED — which key files and which makes a paragraph, what the box measures and where it stops, what three typed paragraphs segment to at both doors, what both doors teach. A missing capability is not a bug pin, and the brief says not to manufacture reds for one |

### WHAT THE TWO CAPTURE DOORS ARE NOW (the contract, in her words where they exist)

**ONE RULE, BOTH DOORS: ⏎ FILES WHAT YOU HAVE WRITTEN · ⇧⏎ ADDS A PARAGRAPH** (R-13u-4). Both
Mac capture surfaces — the shelf/Library quick-entry bar (R3) and the floating quick-note pad
(13f W5) — compose ONE view, `CaptureTextView` (`Core/Views/`, the Mac-only shared home beside
UNIT B's chip), whose `keyDown` asks ONE pure rule, `CaptureKeys.act`. A capture holds as many
paragraphs as she types; the hand-off carries the whole thing through `importPost`'s bulk rule,
untouched.

**What "file" MEANS is the host's, deliberately** (QUESTIONS #120(a)/(b)): the pad files and
CLOSES (its three doors — ⏎, ⌘⏎, "File It" — are one act, and "one summon = one note" is its
shipped grammar); the bar files and OPENS the note (R3's own grammar; its placeholder has always
said *"⏎ opens it"*). The rule says which KEY, never what the host does with the note.

**Before this unit the two doors disagreed in the deepest possible way:** the bar's ⏎ filed
(`.onSubmit`) and the pad's ⏎ typed a newline — its own header said so, from her round-14.2. So a
multi-paragraph capture could only be PASTED into the bar, never typed, and the pad could not be
filed from the keyboard at all without a chord. R-13u-4 settles both; round-14.2's "⏎ IS A
NEWLINE" is superseded **for this pad only**, and the half of it her ruling keeps — the pad holds
many paragraphs — is untouched.

**Why an AppKit box** (and why it is not a second text surface in P-3's sense): AppKit gives ⇧⏎ no
binding of its own — both keys dispatch `insertNewline:` and both type a plain LF (measured and
pinned in `ReturnKeyTraceTests`; `EditorTextView.isSoftNewlineKey` carries the same lesson for the
editor's gesture) — so the ONLY place the two can be told apart is the key event, which neither
`TextEditor` nor `TextField` hands over. SwiftUI's `TextEditor` IS an `NSTextView`, so nothing new
is mounted; what changed is who owns `keyDown`. The box carries no block identity, no
`BlockRangeIndex`, no `PaneTextAuthority`, no `EditorRouter` claim and no liveness ring — P-3's
invariants are not extended here, they are still simply not engaged.

**The caret can no longer change what a key means.** `CaptureKeys.act` takes an event and nothing
else; `.paragraph` is deliberately NOT consumed, so the newline is AppKit's own `insertNewline:`
AT THE CARET. A surface that inserted the newline itself would have to know where the caret is —
and "where the caret is" is exactly what the phone's lost-prose defect was made of.

**Everything else the box does, and where it came from:** it grows with its paragraphs to a bound
and then scrolls (160 pt in the bar ≈ eight lines — #120(c); the pad takes its window); its font
and ink come from `EditorTypography` (the SAME face `VoiceTokens.body` renders in both voices) and
its ink is 18j's ONE dynamic per-voice colour, so an appearance change costs no write; its caret
is the palette's accent through the tokens road; spelling follows the app's one this-Mac
`SpellcheckLevel` (ships `off`); it arms the `FallbackCanary` (TEXTKIT2 §4's third practice) and
opts into TK2 explicitly at init; and its style writes are gated (the A47c lesson).

**UNIT B's title-suggestion chip is consumed, not rebuilt** — both hosts still raise it, one click
still adopts, and a capture she never clicks still files untitled.

### THE TRACED MECHANISM (what was actually wrong, before anything was changed)

**A REFUSED QUICK-NOTE FILING DESTROYED THE CAPTURE.** `QuickNotePad.take()` cleared `text` and
`titleFromFirstWords` BEFORE calling `QuickNoteMint.file`, which `try`s `importPost` and CATCHES:
on any throw the note does not exist and her words are already gone from the only place they
lived. `fileAndClose()` dismissed the window in the same breath, and the refusal was spoken into
`session.status` — the MAIN window's status line, not the pad she was looking at. **This is 13l's
L-b defect one file over**, and the shipped comment explaining why the pad was exempt — *"that pad
mints as you type, so the text is already a note by the time it files"* — describes a pad that has
not existed since 13f W5 shipped mint-on-close/⌘⏎/quit.

**Now:** the text leaves the pad only when a note exists to hold it; the refusal is spoken ON the
pad (`lastError`, the bar's 13l shape, in the alarm register); the window stays open so the next
⏎ tries again; and the mint RETURNS its outcome instead of only speaking it, so the two lifecycle
triggers that have no pad left (close, quit) hand it to the status seam themselves — one message
per event, spoken where she is. "One summon = one note" is preserved on every path, because a
refusal mints nothing.

### THE PINS (18 cells in 3 new suites + 2 shipped suites amended)

| cell | what it holds | red-on-old |
|---|---|---|
| `plainReturnFilesAndShiftReturnMakesAParagraph` | her ruling, as the two lines it is (keypad Enter included) | not bug-class (a new rule) |
| `capsLockAndTheKeypadAreNotMeaning` | the 13d F-2 mask lesson inherited: caps lock is state, the keypad is hardware | not bug-class |
| `everyOtherKeyIsNobodysHere` | ⌥⏎ · ⌃⏎ · ⌘⏎ · ⌘⇧⏎ · letters reach the text untouched | not bug-class |
| `theCaptureRuleAndTheEditorsSoftNewlineAgree` | the app's two Return masks agree, pinned rather than one reaching into the other | not bug-class |
| `theBoxGrowsWithItsParagraphsAndStopsAtItsBound` | the growth arithmetic, floor and ceiling, and a nonsensical bound losing to the floor | not bug-class |
| `returnFilesTheWholeCaptureWhereverTheCaretIs` | **the lost-prose twin:** four caret positions, including inside paragraph one; every ⏎ hands over all three paragraphs | not bug-class (the class is impossible by construction, which is what it asserts) |
| `anEditToAnEarlierParagraphRidesTheFiling` | her report's second half — the edit to the first line rides too | not bug-class |
| `shiftReturnTypesAParagraphAtTheCaretAndFilesNothing` | the break lands AT the caret, is a plain LF (not U+2028), files nothing, and moves the caret | not bug-class |
| `aThreeParagraphCaptureCanBeTypedAndThenFiled` | the whole gesture through real key events: ⇧⏎ ⇧⏎ ⏎ | not bug-class |
| `theMeasuredBoxGrowsAsParagraphsArrive` | growth through the app's ONE measurement brain at a fixed width | not bug-class |
| `aThreeParagraphPadFilesThreeBlocks` | the pad's hand-off: exact block count AND exact texts through the real `importPost` | not bug-class |
| `aThreeParagraphBarEntryFilesThreeBlocks` | the bar's hand-off: the same three blocks, because both doors ride the same bulk rule | not bug-class |
| `theCaretInParagraphOneChangesNothingAboutWhatIsFiled` | **end to end:** real key events → the real pad → the store holds all three paragraphs INCLUDING the edit | not bug-class |
| `aRefusedQuickNoteFilingKeepsTheCaptureInThePad` | her words, her adopted name, the refusal's sentence, nothing minted, and the retry that works | **RED**, 3 issues |
| `aRefusedBarEntryKeepsTheCaptureInTheBox` | 13l's fix byte-preserved on the new road (the pair to the pad's, read side by side) | not bug-class (13l's own cells ride unmodified in `QuickEntryBarTests`) |
| `bothCaptureDoorsTeachTheSameTwoKeys` | the pad's hint and the bar's placeholder, and that the retired model is gone from both | not bug-class |
| `theHelperDictionaryTeachesTheCaptureKeys` (`QuickNoteWordTests`) | the dictionary entry + the shortcuts tab's own row | **RED on the shipped copy** (it taught *"Return makes a new line, not a new note"*) |
| `theWorkspaceLessonTeachesTheCaptureKeys` (`TutorialBookShapeTests`) | the tutorial lesson through the real seeded store | **RED on the shipped lesson** (same retired sentence) |

*(Amended, not replaced: `QuickNoteTests`' three mint-trigger cells, `NodSetTests`' two, and
`TitleSuggestionChipTests`' pad cell now read the mint's `Outcome` instead of a bare id — the same
assertions, through the door that now reports. `QuickEntryBarTests`' five 13l cells are
byte-unmodified and green.)*

**Why so few reds, said plainly:** the single-paragraph limitation was a MISSING CAPABILITY, not a
bug — the brief says so and tells me not to manufacture reds for one. Three cells here are
defect-shaped: the pad's refusal (measured above) and the two copy surfaces that taught the model
her ruling replaced.

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

16 captures in `notes/plans/13u3-screens/` (gitignored), `c-01`…`c-16`.

| capture | what it shows |
|---|---|
| `c-01` · `c-02` | **the headline:** three paragraphs TYPED into the shelf bar with ⇧⏎ (the box grown to hold them, UNIT B's chip beneath), then ⏎ — the note opens and the bar reads **`block 1/3`** |
| `c-03` · `c-04` · `c-05` | the same in the floating pad: three typed paragraphs, ⏎ files AND closes it (the quiet receipt *"Filed in Quicknotes — tagged #quicknote."*, the main window never navigating), and the filed note is **`block 1/3`** in the Quicknotes book |
| `c-06` · `c-07` | **the lost-prose case, on the real app:** the caret clicked INTO paragraph one, `(EDITED IN PARAGRAPH ONE)` typed there, then ⏎ — the note holds all three paragraphs WITH the edit, `block 1/3`. No mode, no frozen prefix, nothing dropped |
| `c-08` · `c-09` (Terminal light) · `c-10` · `c-11` (Study light) · `c-12` · `c-13` (Study dark) · `c-14` · `c-15` (Terminal dark) | both surfaces in both voices and both appearances: the voice's own writing font in the box, the dynamic ink readable on a fully black room (R51), the palette's accent as the caret, the chip and the hint in the voice's register |
| `c-16` | the bound: eleven typed paragraphs — the box stops growing and SCROLLS, the caret's line visible, the chip still offering the FIRST words; ⏎ then filed it as **`block 1/11`** |

**WALK VERDICT: both capture doors answer the same two keys, a typed multi-paragraph capture
survives the hand-off exactly, and the phone's lost-prose case cannot be constructed on the Mac.**
Also driven and confirmed: ⌘⏎ still files and closes the pad; ⌘W (closing) still files it; ⏎ on an
EMPTY pad does nothing and leaves it open (#120(d)); the box keeps its text across a voice change.

**The walk found TWO things the desk could not, both fixed in the same session** (`9da5bec3`):

1. **The typed words moved sideways.** `NSTextContainer` ships a 5 pt `lineFragmentPadding`, so
   the text sat a few points right of the placeholder drawn behind it — visible the instant she
   typed the first character. Set to 0, and re-measured: the placeholder's and the typed text's
   left ink columns now land on the SAME pixel (abs x = 460 in both captures).
2. **The pad's hint truncated mid-rule.** At the pad's own 340 pt the one-line hint read
   *"⏎ files it · ⇧⏎ new paragraph · c…"* — the third clause unreadable at the width the window
   actually opens at. Two lines now, and the whole rule reads (`c-09`…`c-15`). The pad's box also
   gained the host inset both the text and the placeholder share, since the pad draws the box's
   surface itself and 0 padding put the prose against its edge.

**What the walk could NOT stage:** a store-level refusal (the pad's and the bar's
text-preserving behaviour is the harness's, through the endorsed defaulted-seam — measured
red-on-old above).

### FINALS (2026-09-19)

- core `swift test` — **Test run with 1580 tests in 172 suites passed after 53.746 seconds.**
- the FULL Mac suite — **Test run with 2841 tests in 474 suites failed after 768.914 seconds with
  2 issues.** Both issues are ONE test: `theReadClickLandsInIndexAtThatBlock`, the recorded
  environment red (KnownIssues row 58, owner 12) the brief names as the single tolerated one.
  Nothing else failed. (Baseline 2823/471 + 18 cells in 3 suites = 2841/474, exactly.)
- the TUTORIAL SPINE — green in-run (every `Tutorial…` suite passed, including the lesson this
  unit edited).
- iOS build — **BUILD SUCCEEDED**.
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Sources/VariorumCore/`: ZERO. `App/Variorum/Shared/`: ZERO.

### MOBILE PARITY (a note, not a build — the brief's fence)

**R-13u-4 rules BOTH platforms and the phone's face is the mobile catch-up's** (the master plan
item (9)'s own fence: *"Mobile batch 4.6 builds the phone's face to this ruling and does NOT
re-decide it"*). The phone still ships the A5-2 ONE-BLOCK rule that produced her 2026-08-23
lost-prose report; nothing here changes it. What the Mac now has that the phone owes: the two
keys, a capture box that holds many typed paragraphs, a bound with scrolling, the hand-off through
`importPost`'s bulk rule, and the refusal that keeps the capture. `CaptureKeys` is deliberately
Mac-shaped (it reads an `NSEvent`); the phone's answer is UIKit's, and the RULE — file vs
paragraph — is what travels, not the type. A parity row is the orchestrator's to file.

### FOUND, NOT MINE (handed up rather than carried)

1. **`ShelfViewModel.quickEntry` is a dead parallel road.** It mints a post through `importPost`
   exactly as `QuickEntryModel` does, and NOTHING calls it but `ShelfAndPaletteTests`. It predates
   13l's L-b extraction (which moved the bar's rule into `QuickEntryModel`) and was left behind.
   Two mint roads for one door is the drift class; retiring it is a one-line delete plus a test
   edit, and it is a second surface, so I did not take it.
2. **The pad's close/quit refusal still loses the capture** — deliberately recorded rather than
   invented around. If the store refuses at the moment the window is going (`onDisappear`) or at
   app quit, there is no pad left to keep the words in, and the status seam gets the sentence. The
   honest fix is a one-slot unfiled-capture parking spot the next summon restores, which is
   product behaviour nobody has ruled. QUESTIONS #120(e) carries the shape of the decision.
3. **A walker fact that cost me twenty minutes, now in `Tools/WalkKit/README.md`:** the quick-note
   pad is a FLOATING window (CG layer 19), so `walk-cap`'s layer-0 filter skips it entirely — and
   because `walk-cap` writes `w0.png`, `w1.png`… by INDEX, a run that finds fewer windows than the
   last one leaves STALE files behind with the old names. Capture floating windows by id
   (`screencapture -l <id>`), and read the id from a listing that does not filter by layer.

### DEFERRED / NOT MINE (stated rather than done)

- **QUESTIONS #120** — the six calls this unit had to make inside her ruling (what ⏎ closes · what
  it opens · the 160 pt bound · the empty-pad ⏎ · where a refusal speaks · the two visible
  consequences of the box being the app's own). All PROVISIONAL, each one line to change.
- **The phone's face** (above) — the mobile catch-up's, by the master plan's own fence.
- **Not touched, as the brief fences:** UNIT A1's gutter, UNIT A2's comments panel, UNIT B's
  Library card work and its `NoteCardFace` brain (consumed, never rebuilt), ⇧⌘V (`PlainPaste`),
  every other unit in this phase, `Sources/VariorumCore/`, `Shared/`, `Sync/`, `Persistence/`,
  the schema and the marker.

---

## UNIT C CLOSED — 2026-09-19

The Mac's two capture doors answer ONE rule — **⏎ files it · ⇧⏎ adds a paragraph** — through ONE
box and ONE pure key decision; a capture holds as many paragraphs as she types and hands every one
of them to `importPost`'s bulk rule; the caret cannot change what a key means, so the phone's
2026-08-23 lost-prose class is impossible here by construction; and a refusal now keeps her words
in the box that is still in front of her (the one defect-shaped row, measured red-on-old). The
copy that taught the retired model — the tutorial's workspace lesson and the helper's quick-note
entry — teaches the ruling instead, each with its pin. 18 pins in three new suites, a walk in both
voices and both appearances that found two things the desk could not, and one new PROVISIONAL
bundle (#120). Suites and finals above.

---

---

## UNIT D BRIEF — NAMED COMMITS (item 14, R-13u3-1; self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 4 · GOVERNANCE + the
constitution · THE KICKOFF SITTING RECORD (**R-13u3-1 is your law**: names EDITABLE after the
fact — a rename door in Block History; the snapshot TEXT immutable, I5 untouched; the door
offered everywhere `message` exists, auto-commits keeping their occasion as the DEFAULT label) ·
the 13u2 block's items 1 (the status seam's classed doors) and 7 (**⇧⌘V is taken** — your name
field claims no chord without a registry check) · ENVIRONMENT TRAPS · CAST & DISCIPLINE ·
`Tools/WalkKit/README.md`'s walker facts. (2) The master plan's `### 13u` **item (14)** — her
words verbatim (*"optional name at the manual-commit door, enter-to-skip keeps ⌘S instant"*;
names in Block History + listings; her 13n motivation). (3) AppSpec §7's `commit_point` DDL +
§9's `commit` op (the `message` column has existed since v1 — **ZERO schema**). (4) The code:
the ⌘S road (`CommitBar` / `EditorViewModel`'s commit path) · `Features/Editor/SavepointHistory.swift`
· `App/Variorum/Shared/BlockHistoryFace.swift` (**shared with the phone** — `SavepointRowFace`;
extending the shared brain is the non-forking road, and the phone's history listing gaining
names for free is a MOBILE-VISIBLE change: record it as a parity note, do not build phone chrome)
· `Sources/VariorumCore/Operations/` (the commit family, for your new op's home and conventions).

**A sync fact, checked by the orchestrator so you do not re-derive it:** `Merge.swift` applies
EVERY table server-version-wins (the §6 matrix's "insert-if-absent" for `commit_point` describes
the rows' natural immutability, not an engine arm), and outbox triggers fire on UPDATE — so a
message rename propagates as ordinary metadata CAS with **zero `Sync/` lines**. Touch nothing
under `Sources/VariorumCore/Sync/`. The SyncSpec §6 one-line annotation is the CLOSEOUT's delta
under R-13u3-1, not yours.

**Scope (ONE acceptance unit — the savepoint-name family):**
1. **Core op** `renameCommitPoint(commit, message?)` (or the conventions' natural name): set/clear
   `message`; nil clears; a no-op writes nothing (no outbox row); identity-level metadata — NO
   touch, NO churn (the `setBlockName` class). Refusal edges, both PROVISIONAL one-liners logged
   to QUESTIONS: refuses under a SEALED post (the seal's letter — "everything under the post");
   ALLOWED on a locked variant (the lock guards the buffer; a label is not the buffer — the
   variant-label parallel). Exact state-transition tests.
2. **The manual-commit door:** ⌘S summons a minimal focused name field — **⏎ empty files the
   savepoint unnamed (two keys, instant); text + ⏎ files it named; ⎋ cancels the commit whole**
   (PROVISIONAL — the least-surprising reading; log it). The field is voiced, claims no global
   chord, and speaks through the classed doors. The commit op itself is untouched (`message`
   rides the existing parameter).
3. **Names shown:** Block History's savepoint runs + commit listings lead with the name where
   set; auto-commits show their occasion as today (the occasion is the default label, never
   overwritten by the display); extend the SHARED face brain (`SavepointRowFace`) so both
   platforms stay one-brained — the phone COMPILES and its listing may gain names (parity note).
4. **The rename door:** in Block History beside the savepoint (R-13u3-1) — offered on manual AND
   auto savepoints (her unqualified "Editable"); renaming an auto savepoint sets `message` while
   `kind` stays `auto` (the occasion remains visible where the display distinguishes kinds).
5. **Fences:** zero schema · zero migrations · zero `Sync/` · marker 8 · I5 untouched (TEXT never
   editable) · the gutter/panel/card surfaces untouched.

**Pins:** the op's transitions (set · clear · no-op · seal refusal · locked-variant allowance);
the ⌘S skip road = exactly one `commit_point`, message NULL, kind manual (and the old
single-keystroke pins updated deliberately, never deleted to pass); the named road; the rename
road (red-on-old is not owed — a new capability, not a defect — but any behaviour you FIX on the
way is). The history face's name display pinned on both kinds.

**End verification:** FULL Mac suite (row 58 the one tolerated red) · tutorial spine green ·
iOS build green (the shared face compiles) · the FULL mobile suite if `Shared/` changed
(expected: yes — run it, record the count against 626/106 w/4 known) · YOUR walk with captures:
⌘S ⏎ (instant, unnamed) · ⌘S "before the AI edit" ⏎ · rename it · an auto savepoint's occasion
label untouched · both voices, both appearances; captures to `notes/plans/13u3-screens/`.
Record: **UNIT D RECORD** appended here, LIVE STATUS from the first commit, UNIT CLOSED banner,
ledger row 5 flipped in the same commit.


---

## UNIT D RECORD — NAMED COMMITS (opus-implementer, 2026-09-19)

**WHAT THIS UNIT DOES NOT DO (the record's first line):** it does not touch the PHONE's commit
door or build any phone chrome — the shared face brain gains names and the phone's Block History
listing therefore shows them for free (a MOBILE-VISIBLE change, recorded as a parity note below,
not built). It changes NOTHING about what a savepoint IS: the snapshot text stays immutable (I5),
`commit_point.message` has existed since v1, so ZERO schema, ZERO migrations, the marker stays 8,
and `Sources/VariorumCore/Sync/` gets ZERO lines (the rename rides the shipped `commit_point`
UPDATE outbox trigger and server-version-wins CAS; `message` was already classified ENCRYPTED in
`SyncSchema`, so no disclosure envelope moves either). It does not touch UNIT A1's gutter, UNIT
A2's comments panel, UNIT B's card family or UNIT C's capture boxes, and it claims no new global
chord (⇧⌘V stays `PlainPaste`'s): ⏎ and ⎋ act only inside a name field that has the keyboard.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | the record + LIVE STATUS | **DONE** |
| 1 | core — `SavepointName` (the one normalisation) + `renameCommitPoint` + its state-transition pins | **DONE** (11 cells green; the 39 commit/variant/savepoint suites 129/129 green beside them) |
| 2 | the SHARED face — a savepoint's name LEADS its quiet line (`SavepointRowFace`) + pins | PENDING |
| 3 | the Mac name field — one component, one pure key rule, voiced | PENDING |
| 4 | the commit doors summon it (Write · Takes/Lenses · Canvas · Compare) + pins | PENDING |
| 5 | the RENAME door in Block History, on manual AND quiet savepoints + pins | PENDING |
| 6 | the copy that teaches (the helper dictionary, the cheat sheet, the tutorial lesson) + pins | PENDING |
| 7 | QUESTIONS #121 (the PROVISIONAL calls) + the next-free marker moved | PENDING |
| 8 | the walk + captures, the FULL Mac suite, tutorial spine, iOS build, the FULL mobile suite | PENDING |

*(Nothing below this line is claimed until its row says DONE.)*

### THE RED-ON-OLD VERIFICATION — NAMED BEFORE IT RUNS (the checkpoint protocol)

**This unit is a MISSING CAPABILITY and the brief says so** (*"the rename road (red-on-old is not
owed — a new capability, not a defect — but any behaviour you FIX on the way is)"*). A face that
never offered a name was not a bug, and I am not manufacturing reds for the op's transitions, the
field's key rule or the display. If a defect turns up while I read the shipped commit roads it is
traced, measured red-on-old and recorded in this section; if none does, this section says so.

**BASELINES AT OPEN** (UNIT C's recorded finals, this session's start — never re-run at a start):
core **1580 / 172** green · the FULL Mac suite **2841 / 474** with ONLY row 58's recorded
environment red (`theReadClickLandsInIndexAtThatBlock`) · the FULL mobile suite **626 / 106 with 4
known issues** · iOS build green · marker **8**.
