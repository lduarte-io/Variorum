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

### MINOR-1 · `notes/plans/fixes/vx-105-readme-letter.md` "## The ladder" and "## Closeout checklist" · the round's owed merge-time acts are missing from the checklist the closeout walks, and the arbitration points at a section that does not hold them

**Evidence.** The round-1 arbitration says *"Tickets minted at this arbitration: see the record's closeout section (the
getting-around sibling; the end-card wording)"* (`vx-105-ladder-round1.md:97`). The closeout checklist
(`vx-105-readme-letter.md:477–485`) names neither ticket. VX-713 is noted only on O-1. **VX-712**, the getting-around
⌘2/⌘1 sibling (it exists on Linear: Medium · Bug · Confirmed, a child of VX-292), is named NOWHERE in the repo. The two
QUESTIONS entries owed "at the merge" sit only in prose: R-105-10's "should 'Open Takes mode' (and ⌘1–⌘7) over a book
open the note?" and P-105-8's "should the door's born star be a non-event?". The P-list header's "for QUESTIONS at the
merge" also covers P-105-1…7. None of these is a checklist line. "## The ladder" (`:473–475`) is still the empty
placeholder, although its own text says findings land there. Records only, nothing behavioural, but this is exactly
what gets dropped at a serialized closeout, and CLAUDE.md routes undefined product behaviour to QUESTIONS.

**Fix.** Add checklist lines: (1) the QUESTIONS entries — the Open-Takes-over-a-book question, P-105-8, and the
P-105-1…7 PROVISIONALs; (2) VX-712 and VX-713 named, with their parent VX-292; (3) under "## The ladder", one pointer
line per round file (`vx-105-ladder-round1.md`, `vx-105-ladder-round2.md`). No pin, because it is a record change.

---

## Clean bill (the round-1 dispositions, each checked against the code)

