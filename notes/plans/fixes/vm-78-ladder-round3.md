# VM-78 — ladder round 3: the cold review's findings

**Reviewer:** `fable-reviewer`, a fresh session with no implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff:** the run's whole diff, `git diff e48ef2f30..35ce90848` on
`vm-78-fixes-to-whats-there` (67 commits, 49 files); the commits since round 2's review are
`a00581328..35ce90848`. **Anchor:** `notes/plans/fixes/vm-78-ladder-round1.md` and
`notes/plans/fixes/vm-78-ladder-round2.md` (each round's findings and final calls) and the run record's ladder
tables. **Date:** 2026-11-19.

**The count: 0 BLOCKER · 1 MAJOR · 5 MINOR · 3 NIT, all new in this round.** No finding is against a product
line this run changed. The MAJOR and three of the MINORs are about VM-17's fix (batch D), which is not written
yet, and the instrument built to shape it. Round 1's F1 still stands: this round cannot close the ladder
("What is still owed").

## What this round read and ran

- Read myself, whole: `notes/REVIEW_PROMPT.md`; the run record (every batch's LIVE STATUS, batch C's results and
  the VM-24 write-up, batch D, the ladder, the Closeout draft); rounds 1 and 2; CLAUDE.md and its loaded canon;
  `notes/TEXTKIT2_NOTES.md` whole; the canon the run edited (`notes/SurfaceContracts.md`, The Bookcase and
  books; `notes/MobileSoul.md` row PL-75) and the handoff draft; the whole run diff — every product file's
  diff, and at the tip `MobileBookDetails.swift`, `MobileFanBadgePlacementProbeTests.swift` and
  `MobileFanBadgeSettleMeasureTests.swift` whole; the code the new work leans on (`MobileTakesChrome.refresh`,
  `MobileBlockDecor.refresh`, `MobileEditorTextView` `layoutSubviews` / `refreshChrome` / `nearViewportBand` /
  the three geometry helpers, `MobileEditorViewModel.storageDidEdit` / `fallbackVerdict` / `desyncRecovery` /
  `jumpToBlock`, `EditorEditRouting`'s `ArmedEdit.describes`, `UndoStack.undoReporting` / `redoReporting`,
  `Queries.reading` / `bookshelf` / `liveMemberNoteCount` / `pendingArrivalCount`,
  `MobileTakesChromeTests.perTickRefreshResolvesOnlyNearViewportGeometry` and its keystroke twin); the two
  passages the VM-24 write-up cites from earlier records (`notes/plans/mobile-round-2-crash-trace.md`, the E1
  result; `notes/plans/mobile-round-2.md`, M25).
- Not triggered: SyncSpec, CastleRules, MCPSpec — `git diff --name-only` still names nothing outside
  `App/Variorum/` and `notes/`; no schema, no custody, no protection sentence.
- Ran: nothing on the stage (other sessions hold it), no `xcodebuild`, no simulator, no `swift test` (the diff
  changes no core file). Read-only checks over the kept evidence: every window-(3) log's verdict line and
  named reds (`vm78-c-M1` … `M9-green`), the `VM17|`, `VM24|` and `VM19|` lines, a `diff` of M5's and M5b's
  geometry lines, the R2-N1 and F4 window logs, three result bundles with `xcrun xcresulttool` (`c-M5`,
  `c-M9-red`, `r2n1-green` — the tool writes its index file into a bundle it reads), and the two build logs
  after the instruments left (`vm78-c-bft7.log`, `vm78-d-bft1.log`).
- Not re-checked: the Apple documentation quotes in the VM-24 write-up (one external lookup, by the batch's
  runner; I did not repeat it — nothing in this round's findings rests on them).
- **Review foci:** the run record has no "Review foci" section and no brief file beside it, so there are none
  to answer.

## Round 2's fixes, re-checked against each final call

| Final call | What is on the branch | This round's reading |
|---|---|---|
| R2-F1 | the two unreadable red bundles said as such, their logs named; the 90 s grace and the `xcresulttool` read in batch C's matrix | as called. Window (3) kept all eleven bundles readable (each `xcodebuild` exited by itself); R2-N1's red bundle is the second unreadable one, and the record says so |
| R2-F2 | two lines under "Combinations no arm maps", H1's second half, arm A's one posture expectation | as called — and both lines were USED: window (3) met line one (`waited spins=300` in five of six real-posture cases) and line two ("Hello" #1 `{1,5}` green against #2 `{1,8}` red in one posture). The orchestrator's decision that followed is read below (the clean bill) |
| R2-F3 | reading (i′) in the probe (`78179b765`), its counts, its two expectations; the HOLLOW arm's reach sentence | matches the final call line for line (the point 1 pt under the badge's top, container coordinates, mid-width, skipped and counted off screen, nothing forced). Not vacuous: the jump road asked 22 badges and missed none, the walk asked 54 and missed 35 |
| R2-N1 | the four act rows carry their drawn captions as `.accessibilityHint` (`97282e72f`); pin `theBookDetailsRowsSpeakTheirCaptionsAsHints` (`01205f799`) | right. `vm78-window-r2n1-red.log`: 11 tests in 2 suites failed, four issues, all four the pin's hint expectations; `-green.log`: 11 in 2 passed. F5's two hosted guards are green on both sides, so the hosted driver does read a SwiftUI hint and the "comes out by a new commit" branch does not apply |
| R2-N2 | the recipe's array marked as run, the follow-up's leg beside it | as called; F4's red (three expectations) and green are in the kept logs |
| R2-N3, R2-N5 | the quoted filter; the voice-flip cite | as called |
| R2-N4 | the line for VM-62's run under "Lines for other owners" | as called, with the added clause |

## Findings, by severity

### MAJOR

**R3-F1 · [MAJOR — the reach of a proved mechanism; on these overlays no run has measured it, so SPECULATIVE as
to occurrence] · `App/Variorum/VariorumMobile/Features/Write/MobileBlockDecor.swift:136-139` and `:195-198`,
with the forced helpers at `Write/MobileEditorTextView.swift:603-673` · the rule window (3) proved wrong for fan
badges is the block decor's rule too — callout washes, callout glyphs and comment marks — and neither the
record nor a ticket owns that.**
- *The mechanism, link by link.*
  1. The one refresh door runs the decor before the takes chrome (`MobileEditorTextView.refreshChrome`,
     `:320-332`). At load the pass is full for both (`.document`, or the first tick's width escalation: the
     band is nil). A callout's wash is placed from `blockRectsUnion` (`:631`), its glyph from
     `firstLineGeometry` (`:611`), a comment mark from `lastLineEnd` (`:656`) — each `.ensuresLayout` from the
     block's own mid-document offset, the read the badge takes — and written in content coordinates
     (`MobileBlockDecor.swift:143-149`, `:157-161`, `:209-214`).
  2. On every later tick an off-band block that already has its overlay is skipped and the frame stands
     (`:136-139` for the wash, and the glyph's placement sits below that `continue`; `:195-198` for the mark).
     The band's own comment says it "mirrors the takes chrome's exactly (the sibling discipline — one scope
     law, two controllers)" (`:82-85`).
  3. M5 measured what such a load-time read returns and what TextKit then does with the fragment: the block at
     `@9190` read 4683.0 at load and settled at 6207.0; 21 of 22 fans stood off the idealized layout at load,
     the largest by 9,276 pt; 24 stale load-time frames were then seen inside the viewport on the walk.
  So a wash, glyph or mark loaded at an estimate stands there until its block comes within one viewport of
  characters of the page. A wash is the height of its block and tints whatever text it stands behind — a larger
  thing to see than a badge.
- *What is and is not shown.* Links 1 and 2 are code I read; link 3 is `vm78-c-M5.log`, for a fragment read by
  the same call. No run has put a callout or a comment on that note, so that a wash or a mark itself stands
  astray is inferred, not seen.
- *Why it is ranked.* Batch D's brief covers the badge and names the peek markers and the pill ("the fix covers
  them or a ticket names them"). The decor appears nowhere in the record except as a suite name in a test
  list. As briefed, the fix would change one of two controllers that are written to share one law, and leave
  the proved mechanism standing, unowned, on the more visible overlays.
- *Fix.* (a) Measure it in the window the settle instrument already owes: a separate test (the pin test is not
  edited) on the probe's note with a callout and a comment on every Nth block, the probe's readings (i) and
  (ii) over `blockDecor.frameView(for:)` and `commentMark(for:)` against unforced fragment tops, on the stepped
  walk. (b) Then one of two, the orchestrator's call, written in batch D's entry: ONE rule for both
  controllers in batch D (an overlay is resolved only for an in-band block and does not stand off-band), with
  that reading red on the unfixed decor and green after; or batch D stays the badge's, and the decor goes to a
  ticket that carries that reading as its pin, the band comment in `MobileBlockDecor.swift` then saying the two
  laws differ until that ticket.
- *Pin.* (a)'s reading, red on the unfixed decor. If it is green there, this finding is hollow for the decor:
  record it, change nothing.

### MINOR

**R3-F2 · [MINOR — advance guidance on batch D's fix shape; nothing is built, so no pin of its own — the
probe's readings are the pins; SPECULATIVE where marked] · `Takes/MobileTakesChrome.swift:146-170` and
`:206-209`, `Write/MobileEditorTextView.swift:587-598`,
`VariorumMobileTests/MobileFanBadgePlacementProbeTests.swift:309-323` · three places where "resolve in-band
badges only, hide the rest", built as worded, does not yet do what round 1's final call meant.**
1. *The band is one tick old.* `nearViewportBand()` reads `textViewportLayoutController.viewportRange`, and the
   tick runs after `super.layoutSubviews()` but before TextKit has laid out the viewport for the new bounds.
   That ordering is batch D's own reading of the 74-pt class and M5 supports it: every fan first seen within
   about 220 pt of the page's bottom edge read 74 pt short, and every fan first seen 260 pt or more above it
   read exactly — what the previous pass had laid out (the old viewport and some 300 pt past it) was right,
   what lay beyond it was read ahead of unlaid text. So "hide it as it leaves the band, resolve it as it enters" decides on the previous viewport.
   For a 0.8-viewport step that band still covers the fans coming into view. After a far single-step change it
   does not: the fan now on screen is off the band on the first tick, where today its old frame stands and
   under the confirmed shape it would be hidden. On the probe's jump road a second tick seems to follow by
   accident: the first jump's logged offset is 23334, where that block's load-time frame on the walk's mount
   (23302.25) less the jump's 24 pt is 23278 — so, if the two cold mounts load alike, the page moved 55.75 pt
   after the jump, and that move is another layout pass with a fresh band. Where TextKit
   moves nothing above the target (a jump back into laid-out text; a saved place restored on re-open), no
   second tick comes. SPECULATIVE as to occurrence; the stale read is concrete. The consequence for the shape:
   the re-read after TextKit's pass (a fresh band, settled frames) is part of what fixes the stray, not an
   extra for the 74-pt class. Batch D's forecast for the confirmed shape ("(iii) green", about 11 · 11 · 9)
   should be read with this in hand.
2. *A nil band reads as everything-near* (`:146-150`, `:169-170` — "never a silently skipped block"). If the
   load's full pass meets no viewport yet, the confirmed shape forces every fan exactly as today. The final
   call should say what nil means for the GEOMETRY walk (nothing resolved now; the re-read after the first
   viewport pass resolves) while the reservation walk keeps every block. SPECULATIVE as to whether a load ever
   meets a nil viewport; the fallback line is concrete.
3. *Reading 1 reads badge views whether or not they are drawn.* `:309-310` builds its list from every
   `badgeView(for:)` frame (the local is named `drawn`, but nothing filters on it). If the fix keeps off-band
   badges as hidden views that were never placed, they coincide at their first frame and reading 1 goes red on
   a pile nobody can see. If it removes them, three existing expectations invert
   (`MobileTakesChromeTests.swift:513`, `:529`, `:617` — `badgeView(for: seed.far) != nil`; batch D's record
   names `:529` and the `.document` half only). Decide which in the final call. Narrowing reading 1 to drawn
   badges is faithful to the brief's own wording ("sits at its own block (or is not drawn)"), but it is an
   amendment to the pin: ruled first, then red-on-old shown again for the changed probe (the brief's rule), in
   the same window as the green.

**R3-F3 · [MINOR — a bug in the instrument that will shape the fix; test code only, fix it before its window] ·
`App/Variorum/VariorumMobileTests/MobileFanBadgeSettleMeasureTests.swift:481-508` (`DisplayTurn`), with `:300`
and `:331` · a timed-out fallback from an earlier stop can end a later stop's wait.**
- *Mechanism.* One `DisplayTurn` serves every stop of mount 1 (`:300`). Each `next()` schedules a 0.5 s fallback
  (`:491`) that is never cancelled, and `finish(fired:)` (`:501-507`) acts on whatever link and continuation are
  current. A stop is far shorter than 0.5 s (the probe's 83 stops took 4.29 s), so every call's fallback fires
  during a LATER stop. When that stop is inside its own `next()`, the stale fallback invalidates its link and
  resumes it with `false` before any display callback has come.
- *Wrong outcome.* At those stops the `link` moment is the `flush` moment over again, and `linkFired`
  undercounts. The record reads a missing count as "no callback came" — a limit of the host — and in the
  outcome "only `flush` or `link` agree" those stops are false disagreements at `link`.
- *Fix.* A token per call (or a cancellable work item), so a fallback can finish only its own call; or a fresh
  `DisplayTurn` per stop. No product pin: the file is an instrument and leaves the tree.

**R3-F4 · [MINOR — two readings the instrument does not take; advance guidance, no pin] · the same file,
`:295-298` and `:388-391`, and batch D's "What each SUMMARY outcome would mean" · the table can send the fix to
a main-queue hop without having looked at the cheaper shape, and it measures only the probe's stride.**
1. *No moment after TextKit's own subview inside the pass.* The sentinel is inserted at subview index 0, so
   `pass` is taken before the text view's other subviews lay out; `afterPass` is after the whole window pass.
   For "`pass` disagrees, `afterPass` agrees" the table goes straight to a hop. A second sentinel kept as the
   LAST subview (`passEnd`) says whether a re-read from a trailing subview's `layoutSubviews` already sees the
   settled frame: the same pass, the right badge in the frame that is drawn, no hop. A hop queued from inside
   a layout pass runs after that pass, so the 74-pt badge can be drawn for one frame before it is corrected.
   One more line per stop decides between the two shapes.
2. *Reach on a finger-sized tick.* Both mounts repeat the probe's 0.8-viewport step, where one tick crosses a
   whole viewport. On a drag the tick is a few points and the chrome re-reads every band fan on every tick, so
   by reading the 74-pt class is corrected one tick later and stands only when the LAST tick of a gesture is
   the one that laid out the lines above a fan. Whether she can see it on a drag at all — and so what a second
   chrome pass per tick buys on the scroll road, the one P1 is most sensitive to on this surface — is
   unmeasured. A third mount would say: 20–40 pt steps, one layout pass per step, no settle between, one
   settle at the end; print the ticks where a drawn badge in the viewport is off its unforced line at
   `afterPass`, and whether one still stands after the last tick. Printed only. The probe's stride stays the
   pin either way: a single large step is a real road too (the jump, a restored place).
3. R3-F1's decor reading rides the same window.

**R3-F5 · [MINOR — the held decision's reach is understated; record only, no code, no pin] · the run record,
"VM-24 — the mechanism, its reach, and the options", the reach table's first row, and the live state's "typing,
Return, Tab and the markdown acts are armed" · the capture cited as evidence that typing is armed is the
capture of a typed character landing unarmed.**
- *Evidence.* The row cites `notes/plans/mobile-round-2-crash-trace.md:8-24`. Those lines are
  `#50 GATE at 178 … → armed`, `#51 EDIT at 177 … arming rejected`, `#52 EDIT at 178 len 1 Δ+1 after 0 gates ⚠
  gate-less`, and that file's own reading of them: the delegate was asked about one character at 178, a
  different transaction landed first, "then performed the real insertion at 178 without consulting at all". By
  the code that is the rule, not luck: `storageDidEdit` clears the arming at the first report whether or not it
  binds (`MobileEditorViewModel.swift:1855-1856`), so a consulted keystroke that lands behind a keyboard
  transaction of its own is routed by `fallbackVerdict` like any gate-less edit. The table's autocorrect row
  uses the same `#52` line as autocorrect's evidence.
- *Why it matters to her decision.* The unarmed road includes an ordinary typed character whenever the keyboard
  puts a transaction between the consult and the insert — seen on her phone "in ordinary use". At a block's
  end with a widened report that is the snap-back the write-up describes. And option 3 (arm the roads the
  phone can see) cannot cover an arming that is spent before its edit lands; option 1 does not depend on the
  arming at all.
- *Fix.* Reword the row and the live-state sentence (asked, but the arming can be spent on a transaction that
  lands first; the keystroke then routes unarmed — E1 #50–#52); add the consequence to options 1 and 3; carry
  it into the handoff's lead item.

**R3-F6 · [MINOR — process; a rule the record does not have yet] · the run record, the live state's steps 4–8
and BATCH D · the tip carries a second deliberately red test and a new instrument, and the steps to the gate
were written before either existed.**
- F7's rule reaches `MobileFanBadgeSettleMeasureTests`: it leaves, in its named commit, before any
  whole-target run. Step 5 names only the three trace suites and the cost note, which are already gone.
- The probe is red on the tip by design (VM-17's pin on the unfixed chrome). If batch D's fix does not land in
  this run — the shape needs her, or the cap runs out — the record has no rule for that test at the gate and
  the merge. The honest choices: it merges red and unwrapped as VM-17's pin, named in every result line beside
  VM-24's (a second standing red on main, for every session's gate line — hers to allow); or the probe file
  leaves this branch in a named commit and rides VM-17's own branch, its red on file. Never wrapped as a known
  issue. Write the rule in the live state before the gate.

### NIT

- **R3-N1 · the run record, BATCH D, "Evidence".** "No second red leg is needed unless the probe file changes" —
  the file did change after M5 (`16c75a5bf`, the cost note out). The rule's point holds and one sentence should
  say why: the pin test is byte-unchanged since the build M5 ran (`git diff 78179b765..HEAD` on that file is the
  cost note and three header lines), and in M5 the pin ran first, before the cost note (`vm78-c-M5.log`), so
  its red owes nothing to its neighbour. If R3-F2's third point amends reading 1, the red leg is owed again.
- **R3-N2 · the closeout drafts lag window (3).** FOR A LATER READER ("VM-24, VM-19, VM-17 — PENDING(window
  3 …)", "Three batches"), the Closeout's VM-24 and VM-17 blocks and its evidence row (3) (they still describe
  the instruments as built, and M1–M9 as pending), the handoff's item 13 and its checklist — the live state
  promises the VM-24 decision "leads the handoff" and it is not there yet — and `notes/MobileSoul.md` PL-75
  ("Batch C — PENDING(window 3)", "VM-16 … PENDING"). They are marked drafts and the orchestrator knows; named
  here because one of them is canon on the branch. A gate line worth having:
  `grep -n PENDING notes/MobileSoul.md notes/SurfaceContracts.md` answers nothing before the merge.
- **R3-N3 · `MobileFanBadgePlacementProbeTests.swift:57-60` and `:86-88`.** The header still ends "All green ⇒
  hollow: this stays as the guard"; the member is real and this is its pin. `seedLongFannedNote`'s optional
  `fanEvery` has one caller left. Both ride batch D's fix commit, not a commit of their own.

## What is still owed (round 1's F1, as ruled — not a new finding)

This round read, as new work, window (3)'s outcome, the instruments' removal, reading (i′) and its run, R2-N1's
fix with its red and green, R2-F2's lines in use, the orchestrator's decisions on VM-24 and VM-17, batch D's
trace and its instrument. Two things do not exist yet and so were not read: **VM-17's fix** — a product change
in the takes chrome, and by batch D's own options possibly a geometry helper in `MobileEditorTextView.swift`,
which is the editor-seam class — and **VM-16 re-landed** on main's message seam. A further fresh round reads
both. Two rounds remain under tonight's cap; sequencing the merge behind vm-55 and batch D so that ONE round
reads both spends one of them. Still pending by the record's own account: the settle instrument's window, the
walk, the whole phone target, the Mac leg on the merged tree, the closeout.

## The clean bill — what I checked and found solid

- **Nothing outside `App/Variorum/` and `notes/`.** No `Sync/`, custody, schema or core line. Every write the
  changed doors make is an existing operation (`restoreCommit`, `lockReading`, `unlockReading`,
  `unarchiveReading`, `deleteReading`, `collectPostIntoSmartReading`, `setStarred`), so S1–S5 and I1–I10 are
  untouched. Nothing new scales with the corpus; nothing tracks word-level change or copies text across
  entities.
- **Window (3), against its logs.** Every row of the record's matrix matches its log's verdict line and named
  reds: M1, M6a, M6b the two caret cases at `:215` and no other; M2, M3, M4 green; M5 and M5b three issues at
  `:394`, `:396`, `:398`, their `VM17|` geometry lines identical line for line; M7 22 tests with only M1's two
  reds, every liveness test green; M9-red exactly the VM-19 expectation at `:1087`, M9-green 18 of 18. No
  `Restarting after unexpected exit` in any of them. The three bundles I opened read as the record says.
- **VM-24 — the trace and the decision.** M2's eighteen verdict lines say what the record says: no gate
  consult on any act, no write inside the transaction, and the red following the report's range (widened in
  five of six suite-posture acts, exact in all six real-posture acts, four of six with the settle held). I
  traced the routing myself: an exact `{1,2}` gives `fallbackVerdict` the old range `(1,5)` → block 0; a widened
  `{1,5}` gives `(1,8)`, which reaches the separator → `.refuse` → `desyncRecovery`, before `recordAutosave`
  (`MobileEditorViewModel.swift:1882-1932`, `:1962-1972`, `:2011-2032`). So the orchestrator's decision stands
  on the record's own rules: no pre-decided arm mapped (both of R2-F2's lines were met), arm A's wait would
  turn the test green by changing when the replace runs and remove nothing, and the mechanism is in the
  product's edit routing. Leaving the red test red and unwrapped as the pin, writing no seam line, and holding
  the fix for the author is what CLAUDE.md asks. Stored text is not at risk on this road, as the write-up says
  (the refusal returns before the autosave is recorded; the recovery flushes what was already pending). R3-F5
  is a precision on its reach, not a disagreement.
- **VM-19.** The pin is red on the hide-only teardown and green on the fix; the desync did not reproduce in any
  of M4's four cases; the record calls the pin test hygiene and does not claim more.
- **The instruments' removal** (`16c75a5bf`). `MobileCaretReplaceTraceTests.swift` is gone whole and the cost
  note is out of the probe; nothing in the tree names a removed type except one comment that points at
  history; the phone test build after it succeeded. Their numbers are in the record (reading 2's, the cost
  note's four lines).
- **Batch D's trace, against M5.** 35 (i) lines: 24 carry their block's exact load value (I matched each to its
  `VM17|load|` line) and 11 stand exactly 74.0 pt above a line that equals the idealized layout; the 9 bare
  lines are nine of those eleven; the jump road is clean. The reading — a stale off-band frame from the load,
  and an in-band read taken before TextKit lays out the new viewport — fits every line I checked, and stopping
  before code was the brief's own rule. R3-F2 and R3-F4 add to it; they do not overturn it.
- **R2-N1's fix.** Four rows, each hint the caption the row already draws, the verb still the label; the
  Unarchive row gives no hint when it draws no sentence. Proved by its window.
- **The whole diff, re-read for what two rounds might have passed.** VM-16: the Mac door's three arms in both
  directions, over `undoReporting` / `redoReporting`, whose quiet half retires its entry and leaves the other
  stack alone — the fix's premise, read in `UndoStack.swift:356-402`; no other reader of `undo(with:)` on the
  phone. VM-43: one `restoreCommit` call under `VariorumMobile/` and `Shared/`, flush first, the insurance
  inside the op. VM-84: `entryDate` set at the one place `header` is assigned; the only other view read of
  `header` is a point-in-time read inside a tap. VM-33: the flag lowered at restart, raised only by a value.
  VM-81: the confirm's N is the dismissal's own predicate; the archived book resolves through a
  tombstone-tolerant read; `refusal` forwards the two cases it names. VM-83: `BookcaseBoard.ordered` over the
  union star; the create sheet's kind row keeps its order (`BookKind`'s declaration order is unchanged). VM-21:
  the Mac chip's composer. The hoists: the Mac files extend the shared enums and the moved lines are
  byte-identical. Of the pins I read in full (the undo door's three, the restore's two, the Trash's two, the
  date chip's, the Finish confirm's six, the archived book's two, the hints'), the red-on-old ones fail on the
  old code by assertion, the controls are real controls, and none is vacuous.
- **Canon as drafted.** The five SurfaceContracts clauses are each true of what is built and each is one
  clause in place with one pointer — no date, no words of hers, no ladder tally (the two-file rule). The
  shared ledgers are untouched on the branch, as the rule asks.
- **Commits since round 2.** One piece each, the revert in flight announced and closed in LIVE STATUS around
  M9, no trailer, no home path, no device id, no test wrapped as a known issue, public wording.
