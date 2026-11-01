# VX-500 — Run: the 0.10 window follow-ups (the sync follow-ups)

**STATUS: OPEN — CUTOVER 2026-11-01 ~14:00 MDT at her word: the first orchestrator handed off after the PROTOCOL BREACH below (its context ~580k); the next orchestrator resumes from `notes/handoffs/vx-500-handoff.md` (the paste-ready kickoff at its top). RESUMED 2026-11-01 ~13:30 MDT by the second orchestrator (stage claim `vx500-orchestrator`; main merged into the branch at `c64211270` so every brief reads the reworded CLAUDE.md). The cast from here, her ruling at the resume kickoff (R-500-5): FABLE SUBAGENTS implement EVERY unit — U1a · U1b · U2 · U3 — a fresh `fable-reviewer` runs the ladder (SAME-MODEL: the orchestrator arbitrates findings against the spec); the orchestrator writes nothing that ships. Kickoff 2026-11-01 ~12:30 MDT.** Ticket VX-500 (Umbrella, project 18a — Sync
considerations) · branch `vx-500-sync-followups` · worktree `~/dev/variorum-vx-500` · the Pro. Architect shape
(`/architect-phase VX-500`); the cast is CLAUDE.md's standing default — **Fable orchestrates, writes every `Sync/`
and server line, and cold-reviews (`fable-reviewer`); Opus implements the faces, the tests and the custody road under
Fable's review.** Her kickoff word binds TWO departures from the ritual: **the PR is HELD OPEN at the end — no merge
*[removed for publication]*
commits say `Part of VX-<member>`; NO trailers of any kind (CLAUDE.md's Environment rule overrides the harness).

**Her words at kickoff (2026-11-01, verbatim):** "hello Fable! I have some extra tokens and we're very close to my weekly
reset, so I want you to get some work done but I don't want to plan on immediately merging the PR once it's ready -
we're in a code freeze for launch right now. However, I think this is now a good moment to work on /architect-phase
*[removed for publication]*
but the other elements should be allowed. Question: should the phone's VM ticket on fixing the duplicated sherlock
wait til this is in master to work? is it in the same area? right now I have no coordinator and you can freely claim
the stage, I will let you know if I do start a coordinator session. go ahead and make your branch and work through
all of this, just wait to merge the PR. As always, if you notice any sort of flaw in the design that this uncovers, or
a bug that seems bad with sync / likely to impact users, raise it in priority when flagging it to me, ESPECIALLY if
it seems like it could impact new users."

**Her VM question, answered at kickoff:** VM-32 (the phone build carrying VX-669's fix + the Sherlock-deletes-stick
acceptance round) does NOT wait on this run. Its blocker, VX-678, merged 2026-10-28 (PR #205, released in 0.10.5),
so it is runnable from `main` today; its code is the seed dedupe's defense leg (removed) and a phone INSTALL, none of
which this run touches (this run changes the engine's progress plumbing, the server's pull query, the sync row, the
typed-unlock key load and two tests). Same Area label, different code; no overlap.

## THE ROSTER (the sub-issue listing, read at kickoff 2026-11-01 — her VX-548 rule; re-listed before the ladder)

| Member | Title (short) | Kind · Evidence · Area · Priority | This run |
|---|---|---|---|
| VX-495 | the changefeed query re-sorts every remaining row per call — a first sync's download is quadratic | Improvement · Confirmed · Performance · High (Pre-launch at her R-494-4 (f)) | **U1** — the server artifact (keyset pick per table) + a read-only cost probe; the DEPLOY is HELD for her word |
| VX-496 | the sync row shows no progress during a long download | Improvement · Confirmed · Castle & sync · High (Pre-launch, R-494-4 (f)) | **U1** (the engine's progress + the count RPC) + **U2** (the row's and the sheet's words) |
| VX-497 | a first catch-up's save is one all-or-nothing transaction holding the writer for minutes | Improvement · Confirmed · Performance · Medium (her VM-8 word: "don't close it", not now) | **U1** — PROFILE first (headless, at scale); the zero-semantics win (the per-row FK introspection memoized per apply) if the profile names it; chunking = a DESIGN MEMO for her, no build |
| VX-505 | the one-writer belt's refusal shows internal error text on the row | Improvement · Wording · Castle & sync · Low | **U1** (a typed status flag) + **U2** (the row's line, her draft) |
| VX-544 | an offline TYPED unlock in Castle leaves sync locked for the session — no retry on reconnect | Bug · Confirmed · Castle & sync · Medium | **U3** — the retained typed-unlock secret in session memory + the retry at every trigger + the reachability trigger |
| VX-539 | ProtectionPairRetentionTests flakes at a week boundary — the tests read `Date()` | Bug · Test-only · Tests & tooling · Low | **U2** — the pair road and the suite on the injected clock |
| VX-504 | a first catch-up leaves free pages about the library's size — design the compaction | Improvement · Confirmed · Performance · Low | **the architect's DESIGN MEMO** (below), no build — "its own small design sitting" |
*[removed for publication]*
| VX-503 | the Standard join's Touch ID prompt | — | Done before this run; nothing here |

**Riders (the kickoff's Low/Medium sweep of Castle & sync + Performance; seated PROVISIONALLY since she is away —
one line each to unseat):** **VX-546** (ProtectionPairRetentionTests red on main at VM-8's stage batch, "possibly
date-boundary-dependent", Medium) — the SAME suite and class as VX-539; one fix, so it is SEATED beside VX-539 in U2.
**VX-490** (the sync-keys leaf's `nonisolated(unsafe)` → `SyncKeysLeaf & Sendable`, Low Debt, VX-488's own
candidate) — SEATED in U2 (zero behavior, one file). **VX-76** ("First sync on a fresh device shows only an
undifferentiated 'Syncing' — add catch-up progress", Medium, 2026-10-06) is the SAME ask as VX-496 from before the
0.10 window — related here; proposed CLOSED AS DUPLICATE of VX-496 at the merge (her call). **NOT seated:** VX-491
(the key-proof refusal's re-enrollment — reachable only by operator-side vault damage), VX-711/VX-689 (dedupe
improvements, Low), VX-212 (rotation era, retired).

**Flagged to her at kickoff, NOT seated (the priority-raise she asked for — see the kickoff report):** **VX-683**
(a pull applied into her autosave's debounce window on the SAME take is overwritten by the autosave — the remote words
survive nowhere; Suspected, statically traced at VX-677; a two-device user editing one note on both — the Mac and the
phone — is exactly the shape; a data-loss class, `Sync/`-shaped, needs its own design memo: the autosave's write as a
compare-and-rescue against the row the pull just landed, or the apply parking the incoming text until the flush) and
**VX-672** (a phone round after a book delete/purge takes minutes; Suspected; VX-497-adjacent — the per-row apply cost
or the janitor; may have dissolved with VX-669, unverified).

## THE BINDING PRINCIPLES (the 13b constitution, copied VERBATIM from `.claude/skills/architect-phase/SKILL.md` as
the skill requires; the application notes there bind too)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

## SIZING — said to her, as the guidance asks (`notes/PhaseSizingGuidance.md`)

This run holds THREE units under one theme — U1 (a server query redefinition + the engine's progress seam: a
sync/protocol unit), U2 (faces + two test fixes: a UI unit), U3 (a custody road: the typed-unlock retry) — one past
the guidance's two. Said rather than split silently: the members were bundled at her word ("if they can all run
together, do that"), each unit is small, and the ladder covers the whole diff once with a Fable reviewer (the diff
touches `Sync/` and custody). If she would rather split, U3 (VX-544) lifts out whole into its own ticket run; nothing
in U1/U2 depends on it. The units run SEQUENTIALLY (one implementer at a time), U1 → U2 → U3.

**The resume's refinement (the second orchestrator, 2026-11-01 — an architect's call, said here as the guidance asks):**
U1 as handed is two acceptance units under one name — the sync/protocol unit (the server artifact + the engine's
progress seam + the belt flag + their pins) and a MEASUREMENT unit (the apply profile at scale, with the FK memo built
only if the profile names it). One unit per implementer session, so U1 runs as **U1a** (the artifact, the seam, the
pins — the brief below) and **U1b** (the profile + the profile-gated FK memo + the chunking memo trued with the
numbers), two Fable sessions in sequence. The order stays U1a → U1b → U2 → U3. The sync unit's USE-SHAPED evidence per
the guidance is "the convergence suites for its shape + one live two-device round on the real mirror": the suites
close U1a here; the LIVE ROUND rides her held deploy window and is recorded as OWED, not claimed (THE DEPLOY §3).

## PREFLIGHT FACTS (read at kickoff — the code as it stands on `main` 00e32497c; verify points for the implementers)

- **The engine (`Sources/VariorumCore/Sync/SyncEngine.swift`):** `pullRound()` fetches the feed in `pullWindowSize`
  windows (2,000) staging each (`PullStage.stage`), then applies everything staged in ONE shielded transaction
  (`applyingRemoteShieldedFromCancellation`): the one-writer belt (cursor + continuity), the straggler FIXPOINT
  (`foreignKeysSatisfiable` over the prefix — `foreignKeyColumns` runs `PRAGMA foreign_key_list` PER ROW), then per row
  `isEnqueued` → `merge` or `writeResolvedRow` + `recordSeq`, then `runPostApplyRepairs`, the cursor, `PullStage.clear`.
  Nothing publishes progress; the engine has no reference to the scheduler.
- **The scheduler (`Sync/SyncScheduler.swift`):** `Status` (isSyncing · lastSuccessAt · lastError · lastErrorIsOffline ·
  pendingPushCount · pullStalled · pushDeferredCount · roundsCompleted) is published through `statusUpdates()`;
  `runOneRound` sets `isSyncing` once at the start and clears it at the end. The belt's refusal lands as
  `String(describing:)` on `lastError` and requests one follow-up (`nextRoundIsBeltFollowUp`).
- **The row (`App/Variorum/Shared/SyncStatusViews.swift`, shared Mac + phone):** `SyncRowFace.face(...)` classifies the
  status into a `Kind`; `.syncing` renders a small `ProgressView` beside `SyncStatusRow.line(for:)`'s "Syncing…"; the
  pins live in `App/Variorum/VariorumTests/Sync*RowTests.swift` + `FirstRound*Tests.swift`. The first-round sheet
  (VX-507, `RoadAccountModel.firstRoundLine`) says `ProtectionWords.firstRoundProgress` ("Syncing your library with your
  account…") while `face.kind == .syncing` — ONE presentation source for every other face (`SyncStatusRow.line(for:)`).
- **The transport (`Sync/SyncTransport.swift`, `Sync/SupabaseTransport.swift`):** `SyncTransport.pull(since:limit:...)`
  decodes a bare JSON array (`[PulledItem]`); the optional surfaces (`SyncPurgeTransport`, `SyncRotationTransport`) are
  SEPARATE protocols the engine reaches by `as?` — the 13j precedent for an optional door. `schemaVersion()` treats a 404
  as "the function does not exist" (version 1) — the precedent for a client that tolerates an undeployed RPC.
- **The server (`Server/supabase/13_phase13i_wings.sql` §3a — the CANONICAL `sync_pull` body since 13i-a; 12's body
  with wing/shelf added):** per call, a `union all` over all 21 synced tables of EVERY row past the cursor
  (`to_jsonb(t)` computed per eligible row), then ONE `order by raw.server_seq limit max_rows` — the plan the record's D1
  check read: Seq Scan → to_jsonb of every eligible row → full Sort → Limit; 2,934 ms at LIMIT 200 vs 1,477 ms at
  LIMIT 2,000 on her ~108k rows, the `authenticated` statement timeout 8 s. Every table carries an
  `idx_owner_seq_<table> (owner_id, server_seq)` index (09 §; 10 for `purge_intent`; 13 for `wing`/`shelf`). The A5
  horizon derives from `sync_visibility_horizon_ms()`; the belt (`maintenance/vx213-pg-temp-search-path.sql`) appends
  `pg_temp` AFTER 17, and `AuthRLSDDLTests` resolves every function's FINAL search_path through `searchPathDeployOrder`
  (lockstep files + the maintenance artifacts at their deploy positions). The pins on the pull body
  (`theVisibilityHorizonSurvivesEveryRework`, `pullFiltersEveryTableToTheCallerAndSubtractsTheStampedOwner`) read
  `finalBody(of: "sync_pull")` over `04 + lockstepFiles` — a maintenance artifact is NOT in that composition unless the
  test lays it over (the ladder-overlay precedent, `deployedBody(of:)`).
- **`Tools/prod-read.sh`** runs ONE bare `SELECT` against production (no `WITH`, no `EXPLAIN`, no mutating keyword);
  an `EXPLAIN ANALYZE` is her `!` road. Her tenant is the only large one (864 containers · ~20.8k blocks · ~32.8k
  variants · ~28.9k commits — the record's counts).
- **The typed-unlock key load (`App/Variorum/Shared/Protection/ProtectionOpenRoad.swift`):** `openTyped` →
  `loadSyncKeysAfterTypedUnlock(session, signIn:, typed:, within: 10 s)` — ONE bounded vault read; on `.failed` (offline)
  or `.timedOut` it logs and returns, the `TypedUnlockSecret` (the passphrase's DERIVED keys, or the words) is "never
  stored; gone with the call". `NewRoadSyncKeyProvider.currentKeys()` reads session memory, then the silent item, never
  the Touch ID item; Castle keeps no silent item, so the engine refuses `encryptionKeysUnavailable` until something
  loads session memory. NO reachability monitor exists in the app (grep `NWPathMonitor` → none); the round triggers are
  the write-settle observation, became-active/launch, Sync now, the act roads.
- **The retention tests (`App/Variorum/VariorumTests/Protection/ProtectionPairRetentionTests.swift`):** plant pairs at
  `Date()`-relative offsets and press `ProtectionBackupHook.takePair(session)`, whose `now: Date = Date()` default flows
  to `Retention.plan(now:)` (weekly buckets) — two clocks, read moments apart, disagreeing exactly at a bucket boundary
  (VX-539's 00:20 UTC Sunday; VX-546's VM-8 batch).

## THE DESIGN (each member: the mechanism, the build, the pins, the PROVISIONALs)

### D-495 — the server pull: a page's cost proportional to the page (U1, Fable; the DEPLOY held for her)

**Mechanism.** The body sorts every row still ahead of the cursor on each call and computes `to_jsonb(t)` for each
before the sort, so a from-zero catch-up of N rows pays ≈ N²/page in total and a large enough account meets the 8 s
statement timeout on its FIRST window whatever the page size (the record's D1 ceiling). New users with small libraries
never feel it; a user crossing a second device onto a large library does (her own case took 11.6 min of download at the
200-row window; 56 calls at 2,000).

**The build — `Server/supabase/maintenance/vx495-pull-keyset.sql` (AS DRAFTED in `aad734aef`; the FETCH is superseded by SHAPE B below — the bound-based range scan — at her 2026-11-01 probes):** a maintenance artifact (NO marker move — the wire
shape, parameters and semantics are byte-identical; a client sees only a faster answer), redefining `sync_pull` with the
SAME signature in two phases inside one dynamic statement: **THE PICK** — per table, `(select 'tbl', t.server_seq,
t.<pk>::text as row_id from tbl t where t.owner_id = caller and t.server_seq > since and <the A5 horizon filter> order
by t.server_seq limit max_rows)` — each an index range scan off `idx_owner_seq_<table>` that stops after `max_rows`
qualifying rows, `union all`ed and `order by server_seq limit max_rows` as the CTE `picked` (≤ 21 × max_rows small
tuples, never the rows' JSON); **THE FETCH** — the existing two branches VERBATIM (owner-carrying keeps `owner_id`,
mirror-only subtracts it; the same owner filter; the same derived horizon filter) with one added predicate `and t.<pk>
in (select p.row_id from picked p where p.tbl = 'tbl')`, so `to_jsonb(t)` runs exactly `max_rows` times; the outer
`jsonb_agg(... order by u.server_seq)` unchanged. Correctness: any row in the global first `max_rows` is in its own
table's first `max_rows`, so the pick's union contains the global page; each row appears once at its latest seq (one
row per PK per table); the output ORDER and SHAPE are byte-identical to today's, so the fake server (`FakeSyncServer.pull`,
already an in-memory sort) needs no change and every convergence suite stays the evidence. The device-cursor upsert,
the gate, the entitlement gate, `set search_path = public` (the belt re-applies `pg_temp` — the artifact deploys AFTER
the belt, and ITSELF re-asserts `alter function sync_pull(...) set search_path = public, pg_temp` + the
`variorum_definer` owner + the grants so a re-run lands the same state), all kept. A re-run guard: refuses below marker
14 (the body it replaces is 13's at marker ≥ 10; 14 is today's).
**Pins (core, `AuthRLSDDLTests`):** the artifact joins `searchPathDeployOrder` after the belt (`"17_…": [belt, this]`),
and `finalBody(of: "sync_pull")` is laid over with it (the `deployedBody` overlay precedent) so the two standing pull-body
pins run against the DEPLOYED body: the horizon derivation + no inline interval + the server-only subtraction; every
`from %I t` with its owner filter (the pick phase adds one `from`/one `where` per branch — the counts stay equal); plus
NEW pins: the pick phase's `order by t.server_seq limit %s` inside the per-table subquery; the fetch phase's
`in (select p.row_id from picked p …)` — SUPERSEDED by SHAPE B's bound pin (D-495 EVIDENCE); the allowlist and owner-table arrays byte-equal to 13's (no table gained or
lost). **Evidence — the read-only cost probe on production (her tenant, counts only, no content):** the OLD shape vs
the NEW shape as bare SELECTs through `Tools/prod-read.sh`, each 3 runs, wall-clock by `curl` — recorded below;
`EXPLAIN ANALYZE` of the new body is HELD for her `!` road (offered in the report). **The deploy: HELD** — at her word
only (SyncSpec §12's procedure for a function body: the mirror first; no client lockstep since nothing on the wire
changes); the checklist is in THE DEPLOY section below.

#### D-495 EVIDENCE — her `EXPLAIN ANALYZE` probes on production (2026-11-01, her `!` road; read-only; her tenant
*[removed for publication]*

- **THE OLD SHAPE (13's body):** `Execution Time: 3398.374 ms`. Parallel Append of Seq Scans on every large table
  (`block` 21,963 rows · `variant` 17,113 × 2 workers · `commit_point` 29,680 · `container_block` 21,957 · `lens_choice`
  8,373 …; ~122k rows filtered and `to_jsonb`'d), then a top-N heapsort, then the Limit. Buffers 11,538. The ticket's
  mechanism, measured: the page costs the rows still ahead.
- **THE NEW SHAPE AS WRITTEN IN `aad734aef` (pick by id, fetch by PK probe):** `Execution Time: 1137.617 ms` — 3×
  faster, and the PICK is exactly as designed: a `Merge Append` of per-table `Index Scan using idx_owner_seq_<table>`
  each under its own `Limit`, **37 ms, 241 buffers** for the whole page. The FETCH is the cost: each branch is a Nested
  Loop of per-row PK probes (`Index Scan using block_pkey … actual time=0.468 rows=1 loops=431`; variant 0.585 ms × 539;
  commit_point 0.55 ms × 443) — ~0.5 ms a probe on this instance, ~1,100 ms for the 2,000 probes. The cost is now
  O(page) rather than O(rows ahead) — the ceiling is gone — but a constant ~1.1 s per window would make the END of a
  catch-up slower than today's ~0.4 s windows, and her 56-window catch-up only ~1.7× faster in sum.
- **THE REFINEMENT (recorded for the Fable implementer; NOT written by the orchestrator) — SHAPE B, the bound-based
  fetch:** the page's picked rows per table are exactly that table's rows with `server_seq` in `(since, S]` where `S`
  is the page's LAST seq (the pick takes the globally smallest 2,000 seqs; per-tenant seqs are unique, so no ties), so
  the fetch needs NO per-row probes: `picked` yields only seqs, `bound as (select max(server_seq) from picked)`, and
  every fetch branch is ONE index RANGE scan `where t.owner_id = caller and t.server_seq > since and t.server_seq <=
  (select seq from bound) and <horizon>` off `idx_owner_seq_<table>` — `to_jsonb` on exactly the page's rows, sequential
  within each index. Expected ≈ the pick's 37 ms + the JSON of 2,000 rows. The probe `new-shape-b.sql` is written;
  her run decides (below). Either way the A5/owner pins' shape (`from %I t` + `where t.owner_id = %L` per branch, the
  derived horizon, the two subtraction branches) holds.
- **SHAPE B's result, her run: `Execution Time: 230.158 ms`** — 15× the old shape, 5× the draft. The pick as before
  (a `Merge Append` of per-table index scans under their limits, 108 ms this run — the pick's time varies 37–108 ms
  between runs on this instance); the FETCH is now an index RANGE scan per table off `idx_owner_seq_<table>` (`block`
  431 rows 7.9 ms · `variant` 539 rows 45 ms · `commit_point` 443 rows 27.5 ms · `container_block` 432 rows 7.7 ms; the
  only Seq Scans are the one-page tables `canvas_layout`/`setting`, the planner's correct choice); 969 buffers in
  all against the old shape's 11,538. **SHAPE B IS THE DESIGN (D-495 as it stands from here):** `picked` yields seqs
  only, `bound` is `max(server_seq) over picked`, every fetch branch is `… and t.server_seq <= (select seq from
  bound)` — no per-row probes, no `in (select …)`. The Fable implementer REWRITES the artifact's fetch to it (the
  drafted `in (select p.row_id from picked p …)` form and its pin in `AuthRLSDDLTests` go; a bound pin replaces them;
  the A5/owner pins' per-branch `from %I t` + `where t.owner_id = %L` shape is unchanged — the pick phase keeps the
  owner filter too, so the counts still match). Correctness unchanged from the draft's argument: per-tenant seqs are
  unique (`next_tenant_seq` per write), so "the page's rows" ≡ "every table's rows with seq ≤ the page's last seq".
  The page may hold FEWER than `max_rows` only at the head — then `bound` is the head and the fetch returns everything
  left, as today.
- **The count shape (`sync_pull_remaining`), her run:** `Execution Time: 1586.109 ms` — twenty-one `count(*)`
  InitPlans, each a Seq Scan with the owner + seq + horizon filter (`block` 21,963 rows 477 ms · `variant` 34,226 rows
  319 ms · `commit_point` 29,680 rows 304 ms · `container_block` 21,957 rows 333 ms …; 6,819 buffers). EXACT, and
  inherently O(rows remaining) — a count from zero touches every row — so it is asked ONCE per long round (the design's
  gate: only after a first full window), never per window; at her scale 1.6 s once per catch-up is acceptable, but an
  account ~3× hers would sit near the 8 s statement timeout. **Two cheaper shapes recorded for the Fable implementer
  (her exactness call — P-500-6):** (i) drop the horizon filter from the COUNT only — `where t.owner_id = caller and
  t.server_seq > since` is an index-only count off `idx_owner_seq_<table>` (no heap visits where the visibility map is
  set), exact to within the last two seconds of writes, which a progress total never needs; (ii) the O(1) ceiling —
  `sync_tenant_seq.last_seq − since` (the tenant's head is the counter; updates re-stamp rows, so it OVERSTATES rows
  remaining — honest only as "at most N", never as "of N"). The default to build: (i), with the client's words saying
  "of N" as today; (ii) only if she prefers zero server cost over exactness.

### D-496 — the progress line (U1: the engine + the count RPC; U2: the words)

**Mechanism.** The scheduler publishes `isSyncing` once; the engine's ~55-window download and its minutes-long save
report nothing in between, so the row reads "Syncing…" for the whole first catch-up — her half-hour test, the testers'
"it's broken" conclusion (VX-76). The engine KNOWS rows downloaded (each window's count + a resumed stage's) and rows
saved (the apply loop's index); the TOTAL needs the server (a count of rows past the cursor).

**The build.** (1) `SyncScheduler.Status` gains `progress: SyncProgress?` — `struct SyncProgress: Equatable, Sendable {
enum Phase { downloading, saving }; var phase; var done: Int; var total: Int? }` — nil on every ordinary round. (2)
`SyncEngine.pull(progress: (@Sendable (SyncProgress) -> Void)? = nil)` (and `pullToHead`): the download publishes after
each window ONLY ONCE THE ROUND HAS NEEDED A SECOND WINDOW (a first window that came back full) — so everyday rounds
never flash numbers; `done` = the rows this round downloaded + the resumed stage's row count (read once at plan time);
the save publishes every 1,000 applied rows and at its end, `done` = rows applied so far, `total` = the batch's count
— the save's total is EXACT and server-free. (3) THE TOTAL for the download: a new OPTIONAL transport protocol
`SyncPullCountTransport { func pullRemaining(since:activeKeyID:keyProof:) async throws -> Int64 }` (the
`SyncPurgeTransport` shape — wrappers forward, fakes serve), called ONCE per round, after the first full window, through
the round's challenge signer; `SupabaseTransport` conforms → the RPC `sync_pull_remaining(since_seq, active_key_id,
key_proof, challenge)` (the same gate as `sync_horizon`; `count(*)` per table past the cursor under the same horizon
filter, off the same indexes) in the SAME maintenance artifact as D-495 (one deploy); a transport that does not conform,
a refusal, a 404 (the RPC not yet deployed — the `schemaVersion` precedent) or any error ⇒ `total == nil` and the round
goes on — the count can NEVER fail a round. (4) The scheduler passes `{ p in Task { await self.publish(progress: p) } }`
and clears `progress` with `isSyncing` at the round's end. `FakeSyncServer` + its per-user wrapper conform (a count of
staged rows past `since`). **Pins (core):** a scheduler-driven multi-window catch-up over the fake publishes a
downloading progress whose `done` climbs to the corpus size with `total` equal to it, then a saving progress ending at
`done == total`, then `progress == nil`; a ONE-window round publishes no progress; a transport without the count surface
publishes `done` with `total == nil`; a resumed round (the VX-494 interrupt scene) starts `done` at the stage's count;
every existing `ResumableCatchUpTests`/`SyncSchedulerTests` pin green unchanged.
**The words (U2; PROVISIONAL, HERS — her example "Syncing — 40,000 of 108,000" is the lead):** `.syncing` with a
downloading progress and a total → "Syncing — 40,000 of 108,000"; without a total → "Syncing — 40,000 so far"; a saving
progress → "Syncing — saving 12,000 of 108,000"; no progress → "Syncing…" byte-unchanged. Numbers in the user's locale
grouping. The first-round sheet (VX-507's `firstRoundProgress`) keeps its own sentence and GAINS the same count beneath
it when a progress stands (P-500-2: the sheet shows the count; alt: the sheet's sentence alone). Both platforms (the row
is shared) — the MOBILE PARITY line at closeout. **Pins (Mac):** `SyncStatusRow.line(for:progress:)` for the four
shapes; the face keeps `.syncing`'s doors (CF-15: Sync now disabled, Account… present) with a progress standing.

### D-497 — the save's duration (U1, Fable): PROFILE, the one zero-semantics win, and a memo

**Her standing word (VM-8's bundle, 2026-10-26):** "honestly i don't think we'll fix it right now but don't close it" —
so this run does NOT chunk the apply. It (1) measures the apply headlessly at scale (a 1,200 × 30 generated corpus
pushed by client A over the fake, client B's pull timed by phase — the fixpoint, the row loop, the repairs — a Debug
build, the numbers recorded as RELATIVE shares, not absolute promises); (2) lands ONE optimization only if the profile
names it as a measurable share and it changes NO semantics: `foreignKeyColumns` memoized per apply transaction (today
`PRAGMA foreign_key_list(table)` runs once per ROW in the fixpoint — the schema cannot change inside the transaction, so
a per-table cache inside `pullRound`'s apply is pure); its evidence is the suite (no behavior) + the profile's before/
after; (3) writes THE CHUNKING MEMO for her (below) — the parent-first chunked apply whose commits stay atomic-consistent,
the edges enumerated (the straggler fixpoint across chunks, the cursor per chunk, the stage's continuity, a lock between
chunks, the repairs' batch scope, the phone's suspension) — a design for a later run, never built here.

### D-505 — the belt's words (U1: the flag; U2: the line — Wording, HERS)

**Mechanism.** `runOneRound`'s catch writes `String(describing: error)` to `lastError` for the belt's two refusals
(`CursorMovedUnderRound` / `StageMovedUnderRound`) and requests a follow-up; until that follow-up ends (seconds), the row
shows the internal sentence under the error face. **The build:** `Status` gains `lastErrorIsRetrying: Bool` set exactly
when `PullStage.isOneWriterRefusal(error)` (a TYPED flag, never string-matching), cleared with the next round; the face
classifies it (after offline, before every other error class) as a new `Kind.retrying` rendered like `.syncing` (the
small spinner, the same doors) with her draft line, sentence-cased for the app ("Another change landed mid-sync —
retrying."; her words: "another change landed mid-sync — retrying."), the engine's sentence in the hover as every paused
state's. PROVISIONAL P-500-3 (hers to reword). **Pins:** core — the scheduler sets the flag on the belt's refusal and
clears it after the healing follow-up (ride the R2-6 scene); Mac — the face's kind + line, and an ordinary error keeps
`.error`.

### D-544 — the offline typed unlock (U3, Opus under Fable review; custody-adjacent, CastleRules read)

**Mechanism (her two-Mac test, VX-529 steps 8–9, confirmed live):** offline, the typed unlock's one bounded vault read
fails; the library opens (never hostage — correct); the derived secret is dropped with the call; nothing ever retries, so
the row says "Sync locked — this Mac hasn't unlocked your account's sync keys" until another ONLINE typed unlock or a
Touch ID unlock. Castle users on the typed road (Always ask, or Touch ID declined) who open offline — a train, a plane,
a café — and come back online never sync that session. New users who choose Castle without Touch ID meet it on their
first offline open.

**The posture question, answered from the rules before any code:** rule 9 ("no copy of the key on the device at all"
under Always ask) is about the DEVICE — disk and keychain; session MEMORY already holds the account's sync keys after a
successful typed unlock (`holdInSession`, dropped at a relock — `ProtectionRoadLock.dropSessionMemory`). Holding the
typed unlock's DERIVED secret (the `PassphraseKey`s the open derived, or the words' derived `WordsKey`) in the SAME
session memory, for the same lifetime, to finish the load the user already authorized, is posture-consistent and exactly
her R-494-4 direction ("a typed unlock should hold sync keys in session until lock"). Nothing is written to disk or
keychain; a lock drops it with the keys.

**The build.** (1) `ProtectionRoadSession` gains `pendingSyncKeyLoad: PendingSyncKeyLoad?` (`account`, the
`TypedUnlockSecret` — derived material only, never the passphrase text; `CustomStringConvertible` redacted) set by
`loadSyncKeysAfterTypedUnlock` ONLY on `.failed`/`.timedOut` of the vault read (every other exit — loaded, no vault,
signed out, a secret that opens the library but not the vault, a moved account — leaves it nil as today), cleared on a
successful load, on `dropSessionMemory` (the relock), on sign-out, and by any act that loads the keys. (2) THE RETRY:
`ProtectionOpenRoad.retryPendingSyncKeyLoad(session, signIn:)` — the same function with the retained secret, the same 10 s
bound, the same log lines; idempotent; nil pending ⇒ nothing. (3) THE OCCASIONS: (a) every sync trigger —
`SyncSession.triggerSync()` and `flush()` gain an optional async `beforeRound: (@MainActor () async -> Void)?` hook
the Mac composition wires to the retry (run only when the provider cannot produce keys — one cheap `currentKeys()` try —
so an unlocked session pays nothing); the round then runs with the keys loaded; (b) a NEW reachability trigger —
`NWPathMonitor` in the shared `SyncSession` (Network framework, both platforms): a path transition to `.satisfied` from
unsatisfied runs `triggerSync()` once (debounced 2 s), so her step 9 ("Wi-Fi back on, a minute's wait") heals by itself.
The row keeps saying locked until the keys load; "Sync now" and the Protection door keep their roads. PROVISIONAL
P-500-4: the retained-derived-secret shape over the alternative "a quiet one-press Unlock sync door on the locked row"
(the ticket's other option) — the door would make her type again; the retention finishes what she typed. P-500-5: the
reachability trigger (a new machinery, small, shared). **Pins (Mac, the planted road + a scripted vault leaf):** a typed
unlock whose vault read fails OFFLINE leaves `pendingSyncKeyLoad` standing and the keys unloaded (red-on-old: the pending
load does not exist); a later `retryPendingSyncKeyLoad` with the vault reachable loads the keys and clears the pending
(red-on-old); a relock clears the pending (guard); a successful first load leaves no pending (guard); the SyncSession
hook runs before a triggered round and only while keys are missing (core-free Mac pin over a scripted scheduler — the
`FirstRoundScheduling` precedent); the reachability trigger fires `triggerSync` once per satisfied transition (a planted
path publisher). Live confirmation (her hands, later): the two-Mac test's steps 8–9 on her Air.

### D-539 + VX-546 — the retention tests on the injected clock (U2, Opus)

**Mechanism.** The suite plants dated pairs relative to its own `Date()` and the pair road reads another `Date()`
(`takePair`'s default) moments later; `Retention.plan` buckets weeklies by `now`'s week, so across a week boundary (or
any bucket edge) the two clocks disagree and the expected 14 + 4 drifts — a flake on some days, green on others; VX-546
saw it on 2026-10-25 (a Saturday night). **The build:** `ProtectionBackupHook.takePair`/`takePairReporting`/`prune`'s
`now` default becomes the injected clock (`Dependency(\.date).wrappedValue.now` — the app's live clock resolves to
`Date()`, so production is byte-unchanged); the suite wraps planting AND the press in `withDependencies { $0.date =
.constant(instant) }` with ONE instant per test, planting from that instant. **The red-on-old pin:** one test pinned
at a boundary instant deep in the past (e.g. 2026-01-04 00:20 UTC, a Sunday) — on the OLD code the road's real `Date()`
differs from the planted instant by months, the buckets disagree, the counts miss → RED deterministically; on the new
code both clocks are the instant → green. VX-546's two failing tests become green by the same change (its "real
miscount" alternative is falsified by the pin: the planner is correct under one clock).

### D-490 — the leaf's constraint (U2, Opus)

`RoadInputs.live`'s shared sync-keys leaf parameter: `nonisolated(unsafe)` → `SyncKeysLeaf & Sendable` as the ticket
states (the bootstrap's stored `any SyncKeysLeaf` retypes or drops; `OneSyncKeysLeafCompositionTests`' literal moves).
Zero behavior; the suites are the evidence; no pin claimed.

### D-504 — THE COMPACTION MEMO (the architect's; for her sitting, no build)

**The fact:** a first catch-up stages the whole feed (~the library's size as JSON) in the store file, then the apply
empties the stage in the commit; SQLite keeps the pages FREE (79 MB corpus → 150 MB file in the live proof) until growth
reuses them, and the page-copying backup API copies the slack into every backup until then. Correctness untouched; a
fresh device's first catch-up only; her Pro and Air carry it today.
**Options:** **(a) `PRAGMA incremental_vacuum(N)` after the first catch-up's commit** — requires `auto_vacuum =
INCREMENTAL`, which can only be set on an EMPTY database or by a full VACUUM; a FRESH library (the only place the slack
is born) is created empty by this app, so the migration that creates v1 can set it for new stores; existing stores
would need the one-time full VACUUM the app never runs (and VACUUM can renumber rowids behind the search index's
external-content FTS table — a rebuild-after step, `Operations.rebuildSearchIndex`, makes it safe). Cost: incremental
vacuum moves pages, so a background `incremental_vacuum(1000)` loop after a large apply (writer-held in small bites). **(b)
`VACUUM INTO` on the BACKUP road** — the backup pair writes a compacted copy instead of the page copy (SQLCipher supports
`VACUUM INTO`; the key file pair unchanged), so backups never carry the slack while the live file keeps its free pages
until reuse; no FTS concern (the live file is untouched). **(c) a one-time VACUUM + search-index rebuild at a quiet
moment after a first catch-up** (the lock's idle window, or the quit door) — the simplest for the live file, with the
FTS rebuild as its belt and a writer hold for its duration. **Recommendation for her sitting:** (b) first (backups are
where the slack multiplies, zero live-file risk), (a) for fresh stores at the next schema touch; (c) declined (a long
writer hold on her real store for a cosmetic size). Ticket VX-504 carries this memo's pointer; nothing here is built.

### THE CHUNKING MEMO (D-497's deliverable; for her sitting, no build)

**The save today:** one transaction over every staged row — the straggler fixpoint (apply in seq order up to the first
row whose FK closure is satisfiable neither locally nor by the applied prefix), the row loop, the repairs, the cursor,
the stage cleared. Atomic-consistent at commit under deferred FKs; a rollback keeps the stage (resume, never
re-download); her Pro ~4 min 20 s (~420 rows/s), the throwaway ~7 min with a shared CPU; the phone slower and suspendable.
**A chunked apply, on paper:** apply the staged rows in K-row chunks, each its own transaction committing the cursor
at the chunk's end. **The edges:** (1) the FK fixpoint is per chunk — a chunk that stalls at a straggler commits its
prefix and holds the cursor at the stall (today's stall semantics, per chunk); the rows past the stall in THIS chunk are
re-fetched next round exactly as today — but the STAGE must then be cleared only PAST the committed cursor (today it
clears whole: a partial clear is new — `PullStage.clear(after:)`, the header's `base` advancing to the new cursor, its
continuity half re-derived); (2) the one-writer belt holds per chunk (the cursor check + the continuity check run inside
each chunk's transaction); (3) the repairs (`runPostApplyRepairs`) are BATCH-scoped today — a dedupe/keeper repair that
reads "the batch" would see one chunk; the deferral markers (F2's, the furniture fold's) already handle rows arriving in
a later batch, so chunking is "many small batches" to them, but the Journal-keeper's "re-point BEFORE any tombstone
applies" arm needs the keeper and the loser in one chunk OR the arrival-order independence it already claims (R1/F1) —
to verify, not assume; (4) a lock between chunks closes the library with the cursor committed mid-feed — safe by design
(resume from the cursor; the stage past it stays); (5) the 13j device rule — a mid-feed cursor IS committed, so the next
round's first window may carry the device id honestly; (6) echo suppression and outbox explicit-enqueue unchanged per
chunk. **The gain:** the writer held in bites (her typing's autosaves interleave), a lock or a phone suspension costs
one chunk, the progress line gets a cursor that moves. **The cost:** a window where the library shows PART of a crossing
(the Library fills in as chunks land — the record's "nothing is visible until the one commit" becomes "visible as it
lands"; a product-flavored change for her eye). **Recommendation:** profile first (this run); chunk in its own run with
a convergence-suite extension (the fake harness driving a K-row chunked apply through every repair suite) — never a
patch.

## THE DEPLOY (HELD — at her explicit word only; SyncSpec §12's procedure for a server-side body; NOT a marker event)

1. Rehearse? The throwaway project was deleted 2026-10-27; a new throwaway is her hands (or she accepts the read-only
   production probe as the rehearsal — the body is a query rewrite under the same gates).
2. `Server/supabase/maintenance/vx495-pull-keyset.sql` on production through the stored PAT at her word (the artifact
   carries its own marker ≥ 14 guard and is idempotent).
3. Verify: `select pg_get_functiondef('sync_pull(bigint,text,text,text,int,text)'::regprocedure)` reads the new body;
   `sync_pull_remaining` exists; the grant sweep (`maintenance/14c-post-deploy-grant-sweep.sql`) reads 62 OK · 4 INFO
   · 0 fail PLUS one row for the new function; her first round runs clean; the row shows the count on a long round.
4. No client install is needed for the deploy (the wire is unchanged); the client half (progress) rides the PR.

## ENVIRONMENT TRAPS (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run);
inside a command that names the app's path use `pgrep -x Variorum`. Real-store instances are treated by STORE, never
quit or killed; no Release build or `/Applications` refresh while one lives (none is planned this run — the PR is held).
Headless `swift build`/`swift test` from `<home>/dev/variorum-vx-500` needs no stage; EVERY `xcodebuild
test` needs a HELD `Tools/stage` claim (the orchestrator claims it for the closing Mac run); Mac tests from
`App/Variorum/` with suite-level `-only-testing`, confirm the "Test run with N tests" line; never a custom build
configuration. Swift Testing's count includes skipped tests — read the skipped lines. The core suite's known load-flake
`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitialize…` (passes alone) is named, never fixed here. The release core
run is split (`swift build -c release --build-tests -Xswiftc -enable-testing`, then `swift test -c release --skip-build`)
— one call is capped at 10 minutes. Commit per piece, push after every commit, LIVE STATUS flipped in the same commit,
PENDING on every unverified claim; foreground waits only (poll a log with `grep -q … && break; sleep 5`); never
`git checkout` over uncommitted work; a behavioral revert is named in the record BEFORE it runs, at a committed tip,
restored by `git checkout --`, `git diff --exit-code` clean after. No subagents for implementers. No store, no server
contact except the orchestrator's read-only probe through `Tools/prod-read.sh`.

## PROTOCOL BREACH — recorded at her stop (2026-11-01, ~13:40 MDT)

**What happened.** The orchestrator (Fable) WROTE THE CODE of U1 itself instead of briefing an implementer: the server
artifact `Server/supabase/maintenance/vx495-pull-keyset.sql`, the engine's progress seam and the count door in
`Sources/VariorumCore/Sync/` (`SyncEngine.swift`, `SyncScheduler.swift`, `PullStage.swift`, `SyncTransport.swift`,
`SupabaseTransport.swift`), the fake server's count, the sweep row, a new suite (`SyncProgressTests`), a pin in
`ResumableCatchUpTests`, and edits to `AuthRLSDDLTests` — committed as `aad734aef` ("DDL pins WIP"). It read
CLAUDE.md's "any change inside `Sources/VariorumCore/Sync/` is Fable work" as licence for the ORCHESTRATOR to type,
and then kept typing past `Sync/`. That reading was wrong: the architect shape's mandate is to orchestrate — a fresh
implementer per batch builds, a fresh cold reviewer reviews, and the orchestrator writes only records, briefs,
adjudication fixes and environment acts; "Fable work" on `Sync/` means a Fable AGENT in the cast (the reviewer's
FINDER-FIXES road), never the orchestrator's own hands. **Her words (verbatim):** "why are you doing all of the code?
/architect-phase gives you subagents to work with." and, at the stop: "Stop - you are not supposed to even be writing
the Sync code. read what /architect-phase entails - you are supposed to only be the orchestrator of several subagents
that write code, cold review, etc. record this breach in protocol as well."

**The disposition (hers to confirm):** the orchestrator-written commit `aad734aef` is UNTRUSTED INPUT — it is not an
implementer's work and no cold review has read it. Two honest roads: (a) REVERT it (one `git revert`, the branch back
to the plan file alone) and brief a fresh `opus-implementer` for U1 from THE DESIGN above; (b) KEEP it as a DRAFT the
U1 implementer ADOPTS — re-reads every line against D-495/D-496/D-505, re-derives the pins' red-on-old, fixes the
WIP (the DDL body finder's prefix match), and owns it — with the ladder's cold review covering it like any
implementer diff. The orchestrator writes no further product or test code in this run either way. The build-evidence
claims in `aad734aef`'s message (the existing resume/scheduler suites green, the DDL suite's 19 issues) stand as
observations, not as the unit's evidence.

**The standing lesson, into memory** (`orchestrator-never-writes-code`): under `/architect-phase` and `/run-phase`
the orchestrator never writes product or test code — not `Sync/`, not "small" — it briefs, verifies, adjudicates and
records; the cast's model rules name which AGENT types, never the orchestrator.

## HER RULINGS AT THE CUTOVER SITTING (2026-11-01, after the probes; verbatim-faithful)

- **R-500-1 — the count's shape (P-500-6 RULED):** the question tool's "Index-only count (Recommended)" — drop the
  2-second horizon filter from `sync_pull_remaining` only, so each table's count runs off `idx_owner_seq_<table>`
  without heap visits; exact to within the last two seconds of writes; still asked once per long round. The exact
  horizon-filtered count (1.6 s), the O(1) head ceiling and "no total" were the declined alternatives.
- **R-500-2 — Pre-launch:** "no one is going to have a phone at launch, so VX-683 does not need to be pre-launch.
  VX-544 I've already decided is fine to not have at launch as well." Neither carries the label.
- **R-500-3 — the cast rule, for CLAUDE.md (her words):** "I would fix CLAUDE.md to say that changes inside of Sync
  require Fable review, instead of being Fable work. I would also say that I'll decide at kickoff time or in the plan
  file for if it will be Fable implemented or Opus implemented. … the claude.md should also be clear that Fable always
  reviews the Sync and Editor Seam class". No `fable-implementer` agent definition for now ("it's rare that I use
  one"). For THIS run: U1's implementer is decided at the new orchestrator's kickoff with her (the handoff's prompt
  names it as her call), the reviewer is Fable.
- **R-500-4 — the recovery shape:** her word — finish, commit, hand off to a fresh orchestrator; three units stand;
  the probes ran at her `!` road (D-495 EVIDENCE).
- **R-500-5 — the cast for this run (the resume kickoff, 2026-11-01 ~13:35 MDT; the question tool):** her kickoff
  line "Fable subagents implementing", confirmed against the handoff's Fable-or-Opus question as **"Fable implements
  all three units"** — U1 (`Sync/`), U2 (the faces, the retention clock, the leaf) and U3 (the typed-unlock retry) are
  each a Fable implementer session; a fresh `fable-reviewer` runs the ladder; same-model, so the orchestrator
  arbitrates against the spec (CLAUDE.md). The declined alternatives: Fable U1 + U3 with Opus U2; the handoff's shape
  (Fable U1 only). Her kickoff words for this session, verbatim: "do not plan to merge your PR automatically at the end -
  main is currently frozen in preparation for release"; "You have the stage on the macbook pro - there's currently no
  coordinator, so claim the stage yourself, and I am off of it for any testing that you need to do"; "/architect-phase
  discipline. Fable subagents implementing."


## THE BRIEFS (one per unit; an implementer reads ITS brief, the sections it names, and nothing briefed from a transcript)

### U1a BRIEF — the server artifact (SHAPE B + the count per R-500-1), the engine's progress seam, the belt flag, the pins (a FABLE implementer; a SYNC batch)

**Who you are.** The implementer for U1a of VX-500, a Fable subagent at xhigh effort. `.claude/agents/opus-implementer.md`'s
contract binds you point for point (its model line aside — you are Fable at her R-500-5 word): read everything named
here yourself; one unit; pin before fix; no product invention; checkpoint discipline; no subagents but one read-only
Sonnet lookup at a time for EXTERNAL facts; honest close. **This IS a sync batch: `Sources/VariorumCore/Sync/` and
`Server/supabase/maintenance/` are yours to edit.** The orchestrator writes nothing that ships and will not fix your
code at adjudication — what you leave unfinished stays unfinished until a fresh session. You work ONLY in the worktree
`<home>/dev/variorum-vx-500` on branch `vx-500-sync-followups` (never the main checkout). No store is
opened, no server is contacted, no stage is needed (headless `swift build`/`swift test` only).

**Read first, in full, in this order:** `CLAUDE.md` and the canon it loads · THIS FILE WHOLE (the roster, PREFLIGHT
FACTS, D-495 with its EVIDENCE, D-496, D-497, D-505, PROTOCOL BREACH, HER RULINGS R-500-1…5, ENVIRONMENT TRAPS, LIVE
STATUS) · `notes/handoffs/vx-500-handoff.md` (the STATE AT CUTOVER table names the DDL WIP's exact causes) ·
`notes/SyncSpec.md` WHOLE (§3, §5, §12 especially) · `notes/sync-postmortem-fragments.md` (AppSpec §15 risk 3: read
before touching `Sync/`) · `notes/SessionResiliencyProtocol.md` §implementer · then `git show aad734aef` — THE DRAFT —
and the three files it touches most (`Sync/SyncEngine.swift`, `Sync/SyncScheduler.swift`,
`Server/supabase/maintenance/vx495-pull-keyset.sql`) as they stand on the tip, plus `Tests/VariorumCoreTests/AuthRLSDDLTests.swift`'s
finders (`finalBody`, `lastBody`, `deployedBody`, `searchPathDeployOrder`, `aDoctoredChainIsFlaggedByTheSearchPathCheck`)
and `Server/supabase/13_phase13i_wings.sql` §3a (the body SHAPE B replaces).

**The standing of the draft.** `aad734aef` was written by the first orchestrator in breach of the shape (PROTOCOL
BREACH) and has never been reviewed. You ADOPT it as a draft: every line of it is now yours to defend or change. Re-read
each against D-495 / D-496 / D-505 and the engine's own invariants (SyncSpec §5: the apply is one transaction, the
cursor moves at commit; the progress closure must never be able to fail or stall a round; the generation guard; the
weak-self hop; `advances`' monotone rule; the save's stride publishes from INSIDE the write transaction — a Task per
1,000 rows). Where the draft is right, keep it and say so in your record; where it is wrong, fix it and say why. Its
commit message's "green" claims are observations, not your evidence — re-run everything yourself.

**The pieces, in order (commit per piece, push after each, the record flipped in the same commit):**

1. **SHAPE B in `maintenance/vx495-pull-keyset.sql` (D-495 EVIDENCE, her 230 ms probe — THE design).** The pick
   yields SEQS only (drop `row_id` from the pick tuples — `sync_table_pk` is no longer needed there); add
   `bound as (select max(server_seq) as seq from picked)`; every fetch branch's `and t.%I in (select p.row_id from
   picked p where p.tbl = %L)` becomes `and t.server_seq <= (select seq from bound)`; the header comment is rewritten
   to describe SHAPE B (and to name the probe numbers: old 3,398 ms · pick-by-id 1,138 ms · SHAPE B 230 ms); the
   VERIFY comment's "carries 'with picked as'" stays true. Keep byte-identical everything D-495 lists as kept (the
   signature, the gates, the device-cursor upsert, the derived horizon, the two subtraction branches, the owner filter
   on every branch, the re-asserted owner/search_path/grants, the marker ≥ 14 guard). Correctness argument (write it
   into the header): per-tenant seqs are unique, so "the page's rows" ≡ "every allowed table's rows with
   since < seq ≤ bound". **One edge for YOUR judgment, recorded either way:** the horizon cutoff is
   `clock_timestamp() - horizon`, evaluated per branch — between the pick and the fetch inside one statement the clock
   advances by microseconds, so a row with seq ≤ bound that was inside the horizon at the pick could be outside it at
   the fetch and ride the page unpicked (harmless to the client, which treats any count ≥ `max_rows` as a full
   window; the reverse — picked but unfetched — cannot happen since visibility only grows). Either keep it and say
   it is harmless, or read the cutoff ONCE into a `timestamptz` local used by both phases — but
   `theVisibilityHorizonSurvivesEveryRework` pins the exact text `t.server_written_at <= clock_timestamp() - %L::interval`
   and `!contains("interval '")`; if you change the shape, amend that pin's text WITH its reason in the same commit
   and keep its three intents (derived from the one function, no inline literal, every branch filtered).
2. **The count per R-500-1.** `sync_pull_remaining` DROPS the horizon filter (and the `horizon` local) — each table's
   count is `where t.owner_id = %L and t.server_seq > %s`, an index-only count off `idx_owner_seq_<table>`; the header
   says why (exact to within the last two seconds of writes, which a progress total never needs; her ruling R-500-1;
   the measured alternative 1,586 ms with the filter). The fake server's `pullRemaining` mirrors the server EXACTLY —
   drop its `writtenAt <= clock - visibilityHorizon` term too — then re-derive what `SyncProgressTests` asserts about
   totals vs rows served (a count without the horizon can exceed the rows the feed serves while writes are inside the
   horizon; confirm the fake's clock makes the pins' equalities honest, or loosen them to the true relation with the
   reason). The sweep row (`14c-post-deploy-grant-sweep.sql`) and the grants stay as drafted.
3. **The DDL pins (`AuthRLSDDLTests`) — the handoff's three known causes, then every remaining issue read honestly:**
   (a) `finalBody(of:)` and `lastBody(of:in:)` match `"create or replace function \(name)"` as a PREFIX, so with the
   artifact laid over, `sync_pull` resolves to `sync_pull_remaining`'s body — match `"create or replace function
   \(name)("` in both; (b) the count pin's `!artifact.contains("lockstep_version'")` is wrong (the artifact's GUARD
   reads the marker) — assert no marker WRITE instead (no `update sync_meta`, no `insert into sync_meta`); (c)
   `aDoctoredChainIsFlaggedByTheSearchPathCheck`'s "unbelted" arm expects every checked signature flagged when the
   belt is dropped, but `sync_pull` and `sync_pull_remaining` now receive `pg_temp` from the VX-495 artifact itself —
   drop the post-belt artifact from that arm too (or exempt the two by name, with the reason). The drafted fetch pin
   (`in (select p.row_id from picked p …)`, both branches) GOES; a BOUND pin replaces it (`with picked as`, `bound as
   (select max(server_seq)`, `t.server_seq <= (select seq from bound)` in both branches, the pick's
   `order by t.server_seq` + `limit %s`, no `row_id` in the pick). Then `swift test --filter AuthRLSDDLTests` and read
   EVERY remaining issue — fix what the artifact or the test got wrong, never weaken a standing pin to pass.
4. **The pins' red-on-old, honestly.** This unit's members are Improvements (VX-495, VX-496) and a Wording item
   (VX-505): no bug-class pin is owed, and `SyncProgressTests` + the belt-flag pin are NEW-API pins (red on the old tree
   by compile, which proves nothing about behavior). Record that plainly. For the DDL shape pins show the honest red:
   with `postChainFunctionArtifacts` emptied, the bound pin and the count pin fail against 13's body (run it once, note
   the failure lines, restore). Pin counts and names land in your record.
5. **The engine's and scheduler's lines — your ownership pass.** For each of: `SyncProgress`, `pull(progress:)` /
   `pullToHead(progress:)`, `countRemaining` (ONCE per round, through the round's signer, never able to throw),
   `stagedRowCount` at plan time, the arming rule (a first window that came back full, or a resumed stage), the save's
   stride and its first/last publishes, `Status.progress` cleared with `isSyncing`, the generation guard,
   `advances`, `lastErrorIsRetrying` set exactly on `PullStage.isOneWriterRefusal` with a follow-up requested and
   cleared at the next round's start — write one line in the record: KEPT (why right) or CHANGED (what, why). Check
   in particular: does `Status.lastErrorIsRetrying` go FALSE when the follow-up itself is refused (D-505: "on a belt
   refusal nothing follows" — read the `!isBeltFollowUp` guard) and does the face's contract (D-505's `Kind.retrying`,
   U2) have the typed fact it needs? Does any new line read `String(describing:)` or match a sentence? (It must not.)
6. **Close.** `swift build`; `swift test --filter "SyncProgressTests|ResumableCatchUpTests|SyncSchedulerTests|AuthRLSDDLTests"`
   green with the counts in the record; then the broad core run `swift test` (debug) in the foreground, polling a log
   per the traps — its exact "Test run with N tests" line and any failure named (the known load-flake
   `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitialize…` is recorded, never fixed here). Write your
   SELF-ASSESSMENT (the first of the two reviews: what you are least sure of, what the cold reviewer should press on,
   with file:line) at the end of your record.

**Your record.** Append `### U1a RECORD` under `## UNIT RECORDS` below, with a LIVE STATUS table (one row per piece:
`DONE (hash)` · `IN-PROGRESS — what remains` · `NOT-STARTED`) written at your FIRST commit and flipped per piece; the
ownership-pass lines (piece 5); the pins (names, counts, the honest red); the close's lines; the self-assessment; the
first line of the record names anything you did NOT do. Flip rows 1 and 2 of the orchestrator's LIVE STATUS table to
`DONE (hash) — U1a` when they are. Commit messages: `VX-500 U1a: …` with `Part of VX-495` / `Part of VX-496` /
`Part of VX-505` as fits; NO trailers of any kind; `git pull --rebase` before each push.

**Not yours:** the apply PROFILE and the FK memo (U1b, a later session); the faces and the words (U2); the typed-unlock
retry (U3); the DEPLOY (held for her word); the PR; any `/Applications` act; any store. If a second unit stands in your
way, stop, record, hand off.

**ENVIRONMENT TRAPS — the section above, binding verbatim.**

## UNIT RECORDS (appended by each implementer; the orchestrator's verification notes follow each)

### U1a RECORD (the Fable implementer, 2026-11-01; branch `vx-500-sync-followups`, worktree `~/dev/variorum-vx-500`)

**NOT DONE (the record's first line):** nothing of the brief's six pieces is left undone (the LIVE STATUS below). NOT
done because not this unit's: the apply PROFILE and the FK memo (U1b), the faces and the words (U2), the typed-unlock
retry (U3), the DEPLOY (held for her word — the artifact has never run on a Postgres; the DDL and wire pins are string
pins), the PR, any `/Applications` act, any store, any stage. NOT added though a reviewer may want them (the
self-assessment, items 5 and 8): a stall scene pinning the save's `done < total`, and an engine scene under a non-zero
horizon pinning `total > rows served`. The three ladder questions I leave open are in the self-assessment (1, 3, 6).

**The standing of the draft `aad734aef`, adopted:** every line of it is re-read against D-495 / D-496 / D-505 and
SyncSpec §5 before this record closes; the ownership-pass lines (piece 5) say KEPT or CHANGED per item. Its commit
message's "green" claims are observations only — every suite named here is re-run by this session.

#### LIVE STATUS (U1a; flipped per piece, in the piece's own commit)

| # | Piece | Status |
|---|---|---|
| 1 | SHAPE B in `maintenance/vx495-pull-keyset.sql` (D-495 EVIDENCE): the pick yields SEQS only; `bound as (select max(server_seq) as seq from picked)`; every fetch branch bounded by `t.server_seq <= (select seq from bound)` (the probe's exact predicate order: horizon, then bound); the header rewritten (SHAPE B, the correctness argument, the horizon-skew judgment, the measured numbers 3,398 · 1,138 · 230 ms); VERIFY names the bound text | DONE (`6155ba7fb`) — the horizon edge KEPT as per-branch `clock_timestamp()` and said harmless in the header (visibility only grows ⇒ picked-but-unfetched impossible; fetched-but-unpicked impossible under the per-tenant counter's write-order = seq-order, and harmless to the client if it ever were); the pinned filter text is byte-identical to 13's |
| 2 | The count per R-500-1: `sync_pull_remaining` drops the horizon filter and the `horizon` local (an index-only count off `idx_owner_seq_<table>`); the fake's `pullRemaining` drops its horizon term too (keeps `committed` — Postgres visibility); `SyncProgressTests`' totals re-derived | DONE (this commit) — the re-derivation: the six drafted pins run the fake at horizon 0, so `done == total` stays exact (nothing is ever inside the horizon); the TRUE relation (`total ≥ rows served now`, equal once the horizon passes) is pinned NEW under `FakeSyncServer(visibilityHorizon: 5)` — `theCountIsIndexOnlyAndCountsRowsStillInsideTheHorizon`; `swift test --filter SyncProgressTests` → "Test run with 7 tests in 1 suite passed" |
| 3 | The DDL pins (`AuthRLSDDLTests`): (a) `finalBody`/`lastBody` match `"create or replace function \(name)("`; (b) the count pin asserts no marker WRITE; (c) the doctored chain's unbelted arm drops the VX-495 artifact too; the drafted `in (select p.row_id …)` pin GOES, a BOUND pin replaces it; then every remaining issue read honestly | DONE (this commit) — the three causes were the WHOLE of the 19 issues: after (a)+(b)+(c) and the bound pin, `swift test --filter AuthRLSDDLTests` → "Test run with 82 tests in 1 suite passed", 0 skipped, no standing pin weakened (the A5 pin, the owner-filter pin, the belt's drift pin and the doctored-chain proof all ran green against the laid-over body). The bound pin (`theKeysetPullPicksEachTablesPageOffItsIndexThenFetchesUpToTheBound`) asserts: `with picked as (` · the pick's `(select t.server_seq\n from %I t` · `order by t.server_seq\n limit %s)` · `bound as (select max(server_seq) as seq from picked)` · `and t.server_seq <= (select seq from bound)` exactly twice · no `in (select` · `sync_table_pk(tbl)` exactly twice (the fetch's row_id only) · the horizon filter exactly three times (pick + both fetch branches) · gates, upsert, 13's arrays byte-equal, the pg_temp header. The count pin (`theCatchUpCountIsAnIndexOnlyReadUnderThePullsGatesForAuthenticatedOnly`) asserts the owner+seq term verbatim, no `server_written_at`/`interval` in the body, from-count == owner-filter-count, the gate under its own rpc name, the grants/owner/search_path lines, the marker READ present and no `update`/`insert into sync_meta` |
| 4 | The pins' red-on-old, honestly (new-API pins said plainly; the DDL shape pins' honest red with `postChainFunctionArtifacts` emptied — run once, lines noted, restored) | DONE (this commit) — **the DDL shape pins' red against 13's body:** at the committed tip `1e8d24286` (tree clean), `postChainFunctionArtifacts` emptied by a scratch `sed`, `swift test --filter "theKeysetPull…UpToTheBound\|theCatchUpCount…AuthenticatedOnly"` → "Test run with 2 tests in 1 suite failed … with 12 issues": the bound pin 7 issues (`with picked as (` · the seqs-only pick · `order by … limit %s)` · `bound as (select max(server_seq) as seq from picked)` · the two bounded branches · the three horizon filters · `set search_path = public, pg_temp`), the count pin 5 (the `finalBody` finder's "no create-or-replace for sync_pull_remaining" Issue, then the gate, the entitlement, the owner+seq term, the allowlist); restored by `git checkout --`, `git diff --exit-code` clean at `1e8d24286`. **The rest, said plainly (the brief's piece 4):** VX-495 and VX-496 are Improvements and VX-505 a Wording item — no bug-class pin is owed; `SyncProgressTests` (7) and the belt-flag pin in `ResumableCatchUpTests` are NEW-API pins — on the pre-draft tree they fail only by compile (`SyncProgress`, `pull(progress:)`, `Status.progress`, `lastErrorIsRetrying` do not exist), which proves nothing about behavior; their evidence is the scenes they drive on the fake (a 120-row catch-up over 40-row windows, the VX-494 interrupt + resume, the N2 belt interleaving) and the convergence assertions each ends on |
| 5 | The ownership pass over the adopted engine/scheduler lines (one KEPT/CHANGED line per item) | DONE (this commit) — the lines below; ONE change (the save's total = the batch's count, per D-496's letter); `swift test --filter "SyncProgressTests\|ResumableCatchUpTests\|SyncSchedulerTests"` → "Test run with 36 tests in 4 suites passed" |
| 6 | Close: `swift build`; the four named suites green with counts; the broad core `swift test` in the foreground; the self-assessment | IN-PROGRESS — build green; the named suites "118 tests in 5 suites passed"; the FIRST broad run read whole (the wire pin found and grown — the close block below); the self-assessment written; the SECOND broad run PENDING |

#### The ownership pass (piece 5) — every adopted engine/scheduler line, KEPT (why right) or CHANGED (what, why)

- **`SyncProgress`** (`Sync/SyncEngine.swift`, above the engine): KEPT — a public `Equatable, Sendable` value: two phases, `done`, `total: Int?`. Its doc GAINED the two bounds a face must tolerate: `done > total` when the feed grew during a long download (the total is the count at arm time — R-500-1's index-only count, exact to within the horizon), `done < total` at a straggler stall's end (the unapplied rows are fetched again next round).
- **`pull(progress:)` / `pullToHead(progress:)`**: KEPT — the default `nil` keeps every existing caller byte-unchanged (the deliberate-act engines, the Mac suites' scripted schedulers); `pullToHead` hands the one closure to each attempt. The closure is synchronous `@Sendable (SyncProgress) -> Void` — a slow observer can never stall a round.
- **`countRemaining`** (once per round, through the round's signer, never able to throw): KEPT — `transport as? any SyncPullCountTransport` is the 13j `as?` precedent for an optional surface; in production the engine holds the BARE `SupabaseTransport` (`AppServices.makeSyncTransport` → `SyncSession.configure(transport:)` → `SyncEngine(transport:)` — no wrapper, verified at `App/Variorum/Shared/AppServices.swift:174–178, 485–487` and `SyncSession.swift:156`), so the cast succeeds there; the test wrappers (`FaultInjectingTransport`, `GatedSpyTransport`) deliberately lack it and model the undeployed/absent surface. `try?` swallows every failure — a refusal, the 404 before the deploy (`SupabaseTransportError.httpFailure`), a `CancellationError` (the loop's next `Task.checkCancellation()` still ends a retired round) — into `nil`; `askedForTotal` makes it one call per round; the Int64 is `Int(clamping:)`'d.
- **`stagedRowCount` at plan time**: KEPT — one `COUNT(*)` over the stage, read only under `.resume`, in its own read after the plan's (the stage changes only under another round, which the belt refuses at the save).
- **The arming rule**: KEPT — `.resume` arms at plan time (a stage is by definition a long round) and otherwise the first window that comes back FULL (`window.count >= pullWindowSize`) arms, so an everyday round never flashes numbers; a feed of exactly one full window publishes "N of N" once and then saves — harmless. Arming requires `progress != nil`, so a nil-progress caller pays nothing (no count call, no publishes).
- **The save's stride and its first/last publishes**: CHANGED — the stride's and the final publish's `total` was `stopIndex` (the straggler stall point), so on a stall the denominator SHRANK mid-save ("saving 2,000 of 107,990" after "saving 0 of 108,000") and the fraction jumped; D-496 says "`total` = the batch's count", so both now publish `batch.count` (the first publish already did) and `done` ends at `stopIndex` ≤ total on a stall. The first publish BEFORE the shielded transaction (before the belt check and the fixpoint) KEPT — the row turns to "saving" at once; a belt refusal after it shows "saving 0 of N" for a moment, then the retrying face. Stride 1,000 ≈ one publish every ~2.4 s at her ~420 rows/s; the publishes run INSIDE the write transaction on GRDB's writer queue but only spawn a Task onto the actor — never await, never touch the database — so the transaction never waits on a reader (~110 Tasks for her corpus).
- **`Status.progress` cleared with `isSyncing`**: KEPT — nil at the round's start and at its end, both in `runOneRound`; the janitor's early-return road (`deviceLeftBehindReloadRequired`) returns before any pull, so it has no progress to clear.
- **The generation guard**: KEPT — `roundGeneration` increments per round; `publish` drops a stale generation AND anything landing while `!status.isSyncing` (a hop that lands after the round's end in the same generation); the `[weak self]` hop drops publishes onto a deallocated scheduler.
- **`advances`**: KEPT — a later phase wins; the same phase only forward (equal allowed — a duplicate yield, harmless); saving never steps back to downloading; `total` is fixed per phase (now for the save too), so the rule rightly ignores it.
- **`lastErrorIsRetrying`**: KEPT — set only inside the `isOneWriterRefusal(error) && !retired && !isBeltFollowUp` branch, exactly where `followUpRequested` and `nextRoundIsBeltFollowUp` are set, so the flag is true iff a follow-up WILL run; cleared at the next round's start with `progress`. **The brief's question, answered:** on a refused FOLLOW-UP the flag stays FALSE (nothing follows — the R2-6 bound) and `lastError` carries the belt's sentence, so in that one corner (the GUARD scene `theBeltsFollowUpRoundRunsOnceNeverALoop`: a raid on the stage three rounds running — two rounds on one store racing, not a production shape) the row still shows the internal sentence under `.error` until the next trigger. The face has the typed fact `Kind.retrying` needs; whether it wants a SECOND typed fact ("the belt refused and nothing follows") for that corner is U2's/hers — flagged in the self-assessment, not invented here.
- **No new line reads `String(describing:)` or matches a sentence**: KEPT — the only `String(describing:)` is the pre-existing `lastError` write; the flag is typed through `PullStage.isOneWriterRefusal`.
- **`SyncPullCountTransport` · `SupabaseTransport.pullRemaining` · `PullRemainingRequest`**: KEPT — a REQUIRED method with no default (wrappers forward, fakes count — the conformers' standing doctrine); the wire keys `since_seq`/`active_key_id`/`key_proof`/`challenge` match the SQL signature; the bare-integer parse matches PostgREST's scalar result for a `bigint` RPC; a 404 is `httpFailure` → the engine's nil.
- **`PullStage.stagedRowCount`, the fake's two conformers, the sweep row**: KEPT (the fake's count CHANGED in piece 2 to the index-only shape).

#### The close (piece 6)

- `swift build` → "Build complete!" (the tip).
- `swift test --filter "SyncProgressTests|ResumableCatchUpTests|SyncSchedulerTests|AuthRLSDDLTests"` → **"Test run with 118 tests in 5 suites passed"**, 0 skipped (AuthRLSDDLTests 82 · SyncProgressTests 7 · the VX-494 resume suite · the two scheduler suites).
- **The broad core `swift test` (debug), FIRST RUN** (detached `nohup`, foreground bounded waits on its log — `timeout`/`setsid` do not exist on macOS; a `tail -f` is backgrounded by the harness after 180 s, so the wait is an `until … sleep 5` loop under 170 s per call), three test targets, three summary lines:
  - `StringsWorkbookTests`: "Test run with 32 tests in 4 suites passed".
  - `VariorumMCPTests`: "Test run with 468 tests in 85 suites failed … with 1 issue" — the ONE issue is the traps' named load-flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (`ContinuousClock.now - started < .seconds(15)` → 23.19 s under the full-suite load); re-run ALONE → "Test run with 1 test in 1 suite passed after 1.058 seconds". Recorded, never fixed here, as the traps say.
  - `VariorumCoreTests`: "Test run with 3589 tests in 478 suites failed after 249.792 seconds with 8 issues (including 5 known issues)". The 5 known issues are pre-existing `withKnownIssue` arms in the Castle pair suites (`PairCatchUpTests` ×1, `PairInvariantPinsTests` ×4), untouched by this unit. **The 3 real issues were ONE test, and it was MINE to own: `MultiTenantSyncAttackerTests.noOwnershipChangeInstructionExistsOnTheWire`** — the 14c arm-9 WIRE-SURFACE pin that enumerates, by name, every RPC the client calls, every requirement on the transport protocols, and asserts each client RPC is a DEPLOYED function. The adopted draft put `sync_pull_remaining` on the wire (`SupabaseTransport.pullRemaining`, `SyncPullCountTransport`) without touching the pin, and the draft's "green" claims never included a broad run. Grown DELIBERATELY (the pin's own rule — the allowlist extends by exactly the new road, never a relaxation of the blanket scans): `clientRPCs` + `"sync_pull_remaining"`; the protocol requirements + `"pullRemaining"`; the deployed-function scan reads the ONE post-chain function artifact `maintenance/vx495-pull-keyset.sql` by name after the numbered chain (the `AuthRLSDDLTests.postChainFunctionArtifacts` precedent — never the maintenance folder wholesale, whose historical overlays would overwrite the chain's final parameter lists), so the forbidden-word scan (`owner`/`transfer`/`move`/…) now covers the new function's name and parameter list too. Re-run → `MultiTenantSyncAttackerTests` "Test run with 2 tests in 1 suite passed".
- **The broad core `swift test` (debug), SECOND RUN** (after the wire pin's fix): **PENDING** — its three lines land here.

#### The pins (names and counts)

- `AuthRLSDDLTests` (82, two of them this unit's): `theKeysetPullPicksEachTablesPageOffItsIndexThenFetchesUpToTheBound` (the SHAPE B bound pin — replaces the drafted pick-by-id fetch pin), `theCatchUpCountIsAnIndexOnlyReadUnderThePullsGatesForAuthenticatedOnly` (the count pin, R-500-1's shape + no marker WRITE); both RED against 13's body with the artifact unread (piece 4: 12 issues) and GREEN with it laid over. The standing pins `theVisibilityHorizonSurvivesEveryRework`, `pullFiltersEveryTableToTheCallerAndSubtractsTheStampedOwner`, `everyDefinerPathEndsInPgTempOnceTheBeltIsRead`, `aDoctoredChainIsFlaggedByTheSearchPathCheck` run against the laid-over body, byte-unchanged in what they assert (the doctored chain's unbelted ARM drops the VX-495 artifact beside the belt — the fixture, not the assertion).
- `SyncProgressTests` (7): `aMultiWindowCatchUpReportsItsDownloadWithTheServersTotalThenItsSave` · `anOrdinaryOneWindowRoundCarriesNoProgress` · `aTransportWithoutTheCountSurfaceReportsRowsSoFarWithoutATotal` · `aResumedCatchUpCountsTheStagedRowsAsAlreadyDownloaded` · `theCountIsIndexOnlyAndCountsRowsStillInsideTheHorizon` (NEW this session — R-500-1's relation) · `anOrdinaryErrorIsNeverFlaggedRetrying` · `aProgressReadingOnlyAdvances`. New-API pins (piece 4).
- `ResumableCatchUpTests`: `theBeltsRefusalIsFlaggedRetryingUntilItsFollowUpHeals` (the belt flag, D-505; new-API).

#### SELF-ASSESSMENT (the first of the two reviews — what I am least sure of; what the cold reviewer should press on)

1. **The SHAPE B correctness argument rests on per-tenant seq UNIQUENESS across tables** (`Server/supabase/maintenance/vx495-pull-keyset.sql`, the header's "WHY THE BOUND IS EXACT"). `next_tenant_seq` is one counter per owner stamping every synced table's writes (12's `stamp_server_seq()`), and the pre-13y global sequence was unique too. If any path ever stamped two rows of one tenant with one seq (a bulk backfill writing `server_seq` directly, a future per-table counter), a page could carry MORE than `max_rows` rows (harmless to the client, which reads ≥ `max_rows` as full) — never fewer, never a skip. Press on: `12_phase13y_tenant_seq.sql`'s F-S1 wide floor and whether any artifact writes `server_seq` outside the trigger.
2. **The horizon skew between the pick and the fetch** (the header's "THE HORIZON ACROSS THE TWO PHASES"; `AuthRLSDDLTests` pins the per-branch filter three times). I argued fetched-but-unpicked is impossible under the per-tenant counter (write time monotone in seq ⇒ the horizon excludes a SUFFIX of the seq order). That rests on the counter's row lock being held to COMMIT (so a later transaction's rows have later `server_written_at` AND later seqs). Press on: the `next_tenant_seq` body — `update … returning` holds the row lock to commit in Postgres, but a reviewer should read it rather than trust me; and `server_written_at` is `clock_timestamp()` at the trigger, so within ONE transaction rows are stamped in seq order too.
3. **The index-only claim is the planner's, not mine**: `where owner_id = … and server_seq > …` off `idx_owner_seq_<table>` is an index-only scan only where the visibility map is set; a freshly written table pays heap visits until autovacuum/analyze. Her 1,586 ms probe was the horizon-filtered shape; the index-only shape was NOT probed on production (R-500-1 ruled it from the question tool). The deploy checklist should read the count's EXPLAIN once live. Also: `count(*)` per table is still O(rows remaining) by design — asked once per long round; an account ~10× hers could approach the 8 s timeout even index-only, and the client reads a timeout as "no total" (the round goes on).
4. **The engine's `try?` in `countRemaining`** (`Sync/SyncEngine.swift`, `countRemaining`) swallows `CancellationError` by design — but it ALSO swallows a `keyProofEnrollRequired` thrown by the signer AFTER the signer flipped `enrolled = true` on a failed enroll; the next `signer.call` for the pull window would then throw `keyProofEnrollRequired` outright (the signer's once-only enroll). Is that a NEW failure path? No: the signer's enroll runs on the first `sync_pull` call of the round (before any count), so by the time the count runs the round is enrolled or already refused. Press on it anyway: the count is the first NEW call site under the signer since 13y.
5. **The save's progress total CHANGED to `batch.count`** (`SyncEngine.swift`, the apply loop) — D-496's letter, but `SyncProgressTests` has no stall scene, so "done ends at stopIndex < total on a stall" is argued, not pinned. A reviewer may want a pin over the straggler feed (`ResumableCatchUpTests.stragglerFeed`) asserting the saving phase's last reading is `(stallIndex, batch.count)`. I did not add it: the brief's piece 5 asks for the ownership pass, not new scenes, and the stall's progress is cosmetic.
6. **`lastErrorIsRetrying` on the refused follow-up** (`Sync/SyncScheduler.swift`, the catch): FALSE by design (nothing follows), so the double-refusal corner shows the internal belt sentence under `.error` until the next trigger — the VX-505 symptom survives in that one (non-production) shape. U2's face may want a second typed fact; hers to say. Not invented here.
7. **Progress publishes from INSIDE the write transaction** spawn a `Task` per 1,000 applied rows onto the scheduler actor from GRDB's writer queue. I reasoned it never blocks the writer (no await, no database touch). Press on: `publishStatus()` fans out to every `AsyncStream` continuation — the UI's observer — on the actor; cheap, but the save's `Task`s land on the actor WHILE the actor awaits `engine.pull`, which is fine for an actor (reentrancy at the await) — a reviewer should confirm no actor-reentrancy assumption in `runOneRound` reads `status` across that await expecting it unchanged (it sets `isSyncing`/`progress` before the await and after; `publish` writes only `progress`).
8. **`SyncProgressTests` run the fake at horizon 0**, so `done == total` is exact; the new pin covers the relation under a horizon, but no scene drives the ENGINE under a non-zero horizon where `total` (index-only) exceeds the rows served and `done` ends below `total` — again argued, not pinned (the doc on `SyncProgress.total` says it).
9. **The `(` in the body finders** (`AuthRLSDDLTests.lastBody`/`finalBody`) — every `create or replace function <name>(` in the chain is written without a space before the paren and without a `public.` prefix; I checked by the suite going 82/82 (an unmatched name records an Issue). A future artifact writing `function public.name (` would be invisible to the finders exactly as before this change.
10. **Not probed live**: the artifact has never run on a Postgres — the DDL pins are string pins. The deploy (HELD) is where the SQL first executes; the checklist's "pg_get_functiondef reads the new body" and a first live round are the real evidence. A rehearsal on a throwaway is her hands.

## LIVE STATUS (the orchestrator's; flipped per piece)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight whole; worktree + branch; the in-flight row on main (`24c413138`); VX-500 In Progress; this file | DONE |
| 0b | RESUME (the second orchestrator, 2026-11-01 ~13:30 MDT): the handoff + this file + the standard preflight read whole (SyncSpec, CastleRules, SurfaceContracts' Doors, the resiliency protocol, the sizing guidance, the master plan, QUESTIONS' tail); main merged into the branch (`c64211270`); the stage claimed; the roster re-listed via Linear (11 sub-issues — matches); R-500-5 ruled; the U1 split; the U1a brief | DONE (this commit) |
| 1 | U1a — the server artifact (D-495 SHAPE B + the count per R-500-1) + the DDL pins | DONE (`6155ba7fb` SHAPE B · `7d645688f` the count · `1e8d24286` the DDL pins · `917189ccd` the red-on-old) — U1a; the record is `### U1a RECORD` |
| 2 | U1a — the engine's progress seam (D-496) + the belt flag (D-505) + pins | DONE (`86b097934` the ownership pass, one change; the close commit the wire pin) — U1a; the draft `aad734aef` adopted line by line |
| 3 | U1b — the apply PROFILE at scale (D-497 (1)); the FK memo if the profile names it; the chunking memo trued | NOT STARTED (a second Fable session after U1a) |
| 4 | U2 — the faces (D-496's words, D-505's line), the retention clock (D-539/VX-546), the leaf constraint (VX-490) | NOT STARTED |
| 5 | U3 — the typed-unlock retry + the reachability trigger (D-544) | NOT STARTED |
| 6 | The ladder (a fresh `fable-reviewer` over the whole diff; rounds per CLAUDE.md) | NOT STARTED |
| 7 | Closing runs (core debug + release; the Mac suites over every changed source; the phone build) | NOT STARTED |
| 8 | The PR opened — HELD OPEN at her word; the handoff; memory; the canon deltas DRAFTED for the merge moment | NOT STARTED (the CUTOVER handoff `notes/handoffs/vx-500-handoff.md` written 2026-11-01) |

## HELD FOR HER (bundled; nothing here is improvised around)

- **The merge** (the freeze) and **the server deploy** (D-495 + the count RPC) — each at her explicit word.
*[removed for publication]*
- **The words:** P-500-1 the progress lines (her example leads), P-500-2 the sheet's count, P-500-3 the belt's line
  (her draft), the locked row unchanged. P-500-6 (the count's shape) RULED — R-500-1.
- **The directions:** P-500-4 (the retained derived secret over a door), P-500-5 (the reachability trigger), D-497's
  FK memo (zero semantics — built only if the profile names it), the two memos (compaction, chunking) for a sitting.
- **The riders:** VX-546 and VX-490 seated provisionally; VX-76 as VX-496's duplicate; VX-491 not seated.
- **The flags:** VX-683 (data-loss class, two-device same-take edits — her priority call; a `Sync/` design memo run),
  VX-672 (the phone's slow post-purge round — profile on her phone after VM-32), both outside this run.
- ~~**Pre-launch labels:** VX-544 (her call — Castle typed-road users offline); VX-683 (her call).~~ RULED R-500-2: neither is Pre-launch.
