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
| 2 | THE FIX — the pre-initialize window in `MCPHandshake.readOpening` (requests answered before the next read; notifications skipped; bounded); its pure pins; the one justified edit of an existing arm | NOT-STARTED |
| 3 | red-on-old BY REVERT (announced here before it starts; the fix committed first) | NOT-STARTED |
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
