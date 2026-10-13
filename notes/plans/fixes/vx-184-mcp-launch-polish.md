# VX-184 — Run: MCP launch polish (the RUN record)

**STATUS: OPEN (kickoff 2026-10-12 night).**

**The RUN record** (the RUN rule: one branch, one PR, members close individually). Kickoff + plan (BINDING,
read in full): `notes/plans/mcp-launch-polish-kickoff.md` — her pre-run sitting's rulings R-VX184-0…6,
R-VX185-1, R-VX187-1, R-VX188-1/2, the unit table, the member briefs. Ticket VX-184 · branch
`vx-184-mcp-launch-polish` · worktree `~/dev/variorum-vx-184` · PR `VX-184: …` (merge commit).
Cast: Fable orchestrates (session vx-184); `opus-implementer` per unit, strictly sequential;
`fable-reviewer` — ONE ladder over the whole run's diff, cap three. Pin-before-fix PER MEMBER,
red-on-old verified by revert.

**Members:** U1 VX-132 → VX-181 → VX-198 · U2 VX-185 · U3 VX-186 + VX-173(door half) + VX-188 + VX-190 +
VX-187 · U4 VX-195 · U5 VX-196 · U6 VX-199 + VX-205 · U7 VX-197. Nothing drops (R-VX184-0); the order is
the build order. VX-173's human bulk face is parked as VX-200.

