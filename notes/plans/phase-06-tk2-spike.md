# Phase 6 — TK2 spike (de-risk, throwaway)

## Kickoff message (for a fresh session)

> You are starting **Phase 6 of Variorum** — the TextKit 2 de-risking spike: learn the viewport/height/scroll facts **on Tahoe, on the M3, against the 26 SDK** before any editor code is designed onto them. Read, in order: `CLAUDE.md`, **`notes/TEXTKIT2_NOTES.md` in full — it is this phase's authoritative companion** (§0 the silent-fallback mental model, §2 the viewport/height/scroll-to-location problem this spike exists to answer, §3 the category bugs, §4 the defensive practices — opt-in constructor, canary, no TK1 API ever — §5 the per-version matrix, §6 the STTextView escape hatch), `notes/AppSpec.md` §4 (the P1 performance architecture the editor must deliver and the spike's known risk paragraph) and §15 risks 1–2, and the master plan's Phase 6 row. Key context: **this is throwaway code** — a standalone executable under `Spikes/`, never a `VariorumCore` target, never a dependency of anything; the quality bar is measurement rigor, not production polish, and `Sources/VariorumCore` is untouched this phase (**baseline: `swift test` = 373 green in 37 suites — do not re-run at session start**; the 37th suite is the env-gated Supabase integration test, which skips without credentials, so plain `swift test` stays network-free). The phase's deliverable is a **decision memo** — live TK2 geometry vs stored per-block length estimates vs STTextView, per surface — and that memo is **the author's to accept** (a Phase 6-class gate, CLAUDE.md: never adjudicated autonomously). Two standing author-only lines you cannot cross: adding STTextView (or any dependency) is her call — during the spike it is a *decision option on paper*, not a package to fetch; and if a GUI run needs signing/TCC/Xcode steps beyond `swift run`, pause and ask. (The Phase 5 author-assist gate — the real-Supabase integration pass — closed 2026-07-06; nothing from Phase 5 is waiting. See the gate-closure round at the end of `notes/plans/phase-05-sync-core.md`.)

**Goal:** establish, with numbers on Tahoe, whether book-scrub / infinite-scroll / scroll-to-location can trust live TK2 geometry — or must drive off stored per-block estimates — or whether the editor core should be STTextView; decide the fallback-canary posture; hand Phase 7 a settled foundation.

**References:** @notes/TEXTKIT2_NOTES.md (all); @notes/AppSpec.md §4, §12 (book-scrub, the read-cheap/edit-focused split), §15 risks 1–2; @notes/OverallModel.md §5 (P1–P3); master plan row 6; KnownIssues "TK2 viewport viability decision" (owned by THIS phase).

---

## Ground rules

- **Throwaway means throwaway:** everything lives in `Spikes/TK2Spike/` (its own SPM executable package booting `NSApplication` programmatically — no Xcode project, no app target; that arrives Phase 7). Nothing under `Sources/` or `Tests/` changes. The spike is kept in-repo after the phase as evidence, clearly labeled — never imported.
- **TK2 discipline from the first line** (TEXTKIT2_NOTES §4): create the view with `NSTextView(usingTextLayoutManager: true)`-equivalent explicitly; never touch `.layoutManager` or any `NSLayoutManager` API (a guaranteed downgrade trigger on 26); install the fallback canary (`willSwitchToNSLayoutManager` / `didSwitchToNSLayoutManager`) before anything else and treat any firing as a headline finding.
- **Measure, don't vibe:** every fact gets a number (ms, px, counts) captured by the harness and written into this file's findings section. Record the exact macOS build (`sw_vers`) and Xcode/SDK version with the results — the §5 matrix makes results point-release-scoped by definition.
- **P1 shapes what counts as a pass:** any strategy that needs `ensureLayout` over the whole document (seconds of work; TEXTKIT2_NOTES §2) is a fail *by definition*, whatever its accuracy.
- **No new dependencies.** STTextView is evaluated from its documentation/source as a decision option; fetching it is an author call at the memo.

## Steps

