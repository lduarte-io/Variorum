# VX-981 — the MCP door fixes: your morning handoff

**STATUS: MERGED 2026-11-19 — PR #14, merge commit `7629cf049`; the decisions are QUESTIONS #278. THE RELEASE WAS NOT BUILT: Apple's notary service refuses until you sign your developer account's current agreement (VX-1028). Main is release-ready; one command builds it.**

---

## What happened, in plain words

You asked for the MCP door's follow-up tickets to run overnight beside the search run, with the bug you'd just reported — your daily Journal not wearing the Private eye — added to it. That is what this run was: sixteen tickets about the door AI clients use to reach your library. Fourteen were yours to start with (eleven on the umbrella and three riders you picked); two more were found during review and fixed in the same run. They were built in five batches, read twice by fresh reviewers, and tested at four gates. Anything that needed your judgment was built the most defensible way and bundled for you rather than decided.

The headline is the bug you reported. Your daily Journal, and every entry in it, now wears the Private eye wherever the eye appears, and the Journal's Book Settings shows Private ticked and locked, with a line saying it is always Private. Nothing was written into your library to do it: the app now reads the same rule the AI door already used, so the two can't disagree. The rest makes the door more honest and more solid. An AI can remove a version link only when it can edit both notes, as you ruled. The status line keeps saying what an AI did even when the titles are long, and its count drops the changes you've undone. A note deleted at the very moment an AI shows it to you opens nothing and says so. One AI client that stops responding can no longer hold up the others or your unlock. And the server is steadier when it's switched off and on quickly. One more piece has no code: an audit listing everything you can do at the keyboard against what an AI can do, with proposals that are yours to rule.

The release: by your word, the last of tonight's two Mac runs builds it and does not publish it — that is this run. **It could not be built tonight.** The release script stopped at its own first checks, because Apple's notary service answered: "HTTP status code: 403. A required agreement is missing or has expired." Your signing credential is fine and nothing is wrong on this Mac; Apple wants the developer account's current agreement signed, and that signature is yours. Nothing was built, signed or uploaded, and I ran none of the script's steps by hand. Everything before the build is done and on main, so once you have signed it is one command (below). **The label 1.5 and the notes in `ReleaseNotes-1.5.md` are provisional:** I put both to you in chat and built with them unanswered. They are yours to confirm or change before any publish; a change is the version line on the Mac app's two configurations plus the notes file, then a rebuild.

## Your checklist

- [ ] Read and rule the QUESTIONS bundle **#278** (the P-981 family). The biggest calls: how the Journal's rows lock (P-981-B1-2, -3); what an AI hears when the note it moves you to was just deleted (P-981-B2-5) and what happens to that place's other AI doors (P-981-L1-1); which requests count as a client being ready (P-981-B3-2).
- [ ] The parity audit's proposals (in #278; the audit is `notes/plans/vx-981/mcp-parity-audit.md`): **T3** (renaming a tag on the wire would reach notes the AI can't see) and **T4** (where a grant for Snippets would live) need your call first; then T1–T22 as tickets and E1–E12 as stated exceptions — flip any you disagree with.
- [ ] The wording pass — every new sentence, listed by where it appears, in #278.
- [ ] Re-seed the field guide in your real store: lesson 3 changed (unlinking moved from the Write-new card to the Edit card). Behind the A1 safety copy, Help ▸ Restore Field Guide….
- [ ] VX-370: install and sign in to a second MCP client on the Pro (Codex or Gemini) when you want the output-cap measurement run — the recipe is ready.
- [ ] **First, because the release waits on it (VX-1028):** sign the current agreement on Apple's developer site (Account ▸ Agreements). Then confirm or change the label 1.5 and the notes (`App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-1.5.md`), and build: from `~/dev/variorum` on main, with no Variorum running, `Tools/Release/release.sh --version 1.5 --stop-before-appcast` (drop the flag to make the appcast in the same run — that step reads your Keychain). Publishing after that is yours alone, by the site's runbook.
- [ ] The filed tickets pass (the list at the bottom), and VX-368 moving to Needs Lillian with the audit as its pointer.

## What changed for you in the app

