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
