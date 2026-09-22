# RUN B — LADDER ROUND 1 (cold review; fresh Fable reviewer, 2026-09-22)

**Scope:** the run's combined diff `08d9ea8f..HEAD` on `main`, excluding the other session's
artifacts (`notes/codebase-health-review-2026-09-21.md`, `notes/plans/post-13u-health-rounds.md`).
Review anchor: `notes/plans/run-b-sync-correctness.md` (read whole); canon: CLAUDE.md + AppSpec +
OverallModel + SyncSpec (whole) + the 13j purge memo §4f + the disagreements memo.

**STATUS: IN PROGRESS — findings land here incrementally as traced; nothing below is final until
the SUMMARY section closes the file.**

---

## FINDINGS (severity-ranked; format: severity · location · what · evidence · fix)

### F-R1 [MAJOR] · Sources/VariorumCore/Sync/Merge.swift:~76 (the ride-the-row overlay) · the overlay conflates "dirty ROW" with "dirty TEXT" — a metadata-only-dirty variant with STALE text overwrites the peer's NEWER final edit on the tombstoned row, losing the only new bytes

**Mechanism (traced):** the overlay fires whenever `!cardMinted && server.isTombstoned &&
localText != serverText`. The outbox is a dirty-ROW set (SyncSpec §3), so a variant row is dirty
for non-text reasons too — `setTakeLabel`, `archiveVariant`, `lockVariant`, a fan reorder all
enqueue the row with `working_text` untouched. Construction: device B labels a take (row dirty,
text = old ancestor state); device A edits that take's text and then deletes the note (the cascade
tombstones A's variant carrying the NEW text); A pushes; B pulls. On B the arriving block
tombstone's local cascade stamps B's variant first (registry order), so the variant merge is
(true, true) → `rescueLosingText` returns false → the overlay's conditions all hold (server
tombstoned; OLD ≠ NEW) → `merged.working_text` = B's STALE text. B pushes it (outbox survived);
A applies it clean (server-wins). Both devices converge with A's final edit REPLACED by the
ancestor text on the tombstoned row; Put back returns the OLD text. §6's own warrant — "deleting
an edit nobody chose to lose is the one forbidden outcome" — is violated by the fix that cites
it: the pre-fix code kept A's newer text here (server-wins was CORRECT for this input).

**Why this is outside the two recorded corners:** JUDGMENT CALL 1's recorded corners are (a) a
LIVE server row (kept server-wins) and (b) BOTH sides edited (symmetric loss). This input has
exactly ONE edit — the server side's — and the local text is the un-edited ancestor, not an
intent; riding is strictly worse than the old behavior, not a symmetric-loss coin flip. The
overlay has no discriminator for "the local text is an EDIT" because state-based sync holds no
last-acked text pre-image — which means the (b) corner's "one side loses either way" justification
silently swallowed a case where one side loses and the other never edited.

**Pin (red on current code):** B enqueues a variant metadata change (label) with unchanged text;
A autosaves new text then `deleteContainer`s; production rounds; assert the converged tombstoned
row's `working_text` is A's NEW text (green pre-run at `08d9ea8f`, red on HEAD).

**Proposed fix:** narrow the overlay to inputs where the local text can actually be an unpushed
edit the server never saw — the honest available discriminator is the server's OWN text history:
none exists client-side, so the narrowing has to come from the fingerprint (e.g. overlay only when
`local.syncVersion == server-side pre-tombstone version` is unknowable — see the record) — at
minimum, the corner must go to the orchestrator/#143(a)'s neighborhood as a falsified-premise
recheck rather than ship silently. (Candidate mechanical narrowing: ride only when the LOCAL row
was tombstoned by this batch's own cascade — i.e. `local.isTombstoned == true` — AND the local
row's pre-merge `updated_at` postdates the server row's; wall-clock-flavored, so this is a design
fork, not a one-liner. The finding is the unconsidered input, not the choice of narrowing.)

