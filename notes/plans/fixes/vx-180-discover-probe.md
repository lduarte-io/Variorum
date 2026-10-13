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
| 0 | this record + LIVE STATUS; `notes/plans/vx180-screens/` gitignored (the live round's evidence home) | DONE `a3033539` |
| 1 | THE PIN — socket-road tests replaying the captured pipelined pair through the keyed harness (pre-existing API only, so they compile on the pre-fix tree); watched RED on the pre-fix tree | DONE `5e51abe2` — `Tests/VariorumMCPTests/MCPDiscoverProbeServerTests.swift`, 5 tests; **RED on the pre-fix tree `a3033539`: 5/5 failed, 14 issues** (the evidence below, "THE PIN — red on the pre-fix tree") |
| 2 | THE FIX — the pre-initialize window in `MCPHandshake.readOpening` (requests answered before the next read; notifications skipped; bounded); its pure pins; the one justified edit of an existing arm | DONE `c65f8de8` — `MCPHandshake` (`preInitializeLimit` · `WindowFrame`/`windowFrame` · `windowAnswer(toRequest:)` · the loop in `readOpening`) + doc comments in `MCPSession` / `MCPServerHost.refuseOverCap` (no code change in either); `MCPPreInitializeWindowTests` (8 — the window's letter); the justified edit of `everyRefusalIsTheSameSentence`'s last arm (see "The justified edit"). The three suites **23/3 green** headless (`MCPDiscoverProbeServerTests` 5 · `MCPPreInitializeWindowTests` 8 · `MCPSetupKeyServerTests` 10) |
| 3 | red-on-old BY REVERT (announced here before it starts; the fix committed first) | DONE `d8dc0e1f` (announced `c2f49bae`) — the evidence below, "RED-ON-OLD BY REVERT" |
| 4 | suites — `VariorumMCPTests` whole target headless; the Mac app target BUILDS | DONE (this commit) — **`VariorumMCPTests` 135 tests / 20 suites, ALL GREEN** headless (`swift test --filter VariorumMCPTests`, 16.1 s; VX-168's close was 122/18 — +13 tests in the 2 new suites; no `skipped:` lines). **The Mac app target: `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx180 build` → `** BUILD SUCCEEDED **`** (the live round's Debug app, `io.lduarte.Variorum.debug`, with its `variorum-mcp` shim). Other suites over the changed types: `VariorumCoreTests` untouched (zero `Sources/VariorumCore` lines); the app's `MCPPaneTests` builds `MCPServerHost` and connects-then-closes (an EOF first read — no window frame), a Mac suite needing the stage: offered for the GO window |
| 5 | self-assessment (below) | DONE (this commit) |
| 6 | READY to the orchestrator; THE LIVE ROUND (gated on its GO + a held stage claim — dev store only) | IN-PROGRESS — READY sent (`d39e92a8`); **GO received; stage CLAIMED `vx180-live` 2026-10-12 21:01:58 (60 min)**; the round running per "THE LIVE ROUND — the plan" below. If this line survives a death: check `pgrep -fl 'Variorum.app/Contents/MacOS'` (quit only the DEV instance, by identity), remove the `-s local` registrations `variorum-dev`/`variorum-tee` from the scratch folder, restore the dev store from the newest `scale-prestage-*` dir with `Tools/ScaleFixture/restore.sh`, empty the clipboard, release the stage |

**No revert is in flight** (piece 3's revert ran and was RESTORED — `git diff` empty after `git checkout HEAD --`, the moved test file `cmp`-identical to the committed one).

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

## RED-ON-OLD BY REVERT (piece 3, 2026-10-12)

Announced in `c2f49bae` before it started; the fix committed at `c65f8de8`. **Reverted:** `MCPHandshake.swift` and
`MCPSetupKeyServerTests.swift` to their pre-fix bytes (`git show 5e51abe2:…`); `MCPPreInitializeWindowTests.swift`
moved aside (it names the window's new symbols, so the target would not compile with it); the doc-only comment edits
in `MCPSession.swift` / `MCPServerHost.swift` stayed (comments — no behaviour). `swift test --filter
'MCPDiscoverProbeServerTests|MCPSetupKeyServerTests'` → **"Test run with 15 tests in 2 suites failed … with 14
issues"**: all FIVE probe pins RED (2 + 4 + 2 + 2 + 4 issues — the same issues as on the pre-fix tree, piece 1),
the ten setup-key arms green on their pre-fix letter. **Restored:** `git checkout HEAD --` the three paths; `git
diff` empty; the moved file `cmp`-identical to the committed one. Re-run → **"Test run with 23 tests in 3 suites
passed"**. Logs: `notes/plans/vx180-screens/logs/revert-red.log`, `revert-green.log` (gitignored).

## SELF-ASSESSMENT (piece 5 — the implementer's, before the cold review)

**Against the kickoff's acceptance:** the pin (the captured pair, pipelined, through the keyed harness) — RED on the
pre-fix tree and RED again with the fix reverted, GREEN with it: the probe answered `-32601` on its string id, the
`initialize` admitted and answered with the advice, `tools/list` listing the grant's tools, a `read_note` served, her
Activity clean. Notification-first skipped (pinned on the socket road and over a socket pair). A request flood past the
bound refused with the ONE sentence, byte-identical to a bare arm, logged `connect_unnamed`, claiming no key. Every
`MCPSetupKeyServerTests` arm green; the refusal sentences untouched; the one arm whose TRIGGER the fix necessarily
changes is the recorded justified edit (its answer byte-identical). `VariorumMCPTests` whole target green; the Mac
target builds. The live round — the unit's evidence of kind — is PENDING the orchestrator's GO.

**Against the spec and the model:** zero schema, zero `Sync/`, zero custody (the key's rule, the admission
transaction, `MCPPreamble` and the shim are untouched — the window sits BEFORE the one decision and decides nothing),
zero editor seam, zero app face. A-4/K2's boundary is unchanged: identity is still decided once per connection, on
the `initialize` frame's name and the preamble's key; the window's bytes are a function of the frame alone, so it adds
no oracle (P-VX168-U1-4's no-oracle letter holds — the flood's refusal is pinned byte-identical to the bare arm's).
P2: the window runs on the handshake's own thread (and the over-cap helper thread), never the cooperative pool.

**Risks I see, said plainly:**
1. **A behaviour change for every non-`initialize` first REQUEST** (not only `server/discover`): it is now answered
   `-32601` and the connection stays open for up to 8 frames, where it was refused at once. That is the fix's point
   and the kickoff's shape; the only client known to do it is Claude Code. The cost is the justified edit.
2. **Work per unadmitted connection grows from 1 frame to at most 9** before the refusal (each frame still capped at
   `lineLimit`, 1 MiB, read a byte at a time). The socket is `0600` in her container (same-user only) and live
   sessions are capped at 16, so this buys a same-user process nothing it could not already do; recorded, not
   mitigated.
3. **Pre-existing, unchanged:** the opening read has no overall deadline — a peer that connects and stays silent
   holds a session slot until it closes (the session cap bounds it). The window adds no unbounded wait of its own
   (every iteration needs a new frame from the peer). Not this ticket's; noted for the reviewer.
4. **`ping` → empty result** goes beyond the kickoff's literal "-32601 for any non-initialize request" — argued in
   design call 3 from MCP's lifecycle and this server's own SDK; P-VX180-2 offers the literal shape as option (b).
5. **The test helpers** (`RawSocket`, `CapturedClaudeCode`) are internal to the test target; every new socket read
   runs under a receive timeout, so a regression fails a pin rather than hanging the suite (the VX-132 class).

## PROVISIONALs (each wants a `notes/QUESTIONS.md` entry at the merge — the merging session's ledger)

- **P-VX180-1 — the window's bound, 8 frames.** How many requests/notifications may a client send before
  `initialize`? (a) **8, as built** — generous beside Claude Code's one probe, same order as the blank-line
  tolerance; (b) a tighter 1–2 (exactly the probing known today — a client that probes more is refused); (c) no
  count, a time bound on the whole opening instead (it would also close the pre-existing silent-peer gap, risk 3).
- **P-VX180-2 — a `ping` before `initialize` gets the empty result.** (a) **as built** — MCP's lifecycle allows
  pre-initialize pings, its ping utility requires an empty response, and this server's SDK answers a ping before
  initialize exactly so; (b) the kickoff's literal shape — `-32601` for every non-`initialize` request, ping
  included.
- **P-VX180-3 — the window's words: JSON-RPC's own "Method not found", nothing echoed.** (a) **as built**; (b) the
  SDK's post-admission wording (`Method not found: Unknown method: <method>` + `data.detail`) — one voice across the
  window and the SDK, at the cost of echoing client text before the connection is decided; (c) a Variorum sentence
  (e.g. "Variorum answers initialize first."). Technical register on the wire (P-13n-1); her copy pass if she wants
  one.
- **Argued, not provisional:** where the window lives (`readOpening` now writes — design call 1); what ends the
  window at once (anything that is no well-formed request or notification keeps the pre-fix road — design call 2);
  `refuseOverCap` inheriting the window (design call 6); no Activity word (design call 8).

## OWED (for the orchestrator)

1. **Canon at the merge (her call whether it earns a line):** AppSpec §12's THE MCP DOOR line could gain one
   clause — "the handshake answers a pre-initialize request (`-32601`; a ping, its empty result) and skips a
   notification inside a bounded window, before the setup key's one decision (VX-180)". No other canon is stale
   (the line never claimed the first frame IS the initialize). The QUESTIONS entries above. MOBILE PARITY: nothing
   mobile-visible.
2. **Noticed, NOT this unit's — now ticket VX-181 (minted under 13n by the orchestrator, Bug + Pre-launch; a second surface — the shim binary, `Sources/VariorumMCPSocket/MCPShim.swift`):**
   when the shim CANNOT reach the app (Variorum closed — "Variorum must be open"; or not inside the app bundle), it
   answers the client's FIRST line and exits (`respondToFirstRequest`). With Claude Code that first line is now the
   probe, so the honest sentence lands on the probe's id and the `initialize` goes unanswered — the connection fails
   either way (correct: the app is closed), but Claude Code may show only "connection closed" instead of "Variorum
   must be open". A beta tester with Variorum closed would meet it. VX-181 carries it; the fix shape is
   the same window, in the shim's refusal read. Not done here — one surface per batch.
3. **Her handoff (the kickoff's note):** after the fixed build is installed her clients re-run NOTHING (no key
   binding changes); the Air's `variorum` registration currently runs the BRIDGE (`~/.variorum/mcp-discover-bridge.
   py`), which keeps working after the fix (pure passthrough + a local `-32601` the app never sees); retiring it =
   she re-runs the pane's Claude Code setup once, any time after the install. The beta tester's pasted bridge
   retires the same way. Never reached into from this run.
4. **The A1 `/Applications` refresh** — the closeout's, at a verified zero-instance window coordinated with her
   (she is using the real-store app tonight).

## THE LIVE ROUND — the plan (piece 6; runs ONLY on the orchestrator's GO, under the claim name it gives)

Dev store ONLY, the Debug app `App/Variorum/DerivedData/vx180/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`); the VX-168 U1 drill (leg 4) is the precedent.
1. **Guards first:** `Tools/WalkKit/guard.sh --author` (her `/Applications` app absent; HID idle) — if her app is
   running, STOP and report (never quit or kill it); no other `Variorum.app/Contents/MacOS` process. Claim the
   stage with the given name.
2. **A1 prestage copy** of the dev store (the store files + key files → `…/Variorum-dev/Backups/safety-copies/
   scale-prestage-<ts>/`, each `cmp`-verified — `Tools/ScaleFixture/stage.sh`'s copy loop, WITHOUT its fixture
   launch), so `Tools/ScaleFixture/restore.sh` restores it.
3. **Launch** the Debug app (`open -n`), confirm the MCP server is ON in Settings ▸ MCP; Settings ▸ MCP ▸ Connect a
   client ▸ Claude Code ▸ **Copy setup command** (cliclick under the per-step guard) — the clipboard's line minted a
   fresh key. If `claude-code` is already bound to another key in the dev store, the rotation road (Deny… →
   Approve…, P-VX168-U1-1) first, recorded.
4. **The real client, never her user scope:** in a scratch folder, the copied line with `-s user` → `-s local`
   (registration `variorum-dev`, the REAL fixed shim) plus a second `-s local` registration `variorum-tee` running
   the same shim behind a `tee` wrapper (to CAPTURE the probe arriving on this Mac and the `-32601` leaving).
   `claude mcp list` → both **Connected** (the kickoff's symptom was CONNECTION_CLOSED); the tee logs show
   `server/discover` in, `-32601` out, `initialize` answered. Then ONE `claude -p` turn with `--strict-mcp-config
   --mcp-config <scratch json for the plain shim>` (isolated from every other registration) calling `list_books`
   once — served. Her user-scope servers read BEFORE and AFTER (untouched).
5. **Her Activity** in the dev app: claude-code's acts listed, NO "an unnamed client was refused" — one capture.
   (No new face exists; one voice suffices — the record says so.)
6. **Optional, same window:** `xcodebuild test -only-testing:VariorumTests/MCPPaneTests` (the app suite that builds
   `MCPServerHost`).
7. **Cleanup:** both `-s local` registrations removed; the dev instance quit BY IDENTITY; the dev store restored
   (`restore.sh`, "Restored (verified)"); the clipboard emptied; transcripts in `notes/plans/vx180-screens/`
   (gitignored; every key REDACTED to its first 9 characters); the stage released; evidence recorded here.
