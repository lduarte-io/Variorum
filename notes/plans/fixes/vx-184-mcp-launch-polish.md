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

**What this unit did NOT do (said first):** PENDING — finalized at the unit's close.

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
| 1 | VX-132 — the mechanism traced (below); the pins (a silent server: connect, call); the bounded harness + client hygiene | NOT-STARTED |
| 2 | VX-132 red-on-old BY REVERT (announced here first) | NOT-STARTED |
| 3 | VX-181 — trace; the pin (the shim's closed-app refusal answers the INITIALIZE past a probe); the window in the shim's refusal read; NIT 1's one shared echoable-id predicate | NOT-STARTED |
| 4 | VX-181 red-on-old BY REVERT | NOT-STARTED |
| 5 | over-cap answers (opening frame `lineLimit`; the transport's `lineCap` made exact) + the boundary pins (just under served, just over answered) | NOT-STARTED |
| 6 | over-cap red-on-old BY REVERT | NOT-STARTED |
| 7 | VX-198 — the rule + the admission (newest copy re-binds; the replaced key's own sentence) + state-transition pins | NOT-STARTED |
| 8 | VX-198 faces (the setup sentence, the one refusal sentence, L1, the Deny confirm) + the Mac pins' justified edits | NOT-STARTED |
| 9 | VX-198 red-on-old BY REVERT | NOT-STARTED |
| 10 | headless finals (`VariorumMCPTests`, `VariorumCoreTests`, workbook) + the Mac target's build-for-testing | NOT-STARTED |
| 11 | READY FOR STAGE (turn ends; the orchestrator's GO) | NOT-STARTED |
| 12 | the stage window: the Mac batch + THE LIVE ROUND legs (a)–(d), dev store only | NOT-STARTED |
| 13 | close: self-assessment, PROVISIONALs, OWED | NOT-STARTED |

**No revert is in flight.**

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
