# Phase 13s — Voice & polish + first-run onboarding

**Ticket: VX-7 · Project: 13s — Voice & onboarding · Branch: `vx-7-13s-voice-onboarding` · Machine: THE AIR (its clone, on the pushed branch)**

*(This file holds the KICKOFF; the execution plan lands here after the kickoff sitting, authored
by this phase's orchestrator. Written 2026-10-06 at the workflow transition.)*

## KICKOFF MESSAGE (the author launches a fresh orchestrator with `/architect-phase 13s` — on the Air)

You are the orchestrator for **Phase 13s — VOICE & POLISH + FIRST-RUN ONBOARDING**, the
author-heaviest phase of the three in flight: her copy lands, the design review runs, the field
guide is rewritten for users.

**The workflow is new — read it first.** PREFLIGHT, complete and never delegated: CLAUDE.md +
its auto-loaded canon · **`notes/plans/workflow-transition-2026-10-06.md`** · the master plan's
IN-FLIGHT table · the board snapshot (`notes/TICKETS.md` — on the Air, your clone's copy after
`git pull`; never run `Tools/vx sync` off main) · `notes/QUESTIONS.md` ·
`notes/SessionResiliencyProtocol.md` · **`notes/plans/phase-13s-onboarding-intake-2026-10-04.md`**
(the intake — this phase's accumulated inputs). Work on THIS branch in the Air's clone; one PR
titled `VX-7: …`, merge commit, at closeout. Linear: VX-7 In Progress → In Review → Done.

**THE SPEC is `notes/FuturePhases.md`'s 13s row, read WHOLE.** The standing bars this kickoff
repeats because they are hers verbatim: the copy §11 re-voicing (~45 rows) **never softens
Standard's limit or Castle's "nobody can help"**; the DESIGN REVIEW is **PROPOSE-ONLY** — her
binding posture since 13b: *"everything it surfaces should be brought to me to consider… it's
all a taste question"* — nothing is built from it autonomously, and it inherits the accumulated
visual-loop item lists (the 13b plan's 4A–4F batch records name the never-inspected surfaces);
first-run onboarding is the first-ten-minutes story (it LEFT the v1-readiness row for this
phase); the field-guide rewrite re-seeds, so lesson-currency pins ride every copy change.
Project ticket **VX-45** (the copy family: the book-only delete receipt, the archived empty
state, the "(M archived)" refinement) lands here; sweep the board for other copy-labeled
hand-ins at kickoff.

**THE AIR'S POSTURE IS A RULE (hers):** this machine runs the headless core loop at most
(`swift build` · `swift test`). EVERY `xcodebuild test` run, walk, seed re-generation check or
Debug launch happens ON THE PRO — ssh over, claim `Tools/stage`
(`ssh <pro> '~/dev/variorum/Tools/stage claim --who 13s --reason … --minutes N'`), run there,
release. The Air is never possessed by suites. Sittings with her carry the phase: bundle
questions, present mockups/copy tables for her ruling, land rulings repo-first. Closeout per
CLAUDE.md: the in-flight row retires, the PR merges, hard stop.

---

## KICKOFF RECORD (2026-10-06 evening — the VX-7 orchestrator; the sitting runs next)

- **Seat:** the PRO, worktree `~/dev/variorum-13s`, branch ff'd to main (a7412d2c) and pushed. The kickoff above expected the Air; she launched with "you are implementing and coding on the mac pro right now" — the in-flight row reflects the move (main b6113a66). She attaches from the Air; the Air views the branch by `git pull && git switch`. Suites, when they come, run HERE under a held `Tools/stage` claim (the "over ssh" line above was written for an Air seat; flagged at the sitting).
- **Scope at launch, her word:** the ONBOARDING half (13s-b) first, not the rewording (13s-a). 13s-a's hand-ins (copy §11, the J-list, the "13s re-voices" family, VX-45, release notes) are swept and WAIT.
- **Preflight complete:** CLAUDE.md canon · workflow transition · master plan in-flight table · TICKETS.md (regenerated, 79 open; copy-labeled sweep found VX-45 only) · QUESTIONS.md (open-item sweep + the #179–#188 tail whole) · the 13s intake (2026-10-04) · FuturePhases 13s row whole · resiliency protocol. SyncSpec/TEXTKIT2 deferred until a batch touches their seams (seed-dedupe work would be Sync-adjacent — noted below).
- **Surfaces declared (overlap check):** first-run/onboarding chrome, tutorial/Help features, seed content. 13o (search surfaces): low overlap. 13x (Sync/custody, portability doors): none NOW — but a later seed-set reshape touching `SampleLibraryDedupeFacts` is a `Sync/` touch, and the Sync slot queue is 13o → 13x (R-13o-1); 13s-b's seed code waits its turn or lands clear of `Sync/`. VM-5 (mobile merge): closeouts serialize; we are early and unaffected.
- **Linear:** VX-7 In Progress. Pro→Air ssh tested: OFF (Connection refused — Remote Login disabled on the Air); not needed for this flow.
- **Execution shape standing from the intake (her 2026-10-04 ruling):** MOCKUP-FIRST — every screen and sentence approved before Swift. Mockups as self-contained local HTML, absolute paths.

## SITTING RECORD — the 13s-b kickoff sitting (2026-10-06 evening, the question tool + her live message; rulings verbatim-faithful)

**R-13s-1 — ONE tour with an optional leg.** Her pick of the recommended shape: one short tour (~2 min) ending in a "keep going?" fork that adds the longer-basics leg; both roads end pointing at the field guide. Two separate tutorials declined with it; the longer-basics content lives in the leg (and the field guide stays the deep reference).

**R-13s-2 — Calm open + the helpful badge.** Her words: *"calm open, there can be a small helpful badge (think clippy showing up in the corner), offering a tutorial. it can be on the main screen without being a popup."* No popup at first open — R-13r-11 holds by design, not exception. **Declined idea, recorded at her word:** *"i thought of even putting a picture of me in there waving to start it but decided that would be too much."*

**R-13s-3 — The quick-entry line returns to the BOTTOM (a build item of this phase).** Her words: *"please make the 'new note, just start typing' default to being at the bottom of the page again (above the bottom bar, but not right up next to books). the tutorial offer can live above that bar on the right side."* So the first-open band reads: quick-entry at the bottom of the content area (air between it and the book rows), the tour badge above the bottom bar at the right.

**R-13s-4 — Coach-marks on the real app, and the tour MAKES a take.** Her words: *"coach-marks on the real app, they should at least make a take in write and then see open take mode too (can be within sherlock)"*. The tour is interactive (real clicks advance), and its centerpiece is creating a second take of a real paragraph in Write, then opening Takes to see the fan — inside Sherlock is legal. (Seed-fold note: Sherlock dedupes by the Sherlock-style rule — your edited copy kept — so a toured Sherlock still folds clean on a later sign-in; #186(a).)

**R-13s-5 — The seed reshape is IN 13s-b's scope.** Her pick of the recommended option. The final set stands as her stated list (*"only starred notes there with 0 items starred, sherlock, and field guide (maybe one standalone note too)"*). Seed code touching `Sync/` dedupe facts sequences behind the Sync slot (13o → 13x, R-13o-1); the mockup shows the final set now.

**Her directive at the sitting's close (verbatim):** *"what I want done right now is the mockups and ideas on how things can be - save all of the results of what you do in the repo and pushed, along with notes, because there's a good chance I'll pick this back up from the air."*

## THE EXECUTION PLAN (drafted at kickoff; mockup-first per her 2026-10-04 ruling — units firm up as mockup screens are approved)

- **U0 — THE MOCKUP ROUND (now, orchestrator-built):** the click-through `notes/plans/13s-mockups/onboarding-tour.html` — every screen and sentence of the tour, the first-open surface with the final seed set, the badge, the keep-going leg, an ideas/variations frame. Evidence: her per-screen approval; iterations land in this file and the mockup until approved. NO Swift before approval.
- **U1 — THE FIRST-OPEN SURFACE:** the seed reshape to the final set (R-13s-5) · the quick-entry line's return to the bottom (R-13s-3) · the tour badge (R-13s-2; lifecycle per the mockup's answered questions) · Study as the fresh-store default voice (ruled 2026-10-05). Partly `Sync/`-adjacent (dedupe facts) — lands after 13o frees the slot, or split so seed-dedupe diffs wait.
- **U2 — THE TOUR ENGINE + STEPS:** coach-mark machinery over the real app (anchor targets, real-click advance, dim+spotlight), the core leg + keep-going leg to the approved mockup, the make-a-take step (R-13s-4), the end card → field guide. The tour is the executable spec (P-6): a TourWalk test rides every step; a step broken by a later phase is a regression by definition.
- **U3 — THE QUICKSTART NOTE + RE-ENTRY DOORS:** the standalone fast-read note (her intake's "1 super simple fast read Quickstart note"), where it lives (open Q), Help ▸ tour re-entry, the badge's dismissal/return story.

Sizing: U1 and U2 are the two phase-sized units (within guidance); U0/U3 are small. Acceptance is USE-shaped: her walk of the real flow on a fresh dev store before any unit's record closes. 13s-a (the rewording) is NOT this effort's scope — it runs at her word as its own letter per the FuturePhases split ruling.

**OPEN QUESTIONS FOR THE NEXT SITTING (bundled; the mockup's ideas frame carries them too):** (1) badge lifecycle — when it disappears (tour completed · "Not now" pressed once · N quiet opens), and whether a dismissed badge leaves a smaller re-entry affordance; (2) where the Quickstart note lives (Pool · pinned atop the Library · the badge's "read the two-minute version instead" twin); (3) the make-a-take gesture the tour teaches (the block's ▾ menu vs a shortcut); (4) tour interruption (quit mid-tour — does the badge return offering to resume); (5) the keep-going leg's exact four stops (proposed: star · tag · add to a book · the snippet → Snippets); (6) whether the tour's Sherlock take persists afterwards (a souvenir of the tour) or cleans up.

## SEAT NOTE — resumed 2026-10-07 ON THE AIR, in a WORKTREE (her word)

She resumed on the Air and ruled a **worktree** for this effort — her words: *"start a worktree for this effort - several items are in flight right now on the pro and will be merging into main."* This deliberately overrides the Air's one-clone-switches rule (the Air's clone of `~/dev/variorum` STAYS on `main` to receive the in-flight merges — 13x, VX-83, VX-92 are all heading there). Seat: **`~/dev/variorum-13s` on the Air**, branch `vx-7-13s-voice-onboarding` (same worktree name as the Pro's — different machines, no collision). First development bout run from the Air; no hiccups at setup (pulls, worktree add, `Tools/vx sync` on main, mockup opened — all clean; the Linear key is present in this Mac's Keychain). The Air's posture is unchanged: headless `swift build`/`swift test` at most; suites/walks stay on the Pro via the stage (scheduler today: the `oct7coordinator` session, per the in-flight table). Nothing in this note changes scope or rulings; the mockup-walk sitting is next.

## RESUME PROMPTS — the mockup-walk sitting (written 2026-10-06 night at her ask; she picks up tomorrow, machine unknown)

**State at sleep:** mockup delivered and pushed (b4abda9a); rulings R-13s-1…5 recorded above; open questions Q1–Q8 bundled (the EXECUTION PLAN's list + the mockup's ideas frame); 13s out of the stage queue (13o schedules; nothing needed for a mockup sitting); NO Swift before her per-screen approval.

### If she resumes ON THE PRO (paste-ready)

> /architect-phase vx-7 — resume 13s-b at the MOCKUP WALK, on the Pro. The worktree `~/dev/variorum-13s` exists on branch `vx-7-13s-voice-onboarding` — verify clean (`git status -sb`), `git pull --ff-only`. First steps per CLAUDE.md: `git pull` in `~/dev/variorum` AND the shared memory repo, then `Tools/vx sync` (in `~/dev/variorum`, on main). Read WHOLE: `notes/plans/phase-13s-voice-onboarding.md` (kickoff → KICKOFF RECORD → SITTING RECORD R-13s-1…5 → EXECUTION PLAN → RESUME PROMPTS), the intake `notes/plans/phase-13s-onboarding-intake-2026-10-04.md`, and the memory file `vx-7-13s-run-state`. Then give me the mockup's path — `~/dev/variorum-13s/notes/plans/13s-mockups/onboarding-tour.html` — I'll walk the 17 frames and report; you record my rulings VERBATIM repo-first (numbering continues R-13s-6+), bring me the Q1–Q8 bundle with recommendations, iterate the mockup same-day, commit+push per piece (the memory repo immediately after every write). NO Swift before my per-screen approval. Stage: 13s is out of the queue — when U1/U2 builds near, request an assignment from the "13o" session (ListAgents); never claim without one.

### If she resumes ON THE AIR (paste-ready)

> /architect-phase vx-7 — resume 13s-b at the MOCKUP WALK, on the Air. Seat yourself: `cd ~/dev/variorum && git pull && git switch vx-7-13s-voice-onboarding && git pull` (the Air's one clone switches branches — no worktrees here), and `git pull` the shared memory repo FIRST (`~/.claude/projects/-<home>-dev-variorum/memory`). NEVER run `Tools/vx sync` off main — read `notes/TICKETS.md` as committed. Read WHOLE: `notes/plans/phase-13s-voice-onboarding.md` (kickoff → KICKOFF RECORD → SITTING RECORD R-13s-1…5 → EXECUTION PLAN → RESUME PROMPTS), the intake `notes/plans/phase-13s-onboarding-intake-2026-10-04.md`, and the memory file `vx-7-13s-run-state`. Then give me the mockup's path — `~/dev/variorum/notes/plans/13s-mockups/onboarding-tour.html` — I'll walk the 17 frames and report; you record my rulings VERBATIM repo-first (numbering continues R-13s-6+), bring me the Q1–Q8 bundle with recommendations, iterate the mockup same-day, commit+push per piece (the memory repo immediately after every write). NO Swift before my per-screen approval. The Air's posture is a rule: headless `swift build`/`swift test` at most — EVERY suite/walk runs on the Pro via the stage, and stage scheduling belongs to the 13o session on the Pro (a mockup sitting needs none; defer build-batch stage coordination to a Pro-seated session or ssh per CLAUDE.md).
