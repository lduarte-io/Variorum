# Phase 13d — the refusal & ergonomics floor

**Status: KICKED OFF by the author 2026-07-27 evening**, at the tail of
the 13c ratify walk — her words: *"I think after this we're also fully
done with 13c and ready to go into 13d. Also - let's keep the
implementation to Orchestrator Fable, implementer Opus, and cold review
at the end fable."* **CAST (her ruling): Fable orchestrator · fresh
Opus implementer per batch · ONE Fable cold review at phase end** — the
13c K6 shape carried forward. Runs under `/architect-phase` (the
sitting-heavy walk items below want it).

## Ruled at the 13c walk — BATCH 1 (build first; all three are her fresh rulings)

1. **#43(a) — Outline opens COLLAPSED** (her overturn of the shipped
   PROVISIONAL): posts render as cards by default; expand what you work
   on. Flip the default (the 2A model tracks the collapsed set — invert
   or seed), update the pins, keep "expand all"/"collapse all".
2. **#44(c)/#45(c) — the scrubber returns to Book's spread** beside the
   leaf-turn controls (the 2B removal reverses); Read's Pages keeps its
   own. Model-driven domain as everywhere (Stage 4 lesson 8).
3. **#47(c) — Compare's related-blocks-only defaults ON**; the toggle
   reveals the full posts. Flip + pin update (the 2E narrowness pins
   must still hold).

**#34 (backspace-merge when neither block has takes, refuse-and-speak
when either does) is ruled and builds in this phase as its own batch**
— planner + merge wiring + pins; the §14 delta lands with it.

**Successor orchestrator resumed 2026-07-27 late evening** (the ~620k
cutover — `phase-13d-orchestrator-handoff.md` is the role handoff;
this file stays the phase's one running record). State verified, not
trusted: HEAD `99c5ecb` clean; the first batch-1 agent provably acted
zero times; baselines re-verified by this orchestrator's own runs
(the "Baselines at open" section below carries the numbers). Her
real-store app was LIVE at resume — instance discipline binds every
session; installs only at her word.

## Binding principles

**The P-1…P-9 constitution is copied VERBATIM below (the skill's
requirement; byte-exact from 13b's plan file via 13c's copy).**

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

**The skill's "Applying the constitution" precisions bind here as
written there** (P-1's routed-vocabulary scope + `.surface`; P-3's two
surface kinds — the full-document editor is never absorbed; layer
placement + parity-by-forwards; the overlay/sink delivery law), and
the 13c plan's "Stage 4 lessons" section binds by reference (ONE snap
brain, ONE join brain, the ceremony-sheet disciplines, model-driven
navigation, the locked-session regime, in-view affordances vs declared
acts).

## Rolled from the 13c walk to THIS phase's sittings (open with her)

#29–#33, #36, #37, #38, #42, the minor sub-calls of #43–#47, #46's
five conversion rulings, the C3 block-extent memo's Parts 1/3, and the
long-content-panes memo's §6 — the QUESTIONS walk ledger (end of
`notes/QUESTIONS.md`) is the checklist. Resolved gates: #34, #39, #40,
#41, #43(a), #45(b) — see the 13c plan's walk record.

## Kickoff message (paste-ready for the orchestrator/coordinator the author invokes)

