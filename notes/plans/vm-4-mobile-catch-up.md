# VM-4 — The mobile catch-up READING & PLAN

**Ticket: VM-4 (flagship, team VM) · Project: Mobile — the catch-up & launch · Worktree: `~/dev/variorum-mobile` (branch `mobile`)**

*(This file holds the KICKOFF for the catch-up PLANNING session; the plan it produces lands here
or in files this one names. Written 2026-10-06 at the workflow transition, at her word: the
mobile session's "long overdue reading of everything that has to be done to catch up and plan it
all." This is a SIGNIFICANT LIFT — a planning mandate, not a build.)*

## KICKOFF MESSAGE (the author launches in `~/dev/variorum-mobile`)

You are the **mobile catch-up planner**. Mobile has been paused since ~2026-08-30 while the Mac
ran 13u → 13i → 13r → 0.9.2 (now LIVE, friends beta open). Your duty is a THOROUGH catch-up
plan and the Linear organization to carry it — **you build nothing**; you read, reconcile,
structure the board, and bundle every question into ONE sitting for her ratification. Hard stop
at the plan + sitting bundle.

**A branch fact before anything: `mobile` predates the 2026-10-06 workflow transition.** Read
every transition-era doc from MAIN's checkout by absolute path (`~/dev/variorum/notes/…`) — and
do NOT merge main into `mobile`: how main's two months of changes reach the mobile branch is
exactly the branch-shape question below, hers to rule first.

**PREFLIGHT (never delegated), in this order:**
1. Your project memory (auto-loads — the VM workflow + cast ruling) ·
   `~/dev/variorum/CLAUDE.md` ("Tracker & parallel work" especially) ·
   `~/dev/variorum/notes/plans/workflow-transition-2026-10-06.md` (the whole system).
2. The standing mobile entry point: `notes/plans/mobile-round-2-orchestrator-handoff.md`
   (HANDBACK CHECKLIST first) · `notes/MobileSoul.md` (the parity ledger) ·
   `notes/plans/mobile-app-plan.md` (incl. the v1 gate sitting — mobile is a COMPLETE app,
   her ruling).
3. What happened while mobile slept: the master plan's closeout log (13u1→13r paragraphs) +
   `notes/AppSpecDeltaArchive.md` + AppSpec §14's recent entries — the 13i family (wings,
   Bookcase, gatherings, Owned/Finished/Sealed, the daily Journal) and the 18-era editor-seam
   hoists are the big parity surfaces born since.
4. The board: `~/dev/variorum/notes/TICKETS.md` — VM-1 (hand-ins bundle), VM-2 (keystroke
   fence, data-shaped), VM-3 (tutorial copy, her flagged beta risk); plus every Mobile-labeled
   VX ticket and the frozen archive rows they cite.

**THE DELIVERABLES (all repo-first, then the sitting):**
1. **The branch-shape PROPOSAL** (deliberately left to you): (a) keep long-lived `mobile` with
   `vm-N-slug` ticket branches off it and periodic mobile→main merges, or (b) rebuild onto
   main-based worktrees. Weigh: two months of main drift, the shared-core hoists already on
   main, the PR rule, the resiliency protocol. Recommend one; she rules.
2. **The catch-up plan**: reconcile the handoff's owed reviews and batches-through-10 against
   today's tree (some owed work may have been discharged by the Mac's hoists — verify, never
   assume); fold in VM-1/2/3 and the parity ledger's open rows; sequence into batches sized per
   `notes/PhaseSizingGuidance.md`; name what is data-shaped or beta-visible (VM-2, VM-3) as
   pull-forward candidates for her.
3. **The Linear organization**: projects (epics) within team VM with a FLAGSHIP each, tickets
   per batch/row with two-way pointers (plan-file path in every ticket; `Ticket · Project ·
   Branch` in every plan-file header), states honest (Parked carries reasons; her calls to
   Needs Lillian). The conventions are the transition record §9; runs use the RUN-ticket
   pattern; mobile epics never mint in VX.
4. **The sitting bundle**: branch shape, pull-forwards, sequencing, anything the reading found
   ambiguous — one organized list, her rulings, then the plan finalizes and VM-4 moves to
   reflect it.

**Rules that bind:** the stage (`~/dev/variorum/Tools/stage`) for ANY simulator/device/suite
run — though a reading should need none; CLAUDE.md's author-only list; repo-first records (this
file is your record — keep a LIVE STATUS section from your first commit, per the resiliency
protocol); commits on `mobile` push to `origin/mobile` as ever until the branch-shape ruling
says otherwise.
