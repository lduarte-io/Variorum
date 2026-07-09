# Phase 9d — Editor visibility & QoL fixes

**Status:** in progress (2026-07-09).
**Origin:** out-of-band, author-directed 2026-07-09 — her first hands-on session with the
Phase 7–9 editor, before the formal feel pass. Decisions recorded in AppSpec §14's
2026-07-09 delta; open items in QUESTIONS #10/#11; scope handoffs in the Phase 10/11
briefs. **Runs BEFORE 9b** (master plan pointer updated).
**Cast:** implemented directly by Fable in the author-attended session (her staffing call —
recorded in CLAUDE.md's model-policy table). Not a `/run-phase` cast; no cold reviewer owed
by default.

## Why this phase exists (the two gaps + the visibility problem)

The author's first real session found:

1. **A block's first branch has no door.** The FanPanel (Phase 7 — branch/blank/choose/
   archive/lock/delete, all tested ops calls) opens ONLY from the ⑂ corner badge
   (`EditorView.swift` badge overlay → `openFan`), and badges render only `where
   slot.hasFan`. Chicken-and-egg: fanning is unreachable in the UI. Tests never caught it
   because they call `openFan(blockID:)` directly.
2. **Refusals are silent in practice.** All three gesture doors (menu bar, context menu →
   both gate shortcuts too) are `.disabled(...)` on a planner refusal, so `RefusalCopy`'s
   twelve tested messages only surface on stale-enablement races. A refused shortcut is a
   dead key; combined with invisible block boundaries, "what is possible right now" was
   unanswerable from inside the app.
3. **Block structure is invisible.** Boundaries can't be seen (her document was pasted →
   one block per paragraph → cross-block refusals everywhere with no way to know why),
   block identity shows only as a truncated UUID, and there are no visible affordances
   proving the gestures exist.

## The current segmentation contract (recap for clarity — nothing here changes in 9d)

Recorded because the author asked "what has actually been decided?" — this is the settled
state as of Phase 9, in plain terms:

- **Typing new text at the end of a post:** each completed paragraph silently becomes a
  block as you type past it (type-time crystallization, paragraph granularity in EVERY
  segmentation mode — author ruling 2026-07-06). The trailing paragraph still being typed
  is the *open tail*; it becomes a block after a 2 s pause (idle-mint) or at teardown.
- **Paste / drag-drop / import / mobile capture:** bulk entry — segments on arrival per the
  post's segmentation setting (global default: paragraph; journal profile: one block).
  Sentence-level segmentation exists ONLY as a bulk-entry mode.
- **Enter inside an existing block is pure content, forever** (I4). Blocks never split by
  typing; only the explicit gestures (divide/extract/make-block) change boundaries.
- **Sentence-level blocks arise only by deliberate carving** (extract/divide/make-block —
  floor is the sentence) or sentence-mode bulk entry.
- **Consequence worth knowing (inherent, not a bug):** the editor separates blocks with a
  newline, and TK2 discipline maps blocks to paragraph elements (TEXTKIT2 §3) — so carving
  a mid-paragraph sentence into its own block visibly splits that paragraph into three
  lines in the editor. Sentence blocks are a *promotion to their own unit*, not an
  invisible annotation. If daily use makes this feel wrong, that is a product conversation
  for the author — it is constrained by TK2 (inline multi-block paragraphs would need
  custom text elements, which are broken — TEXTKIT2 §3).

## Scope (all author-directed 2026-07-09)

Each step lands with tests where there is logic to pin; pure helpers get direct tests;
thin SwiftUI faces over tested ops may land UI-only (per the testing expectations —
"UI-only changes may be untested early; domain logic may not").

1. **Fan door.** "Show Takes" in the Block menu (⌘⇧T), the editor context menu, and the
   bottom bar — enabled whenever the caret is in a block, ANY arity (this is the fix: the
   badge stays fan-only per the calm default, but the *door* must not be).
   `EditorViewModel.openCaretFan()` → existing `openFan(blockID:)`.
2. **Refusals fire and speak.** Gesture doors are no longer disabled by the planner
   verdict: invoking a refused gesture surfaces its `RefusalCopy` message (the
   `invokeGesture` path already does this — the change is removing the silent gate in
   front of it). The verdict still drives *visual* state (button dimming). Menu items stay
   enabled whenever an editor is active.
3. **Gesture button bar** (the fourth door): Divide · Extract · Make Block · Merge · Takes
   in the bottom bar; planner verdict shown as dimming, clicks always speak.
4. **Block ordinal display:** the status bar's "block 741AC27E" becomes
   "block 6 of 23 · 741AC27E" — ordinal derived from the current index, never stored.
5. **Word counts:** caret block count; when a selection exists, "N of M words" (selection
   count across whatever it spans, cost ∝ selection). Pure helper, tested.
6. **"Show Blocks" tint mode** (toggle in the Block menu, persisted via AppStorage):
   soft pastel background per block via an overlay (the badge overlay's fragment-frame
   technique; decorations stay OFF the text storage per TEXTKIT2 §3 — rendering attributes
   are the flaky path). **Color rule (author): not alternating zebra** — deterministic
   per-block color from a stable hash of the block ID, palette ≥ 4 soft pastels, with a
   local bump so the same color is never adjacent; inserting a block never re-ripples the
   document (worst case a bounded local cascade). Pure assignment function, tested
   (adjacent-distinct; stability under insertion). Functional-unstyled; Phase 13 owns the
   pretty version + fan color-coding.
7. **Sidebar post rename:** context-menu Rename on library rows → `renameContainer`
   (op shipped Phase 2; this is its first face).
8. **N-way merge chain** (supersedes the binary ratification — AppSpec §14 2026-07-09):
   a selection touching 2+ blocks merges the whole contiguous run `[first…last]` touched —
   including empty blocks the selection spans — as a left-to-right chain of the existing
   binary merges under ONE undo compound (`UndoStack.withCompound`). Caret-at-seam stays
   the binary gesture. The chain path renders via the full-render door (a deliberate act,
   not keystroke-rate; the differential seam edit stays for the binary case). Planner:
   `.merge` generalizes to the ordered index list; `tooManyBlocksForMerge` refusal retires
   (a text selection is one range — the touched set is always a contiguous candidate).
   Planner tests updated + new cases (3-block chain; empty-block inclusion; the
   endpoint-graze exclusion still holds).

## Verification

- Mac app suite green (planner/gesture/soak suites must pass with the merge-chain change);
  core suite untouched (no `Sources/VariorumCore` changes — nothing near the sync rider).
- Manual: the author can branch a first take from an unfanned block; a refused gesture
  says why; Show Blocks makes the paragraph-per-block structure visible; N-way merge on a
  pasted multi-paragraph selection produces one block, one ⌥⌘Z undo.

## Closeout

*(filled at completion)*
