# VX-601 — cold review, round 1 (fable-reviewer, 2026-10-28)

**Diff reviewed:** `git diff origin/main...HEAD` in `~/dev/variorum-vx-601` at HEAD `86ff62dd8`
(the branch moved during the review — two commits landed mid-read: `1a0082ea9` the 0.10.4 version
bump + What's New notes, `86ff62dd8` the handoff draft; both read and covered). Anchor:
`notes/plans/fixes/vx-601-run-takes-editor-quick-fixes.md` (read in full, all 2351 lines). No
"Review foci" section exists in the record. Canon read: CLAUDE.md + auto-loaded set,
`notes/TEXTKIT2_NOTES.md` in full, `notes/SurfaceContracts.md` (The app / The note / Takes).
Production diff read line-by-line (17 files); the five new/edited pin files read; red/green/battery
logs spot-checked against the record's claims; the whole-target pre-ladder baseline log verified
(5,486 tests / 963 suites PASSED).

---

## Findings (severity-ranked)

### [MAJOR — pre-existing, OUT of this run's diff; the required act is a TICKET at closeout, not a fix in this ladder]
**Write's full-document editor carries the exact undo class VX-421 just fixed for panes.**
`App/Variorum/Variorum/Features/Editor/EditorTextView.swift:880,953` set `allowsUndo = true`; no
`undoManager(for:)` exists anywhere under `Features/Editor/` (grep: the only implementers are
`CaptureTextView`, `CommentTextArea`, and — since this run — `PaneSurface`); and
`EditorViewModel.teardown()` (`EditorViewModel.swift:677–717`) clears nothing undo-related. So
Write's typing/paste undo registers on the WINDOW's manager, aimed at the `EditorTextView`;
`PostDetailView` dismantles the editor on every mode switch; `NSUndoManager` does not retain
targets. Mechanism (inputs → wrong state): type in Write → ⌘2/⌘3/Library (the editor unmounts,
actions stay on the window's manager) → ⌘Z while no text input holds the keyboard → the window's
manager pops an action aimed at the torn-down (possibly freed) editor — the replay/`EXC_BAD_ACCESS`
class batch A proved red-on-old for panes (`PaneUndoLifecycleTests/undoAfterATornDownPaneIsReleasedIsACleanNoOp`).
The batch A implementer recorded this as residue R-1 ("Suspected, NOT traced to a crash — out of
this batch"), which is the honest scope call — but the ledger's closeout row (15) is NOT-STARTED,
so nothing yet guarantees R-1 becomes a ticket. **The red-on-old pin that would prove it:** batch A
pin #2's shape pointed at `EditorTextView` (mount Write's editor in an offscreen window, type,
unmount + release, window-road ⌘Z — zombie/replay on today's tree). **Fix shape (the ticket's):**
the pane road — an owned manager answered through `undoManager(for:)` — or an explicit
window-manager clear at teardown. SPECULATIVE only as to live crash reachability (not reproduced);
the registration half and the teardown half are read directly from the code. **Disposition asked
of this run: mint the ticket (Bug · Suspected · Editor · at least High given VX-421 was a launch
gate) before the run closes; do not fix here.**

### [MINOR]
**The run's canon deltas are owed at closeout and the contract line to change is identifiable now.**
`notes/SurfaceContracts.md` "The note / Takes" carries the article-row session memory ("Its article
remembers the row at the top per note for the session…") but not the new open-fans session memory
(VX-428, R-601-2) — the one user-visible contract change in this run that an existing contract
line's neighborhood already describes. At closeout: that line gains the fans clause + one pointer;
`notes/AppSpecRecord.md` gets the dated narrative for R-601-1…6, the VX-577 supersession of R25's
slot-split half, and VX-248's ruled bend of P-3's "a live pane never adopts projection text" (the
bend is currently documented only in `PaneSurface.swift`/`PaneTextAuthority.swift` doc comments and
the run record); batch A2's R-A2-3 TEXTKIT2_NOTES §3 entry (the settled-caret-covers-next-character
measurement, pinned in `CaretPressTests`) and its §5 re-verify line are drafted in the record and
must land. Ledger row 15 is NOT-STARTED so this is expected — named here so none of the four
pieces drops.

### [NIT]
`App/Variorum/VariorumTests/PaneLifecycleTests.swift:125–137` — `HostLaunchSettle.wait()` gates on
`EditorTypography.isAdopted`, a process-global flag that several OTHER suites temporarily set
`false` and restore (`FocusHandoffTests.swift:94`, `RefontGapTopTests.swift:100–104`,
`InlineEditorWidthReflowTests.swift:90–93`, …). The gate's one-shot wait awaits `Task.sleep`, and
`@MainActor` suites interleave at awaits — so a first call that lands inside another suite's
false-window stalls the full 20 s + tail, then latches. Not a wrong verdict (a false-positive
`true` can only come from a restore of a value that was already true, i.e. the shell had adopted);
a once-per-process stall at worst. A dedicated launch-settled signal (or reading the latch the
shell itself sets) would be sturdier — VX-604's suite-wide gate design is the right home; note it
there.

### [NIT]
`App/Variorum/Variorum/Features/Takes/TakesViewModel.swift` (`landingEnabled` setter) — the
`else if !newValue { board.expansionSink = nil }` arm is unreachable today: `TakesBoardView.init`
sets the flag true and `teardown()` never sets it false. Harmless (the sink is `[weak self]` and
the layout dies with the model), but a reader may believe teardown closes the memory when nothing
does — one doc line at `teardown()` or on the setter would keep it honest.

### [NIT — already routed, named for completeness]
`App/Variorum/Variorum/Registry/OpsRefusalCopy.swift` `wayBack(.lensesBoard)` nests "(⌘2)" inside
`movedNote`'s own parenthesis, and the C walk measured the Write/board receipts truncating at a
1240-pt window before their distinguishing clause (F-CW-2). Both already ride P-C-1 into her
bundle with the copy pass; nothing further owed by this ladder.

---

## Clean bill (checked and found solid)

- **VX-421 (the launch gate).** Mechanism confirmed by my own read: `makeTakeSurface()` →
  `allowsUndo: true` with no delegate manager pre-fix; fix = coordinator-owned `undoHistory`
  answered via `undoManager(for:)` only for the coordinator's own view, `readHistory` (never-
  registered, never nil — nil falls back to the window's manager) for read panes;
  `endUndoHistory` at every programmatic character write (read adoption + re-bind), emptied at
  `uninstall()`. ⌘Z keeps AppKit's road. The six pins exercise the real window road
  (`tryToPerform("undo:")` on the first responder), with #require guards so no red run can take
  the host down; red-on-old verified by revert per member in window a2 (9/6/4 exactly per table,
  logs read); the walk reproduced her exact gesture on both voices, one pid, no crash.
- **VX-248 (her ruled P-3 bend).** `boundVariantID` written at mount and by `rebindIfTakeChanged`
  only; the re-bind runs after the callbacks refresh and before `paintFind`/`isEditable`/
  `noteLiveness`; writes only where the text differs (the A47c class avoided); ends the old
  history even when bytes agree; hands nothing up (`string =` posts no `textDidChange` — the
  probe's fact, pinned by the `aRebindHandsNothingUp` guard); a live re-bind lands its caret in
  the NEW text then claims the keyboard, and spends no stale click flag. All ten
  `PaneSurfaceView` call sites verified to pass `variantID:` bound to the same take their
  `onEdit` names (8 files, checked each). The Canvas widening is pinned on a REAL road with a
  non-vacuity line that would expose a hollow pin (same pane across the switch). VX-222/VX-227
  left in place, now redundant by construction — correct, per the plan.
- **VX-429/VX-592 (CaretPress).** The pure rule is tight: one empty range, caret < length,
  pressed ∈ {c−1, c}, move to the composed-character far edge; the wire gates plain single left
  click, no marked text, lone caret before any hit-test; one `characterIndex(for:)` per
  qualifying click (P1); `stillSelecting: true` so no notification; placed immediately before
  `super.mouseDown` after the checkbox/link/⌘-claim (and block-pick) doors on both surfaces. No
  TK1 API, no attribute write, no storage write, no second selection authority (P-3). Pins assert
  their own preconditions (`anchors`), the read-pane case, the quick-drag "sometimes" guard, the
  held-click-is-a-click guard (one notification, place handed up), ⇧-click, and drag-of-a-real-
  selection untouched; "Write is fine" falsified by revert discrimination (rev592's 2 reds).
  The scout's mid-drag-settle hypothesis was honestly falsified and recorded. Q-A2-1 (which
  *[removed for publication]*
- **VX-428 (expansion memory).** Session-home on `EditorRouter` matches the ratified VX-170
  pattern; seed at construction (before the first geometry report — the 17q lesson), write-back
  per change through `expansionSink` with change-gated reporting (observation byte-identical);
  prune against the FIRST projection only (⌥⌘Z resurrection preserved); empty set never stored;
  the Write panel and Lenses fenced by `landingEnabled` and pinned so
  (`onlyTheTakesBoardReadsOrWritesTheMemory`). Her perf requirement is backed by real numbers
  (VX428-MEASURE lines read from `tier1-b-post.log`: seed 1.2–4.0 µs; 25 fans below the fold
  realize exactly what 0 do; settled 154→168/152→166/155→203 ms — P3 holds), and "getting to the
  right location" by pin #7 (×4 styles, mounted, on-screen assertion) + walk B2/B4.
- **VX-577 (+ the R112 widenings).** The gate flip is an exhaustive switch; the slot-split
  entry-ring mapping (`paneRenderingArticleTake`, read after the filter's reveal, paged to the
  visible page) and the expand-all blur (P-B-1, the R-VX170 rule's shape, flush-backed via
  `blur()` → `autosave.flushNow()`) are both pinned red-on-old on their OWN revert trees
  (rev428map isolating the mapping; rev577 the blur) — the discrimination design here is
  genuinely good. R-B-1/R-B-2/R-B-3 (pre-existing same-class strands) honestly recorded as
  residue, not silently fixed.
- **VX-594.** The door is registry-declared (`.newTake` gains `.surface`; both card hosts list
  it; the chord-drift guard walks the new row); the acts wired ONCE on the model for both hosts
  (the four old closures byte-equivalent, verified against the removed copies in the diff); the
  branch targets the card's NAMED take with the host's card namespace for the reveal. The ⌘T
  half found already true, dismissed HOLLOW with guards green on every tree — exactly the
  hallucination-guard outcome the plan demanded; the B6 margin-click edge (the board's refusal
  unreachable) routed to the bundle.
- **VX-427.** `takeUnit` counts the focused pane's own take through the authority's overlay,
  per keystroke; nil (no unit) over a wrong number for a not-yet-echoed mint; the Lenses
  widening covered by its own pin; the bar's words byte-identical; `postWordCount` untouched by
  the diff (F-CW-3's transient short "in note" count correctly judged out-of-diff → VX-651).
- **VX-574.** The focused board's prose measured byte-identical to Write (glyph-coverage
  numbers in the C walk, both voices — the smoothing hypothesis falsified honestly); the two
  real lighter faces fixed at token consumers (`ReadTakesView.proseInk` → `tokens.ink`;
  `collapsedTakeLineFont` → `tokens.small`, foreground staying muted per the ruled sibling);
  no literal font/color added anywhere in the diff. R-C-2 (chrome fonts) correctly left as
  residue.
- **VX-586.** One wording brain (`BlockLineLabel.caret`), the honest "block —" blank, the sweep
  table dispositioning every id-speaking face (kept identifiers are non-faces); O(blocks) =
  the bar's existing cost class.
- **VX-321.** `ArchivedRoad` read from the same two facts the archive receipt reads; the
  board's sentence pinned byte-unchanged; the panel's header now ONE literal shared with both
  receipts that name it; the four host pins compare against literal halves so a revert cannot
  agree with itself.
- **VX-337.** The fold-flake fix is a model test-correction, not a weakening: the page
  assertion (−30 ± 2) is untouched and still carries the original red; the state assertion
  admits only `.wanted` ON HER ROW (the design's own state, pinned elsewhere by
  `aRestoreWithNoLandingWaitingIsLeftToItsOwnCadence`); the new pure pin proves the old
  assertion rejects the legal state and the new one still rejects `.undecided` and
  wrong-row restores; red-on-old by revert of `restArrived`'s body. The drafted code fix that
  would have reversed a pinned ruling was caught and NOT built — exactly right. The soak half's
  bound respected (her word), hypotheses on the ticket.
- **Process and hygiene.** Zero changes under `Sources/VariorumCore` (no operations, no schema,
  no `Sync/` — nothing sync-shaped to check; S1–S5 untouched by construction); no TK1 API
  (`.layoutManager` appears nowhere in the diff); no attribute stamps; no new liveness authority
  (P-3: the history keys off `isEditable`, which the authority's answer sets); mobile parity
  honest (every touched file Mac-only). Red-on-old by revert PER MEMBER verified across all four
  batches, including the batch B forensics (the bare-`return` revert slip and the #12 suite-name
  miss were traced, rebuilt, re-run red — the green-where-red rows were treated exactly as the
  guard demands, and the worktree collision was repaired by a forward commit with the lesson
  recorded). Tier 1s, the batteries, and the whole-target pre-ladder baseline (5,486/963, 0
  failures) verified against their logs. No attribution trailers on any of the 71 branch
  commits. Walk findings all dispositioned to tickets (VX-634, VX-637, VX-638, VX-650, VX-651,
  VX-652) or the bundle; the B-walk's Terminal gap covered forward by C6, said plainly. The
  0.10.4 bump + What's New notes: one line per bullet, sentence case, content accurate to the
  run (the ⌘T bullet describes already-true behavior — acceptable as user-facing truth).

**Verdict: no finding against the diff's own code. One MAJOR pre-existing sibling to ticket at
closeout, one MINOR canon-delta reminder, three NITs. No round-2-triggering defect found.**
