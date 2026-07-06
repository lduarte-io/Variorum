# Phase 7 — App shell & editor core v1

> ## ✅ GATE CLOSED 2026-07-06 — this plan stands as written
> The Phase 6 decision memo was **accepted by the author as written** at the 2026-07-06
> checkpoint, after her manual feel pass (PASS — notes in the gate-closure round of
> `notes/plans/phase-06-tk2-spike.md`). The post-acceptance doc updates landed the same
> day: AppSpec §14 delta + §15 risk 2 resolution + §16, KnownIssues entry resolved,
> QUESTIONS cleared. The three flagged interpretations in the ground rules below were
> **confirmed by the author at the same walk** — all three as the provisional readings:
> post-level live view, single-`"\n"` separator, refuse/clamp. Phase 7 may start.

## Kickoff message (for a fresh session)

> You are starting **Phase 7 of Variorum** — the app shell and editor core v1: one calm
> editor over one post, proving "cost ∝ viewport + edit" in a real app. **First, verify the
> Phase 6 gate is closed** (the master plan pointer no longer says GATE OPEN; the memo in
> `notes/plans/phase-06-tk2-spike.md` is marked accepted; `notes/QUESTIONS.md` has no open
> Phase 6 items) — if it is not, stop and report. Read, in order: `CLAUDE.md`,
> `notes/TEXTKIT2_NOTES.md` in full (§4's defensive practices are law in this phase),
> `notes/AppSpec.md` §2 (code architecture), §4 (P1 — the editor's reason for being),
> §9 (the operations the editor calls: `autosave`, `commit`, `branchVariant`,
> `newBlankVariant`, `chooseVariant`, locks, structural undo), §12 (views stance,
> badge behavior), `notes/OverallModel.md` §3 (mutability rule) and §5 (P1–P3), **the
> accepted Phase 6 memo + findings** (the spike's numbers are this phase's performance
> contract), the four KnownIssues entries owned by Phase 7 (AppDatabase.liveValue failure
> UX; structural-undo UI wiring; sentence-mode crystallization; restoreCommit pre-split
> warning), and this plan in full. Key context: **baseline is `swift test` = 373 green in
> 37 suites — do not re-run at session start** (the 37th suite is env-gated Supabase and
> skips without credentials). The Phase 5 sync gate is closed; sync is live machinery —
> every editor write flows through Operations onto the outbox, and Step 8 verifies
> convergence under editor-rate writes. **Step 1 is an author-assist gate** (Xcode app
> target creation is a machine-side GUI step — hers per CLAUDE.md); structure the session
> so headless work proceeds until she is available. The editor core is AppKit (TK2
> `NSTextView` via `NSViewRepresentable`); SwiftUI does all chrome; view models are
> `@Observable`, hold projections, call operations, contain no business rules. Never touch
> `.layoutManager` or any `NSLayoutManager` API. Views are functional and unstyled — zero
> polish until Phase 13.

**Goal:** a thin macOS app target over `VariorumCore` with a TK2 editor for a single post — block identity riding text attributes, autosave + churn through Operations, the commit shortcut, a minimal fan UI, the canary installed from the first editor commit — snappy at 10k+ words, converging under sync, with the memo's scroll disciplines built in from day one.

**References:** accepted Phase 6 memo (scroll primitives, canary posture, Phase 7 obligations); AppSpec §2, §4, §9, §12; OverallModel §3, §5, §9; TEXTKIT2_NOTES §3–§5; AppSpec §15 risk 1 (live block-identity maintenance — **this phase's hard core**); KnownIssues rows owned by 7.

---

## Ground rules

- **TK2 discipline is not optional:** explicit `NSTextView(usingTextLayoutManager: true)`; no TK1 API anywhere in the app target (grep-audit before every commit); **canary in the first editor commit** — debug `assertionFailure`, release `os_log` fault + visible in-app diagnostic (memo posture). Any firing is a P1-class bug.
- **The editor is a client of the operations API.** It renders projections (`Queries.renderPost`) and sends operations; it never writes rows. Identity is validated against the DB, never inferred from the text view (AppSpec §15 risk 1: if the editor corrupts identity, the store must stay safe).
- **Scroll discipline from the memo:** restore and navigate by *text location* via the bounded hybrid jump primitive; never px-anchor across reflow or relaunch; never `relocateViewport(to:)`; `scrollRangeToVisible` for caret reveal only; **no `ensureLayout` beyond a single target fragment, ever** (P1).
- **Domain rules stay pure and tested** (crystallization via `SegmentationRules`, boundary math, range bookkeeping). UI-only glue may go untested early; anything with logic may not.
- **Re-verify after any macOS point update mid-phase:** re-run the spike (`Spikes/TK2Spike`, all scenarios) and the §5 matrix checks before trusting results gathered pre-update.
- **Interpretations — all three CONFIRMED by the author 2026-07-06 at the Phase 6 gate walk** (recorded in AppSpec §14; the options are kept below for the record)**:**
  1. **One live NSTextView per focused post:** editor v1 renders the focused post as **one live TK2 NSTextView** whose paragraph ranges carry block-ID attributes (AppSpec §4 "block IDs ride block ranges"; the spike measured exactly this shape flat to 200k words). AppSpec §4's read-cheap tier ("only the focused block/post upgrades") is satisfied at this phase's scale by the *post* being the focused unit; the per-block/per-post read-only tier becomes load-bearing at Phase 10's multi-post views. If she prefers the stricter per-block-live reading now, Step 3's design absorbs it (the range index is the same either way). **Confirmed 2026-07-06: post-level live view.**
  2. **Editor-surface block separator (cold review, MINOR 4):** what character(s) sit between blocks *in the live editor's text storage* is a new interpretation — Phase 4 ratified `"\n\n"` only for the `renderedText` *projection* (export/diff), a different surface. Options: (a) single `"\n"` (visually adjacent paragraphs; block chrome/spacing via paragraph styles or overlays), (b) `"\n\n"` (matches the projection's look but puts a stored-nothing blank line inside the editable surface), (c) `"\n"` + paragraph-spacing styling to *look* like `"\n\n"`. Step 2 provisionally assumes (a) as the minimal-separator reading (every separator char in the editable surface is a char the range index must police). **Confirmed 2026-07-06: option (a), a single `"\n"`.**
  3. **Multi-block edit gestures in v1 (cold review, MINOR 4 — everyday action, spec-undefined):** what happens when a selection spans a block boundary and the author types/deletes. Options: (a) refuse/clamp cross-block destructive edits until Phase 9's real gestures (safest for identity; mildly annoying), (b) treat boundary-erasing deletion as an implicit `Operations.merge` (spec-shaped but it *is* a structural op firing from a plain keystroke — against the "one deliberate ceremony" spirit), (c) allow whole-block deletion only via an explicit block gesture (`deleteBlock` + tray). Step 3 provisionally assumes (a). **Confirmed 2026-07-06: option (a), refuse/clamp — the Step 3 tests target it.**

## Steps

### Step 1 — App target (AUTHOR-ASSIST GATE) + shell
**Files:** `App/` (Xcode project + thin target `Variorum`), `App/Variorum/VariorumApp.swift`, `App/Variorum/RootView.swift`, `App/Features/Library/` (minimal post list + create).
**Work:** the author creates the thin Xcode app target wrapping the `VariorumCore` package (project structure per AppSpec §2; deployment target macOS 26). Root composition wires `@Dependency(\.database)` to a real on-disk store (Application Support path). **Resolve the KnownIssues "AppDatabase.liveValue failure UX" entry:** the live value must not `fatalError` in the app — a failed open surfaces a recovery alert (retry / reveal file / quit) with the error preserved. Minimal library sidebar: list posts (`Queries.library` bounded observation), create a post, select one to edit — chrome only, no business rules.
**Tests:** core-side unit test for the recoverable-open path (a corrupted/locked store produces the typed failure the shell renders); `xcodebuild -scheme Variorum build` green; manual launch shows the (empty) library.

### Step 2 — Editor module: TK2 view + canary + projection render
**Files:** `App/Features/Editor/EditorView.swift` (NSViewRepresentable), `EditorTextView.swift`, `EditorViewModel.swift`, `FallbackCanary.swift`.
**Work:** TK2 text view with the canary armed at init (memo posture); `EditorViewModel` (@Observable) loads one post via `Queries.renderPost` observation and materializes the editor string: blocks in `position` order, block-ID custom attribute over each block's range, separated per **flagged interpretation 2** (provisionally a single `"\n"`; the stored-nothing separator is a render-time artifact — blocks own their internal newlines per I4; empty chosen takes render as empty slots per the Phase 4 ratification). **Separator ownership is a deliberate decision, decided once and tested** (Phase 6 review note: the spike corpus accidentally had the separator newline carry the *following* block's attribute while offset bucketing assigned it to the *preceding* one — the editor must not inherit a boundary-membership accident; attribute ownership and range math must agree on which block, if either, owns the separator char). Read path only in this step: external store changes re-render when the buffer is clean.
**Tests:** pure attribute-mapping function (blocks → attributed string with ranges; ranges → block IDs) unit-tested both directions, incl. empty takes and multi-paragraph blocks; canary wiring compiles in both configs; manual: a seeded 10k-word post renders and scrolls.

### Step 3 — Live block identity over NSTextStorage (the hard core)
**Files:** `App/Features/Editor/BlockRangeIndex.swift` (+ tests), edit-notification plumbing in `EditorTextView`.
**Work:** maintain block→range mapping *live* during editing (AppSpec §15 risk 1): every edit reports its exact changed range; `BlockRangeIndex` (pure, UTF-16 offsets — the Phase 3 unit decision) shifts/grows the owning block's range and never lets edits leak across block boundaries; Enter inside a block is content (I4). **Type-time crystallization at the post tail** (AppSpec §7 segmentation trigger): typing past a completed paragraph in the open tail mints a block via `Operations.newBlock` using `SegmentationRules.crystallizedBoundary`; the trailing open paragraph is not yet a block. Bulk paste into the tail segments on entry (`bulkSegments`). Crystallization never touches existing blocks.
**Tests:** exhaustive `BlockRangeIndex` unit tests (insert/delete at start/middle/end/boundary of a block, cross-block edit gestures per **flagged interpretation 3** — the author's kickoff call decides refuse/clamp vs implicit-merge vs whole-block-only, and the tests target that decision, grapheme edge cases reusing Phase 3's corpus patterns, separator-ownership cases per **flagged interpretation 2**); crystallization: typing past one paragraph mints exactly one block with the right text and position, open tail stays unminted, paste mints N; integration: after a scripted edit session, DB rows equal the text view's content per block.

### Step 4 — Autosave pipeline + churn
**Files:** `App/Features/Editor/AutosaveCoordinator.swift`.
**Work:** debounced per-variant autosave through `Operations.autosave` (char-delta from the edit reports feeds churn per AppSpec §10); writes off the main thread (P2); the coalescing outbox absorbs keystroke-rate writes (S1 — already proven; here just *don't defeat it*). The buffer is authoritative while dirty; observation-driven re-renders are suppressed until clean (single-author local editing; sync conflicts arrive as new variants, never buffer clobbers — S5).
**Tests:** debounce coalesces a burst into one `autosave` per quiet gap (deterministic clock via `@Dependency(\.date)`); churn accumulates and stamps exactly as §10 (integration against core); main-thread I/O assertion (reuse the Phase 4 P2 pattern).

### Step 5 — Commit shortcut + history + pre-split warning
**Files:** `App/Features/Editor/CommitBar.swift` (or menu wiring), `CommitHistoryView.swift`.
**Work:** ⌘S = `Operations.commit(variant, kind: manual)` (flushes pending autosave first); minimal per-variant commit list with restore (`restoreCommit`). **Resolve the KnownIssues "restoreCommit pre-split warning" entry:** restoring a commit older than the newest divide/extract lineage edge on that block shows the documented warning (AppSpec §9) before proceeding.
**Tests:** the predates-split predicate as a pure function over commit timestamp + the block's `derived_from` edges (origin_op divide/extract, block as ancestor); commit flush ordering (autosave-then-commit yields the buffer text exactly).

### Step 6 — Minimal fan UI (branch / choose / badge)
**Files:** `App/Features/Editor/FanBadge.swift`, `FanPanel.swift`, view-model additions.
**Work:** the corner badge appears **only** on blocks with >1 live active variant (AppSpec §12); clicking it opens a functional fan panel: variant cards (working_text preview, label, lock state), `branchVariant` / `newBlankVariant` gestures, `chooseVariant` on the pointer (I3 — the slot re-renders), archive/delete via their ops (refusals — I10, chosen-guard, seal — surface as plain alerts). Calm default: no fan machinery visible on unfanned blocks.
**Tests:** VM-level — badge predicate; choose swaps the rendered slot text; refusal paths render the op's error; no business rules in the VM (ops do the enforcing — assert by construction/review, not mocks).

### Step 7 — Structural-undo UI wiring + scroll utilities
**Files:** menu wiring in the app target; `App/Features/Editor/JumpPrimitive.swift`.
**Work:** **Resolve the KnownIssues "structural-undo UI wiring" entry** (Phase 7's slice): an Edit-menu "Undo Structural Change" (distinct from command-Z, which stays NSTextView's text undo — the stacks never interleave, OverallModel §3) that **serializes `undo()` calls** (the entry's race note); labels can stay generic until Phase 9 adds gestures. Implement the memo's scroll utilities: the bounded hybrid jump (proportional estimate → single-fragment `ensuresLayout` → correction loop, capped) as the one navigation primitive; content-anchored restore across window reflow and editor reopen (top visible text location, restored via the primitive).
**Tests:** serialization guard (two concurrent undo requests execute one-at-a-time); jump-primitive correction loop logic unit-tested with a fake geometry source; manual: resize a 10k-word post — reading position holds (the spike's −79-paragraph failure mode, now guarded).

### Step 8 — Phase verification
**Work:** full-suite `swift test` (expect ≥ baseline 373 + this phase's additions) + app-target tests; the TEXTKIT2_NOTES §5 milestone checks on the current Tahoe point release: (a) canary silent through a real editing session, (b) scroll/height stable on a 10k+ and a 50k-word post (spike re-run if a point update landed mid-phase), (c) live decorations (badge, any highlight) draw and update, (d) selections at block boundaries behave (Phase 9 owns the gestures; this is a smoke check). **Sync under editor-rate writes:** a scripted session against the editor-backed store while the Phase 5 engine syncs a second in-memory client — convergence (byte-identical synced tables, empty outboxes) must hold. 10k+-word post stays snappy (keystroke cost flat — the spike numbers are the budget).
**Sentence-mode crystallization (KnownIssues, author call):** present the question at the checkpoint with the editor in hand — never decide autonomously.

## Explicitly out of scope
Structural op gestures and cross-block selection re-bracketing (Phase 9); multi-post/virtualized views and the per-block read-only tier as a perf necessity (Phase 10); iOS capture (Phase 8); any styling/theming (Phase 13); pool UI, reference panel, exports (Phase 11); within-post virtualization (Phase 12's evidence question).

## Risks / things to watch
- **AppSpec §15 risk 1 is this phase's center of gravity:** live identity over `NSTextStorage`. Every editor bug class lands here — keep `BlockRangeIndex` pure, exhaustively tested, and reconciled against the DB (the store must survive any editor bug).
- **TK2 §3 category bugs:** rendering-attribute unreliability (keep decorations minimal on the live view — badge and fan chrome live in SwiftUI overlays, not text attributes, wherever possible), selection oddities at boundaries, spell-check/completion crash (ship the diagnostic toggle).
- **Point-release drift:** a macOS update mid-phase voids spike numbers until re-run (§5 matrix).
- **Scope creep toward Phase 9:** the moment a selection gesture wants to split a block, stop — that's Phase 9 on this phase's foundation.
- **The buffer-vs-observation loop** (Step 4): re-render suppression while dirty must be airtight, or the editor fights its own autosave echo. Sync's apply path never touches `working_text` of a dirty local variant except via the S5 conflict path — trust it, don't re-guard it in UI.
