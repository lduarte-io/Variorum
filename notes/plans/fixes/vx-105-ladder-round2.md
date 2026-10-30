# VX-105 — Ladder round 2 (cold review of the fix round)

**Reviewer:** fresh Opus cold reviewer (`opus-reviewer`), 2026-10-30 · `notes/REVIEW_PROMPT.md` verbatim, zero framing.
**Diff reviewed:** the fix round, `git diff 0bf9c0645..HEAD` on `vx-105-readme-letter` (11 files, +735/−99), every
file read in this session; the round-1 findings, arbitration, FIX ROUND 1 RECORD and F-3 arbitration
(`notes/plans/fixes/vx-105-ladder-round1.md`); the effort record (`notes/plans/fixes/vx-105-readme-letter.md`); and the
fixes' blast radius read directly (OperationsRunner, AppSession, ShellActions.restoreReadme, the version classifier and
its other callers, BookView's Outline rows, NoteBox, ContextBar/ContextBarDoors, CommandRouter, WriteTakesPanel, the
note-grain fold classifier).
**Seam check (first):** no editor seam, no custody/keychain code, nothing under `Sources/VariorumCore/Sync/` (read
only — `SeededFurnitureDedupe.swift`'s classifier, to verify MINOR-4's restored net), no default's meaning. The one core
change is a public read in `Sources/VariorumCore/Queries/NoteVersions.swift`. The opus-reviewer seat is right.

**Verification run by the reviewer (no stage):** `swift test --filter NoteVersionsTests` — 31 tests PASSED (the new
core pin included). `xcodebuild -scheme Variorum -destination 'platform=macOS' build-for-testing -quiet` from
`App/Variorum/` — EXIT 0, zero errors (compile only; nothing run, no test host launched). A scratch SwiftPM probe
OUTSIDE the repo (`.package(path:)` on this worktree; it wrote nothing into the tree — `git status` clean after) ran the
REAL `Queries.isVersionOfAnyLiveNote` on a fully migrated `AppDatabase.inMemory()` store and printed the plan SQLite
chose and the wall time (see BLOCKER-1). No Mac suite was run (the stage is not mine).

---

## Findings (severity-ranked)

### BLOCKER-1 · `Sources/VariorumCore/Queries/NoteVersions.swift:341–363` (`Queries.isVersionOfAnyLiveNote`, new this round, MINOR-1's fix) · the new public core read walks every live note in the store, while its doc states "never the corpus"

Severity is the review prompt's own rule ("makes cost scale with corpus size … flag it at full severity"). The practical
reach today is small, and that is stated below so the arbitration can weigh it.

**Mechanism (traced, then measured in the real engine).** The query is `SELECT EXISTS (SELECT 1 FROM container v WHERE
v.id = :container AND … AND versionHistoryPredicate(alias: "v", of: .anyLiveNote))`. The `.anyLiveNote` arm joins
`container peer ON peer.id = theirs.container_id AND peer.id <> v.id AND peer.kind = 'post' AND peer.deleted_at IS NULL`
(`NoteVersions.swift:163–168`). Without stats (the repo never runs ANALYZE, `Migrations.swift:496`, `:549`), SQLite
drives that correlated EXISTS FROM `peer`. The plan printed by the probe, against the real migrated schema
(SQLite 3.54.1 through the GRDB fork):

```
SEARCH v USING INDEX sqlite_autoindex_container_1 (id=?)
CORRELATED SCALAR SUBQUERY 2
SEARCH peer USING INDEX idx_container_kind (kind=?)      ← every live post
SEARCH mine USING INDEX idx_cblock_order (container_id=?)
BLOOM FILTER ON e (type=?)
SEARCH e USING AUTOMATIC PARTIAL COVERING INDEX (type=?) ← built over the edge table each run
CORRELATED SCALAR SUBQUERY 1
SEARCH cascaded USING INDEX sqlite_autoindex_block_1 (id=?)
SEARCH theirs USING INDEX idx_cblock_order (container_id=?)
```

Measured: a version of the newest note, 10 saved versions in the store, 5 blocks per note — **1.6 ms at 300 notes,
14.4 ms at 3,000 notes (linear)**. The same store's `isVersionHistory(_, moment, of: note)` (the named-note arm) takes
0.12 ms at 3,000 notes, because its plan starts from `mine`/`theirs` and never walks the notes. A candidate that is NOT
archived-at-birth short-circuits on `v.archived_at IS NOT NULL` (0.1 ms), so only real saved versions pay the walk.

**Where it bites today.** `ReadmeSeeder.liveReadmeID` (`BirthFurnitureSeeders.swift:335–345`) asks it of each post
titled "readme" in id order until one is not a version. Every saved version of her readme keeps the title (V6), so
after K saves a door press asks it of up to K version candidates, each one a walk of every note (with 17 placements
per candidate, more than the probe's 5). The doc's "Candidates are the posts titled "readme" — a handful at most" is
false for the same reason. The birth seed runs on a fresh store and is unaffected. It is one Help-menu press, not a
keystroke road. **The larger harm is the contract.** The doc comment (`:349–350`) says "Cost: this container's own
placements and their version links — never the corpus", and the function is PUBLIC "so an app read … asks exactly
what those surfaces ask". The next caller to trust that line in a per-row road (a listing, a badge) gets
O(rows × notes).

**Context, not part of this finding (pre-existing).** (a) The candidate read itself (`kind = 'post' AND title = ?`)
walks every post through `idx_container_kind`, since U1. Round 1's clean bill called it "one indexed-by-kind title
query"; it is a walk with a small constant, the same shape as the fold engine's reserved-title scan
(`SeededFurnitureDedupe.swift:627–634`). Whether reserved-title door and seed reads are an accepted exemption is the
orchestrator's call. (b) The shared predicate's AUTOMATIC edge index (a build over `edge` per execution) also appears
in the existing `isVersionHistory`. It is older than this effort and belongs in a ticket if anywhere.

**Proposed fix.** Drive the read from the candidate, exactly as `noteVersionStamps` drives from the note
(`NoteVersions.swift:269–303`). Reach the candidate's linked notes through its OWN placements (`mine.container_id =
:container` → `idx_edge_source` / `idx_edge_target` arms → the other endpoint's placement, live or tombstoned per
LR1-1, by `block_id` → a live post ≠ the candidate). Then let the ONE classifier decide, for example by asking
`isVersionHistory(db, candidate, of: peer)` for each such peer, so no classifier is hand-copied. Correct the doc's cost
line and the "handful at most" line.

**Pin (red on this tree).** A plan pin in the `VersionsInCompareTests.theStampsReadIsDrivenFromTheNotesOwnPlacements`
shape. Capture the statement(s) `isVersionOfAnyLiveNote` runs, `EXPLAIN QUERY PLAN` each, and assert no line reads
`SEARCH peer USING INDEX idx_container_kind` (no walk of the notes). It is RED on this tree, where the plan above is
exactly that line. Pair it with an equality pin: across the LR1-1 note-side shapes (the anchor merged away, divided,
deleted; an unmark; the note deleted), the rewritten read answers exactly what `versionHistoryPredicate(.anyLiveNote)`
answers. `anyLiveNotesVersionIsNamedAndNothingElseIs` stays as the behaviour pin.

**STATUS: IN PROGRESS** (written incrementally).
