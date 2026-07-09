# Phase 9 handoff — Structural gestures in the editor (closed 2026-07-07)

Self-contained checkpoint for the author. Everything a fresh session needs to answer your
questions about this phase is in this file plus the pointers at the bottom — the build
sessions are cold; never wake them.

---

## Your checklist (in this order)

> **2026-07-09 update:** your first hands-on session happened before the formal feel pass
> and changed this list. It found two gaps (no door to a block's first branch; refusals
> silent behind disabled doors) → **Phase 9d** (editor visibility & QoL, runs before 9b)
> fixes them, plus your batched decisions — all recorded in AppSpec §14's 2026-07-09 delta,
> QUESTIONS #10/#11, the Phase 10/11 briefs, and the master plan. **Item 1 below now runs
> AFTER 9d lands** (the fan door, visible refusals, and the Show Blocks tint are
> prerequisites for a meaningful pass). **Item 2 is ANSWERED** (see its update). Daily use
> waits until 9d + 9b + 9c are all done (your call, same session).

1. **The COMBINED manual feel pass — one sitting (your 2026-07-07 bundling call).** Open a
   real post (10k words is the proven scale) and walk BOTH lists:
   - *Phase 7 §5 items (still pending from that phase):* the canary stays silent through a
     real typing/scrolling session (no red banner); scroll and height feel stable on a long
     post; typing feel at start/middle/end.
   - *Phase 9 items:* the snap feel — put the caret mid-sentence, ⌘⇧D, and watch the cut
     visibly snap to the boundary before the divide lands; select sloppily and ⌘⇧E
     (Extract), ⌘⇧K (Make Block from a middle span), ⌘⇧M (Merge at a seam); the W ceremony
     — divide a block that has takes (the sheet: checklist, pre-placed cuts, cancel is
     inert); refusal copy (try a cross-block selection → the message names the
     divide-then-merge workaround); and the differential rewrite feel — divides/merges on a
     long post should feel instant with NO scroll jump (untouched text never moves).
   Record the result in `notes/plans/phase-09-structural-gestures.md` (the closeout's
   pending line) — a fresh session can do the recording if you dictate notes.

2. **One call: the messy cross-fan re-bracketing case.** The ratified v1 line shipped
   exactly: a selection crossing block boundaries refuses, naming the workaround. The old
   KnownIssues row said the messy case (splitting multiple touched, possibly fanned blocks
   and reconciling) gets re-owned "only if daily use demands it." Your call at this
   checkpoint: leave it dead (recommended until real use complains), or name an owning
   phase to re-add it.
   **→ ANSWERED 2026-07-09: re-owned at Phase 11, not dead.** Your first re-bracketing
   attempt met the "daily use demands it" condition immediately. The shape: a guided flow
   (confirm → adjust edges → compound divide/divide/merge, one undo), with
   auto-proceed-when-all-takes-match as a design input and the fanned cases deliberately
   OPEN — Phase 11 brief item 7, QUESTIONS #10/#11, AppSpec §14 (2026-07-09).

