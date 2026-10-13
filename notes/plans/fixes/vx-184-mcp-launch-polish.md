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
| 1 | VX-132 — the mechanism traced (below); the pins (a silent server: connect, call); the bounded harness + client hygiene | DONE `d4610d06` (pins, all three HANG on the pre-fix harness — 45 s watchdog, sampled) + this commit (the fix) — `MCPHarnessDeadline.swift` (the GCD-timed deadline, task-local limit 30 s) · `MCPHarnessClient.swift` (`HarnessTransport` — the SDK's `StdioTransport` underneath, parks + disconnects at the drained second `receive()`, closes its own socket only after the SDK's read loop is done; `HarnessClient` — `callTool`/`listTools`/`disconnect`/`onNotification` bounded) · `ServerHarness.connect` bounded, a failed connect leaves no client, `rawOpen` read bounded, `tearDown`/`hangUp` never touch a client's number · the ten helpers' type → `HarnessConnection` · `MCPAdviceServerTests`' hand-built client → the harness (justified edit) · **the SIGPIPE flake traced and fixed** (below) in `MCPShimTests.aKeyedShim…` (justified edit). Green: the four VX-132 pins (connect fails named in 1.14 s, call in 1.06 s, the mid-call hang-up in **0.064 s**, the hygiene pin) · `MCPShimTests` **80/80 runs clean** (pre-fix: 2 SIGPIPE deaths in 40) · `VariorumMCPTests` **139/22 green, three consecutive runs, ~11 s each** |
| 2 | VX-132 red-on-old BY REVERT (announced here first) | DONE (announced `92f05ce8`; this commit records it) — **leg (a)**, the harness at its pre-fix bytes (`78cf9a68`), the pins kept: all three HANG (40 s watchdog, exit 142); the whole target minus those pins **135/20 in 15.95 s wall, 63.6 s user CPU** (fixed: ~11.1 s, ~31 s user — the spinning loops' user time gone). **Leg (b)**, the fixed tree with ONLY the hygiene undone (`receive()` hands the ended stream out again — the SDK's own behaviour): the hygiene pin RED (the loop asked for its stream **16,200** times in the poll window; fixed: 2) and the mid-call hang-up RED (the call waited out the whole 30 s deadline — failing NAMED at 32.0 s instead of hanging, the deadline doing its job — where the fixed tree answers in 0.064 s). **Restored:** `git checkout HEAD --`, `git status` clean. Logs `notes/plans/vx184-screens/u1/logs/vx132-*` (gitignored) |
| 3 | VX-181 — trace; the pin (the shim's closed-app refusal answers the INITIALIZE past a probe); the window in the shim's refusal read; NIT 1's one shared echoable-id predicate | DONE `1caecf4a` (pins) + this commit (fix) — **`Sources/VariorumMCPSocket/MCPOpeningWindow.swift`** (NEW: the window's pure letter `classify`/`answer(toRequest:)`/`isEchoableID`/the bounds, its line reads and the window loop `read(startingWith:from:answeringOn:)` — moved from `MCPHandshake`, byte-identical behaviour) · `MCPHandshake` consults it (VX-180's names `WindowFrame`/`windowFrame`/`windowAnswer`/`preInitializeLimit`/`lineLimit`/`blankLimit`/`methodNotFound*` kept as forwards — VX-180's pins ran UNCHANGED and green) + `readOpeningOutcome`/`openingOutcome` (the over-limit arm told apart) · **`MCPShim.respondToFirstRequest` reads the SAME window** (a probe answered `-32601`, a ping `{}`, a notification skipped; the sentence on the `initialize`'s id) · **NIT 1: `MCPShim.refusalResponse` reads `MCPOpeningWindow.isEchoableID`** — one predicate, both call sites (+ the agreement pin `theRefusalAndTheWindowEchoIDsByOneRule`, green both sides by nature — said in its doc). `MCPShimClosedAppTests` 6/6 green |
| 4 | VX-181 red-on-old BY REVERT | DONE (announced `9a08d7c9`; this commit records it) — the four production files at their pre-fix bytes (`1caecf4a`), `MCPOpeningWindow.swift` moved aside: `MCPShimClosedAppTests` 4 of 5 RED again (the captured pair: 4 issues — the sentence on the probe's id, no answer to the initialize; the waiting client 2; ping/notification 2; the bound 9) and `aFrameThatIsNoRequest…` green both sides by design. Restored clean. Log `logs/vx181-cap-revert.log` |
| 5 | over-cap answers (opening frame `lineLimit`; the transport's `lineCap` made exact) + the boundary pins (just under served, just over answered) | DONE `1caecf4a` (pins) + this commit (fix) — `MCPSession.run`: an over-limit OPENING answered `MCPHandshake.overLimitResponse` (`id: null`, -32000, "…a message before initialize ran past 1 MiB (1,048,576 bytes).") then closed — nothing decided/logged/claimed · `MCPSocketTransport.readLines` EXACT (a complete line measured too) and LINEAR (only each read's new bytes scanned) → `ReadEnd`; its reader answers an over-cap message through the ACTOR (serialized with the SDK's `send`; a bounded 2 s wait) — "…a message ran past 16 MiB (16,777,216 bytes), the most one message may carry. Send smaller messages and reconnect." Green: `MCPSizeCapTests` 8/8 (1 MiB initialize served 0.46 s · +1 answered · preamble +1 answered · probe at 1 MiB answered then initialize opens · **16 MiB call served 0.555 s** · +1 answered · exactness) · the VX-180/168 window, probe, key and shim suites unchanged and green; **`VariorumMCPTests` 152/24 green twice** |
| 6 | over-cap red-on-old BY REVERT | DONE (the same revert as piece 4) — RED again: the opening +1 (closed unanswered, 3 issues) · the preamble +1 · the session +1 (60 s, no answer) · the exactness pin · **the 16 MiB call at the cap (unserved in 30 s)**; green both sides by design: the 1 MiB initialize and the 1 MiB probe at the opening's cap (the opening reader was always exact and byte-at-a-time). Restored clean |
| 7 | VX-198 — the rule + the admission (newest copy re-binds; the replaced key's own sentence) + state-transition pins | NOT-STARTED |
| 8 | VX-198 faces (the setup sentence, the one refusal sentence, L1, the Deny confirm) + the Mac pins' justified edits | NOT-STARTED |
| 9 | VX-198 red-on-old BY REVERT | NOT-STARTED |
| 10 | headless finals (`VariorumMCPTests`, `VariorumCoreTests`, workbook) + the Mac target's build-for-testing | NOT-STARTED |
| 11 | READY FOR STAGE (turn ends; the orchestrator's GO) | NOT-STARTED |
| 12 | the stage window: the Mac batch + THE LIVE ROUND legs (a)–(d), dev store only | NOT-STARTED |
| 13 | close: self-assessment, PROVISIONALs, OWED | NOT-STARTED |

**No revert is in flight** (pieces 2, 4 and 6's reverts ran and were RESTORED — `git checkout HEAD --`, the moved files back, `git status` clean each time).

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
