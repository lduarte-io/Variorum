# 18l-b U3 — Fable cold review, ladder ROUND 1 (2026-09-27)

**Reviewer:** `fable-reviewer` (Fable 5, xhigh), zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
**Diff under review:** `545375bc..43031072` (code = `App/`, `Tools/`) — what SHIPS (the rider's observation
seam on `PaneSurface.swift`, `PaneRenderRestoreClipTests` new, the VisualWalk `SCN_ORDER`/README fixture fix)
**plus** the built-then-reverted pair `8a93eb24` + `e113dd56` (reverted whole at `b60e5d6d`) for the revert's
completeness and the record's truthfulness. Anchors read in own context: the U3 BRIEF / U3 RECORD / acceptance
(`notes/plans/phase-18l-b-navigation-feel.md`), the charter's KICKOFF 2 U3 bullet (`post-13u-health-rounds.md`),
health review §5.1 A1, `TEXTKIT2_NOTES.md` in full, KnownIssues rows 85/88/92/95/97, QUESTIONS #152,
`PaneSurface.swift` (the publisher, `PaneMeasurement`, the coordinator, the restore), the 545375bc baseline of
the same, both scenarios/README files and their history. No "Review foci" section exists for this unit
(grep-verified); the SEAM FILES table was read first as it asks.

---

## FINDINGS (severity-ranked)

### MINOR-1 · notes/QUESTIONS.md:1951 (#152, the "Recoverable exactly" paragraph) · the author's overturn instruction is a garbled sentence

- **What:** the fork's action line for overturning the felt gate reads *"If you rule the 50–83 ms not felt,
  say so and (the shape returns as built)."* — "say so and (…)" dangles; the parenthetical swallowed the
  clause. This is the exact line the author acts on if she overturns the gate, on her own decision surface.
- **Evidence:** read directly; every other sentence in #152 parses. The intended content is unambiguous from
  the record (JC 1: *"Reverse by her judging it not felt: the shape is recoverable exactly
  (`e113dd56` + `8a93eb24`), its pins included"*), so the slip is real but recoverable.
- **Class:** doc/clarity — no pin (nothing executable); the hallucination guard's written-justification arm:
  the degradation is a mis-read instruction at an author fork.
- **Fix:** one sentence, e.g. *"If you rule the 50–83 ms not felt, say so and the shape returns exactly as
  built (`e113dd56` + `8a93eb24`, pins included)."*
- **VERDICT (round 1, pre-dispute):** CONFIRMED, doc-only.

### NIT-1 · App/Variorum/Variorum/Surface/PaneSurface.swift:549 · the tripwire's `clipShift` parameter is defaulted to 0 with exactly one caller

- **What:** `func noteRenderRestore(clipShift: CGFloat = 0)` — the one caller (the restore at :1764) always
  passes a measured shift, and no test calls it bare (grep: zero other callers app- and test-side). The
  default invites a FUTURE second `layoutViewport()` road to call `noteRenderRestore()` and compile silently
  while recording shift 0 — quietly narrowing the very tripwire TK2 §5's point-release re-verify leans on
  (`lastRenderRestoreClipShift` would read a false clean 0 and even overwrite a just-recorded real shift;
  `largest` survives, being monotonic).
- **Evidence:** traced hazard, not a bug today — no input on this tree produces a wrong value. No red-on-old
  pin can exist (nothing misbehaves); labeled honestly as a hardening.
- **Fix:** drop the default; every caller states its shift.
- **VERDICT:** CONFIRMED as a hardening NIT.

### NIT-2 (SPECULATIVE) · App/Variorum/Variorum/Surface/PaneSurface.swift:1765 · `zip(clipsBefore, clipsAfter)` drops unpaired clips on a count change across the call

- **What:** if a viewport-layout pass ever added/removed an enclosing `NSClipView` between the two reads, the
  zipped max would ignore the unpaired entry and could record 0. Mechanism NOT traceable today: the pane's
  `layoutViewport()` draws fragments and cannot restructure its SwiftUI ancestors, and road 1's pin compares
  the full arrays (`enclosingClipOrigins() == clipsBefore`), which does catch a count change on that road.
- **Fix (if taken):** treat a count mismatch as a recorded shift (or leave as is — the pins carry the teeth).
- **VERDICT:** SPECULATIVE — record, take only if the implementer agrees it's free.

### NIT-3 (SPECULATIVE) · App/Variorum/VariorumTests/PaneRenderRestoreClipTests.swift:124–128 · `onTheBoard` tears down without emptying the mounted storages

- **What:** TK2 §3's 18k C8 finding records that a mounted editor dropped under an async test body can outlive
  its test on the runner's main-thread autorelease pool, and content-equal attribute dictionaries are uniqued
  PROCESS-WIDE — able to flip a later suite's attribute-fixing answer (`IdentityProjectionAuditTests` lives in
  this same target). `onTheBoard` cancels/tears down/orders out but does not empty the panes' storages; road 2
  leaves a `paragraphTall`-styled storage behind, the adversarial arm a 22-pt-font one.
