# RUN B — LADDER ROUND 1 (cold review; fresh Fable reviewer, 2026-09-22) — COMPLETE

**Scope:** the run's combined diff `08d9ea8f..HEAD` on `main`, excluding the other session's
artifacts (`notes/codebase-health-review-2026-09-21.md`, `notes/plans/post-13u-health-rounds.md`).
Anchor: `notes/plans/run-b-sync-correctness.md` read whole (ledger, all five batch records, all
rulings/adjudications); canon read: CLAUDE.md's load (SyncSpec whole, OverallModel, AppSpec §§6–9),
the 13j purge memo contract as the run cites it, the disagreements memo's ANSWERED blocks, the
fragments postmortem context. Every `Sources/`+`App/` hunk in the diff read line by line; the
load-bearing test constructions read; the touched suites re-run by my own hands (results in the
clean bill). **4 MAJOR · 2 MINOR · 2 NIT.** No BLOCKER: no invariant (I1–I10/P1–P3/S1–S5) is
violated on the settled inputs, and every defect below lives in a window the run itself opened or
narrowed — but F-R1 is a REGRESSION this run introduced in the §6-forbidden class, and the
arbitration may fairly argue it up.

---

## FINDINGS (severity-ranked)

### F-R1 [MAJOR] · `Sources/VariorumCore/Sync/Merge.swift:~76` (the row-15 ride-the-row overlay) · the overlay conflates "dirty ROW" with "dirty TEXT": a metadata-only-dirty variant with STALE text overwrites the peer's NEWER final edit on the tombstoned row — the only new bytes die, a regression against the pre-fix server-wins