3. **Reminder — device rounds and credentials now WAIT for 9c (your 2026-07-07 call).**
   You deferred all sync/device testing until 9b AND 9c are complete: the Phase 8 device
   round (phone provisioning was step 2 of that handoff) and all credential setup happen
   AFTER 9c ships the real sign-in — the Phase 8 Keychain paste-in is now interim
   scaffolding that 9c retires (QUESTIONS #3 superseded by #9). Already done and staying
   done: the A5 visibility-horizon SQL (you deployed it 2026-07-07).

4. **Kick off Phase 9b when ready:** a fresh `/run-phase` session; the execution plan is
   authored and self-contained (`notes/plans/phase-09b-fragments-bridge.md` — the bridge
   to your Fragments journal, Fable implementer + Fable reviewer per your staffing call).
   9c (auth alignment / one account with Fragments) follows it.

---

## What shipped (and why it's shaped that way)

**The phase in one line:** every structural operation is now a calm editor gesture —
divide, extract, make-block, merge, and the W ceremony — with the store, the block index,
and the visible text provably agreeing through every interleaving, and with the everyday
gestures rewriting only the seam they touched.

- **One brain, three doors.** `StructuralGesturePlanner` (pure, exhaustively tested) is
  the single authority on what a selection may do: the menu bar, the right-click menu,
  and the shortcuts all ask it for enablement, and invoking a command re-asks — so a
  stale menu (a post sealed remotely a moment ago) surfaces the real refusal instead of
  acting. Every refusal has honest copy; nothing is ever silent or beep-only.
- **The ratified gesture contract, as ratified.** Two named commands (Divide Block at
  Cursor ⌘⇧D, Extract Selection ⌘⇧E); visible snap-and-proceed (the selection lands on
  the legal sentence/paragraph boundary as part of the one invoke — never a confirm
  step); Make Block from Selection (⌘⇧K) runs two divides as ONE undoable action
  (single-variant blocks only; fanned blocks point you at the W); Merge Blocks (⌘⇧M) is
  explicit and binary — a selection naming more than two neighbors refuses; cross-block
  selections refuse with the workaround named; drops into the open tail are bulk entry
  exactly like paste; extracting from a fanned block shows the passive one-line hint.
- **The W ceremony is one sheet.** Your takes as a checklist (the shown take pre-marked,
  its cut pre-placed where you invoked), each marked take's full text with a visible ✂
  and click-to-place cut positions (pre-seeded by string-context matching when a unique
  match exists — a proposal, never a guess), Confirm gated until every marked take has a
  legal cut, Cancel touches nothing. If a sync round edits a take while the sheet sits
  open, Confirm refuses to cut stale text and re-proposes instead.
- **The differential rewrite (your mid-phase directive, superseding the v1 full-render
  reading).** Everyday gestures now apply as ONE minimal text edit derived from what the
  operation itself reported — never from diffing (the rejected model). Untouched text
  never moves; there is no scroll-restore step at all. The W confirm and structural undo
  deliberately stay full re-renders (rare ceremonial acts; rebuilding from the store is
  the sane answer). Measured: a divide on a 50k-word post costs ~28 ms in a debug build
  (most of that is debug-only checking; the edit itself is block-scale) vs the full
  path's document-proportional rebuild.
- **Three guard layers protect the differential** (each one directly tested, each proven
  by making the old code fail): the seam's own shape; every OTHER block's geometry must
  correspond exactly (a concurrent sync write anywhere falls back to a full rebuild from
  the store); and the retained bytes — the text the edit deliberately doesn't rewrite
  must byte-match the store (your directive: length checks alone would miss a same-length
  remote rewrite). A DEBUG-only oracle additionally verifies every differential apply
  against the store; the randomized soak holds it at zero misses. **The one documented
  residual:** a same-length byte change to a NON-seam block passes (geometry stays safe;
  the stale text heals via the delivery already in flight; checking it would cost
  O(document) per gesture).
- **Per-op undo labels.** The Edit menu now reads "Undo Divide," "Undo Extract," "Undo
  Make Block," "Undo Divide into Variants," disabled when there's nothing to undo. ⌘Z
  remains pure text undo; the stacks never interleave; every structural rewrite clears
  text-undo (a stale replay landing in a different block is the corruption class).
- **`newBlock` now stamps `last_touched_at` and feeds churn** (your #5 option (a) —
  implemented here as owned): mint-only entries and idle-minted tails now get idle
  insurance and sort honestly; Phase 8's two documented sweep gaps are closed, pinned by
  the test that used to document them.

## Counts and verification

**Final: core `swift test` 430 green / 51 suites · Mac app 222 green / 40 suites ·
mobile 11 green / 4 suites** (iOS 26.2 simulator). Release build green. TK1 grep audit
clean; canary silent through everything. The centerpiece verifications: a 3-seed × 250-
action randomized soak (typing, deletions, crystallization, all gestures, the W
confirm/cancel, undo — after every settled action the store, the index, and the surface
agree, with zero desync recoveries and zero oracle misses, and the soak proves it
actually landed structural work); sync convergence under the structural write pattern
(byte-identical stores, empty outboxes, a racing phone edit kept alive per S5); and the
dual-path latency measurements above.

## The review ladder (three rounds, closed at the hard cap)

- **Round 1 — 1 MAJOR / 4 MINOR / 2 NIT, all agreed + fixed with red-on-old pins.** The
  MAJOR: the idle-mint clock could birth a mint mid-gesture (transient duplication of
  your words + an index/store disagreement) — the clock is now held for the gesture's
  whole flight, both doors. Also: the mid-flight header-delivery fence hole; the pure
  extraction of the differential derivation (which made every guard branch directly
  testable); the convergence test's compound widened to the editor's real two-divide
  pattern; text-undo clearing pinned on a real window; a tail-separator selection edge.
- **Round 2 — 1 new MAJOR / 1 MINOR / 1 NIT + your retained-byte directive folded in.**
  The MAJOR: the differential guard validated the seam but not the REST of the projection
  — a concurrent sync write to any other block could de-synchronize geometry in release
  (the daily-drive configuration) with store-level consequences; closed by the non-seam
  correspondence layer, pinned per seam kind and proven by behavioral revert. The MINOR:
  the W sheet's stale-cut window at confirm (now drift-checked). Plus your directive's
  byte layer, pinned the same way.
- **Round 3 — 0 MAJOR / 1 MINOR / 3 NIT; fixes landed post-cap per the ladder's rule
  (recorded honestly — no fourth review).** The MINOR: the W confirm bypassed the
  one-gesture-at-a-time door (the door is now self-guarding from every entrance, and a
  refused confirm keeps your cuts). NITs: stale refusal copy fixed; the confirm's
  check-then-act ms-window documented as an accepted residual; external deliveries now
  defer during a gesture's flight (taken with its pin).

Every finding's disposition — including the two honest pin stories (a first pin that
passed on both sides was re-aimed at its mechanism; the round-1 tripwire was declined as
unpinnable and replaced by your byte-verification directive) — is recorded in the phase
plan's three review-round sections.

## Mid-phase decisions folded in (your 2026-07-07 QUESTIONS walk)

#8 differential rewrite (built this phase, above) · #3 Keychain paste-in ratified, then
superseded the same day by · **#9: Phase 9c created** — the auth core pulled forward
(one account: your Fragments identity IS your Variorum identity; the paste-in retires
into a real sign-in; the key demotes to truly publishable) · the 9b graduated-entry
policy ratified · A5 deployed by you · the feel passes bundled (checklist item 1) · all
sync/device testing deferred until 9b + 9c complete (checklist item 3).

## Pointers

- Phase plan + full closeout + three review rounds:
  `notes/plans/phase-09-structural-gestures.md`
- The differential path's code + guards: `App/Variorum/Variorum/Features/Editor/
  StructuralSeamEdit.swift` (the three-layer guard doc is its header comment)
- The planner (one brain): `.../Features/Editor/StructuralGesturePlanner.swift`
- The W ceremony: `.../Features/Editor/DivideWSheet.swift` + `CutPropagation.swift`
- Next phase's plan (self-contained kickoff): `notes/plans/phase-09b-fragments-bridge.md`
- The auth phase after it: `notes/plans/phase-09c-auth-brief.md` (QUESTIONS #9)
- Master plan: `notes/DetailedPlanForPhases.md` (pointer now at 9b)
