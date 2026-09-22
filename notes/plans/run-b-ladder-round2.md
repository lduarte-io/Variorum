# RUN B — LADDER ROUND 2 (cold review; fresh Fable reviewer, 2026-09-22) — COMPLETE

**Scope:** a REAL pass over round 1's fixes and what they touched — the fix range
`6d0a029c..cd251b15` (four `Sync/` sources + one test file, verified by `git diff --stat`) inside
the run's combined diff `08d9ea8f..HEAD`, excluding the other session's artifacts. **Anchor:**
`notes/plans/run-b-ladder-round1.md` (F-R1…F-R8) + the run record's LADDER ROUND 1 FIX-SESSION
RESPONSES + the R1 ADJUDICATION, all read whole; the run record read whole (all five batch
records, all rulings); canon: CLAUDE.md's load (SyncSpec whole, OverallModel, AppSpec §§6–9), the
13j purge memo contract as cited. Code read line by line, whole files: `Merge.swift`,
`SampleLibraryDedupe.swift`, `PurgeJanitor.swift`, `SyncEngine.swift`, plus `Repairs.swift`,
`SyncScheduler.swift`, the `PurgeFamily.swift` diff, the row-11 diff, and the five new pins in
`SyncReconciliationProbeTests.swift`. Suites re-run by my own hands; TWO of the four MAJOR
red-on-old claims independently re-proven in a scratch clone (results below).

**VERDICT: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT — no round 3 owed by the ladder's rule.**

---

## FINDINGS (severity-ranked)

### F-R2-1 [MINOR] · `notes/QUESTIONS.md` #143(a) (corner 2's wording) + `Sources/VariorumCore/Sync/Merge.swift:93–97` (the recorded-corners comment) · the "coincidental metadata equality" corner's stated on-ramp understates its reachability: a NET-ZERO metadata round-trip on ONE device (and, latently, `resyncReinitialize`'s no-divergence re-enqueues) produces the same byte-equality with no coincidence at all — her PROVISIONAL ratification of the narrowed ride would be made on an understated premise