> You are running Variorum Phase 13d under the shape the author picks
> at kickoff (`/architect-phase` if design-heavy sittings are wanted;
> `/run-phase` if she wants it spec-driven — this plan leans simple
> enough for either). Read IN FULL first: `CLAUDE.md`,
> `notes/CoreDescription.md`, `notes/OverallModel.md`,
> `notes/AppSpec.md` (§9, §12, §14's Stage 1/Stage 2 13c deltas),
> `notes/plans/phase-13c-book-forms-and-conversions.md` (the
> constitution P-1…P-9 it carries binds 13d identically; its
> environment-traps section is current — including the 2E
> `-only-testing` false-green trap), `notes/TEXTKIT2_NOTES.md`, this
> plan, and `notes/QUESTIONS.md` #29–#47 (several 13d items depend on
> her walk's answers — see "Gates on her rulings" below). Verify the
> baselines with your own runs. Copy the P-1…P-9 constitution into
> this file verbatim at kickoff (the skill's requirement) if running
> under `/architect-phase`.

## Baselines at open (verify with your own runs)

Core **882/100** · Mac **788/135** · mobile **14/4**. Core and Mac
RE-VERIFIED green by the successor orchestrator's own runs 2026-07-27
~20:00 ("Test run with 882 tests in 100 suites" / "Test run with 788
tests in 135 suites"); Mac supersedes the 782/134 first written here —
that was the 13c Stage 2 final, before the post-closeout A47c work
added its pins (the handoff's 788/135 is confirmed). Mobile untouched
since its 13c verification; re-verify before any batch that touches
shared/mobile code, else at phase end. No schema change since v1_12;
mirror at lockstep marker 4.

## Scope (the K3 roadmap's rows, hers verbatim from the 2026-07-25 intake ledger)

| Row | Item (hers) | Notes for the plan |
|---|---|---|
| A5 | "the callouts don't have the spacing on their color right" | Largely addressed by 13c 1A's geometry fixes + R17's rule now live; VERIFY against her walk's reaction before building more — may be done, may be a memo-Q1 conversation (the block-extent memo's Part 1 is hers, #29) |
| A9 | Divide NATIVELY in Takes (without the carry-to-Write) | The 13c sizing (#41) binds: needs a structural planning path for Takes + the W ceremony mountable outside `EditorSurfaceController`. **She may promote this to the top** — ask at kickoff |
| A11 | Divide on an empty line puts the blank line NOWHERE | Interacts with the 2026-07-12 spacing ruling (trailing newlines are content) — trace what the blank line IS before designing. **13c 1G recorded input:** the blank-run ownership rule is `SegmentationRules` (k newlines between pieces → k−1 stored on the preceding block); block-END newlines are content and durable (pinned, `TakePaneDurabilityTests`); the ONLY places whitespace is dropped are the open tail (whitespace-only never mints) and bulk-entry edge runs |
| A12 | Warning before destructive structural undos | The cheap half now that 13c built redo (its recorded pair); "destructive" needs a definition — likely "undo of a mint that had post-op edits" (the insurance class) |
| A14 | ⌘⇧Enter = new block | Registry declaration + editor wiring; check collision with existing ⌘⇧ bindings first |
| A15 | Shift-Enter stays in the block — Takes AND Write | I4-clean (newlines are content); the crystallization interaction at the open tail is the part to design |
| A16 | The newline-makes-a-block setting in Takes too (N34's GLOBAL `one_block` face) | 13b's 4D recorded the blocker: one small core setter away — read that record first |
| A22 | Typewriter room (a page of scrollable space below) | **CONFIRMED BY THE AUTHOR 2026-07-27** (*"yeah, I think we should build A22 properly in 13d"*) — ruled at the A47b sitting, where she described building the room BY HAND out of typed newlines because the app refuses to scroll past the end (the 13c plan's A47b section holds the story; it fed the void defect). MUST compose with 13c's phantom fix: 1C's record binds — deliberate room must be REAL space the caret can enter, or it feels exactly like the phantom she hated. Read `LongBlockLayout.swift`, the C3 memo, AND the 13c Batch 1G record first. **1G's recorded input on how typed end-of-post whitespace ACTUALLY behaves:** newlines typed at a BLOCK's end (mid-post included) are content, stored byte-exact, durable through every ordinary path (experiment-pinned); newlines typed past the LAST block are open-tail entry and a whitespace-only tail NEVER MINTS — it renders for the session and evaporates at teardown without ever reaching the store (`idleMintTail`/`finalizeWork` both guard `!tail.allSatisfy(\.isWhitespace)` — the ratified Phase 7 rules). So hand-built room LOOKS durable and silently vanishes — the surface-vs-store disagreement that seeded A47b. A22's design must give room that is either real non-content scroll allowance or genuinely durable; her "should we just stop trimming?" question + the architect's recommendation (keep the edge rules, build A22 as the real answer) are recorded in the 13c plan's A47b section, HER ruling deliberately untaken until this sitting |
| A23 | Setting: paragraph-tall gap between blocks | Pure presentation (the 2026-07-12 ruling's presentation half); a Settings face over the uniform gap |
| A24 | Different levels of spellchecking | TEXTKIT2 §3 warns: continuous spell check + completion has crashed TK2 — keep the toggle coarse and test the crash class |

## Gates on her rulings (do not build past these before the walk)

- **#34** (texted-seam backspace-merge): if she rules (ii)/(iii), that
  build lands HERE — it is the floor's biggest item and pairs with A12.
- **#40** (named/callout empty carve): one guard line if she flips it.
- **#41** (A9's promotion): her call on where it sits in this phase.
- **#43(a)** (Outline's open-by-default): one line if she flips it.
- The C3 block-extent memo's Parts 1/3 (#29) — A5's real scope depends
  on her answers.

## Batch briefs

### Batch 1 — the three ruled walk flips (fresh Opus implementer; self-contained)

**Read IN FULL before touching code:** `CLAUDE.md` (and the canon docs
it loads), THIS plan file, and in
`notes/plans/phase-13c-book-forms-and-conversions.md`: "Binding
principles", "Environment traps" (binding), "THE RATIFY WALK", and the
batch records for **2A** (Outline), **2B** (the Book spread), **2E**
(Compare) — the three surfaces you are changing. `notes/QUESTIONS.md`
#43, #44, #45, #47 hold each ruling's full option context.

Three changes, each a ruled author decision from the 2026-07-27 walk —
build exactly these, nothing more:

1. **#43(a) — Outline opens COLLAPSED** (her overturn of the shipped
   PROVISIONAL): posts render as the batch-12 cards by default;
   expanding is the deliberate act. The 2A model tracks a collapsed
   set — invert its sense or seed it (your call; record which).
   #43(b)'s view-local/session semantics are UNCHANGED (nothing
   persists); "expand all"/"collapse all" both stay; an expanded post
   stays expanded for the view's life. Pins that assert open-by-default
   flip to assert collapsed-by-default — a ruled flip, not a bug fix;
   name every pin change in the batch record.
2. **#44(c)/#45(c) — the jump scrubber RETURNS to Book's spread**,
   beside the leaf-turn controls; Read's Pages keeps its own (her
   one-rule-for-both: scrubbers on BOTH horizontal surfaces). The 2B
   removal reverses — that record says the brain (`scrubIndex`) is
   still present and pinned; this is face work. Model-driven domain
   only (the post list — never live TK2 geometry; Stage 4 lesson 8).
3. **#47(c) — Compare's related-blocks-only toggle defaults ON**; the
   toggle reveals the full posts. A default flip + pin update; the 2E
   narrowness pins must still hold (the filter's SEMANTICS are
   untouched). The empty-state copy ("related blocks only — nothing
   from this post") now greets unrelated pairs first — that
   consequence was in front of her when she ruled; change nothing else
   about it.

**Loop (binding):** build → pins updated → the tutorial spine green →
full suites: core `swift test` from the repo root, Mac from
`App/Variorum/` — the "Test run with N tests" line is the ONLY proof a
suite ran (SUITE-level `-only-testing` only if you narrow; zsh
`pipestatus`). Baselines to match-or-beat are in "Baselines at open"
below; mobile is untouched by this batch. Commit per convention with
the standing trailer (one commit for the batch, or one per item if the
diffs read cleaner). **Append your batch record to THIS file under
"Batch records"**: what changed, files touched, every pin change
named, counts from your own runs, anything unverified marked PENDING.
**Never** refresh `/Applications` (her live instance; installs are at
her word only), never touch `Sources/VariorumCore/Sync/` (nothing here
needs it), never push. If any item turns out materially bigger than
its ruling's shape (none should), STOP on that item and return with a
proposal — the implementer-proposes-architect-rules door — rather than
designing past the ruling.

### Batch 2 — #34, backspace-merge at a texted seam (fresh Opus implementer; self-contained)

**The ruling (13c ratify walk, 2026-07-27 — QUESTIONS #34, option
(ii); the verbatim record is the 13c plan's "THE RATIFY WALK"
section):** backspace at a seam between two TEXTED blocks **MERGES
when NEITHER block has takes**, and **refuses-and-speaks when either
does**. The AppSpec §14 delta lands with this batch.

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §9's merge / mergeCeremony / deleteBlock-precondition
entries; §14's 13c Stage 1 delta, item (3) — the A7 carve's record);
THIS plan file; `notes/QUESTIONS.md` #34 (the full option context) and
#40/#42 (the carve's adjacent rulings — their behavior must NOT
change); the 13c plan's Batch 1B record + the ladder findings the §14
delta names (the precondition story); then the code: the seam-deletion
path the A7 carve rides (`StructuralGesturePlanner` and the editor's
separator-deletion handling) and the merge gesture path.

**The shape (bind to this; STOP and propose before deviating):**

1. **The seam-deletion vocabulary gains one case; nothing existing
   moves.** Precedence at a deleted inter-block separator: (1) the A7
   carve exactly as shipped — empty block, nothing unshown → delete;
   its guarded refusals (#40/#42's rulings) untouched; (2) NEW — both
   neighbors TEXTED, neither fanned → the ordinary binary MERGE of the
   two neighbors; (3) NEW — both texted, either side fanned →
   refuse-and-speak: the fan named, the explicit merge door pointed
   at.
2. **"Has takes" = the same condition `mergeCeremony` uses to decide
   instant-vs-ceremony** (a live fan on either side). Backspace-merge
   fires exactly where merge itself would be instant, and never where
   it would open a ceremony — ONE rule, no second fan test invented. A
   keystroke must never fold a fan and never open a sheet.
3. **The merge IS the ordinary merge operation** through the standing
   gesture path (`runStructural`'s one-flight door; the differential
   seam path; `MergeJoin` — never a re-derived join; undo AND redo
   riding the standing registration). Caret lands at the join per the
   standing merge caret rule. Sealed post, locked variant: fire the
   op, deliver its real refusal (P-2) — invent nothing.
4. **Directional coverage = the A7 carve's, exactly** — whatever
   separator-deletion gestures the carve accepts today (backspace at a
   block's start; forward-delete at the previous block's end, if the
   carve accepts it), the merge case accepts identically. Parity with
   the shipped carve, not invention; record which gestures that turned
   out to be.
5. **The §14 delta:** one AppSpec §14 shipped-semantics addition
   recording the ruled second exception to the cross-block
   destructive-edit refusal line (the A7 carve is the first) — HER
   ruling, quoted, nothing beyond it. The orchestrator reviews the
   delta text at adjudication before it stands.
6. **Pins:** red-on-old for the merge case (pre-change, that keystroke
   does nothing — verify the red by behavioral revert, not by
   construction alone); refusal pins for the fanned case; the A7
   carve's cannot-widen pins and #40/#42's shipped behavior run
   UNCHANGED and green.

Loop, records, constraints: identical to Batch 1's — the standing
loop, full suites with quoted "Test run with N tests" lines, batch
record appended under "Batch records", commit per convention, never
`/Applications`, never `Sources/VariorumCore/Sync/`, never push.

### Batch 3 — A9: divide NATIVELY in Takes (fresh Opus implementer; PROPOSAL GATE inside)

**The ruling (QUESTIONS #41, the 13c ratify walk):** native
divide-in-Takes lands in 13d — her words, *"it should be done in 13d
but wherever in 13d is fine."* The carry-to-Write door is the shipped
stopgap she accepted until this batch lands.

**Scope: DIVIDE ONLY.** The other carried gestures (extract,
make-block, merge, delete-in-every-take) KEEP the carry choreography —
A9's words are "divide natively"; nothing else moves in this batch.

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §9's divide/divideW entries with S4-22's cut/parking
rules; OverallModel §7); THIS plan file; `notes/QUESTIONS.md` #41; the
13c plan's "Environment traps"; the two 13b memos
(`notes/plans/phase-13b-memo-w-ceremony.md`, `…-memo-merge.md` — the
ruled ceremony semantics); then the code: `StructuralGesturePlanner`,
`EditorSurfaceController`'s divide/W path (`runStructural`, the
ceremony state, `DivideWSheet`, `CutPropagation`),
`TakesChoreographer` (the carry this replaces — its caret-transfer
comment records the W-memo reading), `TakesBoardView` /
`TakesViewModel` / `TakesBottomBar`, and `PaneTextAuthority`.

**Binding constraints:**

1. **ONE planner brain.** The divide verdict Takes consults is
   `StructuralGesturePlanner`'s — extracted or parameterized as
   needed, never a sibling planner. The Takes divide door's registry
   declaration (P-1) updates from carry-choreography to native act;
   availability stays data.
2. **ONE snap brain.** `BoundarySnapping` + the S4-22 rules
   (word-edge floor, gentle settle, both-end parking in the ceremony)
   — byte-identical to Write's door.
3. **The ceremony-sheet disciplines bind wherever the sheet mounts**
   (Stage 4 lesson 5): one-flight guard before any await,
   drift-refresh against the CURRENT fans at confirm, cancel-inert,
   honest confirm blockers, I10-at-birth (`divideSideWouldBeEmpty`).
4. **P-3 holds.** The full-document editor is not absorbed; the pane
   surface stays the one pane component; anything liveness-shaped
   routes through `PaneTextAuthority` — never a second mechanism.
5. **The two cases:** an UNFANNED block takes a plain `divide` at the
   pane caret (the one take is the text). A FANNED block opens the W
   ceremony IN Takes — the cut pre-seeded from the take the caret
   actually sits in, `CutPropagation` seeding the rest (the recorded
   W-memo reading; note this is a small generalization of Write's
   seed-from-chosen, since a Takes caret may sit in a non-chosen
   pane — name it in the record).
6. **Fire-and-DO:** the door acts in place — no mode switch; refusals
   are the operation's own, spoken; the seal refuses through the
   standing guards.
7. **Undo/redo ride the standing ops registration** — nothing new.
8. **The board shows the successors through its ordinary projection
   path** — no bespoke re-render.

**THE PROPOSAL GATE (binding — the in-batch design fork is the
architect's, the 4E pattern):** BEFORE building the ceremony-mount
half, investigate and append a short PROPOSAL to this file under your
batch record heading covering: (a) where the ceremony state machine
will live and what is extracted from `EditorSurfaceController`
(parity-by-forwards where names move); (b) how the sheet mounts on
the Takes board; (c) what serves as the ONE-flight door for a
Takes-native structural act and how it relates to `runStructural`;
(d) how the confirm's apply and the board's refresh compose. Then
STOP and report to the orchestrator; the build proceeds on the
orchestrator's ruling. The unfanned plain-divide half may be built
before the gate ONLY if it needs none of (a)–(d) beyond trivial
wiring — say which it was either way.

Loop, records, constraints: identical to batches 1–2 — checksums
before every revert; batch 2's adopted rule binds (a pin whose red
state changes an array's length must not subscript it); full suites
with quoted "Test run with N tests" lines; batch record appended;
commits per convention (an extraction/move may be its own commit);
never `/Applications`, never `Sources/VariorumCore/Sync/`, never
push. Baselines to match-or-beat: core 882/100 · Mac 808/136 · mobile
14/4 (untouched unless `Shared/` is touched — run it and say so if
so).

### Batch 4 — the typing-ergonomics floor: A14 · A15 · A16 · A23 · A24 (fresh Opus implementer; ONE PROPOSAL GATE on A15's tail half)

Five ledger rows from her 2026-07-25 intake (the K3 roadmap's 13d
column). Four are mechanical against recorded decisions; A15 carries
the phase's one genuine design edge and is GATED.

**Read IN FULL before touching code:** `CLAUDE.md` + the canon it
loads (AppSpec §7's segmentation-trigger note + the §14 deltas for
2026-07-06/07 Phase 7 rulings — the open tail, idle-mint, Enter-at-end
— and 2026-07-12's spacing ruling, both halves); THIS plan file
(batches 1–3's records show the form; their adopted rules bind); the
13c plan's "Environment traps"; in
`notes/plans/phase-13b-make-it-work.md`: the 4D batch record's N34
note (A16's recorded blocker) and the S4-14/S4-21 one_block rulings;
`notes/TEXTKIT2_NOTES.md` §3 (the spell-check crash warning that
scopes A24). Then the code each item names.

**The items:**

1. **A14 — ⌘⇧⏎ mints a new block.** Her row verbatim: *"⌘⇧Enter = new
   block"*. The ACT already exists (`insertBlockBelowFocused` — 13b
   4D, native in Write, Takes and Lenses); this is its SHORTCUT door:
   one registry declaration (P-1 — the shortcut rides the act's
   standing availability; every shortcut a menu item, the R73/R91/R93
   legibility mandate; the Shortcuts & Dictionary helper picks it up
   from the registry). CHECK COLLISIONS FIRST across the standing
   keyboard family (menu key equivalents + registry shortcuts) and
   record the sweep's result in the batch record; if ⌘⇧⏎ is taken,
   STOP and report rather than picking a substitute — the key is her
   ask.
2. **A15 — shift-Enter stays in the block, Takes AND Write — TRACE
   FIRST, THEN THE GATE.** Her row verbatim: *"Shift-Enter staying in
   the block in BOTH editors"*. Step one is a TRACE, recorded in the
   batch record BEFORE any design: what Enter and ⇧Enter each do
   TODAY in (a) Write mid-block, (b) Write's open tail (paragraph
   mode), (c) Write under `one_block`, (d) a Takes/Lenses pane, (e)
   the quick-entry bar if it accepts newlines. Where the two keys
   already both stay (I4 — mid-block newlines are content), record
   that and build nothing. The REAL half is wherever Enter leads to a
   block boundary (the open tail's crystallization; any pane behavior
   that isn't stay): propose the minimal mechanism that makes ⇧⏎ a
   guaranteed stay-in-this-block newline there — and note the
   constraint that makes this a design edge: crystallization's
   boundary detection is a pure Domain function over TEXT, newlines
   are content (I4), and the store records no keystroke provenance —
   so any "this newline is soft" memory must live in EDITOR SESSION
   state over the un-minted tail (the tail is surface-only until it
   mints), never in the schema, and the minted result must be
   indistinguishable from typed content afterward. **Append the
   proposal to this file under your batch record heading, STOP on
   this item, and report** — the other four items may be built while
   A15 waits; the gate closes on the orchestrator's ruling.
3. **A16 — the GLOBAL `one_block` face (N34).** Her row: the
   newline-makes-a-block setting reachable in Takes too — 13b 4D
   recorded the blocker as "one small core setter away"; read that
   record first. Build the small core setter for the document-global
   `default_segmentation` setting (the `setting` table row is SYNCED
   document semantics — §7's seeds; upsert-only, ordinary outbox
   ride) + its Settings face; per-post `segmentation_default`
   override semantics are UNTOUCHED. Entry-wide semantics per
   S4-14/S4-21 (paste included) come from the existing machinery —
   this is a face + setter, not a segmentation change.
4. **A23 — the paragraph-tall gap setting.** Pure presentation over
   the 2026-07-12 ruling's presentation half (the uniform
   per-PARAGRAPH gap — never per-seam; §12's boundaries-invisible
   reasoning rides it): a Settings → Appearance face offering the
   standing gap and a paragraph-tall option. Stored NOWHERE in the
   schema (an app-local appearance setting beside the phantom kill
   switch — follow that face's precedent); `renderedText`, export,
   and the bridge are byte-untouched (pin that no store write occurs
   on toggle).
5. **A24 — spellcheck levels, COARSE.** Her row: *"different levels
   of spellchecking"*. TEXTKIT2 §3's warning scopes this: continuous
   spell check + the completion popover has crashed TK2 — keep it
   coarse (off · check-while-typing · check+correction — three
   levels, no finer), a Settings face applying to the TK2 editing
   surfaces through their existing configuration point, default =
   today's shipped behavior (record what that IS as part of the
   trace). Exercise the crash class in a hosted pin as far as the
   harness allows; what the harness cannot reach is recorded for the
   Design & UI review's screenshot drive, not claimed.

**Binding for all five:** P-1 (doors/settings declared where the
registry reaches them; surface-local faces recorded, not declared —
Stage 4 lesson 10); refusals speak (P-2); no schema change anywhere
in this batch (if any item seems to want one, STOP — that is a §12
lockstep event and never a batch's call); the loop, records, and
constraints exactly as batches 1–3 (checksums before reverts; the
array-subscript pin rule; full suites with quoted "Test run with N
tests" lines; batch record appended; commits per convention — one per
item is fine if the diffs read cleaner; never `/Applications`, never
`Sources/VariorumCore/Sync/`, never push). Baselines to
match-or-beat: core 882/100 · Mac 831/137 · mobile 14/4 (A16's setter
touches core — if any diff lands under `Sources/` or `Shared/`, run
the affected suites and quote their lines).

### Batch 5 — the sitting's builds: #37(iii) · A12 · the idle-voice line · A22 · A11 (fresh Opus implementer; the phase's LAST build batch)

Five items, every one RULED at the 2026-07-28 sitting (the sitting
record above is the binding text). **Read IN FULL:** `CLAUDE.md` + the
canon it loads (AppSpec §9's `shelveInDailyJournalBook` +
`createOrOpenJournalEntry` entries, the QUESTIONS #26(a) daily-book
record, the §14 2026-07-12 spacing ruling and Phase 3 seam-trimming
delta); THIS plan file (the sitting record; batches 1–4's records +
adopted rules); the 13c plan's "Environment traps" + its Batch 1D
record (the bridge shelving build) + the A47b/A47c sections and
`notes/plans/phase-13d-memo-long-content-panes.md` §3 (anyone touching
`PaneSurface`/`LongBlockLayout` reads them first — binding);
`notes/plans/phase-13c-memo-block-extent.md` Part 2 (the phantom fix
A22 must compose with).

1. **#37(iii) — the ensure half moves INTO the shared door.** With NO
   daily journal book designated (or a designation dangling at a dead
   book), `shelveInDailyJournalBook` now CREATES AND PINS the Journal
   book exactly as ⌘J's first press does — ⌘J then delegates its
   whole ensure to the shared door, so the bridge landing, the
   phone's capture, and ⌘J share ONE rule with no creation residue at
   the ⌘J door. Unchanged and binding: the op NEVER throws (a landing is
   never blocked — return what happened); the already-decided rule
   (any membership row, live or tombstoned) is untouched; the
   finished/full-book paths keep their statuses and wording. The §9
   canon delta lands with this item (the "It never creates a book"
   PROVISIONAL sentence superseded by her ruling, quoted) — the
   orchestrator reviews it at adjudication. Core change ⇒ core tests;
   run all three suites.
2. **A12 — the destructive-undo warning, her definition exactly:**
   the confirm fires ONLY when the undo would discard text edited
   since the operation (the fourth-occasion insurance class — the
   condition the undo path already computes to decide the quiet
   auto-commit); every other structural undo stays silent; redo
   untouched. The dialog names what would be set aside and that the
   insurance commit preserves it. Pins: fires exactly on the class,
   silent otherwise, cancel leaves everything untouched.
3. **The idle-voice-switch render fix** — the panes memo §6 item 5's
   one-line restore on the font-swap branch (edge 3 in the memo's §3);
   pinned.
4. **A22 — typewriter room, RULED shape:** ~one viewport-page of
   scrollable allowance below the last line, ALWAYS ON, Write's
   full-document editor only (Outline/Book/Read/panes untouched — her
   ask and the A47b story are the post editor); a click in the room
   lands the caret at the end of the text. The room is ALLOWANCE,
   never content: zero store bytes (pin via row/byte counts +
   renderedText), the edge-trimming rules byte-untouched, the hybrid
   jump and scroll-restore still land text correctly with room below,
   and it composes with the phantom heal (room applies below HEALED
   geometry; the heal's law untouched). TK2 discipline binds (inset/
   allowance-level mechanism; never TK1 APIs). **STOP-and-propose if
   the mechanism must modify the heal path or `LongBlockLayout`** —
   otherwise build.
5. **A11 — the blank line divides into the FIRST half:** dividing at
   an empty line today drops the blank from both halves (her report:
   it lands NOWHERE). Ruled: the standing k−1 ownership rule applies
   at divide — "para1\n\npara2" cut at the blank yields first half
   "para1\n" (k−1 trailing) and second "para2"; the editor separator
   re-creates the last newline, so the SURFACE reproduces the blank
   line byte-for-byte and `renderedText` round-trips. Land it in the
   ONE cut brain (the seam-trimming function every divide door
   consults — plain divide, the ceremony's per-take cuts, extract
   edges), red-on-old pinned on her report. **STOP-and-propose if the
   trace shows the mechanism is NOT the seam-trim function.**

Loop, records, constraints: batches 1–4's exactly (checksums; the
array-subscript pin rule; tutorial spine; FULL suites with quoted
"Test run with N tests" lines — all three, since items 1 and 5 touch
core; mobile destination = iPhone 17 family/16e). Baselines to
match-or-beat: core 887/101 · Mac 858/143 · mobile 14/4. Never
`/Applications`, never `Sources/VariorumCore/Sync/`, never push.
Append the batch record; commit per convention (canon may be its own
commit).

## Batch records

*(Implementers append here — one record per batch: changes, files,
pins named, counts by own runs, PENDING marks.)*

### Batch 1 — the three ruled walk flips (#43(a) · #44(c)/#45(c) · #47(c))

**Counts, by my own runs:** core `✔ Test run with 882 tests in 100 suites
passed after 28.582 seconds` (**882/100** — the baseline exactly; zero
`Sources/` lines, so unchanged by construction rather than by luck) · Mac
`✔ Test run with 790 tests in 135 suites passed after 87.783 seconds`
(**788/135 → 790/135**: +2 tests, no new suite). **Mobile untouched by
construction, not by assumption** — the mobile target's
`fileSystemSynchronizedGroups` are `VariorumMobile/` + `Shared/`, and every
file here is under `Variorum/` (Mac) or `VariorumTests/`; 14/4 stands
unrun. **Zero schema, zero `Sources/VariorumCore/` lines, zero
`Sources/VariorumCore/Sync/` lines.** Tutorial spine green on its own run
before the full suites: `✔ Test run with 49 tests in 7 suites` (all seven
`Tutorial*Tests` types — addressed by TYPE name, the 2E trap).

**Her instance:** her real-store build was LIVE throughout (`pgrep` →
PID 54248, `/Applications/Variorum.app/…`). Never quit, never touched; no
Release build, no `/Applications` refresh, no store touched. Mac suites ran
beside it on the Debug host as 4G established. Login session unlocked
(`CGSSessionScreenIsLocked` = 0), so the runner behaved normally.

**Diff scope — 7 files:** `BookViewModel.swift` (the expansion set's sense
+ the spread's scrub position) · `BookView.swift` (Outline's comments and
the `initiallyExpanded` doc) · `SpreadBookView.swift` (the scrubber in the
flip bar) · `CompareBoardView.swift` (one default) · `TutorialSeeder.swift`
(one lesson paragraph) · `BookViewTests.swift` / `CompareBoardTests.swift`
(the pins).

#### Item 1 — #43(a): Outline opens COLLAPSED

**The set was INVERTED rather than seeded, and the choice is 2A's own
argument pointed the other way.** 2A tracked the COLLAPSED set for a traced
reason: a post that ARRIVES (minted by "+ new post in this book", pulled in
by a tag, landed by sync) must take the default with no seeding site to
forget — the silent-miss class. Seeding a collapsed set on every arrival
would have re-introduced exactly that site. Tracking `expandedPosts`
instead makes collapsed-by-default hold for free: a post nobody expanded is
collapsed because it is not in the set. Everything else about the surface
is untouched — the card is batch 12's, expand/collapse-all both stay, focus
still implies expansion, collapse still releases focus (13b 3E's D1), and
collapse state is still session/view-scoped (#43(b) unchanged).

One consequence worth naming: `BookView.init(initiallyExpanded:)` is
load-bearing again (2A had recorded it as a no-op), and it is what the
hosted pins that measure PROSE now use — the same deliberate act she makes.

#### Item 2 — #44(c)/#45(c): the jump scrubber returns to Book's spread

Face work, as 2B's record predicted: the brain (`scrubIndex`) was still
there and still pinned. What was added is the position half —
`BookViewModel.spreadScrubFraction` (the thumb) and `scrubSpread(fraction:)`
(the landing, which delegates to `openSpread`, so the focus-release rule is
inherited rather than re-implemented). **The domain is the POST LIST** —
`scrubIndex`'s own mapping, reused rather than a second one minted (Stage 4
lesson 8; never live TK2 geometry). The scrubbed post takes the LEFT page.

Layout: the slider sits between the nudge controls, i.e. **beside the
leaf-turn controls**, and the page line moved from the bar's centre to its
trailing end — the arrangement Read's Pages bar already uses, so the two
horizontal surfaces read as one thing, which is the point of her
one-rule-for-both ruling. Nothing else in the bar changed (flip family,
enablement rule, form picker, the conditional arrow shortcuts).

#### Item 3 — #47(c): Compare's related-blocks-only defaults ON

One default (`var relatedOnly = true`) plus its doc comment. **The filter's
SEMANTICS are untouched** — the pre-pass, the kinship notion, the
per-column note, the whole-board honesty state, the filter-OFF placement
and the live-ring release are 2E's, byte for byte, and every 2E composition
pin runs unchanged. The unrelated-pair consequence (the honesty line greets
her first) was in front of her when she ruled; nothing about that copy
changed.

**One in-scope prose correction, flagged rather than buried:** the field
guide's Compare lesson said *"Turn it on against an unrelated post…"*,
which the flip makes untrue of what she'll see. It now reads "Compare OPENS
with 'related blocks only' on… turn the chip off to read the posts whole",
keeping the promise the walk act asserts (`TutorialLookingActsTests`'
`compareHonestyHoldsOnTheLessonsOwnContent`, green). **This stales the
seeded field guide further — it adds nothing new to the standing re-seed
obligation** already on her checklist from 13c (one "Restore Tutorial" run).

#### Pin changes — every one named

| Pin | Change | Why |
|---|---|---|
| `focusImpliesExpansionAndCollapseReleasesFocus` | **flipped** — asserts collapsed-at-open, adds the `expand` arm; set assertions read `expandedPosts` | the ruled default |
| `aPostThatArrivesAfterCollapseAllIsOpen` | **renamed + inverted** → `aPostThatArrivesAfterExpandAllIsCollapsed` | the same traced arrival argument, mirrored with the set |
| `outlineOpensWithItsPostsCollapsed` | **NEW** (hosted) | the ruling itself: zero read surfaces at open, prose on expand-all, cards again on collapse-all |
| `outlineVirtualizesItsRowsWithPostsOpenByDefault` | **renamed** → `…EvenWithEveryPostExpanded`; asserts the collapsed default, then expands | keeps 2A's HARDER P3 claim (prose rows, not cheap cards) instead of quietly weakening it with the default |
| `withHostedBook` (helper) | gains `expanded: Bool = true`, calling `expandAll()` | hosted pins that measure prose must expand first; `expanded: false` observes the default |
| `theSpreadKeepsItsBarWithFormsAndNoSlider` | **renamed + inverted** → `theSpreadKeepsItsBarWithFormsAndTheJumpScrubber` (1 `NSSlider`, 1 `NSSegmentedControl`) | the ruled return |
| `theSpreadScrubberRidesThePostListAndRoundTrips` | **NEW** (pure/model) | the landing, the clamps, the thumb's two ends, the round-trip, the focus-release inheritance, the empty book |
| `relatedOnlyHidesTheUnrelatedColumnAndTheBoardSaysSo` | **flipped** — opens filtered; the unfiltered board is now reached by turning the chip OFF (2E's OFF side still pinned, in the same test) | the ruled default |
| `turningOnRelatedOnlyReleasesARingItHidesAndLandsTheText` | turns the chip OFF first, then on | a set that doesn't CHANGE the value never runs the release guard — without this the pin would have gone hollow under the new default |
| `relatedOnlyLeavesARingItDoesNotHideAlone` | same off-then-on for its first arm | same reason (its second arm already did) |

Unchanged and re-run green: all 13 `CompareCompositionTests` (the filter is
pure and its semantics didn't move), `outlineCarriesNoBottomChrome` (Outline
still carries no slider — her A6 complaint was a horizontal control on a
VERTICAL page, and this batch does not touch that), `PagedReadTests`' Read
slider count (the other half of "scrubbers on BOTH").

#### Guard-revert evidence (three source files checksummed first; `shasum -c` OK after every restore)

**Class statement:** these are RULED FLIPS and one new capability, not bug
fixes — no pin is owed under the hallucination guard. Four surgical reverts
were run anyway, because a flipped pin that would also pass on the old code
is worth nothing.

| Revert | Pins that went RED | Observed |
|---|---|---|
| **A** — `isExpanded` returns `true` for anything (the pre-13d open-by-default sense) | `outlineOpensWithItsPostsCollapsed` · `focusImpliesExpansionAndCollapseReleasesFocus` · `aPostThatArrivesAfterExpandAllIsCollapsed` · `outlineVirtualizesItsRowsEvenWithEveryPostExpanded` | **4 pins, 7 issues** — chiefly **4 read surfaces** in a hosted 6-post Outline where 0 is right (the ruling, at the surface) |
| **B** — the `Slider` removed from the flip bar (2B's shipped bar) | `theSpreadKeepsItsBarWithFormsAndTheJumpScrubber` | 1 issue: **0 `NSSlider`** where 1 is right |
| **C** — `relatedOnly = false` (2E's default) | `relatedOnlyHidesTheUnrelatedColumnAndTheBoardSaysSo` | 5 issues: not filtered at open, the stranger's free row present, `peerHasBlocks == [true, true]`, 3 rows where 2 are right |
| **D** — `spreadScrubFraction` divides by `count` instead of `count − 1` | `theSpreadScrubberRidesThePostListAndRoundTrips` | **First run: GREEN — and that was the useful result.** An `i / count` thumb round-trips exactly as well, so the round-trip arm alone did not discriminate; the pin gained the arm that does (the thumb must reach BOTH ends of the track) and revert D then read **0.8 where 1.0 is right** — the last page never reaching the track's end |

#### Judgment calls

1. **Invert the set, don't seed it** (item 1's headline). The brief left the
   choice open; this is the one that keeps 2A's traced arrival argument
   true instead of trading it away.
2. **`expandAll()` stays scoped to the entries in hand**, the exact mirror
   of what `collapseAll` carried before — so a post arriving after an
   expand-all is collapsed (the default), not a survivor of the gesture.
   Pinned. The alternative (expand-all as a sticky mode) would be a new
   third state nobody ruled.
3. **`outlineVirtualizesItsRows…` kept its harder claim** by expanding
   everything rather than accepting the now-cheaper default. Letting it
   count cards would have quietly retired the Phase 13 round-3 MAJOR's
   guard.
4. **The page line moved to the bar's trailing end** to give the scrubber
   the flexible middle (a centred text between two `Spacer`s cannot share a
   row with a flexible slider). Recorded because it is the one visual
   change in the bar beyond the control she asked for; it makes Book's bar
   match Read's Pages bar, which is the ruling's own spirit.
5. **The scrubber is `.disabled` on a one-post book**, not hidden — the
   flip controls in the same bar disable rather than disappear, and one bar
   should not speak two grammars.
6. **The Compare lesson's paragraph was corrected** (above) rather than
   left describing an act she no longer has to perform. P-6 reading:
   tutorial prose that contradicts the shipped surface is a regression.
7. **`QUESTIONS.md` annotated, not resolved:** the four ruled sub-calls
   (#43(a), #44(c), #45(c), #47(c)) now carry a one-line "RULED … — BUILT
   13d batch 1" marker pointing at the 13c walk record, because leaving
   "SHIPPED — PROVISIONAL" text describing the opposite of the code is the
   drift class 13c's R1-2 punished. The entries stay OPEN as wholes (their
   minor sub-calls are rolled to this phase's sittings), and nothing was
   renumbered or removed — that remains the closeout's call.

#### Deviations

- **None from the brief's three items.** Nothing else was built; no item
  turned out bigger than its ruling's shape, so the stop-and-propose door
  was not needed.
- **One self-inflicted incident, recorded because the rule exists for
  exactly it.** While restoring guard-revert B I ran
  `git checkout Variorum/Features/BookView/SpreadBookView.swift` — the
  environment's "never `git checkout` over uncommitted work" line — which
  discarded that file's three uncommitted edits (header, slider, page
  line). No other file was touched; the edits were re-applied from context
  and the file verified **byte-identical to the pre-revert checksum**, so
  nothing was lost and the proof is mechanical rather than my say-so. The
  checksums taken before the revert pass are what made that provable.
- **No lookup subagent used** — nothing external was in question.
- **No visual loop this batch** (P-7's screenshot half): the three changes
  are a default, a control's presence, and a default; the hosted pins
  observe all three at the layer where they can fail. The one thing a human
  eye would add is whether the bar reads well with the scrubber in its
  middle — routed to the standing **Design & UI review** row rather than
  claimed.

#### PENDING / for the orchestrator

- **Nothing unverified in this batch.** Both full suites were run by me,
  with their run lines quoted above.
- The **field-guide re-seed** obligation (hers, standing since 13c) now has
  one more stale lesson behind it; still one "Restore Tutorial" run.
- **For the end-of-phase Fable review, suggested foci:** (1) the set
  inversion — is the arrival argument really symmetric, and is there a
  caller that assumed "not in the set ⇒ open"? (2) `withHostedBook`'s
  `expanded: true` default — does it hide any pin that should be observing
  the collapsed state? (3) the scrubber's domain — Book scrubs by POST
  while Read scrubs by PAGE, so the two bars now look alike and mean
  slightly different things; is that the right reading of her one rule?
  (4) whether the moved page line costs more than it buys.

#### Batch 1 — ACCEPTED (2026-07-27 late evening; the successor orchestrator's adjudication)

**Counts by my own runs** (not the implementer's): core `✔ Test run
with 882 tests in 100 suites passed after 31.242 seconds` · Mac
`✔ Test run with 790 tests in 135 suites passed after 88.133 seconds`
— both match the record's claims exactly; tree clean at `8c07717`.

**Load-bearing diffs read:** the set inversion is COMPLETE (zero
`collapsedPosts` references remain anywhere in `App/`; every consumer
routes through `isExpanded()`; focus-implies-expansion now rides an
insert — same semantics, D1 preserved); the scrubber is model-driven
(`spreadScrubFraction` the exact inverse of `scrubIndex`'s mapping,
landing through `openSpread` so focus-release is inherited),
disabled-not-hidden on one-post books, and the bar's chrome text keeps
`lineLimit(1)` (P-8's b6dae25 class held); Compare's flip is one
default plus honest doc comments recording both the ruling and 2E's
superseded reasoning; the QUESTIONS #43/#44/#45/#47 annotations are
bracketed RULED-markers that preserve the original prose with the
entries staying OPEN as wholes — the right R1-2 drift-avoidance shape,
and the closeout still owns their disposition. The de-hollowed ring
pins verified in the diff: they now drive a real false→true
transition, and revert C's 5-issue red shows the family discriminates.

**Review focus (3) adjudicated NOW, the rest ride:** Book scrubbing by
POST while Read's Pages scrubs by PAGE is the ruling's own letter —
her #44(c)/#45(c) ruling was about PRESENCE on both horizontal
surfaces; Book's jump domain has been the post list since S4-9(2) and
2B ("40 posts are 40 pages"), and Read's page domain is its own
brief's §4. No re-read needed; foci (1), (2), (4) stay listed for the
end-of-phase Fable review.

**The disclosed `git checkout` incident:** accepted as recorded — one
file, self-caught, restored and PROVEN byte-identical by the
pre-revert checksum, no other file touched, and the record names the
rule it broke. The pre-revert checksum discipline is what made the
recovery provable; noted as the practice every future revert pass
should copy. No further action.

**Revert D's lesson endorsed:** a round-trip arm alone did not
discriminate the thumb's denominator; the both-ends arm does. That is
the guard working as designed — the pin was strengthened BEFORE the
fix was trusted.

**Judgment calls 1–7 all endorsed** — in particular call 3 (keeping
the virtualization pin's HARDER claim by expanding everything rather
than letting the collapsed default cheapen it) and call 7 (annotate,
never resolve, QUESTIONS). Batch 2 (#34) proceeds.

### Batch 2 — #34, backspace-merge at a texted seam

**Counts, by my own runs:** core `✔ Test run with 882 tests in 100 suites
passed after 29.177 seconds` (**882/100** — the baseline exactly; **zero
`Sources/` lines** in the diff, so unchanged by construction) · Mac
`✔ Test run with 808 tests in 136 suites passed after 89.908 seconds`
(**790/135 → 808/136**: the new `SeamMergeTests` suite's 18 pins; the one
1B pin the ruling reverses was rewritten in place, not added). Tutorial
spine green on its own run first: `✔ Test run with 49 tests in 7 suites`
(all seven `Tutorial*Tests` types by TYPE name — the 2E trap).
**Mobile untouched by construction:** every file here is under
`Variorum/` (Mac) or `VariorumTests/`; nothing in `Shared/` or
`VariorumMobile/`. 14/4 stands unrun. Zero schema, zero
`Sources/VariorumCore/Sync/` lines.

**Her instance:** her real-store build was LIVE throughout (`pgrep` →
PID 54248, `/Applications/Variorum.app/…`). Never quit, never touched;
no Release build, no `/Applications` refresh, no store touched. Mac
suites ran beside it on the Debug host (4G).

**Diff scope — 6 files:** `BlockRangeIndex.swift` (the shared separator
geometry + `textedSeamPair`) · `EditorSurfaceController.swift` (the plan,
the run, the refusal copy, the shared fan read) · `EditorViewModel.swift`
(the routing branch + two forwards) · `SeamMergeTests.swift` (NEW, 18
pins) · `BlockDeletionAndRedoTests.swift` (the one reversed pin) ·
`notes/AppSpec.md` + `notes/QUESTIONS.md` (the canon delta, its own
commit).

#### The precedence vocabulary, as built

At a deleted **inter-entry separator** (the one range shape that belongs
to no block, which is why it reaches `.refuse(.crossesBlockBoundary)` at
all), `shouldChangeText` now asks three questions in this order:

1. **A7's carve** — a neighbour that is empty on the surface, unfanned,
   editable, carrying nothing unshown → that block is deleted, with the
   authorization re-read inside `deleteBlock`'s own transaction.
   **Byte-unchanged by this batch**, guards and all; #40's named/callout
   reading and #42's redo refusal are untouched and their pins run green.
2. **NEW — the seam merge** — both neighbours texted, neither carrying a
   live active fan → the ordinary binary `merge`.
3. **NEW — the seam refusal** — both texted, either side fanned → the
   fan is named and ⌘⇧M pointed at. Nothing is written.

…and only then the two standing cross-block plans (merge-then-edit, the
visible-take edit), which cannot see this range anyway — both collect
targets by INTERSECTION, and a lone separator intersects nothing (pinned
here as well as in 1B).

**1 and 2 are mutually exclusive BY CONSTRUCTION**, not by ordering: one
requires a zero-length neighbour, the other requires neither. Pinned by
walking every offset of a `["", "alpha", "beta", ""]` document and
asserting at most one of them ever answers — with a non-vacuity arm
showing both are reachable in that same document.

**One small refactor rather than a second walk:** both now consult
`BlockRangeIndex.interEntrySeparatorPair(deleting:isDeletion:)` — the ONE
geometric question ("which pair does this separator sit between?"),
extracted from `emptyBlockDeletion`'s body with its behaviour unchanged
(same guards, same walk, same both-empty tie-break; 1B's carve pins run
untouched and green). Two hand-walked copies of the tiling would have
been the sediment class this phase's constitution names.

#### "Has takes" — one rule, and where it is read

The condition is the **merge ceremony's own instant-vs-ceremony
threshold** (S4-23 ruling 4): *any live ACTIVE fan on either side*.
`openMergeCeremony` and the seam keystroke now call ONE helper
(`liveActiveFans`) — the ⌘⇧M door's truth read, shared by name, not a
second fan test. So the keystroke fires exactly where merge would be
instant and refuses exactly where merge would open the sheet.

**It is read at RUN time, from the STORE — deliberately not at plan
time from `model.slots`, and this is the batch's one real design
decision.** The projection engine freezes `slots` for the whole of a
typing burst (`EditorProjectionPolicy.decide` → `.deferUntilClean` while
the buffer is dirty, and autosave's debounce re-arms on every keystroke).
That freeze is exactly what the 13c ladder's R3-1 finding was about one
door over: a plan-time guard reading it is an enablement hint, never an
authorization. A7 could move its authorization into the operation
(`BlockDeletionPrecondition`); merge has no such parameter, and adding
one would be core surgery well past this brief — so the honest available
authorization point is the run's own truth read, which is also the read
the explicit gesture already trusts. `planSeamMerge` therefore asks about
GEOMETRY and liveness only and is stale-blind on purpose (pinned as
such). **The pin that makes this real is
`aFanArrivingWhileSheIsTypingStillStopsTheMerge`**, the direct mirror of
1B's `aCommentArrivingWhileSheIsTypingStillStopsTheCarve`: it drives the
frozen projection deliberately (no `reload()`), and guard-revert D shows
it is the ONLY pin that discriminates the two readings.

#### Point 4 — the parity answer

**The carve accepts any DELETION (empty replacement) of exactly one
inter-entry separator, whatever gesture proposed it**, and the merge case
accepts identically — because it is the same range, not because three
wirings were kept in step. Concretely that is: **backspace at a block's
start** · **forward-delete at the previous block's end** · **selecting
the separator character and deleting (or cutting) it**. All three propose
`(separatorOffset, 1) → ""`. Each is pinned end to end. What neither
accepts, unchanged: a replacement (typing over the seam), a range longer
or shorter than the one separator, a range starting or ending inside a
block, the TAIL separator (that is `closeTail`'s, and `verdict` answers
it before this branch is ever reached), and a single-block or empty post.

#### What the merge IS (nothing invented)

`runInstantMerge` — the same body the ⌘⇧M gesture runs, reached
unchanged: `runStructural`'s one-flight door (flush first, non-editable
for the flight, store-led rewrite), `ops.merge`, `MergeJoin.canon`'s
single space at the join, the differential `.merge` seam edit, the caret
at the join, ONE undo entry labelled **"Merge"**, and 1B's redo half
riding the same registration (do → undo → redo pinned). A **sealed post**
never reaches the act: `adoptHeader` makes the surface non-editable, so
the keystroke is not even proposed (pinned at the mechanism, plus the
model's own spoken refusal). A **locked take** deliberately does NOT
refuse — merge copies rendered texts and never edits a buffer, so the
explicit gesture allows it and parity is the rule for this door too.

#### Pins — every one named

| Pin | Change | Why |
|---|---|---|
| `backspaceBetweenTwoBLOCKSWITHTEXTStillREFUSES` (1B) | **rewritten + renamed** → `theCarveStillNeverNamesASeamBetweenTwoBLOCKSWITHTEXT`; the behavioural half moves to the new suite, the narrowness half stays | the ruled flip — that keystroke is no longer a refusal. Recorded as a RULED CHANGE, not a bug fix |
| `SeamMergeTests` (NEW suite, 18) | new | the ruling: geometry, six cannot-widen arms, mutual exclusion, the three gestures end to end, the two fanned refusals, the copy, the mid-burst staleness pin, the seal, and A7-still-wins-at-an-empty-neighbour |

Everything else in `BlockDeletionAndRedoTests` — the nine cannot-widen
pins, the archived-take and comment guards, #40's named/callout
PROVISIONAL, #42's redo refusal, the A8 door, the redo family — ran
UNCHANGED and green.

#### Guard-revert evidence (checksums taken first; `shasum -c` OK after every restore)

| Revert | Applied | Observed RED |
|---|---|---|
| **A** — the routing branch unwired (`else if false, let seam = …`): the exact pre-ruling world, where that keystroke did nothing | `EditorViewModel.shouldChangeText` | **6 pins, 15 issues** — the store keeps `["alpha","beta"]`, the surface keeps the separator, the undo stack stays empty, the caret never moves, and the message reverts to the generic cross-block refusal copy. **Her reported behaviour, reproduced exactly** |
| **C** — the fan guard removed (`count >= 1`), everything else intact | `runSeamMerge` | **3 pins, 12 issues** — a fanned seam MERGED (`["alpha beta"]`), an undo entry appeared, and the refusal copy became "Blocks joined". The guard is what stands between a keystroke and a folded fan |
| **D** — the fan read taken from `model.slots` instead of the store (a plan-time-style guard, the tempting shape) | `runSeamMerge` | **exactly 1 pin, 5 issues** — `aFanArrivingWhileSheIsTypingStillStopsTheMerge` alone goes red (the two ordinary fanned pins stay GREEN, because they `reload()`): the merged block ate "beta" AND the take that had just arrived on it. This is the pin that earns the design |

**One incident, recorded because the guard is what caught it.** Revert C's
first run CRASHED the test process (`Index out of range`) and truncated
the run's evidence — the trap was in MY pin, not the code: it subscripted
`after[1]` after asserting `after.count == 2`, so in the reverted world
(where the blocks merged) the subscript trapped before the remaining
expectations could record. Fixed by reading through `first` /
`dropFirst().first`, the suite re-verified green, and revert C re-run for
clean evidence (the table's numbers are the clean run). Worth keeping as
a rule: **a pin whose red state changes an array's length must not
subscript it** — a trapped pin destroys the very evidence the revert was
run to produce.

#### Judgment calls

1. **The fan is read from the store at run time, not from the projection
   at plan time** (the section above). The alternative — a fast plan-time
   arity guard like the `.merge` door's — would have been a *second* fan
   test, and a stale one; revert D is the receipt.
2. **The plan does not carry the fanned case as a variant.** It answers
   "is this a texted seam at all"; the run answers "may it merge". One
   place asks about takes, which is what point 2's "no second fan test"
   means in practice.
3. **A successful join SPEAKS** ("Blocks joined — ⌥⌘Z undoes it."),
   following A7's carve rather than merge's silence. Load-bearing, not
   chatter: a structural act just landed from an ordinary keystroke, and
   ⌘Z cannot take it back (the structural rewrite clears the text-undo
   stack by design), so the line names the door that can. If she finds it
   noisy it is one line to make transient or drop — flagged for her walk.
4. **`runInstantMerge` gained a `@discardableResult` Bool** so the seam
   path can speak only when the merge actually landed. No behaviour
   change to the ⌘⇧M door.
5. **Locked takes merge** (parity with the explicit gesture, above)
   rather than inventing a keystroke-only refusal.
6. **The refusal names WHICH side carries the fan** (above / below /
   both) rather than a generic "this seam has takes" — the same instinct
   as `speakAboutMergedFans`, which names the road rather than gesturing
   at it.
7. **No §9 edit.** The seam keystroke is a DOOR onto the existing `merge`
   operation, and §9 describes operations; the reach change is §14's
   business, which is where the brief put it. The §14 delta names the
   Stage 1 delta sentence it supersedes rather than rewriting that
   paragraph (batch 1's annotate-don't-rewrite shape, endorsed).
8. **`QUESTIONS.md` #34 annotated, not resolved** — a bracketed "BUILT
   13d batch 2" marker inside the existing ANSWERED status; the entry's
   disposition stays the closeout's.

#### Deviations

- **None from the brief's six points.** The shape bound; nothing turned
  out materially different from the brief's description, so the
  stop-and-propose door was not needed.
- **One in-scope refactor beyond the literal shape:** the shared
  `interEntrySeparatorPair` extraction and the shared `liveActiveFans`
  read. Both are the "ONE brain" discipline the brief's own points 1 and
  2 ask for, and neither changes existing behaviour (the carve's pins and
  the ceremony's pins run unchanged).
- **No lookup subagent used** — nothing external was in question.
- **No visual loop** (P-7's screenshot half): there is no new pixel in
  this batch — a keystroke that previously did nothing now runs an
  existing operation, and its two visible outcomes (the joined text, the
  status line) are observed by hosted pins at the layer where they can
  fail.

#### PENDING / for the orchestrator

- **Nothing unverified.** Both full suites were run by me, run lines
  quoted above.
- **For the end-of-phase Fable review, suggested foci:** (1) the read-
  then-act window — `liveActiveFans` reads, then `runStructural` flushes
  and merges, so a take born in that sub-ms window still folds away; it
  is the SAME window the explicit ⌘⇧M door has had since 13b 4B (its
  threshold read precedes its own confirm), so closing it means a
  `merge(_:requiring:)` precondition at the ops layer, deliberately not
  invented here — is that the right line? (2) the status line on every
  join (judgment call 3) — right call or noise? (3) whether any other
  surface reaches a seam keystroke (I found none: seams exist only in the
  full-document editor; take panes are single-block). (4) the `Merge`
  undo label — the keystroke and the gesture now share it, so her undo
  menu cannot tell her which door she used; deliberate (it IS the same
  act), but worth a second opinion.

#### Batch 2 — ACCEPTED (2026-07-27 night; the orchestrator's adjudication)

**Counts by my own runs:** core `✔ Test run with 882 tests in 100
suites passed after 31.064 seconds` · Mac `✔ Test run with 808 tests
in 136 suites passed after 90.155 seconds` — both match the record's
claims exactly; tree clean at `ac2074f`.

**The §14 delta REVIEWED and it STANDS** (the brief reserved this to
the orchestrator): her ruling quoted verbatim, option (ii) named as
what she was shown, the second-named-exception framing correct and its
grounds distinguished from A7's, the supersession of the Stage 1
delta's closing sentence exactly right (that sentence said the
question was live; the walk answered it), and the shape section states
only what shipped. No §9 edit is the correct call — the keystroke is a
door onto the existing `merge` operation, and §9 describes operations.

**Load-bearing diffs read:** the `interEntrySeparatorPair` extraction
gives both carves ONE geometry with the A7 walk byte-unchanged (its
pins run untouched); mutual exclusivity is structural, pinned by the
every-offset walk with a non-vacuity arm; the fan authorization reads
the STORE at run time through `liveActiveFans` — the ⌘⇧M door's own
threshold read, shared by name — which is the 13c R3-1 lesson applied
at the right level, and revert D (exactly the mid-burst pin red, the
ordinary fanned pins green because they reload) is the receipt that
the pin discriminates the two readings. Locked-takes-merge is parity
with the explicit gesture's Phase 3 op semantics, not an invention;
the seal refuses upstream at `adoptHeader`.

**Judgment calls 1–8 all endorsed.** Call 3 (the "Blocks joined —
⌥⌘Z undoes it." line) endorsed as LOAD-BEARING, not chatter: ⌘Z
cannot reverse a structural act (the rewrite clears text-undo by
design), so the line names the only door that can — its taste half
joins the sitting bundle beside review focus (2). Call 5's parity and
call 7's no-§9-edit reasoning are exactly right.

**The pin-crash incident accepted as recorded**, and its rule is
ADOPTED for the phase: *a pin whose red state changes an array's
length must not subscript it* — a trapped pin destroys the evidence
the revert exists to produce. The clean re-run's numbers stand.

**The read-then-act window: recorded, deliberately not closed.** It is
the same sub-ms window the explicit door has carried since 13b 4B; the
ops-level close (`merge(_:requiring:)`, the `BlockDeletionPrecondition`
pattern's merge twin) is real work past this brief and is left for the
end-of-phase review to weigh — foci (1)–(4) all ride. Batch 3 (A9)
proceeds.

### Batch 3 — A9: divide NATIVELY in Takes

#### THE PROPOSAL (gate open — nothing built yet; awaiting the orchestrator's ruling)

**Gate answer first: the unfanned plain-divide half was NOT built before
the gate, and could not honestly have been.** It needs (c) — the flight
latch and the pane freeze — for *correctness*, not polish (the traced
mechanism is in (c) below), and it needs the same registry flip and door
wiring the ceremony half needs. Shipping it alone would leave `.divide`
declared `.native` in Takes while the FANNED case — which in Takes is the
ordinary case — had no native path, i.e. a door that acts sometimes and
lectures otherwise: the exact D3 class P-2 retired. So: one build, after
the ruling.

##### What I found about the current coupling (the survey the gate is for)

The W ceremony's state machine is **already almost surface-independent**.
`EditorSurfaceController` lines 1800–1990 hold `DivideWCeremonyState` /
`WTake` / `openDivideWCeremony` / `toggleWTake` / `placeWCut` /
`cancelDivideW` / `confirmDivideWCeremony` / `refreshDivideWCeremony`, and
what they actually touch is only:

1. `model.autosave.flushNow()` + the `isDirty` refusal — the **per-post**
   coordinator (`session.autosave(forPost:)`), which `TakesViewModel`
   already holds (same object, same post);
2. `model.session.database.read { Queries.blockFan(...) }` — plain store
   reads;
3. speech (`showStatus` / `showOperationError` / `refuseFeedback`);
4. `structuralInFlight` — one read, as the confirm's pre-await guard;
5. `runStructural { ops.divideW(blockID, cuts:) }` — the ONE genuinely
   Write-shaped thing (flush → freeze the TK2 view → `awaitMintSettle` →
   op → re-fetch `renderPost` → rewrite the full-document surface).

Only (5) is Write's. (1)–(4) exist in both surfaces already. **One
Write-specific coupling is real and must be generalized**: the seed take
is derived from Write's own index —
`model.index.entries.first { $0.blockID == blockID }?.variantID`, i.e.
*the chosen take* — and the sheet then refuses to open unless that take is
in the live fan. In Takes the caret may sit in a **non-chosen** pane, so
the seed must be a parameter. That is the "small generalization" the brief
names, and it is one argument, not a redesign.

`DivideWSheet` touches the model at exactly five points:
`divideWCeremony` (read), `toggleWTake`, `placeWCut`, `cancelDivideW`,
`confirmDivideW`. Everything else in that file (`WCutFlow`,
`CutFlowLayout`, `WCutPlacement`) is already pure over `WTake`.

Two more facts the survey turned up, both load-bearing below:

- **`ops.divide` refuses a fanned block inside its own transaction**
  (`OperationError.fannedBlock`), and `openDivideWCeremony` already
  re-reads the fan and bails when it finds fewer than two live active
  takes. So *both* forks are already honest against a stale arity — but
  neither has app copy for `fannedBlock` (the editor's switch and
  `OpsRefusalCopy` both fall through to a raw enum dump). See (d).
- **Takes and Lenses share ONE `TakesViewModel`.** Every native
  block-scoped door built since 13b — `insertBlockBelowFocused`,
  `deleteFocusedBlock` (13c 1B/A8), `applyCallout` (13c R2-2/A13(a)) —
  is a model method both `TakesBoardView.handleRouted` and
  `LensesBoardView.handleRouted` call. See (e).

##### (a) Where the ceremony state machine lives, and what is extracted

**Extract `DivideWCeremony`** — a new `@MainActor @Observable final class`
in `Features/Editor/` (feature-side by design: storage-coupled code stays
with the feature, the Stage 1b judgment call) owning `state:
DivideWCeremonyState?` and the whole machine: `open(blockID:
seedVariantID:seedCut:)`, `toggle`, `place`, `cancel`, `confirm`, the
drift check and `refresh`. `DivideWCeremonyState` and `WTake` move with
it, unchanged.

It reaches its host through ONE small protocol — the four things above,
named honestly:

```swift
@MainActor protocol DivideWCeremonyHost: AnyObject {
    var database: AppDatabase { get }
    func flushPendingText() async -> Bool      // false ⇒ refused, text pending
    var structuralFlightInProgress: Bool { get }
    func runDivideW(blockID: String, cuts: [String: Int]) async -> Bool
    func speak(_ message: String)
    func speakError(_ error: Error)
}
```

`EditorSurfaceController` conforms by forwarding — `runDivideW` is
`runStructural { ops.divideW(...) }` with the existing `seam: nil` full
re-render, byte-unchanged. `TakesViewModel` conforms with its own runner
(see (c)).

**Parity-by-forwards, so every existing pin and view reads unchanged:**
`EditorSurfaceController.divideWCeremony` becomes a get/set forward to
`ceremony.state`; `toggleWTake` / `placeWCut` / `cancelDivideW` /
`confirmDivideWCeremony` forward; `EditorViewModel`'s existing forwards
and its `DivideWCeremonyState` / `WTake` typealiases re-point. Every
`StructuralGestureTests` / `GestureSoakTests` call site
(`h.model.divideWCeremony`, `h.model.toggleWTake`, …) compiles and passes
untouched — that is the batch contract, exactly as N10's move was.

*Alternative considered and rejected:* leave the machine on
`EditorSurfaceController` and have Takes drive it through a hidden
EditorViewModel. That mounts a full-document editor nobody sees to run a
sheet — P-3's "the full-document editor is never absorbed", inverted.

##### (b) How the sheet mounts on the Takes board

`DivideWSheet` is re-parameterized from `model: EditorViewModel` to
`ceremony: DivideWCeremony` (observable, so live marks/cuts still
re-render; `presented:` stays the `.sheet(item:)` snapshot). Then:

- `EditorView` keeps `.sheet(item: $model.divideWCeremony)` **unchanged**
  (the model's forwarding property is already a get/set computed) and
  passes `model.divideWCeremonyController`.
- `TakesBoardView` and `LensesBoardView` each add
  `.sheet(item: $model.divideWCeremony)` beside their existing diff/lens
  sheets, passing the model's own ceremony.

The board's own sheet mount means the ceremony opens **in place** — no
mode switch, which is the whole of A9 (constraint 6).

##### (c) The ONE-flight door for a Takes-native structural act — and a correctness finding

**The finding, traced, because it decides this point.** In Write,
`runStructural` sets `textView.isEditable = false` for the flight and the
comment says why: *"a stale whole-buffer autosave after a divide would
resurrect the moved half — the forbidden text-duplication class."* A
Takes pane has exactly the same shape: a keystroke between the flush and
the op calls `paneEdited` → `autosave.record(variantID:text:)` with the
**pre-divide full text**, and when that debounce fires it writes the whole
old text back into the source variant — which `ops.divide` has just
truncated. Result: the second half lives in block A *and* in the new block
C. So a Takes-native divide needs its panes frozen for the flight; this is
not defensive tidiness.

**Proposed:** a `structuralInFlight` latch on `TakesViewModel` (observable),
taken synchronously at the door before any await, released in a `defer` —
Write's shape. It does two jobs: it refuses a second divide (including the
sheet-confirm-vs-⌘⇧D race Write's round-3 MINOR closed, since key
equivalents stay live under a window-modal sheet), and it **freezes the
panes** by folding into liveness: a new `TakesViewModel.isPaneLive(_ key:)`
returning `authority.isLive(key, sealed: projection.sealed ||
structuralInFlight)`, used at the three `TakesViewModel`-hosted call sites
(`TakesShared.swift:44`, `TakesBoardView.swift:918`,
`WriteTakesPanel.swift:187`). `PaneSurface` already does
`view.isEditable = isLive`, so the freeze is the existing mechanism, not a
new one — **P-3 holds**: the authority still answers "which pane is live";
the model composes its suspension reasons before asking, exactly as it
already composes `sealed`. No `PaneTextAuthority` API change.

*The alternative, named because it is the stricter one:* a **post-keyed
latch on `AppSession`** (the `mergeJoinMemory` / `tutorialDoorInFlight`
precedent) shared with `runStructural`, so Write and Takes hold literally
one door per post. I do **not** recommend it for this batch: the only way
a Write flight and a Takes pane coexist for one post today is
`WriteTakesPanel` (Write's own take panel, which has no divide door), so
the shared latch buys nothing today while costing a change to
`runStructural` — the most heavily pinned structural path in the app — in
a divide-only batch. Say the word and it is a small, separable follow-on.

##### (d) How the confirm's apply and the board's refresh compose

**The apply.** `TakesViewModel.runDivideW` is the `deleteFocusedBlock`
shape with the flight latch added: take the latch → `await
autosave.flushNow()` → `guard !autosave.isDirty` (else speak the standing
"Unsaved changes couldn't be written…" — 13c R2-6's one-act-one-contract
rule) → `session.runner.run { ops.divideW(blockID, cuts:) }` → park focus
→ release. Undo **and** redo ride the ops layer's own registration
untouched (constraint 7); nothing new is registered anywhere.

**The refresh is the board's ordinary projection path** (constraint 8):
the observation fires, `adopt` runs — and it lands rather than deferring
precisely because the flush left the buffer clean. No bespoke re-render,
no `renderPost` fetch, no seam derivation. That asymmetry with Write is
the point: Write must rewrite a TK2 document; a board just re-renders its
slots.

**Focus after the act, mirroring Write's caret rule exactly rather than
inventing one:** plain divide → the successor (`result.variant.id`, Write
puts the caret at the successor's start); the ceremony → the FIRST
successor (`result.first.variants.first`, Write's `caretBlockID:
result.first.block.id`). Delivered through the existing
`choreography.parkFocus(onVariant:)`, which already focuses a minted
variant's pane when its slot arrives (the insert-below handover).

**Two sub-calls inside this point that are genuinely yours:**

- **(d1) Where the fanned/unfanned fork is decided.** I propose the
  **batch-2 precedent: read the block's live active fan from the STORE at
  run time**, after the flush, not from `projection.fans` at plan time —
  the Takes projection is deliberately frozen while any buffer is dirty
  (`adopt`'s `isDirty` defer), so a plan-time arity is an enablement hint,
  never an authorization, and this is the same reading batch 2's revert D
  earned. It costs *nothing*: `openDivideWCeremony` already makes that
  exact read, so the fork consumes a read the ceremony path needs anyway.
  The planner is still the ONE brain — it is handed `fanArities` from that
  fresh read instead of from the projection (constraint 1 is about *which*
  planner, and there is only one). *The alternative* is parity-with-Write
  staleness (plan-time arity + honest `fannedBlock` copy); it is one line
  either way, and (d2) covers it regardless.
- **(d2) `fannedBlock` gets app copy.** Whichever fork rule you pick, the
  window can still close between the read and the op, and today both copy
  paths dump the raw enum. One `case .fannedBlock` in `OpsRefusalCopy` (the
  shared home; the R1-3 class) + the editor's switch. Small, and it is the
  kind of thing that only ever shows up in front of her.

##### How the planner stays ONE brain (constraint 1), concretely

`TakesViewModel` builds a **synthetic single-entry `World`** over the take
the caret is in and calls the existing
`StructuralGesturePlanner.plan(.divideAtCursor, selection:world:)`:
`BlockRangeIndex(entries: [Entry(blockID:, variantID:, length: take text,
editable: !take.locked)], tailLength: nil)`, `fanArities: [live active fan
count]`, `sealed: projection.sealed`, `textAt: { the take's
buffer-overlaid text }`. Nothing is re-implemented and nothing is
parameterized: the seal refusal, the gap refusal, the locked-take refusal,
the word-rule snap (`snapToInteriorBoundary` → `BoundarySnapping.settle`,
constraint 2) and the `.divide`/`.divideW` fork all come back from the one
planner, byte-identical to Write's door. (`touchesTailRegion` is inert with
`tailLength: nil` — a board has no open tail.)

**The caret:** `paneSelection.range.location`, counted only when its
`variantID` is the focused pane's — the choreographer's own existing rule,
reused. With no caret the offset is 0 and divide refuses "nothing to
divide", which is **exactly what the carry door does today** (it lands at
offset 0 in Write); parity, not invention.

##### (e) Lenses parity — the one scope question I am raising rather than assuming

Takes and Lenses share the model, and every native door since 13b has gone
into **both** handlers. `.divide` becoming `.native` also has a registry
consequence: `CapabilityRegistryTests.takesIsNeverBehindWrite` asserts
`.native` ⇒ `availability(.takes) == .act`, so `.divide` leaves the shared
`structural` closure for its own (extract/makeBlock/merge/deleteInEveryTake
keep theirs untouched — scope is divide-only). **I propose native in BOTH**
(two identical `handleRouted` lines; the alternative — native in Takes,
carry in Lenses — is a per-mode split that would need its own justification
and would be the first door where the two boards disagree). A9's words are
"divide in takes mode"; Lenses riding along is the shipped pattern, not an
extension of scope. Your call.

##### Door wiring (P-1) and the pins that change

One model entry point `runStructuralDoor(_ act: StructuralAct)` forks
divide → native, the other three → `moveToWriteAndRun` unchanged, and all
three call sites use it (`TakesBoardView.handleRouted`,
`LensesBoardView.handleRouted`, `TakesBottomBar` line 304) so they cannot
drift. The bar's Divide help string loses "in Write, carried there for
you". Registry: `.divide` gains `takesAccess: .native` + its own
availability.

Pins: a new suite for the native path (unfanned end-to-end, the ceremony
opening in place seeded from a NON-chosen pane, the seal/lock/no-caret
refusals, the flight latch refusing a second divide, the pane freeze, the
successors arriving by ordinary projection, undo→redo). Existing:
`CommandRoutingTests`'s choreography pins call `moveToWriteAndRun`
*directly* and would keep passing — but six of them use `.divide` as their
sample act, which after this batch describes behaviour that no longer
exists at that door. I propose re-pointing those to `.extract` (which
genuinely still carries) rather than deleting them: the machinery pin
survives and stops narrating a retired flow (batch 1's judgment call 6 /
batch 2's annotate-don't-contradict discipline). Named individually in the
batch record.

**Awaiting the ruling on: (a) the extraction + host protocol · (b) the
board sheet mount · (c) the model-local latch + pane freeze (vs the
session-shared latch) · (d1) store-read fork vs plan-time parity · (d2)
the `fannedBlock` copy · (e) Lenses parity.**

#### THE ARCHITECT'S RULING on the Batch 3 proposal (2026-07-27 night — the gate closes; BUILD)

**The gate answer is accepted** — one build; the plain-divide half
genuinely needed (c), and shipping a door that acts sometimes is the
D3 class, correctly refused.

- **(a) APPROVED as proposed.** The extraction + six-member host
  protocol, `EditorSurfaceController` conforming by byte-unchanged
  forwards, parity-by-forwards on every moved name — the bar is the
  skill's 3C bar: every existing pin compiles and passes UNMODIFIED,
  and zero test edits is the parity proof. The extraction may be its
  own commit before the feature commit.
- **(b) APPROVED as proposed.** The sheet re-parameterized to the
  ceremony object; Write's mount unchanged; both boards mount
  `.sheet(item:)`. In place, no mode switch — that is A9.
- **(c) APPROVED — the MODEL-LOCAL latch, not the session-shared
  one.** The traced duplication hazard is real and the pane freeze
  rides the EXISTING liveness mechanism, which is what P-3 demands.
  The session-shared alternative buys nothing today and would touch
  the most heavily pinned structural path in a divide-only batch —
  correctly not taken. **Two riders:** (1) RECORD THE TRIGGER in the
  batch record: if any composition ever mounts Write and a
  takes/lenses board on ONE post with structural doors on both sides
  (`WriteTakesPanel` growing a divide door is the concrete case), the
  latch MUST move to a post-keyed shared authority — write that
  sentence down so the future session finds it beside the code it
  indicts. (2) NAMING HONESTY without API churn: do not rename the
  authority's `sealed:` parameter (churn on a heavily-pinned
  surface); instead update `isLive`'s doc comment to name BOTH
  suppression reasons (a sealed post has no live pane; a pane whose
  post is mid-structural-flight is frozen the same way), and pass a
  named local (`let frozen = sealed || structuralInFlight`) at the
  call sites so no reader mistakes the disjunction for a seal.
- **(d) APPROVED as proposed** — the `deleteFocusedBlock` apply shape,
  the ordinary projection refresh (the flush-leaves-it-clean reasoning
  is right), Write's caret rule mirrored through the existing
  `parkFocus(onVariant:)`, undo and redo untouched on the ops
  registration.
- **(d1) RULED: the STORE-READ fork.** Batch 2's precedent is the
  precedent precisely because revert D proved the projection reading
  eats takes; a plan-time arity stays an enablement hint, never an
  authorization. The planner remains the one brain, handed
  `fanArities` from the fresh read.
- **(d2) APPROVED** — `case .fannedBlock` in `OpsRefusalCopy` + the
  editor's switch (the R1-3 every-refusal-readable class).
- **(e) RULED: NATIVE IN BOTH.** The shared-model precedent (every
  native door since 13b lands in both handlers) makes the per-mode
  split the invention here, not the parity — a Takes-only door would
  be the first place the two boards disagree, and nobody ruled that
  asymmetry. Name it in the batch record as precedent-following, not
  scope growth.
- **The synthetic single-entry World: APPROVED, with ONE ADDITION
  (binding).** The one-brain claim gets a PARITY PIN, not an
  assertion: identical block text + caret + fan arity driven through
  the Takes door's plan and Write's door's plan must produce the same
  verdict class AND the same snapped cut offset. Constraint 1 is
  enforced by test or it is a comment.
- **The six `CommandRoutingTests` re-points to `.extract`: APPROVED**
  — the machinery pin survives, the retired narration goes; each named
  individually in the batch record.

**Proceed to build.** Everything else in the brief binds as written —
the ceremony disciplines at the new mount (one-flight before any
await, drift-refresh at confirm, cancel-inert, I10-at-birth), the
S4-22 snap rules byte-identical, checksums before reverts, the
array-subscript pin rule, full suites with quoted run lines.

#### BUILT — the batch record

**Counts, by my own runs:** core `✔ Test run with 882 tests in 100 suites
passed after 29.989 seconds` (**882/100** — the baseline exactly; **zero
`Sources/` lines** in the diff, so unchanged by construction rather than by
luck) · Mac `✔ Test run with 831 tests in 137 suites passed after 90.205
seconds` (**808/136 → 831/137**: the new `TakesDivideTests` suite's 23
pins). Tutorial spine green on its own run first: `✔ Test run with 49 tests
in 7 suites` (all seven `Tutorial*Tests` types by TYPE name — the 2E trap).
**Mobile untouched by construction, not by assumption:** every file in the
diff is under `Variorum/` (Mac) or `VariorumTests/`; nothing in `Shared/`
or `VariorumMobile/`. 14/4 stands unrun. Zero schema, zero
`Sources/VariorumCore/Sync/` lines.

**Her instance:** her real-store build was LIVE throughout (`pgrep` → PID
54248, `/Applications/Variorum.app/…`). Never quit, never touched; no
Release build, no `/Applications` refresh, no store touched.

**One environment note, because it contradicts a standing lesson and 13c
already recorded the exception once:** the lock flag read **1** for this
whole batch (`CGSSessionScreenIsLocked` = 1), and the Mac runner worked
normally anyway — probed with a control suite (`WCutPlacementTests`, `✔
Test run with 9 tests in 1 suite`) before anything was trusted to it, per
2C's precedent. Stage 4 lesson 9's prediction (the runner hangs
pre-connection under a locked session) did not hold here either; the
lesson now has its second recorded exception.

**Two commits.** `ef63399` the extraction, `517c5c7` the feature.

##### Commit 1 — the extraction (`ef63399`), and its parity proof

`DivideWCeremony` + `DivideWCeremonyHost` (new file) take the W ceremony's
state machine out of `EditorSurfaceController`; the controller conforms by
forwarding, with `runDivideW` = the byte-unchanged `runStructural { ops
.divideW }` (seam nil). `DivideWSheet` is parameterized on the ceremony
object rather than `EditorViewModel`. **The bar the ruling set was met
mechanically: ZERO test edits, and the full Mac suite green at 808/136 —
the exact pre-extraction baseline.**

One deviation from the proposal's letter, and it is a parity fix: the host
protocol has **seven** members, not six. The busy-door guard used
`model.refuseFeedback` (status **plus a beep**); routing it through
`speakCeremonyStatus` would have silently dropped the beep, so
`speakCeremonyRefusal` exists and each host uses its own refusal voice —
Write beeps because Write's structural refusals beep, a board speaks
because its refusals speak. A member for a behaviour is cheaper than a
behaviour change nobody asked for.

`EditorSurfaceController.legalCutPositions` survives as a static forward
because `WCutPlacementTests` addresses it there — parity-by-forwards
applies to statics too.

##### Commit 2 — the feature (`517c5c7`)

**The one planner brain, made checkable.** `TakesViewModel.divideWorld`
builds a single-entry `BlockRangeIndex` over the take the caret sits in
(`tailLength: nil` — a board has no open tail; `editable: !take.locked`)
and hands it to the existing `StructuralGesturePlanner.plan(
.divideAtCursor, …)`. Seal, gap, locked-take, the S4-22 word-rule snap and
the `.divide`/`.divideW` fork all come back from that one call.

**The store-read fork (ruled).** `prepareDivide` flushes, reads the block's
live active fan from the STORE, and hands THAT arity to the planner.
Revert B is the receipt (below).

**The flight latch, and the freeze it exists for.** `structuralInFlight`
is taken synchronously at the door, released explicitly per branch:
the plain divide runs frozen; the ceremony branch **releases before
opening the sheet**, because the sheet is window-modal and its confirm is
its own flight — Write's arrangement exactly (opening the ceremony has
never been a flight there either), and holding it across the sheet would
drop her live ring for as long as she reads. `runDivideW` takes it again.

**Rider 1 — THE TRIGGER, written where a future session will find it:**
*if any composition ever mounts a Write editor and a takes/lenses board on
ONE post with structural doors on both sides — `WriteTakesPanel` growing a
divide door is the concrete case — this model-local latch MUST move to a
post-keyed shared authority (the `AppSession.mergeJoinMemory` /
`tutorialDoorInFlight` precedent), because two surfaces over one post can
then interleave a flush and an op.* Today the only such coexistence is
`WriteTakesPanel`, which has no divide door.

**Rider 2 — naming honesty without API churn:** `PaneTextAuthority
.isLive`'s `sealed:` parameter keeps its name; its doc comment now names
BOTH suppression reasons, and `TakesViewModel.isPaneLive` composes `let
frozen = projection.sealed || structuralInFlight` as a named local before
asking. Three `TakesViewModel`-hosted call sites route through it
(`TakesShared`, `TakesBoardView`, `WriteTakesPanel`).

**(e), named as precedent-following rather than scope growth:** divide is
native in **both** boards. Takes and Lenses share one `TakesViewModel`,
and every native door since 13b — `insertBlockBelowFocused` (4D),
`deleteFocusedBlock` (13c 1B), `applyCallout` (13c R2-2) — is a model
method both handlers call. A Takes-only door would have been the first
place the two boards disagree.

**One door, three call sites:** `runStructuralDoor(_:)` forks divide →
native, the other three → the carry, and the Takes handler, the Lenses
handler and the bottom bar all call it, so they cannot drift into three
answers.

**Diff scope — 12 files + 1 new suite:** `DivideWCeremony.swift` (new) ·
`DivideWSheet.swift` · `EditorSurfaceController.swift` ·
`EditorViewModel.swift` · `EditorView.swift` · `TakesViewModel.swift` ·
`TakesBoardView.swift` · `LensesBoardView.swift` · `TakesBottomBar.swift` ·
`TakesShared.swift` · `WriteTakesPanel.swift` · `CapabilityRegistry.swift` ·
`OpsRefusalCopy.swift` · `PaneTextAuthority.swift` (doc only) ·
`TakesDivideTests.swift` (new) · `CommandRoutingTests.swift` ·
`CapabilityRegistryTests.swift`.

##### Pins — every change named

| Pin | Change | Why |
|---|---|---|
| `TakesDivideTests` (NEW suite, 23) | new | the ruling: the parity pin, the store-read fork, both cases end to end, the seed generalization, the refusals, the latch's two jobs, the registry cells, and divide-only scope |
| `theTakesWorldAndWritesWorldPlanAlike` | **NEW — the gate's binding addition** | every caret × both arities through Write's world and the board's: same verdict class AND same snapped cut, with a non-vacuity arm showing the domain really contains several classes |
| `structuralActsFireAndDoFromTakesAndLenses` (13b) | **divide REMOVED from its loop; its native cell asserted in the same test** | a RULED FLIP (#41), not a bug fix — the table stays the one place a reader learns each verb's Takes cell |
| `divideFromTakesParksTheIntentAndSwitchesToWrite` | **renamed + re-pointed** → `extractFromTakesParksTheIntentAndSwitchesToWrite` | the choreography pin survives; the retired narration goes |
| `aParkedDivideIntentLandsAndDividesEndToEnd` | **renamed + re-pointed** → `aParkedExtractIntentLandsAndExtractsEndToEnd` (the parcel gains a `selectionLength`, since extract is a span gesture) | same |
| `aRefusedModeSwitchClearsTheParkedIntentAndNothingEverRuns` | re-pointed, **both** its sample acts (the `moveToWriteAndRun` call and the hand-parked parcel) | same |
| `theDetailLifecycleClearsStaleParkedIntents` | re-pointed, **both** its hand-parked parcels | same |
| `aCompetingModeSwitchAbortsTheRoundAndClearsTheParkedIntent` | re-pointed | same |

**Count correction, stated rather than buried:** the proposal said "six"
`CommandRoutingTests` sites; the honest count is **seven occurrences across
five tests**, all re-pointed, and `structural(.divide)` now appears zero
times in that file (asserted at edit time).

##### Guard-revert evidence (four source files checksummed first; `shasum -c` OK after every restore)

| Revert | Applied | Observed RED |
|---|---|---|
| **A** — the door unwired: `case .divide` falls in with the other three and CARRIES (the exact pre-A9 world) | `runStructuralDoor` | **1 pin** — `theDivideDoorNeverParksAWriteIntent`: the block is not divided (1 slot where 2 is right). Only one, and honestly so: the other pins drive `divideFocused()` directly, so the DOOR-level pin is the one that discriminates the routing change |
| **B** — the fork read from `projection.fans` instead of the store (the tempting shape) | `prepareDivide` | **exactly 1 pin** — `theForkIsReadFromTheStoreNotTheFrozenProjection`: no ceremony opened. The batch-2 revert-D signature exactly (the ordinary fanned pins stay green because they `reload()`). The block was NOT cut, because `ops.divide`'s own in-transaction guard threw `fannedBlock` — which is precisely why (d2)'s copy was owed |
| **C** — the pane freeze removed (latch still guards a second divide) | `isPaneLive` | **1 pin** — `thePanesFreezeForTheFlight`: the pane stays live through the flight, which is the keystroke window that resurrects a divided half |
| **D** — the ceremony seeded from the CHOSEN take (Write's old derivation) | the `.divideW` branch | **1 pin, 3 issues** — `theCeremonySeedsFromTheTakeTheCaretIsIn_notTheChosenOne`: wrong seed id, the caret's take not pre-marked, and its cut nil. The one generalization, discriminated |

##### Three pins I got wrong before the code did — recorded, because the guard is what caught them

The suite failed on first run with four issues, and **three were my
expectations, not the build**:

1. I asserted a caret of 0 REFUSES with "nothing to divide". It does not:
   **snap-and-proceed** (the ratified 2026-07-06 contract, item 2) settles
   0 onto the nearest INTERIOR word edge and divides near the start — and
   that is *exactly* what the carry door produced, since
   `moveToWriteAndRun` sets `offsetInBlock = carried?.location ?? 0` and
   Write plans the same command at the same offset. So the parity I claimed
   holds, but through the opposite behaviour; inventing a refusal to match
   my pin would have been inventing product behaviour. The pin now asserts
   the real thing and is renamed for it, and a separate pin reaches
   `.nothingToDo` honestly (a one-word block has no interior boundary).
2. The same pin then failed by ONE character: divide **seam-trims** (the
   Phase 3 ratification), so the first half is not `text[..<cut]`. It now
   compares through `BoundarySnapping.seamTrimmedHalves` — the op's own
   halving function — rather than re-deriving the arithmetic.
3. `extractMakeBlockAndMergeStillCarryToWrite` read "no carry" for the
   wrong reason: with no registered detail, `requestMode` refuses and
   CLEARS the parking (the round-1 MAJOR's half-a rule). It now registers
   one, so the pin tests the carry rather than the refusal path.

##### Judgment calls

1. **A seventh host member for the beep** (above) — parity of the refusal
   voice over a tidy member count.
2. **The latch releases before the sheet opens**, and `runDivideW` takes it
   again. Write's arrangement; the alternative drops the live ring for as
   long as she reads the sheet.
3. **`structuralInFlight` is internal-settable**, with the reason in its
   doc comment: the freeze is a rule about what a pane may do DURING a
   flight, and a pin that cannot stage a flight cannot check it without
   racing it. The `adopt` / `divideWorld` precedent (internal so tests
   drive state deterministically). In production only two methods write it.
4. **`divideWorld` is internal** for the same reason — constraint 1's
   one-brain claim is enforced by test or it is a comment (the ruling's
   own words).
5. **The plain divide speaks** ("Block divided — ⌥⌘Z undoes it."),
   following batch 2's seam-merge line and A7's carve rather than Write's
   silence: a structural act just landed from a board door and ⌘Z cannot
   take it back. If she finds it noisy it is one line — flagged for her
   walk beside batch 2's judgment call 3.
6. **No caret ⇒ divide at the block start**, kept rather than "fixed"
   (finding 1 above). It is Write's behaviour, and the friction it may
   cause is a product question, not a bug — flagged for her walk.
7. **`fannedBlock` copy in BOTH homes** (`OpsRefusalCopy` and the editor's
   own switch): the ruling named both, and revert B proved the refusal is
   genuinely reachable rather than theoretical.

##### Deviations

- **None from the ruling.** Every point built as ruled; the one departure
  from the PROPOSAL's letter (seven host members, not six) is judgment
  call 1 and is a parity preservation.
- **No lookup subagent used** — nothing external was in question.
- **No visual loop** (P-7's screenshot half): the new pixel is an existing
  sheet mounted on a board. What a human eye would add is whether the
  ceremony sheet reads well over the takes board rather than over the Write
  editor — routed to the standing **Design & UI review** row rather than
  claimed.

##### PENDING / for the orchestrator

- **Nothing unverified.** Both full suites were run by me, run lines quoted
  above.
- **A layering consequence worth a second opinion, recorded not acted on:**
  the Takes feature now reaches into the Editor feature for
  `StructuralGesturePlanner`, `BlockRangeIndex` and `RefusalCopy`. That is
  the direct consequence of the ruled one-brain constraint (a sibling
  planner was the alternative and is worse), but the tidy end state is the
  `OpsRefusalCopy` precedent: the structural-gesture vocabulary is shared
  vocabulary and belongs in the shared layer. Deliberately NOT moved in a
  divide-only batch.
- **For the end-of-phase Fable review, suggested foci:** (1) the latch's
  release-before-the-sheet seam — is the window between release and
  `ceremony.open`'s own flush genuinely harmless? (2) judgment calls 5 and
  6 (the status line; divide-at-block-start with no caret) — right calls or
  friction? (3) the layering note above. (4) whether `WriteTakesPanel`
  should be the trigger's first customer — it now composes `isPaneLive`,
  so it would inherit the freeze for free if its model ever ran a flight.

#### Batch 3 — ACCEPTED (2026-07-27 night; the orchestrator's adjudication)

**Counts by my own runs:** core `✔ Test run with 882 tests in 100
suites passed after 32.582 seconds` · Mac `✔ Test run with 831 tests
in 137 suites passed after 90.652 seconds` — both match the record's
claims; tree clean at `113a1ff`.

**Spot-checks run, all clean:** `structural(.divide)` appears ZERO
times in `CommandRoutingTests` (the re-point claim, verified by my own
grep); the parity pin (`theTakesWorldAndWritesWorldPlanAlike`) is
exactly the ruling's binding addition — EXHAUSTIVE over every caret ×
both arities, full plan equality (the snapped cut rides the plan
value), with a real non-vacuity arm; rider 2's `let frozen =
projection.sealed || structuralInFlight` named local and the
authority's two-reason doc comment both landed as ruled.

**The one deviation from the proposal's letter (the seventh host
member) is ENDORSED** — the busy-door refusal keeps its voice per
host (Write beeps, a board speaks); routing it through the status
voice would have silently changed shipped behavior, which is exactly
what parity-by-forwards exists to prevent. The count correction
(seven occurrences across five tests, not six) is the record working
honestly.

**The caret-0 finding is the guard working in the RIGHT direction:**
the pin asserted a refusal; reality is snap-and-proceed (the ratified
2026-07-06 contract, item 2), and the carry door produced the same
landing — so the parity claim holds through the opposite behavior,
and inventing a refusal to match the pin would have been inventing
product behavior. Judgment calls 5 and 6 (the "Block divided" status
line; divide-at-block-start with no caret) join the SITTING BUNDLE
beside batch 2's status-line call — all three are one-line changes on
her word, and all three describe standing-or-parity behavior, not
inventions.

**The latch's release-before-the-sheet arrangement is endorsed** — it
is Write's own arrangement (opening the ceremony has never been a
flight), the sheet's drift-refresh-at-confirm discipline covers edits
made while it is open, and holding the latch across a window-modal
sheet would freeze her live ring for as long as she reads. Focus (1)
still rides the end-of-phase review.

**The layering note is recorded and adopted as a phase-closeout
consideration:** the Takes→Editor reach for the planner/index/refusal
vocabulary is the ruled one-brain constraint's direct consequence; the
tidy end state (shared vocabulary → the shared layer, the
`OpsRefusalCopy` precedent) is a candidate small cleanup for the
end-of-phase review to endorse or the closeout to re-own — not built
mid-phase.

**The second lock-flag exception recorded:** Stage 4 lesson 9's
probe-first discipline held (a control suite before anything was
trusted); the lesson's prediction failed again. Future sessions keep
the probe, not the prediction. A9 is DELIVERED — #41's "carry stands
until then" clause is now moot. Batch 4 (the typing-ergonomics
floor) proceeds.

### Batch 4 — the typing-ergonomics floor (A14 · A15 · A16 · A23 · A24)

#### A15 — THE TRACE (step one, before any design), and THE PROPOSAL (gate open)

**Gate answer up front: the gate IS needed, but it is much narrower than
the brief allowed for.** Four of the five contexts already keep both
keys inside the block, and the trace proves it by running REAL key
events rather than by reading code. Exactly ONE context does not, and it
is the one the brief predicted: **Write's open tail**.

##### The trace, machine-verified (`VariorumTests/ReturnKeyTraceTests.swift`, 6 pins)

The trace drives real `NSEvent` key-downs (keyCode 36) through a real
window, a real first responder, and AppKit's own
`keyDown → interpretKeyEvents → StandardKeyBinding.dict` path — because
the question is what the KEY does, not what the pipeline does with a
string (`insertText`, which every other editor pin uses, would have
answered a different question).

**The dispatch fact everything else follows from: ⇧⏎ and ⏎ are THE SAME
KEY to AppKit.** macOS's `StandardKeyBinding.dict` binds `\r` →
`insertNewline:` and gives Shift-Return **no binding of its own**, so the
shift falls away; the pin observes `["insertNewline:"]` for both and a
plain LF (never U+2028) in the storage. Control-Return is the one Return
variant bound differently (`insertLineBreak:`) — recorded so the negative
space is on the record too. **Consequence: there is no "soft return" key
here to give a different meaning to — any distinction must be made by
the app, by inspecting the modifier in `keyDown`.**

| # | Context | ⏎ today | ⇧⏎ today | A15 work |
|---|---|---|---|---|
| (a) | Write, mid-block | newline is block CONTENT (I4); verdict `.block` | identical | **none** — already "stays" |
| (b1) | Write, exact document end, no open tail, paragraph mode | verdict `.openTail` — **the tail opens** (the ratified Phase 7 gesture) | identical | **THE REAL HALF** |
| (b2) | Write, inside an OPEN tail | verdict `.tail`; the newline becomes a crystallization boundary as soon as a later non-blank segment exists (`SegmentationRules.crystallizedBoundary` splits at EVERY newline, not only blank lines) | identical | **THE REAL HALF** |
| (c) | Write under `one_block` | `verdict` excludes `.oneBlock` from the open-tail gesture, so the newline is content of the last block | identical | **none** — already "stays" |
| (d) | A Takes / Lenses pane | a pane is single-block by construction: `insertNewline:` → content → `onEdit` → autosave | identical | **none** — already "stays" |
| (e) | The quick-entry bar | `TextField(axis: .vertical)` + `.onSubmit` — ⏎ mints and opens the post (the bar's own hint says so) | SwiftUI's multiline-field grammar puts the literal newline here | **none** — and see the honesty note below |

**(e) is a READING, not a measurement — stated as such.** The field is
SwiftUI's, the grammar is SwiftUI's, and hosting it to drive key events
would test SwiftUI rather than Variorum. What is certain from the code:
the bar *does* accept newlines (`axis: .vertical`, `lineLimit(1...4)`)
and ⏎ is claimed by `.onSubmit`. If ⇧⏎ there ever fails to insert a
newline, that is a SwiftUI-grammar report for her walk, not a Variorum
mechanism — routed, not claimed.

**One fact discovered mid-trace that shapes the proposal** (and is not
obvious from the brief): `attachLeadingTailRunIfNeeded` already means a
newline typed into an **empty** open tail is transferred to the
preceding block as trailing CONTENT on the next crystallize pass (the
2026-07-12 k−1 rule, Phase 10 round-1 MAJOR-2's fix). So today's ⏎⏎ at a
document end already puts one newline INSIDE the last block. Only the
FIRST ⏎ (which opens the tail) and a ⏎ typed after real tail text behave
as boundaries.

##### The constraint, restated in the terms the code actually imposes

Crystallization is a pure Domain function over TEXT
(`SegmentationRules`); newlines are content (I4); the store records no
keystroke provenance; and the tail is surface-only until it mints. So
"this newline was soft" can only live in editor SESSION state over the
un-minted tail — and whatever is minted must afterwards be
indistinguishable from typed content.

##### PROPOSAL — option B, "⇧⏎ always lands the newline inside a real block" (RECOMMENDED)

One sentence describes the whole feature: **⇧⏎ ends with the caret
inside a real block and the newline as that block's content.** It needs
**no provenance memory at all** — not one offset, not one set — because
a newline that is block content the moment it exists can never become a
segmentation boundary (I4 is absolute; crystallization never touches
existing blocks).

Two halves:

- **B1 — the flag (small).** `EditorTextView.keyDown` notes that this
  keystroke was Return-with-shift; `EditorViewModel.shouldChangeText`
  passes `replacementIsSingleNewline: false` for it. The open-tail
  gesture is the ONLY consumer of that parameter, so the effect is
  surgical: at the exact document end the verdict falls through
  containment to `.block(last)` and the newline becomes the last block's
  content, caret inside the block, subsequent typing extending it. Every
  other context is unchanged by construction (mid-block, tail-interior
  and `one_block` never consult the flag). Refusals stay the ops layer's:
  a locked/gap last entry refuses and speaks exactly as it does today.
- **B2 — the tail (the part that needs your ruling).** Inside an open
  tail there is no block to stay in yet, so ⇧⏎ **mints the tail as it
  stands and then appends the newline to the block that just became**:
  refuse the raw keystroke, schedule a compound (the
  `scheduleCrossBlockCompound` shape batches 1B/2 already use) that runs
  the **existing** forced `.idle(.paragraph)` mint — the same call the
  2 s idle clock and teardown already make, minting the trailing partial
  paragraph and closing the tail — then inserts `"\n"` into the resulting
  last block through the ordinary path. A tail with **nothing mintable**
  (empty or whitespace-only — the ratified never-mints class) takes the
  ordinary tail edit instead, where the leading-run attachment already
  makes the newline block content.

**Why B2 mints rather than remembers.** Minting invents nothing: it is
the ratified idle-mint, fired deliberately 2 s early, and the author has
already ratified that a tail becomes a block *including its trailing
partial paragraph*. The alternative (A, below) has to keep a live set of
"soft" offsets correct through every tail insert and delete, every
partial mint, the apply-time reconciler, the leading-run attachment, and
the idle/teardown paths — and hand it to a pure Domain function that
deliberately takes no such parameter. That is the text-loss class this
project has paid for twice.

**Named consequence, so it is ruled and not discovered:** pressing ⇧⏎
while typing fresh text at the end of a post makes a block right then.
Recoverable and ordinary (⌥⌘Z; the block is the one the newline lives
in), but it IS a visible act on a keystroke.

##### The alternatives, stated honestly

- **A — the soft-offset memory (the "true" soft return).** `EditorViewModel`
  keeps a set of UTF-16 offsets in the tail where a soft newline sits,
  rebased on every tail edit and every partial mint, and crystallization
  skips boundaries at those offsets — which means either a new parameter
  on `SegmentationRules.crystallizedBoundary` (a core change to a pure
  rule that is deliberately provenance-free) or masking the character
  before planning and restoring it after (a text-mutating hack on the one
  path that must never lose bytes). Gives the truest behaviour: the tail
  stays open, nothing mints early. Costs the most risk, in the exact
  place the project's risk register points at.
- **B1-only.** Build the flag, leave the tail alone. Smallest diff — but
  the tail is open for most of the time she is typing fresh prose, so
  ⇧⏎ would stay-in-the-block sometimes and not others: a door that acts
  sometimes, which is the D3 class P-2 retired. Not recommended.
- **B2′ — refuse-and-speak in the tail** ("this text isn't a block yet").
  Honest, needs nothing, helps nobody. Considered, rejected under P-2.

**Awaiting the ruling on: B vs A vs B1-only; and, if B, whether B2's
early mint is acceptable as a keystroke-visible act.** Nothing of A15 is
built until the gate closes — including B1, which is design, not a
"trivial half" (the trivial halves are (a), (c), (d), (e), where the
answer was *build nothing* and the trace is the deliverable).

##### THE ARCHITECT'S RULING on A15 (2026-07-27 night — the gate closes; BUILD OPTION B, both halves)

**B is ruled, whole.** The one-sentence contract — *⇧⏎ ends with the
caret inside a real block and the newline as that block's content* —
is her ask satisfied without provenance memory, and the argument
against A is the risk register's own: a live soft-offset set rebased
through every tail edit, partial mint, reconcile and attach, handed to
a deliberately provenance-free Domain rule, is the text-loss class
this project has paid for twice. B1-only fails the D3 class exactly as
stated; B2′ fails P-2. **B2's early mint is ACCEPTED as a
keystroke-visible act**: it is the ratified idle-mint fired
deliberately ~2 s early — same mechanism, same result as waiting, and
the boundary it makes visible is one the clock would have made anyway.

**Three riders, binding:**

1. **B2 is the idle-mint's OWN code path, never a re-implementation** —
   the same forced-mint call the 2 s clock and teardown make, so the
   whole ratified mint story (trailing-partial inclusion, the
   never-mints whitespace class, resumed-typing-extends) rides free
   and stays pinned where it always was.
2. **State PRECISELY in the batch record what undo offers after a ⇧⏎
   mint, with PARITY to the idle-mint's existing story as the bar** —
   whatever ⌥⌘Z does (or does not do) after the 2 s clock's mint is
   exactly what it does after ⇧⏎'s; invent nothing in either
   direction, and do not claim ⌥⌘Z in the record unless the pin shows
   it.
3. **The keyDown flag is narrow and self-clearing:** shift+Return
   only (Control-Return's `insertLineBreak:` untouched), reset on
   every keystroke path — no sticky state; pin that a ⇧⏎ followed by
   a plain ⏎ behaves as two different keys.

**Pins owed:** (b1) end-to-end — ⇧⏎ at the exact document end lands
the newline inside the last block, no tail opens, subsequent typing
extends; (b2) end-to-end — ⇧⏎ in an open tail mints-and-stays, the
final block structure equal to idle-mint-then-type; the
whitespace-only tail's ordinary path; rider 3's two-keys pin; and the
trace suite stays green as the already-stays contexts' cannot-change
pins. The early-mint consequence joins the bundled walk entry at the
batch's acceptance.

##### BUILT — A15, option B, both halves

**Counts, by my own runs:** core `✔ Test run with 887 tests in 101 suites
passed after 29.161 seconds` (**887/101** — unchanged, zero `Sources/`
lines in this half) · Mac `✔ Test run with 858 tests in 143 suites passed
after 90.972 seconds` (**852/142 → 858/143**: the new `SoftNewlineTests`
suite's 6; the trace suite stays at 6 because its one changed pin was
REWRITTEN, not added). Tutorial spine green on its own run first:
`✔ Test run with 49 tests in 7 suites`. **Mobile untouched by
construction, not by assumption** — this half's only source files are
`Features/Editor/EditorTextView.swift` and `EditorViewModel.swift`, both
under `Variorum/` (Mac); the mobile target synchronizes `VariorumMobile/`
+ `Shared/` only. Its earlier same-batch run stands: 14/4. Zero schema,
zero `Sources/VariorumCore/Sync/` lines.

**Diff scope — 3 files:** `EditorTextView.swift` (the keystroke flag) ·
`EditorViewModel.swift` (the verdict fork + the tail path) ·
`ReturnKeyTraceTests.swift` (the new suite + the one rewritten trace pin).

**The whole build, in the contract's own sentence:** ⇧⏎ ends with the
caret inside a real block and the newline as that block's content.

- **Rider 3 — the flag.** `EditorTextView.isSoftNewline`, written ONLY by
  `withSoftNewline`, whose `defer` clears it on every path — deliberately
  the exact shape `isPasting` has used on this class since Phase 9, so it
  is a precedent rather than a new mechanism. `keyDown` raises it for
  SHIFT-Return alone: `isSoftNewlineKey` requires the modifier set to be
  EXACTLY `.shift` and the character to be `\r` or keypad `\u{3}`, so
  Control-Return keeps `insertLineBreak:`, ⌥⏎ keeps
  `insertNewlineIgnoringFieldEditor:`, and ⌘⇧⏎ stays A14's menu key.
- **B1 — the verdict.** `shouldChangeText` withholds
  `replacementIsSingleNewline` for a soft newline. That parameter has
  exactly ONE consumer (the open-tail gesture), so the change is surgical:
  at the exact document end the verdict falls through containment to
  `.block(last)`. Mid-block, tail-interior and `one_block` never consult
  it, which is why the three already-stays contexts could not move — and
  their trace pins ran unchanged and green, which is the guarantee stated
  as a test rather than as a claim.
- **B2 — the tail (rider 1).** A soft newline whose verdict is `.tail`
  with a MINTABLE tail refuses the keystroke and schedules the standing
  compound, which calls **`idleMintTail()` itself** — the very call the
  2 s clock makes — awaits `awaitMintSettle()`, and re-plays the newline
  at the document end inside `withSoftNewline`. Nothing about minting is
  re-implemented, so the ratified story rides free and stays pinned where
  it always was: trailing-partial inclusion, the never-mints whitespace
  class, the in-flight/marked-text skips, resumed-typing-extends.
- **"Mintable" is asked ONCE.** `mintableTail` states the guard
  `idleMintTail` and `finalizeWork` already apply
  (`hasOpenTail && !tailText.allSatisfy(\.isWhitespace)`), so the B2 fork
  and the mint cannot disagree about what mints.
- **Both roads end in block content.** Where the mint CLOSED the tail the
  re-play is `.block(last)` directly; where it kept a newline run open (a
  tail that already ended in blank lines — the k−1 rule) the re-play is an
  ordinary `.tail` edit and the standing leading-run attachment folds it
  into the preceding block. Neither is new machinery.

**RIDER 2 — what undo offers after a ⇧⏎ mint, MEASURED, not claimed.**
The pin `undoAfterASoftReturnMintMatchesTheIdleMintExactly` drives both
roads and reads `session.undoStack` on each. The measurement:
**depth 0, topLabel nil — on BOTH roads.** So a crystallization mint
registers NO structural undo entry at all, by the clock or by ⇧⏎, and
**⌥⌘Z offers nothing new after either.** That is the parity the rider
demanded, and it is stated at exactly the strength the pin supports: the
bar was "whatever the idle-mint's story is", the idle-mint's story is
"nothing", and ⇧⏎ matches it exactly. The pin asserts the equality AND
the concrete values, so a future change to either road breaks it. *(Why
it is nothing, for the reader: segmentation minting is the machinery
doing its job, not an author gesture — `finishMint`'s compensating
deletions already run through an explicitly undo-stack-free `Operations`
for the same reason. No claim is made here about text undo or the tray;
neither was measured.)*

**Pins — every change named**

| Pin | Change | Why |
|---|---|---|
| `SoftNewlineTests` (NEW suite, 6) | new | B1 end-to-end (no tail, typing extends the same block); rider 3's two-keys pin; the modifier discrimination incl. Control-Return; B2 end-to-end **against the idle-mint-then-type road, asserted EQUAL** (the ruling's bar); the whitespace-only tail's ordinary path; the undo parity with its measured values |
| `writeAtTheDocumentEndOpensTheTailUnderBothReturns` | **rewritten + renamed** → `onlyPlainReturnOpensTheTailAtTheDocumentEnd` | THE ONE trace pin the build changes. It asserted the pre-A15 world (both keys open the tail); it now asserts the ruled split, with ⏎'s half byte-unchanged. A RULED FLIP, named as such — the flip's behaviour is `SoftNewlineTests`' |
| the other five trace pins | **UNCHANGED, green** | the cannot-change guarantee the ruling asked for: (a) mid-block, (c) `one_block`, (d) take panes, the dispatch fact, and Control-Return all ran untouched |

**Guard-revert evidence (two source files checksummed first; `shasum -c`
OK after every restore)**

| Revert | Applied | Observed RED |
|---|---|---|
| **F** — the soft flag never reaches the verdict (the exact pre-A15 world) | `EditorViewModel.shouldChangeText` | **4 pins, 7 issues** — the tail opens under ⇧⏎, "beta\nmore" never forms, the two-keys pin collapses, and B2's equality bar fails. Her reported behaviour, reproduced |
| **G** — B1 only, the B2 fork removed (the variant the ruling REJECTED) | `EditorViewModel.shouldChangeText` | **exactly 1 pin, 2 issues** — B1's pins stay green while B2's equality bar reads `["alpha","beta"]` where `["alpha","beta\ngamma"]` is right: the "gamma" typed after the soft newline landed in a still-open tail and never reached the block. **The D3 class the ruling named, reproduced mechanically** |
| **I** — the flag made STICKY (rider 3's `defer` removed) | `EditorTextView.withSoftNewline` | **1 pin, 3 issues** — the flag is still raised after the keystroke, so the FOLLOWING plain ⏎ behaves as a soft one: no tail opens and the block reads `"alpha\n\n"` where `"alpha\n"` is right |

**No revert for rider 1**, and the reason is stated rather than skipped:
"the mint is the idle-mint's own call" is an architectural constraint, and
the only available revert (calling `crystallizeIfNeeded(forcedKind:)`
directly) would behave identically, so it could not discriminate. It is
verified by reading the diff — `runSoftNewlineInTail` calls
`idleMintTail()` and nothing else — and the ratified mint story's own
existing pins ARE its coverage, which is the point of the rider.

**Judgment calls**

1. **`withSoftNewline` is a scoped body, not a settable flag** — the
   `isPasting` shape. Rider 3 forbids sticky state, and a scope with a
   `defer` cannot leak one even on a throw; revert I is the receipt.
2. **The model's re-play goes through `withSoftNewline` too**, rather
   than through a second private code path. The re-played newline must
   reach the same verdict the keystroke would have; sharing the flag is
   how it does that without a parallel mechanism.
3. **The degradation under a skipped mint is recorded, not papered
   over:** if `idleMintTail` skips its tick (a structural gesture in
   flight, or an open IME composition — it re-arms the clock instead),
   the tail is still open when the newline is re-played, so ⇧⏎ behaves as
   ⏎ there. The honest alternative would be inventing a blocking wait on
   someone else's flight; the doc comment says so at the code.
4. **Keypad Enter counts as the gesture** (`\u{3}`), because macOS's own
   `StandardKeyBinding.dict` binds it identically to Return; excluding it
   would have made the same physical act mean two things.

**Deviations:** none from the ruling. All five owed pins landed plus the
modifier-discrimination pin; the trace suite's cannot-change contexts are
green and untouched.

#### BUILT — the other four items (A14 · A16 · A23 · A24)

**Counts, by my own runs:** core `✔ Test run with 887 tests in 101 suites
passed after 29.234 seconds` (**882/100 → 887/101**: A16's core suite) ·
Mac `✔ Test run with 852 tests in 142 suites passed after 89.289 seconds`
(**831/137 → 852/142**: five new suites — the A15 trace's 6, A14's 3,
A16's face 2, A23's 4, A24's 6 = 21) · mobile `✔ Test run with 14 tests in
4 suites passed after 0.246 seconds` (**14/4** — RUN, not assumed: A16's
setter lands under `Sources/`, which the mobile target links). Tutorial
spine green on its own run first: `✔ Test run with 49 tests in 7 suites`
(all seven `Tutorial*Tests` types by TYPE name — the 2E trap).
**Zero schema change; zero `Sources/VariorumCore/Sync/` lines.**

**Her instance:** her real-store build was LIVE throughout (`pgrep` → PID
54248, `/Applications/Variorum.app/…`). Never quit, never touched; no
Release build, no `/Applications` refresh, no store touched.

**Lock-flag exception #3:** the flag read **1** for this whole batch and
the Mac runner worked normally, probed first with a control suite
(`WCutPlacementTests`, `✔ Test run with 9 tests in 1 suite`) per 2C's
precedent. Stage 4 lesson 9's prediction failed a third time; keep the
probe, not the prediction.

**Three commits:** `0932e09` the core setter + read (A16's half under
`Sources/`), `7a4ca38` the four app-side items and their pins, and the
earlier `8233753` the A15 trace + proposal.

##### A14 — ⌘⇧⏎ mints a new block

**THE COLLISION SWEEP'S RESULT: ⌘⇧⏎ is FREE.** Swept across the whole
keyboard family — `EditorCommands.keyEquivalent` (the one place shortcut
labels are wired), every `.keyboardShortcut` call site in `Variorum/` and
`Shared/`, every `NSMenuItem` key equivalent, and the two
`performKeyEquivalent` overrides. The only Return chord in the app is
**⌘⏎ = Choose Take**; the `.defaultAction` shortcuts are plain Return
inside modal sheets; `EditorTextView.performKeyEquivalent` intercepts only
⌘S. No collision, so the item did not need its stop-and-report door.

**The one real decision, and it is a judgment call, not a ruling:
⌘⇧⏎ SUPERSEDES ⌥⌘N rather than joining it.** The act
(`insertBlockBelow`, 13b 4D) already carried ⌥⌘N, which the brief did not
account for. The registry has ONE `shortcutLabel` per capability by
design, a SwiftUI menu item carries ONE key equivalent, and the R73/R91/R93
mandate is that every shortcut is a menu item — so keeping both would have
meant either a duplicate row in the Block menu or an undeclared key living
outside the registry, and both are the legibility failure the mandate
exists to prevent. Her intake asked for ⌘⇧⏎ *while the act already had a
shortcut*, which reads as the existing key not serving her. The act keeps
four doors (menu, bottom bar, palette, and now this key). **Flagged for
her walk: if she wants ⌥⌘N back, that is a registry alias concept — a
design change, not a batch's call.**

It also reads beside A15, which is why the pair is coherent: **⇧⏎ stays in
the block, ⌘⇧⏎ makes a new one** — the two Enter-flavoured keys her intake
describes side by side.

**The copy swept with it** (batch 1's judgment call 6 — prose that
contradicts the shipped surface is a regression): the Takes/Lenses bar's
insert button, Write's CommitBar help, the ⌘/ shortcut dictionary, BOTH
`SegmentationFaceCopy` notes that name the split doors, and a
`TutorialWalkTests` comment. `⌥⌘N` now appears in the tree only in the
comment recording its supersession.

##### A16 — the GLOBAL `one_block` face (N34's deferred half)

13b's 4D record named the blocker exactly — *"no public
`default_segmentation` setter exists; `upsertSetting` is
Operations-internal"* — so the build is that setter
(`Operations.setDefaultSegmentation`), its read
(`Queries.defaultSegmentation`, `.paragraph` on absent/garbage), and a face.
**No segmentation semantics moved**: the value has been consulted by
`containerHeader.effectiveSegmentation` since Phase 7 and `one_block` has
been entry-wide since S4-21.

The face is a **Settings ▸ Appearance ▸ "Writing"** section — its own
section because it is the one setting on that pane that is SYNCED (document
semantics), and its copy says so where its neighbours say "This Mac only".
It offers exactly two modes; **sentence segmentation is deliberately not
offered**, because type-time crystallization is paragraph-granular in every
mode (the ratified 2026-07-06 rule), so a sentence choice would name a
behaviour the editor does not have. A tiny bounded observation over the
`setting` table (the ThemeStore pattern) keeps the picker honest against
another device.

**The honesty half, which this batch OWNS because this batch creates it.**
4D deliberately mapped the per-post chip's "on" to per-post NIL —
*inherit* — "so a future global one_block choice stays honored". That
future is now: under a global `one_block`, turning a post's chip on clears
its override and the post **still does not mint**, while the shipped note
said *"Newlines make blocks again in this post"*. The door still acts; it
just needed to say what acting means. Both bars now pick their note from
what the post EFFECTIVELY does after the write (`SegmentationFaceCopy
.note(asked:effectivelyMints:)`), Takes reusing its existing
`refreshSegmentation`, Write adding one bounded header read because its
`header` observation may not have delivered yet. **Per-post override
semantics are untouched** — this is copy, not mapping.

##### A23 — the paragraph-gap setting

A `ParagraphGap` choice in Settings ▸ Appearance ▸ Editor, stored in
`UserDefaults` beside the hover handles (S4-19) and the phantom kill switch
(13c 1E) — **nowhere in the schema**, so `renderedText`, export and the
bridge are byte-untouched (pinned, including zero outbox rows and unchanged
`updated_at` stamps across a toggle).

Two shaping decisions:

- **ADDITIVE, not absolute.** "Paragraph-tall" adds a whole line of the
  prose font ON TOP of the standard gap. An absolute "one line" would have
  been *smaller* than the shipped gap whenever inline comments are on
  (which already adds 22pt of room) — i.e. a setting that silently does
  nothing in a state she can be in.
- **Read at style-construction time, not cached.** `EditorDocument
  .baseParagraphStyle` reads `ParagraphGap.current` directly rather than
  going through `EditorTypography.current`. Every surface rebuilds that
  style, so there is no global to keep in sync and no ordering hazard
  between the setting changing and a surface re-styling.

Two reach points were needed and both are the EXISTING mechanism, never a
second one: `EditorSurfaceChrome` gained the value so the app's one
"presentation moved, re-apply it" `Equatable` gate notices a gap change (a
gap moves no font, so the font test alone could never see it), and the pane
representable's voice-adopt branch gained the paragraph-spacing half of the
same question. **`PagePaginator`'s own spacing constants were deliberately
NOT touched** — those measure Read's true pagination, whose address is
(post, page-in-post) identity, and moving them would move her reading
position for a presentation setting.

##### A24 — spellcheck levels, and the two things the pins FOUND

Three levels (off · check while typing · check and correct), applied
through one write-gated `apply(to:)` at every TK2 surface factory and on
the live update paths. Coarse by TEXTKIT2 §3's warning; the default is the
full-document editor's shipped posture, so a Mac that never opens Settings
sees no change there.

**Finding 1 — the §3 crash pairing was ONE SETTING AWAY, and the pin found
it rather than confirming a precaution.** I wrote
`theHighestLevelNeverEnablesTheCompletionHalfOfTheCrashPairing` expecting
it to pass trivially, on the belief (which I had also written into the
file's header) that "nothing in the app turns automatic completion on". It
FAILED on all three surfaces: `isAutomaticTextCompletionEnabled` is **TRUE
by default** on every NSTextView here. So shipping A24's higher levels
without more would have put every writing surface into exactly the pairing
§3 records as crashing NSTextView — *continuous spell checking + the
word-completion popover*. The fix: completion is OFF whenever checking is
ON, and restored to AppKit's default at `.off`, so a round trip through the
setting leaves the surface where it began (pinned). The header comment that
carried my wrong belief was corrected in the same pass.

**Finding 2 — Write and the take boards disagreed about autocorrect, and
had since the pane surface was built.** `PaneTextView.makeSurface` never
set the spelling flags, and a bare NSTextView carries
`isAutomaticSpellingCorrectionEnabled = TRUE` — so her prose in take panes
was being autocorrected while Write's explicitly was not ("the author's
prose should not be silently rewritten", Phase 7's comment). The setting
unifies every surface on Write's posture, which **changes take-pane
behaviour at the default level** — deliberately, and recorded here rather
than buried. "Check and correct" is now the deliberate way to ask for the
other behaviour. **Flagged for her walk.**

The §3 class is also exercised as far as the harness reaches: a real
window, a real editing session at the highest level over deliberately
misspelled prose, selections, the store round-trip, and the fallback canary
silent. What the harness cannot reach — whether the popover itself
misbehaves under real key input — is recorded for the Design & UI review's
screenshot drive, not claimed.

##### Pins — every one named

| Pin | Change | Why |
|---|---|---|
| `ReturnKeyTraceTests` (NEW suite, 6) | new | A15's trace, machine-verified: the ⏎/⇧⏎ dispatch fact, Control-Return's contrast, and the four contexts' behaviour today |
| `GlobalSegmentationDefaultTests` (NEW core suite, 5) | new | A16's setter/read: seed, round trip, upsert-never-duplicates, outbox row, absent/garbage, the global-vs-override rule, and the inherit mapping the copy speaks about |
| `NewBlockShortcutTests` (NEW suite, 3) | new | A14's declaration, **the collision sweep made permanent**, and the retired key's absence from the copy that named it |
| `GlobalSegmentationFaceTests` (NEW suite, 2) | new | the honest note, pure and then end to end through Write's own setter |
| `ParagraphGapTests` (NEW suite, 4) | new | the default, the additive rule, **no stored/exported byte moves**, and the chrome gate noticing a gap change |
| `SpellcheckLevelTests` (NEW suite, 6) | new | the default on every surface (+ the measured AppKit divergence), the level→flags map, the write gate, birth-under-a-level, **the §3 pairing and its round trip**, and a real hosted session at the highest level |

Nothing existing was renamed, re-pointed or weakened: the four items are
additions plus one declared-key change, and no shipped pin asserted that
key.

##### Guard-revert evidence (five source files checksummed first; `shasum -c` OK after every restore)

| Revert | Applied | Observed RED |
|---|---|---|
| **A** — the §3 completion guard removed from `apply` | `EditorBehaviorSettings` | **1 pin, 4 issues** — every surface (editor, inline, pane) and the round-trip arm report completion still ON under continuous checking: the crash pairing, reproduced |
| **B** — panes never adopt the level (the pre-batch pane world) | `PaneSurface.makeSurface` | **3 pins** — the pane carries autocorrect ON at the default level, does not follow a level it was born under, and keeps completion on at the top level |
| **C** — `paragraphTall` adds nothing | `EditorBehaviorSettings` | **1 pin, 3 issues** — extra 0.0 where 16.0 is right; the gap identical (7.0 vs 7.0) across both settings |
| **D** — the note reverted to the unconditional `mintOnNote` | `OpsRefusalCopy` | **2 pins** — the pure mapping AND the end-to-end Write chip both speak *"Newlines make blocks again in this post"* under a global one_block, which is the lie the fix exists to stop |
| **E** — A14's key back to ⌥⌘N | `EditorCommands` | **1 pin, 2 issues** — character `n` where Return is right, modifiers 24 (⌥⌘) where 18 (⇧⌘) is right |

**One disclosed deviation in the revert pass, and its proof.** Restoring
revert A, I also corrected the file's header comment in the same edit (it
still claimed the app "has never enabled" automatic completion — the belief
finding 1 falsified), so the post-restore checksum for
`EditorBehaviorSettings.swift` did NOT match its pre-revert value. The
functional restore was verified by reading the restored `apply` body back,
the file was re-checksummed, and every subsequent revert/restore matched
exactly. Recorded because a mismatched checksum should never pass without
an explanation.

##### Judgment calls

1. **⌘⇧⏎ supersedes ⌥⌘N** rather than joining it (the A14 section's
   reasoning). The alternative — a registry alias concept — is a design
   change; flagged for her walk either way.
2. **A16's honesty note was built even though the brief said per-post
   override semantics are untouched.** It touches COPY, not mapping, and
   the case it speaks about only becomes reachable because this batch made
   the global settable — so leaving it would have been shipping a door that
   lies, created by my own item.
3. **A23 is additive, not absolute** (the reasoning above): the absolute
   reading is invisible in a shipped state.
4. **A23 reads the setting at style-construction time**, so no global
   needs synchronizing and no ordering hazard exists.
5. **`PagePaginator` deliberately untouched** — Read's pagination address
   is identity, and a presentation setting must not move her page.
6. **A24 turns COMPLETION off with checking on**, rather than leaving the
   §3 pairing to chance or adding a fourth level for it. The §3 warning is
   the reason the item is coarse; honoring it in the mechanism rather than
   in a comment is the point.
7. **A24's default unifies panes onto Write's posture**, changing take-pane
   autocorrect. The alternative — preserving each surface's accidental
   default — would have made "off" mean two different things on two
   surfaces, which is what a *setting* exists to stop. Flagged.
8. **A24 rides `EditorSurfaceChrome`** rather than getting its own
   re-application mechanism: the chrome's `Equatable` gate is the app's ONE
   "this surface's presentation moved" door, and a second door beside it is
   what P-3 forbids.

##### Deviations

- **None from the brief's five items' shapes**, and no schema change
  anywhere (A16 writes an existing `setting` row; A23/A24 are
  `UserDefaults`). No item wanted a schema change, so that stop-door was
  not needed; A14's collision stop-door was not needed either.
- **A15 is deliberately unbuilt**, gate open, per the brief.
- **No lookup subagent used** — the one external fact in question (what
  macOS binds Shift-Return to) was answered from the system's own
  `StandardKeyBinding.dict` and then re-verified by running real key events.
- **No visual loop** (P-7's screenshot half): three of the four items are
  Settings rows and a key equivalent; the fourth (A23) is genuinely visual,
  and what a human eye would add — whether "a blank line's worth" is the
  right amount of air in each voice — is routed to the standing **Design &
  UI review** row rather than claimed.

##### PENDING / for the orchestrator

- **Nothing unverified.** All three suites were run by me, run lines quoted
  (the batch's final numbers are A15's: core **887/101** · Mac **858/143**
  · mobile **14/4**).
- **A15 is BUILT** to the ruling, both halves — its record is the section
  above; the gate is closed.
- **Three things to put in front of her at the walk:** (1) ⌥⌘N is retired —
  one line to restore if she wants it, but properly it wants a registry
  alias concept; (2) take panes no longer autocorrect at the default level,
  which is a change to what she has been living with; (3) **A15's early
  mint** — ⇧⏎ while typing fresh text at the end of a post makes a block
  right then (~2 s before the clock would have), which the ruling accepted
  as a keystroke-visible act and which she will SEE.
- **For the end-of-phase Fable review, suggested foci:** (1) the
  supersession call on ⌥⌘N — right call, or should the registry grow
  aliases? (2) A23's additive rule and its interaction with the
  inline-comment gap — does the combined gap read as intended in both
  voices? (3) whether `EditorSurfaceChrome` carrying two non-voice settings
  is the right home or a bag forming (P-9's smell, deliberately weighed:
  it already carried `inlineComments`). (4) A24's grammar-checking
  coupling — riding the "check while typing" level was my call, not hers.

#### Batch 4 — ACCEPTED IN FULL (2026-07-28 early; the orchestrator's adjudication of both halves)

**Counts by my own runs, both passes:** after the four items — core
`✔ Test run with 887 tests in 101 suites` · Mac `✔ Test run with 852
tests in 142 suites` · mobile `✔ Test run with 14 tests in 4 suites`
(RUN, not assumed — A16 touched `Sources/`); after A15 — core
`✔ 887/101` unchanged · Mac `✔ Test run with 858 tests in 143 suites
passed after 90.177 seconds`. All green; tree clean at `b419ca1`.

**The A16 core diff read closely (the phase's first `Sources/`
change):** exactly the 13b 4D blocker's shape — a setter over the
existing `upsertSetting` (synced document semantics, the fan_style
class), a read with the stated `.paragraph` fallback matching
`containerHeader`'s standing resolution, zero semantics change,
per-post override untouched. Endorsed.

**A15's build verified against the ruling's riders line by line:**
the scoped `withSoftNewline` defer-clears on every path (the
`isPasting` precedent — rider 3, with the two-keys pin and revert I
proving non-stickiness); B1 withholds `replacementIsSingleNewline`
whose ONE consumer is the tail gesture; B2's fork calls
`idleMintTail()` ITSELF behind the shared `mintableTail` guard
(rider 1 — and the no-revert justification for it is SOUND: an
equivalent-behavior revert cannot discriminate, and the mint story's
own pins are the coverage, which is the rider's point). **Rider 2's
measurement corrected the proposal's own claim:** a crystallization
mint registers NO structural undo entry by either road — the
proposal's "⌥⌘Z-recoverable" was wrong, the pin measured it, and the
record now claims parity at exactly the strength the measurement
supports. That is rider 2 doing precisely what it was written to do.
**Revert G is the ruling's own rejection reproduced mechanically**
(B1-only leaves the word after a soft newline in a still-open tail —
the D3 class red on exactly one pin).

**The ⌘⇧⏎-supersedes-⌥⌘N call, A24's two found-not-confirmed
defaults, A23's additive rule, and A15's early mint are all ENDORSED
as built and BUNDLED for her** — QUESTIONS **#48** now carries the
seven one-line calls from batches 2–4 in one entry, so the walk reads
them in one place. The permanent no-two-capabilities-share-a-chord
pin and the A24 crash-pairing guard are exactly P-7's find-it-first
posture. Third lock-flag exception recorded (probe-first held again).

**Environment note adopted for the phase:** the mobile scheme's
OS 26.2 simulators are the iPhone 17 family + 16e — "iPhone 16" fails
with exit 70, and the orchestrator's own first mobile attempt proved
the quoted-run-line rule catches it (grep swallowed the failure;
`pipestatus` and the missing run line exposed it). Mobile runs name
an existing destination and quote the line.

**BATCH 4 CLOSES THE PHASE'S AUTONOMOUS BUILD FLOOR.** Built across
batches 1–4: the three walk flips · #34's seam merge + its §14 delta ·
A9 native divide with the ceremony extraction · A14 ⌘⇧⏎ · A15 ⇧⏎
option B · A16's global face · A23 · A24. What remains is
SITTING-GATED (A5 via #29, A11, A12's definition, A22's design with
her untaken trimming ruling, the rolled walk items, #48) and then the
ONE Fable cold review at phase end (her kickoff cast ruling) over the
combined diff. The install refresh is HELD for her word as always.

### Batch 5 — the sitting's builds (#37(iii) · A12 · the idle-voice line · A22 · A11)

**Counts, by my own runs:** core `✔ Test run with 901 tests in 101 suites
passed after 29.852 seconds` (**887/101 → 901/101**: +14, all into existing
suites — BoundarySnapping +1, StructuralDivide +3, UndoStack +4,
ContainerOperations +4, BridgeDailyBook +2) · Mac `✔ Test run with 873 tests
in 145 suites passed after 93.646 seconds` (**858/143 → 873/145**: the two
new suites `TypewriterRoomTests` (8) and `DestructiveUndoWarningTests` (5),
plus one pin each in `PaneSurfaceTests` and `StructuralGestureTests`) ·
mobile `✔ Test run with 14 tests in 4 suites passed after 0.246 seconds`
(**14/4** — RUN, not assumed: items 1 and 5 land under `Sources/`, and one
mobile pin is a ruled flip). Tutorial spine green on its own run:
`✔ Test run with 49 tests in 7 suites passed after 12.126 seconds` (all
seven `Tutorial*Tests` types by TYPE name — the 2E trap). **Zero schema
change; zero `Sources/VariorumCore/Sync/` lines.**

**Her instance:** closed for the whole batch (`pgrep` → nothing at
`/Applications/Variorum.app/…`, checked at open and at close, as her
sitting said). No Release build, no `/Applications` refresh, no store
touched. Lock flag 0.

**Diff scope — 8 source files + 4 canon/test-support files + 2 new suites:**
core `BoundarySnapping.swift` · `Operations+Container.swift` ·
`Operations+Appearance.swift` · `Operations+UndoInverses.swift` ·
`Operations+Structural.swift` · `Operations+TakeEdits.swift` ·
`UndoStack.swift` · `Bridge/BridgeEngine.swift`; app
`EditorTextView.swift` · `PaneSurface.swift` · `ShellActions.swift` ·
`BookStructureModel.swift` · `TutorialSeeder.swift` ·
`EntryListViewModel.swift` (mobile); canon `notes/AppSpec.md` +
`notes/QUESTIONS.md`.

#### Item 1 — #37(iii): the ensure half moves INTO the shared door

The create-and-pin block left `JournalBooks.openToday` entirely and became
`insertDailyJournalBook` inside `shelveInDailyJournalBook`. All four doors
now share ONE rule with no residue at ⌘J — which the guard revert proves
mechanically rather than by inspection (revert B reds ⌘J's own suite, five
tests, because its book now comes from the shared door).

**The one design decision inside it: WHERE the creation runs.** The ordinary
path stays a READ (a designation exists on every round after the first);
only its absence opens a `database.write`, and that write RE-READS the
designation inside the writer before minting. GRDB serializes writers, so
two doors racing the very first entry cannot mint two Journal books — the
same hazard Phase 13's Stage B review closed for ⌘J by moving its read
inside the runner, closed here at the one place all four doors share. A book
minted in that transaction can carry no membership row, so `decided` is
false by construction rather than by a second query.

**`noDailyBook` is REMOVED from `DailyBookShelving`**, not left unreachable:
the ruling makes it impossible, and a case that can never be returned is the
drift class R1-2 punished. The three call sites lost their branch; two of
them (the bridge's note, the phone's note) lost copy that now describes
nothing.

**What creation deliberately does NOT do:** replace a book she designated. A
FINISHED, FULL or SMART daily book keeps its own status and wording — those
are her states, and answering them by minting a second Journal beside hers
would be inventing product behavior. Pinned
(`creationNeverReplacesABookSheDesignated`,
`aDecidedPairIsLeftAloneAndTheCreationNeverSecondGuessesHer`).

**Two internal db-level helpers** (`setDailyJournalBook(_:_:)`,
`setShelfPinned(_:_:pinned:)`) so the in-transaction path shares the ONE
implementation with the public ops instead of copying it — the public doors
now forward.

**The §9 delta (the orchestrator's to review):** the superseded PROVISIONAL
sentence is quoted where it stood, her ruling is quoted, the retirement of
`noDailyBook` is stated, and the never-replaces-her-book limit is written
down as part of the rule rather than left to the code.

#### Item 2 — A12: the destructive-undo warning, at her definition exactly

**The condition is asked ONCE.** `Operations.wouldInsure(currentText:
preImage:dirty:)` is the predicate `revertStructural` already computed inline
to decide the fourth quiet auto-commit; it is now a named static that BOTH
the commit and the warning consult, so the dialog and the insurance can never
disagree about what the class is.

**The warning is DATA, not a per-site decision.** `UndoStack.Entry` gains
`insuring: [TextPreImage]` — the same values the inverse hands
`revertStructural` — and `register` takes it with a default of empty. Every
entry that restores no buffer (deleteBlock, moveBlock, reorder, merge, the
W, poolDragCopy…) is silent BY CONSTRUCTION rather than because someone
remembered to say so; exactly three ops pass it (`extract`, `divide`,
`editTakesAtomically`), because exactly three restore buffers. A compound
folds its legs' arrays, so Make Block warns for both divides as one act.

**It is asked at the door, against the store as it is NOW** — an entry
becomes warnable the moment she edits the buffer and stops being warnable the
moment she commits it, and neither event touches the stack. `insuranceTargets`
never throws and never writes: a store hiccup degrades to "no warning", never
to a blocked undo, because the insurance itself rides inside the undo's own
transaction (pinned: `theWarningNeverChangesWhatTheUndoDoes`).

`ShellActions.structuralUndo(confirm:)` follows `openTutorial`'s precedent —
injectable decision, NSAlert default — and the copy names what would be set
aside AND where it goes (the take's history). Cancel speaks and touches
nothing.

**THE FINDING THIS ITEM PRODUCED, recorded because it cost an hour and is
the kind of thing that repeats:** the tutorial spine HUNG. The field guide's
own "the two undos" lesson has a pin that types after a divide and then
undoes — which is precisely the insurance class — so the default NSAlert ran
`runModal()` in a test host and waited forever. Three consequences, all
landed: the pin answers the confirm (a ruled change, named below); the
doc comment now says a headless caller in the class MUST pass `confirm:`;
and **the lesson's PROSE was corrected** — it said the app "quietly keeps a
savepoint" and told her to press ⌥⌘Z and look in history, which is no longer
what she will see. It now says the app ASKS FIRST, that saying yes keeps the
savepoint anyway, and that every other structural undo stays silent. *(This
adds one more stale lesson to the standing field-guide re-seed obligation —
still one "Restore Tutorial" run.)*

#### Item 3 — the idle-voice-switch render restore (panes memo §6 item 5)

One call — `context.coordinator.restoreRenderTier()` — on the font/gap
re-attribution branch, plus the small internal method it needs (the render
half of the A47c occasion, without the geometry half, coalesced by the same
latch). That branch IS the memo's edge 3: a full-range `addAttributes` with
no user event behind it, which is exactly the write A47c traced as stranding
a tail-scrolled pane's rendering surfaces, and the occasion heals cannot
reach an idle card. Pinned at the A47c seam (`renderRestoresRun`) with a
non-vacuity arm proving the re-attribution really ran.

**One test-craft fact worth carrying:** the deferred restore is a
`DispatchQueue.main.async` block, and in this test host such a block only
drains when the main actor YIELDS — `RunLoop.main.run(until:)` alone left it
pending and the pin read zero. The pin now pumps and yields (the
`TakePaneMeasureTests` shape).

#### Item 4 — A22: typewriter room, and the mechanism the pins REJECTED

Her ruling: ~one viewport-page of scrollable allowance below the last line,
ALWAYS ON, Write's full-document editor only, and a click in the room lands
the caret at the end of the text. Shipped as
`TypewriterScrollView` + `TypewriterClipView` in the editor's own stack, with
the arithmetic pure (`TypewriterRoom.height(viewport:lineHeight:)` — a
viewport LESS ONE LINE, so at maximum scroll her last line sits at the top
rather than one pixel above it).

**The mechanism was chosen by measurement, and the FIRST choice was wrong —
this is the batch's most important record.** `contentInsets.bottom` was built
first and measured beautifully: clip height exactly unchanged (400.0 →
400.0), scroll range extended by exactly the room (2406.5 → 2700.5), and the
vertical scroller reflecting the extra range (knobProportion 0.1425 →
0.1290, which the alternative does not do). **It also broke clicking into her
own text.** With the inset set, every point below the top ~17 pt of the
viewport hit-tested to an AppKit backdrop view — at depths where her prose
was VISIBLY DRAWN (measured both ways in the same run: `ink: true`, hit
wrong). AppKit lays a backdrop over the inset region and the document keeps
drawing through it, so the failure is invisible until you click. **13c 1C's
dead-strip tripwire is what caught it** — the pin written to fire "if this
class ever grows from a sliver into a band of page" fired at 483 pt. The
shipped mechanism is an `NSClipView.constrainBoundsRect` allowance: same
scroll range, no view added, hit testing untouched.

**Recorded cost of the switch, for her walk:** the vertical scroller's knob
does not cover the room (AppKit sizes it from the document rect), so the room
is reached by ordinary scrolling — wheel, trackpad, keyboard — not by
dragging the knob to the very bottom.

**The click had to be built too, and a pin found that as well.** The room is
covered by no view (NSClipView hit-tests transparently past its document), so
a click there reached nothing and left the caret where it was. My first
reading of the probe said otherwise — it had mistaken a pre-existing
end-of-text selection for the click's work; resetting the selection first is
what exposed it. `hitTest` now claims exactly the region below the document
(never a scroller, never the document), and `mouseDown` answers with the text
view's OWN `characterIndexForInsertion`, which for a point past every line IS
the end — the same behaviour batch 1C measured for the phantom, which is what
her "the room is space, not paper" asks for.

**The room is ALLOWANCE, never content** — pinned: no stored byte, no export
byte, no outbox row moves, and the ratified edge-trimming rules are
byte-untouched (a whitespace-only tail still mints no block; the leading run
still attaches as ordinary content — the room replaces the NEED to type them,
it does not change what typing them does). It composes with the phantom heal
for free: the heal re-frames the text view, and the room is measured from the
VIEWPORT and simply sits below whatever height that leaves — `LongBlockLayout`
never learns this exists, so the stop-and-propose door was not needed.

**Honestly unpinned, stated:** AppKit's own delivery of a synthesized
mouse-down could not be driven in this test host (`NSApp.sendEvent` and
`window.sendEvent` both leave the caret untouched, with the hit test already
answering correctly), so the click pin asserts the hit test AND invokes the
handler the hit test selects. What is unpinned is AppKit's routing, not our
code.

#### Item 5 — A11: the blank line divides into the FIRST half

Landed in `BoundarySnapping.seamTrimmedHalves`, which the trace confirmed is
the ONE halving function every divide door consults (plain `divide`,
`divideW`'s per-take cuts) — so the ceremony inherits it with no second
implementation, and the stop-and-propose door was not needed. The rule is the
standing k−1 ownership rule, applied to the seam run both trims drop:
`"para1\n\npara2"` cut at the blank yields `("para1\n", "para2")`, the
editor's single-`"\n"` separator re-creates the rest, and **her page does not
change at all** — pinned at the surface (`aDivideAtABlankLineLeavesTheSurface
ExactlyAsItWas`) and through `renderedText` (round-trips byte-identical).

k = 1 (the ordinary paragraph cut) and a seam with no newline are
byte-unchanged. An EMPTY first half gains nothing — an edge run has no
preceding piece to own it (`bulkSegments`' own rule), so the ops layer's
empty-half refusal keeps refusing exactly what it did.

**Composes with the differential editor path unchanged:** the first half is
still a strict PREFIX of the old text, which is what `StructuralSeamEdit`'s
retained-byte guard requires; a divide at a blank line now rewrites the
surface to the same bytes it already had (and re-brackets the attributes),
which is the point.

**The sibling class found and deliberately NOT widened, for the
orchestrator/her walk:** `extract` drops the same blank. Its `.suffix` case
trims the head, so extracting a trailing paragraph after a blank line leaves
`"para1"` where the same ownership rule would say `"para1\n"`; the `.prefix`
case is subtler still (the newline would have to ride on the MINTED block,
since that is the preceding piece). Her ruling names divide, she reported
divide, and extract's shipped semantics are pinned in several places — so it
is recorded here rather than changed under cover of an A11 build.

##### Pins — every change named

| Pin | Change | Why |
|---|---|---|
| `seamTrimmingDropsTheSeparatorFromBothHalves` | **rewritten + renamed** → `seamTrimmingGivesTheBlankLineToTheFirstHalf`; gains k=1 and k=3 arms | the ruled flip (A11) |
| `theSeamRunIsOwnedTheSameFromEitherSideOfTheCut` | **NEW** | a cut before / inside / after the newline run describes ONE seam and must own it identically; mixed whitespace normalizes |
| `aCutInsideEdgeWhitespaceLeavesAnEmptyHalf` | gains a leading-run arm | A11's cannot-widen edge: an empty first half gains no newline |
| `divideExactRows` · `divideFeedsChurn` | **updated** (first half `"Para one.\n"`, churn 11 → 10) | the ruled flip, at the op |
| `aDivideAtABlankLineKeepsTheBlankAndRoundTrips` · `aDivideAtAPlainNewlineIsUnchangedByTheBlankLineRule` · `theCeremonysPerTakeCutsInheritTheBlankLineRule` | **NEW (3)** | her report; the unchanged ordinary case; the ONE-brain claim as a test |
| `aDivideAtABlankLineLeavesTheSurfaceExactlyAsItWas` | **NEW** (Mac) | her report at the surface where she made it |
| `withNoDesignatedBookTheBodyStillLandsAndTheRoundSaysWhy` | **rewritten + renamed** → `withNoDesignatedBookTheLandingCreatesAndPinsTheJournalBook` | #37 OVERTURNED; the pin asserted the superseded PROVISIONAL |
| `aDanglingDesignationLandsAndSaysWhy` | **rewritten + renamed** → `aDanglingDesignationGetsAFreshJournalBook` | same ruling; a dangling designation reads as none |
| `aSecondLandingJoinsTheBookTheFirstOneCreated` · `creationNeverReplacesABookSheDesignated` | **NEW (2)** | the ensure is once, not per landing; the cannot-widen edge |
| `shelvingCreatesDesignatesAndPinsTheJournalBookOnFirstUse` · `shelvingEnsuresOnceNoMatterHowManyDoorsCallIt` · `aDecidedPairIsLeftAloneAndTheCreationNeverSecondGuessesHer` · `shelvingStillNeverThrows` | **NEW (4, core op level)** | the ruling at the op the four doors share |
| `theCaptureMintIsNeverBlockedByShelving` (mobile) | **updated second half** | ruled flip: the phone's capture now lands IN the Journal book; the never-blocked half is untouched |
| `theWarningFiresExactlyOnTheInsuranceClass` · `everyOtherStructuralUndoIsSilent` · `aCompoundWarnsForEveryLegItWouldRestore` · `theWarningNeverChangesWhatTheUndoDoes` | **NEW (4)** | A12's "only", both halves, and that the question is never a gate |
| `DestructiveUndoWarningTests` (NEW suite, 5) | new | the DOOR: it asks, obeys a cancel, never interrupts an ordinary undo, leaves redo alone, and its copy names what is set aside |
| `structuralUndoInsuresTextTypedAfterTheAct` (tutorial) | **updated** — answers the confirm | ruled change: that act IS the insurance class, which is what the lesson teaches |
| `aGapOrVoiceChangeRestoresTheRenderTierWithNoUserEvent` | **NEW** | the panes memo's edge 3 |
| `TypewriterRoomTests` (NEW suite, 8) | new | the room's arithmetic, its allowance, its resize follow + change gate, the click, Write-only scope, zero stored bytes with the trimming rules intact, the jump, **and `theRoomNeverStealsAClickOverHerText`** |
| `aClickInThePhantomLandsTheCaretAtTheDocumentEnd` (13c 1C) | **probe moved to the phantom's midpoint**; the helper's hit-test conversion corrected | construction, not behaviour: the fixed 20 pt probe landed inside AppKit's own non-routing sliver once the room changed where the scroll settles |
| `theDeadStripAtTheBottomOfTheScrollViewStaysASliver` (13c 1C) | **re-scoped**: "dead" = routes to NEITHER the text view nor the room | the room is not dead space; the pin's job (a band of page must never stop routing) is preserved exactly, and it is what caught the inset mechanism |

##### Guard-revert evidence (checksums taken first; `shasum -c` OK after every restore)

| Revert | Applied | Observed RED |
|---|---|---|
| **A** — the k−1 rule removed (the exact pre-A11 body) | `seamTrimmedHalves` | **6 pins, 10 issues** across two suites — the blank vanishes from both halves at the Domain level, at the op, in the ceremony, in the round trip, and the churn arithmetic moves. Her report, reproduced |
| **B** — the creation unwired (`return .refused(…)` before the write) | `shelveInDailyJournalBook` | **6 pins** in core (no book minted; the notes speak the retired wording) **plus 5 in the Mac's `JournalBooksTests`** — the second half is the proof that ⌘J genuinely delegates rather than keeping a copy |
| **C** — `pendingUndoWarning` always nil (the pre-A12 world) | `UndoStack` | **2 core pins, 4 issues** + the door's own pin: the confirm is never asked and the undo runs straight through |
| **D** — the render restore removed from the font/gap branch | `PaneSurface` | 1 pin: restores stay at 0 through a real re-attribution — the memo's edge 3, un-healed |
| **E** — the room switched off (the pre-A22 world) | `TypewriterScrollView` | **3 pins, 7 issues** — no allowance, no resize response, the room point is not even inside the viewport, and the click's hit test finds nothing |
| **F** — the room's `hitTest` claim removed (room on, nothing claims it) | `TypewriterScrollView` | exactly 1 pin: the room hit-tests to `NSVisualEffectView` — the discriminating revert for the half that had to be BUILT |
| **G** — the room claims the whole viewport (a room that steals clicks over her text) | `isInRoom` | **3 pins across two suites** — `theRoomNeverStealsAClickOverHerText` (four depths), the phantom click, and the room pin's own over-text arm. This is the revert that proves the new guard discriminates the defect the inset mechanism actually had |

##### Judgment calls

1. **`noDailyBook` REMOVED rather than left unreachable.** A public case that
   can never be returned is the drift class; removing it made the compiler
   walk the three call sites for me.
2. **The creation's double-checked write** (fast read, then a re-read inside
   the writer) rather than a single write on every call: the ordinary path
   stays read-only, and the mint-two-books race is closed by GRDB's writer
   serialization rather than by a lock nobody would find.
3. **`insuring:` is DATA with a default, not a required parameter.** `redo:`
   is required because a missing redo is a silent hole in a feature; a
   missing `insuring` is *correct* for every op that restores no buffer,
   which is most of them. The three that do restore are the three that pass
   it.
4. **The A12 dialog names the count, not the takes.** "One take has been
   edited since" — naming which takes would mean rendering block/take
   identity in an alert, and the count is what decides her answer.
5. **The tutorial lesson's prose was corrected** rather than left describing
   a quiet undo she no longer has (batch 1's judgment call 6, applied to a
   lesson this batch changed the behaviour of).
6. **A22's mechanism switched after measurement**, and the rejected one is
   written up in the code rather than deleted — a future session reading
   "why not just use contentInsets?" gets the answer with numbers.
7. **The room is a viewport LESS ONE LINE.** A literal viewport would let the
   last line scroll one pixel out of reach; the line comes from the font's
   own metrics, never `NSLayoutManager.defaultLineHeight` (TK1 — TEXTKIT2 §4).
8. **Extract's blank-line sibling recorded, not built** (item 5's section).

##### Deviations

- **None from the brief's five items**, and neither stop-and-propose door was
  needed: A22's mechanism touches neither the heal path nor `LongBlockLayout`,
  and A11's mechanism IS the seam-trim function.
- **Three pins in files this batch did not own were changed** — the two 13c 1C
  characterization pins (construction + re-scoping, above) and one tutorial
  pin (answers the confirm). Each is named with its reason; none weakens what
  it was written to catch, and the 1C dead-strip pin in particular kept its
  teeth (it is what caught the inset defect).
- **No lookup subagent used** — the one external question (what
  `contentInsets` does to hit testing) was answered by measuring the real
  thing, twice.
- **No visual loop** (P-7's screenshot half): the room is the one genuinely
  visual item, and what a human eye would add — whether a viewport-less-a-line
  of air below the last line FEELS right — is hers at the walk, not mine to
  claim.

##### PENDING / for the orchestrator

- **Nothing unverified.** All three suites plus the tutorial spine were run by
  me, run lines quoted above.
- **For her walk (three one-liners):** (1) the room is reached by scrolling,
  not by dragging the scroller knob to the bottom — a consequence of the
  mechanism the pins forced; (2) A12's dialog wording ("One take has been
  edited since… it is committed first, so you can bring it back from the
  take's history"); (3) extract at a blank line still drops it — the A11
  sibling, deliberately unbuilt.
- **The field-guide re-seed obligation gains one more stale lesson** ("the two
  undos" — still one "Restore Tutorial" run).
- **For the end-of-phase Fable review, suggested foci:** (1) the A22
  mechanism story — is `constrainBoundsRect` the right final answer, and is
  the scroller-knob cost acceptable? (2) `insuring:`'s defaulted parameter —
  right call, or should it be required like `redo:`? (3) the A12 modal's
  reach: any OTHER headless caller of `structuralUndo` that could hang (I
  found only the tutorial pin; the palette and menu doors are user-facing).
  (4) whether extract should inherit A11 after all.

#### Batch 5 — ACCEPTED (2026-07-28; the orchestrator's adjudication)

**Counts by my own runs, all three suites:** core `✔ Test run with 901
tests in 101 suites passed after 43.632 seconds` · Mac `✔ Test run
with 873 tests in 145 suites passed after 98.627 seconds` · mobile
`✔ Test run with 14 tests in 4 suites passed after 0.262 seconds` —
all matching the record; tree clean at `0a29e60`. (A burst of stale
SourceKit diagnostics against two test files was checked against the
source — both symbols exist — and refuted by the runs.)

**The §9 canon delta REVIEWED and it STANDS:** her ruling quoted, the
superseded PROVISIONAL sentence quoted where it stood, the
dangling-designation reading stated, and the never-replaces limit —
creation never touches a FINISHED/FULL/SMART book she designated,
because answering her deliberate states by minting a second Journal
would be inventing product behavior. Exactly her ruling, nothing
beyond.

**The A22 mechanism story is P-7 working:** the first mechanism
(`contentInsets`) measured perfectly and was WRONG — clicks below the
top ~17 pt missed the text at depth, and 13c 1C's dead-strip tripwire
pin fired at 483 pt, which is precisely what that pin was built to
catch. The shipped `constrainBoundsRect` allowance + the narrow
`hitTest` claim carry their own guard
(`theRoomNeverStealsAClickOverHerText`, revert-discriminated). The
scroller-knob nuance (the room is reached by scrolling, not by
dragging the knob) is recorded for her and joins the Design & UI
review row's material.

**The tutorial-spine hang was the spine doing its job** — the field
guide's insurance lesson met A12's modal and held; the `confirm:` seam
plus the corrected lesson prose are right, and the re-seed obligation
grows by one lesson (still ONE "Restore Tutorial" run).

**Extract's blank-line sibling: correctly NOT widened** — her ruling
named divide; extending it silently would be scope growth. Recorded
as a one-line question on the handoff checklist (review focus 4
weighs it too). The three 13c-owned pin changes are accepted on their
named reasons; the review re-checks them cold. **The phase's build
work is COMPLETE — the ONE Fable cold review runs next.**

## THE 13D SITTING — 2026-07-28 (author-attended; the agenda below was walked in four question batches; rulings verbatim-faithful)

Her opening: *"ok, you can give me the questions, my live app is closed,
and we can close the phase out."* Every agenda item was ruled; the
phase closes after one final build batch, the Fable review, and the
ritual.

**RATIFIED AS SHIPPED (her picks of the recommended option, except
where quoted):** **#48** all seven build calls ("Keep all seven") ·
**#33(a–e)** and **#36** (inside her words: *"aside from that, these
seem fine"*) · **#43(b)(c) · #44(a)(b)(d) · #45(a)(d)(e)** + the
callout-as-indent page note · **#46 all five + A31's two** ("Ratify
all seven") · **#47(a)(d)** + the filter-OFF placement, and
**#47(b)** after asking *"what does a version link alone doesn't make
blocks related? like if one *post* is a version of the other htey
aren't related? or if a block is a verison of another block they
aren't related?"* — answered (the mark is post-level, one anchor edge,
no block correspondences; no user-facing block-version mark exists)
and then RULED "Keep as shipped" · **#38** "Leave it — no timer"
(revisit with Phase 12's dirty-day remedy) · **#42** "Keep the
refusal" · **#31** A21 "Leave at 13e" · **the block-extent memo
Q1/Q2/Q5** "Accept all three" (tight callouts + the new gap setting
for room; seam centred CONFIRMED; inline comments keep UNIFORM
airiness — **A5 is DISPOSITIONED as addressed**) · **the
long-content-panes memo §6** "Accept all" (hold the landed
stabilization; **option (a) PRE-APPROVED, evidence-gated** — defaults
recorded: ~1.5× screen threshold, fan cards only, focus un-caps; the
(c) escape hatch stays bookmarked unbuilt).

**OVERTURNED / NEW RULINGS (batch 5 builds these):**

1. **#37 OVERTURNED to option (iii)** — her words: *"the fragments
   entries should arrive as part of Journal"*. A Fragments landing
   with NO daily journal book designated now CREATES AND PINS the
   Journal book exactly as ⌘J's first press does — the ensure half
   moves into the shared door so all four doors truly share one rule.
   This supersedes §9's "It never creates a book (PROVISIONAL,
   QUESTIONS #37)" sentence; the canon delta lands with the build.
2. **A12 RULED + build now:** warn ONLY on the insurance-class undo —
   an undo that would discard text edited since the operation (the
   case the fourth quiet auto-commit occasion insures). Every other
   structural undo stays silent.
3. **The panes memo's one-line idle-voice-switch render fix builds
   now** (§6 item 5's "add it" arm — her Accept-all).
4. **A22 RULED + build now:** REAL typewriter room — about one
   viewport-page of scrollable space below the last line, **ALWAYS
   ON** (no setting), a click in the room lands the caret at the end
   of the text ("the room is space, not paper"). **The edge-trimming
   rules stay exactly as ratified** (whitespace-only tails never
   mint) — her A47b "should we just stop trimming?" question is now
   RULED: no; the room is the real answer.
5. **A11 RULED + build now:** divide on an empty line — the blank
   line belongs to the FIRST half (the standing k−1 trailing-newline
   ownership rule, one rule everywhere).

**NEXT PHASE: 13f — Workspace** (her K4 "soonest" rank; the closeout
authors its plan; its kickoff stays hers). Nothing rolls to it from
13d — every 13d scope row is now built, building in batch 5, or
dispositioned (A5 addressed; A21 stays 13e).

**Install refresh authorized by context** (her app is closed, her
words above) — executes at the closeout behind the standing A1 rail.

## The 13d sitting agenda (bundled; nothing here gates the shipped batches — WALKED IN FULL at the sitting above)

One list, so the sitting runs off one section — the detail lives in
the QUESTIONS entries and the two memos:

1. **#48** — the seven one-line build calls from batches 2–4 (status
   lines · no-caret divide · ⌥⌘N · spellcheck defaults · additive gap
   · ⇧⏎'s early mint).
2. **The rolled 13c walk items** — #29 (the C3 memo's Parts 1/3 —
   gates A5's real scope), #30–#33, #36, #37, #38, #42, the minor
   sub-calls of #43–#47, #46's five conversion rulings, and the
   long-content-panes memo's §6.
3. **A12's definition** — which structural undos warn ("undo of a mint
   that had post-op edits" is the recorded candidate).
4. **A22's design** — typewriter room as REAL enterable space,
   composing with the phantom fix; her "should we just stop trimming
   edges?" question from the 13c A47b sitting, ruling deliberately
   untaken until now.
5. **A11** — divide on an empty line and what the blank line IS (the
   1G ownership rule is the recorded input; likely interacts with 4's
   ruling).
6. **The field-guide re-seed confirm** (one "Restore Tutorial" run —
   stale since 13c's 2C, plus batch 1's Compare paragraph and batch
   4's copy touches).
7. **The install refresh** — at her word, zero-instance + fresh A1
   backup as always.

## Verification

Per-batch: the standing loop (build → pins → the tutorial spine green →
full suites, counts confirmed by the "Test run with N tests" line —
never a bare SUCCEEDED). Phase-end: the review shape the author sets at
kickoff. Red-on-old absolute; the hallucination guard binds; every
PROVISIONAL to `notes/QUESTIONS.md` (append, never renumber — next
free number at authoring time: #48).

## Environment

The 13c plan's environment-traps section binds by reference (instance
discipline incl. discriminate-by-path; no Release builds/refreshes
beside a live instance; WAL-safe UTC-named backups before touching the
real store; suite-level `-only-testing` only, with the run-line proof;
zsh `pipestatus`; never a custom build configuration; the sandboxed
test host's scratchpad limitation; the worktree-must-be-named-
`variorum` SPM note from the 13c refresh record).

## The 13d cold review — round 1 findings (2026-07-28, fresh Fable reviewer, REVIEW_PROMPT.md verbatim, zero framing)

Reviewed: the combined diff `99c5ecb..472a9bc` (all 21 phase commits), read
whole; the plan file's five batch records + acceptances + the sitting record;
the canon deltas (AppSpec §9/§14, QUESTIONS) checked against the code; the
batch records' suggested review foci each addressed below. Severity-ranked;
each finding carries its traced mechanism. Recorded BEFORE any fix, per the
review protocol.

### Findings

**[MAJOR] F-1 · `EditorViewModel.swift:667` (the B2 fork) + `:876`
(`runSoftNewlineInTail`) · ⇧⏎ with the caret MID-tail displaces the newline
— and the caret — to the document end.** The fork discards the keystroke's
`range` entirely; `runSoftNewlineInTail` re-plays the newline at
`index.documentLength` after the mint, having first moved the selection
there. The `.tail` verdict covers EVERY offset inside the tail region
(`BlockRangeIndex.verdict`'s containment arm), and the open tail is the
STANDING state while she composes the trailing paragraph — it closes only
when the next paragraph begins, at the 2 s idle mint, or at teardown — so
"type a sentence, arrow back a few words, press ⇧⏎" hits this in ordinary
fresh writing. Concretely: tail `"beta more"`, caret after `"beta"`, ⇧⏎ →
the store reads `["alpha", "beta more\n"]` with the caret teleported past
`"more"`, where the ruling's own equality bar (rider 2's road: idle-mint,
then ⇧⏎ at that same caret — a mid-BLOCK content newline) gives
`["alpha", "beta\n more"]` with the caret after the newline. The shipped
pins never drive a mid-tail caret (`shiftReturnInATailMintsAndStays…` sets
the selection to the end before every soft return), so the equality bar was
proven only at the one offset where the two answers coincide. This is not
the ruled "appends" shape doing its job — the ruling's contract sentence is
*"⇧⏎ ends with the caret inside a real block and the newline as that
block's content"*, and a displaced newline is not the caret's content.
**Fix:** capture `range.location` at the keystroke, re-play at it (clamped
to the post-mint document length — the mint changes no surface byte, so the
offset survives). Red-on-old pin: mid-tail caret, equality against the
idle-mint-then-⇧⏎-at-that-caret road.

**[MINOR] F-2 · `EditorTextView.swift:49` (`isSoftNewlineKey`) · the
modifier test defeats the gesture under caps lock and makes the keypad
branch dead on real hardware.** The guard requires
`modifierFlags.intersection(.deviceIndependentFlagsMask) == .shift` —
EXACTLY shift and nothing else in the whole device-independent word. Two
flags AppKit sets that carry no meaning for this distinction break it: (a)
`.capsLock` is set on every key event while caps lock is LATCHED, so ⇧⏎
with caps lock on is silently not the gesture — the tail opens as if plain
⏎, a ruled gesture that reads as a dead key (the exact class this phase's
floor exists to kill), with nothing spoken; (b) `.numericPad` (with
`.function`) rides every keypad key event, so the explicit `"\u{3}"` keypad-
Enter arm — judgment call 4's "keypad Enter counts as the gesture" — is
unreachable from real hardware; it passes only for the tests' synthesized
events, which set `[.shift]` alone. **Fix:** intersect with the four
meaning-bearing modifiers (`[.shift, .command, .control, .option]`) and
require exactly `.shift` — Control-⏎/⌥⏎/⌘⇧⏎ exclusions all survive
(each intersects to more than `.shift`). Red-on-old unit pins for both
flags.

**[MINOR] F-3 · `TakesViewModel.swift:1253` (`prepareDivide`) · the seed
fallback `?? liveActive.first` silently re-targets the divide when the
caret's take has vanished from the live fan.** The fresh store read is the
authorization (ruled, batch 3 d1) — but when the seed take (the focused
pane's, or the slot's rendered take) is no longer in `liveActive`
(archived/deleted by sync or a sibling surface mid-race), the fallback
substitutes `liveActive.first` and proceeds: with one other take left the
block DIVIDES that take immediately, at a word-snapped offset derived from
a caret that was never in it — no sheet, no refusal, no mention. Write's
door in the identical state refuses and speaks (`DivideWCeremony.open`'s
"This block's takes changed — try the divide again"; the pre-extraction
`openDivideWCeremony` did the same), and `prepareDivide` itself speaks that
exact line when the fan is EMPTY — the fallback is the one arm that
neither speaks nor matches Write. It appears in neither the proposal nor
the batch record, in a batch whose binding constraint 1 was byte-parity
with Write's door. Undoable, race-narrow — but a silent act on a take she
was not in. **Fix:** drop the fallback; the vanished-seed case joins the
existing takes-changed refusal (Write's posture exactly). Red-on-old pin:
archive the focused take behind the frozen projection, `divideFocused`,
expect refusal + store untouched (old code cuts the surviving take).

**[MINOR] F-4 · `EditorTextView.swift:316` (TypewriterScrollView header
doc) · the room's summary paragraph states the REJECTED mechanism as the
shipped one.** "*The room is ALLOWANCE, never content. It is
`contentInsets.bottom` on the scroll view: …*" — but the mechanism story
two paragraphs down records `contentInsets.bottom` as measured-wrong (the
hit-test-eating backdrop; the 1C tripwire fired at 483 pt) and the shipped
mechanism is the `NSClipView.constrainBoundsRect` allowance. The comment's
own stated purpose is to stop a future session "simplifying" the mechanism
back; its lead paragraph currently instructs exactly that regression. Doc
fix, no pin (clarity class; the degradation is a reader re-introducing the
click defect the tripwire caught).

**[MINOR — record-only, the closeout's to execute] F-5 ·
`notes/QUESTIONS.md` · the ledger lags the 2026-07-28 sitting.** The
sitting record (this file) rules #48 ("Keep all seven"), #38 ("Leave it —
no timer"), #42 ("Keep the refusal"), #31, #33(a–e), #36, the #43–#47
minor sub-calls, #46's five + A31's two, and the two memos — yet the
QUESTIONS entries still read "Status: OPEN" for every one of them, while
#37 (ruled at the SAME sitting) was annotated ANSWERED by batch 5. A fresh
session walking the ledger re-asks ruled questions — the R1-2 drift class
this phase cites in its own records. The batch convention ("annotate,
never resolve — disposition is the closeout's") explains restraint, but
the #37 asymmetry shows the sitting's rulings reached the ledger
selectively. Named here so the closeout ritual cannot miss it; deliberately
NOT fixed by the reviewer — the ledger walk's wording is the closeout's
own duty.

**[NIT] F-6 · `DivideWCeremony.swift` (host-protocol doc) · "Deliberately
six members" — seven ship.** The batch record corrected the count (the
seventh member, `speakCeremonyRefusal`, is judgment call 1's beep parity);
the doc comment kept the six and its "two voices" undercounts three. Doc
fix.

**[NIT] F-7 · `EditorViewModel.swift:873` (`runSoftNewlineInTail` doc) ·
the degradation claim "⇧⏎ behaves as ⏎ there" is mechanically wrong.** If
`idleMintTail` skips (structural flight / IME), the re-play runs inside
`withSoftNewline`, so a still-open mintable tail re-enters the B2 fork and
RE-SCHEDULES (chained cross-block compounds) until the mint lands — a
bounded, self-terminating retry, never a plain-⏎ tail insertion. The
behavior is fine; the record of it isn't. Corrected inside F-1's diff.

**[NIT — record-only, SPECULATIVE] F-8 · `EditorSurfaceController.swift:1212/:1233`
(`runSeamMerge` / `seamFanRefusal`) · the degenerate zero-active-fan block
would refuse with the wrong words.** The keystroke guard requires both
counts `== 1` while the ceremony threshold it claims to share is
`> 1 || > 1` — for a (hypothetical) live block with zero live active
takes the keystroke refuses "The block below has takes" where ⌘⇧M would
run the instant merge. Unreachable for live blocks (I10, the §7 repairs,
and `renderPost`'s active-take resolution all forbid the state), so no
failing-on-old pin could exist; labeled speculative and recorded, per the
prompt's own honesty rule.

**[NIT] F-9 · `AppSettingsView.swift:189` (`setDefaultSegmentation` catch)
· a failed write surfaces `String(describing: error)`** — the raw-dump
class the phase's own R1-3 discipline (and this very diff's `fannedBlock`
copy) exists to kill. One line through `OpsRefusalCopy.message(for:)`; no
pin (the path needs a failing store write, unreachable without a
failing-runner seam; clarity class).

### The batch records' suggested foci, each answered

- **B1-f1 (set inversion):** complete — zero `collapsedPosts` references
  survive anywhere in `App/`; every consumer routes through `isExpanded()`.
  No caller assumes "not in the set ⇒ open".
- **B1-f2 (`withHostedBook expanded: true`):** correct — the hosted pins
  that expand are measuring PROSE; the ruling's own pin
  (`outlineOpensWithItsPostsCollapsed`) observes the default via
  `expanded: false`. Nothing hides.
- **B1-f3/f4:** adjudicated at acceptance (post-domain vs page-domain is
  the ruling's letter); the page line is the Design & UI review row's.
- **B2-f1 (read-then-act window):** agree with recorded-not-closed — it is
  the ⌘⇧M door's own standing window; the eventual close is the
  `merge(_:requiring:)` precondition twin, a core change nothing here
  justifies. **B2-f2:** ruled at the sitting (#48a, keep). **B2-f3:** no
  other surface reaches a seam keystroke — panes are single-block by
  construction (`divideWorld`'s one-entry tiling is the same fact from the
  other side). **B2-f4:** the shared "Merge" undo label is the same act
  through the same op; right.
- **B3-f1 (latch release-before-sheet):** covered — the confirm's own
  flush + drift-refresh + re-take close the window the release opens; an
  edit made while the sheet sits open is exactly what the drift check
  exists for. **B3-f2:** ruled at the sitting (#48b/c, keep). **B3-f3
  (layering):** the closeout consideration stands as adopted; right not to
  move mid-phase. **B3-f4:** `WriteTakesPanel` already composes
  `isPaneLive`, so it inherits the freeze the day its model runs a flight;
  the trigger sentence is where it belongs.
- **B4-f1 (⌥⌘N):** ruled at the sitting (#48d, keep). **B4-f2 (A23 ×
  inline comments):** visual; the Design & UI review row's. **B4-f3
  (`EditorSurfaceChrome` as a bag):** acceptable — every field is "how
  this surface presents", and the one-gate rule (P-3/P-8) is worth more
  than a purer struct; watch it at the next addition. **B4-f4 (grammar
  rides checkWhileTyping):** right coarse mapping — same underline
  vocabulary, and a fourth level is the fineness §3 warns off.
- **B5-f1 (A22 mechanism):** `constrainBoundsRect` is the right final
  answer on the evidence; the scroller-knob cost is honestly recorded and
  hers to weigh. F-4 is the STORY's one defect, not the mechanism's.
  **B5-f2 (`insuring:` defaulted):** the right call — empty is the CORRECT
  value for the many no-buffer-restoring ops (silence by construction),
  where `redo: nil` is a meaningful choice a site must make. The residual,
  recorded: a FUTURE buffer-restoring op that forgets to pass `insuring`
  ships a silent destructive undo, and the existing pins (written against
  the three current ops) would not catch it — the coupling to watch is
  "any inverse that passes `restoringTexts` non-empty should have passed
  `insuring`". **B5-f3 (A12 modal reach):** grep confirms the tutorial pin
  was the only headless caller in the insurance class; the remaining bare
  `structuralUndo()` calls (four tutorial walks, one routing pin) never
  edit a buffer post-op before undoing, and the doc comment now warns the
  class. **B5-f4 (extract inherits A11):** correctly unbuilt — her ruling
  named divide; the one-line question sits on the handoff checklist where
  it belongs.

### Clean bill (load-bearing things specifically checked and found solid)

- **A11's one cut brain:** `seamTrimmedHalves` is the only halving
  implementation; `divide` and `divideW` both consult it (the ceremony
  inheritance pinned); the k−1 arithmetic is the 2026-07-12 rule's letter;
  CRLF is safe by construction (a `"\r\n"` is ONE `Character`, so
  `count(where: \.isNewline)` counts it once — grapheme clustering answers
  the class before it opens); mixed-whitespace normalization and the
  either-side-of-the-cut equivalence are pinned; the empty-first-half edge
  keeps the ops layer's refusal; `renderedText` round-trips byte-identical
  (op-level pin) and the surface pin holds byte-identity at the editor.
- **#37(iii):** the double-checked write (fast read → `database.write`
  with an in-writer re-read) genuinely closes the two-doors-race under
  GRDB's writer serialization; `insertDailyJournalBook` is field-parity
  with the retired ⌘J creation (same reading shape, designation + pin in
  ONE transaction); the never-replaces guard is pinned both ways;
  `noDailyBook` is fully retired (zero references repo-wide); the catch
  mapping preserves never-throws; ⌘J's delegation is proven by revert B's
  second half (its own suite red when the shared door is unwired).
- **A12:** `wouldInsure` is consulted by BOTH the warning and
  `revertStructural`'s insurance commit (one predicate, line-verified);
  `insuring` rides the entry as data, compounds fold legs, and exactly the
  three buffer-restoring ops pass it; `insuranceTargets` never throws and
  never writes; the warning read cannot change what the undo does
  (pinned); the tutorial lesson's prose was corrected WITH the behavior.
- **#34:** the precedence (carve → merge → refusal) is mutually exclusive
  by construction and pinned by the every-offset walk with non-vacuity;
  `interEntrySeparatorPair` is a behavior-preserving extraction (the A7
  walk byte-unchanged, its pins untouched); the fan authorization is the
  store read at run time through the ⌘⇧M door's own `liveActiveFans` —
  the R3-1 lesson at the right level, with revert D discriminating the
  projection reading; the sealed post refuses upstream at `adoptHeader`;
  locked-takes-merge is Phase 3 op parity, not invention; the three
  gesture directions all reduce to the same one-separator deletion.
- **A9:** the ceremony extraction is verbatim (state machine, confirm
  gate, drift refresh, cancel-inert compared line-against-line with the
  removed controller code); parity-by-forwards held (zero test edits at
  the extraction commit); the one-brain parity pin is EXHAUSTIVE (every
  caret × both arities, full plan equality including the snapped cut, with
  a non-vacuity arm); the flight latch + pane freeze ride the existing
  liveness authority — no second mechanism (P-3), all three `isPaneLive`
  call sites verified; the registry flip is declared and pinned; the
  store-read fork's revert B reproduced batch 2's signature exactly.
- **A14/A15/A16/A23/A24:** the chord sweep is a permanent pin
  (`noTwoCapabilitiesClaimTheSameChord`); `replacementIsSingleNewline` has
  exactly ONE consumer (verified in `verdict`), so B1 is surgical as
  claimed; the trace suite's already-stays contexts ran unchanged; A16's
  setter/read are upsert-only, outbox-riding, `.paragraph`-fallback
  matching `containerHeader`, sentence deliberately not offered (the
  ratified paragraph-granularity rule); A23 is per-paragraph (never
  per-seam), read at style-construction, additive, with `PagePaginator`
  untouched (Read's identity address unmoved) and the no-stored-byte pin
  including outbox rows; A24's default is byte-identical on the full
  editor, the §3 completion pairing is forced off with checking on and
  restored at `.off` (round-trip pinned), and the pane unification is
  recorded and ruled (#48e).
- **A22:** the allowance stores zero bytes (pinned with row/outbox/export
  counts); the room formula converges geometrically (at max scroll the
  last line sits at the viewport top; short posts get exactly what the
  geometry needs — `doc.height + room − clip.height` clamps to nothing
  when nothing is needed); the 1C dead-strip pin kept its teeth (it is
  what caught the inset mechanism) and its re-scope preserves the
  routes-nowhere claim; `hitTest` claims exactly the room (over-text theft
  revert-discriminated); the phantom-probe change is genuinely a
  construction fix (`hitTest` takes superview-space — the old conversion
  was a titlebar off).
- **Batch 1:** the set inversion is complete and the arrival argument
  survives mirrored (pinned); `expandAll` scoped to entries in hand;
  the scrubber is model-driven (post list), `disabled` not hidden on
  one-post books, the thumb reaches both track ends (the de-hollowed
  revert-D pin); Compare's flip is one default with 2E's semantics
  byte-untouched (13 composition tests unchanged).
- **Canon:** the §9 `shelveInDailyJournalBook` rewrite, §14's #34 delta,
  and the QUESTIONS #34/#37/#41/#43(a)/#44(c)/#45(c)/#47(c) annotations
  each read accurately against the shipped code, quote her rulings, and
  preserve superseded text in place (the R1-2 shape).
- **Boundaries:** zero `Sources/VariorumCore/Sync/` lines in the whole
  range; zero schema change (marker stays 4); the mobile pin flip matches
  the #37 ruling with its never-blocked half untouched; no new
  cost-∝-corpus path anywhere touched (the A12 read is ≤3 variant
  fetches; A16's observation is bounded; the room is O(1); the board
  divide reads one fan).

### The round-1 fix pass (same reviewer, same session — the 13c K6 precedent)

**Fixed: F-1, F-2, F-3 (each with a red-on-old pin verified by behavioral
revert), F-4, F-6, F-7, F-9 (doc/copy, traced + justified, no pin owed).
Recorded, deliberately not fixed: F-5 (the QUESTIONS ledger walk is the
closeout's own duty — fixing it here would pre-empt the closeout's
disposition wording) and F-8 (SPECULATIVE by its own label — no failing
pin could exist for a state I10 forbids).**

**Diff scope — 6 files:** `EditorViewModel.swift` (F-1: the B2 fork
captures `range.location`; `runSoftNewlineInTail(at:)` re-plays at it,
clamped as a belt — the mint moves no surface byte, so the offset survives;
F-7's degradation wording corrected in the same doc block) ·
`EditorTextView.swift` (F-2: `isSoftNewlineKey` masks to the four
meaning-bearing modifiers; F-4: the room header's lead paragraph now names
the shipped `constrainBoundsRect` allowance and points at the
rejected-mechanism story instead of asserting `contentInsets`) ·
`TakesViewModel.swift` (F-3: the `?? liveActive.first` fallback dropped —
a vanished seed joins the existing takes-changed refusal, Write's posture)
· `DivideWCeremony.swift` (F-6: seven members, three voices) ·
`AppSettingsView.swift` (F-9: the catch routes through
`OpsRefusalCopy.message(for:)`) · `ReturnKeyTraceTests.swift` +
`TakesDivideTests.swift` (the three pins).

**Pins added (3):**

| Pin | Suite | What it discriminates |
|---|---|---|
| `shiftReturnMidTailLandsTheNewlineAtTheCaretNotTheEnd` | `SoftNewlineTests` | F-1 — the ruling's equality bar at a MID-tail caret: `["alpha", "beta\n more"]` with the caret at `caret+1`, vs the pre-fix `["alpha", "beta more\n"]` with the caret at the end |
| `capsLockAndKeypadFlagsDoNotDefeatTheSoftGesture` | `SoftNewlineTests` | F-2 — ⇧⏎ under a latched caps lock, and shift+keypad-Enter as real hardware reports it (`.numericPad`/`.function` on the event); the ⌘/⌥ exclusions asserted unchanged in the same pin |
| `aVanishedSeedTakeRefusesInsteadOfDividingAnotherTake` | `TakesDivideTests` | F-3 — the caret's take archived behind the frozen projection: refuse-and-speak vs the pre-fix silent divide of the surviving take |

No pin subscripts an array whose length its red state changes (the batch-2
adopted rule): every store comparison is whole-array equality or
`first`-shaped.

**Guard-revert evidence (three source files checksummed BEFORE the revert
pass; `shasum -c` OK — all three byte-identical — after every restore):**

| Revert | Applied | Observed RED |
|---|---|---|
| **R1** — `runSoftNewlineInTail` re-targets `index.documentLength` (the exact pre-fix body) | `EditorViewModel` | **exactly 1 pin, 2 issues** — store `["alpha","beta more\n"]`, selection 16 where 11 (caret+1) is right; the seven other A15 pins GREEN (they drive end-of-tail carets, which is why the hole shipped unpinned) |
| **R2** — the whole-word `.deviceIndependentFlagsMask` test restored | `EditorTextView` | **exactly 1 pin, 2 issues** — the caps-lock event (flags 0x30000) and the keypad event (flags 0xa20000) both rejected; every other exclusion pin green |
| **R3** — `?? liveActive.first` restored | `TakesViewModel` | **exactly 1 pin, 2 issues** — no takes-changed message, and the store reads `["Alpha beta","gamma delta."]`: the surviving take CUT, silently — F-3's mechanism reproduced verbatim |

**Verification (after all fixes + restores):** tutorial spine
`✔ Test run with 49 tests in 7 suites passed after 11.949 seconds` (all
Tutorial* TYPES by name — and the 2E trap bit once first: a 7-name guess
matched only 4 suites and the run line exposed it at 28/4, exactly the
trap's recorded shape; re-run with the real type list) · core
`✔ Test run with 901 tests in 101 suites passed after 29.261 seconds`
(**901/101** — baseline exactly; zero `Sources/` lines in the fix pass) ·
Mac `✔ Test run with 876 tests in 145 suites passed after 93.402 seconds`
(**873/145 → 876/145**: the three pins, no new suite) · mobile
`✔ Test run with 14 tests in 4 suites passed after 0.244 seconds`
(**14/4** — untouched by the fixes; run anyway). Her instance: no Variorum
process was live at any point in the review or fix pass (`pgrep` empty at
open); no Release build, no `/Applications` refresh, no store touched,
zero `Sources/VariorumCore/Sync/` lines.

**Left for the closeout, restated:** F-5 (walk the QUESTIONS ledger — #48,
#38, #42, #31, #33, #36, the #43–#47 sub-calls, #46's five + A31's two,
and the two memos all ruled at the 2026-07-28 sitting but still marked
OPEN); F-8 stands recorded; the B5-f2 residual (a future buffer-restoring
op that forgets `insuring:` ships a silent destructive undo — the coupling
to watch is "an inverse that passes `restoringTexts` non-empty should have
passed `insuring`").

### Post-fix correction to F-5 (same session, on the record)

**F-5 is MOOT — and it was already being fixed while the review read.**
The finding was recorded against the review range's end state (`472a9bc`),
where the ledger genuinely lagged the sitting. Commit `a284c06` ("13d
closeout: the QUESTIONS sweep") landed from the orchestrator DURING this
review's reading pass, before the findings commit, and does exactly what
F-5 asked the closeout to do: every rolled walk item's status is ANSWERED
in place per the sitting's rulings (#48 "Keep all seven" · #38 "leave it,
no timer" · #42 "KEEP the refusal" · #29/#30/#31/#33/#36 and the #43–#47
sub-calls verified in the sweep's diff), with #32 alone left open by
design (routed to the Design & UI review row). The #37-vs-the-rest
asymmetry the finding named was a snapshot of a sweep in flight, not a
hole. Nothing further is owed on F-5.
