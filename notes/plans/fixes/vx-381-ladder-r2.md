# VX-381 — ladder round 2 (cold re-review of round 1's fixes, opus-reviewer)

**Reviewer:** a fresh `opus-reviewer`; `notes/REVIEW_PROMPT.md`'s standing context; anchor =
`notes/plans/fixes/vx-381-ladder-r1.md` (findings, §DISPOSITIONS, §FIX-LEG APPROVALS).
**Diff:** `git diff aa210ec1b..HEAD` in `~/dev/variorum-vx-381` — the fix commits 26d613bf (F-2) · 6e3ff09e (F-1) ·
20894e80 (F-3) · dd3ba271 (red-tree pins) · b1d38659 (F-7) · f2644865 (F-8); the rest are records.
**Scope check (first):** the fix diff touches no editor seam, no custody/Keychain code, no
`Sources/VariorumCore/Sync/`, no schema, no default's meaning (`Operations+Tag.swift`, the shared refusal table,
two Mac copy files, two doc comments, pins). The opus-reviewer cast stands.

**Status:** COMPLETE — F-2 · F-1 · F-3 · F-7 · F-8 all HOLD; 0 BLOCKER · 0 MAJOR · 1 MINOR (N-1, the ordered sweep
predicate) · 2 NIT (N-2, N-3). **No new BLOCKER or MAJOR — the ladder closes at round 2** (N-1's fix, if taken, is a
final-round fix: the orchestrator's line-by-line check).

**Method.** Read every fix line; ran the worktree's `TagDeleteUndoTests` headless on HEAD (12/12 green). Probes ran
ONLY in a scratch copy of the core package outside the repo (`$SCRATCH/probe` — Sources/Tests/Vendor/Tools +
the build cache): six throwaway corner-case tests for F-2, the shipped revival constants' `EXPLAIN QUERY PLAN`
printed, red-on-old checks by reverting ONLY the fix lines in the copy, and the optional sweep predicate run on
both trees. Nothing in the worktree was edited but this file.

## Verdicts on round 1's confirmed findings

### F-2 (BLOCKER) — FIX HOLDS

`Operations+Tag.swift:220–232`: each dead tag of the pass is walked `ORDER BY path, id` over its STORED
(delete-time) paths; a child rebuilds `parent.path + "/" + name` from the parent row read INSIDE the same
transaction (so a parent revived earlier in the loop hands over its REBUILT path), a root takes its name; the
collision check (`ensureNoLiveTagPath`, `:229`) and the UPDATE (`:231`, `deleted_at = NULL, path = ?`) both use the
rebuilt path. Traced points:

- **Parents first is guaranteed** for every pass the ops can write: a pass is the root plus the live tags under its
  CURRENT path prefix (`tombstoneTagSubtree`, `:144–154`), and a parent's path is a proper prefix of its child's,
  which sorts strictly first under SQLite's BINARY collation whatever the sibling names (probed with siblings `a`,
  `a b`, `a.`, `a0` and the grandchild `a/x` — names whose bytes fall either side of `/`). Dead rows' paths never move while dead (`renameTag`'s
  descendant UPDATE is `deleted_at IS NULL`, `:88`; the only other tag writers — the subtree tombstone, the wing
  move's whole-vocabulary retire, `Sync/Repairs.swift:615` — write `deleted_at` only), so the order read at undo is
  the order written at delete.
- **The collision check reads what is written**, in one statement with the revival, so `uq_tag_path_live` can only
  meet the rebuilt path (no stale-path false refusal, no stale-path false pass). Within one pass two rebuilt paths
  cannot collide (siblings differ by name; deeper rows are strictly longer). A child-level collision in an
  already-incoherent store throws after the parent's UPDATE — the whole `database.write` rolls back and the entry
  stays (the LIFO doctrine), as before.
- **The redo** re-deletes by the CURRENT (rebuilt) path, so a later undo reads a coherent pass again.

