# Phase 13n — the MCP door: SITTING PREP (2026-10-09)

**Status: sitting prep — Fable's proposed direction for the promoted 13n design
sitting, awaiting her rulings.** Ticket VX-116 · branch `vx-116-13n-sitting`.
The standing canon this builds on, read in full for this prep:
`notes/plans/phase-13n-mcp-door-note.md` (her dream vision + use cases,
verbatim; the chat question; the candidate shape) and
*[removed for publication]*
door, insure-first writes, consent-scoped reads, journals gated, local LLMs
first-class, the open-book switch, the honest boundary). The mockups:
`notes/plans/13n-sitting-mockups/mcp-door-mockups.html`.

## What this session changed (her words, 2026-10-09)

1. **13n moves PRE-LAUNCH.** Her ruling: "Let's do Level 0 & level 2 now,
   before launch" — "the app almost shouldn't even ship without it; offering
   another way to work with LLMs is why the vast majority of technical users
   would want my app." The master-plan row (currently post-🚀 at running-order
   row 10) re-sequences at this effort's merge.
2. **Level 0 joins the scope**: a round-trippable Variorum document format +
   an import door, as the bulk road under the MCP's interactive road. (The
   13h boundary stands — 13h remains the folder/markdown bridge; this format
   is the fan-aware native grammar. Shared plumbing noted, separate designs.)
3. **Level 3 (in-app chat) stays deferred** — matching the recorded candidate
   shape: a future chat is ANOTHER CLIENT of the same server and grant
   grammar; nothing in 13n may assume the client is external.
4. **The dependency is conditionally approved**: "I'm open to a new dependency
   and the MCP swift SDK, is that license fine for commercial use? if so I
   think it's fine to use it." License verified below — the condition is met.
5. **MCP writes register structural undo** — her words: "one of the coolest
   features I can imagine — undoing AI writing in to your markdown in a
   single command is something people genuinely want and don't have."

## External facts (verified 2026-10-09, Sonnet web pass)

- **modelcontextprotocol/swift-sdk license: MIT → Apache 2.0 transition**
  (existing code MIT, new contributions Apache 2.0; the LICENSE file carries
  both). Both permissive — **fine for a closed-source commercial app**; ship
  the license notices (and any NOTICE file) in the app's acknowledgements.
- SDK state: 0.12.x, roughly monthly releases, Swift 6+/macOS 13+ (our 26
  target is fine). Still 0.x — pin the version, expect churn. Server-side it
  supports tools/resources/prompts, **stdio and streamable-HTTP server
  transports** (the HTTP ones are bring-your-own-listener).
- **Claude Code** connects over stdio (`claude mcp add <name> -- <command>`)
  and streamable HTTP incl. localhost with headers. **Claude Desktop**:
  custom connectors cannot reach localhost (they originate from Anthropic's
  servers); local servers go through `claude_desktop_config.json` as stdio
  commands — which the stdio shim serves directly.
- **MCP is an open protocol, client-agnostic** — the same server serves any
  MCP client unchanged: Claude Code/Desktop, OpenAI's Codex CLI, Cursor,
  VS Code/Copilot, Gemini CLI, and local-model hosts with MCP support. Each
  client registers the server in its own config (command or URL); the
  protocol's `tools/list` handshake does discovery. §9's line holds: the
  grant gates the DOOR, not a specific model.

## The proposed direction (D-rulings wanted)

