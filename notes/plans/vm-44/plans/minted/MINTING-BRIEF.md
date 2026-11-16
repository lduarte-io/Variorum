# VM-44 — minting the tickets (the brief every minter shares)

You turn part of the APPROVED plan into Linear tickets. You write no code and change no canon file.

## Read first
1. `notes/plans/vm-44-mobile-catch-up-plan.md` — the approved composition. Your umbrellas are named in your
   message; mint exactly those, with exactly the work-list rows the plan gives them.
2. `notes/plans/vm-44/plans/sitting-1-rulings.md` — the author's decisions. A ticket never contradicts a ruling;
   where a row's old wording does (for example a row that offers options she has since chosen between), the
   ticket states the ruled answer.
3. `notes/plans/vm-44/plans/master-work-list.md` — find each of your rows by id (W-nnn): its title, what is
   wrong or missing, sources (audit sections; existing VM-/VX-/PL- ids it absorbs), brain status, size,
   dependencies. `notes/plans/vm-44/plans/dependency-notes.md` for ordering and hoists.
4. `CLAUDE.md` "Tracker & parallel work" — the labeling rule, which binds every ticket.

## What to mint, per umbrella
- **One umbrella ticket** in team **VM**, project **"Mobile — the catch-up & launch"**: title
  `Umbrella: <the umbrella's name from the plan>`; labels `Umbrella`, `Mobile` and ONE Area; priority High for
  waves 1–2, Medium for waves 3–5, Low for wave 6; state Todo. Description (short, plain): one sentence saying
  what the umbrella delivers; "Wave N of the mobile catch-up (`notes/plans/vm-44-mobile-catch-up-plan.md`)";
  the mockup files; anything that must come first inside it (for example "the timing readout first").
- **5 to 10 member tickets** as sub-issues of the umbrella (`parentId`), covering EVERY row the plan gives the
  umbrella. Merge small related rows into one ticket; split a row only if it hides two separable pieces. Each
  member: a title that is public copy in plain words (sentence case, says what the user gets or what is wrong,
  no jargon, no exploit detail); ONE kind label (Bug · Improvement · Feature · Debt); on a Bug, Improvement or
  Debt ONE Evidence label (Confirmed where an audit verified it in code or she reported it; Suspected where the
  audit says INFERRED); ONE Area (Editor · Takes & Lenses · Library & sidebar · Books · Search · Castle & sync ·
  Import & export · Settings & onboarding · App shell · Performance · Tests & tooling); the `Mobile` label; a
  Priority (High where the work list marks her priority HIGH or the row is in the plan's "should not wait" set;
  otherwise the umbrella's); state Todo; NEVER an assignee; same project.
- **A member's description is a pointer plus a few lines, never a spec:** what is wrong or missing in one or
  two sentences; the ruled answer where she ruled one (quote her words where they are short); `Rows: W-…`;
  `Mockup: notes/plans/vm-44/design/mockups/<file>.html` (or the sketch); `Audit: <file §>`; `Depends on:` other
  tickets by id where the work list says so (use Linear's `blockedBy` for members you minted; name rows from
  other umbrellas as W-ids in text). Put longer agent detail (files, the hoist owed, the pin idea) in a
  collapsible `+++ Agent notes` section.
- **Existing tickets:** if a row's sources name an OPEN VM ticket that is this same work, do not mint a twin —
  re-home the existing ticket instead (set its parent to the umbrella, fix its labels to the rule above, remove
  the retired `Pre-launch` label, add the pointer lines to its description, keep its id). If an existing ticket
  is only PART of a new ticket, mint the new one and relate the old one (`relatedTo`), leaving a line in the
  old ticket saying which new ticket carries it; do not close anything — list closing candidates in your
  report. Never touch VX tickets except to relate them.
- Check for duplicates before each create (`list_issues` with a keyword query in team VM).

## Record
Write `notes/plans/vm-44/plans/minted/umbrella-<nn>.md` for each umbrella: its ticket id and title, then a
table `Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup`, then "Existing tickets re-homed or
related", then "Closing candidates". Do NOT commit or push (the orchestrator does).

## Rules
- Titles and descriptions are PUBLIC copy (the board snapshot publishes): no private identifiers, no account
  or device ids, no email addresses, nothing that reads as a recipe for getting past protection.
- Never estimate how long work takes; sizes S/M/L only, and only inside Agent notes.
- If a row cannot be placed without a decision the rulings do not give, mint the ticket in state
  "Needs Lillian" with the question and 2–3 options in its description, and say so in your report.
- Reply in under 150 words: the umbrella ids, the member counts, tickets re-homed, anything in Needs Lillian.
