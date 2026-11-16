# VM-44 — the Great Mobile Catch-up: handoff after sitting 1

Written 2026-11-15, at the close of the first planning session. The effort is NOT finished: the audit, the
design and her first sitting are done; composing the umbrellas and waves and minting the tickets is the next
session's work. Ticket: VM-44 (team VM, In Progress) · Branch: `vm-44-mobile-catchup` · Worktree:
`~/dev/variorum-vm-44` (it also holds the local-only screenshots and clips, so keep it).

## Her checklist

1. Start the next session with the kickoff message below.
2. Second sitting, when that session asks: approve or reshape the umbrellas and waves; skim the revised mockups.
3. Whenever you like: the wording pass over the designers' proposed lines (each mockup's build notes list them).
4. Fill nothing: the guard's private list is already compiled on both Macs. Six tokens were left out of it
   because they are already public on purpose (a backup folder name, the production project ref, the team id,
   your domain, an old session name, the scratch folder name) — say if any should not be public.
5. Decide what to do with the two phone safety copies under `~/.variorum/phone-safety-copies/` (about 280 MB
   each; keeping the newer one is enough).
6. Delete the test notes on your phone if any were made tonight (none should have been; the trace did not run).

## What exists (all under `notes/plans/vm-44/`, start at its README)

- `her-words.md` — everything she said for this effort, verbatim, in order. Read first.
- `plans/sitting-1-rulings.md` — her decisions sorted by surface and question id. **The planner's main input.**
- `plans/master-work-list.md` — 263 candidate tickets from seven audits, with sources, sizes, dependencies and
  which existing VM tickets each absorbs. `plans/dependency-notes.md` — the hard ordering constraints, the
  shared-code moves several rows wait on, the items that should not wait, and which rows collide in the same
  files. `plans/sitting-1-questions.md` + `sitting-1-recommendations.md` — the 70 questions and the defaults.
- `audit/` — the seven audits (A shell and Library · B books · C the note · D protection, sync, launch · E the
  ledger and ticket reconciliation · F the performance trace · G visual metrics).
- `design/sketches/` (the choices she was shown, and `sizing-sheet.html`) and `design/mockups/` (twelve files:
  home-wings-capture · library-and-search · trash-archive-tags · a-book · arrivals · note-write ·
  takes-and-history · comments-and-callouts · first-run-and-joining · lock-and-protection · export-and-share ·
  compare-concept). **The mockups predate several of her rulings**; see "next" below.
- `atlas/` — the screen inventory and walk findings from the simulator capture of 2026-11-12; the screenshots,
  clips and contact sheet are local only (gitignored), in this worktree.

## What is done and closed

VM-45 (a current build on her phone; sync works again) · VM-46 (the brand icon and the name "Variorum" on the
phone) · VX-996 (the pre-push guard; installed on both Macs; the private list compiled) · VX-998 (the owed
open-source verify pass) · VX-999 (the release scripts read the signing profile from `~/.variorum/release/`).
VX-1000 minted (a book as a folder of notes, Mac and phone, after v1). VX-987 (all-wings search) moved to Todo.
VX-207 retitled. The Air is cut over to the public clone; pushes from both old private clones are disabled;
the Variorum repo commits as her GitHub noreply address on both Macs.

## Next, in order (the next session's work)

1. **One revision pass on the mockups** so they match `plans/sitting-1-rulings.md`. The known gaps: the
   keyboard capsule's ⋯ quick row (Undo, Redo, Comment, Commit) and no routine receipts; the masthead without
   the place readout; the lock icon on the home screen, "back to where I was" after an unlock, the app switcher
   as today; full wing and shelf management behind a ⋯; a way to put the capture keyboard away; the bottom bar
   on roots and lists only; Snippets with edit and delete; search with an all-wings switch; book settings with
   the word target and note limit; simpler wording throughout. Fable designers, at most two at a time (her
   cast for this effort); they reuse the generators beside each mockup.
2. **Compose the umbrellas (5–10 tickets each) and waves (2–4 umbrellas each)** from the work list, the
   dependency notes and the rulings, and propose them to her IN CHAT (her rule: no wave document before she
   approves the composition). The orchestrator's early guess, unconfirmed: wave 1 makes what exists right
   (performance with the timing markers first, the phone sizing layer, wings and the shell, the data-shaped
   fixes that should not wait); then books and Arrivals, the Library and search; then the note; then protection,
   onboarding, export, accessibility and launch; Compare after v1.
3. **Second sitting** with her: the composition, and a skim of the revised mockups.
4. **Mint the tickets** in team VM (labels per CLAUDE.md; no assignee; each ticket a pointer plus one line, with
   its mockup file named), re-home or close the existing VM tickets the work list absorbs, write the approved
   plan as `notes/plans/vm-44-mobile-catch-up-plan.md`, record the canon deltas she ruled (MobileSoul: Compare
   reopened after v1, the lock's phone reading, the retired worktree line; SurfaceContracts where a phone
   surface is now ruled), and merge.

## Things a later reader would otherwise trip on

- **The stage:** every simulator or device act needs a claim from the coordinator. Never sit in a question
  dialog while holding one (a claim lapsed that way on Nov 12); release and re-request instead.
- **Her phone:** installs go in place over the cable with `devicectl`, a verified safety copy first, never an
  uninstall; the app must be closed first, and it does not relaunch by itself. The runbook is
  `plans/vm-45-install-runbook.md`. The installed build is main `beb638033`; its symbols are in DerivedData
  `vm46-device` on the Pro.
- **Instruments from the command line** attaches to the app only by process id (it knows the process by its
  display name), after a read-only `devicectl` call wakes the tunnel. The prepared recorder and analyzer are in
  the worktree's `audit/traces/` (local only). She prefers chat cues to spoken prompts.
- **How she wants sittings run:** open each file on the Pro in the order to be discussed, explain, then use the
  question tool; put the context inside the question, because text written just before a dialog can be hidden.
- **Usage:** this account hit a weekly limit once during the session; run one or two agents at a time.

## Kickoff message for the next session

You are the planner for VM-44, the Great Mobile Catch-up (Variorum's iPhone app). The audit, the design round
and her first sitting are done and merged. Work in `~/dev/variorum-vm-44` (branch `vm-44-mobile-catchup`; merge
`main` in first). Read `notes/handoffs/vm-44-sitting-1-handoff.md`, then `notes/plans/vm-44/her-words.md` and
`notes/plans/vm-44/plans/sitting-1-rulings.md` in full, then the work list and the dependency notes. Your job,
in order: (1) one revision pass on the mockups so they match her rulings (Fable designers, at most two at a
time); (2) compose umbrellas of 5–10 tickets in waves of 2–4 and propose them to her in chat; (3) hold the
second sitting; (4) at her approval, mint the VM tickets with their mockups named, re-home the old ones, write
the plan file, record the canon deltas, merge. No product code. Her words govern; where they are silent, give
her options, never invent.