### F-R2 [MAJOR] · Sources/VariorumCore/Sync/SampleLibraryDedupe.swift:~334 (`recordSampleCopyKillEvidence`'s meeting predicate) · the "meeting context" includes DEAD readings, so the defense window is not the once-per-store-life meeting but the loser-tombstone's whole lifetime — a deliberate cross-device delete of an ever-engaged sample copy is revived for a month+ after any meeting

**Mechanism (traced):** the meeting check is
`SELECT EXISTS (SELECT 1 FROM reading WHERE name = ? AND id <> ?)` — no `deleted_at` filter.
After any two-copy meeting resolves, the retired loser's `reading` tombstone satisfies this
predicate until the loser's family is physically purged (30-day window + horizon — a month or
more). Within that whole period: she deletes the surviving sample book deliberately on the phone;
the tombstones arrive on the Mac; the kill hook fires (meeting = the DEAD loser row), the
kill-time classifier reads ANY historical engagement (a manual savepoint, comment, tag, take —
not unpushed edits) as EDITED, the reading dies under the recorded stamp → `defendEditedSampleCopies`
REVIVES her deliberately deleted book, pushes the revival, and the phone's copy comes back. Every
repeat delete meets the same defense until the loser purges.

**Why this is a finding and not the accepted corner:** the row-15 ruling accepted #143(b) on the
stated premise that the revival "can never fire outside the once-per-store-life meeting window"
and keys on UNPUSHED edits. The built predicate falsifies both halves: the window is the loser
tombstone's lifetime, and the amended (classifier) discriminator fires on any engagement ever,
pushed or not. Resurrecting deliberate deletions is the exact class the row-17 ruling rejected
Shape C over, "sustained emphatically." QUESTIONS #143(b)'s wording also no longer matches the
shipped behavior.

**Pin (red on current code):** meeting resolves normally (loser retired, settles); TWO rounds
later device A deliberately deletes the kept (engaged — one manual savepoint) copy; production
rounds; assert the deletion stands on both devices. Red on HEAD (the copy revives), green at
`08d9ea8f`.

**Proposed fix:** bound the meeting context in time rather than by row existence — e.g. the
meeting stands only while the OTHER same-name copy's reading row is live, OR its tombstone is
younger than the arriving kill stamp by less than the settle window; or record a local-only
"meeting resolved" marker the defense consults. Both-edited defense must stay reachable (the
other copy is locally dead on the defending device in that cell) — so the predicate needs the
tombstone-age bound, not a liveness bound. Design fork for the orchestrator; the falsified
premise is the finding.

### F-R3 [MAJOR] · Sources/VariorumCore/Sync/SampleLibraryDedupe.swift (the kill-time verdict) + Repairs.swift:~227 · a retirement split across two push chunks (the A5 band between them) defeats the first-death fence: batch 2's verdict reads a HALF-KILLED copy as EDITED and revives a correctly-retired PRISTINE copy

**Mechanism (traced):** the hook's own comment names the hazard ("a verdict taken at the
reading's own tombstone reads a half-killed copy — dead members = 'her pruning' = EDITED") and
fences it by firing at the FIRST family death — but the fence is per-batch (`TouchedRows`), and
the retirement's rows can reach the puller in TWO batches: the retiring device's outbox holds
≥ batchSize rows, so the drain's 200-row chunk boundary lands between the member-container
tombstones and the reading tombstone (registry order: container before reading; each chunk its
own server transaction), and the pulling device's round lands inside the A5 visibility band
between the two commits (`pull` fetches to head, so only the band can split one retirement across
its one-transaction applies). Batch 1: member containers die; kill evidence records verdict
PRISTINE; no defense (reading alive). Batch 2 (next round): the reading tombstone arrives as the
first family death of ITS batch; `copy.deletedAt == nil` still holds; the classifier now reads
the half-killed copy (pruned-with-tombstone-evidence) as EDITED; the reading dies under the same
retirement stamp → the defense revives the WHOLE family (same-stamp flips include batch 1's
victims) → a correctly-retired pristine copy comes back, pushes, and the other device re-retires
next round (fresh stamp) — visible churn, and a repeat split loops it. This is exactly the
cross-batch class B4's sweep exists to catch (F-3's own window: chunk boundary × the band),
applied to the defense the same run built.

