# Phase 2 — Operations I: Lifecycle (Execution Plan)

**Status:** ready to start

## Kickoff message (for a fresh session)

> You are starting **Phase 2 of Variorum** — every non-structural mutation as a tested transactional operation. Read, in order: `CLAUDE.md`, `notes/OverallModel.md` §2–7 (objects, mutability rule, invariants), `notes/AppSpec.md` §9–10 (the operations catalog — your contract — and churn), `notes/SyncSpec.md` §8–9 (fractional positions, ID/time rules), the **Phase 1 closeout** at the bottom of `notes/plans/phase-01-schema-and-migrations.md` (your baseline: schema + triggers + records exist; `swift test` = 37 green on the Air — do not re-run at session start), and this plan. Key inherited facts: tombstone cascades and outbox capture are **triggers** — operations never re-implement them; operations own semantic side-effects (timestamps via `@Dependency(\.date)`, IDs via `@Dependency(\.uuid)`, `last_container_id`, default-variant reassignment); the deleteVariant/chosen-variant guard is **ops-layer** (schema RESTRICT only guards physical purge); tag *subtree* deletion is an ops-layer loop. Work step by step; each step lands with its tests; Domain functions get their own commits. Structural ops (extract/divide/merge) are **Phase 3 — do not build them**, but the undo core you build here must be shaped so Phase 3 ops can register inverses. When done, run the closeout ritual (record results here, update the master plan table + pointer, write the Phase 3 plan with its own kickoff message).

**Goal:** the full non-structural operations API (AppSpec §9) as single-transaction functions over `AppDatabase`, with the three pure Domain function families (FractionalIndex, churn, segmentation) tested independently, the session-scoped structural-undo core in place, and invariants holding under randomized op sequences. Zero UI, zero queries beyond what tests need, zero structural ops, zero sync engine.

**References:** @notes/AppSpec.md §9 (operation semantics — authoritative), §10 (churn); @notes/OverallModel.md §3–6; @notes/SyncSpec.md §8–9; Phase 1 closeout in `notes/plans/phase-01-schema-and-migrations.md`.

---

## Ground rules (from CLAUDE.md + Phase 1)

- Every operation = **one transaction** through `AppDatabase.write`; no ad-hoc row edits, ever.
- IDs from `@Dependency(\.uuid)` (v4), time from `@Dependency(\.date)` formatted via `DateFormatter.variorumISO8601`. Tests override both (`.incrementing`, fixed dates).
- Operations *read* current rows and *write* records/SQL — they never rely on triggers for semantics, and never duplicate what triggers do (cascade tombstones, outbox rows).
- Text-changing ops also update `container.last_touched_at` + churn (§10). Which ops are "text-changing": autosave, commit (stamps major revision), restoreCommit.
- Domain rules are pure functions in `Sources/VariorumCore/Domain/` with edge-case tests, no GRDB imports.

## Steps

### Step 1 — Domain: `FractionalIndex`
**Files:** `Sources/VariorumCore/Domain/FractionalIndex.swift`, tests.
**Work:** base-62 lexicographic keys (SyncSpec §8): `between(_ a: String?, _ b: String?) -> String` (nil = open end), with **per-call random jitter** — randomness via `withRandomNumberGenerator` / an injected generator so tests are deterministic. Also `initial()` for first insertion. No rebalance function exists — do not add one.
**Tests:** result strictly between inputs (property-style over many random pairs); open ends (nil,x)/(x,nil)/(nil,nil); repeated bisection never exhausts (depth 200+ stays ordered, strings grow); jitter: two calls with the same neighbors differ (under different RNG seeds); output alphabet is base-62 only; degenerate adjacent keys (e.g. "a","a0") still produce a strict in-between.