### Step 1 — Harness
**Files:** `Spikes/TK2Spike/Package.swift`, `Spikes/TK2Spike/Sources/main.swift` (+ small support files).
**Work:** SPM executable that opens one window with a TK2 `NSTextView` in an `NSScrollView`; deterministic 50k-word corpus generator (seeded; paragraph-shaped, mixed paragraph lengths, a few very long paragraphs — the shapes journals/books actually have); the fallback canary wired to `assert` + a visible log; a tiny measurement recorder (named probes → ms/px values dumped as a table on exit). Include **block-ID-like custom attributes on every paragraph range** — the real editor rides custom attributes (AppSpec §4), so every fact must be measured with them present.
**Verification:** app launches via `swift run`, renders the corpus, canary silent at rest.

### Step 2 — Fact A: silent-fallback triggers
**Work:** exercise the known trigger classes (typing at several positions; attribute updates; selection sweeps; find; spell-check toggle) with the canary armed. Any fallback = record the exact action.
**Verification:** a written list — either "no fallback observed under: …" or the trigger inventory.

### Step 3 — Fact B: height estimation & scroll stability
**Work:** measure `usageBoundsForTextContainer` at load, then continuously while scrolling to the end; count/size estimate revisions; scroll-to-end correctness (does the last line render?); window-resize reflow behavior (the §2/§3 cropping and jumping reports).
**Verification:** drift profile recorded (initial estimate vs settled height, number of revisions, any jumps), scroll-to-end pass/fail.

### Step 4 — Fact C: scroll-to-arbitrary-location (the book-scrub question)
**Work:** for target positions at 10/25/50/75/90% through the document, try in order: (a) scroll to estimated y via the scroll view; (b) `relocateViewport(to:)` (undocumented for this use — treat as an experiment, not a foundation); (c) a bounded hybrid (estimate, then `ensureLayout` over just the landing viewport's range). Measure: landing error (px and paragraphs), time to stable layout, and whether the estimate-then-correct visual jump is acceptable.
**Verification:** a table: strategy × position → error/time/stability. This table IS the scrubber decision input.

### Step 5 — Fact D: typing latency at scale
**Work:** programmatic keystrokes (and a manual feel pass) at document start / middle / end with attributes present: measure keystroke→layout time, and re-measure after a large paste mid-document. This is P1's editor half — cost ∝ viewport + edit, never document size.
**Verification:** latency numbers at each position; a flat profile passes, growth with position/document size fails.

### Step 6 — Decision memo (AUTHOR GATE — the phase ends at her acceptance)
**Work:** write the memo into this file's findings section: per surface (continuous editor, infinite scroll, book-scrub, scroll-to-location) → live TK2 geometry / stored per-block length estimates (the AppSpec §4 fallback: estimates stored per block, scrubber driven off them, geometry corrected lazily) / STTextView (last resort, §6) — with the Step 2–5 numbers as evidence and a recommendation. Include the canary posture for Phase 7 (assert in debug, log in release?) and the §5 matrix row for the current point release. **Then stop and present it to the author** — acceptance, amendments, or a re-run are her calls. After acceptance: record the decision in AppSpec §15 (risk 2's resolution state) and resolve/re-scope the KnownIssues "TK2 viewport viability decision" entry.

### Step 7 — Closeout
Ritual per CLAUDE.md: results + the accepted memo here; master plan table + pointer; KnownIssues updated; **write the Phase 7 (app shell & editor core v1) plan + kickoff** from AppSpec §4/§12, TEXTKIT2_NOTES §4–5, and the accepted memo — Phase 7 also inherits the `AppDatabase.liveValue` failure-UX and structural-undo-UI KnownIssues entries and (still open unless closed by then) the Phase 5 Supabase gate. Commit per convention; never push.

