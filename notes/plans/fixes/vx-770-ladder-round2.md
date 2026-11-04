# VX-770 — Ladder round 2 (cold re-check of round 1's fixes; fable-reviewer, 2026-11-04)

**Reviewer:** Fable (fresh session, zero fix-leg context; `notes/REVIEW_PROMPT.md` run verbatim).
**Diff under review:** `2834c37f7..HEAD` (HEAD = 0e2f40b81), branch `vx-770-takes-compare-window` —
the round-1 fix leg: F1 (the Compare face mounted wherever a lane stands), F2
(`forgetPages(ofClosed:evenWhileOnScreen:)`, the collapse door passing `true`), F4 (the rename to
`compositionKey` + `Identifiable` dropped).
**Anchors read whole:** `notes/plans/fixes/vx-770-ladder-round1.md` (the prior round's findings and
dispositions), the run record's "LADDER ROUND 1 — THE FIX LEG" section (agree/dispute, AS BUILT,
the prediction table, READY-FOR-SUITES, R-LF-1..3, the self-assessment). Every source and test line
of the diff read in this session; every mechanism re-traced by my own read (the hallucination
guard); the fix pins are Mac-target and unrun by design — their red/green rides the merge-gate
window — so their DESIGN is judged from source against the prediction table.

**STATUS: COMPLETE — verdicts below; no new BLOCKER or MAJOR; the ladder CLOSES this round**
(the pins' red/green remains owed at the merge-gate window per the record's prediction table).

---

## Verdicts on round 1's findings

### F1 · MAJOR — **FIXED AS SPECIFIED** (pin pending the window)

The fix is round 1's own shape, byte-for-byte in intent: `CompareCellView`'s overlay now gates on
`lane > 0` alone (`CompareBoardView.swift:2144`), reads `let entries = model.face(for:
postID)?.comments[slot.blockID] ?? []` inside the branch, and builds the `GeometryReader` +
`CommentGutterFace` unchanged. Re-traced end to end:

- **The seat now holds in Compare.** With the face mounted through the deletion, the live feed's
  next projection delivers `entries == []` while `panelShown` is true, so
  `shown = seat` (`CommentGutterFace.swift:77`) — the panel keeps its anchor, the deleted fold
  and Restore stay under her hand. The exact teardown round 1 traced (unmount → `@State` death →
  popover torn down) is no longer reachable from the comment feed; only geometry (the lane) can
  unmount the face, which is P-770-3's own rule and recorded as R-LF-2, not this finding.
- **The empty face is inert, so nothing regresses on uncommented cells.** The draw AND the oracle
  record both ride the inner `if !shown.isEmpty` branch (`CommentGutterFace.swift:78–93` — the
  `.recordsBoardCommentFace` modifier is inside it), so an uncommented cell's mounted face draws
  nothing, records nothing, and holds nothing hit-testable (a `GeometryReader` whose content
  resolves to nothing). Batch 2's `oracle.face(world.other.block) == nil` line
  (`BoardCommentGutterTests.swift:551`) stays green by construction, not by luck.
- **Cost:** one empty overlay more per realized cell with a lane, bounded by the rows'
  `LazyVStack` (`CompareBoardView.swift:1779`); the Takes board has paid the identical shape per
  row since batch 2. P1/P-8 hold.
