# 18m U1 — Fable cold review, ladder round 1 (2026-09-29)

**Reviewer:** fable-reviewer (fresh session, zero implementation context). **Window:** `git diff 3975b682..1734857a`.
**Status: COMPLETE — round CLOSED.** Verdict: **no BLOCKER, no MAJOR, no MINOR — one NIT**, implementer
AGREED, reviewer CONFIRMED and FIXED in-round (the disposition section at the end). The hoist is a
faithful address move on both platforms; every load-bearing claim was traced or re-run.

## Reading done (never delegated)

Plan file whole (the U1 RECORD, arm table, shape ruling + six conditions, build notes, self-assessment,
orchestrator verify pass); CLAUDE.md + auto-canon; TEXTKIT2_NOTES §3–4 (mandated — confirmed the diff
touches no TK2 surface: no attribute stamps, no layout/viewport reads, pure decision code only);
KnownIssues rows 28/51 diffs; the full diff of all four production files + both new test files; the
PRE-state at `3975b682` (Mac `EditorViewModel` ladder + its `planClampedInBlockEdit` /
`planWholeBlockDeletion` / `planCrossBlockEdit` / `planEmptyBlockDeletion` / `planSeamMerge` forwards and
`viewText`; `EditorSurfaceController.planEmptyBlockDeletion` / `planSeamMerge` / `WholeBlockDeletion` /
`planCrossBlockEdit`; phone `MobileEditorViewModel` ladder + its three plan wrappers + `viewText`);
`CrossBlockRefusal.swift` whole + `CrossBlockRefusalRoads.swift` (the Mac's `macFanRoads` forwards);
`CrossBlockCompound.clampedInBlockEdit` + `plan` read discipline; `BlockRangeIndex` inits +
`wholeBlockRun` / `wholeBlockDeletion` / `wholeBlockRunAwaitsSync` / `runAwaitsSync`;
`EditorAssertionSeam`; `EditorTestSupport.slot`; `EditorDocument.separator`; `RenderedBlock.isGap`;
the seven commits' log (no trailers; per-piece; the two closing commits verified notes/comment-only).

## Equivalence trace (the 3C claim, checked mechanism by mechanism)

- Mac order old = fence → A7 → #34 → J9 → clamp → compound → diagnose; `macArms` identical. Phone order
  old = J9 → clamp → gap fence → compound → diagnose; `phoneArms` identical. Both gates clear
  `pendingEdit`/`bulkPending` first and `return false` after, unchanged.
- A7 plan: `SeamCarvePlan.emptyBlockDeletion` is a byte-faithful move of the old controller body
  (`model.index`/`model.slots` → parameters; `EditorSurfaceController.model` is `unowned let model:
  EditorViewModel`, so the new call's `index`/`slots` are the SAME values at the SAME instant). #34's
  `textedSeamMerge` likewise, guard for guard.
- J9: old Mac wrapped `index.wholeBlockDeletion` in `WholeBlockDeletion(blockIDs:)` (a struct holding
  only `blockIDs`); the route returns `[String]` and the Mac mapping re-wraps — identical. The phone
  consumed `[String]` directly, unchanged.
- Clamp/compound: same shared brains, same `viewText` surface reader (the counted extraction door on
  both platforms) — the old `[weak self] … ?? ""` / `[model]` captures collapse to one non-escaping
  `{ viewText($0) }` inside a synchronous gate, equivalent while `self` lives (it does — the route is
  synchronous inside `shouldChangeText`).
- Gap fence (phone): `index.wholeBlockRunAwaitsSync(covering:)`, same position, same
  replacement-agnostic guard.
- Terminal: Mac `message(for: cause)` (`CrossBlockRefusalRoads` supplies `macFanRoads`) ≡ old
  `message(range:index:slots:)` = `message(for: diagnose(...), fanRoads: macFanRoads)` — same inputs,
  computed at the same time. Phone `message(for: cause, fanRoads: Self.fanFoldRoads)` ≡ old composed
  call. `route(...)`'s terminal is `diagnose(range:index:slots:)` with the gate's own three values.
- Executors, schedules (`scheduleCrossBlockCompound` / `scheduleGestureCompound`), sentences (find copy,
  read-only line, R13 no-confirm note kept at the phone's `.deleteWholeBlocks` mapping) — all unchanged;
  the switches re-derive nothing (condition 3, verified by reading both).
- Laziness/cost (P1): `for arm in arms` with early return = the ladder's first-claim-stops. The clamp
  reads the surface only in its claiming return (verified in `CrossBlockCompound.clampedInBlockEdit` —
  `surfaceText(span)` sits in the return expression after every guard); `plan` reads ≤ 2 (edges only).
  The ≤ 2 route bound is real; the implementer's correction of the ruling's "≤ 3" is right, and the
  orchestrator adjudicated it so.

## The ruling's six conditions — each checked

1. `surfaceText` bounded/read-only, ≤ 2 reads: verified in code + pinned by the property test
   (`aPlatformIsOnlyAnsweredByAnArmItDeclaresAndReadsAreBounded`, incl. the 0-read J9 laziness pin). ✓
2. Absent arm = vacuous pass, bites on arrival: `violations(of:)` + `anAbsentArmPassesVacuously…`
   (wrong-position phone carve fails BY NAME; the Mac list is proven non-vacuously compliant). ✓
3. No re-derivation at either switch: verified — each case is one executor call or one sentence. ✓
4. Undeclared-arm cases fire `EditorAssertionSeam` then the platform's own terminal sentence; Release =
   the diagnosis alone (handler default `assertionFailure`, a no-op in -O), exactly what each platform
   says today when every declared arm declines. The property sweep pins unreachability. ✓
5. `Arm.gapFence`'s doc declares the COPY arm (O-2) + why the Mac lacks it (M7's `.unsyncedBlock`);
   `theGapFenceChangesOnlyTheWords` pins the copy-arm fact. ✓
6. `findReplacing` has no default in `route`'s signature; the Mac passes the live fact
   (`textView?.isFindReplacing == true`), the phone literal `false`; pinned in BOTH targets
   (`aFindSweepIsFenced…` / `aSeamKeystrokeOnThePhoneIsTheDiagnosisEvenUnderAFindFact`). ✓

## Verification runs (this reviewer's own, on the reviewed tree)

- Mac: `EditorEditRouteTableTests` + the five riding families (`SeamMergeTests`, `WholeBlockDeleteTests`,
  `BoundaryClampTests`, `CrossBlockCompoundTests`, `FindAndReplaceTests`) — **105 tests in 6 suites, all
  green** (suite-level `-only-testing`, 2026-09-29 01:58).
- Phone: `MobileEditRouteArmsTests` — **3/3 green** on the iPhone 17 Pro simulator (02:01).
- The Tutorial 79/11 and FULL-mobile 647/110 finals were NOT re-run here (heavy; the orchestrator's
  verify pass re-checked the counts and the 3C diff); F-1's offender literal was independently confirmed
  on disk (`SampleLibraryJekyllBook.swift:91`) and the file confirmed untouched by the window's diff.
- 3C re-checked by diff: the two test targets gained exactly the two NEW files; zero existing pin lines
  edited; zero `Sources/VariorumCore/` (zero `Sync/`), zero schema, zero layout code.
- Same-commit ledger touch verified: the hoist commit (`3a7b79fd`) carries KnownIssues rows 28+51.

## Findings

- **[NIT] · App/Variorum/Shared/EditorBrain/EditorEditRoute.swift:189–196 · one `precedence` row is a
  generated extrapolation, not a recorded ruling · The `Arm.allCases` map manufactures
  `findReplaceFence ≺ gapFence` and stamps it with the L6 ruling string ("the safety core runs before
  every planner") — but the gap fence is not a planner, no ruling ever placed the fence relative to it
  (they have never shared a ladder), and the pair is vacuous on every declarable list today (no platform
  holds both arms). Honestly labeled: NO pin could ever go red on this — it is a doc-precision note for
  the table that presents itself as "the ruled pairwise order constraints", not a behavior hazard. ·
  Fix (optional, U3-or-later): either exclude `.gapFence` from the generated block or re-word that row's
  ruling string to say the fence-first placement is L6's natural extension, not its text.**

*(Nothing else. The self-assessment's own hardest-look list — the undeclared-arm cases, the ≤ 2-read
bound, the moved docs, the permutation-vs-recorded precedence split — was checked line by line and
holds. The `EditorAssertionSeam`-over-`preconditionFailure` choice is right by the repo's
refuse-don't-trap doctrine and I confirm it.)*

## Clean bill (checked specifically, found solid)

1. **Zero behavior change per platform** — every arm's guard, input source, order, executor, schedule
   and sentence traced old→new on both platforms (the table above); no input routes differently.
2. **The order-as-data claim is real** — the three load-bearing overlaps (J9≺clamp, J9≺compound,
   fence≺carve) are proven by permutation pins that answer differently on a permuted list; the
   exclusive-by-geometry pairs are honestly recorded as rulings, not overlaps; the gap fence is pinned
   as a COPY arm.
3. **Row 51 is genuinely "buildable, never built"** — the phone's list lacks both carves (pinned in
   both targets), their plans are shared, and the vacuous-pass-then-bites pin works as designed.
4. **The ruling's six conditions** — all six verified (section above).
5. **P1** — laziness preserved; the route's cost profile is the ladder's own (0 surface reads on a J9
   claim, pinned; ≤ 2 ever, pinned; the fence/carve short-circuits unchanged).
6. **The frozen-projection doctrine survives the move** — A7's guards remain ENABLEMENT only; the
   store-time authorizations (`.emptyWithNothingUnshown`, #34's store fan read, the compound's CAS)
   ride byte-untouched at the executors (condition 3).
7. **MobileSoul §3/§4.4** — the shared file holds zero user-facing strings; every sentence stayed at
   its platform's call site; `fanRoads` stays a parameter.
8. **TK2 exposure nil** — no attribute stamping, no layout-forcing reads, no viewport code (TEXTKIT2
   NOTES §3–4 read; nothing in the diff touches the listed hazard classes).
9. **Discipline** — seven commits, per-piece, no trailers, pushed; LIVE STATUS from the first commit;
   the ledger touch rule honored in the hoist commit; F-1 attributed correctly (pre-existing, file
   untouched by U1) and routed, not fixed; no PROVISIONAL owed (none minted, none needed).
10. **Named open gate (by record, not a finding):** the unit's USE acceptance is OPEN — the W1–W7 walk
    + VisualWalk subset are HELD at `guard.sh --author` (her live real-store app), correctly recorded
    as gating the unit's close; the ladder ran in parallel per the 18l-b U3 precedent.

**Round 1 verdict: PASS with one NIT.** Under the cross-model flow the NIT goes to the implementer
verbatim; given its no-pin-possible label the reviewer's expectation is agree-and-defer (U3 or a later
touch), not an in-round fix.

## Disposition + fix (round closed — reviewer's final call, 2026-09-29)

- **The implementer AGREED** (its response, held by the orchestrator, verbatim in the round log) and
  leaned toward fixing in-round by EXCLUDING `.gapFence` from the generated fence-first rows rather
  than rewording the row. Its three reasons match this review's trace: the gap fence is a COPY arm
  (nothing for L6 to guard), no ruling ever ordered the pair (no platform declares both; the relative
  order could change only a refusal's WORDING), and the unruled row undercut the table's own promise
  that every constraint names a real ruling.
- **FINAL CALL: CONFIRMED, fixed in-round, by exclusion** (rewording would have kept a constraint no
  ruling asked for). One correction to round 1's own label: "no pin possible" was too pessimistic —
  a pin on the TABLE'S CONTENT (no generated fence≺gapFence row) is possible and went in first.
- **The fix, landed pin-first (red-on-old verified by run order, not revert):**
  1. `EditorEditRouteTableTests.bothListsHonourEveryRuledPrecedence` gains the expectation that no
     `precedence` row pairs `.findReplaceFence` with `.gapFence` — run against the UNFIXED code:
     **RED, exactly that one expectation** (19 tests / 1 suite, 1 issue, 02:09).
  2. `EditorEditRoute.precedence`'s generated block excludes `.gapFence`
     (`.filter { $0 != .findReplaceFence && $0 != .gapFence }`) with a comment carrying the why (copy
     arm; no ruled position; wording-only consequence) — the fence-first rows now cover the planner
     arms only, each genuinely under L6.
- **Green after the fix (this reviewer's runs):** Mac `EditorEditRouteTableTests` + the five riding
  families — **105 tests / 6 suites green**; phone `MobileEditRouteArmsTests` — **3/3 green** (iPhone
  17 Pro simulator). No other test names the pair; the behavioral surface is untouched (the walk never
  consulted `precedence`).
- The implementer's suggested self-assessment/build-notes sentence is carried by the code comment and
  this disposition (the plan file's U1 record stays the implementer's own text; this file is the
  round's record). An implementer sanity pass over this diff follows per the flow.