Corner probes (scratch copy; all six GREEN on HEAD; the four that involve a rename RED with only the rebuild
reverted, the two that don't green on both trees, as they should be):
a REVIVED ROOT (`r` ⊃ `c`; a fresh `r` ⊃ `c` refuses `duplicateTagPath("r")`, rename hers → `r`, `r/c`, `r2`, `r2/c`;
green on both trees — a root's path IS its name) · a PARENT REVIVED IN THE SAME UNDO under a renamed
grandparent (`g0 ⊃ g1 ⊃ {a ⊃ x, a b, a., a0}`, delete `g1`, rename `g0`→`Z`, undo → every path under `Z/g1`) · a
MID-CHAIN RENAME (`g0 ⊃ g1 ⊃ g2 ⊃ g3`, delete `g2`, rename `g1`→`mid`, undo → `g0/mid/g2`, `g0/mid/g2/g3`; a later
rename of `g0` reaches both and a delete of `g0` takes both) · TWO ENTRIES with a rename between (delete `g2`, delete
`g1`, rename `g0`→`Z`, undo, undo → `Z/g1/g2`; redo, rename `g1`→`m`, undo → `Z/m/g2`) · REDO→RENAME→UNDO (→
`B/g1/g2`) · a parent DELETED AND RE-MINTED AS A TWIN (the twin refuses the parent's undo; renamed, both undos land
under the original parent, never the twin — green on both trees). Every probe also asserts a DB-wide coherence count (below, the sweep
predicate's SQL) = 0.

Red-on-old (verified, not taken from the record): with ONLY `:221–226`'s rebuild reverted to `let path = tag.path`,
the three new pins fail with exactly 4 + 4 + 3 = 11 issues (`theCollisionCheckReadsTheRebuiltPath`,
`aTagRevivedUnderARenamedParentTakesTheParentsNewPath`, `aRevivedChainRebuildsEveryPathParentsFirst`); the eight
shipped pins stay green — matches the record.

### F-1 (BLOCKER, P1) — FIX HOLDS

`EXPLAIN QUERY PLAN` of the shipped constants (`Operations.revivePostTagApplicationsSQL` /
`reviveBlockTagApplicationsSQL`, `:252–274`), run by me on the bundled SQLCipher (`sqlite_version()` 3.53.4):

```
SEARCH post_tag USING INDEX idx_post_tag_tag (tag_id=?)
CORRELATED SCALAR SUBQUERY 1
  SEARCH c USING INDEX sqlite_autoindex_container_1 (id=?)
CORRELATED SCALAR SUBQUERY 2
  SEARCH twin USING INDEX uq_post_tag_live (tag_id=? AND post_id=?)
```
(the block twin: `idx_block_tag_tag` · `SEARCH b USING INDEX sqlite_autoindex_block_1 (id=?)` · `uq_block_tag_live`).
No `LIST SUBQUERY`, no `SCAN`. The same constants with the OLD guards substituted plan `LIST SUBQUERY 1 → SCAN
container USING INDEX idx_container_touched → CREATE BLOOM FILTER` / `SCAN block`, and the plan pin
(`theApplicationRevivalsSeekTheirTargetsAndNeverScanACorpusTable`) goes red on them — verified. Cost is now the
tag's own application history (`idx_post_tag_tag`) × O(log N) seeks: act-sized. The stats-free plan IS the
production plan (the repo never runs `ANALYZE` — `ShelfQueries.swift:1160`, `Migrations.swift:545`); with an
`ANALYZE` on a one-row fixture SQLite picks table scans of the TINY tables, which says nothing at scale and is
moot here. The rest of the inverse is keyed (`id IN (…)` by PK, the parent by PK, the collision probe by
`uq_tag_path_live`). The pre-existing twin in `restoreContainer`/`restoreBlock` is VX-387 (on the board, Debt,
Performance) — correctly outside this fix.

### F-3 (MAJOR) — FIX HOLDS

`App/Variorum/Shared/OpsRefusalTable.swift:422–423` — one arm in the SHARED `words(for:)`, the approved sentence
byte-for-byte ("A tag named “work” already exists — rename it, then try again."). Both seams reach it, traced:
the Mac's `OpsRefusalCopy.message(for:)` (`Registry/OpsRefusalCopy.swift:408–409`) is `macWords ?? shared`, and
`macWords` has no `duplicateTagPath` arm, so ⌥⌘Z (`ShellActions.structuralUndo` → `StructuralUndoCopy.undoFailed`)
speaks it; the phone's `MobileUndoDoor.refusal` (`:297–305`) is the shared table before `String(describing:)`. The
Mac pin drives the REAL door end to end (the toast, the kept entry, then the rename road landing "Undid: Delete
Tag"); the phone pin calls the phone's own door function. Both red on the RED tree per the batch logs
(`App/Variorum/DerivedData/run1-mac-red.log:87–100`, `run3-phone-red.log:48–54` — read, the raw strings are there),
green on the green tree (RUN 2/RUN 4).

**No raw enum remains on this entry's seam:** the Delete Tag inverse can throw only `duplicateTagPath` (`:229`;
`Queries.wingIsLive` and the revivals throw no typed error) and the re-apply throws none, so every typed refusal the
entry can raise on either platform's undo/redo door is now worded. The other doors that reach a tag collision keep
their own words (`TagsViewModel.message` / `MobileTagsModel.refusal` — Settings, the typed-tag sheets, quick entry,
capture microsyntax); the shared arm is reached otherwise only by the rule editor's make-a-tag door on a race (N-2
below). The MCP wire-refusal sweep keeps `duplicateTagPath` in its proven-unreachable set (no wire tool deletes a
tag or pops an undo — grep of `Sources/VariorumMCP` clean). *(For the record, not a finding: a grep of the two tables'
`case .x` arms against `OperationError`'s cases leaves ~37 unworded — `invalidTagName`, `sectionNotFound`,
`postNotInReading`, the MCP grant family, … — each still printing "Refused: …" wherever `message(for:)` is a door's
fallback. A pre-existing class (many proven wire-unreachable by the MCP sweep); none is reachable from this entry.)*

### F-7 (NIT rider) — FIX HOLDS

`ShelfViewModel.swift:765–766`: `wore([], false) == nil` now heads "Added", giving "Added — the gathering shows it once
it's unarchived." — the approved wording; reached by both the Bookcase (`collectReceipt`, `:783`) and the Mac chip
(`MembershipChoice.swift` `AddToBookCopy.collected`, the archived arm). Every other arm byte-unchanged
(`wore` untouched). The chip's LIVE empty arm ("Added by tagging  — …", `MembershipChoice.swift` `collected`'s last
line) is the same unreachable shape and stays with VX-216 as the fix leg records — consistent with the disposition.

### F-8 (NIT rider) — DONE, docs true

`GatheringNoteDoorCopy.cannot` is gone with no remaining reference (grep of App/Tests/Sources clean); both former
callers (`help`, `BookStructureModel.swift:808`) now say `reason` directly — byte-identical output.
`MultiBookEditNote.divergeTarget`'s doc (`:65–75`) and its twin in `AppSession.noteMultiBookEdit` (`:656–658`) now
say what is true: the trigger passes `memberBooks` (`MultiBookEditNote.swift:55–57`, `kind == .book`), speaking only
at ≥ 2 (`shouldSpeak`), so a target exists at the trigger; the nil contract for a mixed/derived-only list is real and
pinned (`BookAscentTests.swift:871–874`).

## The item marked "ROUND 2 DECIDES" — the sweep predicate: ORDERED (as N-1, MINOR)

Ruling: **order it**, with one condition the round-1 proposal did not state — it must ship WITH a witness seed, or it
is green on both sides. Measured in the scratch copy (the shipped `InvariantSweepTests` + one predicate, nothing else):

- The predicate — every live tag is coherent: a root's `path = name`; a child's parent row exists, is live, and
  `path = parent.path || '/' || name` —
  ```sql
  SELECT COUNT(*) FROM tag t LEFT JOIN tag p ON p.id = t.parent_id
  WHERE t.deleted_at IS NULL AND (
      (t.parent_id IS NULL AND t.path <> t.name)
   OR (t.parent_id IS NOT NULL AND (p.id IS NULL OR p.deleted_at IS NOT NULL
                                   OR t.path <> p.path || '/' || t.name)))
  ```
- **HEAD: green on the 7 shipped seeds AND on seeds 1…400** (400 × 250 random acts; every other predicate green too).
- **The pre-fix inverse (only F-2's rebuild reverted): green on the 7 shipped seeds** — as shipped, the predicate
  would NOT have caught F-2 (hollow on the current list) — **but RED on seed 82** ("tag→parent … dangling at step 249"
  and "… step 250"; 1 seed in 400 reaches delete-child → rename-parent → undo-with-the-entry-on-top).

Why order it rather than decline: `tag.path` is the model's ONE deliberate denormalization (AppSpec §7), no DB
constraint can express its coherence, and the sweep is the house's home for exactly such DB-wide predicates — it
already randomizes `createTag` (with parents) · `renameTag` · `deleteTag` · undo (`InvariantSweepTests.swift:284–298`,
and the `default:` undo arm at `:385–386`) without ever checking the column those ops exist to keep coherent. The U2 self-assessment's
claim that the sweep exercises the entry "against the no-live-row-under-a-dead-parent invariants" covered
applications only (round 1, F-2's "why missed"); this closes that gap for every future tag writer (VX-238's Trash
restore, any wing-adoption change) at near-zero cost. It is a standing guard, not F-2's pin (the three F-2 pins are),
so MINOR — it earns no round 3.

## New findings (severity-ranked)

### N-1 · MINOR (test coverage — the ruling above) · `Tests/VariorumCoreTests/InvariantSweepTests.swift:15` and `:72–115`

**What:** the sweep's "no live row under a tombstoned parent" list has no `tag→parent` / path-coherence row, though the
sweep randomizes every op that maintains `tag.path`. **Traced degradation:** F-2 shipped through U2's evidence because
nothing DB-wide looks at the column (measured above: the predicate alone is green on both trees with the shipped seeds).
**Proposed fix:** add the predicate above to the list (label e.g. `"tag→parent path coherence"`) AND append `82` to the
`@Test(arguments:)` list with a one-line comment naming it F-2's witness (the existing seeds untouched, so no other
predicate's coverage shifts). **Pin evidence owed by the fix:** red with F-2's rebuild reverted (seed 82, steps
249/250), green on HEAD — exactly what I measured. The seed is a fragile witness (any change to the op mix or the
RNG's consumption reshuffles every sequence); its comment should say so, so a future reader re-finds a witness rather
than trusting a stale one.

### N-2 · NIT (copy, race-only — for her bundle beside the approved wording) · `App/Variorum/Shared/OpsRefusalTable.swift:422–423` × `App/Variorum/Variorum/Features/Readings/RuleEditor.swift:282–308`

The shared arm's road "rename it, then try again" is right on the undo doors (the colliding tag is hers, made since).
Its only other reader is the rule editor's make-a-tag door: `createTag` reads the wing's live tags, plans, then mints
the missing remainder in a separate runner turn; a tag minted at that path in between (another window, a sync apply)
makes `insertTag` throw `duplicateTagPath` → `status.refuse(OpsRefusalCopy.message(for:))` (`:306`). There a plain
retry already succeeds (the re-plan finds the path live and adopts it — `TypedTagPath.plan`/`createMissing` mint
nothing), so "rename it" asks her to rename a tag she may want. Race-only and the orchestrator's approval already
weighed this door for the "undo again" alternative; no change ordered — one clause in the PROVISIONAL bundle line
("on the rule editor's race the road is just 'try again'") so her ratification sees both readers.

### N-3 · NIT (robustness of F-2's stated assumption; pre-existing sync class — no fix ordered) · `Sources/VariorumCore/Operations/Operations+Tag.swift:218`, `:223–224`

The revival orders the pass by its STORED paths and skips a child whose parent is still dead (`continue`), relying on
the pass having been coherent when written (the fix's own doc, `:207–209`). Every LOCAL op keeps that true (traced
above). Sync can break it: device A renames `home/a` → `home/x` (rewriting only its own live subtree) while device B
mints `y` under the same tag as `home/a/y`; both rows converge as written (server-wins per row; no repair rewrites a
path), leaving `y` live with a stale path. Delete `home` then undo: the pass is `{home, home/a/y, home/x}` in that
order, so `y` is read BEFORE its parent revives, is skipped, and stays dead — the next redo/undo cycle never carries it
again. Fail-closed (nothing incoherent goes live; the rebuild would even have HEALED `y` had it come second) and
identical on the pre-fix code, so not a regression of this fix; the real class is the pre-existing sync-born path
incoherence (`renameTag` under concurrency — AppSpec §9 names only "a lost rename"), under which a plain `deleteTag`
of `home/x` already leaves `y` LIVE under a dead parent (worse). **Probed** (scratch copy, the converged row written
by hand: `home ⊃ x ⊃ y` with `y.path = 'home/a/y'`): after Delete `home` → undo, `x` live, `y` dead; after redo +
undo, `y` still dead on the original stamp; and a plain `deleteTag(x)` leaves `y` live. Pinnable (red on HEAD) the same
way; a parent-pointer walk (revive while progress is made) would close the undo's half. Recommend: no action in this
run; if the orchestrator wants the sync class owned, a Low ticket (Castle & sync / Debt, Suspected) naming both
halves.

## Severity-ranked index

| # | Severity | One line |
|---|---|---|
| F-2 | — | FIX HOLDS: paths rebuilt parents-first from the live parent; collision on the rebuilt path; six corner probes + three pins red-on-old verified. |
| F-1 | — | FIX HOLDS: the shipped constants plan as keyed seeks (no LIST SUBQUERY, no SCAN) on the bundled SQLite 3.53.4; pin red on the old guards, verified. |
| F-3 | — | FIX HOLDS: one shared arm, both platforms' undo doors reach it; no typed refusal of the entry is left unworded. |
| F-7 | — | FIX HOLDS: "Added — the gathering shows it once it's unarchived." |
| F-8 | — | DONE: identity wrapper gone, docs true. |
| N-1 | MINOR | The ordered sweep predicate (tag path coherence) — ship it WITH witness seed 82 (red on the pre-fix inverse, green on HEAD over 400 seeds); alone it is green on both sides. |
| N-2 | NIT | The shared road "rename it, then try again" is unneeded on the rule editor's create-tag race (a retry adopts) — one clause in her bundle line; no change. |
| N-3 | NIT | The revival's path order skips a sync-incoherent child before its parent revives (fail-closed, pre-existing class; probed) — no action this run; optional Low ticket for the sync-born path incoherence. |

## Clean bill (checked and found solid)

- **Scope:** no editor seam, custody/Keychain, `Sync/`, schema or default's meaning in the fix diff — opus-reviewer
  stands.
- **F-2 has no new hole on the local op set:** every writer of `tag.path`/`deleted_at` traced (create, rename's live
  subtree, the subtree tombstone, the wing move's whole-vocabulary retire, the revival, `Sync/Repairs.swift:615`'s
  tombstone); dead rows' paths never move, so the delete-time order is the undo-time order; within-pass rebuilt paths
  cannot collide; a mid-loop throw rolls the whole write back and keeps the entry; the redo re-deletes by the coherent
  current path. The path write has no derived-index consequence (the 13o search index carries no tag rows —
  `SearchIndex.swift` has no `tag`), and the outbox captures it by the ordinary UPDATE trigger, as the old revival's
  write was captured.
- **P1 of the whole inverse:** pass rows by PK, the parent by PK, the collision probe on `uq_tag_path_live`, the
  application UPDATEs on `idx_*_tag_tag` with keyed EXISTS / NOT EXISTS — act-sized; the plan pin reads the SHIPPED
  constants (`static let`), so it cannot drift from what runs.
- **Pins are honest:** every new pin was red on its old tree (F-2's 11 issues and F-1's plan issues re-run by me in
  the scratch copy with only the fix lines reverted; F-3 / F-7's reds read in the RED-tree batch logs) and green on
  HEAD; the shipped eight `TagDeleteUndoTests` pins green on both sides, as they should be.
- **Headless on the worktree's HEAD (run by me):** `TagDeleteUndoTests` 12/12; 104 tests in 15 suites green across
  `InvariantSweepTests` · `TagReferenceOperationsTests` · `TagWingScopeTests` · `RuleWingScopingTests` ·
  `BookWingMoveTests` · `TagFamilySectionsTests` · `SearchTagListingTests` · `CollectSetsTheStarTests` ·
  `GatheringMint*` · `SmartCollect*`. The Mac (143/18) and phone (23/3) batch counts were read against the pins' source
  and the batch logs, not re-run (no stage window — the brief's rule).
- **Copy:** the two approved wordings land byte-for-byte; the chip's live empty arm stays VX-216's, as the fix leg
  records.

Probe note: every probe ran in a scratch copy of the core package outside the repo (deleted at the end of this
session); nothing in the worktree was edited but this record.
