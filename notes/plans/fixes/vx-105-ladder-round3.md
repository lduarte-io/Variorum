# VX-105 — Ladder round 3 (cold review of fix round 2; the final round, hard cap three)

**Reviewer:** fresh Opus cold reviewer (`opus-reviewer`), 2026-10-30 · `notes/REVIEW_PROMPT.md` verbatim, zero framing.
**Scope:** `git diff 2d353add9..HEAD` on `vx-105-readme-letter`. That is `c7624059f` (BLOCKER-1: the rewrite of
`Queries.isVersionOfAnyLiveNote`, its two new pins, `liveReadmeID`'s doc) and `8bb17be09` (MINOR-1: record-only
additions). Anchor: `notes/plans/fixes/vx-105-ladder-round2.md` (the findings, the arbitration, the FIX ROUND 2
RECORD). I read every changed line, plus the classifier it now delegates to (`versionHistoryPredicate`,
`isVersionHistory`, `noteVersionStamps`), the edge writer (`insertVersionOfEdge`, canonical `(min, max)`), the restore's
re-anchor, `idx_cblock_dead_block`'s migration, and the record sections the MINOR-1 lines point at.

**Seam check (first):** no editor seam, no custody or keychain code, nothing under `Sources/VariorumCore/Sync/`, and no
default's meaning changes. The one core change is a read in `Sources/VariorumCore/Queries/NoteVersions.swift`. The
opus-reviewer seat is right.

**Verification run by the reviewer (no stage):**
- `swift test --filter "NoteVersionsTests|VersionsInCompareTests"` passed 37 tests in 2 suites. That includes both new
  pins and `theStampsReadIsDrivenFromTheNotesOwnPlacements`.
- A scratch SwiftPM probe lives OUTSIDE the repo, in the session scratchpad, with `.package(path:)` on this worktree and
  `@testable import VariorumCore`. It wrote nothing into the tree: `git status` showed only this file. It ran the REAL
  read on fully migrated `AppDatabase.inMemory()` stores to check four things: the plans, the bytecode of every
  statement the call runs, scaling, and arm-by-arm mutants of the gather checked against the classifier.
- I made no Mac build and ran no Mac suite. No app was launched.

---

## Verdict on BLOCKER-1's required shape (each element checked mechanically)

- **Candidate-driven, index seeks.** I captured the gather's plan myself. It has four `UNION` arms, and each arm runs
  `SEARCH mine USING INDEX idx_cblock_order (container_id=?)` → `SEARCH e USING INDEX idx_edge_source|idx_edge_target
  (…=? AND type=?)` → `SEARCH theirs USING INDEX uq_cblock_ownership (block_id=?)` | `… idx_cblock_dead_block (block_id=?
  AND deleted_at>?)` → `SEARCH note USING INDEX sqlite_autoindex_container_1 (id=?)`. Nothing reads `idx_container_kind`.
  The `CROSS JOIN` order holds, as the record states.
- **The walk is gone.** For a saved-moment candidate, measured as a median of 41 runs:
  - With 311 posts the read takes 0.37 ms; with 3,011 posts it still takes 0.37 ms.
  - The round-1 statement on the same stores takes 1.53 ms and 14.18 ms. That is round 2's linear curve, reproduced.
- **The plan pin is red on old.** The pin's first assertion, applied to the round-1 statement's plan, is RED: that plan
  holds `SEARCH peer USING INDEX idx_container_kind (kind=?)`. On the new read it is GREEN.
- **The classifier decides, and nothing is copied.** By derivation, the rewrite answers exactly what
  `.anyLiveNote` answers:
  - *Original ⇒ new.* Any `.anyLiveNote` witness `(e, mine, theirs, peer)` has `{mine.block_id, theirs.block_id} =
    {e.source, e.target}` with the two different. So it falls in exactly one direction arm. Its `theirs` is either live
    or dead, so it falls in exactly one liveness arm. That arm gathers `peer`, and the same witness satisfies
    `isVersionHistory(v, of: peer)`.
  - *New ⇒ original.* A gathered note already passed the peer join's filters (a live post ≠ v). The classifier's
    witness, with `theirs.container_id = note`, then completes the `.anyLiveNote` EXISTS.
  - Both statements run on one `Database` handle, so both read the same snapshot.

  The probe agrees with this derivation on every container across:
  - the pin's shapes;
  - the pin's shapes plus a `restoreNoteVersion`;
  - a moment on the edge's SOURCE side;
  - a SOURCE-side moment whose note-side block was merged away.

  That is 0 disagreements in all four sets, and `isVersionOfAnyLiveNote` matches the four-arm gather in every one.