- **The pin** (`CompareCommentGutterTests.herOpenPanelKeepsItsSeatInCompareWhenTheLastCommentLeaves`,
  `BoardCommentGutterTests.swift:666`) is the proven Takes twin
  (`TakesCommentFeedLivenessTests.herOpenPanelKeepsItsSeatWhenTheLastCommentLeaves` — suite struct
  at `TakesPostUndoStalenessTests.swift:214`; the doc comment's suite name is correct) transplanted
  onto the batch-2 Compare rig (`withCompareCommentWorld` / `adoptCompare` / `mountCompare` at
  1100 pt — the same world, adopt road and settle cadence as the green batch-2 pins), strengthened
  with a `#require` premise that the feed no longer names the block — so an old-tree failure lands
  on the finding's two lines, never a fixture line. Red-on-old verified from source: on the pre-fix
  branch the conditional fails → unmount → `onDisappear` forgets the record → both `#expect`s red.
  The per-board reader (`reader(scope, board:)`) is the reconciled attribution. The one real run
  risk (the test host un-presenting the popover, flipping `panelShown` back) is pre-read in the
  prediction table with the honest instruction to record, never "fixed blind" — the twin passed
  the same host at b3r/b5gate. Design sound.

### F2 · MINOR — **FIXED AS SPECIFIED** (pin pending the window)

`forgetPages(ofClosed:evenWhileOnScreen: Bool = false)` (`TakesBoardLayout.swift:433–438`);
`closeCollapsedFans` alone passes `true` (`:413`); `toggleExpanded` (`:562`) and `closeAllFans`
(`:582`) keep the default — the hand-close doors' behaviour is byte-untouched. Re-traced, and the
flag is universally right at its one door: `closeCollapsedFans`' single caller
(`TakesViewModel.swift:2886`) feeds only `TakesOpenFanRule.collapsed`'s output, whose every member
has `liveVariantCount <= 1` (`TakesOpenFanRule.swift:68`); `liveVariantCount >= activeVariantCount`
(`PostRender.swift:60`), so `hasFan == false` (`:57`) and R25's bloom arm
(`followTheScroll && slot.hasFan && visible`, `TakesBoardLayout.swift:334–336`) can never hold a
member — the strip unmounts on screen or off, so the page must go. No other `forgetPages` caller
exists (it is private; three call sites total).

- **The pin** (`TakesPagerAfterCloseTests.aCollapsedFanForgetsItsPageEvenWhileFollowTheScrollShowsItsRow`,
  `:99`) is a pure state transition in the family's own shape. Red-on-old verified from source
  arithmetic: the old `forgetPages` skips the visible block, so `pageOffset("a", limit: 1)` clamps
  stored 1 → 1 (≠ 0) and the rail clamps stored 2 against limit 3 → 2 (≠ 0) — both finding lines
  red; the premise lines green on both trees. Green-on-new follows the flag directly.
- **The keep-guard** (`aFanFollowTheScrollKeepsBloomedKeepsItsPage`, `:133`) exercises
  `closeAllFans` under follow-the-scroll with the row visible — the untouched default arm — and
  stays green on both trees by design, exactly as the prediction table's row 4 states.

### F3 · NIT — **correctly left** (round 1's own disposition: record-only, no pin demanded; the
fix leg touched nothing of it).

### F4 · NIT — **FIXED DIFFERENTLY BUT SOUNDLY** (the corrected premise is real; the rename honors
the intent)

