# VX-926 — Run: the test flakes (the stage's interrupters)

**STATUS: OPEN — kicked off 2026-11-08 (/architect-phase, the Pro; orchestrator variorum-91, the same session that closed VX-912).**
Ticket: VX-926 · Branch: `vx-926-test-flakes` · Worktree: `~/dev/variorum-vx-926` · PR: `VX-926: …` (merge commit, never squash).
Coordinator: nov7. **Stage posture: headless building NOW; every stage window (the soaks, the gate) waits until vx-914 MERGES — her word: "I just think it's good to try to take care of this once that's in when you're alone on the stage." A flake run's stage evidence is long windows split at the targets (the coordinator's sizing note).**

## FOR A LATER READER

*(Written at closeout. Until then: her rulings are §2; the batches are §4; the ledger is §6.)*

---

## 1. Kickoff, cast, preflight

- **The frame (her word, 2026-11-08):** "it's just addressing some of the test flakes. you have the final disposition and call on what makes it in - this is what the coordinator suggested. … I will handle the handoff later." Membership is the ORCHESTRATOR'S final disposition over the coordinator's ranked families (§3). She is away: **everything rules PROVISIONALLY and bundles for her sitting.**
- **Her cast ruling (verbatim): "opus implements, opus reviews. run ruling things provisionally."** → `opus-implementer` per batch (fresh per batch), `opus-reviewer` for the ladder. **The standing constraint:** this cast is legal only while the diff holds NO `Sync/`, custody/keychain or editor-seam line — any batch whose fix reaches one STOPS (that class mandates a Fable review; back to her). The expected surfaces are Tests/, the MCP socket harness (`Sources/VariorumMCP` possibly — MCPSpec is U1's required reading), the test-host bootstrap seam and defaults plumbing.
- **Members = the sub-issue listing of VX-926** (re-checked before the ladder): U1 VX-850 · VX-477 · VX-353 · VX-607 · VX-685 · VX-686 · VX-722 · VX-772 — U2 VX-661 · VX-690 — U3 VX-625 — U4 VX-97 · VX-666 · VX-695 — rider VX-665. Duplicates marked at kickoff: VX-723 + VX-924 → VX-625; VX-714 → VX-499; VX-746 → VX-337.
- **OUT with reasons (the umbrella text carries them):** VX-855/VX-691 (teardown crashes — rarer; VX-855 may touch `Sync/` = cast conflict; its own effort) · VX-847 (exploration, noise only) · VX-167 (Parked; dissolve-check evidence only) · family 4 as fix targets (dissolve-check first) · the phone's standing caret red (VM board).
- **Preflight (DONE at kickoff — this orchestrator session's same-day reads carry: CLAUDE.md + canon, the master plan + in-flight, QUESTIONS (#268 tail), the resiliency protocol whole, MCPSpec IN FULL (read this session), TICKETS.md regenerated at the VX-912 closeout).** SyncSpec/TEXTKIT2/CastleRules deliberately NOT required: no seam in scope — the STOP rule above guards the boundary. SurfaceContracts: no user-facing surface changes (tests + harness); if a product file's behavior changes beyond the test seam, the batch says so and the contract gets read.
- **Known false-red context the batches inherit:** the socket-timing family IS this run's subject; VX-855's teardown SIGSEGV and the phone caret red stay named-not-chased.

## 2. Her rulings

- **R-926-1 (the mint + mandate):** "you can make a new umbrella for the new work. it's just addressing some of the test flakes. you have the final disposition and call on what makes it in - this is what the coordinator suggested."
- **R-926-2 (sequencing):** "vx-914 will be merging in soon, this doesn't have to go in that. I just think it's good to try to take care of this once that's in when you're alone on the stage." → headless now; stage windows after vx-914's merge.
- **R-926-3 (cast + posture):** "opus implements, opus reviews. run ruling things provisionally."
- **R-926-4 (the handoff):** "I will handle the handoff later." → written at closeout as ever; nothing blocks on her.

## 3. The orchestrator's membership disposition (A-926-1 — the delegated call, from the coordinator's ranked families)

Families 1–3 IN (the actual window-interrupters; eleven tickets, two mechanisms between families 1 and 3) + family 5 IN (the structural prevent — the coordinator: "the best structural fix if you want one that prevents rather than patches"; alone-on-the-stage is the cheapest moment for a test-infra change) + the duplicate merges + the VX-665 verify-close rider. Family 4 NOT as fix targets — the dissolve check decides which of its reds family 5's fix removes. Family 6 and the noise row OUT with reasons. The evidence discipline binding every unit: **a load flake is fixed only when its mechanism is first made DETERMINISTIC** — injected delay/clock/starvation forcing the old red reliably, the fix turning exactly that red green — and the statistical soak (repeated whole-target windows) is ACCEPTANCE evidence recorded as counts, never the pin.

## 4. Batches (one acceptance unit each; a fresh opus-implementer per batch; briefs = the named sections below + §7 traps)

### U1 — the socket clock (VX-850 canonical + VX-477, VX-353, VX-607, VX-685, VX-686, VX-722, VX-772)
**Required reading:** `notes/MCPSpec.md` IN FULL (the harness drives the real door; any change to `Sources/VariorumMCP` lives inside its contract); the eight tickets (Linear; one-liners in §5); `notes/plans/fixes/vx-781-lockfile-pins.md` §THE MCP A/B (VX-850's origin); the VX-912 B4 record's suite notes (the load datapoint: at load 8–16 the family widened 4→11, a rawOpen read 0 bytes after its 30 s timeout — the bound is on the accept/read road).
**The work:** FIRST answer VX-850's standing question — is the slowdown test timing or REAL pre-initialize latency? (Instrument the harness's connect/initialize road under load; the answer decides the fix's home and is recorded either way.) THEN one mechanism fix for the family: the shapes on the table are (a) event-driven waits in the harness (wait for the socket's own readiness instead of wall-clock bounds), (b) bounds measured on the harness's own clock/seam (VX-353's suggestion), (c) a serialized/isolated trait for the socket-harness suites (VX-686's suggestion), (d) load-scaled bounds with the reason stated — pick on the mechanism the trace shows, record the why, and the three pre-existing suggestions each get a sentence (taken or not-taken-why). **Wire behavior may NOT change** unless the trace proves REAL latency in the door's pre-initialize road — in that case STOP and return the shape to the orchestrator before building (it may be product code with MCPSpec consequences).
**Pins:** the mechanism made deterministic — e.g. an injected slow-clock/stalled-accept arm that forces the old red reliably (red-on-old by behavioral revert), green with the fix; the family's suites green alone AND under a deliberately loaded parallel run (a headless load generator is a legal instrument). All headless.
**Closes:** all eight if one mechanism carries; any member that proves distinct gets its own disposition (fixed, or returned with its shape).

### U2 — the swift-testing encoder exit crash (VX-661 High + VX-690) — MITIGATION, TIMEBOXED
**The facts (from the tickets):** two shapes of one upstream class — mid-run SIGSEGV in the generic-metadata cache under `Dictionary.reserveCapacity` ← `ABI.EncodedEvent.encode` (crash-restart mid-window; since 2026-10-29 it fires even on green single-test runs of rebuilt binaries), and stack-overflow recursion in `ABI.Record.encode` at exit after a green run (Problem Reporter). Zero Variorum frames; Xcode 27.1 / macOS 27.0.1 toolchain class. VX-604's gate already prevents false-greens from the restarts.
**The work (timebox: one session, no extensions):** (1) characterize — can either shape be reproduced at will? (the red-rich-product trigger was the old pattern; the new green-run firings changed it); (2) the mitigation menu, each evaluated with evidence: disable/trim swift-testing's ABI event stream if a configuration exists (check the toolchain's knobs: `SWT_*` environment, `--event-stream-*` flags, xcodebuild test plans), reduce issue-payload sizes (our soak/layout tests emit MANY issues per failure — capping expectation output is OUR code), split invocations (fewer suites per run — already the in-run mitigation), serial exit ordering; (3) land the safest effective mitigation with its evidence, OR return RECORD-ONLY with the characterization + the Apple-feedback draft (the tickets name that road; the draft is a deliverable either way — it goes in the record for her to file). **Returning unbuilt with a good characterization is an acceptable, honest outcome.**
**Closes:** VX-661 + VX-690 if mitigated; else both get the characterization + the escalation draft and stay open re-owned to the Apple-feedback road (her call at the bundle).

### U3 — StarContext starvation (VX-625 canonical)
**The facts:** `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` — a held GRDB `ValueObservation`'s `next()` starves under full-parallel load (205 s past a 60 s limit; three sightings across VX-620/VX-500/VX-912; the test's own doc records an earlier starvation). The test drives her own `setStarred`; the product road is fine.
**The work:** trace WHAT starves (the observation's scheduler? the reader pool under parallel suites? the notification's delivery queue?); fix at the right home — the test's wait primed/scheduled so it cannot starve (preferred if the mechanism is test-side), or the observation harness's scheduling if the starvation is a real harness defect shared by other held-observation tests (then sweep the class: enumerate held-observation tests, verdict each). **If the trace shows a PRODUCT-side starvation possibility (a real app observation could starve the same way), STOP and return the shape — that would be a product bug beyond this run's scope.**
**Pins:** forced-starvation arm red-on-old (behavioral revert), green with the fix; the suite green alone + under load. Headless.
**Closes:** VX-625 (VX-723/VX-924 already folded as duplicates).

