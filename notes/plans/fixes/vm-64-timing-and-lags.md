# VM-64 — Run: Timing and the two lags (mobile catch-up, wave 1, umbrella 3)

**STATUS: OPEN — kicked off 2026-11-19 (/run-phase, the Pro, overnight; orchestrator session `vm-64`; stage coordinator `nov18`).**
Ticket: VM-64 (team VM, the umbrella is the run ticket) · Branch: `vm-64-timing-and-lags` · Worktree: `~/dev/variorum-vm-64` · PR: `VM-64: …` (merge commit, never squash).
Plan: `notes/plans/vm-44-mobile-catch-up-plan.md` (wave 1, umbrella 3 ⚑ — the wave's ONE `Sync/`-or-custody slot) · members `notes/plans/vm-44/plans/minted/umbrella-03.md` · the traced causes `notes/plans/vm-44/audit/F-performance-trace.md`.

## FOR A LATER READER

**What the run was.** The phone's performance umbrella in the mobile catch-up's wave 1 (`/run-phase`, overnight 2026-11-19; Fable orchestrating, a fresh Opus implementer per batch, Fable cold reviews, nov18 on the stage). The wave's one `Sync/`-or-custody slot — and not one line written in `Sources/VariorumCore/Sync/`, `Server/` or custody code. A timing layer and its readout first, then the keystroke fence and five fixes behind her two lags (§2). Seven batches, all closed; main merged in three times (VX-980, VM-55, VX-981) and PENDING(the VM-78 merge-in); three ladder rounds, closed — round 2 found one MAJOR, fixed and seen red on the old build and green on the new; the merge gate and the merge are PENDING(gate · merge).

**Per member — the mechanism as settled · the fix as built · one pointer.**
- **VM-65** — nothing timed what she feels · a bounded Core recorder (O(1) a mark, a 64-ring per series, durations and counts only, signposts); one catalog in `Shared/AppTiming.swift`, inert unless the phone enables it (the Mac records nothing); the readout at Settings ▸ Diagnostics ▸ Timing…, one table per build kept across a quit · `808f333a8`. The ladder added: a no-op end no longer marks the record changed (round 1); an Open that files nothing leaves no open span, and the heading is drawn as drafted, not in capitals (round 2); a damaged timing file can no longer trap the readout or the launch — its ring size, its drawn numbers and its absorbed counts are all bounded (round 3, `8d48a682c` · `4bee11420`).
- **VM-2** — the phone's structural doors suspend while the pre-act page stays editable, and the gate never read the latch; a key there recorded the whole pre-act block, flushed after the act, and `autosave`'s rescue kept it, demoting the act's result to a `'conflict'` take · a refuse-and-say fence from the latch to the settled page (`Domain/StructuralFlightFence` + the gate and storage belts); insert below exempt; the undo door hooked · `2a3fd3a52`.
- **VM-66** — the speed tests skipped her paths · `MobileHerPathsPerfTests` (the real screen and shell, reading VM-65's one recorder — so it runs ALONE, gated since ladder round 2: `TEST_RUNNER_VM66_PERF=1`) and the `.nineWings` fixture · `App/Variorum/VariorumMobileTests/MobileHerPathsPerfTests.swift`.
- **VM-67** — `adoptOwnerID` scanned all eleven owner tables in a write transaction at every launch, unlock and sign-in, to change nothing · `v1_38`'s partial indexes (local-only, not a §12 event, marker 15) and a probe before the write, in one writer access · `e6d16fca7`.
- **VM-68** — the hidden Library held two whole-listing observations re-run on every write, and the listing cut silently at 200 · keyset pages through the Mac's `catalogNotesPage` (+`keys`, +`poolLoose`), held only while drawn, re-asked on return · `dcea98cee`. **Only the FIRST page is held, so the ladder added three rules to the model (`MobileLibraryViewModel`):** an act on a listed row re-asks the shown listing in place when it is deeper than a page — the row's delete, a ★ under Bookless, and the message line's Put back by ONE signal posted from `MobileLine.putBack` (round 2's MAJOR, `64af6d64a` · `686a07d13`); rows are drawn only while they answer the current wing (`landedWing`, round 2's finding 3, the merge with VM-55); a listing that was complete stays complete when a landing brings a cursor back (`land`, round 3's finding 1, `848b98b66`).
- **VM-69** — an open read the note twice (`loadOnce`, then `start()`'s first fetch), laid the chrome out three times, and the chips read every book and tag · the arrival's load IS the live observation's first value; chrome once; chip-scoped reads · `63ad8b188`.
- **VM-70** — nothing on the phone released an editor's coordinator (registry +1 per open) · the leaving's last act gives the hold back, the arrival takes it back adopting a re-minted coordinator (the fix pass's `f589d964e` re-observes on both paths) · `36cddcf60`.
- **VM-71** — every leaving ask was `closeAutoCommit`'s O(note) runner turn, three per Castle backgrounding · the phone's `savepointOnLeaving` reads the owed takes on a reader and asks the runner once for exactly those (`Queries.leavingSavepointCandidates`, `closeAutoCommit(_:takes:)`); who asks is unchanged · `d849b7125`.

**Her rulings (§2, by bullet):** the lags (1st) and the readout (2nd) are why the run exists; the plan's evidence rule (3rd); five ladder rounds, made standing — landed in CLAUDE.md, both phase skills and ProcessHistory (5th); no "before" run on her phone and ONE wave-1 install at her hands (6th — P-64-1 CLOSED, §3); "rule provisionally in my absence" (7th). VM-24's fix is its own run after wave 1 — her pick in the VM-78 run, relayed there.

**Evidence that matters (pointers):** §5 "THE BEFORE NUMBERS" and "THE AFTER NUMBERS" — every count the run set out to change moved and is asserted (reads per open 2 → 1; hidden-Library re-reads and redraws per box save 2 · 2 → 0 · 0; Castle backgrounding savepoints 3 → 1; registry growth 1 → 0); one duration moved outside noise (the 100k note live 496 → 342 ms); a single Library page is NOT faster per fetch. §5 "Batch 6 (r1) and batch 7 — THE STAGE WINDOW ON THE FINAL TREE": 80 types in one host, the only red VM-24's standing caret test. The red-on-old runs: §5's batch 2 r2 cycle, batch 4's P4 (headless), batch 5's red build, the batch 6 and 7 r1 red builds. The Mac pieces in §5 (61/9 · 110/16 · 93/14 · 48/7). After the merge of VM-55: §5 "The merged tree … THE STAGE WINDOW" (round 1's finding-2 pin red on the hunk-reversed build and green on the fix; 234 tests in 38 suites green in one host). After round 2's fixes: §5 "Ladder round 2's fixes — THE STAGE WINDOW" (exactly the seven meant tests red on the reversed build; 32 in 5 green alone; 237 in 27 green in company with the gated speed suite's 13 skipped; the gated suite alone 13 passed). The whole Core package on the tree with VX-981 in: 4,971 tests in 721 suites, 5 declared known issues. Round 3's three hosted pins and the merge gate: PENDING(gate counts).

**The ladder:** the midpoint review (batches 1–4, outside the count, `vm-64-midpoint-review.md`) 0 B · 0 M · 5 minor · 3 nit, and round 1 (the whole diff, `vm-64-ladder-round1.md`) 0 · 0 · 4 · 3 — every finding agreed and dispositioned; finding 1 accepted as arm (a), its bound held by a guard (`84a8acff8`). **Round 2** (the merged tree, `vm-64-ladder-round2.md`) 0 · **1 MAJOR** · 5 · 3: the MAJOR — a note deleted from a Library row past the first page stayed listed, and a Put back of one did not return — fixed (above); finding 2 (the fence can read "settled" while its settle read is in flight) CONFIRMED but its one-fact fix WITHDRAWN as wrong for the ordinary road, carried to VM-226; and the orchestrator's item O-1: the speed suite is gated (`TEST_RUNNER_VM66_PERF=1`), a guard in `MobileNoteOpenOnceTests` keeps "read once" in every ordinary run, and a phone merge gate runs the gated suite as its own leg (VM-241 for the rest). **Round 3** (`vm-64-ladder-round3.md`) 0 · 0 · 2 · 3, the LAST round: the fully-listed listing's row short after an Undo, fixed as (i′) with one accepted leftover (VM-242); the timing file's bounds; record corrections; the reviewer's final calls and the orchestrator's line-by-line check of the final round's fixes are at the end of that file.

**Open items:** the PROVISIONAL bundle QUESTIONS #PENDING(QUESTIONS number), led by P-2-1 (refuse-and-say) and P-2-5 (insert below exempt); VM-226 (the tail's idle save mid-flight; the fence dropping before the page has re-read; and a refusing door that leaves the fence up while a save is stuck — typing refused until the note is reopened); VM-227 (a re-show while teardown is suspended stops hearing its coordinator — narrowed, not closed; the same stuck-fence consequence); VM-240 (the held first page still grows with the library under three sorts and in a small wing); VM-241 (always-run tests for the counts only the gated speed suite asserts); VM-242 (a synced change deep in the listed Library is not shown until the list refreshes; (i′)'s leftover); P-2-2 as it meets VM-55's one message line (a refusal is drawn with no Undo beside it; the Undo stays in the ⋯ sheet — in the bundle); the residuals table in `vm-64-closeout-drafts.md` ▸ (g); her phone sitting (the wave-1 install, the readout, autocorrect and dictation under the fence); the batches 6 + 7 walk PENDING(walk); the merge gate PENDING(gate).

**Do not trust these without the correction beside them:**
- **Batch 2's first-version claims** (§7 batch 2's r0 closeout — "typed keys deferred and replayed, never dropped", its input table, "8 failing, 2 passing"): falsified at the first window; corrected in "Iteration r1", "Iteration r1 → r2" and "Iteration r2" below it — on her keyboard even r1 was refuse-and-say.
- **Batch 6's r0 release** (§7 batch 6 — the `isolated deinit`, hazard (b)'s first text, D-6-3, three pins' rows): falsified, since nothing frees a popped screen's editor promptly in her app; the `[r1: FALSIFIED …]` marks and "Iteration r1" carry the release as built.
- **Batch 7's hazard (b)** ("nothing can go stale") and hazard (a)'s pop row: true ACROSS asks only; the in-place "[Ladder round 1, finding 1 …]" notes and D-7-1 name the one-ask gap and its bound.
- **Batch 1's "what each number means" table:** read it with batches 5, 6 and 7's "The timing marks — what they measure now" (deliveries, reads per open and savepoint attempts changed meaning).
- **Batch 5's "bounded"** (its cost table, and the first handoff): true only under the edited sort in a wing of a page or more; corrected in place by round 2's finding 5 (VM-240).
- **The nine-wing fetch series after VM-55** read the current wing only (a ninth of the fixture); the BEFORE and AFTER tables read every wing — not comparable (§7 ▸ "The merge of main (VM-55)…" (a)).
- **Batch 3's "the suite runs alone because suites run in parallel":** in this host suites run one after another (the scheme has parallel execution off); the suite is gated because its place among the others is not its own to choose (round 2, O-1).
- **The fix passes' "keeps the door's Undo beside it"** (batch 2's P-2-2, the first handoff): false since VM-55's one message line; corrected by round 2's finding 6.

---

## 1. Kickoff message (handed to every implementer verbatim, with its batch named)

> You are the implementer for ONE batch of the VM-64 run, "Timing and the two lags" — the phone's performance umbrella in the mobile catch-up's first wave. Work only in the worktree `~/dev/variorum-vm-64` on branch `vm-64-timing-and-lags`; never touch `~/dev/variorum` (main) or any other worktree.
>
> **Read first, yourself, in full, before touching code:** `CLAUDE.md` and its loaded canon; this record (`notes/plans/fixes/vm-64-timing-and-lags.md`) §1–§4 and your batch's section in §4; `notes/plans/vm-44-mobile-catch-up-plan.md` ("The rules every umbrella inherits"); `notes/plans/vm-44/plans/minted/umbrella-03.md`; `notes/plans/vm-44/audit/F-performance-trace.md` (all of it — it is the trace your batch answers; verify its file:line claims against today's tree before building on them, the audit was read at an older main); `notes/plans/vm-44/plans/sitting-1-rulings.md`; `notes/MobileSoul.md` §1–§5; `notes/SessionResiliencyProtocol.md` (it binds you). Then the extra reading your batch section names.
>
> **Her words, the reason this run exists:** "There's significant lag when going to the quick entry box, when going from the quick entry box into a note." And her bar (MobileSoul §2): "I do not want the mobile app to choke even on 100k words."
>
> **What every batch owes:** the batch section's acceptance unit and nothing beyond it; pin before fix (every bug-class change lands with a pin that is red on the old code, verified by revert — commit before you revert, and say so in the record before starting); brains in `VariorumCore` or `App/Variorum/Shared/`, the phone owns only faces (MobileSoul §3); the Mac must not change in behaviour — shared code you touch still compiles and behaves for the Mac; no new user-facing copy beyond what the batch section allows, and any line you must draft is marked DRAFT for her wording pass; record durations and counts only, never note text, titles or ids, in anything this run logs.
>
> **The checkpoint protocol binds from your first commit:** write your batch's LIVE STATUS block in §5 of this record at the start; commit per coherent piece and push after every commit; flip the status in the same commit as each piece; claims not yet verified are marked PENDING; synchronous foreground waits only (poll a log with a `grep -q … && break; sleep 5` loop, never end your turn waiting on a background run). Commits carry no attribution trailer; messages are public copy and say `Part of VM-<member>`. The repo is PUBLIC and every push runs a pre-push guard: never write a device identifier, simulator UDID, email, account id or credential into a commit or the record (use placeholders such as `<simulator-udid>`); a guard refusal is fixed in the commits, never bypassed. `notes/QUESTIONS.md` is a shared ledger touched only at the merge: never edit it on this branch — write each PROVISIONAL question, with its options, under a "For QUESTIONS at the merge" heading in your closeout.
>
> **The stage:** headless `swift build` / `swift test` on the core package and `xcodebuild build` / `build-for-testing` need no stage and run freely. EVERY `xcodebuild test` (simulator or Mac), every simulator boot, walk or Debug launch needs a stage window that ONLY the orchestrator can obtain from the coordinator. So: do all headless work, get `build-for-testing` green for the phone test target (and the Mac's when you changed `Shared/` or Core code the Mac compiles), then END YOUR TURN with a READY report naming the exact suites and commands you need run. The run is PIPELINED: while your batch waits for its window, the next batch's implementer may already be working headless in this same worktree, and the orchestrator may run your stage commands itself from your built products — so make them runnable by someone else exactly as written (`test-without-building` against the `.xctestrun` in your DerivedData folder, TYPE names in a zsh array), and never touch another batch's DerivedData folder. If the orchestrator instead messages you the GO with the claim line, you run, release, and report. Never claim the stage on your own; never run a test host or boot a simulator without the GO. Use a run-tagged DerivedData folder (`App/Variorum/DerivedData/vm64-<batch>/`, gitignored) and say its path in your report.
>
> **Report back with:** what shipped (file by file), headless test counts, the pins and their red-on-old proof, PROVISIONAL calls with the options you weighed, commits (hashes), the exact stage commands you need, anything that needs the author. Write your batch's closeout section in this record detailed enough to be reviewed cold against the spec.

## 2. Her words and rulings this run stands on

- The lags: "There's significant lag when going to the quick entry box, when going from the quick entry box into a note." (`notes/plans/vm-44/her-words.md`)
- The readout (sitting 1, `sitting-1-rulings.md` ▸ Performance): the Instruments session on her phone was set aside at her word in favour of timing built into the app — markers at the moments she feels (tap on the capture box, keyboard up, file, note on screen, unlock, library ready) and a readout; it gives before-and-after numbers for every later fix. Seen on her phone after the VM-46 install: a sync round of about a minute with nothing new to send.
- The plan's rule: the timing readout is run before and after anything that claims to be faster; every umbrella closes on use-shaped evidence on her phone or a simulator walk, never on a pin alone.
- Tonight (2026-11-19), verbatim: "i want to get everything set up for an overnight session" · "the whole issue is that i need to use my weekly limit up before tomorrow" · "i want one claude coordinator named nov18, then i want all the VM in the first wave launched with instructions to talk to stage coordinator nov18, i want the vx-981 and vx-980 added too. and add the high priority (private eye not shown on journal) to one of those runs - maybe the MCP run, since it deals with the private mark."
- The ladder (2026-11-19, to this orchestrator, verbatim): "up to 5 review rounds as long as a major is found." Asked whether for the night or standing: "honestly, just update the standing rule too." (CLAUDE.md, both phase skills and `notes/ProcessHistory.md` carry it from this branch.) And: "you can do an in between review if you need".
- The phone (2026-11-19, verbatim, in order): "i won't be able to do vm-65 then - how do you suggest handling that? I'd leave it in the handoff bundle for me to do later." · "i talked to vm-55, and i'm just going to have that session add a very basic switcher. so i can just install the build from all of wave 1 on my phone at the end of you all merging in." · "i'm not that concerned about a before run from my library for this run's fixes, unless you think it's a big issue, which it doesn't seem like you do - we'll tune after the fixes, from that point. it's quite laggy right now, so we know there are issues. and then I'll install the result of wave 1, do a sitting where i plug my phone in before wave 2." · to every session: "resolved the previous install blocker with vm-55. now, i'll plan to have the wave 1 build installed on my phone after the last vm has merged in, prepared by the last one - a new session should be able to help me with the install if i don't want to wake a stale cache. sound good? the phone step is the single wave-1 install after all four runs have merged. I'll do the hands part hands on in the morning."
- Leaving for the night (04:16, relayed verbatim by the coordinator): "ok i'm off the mac. variorum is closed. i'm leaving for overnight. good luck with everything, tell all my sessions that i'm off, rule provisionally in my absence, i'll check in in the morning (which is depressingly soon)."
- The kickoff's instruction for this run: VM-65 first; VM-65 going onto her phone needs her hands (phone on the cable, unlocked, Variorum closed), so that install is a HELD ask for her next sitting; everything that does not depend on it continues.

## 3. Cast, members, and how the run is cut

**Cast (CLAUDE.md's standing cast; no redirect at kickoff):** the orchestrator (Fable) never implements · `opus-implementer`, a fresh one per batch, strictly one agent at a time · the ladder's cold reviewer is `fable-reviewer` (the diff holds the phone's editor seam and the services' sync start), a fresh one per round, `notes/REVIEW_PROMPT.md` verbatim. This run aims to change no line inside `Sources/VariorumCore/Sync/`; a batch that finds it must stops and reports first. **The ladder runs up to FIVE rounds** (her ruling above), a further round only while the round before it found a new BLOCKER/MAJOR. **One midpoint cold review** (her allowance; `fable-reviewer`, the review prompt verbatim) runs after batch 4 closes, over batches 1–4, before batches 5–7 build on them; the orchestrator reads it as outside the ladder's count.

**Members = VM-64's sub-issue listing (read at kickoff, re-read before the ladder):** VM-65 · VM-66 · VM-67 · VM-68 · VM-69 · VM-70 · VM-71 · VM-2. Eight, matching `umbrella-03.md`.

**Riders:** none offered. Every open mobile ticket in the Areas this run touches (Performance, Editor, Tests & tooling) is already a seated member of a later umbrella (VM-137, VM-147, VM-176, VM-192) or of the device queue (VM-13).

**Sizing note (said aloud, per `notes/PhaseSizingGuidance.md`):** eight members are seven acceptance units, more than the guidance's two phase-sized units. The composition is hers ("22 is fine, composition is fine"); the members are S/M and share one theme and one evidence instrument (the readout). Each unit gets its own implementer session; the one ladder reads the whole diff.

**P-64-1 — CLOSED BY HER WORD (2026-11-19, §2 "The phone"):** no "before" run on her phone for this run's fixes; the phone step is ONE install of the wave-1 result after all four runs have merged, prepared by the last merger, her hands at a sitting before wave 2; the readout's first numbers on her phone are the baseline tuning starts from. The simulator's before-and-after numbers (batch 3) carry each fix's evidence. The BEFORE commit below stays named for the record and is no longer an ask. The paragraph that follows is the question as first cut, kept as written.

**The before-and-after question, and how this run keeps it honest while she is away (as first cut — see the line above).** Her phone can take a build only with her hands, so the "before" run on her phone cannot happen tonight. Options: (a) stop after VM-65 until her sitting; (b) build the fixes on the branch after VM-65, and keep the VM-65-only commit as the named BEFORE build, so her sitting installs BEFORE, runs the readout, installs the tip, runs it again; (c) skip the phone's before numbers. Built: (b). It keeps her rule (numbers before and after, on her phone, her library) and loses nothing of the night. The BEFORE build's commit is recorded in §5 the moment batch 1 closes, and no batch after it may change what the markers measure without saying so. The simulator's before-and-after numbers come from VM-66's tests, which is why VM-66 runs before any speed fix.

**Batch order** (strictly sequential; each is one implementer session):

| # | Batch | Members | Unit and its evidence |
|---|---|---|---|
| 1 | The timing layer and its readout | VM-65 | Markers + readout working in Release and Debug; pure-brain tests; a simulator walk showing real numbers in the readout. Then: the BEFORE commit named. Her phone: HELD. |
| 2 | The keystroke fence for structural flights | VM-2 | The red-on-old store pin per door (divide, merge, extract / make block, insert below); phone suites green. Editor seam. Does not wait for numbers. |
| 3 | The speed tests run her paths | VM-66 | The walk starts live updates, the shell, the push; Library wakes counted; a nine-wing fixture; the BEFORE simulator numbers recorded (median and range). |
| 4 | Launch and unlock stop scanning every table | VM-67 | Owner adoption no longer O(corpus) per launch; state-transition tests; before/after from batch 3's tests. Sync start; schema only if an index is the right fix. |
| 5 | The Library pages and stops re-reading | VM-68 | Keyset pages past 200; held reads viewport-shaped; the off-screen Library stops waking per autosave; wake counts before/after. |
| 6 | A note is read once and released | VM-69 · VM-70 | One projection read per open; the autosave coordinator released on close; the twin count settled; counts before/after. Editor seam. |
| 7 | Leaving saves once | VM-71 | One savepoint attempt per note on leaving; the capture box's first save does not wait behind a long note's teardown; the lock's behaviour unchanged. |

After batch 7: the ladder (Fable; up to FIVE rounds by her ruling in §2, a further round only while the last found a new BLOCKER or MAJOR), then the merge gate's whole-phone and whole-Mac windows on the tree that holds the ladder's fixes and main, then the closeout. *(Corrected at the ladder: this line first read "the whole-phone and whole-Mac windows, then the ladder (Fable, up to three rounds)" — the order as run, and the cap as ruled, are the ones above.)*

## 4. The batches

### Rules common to every batch

- **Verify the audit before building on it.** Audit F was read at main `5dde1bcf9`; lines have moved. A TRACED claim you cannot find in today's tree is reported, not assumed.
- **A fix that claims speed reports numbers before and after**, from the timing layer (batch 1) or batch 3's tests, as a median and a range over at least five runs, never a single number. A simulator number is quoted as a simulator number.
- **P1 is the yardstick:** no cost that scales with the note or the corpus is added anywhere, and the timing layer itself is bounded (a fixed ring, O(1) per mark).
- **What stays out:** the lock's behaviour on leaving and returning (wave 2, VM-103); the purge janitor's scans and the sync aftershock (wave 4, VM-176…VM-185); the capture box's layout and its focus choreography (wave 2, VM-72); row previews (wave 2, VM-87). If your fix needs one of these, stop and report.
- **The stage facts for this window (from the coordinator, nov18, binding):** the phone suites run on the standing simulator, iPhone 17 Pro / iOS 26.2, addressed by its UDID (`<simulator-udid>` — the orchestrator's GO message carries the value; it never enters a commit) — booted fresh inside the claim, left to settle before the launch (a back-to-back boot can refuse with SpringBoard "Busy / failed preflight", 0 executed), and SHUT DOWN before release. `-only-testing` takes TYPE names, never file names, and the list is a zsh ARRAY. A result line gives executed counts (for a Swift Testing suite, the Swift Testing pass count), names EVERY failing test, and says: simulator shut down, no Variorum instance left, any new `Variorum-*.ips` or Problem Reporter window. A timing red that appears while another session's work loads the machine is re-run ALONE before it counts as red, and the line says so. While the coordinator has announced a QUIET window (a whole-Mac-target run or a merge gate), run no whole-package `swift test` and no cold or full `build-for-testing`; small targeted runs and editing are fine. A Debug walk of the phone app stays signed out, never presses Resume, uses no test account, and says what it left behind on the device.
- **The Sync/-custody slot is this run's by the coordinator's explicit grant (2026-11-19 03:07 MST)**, scoped to: the services' sync start (`Shared/AppServices.swift` owner adoption, `Operations/OwnerIdentity.swift`), a possible local-only index migration, and the savepoint calls on the phone's leaving road beside `MobileRelock`. Before ANY line lands inside `Sources/VariorumCore/Sync/` or in custody/keychain code, stop and report: the orchestrator must tell the coordinator first. A migration that turns out to be synced is a SyncSpec §12 lockstep event and stops the batch.
- **Shared files with other wave-1 runs:** (also: VX-980 changes the guard inside `SearchComposer.listingNarrowing`, which `Queries/LibraryPaging.swift` calls; it does not edit that file.) VM-55 edits the phone's listing call sites and `Shared/AppSession.swift`; VM-78 edits the note's masthead. Keep your diff in those files as small and as local as the fix allows, so the later merge is a clean one.

### Batch 1 — VM-65: the timing layer and its readout

**Extra reading:** audit F §9–§11; the existing diagnostics face (`Features/Write/MobileEditTrace.swift` and its Settings rows) as the precedent for a Release-shipped diagnostic.

**The unit.** A timing layer that works on her real library in a Release build, and a readout she can open on the phone.

1. **The brain** (shared, pure, headless-tested): named marks and spans over a monotonic clock; a bounded in-memory record; per-span statistics — count, median, minimum, maximum, last. It also emits `os_signpost` intervals under the app's subsystem so an Instruments session, if one is ever wanted, sees the same spans. It records durations and counts only. Put it where headless `swift test` reaches it unless the tree's layout argues otherwise; say where and why.
2. **The marks, at the moments she named** — the tap on the capture box · the keyboard up · File (and Open: the press) · the note on screen (first text painted) and the keyboard live in it · unlock (Face ID or passphrase accepted) · the store opened · the shell on screen · the library ready (the Library's first listing delivered). And the cheap counts later batches answer to: full note-projection reads per open; editor view-model constructions per open; Library listing re-runs and deliveries per autosave; savepoint attempts per leaving; the duration of owner adoption and of each sync round (count of rows sent and received, never content). F §11's flows F1–F6 are the guide to which spans matter; add a mark only where a later batch or her two lags need it.
3. **The readout** on the phone: where the edit trace's diagnostics live today is the proposed home (PROVISIONAL — say what you chose and the alternative). Per span: how many runs, the median, the range, the last. A Reset. A Copy that puts the table on the clipboard as plain text, so she can paste it to a session. Plain, short labels in her words ("Tap the box → keyboard up"), marked DRAFT for her wording pass.
4. **Survival:** numbers must survive the app being backgrounded and locked, since the unlock span crosses it. Whether they survive a full quit (a cold-launch span) is yours to design; if you persist, persist durations and counts only, locally, outside the store, and say where.

**Evidence:** brain tests headless (statistics, the ring's bound, an unmatched begin, a re-entrant span); the phone target builds in Debug and Release; phone suites green for what you touched; one simulator walk (the orchestrator's stage window) — launch, tap the box, type, Open, back, open a note from the Library — ending on the readout showing non-zero numbers for those spans, captured.

**Not in this batch:** any fix. If a mark reveals something broken, record it.

### Batch 2 — VM-2: the keystroke fence for structural flights

**Extra reading:** `notes/TEXTKIT2_NOTES.md` (the iOS findings in §3, and §4); `notes/plans/fixes/vm-5-stability-pass.md` MAJOR 1 (the measured probe, the pin shape, the fix sketch); the Mac's fence (`EditorSurfaceController`'s `runStructural` and `beginDeferringKeystrokes`); audit C (`notes/plans/vm-44/audit/C-the-note.md`) E10 and §2.5; MobileSoul §5 item 2.

**The unit.** On the phone, no keystroke, autocorrect commit or dictation commit that lands inside a structural flight's window (from the pre-commit flush to the settled surface) can write a stale whole-block autosave. The store pin from the VM-5 pass (probe 2 inverted) is red today and green after, for divide; its twins cover merge (prose must not land in a released block's variant), extract / make block, and insert block below.

**The design choice (PROVISIONAL, options in your closeout):** refuse-and-speak with the existing sentence ("Another structural change is still landing."), or defer-and-replay as the Mac does. The minimum correct fix is the gate consulting the flight; prefer the shape that never drops her keystroke if it can be made honest on the phone's async road, and say what autocorrect and marked text do under it. No new copy.

**Evidence:** the pins, red on old by revert; the phone's editor suites green; the DEBUG identity audit quiet.

### Batch 3 — VM-66: the speed tests run her paths

**Extra reading:** audit F §9; `VariorumMobileTests/MobilePerfWalkTests.swift`, `MobileShelfPerfTests.swift`, `Features/Perf/MobilePerfFixtureSeeder.swift`.

**The unit.** The phone's performance tests measure what she feels, repeatably, on a simulator: the walk starts the note's live updates (`start()`), mounts through the shell and the push where a test host can, and reads the timing layer's spans and counts from batch 1; the capture-box test counts Library wakes per autosave; the fixture gains a nine-wing shape; the stale doc comment on the launch-path tests is corrected. Budgets that exist stay; a new budget is PROVISIONAL and written with its measured basis.

**It ends by recording the BEFORE numbers** in §5 of this record (median and range, n ≥ 5): note open (short and 100k), the hand-off's counts (projection reads, editor constructions), Library wakes per autosave, owner adoption at fixture scale, savepoint attempts per leaving. These are the numbers batches 4–7 are judged against.

### Batch 4 — VM-67: launch and unlock stop scanning every table

**Extra reading:** `notes/SyncSpec.md` in full; audit F §3 and §6; `Sources/VariorumCore/Operations/OwnerIdentity.swift`; the services' start in `Shared/AppServices.swift`.

**The unit.** Owner adoption stops costing a full scan of every synced table on every launch and every unlock, and stops holding the runner and the writer when there is nothing to adopt. Rows that genuinely need an owner still get one (S4), on every road they do today.

**Options to weigh and record:** a partial index per table on the rows still lacking an owner (a local schema change: its own commit first, and say what SyncSpec §12 makes of a local-only index — the mirror is untouched); a cheap existence probe before the write transaction; a recorded "adopted for this owner" fact with an honest rule for when it goes stale. Pick the one that cannot silently skip a row that needs adopting. Also report, without fixing, what else the first round after launch scans (the janitor is wave 4's), and whether adoption plausibly contributes to the minute-long empty round she saw.

**Evidence:** state-transition tests (rows without an owner are adopted; nothing is written when none exist; the mixed case); the query plan showing no full scan; before/after from batch 3.

### Batch 5 — VM-68: the Library pages and stops re-reading

**Extra reading:** audit A (`A-shell-library-wings.md`) B1, B2 and §3.2; audit F §5, §7, §8; `notes/plans/vm-44/plans/dependency-notes.md` §1 items 9–10; `notes/SurfaceContracts.md` ▸ The Library; the Mac's paging (`catalogNotesPage`, `LibraryPaging.swift`); VX-618's ticket text in `notes/TICKETS.md`. Before starting, merge `origin/main` into the branch if VM-55 has merged, and read what it changed in the Library view model.

**The unit.** The phone's Library lists every note by pages (a page, never a cap) through the Core paging read the Mac uses; its held reads are viewport-shaped; a write that changes nothing the Library shows does not re-run a corpus-sized query or re-draw the hidden Library. The bookless (Pool) listing stops testing every note against every gathering's rule on each write, and is held only while it is the listing shown. Row previews are NOT built here (wave 2), but nothing built here may force them onto the held read later.

**Evidence:** the 201st note is reachable by scrolling (a pin, red on old); Library wakes per autosave before/after (batch 3's count); query plans; the Mac's Library tests green if a Core read changed.

### Batch 6 — VM-69 and VM-70: a note is read once, and released when it closes

**Extra reading:** `notes/TEXTKIT2_NOTES.md`; audit F §2 (C, D), §4, §12.4; audit C §2.16; `Features/Write/MobileWriteView.swift`, `MobileEditorViewModel.swift`, `MobileLivenessAuthority.swift`, `Shared/AppSession.swift`'s autosave registry. Before starting, merge `origin/main` if VM-78 has merged.

**The unit.** Opening a note reads its projection once before first paint and does not read it again for the live updates' first delivery; the liveness check, the load and the chips cost no redundant round trips (the chips stop reading every book and every tag where a scoped read answers); the chrome is laid out once per open, not three times. Closing a note releases its autosave coordinator after its pending text has landed; the registry no longer grows per note opened. The twin question (are the seven models built twice per push?) is settled by batch 1's construction count, and fixed only if the count says so.

**Hazards to answer in the closeout:** a remote change arriving between the load and the first delivery must still land; a release must never drop unsaved text or race the leaving savepoint; a stood-down editor on another tab keeps working.

**Evidence:** counts before/after (projection reads per open: 2 → 1; registry size after N opens and closes); pins red on old; the editor suites green.

### Batch 7 — VM-71: leaving saves once

**Extra reading:** audit F §1 (1D), §6 (6B, 6C); OverallModel §3 on `closeAutoCommit`; `Features/Shell/MobileShellRouter.swift`, `Features/Protection/MobileRelock.swift` (read only what the savepoint calls need), `MobileWriteView.swift`'s `onDisappear`.

**The unit.** Leaving a note or the app makes one savepoint attempt per note that needs one, not up to three; coming back from a long note, the capture box's first save does not wait behind that note's teardown and savepoint. The savepoint itself stays (the cadence occasion, deduped). What leaving does to the lock is unchanged, to the line: this batch may not move, gate or reorder the lock.

**Evidence:** savepoint attempts per leaving before/after (batch 1's count); a pin for "the box's first mint is not queued behind the previous note's leaving work" in the shape the runner allows; the relock and protection suites green and unchanged.

## 5. LIVE STATUS

| Batch | State | Commits | Notes |
|---|---|---|---|
| 1 · VM-65 | **CLOSED 2026-11-19** | `65d70fe9f` `feef85c7a` `f6389e3b5` `808f333a8` `914278cfa` | code state `808f333a8`; stage results in "Orchestrator's stage results" below |
| 2 · VM-2 | **CLOSED 2026-11-19** (r2; three stage cycles) | see the batch 2 block; r2 code `2a3fd3a52` | stage results in "Orchestrator's stage results" below; PROVISIONAL P-2-1, P-2-5; residual VM-226 |
| 3 · VM-66 | **CLOSED 2026-11-19** | see the batch 3 block; built at `d2cef56be` | the BEFORE numbers are in "Orchestrator's stage results" below |
| 4 · VM-67 | **CLOSED 2026-11-19** | see the batch 4 block; schema `0e9948d03`, op `e6d16fca7`, built at `8e4e73e01` | headless whole package, phone and Mac pieces green — "Orchestrator's stage results" below |
| 5 · VM-68 | **CLOSED 2026-11-19** | see the batch 5 block; built on the merged tree at `dcea98cee` | suites, red-on-old and the walk in "Orchestrator's stage results" below; PROVISIONAL P-68-1, P-68-4, P-68-5 |
| 6 · VM-69 · VM-70 | **CLOSED 2026-11-19** (r1) | see the batch 6 block; r1 code `36cddcf60` `9821ffef3` `ce3c4e75b` | first window NOT green (the release lived in `deinit`); r1 green on the final tree — "Orchestrator's stage results" below; residual VM-227 |
| 7 · VM-71 | **CLOSED 2026-11-19** | see the batch 7 block; built at `c9b574513`, re-checked on r1 (`a61e4f7c9`) | Mac and phone pieces green on the final tree; PROVISIONAL P-71-1; the combined walk for batches 6 and 7 is owed before the run closes |
| Ladder r1 · fix pass | **DONE 2026-11-19** — settled by the merged tree's stage window (finding 2 red on its hunk-reversed build, green alone and in company; "Orchestrator's stage results" ▸ "The merged tree (main's VM-55 in)") | see the fix-pass block below | the reviewer's final calls applied (finding 1 arm (a); 2, 3, 5, 6 confirmed as applied); part 2 ran as the merge block below. *(Was: IN-PROGRESS, "owed: the stage" — flipped at ladder round 3, finding 2(c).)* |
| The merge of main (VM-55) | **DONE 2026-11-19** — merge `f03d59ae3`; stage runs owed (the orchestrator's) | see "The merge of main (VM-55) · LIVE STATUS" below | merge `origin/main` at `eb18888db` (VM-55's `66337ff08`); re-land the two conflicted Shell files; the semantic merge (a)–(f); builds into `vm64-gate` / `vm64-gate-red` |
| Ladder r2 · fix pass | **DONE 2026-11-19** — part B built and the whole Core package green (`74d91c666`); settled by its stage window: the seven meant reds on `vm64-gate2-red` and no other, green alone and in company, the gated suite alone 13 passed ("Orchestrator's stage results" ▸ "Ladder round 2's fixes — THE STAGE WINDOW") | see "Ladder round 2 — fix pass · LIVE STATUS" below | the responses first, the no-choice fixes with their pins, the final calls in the second turn, part B's builds. *(Was: IN-PROGRESS, part B waiting on the QUIET window — flipped at ladder round 3, finding 2(c).)* |
| Ladder r3 · fix pass | **DONE (both turns)** — the final calls applied (`6aa357bff`): (i′) confirmed with its guard; `merged` bounded, pin first; the migration comment. Owed with the gate tree after VM-78's merge-in: finding 1's red build and the hosted runs of its suite | see "Ladder round 3 — fix pass · LIVE STATUS" below | the last round (no major found). *(Was: FIRST TURN DONE, the arms waiting.)* |
| The merge of main (VM-78) and the gate tree | **IN-PROGRESS** — see its block below | see "The merge of main (VM-78) and the gate tree · LIVE STATUS" below | merge exactly `f909d6714` (VM-78's PR #15); the five shared files read; builds into `vm64-gate3` / `vm64-gate3-red`; the whole Core package |

### Batch 1 · VM-65 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** Batch 1 is a feature batch (no bug-class row; "not in this batch: any fix"), so there is no
red-on-old pin to take; its evidence is the brain's headless tests, the builds, the phone suites and the walk.

**The settled design** (verified against today's tree first — audit F's file:line claims for every mark site below still
hold at this branch's base `21747b9de`: `MobileWriteView.swift` 143-226, `MobileEditorViewModel.swift` 549-597 / 667-678 /
827-867, `MobileQuickNote.swift` 882-1110 / 1183-1203, `AppServices.swift` 518-595, `OwnerIdentity.swift` 87-104,
`MobileLibraryViewModel.swift` 316-343, `AppSession.swift` 660-691):
- **The brain** in `Sources/VariorumCore/Diagnostics/` (a new folder: the timing layer is neither a domain rule nor a
  query, and Core is where headless `swift test` reaches it): a `Mutex`-guarded recorder generic over the catalog's two
  key enums — keyed spans (begin here, end there; a re-begin restarts, a begin older than its stale limit is dropped as
  abandoned, an end with nothing open is counted), token spans (re-entrant by construction), value samples, monotonic
  counters, and COUNTING WINDOWS (events of named counters between an opening act and a closing act or deadline, recorded
  as one sample — "reads per open", "savepoint tries per leaving", "Library re-reads per save"). Per series a fixed ring
  (64): count, median, min, max, last. `os_signpost` intervals under `io.lduarte.Variorum` / `timing`. Durations and
  counts only — the API has no string parameter at all.
- **The catalog and the one recorder** in `App/Variorum/Shared/AppTiming.swift` (Shared code marks owner adoption, sync
  rounds, savepoints and autosaves); the recorder is DISABLED unless the phone enables it at launch, so the Mac — which
  compiles every Shared mark — records nothing and its behaviour is unchanged.
- **The phone's face** in `VariorumMobile/Features/Perf/`: the launch hook (enable, restore, the launch spans begun at the
  process's true start), the keyboard watch (`keyboardDidShow` ends "→ keyboard up" spans), the next-frame tick (a span
  "on screen" ends at the display-link tick after the render), persistence at backgrounding, and the readout.
- **The readout** (PROVISIONAL): Settings ▸ Diagnostics, a "Timing…" row beside "Edit trace…"; per span runs · median ·
  range · last; Reset; Copy (plain text). Labels DRAFT.
- **Survival**: the recorder is process-global (outlives the session, the shell and a Castle lock); it is also written to
  `UserDefaults` (durations and counts only, outside the store) at every backgrounding and restored at launch, keyed to
  the running binary's build fingerprint so a new install (the BEFORE build vs the tip) starts clean.

| Piece | State |
|---|---|
| P1 — the brain + headless tests (Core `Diagnostics/`) | DONE — `TimingStats` · `TimingRecorder` · `TimingReport`; `swift test --filter TimingRecorderTests` 24/24 in 1 suite green (headless, no stage) |
| P2 — the catalog, the one recorder (`Shared/AppTiming.swift`) + `endIfOpen` in the brain | DONE (this commit) — brain 25/25 |
| P3 — the marks (phone + Shared sites) | DONE (this commit) — phone Debug `build-for-testing` green, no warning in a touched file; the walk PENDING |
| P4 — the readout + the Settings row | DONE (this commit) — face PENDING the walk |
| P4b — **survival reworked to the author's sharpening (below)**: per-build tables in a file in the app's container, deferred saves off the timed path, the previous build's table on the readout, since-days | DONE (this commit) — Core `TimingBook` + the recorder's since-day, change handler and `absorb`; brain 31/31 headless; the phone's `MobileTimingStore` (`Library/Application Support/Timing/timing.json`, saves 20 s after the first unsaved change and at every backgrounding, on its own utility queue); the readout shows this build then the previous; new phone suite `MobileTimingTests` (4) BUILT, its run PENDING the stage window |

**The author's sharpening (relayed by the orchestrator mid-batch, 2026-11-19; she will NOT run the readout tonight — "leave
it in the handoff bundle for me to do later"; the BEFORE build may live on her phone for days, the AFTER build installed
over it much later):** (1) the statistics PERSIST across a full quit and an install-in-place — durations and counts only,
bounded, local, outside the store, in the app's own container; O(1) per mark; no write on the path it times (batched or
deferred; a crash loses at most the unsaved tail); (2) samples kept PER BUILD (her words name the bundle's build number plus
the short version for display); a new build never blends into the old; the previous build's table stays readable on the
readout under this build's, Copy exports both each headed by its build; Reset clears this build's table only (what clears
the older one: simple, PROVISIONAL); (3) the readout says since when each table has collected (the day of its first sample)
and how many samples each span holds. Brain tests for the per-build keying, the bound, and the round-trip through the
persisted form.
| P5 — builds: phone Debug `build-for-testing`, phone Release `build`, Mac `build-for-testing` | DONE at `808f333a8` — all three `** … SUCCEEDED **`, no warning in a touched file (DerivedData `App/Variorum/DerivedData/vm64-b1/`) |
| P6 — stage window (GO from the orchestrator): phone suites + the simulator walk + captures | READY — awaiting the GO; the commands are in §7 batch 1 ▸ "The stage window" |
| P7 — closeout in §7; the BEFORE commit named here | IN-PROGRESS — §7 written; its PENDING lines flip after P6 |

DerivedData: `App/Variorum/DerivedData/vm64-b1/` (gitignored). Screens: `notes/plans/vm64-screens/` (gitignored, added
by this batch).

**The BEFORE build:** code state `808f333a8` (today's app plus the timing layer, nothing else). Named for the record; by her word (§2) it is not installed — her phone's first timing numbers come from the wave-1 build.

**Held for her next sitting:** the ONE wave-1 install on her phone after all four wave-1 runs have merged (phone on the cable, unlocked, Variorum closed; `notes/plans/vm-44/plans/vm-45-install-runbook.md`), prepared by the last merger so a fresh session can run it; then her use of the phone fills the readout. Her wording pass on the readout's labels.

**Machinery notes** (deaths, resumes, stage windows): none yet.

### Batch 2 · VM-2 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight** (the red-on-old revert ran and is RESTORED: the three phone production files were checked out from base `9cf3b3688` over the fix `f83122794`, the red products built, then `git checkout HEAD -- <the three>`; `git status` and `git diff HEAD` empty after). The red-on-old proof is a SECOND build of the pins against the pre-fix production files
(`git checkout <base> -- <production files>` AFTER the fix is committed and pushed, build-for-testing into
`App/Variorum/DerivedData/vm64-b2-red/`, then `git checkout HEAD -- <the same files>` and a clean `git status`). When
that revert starts, this line changes to name it and the base commit; until then the tree is never mid-revert.

**The traced mechanism (verified against this branch's tree, base `9cf3b3688`).** The phone's structural doors
(`MobileStructural.swift`: divide :82, merge :217, extract / make block :357, insert below :518 — the VM-5 record's
lines still hold) latch `structuralInFlight`, flush, then SUSPEND (the fan read, the op on the runner, the settle's
flush and read) while the surface and `BlockRangeIndex` still show the pre-op note. The gate
(`MobileEditorViewModel.shouldChangeText`, today :1544–1658 — audit C's :1531–1573 moved) never reads the latch, and
the text view stays editable. A keystroke in that window routes `.block(i)` against the pre-op index;
`recordAutosave` (:1977) records the WHOLE pre-op block text; the door's own settle (`refreshTakesFromStore`, :1449)
flushes it after the op committed. **One correction to the VM-5 record:** it says the flush "writes unconditionally"
— since VX-683 B the write carries `expectedText` (the ledger's pre-edit text), the row no longer holds it, so
`Operations.autosave` RESCUES: the pre-op text + the keystroke keeps the chosen take and the op's real result becomes a
spurious `'conflict'` take. The divide is still visibly undone and the moved half still reads twice; merge still lands
the prose in a RELEASED source's take (gone from the note); extract and make block duplicate the lifted span the same
way. Gate-less roads (a programmatic `replace(_:withText:)`/`deleteBackward()` — M25's measured bypass — and the
system's autocorrect, dictation and marked-text commits) reach `storageDidEdit` with no arming, route by
`fallbackVerdict` to the same `.block(i)` arm, and take the same stale write.

**The settled design (PROVISIONAL P-2-1, options in the closeout): a fence from the latch to the settled surface —
typed keys DEFERRED and replayed, everything else REFUSED or WITHHELD, and either spoken once.**
- **The brain** — `Sources/VariorumCore/Domain/StructuralFlightFence.swift` (pure, headless; the `MarkdownCaretRescue`
  precedent for a live-surface brain in Core): the fence's phase (open · flying · settling), the deferred input queue
  (insert text · delete backward, coordinate-free, in order; a composition in progress is never deferred), the
  "something was refused or withheld" debt spoken once, and the landing rule (the fence drops only when the surface
  holds the post-op store: no forced render and no deferred projection outstanding).
- **The face** (the phone): the latch's `didSet` raises and lands the fence; `MobileEditorTextView.insertText` /
  `deleteBackward` hand typed keys to it (the Mac's `beginDeferringKeystrokes`, UIKit-spelled); the gate refuses any
  other edit while it is up with `StructuralUndoCopy.anotherIsLanding` (the one home of the existing sentence); a
  gate-less edit while it is up keeps the tiling coherent but writes NOTHING toward the store and forces the settle to
  re-render from the store; at landing the queue replays through the policed input path at the landed caret, and the
  sentence is spoken if anything was refused or withheld. No new copy.
- **Not changed:** `BlockRangeIndex`'s regions, `runStructural` (Mac), the crystallizer's declared arms, `Sync/`.

| Piece | State |
|---|---|
| P1 — the brain `StructuralFlightFence` + headless tests | DONE (`76dbf89b2`; `putBack` removed at `f83122794` as dead API — the face replays whole and at once) — `swift test --filter StructuralFlightFenceTests` 10 tests in 1 suite passed (headless, no stage) |
| P2 — the phone's face (latch hook, input stash, gate belt, storage belt, landing + settle heal) | DONE (this commit) — phone `build-for-testing` green into `DerivedData/vm64-b2/`, no new warning in a touched file; behaviour PENDING the stage window |
| P3 — the hosted pins (probe 2 inverted per door: divide · merge · extract · make block · insert below; the three input roads on divide) | DONE (this commit) — `MobileStructuralFlightFenceTests` (10), BUILT; green run and red-on-old run PENDING the stage window |
| P4 — builds: phone `build-for-testing` green (`DerivedData/vm64-b2/`) · red-on-old build (`DerivedData/vm64-b2-red/`) · Mac `build-for-testing` (Core changed) | DONE — all three `** TEST BUILD SUCCEEDED **` at `f83122794` (the red one over the base's three phone files, cold), no new warning in a touched file |
| P5 — stage window (the orchestrator's GO): the pins green, the red build red, the phone editor suites green | Window 1 NOT GREEN · r1 cycle clean alone · the 49 run red on four state-dependent pins · TRACED · r2 APPROVED and BUILT (`vm64-b2r2`, `vm64-b2r2-red`) — READY for (i) the fence suite alone on each build, (ii) the 49 types from `vm64-b2r2` |
| P6 — closeout in §7 | DONE (this commit) — its PENDING lines flip after P5 |

DerivedData: `App/Variorum/DerivedData/vm64-b2/` (green) and `App/Variorum/DerivedData/vm64-b2-red/` (the red-on-old
build), both gitignored.

**Iteration r1 (after the first stage window, 2026-11-19 — the batch came back NOT GREEN; see the orchestrator's §5 block).**
Diagnosis from the logs, the six crash reports and the code (no stage). Every trap is the SAME road: `storageDidEdit`'s
`.refuse` arm (`MobileEditorViewModel.swift:1934` pre-fix / `:2089` fix), i.e. a character edit whose report did NOT bind
to a gate arming and whose fallback span crossed a separator. Per crashing test:
- `aGatelessEditDuringADivideIsWithheld…` (pre-fix AND fix): **the PROBE's own write**, not the fence. `systemEdit`
  inserts with font-only attributes at the END of a non-last block; iOS paragraph-style fixing widens the report forward
  through the paragraph's terminator (TEXTKIT2 §3's iOS finding; round 2's M12), so `fallbackVerdict`'s old span covers
  the separator and refuses — the verdict is `.refuse` before the fence's belt (in the `.block(i)` arm) is ever reached.
  Same write, same trap, on both trees; the merge pin's identical write in the LAST block routed on both (no separator
  past it). FIX: test-only — the window's gate-less edit lands in the last block (a routable edit, the belt's real job).
  M12 itself (an unroutable gate-less insert in a non-last block) heals by re-rendering from the store and writes nothing
  stale on either tree; it stays round 2's row, not this batch's.
- `afterTheFlightLandsTypingIsOrdinaryAgain` (pre-fix AND fix): a plain UIKit `insertText` at the START of a non-empty,
  non-last block after a divide — no fence code involved (it traps on the pre-fix tree). The same road traps the three
  replays on the fix build: `keysTypedWhileADivideLands…`, `aKeyTypedWhileAnExtractLands…`, `aKeyTypedWhileMakeBlock…`
  (the stack: `drainFlightFence` → `MobileEditorTextView.insertText` → `super.insertText` → the report). Every one of the
  four lands at a non-empty block's START; every UIKit insert that routed was mid-block, at a block's end, into an empty
  block, or in the last block. The fence's logic sends nothing down this road — it REPLAYS at the landed caret, which for
  divide / extract / make block is always such a start. WHY the arming did not bind there is NOT settled by reading. The
  recorded candidate is VM-19's class (VX-282 C-1, measured): `insertText` driven into a text view that is not the key
  window's first responder while another responder holds the keyboard's input session — and these pins host the view in
  no window at all, unlike the posture her phone types in (`MobileMarkdownCaretTests.host`).
- What r1 builds (test-only; no product line changes until the question is settled): (1) the pins take the production
  posture (the foreground scene's key window, the text view first responder, leftovers resigned; `.serialized`); (2) a
  debug assertion inside a pin is RECORDED AS A FAILING ISSUE, never swallowed, so the host survives and every pin
  reports; (3) road C as above; (4) a diagnostic suite (`MobileFlightFenceProbeTests`, prints `VM2-PROBE` lines from the
  E1 trace) that answers, in the same short cycle, whether a UIKit insert at a block start binds in each posture, with
  and without a divide before it. If it still fails to bind in the production posture, that is a pre-existing product
  defect (round 2's M27, never truly dissolved — VM-5's probe typed at block ENDS through the harness) and the replay
  road changes in r2 with its own red-on-old.
- r1 pieces: the test changes + the diagnostic suite — DONE (this commit); fix build `DerivedData/vm64-b2r1/` TEST BUILD
  SUCCEEDED, no warning in a touched file (the deprecated `UIWindow(frame:)` fallback copied from the caret suite was
  replaced by requiring the scene). The pre-fix build `vm64-b2r1-red/`: DONE — TEST BUILD SUCCEEDED (cold), the three
  phone production files checked out from base `9cf3b3688` over `05ca99e0d` and RESTORED (`git status`, `git diff HEAD`
  empty after). **No revert is in flight.** r1 is READY for the next short stage cycle (§7 batch 2 ▸ r1's commands).

**Iteration r2 (APPROVED by the orchestrator, 2026-11-19 — its calls are quoted in §7 batch 2 ▸ "Iteration r2").** Refuse-and-
say; the hold-and-replay mechanism removed whole; insert below exempt; the structural undo door hooked to the same fence;
every typed-key pin on her keyboard's road (the delegate consult, then the insert only on a yes); the probe suite deleted;
TEXTKIT2 §3 gains the measured `insertText` line. **No revert is in flight** until P-r2-6 says so.

| r2 piece | State |
|---|---|
| P-r2-1 — the brain without the input queue (`StructuralFlightFence`) + its tests rewritten | DONE (this commit) — `swift test --filter StructuralFlightFenceTests` 8 tests in 1 suite passed (headless) |
| P-r2-2 — the face: the stash and replay removed; insert below exempt; the undo door's latch hooked; landing only when no fencing latch is up | DONE (this commit) — phone `build-for-testing` into `vm64-b2r2` TEST BUILD SUCCEEDED, no new warning in a touched file |
| P-r2-3 — the pins on her keyboard's road (+ the undo door's pin, the insert-below exemption pin, the guard); the probe suite deleted | DONE (this commit) — 10 pins BUILT; runs PENDING the stage |
| P-r2-4 — TEXTKIT2 §3's measured line | DONE (`9b1451cad`) |
| P-r2-5 — the r2 closeout section (before the final builds) | DONE (this commit) — §7 batch 2 ▸ "Iteration r2" |
| P-r2-6 — builds: phone `vm64-b2r2` · Mac (the brain is Core) · pre-fix `vm64-b2r2-red` (revert announced first) | DONE — phone and Mac `build-for-testing` into `vm64-b2r2` (TEST BUILD SUCCEEDED at `2a3fd3a52`, no new warning in a touched file); `vm64-b2r2-red` = r2's pins over the base's four phone production files, built cold, TEST BUILD SUCCEEDED, files RESTORED (`git status`, `git diff HEAD` empty). **No revert is in flight.** READY for the stage (§7 batch 2 ▸ "Iteration r2" ▸ the commands) |


### Batch 3 · VM-66 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight, and none is planned.** Batch 3 is a TEST batch (VM-66 is Debt · Tests & tooling): it fixes no
behaviour, so it owes no red-on-old pin. Its counts that measure a defect are RECORDED, never asserted, so batches 4–7
can each turn one into an assertion that is red on today's code. No production behaviour changes; the one app-target
file touched is the DEBUG-door fixture seeder (an additive option, today's shape byte-identical).

**Audit F re-verified against this branch's tree** (base `ba3516a30`): the walk's `openSurface` still never calls
`start()` (`MobilePerfWalkTests.swift:188-205`); `MobileShelfPerfTests` still counts only the shelf's observation; the
fixture is still one wing (`MobilePerfFixtureSeeder.swift`); `MobileLaunchPathTests`' doc (`MobilePerfWalkTests.swift:949-994`)
still says the open is main-thread — false since 13l L-c (`Shared/AppBootstrap.swift:314-334`, the detached
`routeAndOpen`). Batch 1's marks are where its closeout says (`MobileWriteView.swift:154/201/226`,
`MobileEditorViewModel.swift:202/589/682/685/815`, `MobileLibraryViewModel.swift:324-346`, `MobileQuickNote.swift:883/935`,
`AutosaveCoordinator.swift:225-234`, `AppSession.swift:661`, `AppServices.swift:587-595`). The test host runs
`VariorumMobileApp.init` → `MobileTiming.start()`, so the app's ONE recorder is live there (and never persists —
`MobileTiming.persists`).

**The settled design:**
- **One new suite, `MobileHerPathsPerfTests`** (`.serialized`), which drives the REAL screen and the REAL shell and READS
  batch 1's spans, windows and counters off `AppTiming.recorder` (the one the marks feed — a test cannot hand the marks a
  recorder of its own, since GRDB's fetch closures do not inherit task-locals). Because that recorder is process-global,
  **the suite must run alone in its own `xcodebuild` invocation** (group (i) of the READY report) — any other suite
  running in parallel in the same process would add its opens and saves to these windows. Every measured series runs
  n ≥ 5 and prints ONE line `VM64-PERF|<series>|n=…|median=…|min=…|max=…|<unit>`.
- **Its worlds are on-disk copies** (`AppDatabase.backup(to:)` → `openStore(at:)`, the launch-path precedent — a WAL pool,
  encrypted by the open's own migration, as on her phone) of the static fixture worlds, one copy per test, so nothing it
  writes reaches the shared static worlds the other perf suites pin.
- **The fixture gains `.nineWings`** beside `.oneWing` (the default, unchanged): the same corpus generator, spread over
  nine wings, each with its own tag vocabulary, two books, one gathering and bookless (Pool) notes; a shape pin of its own.
- **The stale launch-path doc** is corrected in place.

| Piece | State |
|---|---|
| P1 — this live status | DONE (this commit) |
| P2 — the nine-wing fixture option (seeder) + its world and shape pin | DONE (`fd9184011`, `51440c726`) — built; the pin's run PENDING the stage window (group ii) |
| P3 — `MobileHerPathsPerfTests` (the VM64-PERF series) | DONE (`0bc11d9a9`, `51440c726`, `d2cef56be`) — built; its runs PENDING the stage window (group i, twice) |
| P4 — the launch-path doc corrected; pointers in the walk and shelf suites | DONE (`fd9184011`, `21fc776fb`) |
| P5 — builds: phone `build-for-testing` into `DerivedData/vm64-b3/` (no Shared/Core change ⇒ no Mac build) | DONE at `d2cef56be` — `** TEST BUILD SUCCEEDED **`, no warning in a touched file |
| P6 — closeout in §7 + the READY report's stage commands | DONE (this commit) — its PENDING lines flip after the window |

DerivedData: `App/Variorum/DerivedData/vm64-b3/` (gitignored).

**THE BEFORE NUMBERS (simulator) — PENDING the orchestrator's stage window** (group (i) of §7 batch 3 ▸ "The stage
window", run twice ALONE; lift with `grep '^VM64-PERF|' <log>`). These are what batches 4–7 are judged against; each
cell is `median (min–max), n` per run. The predictions are audit F's trace read on today's tree — predictions, never
assertions.

| Series | Unit | Run 1 | Run 2 | Predicted today | Tightened by |
|---|---|---|---|---|---|
| `note-open-to-screen-short` / `-100k` | ms | PENDING | PENDING | — | (batch 6 may move it a little) |
| `note-open-to-live-short` / `-100k` | ms | PENDING | PENDING | — | batch 6 (the second read goes) |
| `note-reads-per-open-short` / `-100k` | count | PENDING | PENDING | 2 | batch 6 → 1 |
| `shell-box-open-to-note` | ms | PENDING | PENDING | — | batches 6, 7 |
| `shell-box-file` | ms | PENDING | PENDING | — | batch 7 |
| `shell-box-open-to-live` | ms | PENDING | PENDING | — | batch 6 |
| `shell-box-editor-builds-per-open` | count | PENDING | PENDING | 1 or 2 (audit F 2D: unknown) | batch 6, only if > 1 |
| `shell-box-note-reads-per-open` | count | PENDING | PENDING | 2 | batch 6 → 1 |
| `shell-library-open-to-screen-short` / `-100k` | ms | PENDING | PENDING | — | batch 6 |
| `shell-library-editor-builds-per-open-short` / `-100k` | count | PENDING | PENDING | 1 or 2 | batch 6, only if > 1 |
| `shell-library-note-reads-per-open-short` / `-100k` | count | PENDING | PENDING | 2 | batch 6 → 1 |
| `library-rereads-per-box-save` | count | PENDING | PENDING | 2 (both listings) | batch 5 |
| `library-redraws-per-box-save` | count | PENDING | PENDING | 2 | batch 5 |
| `all-listing-rereads-per-box-save` | count | PENDING | PENDING | 1 | batch 5 |
| `bookless-rereads-per-box-save` | count | PENDING | PENDING | 1 | batch 5 |
| `library-listing-fetch-ninewings` | ms | PENDING | PENDING | — | batch 5 |
| `bookless-listing-fetch-ninewings` | ms | PENDING | PENDING | — | batch 5 |
| `owner-adoption-nothing-to-adopt` | ms | PENDING | PENDING | — | batch 4 |
| `owner-adoption-rows-nothing-to-adopt` | count | PENDING | PENDING | 0 (ASSERTED) | — (kept 0) |
| `savepoints-per-note-leaving` | count | PENDING | PENDING | 1 | batch 7 (stays ≥ 1, ASSERTED) |
| `savepoints-per-backgrounding-standard` | count | PENDING | PENDING | 1 | batch 7 |
| `savepoints-per-backgrounding-castle` | count | PENDING | PENDING | 3 (audit F 6C) | batch 7 → 1 |
| `autosave-registry-growth-per-open-close` | count | PENDING | PENDING | 1 | batch 6 → 0 |
| `note-rereads-per-save-100k` | count | PENDING | PENDING | 1 | wave 4 (VM-176) |
| `note-deliveries-per-save-100k` | count | PENDING | PENDING | 1 | wave 4 (VM-176) |
| `note-delivery-ingest-100k` | ms | PENDING | PENDING | — | wave 4 (VM-176) |

### Batch 4 · VM-67 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** Two reverts RAN and are RESTORED, each of the same two files
(`Sources/VariorumCore/Persistence/Migrations.swift`, `Sources/VariorumCore/Operations/OwnerIdentity.swift`) to base
`96dfa82b5` after the fix was committed and pushed, each restored by `git checkout HEAD --` with `git status` and
`git diff HEAD` empty after: (1) the red-on-old (P4); (2) the headless BEFORE number (P6). The suites are green again
on the restored tree.

**The mechanism, re-verified on this tree (audit F 3A/6A — still TRACED as written):** `AppServices.connectSyncIfAllowed`
(`Shared/AppServices.swift:518`) runs `runOwnerAdoption` (:584) first on every launch with a persisted session, every
unlock (a fresh `AppServices.start`), every sign-in, Resume and the first round after an account act; it runs
`Operations.adoptOwnerID` (`Operations/OwnerIdentity.swift:87`) on the ONE serial runner, which opens ONE write
transaction and runs `UPDATE <t> SET owner_id = ? WHERE owner_id IS NULL` for each of the eleven synced tables that carry
`owner_id` (container, block, tag, wing, shelf, reading, reference, canvas_layout, lens, block_comment, purge_intent). No
index serves `owner_id IS NULL` (`Migrations.swift` has none), so each UPDATE is `SCAN <t>` — a full read of every
owner-carrying table, through SQLCipher's page decrypt, holding the runner AND the writer, even when nothing is unowned.

**The settled design:**
- **Schema (its own commit, first):** `v1_38_owner_adoption_index` — eleven partial indexes
  `idx_<table>_unowned ON <table>(owner_id) WHERE owner_id IS NULL`, one per owner-carrying synced table. Empty in
  steady state; holds exactly the rows adoption exists to find. *[Ladder round 3, finding 5(c): the SIGNED-IN steady
  state. In a library that has never signed in (a local-only Mac library, the dev store) every row of the eleven
  tables is unowned, so each index holds every row of its table — one small index entry per row written, for an
  adoption that never runs there.]* LOCAL ONLY — not a SyncSpec §12 lockstep event
  (v1_34 / v1_36's class: no table, no column, no classification; the marker stays 15). Verified: no in-flight branch
  adds a migration (`git fetch`; every remote branch's diff against main touches no `Persistence/` file), so `v1_38` is
  free. Query plans (sqlite 3.54 CLI, to be re-read through the real SQLCipher build by the pin): the probe and the
  UPDATE both `SEARCH <t> USING (COVERING) INDEX idx_<t>_unowned (owner_id=?)`; `owner_id = ?` and
  `owner_id IS NOT NULL AND owner_id != ?` keep their plans (the partial index is unusable for them — no plan churn).
- **The op:** `adoptOwnerID` becomes probe-then-write inside ONE writer access (`writeWithoutTransaction` — on the
  writer's own FIFO queue, so it sees every write queued ahead of it: today's visibility, exactly): per table an
  `EXISTS` probe through the partial index; nothing unowned ⇒ the all-zero report, NO transaction opened, nothing
  written; otherwise today's UPDATE set unchanged inside ONE IMMEDIATE transaction (GRDB's own `write` shape). The
  predicate, the call sites and the occasions are unchanged, so every row today's code adopts is adopted at the same
  occasion.
- **`AppServices`: unchanged** — the "Owner check at start" span and the rows-stamped sample keep measuring the same
  thing (the op's wall time on the runner; the report's total).
- **The pins:** Core headless — nothing to adopt ⇒ the writer runs no BEGIN and no UPDATE (a GRDB statement trace); every
  statement adoption runs reaches an owner table only through its adoption index (`EXPLAIN QUERY PLAN` of each traced
  statement); state transitions per road (signed-out mints in every owner table, live and tombstoned; the mixed case;
  an account change; outbox and `updated_at`); a schema pin that every owner-carrying table carries its index. Hosted —
  the same two guarantees asserted in `MobileHerPathsPerfTests` at fixture scale on the encrypted on-disk store.

| Piece | State |
|---|---|
| P1 — this live status | DONE (this commit) |
| P2 — the schema commit (`v1_38`) + the index-set pins' justified edits | DONE (this commit) — `swift test --filter 'MigrationTests\|BlockCommentTests'` 44 tests in 5 suites passed (the new `theOwnerAdoptionIndexesArriveForAnOlderStoreOnePerOwnerTable` among them); `SyncSchemaTests\|AuthRLSDDLTests\|LocalMachineryRecreationTests\|StorePlaintextExportTests\|PlaintextExportImportTests\|LibraryClassifier` 133 tests in 6 suites passed — the registry walk (`SyncSchemaTests.swift:14-19`, `type = 'table'`), the column walk (`:93`) and the mirror-marker pin (`AuthRLSDDLTests.swift:934-949` against the constant `SyncSchema.swift:170`) all untouched by an index |
| P3 — the op (probe-then-write) + the Core pins and state-transition tests | DONE (this commit) — `OwnerAdoptionTests` (8) + `OwnerIdentityTests` (8): 16 tests in 2 suites passed. On the SCHEMA-ONLY tree (`0e9948d03`: the index landed, the op unchanged) the same suite ran 8 tests, 4 issues: the three "writes nothing" pins red (the op ran `BEGIN IMMEDIATE TRANSACTION`, eleven `UPDATE … WHERE owner_id IS NULL`, `COMMIT TRANSACTION` with nothing unowned), the plan pins GREEN — the index alone fixes the scan; the probe is what stops the write |
| P4 — red-on-old (revert the two production files, run the pins, restore) | DONE — on the pre-fix tree `OwnerAdoptionTests` ran 8 tests, **5 failed with 7 issues**: `withNothingUnownedTheWriterRunsNoTransactionAndNoWrite` (BEGIN IMMEDIATE + eleven UPDATEs + COMMIT) · `everyStatementReachesAnOwnerTableOnlyThroughItsUnownedIndex` ×2 (adopting AND idle: `UPDATE container … → SCAN container`, `→ SCAN block`, … every owner table) · `signedOutRows…` (its idempotent second pass wrote) · `anAccountChange…` ×2 (both quiet passes wrote) · `aStoreFromBeforeTheIndex…` (scanned). GREEN on both trees, by design (they pin S4 behaviour that must not move): `everyOwnerTableHoldsARowFromTheSeed` (the seed's guard), `theMixedCaseAdoptsOnlyTheUnownedRows`, `aRowFromAWriteAlreadyQueuedIsAdoptedByThatPass`. Restored; green again |
| P5 — the hosted assertion in `MobileHerPathsPerfTests` | DONE (this commit) — inside `ownerAdoptionWithNothingToAdoptIsMeasuredAtFixtureScale`, AFTER its measured series (which stays untraced and unchanged): one more pass traced on the store's writer asserts no write statement and every statement through its unowned-row index (the `OwnerAdoptionTrace` helper, nonisolated); no other series touched. Phone `build-for-testing` into `DerivedData/vm64-b4/` `** TEST BUILD SUCCEEDED **`, no warning in a touched file; its run PENDING the stage window |
| P6 — `swift test` (touched suites + migrations / schema / sync-schema suites); phone + Mac `build-for-testing` into `DerivedData/vm64-b4/` | DONE — `swift test --filter 'OwnerAdoptionTests\|OwnerIdentityTests\|MigrationTests\|BlockCommentTests\|SyncSchemaTests\|AuthRLSDDLTests\|StorePlaintextExportTests\|PlaintextExportImportTests\|LocalMachineryRecreationTests\|LibraryClassifier\|MultiTenantSyncTests\|StoreEncryption\|TriggerTests\|ArrivalsPinsSchemaEventTests\|AppDatabase'` **242 tests in 20 suites passed**; phone `build-for-testing` (generic iOS Simulator) and Mac `build-for-testing` into `DerivedData/vm64-b4/`, both `** TEST BUILD SUCCEEDED **`, no warning in a touched file. **The headless before/after** (`OwnerAdoptionMeasurementTests`, gated `VARIORUM_VM67_MEASURE=1`; Mac M3, Debug, an ENCRYPTED on-disk WAL store holding 61,700 owned rows in the owner tables; n = 5): BEFORE (pre-fix tree) warm **11.14 ms (10.98–11.18)**, cold (store reopened per pass) **11.10 ms (10.97–11.27)**; AFTER warm **0.79 ms (0.78–0.81)** / **0.83 (0.81–0.85)** on a second run, cold **0.86 ms (0.83–0.90)** / **0.85 (0.85–0.87)** — about 13× on a Mac; a Mac number, never a phone number. The simulator's before/after is `owner-adoption-nothing-to-adopt` in `MobileHerPathsPerfTests` (BEFORE: batch 3's window; AFTER: this batch's) |
| P7 — closeout in §7 (the S4 road list, the three options with plans, the first-seconds report) + READY | DONE (this commit) — §7 batch 4; the plans read through this build's SQLite (3.53.4) by the gated measurement; the whole Core package green (4,119 tests in 566 suites, 5 standing known issues; 703 in 130; 32 in 4). READY — the stage commands are in §7 batch 4 ▸ "The stage window" |

DerivedData: `App/Variorum/DerivedData/vm64-b4/` (gitignored).

### Batch 5 · VM-68 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** The red-on-old revert RAN and is RESTORED: from `dcea98cee` (committed and pushed), the five
phone Shell files (`MobileLibraryViewModel`, `MobileLibraryView`, `MobileShellView`, `MobileShellBand`,
`MobileListingFilters`) were checked out at base `35a3bea7a` and `MobileLibraryPagingRulesTests.swift` moved aside (it
names VM-68's API); `build-for-testing` into `App/Variorum/DerivedData/vm64-b5-red/` SUCCEEDED; then `git checkout HEAD
--` the six files, the aside folder deleted, `git status` and `git diff HEAD` empty. The branch merged main at
`d893fae63` (VX-980) first, at the orchestrator's word, so both product folders are built on the merged tree. (A quiet
window held the machine when the code was written; it ended 08:33.)

**Audit F re-verified on this tree:** `startAll` / `startBookless` (`MobileLibraryViewModel.swift:316-353`, VM-65's
marks inlined), both held for the root's whole life (`MobileLibraryView.swift:130-131`); `Queries.library` orders by the
un-indexable COALESCE (`Timeline.swift:214-255`); `poolPosts` → `notePoolListingSQL` classifies every bookless note
against every gathering's rule, then window-counts both classes (`ShelfQueries.swift:499-503, 576-655`); the silent cut
(`MobileLibraryView.swift:419-422`); `observe` / `observe(tracking:)` (`AppDatabase.swift:237-296`, no phone list uses
the second); the box's 500 ms debounce (`MobileQuickNote.swift:309`); the Library alive off screen in the band
(`MobileShellView.swift:227-241`). All TRACED as written.

**How the Mac keeps its Library fresh (read before designing — MobileSoul §3):** the catalog is ONE-SHOT keyset pages
(`catalogNotesPage`, first page 80, growing), re-asked at the LISTED depth on mount (`listingAppeared`), on a new
question, after its own row acts, on the deleted-notes signal, and when the held 200-window sidebar listing's MEMBERSHIP
moves (`LibraryViewModel.listingMoves` → `followListingMove`, single-flight). Nothing the catalog shows is held except
the near window's facts.

**The settled design (the Mac's shape, phone-spelled):**
- **A page, never a cap.** Both note listings (All/Notes, and Bookless) are keyset pages through `Queries.catalogNotesPage`
  — the Mac's read — of `listingLimit` rows (200, the phone's existing window, so the resting listing is unchanged);
  the next page is asked for as a row near the end appears, appended once (a note listed twice is listed where it was
  first read — the Mac's landing rule). No face is added: rows simply continue (the Mac's precedent).
- **Held only while the Library is on screen** (the shell's fact: the Library page is drawn at all — the current page
  or revealed by a band drag — and its stack is at its root). While hidden NOTHING is held: a write sets off no Library
  fetch and no landing. On screen, ONE observation holds the shown listing's FIRST page (a bounded keyset page — the
  Mac's held window); a delivery lands directly when only that page is listed, else re-asks the LISTED depth in place,
  single-flight (the Mac's `followListingMove`).
- **The return is current:** becoming on screen (re)starts the held page, whose first fetch IS the re-ask; between the
  return and that fetch's landing the pre-return rows show (one bounded statement). The Note listing is read ONCE at mount
  whatever shows (the "Library ready" mark keeps its meaning; the bookless empty line's store fact).
- **The bookless (Pool) listing** is held only while it is the filter shown AND the page is on screen, and is the same
  paged read with the Pool's LOOSE predicate added (the Mac's `notePoolListingSQL` predicates, shared, its statement
  byte-identical): a page walks `idx_container_touched` and stops when the page fills, so a re-read tests the notes it
  walks — never every note against every gathering (the floor, stated: when the wing holds fewer loose notes than a page,
  the walk reaches the wing's end).
- **Core changes — said first, as the brief asks, with why:** `Queries/LibraryPaging.swift` (VX-980 calls into it; it
  does not edit it): (1) `CatalogNotesPage` gains `keys` — each hit's sort-key value, which the statement already
  selects — because the phone's All interleaves books by the row's sort stamp and `CatalogHit` carries no
  `last_major_revision_at`; (2) `catalogNotesPage(…, poolLoose:)`, default false and byte-identical, adds the Pool's loose
  predicate to each arm. `Queries/ShelfQueries.swift`: the Pool's two predicates (the gatherings' `shown` OR and the
  live-book home) move to one home both statements read; `notePoolListingSQL`'s text stays byte-identical (a guard pins
  it against a frozen copy of the pre-change builder). No `SearchComposer` line, no schema, no `Sync/`.
- **Not built (wave 2):** row previews. They attach as a one-shot read over the LANDED rows' ids (the Mac's
  `loadNearExtras` place), never inside the held page's fetch.

| Piece | State |
|---|---|
| P1 — this live status | DONE (this commit) |
| P2 — Core: the shared Pool predicates + the byte-identity guards (frozen pre-change builders) | DONE (this commit) — the guards ran GREEN on the base's builders BEFORE the extraction (2 tests), and green after it |
| P3 — Core: `keys` + `poolLoose` on the page read; the Core pins (the loose pages equal `poolPosts`' loose class; the keys equal `Queries.library`'s stamps; the plans and VM steps) | DONE (this commit) — `LibraryPoolPagingTests` 8 tests green; with the neighbours (`LibraryPagingTests`, the Pool/ownership/rule suites, the four search suites that call the page read) **169 tests in 23 suites passed** headless. Measured: the first loose page **6,332 → 6,164 VM steps** at 300 → 1,200 notes (flat); the Mac's Pool statement **77,461 → 306,988** (∝ notes — the phone's Bookless re-read BEFORE) |
| P4 — phone: the model's paging + hold, the view's hold key and load-more, the shell's on-screen fact (`MobileShellBand.isDrawn`) | DONE (`8f1adc87c`; the one compile error fixed at `5ba59a6c8` — `isDrawn` compares pages by index, `MobileTab`'s equality being main-actor) — phone `build-for-testing` SUCCEEDED, no warning in a touched file; behaviour PENDING the stage |
| P5 — hosted pins: the 201st note reachable by scrolling (red on old); bookless pages past its window (red on old); the return lists what was minted while hidden (guard); the perf suite's four box-save counts ASSERTED 0 and a note typed in from the Library leaves its root alone | DONE (`8f1adc87c`, `cc7b2e4a2`, `dcea98cee`) — BUILT in both product folders; the runs PENDING the stage (§7 batch 5 ▸ "The stage window") |
| P6 — builds, the headless suites, the closeout and READY | DONE — main merged at `d893fae63` (VX-980, at the orchestrator's word; clean); Core set re-run on the merged tree **173 tests in 24 suites passed** (the 169 + VX-980's `SearchFoldedWordsBesideATagTests`); phone + Mac `build-for-testing` into `vm64-b5/` and the red phone build into `vm64-b5-red/` all `** TEST BUILD SUCCEEDED **` on the merged tree (`dcea98cee`); READY — §7 batch 5 ▸ "The stage window" |

DerivedData: `App/Variorum/DerivedData/vm64-b5/` (gitignored).

### Batch 6 · VM-69 · VM-70 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** The red-on-old revert RAN and is RESTORED: from `24fa9a5e2` (committed and pushed, announced
at `5608b7e52`), the four production files (`MobileEditorViewModel`, `MobileMembership`, `MobileNoteTags`,
`MobileWriteView` under `VariorumMobile/Features/Write/`) were checked out at the INSTRUMENT commit `c8f95ea6f` (today's
behaviour + the counter) and `MobileChipScopeTests.swift` moved aside (it names the new chip reads);
`build-for-testing` into `App/Variorum/DerivedData/vm64-b6-red/` `** TEST BUILD SUCCEEDED **` (cold); then
`git checkout HEAD --` the four files, the suite moved back, the aside folder removed — `git status` and `git diff HEAD`
empty.

**Audit F re-verified on this tree** (`d893fae63` + `f0e2e696c`): the screen's `.task` registers (the liveness grant's
flush + one header read, `MobileLivenessAuthority.swift:154-265`), then `arrive` → `loadOnce` (projection + header in one
read, `MobileEditorViewModel.swift:556-605`), then `start()` → two observations whose FIRST fetches re-read the header and
the whole projection (`:580-585`, `:655-695`) — the second projection read audit F 2C names, and the BEFORE count 2. The
first delivery's `ingest` is the third `.document` chrome request (`ingest` `:623` after `renderFull` `:896`, and again per
delivery). The editor acquires the post's coordinator at `init` (`:213`) and nothing on the phone releases it
(`releaseAutosave` has one phone caller, the quick note) — the BEFORE growth 1. The chips (`MobileWriteView.swift:492,527`)
call the sheets' full `refresh()`: `Queries.readings(db)` (every book) and `Queries.allTags(db)` (every tag) at every
open, though the masthead shows only the note's own rows; the two sheets already re-read on appear (`.task`).

**The settled design:**
- **VM-69, one read:** the arrival's ONE authoritative load IS the live observation's first value. `arrive` starts both
  live observations (header + projection), takes their first values (header adopted first, then the projection ingested
  — `loadOnce`'s order), and hands the running observations to `start()`, which continues them. No second read, so no
  gap to fall into: GRDB's own guarantee covers the window between an observation's first fetch and its tracking start
  (on a pool it compares WAL snapshots and re-fetches if anything committed — `ValueConcurrentObserver`), and nothing else
  sits between the load and the live updates. `loadOnce()` stays for the harness (unchanged). A RE-arrival (a covered
  screen shown again, already rendered) takes its first value as a DELIVERY — a signal that never rewrites the surface
  (MAJOR 3), since the second read that used to follow is gone.
- **The chrome once per open:** an apply arm that rewrote the page (a full render, a differential) already laid the
  chrome out as its last act; `ingest` lays it out only when the arm did not (echo, deferred, refetch) — the same inputs,
  never a second pass over them.
- **VM-70, released on close:** the model releases its ONE acquisition at its end of life — `isolated deinit`, the Mac's
  18k C1 shape (`EditorViewModel`'s own), phone-side only; `AppSession` unchanged. The `onDisappear` task holds the model
  through teardown's flush and the leaving savepoint, so the release lands after both by construction; the phone's
  `releaseAutosave` keeps a dirty coordinator and any coordinator another holder (a second tab, the quick note) still holds.
- **The chips:** each chip reads only what it shows — membership `Queries.readingsContaining` (the Mac chip's feed), tags
  `Queries.postTags`; the sheets keep their full `refresh()` on appear. References already read only the note's rows.
- **No Core, no `Shared/`, no `Sync/`, no schema.** The Mac does not compile any changed file.

| Piece | State |
|---|---|
| P0 — the midpoint review's finding 1 (the fence's projection-seam comment) | DONE (`f0e2e696c`) |
| P1 — this live status | DONE (this commit) |
| P2 — the instrument: the projection road's document-scope chrome requests counted (no behaviour change) | DONE (this commit) — `projectionChromePasses` + `layOutChrome()` at the three projection-road call sites (`ingest`, `renderFull`, `applyDifferential`); the build PENDING P7. **This commit is the red-on-old base** (today's behaviour + the counter) |
| P3 — VM-69: the arrival through the live observation; the chrome once | DONE (`63ad8b188`) — `loadLive` (`arrive`'s load), `start()` continues `liveHeader`/`liveTakes`, `takesObservation()` one home for the counted fetch, `ingest`'s chrome only when the arm did not lay it out; phone `build-for-testing` SUCCEEDED (P5's build), no warning in a touched file; behaviour PENDING the stage |
| P4 — VM-70: the release at the model's end of life | DONE (`9ad4a880d`) — `isolated deinit { session.releaseAutosave(forPost:) }`; built; behaviour PENDING the stage |
| P5 — the chips' scoped reads | DONE (this commit) — `MobileMembershipModel.refreshChip()` (`readingsContaining` only), `MobileNoteTagsModel.refreshChip()` (`postTags` only), the masthead's two chip tasks call them; the sheets' `.task { refresh() }` unchanged. Phone `build-for-testing` into `DerivedData/vm64-b6/` `** TEST BUILD SUCCEEDED **` (P3–P5 together), no warning in a touched file |
| P6 — the pins: the perf suite's counts asserted (reads 1, builds 1, registry 0); the hazard pins (a)–(d); the chrome count | DONE (`68d630d96` + this commit) — `MobileHerPathsPerfTests` (five series asserted; the registry series through `MountedBuilt`, a screen built and let go as the shell's destination does); new `MobileNoteOpenOnceTests` (6: the chrome once, the chips' trace, hazards (a), (b)×3, (c)) and `MobileChipScopeTests` (3: hazard (d)); phone `build-for-testing` into `vm64-b6` `** TEST BUILD SUCCEEDED **`, no warning in a touched or new file; runs PENDING the stage |
| P7 — builds: phone `build-for-testing` into `DerivedData/vm64-b6/`; red-on-old into `vm64-b6-red/` | DONE — fix products `vm64-b6` built at `24fa9a5e2` (the tree's code state; later commits are record-only) `** TEST BUILD SUCCEEDED **`; red-on-old `vm64-b6-red` `** TEST BUILD SUCCEEDED **` (cold), restored. No Mac build: no `Shared/` or Core file changed, and the Mac compiles none of the four files |
| P8 — closeout in §7 + READY | DONE (this commit) — §7 batch 6; READY: the stage groups (i)–(iv) are in §7 batch 6 ▸ "The stage window"; every run PENDING |

DerivedData: `App/Variorum/DerivedData/vm64-b6/` and `vm64-b6-red/` (gitignored).

**Iteration r1 (after the first stage window, 10:10–10:28 — the orchestrator's message; logs `notes/plans/vm64-screens/b6-*.log`).**
What ran: the perf suite alone on the fix build, twice — 10 of 10 (reads per open 1, registry growth 0 through
`MountedBuilt`); the 73 types in one host — green but VM-24's standing caret test and THREE release pins
(`closingANoteLandsItsTextThenGivesItsCoordinatorBack` `givenBack`; `theReleaseWaitsForTheLeavingSavepoint` the give-back;
`aCoordinatorAnotherHolderNeedsIsNeverLetGo`, 4 issues — the shelf's hold never came back, holders 3 after the quick
note's acquire); the note-open suite ALONE: the same three at their 10 s deadlines (neither company nor load); the red
build: the perf suite's four reds as designed, the note-open suite's chrome-once and chips-trace reds as designed AND the
same three. **Those three are red on BOTH builds — they proved nothing.** In each, the text landed and the savepoint
landed (their other expectations passed): the leaving work ran to its end, and the editor still never released.

**The trace (read on this tree; per pin and for the product):**
- **What holds the editor in the three pins — the LIVE HOST, not our code.** Every reference our code keeps to the
  editor was read: the screen's `onDisappear` task ends with the savepoint (it did — the savepoint landed); the screen's
  `.task` and `start()`'s two loops end at the stream's cancellation (the iterators hold no model); the liveness
  authority's entries are `weak` and the screen deregisters; the router holds none; the text view (`editorModel`), the
  gate delegate, the storage observer, the chrome and decor controllers, the pan router and every sibling hold it `weak`;
  the crystallizer's tasks are transient. What remains is the SwiftUI/UIKit hosting of the removed screen — its
  `@State`, the representable's struct (`MobileWriteView.model`, strong), the six `.sheet` and two `.alert` content
  closures and the `safeAreaInset` closure (each captures the screen value, whose `State(initialValue:)` stores the
  editor). The pins' host (`BuiltScreen`) stays up — window, hosting controller — until the test's `defer`; the perf
  series' `MountedBuilt` tears its window down and lets its host go BEFORE it waits, and there the release came. So per
  pin: **(A) for the harness** — the retain is the live host's, on both builds. Which object inside SwiftUI/UIKit
  holds it is not readable from our side; r1 adds a RECORDED probe (`VM70-PROBE|…`) that reads, through a weak
  reference, at which stage of a host's life the editor is freed — after the close, after a SwiftUI update, after the
  window's teardown, after the host's release — and the same on the REAL shell's NavigationStack pop (the Library row,
  then the navigation bar's Back).
- **For the product: (B).** Her shell is a live host for the app's whole life; a popped destination's state is freed on
  SwiftUI's schedule, and nothing on this branch pins that it is freed promptly, or at all, while the host lives — the
  one road that showed a release did so only by destroying the host. So r0's release depended on a deallocation her
  hands do not demonstrably cause: **VM-70 is not shown fixed for her road**, and an `isolated deinit` is the wrong
  place for the phone's release.
- **Why the Mac's 18k C1 is safe and the phone's lifetimes differ:** on the Mac a release only DECREMENTS — the entry's
  drop is the leaving savepoint's (`dropAfterLeaving`), and ⌘Q/the lock savepoint any entry still held — so a late death
  only delays a drop, never loses text, never costs a savepoint (18k measured it on the dev store). The phone's release
  IS the drop (`releaseAutosave`'s phone branch, at zero holders and clean), so on the phone a late or missing death is
  exactly the growth VM-70 measures.

**The r1 design (the release moves OUT of `deinit`, into the leaving work — the order flush, savepoint, release, which
batch 7's `MobileLeavingSavesOnceTests` assumes too):**
- **The leaving's last act gives the hold back** — the screen's `onDisappear` task: `teardown()` (the flush), then
  `savepointOnLeaving` (batch 7's phone branch: its flush, the read, the one runner turn), then
  `model.releaseAutosaveHold(ifNotShownSince:)`, then the leave's timing mark. Deterministic: no wait on any deallocation.
- **A screen shown again takes it back** — the screen's `.task` begins with `model.takeAutosaveHold()`: it counts the
  arrival and, if the hold was given back, re-acquires through `session.autosave(forPost:)`. If the registry hands back a
  DIFFERENT coordinator (the entry dropped clean and was re-minted, perhaps by another tab's editor of the same note), the
  editor ADOPTS it (stops observing its old one, observes the new) — so two coordinators for one note can never stand
  (the S3 BLOCKER's class). A screen shown again BEFORE its leaving finished keeps its hold: the leaving releases only if
  no arrival came after it (the arrival count captured at `onDisappear`).
- **`deinit` releases only a hold no leaving gave back** (a twin built by a view re-init, a harness model) — exactly one
  release per acquisition, as before.
- `autosave` becomes a `private(set) var` (every reader goes through `model.autosave` / `host.autosave` at use time —
  read on this tree); the re-mint passes the editor's own clock parameters. No `Shared/`, Core or `Sync/` change; the
  phone's `releaseAutosave` rule unchanged.
- **Pins:** the three release pins stay (now deterministic — the registry's release IS the leaving's last act; their
  bound is a hang guard, not a timing assumption); new `MobileNoteHoldTests` (names the new API — set aside for the red
  build): a re-show after the give-back takes it back and is wired to it; a re-show of the note opened meanwhile on
  another tab joins that tab's coordinator; a re-show before the leaving finished keeps its hold; a twin gives its hold
  back at its end; the order (flush, savepoint, release). The probe above, recorded. Red build: the four Write files at
  the instrument commit `c8f95ea6f`, on today's tree (batch 7's Core and `Shared/` included).
- **Kept as written:** the r0 closeout's claims in §7; the lines the stage falsified are marked there.

| r1 piece | State |
|---|---|
| R1 — this trace and the decision | DONE (this commit) |
| R2 — the product: the hold given back by the leaving, taken back by the arrival; `deinit` the remainder | DONE (this commit) — `MobileEditorViewModel`: `holdsAutosave`, `arrivalCount`, `takeAutosaveHold()`, `releaseAutosaveHold(ifNotShownSince:)`, `observesAutosave`, `autosave` a `private(set) var`, `deinit` releases only a hold still held; `MobileWriteView`: the `.task` takes the hold first, `onDisappear` captures the arrival and its task releases after the savepoint, before the leave's mark. Build PENDING (R4) |
| R3 — the pins: `MobileNoteHoldTests`; the probe; the three pins' notes | DONE (`9821ffef3` + this commit's two compile fixes) — `MobileNoteHoldTests` (4, names the new API); in `MobileNoteOpenOnceTests` the three pins' notes, `anEditorThatNeverArrivedGivesItsHoldBack` (red on old), `probeWhenAClosedScreensEditorIsFreed` and `probeAPoppedNotesEditorInTheShell` (RECORDED, `VM70-PROBE|…`) |
| R4 — builds `vm64-b6r1` (fix) and `vm64-b6r1-red` (revert announced first) | DONE — fix `vm64-b6r1` built at `ce3c4e75b`'s tree `** TEST BUILD SUCCEEDED **`, no warning in a touched or new file; red `vm64-b6r1-red` (the four Write files at `c8f95ea6f` over today's tree, batch 7's Core and `Shared/` included; the two new-API suites aside) `** TEST BUILD SUCCEEDED **` (cold) — it compiles. **No revert is in flight:** the four files restored by `git checkout HEAD --`, the two suites moved back, the aside folder removed, `git status` clean but this record |
| R5 — §7 r1 section (the falsified r0 lines marked) + READY | DONE (this commit) — §7 batch 6 ▸ "Iteration r1"; the r0 lines the window falsified carry `[r1: FALSIFIED …]` in place, kept as written; READY |

### Batch 7 · VM-71 — LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** The r1 red build RAN and is RESTORED: from `b6a047e82` (committed and pushed, the revert
announced there), the four production files were checked out at `dfdd94b5a` over today's tip (batch 6's r1 included);
phone `build-for-testing` into `App/Variorum/DerivedData/vm64-b7r1-red/` `** TEST BUILD SUCCEEDED **` (cold); then
`git checkout HEAD --` the four — `git status` and `git diff HEAD` empty. **(The r0 red build, kept as written:)** The red-on-old revert RAN and is RESTORED: from `c9b574513` (the fix and the pins, committed
and pushed; announced at `ba675754d`), the batch's four production files — `Sources/VariorumCore/Queries/IdleCommit.swift`,
`Sources/VariorumCore/Operations/Operations+Variant.swift`, `App/Variorum/Shared/AppSession.swift`,
`App/Variorum/Shared/AppTiming.swift` — were checked out at the base `dfdd94b5a`; phone `build-for-testing` into
`App/Variorum/DerivedData/vm64-b7-red/` `** TEST BUILD SUCCEEDED **` (cold); then `git checkout HEAD --` the four files —
`git status` and `git diff HEAD` show only this record. No test file was set aside (the phone pins name no VM-71 API; the
Core suite is not in the phone build).

**Base:** `dfdd94b5a` (batch 6 BUILT and waiting for its window; its three release pins in `MobileNoteOpenOnceTests` are
in this batch's stage commands).

**Audit F re-verified on this tree** (the lines moved, the shape did not — all TRACED as written):
- **1D** — a pop: `MobileWriteScreen.onDisappear` (`MobileWriteView.swift:210-232`) → `teardown()` (the flush, a runner
  write per dirty take) → `AppSession.savepointOnLeaving` (`Shared/AppSession.swift:660-692`) → `runner.run {
  closeAutoCommit }`. `closeAutoCommit` (`Sources/VariorumCore/Operations/Operations+Variant.swift:311-320`) opens ONE
  write transaction and, in `autoCommitDirtyVariants` (`:388-411`), decodes EVERY live unlocked take of the note with its
  whole `working_text` and runs one last-commit read per take (`isDirty`, `:710-720`) — O(note), holding the ONE serial
  runner (`Shared/OperationsRunner.swift:17-31`) and the writer, whether or not anything changed. The box's mint
  (`MobileQuickNote.swift:704-735`, `runner.run { importPost }`) queues behind it.
- **6C** — a Castle backgrounding: `mobileScenePhaseChanged(.background)` (`MobileShellRouter.swift:306-363`) →
  `performBackgroundFlush` (`:208-277`) asks for every registered note's savepoint (`:256-261`) → the network round
  (`:275-276`) → `relock.didLeaveTheScreen()` (`:351`) → `bootstrap.lock()` → `lockOnNewRoad`
  (`Shared/AppBootstrap.swift:1477-1499`): `runWillLock` → `mobileWillLock` (`Features/Protection/MobileRelock.swift:80-96`)
  asks AGAIN (`:91-93`), then `state = .opening` (`:1485`) removes the tree and each mounted screen's `onDisappear` asks a
  THIRD time, racing the pool close (`:1490-1495`). The BEFORE table: 3 (Standard 1, a pop 1). The lock road alone (Lock
  now, the crossings' `runWillLock`) asks twice: `mobileWillLock`, then the teardown's `onDisappear`.
- **6B** — the network round inside the grant before the lock: as written; NOT this batch's (wave 2, VM-103).

**The settled design — the dedupe is `closeAutoCommit`'s own rule, read OFF the runner:**
- **Core, additive (the Mac calls neither):** `Queries.leavingSavepointCandidates(db, containerID:)` — the takes a
  leaving savepoint would write (`closeAutoCommit`'s exact predicate: live, unlocked takes under the note's live
  placements whose text differs from their last savepoint; none when the note is gone, sealed, or the cadence does not
  save on leaving), in SQL, as a READ; and `Operations.closeAutoCommit(_:takes:)` — `closeAutoCommit`'s own checks
  re-run inside one transaction for exactly the listed takes (each re-verified: still live, unlocked, placed in the note,
  dirty), so its rows equal `closeAutoCommit(_:)`'s whenever the list covers the dirty set. `closeAutoCommit(_:)` and
  `autoCommitDirtyVariants` are untouched.
- **`AppSession.savepointOnLeaving`, the phone's branch only** (`#if os(macOS)` keeps the Mac's statements exactly):
  flush (unchanged) → the candidates on a READER (never the runner, never the writer) → nothing owed: done, the runner
  never asked → owed: ONE runner turn writing exactly those takes. A closed store (`StoreLockedError`) skips quietly
  (nothing can be written there — today's attempt failed and was swallowed); any other read failure falls back to
  today's full `closeAutoCommit`.
- **Who asks is unchanged on every road** — the lock does not move: no line in `MobileRelock.swift`,
  `MobileShellRouter.swift`, `MobileWriteView.swift`, `MobileQuickNote.swift` or `AppBootstrap.swift`. The repeats are
  answered by the store: a later ask in the same leaving finds the takes already savepointed and asks the runner for
  nothing; a write that landed in between (hers or a sync round's) is still savepointed, exactly as today.
- **The timing mark** (`AppTiming.savepointAttempted`) moves to the runner ask on the phone. On the old tree every
  `savepointOnLeaving` call reached the runner, so before and after it counts the same quantity — runner turns for a
  leaving savepoint (said here, per the record's rule on marks).

| Piece | State |
|---|---|
| P1 — this live status | DONE (this commit) |
| P2 — Core: the candidates read + the narrowed op + headless pins (equivalence, re-verification, every refusal) + a gated measurement | DONE (this commit) — `Queries.leavingSavepointCandidates` (`Queries/IdleCommit.swift`), `Operations.closeAutoCommit(_:takes:)` (`Operations+Variant.swift`); `swift test --filter 'LeavingSavepointTests\|LeavingSavepointMeasurementTests\|SavepointCadenceTests\|InsureTakesTests\|SearchSavepointCaptureTests\|SearchSavepointFacetTests'` green (`LeavingSavepointTests` 7, the measurement skipped ungated; the four neighbours unchanged). **The headless before/after** (`VARIORUM_VM71_MEASURE=1`; Mac M-series, Debug, an ENCRYPTED on-disk WAL store, one note of 1,370 blocks / 131,520 words, every take savepointed once; n = 5): the whole op (today's runner turn) **215.53 ms (214.96–216.49)** after one edit and **216.16 ms (215.01–216.90)** after only reading; the read **5.84 ms (5.83–5.89)** / **5.94 ms (5.88–6.18)** on a reader; the narrowed op **1.07 ms (1.02–1.14)** on the runner for the one owed take, and NO runner turn when nothing is owed — a Mac number, never a phone number |
| P3 — the phone's branch of `savepointOnLeaving` + the mark | DONE (this commit) — `Shared/AppSession.swift`: the Mac's statements in their order under `#if os(macOS)` (only the two inner guards they already sat in collapse into it); the phone's `#else`: flush → the read on a reader → nothing owed: return / `StoreLockedError`: return / another read failure: today's whole op → the mark → one runner turn for the owed takes. `Shared/AppTiming.swift`: the `savepointAttempt` docs say what it counts now. Build PENDING (P5) |
| P4 — the pins: perf suite (Castle 3 → 1 asserted, the lock road 2 → 1, note-leaving and Standard guards, the 100k leaving's writer statements, the runner-hold probe, the box's first mint after the 100k leaving); a company-safe suite for hazards (a)–(c) | DONE (this commit) — `MobileHerPathsPerfTests`: `savepoints-per-note-leaving` and `-backgrounding-{standard,castle}` ASSERTED == 1; new `lockingWithAnEditedNoteOpenCountsItsSavepointAttempts` (`savepoints-per-lock` == 1), `leavingTheHundredKNoteHoldsTheRunnerOnlyForWhatItOwes` (writer: no take scan, one last-savepoint read per take owed — 0 read-only, 1 edited; the runner probe and the `noteLeave` span recorded), `theBoxsFirstSaveAfterLeavingTheHundredKNote` (recorded); `RunnerProbe`. New `MobileLeavingSavesOnceTests` (6, company-safe: every road's one savepoint by the store's record, (b) twice per road, (c) with a REAL pool close, the writer's scans). Phone `build-for-testing` into `vm64-b7` `** TEST BUILD SUCCEEDED **`, no warning in a touched or new file; runs PENDING the stage |
| P5 — builds: Core `swift test` (touched + savepoint suites); phone + Mac `build-for-testing` into `DerivedData/vm64-b7/`; the red-on-old phone build into `vm64-b7-red/` (revert announced first) | DONE — Core suites green (P2); phone and Mac `build-for-testing` into `vm64-b7` `** TEST BUILD SUCCEEDED **` (the fix products, the tree at `c9b574513`), no warning in a touched file; the red-on-old phone build `vm64-b7-red` `** TEST BUILD SUCCEEDED **` (cold), restored |
| P6 — closeout in §7 + READY | DONE (this commit) — §7 batch 7; READY: the stage groups (i)–(v) are in §7 batch 7 ▸ "The stage window"; every hosted run PENDING |

DerivedData: `App/Variorum/DerivedData/vm64-b7/` and `vm64-b7-red/` (gitignored).

**Re-check on batch 6's r1 (the orchestrator's message, after `dd3f11d79`; r1 = `9490642e3` … `7647127f2`).** r1 moved
the editor's coordinator release out of `deinit` into the leaving work: `MobileWriteView`'s `onDisappear` task now runs
teardown's flush → `savepointOnLeaving` (this batch's phone branch) → `model.releaseAutosaveHold(ifNotShownSince:)` → the
leave's mark; the `.task` takes the hold first. Read on this tree: no product line of this batch changes; **two TEST-only
changes** (so a fresh fix product `vm64-b7r1` is owed, phone only — no `Shared/` or Core file changes, the Mac product
stays `vm64-b7`): (1) `MobileLeavingSavesOnceTests`' notes said a screen's leaving ends at "its editor's end of life" —
r0's mechanism, under which its five holder-count waits could only pass when the host died; under r1 they pass at the
leaving's last act — the waits and their deadlines stand, the words are corrected; (2) one pin added for hazard (c) under
r1: a key typed AFTER the lock's flush, whose landing meets the closed pool, is KEPT pending by the release (the phone's
`releaseAutosave` drops an entry only at zero holders AND a clean coordinator — `Shared/AppSession.swift:476-481`), not
dropped. The closeout's r0 lines are corrected in place (§7 batch 7 ▸ "Re-check on batch 6's r1").

| r1 re-check piece | State |
|---|---|
| Q1 — the re-check, per pin, and the plan (this paragraph) | DONE (this commit) |
| Q2 — the two test changes | DONE (this commit) — `MobileLeavingSavesOnceTests`: the host's note and the header say the leaving ends at its LAST act (r1), and the new `aKeyThatMeetsTheClosedStoreIsKeptByTheReleaseNotDropped` (7 tests now). Build PENDING (Q3) |
| Q3 — builds: phone `build-for-testing` into `vm64-b7r1` (fix); the red `vm64-b7r1-red` (the four production files at `dfdd94b5a` over today's tip; revert announced first) | DONE — fix `vm64-b7r1` built at `a61e4f7c9`'s tree `** TEST BUILD SUCCEEDED **` (cold), no warning in a touched file; red `vm64-b7r1-red` `** TEST BUILD SUCCEEDED **` (cold), restored. No Mac build: no `Shared/` or Core file changed (the Mac product stays `vm64-b7`) |
| Q4 — §7: the r1 re-check, the corrected lines, the stage commands on the new folders | DONE (`b6a047e82`) — §7 batch 7 ▸ "Re-check on batch 6's r1"; READY |

### Ladder round 1 — fix pass · LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** Base: `4b4d64143` (the round's findings as written, `notes/plans/fixes/vm-64-ladder-round1.md`).
The flow (cross-model): the responses to all seven findings are written first, at the end of the round file; the
agreed fixes whose shape is the reviewer's own are applied this turn; finding 1 waits for the reviewer's call between
its two arms and lands in a second turn, with the whole-package `swift test` on the final tree. DerivedData:
`App/Variorum/DerivedData/vm64-fix/` (fix) and `vm64-fix-red/` (the red-on-old phone build) — gitignored; the
orchestrator's frozen `vm64-b7r1/` and `vm64-b7/` are never written.

| Piece | State |
|---|---|
| F0 — this live status | DONE (this commit) |
| F1 — the responses (round file ▸ "Implementer responses (fix pass)"), committed and pushed before any fix | DONE (`44ac60f8b`); the gated measurement behind finding 1's arm (b) numbers `12d6afde5` (test-only) |
| F2 — finding 3 (VM-65): `TimingRecorder.end` tells the change handler only when something changed; the pin red, then green, headless | DONE (this commit) — pin `TimingRecorderTests.aNoOpEndIfOpenLeavesTheRecordUnchanged`: RED on the pre-fix tree (4 issues, the two no-op arms at `:446` `:447` `:458` `:459`), green after; `swift test --filter TimingRecorderTests` 32 tests in 1 suite passed |
| F3 — finding 5 (VM-2): `surfaceSettled()` no longer `mutating`; finding 6 (VM-65): the round's "sent" says it under-reads | DONE — 5: `a578f0b6e` (`StructuralFlightFenceTests` 8 passed, no new warning); 6: this commit (comments in `Shared/AppTiming.swift` only — the catalog line and `syncRoundEnded`; `SyncSession` untouched). No pins (cleanliness) |
| F4 — finding 2 (VM-70): `takeAutosaveHold` re-observes on both of its paths; the hosted pin; the red build `vm64-fix-red` | DONE but the red build — the fix and the pin `f589d964e` (`takeAutosaveHold`: the hold guard's early return became `if !holdsAutosave { … }` around the re-acquire, the unchanged re-observe after it on both paths; pin `MobileNoteHoldTests.aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator`). **HELD:** the red build `vm64-fix-red` (a cold build — the QUIET window from about 12:36 forbids it; recipe in §7 ▸ "Fix pass", reversing only the fix's hunk so it survives the VM-55 merge). No revert is in flight |
| F5 — builds: phone and Mac `build-for-testing` into `vm64-fix`; `swift test` for the touched suites | DONE at `f589d964e` — phone and Mac `** TEST BUILD SUCCEEDED **` (the Mac finished at 12:37, inside the window's two-minute tail), no warning in a touched file; `swift test --filter 'TimingRecorderTests\|StructuralFlightFenceTests\|LeavingSavepointTests\|LeavingSavepointMeasurementTests'` 48 tests in 4 suites passed (the gated one skipped). **To be REBUILT on the merged tree** once the orchestrator says to merge `origin/main` (VM-55) and the window has ended |
| F6 — §7 "Fix pass" closeout with the stage commands | DONE (this commit) — §7 ▸ "Ladder round 1 — fix pass"; the turn ENDS here with only builds left (the window): the merge of `origin/main` at the orchestrator's word, then the phone and Mac rebuilds into `vm64-fix`, then the red build, then the stage |
| F7 — finding 1 (Part of VM-71): HELD for the reviewer's call; the second turn | DONE — the call is in (`c9a2effda`: arm (a), exactly as specified, nothing of arm (b)). (i) the GUARD in `LeavingSavepointTests` ("GUARD — a take another writer dirties between the read and the turn is the next ask's") — DONE (`84a8acff8`; green by design, `LeavingSavepointTests` 8 passed); (ii) the comment corrections — DONE (`78439841e`; comments only: `Shared/AppSession.swift`'s phone branch of `savepointOnLeaving`, inside its `#else`, and `closeAutoCommit(_:takes:)`'s doc; the Mac's statements byte-unchanged); (iii) the record corrections in §7 batch 7 — DONE (`d6404029a`; in place, marked "[Ladder round 1, finding 1 — …]", the first text kept legible: hazard (a)'s pop row, hazard (b)'s "nothing can go stale" qualified to ACROSS asks, D-7-1's visibility-point note); (iv) the gated measurement stays (`12d6afde5`). The final table: §7 ▸ "Ladder round 1 — fix pass" ▸ "Second turn, part 1" (this commit); the touched filters 49 tests in 4 suites passed |
| F8 — second turn, part 2 (after the QUIET window and VM-55's merge to main, at the orchestrator's word): merge `origin/main`, rebuild `vm64-fix` (phone and Mac) and `vm64-fix-red` on the merged tree, the whole Core package headless, the stage | TAKEN OVER by "The merge of main (VM-55)" below — its builds go to `vm64-gate` / `vm64-gate-red` (the orchestrator's brief), never `vm64-fix*`; the stage stays the orchestrator's |

### The merge of main (VM-55) · LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight** (M11's revert ran and was restored: `git status` and `git diff HEAD` empty after it). Base: `48919f693` (this branch) · `origin/main` `eb18888db` (VM-55's merge `66337ff08` + its
notes-only ledger commit; merge-base `359ae214d`). DerivedData: `App/Variorum/DerivedData/vm64-gate/` (phone + Mac, the
merged tree) and `vm64-gate-red/` (phone, finding 2's hunk reversed) — gitignored; no other batch's folder is written.
The record of what was checked and changed: §7 ▸ "The merge of main (VM-55) and what it re-landed".

| Piece | State |
|---|---|
| M0 — this live status, before any tree change | DONE (this commit) |
| M1 — `git merge origin/main` (a merge commit); the two Shell conflicts re-landed hunk by hunk, each with its reason | DONE (`f03d59ae3`; the hunks and reasons in §7 ▸ "The merge of main (VM-55)…") — exactly the two expected files conflicted, no notes file; batch 5's four raw `lastError` lines converted in the merge by its recipe |
| M2 — (a) the wing: the Library's two paged listings scoped as VM-55's were; a switch re-asks; a hidden switch honoured on return; VM-55's Library wing pins re-landed on the paged model | DONE (this commit) — no product line: the key already carries the wing. Test side: `holdLibraryAsItsViewDoes` (`MobileWingsTests.swift`); VM-55's four Library pins re-landed on it, expectations unchanged; a hosted GUARD for the hidden switch (`MobileLibraryPagingTests`); the wing lines in `theHoldKeyNamesTheShownListing`; the nine-wing perf comparison scoped like for like; two model comments. Build PENDING (M10); runs PENDING the stage |
| M3 — (b) the one message line: this run's phone code routed through VM-55's seam (every raw error, every direct status write) | DONE — nothing beyond the merge's four conversions: every other site already reaches VM-55's seam (§7 (b)); the scans' mirrors clean; P-2-2 meets VM-61 → QUESTIONS |
| M4 — (c) `Shared/AppSession.swift` read (the phone's `savepointOnLeaving` branch, `releaseAutosave`, the status seam's move; the Mac's savepoint statements byte-identical) | DONE — both functions byte-identical to `48919f693`; no change |
| M5 — (d) `MobileShellView.swift`: the wing door beside `libraryOnScreen` / `isDrawn`, both new `MobileLibraryView` arguments, batch 1's marks | DONE — both runs' additions kept; no change after the resolution |
| M6 — (e) every `AppTiming` catalog series and counter has its call site | DONE — none dropped, none moved; no change |
| M7 — (f) the fence and the hold read on the merged tree (no change unless (b) needs a routing line) | DONE — the merge brought exactly VM-55's lines into the four seam files; no change |
| M8 — step 3: the `MobileHerPathsPerfTests` registry comment corrected (comment only) | DONE (this commit) |
| M9 — the whole Core package, `swift test`, once, at the end of the edits | DONE at `66ac9d503` — 4,913 tests in 710 suites passed, 0 failed (MCP 703/130 · Core 4,178/576 with 5 declared known issues · StringsWorkbook 32/4); 15 gated harnesses skipped; §7 ▸ "Evidence" |
| M10 — phone and Mac `build-for-testing`, cold, into `vm64-gate` | DONE at `f4068b3cf` — phone (`generic/platform=iOS Simulator`) `** TEST BUILD SUCCEEDED **`, 0 errors, first try; Mac (`platform=macOS`) `** TEST BUILD SUCCEEDED **`, 0 errors. No warning in a line the merge or this session wrote (the two nearest are pre-existing: `MobileStructural.swift:122`'s unused `intra`, 2026-08; VM-55's `MobileUndoDoorTests` `try`s). Logs `App/Variorum/DerivedData/vm64-gate-{phone,mac}-build.log` (local) |
| M11 — the finding-2 red build into `vm64-gate-red` (announced and committed before the revert; restored; `git status` / `git diff HEAD` empty) | DONE — announced at `fe7bc1960`; the recipe's reverse patch applied cleanly on the merged tree (finding 2's hunk in `takeAutosaveHold` alone; the pin file kept); phone `build-for-testing` into `vm64-gate-red` `** TEST BUILD SUCCEEDED **`, 0 errors; restored by `git checkout HEAD --` the one file; `git status` and `git diff HEAD` empty |
| M12 — §7's section, the hosted commands, the report | DONE (this commit) — §7 ▸ "The merge of main (VM-55) and what it re-landed" |

### Ladder round 2 — fix pass · LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** Base: `85762803a` (the round's findings as written, `notes/plans/fixes/vm-64-ladder-round2.md`).
The flow (cross-model): the responses to findings 1–9 and O-1 are written first, at the end of the round file, and
pushed before any code; the agreed fixes whose shape has nothing left to choose are applied this turn with their pins;
the rest wait for the reviewer's final call (the second turn), with the whole Core package `swift test` and the final
`build-for-testing` (phone + Mac) into `App/Variorum/DerivedData/vm64-gate2/` and the red-on-old phone build into
`vm64-gate2-red/` — owed once, on the final tree. The orchestrator's frozen `vm64-gate/` and `vm64-gate-red/` are never
written.

| Piece | State |
|---|---|
| R0 — this live status | DONE (this commit) |
| R1 — the responses (round file ▸ "Implementer responses (round 2 fix pass)"), committed and pushed before any code | DONE (`35551e25f`) |
| R2 — the no-choice fixes and their pins (the responses name which) | DONE — findings 1 (delete + ★ legs) and 3 `64af6d64a`, 8(a) `6b6c288b1`, 9 `28dc98ac5`, O-1 `c42078746`; UNCOMPILED (a QUIET window from 15:13 forbids the builds); runs PENDING the stage. HELD for the final call: finding 1's Put back leg; finding 2 (not applied — disputed shape) |
| R3 — the docs corrections of findings 5 and 6 (the record, the handoff, the closeout drafts) | DONE — the record `f45d25498` (with 8(b)'s note and O-1's commands), the handoff and the drafts `8eeafb614` |
| R4 — `swift test --filter` for every Core suite touched; §7's "Ladder round 2 — fix pass" closeout; the first turn's report | DONE (this commit) — no Core file changed, so no Core suite touched; §7 ▸ "Ladder round 2 — fix pass" |
| R5 — second turn: the reviewer's final calls applied; the whole Core package; `vm64-gate2` (phone + Mac) and `vm64-gate2-red` (revert announced first); the hosted commands | TAKEN OVER by the second turn's rows S0–S7 below (a fresh implementer; the first turn's session reached its context limit after its closeout — nothing of its work was uncommitted: the tree was clean and pushed at `31630a151`) |

**Second turn (implementer, opus, fresh; started 2026-11-19, inside the QUIET window that began 15:13).** Base `31630a151`
(the reviewer's final calls, `notes/plans/fixes/vm-64-ladder-round2.md` ▸ "Final calls (reviewer)"). Part A is edits
only (legal under QUIET); part B — the pass's FIRST compile, the whole Core package, the red build — waits for the
orchestrator's word that the window ended. **No revert is in flight.**

| Piece | State |
|---|---|
| S0 — this live status | DONE (this commit) |
| S1 — finding 1's Put back leg, arm (A): ONE line in `MobileLine.putBack` (the success path); the notification's name and its listener in the Library's model, alive only inside a running hold, its own session only; the pin as the final call words it, plus a witness pin whose only road between the Undo and the row is arm (A) (Part of VM-68) | DONE (`686a07d13`) — `MobileLine.swift` +1 line (the post, inside `putBack`'s `do`, after `runner.run`); `MobileLibraryViewModel.swift`: `listenForPutBack` (registered at `holdFirstPage`'s top, removed in its `defer`), `Notification.Name.variorumPutBackLanded`; pins `MobileLibraryPagingRulesTests.aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage` (the final call's) and `…aPutBackAfterTheLibraryCameBackReturnsARowPastTheFirstPage` (the witness). UNCOMPILED (QUIET); runs PENDING the stage |
| S2 — O-1's condition 2: the company-safe GUARD in `MobileNoteOpenOnceTests` — the hosted open reads the note once by the statement trace; the old shape (`loadOnce()` then `start()`) reads it twice in the same test (VM-66, VM-69); test-only | DONE (`2c8911ac0`) — `MobileNoteOpenOnceTests.anOpenReadsTheNoteOnceAndTheOldShapeTwiceByTheSameOracle` (the marker: `takesProjection`'s header leg, `OpenOnceTrace.projectionRead`); the header's bullet. UNCOMPILED (QUIET); runs PENDING the stage |
| S3 — record edits: the handoff (P-2-1's scope; VM-226's second road; the gate's own leg; VM-240/241/242 in every list), the closeout drafts ((e)5, (e)6, (b) Born, (c), (d), (g)), the `MobileTimingTests` header (comment only) | DONE — the header `167483f4d`; the handoff and the drafts `1dd921f7e`: P-2-1 scoped to the keys it is about; VM-226's line gains the second road; "The next runs" says a phone merge gate runs the speed tests as their own step; VM-240/241/242 in the tickets block, the found-not-fixed list and the reconciled table; the drafts' (e)5 "an act on a listed row re-asks it in place", (e)6 the gate's own leg, (b) the VM-68 paragraph (finding 1; VM-240 fills the first turn's `PENDING(id)`) and the Born line (every id, with labels), (c), (d), (g) rows 7/23/27 and new rows 45–48, the three tickets' section |
| S3b — part B's builder (a FRESH implementer, opus; the QUIET window ENDED by the orchestrator's word): main's `7629cf049` (the VX-981 run's merge) merged in, a merge commit, before any build; its three Core files read against this run's callers | DONE (`f850d1af4`) — the trial and the merge clean, no conflict in any file; the semantic check is §7 ▸ "Ladder round 2 — fix pass, second turn" ▸ "Part B" (no collision) |
| S4 — the pass's FIRST compile: phone + Mac `build-for-testing` into `vm64-gate2` | DONE — both built at `74d91c666` (the merged tree; nothing but this record changes after it): phone `** TEST BUILD SUCCEEDED **`, 0 errors; Mac `** TEST BUILD SUCCEEDED **`, 0 errors; NO compile fix needed; no warning in a line this pass wrote |
| S5 — the whole Core package, `swift test`, once, on the final tree | DONE — on `74d91c666`'s code (`e1e87dda0`'s tree; no code edit followed): `VariorumMCPTests` 746 tests in 139 suites passed · `VariorumCoreTests` 4,193 in 578 passed with 5 known issues · `StringsWorkbookTests` 32 in 4 passed — 4,971 in 721, no red; the 15 gated harnesses skipped (counted in N), the five known issues the baseline's |
| S6 — the red-on-old phone build into `vm64-gate2-red` (the first turn's recipe plus arm (A)'s hunks; announced and committed before it; restored; `git status` / `git diff HEAD` empty) | DONE — **no revert is in flight; the tree is restored.** Announced at `b44622e62` and built there with the recipe exactly (`git diff 85762803a HEAD` over the six production files reversed; `MobileLibraryRowActsTests.swift` aside): `** TEST BUILD SUCCEEDED **`, 0 errors; restored by `git checkout HEAD --` of the seven paths, the aside folder removed, `git status --short` and `git diff HEAD --stat` both empty |
| S7 — §7 ▸ "Ladder round 2 — fix pass" ▸ its "Second turn" part; the §5 rows flipped | DONE (this commit) — the section written by the second turn (`500c907b1`) with part B's results as PENDING slots; part B's builder filled them: §7 ▸ "… second turn" ▸ "Part B" (the merge and its semantic check, the builds, the whole-package counts, the products' SHAs), "Compile fixes" NONE, the stage commands (i)–(iv) unchanged (no test's name or count moved). The FOR A LATER READER and the gate/merge/round-3 `PENDING(…)` slots stay the orchestrator's. *(The second turn's text of this cell, kept: "IN-PROGRESS — … filled and the rows flipped after part B. The turn ENDS here under QUIET, owing S4–S6".)* |

### Ladder round 3 — fix pass · LIVE STATUS (implementer, opus; started 2026-11-19)

**No revert is in flight.** Base: `e78c5f1fa` (the round's findings as written, `notes/plans/fixes/vm-64-ladder-round3.md`,
`16581e7ad`; code unchanged since `74d91c666`). The flow (cross-model, the last round — no major was found): the
responses to findings 1–5 first, at the end of the round file, pushed before any code; the agreed fixes with nothing left
to choose applied this turn with their pins; any arm laid out waits for the reviewer's final call. Builds this turn: ONE
warm incremental phone `build-for-testing` into `App/Variorum/DerivedData/vm64-gate2/` (the gate tree and finding 1's
red-on-old build are made after VM-78's merge-in, not now). No hosted run (the stage's).

| Piece | State |
|---|---|
| T0 — this live status | DONE (this commit) |
| T1 — the responses (round file ▸ "Implementer responses (round 3 fix pass)"), committed and pushed before any code | DONE (`6cc3f9705`); two in-place corrections before each fix landed, marked: 5(b)'s trap-at-decode claim (false — a probe; with `8d48a682c`) and finding 1's missed over-read, which makes the (i′)/(i) arm (with `848b98b66`) |
| T2 — finding 1 (Part of VM-68): the agreed shape and its pins | DONE — pins `cd828fe16` (three, hosted; red-on-old 3 · 2 · 2 issues by trace), the fix `848b98b66` (one condition in `land`, shape (i′) — an arm for the final call). Runs PENDING the gate tree's stage; the red build PENDING (made with the gate tree after VM-78's merge-in — recipe in §7 ▸ "Ladder round 3 — fix pass") |
| T3 — finding 5(b) (VM-65): the damaged-record decode and the report's number; the headless pin red, then green; the touched Core suites | DONE — pins `2543a81f3` RAN RED (35 in 1 suite failed with 5 issues — the three pins only), fix `8d48a682c` RAN GREEN (35 in 1 suite passed). `merged`'s overflow NOT applied (an arm) |
| T4 — record and handoff edits: 2(c) the two fix passes' rows; 2(d) the handoff's "What happened" and "Reviews"; 3 the handoff's P-2-4 and the bundle; 4 the readout caveats; 5(a) the SurfaceContracts draft; 5(c) "empty in the steady state"; 5(d) declined, recorded | DONE (`fb55c3cbf`); 5(c)'s migration comment NOT touched (an arm); 5(d) declined in §7 ▸ "Ladder round 3 — fix pass" |
| T5 — ONE warm phone `build-for-testing` into `vm64-gate2` | DONE at `848b98b66` — `** TEST BUILD SUCCEEDED **`, 0 errors, no warning in a touched file (`DerivedData/vm64-gate2-r3-phone-build.log`, local) |
| T6 — §7 ▸ "Ladder round 3 — fix pass" closeout; the report | DONE (`1d781c237`). The first turn ended here — the arms waited for the reviewer's final call |
| **Second turn** (the final calls, `6aa357bff`): T7 — finding 1's GUARD (the short complete listing a page reaches past is not chased; test-only) | DONE (`8be3a1f30`) — `aShortCompleteListingThatAPageReachesPastIsNotChased`; the handoff's slot beside "fixed" `399846e11`. Runs PENDING the gate tree's stage (green on both builds expected) |
| T8 — 5(b)'s `merged` bound, arm (B): the exit-test pin first (its own commit, red), then the bound (green) | DONE — pin `adc466230` RAN RED (36 in 1 suite failed with 1 issue, the child's SIGTRAP); bound `4bee11420` RAN GREEN (36 in 1 suite passed) |
| T9 — 5(c): `Migrations.swift`'s `v1_38` comment, COMMENT ONLY; `MigrationTests` green | DONE (`705c6cf8a`) — `//` lines only; `MigrationTests` 33 in 4 suites passed |
| T10 — ONE warm phone `build-for-testing` into `vm64-gate2`; §7's second-turn part; these rows | DONE — the build at `8be3a1f30` `** TEST BUILD SUCCEEDED **`, 0 errors; §7 ▸ "Ladder round 3 — fix pass" ▸ "Second turn" (this commit). **The turn ENDS here**; owed, by a fresh session after VM-78's merge-in: the gate tree, finding 1's red build and the hosted runs |

### The merge of main (VM-78) and the gate tree · LIVE STATUS (implementer, opus, fresh; started 2026-11-19)

**No revert is in flight.** Base: `dd7da4f4c` (this branch; final code `8be3a1f30`) · the merge target EXACTLY `f909d6714`
(VM-78's merge, PR #15, a true merge on `a4634b288`, which this branch already holds; `git merge-tree` trial CLEAN).
DerivedData: `App/Variorum/DerivedData/vm64-gate3/` (phone + Mac, the joined tree) and `vm64-gate3-red/` (phone,
`848b98b66`'s one hunk reversed) — gitignored; no other `vm64-*` folder is written. No hosted run (the stage is the
orchestrator's). The record of what was checked: §7 ▸ "The merge of main (VM-78) and the gate tree".

| Piece | State |
|---|---|
| G0 — this live status, before any tree change | DONE (this commit) |
| G1 — `git merge --no-ff f909d6714` (a merge commit); stop on any code conflict | DONE (`a18fae31f`) — trial and merge clean, no conflict in any file; `git merge-base --is-ancestor f909d6714 HEAD` holds |
| G2 — the blob check of the five shared files; each read whole against the map's VM-64 bullet and this run's intents; the composition traced; the other meeting points; the guards mirrored | DONE (this commit) — all five blobs MATCH; both runs hold in each file; the quiet-undo composition ends on the fence's sentence, no state wrong (one note for her bundle with P-2-2); the union, the fence's sentence, the Put back line and the timing marks unchanged in meaning; both source scans green by reading. NO collision; no line written. §7 ▸ "The merge of main (VM-78) and the gate tree" |
| G3 — phone and Mac `build-for-testing` into `vm64-gate3`; compile fixes (if any) listed | NOT-STARTED |
| G4 — the whole Core package, `swift test`, once, on the final tree | NOT-STARTED |
| G5 — finding 1's red-on-old phone build into `vm64-gate3-red` (announced and committed before the revert; restored; `git status` / `git diff HEAD` empty) | NOT-STARTED |
| G6 — §7's section, the final stage commands, the report | NOT-STARTED |

### Orchestrator's stage results (the PENDING lines above and in §7 are settled here; pipelined run — the orchestrator ran each window from the batch's built products)

**Batch 1 · VM-65 — CLOSED 2026-11-19.** Run from `DerivedData/vm64-b1` (built at `808f333a8`), `test-without-building` against the batch's `.xctestrun` files.
- **Mac, 04:44** — the nine suites over the shared types the marks touch (`AutosaveCoordinatorTests` `AutosaveConsolidationTests` `SavepointOnLeaveTests` `SyncBeforeRoundTests` `FirstRoundRoadTests` `SyncSessionFenceTests` `Phase9cAuthWiringTests` `AppBootstrapOffMainTests` `TestHostInertTests`): Swift Testing **61 tests in 9 suites passed**; no red, no skip.
- **Phone, 05:03** — the 23 suites the batch named (`MobileTimingTests` first), standing simulator: Swift Testing **173 tests in 23 suites passed** in 76 s; no red, no skip. Machinery: `xcodebuild` never printed its `** TEST EXECUTE **` line and had to be stopped by hand nine minutes after the Swift Testing verdict; poll for the Swift Testing verdict line.
- **The walk, 05:13–05:22** — the orchestrator's own hands, on a dedicated simulator device (`vm64-walk`, created for this run so the shared device takes nothing; kept shut down for later walks, deleted at closeout), the Debug app, signed out. Fresh install → the first-run words card → the shelf; the capture box → a typed line → Open → back → Library → the note opened from its row → back → Settings ▸ timing…; then one cold relaunch and the readout again. Captures (local, gitignored): `notes/plans/vm64-screens/w12-readout.png`, `w14-readout-relaunch.png`. **The readout showed, on this build's table (1.0 (1) Debug, simulator — simulator numbers, single runs, not medians):** File → box clear 15 ms · Open → note on screen 267 ms · Open → keyboard up in the note 949 ms · Open a note → on screen n 2, 96–220 ms · Leave a note → saved n 2, 1.8–8.5 ms · after the relaunch, Launch → library open 2,190 ms · Launch → home on screen 2,461 ms · Launch → Library ready 2,472 ms. Empty as expected: the unlock spans (no lock on this library), owner check and sync round (signed out), and "Tap the box → keyboard up" (this simulator never raises the software keyboard under Device Hub — first filled on her phone).
- **Seen on the walk, for later batches and the ladder (not fixed here):** (1) after Open the caret sits at the START of the typed line (audit F 2F, now seen). (2) The first launch of a fresh install, which passes through the words card, recorded NO launch spans; the relaunch recorded all three — say whether that is by design in the closeout's table, or mark it. (3) A hardware Return in the capture box did not open the note in this harness (the "open ↵" door did); not chased — the harness's key road, not the product's, until shown otherwise.
- **Walk machinery (for the run's later walks):** Device Hub's process is `DeviceHub`; select the device's row in its sidebar to get the live screen; phone point → host point is a plain scale (0.737 at the default zoom) from the screen's top-left; a bare `cliclick c:` leaves the simulator's touch stuck down — use `dd:` · `w:70` · `du:` (70 ms is a tap; 180 ms on a list row opens its long-press menu); the author guard needs two seconds between synthetic acts because they reset HID idle; the toolbar's keyboard button captures the Mac keyboard for typing and is switched back off afterwards; the calibration helper needs a Python with numpy.

**Batch 2 · VM-2 — FIRST STAGE WINDOW, 2026-11-19 05:38–05:47: NOT GREEN (the batch is back with its implementer).** Products as built at `59f097244` (`DerivedData/vm64-b2-red` = the pins over the pre-fix phone files; `vm64-b2` = the fix). Logs kept locally: `notes/plans/vm64-screens/b2-red.log`, `b2-green.log`; crash reports `~/Library/Logs/DiagnosticReports/VariorumMobile-2026-11-19-05[34]*.ips`.
- **Pre-fix run** (the fence suite alone, three host processes): 7 pins FAILED by assertion, as designed — `keysTypedWhileADivideLandsReplayAtTheLandedCaret` · `anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid` · `aKeyTypedWhileAMergeLandsEndsUpInTheMergedBlock` · `aGatelessEditDuringAMergeNeverLandsInAReleasedSource` · `aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan` · `aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource` · `aKeyTypedWhileInsertBelowLandsGoesIntoTheNewBlock`; 1 passed (`insertBelowTwin…`); and 2 were LOST TO A HOST CRASH on the DEBUG trap "mobile editor surface desynced from the block index": `aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore` and `afterTheFlightLandsTypingIsOrdinaryAgain` — the second is the guard expected green on both sides.
- **Fix run** (49 types, six host processes): the fence suite's 10 — 5 passed (`anEditTheGateIsAskedAbout…`, both merge pins, `insertBelowTwin…`, `aKeyTypedWhileInsertBelowLands…`), **5 LOST TO THE SAME TRAP: `keysTypedWhileADivideLandsReplayAtTheLandedCaret` (the pin) · `aGatelessEditDuringADivideIsWithheld…` · `aKeyTypedWhileAnExtractLands…` · `aKeyTypedWhileMakeBlockLands…` · `afterTheFlightLandsTypingIsOrdinaryAgain`.** The faulting stack, identical in every report: `_assertionFailure` ← `EditorAssertionSeam.fire` ← `MobileEditorViewModel.desyncRecovery()` ← `recoverFromUnroutableEdit()` ← `storageDidEdit` ← `MobileStorageObserver.textStorage(_:didProcessEditing:…)`; in the gateless pin the storage edit is the test's own `systemEdit`. A test that died with the host is NOT counted green. The other 48 types ran to their end: 47 whole-green (345 tests passed across the launches); `MobileMarkdownCaretTests` red only on VM-24's standing test, in main's shape (2 of 3 cases, 2 issues).
- **What it means:** the fence is not yet shown to hold on divide, extract and make block, and one guard pin traps on old code too, so either the pins' typing road desyncs the surface by itself (the VM-19 class) or the fence's withheld-edit arm routes as unroutable. The implementer diagnoses from the logs and reports, then iterates in SHORT stage claims on the fence suite alone.

**Batch 2 · VM-2 — FENCE CYCLE r1, 2026-11-19 06:32–06:33: CLEAN.** Products at `05ca99e0d` (`DerivedData/vm64-b2r1` = the fix; `vm64-b2r1-red` = r1's tests over the pre-fix phone files). `MobileStructuralFlightFenceTests` + `MobileFlightFenceProbeTests`, one invocation per build, ONE host process each, no trap, no crash report, no Problem Reporter. Logs kept locally: `notes/plans/vm64-screens/b2r1-fix.log`, `b2r1-red.log`.
- **Fix build:** 17 starts, 17 passed (the 10 fence pins and the 7 probe cases); Swift Testing "17 tests in 2 suites passed". Every `VM2-PROBE` summary line reads `desyncs=0 asserts=0 … rejected=0 mismatches=0`, in both postures, before and after a divide.
- **Pre-fix build:** 17 starts, 8 passed, **9 fence pins FAILED by assertion** ("17 tests in 2 suites failed with 22 issues"): the eight predicted (`keysTypedWhileADivideLandsReplayAtTheLandedCaret` 2 issues · `anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid` 3 · `aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore` 4 · `aKeyTypedWhileAMergeLandsEndsUpInTheMergedBlock` 2 · `aGatelessEditDuringAMergeNeverLandsInAReleasedSource` 2 · `aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan` 2 · `aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource` 2 · `aKeyTypedWhileInsertBelowLandsGoesIntoTheNewBlock` 1) **and the guard `afterTheFlightLandsTypingIsOrdinaryAgain` (4 issues: the recorded desync assertion, `model.autosave.isDirty`, the stored text, `desyncRecoveryCount == 0`).** Green there: `insertBelowTwin…` and the 7 probes (the same `desyncs=0` lines as on the fix build).
- **What is settled and what is owed:** the pins are red on old and green on the fix, per door, in one host process. NOT yet explained, and owed in the implementer's closeout before the batch closes: (1) on the OLD code, typing at the start of the minted block just after a divide lands desyncs in the key-window posture (the guard's red) while the probe's p5, the same act in the same posture, shows no desync on either build — what differs between the guard and p5; (2) the traced mechanism by which the fix build no longer desyncs there; (3) whether this is round 2's M27 (which `notes/plans/fixes/vm-5-stability-pass.md` recorded as dissolved) and what that means for that record. The six crash stacks of the first window stay the evidence beside any "posture, not the fence" claim.

**Batch 2 · VM-2 — THE 49 TYPES FROM THE r1 FIX BUILD, 2026-11-19 06:57–06:59: FOUR FENCE PINS RED ON THE FIX. The batch is NOT closed.** `vm64-b2r1` (05ca99e0d), ONE host process, no restart: 352 test starts, 345 passed, 5 tests failed ("350 tests in 49 suites failed with 18 issues"). Red: VM-24's standing caret test in main's shape (2 of 3 cases, 2 issues), and `keysTypedWhileADivideLandsReplayAtTheLandedCaret` (6 issues) · `aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan` (3) · `aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource` (3) · `afterTheFlightLandsTypingIsOrdinaryAgain` (4) — each with the recorded desync assertion. The same four were green at 06:32 beside only the probe suite: their outcome depends on what earlier suites leave in the host process. Log: `notes/plans/vm64-screens/b2r1-49.log`. The implementer's trace (its §7 "Iteration r1 → r2") names the cause: a programmatic `insertText` never consults the editor's gate, while her keyboard always does, so these pins and the fence's hold-and-replay path ride a road only tests reach. **The orchestrator's call on r2 follows in the batch's section.**

**Batch 3 · VM-66 — CLOSED 2026-11-19. Stage window 06:59–07:03, products `vm64-b3` at `d2cef56be`.** `MobileHerPathsPerfTests` alone, twice: 9 tests in 1 suite passed both times (run 1 started 06:59:36, load averages 16.12 77.53 71.31; run 2 started 07:01:24, 7.75 55.55 63.40 — a loaded machine, six runs sharing it). Then `MobilePerfFixtureTests` `MobilePerfWalkTests` `MobileLaunchPathTests` `MobileShelfPerfTests` `MobileTimingTests`: 21 tests in 5 suites passed. No red, no crash. Logs: `notes/plans/vm64-screens/b3-perf1.log`, `b3-perf2.log`, `b3-five.log`.

**THE BEFORE NUMBERS — simulator (iPhone 17 Pro, iOS 26.2), Debug build, n = 5 per series inside each run; median (min–max); a single value means min = max. These are the figures batches 4–7 are judged against; the implementer's PENDING table in the batch-3 block above is settled by this one.** The last column is the same suite from batch 4's products (`vm64-b4`, `8e4e73e01`, started 07:03:40, load 4.71 37.11 54.81).

| Series | unit | BEFORE run 1 (load 16.1) | BEFORE run 2 (load 7.8) | after batch 4 (load 4.7) |
|---|---|---|---|---|
| `note-open-to-screen-short` | ms | 59.26 (44.78–65.03) | 53.53 (46.93–64.85) | 56.85 (49.41–59.22) |
| `note-open-to-live-short` | ms | 38.14 (33.19–54.85) | 37.92 (33.32–73.00) | 38.52 (35.68–55.78) |
| `note-reads-per-open-short` | count | 2 | 2 | 2 |
| `note-open-to-screen-100k` | ms | 359.99 (355.23–362.37) | 361.61 (357.77–365.59) | 352.60 (350.84–359.25) |
| `note-open-to-live-100k` | ms | 486.45 (483.49–495.25) | 496.14 (494.37–500.23) | 490.69 (487.57–493.37) |
| `note-reads-per-open-100k` | count | 2 | 2 | 2 |
| `shell-box-open-to-note` | ms | 56.61 (49.85–64.17) | 58.08 (57.14–63.81) | 59.98 (55.44–67.06) |
| `shell-box-file` | ms | 3.08 (2.85–6.46) | 3.60 (3.28–7.62) | 6.19 (2.88–11.84) |
| `shell-box-open-to-live` | ms | 34.08 (32.31–34.94) | 35.46 (33.96–36.10) | 35.92 (31.75–37.67) |
| `shell-box-editor-builds-per-open` | count | 1 | 1 | 1 |
| `shell-box-note-reads-per-open` | count | 2 | 2 | 2 |
| `shell-library-open-to-screen-short` | ms | 40.34 (33.68–46.40) | 49.41 (39.95–50.90) | 45.13 (37.11–48.95) |
| `shell-library-editor-builds-per-open-short` | count | 1 | 1 | 1 |
| `shell-library-note-reads-per-open-short` | count | 2 | 2 | 2 |
| `shell-library-open-to-screen-100k` | ms | 311.51 (308.52–324.44) | 326.34 (315.22–329.84) | 322.16 (314.27–323.64) |
| `shell-library-editor-builds-per-open-100k` | count | 1 | 1 | 1 |
| `shell-library-note-reads-per-open-100k` | count | 2 | 2 | 2 |
| `library-rereads-per-box-save` | count | 2 | 2 | 2 |
| `library-redraws-per-box-save` | count | 2 | 2 | 2 |
| `all-listing-rereads-per-box-save` | count | 1 | 1 | 1 |
| `bookless-rereads-per-box-save` | count | 1 | 1 | 1 |
| `library-listing-fetch-ninewings` | ms | 1.13 (1.03–2.69) | 1.14 (1.09–1.47) | 1.15 (1.09–2.87) |
| `bookless-listing-fetch-ninewings` | ms | 6.52 (6.24–13.34) | 6.53 (6.35–7.09) | 6.58 (6.30–14.10) |
| `owner-adoption-nothing-to-adopt` | ms | 1.15 (1.00–1.24) | 1.16 (1.04–1.30) | 0.88 (0.83–0.92) |
| `owner-adoption-rows-nothing-to-adopt` | count | 0 | 0 | 0 |
| `savepoints-per-note-leaving` | count | 1 | 1 | 1 |
| `savepoints-per-backgrounding-standard` | count | 1 | 1 | 1 |
| `savepoints-per-backgrounding-castle` | count | 3 | 3 | 3 |
| `autosave-registry-growth-per-open-close` | count | 1 | 1 | 1 |
| `note-rereads-per-save-100k` | count | 1 | 1 | 1 |
| `note-deliveries-per-save-100k` | count | 1 | 1 | 1 |
| `note-delivery-ingest-100k` | ms | 4.66 (4.10–4.74) | 4.49 (3.92–4.80) | 4.54 (4.02–4.88) |

**Reading them (the orchestrator's, for the batches that follow):** every count repeats exactly across runs — a note is read twice per open (batch 6 → 1); the Library re-reads twice and redraws twice per capture-box save with the Library off screen (batch 5 → 0); backgrounding under Castle makes 3 savepoint attempts where Standard makes 1 (batch 7 → 1); the autosave registry grows by 1 per open-and-close (batch 6 → 0); the editor's models are built ONCE per open, so audit F's suspected twin construction (2D) is NOT happening on this road. The durations are simulator figures at fixture scale and are small: nothing here reproduces the size of what she feels on her phone, which is why the readout on her wave-1 build is the number that matters for tuning. Owner adoption with nothing to adopt: 1.15 ms before, 0.88 ms after, at a 450-note fixture (the batch-4 closeout's headless figure at 61,700 rows is 11 ms → under 1 ms).

**Batch 4 · VM-67 — the phone piece, 07:03–07:05, GREEN** (`vm64-b4`): `MobileHerPathsPerfTests` alone — 9 passed, the new owner-adoption assertions included; then `MobileLaunchPathTests` `MobilePerfFixtureTests` `MobilePhoneStoreEncryptionTests` `MobileRoundOccasionTests` `MobileTypedUnlockSyncKeysTests` `MobileRelockCoordinatorTests` — 16 tests in 6 suites passed. Logs `b4-perf.log`, `b4-six.log`. The Mac piece (16 types) is still owed before the batch closes. **A file under `Features/Protection/` to name plainly (the coordinator's catch):** batch 1 added one line to `VariorumMobile/Features/Protection/MobileRoadFaces.swift` — `.onAppear { MobileTiming.lockScreenAppeared() }`, the lock screen's timing mark; it changes nothing the lock does, and it sits inside this run's custody slot.

**Batch 2 · VM-2 — THE r2 CYCLE, 2026-11-19 07:24–07:27: CLEAN. BATCH 2 CLOSED.** Products at `2a3fd3a52` (`DerivedData/vm64-b2r2` = the fix; `vm64-b2r2-red` = r2's pins over the pre-fix phone files); one host process per invocation, no trap, no crash report, no Problem Reporter. Logs kept locally: `notes/plans/vm64-screens/b2r2-fix.log`, `b2r2-red.log`, `b2r2-49.log`.
- **The fence suite alone, fix build:** 10 tests in 1 suite passed.
- **The fence suite alone, pre-fix build:** "10 tests in 1 suite failed with 23 issues" — the eight product pins RAN AND FAILED by assertion: `keysTypedWhileADivideLandsAreRefusedAndSaid` (3 issues) · `anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid` (3) · `aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore` (4) · `aKeyTypedWhileAMergeLandsNeverLandsInAReleasedSource` (2) · `aGatelessEditDuringAMergeNeverLandsInAReleasedSource` (2) · `aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan` (3) · `aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource` (3) · `aKeyTypedWhileAnUndoLandsIsRefusedAndTheUndoLandsWhole` (3); the two guards passed (`aKeyTypedWhileInsertBelowLandsIsNeitherLostNorDuplicated`, `afterTheFlightLandsTypingIsOrdinaryAgain`).
- **The 49 types in ONE invocation, fix build:** one host process, no restart — 352 test starts, 349 passed, 1 test failed ("350 tests in 49 suites failed with 2 issues", 48 suites passed). **The fence suite is whole-green in company**, `MobileUndoDoorTests` green; the ONLY red is VM-24's standing `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` in main's exact shape (2 of 3 cases, 2 issues, `desyncRecoveryCount == 0`), which belongs to the VM-78 run.
- **Open from this batch, with owners:** the refuse-and-say shape (P-2-1) and the insert-below exemption (P-2-5) are PROVISIONAL and lead the author's handoff; the tail's idle-save road is **VM-226**; the on-device autocorrect and dictation check rides her wave-1 install.

**THE MIDPOINT COLD REVIEW (batches 1–4), 2026-11-19: 0 BLOCKER · 0 MAJOR · 5 MINOR · 3 NIT.** The report verbatim and every disposition are in `notes/plans/fixes/vm-64-midpoint-review.md`. Carried forward: finding 1 (a stale comment at the fence's projection hook in `MobileEditorViewModel.swift`) is batch 6's FIRST commit; findings 6 and 7 (a no-op `end` marking the timing record dirty; `surfaceSettled()` declared `mutating`) are fixed with a pin in the end-of-run ladder's fix pass; finding 8 (the in-note keyboard span will undercount on a real phone) is a caveat in the author's handoff.

**Batch 4 · VM-67 — CLOSED 2026-11-19.** The Mac piece, 08:33–08:34, products `vm64-b4` at `8e4e73e01`: the 16 types the batch named (`Phase9cAuthWiringTests` · the three first-round suites · `SyncBeforeRoundTests` · `SyncReachabilityTriggerTests` · `ProdTestRoadTests` · the two one-refresh-authority suites · `HostedSyncStatusReadTests` · `SyncWalkFenceTests` · `AuthSessionTests` · `SignUpPresentationTests` · `HostedSyncTierFaceTests` · `AppBootstrapOffMainTests` · `TestHostInertTests`) — Swift Testing **110 tests in 16 suites passed**, no red, no skip. Log `notes/plans/vm64-screens/b4-mac.log`. With the headless whole-package run (4,119 tests in 566 suites) and the phone piece above, the batch's evidence is complete; the midpoint review's finding 4 is settled.

**Where two runs' findings meet (noted 2026-11-19 at the VM-78 run's word).** VM-78's trace of VM-24's standing red (`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`) names the same mechanism batch 2 traced for a bare `insertText`: on the `replaceRange:withText:` road the editor's gate is never consulted, the edit reaches `storageDidEdit` unarmed, and when TextKit's attribute fixing widens the report across the block's terminator `fallbackVerdict` refuses and `desyncRecovery` re-renders from the store. VM-78 holds that fix for the author's decision and does not touch the routing. On this run's tree that test stayed red in main's exact shape through every run (2 of 3 cases, 2 issues): the fence changes no routing of an unarmed or widened report outside a structural flight. Their write-up: branch `vm-78-fixes-to-whats-there`, `notes/plans/fixes/vm-78-fixes-to-whats-there.md`, BATCH C.

**Main merged in, 2026-11-19:** `d893fae63` — "Merge main (VX-980) into vm-64-timing-and-lags", a merge commit, clean, by batch 5's implementer at its own clean point (the one live writer), at the coordinator's requirement that batch 5's products be built on the merged tree. Batches 5–7 build on it; batches 1–4's stage evidence above was taken before it and is re-covered by the whole-target windows before the merge.

**Batch 5 · VM-68 — CLOSED 2026-11-19.** Products built ON THE MERGED TREE (main in at `d893fae63`) at `dcea98cee`: `vm64-b5` (phone + Mac) and `vm64-b5-red` (the pins over the five pre-fix Shell files on merged Core). One host process and no restart in every invocation; no crash report. Logs kept locally: `notes/plans/vm64-screens/b5-*.log`.
- **Phone, 09:01–09:11.** `MobileHerPathsPerfTests` alone on the fix build (started 09:01:31, load averages 49.56 117.19 185.33 — a heavily loaded machine): 10 tests in 1 suite passed. `MobileLibraryPagingTests` + `MobileLibraryPagingRulesTests` on the fix build: 12 tests in 2 suites passed. `MobileLibraryPagingTests` on the red build: `theTwoHundredAndFirstNoteIsReachableByScrolling` (3 issues) and `theBooklessDoorListsEveryLooseNote` (7) RAN AND FAILED; the guard `aNoteMintedWhileTheLibraryIsAwayIsListedWhenSheReturns` passed. `MobileHerPathsPerfTests` alone on the red build (09:04:54, load 65.40 99.67 164.54): `typingInTheBoxWakesTheOffScreenLibrary` failed on its four zeros and `typingInANoteOpenedFromTheLibraryLeavesTheLibraryAlone` failed on its two — **so the old code did keep the covered Library working under a pushed note, and that pin is a real red-on-old, not hollow.** The 23 types the batch named, fix build: "229 tests in 23 suites passed with 2 known issues" (`MobileTrashTests`' one designed known issue twice, as on main).
- **Mac, 09:11–09:13.** The 14 types over the two Core reads the batch touched: 93 tests in 14 suites passed.
- **The after-numbers (the fix build, simulator, Debug, n = 5, under the load above):** Library re-reads per capture-box save **0** (before 2) · Library redraws per save **0** (before 2) · all-listing re-reads **0** (before 1) · bookless re-reads **0** (before 1) · Library re-reads and redraws per save of a note opened over the Library **0 · 0** · one re-read per return to the Library. Every other series unchanged (a note still read 2 times per open; registry growth still 1 — batch 6's). **Read the fetch timings honestly:** on the 450-note nine-wing fixture one page fetch measured 2.25 ms (2.11–2.27) and one bookless page 9.02 ms (8.73–9.17), against the old listing reads' 1.25 ms and 6.82 ms in the same run — a single fetch is NOT faster at this scale. What changed is how often it runs (never while the Library is hidden) and how it grows (the batch's headless figures: the loose page's work is flat from 300 to 1,200 notes where the old statement's grew fourfold).
- **The walk, 09:14–09:20,** the orchestrator's hands, on `vm64-walk`, the Debug app built at `dcea98cee`, signed out. Settings ▸ "seed the 100k fixture" seeded "the long haul" (100,025 words, 1,370 blocks) and 300 corpus notes in six books; the Library, flicked down from "corpus note 300", passed "corpus note 1" and ended on the oldest seeded notes, the book row and the "archived" door — the list's true end, every note past the 200th reachable. A line typed in the capture box on the shelf, then the Library: the new note leads the list, above the fixture's notes. The bookless filter lists exactly the two loose notes. The timing readout opened on this build's own table. Captures (local): `notes/plans/vm64-screens/b5w03-library-top.png` … `b5w10-readout.png`.
- **Open from this batch:** P-68-1 (page size 200), P-68-4 (in All, a book older than the last listed note is held back until the notes around it load) and P-68-5 (no face for paging) go to QUESTIONS at the merge. VX-618 stays open: this batch stops the phone Library's part by holding nothing while hidden, not by narrowing what observations watch.

**Tickets filed by this run so far:** VM-226 (the tail's idle save during a divide or merge of the last block) · VM-227 (a note covered by another screen stops hearing its autosave) — both Medium · Bug · Suspected · Editor, traced by reading, each wanting a pin first.

**Batch 6 · VM-69 · VM-70 — FIRST STAGE WINDOW, 2026-11-19 10:10–10:28: NOT GREEN (three release pins); the batch went back to its implementer, who built r1.** Products as built at `24fa9a5e2`; one host process and no restart in every invocation, no trap, no crash report. The machine was extremely loaded (load averages 150 to 494; the coordinator traced most of it to Spotlight indexing, since excluded). Logs kept locally: `notes/plans/vm64-screens/b6-*.log`.
- **Fix build:** the perf suite alone, twice — 10 tests in 1 suite passed both times; reads per open == 1 and registry growth == 0 held. The 73 types in one invocation — 558 test starts, 551 passed, 4 failed ("556 tests in 73 suites failed with 11 issues (including 2 known issues)"): the fence suite whole-green in company, `MobileChipScopeTests` green; red were VM-24's standing caret test in main's shape and three of the batch's own pins in `MobileNoteOpenOnceTests` — `closingANoteLandsItsTextThenGivesItsCoordinatorBack` (1 issue) · `theReleaseWaitsForTheLeavingSavepoint` (1) · `aCoordinatorAnotherHolderNeedsIsNeverLetGo` (5). That suite re-run ALONE (load 145): the same three failed, each at its ~10 s deadline.
- **Red build:** the perf suite's four assertions failed as designed (reads per open in three tests; registry growth); `MobileNoteOpenOnceTests` failed chrome-once and the chips trace as designed, and the same three release pins — red on both builds, so they proved nothing.
- **What it showed (the implementer's r1 trace, its §7 "Iteration r1"):** the release sat in the editor's `deinit`, and nothing in her app is shown to free a popped screen's editor promptly — the perf series passed only because its harness destroys its host. VM-70 was therefore not fixed for her road at r0. r1 moves the release out of `deinit`: it is now the last act of the leaving's one task (flush, savepoint, release), with the hold taken back when a screen shows again.

**Batch 7 · VM-71 — the Mac piece, 2026-11-19 10:37, GREEN:** the seven types over the shared savepoint road (`SavepointOnLeaveTests` · the three autosave-registry suites · `MacWillLockTests` · `AutosaveCoordinatorTests` · `TestHostInertTests`) from `vm64-b7` at `c9b574513` — 48 tests in 7 suites passed (load averages 24 109 156). Log `b7-mac.log`. Batch 6's r1 changed phone files only, so that Mac product is still the tip's Mac code. The phone piece is owed, and it runs from products built on r1.

**Batch 6 (r1) and batch 7 — THE STAGE WINDOW ON THE FINAL TREE, 2026-11-19 10:54–11:09: GREEN. BATCHES 6 AND 7 CLOSED.** Products: `vm64-b6r1` (the tip's code at `ce3c4e75b`) for batch 6's own suites; `vm64-b7r1` (built at `a61e4f7c9`, the tip's code with batch 7's last test change) for the perf suite and the company run; `vm64-b6r1-red` and `vm64-b7r1-red` for the pre-fix runs. One host process and no restart in every invocation; no trap, no crash report. Logs kept locally: `notes/plans/vm64-screens/r1-*.log`, `final-*.log`, `b7r1-*.log`.
- **Batch 6's release, the calm re-run the first window asked for.** `MobileNoteOpenOnceTests` alone on the fix build (10:54:31, load averages 132.61 44.67 67.56): 10 tests in 1 suite passed. The three release pins RAN AND PASSED far inside their 10 s guard — `closingANoteLandsItsTextThenGivesItsCoordinatorBack` 0.08 s · `theReleaseWaitsForTheLeavingSavepoint` 0.72 s · `aCoordinatorAnotherHolderNeedsIsNeverLetGo` 0.63 s — so no load could flip them: at r0 the release lived in a `deinit` nothing on her road reaches, a product fault the load never explained. The recorded probe line: `built-screen|leaving-done=true|alive-after-close=true|after-update=false|…|holders=0` (the editor outlives its close until SwiftUI's next update; the hold is already back). The shell-pop probe could not drive the Back button in process (`no-back-door`) — that road is the walk's. `MobileNoteHoldTests` alone: 4 tests passed.
- **Batch 6's red build** (`MobileNoteOpenOnceTests` alone): RAN AND FAILED `anOpenAsksForTheWholeDocumentChromeOnce` · `openingANoteReadsNoListingOfEveryBookOrEveryTag` · the three release pins (each at its 10 s guard) · `anEditorThatNeverArrivedGivesItsHoldBack`; the two hazard guards and the two probes passed.
- **Batch 7's red build:** `MobileLeavingSavesOnceTests` alone — RAN AND FAILED the five designed (`poppingAChangedNoteLeavesOneSavepointAndAgainAfterTheNextChange` · `aStandardBackgroundingLeavesOneSavepointAndThePopAfterAChangeAnother` · `aCastleBackgroundingSavepointsOnceBeforeTheStoreCloses` · `theLockSavepointsOnceBeforeTheStoreCloses` · `leavingANoteSheOnlyReadAsksTheRunnerForNothing`); the tab-switch test and the closed-store guard passed. The perf suite alone — RAN AND FAILED `backgroundingWithAnEditedNoteOpenCountsItsSavepointAttempts` (Castle 3) · `lockingWithAnEditedNoteOpenCountsItsSavepointAttempts` (2) · `leavingTheHundredKNoteHoldsTheRunnerOnlyForWhatItOwes`; the other ten passed.
- **The company run on the final tree:** 80 types in ONE invocation from `vm64-b7r1` (batch 6's 73, `MobileNoteHoldTests`, and the six of batch 7's not already there), one host process — 580 test starts, 575 passed, 1 test failed: "578 tests in 80 suites failed with 4 issues (including 2 known issues)". The fence suite, both batch-6 suites, the hold suite and batch 7's leaving suite are whole-green in company. The only red is VM-24's standing caret test in main's shape (2 of 3 cases, 2 issues); the two known issues are `MobileTrashTests`' designed one, twice.
- **The perf suite alone, twice, on the final tree** (13 tests passed both times; run 1 at 10:56:40, load 102.66 95.88 87.38; run 2 at 10:58:56, load 16.42 63.23 75.44 — run 2 is the calmer one).

**THE AFTER NUMBERS — the final tree (batches 1–7), simulator (iPhone 17 Pro, iOS 26.2), Debug build, n = 5 per series; median (min–max). BEFORE is batch 3's run 2.**

| Series | unit | BEFORE (batch 3, run 2) | AFTER run 1 (load 102.7) | AFTER run 2 (load 16.4) |
|---|---|---|---|---|
| `note-open-to-screen-short` | ms | 53.53 (46.93–64.85) | 61.63 (46.56–62.77) | 46.28 (43.16–52.28) |
| `note-open-to-live-short` | ms | 37.92 (33.32–73.00) | 43.28 (38.94–46.35) | 42.30 (30.28–43.73) |
| `note-reads-per-open-short` | count | 2 | 1 | 1 |
| `note-open-to-screen-100k` | ms | 361.61 (357.77–365.59) | 345.20 (341.41–361.87) | 356.73 (342.97–361.77) |
| `note-open-to-live-100k` | ms | 496.14 (494.37–500.23) | 340.95 (339.48–343.57) | 342.86 (340.56–347.08) |
| `note-reads-per-open-100k` | count | 2 | 1 | 1 |
| `shell-box-open-to-note` | ms | 58.08 (57.14–63.81) | 61.57 (30.06–75.50) | 64.90 (58.54–73.86) |
| `shell-box-file` | ms | 3.60 (3.28–7.62) | 6.01 (4.08–7.71) | 8.07 (5.01–12.98) |
| `shell-box-open-to-live` | ms | 35.46 (33.96–36.10) | 36.21 (32.13–49.63) | 35.42 (35.28–49.33) |
| `shell-box-editor-builds-per-open` | count | 1 | 1 | 1 |
| `shell-box-note-reads-per-open` | count | 2 | 1 | 1 |
| `shell-library-open-to-screen-short` | ms | 49.41 (39.95–50.90) | 40.97 (34.84–51.27) | 44.32 (33.45–57.52) |
| `shell-library-editor-builds-per-open-short` | count | 1 | 1 | 1 |
| `shell-library-note-reads-per-open-short` | count | 2 | 1 | 1 |
| `shell-library-open-to-screen-100k` | ms | 326.34 (315.22–329.84) | 323.84 (316.95–330.05) | 347.97 (312.12–365.52) |
| `shell-library-editor-builds-per-open-100k` | count | 1 | 1 | 1 |
| `shell-library-note-reads-per-open-100k` | count | 2 | 1 | 1 |
| `library-rereads-per-box-save` | count | 2 | 0 | 0 |
| `library-redraws-per-box-save` | count | 2 | 0 | 0 |
| `all-listing-rereads-per-box-save` | count | 1 | 0 | 0 |
| `bookless-rereads-per-box-save` | count | 1 | 0 | 0 |
| `library-return-rereads` | count | — | 1 | 1 |
| `library-listing-fetch-ninewings` | ms | 1.14 (1.09–1.47) | 1.07 (1.02–1.50) | 1.16 (0.97–5.61) |
| `bookless-listing-fetch-ninewings` | ms | 6.53 (6.35–7.09) | 6.43 (6.11–7.32) | 6.86 (5.68–18.15) |
| `library-page-fetch-ninewings` | ms | — | 1.88 (1.84–2.17) | 1.90 (1.64–3.77) |
| `bookless-page-fetch-ninewings` | ms | — | 8.08 (7.90–8.64) | 8.21 (7.39–13.95) |
| `library-rereads-per-note-save-covered` | count | — | 0 | 0 |
| `library-redraws-per-note-save-covered` | count | — | 0 | 0 |
| `owner-adoption-nothing-to-adopt` | ms | 1.16 (1.04–1.30) | 0.80 (0.78–0.96) | 0.77 (0.73–0.84) |
| `owner-adoption-rows-nothing-to-adopt` | count | 0 | 0 | 0 |
| `savepoints-per-note-leaving` | count | 1 | 1 | 1 |
| `savepoints-per-backgrounding-standard` | count | 1 | 1 | 1 |
| `savepoints-per-backgrounding-castle` | count | 3 | 1 | 1 |
| `savepoints-per-lock` | count | — | 1 | 1 |
| `leaving-100k-runner-hold-read` | ms | — | 0.56 (0.22–9.89) | 0.47 (0.30–8.82) |
| `leaving-100k-to-saved-read` | ms | — | 6.80 (4.37–7.40) | 6.69 (4.95–7.43) |
| `leaving-100k-writer-take-reads-read` | count | — | 0 | 0 |
| `leaving-100k-writer-take-scans-read` | count | — | 0 | 0 |
| `leaving-100k-runner-hold-edited` | ms | — | 7.18 (6.74–7.72) | 6.71 (3.46–7.73) |
| `leaving-100k-to-saved-edited` | ms | — | 20.31 (19.75–20.47) | 19.68 (13.18–21.36) |
| `leaving-100k-writer-take-reads-edited` | count | — | 1 | 1 |
| `leaving-100k-writer-take-scans-edited` | count | — | 0 | 0 |
| `box-first-save-after-100k-leaving` | ms | — | 8.14 (6.56–9.58) | 7.83 (7.49–9.11) |
| `autosave-registry-growth-per-open-close` | count | 1 | 0 | 0 |
| `note-rereads-per-save-100k` | count | 1 | 1 | 1 |
| `note-deliveries-per-save-100k` | count | 1 | 1 | 1 |
| `note-delivery-ingest-100k` | ms | 4.49 (3.92–4.80) | 4.31 (3.90–4.82) | 3.83 (3.42–3.99) |

**Batch 7's own BEFORE figures (the pre-VM-71 build `vm64-b7r1-red`, the perf suite alone, 2026-11-19 11:07, load 9.63; simulator, Debug, n = 5) — the series batch 7 added, which the table above shows only AFTER:** leaving the 100k note after only reading it held the runner **158.90 ms (154.01–160.00)** and took 161.09 ms to "saved", with **1,404** take reads and **1** scan on the writer; after one edit, 159.16 ms on the runner and 166.29 ms to "saved", the same 1,404 reads; **the capture box's first save after leaving the 100k note took 151.69 ms (148.94–152.09)**; the lock made **2** savepoint attempts. AFTER (run 2 above): 0.47 ms and 6.69 ms with 0 reads and 0 scans (read only); 6.71 ms and 19.68 ms with 1 read (edited); **the box's first save 7.83 ms (7.49–9.11)**; the lock 1. Log: `notes/plans/vm64-screens/b7r1-perf-red.log`.

**Reading them:** every count the run set out to change has changed and is now asserted — a note is read **1** time per open (was 2); the hidden Library does **0** re-reads and **0** redraws per capture-box save (was 2 and 2); backgrounding under Castle makes **1** savepoint attempt (was 3) and the lock 1; the autosave registry grows by **0** per open-and-close (was 1); leaving the 100k note after only reading it reads **0** takes on the writer and holds the runner about half a millisecond, and after one edit reads **1**. One duration moved outside noise: the 100k note is live about 150 ms sooner after opening (496 → 342 ms), which is the second read removed. The others are unchanged within run-to-run range, and they are small simulator figures at fixture scale: the readout on her wave-1 build is what will say how much of what she feels this run removed.

**The merged tree (main's VM-55 in) — THE STAGE WINDOW, 2026-11-19 14:43:27–14:51:11: ALL FOUR PIECES AS MEANT.** Products: `vm64-gate` and `vm64-gate-red`, both built at `f4068b3cf` (the tip's code: every later commit to that point was this record or the round-2 findings file). The standing simulator, a fresh boot, a 30 s settle; load 2.3 at the start and 3.7 at the end. One host process and no restart in every piece; no trap, no Problem Reporter, no new Variorum crash report; the simulator shut down; the standing device's app container listed `Variorum-dev` only. Logs kept locally: `notes/plans/vm64-screens/mg-*.log`, `window-merged.out`.
- **Piece 1 — ladder round 1's finding 2, RED ON OLD** (`vm64-gate-red`: the merged tree with only that finding's hunk in `takeAutosaveHold` reversed; `MobileNoteHoldTests` alone): 5 tests in 1 suite, FAILED with 2 issues — both in `aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator`, "Expectation failed: model.observesAutosave" at `MobileNoteHoldTests.swift:227` (after the re-show) and `:234` (after the leaving ends); the other four passed.
- **Piece 2 — the same type on the fix build** (`vm64-gate`): 5 tests in 1 suite passed. Round 1's condition on finding 2 (red on the hunk-reversed build, green on the fix build) is met; the company arm is piece 3, where the type ran green beside 37 others.
- **Piece 3 — the merge's types in one host** (`vm64-gate`, 38 types: VM-55's `MobileWingStandTests`, `MobileWingListingTests`, `MobileWingMintTests`, `MobileWingTagManagerTests`, `MobileWingDoorTests`, `MobileWingDoorGeometryTests`, `MobileWingListSheetTests`, `MobileWingDoorShellTests`, `MobileLineShowRuleTests`, `MobileMessageLineGeometryTests`, `MobileMessageLineHostTests`, `MobileMessageLineInsetTests`, `MobileMessageLineSceneTests`, `MobileLineDoorTests`, `MobileNoRawErrorPinTests`, `MobileRefusalSentencePinTests`, `MobileErrorLogPrivacyPinTests`, `MobileWingBlindPickerTests`, `MobileWingBrainsHoistTests`, `MobileLineDirectionTests`, `MobileLineStandingOfferTests`, `MobileRefusalFallbackTests`; this run's `MobileLibraryPagingTests`, `MobileLibraryPagingRulesTests`, `MobileNoteHoldTests`, `MobileNoteOpenOnceTests`, `MobileLeavingSavesOnceTests`, `MobileStructuralFlightFenceTests`, `MobileUndoDoorTests`, `MobileNavigationTests`, `MobileShellTests`, `MobileTimingTests`, `MobileDeletionTests`, `MobileRefusalTableTests`, `MobileSavepointOnLeavingTests`, `MobileChipScopeTests`, `MobileLibraryTests`, `MobileFilterTests`): **234 tests in 38 suites passed**, no red, no known issue — VM-55's four re-landed Library pins with their expectations unchanged, the hidden-switch guard, the hold key's wing lines and the raw-error scan over the four converted lines among them.
- **Piece 4 — a probe: the speed suite in company** (`vm64-gate`; `MobileHerPathsPerfTests` beside `MobileNoteOpenOnceTests`, `MobileLeavingSavesOnceTests`, `MobileLibraryPagingTests`, `MobileQuickNoteTests`, `MobileNavigationTests`, `MobileShellTests`): **98 tests in 7 suites passed**, every count assertion holding (reads per open 1, editor builds per open 1, hidden-Library re-reads and redraws 0, savepoint attempts 1 on all four roads, owner-adoption rows 0). What the log shows: this host ran the suites ONE AFTER ANOTHER, never interleaved, and the speed suite happened to run first (129 s, then the next suite started). So the suite's stated hazard — another suite running beside it — did not occur; the suite running AFTER others (their leftovers landing in its windows) was not tested. The orchestrator's item O-1 (ladder round 2's fix pass) gates the suite behind an environment switch so that it runs only when asked, alone; the stage coordinator made that a condition of the merge gate.
- **The merged tree's speed numbers from the probe run** (simulator, Debug, n = 5, in company — indicative only): the 100k note live 338.79 ms after opening (332.29–352.28); the nine-wing page fetch 1.78 ms and the old listing read 0.99 ms, the Bookless page 3.46 ms and the old Bookless read 2.71 ms — these four now read the CURRENT WING only (Home, a ninth of the fixture) since VM-55, where the BEFORE and AFTER tables above read every wing, so they are not comparable with those tables.

**Ladder round 2's fixes — THE STAGE WINDOW, 2026-11-19 16:47:12–16:55:40: THE SEVEN MEANT REDS ON THE OLD BUILD AND NO OTHER; EVERYTHING GREEN ON THE FIX.** The first time any line of the round-2 fix pass ran. Products: `vm64-gate2` (phone; the final code, built at `74d91c666` — every later commit is the record or a notes-only merge of main) and `vm64-gate2-red` (the same tree with only the pass's production hunks reversed in six files — `MobileLibraryViewModel.swift`, `MobileLibraryView.swift`, `MobileLine.swift`, `MobileQuickNote.swift`, `Shared/AppTiming.swift`, `MobileTimingView.swift` — and the ★ design pin's file aside). The standing simulator, a fresh boot, a 30 s settle. One host process and no restart in every piece; no trap, no Problem Reporter, no new Variorum crash report; the simulator shut down; the standing device's app container listed `Variorum-dev` only. The machine's load average read high from the system's own background I/O, with no build or test running elsewhere (the coordinator's check): 35.9 at piece 1's start, 16.0 at its end, 12.0 after piece 2, 1.9 after piece 3, 2.4 after piece 4 — no timing-shaped test went red where it was meant green. Logs kept locally: `notes/plans/vm64-screens/r2-*.log`, `window-r2.out`.
- **Piece 1 — RED ON OLD** (`vm64-gate2-red`; `MobileLibraryPagingRulesTests`, `MobileBoxOpenTimingTests`, `MobileTimingTests`, `MobileNoteOpenOnceTests`): 31 tests in 4 suites, FAILED with **16 issues in exactly seven tests**, the other 24 green (the read-once guard `anOpenReadsTheNoteOnceAndTheOldShapeTwiceByTheSameOracle` among them, green by design on both builds):

  | Test | Issues | Where |
  |---|---|---|
  | `aRowDeletedPastTheFirstPageLeavesTheListing` | 2 | `MobileLibraryPagingRulesTests.swift:157` (the deleted note still listed), `:162` (the listing is not the store's first 8) |
  | `aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage` | 2 | `:196` (its premise: the deleted note never left), `:206` (the final order comparison) |
  | `aPutBackAfterTheLibraryCameBackReturnsARowPastTheFirstPage` | 2 | `:246` (the note Put back is not listed), `:251` |
  | `aWingSwitchedWhileBooklessWasNotHeldDrawsNoOtherWingsRows` | 2 | `:279` (Home's note drawn in Work), `:281` |
  | `aDoorOpenedAfterAWingSwitchDrawsNoOtherWingsRows` | 1 | `:314` |
  | `MobileBoxOpenTimingTests.anOpenThatFilesNothingLeavesNoOpenSpan` | 4 | `MobileBoxOpenTimingTests.swift:72`, `:73` (both Open spans left open), `:79`, `:80` (a false sample each) |
  | `MobileTimingTests.theReadoutShowsThisBuildThenThePreviousOne` | 3 | `MobileTimingTests.swift:64`, `:65`, `:78` (the heading drawn in capitals) |

  **One issue more than the fix pass's closeout predicted (16, not 15):** the line's-Undo pin was predicted red at its premise only; it also failed its final order comparison at `:206`. The orchestrator's reading, not traced further (it is the pre-fix build, and the test is already red at its premise): on the old build the deleted row never leaves the listing, so the wait for its return ends at once and the comparison reads the store before the Put back has landed. The same seven tests, no other red.
- **Piece 2 — the fix alone** (`vm64-gate2`; the four types above and `MobileLibraryRowActsTests`): **32 tests in 5 suites passed.**
- **Piece 3 — the fix in company** (`vm64-gate2`, one host, 27 types: `MobileLibraryPagingRulesTests`, `MobileLibraryRowActsTests`, `MobileBoxOpenTimingTests`, `MobileTimingTests`, `MobileNoteOpenOnceTests`, `MobileNoteHoldTests`, `MobileLibraryPagingTests`, `MobileLibraryTests`, `MobileLibrarySortTests`, `MobileFilterTests`, `MobileEmptyStoreTests`, `MobileDeletionTests`, `MobileTrashTests`, `MobileVersionsTests`, `MobileWingListingTests`, `MobileWingStandTests`, `MobileWingDoorTests`, `MobileWingDoorShellTests`, `MobileWingDoorGeometryTests`, `MobileLineDoorTests`, `MobileLineShowRuleTests`, `MobileLineDirectionTests`, `MobileStarsTests`, `MobileQuickNoteTests`, `MobileNoRawErrorPinTests`, `MobileErrorLogPrivacyPinTests`, `MobileHerPathsPerfTests`): **237 tests in 27 suites passed with 2 known issues** — both `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`'s declared ones (main's). **13 SKIPPED — the gated speed suite:** each of `MobileHerPathsPerfTests`' 13 tests, and the suite, logged "skipped: reads the process's one timing recorder — set TEST_RUNNER_VM66_PERF=1 and run it alone" (Swift Testing counts the 13 inside the 237; they did not run). VM-55's five wing types green beside the wing gate of finding 3.
- **Piece 4 — the gated speed suite alone** (`vm64-gate2`, `TEST_RUNNER_VM66_PERF=1`, `MobileHerPathsPerfTests`): **13 tests in 1 suite passed, none skipped** — reads per open 1 (short and 100k), editor builds per open 1, hidden-Library re-reads and redraws per box save 0 and 0, savepoint attempts 1 on all four roads, owner-adoption rows 0; the 100k note live 337.95 ms after opening (329.65–342.30; simulator, Debug, n = 5).
- **What this settles:** every condition the round-2 reviewer's final calls put on a run — findings 1 and 3 (red on the reversed build, green on the fix, alone and in company, VM-55's wing types green beside them), finding 8(a), finding 9, and O-1's skip and its gated run. Still owed, all the merge gate's: the whole phone target (which must show the speed suite's 13 as skipped), the whole Mac target, the batches 6 + 7 walk.

## 6. Review foci (written at plan time, before any code)

1. Does anything the timing layer records, persists or copies contain note text, a title or an id? Is its cost O(1) per mark and its memory bounded?
2. Does every fix that claims speed carry numbers before and after, as a median and a range, with the simulator named as the simulator?
3. VM-2: is there any road — autocorrect, marked text, dictation, paste, the edit menu with the keyboard up — by which text reaches the store during a structural flight? Is a keystroke ever silently dropped?
4. VM-67: can any row that needs an owner be skipped, on any launch, unlock, sign-in or account change? Does the diff touch `Sources/VariorumCore/Sync/`? If a migration landed, is it its own commit and is the mirror untouched?
5. VM-68: is any held read still corpus-shaped? Can a note be unreachable by scrolling? Did the Mac's Library change in behaviour?
6. VM-69/70: can a remote change be missed between load and first delivery? Can a released coordinator lose text or outlive its note? Is P3's one live editor intact?
7. VM-71: did the lock's behaviour move at all? Is a savepoint that should happen ever skipped?
8. Did the Mac change in behaviour anywhere? Do the brains live in Core or `Shared/`?

## 7. Batch closeouts, findings and dispositions

*(Each implementer writes its batch's closeout here; the ladder's findings and their dispositions follow.)*

### Batch 1 · VM-65 — the timing layer and its readout (implementer closeout)

**Not done in this batch (first, by the record's rule):** no fix of any kind (the batch section's "not in this batch");
nothing on her phone (HELD for her sitting — and, at her word tonight, she will not run the readout now: "leave it in the
handoff bundle for me to do later"); the exact rows-sent and rows-received of a sync round (they live in the engine's
round report, a `Sources/VariorumCore/Sync/` line this run may not write — the readout carries honest approximations,
P-65-7); the phone suites' and the walk's results are PENDING the stage window (P6) as this section is first written.

**Base:** `21747b9de`. **Commits:** `65d70fe9f` (live status) · `feef85c7a` (the brain) · `f6389e3b5` (the catalog, the
marks, the readout) · `808f333a8` (one table per build — the author's sharpening) · PENDING (the stage results).

#### What shipped, file by file

- `Sources/VariorumCore/Diagnostics/` — a new Core folder (the timing layer is neither a domain rule nor a query; Core is
  where headless `swift test` reaches it):
  - `TimingStats.swift` — one series: a fixed ring (64), all-time count, last; median / min / max computed at read time
    over the ring. Equality is over contents (a ring rebuilt from a file starts its cursor at zero). Codable, held to the
    ring's invariants on decode.
  - `TimingRecorder.swift` — the brain, generic over the catalog's two `String`-backed enums. Keyed spans (`begin`
    restarts an open one; `end` drops a begin older than its stale limit; `endIfOpen` for moments that only sometimes
    close a span), token spans (re-entrant), value samples, counters, COUNTING WINDOWS (events of named counters from an
    opening act to a close or deadline, recorded as one sample; `keepFirst` / `restart`), `os_signpost` intervals per span
    (subsystem `io.lduarte.Variorum`, category `timing`). Inert unless enabled (one relaxed atomic load). The day of the
    first sample; a change handler told about the FIRST change after a save (one atomic exchange per mark); `archive`,
    `restore`, and `absorb` (a kept table folded UNDER what a new process already measured). No entry point takes a
    string.
  - `TimingReport.swift` — the readout's plain text (two lines per entry: label, then `n · median · range · last`).
  - `TimingBook.swift` — one table per BUILD: this build's and the previous build's; a third build drops the oldest;
    storing one build never touches another; Codable; a malformed or future file reads as no book.
- `App/Variorum/Shared/AppTiming.swift` — the catalog (23 series, 14 counters) and the ONE recorder, disabled until the
  phone enables it; every mark's meaning in one place (call sites are one line); the process's true start (`sysctl`
  `kinfo_proc`) and the executable's build fingerprint (`LC_UUID`).
- `App/Variorum/VariorumMobile/Features/Perf/MobileTiming.swift` — the phone's half: `start()` (enable, launch spans from
  the process's true start, the file's load, the change handler, the keyboard watch); the next-frame tick (a one-shot
  `CADisplayLink`); `MobileTimingStore` (the timing file).
- `App/Variorum/VariorumMobile/Features/Perf/MobileTimingView.swift` — the readout sheet and its words (`MobileTimingCopy`,
  every label DRAFT).
- The marks (each a pure append unless said): `VariorumMobileApp.swift` (an explicit `init` so the layer turns on BEFORE
  the bootstrap begins opening; backgrounding counts a leaving and saves) · `Shared/AppBootstrap.swift` (`finish(.ready)` =
  library open; the lobby's `opened` = unlock accepted) · `MobileRoadFaces.swift` (lock screen showing) ·
  `MobileShellView.swift` (home on screen) · `MobileWriteView.swift` (`init` = a note requested; `.task` = arrival;
  `.onDisappear` = a leaving, timed to its savepoint) · `MobileEditorViewModel.swift` (`init` = an editor built; `loadOnce`;
  the live observation spelled as `observeTakes`' own body so its fetch counts itself; first and later deliveries;
  `refreshTakesFromStore`; the first render) · `MobileQuickNote.swift` (`open()` = the press; `file()` timed when it
  completes; the box taking focus) · `MobileLibraryViewModel.swift` (both held listings' fetches and deliveries — the note
  listing spelled as `observeLibrary`'s own body; its first delivery = Library ready) · `Shared/AppSession.swift`
  (`savepointOnLeaving` = an attempt) · `Shared/AutosaveCoordinator.swift` (around each take's write) ·
  `Shared/AppServices.swift` (owner adoption timed, its rows counted — the op's report, previously discarded, is now read)
  · `Shared/SyncSession.swift` (the round, from the scheduler's own public status) · `MobileSettingsView.swift` (the
  "Timing…" row).
- Tests: `Tests/VariorumCoreTests/TimingRecorderTests.swift` (31, headless) · `VariorumMobileTests/MobileTimingTests.swift`
  (4: readout coverage of every series and counter; both tables in order; the file keeping builds apart across "quits").

#### What each number means (so a later batch reads it right)

| Series (readout label, DRAFT) | Begins | Ends | Notes |
|---|---|---|---|
| Tap the box → keyboard up | the box takes focus (`.onChange(of: focused)`), only if no keyboard is up | `keyboardDidShow` | P-65-6: starts when the app PROCESSES the tap; time the main thread spends before processing it is outside |
| File → box clear | `file()` starts | `file()` returns having filed a note | empty box, refusal, withdrawal: discarded, never recorded |
| Open → note on screen | `open()` (⏎ or the open door) | the display-link tick after the new note's first render | the whole of lag 2 |
| Open → keyboard up in the note | `open()` | `keyboardDidShow` | |
| Open a note → on screen | `MobileWriteScreen.init` (every road: Library, book, box, Starred) | as above | a rebuild of the same screen restarts it (a few ms short, never a stale begin) |
| Leave a note → saved | `.onDisappear` | its teardown and `savepointOnLeaving` done | |
| Launch → lock screen / library open / home on screen / Library ready | the process's start (kernel's, so pre-main time is inside) | the lobby's next frame / `finish(.ready)` / the shell's next frame / the Library's first listing | the lock screen cancels the other three (what follows waits on her) |
| Unlock → library open / home / Library ready | the lobby's `opened` (Face ID or passphrase accepted) | as above | |
| Owner check at start | `runOwnerAdoption` | its return (refused too) | + "rows stamped" |
| Sync round | the status turns syncing | it stops, or the completed count moves | + "rows sent (about)" = outbox at start − still owed after; "changes received (about)" = the pull cursor's advance (counts this device's own pushed rows too) — P-65-7 |
| Note reads per open (window) | the screen's `.task` | the live observation's first delivery (or 10 s) | counts `loadOnce` + every observation fetch; audit F 2C predicts 2 |
| Note re-reads per save (window) | before each autosave write | the next save or 1 s | every MOUNTED editor's re-fetch counts (audit F §7) |
| Library re-reads / redraws per save (windows) | as above | as above | both held listings (all + bookless) |
| Savepoints per leaving (window) | a note's `.onDisappear` or the app's backgrounding (`keepFirst`) | 10 s | a Castle backgrounding's lock teardown counts inside its leaving. *[Ladder round 2, finding 8(b): no act closes this window early, so two leavings inside ten seconds are ONE sample holding both — leave about ten seconds between leavings when reading it (the handoff's readout step says so). Closing it at `noteLeft` was weighed and not built: the window does not record whether a note's leaving or the app's backgrounding opened it, and a backgrounding's window must keep counting through the removed screens' own leavings.]* |

Totals (monotonic): notes opened (arrivals) · editors built (÷ opened > 1 = audit F 2D's twins, settled by the count) ·
note reads at open / live / at a tab switch · note redraws live · Library and bookless reads and redraws · saves ·
savepoint tries · notes left · app left. The footer: spans restarted, ended too late to count, ended with no start.

#### The author's sharpening (mid-batch, 2026-11-19 — an author-driven change, recorded as such)

Relayed by the orchestrator: she will NOT run the readout tonight ("leave it in the handoff bundle for me to do later");
the BEFORE build may live on her phone for days and the AFTER build is installed over it much later. Built to it:
(1) the record survives a full quit and an install in place — `Library/Application Support/Timing/timing.json` in the
app's container, outside the store, numbers only (plus each table's build key, label and first day); saves are BATCHED off
every timed path — the recorder tells the store about the first unsaved change, the store writes 20 s later on its own
serial utility queue, and at once (same queue, its own background-task grant) at every backgrounding, so **a crash loses
at most the last 20 seconds of marks**; the launch never waits on the file (the kept table is read on the store's queue
and `absorb`ed under what the launch already measured). (2) One table per build; a new build never blends into the old;
the previous build's table stays readable under this one's on the readout, and Copy exports both, each headed by its
build. **Reset clears THIS build's table only; the previous one is cleared only by aging out when a third build opens**
(P-65-4). (3) Each table says the day it began collecting, and every row its `n`. **One deviation, forced and recorded
(P-65-3):** her words key a table on the bundle's build number, but the phone does not stamp it — every phone build says
`1` (`CURRENT_PROJECT_VERSION = 1`; only the Mac target runs `StampBuildNumber.sh`) — so the key is the short version +
the build number + the executable's fingerprint, and the label shows all three. Her rule (never blend two builds) holds;
her literal key would have broken it.

#### PROVISIONAL calls (options weighed; the built one first)

- **P-65-1 — the readout's home:** Settings ▸ Diagnostics, a "Timing…" row beside "Edit trace…" (built — the brief's
  proposed home, the Release-shipped precedent) · its own Settings section · DEBUG-only (rejected: her phone runs Release).
- **P-65-2 — always recording on the phone, no arming switch** (built — her BEFORE numbers must not depend on remembering
  to arm; cost is O(1) per mark at act cadence) · an arming switch like the edit trace's.
- **P-65-3 — the build key** (above): version + number + fingerprint (built) · the number alone (blends BEFORE into AFTER)
  · stamp the phone's build number (wave 6's build-stamping row, VM-216 — not this batch's file set).
- **P-65-4 — what clears the previous build's table:** only a third build's arrival (built — simple) · a second
  "Clear previous" door · keep more than two.
- **P-65-5 — "on screen":** the display-link tick after the render (built — the frame carrying the text has been
  committed) · the render's return (misses the layout it sets off) · a `CATransaction` completion (unreliable without
  animations).
- **P-65-6 — "tap the box":** the box taking focus (built — zero behaviour change) · the physical touch (needs an event
  timestamp from UIKit — a gesture or `sendEvent` hook on a surface wave 2 owns).
- **P-65-7 — a round's rows:** two cheap local readings in `SyncSession` (built — no `Sync/` line; labelled "about") ·
  exact counts from the engine's push/pull reports surfaced on the scheduler's status (a `Sync/` line — the author's slot
  rules and another batch).
- **P-65-8 — Reset asks nothing** (built — the edit trace's Clear precedent) · a confirm (protects BEFORE numbers from a
  stray press).

#### The Mac does not change (review focus 8)

Every shared mark (`AppBootstrap`, `AppSession`, `AppServices`, `AutosaveCoordinator`, `SyncSession`) calls into the one
recorder, which only `MobileTiming.start()` enables — the Mac never calls it — so on the Mac each mark is one relaxed
atomic load and a return: nothing recorded, saved or signposted, no file, no reads. Two lines change shape without
changing behaviour: `runOwnerAdoption` now keeps the op's report it used to discard (`_ =`), and `SyncSession`'s status
loop consults the round timing before assigning (an early return while disabled). The phone's two observations keep
their exact bodies (`observeTakes` = `observe { takesProjection }`; `observeLibrary`'s defaults `profile: nil, wingID:
nil`). PENDING: the Mac suites over those shared types (below).

#### Evidence

- Core, headless (no stage): `swift test --filter TimingRecorderTests` — **31 tests in 1 suite passed** (statistics, the
  ring's bound, an unmatched begin, a re-entrant keyed span and overlapping token spans, stale ends, windows, the disabled
  recorder, the since-day, the change handler, absorb, per-build keying, the two-build bound, the round-trip through the
  persisted form, concurrency).
- Builds at `808f333a8`: phone Debug `build-for-testing` · phone Release `build` · Mac `build-for-testing` — all succeeded;
  no warning in a touched file.
- PENDING (P6): the phone suites (`MobileTimingTests` + the touched suites), the Mac suites over the shared types, and
  the simulator walk with its captures in `notes/plans/vm64-screens/`.

#### The stage window (what P6 runs — the GO's claim line and UDID fill `<simulator-udid>`)

Phone (boot fresh inside the claim, settle, then `test-without-building` over this batch's products; a zsh array):
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileTimingTests MobileQuickNoteTests MobileQuickNoteReadFailureTests MobileShelfPerfTests MobileLibraryTests
  MobileLibrarySortTests MobileFilterTests MobileSavepointOnLeavingTests MobileRoundOccasionTests MobileNavigationTests
  MobileLivenessTests MobilePerfFixtureTests MobilePerfWalkTests MobileLaunchPathTests MobileEditTraceTests MobileWalkTests
  MobileDeferredProjectionRetryTests MobileConflictDiscoveryTests MobileTypedOverRescueTests MobileTakesTests
  MobileLockTeardownTests MobileRelockCoordinatorTests MobileQuickNoteUnderLockTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b1 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Mac (the shared types; the recorder stays disabled there, so these prove "unchanged"):
```
tests=(AutosaveCoordinatorTests AutosaveConsolidationTests SavepointOnLeaveTests SyncBeforeRoundTests FirstRoundRoadTests
  SyncSessionFenceTests Phase9cAuthWiringTests AppBootstrapOffMainTests TestHostInertTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath DerivedData/vm64-b1 ${tests/#/-only-testing:VariorumTests/}
```
The walk (Debug phone app, dev store, signed out, never Resume, no test account): install
`DerivedData/vm64-b1/Build/Products/Debug-iphonesimulator/VariorumMobile.app` on the booted simulator; `simctl launch`
(a cold launch); tap the box, type a line, Open (⏎), back, Library ▸ open that note, back; Settings ▸ Timing…; capture.
Hands: the VM-8 precedent (Device Hub hosts the simulator; captures `simctl io … screenshot` only; taps `cliclick` at
host points from a template-match calibration; keys by System Events to Device Hub, frontmost verified; the author guard
before every GUI act) — throwaway helpers in the session scratchpad, never committed. **Known limit:** in hardware-
keyboard mode (VM-10's record: this machine's headless simulator stays there) the software keyboard never rises, so the
two "→ keyboard up" spans can only fill if Device Hub can toggle the software keyboard; if it cannot, the walk records
them as empty BY DESIGN of the instrument (no `keyboardDidShow`), and they are first filled on her phone.

#### For QUESTIONS at the merge (the orchestrator carries these to `notes/QUESTIONS.md`)

1. **P-65-3 — the build key.** Her words: keyed on the bundle's build number. The phone's build number is never stamped
   (always `1`). Options: (a) version + number + executable fingerprint (built); (b) stamp the phone's build number (the
   Mac's `StampBuildNumber.sh` phase on the phone target — wave 6's build stamping) and key on the number alone; (c) the
   number alone as it stands (blends every build — rejected).
2. **P-65-4 — clearing the previous build's table.** (a) Only a newer build's arrival ages it out (built); (b) a "Clear
   previous" door beside Reset; (c) keep more than two builds.
3. **P-65-1, P-65-2, P-65-8 — the readout's home, always-on recording, Reset without a confirm** (options above).
4. **P-65-7 — a sync round's exact rows** need a `Sync/` line (the engine's reports on the scheduler's status); today's
   readout says "about". Hers to schedule if the approximations prove too blunt for the minute-long empty round.
5. **The labels** (every string in `MobileTimingCopy`, and the section and footer words) — her wording pass.

### Batch 2 · VM-2 — the keystroke fence for structural flights (implementer closeout)

**Not done in this batch (first, by the record's rule):** the stage runs are PENDING the orchestrator's window — the
pins' green run, the red-on-old run, and the phone editor suites (the commands are below, runnable by anyone from my
built products). No simulator walk: the window is the milliseconds between a menu tap and the settled page, which a
hand cannot hit on purpose; the hosted pins drive the real Write text view's own key entry points (`insertText`,
`deleteBackward`) through a deterministically held flight instead (an ordinary-use smoke is offered below as optional).
Not touched, by the unit's line: the structural UNDO door (`MobileUndoDoor`, its own `inFlight` latch — the same window,
recorded below as a follow-up), the crystallizer's declared arms, `runStructural` (Mac), `BlockRangeIndex`, `Sync/`.

**Base:** `9cf3b3688`. **Commits:** `2358f33cb` (live status) · `76dbf89b2` (the brain) · `f83122794` (the face + the
pins) · `1f292b1ec` / `5b40f1984` (the red-on-old revert announced, then restored) · this closeout.

#### The mechanism, as traced on this tree (the VM-5 record's MAJOR 1, re-verified and corrected)

A phone structural door raises `structuralInFlight`, flushes (`flushPendingText`), then suspends — the fan read, the
operation on the runner, and its own settle (`refreshTakesFromStore`: flush, read, ingest) — while the page and
`BlockRangeIndex` still show the note as it was. Nothing consulted the latch outside `MobileStructural.swift`: the gate
(`shouldChangeText`) approved a keystroke there as `.block(i)` against the old tiling; `recordAutosave` recorded the
WHOLE old block text; the door's own settle flushed it after the operation committed. The gate-less roads (M25's
measured programmatic `deleteBackward()`/`replace(_:withText:)`, and the system's composition commits and dictation)
took the same `.block(i)` arm through `fallbackVerdict`. **Correction to the VM-5 record:** the flush is no longer
unconditional — since VX-683 B it carries `expectedText` (the ledger's pre-edit text), the row no longer holds it, and
`Operations.autosave` RESCUES: the old block text + the keystroke keeps the chosen take and the operation's real
result becomes a spurious `'conflict'` take. Net effect per door, all measured shapes the pins name:
divide — the moved half reads twice; extract / make block — the lifted span reads twice; merge — her prose lands in a
RELEASED source's take (no rescue: the row still holds the snapshot), gone from the note. **Insert below** rewrites no
existing text, so its keystroke wrote A's CURRENT text — never stale (its twin is HOLLOW, below).

#### What shipped, file by file

- `Sources/VariorumCore/Domain/StructuralFlightFence.swift` — the rule, pure (the `MarkdownCaretRescue` precedent for a
  live-surface brain in Core, so `swift test` reaches it): phases `open · flying · settling`; `offer` (a typed key is
  deferred while up; a composition in progress never is); `refusesPolicedEdit` / `withholdsSystemEdit` (true while up,
  each leaving a one-sentence debt); `flightLanded(surfaceSettled:)` → `.drain` or `.awaitSettle`; `surfaceSettled()`;
  `drain()` (lowers, hands back the keys in order and whether to speak); the settle rule
  `surfaceHoldsTheStore(forcedRenderOwed:projectionDeferred:)`. Logs nothing, persists nothing.
- `Tests/VariorumCoreTests/StructuralFlightFenceTests.swift` — 10 headless tests.
- `App/Variorum/VariorumMobile/Features/Write/MobileStructural.swift` — ONE change: the latch's `didSet` calls
  `model?.structuralFlightChanged(up:)` on each edge, so every door that holds the latch (divide, merge, extract, make
  block, insert below, delete, archive, the whole-block delete, the cross-block compound) is fenced and no door body
  changed.
- `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift` — the face:
  - `flightFence` (state, readable); `structuralFlightChanged(up:)` (raise; at the latch's fall, drain if the page holds
    the store, else `settleFlightSurface`); `deferTypedInputDuringFlight` (the text view asks first);
  - **the settle** — `flightSurfaceHoldsTheStore` (no `forceFullRender`, no `pendingProjection`); `settleFlightSurface`
    re-reads at most three times (`awaitMintSettle` + `refreshTakesFromStore`), then waits for the next applied
    projection (`applyProjection`'s settling hook, which schedules the drain on the next turn — never from inside the
    apply). FAIL-CLOSED by design (P-2-4);
  - **the drain** — speaks `StructuralUndoCopy.anotherIsLanding` (the one home of the sentence every door already says)
    with the receipt's action (the door's Undo) kept, then replays the keys in order at the landed caret: `insertText`
    through the text view (UIKit consults the gate — the walk suites' measured road), a held ⌫ through
    `replayDeferredDeleteBackward`;
  - **the gate belt** in `shouldChangeText` (after the gone / stood-down / sealed belts and the attribute-only return):
    refuse with the sentence, disarming `pendingEdit` and `bulkPending` (NIT 4's doctrine);
  - **the storage belt** in `storageDidEdit`'s `.block(i)` arm: the tiling and the re-stamp run as ever (the identity
    audit stays coherent), `recordAutosave` does NOT, and `forceFullRender` is set so the settle re-reads the page from
    the store. The tail arms are untouched (no block text, nothing stale; P-a's measured mint interleavings stand);
  - **the door contract** (`flushPendingText`): while a fence is up and a forced render is owed (a gate-less edit
    landed during the door's own flush suspension), the page is re-read before the door plans against it — the
    pre-fence behaviour there was a dirty buffer refusing the door; this keeps the plan honest without a new refusal.
- `App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift` — `insertText` asks the fence FIRST (so a ⏎
  waits whole and its list continuation runs at the replay); a new `deleteBackward` override does the same;
  `replayDeferredDeleteBackward` runs a held ⌫ through the pre-gated `MobileMarkdownActs.inputReplace` (a programmatic
  `deleteBackward()` never consults the gate — M25), over the selection or the one composed character before the caret.
- `App/Variorum/VariorumMobileTests/MobileStructuralFlightFenceTests.swift` — 10 hosted pins (below). They use only API
  that exists on the base tree, so the same file builds against it for the red run.

#### What each kind of input gets during a flight (the batch's question, answered)

| Input | Road | Under the fence |
|---|---|---|
| Typed character, ⏎, ⌫ (software or hardware keyboard) | `insertText` / `deleteBackward` | **deferred** in order, replayed at the landed caret through the policed road — never dropped. If UIKit's ⌫ ever arrives by a private road that skips the override, it meets the gate belt instead (refused, said) |
| Paste, a formatting-bar act, Tab, an edit-menu act | the gate (pre-gated or UIKit's consult) | **refused**, said once as the fence drops |
| An autocorrection that consults the gate | the gate | **refused** — her typed word stays as she typed it; said |
| An autocorrection / programmatic replace that does not consult | gate-less storage report | **withheld** — the page is re-read from the store; said |
| Marked text (a composition in progress) | never deferred | its updates and its commit meet the gate (refused) or arrive gate-less (withheld); **a composition committed inside the window is the one case where her own text is refused rather than delayed** — said, never silent |
| Dictation | gate-less | **withheld**, said |
| Keys typed after the latch falls but before a deferred settle lands | `insertText` / `deleteBackward` | still deferred (the fence stays up until the page holds the store) |

Autocorrect after the flight: the held keys replay before her next keystroke, so the keyboard's word context is whole
again and the next space autocorrects as usual.

#### The pins (red-on-old by the second build; PENDING the stage window)

| Pin (`MobileStructuralFlightFenceTests`) | Road · door | Expected on the OLD build (`vm64-b2-red`) |
|---|---|---|
| `keysTypedWhileADivideLandsReplayAtTheLandedCaret` — **THE PIN (probe 2 inverted)** | A (X, Y, ⌫) · divide | RED: store `["Alpha beta. XGamma delta.", "Gamma delta.", …]` (or `…XYGamma…` if the off-window programmatic ⌫ never reaches storage) and `conflictTakes == 1` |
| `anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid` | B · divide | RED: `["Alpha beta. Gamma delta.X", "Gamma delta.", …]`, a conflict take, `statusMessage == nil` |
| `aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore` | C · divide | RED: the same store, a conflict take, the page holding the duplicate, `statusMessage == nil` |
| `aKeyTypedWhileAMergeLandsEndsUpInTheMergedBlock` | A · merge | RED: `occurrences(X) == 0` in the note and `markerInUnplacedTakes == 1` (in the released source) |
| `aGatelessEditDuringAMergeNeverLandsInAReleasedSource` | C · merge | RED: `markerInUnplacedTakes == 1`, `statusMessage == nil` |
| `aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan` | A · extract | RED: `["Alpha beta.", "Alpha beta. Gamma delta.X", …]` (the span twice) + a conflict take |
| `aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource` | A · make block | RED: `["Alpha beta. Gamma delta. Epsilon zeta.X", "Gamma delta.", "Epsilon zeta.", …]` + a conflict take |
| `insertBelowTwinNoKeyTypedDuringTheFlightIsLostOrDuplicated` | A · insert below | **GREEN on old — HOLLOW** for the stale-write claim (see below) |
| `aKeyTypedWhileInsertBelowLandsGoesIntoTheNewBlock` | A · insert below | RED by design of the change, not a bug pin: old `["Alpha beta. Gamma delta.X", "", …]` (P-2-5) |
| `afterTheFlightLandsTypingIsOrdinaryAgain` | — | GREEN on both (a guard: the fence is gone after a landing; nothing is said when nothing was refused) |

So the red run expects **8 failing, 2 passing**; the green run expects **10 passing**. Every pin also asserts the DEBUG
identity audit quiet (`identityAuditFailures == 0`) and no desync heal (`desyncRecoveryCount == 0`). The window is made
deterministic by holding the in-memory store's one serial queue (a `DatabaseQueue`) from a detached write until the pin
releases it, which parks the door at its first store trip after the flush — the Mac twin's sleeping-writer technique
without the timing. The hold is always released, even when a pin fails, so a red run cannot hang.

**Row dispositions:** divide · merge · extract · make block — **FIXED** with their pins (red-on-old PENDING the run).
**Insert below — DISMISSED AS HOLLOW** for the stale-write claim (its twin is green on both trees: `newBlock` rewrites no
existing text, so the window's keystroke records A's current text). The fence still covers it by construction (one
latch), which changes where such a key lands — the new block, the Mac's rule — pinned as a behaviour (P-2-5), not
claimed as a fix. **Delete · archive · whole-block delete · cross-block compound** share the latch and are fenced by
construction; traced by reading only (no pin claimed): a keystroke into a block a delete tombstones used to be written
into the tombstoned take, refused, and kept pending forever (`isDirty` stuck, the raw error in the status line).

#### Evidence so far

- Core, headless (no stage): `swift test --filter StructuralFlightFenceTests` — **10 tests in 1 suite passed**.
- Builds, all `** TEST BUILD SUCCEEDED **`, no new warning in a touched file (the one warning in
  `MobileStructural.swift`, `intra` never used in `divide`, is pre-existing and untouched): phone `build-for-testing` of
  the fix (`DerivedData/vm64-b2/`), phone `build-for-testing` of the pins over the base production files
  (`DerivedData/vm64-b2-red/`, built cold), Mac `build-for-testing` (`DerivedData/vm64-b2/`).
- PENDING (the stage window): the green run, the red run, the phone editor suites.

#### The stage window (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Green — the pins and the phone editor suites over the fix:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileStructuralFlightFenceTests MobileStructuralTests MobileSelectionActsTests
  MobileEditorMaterializationTests MobileCanaryTests MobileEditorRoutingTests MobileEditorCrystallizationTests
  MobileEditorProjectionTests MobileTypewriterRoomTests MobileNoteSealTests MobileFindInNoteTests
  MobileEditRoutingBindingTests MobileIdentityAuditSeparatorTests MobileBulkArmingTests MobileCanaryTeardownTests
  MobileEditRoutingCrashTests MobileEditRouteArmsTests MobileWholeBlockDeleteBrainTests MobileWholeBlockDeleteTests
  MobileCrossBlockEditBrainTests MobileCrossBlockEditTests MobileMarkdownRenderTests MobileMarkdownReturnTests
  MobileMarkdownActsTests MobileCheckboxTapTests MobileMarkdownCaretTests MobileTakesTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileTakesChromeTests MobileTakeReorderTests MobileTakeToBlockTests
  MobileTakeLockTests MobileUndoDoorTests MobileBlockMenuTests MobileCommentsTests MobileBlockDecorTests
  MobileWalkTests MobileTrailingNewlinesTests MobileSpaceEaterTests MobileCRLFCaptureTests
  MobileWriteScrollAuthorityTests MobileScrollAuthorityBrainTests MobileLivenessTests
  MobileDeferredProjectionRetryTests MobileTypedOverRescueTests MobileEditTraceTests MobileKeyDoorPostureTests
  MobileSavepointOnLeavingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Red-on-old — the same pins over the BASE production files (expect 8 failing, 2 passing, as tabled above):
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2-red \
  -only-testing:VariorumMobileTests/MobileStructuralFlightFenceTests
```
If `vm64-b2-red` is ever lost, it is rebuilt from the committed tree by: `git checkout 9cf3b3688 --
App/Variorum/VariorumMobile/Features/Write/{MobileStructural,MobileEditorViewModel,MobileEditorTextView}.swift`, the
same `build-for-testing` into `DerivedData/vm64-b2-red`, then `git checkout HEAD --` the same three files (safe against
`f83122794` and every later commit of this batch: no other production file of the fix exists).

Optional, heavier: `MobilePerfWalkTests` (the 100k typing walk — the fence adds one O(1) check per key at
`insertText`; batch 3 runs this suite anyway). Optional ordinary-use smoke on the Debug phone app (signed out, no
Resume): open a note, ⋯ ▸ Divide Block, keep typing at once; ⋯ ▸ Merge with Previous, keep typing; ⋯ ▸ New Block
Below, type — each act lands, the typing follows it, nothing is said. No Mac test run is needed: the only Core change
is a new type no Mac code calls (the Mac build compiles it).

#### PROVISIONAL calls (options weighed; the built one first)

- **P-2-1 — the fence's shape.** (a) **built:** typed keys deferred and replayed (the Mac's R1-2), every other edit
  refused or withheld, either said once; (b) refuse-and-speak everything (the batch's named minimum — drops her typed
  keys with a sentence); (c) defer everything (not honest on iOS: an autocorrection and a composition are bound to
  ranges and to the keyboard's own state, and replaying them against a rewritten page would land them in the wrong
  text).
- **P-2-2 — the sentence after the flight.** (a) **built:** `StructuralUndoCopy.anotherIsLanding`, said as the fence
  drops if anything was refused or withheld, the door's Undo kept beside it — it replaces a WORDED receipt (insert
  below's "New block added below — type away.", delete's and archive's) in that rare case; (b) say it only when the
  status line is empty (leaves a refusal silent on the worded doors); (c) a new sentence naming what was refused (new
  copy — hers).
- **P-2-3 — gate-less edits are always withheld**, even when the flight then commits nothing (a refused divide): (a)
  **built** — simple, never stale, said; (b) release them when no operation committed (needs a commit signal from
  every door and a delivery fence over held bytes; recorded as the road if (a)'s rare drop ever matters).
- **P-2-4 — the settle fails CLOSED.** (a) **built:** if three re-reads cannot settle the page, keys keep waiting
  until the next projection applies (in production the live observation delivers after every write); (b) fail open
  after N re-reads (an editor never looks frozen, but a key could again build on a page that has not settled).
- **P-2-5 — insert below's keys land in the new block** (the Mac's rule for its own ⌘⇧⏎ flight; the door's receipt
  says "type away"): (a) **built** — the one latch fences every door alike; (b) exempt insert below from the fence
  (its keys would keep going into the block above, the pre-fix placement).
- **P-2-6 — a held ⏎ replays whole**, so its list continuation is decided at the replay against the settled page (the
  Mac's replayed ⏎ "claims and chains exactly as a typed one").

#### Residuals and follow-ups (traced, not fixed here — owners for the orchestrator to assign)

1. **The structural UNDO door** (`MobileUndoDoor.undo` / `redo`, its own `inFlight` latch: flush → `stack.undo` on the
   runner → `refreshTakesFromStore`) has the same window — a keystroke while an undo of a divide lands records the
   pre-undo block text. A sibling door outside this batch's named unit; with the fence in place the fix is one more
   latch hook (both latches must be down before the fence lands). Proposed owner: a rider on wave 3's Writing
   umbrella or a VM ticket.
2. **The leading-run attachment mid-flight** (`TailCrystallizer.attachLeadingTailRunIfNeeded`): if the tail's idle
   clock fires while a divide or merge of the note's LAST block is landing, it records that block's ledger text + the
   newline run — the old text. Not a keystroke in the window (an earlier keystroke's timer), so outside this unit.
   Holding the tail for the fence (the Mac's `holdsTailForStructuralFlight: structuralInFlight`) was weighed and
   REJECTED here: `finish()`'s backstop mint goes through the same hold, so a teardown that lands mid-flight would skip
   it and lose the open tail. Proposed owner: the same Writing umbrella, with a pin.
3. **A pop in the same instant as a flight** (SwiftUI may release the text view concurrently with `onDisappear`): keys
   held at that moment have no caret to replay at and go with the view — the Mac's stash has the same lifetime.
4. **The phone's own walk of the window** cannot be made by hand; the device's autocorrect / dictation / composition
   behaviour under the fence is reasoned from M25 and the pins' three roads, not seen on her phone. MobileSoul §5.2's
   standing obligation ("any new editor behavior must pass the autocorrect/dictation test on device") rides her
   wave-1 install sitting.

#### The Mac does not change (review focus 8)

No `Shared/` file changed. The one Core addition is a new type no Mac code references; the Mac test build compiles it.
`runStructural`, `EditorTextView` and every Mac editor seam are byte-untouched.

#### For QUESTIONS at the merge (the orchestrator carries these to `notes/QUESTIONS.md`)

1. **P-2-1 — the fence's shape** on the phone: defer typed keys + refuse/withhold the rest, said once (built) · refuse
   and say everything · defer everything.
2. **P-2-2 — the after-flight sentence** replacing a worded receipt when something was refused (built) · only when the
   status line is empty · a new sentence (her wording).
3. **P-2-3 — a composition commit or dictation inside the window is withheld and said** (built) · released when the
   flight commits nothing.
4. **P-2-5 — insert below's keys land in the new block** (built, the Mac's rule) · exempt insert below.

#### Iteration r1 — after the first stage window (2026-11-19; the window's facts are the orchestrator's §5 block)

**What the first window FALSIFIED in this closeout (kept above as written, corrected here):**
- "So the red run expects 8 failing, 2 passing; the green run expects 10 passing" — FALSE. Pre-fix: 7 failed by
  assertion, 1 passed, 2 killed the host. Fix: 5 passed, 5 killed the host. Every kill was the DEBUG desync trap from
  `storageDidEdit`'s `.refuse` arm.
- Road C's red-on-old shape ("the same store, a conflict take…") — FALSE: the probe's own write trapped on BOTH trees.
- `afterTheFlightLandsTypingIsOrdinaryAgain` "GREEN on both (a guard)" — FALSE: it trapped on both trees.
- The evidence lines "the pins … green run PENDING" stand as PENDING; nothing was claimed green.

**The diagnosis (traced from the six crash reports, the two logs and the code; §5 "Iteration r1" carries it in full).**
One road under all six: an edit whose report did not bind to a gate arming, routed by `fallbackVerdict`, whose span
crossed a separator → `.refuse` → `desyncRecovery` → the trap.
- Road C (divide): the PROBE's write — a font-only insert at a non-last block's end, widened through the paragraph's
  terminator by iOS's paragraph-style fixing (round 2's M12). The fence's belt is never reached (it sits in the
  `.block(i)` arm). The merge pin's identical write in the last block routed on both trees, which is the control.
- The four UIKit `insertText` traps (the guard on both trees; the divide / extract / make-block replays on the fix):
  all at the START of a non-empty, non-last block — the caret those three doors land. The fence's logic is not on the
  road; its replay uses the same `insertText` the guard uses on the pre-fix tree. Why the arming did not bind there is
  NOT settled by reading; the recorded candidate is VM-19's posture class (the pins typed into a text view in no window
  at all, never the key window's first responder).

**What r1 changed (test-only — no product line moved):** the pins type in her posture (the foreground scene's key
window, the text view first responder, leftovers resigned; `.serialized`); a debug assertion inside a pin is RECORDED
AS A FAILING ISSUE (task-scoped `EditorAssertionSeam` handler) — never swallowed, so a desync still fails its pin and
the host survives; road C's divide pin seeds one block so its gate-less write lands where it routes; and
`MobileFlightFenceProbeTests` (DIAGNOSTIC, asserts nothing) prints `VM2-PROBE` lines from an armed E1 trace for a UIKit
insert at a block start — with and without a divide before it, in both postures, and with the caret moved away and
back.

**What r1's cycle should show, and what each outcome means:**

| Build | If the posture was the cause | If the block-start insert is unroutable in her posture too |
|---|---|---|
| fix `vm64-b2r1` | 10 of 10 pins pass | road-A divide · extract · make block and the guard FAIL with a recorded desync issue (no host kill); the other 6 pass |
| pre-fix `vm64-b2r1-red` | 8 fail by assertion (A ×4 doors, B, C ×2, insert-below parity); `insertBelowTwin` and the guard pass | the same 8 fail, plus the guard fails with a recorded desync; `insertBelowTwin` passes |
| `VM2-PROBE` lines | p2/p5/p7 (keyed): `rejected=0 desyncs=0` | p5 (keyed, after a divide): `desyncs=1` — then it is round 2's M27, pre-existing, and r2 moves the replay off this road with its own red-on-old |

**r1's stage commands** (the orchestrator's short claim; the fence suite and the diagnostic only):
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileStructuralFlightFenceTests MobileFlightFenceProbeTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2r1 \
  ${tests/#/-only-testing:VariorumMobileTests/}
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2r1-red \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Then `grep VM2-PROBE` over each log. Products: `vm64-b2r1` built at `05ca99e0d` (the fix + r1's tests);
`vm64-b2r1-red` = r1's tests over the base's three phone production files (cold; restored after, tree clean). The first
window's `vm64-b2`, `vm64-b2-red` are superseded (the orchestrator deletes them).

#### Iteration r1 → r2 — the trace the orchestrator asked for (2026-11-19, after the r1 cycle and the 49-type run)

Evidence read for this section (all local, gitignored): `notes/plans/vm64-screens/b2r1-fix.log` and `b2r1-red.log` (the
r1 cycle: the fence suite + the diagnostic, one host each) and `b2r1-49.log` (the 49 types from `vm64-b2r1`, one host,
where the fence suite ran AFTER 34 other suites — the block menu, the editor and routing suites, VM-8 unit 2, liveness,
the caret suite, the markdown suites, savepoint on leaving, the space-eater — and four fence pins went red with a
recorded desync); her device's E1 readout (`notes/author-reports/2026-08-23-device-walk-and-product-asks.md`).

**The one fact that decides it: a programmatic `UITextView.insertText(_:)` NEVER consults the editor's gate.** Every
`VM2-PROBE` summary line, p1–p7, both builds, both postures — including p2, p5, p7 with `firstResponder=true` in the
foreground scene's key window — reads `consults=0 … gateless=1`, and the one event is `EDIT at 12 len 1 Δ+1 after 0
gates ⚠ gate-less`. So the probes did NOT measure the road I meant them to; neither did any typed-key road in these pins
(`textView.insertText` / `textView.deleteBackward` — M25 had measured the last two; `insertText` is the third). Every
UIKit insert in the pins took the GATE-LESS road: no arming, routed by `fallbackVerdict` from the storage report alone.
Her keyboard is different — her device trace shows a consult before every typed key (`#10 GATE at 129 len 0 repl 1 →
armed` · `#11 EDIT at 129 len 1 Δ+1 after 4 gates`; autocorrect too: `#28 GATE at 134 len 5 repl 5 → armed`). Since the
public `insertText` does not consult even as first responder, the keyboard consults through its own entry BEFORE it
calls `insertText`, and inserts only on a yes.

**1 · Why the guard desyncs on the old code in the key-window posture while probe p5 does not.** Both are gate-less
programmatic inserts at the minted block's start, routed by the report alone; a gate-less report routes only if it stays
inside one entry. At a non-last block's start, a report widened forward through the paragraph's terminator crosses the
separator and refuses (TEXTKIT2 §3's iOS fixing; the same shape as M12). The concrete difference between the two tests'
states at the insert: **p5 reads the text view's selection (`view.selectedRange`) between the door's return and the
insert; the old-code guard reads nothing.** Nothing else differs on the road — the door left no deferred projection, no
forced render and no arming in either (the door's own settle applied; no gate was consulted to arm). The fix build's
guard passed in the r1 cycle for the matching reason: `MobileEditorTextView.insertText` reads `textView.markedTextRange`
(inside `deferTypedInputDuringFlight`) before `super.insertText`. What such a read synchronises inside UIKit (the
selection and typing state after a whole-storage replacement plus a programmatic caret write) is INFERRED, not observed;
what is measured is that the report's width — and so whether a gate-less insert routes — depends on that state. The
49-type run proves it is state left in the host process: the same four pins, green with only the probe suite beside
them, went red after 34 earlier suites (`b2r1-49.log`: the divide pin's three recorded assertions are its replayed X, Y
and ⌫ each refusing). Which suite's leftover flips it is NOT isolated — and r2 does not need it isolated, because r2
leaves no gate-less insert anywhere a separator can be crossed (below).

**2 · Why the fix build "no longer desyncs" in the guard, and what the old code does to HER.** The r1 claim is FALSE as
stated: no line of the fence's landing or settle makes the page hold anything the old code's page did not — the door's
own settle had already applied on both trees. The fix build's guard routed in the r1 cycle only because of the
incidental `markedTextRange` read, and it failed in the 49 run. **What the old code does to her: nothing on this road.**
Her keys are consulted first, the arming binds (`ArmedEdit.describes` takes a report that starts at the approved
location however far it widens forward — and her device reports a typed key as `len 1` anyway), and the key routes. The
desync needs a CONSULT-LESS programmatic insert right after a structural render, which no production road performs on
the pre-fix tree (the bar's acts, Tab and the ⏎ door all pre-gate through `MobileMarkdownActs.gateAllows`). **So this is
not a second product defect the fence fixes, and the guard is not a red-on-old product pin** — it measured the test road.
Round 2's M27 ("the first typed edit after a divide is unroutable") is very probably this same test-road phenomenon (its
record carries the symptom only; round 2's pins typed through programmatic `insertText`). VM-5's "DISSOLVED" was measured
on a CONSULTED road (`typeEdit`), where it cannot occur — so for her keyboard road it stands; its wider wording ("no road
through the shared brain reproduces the symptom") is contradicted for the consult-less road (the r1 red build's guard).

**3 · The first window's six traps, restated honestly** (the six stacks stay quoted in §5):
- `aGatelessEditDuringADivideIsWithheld…` (both trees) — the PROBE's write (a font-only insert at a non-last block's
  end; M12's shape). r1's fix (one block) holds: green on the fix, red by assertion on the old code, in both r1 runs.
- `afterTheFlightLandsTypingIsOrdinaryAgain` (both trees) — the consult-less TEST road (programmatic `insertText` right
  after a divide's render), width-dependent; not a product defect on her road (2 above).
- `keysTypedWhileADivideLands…`, `aKeyTypedWhileAnExtractLands…`, `aKeyTypedWhileMakeBlockLands…` (fix build) — the
  FENCE's replay, which is a consult-less programmatic `insertText` at the landed caret: unpoliced (the gate's belts never
  see a replayed key) and width-dependent (state-dependent: red unmounted in window 1, green keyed alone at 06:32, red
  keyed after 34 suites at 06:57). A real weakness of r1's replay — but one her keyboard can never reach, because on her
  phone the stash never holds a key (below).
- "Posture" was NOT the cure (r1's §5 hypothesis is falsified): keyed, the same pins went red in company.

**What this means for the fence's design (the correction that matters most).** On her phone, a key typed during a
flight is consulted by the keyboard BEFORE `insertText`; r1's gate belt refuses it; the keyboard therefore never calls
`insertText`; the override's stash never sees it. **r1 on her phone is already refuse-and-say for every typed key** — the
"typed keys deferred and replayed, never dropped" claim (P-2-1 (a), the closeout's input table) is FALSE for her
keyboard: it held only for consult-less programmatic inserts, which only the tests make. Deferral cannot be moved to the
gate honestly: a consult does not promise an edit (her own trace shows consults with none following — "most gate calls
before one edit: 4"; round 2's crash trace lists speculative consults as unknown), so stashing at the gate risks
replaying text she never typed. The batch section's named minimum — refuse and say — is what the phone can honestly do.

**4 · The corrected red-on-old table (r1's red build, one host, no trap):** NINE red — the eight predicted plus the
guard. Dispositions as r1 stands: the eight are red-on-old pins of the stale write per door (divide ×3 roads, merge ×2,
extract, make block) and of insert-below's landing change; **the guard's red is the test road, not a product red** (its
"green on both" claim fails because its typed key is consult-less); `insertBelowTwin…` green on both (HOLLOW, as
recorded).

**5 · `MobileFlightFenceProbeTests`:** to be DELETED in r2. What it established — `insertText` called programmatically
never consults the gate, in either posture — is a platform fact for TEXTKIT2 §3 beside M25 (routed at closeout), and r2's
pins no longer depend on it; nothing in it is red on old where the old code is wrong, so there is no pin to keep.

**PROPOSED r2 — NOT BUILT; the orchestrator asked to be told before any product change.** No file changed in this pass
but this record, so `vm64-b2r1` is the last product — and it should NOT be the final run's product: its four replay /
guard pins are state-dependent, as the 49 run showed.
- **Product (editor seam), a REMOVAL:** take out the input stash and the replay — the `insertText` fence check and the
  `deleteBackward` override in `MobileEditorTextView` (with `replayDeferredDeleteBackward`), the model's
  `deferTypedInputDuringFlight` and the drain's replay loop; the brain loses `Input`, `offer`, `deferred` and
  `Drain.replay` (its headless tests rewritten). KEPT unchanged: the gate belt (refuse, said once as the fence drops), the
  storage belt (withhold a gate-less block edit, force the re-read), the settle (the fence stays up until the page holds
  the store), the `flushPendingText` re-read. On her phone this changes nothing (keys were already refused at the gate);
  it removes a mechanism that only tests could reach and whose pins were pins over nothing reachable. No red-on-r1 pin
  exists for a removal of an unreachable road — said, not hidden.
- **Insert below (P-2-5, re-weighed under refuse-and-say):** (a) keep it fenced like every door (keys typed during its
  flight refused and said); (b) EXEMPT it — its row is hollow (`newBlock` rewrites no text; the window's key records the
  block's current text, never stale), so refusing there drops her key for no data reason; one line in that door tells the
  latch not to raise the fence. Recommended: (b). Hers at the merge either way.
- **Pins:** every typed-key pin drives HER road — the text view's delegate consult, then the insert only on a yes (M25's
  prescription; on the old code the consult arms and the insert binds, so the old code's stale write reproduces
  deterministically; on the fix the consult refuses and nothing lands) — for divide (X, Y, ⌫), merge, extract and make
  block; road B and both road-C pins as they are; the insert-below twin on the keyboard road (and, under (b), a guard
  that the key lands in the block it was typed in, green on both); the guard `afterTheFlightLands…` on the keyboard road
  (green on both — a true guard that the fence is down after a landing); the probe suite deleted. No gate-less insert is
  left in any pin except road C's, which lands in the last block where no separator can be crossed — so every pin is
  deterministic by construction, whatever an earlier suite leaves in the host.
- **Builds:** `DerivedData/vm64-b2r2/` (the fix) and `vm64-b2r2-red/` (r2's pins over the base's three phone files),
  fresh, frozen; the revert announced first. Expected on the red build: the per-door pins red by assertion (divide ×3,
  merge ×2, extract, make block), the twin, the guard and (under (b)) the insert-below guard green. Expected on the fix:
  all green, alone and in company — the cycle to prove "in company" is the fence suite run AFTER the caret, liveness and
  markdown suites from `vm64-b2r2` (the 49-type list does that).
- **If the orchestrator prefers moving the replay instead of removing it** (pre-gating each replayed key through
  `inputReplace`, which makes it policed and binding-deterministic): that is buildable too, but it keeps a mechanism her
  keyboard never reaches; I would not recommend it.

**For the orchestrator (findings, not edits to other records):**
1. **M27 / the VM-5 record:** the symptom ("the first key after a divide unroutable") reproduces on the pre-fix tree on
   the CONSULT-LESS programmatic `insertText` road (the r1 red build's guard, keyed posture); it does not reach her
   keyboard road, which is consulted and binds. VM-5's DISSOLVED verdict holds for the road she types on; its claim that
   no road reproduces the symptom does not. Not a product defect to fix — a test-road trap for any pin that types through
   programmatic `insertText` after a render.
2. **TEXTKIT2 §3, beside M25 (at closeout):** `UITextView.insertText(_:)` called programmatically never consults the
   delegate — measured on iOS 26.2 (simulator), in no window and as the key window's first responder alike — and its
   report's width after a whole-storage replacement depends on process state; a pin that types through it routes by
   `fallbackVerdict` alone.
3. **The fence's real shape on her phone is refuse-and-say** (P-2-1 (b)); the closeout's P-2-1 and input table above it
   are corrected by this section and stay as written above it.

#### Iteration r2 — refuse and say (APPROVED by the orchestrator, 2026-11-19; built at `2a3fd3a52`)

**The orchestrator's calls, recorded as such (against the batch section):**
1. *The fence's shape on the phone is refuse-and-say* (P-2-1 → option (b), PROVISIONAL as before): the gate belt refuses
   a typed key while a flight is landing and the one existing sentence is said once as the fence drops; the storage belt
   withholds an edit that skipped the gate and re-reads the page; the settle and the `flushPendingText` re-read stay.
   The hold-and-replay mechanism is removed whole. The batch section asked for "the shape that never drops her keystroke
   IF it can be made honest on the phone's async road"; the trace shows it cannot — **her keyboard asks the gate BEFORE
   it inserts** (her device's E1 trace, `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`: `#10 GATE at
   129 len 0 repl 1 → armed` · `#11 EDIT at 129 len 1 Δ+1 after 4 gates`, a consult before every typed key and before
   the autocorrection `#28 GATE at 134 len 5 repl 5`), so a key typed during a flight is refused at the gate and never
   reaches `insertText`; and **a consult does not promise an edit** (the same trace: "most gate calls before one edit:
   4"), so holding keys at the gate would risk replaying text she never typed. The honest shape is the refusal that
   speaks.
2. *Insert Below is EXEMPT* (P-2-5 re-ruled, PROVISIONAL, hers at the merge — the alternative, fencing it like every
   door, written out below): its row is hollow, and this batch's unit is the store defect, so the door keeps its old
   behaviour and gains no new refusal.
3. *The structural undo door is inside the unit* if the window is the same and the fix is the latch hook alone. It is:
   `beginUndo` / `confirmPendingUndo` / `redo` hold `inFlight` across flush → the inverse on the runner →
   `refreshTakesFromStore`, the structural doors' exact window. The fix is the latch hook plus one composition rule (the
   fence lands only when NO fencing latch is up, so an undo inside a divide's flight, or the reverse, never drops the
   other's fence) — no new mechanism.
4. *Every typed-key pin drives her real road* (the delegate consult, then the insert only on a yes), deterministic in
   company; the red-on-old table honest; `MobileFlightFenceProbeTests` deleted.
5. *The canon line* in TEXTKIT2 §3 (landed at `9b1451cad`).
6. *Kept as written:* the M27 / VM-5 finding and "the first window's six traps, restated" (the section above).

**What shipped in r2, file by file** (on top of r1's `05ca99e0d`):
- `Sources/VariorumCore/Domain/StructuralFlightFence.swift` — the input queue is gone (`Input`, `offer`, `deferred`,
  `Drain.replay`); `drain()` now answers only whether the sentence is owed. The header carries refuse-and-say and its
  evidence. `Tests/VariorumCoreTests/StructuralFlightFenceTests.swift` — rewritten, 8 tests (headless, green).
- `MobileEditorTextView.swift` — back to the pre-batch `insertText` (no fence check); the `deleteBackward` override and
  `replayDeferredDeleteBackward` removed. **This file's diff against the base is now empty.**
- `MobileEditorViewModel.swift` — `deferTypedInputDuringFlight` and the drain's replay loop removed;
  `structuralFlightChanged()` (no argument) is called on EVERY edge of either door's latch: the fence flies while
  `structural.holdsFencingFlight || undoDoor.inFlight`, and lands only when neither holds (an exempt door's edges, or a
  fence already settling, pass by). The gate belt, the storage belt, the settle, the drain's one sentence and the
  `flushPendingText` re-read are unchanged in behaviour (comments now say refuse-and-say).
- `MobileStructural.swift` — the latch's `didSet` calls `structuralFlightChanged()`; `flightFencesTyping` (true but for
  insert below) and `holdsFencingFlight`; `insertBlockBelow` sets the exemption around its own flight (one line in, one
  in its `defer`).
- `MobileUndoDoor.swift` — its `inFlight` latch gains the same `didSet` hook.
- `VariorumMobileTests/MobileStructuralFlightFenceTests.swift` — rewritten (below); `MobileFlightFenceProbeTests.swift`
  deleted.
- `notes/TEXTKIT2_NOTES.md` §3 — the measured `insertText` finding and its rule.

**What each input gets during a structural flight now** (supersedes the r0 table above, which is kept as written):

| Input | Road | Under the fence |
|---|---|---|
| A typed character, ⏎, ⌫ (software or hardware keyboard) | the keyboard asks the gate first | **refused**, said once as the fence drops |
| An autocorrection, a predictive pick | the keyboard asks the gate first | **refused** (her typed word stays as typed), said |
| Paste, a formatting-bar act, Tab, an edit-menu act | the gate (UIKit's consult or the act's pre-gate) | **refused**, said |
| Dictation's progressive inserts, a composition update | no gate consult | **withheld** — tiling kept, nothing written, the page re-read; said |
| Dictation's final commit | the gate (her trace `#46`) | **refused**, said |
| A key typed after the latch falls but before a deferred settle lands | the gate | still **refused** (the fence stays up until the page holds the store) |
| Anything during **Insert Below** | as ever | **unfenced** — lands where typed, never stale (the exemption) |

What is dropped, and how she knows: a key, autocorrection or dictation chunk that meets a landing flight is not
written; the sentence "Another structural change is still landing." stands in the status line after the flight (with
the door's Undo/Redo kept beside it). Nothing reaches the store stale; nothing leaves silently. *[Ladder round 2,
finding 6 — both clauses over-claim on the merged tree. Since VM-55's one message line the sentence is a REFUSAL on
that line, drawn with no Undo (`MobileLine.say` takes back the note's standing Undo line first); the door's Undo stays
in the note's ⋯ sheet — "P-2-2 meets the one message line", the merge-in closeout's QUESTIONS item. And "nothing reaches
the store stale" is the fence's claim for what it refuses or withholds only: VM-226 (the tail's idle save mid-flight)
and round 2's finding 2 (the settle read in flight) are open roads.]*

**The pins (r2), and the corrected red-on-old table** — PENDING the stage; expected:

| Pin | Road · door | Fix (`vm64-b2r2`) | Pre-fix (`vm64-b2r2-red`) | Kind |
|---|---|---|---|---|
| `keysTypedWhileADivideLandsAreRefusedAndSaid` (THE PIN) | keyboard (X, Y, ⌫) · divide | green | RED: `["Alpha beta. XGamma delta.", "Gamma delta.", …]`, a conflict take, no sentence | product |
| `anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid` | B · divide | green | RED: `["Alpha beta. Gamma delta.X", …]`, a conflict take, no sentence | product |
| `aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore` | C (last block) · divide | green | RED: `["Alpha beta. Gamma delta.X", "Gamma delta."]`, a conflict take, the page, no sentence | product |
| `aKeyTypedWhileAMergeLandsNeverLandsInAReleasedSource` | keyboard · merge | green | RED: `markerInUnplacedTakes == 1`, no sentence | product |
| `aGatelessEditDuringAMergeNeverLandsInAReleasedSource` | C (last block) · merge | green | RED: `markerInUnplacedTakes == 1`, no sentence | product |
| `aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan` | keyboard · extract | green | RED: the span twice, a conflict take, no sentence | product |
| `aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource` | keyboard · make block | green | RED: the whole source + X, a conflict take, no sentence | product |
| `aKeyTypedWhileAnUndoLandsIsRefusedAndTheUndoLandsWhole` | keyboard · the undo door (of a divide) | green | RED: `["Alpha beta.X", …]` (the undo reversed), a conflict take, `"Undid: …"` not the sentence | product (the undo door's red-on-old) |
| `aKeyTypedWhileInsertBelowLandsIsNeitherLostNorDuplicated` | keyboard · insert below | green | GREEN | guard of the exemption (the row is HOLLOW) |
| `afterTheFlightLandsTypingIsOrdinaryAgain` | keyboard · after a divide | green | GREEN | guard (the fence is down after a landing) |

**8 product reds on the pre-fix tree, 2 guards green on both; 10 green on the fix — alone and in company.** No pin holds
a gate-less insert whose report can cross a separator: every typed key is armed before it lands (the binding takes a
report widened forward from the approved location), and road C writes into the LAST block. That is why these are
deterministic whatever an earlier suite leaves in the host — the property r1's pins lacked.

**Row dispositions (final shape):** divide · merge · extract · make block — FIXED, red-on-old pins above. **The
structural undo door** — FIXED in this batch (the orchestrator's call 3), its red-on-old pin above. Delete · archive ·
whole-block delete · the cross-block compound — fenced by construction (one latch), traced by reading, no pin claimed.
**Insert below — DISMISSED AS HOLLOW** for the stale-write claim and EXEMPT from the fence (call 2), its guard above.
M27 — not a product defect on her road (the finding above, kept as written).

**PROVISIONAL calls, as they stand after r2** (the r0 list above is kept as written; these supersede it):
- **P-2-1 — refuse and say** (the orchestrator's call 1): built. Weighed and not built: hold-and-replay (dishonest on the
  phone's keyboard road, above); holding keys at the gate (a consult does not promise an edit).
- **P-2-2 — the after-flight sentence** replaces a WORDED receipt when something was refused (the undo door's "Undid: …",
  delete's, archive's) and keeps the door's action: built. Alternatives: say it only when the status line is empty; a
  new sentence naming what was refused (her wording).
- **P-2-3 — a gate-less edit inside the window is always withheld and said**: built. Alternative: release it when the
  flight commits nothing.
- **P-2-4 — the settle fails CLOSED**: built. Alternative: fail open after N re-reads.
- **P-2-5 — Insert Below exempt** (call 2): built. Alternative: fence it like every door (a key typed in its window
  refused and said, for no data reason).
- P-2-6 (a held ⏎ replays whole) is MOOT — nothing is held.

**Residuals after r2:** (1) the undo door — CLOSED by call 3. (2) the leading-run attachment mid-flight
(`TailCrystallizer.attachLeadingTailRunIfNeeded`, a timer's write, not a keystroke) — unchanged, outside the unit,
proposed owner the Writing umbrella. (3) a pop in the same instant as a flight — MOOT (nothing is held). (4) the
device's autocorrect / dictation behaviour under the fence is reasoned from her own E1 trace and the pins' roads, not
seen live — rides her wave-1 install sitting (MobileSoul §5.2).

**The Mac does not change:** the only Core change is the fence brain, which no Mac code calls; the Mac
`build-for-testing` compiles it (P-r2-6). No `Shared/` file changed.

**r2's stage commands** (the orchestrator's short claims; `<simulator-udid>` from the GO):
(i) the fence suite alone, on each build:
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2r2 \
  -only-testing:VariorumMobileTests/MobileStructuralFlightFenceTests
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2r2-red \
  -only-testing:VariorumMobileTests/MobileStructuralFlightFenceTests
```
Expected: fix 10/10 green; pre-fix 8 red by assertion (the product rows), 2 green (the guards), one host each, no trap.
(ii) the 49-type list from `vm64-b2r2`, ONE invocation:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileStructuralFlightFenceTests MobileStructuralTests MobileSelectionActsTests
  MobileEditorMaterializationTests MobileCanaryTests MobileEditorRoutingTests MobileEditorCrystallizationTests
  MobileEditorProjectionTests MobileTypewriterRoomTests MobileNoteSealTests MobileFindInNoteTests
  MobileEditRoutingBindingTests MobileIdentityAuditSeparatorTests MobileBulkArmingTests MobileCanaryTeardownTests
  MobileEditRoutingCrashTests MobileEditRouteArmsTests MobileWholeBlockDeleteBrainTests MobileWholeBlockDeleteTests
  MobileCrossBlockEditBrainTests MobileCrossBlockEditTests MobileMarkdownRenderTests MobileMarkdownReturnTests
  MobileMarkdownActsTests MobileCheckboxTapTests MobileMarkdownCaretTests MobileTakesTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileTakesChromeTests MobileTakeReorderTests MobileTakeToBlockTests
  MobileTakeLockTests MobileUndoDoorTests MobileBlockMenuTests MobileCommentsTests MobileBlockDecorTests
  MobileWalkTests MobileTrailingNewlinesTests MobileSpaceEaterTests MobileCRLFCaptureTests
  MobileWriteScrollAuthorityTests MobileScrollAuthorityBrainTests MobileLivenessTests
  MobileDeferredProjectionRetryTests MobileTypedOverRescueTests MobileEditTraceTests MobileKeyDoorPostureTests
  MobileSavepointOnLeavingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b2r2 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Expected: one host process; the fence suite whole-green in company; `MobileUndoDoorTests` green (its latch now raises
the fence — no existing pin types during an undo); VM-24's caret test the only red, in main's shape.

**For QUESTIONS at the merge (supersedes the r0 list above):**
1. **P-2-1 — refuse and say** on the phone (the orchestrator's call) · hold-and-replay (not honest on the keyboard road).
2. **P-2-2 — the after-flight sentence** replacing a worded receipt · only when the line is empty · a new sentence.
3. **P-2-3 — a gate-less edit in the window withheld and said** · released when the flight commits nothing.
4. **P-2-5 — Insert Below exempt** · fenced like every door.

### Batch 3 · VM-66 — the speed tests run her paths (implementer closeout)

**Not done in this batch (first, by the record's rule):** the stage runs are PENDING the orchestrator's window — so the
BEFORE numbers in §5 are not yet filled, and the new suite and the fixture pins have not yet run (their commands are
below, runnable by anyone from my built products). No simulator walk of the app: this batch's unit is the test suite
itself, whose two stage runs ARE its use-shaped evidence (the real screen and the real shell, driven). No fix of any
kind; no new duration budget (P-66-4); no Core, `Shared/` or `Sync/` line; nothing on her phone.

**Base:** `ba3516a30`. **Commits:** `3cb346ebb` (live status) · `fd9184011` (the nine-wing fixture, its pin, the
launch-path doc) · `0bc11d9a9` (the suite) · `51440c726` (two compile fixes) · `284e30c9e` (live status) ·
`21fc776fb` (the shelf suite's pointer) · `d2cef56be` (the Library row found by its title's prefix) · this closeout.

#### What shipped, file by file

- `App/Variorum/VariorumMobile/Features/Perf/MobilePerfFixtureSeeder.swift` — the seeder gains `WingShape`
  (`.oneWing`, the default, byte-identical: the corpus loop's body was lifted unchanged into `seedCorpusBody`, so the
  same operations run in the same order and a `.incrementing` world mints the same ids; `.nineWings`, the new option).
  **What `.nineWings` seeds per wing** (Home plus eight minted wings, `extraWingNames`): its own `perf fixture` tag (a
  legal per-wing twin; Home's is the caller's) worn by every note in it · a `gathered` tag worn by every third note ·
  TWO books (`"<wing> notebook i"` / `"… ii"`) · ONE gathering (`"<wing> gathered"`, rule: that wing's `gathered`
  tag) · its share of the corpus notes dealt round-robin (note n → wing n % 9; each note's prose is the same generator
  stream as in `.oneWing`), every fourth of them BOOKLESS (a Pool note — some of those gathered, so the Pool's
  gathering test has rows to exclude). The fixture book and its control (and mega, when asked) posts stay in Home.
  `SeedResult` gains the shape's facts (`wingCount`, `wingIDs`, `corpusBookCount`, `gatheringCount`,
  `booklessNoteCount`, `gatheredNoteCount`). The DEBUG door (`findOrSeed`) is untouched and seeds the one-wing shape.
- `App/Variorum/VariorumMobileTests/MobilePerfWalkTests.swift` — `PerfWorlds.nineWings` (450 corpus notes, 50 per
  wing, the control post, no mega — PROVISIONAL P-66-2); the shape pin
  `MobilePerfFixtureTests.theNineWingShapeSeedsEachWingItsOwnLibrary` (per wing: 50 notes, 12 bookless, 2 books, 1
  gathering, 1 fixture-tag twin, 17 gathered; the control post in Home); **the stale `MobileLaunchPathTests` doc
  corrected in place** (the open left the main thread at 13l L-c — `AppBootstrap.beginOpening` → the detached
  `routeAndOpen`; the measurement stays, the P2 claim goes; its `PERF[sim]` label and two comments follow); a pointer
  on `openSurface` (the windowless editor's open stays what the budgets were derived on; the open she feels is the
  new suite). No budget changed; no existing pin's assertion changed.
- `App/Variorum/VariorumMobileTests/MobileShelfPerfTests.swift` — header only: the box's Library-wakes leg is counted
  in the new suite, and why it lives there.
- `App/Variorum/VariorumMobileTests/MobileHerPathsPerfTests.swift` — **the new suite** (`.serialized`, nine tests),
  reading VM-65's layer off `AppTiming.recorder`; each test on its own on-disk copy of
  a static world (`DiskWorld`: `backup(to:)` → `openStore(at:)`, whose migration encrypts it — a WAL pool like her
  phone's store); the real screen and the real shell mounted in a key window behind a `MountGate` (the bootstrap's
  `.ready` → `.opening` flip, as a view: removing the content fires every mounted screen's `onDisappear` exactly as
  the app's state flip does); one `VM64-PERF|…` line per series.

#### The series (what each one reads, and who tightens it)

| Test | Series | Source | World | Asserted? |
|---|---|---|---|---|
| `aNoteOpensOnTheRealScreenWithItsLiveUpdatesStarted` | `note-open-to-screen-{short,100k}` | layer span `noteOpenToScreen` (screen built → text on screen) | big (on-disk copy) | no (probe only) |
| | `note-open-to-live-{short,100k}` | TEST clock: screen built → the first live delivery INGESTED | big | no |
| | `note-reads-per-open-{short,100k}` | layer window `noteReadsPerOpen` | big | ≥ 1 only; the value RECORDED for batch 6 (2 → 1) |
| `theCaptureBoxOpensItsNoteThroughTheShellsPush` | `shell-box-open-to-note` | layer span `boxOpenToNote` — the whole of lag 2 | nine wings | no |
| | `shell-box-file` | layer span `boxFile` | nine wings | no |
| | `shell-box-open-to-live` | TEST clock: Open → the first live delivery ingested | nine wings | no |
| | `shell-box-editor-builds-per-open` | layer counters `editorBuilt` ÷ `noteArrival` across the push | nine wings | ≥ 1 only; RECORDED (audit F 2D's twins — batch 6 settles) |
| | `shell-box-note-reads-per-open` | layer window | nine wings | RECORDED (batch 6) |
| `aLibraryRowOpensItsNoteThroughTheShellsPush` | `shell-library-open-to-screen-{short,100k}` | layer span `noteOpenToScreen` via the row's push | big | no |
| | `shell-library-editor-builds-per-open-{short,100k}` · `shell-library-note-reads-per-open-{short,100k}` | layer counters / window | big | RECORDED (batch 6) |
| `typingInTheBoxWakesTheOffScreenLibrary` | `library-rereads-per-box-save` · `library-redraws-per-box-save` | layer windows (both held listings) | nine wings | RECORDED (batch 5) |
| | `all-listing-rereads-per-box-save` · `bookless-rereads-per-box-save` | layer counters `libraryFetch` / `booklessFetch` per save | nine wings | RECORDED (batch 5) |
| | `library-listing-fetch-ninewings` · `bookless-listing-fetch-ninewings` | TEST clock around `Queries.library` / `Queries.poolPosts` (limit 200) — the very queries the held listings re-run | nine wings | no |
| `ownerAdoptionWithNothingToAdoptIsMeasuredAtFixtureScale` | `owner-adoption-nothing-to-adopt` | layer span `ownerAdoption` | big | RECORDED (batch 4) |
| | `owner-adoption-rows-nothing-to-adopt` | layer series `ownerAdoptionRows` | big | **ASSERTED 0** (the op's idempotence contract) |
| `leavingAnEditedNoteCountsItsSavepointAttempts` | `savepoints-per-note-leaving` | layer window `savepointsPerLeaving` from the screen's `onDisappear` | small | **ASSERTED ≥ 1** (an edited note's leaving is savepointed — PR7); the value RECORDED (batch 7) |
| `backgroundingWithAnEditedNoteOpenCountsItsSavepointAttempts` | `savepoints-per-backgrounding-{standard,castle}` | layer window from `MobileTiming.appLeaving()`, then `mobileScenePhaseChanged(.background, …)` — the app's own two calls | small | **ASSERTED ≥ 1**; the value RECORDED (batch 7: audit F 6C's three → one) |
| `theAutosaveRegistryAcrossOpensAndCloses` | `autosave-registry-growth-per-open-close` | `AppSession.openAutosaveCount` before/after each open-and-close of a different note (+ a `PERF[sim]` line with the size after five) | small | RECORDED (batch 6: 1 → 0) |
| `oneTypingPauseInTheHundredKNoteIsMeasured` | `note-rereads-per-save-100k` | layer window `noteRereadsPerSave` | big | RECORDED (wave 4, VM-176) |
| | `note-deliveries-per-save-100k` | layer counter `noteProjectionDelivery` per save | big | RECORDED (wave 4) |
| | `note-delivery-ingest-100k` | TEST clock around the model's own `ingest(_:fromDelivery: true)` of a fresh projection (the echo arm) | big | no |

Every measured series runs five times after one unrecorded warm-up (the process's first use of TextKit, the fonts and
the screen's types is a once-per-launch cost, not a per-open one); each test also asserts it GATHERED its five runs, so
a dead probe is red, never a silent pass. "Editor constructions per open" is reported on the two SHELL roads only: a
screen mounted directly is built once by the test by construction, so its count would say nothing.

#### What a hosted test can and cannot reach (the brief's question, answered)

REACHED: the SwiftUI screen and shell, the band (the Library alive off screen), the NavigationStack push and its
`navigationDestination` builder (so the twin question is answerable), the screen's `.task` (liveness registration, the
arrival's load and first render, `start()` and its first delivery), the first paint (the layer's display-link tick), the
editor's and the box's real debounces, the leaving's `onDisappear`, the background flush through the app's own call,
an encrypted on-disk WAL store. NOT REACHED: the software keyboard (hardware-keyboard mode under `xcodebuild test`, so
"Tap the box → keyboard up" and "Open → keyboard up in the note" never fill — her phone fills them); a finger (doors are
driven through UIKit's accessibility activation or the model a face calls); the launch and unlock spans (a test host
never opens through the bootstrap); sync rounds and their aftershock (no services, signed out); a real lock (the Castle
arm runs the phone's own `onWillLock` and removes the tree as the state flip does, but closes no pool and drops no
key); the device's CPU, GPU and flash. Every number is a SIMULATOR number on a machine that may be loaded.

#### PROVISIONAL calls (options weighed; the built one first)

- **P-66-1 — reading the process's ONE recorder, so the suite runs ALONE** (built — the marks feed `AppTiming.recorder`
  and the listings' fetch closures run on GRDB's queues, which inherit no task-local, so no per-test recorder can be
  handed to them) · inject a recorder into every mark site (a production change across batch 1's files — not a test
  batch's) · a task-local override like `MobileEditTrace.testRecorder` (misses every fetch-closure count).
- **P-66-2 — the nine-wing world's size: 450 notes (50 per wing), no mega post** (built — over the Library's 200-note
  cut so batch 5's paging question is live; the 100k axis stays the big world's) · 300 notes, the one-wing corpus size
  (keeps corpus size equal across shapes, but under the cut per wing) · a full 300-note corpus PER wing (2,700 notes —
  a seeding cost every run pays). Her real note count is unmeasured; her phone's readout will say.
- **P-66-3 — the savepoint windows are closed by the test** once the leaving's own timed work has finished (the
  layer's `noteLeave` span, or the background work's `Task`) plus half a second (built — five runs in seconds, nothing
  else runs between) · wait out each window's 10 s deadline (a minute per series, and the same count).
- **P-66-4 — no new duration budget** (built — a budget is written with its measured basis, and the basis is the BEFORE
  numbers these runs produce; the counts carry the assertions later batches add) · generous budgets now, from the audit's
  older single numbers (no basis on this tree).
- **P-66-5 — the Castle arm's lock is the phone's `onWillLock` plus the tree's removal** (built — `AppBootstrap.
  lockOnNewRoad`'s order, minus the pool close and key drop, which no hosted test may do) · drive `bootstrap.lock()`
  itself (needs a real Castle-road store and custody in the test host — out of a test's reach).
- **P-66-6 — owner adoption: `AppServices.runOwnerAdoption`'s private body run verbatim** between the layer's own two
  marks (built) · build a whole `AppServices` (auth, sync, custody — a composition a test host cannot make) · widen
  the method's visibility (a production change for a test).
- **P-66-7 — each test on its own on-disk, encrypted copy** (built — her store's shape; the static worlds stay pristine
  for the other suites) · the static in-memory worlds (a `DatabaseQueue`, no WAL, no encryption — and shared, so a
  writing test would leak into the fixture pins).
- **P-66-8 — three durations on the TEST's clock where the layer has none** (open → live, a listing's query, one
  delivery's ingest), each named so in its series and comment (built) · add marks to the layer (a production change;
  batch 1's catalog is closed for this batch).

#### The Mac does not change

No `Shared/`, Core or `Sync/` file changed. The one app-target file (the fixture seeder) is phone-only
(`VariorumMobile/`), and its default shape is byte-identical. No Mac build is owed.

#### Evidence

- Core, headless: none owed (no Core change).
- Build: phone `build-for-testing` into `DerivedData/vm64-b3/` at `d2cef56be` — `** TEST BUILD SUCCEEDED **`, no warning
  in a touched file.
- PENDING (the stage window): group (i) twice → the BEFORE numbers in §5; group (ii) → the fixture pins (incl. the new
  nine-wing one) and the suites around the touched files green.

#### The stage window (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

**Group (i) — the BEFORE numbers. Run it ALONE (one suite, its own invocation, nothing else in the process), TWICE.**
Expect a few minutes per run (two fixture worlds seed first). Lift the numbers with the `grep`. *[Ladder round 2, O-1:
the suite is GATED since then — a run that does not hand the test runner `TEST_RUNNER_VM66_PERF=1` skips it (and Swift
Testing still counts the 13 skipped in "N tests … passed": read the skipped lines). The command below carries the switch;
the BEFORE runs at `vm64-b3` predate the gate and ran without it.]*
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileHerPathsPerfTests)
TEST_RUNNER_VM66_PERF=1 xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b3 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-run-N>
grep '^VM64-PERF|' <log-run-N>
```
A count red on a loaded machine is not expected (counts are deterministic); a duration is never asserted. If a run is
red, the failing test's issue names what it waited for (`VM-66: timed out waiting for …`) or which series came up short.

**Group (ii) — the other phone suites my changes could disturb** (the fixture's file and its worlds, the launch-path
doc, the shelf suite's header, and the layer the new suite reads):
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobilePerfFixtureTests MobilePerfWalkTests MobileLaunchPathTests MobileShelfPerfTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b3 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Expected: Swift Testing all green; `MobilePerfFixtureTests` now 7 tests (the nine-wing pin added). The walk's timing
pins are unchanged, and on a loaded machine a timing red is re-run alone before it counts (§4's rule). Batch 1's
machinery note applies: poll for the Swift Testing verdict line, not `** TEST EXECUTE **`.

#### For QUESTIONS at the merge (the orchestrator carries these to `notes/QUESTIONS.md`)

1. **P-66-2 — the nine-wing fixture's size** (450 notes, 50 per wing, no mega — built · 300 notes · 300 per wing).
   Hers to correct once her phone's readout gives her real count.
2. **P-66-4 — new duration budgets wait for the BEFORE numbers** (built) · budgets now without a basis.
3. **P-66-5 — the Castle backgrounding arm runs the phone's `onWillLock` and the tree's removal, not the pool close**
   (built) · a real lock in the test host (not reachable).
4. **P-66-1, P-66-3, P-66-6, P-66-7, P-66-8** — test-harness shapes (the suite runs alone; windows closed after the
   leaving's work; the private adoption body run verbatim; per-test encrypted copies; three test-clock durations),
   recorded for the cold review rather than her ruling.

### Batch 4 · VM-67 — launch and unlock stop scanning every table (implementer closeout)

**Not done in this batch (first, by the record's rule):** the stage runs are PENDING the orchestrator's window — the
simulator AFTER number of `owner-adoption-nothing-to-adopt` and the green run of the new hosted assertion (both in
`MobileHerPathsPerfTests`, group (i) below), and the hosted Mac and phone suites over the touched code (groups (ii) and
(iii)). **No red-on-old PRODUCT was built for the hosted assertion** (its red-on-old is proven headless on the same op —
below; the recipe for a hosted red build is given, optional). **No simulator walk, by the fence, not by choice:** owner
adoption runs only for a SIGNED-IN session, and a Debug walk of the phone stays signed out and uses no test account
(§4's stage facts), so no walk can reach it; its use-shaped evidence is the hosted suite driving the real op through
the real runner on an encrypted on-disk copy of the 100k world, and her phone's readout ("Owner check at start") fills
after the wave-1 install. No line in `Sources/VariorumCore/Sync/`, custody or keychain code; `Shared/AppServices.swift`
NOT changed. The other first-seconds work (the round, the janitor's scans, the idle sweep) is REPORTED below, not fixed.

**Base:** `96dfa82b5`. **Commits:** `2bdeafab9` (live status) · `0e9948d03` (the schema, its own commit) ·
`e6d16fca7` (the op + the Core pins) · `62c810100` / `de3111c4d` (the red-on-old revert announced, its result) ·
`8e4e73e01` (the hosted assertion) · `2b04e304c` / `2033aa95b` (the gated measurement; the before/after) · this closeout.

#### The mechanism, as traced on this tree (audit F 3A/6A — TRACED as written; the lines moved, the shape did not)

`AppServices.connectSyncIfAllowed` (`Shared/AppServices.swift:518-547`) runs `runOwnerAdoption` (:584-600) FIRST, then
composes and triggers the round. `runOwnerAdoption` runs `Operations.adoptOwnerID` on the ONE serial runner. The op
(`Operations/OwnerIdentity.swift:87-105` pre-fix) opened ONE write transaction (`database.write` = GRDB's
`writeWithoutTransaction` + `BEGIN IMMEDIATE`) and ran `UPDATE <t> SET owner_id = ? WHERE owner_id IS NULL` for each of
the eleven synced tables whose DDL carries `owner_id`. No index served `owner_id IS NULL` (none in `Migrations.swift`), so
every statement planned as `SCAN <t>` — measured, not inferred: the pin's trace on the pre-fix tree read `UPDATE
container … → SCAN container`, `→ SCAN block`, … for all eleven, and with NOTHING unowned the writer still ran `BEGIN
IMMEDIATE TRANSACTION`, eleven UPDATEs and `COMMIT TRANSACTION`. So every launch with a session, every unlock and every
sign-in read every row of every owner table through SQLCipher's page decrypt, holding the runner and the writer, to
change nothing.

#### What shipped, file by file

- `Sources/VariorumCore/Persistence/Migrations.swift` — **`v1_38_owner_adoption_index`** (its own commit, `0e9948d03`,
  ahead of the code): eleven partial indexes `idx_<t>_unowned ON <t>(owner_id) WHERE owner_id IS NULL` — container,
  block, tag, wing, shelf, reading, reference, canvas_layout, lens, block_comment, purge_intent. Empty in her steady
  state; holds exactly the rows adoption exists to find. The comment carries the §12 reasoning (below).
- `Sources/VariorumCore/Operations/OwnerIdentity.swift` — **`adoptOwnerID`, probe-then-write inside ONE writer access**
  (`database.writeWithoutTransaction` — the writer's own FIFO queue): the owner tables introspected as before; per table
  `SELECT EXISTS (SELECT 1 FROM <t> WHERE owner_id IS NULL)` (an index seek, autocommit — no write lock, no WAL frame);
  nothing unowned ⇒ the all-zero report (one entry per owner table, the shape unchanged) and NO transaction; otherwise
  today's UPDATE set unchanged, over every owner table, in ONE IMMEDIATE transaction (`db.inTransaction()` — GRDB's
  `write` shape). `restampOwner` (the adopt road) is untouched.
- `Tests/VariorumCoreTests/OwnerAdoptionTests.swift` — **the pins and the state transitions** (8 tests): PIN 1
  `withNothingUnownedTheWriterRunsNoTransactionAndNoWrite` (a GRDB statement trace on the writer connection: no BEGIN /
  COMMIT / UPDATE / INSERT / DELETE / SAVEPOINT; outbox empty; the report's shape); PIN 2
  `everyStatementReachesAnOwnerTableOnlyThroughItsUnownedIndex` (`EXPLAIN QUERY PLAN` of every traced statement, while
  adopting AND with nothing to adopt: a plan line that reads an owner table must name its `idx_<t>_unowned`; every owner
  table reached — never vacuous); `everyOwnerTableHoldsARowFromTheSeed` (the seed covers all eleven — a new owner table
  is unproven until seeded); `signedOutRowsInEveryOwnerTableAreAdoptedLiveAndTombstoned` (road 1, below: counts per
  table, every row owned, every adopted row in the outbox, `updated_at` and `sync_version` unmoved, the next pass writes
  nothing); `theMixedCaseAdoptsOnlyTheUnownedRows` (mine / theirs / unowned side by side); `anAccountChange…`
  (X's rows stay X's, NULLs → Y, then nothing written; after `restampOwner` nothing written);
  `aRowFromAWriteAlreadyQueuedIsAdoptedByThatPass` (on-disk WAL pool: a write holding the writer while adoption is
  called — the pass waits its turn and adopts the row; a reader-side probe fails this); `aStoreFromBeforeTheIndex…`
  (a v1_37 store with unowned rows, migrated: the index builds over them, the first pass adopts all six, through the
  index).
- `Tests/VariorumCoreTests/OwnerAdoptionMeasurementTests.swift` — the gated headless before/after
  (`VARIORUM_VM67_MEASURE=1`; skipped otherwise) on an ENCRYPTED on-disk store with 61,700 owned rows, warm and cold
  (store reopened per pass, the unlock's shape), plus the options' query plans through this build's SQLite (3.53.4).
- `Tests/VariorumCoreTests/MigrationTests.swift` — A JUSTIFIED EDIT (the ritual) ×3: `expectedIndexes` and the two
  migration-chain subtractions gain v1_38's eleven (`ownerAdoptionIndexes`), the v1_36 test subtracts them to keep its
  own claim; NEW `theOwnerAdoptionIndexesArriveForAnOlderStoreOnePerOwnerTable` (v1_37 → full: exactly one partial
  index per owner-carrying table, the set DERIVED from the registry + live DDL).
- `Tests/VariorumCoreTests/BlockCommentTests.swift` — A JUSTIFIED EDIT: the table's index set gains
  `idx_block_comment_unowned`.
- `App/Variorum/VariorumMobileTests/MobileHerPathsPerfTests.swift` — `OwnerAdoptionTrace` (nonisolated: the trace
  closure GRDB calls on its writer queue carries no test-actor isolation) and, inside
  `ownerAdoptionWithNothingToAdoptIsMeasuredAtFixtureScale`, AFTER its measured series (left untraced and unchanged),
  one more pass called as `runOwnerAdoption` calls it, asserting PIN 1 and PIN 2 at fixture scale on the encrypted
  on-disk store; the test's doc says so. No other series touched.

#### S4 — every road by which a synced row with a NULL `owner_id` can exist on today's tree (the fix is judged against this)

**The facts the list stands on.** Eleven synced tables carry `owner_id` (`SyncSchema.tables` ∩ live DDL). Every
Operations construction of their records passes `ownerId: currentOwnerID()` — all 34 sites checked (`Operations+`
Container, Versions, WingMove, Ownership, Pool, Structural, Quicknote, Tag, Wing, Shelf, ReadingFilter,
StarredGathering, Reading, DocumentImport, MCPWrites, Reference, Lens, Canvas, Comments, Purge); the models default
`ownerId` to nil. `currentOwnerID()` reads the installed closure, which reads the Keychain session PER CALL
(`Shared/AppBootstrap.swift:490-493`) — nil while signed out. No raw-SQL insert into an owner table exists outside
`SyncRow.apply` (`Sync/SyncSchema.swift:965`, the pull) and v1_18's `reading` rebuild (`Migrations.swift:671`, which
copies `owner_id` as it was).

1. **A mint while signed out** — every owner-table row is born NULL: notes and pools, blocks, tags, books and gatherings,
   wings, shelves, references, canvas positions, lenses, comments, purge intents (the seeders and the first-write
   furniture mint through the same ops).
2. **A mint while signed in but the closure answers nil** (the Keychain item unreadable at that instant) — the same
   mechanics as 1; possible in principle (a per-call Keychain read), not observed.
3. **Rows inside a store that arrives whole** — a restore from a safety copy or backup, a library opened from its folder
   pair, a plaintext export adopted (the `LocalMachineryRecreation` road): whatever NULL rows it carried (a library built
   entirely signed out; pre-9c rows).
4. **A schema migration** — mints none; v1_18's rebuild carries a NULL as a NULL (road 3's class).
5. **The pull — never.** The mirror's `owner_id` is NOT NULL on these eleven tables (14c), and `sync_pull` keeps it in the
   payload for exactly these eleven (`owner_tables`, `Server/supabase/maintenance/vx495-pull-keyset.sql:162-164,
   244-255`; the same list in `13_phase13i_wings.sql:196-198, 310-312, 490-492`); `SyncRow.apply` writes it verbatim.
   Sync repairs that mint rows mint through Operations (roads 1–2's stamping; a round runs only signed in).
6. **And the push refuses one:** `sync_push` raises on any owner-table row whose `owner_id` `is distinct from` the
   caller, NULL included (`13_phase13i_wings.sql:383-391`) — an exception, so ONE unowned row in the outbox fails the
   whole push. That is why adoption must precede the first push of any row from roads 1–3, and why a skipped row would
   show as a stuck round, not a silent loss.

**When adoption runs (unchanged by this batch):** `connectSyncIfAllowed` → `runOwnerAdoption` at a launch with a
persisted session (`start()`, `AppServices.swift:320-323`); every UNLOCK (each `.ready` composes and starts fresh
services — the phone at `VariorumMobileApp.swift:150`, the Mac likewise); every sign-in (`variorumSignInChanged` :497 —
an account change is a sign-out, then a sign-in); Resume (`resumeSync` :557); the first round after an account act
(`runFirstRound` :572); the deletion door's refusal reconnects (:634, :654).

**Why the fix adopts every such row no later than today's code:** (i) the predicate is unchanged — the probe and the
UPDATE both select `owner_id IS NULL`, and when ANY owner table has one, the full UPDATE set runs over every owner
table; (ii) a partial index holds exactly the rows satisfying its WHERE — SQLite maintains it inside every INSERT and
UPDATE, trigger and pull-apply writes included, and builds it over existing rows at the migration (road 3's older
stores: `aStoreFromBeforeTheIndex…`); (iii) the probe runs on the WRITER's queue, FIFO behind every write already
queued, so it sees exactly what the one write transaction it replaced saw (`aRowFromAWriteAlreadyQueued…` — a reader
probe fails it); (iv) the occasions and call sites are untouched. A row committed after the pass is the next pass's, as
before.

#### The three options, weighed — with the plans (through this build's SQLite 3.53.4, on the seeded encrypted store)

| Option | The probe's plan | The update's plan | With nothing to adopt | Can it skip a row? | Verdict |
|---|---|---|---|---|---|
| (a) a partial index per owner table | `SEARCH block USING COVERING INDEX idx_block_unowned (owner_id=?)` | `SEARCH block USING COVERING INDEX idx_block_unowned (owner_id=?)` | O(1) per table — but ALONE it still opens `BEGIN IMMEDIATE` + eleven seeks + `COMMIT` every launch (the schema-only tree `0e9948d03`: the plan pins green, the write pins red) | No — SQLite keeps the index true, no fact to remember | built, with (b) |
| (b) an existence probe before the write | `SCAN CONSTANT ROW ; SCALAR SUBQUERY 1 ; SCAN block` without the index | — | ALONE it is the same O(corpus) read: `EXISTS` with no unowned row must read the whole table to answer "none" — it only moves the scan off the write lock | No | built, on top of (a) |
| (c) a recorded "adopted for owner X" fact | none | none | O(1) — skips the scan entirely | **Yes, silently**: the fact stays true only if EVERY road that can mint an unowned row clears it — roads 1–3 (34 op mint sites under a nil identity, every whole-store arrival, any future road); the only central hook would be a trigger, and triggers own exactly three things (OverallModel §9), so it would rest on op-side discipline, and one forgotten road leaves rows unowned and the next push refused | rejected — the brief's own preference: no remembered fact |

Before the fix, the update read `SCAN block` (the same line through this build). The store's other `owner_id` reads keep
their plans — `owner_id = ?` and the dormant foreign-owner read (`owner_id IS NOT NULL AND owner_id != ?`) both
`SCAN block` before and after (a partial index on `owner_id IS NULL` is unusable for them): no plan churn.

#### SyncSpec §12 — the index is NOT a lockstep event (verified against the code, not assumed)

- The registry walk enumerates TABLES (`SyncSchemaTests.swift:14-19`, `sqlite_master WHERE type = 'table'`); the column
  walk classifies COLUMNS (`SyncSchemaTests.swift:93`). An index is neither.
- `SyncSchema.lockstepVersion` is a constant (`Sync/SyncSchema.swift:170`, 15), pinned equal to the newest mirror
  artifact's marker (`AuthRLSDDLTests.swift:934-949`); no migration computes or moves it. Unchanged.
- The mirrors carry no index beyond the PK by design (SyncSpec §2); no file under `Server/` changed. Precedents: v1_34
  and v1_36, local index migrations recorded as not lockstep events (`Migrations.swift`).
- A store or plaintext export that ran v1_38 reads `.newerSchema` on an older build (`LibraryClassifier.swift:179-185`:
  applied minus known migrations) — VX-502's standing rule, as for v1_36. The plaintext export carries the index
  (`sqlcipher_export` copies the whole schema, `StorePlaintextExport.swift:74`).
- **The identifier:** `git fetch origin`; every remote branch's diff against `origin/main` touches no file under
  `Sources/VariorumCore/Persistence` (vm-47-sizes-and-look, vm-55-wings-underneath, vm-78-fixes-to-whats-there,
  vx-980-search-fixes, vx-981-mcp-door-followups, vm-44-mobile-catchup, vx-997-ambient-app); main's last is v1_37. No
  two runs mint v1_38.
- **The one-time cost:** building the eleven indexes reads each owner table once at the new build's first open — about
  ONE of today's launches' adoption scans, once (her phone: the wave-1 install's first launch).

#### The pins — red on the pre-fix tree, by revert

| Test | Pre-fix (`96dfa82b5`'s schema + op) | Schema only (`0e9948d03`) | The fix |
|---|---|---|---|
| PIN 1 `withNothingUnownedTheWriterRunsNoTransactionAndNoWrite` | **RED** (BEGIN IMMEDIATE + 11 UPDATEs + COMMIT) | **RED** (same) | green |
| PIN 2 `everyStatementReachesAnOwnerTableOnlyThroughItsUnownedIndex` | **RED** ×2 (`→ SCAN <t>`, adopting and idle) | green | green |
| `signedOutRowsInEveryOwnerTableAreAdoptedLiveAndTombstoned` | **RED** (its idempotent second pass wrote) | **RED** | green |
| `anAccountChangeAdoptsOnlyTheUnownedRowsAndThenWritesNothing` | **RED** ×2 (both quiet passes wrote) | **RED** ×2 | green |
| `aStoreFromBeforeTheIndexAdoptsItsUnownedRowsThroughTheIndex` | **RED** (scanned) | green | green |
| `theMixedCaseAdoptsOnlyTheUnownedRows` | green | green | green — **S4 guard, by design** |
| `aRowFromAWriteAlreadyQueuedIsAdoptedByThatPass` | green | green | green — **S4 guard, by design** |
| `everyOwnerTableHoldsARowFromTheSeed` | green | green | green — the seed's guard |

Pre-fix: 8 tests, 5 failed, 7 issues. The revert ran on the committed fix and was restored (`git diff HEAD` empty).
The hosted assertion is the same two pins on the same op at fixture scale; its red-on-old is optional (recipe below).

#### The timing marks (batch 1's) — unchanged, and measuring the same thing

`AppServices.runOwnerAdoption` is byte-untouched: "Owner check at start" still spans the op on the runner (its queue
wait included), "rows stamped" is still the report's total. The work moved INSIDE the op, so no mark moved.

#### Evidence

- **Core, headless:** `OwnerAdoptionTests` 8/8 · `OwnerIdentityTests` 8/8 · the touched + store-constructing suites
  (`OwnerAdoptionTests|OwnerIdentityTests|MigrationTests|BlockCommentTests|SyncSchemaTests|AuthRLSDDLTests|
  StorePlaintextExportTests|PlaintextExportImportTests|LocalMachineryRecreationTests|LibraryClassifier|
  MultiTenantSyncTests|StoreEncryption|TriggerTests|ArrivalsPinsSchemaEventTests|AppDatabase`) **242 tests in 20 suites
  passed** · **the whole package, `swift test`: VariorumCoreTests 4,119 tests in 566 suites passed with 5 known issues
  (the standing `withKnownIssue` marks in the VX-529 pair suites — not this batch's); 703 in 130 and 32 in 4 passed;
  exit 0** (Swift Testing's counts include skipped tests — the gated measurement among them).
- **Builds:** phone `build-for-testing` (generic iOS Simulator) and Mac `build-for-testing` into
  `App/Variorum/DerivedData/vm64-b4/`, both `** TEST BUILD SUCCEEDED **`, no warning in a touched file.
- **The headless before/after** (`OwnerAdoptionMeasurementTests`; Mac M3, Debug, encrypted on-disk WAL store, 61,700
  owned rows; n = 5 per series; a MAC number, never a phone number; the machine shared with other sessions):

| Series | BEFORE (pre-fix tree) | AFTER run 1 | AFTER run 2 | AFTER run 3 (loaded machine) |
|---|---|---|---|---|
| warm (one pool) | 11.14 ms (10.98–11.18) | 0.79 (0.78–0.81) | 0.83 (0.81–0.85) | 1.76 (1.51–3.70) |
| cold (store reopened per pass) | 11.10 ms (10.97–11.27) | 0.86 (0.83–0.90) | 0.85 (0.85–0.87) | 2.38 (2.35–4.90) |

  What remains after the fix is the per-table introspection (`PRAGMA table_info` over the registry) and eleven index
  seeks; it no longer grows with the corpus. The BEFORE scales with her row count and her phone's flash and CPU.
- **PENDING (stage):** the simulator AFTER of `owner-adoption-nothing-to-adopt` (median and range, n = 5) against
  batch 3's BEFORE, the hosted assertion green, and groups (ii)–(iii).

#### The Mac does not change in behaviour (review focus 8)

The op is shared, so on the Mac too a launch with nothing unowned now writes nothing (before: an empty IMMEDIATE
transaction after eleven scans) — the same rows adopted at the same occasions, nothing she can see. No `Shared/` file
changed. The Mac's sign-in adoption pins (`Phase9cAuthWiringTests` and the first-round suites) are in group (iii).

#### Reported, not fixed: what else the first seconds after launch and unlock scan or write

In order, after `start()` (`AppServices.swift:298-335`) — runner (R), writer (W), reader (r), network (N):

1. **Owner adoption** — fixed here (before: eleven full-table scans in one write transaction, R + W).
2. **The first round**, triggered at once by `connectSyncIfAllowed` (`Sync/SyncScheduler.swift:212-320`):
   `beforeRound` (a memory read unless a typed-unlock key load is pending; a flush only when typing is pending) →
   **`janitor.reconcileLedger()` BEFORE the round** (`PurgeJanitor.swift:297-340`: preflight = custody key read + the
   `schemaVersion` RPC; `sync_purge_ledger` behind a challenge — N ×2–3; a W transaction only if entries arrived) →
   **pull** (the engine's own preflight and challenge; with nothing new, an empty page; N) → **push** (an outbox read;
   with nothing to send, little or nothing on the wire) → **`janitor.sweep()` AFTER every clean round**
   (`PurgeJanitor.swift:132-276`): the preflight AGAIN (`schemaVersion`), `reconcileLedger` AGAIN (challenge + ledger),
   `sync_horizon` (challenge) — N ×5–6 more — then **`collectRoots` (:360-427): four reads with `deleted_at IS NOT
   NULL` on `container`, `reading`, `block` and `variant` (variant joined to block). No index serves `deleted_at IS NOT
   NULL` (the `deleted_at` indexes are partial on `IS NULL`; `idx_cblock_dead_block` is on `container_block`), so these
   are FULL SCANS of four tables — `variant`, the largest, included — after EVERY clean round (r).** Then a family
   verdict read per root, and, in Standard mode only, `prunableSavepoints` and a purge-intent mint (W). Wave 4's
   (VM-176…VM-185, the janitor VM-182).
3. **The idle-commit sweep** (`idleCommits.start()` → an immediate `sweepNow`, `Shared/IdleCommitScheduler.swift:75-
   110`): candidates read from a low-water-mark window over `idx_container_touched` (bounded, r), then one
   `idleAutoCommit` per candidate on the runner (R + W).
4. **The local purge loop's first tick** (`AppServices.swift:328-334`): a no-op while sync is configured (it is, by then,
   when signed in — `AppSession.sweepLocalPurge`'s guard); a signed-out install runs `LocalPurge`'s own tombstone scans.
5. **The phone's first-write furniture `prime()`** (two reads) and **every held listing's first fetch** on a cold store
   (the Library's two — the bookless one corpus × gatherings, batch 5's — Starred, the shelf; r).
6. **Per MINT, not per launch:** the identity closure reads the Keychain on every top-level mint (`AppBootstrap.swift:
   490-493`) — each quick-note mint and each crystallized block pays a Keychain read to stamp `owner_id`. Size
   unmeasured; a candidate for lag 2's mint step (a later batch or wave 4 — not this unit).
7. **Dormant:** `Queries.foreignOwnerExists` (`Queries/OwnerQueries.swift:31-40`) scans every owner table when the
   library is NOT foreign (the common answer); no production caller today (tests only) — recorded for its first caller.
   `restampOwner` (the adopt road) stays O(owner tables) by nature (it rewrites every row) — a rare, deliberate act.

**Does owner adoption plausibly contribute to the minute-long round with nothing to send?** **No — not inside the
round.** Adoption returns BEFORE `sync.configure` and `triggerSync`, so the readout's "Sync round" span (status syncing →
stopped) begins after it; with nothing unowned its UPDATEs changed zero rows, so it enqueued nothing and added no push
work. Its only effect on the round was to delay its START by the scan — 11 ms on this Mac at 61.7k owned rows; on her
phone plausibly tens to a few hundred milliseconds on a cold encrypted store after an unlock — never a minute. The
round's own candidates, by reading: about eight to ten challenge-signed network calls (each a nonce fetch plus the
call) even with nothing to send; the pull (if the Mac had pushed anything); the sweep's four full tombstone scans on a
cold store; per-family purge RPCs if families were eligible. Splitting the minute needs per-phase marks INSIDE the
round — a `Sync/` line (P-65-7's road), wave 4's.

#### Design calls (options weighed; for the cold review — none is a product decision, none is hers)

- **P-67-1 — the probe runs on the writer's queue** (built: identical visibility to the transaction it replaced; the
  queue is held for eleven index seeks) · on a READER (no writer contact at all, but a write queued at the call is
  missed until the next launch — pinned out by `aRowFromAWriteAlreadyQueued…`) · no probe (the index alone: an empty
  write transaction every launch).
- **P-67-2 — the index shape: per owner table, on `(owner_id)`, partial on `owner_id IS NULL`** (built: the planner
  seeks it as `owner_id=?`, and it stays empty in the steady state *[ladder round 3, finding 5(c): the signed-in
  steady state; in a library never signed in it holds every row of its table — one small entry per row written, the
  cost the full-index option is rejected for, paid there only]*) · partial on `(id)` (the planner would scan the
  partial index rather than seek it) · a full `owner_id` index (every owned row an entry, maintained at every mint, for
  no read that needs it).
- **P-67-3 — the report keeps one zero entry per owner table when nothing adopts** (built: its shape is unchanged for
  every reader) · an empty dictionary.

#### For QUESTIONS at the merge

None. This batch decides no product behaviour and adds no user-facing copy.

#### The stage window (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Products: `App/Variorum/DerivedData/vm64-b4/` (phone + Mac), built at `8e4e73e01` (later commits are records and the
gated Core measurement — no app-target or shared-code change).

**Group (i) — the AFTER number and the new assertion. Run it ALONE, in its own invocation** (batch 3's rule — the
suite reads the process's one recorder). The BEFORE is batch 3's group (i) from `vm64-b3` (its own window). Lift with
the `grep`; the batch's series is `owner-adoption-nothing-to-adopt` (and `owner-adoption-rows-nothing-to-adopt`, still 0).
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileHerPathsPerfTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b4 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-b4-i>
grep '^VM64-PERF|owner-adoption' <log-b4-i>
```
Expected: Swift Testing all green; `ownerAdoptionWithNothingToAdoptIsMeasuredAtFixtureScale` green WITH its VM-67
assertions (no write statement; every statement through its unowned-row index; every owner table reached). If it is
red, its issue names the statement or the plan line.

**Group (ii) — the phone suites that open on-disk stores through the migration set or compose the services:**
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileLaunchPathTests MobilePerfFixtureTests MobilePhoneStoreEncryptionTests MobileRoundOccasionTests
  MobileTypedUnlockSyncKeysTests MobileRelockCoordinatorTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b4 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```

**Group (iii) — the Mac suites that construct `AppServices` or exercise adoption at sign-in and first round** (the Mac
compiles the changed op and the migration set):
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(Phase9cAuthWiringTests FirstRoundRoadTests FirstRoundAfterTheActTests FirstRoundAfterTheReopenTests
  SyncBeforeRoundTests SyncReachabilityTriggerTests ProdTestRoadTests OneRefreshAuthorityCompositionTests
  OneRefreshAuthorityRaceTests HostedSyncStatusReadTests SyncWalkFenceTests AuthSessionTests SignUpPresentationTests
  HostedSyncTierFaceTests AppBootstrapOffMainTests TestHostInertTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath DerivedData/vm64-b4 ${tests/#/-only-testing:VariorumTests/}
```
Batch 1's machinery note applies: poll for the Swift Testing verdict line, not `** TEST EXECUTE **`.

**Optional — a hosted red-on-old** (not built): `git checkout 96dfa82b5 --
Sources/VariorumCore/Persistence/Migrations.swift Sources/VariorumCore/Operations/OwnerIdentity.swift`, phone
`build-for-testing` into `DerivedData/vm64-b4-red`, `git checkout HEAD --` the same two files (clean `git status`),
then group (i) against `vm64-b4-red` — expect the owner test RED on its VM-67 assertions (BEGIN + eleven UPDATEs,
`→ SCAN <t>`), every other test as in batch 3's BEFORE run.

### Batch 5 · VM-68 — the Library pages and stops re-reading (implementer closeout)

**Not done in this batch (first, by the record's rule):** every hosted run is PENDING the orchestrator's stage window
(the products are built — the commands are below), so the pins' red and green, the after-numbers and the nine-wing
plans are not yet in this record; no simulator walk yet (the stage's — group (vii) below names it). Row previews are not
built (wave 2 — where they attach is said below). No new copy, no new face. No schema, no `Sync/`, no `SearchComposer`
line. VX-618 is NOT closed by this batch (below).

**Base:** `35a3bea7a`. **Commits:** `d8b64dd34` (live status, the Core lines said first) · `3c931e33c` (Core: the
Pool's predicates' one home, the page's keys and its Pool-loose form, the Core pins) · `8f1adc87c` (phone, written under
the quiet window) · `5be4f09b1` (this closeout, drafted) · `cc7b2e4a2` (a test's row lookup) · `5ba59a6c8` (the
phone build's one compile error: `isDrawn` compares pages by index) · **`d893fae63` — Merge main (VX-980)**, at the
orchestrator's word · `dcea98cee` (two test-file compile fixes) · the red-on-old revert's announcement and this
closeout's completion.

#### Main merged (VX-980) — what it means for this batch

Clean merge (`d893fae63`; VX-980 touched no file this batch touches). VX-980 changed the guard inside
`SearchComposer.listingNarrowing` (it now reads `!asksWords(query)`, so words that fold to nothing beside a tag take the
tag road). `catalogNotesPage` calls that guard ONLY when its `narrowing:` argument is non-nil, and every read this batch
adds passes `narrowing: nil` (the phone's `read`: the plain page and the Pool-loose page), so the new guard never runs
on them. In `LibraryPaging.swift` this batch's lines sit NEXT TO that call — the `poolLoose:` parameter on the same
signature line as `narrowing:`, and `let pool = …` right after the narrowing's fail-closed return — but no line of the
call or its guard changed, and VX-980 did not edit the file. Nothing in this batch's pins depends on the old guard: the
catalog page's byte-identity pin builds its narrowed shape from a hand-made `ListingNarrowing` (the memberwise struct,
unchanged by VX-980) and never goes through the guard; the loose-page walk, the keys pin and the plans pass no
narrowing. Re-run on the merged tree, headless: the Core set plus VX-980's `SearchFoldedWordsBesideATagTests` — **173
tests in 24 suites passed**.

**Builds (all on the merged tree, products at `dcea98cee`):** phone `build-for-testing` (generic iOS Simulator) and Mac
`build-for-testing` into `App/Variorum/DerivedData/vm64-b5/` — `** TEST BUILD SUCCEEDED **`, no warning in a touched
file; the red phone build into `App/Variorum/DerivedData/vm64-b5-red/` (the five Shell files at base `35a3bea7a` over
merged Core, the rules pins aside) — `** TEST BUILD SUCCEEDED **`, so the pre-fix Shell files compile against merged Core;
restored, `git status` clean.

#### The mechanism, as traced on this tree (audit F §5/§7/§8 P1.1–P1.2, A·B1/B2 — TRACED as written)

The Library root is mounted for the shell's whole life, offset a screen away in the band (`MobileShellView.swift:227-241`),
and its view held TWO observations unconditionally (`MobileLibraryView.swift:130-131`): `Queries.library(limit: 200)`
(ordered by `COALESCE(last_touched_at, created_at)`, which no index holds — a full scan and top-N sort of the posts) and
`Queries.poolPosts(limit: 200)` (`notePoolListingSQL`: every live note probed for a home, every bookless note tested
against every live gathering's rule, then `ROW_NUMBER`/`COUNT(*) OVER` over both classes). `AppDatabase.observe` tracks
whole tables, and every autosave rewrites the `container` row (VX-618's full-record update), so each capture-box save —
and each note save, each mint, each sync apply and push bookkeeping — re-ran both and delivered both to a Library she
could not see: the BEFORE table's **2 re-reads · 2 redraws per box save** (1 + 1 by listing). And the note listing was a
silent CUT at 200: note 201 had no road but a title search.

#### What shipped, file by file

- `Sources/VariorumCore/Queries/ShelfQueries.swift` — the Pool's two predicates lifted, unchanged, into one home:
  `poolShownByGathering` (the live, unarchived gatherings' OR, each COALESCEd to 0) and `poolHomeExistsSQL` (a live MEMBER
  row of a LIVE BOOK); `notePoolListingSQL` reads them and is **byte-identical** (pinned against a frozen verbatim copy of
  the base's builder, text AND arguments, across six kinds of gathering and every wing scope). New `poolLooseFilter` —
  the loose class as one predicate: `CASE WHEN <home> THEN 0 ELSE NOT <shown> END`, so a note with a home never pays a
  rule probe.
- `Sources/VariorumCore/Queries/LibraryPaging.swift` (said first in LIVE STATUS, with why) — `CatalogNotesPage.keys`
  (each hit's sort key, which the statement already selected for the cursor; additive, defaulted); `catalogNotesPage(…,
  poolLoose:)` (default false: the shipped statement byte for byte — pinned against a frozen copy across every sort,
  direction, cursor, wing scope and narrowing) adds the loose predicate to each arm and names the plain arm's table `c`.
- `Tests/VariorumCoreTests/LibraryPoolPagingTests.swift` — 8 tests (below).
- `App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift` — the listings' machinery (MARK "The
  listings: pages, held only while shown"): `Listing` / `Question` / `Hold` / `ListingPage`; `hold(_:)` (the view's one
  task); `prime` (one read per question, shown or not); `holdFirstPage` (the on-screen observation of the shown listing's
  first page); `followFirstPage` + `reread` (a deeper listing re-asked in place, single-flight — the Mac's
  `followListingMove`); `loadMore` / `rowAppeared` / `askForMore` (the next page, with a `wantsMore` ask that survives a
  superseding landing); `land` / `append` / `place` (generation-guarded; "listed once, where first read"; the timing marks);
  `read` (the one read — `catalogNotesPage`, its Pool-loose form for Bookless) and `timelineItems` (page → rows, the key as
  the stamp). `startAll` / `startBookless` stay (the on-screen hold, the pins' road). `union` gains `notesComplete`
  (default true — every existing caller unchanged); `emptyListing` waits for the Bookless door's first answer and reads
  its store fact from that read.
- `…/Shell/MobileLibraryView.swift` — `isOnScreen` (default true); ONE `.task(id: hold)` replaces the two always-on
  tasks; the scraps task stands down while hidden too; a note row's `onAppear` asks for the next page; the stale "cuts
  silently" comment replaced.
- `…/Shell/MobileShellBand.swift` — `isDrawn` (pure): a page is drawn while any of it shows.
- `…/Shell/MobileShellView.swift` — `libraryOnScreen(width:)` = the Library's stack at its root AND its page drawn (the
  current page, or revealed by a band drag), passed as `isOnScreen`.
- `…/Shell/MobileListingFilters.swift` — two doc lines (the Bookless read's name).
- `App/Variorum/VariorumMobileTests/MobileLibraryPagingTests.swift` (3, red-on-old-able), `MobileLibraryPagingRulesTests.swift`
  (9 + parameter cases, VM-68's API), `MobileHerPathsPerfTests.swift` (batch 5's series only — below).

#### The shape chosen, and what it costs per write (brief items 2–4)

| | Hidden (a band neighbour, or covered by a note on its own stack) | On screen |
|---|---|---|
| Note listing (All/Notes) | **nothing held — 0 reads, 0 landings per write.** Read ONCE per question (the mount's prime: "Library ready") | ONE observation of the FIRST page (`listingLimit` = 200, a bounded keyset page): per write to `container`/`wing`, one seek down `idx_container_touched` stopping at the page (+ the never-touched notes' arm, ∝ those — the paging read's recorded design); a delivery lands directly while only that page is listed, else ONE statement to the listed depth (single-flight). *[Ladder round 2, finding 5 — "one seek … stopping at the page" is the EDITED sort's, in a wing holding at least a page of notes. Under the other three phone sorts (created, date, last meaningful edit) the page is `catalogNotesPage`'s single arm with no index on its key: a top-N pass over the store's live notes (no index carries the wing either), ∝ the note count (the paging read's own header says so of the Mac). And under the edited sort in a wing holding FEWER notes than a page — any small wing, since the phone stands in one — the touched arm is forced onto `idx_container_touched` (`INDEXED BY`), which carries neither kind nor wing, so `LIMIT limit + 1` never fills and the walk reaches the index's end, fetching every live container in the store to test it: ∝ the store. Neither is a regression (the old listings scanned and sorted every post at every write, hidden or not; the Mac's catalog has the same shape), and while the Library is on screen little is typed; ticketed for wave 4's ranking.]* |
| Bookless | nothing held, not even read (not the filter shown) | the same, Pool-loose: per write to its region (`container`, `reading_post`, `reading`, `post_tag`, `tag`, the ★ `setting` when a ★ gathering exists, `wing`), a walk of the touched index testing each walked note's home (one seek) and, only for a homeless one, the gatherings' rule probes — stopping when the page fills |
| Scraps | stood down | `MobileScrapsModel.start()` as before |

**Plans** (headless, `LibraryPoolPagingTests.thePlansOfTheTwoHeldPagesAreSeeks`, `VM68-PLAN|…`; the nine-wing fixture's
are printed by the hosted series, `VM64-PLAN|…` — PENDING the stage): notes-head — `SEARCH container USING INDEX
idx_container_touched (last_touched_at>?)` for the touched arm, `(last_touched_at=?)` for the never-touched arm, each a
co-routine under `MERGE (UNION ALL)`; bookless-head — the same two seeks on `c`, with per walked row `SEARCH rp USING INDEX
idx_reading_post_post (post_id=?)` → `SEARCH r … (id=?)` and, per tag term, `SEARCH root … (id=?)` · `SEARCH applied USING
INDEX uq_tag_path_live` · `SEARCH pt USING INDEX uq_post_tag_live (tag_id=? AND post_id=?)`. No arm scans `container`.
**VM steps** (`theLoosePagesWorkIsFlatInTheCorpusWhileThePoolsGrows`, headless, page 40, the never-touched notes and the
gatherings' wearers held fixed): the first loose page **6,332 → 6,164** at 300 → 1,200 notes (flat); the Mac's Pool
statement (= the phone's Bookless re-read before this batch) **77,461 → 306,988** (∝ notes).

**The floor, said plainly:** *[Ladder round 2, finding 5: this floor is the Bookless page's; the note listing has its own two, stated in the cost table's "On screen" cell above.]* a loose page must find a page of loose notes, so a wing holding FEWER loose notes than a
page is walked to its end (each walked note one home seek) — never worse than the Pool statement, which walks every note
and sorts; on the nine-wing fixture's all-wing scope (≈75 loose of 450) the first Bookless page is that case. Only an
index on "loose" could beat it, and loose-ness is a function of the gatherings' rules — no column holds it (no schema
change proposed).

**Why `observe(tracking:)` buys nothing here:** both listings' answers genuinely depend on `container`'s per-autosave
stamp (the edited sort's order), and autosave writes the full record (VX-618), so a named-region trigger would still wake
at autosave rate. The win is not narrowing the wake; it is holding nothing while nothing is shown.

#### The hidden Library, and why the return can never show a stale list (brief item 3)

**Built: stand down, and re-ask on return** (not a held trigger). The view's task key carries the on-screen fact; it
flips TRUE the moment any of the Library is drawn — the tab door's tap, the FIRST point of a band drag's reveal, a pop
back to its root — which restarts the task, and the restarted held page's FIRST fetch is the re-ask (GRDB's
`ValueObservation` observes every commit after that fetch, so nothing written from then on is missed; a listing deeper
than the page is re-read to its depth on that first delivery). What can show before the re-ask lands is the pre-return
rows, for one bounded statement (the simulator's `library-page-fetch-ninewings`, PENDING). A held "dirty" trigger was
weighed and not built: it would still wake at autosave rate (above) and could not show anything sooner than the re-ask
does — the rows on screen at the reveal are the same either way.

#### The pins

| Pin | Kind | Pre-VM-68 | VM-68 |
|---|---|---|---|
| `MobileHerPathsPerfTests.typingInTheBoxWakesTheOffScreenLibrary` — `library-rereads-per-box-save` / `-redraws-` / `all-listing-rereads-` / `bookless-rereads-per-box-save` **ASSERTED 0** | bug pin | RED (2 · 2 · 1 · 1 — the BEFORE table) PENDING the red build's run | 0 · 0 · 0 · 0 PENDING. **Why zero, not one:** nothing is held while hidden, so nothing waits to be told of a write; the cost moved to the return (`library-return-rereads`, recorded: 1 per return) |
| `MobileHerPathsPerfTests.typingInANoteOpenedFromTheLibraryLeavesTheLibraryAlone` — `library-rereads-` / `library-redraws-per-note-save-covered` **ASSERTED 0** | bug pin, or HOLLOW | PENDING — red if SwiftUI kept the covered root's tasks alive under a push; if it reads 0 on the old build too, SwiftUI already stood them down and this row is hollow (recorded so, the `libraryPath.isEmpty` term then a stated belt) | 0 PENDING |
| `MobileLibraryPagingTests.theTwoHundredAndFirstNoteIsReachableByScrolling` (230 notes, the default page, scrolled like a thumb) | bug pin | RED expected (the 200 cut) PENDING | PENDING |
| `MobileLibraryPagingTests.theBooklessDoorListsEveryLooseNote` (12 loose, page 5) | bug pin | RED expected (`poolPosts(limit: 5)`) PENDING | PENDING |
| `MobileLibraryPagingTests.aNoteMintedWhileTheLibraryIsAwayIsListedWhenSheReturns` | GUARD (green on both) | PENDING | PENDING |
| `MobileLibraryPagingRulesTests` (paging walks every note once in `Queries.library`'s order for all four sorts · a hidden Library holds nothing and the return re-asks · a deeper listing follows its first page · a new question starts over · the Bookless line waits for its answer · the hold key · the union withholds · page → rows · `isDrawn`) | design pins (VM-68's API — not in the red build) | — | PENDING |
| Core `LibraryPoolPagingTests` (the Mac's two statements byte-identical · the loose pages ARE `poolPosts`' loose class, ids and stamps, every wing scope, pages of 1/4/50/500, over books, a deleted book, arrivals, a stray gathering row, tag/★/NOT/malformed/archived gatherings, a second wing, archived/deleted/never-touched notes · the class follows the Pool's own acts · the keys ARE `Queries.library`'s stamps for the four phone sorts · the loose page seeks the touched index · the VM steps · the plans) | guards + P1 | the byte-identity guards GREEN on the base builders (run before the extraction) | **8 tests green headless**; with the neighbours **169 tests in 23 suites** |

**The red-on-old build** (PENDING — announced in LIVE STATUS before it starts): after the fix is committed and pushed,
`git checkout 35a3bea7a -- App/Variorum/VariorumMobile/Features/Shell/{MobileLibraryViewModel,MobileLibraryView,MobileShellView,MobileShellBand,MobileListingFilters}.swift`,
move `MobileLibraryPagingRulesTests.swift` out of the test folder (it names VM-68's API), `build-for-testing` into
`DerivedData/vm64-b5-red/`, then `git checkout HEAD --` the five files, put the rules file back, `git status` clean. Core
stays at the fix there: its changes are additive and the old phone code calls only the unchanged statements
(`Queries.library`, `poolPosts` — byte-identical), so the red build IS the old phone's behaviour.

#### The timing marks (batch 1's) — what they measure now

"Launch/Unlock → Library ready" is unchanged in meaning: the note listing's first landing is the mount's prime, which
runs whether or not the Library is on screen. `libraryFetch` / `booklessFetch` still count every Library read (prime,
held page, re-ask, next page); `libraryDelivery` / `booklessDelivery` now count landings that CHANGED the rows (before:
every distinct observation delivery — the same thing in practice, since `removeDuplicates` delivered only changed values;
a re-ask that lands identical rows draws nothing and is not counted).

#### Row previews (wave 2) — where they attach (brief item 5)

Never inside `read` (the held page's fetch): a preview read attaches beside `place(_:page:in:)` as a ONE-SHOT read over the
LANDED rows' ids — bounded, flat in a note's length (Core's `leadingBlockTexts` with a cap, the Mac's `loadNearExtras`
road) — and re-reads only the rows a landing changed. The held page stays ∝ the page.

#### The Mac does not change in behaviour

Its Pool statement and its catalog page statement are byte-identical (pinned, frozen copies); `keys` and `poolLoose` are
additive with defaults; no Mac file changed. Its suites over these reads are group (iii) below (PENDING).

#### VX-618 — not closed

The phone's Library half of "autosave's full-record updates wake every observation" is answered by holding nothing while
hidden, not by narrowing the region; the Mac's sidebar listing and every mounted editor's projection still wake at
autosave rate. The ticket stays open for its own road (the operations seam).

#### Merging with VM-55 (wings underneath) — where a hand is needed

- `MobileLibraryViewModel.swift`: VM-55 rewrote `startAll`/`startBookless` around `MobileWingScope.follow` with
  `wingID: wing`, and routed `lastError` through `MobileLine` / `OpsRefusalCopy`. Take THIS batch's listing section
  whole; DROP the `follow` wrapper around the listings (the hold key already restarts on a wing change — `Question.wing`
  is `session.wing.readScope`, which VM-55 makes the current wing on the phone, and reading it in the view's body tracks
  it); KEEP VM-55's `lastError` didSet and map this batch's `lastError = String(describing: error)` lines to
  `OpsRefusalCopy.sentence(for: error, roads: .phone)`; keep VM-55's `wingID` and search re-key.
- `MobileLibraryView.swift`: both add a stored property (`wingName` after `tokens`; `isOnScreen` after `onOpenArchive`)
  and both edit the task block — keep both.
- `MobileShellView.swift`: both add an argument to the `MobileLibraryView(…)` call — keep both.
- `MobileHerPathsPerfTests` is this run's only; VM-55 does not touch Core's `LibraryPaging.swift` / `ShelfQueries.swift`.

#### PROVISIONAL and design calls (options weighed; the built one first)

- **P-68-1 — the page is 200** (the phone's window before paging, so the resting listing is byte-for-byte what it was;
  fewer landings) · the Mac's 80, growing to 1,280 (a smaller held page; a visible change at rest).
- **P-68-2 — stand down and re-ask on return** (built) · a constant-region "dirty" trigger held while hidden (still wakes
  at autosave rate — VX-618 — and shows nothing sooner) · the listed depth held while on screen (∝ the depth per write).
- **P-68-3 — "on screen" is drawn-at-all (a band drag's reveal counts) and at the stack's root** (built) · the current
  tab only (a drag would reveal pre-return rows for the whole drag).
- **P-68-4 — in All, a book older than the last listed note waits until the notes around it are read** (built — the
  rows are always the true head of the union; nothing jumps) · show every book at once (older books sit at the listing's
  end and move up as pages land) · page the books too (no read pages them; they are author-scale).
- **P-68-5 — no face for paging** (built — the rows continue, the Mac's precedent; brief item 6) · a quiet "Loading…"
  row at the foot (new copy).
- **P-68-6 — the Bookless door says nothing until its first answer** (built — no false empty line on the first switch)
  · speak at once (a flash of "No bookless notes…" before the rows).
- **P-68-7 — the scraps listing stands down while hidden too** (built — "the hidden Library does not work") · leave it
  held while its filter shows.

#### For QUESTIONS at the merge (the orchestrator carries these to `notes/QUESTIONS.md`)

1. **P-68-4 — books in a paged All:** withheld until the notes around them are read (built) · all at once · paged. Hers
   only if she sees it; it is what makes the union honest under paging.
2. **P-68-5 — paging has no face** (built) · a quiet foot row (would need her words).
3. **P-68-1 — the page size, 200** (built) · the Mac's 80-and-growing.

#### The stage window (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Products: `App/Variorum/DerivedData/vm64-b5/` (phone + Mac, the fix) and `App/Variorum/DerivedData/vm64-b5-red/` (phone,
the five Shell files at base `35a3bea7a`, without `MobileLibraryPagingRulesTests`), both built on the merged tree at
`dcea98cee` (main merged at `d893fae63`). Batch 1's machinery note applies: poll for the Swift Testing verdict line,
not `** TEST EXECUTE **`. Every phone group is its own invocation (the perf suite reads the process's one recorder).

**Group (i) — the perf suite ALONE, fix build: the after-numbers and the new assertions.**
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileHerPathsPerfTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b5 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-b5-i>
grep -E '^VM64-(PERF|PLAN)\|' <log-b5-i>
```
Expected: 10 tests green. `typingInTheBoxWakesTheOffScreenLibrary` with its four box-save series at 0 (asserted),
`library-return-rereads` 1 each (recorded), the four fetch series (the two pre-VM-68 queries kept, and
`library-page-fetch-ninewings` / `bookless-page-fetch-ninewings`) and the `VM64-PLAN|notes-page-ninewings|…` /
`|bookless-page-ninewings|…` lines; `typingInANoteOpenedFromTheLibraryLeavesTheLibraryAlone` with its two series at 0
(asserted). Every other series as batch 3/4's (batch 5 does not touch them; the Library opens no longer wait behind a
held Library, so their durations may move a little).

**Group (ii) — the two paging suites, fix build.**
```
tests=(MobileLibraryPagingTests MobileLibraryPagingRulesTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b5 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Expected: all green — 3 + 9 tests (the sort pin runs four cases).

**Group (iii) — `MobileLibraryPagingTests` on the RED build (the red-on-old).**
```
tests=(MobileLibraryPagingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b5-red \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Expected: **`theTwoHundredAndFirstNoteIsReachableByScrolling` RED** (notes 029…000 never on screen — the 200 cut) and
**`theBooklessDoorListsEveryLooseNote` RED** (the seven oldest loose notes never on screen — `poolPosts(limit: 5)`);
`aNoteMintedWhileTheLibraryIsAwayIsListedWhenSheReturns` GREEN (the guard).

**Group (iv) — the perf suite ALONE on the RED build** (settles the covered-Library pin's question; the box-save zeros'
red is already on record as the BEFORE table's 2 · 2 · 1 · 1):
```
tests=(MobileHerPathsPerfTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b5-red \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-b5-iv>
grep -E '^VM64-PERF\|library-' <log-b5-iv>
```
Expected: `typingInTheBoxWakesTheOffScreenLibrary` RED on its four zeros (2 · 2 · 1 · 1, as before);
`typingInANoteOpenedFromTheLibraryLeavesTheLibraryAlone` RED if SwiftUI kept the covered root's tasks alive under a push
(then it is a bug pin), GREEN if it already stood them down (then the row is HOLLOW for the covered case — recorded, and
the shell's `libraryPath.isEmpty` term is a stated belt); `library-return-rereads` reads 0 (the old listing was held).

**Group (v) — the phone suites the Shell changes could disturb, fix build:**
```
tests=(MobileLibraryTests MobileLibrarySortTests MobileFilterTests MobileFilterRowGeometryTests MobileEmptyStoreTests
  MobileDeletionTests MobileTrashTests MobileScrapsTests MobileStarsTests MobileShellTests MobileNavigationTests
  MobileLivenessTests MobileShelfPerfTests MobileShelfLayoutBrainTests MobileShelfRenderedLayoutTests
  MobileShelfTodayDoorTests MobileQuickNoteTests MobileQuickNoteReadFailureTests MobileSavepointOnLeavingTests
  MobileWalkTests MobileTutorialLibraryWalkTests MobilePerfFixtureTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b5 \
  ${tests/#/-only-testing:VariorumMobileTests/}
```
Expected: all green. (The orchestrator's caveat holds for reading it: VX-980's Core changes have not yet met a hosted
phone run, so a red in a listing, filter, tag or Trash suite that does not tie to this diff may be main's.)

**Group (vi) — the Mac suites over the Core reads this batch touched** (`LibraryPaging.swift` — the catalog's pages;
`ShelfQueries.swift` — the Pool):
```
tests=(LibraryPagingModelTests LibraryInfiniteScrollTests VX384LibraryFollowsMintsTests VX408ListingRaceTests
  LibraryReturnPlaceTests LibraryReturnRoadTests LibraryTagListingTests LibrarySearchOrderTests PoolPageTests
  PoolTuckFaceTests PoolCardPreviewTests VX385PoolQuietReceiptTests LaunchFurnitureTests MembershipChoiceTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath DerivedData/vm64-b5 ${tests/#/-only-testing:VariorumTests/}
```
Expected: all green — the Mac's two statements are byte-identical (pinned headless), so nothing it runs changed.

**Group (vii) — the walk (the batch's use-shaped evidence; the orchestrator's hands or a GO to me).** The Debug app on a
dev-store simulator, signed out: seed more than 200 notes (Settings ▸ "Seed the 100k fixture" gives the 300-note corpus),
open the Library, scroll to the end — the oldest notes come on screen (capture: the listing's foot past note 200); type
in the capture box, swipe to the Library — the box's note leads (capture); Bookless shows the loose notes (capture);
Settings ▸ timing… after the walk — "Library re-reads per save" holds no new non-zero samples from the box's saves.

### Batch 6 · VM-69 · VM-70 — a note is read once, and released when it closes (implementer closeout)

**Not done in this batch (first, by the record's rule):** every hosted run is PENDING the orchestrator's stage window —
the perf suite's five asserted series (fix and red), the new suites (fix and red), the editor and Write suites in company,
and the walk with its captures (groups (i)–(iv) below, runnable from the built products by anyone). The AFTER durations
(`note-open-to-live-*`, `shell-box-open-to-live`, …) therefore have no numbers yet. No headless suite reaches this batch:
no Core, `Shared/` or `Sync/` file changed (so no `swift test` and no Mac build was owed — the Mac compiles none of the
four changed files).

**Base:** `d893fae63` (main's VX-980 merged in). **Commits:** `f0e2e696c` (the midpoint review's finding 1 — the fence's
projection-seam comment, alone, "Part of VM-2") · `1423defca` (live status) · `c8f95ea6f` (the INSTRUMENT: the projection
road's chrome passes counted, no behaviour change — the red-on-old base) · `63ad8b188` (VM-69: one read; the chrome once)
· `9ad4a880d` (VM-70: the release) · `3d43fe52e` (the chips) · `68d630d96` (the perf suite's assertions) · `24fa9a5e2` (the
new suites; the fix products `vm64-b6` are this tree) · `5608b7e52` / `7770b4fb5` (the red-on-old revert announced, built,
restored) · this closeout.

#### The midpoint review's finding 1 (the first commit)

`MobileEditorViewModel.applyProjection`'s settling hook said the drain "replays her keys through the input road" — r1's
mechanism, removed whole at r2. Reworded to r2's truth (comment only, no pin): the drain only REPORTS — it lowers the
fence and, if anything was refused or withheld, says the one sentence through `report` (the status line and its action);
deferring keeps those status/undo writes out of a projection apply and reads the settle rule after the apply's own
bookkeeping. Read against r2's closeout ("the drain's one sentence") and `drainFlightFence()` before writing it.

#### The mechanisms, as traced on this tree (audit F 2C/2D, §4, §12.4; audit C §2.16 — TRACED as written, lines moved)

- **Two whole-note reads per open (VM-69).** The screen's `.task` registers (`MobileLivenessAuthority.takeLiveness(refresh:
  false)`: the flush, one indexed header read), then `arrive` → `loadOnce` (projection + header, one read), then `start()`,
  whose two `ValueObservation`s each begin with a FIRST FETCH — the header again, and the WHOLE projection again — and
  deliver it (`ingest(fromDelivery: true)` → `ledger.matches` O(note) → `.adoptEcho` → a `.document` chrome pass). The
  BEFORE table: `*-note-reads-per-open-*` 2 in every run, five series.
- **The chrome three times (VM-69).** Per open, `renderFull` laid the chrome out as its last act; `ingest` then laid it
  out again over the same inputs (`takes.adoptFans` and `presentations` are adopted BEFORE the apply); the first delivery's
  `ingest` a third time. Each pass is O(the note's decorated blocks) once the page has width (`refreshChrome` →
  `blockRangesByID` + both controllers; `.ensuresLayout` per fanned block).
- **The registry grows by one per note opened (VM-70).** The editor acquires the post's coordinator at `init`
  (`session.autosave(forPost:)`); nothing on the phone ever released an editor's (`releaseAutosave`'s one phone caller is
  the quick note). The BEFORE table: growth 1 per open-and-close. Every filing (`flushEveryOpenPost`), every sync round's
  flush-first (`flushPendingTypingBeforeRound` → `hasPendingAutosave`) and every background flush walked them all.
- **The chips read every book and every tag (VM-69).** The books and tags chips' mount tasks called the SHEETS' full
  `refresh()` — `Queries.readings(db)` (every book, for "Add to a book") and `Queries.allTags(db)` (every tag, for the
  suggestions) — at every open, though the masthead shows only the note's own rows; both sheets already re-read on appear
  (their own `.task { refresh() }`). References already read only the note's rows.
- **The twin graph (audit F 2D / audit C §2.16) is NOT on these roads:** `*-editor-builds-per-open` read 1 in every BEFORE
  run. Nothing to fix; it is now an asserted guard (and the release at the model's end of life covers a twin anyway — a
  discarded twin acquires, then releases at its death).

#### What shipped, file by file

- `VariorumMobile/Features/Write/MobileEditorViewModel.swift` (the editor seam):
  - **`loadLive()`** — the arrival's ONE read: both live observations start (`observeContainerHeader`, the counted
    `takesObservation()`), their first values are the load (header adopted, then the projection through `ingest` —
    `loadOnce`'s order), the running iterators are kept in `liveHeader` / `liveTakes`, and VM-65's
    `noteProjectionDelivered(first: true)` marks the live updates' first delivery at its true moment (this one). A
    re-arrival (`loaded` already true) takes its first value as a DELIVERY (MAJOR 3's signal arm). A failure falls back to
    `loadOnce()` (which speaks as it always did); a cancellation paints nothing. `arrive` calls it instead of `loadOnce`.
  - **`observeHeader` / `observeTakesProjection`** continue the arrival's iterators (`next(isolation: #isolation)`, on the
    main actor as the old `for try await` ran), or start their own when no arrival preceded (`loadOnce` + `start` — the
    harness's road, unchanged). `takesObservation()` is the one home of the counted fetch.
  - **`loadOnce()`** unchanged (the harness's and the fallback's road).
  - **The chrome once** — `layOutChrome()` (counted: `projectionChromePasses`, the instrument) is the projection road's one
    whole-document pass; `renderFull` and `applyDifferential` call it as their last act, and `ingest` calls it only when
    the arm did not (`chromeLaidOutByApply`).
  - **`isolated deinit { session.releaseAutosave(forPost: postID) }`** — the one release for the one acquisition.
  - The finding-1 comment.
- `VariorumMobile/Features/Write/MobileMembership.swift` — `refreshChip()`: `Queries.readingsContaining` only, ordered by
  the same `ordered`; cancellation silent; any other failure falls back to `refresh()`. `refresh()` untouched.
- `VariorumMobile/Features/Write/MobileNoteTags.swift` — `refreshChip()`: `Queries.postTags` only; the same fallbacks.
  `refresh()` untouched.
- `VariorumMobile/Features/Write/MobileWriteView.swift` — the books and tags chips' `.task(id:)` call `refreshChip()`.
  Nothing else in the screen changed (the `.task` wiring — register, arrive, start — is byte-identical).
- `VariorumMobileTests/MobileHerPathsPerfTests.swift` — five series asserted (below); `MountedBuilt` (a screen built
  inside the gate's body, as the shell's destination builds it) for the registry series only; the header notes it.
- `VariorumMobileTests/MobileNoteOpenOnceTests.swift` (new, 6) and `VariorumMobileTests/MobileChipScopeTests.swift` (new,
  3).

#### Round trips per open, before → after (the brief's "no redundant round trips")

| Step | Before | After |
|---|---|---|
| Liveness grant (register) | flush + header read | unchanged — the authority's pen precondition, read after the flush |
| Arrival | `loadOnce`: projection + header (1 trip) | the two observations' first reads, concurrent (header · projection) |
| Live updates' start | header read + WHOLE projection read (2 trips) | none — the arrival's observations continue |
| Chips | 3 concurrent: books (feed + EVERY BOOK), tags (note's + EVERY TAG), references | 3 concurrent: books (feed), tags (note's), references |

Whole-note reads 2 → 1; header reads 3 → 2; serial trips before the first paint unchanged (liveness, then the load); the
trips after the paint 5 → 3. **Not removed, and why:** the liveness grant's header read and the header observation's first
read both read the one header row — the first is the authority's precondition for handing over the pen (after the flush,
before the grant; 4.5c's MAJOR 1/2 rule that every refusal is store-confirmed), the second is the start of the live header
GRDB cannot begin without a fetch. Folding them would move the authority's grant after the arrival — a liveness design
change, not this unit's (recorded as an option below). The books chip's own feed (`readingsContaining`, the Mac chip's
read, Core, byte-identical) lists the readings once internally to test each gathering's rule — author-scale; narrowing it
is a Core change both platforms share (option below).

#### The chrome's three layout passes — what they become

**One per open.** (1) `renderFull`'s — KEPT: the render replaced every character and every range on the page, so the
fans' badges and pill anchors, the gutter's comment marks and the callout frames must be placed on the new page, and
they cannot be placed before the page exists. (2) `ingest`'s second pass over the same inputs — GONE (`chromeLaidOutByApply`).
(3) The first delivery's — GONE with the second read. Untouched and still needed: the arms that rewrite nothing in the
view (an echo, a deferral, a refetch) still get `ingest`'s pass — a take can arrive without a byte of text moving (pinned:
a branched take's delivery lays the chrome out); the text view's own `.nearViewport` passes (`layoutSubviews`) and the
width-change escalation inside the controllers are how the chrome follows scrolling and the first real layout — not
projection-road passes, unchanged; `installTakes`' pass at attach runs over an empty page. Side effect of the same
mechanism, stated: a DIFFERENTIAL delivery (a remote text change) now lays the chrome out once, not twice.

#### The hazards — each with its traced mechanism and its pin

**(a) A remote change between the one load and the live updates' first delivery still reaches the page.** There is no
longer a "between": the load IS the live observation's first value. What remains is the window inside GRDB between an
observation's first fetch and its tracking start, and GRDB closes it by contract: on a POOL (her phone's store) the first
fetch runs on a reader inside a WAL-snapshot transaction, then the observation takes the WRITER, compares the snapshot with
the writer's and — if anything committed — fetches again and notifies, and only then (same writer access) adds its
transaction observer, so no commit can fall between the compare and the tracking start
(`.build/checkouts/GRDB.swift/GRDB/ValueObservation/Observers/ValueConcurrentObserver.swift`, `asyncStartObservation`;
without a snapshot it refetches unconditionally); on a queue the first fetch and the tracking start are one writer access.
The values wait in the stream (unbounded buffering) until `start()` takes the iterator — same main actor, same `.task`,
nothing between `arrive` returning and `start()` beginning. A delivery is ingested as a signal (`refetchFresh` → the fresh
read → `.differential`). **Pin:** `MobileNoteOpenOnceTests.aWriteLandingAfterTheOpensOneReadReachesThePage` — an on-disk
encrypted POOL; a write HOLDS the writer and commits a change only after the arrival painted the old text; the page must
end on the change. A guard: green on both trees (the old second read covered the same window the same way).

**(b) The release never drops unsaved text, never races the leaving savepoint, never takes a coordinator another holder
needs.** **[r1: FALSIFIED by the first stage window — in a live host the editor OUTLIVES its leaving work (the three
release pins red on both builds); the release moved into the leaving work. See "Iteration r1" below. The text that
follows is kept as written.]** Mechanism: the release is the model's `isolated deinit`, and the model's last strong reference on the leaving road
is the screen's `onDisappear` task, which holds it across `teardown()` (the canary, the gesture task, `finish()`: the tail
mint and the flush) and `savepointOnLeaving` (which flushes the EXISTING coordinator again, then `closeAutoCommit`) — so the
release comes after both, by construction (the Mac's 18k C1 shape, `EditorViewModel`'s own `isolated deinit`). The session's
phone rule (`releaseAutosave`, `Shared/AppSession.swift`, unchanged) drops the entry only at ZERO holders and a CLEAN
coordinator: a second tab's editor on the same note holds its own acquisition; the quick note holds its own (adopt) and
releases its own (reset); a coordinator left dirty (a refused write) stays reachable to every flush walk. The lock road:
`mobileWillLock` runs `editors.flushAll()` and the savepoints while every model is alive and holding; then the state flip
removes the tree, each screen's `onDisappear` runs (unchanged — batch 7's), and each model releases into the OLD session
afterwards — so every flush walk on that road still reaches every coordinator that could hold text. A covered screen (a
push on top) keeps its model and its hold: the deinit is the only point that runs exactly once per acquisition (a covered
screen can be torn down and shown again). **Pins** (`MobileNoteOpenOnceTests`): `closingANoteLandsItsTextThenGivesItsCoordinatorBack`
(a key in the debounce at the close lands, the savepoint lands, the registry is back — red on the pre-fix tree on the
give-back); `theReleaseWaitsForTheLeavingSavepoint` (the writer held as the note closes: the entry stays held while the
leaving work waits, and goes only after it lands — red on the pre-fix tree on the give-back; a release at the close itself
would be red on the hold); `aCoordinatorAnotherHolderNeedsIsNeverLetGo` (two tabs on one note, then the quick note's hold:
each close gives back one hold, the entry stays while anyone holds it, the remaining editor records into the registry's
coordinator — red on the pre-fix tree). And the perf suite's registry series, asserted zero.

**(c) A stood-down editor on another tab keeps working; `takeLiveness(refresh:)` still gets a current page.** Unchanged
mechanisms, re-read after the change: a stood-down editor's live updates run for its life (`start()` never consults
liveness), so a write anywhere reaches its page (delivery → refetch → `.differential`; with a shared coordinator dirty from
the live tab's typing it defers, and the coordinator's settle — every observer's `onSettled` — re-reads it); the tab
switch's grant (flush → header confirm → `refreshTakesFromStore`, a fresh read through the one projection door) is
untouched; the one change on that road is `ingest`'s chrome rule, which only drops a duplicate pass. **Pin:**
`aStoodDownEditorKeepsWorkingAndTheTabSwitchGetsACurrentPage` — two tab stacks on one note through the real screens (both
arrived through the one read): the live tab's typing reaches the stood-down page; the tab switch moves the pen over a
current page; the other direction too. A guard: green on both trees.

**(d) The chips' scoped reads show exactly what the full reads showed.** The chip reads ARE the full reads' own
statements for what the chip shows — `readingsContaining` then the same `ordered`; `postTags` — so the rows, their order
and every field (the archived stamp included) are the same values; only the sheet's every-book / every-tag listings are no
longer read by the chip, and the sheets read them on appear exactly as before. A failure falls back to `refresh()`.
**Pins:** `MobileChipScopeTests` (3 — a note in two books, one ARCHIVED, and a gathering; books and a gathering it is not
in; three tags, two worn; a reference: the same ids, order, names, kinds and archived state, the same chip words; the
chip's sheet lists unread, the full read's still filled); and the red-on-old one,
`MobileNoteOpenOnceTests.openingANoteReadsNoListingOfEveryBookOrEveryTag` (the store's statement trace over the real
screen's open: no every-tag listing, and no every-book listing beyond the feed's own — on the pre-fix tree one of each
more).

#### The keystroke fence still means the same thing (batch 2's conditions, read after this change)

`flightSurfaceHoldsTheStore` is `!forceFullRender && pendingProjection == nil`, and `settleFlightSurface` re-reads through
`awaitMintSettle` + `refreshTakesFromStore`; this batch touches neither flag's writers nor that road. The settling hook in
`applyProjection` is unchanged (only its comment, finding 1). `ingest`'s new rule decides only whether `layOutChrome` runs —
no flag the fence reads. The arrival's change cannot meet a flight: no structural door is reachable before the page has
rendered, and the latch is down at arrival. On a RE-arrival the first value now takes the delivery arm: if it does not
match the page it parks as `pendingProjection` until the fresh read applies it — so a fence that were settling then would
keep failing CLOSED until the page holds the store, which is the fence's own rule ("the page holds the store" means the
same thing). `flushPendingText`'s fence re-read is untouched. **`storageDidEdit`, `fallbackVerdict` and `EditorEditRouting`
are not touched** (VM-78's VM-24 question stays theirs); `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePoint…`
is expected in main's shape (2 of 3 cases, 2 issues) — this batch changes no routing.

#### The pins, and what each build should show

| Pin | Fix (`vm64-b6`) | Pre-fix (`vm64-b6-red`) | Kind |
|---|---|---|---|
| perf `aNoteOpensOnTheRealScreen…` — `note-reads-per-open-{short,100k}` == 1 | green | RED (2, both) | VM-69 product |
| perf `theCaptureBoxOpensItsNoteThroughTheShellsPush` — reads == 1; builds == 1 | green | RED on reads (2); builds green | VM-69 product + twin guard |
| perf `aLibraryRowOpensItsNoteThroughTheShellsPush` — reads == 1 (short, 100k); builds == 1 | green | RED on reads (2, both); builds green | VM-69 product + twin guard |
| perf `theAutosaveRegistryAcrossOpensAndCloses` — growth == 0 | green | RED (1) | VM-70 product |
| perf, the other five tests | green, unchanged | green | — |
| `anOpenAsksForTheWholeDocumentChromeOnce` | green (1) | RED (3); the branched-take guard green | VM-69 product |
| `openingANoteReadsNoListingOfEveryBookOrEveryTag` | green | RED (one every-tag listing; two every-book listings for one feed) | VM-69 product |
| `aWriteLandingAfterTheOpensOneReadReachesThePage` | green | green | hazard (a) guard |
| `closingANoteLandsItsTextThenGivesItsCoordinatorBack` | green | RED on the give-back; text + savepoint green | VM-70 product **[r1: FALSIFIED — red on the fix build too]** |
| `theReleaseWaitsForTheLeavingSavepoint` | green | RED on the give-back; the hold green | VM-70 product (ordering) **[r1: FALSIFIED — red on the fix build too]** |
| `aCoordinatorAnotherHolderNeedsIsNeverLetGo` | green | RED (holds never given back) | VM-70 product **[r1: FALSIFIED — red on the fix build too]** |
| `aStoodDownEditorKeepsWorkingAndTheTabSwitchGetsACurrentPage` | green | green | hazard (c) guard |
| `MobileChipScopeTests` (3) | green | not built (names the new reads) | hazard (d) guard |

Row dispositions: **VM-69 — FIXED** (one read; the chrome once; the chips' reads) with the red-on-old pins above. **VM-70 —
FIXED** with its pins. **The twin (audit F 2D / audit C §2.16) — DISMISSED AS HOLLOW on today's roads** (builds per open 1
in every BEFORE run, the box's and the Library's), held by an asserted guard; the release-at-death closes the leak class a
twin would leave, should one ever be built.

#### The timing marks (batch 1's) — what they measure now (said, per the record's rule)

`noteReadsPerOpen` still counts whole-note reads from the arrival to the live updates' first delivery; the first delivery
is now the arrival's own (the observation's first value — `noteProjectionDelivered(first: true)` is called there), so the
window closes after ONE read. `noteProjectionLoad` now marks only `loadOnce` (the harness's and the failure fallback's
road); the screen's read is the observation's counted fetch. `note-open-to-live-*` / `shell-box-open-to-live` (the test's
clocks) end at that same first delivery, so they now end at the arrival's ingest — the second read's cost leaves them.
Nothing else moved.

#### The Mac does not change in behaviour

No `Shared/`, Core or `Sync/` file changed; the four changed production files are phone-only (`VariorumMobile/`). The
phone's release goes through `AppSession.releaseAutosave`'s existing phone branch; the Mac's branch and its 18k C1 drop are
untouched.

#### Merging with VM-78 and VM-55 — where a hand is needed

Read from `origin/vm-78-fixes-to-whats-there` and `origin/vm-55-wings-underneath` against their merge-bases; nothing merged
or cherry-picked.
- **VM-78** adds the observed `entryDate` mirror, set in `adoptHeader`, and the date chip reads it. This batch keeps
  `adoptHeader` the one header door — `loadLive` and the continued header observation both adopt through it — so the
  mirror is set at the arrival before the first ingest, as with `loadOnce`. VM-78's `dateChip` lines and this batch's chip
  `.task` lines are separate hunks; its `MobileMembership` row statics land before `// MARK: - Reads`, this batch's
  `refreshChip()` after `refresh()`. Expected clean.
- **VM-55** rewrites the catch lines of `loadOnce`, `observeHeader` and `observeTakesProjection` (raw error dumps →
  `report(OpsRefusalCopy.sentence…)`), and the `refresh()` bodies of the books and tags models (wing-scoped listings,
  `say(…)`). This batch's hunks sit beside those with unchanged lines between, and its new code carries NO error words of
  its own: `loadLive` falls back to `loadOnce` and `refreshChip` to `refresh()`, so VM-55's wording rules reach every
  failure here once merged. The chip reads need no wing (`readingsContaining` and `postTags` are note-scoped); the
  sheets' `refresh()` takes VM-55's wing scope as written. **If git conflicts**, it will be at `refresh()`'s closing
  lines in `MobileMembership` / `MobileNoteTags` or at the observation loops' last lines: keep VM-55's bodies and catch
  lines AND this batch's loop heads and `refreshChip()` — they do not overlap in meaning. The red-on-old chips pin matches
  the listings by their SQL prefix, which VM-55's wing-scoped forms share, so it stays meaningful after the merge.

#### Residuals (traced, not fixed here — owners for the orchestrator to assign)

1. **A covered screen loses its autosave observer.** `onDisappear` runs `teardown()`, which calls
   `autosave.stopObserving(autosaveToken)`; if the screen was only COVERED (Versions or a diverged copy pushed on its
   stack) and is shown again, `.task` re-runs register → arrive → start, and nothing re-observes — so on that page a flush
   settle no longer bumps `storeWriteGeneration` or calls `applyPendingIfClean`, and the autosave's `onError` no longer
   reaches the status line. A delivery deferred while she types then waits for the next clean delivery; a fence settling
   there fails closed until then. Traced by reading; whether SwiftUI's NavigationStack fires `onDisappear` on a covered
   destination was not measured here. Pre-existing; outside this unit (it is the leaving road's, batch 7's area, or the
   Writing umbrella's). Proposed: a VM ticket with a hosted pin (push Versions, pop, type, a remote change).
2. **A coordinator left dirty at its last release stays forever** (the phone's `releaseAutosave` keeps it and nothing
   later drops it once it lands). Pre-existing rule, rare (a refused write at leaving), bounded by such notes. Not changed.
3. **The arrival's two header reads** (the liveness grant's, the header observation's first) — options in "Design calls".
4. **`readingsContaining`'s internal every-reading listing** (the gatherings' rule leg) — options in "Design calls".

#### Design calls (options weighed; none is a product decision, none is hers)

- **D-6-1 — how the open reads once.** (a) **built:** the arrival starts the live observations and their first values
  are the load; `start()` continues them. (b) keep `loadOnce` and start the live updates with a change-signal
  (`DatabaseRegionObservation`, no first fetch) established BEFORE the load — also one read, but the delivery road changes
  shape (signal-then-fetch everywhere) and the observation must be started before the flush's write. (c) keep both reads
  and only suppress the second's delivery — saves nothing that matters. (a) changes the least and leans on GRDB's
  documented no-missed-change contract.
- **D-6-2 — a re-arrival's first value as a delivery.** (a) **built:** the second read that used to follow a re-arrival's
  load is gone, so its value is a signal (adopted when the page holds it, else settled by the fresh-read road); (b) treat
  it as `loadOnce`'s was (authoritative, may rewrite at once) — would drop the healing the old second read happened to give
  when a settle landed between the read and its use.
- **D-6-3 — where the release lives.** **[r1: SUPERSEDED — see "Iteration r1" ▸ D-6-3r1.]** (a) **built:** the model's `isolated deinit` (the Mac's 18k C1 shape; exactly once
  per acquisition; after the leaving work by construction); (b) the end of `onDisappear`'s task — wrong for a covered
  screen that comes back (its model would keep recording into a coordinator the registry no longer holds, and a second
  tab would mint a twin coordinator — the S3 BLOCKER's class); (c) a new `AppSession` hook — unnecessary, and in VM-55's
  file.
- **D-6-4 — the chips.** (a) **built:** a chip read per chip (what it shows), the sheets' full reads unchanged on appear;
  (b) one combined chip read for all three chips (one trip instead of three concurrent ones — a composition change across
  three models); (c) narrow `readingsContaining`'s gathering leg in Core (both platforms' read; author-scale gain).
- **D-6-5 — the arrival's header reads.** Not built: (a) let the register road skip its header confirm and take the
  arrival's header first value as the liveness answer (moves the pen grant after the load — the authority's ruled order);
  (b) keep (today).
- **D-6-6 — the chrome once by a flag set inside `layOutChrome`** rather than a return value from `applyProjection`
  (whose direct callers and pins would all change shape).

#### For QUESTIONS at the merge

None — no product behaviour was decided here; the design calls above are engineering and are for the cold review.

#### The stage window (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Products: fix `App/Variorum/DerivedData/vm64-b6/` (built at `24fa9a5e2`), pre-fix `App/Variorum/DerivedData/vm64-b6-red/`
(the four Write files at the instrument commit `c8f95ea6f`; `MobileChipScopeTests` absent). If `vm64-b6-red` is ever lost,
rebuild it by: `git checkout c8f95ea6f -- App/Variorum/VariorumMobile/Features/Write/{MobileEditorViewModel,MobileMembership,MobileNoteTags,MobileWriteView}.swift`,
move `App/Variorum/VariorumMobileTests/MobileChipScopeTests.swift` out of the folder, `build-for-testing` into
`DerivedData/vm64-b6-red`, then `git checkout HEAD --` the four files and move the suite back.

**Group (i) — the perf suite ALONE, fix build, twice** (it reads the process's one timing recorder):
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6 \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests 2>&1 | tee <log-b6-perf-1>
grep '^VM64-PERF|' <log-b6-perf-1>
```
Expected: 9 tests pass; `*-note-reads-per-open-*` 1 (five series); `*-editor-builds-per-open*` 1; registry growth 0;
batch 5's four box-save zeros unchanged. The AFTER durations for §5's table come from these two runs.

**Group (ii) — the pre-fix build, each suite ALONE:**
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6-red \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests 2>&1 | tee <log-b6-red-perf>
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6-red \
  -only-testing:VariorumMobileTests/MobileNoteOpenOnceTests 2>&1 | tee <log-b6-red-once>
```
Expected: perf — RED `aNoteOpensOnTheRealScreen…` (reads 2, both notes), `theCaptureBoxOpens…` (reads 2),
`aLibraryRowOpens…` (reads 2, both), `theAutosaveRegistry…` (growth 1); the other five green. OpenOnce — RED
`anOpenAsksForTheWholeDocumentChromeOnce` (3), `openingANoteReadsNoListing…`, `closingANote…`, `theReleaseWaits…`,
`aCoordinatorAnotherHolder…`; GREEN `aWriteLandingAfter…` and `aStoodDownEditor…` (the guards). The give-back pins wait
10 s for a release that never comes on this build — slow, by design.

**Group (iii) — the batch's suites with the editor and Write suites, fix build, ONE invocation:**
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileNoteOpenOnceTests MobileChipScopeTests
  MobileStructuralFlightFenceTests MobileStructuralTests MobileSelectionActsTests
  MobileEditorMaterializationTests MobileCanaryTests MobileEditorRoutingTests MobileEditorCrystallizationTests
  MobileEditorProjectionTests MobileTypewriterRoomTests MobileNoteSealTests MobileFindInNoteTests
  MobileEditRoutingBindingTests MobileIdentityAuditSeparatorTests MobileBulkArmingTests MobileCanaryTeardownTests
  MobileEditRoutingCrashTests MobileEditRouteArmsTests MobileWholeBlockDeleteBrainTests MobileWholeBlockDeleteTests
  MobileCrossBlockEditBrainTests MobileCrossBlockEditTests MobileMarkdownRenderTests MobileMarkdownReturnTests
  MobileMarkdownActsTests MobileCheckboxTapTests MobileMarkdownCaretTests MobileTakesTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileTakesChromeTests MobileTakeReorderTests MobileTakeToBlockTests
  MobileTakeLockTests MobileUndoDoorTests MobileBlockMenuTests MobileCommentsTests MobileBlockDecorTests
  MobileWalkTests MobileTrailingNewlinesTests MobileSpaceEaterTests MobileCRLFCaptureTests
  MobileWriteScrollAuthorityTests MobileScrollAuthorityBrainTests MobileLivenessTests
  MobileDeferredProjectionRetryTests MobileTypedOverRescueTests MobileEditTraceTests MobileKeyDoorPostureTests
  MobileSavepointOnLeavingTests
  MobileMembershipTests MobileNoteTagsTests MobileNoteRenameTests MobileNoteEntryDateTests MobileReferencesTests
  MobileTagManagerTests MobileBlockListTests MobileBlockSelectionTests MobileNoteTrayTests MobileDeletionTests
  MobileTrashTests MobileVersionsTests MobileNavigationTests MobileShellTests MobileMenuVocabularyTests
  MobileRefusalTableTests MobileQuickNoteTests MobileQuickNoteUnderLockTests MobileLockTeardownTests
  MobileRelockCoordinatorTests MobileRelockPolicyTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-b6-company>
```
Expected: all green but VM-24's standing `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePoint…` in main's
shape (2 of 3 cases, 2 issues). Optional, heavier: `MobilePerfWalkTests` (it opens through `loadOnce`, unchanged).

**Group (iv) — the walk (the batch's use-shaped evidence; the orchestrator's hands or a GO to me).** The Debug app on a
dev-store simulator, signed out, never Resume; both voices for the masthead. (1) Settings ▸ "Seed the 100k fixture" if the
store is empty; open a short note from the Library, back; open "the long haul", back; open the short note again — capture
the masthead with its chips (Study), then switch the voice to Terminal in Settings and capture the same masthead
(`b6-chips-study.png`, `b6-chips-terminal.png`). (2) Tap the books chip: the sheet opens with "Add to a book" listed
(capture `b6-books-sheet.png`); Done; tap the tags chip: suggestions listed (capture `b6-tags-sheet.png`). (3) Type a word
in the note, go back at once — the word is in the note when reopened (capture `b6-reopened.png`). (4) Settings ▸ timing… —
the "Note reads per open" row reads 1 across its samples (capture `b6-readout.png`). Screens go to
`notes/plans/vm64-screens/` (gitignored). What it leaves on the device: the seeded fixture and one typed word in the short
note.

#### Iteration r1 — the release moves into the leaving work (after the first stage window, 2026-11-19)

**Not done in r1 (first):** every hosted run is PENDING the next window — the note-open suite alone on each r1 build, the
73-type list from the r1 fix build (commands below). The trace's probes are RECORDED lines that window will print.

**What the first window showed** (10:10–10:28; the orchestrator's message and the logs `notes/plans/vm64-screens/b6-*.log`):
the perf suite alone, fix build, twice — 10 of 10 (reads per open 1, editor builds 1, registry growth 0 through
`MountedBuilt`); the 73 types in one host — green but VM-24's standing caret test (main's shape) and three of this
batch's pins; the note-open suite alone — the same three at their 10 s deadlines, the other four green; the red build —
every designed red, and the same three. **`closingANoteLandsItsTextThenGivesItsCoordinatorBack`,
`theReleaseWaitsForTheLeavingSavepoint` and `aCoordinatorAnotherHolderNeedsIsNeverLetGo` were red on BOTH builds** — in
each the typed text and the leaving savepoint landed (those expectations passed), and the editor never released.

**The trace, per pin and for the product** (the full text is §5 batch 6 ▸ "Iteration r1"):
- **Per pin — (A), the harness: the live host keeps the editor.** Every reference our code keeps was read: the
  `onDisappear` task (ended — its savepoint landed), the `.task` and `start()`'s loops (end at the stream's
  cancellation; the iterators hold no model), the liveness authority (`weak`, deregistered), the router (none), the text
  view, gate delegate, storage observer, chrome/decor controllers, pan router and siblings (all `weak`), the crystallizer's
  tasks (transient). What is left is SwiftUI/UIKit's hosting of the removed screen (its `@State`, the representable's
  struct — `MobileWriteView.model`, strong — and the sheet/alert/inset content closures, each capturing the screen value
  whose `State(initialValue:)` stores the editor). The pins' `BuiltScreen` keeps its window and hosting controller until
  the test's `defer`; the perf series' `MountedBuilt` tears its window down and lets its host go BEFORE it waits — the one
  road that released. Which object inside SwiftUI/UIKit holds it is not readable from our side; two RECORDED probes print
  the stage at which the editor is freed (`probeWhenAClosedScreensEditorIsFreed`: after the close, a SwiftUI update, the
  window's teardown, the host's release; `probeAPoppedNotesEditorInTheShell`: the real shell's NavigationStack pop through
  the navigation bar's Back).
- **For the product — (B).** Her shell is a live host for the app's life; a popped destination's state is freed on
  SwiftUI's schedule; no pin on this branch shows that happens promptly, or at all, while the host lives. r0's release
  therefore depended on a deallocation her hands are not shown to cause: **VM-70 was not shown fixed for her road**.
- **The Mac (18k C1) and why its lifetimes are different:** a Mac release only DECREMENTS — the drop is the leaving
  savepoint's (`dropAfterLeaving`), and ⌘Q/the lock savepoint whatever is still held — so a late death there only delays a
  drop (18k measured the deaths on the dev store). On the phone the release IS the drop, so a late or missing death is
  the growth VM-70 measures.

**What changed (r1), file by file:**
- `VariorumMobile/Features/Write/MobileEditorViewModel.swift` — the hold FOLLOWS THE SCREEN:
  `holdsAutosave` (true from `init`'s acquisition), `arrivalCount`; **`takeAutosaveHold()`** — the arrival's first act:
  counts the arrival and, if a leaving gave the hold back, re-acquires through `session.autosave(forPost:)` with the
  editor's own clock; if the registry hands back a DIFFERENT coordinator (the entry dropped clean and was minted again —
  by this call or by another tab's editor of the same note) the editor ADOPTS it (a belt flush of the old one if dirty,
  its observer dropped, `autosave` re-pointed), and in either case ends observing the coordinator it records into (the
  hooks `init` makes; the error hook through `reportOperationError`, so VM-55's wording reaches it). **`releaseAutosaveHold
  (ifNotShownSince:)`** — the leaving's last act: gives the hold back unless the screen arrived again since the leaving
  began. **`deinit`** releases only a hold still held (a twin, a harness model). `autosave` is a `private(set) var`;
  `observesAutosave` for pins. The r0 `deinit` doc is replaced by the r1 one (it says why).
- `VariorumMobile/Features/Write/MobileWriteView.swift` — the `.task` takes the hold first (before the liveness grant's
  flush); `onDisappear` captures `model.arrivalCount`, and its task releases after `savepointOnLeaving`, before the leave's
  timing mark. **The order on every leaving is now explicit and in one task: teardown's flush → the leaving savepoint
  (batch 7's phone branch: its flush, the read, the one runner turn) → the give-back → the mark** — the order batch 7's
  `MobileLeavingSavesOnceTests` reads off the store (it waits for `autosaveHolderCount == 0` as the leaving's end; with
  r0 that wait could only pass by the host's death, with r1 it is the leaving's last act).
- `VariorumMobileTests/MobileNoteOpenOnceTests.swift` — the three pins unchanged in what they assert (their notes say the
  give-back is the leaving's completion and the bound a hang guard); new `anEditorThatNeverArrivedGivesItsHoldBack`; the
  two probes.
- `VariorumMobileTests/MobileNoteHoldTests.swift` (new, 4, names the new API — set aside for the red build): the screen's
  own sequences, deterministic — a re-show after the give-back takes it back and is wired to it; a re-show JOINS the
  coordinator another tab opened meanwhile (one coordinator per note); a re-show before the leaving finished keeps its
  hold (the leaving parked on a held store); the order flush → savepoint → give-back.

**Hazard (b), re-traced for r1.** Never drops unsaved text: the give-back follows `teardown()`'s flush and the leaving
savepoint's own flush in the same task, and the phone's `releaseAutosave` still keeps a DIRTY coordinator whatever the
holders. Never races the savepoint: it is the next statement after `savepointOnLeaving` returns. Never takes a
coordinator another holder needs: holds are counted per holder (a second tab's editor, the quick note) and the entry goes
only at zero. The lock road: `mobileWillLock` flushes and savepoints while every editor holds; the state flip removes the
tree; each screen's `onDisappear` task runs its leaving and gives its hold back into the OLD session — unchanged
(batch 7's) in who asks and when. **New with r1 — the screen shown again:** a destination covered by a push gets
`onDisappear` (its leaving runs and gives the hold back) and, popped back to, a new `.task` (`takeAutosaveHold` takes it
again, adopting the registry's coordinator if the entry was re-minted, so two coordinators for one note cannot stand); a
re-show before the leaving ended keeps the hold (the arrival count). **A residual stays (r0's residual 1, narrowed):**
teardown's `stopObserving` on a covered screen — r1's re-take re-wires the observer whenever a hold was given back;
a re-show that lands BEFORE its leaving's teardown finished keeps the hold and still loses the observer (the teardown's
last line runs after the re-show). Pre-existing; owner as proposed for residual 1.

**The keystroke fence:** untouched by r1 — neither flag the fence reads (`forceFullRender`, `pendingProjection`) is
written by the hold; the re-take may re-point `autosave`, which the fence never reads, and only when the screen arrives
(no structural flight can be in the air before the page is live again).

**The Mac:** no `Shared/` or Core file changed in r1 either; the phone's `releaseAutosave` and the Mac's 18k C1 drop are
untouched.

**Merging (r1's additions):** VM-55 edits the top of `onDisappear` (a `MobileLine` withdraw before the deregister) and
`init`'s `onError` line; r1's lines are the `.task`'s first statements, a capture beside `let leaving`, one call inside
the leaving task, the `autosave` declaration, two assignments after `init`'s acquisition, and the block that replaced the
r0 `deinit` — none overlaps. VM-78 touches none of them.

**D-6-3r1 — where the release lives (supersedes D-6-3).** (a) **built:** the leaving work's last act, and the arrival
takes it back (adopting a re-minted coordinator) — deterministic, no dependence on any deallocation, one release per
acquisition with `deinit` as the remainder; (b) r0's `isolated deinit` alone — falsified for a live host (above); (c) keep
the hold for a COVERED screen and release only for a POPPED one (`isPresented` / a NavigationStack signal) — not readable
reliably from the destination, and unverifiable in process (the pop is not drivable — the probe records whether it is);
(d) an `AppSession` re-adopt hook so a re-show re-inserts its OWN coordinator — avoids the re-point only when no other
tab minted meanwhile, still needs it when one did, and lands in VM-55's file.

**The corrected red-on-old table (r1 products: fix `vm64-b6r1`, pre-fix `vm64-b6r1-red` = the four Write files at the
instrument commit `c8f95ea6f` over today's tree, batch 7's Core and `Shared/` included; `MobileChipScopeTests` and
`MobileNoteHoldTests` absent there):**

| Pin | Fix (`vm64-b6r1`) | Pre-fix (`vm64-b6r1-red`) | Kind |
|---|---|---|---|
| perf: reads per open == 1 (screen ×2, box, Library ×2) | green | RED (2) | VM-69 product |
| perf: editor builds per open == 1 | green | green | twin guard |
| perf: registry growth == 0 | green | RED (1) | VM-70 product |
| `anOpenAsksForTheWholeDocumentChromeOnce` | green (1) | RED (3) | VM-69 product |
| `openingANoteReadsNoListingOfEveryBookOrEveryTag` | green | RED | VM-69 product |
| `aWriteLandingAfterTheOpensOneReadReachesThePage` | green | green | hazard (a) guard |
| `closingANoteLandsItsTextThenGivesItsCoordinatorBack` | green | RED on the give-back | VM-70 product |
| `theReleaseWaitsForTheLeavingSavepoint` | green | RED on the give-back (the hold green) | VM-70 product (order) |
| `aCoordinatorAnotherHolderNeedsIsNeverLetGo` | green | RED | VM-70 product |
| `anEditorThatNeverArrivedGivesItsHoldBack` | green | RED | VM-70 product (the twin) |
| `aStoodDownEditorKeepsWorkingAndTheTabSwitchGetsACurrentPage` | green | green | hazard (c) guard |
| `probeWhenAClosedScreensEditorIsFreed`, `probeAPoppedNotesEditorInTheShell` | pass (RECORDED lines) | pass (RECORDED lines) | the trace |
| `MobileNoteHoldTests` (4) | green | not built | VM-70 r1 (the re-show roads, the order) |
| `MobileChipScopeTests` (3) | green | not built | hazard (d) guard |

**The commands (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down):**
(i) the note-open suite ALONE on each build, then the hold suite alone on the fix build:
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6r1 \
  -only-testing:VariorumMobileTests/MobileNoteOpenOnceTests 2>&1 | tee <log-b6r1-once>
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6r1-red \
  -only-testing:VariorumMobileTests/MobileNoteOpenOnceTests 2>&1 | tee <log-b6r1-once-red>
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6r1 \
  -only-testing:VariorumMobileTests/MobileNoteHoldTests 2>&1 | tee <log-b6r1-hold>
grep '^VM70-PROBE|' <log-b6r1-once> <log-b6r1-once-red>
```
Expected: fix — 10 of 10 green (r0's 7 — the r0 closeout's "6" miscounted them — plus the twin pin and the two probes); pre-fix — RED as tabled (the give-back pins wait 10 s each), the guards and probes pass;
hold — 4 of 4. The probe lines say at which stage the editor was freed in a live host, and whether the shell's pop was
drivable and freed it.
(ii) the 73 types plus the hold suite, ONE invocation, fix build (the first window's list, `MobileNoteHoldTests` added):
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileNoteOpenOnceTests MobileChipScopeTests MobileNoteHoldTests
  MobileStructuralFlightFenceTests MobileStructuralTests MobileSelectionActsTests
  MobileEditorMaterializationTests MobileCanaryTests MobileEditorRoutingTests MobileEditorCrystallizationTests
  MobileEditorProjectionTests MobileTypewriterRoomTests MobileNoteSealTests MobileFindInNoteTests
  MobileEditRoutingBindingTests MobileIdentityAuditSeparatorTests MobileBulkArmingTests MobileCanaryTeardownTests
  MobileEditRoutingCrashTests MobileEditRouteArmsTests MobileWholeBlockDeleteBrainTests MobileWholeBlockDeleteTests
  MobileCrossBlockEditBrainTests MobileCrossBlockEditTests MobileMarkdownRenderTests MobileMarkdownReturnTests
  MobileMarkdownActsTests MobileCheckboxTapTests MobileMarkdownCaretTests MobileTakesTests MobileTakesBrowserTests
  MobileTakesBrowserSurfaceTests MobileTakesChromeTests MobileTakeReorderTests MobileTakeToBlockTests
  MobileTakeLockTests MobileUndoDoorTests MobileBlockMenuTests MobileCommentsTests MobileBlockDecorTests
  MobileWalkTests MobileTrailingNewlinesTests MobileSpaceEaterTests MobileCRLFCaptureTests
  MobileWriteScrollAuthorityTests MobileScrollAuthorityBrainTests MobileLivenessTests
  MobileDeferredProjectionRetryTests MobileTypedOverRescueTests MobileEditTraceTests MobileKeyDoorPostureTests
  MobileSavepointOnLeavingTests
  MobileMembershipTests MobileNoteTagsTests MobileNoteRenameTests MobileNoteEntryDateTests MobileReferencesTests
  MobileTagManagerTests MobileBlockListTests MobileBlockSelectionTests MobileNoteTrayTests MobileDeletionTests
  MobileTrashTests MobileVersionsTests MobileNavigationTests MobileShellTests MobileMenuVocabularyTests
  MobileRefusalTableTests MobileQuickNoteTests MobileQuickNoteUnderLockTests MobileLockTeardownTests
  MobileRelockCoordinatorTests MobileRelockPolicyTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b6r1 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-b6r1-company>
```
Expected: all green but VM-24's standing `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePoint…` (main's
shape). The perf suite (alone) is unchanged by r1 in what it asserts; its registry series now passes by the leaving's
give-back rather than the host's death — it can ride the next perf window. Batch 7's `MobileLeavingSavesOnceTests` waits
on the same give-back, and its products (`vm64-b7`) are r0's — it should be rebuilt on r1 before its window counts.

### Batch 7 · VM-71 — leaving saves once (implementer closeout)

**Not done in this batch (first, by the record's rule):** every PHONE run is PENDING the orchestrator's stage window —
the perf suite's savepoint and leaving series (fix and red), the company-safe suite (fix and red), batch 6's release
pins and the lock and relock suites in company, and the walk (groups (i)–(iii) and (v) below, runnable from the built
products by anyone; since batch 6's r1 they run from `vm64-b7r1` / `vm64-b7r1-red`). The Mac piece (group (iv)) RAN
GREEN at 10:37 (the orchestrator's §5 block: 48 tests in 7 suites, from `vm64-b7`). So the simulator's AFTER numbers (`savepoints-per-*`, `leaving-100k-*`,
`box-first-save-after-100k-leaving`) have none yet; the headless Mac numbers below are the only measured before/after so
far. Nothing in custody, keychain, `Sync/` or the schema; no line in `Features/Protection/` (so nothing for the stage
coordinator's Protection watch from this batch); the lock, the relock decision, the grant and the network round in the
grant are untouched (the fence, below).

**Base:** `dfdd94b5a`. **Commits:** `242c5b3e3` (live status) · `c3db1be8d` (Core: the read and the narrowed op, their pins,
the gated measurement) · `d849b7125` (the phone's branch of `savepointOnLeaving`; the mark) · `c9b574513` (the phone pins;
the fix products `vm64-b7` are this tree) · `ba675754d` (record: the revert announced) · `1992b946f` / `20bbf402d` (this
closeout; the red-on-old build `vm64-b7-red` built over the four production files at the base, then restored). **On
batch 6's r1:** `03995a568` (live status: the re-check) · `a61e4f7c9` (the two test changes) · the r1 products and this
section's r1 lines (below).

#### The mechanisms, as traced on this tree (audit F 1D, 6C — TRACED as written; the lines moved)

- **The waiting (1D).** A pop runs `MobileWriteScreen.onDisappear` (`MobileWriteView.swift:210-232`): `teardown()` (the
  flush — a runner write per dirty take), then `AppSession.savepointOnLeaving`, whose whole runner turn was
  `Operations.closeAutoCommit` (`Operations+Variant.swift:311-320` → `autoCommitDirtyVariants` `:388-411`): ONE write
  transaction that decodes every live unlocked take of the note with its whole `working_text` and runs one last-savepoint
  read per take (`isDirty`) — O(note) on the ONE serial runner (`Shared/OperationsRunner.swift:17-31`) and the writer,
  whether or not anything had changed (a note she only READ paid it too). The capture box's first save — its mint,
  `MobileQuickNote.swift:704-735`, `runner.run { importPost }` — queued behind it. Measured headless (Mac, Debug, an
  encrypted on-disk WAL store, 1,370 blocks / 131,520 words): **216 ms per leaving**, the same after one edit or none.
- **The repeats (6C).** A Castle backgrounding asked three times for one leaving: `performBackgroundFlush`'s savepoint
  leg (`MobileShellRouter.swift:256-261`), then — after the network round (`:275-276`) and `relock.didLeaveTheScreen()`
  (`:351`) — `bootstrap.lock()` → `lockOnNewRoad` (`Shared/AppBootstrap.swift:1477-1499`) → `runWillLock` →
  `mobileWillLock`'s leg (`Features/Protection/MobileRelock.swift:91-93`), then `state = .opening` (`:1485`) removed the
  tree and each mounted screen's `onDisappear` asked a third time, racing the pool close (`:1490-1495`). Each ask was the
  216 ms whole op. The lock road alone (Lock now, a crossing's `runWillLock`) asked twice. The BEFORE table: Castle 3,
  Standard 1, a pop 1.

#### What shipped, file by file

- `Sources/VariorumCore/Queries/IdleCommit.swift` — **`Queries.leavingSavepointCandidates(_:containerID:)`**:
  `closeAutoCommit`'s own rule asked as a READ, in SQL — the live, unlocked takes under the note's live placements whose
  text differs from their last savepoint (none savepointed yet: any text at all); nothing for a gone or sealed note or a
  cadence that does not save on leaving; in id order. Text equality is BYTE equality here (SQLite BINARY) where the op's
  `isDirty` compares Swift strings (canonical equivalence), so the read's set CONTAINS the op's — never the other way.
- `Sources/VariorumCore/Operations/Operations+Variant.swift` — **`Operations.closeAutoCommit(_:takes:)`**: the same
  occasion and rows for exactly the listed takes — the note's two quiet no-ops, the cadence gate, then per listed take (in
  id order, deduped, one clock read) a re-check inside the one transaction (still live, unlocked, placed in this note,
  still dirty) and its `kind: .auto` savepoint. `closeAutoCommit(_:)`, `autoCommitDirtyVariants` and `isDirty` are
  untouched; the Mac calls neither new API (grep: their only caller is the phone branch below).
- `App/Variorum/Shared/AppSession.swift` — `savepointOnLeaving`: the Mac's statements under `#if os(macOS)`, in their
  order (the mark, `markLeaving`, the flush, the whole op on the runner, `dropAfterLeaving` — the two inner
  `#if os(macOS)` guards they sat in collapse into the outer one; the phone's `_ = landed` line goes). **The phone's
  `#else`:** the flush (unchanged — the read must see her last keys) → the owed takes read on a READER → none owed:
  return, the runner never asked → a closed store (`StoreLockedError`): return (nothing can be written there; the attempt
  this replaces failed and was swallowed) → any other read failure: today's whole op → the mark → ONE runner turn writing
  exactly the owed takes. The doc gains one pointer line.
- `App/Variorum/Shared/AppTiming.swift` — docs only: what `savepointAttempt` and its window count now (below).
- Tests: `Tests/VariorumCoreTests/LeavingSavepointTests.swift` (7, headless) · `LeavingSavepointMeasurementTests.swift`
  (gated) · `VariorumMobileTests/MobileHerPathsPerfTests.swift` (three series asserted, three tests added, `RunnerProbe`)
  · `VariorumMobileTests/MobileLeavingSavesOnceTests.swift` (new, 6, company-safe).
- **Not touched, by the fence:** `MobileRelock.swift`, `MobileShellRouter.swift`, `AppBootstrap.swift`,
  `VariorumMobileApp.swift`, `MobileWriteView.swift`, `MobileQuickNote.swift`, `MobileLivenessAuthority.swift`,
  `OperationsRunner.swift`, `AutosaveCoordinator.swift`, the relock and lock-teardown suites — `git diff dfdd94b5a --stat`
  lists no file under `App/Variorum/VariorumMobile/` or `App/Variorum/Variorum/`.

#### The fence — the lock did not move, and the savepoint stayed

WHO asks, and WHEN against the lock, is byte-identical: every ask site above is unchanged, so the flush's savepoint still
lands before the network round (its rows ride that round), `mobileWillLock`'s still lands inside `runWillLock` before the
state flip and the pool close, and the removed screens still ask from their `onDisappear` (deduped now, never reordered).
What changed is only what an ask COSTS and when it reaches the runner: the store is asked first, as a read, and the runner
only for what is owed. Every leaving that owes a savepoint still writes one, exactly the rows `closeAutoCommit(_:)` would
(pinned row for row); `closeAutoCommit`'s cadence occasion, its dedupe rule, its two quiet no-ops and its cadence gate
are the rule the read and the narrowed op both apply.

#### Hazard (a) — the five leaving roads: who asks, and what dedupes the rest

| Road | Who asks (unchanged) | What happens now |
|---|---|---|
| Popping a note | its screen's `onDisappear` → `teardown()` → `savepointOnLeaving` (`MobileWriteView.swift:210-232`) | one ask; the read decides — owed: one runner turn for the owed takes; nothing owed (she only read it): no runner turn at all. *[Ladder round 1, finding 1 — qualified: the read and the turn are two transactions, so a take ANOTHER writer dirties between them (a sync apply, which writes through the writer and never queues on the runner) is not written by this one ask; it stays owed and is the note's next leaving's — the pop has no later ask in the same leaving. Her typing is always inside: the flush lands it before the read. The cell's first text is kept as written.]* |
| Switching tabs away | `MobileShellView.selectPage` (`:422-432`) → the capture box's `fileOnLeaving` → `file()` → `savepointOnLeaving(minted)` (`MobileQuickNote.swift:1040`) | one ask, for the box's note. The note on the stack the switch hides is NOT left — it stays mounted and registered, stood down (the liveness authority's rule), and gets its savepoint at its pop, the backgrounding or the lock (each asks for every registered note). Unchanged; see P-71-1 |
| Backgrounding, Standard | `mobileScenePhaseChanged(.background)` → `performBackgroundFlush`: the box, then one ask per registered note (`registeredPostIDs`, deduped by note) | one ask per note, before the network round; no lock, no further ask |
| Backgrounding, Castle, before the lock | (1) the flush's ask, as Standard; (2) `mobileWillLock`'s ask inside the lock's `runWillLock`; (3) each removed screen's `onDisappear` | (1) savepoints what is owed. (2) and (3) read the takes already savepointed and ask the runner for nothing — unless something landed after (1): the round's apply, a conflict take, or (1) skipped because the grant expired — then they savepoint it, as before. (3) meeting a closed store asks nothing |
| The lock itself (Lock now, a crossing, a return-lock) | (2) `mobileWillLock`'s ask; (3) the removed screens' | (2) savepoints what is owed, before the state flip and the pool close; (3) as above |

**What dedupes the rest is the store**, not a memory: the read is `closeAutoCommit`'s own rule ("a take whose text
differs from its last savepoint"), asked before the runner. **Pins:** the perf suite — `savepoints-per-note-leaving` == 1
(a guard), `-backgrounding-standard` == 1 (a guard), `-backgrounding-castle` == 1 (RED on the pre-fix build: 3, the BEFORE
table), `savepoints-per-lock` == 1 (new; RED: 2). `MobileLeavingSavesOnceTests`, by the store's own record: the pop, the
tab switch, Standard, Castle and the lock each leave exactly ONE new quiet savepoint holding her text (guards — the op's
own dedupe already held this) and, on each road with an ask, the writer runs NO scan of the note's takes and one
last-savepoint read per take owed (RED on the pre-fix build: the pop, Standard and the lock one scan each, Castle two
before the pool closed, a read-only visit one scan and one read).

#### Hazard (b) — an earlier leaving never stands in for a later one

**Mechanism:** the dedupe has no memory of leavings. The read compares each take's text NOW with its LAST savepoint; any
change after any earlier savepoint — hers, or anything else's — makes that take differ again, so it is owed and
savepointed. Nothing is cached between asks, so nothing can go stale. **[Ladder round 1, finding 1 — qualified: "nothing
can go stale" holds ACROSS asks. Inside ONE ask the read and the runner turn are two transactions, so the ask sees what
had committed at the read's snapshot: a take another writer dirties between that snapshot and the turn (the sync
engine's apply — it writes through the writer, never the runner) is not listed, so that ask does not write it. It stays
owed, and the NEXT ask writes it: the same leaving's later ask on the Castle and lock roads, the note's next leaving on
the pop road. Her typing never falls in the window (the leaving's flush lands it before the read, in the same task).
The bound is held by `LeavingSavepointTests`' GUARD (green by design). The text around this note is kept as
written.]** **Pins:** the perf suite's backgrounding and lock
series alternate between two notes and edit before every leaving — an earlier leaving that stood in for a later one would
read 0, not 1; `MobileLeavingSavesOnceTests` runs the pop, the Castle backgrounding and the lock twice each with a change
between (the second round must add a second savepoint holding the second text), and a Standard backgrounding followed by
a change and a pop (a third savepoint). Guards: green on both trees by construction of the op.

#### Hazard (c) — under Castle the savepoint is made before the store closes, never after

**Mechanism:** no ask moved. The flush's ask lands before the round and the lock; `mobileWillLock`'s lands inside
`runWillLock`, before `state = .opening` and before `binding.lock()` (`AppBootstrap.swift:1484-1491`). The only later asks
are the removed screens', which write only if something is still owed AND the store is still open — on a closed store
their read throws `StoreLockedError` and nothing is asked (an attempt there could only fail, as it did before, swallowed).
**Pins:** `MobileLeavingSavesOnceTests.aCastleBackgroundingSavepointsOnceBeforeTheStoreCloses` and
`theLockSavepointsOnceBeforeTheStoreCloses` close a REAL pool (the bootstrap's binding, `asRebindable`), after the tree
comes down, so the removed screen's ask meets the closed store: the savepoint is in the store at the lock's start (read
then), the unlock finds exactly it and nothing more, and her text is whole. Guards on the ordering (green on both trees);
RED on the pre-fix build on the writer's scans.

**Re-checked on batch 6's r1** (the removed screens' leaving tasks now ALSO give their coordinator back, after their
savepoint). The savepoint still lands before the pool closes: r1 changed nothing of the lock's order — `mobileWillLock`'s
flush and savepoint still run inside `runWillLock` while every editor holds, before the state flip removes the screens
and before `binding.lock()`; r1 only appends, to each removed screen's leaving task, a release that writes nothing to the
store. A release racing the pool close cannot drop unsaved text — VERIFIED in the code, not assumed: the release is the
statement after `savepointOnLeaving` returns in the same task, so it runs only after teardown's flush and the savepoint's
own flush have each landed or been REFUSED; a refusal puts the text back into `pending` (`AutosaveCoordinator.flushNow`),
so the coordinator is dirty; and the phone's `releaseAutosave` (`Shared/AppSession.swift:476-481`) drops an entry only at
zero holders AND `!coordinator.isDirty` — a dirty one stays in the registry, reachable to `flushEveryOpenPost` and the
sync round's flush-first. **Pinned (new, a guard on both builds):**
`MobileLeavingSavesOnceTests.aKeyThatMeetsTheClosedStoreIsKeptByTheReleaseNotDropped` — a key typed after the lock's own
flush and savepoint, the tree down, the pool closed: the leaving's flush is refused, the release keeps the dirty entry,
and after the unlock one flush walk lands the key; the lock's savepoint holds what had landed before. (Whether such a
late key survives the REAL lock — whose session ends with it — is the lock's own road, wave 2's VM-103; unchanged by
this batch and by r1: before r1 the entry was never released at all.)

#### Hazard (d) — the capture box's first save after the 100k note is not behind that note's leaving work

**Mechanism:** the leaving's O(note) work — finding which takes changed — is now a READ on a reader connection: it holds
neither the runner nor the writer, and in WAL a reader never blocks the writer, so a box save asked meanwhile runs at
once. What the leaving still asks of the runner is O(her edit): the flush (her pending keys, as before) and ONE turn
writing the owed takes (none when she only read the note). The runner's serial guarantee is untouched. **Measured,
headless** (`VARIORUM_VM71_MEASURE=1`; the Mac, Debug, encrypted on-disk WAL, 1,370 blocks / 131,520 words, every take
savepointed once; n = 5): today's runner turn **215.53 ms (214.96–216.49)** after one edit and **216.16 ms
(215.01–216.90)** after only reading; now the read **5.84 ms (5.83–5.89)** / **5.94 ms (5.88–6.18)** OFF the runner and the
runner turn **1.07 ms (1.02–1.14)** for the one owed take — **none** after only reading. A Mac number, never a phone
number. **Pins (the shape the runner allows):** `MobileHerPathsPerfTests.leavingTheHundredKNoteHoldsTheRunnerOnlyForWhatItOwes`
— on the on-disk encrypted pool, the leaving's statements on the store's WRITER (every runner turn writes through it):
no scan of the note's takes, and last-savepoint reads = takes owed (0 after reading, 1 after one edit) — RED on the
pre-fix build (the scan, and one read per take: ~1,400, both arms). RECORDED beside it: `leaving-100k-runner-hold-*` (a
`RunnerProbe` — trivial runner turns asked back to back through the leaving; the longest wait is the longest stretch the
leaving held the runner — what a box save asked then queued behind), `leaving-100k-to-saved-*` (the layer's `noteLeave`
span), and `theBoxsFirstSaveAfterLeavingTheHundredKNote` → `box-first-save-after-100k-leaving` (the box's real mint, asked
the instant the leaving's flush landed her key — the moment before the savepoint asks the runner; the test's clock).
**One inherent case, said:** a leaving that OWES many takes (a note never savepointed — a long import, a note from before
the cadence) still writes one savepoint per owed take in its one runner turn; that is the cadence's rule, once per such
take, never again until it changes. The fixture's 100k note is exactly that on its first leaving, so the pins savepoint
it once before measuring ("a note she has left before").

#### The timing marks (batch 1's) — what they measure now (said, per the record's rule)

`savepointAttempt` (and so the `savepointsPerLeaving` window, the readout's "Savepoint tries" and "Savepoints per
leaving") now counts **runner turns for a leaving savepoint** — the mark moved from the top of `savepointOnLeaving` to
where the phone's branch asks the runner. Before VM-71 every call reached the runner, so the BEFORE numbers counted
exactly this quantity; after it, an ask whose read finds nothing owed is not counted (it costs no runner turn). The
Mac's mark is where it was (inert there). `noteLeave` ("Leave a note → saved") is unchanged in meaning: it now includes
the read instead of the whole op. Nothing else moved; no other series was touched (batches 5 and 6 own theirs).

#### The Mac does not change in behaviour

The Mac's `savepointOnLeaving` runs the same statements in the same order (the diff only collapses two inner
`#if os(macOS)` guards into the outer one); `closeAutoCommit(_:)` and everything under it is byte-identical; the two new
Core APIs have one caller, the phone's branch. RAN GREEN at 10:37 (48 tests in 7 suites, from `vm64-b7`; the
orchestrator's §5 block; batch 6's r1 changed phone files only, so that is still the tip's Mac code): the Mac suites over
the shared types (group (iv)) —
`SavepointOnLeaveTests` (the six leaving roads' one entry), `AutosaveRegistryReleaseTests`,
`AutosaveRegistryLifecycleTests` and `AutosaveRegistryReleaseGuardTests` (18k C1's drop rides this function),
`MacWillLockTests`, `AutosaveCoordinatorTests`, `TestHostInertTests`. Core, headless, on the final tree: `swift test --filter
'IdleCommitSweepTests|InsureTakesTests|SearchSavepointFacetTests|SavepointNameTests|LeavingSavepointTests|InvariantSweepTests|SavepointCadenceTests|SampleLibraryDedupeRepairTests|BlockVariantOperationsTests|LibraryDaySearchTests|SearchSavepointCaptureTests|LeavingSavepointMeasurementTests'`
— **121 tests in 15 suites passed** (one of them the gated measurement, skipped ungated; every suite near
`closeAutoCommit`, the cadence and the idle sweep).

#### Merging with VM-55, VM-47 and VM-78 — where a hand is needed

Read from `origin/vm-55-wings-underneath`, `origin/vm-47-sizes-and-look`, `origin/vm-78-fixes-to-whats-there` against
their merge-bases; nothing merged or cherry-picked. **None of the three touches a file this batch changed except
VM-55's `Shared/AppSession.swift`**, whose one hunk moves `let status = StatusCenter()` from the macOS block (~line 730)
up beside `undoMenuState` (~line 226) — far from `savepointOnLeaving` (~line 660); expected clean. VM-47's
`MobileShellRouter.swift`, `MobileQuickNote.swift` and `MobileWriteView.swift` rewrites, VM-55's `MobileQuickNote.swift`
/ `MobileWriteView.swift` and VM-78's `MobileWriteView.swift` meet nothing of this batch's: it left all of them alone.
The test files: VM-47's `MobileShellRouter.init()` (no `defaults:`) is what these tests already call
(`MobileShellRouter()`); `MobileLeavingSavesOnceTests` uses `router.quickNote.bind(session:)`, unchanged on every branch.

#### Residuals (traced, not fixed here — owners for the orchestrator to assign)

1. **Seen, not this batch's (the brief's own list):** after a Castle relock the quick note stays bound to the old
   session (audit F §12.1 — wave 2); the network round runs inside the background grant before the lock (6B — wave 2,
   VM-103); the removed screens' `onDisappear` still runs its teardown flush as the pool closes (§6) — it has nothing
   pending after `mobileWillLock`'s `flushAll`, and its savepoint ask now writes nothing in the ordinary case and asks
   nothing of a closed store; its ordering against the lock is unchanged (VM-103's).
2. **The read is O(note) per ask, off the runner.** A Castle backgrounding of a long note reads it three times
   (~6 ms each on the Mac headless; on a phone, PENDING the simulator). Cheap and concurrent, but not free; a per-leaving
   memory could skip the later reads only with a "nothing landed since" signal the phone cannot get cheaply for writes
   outside her coordinator (D-7-1). Recorded, not built.
3. **A tab switch does not leave the note on the stack it hides** (P-71-1 below) — today's rule, kept.

#### Design calls (options weighed; engineering, for the cold review)

- **D-7-1 — where the dedupe lives.** (a) **built:** the store's own record, read before the runner is asked —
  `closeAutoCommit`'s rule, exact, memoryless, blind to WHO wrote; (b) a per-leaving memory on the phone ("this note was
  savepointed in this leaving") — needs a "nothing landed since" signal; her coordinator gives one, but structural acts,
  take acts and a sync apply write around it, so it could skip a savepoint owed (hazard (a)'s failure); (c) change who
  asks (drop the lock teardown's or the flush's ask) — moves savepoint work against the lock or out of the round; fenced.
  **[Ladder round 1, finding 1 — the visibility point, added: (a) moves the point an ask sees the store at. The whole
  op decided and wrote in ONE write transaction, so it saw everything committed before the runner turn's transaction
  began — an apply already holding the writer, runner turns queued ahead; (a) decides at the READ's snapshot, earlier
  by the read itself (~6 ms at 100k words, the Mac, headless) and, when something is owed, by the runner hop and any
  wait for the writer. A take another writer dirties in between is the next ask's. Accepted, at the reviewer's call
  (`notes/plans/fixes/vm-64-ladder-round1.md` ▸ "Final calls"): the occasion is one savepoint per take she edited, and
  every such take is listed and written; the gap admits only another device's writes through sync (and, in the S5
  case, her words moved onto a conflict take — a live, synced take, savepointed at the next leaving); the old road's
  catch of an in-gap apply was timing, not a rule. The road not taken — re-running the read inside the turn — costs
  ~11–12 ms of O(note) on the runner on every edited leaving of a 100k note and leaves the read-only case's gap open
  anyway (measured: the gated `union-turn-one-edit` series, `12d6afde5`).]**
- **D-7-2 — the runner's turn when something is owed.** (a) **built:** `closeAutoCommit(_:takes:)` for exactly the owed
  takes, re-checked inside the transaction — O(owed); (b) the read as a yes/no, then today's whole op — O(note) on the
  runner whenever she edited, which is the 1D case the box meets after editing a long note.
- **D-7-3 — a closed store at the read.** (a) **built:** ask nothing (a closed store cannot take a write; the replaced
  attempt failed and was swallowed); (b) fall back to the whole op (fails, swallowed, one counted attempt more on the
  lock's race). Any OTHER read failure falls back to today's whole op — never worse than before.
- **D-7-4 — the mark.** (a) **built:** at the runner ask (the same quantity before and after, said above); (b) keep
  counting calls and add a counter for runner turns — a new readout row is new copy, not this batch's.
- **D-7-5 — the read compares bytes.** A superset of the op's canonical-equivalence rule, re-checked by the op (pinned:
  byte-different equal text is listed, and neither op writes it). Normalizing in SQL is not available without a custom
  function; the superset costs, at most, one empty runner turn on such a take.

#### For QUESTIONS at the merge (the orchestrator carries these to `notes/QUESTIONS.md`)

1. **P-71-1 — is switching tabs away a leaving of the note on the hidden stack?** Today (kept, unchanged by this batch):
   no — both stacks stay alive, the hidden note stays mounted and registered (stood down), and its quiet savepoint comes
   at its pop, the app's backgrounding or the lock; a tab switch files only the capture box. Options: (a) keep (built —
   the note is still open on its stack; its savepoint is owed when it is truly left); (b) a tab switch savepoints the
   hidden stack's notes as a leaving (cheap now — a read, and a runner turn only if owed; a return and a further edit
   owe another at the next leaving). Hers: what "stops being shown anywhere" means on the phone's two live stacks.

#### Re-check on batch 6's r1 — what each pin waits on now (2026-11-19, the orchestrator's message after `dd3f11d79`)

r1 (`9490642e3` … `7647127f2`) made the editor's coordinator release the LAST act of the screen's leaving task (teardown's
flush → `savepointOnLeaving` → `releaseAutosaveHold(ifNotShownSince:)` → the leave's timing mark) and the arrival's first
act takes it back. Read pin by pin on the tip:
- **`MobileLeavingSavesOnceTests` (the five tests that close a screen):** each waits for
  `session.autosaveHolderCount(forPost:) == 0` after `close()`, in a host that stays up. On r0 that could come true only
  when SwiftUI freed the removed screen's editor — which batch 6's first window showed does not happen while the host
  lives — so on r0 these waits would have run to their 15 s bound and failed on BOTH builds (they never ran on r0). On r1
  the count falls at the leaving's last act, after the savepoint: the waits now mean exactly "the leaving's savepoint has
  run" (the holder count falls even when the release KEEPS a dirty entry — `holders -= 1` comes first). Expectations and
  bounds stand (the bound is a hang guard); the host's note and the header said "the editor's end of life" — corrected
  (`a61e4f7c9`). The red build (r1's Write files, this batch's four production files at the base) releases the same way,
  so those waits pass there too and the designed reds stay on the writer's scans.
- **`aTabSwitchFilesTheBoxOnce…`:** waits on no hold (the hidden note is never left); unchanged.
- **The perf suite's five savepoint tests (two assertions tightened, three new):** they wait on the layer's `noteLeave`
  span (`Mounted.unmount(leavings:)`, the box test's own wait), whose end — `noteLeft` — r1 placed AFTER the release; the
  `savepointsPerLeaving` window and the `savepointAttempt` counter count only `savepointOnLeaving`'s runner asks, which r1
  does not add to (the phone's `releaseAutosave` asks for no savepoint — only the Mac's does); the writer traces see no
  release statement (the release is in memory). `leaving-100k-to-saved-*` now includes the release's microseconds. No
  expectation, deadline or note in them is stale. Under r0 the injected editors these tests hold kept their holds for the
  whole test (the test's own reference kept the model alive); under r1 each leaving gives its hold back — neither changes a
  count they read.
- **Hazard (c) re-checked — see "Hazard (c)" above:** the lock's order is unchanged; the removed screens' releases follow
  their savepoints and keep a dirty coordinator; one new pin.
- **Stale in my closeout and corrected here:** group (iii)'s expectation said the release "still comes after the flush and
  the savepoint (the onDisappear task holds the model across both…)" — r0's mechanism; on r1 the release is the leaving
  task's statement after `savepointOnLeaving` returns (corrected below). And the products: `vm64-b7` / `vm64-b7-red` were
  r0's — the phone runs are now from `vm64-b7r1` / `vm64-b7r1-red`; the Mac's stays `vm64-b7` (ran green, no Mac code
  changed since).
- **Not mine, noted:** the perf suite's registry test note (batch 6's — "releases its one acquisition at its end of life,
  which the leaving task holds", `MobileHerPathsPerfTests.swift` near `theAutosaveRegistryAcrossOpensAndCloses`) still
  describes r0; batch 6 owns that series.

#### The pins, and what each build should show

| Pin | Fix (`vm64-b7r1`) | Pre-fix (`vm64-b7r1-red`) | Kind |
|---|---|---|---|
| perf `backgroundingWith…` — `savepoints-per-backgrounding-castle` == 1 | green | RED (3) | VM-71 product (6C) |
| perf `backgroundingWith…` — `-standard` == 1 | green | green (1) | guard |
| perf `leavingAnEditedNote…` — `savepoints-per-note-leaving` == 1 | green | green (1) | guard |
| perf `lockingWithAnEditedNote…` — `savepoints-per-lock` == 1 | green | RED (2) | VM-71 product (the lock road) |
| perf `leavingTheHundredKNote…` — writer: no take scan; take reads 0 (read) / 1 (edited) | green | RED (1 scan; ~1,400 reads, both arms) | VM-71 product (1D) |
| perf `theBoxsFirstSaveAfterLeavingTheHundredKNote` | records | records (the BEFORE number) | recorded |
| perf, the other nine tests | green, unchanged | green | — |
| `MobileLeavingSavesOnceTests.poppingAChangedNote…` | green | RED on the writer (1 scan); the savepoints green | product + (a)(b) guards |
| `…aTabSwitchFilesTheBoxOnce…` | green | green | guard (P-71-1 stated) |
| `…aStandardBackgrounding…` | green | RED on the writer (1 scan); the savepoints green | product + (a)(b) guards |
| `…aCastleBackgroundingSavepointsOnceBeforeTheStoreCloses` | green | RED on the writer (2 scans, 2 reads); the savepoints and the order green | product + (a)(b)(c) guards |
| `…theLockSavepointsOnceBeforeTheStoreCloses` | green | RED on the writer (1 scan); the rest green | product + (a)(b)(c) guards |
| `…leavingANoteSheOnlyReadAsksTheRunnerForNothing` | green | RED (1 scan, 1 read) | VM-71 product (1D) |
| `…aKeyThatMeetsTheClosedStoreIsKeptByTheReleaseNotDropped` (new on r1) | green | green | (c) guard under r1 (the release is batch 6's) |
| Core `LeavingSavepointTests` (7) | green (headless, run) | not built (names the new API) | the new API's contract |

Row dispositions: **VM-71 — FIXED** (the repeats: Castle 3 → 1, the lock 2 → 1; the waiting: the leaving's O(note)
work off the runner) with the red-on-old pins above — PENDING their stage runs.

#### The stage window (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Products **since batch 6's r1**: phone fix `App/Variorum/DerivedData/vm64-b7r1/` (the tip at `a61e4f7c9`: this batch,
batch 6's r1, the two r1 test changes); phone pre-fix `App/Variorum/DerivedData/vm64-b7r1-red/` (the same tip with this
batch's four production files at `dfdd94b5a`); Mac `App/Variorum/DerivedData/vm64-b7/` (unchanged Mac code — group (iv)
ran green from it at 10:37). The r0 products `vm64-b7-red` (deleted by the orchestrator) and `vm64-b7`'s phone half are
superseded — do not run phone tests from them. If `vm64-b7r1-red` is ever lost:
`git checkout dfdd94b5a -- Sources/VariorumCore/Queries/IdleCommit.swift Sources/VariorumCore/Operations/Operations+Variant.swift App/Variorum/Shared/AppSession.swift App/Variorum/Shared/AppTiming.swift`,
`build-for-testing` into `DerivedData/vm64-b7r1-red`, then `git checkout HEAD --` the same four.

**Group (i) — the perf suite ALONE, fix build, twice** (it reads the process's one timing recorder):
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b7r1 \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests 2>&1 | tee <log-b7-perf-1>
grep '^VM64-PERF|' <log-b7-perf-1>
```
Expected: 13 tests pass; `savepoints-per-*` all 1 (four series); `leaving-100k-writer-take-scans-*` 0,
`leaving-100k-writer-take-reads-read` 0 and `-edited` 1; batch 5's and batch 6's asserted series unchanged. The AFTER
numbers (`leaving-100k-runner-hold-*`, `leaving-100k-to-saved-*`, `box-first-save-after-100k-leaving`) come from these two
runs. It is the longest suite in the run now (three more tests open the 100k note six times each) — poll for the Swift
Testing verdict line, not `** TEST EXECUTE **`.

**Group (ii) — the pre-fix build, each suite ALONE:**
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b7r1-red \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests 2>&1 | tee <log-b7-red-perf>
grep '^VM64-PERF|' <log-b7-red-perf>
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b7r1-red \
  -only-testing:VariorumMobileTests/MobileLeavingSavesOnceTests 2>&1 | tee <log-b7-red-once>
```
Expected: perf — RED `backgroundingWith…` (Castle 3), `lockingWith…` (2), `leavingTheHundredKNote…` (scans 1, reads
~1,400, both arms); the other ten green; `box-first-save-after-100k-leaving` is the BEFORE number. Once — RED
`poppingAChangedNote…`, `aStandardBackgrounding…`, `aCastleBackgrounding…`, `theLockSavepointsOnce…`,
`leavingANoteSheOnlyRead…` (each on the writer's scans/reads only — every savepoint-count and ordering expectation green);
GREEN `aTabSwitchFilesTheBoxOnce…` and `aKeyThatMeetsTheClosedStoreIsKeptByTheReleaseNotDropped`.

**Group (iii) — the batch's suites with the leaving road's, the lock's and batch 6's, fix build, ONE invocation:**
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileLeavingSavesOnceTests MobileNoteOpenOnceTests MobileNoteHoldTests MobileSavepointOnLeavingTests
  MobileLockTeardownTests MobileRelockCoordinatorTests MobileRelockPolicyTests MobileQuickNoteUnderLockTests
  MobilePhoneStoreEncryptionTests MobilePassphraseFloorTests MobileTypedUnlockSyncKeysTests MobileRoundOccasionTests
  MobileQuickNoteTests MobileQuickNoteReadFailureTests MobileLivenessTests MobileShellTests MobileNavigationTests
  MobileDeletionTests MobileVersionsTests MobileStructuralFlightFenceTests MobileCanaryTeardownTests
  MobileTypedOverRescueTests MobileDeferredProjectionRetryTests MobileWalkTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-b7r1 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-b7-company>
```
Expected: all green. Batch 6's three release pins (`MobileNoteOpenOnceTests.closingANoteLandsItsTextThenGivesItsCoordinatorBack`,
`theReleaseWaitsForTheLeavingSavepoint`, `aCoordinatorAnotherHolderNeedsIsNeverLetGo`) and r1's `MobileNoteHoldTests` must
stay green: since r1 the release is the leaving task's statement after `savepointOnLeaving` returns — after this batch's
phone branch has flushed, read and (when owed) written — so when the writer is held, the flush waits on it and the
release with it. *[r1: corrected — this line said "the onDisappear task holds the model across both", r0's mechanism.]* The lock and relock suites (`MobileLockTeardownTests`,
`MobileRelockCoordinatorTests`, `MobileRelockPolicyTests`, `MobileQuickNoteUnderLockTests`) are UNCHANGED files and must
be green.

**Group (iv) — the Mac suites over the shared `AppSession` (its Mac branch unchanged), ONE invocation:**
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(SavepointOnLeaveTests AutosaveRegistryReleaseTests AutosaveRegistryLifecycleTests AutosaveRegistryReleaseGuardTests
  MacWillLockTests AutosaveCoordinatorTests TestHostInertTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme Variorum -destination 'platform=macOS' \
  -derivedDataPath DerivedData/vm64-b7 ${tests/#/-only-testing:VariorumTests/} 2>&1 | tee <log-b7-mac>
```
Expected: all green, unchanged. **RAN GREEN at 10:37** (48 tests in 7 suites — the orchestrator's §5 block); no Mac
code has changed since, so it is not owed again.

**Group (v) — the walk (the batch's use-shaped evidence; the orchestrator's hands or a GO to me).** The Debug phone app
(`DerivedData/vm64-b7r1/Build/Products/Debug-iphonesimulator/VariorumMobile.app`) on the `vm64-walk` simulator, dev store,
signed out, never Resume, no test account. (1) Settings ▸ "Seed the 100k fixture" if the store does not hold it. (2)
Library ▸ "the long haul" — read, back (a leaving she only read); open it again, type a word in the second block, back,
then at once tap the capture box, type a line and File (the box's first save, right behind the long note's leaving);
capture the shelf after the filing (`b7-box-filed.png`). (3) Open "the long haul" again, open the edited block's takes
(the block menu's Takes…), the take card's ⋯ ▸ "Block History…" — under "Commits" the quiet savepoint holding the typed
word is listed (`b7-history.png`); back. (4) Settings ▸ Timing… — "Leave a
note → saved" and "Savepoints per leaving" rows (the leaving she only read adds a 0; the edited one a 1)
(`b7-readout.png`). No face changed in this batch, so one voice is enough. Screens go to `notes/plans/vm64-screens/`
(gitignored). What it leaves on the device: the seeded fixture (if seeded), one typed word in the long note, one filed
capture.

### Ladder round 1 — fix pass (implementer closeout; first turn)

**Not done in this turn (first, by the record's rule):** finding 1 is NOT applied — it waits for the reviewer's call
between its two arms (the responses, `notes/plans/fixes/vm-64-ladder-round1.md` ▸ "Implementer responses (fix pass)",
recommend arm (a)). The red-on-old phone build `vm64-fix-red` is NOT built: a QUIET window (another run's merge gate) began
at about 12:36 and forbids cold builds; it waits for the window's end and for the merge of `origin/main` (VM-55) the
orchestrator will ask for first. The hosted pin has not run (the stage). The whole-package `swift test` is owed once, on
the final tree, in the second turn. The fix products in `vm64-fix` were built at `f589d964e` just before the window and
will be SUPERSEDED by a rebuild on the merged tree.

**Base:** `4b4d64143`. **Commits:** `1318e0567` (live status) · `44ac60f8b` (the responses, before any fix) · `12d6afde5`
(the gated measurement behind finding 1's arm (b) numbers — test-only) · `39008cb46` (finding 3 + its pin) · `a578f0b6e`
(finding 5) · `f4801064e` (finding 6) · `f589d964e` (finding 2 + its pin) · this closeout.

#### What shipped, finding by finding

- **Finding 3 (VM-65) — `Sources/VariorumCore/Diagnostics/TimingRecorder.swift`, `end(_:countingUnmatched:)`.** The
  locked body now also answers whether the SAVED record moved — a sample recorded, `unmatchedEnds` counted, a stale
  begin's `abandoned` counted — and the change handler is told only then: the windows' own rule (`openWindow` and
  `closeWindow` already called `changed()` only `if recorded`). An `endIfOpen` that found nothing open (every keyboard
  rise asks two) no longer marks the record dirty or schedules a 20 s save of an unchanged table. **Pin**
  `Tests/VariorumCoreTests/TimingRecorderTests.swift` `aNoOpEndIfOpenLeavesTheRecordUnchanged`: after a save, a no-op
  `endIfOpen` tells the handler nothing and leaves no unsaved change; the same test's guard arms — a recorded span, an
  unmatched `end`, a stale begin dropped — each tell it once per save. **RED on the pre-fix tree** (run before the fix:
  4 issues, exactly the two no-op arms — `:446`, `:447`, `:458`, `:459`), **green after**.
- **Finding 5 (VM-2) — `Sources/VariorumCore/Domain/StructuralFlightFence.swift`.** `surfaceSettled()` is no longer
  `mutating`; its doc says it is a query. The name and its one production call site (`MobileEditorViewModel.swift`, the
  settle) are unchanged — no editor-seam line moved for a cleanliness nit. No pin.
- **Finding 6 (VM-65) — `App/Variorum/Shared/AppTiming.swift`, comments only.** The catalog line for
  `syncRoundSent` (the one place every mark's meaning is written) and `syncRoundEnded`'s doc say the count is the
  outbox's drop, so rows queued during the round are subtracted from it and a mid-round burst under-reads it, down to 0
  (the clamp). `SyncSession` untouched. No pin.
- **Finding 2 (VM-70) — `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift`,
  `takeAutosaveHold()`.** The hold guard's early return became `if !holdsAutosave { … }` around the re-acquire and the
  adoption, and the re-observe block — unchanged, idempotent, reading `autosave` at use time — runs after it on BOTH
  paths. Not the literal hoist: moving the block above the guard would observe the coordinator the editor gave back,
  which the adopt branch then stops, leaving an adopted coordinator unobserved (r1's
  `aScreenShownAgainAfterItsLeavingTakesTheHoldBackAndIsWiredToIt`). Nothing else in the hold's lifecycle changed
  (`releaseAutosaveHold`, `deinit`, `teardown`, `MobileWriteView` untouched); batch 2's fence untouched (the latch hook,
  the gate and storage belts, the settle); `storageDidEdit`, `fallbackVerdict` and `EditorEditRouting` untouched.
  **Pin** `App/Variorum/VariorumMobileTests/MobileNoteHoldTests.swift`
  `aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator`: the store held, the leaving parked in its savepoint
  after teardown ran (asserted: not listening, still holding — the posture, green on both trees), the screen shown again,
  the store released, the leaving ended: the editor holds AND listens, and what it records reaches the registry (a key,
  `flushEveryOpenPost`, the stored text). Hosted — PENDING the stage; expected RED on the pre-fix `takeAutosaveHold` at
  exactly two expectations (`observesAutosave` after the re-show, and again after the leaving ends), green on the fix.

#### VM-227 — narrowed, not closed (the trace is the responses' finding 2)

The covered-and-shown-again roads are pushes on the note's own stack (Note ▸ Versions; the diverged copy's landing,
R67) and Back — not a tab switch (the band keeps every page mounted and only offsets it, so no `onDisappear`), not a
sheet. Shown again AFTER the leaving's give-back (the ordinary case): re-observed since batch 6's r1. Shown again after
teardown but before the give-back (the leaving parked in its savepoint): re-observed by this fix. Shown again WHILE
teardown is still suspended (her keys pending at the cover and `finish()`'s flush, the mint settle or a pending gesture
outlasting the push and Back behind a busy runner or writer): still NOT re-observed — the re-show finds the token set,
teardown's last lines then remove it, and the give-back is skipped. The closing shape, offered for the reviewer's call
and NOT applied (it changes the leaving's half, outside this fix's fence): at the leaving's last act, if the screen
arrived again and no token is held, re-observe — one conditional in `releaseAutosaveHold(ifNotShownSince:)`.

#### Evidence

- Headless, the touched Core suites: `swift test --filter 'TimingRecorderTests|StructuralFlightFenceTests|LeavingSavepointTests|LeavingSavepointMeasurementTests'`
  — **48 tests in 4 suites passed** (the gated measurement skipped ungated: 47 ran). `TimingRecorderTests` alone 32
  passed; `StructuralFlightFenceTests` alone 8 passed, no warning in the touched file.
- Builds at `f589d964e` (before the QUIET window): phone `build-for-testing` into `App/Variorum/DerivedData/vm64-fix/`
  **`** TEST BUILD SUCCEEDED **`** and Mac `build-for-testing` into the same folder **`** TEST BUILD SUCCEEDED **`** (it
  finished at 12:37, inside the window's two-minute tail) — no warning in a touched file. Both are superseded by the
  rebuild on the merged tree.
- Finding 1's arm (b) cost: the responses' table (three calm runs of the gated measurement).

#### The stage window (after the merge and the rebuild; the GO's claim line and UDID fill `<simulator-udid>`)

The red build first (no revert is in flight now; this is the recipe, announced in the live status before it starts —
it reverses ONLY finding 2's hunk, so it stays right after VM-55's edits to the same file are merged in):
```
cd ~/dev/variorum-vm-64
git diff f4801064e f589d964e -- App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift | git apply -R
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm64-fix-red
cd ~/dev/variorum-vm-64 && git checkout HEAD -- App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift
git status --short   # must be empty
```
(i) the hold suite ALONE on each build:
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-fix \
  -only-testing:VariorumMobileTests/MobileNoteHoldTests 2>&1 | tee <log-fix-hold>
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-fix-red \
  -only-testing:VariorumMobileTests/MobileNoteHoldTests 2>&1 | tee <log-red-hold>
```
Expected: fix — 5 tests in 1 suite passed; red — `aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator`
FAILS with 2 issues (the two `observesAutosave` expectations), the other four pass.
(ii) the suites around the touched code, fix build, ONE invocation:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileNoteHoldTests MobileNoteOpenOnceTests MobileLeavingSavesOnceTests MobileLivenessTests
  MobileStructuralFlightFenceTests MobileUndoDoorTests MobileDeferredProjectionRetryTests MobileTypedOverRescueTests
  MobileSavepointOnLeavingTests MobileVersionsTests MobileNavigationTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-fix \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-fix-company>
```
Expected: all green. No Mac hosted run is owed by this pass: its `Shared/` lines are comments, its Core lines are pinned
headless, and the Mac build compiles them; the run's whole-Mac window covers the rest.

#### For QUESTIONS at the merge

None from this pass — no product behaviour was decided. Finding 1's arm and finding 2's closing conditional are the
reviewer's calls (engineering).

#### Second turn, part 1 — the reviewer's final calls, and what landed

The calls are the reviewer's, verbatim in `notes/plans/fixes/vm-64-ladder-round1.md` ▸ "Final calls (reviewer)"
(`c9a2effda`). Part 1 ran inside the QUIET window: comments, one test, the record — no product statement changed, no
build, no merge.

| Finding | The reviewer's call | What landed (commit) |
|---|---|---|
| 1 · the leaving read's visibility window (Part of VM-71) | CONFIRMED — arm (a), exactly as specified; nothing of arm (b); no pin (an over-claim corrected, not a bug fixed) | the GUARD `LeavingSavepointTests` "GUARD — a take another writer dirties between the read and the turn is the next ask's" (`84a8acff8`; green by design, named a guard, never a pin) · the comments — `Shared/AppSession.swift`'s phone branch of `savepointOnLeaving` (inside its `#else`) names the one-ask gap and its bound, `closeAutoCommit(_:takes:)`'s doc says AT THE TURN and that a take dirtied after the read is the next ask's (`78439841e`; comments only, the Mac's statements byte-unchanged) · the record — §7 batch 7's hazard (a) pop row, hazard (b) and D-7-1 corrected in place, the first text kept (`d6404029a`) · the gated measurement stays as the road not taken's cost (`12d6afde5`) |
| 2 · a re-show mid-leaving never re-observes (VM-70) | CONFIRMED AS APPLIED — the built shape adopted over the literal hoist; owed: the red build reversing only this hunk, the pin RED on it at the two named expectations and GREEN on the fix alone and in company, the suite's other four green | `f589d964e`; the red build and the stage runs are part 2 (after the window and the merge) |
| 2 · the remaining road (a re-show while teardown itself is suspended) | DISMISSED from this pass — stays with VM-227 | nothing; "VM-227 — narrowed, not closed" above is kept verbatim; at the merge the orchestrator points VM-227 at the responses' finding-2 trace and the offered conditional with its pin sketch |
| 3 · `TimingRecorder.end` dirty on a no-op (VM-65) | CONFIRMED AS APPLIED | `39008cb46` (the pin RED on the pre-fix tree at the two no-op arms, 4 issues; green after) |
| 4 · the batches 6+7 walk (or the recorded substitution) | stands, the orchestrator's | nothing here |
| 5 · `surfaceSettled()` mutating (VM-2) | CONFIRMED AS APPLIED | `a578f0b6e` |
| 6 · the round's "sent" clamp (VM-65) | CONFIRMED AS APPLIED | `f4801064e` |
| 7 · FOR A LATER READER | stands, the closeout's | nothing here |

**Evidence (part 1):** `swift test --filter 'TimingRecorderTests|StructuralFlightFenceTests|LeavingSavepointTests|LeavingSavepointMeasurementTests'`
— **49 tests in 4 suites passed** (the gated measurement skipped ungated; the guard among them). The two comment
edits in Core compile in that run; the `AppSession.swift` comment compiles in part 2's rebuild (app code — not in the
package).

**Part 2 (NOT-STARTED — at the orchestrator's word, after the window and once VM-55's merge has landed on main):**
merge `origin/main` (batch 5's "Merging with VM-55" recipe for the two Shell files); rebuild phone and Mac into
`vm64-fix` on the merged tree; the red build `vm64-fix-red` by the recipe above (it reverses only finding 2's hunk);
the whole Core package headless; the stage commands above.
*(Part 2 was taken over by the merge-in implementer — the section below; its builds went to `vm64-gate` /
`vm64-gate-red`, not `vm64-fix*`.)*

### The merge of main (VM-55) and what it re-landed (merge-in implementer closeout)

**Not done here (first, by the record's rule):** no hosted run of any kind — every `xcodebuild test`, simulator boot
and walk is the orchestrator's stage window; the commands are at the end of this section. No shared ledger touched
(`notes/QUESTIONS.md`, `notes/TICKETS.md`, the master plan, `notes/AppSpecRecord.md`, `notes/MobileSoul.md`,
`notes/SurfaceContracts.md` arrive from main by the merge exactly as main has them). Nothing in `Sources/VariorumCore/Sync/`,
custody or keychain code, or `VariorumMobile/Features/Protection/`; no schema change (`v1_38` stays this run's only
migration; VM-55 added none). `storageDidEdit`'s routing, `fallbackVerdict` and `EditorEditRouting` not opened.

**The merge:** `f03d59ae3` — "Merge main (VM-55) into vm-64-timing-and-lags", a merge commit (parents `d10b167b2`, this
branch, and `eb18888db`, `origin/main`: VM-55's merge `66337ff08` and its notes-only ledger commit). Merge-base
`359ae214d` (the main both runs merged earlier — VX-980). `git merge-base --is-ancestor origin/main HEAD` holds. Thirteen
code files were changed by both runs since that base; two conflicted textually, eleven merged clean (each read on both
sides — items (a)–(f) below).

#### The two conflicts, hunk by hunk (each resolution checked against both sides: every line either side ADDED is in the result but VM-55's dropped `follow` bodies; no line either side REMOVED came back)

**Batch 5's recipe was checked against VM-55's code AS IT LANDED, not as it stood this morning.** VM-55's later batches did
not touch `MobileLibraryViewModel.swift` again after batch 2b's error conversions (its batch 4 changed the shell and the
roots' path lines, not the model); the recipe's three instructions held. One trap the recipe did not name, found by
diffing the result against our side: see H3.

`App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift` — four diff3 regions (`git checkout
--conflict=diff3`, so each region's base was in view):
- **H1 — our listings section (`// MARK: - The listings…` through `prime`'s read) vs VM-55's `follow`-wrapped
  `startAll` head.** Took OURS; dropped VM-55's `MobileWingScope.follow` wrapper. *Reason:* batch 5 replaced the two
  always-on observations with ONE keyed hold; its question carries the wing (`Question.wing = session.wing.readScope`,
  which VM-56 made the current wing on the phone), and the view keys its task on that question, so a wing change restarts
  the hold — a second, model-side follow would restart it twice. What VM-55's pins drove through `follow` is re-landed
  under item (a).
- **H2 — `prime`'s `land` + catch vs base's `startAll` catch vs nothing (VM-55 moved that catch inside its closure).**
  Took OURS, its raw `lastError = String(describing: error)` converted to `OpsRefusalCopy.sentence(for: error, roads:
  .phone)`. *Reason:* our line descends from the base line VM-55 converted; VM-55's intent for it (VM-62: refusals in
  words) holds on our function.
- **H3 — `holdFirstPage`'s head vs base's `startBookless` head vs VM-55's `follow`-wrapped `startBookless`.** Took OURS.
  **The trap:** "ours" here does NOT carry `holdFirstPage`'s catch. Our side kept the base `startBookless` catch lines
  verbatim inside `holdFirstPage`; VM-55 deleted them from the same place (moved inside its closure); the 3-way applied
  VM-55's deletion to the text BETWEEN the regions, so a resolution of "ours everywhere" compiles to a `do` with no catch
  for an observation that throws. Found by diffing the resolved file against our side (three lines missing), restored,
  and converted as in H2. *Reason:* the catch is ours; VM-55's conversion is its intent for it.
- **H4 — the end of our listings section vs nothing vs VM-55's `var wingID: String { session.wing.currentID }`.** Took
  BOTH: our section, then VM-55's `wingID`. *Reason:* the search task re-keys on it (VM-57, `MobileLibraryView`'s
  `.task(id: [model.wingID, query])`, which merged clean); nothing of ours replaces it.
- Outside the regions git merged VM-55's other hunks clean and they are kept: the `lastError` `didSet` speaking on the
  one line, `search`'s wing-scoped `searchCatalog(…, wingID:)` and its converted catch, the mint's converted catch, the
  delete's `MobileLine.say(…, as: .removal(.putBackNote(…)))` and `DeletionRefusal.sentence(…, roads: .phone)`.
- The two remaining raw lines of batch 5 (`reread`'s catch and `loadMore`'s) were converted IN THE MERGE COMMIT too, by
  batch 5's recipe ("map this batch's `lastError = String(describing: error)` lines"): **all four** of batch 5's raw
  `lastError` writes now speak `OpsRefusalCopy.sentence(for: error, roads: .phone)`. The pin that is red without them is
  VM-55's own `MobileNoRawErrorPinTests.noPhoneSourceRendersARawError` (a source scan of `VariorumMobile/`): our pre-merge
  file holds four of its offending lines.

`App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift` — ONE region (the `MobileLibraryView(…)` arguments did
NOT conflict: VM-55's `wingName:` / `onWingDoor:` after `tokens:` and our `isOnScreen:` after `onOpenArchive:` merged
clean, in the struct's declaration order):
- **After `.task { await starsModel.start() }`: our `.onAppear { MobileTiming.homeAppeared() }` (VM-65's "home on
  screen") vs VM-55's `.task { await wings.track() }` (the held wings read — a dead wing returns the phone Home).** Took
  BOTH, VM-55's task first. *Reason:* two independent modifiers on the shell; neither reads the other.

#### (a) The wing — the Library and Bookless listings, a switch, a hidden switch (commit `fa4a8c58a`)

**Checked:** on the merged tree the paged hold's question carries `wing: session.wing.readScope`
(`MobileLibraryViewModel.question(_:)`), and VM-56 made `WingState.readScope` return `currentID` on the phone
(`Shared/WingState.swift`), so both listings read exactly the scope VM-55's listings read: the notes page
`catalogNotesPage(…, wingID: wing)` where VM-55 read `observeLibrary(…, wingID: wing)`, and the loose page
`catalogNotesPage(…, wingID: wing, poolLoose: true)` where VM-55 read `poolPosts(…, wingID: wing)` — the loose class is
pinned identical to `poolPosts`' over every wing scope in Core (`LibraryPoolPagingTests`, batch 5). `WingState` is
`@Observable`, and `MobileLibraryView` reads the hold key in its body (`model.hold(onScreen: isOnScreen)` →
`readScope`), so a switch changes the key and `.task(id: hold)` restarts the hold: on screen, the restarted hold's held
page is the new wing's first page; hidden, its `prime` reads the new wing once and nothing is held; at the return the key
is the new wing's in any case (the first fetch of the held page re-asks). VM-55's door lands on the Shelf
(`selectPage(.shelf)`), so a pick from the Library root hides the Library in the same moment — the restart reads the new
wing's page once, and the return re-asks it. **No product line was needed**: the key already carried the wing; only
`MobileWingScope.follow` around the listings was dropped (H1, H3).

**Changed (all test-side, plus comments in the model):**
- **VM-55's Library pins no longer meant anything as written** — they drove `startAll()` / `startBookless()`, which under
  VM-55 WERE the view's road and followed the wing themselves; under batch 5 they hold ONE question for as long as they
  run (the view's key is what restarts), so a switch would leave the old wing's rows standing and four pins would go red
  for a reason that is not a product fault. **Replaced by** the Library held exactly as its view holds it:
  `holdLibraryAsItsViewDoes(_:onScreen:)` (`VariorumMobileTests/MobileWingsTests.swift`, beside VM-55's `eventually`) —
  the hold key read under observation tracking (`Observations { model.hold(onScreen:) }`, as the view's body reads it)
  and `model.hold(key)` restarted on each change, cancelling the one before, as `.task(id:)` does. The four pins' DRIVER
  line is the only change; their expectations, names and fixtures are VM-55's, byte for byte:
  `MobileWingListingTests.theLibraryListsOnlyTheCurrentWingAndFollowsIt`, `MobileWingListingTests.thePoolListsOnlyTheCurrentWing`
  (it also sets `filter = .bookless` first — the Bookless listing is held while its filter shows),
  `MobileWingStandTests.aWingArrivingDeletedBySyncReturnsThePhoneHomeAndTheListingsFollow`,
  `MobileWingDoorTests.aPickSwitchesLandsOnTheBookcaseAndEveryRootRescopes` (its Shelf and Starred still follow through
  `MobileWingScope.follow`, untouched). A key that stopped carrying the wing, or a wing the key could not observe, leaves
  the old rows standing and these go red.
- **New GUARD (hosted, the mounted shell):** `MobileLibraryPagingTests.aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn`
  — the Library seen in Home, left for the Shelf, the wing switched there by VM-55's door (the name on the Shelf's root,
  then the "Work" row), the Library's tab door: Work's note listed, Home's not. Green by design on the merged tree.
- **Model-level wing lines** added to batch 5's own `MobileLibraryPagingRulesTests.theHoldKeyNamesTheShownListing`: the
  question's wing is the current wing, and a switch changes both the shown and the hidden key.
- **Comments only** in `MobileLibraryViewModel.swift`: `Question.wing`'s doc (the current wing on the phone since VM-56; a
  switch is a new question) and `startAll()`'s (it holds one question; following is the view's key).
- **The nine-wing perf comparison** (`MobileHerPathsPerfTests.typingInTheBoxWakesTheOffScreenLibrary`, RECORDED series —
  none asserted): the two page reads already take `readScope`, which on the merged tree is Home (one ninth of the world);
  the two pre-batch-5 comparison reads were unscoped. Scoped them by the same `wing` (VM-57's scope for those very
  queries), so the same-run comparison stays like for like. **Said, per the record's rule:** on the merged tree
  `library-page-fetch-ninewings`, `bookless-page-fetch-ninewings`, `library-listing-fetch-ninewings` and
  `bookless-listing-fetch-ninewings` measure the CURRENT WING (Home), where batch 3's BEFORE and the final tree's AFTER
  tables (§5) measured every wing; the plans printed (`VM64-PLAN|…`) carry the wing predicate too. No other series moves.

**VM-55's pins that cover the Library's wing scope (by TYPE):** `MobileWingListingTests` (the two above, and
`searchAsksTheCurrentWing` — the search's own wing, untouched, still keyed by `model.wingID`) · `MobileWingStandTests`
(the sync-death pin above) · `MobileWingDoorTests` (the pick pin above) · `MobileWingDoorShellTests` (the mounted shell,
the pick from the Library root — untouched) · `MobileWingDoorGeometryTests` (`theLibraryRootsDoor` — untouched). This
merge's: `MobileLibraryPagingTests` (the new guard) · `MobileLibraryPagingRulesTests` (the hold key's wing lines).

**For the cold reviewer — one difference the merge kept, read before (a):** VM-55's `follow` cancelled the old wing's run
AND WAITED for it to end before the new one started ("a listing never shows two wings"). `.task(id:)` cancels the old hold
and starts the new one without waiting. What remains of the old run: its held observation's stream ends at cancellation
(no further landing); its in-flight one-shot reads (`prime`, `reread`, `loadMore`) are GRDB async reads, which throw
`CancellationError` when cancelled mid-read (the read is interrupted), so only a read that had already FINISHED in the
instant before the switch can still land — and `reread` / `loadMore` then also drop on their question/generation guards;
`prime` lands it (it has no guard after its await), replacing the rows with the old wing's page until the next landing.
That window is the same one batch 5 already had for a sort or filter change; the wing adds a trigger, not a mechanism.
No pin can hold it deterministically and no line was written for it; it is named here so the reviewer can judge it.

#### (b) The one message line (no commit beyond the merge)

**Checked:** a mirror of VM-55's `MobileNoRawErrorPinTests.noPhoneSourceRendersARawError` over every `.swift` under
`VariorumMobile/` on the merged tree (its patterns: `String(describing:`, `String(reflecting:`, `.localizedDescription`,
an interpolated `\(error|err|failure|op)`, `"Refused: \(…)"`, `DeletionRefusal.fallback(`/`.words(`,
`OpsRefusalCopy.message(`, `VersionActs.words(`; logger lines exempt) finds only VM-55's two named exemptions
(`MobileStarterJournal.swift`) and one logger line (`MobileFirstWriteFurniture.swift`). A mirror of
`MobileErrorLogPrivacyPinTests` over `Shared/` + `VariorumMobile/` finds only its named exemption
(`SampleLibraryWelcome.swift`). This run's phone code, read site by site:
- batch 5's Library model — four raw `lastError` writes (`prime`, `holdFirstPage`, `reread`, `loadMore`): converted to
  `OpsRefusalCopy.sentence(for: error, roads: .phone)` IN THE MERGE (`f03d59ae3`, H2/H3 and the recipe); the slot's
  `didSet` (VM-55's) speaks each on the line. Red without: `MobileNoRawErrorPinTests` (four offending lines).
- batch 6's arrival fallback (`loadLive` → `loadOnce`, whose catch VM-55 converted to `report(OpsRefusalCopy.sentence…)`),
  the chips' fallbacks (`refreshChip` → `refresh()`, whose catches VM-55 routed through `say(…, as: .refusal)` /
  the slot's `didSet`), and `takeAutosaveHold`'s error hook (→ `reportOperationError`, which VM-55 made
  `report(OpsRefusalCopy.sentence…)` — the same road `init`'s hook speaks): already on VM-55's seam, nothing to change.
- batch 2's fence: the gate belt's `refuse(StructuralUndoCopy.anotherIsLanding)` (VM-55 made `refuse` call `report`) and
  the drain's `report(StructuralUndoCopy.anotherIsLanding, action: statusAction)` — both now reach `MobileLine.say(…, as:
  .refusal, door: undoDoor)`, the line, with the one existing sentence. Nothing to change.
- batch 1's timing store (`MobileTimingStore`) shows no message (its file failures are `try?`, silent); the readout's
  text (`MobileTimingCopy.report`) is a table, not a status. Nothing to change.
- No site was left on the generic road for want of a sentence.
**One consequence, carried to QUESTIONS below (P-2-2 meets VM-61):** `MobileLine.say` first takes back the note's
standing structural-Undo line (VM-61's carriage of M20's law) before it speaks. So when a removal-class door (merge,
block delete, archive, whole-paragraph delete, the cross-block compound) refused or withheld a key during its flight, the
drain's sentence replaces that door's line AND its Undo; the model's `statusAction` still holds `.undo`, which no face
draws since VM-61 took the masthead's row, and the Undo stays in the ⋯ sheet. P-2-2 said "keeps the door's action" —
true of the masthead row it was written against, not of the one line.

#### (c) `Shared/AppSession.swift` (no change)

Merged clean. `savepointOnLeaving` and `releaseAutosave` are byte-identical to this branch before the merge (extracted from
`48919f693` and `HEAD` and compared: 98 and 21 lines, no difference) — so the Mac's statements on the savepoint road are
unchanged by the merge, and the phone's branch (batch 7, with the ladder's corrected comments — the one-ask gap and its
bound) and the phone's `releaseAutosave` (an entry goes only at zero holders and a clean coordinator) stand as built. The
merge's only change in the file is VM-55's: `let status = StatusCenter()` left the second `#if os(macOS)` block for the
shared section beside `undoMenuState` (line ~233), so the phone's `report` reaches `session.status`.

#### (d) `MobileShellView.swift` (the one resolved hunk, nothing else)

Read the merged file: VM-55's `wings` / `wingDoor` state and init, the three roots' `wingName:` / `onWingDoor:`, the
wing list sheet, `.onChange(of: wingDoor.landings) { selectPage(.shelf) }`, `.task { await wings.track() }`, the message
line's host and the tab bar's measured height — beside batch 5's `isOnScreen: libraryOnScreen(width: width)` and
`libraryOnScreen` (`libraryPath.isEmpty && MobileShellBand.isDrawn(…)`), and batch 1's `.onAppear {
MobileTiming.homeAppeared() }`. A pick's landing goes through `selectPage(.shelf)`, so the Library's on-screen fact
falls with the page change and the hold restarts as (a) says; the list sheet over the Library root leaves the Library
drawn (held) while it stands — the drawn-at-all rule (P-68-3). Both runs' additions are kept; nothing changed after the
resolution.

#### (e) The timing marks (no change)

Every case of `AppTiming`'s catalog (23 series, 14 counters) is referenced by its mark function, and every mark function
has its app call site on the merged tree (a grep of `AppTiming.<fn>(` over `Shared/`, `VariorumMobile/`, `Variorum/`):
in the shared files — `MobileQuickNote.swift` (`boxOpenPressed`, `boxFilingStarted`/`Ended`, `boxFocused`),
`MobileShellView.swift` (`MobileTiming.homeAppeared` → `homeOnScreen`), `MobileWriteView.swift` (`noteRequested`,
`noteArrived`, `noteLeaving`, `noteLeft`), `MobileEditorViewModel.swift` (`editorBuilt`, `noteProjectionLoaded`,
`noteProjectionFetched`, `noteProjectionDelivered` ×2, `noteProjectionRefreshed`, `MobileTiming.noteRendered` →
`notePainted`), `MobileLibraryViewModel.swift` (`libraryFetched`, `libraryDelivered`), `AppSession.swift`
(`savepointAttempted`, Mac and phone), `AppBootstrap.swift` (`libraryOpened`, `unlockAccepted`); and outside them
`AutosaveCoordinator.swift`, `AppServices.swift`, `SyncSession.swift`, `MobileTiming.swift`, `MobileRoadFaces.swift`,
`VariorumMobileApp.swift`. `openLeavingWindow`, `afterNextFrame` and `NextFrameTick.schedule` are internal helpers. The
merge DROPPED none and MOVED none (the timing files themselves are untouched by it; only line numbers shifted). What
the marks measure is unchanged, with one scope note: "Library ready" (the note listing's first landing) and the
Library's fetch/delivery counters now count reads of the current wing's listing (VM-56) — the count, not the meaning.

#### (f) The fence and the hold (no change)

The merge brought into `MobileEditorViewModel.swift`, `MobileStructural.swift`, `MobileUndoDoor.swift` and
`MobileWriteView.swift` exactly VM-55's own changed lines (each file's merge diff compared with VM-55's diff from the
base: identical), so nothing of this run's was altered there. Read on the merged tree: the latch hooks
(`structuralInFlight` / `inFlight` `didSet` → `structuralFlightChanged()`), the Insert Below exemption, the gate belt
(`refusesPolicedEdit` → `refuse(…anotherIsLanding)` → `report` → the line), the storage belt and the settle, the drain
(deferred out of a projection apply, as before — VM-55's `report` adds a status write, still outside the apply),
`reportOperationError` (VM-55's `report(OpsRefusalCopy.sentence…)`), `takeAutosaveHold` (both paths re-observe; its
hook through `reportOperationError`) and `releaseAutosaveHold`; and the leaving task's order — VM-55's
`MobileLine.withdrawNoteLine` and `deregister` first (synchronous, before the task), then in the one task
`teardown()` (the flush) → `savepointOnLeaving` → `releaseAutosaveHold(ifNotShownSince:)` → `AppTiming.noteLeft`.
`storageDidEdit`'s routing, `fallbackVerdict` and `EditorEditRouting` not opened.

#### Step 3 — the registry comment (comment only)

`MobileHerPathsPerfTests.theAutosaveRegistryAcrossOpensAndCloses`' doc said the editor "releases its one acquisition at its
end of life, which the leaving task holds" — r0's mechanism. Now: the release is the leaving's last act (teardown's flush,
the leaving savepoint, then `releaseAutosaveHold(ifNotShownSince:)`), never at the editor's end of life.

#### Evidence (headless and built; no hosted run — the stage is the orchestrator's)

- **The whole Core package, `swift test`, once, at the end of the edits** (tree `66ac9d503`; no Core line changed by the
  merge — VM-55 wrote zero `Sources/` lines — or by this session): **4,913 tests in 710 suites passed, 0 failed**, across
  the three test products — `VariorumMCPTests` 703 in 130 · `VariorumCoreTests` 4,178 in 576 "with 5 known issues" ·
  `StringsWorkbookTests` 32 in 4; XCTest "Executed 0 tests" ×3. The 5 known issues are declared (`withKnownIssue`):
  `PairInvariantPinsTests.theGuardBitesOnALockOffTheVaultsDescriptorAndAStaleCopy` 4 and
  `PairCatchUpTests.theResidualCastleAlwaysAskWithOnlyAPassphraseAtTheLobbyHealsAtTheWords` 1. 15 gated harnesses skipped
  (counted in N by Swift Testing — the resiliency protocol's note): `aFirstCatchUpsApplyTimedByPhase`,
  `aLeavingSavepointOnAHundredThousandWordNote`, `basicOfflineEditsConvergeOverTheRealServer`, `bench(notes:)`,
  `directCost(shape:)`, `fts5InsertCostByTableShape`, `memberIDPredicateVersusTheJoin`,
  `ownerAdoptionWithNothingToAdoptOnAnEncryptedStoreAtHerScale`, `plans`, `prefixSizing(prefix:)`,
  `probeTheLinkedSQLite`, `seamHistoryCost`, `theThreeRoads`, `variantInsertCostByTriggerSet`,
  `writeLatencyWithHeldObservations(shape:)`. Log `App/Variorum/DerivedData/vm64-gate-swifttest.log` (local).
- **Builds** (M10, M11): `vm64-gate` — phone and Mac `build-for-testing` at `f4068b3cf`, both SUCCEEDED, 0 errors (every
  commit after it is this record alone, so the products are the tip's code); `vm64-gate-red` — phone, finding 2's hunk
  reversed, SUCCEEDED, restored. Products: `App/Variorum/DerivedData/vm64-gate/Build/Products/{VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64,Variorum_Variorum_macosx27.0-arm64}.xctestrun`
  and `App/Variorum/DerivedData/vm64-gate-red/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`.
- **Scans** (mirrors, (b)): VM-55's two source-scan pins clean on the merged tree but for their named exemptions.

#### The stage commands (the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

(i) **The ladder's finding-2 pin**, the hold suite ALONE on each build:
```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate \
  -only-testing:VariorumMobileTests/MobileNoteHoldTests 2>&1 | tee <log-gate-hold>
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate-red \
  -only-testing:VariorumMobileTests/MobileNoteHoldTests 2>&1 | tee <log-gate-red-hold>
```
Expected: `vm64-gate` — 5 tests in 1 suite passed. `vm64-gate-red` — `aScreenShownAgainBeforeItsLeavingFinishedListensToItsCoordinator`
FAILS with 2 issues (the two `observesAutosave` expectations — after the re-show, and again after the leaving ends);
the other four pass.

(ii) **The merge's own types**, ONE invocation, `vm64-gate`:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileWingListingTests MobileWingStandTests MobileWingDoorTests MobileWingDoorShellTests
  MobileWingDoorGeometryTests MobileWingListSheetTests MobileLibraryPagingTests MobileLibraryPagingRulesTests
  MobileNoRawErrorPinTests MobileErrorLogPrivacyPinTests MobileLineShowRuleTests MobileLineDoorTests
  MobileStructuralFlightFenceTests MobileUndoDoorTests MobileNoteOpenOnceTests MobileLeavingSavesOnceTests
  MobileLibraryTests MobileFilterTests MobileNavigationTests MobileShellTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-gate-merge>
```
Expected: all green — VM-55's four re-landed pins with their unchanged expectations, the new guard
`MobileLibraryPagingTests.aWingSwitchedWhileTheLibraryIsAwayIsHonouredOnTheReturn`, `theHoldKeyNamesTheShownListing`
with its wing lines, the two scans (no offender), the fence suite and the undo door in company.
(iii) **The perf suite ALONE**, `vm64-gate` (it reads the process's one recorder; the nine-wing fetch series now read the
current wing — (a)): `-only-testing:VariorumMobileTests/MobileHerPathsPerfTests`; expected 13 passed. *[Ladder round 2, O-1: on a tree from `c42078746` on, the suite is gated — the same run needs
`TEST_RUNNER_VM66_PERF=1` in front of `xcodebuild`, and a whole-target run (iv) SKIPS its 13 (counted in Swift Testing's
"N tests … passed"; read the skipped lines). `vm64-gate`'s products predate the gate and run it without the switch.]*
(iv) **The merge gate** — the whole phone target and the whole Mac target from `vm64-gate` (`.xctestrun` above), the
orchestrator's windows. Expected reds from main only: VM-24's `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
(2 of 3 cases) on the phone; on the Mac the standing flake VX-701 if it appears (re-run alone).

#### For QUESTIONS at the merge

1. **P-2-2 meets VM-61's one line — the fence's sentence after a removal-class door's flight.** P-2-2 (batch 2, r2): when
   keys were refused or withheld during a flight, the after-flight sentence ("Another structural change is still
   landing.") replaces the door's worded receipt and "keeps the door's action" — written against the masthead's status
   row, which drew the Undo beside it. VM-61 retired that row: the one line draws a refusal without an Undo, and
   `MobileLine.say` first takes back the note's standing structural-Undo line (M20's law carried onto the line). So after
   a merge, a block delete, an archive, a whole-paragraph delete or the cross-block compound whose flight refused a key,
   the line ends on the refusal with no Undo; the Undo stays in the ⋯ sheet (and the model's `statusAction` still holds
   it, unread). Options: (a) **as merged** — no line written; the refusal wins the line, VM-61's law holds; (b) the drain
   speaks through the door's own class (`.removal(.structural)` with the sentence), keeping the Undo beside it — a refusal
   drawn in a removal's ink, outside VM-61's class table; (c) a seam change letting a refusal carry its door's Undo — new
   behaviour in VM-61's seam. **Left at (a), PROVISIONAL**; hers with P-2-2 and P-55-3/P-55-5. No other product question
   from the merge.

#### What a cold reviewer should read first

1. **H3's trap** — "ours" in every diff3 region compiles to `holdFirstPage` with no catch (the 3-way applies VM-55's
   removal of the base `startBookless` catch to the shared text). Verify by diffing `MobileLibraryViewModel.swift` at
   `f03d59ae3` against both parents: against `d10b167b2` it differs by VM-55's six hunks and the four converted lines
   only; against `eb18888db` by batch 5's whole listings section, minus VM-55's `follow` bodies.
2. **The re-landed VM-55 pins** — `holdLibraryAsItsViewDoes` against `MobileLibraryView`'s `.task(id: hold)`: is the
   helper the view's road, and do the four pins still mean what VM-55 wrote (their expectations are unchanged)?
3. **`.task(id:)` cancels, `follow` awaited** — the stale-landing window in (a) and why it is batch 5's existing one.
4. **The nine-wing comparison's scope** ((a), last bullet) — a recorded series re-scoped so the comparison stays like for like.
5. **P-2-2** above.

### Ladder round 2 — fix pass (implementer closeout; first turn)

**Not done in this turn (first, by the record's rule):** NO BUILD of any kind — a QUIET window (another run's merge gate)
began at 15:13, so the phone and Mac `build-for-testing` into `App/Variorum/DerivedData/vm64-gate2/` and the red-on-old
phone build into `vm64-gate2-red/` are OWED (recipes below); every new and changed app-target line is therefore UNCOMPILED
as this is written. No hosted run (the stage's). Finding 1's Put back leg is NOT applied (its seam is in VM-55's
`MobileLine`, fenced — the responses' arms (A)/(B)/(C), waiting for the final call). Finding 2 is NOT applied
(the specified one-fact shape fences her ordinary road; it rides VM-226 — the responses). The whole Core package
`swift test` is owed once, on the final tree, in the second turn. No Core file changed this turn, so no Core suite was
touched or run. No line in `Sources/VariorumCore/Sync/`, `Server/`, custody/keychain code or
`VariorumMobile/Features/Protection/`; no schema change; `MobileEditorViewModel.swift` untouched; VM-55's `MobileLine`,
wing door and `MobileWingScope` untouched; no shared ledger edited; no new user-facing copy.

**Base:** `85762803a`. **Commits:** `9c21ee40f` (live status) · `35551e25f` (the responses, before any code) ·
`64af6d64a` (findings 1 and 3 + pins) · `6b6c288b1` (finding 8(a) + pin) · `28dc98ac5` (finding 9) · `c42078746` (O-1) ·
`f45d25498` (the record's corrections) · `8eeafb614` (the handoff and the drafts) · this closeout.

#### What changed, finding by finding

| # | Call | What landed |
|---|---|---|
| 1 · MAJOR (Part of VM-68) | AGREE; delete and ★ legs applied; Put back leg waits | `MobileLibraryViewModel.swift`: `reaskAfterRowAct(_:)` (re-asks the shown listing at its listed depth through `followFirstPage`, only when deeper than a page, only for the question its rows answer, only while held — a new `Paging.holds` count raised and lowered by `holdFirstPage`), called by `confirmDeleteNote` after the op lands; `rowStarLanded()` (Bookless only). `MobileLibraryView.swift`: the row's star button tells the model after `stars.toggle`. The enumeration of every Library-row and line act is the responses' table |
| 2 · MINOR (VM-2) | AGREE with the hole; DISPUTE the one-fact shape | nothing — the trace and the VM-226 proposal (the reviewer's pin + an ordinary-road guard with the live observation running) are the responses' |
| 3 · MINOR (Part of VM-68) | AGREE; applied as proposed + the union's books | `MobileLibraryViewModel.swift`: an OBSERVED `landedWing` set in `land`; `answersCurrentWing(_:)` gates `visible`, `emptyListing` and `rows(books:)`'s books |
| 4 · MINOR | the orchestrator's | its stage results go in §5 (the orchestrator's) |
| 5 · MINOR (Part of VM-68) | AGREE | §7 batch 5's cost table "On screen" cell and its floor paragraph's scope (in place, first text kept); the handoff's "Rulings reconciled" row; the drafts' (b) VM-68 paragraph and (g) row 23. Ticket body: the report |
| 6 · MINOR (VM-2) | AGREE | the handoff's P-2-1 and P-2-2 (P-2-2 now carries the one-line meeting, options (a)–(c), in plain words); the drafts' bundle P-2-1 clause and P-2-2; the drafts' (e)5 fence line narrowed to the reviewer's guarantee; §7 batch 2 r2's "What is dropped" paragraph marked in place |
| 7 · NIT | AGREE | VM-227's paragraph: the report |
| 8 · NIT (VM-65) | (a) applied; (b) the caveat | (a) `Shared/AppTiming.swift` `boxOpenFiledNothing()` (the recorder's existing `cancel`, both Open spans) called from `MobileQuickNote.open()` when `file()` returns nil. (b) the handoff's readout step ("leave about ten seconds between the two") and a bracketed note on batch 1's "what each number means" row — why not the code: the responses |
| 9 · NIT (VM-65) | applied | `MobileTiming.swift`: `print` → `fingerprint`. `MobileTimingView.swift`: the heading no longer `.uppercased()` (the readout alone forced capitals on screen — the edit trace's screen draws mixed case, Settings' header is a plain label); `MobileTimingTests`' three heading expectations follow, plus one holding the title not upper-cased. The recorder: unchanged |
| O-1 (VM-66) | applied | `MobileHerPathsPerfTests`: `.enabled(if:)` on `VM66_PERF` (`TEST_RUNNER_VM66_PERF=1`), its display name, the skip's comment, the header's mechanism sentence corrected; the record's batch 3 group (i), the merge-in (iii), the handoff's "The next runs", the drafts' VM-66 paragraph, (e)6 and the PR line corrected. Confirmed by reading: the scheme's `parallelizable = "NO"` is built into the phone xctestrun as `InProcessParallelizationEnabled = false` |

**The Mac does not change:** the one `Shared/` line is a new static function in `AppTiming` (the box's cancel), whose only
caller is the phone's `MobileQuickNote`; on the Mac it has no caller and every mark stays one relaxed atomic load. Checked
by grep: `boxOpenFiledNothing` appears in `Shared/AppTiming.swift` and `VariorumMobile/Features/Shell/MobileQuickNote.swift`
only. Every other production line is phone-only (`VariorumMobile/`). The Mac build is owed with the phone's (`vm64-gate2`).

#### The pins, and what each build should show

| Pin | Kind | `vm64-gate2-red` (expected) | `vm64-gate2` (expected) |
|---|---|---|---|
| `MobileLibraryPagingRulesTests.aRowDeletedPastTheFirstPageLeavesTheListing` | bug pin (finding 1, delete) | RED — 2 issues ("the deleted note left the listing"; "the listed depth is kept") | green |
| `MobileLibraryPagingRulesTests.aWingSwitchedWhileBooklessWasNotHeldDrawsNoOtherWingsRows` | bug pin (finding 3) | RED — 2 issues ("no frame draws another wing's note"; `visible.isEmpty`); the empty-line and return expectations green | green |
| `MobileLibraryPagingRulesTests.aDoorOpenedAfterAWingSwitchDrawsNoOtherWingsRows` | bug pin (finding 3, the filter door) | RED — 1 issue ("the door draws no other wing's note") | green |
| `MobileLibraryRowActsTests.aStarThatTakesADeepRowOutOfTheLooseClassReAsksBookless` | design pin (finding 1, ★ — names the new door) | NOT IN THE BUILD (moved aside) | green |
| `MobileBoxOpenTimingTests.anOpenThatFilesNothingLeavesNoOpenSpan` | bug pin (finding 8(a)) | RED — 4 issues (both spans open; a false sample each) | green |
| `MobileBoxOpenTimingTests.anOpenThatFilesIsStillTimed` | guard | green | green |
| `MobileTimingTests.theReadoutShowsThisBuildThenThePreviousOne` | finding 9's expectations | RED — 3 issues (the heading line twice, the title not upper-cased) | green |
| The rest of `MobileLibraryPagingRulesTests`, `MobileTimingTests` | unchanged | green | green |
| Finding 1's Put back pin (press the line's own Undo after a deep delete; the row listed again) | bug pin | — lands with the final call's arm (second turn) | — |

#### The builds owed (when the QUIET window ends — the second turn, on the final tree)

```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm64-gate2
xcodebuild build-for-testing -project Variorum.xcodeproj -scheme Variorum \
  -destination 'platform=macOS' -derivedDataPath DerivedData/vm64-gate2
```
The red-on-old phone build (announced in the live status and committed before it starts; it reverses THIS PASS'S
production hunks only — findings 1, 3, 8(a) and 9 — and moves aside the one pin file that names the new door):
```
cd ~/dev/variorum-vm-64
files=(App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift
  App/Variorum/VariorumMobile/Features/Shell/MobileLibraryView.swift
  App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift
  App/Variorum/Shared/AppTiming.swift
  App/Variorum/VariorumMobile/Features/Perf/MobileTimingView.swift)
git diff 85762803a HEAD -- $files | git apply -R
mkdir -p App/Variorum/DerivedData/vm64-gate2-aside
mv App/Variorum/VariorumMobileTests/MobileLibraryRowActsTests.swift App/Variorum/DerivedData/vm64-gate2-aside/
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm64-gate2-red
cd ~/dev/variorum-vm-64 && git checkout HEAD -- $files App/Variorum/VariorumMobileTests/MobileLibraryRowActsTests.swift
rm -rf App/Variorum/DerivedData/vm64-gate2-aside
git status --short   # must be empty
```
(`MobileTiming.swift`'s rename is not reversed: it changes no behaviour. If the Put back leg lands in the second turn,
its hunks join the reversed set.)

#### The hosted commands (the orchestrator's stage; the GO's claim line and UDID fill `<simulator-udid>`)

(i) **The red-on-old run**, ONE invocation from `vm64-gate2-red`:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileLibraryPagingRulesTests MobileBoxOpenTimingTests MobileTimingTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2-red \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-r2-red>
```
Expected: exactly the RED column above, every other test in those three suites green.

(ii) **The fix and its company**, ONE invocation from `vm64-gate2`:
```
tests=(MobileLibraryPagingRulesTests MobileLibraryRowActsTests MobileBoxOpenTimingTests MobileTimingTests
  MobileLibraryPagingTests MobileLibraryTests MobileLibrarySortTests MobileFilterTests MobileEmptyStoreTests
  MobileWingListingTests MobileWingStandTests MobileWingDoorTests MobileWingDoorShellTests MobileLineDoorTests
  MobileLineShowRuleTests MobileStarsTests MobileQuickNoteTests MobileNoRawErrorPinTests MobileHerPathsPerfTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-r2-fix>
```
Expected: all green, and `MobileHerPathsPerfTests`' 13 SKIPPED (no switch handed — the gate's own proof; Swift Testing
counts them in "N tests … passed", so read the skipped lines).

(iii) **The perf suite gated and alone**, `vm64-gate2`:
```
TEST_RUNNER_VM66_PERF=1 xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2 \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests 2>&1 | tee <log-r2-perf>
```
Expected: 13 tests in 1 suite passed, none skipped.

(iv) **The merge gate** — the whole phone target and the whole Mac target from `vm64-gate2`: the perf suite's 13 skipped
on the phone; the expected reds are main's (VM-24's caret test, 2 of 3 cases; VX-701 on the Mac if it appears).

#### For QUESTIONS at the merge

None from this pass — no product behaviour was decided. Finding 1's Put back arm and finding 2's disposition are the
reviewer's engineering calls; P-2-2's options (a)–(c), already the merge-in closeout's item, now also sit in the handoff
and the drafts' bundle.

#### What a cold reviewer should read first

1. **Finding 2's dispute** (the responses): the ordinary road where a delivery's `.refetchFresh` re-read is in flight at
   the latch drop after the door's own settle rendered the post-act page — is today's "settled" right there, and does
   the one-fact shape refuse keys on it?
2. **`reaskAfterRowAct`'s guards** — the `holds` count against `.task(id:)`'s overlap (the next hold starts before the
   last one's `defer`), and the question match.
3. **`landedWing` is observed** (a landing that moves only the wing must redraw) and `.some(question.wing)` (a nil scope
   is a value, never a removal); and the union's books withheld while the notes answer another wing.
4. **The uncompiled state** — no build ran this turn (QUIET); the second turn's builds are the first compile of these
   lines.

### Ladder round 2 — fix pass, second turn (implementer closeout)

**Not done (first, by the record's rule — rewritten at part B's close; part B is DONE, below):** NO PIN OF THE PASS HAS
RUN — every hosted run is the orchestrator's stage window ((i)–(iv) below, from the products part B built); the pass's
lines now COMPILE (phone and Mac) but are unproven by any run until then. The merge gate, the batches 6 + 7 walk and
round 3 (if any) are the orchestrator's. *(The first text, kept: "part B — the pass's FIRST compile …, the whole Core
package `swift test` once on the final tree, and the red-on-old phone build into `vm64-gate2-red/` — waits for the
orchestrator's word that the QUIET window (from 15:13) has ended, so EVERY app-target line of this pass … is still
UNCOMPILED as this part is written, and no pin of the pass has run.")* No line in `Sources/VariorumCore/Sync/`, `Server/`,
custody/keychain code or `VariorumMobile/Features/Protection/`; no schema change; `MobileEditorViewModel.swift` untouched
by the whole pass (`storageDidEdit`'s routing, `fallbackVerdict`, `EditorEditRouting` not opened); VM-55's `MobileLine.swift`
gains exactly ONE line and no other VM-55 file is touched; no new user-facing copy; no shared ledger edited.

**Base:** `31630a151` (the reviewer's final calls). **Commits:** `28943ac9d` (live status) · `686a07d13` (finding 1's Put
back leg, arm (A), with its pin and the witness) · `2c8911ac0` (O-1's company-safe guard) · `167483f4d` (the timing suite's
header, comment only) · `1dd921f7e` (the handoff and the closeout drafts) · this closeout. **Machinery honesty:** this is a
FRESH session; the first turn's implementer reached its context limit after its closeout, with nothing uncommitted (the
tree clean and pushed at `31630a151`) — nothing was adopted from a dead tree.

#### What changed, per final call

| Final call | What landed |
|---|---|
| 1 · the Put back leg — arm (A) (Part of VM-68) | **(i)** `MobileLine.putBack`, inside its `do`, the line after `try await session.runner.run(body)`: `NotificationCenter.default.post(name: .variorumPutBackLanded, object: session)` (a trailing comment on the same line) — the success path only; a refused Put back reaches the `catch` and posts nothing; `unarchive` is a different function and posts nothing. The name is declared with its listener: `extension Notification.Name { nonisolated static let variorumPutBackLanded }` at the end of `MobileLibraryViewModel.swift`. **(ii)** the listener lives INSIDE the hold: `holdFirstPage` registers it first (`listenForPutBack(question.listing)`, `addObserver(forName:object: session, queue: .main)`) and removes it first in its `defer` — so it hears only while a hold runs, which is only while the Library's view is on screen holding that listing (hidden, the return's first delivery re-asks anyway); `object: session` is NotificationCenter's identity filter, so another session's signal never reaches it; it answers through `reaskAfterRowAct(listing)`, so the first turn's guards hold unchanged (held, the question its rows answer, deeper than a page; a Put back inside the first page stays the held observation's). No second spelling of the op, the refusal words or the line. **(iii)** `MobileLine.swift:139-141`'s comment is untouched (now true past the first page). Two overlapping holds (`.task(id:)` starts the next before the last one's `defer`) both hear the signal; the follow's single flight folds them into one re-ask and at most one more |
| 1 · the pin | `MobileLibraryPagingRulesTests.aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage` — the final call's words: limit 4, 12 notes, held on screen, 8 listed; the seventh row deleted through `confirmDeleteNote`; the line's own Undo read off the line as it spoke (`try #require(session.status.current?.action)` — non-nil required; read right after the delete so the line's 6 s clock cannot race a slow settle on the red build); settle until gone; the Undo pressed; settle; the note listed again, `model.all` equal to `Queries.library`'s first 8, no note twice |
| 1 · a witness (added, said so) | `…aPutBackAfterTheLibraryCameBackReturnsARowPastTheFirstPage` — the same world and Undo, but the hold ended and taken again between the delete and the Undo (the Library left and returned), whose re-ask removes the deleted row on EVERY build. **Why:** `vm64-gate2-red` reverses the delete leg too, so there the final call's pin fails at its premise (the row never leaves) and its Put back arm is vacuous; this witness is the only test whose red on that one build is the Put back arm itself |
| 2 | no code (dismissed to VM-226 by the final call); the handoff's VM-226 line gains the second road in plain words; the drafts' residuals row 7 and new row 48 carry it |
| 3, 8(a), 9 | no change (confirmed as applied); their conditions are the red and fix runs below |
| 5 | no change (confirmed as applied); its ticket is VM-240, which fills the first turn's `PENDING(id)` in the handoff and the drafts |
| 6 | the handoff's P-2-1: "Nothing old is ever written" → "A key refused or held back this way never writes old text", with a pointer to the two rarer roads listed lower in the same file |
| 7 | the ticket's body is the orchestrator's (already in VM-227); the drafts' residuals row 27 names it |
| O-1 · condition 1 | the gate's legs are the stage commands below ((iii) the gated suite alone; (iv) the whole phone target saying its 13 SKIPPED); the drafts' MobileSoul sentence ((e)6) gains "a phone merge gate runs it as its own leg"; the handoff's "The next runs" says the same in plain words |
| O-1 · condition 2 (VM-66, VM-69) | `MobileNoteOpenOnceTests.anOpenReadsTheNoteOnceAndTheOldShapeTwiceByTheSameOracle` — a GUARD, test-only. The oracle: the suite's existing statement trace on the world's one connection (an in-memory queue), counting `OpenOnceTrace.projectionRead` — `Queries.takesProjection`'s header leg, `SELECT locked, profile, entry_date FROM container WHERE id = ?`, which runs once per projection read and in no other read (checked by grep: `TakesQueries.swift:100` only; `containerHeader` is a record fetch). **Arm 1:** the real `MobileWriteScreen` with a router (her road) — counted from the mount through the first live delivery (the arrival's render, which IS it since VM-69) plus a 1.5 s quiet window: ONE. The liveness grant owes no re-read: a first open registers `refresh: false` (`MobileLivenessAuthority.register` → `takeLiveness`: the flush, then `confirmNoteStillLive` — the header record only), so nothing of the grant's is folded in. **Arm 2:** the harness's old shape on another note — `loadOnce()`, then `start()` beginning its own observation; its first delivery seen as the model's second chrome pass; the same window: TWO. Green on both builds of the round (both hold batch 6); the red-on-old proof of "read once" stays the gated suite's (`note-reads-per-open-*`, 2 → 1) |
| O-1 · the ticket | VM-241 (Medium · Debt · Todo) — in every list of the run's tickets |
| the optional ticket | VM-242 (Low · Bug · Backlog) — in every list |
| records | the handoff (P-2-1's scope; VM-226's second road; the gate's own step; VM-240/241/242 in "Tickets filed" in priority order, in "What was found and not fixed" and in the reconciled table); the drafts ((b) the VM-68 paragraph gains finding 1 and VM-240, the Born line every id with its labels; (c); (d); (e)5 "an act on a listed row re-asks it in place"; (e)6 the gate's leg; (g) rows 7/23/27 and new rows 45–48; the three tickets' section; the header's slot list); `MobileTimingTests`' header ("the suites run in parallel" corrected — comment only); `MobileLibraryPagingRulesTests`' header (round 2's pins ARE in that round's red build) |

**The Mac does not change:** this turn touched no file under `Shared/` or `Sources/` (`git diff --stat 31630a151..HEAD --
App/Variorum/Shared Sources` is empty); over the whole pass the one `Shared/` line is the first turn's
`AppTiming.boxOpenFiledNothing` (its only caller `MobileQuickNote.swift`; on the Mac no caller, every mark one relaxed
atomic load). The Mac build is owed with the phone's because of that line.

#### Part B — the merge of main (VX-981), the first compile, the whole Core package, the red build (builder; a FRESH session)

**Machinery honesty:** a third session, opus, fresh, briefed by the orchestrator after the QUIET window ended — the
second turn's session had reached its context limit at `e3412bee4` with the tree clean and pushed; nothing was adopted
from a dead tree. **Commits:** `f850d1af4` (the merge) · `74d91c666` (live status) · `e1e87dda0` (S4) · `b44622e62` (S5,
and the revert announced before it started) · this closeout. **Every commit after `74d91c666` is this record alone**
(`git diff --stat 74d91c666 HEAD` names only `notes/plans/fixes/vm-64-timing-and-lags.md`), so `74d91c666` IS the final
code tree.

**(1) Main's `7629cf049` merged in — `f850d1af4`, "Merge main (VX-981) into vm-64-timing-and-lags".** `git merge-tree`
first (clean), then `git merge --no-ff 7629cf049` (a merge commit; never a rebase or squash); no conflict in any file,
code or notes. `7629cf049` is a true merge on `eb18888db`, which the branch already held, so it brought the VX-981 branch
alone: Core's `Operations/UndoStack.swift`, `Queries/MCPGrantQueries.swift`, `Queries/PrivateMarkQueries.swift`, the
`VariorumMCP`/`VariorumMCPSocket` sources, their tests, the project file (`MARKETING_VERSION` 1.4 → 1.5, both Mac
configurations — nothing else in it), the Mac app's MCP door and its Private-mark faces (`Core/Views/` `MCPNoteIndicator`,
`PrivateMark`, `PrivateMarkView`; the Library catalog, the Shelf, the book panel and settings sheet; the tutorial
seeder), `ReleaseNotes-1.5.md`, thirteen Mac test files (`VariorumTests/` — the whole Mac target's count at the merge
gate rises by them), and VX-981's notes. Nothing under `App/Variorum/Shared/`, `VariorumMobile/` or
`VariorumMobileTests/`. `git merge-base --is-ancestor 7629cf049 HEAD` holds.

**(2) The semantic check — NO COLLISION.** Read: `git diff eb18888db 7629cf049 --` the three Core files.
- **`UndoStack.swift` against the phone's undo door** (`VariorumMobile/Features/Write/MobileUndoDoor.swift`, hooked to
  the keystroke fence by this run): VX-981's change is ADDITIVE — a `Walk` value, `newestEntryID`,
  `entryIDs(newerThan:)`, `addWalkObserver`/`removeWalkObserver`, and one `notifyWalk(…)` call after `notifyChange()` at
  the end of `undo(with:)` and `redo(with:)`, outside the lock. The door calls exactly `pendingUndoWarning(with:)`,
  `undo(with:)` and `redo(with:)`: their signatures, their `Outcome`, the failed-inverse-stays rule and the change
  observer are unchanged. The fence hook is the DOOR's own `inFlight` latch (raised before the awaited runner call,
  lowered in its `defer`, `model?.structuralFlightChanged()` on each flip) — it reads nothing of the stack's, so the
  added notify (synchronous, on the runner's thread, before the call returns) cannot move the latch's timing. The only
  walk observer in the tree is the Mac's `MCPDoor` (`Features/MCP/MCPDoor.swift:395`); on the phone the walk list is
  empty.
- **`PrivateMarkQueries.swift`**: `privateBookMarks` / `privateBookMarksDrawn` change their RETURN TYPE (`Set<String>` →
  `[String: PrivateBookMark]`) and `PrivateMark` gains `journalEntry`/`viaJournals`/`journalFenced`/`isFenced`
  (`isPrivate` keeps its meaning, "by the mark"). Nothing this run wrote, and nothing under `Shared/` or `VariorumMobile/`,
  calls any of them (grep: no match) — the Mac's callers came with the merge, and both builds below compile them.
- **`MCPGrantQueries.swift`**: the journal legs factored into named fragments (`journalEntryLegForNote`,
  `journalMemberLegForNote`, `fenceMemberRowSQL`), the same SQL text; nothing this run calls.

**(3) The first compile — both builds GREEN, NO compile fix.** Built at `74d91c666` (the merged tree):
- phone — `xcodebuild build-for-testing -scheme VariorumMobile -destination 'generic/platform=iOS Simulator'
  -derivedDataPath DerivedData/vm64-gate2`: `** TEST BUILD SUCCEEDED **`, 0 errors; no warning in any of the pass's 13
  files (the cold build's 153 distinct warnings are all in files the pass did not touch). Product:
  `vm64-gate2/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`.
- Mac — `-scheme Variorum -destination 'platform=macOS'`, same folder: `** TEST BUILD SUCCEEDED **`, 0 errors; no warning
  in `Shared/AppTiming.swift`. Product: `vm64-gate2/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`.
- Logs and stamps beside the folders (gitignored): `DerivedData/vm64-gate2-phone-build.log` / `-phone.sha`,
  `vm64-gate2-mac-build.log` / `-mac.sha`.

**(4) The whole Core package — `swift test`, once, on the final code tree** (run at `e1e87dda0`, whose code is
`74d91c666`'s; `DerivedData/vm64-gate2-swifttest.log` / `.sha`): **4,971 tests in 721 suites, no red** —
`VariorumMCPTests` 746 tests in 139 suites passed · `VariorumCoreTests` 4,193 tests in 578 suites passed with 5 known
issues · `StringsWorkbookTests` 32 tests in 4 suites passed. Against this branch's baseline (4,913 in 710: 703/130 ·
4,178/576 · 32/4) that is **+58 tests and +11 suites, every one VX-981's** (+43/+9 in the MCP product, +15/+2 in Core —
`UndoStackWalkTests`, `JournalPrivateFacesTests` and the rest of its diff, +59 −1 `@Test` lines and +11 `@Suite` lines
in `git diff eb18888db 7629cf049 -- Tests`); this pass changed no Core file and no Core test. The five known issues, by
name, the baseline's: `theGuardBitesOnALockOffTheVaultsDescriptorAndAStaleCopy()` (4 — `PairInvariantPinsTests.swift:218`
×2, `:223` ×2) and `theResidualCastleAlwaysAskWithOnlyAPassphraseAtTheLobbyHealsAtTheWords()` (1 —
`PairCatchUpTests.swift:408`). Skipped (counted in N): the 15 gated harness tests and 8 gated suites, the same as the
baseline log's.

**(5) The red-on-old phone build — GREEN, the tree restored.** Announced in the live status and committed
(`b44622e62`) before it started; the recipe in "The builds" below, run exactly — no compile fix touched any file it
reverses, so it still reverses exactly the pass's behaviour: `git diff 85762803a HEAD --` the six production files
(`MobileLibraryViewModel.swift`, `MobileLibraryView.swift`, `MobileLine.swift`, `MobileQuickNote.swift`,
`Shared/AppTiming.swift`, `MobileTimingView.swift`; 145 insertions, 7 deletions — `git log 85762803a..HEAD` over them
names only the pass's four code commits `64af6d64a` `6b6c288b1` `28dc98ac5` `686a07d13`, the VX-981 merge touching none)
reversed by `git apply -R`; `MobileLibraryRowActsTests.swift` moved to the gitignored `DerivedData/vm64-gate2-aside/`;
built at `b44622e62` with that reversal into `DerivedData/vm64-gate2-red`: `** TEST BUILD SUCCEEDED **`, 0 errors (the
four pin files compiled in it; `MobileLibraryRowActsTests` not); restored by `git checkout HEAD --` of the seven paths
and the aside folder removed — `git status --short` and `git diff HEAD --stat` both EMPTY afterwards. Product:
`vm64-gate2-red/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64-x86_64.xctestrun`; log and stamp
`DerivedData/vm64-gate2-red-build.log` / `-red.sha`. (`MobileTiming.swift`'s rename stays unreversed, as the recipe
says: it changes no behaviour.)

#### Compile fixes to the first turn's lines

**NONE.** The pass's first compile (part B (3)) built every line of both turns — the first turn's and the second's —
with 0 errors on the phone and the Mac and no warning in a line the pass wrote; no line was edited to make it build.

#### The pins, and what each build should show (the whole pass)

| Pin | Kind | `vm64-gate2-red` (expected) | `vm64-gate2` (expected) |
|---|---|---|---|
| `MobileLibraryPagingRulesTests.aRowDeletedPastTheFirstPageLeavesTheListing` | bug pin (finding 1, delete) | RED — 2 issues ("the deleted note left the listing"; "the listed depth is kept, in the listing's order") | green |
| `MobileLibraryPagingRulesTests.aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage` | bug pin (finding 1, Put back — the final call's) | RED — 1 issue, at the premise ("the premise: the deleted note left the listing"); its Put back expectations pass vacuously there (the row never left) | green |
| `MobileLibraryPagingRulesTests.aPutBackAfterTheLibraryCameBackReturnsARowPastTheFirstPage` | witness (finding 1, Put back — arm (A)'s own red) | RED — 2 issues ("the note Put back is listed again"; "in its place, the listed depth kept, in the listing's order"); its premise green | green |
| `MobileLibraryPagingRulesTests.aWingSwitchedWhileBooklessWasNotHeldDrawsNoOtherWingsRows` | bug pin (finding 3) | RED — 2 issues ("no frame draws another wing's note"; `visible.isEmpty`); the empty-line and return expectations green | green |
| `MobileLibraryPagingRulesTests.aDoorOpenedAfterAWingSwitchDrawsNoOtherWingsRows` | bug pin (finding 3, the filter door) | RED — 1 issue ("the door draws no other wing's note") | green |
| `MobileLibraryRowActsTests.aStarThatTakesADeepRowOutOfTheLooseClassReAsksBookless` | design pin (finding 1, ★ — names the new door) | NOT IN THE BUILD (moved aside) | green |
| `MobileBoxOpenTimingTests.anOpenThatFilesNothingLeavesNoOpenSpan` | bug pin (finding 8(a)) | RED — 4 issues (both spans open; a false sample each) | green |
| `MobileBoxOpenTimingTests.anOpenThatFilesIsStillTimed` | guard | green | green |
| `MobileTimingTests.theReadoutShowsThisBuildThenThePreviousOne` | finding 9's expectations | RED — 3 issues (the heading line twice, the title not upper-cased) | green |
| `MobileNoteOpenOnceTests.anOpenReadsTheNoteOnceAndTheOldShapeTwiceByTheSameOracle` | GUARD (O-1 condition 2) | green (arm 1 one, arm 2 two) | green |
| the rest of `MobileLibraryPagingRulesTests`, `MobileTimingTests`, `MobileNoteOpenOnceTests` | unchanged | green | green |

**Run headless:** nothing — no Core file changed in either turn, so no Core suite is touched by the pass and none ran
under QUIET. The whole Core package: GREEN on the final tree, 4,971 tests in 721 suites, the five known issues the
baseline's (part B (4)).

#### The builds (part B — when the orchestrator says the QUIET window has ended; on the final tree)

```
cd ~/dev/variorum-vm-64/App/Variorum
xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm64-gate2
xcodebuild build-for-testing -project Variorum.xcodeproj -scheme Variorum \
  -destination 'platform=macOS' -derivedDataPath DerivedData/vm64-gate2
cd ~/dev/variorum-vm-64 && swift test   # the whole Core package, once
```
The red-on-old phone build — the first turn's recipe plus arm (A)'s hunks (`MobileLine.swift` joins the reversed set;
`MobileLibraryViewModel.swift`'s listener and the name are already in it, so the two stay consistent). Announced in the
live status and committed BEFORE it starts:
```
cd ~/dev/variorum-vm-64
files=(App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift
  App/Variorum/VariorumMobile/Features/Shell/MobileLibraryView.swift
  App/Variorum/VariorumMobile/Features/Shell/MobileLine.swift
  App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift
  App/Variorum/Shared/AppTiming.swift
  App/Variorum/VariorumMobile/Features/Perf/MobileTimingView.swift)
git diff 85762803a HEAD -- $files | git apply -R
mkdir -p App/Variorum/DerivedData/vm64-gate2-aside
mv App/Variorum/VariorumMobileTests/MobileLibraryRowActsTests.swift App/Variorum/DerivedData/vm64-gate2-aside/
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/vm64-gate2-red
cd ~/dev/variorum-vm-64 && git checkout HEAD -- $files App/Variorum/VariorumMobileTests/MobileLibraryRowActsTests.swift
rm -rf App/Variorum/DerivedData/vm64-gate2-aside
git status --short; git diff HEAD --stat   # both must be empty
```
Results (part B (3)–(5)): phone `vm64-gate2` `** TEST BUILD SUCCEEDED **` 0 errors · Mac `vm64-gate2` `** TEST BUILD
SUCCEEDED **` 0 errors · `swift test` 4,971 in 721, no red, 5 known issues · phone `vm64-gate2-red` `** TEST BUILD
SUCCEEDED **` 0 errors, the tree restored (both checks empty) — no warning in a touched line; no compile fix.

#### The hosted commands — FINAL (the orchestrator's stage; the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Products: `App/Variorum/DerivedData/vm64-gate2/` (phone + Mac, the fix — built at `74d91c666`, the final code tree)
and `vm64-gate2-red/` (phone, this pass's production hunks reversed — built at `b44622e62` with the six files reversed to
`85762803a` and `MobileLibraryRowActsTests.swift` aside); every commit after `74d91c666` is this record alone. **No
compile fix changed any test's name or count, so (i)–(iv) stand exactly as written below** (TYPE names, zsh arrays,
the expected reds). Poll for the Swift Testing verdict line, not `** TEST EXECUTE **`.

(i) **The red-on-old run**, ONE invocation from `vm64-gate2-red`:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileLibraryPagingRulesTests MobileBoxOpenTimingTests MobileTimingTests MobileNoteOpenOnceTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2-red \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-r2-red>
```
Expected: exactly the RED column above — `aRowDeletedPastTheFirstPageLeavesTheListing` 2 · `aPutBackThroughTheLines…` 1
(premise) · `aPutBackAfterTheLibraryCameBack…` 2 · `aWingSwitchedWhileBooklessWasNotHeld…` 2 · `aDoorOpenedAfterAWingSwitch…` 1 ·
`anOpenThatFilesNothingLeavesNoOpenSpan` 4 · `theReadoutShowsThisBuildThenThePreviousOne` 3 — seven tests failing with 15
issues; every other test of the four suites green, the open-once guard among them.

(ii) **The fix types, alone and then in company**, from `vm64-gate2`. Alone — the pass's own types, ONE invocation:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileLibraryPagingRulesTests MobileLibraryRowActsTests MobileBoxOpenTimingTests MobileTimingTests
  MobileNoteOpenOnceTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-r2-fix-alone>
```
In company — ONE invocation:
```
tests=(MobileLibraryPagingRulesTests MobileLibraryRowActsTests MobileBoxOpenTimingTests MobileTimingTests
  MobileNoteOpenOnceTests MobileNoteHoldTests MobileLibraryPagingTests MobileLibraryTests MobileLibrarySortTests
  MobileFilterTests MobileEmptyStoreTests MobileDeletionTests MobileTrashTests MobileVersionsTests
  MobileWingListingTests MobileWingStandTests MobileWingDoorTests MobileWingDoorShellTests MobileWingDoorGeometryTests
  MobileLineDoorTests MobileLineShowRuleTests MobileLineDirectionTests MobileStarsTests MobileQuickNoteTests
  MobileNoRawErrorPinTests MobileErrorLogPrivacyPinTests MobileHerPathsPerfTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2 \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-r2-fix-company>
```
Expected: both all green; in company, `MobileHerPathsPerfTests`' 13 SKIPPED (no switch handed — the gate's own proof;
Swift Testing counts them in "N tests … passed", so read the skipped lines), and VM-55's five wing types
(`MobileWingListingTests` `MobileWingStandTests` `MobileWingDoorTests` `MobileWingDoorShellTests`
`MobileWingDoorGeometryTests`) green beside finding 3's gate — the final call's condition, shown, not assumed.

(iii) **The gated speed suite alone**, `vm64-gate2`:
```
TEST_RUNNER_VM66_PERF=1 xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/vm64-gate2 \
  -only-testing:VariorumMobileTests/MobileHerPathsPerfTests 2>&1 | tee <log-r2-perf>
```
Expected: 13 tests in 1 suite passed, NONE skipped; every asserted count as on the merged tree (reads per open 1, editor
builds per open 1, the hidden Library's re-reads and redraws 0, savepoint attempts 1 on all four roads, owner-adoption
rows 0).

(iv) **The merge gate** — the whole phone target and the whole Mac target from `vm64-gate2`
(`DerivedData/vm64-gate2/Build/Products/*.xctestrun`). Phone: the speed suite's 13 must show as SKIPPED and be said so in
words ("13 skipped — the gated speed suite"), never folded into "passed"; the expected red from main only — VM-24's
`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` (2 of 3 cases, 2 issues).
Mac: the standing flake VX-701 if it appears (re-run alone). The gate's three phone-side lines, each with its counts:
(iv)'s whole target; (iii); and (i)/(ii) — the final call's condition 1.

#### For QUESTIONS at the merge

None from this turn: arm (A) and the guard's shape are the reviewer's engineering calls, and no product behaviour was
decided (a listing made honest after a Put back is the Mac's own rule, `LibraryCatalogModel.refresh`).

#### What a cold reviewer should read first

1. **Arm (A)'s one line and its listener's scope** — `MobileLine.putBack`'s post (success path only; `object: session`)
   against `MobileLibraryViewModel.listenForPutBack`: alive only inside `holdFirstPage` (registered before its `defer`,
   removed first in it), its own session only (NotificationCenter's object filter), answering only through
   `reaskAfterRowAct` and its guards. Is a signal heard by two overlapping holds harmless (the follow's single flight)?
2. **The red-on-old table** above against the run (i): the final call's Put back pin is red on `vm64-gate2-red` at its
   PREMISE only (the delete leg is reversed there too); the witness is arm (A)'s own red. Is the witness's extra step
   (the hold ended and re-taken) a fair stand-in for her road (the Library left and returned while the line still shows)?
3. **The open-once guard's oracle** — the marker statement as "one projection read", the 1.5 s quiet window, and the
   liveness grant's `refresh: false` at a first open (no read of its own folded in); arm 2 telling two from one.
4. **Finding 2 is OPEN under VM-226**, and the fence suite still has no world that runs the editor's live observation
   (`makeSurfaceEditor` calls `loadOnce()` only) — the drafts' residuals row 48.
5. **The uncompiled state** until part B's builds: the first compile of both turns' lines. *(Part B: compiled — phone
   and Mac green with no compile fix; the red build green; the whole Core package green on the merged tree. What
   remains unproven is every run: (i)–(iv).)*
6. **VX-981's merge** (part B (1)–(2)): `UndoStack`'s walk observers beside the phone's undo door's fence hook, and
   `privateBookMarks`' new return type — checked, no collision; read it again if a hosted red lands near either.

### Ladder round 3 — fix pass (implementer closeout; the last round)

**Not done (first, by the record's rule):** NO hosted run — finding 1's three pins are hosted and have not run on either
build; their red-on-old build is NOT made (by the brief: it is made with the gate tree after VM-78's merge-in — the
recipe below). The Mac `build-for-testing` was not run this turn (the brief's one build is the phone's; the Mac compiles
the Core change — see "The Mac" below). The whole Core package was not re-run (the touched suite was). Finding 2's (a)
and (b) — the merge gate and the FOR A LATER READER — are the orchestrator's. Three arms wait for the reviewer's final
call: finding 1's (i′) as built against (i) as written; 5(b)'s `merged` overflow (not applied); 5(c)'s migration comment
(not applied). No line in `Sources/VariorumCore/Sync/`, `Server/`, custody/keychain code or
`VariorumMobile/Features/Protection/`; no schema change (`Persistence/Migrations.swift` untouched); `MobileEditorViewModel.swift`
and `MobileStructural.swift` untouched; `MobileLine.swift` untouched by this pass; no new user-facing copy; no shared
ledger edited.

**Base:** `e78c5f1fa` (code `74d91c666`'s). **Commits:** `9c3b05a49` (live status) · `6cc3f9705` (the responses, before
any code) · `2543a81f3` (5(b) pins, red) · `8d48a682c` (5(b) fix; the response's trap-at-decode claim corrected) ·
`cd828fe16` (finding 1 pins) · `848b98b66` (finding 1 fix; the response's over-read added) · `fb55c3cbf` (the records
and the handoff) · this closeout. **Machinery honesty:** the same session as round 2's part B, continued by the
orchestrator's message; nothing adopted from another session.

#### What changed, per finding

| # | Call | What landed |
|---|---|---|
| 1 · MINOR (Part of VM-68) | AGREE; shape (i) built one clause narrower as (i′) — an arm for the final call | `MobileLibraryViewModel.land`: `if state.question != question { wantsMore = false } else if state.next == nil, page.next != nil, page.items.count <= rows(question.listing).count { wantsMore = true }` with its comment — a listing complete for this question whose re-ask (no deeper than it listed) now carries a cursor asks for the one page after it; the follow's exit starts it. The extra clause keeps (i) from chasing a SHORT complete listing a page reaches past (a first sync onto an empty Library held on screen would otherwise read a second page and hold two). Three hosted pins (below). The caller-by-caller check is the round file's response 1 |
| 2 · MINOR | (a) (b) the orchestrator's; (c) (d) applied | (c) §5's summary rows "Ladder r1 · fix pass" and "Ladder r2 · fix pass" → DONE with the windows that settled them (first texts kept); a "Ladder r3 · fix pass" row. (d) the handoff's "What happened" (a midpoint review and three rounds; round 2's one major in plain words, fixed and seen failing on the old build and passing on the new; `PENDING(merge gate: …)`) and "Reviews" (each round's counts; round 2's major; round 3 the last, its two minor; `PENDING(merge gate)`) |
| 3 · NIT | AGREE by reading; no code (the reviewer's disposition) | the handoff's P-2-4 bullet: the next update ends a stuck fence — except while a save is stuck and cannot land, when typing stays refused in that note until it is closed and opened again, and a refusing Divide or Merge can start it; the drafts' bundle P-2-4 the same (pointing at VM-226); the handoff's VM-226 line in "What was found and not fixed" gains that third way in. VM-226's body: the orchestrator's |
| 4 · NIT | AGREE; caveats, no code | the handoff's readout steps: the Launch row (several launches; the median and the smallest, never one — a prewarmed start can read long) and "Note reads per open" (2 when opened within about ten seconds of an open abandoned mid-load; read the median). Why not code: (b)'s cancel belongs in `loadLive` (`MobileEditorViewModel.swift`, fenced); (a)'s options change what the mark measures or read an undocumented variable — the response |
| 5(a) · NIT | applied | the drafts' (e) Library contract line: "— ladder round 2, finding 1" removed (the record pointer stays) |
| 5(b) · NIT (VM-65) | applied with headless pins | `TimingStats.init(from:)`: a decoded capacity outside `1…defaultCapacity` takes `defaultCapacity`; `TimingReport.number`: the value bounded to ±`drawnBound` (10¹⁵) before either `Int(_:)` (a NaN → 0); comments on both. *Corrected trace:* the decode never trapped (`reserveCapacity(Int.max)` is a silent no-op — a probe binary); what it did was keep every sample of a damaged file and reserve that many slots; the report's conversion DID trap (`.signal(SIGTRAP)`, observed). One more, NOT applied (an arm): `TimingRecorder.merged` adds a decoded count/counters to the live ones with checked arithmetic — a damaged count near `Int.max` traps the launch's `absorb` |
| 5(c) · NIT | applied in the record and the draft; the migration comment an arm | §5 batch 4's row and §7 batch 4's P-67-2 (in place, marked, first text kept) and the drafts' AppSpecRecord §7 narrative: the SIGNED-IN steady state; a never-signed-in library's index holds every row of its table (one small entry per row written). `Migrations.swift`'s same phrase: untouched, for the final call |
| 5(d) · NIT | DECLINED, recorded | `MobileEditorViewModel.swift` stays untouched by the ladder's fix passes (the editor seam; a cleanliness nit does not open it). No correctness reason found: `reportOperationError(_:)` IS `report(OpsRefusalCopy.sentence(for: error, roads: .phone))`, `init`'s own call |

**The Mac:** finding 1 is phone-only (`VariorumMobile/`). 5(b)'s two files are Core, which the Mac compiles; nothing of
the Mac's calls the decode or the report — the decode's one caller is the phone's `MobileTiming` (`TimingBook.decode` →
`absorb`), the report's the phone's readout (`MobileTimingView`), and `Shared/AppTiming` uses only the recorder's marks
(grep over `App/Variorum/Variorum`, `App/Variorum/Shared`: no `TimingStats`/`TimingReport`/`TimingBook` reference). The
Mac's statements are untouched. A Mac `build-for-testing` was not run this turn; the gate tree's rebuild covers it.

#### The pins, and what each build should show

| Pin | Kind | Red-on-old (expected) | Fix (expected) |
|---|---|---|---|
| `TimingRecorderTests.aDecodedCapacityIsHeldToTheRingsBound` | bug pin (5(b), headless) | **RAN RED** on today's code: 3 issues (capacity 100,000 ≠ 64; all 70 samples held; `Int.max` ≠ 64) | **RAN GREEN** |
| `TimingRecorderTests.aSampleOutsideIntsRangeIsReportedWithoutTrapping` | bug pin (5(b), exit test) | **RAN RED**: 1 issue, the child `.signal(SIGTRAP)` | **RAN GREEN** |
| `TimingRecorderTests.aValueOutsideTheDrawnBoundIsDrawnAtTheBound` | design pin (5(b), exit test — the bound drawn) | **RAN RED**: 1 issue (the old conversion traps) | **RAN GREEN** |
| `MobileLibraryPagingRulesTests.aPutBackOfTheLastRowOfAFullyListedListingReturnsIt` | bug pin (finding 1, the reviewer's) | RED — 3 issues: "the note Put back is listed again"; "the store's whole listing, in its order"; `!allHasMore` | green |
| `MobileLibraryPagingRulesTests.aPutBackOfARowAboveTheEndOfAFullyListedListingKeepsItsLastRow` | bug pin (finding 1, shapes (b)/(c) at the model level) | RED — 2 issues: "the store's whole listing — the last row kept"; `!allHasMore` | green |
| `MobileLibraryPagingRulesTests.aNoteArrivingAtTheTopOfAFullyListedListingKeepsItsLastRow` | bug pin (finding 1, the arrival) | RED — 2 issues: "the store's whole listing — the oldest kept"; `!allHasMore` | green |
| the rest of `MobileLibraryPagingRulesTests` (round 2's four 8-of-12 pins among them — the guards that a listing NOT complete is untouched) | unchanged | green | green |

**Run headless:** `swift test --filter TimingRecorderTests` — on the pins-only tree **35 tests in 1 suite failed with 5
issues** (exactly the three pins above); on the fix **35 tests in 1 suite passed**. No other Core suite references the
two types (grep over `Tests/`).

**Built:** ONE warm incremental phone `build-for-testing` into `App/Variorum/DerivedData/vm64-gate2/` at `848b98b66` (the
pass's last code commit; every later commit is the record or the handoff) — `** TEST BUILD SUCCEEDED **`, 0 errors, no
warning in a touched file. Log and stamp `DerivedData/vm64-gate2-r3-phone-build.log` / `-r3-phone.sha` (local). This
overwrites round 2's phone product in that folder; the gate tree is rebuilt after VM-78's merge-in anyway.

#### Finding 1's red-on-old build (made with the gate tree, after VM-78's merge-in — the orchestrator's brief)

Announce it in the live status and commit before it starts; it reverses round 3's ONE production hunk and nothing else
(the pins name only old API, so nothing moves aside):
```
cd ~/dev/variorum-vm-64
git show 848b98b66 -- App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift | git apply -R
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/<the gate's red folder>
cd ~/dev/variorum-vm-64 && git checkout HEAD -- App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift
git status --short; git diff HEAD --stat   # both must be empty
```
(If VM-78's merge moved the hunk's context, `git apply -R` refuses rather than guesses; then reverse the
`else if state.next == nil, page.next != nil, page.items.count <= rows(question.listing).count { state.wantsMore = true }`
arm by hand to `if state.question != question { state.wantsMore = false }` alone, and say so.)

#### The hosted command for finding 1's pins (the orchestrator's stage; the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

Red-on-old, ONE invocation from the red folder above:
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileLibraryPagingRulesTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination "platform=iOS Simulator,id=<simulator-udid>" -derivedDataPath DerivedData/<the gate's red folder> \
  ${tests/#/-only-testing:VariorumMobileTests/} 2>&1 | tee <log-r3-red>
```
Expected: exactly the three finding-1 pins failing, with 7 issues (3 · 2 · 2); every other test of the suite green.
The fix, from the gate folder: the same `tests` alone — all green — and then in company with round 2's (ii) list
(the record's "Ladder round 2 — fix pass, second turn" ▸ "The hosted commands — FINAL" (ii), which already holds
`MobileLibraryPagingRulesTests`) — all green, `MobileHerPathsPerfTests`' 13 skipped; the gated suite alone (iii) as
before, every asserted count unchanged (by reading: no perf world lands a complete listing that a page pushes past — a wing
of the nine-wing world holds 50 notes, under a page even after a box save, so its pages never carry a cursor; a larger
world's listing is never scrolled (the suite drives no paging), so its first page's cursor stands and the raise never
applies).

#### For QUESTIONS at the merge

None from this pass — no product behaviour was decided: finding 1 makes the listing show what the store holds (the
Mac's own rule); 5(b) touches only how a damaged diagnostic file is read; the caveats are wording in the handoff, hers
to correct.

#### What the orchestrator's line-by-line check should read first (the last round — no reviewer reads these fixes after it)

1. **Finding 1's one condition** in `MobileLibraryViewModel.land` — against `prime` (always a new question), the direct
   arm of `holdFirstPage` (a new question, or ≤ one page), `reread` (inside the follow; its exit asks), and `append`
   (clears `wantsMore`); and the extra clause `page.items.count <= rows(question.listing).count` (the arm (i′) vs (i)) —
   true for every `reread` (its depth IS the listed rows) and for an exactly-full one-page listing, false for a short
   listing a page reaches past.
2. **The three pins' red on the reversed build** — 3 · 2 · 2 issues, nothing else red in the suite.
3. **5(b)'s two lines** (`TimingStats.init(from:)`'s range; `TimingReport.number`'s bound before both conversions) and
   the corrected trace (the decode never trapped; the report did).
4. **The arms left for the final call:** (i′)/(i); `merged`'s overflow (A saturating adds, pin first · B bound the
   decoded count · C record only); the migration comment (yes/no).
5. **The handoff's new sentences** read as plain English for her (P-2-4; VM-226's third way in; the two caveats; "What
   happened"; "Reviews").

#### Second turn — the reviewer's final calls (`6aa357bff`) applied

**Not done:** no hosted run, no Mac build, no red build, no whole Core package — by the brief, those come with the gate
tree after VM-78's merge-in, from a fresh session. The ticket bodies (VM-242 gains (i′)'s residual; VM-234 gains
finding 4's two lines) and finding 2's (a) and (b) are the orchestrator's.

**Commits:** `6c6d3a01e` (live status) · `adc466230` (the `merged` pin, red) · `4bee11420` (the `merged` bound) ·
`705c6cf8a` (the migration comment, comment only) · `8be3a1f30` (finding 1's guard) · `399846e11` (the handoff's slot
beside "fixed") · this part. **The final code tree is `8be3a1f30`**; every later commit is the record or the handoff.

| Final call | What landed |
|---|---|
| Finding 1 — (i′) CONFIRMED as built; one guard | `MobileLibraryPagingRulesTests.aShortCompleteListingThatAPageReachesPastIsNotChased` — test-only, a GUARD by its doc: a page of four; three notes read hidden (`hold(onScreen: false)` — three rows, complete); three more minted hidden; held on screen; settle to four rows; after 150 ms still `all.count == 4 && allHasMore`; then `loadMore` to the end equals `Queries.library`'s six. It holds the clause `page.items.count <= rows(listing).count`: GREEN on the fix and on the hunk-reversed build (nothing raises there), RED only under (i) (the clause deleted — the landing would chase and read six) |
| Finding 1 — the handoff's sentence | round 3's "fixed the same way" keeps `PENDING(merge gate: its tests, seen failing on the old build and passing on the new one)` beside it, until the two runs land |
| 5(b) — `merged`, arm (B), pin first | **Pin** (`adc466230`): `TimingRecorderTests.aDamagedArchivesCountsAreBoundedWhenAbsorbed`, an exit test exactly as the call words it — a live sample and a live count; an archive whose same series decodes with `count` = `Int.max`, whose same counter and three footer counts are `Int.max`; `absorb`; one more sample, one more count, a restarted begin, an unmatched end; a snapshot and the series' summary; in the child, the series count = bound + 2, the counter = bound + 2, `restarts` and `unmatchedEnds` = bound + 1, `abandoned` = bound. **The bound** (`4bee11420`): in `TimingRecorder.merged`, the decoded series count, each decoded counter and the three footer counts each held to `0…archivedCountBound` before they are added (the old `max(0, …)` kept inside the clamp); ONE named constant, `private let archivedCountBound = Int(TimingReport.drawnBound)` (10¹⁵) at file scope (a generic type cannot hold a static stored property), with a comment saying why it is a bound and not saturation. Nothing else moves |
| 5(c) — the migration comment | `705c6cf8a`, COMMENT ONLY: `Persistence/Migrations.swift`'s `v1_38` comment "empty in the steady state (a signed-in mint is stamped at birth)" → "empty in the signed-in steady state (a signed-in mint is stamped at birth) — in a library never signed in, each index holds every row of its table, one small entry per row written —". `git diff -U0` holds only `//` lines (2 removed, 4 added; no non-comment line); the migration's name, SQL and position untouched |

**Headless runs:**
- `swift test --filter TimingRecorderTests` on the pin-only tree (`adc466230`): **36 tests in 1 suite failed with 1 issue** —
  `aDamagedArchivesCountsAreBoundedWhenAbsorbed`, "expected exit status `.success`, but `.signal(SIGTRAP)`" (the absorb's
  `Int.max + 1`). On the fix (`4bee11420`): **36 tests in 1 suite passed**.
- `swift test --filter MigrationTests` after the comment: **33 tests in 4 suites passed**.

**The Mac:** the bound sits in `merged`, reached only through `absorb`/`restore`, whose one caller in the app tree is the
phone's `MobileTiming` (`recorder.absorb(kept)`); the Mac's recorder is never enabled and never absorbs. The comment
changes no statement. Nothing of the Mac's moves.

**Built:** ONE warm incremental phone `build-for-testing` into `App/Variorum/DerivedData/vm64-gate2/` at `8be3a1f30` —
`** TEST BUILD SUCCEEDED **`, 0 errors, no warning in a touched file (`DerivedData/vm64-gate2-r3b-phone-build.log`,
local).

**Finding 1's red build, as it stands after this turn** (unchanged recipe; checked: `git show 848b98b66 --
…/MobileLibraryViewModel.swift | git apply -R --check` passes on this tip, and no later commit touches that file — so it
reverses `848b98b66`'s one hunk and nothing else; the new guard stays IN the red build and must be green there):
```
cd ~/dev/variorum-vm-64
git show 848b98b66 -- App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift | git apply -R
cd App/Variorum && xcodebuild build-for-testing -project Variorum.xcodeproj -scheme VariorumMobile \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData/<the gate's red folder>
cd ~/dev/variorum-vm-64 && git checkout HEAD -- App/Variorum/VariorumMobile/Features/Shell/MobileLibraryViewModel.swift
git status --short; git diff HEAD --stat   # both must be empty
```

**The final hosted command and expectations** (the orchestrator's stage; `tests=(MobileLibraryPagingRulesTests)`, the
invocation as above in "The hosted command for finding 1's pins"):
- **On the hunk-reversed build:** EXACTLY the three finding-1 pins red, at 3 · 2 · 2 issues (7) and at the expectations
  their docs name — `aPutBackOfTheLastRowOfAFullyListedListingReturnsIt` (listed again; the store's whole listing;
  `!allHasMore`) · `aPutBackOfARowAboveTheEndOfAFullyListedListingKeepsItsLastRow` (the whole listing; `!allHasMore`) ·
  `aNoteArrivingAtTheTopOfAFullyListedListingKeepsItsLastRow` (the whole listing; `!allHasMore`); round 2's 8-of-12 pins
  in this suite (`aRowDeletedPastTheFirstPageLeavesTheListing`, `aPutBackThroughTheLinesUndoReturnsARowPastTheFirstPage`,
  `aPutBackAfterTheLibraryCameBackReturnsARowPastTheFirstPage` — its fourth, the ★ pin, is
  `MobileLibraryRowActsTests`', run in company), batch 5's `aDeeperListingFollowsItsFirstPage` (8 of 12 too) and the new guard
  `aShortCompleteListingThatAPageReachesPastIsNotChased` GREEN; every other test of the suite green. Any other red, or a
  different count, is explained in the record before the gate counts as open; a finding-1 pin green there is hollow at
  that pin and said so.
- **On the fix build:** the whole suite green, alone and in company with round 2's (ii) list.

### The merge of main (VM-78) and the gate tree (merge-in implementer and gate-tree builder; a FRESH session)

**Not done here (first, by the record's rule):** no hosted run of any kind — every `xcodebuild test`, simulator boot and
walk is the orchestrator's stage window; the commands are at the end of this section. **Main's own phone count from
VM-78's gate could not be quoted:** on main at `f909d6714` (origin/main had not moved past it when this section was
written) VM-78's record still holds its gate as a slot — "Gate 1, the whole phone target: PENDING(gate 1: its verdict;
VM-24's caret pin the one red by decision)" (`notes/plans/fixes/vm-78-fixes-to-whats-there.md`, FOR A LATER READER), its
gate table's row "PENDING(gate 1: every red by name — the one standing red by decision is VM-24's caret pin,
`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`)", and its handoff
"PENDING(gate 1: the whole phone test suite on the merged code …)"; the count presumably rides main's notes-only ledger
commit, which this branch does not take (the orchestrator merges it). No shared ledger touched (`notes/QUESTIONS.md`,
`notes/TICKETS.md`, the master plan, `notes/AppSpecRecord.md`, `notes/MobileSoul.md`, `notes/SurfaceContracts.md`,
`notes/AppSpec.md` arrive from main exactly as main has them). Nothing in `Sources/VariorumCore/Sync/`, `Server/`,
custody or keychain code, or `VariorumMobile/Features/Protection/`; no schema change. `storageDidEdit`'s routing,
`fallbackVerdict` and `EditorEditRouting` not opened. `MobileLine.swift` untouched (VM-78 never touched it either). The
FOR A LATER READER and every `PENDING(…)` slot about the gate, the walk and the merge stay the orchestrator's.

**The merge:** `a18fae31f` — "Merge main (VM-78) into vm-64-timing-and-lags", a merge commit (`git merge --no-ff
f909d6714`; never a rebase or squash), parents `48a94ea43` (this branch: the live status on `dd7da4f4c`, final code
`8be3a1f30`) and `f909d6714` (VM-78's merge, PR #15 — a true merge on `a4634b288`, which the branch already held, so it
brought the VM-78 branch alone). `git merge-tree` trial first: clean; the merge: no conflict in any file, code or notes.
`git merge-base --is-ancestor f909d6714 HEAD` holds. **What it brought** (56 files, +10,277 −505): seven `Shared/` files
(`ArrivalsCopy`, `BookStateCopy`, `CollectReceiptCopy` new; `BookcaseBoard`, `RecoveryCopy`, `ShelfOrder`,
`StructuralUndoCopy` changed); six Mac files (`MembershipChoice`, `BookArrivals`, `BookSettingsSheet`, `BookStateDoors`,
`ShelfViewModel`, `ShellActions`); fourteen phone product files and twelve phone test files (one new,
`MobileBookFixesTests`); two Mac test files (`ShelfAndPaletteTests`, `UndoWarningWordsTests`); fifteen notes files.
**Nothing under `Sources/`, `Tests/`, `Server/` or the package manifest** — so the whole Core package's count cannot move
by the merge.

**Files changed by both runs since `a4634b288`:** the five code files below and `notes/TEXTKIT2_NOTES.md` (both sides'
blocks kept — VM-78's 4 lines, this run's 3). For each of the six, the merge's diff from our parent equals VM-78's own
diff from `a4634b288`, and the merge's diff from VM-78's parent equals this run's own diff — checked by hashing each
diff's changed lines: identical in all six, so neither side's lines were altered by the join.

#### The blob check — all five MATCH VM-78's last reviewer's pre-read

| File (`App/Variorum/VariorumMobile/Features/…`) | `git rev-parse --short HEAD:<path>` | Pre-read | |
|---|---|---|---|
| `Write/MobileEditorViewModel.swift` | `1b4149904` | `1b4149904` | MATCH |
| `Write/MobileWriteView.swift` | `d63f7af29` | `d63f7af29` | MATCH |
| `Write/MobileUndoDoor.swift` | `645612238` | `645612238` | MATCH |
| `Write/MobileMembership.swift` | `3e48ae264` | `3e48ae264` | MATCH |
| `Shell/MobileLibraryView.swift` | `00b5c086c` | `00b5c086c` | MATCH |

So the join read below is the join `notes/plans/fixes/vm-78-ladder-round4.md` ▸ "The map, final" read.

#### The five files — what each run changed, and that both hold

1. **`Write/MobileEditorViewModel.swift`.** *This run* (+380 −10 across batches 1, 2, 6 and 7 and the ladder): the
   keystroke fence (`flightFence`, `structuralFlightChanged`, `settleFlightSurface`, `drainFlightFence`, the gate and
   storage belts, the settle's hooks in `applyProjection`); `loadLive` and the live iterators handed to `start()`; the
   hold (`holdsAutosave`, `arrivalCount`, `takeAutosaveHold`, `releaseAutosaveHold(ifNotShownSince:)`); the counted
   chrome pass; VM-65's marks. *VM-78* (VM-84, +10 −0): the OBSERVED `private(set) var entryDate: String?` with its doc
   (:114–122) and `entryDate = value?.entryDate` inside `adoptHeader(_:)`. **Both hold.** The property `header` is
   assigned in exactly ONE place — `header = value`, the first line of `adoptHeader(_:)` (:912), with `entryDate =
   value?.entryDate` two lines under it (:914); `header` stays `@ObservationIgnored` (:141) and `entryDate` is a plain
   observed stored property (never `@ObservationIgnored`). Every other `header` in the file is a local — `loadLive`'s
   iterator (:754) and three `let header = try await …read` (:1549, :1666, :1698), each handed to `adoptHeader`. **No
   road of this run sets the header without `adoptHeader`:** `loadLive` (:760), `loadOnce` (:782), `observeHeader`
   (:856) and `confirmNoteStillLive` (:522) all go through it. **The observed `entryDate` cannot add a chrome pass to an
   open:** `MobileNoteOpenOnceTests` counts `projectionChromePasses`, which only `layOutChrome()` (:1154) increments, and
   that is reached only from `renderFull` (:1105), `applyDifferential` (:1149) and `ingest`'s own (:817); `adoptHeader`
   calls none of them, and the new line writes one observed property. On an open it is set once, inside the same
   synchronous `adoptHeader` call that already sets the observed `isSealed` and `displayTitle`, which the masthead reads
   already — the masthead's one invalidation per header adoption, not a second. This run's entries, read on the merged
   tree, are byte-for-byte this run's: `takeAutosaveHold` :320, `releaseAutosaveHold(ifNotShownSince:)` :351, `loadLive`
   :753, the settle hooks :1058 and :1284, `structuralFlightChanged` :1320, `settleFlightSurface` :1350,
   `drainFlightFence` :1373, the gate belt :1946, the storage belt :2277.
2. **`Write/MobileWriteView.swift`.** *This run* (+22 −2): `AppTiming.noteRequested()` in `init`; `noteArrived()` and
   `takeAutosaveHold()` at the head of the arrival task; the leaving's `noteLeaving()`, `shown = model.arrivalCount`,
   `releaseAutosaveHold(ifNotShownSince: shown)` and `noteLeft(leaving)`; the two chips' `refreshChip()`. *VM-78*
   (VM-84): the date chip reads `Self.dateChipDay(model)` for its words, its ink and the alert's seed; `static func
   dateChipDay(_:)` returns `model.entryDate`. **Both hold.** `dateChip` (:459–472): `let day = Self.dateChipDay(model)`,
   the seed `dateField = Self.dateChipDay(model) ?? ""`, `Text(day ?? …)`, the ink on `day != nil`; no
   `.header?.entryDate` anywhere in the file (its one other `header` read is the rename door's tap-time seed
   `model.header?.title`, :260 — main's, and legitimate by the guard's own doc). **The leaving task's order,
   untouched:** in `.onDisappear`, VM-55's `MobileLine.withdrawNoteLine(of:session:)` (:219) and
   `router?.editors.deregister(model)` (:220) first, synchronous; then `noteLeaving()` and `shown`; then the ONE `Task`:
   `teardown()` (:238, the flush) → `session.savepointOnLeaving` (:239) → `releaseAutosaveHold(ifNotShownSince: shown)`
   (:242) → `AppTiming.noteLeft(leaving)` (:243). The arrival task's order too: `noteArrived` → `takeAutosaveHold` →
   `register` → `placeMemory` → `arrive` → `start`.
3. **`Write/MobileUndoDoor.swift`.** *This run* (+12 −1): the `inFlight` latch's `didSet`, which tells the model on each
   real flip (`guard inFlight != oldValue`, then `model?.structuralFlightChanged()`). *VM-78* (VM-16, VM-20):
   `runUndo` reads `undoReporting(with:)` and `redo()` reads `redoReporting(with:)`, three arms each — landed (`outcome.changed`)
   → `undone`/`redone`, ordinary, the other direction recorded; quiet (an outcome, unchanged) → `undoFoundNothing` /
   `redoFoundNothing`, a refusal, nothing recorded; nil → `nothingToUndo`/`nothingToRedo`, a refusal — and
   `discardingUndoDetail` composes the shared sentence. **Both hold:** the arms at :230–246 and :285–296; the latch at
   :131–136, raised by `beginUndo` / `confirmPendingUndo` / `redo()` before the awaited runner call and lowered in their
   `defer` — AFTER `runUndo`'s or `redo()`'s report — so every one of VM-78's six arms speaks inside the flight, and
   the latch's lowering (the fence's landing) is the last thing either door does. The composition is traced below.
4. **`Write/MobileMembership.swift`.** *This run* (+23): `refreshChip()` beside `refresh()` — the chip's read is
   `Queries.readingsContaining` alone, ordered by the same `ordered`, a failure falling back to `refresh()`. *VM-78*
   (VM-81, VM-83, VM-21): the pure brains `rowCarriesDiverge`, `kindMark(for:)`, `memberRowName(for:)`,
   `addRowLabel(for:)`; the membership row draws `memberRowName`, the `kindMark` and Diverge inside `if
   rowCarriesDiverge`; both add lists read `addRowLabel`; `collect(into:)` speaks `AddToBookCopy.collected(…)`. **Both
   hold, and `refreshChip` carries every fact the new faces read:** the row faces read `kind` (`kindMark`,
   `rowCarriesDiverge`, `rowCarriesRemove`), `archivedAt` (`memberRowName`) and the finished state (`MobileShelfFaces.name`)
   off `model.books`, and `books` is assigned from the SAME call on both roads — `Self.ordered(Queries.readingsContaining(db,
   postID:))` in `refresh()` (:149, :152) and in `refreshChip()` (:178, :180). That read returns whole rows: `SELECT r.*
   FROM reading r …` for the book leg (an ARCHIVED book kept — membership is a fact) and whole `Reading` values from
   `readings(db)` for the gathering leg (an archived gathering skipped — it shows nothing) (`ShelfQueries.swift:709`). So
   the chip's rows and the sheet's rows wear the same marks whichever read filled them. The add lists (`addableBooks`,
   `addableSmartBooks`) are `refresh()`'s alone, as this run left them (the sheet reads them on appear).
5. **`Shell/MobileLibraryView.swift`.** *This run* (+37 −12): `isOnScreen` (:71) and the hold key read from it (:79–80),
   the row's `rowAppeared` (:498), the star's `rowStarLanded()` (:512), the paged listing's comments. *VM-78*: three
   COMMENT hunks only (:28, :252–253, :310 — the Shelf's order now named `MobileShelfViewModel.orderedBooks`, VM-83).
   **Both hold;** no statement of either run's changed.

#### The composition, traced — a QUIET undo whose flight refused a key

1. `beginUndo` raises `inFlight` → `didSet` → `structuralFlightChanged()` → `flightFence.flightBegan()` (phase `.flying`).
2. The flush, `pendingUndoWarning` (none), then `runUndo` suspends on `runner.run { stack.undoReporting(with:) }`.
3. A key typed now: her keyboard asks the gate → `flightFence.refusesPolicedEdit()` (the fence is up: `owesSentence =
   true`) → `refuse(StructuralUndoCopy.anotherIsLanding)` → `report` → the line says "Another structural change is still
   landing."; the key never reaches the page.
4. The inverse finds the act's result already gone: an outcome with `changed == false`; the entry RETIRED by the
   stack's own rule, the redo stack left as it was.
5. `refreshTakesFromStore()` settles the page (nothing was written to it: the refused key never landed).
6. VM-78's quiet arm: `report(undoFoundNothing(label), line: .refusal)` → `statusMessage` = "Nothing to undo — ‹label›
   was already undone or changed since.", `statusAction = nil`, the line replaced by it (`StatusCenter.deliver` sets
   `current` outright).
7. `beginUndo`'s `defer` lowers `inFlight` → `didSet` → `structuralFlightChanged()`: no fencing latch is up and the
   phase is `.flying` → `flightLanded(surfaceSettled:)` — the page holds the store after (5) (no forced render owed, no
   deferred projection) → `.drain` → `drainFlightFence()` → `drain()` returns true (the owed sentence) →
   `report(StructuralUndoCopy.anotherIsLanding, action: statusAction)`, with `statusAction` nil (set by (6)) and the
   default class `.refusal`.

**The line ends on the FENCE's sentence, "Another structural change is still landing."** — P-2-2 as built: the
after-flight sentence replaces the door's own words and keeps the door's action, which for a quiet press is none.
**No state is left wrong:** the fence is `.open` with nothing owed; `inFlight` is false; `statusAction` is nil, so no
Redo is recorded — VM-16's "a quiet press records no way back" survives the drain, which only re-states the action it
finds; the stack's entry is retired by the op, not by the door. (Had the page not held the store at (7) — a deferred
projection — the fence would settle first, at most three re-reads, and drain with the same sentence; the same end state.)
**What the composition costs her** (carried to "For QUESTIONS at the merge" below, with P-2-2): (6) and (7) run back to
back in one turn of the main actor — `runUndo` returns into `beginUndo`'s `defer` with no awaited work between — so the
quiet undo's "Nothing to undo — …" is replaced before it can be read; she learns a key was refused, not that the undo
did nothing. The redo door's quiet arm composes the same way ("Nothing to redo — …" replaced by the fence's sentence).
VM-78's three new undo-door tests (`aQuietUndoSpeaksTheRefusalAndOffersNoRedo`,
`aQuietRedoSpeaksTheRefusalAndOffersNoUndo`, `aLandedRedoStillOffersItsUndo`) type nothing during a flight, so the fence
owes no sentence there and the drain says nothing: by trace they hold on the joined tree.

#### The other meeting points

- **The paged Library's union of books.** `MobileLibraryView` hands the Shelf model's `books.orderedBooks` to
  `model.windowedBooks(_:)` under the Books filter (:320, :391) and under `.all`'s union (:424). VM-78 (VM-83) changed
  only what `orderedBooks` RETURNS — `BookcaseBoard.ordered(books, mode: .alphabetical, lastEdited: [:])` (starred first,
  then a–z, digit-aware) in place of the retired `ShelfOrder.ordered(books:pins:)` — keeping its type
  (`[Queries.ShelfBook]`) and its role; the Shelf's `pins` and `setPinned` left with it. This run's code reads no order:
  `windowedBooks` windows whatever it is handed (`TrashListing.windowed`), and the union's VM-68 change is the stamp
  FLOOR (a book whose stamp is not newer than the last listed note is withheld while notes remain), a filter on stamps;
  the book order reaches the union only as its tie-break among books of equal stamp ("for books is the Shelf's order").
  So the Library's book rows take the new order exactly as VM-78 intends ("The Library's book rows read this order
  too"). No line anywhere in the phone tree calls a retired API (a grep for `ShelfOrder.ordered`,
  `MobileShelfFaces.ordered(`, `.setPinned(`, `.pins` finds two comments only).
- **The fence's sentence.** `StructuralUndoCopy.anotherIsLanding` is byte-unchanged ("Another structural change is
  still landing.", `Shared/StructuralUndoCopy.swift:70`); VM-78's change in that file is the hoisted
  `discardingUndoDetail(_:readBackFrom:)` and its header comment. The quiet-arm sentences the composition meets
  (`undoFoundNothing`, `redoFoundNothing`, :54–60) are main's from before VM-78.
- **The message line's Put back.** `MobileLine.putBack` still carries this run's ONE added line — `NotificationCenter.default
  .post(name: .variorumPutBackLanded, object: session)`, inside its `do`, after `try await session.runner.run(body)`, so
  on the success path only (a refused Put back reaches the `catch` and posts nothing); `unarchive` posts nothing. VM-78
  did not touch `MobileLine.swift`; this run's diff in it against `a4634b288` is that one line.
- **The timing marks.** `Shared/AppTiming.swift` is untouched by VM-78. Its 37 catalog cases (23 series, 14 counters)
  are each referenced by a mark function, and each of its 36 mark functions has its app call site (a grep of
  `AppTiming.<fn>(` over `Shared/`, `VariorumMobile/`, `Variorum/`, `Sources/`): `MobileQuickNote` (the box's five),
  `MobileWriteView` (`noteRequested`, `noteArrived`, `noteLeaving`, `noteLeft`), `MobileEditorViewModel`
  (`editorBuilt`, `noteProjectionLoaded`, `noteProjectionFetched`, `noteProjectionDelivered` ×2,
  `noteProjectionRefreshed`), `MobileLibraryViewModel` (`libraryFetched`, `libraryDelivered`), `AppSession`
  (`savepointAttempted` ×2), `AppBootstrap` (`libraryOpened`, `unlockAccepted`), `AppServices` (owner adoption ×3),
  `SyncSession` (the round's four), `AutosaveCoordinator` (three), `MobileTiming` (the rest). None dropped, none moved.

#### VM-78's guards, mirrored over this run's phone lines

- **`noPhoneFaceReadsTheEditorsUnobservedHeaderDate`** (`MobileMembershipTests.swift:396` — the member access
  `/\.header[?!]?\.entryDate\b/` on comment-stripped lines under `VariorumMobile/`, the model's file exempt): a grep of
  the same pattern over the whole merged phone tree finds NO line at all (comment or code), and none among this run's
  added lines under `VariorumMobile/` and `Shared/` (`git diff a4634b288 HEAD^1`). Green by reading.
- **`noPhoneStringLiteralSaysSmart`** (`MobileBookFixesTests.swift:749` — "smart" as a whole word, any case, in any string
  literal under `VariorumMobile/` and `Shared/`, two exemptions by file and exact literal): the whole-word grep over the
  merged tree's non-comment lines holding a quote finds exactly the two exempt literals, both main's —
  `MobileTodayDoor.swift:76` and `MobileTutorialSeeder.swift:295`. This run's added lines say "smart" once, inside a
  `//` comment (`MobileLibraryViewModel.swift:14`, "derived smart membership counts"), which the scan cannot see (it reads
  string literals only). Green by reading; no exemption touched.
- **`MobileMembershipSheetFaceTests`** (hosted, the real sheet): it calls `refresh()` itself; and by (4) above the sheet's
  rows wear the same marks whether `refresh()` or this run's `refreshChip()` filled `books`. Nothing of this run's can
  turn it red. No guard was edited; no line of this run needed restyling.

#### Compile fixes

PENDING(the first compile of the joined tree — phone and Mac `build-for-testing` into `vm64-gate3`).

#### The whole Core package

PENDING(`swift test`, once, on the final tree). Expected by reading: VM-78 changed no Core file or test, so +0 from the
merge; against the 4,971 in 721 baseline (`74d91c666`, round 2 part B) this run's round 3 added four
`TimingRecorderTests` (32 → 36: three in `2543a81f3`, one in `adc466230`) and no suite — 4,975 in 721, the five declared
known issues the baseline's.

#### The products

PENDING(the builds and the commit each was built at).

#### The stage commands — FINAL (the orchestrator's stage; the GO's claim line and UDID fill `<simulator-udid>`; boot fresh, settle, run, shut down)

PENDING(written once the products exist).

#### For QUESTIONS at the merge

1. **P-2-2 meets VM-16's quiet arms (an addendum to the VM-55 merge-in's question 1, "P-2-2 meets VM-61").** When a
   QUIET undo or redo (VM-16 — the inverse found the act's result already gone) refused or withheld a key during its
   flight, the drain's sentence ("Another structural change is still landing.") replaces the door's refusal ("Nothing to
   undo — ‹label› was already undone or changed since." / its redo mirror) in the same main-actor turn, so the line ends
   on the fence's words and she is not told the undo did nothing. No state is wrong (the composition above). Options:
   (a) **as merged** — no line written; P-2-2's rule (the after-flight sentence is the line's last word) holds for every
   door, quiet undo included; (b) the drain stays silent when the door's own report in the same flight was a refusal
   (the door's refusal already says nothing landed; but then the refused key goes unsaid — P-2-1's "said once, as the
   fence drops" broken for that case); (c) the drain speaks first and the door's refusal second — reordering the door's
   last two acts, a change to VM-2's and VM-16's lines both. **Left at (a), PROVISIONAL**; hers with P-2-2, P-55-3 and
   P-55-5. No other product question from this merge.
