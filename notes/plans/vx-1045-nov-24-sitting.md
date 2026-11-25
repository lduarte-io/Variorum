# VX-1045 — the Nov 24 sitting: the VX-980 and VX-981 bundles, the coordinator handoff, the Ambient merge, the 1.5 release

**Ticket: VX-1045 · Branch: `vx-1045-nov-24-sitting` · Worktree: `~/dev/variorum-vx-1045` · the Pro**

## FOR A LATER READER

*(Kept current while the sitting runs; rewritten at its close.)*

- **Done:** PR #8 (VX-997, the Variorum side of the Ambient app) merged at her word, merge commit `703c42173`, and
  cleaned up. A Linear label "Ambient" sits on all fourteen Ambient tickets. VX-1013 (the slow open) sized with
  measurements; now High, Todo. Apple's agreement accepted by her; the notary service answers again.
- **Ruled (her words below, "Her rulings"):** QUESTIONS #276 and #278 are closed but for the wording pass and
  VX-370; the parity audit became the umbrella VX-1046 (twenty-seven members, all Todo at her word) plus VX-1068
  (Snippets, Needs Lillian); its twelve exceptions are stated in `notes/MCPSpec.md`; the coordinator skill gained the
  five lines the 2026-11-22 coordinator proposed; VX-1026 rides VX-1036; VX-460 closed; VX-1017 parked.
- **The 1.5 release's step 0: PASSED** on the code of `703c42173`, 2026-11-24 17:47–17:54, under stage coordinator
  `nov24` (claim `vx-1045`): FirstRunDrillTests 11 of 11, the first-run walk green in both arms, the dev slot back
  byte for byte. The evidence lines are in "The release's step 0" below.
- **Order from here:** her approval of the notes and label, then this branch's first PR merges (it carries the
  ignore line the release's clean-tree check needs), then the release run, then the sitting's close.
- **Still hers before 1.5 is built:** the 1.5 notes and label (put to her in chat for approval).
- **Canon touched on this branch:** `notes/SurfaceContracts.md` and `notes/MCPSpec.md` (the ratified calls lose the
  word PROVISIONAL; the stated exceptions added beside the audit's pointer); `notes/QUESTIONS.md` (two addenda).
  Neither spec file is in the loaded set.

## Her words (2026-11-24, verbatim)

Opening the sitting:

"hello fable I want us to handle handoffs from recent VX sessions, get the latest apple agreement signed (where do I
even see that? I opened xcode and did not see it), then once the handoffs are handled, get 1.5 released. I also want
to get the new ambient PR merged - I'm pleased with the ambient app improvements. there were tickets filed for it -
make sure those are tagged "ambient" or something of the sort in Linear. PR #8: still held at your word; it now
carries the coordinator skill's updated Ambient lines"

On VX-1013, quoting the VX-980 handoff's "Slow first launch" lines: "I want to understand how big of an issue this
ticket is"

On the VX-981 handoff: "I might want to handle things like the list order in my upcoming umbrella on book
improvements - not 100% sure on that"

A little later, with the 2026-11-22 coordinator's closing message pasted: "I also was given this by the coordinator -
what are those stage coordinator improvements? we need to handle this as well"

## What was done

### PR #8 (VX-997), merged

Her word is the first quote above. Before the merge, on the Pro: `~/dev/ambient` on its main and level with its
origin; `/Applications/Ambient.app` at build 525; the branch's `Tools/ambient status` answering `OFF` through the
thin door; both scripts parsing; a trial merge with main clean. Main was merged into the branch, the in-flight row
retired and the record's top updated on the branch (`c5a322755`), the PR marked ready and merged with a merge
commit (`703c42173`). After it: main pulled; `Tools/StageAmbient/` (only its ignored build folder was left) removed
from the main checkout; the worktree `~/dev/variorum-vx-997` and the branch removed, locally and on the remote;
`Tools/ambient status` on main answers `OFF`.

Linear closed VX-997 by itself at the merge. Its open members stay seated under it: VX-531, VX-1042, VX-1043,
VX-1044 (all Low, Backlog) and VX-460 (In Progress).

### The Ambient label

