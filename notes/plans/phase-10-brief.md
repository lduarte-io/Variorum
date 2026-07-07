# Phase 10 — Readings & first views — DESIGN BRIEF

> **This is a BRIEF, not the execution plan.** Written 2026-07-06 in the author's
> forward-planning session (Fable) to carry design judgment forward under the token-budget
> plan (see CLAUDE.md's model-policy amendment). The just-in-time execution plan is still
> written at **Phase 9's closeout** and MUST incorporate this brief: its pre-answered
> decisions are author-ratified (not reopenable by a session), its leanings are starting
> points to verify against the then-current code, and its open interpretations are the
> questions that plan must answer (or PROVISIONAL per the standard rule).

## Scope (one line + the one change)

Reading CRUD (curated + smart), continuous book view (virtualized), folder view, timeline
view — functional, unstyled — **plus a minimal pool** (author decision 2026-07-06: pulled
forward from Phase 11 because she is a daily user by now; scope = pool listing +
drag-into-draft via `poolDragCopy`; the fuller pool experience — block-tag filtering,
pool-side structural ops surface — stays in 11).

## Author-ratified decisions this phase implements (2026-07-06 — not reopenable)

1. **Minimal pool ships here** (scope above). The op (`poolDragCopy`, `includeFan` from day
   one) and the query (`poolListing`) exist since Phases 3–4 — this is wiring, not building.
2. **The read tier allows select + copy** (scoped to one post at a time), and clicking into
   an unfocused post upgrades exactly it to the live editor. Read-only never means inert.

## The phase's center of gravity

**P3 stops being satisfied for free.** Phase 7's "one live NSTextView per focused post" was
confirmed with the note that the per-block/per-post read-only tier "becomes load-bearing at
Phase 10's multi-post views" — this is that phase. Two hard sub-problems:

- **The read-cheap tier.** Unfocused posts render as lightweight read-only text from
  `Queries.renderPost` projections. Requirements: per-post selection (ratified above), fan
  badges on fanned blocks (AppSpec §12 — badges are not an editor-only affordance), cost per
  unfocused post trivial and flat, gap tolerance (SyncSpec §5).
- **Focus handoff.** ONE live editor migrates between posts: flush the dirty buffer +
  crystallize the tail on focus-leave (Phase 7's teardown rules apply per post), attach to
  the newly focused post, preserve scroll continuity (content-anchored, `ScrollAnchorController`
  patterns — never pixel offsets).

## The read-tier technology — framing memo (decide by measurement at the phase, never by coin-flip)

Two candidates; the tension between them is real and the plan must resolve it with numbers:

- **(a) SwiftUI `Text`/`AttributedString` + `.textSelection(.enabled)`.**
  *For:* cheapest to build; no TK object lifecycle; virtualizes naturally inside Lazy
  containers; zero fallback-canary surface. *Against — the structural tension:* one `Text`
  per **post** gives the ratified per-post selection but SwiftUI exposes no per-fragment
  geometry, so **fan badges have nowhere to anchor**; one `Text` per **block** gives natural
  badge anchoring but scopes selection to a block — which fails the ratified
  "select + copy per post" the moment a selection wants to cross a block. Also verify on
  current Tahoe: selection survival across projection-driven view updates (a refresh
  mid-selection must not silently drop it).
- **(b) Non-editable TK2 `NSTextView`** (`isEditable = false`, `isSelectable = true`) per
  *visible* post. *For:* true cross-block per-post selection; real fragment geometry for
  badge overlays (Phase 7's exact badge technique reuses); the same `EditorDocument`
  attributed-string pipeline as the editor (one rendering brain, not two). *Against:* one
  TK2 stack per visible post (setup + memory — measure at a dozen visible posts); the canary
  surface multiplies; `NSViewRepresentable` recycling inside a virtualized list must be
  deliberate (leaked text views are the classic rot).

**Decision protocol for the plan:** build the half-day measurement — ~50 seeded posts in the
virtualized container, both candidates: scroll cost, memory, cross-block selection behavior,
badge anchoring, selection survival across a projection refresh. **Decision rule:** (a) wins
only if it can deliver cross-block per-post selection AND badge anchoring (its known weak
axes); otherwise (b) wins unless its per-view cost measurably breaks P3 at a dozen visible
posts — in which case bring the finding to the author, because the ratified selection
behavior and the P3 budget would be genuinely in tension. Either way: gaps and blank takes
render per Phase 4 semantics, and the tier never instantiates for off-viewport posts.

## Leanings (verify against current code; not ratified)
- **Virtualization:** SwiftUI `LazyVStack`/`List` with bounded observations (the Phase 4
  `observeLibrary(limit:)` pattern extended) before any hand-rolled windowing. Benchmarks
  must be ratio-asserted like Phase 4's (cost flat as post count grows), not eyeballed.
- **Reading CRUD scope:** minimal — create/rename/delete curated + smart readings, the
  existing `SmartQuerySpec` vocabulary surfaced plainly, sort-field/dir pickers, curated
  membership add/remove/reorder. The assembly/grouping semantics are all Phase 4 ratifications;
  the UI renders them, it re-decides nothing.

## Open interpretations the execution plan must answer

1. **Badge interaction on unfocused posts:** does clicking a read-tier badge focus the post
   first, or open the fan panel in a read-only mode? (Leaning: focus first — one live surface,
   calm default.)
2. **Timeline/folder item affordances:** open-in-editor only, or inline preview? (Leaning:
   open only; previews are Phase 13 material.)
3. **Where the minimal pool lives in the shell** (sidebar section vs separate window).
4. **KnownIssues row owned here — "Editor echo detection is O(post length)":** the fix
   direction is recorded in the row (track last-flushed text per variant, compare candidate
   slots only); multi-post observation multiplies the cost, so it must land in this phase,
   early, before the book view multiplies held observations.

## Risks

- **A tortured view is information** (OverallModel §9): if the book view or timeline needs a
  bespoke subsystem instead of a traversal, surface it as a model finding — do not work
  around it quietly.
- **Focus handoff is where identity bugs would leak between posts** — the flush/teardown-
  then-attach sequence must be serialized through the runner and covered by an integration
  test that switches focus mid-dirty-buffer, mid-open-tail, and mid-crystallization-flight.
- **P1/P3 regressions arrive silently with held observations** — every observation bounded;
  benchmark deltas asserted against Phase 4's numbers.

## Review foci (for the cold reviewer; written at brief time, no implementation context)

1. P3: exactly one live editor ever exists; unfocused posts are provably cheap (measured,
   not asserted).
2. Focus handoff: dirty-buffer + open-tail correctness across switches (the three mid-state
   tests above exist and pass).
3. Views contain no business rules; reading assembly matches Phase 4's ratified semantics
   exactly (grouping, NULLs-last, extent, archived-out-of-ambient-view).
4. The echo-detection KnownIssues row is resolved, not re-deferred.
5. Benchmarks are ratio-asserted at multi-post scale; bounded observations everywhere.
6. Pool drag-copy through the UI emits exactly the Phase 3 op (lineage edge, no text copy
   outside the deliberate op).

## Test-matrix skeleton

Read-tier rendering (projection fidelity, badges, gaps, blank takes) · focus-handoff
integration (the three mid-states) · virtualization benchmarks (flat in post count) ·
reading CRUD state transitions · pool listing + drag-copy path · sync convergence spot suite
re-run under a multi-post editing session · TEXTKIT2_NOTES §5 checks (unchanged ritual).
