# Phase 13n — the MCP door: SITTING RECORD (2026-10-09)

**Status: BINDING — the 13n promoted design sitting's rulings.** Ticket
VX-116 · branch `vx-116-13n-sitting`. Supersedes nothing; builds on
`notes/plans/phase-13n-mcp-door-note.md` (her dream vision, verbatim) and
*[removed for publication]*
carried). The prep that framed the questions:
`notes/plans/phase-13n-sitting-prep-2026-10-09.md`. The approved mockups
(updated to these rulings): `notes/plans/13n-sitting-mockups/mcp-door-mockups.html`.
The sitting ran in-conversation 2026-10-09; options were put through the
question tool at her ask; her verbatim words quoted where load-bearing.

## The rulings

- **R-13n-1 — 13n moves PRE-LAUNCH; Levels 0 and 2 ship in v1; Level 3
  stays deferred.** Her words: *"Let's do Level 0 & level 2 now, before
  launch. Level 3 is nice for someday but it would be relatively very
  minimal UI and work to get to Level 2."* The chat remains a possible
  later phase built as ANOTHER CLIENT of the same server and grant grammar
  (the 13n note's candidate shape, unchanged); nothing in 13n may assume
  the client is external. The master-plan resequencing (13n from
  running-order row 10 to pre-launch) lands at this branch's merge.

- **R-13n-2 — the dependency is APPROVED.** modelcontextprotocol/swift-sdk,
  her condition ("is that license fine for commercial use? if so I think
  it's fine to use it") met: MIT transitioning to Apache 2.0, both
  permissive, commercial-fine; license notices (and any NOTICE file) ship
  in acknowledgements; version pinned exactly (0.x churn expected). The
  app's second third-party dependency after GRDB.

- **R-13n-3 — transport: the stdio shim + unix socket.** A `variorum-mcp`
  helper in the app bundle; clients launch it over stdio; it forwards
  JSON-RPC to the running app over a unix socket in the app's container.
  No TCP port, no network service (§9's lean, literal). The app stays the
  ONE process touching the store; the socket dies with the app; "Variorum
  must be open" is the honest limitation. Setup is app-initiated (§9): a
  "Set up Claude Code" press writes the client's own config; a copyable
  command is the fallback. Serves every stdio-speaking MCP client (Claude
  Code, Claude Desktop via its config file, Codex CLI, Cursor, local
  hosts) — MCP is an open protocol and the server is client-agnostic: the
  grant gates the DOOR, never a specific model (§9's honest boundary).
  A localhost-HTTP listener is deliberately NOT built in v1 (addable
  later without redesign).

- **R-13n-4 — the grant grammar: four cumulative rungs — read · suggest ·
  write new · edit.** read = read + search within scope. suggest = new
  takes at the fan's end (labeled, never chosen, never locked), comments,
  save-a-lens — PROVABLY cannot modify an existing take, test-pinned like
  any refusal. write new = + create notes, apply tags, build books. edit =
  + edit takes under insurance (R-13n-7), structural ops, tombstone-only
  delete. Scopes: this note · a book · this wing. Durations: once · while
  connected · always. The ONE deliberate open-book switch (§9's spectrum);
  journals excluded from every standing grant and from open-book — per-ask
  only, and the ask never offers "always" (§9 carried). Grants live in a
  LOCAL-ONLY table (never synced — no §12 lockstep, marker untouched) with
  faces in Settings ▸ MCP, the book settings sheet, the note ⋯ menu, and a
  chip on shared rows. A new client's connection request is approved in
  the pane (no popup); past-grant asks arrive as the just-in-time sheet.

- **R-13n-5 — the MCP room speaks DIRECT AND TECHNICAL; the pane is named
  "MCP".** Her words: *"I think 'is at the door' is too flowery - let's
  keep this section of settings more direct and technical than the rest of
  the app. it's only for technical people anyway."* The Arrivals door
  idiom is OUT of this pane — a pending client is a "connection request"
  with Approve…/Deny. Register boundary (Fable's interpretation,
  PROVISIONAL): the technical register governs INSIDE the MCP pane and the
  grant/ask sheets; the app-wide faces an AI act produces (receipts, the
  shared chip, commit names, take labels) keep the app's own voice.

- **R-13n-6 — undo: per-act entries + compound bulk doors.** Every MCP
  write registers structural undo/redo exactly as her gestures do (they
  ARE ordinary operations); `import_document` and any multi-block door
  registers ONE compound entry — an imported book undoes in one press.
  Session-window coalescing DEFERRED (a ticket, not 13n). Her motivation,
  verbatim: *"MCP writes registering structural undo is one of the coolest
  features I can imagine - undoing AI writing in to your markdown in a
  single command is something people genuinely want and don't have."*

- **R-13n-7 — insurance: the named bracketing commits carry THE CLIENT'S
  NAME.** `edit_take` runs commit("before claude code's edit") → write →
  commit("after claude code's edit") — whichever client, named; the
  history reads as a cast of writers. Plus `expectedText` preconditions
  (stale agent reads refuse as `bufferChangedSinceGesture`). This is the
  EIGHTH quiet auto-commit occasion, insurance-class: always on, never
  governed by `savepoint_cadence`.

- **R-13n-8 — Level 0: the import format IS the export format; full
  fidelity lives at 13m.** The text format stays prose + fan + tags: the
  shipped Alternates sections plus the capture microsyntax (`{t:"…"}`,
  `{#tag}`); paragraph = block on entry (the standing bulk rule); labeled
  takes join the fan, never chosen; the in-place text is the chosen take.
  A FOLDER imports as a book — subfolders = chapters, filename order =
  book order, folder names = names. One import = one compound undo entry.
  Commits and book settings deliberately do NOT ride the text file — on
  the connected road structure travels through TOOLS (create_book,
  sections, rules), and history is lived, not authored; the TRUE
  full-fidelity format is 13m's variorum edition bundle (canon since the
  export pin), shaped at 13m to share bones with this format. Her question
  that drew the line: *"how are book settings travelling? and commits? can
  we not get a true variorum format"* — answered with this two-form split,
  her pick. The export pin stands untouched: exports never write a row;
  import is its own door minting fresh rows through ordinary operations,
  never reconciling a file as truth.

- **R-13n-9 — sequence: 13n runs BEFORE 13s-a.** Her words: *"13s-a will
  run later entirely - we can get this done before finishing or even
  really starting 13s-a. now that I want them both pre launch, no reason
  to do the rewording first. in fact, good reason to do it after since
  this'll add to the field guide."* Shape: **13n-a** (Level 0 — one
  acceptance unit: the format + the import door + Copy for AI +
  round-trip tests) then **13n-b** (the door — U1 shim/socket/server +
  read rung + the grants table and pane; U2 suggest/write-new rungs + the
  grant sheet + receipts; U3 edit rung + insurance + undo + the lens
  face). Launch order now: 13n-a → 13n-b → 13s-a (re-voicing sweeps the
  new copy and the field guide's MCP chapter) → 🚀.

- **R-13n-10 — the MCP pane must stay legible at length.** Her words:
  *"some pages like this one … are going to need careful UI design to make
  sure that it doesn't end up messy and impossible to see if those lists
  are becoming long within the menu."* A design constraint on 13n-b: the
  clients / shared-with / activity lists get a shape that scales (per-list
  caps with an "all N ›" road, or sub-views) — never one growing pile.

- **R-13n-11 — the push gesture (from her rider: "be sent some document /
  info as context for a question").** Two forms: **Copy for AI** in the
  note ⋯ menu — the note in the Level 0 format onto the clipboard, works
  with any chat anywhere, zero connection (13n-a builds it; the export
  side already exists); and the connected form — sharing a note to a
  client grants that one note, read, once (13n-b). Her homework loop
  ("add 10 questions, let me answer, fill in the grade / corrections when
  I'm done") decomposes with zero new mechanism: write-new mints the
  question blocks, her answers are ordinary takes, grades land as
  suggest-rung takes, a saved lens reads the columns; turn-taking stays a
  workflow, never a mechanism (the 13n note's restraint lean, confirmed).

## Carried standing guardrails (not re-ruled, binding from §9 + the 13n note)

Ops-shaped door, never raw SQL; reads scoped and granted, never ambient;
every refusal speaks to the client exactly as to her; the verification bar —
a suggest grant provably cannot touch existing takes (pinned), reads never
exceed the grant (scope checks pinned per tool), every AI write reviewable,
undoable, synced like her own; Claude Code is the must-work first client;
conflict-as-variant's doctrine extends to the third writer.

## PROVISIONALs (logged to QUESTIONS at merge)

- P-13n-1 — the register boundary (technical inside the MCP room, app
  voice on app-wide faces) is Fable's interpretation of R-13n-5.
- P-13n-2 — a single FILE (not folder) imports as a bookless note (the
  Pool); the destination wing is the current one, tags adopt/mint by path
  in that wing (R-13ia-1's rule applied).
- P-13n-3 — the take-label convention on AI takes ("claude · suggested" +
  the client's own label) and the chip's word ("shared with AI").
- P-13n-4 — multi-paragraph SURFACE blocks are not expressible in the v1
  format (merge after, or author inside takes); revisit at 13m if wanted.

## Next

13n-a's execution plan: `notes/plans/phase-13n-a-document-format.md`
(kickoff message at its top). 13n-a mints its own ticket at kickoff;
13n-b's plan is written at 13n-a's closeout (just-in-time, one ahead).
