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

## FINAL CALLS (fable-reviewer, 2026-09-28 — each verified against the code before ruling; the fix record follows below as the pieces land)

- **R1-M1 → (b) CONFIRMED — the documented boundary, not a reveal.** The reviewer re-checked
  the implementer's three factual claims before ruling: `articleRowFrames` IS private to
  `TakesArticleScroll` (line 767), so (a) is a new forward out of the landing half, never one
  line; an unconditional land at Esc would move the page after a deliberate scroll-away; and
  the entry way into the state is road A, which U8's R-18l-13 removes. The deciding ground is
  decision 1's ruled words — *"Esc closes, focus returns to the board, her place kept"* — a
  page move at Esc contradicts them and would re-rank R-Q21's ruled page restore through a
  side door. The product fork (should Esc ever bring the take back?) is undefined behavior the
  canon is silent on → per the flow it goes to QUESTIONS as a question, never a reviewer
  ruling: **#157 gains (7)** (as-built (a) = the page stays put). Landing: HONEST BOUNDARIES
  row 8 (the implementer's draft, adopted), #157 (7), and the reviewer's pin as a
  `withKnownIssue` arm naming the boundary — red the day (b→a) or U8 changes the behaviour.
  NOT a bug-class fix (no behavior changes), so no revert dance; the pin is the tripwire.
- **R1-N1 → CONFIRMED.** Clear `request` at the next REOPEN (inside `open()`'s `!isPresented`
  branch — targeted, so ⌘F-while-open never races a just-issued step request), and the `face`
  doc corrected to say the hand-back request lingers for its take until the next open (its
  vehicle; inert once consumed). Pin: after step → close → reopen, the face carries no
  request — RED on the old code (the request survived the reopen), revert-verified.
- **R1-N2 → CONFIRMED.** `fanCaretLanding` binds the landing once. Cleanliness, no pin.
- **R1-N3 → CONFIRMED.** `recount` drops `wrapped` whenever the match list or the re-anchored
  current CHANGES (an unchanged recount keeps the face's words — the last step's description
  still holds); the empty-query branch clears it for hygiene. Pin: wrap, then a settle that
  moves one take's text — the face must not keep "· wrapped" — RED on the old code,
  revert-verified. The copy taste stays #157 (2)'s.
- **R1-N4 → CONFIRMED as walk-row evidence** (the implementer is right that a hosted pin
  cannot prove it: `NSEvent.modifierFlags` reads live hardware state). `takes-find` gains a
  ⇧⏎ row after row D (`key code 36 using shift down` → the count steps BACK, the live take's
  4-unit selection, the field keeps the keyboard); README row updated; the scenario run on
  the re-stamped final build, both voices, machine author-free per the traps.
- **R1-N5 → CONFIRMED, with the derivation verified by the reviewer at the source:**
  `vis-ax.swift` prints a match's frame BEFORE pressing and exits 1 only when nothing matched,
  printing nothing — so 074442's printed `739 267 75 24 AXRadioButton` + non-zero exit is
  exit 2 (`AXUIElementPerformAction` returned non-success on a FOUND control), which
  `vw_set_voice` (lib.zsh:394) words as "not found" for every non-zero rc. The record's
  row-10 sentence is re-worded to quote the artifact and state that derivation; "landed
  anyway" rests on the abort's own probe (id 191, `voice=terminal`), verified in probes.log.
  The README's missing sentence break is fixed with the N4 row edit.

**Totals: 6 confirmed as scoped above (R1-M1 on road (b)); zero dismissed; zero to the
orchestrator (the one product-flavored fork goes to #157 as a question, per the flow).**

## THE FIX RECORD (fable-reviewer, 2026-09-28 — commit per piece, pushed each, no trailers, pathspec staging)

| Finding | Landed | Evidence |
|---|---|---|
| R1-M1 (b) | `d203c390` — HONEST BOUNDARIES row 8 (plan file), QUESTIONS #157 (7) + header FIVE→SIX, and `TakesFindBoardTests.escWithNoBuiltPaneForTheRingIsANamedBoundary` | the `withKnownIssue` arm records LIVE (the window keeps the keyboard — the boundary's mechanism seen by the pin), the her-place-kept arm pinned PLAIN and green; not a bug-class fix (no behavior changed), the pin is the tripwire that reds the day (b→a) or U8 changes it |
| R1-N1 + R1-N2 | `e8be430f` — `open()`'s `!isPresented` branch clears the lingering request; the `face` doc states the vehicle wrinkle honestly; `fanCaretLanding` binds once | pin `aReopenClearsTheLastSessionsRequest` GREEN on the fix; **behavioural revert R-N1** (the clear removed, working tree, restored by checkout): **RED 1 in exactly the predicted shape** — `Request(token: 2, select: nil, claimsKeyboard: true) == nil` failed, the Esc hand-back surviving the reopen. (A first revert attempt with a TEST-level `-only-testing` path matched 0 tests — vacuous, discarded; re-run at SUITE level.) |
| R1-N3 | `2006a44f` — `recount` drops `· wrapped` when the list or the re-anchored current CHANGES (an unchanged recount keeps the last step's words); the empty-query branch clears it | pin `aRecountThatChangesTheListDropsTheStaleWrappedWord` GREEN; **behavioural revert R-N3** RED 1 in exactly the predicted shape — `"1 of 4 · wrapped" == "1 of 4"` failed; restored, tree clean |
| R1-N4 | `96a079db` + `00f72f13` — `takes-find` row D2 (⇧⏎ steps back from the field) + the shipped-path resume ⏎; README row updated | **the row itself found a real walker fact:** the transient `using shift down` posts down·key·up faster than the app processes the ⏎, so `NSEvent.modifierFlags` (the LIVE state) read no shift and the step went FORWARD (run `090640` — its row-F red was the path perturbation, not a regression). D2 now HOLDS the shift across acts (down · ⏎ · up — the hand's own shape) and resumes the shipped path: **takes-find PASS 25/25 Terminal (`091057`) and Study (`091332`)**; the Study run's voice-restore abort is the known worded-as-not-found class, its own probe id 64 `voice=terminal`, zero instances after. Lesson recorded in the WalkKit README (the held-modifier rule). The ⇧⏎ road is now proven END-TO-END under a genuinely held modifier — R1-N4's SPECULATIVE label retires as *road works; transient-synthetic input cannot drive it* |
| R1-N5 | `96a079db` (README sentence break) + `2f9c0951` (the row-10 074442 sentence quotes the abort artifact + the verified vis-ax/lib.zsh derivation; probe id 191 carries the landed-anyway claim) | derivation verified at `vis-ax.swift` (frame printed BEFORE pressing; exit 1 prints nothing) and `lib.zsh:394` before adoption |

**Closing run (the five touched suites, after all pieces):** `TakesFindPlanTests` +
`PaneFindFaceTests` + `TakesFindBoardTests` + `CapabilityRegistryTests` + `FindAndReplaceTests`
— **65 tests / 5 suites, TEST SUCCEEDED, exactly 1 known issue** (the R1-M1 boundary tripwire,
by design). Tree clean, every commit pushed. **Round 1 CLOSED on the reviewer's side — over to
the implementer's sanity pass** (its window: `0c335261..HEAD`, the reviewer's five fix commits
plus this record). No new BLOCKER/MAJOR arose during the fix pass; round cap status stays 1 of 3
unless the sanity pass raises one.

## THE IMPLEMENTER'S SANITY PASS (2026-09-28, window `0c335261..6ab89a8f`)

**Verdict: CLEAN** — files match the stated list exactly (product = `TakesFindController.swift`
alone; zero `Sources/`/`Shared/`/`Sync/`/`PaneSurface`/registry/landing-half); the request
clear sits in `open()`'s `!isPresented` branch only, with the token still monotonic; the
wrapped rule is the agreed shape (drops on list/current change, empty branch clears, a step
still sets its own wrap); bind-once correct; the R1-M1 tripwire is the drafted non-intermittent
`withKnownIssue` with the page-kept half pinned plain; #157 (7) and boundary row 8 match the
drafts; the 074442 record quotes the artifact; its own run of the five suites — **65 / 5
TEST SUCCEEDED, exactly 1 known issue** (`18lc-u7-sanity1.log`). Committed and fixed nothing.

**One concern raised TO THE REVIEWER for the final word (the flow's rule), surfaced by
R1-N4's own measurement — product robustness in the implementer's ORIGINAL code:** the ⇧⏎
road reads `NSEvent.modifierFlags` in `onSubmit` — the LIVE session state, not the key
event's own flags; run 090640 proved a quickly-released shift loses that race (the step went
FORWARD). The walk now holds shift across acts, which proves the held case but hides the
product's sensitivity to a fast ⇧-tap / key-repeat / macro. Candidate fix:
`NSApp.currentEvent?.modifierFlags` (the Return keyDown that triggered `onSubmit` carries
what was pressed regardless of release timing) — UNMEASURED whether `currentEvent` is that
keyDown inside SwiftUI's `onSubmit`; the old transient walk form is the natural red-on-old.
Or record it as a named edge. **Optional, harness only:** `vw_abort` does not release a held
synthetic shift; a one-line `key up shift` in the shared abort path closes the stuck-modifier
window. Both the reviewer's call.
