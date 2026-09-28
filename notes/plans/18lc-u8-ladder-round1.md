# 18l-c U8 — cold review, round 1 (Fable, 2026-09-28)

**Reviewer:** `fable-reviewer` (cold, zero implementation context; `notes/REVIEW_PROMPT.md` run verbatim).
**Window:** `git diff 45054bba..HEAD` — UNIT U8, mode-switch feel (the caret rule R-18l-13 · the arrival flash · the comfort band). Earlier 18l-c units (U5/U6/U7) were prior rounds' subjects and were touched here only where this window's diff re-arms their pins.
**Verdict: 0 BLOCKER · 0 MAJOR · 1 MINOR · 5 NIT.** No spec drift found; no invariant touched; every load-bearing closeout claim located and verified (logs, pins, or a fresh run).

---

## Findings (severity-ranked; format `[severity] · file:line · what · evidence · fix`)

**[MINOR] R1-1 · App/Variorum/VariorumTests/TakesArticleWatchTests.swift:456 (`aStoodDownEntryLandingIsNeverWatched`), TakesArticleScrollTests.swift:2069 (`theTopStandDownHoldsInTheAppsOrderToo`), TakesArticleScrollTests.swift:2126 (`aPageLeftAtRestComesBackAtRestOnTheAppsOrder`) · three re-armed pins now ASSERT THE OPPOSITE of their own names** · Evidence: the re-arm (correctly, per R-18l-13's "each named old → new, never silently edited") flipped the assertions — `aStoodDownEntryLandingIsNeverWatched` now expects the landing IS watched (`story contains " LAND"`), `theTopStandDownHoldsInTheAppsOrderToo` now expects `articleLanding == "was-here"` (the stand-down does NOT hold), and `aPageLeftAtRestComesBackAtRestOnTheAppsOrder` now expects `isOnScreen(hers…) == true` (the page does not simply come back at rest — her block is revealed). In this repo pin NAMES are load-bearing documentation (records, ladder files, and the revert tables cite pins by name); a future reader grepping for the stand-down or the at-rest promise finds three green pins whose names claim the retired contract. Cleanliness class — no red-on-old pin can exist for a name (justification in lieu of a pin, per the guard). · Fix: rename the three to state the ruled behavior (e.g. `theEntryLandingIsWatchedNeverStoodDown`, `theSameBlockEntryLivesAtATopMemoryInTheAppsOrder`, `aPageLeftAtRestComesBackWithHerBlockRevealed`), keeping the old name in each doc comment as the re-arm's audit trail. One mechanical commit; zero behavior.

**[NIT] R1-2 · App/Variorum/Variorum/Features/Takes/TakesArticleScroll.swift:239, Features/ReadMode/ReadEditPane.swift:145, Features/ReadMode/ReadModeView.swift:879 · the flash STATE's lifetime is hard-coded to `ArrivalFlash.plan(reduceMotion: false).total` while the FACE renders from `plan(reduceMotion: <live>)`** · Evidence: three state-clear timers (`watchedLandingArrived`'s Task, the two `.task(id: arrival)` sleeps) assume the two plans share `total`. Today they do by construction (`Plan.total = hold + fade` regardless of `animated`), and the pure pin `reduceMotionIsTheDiscreetUnanimatedVariant` asserts `plan(true).total == holdSeconds + fadeSeconds` — so behavior is correct and the invariant is (indirectly) pinned; the coupling is just unstated at the three call sites. · Fix: a named `ArrivalFlash.stateLifetime` (or a one-line comment at each site naming the pinned invariant). No pin owed (green on both sides today — hollow as a bug).