- Your daily Journal wears the Private eye on its row in the Bookcase, the Library and the Book Panel, and each entry wears it on its row and on the note's masthead; pressing it says why, and changes nothing. As before, the eye shows only while an AI client is approved and the AI-marks switch is on. (VX-1007)
- The Journal's Book Settings shows Private ticked and greyed, with one line saying it is always Private; a note in the Journal shows the same in its ▾ menu. (VX-1007)
- An AI needs the Edit permission on both notes to remove a version link; with less, you're asked, as for its other edits. The field guide's lesson 3 says so. (VX-977)
- When an AI links or unlinks two notes whose titles are too long for the status line, the line now says "linked two notes as versions" or "unlinked two notes as versions" instead of "made a change". (VX-979)
- The status line's count of an AI's changes drops any you've undone, and comes back if you redo. (VX-133)
- If an AI's request to show you something lands but the activity log can't record it, the AI still gets the true answer and you get one line saying the log missed it. (VX-961)
- If the note an AI is moving you to is deleted at that instant, nothing opens, you're told it's gone, and its sidebar rows and ⌥⌘O stop offering it — on every road that finds a place gone. (VX-705, VX-1025)
- Under the hood: an AI client hears "your tools changed" only after it has finished connecting; a client that stops reading can't delay the others or your unlock; the server's socket is safe from quick off-and-on switching; the first message is read faster. (VX-951, VX-944, VX-959, VX-952)

## The ladder, in three lines

- Round 1 (a fresh Fable reviewer, the whole diff): no blocker, no major; four minors and five nits, every one fixed — the biggest a half-finished AI show that still told you nothing when the log failed, and the move's gone place leaving dead doors behind.
- Round 2 (a fresh Opus reviewer, the fixes): no blocker, no major; one minor — ⌥⌘O could stay lit over a deleted place on two older roads — fixed with one rule for all four roads, plus three nits.
- No round 3 was earned (your five-round cap applies only while a major turns up).

## The gates