- **Evidence of non-impact today:** the 191-suite closing run (`18lb-u3-closing1.log`) is green with this suite
  in it; sibling board suites (e.g. `TakePaneMeasureTests`) follow the same teardown shape. No traced victim —
  hence SPECULATIVE, hygiene only.
- **Fix (if taken):** `setAttributedString(NSAttributedString())` on the mounted panes in the defer (the
  `AutosaveRegistryLifecycleTests:165` pattern).
- **VERDICT:** SPECULATIVE — record; take at will.

**No BLOCKER. No MAJOR.** Nothing in this diff tracks word-level change, copies text across entities, or
scales with corpus size. No pin-hollow findings raised: none of the above is a bug-class finding; the two
NIT hardenings and the doc fix need no red-on-old pin by class (stated per the guard).

---

## THE BUILT-THEN-REVERTED PAIR (completeness + truthfulness — verified, not trusted)

1. **Revert completeness — VERIFIED at the byte level.** The pair touched exactly three code files
   (`PaneSurface.swift`, `PanePublishShapeTests.swift` new, `PaneSurfaceTests.swift`) plus plan notes.
   At `43031072`: `git diff 545375bc..HEAD -- PaneSurfaceTests.swift` is EMPTY; a full-file diff of
   `PaneSurface.swift` against `545375bc` shows ONLY the rider's observation seam (re-derived independently,
   not read off the record); `PanePublishShapeTests.swift` absent from tree, project (file-system-synchronized
   groups — zero dangling pbxproj references), and the closing script. No leftover of the flagged-shape seam
   (`representableUpdateDepth` / `stateWritesInsideUpdate` / the `writeHeight` wrapper: grep 0). The shipped
   publisher docs are the pre-U3 synchronous-write reasoning again — coherent with shipped behavior.
