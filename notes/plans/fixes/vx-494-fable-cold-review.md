# VX-494 — post-merge cold review (fable-reviewer, REVIEW_PROMPT verbatim)

**Reviewer:** Fable 5 (xhigh), 2026-10-23, zero implementation context, on `main` at `198f5c0d1` (post-merge).
Diff under review: `git diff 44226636b^1 44226636b` (PR #185, 21 files). Anchors read whole, myself: the record
`notes/plans/fixes/vx-494-catchup-hang.md`, the three ladder rounds, the handoff, SyncSpec IN FULL, the purge memo
§2/§4, AppSpec §7/§9/§11, OverallModel S1–S5, and every product and test file the diff touches. Headless runs on this
checkout: `swift test --filter ResumableCatchUpTests` → **18/18 green (8.7 s)**; the sync sweep filter → **344 tests /
80 suites green (48.0 s)** — both exactly the record's counts. Written incrementally; FINAL.

## SCOPE NOTE — FIRST

The diff is squarely in Fable's mandatory scope (`Sources/VariorumCore/Sync/` + a schema migration). The ladder ran
as three `opus-reviewer` rounds under the author's recorded waiver (R-494-1, R-494-3 — her words verbatim in the
record). This review is the post-merge Fable pass over the whole merged diff; it does not relitigate the waiver.

## TALLY

**0 BLOCKER · 0 MAJOR · 2 MINOR · 3 NIT.** The fix's three mechanisms (D1 window size, D2 stage + identity + belts,
D3 cancel with the shielded save) are sound as built; I re-traced each mechanism myself and independently re-proved
the final round's fix (R3-1, the shield) by revert on a scratch copy — details in the clean bill.

## FINDINGS (severity-ranked)

### FB-1 [MINOR, doc-class — no pin possible] · `Sync/SyncSchema.swift:505` (`SyncValue`), `:816` (`SyncRow`) + `Sync/SyncTransport.swift:7` (`SyncPulledRow`) · the three Codable types are now a PERSISTED on-disk format, and nothing at their declarations says so

**What's wrong.** `sync_pull_stage.payload` persists `SyncPulledRow`'s (and so `SyncRow`'s and `SyncValue`'s)
synthesized Codable JSON across app restarts and app UPDATES. The designed fence is `PullStage.format`
(`PullStage.swift:50–54`): "Bump it whenever that encoding or its meaning to the apply changes." But the bump trigger
is documented ONLY in `PullStage.swift`. The three types themselves — in two other files — carry no sentence saying
their shape is a persisted format. Ladder R1's F1 named exactly this ("Nothing on those types says they are now a
persisted format"); the fix added the constant without the pointer at the change site.

**Traced degradation (the justification; a process hazard, so no red-on-old pin is constructible).** A future session
reshapes one of these types — e.g. changes `SyncValue`'s decode order or a coding key — in a way that still DECODES
old JSON but means something different to the apply. It has no reason to open `PullStage.swift`, so `format` stays 1.
A stage left by the previous build then resumes and the apply writes rows with drifted meaning. The F1 (2) fallback
(undecodable ⇒ one re-download) heals only the decode-FAILURE half; the decodes-but-means-otherwise half is exactly
what `format` exists for, and its trigger is invisible from the place the change is made. VM-8 raises the odds: the
phone's catch-up will be interrupted far more often, so a stage existing across an update is the common case there.

**Fix (one line per type).** A doc sentence on each of the three declarations: "Persisted on disk by the pull stage
(`sync_pull_stage.payload`, VX-494) — any change to this type's Codable shape or meaning must bump
`PullStage.format`." No code change, no pin claimed.

### FB-2 [MINOR, record-class] · `notes/handoffs/vx-494-handoff.md:118, :129, :155` · the FINALIZED handoff still carries three unfilled PENDING placeholders — one of them inside the paste-ready Air prompt's own safety check

**Evidence (current main; `grep -n PENDING` finds exactly these three).**
- `:1–2` says "FINALIZED ~09:25 MDT — VX-494 merged and installed; **nothing below is pending**".
- `:118` — "**The dev slot:** PENDING(restored whole — …)" — the template placeholder never flipped, directly under
  the night's-result bullet (`:115`) that already states the restore happened at 06:03.
- `:129` — APPENDIX A, the paste-ready Air install prompt, instructs: "verify the tip CONTAINS BOTH the VX-488 merge
  (e63602bac) and the **VX-494 merge (PENDING-SHA)** — `git merge-base --is-ancestor <sha> HEAD` for each; refuse to
  build from anything older." The SHA was never substituted (it is `44226636b`).
