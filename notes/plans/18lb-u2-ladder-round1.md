# 18l-b U2 — COLD REVIEW, LADDER ROUND 1 (Fable, 2026-09-27)

**Reviewer:** `fable-reviewer`, cold, zero implementation context, `notes/REVIEW_PROMPT.md` verbatim.
**Diff under review:** `334bf74c..43a879b1` (code = `App/`, `Tools/`; 25 commits, notes-only record
commits excluded from the code read but read as the record). **Anchors read in this session, in own
context:** CLAUDE.md + the auto-loaded canon; `notes/plans/phase-18l-b-navigation-feel.md` WHOLE (her
kickoff, the principles, the traps, the ledger, the U2 BRIEF, the U2 RECORD, both acceptance passes,
the bloom-race fix pass); the charter's KICKOFF 2 U2 bullet (`notes/plans/post-13u-health-rounds.md`);
the 18l first-half record's U0c TRACE/BUILD (C6, the opening arm) and U1 RECORD + judgment calls;
R-Q1 / R-Q20 / R-Q21 verbatim and the R-8 brief's restore/landing map
(`notes/plans/use-report-round-2026-09-12.md`); KnownIssues rows 36/42/85/88; TEXTKIT2_NOTES §3
(relevance check — see clean bill 12). **Code read whole:** `Surface/LandingAim.swift` (new),
`Surface/LandingAuthority.swift`, `Features/Takes/TakesArticleScroll.swift`, the board/view-model/view
diffs, `ReadNoteLanding.swift`, `LandingAimTests`, `TakesArticleWatchTests`,
`LandingAuthorityTests` diff, `Tools/VisualWalk/scenarios.zsh` + README.

**Evidence discipline (the hallucination guard):** every mechanism below was traced by reading in this
session; the load-bearing record claims were independently re-verified — the landing family run by this
reviewer (`xcodebuild test`, 7 suites: TakesArticleWatchTests 12 · LandingAimTests 5 ·
LandingAuthorityTests · LandingSignpostTests · TakesArticleScrollTests 40 ·
ArticleLandingProjectionArmTests · TakesLandingTests): **✔ 78 tests in 7 suites passed**; the
hoisted-arithmetic suites (ReadNoteLandingArithmeticTests · ReadNoteHeightsCalibrationTests ·
ReadNoteLandingTests): **✔ 16 tests in 3 suites passed**; the 3C proof re-run by diff (the ONE
pre-existing test line changed is the sanctioned `LandingSignpostTests` surface count 5→6); the restore
half hunk-free by hunk ranges (no hunk between the step's tail and the file's new tail — `ArticlePlace`,
`ArticleRestore`, `consumeArticleGeometry`, `restoreStep`, `.holding`, the 24-aim budget,
`articlePlaceNow`, `rememberStep` untouched); the red logs read (`18lb-u2-watch-prefix1.log` RED 2/2;
`18lb-u2-R-watch.log` RED exactly 7 tests / 14 issues over 63/5 with all 51 pre-existing landing pins
green; `18lb-u2-bloom-red.log` the two fix-pass pins RED 3+3; `18lb-u2-R-relook.log` /
`18lb-u2-R-file.log` each RED exactly its one pin / 3 issues; the pre-U2 attribution log holds the
`[wait ×5] restore=wanted` stall verbatim; the Release scratch compile `** BUILD SUCCEEDED **`); the
walk's product claim re-verified by this reviewer's own `cmp` — rows A/B/D/F captures BYTE-IDENTICAL
between the pre-U2 scratch build (`223440/`) and the U2 build (`222714/`); zero app instances before
tests; zero commit trailers on the 25 commits. No product file was edited in this pass; this record is
the one write.

---

## FINDINGS (severity-ranked)

### MINOR-1 · `Surface/LandingAim.swift:87` + `Surface/LandingAuthority.swift:110` · the aim kind is a mechanism on one adopter of six and a convention on the other five

