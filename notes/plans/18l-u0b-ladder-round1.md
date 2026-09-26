# 18l U0b — COLD REVIEW, ladder round 1 (Fable, 2026-09-26)

**Reviewer:** `fable-reviewer` (Fable 5, xhigh), zero implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff under review:** `3404fd61..5241d8d4`, code =
`App/`, `Sources/`, `Tests/` (5 files, +445/−13; commits `b4b978cd…5241d8d4`, the
notes-only record commits excluded per the brief). **Anchors read in full, myself:** the
phase plan (`phase-18l-navigation-feel.md` whole — U0b BRIEF, U0b RECORD, the U0 RECORD,
THE SITTING RECORD R-18l-1/2/4/5), the charter (`post-13u-health-rounds.md` KICKOFF 2 /
U0b), `TEXTKIT2_NOTES.md` §§2–4 (the 27.0 findings are this diff's era), KnownIssues rows
53/81/85/87/88, QUESTIONS #116/#134/#147/#149, the canon (CLAUDE.md auto-set), and the
touched code end to end plus its unchanged surroundings: `JumpPrimitive.swift` WHOLE
(`JumpCorrectionLoop`, `FragmentLines`, `lineSpan`, `jump` with the C6 re-assert and the
C6b live range, the new `ReadingAnchor`), `EditorViewModel` §scroll anchoring
(`topVisibleOffset` + `isBlankParagraph`/`firstReadableLineStart`, `restoreTopVisibleOffset`,
the new `readingAnchor()`/`restoreReadingAnchor`, `parkAnchorRestore`/
`consumePendingAnchorRestore`/`consumePendingCarriedPlacement`, `keepingReadingPosition`,
the teardown session-anchor stamp), `EditorSurfaceController` (`renderFull`,
`applyStructuralResult`, `planEmptyBlockDeletion`/`runEmptyBlockDeletion`),
`EditorView.swift` (`ScrollAnchorController` whole, both `applyChrome` doors,
`EditorSurface.Coordinator.install`), `EditorTextView.makeEditor` (the 24-pt inset,
verified at the source), `EditorTestSupport.swift` (the harness the pin composes), and
`WriteTopAirTests.swift` whole. No "Review foci" section exists in the plan or the
charter's U0b text (checked; none owed). Zero `Sync/`, zero schema, zero `Sources/`,
zero `Shared/` — confirmed by diff stat, not the seam table. Commit-trailer check over
the range: clean.

**Verification runs made by this review (targeted, per the prompt's rule):**
- `xcodebuild test -only-testing` on **WriteTopAirTests + the six anchor-family suites
  the record claims ride unmodified** (`ScrollAnchorTests`, `RefontViewportTests`,
  `RefontGapTopTests`, `JumpViewportLayoutTests`, `ModeSwitchCarryTests`,
  `LandingOffsetTests`) → **37 tests / 7 suites passed** on the final tree (zero app
  instances at the run, verified by pgrep). The six pre-existing suites are byte-untouched
  in the range (diff stat) and green beside the new pins.
- Pin-before-fix verified against git: the pin commit `642a9a00` carries ONLY the test
  file (+ record); the fix `998f7d7d` carries only the four product files (+ record).
- The red-on-old claim verified by TRACE (below), the implementer's three logged runs
  (pre-fix RED 14, R-full RED 14 identical, R-top RED exactly 4), and the arithmetic
  being forced: the old `renderFull` called `jump` with the default `landingInset: 0`,
  whose contract is "the line AT the viewport top"; a page at rest has line 0's top at
  `textContainerOrigin.y` = 24 (`makeEditor`, verified: `textContainerInset` height 24),
  so the correction loop converges the clip to 24 — the pins assert < 0.5 and MUST fail
  by 24.0 on the old code. Re-running the reverts myself would require working-tree
  edits (barred in review) — the trace plus the green-on-new run is my evidence.
- KnownIssues records verified on disk: row 87 CLOSED with the ladder re-open clause;
  B5 filed as row 88 (owner 18l, honest "untraced" with named suspects); B6 folded into
  the U0c brief with the ReadingAnchor hand-forward.

**The mechanism, traced independently (the hallucination guard):** her ⌫ on the empty
last block → `shouldChangeText` plans A7's carve (`planEmptyBlockDeletion`,
EditorViewModel:1121) → `runEmptyBlockDeletion` (EditorSurfaceController:2358) returns
`StructuralOutcome(… seam: nil)` → `applyStructuralResult`:3082 takes the else branch →
`renderFull`:153, whose restore captured `topVisibleOffset()` (offset 0 at the page top)
and replayed it through `JumpPrimitive.jump` at the default inset 0 = line-at-the-top =
clip 24: the air eaten, exactly her captures' 24.0 in both voices. The same replay in
`ScrollAnchorController` (live resize) and `keepingReadingPosition` (re-font) collapses
the air at the page top; the same replay mid-note snaps a wheel-scrolled page by the
edge's offset inside its line (the pins' 5.0; the walk's 40.0 at a gap edge). The fix
carries the place (`ReadingAnchor.inset`) into the `landingInset` parameter `jump` has
had since 13u2b — no new scroll machinery; the C6 re-assert composes correctly because
it re-asserts `wanted`, which the loop already derived from `minY − landingInset`.

---

## FINDINGS (severity-ranked)

### MINOR-1 · `notes/QUESTIONS.md` #134(a) (and the F2 record's shape) · the ruled/PROVISIONAL re-font rule's own record now describes behavior the keepers no longer have in the page's top air — no pointer to the carve lands beside the rule

**What's wrong:** #134(a) — the PROVISIONAL product call recorded for 13u4 F2, hers to
overturn — states the keeper *"remembers the LINE at the top of your page before the
type changes and puts that same line back at the top afterwards. That is what the app
already does when a window resize re-wraps your text, so the two agree."* After this
diff both keepers land `ReadingAnchor.reflowLandingInset` — the line at the top
EVERYWHERE EXCEPT the page's top air, where the captured inset is kept (judgment call 2,
stated for this ladder). The two keepers still agree with each other, and the carve is
CORRECT on the merits (my ruling below) — but the QUESTIONS row she reads if she ever
revisits F2's product calls now describes a rule the app no longer follows in the
top-air case, with no dated pointer to where the carve is recorded (KnownIssues row 87 /
the U0b RECORD). The repo's own precedent for exactly this shape is R-18l-5/#149: the
carve-out to a recorded rule lands beside the rule, in its own terms.
**Evidence (traced degradation, clarity class — no pin owed):** `#134(a)` is
byte-unchanged in the range (verified); `ReadingAnchor.reflowLandingInset`
(JumpPrimitive.swift:170) and both keeper call sites implement the carve; an author (or
a future implementer) consulting #134 to change the keepers would build to the stale
letter.
**My ruling on the carve itself (the reviewer's final-call duty):** SOUND, not a
STOP-and-report miss. The landing place was never separately author-ruled — F2's
line-at-the-top was inherited from `jump`'s default contract (KnownIssues row 53's fix
description confirms: "park the restore through the existing `parkAnchorRestore`", i.e.
machinery); #147 rules WHICH line (untouched, `topVisibleOffset` byte-unchanged); and
#134(a)'s stated purpose — keep the words you were reading where they were — is
contradicted, not served, by moving a resting page 24 pt. The collapse is her reported
bug's sibling (B3/B4 pinned red-on-old at 24.0), so fixing it is stopping an
un-asked-for jump, not changing a ruled resting rule. The record just needs to say so
where the rule lives.
**Proposed fix:** one dated line appended to #134(a) — *(18l U0b, 2026-09-26: the
"same line back at the top" rule keeps the page's TOP AIR as it was — a page resting
above the text container was never "at the top"; the mechanism and pins are KnownIssues
row 87 / `WriteTopAirTests`; hers to overturn with the row)* — nothing else.

