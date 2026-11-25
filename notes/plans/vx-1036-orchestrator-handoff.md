# VX-1036 — orchestrator handoff (written 2026-11-24, at the first orchestrator's context seam)

**For:** the session that takes the architect/orchestrator role for VX-1036 next. **Shape:** `/architect-phase vx-1036`. **Read whole:** `notes/plans/vx-1036-organizing-inside-a-book.md` (the effort is open — whole, not only its first section).

## The role, as it stands

- Architect and orchestrator for the umbrella VX-1036, under her word at kickoff: "we will finish the design plans together before you do any building." **The design closed on 2026-11-25. Nothing is built. No implementer has been spawned; no stage has been claimed.**
- You never implement (CLAUDE.md's cast rule). Mockups have been drawn by one worker at a time from a brief written into the plan file first (§4c, §4e): round 1 by a Fable subagent at her explicit word for that round, round 2 by an Opus worker. The standing rule is Opus or Sonnet for subagents, the model always named.
- Her rules that have already bitten once here: repo notes carry the FEATURE only — nothing personal from notes or screenshots she shares (her real note titles and tags never enter the repo or a mockup; sample content is invented); she never wants an Artifact — local self-contained HTML and the full path; every message of hers is answered point by point in her words; no time estimates; a ticket id comes only from a `save_issue` result.

## State at cutover — verify, do not trust

- Branch `vx-1036-organizing-inside-a-book`, worktree `~/dev/variorum-vx-1036` (Pro), in sync with origin at the commit that added this file. The in-flight row is on main. The branch was rewritten ONCE at her word (its first two commits became one); that word covered that rewrite only.
- Members (list the sub-issues of VX-1036 on Linear — the listing is the roster, never a description): VX-1037 lanes · VX-1038 tags inside a book · VX-1039 the new-note defect and landing · VX-1040 the order dial · VX-1041 wings · VX-881 titles in Read · VX-1026 the wire's book order · VX-1078 tags on a quick note · VX-1079 lanes on the wire · VX-1080 the radio-scroll title · VX-1081 the pill's ×.
- The rulings are R-1036-1…28 in the plan's §5. The design is §4b as amended by §4d (where they differ, §4d stands).
- The mockups: `notes/plans/vx-1036/mockup-1-book-and-lanes.html`, `mockup-2-wings.html` (round 1), `mockup-3-round-2.html` (round 2). Each takes `?theme=dark` and `?only=<frame id>`; render off-screen with headless Chrome into the scratchpad to look — never open a window on her screen.
- One schema event is accepted in principle (R-1036-5: the lanes column on `reading`); its mirror deploy runs only at her explicit go, in one window with both Macs and the phone. Wings' choices are planned as synced `setting` keys — no event.

## Where it stands (updated 2026-11-25)

**The design is closed** (R-1036-42). The plan's §4f is the design as closed; §5 holds rulings R-1036-1…43. Members now also include VX-1084 (the list mode).

Open with her:
1. **The umbrella composition** (R-1036-43). She wants 2 or 3 umbrella tickets for the twelve members. A three-umbrella cut was proposed to her in chat — the book view (VX-1036 kept: the small fixes, pills on cards, the list mode, tags on new notes) · lanes with their schema event and the wire · wings (VX-1041 split into its pieces). Nothing is minted or re-parented until she says so; write the composition into the plan only once she approves it.
2. **Getting the design onto main.** The record and the mockups live on this branch; a run that branches from main cannot read them. A docs-only PR was proposed to her. If it merges under a `VX-1036:` title, Linear closes VX-1036 — reopen it with a one-line comment.
3. The add-tag chord (at the build) and the lanes run's cast (at its kickoff).
4. Four faces exist only in words (§4f's list); each is shown to her at its run's first walk.
5. Ticket bodies are pointers and some still say "drawn for her to choose"; the plan's §5 is the truth.

## Owed before the first implementer spawn

- Build preflight in full (the plan's §8): `notes/QUESTIONS.md`, the board snapshot, `notes/SessionResiliencyProtocol.md`, `notes/plans/workflow-transition-2026-10-06.md`, `notes/PhaseSizingGuidance.md`, `notes/MobileSoul.md`; `notes/SyncSpec.md` in full for the lanes column; `notes/MCPSpec.md` in full for VX-1079 and VX-1026; `notes/SurfaceContracts.md` for the Library, the Bookcase and books, the note, and Doors.
- A per-run execution plan with its acceptance units and their evidence named; pins before fixes (VX-1039's trace in §3a is by reading only); the MOBILE PARITY rows; announce to the day's stage coordinator before any `xcodebuild test` or walk.

## Machinery notes

- The mockup workers were costly (round 1 about 730k tokens, round 2 about 490k). A later round should edit the existing files' frames in place and be scoped to the frames that changed.
- A worker live in the worktree commits by pathspec; so does the orchestrator. Never `git add -A` there.
- Copies of the mockups were put on her Air's Desktop at her ask (names prefixed `vx-1036-`); they are snapshots — refresh them when a file changes and she is reading on the Air.

## Paste-ready kickoff

> /architect-phase vx-1036 — you are taking over as architect/orchestrator from a session that reached its context seam. Read `notes/plans/vx-1036-orchestrator-handoff.md` first, then `notes/plans/vx-1036-organizing-inside-a-book.md` whole, in the worktree `~/dev/variorum-vx-1036`. The design is not closed and nothing is built: the design is closed (§4f) and nothing is built. Start from the handoff's open list: settle the umbrella composition with me, then write the first run's execution plan. Do not spawn an implementer before that plan is in the repo.
