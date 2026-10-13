# VX-180 kickoff — the MCP handshake must survive Claude Code's pre-initialize `server/discover` probe

**LAUNCH CRITICAL — her word 2026-10-12 evening ("I'm hoping to launch still tomorrow").** Ticket: VX-180
(urgent, 13n project). Found live on the Air during her readme editorial session, diagnosed end-to-end there;
this file carries the evidence so nothing needs re-deriving.

## The bug, exactly

Claude Code (2.1.296, flipped on by a server-side rollout mid-day 2026-10-12 — the SAME binary passed the
VX-168 U1 drill that morning) now opens every MCP stdio connection by PIPELINING two frames:

```
{"jsonrpc":"2.0","id":"server-discover-probe-1","method":"server/discover","params":{"_meta":{"io.modelcontextprotocol/protocolVersion":"2026-07-28","io.modelcontextprotocol/clientInfo":{"name":"claude-code","title":"Claude Code","version":"2.1.296",...},"io.modelcontextprotocol/clientCapabilities":{...}}}}
{"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{...},"clientInfo":{"name":"claude-code",...}},"jsonrpc":"2.0","id":0}
```

(Captured verbatim through a tee wrapper on the Air, 2026-10-12 20:19 MDT. Note the probe carries clientInfo
only inside `params._meta` — there is NO top-level clientInfo, and its protocolVersion names a 2026-07-28 spec
draft.)

`MCPHandshake`'s opening read (VX-168 U1: preamble line → the initialize frame) takes the FIRST frame as the
initialize, finds no name, and answers the probe's id with the one refusal sentence
(`MCPHandshake.refusal`), then the host CLOSES — the real `initialize` sitting in the buffer is never read.
Observed from the server side as her Activity's "an unnamed client was refused connecting without a name";
observed from Claude Code as `CONNECTION_CLOSED` after ~25 ms on EVERY connection (sessions, `/mcp`
reconnect, and `claude mcp list` alike). The door is dead for the flagship client, including for any beta
tester following the pane's setup instructions today.

Reproduce: the keyed socket harness (`connect(as:)`) sending the two frames above pipelined — or any real
`claude mcp list` against the Release app.

## The fix shape (proposed — the implementer argues the exact form; this is not canon yet)

In the opening read, BEFORE admission:

- A pre-initialize **request** (has `id`, `method != "initialize"`) is answered with JSON-RPC
  `-32601` "Method not found" on its own id, and the opening read CONTINUES to the next frame. (Claude Code
  does not block on the probe — it pipelines initialize regardless — but a spec-correct -32601 is the honest
  answer and future-proofs clients that do wait.)
- A pre-initialize **notification** (no `id`) is skipped silently.
- The pre-admission window stays BOUNDED: a small cap on pre-initialize frames (and the existing size/over-cap
  guards) so an unadmitted socket cannot hold the handshake open indefinitely. Over the cap: the existing
  refusal road.
- `initialize` then proceeds EXACTLY as today: the admission (`admitMCPConnection`) still decides once, on the
  initialize frame's name plus the preamble key; the replay into `MCPSocketTransport(replay:)` is the
  initialize frame as before. No change to the rule, the admission transaction, the refusal sentence, or any
  arm's byte-identity.
- OUT OF SCOPE: actually implementing `server/discover` (someday, its own ticket if ever).

Surfaces: `Sources/VariorumMCP/MCPHandshake.swift` (+ `MCPSession.run` if the read loop lives there),
`MCPServerHost.refuseOverCap` only if the cap interacts. ZERO schema, zero `Sync/`, zero custody, zero editor
seam, zero app faces (unless a new Activity word for the skipped-probe case is argued — not required).

## Acceptance (pin-before-fix binds)

- **The pin:** a socket-road test replaying the captured two-frame sequence through the keyed harness —
  RED on the pre-fix tree (connection closed, initialize unanswered), GREEN after: the probe answers -32601,
  the initialize admits and serves (tools/list works). Verify red-on-old by revert.
- Notification-first skipped; request-flood past the cap still refused; every existing
  `MCPSetupKeyServerTests` arm byte-unchanged (the refusal sentences and their byte-identity are pinned —
  they must not drift).
- **The live round (the unit's evidence-of-kind):** a REAL `claude mcp list` / `claude -p` turn against the
  Debug app on the dev store under a held stage claim — the drill rig from VX-168 U1 leg (4) is the
  precedent. This is the whole point of the fix; do not close on headless pins alone.
- Suites: VariorumMCPTests whole target headless; the Mac target builds.

## Rules binding this run

- Branch `vx-180-discover-probe`, PR `VX-180: …`, merge commit. Commits say `Part of VX-180`, NO attribution
  trailers. Push after every commit; `notes/SessionResiliencyProtocol.md` binds (LIVE STATUS from the first
  commit). Record file: `notes/plans/fixes/vx-180-discover-probe.md`.
- **The handshake is the secret's accept path ⇒ the cold review is `fable-reviewer`** (her protocol, the
  VX-168 precedent). Pin-before-fix verified by revert; the ladder caps at three rounds.
- Preflight: CLAUDE.md + auto-loaded canon, the master plan's in-flight table, `notes/TICKETS.md`,
  `notes/QUESTIONS.md`, `notes/plans/fixes/vx-168-mcp-client-secret.md` (UNIT 1 RECORD + THE DRILL — the
  handshake's design record), `notes/SessionResiliencyProtocol.md`. SyncSpec NOT required (no `Sync/` line) —
  if the build discovers it needs one, STOP and report.
- Stage: any Mac test batch or the live round needs a held `Tools/stage` claim (this runs on the Pro; the
  Pro's stage).
- Closeout: the A1 `/Applications` refresh at a verified zero-instance window — **coordinate with her; she is
  actively using the real-store app for the readme session tonight. Never quit or kill her running instance;
  ask first or wait for her window.**
- After the refresh, her clients re-run NOTHING (the key binding is untouched) — but the Air's `variorum`
  registration currently points at the BRIDGE (`~/.variorum/mcp-discover-bridge.py`); it keeps working after
  the fix (pure passthrough + a local -32601). Retiring it = she re-runs the pane's Claude Code setup once,
  any time after the fixed build installs. Note it in the handoff; do not reach into her config from the run.

## Context: the workaround now live (the Air, 2026-10-12)

`~/.variorum/mcp-discover-bridge.py` — a stdio passthrough in front of the real shim that answers
`server/discover` with -32601 itself and forwards everything else verbatim (the shim still speaks its own
preamble). Her user-scope `variorum` entry runs it with the same bound key; `claude mcp list` shows Connected.
A beta tester received the same bridge as a paste-prompt. Both retire by re-running the pane's setup once the
fixed build is installed.
