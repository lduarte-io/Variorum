# 18l-b U-B5 — Fable cold review, ladder round 1 (2026-09-27)

**Reviewer:** `fable-reviewer` (cold, zero implementation context; `notes/REVIEW_PROMPT.md` run verbatim).
**Diff under review:** `b811760a..34622758`, code = `App/`, `Tools/` (4 code files, 2 harness files; the
only `notes/` change in the range is this unit's own plan record — verified by `git diff --stat`, no
canon file touched). **Anchor docs read whole in this session:** the U-B5 BRIEF + RECORD + first-pass
acceptance, the U3 RECORD's THE B5 REPORT, KnownIssues rows 88/85, TEXTKIT2_NOTES (whole), the 18l-b
kickoff/ledger/traps, and the code itself: `applyStructuralResult` / `applyDifferentialStructural` /
`runStructural`, `keepUntouchedReadingLine` + `readingAnchor` + `topVisibleOffset`, `ReadingAnchor` +
`lineSpan` + `jump` (whole file), `StructuralSeamEdit.derive` (whole file), `applySeamEdit`,
`updateCaretContext`, `insertEmptyBlock`, the new test file, and both harness files.

**Verification runs made by this reviewer** (machine author-free — HID idle 886 s at the check; zero
app instances by pgrep; no GUI driven): `zsh -n Tools/VisualWalk/scenarios.zsh` (clean); the two new
suites run first-hand — `WriteFloatingViewportTests` + `UntouchedLineKeeperTests`: **4 tests / 2
suites PASSED** on the shipped tree. Evidence logs read from disk, not trusted from the record:
`18lb-ub5-pin-prefix{1,2}.log` (the pin RED pre-fix, Study 80.0 pt, 2/2), `18lb-ub5-R-keep.log`
(**exactly the 3 predicted issues** — the pin's Study case 80.0 pt + the witness test's two),
`18lb-ub5-D1.log` (GREEN — the pre-18c full-re-render road holds the line), `18lb-ub5-D2.log` (ring
off ⇒ **premises fail, not the line**: floating = 40 where 0 is required, usage +30.0 vs > 66 —
byte-consistent with the record), `18lb-ub5-closing1.log` (`Test run with 1019 tests in 154 suites
passed`, `** TEST SUCCEEDED **`), `18lb-ub5-release-compile.log` (`BUILD SUCCEEDED`), and the walk
reports `vis-walks/2026-09-27/121540/report.md` (both voices 15/15, 0 FAIL/0 ERROR/0 XPASS, XFAIL 4
= S3 ×4 only, `b5-return-after-cmd-down` PASS plain in Study) and `125735/report.md` (the R-keep
scratch build: `b5-return-after-cmd-down` **FAIL**, first visible line 45591 → 44477 — the teeth are
real). Commit hygiene verified: 14 commits, no trailers, tree clean, HEAD == origin/main.

---

## FINDINGS (severity-ranked; format: [severity] · where · what · evidence · fix)

