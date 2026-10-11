# 13n-c kickoff prompt — MCP launch readiness (the Pro, overnight, Opus orchestrating)

**From the author, verbatim (read first — this is what she wants gone over):**

> Hellooooo Opus! Exciting day today, we're going to be building the follow up on
> the mcp connection that was already built, so that I can fully see and explore
> the use of the mcp and where we're at with it tomorrow morning. Focus on making
> the UI and UX of the mcp grant experience CLEAR - keep in mind a user might have
> hundreds of books and notes. perhaps a sort by shelf would also be helpful,
> ability to see favorites, etc. it needs to be and feel nice or no one will want
> to use it at all. make sure the keyboard shortcuts pane is updated and perhaps
> the field guide can grow an MCP chapter, or we can make an MCP explanation book
> that shows up in your library when you first connect an MCP server. either way,
> notes / documentation for the user need to be made clear (especially since
> that's what a user's AI might need as advice too). It's also important that you
> note down your adjuncation decisions for a Fable review that will follow this
> phse's completion, as well as having parts of the code that would deserve a
> fable review noted clearly. I still have 4% of my weekly usage, so run fable
> reviews on what you need to until you can't anymore. you'll be running this
> overnight. also, I want you to finish if phases are complete and everything is
> passing, has been walked and specifically had an opus UX reviewer walk it to
> flag problematic flows, hard to find buttons, weird spacing or looks, etc., then
> you can refresh my application install.

## Your role

You are the 13n-c ORCHESTRATOR, running on the Pro, overnight, under her mandate
above. She has redirected the standing cast at this kickoff: **Opus orchestrates
this phase** (her Opus-week protocol — her Fable budget is nearly out). Everything
else in CLAUDE.md's Phase execution rules binds unchanged.

## Bout start (before anything)

The full CLAUDE.md ritual: `git pull` here AND in the shared memory repo, then
`Tools/vx sync` on main with the snapshot commit+push. Then the complete preflight
— CLAUDE.md's list, plus these phase-specific reads (reading is never delegated):

1. **`notes/plans/vx-156-grant-ux-design-kickoff.md` — THE SITTING RECORD.** Its
   RATIFIED + ROUND 2/3/4/5 sections carry every ruling this phase builds to
   (R-AIR-1…15 and the round-5 items). They are her word, already pushed.
2. `notes/plans/vx-156-grant-ux-brief.md` + `vx-156-grant-ux-mockups.html` — the
   approved design (she approved the mockups at the sitting; specific overrides
   live in the sitting record and win over the mockups where they differ).
3. `notes/plans/phase-13n-c-mcp-launch-readiness-DRAFT.md` — the draft plan.
4. `notes/plans/phase-13n-b-mcp-door.md` — the door you are extending.
5. `notes/handoffs/phase-13n-b-handoff.md`, `notes/TICKETS.md`, `notes/QUESTIONS.md`,
   `notes/SessionResiliencyProtocol.md`.

## First acts

1. FINALIZE the plan as `notes/plans/phase-13n-c-mcp-launch-readiness.md`: fold in
   every sitting ruling, her prepended text's additions (sort-by-shelf and
   favorites/starred in the grant pickers; the keyboard shortcuts pane update; the
   user-docs choice — field-guide MCP chapter vs a first-connect MCP explanation
   book: pick the most spec-defensible, mark PROVISIONAL, log in QUESTIONS), and
   the round-5 items (the Library-pane wing switcher; snippets kept out of the
   door at launch AND said clearly in the docs — her override possible in the
   morning). Size in acceptance units per `notes/PhaseSizingGuidance.md`; if the
   scope exceeds the sizing guidance, SAY SO in the plan and sequence so the
   launch-critical units land first — never split or trim silently.
2. Open the effort's branch (`vx-NNN` run-ticket convention — mint the run ticket
   in Linear if the board road is available from the Pro; otherwise record the
   intended title in the plan and proceed) and declare the in-flight row.

## Scope (from the sitting — the record file is authoritative over this summary)

VX-156 (the grant UX round, incl. searchable pickers with last-edited +
recently-edited section, duplicate-name disambiguation, grant-from-Library,
⌥⌘A with the adjust door, the ask badge + Waiting list REPLACING the
self-popping ask sheet, ⌥⌘, pane shortcut) · VX-157 (⌘L wing switching,
R-AIR-15: type filters, ⌘-held-L cycles, masthead click cycles, present on the
LIBRARY masthead too) · VX-158 (wing target on show_in_app) · VX-159 (ceremony
presets on the wire, R-AIR-10 provisional) · VX-160 (per-item cross-wing note
move, R-AIR-9: R1 recommended, R1/R2 both legal) · VX-163 (the journal-trait
fence re-key — FIRST UNIT, see below) · VX-164 (the in-note shared/private/
pending-ask indicator, R-AIR-6/7's one icon) · gatherings ride wing grants
(R-AIR-12) · the per-client setup menu (R-AIR-13: Claude Code · Codex · generic
path/JSON) · the per-setup secret (R-AIR-14 — LAST, may fall out, launch never
blocks on it) · the A-4 pane sentence (brief §12) · the grant-confirm wording
(R-AIR-3, on every book grant) · no-"AI"-in-settings wording + faces rendered
only with an approved client + zero-states route to Settings ▸ MCP (R-AIR-8).
EXCLUDED: VX-161; the wings/library renaming (13s-a's).

## Ordering and the Opus-week protocol

- **The fence-classifier unit (VX-163) lands FIRST** — it re-keys journal-class
  from the trait to the 'daily' book + Private mark across every fold-classifier
  site; extend the byte-identity pins (fenced = unshared = nonexistent on every
  road); fix the shipped sentences that become false. This is the riskiest unit.
- **FABLE-OWED ledger inside the plan file:** every adjudication decision and
  every diff that would ordinarily earn a Fable review (fence semantics, the
  secret's accept path, refusal uniformity) gets a row — commit SHA, diff scope,
  why owed — written AT THE MOMENT. A post-phase Fable session walks it.
- She has ~4% Fable left: spend it on `fable-reviewer` cold reviews of the
  HIGHEST-RISK diffs first (the fence unit's ladder round 1 above all), until it
  runs out; then `opus-reviewer` with owed-rows. Note in each ladder record which
  model actually reviewed (verify the label — labels have lied).
- Standard ladders otherwise; one implementer at a time, fresh per unit;
  pin-before-fix; dispositions repo-first.

## Closing (her conditional authorization, from her text above)

If and only if: the units are complete, the suites pass, the phase has been
WALKED, and an **Opus UX-reviewer walk** has run specifically to flag problematic
flows, hard-to-find buttons, weird spacing or looks (treat its findings as a
ladder round — fix or disposition before proceeding) — then run the
`/Applications` refresh per the A1 ritual at a zero-instance window (NEVER quit
or kill a running real-store instance; if an instance is live, hold the refresh
and say so in the handoff instead). Then the full closeout ritual: plan results,
master plan + in-flight row + closeout paragraph, canon deltas exactly as ruled
(AppSpec §12's journal-class line per R-AIR-1, the duration line per VX-162, the
new contract lines), MOBILE PARITY line, tickets closed or re-owned, the next
plan untouched (13s-a stands), the author handoff
`notes/handoffs/phase-13n-c-handoff.md` with her checklist at top — including
the FABLE-OWED ledger pointer and the morning items (snippets call, any
PROVISIONALs). PR merge-commit to main, push, hard stop.

SessionResiliencyProtocol binds throughout: commit per piece, LIVE STATUS from
the first commit, push after each, synchronous waits only.
