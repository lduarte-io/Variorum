# Phase 13n-b — the MCP door (Level 2: the server, the grants, the pane)

## KICKOFF MESSAGE (for a fresh orchestrator session)

You are kicking off 13n-b, the MCP door's second and larger effort — the
one at whose end a Claude Code session genuinely connects to her library
under a grant she set. Every design question is ALREADY RULED: the binding
record is `notes/plans/phase-13n-sitting-record-2026-10-09.md` (R-13n-1…11)
with the approved mockups `notes/plans/13n-sitting-mockups/mcp-door-mockups.html`
and the standing canon they carry forward (`notes/plans/phase-13n-mcp-door-note.md`
*[removed for publication]*
guardrails). 13n-a (Level 0) is CLOSED and merged — the format and import
ops it built (`Domain/VariorumDocument`, `importDocument`/`importBook`,
`Queries.variorumDocumentText`) are this phase's substrate: `read_note`
speaks the format, `import_document` takes it as payload.

Preflight per CLAUDE.md in full. NO `Sync/` and no custody code is expected
in this diff (grants are a LOCAL-ONLY table; the server sits inside the
unlocked app) — but the GRANT BOUNDARY is security surface, so the cold
reviewer is **fable-reviewer** for U1 at minimum (the orchestrator may use
opus-reviewer for pure-chrome units). Mint the effort's ticket at kickoff
("13n-b — the MCP door", child of VX-25), branch/worktree per the standing
rules, declare surfaces against the in-flight table. `/architect-phase`
shape; THREE acceptance units, one implementer session each, laddered as
ever.

## What this phase builds (the ruled design, restated for building)

**The transport (R-13n-3):** a `variorum-mcp` helper binary in the app
bundle; MCP clients launch it over STDIO; it forwards JSON-RPC to the
running app over a UNIX SOCKET in the app's container (no TCP, no network
service; the socket dies with the app; "Variorum must be open" is the
honest refusal when it isn't). The app is the ONE process touching the
store. Setup is app-initiated: Settings ▸ MCP's "Set up Claude Code" writes
the client config itself (`claude mcp add variorum -- <bundle path>`); a
copyable command is the fallback; Claude Desktop registers the same binary
in its config file. The dependency is RULED IN (R-13n-2): the official MCP
Swift SDK, pinned exact version, license notices in acknowledgements.

**The grant grammar (R-13n-4) — the product:** four cumulative rungs —
**read** (read + search in scope) · **suggest** (new takes at the fan's
end, labeled, never chosen, never locked; comments; save-a-lens — PROVABLY
cannot modify an existing take, test-pinned) · **write new** (+ create
notes, apply tags, build books; `import_document` as the bulk door) ·
**edit** (+ `edit_take` under insurance, structural ops, tombstone-only
delete). Scopes: this note · a book · this wing. Durations: once · while
connected · always. The ONE open-book switch; journals NEVER in a standing
grant and never offered "always" (§9). Grants live in a LOCAL-ONLY table
(never synced — zero lockstep, marker untouched) with faces in Settings ▸
MCP, the book settings sheet, the note ⋯ menu, and a "shared with AI" chip
on granted rows (P-13n-3's wording, hers to re-voice).

**The pane (R-13n-5 + R-13n-10):** Settings ▸ MCP speaks DIRECT AND
TECHNICAL (her register ruling — "it's only for technical people anyway");
a pending client is a "Connection request — Approve… / Deny", never the
Arrivals door idiom; the app-wide faces an AI act produces (receipts,
chips, commit names, take labels) keep the app's voice (P-13n-1). The
clients / shared-with / activity lists MUST stay legible at length — each
section caps its rows with an "all N ›" road (her clutter constraint).
Mockup sections 1–4 are the approved reference, as amended by the rulings.

**The paper trail (R-13n-6/7):** every MCP write is an ordinary operation
registering structural undo per act; multi-block tools register ONE
compound entry. `edit_take` takes `expectedText` (stale reads refuse as
`bufferChangedSinceGesture`) and is bracketed by named commits carrying THE
CLIENT'S NAME ("before claude code's edit" / "after …") — the EIGHTH quiet
auto-commit occasion, insurance-class, never governed by
`savepoint_cadence`. AI takes are labeled with the client (P-13n-3).

**The tool vocabulary (mockup §9, the lean set):** read — `list_books`,
`list_notes`, `read_note` (the Level 0 format), `search` (the 13o engine,
scope-filtered), `export_note`. suggest — `add_take`, `add_comment`,
`save_lens`. write new — `create_note`, `import_document`, `apply_tag`,
`create_book`, `add_note_to_book`. edit — `edit_take`, `divide_block`,
`merge_blocks`, `move_block`, `delete_block`. Tools are thin projections of
the operations layer (P-1's registry thinking applied to the wire); every
refusal speaks to the client exactly as it speaks to her; scope checks run
per call. Nothing can choose a take, hard-delete, or touch keys.

## The units

- **U1 — the spine (fable-reviewer):** the SDK dependency; the socket
  server inside the app; the `variorum-mcp` stdio shim; the grants table +
  the pure grant-check Domain rule; the READ rung end to end (Claude Code
  connects, lists, reads, searches under a grant); the Settings ▸ MCP pane's
  resting shape (toggle, connection requests, clients list, Set up Claude
  Code). Acceptance: a REAL Claude Code session on the dev store reads a
  granted book and is refused past it (the refusal pinned); the verification
  bar's read half (reads never exceed the grant, pinned per tool).
- **U2 — suggest + write new:** the grant sheet (where · how much · how
  long) and the just-in-time ask; `add_take`/`add_comment`/`save_lens` +
  the suggest-rung PROOF (test-pinned: cannot modify an existing take);
  `create_note`/`import_document`/`apply_tag`/`create_book`/
  `add_note_to_book`; receipts + the shared chip; undo per act. Acceptance:
  her fact-check shape live — an agent reads a note, lands takes beside
  every block, saves a lens; one ⌥⌘Z walk.
- **U3 — edit + polish:** `edit_take` with insurance commits + expectedText;
  the structural tools; the open-book switch; journals' per-ask fence; the
  activity list; the list-scalability shapes (R-13n-10); the walk (both
  voices) + her Percy-grade live round over the connection. Acceptance: the
  whole W-series equivalent for the door + the verification bar complete.

## Standing constraints

Zero `Sync/`; zero schema SYNC impact (the grants table is local-only —
registered like the 13o derived family, subtracted from the completeness
walk, kept out of exports); Claude Code is the must-work first client;
nothing may assume the client is external (the future chat is another
client, R-13n-1); the capability registry declares any new user-facing
doors; P1 binds the server (tool cost ∝ the request's scope, never the
corpus). MOBILE: nothing mobile-visible expected (the server is Mac-hosted;
synced rows arrive on the phone as ordinary rows) — say the line at
closeout.

## Open taste items riding into this phase (from QUESTIONS #207/#208)

P-13n-1 (the register boundary), P-13n-3 (chip + label wording), WA-7
(should Welcome refuse context mints generally — surfaced by 13n-a's drop),
and the Index receipt-footer option set (WA-1's record). None gates U1.