**Mechanism (traced end to end):** the overlay fires whenever
`!cardMinted && server.isTombstoned && localText != serverText`. The outbox is a dirty-ROW set
(SyncSpec §3) — `setTakeLabel`, `archiveVariant`, `lockVariant`, a fan reorder all enqueue the
variant row with `working_text` untouched. Construction: device B labels a take (row dirty, text
= the ancestor state); device A autosaves NEW text into that take and then deletes the note (the
cascade tombstones A's variant carrying the new text); A pushes; B pulls. On B the arriving block
tombstone's local cascade stamps B's variant first (cascades active during apply; registry order
block < variant), so the variant merge is (true, true) → `rescueLosingText` returns `false` →
all overlay conditions hold → `merged.working_text` = B's STALE ancestor text, replacing the
server baseline that carried A's edit (`merged = server` — Merge.swift:34, verified). The outbox
entry survives (landed ≠ server), B pushes the stale text, A applies it clean (server-wins), both
devices converge with A's final edit GONE from every row, live or tombstoned; Put back returns the
ancestor text. §6's own ratified warrant — "deleting an edit nobody chose to lose is the one
forbidden outcome" — is violated by the fix that cites it, and the PRE-fix code handled this input
correctly (server-wins kept A's newer text).

**Why it is outside the two recorded corners (B2 record, JUDGMENT CALL 1):** corner (a) is a LIVE
server row (kept server-wins); corner (b) is BOTH sides edited (symmetric loss, either choice
loses one side). This input has exactly ONE edit — the server side's — and the local text is the
un-edited ancestor, not an intent. Riding is strictly worse than the old behavior, not a
symmetric coin flip. The overlay has no "the local text is an EDIT" discriminator because
state-based sync holds no last-acked pre-image — which means corner (b)'s "one side loses either
way" justification silently swallowed a case where only one side ever edited.

**Pin (red on HEAD, green at `08d9ea8f`):** B enqueues a variant metadata change (label) with
unchanged text; A autosaves new text then `deleteContainer`s; production rounds; assert the
converged tombstoned row's `working_text` is A's new text on both devices.

**Fix direction (a design fork — the orchestrator rules):** the honest narrowing needs a
discriminator for "local text differs from the last text the server acked," which the engine does
not store. Candidates to weigh: (i) consult the local row's own last `commit_point` (a
metadata-dirty take's text equals some committed/synced state far more often than an edit does —
imperfect); (ii) accept the corner, revert the overlay to fire only when the local row was ALSO
tombstoned by this batch's own cascade AND the server text equals the local row's pre-cascade…
(unknowable — same problem); (iii) surface to #143(a)'s ratification with this input stated, and
have her choose between the F-1 rescue and this regression explicitly. What may NOT happen: the
corner shipping silently inside #143(a)'s current wording, which describes only the two symmetric
corners. (#143(a)'s text needs this input added whatever the ruling.)

### F-R2 [MAJOR] · `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift:~345` (`recordSampleCopyKillEvidence`'s meeting predicate) · the "meeting context" counts DEAD readings, so the defense window is not the once-per-store-life meeting but the retired loser's whole tombstone lifetime — a deliberate cross-device delete of an ever-engaged sample copy is REVIVED for a month or more after any meeting, falsifying the row-15 ruling's stated premise and QUESTIONS #143(b)'s wording

**Mechanism (traced):** the meeting check is
`SELECT EXISTS (SELECT 1 FROM reading WHERE name = ? AND id <> ?)` — no `deleted_at` filter.
After a meeting resolves, the retired loser's `reading` tombstone satisfies it until the loser's
family physically purges (30-day window + horizon — a month+). Inside that whole period: she
deliberately deletes the surviving sample book on the phone (`deleteReading` — the shelf's book
delete); the tombstone arrives on the Mac by pull; the kill hook fires (first family death = the
reading itself, so the stamp check trivially matches), the kill-time classifier reads ANY
historical engagement — one manual savepoint, comment, tag, extra take, text change, a finish, a
sort change — as EDITED (the amended-ruling discriminator is the classifier, NOT unpushed edits),
and `defendEditedSampleCopies` revives the book + chapters + memberships exact-stamp, enqueued —
her deleted book reappears on the shelf of every device. Repeat deletes meet the same defense
until the loser purges. The full-delete flavor (notes + book) is also reachable whenever the ops
share a millisecond stamp or the batches split.

**Why it is a finding, not the accepted corner:** the row-15 ruling accepted #143(b) on two
stated premises — the revival "can never fire outside the once-per-store-life meeting window,"
and the evidence is UNPUSHED edits. The built predicate falsifies both: the window is the loser
tombstone's lifetime, and the classifier arm fires on any engagement ever, pushed or long-since
synced. Resurrecting deliberate deletions is the class the row-17 ruling rejected Shape C over
"emphatically." Tempered honestly: it needs an ENGAGED copy (a never-touched sample book stays
deleted — pristine, no defense), and the existing pin (`aDeliberateDeleteWithNoSecondCopyIsNeverDefended`)
covers only the no-second-copy state, so nothing pins this window.

**Pin (red on HEAD):** meeting resolves normally (loser retired, rounds settle); two rounds
later device A deliberately `deleteReading`s the kept copy after one manual savepoint on a member
take; production rounds; assert the deletion stands on both devices.

**Fix direction:** bound the meeting in time, not by row existence — e.g. the meeting stands only
while the other same-name copy's reading row is LIVE, or its tombstone is within the settle
window of the arriving kill (both-edited stays reachable: on the defending device the other copy
dies within the same few rounds); or spend a local-only "meeting resolved" one-shot marker (the
dedupe's existing marker idiom) that the kill hook consults. Whatever the shape, #143(b)'s text
must be re-worded to the shipped behavior or the behavior narrowed to #143(b)'s text.

### F-R3 [MAJOR] · `Sources/VariorumCore/Sync/Repairs.swift:~227` + `SampleLibraryDedupe.swift` (the kill-time verdict) · a retirement split across two push chunks with the A5 band between them defeats the first-death fence: the second batch's verdict reads a HALF-KILLED copy as EDITED and revives a correctly-retired PRISTINE copy

**Mechanism (traced, every leg verified in the code):** the hook's own comment names the hazard
("a verdict taken at the reading's own tombstone reads a half-killed copy — dead members = 'her
pruning' = EDITED") and fences it by classifying at the FIRST family death — but the fence is
per-batch (`TouchedRows`), and one retirement can reach the puller in TWO pulls: the retiring
device's outbox holds ≥ batchSize rows, the drain's chunk boundary lands between the member
containers and the reading row (registry order container < reading; each chunk its own server
transaction), and the puller's round lands inside the visibility band between the two commits
(`pull` fetches to head, so ONLY the band can split one retirement across applies — verified at
`SyncEngine.pullIgnoringMarker`). Batch 1: member containers die; kill evidence records verdict
PRISTINE; no defense (reading alive). Batch 2 (next round): the reading tombstone is its batch's
first family death; `copy.deletedAt == nil` still holds; the memberships are still locally live
(`reading_post` sorts after `reading`), their POSTS are dead → the classifier's own leg
(`if post["deleted_at"] != nil → .edited`, verified in `SampleCopyClassifier.classify`) answers
EDITED; the reading dies under the same retirement stamp (one `nowStamp()` for the whole
retirement, verified in `retireSampleCopy`) → the defense revives the WHOLE family (same-stamp
flips reach batch 1's victims too). A correctly-retired pristine copy returns, pushes, and the
peer re-retires it next round on a fresh stamp — visible two-Sherlock churn; a recurring split
loops it. This is precisely the cross-batch class B4's own sweep philosophy exists to catch
(F-3's window: chunk boundary × the band), applied to the defense the same run built.

**Pin (red on HEAD):** deterministic with the run's own instruments —
`pushSplitAtBoundary(retiringSide, table: "reading")` + `FakeSyncServer(visibilityHorizon:)` so
the puller's round lands between the chunks; assert the retired pristine copy STAYS retired on
both devices after the resume.

**Fix direction:** make the kill verdict durable across the split — when a batch records a kill
whose READING did not die in the same batch, persist the verdict in a local-only one-shot marker
(the dedupe's existing R2-3 idiom) keyed copy+stamp; the later batch's reading-death consumes
THAT verdict instead of re-classifying a half-killed copy. Repair-rule-scale, zero schema.

### F-R4 [MAJOR] · `Sources/VariorumCore/Sync/PurgeJanitor.swift:~713` (`healPurgeOrphan`'s completion set) · the same-stamp residue scan is STORE-WIDE, so a millisecond stamp collision hands an UNRELATED family to `executePurge` — a pre-horizon mirror purge, violating the §4f sentence probe P2(a) pinned green this same run

**Mechanism (traced):** the completion set gathers residue by
`SELECT id FROM <kind> WHERE deleted_at = ?` over container/reading/block/variant with NO family
scoping (contrast every other exact-stamp discriminator in the codebase — `restoreContainer`,
the cascade flips — which are all scoped to the root's own children). Stamps are
`yyyy-MM-dd'T'HH:mm:ss.SSS'Z'` (VariorumRecord.swift:35) — millisecond precision; two separate op
transactions can land in one millisecond (successive fast deletes on an M3; deterministic under
the injected `@Dependency(\.date)` clock). A family tombstoned in the same millisecond as the
stalled family — and the only way a same-age tombstoned family still exists un-swept is that its
OWN horizon has not crossed (the sweep already purges eligible families) — is expanded and handed
to `executePurge`: removed from the mirror and ledgered BEFORE every live device saw its
deletion. A device offline < 60 days holding unpushed edits to that family then meets the ledger
fence and drops them silently — the loss the horizon exists to prevent, and the exact guarantee
`p2aTheHorizonHoldsThePurgeWhileTheLaptopIsLive` pinned green in B1. Layered rarity, honestly
stated: P8-class stall × same-millisecond unrelated deletion; MAJOR by the run's own
class-consistency convention (a §4f/13j sentence violated in the bytes; rarity tempers
reachability, not class). Side wrinkle: `deleted_at = ?` has no index (the partial indexes are
`WHERE deleted_at IS NULL`), so the residue scan is four full-table scans — corpus-scale work on
the stall path (P1-adjacent; rare, but free to eliminate with the same fix).

**Pin (red on HEAD):** freeze the injected clock; delete two unrelated notes in one frozen
instant; age + purge family 1 cross-device with the B1 held-push construction so the heal fires;
assert family 2's rows survive on the mirror and locally.

**Fix direction:** scope the residue to the stalled row's FK-CONNECTED family — expand from the
stalled row's own referents/children through `PurgeFamily`'s joins and keep only same-stamp rows
reachable that way. The traced construction (X + VX behind N's placement) is fully covered by
connected expansion; the store-wide scan buys nothing it needs.

### F-R5 [MINOR] · `Sources/VariorumCore/Sync/PurgeJanitor.swift:672–700` (`healPurgeOrphan` guard order) · the network preflight runs before the cheap local guards, so every STALLED round of the common transient class pays an extra `schemaVersion` RPC — and every tombstoned transient pays a full purge-ledger read per round

**Traced degradation (architectural class — no pin owed):** the preflight (rekey read, keys,
`transport.schemaVersion()`) executes before `guard let stamp = stall.tombstoneStamp` and
`guard !missingReferents.isEmpty`. A LIVE-row transient straggler (the ordinary §5 class — the
scheduler calls the heal on EVERY stalled clean round until the owing device drains) costs one
extra server RPC per round for a refusal two local field reads could have made; a TOMBSTONED
transient additionally pays `purgeLedger(since: 0)` — a full-ledger read whose size grows
unboundedly until Phase 12's pruning — per round. Reorder: the two field guards first, then the
preflight, then the ledger. Two-line move; behavior identical.

### F-R6 [MINOR] · `Sources/VariorumCore/Sync/SampleLibraryDedupe.swift:~330` (`recordSampleCopyKillEvidence`'s container→copy resolution) · `LIMIT 1` with no ORDER BY and no name filter: a sample post that also lives in a SECOND book resolves to an arbitrary reading, and the defense can silently miss its kill evidence

**Traced (reachability SPECULATIVE — plan-dependent):** posts are non-exclusively pointed at by
readings, so a sample note added to a personal collection has two live memberships; the copyID
query picks one with `LIMIT 1`, unordered. If SQLite's plan returns the non-sample book, the
`copy.name == facts.bookName` filter drops the record and the F-1 defense never sees the kill —
the fixed loss resurfaces in that configuration. In practice the seeded membership's lower rowid
likely wins, which is why this is SPECULATIVE rather than a pinned defect — but correctness
should not ride a query plan. Fix: filter the JOIN to readings whose name matches a facts row (or
iterate all containing readings), and add a deterministic ORDER BY.

### F-R7 [NIT] · `Sources/VariorumCore/Sync/PurgeJanitor.swift:82/256/682` · the heal added a THIRD verbatim copy of the janitor preflight block (rekey marker + keys + lockstep) — extract a `preflight()` helper at next touch (the hoist-at-next-touch instinct; the run had the file open)

### F-R8 [NIT] · `Sources/VariorumCore/Sync/Merge.swift:~79` · the overlay re-binds `let ridden = local.columns["working_text"]` after `localText` was already bound from the same column — one binding serves both (fold into whatever F-R1's fix becomes)

---

## DISMISSED AS NOT FINDINGS (traced and cleared, recorded so round 2 need not re-chase)

- **The F-3 defer cannot wedge or over-fire:** the fingerprint (current tombstoned · local live ·
  base 0) is unreachable outside the half-landed-drain class — a restored row carries base ≥ 1, a
  repair-revived row inherits the server's version, recreations mint fresh UUIDs (S3), and a
  cursor at/past the tombstone's seq implies the local row already died (or the stall class,
  which row 12 surfaces). Traced against push/pull/rebase/`resyncReinitialize` roads.
- **The heal's `deleteLocal` without the explicit-enqueue closure is CORRECT:** the heal's write
  runs outside apply mode, so the survivor-detachment UPDATEs reach the outbox via the ordinary
  triggers (the `.purged` handler passes the closure because IT runs with triggers muted).
- **A reject-delivered sample-copy retirement missing kill evidence (pull-only hook):** the
  reading row is clean on the editing device in every F-1 shape (edits dirty variant rows), so
  the retirement arrives by pull and the hook fires; no reachable reject face found.
- **Put back racing the heal's read→RPC→write window:** no realistic revive road exists for the
  residue (the root container is already purged locally; a bare tombstoned block has no tray
  surface once its `last_container_id` target is gone).

## CLEAN BILL (checked by my own hands and found solid)

- **Row 17 (F-3 defer):** the fingerprint sits exactly where ruled, every other reject branch
  byte-unchanged (read in context, SyncEngine.swift:225–280); the unwrapped pin asserts the whole
  healed flow including the row-12 visibility counter and both-orders contract; the Journal-face
  probe exists and passes.
- **Row 7 (`repointApplicationUnderDeadDuplicateTag`):** placed before the orphan check;
  straggler-tolerant (§5); explicit enqueue (§7); catches the merged-row road too (the leg lives
  in `writeResolvedRow`, so a server-wins un-repoint is immediately re-repointed); the
  recreated-tag consequence honestly filed as #142.
- **Row 9 (the heal):** tombstone-only narrowing + exact ledger discriminator + transient guard,
  each pinned (`aLiveStalledRowIsLeftStalledAndHonestNeverHealed`,
  `aStallWhoseReferentIsNotLedgerNamedHealsNothing` — read; both green); `PullStall` is
  client-side only, no wire change; the row-19 park/heal fence held (no parking, no retry
  policy). Findings F-R4/F-R5 qualify, not overturn.
- **Row 10 (`expandContainer` live arm):** the SQL discriminator is right — live blocks under
  LIVE placements for a live root, dead-root arm byte-identical; archived blocks excluded by
  their released placement.
- **Row 11:** the one-liner matches the six sibling revive roads, reason at the site.
- **Row 12:** readers assigned on the success branch only; the `.stalled` face decorates only the
  clean branch (code order verified); `pageCaptionWarning` is pre-existing (mobile-parity D1) —
  P-8 held, no new chrome vocabulary.
- **Row 13 (descriptor reuse):** proven-by-unwrap, never UI state; floor validated at the read
  site; the recovery wrap derives fresh in both arms structurally (no descriptor reaches that
  path); the changed-word road byte-unchanged; the runner's derive moved into the branches with
  the local-only arm keeping fresh salt. The nine attacker arms re-run green.
- **Row 8:** one classifier body (`SampleCopyClassifier`), the engine's pass and the Mac guard
  both call it; the Mac guard runs it over the REAL shipped seed (both guard tests re-run green).
- **Rows 14 + 16 (harness realism):** `ProductionRound.swift` models production's order honestly
  (pull→push, chunked pushes as separate server transactions, weave + boundary split exposed);
  conversions carry per-line exemption reasons (spot-checked SyncPullTests, SyncConvergenceTests,
  MultiTenantSyncTests); the tenth arm is complete (fence-first → proof-refused → mirror unmoved
  → non-vacuity control → the DDL text pin).
- **Suites, re-run by me (this session):** the probe/repair/dedupe/purge/scheduler/rotation/
  furniture/sweep filters — **126 tests / 12 suites PASSED**; the remaining converted suites
  (convergence, pull, push, fault, editor-rate, structural, mobile-capture, multi-tenant +
  attacker, merge) — **78 tests / 11 suites PASSED**; Mac `SyncStalledRowTests` +
  `SampleLibraryTests` — **18/2 PASSED**; Mac `PostureSwitchTests` — **44/44 PASSED** (zero
  instances running, pgrep-checked first). Zero known issues anywhere — the zero-wraps claim
  verified.
- **Records:** QUESTIONS #141/#142/#143 filed as the ledger states (with #141's ruling verbatim
  and 17s minted); the memo's ANSWERED blocks under P1/P2 (and siblings) in place with pin names;
  the 13y plan's stale-marker correction + her kickoff ruling recorded; the deploy-checklist
  caveat landed.
- **Fences:** zero `Server/` lines, zero `Persistence/`/schema lines, `lockstepVersion` still 8;
  the only `App/` touches are rows 12/13's sanctioned files; `Operations+UndoInverses` is row
  11's sanctioned one-liner.

## SUMMARY

The run's core work — the hunt, the P8 heal, the tag arrival-order leg, the F-3 defer, the
descriptor reuse, and the harness conversion — is careful, honestly recorded, and holds up under
independent re-tracing; every headline test claim I checked reproduced. The four MAJORs share one
shape: each is a WINDOW the new repair machinery itself opens (a stale-text overlay input nobody
classified, a meeting predicate wider than its ruling, a batch-scoped fence against a cross-batch
delivery, an unscoped stamp join) — the same cross-batch/e­vidence-scope discipline the run
enforced on the shipped code, applied one level up to the run's own fixes. All four are
repair-rule-scale to fix and deterministically pinnable with the run's own instruments.
