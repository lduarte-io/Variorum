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
| 2 | UNIT A1 — the gutter geometry rework (item 3's page half + KnownIssues row 50) | OPEN — the memo is the design; brief below |
| 2b | UNIT A2 — the comments panel as a text editor (item 3's panel half, memo §2 D) | NOT STARTED — after A1 |
| 3 | UNIT B — note-list skimmability (item 4) | NOT STARTED |
| 4 | UNIT C — the quick-capture Mac face (item 9 / R-13u-4) | NOT STARTED |
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
| 1 | `ProseGutter` — the ONE gutter brain; both contained surfaces + Write adopt it; `DecorLane` retires | PENDING |
| 2 | the four HOST cells converted (bleed + preset), the host table proved byte-identical | PENDING |
| 3 | the decoration geometry: wash hugs the prose, the R-13u3-3 stack, the badge that never covers prose, the card rhythm | PENDING |
| 4 | the R-13u3-4 one-grapheme guard | PENDING |
| 5 | pins (one-law · stack · rhythm · grapheme), `BlockDecorLaneTests` retired INTO successors | PENDING |
| 6 | KnownIssues row 50 RESOLVED + QUESTIONS #117 | PENDING |
| 7 | the walk + captures, the full Mac suite, iOS build | PENDING |

### THE HOST TABLE (the sweep — every host of `BlockDecorOverlayController`, plus every host of a contained surface)

*(filled as each cell is converted — the arithmetic proof lives here)*

