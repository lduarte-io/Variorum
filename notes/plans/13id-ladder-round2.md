# 13i-d LADDER A — ROUND 2 (cold re-review of round 1's fixes, `fable-reviewer`, 2026-10-02)

**Subject:** the round-1 fix diff `3634321f..e29092da` — the four fix commits `8f21224f` (MINOR 2),
`f649d45f` (NIT 4), `99a9d30d` (MINOR 1), `fce9295d` (NIT 3), the sanity NIT's fix `6d592161`, and
the round's two record commits (`4a22aa49`, `e29092da`). Prompt: `notes/REVIEW_PROMPT.md` VERBATIM;
anchor: `notes/plans/13id-ladder-round1.md` (the four findings, the zero-dispute cross-model
responses, the FINAL CALLS, the sanity NIT). The wider bank diff `d8f7c452..8b41f667` was round 1's
subject and is context only. No editor seam, no custody, no `Sync/`, no `Persistence/`, no schema
in this diff (verified by file list: `Sources/VariorumCore/Queries/` + Mac features + tests +
the ladder record only).

**STATUS: ROUND 2 COMPLETE — no BLOCKER, no MAJOR, no MINOR; ONE NIT (test-clarity, on a new
pin's redundant assertion). Nothing reaches the round-3 bar.**

## FINDINGS (severity-ranked; `[severity] · file:line · what · evidence · fix`)

- **[NIT] · `Tests/VariorumCoreTests/BookcaseShelfTests.swift:~409`
  (`theWingScopedStatementsDriveFromTheWingNeverTheStore`, second `#expect` of the plan loop) ·
  the pin's anti-scan assertion is ALIAS-BLIND and can never fire in its intended role ·
  **Evidence (traced):** the assertion is `!plan.contains("SCAN reading_post") &&
  !plan.contains("SCAN reading_section")`, but every shipped statement aliases the pair tables
  (`rp`/`rs`), and EXPLAIN QUERY PLAN prints the ALIAS — the round-1 record itself says the
  reverted store-wide plans read `SCAN rp USING INDEX uq_reading_post_live` / `SCAN rs …`, which
  this string test passes. So on the behavioural revert the recorded 4 issues were all the FIRST
  assertion's (`plan.contains("SEARCH rp/rs USING")` — the load-bearing arm, which genuinely went
  red); the second arm asserted nothing then and asserts nothing now. The pin as a whole has
  teeth; this arm is dead weight that reads as a second independent check. No pin applies — this
  is a finding ABOUT a test's clarity, not a bug (the justification is the trace above: no input
  exists that fails arm 2 without failing arm 1 first, given the aliases). · **Fix:** make the
  arm honest (`!plan.contains("SCAN rp")` / `!plan.contains("SCAN rs")`) or drop it and let the
  SEARCH assertion carry the pin alone; either is a one-line test edit, routable to the closeout
  or U5's bank rather than a fix pass of its own.

Nothing else. Specifically: **no new BLOCKER or MAJOR — no round 3 is earned by this diff.**

## FIX-BY-FIX VERIFICATION (correct and complete against round 1's findings; nothing new introduced)

### MINOR 1 (`99a9d30d` — the superseded-observation stomp, three models + the refresh extension) — CORRECT AND COMPLETE

- **The guard is in all three places the finding named, in the exact sibling shape:**
  `MastheadTagsModel.adopt` (MastheadTagCluster.swift:292), `BookIndexGroupingModel.adopt`
  (BookIndexGrouping.swift:315), `BookArchivedModel.adopt` (BookArchived.swift:166) each open
  with `guard !Task.isCancelled else { return }` — compared byte-for-mechanism against
  `NoteMembershipModel.track`'s guard (NoteMembershipModel.swift:72). Guarding inside `adopt`
  rather than the loop body is equivalent for the production path (the loop calls `adopt` in the
  same task) and additionally covers the pins' direct calls.
