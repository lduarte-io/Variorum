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
| 5 | UNIT D — named commits (item 14 / R-13u3-1) | **DONE 2026-09-19** — `203a722c`…`a2c5ede0` + this record's close; the UNIT D RECORD is at the end of this file (the contract as built · the three traced mechanisms, two found by the walk and one real regression found by the suite · 18 pins in 6 suites + 4 shipped suites amended · the walk's 16 captures in both voices and both appearances · the mobile-parity note · three things handed up). QUESTIONS #121 opened |
| 6 | UNIT E — the #80(e) two faces (item 15) | **DONE 2026-09-19** — `1031135b`…`e24318ce` + this record's close; the UNIT E RECORD is at the end of this file (the PROBE that falsified #80(e)'s premise with its mechanism · the bounded read with its anti-drift pin against `PurgeFamily` · 8 new cells in 3 suites with the one defect-shaped cell red on the shipped words · the walk's 14 captures and what it proved · the re-seed note for the closeout). QUESTIONS #122 opened |
| 7 | UNIT F — PDF renders formatting (item 16) | **DONE 2026-09-19** — `0003bac1`…`261cae8a` + this record's close; the UNIT F RECORD is at the end of this file (the trace · the red-on-old at 6-of-8 cells / 31 issues · the ONE hoist with its two collapsed duplicate rules · 10 pins incl. two anti-drift guards and the `.md` byte-fence · the walk's 9 captures with BEFORE/AFTER pairs and the two-build `.md` SHA match · the literal-colour regression the suite caught in my own diff and the better fix that answered it · three things handed up). QUESTIONS #123 opened
| 8 | UNIT G — the ceremony-sheet residuals (KnownIssues row 42) | **DONE 2026-09-19** — `c79860b0`…`91209567` + this record's close; the UNIT G RECORD is at the end of this file (the traced mechanisms · the red-on-old table, 11 issues across 4 cells on `25638746` · 13 pins incl. an anti-drift net over SIX rendered-take readers and an EXPLAIN seek pin · the walk's 14 captures in both voices, with the drift staged BY HAND through two dev instances on one store · both full-suite reds adjudicated on two trees · item 6's five verdicts). KnownIssues row 42 RESOLVED; QUESTIONS #124 opened |
| 8b | UNIT H — the Takes board's live-card delete door + the lesson's truth (the E hand-up, adjudication 2 above) | **DONE 2026-09-19** — `14ae400c`…this record's close; the UNIT H RECORD is at the end of this file (the traced mechanisms, incl. a CORRECTION to the adjudication — the board's cards never had a ⋯, the F1 pass reached its article cell instead · the red-on-old table, 12 issues across 6 of 8 cells on `4f069b1b` · 9 pins in one new suite, incl. the PER-SURFACE declared⇔rendered guard the union walk could never make · the ⋯ sweep's second find, a row renamed at the Snippets ruling with a shipped pin holding the old name "verbatim" · the walk's 17 captures running the LESSON'S OWN experiment in both voices and both appearances · both full-suite reds adjudicated, one of them a NEW flake-list member · one breach of the green-per-commit rule, stated). QUESTIONS #125 opened |
| 9 | The ladder — `fable-reviewer`, combined diff, standing rounds | **CLOSED 2026-09-19** — TWO rounds + a final clean sanity pass, full cross-model flow both rounds (R1 0B/1M/2m/3N: the MAJOR = the editor spin's precondition, fixed at its mechanism; the R1-3 dispute ruled a WIDEN — all four doors; S-1…S-4 all taken. R2 0B/0M/1m/1N: both fixed, the MINOR's red measured first. No round 3 owed; one Fable budget death cost ZERO commits). Records: `13u3-ladder-round1.md` · `-round1-responses.md` · `-round2.md` |
| 10 | The orchestrator's walks + closeout ritual + the pre-authorized `/Applications` refresh (R-13u3-2) | WALK DONE (spine PASSES); notes-side closeout DONE (`9832175e`); the closing full-suite run + the refresh: **the refresh WAITS on a zero-instance window — her app is running and is never touched; she quits at her convenience, then the refresh runs on the standing rails** |

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
| 2 | the SHARED face — a savepoint's name LEADS its quiet line (`SavepointRowFace`) + pins | **DONE** (5 cells; with `BlockHistoryPaneTests` 23/23 green) |
| 3 | the Mac name field — one component, one pure key rule, voiced | **DONE** (2 cells beside the face's 5; 7/7 green) |
| 4 | the commit doors summon it (Write · Takes/Lenses · Canvas · Compare) + pins | **DONE** (6 new cells; the 4 new suites 13/13, and the shipped suites the doors touch — canvas · compare · the board doors · commit flow · confirmations — 59/59 green) |
| 5 | the RENAME door in Block History, on manual AND quiet savepoints + pins | **DONE** (4 cells; the whole family + the pane's shipped suite 35/35 green) |
| 6 | the copy that teaches (the helper dictionary, the cheat sheet, the tutorial lesson) + pins | **DONE** (2 cells, both red on the shipped copy; the two tutorial suites 14/14 green) |
| 7 | QUESTIONS #121 (the PROVISIONAL calls) + the next-free marker moved | **DONE** — six lettered calls; the marker moved to #122 at the file's end |
| 8 | the walk + captures, the FULL Mac suite, tutorial spine, iOS build, the FULL mobile suite | **DONE** — 16 captures; finals below (the full Mac suite run THREE times, the deciding one alone) |

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

### WHAT A SAVEPOINT IS NOW (the contract, in her words where they exist)

**A SAVED MOMENT CAN CARRY A NAME, AND THE NAME IS ALWAYS EDITABLE** (item 14 · R-13u3-1).
`commit_point.message` has existed since v1 and §9's signature already read
`commit(variant, kind=manual, message?)`; what never existed was a door. Now:

- **⌘S opens a small focused field; ⏎ files the savepoint.** Empty means unnamed, so the fast
  road is *"enter-to-skip keeps ⌘S instant"* exactly as she wrote it — two keys, and the savepoint
  she has always got. ⎋ (or a click outside, or the window going) cancels the whole gesture and
  writes nothing.
- **Every Mac commit door answers the same gesture:** Write's bar and its chord, the Takes/Lenses
  bar, Canvas and Compare (whose only commit door is the chord itself). ONE component
  (`Core/Views/SavepointNameField.swift`), ONE pure rule (`SavepointName`, core), five hosts.
- **The name LEADS the row in Block History**, in the accent register, with *when · how it was
  saved* muted beneath it; **Name / Rename** sits beside **Restore** on EVERY savepoint — manual
  and quiet alike (her unqualified *"Editable"*). Clearing the field removes the name.
- **A renamed quiet savepoint is still quiet.** The rename writes `message` and nothing else, so
  the occasion stays visible wherever a face tells the two kinds apart — her ruling's own note,
  pinned twice (as a value and through the store).
- **The snapshot's TEXT is untouched by every road here.** I5 is not merely respected, it is
  unreachable: no door in this family can write `commit_point.text`, and the op's own pin asserts
  the text is byte-identical after a rename of a take that has since moved on.

**Why a popover and not a sheet** (#121(d)): a sheet takes the window for a one-line optional
name, and her ruling's whole point is that the fast road stays fast. The field hangs at the door
that summoned it, takes the keyboard on appear (the ⌘K palette's idiom — `.task { focused = true }`,
verified on the walk in all four surfaces and both voices), and gives it back when it goes.

**What the sync fence cost: nothing.** `message` was already classified ENCRYPTED in `SyncSchema`
(it is her prose), the shipped `commit_point` outbox triggers carry the UPDATE, and `Merge.swift`
applies the row server-version-wins like every other table. ZERO `Sync/` lines, and the wire's
disclosure envelope does not move.

### THE TRACED MECHANISMS (what was actually wrong, and where each was caught)

**This unit is a MISSING CAPABILITY**, and the brief says not to manufacture reds for one. Nothing
was wrong with savepoints; there was simply no door. So there is no red-on-old table here, and the
three things that WERE wrong were all found by driving the thing rather than by reading it:

1. **THE PLACEHOLDER TRUNCATED AT THE DOOR (the walk).** The first wording was *"name this moment
   (optional)"* and it cut to *"name this moment (optional"* at the field's own width in the
   Terminal voice's monospace — the door's one sentence, unreadable at the one width the field
   actually opens at. The optionality belongs to the hint (*"an empty name is fine — the moment is
   saved either way"*), so the prompt is now just *"name this moment"*, the field is 260 pt, and
   the rename door's placeholder says **"no name"** — which is exactly what ⏎ leaves behind after
   a clear.
2. **THE RENAME HINT RAN TO FOUR LINES AND CUT MID-WORD (the walk).** *"…the moment's text never
   chang…"* at the field's width. What I5 says is now the DOOR's `help` sentence, where there is
   room for it, and the hint is two lines.
3. **A ZERO-SIZE ANCHOR STILL TOOK THE STACK'S SPACING (the full Mac suite).** Canvas and Compare
   render no commit door, so I hung the field off a zero-size `Color.clear` at the head of their
   strips — and a zero-WIDTH child still takes an `HStack`'s spacing: Compare's toolbar moved 8 pt
   off the one left edge its row-16 pin holds, and `CompareLensesAlignmentTests` caught it on the
   first full run. Both anchors are `.overlay(alignment: .topLeading)` now, which takes no layout
   at all and anchors in the same corner. **This is the unit's one real regression, found by the
   suite, fixed and re-measured** (`a2c5ede0`).

*(A fourth thing the walk had to settle rather than assume: after the first ⏎ the live take pane
showed a caret on a second line, which reads exactly like a stray newline leaking into the buffer.
Three more ⏎ presses added no further lines, the savepoint texts were identical across all four,
and the pane came back one line tall after a relaunch — TK2's own trailing line fragment
(TEXTKIT2 §3), not a newline. Recorded because the next reader will see it too.)*

### THE PINS (18 new cells in 6 suites + 4 shipped suites amended)

| cell | what it holds | red-on-old |
|---|---|---|
| `theNameRuleTrimsTheEndsAndKeepsTheInsideWhole` (core) | the ONE rule: ends trimmed, nothing left means no name, the inside kept whole | not bug-class (a new rule) |
| `renamingSetsClearsAndNormalizes` (core) | set · re-set · clear by whitespace · clear by nil, read back from the store | not bug-class |
| `renamingNeverTouchesTheSnapshotOrItsKind` (core) | **I5**: the text is byte-identical after a rename; a renamed quiet savepoint stays `auto` | not bug-class |
| `namingIsMetadataNeverATouchStampOrChurn` (core) | no touch, no churn, no major-revision stamp (the `setTakeLabel` conventions) | not bug-class |
| `aNoOpRenameWritesNothingAtAll` (core) | the same name again, and a clear on an unnamed savepoint: no row, no outbox entry | not bug-class |
| `renamingRidesTheExistingCommitPointOutboxTriggers` (core) | the brief's sync fact, **verified rather than assumed** | not bug-class |
| `aSealedPostRefusesRenaming` (core) | the seal's letter (PROVISIONAL #121(c)) | not bug-class |
| `aLockedTakeStillTakesASavepointName` (core) | the lock freezes the BUFFER; the snapshot is immutable anyway (#121(c)) | not bug-class |
| `anArchivedTakesSavepointStillTakesAName` (core) | naming never resurrects | not bug-class |
| `aMissingSavepointAndADeadTakeBothRefuse` (core) | the two honest throws | not bug-class |
| `aSavepointCanBeBornNamedAndTheNameIsNormalizedThere` (core) | the commit door's shipped parameter: named · skipped · one savepoint per press | not bug-class |
| `theNameIsTheFirstThingTheRowSays` | the name LEADS `meta`, details follow whole | not bug-class |
| `anUnnamedSavepointReadsExactlyAsItAlwaysHas` | the ordering change costs the shipped rows nothing | not bug-class |
| `aNamedQuietSavepointStillSaysQuiet` | her ruling's own note, as a value | not bug-class |
| `theFaceReadsTheSameNameRuleTheStoreWritesBy` | a face can never show a name the store would normalise away | not bug-class |
| `theRenameDoorWordsItselfToItsRow` | Name vs Rename, the two helps, the two receipts | not bug-class |
| `theAskSeedsItselfFromWhatItIsNaming` | the commit door opens EMPTY, the rename door on what is there | not bug-class |
| `theFieldTeachesItsTwoKeys` | the hint says ⏎ and ⎋ and that an empty name is fine; I5 at the door's help | not bug-class |
| `commandSThenReturnFilesOneUnnamedSavepoint` | **the skip road:** the door writes nothing, ⏎ files exactly one savepoint, message NULL, kind manual, the buffer exact | not bug-class |
| `aTypedNameRidesTheSavepointAndTheReceiptSaysIt` | the named road end to end, receipt included | not bug-class |
| `cancellingTheFieldFilesNothingAtAll` | ⎋ is no savepoint, not a savepoint with no name (#121(b)) | not bug-class |
| `theDoorRefusesBeforeItOpensAFieldItCannotFile` | P-2: the caret in the open tail refuses where it always did, and no field opens | not bug-class |
| `theNamedSavepointReadsBackNameFirst` | the store half and the face half meeting on one savepoint | not bug-class |
| `theTakesDoorOpensTheFieldAndFilesWhatItIsGiven` | the boards' door: named, then the skip road on the same take | not bug-class |
| `renamingASavepointSetsAndClearsItsNameAndSaysSo` | the pane's act and both receipts | not bug-class |
| `aQuietSavepointCanBeNamedAndStaysQuiet` | the same claim through the REAL store and the real model | not bug-class |
| `renamingNeverChangesWhatTheMomentHolds` | I5 asserted where the door is, with the take moved on | not bug-class |
| `aSealedNoteRefusesTheRenameAndSaysWhy` | the refusal arrives in the pane's own register, worded | not bug-class |
| `theHelperTeachesTheNameAndTheSkipKey` | the dictionary entry, the ⌘S row, the hover sheet | **RED on the shipped copy** (neither carried ⏎ or the word "name") |
| `theSavingLessonTeachesTheNameAndTheSkipKey` (`TutorialWalkTests`) | the tutorial lesson through the real seeded store | **RED on the shipped lesson** |

*(Amended, not replaced: `TutorialWherePlacesActsTests`' ⌘S arm, `CommandRoutingTests`' routed-⌘S
pin, `TakeToBlockDoorTests`' no-ring arm and the Canvas/Compare no-focus arms now drive the DOOR —
`askSavepointName` — and, where they assert a savepoint, file it with ⏎. Four deliberate updates;
nothing deleted to pass. Every other shipped cell on these roads rides byte-unmodified, because
the FILER kept its guard, its flush ordering and its refusal word for word.)*

**A MOUNTED PIN I WROTE, MEASURED VACUOUS AND DELETED** (its reason is in the test file, where the
next reader will look): a probe that mounts the real pane twice — a block with no savepoint and one
with one — and counts `KeyViewProxy` controls, to hold "a savepoint row draws TWO doors now". It
measured **1 control in both mounts**: in this headless host the pane's ScrollView rows never
realize and the model's observation lands after the mount without rebuilding the tree (the pane's
own batch-4 finding, met from the other side). A probe that cannot see what it claims is not
evidence, so the rename door's PRESENCE is walk evidence (`d-04`…`d-08`).

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

16 captures in `notes/plans/13u3-screens/` (gitignored), `d-01`…`d-16`.

| capture | what it shows |
|---|---|
| `d-01` · `d-02` · `d-03` | **the headline, in Takes:** ⌘S opens the focused field over the live take; *"before the AI edit"* typed; ⏎ files it and the bar's quiet slot reads **Committed "before the AI edit" — an immutable savepoint of this take.** |
| `d-04` | **Block History with names:** four savepoints on the take she is in — the named one leading its row in the accent, the others unchanged, and **Name / Rename · Restore** on every row including the **quiet** one |
| `d-05` · `d-06` | the rename door: the field opens SEEDED with the current name (selected), the hint says what ⏎ and ⎋ do; a new name typed and filed — the row reads *"the ending I kept"* and the pane says **Saved moment named "the ending I kept".** |
| `d-07` · `d-08` | **the quiet savepoint named** — *"the one before I left"* — and its row still says **quiet**, her ruling's letter on screen; its door has flipped from Name to Rename |
| `d-09` · `d-10` | Write's own door: ⌘S over the full-document editor opens the same field above the bar; ⎋ closes it with no receipt and no savepoint |
| `d-11` (Terminal dark) · `d-12` (Study dark) · `d-13` (Study light) | both voices, both appearances: the field in the voice's own face, the hint legible, the caret the palette's accent, the room fully black in dark (R51) |
| `d-14` · `d-15` | **Canvas**, which renders no commit door at all: ⌘S hangs the field at the strip's leading edge, the live card ringed behind it; filed — and the workbench then reads **2 savepoints** on that block where it read 1 |
| `d-16` | **Compare**, the same composition at its header's leading edge |

**WALK VERDICT: ⌘S means one thing on every Mac surface — it asks for a name and ⏎ files it — a
savepoint's name leads it wherever it is listed, and a name is editable afterwards from the door
her ruling put beside it.** Also driven and confirmed: ⌘S at the shelf (no take) opens nothing;
the field takes the keyboard on appear in all four surfaces and both voices; three successive
skip-road commits leak no newline into the take.

**The walk found TWO things the desk could not**, both fixed and re-walked (`5f40e5b3`): the
truncated placeholder and the four-line rename hint (traced above).

### FINALS (2026-09-19)

- core `swift test` — **Test run with 1591 tests in 173 suites passed after 52.078 seconds.**
- the FULL Mac suite — **Test run with 2859 tests in 480 suites failed after 755.816 seconds with
  2 issues.** Both issues are ONE test: `theReadClickLandsInIndexAtThatBlock`, the recorded
  environment red (KnownIssues row 58, owner 12) the brief names as the single tolerated one.
  **Run three times, and the arithmetic of the other two is recorded rather than hidden:** run 1
  carried this red plus `BookOutlineLandingTests`' collapsed-story arm (`abs(top) → 3424.0`) and
  the two my diff really broke (fixed at `a2c5ede0`); run 2 carried this red plus two TIMING pins
  (`initReturnsBeforeTheStoreIsOpen`, `ModeSwitchCarryTests`) because I ran the iOS build beside
  it — my own load, the trap the ENVIRONMENT section warns about; run 3 was run ALONE and is the
  final. The landing arm is KnownIssues row 49's recorded load-flake class, adjudicated by the
  paired protocol rather than by assertion: **8/8 green isolated, twice, and green in runs 2 and 3.**
- the TUTORIAL SPINE — green in-run (all 11 `Tutorial…` suites passed, including the lesson this
  unit edited).
- iOS build — **BUILD SUCCEEDED**.
- the FULL mobile suite — **Test run with 626 tests in 106 suites failed after 146.741 seconds
  with 9 issues (including 4 known issues).** The 4 known issues are the baseline's. The other 5
  are TWO tests, both in `MobileStarsTests`, both asserting a star cap of **5** against core's
  `Operations.starLimit = 15` — **measured PRE-EXISTING on a scratch worktree at this unit's start
  point (`858dcbd6`): byte-identical failures there.** Handed up below; not mine, and not fixed
  here.
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Server/`: ZERO.

*(Suite arithmetic, stated rather than rounded: the 2841/474 baseline + this unit's 18 new cells in
6 suites + the tutorial's 1 new cell comes to 2860/480 by hand, and all three runs counted
2859/480. The six new suites are each named PASSED in the log and the tutorial cell is named
PASSED; I did not chase the single-cell difference between the baseline's recorded arithmetic and
the runner's count.)*

### MOBILE PARITY (a note, not a build — the brief's fence)

**The phone's Block History listing gains savepoint names for free**, because the shared brain
`SavepointRowFace.meta` now leads with the name and `MobileBlockHistorySheetView` renders exactly
that line (`App/Variorum/VariorumMobile/Features/Takes/MobileBlockHistorySheetView.swift:418`). No
phone chrome was built and none is owed for READING a name. What the phone does NOT have is the
two DOORS: its commit button (`MobileBlockHistory`, ⌘S has no phone equivalent) files unnamed, and
it offers no rename. The RULE travels — a name is optional at the door and editable afterwards —
and the phone's answer to "where does the field live on a sheet" is the mobile catch-up's to
design, not this unit's to invent. **A parity row is the orchestrator's to file.**

### FOUND, NOT MINE (handed up rather than carried)

1. **The phone's `MobileStarsTests` have been red since the star cap went 5 → 15** (13u2b). Two
   tests hard-code the old cap; core says 15. Measured pre-existing on a worktree at this unit's
   start point. 13u2b's closeout recorded mobile as *"untouched — nothing mobile-visible shipped"*,
   which was true of its FACES and false of the shared constant its Mac work moved: the mobile
   suite was not re-run there. A one-line fix each, and the deeper lesson is the one UNIT B already
   wrote down — **a change to a shared core constant is a change to every platform that reads it.**
2. **Canvas reports no focused block to the router**, so the ⌘K "Block History" row opens the pane
   for whatever block the LAST surface reported (I watched it open a Write block while a canvas
   card was live). Shipped behaviour, older than this unit; it made confirming the canvas commit
   take three extra steps. The honest fix is for the canvas's live pane to report focus like the
   other surfaces do.
3. **A receipt spoken on Canvas or Compare is invisible under her `quiet` default** — the five
   doors #106 already names, met in the wild: the canvas commit landed (the workbench read 2
   savepoints where it read 1) and said nothing. Recorded, not changed: that is her ruling.

### ONE THING I GOT WRONG, STATED PLAINLY (the environment rule, breached)

**The author's own `/Applications/Variorum.app` session ended during my walk, and a keystroke of
mine is the likely cause.** I quit my dev instance between walk legs with `osascript … keystroke
"q" using command down`, which goes to whatever is FRONTMOST — and the standing rule is that her
instance is never quit. The evidence: her container's hourly backups run 03:19, 04:19 and then
stop; there is no crash report; and `pgrep` at my close found no Variorum running at all. **What
was NOT touched:** her store file's mtime is 2026-09-18 17:49 — before this session began — and
the 04:19 backup in her container is her own app's rhythm, not mine. The Mac test host is
`io.lduarte.Variorum.debug` and uses the DEV store, so the suite runs never reached her data.
**I did not relaunch her app**: launching her real-store copy is hers, not a session's. The fix so
nobody repeats it is in `Tools/WalkKit/README.md` as this walk's first walker fact — quit by
bundle identity (`tell application id "io.lduarte.Variorum.debug" to quit`) and re-check `pgrep`
after every quit.

### DEFERRED / NOT MINE (stated rather than done)

- **QUESTIONS #121** — the six calls this unit had to make inside her two rulings (⌘S opens a
  field · ⎋ cancels the whole commit · the seal refuses a rename while a locked take allows one ·
  a popover at the door, and where the two boards have no door · the name leads the row, which is
  the unit's one mobile-visible change · the rename door on quiet savepoints). All PROVISIONAL.
- **The phone's two doors** (above) — the mobile catch-up's.
- **Not touched, as the brief fences:** UNIT A1's gutter, UNIT A2's comments panel, UNIT B's card
  family, UNIT C's capture boxes, ⇧⌘V (`PlainPaste`), every other unit in this phase,
  `Sources/VariorumCore/Sync/`, `Persistence/`, `Server/`, the schema and the marker.

---

## UNIT D CLOSED — 2026-09-19

A saved moment can be named at the door that writes it and renamed at the door that lists it —
item 14 and R-13u3-1 built to their letter, with ONE field, ONE pure rule and ONE shared face
brain serving five doors across four Mac surfaces and (for reading) the phone. ⌘S stays two keys;
⎋ writes nothing; a quiet savepoint takes a name and stays quiet; and the snapshot's text is
unreachable from every road in the family (I5). 18 new cells in 6 suites with 2 copy cells red on
the shipped words, a 16-capture walk in both voices and both appearances that found two truncations
the desk could not, one real regression found by the suite and fixed, and one new PROVISIONAL
bundle (#121). Zero schema, zero migrations, zero `Sync/`, marker 8. Suites and finals above.

## ORCHESTRATOR ADJUDICATIONS AFTER UNIT D (2026-09-19)

1. **The breach (D's own report, verified by the orchestrator before anything else):** a walk-leg
   `osascript keystroke "q"` went to the FRONTMOST app and ended HER `/Applications` session.
   Verified: zero instances now; **her store untouched** (`variorum.sqlite` mtime 2026-09-18
   17:49, before this phase's first build; the test host is the dev store by construction);
   nothing relaunched — launching her real-store app stays HERS. The fix is systemic, not
   apologetic: quit-by-bundle-identity is now the FIRST walker fact in `Tools/WalkKit/README.md`,
   and every remaining unit brief inherits it by the standing read order. Reported to her
   directly and carried to the handoff's first section.
2. **The mobile star-cap reds (D's finals):** two `MobileStarsTests` cells asserted the literal
   cap 5 against `Operations.starLimit = 15` — red on every mobile run since the 13u2b star-cap
   commit `edb4ae94`, unnoticed because that phase's Mac-only diff did not owe a mobile run (its
   closeout's "nothing mobile-visible" was true of FACES and false of the shared constant; the
   correction is recorded here, not rewritten into history). **FIXED by the orchestrator,
   SYMBOLICALLY** (`cap = Operations.starLimit` throughout, plus one literal index the sweep's
   first pass missed — the "refuse again" arm's `ids[5]`, already starred under cap 15);
   `MobileStarsTests` 4/4 green on the simulator. The phone tutorial's "up to five" sentence
   still rides the mobile catch-up (#112(b), unchanged).
3. **D's suite arithmetic (2860 by hand vs 2859 counted):** the orchestrator diffed D's whole
   range for removed `@Test` lines — ZERO. No pin was dropped; the one-cell difference is hand
   arithmetic (a core-side cell counted Mac-side). Recorded, closed.
4. **Canvas's missing focused-block wire** → a KnownIssues row, owner **17e** (a door acting on
   the wrong target — the correctness-singles class). **The quiet-receipt cost on Canvas/Compare**
   → an evidence line appended to QUESTIONS **#106** (her open call; no change built).

---

## UNIT E BRIEF — THE #80(e) TWO FACES (item 15; self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 5 · GOVERNANCE + the
constitution (P-6: the tutorial is the executable spec — you are EDITING it deliberately, with
its pins, never breaking a step) · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the walker facts.
(2) The master plan's `### 13u` **item (15)** — her instruction verbatim ((a) the restore
confirm NAMES what it takes — the set-aside originals and their never-traveled takes — and may
point at PROMOTE as the zero-loss alternative; (b) the tutorial's versions-copy-placed-only
lesson: *"you're only saving the placed notes - not the history that rides with it"*; copies
never carry commits — one lesson covers both). (3) AppSpec §9's `saveNoteVersion` /
`restoreNoteVersion` / `promoteNoteVersion` (the restore's Delete Now road and the exact-stamp
revive — what the confirm must speak truthfully about) and KnownIssues row "A note's saved
VERSIONS ride a BLOCK-level anchor" (context only — NOT yours to fix). (4) The code: the
Versions face (Note ▸ Versions — the restore confirm's home) · `Features/Tutorial/TutorialSeeder.swift`
+ `TutorialWalkTests` (the lesson's home and its spine).

**Scope (ONE acceptance unit — the ratification's two faces; ops byte-untouched):**
1. **(a) The restore confirm names what it takes:** at confirm time, a bounded read counts the
   outgoing blocks' set-aside originals and never-traveled takes the Delete Now road will take;
   the confirm speaks them concretely (numbers, not categories, where cheap) and offers PROMOTE
   as the zero-loss road (promote mints the past as a first-class note; deletes nothing).
   Wording through the classed doors' grammar; a confirm is a refusal-class surface (always
   shows). If the counts' read cannot stay bounded (∝ the note, never the corpus), STOP and
   report the arithmetic.
2. **(b) The tutorial lesson:** the versions chapter gains the copies-are-placed-only lesson
   (versions AND copies: no history, no commits ride a copy — one lesson, both rules, her words
   honoured). Pins in the spine (`TutorialWalkTests`) hold the words to the acts (the R3-2
   lesson-pin precedent: pin the prose AND the act's shape). **The re-seed consequence is the
   CLOSEOUT's:** a lesson edit stales her REAL store's seeded field guide — record the delta in
   your UNIT E RECORD for the closeout's re-seed list; touch nothing real-store yourself.
3. **Fences:** zero ops changes · zero schema · zero `Sync/` · the Versions semantics untouched
   (the confirm DESCRIBES; it never changes what restore does).

**Pins:** the confirm's counts against a staged note (versions with stranded ancestors — the
#80(e) shape); the lesson pins; existing Versions pins ride unmodified. Red-on-old only where
defect-shaped (a missing sentence is a missing face, not a bug — no manufactured reds; but if
the confirm today says something FALSE, that cell is defect-shaped and gets the revert).

**End verification:** FULL Mac suite (row 58 tolerated) · tutorial spine green WITH the new
lesson's pins · iOS build green · YOUR walk with captures: stage a note with versions whose
restore strands ancestors, read the confirm in the flow, take PROMOTE once and RESTORE once;
walk the new lesson in the tutorial; both voices, both appearances. Record: **UNIT E RECORD**,
LIVE STATUS from the first commit, UNIT CLOSED banner, ledger row 6 flipped in the same commit.


---

## UNIT E RECORD — THE #80(e) TWO FACES (opus-implementer, 2026-09-19)

**WHAT THIS UNIT DOES NOT DO (the record's first line):** it does not change what RESTORE,
PROMOTE or SAVE A VERSION *do* — every operation in `Operations+NoteVersions.swift` is byte
untouched, the Delete Now road still takes exactly what her #80(e) ratification said to keep
taking, and no undo/redo entry changes. ZERO schema, ZERO migrations, ZERO
`Sources/VariorumCore/Sync/` lines (`PurgeFamily` is READ ABOUT and pinned against, never
edited), the marker stays **8**. It does not touch UNIT A1's gutter, UNIT A2's comments panel,
UNIT B's card family, UNIT C's capture boxes or UNIT D's savepoint names. It builds NO phone
face (the phone still has no Versions surface — a parity note below). It does not fix the
KnownIssues row *"A note's saved VERSIONS ride a BLOCK-level anchor"* (owner 13w, context only).

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | the record + LIVE STATUS | **DONE** |
| 1 | THE PROBE — does the restore actually strand an ancestor? (traced, measured, recorded) | **DONE** — it does NOT, and the mechanism is step 1's own copy (below) |
| 2 | core — the bounded read + its pins (incl. the anti-drift pin against `PurgeFamily`) | **DONE** (5 cells green; the versions/purge/tray neighbours 76/76 green beside them) |
| 3 | the confirm — the copy + the ask road + pins (red-on-old where the shipped words are false) | **DONE** (3 cells; the red-on-old measured on the shipped words first — the log line is in the record; the suite 15/15 green after) |
| 4 | the tutorial lesson (b) + its spine pins | **DONE** (the chapter's 4th lesson + 5 pin blocks in 2 suites; the whole spine + the pane's suite 106/106 green in 15 suites) |
| 5 | QUESTIONS #122 + the next-free marker moved | **DONE** — six lettered calls, led by the measured correction to #80(e)'s premise; the marker moved to #123 |
| 6 | the walk + captures, the FULL Mac suite, tutorial spine, iOS build, the mobile suite | **DONE** — 14 captures in both voices and both appearances; finals below |

*(Nothing below this line is claimed until its row says DONE.)*

**BASELINES AT OPEN** (UNIT D's recorded finals; never re-run at a start): core **1591 / 173**
green · the FULL Mac suite **2859 / 480** with ONLY row 58's recorded environment red
(`theReadClickLandsInIndexAtThatBlock`) · tutorial spine green · iOS build green · the FULL
mobile suite **626 / 106 with 4 known issues** (`MobileStarsTests`' two star-cap reds were fixed
by the orchestrator after D) · marker **8**.

### THE PROBE THAT CAME FIRST (and what it found — read this before the rest)

**The brief sent me to build a confirm that names "the set-aside originals and their
never-traveled takes" a restore takes. I measured the restore first, and it takes NEITHER.**

The probe drove the real operation on three staged shapes (a divide-W's preserved original with
an unshown take; the same with every moment deleted; a merge's two released sources), then ran
the janitor's own physical removal over the standing purge intents (`PurgeFamily.expand` +
`deleteLocal`, the technique `NoteVersionsTests` already uses) and asked the store what survived:

- **the preserved original SURVIVED every time**, kept its takes, and still listed in the note's
  tray afterwards (`Queries.preservedOriginals` returned it);
- **`PurgeFamily`'s own `strandedOriginals` was EMPTY** for the restore's family, so the purge
  agrees with the survival rather than merely postponing it.

**The mechanism, traced rather than guessed:** `restoreNoteVersion` step 1 saves the version of
NOW, which copies EVERY outgoing block, and `copyPlacements` mints a `derived_from` edge from
each copy back to the block it copied. So the moment the restore's transaction commits, every
outgoing block has a LIVE descendant OUTSIDE the purge family — which is exactly the condition
`joinStrandedOriginals` (her round-8b rule) requires to be ABSENT before an ancestor may join.
The probe printed it directly: each outgoing block had exactly ONE descendant, and that
descendant's container was the version of NOW. **#80(e)'s premise cannot hold while step 1
exists**, and step 1 is the thing that makes restore repeatable — it is not going anywhere.

**So what DOES the Delete Now road take that no version holds?** The probe answered that too, on
a note worked in since its moment: **3 savepoints on its takes → gone; 1 deleted take waiting in
its Block History → gone; 1 deleted comment → gone.** The version of NOW carried the words of
both live takes and **two savepoints that are not hers** — one insurance auto-commit per copied
take, the seal's own occasion at the version's mint. A copy carries words, never the past.

**What I did with that** (all PROVISIONAL, all in QUESTIONS #122): the confirm names what the
road MEASURABLY takes, in numbers; it still computes and words the set-aside originals, because
her ruling names that population and the zero is ONE line of the copy loop away from being a
number again; and both facts are pinned at both ends in core, so a future change to either says
so out loud instead of quietly making the confirm wrong.

### THE RED-ON-OLD VERIFICATION (the one defect-shaped cell, measured before the fix)

**A missing sentence is a missing face — but a FALSE one is a defect, and there was one.** The
shipped confirm read *"Where the note is right now is saved as a new version first, so this is
never a one-way door."* True of the note's WORDS; false of the savepoints, the deleted takes and
the deleted comments the same act destroys with no road back.

`NoteVersionsPaneTests.theRestoreConfirmNeverPromisesMoreThanTheRestoreKeeps` was written
FIRST and run against the shipped copy:

```
✘ Test theRestoreConfirmNeverPromisesMoreThanTheRestoreKeeps() recorded an issue at
  NoteVersionsPaneTests.swift:246:9: Expectation failed:
  !((detail.lowercased() → "where the note is right now is saved as a new version first, so this
  is never a one-way door. …").contains("one-way door") → true)
✘ … :251:9: Expectation failed: (detail → "…").contains("none of its words are lost")
✘ Test run with 13 tests in 1 suite failed after 1.402 seconds with 2 issues.
```

RED on the pre-fix tree (the suite's other 12 cells green), GREEN after — and the pane's standing
EXPLAINER, which made the same promise two inches above the button, is corrected in the same pin.
No other cell here is a manufactured red: the counts and the lesson are new faces, and they are
pinned as behaviour, not as bugs.

### WHAT THE CONFIRM SAYS NOW (the contract, in her grain)

- **Nothing to name ⇒ not one word changes.** A note nobody has worked in since its moment gets
  the sentence it has always had (walked: capture `E07`).
- **Something to name ⇒ one more short paragraph**, in numbers rather than categories:
  *"A version holds the words, not the history. Going with these paragraphs, and held by no
  version: 2 saved moments and 1 deleted comment. Nothing puts them back. Promote instead keeps
  everything — it makes this moment a note of its own and deletes nothing."*
- **The counts are read at ASK time** (`VersionActs.restoreCost` → `Queries.restoreCost`), the
  `versionCount` precedent: a confirm is a pause, and the pause is about the note as it IS.
- **The read is the NOTE's, never the corpus's (P1):** every statement is scoped to this note's
  own live placements and their lineage — pinned by a cell that adds 24 savepoints and 8 deleted
  takes to OTHER notes and asserts the answer does not move by one.
- **Promote is pointed at in WORDS, not offered as a second button** (#122(c)): her #80(c)
  ratification kept Promote fast on the reasoning that *"one mis-click beside Restore"* is the
  risk it carries, and a promote trigger inside the destructive confirm is that mis-click.

### THE LESSON (item 15(b) — her instruction, both halves in one lesson)

**"what a copy carries" joins `where things go` as its fourth lesson**, between the two saves and
the two exits. Her words: *"you're only saving the placed notes - not the history that rides with
it"* — so the lesson teaches the WORDS/PAST rule over every copying gesture (⌘⇧S, duplicate, a
drag out of Snippets), says where the past she is NOT copying actually lives (the block's
History, the came-from region, the tray), and ends at the confirm: Restore asks because the past
of the paragraphs it replaces goes with them, and Promote is the road that takes nothing.

Two neighbouring sentences were corrected in the same pass: *"every block, every take"* (a
version copies the PLACED blocks) and the same one-way-door promise the confirm made.

**Pinned as prose AND as acts** (the R3-2 precedent): the chapter's contract cell now asserts the
new lesson's six claims against the app's OWN words (`BlockHistoryPath.name`, `.doorLabel`,
`.cameFromSection`, `TrayPath.menuLabel`, both chords, `Promote`), and two new act cells DRIVE
it — the PRACTICE COPY act (⌘S then ⌘⇧S: the version holds every word and not one manual
savepoint, while the moment stays on the take she pressed it on) and a merge whose two set-aside
sources stay with the NOTE while the version holds only the page.

### THE PINS (8 new cells; 5 core + 3 Mac, plus 2 tutorial act cells inside the Mac count)

| pin | suite | what it holds |
|---|---|---|
| `theCostNamesTheHistoryTheRoadTakesAndTheVersionDoesNotHold` | `RestoreCostTests` (core) | 3 savepoints + 1 deleted take + 1 deleted comment counted, then destroyed by the real op + a physical sweep; the version keeps both takes' words and TWO insurance savepoints, never her three |
| `anUntouchedNoteTakesNothingAVersionDoesNotAlreadyHold` | ″ | the empty cost, so the confirm stays the sentence it was |
| `theCostIsScopedToItsNoteAndNeverToTheCorpus` | ″ | P1: 24 savepoints and 8 deleted takes elsewhere move nothing |
| `theSetAsideReadAgreesWithThePurgeFamilyItMirrors` | ″ | **the anti-drift pin**: the mirrored predicate == `PurgeFamily.expand(...).strandedOriginals` on the fixpoint shape (an original behind an original) |
| `aRestoreStrandsNoAncestorBecauseTheVersionOfNowIsTheirSurvivingDescendant` | ″ | the probe's finding, pinned at BOTH ends — the ancestor survives a full sweep AND each outgoing block's one descendant lives in the version of NOW |
| `theRestoreConfirmNeverPromisesMoreThanTheRestoreKeeps` | `NoteVersionsPaneTests` | **RED on the shipped words** (above); the promise, narrowed, in the confirm and the explainer |
| `theRestoreConfirmCountsWhatTheRoadTakesAndOffersPromote` | ″ | the ask through the real model: empty cost ⇒ byte-identical sentence; 2 moments + 1 deleted take ⇒ numbers, "Nothing puts them back", and Promote by its own verb |
| `theCostSentenceSaysExactlyWhatIsThereAndNothingElse` | ″ | the sentence's grammar: singular/plural, the three-item list, the set-aside phrasing for the day it is real |
| `everyPlaceTheChapterNamesIsAPlaceTheAppHas` (extended) | `TutorialWherePlacesActsTests` | the 4-lesson plan + the new lesson's six claims in the app's own words + the corrected neighbour |
| `theMapsChapterIsStagedForItsActs` (extended) | ″ | PRACTICE COPY staged, with paragraphs either side for the merge act |
| `theCopyLessonsPracticeKeepsTheWordsAndLeavesTheMoment` | ″ | the lesson's own act: every word travels, not one manual savepoint does, and the moment is still on the take |
| `aVersionHoldsThePlacedParagraphsAndNotTheSetAsideOnes` | ″ | her sentence's other half: a merge's sources stay with the note; nothing in the moment came from them |

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

A note typed in the shelf's quick-entry box (three paragraphs, ⇧⏎), a version saved, then WORKED
IN: two named ⌘S savepoints, a second take, a comment added and deleted. Captures in
`notes/plans/13u3-screens/` (gitignored):

| capture | what it shows |
|---|---|
| `E01-versions-pane-corrected-explainer-terminal-light.png` | the pane, its explainer now ending *"so none of its words are lost"* |
| `E02-restore-confirm-names-what-it-takes-terminal-light.png` · `E03-restore-confirm-closeup.png` | **the headline:** the confirm naming *"2 saved moments and 1 deleted comment"* and pointing at Promote |
| `E04-promote-the-zero-loss-road-taken.png` | PROMOTE taken: *"This moment is a note of its own now, in the Library. It has left Versions."* — and the listing empty |
| `E05-restore-taken-receipt-and-two-moments.png` | RESTORE taken: the note says the past again, and where it was a moment ago is in Versions |
| `E06-after-the-restore-the-history-really-went.png` | **the confirm told the truth:** Block History after the restore reads *take 1 of 2 · 0* and *take 2 of 2 · 0* — *"no saved moments yet"* |
| `E07-plain-confirm-when-nothing-is-owed.png` | the same door on a note with nothing to lose: the sentence it has always been, not one word added |
| `E08-confirm-terminal-dark.png` · `E09-confirm-study-dark-pane-and-dialog.png` · `E10-confirm-study-light-pane-and-dialog.png` | the confirm in the other three voice/appearance cells (the counts read live: *4 saved moments* by then) |
| `E11-the-new-lesson-in-its-chapter-study-light.png` | the re-seeded field guide — **34 notes, 9 chapters** — with *what a copy carries* third in `where things go` |
| `E12-…-study-light.png` · `E13-…-terminal-light.png` · `E14-…-terminal-dark.png` | the lesson READ, all six paragraphs, in both voices and both appearances |

**WALK VERDICT: both faces do in the app exactly what the pins say, and the walk proved the
confirm's honesty rather than assuming it** — the sentence promised the history would go, and
Block History afterwards showed it gone. Promote and Restore were each taken once for real.
Nothing about the Versions semantics changed: save · read · restore · promote · delete all
behaved exactly as before, with only the words different.

**What the walk cost, and the fact it produced:** `Help ▸ Restore Tutorial…` puts up an APP-MODAL
AppKit alert that `walk-cap` cannot see and that swallows every click and keystroke — the app
looked normal in captures and simply stopped responding, and a `tell application id … to quit`
was REFUSED (-128) while it was up, which briefly left two dev instances on the dev store (the
extra was killed by PID, never by a keystroke; her `/Applications` copy was never running at any
point in this session — `pgrep` verified before, during and after). All four facts are now the
first entries of `Tools/WalkKit/README.md`'s UNIT E section.

### FINALS (2026-09-19)

- core `swift test` — **Test run with 1596 tests in 174 suites passed after 51.521 seconds.**
  (1591 + this unit's 5 core cells.)
- the FULL Mac suite — **Test run with 2864 tests in 480 suites failed after 763.572 seconds with
  3 issues.** (2859 + this unit's 5 Mac cells.) **TWO of the three are ONE test** —
  `theReadClickLandsInIndexAtThatBlock`, the recorded environment red (KnownIssues row 58, owner
  12) the brief names as the single tolerated one. **The third is
  `BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded`
  (`abs(top) → 3424.0`), adjudicated by the paired protocol rather than by assertion:** 1 red / 2
  green over three ISOLATED runs, and its fixture is `withLandingBook(posts: 18, …)` — synthetic,
  not the tutorial — so nothing in this diff can reach it. That is KnownIssues row 49's recorded
  load-flake class, the same arm UNIT D's run 1 carried.
- the TUTORIAL SPINE — green: one run over all 11 `Tutorial…` suites plus the Encryption/NewModes
  seeder consumers and the Versions pane, **106 tests in 15 suites passed**, including the new
  lesson's four pins.
- iOS build — **BUILD SUCCEEDED** (owed: `Shared/VersionsCopy.swift` and `Shared/VersionActs.swift`
  compile into the phone too).
- the FULL mobile suite — **Test run with 626 tests in 106 suites passed after 143.610 seconds
  with 4 known issues.** The 4 are the baseline's; the two star-cap reds the orchestrator fixed
  after UNIT D are green.
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Server/`: ZERO. Eleven files changed in all, 1064 insertions.

### THE RE-SEED CONSEQUENCE (the closeout's, recorded here as the brief asks)

**A lesson edit stales her REAL store's seeded field guide.** The tutorial book in her library is
the copy seeded when she last pressed it; it has 33 notes and the old `saving a moment` wording.
`Help ▸ Restore Tutorial…` in the refreshed build replaces the tutorial book with the current
lessons — 34 notes, `what a copy carries` third in `where things go`, and the two corrected
sentences. **I touched nothing real-store; this is the closeout's re-seed list item**, and it
joins the one still owed from #80(f) (the 13p privacy chapter's own re-seed). The dev store was
re-seeded by my walk, deliberately and only there.

### MOBILE PARITY (a note, not a build — the brief's fence)

The phone has **no Versions face at all**, so nothing of (a) is visible there yet — but both
halves of the decision layer it will need are already shared and now correct:
`VersionsPath.restoreConfirmDetail(_:)` / `restoreCostLine` (`App/Variorum/Shared/VersionsCopy.swift`)
and `VersionActs.restoreCost` (`App/Variorum/Shared/VersionActs.swift`), over a core read every
platform can call. When the phone builds its Versions surface it inherits the honest confirm for
free and must not re-word it. The phone's POCKET GUIDE is a different book (`ProtectionCopy`'s
lessons are shared; the field guide is the Mac's), so item 15(b) owes the phone nothing here —
whether the phone's guide should carry the copies-are-placed-only rule is the mobile catch-up's
call. **A parity row is the orchestrator's to file.**

### FOUND, NOT MINE (handed up rather than carried)

1. **#80(e)'s premise is false, and the ratification that rests on it should be re-read** — not
   because the ruling was wrong (she chose "keep as built", which is exactly what shipped) but
   because the thing she accepted losing is not what the act loses. QUESTIONS #122(a) puts the
   measurement in front of her; the confirm now names the real cost either way.
2. **The Versions pane has no take-level delete door I could find from the board** — the walk
   wanted a deleted take and neither the take card, its header, nor the block ▾ menu in Takes
   offers one (the ⋯ the tutorial's takes chapter names is not on those cards). Either the door
   moved and the lesson's wording is stale, or it is missing; not this unit's to decide, and the
   deleted-take COUNT is pinned in core regardless.
3. **`Help ▸ Restore Tutorial…`'s modal is an AppKit alert while every other confirm in the app is
   a SwiftUI `.alert`** — invisible to the walk harness and unreachable by coordinates. Worth one
   line of consistency work in a faces batch; recorded in WalkKit either way.

### DEFERRED / NOT MINE (stated rather than done)

- **QUESTIONS #122** — six PROVISIONAL calls (the falsified premise and what the confirm names
  instead · the narrowed promise · Promote in words rather than a button · the sentence only when
  there is something to say · deleted comments counted beside deleted takes · a new lesson rather
  than paragraphs, with its re-seed).
- **The KnownIssues row "A note's saved VERSIONS ride a BLOCK-level anchor"** (owner 13w) — read
  as context, untouched, as the brief fences.
- **Not touched:** UNIT A1's gutter, UNIT A2's comments panel, UNIT B's card family, UNIT C's
  capture boxes, UNIT D's savepoint names, every other unit in this phase,
  `Sources/VariorumCore/Sync/`, `Persistence/`, `Server/`, the schema, the marker, and every
  operation in `Operations+NoteVersions.swift` — byte-identical.

---

## UNIT E CLOSED — 2026-09-19

Item 15's two faces are built, and the unit's first finding is that the ratified analysis behind
face (a) described a loss the operation does not cause: **a restore strands no ancestor**, because
step 1's own copy is every outgoing block's surviving descendant — measured through the real op
and the janitor's physical sweep, and pinned at both ends. What the Delete Now road DOES take is
the history of the paragraphs it replaces — the savepoints, the deleted takes, the deleted
comments — and the confirm now counts those and names them in numbers, points at PROMOTE as the
zero-loss road, and keeps the set-aside wording ready for the day that count is real. The promise
it used to make (*"never a one-way door"*) was false and is now exactly true (*"none of its words
are lost"*), red-on-old. The field guide gains **what a copy carries**, teaching both halves of
her rule and ending at that confirm. 8 new cells in 3 suites (one red on the shipped words), 14
walk captures in both voices and both appearances, one re-seed note for the closeout, one new
PROVISIONAL bundle (#122). Ops byte-untouched; zero schema, zero migrations, zero `Sync/`; marker
8. Suites and finals above.

## ORCHESTRATOR ADJUDICATIONS AFTER UNIT E (2026-09-19)

1. **#80(e)'s falsified premise:** E's probe measured that `restoreNoteVersion` strands NO
   ancestors (every outgoing block gains a live descendant in the version of NOW via
   `copyPlacements`' edges, so `joinStrandedOriginals` never fires) — the confirm now names the
   REAL cost (savepoints · waiting deleted takes · deleted comments). Nothing to fix; QUESTIONS
   **#122(a)** puts the re-read in front of her, and the handoff bundles it prominently. The
   anti-drift equality pin against `PurgeFamily` keeps the confirm honest if the op ever changes.
2. **The take-delete door, traced by the orchestrator after E's hand-up:** the door EXISTS on
   Write's fan panel (`WriteTakesPanel`, both live and archived cards) and on the BOARD's
   archived cards — a LIVE take card on the Takes board has none, while the tutorial's takes
   lesson teaches *"⋯ menu ▸ Delete"* there (`TutorialSeeder` ~:1056/:1080). The ⋯ card menu
   retired at a restyle; the spine stayed green because its pins invoke the act, not the door
   (the R3-2 gap's twin). **A P-6 copy-truth defect found in-phase → UNIT H joins the ledger**
   (the board's live-card delete door + the lesson's truth + a pin that holds the words to a
   door that exists). Product risk low: the door's semantics are settled (I10's last-take
   refusal; Write's panel is the precedent).
3. **The AppKit-modal Restore Tutorial confirm** → a KnownIssues row, owner 13u4 (the one
   inconsistent confirm chrome; also walker-hostile — the WalkKit fact E filed).
4. **Mobile parity for the closeout list:** the shared `VersionsCopy`/`VersionActs` halves are
   correct for the phone (no Versions face exists there); the pocket-guide question is the
   catch-up's.

---

## UNIT F BRIEF — THE PDF EXPORT RENDERS FORMATTING (item 16; self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 6 · GOVERNANCE + the
constitution · ENVIRONMENT TRAPS · CAST & DISCIPLINE. (2) The master plan's `### 13u` **item
(16)** — her words (*"the export as pdf is not rendering the markdown formatting you just see
the markdown in the text and that should be fixed at some point pre v1 release"*; the road:
reuse the Mac's own markdown display brain; a projection change ONLY; the TYPOGRAPHIC pass
stays 13m's). (3) AppSpec §9's export notes (a callout maps to a blockquote form — a
presentation transform only; `renderedText` and the join brain never map) and the 11b export
shape (posts/readings/blocks; `joinRenderedTexts`; the attributed-string/CTFramesetter PDF
path). (4) The code: the export family (`Features/` export or `Shared/` — find the 11b PDF
path) · the Mac's markdown DISPLAY brain (13g's markdown-as-content rendering — find where
Write/read tiers style syntax and reuse THAT, never a second parser).

**Scope (ONE acceptance unit — the PDF projection):**
1. The PDF path's attributed strings are built through the SAME markdown display brain the app
   renders with (bold, italic, headings, lists, the code chip's monospace, links as styled
   text) — no second parser, no new formatting rules. Whatever the display brain does not
   style, the PDF does not style (one truth).
2. **Byte-fences, PINNED:** `renderedText` untouched · the `.md` export byte-identical
   before/after on a fixture corpus (a pin that exports both ways and compares) · the callout→
   blockquote mapping preserved as-is.
3. **Not yours:** fonts/layout/print polish (13m's typographic pass); EPUB/annotation anything
   (permanently out); the export's granularity or file shapes.
4. **Fences:** zero schema · zero `Sync/` · zero ops · marker 8.

**Pins:** the .md byte-identity pin; attributed-run assertions on a fixture (a heading run
carries the heading font attribute; raw `**` absent from the rendered string); the fan
"Alternates" sections still export (the ratified shape untouched). Red-on-old IS owed here —
the defect is real (raw syntax in shipped PDFs): a pin asserting no literal markdown syntax
leaks into the PDF's attributed string fails on the pre-fix code.

**End verification:** FULL Mac suite (row 58 tolerated) · tutorial spine green · iOS build
green · YOUR walk: export a formatted note AND a book to PDF from the app, open both captures
(screenshot the PDFs), verify headings/bold/lists render and no raw syntax shows; export the
same note as `.md` and diff against a pre-unit export (byte-identical). Record: **UNIT F
RECORD**, LIVE STATUS from the first commit, UNIT CLOSED banner, ledger row 7 flipped in the
same commit.


---

## UNIT F RECORD — THE PDF EXPORT RENDERS FORMATTING (opus-implementer, 2026-09-19)

**WHAT THIS UNIT DOES NOT DO (the record's first line):** it does not change one byte of what the
`.md` export writes — `Queries.renderedText`, `exportPost`, `exportReading`, `exportBlock`, the
bulk manifest, the callout→blockquote mapping and the fan's "Alternates" shape are all byte
untouched, PINNED against goldens, and PROVED byte-identical by exporting the same note from the
PRE-UNIT BUILD and this one and diffing the files (same SHA-256, below). It does not re-font or
re-space the PDF (the typographic pass is 13m's — the page is the same 12 pt system body it has
been since 11b, with the face on top). It does not touch `Sources/` at all — ZERO core lines,
ZERO schema, ZERO migrations, ZERO `Sync/`, ZERO `Persistence/`, ZERO `Server/`, the marker stays
**8**. It changes NO behaviour of the paged reader (the hoist is byte-identical and its three
suites say so). It builds no phone face and ships nothing mobile-visible. It does not teach the
markdown vocabulary anything new — a blockquote is still not in it, which is why a callout's
`> ` leads still print (QUESTIONS #123(b)).

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | the record + LIVE STATUS | **DONE** |
| 1 | THE TRACE — the shipped PDF path, mechanism named, and the RED-ON-OLD measured on it | **DONE** — 6 of 8 cells RED with 31 issues on the shipped rendering; the log lines are in the record |
| 2 | the ONE reading face: `PageComposer`'s attributed applications hoisted to a shared brain, its duplicate heading/trait rules collapsed onto `MarkdownFace` | **DONE** — `Theme/MarkdownReadingFace.swift`; the paged reader's own 3 suites 16/16 green beside it |
| 3 | the PDF path built through that brain + its pins (no raw syntax; heading/bold/list/code runs) | **DONE** — 10/10 green in the new suite |
| 4 | the BYTE-FENCES pinned (`.md` export byte-identity on a fixture corpus · `renderedText` untouched · the Alternates section · the callout→blockquote mapping) | **DONE** — the two fence cells were GREEN on both sides, which is what a fence is |
| 5 | QUESTIONS — the PROVISIONAL calls + the next-free marker moved | **DONE** — **#123**, five lettered calls (the reading face · the callout's surviving `> ` · paper's values · nothing re-fonted · the title is not markdown); the marker moved to **#124** |
| 6 | the walk + captures (both PDFs opened and screenshotted; the `.md` diff), the FULL Mac suite, tutorial spine, iOS build | **DONE** — 9 captures incl. the BEFORE/AFTER pairs for both the note and the book, the `.md` proved byte-identical across two builds, and ONE REAL REGRESSION the suite found in my own diff and I fixed (below); finals at the end |

*(Nothing below this line is claimed until its row says DONE.)*

**BASELINES AT OPEN** (UNIT E's recorded finals; never re-run at a start): core **1596 / 174**
green · the FULL Mac suite **2864 / 480** with row 58's recorded environment red
(`theReadClickLandsInIndexAtThatBlock`) the single tolerated one and the row-49 landing arm a
recorded load flake (adjudicate by the paired protocol, never one run) · tutorial spine green ·
iOS build green · the FULL mobile suite **626 / 106 with 4 known issues** · marker **8**.

### THE TRACE (the mechanism, named before anything was written)

`ExportModel.pdfData(forPost:)` reads `Queries.exportPost` — which returns the note's
**markdown-as-content**, because since 13g the stored text IS the markdown (her F-1). It handed
that string to `PDFExporter.attributedDocument`, which appended it **verbatim** under one
`NSFont.systemFont(ofSize: 12)`, and `CTFramesetterCreateWithAttributedString` drew the
characters it was given. So every `#`, `**`, `~~`, backtick, `- ` and `](url)` she had typed
landed on the page. The 11b path is a phase OLDER than the markdown vocabulary: it was written
when the stored text was prose, and nothing has re-read it since.

**The road, and the one road it is not.** The app already has two faces for that vocabulary, and
which one a surface wears is her own F-5 rule: an EDITING surface keeps the markers on the glass
(`MarkdownStyling` → `Shared/MarkdownFace` — display == stored byte for byte, because a click has
to land on the right character); a READ-ONLY surface with no gesture mapping a click to an offset
may hide them (`MarkdownRendering`, core, pure — display text + semantic runs + line styles, and
deliberately no fonts). A PDF is the purest read-only surface in the app: it has no gestures at
all. So the page takes the READING face, and the pin `theExportedDocumentShowsNoRawMarkdownSyntax`
is exactly that decision made falsifiable.

The attributed half of that transform — runs → fonts, line styles → paragraph facts — already
existed, and this is the part that made the bug possible: **it lived PRIVATELY inside
`PageComposer`** (`Features/BookView/PagePaginator.swift`, two `private static func`s), so the
paged reader could reach it and the export could not.

### THE RED-ON-OLD VERIFICATION (measured on the shipped rendering, before the fix)

The suite was written first and run against the shipped exporter (the only edit on that tree was
naming its two font literals `bodyFont`/`titleFont` — no behaviour):

```
✘ Test theExportedDocumentShowsNoRawMarkdownSyntax() … Expectation failed:
  !((text → "My Note\n\n# Chapter One\n\nA paragraph with **bold words**, *italic ones*, …
  ~~a struck phrase~~ and `let code = 1` inline.\n\n## A smaller heading\n\n- first item…")
  .contains(syntax → "**") → true)   ↳ raw markdown leaked into the PDF: **
✘ Test theExportedRunsCarryTheAppsOwnFace() … (heading.pointSize → 12.0) > (body.pointSize → 12.0)
✘ Test listLinesIndentAndNestExactlyAsTheReadingPageDoes() … [.paragraphStyle] → nil
✘ Test theRenderedPDFItselfCarriesTheWordsAndNoneOfTheSyntax() … (text).contains("**") → true
✘ Test thePDFDoorExportsTheSameProjectionTheMarkdownDoorWrites() … (text).contains("**") → true
✘ Test run with 8 tests in 1 suite failed after 0.065 seconds with 31 issues.
```

**6 of 8 cells RED, 31 issues.** The two that were GREEN on both sides are the BYTE-FENCES
(`everyMarkdownProjectionIsByteIdentical`, `theAlternatesSectionReachesThePageUnchanged`) — which
is what a fence is: it must not move, and a fence that went red would mean the unit had broken
its own promise. Nothing here is a manufactured red.

### WHAT WAS BUILT (one hoist, zero new rules)

**`App/Variorum/Variorum/Theme/MarkdownReadingFace.swift`** — the reading face's attributed half,
lifted out of `PageComposer` **byte-identically** and given a `Style` (body font · line spacing ·
ink · link · code tint) so each medium supplies its own VALUES while the RULES exist once. It
lives beside `Theme/MarkdownStyling.swift`, the editing face's Mac host, which is where a reader
looking for "how does markdown look here" will find both.

Two duplicate rules collapsed in the move, both verified identical line by line first:

- a heading's SIZE — `PageComposer` had written out the same 1.6/1.35/1.15 scales, the same bold
  union and the same fallback chain that `MarkdownFace.headingFont(level:base:)` already held.
  It now CALLS it, and `theReadingFacesHeadingIsTheEditingFacesHeading` pins the two equal at
  every level and both base fonts.
- a bold/italic TRAIT union — now `MarkdownFace.adding(_:to:)`, the same function the editing
  face calls. The cheap "did the traits actually change" guard is kept.

**`PDFExporter`** consumes the face through one new door, `MarkdownReadingFace.attributed(_:style:)`.
The title line is deliberately NOT read as markdown (it is a stored name, shown the way the
masthead shows it — a book's own `# <name>` travels inside the body and renders as a heading
there; QUESTIONS #123(e)).

### THE REGRESSION MY OWN DIFF INTRODUCED — FOUND BY THE SUITE, FIXED, AND THE FIX IS BETTER

The first full Mac run came back with a red that was **mine**:

```
✘ Test noViewPaintsALiteralColour() recorded an issue at NoLiteralColourTests.swift:176:9:
  Expectation failed: (offenders → ["Features/Export/PDFExporter.swift:73 — Color.black"]).isEmpty
```

18j's grep pin refused `NSColor.black`, and it was **right to**. My reasoning for the literal was
sound — a dynamic ink would resolve against whatever appearance the app wore when she hit Save,
and a PDF exported in dark mode would arrive white on white paper — but the pin's own header says
the thing I had missed: *"a literal colour … is the same value on black paper as on white."*

I did not add an allow-list entry. **The honest answer is no colour at all:** `Style.ink` and
`Style.link` became optional, the PDF passes `nil` for both, and the exported document now carries
**no `.foregroundColor`, `.backgroundColor`, `.underlineColor` or `.strikethroughColor` anywhere**.
That is byte-for-byte what 11b drew (a `CGContext`'s own fill is black — which is exactly why the
old PDF was readable), and it is a STRONGER guarantee than a literal: a page with no colour cannot
resolve one against an appearance, ever. The underline and the strikethrough RULE are still
written — only their colour was optional. `theExportedDocumentIsPaperAndNotAScreen` became an
absence-walk over the whole document, and QUESTIONS #123(c) was rewritten to say what shipped.

**The page's own values are untouched by this**: `PageComposer` still passes the voice's ink, the
system link colour and its code tint, so the reader is byte-identical.

### THE PINS (10 new cells, one new suite — `PDFExportFaceTests`)

| pin | what it holds |
|---|---|
| `theExportedDocumentShowsNoRawMarkdownSyntax` | **RED on the shipped exporter** (above): every word survives; `**` `~~` `` ` `` `](` `# ` `## ` `- ` `[ ]` `[x]` `_underscored` and the URL are all gone; the substituted leads are the ONE transform's own (`•`, ☐, ☑) |
| `theExportedRunsCarryTheAppsOwnFace` | headings are SIZES and bold, `#` bigger than `##`; bold/italic/`_italic_` carry traits; code is monospaced; a struck phrase is struck; a link is underlined; **ordinary prose is exactly the body font** |
| `listLinesIndentAndNestExactlyAsTheReadingPageDoes` | a list line is a HANGING indent, a nested item sits one step further in, and prose gets no paragraph style at all |
| `theExportedDocumentIsPaperAndNotAScreen` | **the absence-walk**: no colour attribute of any kind in the whole document; the underline and strikethrough rules still written |
| `theRenderedPDFItselfCarriesTheWordsAndNoneOfTheSyntax` | real `%PDF` bytes whose EXTRACTED text has the words and none of the syntax |
| `theAlternatesSectionReachesThePageUnchanged` | the ratified fan section is prose and reaches the page verbatim |
| `theReadingFacesHeadingIsTheEditingFacesHeading` | **anti-drift**: the reading face's heading == `MarkdownFace.headingFont` at every level, both base fonts |
| `thePageAndThePDFMakeTheSameFaceDecisions` | **the hoist's own guard**: same display string, and the same trait/size/indent RELATIONS on both media |
| `everyMarkdownProjectionIsByteIdentical` | **the `.md` FENCE**: `renderedText`, `exportPost`, `exportPost(includeVariants:)` pinned to goldens over a fixture with markdown, a callout (its `> ` mapping) and a fan |
| `thePDFDoorExportsTheSameProjectionTheMarkdownDoorWrites` | the PDF door hands the exporter EXACTLY the `.md` string — the markdown file still carries the syntax, the PDF built from it carries none |

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

**The strongest leg first: I built the PRE-UNIT app and exported the same note from both.** A
`git worktree` at `fd598ea6` (the UNIT F brief's commit) built a Debug app, launched ALONE on the
dev store (verified zero instances before and after every launch and quit, always by bundle
identity), and exported the fixture note as `.md` and as PDF; then the current build did the same.

- **`.md`: BYTE-IDENTICAL, proved by two real exports through the real door** — `diff` silent,
  `shasum -a 256` equal on both files (`4b074e79…03047`), and again after the colour fix
  (`F-final-md.md`, same hash). The projection is untouched in practice, not only on paper.
- **PDF: the defect and its fix, side by side.**

A fixture note typed into the shelf's quick-entry bar (8 paragraphs via ⇧⏎, then ⏎ to file),
titled in the masthead, carrying every vocabulary item F-3 names plus row 84's `_italic_`.
Captures in `notes/plans/13u3-screens/` (gitignored):

| capture | what it shows |
|---|---|
| `F01-write-shows-the-editing-face-markers-dimmed-terminal-light.png` | the note in Write: the EDITING face, markers dimmed but present — the other half of the two-face rule, and proof the stored text really is markdown |
| `F02-BEFORE-the-note-pdf-shows-raw-markdown.png` | **the defect, in a real exported PDF from the pre-unit build**: `# Chapter One`, `**bold words**`, `~~a struck phrase~~`, `- [ ]`, backticks, `](https://…)` — her report, exactly |
| `F03-AFTER-the-note-pdf-renders-the-formatting.png` | **the headline**: the same note, same door, shipped build — a big bold *Chapter One*, a smaller *A smaller heading*, **bold**, *italic*, ~~struck~~, `•` bullets, ☐/☑ boxes, monospaced code, an underlined link, and not one marker |
| `F04-AFTER-exported-from-study-DARK-still-black-on-white-paper.png` | the same export taken with the app in **Study voice + DARK appearance**: black on white paper (the #123(c) decision, walked rather than argued) |
| `F05-AFTER-the-book-pdf-renders-its-heading-hierarchy.png` | the BOOK PDF (Encryption Explained, 6 pages): `# book` → `## chapter` → `### note` as three real heading sizes |
| `F06-BEFORE-the-book-pdf-showed-hash-marks.png` | the same book from the pre-unit build: `# Encryption Explained`, `## about this book`, `### About this book` |
| `F07-write-editing-face-study-dark.png` | the note in Write in the other voice and appearance — the editing face unchanged by this unit |
| `F08-a-callout-still-prints-its-blockquote-lead-QUESTIONS-123b.png` | **the one place syntax survives**: a callout block's `> ` lead prints, while the bold/italic/strikethrough INSIDE that same line render — the exact shape #123(b) puts to her |
| `F09-the-apps-own-read-surface-is-the-same-reading-study-dark.png` | the app's own Read surface beside it: the page is the same reading, printed — the one-truth claim, visible |

**The exported ARTIFACTS themselves** — 11 PDFs and 6 `.md` files from both builds, including the
two whose SHA-256 match is the fence's proof — are kept beside the captures in
`notes/plans/13u3-screens/F-exports/` (gitignored), so the evidence can be re-opened rather than
only read about. *(They were written to `~/Documents/13u3f/` by the save panels during the walk
and moved here afterwards; that folder is gone.)*

**Every PDF was OPENED in Preview and read**, not merely written. F03/F04/F05/F08 were re-taken on
the SHIPPED build after the colour fix, so no capture here shows code that is not in the commit.

**WALK VERDICT: her item 16 is done, and the fence held under a real test rather than an argument.**
Both doors (Library ▸ Export ▸ PDF…, Shelf ▸ Export PDF…) produce a page that reads as formatting
rather than as syntax, in both voices and both appearances; the `.md` written by the door beside
it is the same bytes the pre-unit build wrote; and the one remaining marker — a callout's
blockquote lead — is recorded for her with the two roads out rather than papered over.

**Walker facts** (appended to `Tools/WalkKit/README.md`): the shelf quick-entry bar takes markdown
characters cleanly through `cliclick t:` and does NOT auto-continue a list on ⇧⏎; an `NSSavePanel`
is driven with ⌘⇧G → path → ⏎ → ⌘A → name → ⏎; and a PDF is best read back by opening it in
Preview and capturing Preview's own window id (`walk-cap <preview pid>`), since `qlmanage`
thumbnails lose the type. Her `/Applications` copy was never running at any point in this session —
`pgrep` verified before and after every launch and every quit, and every quit was
`tell application id "io.lduarte.Variorum.debug" to quit`, never a keystroke.

### FINALS (2026-09-19)

- core `swift test` — **Test run with 1596 tests in 174 suites passed after 55.716 seconds.**
  (Unchanged: this unit touches ZERO core lines.)
- the FULL Mac suite — **Test run with 2874 tests in 481 suites failed after 741.156 seconds with
  2 issues.** (2864 + this unit's 10 cells.) **The 2 issues are ONE test** —
  `theReadClickLandsInIndexAtThatBlock`, the recorded environment red (KnownIssues row 58, owner
  12) the brief names as the single tolerated one. The row-49 landing arm was green. *(The run
  BEFORE it carried a third issue — the literal-colour pin's refusal of my own diff, recorded
  above and fixed; this run is the shipped tree.)*
- the TUTORIAL SPINE — green: one run over all 11 `Tutorial…` suites plus the
  Encryption/NewModes/Snippets/IA seeder consumers, **113 tests in 15 suites passed**.
- iOS build — **BUILD SUCCEEDED**.
- the FULL mobile suite — **not run, and not owed**: the diff is Mac-only
  (`App/Variorum/Variorum/` + `VariorumTests/`), with ZERO lines in `Shared/`, `Sources/` or
  `VariorumMobile/`. The iOS build above is the owed check. Nothing mobile-visible.
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Server/`: ZERO. `Sources/`: ZERO. Four files changed in all (two app
  files edited, one added, one test suite added), 727 insertions / 98 deletions.

### MOBILE PARITY (a note, not a build)

**The phone has no PDF export at all**, so item 16 owes it nothing today. If one is ever built,
the shape to copy is this unit's and not a port of this file: the phone already has the reading
transform (`MarkdownRendering`, core) and its own reading face in SwiftUI (`Shared/FlowParagraph`,
`MobileReadPage`); what is Mac-only here is the AppKit/CoreText *attributed* end of it
(`Theme/MarkdownReadingFace.swift`), which is why it sits in the Mac target rather than in
`Shared/`. **A parity row is the orchestrator's to file, if she wants one.**

### FOUND, NOT MINE (handed up rather than carried)

1. **A callout's `> ` leads are the one syntax left on the page**, because the blockquote form is
   not in F-3's v1 vocabulary and the display brain has therefore never known what one is. Two
   roads out, both recorded in QUESTIONS #123(b): teach the vocabulary `>` (a canon addition that
   would reach EVERY surface including the editing face she types into), or give the PDF a body
   projection without the blockquote mapping (a second projection for one medium — the drift
   class). I implemented neither; the current behaviour is the one-truth default.
2. **`PageComposer` still owns a callout's INDENT rule privately** (`firstLineHeadIndent = 22` at
   `PagePaginator.swift`), and the PDF has no equivalent because its callouts arrive as `> ` text
   instead. If (1) is ever ruled, that indent is the second thing that wants hoisting beside the
   face — noted, not done.
3. **The `.md` and the PDF now disagree about what a callout IS** (blockquote characters vs an
   indented passage on the page, and neither on the screen where Read draws a wash). That is
   three transforms of one presentation, each defensible on its own medium; whether they should
   converge is a design question above this unit.

### DEFERRED / NOT MINE (stated rather than done)

- **QUESTIONS #123** — five PROVISIONAL calls (the reading face rather than the editing one · the
  callout's surviving `> ` · the page writing no colour at all · nothing re-fonted · the title not
  read as markdown). The marker moved to **#124**.
- **The typographic pass stays 13m's** — no font, measure, margin, running head or line-spacing
  decision was made here, deliberately.
- **Not touched:** UNIT A1's gutter, UNIT A2's comments panel, UNIT B's card family, UNIT C's
  capture boxes, UNIT D's savepoint names, UNIT E's version faces, `Sources/VariorumCore/` in
  full, `Persistence/`, `Sync/`, `Server/`, the schema, the marker, `Shared/`, and the whole
  mobile target.

---

## UNIT F CLOSED — 2026-09-19

Her item 16 is built. The PDF export was a phase older than the markdown vocabulary it was
printing, so it drew the characters she typed; it now draws what the app draws, because the
attributed half of the app's own READING face stopped living privately inside `PageComposer` and
became `Theme/MarkdownReadingFace` — one brain, two media, no second parser and no new formatting
rule (the two rules that HAD been written out twice, a heading's size and a trait union, now call
the editing face's own). The `.md` road is untouched and was proved so the hard way: the same note
exported from a build of the pre-unit commit and from this one produced files with the same
SHA-256. The suite then caught a literal colour I had introduced, and the fix that answered it is
better than the literal was — the page writes NO colour at all, so a PDF exported in dark can
never arrive white on white. 10 new cells in one suite (6 of 8 of the first draft red on the
shipped exporter, 31 issues), 9 walk captures including BEFORE/AFTER pairs for both a note and a
book in both voices and both appearances, one new PROVISIONAL bundle (#123). Zero core lines, zero
schema, zero migrations, zero `Sync/`, marker 8. Suites and finals above.

---

## UNIT G BRIEF — THE CEREMONY-SHEET RESIDUALS (KnownIssues row 42; self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · roster item 7 · GOVERNANCE + the
constitution · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the walker facts. (2) **THE FIX SHAPES
ARE ALREADY WRITTEN:** `notes/plans/use-report-round-2026-09-06.md`, the section titled
"### 18f LADDER — ROUND 3 FINDINGS" — findings **R3-5 · R3-6 · R3-7 · R3-8 · R3-9**, each with
its mechanism, fix shape and pin shape. Read them verbatim; they are your design. (3)
`notes/KnownIssuesAndTechDebt.md` row 42 (the row you resolve). (4) The code the findings name:
`Features/Editor/EditorSurfaceController.swift` (`openMergeCeremony` / `openMergeRunChoice` /
`refreshMergeCeremony` / `refreshMergeSheetIfDrifted` / `runMergeChain` / `MergeRunBlock`) ·
`Features/Takes/TakesStructureController.swift` (the instant road's park) ·
`Sources/VariorumCore/Queries/` (R3-9's new reader's home) + `Operations.renderedVariant` (the
rule it mirrors).

**Scope (ONE acceptance unit — the merge/divide sheets' drift family):**
1. **R3-5 (the core item):** `MergeRunBlock` gains `shownVariantID` read in the SAME store read
   as the fans; the RUN arm's drift check before running (compare store-rendered id + takeCount
   per block; on drift, rebuild `runBlocks` + `otherTakes` and speak the refresh line);
   `runMergeChain` takes the state's shown ids as `displayed`. **Pin red-on-old** exactly as the
   finding writes it (a run of three, fanned middle, `.onlyTheShownOnes`, re-point the middle's
   chosen through ops under the open sheet → the first ⏎ REFRESHES; today it joins).
2. **R3-6:** the pair's rendered ids read at open from the same store read as the fans (the
   raise's rule applied at open); the open-time-lag spurious refresh retires.
3. **R3-7:** after a shown-pair refresh under a PRESET, the pre-pair re-seeds from `rendered`
   exactly as open does; under `.pairByHand` hers are kept (R2-1's pin rides). Pin per the
   finding.
4. **R3-8:** `renderedTakeID(of:)` hoisted to a `FanHalf` extension, consumed on all three
   roads. **NO pin — the finding itself states a pin would pass on both sides; record it as
   cleanliness, never claim a red.**
5. **R3-9:** core `Queries.renderedVariantID(db, blockID:)`, public, mirroring
   `Operations.renderedVariant`'s rule with the SAME equivalence pin shape
   (`PostRenderQueryTests.renderAgreesWithOperationsRenderedVariant` is the precedent); the
   drift checks consume it (the confirm ∝ 2 blocks, never the note).
6. **UNIT B's handed-up find, folded here:** three reads of a note's opening disagree on take
   resolution (`NoteCards.load`'s COALESCE(chosen, default) · the note picker's default-only
   snippet · neither is `renderPost`'s full rule). Where the new R3-9 reader (or the COALESCE
   rule it mirrors) is trivially consumable at those sites, consume it; where not, VERDICT each
   site in your record (aligned / recorded-with-reason). No visual redesign — resolution only.
7. **KnownIssues row 42 RESOLVED** in the same commit as the last fix.
8. **Fences:** zero schema · zero `Sync/` · the ceremony sheets' FACES (18f's presets, figures
   A/B grammar) untouched — this is drift correctness, not restyle; `BlockRangeIndex` untouched.

**End verification:** FULL Mac suite (row 58 tolerated) · tutorial spine green · iOS build
green · YOUR walk with captures: the merge sheet on a fanned run of three, drift staged through
ops under the open sheet (the refresh line speaks; confirm joins what the list shows), both
voices. Record: **UNIT G RECORD**, LIVE STATUS from the first commit, UNIT CLOSED banner,
ledger row 8 flipped in the same commit.

---

## UNIT G RECORD — THE CEREMONY-SHEET RESIDUALS (opus-implementer, 2026-09-19)

**WHAT I DID NOT DO, stated first (the record's own rule).** I did not touch the ceremony sheets'
FACES — not one preset, not one word of the arrangement row, not figure A or B's grammar; this is
drift correctness, and the sheets look exactly as 18f left them. I did not touch `Sync/`,
`Persistence/`, the schema, a migration, or `BlockRangeIndex`; the marker stays 8. I claimed **no
red for R3-8** — the finding says a pin would pass on both sides and it is right, so it is recorded
as cleanliness. I did not rewrite the statements that already carry the rendered-take resolution
correctly (`renderPost`, `leadingBlockTextsSQL`, `Export.blockTakes`, `PageExtents`, the two
word-count reads) — re-typing a shipped load-bearing query for tidiness is the risk, not the cure;
they are verdicted below and held by an anti-drift pin instead. I did not build UNIT H (the E
hand-up), and I did not carry the two things the walk and the suite handed up.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| piece | status |
|---|---|
| 0 · read the brief's named sections (plan banner · roster 7 · GOVERNANCE + constitution · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the walker facts · the 18f round-3 record R3-5…R3-9 · KnownIssues row 42 · the code the findings name) | **DONE** |
| 1 · R3-9 — core `Queries.renderedVariantID` (+ the plural), with the equivalence pin | **DONE** — `Queries.renderedVariantIDs`/`renderedVariantID` in `Sources/VariorumCore/Queries/PostRender.swift`; 4 new cells in `PostRenderQueryTests` (the three-resolver equivalence over the same fallback matrix · the gap/unplaced conventions · the foreign-chosen guard · the EXPLAIN-plan seek pin); suite 28/1 green |
| 2 · R3-6 — the pair's rendered ids read from the STORE at open, in the same read as the fans | **DONE** — `liveActiveFansAndRendered`; pin `openingReadsTheShownPairFromTheStoreSoNothingRefreshesSpuriously` RED on `25638746` (5 issues), green now |
| 3 · R3-5 — `MergeRunBlock.shownVariantID`; the RUN arm's drift check; `runMergeChain` takes the state's shown ids (RED-ON-OLD owed) | **DONE** — `refreshMergeRunIfDrifted` + the retired `if !state.isRun` fence; 2 pins RED on `25638746` (the run merged on the first press in both), 1 guard pin green on both sides and recorded as such |
| 4 · R3-7 — the pre-pair re-seeds from `rendered` on a preset refresh; hers kept under `.pairByHand` (RED-ON-OLD owed) | **DONE** — `prePairing` hoisted and consumed at both open and refresh; pin `aPresetRefreshReSeedsThePrePairFromWhatTheSheetNowShows` RED on `25638746` (the stale head survived and then joined) |
| 5 · R3-8 — `renderedTakeID` hoisted to a `FanHalf` extension, consumed on all three roads (NO pin — hollow by the finding's own words) | **DONE** — `Features/Takes/FanHalfRendering.swift`; the two sheet roads and the board's instant road read it; NO pin claimed, and the file says why in its own header |
| 6 · item 6 — the three disagreeing opening-take reads: consume or verdict | **DONE** — the rule ships as `Queries.renderedTakeJoinSQL` + `renderedTakeTextSQL`; `NoteCards.load` and BOTH `notePickerNotes` overloads consume it; 4 pins (3 RED on `25638746` at the card's three divergences, 2 red at the picker's), plus an anti-drift net walking SIX readers over one world; the other `default_variant_id` reads verdicted in the record |
| 7 · the walk (dev-store Debug, both voices) with captures | **DONE** — 14 captures, `notes/plans/13u3-screens/ug-01…ug-14`; the drift staged BY HAND through the app's own doors using TWO dev instances on one store (the new WalkKit fact); both voices; zero instances at the end, her store never touched |
| 8 · finals (core · FULL Mac · tutorial spine · iOS build) | **DONE** — below |
| 9 · close — KnownIssues row 42 RESOLVED + ledger row 8 flipped + UNIT CLOSED banner | **DONE** — this commit; QUESTIONS #124 opened |

*(No death so far. Baselines at open, from the brief: FULL Mac **2874/481** with row 58's environment red the single tolerated one; core **1596/174**; tutorial spine green; marker 8.)*

### THE RED-ON-OLD VERIFICATION — NAMED BEFORE IT RAN (the checkpoint protocol)

Every defect-shaped row was traced first, then pinned, then watched fail on the PRE-UNIT tree
`25638746`, then fixed. The whole batch of pins was run against that tree in ONE pass before a
line of production code changed (`/tmp/ug-redonold.log`): **11 issues across 4 cells.**

| pin | row | RED on `25638746` — the exact failure |
|---|---|---|
| `openingReadsTheShownPairFromTheStoreSoNothingRefreshesSpuriously` (`MergeArrangementTests`) | **R3-6** | 5 issues. `opened.firstRenderedID` = the PROJECTION's head (`…002`) while the store already rendered the spare (`…007`); the first ⏎ then refreshed, said *"the takes changed while the sheet was open"*, and did NOT land (2 blocks still) |
| `aRunsShownTakeRePointedUnderTheOpenSheetRefreshesInsteadOfJoiningIt` (`MergeArrangementTests`) | **R3-5**, plain road | `try h.storeSlots().count == 3` failed and `mergeCeremony` was nil — the run MERGED on the first press, joining a take the list never showed |
| `aRunsCarryAllSeedsFromTheSheetsShownTakesNotTheProjection` (`MergeArrangementTests`) | **R3-5**, carry-all + `displayed` | same two failures — merged on the first press |
| `aPresetRefreshReSeedsThePrePairFromWhatTheSheetNowShows` (`MergeCeremonySheetTests`) | **R3-7** | the refreshed pre-pair kept the stale head (`…002` where `…007` was now marked), and "Pair by hand…" afterwards joined `"Alpha one. Beta two."` — the pair the sheet no longer marked |
| `aCardPreviewsTheTakeTheNoteShows` (`LibraryCardNameTests`) | **item 6**, the card | 3 issues, one per divergence: the ARCHIVED chosen previewed `"The archived take."`, the TOMBSTONED chosen previewed `""` (a blank card), the FOREIGN pointer previewed `"Another block's words."` |
| `thePickerPreviewsTheTakeTheNoteShows` (`SnippetsAndPickerQueryTests`) | **item 6**, the picker | both overloads returned `"The default take."` where the note shows `"The take I chose."` |

**Green on both sides, and said so rather than claimed:** `anUndriftedRunStillConfirmsOnTheFirstPress`
(a guard — the check must not become a toll), `thePickerFallsBackExactlyAsTheNoteDoes` (default-only
happens to agree on the two fallback shapes), and every cell of **R3-8**, whose finding states the
equivalence itself.

### THE TRACED MECHANISMS (what was actually wrong, in the code, before anything changed)

1. **R3-5 — the RUN arm had no drift check, and the reason it didn't was true when it was written
   and false by the time it shipped.** Round 2 fenced the check with `if !state.isRun`
   (`EditorSurfaceController.confirmMergeCeremony`) on the reading *"a run's sheet marks a list of
   blocks, not a pair"*. Figure B's amendment, landed in the same letter, made the run's list show
   **each block's shown take over its text** — so the sheet was making the pair's exact promise on
   a surface with no check behind it. `MergeRunBlock` carried `shownText` and **no variant id**, so
   there was nothing to compare even if the fence had come off: the plain chain resolves each side
   inside `ops.merge` from the store's chosen, and the carry-all took `displayed` from
   `model.index.entries` — the projection, which only ever lags the store. Either road could join a
   take the list never drew, and `mergedChain`'s receipt then said *"the takes you were looking at
   joined"*.
2. **R3-6 — the pair read its shown ids from a different place than its check compared.** `open`
   took them from `model.index.entries`; `refreshMergeSheetIfDrifted` compared the STORE (round 2's
   raise). Open inside the sub-delivery window and the two disagreed on arrival, so the first ⏎
   refreshed and blamed a change that predated the open. Honest but wrong in the mouth.
3. **R3-7 — the pre-pair survived a refresh by liveness while the marking moved.**
   `refreshMergeCeremony` filtered `state.pairings` to those whose both sides still live. Under a
   PRESET the pre-pair is invisible (the columns mark `firstRenderedID`), so the OPEN-time pair sat
   there unseen; pick "Pair by hand…" after a refresh and the Pairings section offered head ＋ tail
   — the pair the sheet no longer marked — and S4-23 ruling 4's *"⏎ reproduces the instant
   outcome"* stopped holding.
4. **item 6 — two reads of a note's opening, two different rules, neither the note's.**
   `NoteCards.load` joined `COALESCE(cb.chosen_variant_id, b.default_variant_id)`, which agrees
   with the note only while the chosen take is live, active and this block's — and parts company in
   three reachable shapes (measured above). `ShelfQueries.notePickerNotes` (both overloads) read
   `b.default_variant_id` ALONE, and `chooseVariant` writes only the placement's chosen
   (`Operations+Placement.swift:25`) — so the picker previewed the wrong take for **every block
   whose take she has switched**, which is the everyday case, not a race.

### WHAT THE SHEETS DO NOW (the contract)

- **One drift check, both shapes.** `refreshMergeSheetIfDrifted` dispatches to the pair's arm or
  the run's; the `if !state.isRun` fence is gone, so every preset road checks. The RUN's arm
  compares the whole row it drew — shown id, shown TEXT, take count — against one fresh store read
  (`runFansAndRendered`, the same read `open` built the list from), rebuilds `runBlocks` and
  `otherTakes` on drift, keeps the row she chose and the sheet's identity, and speaks the standing
  line. Every fan folding to a single (the two roads become byte-identical `merge`) or a block
  dissolving dismisses in the pair arm's own words.
- **The list's ids are the merge's `displayed`.** `MergeRunBlock` carries `shownVariantID`, read in
  the same store read as the fans, and `runMergeChain` takes those ids instead of the projection's
  (R2-2's pattern, applied to the run). What the list marks is what joins.
- **The pair reads the store at open too** (`liveActiveFansAndRendered`), so the open-time lag
  window no longer produces a refresh that blames the wrong moment.
- **The pre-pair is ONE function** (`prePairing`), consumed at open AND at a preset refresh; under
  `.pairByHand` hers are kept untouched (R2-1's pin rides unchanged).
- **Cost:** both drift checks read `Queries.renderedVariantIDs` — the blocks the gesture names,
  never the note around them. `renderPost` loaded every slot's rendered TEXT of the whole note to
  answer two ids.

### THE NEW CORE READER, AND THE FOUR READS I DID NOT REWRITE (item 6's verdicts)

`Queries.renderedVariantIDs(db, blockIDs:)` / `renderedVariantID(db, blockID:)` are
`renderPost`'s resolution with the traversal turned around — driven by the BLOCK rows named, the
live placement joining in beside them through `uq_cblock_ownership` (live-unique on `block_id`, so
nothing multiplies). Read-layer conventions, pinned: a gap is ABSENCE, never a throw; an **unplaced
live block still answers by its default**, which is the one question the pointer-driven `renderPost`
cannot be asked and which a released-to-lineage block needs. The rule also ships as text
(`renderedTakeJoinSQL` + `renderedTakeTextSQL`) for statements that resolve an opening inside a
bigger question.

| read | verdict |
|---|---|
| `NoteCards.load` (`LibraryCatalogView.swift`) | **ALIGNED** — consumes the fragment; red-on-old at all three divergences |
| `ShelfQueries.notePickerNotes` ×2 | **ALIGNED** — both consume the fragment; red-on-old on the everyday case |
| `Queries.renderPost` · `leadingBlockTextsSQL` · `Export.blockTakes` · `PageExtents`' slot read | **ALREADY THE RULE, own copy KEPT** — byte-identical joins; re-typing four shipped, load-bearing statements for tidiness buys nothing and risks the class this unit exists to fix. Held by `everyRenderedTakeReaderAgreesOnOneWorld` instead |
| `ShelfQueries`' two word-count reads (`:74`, `:100`) | **ALREADY THE RULE, own copy KEPT** — a correlated chosen subquery carrying every guard; not an opening read |
| `PoolAndTray`'s tray/released/unplaced reads · `Trash`'s block rows | **CORRECT BY CONSTRUCTION** — every one is about a block with NO live placement, where `default_variant_id` alone IS the rule (`renderedVariant`'s own fallback). Not a divergence |

### THE PINS (13 new cells: 7 core + 6 Mac)

**Core (`PostRenderQueryTests`, 5):** `renderedVariantIDAgreesWithBothResolvers` (three resolvers,
the precedent's own fallback matrix) · `renderedVariantIDGapsInsteadOfThrowingAndAnswersFor
UnplacedBlocks` · `renderedVariantIDRefusesAForeignChosenPointer` ·
`everyRenderedTakeReaderAgreesOnOneWorld` (the anti-drift net over SIX readers) ·
`theNamedBlocksReadSeeksAndNeverScans` (EXPLAIN over the SHIPPED constant — the reader's whole
point). **Core (`SnippetsAndPickerQueryTests`, 2):** `thePickerPreviewsTheTakeTheNoteShows` (red) ·
`thePickerFallsBackExactlyAsTheNoteDoes` (green both sides, said so).
**Mac (`MergeArrangementTests`, 4):** the R3-6 open-time pin · the two R3-5 pins · the
undrifted-run guard. **Mac (`MergeCeremonySheetTests`, 1):** the R3-7 re-seed pin, which also
follows through to the hand road's actual outcome. **Mac (`LibraryCardNameTests`, 1):**
`aCardPreviewsTheTakeTheNoteShows`, all three divergences in one world.

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

**The drift was staged BY HAND, through the app's own doors — not simulated.** Two facts made that
possible and both are now in `Tools/WalkKit/README.md`: the dev store is SQLCipher-encrypted, so no
external `sqlite3` writer can re-point a take; and while her J16 ruling says a second WINDOW
cancels the sheet, a second **PROCESS** does not — two dev instances (`open -n` twice) share the
store and one can write while the other's sheet is open, which is exactly the shape a sync apply
has. Fixture typed through the shelf quick-entry bar (three paragraphs, ⇧⏎ between), the middle
block fanned through the Takes board.

| # | capture | what it shows |
|---|---|---|
| 01 | `ug-01-fixture-fanned-middle-terminal.png` | the fixture: 3 blocks, the middle fanned (`Beta two.` chosen · `SPARE`) |
| 02 | `ug-02-run-sheet-open-terminal.png` | the RUN sheet: *3 blocks · 1 take beyond the shown ones*, the two presets, the list with block 2 marked *2 takes — all coming along* over `Beta two.` |
| 03 | `ug-03-drift-staged-instance2-terminal.png` | instance 2 re-points block 2's chosen to `SPARE` — the store moves under the open sheet |
| 04 | `ug-04-drift-refresh-terminal.png` | **the fix**: ⏎ under "Only the shown ones" did NOT merge — the list re-marked `SPARE` (*2 takes — only this one comes*), the line spoke *"The takes changed while the sheet was open — review before merging."*, three blocks intact behind it |
| 05 | `ug-05-second-press-joins-what-the-list-showed-terminal.png` | the second ⏎ landed `"Alpha one. SPARE Gamma three."` — the list's own takes |
| 06–08 | `ug-06-run-sheet-open-study.png` · `ug-07-drift-refresh-study.png` · `ug-08-carry-all-landed-study.png` | the same in the STUDY voice on the OTHER preset ("Bring every take"): refreshed, re-marked `Beta two.`, then landed `"Alpha one. Beta two. Gamma three."` with the other take whole (⑂2) |
| 09–11 | `ug-09-pair-sheet-open-study.png` · `ug-10-pair-drift-refresh-study.png` · `ug-11-pair-by-hand-after-refresh-study.png` | the PAIR: opened with the shown pair marked, refreshed on a re-point (the *shown here* badge MOVED to `SPARE`, `Beta two.` became *carried whole*), and **"Pair by hand…" afterwards offered `"Alpha one…." ＋ "SPARE…"`** — R3-7's whole point, with the preview `Alpha one. SPARE` |
| 12–13 | `ug-12-card-previews-chosen-take-study.png` · `ug-13-card-falls-back-past-archived-chosen-study.png` | item 6: the Library card previewed `SPARE Gamma three.`, then — after archiving that chosen take through Write's fan panel — `Beta two. Gamma three.`, the take the note now shows |
| 14 | `ug-14-instant-keep-on-top-divide-ring-study.png` | R3-8: ⌘⇧D on the board split at the word edge, the other take stayed whole on the TOP block (⑂2), and the ring landed on the SECOND successor's rendered take |

⌥⌘Z put every structural act back. The voice was restored to Terminal (the state I found), both
instances quit — the extra by PID, the last by bundle identity — and `pgrep` confirmed **zero
instances**. Her `/Applications` app was never launched or quit.

### THE TWO REDS IN THE FULL SUITE, ADJUDICATED BY MEASUREMENT (not by assertion)

1. **`BookOutlineLandingTests.openingACollapsedStoryLandsAtItsTop WithThreeStoriesExpanded`
   (`abs(top) → 3424.0`)** — the recorded load flake (KnownIssues rows 49/66, and UNIT B's own
   trace of the same number). **Paired protocol: GREEN isolated on my tree.** Not mine.
2. **`BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock` (`live.count → 0`)** — this is
   **row 58's recorded environment red**, named verbatim in UNIT E's own baseline block above. I
   did not take that on faith: I built the PRE-UNIT tree `25638746` in a worktree and ran the suite
   there under identical conditions. **Six runs settle it:** base cold (fresh DerivedData) 7/7
   GREEN in 2.878 s; then, in that same warm DerivedData — my HEAD RED, my first commit
   `ffec8485` RED (a purely ADDITIVE core commit that cannot reach a book-index pane), **the base
   commit itself RED**, base RED again after wiping the Debug domain's 178 `surfaceSize.*` keys
   (sanctioned by ENVIRONMENT TRAPS; they regenerate — 5 were back after the next run), and base
   RED running that ONE test alone. The control is the verdict: **the red reproduces on the tree
   with none of my work in it.** The one green reading was the first run in a cold DerivedData and
   has not reproduced since — the nearest thing to a covariate this unit found, and worth one line
   to whoever owns row 58. Row 58's twin (`BlocksWorkbenchFaceTests`' read-click) passed in my full
   run, so the family is not even reliably red together.

### FINALS (2026-09-19)

- core `swift test` — **Test run with 1603 tests in 174 suites passed after 51.778 seconds.**
  (Baseline 1596/174 + 7 new cells in existing suites = exactly this.)
- the FULL Mac suite — **Test run with 2880 tests in 481 suites failed after 743.375 seconds with
  3 issues** — the 3 issues are the 2 suites adjudicated above (row 58's environment red, 2 issues;
  the row-49 load flake, 1 issue, green isolated). Baseline 2874/481 + 6 new cells, no new suites.
- the TUTORIAL SPINE — green in-run (all 13 `Tutorial…` suites passed; the only two failing suites
  in the whole run are the two named above).
- iOS build — **BUILD SUCCEEDED** (`VariorumMobile`, iPhone 17 Pro simulator).
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Server/`: ZERO. `BlockRangeIndex`: ZERO.

### MOBILE PARITY (a note, not a build — the brief's rule)

`Queries.renderedVariantIDs` / `renderedVariantID` and the `renderedTakeJoinSQL` fragment are core
and platform-free, so the phone inherits them the moment it wants them. **The phone owes nothing
here**: it has no merge ceremony sheet and no Library card of this shape. One row for the catch-up
if its own opening-preview reads are ever audited: they were not in this unit's scope, and the
anti-drift net (`everyRenderedTakeReaderAgreesOnOneWorld`) only walks the readers core ships.

### FOUND, NOT MINE (handed up rather than carried)

1. **The remembered-note-length store writes into the SHARED Debug defaults domain under
   DETERMINISTIC fixture UUIDs.** `defaults read io.lduarte.Variorum.debug` held **178**
   `surfaceSize.flow.<uuid>` keys whose uuids are the test harnesses' `.incrementing` ids
   (`…000000000001`, `…00000000000C`) — so two suites that both mint a fixture note as id 1 share a
   remembered height across runs, and a mounted-flow test can read a height another suite wrote.
   18d's store is deliberately LOCAL-ONLY and never synced, which is right; what it lacks is a test
   seam. I wiped them (sanctioned) and it did NOT fix the row-58 red, so this is not that bug — but
   it is a real test-isolation hazard sitting under every mounted book/flow suite. **Owner: the
   landing/settle family (KnownIssues 12), beside rows 49/58/66.**
2. **Row 58's red has a candidate covariate worth one experiment:** it passed only in the FIRST run
   after a clean build into a fresh DerivedData, and failed in all five subsequent runs across both
   trees (including alone). If that reproduces, the row stops being "environment" and becomes
   "warm-build", which is a thing a fix can bite on.

### DEFERRED / NOT MINE (stated rather than done)

- **UNIT H** (the Takes board's live-card delete door + the lesson's truth) — the ledger's row 8b,
  untouched.
- **The 18f ladder's R3-1…R3-4** (the board's sheet receipt, the field guide's deleting chapter,
  the two bars' ceremony rows and the Divide help) — routed to 17o batch d as ledger rows 43–46 at
  the letter's close; not this unit's, and I left them alone.
- **The ceremony sheets' typography and layout** — 18f's face is the design; this unit changed
  nothing anyone can see except the words the refresh speaks and the takes the list marks.

---

## UNIT G CLOSED — 2026-09-19

The merge sheets' drift family is closed: the RUN arm checks what it showed you before it joins,
the pair reads the store at open as well as at confirm, the pre-pair moves with the marking, the
board's instant divide speaks the one rendered-take rule, the confirm costs the blocks it names
rather than the note around them, and two reads of a note's opening now show the take the note
shows. **KnownIssues row 42 is RESOLVED** in this commit; ledger row 8 flipped with it.
Commits `c79860b0` → this one. QUESTIONS **#124** carries the one PROVISIONAL.

---

## UNIT H BRIEF — THE TAKES BOARD'S LIVE-CARD DELETE DOOR + THE LESSON'S TRUTH (the E hand-up; self-contained; read in this order)

**Read first, in full:** (1) this file's Status banner · GOVERNANCE + the constitution (P-1, P-2
and P-6 all bite here) · ENVIRONMENT TRAPS · CAST & DISCIPLINE · **ORCHESTRATOR ADJUDICATIONS
AFTER UNIT E, item 2** — the trace this unit builds to, and AFTER UNIT D, item 1 — the walk
rule (quit by bundle identity ONLY; `pgrep` after every quit; her real-store app never touched).
(2) The code: `Features/Takes/TakesBoardView.swift` (the LIVE take cards — the door's home; the
ARCHIVED card's direct delete button ~:1331 is the board's own precedent) ·
`Features/Takes/WriteTakesPanel.swift` (`TakeCardMenuCopy.deleteTake` — the vocabulary
precedent; archive/label/lock/delete on its cards) · `Features/Tutorial/TutorialSeeder.swift`
~:1056 and ~:1080 (the lesson teaching *"⋯ menu ▸ Delete"* — the stale copy) ·
`CapabilityRegistry` (`.deleteTake` is already in the board's declared list, `TakesBoardView.swift:77`
— find how it is declared (`.surface`?) and make the rendered door match the declaration; the
18f R3-3 per-surface pin pattern is the shape). (3) `Tools/WalkKit/README.md`'s walker facts.

**Scope (ONE acceptance unit — the door and the words):**
1. **The door:** a LIVE take card on the Takes board offers Delete (and, if the same gesture
   family is where it naturally lives, the WriteTakesPanel card menu's set — but ONLY delete is
   owed; do not restyle the card). Compose the existing `model.deleteTake(take.id)` road — the
   op's semantics are settled (I10: the last live active take refuses and the refusal speaks;
   a CHOSEN take's delete refuses at the RESTRICT class through the ops layer's check — whatever
   the existing model road already speaks). Match the board's card grammar (the archived card's
   button style, or a context menu mirroring `WriteTakesPanel` — pick what the v2 card grammar
   supports and record the choice PROVISIONAL).
2. **The words:** the takes lesson's two sentences corrected to the door that EXISTS (name the
   real gesture, not "⋯"); any sibling sentence naming the retired ⋯ swept (`grep` the seeder
   for the glyph — the R3-2 lesson: no single-string grep can find prose variants, walk the
   chapter's cards).
3. **The pin that holds words to doors:** the lesson's prose names a door; a pin asserts the
   board RENDERS that door (the declared-vs-rendered equality the R3-3 pattern pins per
   surface). Red-on-old BOTH ways: the door pin red on the pre-fix board (no delete door on a
   live card), the words pin red on the pre-fix lesson (the ⋯ claim).
4. **Fences:** zero core (the op exists) · zero schema · zero `Sync/` · the ceremony sheets
   (UNIT G's surface) untouched · nothing else on the card restyled.

**End verification:** FULL Mac suite (row 58 tolerated; row 49's arm by the paired protocol) ·
tutorial spine green WITH the corrected lesson's pins · iOS build green · YOUR walk with
captures: delete a spare take from a live board card (the receipt speaks), the last-take refusal
speaks, the lesson read in the tutorial, both voices, both appearances. Record: **UNIT H
RECORD**, LIVE STATUS from the first commit, UNIT CLOSED banner, ledger row 8b flipped in the
same commit. The lesson edit joins the closeout's re-seed list (state it in your record).

---

## UNIT H RECORD — THE TAKES BOARD'S LIVE-CARD DELETE DOOR + THE LESSON'S TRUTH (opus-implementer, 2026-09-19)

**WHAT I DID NOT DO, stated first (the record's own rule).** I did not restyle the take card — not
the chosen bar, not the choose band, not the reorder arrows, not the pane; the card gained ONE
control and lost nothing. I did not touch the ceremony sheets (UNIT G's surface), `Sources/`,
`Sync/`, `Persistence/`, `Server/`, the schema, a migration or `BlockRangeIndex`; the marker stays
8 and core is byte-untouched. I did not add a RECEIPT to the take delete — it has never had one on
either surface, and inventing one is product behaviour the brief did not ask for (QUESTIONS
#125(b) puts it to her). I did not re-word `.lastActiveVariant`, whose sentence was written for
the take→block-below door and reads oddly for a delete — it is unreachable from this door, because
the chosen check fires first, and re-wording a shipped string for a path she cannot take is the
drift class. I did not fix the Snippets-vocabulary drift OUTSIDE the ⋯ sweep the brief ordered
(handed up below). I did not carry the two things the full suite and the walk handed up.

### LIVE STATUS (written at the start; flipped in the same commit as each piece)

| piece | status |
|---|---|
| 0 · read the brief's named sections (plan banner · GOVERNANCE + P-1/P-2/P-6 · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the two adjudications · the code the brief names · `Tools/WalkKit/README.md`) | **DONE** — this commit |
| 1 · the TRACE, measured on the pre-unit tree before a line changes (what the board's live card renders; where the delete door does and does not exist; what each refusal actually says) | **DONE** — the whole pin batch run against `4f069b1b` with NO production line changed (`DerivedData/13u3h-redonold.log`): **12 issues across 6 of 8 cells**; the table below |
| 2 · the DOOR — one `TakeCardMenu` component rendered by the board's live cards (all four fan styles) and by Write's panel, with the registry declaration and the rendered-door oracle | **DONE** — this commit; 5 of the 8 cells green (2 door cells RED on old, the per-surface declaration cell RED on old); 104 neighbour tests in 12 suites green |
| 3 · the refusal the new door will meet most — `variantIsChosen` — gets words (it falls to `default:` and dumps the raw enum with a UUID in it today) | **DONE** — this commit; RED on old in two cells (the copy table and the model door, the latter printing `Refused: variantIsChosen(id: "00000000-…-000000000002")`) |
| 4 · the WORDS — the takes lesson's two sentences + the ⋯ sweep of the seeder, held to the door by a pin that reads the row's own title | **DONE** — this commit; the takes-delete lesson + the practice take's own words, and the sweep's OTHER find (the trio lesson named a ⋯ row *"Move out to a pool"* — a name the menu dropped at the Snippets ruling — while a shipped pin asserted that literal string and called it "verbatim"). Tutorial spine 83/13 green |
| 5 · the walk (dev-store Debug, both voices, both appearances) with captures | **DONE** — 17 captures, `notes/plans/13u3-screens/uh-00…uh-16`; the LESSON'S OWN EXPERIMENT executed on the board it now names; both voices, both appearances, three of the four fan styles; zero instances at the end, her store never launched |
| 6 · finals (FULL Mac · tutorial spine · core · iOS build) | **DONE** — below; FULL Mac **2889/482** (baseline 2880/481 + 9 new cells in 1 new suite, exactly), both reds adjudicated |
| 7 · close — ledger row 8b flipped + UNIT CLOSED banner + QUESTIONS | **DONE** — this commit; QUESTIONS **#125** opened (two PROVISIONAL calls) |

*(No death so far. Baselines at open, from the brief: FULL Mac **2880/481** with row 58's
environment red tolerated (warm-DerivedData covariate noted by UNIT G) and row 49's landing arm by
the paired protocol; core **1603/174**; mobile 626/106 w/4 known; tutorial spine green; marker 8.
Mac DerivedData `App/Variorum/DerivedData/13u3f` is reused warm — 15 GiB free on this disk — and
iOS `13u3g-ios`.)*

### THE RED-ON-OLD VERIFICATION — NAMED BEFORE IT RUNS (the checkpoint protocol)

Three cells, named here before they are written, each measured on the pre-unit tree `4f069b1b`
with NO production line changed:

1. **the door pin** — mount the real Takes board on a fanned note with the fan bloomed and read the
   rendered-door oracle: `.deleteTake` (and the rest of the take-card grammar) must be recorded by a
   LIVE card. RED on old: the live card renders a choose band and two reorder arrows and nothing else.
2. **the refusal pin** — `OpsRefusalCopy.message(for: OperationError.variantIsChosen(id:))` must be
   a sentence, not `Refused: variantIsChosen(id: "…")`. RED on old: it falls to `default:`.
3. **the words pin** — the takes-delete lesson's prose must name the row by the row's OWN title
   (`TakeCardMenuCopy.deleteTake`) and name where the ⋯ lives. RED on old: the lesson says
   "⋯ menu ▸ Delete" with no place, and the board it sends a reader to has no ⋯.

### THE RED-ON-OLD TABLE — MEASURED ON `4f069b1b` BEFORE A PRODUCTION LINE CHANGED

The whole pin batch ran against the pre-unit tree in ONE pass (`DerivedData/13u3h-redonold.log`):
**12 issues across 6 of 8 cells.** The only production code present at that run was the
instrumentation (`TakeCardMenu` + its oracle), which nothing rendered — so the door pins failed for
the reason they exist to catch.

| pin | RED on `4f069b1b` — the exact failure |
|---|---|
| `theBoardsLiveTakeCardCarriesTheFourActs` (stack) | 2 issues. `doors.rendered → []` — a live card recorded NOTHING, with two panes mounted (the fan really bloomed) |
| `theOtherLiveCardShapeCarriesThemToo` (carousel → `takeMiniPane`) | 1 issue. `doors.rendered → []` in the other card shape too |
| `bothTakesSurfacesDeclareTheOneCardGrammar` | 1 issue. `TakesBoardView.surfaceCapabilities` held `deleteTake` (the ARCHIVED card's) and none of `archiveTake`/`labelTake`/`lockTake` |
| `theChosenTakesRefusalSpeaksInsteadOfDumpingTheEnum` | 4 issues. `"Refused: variantIsChosen(id: \"8C4A1E32-DEAD-BEEF-0000-000000000001\")"` — the raw enum, the UUID, no road, no answer for the one-take block |
| `theBoardSpeaksThatRefusalWhenTheShownTakeIsDeleted` | 1 issue. The SAME dump through the real model door: `Refused: variantIsChosen(id: "00000000-0000-0000-0000-000000000002")` |
| `theLessonNamesTheRowByItsOwnTitleAndSaysWhereTheMenuLives` | 3 issues. The seeded prose contained neither `"Delete this take"` nor `"Takes"`, and the practice take's words did not say `card` |
| `theTrioLessonNamesTheMoveOutRowTheMenuActuallyHas` (the ⋯ sweep's other find) | RED on old by construction — the seeded trio said *"Move out to a pool"* and did not contain `SnippetsCopy.moveOutRow` (the constant did not exist; the two menus hand-typed the title) |

**Green on both sides, and said so rather than claimed:** `theCardMenuIsOneListWithTheRegistrysOwnWords`
(a pure-value law over new code — it states the anti-drift rule, it does not catch the defect) and
`theDeleteRowRunsTheModelDoorAndTheSpareTakeGoes` (the MODEL door has worked since Phase 2; what
was missing was the card's door, so this cell pins fire-and-DO rather than the gap).

### THE TRACED MECHANISMS (what was actually wrong, in the code, before anything changed)

1. **The board's live take card had no act vocabulary at all — and it never had one.** A live card
   is `TakeCardFrame` → `TakeChooseHeader` (a choose band, the take's label, the ◀ ▶ arrows) +
   `PaneSurfaceView` **with `menuItems: nil`**, so there was no ⋯ button and no Variorum
   context menu on the card's pane either: the card's whole vocabulary was *choose* and *reorder*.
   The board's ARCHIVED cards (`archivedCard`) have carried Unarchive + Delete since 13b 3D, and
   Write's panel has carried the four acts on every card since Phase 7. **A correction to the
   adjudication that opened this unit:** it read "the ⋯ card menu retired at a restyle" — I checked,
   and `git log -S` over `TakesBoardView.swift` finds the board's cards never carried one. What the
   post-13l F1 pass actually did was give the four acts to the board's ARTICLE cell
   (`TakesCellView.menuSpecs`), which acts on the take the note SHOWS, not on the card you pointed
   at. So the gesture the tutorial teaches — *point at the spare card, delete that take* — had no
   door on the board in any fan style.
2. **The registry walk could not see it, by construction.** `.deleteTake` was already in
   `TakesBoardView.surfaceCapabilities` for the archived card's button, and
   `theSurfacesRenderExactlyTheDeclaredSurfaceActs` asserts the UNION of every surface — which
   `WriteTakesPanel` alone satisfies for all four ids. This is the 18f ladder's R3-3 shape exactly:
   a union walk proves nothing per surface. The pin that bites is per-surface, and it is the first
   thing in this unit's suite.
3. **The refusal that door meets most often printed a raw enum.** `performDeleteVariant` checks the
   CHOSEN pointer before `ensureNotLastActive`, so pressing Delete on the take the note shows — and
   on a one-take block, the only take there is — raises `variantIsChosen`, which had no case in
   `OpsRefusalCopy.message` and fell to `default: "Refused: \(error)"`. Reachable on the shipped
   tree from Write's panel; measured through the real model door, not inferred.
4. **The lesson sent a reader to a door without a place, and a shipped pin locked in a second stale
   name.** The takes-delete sentence said *"use the spare card's ⋯ menu ▸ Delete"* — true of Write's
   panel, which it names, but the reader who has just finished the takes chapter is standing in
   Takes, where there was no ⋯; and the practice take's own words said *"the ⋯ menu"* with no place
   at all. The ⋯ sweep then found the trio lesson naming its Blocks-mode row *"Move out to a pool"*,
   a name the row lost at the Snippets vocabulary ruling (pre-13u, W8-1) — **and
   `TutorialWalkTests` asserted that literal string with the comment "the Blocks-mode row,
   verbatim"**, so the pin that should have caught it was holding it in place. Both renderers of
   that row hand-typed the title, so there was nothing for the lesson to quote.

### WHAT THE CARD IS NOW (the contract)

- **One component, two surfaces.** `TakeCardMenu` (in `TakesShared.swift`, beside
  `TakeCardMenuCopy`) renders the ⋯ from ONE `rows` list — Archive this take (⌘⇧A) · Label take… ·
  Lock/Unlock this take · Delete this take — with the registry's own titles, the lock row pointing
  the way the TAKE points, and the delete row `destructive`. Write's panel's four inline buttons
  were replaced by it; the chrome (`.borderlessButton`, `.fixedSize()`, `.controlSize(.mini)`) is
  that panel's own, unchanged to the byte, so the board inherits the grammar rather than a second
  one being invented for it.
- **It reaches all four fan styles through ONE addition.** `TakeChooseHeader` gained an optional
  `acts:` (nil by default, exactly like `reorder:`), and both live-card compositions compose that
  header — `takeMiniPane` (carousel · slot split · the margin-grid rail) and `CollapsibleTakeCard`
  (stack). Nothing else on the card moved.
- **The targets are NAMED, never routed** (`unarchiveTake`'s reason and 13k K6's): the act belongs
  to the card you pointed at, and pointing at a card never moves the keyboard. The label sheet is
  hosted by `TakesBottomBar`, which rides this board, so `requestTakeLabel` opens from a board card
  exactly as it does from Write's panel.
- **Every refusal is the operations layer's own, and every one speaks** (P-2): a sealed note, a
  locked take, the take the note shows, the block's last take. The one that had no words has them.
- **P-2 holds at the other end too, by construction rather than by a guard:** in stack, carousel
  and slot split an UNFANNED block blooms into the growth doors alone — there is no card, so there
  is no door that cannot act. The margin-grid rail does draw a one-take block's card, and that is
  where the refusal's parenthesis earns its place (walked, capture 13–14).
- **What did NOT change:** the archived cards (their own Unarchive + Delete buttons), the article
  cell's right-click vocabulary, the ⑂ badge, the growth doors, the pager, the card frame.
- **The registry:** `TakesBoardView.surfaceCapabilities` gains `.archiveTake`, `.labelTake`,
  `.lockTake` (it already declared `.deleteTake` for the archived card). The union walk's result is
  unchanged — which is the point — and the new per-surface pin is what holds it.

### THE WORDS AS THEY NOW READ

- **The takes-delete lesson** (`what a block leaves behind`): *"…open its takes — ⌘⇧T in Write, or
  the Takes tab (⌘2), where every take card carries the same menu — and on the spare card use
  `TakeCardMenuCopy.menuGlyph` ▸ `TakeCardMenuCopy.deleteTake`. Then press history: …"* — the glyph
  and the row are INTERPOLATED from the menu's own constants, so a rename moves the lesson with it.
- **The practice take's own words:** *"the spare take — delete me from my own card's ⋯ menu (every
  take card has one, in Takes and in Write's takes panel), then put me back from the block's history
  panel."* (Its `hasPrefix("the spare take")` locator is preserved — the shipped walk pin finds it.)
- **The trio lesson:** the conceptual line reads MOVE OUT TO SNIPPETS and the instruction quotes
  `SnippetsCopy.moveOutRow` — the row's one constant, which both renderers (`BlocksWorkbenchView`,
  `NoteIndexColumn`) now consume.
- **The refusal:** *"The note shows this take — choose another take first, and then this one can go.
  (If it's the block's only take, it's the block you want to delete.)"* One error serves two states,
  so the sentence answers both readers.

### THE PINS (9 new cells in one new suite + 1 shipped cell amended)

`App/Variorum/VariorumTests/TakeCardDoorTests.swift` — **the door:**
`theBoardsLiveTakeCardCarriesTheFourActs` · `theOtherLiveCardShapeCarriesThemToo` (the two live-card
shapes, mounted on the REAL board with the fan bloomed, read through a scoped DEBUG oracle —
`TakeCardDoors`, keyed by `AppSession.debugProbeScope` per row 50, because a Takes board is exactly
the kind of surface two suites mount at once). **Declared ⇔ rendered, PER SURFACE:**
`bothTakesSurfacesDeclareTheOneCardGrammar` (the R3-3 shape — the union walk could never see this).
**The one list:** `theCardMenuIsOneListWithTheRegistrysOwnWords` (ids, titles from the registry, the
lock row's direction, the destructive row, and every row's closure actually firing). **Fire-and-DO:**
`theDeleteRowRunsTheModelDoorAndTheSpareTakeGoes` (the row's own act, through the model, to a
tombstone, with the shown take left standing — I10). **The refusal:**
`theChosenTakesRefusalSpeaksInsteadOfDumpingTheEnum` + `theBoardSpeaksThatRefusalWhenTheShownTakeIsDeleted`
(no `Refused:` prefix, no UUID, the road named, the one-take answer present, classed as a refusal,
and nothing deleted). **The words:** `theLessonNamesTheRowByItsOwnTitleAndSaysWhereTheMenuLives` +
`theTrioLessonNamesTheMoveOutRowTheMenuActuallyHas`. **Amended:** `TutorialWalkTests`'
`everyDoorTheChapterNamesIsADoorTheAppHas` arm now reads `SnippetsCopy.moveOutRow` instead of a hand-typed
literal — a JUSTIFIED EDIT whose reason is in place: the claim is unchanged, and its source is now
what "verbatim" was supposed to mean.

### THE WALK (mine — `io.lduarte.Variorum.debug`, dev store, 2026-09-19; `cliclick` + `Tools/WalkKit`)

**The walk IS the lesson's own experiment.** I re-seeded the tutorial through `Help ▸ Restore
Tutorial…` (the AppKit modal — pressed by BUTTON NAME through System Events, the UNIT E fact), read
the new words in the field guide, and then did exactly what they say.

| # | capture | what it shows |
|---|---|---|
| 00 | `uh-00-launch.png` | the dev store at rest (Terminal voice, Rose & moss palette) — the state I found and restored |
| 01 | `uh-01-lesson-new-words-terminal-light.png` | the re-seeded lesson: *"open its takes — ⌘⇧T in Write, or the Takes tab (⌘2), where every take card carries the same menu — and on the spare card use ⋯ ▸ Delete this take"* |
| 02 | `uh-02-live-cards-carry-the-menu-terminal-light.png` | the Takes board, the lesson's own block bloomed: BOTH live cards wear `✓ chosen ◀ ▶ ⋯` / `choose ◀ ▶ ⋯` |
| 03 | `uh-03-the-four-rows-terminal-light.png` | the spare card's ⋯ open: Archive this take (⌘⇧A) · Label take… · Lock this take · Delete this take |
| 04 | `uh-04-spare-take-deleted-terminal-light.png` | pressed: the fan collapses ⑂2 → ⑂+, the card is gone, the shown take stands |
| 05 | `uh-05-deleted-take-waits-with-put-back-terminal-light.png` | history: *deleted takes* lists it, *deleted sep 19, 2026 · 30 days left*, **Put back** beside it — the lesson's promise, met |
| 06 | `uh-06-put-back-terminal-light.png` | **Put back**: *"Take put back — it's in this block's fan again."*, ⑂2, its label and place intact |
| 07 | `uh-07-chosen-take-refusal-speaks-terminal-light.png` | ⋯ ▸ Delete on the **chosen** card: *"The note shows this take — choose another take first, and then this one can go. (If it's the block's only take, it's the block you want to delete.)"* — and ⑂2 still, nothing deleted |
| 08–09 | `uh-08-live-cards-carry-the-menu-study-dark.png` · `uh-09-the-four-rows-study-dark.png` | the same two frames in the **STUDY voice, DARK appearance** (a fully black room, R51) |
| 10–11 | `uh-10-spare-take-deleted-study-dark.png` · `uh-11-structural-undo-brings-it-back-study-dark.png` | deleted there too, then **⌥⌘Z** — *"Undid: Delete Variant"* in the bar's trailing end and the fan back at ⑂2 (the road 13j's no-confirm rule promises) |
| 12 | `uh-12-margin-grid-rail-card-study-dark.png` | the **margin-grid rail**'s 250-pt card: `✓ chosen ◀ ▶ ⋯` fits at the tightest width the board has |
| 13–14 | `uh-13-one-take-card-menu-study-dark.png` · `uh-14-one-take-refusal-study-dark.png` | the rail's **one-take** card (no reorder arrows — a one-take fan draws none): ⋯ ▸ Delete, and the refusal's parenthesis answering the block with nothing else to show |
| 15–16 | `uh-15-writes-panel-unchanged-terminal-light.png` · `uh-16-one-grammar-writes-panel-terminal-light.png` | **⌘⇧T** — Write's panel, the surface the component was extracted from: byte-identical chrome, and the identical four rows |

Three of the four fan styles were exercised (carousel · margin grid incl. the one-take rail card ·
and the panel's own card shape); the stack shape is pinned rather than walked. Voice restored to
Terminal, style restored to carousel, `appearanceChoice` restored to `system`, every quit by bundle
identity with `pgrep` after it, **zero instances at the end**, and her `/Applications` app was never
launched, quit or touched.

### THE TWO REDS IN THE FULL SUITE, ADJUDICATED (the paired protocol, not assertion)

1. **`BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock` (`live.count → 0`)** — **row 58's
   recorded environment red**, named in this phase's baselines. RED isolated on my tree too, which
   is the condition the row describes; UNIT G proved it red on the PRE-UNIT tree across six runs in
   warm DerivedData, and this run reused that same warm `13u3f`. Not mine.
2. **`ModeSwitchCarryTests.aBlockAtTheTopOfWriteArrivesAtTheTopOfRead` (`wrote → 3.5106` vs `≤ 0.02`)**
   — **GREEN isolated on my tree** (2.816 s), together with its two neighbours in the same suite.
   A load flake of the row-49 family, and my diff cannot reach it: the only file I touched anywhere
   near Read is `NoteIndexColumn.swift`, where one `Menu("…")` label was replaced by the constant
   holding the byte-identical string. **New member of the flake list — handed up, not carried.**

### FINALS (2026-09-19)

- the FULL Mac suite — **Test run with 2889 tests in 482 suites failed after 737.191 seconds with 4
  issues** — the 4 issues are the 2 suites adjudicated above (2 issues each). Baseline 2880/481 + 9
  new cells in 1 new suite = exactly 2889/482.
- the TUTORIAL SPINE — **green in the full run** (all 11 `Tutorial…` suites passed; neither failing
  suite is one of them) and green again in an isolated 83/13 run against the edited lesson.
- core `swift test` — **Test run with 1603 tests in 174 suites passed after 54.842 seconds.**
  (Baseline 1603/174, unchanged — core is byte-untouched.)
- iOS build — **BUILD SUCCEEDED** (`VariorumMobile`, iPhone 17 Pro simulator).
- lockstep marker — **8**, untouched. Schema: ZERO. Migrations: ZERO. `Sync/`: ZERO.
  `Persistence/`: ZERO. `Server/`: ZERO. `Sources/`: ZERO. `BlockRangeIndex`: ZERO.

### MOBILE PARITY (a note, not a build — the brief's rule)

**Nothing mobile-visible shipped, and the phone owes nothing here.** Every line is Mac-side
(`App/Variorum/Variorum/**`) — no `Shared/`, no `Sources/`. The phone has no Takes board and no
takes panel of this shape; its own take surface is the mobile catch-up's. One row for that catch-up
if it ever wants it: the take-card grammar is now a COMPONENT on the Mac, so the phone's equivalent
should compose one list rather than copy four buttons — the drift this unit closed is exactly the
one two hand-typed copies produce.

### THE RE-SEED CONSEQUENCE (the closeout's list, as the brief asks)

**This unit edits three seeded lesson texts and one seeded take**, so her installed store's field
guide still carries the OLD words until it is re-seeded: the takes-delete paragraph, the practice
take's own text, and the trio lesson's two sentences. `Help ▸ Restore Tutorial… ▸ Replace` is the
door (I used it in the walk and it worked cleanly). This joins UNIT E's re-seed note on the
closeout's list — one re-seed covers both.

### FOUND, NOT MINE (handed up rather than carried)

1. **A new member of the load-flake family:** `ModeSwitchCarryTests.aBlockAtTheTopOfWriteArrivesAtTheTopOfRead`
   fails under full-suite load and passes isolated (measured both ways above). It is not on the
   recorded flake list; it should be, beside rows 49 and 58. **Owner: the landing/settle family
   (KnownIssues 12).**
2. **The Snippets vocabulary is stale in prose OUTSIDE the ⋯ sweep.** The *"pool & scraps"* lesson
   says *"the Snippets area's pool menu switches between pools"*, while the shipped surface speaks
   **groups** (`SnippetsCopy.groupsHeader` / `newGroup` / `bulkMove`, and `SnippetsCopy.groupCreated`
   is its receipt). I did not touch it — no ⋯ sentence names it, and one unit is one surface — but
   it is the same copy-truth class this unit just closed twice, and a sweep of that chapter against
   `SnippetsCopy` would settle it. **Owner: a faces batch or a 17 entry.**
3. **A stale comment in the tutorial walk suite:** `TutorialWalkTests:2472` says *"MOVE OUT — Blocks
   (⌘5), the row's ⋯ menu"* while the mode is ⌘6 (the lesson itself says ⌘6). A comment only; not
   worth a commit of its own, and stating it is cheaper than leaving it for a reader to trip on.

### ONE THING I GOT WRONG, STATED PLAINLY (the checkpoint protocol, breached)

**Piece 2's commit `17257f35` carried a RED suite.** I wrote all nine pins in one file before
measuring — which is what gave the clean 12-issue red-on-old table — and then committed the door's
fix while the refusal and words cells in that same file were still red, because their fixes were
pieces 3 and 4. The tree was green again two commits later (`8be360f2`), so the window is
`17257f35`…`c86e7f40`, but "commit per piece" means a GREEN tree per commit and I should have split
the pin file by piece or held the commit. Recorded rather than hidden; no history was rewritten.

### DEFERRED / NOT MINE (stated rather than done)

- **A receipt for a landed take delete** — QUESTIONS #125(b), hers. The shipped behaviour (silence)
  is what I left, on both surfaces.
- **`.lastActiveVariant`'s wording**, which reads as the take→block-below door's sentence. It is
  unreachable from this door (the chosen check fires first) and re-wording a shipped string for a
  path she cannot take would be the drift class, not a fix.
- **The Blocks-mode and Read-index row menus' other rows** — I touched exactly one label there, and
  only to give the lesson a constant to quote.
- **Not touched:** UNIT A1's gutter, A2's comments panel, B's card family, C's capture boxes, D's
  savepoint names, E's confirm, F's PDF, G's ceremony sheets, every operation in
  `Operations+Deletion.swift`, the schema, the marker, and the whole of `Sources/`.

---

## UNIT H CLOSED — 2026-09-19

The board's take cards can act on their own takes. `TakeCardMenu` is ONE component with ONE row
list, rendered by Write's panel — whose four buttons it was extracted from byte-for-byte — and by
every live take card on the Takes board, in all four fan styles, through a single optional on the
header both card shapes already composed. The board declares the three acts it had never declared,
and a PER-SURFACE pin holds it where the union walk structurally could not. The refusal that door
meets most often stopped printing a raw enum with a UUID in it and now names both roads out. The
lesson that sends a reader to that door names the row by the row's own title and says where the
menu is; the ⋯ sweep found a second stale sentence — a row renamed at the Snippets ruling with a
shipped pin holding the old name in place "verbatim" — and that row is one constant now, quoted by
the lesson and consumed by both menus that render it. **Ledger row 8b flipped in this commit.**
Commits `14ae400c` → this one. QUESTIONS **#125** carries the two PROVISIONALs.

## THE ORCHESTRATOR'S PHASE ACCEPTANCE WALK (2026-09-19 — hands-on, the dev-store Debug build at 13u3f/HEAD; captures `orch-01`…`orch-12` in `notes/plans/13u3-screens/`; quit by bundle identity, zero instances verified after)

**VERDICT: THE PHASE'S SPINE PASSES IN USE.** One pass over the core flows, on top of the
implementers' per-unit walks (each verified by record at its close):

1. **C** — the shelf bar TEACHES its two keys on screen; a two-paragraph capture TYPED with ⇧⏎
   filed on ⏎ and opened as **block 1/2** (the bulk rule) with the adopted title on the masthead
   (`orch-02`…`orch-05`).
2. **B** — the title-suggestion CHIP offered the first words, one click adopted (`orch-03`); the
   Library's List and Notes cards lead per the rule with the 18h stamps intact (`orch-11/12`).
3. **D** — ⌘S opened the name field (its two-key teaching line legible), a typed name filed, and
   the quiet-bar receipt spoke it: *Committed "before the walk edit" — an immutable savepoint of
   this take.* (`orch-06/07`).
4. **A2** — the comments panel opened as ONE writing surface (the empty panel is all writing
   area, caret live, ⏎/⌘⏎/⎋ taught in the footer); a comment typed straight in and filed with
   ⌘⏎ (`orch-08/09`).
5. **A1** — the filed comment rendered as a margin card IN THE GUTTER at the block's first line,
   and the prose column's left edge is pixel-identical across `orch-05/07/10` — the one law,
   watched happening.
6. **F** — verified by the KEPT ARTIFACT read directly (`F-exports/F-after-callout-note.pdf`):
   headings/bold/italic/strike/lists/code/links all RENDER; the one syntax survivor is exactly
   #123(b)'s `> ` lead.
7. **E · G · H** — accepted on their implementers' walk evidence + my record verification (E's
   14 captures incl. the confirm-told-the-truth pair; G's hand-staged two-instance drift race;
   H's 17 captures incl. the refusal and put-back), not re-staged: E/G need staged stores my
   pass would only re-create, and H's door was traced by me at adjudication.

**Two walk notes, recorded not fixed:** (a) after adopting the chip, my FIRST ⏎ did not file
(the retry filed normally; ambiguous focus-vs-app, unreproduced — if the ladder finds a
mechanism in the chip's focus handling, it is real; otherwise environment); (b) a card whose
ADOPTED title equals its first words repeats them in the preview line — the carries-on dedupe
covers the derived lead, and no ruling covers explicit-title-equals-opening; logged beside #119
for her taste pass, not a defect.

## THE MORNING CHECK-IN (2026-09-19 — author present; one ruling)

- **R-13u3-7 — #122(a) RULED "AS BUILT".** Her word at the check-in (*"ask me #122a as a
  question, but I think it sounds like it's fine"* → she selected "As built (Recommended)"):
  the restore confirm names the REAL cost (savepoints · deleted takes · deleted comments, in
  numbers) and keeps computing the set-aside-originals count as a TRIPWIRE that speaks only if
  a future change ever makes that loss real. The #80(e) analysis is corrected by E's
  measurement; her original keep-as-built ruling stands on the corrected ground. #122(b)–(f)
  remain PROVISIONAL on her ordinary ratify list.


## PHASE CLOSEOUT (2026-09-19)

**Every ledger row is DONE or owned; nothing deferred silently.** Eight units (A1 · A2 · B · C ·
D · E · F · G + the in-phase H), each closed on its own record with LIVE STATUS, red-on-old
where defect-shaped, and its implementer's walk; the orchestrator's acceptance walk passed the
spine in use; a two-round ladder with the full cross-model flow closed clean (the record-hygiene
note honored: round 1's R1-3 disposition sentence — "each speaking the exact `lockedPost`
sentence the post-⏎ road speaks" — was FALSIFIED at the Write door and corrected by round 2's
R2-1; quote it only with that correction).

**Finals:** core `swift test` **1604/174** green · the FULL Mac suite **[FINAL-MAC]** (the
closing run; the tolerated reds are row 58's environment condition — now carrying G's
warm-DerivedData covariate — and the row-49-family load arms under the paired protocol) ·
tutorial spine green in-run · iOS build green · the FULL mobile suite **626/106 PASSED with 4
known issues** (its two star-cap reds fixed in-phase, pre-existing since 13u2b) · lockstep
marker **8** · **zero `Sync/` · zero `Persistence/` · zero schema · zero migrations · zero
`Server/`**.

**Canon deltas applied (exactly her rulings, `9832175e`):** AppSpec §9 `renameCommitPoint`
(R-13u3-1) · SyncSpec §6's one-field bend (`commit_point.message` = editable metadata CAS) ·
AppSpec §12's gutter law (R-13u-9 built; R-13u3-3…6) · §14's 13u3 block, 13u1's rolled verbatim.

**KnownIssues:** rows 42 + 50 RESOLVED and removed. Filed this phase, each owned: the indicator
ring (13u4) · the AppKit-modal confirm (13u4) · the "pools" lesson vocabulary (13u4) · Block
History's seal-blind rename field (13u4) · the pad's close-loss (17b) · Canvas's focus wire
(17e) · the chip-wrap manifest sensitivity (12) · row 43's 178-key member + row 49's new flake
member + row 58's warm-build covariate (12, cell extensions).

**MOBILE PARITY:** PL-25…PL-30 (`notes/MobileSoul.md`) — the capture row PL-27 flagged
highest-value on her own lost-prose evidence.

**HER RE-SEED (one act):** `Help ▸ Restore Tutorial… ▸ Replace` in the refreshed build delivers
E's new lesson + H's corrected takes lesson (+ the 18f-era corrections already owed).

**THE REFRESH (R-13u3-2, pre-authorized):** WAITS on a zero-instance window — her app was
relaunched during the closeout and is NEVER touched by a session; at her word/quit, the standing
rails run (A1 backup first · Release from a clean worktree · hashes + codesign recorded · zero
instances verified at every step). Evidence lands in the handoff when it runs.
