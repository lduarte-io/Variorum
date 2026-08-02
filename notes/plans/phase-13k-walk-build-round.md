# Phase 13k — The Walk's Build Round (formatting ergonomics, cards & the bar)

**Status: ACTIVE from 2026-08-02 — opened by the AUTHOR HERSELF at the
tail of the 2026-08-01/02 housekeeping session** (the 9d/QoL
precedent, but at her explicit instruction with FULL phase
discipline): *"you can go ahead and /architect-phase on these items
that have accumulated this session … let's get these items done
though and then i'll kick off 13e. make sure to follow normal phase
rules - give yourself a phase name (like 13k or something, wherever
we are …) let's bring real phase discipline to these issues."*
The name is **13k** (13j exists — Deletion & the Trash; 13k is next
free).

**Cast (the recent standing shape, adopted unless she redirects):
Fable architect/orchestrator (the housekeeping session itself) · a
FRESH Opus implementer per batch · ONE Fable cold reviewer at phase
end, standard ladder.** The author is PRESENT for this phase's
sittings — it opened inside one.

**Baselines at open (13g's finals, verified by that phase's own
runs):** core 1001/110 · Mac 1139/197 (ONE recorded environment-gated
tripwire red on unlocked sessions — the `TakePaneMeasureTests` row in
KnownIssues; 13e owns its A47c re-run) · mobile 14/4 · tutorial spine
51/7.

**Scope guards, binding:** NO schema anywhere in this phase (every
row is faces / read-side projections / editor input / Domain
vocabulary — if any row turns out to want a schema change, STOP: that
is a SyncSpec §12 lockstep event and hers to authorize). Zero
`Sources/VariorumCore/Sync/` lines expected (the standing rider
routes any exception to Fable). `renderedText`, export BODY
projections, and the bridge's join brain stay byte-untouched except
where a row explicitly says otherwise (K1 touches DISPLAY-title
surfaces only — titles have never been body content).

