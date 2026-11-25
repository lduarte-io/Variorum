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

The cut is approved (R-1036-44): **VX-1036 — Inside a book** (VX-1039, VX-1040, VX-881, VX-1080, VX-1081, VX-1038, VX-1084, VX-1078) · **VX-1085 — Lanes in gatherings** (VX-1037, VX-1079, VX-1026; the §12 event; Fable cold review) · **VX-1086 — Wings** (VX-1041, VX-1087, VX-1088). List each umbrella's sub-issues on Linear at kickoff — that listing is the roster. The plan file is the one design record for all three and reaches main by a docs-only PR (R-1036-45); each umbrella writes its own execution plan and takes its own branch, worktree and in-flight row at its kickoff (VX-1036 keeps this branch and worktree).

Open with her:
1. The order the umbrellas run in (proposed: VX-1036, then VX-1085, VX-1086 beside either) and who kicks each off.
2. The add-tag chord (at the build) and the lanes run's cast (at its kickoff).
3. Four faces exist only in words (§4f's list); each is shown to her at its run's first walk.
4. Ticket bodies are pointers and some still say "drawn for her to choose"; the plan's §5 is the truth.

## Owed before the first implementer spawn

- Build preflight in full (the plan's §8): `notes/QUESTIONS.md`, the board snapshot, `notes/SessionResiliencyProtocol.md`, `notes/plans/workflow-transition-2026-10-06.md`, `notes/PhaseSizingGuidance.md`, `notes/MobileSoul.md`; `notes/SyncSpec.md` in full for the lanes column; `notes/MCPSpec.md` in full for VX-1079 and VX-1026; `notes/SurfaceContracts.md` for the Library, the Bookcase and books, the note, and Doors.
- A per-run execution plan with its acceptance units and their evidence named; pins before fixes (VX-1039's trace in §3a is by reading only); the MOBILE PARITY rows; announce to the day's stage coordinator before any `xcodebuild test` or walk.

## Machinery notes

- The mockup workers were costly (round 1 about 730k tokens, round 2 about 490k). A later round should edit the existing files' frames in place and be scoped to the frames that changed.
- A worker live in the worktree commits by pathspec; so does the orchestrator. Never `git add -A` there.
- Copies of the mockups were put on her Air's Desktop at her ask (names prefixed `vx-1036-`); they are snapshots — refresh them when a file changes and she is reading on the Air.

## Paste-ready kickoff

For VX-1036 (inside a book):

> /architect-phase vx-1036 — you are taking over as architect/orchestrator from a session that reached its context seam. Read `notes/plans/vx-1036-orchestrator-handoff.md` first, then `notes/plans/vx-1036-organizing-inside-a-book.md` whole, in the worktree `~/dev/variorum-vx-1036`. The design is closed (§4f) and nothing is built. This umbrella is the book view: list its sub-issues on Linear for the roster. Write its execution plan first and bring me its batches and their evidence. Do not spawn an implementer before that plan is in the repo.

For VX-1085 (lanes) or VX-1086 (wings), the same line with that id and without the worktree clause — each takes its own branch, worktree and in-flight row at kickoff and reads the design record from main.
