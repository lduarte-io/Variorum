# VX-849 — Run: the typed-over rescue and the offline unlock retry (the sync-custody run)

**STATUS: OPEN — kicked off 2026-11-09 (`/architect-phase vx-849`). Branch `vx-849-typed-over-rescue`, worktree
`~/dev/variorum-vx-849`, the Pro. THIS RUN HOLDS THE ONE SYNC/-CUSTODY SLOT (her kickoff word). The stage
coordinator is nov7 — every stage need goes through them; this orchestrator never claims directly without
checking the queue. CAST (her ruling at this kickoff, verbatim: "opus should implement, fable review"):
Fable orchestrates; a fresh `opus-implementer` per batch at xhigh; a fresh `fable-reviewer` per ladder round
(the Sync/-and-custody class — mandatory). Pin-before-fix PER MEMBER; the cold review covers the whole run's
diff. Commits say `Part of VX-<member>`; no trailers. QUESTIONS #268 records the standing gate: VX-849 lands
before the OSS repo flip.**

## FOR A LATER READER

*Written at closeout. Until then: the kickoff, roster and batches below are the plan; UNIT RECORDS at the
bottom are the night's working record.*

## KICKOFF (2026-11-09, author-attended — her rulings verbatim)

- **The cast (her mid-kickoff word):** "opus should implement, fable review" — Opus implements every batch,
  Fable cold-reviews (the Sync/ class requires the Fable review regardless; her call resolves the
  implementer side the umbrella left open).
- **R-849-1 (resolves P-544-1, was VX-500's P-500-4):** the retained derived-secret shape — "Retain + quiet
  retry". The typed unlock's DERIVED material is held in session memory only (never disk, never keychain,
  dropped at lock/sign-out), and the vault read retries quietly. The one-press "Unlock sync" door
  alternative is retired.
- **R-849-2 (resolves P-544-2, was P-500-5):** the reachability trigger IS built — `NWPathMonitor` in the
  shared `SyncSession`, a transition to connected runs one debounced round. The trigger-only road is
  retired.
- **R-849-3 (the riders, her picks at the kickoff check):** VX-402, VX-152 and VX-545 ride. On VX-152 her
  condition, verbatim: "for vx-152 - since it's suspected, you can investigate it, but if it seems like it's
  going to add a lot of work to this run, add the extra info to the ticket and leave it out."
- **Sequencing inherited from the umbrella (her word 2026-11-04 + the VX-912 kickoff sitting 2026-11-08):**
  VX-683 FIRST (the data-loss class); this run is SYNC EFFORT 2, started now that VX-912 released the slot;
  VX-443 joined as a member at the VX-912 sitting (the B0 flag pass promoted it High — the stale-key class
  she just closed server-side).

## THE ROSTER (the sub-issue listing at kickoff — the VX-548 rule — plus her seated riders; re-list before the ladder)

| # | Ticket | What | The ruled design / pointer |
|---|---|---|---|
| 1 | **VX-683** (Med · Bug · Suspected) | a pull applied into the autosave debounce window is overwritten — the remote words survive nowhere | RULED R-683-1…4, `notes/plans/fixes/vx-683-sync-into-debounce.md` (option C = flush-first A + guarded autosave B; rescue direction (i); the rescued take wears `'conflict'`; flush only when typing pending) |
| 2 | **VX-402** (Med · Bug · Suspected, RIDER) | `AutosaveCoordinator.flushNow` returns early while a write is in flight — flush-first doors can act on pre-keystroke text | fix shape per the ticket: the helper awaits the in-flight write, not only the pending batch; trace `notes/plans/fixes/vx-382-ladder-round-1.md` R1-3. Load-bearing for batch 1's flush occasion |
| 3 | **VX-544** (Med · Bug · Confirmed) | the offline typed unlock leaves sync locked all session | D-544, `notes/plans/fixes/vx-544-offline-typed-unlock.md` (the plan + THE BRIEF are there, carried whole); P-544-1/-2 now RULED (R-849-1/-2 above) |
| 4 | **VX-664** (High · Bug · Confirmed) | a live pane whose take changes from OUTSIDE keeps the old words and writes them back | HER RULING 2026-10-28 (on the ticket): option (a) scoped — the ring ends ONLY when an outside write lands on the live pane's OWN take; every outside-change road gets the ring-ending shape (VX-222/VX-440's); P-3 never bent; no clean-buffer adoption. R-683-4 folds its remaining half here (the pane's face right after a rescue, walked) |
| 5 | **VX-443** (High · Debt · Confirmed) | today's store-id envelope (`variorum-keys-<storeID>.json`) beside the slot keeps the pre-crossing key — unread on the new road | `notes/plans/vx-307-castle-crossings.md` §6 U2a F-5; the B0 flag pass (`notes/plans/fixes/vx-912-b0-security-verify.md` flag 1): sweep or re-mint, the VX-508 class client-side |
| 6 | **VX-152** (Med · Bug · Suspected, RIDER) | `AppBootstrap.lock()` has no reentrancy guard — sleep + screen lock together can double-flush and mount two lock screens | investigate-first at her R-849-3 condition; custody machinery proper (the lock/flush road) |
| 7 | **VX-855** (High · Bug · Suspected) | purge sweep's pool reader races pool teardown — SIGSEGV in the SQLCipher codec at quit/teardown | the .ips trace on the ticket (`PurgeJanitor.collectRoots ← LocalPurge.sweep ← AppDatabase.read` under `DatabasePool.reader` at teardown). TRACE FIRST — reproduce (launch-then-quit with purgeable tombstones), pin as the confirm; the fix likely where teardown orders the pool close against in-flight background reads |
| 8 | **VX-545** (Low · Wording · Confirmed, RIDER) | rule 7's ratified sentence family ("…the old ones still open backups made with them") | the ticket lists the five touch points: CastleRules rule 7 + banner line · `ProtectionWords.swift:727` · two doc comments · the lifecycle fixture + regenerate the html (never hand-edit) |
| 9 | **VX-921** (Low · Debt · Confirmed) | the OWNED exclusivity repair still ranks by `sync_row_seq` — the determinism gap tier 3 just left | the created_at swap on the B2 worked pattern (`notes/plans/fixes/vx-912-open-source-gating.md` B2 record, P3) with its own red-on-old convergence pin: two devices ranking DIFFERENT claimants under seq, the SAME under created_at |
| 10 | **VX-919** (Low · Improvement · Confirmed) | device_cursor cap belt — bound live device rows per account at 64, oldest `seen_at` evicted (the `sync_challenge` pattern) | `notes/plans/fixes/vx-912-b0-security-verify.md` (the recorded corner). A SERVER maintenance script, NOT a lockstep (no client schema); AUTHORED in this run, the production deploy HELD for her window — a server act runs only at her word |

## THE BATCHES (one fresh Opus implementer each; order = the build order)

| Batch | Members | Unit + evidence |
|---|---|---|
| 1 | VX-683 + VX-402 | the guarded autosave (B) + the `beforeRound` hook seam + the flush-before-apply occasion (A) + the honest flush. Evidence: B's red-on-old state-transition pin; A's two-client convergence pin (a pull into a simulated debounce window; the round ends with the server text on the row, her text the `'conflict'` take, both pushing); VX-402's own pin (a flush awaits the in-flight write) |
| 2 | VX-544 | D-544 whole (the pending load · the retry · the hook occasion · the reachability trigger) per the vx-544 plan's BRIEF, P-544-1/-2 read as RULED (R-849-1/-2). Evidence: the planted-road pins (compile-red vs behavior-red said plainly); the live confirmation is HER HANDS (the two-Mac test's steps 8–9 on her Air) — recorded as OWED, never claimed |
| 3 | VX-664 | the ring-ending shape on every outside-change road (her option (a) scoped), composed with batch 1's rescue so the pane's face right after a rescue is right (R-683-4). Evidence: red-on-old pins per road (the vx-440 `RestoreLandingTests` shape extended); the orchestrator's hands-on walk |
| 4 | VX-443 + VX-152 + VX-545 | the custody smalls: the envelope sweep/re-mint; the reentrancy guard (investigate-first, her condition); rule 7's five touch points + the lifecycle regeneration. Evidence: a pin per member (VX-152's only if confirmed); the words byte-pinned |
| 5 | VX-855 | TRACE FIRST (Suspected): reproduce the teardown race, pin as the confirm (red confirms, green = record-only), then the ordering fix. Evidence: the repro pin red-on-old by behavioral revert |
| 6 | VX-921 + VX-919 | the rank swap + convergence pin; the cap-belt script authored (deploy HELD). Evidence: the convergence pin red on the seq rank; the script reviewed in the ladder, never run against production |

Then: the LADDER over the whole run's diff (a fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md`
verbatim, rounds per CLAUDE.md); the closing Mac runs over every changed source; the closeout ritual.

**Stage needs (through nov7):** every `xcodebuild test` run; batch 3's walk; any dev-store launch for
VX-855's repro. Headless `swift build`/`swift test` run freely in the worktree.

**SyncSpec §12 check:** NOTHING in this run is a lockstep event — no client schema change, no marker bump.
VX-919's script is server maintenance (the VX-495 class), deploy at her window only.

## THE CONSTITUTION (P-1…P-9, carried byte-verbatim per the architect shape; binding)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette),
  and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view
  if-statements. A registry-walk test asserts every declared door exists and every rendered door is
  declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction
  instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch
  choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can
  never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one
  measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live
  editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling
  implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested
  authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live
  pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something
  happened (mode changed, post opened); no listener derives business state or availability from a broadcast,
  and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition.
  (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected
  feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole,
  edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the
  product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at
  design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every
  happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any
  change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist),
  the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they
  bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays,
  never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class).
  `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in
  the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and
  gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

## ENVIRONMENT TRAPS (carried verbatim from VX-500's plan; binding on every session of this run)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches
mid-run); inside a command that names the app's path use `pgrep -x Variorum`. Real-store instances are treated
by STORE, never quit or killed; no Release build or `/Applications` refresh while one lives. Headless
`swift build`/`swift test` need no stage; EVERY `xcodebuild test` needs a HELD `Tools/stage` claim
(`--minutes` up to 240); Mac tests from `App/Variorum/` with suite-level `-only-testing`, confirm the "Test
run with N tests" line; never a custom build configuration. Swift Testing's count includes skipped tests. The
core suite's known load-flakes: `MCPHarnessTimeLimitTests.aPeerThatNever…` (named), VX-722, VX-723
(Suspected). Commit per piece, push after every commit, LIVE STATUS flipped in the same commit, PENDING on
every unverified claim; foreground waits only; never `git checkout` over uncommitted work; a behavioral revert
is named in the record BEFORE it runs, at a committed tip. The orchestrator writes nothing in the worktree
while an implementer or reviewer is live there (drafts in the scratchpad; pathspec adds only — the VX-500
lesson). No subagents for implementers. No store, no server contact. **This run's addition: the stage is
nov7's queue — ask before every claim; this run holds the SYNC SLOT, so no other Sync/-or-custody effort runs
beside it.**

## STAGE & COORDINATION (nov7's grants and mains moves, 2026-11-09 — binding on every session of this run)

- **The Sync/-custody slot is GRANTED to VX-849 in writing** (nov7, per her word; verified: vx-926/vx-940/vx-915
  touch zero Sync|Protection/keychain/custody files; vx-913 has no code yet). The slot releases only on this
  orchestrator's "nothing further owed" at the hard stop.
- **Watch item:** vx-913's VX-81 (SwiftUI crash on the re-key reopen) is trace-first elsewhere; if its trace
  reaches Protection/custody code, nov7 stops it and routes to her. If a batch here meets VX-81's neighborhood,
  tell nov7 at once.
- **Merges serialize through nov7;** the second merger merges main in and re-proves on the merged tree — for this
  run that includes re-proving convergence over the beforeRound hook × VX-912 straggle-belt seam (the belt was
  already in this branch's base, bd163ea54; the batch-1 convergence pins ran against it).
- **The vx-915 overlap (nov7, 2026-11-09):** vx-915's batch 3 (VX-841) changes `AppSession.swift` (+9/−2, a
  macOS-only block); the shared files between the two runs are now AppSession.swift · CompareBoardView.swift ·
  TakesViewModel.swift; the trial merge is textually CLEAN. WHICHEVER RUN MERGES SECOND runs the WHOLE Mac +
  phone suites on the MERGED tree AND eye-reads AppSession's merged body — carried into this run's closing sweep
  (LIVE STATUS row 8) and the closeout checklist.
- **Stage protocol (every window):** REQUEST (what/minutes/claim name, sent EARLY) → READY (able NOW) → GO only
  from nov7 with the exact claim line → RELEASE with Executed counts and EVERY failing test by name (faulting
  thread read for any crash). `-only-testing` takes TYPE names as a zsh array. Instance checks: `pgrep -lx
  Variorum`, `pgrep -lf "MacOS/Variorum$"`. A window over an hour pings SEAM. **NO HEAVY HEADLESS WORK while
  another session's stage window is live** (nov7's rule, 2026-11-09: no whole-package/whole-target `swift test`,
  no whole MCP target, no full or cold `build-for-testing`; small targeted runs are fine; heavy closes are held
  for a gap or the orchestrator's own window — an implementer marks them PENDING and lists them).
- **Dev-store windows** (VX-855's teardown repro, the batch-3 walk) serialize against vx-913's VX-81 re-key
  repro. Each window leaves the dev store's posture as found: MCP ON, variorum-de approved, never Resume Sync,
  Castle values only from `~/.variorum/dev-castle.env`, restored or reported at RELEASE.
- **Fable safeguard (her memory rule):** any walk that meets the lock screen or a passphrase is handed to an
  OPUS session; Fable reviews the code, never drives the walk.
- **The custody drill's steps 8–9** need HER Air and hands — held and bundled as an ask, never routed around.
- **Lockstep:** nothing in this run is a §12 event (confirmed at kickoff); if that changes, the migration/marker
  is reserved with nov7 FIRST and the mirror deploy runs only on her explicit go.
- **Mains folded in at the batch-1 seam (merge `1f8f25a37`; the batch-1 core pins re-run green on the merged
  tree, 11/11):** 66d6f33cf (VX-931, docs only) · 159e12ac0 (board snapshot) · 744ca5301 (vx-913's no-trailer
  guard: attribution off + a PreToolUse hook DENYING any git commit / gh pr command whose TEXT carries an
  attribution trailer — keep those words out of commit messages entirely; nov7 scans for trailer lines at each
  merge GO).
- **HER RULING AT VX-931, binding on this run's closeout: /Applications holds RELEASES only.** No /Applications
  refresh at this run's merge or closeout — merged work is tested in the DEBUG app, and the wave's release
  installs it. An interim build goes there only at her explicit word, under the label she names.

## LIVE STATUS (the orchestrator flips rows; implementers flip their batch rows in their own commits)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight whole · worktree + branch · her rulings repo-first · the in-flight row · Linear flips (run In Progress; riders seated as sub-issues) · nov7 announced | DONE (this commit) |
| 1 | Batch 1 — VX-683 + VX-402 (the rescue + the honest flush) | DONE — built `03d1fed00`…`bdb70dc3d`; the stage window ran 2026-11-09 (claim vx-849-batch1): leg A 22/22 · leg B six reverts proven (the adjudication's window record) · leg D 116/10 green on the sim; worktree clean at tip throughout |
| 2 | Batch 2 — VX-544 (the offline unlock retry) | DONE — built `b11fb8d39`…`36b709512` + the window fix `f500f94f3`; the stage window ran 2026-11-09 (claim vx-849-batch2): leg A 41/41 at `f500f94f3` after one test-only fix (the WINDOW record below) · leg B R-3a red on exactly its five named pins, restored 18/18 · leg D 7/7, R-3g red on exactly its one pin, restored 7/7; leg C folds into row 8's closing sweep; her drill OWED (row 9) |
| 3 | Batch 3 — VX-664 (the outside-change ring-ending) | IN-PROGRESS — piece 1 (the sweep table) DONE; pieces 2–5 per the BATCH 3 RECORD |
| 4 | Batch 4 — VX-443 + VX-152 + VX-545 (the custody smalls) | NOT STARTED |
| 5 | Batch 5 — VX-855 (the teardown SIGSEGV, trace-first) | NOT STARTED |
| 6 | Batch 6 — VX-921 + VX-919 (the rank swap + the cap script) | NOT STARTED |
| 7 | The ladder (fresh `fable-reviewer`; rounds per CLAUDE.md) | NOT STARTED |
| 8 | Closing Mac runs over every changed source · PR · closeout ritual · FOR A LATER READER | NOT STARTED |
| 9 | Her drill: the two-Mac test's steps 8–9 on the Air — runs AFTER the release reaches the Air via Sparkle (her word, 2026-11-09) · VX-919's deploy window (HELD) | OWED |

## BATCH 1 BRIEF — the typed-over rescue (VX-683, R-683-1…4) + the honest flush (VX-402)

**Who you are.** The implementer for batch 1, an Opus subagent at xhigh; `.claude/agents/opus-implementer.md`
binds you point for point. Worktree `<home>/dev/variorum-vx-849`, branch
`vx-849-typed-over-rescue`. This batch TOUCHES `Sources/VariorumCore/Sync/`'s seams and `Operations` —
SyncSpec is read IN FULL before any line. Fable cold-reviews the run; your self-assessment closes the batch.

**Read first, in full:** `CLAUDE.md` + its canon (auto) · THIS FILE whole · `notes/plans/fixes/vx-683-sync-into-debounce.md`
WHOLE (the memo: the mechanism, options A/B/C as ruled, R-683-1…4, the evidence shapes) ·
`notes/SyncSpec.md` IN FULL (§4–§6 are your seams: the apply's locally-clean path, the merge matrix, S5) ·
`notes/plans/fixes/vx-544-offline-typed-unlock.md` §THE DESIGN build step 3a only (the `beforeRound` hook's
shape — YOU mint the hook; batch 2 wires its retry occasion onto it) · `notes/SessionResiliencyProtocol.md`
§implementer · the code: `Sources/VariorumCore/Operations/` (autosave; the `bufferChangedSinceGesture`
precondition family), `Sources/VariorumCore/Sync/` (the apply road; `resolveSyncConflict`),
`App/Variorum/Shared/SyncSession.swift` (`triggerSync` ~:195, `flush` ~:237), the autosave coordinator
(`AppSession.autosave(forPost:)` / `AutosaveCoordinator` — grep `flushNow`), the two-client fake-server
harness (grep `FakeSyncServer` under `Tests/`), and the vx-382 ladder's R1-3 trace
(`notes/plans/fixes/vx-382-ladder-round-1.md`) for VX-402.

**The pieces, in order (commit per piece, `Part of VX-683` / `Part of VX-402`; push each):**

1. **VX-402 — the honest flush.** `flushNow` (and any flush-first helper the doors share) awaits the
   in-flight write, not only the pending batch. Pin red-on-old: a flush called while a debounced write is in
   flight returns only after that write landed (old: returns at once; drive it with a scripted/slow write).
   This piece is FIRST because piece 3's occasion stands on it.
2. **VX-683 B — the guarded autosave.** `Operations.autosave` gains the expected-text precondition (the
   editor seam's last-adopted snapshot rides the call). A stale autosave — the row changed under it — does
   not blind-write; it RESCUES per R-683-1: HER BUFFER KEEPS THE ROW; the displaced words become a new take
   on the same block, label `'conflict'` (R-683-2), same parent, fan's end — exactly where an S5 card lands.
   Both texts survive; both push; no new schema, no §7 repair, no savepoint occasion (the memo's
   "deliberately does not do" list binds). Pin red-on-old (the memo's shape): autosave with a stale expected
   text on a row a fake apply just rewrote — old overwrites, new rescues both texts; revert-proven. Exact
   state-transition tests for the operation.
3. **VX-683 A — the flush-before-apply occasion.** `SyncSession.triggerSync()`/`flush()` gain the optional
   `beforeRound: (@MainActor () async -> Void)?` hook (nil = inert — the `keyProvider` pattern; injected at
   composition, zero engine knowledge of editors). The Mac composition wires it to flush every live editor's
   pending buffer through the (now honest) flush — ONLY when typing is pending (R-683-3: one cheap check;
   quiet rounds stay zero-cost on the main thread). After the flush the row is dirty and the EXISTING §5/§6
   machinery does the rest (server text wins the row, her flushed text becomes the conflict take, the pane
   adopts). Pin: the convergence suite's shape — the two-client fake-server harness drives a pull INTO a
   simulated debounce window (the hook seam lets the test inject "pending buffer exists"): the round ends
   with the server text on the row, her text as a conflict take, the outbox pushing both. A sync change
   without a convergence test is unreviewed (AppSpec §15.3).
4. **Close.** `swift build`; `swift test` over every touched suite (headless — no stage needed); the
   self-assessment: say exactly which window remains open (the milliseconds between flush and apply — B
   covers it) and every road the guarded autosave now rescues (sync, MCP mid-window, a second window).

**Your record:** `### BATCH 1 RECORD` under UNIT RECORDS below; LIVE STATUS row 1 flipped in your commits;
compile-red vs behavior-red said plainly; first line = what you did NOT do. **Not yours:** VX-664's ring
work (batch 3 — do not touch `PaneSurface`/`PaneTextAuthority` beyond reading); VX-544's retry (batch 2);
the ladder; the PR. **ENVIRONMENT TRAPS above, binding verbatim.** No subagents. Foreground waits only.