**D1 — transport & process: the stdio shim + unix socket (recommended).**
A tiny `variorum-mcp` helper in the app bundle; clients launch it over stdio;
it forwards JSON-RPC to the running app over a unix socket in the app's
container. No TCP port, no network service (§9's lean, literally); serves
Claude Code AND Claude Desktop AND every other stdio-speaking client; the
socket's file permissions are the OS-level gate; dies with the app. The app
stays the ONE writer — observations fire, the UI updates live while an agent
works. "Variorum must be open" is the honest v1 limitation. Alternative
(not recommended now, cheap to add later): a localhost streamable-HTTP
listener for clients that only speak HTTP.
  - Setup is app-initiated per §9: a "Set up Claude Code" press writes the
    client config itself; a copyable command is the fallback (mockup §2).

**D2 — the grant grammar: four cumulative rungs × three scope axes ×
three durations (the sitting's heart).**
- Rungs: **read** (read + search in scope) · **suggest** (new takes at the
  fan's end, comments, save a lens — provably cannot touch an existing take)
  · **write new** (+ create notes, apply tags, build books — the tutor loop)
  · **edit** (+ edit takes under insurance, structural ops, tombstone-only
  delete). Names are hers to re-word; the sentences in mockup §3 are the
  contract.
- Scopes: this note (her floor, verbatim) · a book · this wing. Journals
  excluded from every standing grant — per-ask only (§9).
- Durations: once · while connected · always. Plus the ONE deliberate
  **open-book switch** (§9's spectrum answer); journals gated even under it.
- Grants live in a **local-only table** (never synced, no §12 lockstep,
  marker untouched) with faces in Settings ▸ AI, the book settings sheet,
  the note ⋯ menu, and a chip on shared rows.
- The granting moments: a new client WAITS AT THE DOOR (the Arrivals idiom,
  no popup) → the grant sheet; past-grant asks arrive as the TCC-style
  just-in-time sheet (once · while connected · always; journals never offer
  always).
- **The PUSH gesture (her 2026-10-09 rider: "be sent some document / info as
  context for a question")** — §9's second gesture, share-from-the-app, made
  concrete two ways: **Copy for AI** in the note ⋯ menu (the Level 0 format
  to the clipboard — works with ANY chat anywhere, zero connection), and the
  connected form (the act grants that one note read-once, so "ask about this
  note" is one gesture, not a Settings trip).
- **Her homework loop (2026-10-09, verbatim-faithful: "add 10 questions, let
  me answer, fill in the grade / corrections when I'm done")** decomposes
  with ZERO new mechanism: write-new mints the note (ten question blocks);
  her answers are ordinary takes she writes; the grades land per-block as
  suggest-rung takes; a saved lens reads questions · answers · grades as
  columns. Turn-taking stays a workflow, never a mechanism (the 13n note's
  restraint lean) — "I'm done, grade it" is said to the client, not modeled
  in the app.

**D3 — undo: per-act entries + compound bulk doors (recommended).** Every
MCP write registers structural undo/redo exactly as her gestures do (they
ARE ordinary operations); `import_document` and any multi-block tool
registers ONE compound entry. Open option: time-window coalescing of an
agent's consecutive acts into a session entry — defer unless she wants it
now; the dream ("undo AI writing in a single command") is served by the
compound bulk doors plus per-act stepping.

**D4 — Level 0: the import format IS the export format.** The shipped fan
export ("Alternates" sections + chosen text in place) becomes the import
grammar, extended by the capture microsyntax (`{t:"…"}`, `{#tag}`).
Paragraph = block on entry (the standing bulk rule); labeled takes join the
fan, never chosen; one import = one note = one undo entry; a folder of
files = a book. The export pin stands: exports never write a row; import is
its own door minting fresh rows through operations — a file is bulk entry,
never reconciled truth. Open detail: an explicit fence for multi-paragraph
blocks (proposal: only inside Alternates sections v1, where text runs free;
surface blocks stay paragraph-per-block on import).

**D5 — insurance: the before/after named commits.** `edit_take` runs commit
("before claude's edit") → write → commit ("after claude's edit") — her
2026-08-25 idea, now nearly free on 13u3's named commits; plus
`expectedText` preconditions (stale agent reads refuse as
`bufferChangedSinceGesture`). This is the eighth quiet auto-commit occasion,
insurance-class (always on, never governed by `savepoint_cadence`).

**D6 — the dependency.** Adopt modelcontextprotocol/swift-sdk, pinned exact
version, license notices shipped. Her condition is met (facts above);
recorded as approved unless she says otherwise.

**D7 — verification bar (from the row, restated as the phase's gate):** a
suggest-rung grant PROVABLY cannot touch existing takes — test-pinned like
any refusal; reads never exceed the grant (scope checks pinned per tool);
every AI write is reviewable, undoable, synced like her own. Convergence
untouched: MCP writes are ordinary ops feeding the ordinary outbox.

**D8 — shape & sequence.** Two efforts: **13n-a — Level 0** (one acceptance
unit: format spec + import door + round-trip tests) and **13n-b — the door**
(two to three units: U1 shim + socket + server + read rung + the grants
table and faces; U2 suggest/write-new rungs + the sheet + receipts; U3 edit
rung + insurance + undo + the lens face + polish). Each unit laddered as
ever; `/architect-phase` after the rulings. Pre-launch placement beside
13s-a is hers to slot. Zero schema sync impact throughout (the grants table
is local-only); Claude Code is the must-work first client (canon).

## The ruling checklist (what the sitting needs from her)

1. D1 transport — shim + socket? (and app-initiated setup)
2. D2 rung names + count; scope axes; durations; open-book switch wording;
   the at-the-door approval flow.
3. D3 undo granularity (per-act + compound bulk, or also session coalescing).
4. D4 the format details (fence question; folder-import = book?).
5. D5 the insurance commit names' exact wording.
6. D6 dependency — confirm adoption as conditioned.
7. D8 the two-effort split and its pre-launch slot.
8. Pane name ("AI"?), the client noun ("client"?), the chip's word
   ("shared with AI"?), the take label convention ("claude · suggested"?).
