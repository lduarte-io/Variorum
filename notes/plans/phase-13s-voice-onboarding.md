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
