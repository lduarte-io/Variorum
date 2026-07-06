# Phase 6 — TK2 spike (de-risk, throwaway)

## Kickoff message (for a fresh session)

> You are starting **Phase 6 of Variorum** — the TextKit 2 de-risking spike: learn the viewport/height/scroll facts **on Tahoe, on the M3, against the 26 SDK** before any editor code is designed onto them. Read, in order: `CLAUDE.md`, **`notes/TEXTKIT2_NOTES.md` in full — it is this phase's authoritative companion** (§0 the silent-fallback mental model, §2 the viewport/height/scroll-to-location problem this spike exists to answer, §3 the category bugs, §4 the defensive practices — opt-in constructor, canary, no TK1 API ever — §5 the per-version matrix, §6 the STTextView escape hatch), `notes/AppSpec.md` §4 (the P1 performance architecture the editor must deliver and the spike's known risk paragraph) and §15 risks 1–2, and the master plan's Phase 6 row. Key context: **this is throwaway code** — a standalone executable under `Spikes/`, never a `VariorumCore` target, never a dependency of anything; the quality bar is measurement rigor, not production polish, and `Sources/VariorumCore` is untouched this phase (**baseline: `swift test` = 372 green in 36 suites — do not re-run at session start**). The phase's deliverable is a **decision memo** — live TK2 geometry vs stored per-block length estimates vs STTextView, per surface — and that memo is **the author's to accept** (a Phase 6-class gate, CLAUDE.md: never adjudicated autonomously). Two standing author-only lines you cannot cross: adding STTextView (or any dependency) is her call — during the spike it is a *decision option on paper*, not a package to fetch; and if a GUI run needs signing/TCC/Xcode steps beyond `swift run`, pause and ask. Also note the open Phase 5 gate (real-Supabase integration pass, KnownIssues) — not this phase's work, but the checkpoint report should remind her it is waiting.

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
