# 18l-c U7 (search in Takes) — ladder ROUND 1 (fable-reviewer, 2026-09-28)

**Window:** `git diff 2deb24d8..HEAD` (U7 whole, 22 commits) plus the orchestrator commit
`471358d6` (U6 close, comment-only). **Verdict: 0 BLOCKER · 0 MAJOR · 1 MINOR · 5 NIT.**
Editor-seam round (`PaneSurface`) — the FABLE seat, TEXTKIT2_NOTES §0/§3/§4 read in full by
the reviewer. The reviewer independently ran the five touched suites (**62 tests / 5 suites,
TEST SUCCEEDED**, the live agreement pin watched in the log) and verified the evidence set on
disk (closing log's counts + the 3424 attribution, all seven revert logs' shapes, the marker
red/green pair, both seeded-walk reports).

**CROSS-MODEL FLOW (CLAUDE.md):** these findings go to the U7 implementer VERBATIM; its
agree/dispute returns to the reviewer, which makes the FINAL CALL and implements its
confirmed fixes itself; then the suite green and one implementer sanity pass. The orchestrator
arbitrates nothing this round unless a dispute lands on undefined product behavior (→
QUESTIONS). This file is the round's record; findings transcribed faithfully from the
reviewer's report.

## FINDINGS (the reviewer's, verbatim-faithful)

