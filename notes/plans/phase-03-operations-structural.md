# Phase 3 — Operations II: structural (the hard core)

## Kickoff message (for a fresh session)

> You are starting **Phase 3 of Variorum** — extract, divide (single- and multi-variant W), and merge exactly right, headless, each with its undo inverse. This is the hard core the whole app was designed around; get it right here and the editor phases are wiring, not invention. Read, in order: `CLAUDE.md`, `notes/OverallModel.md` §7 (the split taxonomy — the conceptual contract), `notes/AppSpec.md` §9 (extract/divide/merge/poolDragCopy semantics — authoritative, including the two documented behaviors: restoreCommit-predates-split and fanned-extract), the **Phase 2 closeout** at the bottom of `notes/plans/phase-02-operations-lifecycle.md` (your baseline: the full non-structural ops API + undo core exist; **`swift test` = 153 green on the Air — do not re-run at session start**), and this plan. Key inherited machinery — reuse, don't rebuild: the `Operations` scaffold (`liveBlock`/`liveVariant`/`liveContainer`, `ensureUnlocked`/`ensurePlacementUnlocked`, `containerPosition` for `InsertPosition` resolution, one clock read per op), `placeBlock` (the W-reversibility primitive; refuses doubly-placed blocks), `chooseVariant`, `registerTextChange` (call it from any op that edits `working_text` — extract and single-divide do), `FractionalIndex`, and the Step 8 undo pattern (capture pre-images inside the transaction, return them out, register an **internal revert operation** after success; inverses are exact-row flips + `placeBlock`, never re-derivations). Triggers stay a closed set (tombstone propagation + outbox capture) — if any structural op seems to want a semantic trigger, stop and run the trigger-smell protocol in the Phase 2 plan's Risks. Work step by step; each step lands with tests; Domain functions get their own commits. When done, run the closeout ritual (record results here, update the master plan table + pointer, write the Phase 4 plan — read layer & perf harness — with its own kickoff message).

**Goal:** the three structural operations plus `poolDragCopy`, with boundary-snapping Domain functions, lineage edges, exhaustive state-transition tests (including W mix-and-match and both documented behaviors), and undo round-trips. Zero UI, zero queries beyond what tests need, zero sync engine.

**References:** @notes/AppSpec.md §9 (operation semantics), §7 `edge` DDL note (directionality: source = descendant, target = ancestor; `version_of` stored canonically `(min,max)` — Phase 3 mints only `derived_from`); @notes/OverallModel.md §7; Phase 2 closeout (scaffold inventory, undo pattern).

---

## Ground rules (inherited)

