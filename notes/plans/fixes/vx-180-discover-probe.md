# VX-180 — the MCP handshake survives Claude Code's pre-initialize `server/discover` probe

**What this run did NOT do (said first — PENDING until the close; the line is rewritten at the record's close).**

**The RECORD** (a small fix that touches the secret's accept path, so it lands a repo record — CLAUDE.md). Kickoff:
`notes/plans/vx-180-kickoff-prompt.md` (binding; the captured frames verbatim, the proposed fix shape, acceptance,
the rules). Branch `vx-180-discover-probe`, worktree `~/dev/variorum-vx180`, PR `VX-180: …` (merge commit).
Cast: Fable orchestrates; `opus-implementer` builds (this session); `fable-reviewer` cold-reviews (the handshake is
the secret's accept path — her protocol, the VX-168 precedent). Design record of the code changed:
`notes/plans/fixes/vx-168-mcp-client-secret.md` (UNIT 1 RECORD — design calls 3–5, piece 4; THE DRILL).

**Surfaces:** `Sources/VariorumMCP/MCPHandshake.swift` (the opening read) · `MCPSession.run` / `MCPServerHost.
refuseOverCap` doc comments only where the opening read's meaning changed · `Tests/VariorumMCPTests/`. ZERO
schema, zero `Sync/`, zero custody, zero editor seam, zero app faces.

## LIVE STATUS (per the resiliency protocol — flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS; `notes/plans/vx180-screens/` gitignored (the live round's evidence home) | DONE (this commit) |
| 1 | THE PIN — socket-road tests replaying the captured pipelined pair through the keyed harness (pre-existing API only, so they compile on the pre-fix tree); watched RED on the pre-fix tree | DONE (this commit) — `Tests/VariorumMCPTests/MCPDiscoverProbeServerTests.swift`, 5 tests; **RED on the pre-fix tree `a3033539`: 5/5 failed, 14 issues** (the evidence below, "THE PIN — red on the pre-fix tree") |
| 2 | THE FIX — the pre-initialize window in `MCPHandshake.readOpening` (requests answered before the next read; notifications skipped; bounded); its pure pins; the one justified edit of an existing arm | DONE (this commit) — `MCPHandshake` (`preInitializeLimit` · `WindowFrame`/`windowFrame` · `windowAnswer(toRequest:)` · the loop in `readOpening`) + doc comments in `MCPSession` / `MCPServerHost.refuseOverCap` (no code change in either); `MCPPreInitializeWindowTests` (8 — the window's letter); the justified edit of `everyRefusalIsTheSameSentence`'s last arm (see "The justified edit"). The three suites **23/3 green** headless (`MCPDiscoverProbeServerTests` 5 · `MCPPreInitializeWindowTests` 8 · `MCPSetupKeyServerTests` 10) |
| 3 | red-on-old BY REVERT (announced here before it starts; the fix committed first) | NOT-STARTED — the plan: restore the pre-fix `MCPHandshake.swift` + `MCPSetupKeyServerTests.swift` from `5e51abe2` and move `MCPPreInitializeWindowTests.swift` aside (it names the new symbols), run `MCPDiscoverProbeServerTests`, then `git checkout HEAD --` all three and re-run |
| 4 | suites — `VariorumMCPTests` whole target headless; the Mac app target BUILDS | NOT-STARTED — counts PENDING |
| 5 | self-assessment (below) | NOT-STARTED |
| 6 | READY to the orchestrator; THE LIVE ROUND (gated on its GO + a held stage claim — dev store only) | NOT-STARTED |

**No revert is in flight.**

## THE PIN — red on the pre-fix tree (piece 1, 2026-10-12)

`swift test --filter MCPDiscoverProbeServerTests` on the pre-fix tree `a3033539` (MCPHandshake untouched; the new
file only): **"Test run with 5 tests in 1 suite failed … with 14 issues"** — every test, at the predicted line:

- `claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes` (THE PIN — the captured pair, pipelined behind
  claude-code's own bound key): the probe's id WAS echoed (a string) but its answer was `code → -32000` — the
  setup-key refusal — and `socket.nextResponse()` → nil: EOF, the pipelined `initialize` never answered. Exactly the
  kickoff's diagnosis (`readOpening` returned the probe as the first frame → `initialize(_:)` nil → admission under
  the name `""` → refused `connect_unnamed` → the host closed).
- `aClientThatWaitsForTheProbesAnswerHearsItBeforeSendingInitialize`: `-32000` on the probe; the initialize, sent
  after the answer, met a closed socket (no result; no client row).
- `aNotificationBeforeInitializeIsSkippedSilently`: the first line read was the refusal sentence on `"id": null` —
  the notification had been taken as the initialize.
- `aPingBeforeInitializeIsAnsweredEmpty`: the ping heard the refusal; nothing after.
- `pastTheSessionCapTheCapsSentenceAnswersTheInitializeNotTheProbe`: the over-cap sentence answered the PROBE's id
  (`-32000`), the initialize never answered.

The log: `notes/plans/vx180-screens/logs/pin-red-prefix.log` (gitignored).

## The design calls, argued (piece 2)

1. **Where the window lives — inside `readOpening`, which therefore now WRITES.** The kickoff's wire-order point
   decides it: a spec-correct client may hold its `initialize` until the probe is answered, so the answer must reach
   the wire BEFORE the read blocks on the next frame. Only the reader can do that without a second thread or a
   callback, and the reader already runs on its own blocking thread (`MCPHandshake.opening(fd:)`, and the over-cap
   helper thread), so a write from there is legal and cheap. **What the purity claim becomes:** `readOpening` was
   "pure over a descriptor"; it is now "a read-and-answer over ONE descriptor — no store, no state, and the only
   bytes it writes are the window's fixed answers, each before the next read". The two decisions it consults are
   PURE and pinned directly (`windowFrame` classifies a frame; `windowAnswer(toRequest:)` builds the answer bytes);
   the loop is pinned headless over a socket pair (both orders — pipelined, and a client that reads before it sends
   `initialize`, through the production `opening(fd:)` entry point). The old pipe-based opening-read pins are
   untouched and still green: none of their frames asks for an answer, so nothing is written to the pipe.
2. **What each frame is to the window** (`WindowFrame`): `initialize` by its method name → the opening's frame, and
   from there the road is byte-for-byte the pre-VX-180 one (an `initialize` NOTIFICATION or one with no clientInfo
   included — today's handling, untouched). A **request** = a JSON object with a string `method` and an `id` the
   refusal itself would echo (a string or a number — the one id rule, `MCPShim.refusalResponse`'s) → answered on its
   id, the window continues. A **notification** = a string `method` and NO `id` → skipped (JSON-RPC answers none),
   the window continues. **Anything else** — a response, a batch array, a `null` id (MCP forbids it), an id no
   answer could echo, malformed bytes — ends the window AT ONCE on the pre-VX-180 road (the admission refuses it as
   unnamed, the one sentence on its id). Argued: only the two well-formed JSON-RPC client-message shapes are
   tolerated before `initialize`; everything else keeps exactly today's handling, which minimises the behaviour this
   change can reach.
3. **The answers.** Every request but `ping`: JSON-RPC 2.0's `-32601` with its spec's own message **"Method not
   found"** — before admission no method is served, and the spec's text for the code is "The method does not exist
   / is not available". No client-supplied text is echoed (the SDK's post-admission answer for an unknown method
   carries `"Unknown method: <method>"`; the window echoes only the id, so a frame's method and params never reach
   the wire before the connection is decided). The id is echoed AS IT ARRIVED (the probe's string stays a string;
   `JSONSerialization` round trip, `.sortedKeys` — the refusal's own serialization). **`ping`** gets the EMPTY
   result (P-VX180-2, PROVISIONAL — below): MCP's lifecycle carves pings out ("The client SHOULD NOT send requests
   other than pings before the server has responded to the initialize request" — quoted in the pinned swift-sdk
   0.12.1's `Server.swift`, strict-mode branch), its ping utility requires an empty response, and this server's own
   SDK answers a ping before `initialize` with `Empty()` (`withMethodHandler(Ping.self) { _ in return Empty() }`,
   exempt even in strict mode). A `-32601` to a ping would be the one place this server answers ping otherwise.
4. **The bound — `preInitializeLimit = 8` frames** (P-VX180-1 — the number). N requests/notifications are answered
   or skipped; the frame PAST them is the opening's whatever it is — an `initialize` still opens (the boundary
   pinned both ways), anything else meets the refusal ("over the cap: the existing refusal road" — the kickoff's
   letter). Each frame read is still bounded by `lineLimit` and each `nextLine` by `blankLimit`, so a connection
   that never initializes ends after at most 8 frames instead of looping; its refusal is the ONE sentence,
   byte-identical (pinned against a bare arm), logged as the unnamed connection it is, and it claims no key (the rule
   refuses `unnamed` before any key arm — pinned: the presented key stays `unclaimed`). Why 8: Claude Code sends
   one probe; eight is generous for any honest client's probing and the same order as the blank-line tolerance.
5. **No oracle, no decision.** The window's bytes depend on the frame alone — never on the preamble's key, the
   name, or the library — and it writes nothing to the store. Identity is still decided ONCE, by
   `admitMCPConnection` on the `initialize` frame's name and the preamble's key; the replay into
   `MCPSocketTransport(replay:)` is still that one frame. No arm of `MCPSetupKeyRule`, no refusal sentence, no
   admission transaction, no Activity word is changed (the arms' byte-identity re-pinned green, below).
6. **`refuseOverCap` inherits the window with ZERO code change** (doc comment only): it reads the opening through
   the same `readOpening`, so past the session cap a probe-first client hears the probe answered and the cap's
   sentence on its `initialize` — the request it reports — where the pre-fix tree answered the probe's id with it
   (pinned, red on the pre-fix tree). Its 2 s receive timeout still governs every read in the window.
7. **The SDK never sees the window's traffic.** The answered probe is not replayed (only the `initialize` is), so
   the SDK's own `server/discover` handling (`-32601 Method not found: Unknown method: …` post-admission) is never
   reached by a pre-initialize frame; a probe sent AFTER initialize would meet the SDK's own answer, unchanged.
8. **Considered and left out:** an Activity word for an answered probe (protocol noise with no identity — her
   Activity already logs every connection's outcome; logging pre-admission traffic would also let any local
   process write rows without a key, which the refusals already bound); implementing `server/discover` (out of
   scope by the kickoff).

## The justified edit (the ritual)

`MCPSetupKeyServerTests.everyRefusalIsTheSameSentence` — its LAST arm sent `{"jsonrpc":"2.0","id":5,"method":
"tools/list"}` as the first frame and expected the one sentence on id 5 at once. That premise ("a non-initialize
REQUEST first is refused immediately") is EXACTLY the behaviour VX-180 changes — under the kickoff's own fix shape the
request is answered `-32601` and the window reads on — so the arm could not stay byte-unchanged in its TRIGGER. Its
ANSWER does: the edited arm sends the window's `preInitializeLimit` requests first (each answered `-32601`), then the
SAME frame, which now reaches the refusal past the bound and hears the one sentence on id 5 — the same bytes, still
in the arm set's one-sentence `Set` (count 1). The immediate-refusal road for a frame that is no request at all is
pinned in `MCPPreInitializeWindowTests.aFrameThatIsNoRequestEndsTheWindowAtOnce`. Every OTHER arm of
`MCPSetupKeyServerTests` is untouched and green (10/10), `MCPHandshake.refusal` / `storeErrorRefusal` are untouched
(the sentence's bytes are pinned by every arm), and `theOpeningReadTakesThePreambleThenTheFrameAndNothingMore` passes
unchanged (its `{"id":1}` frames carry no method — `other` — so they end the window at once, as before).
