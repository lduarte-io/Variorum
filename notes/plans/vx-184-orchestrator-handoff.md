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
- **HAND-FORWARDS FROM U4 (2026-10-13 ~05:55, its READY report):** (1) **U5's brief:** follow U4's
  extraction shape — `Operations+MCPNoteEdits.swift` / `MCPWriteTools+NoteEdits.swift` are the pattern
  (her door's row work extracted byte-for-byte, her doors re-pointed at the extraction, her suites
  passing unmodified as the parity proof); the `MCPWriteAct` cases + `MCPPaneCopy` words land in the
  same commit. (2) **U6's brief:** the pane/sheet explainers must reflect the edit rung's AS-BUILT
  reach — the grant sheet's edit sentence ("…with a commit before and after every change") and the
  toggle blurb UNDERSELL it now ("every change" only holds for text changes to a take, + restore_commit's
  brackets); words as built → VX-234. (3) **U7's brief:** the guide's lesson 3 Edit step + the
  instructions' edit-rung sentence are falsified-by-undersell (the kickoff names "the edit rung's
  description" as exactly this class); also note VX-148 honestly (deleted comments aren't readable on
  the wire, so restore_comment works on ids the client holds — its description says so). (4) U4's
  P-VX195-1 deviation (EVERY act one ⌥⌘Z, canon §12's contract line over the kickoff's literal clause)
  is PROVISIONAL'd for the ladder and her bundle — do not relitigate in later briefs; U5 follows the
  same posture and logs its own PROVISIONAL if its acts differ.
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

## U4 BRIEF — READY TO SEND (drafted 2026-10-13 ~04:15 while awaiting U3's stage GO)