### MINOR-2 · `App/Variorum/VariorumTests/ScrollAnchorTests.swift:9–11` + `EditorViewModel.swift:4167` · the width-reflow suite's header names a road production no longer takes, and `restoreTopVisibleOffset` is now production-dead (test-only)

**What's wrong:** the suite header still reads *"The anchor is `topVisibleOffset()`
(read on every scroll) → `restoreTopVisibleOffset()` (replayed on every width reflow:
sidebar toggle, split divider, window resize, live-resize end)"*. After this diff the
controller's every capture is `readingAnchor()` and its every replay is
`restoreReadingAnchor(_:)`; `restoreTopVisibleOffset` has ZERO production callers left
(verified by grep — six call sites remain, all in four test suites: ScrollAnchorTests,
TypewriterRoomTests, TypewriterRoomReachabilityTests, EditorWindowSmokeTests).
**Evidence (traced degradation):** the suites that claim to pin "the width reflow's
replay" now pin a function the width road doesn't call. Today that is harmless by
construction — `restoreReadingAnchor` with `reflowLandingInset == 0` (every non-top-air
anchor) performs the byte-identical `jump(toOffset:min(...), landingInset: 0)` — but a
future edit to `restoreReadingAnchor`'s arithmetic would leave ScrollAnchorTests green
while the production road drifts, which is precisely the false comfort a pin exists to
prevent. The top-air half of the controller road IS pinned by `WriteTopAirTests` (live
resize red-on-old; the width arm an honest labelled hollow guard).
**Proposed fix (either, one is enough):** (a) update the ScrollAnchorTests header to
name the real road (`readingAnchor()` → `restoreReadingAnchor`, inset 0 outside the top
air) and mark `restoreTopVisibleOffset` as the pins' offset-only test seam in its doc
comment; or (b) route the six test call sites through
`restoreReadingAnchor(ReadingAnchor(offset:…, inset: 0, inPageTopAir: false))` and
delete the dead function. (a) is smaller and keeps the pins byte-stable; recommended.