- **Both doc lines.** They are corrected, and they no longer say "never the corpus" or "a handful at most". One part of
  the new cost wording is still not quite true; see MINOR-1.
- **The equality pin.** It holds the LR1-1 note-side shapes, but only for moments on the edge's TARGET side; see MINOR-2.

---

## Findings (severity-ranked)

**No BLOCKER, no MAJOR.** The fix meets the finding's shape, and its semantics are exact.

### MINOR-1 · `Sources/VariorumCore/Queries/NoteVersions.swift:369–375` (the "**Cost:**" line) + `Tests/VariorumCoreTests/NoteVersionsTests.swift:992–993` (the pin's message) + `notes/plans/fixes/vx-105-ladder-round2.md:218` (the FIX ROUND 2 RECORD) · the corrected cost words still understate the one corpus-scaled step: the automatic index is built by a full pass over the WHOLE `edge` table, not "over the `version_of` edges", and "no table is scanned whole" / "no table scan" are false

**Mechanism (traced, then measured).** For every live note the candidate links to, the read now calls
`isVersionHistory`. That statement's plan, unchanged and pre-existing, is `SEARCH e USING AUTOMATIC PARTIAL COVERING
INDEX (type=?)`. I read its bytecode in the probe:

```
42 Once          → 43 OpenAutoindex p1=8 … "for edge"
44 Rewind p1=1   (cursor 1 = edge, root page 12)
53 IdxInsert p1=8 …
54 Next p1=1 p2=45
```

That is a loop over every row of `edge`, of every type. The partial `type = 'version_of'` only filters which rows go
INTO the index. `EXPLAIN QUERY PLAN` prints this step as a SEARCH, which is why the plan pin's
`!plan.contains { $0.hasPrefix("SCAN") … }` passes. The measurement shows what scales: one `isVersionHistory` on the
same 10 `version_of` edges took 0.117 ms with 60 edges in the store and 2.0 ms with 60,060 edges (the extra rows were
`derived_from`). The read's total for a moment went from 0.37 ms to 2.1–2.4 ms. So the per-call cost grows with every
divide, merge, extract and copy in the corpus, not with the candidate's `version_of` links.

**Why it matters here, and what does not.** I am NOT reopening the cost itself. The arbitration ruled it a pre-existing,
occasion-bounded non-action, and its premises hold:
- The step was present in the round-1 form's plan too.
- The read's only caller is `liveReadmeID`, which runs at a birth seed and on a Help press.

But round 2's BLOCKER named "the larger harm" as "the contract": the doc on a PUBLIC read is what the next caller trusts.
The new line says the build is "over the `version_of` edges", which reads as bounded by the links. It sits beside "index
seeks — never a walk of the notes". The pin's message says "no table is scanned whole", and the record says "No
`idx_container_kind`, no table scan." All three are false in substance. A caller who puts this read on a per-row road (a
listing, a badge) gets O(rows × |edge|) while the doc tells them otherwise. That is the same failure shape BLOCKER-1
existed to close, now one table over.

**Proposed fix (words only, so no pin, as with round 2's MINOR-1):**
1. In `NoteVersions.swift:371–374`, state that each per-note `isVersionHistory` builds its automatic `version_of` index
   by reading every row of `edge`, all types. That makes the read corpus-scaled in the edge table, about 2 ms at 60k
   edges. It is fine for its occasion-bounded caller and NOT for a per-row road. Keep the pointer to the round-2 record.
2. In `NoteVersionsTests.swift:993`, the message becomes "no table is scanned whole by the candidate-driven gather (the
   classifier's pre-existing automatic edge index is a full pass, recorded)". Alternatively, scope the `SCAN` assertion
   to the gather's statement.
3. In `vx-105-ladder-round2.md:218`, append a one-line correction rather than rewriting the record: "no table scan" means
   no `SCAN` line, and the automatic index build is a full `edge` pass.
4. Optionally, add one clause to `liveReadmeID`'s doc (`BirthFurnitureSeeders.swift:339–341`): "plus, per version
   candidate, the classifier's pass over the edge table".

### MINOR-2 · `Tests/VariorumCoreTests/NoteVersionsTests.swift:1006–1062` (`anyLiveNotesVersionAgreesWithTheClassifierAcrossTheNoteSideShapes`) · the equality pin never exercises the two arms that serve a moment on the edge's SOURCE side, which in production is about half of all moments

**Mechanism (traced, then shown by mutation).**
- `insertVersionOfEdge` stores every `version_of` edge canonically as `(min(id), max(id))` (`Operations+Versions.swift:747,
  760–762`).
- The harness mints `.incrementing` UUIDs, so a saved moment's blocks always have larger ids than its note's anchor.
- So in every one of the pin's shapes, each named moment sits on the edge's TARGET side. The probe printed
  `candidate on TARGET` for all five named moments.
- Even after a `restoreNoteVersion` shape, where the re-anchor puts moments on the SOURCE side, the old anchor's
  cascade-dead edge still witnesses through the target→source dead arm.
- The gather's two `from: "source_block_id"` arms therefore decide nothing the pin can see.

I swapped the gather's arm list in the probe and compared each variant with the classifier, container by container.
Disagreements per arm set:

| Gather's arm list | Pin's shapes | + a restore | SOURCE-side moment (E) | E + note's block merged away (G) |
|---|---|---|---|---|
| all four (as shipped) | 0 | 0 | 0 | 0 |
| no source→target arms | **0** | **0** | 1 | 1 |
| no source→target DEAD arm | **0** | **0** | 0 | 1 |
| no dead arms | 3 | 3 | 0 | 1 |
| no target→source arms | 5 | 5 | 0 | 0 |

A mis-wired source arm also survives the plan pin, which only checks that `idx_edge_source` and `idx_edge_target` each
appear somewhere. For example, dropping the `IS NOT NULL` source arm still leaves `idx_cblock_dead_block` in the plan
through the target arm, and `to: "source_block_id"` still seeks `idx_edge_source`. With random v4 ids in production, a
moment's anchor is the SOURCE about half the time. The everyday LR1-1 rescue on that side, where the note's anchor is
merged away, runs only through the source→target dead arm, and no pin holds that arm.

The shipped code is right today: the derivation above and the probe both agree. This is pin strength, labelled as such.
The red-on-old for a test-strength finding is the mutant: each line in bold above is GREEN on the current pin and RED
with the proposed shapes.

**Proposed fix.** Add SOURCE-side shapes to the equality pin and confirm that the two bold mutants turn red. Either
option works:
- **(a) Rerun the shape set under a decreasing-id generator** (`withDependencies { $0.uuid = … }` around the shapes).
  Every moment then sits on the SOURCE side.
- **(b) Add the two shapes the probe used:**
  - E: save a moment of note N1, `markVersionOf(momentBlock, laterNoteBlock)` against a later note N2, then
    `unmarkPostsAsVersions(N1, moment)`.
  - G: E, then `merge` N2's linked block with its neighbour.

  In both, the moment's only witnessing link has it on the SOURCE side.

The plan pin needs no change.

### NIT-1 · `Sources/VariorumCore/Queries/NoteVersions.swift:361–364` · "since every filter but the link type is left to the classifier"

The gather also applies the peer's own filters: a live post, ≠ the candidate (`note.id <> :container AND note.kind =
'post' AND note.deleted_at IS NULL`). What it leaves to the classifier is the edge fence, the candidate's born-archived
and liveness checks, and `theirs.block_id <> mine.block_id`. The sentence two lines earlier states the peer filters, so
nothing is misread in practice. **Fix:** "since the edge fence and the candidate's own checks are left to the
classifier".

---

## Record additions (8bb17be09) against the arbitration's MINOR-1 order: all four landed

- **VX-712 and VX-713 are named with one pointer each.** I checked Linear:
  - VX-712 is Medium · Bug · Confirmed · Settings & onboarding, parent VX-292, title "…claims ⌘2/⌘1 roads that refuse on
    the book surface…".
  - VX-713 is Low · Wording · Confirmed · Improvement, parent VX-292.

  The record's labels match. Its omission of VX-713's extra Improvement label is harmless.
- **The two QUESTIONS entries are explicit checklist lines with options.** The quoted refusal "Open a note first — the
  modes live inside a note." exists byte for byte at `CapabilityRegistry.swift:1490`. P-105-8's (a) and (b) match the
  P-list entry at the record's line 317.
- **The PROVISIONALs bundle names P-105-1…8.** Each one-line gloss matches its P-list entry at record lines 288–317.
- **"## The ladder" points at both round files.** Round 1's count, "1 MAJOR · 4 MINOR · 3 NIT", matches its STATUS
  line. Round 2's count, "1 BLOCKER · 1 MINOR", matches.
- **The arbitration's "noted non-action"** (the title read's kind walk and the automatic edge index) is recorded in the
  round-2 arbitration itself. It is named in both corrected docs, `NoteVersions.swift:372–374` and
  `BirthFurnitureSeeders.swift:341–344`, which satisfies "recorded here". MINOR-1 concerns only how accurately that
  automatic-index step is described.

## Clean bill (load-bearing things checked and found solid)

- **Semantic equivalence**, derived above and confirmed by the probe across six store shapes: the four-arm gather plus
  `isVersionHistory` equals `versionHistoryPredicate(.anyLiveNote)` on every container. Specifically:
  - The `mine` side reads past tombstones, as the classifier does.
  - The two liveness arms, through the two partial indexes, cover every `theirs` placement.
  - `UNION` dedup cannot drop a peer.
  - The gather applies no edge fence, so cascade-dead edges, which the classifier keeps, are gathered, and deliberate
    unmarks are judged by the classifier alone.
- **Order and planner robustness.** `CROSS JOIN` fixes the loop nest whatever the stats. The repo never runs
  `ANALYZE` or `PRAGMA optimize` (I searched `Sources/`), so no stats can move the plan in her store.
- **The plan pin is sound.** `db.trace` captures exactly the call's statements, expanded with their bound values.
  `EXPLAIN QUERY PLAN` runs after the trace is removed. Its `idx_container_kind` assertion is red on the round-1 statement
  and green now, as observed here. Its "SCAN" message is the subject of MINOR-1.
- **The behaviour pin `anyLiveNotesVersionIsNamedAndNothingElseIs`** is unchanged and green.
- **The record's red sequence (a)–(d)** is consistent with what I reproduced. I reproduced (a) and (d). I did not rerun
  the intermediate drafts (b) and (c), whose shapes are plausible given the plans above.
- **The cost of the non-version candidate is consistent with the doc.** Her live readme, linked to K moments, now runs K
  short-circuiting `isVersionHistory` statements: 1.36 ms at K = 10 and 11.6 ms at K = 100. That stays flat as the edge
  table grows (11.6 ms at 8.6k edges), so the automatic index is never built for a candidate that fails the born-archived
  check. It scales with the note's own history, never the corpus (P1). The round-1 form short-circuited this case in
  ~0.1 ms. The difference is real but bounded, it happens on a Help press, and the doc's "plus one `isVersionHistory` per
  live note it is linked to" says it.
- **`liveReadmeID`'s corrected doc.** "Every live post titled "readme" … K saves mean up to K + 1 candidates, asked in
  id order until one is not a version" is true of the code at `:345–354`. "Never a walk of the notes" is true. The title
  read's kind walk is honestly named as the recorded non-action.
- **The VX-692 toolchain hazard.** The new pins' helpers are separate functions, and no test body holds two same-typed
  `db.read` closures. The plan pin's single `explainedPlans` closure is the only one of its type in its body.
- **No other reach.** No schema, trigger, `Sync/` line, word-level tracking or cross-entity text copy is involved. Her
  readme text and the passages are untouched. The app-side change is a doc comment only.

**STATUS: ROUND 3 COMPLETE — 0 BLOCKER · 0 MAJOR · 2 MINOR · 1 NIT.** BLOCKER-1's fix meets the finding's shape. It is
candidate-driven, uses index seeks only in the gather, lets the one classifier decide, and has a red-on-old plan pin plus
an equality pin. Its semantics are exact. What remains is the accuracy of the corrected cost line (MINOR-1, words) and
the equality pin's blind half (MINOR-2, test shapes). The ladder is at its cap: these are the orchestrator's to
arbitrate and check line by line.
