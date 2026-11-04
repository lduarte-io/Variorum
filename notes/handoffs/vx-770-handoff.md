# VX-770 — the author handoff (Run: takes & compare after 1.0 · closed 2026-11-04)

## YOUR MORNING BUNDLE — the checklist (everything that waits on you, point by point)

1. **Your two bugs are fixed and walked.** The takes-open mode-switch jumping (VX-756) is gone
   in every fan style — the re-walk on final bytes landed six of six with zero hops, including
   margin grid, which took a second deeper fix after the acceptance walk caught a residual hop
   the harness had been timing-lucky about. The stay-open behavior is untouched (your R-770-1).
   The Compare toggle flicker (VX-757) was real — every pane was being rebuilt on each flip —
   and is dead; fourteen live flips moved zero board pixels.
2. **Three one-line confirms in QUESTIONS #259** (nothing blocks on them; each is one line to
   overturn): (a) your "track paragraphs" was built as **"follow this note's order"** — if you
   meant a different control, say so and VX-757 reopens on it; (b) your "sorting by creation
   date" was traced to the **Entry date** sort (the Created arm already ordered every note) and
   built to your sentence's intent — undated notes now take the day they were written; (c) the
   margin-grid first-paint flash (VX-794, ≤87 ms in one shape) — a curtain would hide it but is
   product behavior nobody ruled; your taste call, no build owed.
3. **One taste cost you own (P-770-3):** Compare's comment gutter is a width-only lane, so wide
   Compare columns always carry it, comments or not (~465 → ~313 pt of prose at two columns).
   One line flips it to a 36-pt badge lane if you dislike the trade.
4. **VX-652 (the Lenses "+ column ▾" overflow) was NOT built** — the honest fix is a new
   AppKit-anchored pull-down only a live walk can judge, the wrong trade at the night's edge.
   Its ticket carries the full design; option (A) (one-door pull-down) is recommended. Also:
   unlink it from VX-770 in Linear if you want it standalone (the API refused the unlink).
5. **The /Applications refresh is HELD for you** (nov3coordinator's card): a Release build from
   main reports 0.10.4 (10856) against your installed 1.0.1 (VX-779's stale MARKETING_VERSION),
   and a refresh would migrate your store to v1_36 — both yours to take deliberately.
6. **VX-781 (High) deserves an early run:** xcodebuild on this Mac intermittently rewrites the
   workspace Package.resolved UPWARD (SQLCipher 4.18→4.20 among others) and later builds adopt
   it; neither exactness flag held the line. Tonight's merge-gate legs ran on verified COMMITTED
   pins, but a future build could silently ship upgrades.
7. **B3-P2's edge, so it never surprises you:** a ⇧⌥⌘Z that brings back an AI's takes after you
   undid them returns the fans CLOSED — they wait for your click.

## The filed tickets, grouped by priority
- **High:** VX-781 (the lockfile rewriter).
- **Medium:** VX-782 (Takes callout pads the row — one-law breach), VX-788 (the fresh-pane
  24-pt seed — the flicker class root).
- **Low:** VX-783 (callout whole emoji), VX-784 (round-trip reveal hops — the ride-through
  road), VX-785 (landing signposts not in the unified log), VX-786 (follow-the-scroll collapse
  corner), VX-787 (re-ordered pairs' partial rebuild), VX-789 (double-press mints two
  outlines), VX-790 (undo-label wording drift ×4), VX-791 (boards write state during view
  update), VX-792 (the Takes return flash + wrong style label), VX-793 (Compare can't add a
  first comment), VX-794 (the first-paint flash), VX-795 (the every-surface comments probe).

## The run, in one paragraph
Thirteen members; twelve fixed and red-on-old verified in real stage windows, one re-owned with
its design (VX-652). The ladder ran three rounds (two planned, one scoped to the walk's
finding) and closed with nothing outstanding; the acceptance walk ran twice (16/17, then 6/6 on
final bytes). The merge gate ran on the merged tree with committed pins both legs: Mac "5846
tests in 1019 suites passed", phone "86 tests in 18 suites passed" (18 of 18 types,
MobileLibrarySortTests included — the date sort reaches your phone, MobileSoul PL-67). Canon:
three SurfaceContracts lines and AppSpec §10's date-sort fallback, in place with pointers.
Tools/canon-size at the closeout: 130,096 of 150,000 (headroom 19,904) — no crossing. NO
release (your word). The record's FOR A LATER READER is the one section a later session reads:
`notes/plans/fixes/vx-770-takes-compare-window.md`.

## Rulings reconciled (the "every/all" check)
R-770-2's "like other surfaces" and §12's every-surface comments line: Takes (all styles) and
Compare now comply, Write was the reference; Lenses/Blocks/Read-edit were out of scope → the
probe is VX-795. R-770-1's "stay though": verified by pins on both trees and both walks' look
lines. Her date-sort sentence ("it should use their creation date…"): built on the arm that was
actually broken (Entry date), CONFIRM-2 above.