### U4 — hermetic test defaults (VX-97 + VX-666 + VX-695) + the family-4 dissolve check
**The facts:** the test host IS the dev app and writes its REAL `io.lduarte.Variorum.debug` defaults; `.incrementing` fixture UUIDs repeat across suites; per-note keys (`postMode.*`, `surfaceSize.*`, `currentBlock.*`) accumulate (2,731 keys by 2026-10-28; her word authorized that scrub — the pre-scrub plist survives at `~/.variorum/debug-prefs-pre-scrub-2026-10-28T2147.plist` as the planted-state reproducer) and steer later suites machine-wide (VX-695's two-direction proof: polluted→red, scrubbed→green). nov7's standing watch: the domain was at 1,131 keys this morning — re-accumulating as designed-to-fail.
**The work — the structural prevent:** ONE injectable defaults seam for the test host's per-note memory stores (`SurfaceSizeMemory` per VX-97, the `postMode`/`currentBlock` family per VX-666) so mounted suites read/write an EPHEMERAL domain, never the dev app's real one; the dev app's own behavior byte-unchanged (the seam defaults to the real domain outside tests — the inert-host pattern VX-912 B1 built is the precedent and possibly the hook: the host already knows it is hosting tests). Design note: prefer ONE seam at the defaults-access home over per-suite scrubbing (the suites that don't protect themselves are the point); per-suite cleanup remains only where a test deliberately plants state. VX-695's reproducer: plant the preserved plist (zero instances), red; the seam, green — the two-direction pin made deterministic.
**Then the DISSOLVE CHECK (evidence, not fixes):** on the fixed tree, repeated whole-target runs (the stage soak, AFTER vx-914 merges) watching the family-4 reds — VX-701, the MastheadLayout class (VX-499/VX-614), VX-337's soak half, VX-167's pair. Each: DISSOLVED (close as fixed-by with the runs counted) or STANDS (stays open, the evidence noted on the ticket). No family-4 code is touched in this run.
**Closes:** VX-97, VX-666, VX-695; family-4 tickets only as the evidence says.