**HER MID-RUN ADD (2026-10-12 night, this chat — minted VX-205, a U6 member):** the pane's setup command
renders in a standard UI code block with the copy icon in the upper right. Her words, verbatim: *"the block
that has the code command to be copied should be in one of those nice little code blocks you see in UI's
everywhere, with the super clear copy icon in the upper right. I feel like there's a very standard look for
copying commands, we should follow that."* U6 builds it with the tabs; the one declared copy act and the
O-4 setup fence are untouched in meaning (the icon is a second door to the same act, or the act's new face —
the implementer argues the registry shape and keeps every existing pin's meaning).

**Hard rules binding every unit:** zero `Sync/`, custody/keychain or editor-seam lines; zero SYNCED schema
(the one allowed schema change is R-VX188-1's local-only comment-authorship record, on the grants family's
road — `MCPGrantSchema`, its own commit, no `sync_version`, no trigger, export strips it, marker 13
untouched). Commits say `Part of VX-184` + the member id, NO attribution trailers, push after every commit;
`notes/SessionResiliencyProtocol.md` binds. Stage: every Mac test batch, walk and live round under a held
claim, sequenced through the oct12coordinator session (REQUEST → READY → GO → RELEASE; no priority
assumed). Never her real store, never her `/Applications` app, never her user-scope MCP registrations;
dev store only behind an A1 prestage copy, restored verified.

## LIVE STATUS (orchestrator — flipped as units land)

| unit | members | status |
|---|---|---|
| U1 — the socket and key road | VX-132 · VX-181 · VX-198 | NOT STARTED — next up; implementer brief being written |
| U2 — the gatherings icon | VX-185 | NOT STARTED |
| U3 — the door's ergonomics | VX-186 · VX-173 · VX-188 · VX-190 · VX-187 | NOT STARTED |
| U4 — edit parity inside a note | VX-195 | NOT STARTED |
| U5 — edit parity across the library | VX-196 | NOT STARTED |
| U6 — the MCP pane in tabs | VX-199 · VX-205 | NOT STARTED |
| U7 — the AI's docs | VX-197 | NOT STARTED (always last; runs over whatever merged — never a fall-out) |
| LADDER (fable-reviewer, whole-run diff) | — | NOT STARTED (after U7) |
| CLOSEOUT | — | NOT STARTED (merge serializes with the other efforts; the /Applications refresh may fold into the coordinator's shared window) |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (oct12coordinator protocol)

- 2026-10-12 night — kickoff registration sent + acknowledged (REQUEST → READY → GO → RELEASE; READY only
  when actually built; refreshes may fold into one shared window at the night's end — send the refresh ask
  at the merge). Zero Sync//custody declared.
- 2026-10-13 — coordinator: she is away from the Pro all night (tmux only), so walks/live rounds need no extra check with her; READY → GO in queue order.

## Cross-run coordination (VX-214, settings panes & launch UI polish — author-attended, merges after us)

Agreed with the settingspaneupdater session (2026-10-13, both run files carry it):
- VX-214 leaves `Features/MCP`, `MCPPane*`, `MCPPaneCopy` and SettingsShape's MCP rows untouched; anything
  MCP-pane-shaped from her sittings routes to VX-184.
- **U6's constraint:** edits to `SettingsShape.swift` stay scoped to the MCP rows only (VX-214 edits the other
  panes' rows — disjoint regions, clean merge); the Settings WINDOW shell is VX-214's this cycle (VX-225
  titlebar bleed, VX-224 lock-screen stub) — if the tab rebuild needs shell/window chrome rather than the pane
  body, STOP and flag to the orchestrator, who sequences with VX-214.
- If U6 mints a reusable explainer-behind-(i) component, its name + home are reported to VX-214 for reuse.
- Merge order: VX-184 expects to merge first; VX-214 rebases onto us.

## UNIT RECORDS (one per unit, owned by its implementer from its first commit)

*(written just-in-time below as each unit spawns)*

## U1 UNIT RECORD — the socket and key road: VX-132 → VX-181 → VX-198 (opus-implementer, 2026-10-12 night)

**What this unit did NOT do (said first — the PRE-STAGE state, 2026-10-13 01:10 MDT):** (1) **the Mac batch and THE LIVE ROUND have NOT run** — the Mac build-for-testing hit a full disk ("THE DISK INCIDENT" below) and the stage window waits on space + the orchestrator's GO; every row is therefore pinned and green HEADLESS, but the unit's evidence of kind (use, on the wire, a real client) is still owed — this record does not close on pins; (2) no capture of the changed faces yet (L1, the setup line, the Activity words — both voices, in the window); (3) no `notes/QUESTIONS.md` entry and no canon edit (the merging session's); (4) zero schema, zero `Sync/`, zero custody, zero editor seam.

**Read in full before code (never delegated):** the kickoff `notes/plans/mcp-launch-polish-kickoff.md` (her pre-run
sitting, the U1 row, the rules); this record's head; `notes/plans/fixes/vx-180-discover-probe.md` whole (the window's
design, VX-181 seen live, the ladder's NIT 1); `notes/plans/fixes/vx-168-mcp-client-secret.md` (head, LIVE STATUS, the
UNIT 1 RECORD whole — design calls 1–8, THE DRILL); the 13n-c plan §8 "Environment traps" (verbatim, honored);
`notes/SessionResiliencyProtocol.md` whole; CLAUDE.md + the auto-loaded canon (AppSpec §12's THE MCP DOOR line).
Code: `Sources/VariorumMCPSocket/` (MCPShim, MCPPreamble, MCPSocketRoad), `Sources/VariorumMCP/` (MCPHandshake,
MCPSession, MCPServerHost, MCPSocketTransport), `Domain/MCPSetupKeyRule`, `Operations+MCPSetupKeys`,
`Operations+MCPGrants` (Deny, adoption, the activity log), `MCPGrantSchema`, the app's `MCPPaneCopy`; the test
harness (`MCPServerTests.ServerHarness`) and the setup-key / probe / window / shim suites; the pinned MCP swift-sdk
0.12.1's `Client.swift` + `StdioTransport.swift` (`.build/checkouts`, read-only — VX-132's mechanism lives there).

**Surfaces:** `Tests/VariorumMCPTests/` (the harness) · `Sources/VariorumMCPSocket/MCPShim.swift` (+ a shared
id predicate) · `Sources/VariorumMCP/{MCPHandshake,MCPSession,MCPSocketTransport}.swift` · `Domain/MCPSetupKeyRule`
+ `Operations+MCPSetupKeys` + `Queries` (the setup-key reads) · the app's `MCPPaneCopy` (the faces). ZERO schema,
zero `Sync/`, zero custody/keychain, zero editor seam.

### LIVE STATUS — U1's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS; `notes/plans/vx184-screens/` gitignored (`git check-ignore` verified) | DONE `b6ed4edf` (gitignore) + this commit (record) |
| 1 | VX-132 — the mechanism traced (below); the pins (a silent server: connect, call); the bounded harness + client hygiene | DONE `d4610d06` (pins, all three HANG on the pre-fix harness — 45 s watchdog, sampled) + this commit (the fix) — `MCPHarnessDeadline.swift` (the GCD-timed deadline, task-local limit 30 s) · `MCPHarnessClient.swift` (`HarnessTransport` — the SDK's `StdioTransport` underneath, parks + disconnects at the drained second `receive()`, closes its own socket only after the SDK's read loop is done; `HarnessClient` — `callTool`/`listTools`/`disconnect`/`onNotification` bounded) · `ServerHarness.connect` bounded, a failed connect leaves no client, `rawOpen` read bounded, `tearDown`/`hangUp` never touch a client's number · the ten helpers' type → `HarnessConnection` · `MCPAdviceServerTests`' hand-built client → the harness (justified edit) · **the SIGPIPE flake traced and fixed** (below) in `MCPShimTests.aKeyedShim…` (justified edit). Green: the four VX-132 pins (connect fails named in 1.14 s, call in 1.06 s, the mid-call hang-up in **0.064 s**, the hygiene pin) · `MCPShimTests` **80/80 runs clean** (pre-fix: 2 SIGPIPE deaths in 40) · `VariorumMCPTests` **139/22 green, three consecutive runs, ~11 s each** |
| 2 | VX-132 red-on-old BY REVERT (announced here first) | DONE (announced `92f05ce8`; this commit records it) — **leg (a)**, the harness at its pre-fix bytes (`78cf9a68`), the pins kept: all three HANG (40 s watchdog, exit 142); the whole target minus those pins **135/20 in 15.95 s wall, 63.6 s user CPU** (fixed: ~11.1 s, ~31 s user — the spinning loops' user time gone). **Leg (b)**, the fixed tree with ONLY the hygiene undone (`receive()` hands the ended stream out again — the SDK's own behaviour): the hygiene pin RED (the loop asked for its stream **16,200** times in the poll window; fixed: 2) and the mid-call hang-up RED (the call waited out the whole 30 s deadline — failing NAMED at 32.0 s instead of hanging, the deadline doing its job — where the fixed tree answers in 0.064 s). **Restored:** `git checkout HEAD --`, `git status` clean. Logs `notes/plans/vx184-screens/u1/logs/vx132-*` (gitignored) |
| 3 | VX-181 — trace; the pin (the shim's closed-app refusal answers the INITIALIZE past a probe); the window in the shim's refusal read; NIT 1's one shared echoable-id predicate | DONE `1caecf4a` (pins) + this commit (fix) — **`Sources/VariorumMCPSocket/MCPOpeningWindow.swift`** (NEW: the window's pure letter `classify`/`answer(toRequest:)`/`isEchoableID`/the bounds, its line reads and the window loop `read(startingWith:from:answeringOn:)` — moved from `MCPHandshake`, byte-identical behaviour) · `MCPHandshake` consults it (VX-180's names `WindowFrame`/`windowFrame`/`windowAnswer`/`preInitializeLimit`/`lineLimit`/`blankLimit`/`methodNotFound*` kept as forwards — VX-180's pins ran UNCHANGED and green) + `readOpeningOutcome`/`openingOutcome` (the over-limit arm told apart) · **`MCPShim.respondToFirstRequest` reads the SAME window** (a probe answered `-32601`, a ping `{}`, a notification skipped; the sentence on the `initialize`'s id) · **NIT 1: `MCPShim.refusalResponse` reads `MCPOpeningWindow.isEchoableID`** — one predicate, both call sites (+ the agreement pin `theRefusalAndTheWindowEchoIDsByOneRule`, green both sides by nature — said in its doc). `MCPShimClosedAppTests` 6/6 green |
| 4 | VX-181 red-on-old BY REVERT | DONE (announced `9a08d7c9`; this commit records it) — the four production files at their pre-fix bytes (`1caecf4a`), `MCPOpeningWindow.swift` moved aside: `MCPShimClosedAppTests` 4 of 5 RED again (the captured pair: 4 issues — the sentence on the probe's id, no answer to the initialize; the waiting client 2; ping/notification 2; the bound 9) and `aFrameThatIsNoRequest…` green both sides by design. Restored clean. Log `logs/vx181-cap-revert.log` |
| 5 | over-cap answers (opening frame `lineLimit`; the transport's `lineCap` made exact) + the boundary pins (just under served, just over answered) | DONE `1caecf4a` (pins) + this commit (fix) — `MCPSession.run`: an over-limit OPENING answered `MCPHandshake.overLimitResponse` (`id: null`, -32000, "…a message before initialize ran past 1 MiB (1,048,576 bytes).") then closed — nothing decided/logged/claimed · `MCPSocketTransport.readLines` EXACT (a complete line measured too) and LINEAR (only each read's new bytes scanned) → `ReadEnd`; its reader answers an over-cap message through the ACTOR (serialized with the SDK's `send`; a bounded 2 s wait) — "…a message ran past 16 MiB (16,777,216 bytes), the most one message may carry. Send smaller messages and reconnect." Green: `MCPSizeCapTests` 8/8 (1 MiB initialize served 0.46 s · +1 answered · preamble +1 answered · probe at 1 MiB answered then initialize opens · **16 MiB call served 0.555 s** · +1 answered · exactness) · the VX-180/168 window, probe, key and shim suites unchanged and green; **`VariorumMCPTests` 152/24 green twice** |
| 6 | over-cap red-on-old BY REVERT | DONE (the same revert as piece 4) — RED again: the opening +1 (closed unanswered, 3 issues) · the preamble +1 · the session +1 (60 s, no answer) · the exactness pin · **the 16 MiB call at the cap (unserved in 30 s)**; green both sides by design: the 1 MiB initialize and the 1 MiB probe at the opening's cap (the opening reader was always exact and byte-at-a-time). Restored clean |
| 7 | VX-198 — the rule + the admission (newest copy re-binds; the replaced key's own sentence) + state-transition pins | DONE `35bd3d76` (pins) + this commit (fix) — `Domain/MCPSetupKeyRule`: `KeyStanding.replaced`, `Decision.rebind` (admits), `Refusal.replaced` (`connect_replaced_key`), `reboundAct` `connect_rebound` + `replacedTargetKind`; `decide`'s bound-name arm splits (own → admit · unclaimed → REBIND · replaced → refuse(.replaced) · boundTo/unknown → notThisNamesKey); `Queries.mcpSetupKeyStanding(db, hash:, name:)` reads the rebind row keyed on (name, hash) after the bound/unclaimed checks; `Operations.admitMCPConnection`'s `.rebind` effect = bind's (key leaves the unclaimed set, binds) + `connect_rebound` with the REPLACED hash as `target_id`; `MCPHandshake`: the ONE sentence loses its falsified deny clause, `replacedRefusal` (her words), `refusal(for:)`; `MCPSession.run` answers each refusal in its reason's sentence. **Justified edits (the ritual, each commented in place):** core `aBoundNameRefusesEveryOtherKey` (the `.unclaimed` arm moved out to `aBoundNameRebindsAFreshCopy`), `anApprovedUnboundNameBinds…` (its "a second tool with a newer copy is told apart" leg → rebind + the replaced refusal; the impostor is now a never-minted key), `aRefusalChangesNothing…` (the impostor's key a never-minted one, all else unchanged); socket `twoToolsUnderOneNameAreToldApart` = **the VX-168 drill's impostor leg re-pinned** (a newer copy admitted; the replaced key hears `replacedRefusal`; bare / never-issued / another name's key hear the ONE sentence; the row untouched; the standing session keeps working). New rule pins `aBoundNameRebindsAFreshCopy`, `aReplacedKeyRefusesWithItsOwnReason`. Green: **`VariorumMCPTests` 153/25** · core key/grant suites **91/11** |
| 8 | VX-198 faces (the setup sentence, the one refusal sentence, L1, the Deny confirm) + the Mac pins' justified edits | DONE (this commit; the Mac batch is the stage window's) — `MCPPaneCopy.keyLine` ends "Running it again replaces the old setup." (her words) · L1 `clientBoundary` true of the new rule ("…binds that name to it — running a newer setup moves the name to the new key — and a connection under the name with any other key, or none, is refused…") · Activity words `connect_rebound` / `connect_replaced_key` · the Deny confirm REVIEWED, unchanged (still true) · the guide's lesson-2 limit sentence (FALSIFIED: "so a second tool using the same name is turned away") made true of the rule — a minimal truth fix, U7 re-voices. Mac pins: `MCPGrantSheetTests` L1 exact string + `TutorialMCPChapterTests` lesson 2 (its rule pin now asserts rebind / replaced / unknown / bare) — justified edits; NEW `MCPSetupKeyFacesTests` (the setup line, every connection act in words — none had a pin — and the Deny confirm's truth). PENDING: the Mac batch under the stage GO |
| 9 | VX-198 red-on-old BY REVERT | DONE (announced `a86941c9`; this commit records it) — the five production files + the two justified-edit test files at `35bd3d76`: core `MCPSetupKeyRebindTests` RED again (2/2, 10 issues — identical to the pre-fix run) and socket `MCPSetupKeyRebindServerTests` RED again (the second copy refused). Restored clean (`git status` empty). Log `logs/vx198-revert.log` |
| 10 | headless finals (`VariorumMCPTests`, `VariorumCoreTests`, workbook) + the Mac target's build-for-testing | HEADLESS DONE (this commit) — on `5ca4bdcc`'s sources, `swift build --build-tests` clean, per target: **`VariorumMCPTests` 153/25** (VX-180's close 135/20 → +18 tests / +5 suites: `MCPHarnessTimeLimitTests` 3, `MCPHarnessHygieneTests` 1, `MCPShimClosedAppTests` 6, `MCPSizeCapTests` 8, `MCPSetupKeyRebindServerTests` 1, minus none) · **`VariorumCoreTests` 2,695/308** (VX-168's close 2,691/307 → +4: `MCPSetupKeyRebindTests` 2 + the two new rule arms) · **`StringsWorkbookTests` 40/6** — all green; skips = the standing gated ones only (8 in core, 1 in the workbook — read, not inferred). **The Mac build-for-testing is BLOCKED — the disk filled (the incident below)**; it needs no stage and runs first when space allows |
| 11 | READY FOR STAGE (turn ends; the orchestrator's GO) | BLOCKED ON DISK (this commit) — everything headless is done and green; the stage window is fully planned below; the one precondition left is the Mac build-for-testing, which needs ~3 GB the disk does not safely have (the incident below). Turn ends with the report |
| 12 | the stage window: the Mac batch + THE LIVE ROUND legs (a)–(d), dev store only | NOT-STARTED |
| 13 | close: self-assessment, PROVISIONALs, OWED | NOT-STARTED |

**No revert is in flight** (pieces 2, 4, 6 and 9's reverts ran and were RESTORED — `git checkout HEAD --`, the moved files back, `git status` clean each time).

### VX-132 — the trace (written before code)

**The symptom on record** (13n-b U3 ladder round 1, `notes/plans/13nb-u3-ladder-round1.md` ~l.307): one
`VariorumMCPTests` run never finished, the test helper at 100% CPU for 11+ minutes; `sample` showed "the SDK's
`Client.connect` message loop busy-spinning over `StdioTransport.readLoop`'s poll-sleep while
`MCPSocketTransport.readLines` sat in `read()`"; 13n-c met it three more times (killed, rerun green).

**The mechanism, read in the pinned SDK (swift-sdk 0.12.1, read-only) and then MEASURED:**
1. `Client.connect(transport:)` starts its message loop as `repeat { … let stream = await connection.receive();
   for try await data in stream { … } … } while true`. When the transport's stream FINISHES (the stdio read loop
   sees EOF — the server closed the socket), the `for try await` ends normally and the `repeat` comes straight
   back: `receive()` hands out the same finished stream, whose iterator returns nil at once — **a loop with no
   suspension that ever waits, forever**. Nothing cancels it but `Client.disconnect()`.
2. The same loop never fails the PENDING requests at EOF: `sendAndAwait` parks a continuation that only a
   response, `disconnect()` or a cancellation notification resumes — and `requestTask.value` ignores the caller's
   cancellation. **No request in the SDK has a time limit.** A call whose answer never comes waits forever.
3. The harness feeds (1) on every test: `ServerHarness.tearDown()` stops the host while the test's SDK clients are
   still connected (most tests never hang up; a refused `connect` never can — it threw), so every such client's
   loop spins for the rest of the test process.
   **Measured (a throwaway probe, never committed; each case its own `swift test` process):** three harness
   clients whose server then stopped, never disconnected → **6.37 CPU-seconds over 2 s of idle wall time** (one
   core each, for good); the same three disconnected first → **0.0002 CPU-s**. A whole `VariorumMCPTests` run
   leaves dozens of these spinning on the cooperative pool, so a later test's awaited answer is processed only
   when the pool can schedule it — and under (2) any answer that is lost or never sent is waited on forever.
   That is the sampled hang: a spinning loop beside a reader parked in `read()`.

**The fix shape (the harness only — the SDK is pinned exact and never patched, 13n-c §8):**
- **Hygiene — no client outlives its connection:** the harness hands the SDK a thin `HarnessTransport` (the SDK's
  own `StdioTransport` underneath, every call forwarded). When the client's message loop asks for the stream a
  SECOND time — which it does only once the stream has ended and every line in it has been handled — the
  transport parks the loop on a stream that never yields (no spin) and disconnects the client, which fails every
  pending request ("Client disconnected") instead of leaving it waiting. A server that closes now fails the call
  at once; the loop never spins.
- **Time limits (the ticket's ask):** `connect` and every `callTool` / `listTools` run under a deadline (default
  30 s per act, task-local so a pin can shorten it) whose timer is a GCD timer, so it fires whatever the awaited
  call does; on expiry the connection's socket is shut down (the transport reads EOF → the hygiene above ends the
  client) and the act throws a `HarnessFailure` naming itself — a hang becomes a bounded, named failure. The
  harness's raw `rawOpen` read gets a receive timeout of the same bound.
- **The pins:** a silent peer that never answers `initialize` → `connect` fails within its bound; a peer that
  answers `initialize` and then nothing → `callTool` fails within its bound (both HANG on the old harness — red
  watched under an outer watchdog); a connection the server closes → the client's message loop asks for its
  stream at most twice (red by reverting the hygiene alone: the count climbs without end).

### VX-132 — the SIGPIPE flake (found on the way, traced, fixed)

The FIRST whole-target run on the fixed harness died of **signal 13** (`swiftpm-testing-helper … exited with
unexpected signal code 13`) — the flake the brief names. **Reproduced in isolation: `MCPShimTests` alone died of
SIGPIPE in 2 runs of 40**, both with `aKeyedShimSpeaksThePreambleFirstAndABareOneNothing` in flight. **The trace:**
`MCPShim.pump` never joins its upstream thread (by design — in the shipped shim the app hanging up must end the run
even while the client keeps stdin open), and that thread's LAST act is `shutdown(socket, SHUT_WR)` once the client's
input ends. The test closed the input and then ended the downstream itself, so the shim thread could `close(pair[0])`
BEFORE the straggling upstream ran its `shutdown`; the loop's next iteration called `socketpair`, got the freed
number back, the straggler shut THAT socket for writing, and the bare iteration's upstream write met a shut socket
with no `SO_NOSIGPIPE` — the whole test process died. (In the shipped shim the same straggler can only meet a closed
number between `close` and `exit`, with nothing opened in between — harmless; recorded, not changed.) **A kernel
fact measured on the way** (a Python socketpair experiment, scratchpad): once the peer has half-closed, macOS
answers `shutdown(SHUT_RDWR)` on an AF_UNIX pair with `ENOTCONN` and wakes NO blocked reader — only `close` does — so
the old test's `shutdown(pair[1])` also never ended its shim (it just never waited). **The fix (the test only):**
read `pair[1]` to EOF after closing the input (the upstream's `shutdown` IS that EOF — it is done), then `close`
(never `shutdown`) `pair[1]`, JOIN the shim thread, and only then close anything else; both pair ends carry
`SO_NOSIGPIPE`; every read is bounded. Assertions unchanged. **Evidence:** 80/80 runs clean after (2/40 SIGPIPE
before) — a timing race, so the red-on-old is statistical, said plainly.

### VX-181 — the trace (written before code)

**Inputs → wrong output.** Variorum closed (or its server off): the shim's `MCPSocketRoad.connect` fails `ENOENT` /
`ECONNREFUSED` → `.notRunning` → `MCPShim.respondToFirstRequest(input:output:message:)` reads ONE line from stdin
(`readFirstLine`, ≤ 1 MiB) and answers it with the refusal ("Variorum must be open: …") on THAT line's id, then the
shim exits. Claude Code 2.1.296 pipelines `server/discover` (string id `"server-discover-probe-1"`) AHEAD of its
`initialize` (id 0) — VX-180's capture — so the one answer lands on the PROBE's id; the `initialize` is never read or
answered, the shim exits, and Claude Code reports only `CONNECTION_CLOSED` (seen live in VX-180's round, leg (2): her
user-scope `variorum` entry, app absent). The honest sentence never reaches the person.

**The fix shape (the kickoff's):** VX-180's bounded pre-initialize window, in the shim's refusal read. The window's
PURE letter (what a frame is to it, its fixed answers, the bound, the echoable-id rule) moves from `MCPHandshake`
(VariorumMCP — which the shim does not link) to `VariorumMCPSocket` as ONE shared rule (`MCPOpeningWindow`), with the
line reads and the window loop beside it; `MCPHandshake` consults it (its VX-180 names kept as thin forwards, so
VX-180's pins run unchanged — the "switched under that ticket's pins" the NIT asked for), and the shim's refusal read
runs the SAME window: a probe is answered `-32601` on its own id, a ping its empty result, a notification skipped,
and the frame that ends the window — the `initialize` — hears the shim's honest sentence on ITS id. Past the bound,
or on a frame that is no request, the sentence answers that frame (the pre-VX-181 road). **NIT 1 discharged:**
`MCPShim.refusalResponse` and the window both read `MCPOpeningWindow.isEchoableID` — one predicate, one module.
**The pin (compiles on the pre-fix tree, `MCPShim.run` only):** the shim run from a fake app bundle whose container
has no socket, stdin carrying VX-180's captured pair pipelined → line 1 is `-32601` on the probe's string id, line 2
is "Variorum must be open…" on id 0. Pre-fix: line 1 is the sentence on the probe's id and there is no line 2.

### Over-cap answers — the argued shape (written before code)

**Today:** an OPENING line (the preamble, a window frame, the `initialize`) past `MCPHandshake.lineLimit` (1 MiB) ends
the read (`readOpening` → nil) and the session returns: closed with NO answer. A message past
`MCPSocketTransport.lineCap` (16 MiB) after admission ends the transport's reader and the session: closed with NO
answer. **And the 16 MiB cap is not exact:** `readLines` checks only the unterminated REMAINDER after each read, so a
line whose newline arrives in the same read as its overflowing bytes is yielded whole — anything up to `lineCap` +
one read (64 KiB) can be served, and which happens depends on how the kernel chunks the stream. A boundary pin needs
the cap to be exact: a line longer than `lineCap` is over, whatever the chunking (the doc comment already says so).
**The shape, per arm:**
- **Opening (pre-admission):** the read thread is the only writer on the descriptor (no SDK yet), so the answer is
  clean: one JSON-RPC error on `id: null` (the overrun line has no parseable id — JSON-RPC 2.0's rule when the id
  cannot be detected), code `-32000` (the door's own refusal code — `MCPShim.refusalCode`: every refusal Variorum
  speaks on the wire is -32000 + one sentence), then the close. Nothing decided, nothing logged, no key claimed —
  the admission never runs (the frame was never read whole).
- **After admission:** the transport's reader thread is NOT the only writer (the SDK's responses go through the
  transport actor's `send`), so the answer goes through the SAME actor — serialized with the SDK's writes, never
  interleaved mid-frame — and only then does the stream finish (the SDK ends, the host closes). Same shape: `id:
  null`, -32000, a sentence naming the cap. The wait for that write is bounded (2 s) so a peer that reads nothing
  cannot hold the reader.
- **The shim with the app closed:** an over-limit line inside its window answers the closed-app sentence on
  `id: null` (that sentence is the one the person needs; the size is the shim's own business).
**PROVISIONAL (P-U1 over-cap):** the code (-32000 · -32600 "Invalid Request" · -32700 "Parse error"), the id (`null`
as built · drain the line to its end and parse the id from a bounded tail — a heuristic over unparsed JSON, rejected
here) and the words — options in the PROVISIONALs list at the close.

### VX-198 — R-VX184-5, the newest copied setup wins (the trace and the argued shape, written before code)

**Today (VX-168 as built):** `MCPSetupKeyRule.decide` — a BOUND name presenting ANY other key refuses
`.notThisNamesKey`, "a fresh key from a newer copy included" (UNIT 1 RECORD call 3; pinned
`aBoundNameRefusesEveryOtherKey`, the drill's impostor leg). So when she re-runs a client's setup (a new Mac
registration, a reinstalled tool, a beta tester's second try) the fresh key is refused, and the only road is
P-VX168-U1-1's rotation — Deny… (revoking every grant) → Approve… → run the setup again. Her ruling: *"the whole path
where you have to deny it and then reset it is a bit annoying and cumbersome even for my beta testers."*

**The rule, per arm (only ONE arm changes meaning):**
- a bound name + its own key → admit (unchanged);
- **a bound name + a FRESH key — minted here by a Copy setup command and never yet presented (`.unclaimed`) → REBIND**
  (new): the key leaves the unclaimed set and becomes the name's key; approval and grants untouched; logged
  `connect_rebound` ("connected with a newer setup, which replaced its earlier one");
- **a bound name + the key a newer setup REPLACED → refuse `.replaced`** (new arm, its own sentence);
- a bound name + a key bound to ANOTHER name, or one never minted here → refuse `.notThisNamesKey` (unchanged — the
  impostor arm now means "a key this library did not hand this name's newest setup");
- no key → `.bare`; no name → `.unnamed`; an unbound name: unclaimed → bind/request, another name's → refuse,
  unknown → refuse (all unchanged); Deny still releases (unchanged); an adoption still releases every binding.
"Newest" is the newest PRESENTED copy: an unclaimed key re-binds whenever it first arrives (the brief's letter: "only
a FRESH, unclaimed, this-store-minted key presented under a bound name re-binds"). Two copies pending at once is the
one edge where an OLDER copy first run later takes the name back — K2's unclaimed set carries no name or order, and
the cap (20, oldest forgotten) bounds it; recorded, not built around.

**The replaced key's own sentence needs a MEMORY, and this unit has zero schema.** A rebind discards the old hash
(the binding column holds one key), so without memory a replaced key is indistinguishable from any never-issued key —
and giving the replaced sentence to every unknown key under a bound name would tell a prober which names are bound
(an oracle the one-sentence discipline exists to prevent). **Built: the memory is the activity log's own rebind row**
— `connect_rebound` with `target_kind = 'setup_key'` and `target_id` = the REPLACED key's hash (a hash of a dead key;
`target_title` nil, so no face shows it). The standing query asks "did a rebind under THIS name replace this hash?"
— keyed on (name, hash), so the sentence is heard only by a connection presenting a key that really was this name's
before a newer setup replaced it: it tells the key's holder only its own key's history, so it opens no oracle. The
log is coarse and capped (500 rows): past the cap the memory lapses and the old key hears the ONE sentence, whose
remedy is the same — graceful, said plainly. PROVISIONAL **P-VX198-1** (the memory's home): (a) as built, the
activity log (zero schema); (b) a local-only replaced-keys record on the grants family's road — a schema change, its
own commit, out of this unit (the kickoff allows only U3's table); (c) no memory: fold "or a newer setup replaced
it" into the ONE sentence for every key refusal (zero oracle, zero memory, but not "its own sentence").

**The words (PROVISIONAL P-VX198-2, her copy pass):**
- the ONE refusal sentence LOSES its last clause — "If this client's name is already set up with another key, the
  author must deny it there and approve it again first." is FALSE once a fresh setup re-binds (it was P-VX168-U1-4's
  clause that "depends on P-U1-1");
- the replaced key's sentence, her words kept: "Variorum refused this connection: a newer setup replaced this one.
  Run this client's setup again — copy a fresh one from Settings ▸ MCP ▸ Connect a client — and reconnect.";
- the setup sentence (`keyLine`, under every client's shown setup) gains her words: "Running it again replaces the
  old setup.";
- L1 (`clientBoundary`) made true of the new rule, no truer: the newest setup run for a name replaces the one before;
- Activity: `connect_rebound` / `connect_replaced_key` worded;
- the Deny confirm — REVIEWED, unchanged: "It can't connect again until you approve it and run its setup again." stays
  true (Deny still releases; R-VX184-5 leaves Deny unchanged); it no longer names the everyday rotation road and never did;
- the field guide's lesson-2 limit sentence ("…so a second tool using the same name is turned away") is FALSIFIED by
  the rebind and pinned against the rule (`TutorialMCPChapterTests`) — minimal truth fix here, U7's quality pass
  re-voices it.

### THE DISK INCIDENT (2026-10-13 ~00:55–01:04 MDT, the Pro) — said plainly

My Mac `xcodebuild … -derivedDataPath App/Variorum/DerivedData/vx184-u1 build-for-testing` (no stage — a build) ran the
data volume to **134 MiB free of 460 GiB** and failed `ENOSPC` (the tool could not even write its own output file). I
deleted ONLY that partial build (mine, this session, rebuildable) at once → 1.8 GiB free; nothing of mine is running
(`pgrep` for xcodebuild/swift-build/clang/test helpers empty). Minutes later the volume read **5.0 GiB free** — freed by
something not mine. Every commit of this unit was pushed before the build started; `git fsck` clean, the tree clean.
**Not rebuilt:** a complete Debug build-for-testing here is ~2.6 GB (the other worktrees' folders measure 1.8–2.9 GB), and
VX-179 is building on the same volume tonight — building now would take the disk back near empty, where her real store's
writes (if her app is open) and the other session's builds fail. **Reclaimable, NONE of it mine (read-only `du`, nothing
touched):** `~/Library/Developer/Xcode/DerivedData` 35 GB · `~/dev/variorum-vx-165/App/Variorum/DerivedData/*` ~28 GB (13n-c,
CLOSED 2026-10-12 — eleven folders, 2.4–2.9 GB each) · `~/dev/variorum-vx-168/App/Variorum/DerivedData/*` ~6.8 GB (VX-168,
CLOSED) · each worktree's `.build` 1.1–3.6 GB. Freeing any of it is the orchestrator's / the author's call (CLAUDE.md:
never delete what she or another session created). **Ask:** ≥ 10 GB free before the Mac build (headroom for VX-179 too).
**RESOLVED (2026-10-13, after 01:10 MDT):** the orchestrator swept the CLOSED efforts' DerivedData (`variorum-vx-165` +
`variorum-vx-168`, ~36 GB, the closeout rule's overdue tidy, no process using them); the data volume read **34 GiB free**
(re-read here before the build). Nothing else touched.

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the claim it names — expected `vx184-u1`)

**Before the window (no stage):** the disk at ≥ 10 GB free (above); `cd App/Variorum && xcodebuild -scheme Variorum
-destination 'platform=macOS' -derivedDataPath DerivedData/vx184-u1 build-for-testing` (~5 min) → `** TEST BUILD
SUCCEEDED **` — the Debug app `io.lduarte.Variorum.debug` with its `variorum-mcp` shim, and the test bundle.
**In the window (~45–55 min):**
0. **Guards first, every time:** `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app` ABSENT — if present,
   STOP and report, never quit or kill it); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; `Tools/stage claim vx184-u1`.
1. **The Mac batch (~10–15 min):** `xcodebuild test-without-building … -derivedDataPath DerivedData/vx184-u1` with
   `-only-testing:VariorumTests/<Suite>` for every suite naming a changed type (grep over `MCPPaneCopy`, `MCPServerHost`,
   `MCPActivityFace`, `MCPSetupKeyRule`, `MCPSetupClient`, `TutorialSeeder`/`mcpChapter`): CalmAsksTests ·
   EncryptionBookDoorTests · EncryptionExplainedDrillTests · LaunchFurnitureTests · MCPAskAndReceiptTests ·
   MCPAsksWaitTests · MCPDeliberateFacesTests · MCPEditFacesTests · MCPGrantSheetTests · MCPGrantSheetU2CaptureTests (gated)
   · MCPPaneTests · MCPSetupKeyFacesTests · MCPSetupMenuTests · MCPShareFacesTests · MCPWingFacesTests · NewModesTests ·
   SampleLibraryWelcomeTests · ShellConfirmTests · SnippetOpenTargetTests · SnippetsLandingTests · SnippetTagDoorTests ·
   TakeCardDoorTests · TourEndCardAsideGateTests · TourEndCardTests · TourEngineTests · TourEntryTests · TourPoolTuckTests ·
   TourScriptTests · TourSpotlightTests · TutorialBookShapeTests · TutorialBooksLessonTests · TutorialBooksRitualTests ·
   TutorialBuildFlavorTests · TutorialCurrencyTests · TutorialDeletionActsTests · TutorialDoorTests ·
   TutorialFannedMatrixTests · TutorialFurnitureFoldTests · TutorialLibraryActsTests · TutorialLookingActsTests ·
   TutorialMCPChapterCaptureTests (gated) · TutorialMCPChapterTests · TutorialPrivacyChapterTests ·
   TutorialStructureActsTests · TutorialTakesActsTests · TutorialWherePlacesActsTests · TutorialWritingActsTests (48 suites;
   standing reds named if met: VX-115's `BookCollectingDoorsTests` is not in the set).
2. **A1 prestage copy** of the dev store — `Tools/ScaleFixture/stage.sh`'s copy loop WITHOUT its fixture launch (every
   store file + the key files → `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified).
3. **Launch** the Debug app (`open -n`), Settings ▸ MCP: the server running; Connect a client ▸ Claude Code ▸ **Copy setup
   command** (cliclick, `guard.sh <devpid> x y` before each click) → key K1 on the clipboard (recorded as its first 9
   characters). Her user-scope servers read BEFORE (`claude mcp list`/config, expected `['linear-server','variorum']`).
4. **Leg (a) — a real Claude Code turn:** in a scratch folder, the copied line with `-s user` → `-s local` (registration
   `variorum-dev`, the REAL fixed Debug shim) + a second `-s local` registration `variorum-tee` running the same shim
   behind a `tee` wrapper; `claude mcp list` → both Connected (the claude-code name binds or re-binds — Activity says
   which); then ONE `claude -p --strict-mcp-config --mcp-config <scratch json> --allowedTools mcp__variorum-dev__list_books`
   turn → served.
5. **Leg (b) — VX-198, the re-bind:** a SECOND Copy setup command press → K2; the line re-run in the scratch folder (it
   replaces the local registration); `claude mcp list` → Connected; her Activity: "claude-code connected with a newer setup,
   which replaced its earlier one"; the client row still approved with its grants (capture). Then, through the REAL shim
   with a scripted stdio client (python, scratchpad): `VARIORUM_MCP_KEY=K1` under `claude-code` → **the replaced sentence**
   on the initialize's id (captured on the wire); a bare shim, a never-issued key, and another name's key (an "Any MCP
   client" copy bound first to a scratch name `vx184-other`) → **the ONE sentence** each; Activity lines captured.
6. **Leg (c) — VX-181:** quit the dev instance BY BUNDLE ID (`tell application id "io.lduarte.Variorum.debug" to quit`;
   `pgrep` empty); `claude mcp list` against the scratch registrations; **acceptance = the tee capture**: IN the probe +
   the initialize, OUT `-32601` on the probe's string id, then "Variorum must be open…" on id 0. What Claude Code displays
   is RECORDED AS FOUND, never the pass/fail.
7. **Leg (d) — the realistic large write:** relaunch the dev app; the scripted client through the REAL shim (K2, as
   `claude-code`) calls `create_note` with a 300-block, ~200 KB document (`blocks` form) on Home — the write-new reach
   given by answering the just-in-time ask in the pane's Waiting section (cliclick, guarded) if claude-code's grants do not
   already reach Home — then `read_note` (with_ids) back: every block's text byte-equal; timings recorded.
8. **Cleanup:** both `-s local` registrations removed; her user-scope servers read AFTER (unchanged); the scripted client's
   scratch files and keys deleted; the clipboard emptied; the dev instance quit by identity; the dev store
   `Tools/ScaleFixture/restore.sh <dir>` → "Restored (verified)"; the stage RELEASED; evidence in
   `notes/plans/vx184-screens/u1/` (gitignored; every key redacted to its first 9 characters — a grep for `vmk1_` whole keys
   finds none).

### SELF-ASSESSMENT (pre-stage — the implementer's; the live round's evidence still owed)

**Against the U1 row:** VX-132 — every harness connect/call bounded and named (pins red-on-old: they HANG on the old
harness) AND the hang's mechanism removed at the harness (no spinning SDK loop, no unfailed pending request — measured:
the old harness's whole run spent 63.6 s user CPU vs ~31 s now; 16,200 receive() calls vs 2 in the hygiene pin by revert);
the SIGPIPE flake traced (pump's straggling `shutdown` on a reused number) and its test fixed (80/80 vs 2/40). VX-181 — the
shim's closed-app sentence answers the initialize past a probe (red-on-old by revert); NIT 1 discharged (one predicate, one
module; VX-180's pins unchanged and green). Over-cap — both caps answer on `id: null` (red-on-old), the 16 MiB cap made
exact, and its reader made linear (the pre-fix reader never served a message at the cap in 30 s — found by the boundary
pin). VX-198 — the newest copied setup re-binds (approval + grants kept), the replaced key's own sentence (no oracle), the
impostor/bare/foreign/unissued arms unchanged; the faces and the falsified guide sentence made true.
**Against the spec:** zero schema (the replaced-key memory rides the existing local-only activity log — P-VX198-1), zero
`Sync/`, zero custody/keychain, zero editor seam (`git diff --stat` over the unit names only `Sources/VariorumMCP*`,
`Sources/VariorumCore/{Domain/MCPSetupKeyRule,Operations/Operations+MCPSetupKeys,Queries/MCPGrantQueries}`, the app's
`MCPPaneCopy` + `TutorialSeeder`, tests, notes). A-4/K2's boundary: identity is still decided once per connection; the
rebind admits only a key this library minted at her copy press (K2's own trust root — a process able to read her
clipboard could already read the client's settings, K2's recorded non-defeat).
**Risks I see:** (1) the replaced-key memory lapses past the activity log's 500-row cap (the old key then hears the ONE
sentence — same remedy) — P-VX198-1; (2) "newest" is newest PRESENTED: an older copy first run later takes the name back
(recorded, the brief's letter); (3) the over-cap answers ride `id: null`, which some clients' schemas may reject (my
recollection, UNVERIFIED: MCP's TypeScript SDK types an error's `id` as string|number — a strict client may drop the line and
still see only the close) — PROVISIONAL;
the live round records what Claude Code does with what it can be sent; (4) the window now governs the shim's refusal read:
a client that never initializes gets at most 8 answers then the sentence — the same bound as the app's.

### PROVISIONALs (each wants a `notes/QUESTIONS.md` entry at the merge — the merging session's ledger)

- **P-VX198-1 — where the replaced key is remembered:** (a) **as built** — the rebind's own activity row (zero schema;
  lapses past the log's 500-row cap to the one sentence); (b) a local-only replaced-keys record on the grants family's road
  (a schema change — its own commit, outside this unit); (c) no memory — "…or a newer setup replaced it" folded into the ONE
  sentence for every key refusal (no oracle, no memory, not her "its own sentence").
- **P-VX198-2 — the words:** the replaced key's sentence ("Variorum refused this connection: a newer setup replaced this one.
  Run this client's setup again — copy a fresh one from Settings ▸ MCP ▸ Connect a client — and reconnect."), the ONE
  sentence without its deny clause, L1, `keyLine`'s "Running it again replaces the old setup.", the Activity words
  ("connected with a newer setup, which replaced its earlier one" / "connecting with a setup a newer one replaced"), the
  guide's lesson-2 sentence (U7 re-voices) — her copy pass.
- **P-U1-OVERCAP — the over-cap answers' shape:** (a) **as built** — `-32000` (the door's refusal code) on `id: null`,
  a sentence naming the cap, then the close; (b) `-32600` "Invalid Request" or `-32700` "Parse error" on `id: null`;
  (c) drain the line and parse its id from a bounded tail (rejected: a heuristic over unparsed JSON could answer the wrong
  request). And the words ("…a message before initialize ran past 1 MiB (1,048,576 bytes)." / "…a message ran past 16 MiB
  (16,777,216 bytes), the most one message may carry. Send smaller messages and reconnect.").
- **Argued, not provisional:** VX-132's harness design (a transport wrapper + GCD-timed deadlines — the SDK pinned exact,
  never patched); the SIGPIPE fix in the test only (the shipped shim's straggler is harmless — `close` then `exit`);
  "newest" = newest presented (the brief's letter — the orchestrator CONFIRMED 2026-10-13 that this follows R-VX184-5 as
  briefed: an implementation note, no change); the window moved whole into `VariorumMCPSocket` (VX-181's fix needs
  more than the predicate there); the session cap's exactness + linear reader (required by her boundary pin).

### OWED (for the orchestrator)

1. ~~**Disk space**~~ — RESOLVED by the orchestrator's sweep (34 GiB free); the Mac build-for-testing follows; then my GO window.
2. **Canon at the merge** (the kickoff's list carries these): AppSpec §12 THE MCP DOOR — the shim's VX-181 window clause
   (the closed-app sentence answers the `initialize` past a probe); A-4's boundary amended for newest-copy-wins (R-VX184-5:
   a fresh copy re-binds a bound name, approval and grants kept; the replaced key refuses with its own sentence; Deny
   unchanged); the over-cap answers (both caps answer on `id: null` before closing) if she wants a clause. The QUESTIONS
   entries above. MOBILE PARITY: nothing mobile-visible (the door is Mac-only).
3. **Her handoff:** with VX-198 her clients re-run NOTHING (no binding changes at install — R-VX168-1's bindings stand);
   from now on re-running a setup is the whole road (no Deny). VX-178 parked as superseded (the kickoff). The beta tester's
   bridge note stands (VX-180's handoff).
4. **Noticed, not this unit's:** `MCPShim.pump` never joins its upstream thread (by design for the shipped shim; only the
   tests met the reuse race — fixed there); `MCPHandshake`'s opening read still has no overall deadline (VX-180's risk 3 —
   a silent peer holds a session slot until it closes; the session cap bounds it).