**What.** `LandingPolicy.aim`'s doc says the authority's converged number "is the target's distance
from THAT home — `LandingAim.residual(policy.aim, …)` answers it per kind." In production, only the
Takes watch consults the dispatcher (`TakesArticleScroll.reportWatchedLanding:690`). The three book
adopters report `row.minY` themselves; note Read's `ReadLandingBox` computes through the
`ReadLandingResidual` typealias directly, not through `LandingAim.residual(.viewportFraction, …)`. So
the dispatcher's `.top` and `.viewportFraction` arms have ZERO production call sites (pins only), and
the five older adopters' `aim` field is declarative: a policy whose declared aim drifted from what its
surface actually reports would fail nothing.

**Evidence (traced).** Grep over `App/Variorum/Variorum`: `LandingAim.residual(` has exactly one
production caller. The arithmetic itself IS single-sourced (the hoist did that job — the typealias and
the dispatcher share one body), so this is shape, not duplication.

**Class.** Architectural clarity — no pin can exist (behavior is identical); flagged with written
justification per the prompt's rule, not as a bug. **Fix:** one sentence in `LandingAim`'s header (or
the `aim` field's doc) naming the convention — "the dispatcher is the watch road's; the older adopters
compute the same bodies at their own call shape" — or route note Read's residual through the
dispatcher at its next touch (behavior-neutral). Not owed inside U2's fence.

### MINOR-2 (SPECULATIVE) · `Surface/LandingAuthority.swift:614–619` + `Features/Takes/TakesArticleScroll.swift:687–695` · the watch cannot retract a target's report — a stale residual can carry a settle

**What.** Once the watched target has reported residual ≈ 0, `lastTop` holds it. If the target's row
then DE-REALIZES (`forgetArticleRowFrame` removes its frame) and the page moves off it with no further
target report, every subsequent report road answers `LandingAim.residual → nil → watch.nudge()` — which
re-arms the quiet but leaves `lastTop` stale — and `LandingSettle.decide(top: 0, …)` settles the
landing `top=0` with the row possibly off screen.

**Why SPECULATIVE (labeled honestly per the prompt).** The internal mechanism is fully traced, but no
reachable input sequence was found: every page-mover enumerated either ENDS the landing (her hand — the
geometry road; a content change — the projection arm) or RE-REPORTS the target (its own
`onGeometryChange` fires on any frame change), and de-realization needs a page-sized move none of the
remaining movers (SwiftUI's re-resolution of the landing's own last `scrollTo`) makes. The same shape
has existed on note Read's two faces since 18l U1. No red-on-old pin exists; per the guard this cannot
enter the fix protocol. **Fix:** none now — record. If it ever surfaces, the shape is a report
retraction (`forgetTop`) on the authority, told from the row's departure.

### MINOR-3 · `Features/Takes/TakesArticleScroll.swift:621` vs `:1180` · the re-look guard duplicates the restore's settle criterion as a literal

**What.** `restoreLooksAgainForAWaitingLanding` restates `abs(frame.minY - place.into) <= 2` — the
restore's own settle tolerance, spelled again at `restoreStep:1180`. If the restore's number ever
moves, the guard silently diverges: looser there → the re-look feeds the restore a geometry it won't
hold on (a wasted aim); tighter there → the bloom stall re-opens for the band between the two numbers.

**Evidence.** The two literals; the in-line comment (FP-1) names the coupling and the fence that forced
it (the restore body is byte-preserved by the unit's own rule, so the one site U2 could write is the
guard). **Fix:** give the duplication a named owner at the close — the KnownIssues row-42 residue
amendment the record already drafts should name this pairing explicitly; the real unification (one
shared `static let` both sites read) is a restore-half-adjacent edit for a unit not bound by U2's
byte-preservation fence. Both-sides-green today — no pin; recorded, not fixed, is the right disposition.

### NIT-1 · `Features/Takes/TakesViewModel.swift:540` · teardown reaches through `board.article.endArticleLandingWatch()`

Every other production access to the article brain goes through a `TakesBoardLayout` forward (the
file's own stated convention: "it lives here now and `TakesBoardLayout` forwards it"); teardown alone
reaches two levels deep. A one-line forward on the layout restores the convention.

### NIT-2 · `App/Variorum/VariorumTests/LandingAimTests.swift:33` · `everyShippedPolicyNamesTheAimItAlreadyHad` omits the sixth shipped policy

`takesArticle`'s aim IS pinned (`TakesArticleWatchTests.theTakesArticlePolicyAndItsSignpost`), but this
pin's name says "every shipped policy" and it now covers five of six (it predates step 2). One added
line, or a name that says "the five pre-U2 policies". Cosmetic.

### NIT-3 · `Features/Takes/TakesArticleScroll.swift:617–624` · the re-look's doc says "the slot order once, at the arrival" — it evaluates twice

The autoclosure re-wrap means `order()` runs at the guard's `contains(rowID)` AND again inside
`restoreStep`'s gone-row check (reached before the `atItsPlace` hold-return). Cost-only: one extra
O(rows) map, once, at the one arrival moment. Fix the doc word, or hoist `let order = order()` past the
cheap guards.

### NIT-4 · `Features/Takes/TakesArticleScroll.swift:492` · `articleLandingAttempts = 64` is now effectively unreachable

With the watch, a landing spends aims only at its arrival `.onChange` and at ≤ 3 quiet corrections —
the per-report spending that motivated 64 is retired (every pre-watch report-road exit is `.wait` /
`.done` before the decrement; the watched road never aims). The "the reveal's aims ran out" `gaveup`
road is in practice dead code kept as a fence. Worth one sentence at the constant so the bound reads as
the fence it now is; keep the fence.

---

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The restore half is byte-preserved** — verified by hunk ranges, not by trust: the diff's eleven
   hunks in `TakesArticleScroll.swift` cover the header, init/watch fields, `landArticle`'s first line,
   `noteProjectionArrived`'s one line, `clearArticleLanding`, the reveal hoists (typealiases/forwards),
   the step's watch lines, the new watch section and the story type; NO hunk touches `ArticlePlace`,
   `ArticleRestore`, `consumeArticleGeometry`, `restoreStep`, the `.holding` machinery, the 24-aim
   budget, `articlePlaceNow`, `rememberStep`, `articleRowFramesMoved`, `articleLastCurrentRow`.
   `TakesChoreographer`, `EditorRouter`, `PaneSurface`, `EditorTextView`, `BlockRangeIndex`,
   `PaneTextAuthority` are not in the diff; zero `Sources/`, `Shared/`, `Sync/`, schema.
2. **The 3C proof holds** — by diff, the only pre-existing test line changed is the sanctioned
   `LandingSignpostTests` surface count (5→6, its own "the next adds its case here" line); this
   reviewer's own runs: the landing family **78/7 green**, the hoisted-arithmetic suites **16/3
   green**, every pre-existing pin file byte-unmodified.
3. **The hoists are moves** — `ReadLandingResidual.residual`, `MinimalReveal.decision` and `.edge`
   bodies are byte-identical to the removed originals (read side-by-side in the diff); the old names
   are typealiases/one-line forwards; `MinimalReveal.anchor(.head/.foot)` equals the `.top`/`.bottom`
   the view always passed (`ViewportCarry.anchor` read; pinned).
4. **The NEW `MinimalReveal.residual` coheres with the shipped decision** — 0 exactly when the decision
   says `.none`, every non-zero answer's magnitude > 0.5 (branches hand-checked including the tall-row
   shapes; the 48k-point sweep pins it) — so `tolerance 0.5` makes the authority's "home" and the
   reveal's `.none` ONE rule with no disagreement band. JC 5 confirmed independently.
5. **The ordering contracts kept their owners.** R-Q20's landing-wins still runs at `landArticle`
   before anything moves (the prepended `watch.end()` touches watch state only, silently); R-Q21's
   stand-down still nils the landing at the resolver — and provably BEFORE the watch could ever hold
   it (the watch begins only past `articleReadyForLanding`, false until the restore resolves, and the
   resolver runs at exactly that boundary), pinned `aStoodDownEntryLandingIsNeverWatched` and
   non-vacuous (the ring's live-pane assertion; `landingEnabled` is set at the board view's
   construction, verified at `TakesBoardView.swift:149`); the settled gate is byte-unchanged; the
   structural arm still ends a landing on any content change (now filed `handedover`); U0c's opening
   arm is untouched and walked (rows A/C file nothing).
6. **Her hand files ONCE, on every door** — the geometry road files then runs the byte-unchanged
   decision; the gesture funnel guards on `articleLanding`; `userTookOver`/`giveUp` guard `isPending`;
   the watch invariant `watch.anchor ∈ {nil, articleLanding}` holds at every writer (`beginWatch` and
   `fileEnding` take only `articleLanding`; `landArticle` ends the watch before moving the request;
   `watchedLandingEnded` matches by anchor, so a superseding landing is never dropped by its
   predecessor's finish). Pinned (`herScrollHandsTheWatchedLandingOverOnce`, the arms pin) and re-read.
7. **The bloom-race fix is sound and bounded to its case** — the mechanism re-traced end-to-end and the
   model pin's sequence re-derived by hand in this session: the re-look hands the restore the geometry
   it last saw through the restore's OWN door; `.wanted → .holding` at `atItsPlace`; the landing's step
   readies in the same report; the reveal's own `endArticleHold` moves `.holding → .settled` (the
   pinned end state). Its reach is provably the bloom alone: an ENTRY landing and a `.wanted` restore
   cannot coexist — the resolver settles the restore (landing wins) or nils the landing (stand-down) at
   both meeting points (`landArticle` and the `.undecided` branch). `remembered: nil` is safe (read
   only in `.undecided`); `positionedByUser: false` is safe (her scroll's geometry report precedes the
   rows' per W-2, and any real scroll breaks the `into ± 2` guard). R-relook and R-file each re-open
   exactly their hole (logs read).
8. **Red-on-old is real, twice over** — the two step-2 pins committed and run RED on the pre-watch tree
   (2/2, the log read); R-watch RED exactly its predicted 7 tests / 14 issues with all 51 pre-existing
   landing pins green; the fix pass's two pins RED on the U2 tree (3+3 issues) and the stall reproduced
   on the pre-U2 road (the attribution log's `[wait ×5] restore=wanted`, read) — attribution
   PRE-EXISTING accepted on that run evidence.
9. **Where a landing PUTS a block is unchanged** — independently re-verified: this reviewer's own `cmp`
   of the walk captures, rows A/B/D/F byte-identical between the pre-U2 scratch build and the U2 build;
   the anchors identical values through the one vocabulary door; the reveal arithmetic byte-moved.
10. **P1/P3 hold.** Nothing pending: both report-road autoclosures stay unevaluated; two cheap guards
    per row report; zero cost change. Watched (≤ ~1.3 s settle, ≤ 4 s watchdog): a dict read, an O(1)
    residual and a work-item re-arm per realized-row report — bounded by the viewport and the watch's
    lifetime; facts O(rows) once per landing; corrections an observed count moving ≤ 3 times per
    landing, written only from the authority's work item (never inside a view update). The column
    realizes what it realized before.
11. **The signpost stays content-free on the new surface** — the closed enum's new case plus integers;
    `isContentFree` re-read; pinned; the walk's captured lines match the format, and a pre-watch death
    reads `hops=0 … top=-9999` (traced: `seedsFromLastReport` false → `lastTop` nil on the ephemeral
    take-and-end).
12. **TK2 relevance checked:** the diff contains no TextKit API — no `NSTextView`, `layoutViewport()`,
    `JumpPrimitive` or `PaneSurface` change; it is SwiftUI scroll choreography beside the panes. TK2
    §3's macOS-27 `layoutViewport()` clip-displacement item is U3's rider and is untouched here.
13. **Discipline held** — 25 commits, zero trailers (verified); commit-per-piece with LIVE STATUS;
    reverts named before they ran, on committed trees, restored clean; the closing 680/101 and the
    Release scratch compile logs read; the harness's 2 ERRORs attributed by measurement (one identical
    on the pre-U2 build, one a pass-on-re-run flake), the B5 fixture interaction handed to U3 (ledger
    row 6) rather than fixed cross-unit.
14. **The may-takes' dispositions stand** — C6's road (the born-live pane's `string =` → pane selection
    → `CommandRouter.noteFocusedBlock` → `CurrentBlockMemory`) is in none of the touched files; row 85's
    ring refresh likewise. NOT TAKEN / NOT TOUCHED verified against the diff's file list.
15. **The judgment calls, weighed independently:** JC 1 (per-quiet corrections) — concur on the
    measurement (64 aims in ~70 ms; row 100's class). JC 2 (the step body stays on the surface) —
    concur; P-9's one-concern line is real, no ordering contract changed owner, and the 40 pins calling
    the step in place IS the 3C proof working. JC 3 (the lifetime is the watch's) — concur it is
    architecture, not product (R-Q20/R-Q21 rule landing-vs-memory, the gesture-end pins rule that her
    hand ends a landing, and both ride green); MINOR-2 names the one residual edge, honestly labeled
    speculative. JC 4 (the structural arm files `handedover`) — the closed vocabulary's honest fit.
    JC 6 (`seedsFromLastReport` false) — right for a lazy column, and `begin` honors it. JC 7 (honest
    manifest-less facts) — Console honesty only; acceptable. JC 9 (the watch on the model) — consistent
    with P-9 and the file's own precedent. FP-1…FP-4 — accepted as recorded (FP-1 is MINOR-3's owner
    question; FP-2's added Console lines are a deliberate, modest cost).
16. **The honest residual is honestly recorded** — the pre-watch window still exists by design (a
    landing waiting on its restore files nothing until an exit road fires); the traced stall road is
    closed by the re-look and every other exit now files; a stall with NO exit road would still be
    silent, but every such shape this reviewer could construct requires row/geometry reports to stop
    flowing at a mount, which the mount's own layout storm contradicts. Nothing pinnable; B4's answer
    stands as written.

## VERDICT

**PASS at round 1 — 0 BLOCKER · 0 MAJOR · 3 MINOR (one SPECULATIVE) · 4 NIT.** Nothing gates the unit:
the two non-speculative MINORs are a header/doc sentence and an ownership line at the close; the NITs
are one-liners. Per the cross-model flow these findings go to the implementer verbatim; its
agree/dispute returns to this reviewer, which makes the final call and implements the confirmed fixes
itself (each with its pin where one is possible — MINOR-1/-3 and the NITs are doc/record-class, no pin
owed; MINOR-2 is recorded, not fixed, by its own label). No new BLOCKER/MAJOR ⇒ no round 3 is earned by
this round's content; round 2 re-reviews the fix pass per the ladder.

---

## IMPLEMENTER RESPONSES (round 1) — `opus-implementer`, 2026-09-27, over `bd409b15`

Every claim re-checked at the source in my own context (grep + read at the cited lines, tree at
`bd409b15`); nothing implemented — under the cross-model flow the final call and the confirmed fixes are
the reviewer's. **Tally: 6 AGREE · 1 AGREE-with-a-premise-correction (NIT-1) · 0 DISPUTE.**

**MINOR-1 — AGREE.** Verified: `LandingAim.residual(` has exactly ONE production caller
(`TakesArticleScroll.swift:690`, `reportWatchedLanding`); `ReadLandingBox.residual`
(`ReadNoteLanding.swift:301`) calls `ReadLandingResidual.residual` — the hoisted body, not the dispatcher;
the three book adopters report their row's top in their own bodies; `policy.aim` is read in production
only through `watch.policy.aim`. The inaccurate sentence is MINE, at `LandingAuthority.swift:106`
("`LandingAim.residual(policy.aim, …)` answers it per kind") — it states the dispatcher as the road for
every adopter. **Refinements for the reviewer's fix:** (a) fix the sentence where it lies — the `aim`
field's doc — e.g. *"…answers it per kind for a surface that asks the dispatcher (the Takes watch); the
five older adopters compute the same bodies at their own call shape — the book three report the row's top
(the `.top` arm's identity), note Read's box calls `ViewportFraction.residual` directly — so on them the
field is declarative"*; (b) if the reviewer wants the declared kind to bite on note Read without touching
its road, a GUARD pin (green both sides, stated as such — not a red-on-old) is cheap: for a handful of
sightings, `ReadLandingBox.residual` equals `LandingAim.residual(LandingPolicy.readNote.aim, …)` — that
makes a drift of `readNote.aim` fail something. Routing note Read through the dispatcher is
behaviour-neutral too, but it is U1's surface and not owed inside U2's fence — agree with "not owed".

**MINOR-2 (SPECULATIVE) — AGREE, record-not-fix.** The internal mechanism verified at the source:
`reportWatchedLanding` (`:686–695`) answers an unrealized target with `watch.nudge()` (`:638` — re-arms
only), so `lastTop` keeps the last residual and `LandingSettle.decide(top: 0, …)` can settle on it. I also
found no reachable input: while a landing is watched, her hand ends it on the geometry road, a content
change ends it through the projection arm, the landing's own reveal re-reports the target, and the one
remaining mover — the restore's HOLD re-aiming its remembered place (a bloom watched while the restore
holds, whose first step found the row on screen and so never spent the reveal that would end the hold) —
re-aims the SAME absolute anchor, a sub-row move, never the page-sized move de-realization needs.
**Refinement:** if it ever surfaces, the retraction has a natural Takes-side hook — the row's departure
(`forgetArticleRowFrame(placementID)` with `placementID == articleLanding` and the watch holding it) — and
the authority-side shape is a `forgetTop`-style call that sets `lastTop = nil` and re-arms, which then
routes through `correctsAnUnreportedTarget` (true on Takes and on note Read) into a blind correction by
direction: the same fix serves both surfaces that share the shape. Agree it cannot enter the fix protocol
without a reachable red.

**MINOR-3 — AGREE.** Verified: the two literals are `TakesArticleScroll.swift:621` (the re-look's guard,
`abs(frame.minY - place.into) <= 2`) and `:1180` (`restoreStep`'s `atItsPlace`, the byte-preserved body).
The coupling is real and one-directional in its harm, as the finding says (a tighter restore re-opens the
stall for the band between the two numbers). **Refinement for the owner line:** name BOTH sites by symbol
(`restoreLooksAgainForAWaitingLanding`'s guard ↔ `restoreStep`'s `atItsPlace`) in the KnownIssues row-42
amendment, with the unification's shape stated (one `nonisolated static let articleRestoreSettleTolerance`
read by both — a restore-half edit, so owner 12 with the row, or U2's successor on the landing family). The
guard's own comment already names the coupling; the finding's disposition (recorded, no pin — both sides
green today) is right.

**NIT-1 — AGREE on the fix, with one PREMISE CORRECTION.** The reach-through is real
(`TakesViewModel.swift:540`, `board.article.endArticleLandingWatch()`), but it is NOT the only one: `adopt`
reaches through the same way at `:480` (`board.article.noteProjectionArrived(new)`, 13u2 UNIT E's
structural arm — pre-existing). The file's forward convention covers the PRE-MOVE names (the split's 3C
list: "every pre-move name, at its old address"); the two post-split entry points the VIEW MODEL calls for
its own lifecycle reach through, and the NEW names the VIEW reads (`articleLandingReport`,
`articleLandingCorrections`) got forwards. So the honest statement is "two VM-lifecycle reach-throughs, one
of them pre-existing". **Refinement:** if the reviewer adds a forward, add both
(`noteProjectionArrived` and `endArticleLandingWatch`) so the convention reads as one rule; or keep both
reach-throughs and write the rule down at the forwards' header ("VM lifecycle calls reach the brain
directly"). Either is fine by me; one-of-two would be a new inconsistency.

**NIT-2 — AGREE.** Verified: `LandingAimTests.everyShippedPolicyNamesTheAimItAlreadyHad` (`:33–41`) pins
five policies; it was written at step 1, before `.takesArticle` existed. **Refinement:** adding
`#expect(LandingPolicy.takesArticle.aim == .minimalReveal)` keeps the name TRUE (the minimal reveal IS the
aim the Takes article already had — her R-Q1). A sturdier shape: drive the assertion from
`LandingSurface.allCases` through an exhaustive `switch surface { case .bookOutline: … }` returning each
shipped policy, so the NEXT adopter is a compile error here rather than a silent omission (the surface-count
pin's own "the next adds its case here" idea, made structural).

**NIT-3 — AGREE, and the count is slightly higher than stated.** Verified: at the arrival report the slot
order is built in the re-look's guard (`order().contains(rowID)`, `:622`), again inside `restoreStep`'s
gone-row check (reached before the `atItsPlace` return, since the restore is `.wanted` not `.holding`), and
a THIRD time by `articleLandingReport`'s own `return articleLandingStep(order: order())` (the step now
ready, so past its guards). So three O(rows) maps, once, at the one arrival moment — still cost-only and
not per report (every other report exits at the cheap frame guard before any `order()`). **Refinement:**
hoist `let order = order()` in the re-look past the cheap guards and pass the value through
`consumeArticleGeometry(…, order: order)` (the autoclosure then captures the array — no re-map); the
step's own evaluation is its P1 contract and should stay. The doc word "once" becomes true for the
re-look's part; the record's cost line can say "the slot order, at the arrival" without a count.

**NIT-4 — AGREE (keep the fence, say so at the constant).** Verified at `:492` and the two spend roads: a
watched landing's aims come only from the arrival's `.onChange(of: articleLanding)` step, the first decided
step on the report road, and ≤ 3 quiet corrections — so at most ~5 per landing in the app (the arrival
`.onChange` and the first report can each aim once if both land before the watch holds it). The 64 bound
is still REACHABLE by direct callers — the pure pin `theLandingEndsForAGoneRowAndAfterItsBoundedAims` spends
all 64 — so it is a live fence in the step's contract, dead only in the app's current cadence.
**Refinement:** the same sentence covers the step's gone-row `gaveup` in practice — the projection arm
(`noteProjectionArrived`, first in `adopt`) ends a landing before any step can see its row gone from a new
projection — so both terminal branches read as fences; one sentence at `articleLandingAttempts` naming
the watch's ≤ 3 corrections as the live bound would carry both.

**No new finding raised from this re-check.** (One record precision the reviewer may fold into NIT-3's fix:
the U2 RECORD's fix-pass line "the slot order once, at the arrival" is the doc sentence NIT-3 names — the
same word, in the record.)

## ROUND 1 FINAL CALLS + FIXES (the reviewer, 2026-09-27 — the cross-model flow's last leg; every implementer refinement re-verified at the source before adoption)

| Finding | Final call | Fix | Hash |
|---|---|---|---|
| MINOR-1 | **CONFIRMED**, the implementer's refinement adopted both halves: the wrong sentence is the `aim` field's own doc (verified at `LandingAuthority.swift:106`), and the guard-pin shape is worth having — it makes a drifted declaration fail something without touching U1's road | The field's doc now says where the dispatcher binds (the Takes watch) and that the five older adopters compute the same hoisted bodies at their own call shape (the field DECLARATIVE on them, guarded); NEW pin `LandingAimTests.theDeclaredAimKindsMatchWhatEachSurfaceComputes` — a GUARD, green both sides by design and stated as such (never a red-on-old): one sighting on which the three kinds answer three different numbers (330 · 0 · 30), the dispatcher keyed on each shipped policy's declared aim asserted equal to that surface's own road (the book three: `row.minY`; note Read: the BOX's own `residual` — `ReadLandingBox` driven directly; Takes: the reveal's home). Non-vacuity is by construction: any drift of any policy's kind lands on a disagreeing number | `1ac258d9` |
| MINOR-2 (SPECULATIVE) | **CONFIRMED as recorded-not-fixed** — the implementer's independent non-reachability check agrees (and adds the one mover I had not enumerated: the restore's HOLD re-aiming under a watched bloom — a sub-row move, never the page-sized one de-realization needs). No reachable red exists; the guard forbids a fix | **The disposition line, for whoever meets it:** the retraction has a natural Takes-side hook — `forgetArticleRowFrame(placementID)` where `placementID == articleLanding` and the watch holds it — and the authority-side shape is a `forgetTop`-style call that sets `lastTop = nil` and re-arms, which then routes through `correctsAnUnreportedTarget` (true on Takes AND note Read) into a blind correction by direction: ONE fix serves both surfaces that share the shape. Recorded here; no code | — |
| MINOR-3 | **CONFIRMED**; the code half stays FENCED by U2's byte-preservation rule (the coordinator's constraint and my own round-1 disposition agree), so the fix is the owner line | **The owner line, verbatim for the closeout's KnownIssues row-42 amendment:** *"The re-look's guard (`restoreLooksAgainForAWaitingLanding`, `TakesArticleScroll.swift`) restates `restoreStep`'s `atItsPlace` settle criterion (`into` ± 2) as a second literal — one-directional harm if they drift (a tighter restore re-opens the bloom stall for the band between the numbers); the unification is one `nonisolated static let articleRestoreSettleTolerance` read by both, a restore-half edit — owner 12 with this row, or the landing family's next U2-successor touch."* | this commit |
| NIT-1 | **CONFIRMED with the implementer's premise correction ADOPTED** (verified: `adopt`'s `board.article.noteProjectionArrived(new)` at `TakesViewModel.swift:480` is the same reach-through shape, pre-existing since 13u2 UNIT E); its "never one-of-two" rule is right — I fixed both rather than writing the rule down, because the layout already IS the model's one address for the article brain everywhere else | Two forwards on `TakesBoardLayout` (`noteProjectionArrived`, `endArticleLandingWatch`, with the rule stated at their doc); both VM call sites rerouted (`:480`, `:540`). Behavior-identical routing; exercised green (the watch suite's `adopt` road; the teardown road via `TakesCardHeightTests`/`TakesEmptyStateTests`/`FocusHandoffTests`/`EditorRouterActiveTests`, 31/4 green) | `45f35296` |
| NIT-2 | **CONFIRMED**, the sturdier shape adopted: the exhaustive switch makes the next adopter a compile error here rather than a silent omission | `everyShippedPolicyNamesTheAimItAlreadyHad` now iterates `LandingSurface.allCases` through an exhaustive switch (the sixth policy pinned; the pin's name true again) | `7c8d8da2` |
| NIT-3 | **CONFIRMED with the implementer's count correction ADOPTED** (three order-builds at the arrival, verified: the guard's `contains`, `restoreStep`'s gone-row check, and the ready step's own read) | The re-look builds the order ONCE past the cheap guards and passes the VALUE (the autoclosure then captures the array — no re-map inside `restoreStep`); the ready step's own read stays its P1 contract; the doc's cost line now true. The U2 RECORD's fix-pass line carries the same pre-fix word ("the slot order once") — noted here rather than edited there (the record stays the record; this table is its correction) | `9e1d79b1` |
| NIT-4 | **CONFIRMED with the implementer's liveness correction ADOPTED** (the 64 bound IS still reachable by direct step callers — the pure gone-row/bounded-aims pin spends all 64 — so it is a live fence in the step's contract, dead only in the app's watched cadence) | One doc block at `articleLandingAttempts` naming the watch's ≤ 3 corrections as the live bound and BOTH terminal branches as fences (the gone-row one pre-empted in the app by the projection arm, first in `adopt`) | `79a73919` |

**Constraints honored:** zero restore-body edits (the five fix commits touch the landing half's new code,
two doc blocks, the layout forwards, two VM call-site reroutes and the unit's own new test file); the 3C
rule stands — no pre-existing pin was edited (both test edits are in `LandingAimTests`, NEW at this unit);
nothing drifted beyond doc/pin/routing class.

**Suite runs on the fixed tree (this reviewer's own, zero app instances):** the landing family
(TakesArticleWatchTests 12 · LandingAimTests 6 — the +1 is the new guard · LandingAuthorityTests ·
LandingSignpostTests · TakesArticleScrollTests 40 · ArticleLandingProjectionArmTests · TakesLandingTests):
**✔ 79 tests in 7 suites passed**; the teardown-road suites (TakesCardHeightTests · TakesEmptyStateTests ·
FocusHandoffTests · EditorRouterActiveTests): **✔ 31 tests in 4 suites passed**.

**Round 2:** not earned by content — no new BLOCKER/MAJOR arose in round 1 or in this fix pass; the
ladder's round-2 re-review of the fixes is the orchestrator's call per the standing rules.