### The rider — VX-665 (orchestrator-verifiable)
VX-912's inert host removed `AppSession.init` from the hosted-run path, which was VX-665's warning source (`AppBootstrap.swift:416` building the live session during a hosted run). Verify on a hosted suite log: zero `@Dependency(\.date)` "Test «unknown»" warnings ⇒ close VX-665 as fixed by VX-604's inert host; a remnant source ⇒ the one-statement `withDependencies { $0.date = .now }` seam the ticket names, folded into U4's batch.

### The ladder
One ladder over the run's whole diff after U1–U4: fresh `opus-reviewer` (HER CAST RULING), `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; findings repo-first here; same-model flow (the orchestrator arbitrates against the spec); hard cap three rounds. If the diff gained any `Sync/`/custody/editor-seam line, the cast conflict goes to her BEFORE the ladder.

### The acceptance soak (the run's gate — stage, after vx-914 merges, alone)
On the final tree: **3× the whole Mac target + 2× the full core `swift test` under deliberate parallel load + 1× the whole MCP target**, every run through `Tools/assert-tests-ran`, every failing test named with Executed counts, results recorded AS COUNTS (a soak is evidence, never proof). The gate's bar: zero reds from this run's fixed families across all runs; any red re-runs isolated and is dispositioned honestly.

