# Phase 10 — Readings & first views (execution plan)

> Authored 2026-07-10 at Phase 9c's closeout per the front-loaded-planning rule, FROM
> `notes/plans/phase-10-brief.md` — the brief's author-ratified decisions are
> **binding** (minimal pool ships here; the read tier allows select+copy per post
> with click-to-focus; the 2026-07-09 scope additions 3–7). Its leanings are starting
> points verified below; its open interpretations are answered in §"The brief's open
> interpretations, answered". **Staffing (CLAUDE.md model policy, AMENDED 2026-07-11
> at the 9c gate sitting — supersedes this header's original cross-model
> prescription): coordinator Opus · implementer FABLE · cold reviewer FABLE** — the
> author enlarged the Fable allocation after the budget reset; the SAME-MODEL review
> flow applies (findings adjudicated implementer-vs-reviewer, the coordinator
> arbitrates against the spec, the implementer applies fixes).
> **The standing rider (author, 2026-07-07):** any change inside
> `Sources/VariorumCore/Sync/` is sync-engine surgery and is Fable work in every
> phase — satisfied trivially by this phase's assignment (prudence extension:
> `Sources/VariorumCore/Bridge/` treated the same). Phase 10 should need neither.

## Kickoff message (for a fresh session)

> You are starting **Phase 10 of Variorum** — readings & first views: the model's
> first multi-post traversals (continuous book view, folder, timeline, reading CRUD)
> plus the minimal pool and the 2026-07-09 library-affordance faces. **First, verify
> Phase 9c is fully closed** — the master plan's pointer says Phase 10 and the 9c
> closeout records the Step 6 gate results (the sitting: cutover probes, device
> rounds, the 9b real-Fragments pass). If the pointer still says 9c, STOP and
> report: the gates have not run, and this phase must not start over an un-cutover
> mirror. Read, in order: `CLAUDE.md` (note the model policy as amended 2026-07-11 —
> FABLE implements this phase under the same-model review flow; the cross-model flow
> does NOT apply here, and the Sync/ rider is satisfied by the assignment),
> `notes/plans/phase-10-brief.md`
> IN FULL (ratified decisions binding), this plan IN FULL,
> `notes/OverallModel.md` (P1–P3 are this phase's center of gravity),
> `notes/AppSpec.md` §4 + §12 + §14's Phase 4 ratification delta (the read
> semantics this phase renders: `"\n\n"` joins, blank takes skip, gaps, grouping,
> strict-stamp timelines, archived-out-of-ambient-view),
> `notes/TEXTKIT2_NOTES.md` (editor-adjacent phase — §2/§3 directly constrain the
> read-tier candidates), the Phase 7 editor files under
> `App/Variorum/Variorum/Features/Editor/` (the live-editor machinery you will
> migrate between posts — READ the flush/teardown/crystallization paths before
> designing focus handoff), `Sources/VariorumCore/Queries/` (every view is a
> traversal of these — the views re-decide NOTHING), and the three owned KnownIssues
> rows (echo detection O(post length); the "Show Blocks" tint mis-registration; paste
> spacing — QUESTIONS #12, ASK THE AUTHOR LIVE, never PROVISIONAL).
> **Baselines — do not re-run at session start:** the Phase 9c closeout's FINAL
> counts in `notes/plans/phase-09c-auth-alignment.md`: **core 549/62 · Mac app
> 254/45 · mobile 11/4** (core moved post-sitting on 2026-07-11 — the ask-13
> receipt consumption + its cold-review ladder; the contract's "Ask 13 CLOSED"
> addendum is the record). Remember the two 9d environment traps (piped
> xcodebuild masks exit codes; a live app instance or stale unsigned DerivedData
> product blocks the Mac test runner). The author is a DAILY USER from this phase
> on — she signed in at the 9c sitting and both devices sync under real auth; treat
> the real store and mirror as live production at all times (the A4 fence keeps dev
> work off them; never weaken it).

**Author input from the 9c Step 6 sitting (2026-07-11) — binding context for this
phase's view work:** her first bridge-landed journal entry appeared in the Mac
shell as an **untitled row in the flat library** — no date shown, no journal
grouping, "not part of the journaling book" (her words). The STORE was correct
(`profile='journal'`, `entry_date` set, body landed); what's missing is exactly
this phase's deliverable — the shell has no journal-shaped surface yet. Treat
"journal entries have an obvious dated home" as an author expectation the
timeline/library/readings work must visibly satisfy (dated rows at minimum; a
journal section/reading as the natural shape), and walk the section design with
her at the checkpoint — she explicitly asked whether the app's final sections
need more definition, so bring the proposal to her rather than leaving it
implicit.

**Goal:** every Phase-10 view renders from the store only, through the Phase 4
queries, with P3 held by construction (exactly ONE live editor, ever); the read
tier is provably cheap and correctly interactive (per-post select+copy, badges,
gaps); focus handoff never loses a keystroke or a tail; the library affordances
(tags, lifecycle, seal, entry date) get their faces; the pool's drag lands as
exactly the Phase 3 op; and the two 2026-07-09 defects are fixed — one traced
(tint), one designed live with the author (spacing).

---

## The brief's open interpretations, answered (ride the checkpoint ratify list)

1. **Badge interaction on unfocused posts: focus first** (the brief's leaning,
   adopted). Clicking a read-tier fan badge focuses the post (the one live editor
   migrates there), THEN opens the fan panel — one live surface, calm default,
   and the fan panel's actions (choose/branch/archive) already assume the focused
   editor's projection machinery. A read-only fan panel would be a second fan
   surface to maintain. PROVISIONAL; QUESTIONS entry at implementation.
2. **Timeline/folder item affordances: open-in-editor only** (leaning adopted).
   Previews are Phase 13 material; the timeline and folder are traversal proofs,
   not reading surfaces. PROVISIONAL; same entry.
3. **The minimal pool lives in the shell as a sidebar section** (below the
   library list; a separate window multiplies focus-handoff surface for zero
   Phase-10 value — drag-into-draft wants the pool and the draft VISIBLE
   TOGETHER, which the sidebar gives for free). PROVISIONAL; same entry.
4. **The echo-detection KnownIssues row is owned by Step 1, FIRST** — before any
   multi-post observation exists (the brief's own sequencing demand).

## Ground rules

- Views render state and send actions; **no business rules in view models, no
  re-decided semantics** — reading assembly, grouping, stamp sorts, archived
  visibility are Phase 4 ratifications the UI merely displays (review focus 3).
- Every observation bounded (`observeLibrary(limit:)` pattern); every benchmark
  ratio-asserted against a baseline, never eyeballed.
- The tint fix (Step 8) is TRACE-FIRST per the KnownIssues row: understand the
  fragment-geometry→block-range mapping error before writing the fix.
- QUESTIONS #12 (paste/newline spacing) is a **hard author gate**: present the
  mechanism options live (I4 whitespace-as-content vs render-time rule, and the
  broader newline-entry treatment), implement her answer. No PROVISIONAL.
- Tests run at the END of steps; the 9c closeout is the baseline.

## Steps

### Step 0 — The read-tier measurement (the brief's decision protocol; half-day box)
**Work:** the throwaway measurement the brief mandates — ~50 seeded posts (reuse
`CorpusFactory`) in the virtualized container; BOTH candidates: (a) SwiftUI
`Text`/`AttributedString` + `.textSelection(.enabled)`, (b) non-editable TK2
`NSTextView` per visible post. Measure: scroll cost, memory at a dozen visible
posts, cross-block per-post selection, badge anchoring, selection survival across
a projection refresh. **Decision rule (binding, from the brief):** (a) wins ONLY
if it delivers cross-block per-post selection AND badge anchoring; otherwise (b)
wins unless its per-view cost measurably breaks P3 at a dozen visible posts — in
which case STOP and bring the numbers to the author (ratified selection behavior
vs the P3 budget would be genuinely in tension; that is her call, not the
plan's). Record the decision memo + numbers in this plan's closeout.
**Tests:** none (throwaway; the memo is the artifact). Keep the harness in
`Spikes/` if it earns keeping.

### Step 1 — The echo-detection fix (KnownIssues row; EARLY by design)
**Files:** `App/Variorum/Variorum/Features/Editor/EditorViewModel.swift` (the
`surfaceMatches` path).
**Work:** the recorded fix direction: track last-flushed text per variant;
compare only candidate slots on clean projection arrival — O(edited slot), not
O(post). Must land BEFORE multi-post views multiply held observations.
**Tests:** red-on-old pin for the bug class (a projection echo on a long post
must not full-text-compare every slot — pin via a counting seam or a
size-proportionality assertion); the existing editor echo tests stay green.

### Step 2 — The read-cheap tier (the P3 workhorse)
**Files:** new `Features/ReadTier/` module (name per convention).
**Work:** per the Step 0 decision: a read-only post view rendering
`Queries.renderPost` projections with Phase 4 semantics (blank takes skip, gaps
render as gaps and never crash — SyncSpec §5), per-post select+copy (ratified),
fan badges on fanned blocks only (AppSpec §12), zero instantiation off-viewport.
If (b) won: deliberate `NSViewRepresentable` recycling (leaked text views are
the classic rot) and the fallback canary on every instance.
**Tests:** projection fidelity (fixture posts incl. fanned/blank/gap states);
badge presence exactly on fanned blocks; a cost assertion (per-post render flat
and trivial); selection-survival across a projection refresh (the Step 0
verified behavior, pinned).

### Step 3 — Focus handoff (ONE live editor, migrating)
**Files:** `Features/Editor/` + the new multi-post container.
**Work:** click-to-focus upgrades exactly one post to the live `NSTextView`;
focus-leave runs the Phase 7 teardown contract for that post (flush dirty
buffer, crystallize the open tail incl. idle-mint semantics, detach); attach to
the new post; scroll continuity content-anchored (never pixel offsets — the
Phase 6 reflow hazard). All serialized through the runner.
**Tests (the brief's three mid-states, integration):** switch focus
mid-dirty-buffer (the keystroke lands in the store, nothing lost), mid-open-tail
(the tail mints to the OLD post), mid-crystallization-flight (the in-flight mint
reconciles; no duplicate or dropped block). Plus: exactly-one-live-editor
asserted across a randomized focus walk.

### Step 4 — Continuous book view (virtualized)
**Files:** `Features/BookView/`.
**Work:** the reading's post list in one continuous scroll (each post scrolls as
part of the whole; NOT paginated — AppSpec §12), read-tier posts + the focus
handoff; assembly via `Queries.assembleReading` (curated + smart + grouping —
rendered, not re-decided); bounded observation window.
**Tests:** view-model assembly matches `assembleReading` exactly (grouping,
NULLs-last, extent, archived-out); virtualization benchmark ratio-asserted (cost
flat as reading size grows — Phase 4's discipline at the view layer); gap
tolerance.

### Step 5 — Folder view + tag management/application UI (brief items 3 + folder)
**Files:** `Features/Folder/`, `Features/Tags/`.
**Work:** folder view = the tag-subtree traversal over posts (Phase 4's
`everythingTagged`/subtree queries); tag management (create/rename/delete
hierarchical tags — `renameTag`'s subtree rewrite gets its face) + apply/remove
on posts. Block tagging may defer to 11's pool work — decide in-phase, record.
**Tests:** view models emit exactly the query results; tag ops through the UI
path emit exactly the Phase 2 ops (state-transition assertions); refusal copy
surfaces (duplicate path, invalid name).

### Step 6 — Timeline view + reading CRUD UI
**Files:** `Features/Timeline/`, `Features/Readings/`.
**Work:** timeline = the Phase 4 keyset-paginated queries (strict-stamp
semantics + the `library` total surface), open-in-editor affordance only;
reading CRUD — create/rename/delete curated + smart, the v1 `SmartQuerySpec`
vocabulary surfaced plainly, sort-field/dir pickers, curated membership
add/remove/reorder (fractional positions via the existing op).
**Tests:** pagination behavior (bounded, keyset-stable under inserts); CRUD
state transitions; a smart reading's UI-built spec round-trips through
`SmartQuerySpec` unchanged.

### Step 7 — The minimal pool (ratified scope: listing + drag-into-draft)
**Files:** `Features/Pool/` (sidebar section per interpretation 3).
**Work:** pool listing via `Queries.poolListing` (default-variant
representative); drag into the draft lands as EXACTLY `poolDragCopy` (lineage
edge `pool_copy`, `includeFan` available from day one — surface it as a
modifier or drop-menu, plan's call at build time); P stays in its pool.
**Tests:** the drag path emits exactly the Phase 3 op (row-level assertions:
fresh block, copied variant(s), edge, placement; commits never copied); review
focus 6's no-text-copy-outside-the-op check.

### Step 8 — Library-affordance faces + the tint fix (brief items 4–6)
**Files:** `Features/Library/` + `BlockTint` path in the editor.
**Work:** post lifecycle UI (archive/unarchive; delete + restore via
`restoreContainer` with `archivedPosts`/tray recovery surfaces); the seal
toggle (`lockPost`/`unlockPost` — the seal's refusals already speak, 9d);
Mac-side entry-date editing (`setEntryDate` — the 9b day-key guard already
enforces canon); **the tint registration fix** — trace the
fragment-geometry→block-range mapping in the `BlockTint` overlay first, record
the mechanism in the closeout, then fix; never-adjacent/stable-color rules
stand.
**Tests:** lifecycle ops through the UI emit the Phase 2 ops; sealed-post UI
state renders every refusal; entry-date editing round-trips the picker through
`JournalDay` validation; the tint fix gets a red-on-old pin at the mapping
layer (pure function — the mis-mapped geometry case).

### Step 9 — Paste/newline spacing (QUESTIONS #12 — the author-gate step)
**Work:** STOP-AND-ASK step, by her explicit instruction. Prepare the options
concretely first (a small demo of each): (a) inter-item whitespace as block
CONTENT (I4-clean; changes renderedText/export composition for pasted posts),
(b) a render-time rule (needs a stored home for variable separators — smells
like denormalization; must reconcile with the single-`"\n"` editor separator
and `"\n\n"` renderedText ratifications). The conversation is BROADER than
paste per her follow-up: cover newline ENTRY handling too. Implement her
answer; record the ruling as an AppSpec §14 delta at the checkpoint.
**Tests:** per the chosen mechanism — bulk-entry round-trips preserving
spacing; renderedText/export composition pinned to the ruling.

### Step 10 — Verification + closeout
**Work:** (i) full suites, three targets. (ii) The multi-post benchmarks
(ratio-asserted; the P1/P3 numbers in the closeout). (iii) The sync convergence
spot suite re-run under a multi-post editing session (editor-rate writes while
views observe — the Phase 7 Step 8 pattern at Phase 10 scale). (iv) The
TEXTKIT2_NOTES §5 ritual (canary silent; jump/height stable; selections at
boundaries). **Closeout ritual:** results + memo + dispositions in this plan;
master plan row + pointer → 11; KnownIssues reconciliation (echo row resolved;
tint row resolved; paste row resolved-or-re-owned per the ruling); the author
handoff; **the Phase 11 execution plan authored from
`notes/plans/phase-11-brief.md`** (the chain's next link — note 11's committed
cross-fan bracketing scope and its ask-her-live items, QUESTIONS #10/#11/#12
history).

## Explicitly out of scope
The fuller pool (block-tag filtering, pool-side structural ops — Phase 11);
side-by-side/diff/scrub/canvas/TOC and the whole §12 remainder (Phase 11);
`version_of` gestures (11); export/import (11); visual polish (13); any change
to sync/bridge engines (and if one seems needed — the rider: stop, report).

## Risks
- **A tortured view is information** (OverallModel §9) — surface model findings,
  never work around them quietly.
- **Focus handoff is where identity bugs would leak between posts** — the three
  mid-state tests are the fence; serialize through the runner.
- **P1/P3 regressions arrive silently with held observations** — bounded
  observations everywhere; benchmark deltas asserted against Phase 4's numbers.
- **The read tier multiplies the canary surface if (b) wins** — every instance
  armed; the §5 ritual closes the phase.
- **First cross-model phase:** the implementer must not touch `Sync/`/`Bridge/`
  (rider); disputes route back to the Fable reviewer for the final call; every
  finding still gets a written disposition here.

## Review foci (for the cold reviewer — from the brief, verbatim intent)
1. P3: exactly one live editor ever exists; unfocused posts provably cheap
   (measured, not asserted).
2. Focus handoff: dirty-buffer + open-tail correctness across switches (the
   three mid-state tests exist and pass).
3. Views contain no business rules; reading assembly matches Phase 4's ratified
   semantics exactly (grouping, NULLs-last, extent, archived-out).
4. The echo-detection KnownIssues row is resolved, not re-deferred.
5. Benchmarks ratio-asserted at multi-post scale; bounded observations
   everywhere.
6. Pool drag-copy through the UI emits exactly the Phase 3 op (lineage edge, no
   text copy outside the deliberate op).
7. The Step 0 decision memo's numbers support the shipped read-tier choice; the
   decision rule was followed, not rationalized after the fact.

## Closeout
*(Accumulating per step; finalized at phase end: results per step, test
counts, the QUESTIONS #12 ruling, PROVISIONALs, review dispositions under the
same-model flow, the Phase 11 plan authored, the handoff.)*

### Step 0 — the read-tier decision memo (2026-07-12)

**DECISION: candidate (b) — a non-editable TK2 `NSTextView` per visible
post, sized to content.** The brief's decision rule applied literally, not
rationalized: (a) fails to DELIVER its two required axes, and (b)'s measured
per-view cost is nowhere near breaking P3 at a dozen visible posts.

**The harness:** `Spikes/ReadTierSpike/` (throwaway, kept as this memo's
evidence; `swift run` from its directory). 50 corpus-shaped posts (the
CorpusFactory block shape: ~120 ASCII chars/block; 45 posts × 5 blocks + 5
posts × 50 blocks), materialization mirroring `EditorDocument` (single-`"\n"`
separator, block-ID attributes, body font), width 600. Run on macOS 26.4.1
(25E253), M3, debug build — numbers are upper bounds.

**Candidate (b) measurements:**
- Setup + full layout per view, 12 views (11 typical + 1 big): **median
  0.35 ms**, max 20.08 ms (the max is the FIRST view — one-time TK/font
  warm-up; the 50-block view itself costs **2.61 ms**).
- Memory: **Δ 1.7 MB for 12 live views**; Δ 6.2 MB at 62 live views
  (~100 KB/view).
- Projection refresh on the 50-block view: full `setAttributedString`
  2.65 ms; **differential one-block replace 0.27 ms**.
- Selection: cross-block per-post **true** (one view spans the post);
  **survives a differential refresh true** (NSTextView shifts it); a full
  re-set resets it (⇒ the shipped tier applies differential updates —
  Step 2's selection-survival pin rides this).
- Badge anchoring: fragment frame available for **every** block start
  (the editor's exact Phase 7 technique — one rendering brain).
- Scroll-through of 50 stacked views: median 0.04 ms/200 px step.

**Candidate (a) measurements + capability facts:** first layout of the
50-post LazyVStack ≈ 84 ms net; one-post refresh ≈ 10 ms net; Δ ≈ 10 MB
with window backing — all fine, and all beside the point, because the
decisive axes are API facts (Sonnet lookup, 2026-07-12, recorded here):
- **Cross-`Text` selection is documented-impossible** ("the selection is
  limited to within individual Text views" — Apple docs /
  nilcoalescing.com). One `Text` per post keeps per-post selection, but:
- **Badge anchoring inside one `Text` has no delivered mechanism.** The one
  lead is `Text.LayoutKey` (a PreferenceKey exposing line/run typographic
  bounds outside the draw callback) — third-party-documented only, with
  unverified coordinate-space semantics and no official Apple guidance; a
  run→block identity mapping would additionally need `TextAttribute`
  plumbing, creating a SECOND rendering brain beside `EditorDocument`.
  A speculative mechanism is not delivery under the rule.
- **No programmatic selection API on `Text`**; selection survival across a
  content refresh is unverifiable (and analogous documented APIs reset).
- macOS 26's `TextEditor` + `AttributedString` has no geometry API and no
  native read-only mode (`.constant` binding still shows cursor/keyboard).

**Rule application:** (a) wins ONLY if it delivers cross-block per-post
selection AND badge anchoring → badge anchoring not delivered → (b) wins
unless it measurably breaks P3 at a dozen visible posts → 0.35 ms median /
1.7 MB does not → **(b)**. The multiplied canary surface is accepted with
the plan's discipline: every read-tier instance arms `FallbackCanary`, and
deliberate `NSViewRepresentable` recycling is a Step 2 obligation.

**Known cost model accepted with (b), recorded honestly:** a read-tier view
sized to content inside an outer scroll lays out its WHOLE post when
instantiated (TK2 viewport layout follows the visible rect of the text
view, which is fully "visible" to its own geometry) — cost ∝ that post's
own size, never the corpus; LazyVStack instantiates near-viewport posts
only (P3's letter). A pathological 100k-word post inside a book view would
pay its own layout on entry — that is exactly AppSpec §4's within-post
virtualization escape-hatch territory (KnownIssues, owner 12), not this
phase's.

### Step 1 — echo detection is O(edited slot), zero surface reads (2026-07-12)

**Mechanism traced:** `EditorViewModel.surfaceMatches` extracted
`attributedSubstring` for EVERY slot on EVERY clean projection arrival
(main thread, autosave-debounce rate) — the KnownIssues row's cost.
**Fix (the row's recorded direction, sharpened):** a
`surfaceTextByVariant` map carries the text the surface is known to hold
per variant — written at every adoption point (`renderFull`,
`applyDifferential`, the differential-structural adopt, the echo-adopt
branch) and every edit record (`recordAutosave`, crystallization
corrections + applied mints) — so the echo check is a pure in-memory
comparison: **zero surface reads** (the remaining per-slot string equality
is allocation-free memcmp, and only differing slots reach it). Soundness
half: a same-length EXTERNAL change never matches the map (the map holds
OUR surface text), so it re-renders — pinned
(`aSameLengthExternalChangeIsNotMistakenForAnEcho`).
**Pin (red on old, verified by behavioral revert):**
`anEchoProjectionPerformsZeroSurfaceReads` — a 40-block echo performed
exactly 40 surface reads on the reverted old path (`surfaceTextReads`
counter), 0 on the fix. Mac suite after Step 1: **256/45 green** (was
254/45).

### Step 2 — the read-cheap tier (2026-07-12)

`Features/ReadTier/` per decision (b): `ReadPostViewModel` +
`ReadPostView`/`ReadPostTextView` — non-editable TK2 view sized to
content, the SAME `EditorDocument` materialization as the live editor (one
rendering brain). Phase 4 semantics displayed, never re-decided: blank
takes render as empty slots; gaps render as gaps, never crash (pinned).
Differential updates when the block sequence is unchanged — replaced units
== the changed slot's, never the document (cost seam pinned) — which is
what preserves an active selection (pinned; a sequence change re-renders
fully, selection reset accepted + recorded). Badges exactly on fanned
blocks, overlay views (never rendering attributes); every instance arms
`FallbackCanary`; dismantle disarms + clears sinks (deliberate recycling).
The read-tier contract as ratified, reconciled: a PLAIN click (no
selection created) requests focus with its UTF-16 offset; a drag-selection
stays a selection — select+copy and click-to-focus coexist.
`ReadTierTests` 7 green.

### Step 3 — focus handoff (2026-07-12)

ONE live editor, migrating. `EditorView(inline:)` — the same
EditorViewModel/EditorTextView/delegate machinery over a bare
content-sized surface (no own scroll view; height published after every
storage change); `attach(textView:scrollView:)` takes an optional scroll
view; viewport reads route through one `viewportBounds` helper (owned clip
bounds for the detail editor, `visibleRect` inline); per-editor scroll
anchoring/jumping stands down inline (the container owns scroll —
JumpPrimitive already no-ops on nil). Focus seeds (one-shot at first
render): the read-tier click's caret offset transfers directly (both tiers
render the SAME materialization); a badge tap seeds focus-then-fan
(interpretation 1). `teardown()` now returns its finalize task (awaitable
text safety). `FocusHandoffTests` 6 green: the brief's THREE mid-states —
mid-dirty-buffer (keystrokes land in the old post), mid-open-tail (the
tail mints to the OLD post; the new post untouched),
mid-crystallization-flight (the in-flight mint reconciles; exactly the
expected slots, no duplicate/dropped block) — plus the
exactly-one-live-editor randomized focus walk (12 switches / 3 posts;
every typed marker survives every handoff; the router always names the
one focused editor), seed application, seed clamping. The harness
switches focus exactly as the container does (teardown → fresh inline
attach). Mac 269/47 green.

### Step 4 — the continuous book view (2026-07-12)

`Features/BookView/`: one continuous scroll, NOT paginated; LazyVStack
virtualization over read-tier posts; the focused post swaps to the inline
editor (`BookFocusState` — one focused id, P3 by construction). Assembly
is `assembleReading` RENDERED VERBATIM (`BookViewModel.adopt` pinned —
grouping, NULLs-last, extent, archived-out are the query's calls); section
headers = pure presentation of `sectionPath` boundaries (the ratified
clustering-is-the-view's-call). **Core (additive; Phase 4 API
preserved):** `assembleReading`/`observeReading` gain a caller `limit`
window (the `observeLibrary` discipline for held fetches; effective cap =
min(maxPosts, limit), pinned; nil = Phase 4 behavior exactly);
`ReadingEntry` gains the public init (RenderedBlock precedent).
**Design note:** the read surface's observation starts from the surface
coordinator's lifecycle (makeNSView starts it, dismantle cancels — the
projection and the text view live and die together); this also makes
hosted tests drivable, since the test host never fires SwiftUI `.task`
appearance callbacks (verified by a minimal probe: representable
lifecycles fire, `.task` does not — production `.task`s are unaffected).
`BookViewTests` 5 green: verbatim adoption; section boundaries;
off-viewport posts NEVER instantiate (counted live surfaces, 60-post
reading, with content-delivery proof); realization ratio-asserted flat
(**14.2 ms @ 20 posts vs 13.1 ms @ 200**); a SyncSpec §5 gap slot inside a
member post renders without crashing. Core 550/62 · Mac 274/48 green.

### Step 5 — folder view + tags + the sectioned sidebar (2026-07-12)

`Features/Tags/` + `Features/Folder/`; core gains `Queries.allTags`,
`Queries.taggedPostItems` (**archived posts INCLUDED** — the Phase 4
ratification: tag lookups still find them; recorded reading, tombstoned
never; ordering is presentation), `Queries.postTags`, + observations
(`observeTags` unbounded on purpose — author-scale metadata, the
pool/tray precedent). TagsViewModel CRUD through the runner
(`renameTag`'s subtree rewrite gets its first face; duplicate-path and
invalid-name refusals SPEAK — pinned); TagAssignmentSheet: every toggle
exactly one apply/remove op (tombstone-not-removal pinned); FolderView:
the subtree traversal rendered verbatim, open-in-editor only
(interpretation 2 PROVISIONAL). **The shell grew its sectioned sidebar**
(`SidebarView` + `SidebarSelection` routing in RootView — cross-feature
routing in composition): **the JOURNAL section lands the binding
9c-sitting author input** — dated rows newest-first via the profile lens,
and "Today's Entry" = `createOrOpenJournalEntry`'s first Mac face (the
notebook rule pinned: create-then-open same id; malformed-day refusal
speaks). The fuller section design is the checkpoint walk with the author
(her explicit ask). **In-phase decision, recorded:** block tagging
DEFERRED to Phase 11's pool work (block tags primarily serve the pool —
AppSpec §7; the plan left it to the phase to decide).
`TagAndFolderTests` 6 green; core 553/62 · Mac 280/49 green.

### Step 6 — timeline + reading CRUD (2026-07-12)

`Features/Timeline/` + `Features/Readings/`; core gains
`Queries.readings` + `observeReadings` (additive). Timeline: the Phase 4
keyset pages under the RATIFIED strict-stamp semantics (an undated post is
NOT on the entry-date timeline — pinned) + the `library` total-surface
lens; keyset pagination pinned bounded and stable under inserts (no
duplicates; loaded rows never reshuffle); open-in-editor only. Readings:
create/rename/delete curated + smart; sort-field/dir menu; the v1
`SmartQuerySpec` vocabulary surfaced plainly (profile, date range, ANY-of
tags w/ subtree semantics) — a UI-built spec round-trips through
`SmartQuerySpec` UNCHANGED and the assembly applies it (pinned); curated
membership add/remove/reorder (up/down = one `reorderReadingPost` each
over the existing fractional-index op; boundary moves no-op; duplicate-add
refusal speaks). Sidebar gains Views (Timeline) + Readings sections;
reading → BookView (which loads its name), timeline → TimelineView.
`TimelineAndReadingsTests` 5 green; core 554/62 · Mac 285/50 green.

### Step 7 — the minimal pool (2026-07-12)

`Features/Pool/` (sidebar section — interpretation 3 PROVISIONAL). The
drag payload is the pool block's ID under a custom pasteboard type and
NOTHING else — the text copy happens inside `poolDragCopy`, the one
deliberate operation (review focus 6, pinned). The drop lands through the
EDITOR door on both surfaces: EditorTextView accepts the custom type
additively, maps the drop point to the nearer block boundary
(`insertPosition`, pinned per offset), **⌥ carries the whole fan** (the
plan's at-build-time `includeFan` call: a modifier), a sealed post refuses
visibly and consumes the drop. Row-level pins: fresh copy block +
`pool_copy` edge, commits never copied, fan-vs-rendered-take per the
modifier, P stays in its pool. **Build-time call, recorded:** opening the
pool shows it in the detail EDITOR — a pool is a container and
renders/edits like one (one traversal, zero new machinery; structural ops
are legal in pools — Phase 3), which is also how scraps get typed until
Phase 11's fuller pool. Core gains `Queries.pools` + `observePools`.
`PoolDragTests` 5 green; core 555/62 · Mac 290/51 green.

### Step 8 — lifecycle faces + THE TINT FIX (2026-07-12)

**The tint registration fix (KnownIssues row) — TRACE FIRST, mechanism
confirmed empirically before any fix:** a windowed diagnostic compared the
emitted tint spans against TK2 ground-truth fragment geometry — every span
missed its text by exactly **8.0 points**. TK2 fragment frames are
TEXT-CONTAINER-relative; the overlay views live in the TEXT VIEW, whose
container sits at `textContainerOrigin` (the 8 px inset) — the 9d tint
emitted container coordinates unconverted, so every stripe sat half a
16 px line ABOVE its text and block boundaries crossed lines mid-way:
exactly the author's "colors change where no block boundary is / every
line its own pastel". Fix at the ONE pure mapping (`BlockTint.viewRect`)
plus the view-y→container-y conversion in the windowing probes; the badge
overlays (editor AND read tier) carried the IDENTICAL unconverted offset
(invisible for floating buttons — fixed, same mechanism).
Never-adjacent/stable-color rules untouched. **Pins:** the pure mapping +
`everyStripeRegistersWithItsBlocksText` against real TK2 geometry in a
window — **red verified by behavioral revert** (all spans off by exactly
8.0 on the old path). *(Adjacent, recorded not fixed: `JumpPrimitive`
lands scroll targets on container-space minY — a constant ≈8 px residual
inside the spike's measured "within 6 px" tolerance band; deliberately
left alone this phase to keep the blast radius at the traced row.)*
**Lifecycle faces (brief items 4–5):** archive/unarchive + delete/restore
through LibraryViewModel (row-level pins) with the new **Archived &
Deleted** detail surface (`RecoveryView` — `archivedPosts` finally gets
the face the Phase 4 closeout promised; core gains `Queries.deletedPosts`
+ two observations, additive, pinned); the **seal toggle** in the
CommitBar (flushes the buffer first so `lockPost`'s quiet auto-commit
insures exactly what the surface shows — pinned: the text + ONE
kind='auto' commit; sealed typing refuses and speaks; unseal
round-trips); **Mac entry-date editing** (CommitBar popover DatePicker →
`setEntryDate`; the ops-boundary day-key guard pinned refusing malformed
keys; picker↔day conversion round-trips incl. leap day — and is
`nonisolated`, because an isolated View static traps off-main: the 9c
SignInFlow lesson, caught by this suite's own crash). Sidebar post rows
gain Archive/Delete. `LifecycleFacesTests` 5 + `TintRegistration` 3
green; core 556/62 · Mac 298/54 green.

### Step 9 — the QUESTIONS #12 author gate: OPTIONS PREPARED (2026-07-12)

**Stopped here by design** — no PROVISIONAL permitted; the options below
went to the coordinator for the author's live ruling. The demo suite
`Tests/VariorumCoreTests/Step9SpacingDemoTests.swift` (7 green) documents
today's behavior exactly and prototypes option (a) test-locally — it
ships NO behavior and is superseded by the real pins after the ruling.

**Today's exact behavior (demonstrated):** bulk entry splits on every
newline and trims — `"A\nB"` (no blank line) → two blocks, surface
faithful; `"A\n\nB"` and `"A\n\n\nB"` → the SAME two blocks — every blank
line vanishes from the surface. Export (`renderedText`) joins everything
with `"\n\n"`, so it NORMALIZES every boundary to one blank line: a k=2
paste round-trips by coincidence, k=1 GAINS a blank line, k=3 LOSES one.
Typing: Enter inside a block is content (I4 — blank lines typed inside a
block already persist); Enter at the document end opens the tail, and
crystallization consumes blank tail lines the same way bulk entry does —
so neither pasting NOR typing can put visible space between blocks today,
which is the "editor is so ugly" half of her follow-up.

**Option (a) — inter-piece whitespace becomes BLOCK CONTENT** (trailing
newlines on the preceding block; k newlines between pieces store k−1, the
editor's single-"\n" separator re-creates the last). Demonstrated: the
surface reproduces any paste byte-for-byte; unspaced text segments
identically to today (the mechanism only activates where spacing exists).
I4-clean, syncs for free, zero schema change, and the SAME k−1 rule
applied at crystallization makes TYPED blank lines between paragraphs
persist too — typing and pasting both become WYSIWYG, which answers the
broadened newline-ENTRY half in the same stroke. Companion export rule
(demonstrated): join with `"\n\n"` UNLESS the left block already ends in a
newline, then complete with `"\n"` — exactly the ratified merge-join
precedent ("a single space at the join unless either side's edge already
carries whitespace"); exports then reproduce the paste too, and
unspaced-block exports are byte-identical to today. Consequences to weigh,
plainly: block texts gain semantically-meaningful trailing newlines
(word counts unaffected; diffs/exports change only for spaced posts); the
Fragments bridge re-projects spaced journal days with their spacing
(arguably the point); the iOS trailing-blank-lines defect (KnownIssues,
owner 15) starts overlapping with MEANINGFUL trailing content — its fix
must then distinguish accidental accrual from stored spacing.

**Option (b) — a render-time rule with a stored separator width** (e.g. a
`separator_width` column on `container_block`). Blocks stay clean (no
trailing whitespace in `working_text`); but it is a SCHEMA CHANGE on a
synced table (migration + SyncSpec §12 lockstep + CAS/repair story — the
stop-and-report class this phase was told to expect none of), a second
home for what "\n" already expresses (the denormalization smell the brief
named), it must be threaded through renderedText/export/bridge separately,
and it covers ONLY block boundaries (intra-block blank lines are already
content — two mechanisms for one visual concept).

**Complement (c) — presentation-only paragraph spacing** (visual gap at
every block separator via paragraph styles; no data change). Makes the
editor look like a normal editor UNIFORMLY but preserves nothing (all
boundaries render alike, k is lost) — it cannot satisfy the decided
direction alone, and is listed because the broadened conversation ("how
newline entry is handled", "the editor is so ugly") may want it ON TOP of
(a) or (b) as the default look for UNSPACED boundaries, or explicitly
not at all (Phase 13 visual-polish territory).

**The implementer's recommendation (for the walk, not a decision):** (a),
with the merge-precedent export join and the same rule at
crystallization; (b) declined as a schema-and-sync cost for a second
representation of expressible content; (c) deferred to Phase 13 unless
she wants the uniform look now.

### Step 9 — THE RULING AND ITS IMPLEMENTATION (2026-07-12, asked live via the coordinator)

**The author ruled: option (a) exactly as demoed, PLUS the presentation
half added now.** Both consequences acknowledged by her (the bridge
re-projects spaced days with their spacing; the iOS trailing-blank-lines
defect must later distinguish accidental accrual from stored spacing —
noted for the Phase-15 KnownIssues row at the reconciliation pass).
Recorded as AppSpec §14's 2026-07-12 delta; QUESTIONS #12 marked ANSWERED.

**Half 1 — the mechanism, shipped:**
- `SegmentationRules.bulkSegments` (paragraph AND sentence modes): the
  newline run between pieces stores k−1 trailing newlines on the
  preceding piece; edge runs (leading/trailing of the entered text) drop
  as before; unspaced text segments identically to before (pinned:
  round-trip through the editor separator reproduces any paste
  byte-for-byte).
- `SegmentationRules.crystallizedBoundary` — the TIMING refinement the
  ruling's typed half required: a paragraph completes when the NEXT
  non-blank segment begins ("typed past" = the successor started), not at
  its own newline — until then the trailing run is still growing.
  Durability unchanged (idle-mint 2 s + teardown backstops); the
  planner's normalized region text is now byte-identical to the typed
  tail in the spaced cases, so mints need NO programmatic surface edit
  (the mint-time visual collapse is gone with the collapse itself).
- `Queries.joinRenderedTexts` — THE one join brain (the merge-join
  precedent's shape): `"\n\n"` unless the left block already ends in a
  newline, then a single completing `"\n"`. `renderedText` and **the
  bridge's per-day projection** both call it. **FLAG FOR THE REVIEWER —
  the one `Sources/VariorumCore/Bridge/` touch of the phase:**
  BridgeEngine's push sweep had an INLINE duplicate of the old join
  (compactMap/filter/`joined(separator: blockJoinSeparator)`); leaving it
  would have silently pushed a different body than the export and the
  landing half compare against. The edit swaps the duplicated expression
  for the canonical helper — no engine logic changes; the rider is
  satisfied by this phase's Fable assignment and the ruling explicitly
  acknowledged the bridge consequence. Corpus impact: unspaced days hash
  identically (zero re-pushes); spaced days re-push once when they first
  exist.
- Superseded tests updated with dated comments (three core segmentation
  tests, four planner/reconciler tests, two editor-session tests, one
  handoff expectation — each now pins the ruling's behavior); the Step 9
  demo suite deleted per its own header, superseded by the real pins:
  bulk round-trips (`bulkSpacingRoundTripsThroughTheEditorSeparator`),
  the k−1 crystallization case (`typedBlankLinesRideTheMintAsTrailingContent`,
  `typedBlankLinesBetweenParagraphsPersist` end-to-end through the real
  editor incl. renderedText), the paste half end-to-end
  (`pastedBlankLinesPersistOnSurfaceAndStore`), and the join
  (`renderedTextCompletesStoredSpacingInsteadOfStacking`,
  `joinRenderedTextsIsTheOneJoinBrain`).

**Half 2 — the presentation gap, shipped:** `EditorDocument.baseParagraphStyle`
(+ `baseAttributes`, ONE source applied at every surface write:
materialization, programmatic replaces, differential structural applies,
the read tier, and both text views' typing attributes). **The §12 trace,
as directed:** a gap applied only at block SEAMS would make every
boundary inferable at rest — violating §12's "boundaries invisible at
rest" — so the gap is per-PARAGRAPH, uniform across intra-block newlines
and block seams alike (no seam is distinguishable by style; pinned:
`theParagraphGapIsUniformPresentationStoredNowhere`). Judged a
spec-forced reading, not a product fork — §12 leaves exactly one option
standing — so NOT PROVISIONAL'd; recorded here and in the §14 delta.
Stored blank lines add on top (the "like any normal editor" behavior she
named). Geometry verified: the tint-registration and badge pins ride the
same fragment frames the gap changes, and both re-ran green with the
style live (the registration pin compares spans against the SAME frames,
so it holds by construction and by test). Size rides the font
(pointSize/2 ≈ 8 pt); the pretty version is Phase 13's. Mobile capture
(SwiftUI TextEditor) untouched — presentation is per-surface.

### Step 10 — verification (2026-07-12)

- **(i) Full suites, three targets: core `swift test` 562 green in 62
  suites · Mac app 302 green in 54 suites · mobile 11 green in 4 suites
  (iPhone 17 simulator).** These are the Phase 11 baselines.
- **(ii) Multi-post benchmarks, ratio-asserted:** book-view first
  realization 16.2 ms @ 20 posts vs 16.5 ms @ 200 posts (flat; asserted
  <5×+50 in `realizationCostStaysFlatAsTheReadingGrows`); off-viewport
  instantiation counted (< 30 live surfaces on a 60-post reading); the
  read tier's differential cost seam (one slot's units, never the
  document) and the Step 1 zero-surface-read echo pin both green. The
  Step 0 memo's numbers stand behind the shipped choice.
- **(iii) The sync convergence spot suite at Phase 10 scale:**
  `aMultiPostEditingSessionConvergesWhileViewsObserve` (new, core) — the
  Phase 7 Step 8 pattern over a book-view-shaped session: two clients,
  three posts in a curated reading, the focus-handoff write pattern
  (bursts hop posts) racing phone edits with engine rounds interleaved,
  a mid-session reorder + membership add, and the spacing ruling's
  trailing-newline content crossing the wire — byte-identical synced
  dumps, empty outboxes, assemblies equal, and the HELD observations
  (library + reading + post — what the Phase 10 views hold) delivered
  throughout and finished equal to the converged store. The original
  Phase 7 scenario also green unchanged.
- **(iv) The TEXTKIT2_NOTES §5 ritual (executable form, all green in the
  Mac suite):** (a) canary silent through every windowed session (editor
  smokes + every read-tier instance armed); (b) 10k-word jump/height
  stable (`tenThousandWordPostStaysSnappyAndAnchored` — pixel-exact jump,
  content-anchored reflow restore, keystrokes < 16.7 ms); (c) live
  decorations draw and update (the tint-registration window pin against
  real TK2 geometry, now WITH the paragraph gap live); (d) boundary
  selections resolve through the planner
  (`structuralGesturesOnTheTenThousandWordWindowedPost`). macOS 26.4.1 —
  same point release as the Phase 6 spike baseline; no macOS update
  occurred mid-phase, so no spike re-run owed.

**Step-10 counts: core 562/62 · Mac 302/54 · mobile 11/4** (baselines
were 549/62 · 254/45 · 11/4). *(Superseded by the post-ladder FINAL
counts at the end of the round-2 dispositions: core 562/62 · Mac 311/55 ·
mobile 11/4.)*

**PROVISIONALs (QUESTIONS #17, bundled):** badge-tap = focus-first;
timeline/folder = open-in-editor only; pool = sidebar section — plus the
recorded build-time calls (⌥ = includeFan; pool-opens-in-editor; the
Journal section + Today's Entry as the 9c binding input's minimal
satisfaction). **In-phase decisions recorded:** block tagging deferred to
Phase 11's pool work; the folder view shows archived posts (the Phase 4
tag-lookup ratification followed).

**Residuals recorded for the reviewer/author:** ~~the interrupted-gap
corner~~ (RETRACTED at review round 1 — the gap-drop was MAJOR 2, fixed:
the `.idle` mint + leading-run attachment make typed gaps durable the
moment they exist; see the round-1 dispositions); JumpPrimitive's
constant ≈8 px container-space scroll-target residual (the tint trace's
family, left untouched deliberately); the SwiftUI-`.task`-under-test-host
quirk (representable lifecycles fire, `.task` doesn't; production
unaffected — probe-verified); `EditorRateSyncTests`' new scenario holds
observations via GRDB directly (view-model-free by design — core cannot
see the app target).

**HELD per the coordinator (post-review-ladder ripples):** master plan
table/pointer; KnownIssues reconciliation (echo row resolved; tint row
resolved; paste row resolved per the ruling; the Phase-15 iOS row's
accidental-vs-meaningful note); the author handoff; the Phase 11 plan.

### Review round 1 — dispositions (2026-07-12; ALL findings AGREED, all fixed; the round-2 anchor)

**MAJOR 1 (toggleSeal loses the open tail) — AGREED, fixed, red-verified.**
Mechanism self-traced: the sealing branch ran flush-only; an open tail at
seal time became surface-only and permanently unmintable (every later
mint path hits the locked-container refusal). The Phase 7 "surface-only
at quit" ratification presumed a seal arriving from ELSEWHERE
("seconds-wide-rare"); a same-surface Seal button broke that premise, and
the lock doctrine everywhere else is "the guard insures exactly what it
protects." **Fix:** the sealing branch runs the FULL teardown contract —
`await finalizeWork()?.value` (flush → await mint flight → mint the
residual tail) + a final `flushNow` for finishMint's corrections — before
`lockPost`. **Pin `sealingMintsTheOpenTailBeforeTheFreeze`, RED verified
by behavioral revert** (the reverted code sealed with the tail text
nowhere in the store: `texts == ["alpha"]`).

**MAJOR 2 (the idle/teardown mint collapses the typed pending gap; the
recorded recovery was false) — AGREED, fixed, red-verified.** Mechanism
self-traced end to end, including the reviewer's recovery falsification
(Enter at the last block's end routes to the `.openTail` verdict — a
separator, never content — so the collapsed gap could not be re-typed;
the "interrupted-gap corner" residual was wrong on frequency AND
recovery, and is retracted). The spec side was already decided (the §14
delta), so the fix ships: **(1) the `.idle` mint kind**
(CrystallizationPlanner; used by `idleMintTail` and `finalizeWork`) —
like bulk, but a trailing typed newline RUN survives: the pieces mint and
the run minus one separator stays as the still-open tail, making the mint
region byte-identical (no visible collapse, ever); **(2) the leading-run
attachment** (`attachLeadingTailRunIfNeeded` + BlockRangeIndex.
`transferTailPrefixToLastEntry`) — a tail that STARTS with newlines sits
after a preceding block, and under the ruling those newlines are that
block's trailing CONTENT (the k−1 rule; the separator is the +1): the
block's range grows over the run (surface bytes unchanged; the block-ID
attribute extends; the store follows through an ordinary autosave read
from the Step-1 surface-text map, so it works even view-less at
teardown). Composition: the idle mint parks the run; the attachment
(fired from `crystallizeIfNeeded`, incl. finishMint's trailing pass)
immediately folds it into content — so a typed gap is durable THE MOMENT
IT EXISTS, successor or not (the "like any normal editor" behavior the
author named; typed trailing newlines now persist even at post end, and
Fragments' own trim covers the bridge's cosmetic side). Reopened-tail
Enters attach eagerly one by one — same rule, same result as typing
straight through. **Pins, RED verified by behavioral revert** (kinds
reverted to `.bulk` + attachment no-op'd):
`aPauseAfterTypedBlankLinesNeverCollapsesThem` (the dominant rhythm —
paragraph, ⏎⏎, think >2 s, next paragraph — store `["A\n","B"]`, surface
`"A\n\nB"`; the revert showed the collapse exactly),
`entersAfterAMintedBlockPersistAsItsTrailingContent`, and the planner pin
`idlePlansKeepThePendingTrailingRunOpen`. Recorded reading rider: a
tail-leading run attaches regardless of HOW the newlines arrived (typed
or pasted into the tail) — one rule, surface-faithful; the pure
`bulkSegments` edge-drop still governs the entered text's own edges.
Junk edge (trailing SPACES inside a blank line at idle time) still
collapses — pure-newline runs are the preserved class, recorded.

**MINOR 3 (unbounded held observations) — AGREED, fixed (architectural;
mechanism traced, no pin owed).** The folder listing is corpus-shaped
(one broad tag approaches the library) and its standing fetch re-runs at
container-write rate; archives/tombstones accumulate forever under S2 —
exactly the class Phase 4 bounded `observeLibrary` for.
`taggedPostItems`/`archivedPosts`/`deletedPosts` gain optional `limit`s
(one-shot callers unchanged); the three OBSERVATIONS take a REQUIRED
`limit` (the library discipline); FolderView passes 200 (the library's
bound), RecoveryView 500 each.

**MINOR 4 (detach keeps `loaded`/`slots` — remade surface permanently
blank) — AGREED, fixed, red-verified.** Traced: the remade text view's
EMPTY storage is never written because the differential compares the
incoming projection against the stale in-memory `slots` (equal ⇒ no
replacement; the out-of-bounds heal lives inside the changed-slot loop).
Fix: `detach()` resets `loaded`/`slots`/`index`, so the next attach
renders fully. **Pin `aDetachReattachCycleRendersTheFreshSurface`, RED
verified** (`fresh.string == ""` on the revert).

**MINOR 5 (inline overlays never refresh on container scroll) — AGREED,
fixed, red-verified.** Traced: the inline coordinator observes only
storage edits; `visibleRect`-pruned badge/tint spans go stale as the book
view scrolls (nothing re-fires the overlays). Fix REMOVES the staleness
class instead of racing it: the inline editor's `viewportBounds` is the
whole surface (`textView.bounds`) — overlay work bounded by the focused
post (the accepted inline cost model: the surface is laid out to content
already, fans are rare, tint is an explicit mode), no observers on
SwiftUI's internal clip view. The detail editor keeps its scroll-driven
pruning unchanged. **Pin
`inlineBadgesCoverTheWholePostNotJustTheClippedViewport` (a real clipped
window; the fanned block outside the visible slice), RED verified**
(badges `[]` on the revert).

**MINOR 6 (per-keystroke `ensureLayout(documentRange)` — asserted, not
measured) — AGREED; MEASURED, assertion vindicated and now pinned.** New
`InlineEditorWindowTests.inlineHeightMaintenanceStaysInsideTheFrameBudgetAtTenThousandWords`
through the REAL coordinator (`InlineEditorSurface` made internal for
it): **warm remeasure 0.043 ms; keystroke + remeasure 2.8 ms** at 10k
words (debug build) — TK2's warm validation walk is trivially cheap; the
Phase 6 105 ms figure was the COLD pass. Both asserted < 16.7 ms
(frame-budget bound, the smoke-test pattern); numbers print for the
record. No height-maintenance redesign needed.

**NIT 7 (↑/↓ on non-manual readings) — AGREED, fixed:** the reorder
buttons render only under Manual order; other sorts show a caption naming
why (reorder writes `position`, which a stamp-sorted assembly doesn't
display — a silent visual no-op otherwise).

**NIT 8 (readingName scans the listing; stale on rename) — AGREED,
fixed:** new one-liner `Queries.reading(_:id:)` (tolerant by-key fetch);
BookViewModel uses it. The rename-while-open staleness stays (one-shot;
cosmetic at author scale — recorded).

**NIT 9 (silent 300-entry truncation of the journaling book) — AGREED,
fixed:** `BookViewModel.truncated` + a visible marker row ("Showing the
first 300 posts — the rest of this reading isn't loaded yet; windowing
arrives with Phase 12"). Never a silent cut on the dated home's surface.

**NIT 10 (joinRenderedTexts doc overclaims k=1) — AGREED, fixed:** the
doc now says k ≥ 2, and states the single-newline paste exports through
the ratified default `"\n\n"` join.

**Post-round counts: core 562/62 · Mac 309/55 · mobile 11/4 — all
green** (Mac +7: the two MAJOR pins, the planner pin, the detach pin, the
two inline window tests, and the eager-attachment pin).

### Review round 2 — dispositions (2026-07-12; ZERO new BLOCKER/MAJOR — the ladder CLOSES; all findings AGREED)

**MINOR (the quit door strands the leading-run attachment's record) —
AGREED, fixed, RED-ON-CURRENT verified.** Mechanism confirmed by my own
trace and by the pin failing BEFORE the fix: `finalizeWork`'s `.idle`
mint parks the run, `finishMint`'s trailing pass attaches it — into the
autosave coordinator's 500 ms DEBOUNCE — and the task returns; the app
delegate replies `terminateNow` right after `await task.value`, so the
record dies with the process and the typed gap collapses on relaunch
(exposure: a gap typed < ~2 s before ⌘Q; payload spacing bytes, never
prose). The `toggleSeal` asymmetry was the tell — it got the trailing
flush belt, the quit door didn't. **Fix:** `finalizeWork`'s task ends
with `await self.autosave.flushNow()` after `finishMint` (toggleSeal's
second flush is now a redundant belt, not load-bearing). **Pin
`quitTimeFinalizeLandsTheAttachedGapBeforeReturning`, verified red on
the PRE-fix code** (store read `["alpha","A"]` — the gap stranded).

**NIT (truncation marker false-positives at exactly the window) —
AGREED, fixed:** the book view observes `entryWindow + 1` as a probe;
`adopt` consumes the probe row into `truncated` and renders exactly the
window — a reading of exactly 300 posts shows no marker (pinned:
`theTruncationMarkerNeverFalsePositivesAtExactlyTheWindow`).

**NIT (silent-cut parity: folder + recovery) — AGREED, fixed:** the same
probe-and-marker treatment — FolderView (window 200, "most recently
touched posts with this tag") and RecoveryView (window 500, per-section
markers). No listing in the phase cuts silently now.

**NIT (`bulkSegments` doc overclaims exact reproduction) — AGREED, doc
fixed:** the API doc now states the preserved class precisely — pure-
newline runs; a blank line carrying stray horizontal whitespace
normalizes (`"A\n \nB"` renders back `"A\n\nB"`), matching what the
closeout already recorded.

**NIT (typed gap after a LOCKED last block collapses at idle) — AGREED,
recorded (record-not-fix, as the reviewer framed):** the attachment
guard skips a non-editable last entry deliberately — writing the run
into a locked variant would violate the lock, so the run has no legal
home and the `.idle` mint's edge-drop collapses it visibly. The only
lock-respecting outcome; recorded HERE beside the trailing-spaces junk
edge as the second boundary of the preserved class.

**NIT (`toggleSeal` vs `finishMint`'s compensating deletions — an
unordered race on the serial runner) — AGREED, recorded (the reviewer's
own framing: an observation, not a fix demand; not deterministically
pinnable without a runner-ordering seam):** if an edit lands mid-seal-
flight, a compensating `deleteBlock` can reach the runner after
`lockPost` and refuse under the seal — superseded minted content stays
frozen with a visible error; unseal recovers; nothing is lost. ms-window,
edit-during-await class (the Phase 9b round-3 residual family).

**FINAL counts after round 2: core 562/62 · Mac 311/55 · mobile 11/4 —
all green** (Mac +2: the quit-door pin, the truncation-probe pin). These
are the Phase 11 baselines.

### Checkpoint ratification round (2026-07-12, the author via the coordinator)

**QUESTIONS #17 RATIFIED IN FULL AS SHIPPED** — the three PROVISIONAL
interpretations (badge focus-first-then-fan; timeline/folder
open-in-editor only; pool as a sidebar section) AND the recorded
build-time calls (⌥-drag carries the fan; the pool opens in the ordinary
editor; the Journal section / "Today's Entry" dated-home shape). Recorded
as AppSpec §14's Phase 10 checkpoint delta; #17 marked ANSWERED.
**The offline-label row's re-owning to Phase 11 Step A0: APPROVED by the
author** (noted on the KnownIssues row — the Phase 11 session inherits it
settled). Remaining with the author, no doc changes owed: the
app-sections/journal-home design conversation, the install relaunch, and
the spacing-ruling shakedown (the handoff checklist carries all three).
**THE PHASE IS CLOSED.**
