# VX-156 design-prep kickoff — the MCP grant UX round (overnight, design only)

**Born 2026-10-11 at the author's Air MCP round (her first real-store door session). This
file is the kickoff message: a fresh overnight session reads it and runs. The sitting
itself is hers, in the morning — this session only PREPARES it.**

## Mandate

Design-prep for the grant UX round. NO app code, NO canon edits, NO suites, NO walks
(this may run on the Air — suites/walks are explicit-say-so only there, and nothing
here needs them). Work on branch `vx-156-grant-ux-design`; open a PR titled
"VX-156: grant UX design prep" at the end; the merge waits for the sitting.

## Preflight (read, never delegate)

- CLAUDE.md + its auto-loaded canon (automatic).
- `notes/plans/phase-13n-b-mcp-door.md` — the pane and grant-sheet rulings (R-13nb-*,
  the "mockup §N" references; locate the 13n-b mockup artifact they cite and build on
  its idiom). The pane speaks DIRECT AND TECHNICAL (R-13n-5); app-wide faces keep the
  app's voice (P-13n-1).
- `notes/plans/librarywalkpolish-ui-reference.html` — the committed-HTML-reference
  precedent this round's mockups follow.
- `notes/TICKETS.md` (bout-start snapshot rules apply), `notes/QUESTIONS.md`,
  `notes/SessionResiliencyProtocol.md`.
- `App/Variorum/Variorum/EditorCommands.swift` — the authoritative swept shortcut
  table (chord candidates must be verified free against it, with the sweep evidence
  quoted in the brief).
- `App/Variorum/Variorum/Features/MCP/MCPPane.swift` + `MCPGrantSheet.swift` — the
  current faces being redesigned.

## Tickets in scope

- **VX-156** — grant UX round: searchable pickers (the grant sheet's flat book
  dropdown AND every book picker on the grant road); grant-from-Library (select
  notes/books in place → grant); a keyboard shortcut to share the note you're
  currently in with MCP, at the last-used rung; a quiet pending-ask badge on the
  thing an ask targets (etiquette-compatible: passive, never raises, never queues
  UI — R-13nb-23/26g binds); an MCP pane keyboard shortcut; duplicate-name
  disambiguation in pickers (two identical "the adventures of sherlock holmes"
  rows are indistinguishable today — her screenshot on record).
- **VX-157** — keyboard wing switching (cycle chord and/or direct access; candidates
  from the free rows of the EditorCommands sweep).
- **VX-158** — MCP wing switch on the wire (face implications only here; the wire
  shape is its own ticket's build).

## Deliverables by morning

1. **`notes/plans/vx-156-grant-ux-mockups.html`** — ONE self-contained local HTML
   reference (never an Artifact; the absolute path printed in the PR body), Study
   voice, light AND dark, sentence case throughout (no shouty caps), covering every
   VX-156 item above as drawn states, plus the wing-switcher face with its chord.
2. **`notes/plans/vx-156-grant-ux-brief.md`** — per item: 2–3 options, a
   recommendation, and the why; chord candidates with sweep evidence; open
   questions. Repo-first, committed per piece with a LIVE STATUS block.
3. **The sitting agenda at the top of the brief**, carrying (verbatim, hers):
   - (a) The journal-trait Always question: "for the default command J journal I
     think it's a fair choice but I am questioning it being applied to all journal
     style books (especially since it can be turned on and off for any book)."
     Present both readings of the fence (the trait is a soft fence since
     `setJournalTrait` is one toggle; the 'daily' book's never-always stands
     regardless; the Private mark is the hard fence either way).
   - (b) VX-160's crossing-door shape — per-item NOTE move across wings via MCP
     (rung, scope semantics when source and destination wings differ, the per-item
     doors' tag adoption by path). Her use case: the variorum-wing sweep.
   - (c) VX-159's addressing problem — per-pairing merge and choose-per-take divide
     on the wire (the `second_half_starts_with` text-addressing precedent).
   - (d) A-4 hardening option: a per-client secret minted at approval and embedded
     in the Copy-setup-command config, so the server can map secret → identity.
     Present honestly: it defeats client mislabeling/confusion, NOT same-user
     malware (the config file is same-user-readable); the pane's boundary line
     stays true either way.

## Rules that bind

- SessionResiliencyProtocol: commit per piece, LIVE STATUS from the first commit,
  push the branch after each, synchronous waits only.
- Author-only calls stay hers: no product behavior invented — where an item needs a
  ruling, the brief presents options and the agenda carries the question.
- One Sonnet subagent max, external facts only, read-only.
- Hard stop after the PR opens. The sitting is hers.