**F1 · MINOR · `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift:3076–3084`
(the structural door's header doc) · the door's contract sentence is now false and contradicts the
paragraph this diff added four lines below it.**
The header still reads *"the everyday gestures apply DIFFERENTIALLY (minimal text edits derived from
the op result's known seams — untouched text never moves, no scroll restore step exists at all)"* —
the 2026-07-07 directive's words — while the new paragraph directly under it describes the keeper's
conditional restore step, and the code now has one (`keepUntouchedReadingLine`, called at :3113).
Evidence: read the two paragraphs; the first clause ("untouched text never moves") is the PROMISE the
keeper enforces, the second ("no scroll restore step exists at all") is a factual statement the diff
falsified. Traced degradation (clarity class — no pin owed, justification instead): this header is
the ONE structural rewrite door's contract statement, echoed by `StructuralSeamEdit.swift`'s header
and `ReadingAnchor`'s doc; a future session reading the first paragraph as the standing directive
would classify the keeper as drift against a ruled decision — the exact confusion the repo's
spec-outranks-code rule exists to prevent, pointed the wrong way. Fix: amend the parenthetical to
date the directive and hand off to the keeper paragraph, e.g. *"untouched text never moves — the
2026-07-07 promise; no unconditional restore step, and since 18l-b U-B5 the keeper below puts the
untouched reading line back iff TextKit moved it (KnownIssues row 88)"*. One sentence, no behavior.

**F2 · NIT · `Tools/VisualWalk/README.md:542–543` · two scenario rows now claim "Runs LAST".**
`book-landings`' row still ends "Runs LAST" (true at U4); the new `b5-more-roads` row also says
"Runs LAST" and actually is (SCN_ORDER, `scenarios.zsh:650–653`). The scenarios file's own order
comment is honest ("`b5-more-roads` appended after it, for the same reason"); the README drifted one
unit behind. Fix: amend `book-landings`' row (e.g. "Runs after `takes-landing`").

**F3 · NIT · `App/Variorum/VariorumTests/WriteFloatingViewportTests.swift:310–315, 440–446` · the
pin hard-codes entry indices 144/150 into the bundled Scandal fixture with no `#require` on the
entry count.** `index.range(ofEntryAt:)` on an out-of-range index TRAPS (array subscript), so a
future change to the bundled sample text would crash the suite instead of failing with a named
premise. The fixture is deliberately stable, and every OTHER premise in the file is `#require`/
`#expect`-guarded — this is the one unguarded assumption. Cheap hardening at the next touch:
`try #require(h.model.index.entries.count > 150)` after seeding. Not worth a fix commit on its own.

**No BLOCKER. No MAJOR.** I looked specifically for the failure classes this diff could plausibly
carry and traced each to a non-finding — the list is in the clean bill.

---

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The traced mechanism is corroborated by the code, not just the record.** The R1-1 depth-guard
   comment (`EditorViewModel.swift:3570–3584`) independently documents the in-edit decoration-walk
   hazard and why the guard reads depth 0 on TextKit's selection-fix road; `applySeamEdit` (:914)
   has no restore step; `applyStructuralResult` is the ONE caller-facing rewrite door (single call
   site, `runStructural:3057`); the differential road's promise and its violation are exactly as
   the trace states. The instrument (`B5Trace`, the scratch rig) is NOT in the shipped tree —
   verified by the diff; the shipped `EditorTextView` has no `setSelectedRanges` override (the
   trace's stack came from the instrumented working tree, as the record honestly says).
2. **The keeper's fence is correct per seam kind — checked against `StructuralSeamEdit.derive`
   itself.** `edit.replaceRange.location` is pre-edit and is the true edit start for every seam:
   divide = the cut point; extract-prefix = the source block's START (so the typed Return's `.above`
   arm — an empty block pushed in above — correctly counts as the act's own movement for a reading
   line at that block); extract-suffix / makeBlock = the retained prefix's end; merge =
   `lead.upperBound` (a reading line inside the lead block is genuinely unmoved by the act — its
   bytes and its paragraph-start-keyed markdown face are untouched; only the blockID attribute
   changes, which is layout-neutral). `isUntouched` is strict `<`, and offsets below the edit start
   survive the edit unchanged, so the post-edit `lineSpan(anchor.offset)` addresses the same text
   by construction.
3. **Nothing deliberately scrolls between the capture and the keep** — the hazard that would make
   the keeper revert an intended move. Checked: `setSelectedRange` (programmatic, no scroll),
   `updateCaretContext` (no scroll), `applySeamEdit`/`adoptRewrite`/`refreshBadges` (no scroll), no
   reveal exists on the differential road (`scrollRangeToVisible` callers are elsewhere), and the
   whole window is one synchronous main-thread turn (no user event can interleave). A post-flight
   reveal would run after the keeper and win — the right priority.
4. **The keeper cannot touch the caret or emit an operation** — it moves only the clip through
   `JumpPrimitive.jump` (the bounded primitive, ≤ 6 viewport layouts, with 18k C6's clip re-assert).
   The U0b product fence (the caret's resting rule is SHIPPED) is honored; sync never learns the
   keeper exists (S1 untouched — no store write anywhere in it).
5. **The escape road that remains is honestly owned, not missed:** `applyPendingIfClean` runs AFTER
   the keep (JC 4 — deliberately, so deferred projections can't re-map the anchor), and a deferred
   projection's restore-less `applyDifferential` rewrite on a floating viewport is exactly the
   unit's NOTICED 2, drafted for owner 12. The keeper's placement covers every forcing read of the
   act's own turn (the in-edit walk, the post-edit badge/decoration refresh, the caret-context
   refresh); a later turn begins with the display pass's viewport layout, which compensates by
   moving the clip (18k C6 — the trace's own asymmetry).
6. **Red-on-old is real, three independent ways, and the pin is not hollow:** the pre-fix pin logs
   (Study 80.0 pt, 2/2 deterministic, both premises asserted so it cannot pass vacuously — D2 proves
   the premises have teeth by failing them on a calm page); R-keep reddened exactly its 3 predicted
   issues; the harness's plain Study row FAILS on the R-keep scratch build (45591 → 44477) and
   PASSES on the fix. I re-ran the two suites myself on the shipped tree: green.
7. **The attribution is by run, not by narrative:** D1 (insert back on `seam: nil`, no keeper) green
   — the differential road `79b334ab` gave the tail ⏎ is the road that shows B5; D2 (ring off) never
   reaches the precondition; TextKit's half honestly undetermined (no 26.x on this machine — TK2 §5).
   Consistent with TK2 §2's documented estimate class; the drafted §3 line is a measurement record
   in the 18k/18l form, correctly left to the orchestrator's closeout pen.
8. **P1/P3 hold:** the keeper's cost is one viewport-bounded `readingAnchor()` capture + one
   single-fragment `lineSpan` per differential structural act, and the bounded jump only when the
   line actually moved (witness = 0 on every settled-geometry act, pinned). Nothing at keystroke or
   autosave rate; nothing scales with the corpus; no word-level tracking; no text copied across
   entities. The test-only `ensureLayout(documentRange)` is the rig's history-setting, not product.
9. **The riding pins are byte-unmodified by construction** — the only file under `VariorumTests/` in
   the range is the new `WriteFloatingViewportTests.swift` (diff stat); the closing set 1019/154
   green includes them; Release compiles (`#if DEBUG` witness fenced on both sides).
10. **The harness changes are sound:** `zsh -n` clean; the retired KNOWN label is retired in BOTH
    voices with the reason at the line (a move is now a FAIL — the tripwire kept its teeth, proven
    by 125735); `b5-more-roads` is appended LAST (order-independence reasoning holds; its two rows
    are labelled GUARDS, honestly — green on the revert too, so they carry standing cover, not
    red-on-old weight); `caretEnd`/`vw_snap`/`vw_expect_page_still` all exist with the used
    signatures; the omitted third argument to `vw_expect_page_still` is the same empty-known the old
    Terminal arm passed.
11. **The brief's mandatory items, each discharged:** (1) INSTRUMENT — done, instrument removed from
    the tree, copies parked in gitignored DerivedData; (2) TRACE — concrete, one call, numbers; (3)
    ATTRIBUTE — the four-value column with evidence bars; (4) FIX inside the fence with red-on-old —
    verified above; (5) row 85 last chance — NOT TAKEN on an honest no-reproduction (five traced ⌘↓
    landings, ring correct each time; no pin possible without a reproduction — the right call under
    the hallucination guard); (6) WALK both voices + full seeded harness — 121540 read, baseline
    exact (XFAIL 4 = S3 ×4), voice restored. Row 88's close is DRAFTED, not applied — correct pen
    discipline; no canon file touched in the range.
12. **Process:** 14 commits, per-piece, all pushed, no trailers; LIVE STATUS from the first commit;
    the withdrawn candidate 1 and the keyboard-stall derailment are in the history, not smoothed
    over; zero `Sources/`, `Shared/`, `Sync/`, `EditorTextView`, `BlockRangeIndex`, `PaneSurface`,
    `PaneTextAuthority`.

---

## VERDICT (round 1)

**The unit stands: the trace is real, the fix is inside the fence, the pin has teeth, and the
evidence chain survives independent verification. Findings: 0 BLOCKER · 0 MAJOR · 1 MINOR (F1, a
contract-comment contradiction on the structural door — fix owed) · 2 NIT (F2 README order row; F3
optional test hardening).** Under the cross-model flow these findings go to the implementer
verbatim; its agree/dispute returns to this reviewer, who makes the final call and implements the
confirmed fixes (F1 and F2 are one-sentence doc amendments; F3 is optional and may be recorded as
declined). No product behavior change is sought by any finding, so no new pin is owed — F1/F2 are
clarity-class with the degradation stated above.

**Dispositions (to be filled at adjudication):**
- F1 — pending implementer response.
- F2 — pending implementer response.
- F3 — pending implementer response.

---

## IMPLEMENTER RESPONSES (round 1) — `opus-implementer`, 2026-09-27

Every claim re-checked at the source on `a2eaac45` (pulled first). I implement nothing; the reviewer makes the final
call and implements its confirmed fixes.

**F1 · MINOR — AGREE.** Verified: `EditorSurfaceController.swift:3076–3084` (the pointers are exact) still says
*"untouched text never moves, no scroll restore step exists at all"*, and six lines below it my paragraph describes a
restore step that now exists (`keepUntouchedReadingLine`, called at :3113). The second clause is false as written;
the first is the promise the keeper enforces. My miss — I added the paragraph without amending the sentence it
contradicts. **Refinements for the pen:**
- Scope check done: `grep 'no scroll restore step\|no scroll-restore step\|no restore step'` over `App/` finds ONLY
  this line (:3080). The other three copies of the 2026-07-07 words are promise-framed and still true —
  `JumpPrimitive.swift:143` and `:175` (`ReadingAnchor`'s docs) and `EditorViewModel.swift:4262` (already qualified:
  *"true while TextKit keeps laid-out geometry where it laid it out"*). `StructuralSeamEdit.swift`'s header makes no
  restore claim. So the fix is the one parenthetical; nothing else needs touching.
- Keep "untouched text never moves" as the promise, date it, and replace only the false clause — the reviewer's
  suggested wording is right; a slightly tighter form that reads as one sentence with the paragraph below it:
  *"…known seams — untouched text never moves (the 2026-07-07 promise); there is no unconditional restore step — since
  18l-b U-B5 the keeper below puts the untouched reading line back iff TextKit moved it, KnownIssues row 88)…"*.
- Doc-only: no pin owed (clarity class), no behaviour, `StructuralSeamEdit`/the oracle untouched.

**F2 · NIT — AGREE.** Verified: two rows end "Runs LAST" — `book-landings` (stale since this unit appended
`b5-more-roads`) and `b5-more-roads` (true: `SCN_ORDER`'s last entry). **Refinement — the line pointers are off:** the
rows are `Tools/VisualWalk/README.md:127–128` (the file has 159 lines, not 542+) and `SCN_ORDER` is
`scenarios.zsh:845–847` (not 650–653). Suggested wording for `book-landings`' row: *"Runs after `takes-landing` (18l-b
U-B5 appended `b5-more-roads` last)"*. The `read-landing` row's "Runs AFTER the B5 pair" is still true — leave it.

**F3 · NIT (optional) — AGREE, and I lean toward taking it rather than declining.** Verified: the indices are hard-coded
at `WriteFloatingViewportTests.swift:144/148` (the pin) and `:274/279` (`UntouchedLineKeeperTests`' `tailReturn`
helper) — the reviewer's pointers (310–315, 440–446) are off; the file has 361 lines. The trap is real but by a
different mechanism than stated: `BlockRangeIndex.range(ofEntryAt:)` (`Shared/EditorBrain/BlockRangeIndex.swift:74–81`)
ends in `preconditionFailure("entry index out of range")`, not an array subscript — same outcome, and in the test
host it kills the whole xcodebuild test process, taking every later suite in a closing set down with it, which is a
little worse than one crashed suite. **Refinements if taken:** guard BOTH sites (the pin and the `tailReturn` helper),
right after the editor mounts: `try #require(h.model.index.entries.count > 150, "the fixture: A Scandal in Bohemia
carries at least 151 blocks")`. The fence test (`anActThatWritesAboveTheReadingLineKeepsItsOwnMovement`, indices
30/40 on its own 80-block synthetic note) is self-sizing and needs nothing. Adding the `#require` does not touch any
assertion, so the pin's red-on-old evidence stands unchanged (it is a premise, not a verdict). If declined, record it
as "declined — the bundled fixture is deliberately stable".

No disputes. Nothing in the clean bill contradicts my record; clean-bill item 1's note that the trace's stack came
from the instrumented tree (the shipped `EditorTextView` has no `setSelectedRanges` override) is accurate — the
override was instrument-only and removed with it.
