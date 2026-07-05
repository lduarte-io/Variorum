# Variorum — Detailed Plan for Phases (Master Plan)

This is the master build plan. It holds: the phase table, the **current phase pointer**, and a running one-paragraph closeout per completed phase. Per-phase execution plans live in `notes/plans/`, written **just-in-time, one phase ahead** — never plan the whole app up front. The closeout of phase N is the starting context for phase N+1.

**Workflow rules** (also in `CLAUDE.md`): every step in an execution plan has tests; tests run at the END of a step/phase, never at the start of a session (the previous closeout is the baseline); schema/model changes get their own commit; deferred work goes to `KnownIssuesAndTechDebt.md` only with an owning phase named. **Closeout of phase N includes writing phase N+1's execution plan AND a kickoff message** (at the top of that plan file) that a fresh session can start from.

---

## Current phase

**→ Phase 1 — Schema & migrations** *(Phase 0 closed 2026-07-04; kickoff message at the top of `notes/plans/phase-01-schema-and-migrations.md`)*

---

## Phase table

| # | Phase | Goal (one line) | Key deliverables | Verification | Status |
|---|-------|-----------------|------------------|--------------|--------|
| 0 | **Docs & scaffold** | Canonical docs approved; repo + SPM skeleton building | `CLAUDE.md`, `notes/` docs (incl. `SyncSpec.md`), `VariorumCore` package skeleton, first commits | `swift test` green (placeholder); author approves docs (follow-up review session planned) | **done** |
| 1 | **Schema & migrations** | The full v1 schema as GRDB migrations, invariants DB-enforced, sync machinery in from day one | Migration `v1_core` (tables incl. `sync_version` columns + `sync_outbox`/`sync_state`, partial unique indexes, cascade + outbox triggers, seeds), record types, database stack (WAL, off-main-thread, in-memory test factory) | Invariant tests: I2/I3/I5 enforcement, tombstone+recreate under live-unique indexes, trigger cascades, outbox capture + `_sync_applying` suppression, RESTRICT guards | pending |
| 2 | **Operations I — lifecycle** | Every non-structural mutation as a tested transactional op | `newBlock`, `autosave`+churn, `commit`, `restoreCommit`, `branchVariant`, `newBlankVariant`, lock/unlock (variant+post), archive/delete variant (I10, default_variant reassignment), `deleteBlock`+tray, `moveBlock`, `reorder` (FractionalIndex Domain fn), tag ops, container/reading CRUD | Per-op state-transition tests; churn/80% + FractionalIndex as pure Domain functions with edge-case tests; invariant checks after randomized op sequences | pending |
| 3 | **Operations II — structural (the hard core)** | Extract / Divide (single + multi-variant W) / Merge exactly right | The three ops + boundary-snapping Domain functions (sentence/paragraph marks); lineage edges; reversibility (re-point at A) | Exhaustive state-transition tests incl. W mix-and-match (first-half-of-1 + second-half-of-3), unmarked-variant preservation, middle-span-extract rejection, merge non-cartesian | pending |
| 4 | **Read layer & perf harness** | Every view's traversal as a fast, observed query | `Queries` module: post render (chosen-variant concat), reading assembly (curated + smart + grouping), lineage CTE, tag subtrees, timeline, diff inputs, pool; ValueObservation wiring; seeded 10k-block corpus + benchmarks. Read side must tolerate referenced-but-missing rows (SyncSpec §5) | Query correctness tests; P1 benchmarks (cost flat in corpus size); P2 (no main-thread I/O) asserted | pending |
| 5 | **Sync core** | Two devices converge on one store, per SyncSpec | Supabase project + mirrored schema + seq/CAS functions (author assists setup); `VariorumCore/Sync`: push/pull engine, apply mode, merge matrix, unique-index repairs, conflict-as-variant | Two in-memory clients vs in-process fake server: convergence suites (offline edits, move/move races, tombstone races, working_text conflict→variant); one integration pass against real Supabase | pending |
| 6 | **TK2 spike (de-risk, throwaway)** | Decide editor architecture facts on Tahoe before building on them | Throwaway 50k-word scroll/jump/height prototype; fallback canary; run on M3/Tahoe with 26 SDK. **Prereq: Xcode 26 installed (both Macs)** | Decision memo: live TK2 geometry vs stored-estimate scrubber vs STTextView; recorded in AppSpec §15 + KnownIssues | pending |
| 7 | **App shell & editor core v1** | One calm editor over one post proving "cost ∝ viewport + edit" | Thin Xcode app target; TK2 `NSTextView` wrapper (block-ID attributes, read-cheap/edit-focused split); autosave pipeline; commit shortcut; minimal fan UI (branch/choose/badge) | Manual matrix run on Sequoia + Tahoe (canary silent-fallback check); 10k+ word post stays snappy; sync keeps converging under editor-rate writes | pending |
| 8 | **iOS journal capture** | The author journals from her phone — the app becomes daily-usable | Minimal iOS target over the same `VariorumCore` + Sync: create journal entries, edit existing blocks' active text, list/scroll past entries. No fan/variant gestures (CoreDescription §8) | Mac⇄iPhone round-trip convergence in real use; offline capture then sync; journal-entry conflict behavior verified | pending |
| 9 | **Structural ops in the editor** | Extract/divide/merge as editing gestures | Selection→boundary-snap UI, divide/extract gestures, multi-variant W ceremony (minimal), merge; identity maintenance over NSTextStorage edits | Op-correctness preserved through editor paths; boundary edge cases on both OSes | pending |
| 10 | **Readings & first views** | Prove the model under divergent traversals | Reading CRUD (curated + smart), continuous book view (virtualized), folder view, timeline view — functional, unstyled | Views render from store only; virtualization verified (P3); a tortured-to-build view = model finding, surfaced | pending |
| 11 | **Remaining views** | The full traversal set, functional and unstyled | Side-by-side, swap-and-reread, diff (whitespace toggle), expand-all-fans (stay-open + close-all), book-scrub, outline↔draft mapping, canvas board, pool UI + drag-copy | Each view over the same store; scrub honors the Phase 6 decision; P1/P3 spot checks | pending |
| 12 | **Hardening & perf validation** | The invariant holds at corpus scale, on Tahoe, under sync | Large-corpus stress (years of journals + a book), per-OS matrix run, sync soak (weeks of real two-device data), deferred-debt sweep | P1 benchmarks at scale; zero TK1 fallbacks; convergence holds; KnownIssues has no orphaned entries | pending |
| 13 | **UI design passes** | Make it beautiful — with the author, iteratively | Visual design, layout, interaction polish, theming; Liquid Glass where it earns its place | Author-driven acceptance; perf invariant re-verified after styling | pending |
| 14 | **Accounts & multi-tenant** | Commercial shape | `owner_id` populated, RLS on the same sync endpoints, auth | Isolation tests; existing single-user data migrates cleanly | pending |
| 15 | **iOS full surface** | Beyond capture: reading views, more of the model on mobile | Scope decided then (still no fan gestures unless the author revisits) | Same core + sync | pending |
| — | Web (WASM SQLite) | someday | — | — | unowned |

