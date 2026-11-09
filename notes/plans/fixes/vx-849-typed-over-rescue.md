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

## LIVE STATUS (the orchestrator flips rows; implementers flip their batch rows in their own commits)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight whole · worktree + branch · her rulings repo-first · the in-flight row · Linear flips (run In Progress; riders seated as sub-issues) · nov7 announced | DONE (this commit) |
| 1 | Batch 1 — VX-683 + VX-402 (the rescue + the honest flush) | IN PROGRESS — the implementer's BATCH 1 RECORD below carries the per-piece lines |
| 2 | Batch 2 — VX-544 (the offline unlock retry) | NOT STARTED |
| 3 | Batch 3 — VX-664 (the outside-change ring-ending) | NOT STARTED |
| 4 | Batch 4 — VX-443 + VX-152 + VX-545 (the custody smalls) | NOT STARTED |
| 5 | Batch 5 — VX-855 (the teardown SIGSEGV, trace-first) | NOT STARTED |
| 6 | Batch 6 — VX-921 + VX-919 (the rank swap + the cap script) | NOT STARTED |
| 7 | The ladder (fresh `fable-reviewer`; rounds per CLAUDE.md) | NOT STARTED |
| 8 | Closing Mac runs over every changed source · PR · closeout ritual · FOR A LATER READER | NOT STARTED |
| 9 | Her drill: the two-Mac test's steps 8–9 on the Air (OWED) · VX-919's deploy window (HELD) | OWED |

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
| 2 | VX-683 B — the guarded autosave (the op + the coordinator + the record sites) | NOT STARTED |
| 3 | VX-683 A — the `beforeRound` hook + the flush-before-apply occasion | NOT STARTED |
| 4 | Close — builds, suites, self-assessment, STAGE REQUEST | NOT STARTED |

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