Round 1's premise — "nothing else reads `.id`" — was **false**: at the base commit the VX-757
toggle pins read `model.rows.map(\.id)` as the composition's fingerprint
(`git show 2834c37f7:…CompareToggleIdentityTests.swift` lines 337/343/404/408 — verified in this
session), and `spineID`'s unreachable fallback returned it. Round 1's intent — one identity per
type, the second unread identity gone — is fully met by what was built: `Identifiable` dropped
(the board's one `ForEach` keys `\.spineID`, `CompareBoardView.swift:1779`; no other conformance
site exists), `id` renamed to `compositionKey` with a doc line that says what it is and is not
(`:115–122`), the fallback and the four pin lines following byte-for-byte. The literal retire
would have changed two verified pins' comparators; the "make `Identifiable` use the spine"
alternative would have degraded the `:409` strangers guard toward a tautology (spine ids are
stable across the toggle by VX-757's own design — kind changes would vanish from the comparison).
The rename is the conservative shape that changes no reader's meaning. No residual readers:
swept the repo — the only `row.id` left in the board file (`:1346`) is `NotePickerSheet`'s note
row, not a `CompareRow`. Compile-proven in both trees. R-LF-3 records the premise correction
honestly, as it should.

---

## New findings this round

**None at any severity.** The whole diff was swept for introduced regressions beyond the verdicts
above (hit-testing over the now-always-mounted overlay; the oracle's record lifecycle through
panel-open → last-delete → panel-close; observation-tracking changes from the hoisted read — none:
every cell body already read `model.face(for:)` for `sealed`; the F2 flag's reach; F4's conformance
and reader sweep). Two record-only observations, neither a finding:

- **R2-O1.** The F2 pin states its premises as `#expect`, not `#require` — a hollow green-on-old
  (e.g. visibility never registering) would still surface as a visible premise red in the window's
  run rather than gating the test, so the run reading in the prediction table covers it. Acceptable
  as-is; worth `#require` only if the suite's style ever changes wholesale.
- **R2-O2.** R-LF-1 (a fan bloomed by follow-the-scroll alone, never in the open set, keeps a stale
  page through a collapse — no close door ever sees it) and R-LF-2 (the lane's geometry can still
  unmount the face under an open panel) are honestly-recorded pre-existing classes, not introduced
  here; R-LF-1 shares R-B5-1's root (a strip honouring its page at birth heals both). The
  orchestrator's to ticket or fold into the R-B5-1 candidate.

## Clean bill (checked and found solid this round)

1. **The revert tree is honest, verified with my own hands:** the scratchpad clone's working diff
   is exactly the two behaviour files (13 + 20 lines); both files byte-equal
   `git show 098b72626:<path>` (the pins commit — pre-fix behaviour WITH F4, so the pins compile
   against both trees); the test files are identical in both trees; `nm` finds `evenWhileOnScreen`
   ×8 in `vx770-lf`'s `Variorum.debug.dylib` and ×0 in `vx770-lf-rev`'s; both build logs end
   `** TEST BUILD SUCCEEDED **`. The prediction table's R/R-on-rev, G/G-on-lf rows are the right
   asks and its failure-mode readings are pre-committed, not post-hoc.
2. **Commit order and hygiene:** F4 before the pins before the fixes (so the rev tree carries the
   rename); one commit per piece, each pushed; no `Co-Authored-By`/`Claude-Session` trailers
   anywhere in `2834c37f7..HEAD`; the record file's diff is purely additive; the worktree carries
   only the pre-existing uncommitted `Package.resolved` artifact (left untouched, as briefed).
3. **Scope fences:** no `Sync/`, no schema, no custody, no editor-seam line (`PaneSurface`,
   `EditorTextView`, `BlockRangeIndex` untouched), no `Shared/` file, no capability-registry delta,
   no TK1 API, no literal colour, nothing corpus-proportional. Nothing mobile-visible. Core
   untouched — no `swift test` owed this leg.
4. **Canon:** no delta owed — the F1 fix makes batch 3's AS BUILT line ("Compare's already-live
   feed gets the same guard") and W14's "Same in Compare" true as written, which is the correct
   resolution (align the code to the record's claim, not the claim to the code). Nothing for
   `notes/QUESTIONS.md`; no product behaviour invented.
5. **The doc comments added by the fixes** state the mechanisms accurately (the overlay comment
   names the seat and the teardown; `forgetPages`' comment scopes the exception to the hand-close
   doors; `compositionKey`'s doc forbids its reuse as on-screen identity and names the `\.spineID`
   rule for any future `ForEach`).

## Verdict

F1 FIXED as specified · F2 FIXED as specified · F4 FIXED differently but soundly (corrected
premise verified real) · F3 correctly left. **No new BLOCKER or MAJOR — no round 3; the ladder
closes.** What remains owed is execution, not review: the window runs the red leg on `vx770-lf-rev`
(rows 1 and 3 red, nine green) and the green delta (or the whole-target run that subsumes it, with
the red leg still run separately) and fills the prediction table; a row-1 anomaly reads per the
table's own instructions before anything is called fixed.
