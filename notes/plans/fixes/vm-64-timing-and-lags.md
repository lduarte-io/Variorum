# VM-64 — Run: Timing and the two lags (mobile catch-up, wave 1, umbrella 3)

**STATUS: OPEN — kicked off 2026-11-19 (/run-phase, the Pro, overnight; orchestrator session `vm-64`; stage coordinator `nov18`).**
Ticket: VM-64 (team VM, the umbrella is the run ticket) · Branch: `vm-64-timing-and-lags` · Worktree: `~/dev/variorum-vm-64` · PR: `VM-64: …` (merge commit, never squash).
Plan: `notes/plans/vm-44-mobile-catch-up-plan.md` (wave 1, umbrella 3 ⚑ — the wave's ONE `Sync/`-or-custody slot) · members `notes/plans/vm-44/plans/minted/umbrella-03.md` · the traced causes `notes/plans/vm-44/audit/F-performance-trace.md`.

## FOR A LATER READER

*(Written at closeout from the settled facts. Until then: read §1–§4, then LIVE STATUS in §5.)*

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

After batch 7: the whole-phone and whole-Mac windows, then the ladder (Fable, up to three rounds), then the closeout.

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
| 4 · VM-67 | BUILT · headless green · phone piece GREEN · **the 16 Mac types owed** | see the batch 4 block; schema `0e9948d03`, op `e6d16fca7`, built at `8e4e73e01` | closes when the Mac window runs |
| 5 · VM-68 | IN-PROGRESS (implementer started 2026-11-19) | see the batch 5 block | — |
| 6 · VM-69 · VM-70 | NOT-STARTED | — | — |
| 7 · VM-71 | NOT-STARTED | — | — |

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
  steady state; holds exactly the rows adoption exists to find. LOCAL ONLY — not a SyncSpec §12 lockstep event
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

**No revert is in flight.** The red-on-old proof for the hosted pins is a second phone build of the pins over the
pre-fix production files (`git checkout <base> -- <files>` AFTER the fix is committed and pushed, build into
`App/Variorum/DerivedData/vm64-b5-red/`, `git checkout HEAD -- <the same files>`, clean `git status`); this line names
it before it starts. Base: `35a3bea7a`. A QUIET WINDOW was on at the start (no whole-package `swift test`, no cold or
full `build-for-testing` until the orchestrator says it ended).

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
| P2 — Core: the shared Pool predicates + the byte-identity guards (frozen pre-change builders) | NOT-STARTED |
| P3 — Core: `keys` + `poolLoose` on the page read; the Core pins (the loose pages equal `poolPosts`' loose class; the keys equal `Queries.library`'s stamps; the plans and VM steps) | NOT-STARTED |
| P4 — phone: the model's paging + hold, the view's hold key and load-more, the shell's on-screen fact (`MobileShellBand.isDrawn`) | NOT-STARTED |
| P5 — hosted pins: the 201st note reachable by scrolling (red on old); bookless pages past its window (red on old); the return lists what was minted while hidden (guard); the perf suite's four box-save counts ASSERTED 0 and a note typed in from the Library leaves its root alone | NOT-STARTED |
| P6 — builds (phone + Mac `build-for-testing` into `DerivedData/vm64-b5/`; the red build `vm64-b5-red/`), the headless suites, the closeout and READY | NOT-STARTED |

DerivedData: `App/Variorum/DerivedData/vm64-b5/` (gitignored).

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
| Savepoints per leaving (window) | a note's `.onDisappear` or the app's backgrounding (`keepFirst`) | 10 s | a Castle backgrounding's lock teardown counts inside its leaving |

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
the door's Undo/Redo kept beside it). Nothing reaches the store stale; nothing leaves silently.

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
Expect a few minutes per run (two fixture worlds seed first). Lift the numbers with the `grep`.
```
cd ~/dev/variorum-vm-64/App/Variorum
tests=(MobileHerPathsPerfTests)
xcodebuild test-without-building -project Variorum.xcodeproj -scheme VariorumMobile \
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
  seeks it as `owner_id=?`, and it stays empty in the steady state) · partial on `(id)` (the planner would scan the
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