Phases may subdivide when their just-in-time plans are written; the table then gains rows (e.g. 3a/3b) rather than rewriting history.

## Sequencing rationale (why this order)

- **Schema before operations before UI** — correctness lives in the operations layer; the editor is a client of it.
- **Sync machinery is in schema v1** (author's direction: sync is early, not commercial-phase). Retrofitting outbox triggers, `sync_version`, and fractional-index positions after tables exist would mean migrating live data; a week of design now beats that forever.
- **Structural ops (3) before sync (5):** every write pattern the server will mirror gets proven locally first — schema flaws surface while migrations are still free, not after Postgres mirrors the schema in lockstep.
- **Sync (5) before the editor (7):** all UI code is born onto a sync-aware persistence layer (apply mode, outbox, repairs live from the start) — no retrofits — and the moment iOS capture (8) exists, the author starts journaling for real.
- **The TK2 spike (6) before the editor (7)** — `notes/TEXTKIT2_NOTES.md` §2 documents viewport/height/scroll-to-location as the stack's least reliable subsystem; the facts must be learned *on Tahoe* before book-scrub is designed onto them. Xcode 26 on both machines is this phase's hard prerequisite.
- **iOS capture (8) immediately after editor v1** — the author's stated priority: journal from the phone early, use the product while building it. Real daily use is also the best sync soak test.
- **Views split into first (10) and remaining (11)**; **UI design (13) after hardening (12)** — substrate first, beauty later, with the author; **accounts (14) reuse the same sync protocol.**

## Closeout log

*(One paragraph per completed phase: what shipped, verification result, anything deferred and where it went. Phase N's closeout is Phase N+1's starting context.)*

- **Phase 0 (closed 2026-07-04):** Canonical docs authored and committed — CLAUDE.md, CoreDescription, OverallModel, AppSpec (source-SPEC §14 questions all resolved; live-row partial unique indexes; two-table tagging per author), SyncSpec (new: author directed sync be handled now — hand-rolled row sync over Supabase chosen after PowerSync's JSON-view storage proved incompatible with DB-enforced invariants; positions redesigned to fractional-index TEXT; outbox/sync_version machinery moved into schema v1), master plan resequenced (sync phase 5, iOS capture phase 8), KnownIssues seeded with owned entries. `VariorumCore` SPM skeleton building with GRDB 7 + swift-dependencies; `swift test` green (placeholder). Author approved architecture answers (Observation + swift-dependencies, SPM core, Xcode 26 on both Macs — install pending, owned by Phase 6) and two-table tagging; a separate review session will re-examine Phase 0's decisions before Phase 1 work leans on them. Phase 1 plan + kickoff message written (`notes/plans/phase-01-schema-and-migrations.md`).