## Explicitly out of scope
Any editor feature work (Phase 7). Block identity/attribute *semantics* (Phase 7; the spike only carries dummy attributes for realism). Within-post virtualization (Phase 12's evidence question). Adding STTextView as a dependency (author call, at or after the memo). Touching `VariorumCore`.

## Risks / things to watch
- **The spike answering the wrong OS:** all numbers are void if measured on anything but the M3's current Tahoe point release with the 26 SDK; re-record `sw_vers` in the findings on every run day (TEXTKIT2_NOTES §5).
- **A canary that never fires because the trigger set moved:** absence of evidence only counts for the actions actually exercised — keep Step 2's action inventory honest and written.
- **`relocateViewport` seduction:** it may look perfect in a quick test; §2 says unreliable in practice. It cannot be the foundation unless it survives repeated runs at every position — and even then the memo must flag its undocumented status.
- **Measuring without attributes:** TK2 attribute handling is implicated in several §3 bug classes; numbers taken on plain text would flatter the stack. The harness includes them from Step 1.
- **Scope creep toward "just build the editor here":** the spike proves facts; the moment it starts growing editor features, stop — that's Phase 7 on an unaccepted foundation.

---

## Findings (definitive run 2026-07-06)

**Environment (per-point-release scope, TEXTKIT2_NOTES §5 — all numbers below are void on any other point release until re-verified):** macOS **26.4.1 (build 25E253)** · Xcode **26.3 (17C519)** · macOS SDK 26.2 · Swift 6.2.4 · the author's M3 (arm64) · debug build via `swift run`. The harness auto-stamps macOS, Xcode, SDK, and Swift versions into every results artifact (`0.env` section), so a future point-release re-run cannot silently omit the toolchain. **Every figure below is quoted from the single archived definitive run** (`Spikes/TK2Spike/results-2026-07-06-macos26.4.1.log`, produced by the final post-review harness); earlier development runs on the same point release produced the same conclusions with ordinary run-to-run ms noise.

**Harness (Step 1 — verified):** `Spikes/TK2Spike/`, a standalone SPM executable booting `NSApplication` programmatically; nothing under `Sources/` or `Tests/` touched. Corpus: deterministic seeded generator, **50,084 words / 431 paragraph-blocks / 380,964 UTF-16 chars**, mixed paragraph lengths including three ~2,000-word giants and markdown-heading blocks; **a block-ID custom attribute on every paragraph range** (plus font/color). TK2 opt-in via the explicit `NSTextView(usingTextLayoutManager: true)` constructor, `precondition(textLayoutManager != nil)` at construction; no `.layoutManager`/`NSLayoutManager` API anywhere (grep-audited); all geometry probes are tk2Alive-guarded so a fallback run degrades into a complete recorded inventory instead of a crash (cold review, MINOR 1). Canary armed before content load. Launches via `swift run`, renders the corpus (setAttributedString 31.1 ms; first viewport layout 225.9 ms — first-window-of-process values, not load-bearing), **canary silent at rest**. Measurement scenarios are re-runnable individually (`load fallback height scrub typing ensure scale`); `swift run TK2Spike manual` is the author's feel-pass mode (live window, canary armed, stays open).

### Fact A — silent-fallback triggers (Step 2)

**No fallback observed under any exercised action.** Zero canary events for the whole run (every scenario, every harness instance); `textLayoutManager` non-nil after every action. Exercised inventory: typing bursts at start/middle/end (NSTextInputClient path, 30 chars each); `textStorage` attribute add/remove on visible + offscreen paragraphs (begin/endEditing); **rendering attributes** set + invalidate on visible ranges (the §3-fragile path — no crash, no fallback); selection sweep across the whole document (`setSelectedRange` far jumps: avg 0.53 ms, max 0.78 ms over 11 sweeps — cheap even to unlaid-out regions); find bar show/hide (`performTextFinderAction`); continuous spell checking toggled on over 50k words with misspellings typed, then off; a 2k-word attributed paste mid-document (12.3 ms); undo ×3. **Not exercised (out of product scope, honestly scoped):** NSTextList/lists, Writing Tools tables, custom caret drawing. Absence of evidence is scoped to this inventory on this point release.

### Fact B — height estimation & scroll stability (Step 3)

- **Estimate lifecycle:** initial `usageBoundsForTextContainer` = 47,690.75 px (**~9.7% below** the true height); one revision at rest (31.8 ms settle) → 48,971 px; **true height (post-full-layout) 52,309 px** — the *resting* estimate under-reports by **6.8%** on this corpus.
- **Scrolling to the end in 89 viewport steps:** **78 estimate revisions** en route, max single revision **1,187 px** (~2 viewports); the document-view height grows under the scroller as real layout replaces estimates. **Content never moved backward: 0 regression steps** (top-block monotonicity held the whole walk) — the drift is scrollbar-thumb breathing, not content jumping.
- **Scroll-to-end works, both ways:** after the incremental walk the last line is VISIBLE (fragment maxY == settled doc height); a **cold `scrollToEndOfDocument` from the top lands in 126 ms**, settles within **6 px** of the true end, last line VISIBLE. The §2 "can't scroll to the end" report **did not reproduce** on 26.4.1.
- **Window resize (one-shot 900→600 px):** reflow settles in ~106 ms, **no crop** (usage-vs-doc mismatch −0.2 px), **but the reading position drifts −79 paragraphs** — NSScrollView keeps the pixel offset while the geometry under it doubles, so the text under the viewport changes. Round trip (back to 900) returns within 5 blocks of the origin. **This, not height estimation, is the real position-loss hazard measured.**

### Fact C — scroll-to-arbitrary-location (Step 4 — the book-scrub question)

Strategy × position table, every sample on a **cold, fresh view** (5 positions × 3 reps; full detail in the archived log). Timing caveat: strategies A and D include the harness's settle protocol (~90 ms quiet-wait floor), so their meaningful metric is landing error; C's time is honest end-to-end work.

| Strategy | Landing error (max over 15 cold runs) | Time | Verdict |
|---|---|---|---|
| **A — proportional scroll** (fraction × docHeight) | 5 paragraphs / 436 px | settle-bound (~103 ms avg) | usable only as a first guess |
| **B — `relocateViewport(to:)`** | **never lands** | call 0.3–6.4 ms | **unusable — see below** |
| **C — bounded hybrid** (proportional + `ensuresLayout` on the ONE target fragment + scroll correction) | **0 paragraphs / 0.00 px; post-settle drift 0.00 px** | **avg 7.0 ms, p95 10.0 ms, max 13.1 ms; ≤1 correction iteration; 0 capped** | **the primitive** |
| **D — `scrollRangeToVisible`** | target visible 15/15, but up to 340 px from top (mid-viewport), position uncontrolled | settle-bound (~131 ms avg) | caret reveal only |

- **B's mechanism (the §2 warning, now with a reproduced cause):** `relocateViewport(to:)` instantly sets `viewportRange` to the target (15/15 reps), but **never moves the scroll view** (clip offset change 0.00 px in every rep) — and NSTextView's next layout pass derives the viewport from the *visible rect*, snapping the viewport straight back to where the scroll position says it is. It cannot be a scroll mechanism inside an `NSScrollView`-hosted NSTextView, full stop.
- **C is exact, stable, and flat in document size:** the correction magnitude (the would-be visible jump) was ≤436 px, but at ~7 ms total the landing completes within a display frame — corrected before anything is seen. Post-settle re-measurement: 0.00 px drift in all 15 runs. At **200k words: same 0-error landing, avg 6.6 ms, max 7.7 ms** (3 cold reps) — cost ∝ one fragment + one viewport, never the document. P1-shaped by construction and by measurement.

### Fact D — typing latency at scale (Step 5)

120-keystroke bursts through `insertText` (+ explicit viewport layout) with block-ID attributes present, cold view, debug build. **Measurement window (cold review, MINOR 3):** each timed sample covers `insertText` + the viewport layout pass only — drawing/display happens outside the timed window (draw cost is viewport-proportional by construction; the author's manual feel pass covers the full keystroke-to-glass path).

| Position | 50k words | after 5k-word paste (55k) | 200k words |
|---|---|---|---|
| start | avg 1.89 ms (p95 3.10) | avg 2.38 ms (p95 4.07) | — |
| middle | avg 1.76 ms (p95 2.18) | avg 1.55 ms (p95 2.16) | avg 2.09 ms (p95 2.75) |
| end | avg 1.04 ms (p95 1.24) | avg 1.12 ms (p95 1.59) | — |

**Flat in position and in document size** (averages 1.0–2.4 ms everywhere; worst single keystroke in 840 samples: 9.32 ms, still inside one 16.7 ms frame); the 5k-word attributed paste itself cost 4.5 ms + 31 ms settle. P1's editor half passes — edit-path averages sit 7–16× under the frame budget, and the profile does not grow with document size. The **manual feel pass remains an author item** (programmatic numbers can't judge feel — see the checkpoint list).

### Reference numbers

- **`ensureLayout(documentRange)`: 104.7 ms at 50k words, 408.1 ms at 200k** — linear in document size, hence banned from any user path by P1 exactly as the plan's ground rule states. (Note: §2's "seconds" did not reproduce at journal/book scale on the M3 — the ban stands on the scaling shape, not on the absolute number.)
- True height 52,309 px @ 50k words → avg ~121 px/block; 210,800 px @ 200k words.

