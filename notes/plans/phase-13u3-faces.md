# Phase 13u3 — FACES (EXECUTION PLAN)

**Status: READY — THE NEXT 13u PHASE since 2026-09-15 (13u2 CLOSED that night; the baselines and
the "what 13u2 changed under you" section at this file's end were refreshed at its closeout).
Authored 2026-09-14 at the 13u1 kickoff (the R-cor-12 four-way split; the shared sitting's rulings
live in `phase-13u1-editor-seam.md`'s SITTING RECORD and bind here). Opens at her word.**
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