**What is deliberately NOT here (stays 13e's):** W26 (the system-wide
quick-note hotkey — her deliberate slotting, "so that i'm sure to
land on it again"); the kickoff-sweep rows (windowless capture-first ·
note-window top-clip · the A47c tripwire); the E1 swatches/real-emoji-
picker work beyond the two riders pulled here; the 13e ledger proper
(A13(b), A17–A21). Fenced ``` code blocks stay WANTED-LATER
(recorded in the 13e plan; not scope here or there).

---

## The binding principles (the 13b constitution, copied verbatim per the `/architect-phase` skill; the skill's application notes bind by reference)

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

## Environment traps (bind by reference + the invariant core)

The 13c plan's "Environment traps" section binds VERBATIM, as every
phase, PLUS the two 13g standing rules: **never address a Variorum
instance by process name** (bundle id `io.lduarte.Variorum` /
`io.lduarte.Variorum.debug` or PID only — the batch-1 incident rule)
and **Mac test runs use the cwd-independent `-project` invocation**
from `App/Variorum/`, suite-level `-only-testing` only, always
confirming the "Test run with N tests" line. Instance checks:
`pgrep -fl 'Variorum.app/Contents/MacOS'` discriminating by PATH;
NEVER quit/kill a real-store instance; no Release builds or
`/Applications` refreshes while one lives; A1 backup before ANY
real-store touch; zsh `pipestatus`; never a custom build
configuration; never `git checkout` over uncommitted work; never
push. The known tripwire red (`TakePaneMeasureTests`, unlocked
sessions) is RECORDED at each acceptance, never papered over.

## THE KICKOFF RECORD (the housekeeping session, 2026-08-01/02)

The phase's rulings all landed in that session, recorded same-turn:

- **The #49–#52 walk** ran early and in full — verdicts verbatim in
  `notes/plans/phase-13e-takes-block-management.md`'s "THE WALK RAN
  EARLY" section and QUESTIONS.md's #49–#52 status lines. #49, #50
  ratified whole; #51/#52 rulings below became this phase's ledger.
- **Her closing rulings (2026-08-02, the kickoff message):** smart
  books SHOW on note cards (*"the number of specifically defined
  smart books you have is probably small, no? you still have to
  choose to deliberately create a smart book"*); pools show their
  created day (*"i think that would be helpful"*); `2026-08-01`
  format stands (*"easier to scan than august 1, 2026"*); tag cards
  *"should fold into the bar if you deliberately choose that but it
  should default to visible"*; chips *"should show leaf only"*;
  block-menu fire-and-speak *"is good i think"*.
- **Pulled from the 13e additions at her word** (*"maybe some of
  what's riding 13e should come in here as well … maybe even handle
  one of the 13e sittings we talked about but that ended with
  uncertainty"*): the context/nav bar bundle (the uncertainty-ended
  conversation — tags placement), the takes-callout rendering rider,
  and the code tint.

## THE LEDGER

| Row | Item (ruling, her words where quoted) | Batch | Status |
|-----|----------------------------------------|-------|--------|
*(Batch 1 status, 2026-08-02: **K1 K2 K3 K4 K5 K6 ALL SHIPPED** — K4 stopped
at its proposal gate, was APPROVED as proposed, and was wired in the
continuation; both halves are in the batch-1 record below.)*

| K1 | **The #52(a) retirement:** literal "Untitled" is a TITLE again — only a BLANK/nil title counts as no title; NO sweep (*"i can delete them or rename them myself"*); the ⌘N nil-mint half STANDS (new notes still store no title and show dates until named) | 1 | **SHIPPED** (`cf06c91` + `042e11c`) |
| K2 | **Nameless pools show their created day** (*"i think pools can show their created day, i think that would be helpful"*) — the `DisplayTitle` chain gains the pool's `created_at` local-day fallback; pools still have no `entry_date` | 1 | **SHIPPED** (`cf06c91` + `042e11c`) |
| K3 | **Tag chips display LEAF ONLY** (*"chips should show leaf only"*) — the #52(e) alternative as ruled: leaf shown, full path in the tooltip, color stays keyed on the WHOLE path (two different `…/goals` stay distinct colors) | 1 | **SHIPPED** (`cf06c91` + `042e11c`) |
| K4 | **Note cards show SMART-book membership too** — her ruling reverses the shipped curated-only #51(c). Mechanism is MEASUREMENT-FIRST under P1: smart books are few and deliberately created (her ground); bounded per-row evaluation (per-note tags + profile + entry_date vs each smart spec), measured at design-corpus scale with a corpus-scale guard (cap or async fill) if the numbers say so. **IN-BATCH PROPOSAL GATE:** the implementer proposes mechanism + measurements BEFORE wiring; the architect rules | 1 | **SHIPPED** (`cf06c91` + `042e11c`) |
| K5 | **⏎ list continuation:** ⏎ at the end of a texted list line mints the next lead (`- ` or `- [ ]`); ⏎ on an EMPTY list item removes the lead and exits the list. Ordinary edits through the ordinary input path — ⏎'s ratified STRUCTURAL semantics (open-tail at document end; one_block's newlines-don't-mint; A15's ⇧⏎) are byte-untouched: continuation only adds lead TEXT where the newline landed. Edges the build must pin: document-end open tail; one_block mode; sealed/locked refusal rides the edit path; ⌘Z ungroups cleanly (newline+lead undo together) | 1 | **SHIPPED** (`cf06c91` + `042e11c`) |
| K6 | **The right-click Callout door:** the editor context menu gains the Callout submenu beside Format (today it lives only in the menu-bar Block menu + ⌥⌘C; she went looking for it in the right-click — 2026-08-01). Registry-declared (P-1); same routed transform as every other door (13c R2-2's letter) | 1 | **SHIPPED** (`cf06c91` + `042e11c`) |
| K7 | **The formatting toolbar — BOTTOM BAR** (*"i think the formatting toolbar should be added to the bottom - if i decide it's too cluttered later i'll remove it then, i think other users would need it though"*): the seven formatting acts as visible buttons riding the bottom bar's standing two-group grammar; every button the SAME registry act as the menu (P-1 — no second brain) | 2 | **SHIPPED** (`1324def`) |
| K8 | **Indented/nested lists — Tab indents** (*"we should allow indented lists and it should happen when you click tab"*): a vocabulary extension — the line-scoped tokenizer's column-0 rule widens to leading-space list lines (Domain: `MarkdownSyntax`/`MarkdownRendering`; face + Read rendering follow; display==stored holds byte-for-byte). UNINDENT door: ⇧Tab + Format ▸ Indent/Outdent rows PROPOSED to her (she knows ⌘[ is taken; she floated *"maybe if you click in it's an option?"*) — **RULED, round 2: ⇧Tab + Format ▸ Indent/Outdent rows** | 2 | **SHIPPED** (the continuation) |
| K9 | **Callout frames RENDER in Take mode** (her 2026-08-01 instruction: *"callouts are supposed to be added to take mode as well"*) — today the frame draws only in Write's `BlockDecor` overlay; the setting door already routes from the boards (13c R2-2). Shape — **RULED, round 2: ONE frame around the block's whole takes region** (one block, one frame, takes inside it — R16/R27's letter) | 2 | **SHIPPED** (`1324def`) |
| K10 | **The code tint** (*"code blocks should have their own tint - i'll rule on that"* — inline `` `code` `` SPANS; fenced blocks are wanted-later, NOT here) — **RULED, round 2: a faint per-voice TINTED CHIP hugging exactly the span** (never block-wide — visibly distinct from callout frames); specific swatches proposed at the batch's visual loop for her flick | 2 | **SHIPPED** (`1324def`) |
| K11 | **The context/nav bar redesign** (pulled from the 13e additions): ALWAYS the compact icon row — her screenshot: ← · book · ＃ · › — no spelled-out back chip, no collapse/grow (*"the collapsing and growing in that bar is a little annoying to me"*); the › chevron becomes a REAL forward door (⌘]'s face — *"after you just went back, i feel like you should be able to go forward"*); "in xyz book" becomes a BOOK ICON (click = the book when exactly one; *"command click on lets you see the list of books (or there's a dropdown if there's several books it could be in)"*); tags placement — **RULED, round 2: the leaf-only chips ride the compact row beside ← book ›, VISIBLE at rest; ＃ is the deliberate fold/unfold door** | 3 | pending |
| K12 | **Tag cards DEFAULT VISIBLE** (#52(d) flipped: *"tag cards should fold into the bar if you deliberately choose that but it should default to visible"*) — folding becomes a deliberate, sticky user choice, not the bar's default state; reconciled with K11 by the Q1 ruling | 3 | pending |

## Batch structure (one FRESH Opus implementer per batch, strictly sequential)

- **Batch 1 — the fully-ruled set: K1 K2 K3 K4 K5 K6.** No open
  rulings; K4 carries its in-batch proposal gate (propose → architect
  rules → wire). Brief: the ledger rows above ARE the brief, plus:
  K1/K2 live in the `DisplayTitle` brain (13g batch 7 — find via
  grep; every view + export surface consumes it; K1 additionally
  re-verifies the 13g export-heading tests against the new rule);
  K3 in the tag-chip face (13g batch 6/7); K4 in the Library list's
  card assembly (13g batch 6) + a Queries-side bounded read; K5 in
  the editor input path (TEXTKIT2_NOTES binds; the A15/⇧⏎ and
  idle-mint rulings are byte-sacred); K6 in
  `EditorTextView.menu(for:)` + the registry declaration. Every
  behavior change red-on-old; the spine rides every run.
- **Batch 2 — the formatting set: K7 K8 K9 K10** (round 2's rulings
  all in hand). **K8 carries an IN-BATCH PROPOSAL GATE like K4's**
  — it is the one row that extends the STORED vocabulary: before
  building the Domain half, the implementer proposes the exact
  extension — the indent unit (spaces vs a tab character, and
  width), depth semantics (unbounded vs capped), Read's rendering
  of levels, the checkbox click-target at depth, and Tab/⇧Tab
  behavior OUTSIDE list lines (which must stay byte-unchanged) —
  and the architect rules before the build proceeds. **K10** ships
  a defensible default swatch per voice and brings 2–3 alternates
  as a PROPOSE-ONLY set for her flick (screenshots at the visual
  loop). **K9** renders as an overlay (P-8: overlays, never
  rendering attributes).
- **Batch 3 — the bar: K11 K12.** Spawns after Q1's ruling; visual
  loop screenshots for her flick (propose-only on look details).
- **The ladder:** ONE cold review at phase end over the combined
  diff, fresh reviewer, `notes/REVIEW_PROMPT.md` verbatim, standard
  rounds/cap.

## SITTING RECORD

### Round 1 (2026-08-02, the kickoff — rulings recorded above)

All of "THE KICKOFF RECORD" is round 1; her verdicts are in the
ledger rows and the 13e plan's walk section. Recorded same-turn,
repo-first.

### Round 2 (2026-08-02, same sitting — the question batch ANSWERED; all four on the recommended option)

- **Q1 (tags & the bar):** CHIPS BESIDE THE ICONS — the leaf-only
  colored chips ride the compact row next to ← book ›, VISIBLE at
  rest; the ＃ icon is the deliberate fold/unfold door. (Resolves
  her 2026-08-01 conflictedness: tags DO move to the bar, in the
  visible-by-default form her #52(d) ruling requires.) → K11/K12.
- **Q2 (code tint):** a TINTED CHIP BEHIND THE SPAN — faint,
  per-voice, hugging exactly the code span; never block-wide (the
  geometry stays visibly distinct from callout frames). Specific
  swatches PROPOSED AT THE BATCH's visual loop for her flick
  (propose-only on the look details). → K10.
- **Q3 (unindent):** ⇧TAB + Format ▸ Indent/Outdent menu rows
  (the platform pair; the ⌘[ conflict never arises). → K8.
- **Q4 (takes frame):** ONE FRAME AROUND THE FAN — the callout
  frame (color + emoji) wraps the block's whole takes region; one
  block, one frame, takes inside it (R16/R27's letter). → K9.

Batches 2 and 3 are UNBLOCKED; they spawn sequentially after
batch 1 closes (one implementer at a time, the standing cap).

## Batch records

*(appended per batch by the implementer, verified by the architect —
counts by the architect's own runs at every acceptance)*

### Batch 1 record — the fully-ruled set (2026-08-02, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on
the final tree, AFTER K4's wiring): core **1016 tests in 112 suites** (from
1001/110: +15 tests, +2 suites — the ⏎ rule and the smart-membership read) ·
Mac **1160 tests in 201 suites** (from 1139/197: +21 tests, +4 suites) **with the ONE recorded environment-gated red**
(`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion` —
this session ran on an UNLOCKED login session, the covariate its KnownIssues
row names; NOT patched, per that row's own instruction that no patch is
allowed without re-running the A47c experiments 13e owns) · mobile **14 tests
in 4 suites** (run because `Sources/` was touched) · the tutorial spine
**51 tests in 7 suites**, green, by TYPE name. **NO schema; zero
`Sources/VariorumCore/Sync/` lines; zero lines near `renderedText`, the
export BODY projections or the bridge's join brain** — the only export edit
is a FILENAME (K2) and a heading rule (K1), both title-side.

**K4 stopped at its proposal gate as briefed, was APPROVED as proposed
(architect adjudication 1, `284fa11`), and was WIRED in the continuation.**
Both halves are recorded below: the gate's mechanism + measurements, and the
wiring with its own reverts. *Counts above are the FINAL (post-wiring) ones.*

---

#### K1 — the literal "Untitled" is a TITLE again · SHIPPED

`DisplayTitle.isAbsent` loses its `|| trimmed == placeholder` clause and
nothing else: **blank means blank** (nil, empty, whitespace-only). The two
halves she left standing are untouched — the ⌘N/New Note mint still stores
`nil` (13g's other half; `NodSetTests.aNewNoteIsMintedWithNoTitleAtAll`
unchanged and green), and **no sweep runs anywhere**, per her words *"i can
delete them or rename them myself"*.

Because the rule lives in ONE brain, the retirement reached every surface at
once: the chrome map, the Library listing, the ⌘K catalog's hit name and its
`storedTitle` (so the rename door seeds "Untitled" again rather than a date),
the timeline/folder/recovery/book listings, and the two export sites.

**The 13g export expectations were re-verified against the new rule, as the
brief required, and TWO were updated on the record** (both stated in QUESTIONS
#53(k)):

| Pin | Was | Now |
|---|---|---|
| `DisplayTitleTests.theBulkManifestNamesAnUntitledNoteByItsDateAlone` (renamed `…NamesANamelessNoteByItsDateAlone`) | a literal-"Untitled" note exported as `2026-07-11.md` | it exports as `2026-07-11 Untitled.md`; a NAMELESS note still exports as `2026-07-12.md` — the ratified 11b convention, unchanged |
| `NodSetTests.theChromeNamesAnUntitledNoteByItsDate` | the chrome said the legacy note's date | the chrome says "Untitled" |

`aReadingExportHeadsAnUntitledNoteWithItsDateNotWithUntitled` needed no change
— it exercises a genuinely nameless note, which is the case her refinement was
about.

**Red-on-old (REVERT A, verified):** putting `|| trimmed == placeholder` back
turns `onlyABLANKTitleCountsAsAbsent` red on its 4th/5th/last expectations AND
takes the four downstream pins with it (the store read, the library listing,
the catalog hit, the manifest) — each reporting the OLD rule's answer by name.
`DisplayTitle.swift` restored, md5 `bf08a0f595c52f32b510caec1038f1e6` matched.

---

#### K2 — a nameless POOL shows the day it was created · SHIPPED

`DisplayTitle` gains `pool(title:createdAt:)` (and its raw-stamp twin), sharing
ONE private `named(_:day:)` with the note rule so a third surface cannot invent
a fourth precedence. The chain is one link shorter than a note's on purpose: a
pool row leaves the post-specific columns NULL (AppSpec §7), so there is no
`entry_date` to consult and the fallback is `created_at`'s LOCAL calendar day
— the same KIND of day `entry_date` is everywhere else (13g's stated reason,
pinned again here with a Tokyo/UTC case).

Wired at every surface that named a pool: `Queries.poolDisplayTitle` (the
`noteDisplayTitle` twin) feeding `WorkspaceModel.resolveTitles`' `.pool` arm;
`PoolNaming.title` (the Blocks area's label and its picker); `RecoveryView`'s
"Place in pool" menu, which now routes through `PoolNaming` instead of its own
`?? "Untitled pool"`; and `bulkExportManifest`'s `Pools/` filename (#53(j) —
the display brain lives in core exactly so the download says what the app
said). `PoolNaming`'s remaining literal is "no pool", which is the one case it
now covers: there is no pool at all.

**Red-on-old (REVERT B, verified):** pointing `poolDisplayTitle` at
`containerTitle`'s bare column read turns
`onePoolsDisplayTitleComesFromTheStoreThroughTheSameBrain` red (nil vs the
day). **REVERT C (verified):** dropping the display brain from the export
filename turns `poolExportsRenderScrapsInPoolOrderWithCollisionHandling` red
with `Pools/Untitled.md`. Both files restored, md5s matched
(`3f5eb0dc98eca9ceb76eb66254072901`, `4f9e7e2bdb3a99f173575db587c5b9c0`).

---

#### K3 — tag chips show the LEAF · SHIPPED

`TagChipLabel.leaf(of:)` — a pure four-line rule beside `TagChipColor`, keyed
on the PATH rather than read off `tag.name`, deliberately: the chip already has
one input, and putting the label rule next to the colour rule is what makes
**"the label narrows, the colour does not"** readable in one place. A
degenerate path (empty, trailing `/`) reads as itself — a chip is never blank.

The full path stays in the chip's tooltip (`.help("Tagged \(tag.path)")`, which
already said it), in the folded glyph's tooltip, in the `＋` adder's suggestion
rows (#53(i) — the adder is a chooser over the taxonomy) and in Settings'
manager. Hierarchy stays surfaced (R45) everywhere except the chip's own face,
which is what she asked for.

**Red-on-old (REVERT I, verified):** keying `TagChipColor.hue` on the leaf
turns `theCOLOURStaysKeyedOnTheWHOLEPath` red with `life/goals` and
`work/goals` at the identical hue `0.9527…`. File restored, md5
`d211afa0919778d3b63b96e4aa68e861` matched.

---

#### K5 — ⏎ continues a list · SHIPPED

**The one safety claim, and it is structural rather than careful:** the
continuation NEVER PLANS THE NEWLINE. `super.insertNewline(_:)` runs exactly
as it always did, so the ratified structural semantics see the same single
typed `"\n"` they have always seen — the open-tail gesture at the document
end, `one_block`'s newlines-don't-mint, the idle-mint, and every refusal — and
the lead is a SECOND ordinary insertion at the caret the newline left, through
the same `shouldChangeText` → `replaceCharacters` → `didChangeText` trio
typing takes. (Planning `"\n- "` as one replacement would have made
`verdict(replacing:replacementIsSingleNewline:)` stop recognising the
keystroke — that is the reason the Domain function returns a LEAD and not an
edit.)

- **Domain:** `MarkdownEditing.ReturnKey` + `returnKey(inLines:at:)` — the
  `checkboxToggle` shape (whole lines in, offsets relative to them). Three
  verdicts: `.ordinary`, `.continueList(lead:)`, `.exitList(lead:)`.
- **Face:** `MarkdownActs.insertNewlineContinuingLists(in:ordinary:)`, taking
  the surface's own `super` call as a closure, plus `listReturn(in:)` which
  rebases the Domain's line offsets into the note's.
- **Doors:** `EditorTextView.insertNewline` and `PaneTextView.insertNewline`
  (#53(f) — R118 parity; the pane gained the same `isSoftNewline` keyDown
  latch `EditorTextView` has carried since 13d, reusing its
  `isSoftNewlineKey` decision).
- **The lead lands only if the newline did** — a refused ⏎ leaves the storage
  byte-identical and leading a line that was never created would be inventing
  text (the length check is the guard).
- **The exit half is the ONE place the keystroke is consumed**: no newline at
  all, just the lead of an empty item going away — an in-line edit that can
  never touch a seam.

The build-time calls are #53(a)–(f): end-of-line only, ⇧⏎ excluded, headings
excluded, continued checkboxes born unchecked, the exit deleting exactly the
lead, and the pane parity.

**Red-on-old, four reverts, each verified and checksum-restored:**

| # | Revert | Result |
|---|---|---|
| D | drop the `.continueList` arm's lead insertion | RED on the four continuation pins (`aTextedBulletMintsTheNextLead`, `aTextedChecklistItemMintsAnUncheckedBox`, `theDocumentEndTailGestureStillFires…`, `oneBlockKeepsBothTheNewlineAndTheLead…`); the exit, ⇧⏎, sealed and prose pins stay GREEN — exactly discriminating |
| E | the `.exitList` arm falls through to `ordinary()` | RED: `anEmptyListItemExitsTheListWithoutMakingALine` (`"- milk\n- \n"` — the empty item survives) + the pane's own arm |
| F | drop the `isSoftNewline` guard from `EditorTextView.insertNewline` | RED: `shiftReturnNeverContinuesTheList` — ⇧⏎ starts sprouting bullets |
| G | drop the `beginUndoGrouping`/`endUndoGrouping` pair | **GREEN — the pin does NOT discriminate it, and that is recorded rather than claimed** (below) |

**REVERT G, the honest one.** The brief named "⌘Z ungroups cleanly" as an edge
to pin, and the pin is green — but removing the explicit undo group leaves it
green too, because `NSUndoManager.groupsByEvent` is on by default and both
edits happen inside ONE key event, so AppKit's own per-event group already
holds them. The explicit group is therefore **redundant today**. It is kept
deliberately (it states the intent where the two edits are made, and does not
depend on an AppKit default staying true), and the pin's doc comment now says
exactly this instead of claiming a red it did not get — the hallucination
guard's rule applied to my own work. `MarkdownActs.swift` restored, md5
`a311dd044954e7dd863ef880b27b85a5` matched; `EditorTextView.swift` md5
`c8864a76274554df9d1a98aeed45e5e2`.

**What the pins cover beyond the two halves:** the document-end tail gesture
still fires and the lead lands in the TAIL as ordinary tail text (nothing
minted, surface-only — byte-identical to the ratified gesture); `one_block`
keeps both the newline and the lead as content; a SEALED note refuses the
whole keystroke without touching a byte, with no new refusal code; plain prose
is untouched; and the pane does all three.

---

#### K6 — the right-click Callout door · SHIPPED

`CalloutMenu` declares the submenu's rows ONCE (toggle · the five palette
colours · Emoji… · Remove) and owns the emoji `NSAlert`, and **three doors now
render from it**: the menu bar's Block ▸ Callout (refactored to read the rows,
⌥⌘C still on the toggle row), `EditorTextView.menu(for:)` beside Format, and a
take card's context menu via `TakesShared.menuSpecs`. The registry declaration
gains `.contextMenu`; both renderers declare `.callout` in their own
`contextMenuCapabilities`, so the walk's union covers it and a future edit that
drops one fails by name.

**The act is unchanged** — every row runs the same `applyCallout`
(`updateBlockPresentation` on the block, 13c R2-2's routed transform). Two
build-time calls: #53(g) (the card's right-click carries it too; Compare's
panes have no Variorum menu at all today and are untouched) and **#53(h)**,
which was a real hazard rather than a preference: a right-click does not move
the keyboard, so `TakesViewModel.applyCallout`'s `commandTargetSlot` would have
framed whichever card was last FOCUSED. It gained an optional explicit
`blockID:` (defaulting nil = the long-standing behaviour, so the routed door is
byte-unchanged) and the card menu passes its own `slot.blockID`.

**Red-on-old (REVERT H, verified):** dropping the `calloutMenuItem` wiring from
`EditorViewModel.attach` turns `theEditorsRightClickCarriesTheCalloutSubmenu`
red at its `#require` — a Format submenu and no Callout one, which is exactly
the state she reported. File restored, md5
`0c8fd7e526e7cb5aa1b946fe9a95186b` matched.