Send verbatim as the U4 `opus-implementer` spawn prompt AFTER: (1) U3 closed in LIVE STATUS, (2) main
merged INTO the branch (fetch fresh first — VX-179's trailing ledger commits), (3) headless suites green
on the merged tree. Do not spawn before all three.

---

You are the U4 implementer for RUN VX-184 ("Run: MCP launch polish") — Opus, xhigh, ONE unit: **U4,
member VX-195 (edit parity inside a note, R-VX184-1 "as capable as her at the keyboard")**. Worktree
`~/dev/variorum-vx-184`, branch `vx-184-mcp-launch-polish` (run ALL work from that absolute path; never
the main checkout). Commits: `VX-195: … Part of VX-184`, NO attribution trailers, push after EVERY
commit. `notes/SessionResiliencyProtocol.md` binds you: your FIRST commit opens a "U4 UNIT RECORD"
section at the end of `notes/plans/fixes/vx-184-mcp-launch-polish.md` with a LIVE STATUS table (pieces,
flipped as they land), and every piece commits+pushes before the next begins.

PREFLIGHT (read in full, yourself, in this session — reading is never delegated): `CLAUDE.md` and its
auto-loaded canon; `notes/plans/mcp-launch-polish-kickoff.md` (BINDING — rulings R-VX184-0…6; your unit
is the table's U4 row); the run record `notes/plans/fixes/vx-184-mcp-launch-polish.md` (U1–U3's UNIT
RECORDs — especially U3's "For U4" note); `notes/plans/fixes/vx-168-mcp-client-secret.md` (U2's
edit-act pattern — YOUR pattern); `notes/plans/phase-13n-b-mcp-door.md` + the 13n-c plan
`notes/plans/phase-13n-c-mcp-launch-readiness.md` (the door's law and reach queries);
`notes/SessionResiliencyProtocol.md`; `notes/SyncSpec.md` BEFORE any schema-adjacent thought (you have
NO schema change — U3 used the run's one allowance; if you believe you need one, STOP that piece and
report). AppSpec §9 is your operations contract.

THE WORK — every act = an EXISTING §9 operation + the grant guard INSIDE the op's transaction + ONE
client-named undo entry (⌥⌘Z speaks the client's name); an act her own door makes undo-less stays
undo-less and the tool description SAYS so (VX-168 U2's pattern, run-wide):
- **Comments at edit:** edit/delete/restore ANY comment (not just own — the edit clause goes into
  `MCPWriteTools.mayDelete`; `Queries.mcpCommentAuthor` is the one read — U3's note). U3's suggest-rung
  own-comment road and her R-VX188-2 refusal sentence stay byte-unchanged for suggest callers.
- **Takes at edit:** delete (deleting a block's LAST take deletes the BLOCK — same road as delete_block,
  SAID in the receipt and the tool description; I10 holds because the block goes — R-VX184-1), archive,
  label, lock/unlock.
- **Commits at edit:** restore (INSURED first, exactly as her restore road is) and rename a message
  (her `renameCommitPoint` semantics: nil clears, no-op writes nothing, seal checked first, allowed on
  a locked take per QUESTIONS #121).
- **The note at edit:** rename its title; delete a saved lens.
Private/Seal/Own acts are HERS ALONE (R-VX184-2) — never minted as tools. Fence and refusal shapes:
the one not-shared answer for anything unreachable; `rungTooLow`-family for a live holder below edit;
no new oracle anywhere. Wording (descriptions, receipts, refusals, Activity lines, undo labels) ships
AS BUILT with a P-U4-WORDS provisional logged (QUESTIONS road, not VX-234 — that ticket is pane wording).

HARD RULES: zero `Sync/`, custody/keychain or editor-seam lines (verify by path diff and say so); zero
schema; pin-before-fix PER TOOL FAMILY, red on the pre-fix tree and red again by revert, counts
recorded; headless `swift build`/`swift test` freely; **every Mac batch / walk / live round ONLY under
the stage claim I relay** — build-for-testing headless, then end your turn READY FOR STAGE and wait for
my GO with the exact claim line. Live round (evidence of its kind, the kickoff's): ONE real Claude Code
turn exercising a representative act of EACH family, ⌥⌘Z walking each back, captured; dev store only
behind an A1 prestage copy, restored verified; never her real store, never her user-scope MCP
registrations. **The Debug app may greet launch with the What's New sheet (cross-run version flip) —
close it with its own button before any leg; expected modal, never a finding.** The one standing Mac
red everywhere is VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (pre-existing
on main — never attribute it to this run). NOTE: main (VX-179's comment-area polish) is merged into the
branch beneath you — verify comment-surface facts against the TREE, not against older records.

> **Autonomous mode.** Where the spec/model is ambiguous and it does NOT gate the phase's core: write
> the 2–3 options into the phase plan's closeout notes, implement the most spec-defensible one, mark it
> **PROVISIONAL**, and append the question to `notes/QUESTIONS.md`. If the ambiguity gates the phase's
> core, stop and report back instead.
> Never, under any circumstances: invent product behavior; violate or relax an invariant (I1–I10,
> P1–P3, S1–S5); add a new third-party dependency; contradict the canonical docs (record deltas in the
> closeout instead); touch anything requiring the author's accounts or credentials; delete or overwrite
> anything the author created; rewrite history or force-push (plain pushes per piece are REQUIRED — the
> resiliency protocol). Those are author-only calls — log to `notes/QUESTIONS.md` and report.
> Do not spawn subagents or use the Agent tool, with one exception: you may run at most ONE Sonnet
> lookup subagent at a time (spawn it with `model: "sonnet"`), strictly for external facts — web
> searches, Apple documentation, API signatures/availability. It returns facts and quotes; it never
> edits files and never spawns agents of its own. Never delegate reading of the repo's docs, the phase
> plan, code, or the diff under review — do that reading yourself, in this session.
> Report back with: what shipped, test counts, PROVISIONAL calls made, commits made, anything requiring
> the author. Write the phase plan's closeout detailed enough to be reviewed against the spec — a cold
> reviewer will do exactly that.

---

## U5 BRIEF — READY TO SEND (drafted 2026-10-13 ~06:00 while awaiting U4's stage GO)

Send verbatim as the U5 `opus-implementer` spawn prompt AFTER U4 is closed in LIVE STATUS (and after a
fresh merge-in IF main moved again — check `git fetch origin main` first; if merged, state the new
baseline counts in place of "U4's closed finals").

---

You are the U5 implementer for RUN VX-184 ("Run: MCP launch polish") — Opus, xhigh, ONE unit: **U5,
member VX-196 (edit parity across the library)**. Worktree `~/dev/variorum-vx-184`, branch
`vx-184-mcp-launch-polish` (run ALL work from that absolute path; never the main checkout). Commits:
`VX-196: … Part of VX-184`, NO attribution trailers, push after EVERY commit.
`notes/SessionResiliencyProtocol.md` binds you: your FIRST commit opens a "U5 UNIT RECORD" section at
the end of `notes/plans/fixes/vx-184-mcp-launch-polish.md` with a LIVE STATUS table, and every piece
commits+pushes before the next begins.

PREFLIGHT (read in full, yourself, in this session — reading is never delegated): `CLAUDE.md` and its
auto-loaded canon; `notes/plans/mcp-launch-polish-kickoff.md` (BINDING — your unit is the table's U5
row); the run record `notes/plans/fixes/vx-184-mcp-launch-polish.md` (U1–U4's UNIT RECORDs — U4's is
YOUR PATTERN: her door's row work extracted byte-for-byte into `Operations+MCPNoteEdits.swift` /
`MCPWriteTools+NoteEdits.swift`, her doors re-pointed at the extraction, her suites passing unmodified
as the parity proof; `MCPWriteAct` cases + `MCPPaneCopy` words in the same commit — follow that shape
for the library acts); `notes/plans/fixes/vx-168-mcp-client-secret.md`; `notes/plans/phase-13n-b-mcp-door.md`
+ `notes/plans/phase-13n-c-mcp-launch-readiness.md`; `notes/SessionResiliencyProtocol.md`;
`notes/SyncSpec.md` BEFORE any schema-adjacent thought (you have NO schema change — U3 used the run's
one allowance; if you believe you need one, STOP that piece and report). AppSpec §9 is your operations
contract — the library op families (readings, chapters, archive, the daily Journal's guards, the
Trash) are all §9's; invent nothing.

THE WORK (her picks, the kickoff's U5 row verbatim) — every act = an EXISTING §9 operation + the grant
guard INSIDE the op's transaction + ONE client-named undo entry (U4's P-VX195-1 posture: every act one
⌥⌘Z, argued from canon §12's contract line — follow it, and log your own PROVISIONAL if any library
act warrants differing, e.g. where her own door is deliberately undo-less like the wing move):
- **At edit on the book/wing:** take a note out of a book (reads "Release" on an owned book — her
  `removePostFromReading` semantics incl. the bookless return); reorder notes and chapters; rename/delete
  a chapter (curated only; her section ops' refusals ride); rename a book; finish/unfinish
  (`lockReading`/`unlockReading` — the finish dismisses pending arrivals in its transaction, the
  unfinish catch-up BELLS; a gathering refuses `wrongReadingKind`); archive/unarchive
  (`archiveReading`/`unarchiveReading` — R-13ie semantics ride whole); delete a book — **the daily
  Journal ARCHIVES, never deletes (its guards stand: `dailyJournalCannotBeDeleted` on the marker,
  inside the write)**, and an OWNED book's delete choices are HER ceremony — if the plain
  `deleteReading` refusal roads don't cover a case cleanly, refuse honestly and log it, never mint a
  ceremony tool.
- **At edit on the note:** delete (her Trash road — tombstone, 30 days, restorable) and
  archive/unarchive.
- **EXCLUDED (R-VX184-2, hers alone):** Private, Seal, Own — never minted as tools; sealing,
  unsealing, owning, `deleteReadingWithNotes`, `archiveReadingWithNotes` are HER doors only. Keep U4's
  Mac pin posture (no tool named for them) covering the library family too.
Fence and refusals: the one not-shared answer for anything unreachable; `rungTooLow`-family for a live
holder below edit; gatherings are FACTS under a wing grant, never a write target (R-AIR-12) — a write
aimed at a gathering refuses honestly; no new oracle anywhere. Wording ships AS BUILT with a
P-U5-WORDS provisional (QUESTIONS road, not VX-234).

HARD RULES: zero `Sync/`, custody/keychain or editor-seam lines (verify by path diff and say so); zero
schema; pin-before-fix PER TOOL FAMILY, red on the pre-fix tree and red again by revert, counts
recorded; headless `swift build`/`swift test` freely; **every Mac batch / walk / live round ONLY under
the stage claim I relay** — build-for-testing headless, then end your turn READY FOR STAGE and wait
for my GO with the exact claim line. Live round (the kickoff's): ONE real Claude Code turn exercising
a representative act of EACH family, ⌥⌘Z walking each back, captured; dev store only behind an A1
prestage copy, restored verified; never her real store, never her user-scope MCP registrations. **The
Debug app may greet launch with the What's New sheet — close it with its own button before any leg;
expected modal, never a finding.** The one standing Mac red everywhere is VX-115's
`BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (pre-existing on main — never attribute
it to this run). Your headless baseline is U4's closed finals (its UNIT RECORD's counts on this tree).

> **Autonomous mode.** Where the spec/model is ambiguous and it does NOT gate the phase's core: write
> the 2–3 options into the phase plan's closeout notes, implement the most spec-defensible one, mark it
> **PROVISIONAL**, and append the question to `notes/QUESTIONS.md`. If the ambiguity gates the phase's
> core, stop and report back instead.
> Never, under any circumstances: invent product behavior; violate or relax an invariant (I1–I10,
> P1–P3, S1–S5); add a new third-party dependency; contradict the canonical docs (record deltas in the
> closeout instead); touch anything requiring the author's accounts or credentials; delete or overwrite
> anything the author created; rewrite history or force-push (plain pushes per piece are REQUIRED — the
> resiliency protocol). Those are author-only calls — log to `notes/QUESTIONS.md` and report.
> Do not spawn subagents or use the Agent tool, with one exception: you may run at most ONE Sonnet
> lookup subagent at a time (spawn it with `model: "sonnet"`), strictly for external facts — web
> searches, Apple documentation, API signatures/availability. It returns facts and quotes; it never
> edits files and never spawns agents of its own. Never delegate reading of the repo's docs, the phase
> plan, code, or the diff under review — do that reading yourself, in this session.
> Report back with: what shipped, test counts, PROVISIONAL calls made, commits made, anything requiring
> the author. Write the phase plan's closeout detailed enough to be reviewed against the spec — a cold
> reviewer will do exactly that.

---

## U6 BRIEF — READY TO SEND (drafted 2026-10-13 ~09:15 while awaiting U5's redo GO)

Send verbatim as the U6 `opus-implementer` spawn prompt AFTER U5 is closed in LIVE STATUS (and after a
fresh merge-in IF main moved — vx-201 merges this morning; check `git fetch origin main` first and
re-verify headless green on the merged tree, then state the new baseline in place of "U5's closed
finals"). At U6's close, the orchestrator posts its FOR-VX-234 list to the Linear ticket.

---

You are the U6 implementer for RUN VX-184 ("Run: MCP launch polish") — Opus, xhigh, ONE unit: **U6,
members VX-199 (the MCP pane in tabs, R-VX184-6) + VX-205 (the setup command's code block, her add)**.
Worktree `~/dev/variorum-vx-184`, branch `vx-184-mcp-launch-polish` (ALL work from that absolute path).
Commits: `VX-199: …` / `VX-205: …` + `Part of VX-184`, NO attribution trailers, push after EVERY
commit. `notes/SessionResiliencyProtocol.md` binds you: FIRST commit opens a "U6 UNIT RECORD" at the
end of `notes/plans/fixes/vx-184-mcp-launch-polish.md` with a LIVE STATUS table; commit+push per piece.

PREFLIGHT (read in full, yourself — never delegated): `CLAUDE.md` + its auto-loaded canon;
`notes/plans/mcp-launch-polish-kickoff.md` (BINDING — R-VX184-6 verbatim + the run record's HER MID-RUN
ADD section carrying her VX-205 words verbatim); the run record `notes/plans/fixes/vx-184-mcp-launch-polish.md`
(U1–U5 UNIT RECORDs: U1's P-VX198-2 pane words, U4/U5's OWED → the edit-rung undersell; the tickets
table's VX-232 row); `notes/plans/phase-13n-c-mcp-launch-readiness.md` (the pane's current contract:
R-AIR-8's carve-out "Shared with AI", the Waiting section, Answer…, the setup menu's O-4 fence, the
one declared copy act); `notes/plans/phase-13n-b-mcp-door.md` (the pane's birth);
`notes/SessionResiliencyProtocol.md`. The pane code: `App/Variorum/Variorum/Features/MCP/` (MCPPane*,
MCPPaneCopy), `SettingsShape.swift` (MCP rows ONLY — see constraints), the pane suites (MCPPaneTests +
the faces suites).

THE WORK — **VX-199, R-VX184-6 (her pick, verbatim essentials):** the enable switch + status ON TOP;
**Waiting ABOVE the tabs** whenever asks are pending; tabs **Connect · Clients · Shared with AI ·
Activity**; the pane OPENS on Connect while no client is approved, else on Clients; every explainer cut
to ONE line with the full text behind an (i) popover. Her words: "just clicking on it, you wouldn't
know without scrolling down where the command to set it up is … as a settings pane, it has a LOT of
text." **VX-205 (her words, the run record's HER MID-RUN ADD — quote them in your record):** the setup
command renders in a standard UI code block with the copy icon in the upper right. The one declared
copy act's MEANING and the O-4 provider fence are untouched — the icon is a second door to the same
act, or the act's new face; argue the registry shape in your record and keep every existing pin's
meaning. **EVERY existing door and pin keeps working:** Answer…, ⌥⌘, landing on Waiting, the
Change…/Revoke rows, "all N ›", the setup menu's O-4 fence, the pending marks, Esc = Don't allow.
**The edit-rung words (U4/U5's OWED):** the grant sheet's edit sentence and the toggle blurb say "with
a commit before and after every change" — that now only holds for take text changes; bring the pane's
and sheet's explainer words to the AS-BUILT truth (U4's 12 acts, U5's 14, U3's batches/links — one
line each, full text in the (i) popover). **VERIFY VX-232** (the setup segment resets to Claude Code on
a voice flip while the receipt keeps the Any-client sentence): if your rebuild moots it, SAY SO in your
record with the proof (it closes with the run); if it still reproduces, fix it red-first (it's a Bug
ticket). **Wording rule (HER MANDATE):** ALL wording ships AS BUILT; write a "FOR VX-234" list in your
record naming every wording call you made (one line each, where it renders) — the orchestrator posts it
to her morning-review ticket; no QUESTIONS entry for pure pane wording (P-U6-WORDS covers the lot).

**ChromeLineLimitTests (red on main — VX-214's whole-target run, 2026-10-13 ~10:40):** 8 bare
`.fixedSize()` sites trip it; TWO are in your files — `MCPPane.swift:412` and `MCPGrantSheet.swift:285`
(line numbers as of main; re-locate after your edits). Fix BOTH in passing to the suite's own rule
(read `ChromeLineLimitTests` for the sanctioned form), prove the suite green for those two sites, and
name them in your hand-back — the orchestrator tells settingspaneupdater (it is ticketing all 8; ours
come off its list). Do NOT touch the other six sites (not ours).

CONSTRAINTS (cross-run agreements — recorded in the run record): `SettingsShape.swift` edits stay
scoped to the MCP rows ONLY (VX-214 owns the other panes' rows and merges AFTER us). The Settings
WINDOW SHELL is VX-214's (VX-225/224) — if you find yourself building shell chrome, STOP that piece
and report instead. If you mint a REUSABLE explainer-(i) component, report its name + home in your
hand-back (the orchestrator relays it to the settingspaneupdater session). Zero `Sync/`,
custody/keychain or editor-seam lines (path diff, say so); zero schema; zero server/wire changes (the
pane is faces — if a fix needs the wire, STOP and report).

EVIDENCE: pane truth suites + faces pins headless where they live; Mac batch + **the WALK in BOTH
voices (Terminal and Study), captured for her morning review** — the walk is this unit's evidence of
kind: the pane opened fresh (Connect) and with an approved client (Clients), Waiting above the tabs
with a pending ask, each tab, each (i) popover, the code block's copy icon pressed and the clipboard
pasted to prove the same copy act, Answer… and ⌥⌘, landing on Waiting, a Change…/Revoke row. All
stage work (Mac batch + walk) ONLY under the claim I relay: build-for-testing headless, end your turn
READY FOR STAGE, wait for my GO with the exact claim line (expect vx184-u6). Dev store only behind an
A1 prestage copy, restored verified. **The What's New sheet may greet the Debug launch — close it with
its own button; expected modal, never a finding.** The standing Mac red is VX-115's
`BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (pre-existing). Baseline: U5's closed
finals (its UNIT RECORD's counts).

> **Autonomous mode.** Where the spec/model is ambiguous and it does NOT gate the phase's core: write
> the 2–3 options into the phase plan's closeout notes, implement the most spec-defensible one, mark it
> **PROVISIONAL**, and append the question to `notes/QUESTIONS.md`. If the ambiguity gates the phase's
> core, stop and report back instead.
> Never, under any circumstances: invent product behavior; violate or relax an invariant (I1–I10,
> P1–P3, S1–S5); add a new third-party dependency; contradict the canonical docs (record deltas in the
> closeout instead); touch anything requiring the author's accounts or credentials; delete or overwrite
> anything the author created; rewrite history or force-push (plain pushes per piece are REQUIRED — the
> resiliency protocol). Those are author-only calls — log to `notes/QUESTIONS.md` and report.
> Do not spawn subagents or use the Agent tool, with one exception: you may run at most ONE Sonnet
> lookup subagent at a time (spawn it with `model: "sonnet"`), strictly for external facts — web
> searches, Apple documentation, API signatures/availability. It returns facts and quotes; it never
> edits files and never spawns agents of its own. Never delegate reading of the repo's docs, the phase
> plan, code, or the diff under review — do that reading yourself, in this session.
> Report back with: what shipped, test counts, PROVISIONAL calls made, commits made, anything requiring
> the author. Write the phase plan's closeout detailed enough to be reviewed against the spec — a cold
> reviewer will do exactly that.

---

## Known cross-run facts

- **VX-179 MERGED to main (PR #154, d6caafc1)** — merged INTO this branch at the U3→U4 boundary
  (a79dbf6a + repair 018cf23c; suites green). DONE.
- **ORCHESTRATOR MODEL SWITCH (her word, 2026-10-13 ~10:30):** she hit her Fable usage limit, which
  stopped this session mid-turn; she ran `/model Opus` and said *"I want you to continue where you
  were as Opus."* This session now orchestrates on **Opus 5.5** — same session, same protocol. **THE
  LADDER QUESTION (surfaced to her):** the run's cold review is ruled `fable-reviewer` (the kickoff:
  the socket road is the secret's accept path and the permission core grows). If her Fable limit
  still blocks when U7 closes, a Fable reviewer will die the same way. Options: (a) wait for the Fable
  reset, then run the ladder as ruled; (b) her redirect to `opus-reviewer` (her call alone; CLAUDE.md
  reserves Fable for `Sync/`, custody or the editor seam, and this diff has none of those, but the
  kickoff named Fable deliberately). NEVER switch the reviewer without her word. If she hasn't
  answered by then, try `fable-reviewer`; if it dies on the limit, hold the ladder and report.
- **VX-201 MERGED and MERGED IN:** main merged INTO the branch at **e5c9c719** (U5→U6 boundary;
  clean, no conflicts). It brings VX-201's Castle/custody code into the branch: StoreLaunchGate,
  ProtectionController, LibraryAdoption, LibraryAsideCopies, ProtectionPane, AppSettingsView, plus
  **a 6-line TutorialSeeder change (VX-204's amended lesson 1 / VX-209's guide warning) that U7 must
  build on, not overwrite**. QUESTIONS: VX-179 took #215, VX-201 took **#216**, so ours takes the
  next free number. VX-201's /Applications refresh was **folded into VX-214's** — ask the
  coordinator at our merge whether ours folds too. The dev store goes back to STANDARD posture via
  vx-201's passphrase window before U5's live round (W-1's Castle copy set aside, hers, never
  delete it). ChromeLineLimitTests is red on main (8 bare `.fixedSize()` sites, VX-214 ticketing all
  8); our two (MCPPane, MCPGrantSheet) are in U6's brief to fix in passing. Tell settingspaneupdater
  at U6's close.
- **VX-201 MERGED to main (PR #155, d2b133fb + ledgers — coordinator's word, 2026-10-13 ~10:15).**
  Merge main in at the U5→U6 boundary (NOT mid-U5 — its Mac batch runs test-without-building on
  products built from the current tip). It brings vx-201's custody/Castle code into the branch —
  harmless for this run (we touch no custody), but RE-RUN HEADLESS after the merge-in and watch the
  QUESTIONS tail (vx-201's ledgers likely took #216; ours takes the next free at closeout). The dev
  store is in CASTLE POSTURE since vx-201's walk (older restore rows read "No key file serves this
  copy") — U5 prestages/restores that state as-is; later units inherit it.
- VX-214 (settingspaneupdater) may now also merge before us (its reviewer's gating run went ~10:10) —
  if so, same road: merge main in at the next boundary; U6's SettingsShape work then lands on its
  as-merged shell.
- vx-201 (Castle pre-launch fixes) owns VX-191's close and her carried Castle notes (routed; confirmed).
- VX-214 (settingspaneupdater) merges AFTER us, rebases/merges onto us; owns Settings window shell.
- The `variorum` MCP server shows CONNECTION_CLOSED in sessions while her app is closed — expected
  (that's VX-181's own symptom), not a defect of this run.
- Disk: was at 99%; I freed ~36 GB (closed efforts' DerivedData). Don't touch LIVE efforts' worktrees
  (vx-179, vx-201, vx-214).