### Step 2 — Domain: churn math (the 80% sort)
**Files:** `Sources/VariorumCore/Domain/Churn.swift`, tests.
**Work:** pure function per AppSpec §10: given `(accumulator, baseline, charDelta, threshold)` → new accumulator + `didCrossThreshold` (inserts + deletes equal weight; crossing ⇒ caller stamps `last_major_revision_at`, resets accumulator, rebaselines to current text length). Read `major_revision_threshold` from `setting` at the ops layer, not in the Domain fn.
**Tests:** fixing a typo in a 10k-char post never crosses; steady accumulation crosses exactly at `churn/max(baseline,1) ≥ threshold`; baseline 0 (empty post) doesn't divide-by-zero; reset + rebaseline semantics; threshold configurable.

### Step 3 — Domain: segmentation (type-time crystallization rule)
**Files:** `Sources/VariorumCore/Domain/Segmentation.swift`, tests.
**Work:** two pure functions (AppSpec §7 setting note; author decision 2026-07-04):
- `bulkSegments(text, mode)` — split pasted/imported/captured text into block texts (`one_block` | `paragraph` | `sentence`); used by paste/pool-drop/capture paths later.
- `crystallizedBoundary(openTail)` — for type-time crystallization: given the open tail of a post, report the completed-paragraph prefix (if any) that should become a block, and the remaining tail. The editor (Phase 7/9) calls this; Phase 2 only proves the rule.
Crystallization never touches existing blocks (I4 holds by construction — it only sees not-yet-block text).
**Tests:** paragraph mode splits on blank-line/newline paragraph marks; sentence floor; one_block passthrough; open tail with no completed paragraph → no boundary; trailing-newline edge cases; empty/whitespace-only input.

### Step 4 — Operations scaffold + container/reading CRUD
**Files:** `Sources/VariorumCore/Operations/Operations.swift` (the API type: `@Dependency(\.database)`, `\.date`, `\.uuid`), `OperationError.swift`, `Operations+Container.swift`, `Operations+Reading.swift`, tests.
**Work:** the `Operations` entry point (a struct/namespace all features call); errors as a typed enum (`.blockNotFound`, `.lastActiveVariant`, `.variantIsChosen`, `.lockedVariant`, `.lockedPost`, `.wrongContainerKind`, …). CRUD: create/rename/archive/delete container (post + pool; delete = tombstone → trigger cascades the chain), `entry_date`/profile/segmentation-default setters, floating-notes update; create/update/delete reading (curated + smart fields), `addPostToReading`/`removePostFromReading`/`reorderReadingPost` (FractionalIndex).
**Tests:** exact row transitions per op (rows read/written, before/after); deleting a post cascades (via triggers) and the outbox captures everything; reading membership recreate-after-tombstone works (live-unique index).

### Step 5 — Block & variant lifecycle
**Files:** `Operations+Block.swift`, `Operations+Variant.swift`, tests.
**Work (AppSpec §9 semantics exactly):**
- `newBlock(container:text:at:)` — block + variant + default_variant + placement (position via FractionalIndex between neighbors).
- `autosave(variant:text:charDelta:)` — update `working_text`/`updated_at`; churn accumulate on the owning container (threshold-cross ⇒ stamp + reset + rebaseline); update `last_touched_at`. Refuse on locked variant / locked post.
- `commit(variant:kind:message:)` — insert `commit_point`; counts as a major revision (stamp). Refuse on locked post (lock forbids new commits); locked *variant* buffer is frozen but `commit` of the current text is a no-op question — **spec says lock freezes buffer + no new commits while post-locked; variant-locked commit: propose to author if ambiguity bites, default refuse.**
- `restoreCommit(variant:commit:)` — load text into `working_text` (append-only history untouched, I5). Document (test) the restores-pre-split-text behavior placeholder — the actual pre-split scenario lands with Phase 3's divide test.
- `idleAutoCommit(post:)` — for each dirty live variant under the post (working_text ≠ its latest commit text, or no commit yet and non-empty): one `kind='auto'` commit. Idle detection (the 24h clock) is the caller's job (app phase); the op takes "commit now if dirty".
- `branchVariant(block:from:)` (copy text, parent pointer, next fan position) / `newBlankVariant(block:)`.
**Tests:** per-op state transitions; autosave churn integration (typo no-stamp / rewrite stamps); commit ordering by `(created_at, id)`; idleAutoCommit is idempotent (second call = no new commits) and skips clean variants; branch inherits text + parent; blank take doesn't.

