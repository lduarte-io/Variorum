# 13n-b U4 — ladder round 2 (cold re-review of the round-1 fixes, fable-reviewer, 2026-10-10)

**Charge:** re-review the round-1 fix pass — the diff `fce833b1..22b79e41` (five reviewer fix
commits `c707340f`/`3f1230bc`/`61abd4d6`/`2096effc`/`f6445fa6` + the architect's precision
commit `013c5f41`; the six coordinator commits in the range are record-only, verified: each
touches `notes/plans/` alone) — verifying every round-1 disposition landed as written, every
pin real (red-on-old re-verified by MY OWN reverts where load-bearing), and nothing new
broken. Anchor: `notes/plans/13nb-u4-ladder-round1.md` (findings F-1…F-7, dispositions 7/7
AGREE, the fix pass, the sanity pass).

**Fences, re-checked over the range by my own hands:** zero files under
`Sources/VariorumCore/Sync/`, `Server/`, `Persistence/`, custody/keychain, or the editor seam
(`BlockRangeIndex`/`EditorTextView`/`PaneTextAuthority`); zero commit trailers
(`Co-Authored-By`/`Claude-Session` grep empty over `fce833b1..22b79e41`); no schema, no
migrations, marker untouched.

---

## Disposition-by-disposition verification

### F-1 (MAJOR — the bell override) · VERIFIED LANDED, pins re-proven red-on-old by my own revert

- **Mechanism re-traced end to end:** `writeReadingQuerySpec` gains `sweepOccasion override:
  IntakeDecision.Occasion? = nil` (`Operations+Reading.swift:237`); exactly TWO call sites
  exist in the tree (my grep): her `setReadingQuerySpec` (line 220, passes nothing — her
  Save's backfill classification byte-untouched) and the MCP act (`Operations+MCPCarriage.swift:296`,
  passes `.catchUp`). The pure table (`Domain/IntakeDecision.swift:170`) turns `.catchUp`
  into `.arrival` for every fresh pair and `.nothing` for decided pairs — an agent-written
  rule can never seat. The undo path (`restoreCollectingColumns`) is a raw three-column
  UPDATE that never calls the choke point — undoing/redoing an agent rule write re-runs no
  sweep.
- **Wire-surface closure checked beyond the fix itself:** `set_book_rule` is the ONLY
  rule-writing road on the wire (`create_book` → `Operations+MCPWrites.swift:496` inserts a
  rule-less book with NO sweep — the creation-time backfill arm at `Operations+Reading.swift:87`
  is unreachable from a client); and EVERY `reading_post` read on the MCP surface filters
  `status = 'member'` (my own audit: `MCPReadTools.swift:213/339/430`,
  `MCPNoteStructure.books`, `MCPGrantQueries.swift:290/310/381/418` — reach, list counts,
  the journal fence's member leg and the Private leg alike), so the bell closes BOTH the
  read oracle and the count oracle. `new_matches` on the facts is the join dial's word
  ("join"/"wait"), never a count — no match oracle reopens there.
- **Red-on-old BY MY OWN REVERT** (checkout of the two core files at `fce833b1`, pins kept):
  `aRuleWriteNeverExpandsTheClientsOwnReach` RED with 3 issues — the first being the
  previously-unshared note's text ANSWERING (the leak live on old) — and
  `anAgentRuleWritesIntakeBellsAndItsRowsStayThroughUndo` RED with 3 issues (member, not
  arrival; through undo). Counts match the round-1 record exactly. Restored → both green.
  The old backfill-seat pin's name is gone (replaced as the ritual); her-Save-keeps-backfill
  is pinned inside the new core pin (verified in the run).
- **`matches_wait` honesty:** said only when a rule LANDED (`before.querySpec !=
  after.querySpec`, non-nil after) and intake runs; the finished/archived book keeps
  `intake_paused` (the live round's leg unaffected — `IntakeDecision.intakeRuns` gates both
  occasions identically). The reworded sentence verified true in every case against the
  table: `.catchUp` never seats; `.live`/`.leftAsMember` pairs → nothing; `.dismissed` →
  nothing on catch-up.
- P-13nb-U4-16 minted in the plan with the named residual (her later applying acts under a
  join dial still seat — her act). ✓

### F-2 (MINOR — the filing's note-side ask) · VERIFIED LANDED, pin re-proven red-on-old by my own revert

- `fileInChapter` now rides `noteIntoBook` (`MCPWriteTools+Carriage.swift:199`) —
  `add_note_to_book`'s own both-sides snapshot (note decided first, then book, each refusal
  through `MCPAsking` with the ask and the asked sentence), with `spendsAfter: false` so
  `land` spends nothing and `guardBookAndNote` keeps the one in-transaction union spend (the
  self-review fix's shape, still pinned by `aOnceWingGrantFilesANoteOnceAndIsSpentOnce`,
  green in my run). `add_note_to_book` itself is untouched (`spendsAfter` defaults true).