### NIT-1 · `EditorViewModel.swift:2421/2534` · the consumed park leaves `pendingAnchorInset` stale

`consumePendingAnchorRestore` nils `pendingAnchorRestore` but not `pendingAnchorInset`;
`consumePendingCarriedPlacement` (line 2534) nils the park the same way. Harmless today
— `pendingAnchorRestore` is set non-nil ONLY by `parkAnchorRestore`, which always writes
the inset (verified: three assignment sites, no other writer) — but a future direct
setter would inherit a stale inset silently. One line (`pendingAnchorInset = 0` beside
each nil) or one sentence on the property naming the invariant. No pin possible (no
observable behavior today) — labelled honestly as hygiene.

### NIT-2 · `EditorViewModel.swift:4179` · `readingAnchor()`'s doc overstates its nil-equivalence by a hair

*"nil exactly when `topVisibleOffset` is"* — the code has a second independent nil
source (`lineSpan` failing). I traced it unreachable in practice (a non-nil
`topVisibleOffset` implies a laid-out fragment holding the offset, so `lineSpan`'s
`.ensuresLayout` enumeration from that location cannot come back empty; textView/
scrollView cannot go nil between the two synchronous calls), so this is doc precision
only: "nil when `topVisibleOffset` is (`lineSpan` of a line already on screen cannot
fail after it)" would be exact.

---

## DISPOSITION OF THE IMPLEMENTER'S FLAGGED JUDGMENT CALLS (each checked, my call)

1. **`renderFull` lands EXACTLY (B2 fixed with B1)** — CONFIRMED SOUND. No ruling
   anywhere names the full re-render's landing as line-at-the-top (searched: 13c 1A is
   the coordinate conversion; RAISE-M1 is the cold mount's park; #147 is which-line;
   #116 is the mode-switch carry); the 2026-07-07 decision ("untouched text never
   moves") and the U0b brief's own walk criterion demand exactness; the old behavior
   measurably moved a wheel-scrolled page 5–40 pt on every `seam: nil` structural act.
   The differential road's promise kept on the fallback road is the spec-coherent shape.
2. **The keepers' top-air carve** — CONFIRMED SOUND on the merits; the record gap is
   MINOR-1.
3. **"Top air" = edge above the text container** — CONFIRMED: O(1), continuous at the
   boundary (inset → 0 as top → 24), cannot be negative in the air, and immune to text
   layout by construction (nothing above the container origin reflows).
4. **B3/B4 fixed inside U0b** — CONFIRMED in scope: same mechanism, same surface,
   pinned red-on-old (R-top red exactly there), and the U0-sweep discipline says fix
   what the unit's mechanism reaches. The B4 attribution (our-commit `4ae12a59` via the
   R-F2 discriminating revert) is the honest one — pre-F2, scroll 0 stayed 0 because
   nothing restored at all.
