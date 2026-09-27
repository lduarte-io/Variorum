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
