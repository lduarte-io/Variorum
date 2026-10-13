# VX-184 — orchestrator handoff / resume map (written pre-compaction, 2026-10-13 ~03:10 MDT)

**For the vx-184 orchestrator session (Fable, /run-phase) resuming after compaction — or any fresh
successor.** The repo is the memory: read this file, then the RUN RECORD's LIVE STATUS
(`notes/plans/fixes/vx-184-mcp-launch-polish.md` — the truth for unit state), then the BINDING plan
(`notes/plans/mcp-launch-polish-kickoff.md` — her rulings R-VX184-0…6, R-VX185-1, R-VX187-1,
R-VX188-1/2, the unit table, the closeout/handoff requirements). Do NOT redo preflight reading beyond
those three plus anything a unit's brief names — U1/U2 are closed and verified; trust their records.

## Who/where

- Session name `vx-184` (the author addresses it by that name; peers message it). Orchestrator only —
  never writes feature code. Cast: `opus-implementer` per unit (ONE at a time, strictly sequential),
  `fable-reviewer` for ONE ladder over the whole run's diff after U7 (cap three rounds, fresh reviewer
  per round, `notes/REVIEW_PROMPT.md` verbatim with zero framing — the cross-model flow: findings to
  the implementer verbatim, agree/dispute back to the reviewer, reviewer makes the final call and
  implements its confirmed fixes itself, then suite green + one implementer sanity pass).
- Worktree `~/dev/variorum-vx-184`, branch `vx-184-mcp-launch-polish` (tracking origin). Main checkout
  `~/dev/variorum` stays on main; never commit from it (exceptions already made: the in-flight row and
  board snapshot, per the rules).
- Commits: member id + `Part of VX-184`, NO attribution trailers, push after every commit.
- Linear: the MCP needs browser OAuth (unavailable) — use `~/.variorum/linear.key` with the GraphQL API
  (the proven road this run; the Keychain item is not visible to this session). All member tickets are
  In Progress; members close one by one at the merge (Done rides the PR).
- Memory run-state: `vx-184-run-state.md` in the shared memory repo (commit+push after updates).

## Her mandates (recorded in the run record too)

1. **Goodnight mandate (she is ASLEEP):** run all the way through the night, culminating in the
   /Applications refresh. Autonomous; PROVISIONAL-and-log; stop only a member that truly gates.
2. **Nothing drops (R-VX184-0);** the unit order is the build order. U7 is NEVER a fall-out.
3. **Merge rule (her word):** if another effort merges main first, merge main INTO this branch, then
   merge ours (merge commits only, never squash/rebase-merge). Closeouts serialize across sessions.
