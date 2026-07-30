# QoL round (2026-07-29/30) — author handoff

**The round is CLOSED.** Everything on your list shipped, was
cold-reviewed (1 MAJOR found and fixed), and is installed at
`/Applications` behind a fresh backup. Final counts, verified by the
orchestrator's own runs: **core 903/102 · Mac 933/151 · mobile 14/4**.
No schema change (mirror stays at marker 4); zero `Sync/` lines. The
full record: `notes/plans/qol-round-2026-07-29.md`.

## Your checklist

1. **Launch the app** — the `/Applications` build is fresh (from the
   round's closeout HEAD).
2. **The feel walk, your six items:**
   - **The take divider:** open your long fanned block and hit Divide.
     The ceremony should open instantly and every click, arrow key, and
     drag should stay instant (before: one click could not finish in
     ten minutes). The sheet now says what checking a take does —
     checked = *cut this take too*, unchecked = *stays whole on the
     original block, in neither new one* — and clicking an unchecked
     take's row now checks it (your ruling).
   - **Whitespace at the bottom:** in Write, at the bottom of a long
     post, the scrollbar now genuinely covers about a page of room
     below the last line — reachable by scrolling, the knob, ⌘↓, and
     jumps, and a window resize no longer throws you back out. Typing
     at the very end keeps ~2 lines of air under the caret (your
     ruling).
   - **Slot split:** a long block's takes show at full length by
     default; the grab bar under the strip pulls them shorter (content
     scrolls in place), and dragging back to natural height means
     "full length again"; double-click the bar resets. Heights are
     remembered per block, locally.
   - **Margin grid:** cards grow with their content up to ~3 sticky
     notes tall, scrolling inside beyond that; one-line takes stay
     small; your "n high" density menu means what it always meant.
   - **Find & replace:** ⌘F in a post; ⌥⌘F adds replace; ⌘G/⇧⌘G step;
     ⌘E searches the selection. Replacements behave exactly like
     typing (autosaved, ⌘Z-undoable). Where a match can't be replaced,
     NOTHING is, and the copy counts and names why ("2 cross a block
     boundary, 1 is in a locked take"). A find can never merge or
     restructure your blocks.
3. **Say the word on anything that reads wrong** — the propose-only
   list below is waiting on your taste, nothing from it was built.
4. **Standing items from the 13d handoff, still yours:** the
   field-guide re-seed (⌘K → Restore Tutorial; four lessons stale),
   the extract-blank-line one-liner, the 13d feel walk.
5. **The next kickoff is yours: Phase 13f (Workspace)** — the plan is
   paste-ready at `notes/plans/phase-13f-workspace.md` (it opens with
   a design sitting; cast at kickoff, as always).

## Propose-only items for your taste (recorded, deliberately NOT built)

- **The ✂ slot no longer widens** — the paragraph doesn't re-wrap as
  the cut moves (calmer, and what makes the ceremony fast). Say if you
  miss the old emphasis.
- **The slot-split drag handle sits below the fan footer** — the
  placement that kept carousel byte-identical; movable if it reads
  wrong in the hand.
- **A windowed ceremony flow** (~±120 words around the cut instead of
  the whole take in a small scroll area) was designed and deliberately
  not built — a long take in the ceremony is still not a *reading*
  surface; your call if you want the windowed shape.
- **Margin grid, honestly:** even grown, a 250-pt-wide card can't be a
  reading surface for a multi-thousand-word take — slot split is the
  style that answers long blocks; the margin grid's honest job is a
  better glance.
- **Replace All is all-or-nothing by measurement, not taste** — AppKit
  delivers the whole batch as one yes/no. If you'd rather have
  apply-and-report ("replaced 9 of 12, skipped these"), it's buildable
  — the finder just has to be driven differently; ask and it's a
  future item.
- **The Edit menu carries no "Spelling and Grammar" submenu** (noticed
  by the review's menu probe; spellcheck rides the context menu and
  13d's levels). Flag it if you miss the menu door.
- **A short post can now show a scrollbar** (the room below the last
  line is honest scroll extent even when the post is three lines).
  Overlay scrollers make this subtle; say if it bothers you.

## What the round was (the one-breath version)

Six items from your day-to-day use, run under `/architect-phase` as an
out-of-band round (your cast: Fable orchestrates, a fresh Opus
implementer per batch, one Fable cold review at the end). Three
batches, each behind a proposal gate — and the gate caught something
real all four times it ran: the typewriter room's tests were green
while the feature was unreachable through real input (the pin-gap
lesson, now a standing rule); the obvious storage spot for drag
heights would have silently reset your saved takes arrangements; the
approved find-replace mechanism was falsified by measurement (AppKit
coalesces Replace All into one transaction — reproduced as a crash);
and a seam-spanning Replace All would have silently MERGED your blocks
if built naively. The cold review found 1 MAJOR (a match that moved
after approval could be applied to the wrong characters — fixed: the
matched text itself is remembered, and anything that moved is skipped
and reported), fixed everything, and refuted its one speculative
finding by measurement.

Also discharged: the TextKit-2 whole-spike re-run your macOS 26.5.2
update owed — zero fallback events, all Phase 6 numbers holding
(`Spikes/TK2Spike/results-2026-07-30-macos26.5.2.log`).

## For the record (not your walk)

- Takes-aware find/replace + whole-library search: recorded future
  scope, your rider verbatim, KnownIssues row owned by 13e.
- A pre-existing flaky test (`theShellRedoActionRunsThroughTheRunner
  AndReports`, 13c-era, timing-shaped) failed once in four full runs;
  deliberately not fixed untraced; owned by 13f's kickoff sweep.
- Incremental find-as-you-type highlighting is OFF in v1 (the one part
  of the find UI the TK2 spike never exercised; named and revisitable).
- The rounds' new environment traps (no `timeout` binary; the
  machine-global find pasteboard; `.incrementing` UUID state leaks) are
  recorded in the plan file's batch records for future sessions.