2. **Record truthfulness — the load-bearing claims each located and re-verified:**
   - Set B numbers from the logs themselves: **1,106 · 1,106 (before) → 0 · 0 (shape) → 1,106 (reverted)**,
     187/39 passed in all five (`18lb-u3-setB-{before,before2,after,after2,reverted}.log`); the 191-suite
     runs: blast **0 warnings / 1115 failed-with-6-issues** (the two pointer suites), closing
     **2,393 warnings / 1114 passed**. Exactly as recorded, including the honest "whole family, not the
     majority" upgrade of the A1 hypothesis.
   - Red-first: `18lb-u3-redfirst.log` fails EXACTLY the four new pins (names extracted from the log —
     frame-now, burst, heal, mounted mechanism), 12 issues. The named behavioural revert:
     `18lb-u3-R-sync.log` fails EXACTLY the predicted nine (the four new pins + the five sanctioned
     `PanePublishDoorTests` edits, names extracted), 19 issues, 17 green. The sanction rule the brief set
     (an edit only where the pin's own text pinned the sync write) is met by the five named edits — read in
     `e113dd56`'s hunks.
   - The shape's mechanism as recorded matches `e113dd56`'s actual diff: `publishHeight`'s one changed line
     (`writeHeight?(height)` → `applyFrame?(height)`), docs restated, canary kept synchronous with the reason
     in its doc, `PaneMeasurement` untouched, callers byte-unchanged.
   - The rider's numbers are byte-identical between the record and `18lb-u3-rider2.log`'s own prints
     (road 1 clips 2094→2094 / visible 2074→2074 / shift 0; road 2 frame 2753→3617 / largest 0;
     adversarial fragments 2055→2080 under fixed frame 2753 and fixed clip 2094). Post-revert 25/3 green
     read from `18lb-u3-reverted1.log`.
   - The felt-gate evidence exists on disk (`vis-walks/2026-09-27/{043958…045302,051016,051702}`,
     `18l-screens/18lb-u3/` classifiers + per-act jsonl + the Compare A/B PNGs); the 5/5-vs-0/5 arithmetic is
     internally consistent (4/4 mount repeats + 1 in the breadth walk).
3. **The revert was the right shape.** Deleting `PanePublishShapeTests` with the revert is correct — it pins
   the reverted contract and would be red on what ships; it stays recoverable at the named hashes. Taking the
   flagged-shape observation seam out with it is correct (a seam with no consumer). Keeping the rider seam +
   pins through the revert is correct — their subject (the restore) is independent of the publisher shape, and
   the numbers proving that are in the log.

## THE FIXTURE FIX (Tools/) — verified

- The order claim is TRUE against history: the pre-U1 (U-VIS) `SCN_ORDER` is exactly today's prefix before
  `read-landing` (checked at `905ee936~1` vs `43031072`), so B5 again runs on the recipe row 88 measured —
  the reason a ⌘↑ reset was refused (it would rewrite an untraced bug's recipe) is sound and the reversal is
  named (JC 4). `takes-landing`'s order-independence claim verified in `scn_takes-landing` (the conditional
  relaunch fires in both orders). The proof runs verify from their own reports: `052516` Terminal 13/13 with
  `b5-return-after-cmd-down` PASS (the ERROR gone), Study XFAIL = S3 ×2 + B5 (the measured recipe still
  reproduces B5 — the fix did not rewrite it), ONE Study FAIL (the intermittent `read-landing` 245-cold
  signpost miss), reproduced clean in `055414` and `060002`. The miss is honestly filed (KnownIssues 97,
  owner 12, U2's FP-2 named as the remedy) rather than argued away.
- Residual noted, no finding: the README row's "(RL_FACES orders them; the first is truly cold)" now
  coexists with B5's Write opens preceding the scenario — the FACE-cold claim still holds (B5 mounts Write's
  full-document editor, not Read's faces), and the warmer note state is stated at the SCN_ORDER comment and
  in the record's costs. Nothing misleads.

## THE RIDER'S VERDICT — checked against the code, found sound

- Ground 1 traced myself: `makeSurface` sets `isVerticallyResizable = false` (:773, the only write); panes are
  representable views inside SwiftUI scroll hosts, never an `NSScrollView`'s document — so the 18k C6 driver
  (the pass resizing the scroll DOCUMENT it lays out) cannot exist on a pane, and the adversarial arm measures
  exactly that (real unmeasured geometry change, frame and clip fixed). Ground 2 traced myself:
  `reconvergeIfDiverged` measures via `PaneMeasurement` (`.ensuresLayout` over the pane-scale document,
  :132–141) before `scheduleRenderRestore`; the re-font branch re-attributes → `remeasure()` →
  `restoreRenderTier()` (:1265–1285). The app's only `layoutViewport()` callers are this restore and
  `JumpPrimitive` (grep — the B5 report's premise), and `moveToEndOfDocument` is not overridden (grep).
- The pins are declared GUARDS, green on both sides BY CONSTRUCTION and labeled so in the record — correct
  under the hallucination guard (the verdict is SAFE; there is no red-on-old to have). Non-vacuity is asserted
  inside each pin (restore ran; geometry really changed), so they cannot rot into vacuous greens.
- The TK2 §3 canon line landed (TEXTKIT2_NOTES.md:155) matches the record's draft and is scoped honestly to
  27.0 with the §5 re-verify posture.
- Coverage note (no finding): the pins exercise the one-clip shape (`[2094.0]`); the doc's two-clip rail-card
  shape (capped wrapper) is unexercised — acceptable because both grounds are shape-independent, but a future
  re-verify could add it cheaply.

## CLEAN BILL (checked and found solid)

1. The shipped `PaneSurface.swift` seam is observation-only: pure reads (`enclosingClipOrigins`), two stored
   CGFloats, the restore's call/gating/latch byte-unchanged; both reads happen synchronously inside one
   deferred block, so no user scroll can interleave between them. Cost as stated: O(hierarchy depth) ×2 per
   coalesced restore, zero at rest, nothing at keystroke rate — P1/P3 honest.
2. `PanePublisher` and `PaneSurfaceTests.swift` byte-identical to `545375bc` (re-diffed, not trusted);
   the one pre-existing doc the shape would have staled ("sync-write + bounded-heal discipline") is true
   again — NOTICED 4's claim verified.
3. The measurement discipline: same command before/after/reverted, deterministic counts, zero-instance
   windows claimed and consistent with the logs' HID notes; the pointer-suite blast reds correctly attributed
   to row 92's class (idle re-run green in the closing log) and the row amended with the new suite name.
4. Dispositions complete: ledger rows 4/5/6/8 all dispositioned; row 85 NOT-TAKEN with the honest one-line
   reason plus the walked ring consequence; row 88 re-owned to U-B5 (not silently dropped — the charter's own
   rule); KnownIssues 95/96/97 + row 92 amendment landed as the acceptance says; QUESTIONS #152 files the
   fork for HER (no product behavior invented; the felt gate honored to her sentence's letter). Nothing this
   unit owned is left unowned.
5. The B5 report stays a REPORT (the ruling was the orchestrator's, per the roster); its three factual premises
   (different surface, no app-side `layoutViewport()` on the road, opposite symptom) each check against code
   and row 88's measurements.
6. Commits: 15 in range, no trailers, pushed, main == origin/main; staging pathspec-limited by inspection of
   the per-commit stats; the record was kept LIVE-STATUS-first per the resiliency protocol.
7. Suite evidence accepted from four independent green runs of the rider pins on the shipped tree
   (`rider1`, `rider2`, `reverted1`, `closing1` — the last two on exactly what ships) rather than a fifth
   re-run from this seat: the author may be at the machine this morning, the suite mounts real windows, and
   the logs' printed numbers are byte-consistent across runs. (The environment traps' own preference.)

## ROUND-1 CLOSE

Findings to the implementer verbatim: **MINOR-1, NIT-1, NIT-2 (SPECULATIVE), NIT-3 (SPECULATIVE)** — no
BLOCKER, no MAJOR. Under the cross-model flow the implementer's agree/dispute returns to this reviewer, which
makes the final call and implements the confirmed fixes itself (MINOR-1 is doc-only; NIT-1 is a one-line
signature hardening whose only callers are in-diff; NIT-2/NIT-3 are take-or-record). None of the four gates
the unit's CLOSED-AS-REVERTED disposition, which this review AFFIRMS as recorded.

---

## IMPLEMENTER RESPONSES (round 1)

*(`opus-implementer`, 2026-09-27 — each claim re-checked at the source on `57a88c7f`; I implement nothing, the
reviewer makes the final call and implements its confirmed fixes.)*

### MINOR-1 — AGREE

Verified: `notes/QUESTIONS.md:1951` reads *"If you rule the 50–83 ms not felt, say so and (the shape returns as
built)."* — the parenthetical swallows the clause, exactly as found. Not my pen, but the fix is right.
**Refinement for the reviewer to weigh:** the overturn can be stated as ONE act, and I checked it rather than
asserting it — in a scratch worktree at `57a88c7f`, `git revert --no-commit b60e5d6d` applies CLEANLY and
restores exactly the built shape: `publishHeight` back on the lever (`applyFrame?(height)` count 1 → 2), the
flagged-shape seam back (`representableUpdateDepth` 0 → 7 hits), `PanePublishShapeTests.swift` re-added and
`PaneSurfaceTests.swift` both BYTE-IDENTICAL to `e113dd56` (`git diff e113dd56` of the two: empty), while the
rider's seam is KEPT (`enclosingClipOrigins` 3 hits). Worktree removed after. So a sentence like: *"If you rule
the 50–83 ms not felt, say so and the shape returns exactly as built (`e113dd56` + `8a93eb24`, pins included —
one `git revert b60e5d6d`, verified clean on today's tree)."*

### NIT-1 — AGREE

Verified: `PaneSurface.swift:549` `func noteRenderRestore(clipShift: CGFloat = 0)`; the ONLY caller is the
restore at `:1764`, which always passes a measured shift; zero callers in `VariorumTests/`, `Tools/` or anywhere
else in `App/` (grep). The hazard is as stated — a future bare `noteRenderRestore()` from a second viewport road
would compile and overwrite `lastRenderRestoreClipShift` with a false 0 (`largest…` survives, monotonic). The
default was mine and buys nothing. **Refinements:** (a) dropping it touches no other site — the one caller already
passes the argument, and the existing `renderRestoresRun` readers (the A47c pin, `aGapOrVoiceChangeRestores…`)
read the counter, not the call; (b) the U3 RECORD's SEAM FILES table says *"`noteRenderRestore(clipShift:)`
(default 0 — the one caller passes the shift)"* — that cell goes stale with the fix and wants the same edit.

### NIT-2 (SPECULATIVE) — AGREE it is unreachable today; taking it is free — my lean is TAKE

Verified the mechanism the reviewer could not trace, and it is stronger than "not traceable": `enclosingClipOrigins`
walks SUPERVIEWS only, while `layoutViewport()` creates and discards rendering surfaces BELOW the text view (its
own fragment views/layers) and cannot restructure its ancestors; and both reads sit synchronously inside one
main-queue block, so no SwiftUI update (the only thing that could re-parent the pane) can run between them. A
count change is therefore not producible on this tree. It is still worth the one expression, because the seam's
doc promises *"how far the render restore's `layoutViewport()` moved ANY clip"* and the tripwire exists for a
point release doing what today's reasoning says it cannot. **If taken:** make a count mismatch LOUD rather than a
shift — e.g. `clipsBefore.count == clipsAfter.count ? (zip(…).map { abs($1 - $0) }.max() ?? 0) : .infinity` —
so the three pins' `== 0` assertions red on it and `largestRenderRestoreClipShift` keeps it (monotonic). Road 1's
full-array compare already catches it on that road, as the reviewer notes; roads 2 and the adversarial arm read
the recorded shift, so this is what gives them the same teeth.

### NIT-3 (SPECULATIVE) — AGREE as hygiene; my lean is RECORD against KnownIssues row 91, not a one-rig patch

Verified: `onTheBoard`'s `defer` (`PaneRenderRestoreClipTests.swift:124–128`) cancels the observation, tears the
model down and orders the window out, and empties no storage; the cited pattern
(`AutosaveRegistryLifecycleTests.swift:161–166`) detaches the delegates FIRST, then `setAttributedString(
NSAttributedString())`. Three facts the reviewer should weigh: (a) **the class is already OWNED** — KnownIssues
row 91 (owner 12) records exactly this ("the CLASS remains for any other harness that drops a typed-and-stamped
editor … Remedy: the same teardown in the shared editor harnesses"); (b) **this rig sits OUTSIDE that row's
stated trigger** — it types into no pane and stamps no block identity (panes carry no `BlockRangeIndex`); what it
leaves behind is road 2's re-attributed paragraph styles and the adversarial arm's 22-pt font on the long pane —
weaker than C8's traced instance, and no victim traced (the 191-suite closing run is green with the suite in it);
(c) **the sibling board rigs share the same teardown shape** (`TakePaneMeasureTests`' A47c pin — `window.orderOut`
only, `:547`; `TakesCardHeightTests.withBoard`), so fixing one rig does not close the class. **If the reviewer
takes it anyway:** empty EVERY `PaneTextView` in the hosting tree (the board mounts several panes, and road 2
re-attributes all of them), and detach each pane's `delegate` before emptying, in the helper's order — a direct
storage edit does not call `didChangeText`, so no `onEdit` would fire either way, but the order is the canon's
("detach delegates, empty the storage") and costs nothing.

**Summary:** MINOR-1 AGREE (+ the verified one-command overturn) · NIT-1 AGREE (+ the record cell that goes
stale) · NIT-2 AGREE-unreachable, lean TAKE with a loud mismatch · NIT-3 AGREE-hygiene, lean RECORD against row 91
(if taken: every pane, delegates first). Nothing here disputes the reviewer's CLOSED-AS-REVERTED affirmation.

---

## ROUND 1 FINAL CALLS + FIXES

*(`fable-reviewer`, 2026-09-27 — the cross-model flow's closing pass: the implementer's 4 AGREE / 0 DISPUTE
weighed, each refinement RE-VERIFIED at the source by this seat before adoption, the confirmed fixes
implemented by this seat, committed per fix, no trailers.)*

| Finding | Final call | Fix | Hash |
|---|---|---|---|
| MINOR-1 (#152's garbled overturn sentence) | **CONFIRMED — FIXED, doc-only**, ADOPTING the implementer's one-command refinement after re-verifying it myself on the POST-FIX tree (the implementer's check was on `57a88c7f`; mine on `04a30237`, which supersedes it): in a scratch worktree, `git revert --no-commit b60e5d6d` applies CLEAN — `PanePublishShapeTests` + `PaneSurfaceTests` byte-identical to `e113dd56` (diff 0 lines), `applyFrame?(height)` count 2, `representableUpdateDepth` 7 hits, the rider seam kept (3 hits), and BOTH round-1 hardenings survive the revert (their sites sit outside every `b60e5d6d` hunk context — post-image hunks end at :566/:1676; the edits sit at :549/:1761+). Worktree removed after. | #152's sentence now names the act: *"one `git revert b60e5d6d` (verified clean on the round-1 tree, `04a30237` …)"* | `ec998abf` |
| NIT-1 (defaulted `clipShift`) | **CONFIRMED — TAKEN.** The default bought nothing (zero bare callers, grep re-run) and weakened the tripwire. The stale-cell question the coordinator posed is ruled as an OPEN amendment: the U3 record's seam-files cell keeps its original text and gains a dated bracket naming this round's change — never a silent history edit. | `noteRenderRestore(clipShift: CGFloat)` — required; the record cell amended in place with the bracket *[amended at ladder round 1, NIT-1 …]* | `e99e3d88` |
| NIT-2 (zip truncation on a clip-count change) | **TAKEN** — upgraded from record-only on the implementer's firmer ground, which I verified against the code: `enclosingClipOrigins` walks SUPERVIEWS only while `layoutViewport()` builds rendering surfaces BELOW the text view, and both reads share one synchronous main-queue block, so a count change is unreachable today — which is exactly the tripwire's business (a point release doing what today's reasoning says it cannot). The loud shape: a count mismatch records `.infinity`, never a zipped 0, so all three pins' `== 0` arms red on it and `largest…` keeps it (monotonic). The adversarial arm's local computation mirrors the same rule. The restore's call, gating and latch are byte-unchanged (the no-restore-body constraint honored: only this unit's own observation expression moved). | the guarded expression at the seam + the test mirror | `04a30237` |
| NIT-3 (`onTheBoard` teardown vs the C8 class) | **RECORDED, NOT TAKEN** — the implementer's three grounds each verified: KnownIssues **row 91 already owns the class** (owner 12: *"the CLASS remains for any other harness that drops a typed-and-stamped editor … Remedy: the same teardown in the shared editor harnesses"*); this rig sits OUTSIDE the row's stated trigger (it types into no pane and stamps no block identity — panes carry no `BlockRangeIndex`); and the sibling board rigs (`TakePaneMeasureTests`' A47c pin, `TakesCardHeightTests.withBoard`) share the same teardown shape, so a one-rig patch would not close the class while suggesting it had. No traced victim exists (the 191-suite closing run green with this suite in it). Disposition: this paragraph IS the record; row 91's remedy covers the rig when 12 takes the class. | none (recorded) | — |

**Suite proof (this pass, zero app instances, HID idle 1,788 s at start):** the four touched/adjacent suites —
`PaneRenderRestoreClipTests` · `PanePublishDoorTests` · `PaneSurfaceTests` · `TakePaneMeasureTests` —
**`Test run with 36 tests in 4 suites passed after 16.413 seconds`**, EXIT 0
(`App/Variorum/DerivedData/18lb-u3-ladder-r1-fixes.log`). The rider's printed numbers are byte-identical to the
U3 record's (road 1 clips 2094 → 2094 / visible 2074 → 2074 / shift 0; road 2 frame 2753 → 3617 / largest 0;
adversarial fragments 2055 → 2080 under fixed frame and clip) — the hardenings changed no behavior. The 68
`Modifying state` lines in the 4-suite log are the standing family (the revert stands; set B's 1,106 baseline
unaffected by this pass).

**ROUND 2 VERDICT: NOT EARNED.** No new BLOCKER or MAJOR arose in the responses or the fix pass; all four
round-1 findings are dispositioned (2 fixed + 1 fixed doc-only + 1 recorded); the unit's CLOSED-AS-REVERTED
disposition stands AFFIRMED. Remaining per the flow: the implementer's one sanity pass over this seat's fix
diff (`e99e3d88` + `04a30237` + `ec998abf`); anything it raises returns here for the final word.