| # | Sev | Finding |
|---|---|---|
| R1-M1 | MINOR | `TakesFindController.swift:127–135` (`close()`) — Esc's keyboard hand-back can address a pane that does not exist, leaving the keyboard dead until a click. Mechanism, traced: in exactly the ledger-row-7 trace state the unit's own pin establishes (mode round trip restores the top page while the entry ring holds a block whose row the lazy column never built — `focusedPane` set, `isPaneLive` true, no `PaneTextView`), open ⌘F and press Esc: `close()` issues the hand-back to `model.focusedPane.variantID`, but no realized pane consumes it; the bar unmounts, AppKit drops first responder to the window, typing does nothing — the row-7 shape recurs on the find's own close door. The interim ends when the live row is later scrolled into view. Pin: extend `ledgerRowSevenTracedAndAFindStepMakesTheTakeTypeable`'s trace half — open the bar in that state, `close()`, assert `window.firstResponder is PaneTextView` — RED on this tree. Fix options, honestly split: **(a)** `close()` with no realized pane for the live take lands the article on its placement first (rides the existing `.find` landing road, no new scroll mechanics — decision 5's letter holds), one guarded line; **(b)** record it as a named boundary of road A, which U8's R-18l-13 owns (the same unrealized-entry class). If the implementer disputes toward (b), a QUESTIONS line + HONEST BOUNDARIES row is an acceptable disposition; silence is not (boundaries 1–3 name adjacent reach limits but not this one) |
| R1-N1 | NIT | `TakesFindController.swift:85–86, 127–135` — the step/Esc `request` is never cleared, so `face(forVariant:)` for that one take stays non-nil forever after the bar closes; that pane runs the find-face update paths (behaviorally inert — paint nil, token consumed) on every render indefinitely, and `face`'s doc ("nil when there is nothing to say … byte-unchanged") overstates. Behavior-hollow (no red-on-old pin possible) — cleanliness only. Fix: clear `request` at the next `open()` (it cannot be cleared synchronously at close — the hand-back needs the render close causes) |
| R1-N2 | NIT | `TakesFindController.swift:205–210` (`fanCaretLanding`) — `model.caretLanding(forVariant:)` read twice; bind once |
| R1-N3 | NIT | `TakesFindController.swift:75–76, 332–369` (`recount`) — `wrapped` survives recounts: after a wrapped step, a settle/toggle recount re-anchors `current` but leaves `wrapped` true, so the face keeps saying "· wrapped" for an event that is no longer the last act; one line (`wrapped = false` when re-anchoring changes the list) — cosmetic; her #157 (2) copy pass is the natural home for the taste call |
| R1-N4 | NIT, SPECULATIVE | `TakesFindBar.swift:41–43` + VisualWalk README — ⇧⏎-steps-backward is advertised (the field's help, the README row, decision 1) but has no pin and no walk row; the `onSubmit` + `NSEvent.modifierFlags` road rests on the field editor mapping shift-Return to `insertNewline:`. No failure mechanism traced — an evidence gap, not a bug claim; one walk row or one hosted pin closes it |
| R1-N5 | NIT | plan file U7 LIVE STATUS row 10 + VisualWalk README — two record-accuracy slips: (1) the 074442 abort's artifact reads "the terminal voice control was not found in Settings" and its log prints the radio's FRAME where a press confirmation belongs — the record's narrative ("the AXPress returned a failure code — but the press landed") is an interpretation the artifact doesn't state; the substantive claim (probe id 191 `voice=terminal`) verified in probes.log; the record should quote the artifact's words. (2) the README's `takes-find` row is missing a sentence break |

## CLEAN BILL (headline items, kept for the record)

The compare rule measured not assumed (agreement pin re-run live, 8/8; the brief's wording
correction is the correct resolution); PaneSurface seam discipline whole (read-tier-only
`.backgroundColor` runs per TEXTKIT2_NOTES §3/§4 rule 5, range-scoped, change-gated — real in
production via value-equal `NSColor`s — shed before liveness with typing attributes stripped,
every storage-rewriting road resets the record; no rendering attributes, no TK1, no identity
stamp); the re-parent re-claim correct and safely guarded on all four pinned edges, P-3 held
(restores what the authority's live pane owned — not a second liveness mechanism); the landing
fences held (restore half byte-untouched, `.find` weighed against nothing, R-Q20/R-Q21 pins
unmodified, 4 lines + a lazy property on the P-9 counterexample); registry P-1/P-2 with both
pin re-arms as the ruled change; her rulings each verified in code + pin (R-18l-6, R-18l-10
both halves, decisions 6/8/9; archived takes excluded by construction); P1/P3 cost shape; the
evidence set verified on disk; hygiene (zero core/Shared/Sync, no trailers, #157 complete,
canon edits correctly deferred under OWED AT CLOSE).

**Round state:** findings sent to the implementer verbatim (same turn as this commit);
reviewer holds the final call. Round cap status: 1 of 3.

## THE IMPLEMENTER'S AGREE/DISPUTE (returned 2026-09-28; re-read the named code on `68b1357b` before answering)

**Totals: 6 AGREE, zero disputes on mechanism.** On R1-M1 the implementer agrees the
mechanism (the proposed pin would be RED on this tree) and PREFERS ROAD (b), recorded, on
three grounds: (1) decision 1 promises Esc keeps "her place" — an unbuilt take can only get
the keyboard if the page MOVES to it, and moving the page at Esc breaks the promise in
exactly this case; (2) (a) is not one line — the controller cannot see whether a row is
built (that is `TakesArticleScroll`'s private `articleRowFrames`), so (a) needs a new forward
out of the landing half or an UNCONDITIONAL land at every Esc (which moves the page after a
deliberate scroll-away); (3) the class is wider than find — ANY far scroll away from a live
take drops its pane and loses the keyboard; the find-specific way in is road A, which U8's
R-18l-13 removes; a find-only reveal at Esc would be a second partial fix of U8's class. For
(b) it drafted: HONEST BOUNDARIES row 8 (Esc when the ring's take has no built pane — the
window holds the keyboard until a click or the row scrolls back and its born-live pane
claims; Esc never moves the page; U8 removes the entry half; the scroll-away half is the
lazy column's general class), a QUESTIONS **#157 (7)** fork ((a) as built — the page stays
put at Esc; (b) Esc brings the take back into view and hands it the keyboard), and the
reviewer's pin kept as a `withKnownIssue` arm naming the boundary — red the day (b) or U8
changes the behaviour. On (a) it has no correctness objection IF the reveal fires only when
the row isn't built (needs the new forward; never unconditional). R1-N1: agree, inert as
traced (paint nil-gated by `isPresented`, token consumed); clear at next `open()` + fix the
doc. R1-N2: agree, bind once. R1-N3: agree (`wrapped` resets only in `setQuery`/no-match/the
step; none of `toggleScope`/`projectionChanged`/`open` touch it); fix = `recount` clears it
when the re-anchor changes current or the list; copy rides #157 (2). R1-N4: agree it is an
evidence gap a HOSTED pin cannot close (`NSEvent.modifierFlags` reads live hardware state; a
synthesized event doesn't set it) — the right evidence is a `takes-find` walk row after row
D: `key code 36 using shift down`, assert `tf == 2_of_$total`, `tsel=*,4`, `fr == text`.
R1-N5: agree both; for the 074442 narrative it supplied the honest derivation to quote (the
artifact's words + `vis-ax.swift` prints a match's frame BEFORE pressing and exits 1 only
when nothing matched printing nothing, so frame + non-zero exit = exit 2 = AXPress returned
non-success; "landed anyway" rests on the abort's own probe id 191 `voice=terminal`).

**State: handed to the reviewer for FINAL CALLS + its own fix implementation (the
cross-model flow); the implementer's sanity pass follows.**
