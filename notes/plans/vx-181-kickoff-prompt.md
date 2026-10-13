# VX-181 kickoff — the shim with the app CLOSED answers Claude Code's probe, so "Variorum must be open" never shows

**Pre-launch (her call on whether it gates the launch). Ticket: VX-181 (13n project, Bug + Pre-launch).**
Born at VX-180 (2026-10-12 evening — merged PR #152), where it was diagnosed, CONFIRMED LIVE, and deliberately
scoped out (a different surface: the shim, not the server handshake). 0.9.4 shipped the same evening with a
"one known edge" note naming exactly this; when VX-181 lands she may want it in the next release — her call.
She intends to run this WITH OTHER MCP IMPROVEMENTS in one session: if several tickets run together, mint ONE
RUN TICKET per CLAUDE.md (`Run: <theme>`, members as sub-issues, the run's number names the ONE branch and PR);
alone, branch `vx-181-shim-closed-probe`, PR `VX-181: …`, merge commit.

## The bug, exactly

Claude Code 2.1.296 pipelines a `server/discover` request BEFORE `initialize` on every stdio connection (the
captured frames are in `notes/plans/vx-180-kickoff-prompt.md`, verbatim). VX-180 fixed the SERVER side — the
in-app handshake now answers pre-initialize requests inside a bounded window (`MCPHandshake.readOpening`,
`Sources/VariorumMCP/MCPHandshake.swift` — read it; the shim-side fix should mirror its shape and constants).

The SHIM side is still probe-blind: when `variorum-mcp` cannot reach the app's socket (Variorum closed, or the
shim run from outside the bundle), **`MCPShim.respondToFirstRequest`** (`Sources/VariorumMCPSocket/MCPShim.swift`)
reads ONE line, answers it with the honest refusal ("Variorum must be open…"), and exits. With the new Claude
Code, that first line is the PROBE — the refusal lands on the probe's id (which Claude Code ignores), the
pipelined `initialize` is never answered, and the user sees only `CONNECTION_CLOSED`.

**Seen live, twice, during VX-180's round (2026-10-12 21:02–21:09 MDT, the record's live-round evidence):**
her user-scope `variorum` registration (the installed Release shim, app closed) read "✘ Failed to connect —
CONNECTION_CLOSED" in the same `claude mcp list` that showed the fixed in-app road "✔ Connected". A beta tester
with Variorum closed hits this on first contact — the honest sentence exists and never ships.

## The fix shape (proposed — the implementer argues the exact form)

In the shim's refusal read (`respondToFirstRequest` or its reader), the SAME bounded pre-initialize window
VX-180 built server-side:

- A pre-initialize **request** (string `method` + string/number `id`, `method != "initialize"`) is answered on
  its own id before the next read — `-32601` "Method not found"; **`ping` gets its empty result** (mirror
  P-VX180-2's shape exactly: the SDK itself answers pre-init pings empty, so -32601 would be an oracle).
- A **notification** is skipped silently.
- The window is **bounded** (VX-180 chose 8 — reuse the number or argue one; past the bound, the existing
  refusal road).
- **`initialize` (or a non-request frame, or the bound) then gets the existing "Variorum must be open" refusal
  answering by id, exactly as today** — the sentence's bytes must not drift.
- **The A-2 letter ("MCP-blind", amended at VX-168) must be squared in the record:** the shim parses nothing of
  MCP in its PUMP path; the refusal road already reads one line and echoes an id (`MCPShim.refusalResponse`),
  so the window extends the refusal road's existing capability, never the pump. Say this in the record; if the
  implementer finds the letter genuinely falsified, that's a recorded amendment, not a silent drift.
- **CARRIED FROM VX-180's LADDER (round 1 NIT 1, the reviewer's accepted deferral — in this ticket's body):**
  expose ONE shared echoable-id predicate in `VariorumMCPSocket` and switch BOTH call sites to it
  (`MCPShim.refusalResponse`'s inline check and `MCPHandshake.isEchoableID` — the pointer comment on the latter
  names this ticket). Today all three sites are `is String || is NSNumber`, byte-equivalent; the predicate pins
  that they stay one rule.
- OUT OF SCOPE: implementing `server/discover`; any server-side change (`Sources/VariorumMCP/` beyond the
  predicate switch in `MCPHandshake`); any app face.

Surfaces: `Sources/VariorumMCPSocket/MCPShim.swift` (+ `MCPPreamble.swift` only if the shared predicate lands
there) · `Sources/VariorumMCP/MCPHandshake.swift` (the predicate switch ONLY) · `Tests/VariorumMCPTests/`
(`MCPShimTests` and the window suites). ZERO schema, zero `Sync/`, zero custody, zero editor seam, zero app
faces. **The shim carries the setup key (its preamble speak) — treat the diff as key-adjacent: the cold review
is `fable-reviewer`** (the VX-168/VX-180 precedent; the author may redirect at kickoff).

## Acceptance (pin-before-fix binds)

- **The pin:** a shim-road test feeding the captured probe+initialize pair to a shim with NO reachable socket —
  RED pre-fix (the must-be-open refusal answers the PROBE's id; `initialize` unanswered), GREEN after (the probe
  answers -32601 on its string id; `initialize` answers the must-be-open refusal, byte-identical sentence).
  Verify red-on-old by revert.
- Notification-first skipped; ping answered empty; the bound holds both ways; the refusal sentence's bytes
  pinned unchanged; the shared predicate consulted by both call sites (a pin that the two answers' id rules
  cannot drift apart).
- `VariorumMCPTests` whole target headless (VX-180's close: 135/20); the Mac target BUILDS.
- **The live leg:** with the fixed Debug shim registered `-s local` in a scratch dir and NO Variorum instance
  running, a real `claude mcp list` shows the honest failure (Claude Code surfaces the server's error text —
  verify what it actually displays and record it; if it still swallows the message, record THAT honestly: the
  fix's value is then spec-correctness + any client that does show it). Needs NO stage claim (no screen, no
  store — the shim alone), but the zero-instance condition must be real: coordinate with the day's stage
  coordinator if one is live, and NEVER quit a running instance to make the condition.

## Rules binding this run

- Preflight (read in full, never delegated): CLAUDE.md + auto-loaded canon · `notes/plans/fixes/
  vx-180-discover-probe.md` (the window's design calls + the live evidence) · `notes/plans/vx-180-kickoff-prompt.md`
  (the captured frames) · `notes/plans/fixes/vx-168-mcp-client-secret.md` UNIT 1 RECORD (the shim's design,
  the A-2/MCP-blind letter, piece 3) · the master plan's in-flight table · `~/dev/variorum/notes/TICKETS.md` ·
  `notes/QUESTIONS.md` #214 · `notes/SessionResiliencyProtocol.md`. SyncSpec NOT required (zero `Sync/`) — if
  the build discovers otherwise, STOP and report.
- Record file `notes/plans/fixes/vx-181-<slug>.md` (or the run's one record) — LIVE STATUS from the first
  commit; commits `Part of VX-181` (or the run's members), NO attribution trailers; push after every commit.
- Worktree per CLAUDE.md (`~/dev/variorum-<effort>`); kickoff declares surfaces and checks the in-flight table.
- The 0.9.4 release notes' "one known edge" paragraph names this bug — when the fix ships in a release, that
  paragraph retires (the next version's notes are hers to write).