**Mechanism (traced end to end; the records class — no pin owed, but the loss shape is
red-on-current by construction):** `textIsTheOnlyDivergence` is the honest floor of what
state-based rows can answer — but the recorded corner 2 ("both devices independently set
byte-identical metadata, one with stale text… vanishingly narrow") and #143(a)'s amended text
("coincidentally byte-identical metadata on both sides still rides") name only the
two-device-coincidence road to that equality. A cheaper road exists on one device: B sets a take's
label and clears it again (`setTakeLabel(t1, "x")` then `setTakeLabel(t1, nil)` — both real
writes; x→nil is not the no-op class) with no round between; the outbox coalesces to one dirty
row whose every intent column now EQUALS the server's. A then autosaves the only new text and
deletes the note; B pulls: the variant merge is the F-R1 shape exactly — server tombstoned,
texts differ, and the discriminator reads text as the SOLE divergence (label nil == nil) — so
B's stale ancestor text rides over A's final edit, pushes, and converges: the F-R1 loss through
the corner's own door, needing only a metadata toggle-and-revert instead of a two-device
coincidence. Latent sibling, same mechanism: after `resyncReinitialize`
(`reonboardFromAccount` step 2 — production-unreachable until ledger pruning advances the floor,
per the code's own comment) EVERY row sits enqueued with zero divergence at
`sync_version 0`, so a peer's edit-then-delete arriving on the returner meets the same
text-sole-divergence read.

**Why MINOR and not MAJOR (stated so the fix session need not re-derive it):** the disposition
itself is NOT falsified — recording the corner instead of fixing it was ruled correctly, because
no better client-side discriminator exists inside the fence (state-based rows hold no last-acked
pre-image; a durable text-intent record is schema, correctly refused). What is inaccurate is the
corner's REACHABILITY premise in the two records her ratification will read. This is the same
records-accuracy class round 1's F-R2 raised at MAJOR — but there the ruling's falsified premise
guarded a BEHAVIOR that could be (and was) narrowed; here no in-fence narrowing exists, so the
finding's whole remedy is honest wording. Demanding a code fix would be the hollow-fix trap.

**Fix:** amend #143(a)'s corner sentence (and the Merge.swift recorded-corners comment) to name
the real on-ramps: "byte-identical metadata — whether minted coincidentally on both sides,
restored by a net-zero toggle on one, or re-enqueued without divergence by
`resyncReinitialize` — still rides." Optionally note the toggle window as the concrete example.
No code change owed.

### F-R2-2 [NIT] · `Sources/VariorumCore/Sync/PurgeJanitor.swift:682,693` · `healPurgeOrphan`'s inline step labels contradict its own doc comment after the F-R5 hoist: the code runs narrowing (labelled "2.") before preflight (labelled "1."), while the doc list numbers narrowing 1 and preflight 2

The F-R5 reorder moved the field guards above the preflight and renumbered the doc list, but the
inline markers kept their pre-hoist identities — a reader tracing "step 1" lands on the second
thing that runs. Fix: renumber the two inline labels to match the doc list (narrowing 1,
preflight 2).

### F-R2-3 [NIT] · `notes/plans/run-b-sync-correctness.md` (ROWS 9+15 RULINGS, the ROW 9 paragraph) · the ruling's sentence "owner-12's future ledger pruning keeps the below-floor-means-purged semantics the discriminator already handles" describes semantics the shipped code deliberately does NOT have — the heal REFUSES on any un-named referent, below-floor included

The B2 fix section states the shipped behavior correctly ("the below-floor case refuses too —
recorded for the ledger-pruning rider"), and the code comment at the discriminator says the same
("a pruned entry cannot be checked by id — the heal refuses there too; the ledger-pruning rider
owes the below-floor refinement"). Only the ruling paragraph carries the proposal's original
below-floor-means-purged wording. Unreachable today (floor 0 until Phase 12's pruning) and the
code errs safe — but a future pruning phase building to the RULING's sentence would expect a
heal that fires where the code refuses. Fix: one bracketed correction in the ruling paragraph
pointing at the B2 fix section's sentence as the shipped semantics.

---

## THE TWO RECORDED WATCH ITEMS (checked at mechanism depth, as the anchor directs)

- **F-R3's inert-lingering marker corner — VERIFIED INERT.** A kill recorded at a lone
  member-note deletion (meeting context standing, reading never dies) persists
  `sample_kill_verdict:<copy>:<stamp>` and is never consumed. Traced: a stale marker can never
  be WRONGLY consumed — `consumeKillVerdict` looks up the exact (copy, stamp) key, so a marker
  under an old stamp returns nil (the batch's own verdict stands) and is merely CLEARED by the
  `LIKE 'sample_kill_verdict:<copy>:%'` sweep whenever any later kill of the same copy consumes.
  Accumulation is bounded by meeting-context kill events, which F-R2's bound made genuinely
  narrow; rows are local-only `sync_state`. The F-R3 pin additionally asserts zero leaked
  markers after its split (`SELECT COUNT(*) … LIKE 'sample_kill_verdict:%'` == 0 — read and
  re-run green). No action owed.
- **The split-gap-edit corner — VERIFIED AS RECORDED (one band wider than the one-batch
  design's own).** An edit landing in the ~2 s gap between a split retirement's two applies is
  invisible to the persisted batch-1 verdict; the copy stays retired on the earlier PRISTINE
  read. Traced: the same blindness exists in the unsplit design for an edit landing after the
  retiring device's classification and before the tombstones arrive; Part 1's text-sole-
  divergence ride still keeps the BYTES on the tombstoned row where the edit was a text edit.
  Recorded, not owed.

## RE-VERIFICATION OF ROUND 1'S DISPOSITIONS (one line each, my own hands)

- **F-R1 (AGREED-FIXED-with-pin) — HOLDS.** `textIsTheOnlyDivergence` read in full (volatile
  set: working_text/deleted_at/updated_at; `sync_version` outside `columns` verified at
  `SyncRow.init`); the pin's teeth read (the two text asserts × both devices × args = 8); the
  red-on-old claim INDEPENDENTLY RE-PROVEN in a scratch clone — discriminator forced `true` →
  the pin red with EXACTLY 8 issues at :234/:249, matching the recorded revert evidence;
  restored → green. The ruled text-dirty rides (p1PhoneFirst, both p5b matrix rows) re-run
  green beside it.
- **F-R2 (AGREED-FIXED-with-pin) — HOLDS.** The three arms read (live · own-unpushed-retirement
  · 1 h settle window; unparseable-outside verified in code); the month-later construction's
  arms all fail as designed; the red-on-old claim INDEPENDENTLY RE-PROVEN in the clone —
  HEAD's bare-EXISTS predicate restored → the pin red with EXACTLY 4 issues (the delete undone
  on both devices), matching the record; the crossing arms re-traced (delayed-push → arm 2;
  pushed-and-racing → arm 3; one-batch third-device meeting → arm 1) and the defense pins re-run
  green. The #143(b) amendment verified in QUESTIONS (bounded meeting, falsified premise
  corrected, the 1 h width stated as the orchestrator's arbitrated call).
- **F-R3 (AGREED-FIXED-with-pin) — HOLDS.** `persistKillVerdict` (INSERT OR IGNORE — first/
  wholest verdict) + `consumeKillVerdict` (exact-key read, copy-wide clear) + the defense's
  persist-else-consume seam read in full; multi-chunk splits traced safe (every intermediate
  batch's half-killed verdict is IGNOREd behind batch 1's whole-copy one); rollback safety by
  in-apply write; the pin's construction read (pushSplitAtBoundary at `reading`, B's round
  between the halves) and re-run green, including the no-leak assert.
- **F-R4 (AGREED-FIXED-with-pin) — HOLDS.** `PullStall.presentReferents` (prefix-arriving +
  locally-present FK targets, named at the stall's birth) and the heal's completion set
  (present referents tombstoned at the stall's EXACT stamp → `PurgeFamily.expand`) read in
  full; the traced X+VX shape covered whether the residue arrived in the stalled batch's prefix
  or an earlier round; the bystander is unreachable by construction (not an FK target); the
  store-wide `deleted_at = ?` sweep confirmed deleted; the defaulted init parameter's one real
  construction site verified (`pullIgnoringMarker` passes `present`); the pin's bystander
  teeth read (mirror + ledger-silence + local Trash row) and re-run green with both p8 heal
  pins and both guard pins.
- **F-R5 (AGREED-FIXED, architectural) — HOLDS.** The two field guards sit above the preflight
  (:690–691 vs :694); the degenerate throw-vs-false difference is stated at the site and
  production-unreachable as argued. (The stale inline step numbers are F-R2-2 above.)
- **F-R6 (defect half DISMISSED-AS-HOLLOW at its own pin; cleanliness half LANDED) — HOLDS.**
  The dismissal's structural temper re-traced: a full retirement's `reading` row resolves
  `copyID = row.rowID` directly, so kill evidence is never wholly missed in any one-batch
  retirement, and the split configuration's exposure is exactly what F-R3's persisted verdict
  needs the name-filtered resolution for — the load-bearing justification is real. The fixed
  resolution read (facts-name filter + `ORDER BY r.id LIMIT 1`); the two-book pin re-run green.
- **F-R7 (AGREED-FIXED) — HOLDS.** ONE `preflight()` body; exactly three call sites (:111,
  :270, :694); refusal order rekey → keys → lockstep, byte-identical to the engine's.
- **F-R8 (AGREED-FIXED inside F-R1) — HOLDS.** One `localText` binding feeds the overlay.

## NEW-DEFECT HUNT OVER THE FIXES' FILES (traced and cleared — recorded so round 3, if any, need not re-chase)

- **The discriminator's column universe is symmetric:** both rows come from `SELECT *` fetches
  (or the wire's full-row payloads), so the union-minus-volatile key set cannot spuriously
  differ by representation; `sync_version` never enters `columns` (`SyncRow.init`).
- **The ride cannot fire in the (true,false) local-tombstone shape** (`server.isTombstoned`
  guard) and the (false,false)/(false,true) live-server shapes keep shipped behavior — read in
  place.
- **F-R2's arm 2 cannot be tripped by in-batch bookkeeping:** the kill hook runs at row-apply
  time, before any post-batch pass; no write-time repair enqueues a `reading` row; the other
  copy's reading is never in the killing batch. Self-retirements record nothing (direct
  writes bypass `writeResolvedRow`), and echoes fail the `copy.deletedAt == nil` guard.
- **The defense's revival cannot violate a live-unique index:** flips touch only rows still
  dead at the retirement's exact stamp, inside the same apply that killed them (or, in the
  split, rows a Put back has not already revived — an interleaved Put back makes the flip a
  no-op and the reading-stamp guard reads NULL ≠ stamp, persisting instead).
- **The heal cannot over-reach through edges:** `expandBlock` takes edge ROWS touching the
  block, never the far endpoint's family — scoped correctly.
- **The F-3 defer's fingerprint survives the new roads:** post-`resyncReinitialize` pushes meet
  it only where the pull genuinely has not delivered the death yet (defer-until-feed, bounded
  by pull progress; the P8 jam that could starve it is now healed).
- **`consumeKillVerdict`'s LIKE pattern is metacharacter-safe for UUID row ids**, and a
  hostile id could only over-CLEAR markers (the no-defense direction — self-limiting).

## CLEAN BILL (load-bearing things checked and found solid)

- **The fix range is exactly as recorded:** `git diff --stat 6d0a029c..cd251b15` = the four
  `Sync/` sources + `SyncReconciliationProbeTests.swift` (+ records); zero `Server/`, zero
  `Persistence/`/schema lines in the whole run diff; `SyncSchema.lockstepVersion` still 8;
  working tree clean at `507c6bcd`.
- **Zero wraps:** the three `withKnownIssue` occurrences in core tests are doc-comment
  references only — the zero-known-issues claim is structural, not incidental.
- **Scheduler wiring (rows 12 + 9):** honesty flags assigned on the success branch only; the
  heal is the stall detail's ONE consumer, fires after the sweep, triggers exactly one
  follow-up on success, and a heal fault never un-succeeds the round — read in place.
- **QUESTIONS #141/#142/#143 verified present**; #143 amended to shipped behavior on both
  edges exactly as the adjudication claims (read in full).
- **Suites, re-run by me this session:** SyncReconciliationProbeTests + SyncRepairTests +
  SampleLibraryDedupeRepairTests — **46 tests / 4 suites PASSED**; PurgeOpsTests +
  PurgeConvergenceTests + SyncSchedulerTests + CorpusRotationTests +
  FurnitureConvergenceRepairTests + MultiTenantSyncAttackerTests — **81 tests / 8 suites
  PASSED** (the nine attacker arms + arm 9 + the tenth standing).
- **Independent revert evidence (scratch clone, the repo untouched):** F-R1's discriminator
  disabled → its pin red with exactly the recorded 8 issues; F-R2's bare-EXISTS predicate
  restored → its pin red with exactly the recorded 4 issues. Both restored green. The
  remaining two MAJORs' revert claims are consistent in mechanism and issue-shape with these
  two and were accepted on the record + code reading.
- **Full core suite (run at the review's END, per the traps):** verified — the finals line
  below.

## FINALS

Full core suite, run by me at the review's end: **1679 tests / 179 suites — ALL PASSED, zero
known issues** + the ONE sanctioned real-server integration skip (its skip message read and
verified as the sanctioned gate). Exactly the recorded R1 finals — the headline claim verified,
the zero-wraps close standing. **ROUND 2 CLOSES: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT — by the
ladder's rule (round 3 only on a NEW BLOCKER/MAJOR), no round 3 is owed.** The MINOR is a
records-accuracy amendment (#143(a)'s corner wording + the Merge.swift comment); the NITs are a
two-label renumber and a one-sentence ruling-paragraph correction — none requires a pin, all
three carry written justifications above.