### Step 6 — Locks, archive/delete, placement ops
**Files:** `Operations+Locks.swift`, `Operations+Deletion.swift`, `Operations+Placement.swift`, tests.
**Work:**
- `lockVariant`/`unlockVariant`; `lockPost`/`unlockPost` — lockPost first auto-commits dirty live buffers (kind='auto'), then freezes (no edits, no commits, pointer order + chosen variants frozen — enforced as refusals in the other ops); all reversible.
- `archiveVariant`/`deleteVariant` — **ops-layer guards** (Phase 1 note: RESTRICT won't fire): refuse if it's any live slot's `chosen_variant_id` (re-point first); refuse if last live *active* variant of a live block (I10 — "delete the block instead"); on removing the `default_variant_id` → reassign to most-recently-updated active variant.
- `deleteBlock(block:)` — set `last_container_id`, tombstone block (triggers cascade variants/placement/edges/block_tags); the tray query is Phase 4, the data is now.
- `placeBlock(block:container:at:)` — insert placement for a live block with **no live placement** (refuse otherwise; this is the W-reversibility primitive).
- `restoreBlock(block:)` — clear the block's tombstone + those of children whose `deleted_at` **equals** the block's (cascade-victim identification), then placeBlock into `last_container_id`.
- `moveBlock(block:container:at:)`, `reorder(block:betweenA:andB:)` — position updates via FractionalIndex; single ownership preserved by the live-unique index (test the constraint path too).
**Tests:** every refusal path; default-variant reassignment; restoreBlock resurrects cascade victims but NOT independently-deleted rows (different `deleted_at`); placeBlock refuses double placement; move/reorder keep `(position, id)` order sane.

### Step 7 — Tags & references
**Files:** `Operations+Tag.swift`, `Operations+Reference.swift`, tests.
**Work:** `createTag(parent:name:)` (path = parent.path + '/' + name), `renameTag` (rewrite `name` + materialized `path` of the tag **and its whole subtree** in one transaction), `deleteTag` (tombstone the subtree via ops-layer loop — triggers only handle each tag's applications), `applyTag`/`removeTag` for posts (enforce `kind='post'`) and blocks; `addReference`/`removeReference`/`updateReferenceViewState`/`reorderReference`.
**Tests:** renameTag rewrites descendants' paths exactly, one transaction; path uniqueness violations surface as typed errors; deleteTag tombstones the subtree + applications; post_tag on a pool refused; reference CRUD transitions.

### Step 8 — Undo core (structural undo, session-scoped)
**Files:** `Sources/VariorumCore/Operations/UndoStack.swift`, tests.
**Work (AppSpec §9, author decision):** an in-memory, session-scoped stack. Registered ops (this phase): `deleteBlock`, `deleteVariant`, `archiveVariant`, `moveBlock`, `reorder` (+ `poolDragCopy` when it exists — Phase 3 registers divide/merge/extract). Each op registers its **inverse as ordinary operations** (tombstone-flips, placeBlock, position restore) — sync never knows undo exists. Not persisted; text editing / commits / locks / tags excluded by design.
**Tests:** round-trip per registered op (do → undo → row-state equality modulo `updated_at`/outbox); undo emits outbox rows like any op; stack is LIFO; unregistered ops don't pollute the stack.

### Step 9 — Randomized invariant sweep + closeout
**Files:** `Tests/VariorumCoreTests/InvariantSweepTests.swift`.
**Work:** a seeded-random sequence generator over the Phase 2 op set (valid calls only — refusals count as no-ops), then assert DB-wide predicates after each run: every live block has ≥1 live active variant (I10) and a non-dangling `default_variant_id`; at most one live placement per block (I2); commits append-only (count never decreases); no live row references a tombstoned parent except via the documented chosen-variant fallback; all positions sort stably.
**Closeout:** ritual per CLAUDE.md — results here, master plan table + pointer, **Phase 3 plan + kickoff** (structural ops: extract/divide/merge + boundary snapping + their undo inverses).

## Explicitly out of scope
Extract/divide/merge and boundary snapping (Phase 3). Queries/ValueObservation (Phase 4). Sync engine (Phase 5). Any UI. The idle-*detection* timer (app phase — the op only answers "commit if dirty"). If an op is tortured to express, treat it as a schema finding — surface it, don't force it.

## Risks / things to watch
- **Op ⇄ trigger boundary:** it is easy to accidentally re-tombstone children an op's trigger already handled (harmless but masks bugs) or to *depend* on a trigger for semantics (forbidden). Each op's test asserts the exact final row set, which catches both.
- **The trigger smell, and the protocol if it appears (author-ratified after the Phase 1 review):** the two trigger families — tombstone propagation and outbox capture — are a **closed set**. If any op in this phase feels like it *needs* a trigger with domain knowledge (which variant is default, what counts as dirty, lock enforcement, churn, `last_container_id`…), **stop; do not implement it, not even "temporarily."** That pressure is diagnostic. Re-assess, in order:
  1. **Mis-filed semantics?** Is the rule actually operation logic wearing a propagation costume? (Most cases — move it into the op's transaction and its state-transition test.)
  2. **Mis-decomposed operation?** Is one op trying to be two? Split it; each op stays one coherent transaction.
  3. **Mis-shaped schema?** Per CLAUDE.md guideline 5, an operation that is tortured to express means the schema is wrong, not the operation. If the only clean home for the rule is a trigger, the *tables* are wrong — this is the serious branch, and it reopens the SQLite-affordances assessment from the Phase 1 review (the verdict there rested on triggers staying dumb; semantic triggers would erode the debuggability/testability line it was based on).
  Handling: write the finding into this plan's closeout + the master plan, propose the ops-layer or schema alternative (schema changes get their own migration + commit per convention), and **get the author's decision before any trigger gains domain knowledge**. What gets re-assessed at that point: the trigger-ownership line itself (Triggers.swift header), the affected invariant's enforcement home (Domain fn vs DB), and — only if branch 3 recurs — the rows-as-truth substrate choice. One occurrence is a finding; a pattern is an architecture signal.
- **Churn is per-container but edits are per-variant** — autosave must resolve variant → block → live placement → container in one query; a pool block's autosave still updates the pool's stamps.
- **Locked-post enforcement is distributed** (autosave, commit, reorder, move, choose-variant all refuse) — centralize the check in one helper or it will drift.
- **Fan position of a branch** goes after the source variant, not at the fan's end — decide and test explicitly (spec says "fan_position=next"; propose to author only if it matters visibly).
- **Undo inverses must capture pre-images at do-time** (positions, `chosen_variant_id`), not re-derive them at undo-time.

---

## Closeout (2026-07-05)

**Result: complete. `swift test` green on the Air — 143 tests, 0 failures** (40 baseline + 103 new: 8 FractionalIndex, 7 churn, 15 segmentation, 16 container/reading ops, 19 block/variant lifecycle, 17 locks/deletion/placement, 11 tags/references, 9 undo core, 1 parameterized×5-seed invariant sweep). This is the Phase 3 baseline — do not re-run at session start.

**Commits:** `69ed691` (Step 1), `c880799` (Step 2), `9fe1d7b` (Step 3), `c45a5f7` (Step 4), `8038a19` (Step 5), `2f3a966` (Step 6), `acf06ce` (Step 7), `257c775` (Step 8), plus the sweep commit (Step 9). Domain functions got their own commits per convention.

**What shipped, step by step:**
1. `FractionalIndex` — digit-wise base-62 midpoint with per-call jitter through `@Dependency(\.withRandomNumberGenerator)`; unlimited depth, no rebalance op. **Plan correction (math, not judgment):** keys never end in the minimum digit `'0'`, and the plan's degenerate example `("a","a0")` is *lexicographically impossible* — no base-62 string sorts strictly between them, which is exactly why trailing-min-digit keys are banned in fractional-indexing schemes. Tested with the possible degenerate `("a","a1")` instead.
2. `Churn.accumulate` — pure fold: signed delta, magnitude counts (insert = delete); `max(baseline,1)`; crossing resets to 0 and tells the caller to stamp + rebaseline.
3. `SegmentationRules` — `bulkSegments` (one_block verbatim passthrough; paragraph splits on newline runs, trims, drops blanks; sentence = coarse scanner with terminator runs + closing quotes, newline always ends a sentence) and `crystallizedBoundary` (first completed non-blank paragraph; `remainingTail` is an exact suffix so the editor can excise without guessing; callers loop). **Interpretation flagged:** the spec defines crystallization in terms of completed *paragraphs*, so the function takes no mode; how sentence mode interacts with live typing is an author question owned by Phase 7 (entered in KnownIssues).
4. Operations scaffold — `Operations` struct (`@Dependency` database/date/uuid; **the clock is read once per op** so every row in a transaction carries one timestamp), typed `OperationError`, neighbor-relative `InsertPosition` (start/end/after/before) resolved via FractionalIndex, **one centralized locked-post guard** (`ensureUnlocked`/`ensurePlacementUnlocked`) so the distributed refusal rule can't drift. Container CRUD (journal profile seeds `one_block`), reading CRUD + curated membership (extent constraint enforced at add; locked reading freezes membership + order; tombstone-then-re-add verified under the live-unique index).
5. Block/variant lifecycle — `newBlock` (block↔variant FK circle resolved by insert-then-point), `autosave` (buffer + churn via `registerTextChange`: last_touched always; threshold-cross stamps + resets + rebaselines to *rendered length* — chosen-variant fallback semantics, computed only on crossings so P1 holds), `commit` (**manual stamps a major revision; auto never does** — auto insurance must not reshuffle the library), `restoreCommit` (I5 untouched; churn = old+new length, the honest full-replacement cost; no-op when identical), `idleAutoCommit` (dirty = differs from latest commit, or never-committed non-empty; idempotent; skips locked variants; refuses locked posts), `branchVariant` (**fan position beside its source**, per plan risk note, tested), `newBlankVariant` (empty, parentless, fan end).
6. Locks/deletion/placement — lockPost auto-commits dirty buffers (shared helper with idleAutoCommit) then seals; archive/delete variant with the **ops-layer chosen guard** (the live enforcement RESTRICT can't provide) + I10 + default reassignment to most-recently-updated active; `deleteBlock` records `last_container_id` then lets triggers cascade (children stamped with the block's exact `deleted_at`); `chooseVariant` (see additions below); `placeBlock` (unplaced blocks only — the W-reversibility primitive; chosen starts NULL); `restoreBlock` (flips block + cascade victims by stamp equality — independently-deleted rows stay dead; fresh placement at the end of `last_container_id`, or live-but-unplaced if that container died); `moveBlock`/`reorder`.
7. Tags/references — `createTag` (path materialization; names may not contain '/'), `renameTag` (one-transaction subtree path rewrite; **unicode-scalar lengths** because SQLite `substr` counts code points, not Swift graphemes), `deleteTag` (ops-layer subtree loop; per-tag triggers take each tag's applications), apply/remove for posts + blocks, reference CRUD + panel ordering (posts only).
8. Undo core — `UndoStack` (in-memory, LIFO, session-scoped; failed inverse stays for retry). Registered: deleteBlock, deleteVariant, archiveVariant, moveBlock, reorder. **Inverses are internal revert operations** (`revertDeleteBlock`, `revertDeleteVariant`, `revertArchiveVariant`, `restorePlacementLocation`): exact-row tombstone/status flips + pre-image restores captured at do-time — so do→undo round-trips to row equality (tested modulo `updated_at`), and undo's writes are ordinary outbox-fed transactions (sync never knows). `revertDeleteBlock` flips the *original* placement row (position + chosen intact) — deliberately distinct from the public `restoreBlock` tray gesture, which re-places fresh at the end.
9. Invariant sweep — 5 seeds × 250 random ops over the whole surface (undo included); refusals are no-ops, **any SQLite error is a failure** (an invariant that survives only by constraint is a bug). Predicates: I10 + non-dangling active default, I2, commits monotone, live-child→live-parent integrity, position-key hygiene. All green.

**The trigger smell never appeared.** No operation wanted a semantic trigger; the closed set (tombstone propagation + outbox capture) held without pressure. No schema findings; nothing tortured.

**Additions beyond the plan's op list (justified, author should skim):**
- `chooseVariant(block, variant)` — I3's setter. Not named in AppSpec §9 but required by `deleteVariant`'s "re-point first" rule and by the Phase 7 fan UI (branch/choose/badge). Guards: placed block, unsealed post, live active variant of the same block.
- `unarchiveVariant` — archive's reverse (spec calls archive "kept"; a keep you can't retrieve isn't a keep).
- `setProfile`, `setReadingQuerySpec`, `unlockReading` — trivial setters for schema fields that had no owner.

**Interpretations — author-reviewed 2026-07-05, ratified with one amendment:** post-lock scope ✓ (the seal refuses everything under the post; variant-lock *toggles* added to the refusal set as a consequence); restore-into-locked-throws ✓; archive-chosen-allowed ✓ (confirmed after walking the default-reassignment lifecycle). **Amendment: `lockVariant` now auto-commits a dirty buffer before freezing** (kind='auto', the third quiet auto-commit occasion, mirroring lockPost) — the original default-refuse left the guarded text uninsured against unlock-then-edit; commit of a locked variant stays refused. Specs updated (AppSpec §9 + §14, OverallModel §3). **145 tests green after the amendment; see the post-phase review addendum below — **153** is the final Phase 3 baseline.** Original list as presented:
- **Post-lock scope:** the seal refuses *everything under the post* — edits, commits, structure, chosen variants, **and fan growth (branch/blank take)** — while library metadata (title, entry date, profile) stays editable and floating notes count as content (refused). The spec enumerates "no edits, no new commits, pointer order + chosen variants frozen"; fan growth under a sealed post felt contrary to its calm.
- **Commit of a locked variant: refused** (plan default) — for both manual commits and auto-commit sweeps (idleAutoCommit and lockPost skip locked variants).
- **`idleAutoCommit` on a locked post: refused** ("no new commits"); the app-phase timer should filter sealed posts.
- **Archiving a chosen variant: allowed** (read-time fallback renders the default — AppSpec §7 names archived explicitly); **deleting** a chosen variant stays refused. Deleting a *locked* variant also refused (the guard means something; unlock first).
- **restoreBlock into a since-locked container throws** (unlock and retry) rather than silently leaving the block unplaced; into a *dead* container it restores live-but-unplaced (the unplaced-blocks utility view's population).

**Deferred/notes for Phase 3:** structural ops get the scaffold as-is (`liveX` helpers, `ensurePlacementUnlocked`, `containerPosition`, `registerTextChange`, `flipBlockCascadeTombstones`, `insertPlacement` via `placeBlock`); undo inverses follow the Step 8 pattern (pre-images at do-time, internal revert ops, register after the transaction succeeds); `poolDragCopy` lands in Phase 3 with the other lineage-minting ops. One KnownIssues entry added (sentence-mode crystallization semantics, owner Phase 7). The restoreCommit-predates-split documented-behavior test is Phase 3's (needs divide).

---

## Post-phase adversarial review — findings & resolutions (2026-07-05)

An author-run adversarial review confirmed two undo-inverse bugs; fixing them surfaced a third of the same class, and extending the sweep surfaced a fourth and fifth in the new `restoreContainer`. All fixed with named regression tests. The class has a name now: **stamp-based restores must check the *present*, not just the stamp** — between delete and restore, a row's parents can die, its block can be re-homed, its story can diverge. Phase 3's inverses inherit this rule (its plan's Risks updated).

**Fixed (each probe-verified failing before, regression-tested after):**
1. `revertDeleteVariant` resurrected a live variant under a block tombstoned in the meantime (deleteContainer is not undo-registered, so LIFO cannot order-protect it). Now requires a live block; refusal leaves the entry for retry.
2. `revertDeleteVariant`/`revertArchiveVariant` bypassed the post seal — the one place the centralized guard was skipped, exactly the drift the plan's risk note predicted. Both now call `ensurePlacementUnlocked`.
3. Same class, pre-existing: `restoreBlock`/`flipBlockCascadeTombstones` revived a `block_tag` whose tag died *after* the block (the application carries the block's stamp). Tag applications now revive only under live tags.
4. + 5. In the new `restoreContainer` (below), caught by the extended sweep as a raw UNIQUE violation and a dangling live placement: a block independently revived and re-placed elsewhere must keep its new home (I2), and one revived-then-re-deleted (newer stamp) must stay dead. The placement flip now checks both.
6. `UndoStack.undo` popped blindly after running the inverse outside the lock; removal is now by entry id, so a racing registration can never lose someone else's entry.

**Author-directed:**
- **`restoreContainer` added** (deleted posts must be recoverable): full-cascade stamp-based restore — placements, blocks + their children, memberships, tags, references — with the divergence rules above. AppSpec §9 updated.
- **Commit of archived variants stays allowed**, now ratified + documented in code: commit reads without editing, and restoring the take means unarchiving first anyway.

**Judgment calls (made, documented):**
- `setReadingSort` now refuses on a locked reading — for non-manual readings the sort field IS the order the lock froze.
- The post seal is **content-level**: a sealed post may be archived/deleted/retitled/tagged without unsealing (deletion now recoverable). Documented in AppSpec §9.
- `reading.grouping_tag_id` may dangle at a tombstoned tag; read-time rule (treat as NULL/ungrouped) added to AppSpec §7 — Phase 4 must honor it.
- `idleAutoCommit` accepts pools deliberately (renamed param, documented): a scrap's buffer deserves the same insurance.
- Tray semantics for container-cascade victims (stale `last_container_id`) → KnownIssues, owner Phase 4.
- Cleanups: the triplicated position resolvers collapsed into one `listPosition` core; `FractionalIndex.between` dead statements removed.

**Sweep hardened:** `restoreContainer` + two more seeds added (now 7×250). The extension caught bugs 4–5 before any human did — the "any SQLite error is a failure" stance paying rent.

**Baseline is now 153 tests green** (supersedes 145/143 above).

**Self-review finding (same session), fixed:** a stale `revertDeleteBlock` entry **wedged the undo stack permanently** — `deleteBlock` → `restoreBlock` (tray) → undo threw `blockNotDeleted`, an *unresolvable* refusal, so the entry never popped and every undo beneath it was unreachable. Distinction now explicit in the inverses: **resolvable refusals keep the entry for retry** (locked → unlock; dead block → restore it); **obsolete entries pop as quiet no-op successes** (the world already moved past them). `revertDeleteBlock` was the one inverse that threw on already-restored; the other three were already tolerant. Regression test asserts the entry beneath stays reachable. Phase 3 inverses must sort every refusal into one of those two buckets deliberately.
