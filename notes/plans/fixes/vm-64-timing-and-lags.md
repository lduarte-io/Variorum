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
> **The checkpoint protocol binds from your first commit:** write your batch's LIVE STATUS block in §5 of this record at the start; commit per coherent piece and push after every commit; flip the status in the same commit as each piece; claims not yet verified are marked PENDING; synchronous foreground waits only (poll a log with a `grep -q … && break; sleep 5` loop, never end your turn waiting on a background run). Commits carry no attribution trailer; messages are public copy and say `Part of VM-<member>`.
>
> **The stage:** headless `swift build` / `swift test` on the core package and `xcodebuild build` / `build-for-testing` need no stage and run freely. EVERY `xcodebuild test` (simulator or Mac), every simulator boot, walk or Debug launch needs a stage window that ONLY the orchestrator can obtain from the coordinator. So: do all headless work, get `build-for-testing` green for the phone test target (and the Mac's when you changed `Shared/` or Core code the Mac compiles), then END YOUR TURN with a READY report naming the exact suites and commands you need run. The orchestrator will message you the GO with the claim line; you then run, release, and report. Never claim the stage on your own; never run a test host without the GO. Use a run-tagged DerivedData folder (`App/Variorum/DerivedData/vm64-<batch>/`, gitignored) and say its path in your report.
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
| 1 · VM-65 | IN-PROGRESS | — | see the batch 1 block below |
| 2 · VM-2 | NOT-STARTED | — | — |
| 3 · VM-66 | NOT-STARTED | — | — |
| 4 · VM-67 | NOT-STARTED | — | — |
| 5 · VM-68 | NOT-STARTED | — | — |
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

**The BEFORE build (her phone's first install at her sitting):** PENDING — the commit that closes batch 1.

**Held for her next sitting:** the ONE wave-1 install on her phone after all four wave-1 runs have merged (phone on the cable, unlocked, Variorum closed; `notes/plans/vm-44/plans/vm-45-install-runbook.md`), prepared by the last merger so a fresh session can run it; then her use of the phone fills the readout. Her wording pass on the readout's labels.

**Machinery notes** (deaths, resumes, stage windows): none yet.

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
