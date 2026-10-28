# VX-601 — Run: takes & editor quick fixes — HER HANDOFF

**STATUS: FINAL.** Ticket VX-601 · PR #200 · merged b3b1041aa · **RELEASED 0.10.4 (9992)** —
the DMG, appcast and beta page all live and verify-published PASS — at your standing word of
2026-10-28 ("release anyway when it's done, including to the stargazing.tech website… and yes this
word covers the notes too").

## Your checklist

1. **Download 0.10.4** — live at https://stargazing.tech/variorum (the page shows 0.10.4; your
   installed app also updates via Sparkle). The What's New notes are in the app and below (your
   word covered drafting them).
2. **VX-637, your 5-second check:** in Takes with a fan open and the caret in a take, press real
   ⎋ — if the fans close, the walk's ⎋ finding was the harness's synthetic-key blind spot and the
   ticket flips to Test-only; if not, it's a real bug on the "⎋ closes all" contract.
3. **Four leftover "block" rows sit in the dev store's Trash** (2:30–2:33 AM, undo residue of Move
   Take — VX-650). Left to age out rather than Delete-Now'd without your word. Clear them if they
   bother you.
4. **The QUESTIONS #247 bundle** — the run's provisionals and edges, each one line to
   overturn: P-A1 (⌘Z in a read pane holding the keyboard does nothing) · O-2 (a ⌃⌘ take-step
   keeps the caret's character offset — lands mid-word) · Q-A2-1 (should a read pane accept a
   dropped selection?) · P-B-1 (expand-all in slot split ends the ring by a blur) · B6's edge (a
   margin click never clears the current take, so ⌘T's refusal is unreachable) · P-C-1 (the
   per-host Move Take receipts — plus the fact that the Write/board sentences truncate at 1240 pt,
   which argues for shorter words) · P-C-2 (the read twin now uses ink, not a dimmed ink).
5. **Two High tickets want your eye** (neither is this run's regression, both found by it):
   **VX-656** — Write's editor carries the exact undo class VX-421 just fixed for panes (pre-launch
   is YOUR call); **VX-657** — a teardown race (process exit vs the purge janitor's background
   read) segfaulted the TEST host once; its first question is whether a real quit is exposed.
   Also VX-658: the walk words-guard over-withholds every capture (walks are log-evidenced until
   it's fixed).

## What shipped — your checklist, checked off

### 4. VX-601 — Run: takes & editor quick fixes (wave 2 · Fable-reviewed)

- [x] VX-421 ⌘Z after deleting a take crashes — per-pane undo histories (A GATE)
- [x] VX-427 Word count follows the take being typed in
- [x] VX-428 Takes stay open across a brief mode switch
- [x] VX-429 A selection can't start at the caret (probe first)
- [x] VX-574 Takes' lighter font fixed
- [x] VX-586 "block 1/10" instead of the block ID
- [x] VX-594 Branch from a not-chosen take (probe first — likely just a missing door)
- [ ] VX-377 Move/Copy to Wing from ⌘K — *not this run's member: it was VX-439's missed member and
      ran in VX-620 (closed 2026-10-27); check its box on VX-620's row*
- [x] VX-577 expand-all takes in slot split

Riders: VX-592 dragging a selection out of the live editor — [x] fixed (the same held-press
mechanism, in Write too; "Write is fine" was false). Also seated and done at your sitting word:
[x] VX-248 (the stale-live-pane root fix — your ruled P-3 bend), [x] VX-321 (the receipt's words),
[x] VX-337 (the fold flake traced + test-fixed on your pinned R-Q21 design; the SOAK half stays
open on the ticket — the one not-fully-closed member, by your bound: "id try on 337 but bound your
efforts on that one").

**Minted underneath:** VX-634 (the "Undid: Delete Variant" wording) · VX-636 (the Trash receipt
overdraw) · VX-637 (does real ⎋ close the fans? your 5-second check) · VX-638 (the stale slot-split
pager label) · VX-650 (undo's Trash-residue blocks) · VX-651 (the in-note count briefly short after
⌥⌘Z) · VX-652 (the Lenses "+ column" menu clips) · VX-656 · VX-657 · VX-658 (above). The bundle:
QUESTIONS #247.

## The release notes as shipped (ReleaseNotes-0.10.4.md)

See `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-0.10.4.md` — the headline "Takes got
sturdier, and your fans stay where you left them", the ⌘Z crash fix leading, one line per bullet.

## Filed tickets, by priority

- **Medium:** VX-637 (⎋ in Takes — Suspected, your 5-s check) · VX-651 (the in-note count briefly
  short after ⌥⌘Z — cache lag, pre-existing)
- **Low:** VX-634 (the "Undid: Delete Variant" wording) · VX-636 (the Trash receipt draws over the
  bottom row) · VX-638 (stale slot-split pager label) · VX-650 (undo's Trash-residue blocks) ·
  VX-652 (Lenses "+ column" menu clips)
- **High (the ladder's + the release's):** VX-656 (Write's undo sibling) · VX-657 (the teardown race)
- **Medium:** VX-658 (the words guard's blind captures)

## The evidence trail (the record is the one running record)

`notes/plans/fixes/vx-601-run-takes-editor-quick-fixes.md` — the sitting (R-601-1…6), four batch
records, every window's executed counts, the walks W/A/B/C, your VX-428 measurement (seeds 1–4 µs;
25 fans below the fold cost exactly what 0 do), the ladder (ONE round, zero findings
against the diff — `notes/plans/vx-601-ladder-round1.md`), the closeout and THE RELEASE entries.

## MOBILE PARITY

Nothing mobile-visible — every touched file is Mac-only (each batch record states it).

## Canon

126,190 / 150,000 (headroom 23,810) — the deltas landed in the two-file shape (SurfaceContracts' Takes line + TEXTKIT2_NOTES' 27.0.1 entry on the branch; AppSpecRecord's dated entry + QUESTIONS #247 + the master plan at the merge).