### TEXTKIT2_NOTES §5 matrix row (this point release)

**macOS 26.4.1 (25E253) / Xcode 26.3 / SDK 26.2, M3:** (a) **no silent TK1 fallback** under the Step 2 inventory (canary armed the entire run); (b) **scroll-to-location exact** via the hybrid primitive; height estimate converges (**resting estimate 6.8% low, raw initial ~9.7% low**; content monotonic; end reachable cold and warm); (c) rendering attributes set/invalidate **without fallback or crash** — *visual* draw correctness deferred to the author's feel pass; (d) split/merge boundary selection behavior **not yet exercised** (Phase 9 concern; re-verify then).

---

## Decision memo — **ACCEPTED by the author, as written (2026-07-06)** — the Phase 6 gate, closed

*Accepted at the 2026-07-06 checkpoint after her manual feel pass (see the gate-closure round at the end of this file). The post-acceptance recordings landed the same day: AppSpec §14 delta + §15 risk 2 resolution + §16 bullet removed; the KnownIssues "TK2 viewport viability decision" entry resolved; QUESTIONS.md cleared; master plan row 6 fully done. Phase 7 is unblocked.*

**Per surface:**

1. **Continuous editor (one live NSTextView over the focused post) → live TK2 geometry. Adopt.** Typing is flat through 200k words with block-ID attributes present (edit-path averages 1.0–2.4 ms, p95 ≤ 4.1 ms; excludes draw, which is viewport-proportional — see Fact D's measurement-window note); paste is milliseconds; no fallback under any editor-shaped action. Nothing measured argues for anything else.
2. **Infinite scroll / reading long posts → live TK2 geometry. Adopt, with one documented cosmetic.** The height estimate revises while scrolling (78 revisions; the resting estimate is 6.8% low, the raw initial ~9.7% low, on 50k words), so the scrollbar thumb breathes slightly as estimates become real layout; content itself never regressed (0 backward steps). No stored-estimate machinery is needed for correctness here.
3. **Scroll-to-location (the jump primitive under book-scrub, timeline navigation, "go to block") → the bounded hybrid. Adopt as THE primitive.** Scroll to the proportional estimate, `enumerateTextLayoutFragments(from: target, options: [.ensuresLayout])` for the single target fragment, correct the scroll offset (≤1 iteration observed). Pixel-exact, zero post-settle drift, avg ~7 ms (max 13 ms) and flat from 50k to 200k words — cost ∝ viewport + one fragment, never the document (P1). **Never `relocateViewport(to:)`** — measured broken for this use (moves the viewport, not the scroll view; snapped back by the next layout pass, 15/15). `scrollRangeToVisible` stays for caret/selection reveal only (lands mid-viewport by design).
4. **Book-scrub (page = a post, AppSpec §12) → model-driven scrubber + hybrid landing. Stored per-block length estimates are NOT needed as the primary mechanism.** The scrubber's domain is the post list — pure model data (50 entries = 50 pages regardless of geometry); landing inside the rendered view is surface 3's primitive. Live TK2 geometry is never asked a question it answers slowly, so the AppSpec §4 fallback (stored per-block estimates driving the scrubber) stays a **documented, unbuilt door** — reopened only if a future point release breaks the hybrid (re-verified per the §5 matrix on every macOS update).
5. **STTextView → not warranted. Do not adopt; keep bookmarked** (TEXTKIT2_NOTES §6). No fallback, no instability, no perf cliff was measured; adopting it would add a dependency (an author-only call regardless) with zero measured justification. It remains the on-paper last resort if a point release regresses the above.

**Canary posture for Phase 7 (recommendation):** install the `willSwitchToNSLayoutManager`/`didSwitchToNSLayoutManager` observers in the first editor commit, before any feature code. **Debug builds: hard `assertionFailure` (stop the world). Release builds: `os_log` fault + a visible in-app diagnostic alert.** Rationale: the spike established that fallback is *not* a normal event on this stack — so any firing is a regression (a newly-touched API or an OS change), never telemetry noise. Silence must be re-earned per point release: re-run the spike's `fallback` scenario after every macOS update (the spike is now the §5 matrix's executable form).