- **Red-on-old BY MY OWN REVERT** (`git show 3f1230bc -- Sources/ | git apply -R`, pin
  kept): `filingAFencedMemberRaisesTheAskAndSaysSo` RED with 2 issues (no asked sentence, no
  ask queued) — matching the record; restored → green.
- The kept-uniform call (a non-member unshared note's silent queue) is recorded in round 1's
  disposition as deliberate. The receipt-title switch (the snapshot's `title` over a
  post-act re-read) is behavior-identical (a filing never retitles). The activity log's
  target for a filing moves from book to note — `noteIntoBook`'s own shape, uniform with
  `add_note_to_book`; no pin spoke of the old shape.

### F-3 (MINOR — the version read's lineage) · VERIFIED LANDED, pin re-proven red-on-old by my own revert

- The version branch passes the REAL standing + `versionOf: noteID`
  (`MCPReadTools.swift:138-144`) — the standing that AUTHORIZED the call (decided on the
  live note, `rung: .read`, before `isVersionHistory` validates `version_id`, before the
  once spend). `farSides` classifies `placed == liveNoteID` → `.readableNote` (the id the
  client itself supplied — no new disclosure), sibling moments via
  `isVersionHistory(_, of: family)` → `.version`, and released originals of the live note
  (`last == liveNoteID`) → `.releasedOriginal` with text — EXACTLY a live-note read's
  disclosure boundary (P-13nb-U4-5/-7). On a live read (`liveNoteID == nil`) every new
  branch is inert (verified by reading the comparisons). `books` stays suppressed on a
  version read by the explicit `liveNoteID == nil` guard — pinned.
- **Red-on-old BY MY OWN REVERT** (reverse-applied `f6445fa6` then `61abd4d6` source hunks,
  pins kept): `aVersionReadsLineageAddressesTheLiveNoteItIsAMomentOf` RED with 2 issues (no
  `note_id`; the `beyond_grant` stub on the authorizing note) — matching the record;
  restored → green.

### F-4 (MINOR — the honest show) · VERIFIED LANDED; suite re-run green by my own hands under a held stage claim

- `MCPNavigator.deliver` answers whether the delivery LANDED (`-> Bool`; the timeout, the
  refused mode request, and the `stillStanding` re-check after the wait's suspension each
  return false); `MCPDoor.agentShow` maps false → `.refuse(MCPShowRule.partialShowWords)`
  (the words say the note DID open — true: `open` adopts before it waits). HER press keeps
  always-proceed: `openShow` calls `deliver` with the default `{ true }` and
  `@discardableResult`. The concurrency shape is sound: `MCPNavigator` is `@MainActor`, so
  the `static var mountWait` test seam is actor-isolated, and `MCPNavigationTests` is
  `.serialized` with a `defer` restore — no cross-test race.
- **Re-run by my own hands:** `MCPNavigationTests` 8/8, 0 skipped, under a held stage claim
  (`u4-ladder-r2`), released after. The red-on-old mechanism is fully readable from both
  sides of the diff (the old `agentShow` returned `.navigate` unconditionally after
  `deliver`, so the pin's two `.refuse` expectations and `applied.isEmpty` fail — the
  record's 3 issues); I did not repeat the Mac-side revert run for a MINOR whose revert
  round 1 performed and the sanity pass re-verified.

### F-5 (NIT — the caps say so) · VERIFIED LANDED, pin re-proven red-on-old by my own revert

- `lenses`/`versions` return `(entries, truncated)`; the answer sets
  `lenses_truncated`/`versions_truncated` only when true. `versions` fetches `cap + 1`;
  `lenses` keeps the pre-existing fetch-all-then-prefix shape (cost ∝ the note's own lens
  count — P1-compatible, unchanged from the old code; noted below).
- **Red-on-old BY MY OWN REVERT** (combined with F-3's, above): `lensAndVersionListsSayWhenTheCapBites`
  RED with 1 issue (200 listed, no flag); restored → green.

### F-6 / F-7 (record-fixes) · VERIFIED AS RECORDED

- P-13nb-U4-7's amendment matches the code exactly: `farSides`' block query carries
  `b.deleted_at IS NULL` (a dead block collapses into the stub — lineage omits it, ancestry
  stubs it), while `parents`' variant join carries NO `deleted_at` filter (a dead take on a
  live block keeps its id — the tray's own `put_back` address), the parent classified by its
  block as any parent is. P-13nb-U4-8's both-sides clause matches the pinned behavior
  (nothing half-lands; a rule-less call lands dial+outflow).
- The architect's `013c5f41` touches only the `matchesWaitWords` constant + records; the pin
  compares the constant, so the SAYING stays pinned; the new sentence verified true in every
  case (above).

## Nothing new broken — the suites, run whole by this session

- Headless, at `22b79e41`: **core 2,580/295**, **VariorumMCPTests 65/8**, **workbook 40/6**
  — the whole-package run, all green, counts matching the round-1 finals exactly. Targeted
  baselines first: `MCPCarriageActsTests` 16/16, `MCPCarriageServerTests` 15/15,
  `MCPShowServerTests` 5/5.
- Mac: `MCPNavigationTests` 8/8 (stage claim held and released).
- Each revert window above was restored and re-greened before the next; the working tree is
  clean against `22b79e41`.

---

## ROUND 2 FINDINGS

**Zero BLOCKER, zero MAJOR, zero MINOR.** One NIT, record-only:

### R2-N1 · NIT (record-only; no pin possible — no behavioral delta) · `Sources/VariorumMCP/MCPNoteStructure.swift` (`lenses`)

F-5's fix gave `versions` the fetch-cap+1 shape but left `lenses` fetching every lens row
before prefixing (as the old code did). Behaviorally identical (same entries, same flag);
the only delta is read cost past 200 lenses on ONE note, unreachable by her own doors in
practice. Symmetry cleanup if `Queries.lenses` ever grows a limit parameter; nothing to fix
in this ladder.

**THE LADDER CLOSES at round 2** (no new BLOCKER/MAJOR — the round-3 trigger is not met).

---

## Clean bill (checked and found solid, this round's own hands)

- **F-1's closure is complete, not just local:** the override's two call sites are the
  tree's only ones; the wire cannot reach the creation-time backfill (`create_book` mints
  rule-less); every MCP-surface `reading_post` read filters `status='member'` (the eight
  sites audited one by one), so an arrival is invisible to reach, listings, counts, the
  journal fence's member leg and the Private leg alike.
- **All four default parameters preserve their old callers' meaning** (`sweepOccasion: nil`
  = her occasions; `spendsAfter: true` = add_note_to_book unchanged; `stillStanding: {true}`
  = her press; `@discardableResult` = openShow unchanged) — no default's meaning moved.
- **Every red-on-old claim in the round-1 record re-proven by my own reverts** (F-1 3+3,
  F-2 2, F-3 2, F-5 1 — issue counts matching the record exactly), each restored and
  re-greened.
- **The sanity pass's load-bearing confirmations re-verified independently:** the F-1
  override defaults nil (her Save pinned); the member-filter audit (my own grep, above);
  F-2's `spendsAfter: false` keeps `guardBookAndNote`'s atomic union spend; F-4's
  `mountWait` is main-actor isolated inside a `.serialized` suite.
- **Sync shape:** the one core-side change (an occasion parameter) alters no row write;
  no schema, no `Sync/`, no custody, marker untouched; the undo's raw restore is the
  already-ruled U2 shape.
- **P1:** no new read scales past the note; no text copied across entities; no word-level
  tracking.
- **Copy:** the two new sentences (`matchesWaitWords`, `partialShowWords`) are sentence-case,
  13s-a-sweepable, and true in every reachable case (the matches-wait truth table checked
  against `IntakeDecision.verdict` directly).
- **Records:** P-13nb-U4-7/-8/-16 amendments present and dated in the plan; R-13nb-27's
  ratification recorded verbatim; the six coordinator commits record-only as marked; ledger
  row 14 consistent.
