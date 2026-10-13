# VX-184 handoff — MCP launch polish (closed 2026-10-13)

**Your checklist (in this order):**

1. **Send the stargazing brief to your site agent.** `notes/stargazing-mcp-guide-brief-2026-10-12.md` is send-ready as
   one message. It's written for the public release, which is the next MCP update (VX-246), not today's build, and it
   says so. If the agent already built from yesterday's version, the brief's top lists exactly what changed. One more
   short update comes when VX-246 is built.
2. **This build is yours alone.** Don't release it publicly until **VX-258** ships (in VX-246): today, a setup key
   copied for any tool can take over an approved client's name and grants if that tool calls itself by the same name.
   Your ruling closes it — tab-tied keys, with an Any-client re-bind waiting for your OK.
3. **Try the door once on your real store** (only you can open your real app): open Variorum, make sure Settings ▸ MCP ▸
   Enable the MCP server is on, run `claude mcp list` (expect ✔ Connected), then ask Claude Code for one small thing,
   e.g. to list your books. If Claude Code says Variorum must be open, the app isn't running or the switch is off.
   (VX-201's note still applies: this build's first open may tidy a lingering silent key copy — you pre-cleared that.)
4. **Re-run Claude Code's setup on the Air** if it still runs the old bridge (`~/.variorum/mcp-discover-bridge.py`):
   Settings ▸ MCP ▸ Connect a client ▸ Claude Code ▸ Copy setup command, run it, start a new session. With this build,
   running a setup again simply replaces the old one (no Deny needed).
5. **Your review queue:**
   - **QUESTIONS #218** — every PROVISIONAL of the run, each with its options (U1–U5 and the ladder).
   - **VX-234** — the wording review; it now carries the corrected edit-access consent sentences (the old ones promised
     "a commit before and after every change", which stopped being true).
   - **VX-246's kickoff calls:** VX-268's Pool / Book Panel / Blocks rows and the open-book behavior (recommendations in
     the ticket), VX-253's lens design (your ruling is on the ticket), and anything you add.
6. **One answer I still need from you:** the closeout step I proposed for CLAUDE.md — at every closeout, check each
   ruling's full wording against what shipped and ticket any remainder. Add it? (Your round-6 "crat attack" fence check
   is DONE — your word, 2026-10-13; recorded on the 13n-c handoff.)
7. **Restore Tutorial is NOT needed for this build** — the field guide's MCP chapter didn't change (that's VX-197, in
   VX-246). Your AI can still learn every new tool by listing the tools: each one's description is accurate.

## What shipped (U1–U5)

- **U1 — the socket and key road (VX-132, VX-181, VX-198):** with the app closed, Claude Code now hears "Variorum must
  be open" instead of a dead connection; messages past the size cap get an answer instead of a silent close; running a
  client's setup again replaces the old one (approval and grants kept) — **narrowed by VX-258 before any public build**.
- **U2 — the gatherings icon (VX-185):** a gathering wears the shared icon when a wing grant or the open book reaches it.
- **U3 — the door's ergonomics (VX-186, VX-173, VX-188, VX-190, VX-187):** `read_note` sends each paragraph once; batch
  takes and comments (up to 200, one undo); an AI can delete its own comments at suggest (your ruled refusal sentence
  otherwise); `remove_tag`; `link_versions` makes two notes Compare peers.
- **U4 — edit parity inside a note (VX-195):** twelve edit-level tools — comments, takes (deleting a paragraph's last
  take deletes the paragraph), commits, the note's title, lenses.
- **U5 — edit parity across the library (VX-196):** fourteen tools — books (rename, finish, archive, delete; the daily
  Journal never deletes), chapters, ordering, removing notes from books, deleting and archiving notes.
- **Every AI act is one ⌥⌘Z, named for the client;** an undo never overwrites a change you made since (fixed in the
  review). Private, Seal and Own stay yours alone.
- **VX-278:** the Air sitting's R-AIR numbers are retired — every ruling is a VX ticket (map in VX-165).

## The numbers

- Headless on the merged tree: VariorumMCPTests 212/41 · core 2,782/319 · workbook 40/6.
- Mac, at the merge moment: the whole target, 4,551 tests in 742 suites. Three red tests, all standing on main (VX-115;
  VX-245's eight known sites; VX-167's `redoNeverAsks`, which only fails when tests run in parallel), no new red. Both
  corrected consent sentences seen whole on screen in Study and Terminal.
- Merged: PR #157, merge commit `98c44900`; the ledgers on main at `b228e51c` (AppSpec, QUESTIONS #218, the in-flight
  row retired).
- The review: an Opus ladder at max effort, closed at round 2 (round 1: 1 MAJOR, 6 MINOR, 5 NIT; round 2: 0 BLOCKER,
  0 MAJOR, 5 MINOR, 1 NIT). Every finding has a written disposition in the run record.
- Refresh: **Variorum 0.9.4 (7045) installed** in `/Applications`, replacing 6843 — a Release build from merged main. A1
  first: your real store's seven files `cmp`-identical in the container's
  `Backups/safety-copies/vx184-refresh-20261013T214607Z`. The new app was staged beside the old and codesign-verified
  before the swap ("valid on disk", "satisfies its Designated Requirement"); 6843 is in your Trash if you ever want it.
  Nothing was launched or quit. Acceptance, with your app closed: your Pro's Claude Code registration is bridge-free and
  `claude mcp list` answered honestly — "Variorum must be open: its MCP server is not running. Open Variorum, turn on
  Settings ▸ MCP ▸ Enable the MCP server, then reconnect." (VX-181's fix, live).

## Tickets minted or moved by this run (your ask — the full list)

- **VX-246 — Run: MCP pane, docs & door fixes** (the next MCP run; plan `notes/plans/mcp-pane-and-docs-kickoff.md`) and
  its members: VX-197 · VX-199 · VX-205 · VX-230 · VX-231 · VX-232 · VX-252 · VX-253 · VX-254 · VX-255 · VX-256 · VX-258 ·
  VX-259 · VX-260 · VX-261 · VX-267 · VX-268 · VX-275 · VX-276 · VX-279 · VX-280.
- VX-262 — lenses created on import (Parked, your reasoning in it).
- VX-277 — your own doors' undo/redo over a later change (v1 release readiness).
- VX-269 · VX-270 · VX-271 · VX-272 · VX-273 · VX-274 — the six Air rulings that never had tickets (Done, under VX-165).
- VX-278 — the R-AIR retirement itself (closed with this run).
- Corrected, not minted: VX-245 (credits VX-246 for its two MCP sites), VX-234 (the consent sentences added).

## Left on disk, deliberately

- The dev store's prestage copies this run made (`scale-prestage-20261013T…` in the DEV container's
  `Backups/safety-copies/`) stay — they sit beside VX-201's W-1 Castle copy (`castle-W1-20261013`, yours, never to be
  deleted), and telling them apart by name alone is too easy to get wrong. Delete the `scale-prestage-*` ones if you
  want the space.

## For a fresh session

Everything lives in `notes/plans/fixes/vx-184-mcp-launch-polish.md` (the RUN record: unit records, both ladder rounds,
her rulings verbatim, the stage log, the ticket table) and `notes/plans/vx-184-orchestrator-handoff.md` (the
orchestrator's resume map). The next run is VX-246; its plan is self-contained.