- **MINOR-1 (a saved version is never "a live readme").** The behaviour is right. `liveReadmeID` now returns the first
  candidate (in id order) that the one classifier does not name, so both arms of the round-1 mechanism are closed.
  (i) She saves a version, renames the readme, presses: the only "readme" left is the moment → skipped → fresh mint.
  (ii) The id-order coin flip between readme and moment is gone, because the moment is always skipped. The birth seed
  and the door share the read. The app pin's red-on-old is credible: on the old bare read the moment is the only live
  "readme", so the refusal speaks and `pendingSelection == .post(moment)`. The core pin RAN GREEN here, and its arms
  discriminate: the note, plain, archived-work and unmarked arms would each read `true` if the first `db.read` body were
  substituted (VX-692's toolchain hazard), so none can pass hollow. The final post-deletion arm is the same call as the
  first, so the hazard cannot change it. (The cost of that classifier is BLOCKER-1, a separate matter.)
- **MINOR-2 (the birth seed decides inside its mint's turn).** Both reads moved into the `session.runner.run` body
  that mints. `@Dependency(\.database)` there resolves the caller task's dependency context, the same database the
  quiet facade `Operations(undoStack: nil)` writes through. That is `restore`'s shape and
  `SampleLibraryWelcome.arrange`'s (`:187`). It is now MORE consistent than the old `session.database` read beside an
  ambient mint. Errors still land as `.refused`. The header's "no door latch" line is now true: the snippet has no
  door, and the readme's door is one turn. `theBirthSeedReadsNothingOutsideItsMintsTurn` is deterministic and red on
  old: its slice runs from `performBirthSeed(` to `/// **THE ONE MINT**`, both present, and the doc comment that names
  `session.database.read` sits above the slice. The interleave pin's green side is order-independent. Its red side
  leans on the actor taking same-priority turns in order, and the record labels that honestly. The pin's semaphore wait
  is bounded and runs in a synchronous runner body, so it cannot hang the suite.
- **MINOR-3 (the door's star is heard).** As arbitrated: no code change. P-105-8 states the built behaviour, the
  alternative and the pin owed if (b) is ruled. The QUESTIONS line belongs to the merge (MINOR-1 above).
- **MINOR-4 (the fold's words).** Every stale site is corrected: `LaunchFurniture.swift:136–138`, the header,
  `MacFurnitureFacts`, `furnitureFact`, `VariorumApp.swift:245–247`, and the wiring pin's message. A grep for the old
  claims ("every seeded … folds on sign-in", "carries its Start Here", "no doors to race") is clean. The rename is
  done. The restored drift net is credible. I traced `noteVerdict` (`SeededFurnitureDedupe.swift:706–819`; read only,
  `Sync/` untouched): it has no stamp leg, so the split stamp (created 4:44, edited at mint) never reads as engagement.
  The star is the only leg the born readme trips (`:727`). Un-starring through the one star write removes it. The
  signature (title, lock, comments, per-block take texts in fan order, chosen index) is equal across two mints. The
  "currency net, green both sides" label is honest.
- **MAJOR-1, reshaped by R-105-10 (the first ask is the move from the book into the note).** Every claim in the new
  block and in the F-3 closer is true of the code:
  - The guide opens on the BOOK (`openTutorial` → `.reading`), on `.outline` (`BookStructureModel.defaultMode`, the
    guide is unlocked).
  - Notes are collapsed CARDS by default (`expandedPosts` starts empty, her #43(a)).
  - The card BODY is the open door (`BookView.swift:3861–3863`), and "open ↗" sits on the card's title row (`:3888`)
    and beside the expanded title (`:3838`). Both carry the help "Open this note in the full editor (Write · Takes ·
    Lenses · …)" and land in Write (`:1235`).
  - Over a book a mode request refuses (`CommandRouter.swift:549–551`), and the take panel offers neither "expand all"
    nor the style menu.
  - The book navigator is the LEADING side (`BookView.swift:256`), so "the chapters are listed on the left" holds.
  - "The book glyph above the page takes you back there, at that very note" matches `ContextBar`'s `.open` arm
    ("open this book, revealed at this note") and "the workspace" lesson's own "Above the page sits the context bar".
  - Every string the road pin scans is present byte for byte, including the router's 12-space indentation and the
    card's multi-line `Button {` shape. The `label: "style:` absence check matches how Takes actually spells its menu,
    so it is not vacuous.
  - The new rendered text is sentence case, with no em dash and no emoji, and "open ↗" is interpolated from
    `NoteBoxCopy.openDoor` (`nonisolated`, so it is legal in the nonisolated seed).
  - Her take-icon block is verbatim again. A reader who clicks the card lands inside the note, where "if it isn't open
    already" reads true.
- **The 14th block's blast radius.** Only `TutorialCurrencyTests` and `HelpMenuNamingTests` read this lesson.
  `theGuidesSeededContentIsNotReworded`'s source slice (start here → getting around) still reads the verb and spells
  no retired name: the NIT-2 helper's message adds none. The tour points at Sherlock's first story, not this lesson.
- **NIT-1.** The record now says what changed and why. Its evaluation's claims check out: the only writer of
  `last_major_revision_at` is `registerTextChange` (`Operations+Variant.swift:688`), and `forceMajorRevision: true`
  comes only from the manual `commit` (`:65`).
- **NIT-2.** `fanned(_:opening:)` checks index 5 → "I built Variorum with a simple goal" and index 7 → "This is the
  point at which you might be thinking", both true of the 14-block lesson. DEBUG asserts and Release attaches nothing.
  Her four take texts and their mint order are byte-unchanged.
- **NIT-3.** VX-713 exists on Linear (Low · Wording · Confirmed, a child of VX-292).
- **Her text and the passages.** The `ReadmeSeeder.paragraphs` literal, `TutorialStartHerePassages.swift` and the
  content package are untouched by `0bf9c0645..HEAD` (the hunks fall outside them).
- **No other invariant reach.** No schema, no trigger, no `Sync/` line, no word-level tracking, no cross-entity text
  copy. The core change is a read, and its one problem is BLOCKER-1.
- **VX-692 exposure (the closure-merge toolchain hazard) of the new pins.** Two of them use the hazardous shape. The
  road pin's `#require(try await db.read { Reading.fetchOne })` has no later same-typed closure. The MINOR-1 app pin's
  `#expect(try await db.read { … })` has none either (`pollUntil`'s closure is a different type). The core pin is
  covered above. None of the round's pins can pass hollow through it.
- **Compiles.** `build-for-testing` EXIT 0, as the record claims. RUN status of every Mac pin remains PENDING the stage
  window; nothing here substitutes for it.

**STATUS: ROUND 2 COMPLETE — 1 BLOCKER · 1 MINOR.** BLOCKER-1 is new in this round (MINOR-1's fix introduced the read),
so under the ladder it earns a round 3 unless the arbitration rules otherwise against the review prompt's
corpus-scale rule. Every round-1 disposition otherwise landed as ruled.

## Round 2 arbitration (the orchestrator, same-model ladder)

- **BLOCKER-1 — CONFIRMED, fixed this round, earns round 3.** The fix is the finding's own: `isVersionOfAnyLiveNote` drives from the CANDIDATE'S own placements/version links (the `noteVersionStamps` shape) and lets the one classifier decide per linked note; both false doc lines corrected to the real cost; the plan pin (no `SEARCH peer USING INDEX idx_container_kind`) red-on-old on this tree, paired with the equality pin across the note-side shapes. The finding's "older context" (the title read's kind-index walk; the automatic edge index inside the existing `isVersionHistory`) is PRE-EXISTING and occasion-bounded (a birth seed and a deliberate Help press) — recorded here, deliberately not fixed in this effort; it joins the record as a noted non-action, ticketable if the class ever meets a hot path.
- **MINOR-1 — CONFIRMED whole.** The record gains: VX-712 and VX-713 named with one pointer each; the two QUESTIONS entries owed at the merge as explicit closeout checklist lines (the "Open Takes mode over a book" question; P-105-8's door star); the P-105-1..8 PROVISIONALs listed for the merge-time QUESTIONS bundle; "## The ladder" filled with pointers to the two round files.

Round 3 (fresh reviewer) re-checks the BLOCKER fix; hard cap three rounds.

## FIX ROUND 2 RECORD (the fix-round implementer, resumed for this tail, 2026-10-30)

**What this round did NOT do (first line):** no Mac suite was RUN (stage window only); no walk, no app launch, no
`/Applications`; nothing under `Sources/VariorumCore/Sync/`. The arbitration's pre-existing context — the title read's
kind walk, and the automatic edge index inside the existing `isVersionHistory` — is untouched, as ruled. Her readme
text is untouched.

### LIVE STATUS

- **BLOCKER-1** (`Queries.isVersionOfAnyLiveNote` walked every live note) — DONE (the commit carrying this line).
  **The fix:** the read is now CANDIDATE-DRIVEN, the `noteVersionStamps` shape from the other side. One statement of
  FOUR UNION arms (the link's two directions × the other endpoint's placement live or dead) reaches, from the
  candidate's OWN placements (`mine`, live or tombstoned, `idx_cblock_order`), its `version_of` links
  (`idx_edge_source` / `idx_edge_target`) and the other endpoint's placements — LIVE through `uq_cblock_ownership`,
  TOMBSTONED through `idx_cblock_dead_block` (the two partial indexes together cover every placement by block; LR1-1
  needs both) — keeping each note that is a live post other than the candidate (a seek by id). Then the ONE classifier
  decides per linked note: `isVersionHistory(db, candidate, of: note)`. No classifier text is copied: the link query
  only GATHERS peers (every filter but the link type is left to the classifier, so its peer set is a superset of the
  ones `.anyLiveNote` can name), and the `.anyLiveNote` answer is exactly "some live post p ≠ v with
  `isVersionHistory(v, of: p)`". `CROSS JOIN` pins the loop order. Without it the planner (no ANALYZE stats) chose
  `SEARCH note USING INDEX idx_container_kind` again (the second red below); with one combined `theirs` arm it scanned
  `container_block` (the third). **Both false doc lines corrected:** the query's own "Cost:" (now the candidate's
  placements and links by index seeks, plus one `isVersionHistory` per linked live note, whose older plan builds the
  automatic `version_of` covering index — named as the round-2 record's pre-existing, occasion-bounded context), and
  `ReadmeSeeder.liveReadmeID`'s "a handful at most" (now: her readme and every saved version of it, K saves → up to
  K + 1 candidates, each asked through the candidate-driven read; the title read's kind walk named as pre-existing and
  left, per the arbitration).
  **The plan the fix runs** (printed by a throwaway test, run and deleted — never committed): four arms of `SEARCH mine
  USING INDEX idx_cblock_order (container_id=?)` → `SEARCH e USING INDEX idx_edge_source|idx_edge_target (…=? AND
  type=?)` → `SEARCH theirs USING INDEX uq_cblock_ownership (block_id=?)` | `… idx_cblock_dead_block (block_id=? AND
  deleted_at>?)` → `SEARCH note USING INDEX sqlite_autoindex_container_1 (id=?)`, merged by UNION; then, per linked
  note, `isVersionHistory`'s unchanged plan (`SEARCH v` by id, `mine`/`theirs` by `idx_cblock_order`, the automatic
  partial covering index on `e`). No `idx_container_kind`, no table scan. [Round-3 correction (ladder round 3,
  MINOR-1): "no table scan" means no `SCAN` line in the plan, and no more. The automatic partial covering index on
  `e` is built on every `isVersionHistory` call by a full pass over the WHOLE `edge` table (every type); the plan
  labels that step SEARCH. See `vx-105-ladder-round3.md`.]
  **Pins** (core, `Tests/VariorumCoreTests/NoteVersionsTests.swift`, HEADLESS):
  1. `anyLiveNotesVersionIsReadFromTheCandidateNeverTheNotes` — the plan pin in the
     `VersionsInCompareTests.theStampsReadIsDrivenFromTheNotesOwnPlacements` shape: every statement the call runs is
     traced (bound values inlined, `expandedSQL`), `EXPLAIN QUERY PLAN`ned, and the details asserted. No line uses
     `idx_container_kind`; `mine` seeks `idx_cblock_order`; both edge indexes seek; `theirs` seeks `uq_cblock_ownership`
     AND `idx_cblock_dead_block`; `note` seeks by id; no table `SCAN` (`SCAN CONSTANT ROW`, an `EXISTS` wrapper's one
     row, excepted). Four other notes in the store, so a kind walk would have somewhere to go. **RED THEN GREEN,
     observed in this session, in this order:**
     - **(a) RED on the round-1 tree, before any fix:** `!plan.contains { $0.contains("USING INDEX
       idx_container_kind") }` failed, the plan reading `… "SEARCH peer USING INDEX idx_container_kind (kind=?)" …` —
       exactly the finding's line; the edge-index expectation failed too (`SEARCH e USING AUTOMATIC PARTIAL COVERING
       INDEX`).
     - **(b) RED on a first candidate-driven draft with plain JOINs:** `SEARCH note USING INDEX idx_container_kind
       (kind=?)` — the planner re-chose the walk.
     - **(c) RED on a CROSS JOIN draft with one combined `theirs`:** `SCAN theirs` (no single index serves live and
       tombstoned placements).
     - **(d) GREEN on the four-arm form:** `swift test --filter anyLiveNotesVersion` — 3 passed.
  2. `anyLiveNotesVersionAgreesWithTheClassifierAcrossTheNoteSideShapes` — the equality pin. Shapes: the anchor block
     merged away, divided, archived, deleted (LR1-1); a deliberate unmark; a promote; a live fork (`duplicateAsVersion`
     — a version LINK born live); the note renamed; a note deleted (its moment rides it). For EVERY container in the
     store, `isVersionOfAnyLiveNote` == `versionHistoryPredicate(alias: "v", of: .anyLiveNote)` asked directly; and the
     set named is exactly the five moments that stay their note's past (unmarked, promoted and rode-the-deletion not
     among them). Green on both sides by design (the round-1 form WAS the predicate) — it holds the rewrite to the
     classifier. Its helpers are separate functions, so no two same-typed closures share a body (the VX-692 hazard).
  3. `anyLiveNotesVersionIsNamedAndNothingElseIs` (round 1's behaviour pin) — unchanged, GREEN.
  **Headless runs:** `swift test --filter "NoteVersionsTests|VersionsInCompareTests"` — 37 tests in 2 suites PASSED
  (incl. `theStampsReadIsDrivenFromTheNotesOwnPlacements`, unchanged). `xcodebuild … build-for-testing -quiet` EXIT 0
  (the app's `liveReadmeID` doc edit; the app door pins `LaunchFurnitureTests.aSavedVersionOfTheReadmeIsNeverALiveReadme`
  and the round-1 door arms compile — they are Mac suites, RUN PENDING the stage window; their behaviour is the core
  read's, which the equality pin holds to the classifier).
- **MINOR-1** (record hygiene) — DONE (the commit carrying this line), records only, no pin (as the finding says). In
  `notes/plans/fixes/vx-105-readme-letter.md`: "## The ladder" now points at both round files (round 1's counts and
  its fix record; round 2's BLOCKER and its round-3 consequence); the closeout checklist gains (1) the two QUESTIONS
  entries owed at the merge as explicit lines, each with its options — "Open Takes mode" (and ⌘1–⌘7) over a book, and
  P-105-8's door star; (2) the PROVISIONALs bundle, P-105-1 … P-105-8 named for the merge-time QUESTIONS pass; (3)
  VX-712 (the "getting around" ⌘2/⌘1 sibling) and VX-713 (the end card's wording) named once each, with their parent
  VX-292, as tickets to triage at the closeout beside VX-711. VX-713's existing O-1 note stands.

**ROUND STATE: READY-FOR-STAGE (and for ladder round 3).** Every round-2 finding dispositioned; the core pins RUN
GREEN headless (the plan pin observed red first); the app compiles (`build-for-testing` EXIT 0). The stage-window
expectation is UNCHANGED from round 1 (`vx-105-ladder-round1.md`, "Stage-window expectation"): the same suite types,
everything passes, no expected red — this round added core tests only (headless, already run) and changed no Mac test.
Commits: `c7624059f` BLOCKER-1 · this commit MINOR-1.