A workspace label "Ambient", outside the Area group (that group is single-select and its list is CLAUDE.md's), so it
sits beside a ticket's Area. On: VX-997, VX-1035, VX-1008, VX-1001, VX-1002, VX-1003, VX-1004, VX-1042, VX-1043,
VX-1044, VX-531, VX-460, VX-459, VX-458.

### VX-1013, sized

**The road, read in the code.** Every open (a launch, an unlock, a retry) gathers the protection facts before it
decides anything: `AppBootstrap.beginOpening` → `ProtectionOpenRoad` → `ProtectionFactsGatherer.facts`, whose first
line builds the catalogue (`CatalogLister.catalog()`). The lister reads the whole bytes of every key file under the
library's own `Backups/` and `Previous Libraries/` and under the second backup folder's `Backups/`, one after the
other (`CatalogLister.entry`, `Data(contentsOf:)`). The work is off the main thread, so the app is not frozen, but
nothing draws until it ends. Its cost follows the number of backup copies kept (one key file each), never the size
of the library.

**Measured on the Pro, 2026-11-24, load about 4, online.**

| Folder | Key files | Evicted by iCloud at the time |
|---|---|---|
| The real library's own `Backups/` and `Previous Libraries/` (local disk) | 10, counted by name | none (local) |
| The real second folder, an iCloud Drive folder | 23 | all 23 |
| The dev store's second folder, an iCloud Drive folder | 80 under `Backups/` | none of the key files (95 other files were) |

Three of the real folder's evicted key files, read to nowhere from a shell, took 0.92 s, 0.62 s and 1.05 s each: the
read waits for iCloud to bring the file back. So the first open of the real library after an eviction waits roughly
a second per backup copy before anything draws, about twenty seconds for today's twenty-three, on a quiet Mac that
is online. The nine-minute case was the same road over the dev store's folder (about 155 files, some 80 of them key
files, the only ones whose bytes are read) with the Mac at a load near 100. Once read,
the files stay on the Mac until macOS evicts them again, which is why the next launch that night took ten seconds.

**Not measured:** an open with the folder evicted and the Mac offline (whether each read fails at once or waits out
a timeout); a folder on a network share or a sleeping external disk.

**Reading of its size.** No words are at risk and nothing is written wrongly. What it costs is the open: the wait
grows by one read with every backup the second folder keeps, and it depends on a folder outside the library, on a
service the app does not control. The orchestrator's recommendation, hers to rule: High, Todo, first step the
offline measurement, and not a gate on 1.5 (1.4 walks the same road).

### Read for the sitting

`notes/handoffs/vx-980-handoff.md`, `notes/handoffs/vx-981-handoff.md`, `notes/handoffs/coordinator-2026-11-22-handoff.md`,
QUESTIONS #276 and #278 whole, `notes/plans/vx-981/mcp-parity-audit.md` (the two gap tables and its opening), the
Nov 22 sitting's record on its branch (`notes/plans/vx-1033-nov-22-sitting.md`: P-980-3 was ruled there, option (a);
the five-round cap is answered as the standing rule), and the Ambient repo's `notes/vx-1035-handoff.md`.

### The release's state

- Apple's notary service: `xcrun notarytool history --keychain-profile VariorumNotary` answered "HTTP status code:
  403. A required agreement is missing or has expired." at 14:40.
- `/Applications/Variorum.app` is 1.4 (12299). No Variorum is running.
- The first-run gate passed on `ad5053002`. Since then 195 files outside `notes/` changed on main (the phone runs
  VM-55, VM-78, VM-64, VM-47 and VM-24): 42 of them in the Mac app, `Shared/` and the core, among them
  `v1_38_owner_adoption_index`. The gate is owed again on the tip that is built.
- `ReleaseNotes-1.5.md` and the label 1.5 are still provisional.

## The list put to her, and her rulings

