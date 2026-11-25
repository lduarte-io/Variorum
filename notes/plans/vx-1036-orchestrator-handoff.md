# VX-1036 — orchestrator handoff (written 2026-11-24, at the first orchestrator's context seam)

**For:** the session that takes the architect/orchestrator role for VX-1036 next. **Shape:** `/architect-phase vx-1036`. **Read whole:** `notes/plans/vx-1036-organizing-inside-a-book.md` (the effort is open — whole, not only its first section).

## The role, as it stands

- Architect and orchestrator for the umbrella VX-1036, under her word at kickoff: "we will finish the design plans together before you do any building." **The design is not closed. Nothing is built. No implementer has been spawned; no stage has been claimed.**
- You never implement (CLAUDE.md's cast rule). Mockups have been drawn by one worker at a time from a brief written into the plan file first (§4c, §4e): round 1 by a Fable subagent at her explicit word for that round, round 2 by an Opus worker. The standing rule is Opus or Sonnet for subagents, the model always named.
- Her rules that have already bitten once here: repo notes carry the FEATURE only — nothing personal from notes or screenshots she shares (her real note titles and tags never enter the repo or a mockup; sample content is invented); she never wants an Artifact — local self-contained HTML and the full path; every message of hers is answered point by point in her words; no time estimates; a ticket id comes only from a `save_issue` result.

## State at cutover — verify, do not trust

- Branch `vx-1036-organizing-inside-a-book`, worktree `~/dev/variorum-vx-1036` (Pro), in sync with origin at the commit that added this file. The in-flight row is on main. The branch was rewritten ONCE at her word (its first two commits became one); that word covered that rewrite only.
- Members (list the sub-issues of VX-1036 on Linear — the listing is the roster, never a description): VX-1037 lanes · VX-1038 tags inside a book · VX-1039 the new-note defect and landing · VX-1040 the order dial · VX-1041 wings · VX-881 titles in Read · VX-1026 the wire's book order · VX-1078 tags on a quick note · VX-1079 lanes on the wire · VX-1080 the radio-scroll title · VX-1081 the pill's ×.
- The rulings are R-1036-1…28 in the plan's §5. The design is §4b as amended by §4d (where they differ, §4d stands).
- The mockups: `notes/plans/vx-1036/mockup-1-book-and-lanes.html`, `mockup-2-wings.html` (round 1), `mockup-3-round-2.html` (round 2). Each takes `?theme=dark` and `?only=<frame id>`; render off-screen with headless Chrome into the scratchpad to look — never open a window on her screen.
- One schema event is accepted in principle (R-1036-5: the lanes column on `reading`); its mirror deploy runs only at her explicit go, in one window with both Macs and the phone. Wings' choices are planned as synced `setting` keys — no event.

## Open with her (sitting 3 opens on the round-2 mockup)

1. The lane-move rule (§4d's four steps) and the refusal when a lane leaves out a tag the note wears.
2. A List mode for the book (R-1036-28, her own idea, asked not ruled): BL-4's A or B, and where a fifth mode goes — round 2 found the mode row and the Library row both want more width than the navigator's 300 pt leaves.
3. In a laned gathering, which pills a note leaves off (T-6).
4. The title scroll: always, or only under the pointer and on the live note (T-2). The weight of a title in Read (RT-1).
5. The order dial as drawn in round 1 (D-1) — she ruled it with doubt and has not spoken to the drawing.
6. Wings: whether the one "take part" switch also decides who is in the All Wings Library; whether the search band's wing chip stays; Home reordered and coloured like the rest; her one star order in all-wings Starred.
7. Which capture doors "quick note creation" means (Q-1).
8. The PROPOSED lines of §4b she has not spoken to: the empty lane, the move's undo entry, the lane doors, bind → chapters.
9. The cut into runs when the design closes (the ledger's sizing line), and the cast for the lanes run (it carries a `Sync/` constant and a §12 event — Fable cold-reviews; who implements is her call).

## Owed before the first implementer spawn

- Build preflight in full (the plan's §8): `notes/QUESTIONS.md`, the board snapshot, `notes/SessionResiliencyProtocol.md`, `notes/plans/workflow-transition-2026-10-06.md`, `notes/PhaseSizingGuidance.md`, `notes/MobileSoul.md`; `notes/SyncSpec.md` in full for the lanes column; `notes/MCPSpec.md` in full for VX-1079 and VX-1026; `notes/SurfaceContracts.md` for the Library, the Bookcase and books, the note, and Doors.
- A per-run execution plan with its acceptance units and their evidence named; pins before fixes (VX-1039's trace in §3a is by reading only); the MOBILE PARITY rows; announce to the day's stage coordinator before any `xcodebuild test` or walk.

## Machinery notes

- The mockup workers were costly (round 1 about 730k tokens, round 2 about 490k). A later round should edit the existing files' frames in place and be scoped to the frames that changed.
- A worker live in the worktree commits by pathspec; so does the orchestrator. Never `git add -A` there.
- Copies of the mockups were put on her Air's Desktop at her ask (names prefixed `vx-1036-`); they are snapshots — refresh them when a file changes and she is reading on the Air.

## Paste-ready kickoff

> /architect-phase vx-1036 — you are taking over as architect/orchestrator from a session that reached its context seam. Read `notes/plans/vx-1036-orchestrator-handoff.md` first, then `notes/plans/vx-1036-organizing-inside-a-book.md` whole, in the worktree `~/dev/variorum-vx-1036`. The design is not closed and nothing is built: open sitting 3 with me on the round-2 mockup and the handoff's open list. Do not spawn an implementer until I close the design.
