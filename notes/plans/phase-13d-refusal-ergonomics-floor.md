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

### Batch 2 — #34, backspace-merge at a texted seam (brief authored when batch 1 lands)

Ruled (ii) at the walk: backspace at a seam between two texted blocks
MERGES when neither block has takes; refuses-and-speaks when either
does. Planner + merge wiring + pins; the §14 delta lands with it.
Pairs with A12's warning question (a sitting item). Brief follows
batch 1's acceptance.

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
