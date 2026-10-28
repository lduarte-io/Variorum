# VX-440 handoff — Sheets & history clarity (books, Block History, versions)

**Run: 2026-10-28, overnight, `/architect-phase`. PR: PENDING(#). Merge: PENDING(sha).**
Record: `notes/plans/fixes/vx-440-sheets-history-clarity.md` · Ladder: `notes/plans/fixes/vx-440-ladder-round1.md` (no BLOCKER/MAJOR).

## Your checklist (the morning bundle)

1. **The Block History declutter verdict (P-440-9 + the pass itself)** — walk shots: PENDING(shots).
   One-line resting rows (stamp · name · a quiet ◦ on automatic commits), rows open in place, region
   headers carry counts, meaning lines behind (i). FLAGGED for you: an unnamed commit at rest shows only a
   time — none of its words until you open it. Good, or should the resting line carry a word or two of the
   text?
2. **The promote-confirm copy (P-440-5)** — "Stop counting this as a version?" / "It becomes a regular
   note — unarchived, unsealed, wearing the note's current tags." / confirm "Promote". Spoken by Compare's
   unmark AND the full-size band's door. Your word?
3. **The version band's wording (P-440-6)** — "A saved version of ‹title› · ‹date›" with "Back to the
   note" and "Promote to a regular note…"; Compare's version column titled by its date with the line "a
   saved version of this note". Your word?
4. **P-440 provisionals to ratify** (all built, all cheap to re-rule): P-440-1 a version's full-size open
   writes NO per-note memories (always opens at the start) · P-440-2 Compare seats ordinary peers first,
   then saved versions newest-first · P-440-3 a brought-back take wears the commit's name as its label ·
   P-440-7 after Promote from the band, the pane shows the promoted note as a note · P-440-8 where a
   restore's landing+wash fires (Write's detail and the Takes board; elsewhere receipt-only; options in the
   record) · P-440-12 VX-356's Study mark is the navigator's viewed-chapter face (accent fill, name in ink)
   · P-440-13 VX-611's one-rule sweep reached every Trash/Put-back sentence, beyond the two sighted.
5. **`show_in_app` and version ids** — the wire still REFUSES a version id (kept deliberately; the app
   state now exists, so opening it is a one-line MCP decision whenever you want it). Say the word and it's
   a ticket.
6. **VX-642-adjacent, not this run's:** nothing here touched Private/Seal/Own.

## What shipped (members, all PENDING(Done-flip) at the merge)

- **VX-130 + VX-437 + VX-432 (one design):** saved versions live in Compare's auto-fill (date-titled,
  sealed/read-only, after ordinary peers); unmarking one PROMOTES after a confirm (the declassify leak is
  dead — pinned red-on-old at `34c21e938`); "Compare with now" on Versions rows; "Compare with Latest
  Version" in File/note ▾/⌘K (renders only with a moment); "Open full size" → the identity band over Read's
  calm page, Back + Promote, no mode rail, no ⌘⇧S, no memories written.
- **VX-431 (+ VX-331, VX-244):** Block History decluttered (one-line rows, counts, (i) explainers); a
  commit reads IN FULL in a sheet with Restore + "Bring back as a take" at its foot; a restore lands at the
  block and washes its start (Write and Takes); `bringBackCommitAsTake` mints the commit's text as a new
  take (never chosen, label = the commit's name); restoreCost's deleted-takes count honors the 30-day
  window (red-on-old); "Show take ▸" no longer renders where it can never act (both arms traced real).
- **VX-611 + VX-616 + VX-189 (+ VX-356):** a gathering says "gathering" at every delete/Trash/Put-back
  sentence; the gathering navigator's "+ new chapter" is gone (Bind into a Book… stays in the row menu);
  a gathering has Book Settings' "Shared with" row and row-menu "Share with AI…" (the one grant sheet,
  faces only, zero reach change); the Book Panel's collapsed chapter row marks the open note in Study.

## Evidence

- Ladder round 1 (Fable, cold): no BLOCKER, no MAJOR; 3 MINOR dispositioned (→ VX-659, VX-660, a VX-234
  comment), 3 NIT (one fixed). Round 2 not owed (one-line non-bug fix; orchestrator line-check).
- Stage: 4/4 red-on-old AS EXPECTED at the recorded SHAs; green union 584/587 (the 3 = batch-1 TEST-harness
  defects, fixed, then 57/57 on the touched suites); vx-601's merge overlap re-run green.
- Two in-window test-host crashes triaged: swift-testing's own ABI event encoder in the runtime
  metadata cache — a toolchain class, NOT VX-657's → **VX-661**.
- Walk: PENDING(verdicts + shots).

## Filed tickets, by priority

- Medium: VX-659 (observeLatestNoteVersion at autosave cadence — Perf/Debt).
- Low: VX-660 (book navigator's Study open-note mark — VX-356's sibling) · VX-661 (the toolchain crash
  class) · PENDING(the two closeout candidates: the host-launch date warnings; the defaults-domain
  cross-suite pollution).

## Mechanical state

PENDING(canon-size line) · PENDING(mobile parity line) · PENDING(QUESTIONS bundle number) ·
PENDING(in-flight row retired, worktree removed, branch deleted, debris swept).