## 5. Member one-liners (so briefs are self-contained; full texts on Linear)

- VX-850 (Med): CLI MCP socket suites trip time bounds more on swift-concurrency-extras 1.4.1 — test timing or real pre-initialize latency? (covers MCPPreInitializeWindowTests + MCPDiscoverProbeServerTests too)
- VX-477 (Med): the MCP suites' wall-clock flakes under full-suite load (15 s bound read 16.5–19.3 s, 7+ sightings; one sighting each MCPSizeCapTests/MCPSetupKeyServerTests/StarContextTests)
- VX-353 (Low): the never-answers-initialize pin overruns 15 s under load (16.3 s at load 9; 16.7 s at load 67)
- VX-607 (Low): MCPReaderAfterCloseTests premise fails under full-parallel load (the VX-532 class)
- VX-685 (Low): the 15 s connect bound trips under concurrent targets (24.8–34 s observed; green alone)
- VX-686 (Low): two socket-harness wall-clock tests under load 20–37 (incl. the ReaderAfterClose premise third sighting)
- VX-722 (Low): ReaderAfterClose reused-number premise under the full core suite (1 initialize unanswered)
- VX-772 (Low): StopRoads quit-says-nothing under the full MCP suite ("got no answer to its initialize")
- VX-661 (High): host SIGSEGV in swift-testing's ABI event encoder mid-run; since 10-29 fires even on green single-test runs
- VX-690 (Low): host stack-overflow at exit in ABI Record encoding after a green run (Problem Reporter)
- VX-625 (Low): StarContext held-observation starves under full-parallel (canonical; 723/924 duplicates)
- VX-97 (Low): SurfaceSizeMemory leaks persisted records into tests via real UserDefaults — injectable defaults suite
- VX-666 (Low): the test-host defaults domain accumulates per-note keys under deterministic test ids — cross-suite pollution
- VX-695 (Med): TakesEntryBandTests not hermetic — reds machine-wide as the shared Debug defaults accumulate (two-direction proof on the ticket; the pre-scrub plist is the reproducer)
- VX-665 (Low): hosted runs record @Dependency(\.date) warnings from the host's own launch (likely already fixed by VX-604's inert host — verify)

## 6. LEDGER