**Phase 7 obligations handed over (measured, not speculative):**
- **Content-anchor scroll restoration across container width changes** — the one real position-loss hazard found (−79 paragraphs on a 900→600 reflow because NSScrollView keeps pixel offsets). Save the top visible text location before reflow, restore via the hybrid primitive after.
- **Restore scroll position by text location, never by pixel offset** (the estimate revises once shortly after load — 31.8 ms settle in the definitive run; a px-restored position lands on different content).
- **Keep decorations off the live editor** (TEXTKIT2_NOTES §4.5): rendering attributes were exercised clean programmatically, but §3 flags their *visual* reliability and the spike could not judge pixels by eye.
- **Re-run the spike after every macOS point update** before trusting any editor milestone (§5 matrix discipline).

**Caveats on all numbers:** debug build (`swift run`, unoptimized — release only improves); **the typing probe times `insertText` + viewport layout and excludes drawing/display** (draw cost is viewport-proportional; the author's feel pass covers the full keystroke-to-glass path); programmatic one-shot scrolling and resize (no momentum-scroll phases, no live resize drag); one NSTextView holding the whole 50k-word post is the AppSpec §4 worst case (real views page by post per P3); single point release (26.4.1) — the §5 matrix makes every row re-verifiable by construction.


---

## Closeout (2026-07-06) — implementation complete; **author gate CLOSED same day — see the gate-closure round below**

**What shipped:** the Step 1 harness (`Spikes/TK2Spike/`, commit `717d01c`, review-round fixes in a follow-up commit — standalone SPM executable, deterministic 50k-word attributed corpus, canary, measurement recorder, seven re-runnable scenarios + a `manual` feel-pass mode), the definitive Tahoe 26.4.1 measurement run (archived in-repo as `Spikes/TK2Spike/results-2026-07-06-macos26.4.1.log`, regenerated post-review), the findings above (Facts A–D, all with numbers), the §5 matrix row for 26.4.1, and the decision memo — **PENDING AUTHOR ACCEPTANCE**. `Sources/VariorumCore` and `Tests/` untouched; baseline remains **373 green in 37 suites** (per the ground rule, not re-run this phase — no core code changed).

**Verification per step:** Step 1 — launches via `swift run`, renders the corpus, canary silent at rest ✅. Step 2 — written inventory recorded; no fallback under any exercised action ✅. Step 3 — drift profile recorded (78 revisions, resting estimate 6.8% low / raw initial ~9.7% low, 0 backward content steps), scroll-to-end PASS cold and warm ✅. Step 4 — the strategy × position table exists and is decisive (hybrid: 0-error, avg ~7 ms, flat to 200k; relocateViewport: reproducibly broken) ✅. Step 5 — programmatic latency flat in position and scale ✅; **manual feel pass = author item** (a subjective judgment was not simulated). Step 6 — memo written above, gate open. Step 7 — this closeout; master plan pointer advanced with the gate flagged; Phase 7 plan + kickoff written **contingent on the memo**.

**Deviations from the plan text, with dispositions (for the cold reviewer):**
- *Canary default = record-and-continue, assert behind `TK2SPIKE_STRICT=1`* (ground rule said "wired to assert + a visible log"). Reason: a hard assert on the first firing would truncate Step 2's trigger inventory — the phase's deliverable is the *complete* inventory. The assert wiring exists (strict mode); the loud log is unconditional; any firing is recorded with the in-flight action. Judged within the spike's measurement-rigor mandate, not a product call. (Moot in practice: zero firings.)
- *Two additions beyond the plan's letter:* strategy D (`scrollRangeToVisible` — what naive code would use; measured to keep it off the scrub path deliberately) and the 200k-word `scale` scenario (proves the hybrid's flatness on P1's document-size axis — the memo's strongest claim needed that data point). Additions, not substitutions; every planned measurement ran.
- *Step 4's settle-protocol floor* (~90 ms quiet-wait) dominates strategies A/D's timings; recorded as a caveat in the findings so the table isn't misread. C's timing has no settle inside the measured window and is honest end-to-end.
- *Sequencing per coordinator instruction:* AppSpec §15 **not** updated and the KnownIssues "TK2 viewport viability decision" entry **not** resolved — both explicitly wait for the author's acceptance of the memo (the plan's own Step 6 sequencing).

