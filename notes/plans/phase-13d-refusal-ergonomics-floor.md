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