4. **U6 wording → VX-234:** ALL U6 wording PROVISIONALs route to ticket VX-234 (her morning pane-wording
   review; its description already carries U1/U2's pane wording items). U6 ships words AS BUILT and
   appends its items to VX-234 at its close.
5. **The launch gate (R-VX184-4):** the stargazing.tech/variorum/mcp page must be LIVE before the build
   ships. U7 appends a DELTA to `notes/stargazing-mcp-guide-brief-2026-10-12.md` (facts the build
   changed + final tool names). The author handoff's checklist LEADS with carrying that brief/delta to
   her site agent BEFORE the build ships.
   **Her post-compaction word (2026-10-13 ~03:20): she is WAITING to send that message to the site
   agent until this round completes** — so at the round's end the brief file must read as ONE complete,
   send-ready message reflecting the AS-BUILT truth (U7's DELTA integrated or appended coherently, final
   tool names, nothing stale). The orchestrator verifies this at closeout before the checkpoint report;
   it is not optional and not satisfied by a raw delta that needs hand-assembly.

## Stage protocol (oct12coordinator — a peer session; ALL stage traffic through it)

REQUEST (what + minutes + claim name, early) → READY (separate ping, only when actually built) → its GO
(it hands the stage over with an exact claim line to run) → run under the claim → RELEASE + ONE result
line to it. A FREE stage is never a go-ahead. Headless swift build/test and xcodebuild BUILD never need
the stage. She is away all night — walks/live rounds need no extra check. Claim names so far:
vx184-u1 (done), vx184-u2 (done); U3's REQUEST is BOOKED as vx184-u3 (~35 min). **Walk heads-up
(coordinator, 2026-10-13 ~03:30, relayed to U3 and owed to every later unit's brief):** the Debug app
may greet a launch with the What's New sheet — it keys on the marketing version in the shared dev
defaults domain, and VX-179's 0.9.3 branch alternating with 0.9.4 builds keeps flipping it; close it
with its own button (cliclick fine) before any walk/live-round leg. Expected modal, never a finding.
At OUR MERGE: send the coordinator the refresh ask — it may FOLD refreshes from several runs into ONE window from merged main
(defer to its call; if we run it: A1 safety copy incl. key files → Release build → /Applications →
codesign verify → acceptance below).

## State at compaction (verify against the RUN RECORD's LIVE STATUS — it outranks this snapshot)

- **U1 CLOSED** (socket/key road: VX-132 harness time limits + SIGPIPE fix; VX-181 shim window —
  "Variorum must be open" on the initialize id; over-cap `-32000` on `id:null` answers + exact 16 MiB
  cap + linear reader; VX-198 newest-copy re-bind). Live round proven with real Claude Code; 300-block
  224 KB round-trip byte-equal. PROVISIONALs: P-VX198-1 (replaced-key memory in the activity log),
  P-VX198-2 (words → VX-234/copy pass), P-U1-OVERCAP (answer shape; strict-client id:null behavior
  recorded from the live round).
- **U2 CLOSED** (VX-185 gatherings icon: `mcpBookReaches` covers gatherings via `decideGathering`; zero
  app-behavior change; fixture `wing=2`). Walk proven both voices; her reported case fixed. PROVISIONALs
  P-VX185-1/2 both (a) with my recorded rationale. Mac batches: the ONE standing red everywhere is
  VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (pre-existing on main — never
  attribute it to this run).
- **U3 IN FLIGHT** (door ergonomics: VX-186 read_note dedupe · VX-173 add_takes/add_comments batches ·
  VX-188 suggest-rung own-comment delete + THE one allowed schema change (LOCAL-ONLY comment-authorship
  record, grants-family road, own commit, marker 13 untouched) · VX-190 remove_tag · VX-187
  link_versions, write-new on BOTH notes). Its implementer is a background subagent of this session; it
  ends its turn READY FOR STAGE, then needs my GO with the coordinator's claim line. Her RULED refusal
  sentence (R-VX188-2, verbatim): "You don't have permission to delete that comment. Suggest raising
  your permission level to edit." Live round legs: batch-as-one-undo · 20-block read_note no duplicate ·
  link_versions pairs Compare · own-comment delete + ruled refusal on the wire.
  **If the subagent handle is lost post-compaction:** check `git -C ~/dev/variorum-vx-184 log --oneline`
  and the U3 UNIT RECORD's LIVE STATUS; ListAgents shows live subagents; a still-running implementer
  gets a MESSAGE, never a twin; if truly dead, spawn a narrow continuation briefed ONLY from the record
  + `git diff` (the resiliency protocol's recovery road — never redo blind, never discard a dirty tree).
- **U4–U7 NOT STARTED.** The briefs' essentials:
  - **U4 (VX-195, edit parity inside a note — R-VX184-1 "as capable as her at the keyboard"):** comments
    edit/delete/restore ANY at edit (consult U3's authorship record design); takes — delete (deleting a
    block's LAST take deletes the BLOCK, same road as delete_block, said in the receipt and the tool
    description — I10 holds because the block goes), archive, label, lock/unlock; commits — restore
    (INSURED first, as her restore is) and rename a message; the note — rename title, delete a saved
    lens. Every act = existing §9 op + grant guard in-transaction + ONE client-named undo entry (an act
    her door makes undo-less stays undo-less and the description says so — VX-168 U2's pattern). Live
    round: one real-client turn per family, ⌥⌘Z walking each back.
  - **U5 (VX-196, edit parity across the library):** at edit on book/wing — remove a note from a book
    (Release on owned), reorder notes and chapters, rename/delete a chapter, rename book,
    finish/unfinish, archive/unarchive, delete a book (the daily Journal ARCHIVES, never deletes — its
    guards stand); at edit on the note — delete (Trash, 30 days) and archive/unarchive. Private/Seal/Own
    EXCLUDED (R-VX184-2 — hers alone). Same op+guard+one-undo pattern; same live-round shape.
  - **U6 (VX-199 + VX-205, the MCP pane):** R-VX184-6 — enable switch + status on top; Waiting ABOVE the
    tabs when asks pend; tabs Connect · Clients · Shared with AI · Activity; opens on Connect while no
    client approved, else Clients; every explainer one line + full text behind an (i) popover. VX-205
    (her add): the setup command in a standard UI code block, copy icon upper right (the one declared
    copy act's meaning and the O-4 provider fence unchanged). Every existing door and pin kept working
    (Answer…, ⌥⌘,, landing on Waiting, Change…/Revoke rows, "all N ›", the setup menu's O-4 fence).
    CONSTRAINTS from cross-run agreement (recorded in the run record): `SettingsShape.swift` edits
    scoped to the MCP rows ONLY (VX-214 owns the other panes' rows); the Settings WINDOW SHELL is
    VX-214's (VX-225/224) — flag before building any shell chrome; if a reusable explainer-(i) component
    is minted, its name+home go to the settingspaneupdater session. VERIFY VX-232 (voice flip resets the
    setup segment while the receipt keeps the Any-client sentence) is mooted by the rebuild — closes
    with the run if so. Wording PROVISIONALs → appended to VX-234, built as-built. Walk both voices,
    captured for her morning review.
  - **U7 (VX-197, the AI's docs — LAST, truth pass over AS-BUILT):** the field guide's MCP chapter gets
    13s's quality pass (sentence case, no shouty caps, calm voice, lesson 1's "way in" repetition);
    ORGANIZATION encouraged explicitly (recipes: notes/books/chapters/tags/collecting books);
    every tool this run added taught in its lesson; Private/Seal/Own explained as hers alone
    (R-VX184-2); lesson 7's icon sentence says "a book or a gathering" (U2's carry); any sentence a unit
    falsified. `MCPSession.instructions`: bound raised 2,000 → 3,000 (R-VX184-3 — `instructionsBound`
    and its pin move together); organization advice; R-VX184-2 awareness; the edit rung's new reach; ONE
    sentence linking https://stargazing.tech/variorum/mcp (exactly that URL). Provider-neutral (O-4),
    truth-pinned. Appends the DELTA to the stargazing brief file. Re-seed note for the handoff: her
    store gains the updated chapter only via Help ▸ Restore Tutorial… (tombstones the old guide, says
    so).
- **THEN:** the fable ladder (one ladder, whole-run diff, cap 3; pin-before-fix per member; Fable
  because the diff includes the secret's accept path and the permission core). Then closeout.

## Tickets minted this run (the handoff LISTS ALL — her ask; table also in the run record)

VX-205 (her add → U6 member) · VX-230 (first-block take badge dark/black after MCP writes — HER
real-store sighting recorded in the ticket, **Pre-launch** at her word; NOT in-run) · VX-231 (stale
Bookcase counts after a 32k-word add; NOT in-run) · VX-232 (pane segment reset on voice flip — U6
verifies; closes with the run if mooted). Plus whatever later units mint — keep the run record's table
current.

## Closeout checklist (the kickoff file's + the standing ritual; serialize with other efforts)

1. U7 done → spawn the fable ladder (REVIEW_PROMPT verbatim; rounds as the skill prescribes).
2. All dispositions in the run record; QUESTIONS gets ONE ratify bundle entry (next free number — check
   the tail marker; #214 was the last at kickoff) carrying EVERY PROVISIONAL: U1's three, U2's two,
   U3–U7's; P-VX185 items note VX-234 where wording.
3. Canon deltas at the merge, on latest main, by this session (the kickoff lists them): AppSpec §12 THE
   MCP DOOR line — instructions bound ≤3,000 (R-VX184-3); the edit rung's new act families + last-take
   rule (R-VX184-1) and the three hers-alone acts (R-VX184-2); the suggest rung's own-comment delete +
   its local record (§7's grants family gains the new table/version); link_versions, remove_tag, the
   batch tools, read_note's new shape; the shim's VX-181 window; A-4's boundary amended for
   newest-copy-wins (R-VX184-5); the pane's tabs (R-VX184-6); the gatherings-icon line (R-VX185-1).
   §14's entry per the house pattern (roll the oldest §14 entry to the archive per the standing rule).
4. Merge moment: `git -C ~/dev/variorum-vx-184 merge main` FIRST (her rule) if main moved; suites green
   on the merged tree (the Mac run covers suites exercising every changed SOURCE file — the 13x lesson);
   PR `VX-184: Run — MCP launch polish` (body ends with the harness attribution line for PRs), MERGE
   COMMIT; then on latest main: QUESTIONS bundle, canon deltas, master-plan in-flight row retired +
   closeout paragraph, board snapshot (`Tools/vx sync` + commit "board snapshot" + push), MOBILE PARITY
   line (expect "nothing mobile-visible — the door is Mac-only", but confirm against U5/U7), tickets
   closed in Linear (all members + VX-232 if mooted; VX-184 itself).
5. The /Applications refresh: ASK the coordinator at the merge (it may fold several runs into one
   window). Acceptance AFTER the refresh (the kickoff's): a bridge-free `claude mcp list` (Connected)
   + ONE real tool call against the refreshed install. Never quit or kill a running real-store instance
   (she says it won't be running; verify anyway). A1 safety copy incl. key files first, codesign verify.
6. The author handoff `notes/handoffs/vx-184-handoff.md` — HER CHECKLIST AT TOP, leading with: (1) carry
   the stargazing brief + U7's DELTA to the site agent BEFORE the build ships (the page must be live —
   launch gate; she holds the send until the round completes, so the brief file must be send-ready as
   one message — verified at closeout per mandate 5); (2) re-run the pane's Claude Code setup on the Air to retire the bridge (+ tell the
   beta tester); (3) Help ▸ Restore Tutorial… for the new chapter (says what it tombstones); (4) the
   PROVISIONALs + VX-234's wording list; (5) ALL tickets minted this run (the table). Self-contained
   for a fresh session.
7. Build-debris tidy (this run's DerivedData/vx184-* + gitignored evidence after merge), worktree
   removed, branch deleted (GitHub + local), run-record STATUS banner flipped CLOSED, memory run-state
   flipped CLOSED (+MEMORY.md line), final checkpoint report in chat leading with what shipped + counts.
8. HARD STOP after this run. (Her VX-181 launch-gate call is ANSWERED by this run — it's a U1 member.)

## Known cross-run facts

- **VX-179 MERGED to main (PR #154, merge commit d6caafc1 — coordinator's word, 2026-10-13 ~03:40;
  its ledger commits follow on main shortly).** Her rule applies: merge main INTO this branch before
  ours. **The plan: do the merge-in at the U3→U4 boundary** (never under a live implementer — fetch
  fresh so the trailing ledger commits ride, merge, headless suites green on the merged tree, THEN
  spawn U4). VX-179 touched the comment area and U4 touches comment ops — merging before U4 is
  deliberate. Main may move again (vx-201, others): re-check and merge-in again at our merge moment.
- vx-201 (Castle pre-launch fixes) owns VX-191's close and her carried Castle notes (routed; confirmed).
- VX-214 (settingspaneupdater) merges AFTER us, rebases/merges onto us; owns Settings window shell.
- The `variorum` MCP server shows CONNECTION_CLOSED in sessions while her app is closed — expected
  (that's VX-181's own symptom), not a defect of this run.
- Disk: was at 99%; I freed ~36 GB (closed efforts' DerivedData). Don't touch LIVE efforts' worktrees
  (vx-179, vx-201, vx-214).