## BATCH 2 BRIEF — the offline typed-unlock retry (VX-544, D-544; R-849-1/-2 RULED)

**The binding brief is `notes/plans/fixes/vx-544-offline-typed-unlock.md`'s "THE BRIEF" section, read WHOLE with
its PREFLIGHT FACTS and D-544 — with these OVERRIDES, which win where they differ:**
1. **Worktree `<home>/dev/variorum-vx-849`, branch `vx-849-typed-over-rescue`** (the run's one
   branch; the vx-544 plan's own worktree/branch lines are superseded by the bundling).
2. **You are an OPUS implementer** (her cast ruling at this run's kickoff: "opus should implement, fable
   review"); `.claude/agents/opus-implementer.md` binds you.
3. **P-544-1 and P-544-2 are RULED, not provisional** (this file's KICKOFF: R-849-1 retain + quiet retry;
   R-849-2 the reachability trigger IS built). Build both; log nothing to QUESTIONS for them.
4. **The `beforeRound` hook EXISTS** (batch 1, `bdb70dc3d`): D-544 build step 3a's hook half is DONE. Your
   occasion (a) is a SECOND composition-level use: in `AppServices`' Mac composition, run the retry BEFORE the
   existing flush occasion inside the one wired closure — gated by "only while the provider cannot produce keys"
   (one cheap `currentKeys()` try, so an unlocked session pays nothing). Do not add a second hook property.
5. **P-849-2 rides with you (same files):** check whether the PHONE composition offers the same one-line seam for
   batch 1's FLUSH occasion; wire it only if it is truly that one line (the guarded autosave B already protects
   the phone either way), else record the fact plainly for the MOBILE PARITY line. The phone's RETRY stays
   unwired (D-544's posture, unchanged).
6. **Commits say `Part of VX-544`** (drop the vx-544 plan's older `VX-500 U3:` prefix); record `### BATCH 2
   RECORD` under UNIT RECORDS here; flip LIVE STATUS row 2 in the same commits.
7. **The stage is NOT yours to claim or check:** this batch builds and pins headless (`swift build`, core
   `swift test`, `xcodebuild build-for-testing`); every `xcodebuild test` run is the ORCHESTRATOR'S, after your
   close, through nov7's queue. List the suites to run (type names) at the end of your record.
8. **Her drill (the two-Mac test's steps 8–9 on her Air) stays OWED** — record it as owed, never claimed
   (LIVE STATUS row 9). The live confirmation is hers.
9. **THE STAGE & COORDINATION section above and ENVIRONMENT TRAPS bind you**; this file's CONSTITUTION too.
   CastleRules is read WHOLE before any line (custody-adjacent: the derived secret lives in session memory only).

## BATCH 3 BRIEF — the outside-change ring-ending (VX-664, her option-(a) ruling) + the post-rescue face (R-683-4) + P-849-1

**Who you are.** The implementer for batch 3, an Opus subagent at xhigh; `.claude/agents/opus-implementer.md`
binds you. Worktree `<home>/dev/variorum-vx-849`, branch `vx-849-typed-over-rescue`. THE EDITOR
SEAM: `PaneSurface`, `PaneTextAuthority`, `TakesViewModel` and their kin — Fable cold-reviews this class, and
`notes/TEXTKIT2_NOTES.md` is read WHOLE before any line. ZERO lines under `Sources/VariorumCore/Sync/` — if the
ring work seems to need a seam there, STOP and record (the orchestrator adjudicates).

**Her ruling, the one you build to (2026-10-28, on ticket VX-664, verbatim-faithful):** option (a), SCOPED — the
ring ends ONLY when an outside write lands on the live pane's OWN take; every outside-change road gets the
ring-ending shape (VX-222/VX-440's); P-3's live-pane buffer authority is never bent; NO clean-buffer adoption,
now or later — her words: "I agree it would be bizarre to have an AI live editing the same exact take as you …
variorum is not a 'we're all editing the same text at the same time' kind of editor like google docs."

**Read first, in full:** CLAUDE.md + canon (auto) · THIS FILE whole (the KICKOFF rulings; batch 1's record — the
rescue you compose with; both adjudications; STAGE & COORDINATION; ENVIRONMENT TRAPS; CONSTITUTION, P-3
especially) · `notes/TEXTKIT2_NOTES.md` WHOLE · `notes/SurfaceContracts.md` §"The note" · the W-1 sections of
`notes/plans/fixes/vx-440-sheets-history-clarity.md` (the TRACED mechanism ~line 805, the general class, the
narrow fix WF-2 `TakesViewModel.consumeRestoreLanding`) · VX-248's landed shape (grep `rebindIfTakeChanged`) ·
the History surface's restore roads (`notes/plans/fixes/vx-827-lineage.md` FOR A LATER READER only) · the code:
`PaneTextAuthority`, `PaneSurface`/`PaneSurfaceRepresentable`, `TakesViewModel` (the ring, `run`, the restore
landing), the Lenses board's twin, Compare's columns, Canvas, Write's take panel, `AppSession`'s apply/adoption
road for sync writes, and `Operations.restoreCommitRows` (the insurance gap P-849-1 names).

**The pieces, in order (commit per piece, `Part of VX-664`; push each):**

1. **THE SWEEP TABLE FIRST (the class-completeness discipline):** enumerate every road that rewrites a take's
   `working_text` from OUTSIDE a live pane bound to that take, × every host surface a live pane can sit on
   (Takes · Lenses · Compare · Canvas · Write's take panel · Read's edit face · a second window). Known roads
   from the W-1 record: the History/Commits-face restore (fixed on Takes+Lenses at vx-440 — verify, then
   generalize), the same restore beside Compare/Canvas/Write's panel, another window's restore, a sync apply of
   `working_text`, the MCP door's `edit_take`/`restore_commit`, the Lineage face's acts that write the SAME take
   (most mint new takes — verdict those N/A with the mechanism said). The table lands in your record BEFORE the
   fix: instance × host, each cell FIXED-with-named-pin or provably N/A.
2. **ONE ring-ending seam, not per-road patches:** generalize the vx-440 shape (the landing ends the ring over
   the written take) into one declared mechanism beside the liveness authority — "an outside write landed on the
   live pane's own take ⇒ the ring ends there" — that every road in the table routes through. P-3 untouched: the
   pane stays buffer-authoritative while live; ending the ring is what makes it a read pane that adopts. The
   sync-apply road composes with batch 1: a flush-first round means her typing already landed (no rescue), and
   the apply's write then ends the ring so the pane shows the applied text; the millisecond stragglers rescue as
   batch 1 built (her buffer keeps the row) — in THAT case the ring deliberately does NOT end (nothing landed on
   the row from outside; the displaced words went to a new take). State this composition in your record.
3. **P-849-1 (PROVISIONAL — her re-cut may land mid-run; keep this piece isolated and cheap to flip):** the
   board's own restore doors (Takes' `restoreCommit` road and its Lenses/History-surface twins — the doors that
   REWRITE the typing take's text; enumerate them in the sweep) flush pending typing FIRST through the honest
   flush, keep ONE quiet `kind='auto'` insurance savepoint of the flushed words when the act is about to replace
   them (`restoreCommitRows` has no insurance of its own — verified at the batch-2 era; the MCP bracket is the
   precedent), then act; the ring-end (piece 2) makes the pane adopt the result. A deliberate act of hers then
   never meets a stale buffer and never mints a `'conflict'` card.
4. **R-683-4 — the post-rescue face:** stage the sync-road rescue (batch 1's) under a mounted live pane and pin
   the face: the pane keeps her words, the `'conflict'` take appears in the fan, the corner badge and the open-fan
   memory behave, the board's comments/geometry hold. Fix what the pins reveal; anything product-flavored goes to
   the record as PROVISIONAL, never invented.
5. **Pins:** red-on-old per fixed cell (the `RestoreLandingTests` shape extended; name each pin beside its table
   cell); `swift build` + both `build-for-testing`s; headless core where touched. NO `xcodebuild test`, NO stage —
   list the Mac/sim suites (type names) and the named reverts for the orchestrator's window at your record's end.
   The orchestrator WALKS this batch (UI-kind) after the window.

**Your record:** `### BATCH 3 RECORD` under UNIT RECORDS; LIVE STATUS row 3 flipped in your commits; the sweep
table; first line = what you did NOT do. **Not yours:** the stage; VX-443/VX-152/VX-545/VX-855/VX-921/VX-919's
files; `Sync/`. **ENVIRONMENT TRAPS and STAGE & COORDINATION above bind verbatim.** No subagents; foreground
waits only.

## BATCH 4 BRIEF — the custody smalls: VX-443 (the stale envelope) + VX-152 (investigate-first) + VX-545 (rule 7's sentence)

**Who you are.** The implementer for batch 4, an Opus subagent at xhigh; `.claude/agents/opus-implementer.md`
binds you. Worktree `<home>/dev/variorum-vx-849`, branch `vx-849-typed-over-rescue`.
CUSTODY/KEYCHAIN CLASS — `notes/CastleRules.md` is read WHOLE before any line; Fable cold-reviews. ZERO lines
under `Sources/VariorumCore/Sync/`.

**Read first, in full:** CLAUDE.md + canon (auto) · THIS FILE whole · `notes/CastleRules.md` WHOLE ·
`notes/SurfaceContracts.md` §"Doors to the outside" (the protection bullet — the pre-design face's detection
sentence especially) · `notes/plans/vx-307-castle-crossings.md` §6's F-5 finding + U2a ARBITRATION (the envelope's
provenance: `variorum-keys-<storeID>.json`, `ensureStoreIdentity`, today's-road backups copied it) ·
`notes/plans/fixes/vx-912-b0-security-verify.md` flag 1 (why VX-443 is High) · the code:
`Sources/VariorumCore/Persistence/LibraryClassifier.swift` (`olderFingerprintKeyFilePrefix` — the pre-design
detector keys on exactly this name class), `Sources/VariorumCore/Protection/Assess/CatalogNames.swift`, the
new-road open's landing (where a successful open of the live library settles — the rule-8 re-makes moment), and
for VX-152: `AppBootstrap` (`lock()`, the sleep/screen-lock monitors) · for VX-545: the ticket's five named touch
points (its description lists exact files and lines; the ticket body is in Linear — the five points are also
quoted below).

**The pieces (commit per piece, `Part of VX-<member>`; push each):**

1. **VX-443 — sweep the stale envelope (direction: DELETE, gated; PROVISIONAL P-849-4 for her bundle).**
   `ensureStoreIdentity` died with today's road (zero production hits — verified at this brief's writing), so the
   13p-era store-identity envelope beside the slot is pure dead weight holding the pre-crossing key under locks a
   crossing retired — the exact stale-key class she just cleared server-side (VX-508), and its NAME is the very
   pattern the pre-design classifier detects, so it is also a latent ambiguity (lose this design's key file and
   the leftover makes a new-road store read pre-design). The sweep: at a SUCCESSFUL new-road open of the LIVE
   library (the rule-8 re-makes moment — the open itself is rule 22's verification that the current pair works),
   delete a today's-road envelope beside the slot that matches the old pattern for names-only reasons (NEVER read
   its contents). Fences, each pinned: fires only on the live slot (never Previous Libraries, never backups, never
   a Look-inside copy, never a picked folder); fires only when THIS design's key file is present and just opened
   the library; a PRE-DESIGN store (an old-name file and NONE of this design's) is never reached (the face shows
   instead — pin the detector unchanged); the deletion is said once in the log, names only. Red-on-old: a planted
   old-name envelope beside an opened new-road library survives the open on the old tree, is gone on the new.
   Record the delete-vs-keep alternative honestly (rule 4 already carries every earlier key in the current file,
   so nothing openable is lost — that is WHY delete is safe; the alternative, set-aside, mints a new place keys
   live, which CastleRules' shape avoids).
2. **VX-152 — the lock reentrancy, INVESTIGATE-FIRST (her condition, verbatim in this file's KICKOFF: "since
   it's suspected, you can investigate it, but if it seems like it's going to add a lot of work to this run, add
   the extra info to the ticket and leave it out").** Trace `AppBootstrap.lock()` under sleep + screen lock
   arriving together: can it double-flush / mount two lock screens? If the trace lands and the fix is a cheap
   guard (a reentrancy flag on the lock road) with a red-on-old pin — build it. If it balloons (a redesign of the
   teardown ordering, overlap with VX-855's territory) — write the traced facts INTO THE TICKET (hand the text to
   the orchestrator for Linear) and leave it out of this run. Say which way it went as your record's first line
   for this piece.
3. **VX-545 — rule 7's ratified sentence, five touch points in ONE commit:** CastleRules rule 7's adoption
   sentence ending becomes "the old ones still open backups made with them" (her ratification, QUESTIONS #241) +
   a status-banner line naming this landing; `App/Variorum/Shared/Protection/ProtectionWords.swift:727` (the
   shown-words arm); the doc comments at `RoadAccountModel.swift:58` and
   `Sources/VariorumCore/Protection/Executor/PlanRunner.swift:33`; the lifecycle fixture
   (`Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/LifecycleFixture.swift:877`) — then REGENERATE
   `notes/plans/vx-266/castle-lifecycle.html` from the fixture (NEVER hand-edit it). The byte-pin
   (`RoadAccountWordsTests.rule7sSentencesAreHersVerbatim`) moves by JUSTIFIED EDIT to the ratified text. Verify
   the 13u-era label fence still holds (the app says "commit"; this sentence is protection copy, not commit
   vocabulary — nothing else reworded).
4. **Close:** `swift build` · headless `swift test` over every touched core suite (the lifecycle/scenario suites
   run headless) · both `build-for-testing`s. NO `xcodebuild test`, NO stage — list the Mac suites (type names)
   and any named reverts for the orchestrator's window at your record's end.

**Your record:** `### BATCH 4 RECORD` under UNIT RECORDS; LIVE STATUS row 4 flipped in your commits; first line =
what you did NOT do. **Not yours:** the stage; batches 3/5/6's files; `Sync/`. **ENVIRONMENT TRAPS and STAGE &
COORDINATION above bind verbatim.** No subagents; foreground waits only.

## BATCH 5 BRIEF — the purge-sweep/pool-teardown SIGSEGV (VX-855, TRACE-FIRST — Suspected)

**Who you are.** The implementer for batch 5, an Opus subagent at xhigh; `.claude/agents/opus-implementer.md`
binds you. Worktree `<home>/dev/variorum-vx-849`, branch `vx-849-typed-over-rescue`. SYNC/-CLASS
(`PurgeJanitor` lives in `Sources/VariorumCore/Sync/`) — `notes/SyncSpec.md` is read IN FULL before any line;
Fable cold-reviews. VX-855 is SUSPECTED: the pin is the CONFIRM — red confirms and the fix proceeds; green means
RECORD-ONLY (the traced findings into your record for the orchestrator to put on the ticket; no fix on a trace
that never bit).

**The evidence (the ticket's one .ips, quoted here because implementers have no Linear):** the Debug TEST HOST
(build 11051, 2026-11-05), crashed 4.4 s after launch, AFTER its test bundle had already passed — teardown, not a
test; no VariorumTests frame on any thread. EXC_BAD_ACCESS / KERN_INVALID_ADDRESS (possible ptrauth failure) on
thread `GRDB.DatabasePool.reader.1`: `sqlcipher_memset ← sqlite3Codec ← readDbPage … sqlite3_step ← fetchAll ←
PurgeJanitor.collectRoots(tombstoneRoots) ← LocalPurge.sweep(afterFamily:) ← AppDatabase.read`. Suspected
mechanism (UNCONFIRMED): the launch-time background purge sweep holds an in-flight POOL READER while the pool (or
its codec key context) is torn down — quit, test-host termination, plausibly the Castle lock's teardown — a
use-after-free in the codec context. Data-safe (a read), but a "Variorum quit unexpectedly" class reachable by
quitting (or locking?) within seconds of a launch that has tombstones to sweep. Adjacent: VX-818's MacWillLock
teardown ordering landed in the same neighborhood — read its landed shape before concluding anything about the
lock road.

**Read first, in full:** CLAUDE.md + canon (auto) · THIS FILE whole · `notes/SyncSpec.md` IN FULL · the purge
design's sweep/horizon sections (`notes/plans/phase-13j-purge-memo.md`) · the code:
`Sources/VariorumCore/Sync/PurgeJanitor.swift` (`collectRoots`), `Operations+Purge.swift` (`LocalPurge.sweep`),
the pool's close road (`Sources/VariorumCore/Persistence/` — where the pool closes at quit/lock), the app
teardown (`AppBootstrap`'s lock and quit roads; grep `QuitPurgeQuiesceTests` — the standing quiesce pin suite,
your closest precedent), and every `LocalPurge.sweep` caller (the launch road that starts the background sweep).

**The pieces, in order (commit per piece, `Part of VX-855`; push each):**

1. **THE TRACE + THE REPRO PIN (the confirm).** Trace the teardown order in code first: who closes the pool /
   drops the codec context, and what (if anything) waits for the sweep's in-flight reader. Then the repro,
   HEADLESS-FIRST: a core-level Swift Testing pin that drives the sweep's read on a pool while the store tears
   down (close/key-drop) mid-read — DETERMINISTICALLY (hold the read open with a plant, then tear down), never a
   timing lottery. RED confirms the class. If the class only reproduces in-app at quit, say so plainly and record
   the dev-store repro recipe for the ORCHESTRATOR'S window (launch, store with purgeable tombstones, quit within
   seconds) — never launch the app yourself (stage).
2. **THE FIX (only on a red confirm):** order teardown against in-flight background reads — the sweep's reader
   awaited (or the sweep cancelled and joined) BEFORE the pool/codec teardown; the `QuitPurgeQuiesceTests` shape
   is the precedent. No new product behavior; pure ordering. If the fix wants to grow into a lock-road redesign,
   STOP and record (VX-152's adjacency — the orchestrator adjudicates).
3. **Pins:** the repro pin red-on-old by behavioral revert (named BEFORE it runs, at a committed tip); the
   ordering pinned.
4. **Close:** `swift build` · headless `swift test` over every touched suite · both `build-for-testing`s; list
   any Mac suites (TYPE names) + named reverts for the orchestrator's window at your record's end.

**Your record:** `### BATCH 5 RECORD` under UNIT RECORDS; LIVE STATUS row 5 flipped in your commits; first line =
what you did NOT do; a green confirm said plainly as RECORD-ONLY. **Not yours:** the stage; any Debug-app launch;
batches 3/4/6's files. **ENVIRONMENT TRAPS and STAGE & COORDINATION above bind verbatim.** No subagents;
foreground waits only.

## BATCH 6 BRIEF — the OWNED repair's rank swap (VX-921) + the device_cursor cap script (VX-919, AUTHORED ONLY)

**Who you are.** The implementer for batch 6, an Opus subagent at xhigh; `.claude/agents/opus-implementer.md`
binds you. Worktree `<home>/dev/variorum-vx-849`, branch `vx-849-typed-over-rescue`. SYNC/-CLASS
(`Repairs.swift`) — `notes/SyncSpec.md` IN FULL before any line; Fable cold-reviews. **ZERO server contact:
VX-919's script is AUTHORED and self-assessed only — never run against production, the mirror or any live
Supabase; the deploy is HELD for her window (a server act runs only at her word).**

**Read first, in full:** CLAUDE.md + canon (auto) · THIS FILE whole · `notes/SyncSpec.md` IN FULL (§7's repair
doctrine especially) · `notes/plans/fixes/vx-912-open-source-gating.md`'s B2 record (the worked pattern — the
created_at rank swap, P3: your exact shape) · `notes/plans/fixes/vx-912-b0-security-verify.md`'s device_cursor
corner (why VX-919 exists) · the code: `Sources/VariorumCore/Sync/Repairs.swift` — the OWNED exclusivity repair
(~:975–1050; the rank comment ~:984, the `sync_row_seq` join ~:1017) · `Server/supabase/` — grep `sync_challenge`
for the cap/eviction pattern; `Server/supabase/maintenance/` for the script conventions (`vx495-pull-keyset.sql`
+ `vx495-rollback.sql` are the paired-rollback precedent).

**The pieces, in order (commit per piece, `Part of VX-<member>`; push each):**

1. **VX-921 — the rank swap.** The OWNED exclusivity repair's claimant rank moves from `sync_row_seq` to
   `created_at` (the B2 worked pattern decides the exact key and tiebreak — follow it; an id tiebreak keeps
   determinism when stamps tie). SCOPE: this repair only — if you find sibling repairs with the same seq-rank gap
   (the ~:795/:812 joins belong to a different repair), RECORD them for the orchestrator, never widen silently.
   The pin, red-on-old by behavioral revert: the convergence shape — two devices whose `sync_row_seq`
   bookkeeping ranks DIFFERENT claimants (seq is per-device) converge on the SAME claimant under created_at; on
   the seq rank the pin is RED (the devices disagree). The repair's demotion/arrival arms unchanged (the standing
   suites stay green).
2. **VX-919 — the cap script, authored.** `Server/supabase/maintenance/vx919-device-cursor-cap.sql`: bound LIVE
   device rows per account at 64, evicting oldest `seen_at` first (the `sync_challenge` pattern); idempotent and
   safe to re-run; a header comment stating what it does, the DEPLOY-HELD-FOR-HER-WINDOW line, and the
   verification query to run after deploy; a paired rollback script/note per the maintenance conventions if the
   pattern calls for one. NEVER executed anywhere by you — its review is the ladder's.
3. **Close:** `swift build` · headless `swift test` over the repair's suites (the convergence suites run
   headless in the core) · both `build-for-testing`s; list any Mac suites (TYPE names — likely none) and confirm
   every named revert ran headless.

**Your record:** `### BATCH 6 RECORD` under UNIT RECORDS; LIVE STATUS row 6 flipped in your commits; first line =
what you did NOT do. **Not yours:** the stage; the deploy; batches 3/4/5's files. **ENVIRONMENT TRAPS and STAGE &
COORDINATION above bind verbatim.** No subagents; foreground waits only.

## UNIT RECORDS

*(appended per batch)*

### BATCH 1 RECORD (the implementer — Opus, xhigh; opened 2026-11-08)

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild test` of any kind and no Debug-app
launch (the brief's headless rule — no stage claim). Every Mac-suite claim below is **PENDING** the STAGE REQUEST
at the end of this record. Nothing touched `PaneSurface`/`PaneTextAuthority` (batch 3), VX-544's retry (batch 2),
the ladder or the PR.

**The headless reading of an app-target batch (recorded at the start):** the honest flush (`AutosaveCoordinator`)
and the `beforeRound` hook (`SyncSession`) live in the APP target (`App/Variorum/Shared/`), so their pins are Mac
suites (`VariorumTests`), which need the stage. Headless here means: `swift build`/`swift test` for the core;
`xcodebuild build-for-testing` (Mac + phone) to COMPILE the app pins — the VX-912 plan's binding line: "Headless
`swift build`/`swift test` and `xcodebuild build`/`build-for-testing` never need the stage"; and, for the
coordinator's behavior, a THROWAWAY instrument (the coordinator + runner source copied uncommitted into a scratch
folder of the core test target, run, then deleted — never in the PR) so its red-on-old is watched, not assumed.

| # | Piece | Status |
|---|---|---|
| 1 | VX-402 — the honest flush | DONE (this commit) — instrument red 3/3 → green 3/3; Mac `build-for-testing` green; the Mac pins' RUNS **PENDING** (stage) |
| 2 | VX-683 B — the guarded autosave (the op + the coordinator + the record sites) | DONE — 2a the op + core pins (`e7ec1227f`; 9/9; revert-proven); 2b the coordinator + the eleven record sites + the Mac pins (`169a51898`; instrument reverts R1/R2 bite); the phone pins (`3779bdea9`); Mac + phone builds green; Mac/simulator runs PENDING (stage) |
| 3 | VX-683 A — the `beforeRound` hook + the flush-before-apply occasion | DONE (the commit after `3779bdea9`, which flipped this row one commit early) — core 11/11; Mac + phone `build-for-testing` green; Mac runs PENDING (stage) |
| 4 | Close — builds, suites, self-assessment, STAGE REQUEST | DONE (this commit) — core 4019 green; MCP socket load-flakes recorded (all green alone); every Mac/simulator run PENDING the STAGE REQUEST |

**Piece 1 — VX-402, the honest flush (FIXED).**
- *Mechanism (traced, `AutosaveCoordinator.flushNow`):* a flush took the batch and cleared `pending` BEFORE awaiting its
  writes, so a second `flushNow` arriving while a write flew (the 500-ms debounce's, a door's detached flush) found
  nothing pending and returned at once — the door read the pre-keystroke store, and `flushExistingAutosave` answered
  `false` (`isDirty` counted the flight), an answer every caller discards. **The order hole beside it (found tracing,
  same class):** a two-take batch writes one runner turn at a time; a flush started between its turns wrote its NEWER
  text for the second take first, then the older batch's text landed on top — her last keystrokes overwritten by her
  own earlier ones, until her next keystroke rewrote the whole buffer (a ⌘Q in between savepoints the older text).
- *Fix:* one serial write lock — a flush waits for the batch in flight, THEN takes everything pending at that moment;
  `isDirty` = pending or writing. A refused entry the waited-on write puts back is not retried by the waiter (the
  keep-pending posture stands). The two vx-382 doc comments that named the open window (`BookIndexEditModel
  .releaseForTakesSheet`, `BookView.openInWrite`) now say it is closed — comment-only.
- *Pins (Mac, `AutosaveCoordinatorTests`, the VX-402 section — all three use only pre-fix API, so their red is
  BEHAVIORAL):* `aFlushArrivingWhileAWriteIsInFlightReturnsOnlyAfterThatWriteLanded` (an on-disk pool store, the
  writer held from a background thread so the write is provably in flight; the door's read beside it) ·
  `aNewerFlushNeverLandsUnderAnOlderInFlightOne` (reads only after the coordinator is quiet, so the red is the ORDER) ·
  `anIdleFlushReturnsAtOnceAndStillSettles` (guard, green both sides).
- *Evidence, headless (the instrument):* on the PRE-FIX coordinator the two pins were red 3/3 for the traced reasons —
  the door read `"before"` with `isDirty == true`; the order pin read `"late older"`. On the fix: green 3/3. Mac
  `xcodebuild build-for-testing` green (0 errors, no warning in a touched file). **The Mac runs themselves are
  PENDING** (the STAGE REQUEST below — red at the pre-fix parent, green at the tip).

**Piece 2a — VX-683 B, the operation (FIXED; core, headless).**
- *Mechanism (the memo's, re-traced in code):* her typing sits in the debounce window, so the take's row is CLEAN (not
  in `sync_outbox`); a pull applies the server's `working_text` on SyncSpec §5's locally-clean path; then the debounced
  `Operations.autosave(variantID, text:, charDelta:)` writes her buffer — built on the OLD text — over it blind
  (`Operations+Variant.swift`, the pre-fix body: `variant.workingText = text; update`). Its push carries the applied
  `sync_version`, so the server ACCEPTS it: the remote words survive nowhere.
- *Fix:* `autosave(…, expectedText: String? = nil)`. Inside the one transaction, after the take's guards (unchanged,
  so a locked take / sealed post / archived or dead take still refuses first and mints nothing): her text is written as
  before (touch and churn as before); when the snapshot is given and the row no longer holds it, the displaced text is
  inserted as a new take through `Operations.insertConflictVariant` — the S5 core `resolveSyncConflict` and the engine
  share — same block, the edited take's own parent, label `'conflict'`, the fan's end, never chosen. Compared as the
  store keeps text (`StoredText`); nothing displaced ⇒ no card; a dead block ⇒ no card (the engine's guard); `nil` ⇒
  today's blind write. The ordinary triggers enqueue both rows (never apply mode), so both push.
- *Pins (`Tests/VariorumCoreTests/TypedOverRescueTests.swift`):* suite "The typed-over rescue (VX-683 B — the guarded
  autosave)" — THE PIN `aStaleAutosaveKeepsHerBufferOnTheRowAndRescuesTheDisplacedWords`, the S5-shape pin
  `theRescuedCardLandsWhereAnS5CardLands`, and six guards (`anAutosaveOnTheTextItSawWritesAsBefore`,
  `anUnguardedAutosaveIsTheBlindWriteItAlwaysWas`, `whenTheRowAlreadyHoldsHerWordsNoCardIsMinted`,
  `aLockedTakeOrASealedPostRefusesBeforeAnyRescue`, `theSnapshotIsComparedAsTheStoreKeepsText`,
  `theRescueTouchesAndChurnsExactlyAsTheWriteItIs`); suite "The typed-over rescue converges (VX-683 B)" —
  `aPullIntoTheDebounceWindowThenHerAutosaveConvergesWithBothTexts` (two clients, the fake server, production rounds:
  dumps equal, outboxes empty, both texts on both devices, her words on the row).
- *Red-on-old, said plainly:* every pin names the new parameter, so on the pre-fix tree the suite is **COMPILE-red**
  (watched: `extra argument 'expectedText' in call`). The BEHAVIORAL red is the named revert below. Green on the fix:
  **9/9** (`swift test --filter TypedOverRescue`).
- *THE NAMED BEHAVIORAL REVERT (named here BEFORE it runs, at the committed tip of this commit):* in
  `Operations.autosave`, the rescue's `if` is guarded off (`if false, let expectedText, …`) — the parameter accepted
  and ignored, i.e. the pre-fix blind write. Expected: THE PIN, the S5-shape pin and the convergence pin RED (the
  displaced words survive nowhere); the six guards green. Then `git checkout --` the one file (nothing else
  uncommitted in it) and the suite re-run green. **Result (run at `e7ec1227f`): exactly as named** — RED:
  `aStaleAutosaveKeepsHerBufferOnTheRowAndRescuesTheDisplacedWords` (2 issues), `theRescuedCardLandsWhereAnS5CardLands`
  (4), `aPullIntoTheDebounceWindowThenHerAutosaveConvergesWithBothTexts` (4); the six guards GREEN; restored by
  `git checkout --` of the one file (diff clean) → **9/9 green**.

**Piece 2b — VX-683 B, the snapshot rides every surface's call (FIXED; Mac pins PENDING the stage).**
- *The coordinator (`AutosaveCoordinator`):* `Pending.expectedText` — the text the pending RUN was built on, set by the
  run's FIRST `record(…, basedOn:)` and kept while later keystrokes coalesce (they were built on her own pending text,
  never on the store); the flush passes it as the op's `expectedText`. A REFUSED write hands its older snapshot to a
  newer run recorded while it flew (the refused text never landed, so the newer run still stands on the older row —
  carrying its own would read the untouched row as changed and mint a spurious card at the retry).
- *The eleven production record sites, each passing what the surface showed BEFORE the edit:* Write
  (`EditorViewModel.recordAutosave` — the ledger's text before `recordEdit`); the crystallizer's leading-run attach
  (`knownText`) and its corrections (what THIS mint wrote into the take); the Takes board, Compare, Canvas, the book
  Index and the block TOC (each pane's `old` = `PaneTextAuthority.text`, computed before `bufferEdited`); the phone's
  page (its ledger), its takes-browser card (`lastRecordedCardText`, seeded at `beginEditing` from what the card
  showed), its branch-carries-the-shown-text road (the minted take's text), and the phone's quick note (a new
  `recordBase`: the owned block's STORED text at adoption — the box's own tail can differ from it by the import's
  normalization — then each tail handed off).
- *Deliberately unguarded (recorded corner):* the list exit's retraction write inside `runStructural`
  (`EditorSurfaceController.insertEmptyBlock`) — a structural flight's op body, written right after the flight's own
  flush in the same serialized runner; the seeders and the perf fixtures (not surfaces).
- *Pins (Mac, `TypedOverRescueSurfaceTests` — a new suite):* RED ON OLD BY BEHAVIOR (they drive only pre-fix API —
  the real typing road, a pull's row write, the flush): `writeTypingOverASyncPullRescuesThePullsWords`,
  `takesPaneTypingOverASyncPullRescuesThePullsWords`. Guards (green both sides — the false-positive class):
  `writeHerOwnSuccessiveRunsNeverMintACard`, `takesPaneHerOwnSuccessiveRunsNeverMintACard`. Coordinator pins
  (compile-red on old — they name `basedOn:`): `aRunCarriesItsFirstSnapshotAcrossCoalescedKeystrokes`,
  `aRefusedWriteHandsItsOlderSnapshotToTheNewerRun`.
- *Evidence, headless:* the two coordinator pins, ported into the instrument over the new coordinator: green. Mac
  `build-for-testing` green (0 errors). Phone `build-for-testing` green (generic iOS Simulator; one phone suite called
  `recordTakeEdit` without the snapshot — the parameter now defaults to nil like the coordinator's own `record`).
  **Every Mac run PENDING** (the STAGE REQUEST). The instrument's behavioral reverts of the two coordinator lines run
  next, at this commit's tip.
- *The instrument's named reverts (run at `169a51898`, on the throwaway copy of the committed coordinator):* **R1** —
  the flush passes `expectedText: nil` → `aRunCarriesItsFirstSnapshotAcrossCoalescedKeystrokes` RED, the refused-write
  pin green; **R2** — the hand-over line `newer.expectedText = entry.expectedText` removed →
  `aRefusedWriteHandsItsOlderSnapshotToTheNewerRun` RED (the spurious card), the first-snapshot pin green. Restored →
  4/4 green. Each revert bites exactly its own pin.
- *The phone's pins (a follow-up commit, `MobileTypedOverRescueTests`):* RED ON OLD BY BEHAVIOR —
  `thePageTypingOverASyncPullRescuesThePullsWords`, `aQuickCaptureTypedOverAPullRescuesThePullsWords`; GUARDS —
  `thePageHerOwnSuccessiveRunsNeverMintACard`, `aQuickCapturesOwnTypingAfterItsMintNeverMintsACard` (a one-block and a
  pasted two-paragraph capture — the quick note's `recordBase`). Phone `build-for-testing` green; simulator runs
  PENDING the stage.

**Piece 3 — VX-683 A, the occasion before every round (BUILT; Mac runs PENDING the stage).**
- *The seam (`SyncSession.beforeRound: (@MainActor () async -> Void)?`, minted here — D-544 build step 3a's shape; batch 2
  wires VX-544's retry onto it):* run to its END before every round the session's own roads start — `triggerSync()`
  (every trigger funnels through it), `flush()` AND `roundNow()`; behind the restore hold (a held store runs neither the
  occasion nor a round); the gate and the chain are read AGAIN after the occasion, so the round goes to the chain that
  stands then (a chain stopped or mid-replacement meanwhile runs nothing — `configure` clears it before it drains, so a
  retired chain is never revived). **nil = inert, byte-for-byte the pre-hook road** (the `keyProvider` pattern). Zero
  `Sources/VariorumCore/Sync/` lines: the engine never learns editors exist. *`roundNow` is included beyond the brief's
  two names* — an account act's first round is the same road class, and "every round this session's roads start" is
  only true with it; flagged for the orchestrator (one `if let` to drop if ruled out).
- *The occasion (`AppSession.flushPendingTypingBeforeRound`, shared):* R-683-3's one cheap check (`hasPendingAutosave`,
  bounded by the notes open — P1), then ONLY the dirty coordinators flush, through the honest flush (piece 1 — a write
  already in flight lands first too). After it the row is dirty and the standing §5/§6 machinery does the rest.
- *The composition:* `AppServices.init`, `#if os(macOS)` — "the Mac composition wires it" (the brief). **MOBILE PARITY:**
  the phone carries B on every phone record site (the page, the takes browser, the quick note) but NOT A's occasion —
  its sync roads (foreground trigger, the background `flush`) run no flush-before-apply, so a pull landing in its
  debounce window takes B's (i)-shaped rescue rather than A's S5 card. Nothing is lost either way; wiring the phone is
  one line beside the Mac's (the orchestrator's call).
- *Pins:* Mac `SyncBeforeRoundTests` — `triggerSyncRunsTheOccasionToItsEndBeforeTheRound`,
  `flushRunsTheOccasionToItsEndBeforeItsRound`, `roundNowRunsTheOccasionToItsEndBeforeItsRound` (an order-logging
  transport: the occasion's start and end both precede the round's first transport call),
  `aHeldStoreRunsNeitherTheOccasionNorARound`, the guard `noOccasionIsInert`; and the composition
  `theMacsOccasionLandsPendingTypingBeforeTheRound`, `theMacsOccasionTouchesNothingWhenNoTypingIsPending` (no flush,
  no settle on a clean coordinator — R-683-3). All name `beforeRound` → **COMPILE-red** on the pre-fix tree; their
  behavioral red is the named Mac reverts in the STAGE REQUEST. Core `FlushBeforeTheRoundConvergenceTests` (two
  clients, the fake server, production rounds) — `herPendingTypingFlushedBeforeTheRoundBecomesTheStandingS5Card` (THE
  brief's pin: the round ends with the server text on the row, her text the `'conflict'` take, the Mac's outbox empty —
  its push carried the card; both devices end with both texts) and `typingBetweenTheFlushAndTheApplyIsRescuedByTheGuard`
  (the memo's millisecond stragglers: three texts, none lost). These pin the COMPOSITION with the standing S5 road —
  green on both sides of the engine by design (no `Sync/` line changed); **11/11** with B's suites.
- *Builds:* Mac `build-for-testing` green and phone `build-for-testing` green (0 errors, no warning in a touched file).

**Piece 4 — Close.**
- *Headless, at `bdb70dc3d` (the instrument deleted first — the tree clean, nothing of it ever committed):* `swift build`
  green. The WHOLE package suite (`swift test`; `Operations.autosave` is called across many suites, so the touched set
  is effectively the target): **VariorumCoreTests 4019 tests in 549 suites PASSED (5 known issues)** · StringsWorkbook
  32 passed · **VariorumMCPTests 669 tests: load-sensitive socket failures, a VARYING set** — 6 in the full run (load
  average 16–23 on the Pro), then 4, then 2 in two runs of the MCP target alone (`aQuitSaysNothingForAConnectionItEnds`,
  `claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes`, `aBareOpeningIsAnsweredBeforeTheReadBlocks`,
  `eachStopSaysItsWordsAsTheConnectionsLastLine`, `aDoorStopThatLetsGoOfItsHostEndsTheClientsUntilDisconnectGrants`,
  `aReusedNumberKeepsItsBytesAfterTheSessionEnds`, and the ENVIRONMENT TRAPS' named flake
  `aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`); every one of the seven is an initialize/handshake
  that got no answer in time, and **all seven PASS run on their own** (two filtered runs, 7/7). No line of
  `VariorumMCP`/`VariorumMCPSocket` changed and neither reaches `autosave`; whether the MCP target goes wholly green in
  one quiet run is left to the closing run (a comparison against main's tip there would settle it beyond doubt).
  Mac + phone `build-for-testing` green at every piece.

**SELF-ASSESSMENT (the brief's two questions, answered exactly).**
- *The window that remains open after A — and B covers all of it:* A's occasion runs when the session's road starts the
  round (the trigger), so what stays open is everything between the occasion's last write and the apply transaction's
  begin: **milliseconds** for an ordinary round (the scheduler's hop, the lockstep check, a small pull); **the whole
  download** for a long catch-up (VX-494's staged windows — minutes on a from-zero round, during which she can type);
  **a trigger coalesced behind a running round** (its occasion runs at the trigger, its round only after the running one
  ends); **the rounds the scheduler starts on its own** (the coalesced follow-up, the orphan heal's, the one-writer
  belt's) — no occasion at all; and **the phone**, which composes no occasion (MOBILE PARITY above). In every one of
  these the row is clean when the pull applies, so the apply lands the server's words; the next autosave of her pending
  run carries the snapshot the run was built on, finds the row changed, and RESCUES (R-683-1/-2). Nothing in the window
  is lost; the only difference from A's road is which text keeps the row (hers, under B; the server's, under A).
- *Every road the guarded autosave now rescues* (any writer that changes a take's row under a pending run, the run's
  snapshot predating it): **a sync pull** on SyncSpec §5's locally-clean path inside the debounce window (the memo's
  mechanism — pinned core, Mac, phone); **the MCP door mid-window** (the door flushes her typing first, then acts; a
  keystroke after that flush starts a run whose snapshot predates the AI's write — rescued as the card, the AI's words
  kept); **a second window or a second surface** on the same take whose stale buffer would write back (VX-664's
  write-back class: the stale surface's next edit is built on words the row no longer holds — rescued, both kept;
  batch 3 still ends the ring so the face adopts); **a structural undo / redo, a Block History restore, a lens promote,
  a Replace-in-every-take** landing on a take with a pending run (the flush-first doors land her run first; a keystroke
  racing them is rescued); **the Takes board's own non-flushing doors** (the recorded corner below).
- *What B does NOT guard:* a caller that passes no snapshot — the seeders and perf fixtures (not surfaces), the list
  exit's retraction inside `runStructural` (a structural flight's op body, right after the flight's own flush), and the
  phone's `recordTakeEdit` when a test calls it bare (both production callers pass it). A surface whose bookkeeping
  lagged the store would show a spurious card; the false-positive guards (Write, a Takes pane, the page, the quick note —
  her own successive runs never mint a card) pin that none of the eleven roads does.

**RECORDED CORNERS (for the orchestrator; none fixed here — each is outside this unit):**
1. **The Takes board's `run` road does not flush first** (`TakesViewModel.run` — its `restoreCommit` among others). A
   board door that rewrites the take her live pane has pending typing in, racing that pending autosave, now leaves a
   `'conflict'` card holding the door's result; pre-fix her typing silently overwrote the door's result (a pre-existing
   loss). R-683-2's retelling says "a deliberate act of hers never mints this card" — this race is the one place that
   sentence does not hold as shipped. The spec-defensible fix is the flush-first doctrine on those doors (a ticket, not
   a product question — the rulings reconciliation item for the closeout).
2. **An empty displaced text mints an (empty) card** — the S5 card's own rule (the engine rescues whenever the texts
   differ), mirrored with no special case: no product invention either way.
3. **A dead block takes no card** (the engine's rescue guard); a live take under a dead block exists only inside an
   apply transaction, so no autosave can meet it.
4. **The face right after a rescue or after A's S5 adoption** is batch 3's (R-683-4, VX-664's composition).
5. **`roundNow` runs the occasion too** (beyond the brief's two named roads — same road class); one `if let` to drop.

**Canon deltas owed at the closeout (the orchestrator's, two-file shape):** AppSpec §9's convention line ("An
`expectedText` precondition that no longer matches refuses as `bufferChangedSinceGesture`") gains the autosave's
exception (it rescues instead of refusing); AppSpec §9's `autosave(variant, text, charDelta)` line gains `expectedText`
and the rescue (her buffer keeps the row; the displaced words a `'conflict'` take — R-683-1/-2); SyncSpec §6's
`working_text` row may want one pointer to the autosave-layer rescue (a local rescue, no §7 entry). No QUESTIONS filed:
nothing here needed a product decision the rulings had not made (corner 1 is a rulings-reconciliation item, flagged).

**STAGE REQUEST (every Mac and simulator run of this batch; the orchestrator's claim through nov7):**
- *Leg A — the batch's own Mac suites, at the tip (green expected):* `cd App/Variorum && xcodebuild test -scheme
  Variorum -destination 'platform=macOS' -only-testing:VariorumTests/AutosaveCoordinatorTests
  -only-testing:VariorumTests/TypedOverRescueSurfaceTests -only-testing:VariorumTests/SyncBeforeRoundTests` — confirm
  the "Test run with N tests" line (AutosaveCoordinatorTests 9 · TypedOverRescueSurfaceTests 6 · SyncBeforeRoundTests 7
  = 22).
- *Leg B — the named Mac behavioral reverts, each applied ALONE at the committed tip, its pins run, then `git checkout
  --` of the one file (diff clean) and the pins re-run green:*
  **R-402** `AutosaveCoordinator.flushNow`: delete the `while writing { … }` wait → RED
  `aFlushArrivingWhileAWriteIsInFlightReturnsOnlyAfterThatWriteLanded`, `aNewerFlushNeverLandsUnderAnOlderInFlightOne`.
  **R-B1** the flush's `expectedText: entry.expectedText` → `expectedText: nil` → RED
  `writeTypingOverASyncPullRescuesThePullsWords`, `takesPaneTypingOverASyncPullRescuesThePullsWords`,
  `aRunCarriesItsFirstSnapshotAcrossCoalescedKeystrokes` (the two surface pins are also behavior-red against the
  pre-fix source — they drive only pre-fix API). **R-B2** delete `newer.expectedText = entry.expectedText` → RED
  `aRefusedWriteHandsItsOlderSnapshotToTheNewerRun`. **R-A1** `SyncSession`: in `triggerSync`, `flush` and `roundNow`
  read `nil` where they read `beforeRound` (the hook stored, never run) → RED the three
  `…RunsTheOccasionToItsEndBefore…` pins. **R-A2** `AppServices.init`: delete the `#if os(macOS)` `sync.beforeRound`
  block → RED `theMacsOccasionLandsPendingTypingBeforeTheRound`, `theMacsOccasionTouchesNothingWhenNoTypingIsPending`.
  **R-A3** `AppSession.flushPendingTypingBeforeRound`'s body → `await flushEveryOpenPost()` → RED
  `theMacsOccasionTouchesNothingWhenNoTypingIsPending` (R-683-3: a clean coordinator flushed).
- *Leg C — the touched surfaces' standing Mac suites* (or simply the whole `VariorumTests` target, LIVE STATUS row 8):
  the suites over the coordinator, the eleven record sites, `SyncSession`/`AppServices` — among them
  `OutsideWriteRingEndTests`, `OutsideWriteLivePaneTests`, `TakePaneDurabilityTests`, `AutosaveConsolidationTests`,
  `AutosaveRegistryLifecycleTests`, `AutosaveRegistryReleaseTests`, `CopyDoorFlushTests`, `EditorSessionTests`,
  `BookIndexEditingTests`, `CompareBoardTests`, `CanvasAndPoolTests`, `TakesBoardTests`, `BlockHistoryPaneTests`,
  `NoteDeletionDoorsTests`, `MCPHerEditorDoorTests`, `ReturnKeyTraceTests`, `FirstRoundRoadTests`, the
  `Phase8ServicesTests` file's suites, `SyncWalkFenceTests`, `Phase9cAuthWiringTests`, `QuitPurgeQuiesceTests`.
- *Leg D — the phone (simulator):* `xcodebuild test -scheme VariorumMobile -destination 'platform=iOS
  Simulator,name=<the run's simulator>' -only-testing:VariorumMobileTests/MobileTypedOverRescueTests` (4 tests) plus
  the touched phone suites (`MobileQuickNoteTests`, `MobileEditorTests`, `MobileTakesBrowserTests`,
  `MobileBlockHistoryTests`, `MobileLivenessTests`); R-B1 again bites `thePageTypingOverASyncPullRescuesThePullsWords`
  and `aQuickCaptureTypedOverAPullRescuesThePullsWords`.
- *Not mine to claim and not claimed:* the live look (one real two-Mac round with typing in flight — her eyes, the
  memo's third evidence shape; can ride batch 2's held window).

### BATCH 1 ADJUDICATION (the orchestrator, 2026-11-09 — repo-first before batch 2 spawns)

**Verification:** all seven commits present and pushed as reported; the core pins re-run FIRST-HAND on the merged
tree (after the fold-in, merge `1f8f25a37`): `swift test --filter TypedOverRescue` → **11/11 in 3 suites green**.
The Mac/simulator legs are claimed as a stage window (legs A + B + D now; leg C FOLDS into the run's closing Mac
runs, LIVE STATUS row 8, where those suites must run anyway over every changed source — one sweep, not two).

**The implementer's decisions, dispositioned:**
1. **The Takes board's non-flushing doors (its `restoreCommit` among them) → FOLDED INTO BATCH 3 as a named item,
   PROVISIONAL P-849-1.** The finding is real: a board door that rewrites the take her live pane is typing in now
   leaves a `'conflict'` card, against R-683-2's premise ("a deliberate act of hers never mints this card"). The
   spec-defensible build (the PROVISIONAL rule): those doors FLUSH PENDING TYPING FIRST — the MCP door's own
   precedent, and the same world batch 3's ring-ending composes with (the door then acts on flushed text, the ring
   ends on the pane's own take per her VX-664 option-(a) ruling, the pane adopts, no card). The alternative (keep
   the rescue card on her own doors) is recorded here; QUESTIONS at the merge.
2. **`roundNow` runs the occasion → ACCEPTED, not provisional.** An account act's first round applies rows like
   any round; the flush-before-apply rationale is road-independent (mechanism, not product).
3. **The phone gets B but not A → batch 2's seam call, PROVISIONAL P-849-2.** Batch 2 wires beforeRound occasions
   anyway (the retry); it wires the phone's FLUSH occasion too if the phone composition offers the same one-line
   seam, else records it for the MOBILE PARITY line. (D-544's phone posture — the retry hook unwired there — is
   unchanged either way.)
4. **The deliberately unguarded sites (the list-exit retraction inside `runStructural`, the seeders, the perf
   fixtures) → ACCEPTED as recorded.** None is her typing racing an outside writer; the structural compound keeps
   `insureTakes` as its own insurance.
5. **Canon deltas → queued for the closeout list:** AppSpec §9's `expectedText` convention line gains the
   autosave exception (rescues, never refuses); the `autosave` line gains `expectedText` and the rescue; a
   SyncSpec §6 pointer if the ladder agrees it belongs.

**THE STAGE WINDOW (claim vx-849-batch1, 2026-11-09, the orchestrator's hands; worktree verified at tip
`cd3c51ce6` before, between and after every cycle):**
- **Leg A:** "Test run with 22 tests in 3 suites passed" (AutosaveCoordinatorTests 9 · TypedOverRescueSurfaceTests 6
  · SyncBeforeRoundTests 7).
- **Leg B, six reverts, each applied alone, restored and `git diff --stat`-verified clean before the next, each
  restore's suites re-run green:** R-402 red on `aFlushArrivingWhileAWriteIsInFlightReturnsOnlyAfterThatWriteLanded`
  (2 issues, the traced expectations); R-B1 red on exactly its three named pins; R-B2 red on
  `aRefusedWriteHandsItsOlderSnapshotToTheNewerRun` (2 issues); R-A1 red on exactly the three
  `…RunsTheOccasionToItsEnd…` pins; R-A2 red on both its named pins; R-A3 red on exactly
  `theMacsOccasionTouchesNothingWhenNoTypingIsPending`. Final clean-tip proof: the leg-A trio 22/22 green.
- **The R-402 overlap, adjudicated live (a finding, not a hollow pin):**
  `aNewerFlushNeverLandsUnderAnOlderInFlightOne` stays GREEN under R-402 alone — with the lock deleted, VX-683 B's
  guard independently covers that interleaving (her own superseded run is dropped without a card), so the row still
  ends right. One deliberate STACKED probe (R-402 + R-B1, both belts off) turned it RED on the exact expected line
  ("an older in-flight write landed over her newer text") — first-hand proof the pin is live. The defense-in-depth
  overlap is the memo's own design ("B is the belt that makes the class impossible whatever the timing"); recorded
  so no later reader mistakes the single-revert green for hollowness.
- **Two spec corrections to the leg as written:** R-B2's pin lives in `TypedOverRescueSurfaceTests` (the first red
  run targeted only the coordinator suite and read green — a suite-targeting miss, corrected); and the leg-D list's
  `MobileEditorTests` is NOT a type (nov7's trap check) — the real editor types are the five `MobileEditor*Tests`
  suites, all run.
- **Leg D (iPhone 17 Pro sim by id, fresh boot, `simctl shutdown all` after):** "Test run with 116 tests in 10
  suites passed" — MobileTypedOverRescueTests (the batch's 4) + MobileQuickNoteTests · MobileTakesBrowserTests ·
  MobileBlockHistoryTests · MobileLivenessTests + the five MobileEditor* suites. A first attempt exited 70 on an
  unresolved `name=iPhone 17 Pro` destination (no test ran); the rerun pins the device BY ID.

**Also recorded:** the MCP whole-target socket timeouts (6→4→2, all green alone, no MCP line changed) are the
known VX-850 load-flake class — vx-926's territory; the closing run compares against main's tip before any claim.
The two batch-1 convergence pins passing on both sides is BY DESIGN (they pin the composition with the standing
S5 machinery), recorded so nobody reads them as a hollow red-on-old — the batch's red-on-old lives in the core
rescue pins (revert-proven headless) and the named Mac reverts (leg B).

### BATCH 2 RECORD (the implementer — Opus, xhigh; opened 2026-11-09)

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild test` of any kind, no stage contact, no
Debug-app launch, no store or server contact (override 7 — every Mac and simulator run is the orchestrator's, through
nov7's queue; the suites are listed at the end). Her drill — the two-Mac test's steps 8–9 on her Air — is OWED, never
claimed (override 8; LIVE STATUS row 9). Nothing under `Sources/VariorumCore/Sync/` or `Protection/`'s headless core.

**Preflight, read in this session (never delegated):** CLAUDE.md + the loaded canon; this file whole (STATUS, KICKOFF,
STAGE & COORDINATION, CONSTITUTION, ENVIRONMENT TRAPS, the batch 1 record + adjudication, this batch's nine overrides);
`notes/plans/fixes/vx-544-offline-typed-unlock.md` whole (D-544, PREFLIGHT FACTS, THE BRIEF) and VX-500's D-544 section;
`notes/CastleRules.md` WHOLE; `notes/SurfaceContracts.md` §"Doors to the outside" (the protection bullet — VX-501's
typed-unlock load, VX-486/487's locked row); `notes/SyncSpec.md` §2–§6 (§3's keys-absent refusal grammar);
`notes/SessionResiliencyProtocol.md` §implementer; `.claude/agents/opus-implementer.md`.

**PREFLIGHT FACTS re-verified at `93c2e3149`:** `ProtectionOpenRoad.swift` — `TypedUnlockSecret` :624 (redacted),
`loadSyncKeysAfterTypedUnlock` :654 (its exits: not writing/unbound :658, not Castle :659, keys already held :661, signed
out/another account :667, the vault read's `.read(nil)` :679 / `.failed` :682 / `.timedOut` :686, a secret not the vault's
:702, a master not the vault's :707, a moved account :711, the hold :715), `openTyped`'s call :395 and the vault road's
catch-up's call :529; `ProtectionRoadLock.dropSessionMemory` :56 (callers: the lock `AppBootstrap.swift:1456`, Make this my
library's outgoing session `ProtectionCopyDoors.swift:538`); `SyncSession.triggerSync` now :214 and `flush` :280 (batch 1
moved them; `roundNow` :243; the `beforeRound` hook :211, batch 1's); the one wired closure `AppServices.swift:220`
(`#if os(macOS)`); NO `NWPathMonitor` / `import Network` anywhere in `App/` or `Sources/`; the locked line
`SyncStatusViews.swift:767` untouched. **Fact the old plan did not have:** the PHONE reaches the shared typed load too
(VM-8 unit 1 — `MobileTypedUnlockSyncKeysTests`), so D-544's "no typed-unlock pending on the phone's road today" is stale:
the shared load's retention runs on the phone; only its retry stays unwired (override 5).

| # | Piece | Status |
|---|---|---|
| 0 | Preflight + this record | DONE (this commit) |
| 1 | The retained pending load (`PendingSyncKeyLoad` on `ProtectionRoadSession`; set only on the read's failure/timeout; every let-go road) + pins | DONE (`b11fb8d39`) — compile-red on old watched; R-1a/R-1b bit exactly as named; harness green; Mac runs PENDING (stage) |
| 2 | The retry (`ProtectionOpenRoad.retryPendingSyncKeyLoad`, single-flight) + pins | DONE (`4152e782a`) — R-2a…R-2d bit exactly as named; harness green; Mac runs PENDING (stage) |
| 3a | The occasion: the Mac's retry inside the one wired `beforeRound` closure, gated; the bootstrap's roads; sign-out's drop; P-849-2 (the phone's flush occasion) + pins | DONE (`88eb36506`) — THE ROAD PIN behavior-red on the pre-fix tree (watched); R-3a…R-3f run (R-3a one red beyond the named set; R-3b′ in place of the too-blunt R-3b); R-3g PENDING (simulator); Mac/simulator runs PENDING (stage) |
| 3b | The reachability trigger (`NWPathMonitor` in the shared `SyncSession`) + pins | DONE (`5ce6becf0`) — R-4a…R-4e bit exactly as named; harness green; Mac runs PENDING (stage) |
| 4 | The words (no new sentence) | DONE (`36b709512`) — no user-facing sentence added or changed |
| 5 | Close: builds, headless runs, self-assessment, the stage suite list | DONE (`36b709512`) — every Mac/simulator run PENDING the STAGE REQUEST |

**The headless reading (recorded at the start of piece 1).** Every pin of this batch is a Mac-target (or phone-target) suite,
so its RUN needs the stage. Headless here: `xcodebuild build-for-testing` (Mac + phone) COMPILES them; and THE HARNESS — a
throwaway SwiftPM package in this session's scratchpad (`vx544-harness`, never committed; the vx-529 U2 recipe rebuilt): tools
6.2, macOS 26, the app target's settings on `Variorum` (Swift 6, default `MainActor`, `NonisolatedNonsendingByDefault`,
`InferIsolatedConformances`, `MemberImportVisibility`, `DEBUG`), the test target without default `MainActor`; the worktree's
core by path, swift-dependencies 1.14.1, the sqlcipher GRDB fork. `Variorum` SYMLINKS every `Shared/Protection/*.swift`,
`Theme/*`, `SampleLibrary/*` minus `SeededBookRestore`, and `Shared/`'s `AppBootstrap`, `AppServices`, `SyncSession`,
`SyncStatusViews`, `ProtectionController`, `AuthSession`, `AuthViews`, `KeychainCustody`, `LibraryOpenCopy`, `WordsCopyDoor`,
`ProjectConfig`, `TierViews`, `ErrorPresentation`, `IdleCommitScheduler`, `StoreBackup`, `OperationsRunner`, `DeviceName`,
`BackupDestination`, `BackupLog`, `MarkdownInsurance`, `BookNameCopy`, `ExportWriter`, `StoreLocation`, `LibraryHandOff`,
`RestoreHoldModel`, `WingState`, `PeekableSecretField`, `TravellingDotsIndicator`, the Mac's `WhatsNewLedger`, and ONE stub
file (a slim `AppSession` + `StatusCenter`, a one-line `CopyForAI.put`). The tests symlink `VariorumTests/Protection/*.swift`
minus the recipe's Mac-view suites (plus `ProtectionPaneRoadRowTests`, a Mac pane), with a TRUNCATED copy of
`TouchIDUnlockSyncKeysTests` (its trailing `SessionHoldBringInTests` suite needs the copy-door plants — the helpers above it
are byte-identical) and one stub of byte copies (`AppTestKeyProvider`, `SeededGenerator`). Only planted suites are ever run
there (`--filter`) — never the recipe's keychain-writing `…Route` suites. A behavioral revert in the harness replaces ONE
symlink with an edited copy of the committed file, runs, and restores the symlink: the worktree is never touched.

**Piece 1 — the retained pending load (BUILT).**
- *Mechanism (D-544's, re-traced at `93c2e3149`):* `openTyped` → `loadSyncKeysAfterTypedUnlock` (:395, and the vault road's
  catch-up :529). Offline, `boundedVaultRead` answers `.failed` (the leaf throws — `PlantedVaultLeaf.reachable = false`) or
  `.timedOut` (past the 10 s bound), the arm logs and RETURNS; the typed secret (`TypedUnlockSecret` — the derived
  `PassphraseKey`s or the words) dies with the call. Nothing anywhere holds it, so no later code CAN load the keys: the
  provider (`NewRoadSyncKeyProvider.currentKeys` — session memory, then the silent item; Castle keeps none) throws
  `notEnrolled` → the engine refuses `encryptionKeysUnavailable` → the row says "Sync locked" until another online typed
  unlock or a Touch ID unlock.
- *Fix (`ProtectionOpenRoad.swift`, `ProtectionRoadLock.swift`):* `PendingSyncKeyLoad` (the account + the secret's DERIVED
  form only — the passphrase's derived keys, or the words' `WordsKey` derived once at the keep; never the text, never the
  words; redacted; not `Codable`), held by `ProtectionRoadSession` under its one lock (`pendingSyncKeyLoad`). The load KEEPS
  it only in the read's `.failed`/`.timedOut` arms (`keepForTheRetry`); a `defer` ends it at EVERY other exit (unbound / not
  Castle / read-only, keys already held, signed out or into another account, no vault, a secret not the vault's, a master
  not the vault's, a moved account). `TypedUnlockSecret` gains `.wordsKey(WordsKey)` (the kept form; the load's switch reads
  it; the secret check's `default` arm is untouched). THE HOLD moves into the session (`holdLoadedSyncKeys`, under the
  session's lock): it lands only if the session has not let go, session memory still holds exactly what the load saw at its
  start (never over an act's or another load's hold), and the library AS IT STANDS still follows the keys in Castle; a hold
  that lands ends the pending. THE LET-GO (`letGoOfSyncKeyLoad`, final): the pending dropped and every later hold refused;
  `ProtectionRoadLock.dropSessionMemory` runs it FIRST, before the leaf drop — the relock and Make this my library's
  outgoing session (`ProtectionCopyDoors.swift:538`) both reach it. (The sign-out's and the replacing reopen's let-go are
  piece 3a's wiring.) The retry's one-flight member (`retryingSyncKeyLoad`) rides this commit unused — piece 2 calls it.
- *Pins (`App/Variorum/VariorumTests/Protection/TypedUnlockRetryTests.swift`, a new suite; planted, no keychain):*
  `anOfflineTypedUnlockLeavesItsLoadPendingWithTheKeysUnloaded` (the derived keys kept, redacted, nothing written),
  `anOfflineWordsUnlockKeepsTheWordsDerivedKeyNeverTheWords`, `aTimedOutVaultReadLeavesTheLoadPendingToo`,
  `theRelockLetsGoOfThePendingLoad`; GUARDS (green on both sides by design): `aSuccessfulFirstLoadLeavesNothingPending`,
  `everyOtherExitLeavesNothingPending` (signed out, another account, no vault, the passphrase changed elsewhere, a moved
  account, keys already held, a read-only road). **All six name the new seam ⇒ COMPILE-red on the pre-fix tree** (to be
  watched in the harness over the pre-fix product files). Their BEHAVIORAL red is the named reverts below. The standing
  VX-501 suites stay green over the moved hold, including `theTypedLoadNeverDerivesThePassphrase` (the source pin over the
  load's region — the keep's helper lives inside it and names no derivation).
- *Evidence, headless at this commit:* Mac `xcodebuild build-for-testing` → `** TEST BUILD SUCCEEDED **`; the harness
  (`--filter` TypedUnlockRetryTests · TypedUnlockSyncKeysTests · TouchIDUnlockSyncKeysTests · RoadLockTests ·
  LobbyVaultRoadTests · SecretCheckRoadTests) → `✔ Test run with 45 tests in 6 suites passed`.
- *THE NAMED BEHAVIORAL REVERTS (named here BEFORE they run, at this commit's tip; each in the harness on a copy of the one
  file, then the symlink restored):* **R-1a** `keepForTheRetry`'s body → `return false` (nothing ever kept — the pre-fix
  behavior) ⇒ expected RED: the three keep pins and `theRelockLetsGoOfThePendingLoad` (its precondition); the two guards
  green. **R-1b** `dropSessionMemory`'s `session.letGoOfSyncKeyLoad()` line deleted ⇒ expected RED:
  `theRelockLetsGoOfThePendingLoad` only.
- *Piece 1's evidence, run at `b11fb8d39` (the harness):* **compile-red on old** — the pre-fix `ProtectionOpenRoad.swift` and
  `ProtectionRoadLock.swift` (`git show 93c2e3149:…`) in place of the two symlinks: the test build fails exactly on the new
  seam (`TypedUnlockRetryTests.swift`: "value of type 'ProtectionRoadSession' has no member 'pendingSyncKeyLoad'", "cannot
  find 'PendingSyncKeyLoad' in scope", "…no member 'retainPendingSyncKeyLoad'"), symlinks restored. **R-1a** → `✘ 6 tests,
  4 failed` — exactly `anOfflineTypedUnlockLeavesItsLoadPendingWithTheKeysUnloaded`, `anOfflineWordsUnlockKeepsTheWords…`,
  `aTimedOutVaultReadLeavesTheLoadPendingToo`, `theRelockLetsGoOfThePendingLoad` (its precondition); both guards green.
  **R-1b** → `✘` exactly `theRelockLetsGoOfThePendingLoad` (3 issues: the pending stood past the drop, a keep after it was
  accepted). Restored → `✔ 6 tests passed`.

**Piece 2 — the retry (BUILT).**
- *Build (`ProtectionOpenRoad.retryPendingSyncKeyLoad(_:signIn:within:)`):* nothing pending ⇒ return at once (no read); else
  ONE FLIGHT through `ProtectionRoadSession.retryingSyncKeyLoad` (a retry asked while one is out awaits that flight's end —
  never a second read; the flight's record is written under the session's lock before the flight can clear it), which
  re-reads the pending and calls `loadSyncKeysAfterTypedUnlock` with its kept secret — the same function, the same 10 s
  bound, the same log lines (plus one line naming the retry). The load's own exits decide: a hold that lands ends the
  pending; a second failure keeps it (re-kept, the same content — refused once the session let go); every other exit ends
  it. `signIn` is the caller's read of who is signed in NOW.
- *Pins (`TypedUnlockRetryTests`, the retry section):* THE PIN `anOfflineUnlockThenTheVaultReachableTheRetryLoadsTheKeys`
  (one more read, the account's keys in session memory, the engine's seam reads them, the pending ended, nothing written),
  `theRetryFinishesAWordsUnlockToo`, `aSecondFailureKeepsThePendingAndNothingPendingReadsNothing` (offline again: one more
  read, still pending; after the hold, no read; on a session that let go, no read and nothing held),
  `aRetryAnsweredAfterTheLockHoldsNothing` (the read out when the lock lets go — its answer holds nothing),
  `aRetryNeverOverwritesAHoldThatLandedMeanwhile` (an act's hold while the read is out stands; the pending ends),
  `retriesAskedTogetherShareOneRead` (three at once: one read), `aRetryThatFindsTheSecretNoLongerTheVaultsEndsThePending`
  (the passphrase changed elsewhere meanwhile), `aRetrySignedOutReadsNothingAndEndsThePending` (signed out; another account).
  All name `retryPendingSyncKeyLoad` ⇒ COMPILE-red on the pre-fix tree; THE PIN is BEHAVIOR-red by R-2a (the old tree's
  behavior: nothing kept, so nothing can load the keys after the failed read).
- *Evidence, headless at this commit:* the harness (the six suites) → `✔ Test run with 53 tests in 6 suites passed`;
  `TypedUnlockRetryTests` alone five runs in a row → `✔ 14 tests passed` each (the two timing pins' windows — 200 ms into a
  600 ms read — hold).
- *THE NAMED BEHAVIORAL REVERTS (named BEFORE they run, at this commit's tip; the harness, one file each, then restored):*
  **R-2a** `keepForTheRetry` → `return false` ⇒ expected RED: THE PIN, `theRetryFinishesAWordsUnlockToo`,
  `aSecondFailureKeepsThePending…`, `aRetryAnsweredAfterTheLockHoldsNothing` (no read was made), `retriesAskedTogether…`
  (no read), and piece 1's four; GREEN: the overwrite pin, the two end-the-pending pins, piece 1's two guards (nothing pending
  is their state either way). **R-2b** `holdLoadedSyncKeys`' `!syncKeyLoadLetGo,` condition removed ⇒ expected RED:
  `aRetryAnsweredAfterTheLockHoldsNothing` only. **R-2c** `holdLoadedSyncKeys`' compare (`sessionSyncKeys == before`) removed
  ⇒ expected RED: `aRetryNeverOverwritesAHoldThatLandedMeanwhile` only. **R-2d** `retryingSyncKeyLoad`'s flight bypassed
  (`await body()` directly) ⇒ expected RED: `retriesAskedTogetherShareOneRead` only (three reads; the second and third holds
  refused by the compare, so the keys still land).
- *Piece 2's evidence, run at `4152e782a` (the harness):* **R-2a** → `✘ 14 tests, 9 failed` — exactly the five named retry
  pins (THE PIN — "Load.fetches == before + 1", the keys, the engine's seam; the words retry; the second failure; after the
  lock — no read was made; one read) and piece 1's four; GREEN: the overwrite pin, the two end-the-pending pins, the two
  guards. **R-2b** → `✘` exactly `aRetryAnsweredAfterTheLockHoldsNothing` ("sessionSyncKeys == nil" — the late answer held
  the keys past the relock). **R-2c** → `✘` exactly `aRetryNeverOverwritesAHoldThatLandedMeanwhile` (the act's hold
  overwritten). **R-2d** → `✘` exactly `retriesAskedTogetherShareOneRead` ("fetches == before + 1" — three reads). Each
  restored; the suite green after.

**Piece 3a — the occasion (BUILT).**
- *The Mac's occasion (`AppServices.swift`):* batch 1's ONE wired closure, moved to the end of `init` (it captures `self`):
  on the Mac `await self?.retryTypedUnlockSyncKeysWhileLocked()` FIRST, then batch 1's
  `session?.flushPendingTypingBeforeRound()` — no second hook property (override 4). THE GATE
  (`retryTypedUnlockSyncKeysWhileLocked`): no roads, or nothing pending (`roads.isPending()` — a memory read, never the
  keychain) ⇒ return at once — the whole cost of every round of an unlocked session, Standard, an unbound library; with a
  pending: ONE `currentKeys()` try OFF the main actor (`Task.detached` — it may read the silent keychain item, never on the
  main thread, the 13e class); keys there ⇒ `roads.clear()` (an act or an unlock loaded them — "cleared by any act that loads
  the keys"); none ⇒ `await roads.retry()` (bounded by the vault read's 10 s; a retry already out is joined).
- *The roads (`TypedUnlockSyncKeysRoads` in `AppServices.swift`; wired in `AppBootstrap.attach(services:)`, both platforms):*
  four closures over the bootstrap's CURRENT `roadSession` (a reopen's fresh session is the one reached; the services never
  hold a road session) — `isPending`, `retry` (`AppBootstrap.retryTypedUnlockSyncKeyLoad`: ready on a writing road, then
  `Task.detached` with `signInNow()` — the press's own off-main pattern — into `retryPendingSyncKeyLoad`), `clear`, `letGo`.
- *The let-go roads completed:* **sign-out** — `AppServices.variorumSignInChanged(nil)` (the one observation every sign-out
  road reaches: the Account sheet, sign out everywhere, the account's deletion) calls `typedUnlockSyncKeys?.letGo()` (her
  R-849-1: "dropped at lock/sign-out"); **a replacing reopen** — `AppBootstrap.finish(.ready)` lets go of the OUTGOING session
  (`outgoing !== road`) before it takes the new one (a re-keying act's reopen, a copy door's landing): the derived secret
  never crosses a reopen and a retry of the old session still out holds nothing.
- *P-849-2 — the phone's FLUSH occasion: WIRED (it IS the one line).* The phone's page, takes browser and quick note record
  into the same `AppSession` autosave registry `flushPendingTypingBeforeRound` walks (`MobileEditorViewModel` —
  `session.autosave(forPost:)`; batch 1's B on every phone record site), so the phone's composition is the same closure
  minus the retry: `#else sync.beforeRound = { [weak session] in await session?.flushPendingTypingBeforeRound() }`. Its roads:
  `.active`'s `triggerSync`, the background transition's `flush()` (after its own `flushAll` — the occasion's cheap check then
  finds nothing pending), the settle observation. The phone's RETRY stays unwired (override 5): its closure has no retry call.
  **[AMENDED at the BATCH 2 ADJUDICATION — P-849-3 RULED (c), below:]** the phone now composes BOTH occasions — the one
  closure is shared by both platforms (the `#if`/`#else` arms collapsed: retry first, then the typing flush).
- *Pins:* **THE ROAD PIN** `OfflineTypedUnlockRetryRoadTests.herOfflineTypedUnlockSyncsAtTheNextRoundOnceTheVaultAnswers` —
  her steps 8–9 end to end over what ships (the bootstrap over the planted road, the real `AppServices`/`SyncSession`
  attached through `attach(services:)`, a fake server): ARM 3's Castle-under-Always-ask set-up, the LOCK, the typed unlock
  with the vault unreachable ("Sync locked"), the vault reachable again, the next round (`roundNow`) clean, "Synced", the keys
  in session memory, nothing in the keychain. It names ONLY pre-fix API ⇒ **BEHAVIOR-red on the pre-fix tree, WATCHED**: the
  harness over the pre-fix `ProtectionOpenRoad`/`ProtectionRoadLock`/`AppServices`/`AppBootstrap` (`git show 93c2e3149:…`),
  the pin alone (its siblings, which name the seam, stripped from a harness-only copy) → `✘ 1 test, 3 issues`: the round's
  `lastError` = "Sync paused: this device's encryption keys are locked or not enrolled…", the row `.keysLocked`, no keys
  held — the traced mechanism exactly; symlinks restored. Its three siblings (compile-red — they name the seam):
  `theLockLetsGoOfTheOfflineUnlocksPendingLoad`, `aSignOutLetsGoOfTheOfflineUnlocksPendingLoad`,
  `aReopenLetsGoOfTheOutgoingSessionsPendingLoad` (Use Standard through the crossing's reopen; the chain stopped first so no
  round retries before it). The composition suite `TypedUnlockRetryOccasionTests` (scripted roads, a counting provider):
  `whileThereAreNoKeysTheOccasionRetriesThePendingLoad`, `withNothingPendingTheOccasionReadsNoKeysAndRetriesNothing`,
  `withTheKeysThereTheOccasionEndsThePendingAndRetriesNothing`, `aSignOutLetsGoOfThePendingLoad`, the guard `noRoadsIsInert`.
  Mac-only (it needs the real `AppSession`'s coordinators): `SyncBeforeRoundTests.theMacsOccasionRetriesTheTypedUnlocksLoad
  BeforeHerTypingLands` (the retry runs while her typing is still pending, then her typing lands). Phone:
  `MobileRoundOccasionTests.thePhonesOccasionLandsPendingTypingAndRunsNoRetry` (the occasion lands her typing; the retry
  closure never called) — BEHAVIOR-red on old by its `#require(beforeRound)` (nil on the phone pre-fix), compile-red as a file.
- *Evidence, headless at this commit:* Mac `build-for-testing` `** TEST BUILD SUCCEEDED **` (one Sendable-capture error in
  the new SyncBeforeRound pin fixed on the way); phone `build-for-testing` (generic iOS Simulator) `** TEST BUILD SUCCEEDED
  **`; the harness (TypedUnlockRetry · TypedUnlockRetryOccasion · OfflineTypedUnlockRetryRoad · TypedUnlockSyncKeys ·
  TouchIDUnlockSyncKeys · RoadLock · LobbyVaultRoad · SecretCheckRoad · FirstRoundAfterTheAct · FirstRoundAfterTheReopen ·
  FirstRunDrill) → `✔ Test run with 81 tests in 11 suites passed`.
- *THE NAMED BEHAVIORAL REVERTS (named BEFORE they run, at this commit's tip; the harness unless marked Mac):* **R-3a** the
  Mac closure's `await self?.retryTypedUnlockSyncKeysWhileLocked()` deleted ⇒ RED `whileThereAreNoKeysTheOccasionRetries…`
  and THE ROAD PIN (and, Mac, `theMacsOccasionRetriesTheTypedUnlocksLoadBeforeHerTypingLands`). **R-3b** the gate's
  `roads.isPending()` condition deleted ⇒ RED `withNothingPendingTheOccasionReadsNoKeysAndRetriesNothing`. **R-3c** the
  keys-present `roads.clear()` deleted ⇒ RED `withTheKeysThereTheOccasionEndsThePendingAndRetriesNothing`. **R-3d** the
  sign-out's `typedUnlockSyncKeys?.letGo()` deleted ⇒ RED `aSignOutLetsGoOfThePendingLoad` and
  `aSignOutLetsGoOfTheOfflineUnlocksPendingLoad`. **R-3e** `finish`'s outgoing `letGoOfSyncKeyLoad()` deleted ⇒ RED
  `aReopenLetsGoOfTheOutgoingSessionsPendingLoad`. **R-3f** `attach(services:)`'s `services.typedUnlockSyncKeys = …`
  deleted ⇒ RED THE ROAD PIN and `aSignOutLetsGoOfTheOfflineUnlocksPendingLoad`. **R-3g (simulator — the stage's)** the
  phone's `#else` closure deleted ⇒ RED `thePhonesOccasionLandsPendingTypingAndRunsNoRetry`.

- *Piece 3a's reverts, run at `88eb36506` (the harness), and one named BEFORE its run here:* **R-3a** → `✘ 9 tests, 3
  failed`: `whileThereAreNoKeysTheOccasionRetriesThePendingLoad`, THE ROAD PIN (the round refused for keys — "Sync paused:
  this device's encryption keys are locked or not enrolled…"), and ONE MORE THAN NAMED — `withNothingPending…`'s occasion leg
  (it asserts the occasion consulted the gate: `["isPending", "isPending"]`; with the call deleted only the direct call's
  read is logged). The named set was incomplete, not the pin hollow. **R-3b** (the condition deleted outright) → `✘ 5 tests,
  3 failed` — the named `withNothingPending…` (`provider.reads == 0` broken) and the two other gate pins, whose logs record
  the `isPending` consult the deletion removed: a revert too blunt to isolate. **R-3b′ (named here, BEFORE it runs, at
  `88eb36506`):** `roads.isPending()` → `(roads.isPending() || true)` (consulted, ignored) ⇒ expected RED
  `withNothingPending…` (the provider read, the retry run) and `withTheKeysThere…`'s second-occasion leg (the cleared pending
  read again); GREEN `whileThereAreNoKeys…`. **R-3c** → `✘` exactly `withTheKeysThereTheOccasionEndsThePendingAndRetriesNothing`.
- *Run at `3f0412931` (product files identical to `88eb36506`):* **R-3b′** → `✘` exactly `withNothingPending…` (the provider
  read, the retry run) and `withTheKeysThere…`'s second-occasion leg; `whileThereAreNoKeys…` green — as named. **R-3d** →
  `✘` exactly `aSignOutLetsGoOfThePendingLoad` and `aSignOutLetsGoOfTheOfflineUnlocksPendingLoad`. **R-3e** → `✘` exactly
  `aReopenLetsGoOfTheOutgoingSessionsPendingLoad`. **R-3f** → `✘` exactly THE ROAD PIN (the round refused for keys) and
  `aSignOutLetsGoOfTheOfflineUnlocksPendingLoad`. Restored → `✔ 23 tests in 3 suites passed`. **R-3g** (the phone's) is the
  stage window's (simulator).

**Piece 3b — the reachability trigger (BUILT; her R-849-2).**
- *Build (`SyncSession.swift`, shared — both platforms):* `import Network`; `NetworkPathWatching` (start with an in-order
  main-actor reading callback; stop) and its production `SystemNetworkPath` (`NWPathMonitor`, its handler on the MAIN queue —
  the readings in order, on the main actor, the handler's work one comparison). `SyncSession.init` gains `path:` (nil = no
  watch — the pre-trigger session exactly) and `reachabilityDebounce:` (2 s, D-544's). The watch RIDES THE CHAIN: `configure`
  starts it (its first reading the baseline), `stopObservations` — every teardown: `stop()`, `quiesceForExit()`, a
  reconfigure's drain — stops it and cancels a round scheduled inside the debounce. THE RULE (`pathReading`): not satisfied ⇒
  cancel a scheduled round; satisfied after a not-satisfied reading ⇒ ONE `triggerSync()` after the debounce (so the
  occasion runs first — the Mac's retry, then her typing — and the restore hold gates it); satisfied after satisfied, or as
  the first reading, ⇒ nothing. **DECIDED AND RECORDED (the brief's "decide and record"): the first reading is never a
  trigger alone** — a chain just composed runs its own round (the sign-in's `triggerSync`), and a launch offline waits for the
  path to come up; a path that drops again inside the debounce cancels (a flapping network earns one round once it settles).
  `AppServices.init` gains `networkPath:` (production's `SystemNetworkPath()` by default; both platforms — the phone gets the
  trigger by sharing the file, as D-544 says) and hands it to the chain. `FirstRoundWorld` (test support) gains a
  `networkPath` the composed services take (production's by default) so the end-to-end world can plant one.
- *Pins (`SyncReachabilityTriggerTests`, a new suite, planted path + fake server; each round counted by its occasion):* THE
  PIN `aTransitionToSatisfiedRunsOneRoundAfterTheDebounce` (nothing at once, one round after), `theFirstReadingAloneRunsNothing`
  (satisfied or not), `aPathStayingSatisfiedRunsNothingMore`, `aPathThatDropsAgainInsideTheDebounceRunsOnlyOnceItSettles`,
  `eachSatisfiedTransitionRunsItsOwnRound`, `theWatchRidesTheChain` (a stop ends it and cancels the scheduled round; a
  reconfigure's fresh watch starts at a baseline), `aHeldStoreRunsNothingWhenThePathComesBack`, the guard `noPathIsInert`, and
  the composition `theServicesHandTheirPathToTheChain` (watched once the signed-in start composes the chain, released at the
  stop). End to end: `OfflineTypedUnlockRetryRoadTests.herStep9TheNetworkComingBackHealsItByItself` — her step 9 with NO
  press: after the offline unlock a full settle window passes with the vault out of reach (any owed trigger runs and fails),
  then the vault answers and the planted path comes up → one round, the retry first, "Synced", the keys in session memory,
  the keychain empty. All COMPILE-red on old (the path seam).
- *Evidence, headless at this commit:* Mac and phone `build-for-testing` → `** TEST BUILD SUCCEEDED **` both (one
  "no calls to throwing functions occur within 'try'" warning in the new suite, fixed); the harness, every touched planted
  suite (TypedUnlockRetry · TypedUnlockRetryOccasion · OfflineTypedUnlockRetryRoad · SyncReachabilityTrigger ·
  TypedUnlockSyncKeys · TouchIDUnlockSyncKeys · RoadLock · LobbyVaultRoad · SecretCheckRoad · FirstRoundAfterTheAct ·
  FirstRoundAfterTheReopen · FirstRunDrill) → `✔ Test run with 91 tests in 12 suites passed`; the trigger suite three runs
  in a row → `✔ 9 tests passed` each.
- *MACHINERY NOTE (honesty):* one foreground command running the Mac and phone builds back to back was moved to the
  background by the harness after 180 s; it was waited on synchronously (blocking on its output file) and its result read
  before anything else ran; the leftover `tail -f` was stopped. Builds run one per command from here.
- *THE NAMED BEHAVIORAL REVERTS (named BEFORE they run, at this commit's tip; the harness, one file each, then restored):*
  **R-4a** `pathReading`'s `guard previous == false else { return }` → `return` (no round ever follows the path) ⇒ expected RED
  THE PIN, `aPathThatDropsAgain…`, `eachSatisfiedTransition…`, `aPathStayingSatisfied…` (its first leg) and
  `herStep9TheNetworkComingBackHealsItByItself`; GREEN the nothing-runs pins. **R-4b** that guard → `guard previous != true`
  (a first reading counted as a transition) ⇒ expected RED `theFirstReadingAloneRunsNothing` (its satisfied leg) and
  `theWatchRidesTheChain` (the reconfigure's baseline leg). **R-4c** the not-satisfied arm's `reachabilityTask?.cancel()`
  removed ⇒ expected RED `aPathThatDropsAgainInsideTheDebounceRunsOnlyOnceItSettles`. **R-4d** `stopObservations`' path
  stop + cancel removed ⇒ expected RED `theWatchRidesTheChain` (still watched; the scheduled round runs after the stop — no:
  no chain then, `triggerSync` finds none — so the watch leg) and `theServicesHandTheirPathToTheChain` (not released).
  **R-4e** `AppServices.init` hands `path: nil` (both arms) ⇒ expected RED `theServicesHandTheirPathToTheChain` and
  `herStep9TheNetworkComingBackHealsItByItself`.
- *Piece 3b's evidence, run at `5ce6becf0` (the harness; the revert runner now refuses to run tests over a failed patched
  build — R-4a's first patch did not compile, `return // R-4a` swallowing the next line as its value, and its "green" over the
  stale binary is VOID; rerun as `if true { return }`):* **R-4a** → `✘ 10 tests, 5 failed` — exactly THE PIN,
  `aPathStayingSatisfied…` (its first leg), `aPathThatDropsAgain…`, `eachSatisfiedTransition…`, and
  `herStep9TheNetworkComingBackHealsItByItself` ("roundsCompleted > rounds" — no round followed the path); the nothing-runs
  pins green. **R-4b** → `✘` exactly `theFirstReadingAloneRunsNothing` (its satisfied leg) and `theWatchRidesTheChain` (the
  reconfigure's baseline). **R-4c** → `✘` exactly `aPathThatDropsAgainInsideTheDebounce…` (both legs). **R-4d** → `✘` exactly
  `theWatchRidesTheChain` (still watched after the stop) and `theServicesHandTheirPathToTheChain` (not released). **R-4e** →
  `✘` exactly `theServicesHandTheirPathToTheChain` and the step-9 pin. And the step-9 pin's own claim checked: under **R-3a**
  it is `✘` (the path's round ran — "roundsCompleted > rounds" held — but no retry: the row `.keysLocked`, no keys). Every
  revert restored; the harness sources are all symlinks again but the one stub file.

**Piece 4 — the words (NO CHANGE).** The row keeps VX-486's "Sync locked — this Mac hasn't unlocked your account's sync
keys" until the keys load (`SyncStatusViews.swift:767`, byte-unchanged — nothing in this batch touches the row); "Sync now"
keeps its road (`SyncStatusViews.swift:744` → `triggerSync()` — which now runs the occasion, so a press retries too) and the
Protection door keeps its road. No user-facing sentence was added or changed; the only new strings are protection-log lines
(diagnostics, `ProtectionOpenRoad.log` — act names and outcomes, never key material). No QUESTIONS filed.

**Piece 5 — Close.**
- *Headless at the close:* `swift build` (the core) → `Build complete!`; the core has ZERO changed lines in this batch
  (`git diff 93c2e3149..HEAD -- Sources Tests Server` is empty), so the core suite was not re-run — the batch-1 baseline
  stands unchanged by construction. Mac `build-for-testing` green at pieces 1, 3a, 3b; phone `build-for-testing` green at 3a
  and 3b. The harness, every touched planted suite: `✔ Test run with 91 tests in 12 suites passed`.
- *The pins, said plainly (compile-red vs behavior-red):* BEHAVIOR-red on the pre-fix tree, watched: THE ROAD PIN
  (`herOfflineTypedUnlockSyncsAtTheNextRoundOnceTheVaultAnswers` — pre-fix API only; over the four pre-fix product files the
  round still refused for keys). BEHAVIOR-red on old by inspection (pre-fix API until its `#require`): the phone's
  `thePhonesOccasionLandsPendingTypingAndRunsNoRetry` (`beforeRound` nil on the phone pre-fix — the simulator run owed).
  COMPILE-red on old (they name the new seam), each with a named behavioral revert that bit: every other pin of the five new
  Mac suites. GUARDS (green both sides by design): `aSuccessfulFirstLoadLeavesNothingPending`,
  `everyOtherExitLeavesNothingPending`, `noRoadsIsInert`, `noPathIsInert`, and the nothing-runs reachability pins.

**SELF-ASSESSMENT — where the derived secret lives, how long, and every road that clears it (the brief's three).**
- *WHERE:* in ONE place — `ProtectionRoadSession`'s private `pendingLoad`, read and written only under that session's
  `NSLock` — as a `PendingSyncKeyLoad`: the library's account id and `TypedUnlockSecret.passphrase([PassphraseKey])` (the
  passphrase keys the open's own Argon2id derived — `SymmetricKey`s with their descriptors) or `.wordsKey(WordsKey)` (the
  twelve words' BIP-39 → HKDF wrap key, derived ONCE at the keep). Never the passphrase's text; never the words (the typed
  `[String]` dies with the open's call exactly as before VX-544). Transient copies: the retry's one flight reads the pending
  into its stack and hands it to the load for the length of ONE bounded vault read (≤ 10 s) and the master's unwrap, then
  lets it go. Not `Codable`; every description redacted (`PendingSyncKeyLoad(redacted)`, `TypedUnlockSecret(redacted)`,
  `PassphraseKey(redacted)`, `WordsKey(redacted)` — pinned); never logged; NO write to disk or the keychain on any road
  (no keychain or file call exists on the path; the planted leaves' `items` stay empty in every pin).
- *HOW LONG:* from the typed unlock's vault read FAILING or TIMING OUT (the only keep) until the first of: the retry's hold
  landing; any other exit of a retry; a let-go road; the process ending. Never longer than the open road session it lives
  in — and the keys it can produce are held under exactly the lifetime session memory already had (VX-501's).
- *EVERY ROAD THAT CLEARS IT:* (1) **the hold landing** (`holdLoadedSyncKeys` — the retry's success); (2) **every
  non-failure exit of the load** (its `defer`): not writing / unbound / not Castle, the keys already held, signed out or into
  another account, no vault, a secret that opens the library but not the vault, a master not the vault's, a moved account, a
  hold refused (the session let go, another hold landed meanwhile, the library moved); (3) **the occasion's gate finding keys
  present** (an act or an unlock loaded them — `roads.clear()`); (4) **the let-go, final for the session**
  (`letGoOfSyncKeyLoad` — the pending dropped AND every later hold refused): the RELOCK (`ProtectionRoadLock.dropSessionMemory`,
  BEFORE the keys drop — Lock Now, sleep, screen lock, idle), Make this my library's OUTGOING session (the same drop,
  `ProtectionCopyDoors.swift:538`), a SIGN-OUT (`AppServices.variorumSignInChanged(nil)` — the Account sheet, sign out
  everywhere, the account's deletion), and a REOPEN that replaces the session (`AppBootstrap.finish(.ready)` — a re-keying
  act's reopen, a copy door's landing); (5) **the process ending** (memory only). NOT cleared by a second failure (kept —
  the same content re-kept; refused once let go).
- *The keys it loads never outlive the lock:* the hold is decided under the session's lock and the drop lets go under that
  same lock before it clears the leaf, so a retry whose read answers after the lock holds nothing (pinned:
  `aRetryAnsweredAfterTheLockHoldsNothing`, R-2b). A retry in flight at a sign-out keeps its stack copy for at most the bound,
  and its hold is refused.

**RECORDED CORNERS (for the orchestrator; none fixed here):**
1. **The phone keeps but never retries** (MOBILE PARITY): the keep is the SHARED load's, so an offline typed unlock on the
   phone now holds the derived secret in session memory — dropped at the lock, a sign-out, a replacing reopen — but nothing
   retries it there (override 5: the phone's retry unwired), so the phone stays "Sync locked" until its next typed unlock, as
   before. Posture-consistent per D-544 (memory, the session's lifetime) but purposeless on the phone today. Options: (a) as
   built; (b) `#if os(macOS)` around the keep (the phone byte-for-byte today's); (c) wire the phone's retry — one line, the
   retry call in the phone's closure arm. The orchestrator's/her call; nothing filed (no product behavior differs).
   **RULED (c) — wire the phone's retry** (the BATCH 2 ADJUDICATION below, PROVISIONAL P-849-3; built in the amendment
   commit — see "AMENDMENT — P-849-3").
2. **The occasion can delay a round by up to the vault bound (10 s)** while a pending exists, the keys are missing and the
   vault read hangs (a black-holed endpoint — offline reads fail at once); that round would refuse for keys anyway. Joined
   retries share the one read.
3. **Rounds the scheduler starts on its own** (the coalesced follow-up, the belt's) run no occasion — the trigger whose
   round they follow ran it.
4. **The reachability trigger runs one round for EVERY library on reconnect** (Standard and signed-in-unsynced included —
   R-849-2's ruled shape), and its first reading is never a trigger alone (decided here, recorded above).
5. **Keys that vanish without a relock after the gate cleared the pending** (an act's rollback dropping its own hold —
   `PlanRunner` :589) leave sync locked until the next unlock — the pre-VX-544 behavior in that corner.
6. **The doc line in D-544 "no typed-unlock pending on the phone's road today" is stale** (VM-8 brought VX-501 to the phone);
   corner 1 is its consequence (now ruled — P-849-3).

**MOBILE PARITY (for the closeout line — AMENDED for P-849-3):** the phone composes the SAME round occasion as the Mac —
VX-544's typed-unlock retry first, then batch 1's typing flush (P-849-2 and PROVISIONAL P-849-3, one shared closure) — and
the reachability trigger (the shared `SyncSession`, production's path watch through the shared `AppServices`). So the phone
heals the offline typed unlock exactly as the Mac does: the derived secret kept in session memory, retried before each round
while the keys are missing, dropped at lock/sign-out/reopen. D-544's "the phone's retry hook is unwired there" is the
recorded deviation (the BATCH 2 ADJUDICATION).

**Canon deltas owed at the closeout (the orchestrator's, two-file shape):** SurfaceContracts' protection bullet — VX-501's
typed-unlock sentence ("one bounded vault read … never hostage (offline, or a secret that opens the library but not the vault,
opens the library all the same)") gains VX-544's: offline or a slow server, the typed secret's DERIVED material is kept in
session memory only and the load runs again before each round while the keys are missing — the next round after the vault
answers syncs, nothing typed again; dropped at a lock, a sign-out, a replacing reopen (R-849-1). The round triggers — the
network path coming back runs one debounced round (R-849-2) — where canon names the rounds' triggers (no canon line lists
them today; `SyncSession.swift`'s header does; the orchestrator's call: AppSpec §11's summary or the sync row's contract).
CastleRules unchanged (rule 9 is the device's — D-544's posture paragraph). AppSpec §12's VX-501 mention unchanged in
substance.

**STAGE REQUEST (every Mac and simulator run of this batch — the orchestrator's claim through nov7; `-only-testing` takes
TYPE names):**
- *Leg A — the batch's own Mac suites at the tip (green expected):* `cd App/Variorum && xcodebuild test -scheme Variorum
  -destination 'platform=macOS' -only-testing:VariorumTests/TypedUnlockRetryTests
  -only-testing:VariorumTests/TypedUnlockRetryOccasionTests -only-testing:VariorumTests/OfflineTypedUnlockRetryRoadTests
  -only-testing:VariorumTests/SyncReachabilityTriggerTests -only-testing:VariorumTests/SyncBeforeRoundTests` — "Test run with
  41 tests in 5 suites" (14 + 5 + 5 + 9 + 8).
- *Leg B — the one Mac-only pin's revert (every other revert ran headless, above):* **R-3a** — `AppServices.swift`'s Mac closure
  line `await self?.retryTypedUnlockSyncKeysWhileLocked()` deleted, at the tip, alone ⇒ RED
  `SyncBeforeRoundTests/theMacsOccasionRetriesTheTypedUnlocksLoadBeforeHerTypingLands` (and the harness-proven
  `whileThereAreNoKeys…`, `withNothingPending…`, the road pin, the step-9 pin); `git checkout --` the one file, re-run green.
- *Leg C — the standing suites over the touched seams (or fold into LIVE STATUS row 8's closing sweep):*
  `TypedUnlockSyncKeysTests` · `TouchIDUnlockSyncKeysTests` · `SessionHoldBringInTests` · `RoadLockTests` ·
  `RoadLockRouteTests` · `LobbyVaultRoadTests` · `SecretCheckRoadTests` · `SecretCheckModelTests` · `SecretCheckBootstrapTests`
  · `MakeMineProofFieldsRoadTests` · `OneSyncKeysLeafCompositionTests` · `OneSyncKeysLeafRoadTests` · `FirstRoundRoadTests` ·
  `FirstRoundAfterTheActTests` · `FirstRoundAfterTheReopenTests` · `FirstRunDrillTests` · `WordsCardAfterAccountActTests` ·
  `PairFollowFacesTests` · `PairFollowDoneDurableTests` · `ProdTestRoadTests` · `SyncSessionFenceTests` ·
  `IdleCommitSchedulerTests` · `Phase9cAuthWiringTests` · `SyncLockedRowTests` · `SyncWalkFenceTests` ·
  `QuitPurgeQuiesceTests` · `SettingsLockCloseTests` · `AppBootstrapOffMainTests` · `ProtectionCrossingRouteTests` ·
  `RoadJoinFollowSurfaceTests` (type names verified by grep at the close).
- *Leg D — the phone (simulator, by id):* `xcodebuild test -scheme VariorumMobile -destination 'platform=iOS
  Simulator,id=<the run's simulator>' -only-testing:VariorumMobileTests/MobileRoundOccasionTests
  -only-testing:VariorumMobileTests/MobileTypedUnlockSyncKeysTests -only-testing:VariorumMobileTests/MobileLockTeardownTests
  -only-testing:VariorumMobileTests/MobileTypedOverRescueTests`; then **R-3g (AMENDED for P-849-3)** — the phone composing
  no occasion: `AppServices.swift`'s one shared `sync.beforeRound = { … }` assignment wrapped in `#if os(macOS)` … `#endif`
  (there is no `#else` arm any more — the closure is both platforms') ⇒ RED
  `MobileRoundOccasionTests/thePhonesOccasionRetriesThePendingLoadThenLandsHerTyping` — the phone's one occasion pin, whose
  `#require(beforeRound)` fails, so BOTH its legs (the retry ran first; her typing landed) go with it; nothing else in leg D
  reads the occasion. Restore (`git checkout --` the one file), re-run green.
- *OWED, never claimed:* her drill — the two-Mac test's steps 8–9 on her Air (LIVE STATUS row 9).


### BATCH 2 ADJUDICATION (the orchestrator, 2026-11-09 — repo-first before the fix resumes)

**Verification:** all eight commits present and pushed as reported; worktree clean; main `009982a3c` folded at
this seam (the pending fold-in list is empty). The 91-test headless result is the implementer's scratch-harness
claim — the evidence of record for the app-target pins is the STAGE WINDOW (legs A–D), run after the ruling below
lands.

**The phone call (the implementer's "for your call") — RULED (c), wire the phone's retry. PROVISIONAL P-849-3.**
The keep runs in shared code, so a phone typed unlock now mints a pending load; option (a) leaves a held secret
with NO consumer on the phone (minimal-exposure says don't hold what nothing uses), and (b) splits shared custody
code by platform. (c) gives the held secret its consumer, heals the same bug on the phone (whose reachability
trigger and flush occasion are already wired), and matches her mobile canon (a complete companion app). D-544's
"the phone's retry hook is unwired there" was written when the phone had NO wired hook at all — that premise moved
at P-849-2; the deviation is recorded here, PROVISIONAL for her bundle. The pin
`thePhonesOccasionLandsPendingTypingAndRunsNoRetry` flips by a JUSTIFIED EDIT to assert the retry DOES run (and
the leg-D revert R-3g's expected red moves with it). The posture is unchanged: session memory only, same drops
(CastleRules rule 9 binds the DEVICE's disk and keychain, not session memory — D-544's ruled paragraph).

### BATCH 2 — AMENDMENT: P-849-3 (the phone's retry wired — RULED (c) at the BATCH 2 ADJUDICATION, `c74b4fc19`)

**Pulled first** (`git pull`, a fast-forward to the orchestrator's `c74b4fc19` — main `009982a3c` folded at the seam; no
rebase). **Built (one piece):**
- *The one line, as one closure:* `AppServices.init`'s round occasion is now ONE `sync.beforeRound` closure for both
  platforms — `await self?.retryTypedUnlockSyncKeysWhileLocked()` then `await session?.flushPendingTypingBeforeRound()` — the
  Mac arm's exact shape and the same gate; the `#if os(macOS)`/`#else` arms collapsed because they became identical (the
  retry road was platform-shared already: the roads are wired in the shared `AppBootstrap.attach(services:)`, the gate and
  `retryPendingSyncKeyLoad` in shared files). Doc comments in `AppServices`, `AppBootstrap.attach(services:)`,
  `ProtectionOpenRoad.retryPendingSyncKeyLoad` and `TypedUnlockRetryOccasionTests`' header/suite name now say "both platforms
  (P-849-3)" where they said the Mac's.
- *The phone pin, by JUSTIFIED EDIT (the ruling flips its claim):* `thePhonesOccasionLandsPendingTypingAndRunsNoRetry` →
  `thePhonesOccasionRetriesThePendingLoadThenLandsHerTyping` (`App/Variorum/VariorumMobileTests/MobileRoundOccasionTests.swift`)
  — it now asserts the phone's occasion runs the retry FIRST (its log reads `["retry: typing pending"]` — the provider has no
  keys; her typing still pending when the retry runs), THEN her typing lands. Behavior-red on old still by its
  `#require(beforeRound)`; R-3g moved with it (leg D above).
- *A pin-robustness fix found on the way (same commit, recorded honestly):* one full-set harness run went `✘` on
  `SyncReachabilityTriggerTests.aTransitionToSatisfiedRunsOneRoundAfterTheDebounce` ("rounds == 1" read too early under the
  12-suite parallel load — its fixed 500 ms window). The positive waits now poll to the count with a 3 s deadline
  (`reach`), and re-checking R-4a over that edit EXPOSED a second hole: a fresh in-memory store's outbox is not empty, so the
  SETTLE observation's own trigger (3 s) could land inside a 3 s window and count as the path's round — R-4a then left three
  of its four pins green (only `eachSatisfied…`'s second count red). The suite's sessions now hold the settle trigger off
  (`settleDebounce: .seconds(60)`): only the path's rounds count. Re-checked: **R-4a → `✘` exactly its four named suite
  pins** (THE PIN, staying-satisfied, drops-again, each-transition); restored → the suite green three runs in a row. The
  earlier R-4a result (500 ms windows) stands valid — a 3 s settle could not land in it.
- *Evidence, headless:* harness — every touched planted suite, twice → `✔ Test run with 91 tests in 12 suites passed`; Mac
  `build-for-testing` → `** TEST BUILD SUCCEEDED **`; phone `build-for-testing` (generic iOS Simulator) → `** TEST BUILD
  SUCCEEDED **`; no warning in a touched file. Leg A's count is unchanged (41); leg B's R-3a now also removes the phone's
  retry (one closure) — leg B runs the Mac only; leg D carries the phone's pin and R-3g (amended above). The simulator run
  stays PENDING the stage window.
- *The posture, unchanged:* session memory only, the same keep and the same drops on both platforms (CastleRules rule 9 is
  the device's disk and keychain — D-544's posture paragraph); the phone's held secret now has its consumer.

**WINDOW FIX (leg A, 2026-11-09):** `TypedUnlockRetryOccasionTests` ran red, all five, each "Issue recorded at Date.swift:37:17"
(swift-dependencies' `\.date` getter): the suite built `AppServices` with no overrides, `AppSession.init` snapshots `\.date` at
construction (`AppSession.swift:856`; `SyncScheduler.swift:106` is a later, post-round site), and the real Mac bundle records an
unoverridden read — the scratch harness never detected test context and masked it (no product bug). Fix, test file only: each
test runs under `withWorld` (`SyncBeforeRoundTests`' `withDependencies` set — the services' own db, uuid, a constant date, a seeded
generator; owner identity left signed-out), services built inside; no pin reads those. Re-verification: the window's leg-A re-run.

### BATCH 2 — THE STAGE WINDOW (claim vx-849-batch2, 2026-11-09, the orchestrator's hands; GO slotted EARLY by nov7 at 04:41 — vx-913's gate had released and its merge needed no stage)

- **Tips:** first red run at `f4a323c5a`; the test-only fix `f500f94f3`; legs A (re-run), B and D all at `f500f94f3`,
  the tree verified clean before, between and after every cycle. nov7 approved holding the claim through the fix
  (the implementer edited/committed/pushed only — no builds or runs; the re-run was the compile proof).
- **Leg A at `f4a323c5a`:** "Test run with 41 tests in 5 suites failed … with 5 issues" — all five of
  `TypedUnlockRetryOccasionTests`, each at swift-dependencies `Date.swift:37:17` (the WINDOW FIX paragraph above:
  an unoverridden live `\.date` read the scratch harness masked — no product bug). **Leg A re-run at
  `f500f94f3`: "Test run with 41 tests in 5 suites passed"** (TypedUnlockRetry 14 · TypedUnlockRetryOccasion 5 ·
  OfflineTypedUnlockRetryRoad 5 · SyncReachabilityTrigger 9 · SyncBeforeRound 8).
- **Leg B — R-3a** (the one closure's retry line deleted; one-line diff verified): "18 tests in 3 suites, 9
  issues" — RED exactly the five named: `herOfflineTypedUnlockSyncsAtTheNextRoundOnceTheVaultAnswers` (3 issues) ·
  `herStep9TheNetworkComingBackHealsItByItself` (2) · `theMacsOccasionRetriesTheTypedUnlocksLoadBeforeHerTypingLands`
  (the order log) · `whileThereAreNoKeysTheOccasionRetriesThePendingLoad` (2 — the scripted log and the provider
  count) · `withNothingPendingTheOccasionReadsNoKeysAndRetriesNothing` (the occasion leg, as the harness predicted);
  13 green. Restored by `git checkout --` of the one file (diff clean at `f500f94f3`), re-run **18/18 green**.
*[removed for publication]*
  tests in 4 suites passed" — all four types present, none dropped (MobileRoundOccasion 1 · MobileTypedUnlockSyncKeys
  1 · MobileLockTeardown 1 · MobileTypedOverRescue 4). **R-3g** (`#if os(macOS)` around the one shared
  `sync.beforeRound` assignment; two-line diff verified): RED exactly
  `thePhonesOccasionRetriesThePendingLoadThenLandsHerTyping` (its `#require(beforeRound)`); restored, re-run
  **7/7 green**.
- **Posture:** no dev-store, Castle or server contact; zero app instances before and after; stage released at the
  end with this accounting (nov7 holds the RELEASE message verbatim).
- **Evidence standing:** batch 2's Mac/simulator pins now have their RUNS; the behavioral reverts R-3a and R-3g
  each bit exactly their named pins first-hand. Leg C (the standing suites over the touched seams) deliberately
  folds into LIVE STATUS row 8's closing sweep — one sweep over the merged tree, not two.

### BATCH 3 RECORD (the implementer — Opus, xhigh; opened 2026-11-09)

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild test` of any kind, no stage contact, no
Debug-app launch, no walk, no store or server contact — every Mac run below is **PENDING** the orchestrator's window
(the suites and named reverts at this record's end); zero lines under `Sources/VariorumCore/Sync/`; no
whole-package or whole-target headless run (nov7's heavy-headless rule — another session's window was live at
spawn; the heavy closes are listed PENDING at the end). Nothing of VX-443/VX-152/VX-545/VX-855/VX-921/VX-919.

**Preflight, read in this session (never delegated):** CLAUDE.md + the loaded canon; this file whole (STATUS,
KICKOFF, ROSTER, CONSTITUTION, ENVIRONMENT TRAPS, STAGE & COORDINATION, LIVE STATUS, every brief, both batch records,
both adjudications, the amendment, both window records, the mandate, the cutover state); `.claude/agents/
opus-implementer.md`; `notes/TEXTKIT2_NOTES.md` WHOLE; `notes/SurfaceContracts.md` §"The note"; the vx-440 record's
WALK FIXES whole (W-1's trace, WF-2, the general class, the VX-248 relationship); the vx-827 record's FOR A LATER
READER; `notes/plans/fixes/vx-683-sync-into-debounce.md` whole; `notes/SessionResiliencyProtocol.md` §implementer;
and — the fact the brief did not have — **the vx-677 record's VX-664 sections whole** (the design fork, A-677-1/2/3,
the S1–S21 sweep table, "as built", the window verdicts): VX-664's ONE seam was BUILT at VX-677 (`8bea570e3`,
merged), so piece 2 verifies and composes it rather than minting it. The code: `PaneTextAuthority`,
`OutsideWriteConfirmation`, `PaneSurface` (the representable's read/live arms, `rebindIfTakeChanged`), every ring
owner's delivery seam and focus door (`TakesViewModel.adopt`/`applyProjection`/`focus`/`blur`/`paneEdited`/
`consumeRestoreLanding`/`run`/`restoreCommit`/`expandAllFans`/`stableCellTake`/the open-fan memory,
`CompareViewModel`, `CanvasViewModel`, `BlockTOCViewModel`, `BookIndexEditModel` + `BookIndexView`'s observation),
`TakesBoardView.articleRow`/`washedCell`/`fanBadge`/`slotSplitBloom`, `TakesBoardLayout.isBloomed`,
`AutosaveCoordinator` (batch 1's), `AppSession`'s flush family + `flushPendingTypingBeforeRound`, the History &
Lineage surface's acts (`CommitsFaceModel.restore`/`bringBackSelected`/`bringBackFromLineage`) and its four hosts
(`PostDetailView`'s full pane, `WriteTakesPanel`/`TakesBottomBar`/`CommitBar`'s sheets), the phone's
`MobileBlockHistory.restore`, `ShellActions.structuralUndo`, the MCP door's flush (`MCPDoor+HerEditor`), and every
core writer of an existing take's `working_text` (`Operations.autosave`, `restoreCommitRows`,
`restoreCommitForClient`, `editTakeUnderInsurance`, `editTakesAtomically`, `extract`, `divide`,
`splitBlockAtNewlines`, `moveSpanToNewTake` + its inverses, the structural undo/redo inverses; `Sync/` read for
what apply writes, never edited). The pin suites read whole: `OutsideWriteRingEndTests`,
`OutsideWriteLivePaneTests`, `TypedOverRescueSurfaceTests`.

| # | Piece | Status |
|---|---|---|
| 1 | THE SWEEP TABLE (below — before any fix) | DONE (this commit) |
| 2 | The ONE seam verified + the batch-1 composition stated + the found gaps G1 (the unlanded guard) and G3 (the gap keystroke's snapshot) fixed with their pins | DONE — 2a the pins on the PRE-FIX tree (`d1a2b028e` — the red-on-old SHA); 2b the fix + the two primitives' pins (this commit); Mac + phone `build-for-testing` green; the instrument green 2/2 (its named reverts run next, at this tip); every Mac run PENDING the stage |
| 3 | P-849-1 — the restore doors: flush-first verified, ONE quiet insurance savepoint (`restoreCommit(…, insuringBuffer:)`), the dead board door aligned | IN-PROGRESS — 3a the door pins on the PRE-FIX tree DONE (this commit — the red-on-old SHA; `RestoreFlushFirstInsuranceTests`, Mac `build-for-testing` green; runs PENDING the stage); 3b the op + core pins + the two doors next |
| 4 | R-683-4 — the post-rescue face pinned (mounted Takes board, both roads) + the slot-split corner (G2, PROVISIONAL P-849-5) | NOT STARTED — design settled below |
| 5 | Pins compiled (`swift build`, targeted core `swift test`, both `build-for-testing`s) + the stage list + the self-assessment | NOT STARTED |

#### Piece 1 — THE SWEEP TABLE (every road that rewrites a take's `working_text` from outside a live pane bound to that take, × every host a live pane can sit on)

**How the class is closed, so the table reads right.** VX-664's mechanism is CONSUMER-side, not per road (A-677-1,
the vx-677 record): every ring owner's delivery seam calls `PaneTextAuthority.settle(isPending:liveIncoming:)` —
"the delivered stored words for the live pane's take differ from what it HOLDS, with nothing of hers pending" — and
`OutsideWriteConfirmation.endRing` confirms on a fresh one-row read, then the owner's own `blur()` ends the ring
(VX-222/VX-440's shape; the pane goes read and adopts through the representable's read arm; P-3 unbent). So a road
is covered on EVERY host the moment its write reaches the store, and the table's two axes verdict separately:
(a) each HOST's seam (is it wired, pinned, unchanged since VX-677?) and (b) each ROAD (does it write an EXISTING
take's text from outside the pane — and if so, which host's pin exercises it?). Re-verified at `80d97cb6e`:
`PaneTextAuthority.swift`, `OutsideWriteConfirmation.swift`, `PaneSurface.swift` carry ZERO commits since
`8bea570e3`; the five owners' seams are byte-for-byte VX-677's except batch 1's `basedOn:` on `paneEdited`; the
pane hosts are exactly the eight `PaneSurfaceView` hosts VX-677 counted (no new pane host since — the History &
Lineage surface's reading pane owns no authority and is never live); the core writers of an existing take's text
are exactly VX-677's set (grep of every `workingText =` / `working_text` write under `Sources/`, `Sync/` read-only)
plus batch 1's guarded-autosave arm.

**(a) The hosts — each seam, verdicted (pins are the standing VX-677 suites unless marked NEW).**

| Host | Owner · seam | Defers while dirty? | Verdict |
|---|---|---|---|
| H1 Takes | `TakesViewModel.adopt` (via `deliver` → `EditorProjectionPolicy`; a fresh read settles a held value) | YES (`autosave.isDirty` = pending OR writing) | COVERED — `OutsideWriteRingEndTests.takesRingEndsWhenAnAIEditsItsTake` (+ Split, Divide, Undo, Another-window) · mounted `OutsideWriteLivePaneTests.aLiveTakesArticleShowsAnAIsEditToItsOwnTake` |
| H2 Lenses | the same model, `host = .lenses` (+ VX-440's parcel blur on `LensesBoardView`) | YES | COVERED — `lensesRingEndsWhenASyncPullWritesItsTake` |
| H3 Write's take panel | the same model, `writePanelBlockID` set (its History is a SHEET over the panel — the panel's pane stays mounted beneath) | YES | COVERED — `writePanelRingEndsWhenBlockHistoryRestoresItsTake` (VX-827's justified edit: drives `CommitsFaceModel.restore`) |
| H4 Compare | `CompareViewModel.adopt` | YES (`anyDirty` over its coordinators) | COVERED — `compareRingEndsWhenBlockHistoryRestoresItsTake` |
| H5 Canvas | `CanvasViewModel.adopt(face:)` | YES | COVERED — `canvasRingEndsWhenASpanMovesOutOfItsTake`, `…WhenAnExtractCutsItsTake`; guard `aStalePhotographNeverEndsHerRing` |
| H6 Read's edit face (Read ▸ edit) | `BlockTOCViewModel.adopt(rows:)` | **NO — adopts every delivery** | COVERED for a landed write — `readEditRingEndsWhenAnAIRestoresACommitIntoItsTake`; **GAP G1 below** for a delivery consumed while her own write is in flight |
| H7 Blocks workbench (panel pane) | `BlockTOCViewModel.adopt(facts:)` | **NO** | COVERED for a landed write — `workbenchRingEndsWhenWriteReplacesInEveryTake`; **G1** |
| H8 book Index | `BookIndexEditModel.settle(postID:rows:)` from `BookIndexView`'s per-note observation | **NO** | COVERED for a landed write — `bookIndexRingEndsWhenAnotherWindowTypesItsTake`; **G1** |
| H9 a second window | every window's OWN owner (one `AppSession`, one coordinator per post; the store write reaches each window's observation) | — | COVERED — `takesRingEndsWhenAnotherWindowTypesItsTake` (two models on one session; the typing window's ring stays) |
| (H10 Write's full-document editor) | not a pane: `EditorViewModel`'s projection policy re-renders a clean block differentially, defers while dirty | — | N/A to the ring (VX-677's S20); the pending case is batch 1's B (pinned there) |

**(b) The roads — every writer of an existing take's text, from the core outward (S-numbers are VX-677's; N- rows are
born since VX-677 and verdicted here first).**

| # | Writer (core) · doors | Outside write on an existing take? | Verdict (pin) |
|---|---|---|---|
| S1 | `restoreCommit` · **the History & Lineage surface's Commits face Restore** (`CommitsFaceModel.restore`, VX-827 — the Block History panel RETIRED): full pane in the note's detail (the mode's surface UNMOUNTS; its teardown flushes), or a sheet over Write's take panel / the Takes bar (book spread's Takes sheet) / Write's inline editors (`CommitBar`); another window's face on the same note | YES (her deliberate act; flush-first at the door — `flushExistingAutosave(forPost:)`, honest since VX-402, one coordinator per post across windows) | COVERED on every host by the seam — `writePanelRingEndsWhenBlockHistoryRestoresItsTake`, `compareRingEndsWhenBlockHistoryRestoresItsTake`; the full-pane host has NO mounted surface during the act (the returning board re-rings with the restored words as `showing:`); VX-440's `RestoreLandingTests` W-1 pins stand (the parcel blur — redundant by construction, KEPT: it ends the ring before the restore landing can re-ring the same key). **P-849-1's insurance (piece 3)** |
| S2 | `restoreCommitForClient` · MCP `restore_commit` (bracketed; the door flushes `flushEveryOpenPost` first) | YES | COVERED — `readEditRingEndsWhenAnAIRestoresACommitIntoItsTake` |
| S3 | `editTakeUnderInsurance` · MCP `edit_take` | YES | COVERED — `takesRingEndsWhenAnAIEditsItsTake` + mounted `aLiveTakesArticleShowsAnAIsEditToItsOwnTake` |
| S4 | `editTakesAtomically` · Write's Replace / Delete in Every Take, Make Block's edge checks, the cross-block compound | YES (takes Write does not show, live in a panel/another window) | COVERED — `workbenchRingEndsWhenWriteReplacesInEveryTake` |
| S5 | `extract` (the source keeps the remainder) | YES | COVERED — `canvasRingEndsWhenAnExtractCutsItsTake` |
| S6 | `divide` (single take in place) · Write ⌘D / the typed Return (VX-806), MCP `divide_block`; the board's own divide parks its ring on C | YES (from outside the pane) | COVERED — `takesRingEndsWhenADivideCutsItsTake` |
| S7 | `splitBlockAtNewlines` · the board's three split doors (flush-first via `flushPendingText`), Write's note ▾ | YES (the ring's own block keeps its first paragraph) | COVERED — `takesRingEndsWhenTheBoardSplitsItsBlockAtNewlines` |
| S8 | `moveSpanToNewTake` (source = remainder) + its undo/redo | YES | COVERED — `canvasRingEndsWhenASpanMovesOutOfItsTake` |
| S9 | the structural undo/redo text restores (`UndoInverses`, `SpanToTake`'s inverses) · ⌥⌘Z / ⇧⌥⌘Z from any window | YES | COVERED — `takesRingEndsWhenAStructuralUndoRestoresItsTake`. **Corner C2 below: the undo/redo DOOR does not flush pending typing first** |
| S10 | `autosave` from another surface · another window's live pane; Write's editor on a take a panel holds | YES | COVERED — `takesRingEndsWhenAnotherWindowTypesItsTake`, `bookIndexRingEndsWhenAnotherWindowTypesItsTake` |
| S11 | the sync pull's apply (`Sync/`, read only): clean row → the server text on the row; dirty row → server wins the row, the local text a `'conflict'` take (S5) | YES | COVERED UI-side from the store's own delivery, zero `Sync/` lines — `lensesRingEndsWhenASyncPullWritesItsTake`; the dirty-row arm is the composition N2 pins (NEW, piece 4) |
| N1 | **batch 1's guarded `autosave` rescue** (VX-683 B): her text on the row + the displaced words as a NEW `'conflict'` take | for the TYPING pane: NO (its own words — the echo equals `liveHeld`); for any OTHER pane live on the take: YES = S10's road | the typing pane: COVERED as her own echo — `herOwnTypingNeverEndsTheRing` + batch 1's guards; the ring DELIBERATELY stays (composition below; NEW mounted face pin, piece 4); another pane: S10's pins. **G1 is the one hole in this row** |
| N2 | **batch 1's flush-first occasion** (VX-683 A) then S11's DIRTY-row arm | the flush: NO (her own typing landing); the apply: YES | COVERED by the seam (the ring ends, the pane adopts the server's words, her flushed words are the `'conflict'` card) — NEW composition pins (piece 4), green on both sides BY DESIGN (A-677-1 already ends it) |
| S12 | the MCP door's other tools (`add_take(s)`, `insert_blocks`, `duplicate_note`, `import_document`, `merge_blocks`, `delete_take`/`archive_take`, `choose_take`, labels/locks/lenses/comments, VX-808's `propose_notes_to_book`, VX-827's reads) | NO (new rows, membership, metadata, or S18) | N/A — mechanism per tool (VX-677's S12; the born-since tools write no existing take's text) |
| S13 | sync repairs (`Repairs.swift`: status / resurrection / labels) | NO (never a live take's text) | N/A |
| S14 | `resolveSyncConflict` | NO (mints a NEW take) | N/A |
| S15 | `restoreNoteVersion` (Note ▸ Versions) | NO (the outgoing blocks leave; their cells unmount) | N/A |
| S16 | `TakesViewModel.restoreCommit` | — (no production caller; `TutorialWalkTests` only) | N/A today; ALIGNED by P-849-1 (piece 3) so no future caller inherits a non-flushing restore |
| S17/N3 | new rows: branch / blank / `bringBackCommitAsTake` (VX-440) / **`bringBackFromLineage` (VX-827)** / duplicate / import / crystallization / `poolDragCopy` / the ceremonies' mints | NO | N/A |
| S18 | the live take deleted / archived / released / chosen away from outside | NO (not a text write) | N/A — VX-222/VX-227's end-rules or the cell leaves |
| S19 | a lock from outside | NO | out of class (r2) |
| N4 | **the Lineage face's acts (VX-827)**: Put back (`placeBlock`), Bring back as a take (mints), Compare with now (reads) | NO | N/A |
| S21 | the go-live render (a delivery sharing her click's turn) | — | COVERED — `PaneGoLiveAdoptionTests.aPaneTurnedLiveInTheRenderThatChangesItsTextShowsTheNewText` (A-677-2, B2-i ratified) |

**What the sweep FOUND (each fixed or recorded below; the fixes route through the ONE seam — no per-road patch):**
- **G1 — the pending guard's in-flight hole (a real composition gap with batch 1; FIX in piece 2).** The seam's "nothing
  of hers pending" reads `autosave.pending[take] != nil`, but `AutosaveCoordinator.flushNow` takes the batch and
  CLEARS `pending` BEFORE its write lands (`pending = [:]`, then `writing = true`, then the awaited runner turn). Three
  owners adopt deliveries while a write flies (H6/H7/H8 — no dirty defer), and every owner's CONFIRMATION runs after an
  off-main read, i.e. possibly while a write flies. Traced on batch 1's straggler road (the brief's own case): she types
  "AB" (pending, built on "A") → a pull lands "S" on the clean row → her debounce fires (pending cleared, the rescue
  write in flight) → Read ▸ edit consumes the pull's delivery: `isPending` false, "S" ≠ held "AB" → suspect → the fresh
  read runs on a reader while her write is still in the writer → "S" → CONFIRMED → `blur()`: her ring ends MID-TYPING
  (the live-only pane unmounts) although her write then lands her words on the row and rescues "S" as the card — the
  case where the brief says "the ring deliberately does NOT end". And `settle` drops her buffer in the same window, so
  any read-side mirror of the take (the authority's overlay) reads the pull's text until the echo. No words are lost
  (the write lands); the ring and the mirror are wrong. FIX: the coordinator answers `isUnlanded(take)` (pending OR in the batch in flight) and every
  owner's settle and confirmation ask that — "nothing of hers UNLANDED". The deferring owners (H1–H5) adopt only clean,
  so their adoption is byte-unchanged; their confirmation gains the in-flight decline. Pinned red-on-old by behavior on
  Read ▸ edit with a HELD writer (deterministic — `WriterHold`, batch 1's rig).
- **G2 — the post-rescue face in SLOT SPLIT (R-683-4's one face defect; PROVISIONAL P-849-5, piece 4).** A slot-split
  bloom REPLACES the block's article cell with its fan cards (`TakesBoardView.articleRow`: `bloomed && .slotSplit &&
  hasFan`). A block that is BLOOMED while it holds one take (her first-take door open — R72's growth doors — or
  follow-the-scroll on with the row visible) becomes `hasFan` the moment the rescue's `'conflict'` card arrives, so the
  cell holding her LIVE pane is replaced under her caret: the ring stands on a `takes-main` key no surface renders (the
  R112 class), her keyboard dead until she clicks a card. Her words are safe (the rescue landed them); the face is
  wrong. Not rescue-specific: any take arriving from outside on her ring's block in that state (an AI's `add_take`, a
  sync's new take). VX-577's expand-all arm is the same shape for HER act (blur); VX-222 is the shape for an outside
  change that re-resolves the ring's cell (blur). Every other style keeps the article cell (the stack/carousel blooms
  render beside it; the margin grid's rail engages around it), so nothing moves there but the rail (below).
- **C1 — margin grid + follow-the-scroll (an observation, no fix):** the first fan a note ever holds engages the margin
  rail, re-centring the article column (`railEngaged` → `articleMeasure`) — the presentation rule's own consequence
  (D2/AD-6), on any first take arriving, rescue or not. Recorded for the walk; not a ring defect.
- **C2 — the structural undo/redo door does not flush pending typing (P-849-1's sibling; RECORDED, not widened):**
  `ShellActions.structuralUndo`/`structuralRedo` run the inverse with her typing still in the debounce; the inverse
  rewrites the take, her pending autosave then lands built on the pre-undo text → batch 1's guard rescues: her text
  keeps the row and the undo's restored words become a `'conflict'` card (pre-VX-683: her typing silently overwrote the
  undo). A deliberate act of hers minting the card — R-683-2's premise — the same class P-849-1 closes for restores.
  The flush-first doctrine would close it (the door's warn→act latch is the place); outside P-849-1's named scope (the
  restore doors) — the orchestrator's to adjudicate or ticket.
- **C3 — the confirmation hole is not only G1's owners:** even a deferring owner's suspicion (raised at a clean adopt)
  is confirmed after an off-main read; a flush-first door firing in that window (the sync occasion, a mode switch)
  puts her write in flight → old: confirmed → ring ends; G1's fix declines it too (one closure per owner).
- **G3 — the gap keystroke's snapshot (found writing G1's pins; a data-loss hole; FIX in piece 2).** A live pane never
  adopts projection text (P-3), so between a delivery that carried an outside write and the ring-end its confirmation
  runs (one fresh read + a main-actor hop), the owner's PROJECTION already holds the outside words while the pane still
  shows hers. Every pane owner's `paneEdited` computes the edit's `old` — batch 1's snapshot AND the churn cost — as
  `authority.text(variantID:storeText: <the projection's text>)`; the settle just dropped the buffer, so `old` is the
  OUTSIDE text. A keystroke in that gap: `record(basedOn: <outside words>)` → the confirmation declines (her typing is
  pending — correctly) → the ring stays → her autosave lands her pre-write words with `expectedText` = the outside
  words → the row "still holds the snapshot" → NO rescue → the outside words are overwritten unseen (an AI's edit
  survives only in its "after" savepoint; a phone's words survive NOWHERE — its push CAS-accepted). VX-664's own
  write-back class re-entering through the confirmation's gap, and batch 1's B, as built, cannot see it (batch 1's
  self-assessment claimed this road rescued — true only while the owner's projection has not yet adopted the write).
  Traced on all five owners (Takes/Lenses/Write's panel, Compare, Canvas, the TOC model, the book Index — the same
  `old` line). FIX: `PaneTextAuthority.shownText(variantID:storeText:)` — for the LIVE pane's take, what the pane HOLDS
  (`liveHeld` — the very fact the ring-end rule judges by), else the buffer overlay; the five `paneEdited`s read it for
  the snapshot and the cost. Then a gap keystroke is built on the words she saw, the row changed under it, and the
  rescue keeps both. Pinned red-on-old by behavior on Takes and Canvas.
- **R1 — a residual, face-only (recorded, not built):** a confirmation whose fresh read ran while her write flew and
  which resumes AFTER that write landed reads a pre-write row with nothing unlanded → it can still end her ring
  spuriously (the pane then adopts her own landed words — no loss, by G3). Closing it needs a per-take landing mark
  read before and after the confirmation's read (five owners' closures); the window is one read wide AND needs a flush
  door to start and land a write inside it. For the ladder's eye.

**P-849-1's door enumeration (the doors that REWRITE the typing take's text by HER act):** `CommitsFaceModel.restore`
(the Mac's one production restore door — flushes first, honest; NO insurance savepoint) · `TakesViewModel.restoreCommit`
(no production caller; `run` with NO flush — the batch-1 corner's door) · the phone's `MobileBlockHistory.restore`
(flushes, refuses while dirty; no insurance — MOBILE PARITY, recorded; the VM board's surface) · the board's split /
divide doors (flush-first ✓, structural — not restores) · Write's every-take edits (`runStructural`'s flush over the
post's ONE coordinator ✓) · the undo/redo door (C2 — no flush). Every other board `run` door (choose · pick · lens
doors · fan style · archive/unarchive/label/lock/delete take · commit · seal · entry date · newlines chip · word target ·
reorder) writes no take's text. **So the "conflict card on her own restore" race has NO production door today** (the
Mac's restore flushes, and its hosts are modal or replace the board); P-849-1's live content is the insurance
savepoint plus aligning the dead door.

**The composition with batch 1, stated (piece 2's brief line, verdicted on the code):**
- *A's road (the flush-first occasion):* her pending typing lands before the round (her own echo — no ring-end);
  the round's pull then meets a DIRTY row: S5's arm puts the server's words on the row and her flushed words in a
  `'conflict'` take; the next delivery (clean — nothing pending) carries stored words that differ from what her pane
  holds → suspect → confirmed → the ring ENDS and the pane, read, adopts the server's words; her words sit on the card
  (the memo's "(ii)-shaped" apply, made concrete by VX-664's ring-end — the memo's "she then keeps typing into a buffer
  whose base is now stale" holds only while she is mid-keystroke at the apply, which is B's road below).
- *B's road (the millisecond stragglers, and every round with no occasion):* her typing is pending (or, after G1, in
  flight) when the pull's write lands → no suspicion (the guard) → her autosave fires on the snapshot its run was built
  on, finds the row changed, RESCUES: her words keep the row, the pull's words become the card → the echo equals what
  her pane holds → the ring DELIBERATELY stays; the card appears in the fan; the badge reads ⑂2. Nothing moved under her
  caret (R-683-1) — except G2's slot-split corner.
- *Nothing in either road needs a `Sync/` line* — the apply's write is consumed from the store's own delivery.

**The settled designs for pieces 2–4 (recorded before code; PROVISIONAL marks where the rulings do not decide):**
- *Piece 2 (G1 + G3):* `AutosaveCoordinator.isUnlanded(_:)` (pending, or a member of the batch being written —
  `inFlight`, each take leaving it as its own write's turn ends); the five owners' settle + confirmation closures read
  it. The authority's doc line "every buffer with no pending autosave record has fully landed" gains the in-flight
  half. `PaneTextAuthority.shownText(variantID:storeText:)` (the live take → `liveHeld`, else the overlay); the five
  `paneEdited`s build the edit's `old` from it.
- *Piece 2's pins (`OutsideWriteRescueCompositionTests`, Mac; all drive PRE-FIX API, so behavior-red at the 2a SHA):*
  G1 — `aPullConsumedWhileHerRescueWriteFliesLeavesReadEditsRing` (Read ▸ edit; the writer HELD so the write is
  provably in flight and the confirmation's reader provably sees the pre-write row — deterministic; red lines: the
  ring ended; her buffer dropped), `aPullConsumedWhileHerRescueWriteFliesLeavesTheIndexRing` (the book Index, same
  staging). G3 — `aKeystrokeInTheConfirmationGapIsRescuedNeverWrittenOver` (Takes; the AI's `edit_take`, the board's
  adopt, her keystroke in the same turn — red line: no `'conflict'` card holds the AI's words),
  `aCanvasKeystrokeInTheConfirmationGapIsRescuedNeverWrittenOver` (Canvas, same). GUARD (green both sides):
  `readEditsOwnSuccessiveRunsNeverMintACardNorEndTheRing`.

#### Piece 2b — the fix, as built (Mac files; zero `Sync/`, zero core)
- *`AutosaveCoordinator` (shared):* `inFlight` (the batch's takes, each leaving as its own write's runner turn ends — a
  refused one is back in `pending` first, so it never reads landed) and `isUnlanded(_:)` (pending OR in flight). Purely
  additive: `pending`, `isDirty`, the honest flush's order and the keep-pending posture are byte-unchanged.
- *`PaneTextAuthority`:* `shownText(variantID:storeText:)` — the live take → `liveHeld`, else the overlay; `settle`'s
  doc states that "pending" means unlanded.
- *The five ring owners* (`TakesViewModel` — Takes, Lenses, Write's take panel — `CompareViewModel`, `CanvasViewModel`,
  `BlockTOCViewModel` — Read ▸ edit, the Blocks workbench — `BookIndexEditModel`): every `isPending` closure handed to
  `settle(isPending:liveIncoming:)`, to `OutsideWriteConfirmation.endRing` and to the Index's old `settle()` reads
  `isUnlanded` (ten closures — the grep of `.pending[` in production is now empty); every `paneEdited` builds the edit's
  `old` (snapshot AND churn cost) from `shownText`. The deferring owners' adoption is unchanged by construction (they
  adopt only with the coordinator clean); the TOC model and the Index keep her buffer through a flight.
- *The primitives' pins (same suite; they NAME new API — compile-red on the pre-fix tree):*
  `isUnlandedAnswersPendingAndInFlightAndLandedOnlyAfterTheWrite` (the held writer), `shownTextIsWhatTheLivePaneHolds`
  (the pure truth table: nothing live → store; live → its holding, never the moved projection; another take → overlay;
  her keystroke → her text; blurred → overlay; a live pane with no known holding → overlay).
- *Evidence, headless at this commit:* Mac `build-for-testing` → `** TEST BUILD SUCCEEDED **` (no warning in a touched
  line — `CompareBoardView.swift:1988`'s is pre-existing); phone `build-for-testing` (generic iOS Simulator) →
  `** TEST BUILD SUCCEEDED **`. THE INSTRUMENT (batch 1's method — byte copies of the committed `PaneTextAuthority`,
  `AutosaveCoordinator` and `OperationsRunner` in an UNTRACKED scratch folder of the core test target, the two
  primitives' pins ported; never committed, deleted after): `swift test --filter ScratchPrimitives` → `✔ 2 tests
  passed`.
- *THE NAMED BEHAVIORAL REVERTS (named here BEFORE they run, at this commit's tip):* on the INSTRUMENT's copies —
  **R-G1i** `isUnlanded`'s body → `pending[variantID] != nil` (the in-flight half gone) ⇒ expected RED: the isUnlanded
  pin's in-flight line only; **R-G3i** `shownText`'s live arm deleted (always the overlay) ⇒ expected RED: the truth
  table's "the live pane's holding, never the projection" line only (after her keystroke the overlay holds her buffer,
  so that line stays green). For the STAGE (Mac, each alone at the tip, then `git checkout --` of the one file):
  **R-G1** `AutosaveCoordinator.isUnlanded` → `pending[variantID] != nil` ⇒ RED
  `aPullConsumedWhileHerRescueWriteFliesLeavesReadEditsRing` (both its red lines), `…LeavesTheIndexRing`,
  `isUnlandedAnswersPendingAndInFlight…`; **R-G3** `PaneTextAuthority.shownText` → `text(variantID:storeText:)` ⇒ RED
  `aKeystrokeInTheConfirmationGapIsRescuedNeverWrittenOver`, `aCanvasKeystrokeInTheConfirmationGap…`,
  `shownTextIsWhatTheLivePaneHolds`. And the red-on-old run: the four behavioral pins at `d1a2b028e` (the pre-fix
  tree) ⇒ RED each on its named lines; the guard green.
- *The instrument's reverts, run at `06856b011` (on the untracked copies; the worktree never touched):* **R-G1i** → `✘ 2
  tests, 1 failed` — exactly `isUnlandedAnswersPendingAndInFlight…` at its `whileFlying` line; the truth table green.
  **R-G3i** → `✘` exactly `shownTextIsWhatTheLivePaneHolds` at "the live pane's holding, never the projection" (its
  only red line, as named); the in-flight pin green. Each copy restored byte-identical to the committed file (`cmp`) →
  `✔ 2 tests passed`; the scratch folder deleted, `git status` clean.
- *Piece 3 (P-849-1, PROVISIONAL, isolated):* `Operations.restoreCommit(_:commitID:insuringBuffer: Bool = false)` —
  inside the restore's ONE transaction, when the restore will change the take's text AND its buffer differs from its
  latest savepoint (`isDirty`), ONE `kind='auto'` savepoint (unnamed — her road's quiet kind; the MCP bracket's named
  pair stays the wire's) of the buffer first; default `false` keeps every other caller byte-unchanged (the MCP road
  calls `restoreCommitRows` inside its own bracket and is untouched). The flip is one argument at each door:
  `CommitsFaceModel.restore` (after its honest flush) and `TakesViewModel.restoreCommit` (which gains the flush first).
  No undo entry (the op registers none, as before); touch/churn unchanged (the savepoint writes none).
- *Piece 4 (R-683-4 + G2):* mounted face pins on THE Takes board — the rescue under her live pane (stack, fan closed and
  fan open), the flush-first round under her live pane — plus G2's model-level pin; **G2's PROVISIONAL P-849-5 build:
  (a) an adoption under which slot split replaces the ring's article cell ENDS the ring by the flushed blur** (VX-222's
  outside-change shape; VX-577's style rule) — the smallest, precedent-backed answer that never strands a ring; the
  recorded alternatives for her: **(b)** carry the ring onto the fan card that renders the same take, the caret where it
  was (she keeps typing; the most R-683-1-faithful, new choreography); **(c)** hold the slot-split bloom of the block
  her ring is in until the ring leaves (the presentation waits for her). QUESTIONS at the merge.

## HER OVERNIGHT MANDATE (2026-11-09, the compaction sitting — her words verbatim; binding on the resumed orchestrator)

"ok - this seems like a good moment to prepare for compaction. update all your docs as needed, give me a post
compaction kickoff prompt. when you give me your handoff in the morning, explain all the most important items in
plain english for a reader with no context (me) to be able to understand. include that in the instructions. I'm
going to compact you, send you the kickoff prompt, and then you will be running everything provisionally overnight
and bundling it, merging everything. don't put a release onto stargazing.tech, but it should be *ready* to release
when I say the word - already built. I'll handle that release in the morning after going through all handoffs."

**Applied, with nov7's same-night wave rule (relayed to all live efforts):** every call that would normally wait
for her runs PROVISIONAL-and-continue and joins the morning bundle; the run finishes its batches, ladder and
closeout and MERGES to main (serialized through nov7); release prep belongs to the wave's LAST MERGER ONLY, on
nov7's GO — the 1.4 bump commit, ReleaseNotes-1.4.md drafted as PUBLIC COPY for her approval (never a ticket id or
process line — the VX-708 rule), the step-0 drill + first-run walk under stage claims, and `Tools/Release/release.sh
--version 1.4` STOPPING AT ITS HANDOFF. Nobody else touches MARKETING_VERSION, ReleaseNotes-*.md or release.sh. NO
site upload, NO appcast copy, NO deploy, NO /Applications install — hers in the morning. If this run ends up the
last merger AND this orchestrator is Fable: the first-run WALK legs are handed to an OPUS session (the Fable
safeguard — live Castle walks trip [cyber]); Fable drives the rest. HARD STOPS that survive the mandate: her Air
drill (post-release via Sparkle), VX-919's production deploy, anything needing her accounts/hands.

## CUTOVER STATE (written at the compaction seam, 2026-11-09 ~04:4x — the resumed orchestrator verifies, never trusts)

- **Tip `f876c8661`** on `vx-849-typed-over-rescue`, clean, pushed; main folded through `38e8f7e31` (vx-913's and
  vx-926's merges will move main again — fold at every seam; vx-913 shares ZERO files with us, trial clean).
- **Batch 1 (VX-683+VX-402): CLOSED** — window record in BATCH 1 ADJUDICATION. **Batch 2 (VX-544+P-849-3):
  BUILT**, awaiting claim `vx-849-batch2` (GO ~05:05 from nov7; legs A/B/D + expected counts in the BATCH 2
  RECORD's STAGE REQUEST; leg C folds into the closing sweep). The window is THE ORCHESTRATOR'S OWN HANDS —
  foreground the legs, SEAM pings per leg, RELEASE with Executed counts and every failure by name.
- **Batches 3 and 4: briefs STAGED above, spawn AFTER the batch-2 window** (batch 3 edits TakesViewModel, which
  leg A's suites mount — never contaminate the window). **Batch 5 (VX-855): brief unwritten** — trace-first, the
  repro may need a dev-store window (serialize vs vx-913's VX-81 repro; posture rules in STAGE & COORDINATION).
  **Batch 6 (VX-921+VX-919): brief unwritten** — the B2 worked pattern is in this file's roster row; VX-919's
  script is authored only, deploy HELD.
- **Then:** the LADDER (fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, whole diff; rounds per
  CLAUDE.md; cross-model flow — the reviewer finals, the implementer applies, FINDER-FIXES/Sync/ lines the
  reviewer's own); the ORCHESTRATOR'S WALK of batches 3's and 4's faces (UI-kind evidence; dev store, stage,
  posture restored); the closing sweep: WHOLE Mac + phone on the MERGED tree + the eye-read of AppSession's merged
  body (the vx-915 overlap terms, three shared files); the full closeout ritual (canon deltas queued in both batch
  adjudications; the two-file rule; canon-size reported; tickets closed and FILED ones triaged; the rulings
  reconciled; MOBILE PARITY — the phone heals as the Mac does, batch 2; worktree removed, branch deleted after
  merge; NO /Applications refresh — VX-931).
- **The morning bundle (hers):** P-849-1 (the board doors' flush-first — explained plainly to her this sitting,
  unanswered), P-849-2 (the phone flush occasion), P-849-3 (the phone retry), P-849-4 (the envelope delete), plus
  whatever the night births; the QUESTIONS entry files AT THE MERGE on latest main. Her Air drill and VX-919's
  deploy stay OWED. The author handoff (`notes/handoffs/vx-849-handoff.md`): HER CHECKLIST AT THE TOP, and per her
  mandate the most important items EXPLAINED IN PLAIN ENGLISH FOR A READER WITH NO CONTEXT — write it like the
  batch explanations she accepted at this sitting (the P-849-1 explanation's register), not like this file. The
  session's VERY LAST chat message: the filed tickets again, her checkbox format, by priority.
- **Machinery:** memory file `vx-849-run-state` current; nov7 holds the queue (REQUEST/READY/GO/RELEASE verbatim;
  no heavy headless while another window is live); the no-trailer hook denies trailer forms in commit text; both
  implementer agents are DONE (batch 1, batch 2 — resumable by SendMessage only if their batches reopen).

## THE POST-COMPACTION KICKOFF PROMPT (paste-ready; the mandate above travels with it)

/architect-phase vx-849 — POST-COMPACTION RESUME, the overnight leg. You are the standing orchestrator of the
VX-849 run (the sync-custody run), mid-flight at the batch-2 stage window. FIRST: read
`~/dev/variorum-vx-849/notes/plans/fixes/vx-849-typed-over-rescue.md` IN FULL — it is the one running record and
it is current: the STATUS banner, KICKOFF (her rulings verbatim), STAGE & COORDINATION, LIVE STATUS, the batch
briefs, both batch records with their adjudications, HER OVERNIGHT MANDATE (verbatim — it governs the night) and
the CUTOVER STATE, which is your task list. Verify before trusting: `git -C ~/dev/variorum-vx-849 log --oneline
-12` against LIVE STATUS. Then the standard preflight ONLY as the briefs demand it per batch (SyncSpec whole is
already honored for Sync/ work; CastleRules whole for batch 4; TEXTKIT2_NOTES whole for batch 3). The cast is her
ruling: Opus implements, Fable cold-reviews. nov7 coordinates the stage — announce yourself, confirm the
vx-849-batch2 claim's tip, and run the window's legs with your own hands when the GO comes. Everything
author-flavored runs PROVISIONAL-and-continue into the morning bundle; the hard stops (her Air drill, VX-919's
deploy, release PUBLISHING) stay held. End state by morning: the run merged (serialized through nov7), release
prep done ONLY if this run is the wave's last merger and only on nov7's GO (the mandate section's exact scope —
built, never published; Fable hands the first-run walk to Opus), the author handoff written with its plain-English
explanations per the mandate, and the filed tickets repeated as the very last chat message in her checkbox format.