**PROVISIONAL calls:** none of product-behavior class. The memo itself is the phase's author gate (logged in `notes/QUESTIONS.md` for the checkpoint walk, alongside the feel-pass item).

**Author items (the checkpoint list):**
1. **Accept / amend / re-run the decision memo above** — the Phase 6 gate. Everything downstream (AppSpec §15 risk-2 resolution, KnownIssues re-scope, Phase 7 start) waits on this.
2. **Manual feel pass** (Step 5's human half): `cd Spikes/TK2Spike && swift run TK2Spike manual` — type at start/middle/end, scroll hard, **drag-resize live** (the spike only measured one-shot resize), jump via the scroller; judge feel, selection, and whether text draws cleanly. The canary prints loudly if TK1 ever appears. Anything that feels off goes back into the memo before acceptance.

---

## Cold review round (2026-07-06) — 0 BLOCKER / 0 MAJOR / 4 MINOR / 4 NIT; all dispositions recorded

All fixes landed **before** author acceptance (the memo remains PENDING AUTHOR ACCEPTANCE; amending it pre-gate is legal per the coordinator). The definitive results log was **regenerated with the post-review harness** and re-archived at the same path (`results-2026-07-06-macos26.4.1.log`; the pre-review log survives in git history at `717d01c`); the findings and memo were restated strictly from it — every ms figure shifted only by ordinary run-to-run noise, and **no conclusion changed**.

1. **[MINOR] Record-and-continue canary defeated by force-unwrapped geometry accessors — AGREED, fixed.** All `Harness` geometry accessors (`tlm`, `contentManager`, `viewport`, `usageHeight`, `layoutViewport`, location/fragment helpers) are now tk2Alive-guarded (optional/sentinel/no-op), and every scenario site whose core needs TK2 records an explicit `"TK2 DEAD — geometry probes skipped"` row instead of crashing — a future point-release fallback run now degrades into a *complete* recorded inventory, which is the very rationale the closeout's deviation #1 claimed. The strict-mode assert wiring is unchanged.
2. **[MINOR] Memo figures not traceable to the archived log — AGREED, fixed.** Root cause: several figures aggregated unarchived development runs. Fix: one regenerated definitive run is now the sole source; the findings header states this explicitly, and the previously-untraceable figures (keystroke max, relocateViewport call range, setAttributedString, first-viewport-layout, settle-at-rest, selection-sweep timings) were requoted from the archived log. "Measure, don't vibe" now holds down to provenance.
3. **[MINOR] Typing window excludes drawing — AGREED, fixed.** Fact D now opens with a measurement-window note (insertText + viewport layout; draw excluded, viewport-proportional, covered by the author's feel pass), the same sentence joined the memo's caveats, and the "order of magnitude of headroom" claim was restated honestly: averages 1.0–2.4 ms (7–16× under the 16.7 ms frame), p95 ≤ 4.1 ms, worst single sample 9.32 ms — still within one frame. The flatness conclusion (the load-bearing one) is unchanged.
4. **[MINOR] Phase 7 plan baked in unflagged product interpretations — AGREED, fixed.** The Phase 7 ground rules now carry a three-item flagged-interpretations list for the author's kickoff walk: (1) one-live-NSTextView-per-post (already flagged), (2) the editor-surface block separator (new interpretation — Phase 4 ratified `"\n\n"` for the `renderedText` projection only; options `"\n"` / `"\n\n"` / styled-`"\n"` presented, (a) provisional), (3) multi-block edit gestures (refuse-clamp / implicit-merge / whole-block-only presented, (a) provisional — a product call, hers). Steps 2–3 reworded to reference the flags instead of presenting either as settled.
5. **[NIT] "6.8% initial error" conflated resting vs raw initial estimate — AGREED, fixed.** Matrix row, memo surface 2, and the closeout verification line now state both: resting estimate 6.8% low, raw initial ~9.7% low. (The findings body was already correct.)
6. **[NIT] Toolchain not auto-stamped into results — AGREED, fixed.** The harness now records Xcode (`xcodebuild -version`), macOS SDK (`xcrun --show-sdk-version`), and Swift (`swift --version`) into `0.env` alongside the macOS build; the regenerated archived log carries all four. A point-release re-run can no longer silently omit the toolchain.
7. **[NIT] Table row "done" while the phase's own definition ends at acceptance — NOTED, no change (convention).** As the reviewer states: Phase 5 precedent, loudly flagged in the pointer, this closeout, and QUESTIONS.md; the row's verification column completes at acceptance. The "(memo gate open)" suffix on the status cell is the guard against misreading.
8. **[NIT] Corpus separator newline: attribute ownership ≠ offset ownership — AGREED (documentation), spike code unchanged.** Harmless for layout measurement (which block's ID rides the separator does not affect geometry), so the throwaway corpus stays as-is; the real lesson is now a written warning in Phase 7 Step 2: separator/boundary-char membership is a deliberate `BlockRangeIndex` decision where attribute ownership and range math must agree — never an inherited accident. Related micro-nits, documented with no change: `runFallback` reuses pre-edit corpus offsets after ~90 chars of typed drift (those actions are trigger-exercisers, not position-precise probes); `stats()` p95 on n=3 is the nearest-rank median (max is always printed beside it; the n=15/n=120 aggregates are the load-bearing tails).

---

## Gate-closure round (2026-07-06) — the memo ACCEPTED as written; Phase 6 fully closed

Walked with the author at the checkpoint, after both review rounds:

1. **Manual feel pass (author item 2) — run by the author, PASS.** Her notes, recorded: typing "looks great"; overall "working great." Scroller behavior observed (hold-and-drag scrubs; clicking the track doesn't jump) and endorsed as the right feel — noted here for accuracy that this is the macOS system default ("Click in the scroll bar to: jump to the next page"), not spike code, and the book-scrub UI is its own deliberate control regardless. Margins are tight ("not much whitespace around the edges … a little hard on the eyes, like TextEdit") — recorded as a legibility note for the UI design pass (Phase 13); the spike is deliberately unstyled, and a basic `textContainerInset` is a one-line Phase 7 request if it bothers daily use before then. No canary output reported.
2. **Decision memo (author item 1) — ACCEPTED AS WRITTEN.** She independently affirmed two of its points before reading it: no STTextView (her stated ground was commercial licensing; corrected for the record — STTextView is MIT-licensed and commercially usable, so the last-resort escape hatch remains genuinely open; the memo's operative ground stands: zero measured justification) and the resize hazard must be handled (confirmed already a Phase 7 obligation three ways: the "never px-anchor" ground rule, Step 7's content-anchored restore, and Step 7's manual resize test).
3. **The three flagged Phase 7 interpretations — confirmed at the same walk**, all three as the provisional/recommended readings (recorded in the Phase 7 plan and AppSpec §14): (1) **one live NSTextView per focused post** (the per-block read-only tier becomes load-bearing at Phase 10's multi-post views); (2) **single-`"\n"` editor-surface separator** (option a — distinct from Phase 4's `"\n\n"` ratification, which covers the `renderedText` projection only); (3) **cross-block destructive edits refuse/clamp in v1** (option a — real structural gestures are Phase 9's).
4. **Post-acceptance recordings landed (this commit):** AppSpec §14 author-decision delta, §15 risk 2 resolution, §16 "TK2 viewport viability" bullet removed; KnownIssues entry resolved and removed; QUESTIONS.md cleared; master plan pointer's GATE OPEN flag removed, row 6 **done**, Phase 6 closeout paragraph updated; the Phase 7 plan's contingency banner replaced with the gate-closed record and its interpretations marked confirmed.