- `:155` — APPENDIX B names "the VX-494 first-catch-up fix **PR #<PENDING>**" (it is PR #185).

**Mechanism.** Her checklist step 3 is to paste APPENDIX A verbatim into a fresh Claude session on the Air. That
session's ONE guard against installing a build without the fix is the two-ancestor check — and the second ancestor is
a literal "PENDING-SHA". The session either skips the check it was told to refuse on, or stalls to ask; either way the
prompt's safety mechanism is broken as shipped. The dev-slot PENDING line additionally reads as unverified work under
SessionResiliencyProtocol's "trust PENDING as unverified" rule, in a file whose header claims nothing is pending.

**Fix (doc only).** Substitute `44226636b` at :129 and `PR #185` at :155; replace :118's PENDING(...) with the done
sentence (or delete the line — :115 already carries the fact).

### FB-3 [NIT] · `notes/plans/fixes/vx-494-catchup-hang.md:3–6` · the CLOSED status header still reads in the future tense

"STATUS: CLOSED … **the closing Mac + phone runs next, then the closeout, the PR merge and the Pro install**" — all
of those are DONE per rows 6–7 of the same table. A fresh session reading the header's first sentence gets a stale
plan before the table corrects it. One clause to rewrite.

### FB-4 [NIT] · `Sync/SyncEngine.swift:57–63` (the `pullWindowSize` doc) · two measurements from two different servers sit in one sentence as if like-for-like

"at 200 rows her ~108k-row first catch-up took ~550 calls (11 min 36 s)" is HER production server; "at 2,000 … 56
windows (~70 s)" is the THROWAWAY project (lighter per-call cost — the record's D1 check measured her server at
~1.5–3 s/call at since=0, so her 56 windows are ~1–2 min, not ~70 s). The substance (calls are the lever; each call
inside the 8 s timeout) is correct and cited. One qualifying clause ("on the throwaway; her server's per-call cost is
higher") would stop the doc reading as a measured 10× on her corpus.

### FB-5 [NIT] · `notes/MobileSoul.md:261` · PL-57 is inserted between PL-55 and PL-56

The ledger's rows already sit in imperfect order (PL-54, PL-55, PL-57, PL-56, PL-53 …), so this only continues a
pre-existing drift; noted for the next ledger touch, not worth its own commit.

## CLEAN BILL (specifically checked, found solid — my own traces, not the ladder's word)

- **R3-1's shield, independently re-proved.** The final round's fix had no fresh-reviewer re-check (round 3 is the
  cap; the orchestrator checked it line by line), so I re-proved it myself: on a scratch copy of the package
  (`Sources/` verified byte-identical to main by `diff -rq`, never this repo), RV-R3a re-run — the shield's body
  reverted to a bare `applyingRemoteWithDeferredFKs(body)` → `✘ Test run with 18 tests … with 2 issues`, BOTH
  `aRetireDuringTheSaveLetsTheSaveCommit`'s (`cursor == head` and `staged == 0` failed) and nothing else; D3's
  `retiringASchedulerStopsItsInFlightDownload` GREEN beside it; restored (`diff -rq` clean against main) → 18/18
  green. The semantics are right by construction too: `Task.init` inherits
  task-locals (the swift-dependencies `\.database`) and never the creator's cancellation; awaiting `.value` waits for
  the task's result and does not throw on the waiter's cancellation, so the round genuinely waits for the save —
  which the pin's determinism (retire delivered mid-save, then `awaitIdle`, then cursor == head) also demonstrates.
  `StoreBinding.lock()` checkpoints synchronously on the OUTGOING writer (`StoreBinding.swift:89–110`), so a lock
  queues behind the shielded save — P-VX308-U4-2's precedent, her question #239 (h) covering the product call.
- **The shield's deliberate non-covers are each sound:** the empty-window dedupe pass (rollback keeps its deferral
  marker; re-runs), the push chunks (lost-ack class, already covered by `FaultInjectionSyncTests`), and the
  create-gap between the batch read and the shielded task (a save that had not begun runs whole — fix (a)'s shape).
- **D2's stage is a faithful cache, re-derived from SyncSpec.** State-based feed ⇒ a staged row whose seq hasn't
  moved is what a fresh fetch returns; any server change re-serves at a higher seq and the upsert
  (`ON CONFLICT … WHERE excluded.server_seq > …`) keeps the newer copy; a row appears once per window (one current
  seq per row), so the deduped batch is "what a fresh round from the base would fetch". The 13y per-tenant in-order
  seqs plus the A5 visibility horizon make the inter-window gap (even days, across a resume) safe — no committed row
  at or below the stage's reach can appear later.
- **The stage's identity is complete against every invalidation road I could construct:** base (cursor moved),
  corpus key id (account reset), device id (rule 21's copied library), `format` + `lockstep` (cross-build), the
  purge-ledger scan point (13j's returner road — R2-1), with `resyncReinitialize` clearing it for the base-0 corner
  and the floor-acknowledgement/`reonboardFromAccount` roads funnelling through the scan point or the reinit. A
  pre-VX-494 header (no `ledgerScanPoint` key) fails the synthesized decode and is discarded, never resumed — pinned
  (`aStageHeaderFromBeforeTheLedgerScanPointIsNeverResumed`).
- **The one-writer belts hold in every interleaving I could build on paper:** cursor-value check + continuity at all
  three doors (`stage`'s absent/unreadable/readable switch, `verifyRoundsStage` in the apply, `plan`'s identity),
  including the first-row-stall clear (cursor unmoved) and a stale round staging a fresh base-matching window after
  another round committed (caught at the apply). Each refusal writes nothing; the scheduler's one non-looping
  follow-up heals it (`nextRoundIsBeltFollowUp`, cleared by `retire()`); an external trigger during the follow-up
  reduces to the ordinary failed-round retry posture, never an unbounded loop.
- **The 13j device rule is kept honestly:** `windowDevice = fetchCursor == since ? deviceID : nil` — a resumed
  round's first window and every mid-round window pass nil; the discard/refetch paths restart at the COMMITTED
  cursor so their first window carries the id honestly. Pinned (`aResumedRoundNeverReportsItsReachAsTheDevicesCursor`).
  The seen_at consequence (a forever-resuming device drifts out of the horizon) is her bundled #239 (b), as ruled.
- **S1–S5 untouched:** the stage writes are small per-window local writes (S1); no tombstone semantics change (S2 —
  the R2-1 identity leg honors the 13j bend's ledger); IDs untouched (S3); no owner_id surface (S4); conflict-as-
  variant untouched — the apply body between the belt checks and `PullStage.clear` is byte-identical to the pre-fix
  transaction (I diffed the region; only the two belt checks before it and the clear after `setCursor` are new).
- **Local-only registration is complete and registry-driven:** `SyncSchema.localOnlyTables` + the
  `LocalMachineryRecreation` DDL map (pinned `ddl.keys == localOnlyTables`,
  `LocalMachineryRecreationTests.swift:126`), `StorePlaintextExport` drops by the same registry
  (`StorePlaintextExport.swift:40`, pinned disjoint), `MigrationTests.expectedTables` updated, no outbox trigger, no
  `sync_version`, no mirror, marker 14 untouched — v1_32 in its OWN commit (`f6658017b`) before the code
  (`c1583de0b`), per the schema-first rule.
- **E2EE seam intact:** rows open at the wire seam BEFORE any stage write (a decrypt refusal leaves the window
  unstaged, cursor unmoved); the stage holds plaintext inside the SQLCipher store like every local row; never a
  payload; the export drops it.
- **P1:** `plan` is O(1) (one EXISTS + one header read per round — the only new cost on an ordinary round); staging
  is window-bounded; encode runs off the writer (cached statement inside); the apply's batch equals the old
  in-memory batch, with R3-5's cursor decode removing the payload-string duplication. A first catch-up's cost is
  proportional to its backlog, which is the operation's own size.
- **The scheduler changes:** `loopTask` set/cleared under actor isolation; `retire()` cancels + clears both flags;
  trigger-after-retire still refuses; `awaitIdle` observes the cancelled round end; the belt follow-up never runs on
  a retired scheduler.
- **Canon, two-file shape, verified in place on main:** AppSpec §7's local-only block carries the `sync_pull_stage`
  DDL + the `pull_stage` key (matching `SyncPullStageSchema.ddl` byte-for-byte in substance); SyncSpec §3's machinery
  list and §5's staged-download paragraph carry the full rule (identity legs, one contiguous run, the apply's one
  transaction unchanged, the shield's "stops its download, never its save", the 13j nil-device line); the dated
  narrative is in AppSpecRecord (§ "2026-10-23 — VX-494"); QUESTIONS #239 carries all nine bundled calls (a)–(i);
  MobileSoul PL-57 is the mobile-parity row; the in-flight row is retired from the master plan; VX-495…499 exist on
  the board with the record's labels. No canon was removed to fit the change.
- **Evidence claims located and re-run where runnable:** 18/18 pins and the 344/80 sweep re-run green by me on this
  checkout; the red-on-old lines for every bug-class pin are recorded per piece with named behavioral reverts (RV1–6,
  RV-R1a–g, RV-R2a–g, RV-R3a), the three hollow/green reverts (RV6, RV-R2d, RV-R2g) honestly recorded as belts, NOT
  claimed as pinned. The full Mac/phone suite lines are quoted with their one flake each dispositioned as tickets
  (VX-499; the known MCP load-flake) — not re-runnable here (stage-claimed xcodebuild), accepted as recorded.
- **No corpus-size cost, no word-level tracking, no cross-entity text copy** anywhere in the diff.
