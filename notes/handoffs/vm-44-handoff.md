# VM-44 — the Great Mobile Catch-up: the planning handoff

Written 2026-11-16, at the close of the planning effort. The plan is approved, the tickets are minted, and this
merge carries all of it. Nothing was built; the building starts with wave 1.

## Her checklist

1. **Answer the five parked questions** (each ticket carries its options; the orchestrator's lean in brackets):
   - VM-76 — after File, a line saying where the quick note went, with an Open door? Also covers the line after a
     copy to another wing. [yes for File: the note is otherwise out of sight]
   - VM-95 — a note's tags on its Library row? [no; the row stays calm]
   - VM-15 — the library and the iPhone's own device backup. [leave it out whenever the library syncs]
   - VM-166 — where a book's filter lives on the phone without the Index. [not in v1]
   - VM-169 — Undo after dismissing an arrival. [the Mac's line, no Undo]
2. **Start wave 1** when you are ready (kickoffs below). Its four umbrellas run together; umbrella 3 is the
   wave's one sync-touching effort and umbrella 3's first ticket (the timing readout, VM-65) goes on your phone
   before any speed fix lands.
3. **The wording pass**, whenever you like: 237 drafted lines in
   `notes/plans/vm-44/design/wording-list-1.md` and `wording-list-2.md`.
4. **Old tickets to close or keep, at your word:** VM-4, VM-1, VM-6, VM-7, VM-9, VM-28, VM-42 (old umbrellas and
   bundles whose every part now has a home in the new umbrellas; each carries a line saying where), VX-618,
   VX-68, VX-672 (Mac-side twins the minters only related). Closed already as exact duplicates: VM-20 (in
   VM-16), VM-19 (in VM-24), VM-26 (in VM-110).

## What this effort produced

- **The plan:** `notes/plans/vm-44-mobile-catch-up-plan.md` — 22 umbrellas in six waves, every work-list row
  placed, the rules every umbrella inherits, the after-v1 list, and the table of umbrella tickets.
- **The tickets:** 22 umbrellas and 181 members in team VM, project "Mobile — the catch-up & launch"; each
  member names its work-list rows, its mockup and its audit section. Per-umbrella lists:
  `notes/plans/vm-44/plans/minted/umbrella-NN.md`.
- **The record:** `notes/plans/vm-44/` — her words (`her-words.md`), her rulings sorted by surface
  (`plans/sitting-1-rulings.md`), the seven audits, the 263-row work list and its dependency notes, the sizing
  sheet, the sketches, and twelve mockups revised to her rulings.
- **Canon:** CoreDescription pillar 8 and MobileSoul §4.5 (Compare comes after the phone's v1; snippets are
  managed on the phone), MobileSoul §5 (the lock's phone reading) and §7 (the retired worktree line), the master
  plan's mobile row, CLAUDE.md's Environment lines on how work runs in the public repo.

## Wave 1 kickoffs (one session each, started together; the stage coordinator serializes their merges)

Each runs as a RUN over its umbrella's members. Paste into a fresh session in `~/dev/variorum`:

- `/run-phase vm-47` — Sizes and look. Read `notes/plans/vm-44-mobile-catch-up-plan.md`,
  `notes/plans/vm-44/plans/minted/umbrella-01.md` and `notes/plans/vm-44/design/sketches/sizing-sheet.html`. The
  type layer is a phone layer over the shared tokens: the Mac must not change.
- `/run-phase vm-55` — Wings underneath. Read the plan, `umbrella-02.md`, and audit A §3.1. No new screens: the
  wing state, the scoped reads, the pickers, the message line.
- `/run-phase vm-64` — Timing and the two lags. Read the plan, `umbrella-03.md`, and audit F. VM-65 (the timing
  markers and readout) lands first and goes on her phone; VM-2 does not wait for it. This is the wave's
  sync-or-custody slot, and its editor-seam diff needs the Fable cold review.
- `/run-phase vm-78` — Fixes to what's there. Read the plan and `umbrella-04.md`. Small, mostly independent
  fixes; pin before fix per member.

Later waves start the same way from the plan's table, each wave after the one before it has merged.

## Things a later reader would otherwise trip on

- **The mockups are the starting point, not a pixel contract;** the drafted lines wait for her wording pass
  before they ship.
- **Her phone:** installs go in place over the cable with `devicectl`, a verified safety copy first, never an
  uninstall, the app closed first (`notes/plans/vm-44/plans/vm-45-install-runbook.md`). The build on her phone
  is main `beb638033`; one safety copy is kept under `~/.variorum/phone-safety-copies/`.
- **The stage:** never sit in a question dialog while holding a claim; release and re-request.
- **Sittings:** open each file on the Pro in the order to be discussed, explain, then use the question tool with
  the context inside the question. She does not want spoken prompts.
- **The worktree `~/dev/variorum-vm-44`** holds the local-only screenshots, clips and mockup renders
  (gitignored). Keep it while the waves run; the mockups themselves are in the repo.