- **U3's refresh extension landed:** `MastheadTagsModel.refresh` gains
  `guard subject == nil || subject == postID` (MastheadTagCluster.swift:281). I traced the four
  orderings myself: (1) stale refresh(old) landing AFTER the new note's adopt → dropped (the
  fix); (2) stale refresh(old) landing while subject is STILL old → re-adopts old data into an
  old subject — no stomp of the new note (its cards already answer `[]` by the `tags(for:)`
  subject check), and the new track corrects; (3) refresh(new) landing while subject is still
  old (a door act racing the track's first delivery) → dropped, BUT the very write that
  preceded the refresh wakes the held `post_tag`+`tag` region, whose delivery adopts with the
  new postID — self-healing is guaranteed by the write itself, not by chance; (4) fresh visit
  (nil subject) → adopts. No legitimate adoption is lost; no new staleness window opens.
- **Each model has exactly one observation road** (plus Masthead's refresh, now guarded) — I
  read all three models in full; no unguarded adopt path remains. `BookArchivedModel`'s
  auto-fold (`if value.count == 0 { expanded = false }`) now correctly cannot fire from a
  cancelled delivery either.
- **The four pins are deterministic and honest:** all three test suites are `@MainActor`
  (checked the declarations), so the `Task { @MainActor in … adopt … }` body cannot run before
  the test suspends at `await late.value`, and `cancel()` lands first — the claimed determinism
  holds. The recorded red-on-old arithmetic is internally consistent with the code: on the
  pre-guard models the track pin fails 2 expects, the refresh pin 1, the grouping pin 2, the
  archived pin 1 (its `expanded` expect passes — count was 1) = exactly the recorded
  **4 red / 6 issues**. `adopt`'s private→internal change is visibility-only (no production
  caller outside the class; scaffolding-before-red honestly recorded). Ran all four pins green
  in this session (part of the 39/6 Mac run below).

### MINOR 2 (`8f21224f` — the held read works the wing's own rows, widened per U1) — CORRECT AND COMPLETE

- **All four held statements are wing-driven** as the widened finding required:
  `bookcaseMemberCountsSQL` / `bookcaseSectionCountsSQL` / `bookcaseArrivalCountsSQL`
  (wingScoped forms) and `wingMemberStampsSQL` all drive from `reading r WHERE r.wing_id = ?`
  with `CROSS JOIN` onto the pair table — verified against `wingArchivedCountsSQL`'s shape
  (ArchivedMemberQueries.swift:152; SQLite's CROSS JOIN pins the join order, which is what makes
  the EXPLAIN pin's SEARCH-not-SCAN meaningful), and the fifth (the readings fetch) filters in
  SQL (`bookcaseReadings`).
- **Output equivalence traced (no behavior change rode the cost fix):** the nil-wing branches
  are byte-identical to the removed inline statements (the phone's `MobileShelfViewModel` /
  `MobileBookDetails` call `bookshelf(db)` with no wing — untouched); the wing-scoped forms add
  only `r.wing_id = ?` + `r.deleted_at IS NULL`, which the old code applied anyway by consulting
  the counts dictionaries only for the wing's live readings. `bookcaseReadings`' wing form keeps
  `ORDER BY name, id` — the SAME order as `Queries.readings` (ReadingAssembly.swift:143), so
  `bookshelf`'s row order is unchanged. The Mac passes `wingID: ""` (Home) and rides the scoped
  path; `""` matches Home's rows by the virtual-wing convention.
- **No kind filter was added** (unlike `wingArchivedCountsSQL`'s `r.kind='book'`) — correctly
  so: the old store-wide statements had none either, so per-reading output stays identical; the
  stray-gathering-row corner is round 1's documented safe-direction class, unchanged.
- **The held region gained no table:** the scoped statements name `reading` /`reading_post`/
  `reading_section` only, all already in the region; the round-1 P1 pin
  `theHeldSnapshotsRegionIsBlindToAutosave` re-run green in this session. `wingMemberStampsSQL`
  joins `container` but lives in the ONE-SHOT `bookcaseAggregates` — consistent with the P1
  letter, and the aggregates' cost comment is now true as claimed.
- **The re-word landed:** `ShelfViewModel.refreshAggregates`' doc now says the three 13 B2
  one-shots are store-wide; grepped the core headers of `bookWordCounts`/`shelfBookTags`/
  `ruleTagPaths` — no false wing claim remains anywhere.
- **The pin:** `theWingScopedStatementsDriveFromTheWingNeverTheStore` ran green here (EXPLAIN
  QUERY PLAN asserting `SEARCH rp/rs USING` on all four statements + the no-`container` letter);
  the behavioural-revert red is honestly recorded (the pre-fix functions took no wing argument —
  the pin could not compile against them; a pure cost claim has no functional red). The one NIT
  above is about this pin's redundant second assertion, not its load-bearing arm.

### NIT 3 (`fce9295d` — the Move to Shelf gate) — CORRECT AND COMPLETE

- `BookcaseBoard.moveToShelfCanAct(shelfCount:here:)` implements exactly U1's confirmed gate
  (`shelfCount > 0 || here != unshelvedKey`); `ShelfView.swift:565` is the ONE rendering site of
  `.moveBookToShelf` (grepped) and now gates the `Menu`; the inner items are a pure re-indent
  (verified against the diff — logic byte-equivalent).
- **Truth table traced at the corners:** gate false exactly when shelfCount == 0 AND the book
  resolves unshelved. A DANGLING shelf pointer resolves to `unshelvedKey` upstream
  (`BookcaseBoard.resolvedShelves` applies §7's dangling rule before `shelfKey` answers), so a
  dangling-pointer book in a shelf-less wing correctly draws no submenu; when any shelf exists,
  the menu always has ≥1 item (the on-a-shelf book gets Unshelved; the unshelved book gets the
  shelves). The pure-value case `(0, "s1")` is unreachable through the view model (resolution
  precedes) but answers sensibly — harmless.
- Declared-but-conditionally-rendered is the bank's established P-2 pattern (the Book Panel's
  gated menu twins); the registry walk ran green at the round's close per the record.
- The behavioural-revert red (gate flipped to `true` → exactly the no-destination case) is
  honestly recorded; a new pure value has no pre-fix shape. Pin ran green here.

### NIT 4 (`f649d45f` — one A–Z on the Starred tail) — CORRECT AND COMPLETE

- The `.sorted { BookcaseOrdering.nameAscending(…) }` lands on the column-only tail inside
  `Queries.starred` alone (AppearanceQueries.swift:223) — exactly U1's confirmed scope.
  `nameAscending` is `localizedStandardCompare` with an id tie-break (BookcaseOrdering.swift:32)
  — a total order, no stability dependence.
- **Red-on-old premise verified:** `starredReadingRows` orders by `name COLLATE NOCASE, id`
  (AppearanceQueries.swift:159), under which "Book 10" < "Book 2" ('1' < '2' at the first
  differing byte) — the recorded genuine red is exactly what the old code produces.
- **Other consumers unaffected, checked each:** `shelfPins` (documented as a SET in stable
  order — the board re-sorts), `starredReadingIDs` (a Set), `writeStar`'s union read
  (`.map(\.target)` — order-insensitive cap math), `ShellActions`' `contains`. The phone's
  `MobileStars` reads `Queries.starred` and inherits the same one A–Z — consistent, not a skew.
  Pin `theColumnOnlyTailUsesTheBoardsOwnAToZ` ran green here.

### The sanity NIT (`6d592161` — the re-bound `@MainActor`) — CORRECT

- Final state verified in `BookcaseBoardTests.swift`: `MoveToShelfGateTests` is nonisolated with
  its doc saying so ("a pure value over the nonisolated `BookcaseBoard` — no actor isolation
  needed"); `@MainActor` sits directly above `@Suite("Bookcase view model (13i-d U1)",
  .serialized)`. The no-pin reasoning (a compile-level isolation restoration, zero behaviour) is
  sound; both suites ran green here.

### The record commits (`4a22aa49`, `e29092da`) — ACCURATE

- The FINAL CALLS section's every mechanical claim was checked against the diff and the runs:
  the fix-commit hashes match `git log`; each described fix matches what landed; the
  red-on-old/behavioural-revert labels are each truthful about which kind they are; the
  recorded 4-red/6-issue arithmetic matches the code (above); the core 2060/221 claim matches
  my own full run.

## CLEAN BILL (load-bearing things specifically checked and found solid)

**Checked by running in this session:**
- Core: `BookcaseReadTests` + `UnionStarTests` (15/2, including both new core pins and the
  revert-verified P1 region pin), then the FULL core suite — **"Test run with 2060 tests in 221
  suites passed"**, byte-matching the round-1 record's end-state claim.
- Mac (`DerivedData/13id-ladderA`, incremental build-for-testing + test-without-building, zero
  running real-store instances checked first): the six fix-adjacent suites
  (MastheadTagsObservation · BookIndexGrouping · BookArchivedLine · MoveToShelfGate ·
  BookcaseViewModel · BookcaseBoardBrain) — **39 tests in 6 suites passed**, all four stomp pins
  and the gate pin among them. The full Mac 222/33 and the phone test-build are the record's,
  not re-run here (said honestly; the suites specific to this round's fixes I ran myself).

**Checked by reading and tracing myself:**
- Every hunk of `git diff 3634321f..e29092da` read in full in this session (code, tests, and
  the ladder-record additions).
- The four refresh/track/adopt orderings of `MastheadTagsModel` (no lost adoption, no new
  staleness window — the self-heal is write-driven, not coincidental).
- SQL semantics equivalence of all five wing-scoped reads against their store-wide
  predecessors (output per wing reading identical; row order identical; region identical;
  phone path byte-identical).
- The gate's truth table including the dangling-shelf-pointer corner (resolved upstream to
  unshelved — §7's rule honored before the gate ever sees it).
- `Queries.starred`'s consumer set for order sensitivity (none harmed; the phone converges on
  the same A–Z).
- Suite isolation of the three stomp-pin suites (`@MainActor` — the determinism claim's
  premise) and the sanity fix's final attribute placement.
- Commit hygiene: zero `Co-Authored-By`/`Claude-Session` lines across all 7 commits (grepped
  full bodies); per-piece commits; `origin/main` == `e29092da` (pushed through the round's end).
- Scope fences: no `Sync/`, no `Persistence/`, no schema, no editor seam anywhere in the diff.

## SUMMARY BY SEVERITY

- **BLOCKER:** none.
- **MAJOR:** none.
- **MINOR:** none.
- **NIT:** 1 — the alias-blind second assertion inside the new EXPLAIN-plan pin (test clarity
  only; the pin's load-bearing arm is sound and revert-verified). Routable to the closeout or
  U5's bank; it does not earn a fix pass, a sanity pass, or a round 3.

**No new BLOCKER or MAJOR — the ladder does NOT earn a round 3. Round 1's four findings and the
sanity NIT are each fixed correctly and completely, with honest pins; the fixes introduce no
regression I could trace.**