**[NIT] R1-3 · App/Variorum/Variorum/Surface/ArrivalFlash.swift:159 (`ArrivalFlashOracle`) · the DEBUG oracle's `seen`/`flashes` dictionaries grow unboundedly across an app session** · Evidence: `note(_:part:opacity:startedAt:)` only ever inserts; `reset()` is called by pins, never by the app; the walk probe reads `flashes` "always on" each probe. A long DEBUG session accretes one entry per flash event (~100 bytes each) — negligible in practice, DEBUG-only, but the repo's own `DebugOracleLog.bound` pattern exists for exactly this class (KnownIssues row 53's family). · Fix: bound `flashes` (drop oldest past ~256) or prune entries older than a few minutes.

**[NIT · SPECULATIVE] R1-4 · App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:2294 · Write's mode-switch feel is keyed on "bare arrival ∧ not the opening ∧ (remembered ∨ carried)" — the 'this is a mode switch' fact is inferred, not carried** · Evidence: I traced the router's model and found NO concrete non-mode-switch road that re-runs the bare arrival with a remembered fact and no opening (first opens arrive fact-less; re-opens carry `CommandRouter.openingLanding`; the representable is not recreated by restyles), so I could not build a mechanism where the band/flash fires off a road that is not a mode switch — hence SPECULATIVE, not a bug. The inference's exhaustiveness argument lives only in my trace, not in the code. · Fix: one doc line at the park naming the argument ("the only bare arrivals that are neither an opening nor fact-less are mode switches — the router ends `opening` at the switch"), so the next editor of `registerDetail`/`opening` knows this seam leans on it.

**[NIT] R1-5 · App/Variorum/Variorum/Features/ReadMode/ReadModeView.swift:452 (`case .pages`) · the paged read form neither bands nor flashes a mode switch — unrecorded residual** · Evidence: `NotePagesView` never consumes `pageTarget`, so it had no landing machinery before U8 and has none now — a mode switch into Read while the pages form is remembered gets no carry, no band, no flash (pre-existing; U8 changes nothing there). The record's HONEST BOUNDARIES names Read's last-block room (row 7) but not this form. · Fix: one line in the record/closeout (the boundary's owner is the landing family, row 12's class), or fold into KnownIssues row 94's re-word at close.

**[NIT] R1-6 · App/Variorum/Variorum/Features/Takes/TakesArticleScroll.swift:224 · `articleArrival` doc says "cleared … at teardown" — no teardown clear exists** · Evidence: `endArticleLandingWatch()` ends the watch only; nothing nils `articleArrival` at teardown. Moot in practice — the brain is per-mount and dies with its board — but the doc claims an act the code doesn't perform. · Fix: one doc word ("dies with the board") or a nil in `endArticleLandingWatch`.

---

## Dispositions (filled by the flow)

| # | Finding | Implementer response | Reviewer's final call | Fixed at |
|---|---|---|---|---|
| R1-1 | stale pin names (3 → 4) | AGREE + a fourth pin (R-3's) + whole-pin naming caveats + the record-table citation rule | CONFIRMED, WIDENED to four; the implementer's names adopted (one broadened a word for the bloom arm) | `1180c71a` |
| R1-2 | flash-lifetime coupling | AGREE; site :880; prefers `ArrivalFlash.stateLifetime` with the 0.1 margin folded in | CONFIRMED; the named constant built as suggested | `14ef4d0b` |
| R1-3 | oracle growth (DEBUG) | AGREE; bounding is pin-safe (every reader resets first); trim `flashes` by start time, clear `seen` on overflow | CONFIRMED; bounded exactly so | `ccca3572` |
| R1-4 | mode-switch inference doc | AGREE; the condition IS #98(a)'s own trigger set, widened only by the carry (a mode-switch fact by construction) — say that, not a new exhaustiveness argument; one clause to weigh for #158 | CONFIRMED as doc-only; the implementer's framing ADOPTED over mine (it is the better description); the weighed clause ACCEPTED into #158 (6) | `44e2530d` |
| R1-5 | pages-form residual, recorded | AGREE; HONEST BOUNDARY 10 or row 94's re-word; owner the landing family | CONFIRMED; recorded as HONEST BOUNDARY 10 in the U8 RECORD (the close may still fold it into row 94's re-word) | `44437f48` |
| R1-6 | `articleArrival` doc word | AGREE; a teardown nil would also be safe (both callers are teardown) but leans to the doc word | CONFIRMED; the doc word (no code — the lean is right: the brain dies with its board, and zero code moves) | `38e8caad` |

---

## Clean bill (what was specifically checked and found solid)

1. **The caret rule (R-18l-13) is built at the ONE resolver site and nowhere else** — `TakesArticleScroll.resolveEntryLandingAgainstTheMemory` (:383): the same-block stand-down retired for the `.entry` kind only; `landingOutranks` (R-Q20's moved-block win) byte-unchanged; the restore machinery (`consumeArticleGeometry`, `restoreStep`, the hold, `ArticlePlace`) untouched; the re-open road untouched (R-18l-1's opening never calls `landArticle`; `NoteOpenLandingTests` and `ModeSwitchCarryTests` absent from the diff — verified by diffstat — and green in the close log). The (A)-vs-(B) reading of the ruling is a real fork and is handled exactly per the PROVISIONAL rule: (A) is the spec-defensible build ("Takes joins Write" literally — Write's own shape is memory-places-then-caret-reveals), and the fork is QUESTIONS #158 (1), a question, not a ruling.
2. **The 17q race is answered, not re-opened** — `articleEntryRidesThrough` (:410) defers the ride-through's first step to the watch's quiet (:726); revert R-U8-2 (`18lc-u8-RD.log`, on disk) shows the race firing deterministically without it (237 → 537). The deferral is bounded (the watch's correction budget + watchdog), and a ride-through landing waits on the restore through the same `articleReadyForLanding` gate the bloom always used, `restoreLooksAgainForAWaitingLanding` serving it by the same guard.
3. **`ComfortBand` is pure and its arithmetic is right** — `fits` guarantees `topAir ≤ viewport − bottomRoom − height`, so `clamp` is well-ordered; the fraction clamp returns mid-band fractions bit-exact (the `abs(clamped − top) > 1e-9` guard); tall targets keep their resolved place (the carry's and R-Q1's tall rules stand). Pinned pure (`ComfortBandAndFlashTests`, all three arms + fraction space + tall + Write's `restCaretLine`) and hosted per surface (`TakesEntryBandTests`, `ModeSwitchFeelTests` — foot/head/mid measured 34.0 / 18.0 / exact on Takes, 24.0 / 34.0 / 250.5→250.5 on Write, 25.5 / 33.5 on Read).
4. **Scope discipline held everywhere I could reach it**: the band and flash key on the Takes `.entry` kind (`landingIsBanded`), Write's `pendingModeSwitchArrival` (non-opening bare arrival with a fact/carry), Read's `ReadLanding.modeSwitch` (a seed with `openingLanding == nil`). I traced the first-open road end-to-end through `CommandRouter.openingLanding` (:196): a session-first open into Read has `opening.seeded == fact == nil` → non-nil opening → `scrolls == false` → no landing at all, so no flash; a re-open lands with `modeSwitch: false`. Clicks, blooms, find steps: pinned never to flash (`aBloomOrAFindStepNeverFlashes`) and never banded (the kinds' shipped reveals byte-reachable in `landingDecision`/`landingEdge`'s else arms).
5. **The band's first-step trio is sound and each piece is independently pinned and reverted**: `landingEdge` (a banded fitting row in the top air → head — R-Q1's `minY<0` rule would have sent it to the foot; pure pin + R-U8-10 red); `bandedSecondAim` (unrealized row aimed at the EXACT shipped edge, one more aim from its real height in the same storm; pure pin + R-U8-12 red; a tall row and a missed edge both fall back to the watch's correction — a hop, never a wrong rest or a stuck landing); `isOnTheRestingPage` (evidence-based, with the impossible-geometry guard pinned in its second arm; R-U8-11 red with the 90-pt haul and row D's hop returning). The four unpredicted revert reds are traced in the record and the tracing is correct (the edge rule and the second aim are one design; the resting-page rule is row D's road).
6. **The flash respects the TK2 rules** (read before this review, §3–4): no rendering attributes anywhere — Write's flash is a `DecorRectView` in the decor overlay (the existing below-text pattern), Takes/Read are SwiftUI background/overlay pairs on the one row; line geometry via `JumpPrimitive.lineSpan`; the C8 object-identity/autorelease hazard honored in the oracle keying (per-event counts for the probe, fresh-per-test keys for the pins — NOTICED 7 recorded). `LandingAuthority.onArrived` is additive (nil default, told once, `arrivalTold` reset per `land`, the settled-untold arm, and the re-entrancy guard after the callback) — the five other surfaces run byte-unchanged.
7. **Cost shape (P1/P3) verified against the code**: zero at rest (no flash state ⇒ no `TimelineView` mounted; the band is arithmetic on landings that already run); per landing the new work is O(realized rows) once (`isOnTheRestingPage`, the anchor read) inside a step that was already O(order); one face on screen ≤ 1.1 s; liveness untouched (exactly one live pane). Nothing scales with corpus or document size; nothing tracks word-level change; nothing copies text across entities.
8. **The core touch is exactly the allowance and exactly the `receipt_style` shape**: `Operations.setArrivalFlash` through the existing `upsertSetting` road; read-time default ON with garbage-reads-ON (`value != "0"`); upsert-only, one row ever, outbox row asserted (synced); `setting.value`'s E2EE PLAIN "enum semantics, no prose" promise honored ("1"/"0" — SyncSpec's settings classification checked); zero schema, zero `Sync/`, lockstep marker untouched. `swift test --filter AppearanceSettingsTests` re-run by me on the final tree: **9/9**.
9. **The closeout's load-bearing claims all located and verified**: `18lc-u8-close.log` on disk ends `602 tests in 99 suites … 6 issues (including 5 known issues)` with the three new U8 suites green and the one real failure exactly the SettingsShape drift (the catalog ⇔ pane pin doing its job); the fix commit `6e72ee74` is +2 lines and `18lc-u8-settings.log` shows 15/15; all thirteen revert logs (R1/R1b/RB/RC/RD/RO/R10–R12) on disk with timestamps matching the record's sequence; the re-armed pins' old → new table matches the diffs line for line (11 pins + the walk's row C, R-2's designed red restaged on the road that remains).
10. **Fences held**: zero `Shared/`, `Sync/`, schema, migrations, mobile; `TakesViewModel` +0 lines; U7's find machinery untouched (`TakesFind*`/`PaneFindFace` absent from the diff; the `.find` kind still weighed against nothing); no TK1 API; no literal colour (tokens.wash/tokens.accent only); Settings face follows the catalog pattern with the drift pin green.
11. **The walk layer**: the `mode-switch-feel` scenario stages a mid-note block for Read's boundary honestly, `vw_cap_on_flash` fixes the real fixed-sleep miss, the probe's `band`/`af` reads are DEBUG-only and O(small); the `takes-find` order-dependency and the store-poisoning mechanism are pre-existing, correctly attributed by run (`124437` pre-U8 scratch build), and owned at the close (the orchestrator's acceptance).
12. **Review foci**: the plan carries no "Review foci" section (checked in all three 18l plan files); the record's own pointed asks — JUDGMENT CALLS 10–11 and the band's first step — got the deepest read (items 3 and 5 above), and the implementer's self-named weak points (a)–(f) were each checked: (a) the trio, sound and fail-soft; (b) the second aim's one report outside the watch — a one-report-wide gap whose next report re-arms normally, no traceable degradation; (c) properly #158 (1); (d) within the probe's tolerance, recorded; (e) the wall-clock timing is honestly bounded by the pins reading state + oracle; (f) the ~70 EditorViewModel lines are consumers-of-private-hop-steps, correctly argued.

**Owed at close (confirmed, not findings)**: the AppSpec §12 R-18l-13 contract line + §7's NOT-seeded list gaining `arrival_flash` (drafted in the record, deliberately proposed to the author at close); KnownIssues row 94's re-word; QUESTIONS #150's close; the TEXTKIT2_NOTES harness fact; the `/Applications` refresh — all correctly owed to the orchestrator's closeout, none silently landed.

---

## THE IMPLEMENTER'S AGREE/DISPUTE (returned 2026-09-28; checked against `1be605d0`, changed nothing)

**Totals: 6 AGREE, zero disputes.** Additions for the reviewer's final call:
- **R1-1:** a FOURTH pin has the same problem — `theEntryRingsOwnRoadAlsoComesBackWhereSheLeftIt`
  (:1310, re-arm table R-3; old: her block stays off the page + top ±1 row; new: the restore ran
  then her block revealed) — suggested `theEntryRingsOwnRoadComesBackThenRevealsHerBlock`. Naming
  caveats: `theTopStandDownHoldsInTheAppsOrderToo` has byte-unchanged arms beyond the flipped
  `same` arm (name the whole pin, e.g. `aTopMemoryInTheAppsOrderKeepsEveryEntryLandingAlive`);
  `aPageLeftAtRestComesBackAtRest…` is half still true (the top restore issues no scroll) —
  `…ComesBackAtRestThenRevealsHerBlock` keeps both halves. The U8 RECORD's re-arm table
  (~1692–1698) cites all four old names — update to "old → new" in the same commit; OLDER
  records citing old names are history and stay (`18lb-u2-ladder-round1.md:148`,
  `use-report-round-2026-09-12.md:5948`, `phase-17-standing-fixes.md`).
- **R1-2:** site correction `ReadModeView.swift:880`; prefers the named constant
  `ArrivalFlash.stateLifetime` WITH the `+ 0.1` margin folded in (all three sites add the same
  0.1 — one home for the margin too).
- **R1-3:** bounding is pin-safe (every oracle-reading pin calls `reset()` first —
  `TakesEntryBandTests` :483/:515/:538, `ModeSwitchFeelTests` :392); `flashes` keys end in the
  start time so oldest-past-cap trims cheap; `seen` is orderless — clear-on-overflow.
- **R1-4:** the park's condition IS #98(a)'s own trigger set three lines above (~2279), widened
  only by `pendingCarriedPlacement` (a mode-switch fact by construction, 13u2b UNIT 3) — the doc
  line should say "the same trigger set as #98(a)'s reveal" rather than claim a new
  exhaustiveness argument. One clause to weigh: #98(a)'s comment names "a place someone chose
  since the note arrived"; no road found that re-runs the bare arrival without a mode switch,
  not exhaustively traced — if one exists it already reveals under #98(a) and would now band and
  flash too — a possible #158 "what flashes" sub-question, not a bug.
- **R1-5:** confirmed (`ReadModeView.swift:452–457`, `onOpenInEdit` only); HONEST BOUNDARY 10 or
  row 94's re-word; a gap in its own boundaries list, owned.
- **R1-6:** both callers of `endArticleLandingWatch()` are teardown (`TakesViewModel.teardown`
  :540 via `TakesBoardLayout` :404) so a nil is safe, but leans to the one-word doc fix.

**State: handed to the reviewer for FINAL CALLS + its own fix implementation; the implementer's
sanity pass follows.**

---

## THE REVIEWER'S FINAL CALLS (Fable, 2026-09-28 — all six CONFIRMED, zero dismissed; fixes implemented in this session, per piece, below)

- **R1-1 — CONFIRMED, WIDENED BY ONE.** The implementer's fourth pin is real (verified against the
  window's own diff: `theEntryRingsOwnRoadAlsoComesBackWhereSheLeftIt`'s new assertions are
  restore-ran + her-block-REVEALED + aims > 0 — the name's "comes back where she left it" is no
  longer the pin's point) — adopted. Its naming caveats are both right and both adopted:
  `theTopStandDownHoldsInTheAppsOrderToo` is named for the WHOLE pin — I broadened the suggestion
  one word (`aTopMemoryInTheAppsOrderKeepsEveryLandingAlive`, not `…EveryEntryLandingAlive`)
  because the fourth arm's landing is a BLOOM, not an entry, and it too stays alive;
  `aPageLeftAtRestComesBackAtRestThenRevealsHerBlock` keeps the still-true half exactly as argued.
  The four renames land with the OLD name kept in each pin's doc comment as the re-arm's audit
  trail; the U8 RECORD's re-arm table (rows R-3/R-6/R-7/R-9) updated to "old → new" in the same
  commit; older records citing old names stay as history (`18lb-u2-ladder-round1.md:148`,
  `use-report-round-2026-09-12.md`, `phase-17-standing-fixes.md:1528`). No pin owed: a name has no
  red-on-old — cleanliness class, justification in lieu (the round-1 finding's).
- **R1-2 — CONFIRMED (NIT).** The implementer's shape is better than my two options and is built:
  `ArrivalFlash.stateLifetime` with the `+ 0.1` clear margin folded in (one home for the margin
  too), consumed at the three sites (`TakesArticleScroll.swift:239`, `ReadEditPane.swift:145`,
  `ReadModeView.swift:880` — its site correction accepted). The reduce-motion-invariance the
  constant leans on stays pinned by `reduceMotionIsTheDiscreetUnanimatedVariant`.
- **R1-3 — CONFIRMED (NIT).** Bounded exactly per its pin-safety note (verified: every
  oracle-reading pin calls `reset()` first): `flashes` trims oldest past the cap by the start time
  its keys already carry; `seen` (orderless) clears on overflow. DEBUG-only; the walk probe's
  per-run counts are unaffected at walk scale (a scenario draws single-digit flashes).
- **R1-4 — CONFIRMED as doc-only, and the implementer's framing ADOPTED OVER MINE.** Its reading
  is the better one: the park's condition is #98(a)'s own trigger set three lines above, widened
  only by `pendingCarriedPlacement` (a mode-switch fact by construction, 13u2b UNIT 3) — so the
  doc line says "the same trigger set as #98(a)'s reveal", not a new exhaustiveness claim. The
  weighed clause is ACCEPTED into QUESTIONS #158 (6) as one sentence: if a non-mode-switch road
  into #98(a)'s reveal exists (neither of us found one), it would now band and flash too — hers
  to weigh with "what flashes", not a bug.
- **R1-5 — CONFIRMED.** Recorded as HONEST BOUNDARY 10 in the U8 RECORD (the record is the unit's
  truth; the closeout may still fold it into KnownIssues row 94's re-word — the owner is the
  landing family, row 12's class, exactly as the implementer says).
- **R1-6 — CONFIRMED; the doc-word lean adopted.** Both callers of `endArticleLandingWatch()`
  being teardown makes the nil safe too, but the doc word is equally honest and moves zero code —
  the right trade for a NIT ("…and it dies with its board").

### The fix record (per piece; every commit pathspec-staged, pushed, no trailers)

| Piece | Finding | Commit | What landed |
|---|---|---|---|
| A | R1-1 | `1180c71a` | four pin renames (old names in the doc comments) + two in-file cross-refs + the U8 RECORD re-arm table rows R-3/R-6/R-7/R-9 to "old → new"; a repo-wide grep confirms no dangling old-name reference outside history records and untracked DerivedData |
| B | R1-2 | `14ef4d0b` | `ArrivalFlash.stateLifetime` (margin folded in) + the three call sites |
| C | R1-3 | `ccca3572` | `ArrivalFlashOracle` bounded at 256 (trim `flashes`' oldest half by the start time its keys end in; clear orderless `seen` on overflow — never the entry being written) |
| D | R1-4 | `44e2530d` | the #98(a)-trigger-set doc line at the park + the one #158 (6) sentence |
| E | R1-5 | `44437f48` | HONEST BOUNDARY 10 in the U8 RECORD |
| F | R1-6 | `38e8caad` | the `articleArrival` doc word ("dies with its board") |

**Suite results (the end of the fix pass, `App/Variorum/DerivedData/18lc-u8-ladder-fixes.log`):**
`✘ Test run with 112 tests in 10 suites passed after 245.392 seconds with 1 known issue` — the ten
touched suites (`TakesArticleScrollTests` · `TakesArticleWatchTests` · `TakesFindBoardTests` ·
`TakesEntryBandTests` · `ModeSwitchFeelTests` · `ComfortBandAndFlashTests` · `ModeSwitchCarryTests` ·
`NoteOpenLandingTests` · `ReadNoteLandingTests` · `ReadLandingTests`), the 1 known issue exactly the
U7 tripwire (`escWithNoBuiltPaneForTheRingIsANamedBoundary`, designed); all four renamed pins green
under their new names. No behavioural change was made anywhere in this fix pass (renames, one named
constant equal by construction to the three expressions it replaced, a DEBUG bound, three doc/record
edits), so no behavioural revert is owed — the round-1 justifications stand in lieu of pins, per the
guard. **Fix pass complete; handed back for the implementer's sanity pass.**