The list, as put to her in chat (each letter with the orchestrator's recommendation):

- **A. VX-980, search.** A1 keep everything as built (the Search index row's place, no confirm before Rebuild, the
  answer lasting only while the pane is open; the "say why" sentence also in a book's search; the Trash search's
  reach, the whole Trash with archived takes, untitled notes answering to their day, the one passage line, the
  180 ms pause, the click-only field, clearing on leaving). A2 one change: when a dash sits beside a tag the band
  stops quoting the dash (P-980-B1-1, option (b)), a Low ticket. A3 park VX-1017.
- **B. VX-981, the AI door.** B1 keep everything as built (a Journal entry's Private row ticked and locked even
  with its own mark; pressing the eye says why; a note deleted at the instant an AI moves her to it answers as
  missing, and every road clears that place's rows and the last-change door; only `tools/list` and `tools/call`
  count as a client being ready; a client that stops reading keeps its notices waiting and is never closed; the
  new status-line sentences). B2 ticket the toast covering the cards band. B3 ticket the two client-side frictions.
- **C. The parity audit.** C1 renaming a tag over the wire: allow it as the tag's act, Edit on the whole wing, the
  answer naming nothing hidden. C2 Snippets for AI: a design question, Needs Lillian, nothing built. C3 the other
  proposed tickets under one Backlog umbrella, Medium for the structural ones, Low for the rest. C4 the twelve
  exceptions accepted as stated.
- **D. The coordinator's items.** Land the five skill lines; no simulator ticket; her word on watchman.
- **E. Tickets.** E1 VX-1013 to High and Todo. E2 VX-1026 rides VX-1036. E3 close VX-460.

**Her answer (2026-11-24, verbatim; her numbers follow the report's sections):**

"1. good. 2. I accepted the apple agreement. 3. agreed that 1013 should be raised to High, Todo. I will do it in my
next umbrella. 4. agreed on landing all 5 improvements. I did brew reinstall watchman already. simulator ticket - I
don't think we need one. 5. agreed - seat this on the vx-1036 ticket, if that's the book improvement umbrella. 6. A.
agreed B. Agreed. C. c1 - ticket this, should be allowed. c2 - leave as needslillian. c3 - agreed, put these into
todo though. they are important to get done soon. C4 - agreed, but what are the rest? and are there any library
level acts approved right now? I suppose moving between libraries is. D. handled. E. yes, close vx-460. 7. that's
fine on the first run check being owed again, I started nov24 the stage coordinator so you can contact them for
that."

**What each became.**

| Her word | What was done |
|---|---|
| "I accepted the apple agreement." | `xcrun notarytool history --keychain-profile VariorumNotary` answers with the submission history (the last entry 1.4's DMG). Noted on VX-1028. |
| VX-1013 "raised to High, Todo" | Done on the ticket. Hers to seat in her next umbrella. |
| "landing all 5 improvements" | A new section in `.claude/skills/stage-coordinator/SKILL.md`, "Lessons the 2026-11-22 window taught", the five lines in the coordinator's own words. |
| watchman, the simulator ticket | She reinstalled watchman herself. No simulator ticket. |
| VX-1026 on VX-1036 | VX-1036 is the book umbrella ("Organizing inside a book"); VX-1026 is its sub-issue. |
| "A. agreed" | P-980-B1-1 (b) is VX-1069 (Low, Backlog). VX-1017 is Parked with its reason. Everything else stays as built. QUESTIONS #276 addendum 2. |
| "B. Agreed" | VX-1070 (the toast over the cards band), VX-1071 and VX-1072 (the two client-side frictions), all Low, Backlog. Everything else stays as built. QUESTIONS #278 addendum. |
| "c1 - ticket this, should be allowed." | VX-1050. |
| "c2 - leave as needslillian" | VX-1068, Needs Lillian, under the umbrella. |
| "c3 - agreed, put these into todo though." | The umbrella VX-1046 (High, Todo). New members VX-1047 to VX-1067; seated members VX-159 (now Medium), VX-145, VX-146, VX-147, VX-148. All Todo. Medium: VX-1047 (extract), VX-1048 (a passage into a new take), VX-1049 (takes into blocks), VX-159 (the divide and merge presets). The umbrella's own priority, High, is the orchestrator's reading of "important to get done soon", hers to change. VX-368 closed with the outcome. |
| "C4 - agreed, but what are the rest? …" | The twelve are stated in `notes/MCPSpec.md` beside the audit's pointer, and were listed for her in chat with the answer to her question: no act above a wing is on the wire today; between wings the wire has `list_wings`, `move_note_to_wing`, `move_book_to_wing` and `copy_note_to_wing` (a gathering and the daily Journal refuse the move). If she strikes one after reading the list, the MCPSpec line changes before this branch merges. |
| "yes, close vx-460" | Done, with her word on the ticket. |
| "you can contact them for that" | REQUEST sent to `nov24`; queued first. See "The release's step 0". |

**The 1.5 notes.** Put to her as drafted on 2026-11-19; her answer, verbatim: "ok i want the release notes changed. I
don't like this type of riddler update: This update makes two things say exactly what is true. I'd make it more
simple. Maybe: Search had a bug where symbols made resujlts blank fixed. The daily journal had a bug where it didn't
show the Private symbol fixed. that kind of simpler style. "what the tag answers" doesn't make that much sense. I want
them rewritten in a more straightforward style of communication." The rewrite was put to her in chat (a one-line
summary, then Fixed, New, and For connected AI tools, each fix as the bug and its fix). Her answer: "yeah that looks
good". It is `ReleaseNotes-1.5.md` as committed on this branch. The label stays 1.5 (she was asked twice and changed
nothing).

**The wording pass** was not ruled: she sent no edit. The sentences listed in the two handoffs stay provisional, and
canon keeps that word on the Trash line's wording.

## The release's step 0

- **What is owed:** FirstRunDrillTests and `Tools/WalkKit/first-run-walk.sh std` (both arms) on the code being
  released. It last passed on `ad5053002`.
- **What does not need re-running:** the whole Mac test target. It ran green on VM-47's merged tree (6,435 tests in
  1,114 suites, the coordinator's 2026-11-19 handoff), and `git diff 226edf626 HEAD` shows no change since that
  merge in the Mac app, `Shared/`, the core or their tests.
- **The tip gated:** `703c42173`. Commits after it on the way to the build change only notes, the coordinator
  skill and, if she edits them, the release notes' words; none of that is code the gate exercises.
- **The road:** stage coordinator `nov24` grants the window (claim `vx-1045`, 45 minutes, seams after the test run
  and between the walk's arms). An Opus subagent prepares headless (the Debug build, build-for-testing, the walk's
  self-test), and runs the gate only after the orchestrator has taken the claim line.

## LIVE STATUS

| When (2026-11-24, MST) | What |
|---|---|
| 14:35 | Bout start: both repos pulled (level). Handoffs, bundles and memory read. |
| 14:40 | The notary check: still 403. |
| 14:45 | VX-1013 traced and measured. |
| 14:49 | PR #8 merged (`703c42173`); cleanup done. |
| 14:50 | The "Ambient" label made and applied to fourteen tickets. |
| 14:52 | VX-1045 minted; this record opened. |
| 17:30 | Her answers arrived. The notary check passes. |
| 17:33 | ANNOUNCE and REQUEST to `nov24` for step 0; queued first. An Opus subagent started on the headless preparation. |
| 17:34–17:38 | Linear: VX-1013 High and Todo; VX-1026 under VX-1036; the umbrella VX-1046 and its members; VX-1068 to VX-1072; VX-460 and VX-368 closed; VX-1017 parked. |
| 17:39 | The five skill lines, the ratified canon lines, the stated exceptions and the two QUESTIONS addenda on this branch. |
| 17:45 | The helper's preparation done, headless: the Debug app built from this worktree (1.5, build 13404, the code of `703c42173`), build-for-testing into the same derived data, the walk's self-test passed (72 cases). FirstRunDrillTests holds 11 tests. The dev slot as found: 239 files, its restore-hold marker present, so it is set aside whole. |
| 17:46 | READY sent to `nov24`. The walk will run from the main checkout's script (byte-identical `Tools/`), pointed at this worktree's build, because the walk's guard needs main's `.env.supabase.local` and this worktree has none; the 2026-11-19 run took the same road. The drill's result comes back to the orchestrator before the walk starts (the seam). |
| 17:47 | GO from `nov24` (its pre-GO: she away from the keyboard, Ambient down, zero instances, no simulator, no crash reports). The takeover line run alone: the stage claimed by `vx-1045` at 17:47:24 for 45 minutes (`~/.variorum/stage.log`). The helper started on the drill only. *The three rows above first carried guessed times; they are corrected to the commit times and the stage log.* |
| 17:48 | **The drill: GREEN.** FirstRunDrillTests by `test-without-building` on the gate build, 17:47:52–17:48:43: `executed 11 (passed 11, failed 0, expected failures 0) - skipped 0 - from the result bundle`, `VERDICT: GREEN (0) - 11 test(s) executed over 1 run(s)` (`Tools/assert-tests-ran`), "Test run with 11 tests in 1 suite passed". xcodebuild exit 0; the test host exited by itself; no crash report. Read by the orchestrator in the logs, not only in the helper's report. |
| 17:49 | SEAM ping to `nov24` with the executed count; the helper continued to the slot's set-aside, the walk (std, both arms, one invocation) and the restore. |
| 17:49–17:52 | **The walk: PASSED, both arms.** `first-run-walk.sh std --arm both`, exit 0, 17:49:55–17:52:37. walk.log: "P8: the set-up arm PASSED — the sheet confirmed, the row Synced, the server holds the vault, the proof, a cursor and rows" · "J8: the join arm PASSED — the sheet confirmed, the row Synced, one device cursor more, the account's lock unmoved" · "done: PASSED — 'std', arm 'both'; signed out, quit, and the account at rest (exists, confirmed, vaultless, rowless)". All thirteen captures were withheld by the words guard (the known class), so the log is the evidence. |
| 17:53 | **The restore, verified by the orchestrator:** the dev slot back by the reverse rename, "md5 IDENTICAL (239 files)", the folder's inode as found; the Debug defaults compared against the pre-walk export after the import and the removal of the walk's four added keys: 1,356 keys, 0 added, 0 removed, 0 changed. Zero Variorum instances, no Problem Reporter, no crash report. Left as they are, with the coordinator's agreement: three values the drill's test host wrote at its launch. |
| 17:54 | The stage released (17:54:08; 7 of 45 minutes) and the result line sent; `nov24` verified it and put step 0 PASSED on its record. |
| 17:55 | Found before the release run: the main checkout holds an untracked folder, `notes/plans/textloss-screens/` (the Nov 22 sitting's local frames, never to be committed), and `release.sh` refuses any tree `git status --porcelain` does not read as clean. Its ignore line is added on this branch, beside the other screens folders, so this branch's first PR merges before the build. |