- Gate A (the Journal's faces): 234 tests in 31 suites green; the old code failed exactly the 8 tests it should.
- Gate B2 (the wire's small fixes): 415 tests in 61 suites green; four old-code legs each failed as named.
- Gate B34 (the announce order and the socket, on the tree with main merged in): 108 tests in 16 suites green; its old-code leg failed.
- Gate FIX (both review rounds' fixes): 143 tests in 22 suites green; three old-code legs failed as named.
- The recorded connection flake: on the old code it showed up alone at repetitions 475 and 296; on the fix, 600 of 600 alone and 3,232 under a parallel load, none failed.
- The closing walk: GREEN in both passes (the Journal's Private faces in both voices; the live wire round). The merge gate (the whole Mac target plus a phone leg over structural undo): GREEN on the merged tree `9007f4686` — the whole Mac target 6,434 tests in 1,114 suites with ONE red, VX-701's known keyboard-focus flake (`TakesFindBoardTests.escWithNoBuiltPaneForTheRingIsANamedBoundary`), green alone twice inside the claim; the 13-type phone leg 159 tests green.

## What the closing walk saw (none a failure)

- **Filed at your word:** the daily Journal's own row menu still offers "Use as Daily Journal" (VX-1027).
- **Yours to say:** a toast on the Bookcase or the Library lands on top of the cards band, so while a card such as the twelve-words card is showing, a toast hides its sentence and most of its click target for the seconds it stays. It is every toast, not this run's. Not ticketed; say the word and it is.
- A link or unlink made within two minutes of other changes by the same AI is folded into "made N changes", so its own title-free line shows only when it stands alone in that window. That is the standing two-minute rule, now counting only changes that still stand (P-981-B2-4).
- **From the client's side** (your standing ask for agent-side notes): a client that is not yet approved and only lists its tools gets an empty list and raises no connection request — the request appeared at its first tool call; and after you answer "Don't allow", the client hears nothing — it has to retry or read its own activity. Neither was changed by this run. Both would be small ergonomics tickets if you want them.

## Two things worth your eyes

1. **A session-permission note (batch 1).** The pre-push guard refused one of batch 1's record commits because a line named a folder by its absolute home path. Nothing had been pushed. The implementer tried to amend the commit and the session's permission layer refused the amend, so it folded its two UNPUSHED record commits back (a soft reset to the pushed tip) and committed them again with the path made home-relative. No pushed commit was rewritten and nothing was lost. You may want to know the permission layer blocks amends even on unpushed work.
2. **The reviewer changed mid-run.** Round 1 was a Fable reviewer, as the kickoff said. From round 2 the reviewer was Opus: CLAUDE.md's rule allows `opus-reviewer` for a diff with no editor seam, custody, `Sync/` or default's-meaning content, and round 2 re-read only the fixes, none of which touched the connection's wire order, writer or socket path (the kickoff's reason for Fable). That was the orchestrator's call, not yours; a later round reaching wire order would have gone back to Fable.

## The rulings reconciled

Each ruling the run built — yours on the Journal, the unlink rung, the title-free arm, VX-775's split, and R-981-1…8 — was re-read word by word against what shipped: the run record's THE RULINGS RECONCILED. Remainders named there: the phone shows no Private eye at all yet (VM-209, open); "its first request" read as the two tool requests (P-981-B3-2, in your bundle). Its two loose ends are settled: MCPSpec's sentence that called every show "fire-and-forget" now says an ask answers at once and a move at once answers after its own delivery; and an optional AppSpec §9 sentence about the undo stack was left out on purpose, to keep the always-loaded canon lean.

## Mobile parity

PL-77: the Journal's Private facts ride to the phone in shared code, unused until VM-209 draws an eye there; the undo stack's new walk observers change nothing on the phone; the MCP door itself is Mac-only.

## Canon

`Tools/canon-size` on main after the merge: 143,205 of 150,000 (headroom 6,795) — no crossing. Contract lines changed in place in MCPSpec and SurfaceContracts (each listed old words → new words in the run record's CLOSEOUT section), plus one optional clause in AppSpec §12 — the eye marking everything the fence holds — yours to strike.

## The release

**Not built.** What happened, in order:

- **Release prep, done and merged:** the Mac app's version line reads 1.5 on both configurations and `ReleaseNotes-1.5.md` is in place (the version guard and the notes guard both pass). Both are provisional — the label and the wording were put to you in chat and went in unanswered.
- **The first-run gate, passed** on main at `ad5053002`: the headless drill ran green inside the merge gate, and the scripted first-run walk passed both arms (a new user turning sync on, then a second device joining) on the Debug build of main, against a test account that the walk found at rest and left at rest. The dev store was set aside whole and put back with every file's checksum unchanged.
- **The build, refused by its own preflight:** `Tools/Release/release.sh --version 1.5 --stop-before-appcast` checked the version, the commit (`ad5053002`, build number 12722), zero running instances and the Sparkle tools, then stopped on "the notary credential 'VariorumNotary' did not answer". Apple's own answer to that check: "HTTP status code: 403. A required agreement is missing or has expired." Nothing was archived, signed, notarized or uploaded; there is no 1.5 folder under `~/Library/Developer/Variorum/Releases`; `/Applications` still holds the published 1.4 (12299).
- **What it needs:** your signature on Apple's agreement, then the one command in your checklist. I stopped before the appcast on purpose: that step reads your Keychain and is yours to run attended.
- **One caution:** the first-run walk is recorded for main at `ad5053002`. Later commits on main that change only notes do not disturb it, but if a mobile run merges code before you build, the release checklist's walk is owed again on the new tip (`Tools/WalkKit/first-run-walk.sh std`, under a stage claim).

## Tickets filed

Tickets filed:
- [ ] VX-1028 (High, Task, Needs Lillian): sign Apple's developer agreement, then build 1.5 with one command and publish when ready.
- [ ] VX-1026 (Medium, Bug, Todo): `list_notes` on a book lists the hand order, not the book's own order — its sort, pinned notes and chapters.
- [ ] VX-1012 (Low, Bug, Backlog): unticking a note's own Private mark from its menu says "No longer Private." while a Private book still holds the note.
- [ ] VX-1027 (Low, Bug, Todo): the daily Journal's own row menu still offers "Use as Daily Journal" — filed at your word during the walk.
- [ ] VX-1018 (Low, Bug, Backlog): one whole-target test run hung idle for 12 minutes in `MCPReaderAfterCloseTests`, seen once on the tree before this run's transport changes — untraced.
- [ ] VX-1020 (Low, Bug, Backlog): a grant change landing in the instant the MCP server starts is never announced to connections already served (older than this run).
- [x] VX-1019 (Low, Bug, Done): the accept-loop tests' 10-second connect bounds went back to the harness's own 30 seconds — fixed in this run.
- [x] VX-1025 (Low, Bug, Done): a last change on a place her press proved gone kept ⌥⌘O lit on two older roads — one rule on every road now, fixed in this run.
