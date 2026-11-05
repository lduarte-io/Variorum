# VX-683 — the design memo (D-683, for her sitting; no build)

**STATUS: RULED — the sitting ran 2026-11-04 (MST evening, the handoff-walkthrough session; R-683-1…4 below). READY TO KICK OFF as the bundled run. Her word 2026-11-04: VX-683 runs BUNDLED with VX-544 under one umbrella run after this memo's sitting —
VX-683 first, one branch, one sync-custody slot, Fable reviewing.**

## The mechanism (statically traced at VX-677 batch 1; the ticket's trace, re-verified against SyncSpec)

Her typing sits in the editor's autosave DEBOUNCE window — in the live `NSTextView`'s buffer, not yet written
through `Operations.autosave`. So the variant row is **not dirty** (nothing in `sync_outbox`). A pull that
arrives in that window applies the server's `working_text` on the **locally-clean path** (SyncSpec §5: clean →
write it + its `sync_version`) — correctly, by its own lights. Moments later her debounced autosave fires and
writes her buffer — which was built on the OLD text — over the freshly-applied row. **The remote words survive
nowhere**: S5's conflict-as-variant never ran because the row was clean at apply, and no later CAS reject fires
because the autosave's push carries the applied row's own `sync_version` (the pull wrote it), so the server
ACCEPTS the overwrite. Pre-existing on every surface including Write; distinct from VX-664 (the no-pending case —
a pane adopting an outside change — covered since VX-677; the MCP roads are covered by flush-first + the bracket
savepoints).

## The options

**(A) Flush-first before the apply** — the MCP door's own precedent ("the author's pending typing lands before
any wire act"), on the sync road: the round's apply is preceded by a MainActor hook that flushes every live
editor's pending buffer through `Operations.autosave`. VX-544's ruled design ALREADY adds the exact seam —
`SyncSession.triggerSync()`/`flush()` gain an optional `beforeRound: (@MainActor () async -> Void)?` the Mac
composition wires (D-544 build step 3a) — so A rides a hook the bundled run builds anyway, one more occasion.
After the flush the row IS dirty, and the EXISTING §5/§6 machinery does the rest: server text wins the row, her
flushed text becomes the conflict take, the pane adopts. Zero new merge semantics, zero engine knowledge of
editors (the hook is injected at composition — nil = inert, the `keyProvider`/`SampleLibraryDedupeFacts` pattern).
**Residual:** keystrokes landing between the flush and the apply transaction re-open the same hole for a
milliseconds-wide window — narrowed ~1000×, not closed.

**(B) The guarded autosave** — the general rule, and the half that CLOSES the hole: **an autosave never
overwrites words it has not seen.** `Operations.autosave` gains the expected-text precondition the gesture
operations already use (`bufferChangedSinceGesture`; the view model carries the text it last loaded or wrote —
it already holds projections, never copies of persisted truth, so the expected text is the editor seam's own
last-adopted snapshot). A stale autosave — the row changed under it (a sync apply, the MCP door, a second
window) — does not blind-write. It RESCUES: the row's current text (the words about to be overwritten) is
preserved, and both texts survive. S5's spirit at the autosave layer; also covers the MCP mid-window race and
any future outside writer, not only sync.

**(C) = A + B** — A gives the common case clean UX through the standing conflict-take road (her flushed text
becomes an ordinary conflict card at apply time, labeled as every S5 card is); B is the belt that makes the
class impossible whatever the timing. Recommended.