- Every operation = one transaction; ops never re-implement what triggers own.
- Structural ops run under the same guards as Phase 2: live targets, `ensurePlacementUnlocked` (a sealed post's structure is frozen), locked-variant rules where buffers are edited.
- Edge rows: `derived_from`, `origin_op` ∈ {'divide','merge','extract','pool_copy'}, source = the new/descendant block, target = the ancestor.
- Text-editing structural ops (extract, single-divide) call `registerTextChange` for the churn/touch stamps.
- Undo: pre-images at do-time; inverses are internal revert ops; register after the transaction succeeds; refusals leave the stack untouched.

## Steps

### Step 1 — Domain: boundary snapping
**Files:** `Sources/VariorumCore/Domain/BoundarySnapping.swift`, tests.
**Work:** pure functions over a variant's text (no GRDB): sentence- and paragraph-mark detection reusing/harmonizing with `SegmentationRules`' scanner; `snap(cut: Int, in text: String, granularity:) -> Int` (nearest sentence/paragraph boundary); span classification for extract — `extractableSpan(_ range: Range<Int>, in text: String) -> ExtractableSpan?` returning `.prefix`/`.suffix` (boundary-adjacent) or nil (middle span → the caller rejects with a typed error: that's a divide). Careful with Unicode: operate on `String.Index`/unicode scalars consistently; document the offset convention the editor will use (TextKit 2 works in UTF-16 — decide the boundary API's unit now and note it for Phase 7).
**Tests:** snapping at/near sentence marks incl. terminator runs and closing quotes; paragraph snapping on newline runs; cut at 0/end; empty text; middle-span → nil; prefix/suffix classification exact; multi-paragraph blocks.

### Step 2 — extract (source survives)
**Files:** `Sources/VariorumCore/Operations/Operations+Structural.swift`, tests.
**Work (AppSpec §9):** `extract(blockA, span)` — span must classify as boundary-adjacent prefix/suffix of A's *rendered/chosen-or-default… decide precisely: the spec says "A's active variant" = the variant the live slot renders (chosen falling back to default)*. INSERT block B + variant(text = span, trimmed consistently with `SegmentationRules`); UPDATE that one variant of A = remainder (other variants untouched); INSERT `container_block`(B) adjacent to A (before A for a prefix, after A for a suffix); edge (B derived_from A, 'extract'). Middle span → typed error. Refusals: sealed post, locked/archived rendered variant (its buffer is edited), unplaced A (extract needs adjacency — decide: refuse `blockNotPlaced`). Churn: A's container gets `registerTextChange` (delta = span length). **Fanned-extract documented behavior:** extracting from a fanned block edits only the rendered variant; other variants keep their span copy — land the test that documents duplication after a later `chooseVariant` switch (AppSpec review #10).
**Undo inverse:** pre-images: A's variant text, B's ids. Revert = restore A's variant text, tombstone B (+ its variant, placement, edge — B is fresh, so `revertExtract` can tombstone by exact ids captured at do-time). Round-trip test to row equality.

### Step 3 — divide, single-variant (the everyday cut)
**Files:** same extension, tests.
**Work:** `divide(blockA, cut)` where A's live slot renders its only active variant (the ~95% case — detect automatically; multi-variant W is a separate op below): snap/validate cut (0 < cut < length → else typed error); INSERT block C + variant(text = A[cut:]); UPDATE A's rendered variant = A[:cut] (A keeps identity as first half); INSERT `container_block`(C) immediately after A; edge (C derived_from A, 'divide'). Same refusals as extract. Churn via `registerTextChange`.
**Tests:** exact rows; A's commits untouched (**and the restoreCommit-predates-split documented test lands here**: commit A whole, divide, restoreCommit → A's buffer holds the full pre-split text while C sits next door — assert and document, editor warning owned by Phase 7 per KnownIssues); order (A then C); edge directionality; refusals.
**Undo inverse:** restore A's variant text + tombstone C (fresh ids captured at do-time).