**Pin (red on current code):** deterministic with the existing instruments —
`pushSplitAtBoundary(retiringDevice, table: "reading")` (or pad the outbox past batchSize) +
`FakeSyncServer(visibilityHorizon:)` so the puller's round lands between the chunks; assert the
retired copy STAYS retired on both devices after the resume. Red on HEAD.

**Proposed fix:** make the kill evidence durable across batches for an in-flight retirement —
e.g. when a batch records a kill whose reading did NOT die in the same batch, persist the verdict
in a local-only one-shot marker (the dedupe's existing deferral idiom, R2-3) keyed by copy +
stamp, and let the next batch's reading-death consume THAT verdict instead of re-classifying a
half-killed copy. Repair-rule-scale; zero schema (the marker table pattern already exists).

### F-R4 [MAJOR] · Sources/VariorumCore/Sync/PurgeJanitor.swift:~713 (`healPurgeOrphan`'s completion set) · the same-stamp residue scan is STORE-WIDE, so a millisecond stamp collision sweeps an UNRELATED family into `executePurge` — a pre-horizon mirror purge, violating 13j §4f's own guarantee (the sentence probe P2(a) just pinned green)

**Mechanism (traced):** the completion set gathers residue by
`SELECT id FROM <kind> WHERE deleted_at = ?` over container/reading/block/variant for the WHOLE
store — no family scoping (contrast `restoreContainer`'s exact-stamp discriminator, which is
always scoped to the container's own children). Stamps are `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`
(VariorumRecord.swift:35) — millisecond precision; two separate op transactions on an M3 can land
in the same millisecond (successive fast deletes), and under the injected `@Dependency(\.date)`
clock the collision is deterministic. A family deleted in the same millisecond as the stalled
family — but whose OWN deletion has NOT crossed the horizon (that is the only way a same-age
tombstoned family still exists un-purged, since the sweep purges eligible families) — is expanded
and handed to `executePurge`: removed from the mirror and ledgered BEFORE every live device saw
its deletion. A device offline < 60 days holding unpushed edits to that family then meets the
ledger fence and drops them — the exact loss the horizon exists to prevent, and the exact
guarantee probe P2(a) pinned green this run ("the horizon HOLDS the purge while the laptop is a
live device").

**Reachability, honestly:** needs a P8-class stall (rare) × a same-millisecond unrelated deletion
(rare; realistic generators are fast successive deletes sharing a wall-clock ms). MAJOR by the
run's own class-consistency convention (a §4f sentence violated in the bytes; rarity tempers
reachability, not class); the fix is cheap.

**Pin (red on current code):** freeze the injected clock; delete two unrelated notes in one
frozen instant on device A; age + purge family 1 with the P8 held-push construction so the heal
fires; assert family 2's rows survive on the mirror and locally. Red on HEAD (family 2 is
swept into the completion set), green at `08d9ea8f` (no heal existed).

**Proposed fix:** scope the residue to the stalled row's FK-CONNECTED family — expand from the
stalled row and take same-stamp rows reachable through `PurgeFamily`'s own joins (the placement
names its block and container; the block its variants), never a store-wide stamp match. The
traced construction (X + VX behind N's placement) is fully covered by connected expansion.

---

## OPEN THREADS (being verified; not yet findings)

- Test-side verification of the headline suite claims (targeted re-runs).
- ProductionRound.swift shape · the probe suite's constructions · the row-9/12/13 pins.
- QUESTIONS #141–#143 filings; the memo's ANSWERED blocks; 17-file entries.
- The heal's per-round full-ledger read on a TRANSIENT straggler stall (cost observation).
- `SyncStatusViews` stalled-face precedence pins; `pageCaptionWarning` provenance (pre-existing
  — verified, mobile-parity D1; P-8 held).

## CLEAN BILL (accumulating)

- (pending — lands with the summary)
