# VX-156 design-prep kickoff — the MCP grant UX round (overnight, design only)

**Born 2026-10-11 at the author's Air MCP round (her first real-store door session). This
file is the kickoff message: a fresh overnight session reads it and runs. The sitting
itself is hers, in the morning — this session only PREPARES it.**

## RATIFIED at the Air round (2026-10-11, her word in session — canon lands at the build's merge)

- **R-AIR-1 — Journal-trait books may hold standing grants.** Her ruling, superseding
  the blanket half of R-13n-4's "journals NEVER in a standing grant and never offered
  always": the never-always fence keys on (a) the **'daily'-marker Journal book** —
  constitutive, untouched, never offered Always, its entries per-ask only — and
  (b) **anything wearing the Private mark** (the hard fence, untouched). A journal-
  TRAIT book (`setJournalTrait`'s toggleable profile) may take standing grants like
  any book, optionally behind one extra-worded confirm (wording is this round's to
  design). Her reasoning on record: "for the default command J journal I think it's
  a fair choice but I am questioning it being applied to all journal style books
  (especially since it can be turned on and off for any book)." The exact classifier
  seam is the build's to trace (the U2 fold-classifier site); the ruled OUTCOME is
  as stated. Ticket: VX-163.
- **R-AIR-2 — The per-item cross-wing NOTE move ships on the wire** (VX-160): her
  "I want per item move to be allowed via mcp" stands ratified, and it belongs to
  the NEXT build group. Shape questions (rung, dual-wing scope semantics, tag
  adoption) stay on the sitting agenda below.
- **Context for the plan draft:** the next phase is about making the MCP door ready
  for REAL USERS at launch, which she hopes to do THIS WEEK. Master-plan sequencing
  against 13s-a is hers at the sitting.

## ROUND 2 — her rulings at the Air sitting, 2026-10-11, over PR #147's mockups
(This section IS the sitting record the 13n-c plan builds from; canon lands at the merge.)

- **R-AIR-3 — the grant confirm's wording:** between the brief's W0 and W1 — her
  sentence: *"Grant read in “dream journal” always, including to future entries."*
  The including-future-entries clause shows on EVERY book grant (membership is
  live — notes added later become visible), not only journal-trait books.
- **R-AIR-4 — ⌥⌘A's confirmation carries a door:** the receipt lets you open a
  panel pre-filled on what was just shared, to change its details fast.
- **R-AIR-5 — the wing switcher:** type to filter; click-without-typing CYCLES;
  fast to click ("fast navigation is important"); the chord must be easier to
  type than ⌃⌘W — re-pick from the free rows of the sweep.
- **R-AIR-6 — one consistent AI-shared ICON, not text:** the Bookcase's "shared
  with AI" tag is too wordy and conflicts with tags; one icon everywhere, hover
  names it, click shows the permission; icon language matches the sidebar set
  (Bookcase/Library/Pool/Snippets); a pending-ask icon in the same family.
- **R-AIR-7 — the in-note indicator (VX-164):** with MCP on, a note's upper right
  shows at a glance what an AI can reach — shared icon (click → the permission
  AND the WHY when reach comes from a wider grant: "readable through the Home
  wing grant"), lock when Private (click to change), pending-ask. "Never
  surprised, from within a note."
- **R-AIR-8 — no "AI" in settings-class wording:** lean "grant MCP permissions"-
  class copy (final words hers at the copy pass); every share/grant face renders
  ONLY when at least one approved client exists (extends 13n-b's Allow-AI-here
  unrendered-when-none, P-2); any zero-state face routes to Settings ▸ MCP —
  never a dead button.
- **R-AIR-9 — VX-160 rungs:** R1 (edit at the source + write-new at the
  destination wing) recommended AND both R1/R2 legal as options depending on
  what is selected/granted.
- **R-AIR-10 — VX-159 presets:** the brief §10 shape accepted PROVISIONAL on her
  "I think it's fine" — presets on the existing tools, id + text addressing.
- **R-AIR-11 — 13n-c scope:** everything discussed tonight builds EXCEPT what she
  explicitly excluded: VX-161 stays filed-not-built. (A-4's per-setup secret:
  decision pending her read of the orchestrator's recommendation.)
- **Also into VX-156's scope:** last-edited joins the picker context line's
  fixed order, and a "recently edited" quick section in grant pickers ("that's
  often what I want"); "while connected"'s wording gets copy OPTIONS at the
  build (she finds it vague but has no replacement yet).
- **Open design question for her:** gatherings at the door. Today a gathering is
  not a grant target and is not listed (code: MCPGrantQueries "a gathering is
  not a grant target"). Options at the sitting's close: keep them off (grant
  the wing instead) · list a wing's gatherings as read facts under a wing grant
  (recommended — reach never exceeds the wing) · make them grantable targets
  (moving reach — the P-13nb-U4-16 class problem).

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
   - (a) ~~The journal-trait Always question~~ **RATIFIED as R-AIR-1 above** — the
     agenda item becomes: the extra-worded confirm's wording (if any) for granting
     Always on a journal-trait book, presented as drawn options.
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

4. **`notes/plans/phase-13n-c-mcp-launch-readiness-DRAFT.md`** — a DRAFT phase plan
   (marked DRAFT PENDING THE SITTING; the phase name is hers to keep or change) for
   the MCP launch-readiness round: the VX-156 round's build, VX-157, VX-158,
   VX-160 (R-AIR-2), VX-163 (R-AIR-1), with VX-159, VX-161 and the A-4 per-client
   token listed as CANDIDATES pending her morning nod. Sized in acceptance units
   per `notes/PhaseSizingGuidance.md`; honest about what fits a this-week launch
   and what should fall out; sequencing against 13s-a flagged as hers.

## Rules that bind

- SessionResiliencyProtocol: commit per piece, LIVE STATUS from the first commit,
  push the branch after each, synchronous waits only.
- Author-only calls stay hers: no product behavior invented — where an item needs a
  ruling, the brief presents options and the agenda carries the question.
- One Sonnet subagent max, external facts only, read-only.
- Hard stop after the PR opens. The sitting is hers.