**(D) An engine-side pending-buffer facts seam** (the apply consults live editor state per row and mints the
conflict itself) — REJECTED: editor semantics leak into `Sync/` (OverallModel §9's smell); the apply would need
per-row MainActor hops inside its one transaction (P2 violation risk); A+B reach the same end through standing
seams.

**(E) Park the arriving row until the flush** — REJECTED: breaks the apply's one-transaction / stage-emptying
design (VX-494: the apply runs to its end once begun and empties the stage with the cursor); partial-apply
cursor machinery is the chunking memo's whole cost, bought here for one row class.

## The rescue's direction (the one real product call — HER QUESTION 1)

When a stale autosave fires, which text keeps the row?

- **(i) Her buffer keeps the row; the displaced words become the conflict take** — RECOMMENDED. She is at the
  keyboard mid-thought; yanking the text out from under her caret is hostile (the fix would CAUSE the jolt it
  exists to prevent). The displaced server words land as an ordinary take on the same block, label `'conflict'`,
  parent = the same parent, at the fan's end — exactly where an S5 card lands, so the fan face, the corner badge
  and the card's affordances all come for free. Convergence: her row pushes (CAS-accepted — base is the applied
  version), the new take pushes; every device ends with both texts. Deterministic because it is a LOCAL rescue,
  not a cross-device repair — no §7 entry needed.
- **(ii) The applied words keep the row; her buffer becomes the take; the editor adopts** — S5's letter
  (server-wins-the-row), but mid-typing adoption REPLACES the words under her caret: the exact Apple-Notes-class
  jolt the app bans. Only right when she is NOT actively typing — which is the no-pending case VX-664 already
  covers.

Note A and B compose: with A in place, the apply-time path is (ii)-shaped through the standing S5 road (her
FLUSHED text becomes the card — she then keeps typing into a buffer whose base is now stale, and B's rescue
fires (i)-shaped on the next autosave only for the millisecond stragglers. Both texts always survive; which one
is "the row" differs only in that sliver.

## What this deliberately does not do

- No new schema, no wire change, no §7 repair, no marker event (everything is client-local; the pushes are
  ordinary rows).
- No savepoint insurance occasion: nothing becomes unreachable (both texts live as takes; the insurance class
  guards roads where a buffer loses its ⌘Z road — not this).
- I4/I1 untouched; S5 untouched on the engine path; the one mutable field stays the one mutable field.

## Evidence (the acceptance units' shape, for the bundled run's plan)

- **B's pin, red-on-old:** a state-transition test — `autosave` with a stale expected text on a row a fake
  apply just rewrote: old behavior overwrites (red), new behavior rescues both texts (green); revert-proven.
- **A's pin:** the two-client fake-server harness drives a pull INTO a simulated debounce window (the hook seam
  lets the test inject "pending buffer exists"): the round ends with the server text on the row, her text as a
  conflict take, outbox pushing both — the convergence suite's standing shape (a sync change without a
  convergence test is unreviewed, AppSpec §15.3).
- **The live look:** one real two-Mac round with typing in flight (her eyes; the VX-500 live-face precedent —
  can ride the same held window).

## HER RULINGS (the sitting, 2026-11-04 MST evening — each presented with full context, her picks verbatim)

- **R-683-1 — the rescue's direction is (i):** her live buffer keeps the row; the displaced words land as the
  take ("(i) My buffer keeps the row"). Nothing ever moves under her caret; both texts survive and converge.
- **R-683-2 — the rescued take wears `'conflict'`:** one vocabulary, one face — every both-versions-survived
  card looks the same ("Reuse 'conflict'"). Settled after the concrete retelling (two writers racing on one
  take; a deliberate act of hers never mints this card).
- **R-683-3 — the flush fires only when typing is pending:** one cheap check; quiet rounds stay strictly
  zero-cost on the main thread ("Only when typing is pending").
- **R-683-4 — VX-664's remaining half folds into this run:** the pane's face right after a rescue is walked and
  polished while the machinery is open; VX-664 closes with the run ("Fold it into the run").

## The bundle (her word 2026-11-04)

One umbrella run: VX-683 (this memo, after her sitting) then VX-544 (plan ready at
`notes/plans/fixes/vx-544-offline-typed-unlock.md`; its D-544 build step 3a mints the same `beforeRound` hook A
rides). One branch, one worktree, the one sync-custody slot, Fable reviews (Sync/ class); the cast at kickoff is
her call.