5. **The teardown session anchor stays an offset** — CONFIRMED as deliberate deferral:
   B6's reproduction is recorded, the U0c brief carries the hand-forward
   (`ReadingAnchor` now exists for it), and touching it here would have crossed into
   R-18l-1's product rule mid-unit.

## CLEAN BILL (load-bearing things specifically checked and found solid)

- **The traced mechanism is real and the numbers are forced:** carve → `seam: nil` →
  `renderFull` → `jump(landingInset: 0)` → clip 24 (the container inset, read at its
  source). The brief's inset-vs-scroll fork is decided by measurement the pins encode
  (`textContainerOrigin.y` constant across the act; the clip moves).
- **`JumpPrimitive.jump` and `lineSpan` byte-unchanged** (diff adds only the
  `ReadingAnchor` struct to the file); `landingInset` is genuinely 13u2b's pre-existing
  parameter, so no new scroll machinery — and the estimate (`… − landingInset`), the
  live `maxScroll()` (C6b) and the C6 re-assert all compose with a non-zero inset
  correctly (the re-assert re-scrolls to `wanted`, which already carries the inset).
- **`topVisibleOffset()` byte-unchanged** — C6b's reading-line rule and #147 ride as
  ruled; `RefontGapTopTests`/`RefontViewportTests`/`ScrollAnchorTests`/
  `JumpViewportLayoutTests`/`ModeSwitchCarryTests`/`LandingOffsetTests` byte-unchanged
  and green beside the new pins (my run, 37/7).
- **Every other `parkAnchorRestore` caller keeps `landingInset` default 0** — the cold
  mount (RAISE-M1) and the carried-placement road (#116, its own `ViewportCarry` inset)
  are byte-equivalent to before; `pendingAnchorInset` is written on every park (no
  stale-inset road exists today — NIT-1 is future-proofing only).
- **The pin suite is real evidence:** real window at Write's proportions, the REAL
  keystroke road (`deleteBackward`/`insertNewline` through `shouldChangeText`), the real
  coordinator + `ScrollAnchorController` via `install`, both voices parameterized, own
  typography pinned and restored (the S5 harness-voice leak answered), deterministic
  in-memory store. The hollow width-reflow arm is labelled hollow IN the test file —
  the guard discipline as written.
- **Behavioral-revert design discriminates the fix's two halves:** R-full (inset thrown
  away) must red all 14; R-top (carve removed) must red exactly the two keeper pins ×
  two voices — and the logs record exactly those shapes. R-13y/R-F2/R-room are genuine
  discriminating experiments for attribution, not narrative.
- **P1/P2/P3 honored:** the new per-scroll cost is one single-fragment `lineSpan` of a
  line already on screen (O(1), viewport-bounded; the self-assessment states it
  honestly); no operation's cost scales with note size; no TK1 API; no decoration on
  live storage; the capture runs before the storage write (the 13u3 R1-1 rule kept by
  construction in `keepingReadingPosition`).
- **Scope fences held:** zero `Sources/`, `Sync/`, `Shared/`, schema; `EditorTextView`,
  `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `runStructural` untouched
  (verified against the diff, not the seam table); no core/iOS/mobile runs owed and
  none claimed.
- **Records verified on disk:** row 87 closed with the ladder re-open clause; B5 = row
  88 with honest "untraced" and named suspects (and it is genuinely a DIFFERENT
  mechanism — the typed ⏎ takes the differential road, which has no restore step, so
  U0b's diff cannot be its cause; seen pre-fix too); B6 in the U0c brief; the walker
  facts in the traps. Pin-before-fix commit ordering verified. No trailers.
- **Product fences held:** R-18l-1 (note-open) untouched — the cold mount's saved-anchor
  branch and the teardown stamp are byte-unchanged; #116(c)'s caret-visible doctrine
  untouched (the reveal machinery is not in the diff); the ⏎ chain (R-13u4-2) and the
  carve's ruled caret landing (13c 1B) untouched.

**Round-1 verdict: 0 BLOCKER · 0 MAJOR · 2 MINOR · 2 NIT.** The fix stands as built;
both MINORs are record/comment edits, no product code. Per the cross-model flow these
findings go to the implementer verbatim; dispositions land here before any fix pass.
