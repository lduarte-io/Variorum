# VM-44 audit — the brief every reader shares

You are one of several read-only AUDIT readers for VM-44, the planning effort for Variorum's iPhone app
("the Great Mobile Catch-up"). The author's verdict: the phone app is far behind the Mac — missing
features AND what exists is stale and rough. Your output feeds a design pass and a ticketing pass; it
must be accurate enough that a designer or planner never has to re-derive it.

## Ground
- Repo: `~/dev/variorum` (branch `main`). READ-ONLY: no edits, no commits, no builds that need the
  stage (`xcodebuild test`, simulators, launching apps are all forbidden; headless `swift build` is
  legal but you should not need it). No web access.
- Phone app: `App/Variorum/VariorumMobile/` (Features/Shell, Write, Read, Takes, Protection, Tutorial,
  Perf; Theme). Shared brains: `App/Variorum/Shared/`. Mac app: `App/Variorum/Variorum/` (Features/,
  Core/Views). Core package: `Sources/VariorumCore/` (Operations, Queries, Domain, Sync, Protection).
- Contracts: `CLAUDE.md` + `notes/AppSpec.md` (§9 operations, §12 UI stance) are loaded for you.
  `notes/SurfaceContracts.md` is the full contract of every Mac surface — read the sections for YOUR
  surfaces in full. `notes/MobileSoul.md` is the phone's doctrine (§1–5: read in full; it names the
  ruled exclusions and the rule "brains live in Core/Shared, platforms own only faces") and its §6 is
  the parity ledger (rows are very long — grep for your surfaces rather than reading whole).
  `notes/plans/mobile-app-plan.md` is 6k lines of history — grep it, never read it whole.
  `notes/TICKETS.md` lists open tickets (VM-* are mobile).
- Her words for this effort (verbatim): `notes/plans/vm-44/her-words.md`. Read it first.

## What to produce
Write ONE markdown file at the path your brief names, under `notes/plans/vm-44/audit/`.
Unless your brief gives a different shape, it has:
1. **Gap matrix** — one row per capability/surface/behavior in your area:
   `Capability | Mac (contract pointer: SurfaceContracts section / AppSpec op / file) | Phone status
   (PRESENT · PARTIAL · STALE · ABSENT · RULED-EXCLUDED) | Phone file(s) | Where the brain lives (Core ·
   Shared · Mac-app-local = hoist owed) | Known ticket/ledger row (VM-n, PL-n) | Size (S/M/L) | Note`.
   STALE means the phone has it but it follows a rule the Mac has since changed, or it is visibly
   behind. Be granular: a designer should be able to turn each ABSENT/PARTIAL/STALE row into a ticket.
2. **What's there but behind** — the phone's existing faces in your area judged as they stand:
   wrong/retired behavior, rough flows, missing states, anything a daily user would trip on.
3. **Flow notes** — for your area, how the user gets from A to B on the phone today (the navigation
   as built), and where it is awkward.
4. **Open questions for the author** — only real product calls, each with 2–3 options.
Every claim says how you know it: VERIFIED (you read the code — give file:line) or INFERRED (say from
what). Never guess silently. Do not propose code. Do not invent product behavior.

## Reply to the orchestrator
When done, reply with at most 300 words: the file path, the counts (rows by status), the five most
important findings, and anything that blocks or contradicts another reader's likely area.