| Row | What | Status |
|---|---|---|
| 0 | Kickoff: mint (VX-926), 15 members seated, 4 duplicates marked, worktree, in-flight row, her rulings R-926-1..4, the disposition A-926-1 | DONE (this commit) |
| U1 | the socket clock | IN PROGRESS — "## U1 record" (end of file) |
| U2 | the encoder mitigation (timeboxed) | NOT STARTED |
| U3 | StarContext starvation | NOT STARTED |
| U4 | hermetic defaults + the dissolve check | NOT STARTED |
| R | VX-665 verify-close (orchestrator) | NOT STARTED |
| L | The ladder (opus-reviewer — her cast ruling) | NOT STARTED |
| S | The acceptance soak (stage, after vx-914 merges, alone) | NOT STARTED |
| C | Closeout | NOT STARTED |

## 7. Environment traps (every batch brief carries this by reference)

- Everything in the VX-912 record's §7 binds here verbatim (`notes/plans/fixes/vx-912-open-source-gating.md` §7): strict pgrep forms, TYPE-name -only-testing as zsh arrays, "Executed 0" is no verdict, no custom build configurations, zsh pipestatus, foreground waits with grep-poll loops, commit-per-piece + push, A1 rail, never checkout over uncommitted work.
- **Plus this run's own:** every xcodebuild-test and every Debug launch waits for the stage AFTER vx-914's merge (REQUEST through the orchestrator → nov7); headless `swift build`/`swift test` free now. `Tools/assert-tests-ran` (VX-604's gate) wraps every suite run — zero-executed and host crashes never read green. A deliberate LOAD GENERATOR for load-testing is a legal throwaway instrument — never leave one running past the test (name its pid in the record while alive). The Debug defaults domain is live product state: planting the pre-scrub plist happens at zero instances and is restored after (the plant and restore both recorded); her 2026-10-28 scrub precedent authorized cleaning TEST-minted keys, not product prefs. **nov7's window rules (2026-11-08, binding):** (1) BEFORE any plant, `defaults export io.lduarte.Variorum.debug` to `~/.variorum/` as the pre-window copy; at the end restore, then RE-EXPORT AND DIFF against the pre-window copy — `defaults import` MERGES rather than replaces (two 10-14 walks left a key behind that way); zero instances throughout; the diff's result goes in the RELEASE line. (2) U4 touches app-side per-note memory code — tell the orchestrator the moment U4 lands so nov7 can trial-merge this branch against vx-914's tip; after vx-914 merges, main merges IN here and the soak runs on the merged tree. (3) The soak's tested tree = the tree of the LAST whole-target window; nothing outside notes/ may land after it, or the merge GO waits. The dev store's MCP server stays ON with variorum-de approved; never press Resume Sync.

## U1 record

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no stage work of any kind (the brief: headless only — no `xcodebuild test`, no Debug launch, no walk; the family has no face, so its acceptance evidence is the socket road itself driven headlessly, alone and under deliberate load); nothing filed on Linear or in `notes/QUESTIONS.md` (PROVISIONALs and findings are listed here for the merge).

### LIVE STATUS

| Piece | What | Status |
|---|---|---|
| P0 | This record opened; ledger row U1 → IN PROGRESS | DONE (this commit) |
| P1 | PHASE 1 — VX-850's question answered with evidence (instrumented connect/initialize road, idle vs external CPU load vs in-process pool pressure) | IN PROGRESS — reading done (brief §4/§5/§7, MCPSpec in full, the VX-781 MCP A/B, the VX-912 B4 suite notes, the resiliency protocol, the eight tickets); the instrument is next |
| P2 | PHASE 2 — one mechanism fix, chosen on the trace | NOT STARTED |
| P3 | Pins: the mechanism made deterministic, red on old by behavioural revert, green with the fix | NOT STARTED |
| P4 | The family alone + under a deliberately loaded parallel run (counts) | NOT STARTED |
| P5 | Per-member dispositions, the three suggestions' sentences, PROVISIONALs, self-assessment | NOT STARTED |

**Load generators alive:** ONE — 36 × `/usr/bin/yes > /dev/null`, pids 35165–35200 (started 18:10 for Phase 1's C1 condition; killed by pid at its end). **Reverts in flight:** none.