---

#### K4 — WIRED · SHIPPED (the continuation, after the architect's approval)

**The approved mechanism, built exactly as proposed:**
`Queries.smartBookMembership(_:postIDs:)` beside `readingsContaining` in
`ShelfQueries.swift` — one statement per live SMART book, restricted to the
page, reusing `smartMatchSQL` verbatim; **no cap, no async fill** (the
book-count guard is recorded DECLINED — corpus size is provably not the
variable). `NoteCards.load` merges it into `Card.books`, and the shipped
"the books are CURATED memberships" paragraph is rewritten to state the new
rule, why the earlier reading was right about the *obvious* query and wrong
about the necessary one, and the measured cost.

**The statement is split out as `smartMembershipSQL(_:)`** (internal, not
public) for ONE reason: the P1 pin runs `EXPLAIN QUERY PLAN` over the REAL
statement rather than a copy of it that could drift from what ships.

**The P1 pin is the PLAN, not a clock — stated, since the architect left the
call to me.** The gate's measurement already established the numbers; a
timing pin would restate them noisily and flakily, while what *makes* them
true is the join ORDER. So `thePAGEDrivesAndTheContainerIsAPrimaryKeySeek`
asserts three things about the shipped statement's plan: the page is the
outer loop (`SCAN j VIRTUAL TABLE …` first — SQLite names the ALIAS, which
the pin's comment records), the container is reached by
`sqlite_autoindex_container_1`, and `idx_container_kind` does **not** drive
it. That is precisely the regression the gate caught, so the pin guards
precisely it.

**Red-on-old, two reverts, each verified and checksum-restored:**

| # | Revert | Result |
|---|---|---|
| J | `smartMembershipSQL` rewritten to the `FROM container c WHERE c.id IN (SELECT value FROM json_each(?))` shape | RED on all three plan expectations — the plan drives from `SEARCH c USING INDEX idx_container_kind (kind=?)`, i.e. the measured corpus scan. `ShelfQueries.swift` restored, md5 `b943bf0c44e16ded8897ba3dddf7e6cc` matched |
| K | drop the `smartBookMembership` merge from `NoteCards.load` | RED: `aCardNamesCuratedBooksFirstThenTheSmartOnesThatCollectIt` fails on the smart-only note (nil books) and the both-books note (`["hand-made"]` only). `LibraryCatalogView.swift` restored, md5 `5084231b9cdfc54586a5cb012c2e088b` matched |

**What else the pins cover.** Core
(`Tests/VariorumCoreTests/SmartBookMembershipTests.swift`, 6 tests): the page's
notes name their books in the readings listing's own `(name, id)` order; **the
bounded read AGREES with `readingsContaining` row for row** (otherwise the card
and the membership chip would tell one note two different stories); an ARCHIVED
note matches no smart book (the ambient-view rule, inherited rather than
re-decided); a malformed spec is skipped fail-closed and an empty page reads as
nothing; and a note NOT on the page is never reported, which is the whole point
of the bound. Mac (`NoteCardSmartBooksTests`, 3 tests): the curated half is
byte-unchanged, the smart half reaches the row, curated names come first, a
name in both halves shows once, and the snippet half is untouched.

**One build-time call added to the OPEN bundle — QUESTIONS #53(l):** curated
first then smart, each alphabetical within itself, with a name appearing in
both halves shown ONCE. Book names have no uniqueness (AppSpec §7), so "Ideas"
curated + "Ideas" smart is reachable; a card row reading "Ideas, Ideas" seemed
worse than the rare ambiguity. Alternatives (one merged sort; show both) are on
the entry.

**One implementation note worth keeping:** `Tag` is ALSO a Swift Testing type,
so both new suites qualify `VariorumCore.Tag` in their tag-seeding helper. Cost
me a compile; recorded so it costs the next session nothing.

---

#### K4 — THE PROPOSAL GATE (mechanism + measurements; the record as it stood at the gate)

**The question.** Her ruling reverses #51(c): the Library's Notes cards must
name SMART books too. The shipped comment says why they did not — *"a smart
book's membership is derived by walking its filter, which is what the
membership chip does for ONE note and must not be done for forty rows (P1)"*.
Her ground for reversing it: *"the number of specifically defined smart books
you have is probably small, no? you still have to choose to deliberately create
a smart book."*

**The proposed mechanism.** `NoteCards.load` already runs two grouped reads
bounded to the listed post ids. Add a THIRD: **one statement per live SMART
book, restricted to the page**, i.e. `Queries.readingsContaining`'s per-post
probe generalised from one post to the page, reusing `smartMatchSQL` (the ONE
predicate implementation the assembly, the Pool and the chip already share):

```sql
SELECT j.value AS post_id
FROM json_each(?) j                       -- the page's ids
CROSS JOIN container c ON c.id = j.value
 AND c.deleted_at IS NULL AND c.archived_at IS NULL AND c.kind = 'post'
WHERE <the spec's own conditions>          -- smartMatchSQL, verbatim
```

**`CROSS JOIN` is load-bearing, and the measurement is what found it.** With
the natural `c.id IN (SELECT value FROM json_each(?))` shape SQLite chooses
`idx_container_kind` as the driver and **scans every post in the corpus** —
measured 4× slower at 10× corpus, i.e. NOT flat, exactly the P1 violation the
shipped comment feared. `CROSS JOIN` is SQLite's own join-order directive: the
page drives, the container is a PK seek. Plan, verified:

```
|--SCAN j VIRTUAL TABLE INDEX 1:
|--SEARCH c USING INDEX sqlite_autoindex_container_1 (id=?)
`--CORRELATED SCALAR SUBQUERY 1
   |--SEARCH pt USING INDEX idx_post_tag_post (post_id=?)
   `--SEARCH t USING INDEX sqlite_autoindex_tag_1 (id=?)
```

**The measurements** (this session's own runs; `sqlite3` over a COPY of the
DEV store — her real store was never opened — and over a 10× clone of it built
in the scratchpad; 200 reps per figure, ms per PAGE LOAD = all books):

| page | books | 235 posts (design corpus) | 2,170 posts (10×) |
|---|---|---|---|
| 40 | 1 | **0.05 ms** | 0.05 ms |
| 40 | 5 | 0.20 ms | 0.25 ms |
| 40 | 10 | 0.45 ms | 0.50 ms |
| 40 | 25 | 1.10 ms | 1.20 ms |
| 200 (the listing's real window) | 1 | **0.15 ms** | 0.20 ms |
| 200 | 5 | 0.80 ms | 0.85 ms |
| 200 | 10 | 1.60 ms | 1.80 ms |
| 200 | 25 | 4.15 ms | 4.30 ms |

**Flat in corpus at every point** (10× the posts, the same cost — that is the
P1 claim, delivered by the join order rather than hoped for), and **linear in
smart-book count**, which is her own ground for the ruling. For scale: the
existing curated-books read costs **0.05 ms** per page load on the same corpus,
and this is a ONE-SHOT read on entering `.notes` mode or changing the listing —
never per keystroke, never per scroll.

**Her real numbers today: 1 smart book, 235 live posts → 0.15 ms.** No cap and
no async fill is warranted by the measurement; both were on the table and both
would be machinery for a cost that does not exist. If the architect wants a
guard anyway, the honest one is a **book-count cap with an honest "+k more"**
rather than a corpus check, because corpus size is provably not the variable.

**Recorded corner for the wiring pass:** a `tagsAll` spec costs one EXISTS
probe per conjunct per row, so a 4-tag AND book costs ~4× a 1-tag book. Still
flat in corpus; worth a line in the wiring's comment.

**Proposed diff, when the architect rules (est. ~60 lines + pins):**
`Queries.smartBookMembership(_:postIDs:) -> [String: [String]]` beside
`readingsContaining` in `ShelfQueries.swift` (post id → smart book names, live
smart books only, `smartMatchSQL` reused verbatim, malformed spec skipped
fail-closed exactly as `assembleReading` does); `NoteCards.load` calls it and
merges into `Card.books` (curated first, then smart, each alphabetical — or
one merged sort, a look call); the shipped `NoteCards` doc comment's
"the books are CURATED memberships" paragraph rewritten to state the new rule
and its measured cost; pins for (i) a note matching only a smart book naming
it, (ii) an ARCHIVED note matching no smart book (the ambient-view rule
`readingsContaining` already keeps), (iii) the read staying bounded to the page
— the `MarkdownScanCount` idea in SQL form is a row-count assertion — and (iv)
the curated half byte-unchanged.

---

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` gains #53** — eleven build-time calls, each one line
  to change, properly OPEN. **#54 is now the next free number.**
- **K4 is the only owed decision**; everything else in the batch is ruled and
  built.
- **One inherited red, recorded at every run:** the `TakePaneMeasureTests`
  tripwire on unlocked sessions. Its KnownIssues row forbids a patch without
  re-running the A47c experiments (13e's kickoff sweep owns them), so it was
  left exactly as found.
- **No visual loop was run.** The batch's only new pixels are a submenu (menu
  rows) and a shorter chip label; the callout submenu's own look is the menu
  bar's, unchanged.
- **One thing a reviewer should check by hand when the app is next open** (it
  is pinned through real key events and a real `menu(for:)`, but the last inch
  is AppKit's): right-clicking inside a take CARD and setting a colour, to see
  the frame land on the card you clicked rather than the one you last typed in
  (#53(h)).

### Architect adjudications on batch 1 (2026-08-02, recorded before the continuation)

- **Batch 1 spot-verified by the architect's own runs:** commit
  `cf06c91` whole, tree clean, `DisplayTitle.pool` present at its
  claimed home; core re-run by the architect — `Test run with 1010
  tests in 111 suites passed` — matching the implementer's quoted
  line exactly. (A stale SourceKit index briefly flagged
  `DisplayTitle.pool` missing in the tests; refuted by grep + the
  green build.) Full Mac/mobile/spine own-runs ride the batch's
  CLOSE, after K4's wiring.
- **K4 WIRING: APPROVED as proposed.** The CROSS JOIN page-driven
  shape is the mechanism (the measurement caught the IN-subquery
  corpus scan — exactly the P1 class; the finding is the proposal
  gate earning its cost). **No cap, no async fill** — flat-in-corpus
  proven at 10×, her real scale measures 0.15 ms one-shot; the
  book-count cap + "+k more" guard is RECORDED AS DECLINED (corpus
  size is provably not the variable; revisit only on a real
  profile). Standard discipline rides: red-on-old pins, the spine,
  the batch record updated, final counts by own runs.
- **The redundant explicit undo grouping (revert G green): KEEP.**
  Stating intent beats leaning on `groupsByEvent`'s default — AppKit
  defaults are precisely the kind of thing that shifts between
  releases — and the pin's doc comment now says honestly that the
  revert does not discriminate. Disposition: recorded, no change.
  (The hallucination guard was followed to the letter: a
  non-discriminating pin was REPORTED as such, not claimed.)
- **K5/K6 riding the take panes: ENDORSED** — R118/13c-R2-2 parity
  is the standing law ("every surface that knows which block you
  are in"); the ledger's "the editor" wording was narrower than the
  law, and the law wins. Compare's context-menu absence stays
  untouched and unowned by this phase. Her eye rides #53's walk.
- **QUESTIONS #53 (eleven build-time calls) is OPEN and BUNDLED for
  her next sitting** — the away rule; nothing in it gates the
  remaining batches.

### Batch 1 ACCEPTED (2026-08-02 — the architect's own runs, quoted)

- core `Test run with 1016 tests in 112 suites passed` (from
  1001/110 at open)
- Mac `Test run with 1160 tests in 201 suites failed after 143.414
  seconds with 1 issue` — the one issue confirmed **BY IDENTITY**:
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
  (the recorded environment-gated tripwire, unlocked session; NOT
  patched, per its KnownIssues row). Every other suite green,
  the tutorial spine's 7 suites included.
- mobile `Test run with 14 tests in 4 suites passed` — on the
  **iPhone 17 Pro** simulator: the iPhone 16 Pro destination is
  silently INELIGIBLE on this runtime (OS 26.2 sims are the
  eligible set) — the 13d destination-miss trap, caught again by
  the quoted-run-line rule. Future sessions: pick from xcodebuild's
  eligible-destinations list, not simctl's.
- Rows K1–K6 all SHIPPED (`cf06c91`, `042e11c`); statuses flipped
  in the ledger. Batch 2 spawns next (fresh implementer).

### Batch 2 record — the formatting set (2026-08-02, a fresh Opus implementer)

**Counts, from this session's own runs** (the "Test run with N tests" line, on
the final tree, AFTER K8's build): core **1032 tests in 114 suites** passed
(from 1016/112: +16 tests, +2 suites — the callout projection and the nested
lists) · Mac **1176 tests in 203 suites** (from 1160/201: +16 tests, +2 suites
— the formatting surfaces and the nesting doors) **with the ONE recorded
environment-gated red**
(`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
confirmed BY IDENTITY; NOT patched, per its KnownIssues row's own instruction
that no patch is allowed without re-running the A47c experiments 13e owns) ·
the **tutorial spine 51 tests in 7 suites**, green, by TYPE name (the seven
`Tutorial*Tests` types — `-only-testing:VariorumTests/TutorialWalkTests`
selects ZERO tests, since the file's suites are named per chapter; recorded so
the next session does not mistake an empty selection for a green spine) ·
mobile **14 tests in 4 suites** on the iPhone 17 Pro (run because `Sources/`
was touched). **NO schema; zero `Sources/VariorumCore/Sync/` lines; zero lines
near `renderedText`, the export BODY projections or the bridge's join brain**
— verified by name-only diff (`git diff --name-only` touches no
`Persistence/`, no `Server/`, no `Bridge/`, no `Features/Export`, and the one
core file changed is `Queries/TakesQueries.swift`).

**One observation that CORRECTS the record, and it belongs to 13e's sweep.**
Batch 1 attributed the tripwire to an UNLOCKED login session, which is the
covariate the KnownIssues row names. **This session's runs were all on a
session reporting LOCKED** (`CGSSessionScreenIsLocked = 1`, checked before and
after the full Mac run) **and the tripwire fired anyway.** So "unlocked
sessions" is NOT the discriminator — the row's own covariate is refuted by two
data points now pointing opposite ways. Recorded rather than re-theorized: the
A47c re-run 13e owns is the only honest way to settle it, and this is one more
reason it is owed.

**K8 stopped at its proposal gate as briefed, was RULED on all six calls
(the "Architect adjudications on batch 2" section), and was BUILT in the
continuation.** Both halves are recorded below: the proposal as it stood at
the gate, and the build with its own six reverts. *The counts above are the
FINAL (post-K8) ones.*

---

#### K7 — the formatting toolbar, in the bottom bar · SHIPPED

`App/…/Features/Formatting/FormatBar.swift` — one small view, rendered by
BOTH bars (`CommitBar.postCluster`, `TakesBottomBar.postCluster`).

**Why both bars, stated because the ledger row said only "the bottom bar":**
the eight acts are `takesAccess: .native` — they run on whichever surface holds
the keyboard — so a visible formatting toolbar in Write's bar and not in the
boards' would privilege Write in exactly the way R118 forbids, and the two
bars have shared one grammar since R6-2. The registry walk enforces it either
way: `theBottomBarsRenderExactlyTheDeclaredBarDoors` compares the UNION of the
two bars' tables against the `.bottomBar` door set.

**It renders EIGHT acts, not the ledger's "seven"** — the ledger's count
predates 13g batch 4's Add Link, and `FormatBar.renderedCapabilities` is
derived from `MarkdownActs.rows` rather than re-listed, so rendering seven of
eight would have been a second list that could drift from the menus. (Build-
time call, #54(a).)

**The one-brain claim, made structural.** `ShellActions.applyFormat`'s body
moved onto **`MarkdownActs.fire(_:status:in:)`**, and the bar's buttons call
that — so the act, its refusal, its LAST-FIRST edit ordering, its single undo
group and its first-responder targeting rule are literally the menu's. The
context menu keeps its own door, deliberately: a right-click already knows the
view it happened in. `fire` takes its window as a defaulted parameter
(`NSApp.keyWindow`) for ONE reason — a headless test host's window is not the
key window, and a door whose target cannot be named in a pin would have to be
trusted instead of proven.

**The face.** The bar's grammar is quiet clickable words (R101), so these are
words set in the format they apply — a bold **B**, an italic *I*, a struck S, a
monospaced backtick, "link", an `H ▾` menu carrying the three heading sizes,
`•`, `☐`. Verbs and chords ride `.help` FROM the registry (so a tooltip can
never claim a chord the capability does not declare), and the ⌘/ helper gains
a row naming the bar beside the menu paths — WT-1's lesson applied to a door
that would otherwise be discoverable only by looking at it.

**Self-contained, because she said she may remove it:** the file, two call
lines, the `.bottomBar` door on eight capabilities, one helper row. Nothing
else knows it exists.

**Red-on-old, two reverts, each verified and checksum-restored:**

| # | Revert | Result |
|---|---|---|
| A | `FormatBar.renderedCapabilities` returns a hand-written subset (`.prefix(4)`) | RED, exactly discriminating: `theToolbarRendersEveryDeclaredFormattingActInOrder` fails on the list and on all four missing ids in BOTH bars, and the registry walk's `theBottomBarsRenderExactlyTheDeclaredBarDoors` fails with it — four declared bar doors unrendered |
| B | `MarkdownActs.fire`'s no-target guard returns silently instead of speaking | RED: `theToolbarsButtonFiresTheMenusOwnDoorAndSpeaksWhenItCannot` fails on the status expectation — the door goes silent, which is the exact P-2 failure |

`FormatBar.swift` md5 `3dcb484fe1c0190a7f1cf8bd1d47d3df`, `MarkdownActs.swift`
md5 `cefeda936f5b217fa1c10bbfa6bdc785`, both matched after restore.

**One thing a reviewer should check by hand when the app is next open** (it is
pinned through a real window and a real first responder, but the last inch is
AppKit's): pressing a toolbar button while the caret is in the editor, to see
that clicking the button does not move first responder off the text surface.
With Full Keyboard Access off — the default — an `NSButton` does not accept
first responder on a click, so the keyboard stays where it was; and the
failure mode if that is ever wrong is HONEST rather than silent (the door
speaks `noTargetNote` instead of formatting the wrong thing).

---

#### K9 — callout frames render in Take mode · SHIPPED

Her instruction was *"callouts are supposed to be added to take mode as
well"*, and the finding underneath it is worth stating: the DOOR has routed
from the boards since 13c R2-2, so setting a frame from a take card already
wrote the right row — **and nothing the boards read carried the presentation
at all**, so the act changed a row and nothing on the glass. This row is the
read half.

- **Core:** `Queries.TakesProjection` gains `presentations`, filled by
  `blockPresentations` — the SAME query Write's decoration layer has always
  used, so the two surfaces cannot disagree about which blocks are framed or
  in what colour (pinned equal). It rides the projection rather than a fifth
  observation for the reason `unplacedOrigins` does: the board already
  re-reads on exactly the writes that change it, and the read is cost ∝ the
  post.
- **The model:** `TakesViewModel.calloutFrame(_:)` — the block's frame or nil,
  with the same fail-open `kind` check the editor's overlay applies, so a
  future non-callout presentation kind draws nothing rather than being drawn
  as a callout.
- **The face:** `TakesCalloutFrame` (a `ViewModifier`) wraps `articleRow`'s
  WHOLE row — the article cell, its bloom in every fan style, and the margin
  rail — because the ruled shape is one frame around the block's whole takes
  region, and in margin grid the takes are out in the rail. An unframed block
  takes the `else` branch, so its layout is byte-for-byte what it was.

**Mechanism and P-8:** a SwiftUI background shape, never a TK2 rendering
attribute (Write's own frame is an overlay VIEW for the same reason). The
colour resolves through `CalloutPalette`, so a new palette colour reaches both
surfaces at once. **R17's white gap is obtained from the layout rather than
from arithmetic:** the article's `LazyVStack` spaces rows by 6 and the frame
pads by 5, so two adjacent framed blocks keep a 6pt lane of surface between
them — the same promise `BlockDecor.verticalPad` computes in Write.

**Red-on-old, two reverts, each verified and checksum-restored:**

| # | Revert | Result |
|---|---|---|
| C | drop `presentations:` from `Queries.takesProjection` | RED on all three core pins by name (the map reads `[:]` against the editor feed's real frame); the plain-block and slot expectations stay green — the revert is exactly the missing read. `TakesQueries.swift` md5 `0b14f16a1f600e997c320cfaa0e213e8` matched |
| D | `calloutFrame` returns the raw presentation with no `kind` check | RED: `aFramedBlocksTakesRegionWearsItsFrameAndAPlainBlocksDoesNot` fails on the foreign-kind case (`someFutureKind` would be drawn as a callout). `TakesViewModel.swift` md5 `38cae7d25aece871142c2e62ea95fdec` matched |

**Scope, stated as a build-time call (#54(b)):** the frame renders in **Take
mode**, which is her instruction's letter and the ledger row's. Lenses and
Compare are not touched — their columns have no single "takes region" (Compare
spans posts), and inventing a frame geometry there would be inventing product
behaviour. Their callout DOORS are unchanged and still work.

---

#### K10 — the inline-code chip · SHIPPED

Her ruling: a faint per-voice TINTED CHIP hugging exactly the span, never
block-wide, geometry visibly distinct from callout frames.

- **The editing faces** (`MarkdownStyling`): one `.backgroundColor` over the
  WHOLE span — backticks included, because they are part of what she typed and
  a chip stopping short of them would leave two dimmed ticks floating outside
  their own tint (#54(c)). It is an ordinary storage attribute like every
  other attribute this file writes (never a TK2 rendering attribute), so it
  **hugs the glyph run by construction** — no geometry, nothing to keep in
  sync with layout, and display == stored is untouched (attributes only). The
  clear loop removes it over the face's own ranges, so a deleted backtick
  leaves no tinted ghost.
- **Read's two faces:** the paged reader (`PagePaginator.applyRun`) and the
  flow (`FlowParagraph.container`) tint the code RUN — Read hides the markers
  (F-5), so there the run IS the span. Both take the tint as a DEFAULTED
  parameter, so every existing caller and pin composes exactly as it did.
- **The tokens:** `VoiceTokens.codeTint` in all four voices; and because the
  reading page's identity is deliberately voice-independent (R2 — only the
  room around it follows the voice), `ReadingPageTokens.codeTint` is the
  page's own, not either voice's (#54(d)).

**This also closes a recorded 13g look finding** (batch 2's item 1): in the
TERMINAL voice the prose is already monospaced, so before this only the dimmed
backticks distinguished code at all.

**Red-on-old, three reverts, each verified and checksum-restored:**

| # | Revert | Result |
|---|---|---|
| E | drop the `.backgroundColor` write from the face's `.code` branch | RED: `aCodeSpanCarriesTheChipAndTheProseAroundItCarriesNone` fails on all three span offsets; the font/marker pins stay green |
| F | drop `removeAttribute(.backgroundColor, …)` from `restyle`'s clear loop | RED, exactly discriminating: `removingTheBackticksClearsTheChip` fails on all five offsets — the tint survives over text that is no longer code — and NOTHING else in the suite moves |
| G | drop the paginator's `.backgroundColor` write | RED: `readsPagedFaceTintsTheCodeRunAndNothingElse` fails on the chip while its marker-hiding expectation stays green |

`MarkdownStyling.swift` md5 `1edb202722fdf16b5f832cebeec8c436`,
`PagePaginator.swift` md5 `2d3a7f0e62ad52c20b031ae38f631f61`, both matched
after restore.

##### THE SWATCHES — the default that shipped, and the alternates, PROPOSE-ONLY

No visual loop was run (recorded honestly rather than implied): the only new
pixels are a background behind a few characters and a wash behind a block, and
13g batch 2's own record establishes that this project's offscreen dark
renders resolve the wrong appearance — so a dark screenshot would have been
misleading and a light one would have shown what the hex values already say.
The numbers below are what she would flick, stated against the surface each
chip actually sits on.

**Shipped defaults** — each a NEUTRAL tint of the voice's own room, deliberately
not a member of the callout palette's five pastels (blue · green · sand ·
violet · rose), so the two never read as the same language:

| where | surface it sits on | chip | the step |
|---|---|---|---|
| terminal light | `0xFBFBF7` | **`0xE9EBE2`** | a warm grey-green, ~7% down from the paper |
| terminal dark | `0x0C0D0C` | **`0x1E211E`** | a lift to just past the `line` token (`0x242624`) |
| study light | `0xFFFFFF` | **`0xF2EDE1`** | the study voice's own warm paper, ~6% down from white |
| study dark | `0x14120F` | **`0x241F18`** | a warm lift, level with the voice's `card` (`0x1C1915`) |
| reading page light | `0xFFFDF6` | **`0xF3EEE0`** | the page's paper, warmed |
| reading page dark | `0x171511` | **`0x241F18`** | the same warm lift the study dark chip takes |

**Alternates, for her flick (nothing is built for these — each is one hex per
line):**

1. **QUIETER (about half the step):** terminal light `0xF1F2EC` · terminal
   dark `0x171A17` · study light `0xF8F4EC` · study dark `0x1D1913`. Reads as
   a breath rather than a chip; the risk is that in the terminal voice it
   under-shoots the very finding this row fixes.
2. **STRONGER (about half again):** terminal light `0xE0E3D8` · terminal dark
   `0x262A26` · study light `0xEDE5D3` · study dark `0x2C261D`. Unmistakable at
   a glance; the risk is that a paragraph with several code spans starts to
   look striped.
3. **ACCENT-TINTED rather than neutral** (the voice's accent at ~8% over the
   surface): terminal light `0xEDF3EF` · study light `0xEDF1F5`. Prettier and
   more "of the voice"; the cost is that it moves toward the callout palette's
   register, which is exactly the distinction her ruling asked us to keep — so
   it is offered last.

A fourth axis exists if she wants it and is deliberately unbuilt: a thin
rounded outline instead of a fill. It is the one shape that cannot ride a text
attribute (it needs geometry), so it would be an overlay pass over the code
spans — real work, and worth naming only if the fill reads wrong to her.

---

#### K8 — THE PROPOSAL GATE (Tab-indented / nested lists; NOTHING BUILT)

**The question.** Her ruling: *"we should allow indented lists and it should
happen when you click tab"*, with sitting Q3 ruling the unindent door: **⇧Tab
+ Format ▸ Indent/Outdent menu rows**. This is the ONE row of the batch that
extends the STORED vocabulary, because the tokenizer's shipped rule is that a
line-leading construct must begin at the line's FIRST character — 13g batch 2
recorded the consequence and named this as the widening that would need her
word.

**What follows is the proposal only. The architect rules; then the Domain half
gets built.**

**(1) THE INDENT UNIT — recommended: TWO SPACES per level.**

Options weighed: two spaces · four spaces · a literal TAB character.

- **Two spaces is exactly the width of the `- ` lead**, so a nested item's
  marker lines up under its parent's first word — which is what an indented
  list looks like, and what CommonMark's own content-column rule produces for
  a `- ` list. It therefore round-trips as REAL nesting in every markdown
  renderer that will ever see her exported `.md` or the bridge's pushed body.
  (A checkbox parent behaves the same: its marker is still `- `; the `[ ]` is
  content.)
- **Four spaces** is the conservative universal, but it over-indents on screen
  and, outside a list context, CommonMark reads four leading spaces as an
  indented code block — a shape this app has no vocabulary for.
- **A TAB character** makes the on-screen indent depend on the text view's tab
  stops rather than on the text, which differs between the two voices' fonts
  and is not something "display == stored" can promise anything about; and a
  file mixing tabs and spaces becomes ambiguous to tokenize.

**Recommendation: two spaces.** Tab-the-key always inserts the two-space unit.

**(2) WHAT THE TOKENIZER READS — recommended: leading spaces AND tabs, level =
tabs + floor(spaces / 2), UNCAPPED.**

Reading tabs too costs ~3 lines and means a list pasted or imported from
elsewhere (11b's import path) simply works; her own tabs are never rewritten,
because the face only ever writes attributes. The alternative — spaces only —
is simpler and leaves tab-indented imports rendering flat.

**No cap on what is READ**, because the stored text is the truth and refusing
to style text she typed would be a lie; an odd space count (three spaces) is
legal and simply lands between levels, which is exactly what the stored text
says. **The widening is deliberately LIST-ONLY:** `"  # heading"` stays plain
text, so 13g batch 2's shipped pin (`headingsRunOneToThreeAndNeedTheirSpace`)
stays green and honest — her ruling is about lists.

**The consequence to state plainly: ZERO stored bytes change anywhere, but
text that used to render as prose will start rendering as a list.** Any line
in any existing note that already begins with spaces + `- ` becomes a styled,
Read-formatted list item. That is the ruling's intent; it is named here
because it is a change to what she will SEE in notes she wrote before it.

**(3) DEPTH ON SCREEN — recommended: Read INDENTS per level, one glyph,
clamped at 6 levels.**

`MarkdownRendering.LineStyle.bullet`/`.checkbox` gain an indent level; Read
strips the leading whitespace (it is part of the lead) and applies
`level × indent` of hanging indent instead — otherwise the spaces AND the
indent would both show. The glyph stays `•` / `☐` / `☑` at every level:
alternating glyphs (`•` / `◦` / `▪`) would invent a second visual vocabulary
and make Read disagree with the editing face, which shows `- ` at every level.
The VISUAL indent clamps at 6 levels so a runaway nest cannot push text off a
fixed page; the stored text is not clamped. *(Alternate for her: alternating
glyphs. One table.)*

**(4) THE CHECKBOX CLICK AT DEPTH — unchanged in kind, and that is the
answer.** The hit test reads `span.markers[1]` (the box) and requires the
insertion index STRICTLY inside it; indentation only moves that range right,
and the tokenizer still splits the markers the same way (`markers[0]` = indent
+ `"- "`, `markers[1]` = the box). Nothing about the two-character target
changes.

**(5) TAB / ⇧TAB OUTSIDE A LIST LINE — byte-unchanged, by the K5 shape.**
`insertTab`/`insertBacktab` are overridden on the two surface kinds and call
`super` unless the caret's own line (or, with a selection, at least one
affected line) is a list line — the exact
`insertNewlineContinuingLists(in:ordinary:)` shape, where the ratified
keystroke runs untouched and the new behaviour is a second ordinary edit.
There is no `insertTab` override anywhere in the app today, so "unchanged"
means AppKit's own behaviour, unchanged.

Sub-decisions inside (5), each recommended:

- **Caret OR selection.** With a caret, the caret's line indents wherever the
  caret sits (indent is a line act, not an end-of-line act like ⏎). With a
  selection, EVERY affected list line indents and non-list lines are left
  alone — the `leadPlan` blank-line-skip precedent. If no affected line is a
  list line, `super` runs and Tab does what it always did.
- **⇧Tab at level 0 is a no-op that falls through to `super`** — there is no
  indent to remove, and inventing a refusal for a key that has a standing
  meaning would be worse than doing what it always did.
- **THE ONE GENUINELY NEW CALL: what ⏎ does on an EMPTY *nested* item.** Her
  K5 ruling — *"⏎ on an EMPTY list item removes the lead and exits the list"* —
  was made when nesting did not exist, so it does not answer this. **Recommended:
  OUTDENT FIRST** (⏎ on an empty level-2 item makes it a level-1 empty item;
  ⏎ again at level 0 exits exactly as ruled today). It is the near-universal
  convention (Notes, Bear, Obsidian, Notion), it makes "finish this sub-list
  and continue the parent" a two-key flow, and it leaves her ruled behaviour
  byte-identical at level 0. **The alternative** is the literal reading —
  exit straight to a plain line at column 0 — which is one rule instead of
  two but loses the parent list. *(And the continuation half must carry the
  indent either way: ⏎ at the end of a nested item mints the next lead AT THE
  SAME LEVEL, or nesting would collapse on every Return.)*

**(6) THE MENU ROWS AND THEIR KEYS — recommended: two new capabilities,
`.formatIndent` / `.formatOutdent`, declared with `.menuBar` + `.contextMenu`
and `shortcutLabel: nil`.**

Tab MUST NOT be declared as a shortcut label: the registry walk
(`everyShortcutLabelHasExactlyOneKeyWiring`) would then require a menu key
equivalent for it, and binding ⇥ as a menu key equivalent steals Tab from every
control in the app. The keys live in the surfaces' `insertTab`/`insertBacktab`
overrides, exactly as ⏎'s does. The discoverability guards are satisfied
deliberately rather than incidentally: the helper's Formatting group gains a
row stating both doors in prose ("Tab / ⇧Tab inside a list, or Format ▸
Indent / Outdent"), which is what the formatting-door CEILING test
(`theHelperNamesEveryFormattingDoorIncludingTheKeylessOnes`) requires.

**Deliberately NOT proposed for the toolbar:** Indent/Outdent are not in
K7's cluster — Tab and ⇧Tab are the primary door, and the bar she already
called crowded is eight wide.

**Estimated diff when ruled:** `MarkdownSyntax` (the leading-whitespace scan +
`Span.indentLevel`, ~20 lines), `MarkdownEditing` (an indent/outdent plan +
the indent-aware `ReturnKey` leads, ~40), `MarkdownRendering` (the level on
the two list line styles + stripping the whitespace, ~15),
`MarkdownActs` + the two surfaces (the `insertTab`/`insertBacktab` doors, ~40),
two registry declarations + two menu rows + one helper row, and the two Read
faces' indent arithmetic (~10 each) — plus pins on every one of the six
decisions above and a red-on-old revert per behaviour.

---


---

#### K8 — indented (nested) lists · SHIPPED (the continuation, after the architect's rulings)

**Built to the six rulings exactly** (the "Architect adjudications on batch 2"
section above): two-space unit · spaces-AND-tabs tokenizer, `tabs +
floor(spaces/2)`, uncapped and LIST-ONLY · Read indents per level with one
glyph, clamped at 6 where it DRAWS · the checkbox target unchanged in kind ·
⏎ on an empty NESTED item OUTDENTS FIRST · `.formatIndent`/`.formatOutdent`
keyless with helper prose.

**THE CONSEQUENCE, STATED PLAINLY** (the architect's rider — it also rides the
author handoff): **zero stored bytes change anywhere, and yet a line in an
EXISTING note that already begins with spaces + `- ` now renders as a list
item where it used to render as prose.** It is a change to what the app DRAWS,
never to what it saved; it is her ruling's intent; and it is the one thing
about this row she could trip over without being told.

**The Domain half** (`Sources/VariorumCore/Domain/`):

- **`MarkdownSyntax`** — the LIST lead may now be preceded by a run of spaces
  and tabs; `Span.indentLevel` carries the level and the run joins
  `markers[0]`, because it is part of the lead. That last choice is what makes
  everything downstream cheap: a reading surface that substitutes the lead
  strips the indent for free, `markers[1]` is still exactly the checkbox's
  box, and `leadPlan`'s "the lead is `line.start..<content.lowerBound`" needed
  no new arithmetic. **The widening is LIST-ONLY**, so 13g batch 2's shipped
  heading rule ("it starts the line or it is text") is untouched and its pin
  stays green on its own terms. Two small public constants ride with it —
  `indentUnit` (the ruled two spaces) and `leadingWhitespace(of:)` — so the
  acts and the ⏎ continuation cannot disagree about what a level is.
- **`MarkdownEditing`** — `Act.indent`/`.outdent` join the enum (so they ride
  `MarkdownActs.apply` and `ShellActions.applyFormat` unchanged, rather than
  becoming a third kind of thing), planned by `indentPlan`: every affected
  LIST line moves by exactly one unit; a heading, a paragraph or a blank line
  is left alone; an outdent at level 0 emits nothing. **An EMPTY plan is the
  signal the keystroke was not ours** — that is the whole mechanism behind
  "Tab outside a list is byte-unchanged". `ReturnKey` gains `.outdentItem`,
  and `.continueList`'s lead now carries the line's own indent (read from the
  text, so a tab-indented item keeps its TAB — nothing here rewrites her
  whitespace).
- **`MarkdownRendering`** — `Line.indentLevel` (uncapped) plus
  `maxDrawnIndentLevel = 6`, the one place both Read faces read the clamp
  from.

**The app half:** `MarkdownActs.indentLists(_:in:ordinary:)` — the K5 door's
shape exactly, where the ratified keystroke runs untouched unless the plan is
non-empty — behind `insertTab`/`insertBacktab` overrides on BOTH surface kinds
(R118: a list behaves the same wherever she is typing). The Format menu and
the context submenu gain the two rows from `MarkdownActs.indentRows`, a
SECOND table beside `rows` and deliberately so: `FormatBar` reads `rows`, so
the nesting acts stay OFF the bottom bar's toolbar (Tab is the primary door
and the bar she already called crowded is eight wide) — and the split is
walk-enforced, since these two carry no `.bottomBar` door. Read's paged face
steps the hanging indent per level; the flow's row indents per level; both
clamp at the shared constant.

**Why the two acts carry no `shortcutLabel`, stated because it looks like an
omission:** the registry walk (`everyShortcutLabelHasExactlyOneKeyWiring`)
requires a menu key equivalent for every menu-doored capability that declares
one — and binding ⇥ as a menu key equivalent takes Tab away from every control
in the app. So the keys live where ⏎'s lives (the surfaces' own overrides) and
the ⌘/ helper carries BOTH doors in prose, which is the only guard a keyless
act can have (WT-1's lesson, pinned by `theHelperNamesTabAndTheMenuRows`).

**THREE shipped expectations were updated deliberately, each on the record**
(the K1 class — the pin's claim changed because this batch changed it):

| Pin | Was | Now |
|---|---|---|
| `MarkdownEditingTests.headingsAndPlainProseAreOrdinary` | `verdict("  - milk") == .ordinary` (the column-0 law) | `== .continueList(lead: "  - ")`; an indented HEADING case was ADDED, since that half of the old claim survives |
| `MarkdownRenderingTests.anIndentedLeadIsNotALead` (renamed `anIndentedLIST_leadIsALeadNowAndAnIndentedHeadingIsStillNot`) | an indented `- ` renders as body text | it renders as a nested bullet, level 1; the indented `# ` in the same fixture is STILL body |
| `MarkdownActsTests.theFormatSubmenuIsRenderedOnlyWhereTheSurfaceCanBeEdited` | the submenu's titles == the eight verbs | == the eight, a separator, and the two nesting verbs (the claim is unchanged: the rows ARE the registry's verbs in declared order) |

**Red-on-old — SIX reverts, each verified and checksum-restored:**

| # | Revert | Result |
|---|---|---|
| H | the tokenizer's indent scan goes (the shipped column-0 guard back) | RED across FOUR suites and exactly on the nested cases: `anIndentedCHECKBOXKeepsItsBoxAsMarkersOne` (no span at all), `continuingANestedItemStaysAtItsOwnLevel`, `anEmptyNESTEDItemOutdentsAndOnlyLevelZeroExits`, `readIsToldTheLevelAndTheIndentIsGoneFromWhatItDraws`, `theLineScopedLawSurvivesTheWidening`, and both updated pins — while every column-0 and heading expectation stays green |
| I | `returnKey` drops the `indentLevel > 0` guard | RED: `anEmptyNESTEDItemOutdentsAndOnlyLevelZeroExits` reports `.exitList(0..<4)` where `.outdentItem(0..<2)` is owed — i.e. the revert IS the recorded alternative (#54(e)), which is why the pin discriminates the ruling rather than an accident |
| J | `indentPlan` drops its list-lead guard | RED: `aNonListLineIsNEVERTouched` and `aSelectionIndentsTheListLinesItTouchesAndNothingElse` — Tab silently indents prose, the exact failure the byte-unchanged promise forbids |
| K | `indentLists` always calls `ordinary()` | RED on both surfaces: `tabIndentsAndShiftTabOutdentsThroughTheRealKeystroke` produces `"- milk\t"` and `aTakePaneIndentsAndOutdentsTheSameWay` the same — the key types a tab into the list line |
| L | `MarkdownRendering` stops carrying `span.indentLevel` | RED: every level reads 0 in both the new pin and the updated rendering pin, while the display TEXT stays right — the precise failure where Read draws a nest flush left with its spaces already gone |
| M | `leadPlan` drops the indent preservation | RED: `settingALeadOnANestedItemKeepsTheIndentAndClearingRemovesIt` — Format ▸ Checklist on a nested bullet collapses it to the margin |

Checksums matched after restore: `MarkdownSyntax.swift`
`794c2b69b198634e92699be904d445f5` · `MarkdownEditing.swift`
`df351e57d122f1832a82ae90ef8dc573` · `MarkdownRendering.swift`
`b6fc6be177ddf655c59c7c41708fb5ec` · `MarkdownActs.swift`
`ad16cdfe669bc582269607d114322163`.

**What else the pins cover:** the checkbox toggle at depth (the box moved
right, the strict-inside rule identical); whitespace-only lines and `"  -"`
are never lists; a selection spanning list and prose lines moves only the list
ones; a SEALED note refuses the indent in its own words with no new refusal
code; a tab-indented item keeps its tab through a continuation; the line-scoped
law (no span crosses a newline, therefore none crosses a block seam) still
holds over indented text; and the registry pair is keyless, off the toolbar,
and named in the helper.

**One build-time call the ruling did not cover, added to #54 as (g)** — it
did not exist when the proposal was written: re-leading a NESTED item keeps
its indent (Format ▸ Checklist on an indented bullet gives an indented
checkbox) while CLEARING a lead removes the indent with it (the line stops
being a list, and a paragraph left indented by two orphan spaces is not what
"clear" means). Strike it from #54 if the architect would rather it were not
her call.

#### Notes for the orchestrator

- **`notes/QUESTIONS.md` gains #54 — SEVEN build-time calls**, opened at the
  architect's instruction: (a)–(d) as proposed, (e) the ⏎ outdent-first call
  with its alternative, (f) Read's clamp and one-glyph look with the
  alternating alternate, and (g) — new from K8's build, flagged for the
  architect to strike if it should not be hers — re-leading a nested item
  keeps its indent while clearing removes it. **#55 is now the next free
  number.**
- **Nothing is owed.** K7, K9 and K10 shipped at `1324def`; K8 shipped in the
  continuation to the architect's six rulings.
- **No visual loop was run** — the reasoning and the full swatch table are in
  the K10 section, with three alternates per voice as a propose-only set.
- **Two hand-checks for the next open app**, both named above: the toolbar
  button vs. first responder (K7), and a framed block in each of the four fan
  styles (K9 — the margin-grid case is the one where the frame grows to
  include the rail).
- **Two acceptance runs of the full Mac suite were made** — one before and
  one AFTER the record/QUESTIONS commit (`7906dd7`), because a comment was
  edited between them and a quoted count must come from the tree that
  shipped. Both landed identically: **1176/203 with only the tripwire**.
- **Environment note for the next session:** running the mobile scheme and a
  `-only-testing` spine pass CONCURRENTLY with the full Mac run makes the full
  run take ~2× wall time (144 s → 148 s of test time, but several minutes of
  contention before it reports). Run them in sequence.
- **The spine's selector:** `-only-testing:VariorumTests/TutorialWalkTests`
  selects ZERO tests. The seven suites are types
  (`TutorialBookShapeTests`, `TutorialDoorTests`, `TutorialWritingActsTests`,
  `TutorialTakesActsTests`, `TutorialStructureActsTests`,
  `TutorialLookingActsTests`, `TutorialLibraryActsTests`).

### Architect adjudications on batch 2 (2026-08-02, recorded before the continuation)

- **Spot-verified:** `1324def` + `1ad3ee5` present, tree clean; own
  core run `Test run with 1019 tests in 113 suites passed` matching
  the implementer's line exactly; the own Mac full run rides at this
  writing and lands with the acceptance.
- **K8 RULED — all six calls as recommended, two with riders:**
  1. **Indent unit: TWO SPACES per level** — approved; the
     export-round-trip argument is exactly right, and both named
     hazards (four-space = code block elsewhere; a tab character
     breaks what display==stored can promise) are real.
  2. **Tokenizer: spaces AND tabs, level = tabs + floor(spaces/2),
     uncapped, LIST-ONLY widening** — approved INCLUDING the named
     consequence: existing lines beginning spaces + `- ` start
     rendering as lists. That is her ruling's intent, display-only,
     zero stored bytes changed — and it RIDES THE AUTHOR HANDOFF
     stated plainly so she sees it before she trips on it.
  3. **Read: per-level indent, one glyph, visual clamp at 6**
     (stored uncapped) — approved; the alternating-glyph look goes
     to her as a propose-only ALTERNATE.
  4. **Checkbox click-target at depth: unchanged in kind** —
     approved.
  5. **⏎ on an empty NESTED item: OUTDENT FIRST** — approved as the
     platform standard, extending her K5 ruling (byte-identical at
     level 0, so nothing she ruled changes); the literal
     exit-to-column-0 alternative goes to her as a lettered call
     (the PROVISIONAL class).
  6. **`.formatIndent`/`.formatOutdent` with `shortcutLabel: nil`,
     helper prose carrying both doors** — approved; declaring ⇥
     would steal Tab app-wide.
- **QUESTIONS #54: OPEN IT NOW** — the batch's four named calls
  (a)–(d) plus (e) the ⏎ outdent-first call and (f) Read's
  clamp/one-glyph look with its alternating alternate. The register
  stays current; her walk stays one place.
- **The tripwire covariate refutation is REAL and lands in
  KnownIssues** — the row's lock-state theory now carries its own
  refutation on its face; 13e's A47c re-run starts
  covariate-UNKNOWN. (Honest recording over re-theorizing —
  exactly right.)

### Batch 2 ACCEPTED (2026-08-02 — the architect's own runs, quoted)

- core `Test run with 1032 tests in 114 suites passed` (from
  1016/112 at the batch's open)
- Mac `Test run with 1176 tests in 203 suites failed after 143.705
  seconds with 1 issue` — confirmed **BY IDENTITY**: the recorded
  environment-gated tripwire (`TakePaneMeasureTests.aStranded…`),
  on a LOCKED session — consistent with the refutation now on the
  KnownIssues row's face. Every other suite green, the spine's 7
  included.
- spine `51 tests in 7 suites` and mobile `14 tests in 4 suites`
  green by the implementer's quoted runs; the spine additionally
  green inside the architect's own Mac full run.
- Rows K7–K10 all SHIPPED (`1324def` + `7906dd7`, record
  `f89c438`); ledger flipped.
- **#54(g) STAYS** — the nested re-lead call is exactly the walk
  register's class (product-flavored, one line either way, shipped
  default defensible); recording it rather than swallowing it was
  right. #54 stands at seven calls; #55 next free.
- The two-identical-Mac-runs note reads as diligence, not
  discrepancy; the concurrency-contention note stands (sequence
  the suites next time).

### Round 3 (2026-08-02 — the author returns; the machine-death event)

- **Her machine DIED mid-batch-3** (her report: "it looks like my
  computer actually just died"). Damage assessment by the
  architect: HEAD untouched at `8642689` (batch 2's acceptance),
  ZERO commits lost; batch 3's in-progress work SURVIVED on disk
  as ~15 uncommitted modified files on exactly the K11/K12 surface;
  the implementer's task record died with the machine. Recovery:
  the implementer resumed FROM ITS TRANSCRIPT with a
  verify-don't-trust preamble — trust the FILES, not its memory;
  every pre-death test run is void and re-runs; quieter sequential
  test scheduling while she is at the machine.
- **The K8 old-notes consequence is RATIFIED by her directly**
  ("like a single indented list item? I think that's fine
  realistically") — recorded on #54's preamble; it no longer needs
  the handoff's flag.
