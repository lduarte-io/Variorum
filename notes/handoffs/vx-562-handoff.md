# VX-562 handoff — Book Outline: the highlight follows your scroll, and the nav info pins up top

**CLOSED 2026-10-27 — PR #198, merge-ready the same day as kickoff.** Two build passes + three ruling fixes, a three-round ladder (capped, every finding dispositioned in writing), six stage windows, four walks + a trace walk, eight revert recipes each red on exactly their named pins, and the end clamp seen firing live before close. The record: `notes/plans/fixes/vx-562-outline-follow.md`; the ladder: `vx-562-ladder-round1/2/3.md`.

## Your checklist

1. **Try it:** open a long book in Outline and scroll — the left bar's highlight walks with the page (never your caret), and the line above the page reads "book · N chapters · M notes · note N of M · ‹chapter›". Click a far story: the highlight moves at the click and holds while the story is on screen; your next scroll hands it back. Scroll to the very end: the last note highlights ("you're at the end").
2. **The one taste knob (P-562-8, the confirm walk's find):** at the very bottom a tiny ~12-pt nudge up steps the mark from the last note back to the top row at once — the walker read it as a twitch, while a ~70-pt scroll reads deliberate. As built: the honest 8-pt band both ways. The alternative: a wider leave-band (hold the clamp within about a row of the bottom). One constant either way — your call.
3. **The PROVISIONALs, ratify or redirect (all built, all walked; §MORNING BUNDLE in the record, mirrored to QUESTIONS at the merge):** P-562-1 (no navigator auto-scroll — the Open list's follow idiom is the ready extension, want it?) · P-562-2 (Outline only — extend the follower to the Book/Read flow's left bar?) · P-562-3 (the counts line moved into the pin) · P-562-4 (chapter name only in chaptered books) · P-562-5 (the pin's "note N of M" counts page order; the note box counts membership order) · P-562-7 (a heading names the note it introduces — no blink) · the short-book edges · R-562-A (a click's target holds until your scroll) · R-562-C (any >8-pt scroll releases) · R-562-D/D′ (the slide REJECTED on walk evidence; the at-bottom clamp, standing only for an on-page last note) · the reachable-travel fact (the app's 40-pt bottom bar is never scrollable room — measured, pinned) · the chapter mark (accent fill, name in ink — an accent name fails the palette floor).
4. **The stated cost of the clamp (walked, bundled):** the last screenful's MIDDLE notes (on folded sherlock, 11–12) highlight by click, not by pure scroll — the slide that made them scroll-reachable read as "racing ahead" at reading speed and was removed on film evidence (`w3/L2/n1.mov` is deleted with the evidence; the record's §WALK 3 keeps the verdict).
5. **Riders still open while this code is warm:** VX-96 (Low — the landing's title-over-blank beat, this exact surface) · VX-616 (Low — the gathering navigator's dead "+ new chapter") · VX-563 (Medium — keyboard navigation for the in-note book view).
6. **Filed tickets, triaged:** VX-624 (Low · Suspected — the pre-existing 4-s landing watchdog spin) · VX-629 (Low · Debt — the follower wiring consolidates into the follower type) · VX-630 (Low · Confirmed — Index → Outline carry returns to the note's start, losing the caret's block; pre-existing, also seen as walks' caret-to-block-1) · VX-631 (Low · Wording — the sample-library receipt's "12 storys").

## What shipped

The viewed-pair follower (pure rules in `BookOutlineViewed.swift` + the landing box's bookkeeping + one read-only slot that never writes focus/caret/aim), the navigator's follow-marks (note + the accent chapter mark readable in both voices and appearances), the pinned nav line above the scroll (one honest total past the 300-note window; position + chapter in page order; a heading names the note it introduces), the click adoption (R-562-A), the input-independent release (R-562-C, 8 pt), the at-bottom clamp (R-562-D/D′) and the reachable-travel geometry fact. Evidence: 326 tests in 60 suites green (the only knowns the four standing IndexTierMetrics pins); reverts B/C/E/G/H/H′/I/J; the clamp live at the confirm walk. The dev store was returned exactly as found after every window (held banner intact, Resume never pressed; walk content to the Trash by the agreed road — 14-row sets, Put back real).

## Mobile parity

Nothing mobile-visible — the book Outline's navigator, pinned header and follower are Mac surfaces.

## Canon

One SurfaceContracts line (§The Bookcase and books — "The Outline follows the page"), on the branch; the dated narrative appended to `notes/AppSpecRecord.md` at the merge-moment ledger pass. `Tools/canon-size`: PENDING (run at the ledger pass).