### Step 4 — divide, multi-variant (W)
**Files:** same extension, tests.
**Work (the one ceremony):** `divideW(blockA, cuts: [variantID: cut])` — marked variants carry the cut through; unmarked stay on A as lineage. A is **preserved whole**: tombstone A's placement (release, don't delete — A stays live and unplaced), leave A's variants and commits untouched. INSERT blocks B and C; for each marked variant Vi in fan order: INSERT variant on B (text Vi[:cutᵢ]) and on C (text Vi[cutᵢ:]), fan positions preserving Vi's relative order; B/C defaults = the halves of A's rendered variant (or first marked); placements B then C where A stood (two fresh positions between A's old neighbors); edges (B derived_from A, 'divide'), (C derived_from A, 'divide'). Chosen variants on the new placements: the halves of the variant A's slot rendered, if marked; else NULL. Validate: every cut within its variant's bounds; at least one marked variant; refusals as above.
**Tests:** W mix-and-match — first-half-of-attempt-1 with second-half-of-attempt-3 via `chooseVariant` on B and C independently; unmarked variants remain on A, untouched; A live + unplaced (the unplaced-blocks query's population); reversibility: tombstone B/C placements + `placeBlock(A)` restores the reading (the promise made real); exact fan orders.
**Undo inverse:** revert = tombstone B and C (blocks + fresh children by captured ids) and un-tombstone A's exact placement row (pre-image: its id) — the Step 8 `revertDeleteBlock` placement-flip pattern.

### Step 5 — merge (mirrors W)
**Files:** same extension, tests.
**Work:** `merge(blockB, blockC)` — both live, placed **adjacently in the same container** (validate; typed error otherwise), same rendered-variant resolution. INSERT block A' + ONE variant(text = rendered(B) + separator + rendered(C) — decide the separator: "\n\n" if both multi-paragraph…? **Don't invent:** spec says "chosen(B) + chosen(C)"; concatenate exactly, no separator, and document — the author sees the raw join in the editor and adjusts). Fans are NOT cartesian-producted — A' gets exactly one variant. Release B and C's placements (tombstone; blocks stay live/unplaced as lineage); INSERT placement A' where B stood; edges (A' derived_from B, 'merge'), (A' derived_from C, 'merge').
**Tests:** exact rows; non-adjacent/cross-container refusal; non-cartesian (one variant on A'); B/C fans + commits untouched; reversibility via placeBlock; edge pair.
**Undo inverse:** tombstone A' (fresh ids), flip B and C's placement rows back.

### Step 6 — poolDragCopy
**Files:** same extension or `Operations+Pool.swift`, tests.
**Work (AppSpec §9):** `poolDragCopy(poolBlock P, to post, at, includeFan: Bool = false)` — INSERT block B; copy P's rendered variant's `working_text` into B's variant (default) — or the whole live fan when `includeFan` (fan positions/statuses copied; commits are NOT copied — lineage is coarse); INSERT placement at the drop point (chosen = copy of P's rendered variant); edge (B derived_from P, 'pool_copy'). P must live in a pool (typed error otherwise — decide whether post→post copy is in scope; spec names the pool, so refuse and note). Target post unsealed.
**Tests:** active-only vs includeFan row sets; P untouched; edge; refusals; undo (tombstone B + children by captured ids).

### Step 7 — sweep extension + closeout
**Files:** `InvariantSweepTests.swift` (extend).
**Work:** add extract/divide/divideW/merge/poolDragCopy (+ their undo) to the random op generator; predicates unchanged plus: every `derived_from` edge's origin_op ∈ the known vocabulary; released blocks (live, unplaced) never violate I10.
**Closeout:** ritual per CLAUDE.md — results here, master plan table + pointer, **Phase 4 plan + kickoff** (read layer: post render, reading assembly, lineage CTE, tag subtrees, timeline, pool, ValueObservation, 10k-block perf harness; read side tolerates referenced-but-missing rows per SyncSpec §5).

## Explicitly out of scope
Editor gestures and selection→boundary UI (Phase 9). Cross-block re-bracketing (KnownIssues, Phase 9). Queries/observation (Phase 4). The restoreCommit editor warning (Phase 7). Any UI.

## Risks / things to watch
- **The rendered-variant question recurs in every op here** (which variant does extract cut? which halves does W choose by default? what does merge concatenate?). Resolve it ONCE as a shared helper (`renderedVariant(db, blockID)` — chosen falling back to default, matching `renderedLength`'s COALESCE semantics) and test it directly.
- **Text-offset units.** Boundary snapping, cuts, and spans must agree on one unit (String.Index vs UTF-16 vs scalars) — TextKit 2 speaks UTF-16; tests must include multi-scalar graphemes (emoji, combining marks) so the convention is proven, not assumed.
- **W's fan bookkeeping** (marked/unmarked, order preservation, default/chosen on B and C) is the deepest state transition in the app — write the exact-row test FIRST for one worked example, then generalize.
- **Undo of ops that mint blocks** tombstones fresh rows by captured ids — never by stamp equality (the fresh rows never had a cascade stamp). Only placement *releases* (W, merge) flip by exact row id.
- **Trigger smell protocol** stands (Phase 2 plan, Risks) — unused in Phase 2; if a structural op wants a semantic trigger, stop and reassess before writing it.

---

## Closeout (2026-07-05)

**Result: complete. `swift test` green on the Air — 219 tests, 0 failures** (153 baseline + 66 new: 25 boundary snapping, 16 extract + rendered-variant resolution, 15 divide single + W, 6 merge, 4 poolDragCopy — plus the extended sweep and the review round's additions). **This is the Phase 4 baseline — do not re-run at session start.**

**Commits:** `4160910` (Step 1, Domain — own commit per convention), `7a57dbf` (Step 2 extract), `6f086fb` (Step 3 divide), `b756c78` (Step 4 divide-W), `b9b3af8` (Step 5 merge), `975b4d7` (Step 6 poolDragCopy), `cce86d0` (Step 7 sweep), `463eedd` (post-phase review round).

**What shipped, step by step:**
1. **`BoundarySnapping`** (Domain, pure): sentence/paragraph boundary detection mirroring `SegmentationRules`' coarse scanner exactly (terminator runs + closers + whitespace; decimal numbers don't split; newline always ends a sentence); `snap` to nearest boundary, distance ties to the earlier one; `extractableSpan` classification (prefix/suffix/nil, whitespace-tolerant at the text's outer edges, whole-text and blank spans refused); seam-trimmed halves. **The offset unit is decided for the editor phases: UTF-16 code units (TextKit 2's NSRange unit), every offset validated to a grapheme-cluster boundary — mid-emoji/mid-combining offsets answer `nil`/typed errors, never a guess.** Proven on ZWJ-family emoji and combining marks.
2. **`renderedVariant`** — the one shared answer to "which text does a structural op cut": chosen-if-live-and-active-and-same-block, else default-if-live, matching `renderedLength`'s COALESCE (which gained the same same-block guard). Tested directly (chosen wins / archived / tombstoned / foreign / NULL / unplaced).
3. **`extract`** — source survives: B minted adjacent (before A for a prefix, after for a suffix), span fully trimmed, remainder seam-trimmed, edge `(B derived_from A, 'extract')`, churn registered. Fanned-extract duplication landed as the documented-behavior test (review #10).
4. **`divide`** — the everyday in-place cut: A keeps identity as the seam-trimmed first half, C minted after, edge `'divide'`, churn; refuses fanned blocks toward W. The restoreCommit-predates-split documented test landed here (editor warning stays owned by Phase 7).
5. **`divideW`** — the ceremony: marked variants carry their cuts through in fan order (B = first halves, C = second halves; mix-and-match proven via `chooseVariant`); A preserved whole and released live-unplaced, unmarked variants untouched; defaults/chosen = rendered's halves if marked, else first marked with chosen NULL; locked marked variants copy through (copying isn't editing). Reversibility-by-`placeBlock` tested as a real gesture.
6. **`merge`** — mirrors W: strict same-container adjacency validated; A' gets exactly ONE variant = `rendered(B) + rendered(C)` **concatenated exactly, no separator invented** (spec literal; ratify item below); both sources released to lineage; edge pair `'merge'`.
7. **`poolDragCopy`** — copy + lineage: rendered text by default, whole live fan with `includeFan` (statuses/labels/fan positions copied, parent tree remapped inside the copy, commits never copied, copies not born locked); source must live in a pool, target must be an unsealed post.
8. **Undo** — one shared inverse, `revertStructural`: pre-image text restores (+ divergence insurance, below), fresh-block tombstones by captured ids (the trigger cascade takes children — fresh rows by construction), released-placement flips by exact row id (position + chosen intact). Refusal buckets sorted deliberately per the Phase 2 rule: **resolvable refusals throw and keep the entry** (sealed container, dead/archived/locked restore target — all resolvable by public ops, and LIFO guarantees any registered resolver sits above); **divergence skips quietly** (minted block already deleted, released block re-homed → I2 wins, dead container). Undone mints deliberately don't stamp `last_container_id` — they must not haunt the tray.
9. **Sweep extension:** the five structural ops (+ undo) joined the 7-seed × 250-op generator (snapped cuts mostly, arbitrary offsets sometimes — refusal paths are product too); new predicate: every `derived_from` edge carries a known `origin_op`; text generator now emits multi-scalar graphemes and terminators.

**The trigger smell never appeared.** No structural op wanted a semantic trigger; releases and undo tombstones compose with the existing cascade set untouched. No schema findings; nothing tortured. Notably, the whole undo system needed zero new machinery — `revertStructural` is tombstone-flips + text restores, exactly what the pointer religion promised.

**Post-phase adversarial review (same session, independent pass over the full diff):** confirmed **no reachable I2/I3/I5/I10 violation and no undo-stack wedge** (every throwing revert path is resolvable by a public op; obsolete entries pop quietly). Two findings fixed, with regression tests:
- **Undo insures diverged buffers** — restoring a pre-image over a buffer edited *after* the structural op would have destroyed the edit with no recovery; `revertStructural` now appends one quiet `kind='auto'` commit first (only when actually dirty). This is the **fourth quiet auto-commit occasion** (after post-seal, variant-lock, long-idle), same doctrine: the operation insures exactly what it's about to make unreachable.
- **Releases stamp `last_container_id`** (divideW's A, merge's B and C) — a released block deleted later now trays and restores home instead of stranding.
Plus hardenings: foreign-chosen guard in `renderedVariant`/`renderedLength` (a corrupt cross-block chosen pointer can no longer make a structural op rewrite another block's text — falls back, tested); one trim implementation at extract's seam; snapping contract documented on the ops ("offsets arrive pre-snapped; the operation validates, never snaps" — the editor owns `BoundarySnapping.snap`).
Reviewed and accepted as-is (documented, no code change): neighbor SQL uses strict position comparison without the `(position, id)` tiebreak — unreachable locally under jittered keys, and SyncSpec §8 calls residual ties harmless; a revived placement may carry a chosen pointer that died in between — the read-time fallback rule covers it (same class as SyncSpec §7's repair); undo's buffer restore doesn't feed churn/touch — undo restores state, it isn't an authorial gesture.

**Interpretations to ratify (author should skim; none block Phase 4):**
1. **Seam trimming on divide/divide-W** — the spec's literal `A[:cut]`/`A[cut:]` would store the separator whitespace inside block text; the halves are trimmed at the cut seam instead, per the settled doctrine "separators are re-created by the rendering join, never stored." (Extract's trim was already plan-directed.)
2. **Merge concatenates with NO separator** — `"First half." + "Second half."` renders as `First half.Second half.`; deliberately not invented per the plan; the author sees the raw join and adjusts. If a `"\n\n"` or `" "` join is wanted, it's a one-line ratified change.
3. **Undo divergence insurance** (review fix above) — undo of extract/divide auto-commits a buffer edited since the op before restoring the pre-image.
4. **`includeFan` copies archived takes too** (statuses copied, per this plan's wording) — the reviewer notes OverallModel defines "fan" as the *active* set, so a stricter reading would copy active only. Current behavior: whole live fan, statuses preserved. Flip = one `AND status='active'`.
5. **Structural ops work in pools** — a pool scrap can be extracted/divided/merged like a post block (same container type, no rule against it). Pool→draft is the only copy direction for `poolDragCopy`.
6. **Extract places the prefix BEFORE the source** (suffix after) — reading order preserved; the spec said only "adjacent."
7. **UTF-16 as the offset unit** everywhere in the structural API (decided per plan; matters to Phase 7/9 editor code).

**Deferred/notes for Phase 4:** nothing new in KnownIssues (the tray-semantics entry there is *narrowed* by the release-stamping fix: container-cascade victims remain the only stale-`last_container_id` population). Phase 4 must reuse the rendered-variant COALESCE semantics (now guarded, see `renderedVariant`) rather than re-derive them; the unplaced-blocks population (released A/B/C) now exists for real and has a cheap query; the sweep's "any SQLite error is a failure" stance carries forward.
