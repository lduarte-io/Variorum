# VX-494 — the large-corpus first catch-up never lands

**STATUS: OPEN 2026-10-23 — the fix built, live-proven on the throwaway at her corpus's scale, ladder round 1 in
(1 MAJOR, 5 MINOR, 4 NIT — the fixes go to a fresh implementer session).** Branch `vx-494-catchup-hang`, worktree
`~/dev/variorum-vx-494`, the Pro. **The cast (R-494-1, her waiver of the Fable rule for `Sync/`):** Opus orchestrates
and writes the `Sync/` fix; a fresh `opus-reviewer` runs every ladder round; ladder fixes go to a fresh
`opus-implementer` per round (normal /architect-phase discipline, her word "use normal /architect-phase discipline",
~04:45). The session moved Fable → Opus 5.5 at her word ~03:40 ("fable kept hitting the safeguards"). The charter is
`notes/handoffs/vx-494-kickoff.md`; the morning handoff `notes/handoffs/vx-494-handoff.md`. Pin-before-fix; commits
say `Part of VX-494`; NO trailers.

## LIVE STATUS (flip per piece, same commit; unverified claims marked PENDING)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight read whole; worktree + branch; in-flight row on main; VX-494 In Progress | DONE |
| 1 | The evidence re-read (the morning's unified log + read-only server probes) — THE EVIDENCE below | DONE (this commit) |
| 2 | Reproduction at scale (headless fake-server scale test; then the throwaway live, her sign-in) | IN-PROGRESS — the stage window is OPEN (claim `vx-494`, 03:48 MDT, 240 min): throwaway user A RESET to virgin (the §8 precedent — the 21 data tables, `device_cursor`, `purged_row`, `key_vault`, the `kp:` secret; entitlement kept; verified 0/0/0, entitlement 1; ref-guarded); the dev slot's 9 top-level files ASIDE by `mv` into `Variorum-dev-aside-vx494/` beside the slot (same inodes); the walk build (`DerivedData/vx494`, the branch tip) launched with the throwaway env mapped to `VARIORUM_WALK_*`, verified in-process by `ps eww` (2 vars, the throwaway ref, no production ref) — `A4 FENCE (VX-483): LIFTED`, fresh library `1eb1d88c` CREATED in Standard (silent custody). Waiting on HER sign-in as A + the set-up. RESTORE (owed at the window's end): sign the walk session OUT (O-B2), quit, remove the walk library's files + its Backups subfolder, `mv` the 9 back, plain relaunch (rule 21's notice once) — **THE OVERNIGHT ROAD PROVEN (04:30–04:36, her present):** the test app relaunched on the throwaway (`ps eww` checked: the throwaway ref, no production ref); her sign-in as A held; Settings ▸ Protection ▸ Turn on sync = the SET-UP arm ("Your account starts in Standard, like this library"), its three fields typed by the fenced helper (`~/.variorum/bin/type-throwaway-passphrase` — the throwaway passphrase twice, then the TEST library's twelve words, minted at its first look and kept 600 beside the passphrase); the act landed (`turnOnSync — library 1eb1d88c now names account <account-uuid>, standard`); after a relaunch the round ran unattended — the server shows A's `kp:` enrollment and device `90013cc3`'s cursor row (10:35:21 UTC), the row **"Synced 4:35 AM"**. OBSERVATION (a closeout ticket, Low): right after the Standard set-up the row stayed "Sync locked" until the relaunch — no round ran on the act's own (the Castle set-up's act-side round did run at the VX-488 rehearsal) |
| 3 | The mechanism named (trace) | DONE — H1 CONFIRMED by her real crossing (HER EXPERIMENT'S RESULT): the first catch-up commits when left alone (11.6 min download + 4.3 min save); every morning failure was an interruption of an all-or-nothing round |
| 4 | Fix + red-on-old pin | DONE — D1+D2 `c1583de0b`, D3 `c33f18f09`, the schema `f6658017b`; pins red-on-old (`b5ff84236`) + six reverts (RV6 hollow, recorded); THE LIVE PROOF passed (05:07); the R1 fixes (a fresh implementer) `5f983faa7`…`8ec29c300` — see THE BEHAVIORAL REVERTS, THE LIVE PROOF and LADDER R1 FIXES below |
| 5 | Ladder | IN-PROGRESS — r1 (`vx-494-ladder-round-1.md`): 1 MAJOR + 5 MINOR + 4 NIT, fixed by a fresh implementer; r2 (`vx-494-ladder-round-2.md`): 1 MAJOR (R2-1) + 3 MINOR + 2 NIT, ⇒ r3 (the cap); the R2 fixes go to a fresh implementer (LADDER R2 FIXES — THE BRIEF) |
| 6 | Closing runs, PR, merge | NOT-STARTED |
| 7 | Release build + A1 + install; her crossing retry | NOT-STARTED |

## LADDER ROUND 1 — THE FINAL CALLS (the orchestrator, same-model arbitration against the spec, 2026-10-23 ~05:15)

The round's record is `vx-494-ladder-round-1.md` (a fresh `opus-reviewer`, REVIEW_PROMPT verbatim: 0 BLOCKER, 1 MAJOR,
5 MINOR, 4 NIT; its targeted sync sweep 343/80 green; its F1 probe on a scratch copy of the package, never this repo).
Each finding's disposition, and who carries it:

- **F1 [MAJOR] — CONFIRMED (probe-proven: a corrupted, drifted or refused staged row failed 3 of 3 later rounds with
  the cursor at 0; a hand-clear healed it). FIX (1) + (2), the implementer:** (1) the header gains `format` (a
  `PullStage` constant, bumped whenever the staged row's encoding or meaning changes) and `lockstep`
  (`SyncSchema.lockstepVersion`); `plan` resumes only when BOTH match as well as base/key/device, else
  `.discardThenFresh`. (2) A staged row that will not decode discards the whole stage (logged) and the round fetches
  fresh from the cursor — one re-download, never a wedge (the header's own `try?` posture, extended to the rows).
  **(3) DECLINED, reason:** discarding the stage on any non-cancellation apply failure would throw the download away in
  exactly the case D2 exists for — Castle's lock closes the library mid-save and the apply fails with a closed-pool
  error, not a `CancellationError`; and a CONTENT poison the server still serves failed every round before the stage
  too (any server change to the row arrives at a higher seq and replaces the staged copy). PINS: the reviewer's (p1)
  undecodable payload → the next round completes at head with an empty stage; (p2) a header with `format` one behind →
  the next round's first `since` is 0; plus the lockstep leg of (p2). Each red on the tip `34abbef16`'s code.
- **F2 [MINOR] — CONFIRMED (a pin, no code):** after the interrupted and the resumed round, the fake server's device
  cursor for B still reads 0 (the resumed round reported nothing — the 13j rule). A guard; its teeth by reverting
  `windowDevice` to "the round's first window".
- **F3 [MINOR] — CONFIRMED (two guard pins, no code):** (a) a stage fetched under one corpus key id is never resumed
  under another (the next round's first `since` is 0); (b) `resyncReinitialize()` empties the stage and the next round
  starts from 0 — the base-0 corner the plan's base check cannot see. Each with its teeth (revert its line).
- **F4 [MINOR] — CONFIRMED (the orchestrator's, at closeout):** the canon contract lines in place — AppSpec §7's
  local-only machinery block (`sync_pull_stage`, v1_32, the export drops it; the `pull_stage` header key beside
  `last_server_seq`), SyncSpec §3 (the machinery list; the cursor no longer the ONE live key) and §5 (the staged,
  resumable download; the pull window its own size; the apply's one transaction unchanged) — each one pointer to this
  file; the dated narrative into AppSpecRecord. Added to the handoff's step 6.
- **F5 [MINOR] — CONFIRMED, DONE (the orchestrator): VX-497** — D4 minted as its own ticket (Improvement, Confirmed,
  Performance, Medium, project 18a, related VX-494/VX-495) (the save — one all-or-nothing
  transaction holding the writer ~4 min at ~420 rows/s on her corpus; the phone's case in VM-8).
- **F6 [MINOR] — CONFIRMED, RECORDED (her call):** v1_32 makes every plaintext export written by 0.10 (9093)
  un-importable by the fixed build (T-8's `applied == known`, P-VX309-U1b-7 PROVISIONAL) though the export drops the
  table. Reach today: exports made on her Pro since the 9093 install. Her question, bundled: should LOCAL-ONLY
  migrations count toward "this build's export"? (QUESTIONS entry at the merge.)
- **N1 [NIT] — ACCEPTED (the implementer):** the doc drift — `retire()`'s first paragraph and `SyncSession.stop()`'s doc
  (the round is now cancelled); `PullStage`'s stale `resumePoint` name; "what it fetched is staged" → only COMPLETED
  windows are staged (the window in flight is dropped); the "~550 → ~55" line stated as measured now that the live
  proof ran (56 windows); `LocalMachineryRecreation`'s "four tables" → the registry's set.
- **N2 [NIT, SPECULATIVE reachability] — ACCEPTED as a belt WITH a pin built first:** inside the apply transaction,
  refuse when the committed cursor no longer equals the round's `since` (another writer committed under this round) —
  throw, keep the stage; the next round re-plans (its base check then discards a stage whose base moved). The pin
  builds the interleaving the reviewer traced (a commit of a moved cursor + a cleared stage landing while the round is
  still fetching — a transport hook) and must be RED on the tip (the round commits past rows it never applied —
  `syncedDump` diverges) before the belt lands; green → record-only, no belt.
- **N3 [NIT] — PART ACCEPTED (the implementer):** `stage` uses a cached statement and encodes before entering the
  writer. The disk-footprint half is the live proof's O-2 (measured: 79 MB → 150 MB) — her call, bundled.
- **N4 [NIT] — DONE (the orchestrator):** the STATUS header rewritten to R-494-1's cast.

## LADDER ROUND 2 — THE FINAL CALLS (the orchestrator, 2026-10-23 ~06:15)

The round's record is `vx-494-ladder-round-2.md` (a fresh `opus-reviewer`, REVIEW_PROMPT verbatim: 0 BLOCKER, 1 MAJOR, 3
MINOR, 2 NIT; every R1 fix verified sound — F1 (1)+(2), the F2/F3 guards, N1, N3; two R1 reverts re-run red on their
own pins; its runs `ResumableCatchUpTests` 12/1 and the sync sweep 355/81 green on a scratch copy). **A new MAJOR ⇒ a
round 3, the cap.** Dispositions:

- **R2-1 [MAJOR] — CONFIRMED (probe-proven on a scratch copy whose `Sources/` match the tip byte for byte; the control
  with the stage hand-cleared stays correct): a staged row is invisible to the pre-round ledger reconciliation**
  (`PurgeJanitor.reconcileLedger` drops purged ids only from the live tables, then advances its scan point), so a
  device that drops out of the purge horizon mid-catch-up resumes a stage holding a since-purged row and resurrects it
  permanently. **FIX (2), the implementer:** the stage header records the ledger scan point (`sync_state`'s purge-scan
  key, read in the stage write's transaction); `plan` resumes only while it is unchanged — any ledger advance discards
  the stage (a stage is valid only for the ledger state it was fetched under). Fix (1) (deleting staged rows by ledger
  entry) DECLINED as a second road beside it: (2) is one rule, conservative, and covers every road the ledger moves on.
  PIN: the reviewer's probe (`ZZReviewerR2ProbeTests` in the session scratchpad — copy its scene into
  `ResumableCatchUpTests`), red on the tip.
- **R2-2 [MINOR, reachability SPECULATIVE; the pin red on the tip] — CONFIRMED: the N2 belt checks the cursor's VALUE,
  and some clears leave it unmoved** (a first-row stall commits `newCursor = since` and clears; `discardThenFresh`;
  `resyncReinitialize` at base 0). **FIX (the reviewer's): CONTINUITY** — `stage` refuses unless (no header and
  `windowSince == base`) or `header.seq == windowSince`; the apply refuses unless the header exists with `seq ==
  fetchCursor`; the cursor check stays beside them. PIN: the reviewer's probe scene (B synced to the stall point
  first), red on the tip.
- **R2-3 [MINOR] — RECORDED, HER QUESTION (no code):** a resumed round's windows carry no device id, so the server's
  `seen_at` is not refreshed by resumed rounds; before the stage a stuck device held the account's purge horizon, now a
  device that ONLY ever resumes drifts out of it after 60 days. With D1 a resume finishes in ~a minute, and R2-1's fix
  discards the stage the moment any purge lands, so the residue is a device that resumes and never completes for 60
  days. Bundled for her: does an actively resuming device count as "seen"? (QUESTIONS at the merge.)
- **R2-4 [MINOR] — CONFIRMED (the orchestrator, at closeout):** the handoff gains F4's canon lines in step 6 and the
  calls owed gain F6, O-1, O-2 and R2-3.
- **R2-5 [NIT] — CONFIRMED (the orchestrator):** the LIVE STATUS table's rows 4 and 5 brought current.
- **R2-6 [NIT] — ACCEPTED (the implementer):** on `PullStage.CursorMovedUnderRound` the scheduler requests one
  follow-up round (the next round re-plans and heals), so the row never sits on the belt's text. A pin: the scheduler
  runs the follow-up.
- **THE ARCHITECT'S NOTE (recorded before the round-2 fixes start):** the stage has drawn a MAJOR in each round (F1,
  R2-1) — each a real invalidation edge of a new persisted cache. If round 3 (the cap) raises another MAJOR or BLOCKER
  in D2, the stage does NOT merge tonight: the merge carries D1 + D3 (D1 alone brings her corpus's first catch-up to
  ~70 s of download + ~4–5 min of save — inside Castle's 10-minute idle lock), D2 reverts off the branch, and the stage
  goes back to her as a design question with the ladder's findings. A clean round 3 merges all three.

## LADDER R2 FIXES — THE BRIEF (a fresh `opus-implementer`, one session; written before it spawns)

**Read first, in full, yourself:** CLAUDE.md + its auto-loaded canon; `notes/SyncSpec.md` WHOLE (incl. §12's 13j
entry — the purge ledger and horizon); `notes/plans/phase-13j-purge-memo.md` §2 and §4 (the ledger and the horizon);
`notes/SessionResiliencyProtocol.md`; this file WHOLE (THE FIX DESIGN, both rounds' FINAL CALLS, the R1 fixes' LIVE
STATUS); `vx-494-ladder-round-1.md` and `vx-494-ladder-round-2.md` WHOLE; the code: `Sync/PullStage.swift`,
`Sync/SyncEngine.swift` (`pullRound`), `Sync/SyncScheduler.swift`, `Sync/PurgeJanitor.swift` (`reconcileLedger` and
every writer of `last_purge_seq`), and `Tests/VariorumCoreTests/ResumableCatchUpTests.swift` + its support files. The
round-2 reviewer's probe — reuse its scenes as your pins — is
`/private/tmp/claude-501/-<home>-dev-variorum/c34bb0c9-4f3f-47f5-964c-43a1eb555b91/scratchpad/probe/Tests/VariorumCoreTests/ZZReviewerR2ProbeTests.swift`
(a scratch copy of the package; read it, never build there; never commit it).

**Your scope — exactly ROUND 2's FINAL CALLS' implementer items:** R2-1 (fix (2): the header records `last_purge_seq`
read in the stage write's transaction; `plan` resumes only while it is unchanged), R2-2 (continuity: `stage` refuses
unless (no header and `windowSince == base`) or `header.seq == windowSince`; the apply refuses unless the header exists
with `seq == fetchCursor`; the cursor check stays), R2-6 (the scheduler requests one follow-up round on
`PullStage.CursorMovedUnderRound`). Each bug-class item with its pin RED on the tip `b37c47c7c`'s code BEFORE its fix
(R2-1 and R2-2: the reviewer's scenes; R2-6: the follow-up round runs). A header from before your change (no scan point)
must be discarded, never resumed — say how your decode guarantees it. **Not yours:** R2-3 (hers), R2-4/R2-5 (the
orchestrator's). A design fork STOPS and comes back as a proposal.

**The discipline, the evidence, the limits — exactly LADDER R1 FIXES — THE BRIEF's** (below): pin before fix, the
behavioral reverts named in your LIVE STATUS before any runs, commit per piece + push each, PENDING on every unverified
claim, foreground waits only, no subagents, headless only plus ONE `build-for-testing` (`DerivedData/vx494-r2fix`) if
any `App/` file changes, no stage, no app, no store, no server; the closing evidence = `ResumableCatchUpTests`, the sync
sweep, the core suite debug + release (the known MCP timing flake named, never fixed). Commits say `Part of VX-494`; NO
trailers of any kind.

### LADDER R2 FIXES — LIVE STATUS (the implementer owns this section)

**NOT DONE HERE, by the brief:** R2-3 (hers), R2-4 and R2-5 (the orchestrator's); no stage, no app launch, no walk, no
`xcodebuild test`, no store or server contact; no `build-for-testing` unless an `App/` file changes (none is planned —
nothing in `App/` names the stage or its errors). **IN PROGRESS — no revert is in flight.**

Session: a fresh `opus-implementer` (Opus 5.5), 2026-10-23, worktree `~/dev/variorum-vx-494`, headless only. Read in
full before any code: CLAUDE.md + canon, SyncSpec, the purge memo §2 and §4, the resiliency protocol, this file, both
ladder rounds, `PullStage.swift`, `SyncEngine.swift` (`pullRound`, `pullToHead`, `resyncReinitialize`),
`SyncScheduler.swift`, `PurgeJanitor.swift` (`reconcileLedger` and the three writers of `last_purge_seq`: the sweep's
own-purge advance, `reconcileLedger`, `reonboardFromAccount`), `ResumableCatchUpTests` + its support, and the R2
reviewer's probe. One fact checked for R2-1's cost: `sync_purge_ledger` (13y's body, 11's verbatim) and the fake both
return EVERY entry above the scan point in one page (no LIMIT), so a fresh device's first pre-pass consumes the whole
ledger and a later pre-pass moves the scan point only when a new purge landed — fix (2) costs one re-download exactly
then, and D2's resume is untouched otherwise.

**The design, one rule at three doors.** The stage's IDENTITY becomes base · key id · device id · format · lockstep ·
**the ledger scan point** (`last_purge_seq`, absent ⇒ 0 — `PurgeJanitor.stateValue`'s own reading). `plan` resumes
only on an identical identity (R2-1); `stage` extends only a stage of this identity whose reach is exactly where this
window starts, or starts one only from the round's base (R2-2 (i)); the apply saves only a stage of this identity whose
reach is the round's fetch cursor, beside the unchanged cursor check (R2-2 (ii)). A mid-round change of any leg —
the scan point included — refuses (`PullStage.StageMovedUnderRound`, nothing written), never re-vouches: a stage is
valid only for the ledger state it was fetched under. **A header from before this change** has no `ledgerScanPoint` key;
the field is a NON-optional `Int64` in the synthesized `Decodable`, so decoding throws `keyNotFound`, `readHeader`'s
`try?` reads it as unreadable, and `plan` answers `.discardThenFresh` (and `stage` refuses an unreadable header rather
than overwrite it). `format` stays 1 (it names the staged ROW's encoding, which does not change). R2-6: the scheduler
requests ONE follow-up round on either belt refusal (`PullStage.isOneWriterRefusal`), never on a retired scheduler,
and never a second consecutive one (a belt-refused follow-up waits for the next trigger — no loop by construction).

| # | Item | Plan | Status |
|---|---|---|---|
| R2-0 | This status | — | DONE (this commit) |
| R2-P | The pins, committed before any fix (one commit) | `ResumableCatchUpTests` gains: **(R2-1)** the reviewer's probe scene — B's first catch-up interrupted with the doomed note staged live; A deletes, backdates, B drops out of the horizon, A's sweep purges the family; B returns (`reconcileLedger()` then `pull`) ⇒ the first `since` is 0 (stage discarded), the doomed container absent, and after explicit rounds (the purge idiom — a purge consumes a seq no feed row carries) both outboxes empty and the dumps equal; **(R2-1u, a guard)** the header's `ledgerScanPoint` key removed (the pre-change shape) ⇒ the next first `since` is 0; **(R2-2)** the reviewer's `probeTheBeltMissesAFirstRowStall` scene (B committed to the stall point first) ⇒ no row at or below B's cursor missing, then the heal ⇒ converged; **(R2-6)** the N2 scene driven through a `SyncScheduler` (no janitor), ONE trigger ⇒ `roundsCompleted == 2` and `lastError == nil` (the follow-up healed); **(R2-6b, a guard)** a transport hook that clears B's stage before each round's second window (three raids) ⇒ one trigger ends after exactly 2 rounds (the follow-up ran once, never a loop). The fault transport gains `armWhileEachPull(times:where:_:)`. Expected on the tip's product code: R2-1, R2-1u, R2-2, R2-6 RED; R2-6b RED for another reason (the tip has no continuity, so nothing refuses — 1 round); its teeth are a revert | NOT-STARTED |
| R2-1 | The ledger scan point in the stage's identity | `Header.ledgerScanPoint` (non-optional); `stage` records `last_purge_seq` read in its own transaction; `plan` resumes only while it is unchanged; the doc (THE IDENTITY) names it and why (13j's returner road: the pre-round reconciliation drops purged rows only from the live tables, so a stage outliving a ledger advance would resurrect them) | NOT-STARTED |
| R2-2 | Continuity | `stage(…, from windowSince:, through:)` refuses unless (no header row and `windowSince == base`) or (a readable header of this identity with `seq == windowSince`); the apply transaction, after the cursor check, refuses unless a readable header of this identity exists with `seq ==` the round's fetch cursor; both throw `StageMovedUnderRound`, nothing written; the ONE WRITER doc rewritten | NOT-STARTED |
| R2-6 | The follow-up round | `SyncScheduler.runOneRound`'s catch: on `PullStage.isOneWriterRefusal(error)`, not retired, and the round was not itself a belt-requested follow-up ⇒ `followUpRequested = true` | NOT-STARTED |
| R2-R | The behavioral reverts | Named here BEFORE any runs, at a committed pre-revert tip; each one file, `git checkout --` restore, `git diff --exit-code` clean after each | NOT-STARTED |
| R2-E | Final evidence | `ResumableCatchUpTests`; the sync sweep; core debug + release (the known MCP timing flake named if it appears, never fixed) | NOT-STARTED |

## LADDER R1 FIXES — THE BRIEF (a fresh `opus-implementer`, one session; written before it spawns)

**Read first, in full, yourself:** CLAUDE.md + its auto-loaded canon; `notes/SyncSpec.md` WHOLE (this is `Sync/`);
`notes/SessionResiliencyProtocol.md`; this file WHOLE (THE FIX DESIGN, THE FINAL CALLS above are your charter);
`vx-494-ladder-round-1.md` WHOLE (each finding's mechanism and proposed pins); the code: `Sync/PullStage.swift`,
`Sync/SyncEngine.swift` (`pullRound`, `resyncReinitialize`), `Sync/SyncScheduler.swift`, `Persistence/
LocalMachineryRecreation.swift`, `App/Variorum/Shared/SyncSession.swift` (`stop()`'s doc only), and
`Tests/VariorumCoreTests/ResumableCatchUpTests.swift` + `Support/FaultInjectingTransport.swift` + `Support/FakeSyncServer.swift`.

**Your scope — exactly THE FINAL CALLS' implementer items, nothing else:** F1 (1)+(2) with pins (p1), (p2) and
(p2)'s lockstep leg; the F2 pin; the F3 pins (a), (b); N2 — the interleaving pin FIRST, the belt only if it is RED on
the tip (green ⇒ record-only, no belt, say so); N1's doc fixes; N3's cached statement + encode-before-write. **Not
yours:** F4 (canon), F5 (done — VX-497), F6 and O-2 (hers), N4 (done), F1 (3) (declined). An item that turns out to
need a design call STOPS and comes back to the orchestrator as a proposal (the architect rules forks).

**The discipline (binding):** pin before fix, per item — each bug-class pin committed RED on the pre-fix tree before
its fix; a guard pin says it is a guard and shows its teeth by a behavioral revert. Then the BEHAVIORAL REVERTS, named
in your LIVE STATUS before any runs (commit first; restore by `git checkout --` of the one file; `git diff
--exit-code` clean after each; "no revert is in flight" written when done). Commit per piece, push after every commit,
your LIVE STATUS below flipped in the same commit, every unverified claim PENDING. Foreground waits only (poll a log,
never end your turn waiting). No subagents. Headless only: `swift build` / `swift test` from
`<home>/dev/variorum-vx-494`, plus ONE `xcodebuild -scheme Variorum -destination 'platform=macOS'
-derivedDataPath App/Variorum/DerivedData/vx494-r1fix build-for-testing` at the end (the app target's doc line); NO
`xcodebuild test`, NO stage, NO app launch, NO dev-store or real-store touch, NO server contact. Commits say
`Part of VX-494`; NO trailers of any kind.

**Evidence at your close (in your LIVE STATUS):** the new pins' red-on-old lines; each revert's run line; then on
the final tree `swift test --filter ResumableCatchUpTests`, the sync sweep `swift test --filter
"Sync|FaultInjection|Purge|Migration|LocalMachinery|StorePlaintext|Soak|Convergence|Scheduler|AbuseGuard|RestoreMatrix"`,
the whole core suite debug (`swift test`) and release (`swift test -c release`) — each line quoted; the known MCP
timing flake (`MCPHarnessTimeLimitTests`, load-shaped, passes alone on both sides) named if it appears, never fixed
here; and the build-for-testing line.

### LADDER R1 FIXES — LIVE STATUS (the implementer owns this section)

**NOT DONE HERE, by the brief:** F4 (canon — the orchestrator's, at closeout), F5 (done — VX-497), F6 and O-2 (hers),
N4 (done), F1 (3) (declined); no stage, no app launch, no walk, no `xcodebuild test`, no store or server contact. One
departure from the brief's letter: the release suite ran as `swift build -c release --build-tests -Xswiftc
-enable-testing` then `swift test -c release --skip-build` (one tool call is capped at 10 minutes; a plain `swift build
-c release --build-tests` cannot compile the `@testable` imports). **CLOSED — every item dispositioned below; no revert
is in flight; the tree is clean.** For the reviewer: `PullStage.log` is the core package's FIRST `os.Logger` (category
`sync`); the N2 belt's refusal is an internal error (`PullStage.CursorMovedUnderRound`, no `SyncError` case), shown on
the status row through the scheduler's `String(describing:)` if it ever fires, healed by the next round.

Session: a fresh `opus-implementer` (Opus 5.5), 2026-10-23, worktree `~/dev/variorum-vx-494`, headless only (no
stage, no app, no store, no server). Read in full before any code: CLAUDE.md + canon, SyncSpec, the resiliency
protocol, this file, `vx-494-ladder-round-1.md`, the named code.

| # | Item | Plan (the settled design) | Status |
|---|---|---|---|
| R1-0 | This status | — | DONE (this commit) |
| R1-1 | The pins, committed before any fix (one commit) | `ResumableCatchUpTests` gains: **(p1)** an undecodable staged payload → the next round completes at head, stage empty, converged; **(p2-format)** the header's `format` rewritten one behind → the next round's first `since` is 0; **(p2-lockstep)** the same for `lockstep`; **(N2)** the interleaving — B's round, 20-row windows, and at its 3rd pull call ANOTHER real engine round on B's store (straight to the server, same device + key) resumes the stage, stalls at a straggler placement, commits the cursor at the stall and clears the stage while the first round is still fetching → assert no row at or below B's committed cursor is missing from B; then heal the straggler (its block pushed) → quiescence → `syncedDump` equal; **(F2 guard)** after the interrupted + resumed rounds the server's device cursor for B still reads 0; **(F3a guard)** the account reset to a new corpus key id (mirror wiped, A re-pushes under it, B re-joins) → B's next first `since` is 0; **(F3b guard)** `resyncReinitialize()` after an interrupted catch-up (mirror wiped) → the stage is empty and the next first `since` is 0, B holds none of A's rows. The fault transport gains `armWhilePull(atCall:_:)`. Expected on the tip `5996c5d36`'s product code: p1, p2-format, p2-lockstep RED; N2 RED or green (green ⇒ record-only, no belt); F2/F3a/F3b GREEN (guards — their teeth are reverts) | DONE (this commit). **RED on the tip's product code** (`swift test --filter ResumableCatchUpTests`): `✘ Test run with 12 tests in 1 suite failed after 5.558 seconds with 5 issues` — p1 ✘ `Caught error: DecodingError.keyNotFound: Key 'row' not found` (the reviewer's probe, exactly); p2-format ✘ and p2-lockstep ✘ `next.first == 0` (the extra key ignored, the stage resumed); **N2 ✘ RED** — `missing.isEmpty` ✘ "33 missing, e.g. [container_block:straggler-placement@8, container:AA…0004@9]" (the other round committed the cursor at the stall, 7, and cleared the stage; B's round then saved only what it staged after the clear and committed the head — the straggler and 32 posts at or below its cursor never applied) and `a.syncedDump() == b.syncedDump()` ✘ after the heal ⇒ **the belt lands (R1-4)**. GREEN by design: F2, F3a, F3b (guards) and the five existing pins |
| R1-2 | F1 (1)+(2) | `PullStage.Header` gains `format` (`PullStage.format`, starts at 1, bumped whenever a staged row's encoding or meaning changes) and `lockstep` (`SyncSchema.lockstepVersion`); `plan` resumes only when both match as well as base/key/device (a header from before this change lacks both keys ⇒ unreadable ⇒ discarded, the existing `try?` posture). `PullStage.rows` answers nil when any staged payload will not decode; `pullRound` then clears the stage (logged — the core's first `os.Logger`, category `sync`) and fetches fresh from the committed cursor, ONCE: a stage this round fetched from the cursor that still will not decode clears and throws (never a loop) | DONE (this commit). `swift test --filter ResumableCatchUpTests`: `✘ Test run with 12 tests in 1 suite failed after 6.046 seconds with 2 issues` — p1 ✔, p2-format ✔, p2-lockstep ✔ (green now); the 2 issues are N2's, by design until R1-4 |
| R1-3 | N3 (part) | `PullStage.encode` turns a window into rows-with-payloads BEFORE the writer is taken; `stage` runs one `cachedStatement` per row. No behavior change (the suite is its evidence) | DONE (this commit) — `swift test --filter ResumableCatchUpTests`: `✔ Test run with 12 tests in 1 suite passed after 6.121 seconds`; the sweep and the whole suite at R1-7 are its wider evidence (PENDING). The disk-footprint half is O-2's, hers |
| R1-4 | N2 belt — ONLY if R1-1's N2 pin is RED on the tip | Inside the apply transaction, before any write: the committed cursor must still equal the round's `since`, else throw (`PullStage.CursorMovedUnderRound`, internal — no `SyncError` case, no app switch touched); the stage is kept, the next round re-plans and its base check discards it. `PullStage`'s ONE WRITER paragraph updated to name the `stop()` → `configure()` hole and the belt | DONE (this commit) — the N2 pin was RED on the tip (R1-1), so the belt landed. `swift test --filter ResumableCatchUpTests`: `✔ Test run with 12 tests in 1 suite passed after 6.153 seconds` |
| R1-5 | N1 doc drift | `retire()`'s first paragraph + `SyncSession.stop()`'s doc (the round is cancelled now); `PullStage`'s `resumePoint` → `plan`; "what it fetched is staged" → only COMPLETED windows (the one in flight is dropped) in `SyncEngine` and `SyncScheduler`; the D1 size comment stated as measured (56 windows, the live proof); `LocalMachineryRecreation`'s "four tables" → the registry's set | DONE (this commit) — doc-only; `swift build` complete |
| R1-6 | The behavioral reverts | NAMED BEFORE ANY RUNS (this commit). The pre-revert state is the committed, pushed tip `455dcb625` (tree clean); each revert is ONE file, run `swift test --filter ResumableCatchUpTests`, restored by `git checkout -- <file>`, then `git diff --exit-code` clean before the next. Predicted: each red on exactly its own pin. **RV-R1a** (F1 (1), format leg) `PullStage.plan` drops `header.format == format` → `aStageOfAnotherStageFormatIsNeverResumed` ✘ · **RV-R1b** (F1 (1), lockstep leg) `plan` drops `header.lockstep == SyncSchema.lockstepVersion` → `aStageOfAnotherLockstepMarkerIsNeverResumed` ✘ · **RV-R1c** (F1 (2)) `PullStage.rows` decodes with `try` again (throws, never nil) → `anUndecodableStagedRowCostsOneDownloadNeverAWedge` ✘ · **RV-R1d** (F2's teeth) `pullRound`'s `windowDevice` rides "the round's first window" (`windowSince == roundStart`, `roundStart` = the fetch cursor after the plan) instead of "a window whose since is the committed cursor" → `aResumedRoundNeverReportsItsReachAsTheDevicesCursor` ✘ · **RV-R1e** (F3 (a)'s teeth) `plan` drops `header.keyID == keyID` → `aStageFetchedUnderAnotherCorpusKeyIsNeverResumed` ✘ · **RV-R1f** (F3 (b)'s teeth) `resyncReinitialize` without its `PullStage.clear(db)` → `reinitializingForTheWipeAndRepushEmptiesTheStage` ✘ · **RV-R1g** (N2's belt) the apply's cursor check removed → `aRoundNeverCommitsPastRowsAnotherWriterClearedFromUnderIt` ✘. N3 is a refactor (no revert; the suites are its evidence) | DONE — **all seven red on exactly their own pin; each restored by `git checkout --`, `git diff --exit-code` clean after every one; no revert is in flight.** `swift test --filter ResumableCatchUpTests` under each: RV-R1a `✘ Test run with 12 tests in 1 suite failed … with 1 issue` — `aStageOfAnotherStageFormatIsNeverResumed` ✘ only · RV-R1b `… with 1 issue` — `aStageOfAnotherLockstepMarkerIsNeverResumed` ✘ only · RV-R1c `… with 1 issue` — `anUndecodableStagedRowCostsOneDownloadNeverAWedge` ✘ (`DecodingError.keyNotFound: Key 'row'`) only · RV-R1d `… with 1 issue` — `aResumedRoundNeverReportsItsReachAsTheDevicesCursor` ✘ (`server.deviceCursor(b.deviceID) == 0`) only · RV-R1e `… with 1 issue` — `aStageFetchedUnderAnotherCorpusKeyIsNeverResumed` ✘ only · RV-R1f `… with 3 issues` — `reinitializingForTheWipeAndRepushEmptiesTheStage` ✘ (`stagedRowCount == 0`, `next.first == 0`, and B applied A's rows the wiped mirror no longer holds) only · RV-R1g `… with 2 issues` — `aRoundNeverCommitsPastRowsAnotherWriterClearedFromUnderIt` ✘ (`missing.isEmpty`, the dumps after the heal) only |
| R1-7 | Final evidence | `ResumableCatchUpTests`; the sync sweep; core debug + release; the one `build-for-testing` | On the final product tree (`ed03a07b1`): `swift test --filter ResumableCatchUpTests` `✔ Test run with 12 tests in 1 suite passed after 6.099 seconds`; the sync sweep (the brief's filter — it does not match this suite's name, so its count equals the reviewer's) `✔ Test run with 343 tests in 80 suites passed after 44.072 seconds`; **core DEBUG** (`swift test`, 05:36→05:40): `VariorumCoreTests` `✔ Test run with 3320 tests in 434 suites passed after 197.421 seconds` (3313 + the 7 new), the third target `✔ Test run with 32 tests in 4 suites passed`, and the MCP target `✘ Test run with 383 tests in 71 suites failed after 30.942 seconds with 1 issue` — the ONE red is the known load-flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (19.710 s vs its 15 s bound; no MCP code in this diff), and RUN ALONE it passes: `✔ Test run with 3 tests in 1 suite passed after 2.198 seconds`; **core RELEASE** (split in two because one call is capped at 10 minutes: `swift build -c release --build-tests -Xswiftc -enable-testing` 05:42→05:50, `Build complete! (468.40 sec)`, then `swift test -c release --skip-build` 05:50→05:54): `VariorumCoreTests` `✔ Test run with 3291 tests in 429 suites passed after 186.583 seconds` (3284 + the 7 new), the third target `✔ Test run with 32 tests in 4 suites passed`, the MCP target `✘ Test run with 383 tests in 71 suites failed after 27.939 seconds with 1 issue` — the same known load-flake (18.169 s vs 15 s), which RUN ALONE passes: `✔ Test run with 3 tests in 1 suite passed after 2.188 seconds`. **build-for-testing** (`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath App/Variorum/DerivedData/vx494-r1fix build-for-testing`, 05:55→05:58, fresh derived data): `** TEST BUILD SUCCEEDED **` | DONE |

## THE LIVE PROOF — the script (written before the walk; the acceptance gate, use-shaped)

On the throwaway (ref-guarded), stage claim `vx-494`, the walk build of the FIXED tip in `DerivedData/vx494b`, the
throwaway env mapped and verified by `ps eww` before anything else. The corpus: a generated book (1,200 notes × 30
paragraphs — `scratchpad/make-scale-corpus.py`, deterministic prose, no real content) IMPORTED into the planting
library L1 (`1eb1d88c`, the pre-fix walk build — the push path is unchanged) and pushed to throwaway A: the server holds
1,200 containers · 36,000 blocks · 36,000 variants · 36,000 placements · 1,200 memberships (~110k rows — her corpus's
scale; A's write budget 11 of its 500k first-load pool before it).
1. Quit L1; its slot files aside by `mv` (a second aside dir, `Variorum-dev-aside-vx494-L1`).
2. Launch the fixed build → a fresh library L2 on the empty slot (Standard), A's sign-in carried by the dev scope.
3. Settings ▸ Protection ▸ Turn on sync → the JOIN arm → the passphrase by the fenced helper → the first catch-up.
4. Measure the download: data windows counted by response size (a 2,000-row window is hundreds of KB; the
   challenge and empty calls ~1 KB) — expected ~56 windows, not ~550.
5. **THE INTERRUPTION:** quit the app partway through the download (~half the windows), relaunch (Standard opens
   quietly) — PASS = the next round downloads only the REMAINING windows (the resume), then saves; FAIL = ~56 again.
6. Measure the save (CPU + WAL, as on her Pro); then the proof of commit: the server's `device_cursor` for L2's
   device reads the head, the row reads Synced, the Bookcase shows the scale book.
7. Restore the dev slot whole BEFORE the closing Mac run (the test host is the dev-store app): sign the walk session
   OUT (O-B2), quit, remove the walk libraries' slot files + their `Backups/<id>` subfolders (and the walk backups'
   far-folder copies), `mv` the 9 dev files back (same inodes), plain relaunch — rule 21's notice once — then quit.

## THE LIVE PROOF — the record (2026-10-23 04:41–05:0x MDT, stage claim `vx-494`; the throwaway only, `ps eww`-verified every launch)

- **The plant:** the generated book (1,200 notes × 30 paragraphs) imported into L1 (`1eb1d88c`, the pre-fix walk
  build) at 04:41 — one import transaction (CPU ~80%, WAL to ~31 MB) — then pushed in 200-row chunks to throwaway A:
  server counts 1,200 containers · 36,000 blocks · 36,000 variants · 36,000 placements · 1,200 memberships (~110k rows).
  The planter's own echo pull then ran in the pre-fix 200-row windows (the old shape, visible as ~40 requests/min);
  quit at 04:55 (no stage on the pre-fix build — nothing to resume there), its 5 slot files aside to
  `Variorum-dev-aside-vx494-L1`.
- **The fresh library on the FIXED build** (`DerivedData/vx494b`, built from `34abbef16` — the product = `c33f18f09`):
  L2 `35067e12` (device `5546f6f7`) created in Standard on the empty slot; A's sign-in carried. Settings ▸ Protection ▸
  Turn on sync = the JOIN arm ("Your account already syncs. Type its passphrase or its twelve words once…") → the
  passphrase by the fenced helper → `enroll: begun #1` (04:56:01).
- **OBSERVATION O-1 (her call; a ticket candidate):** the Standard join raised a SYSTEM Touch ID prompt —
  "Variorum Dev is trying to Unlock your Variorum library. Touch ID to continue with Variorum Dev." — and waited on it
  (~2 min; no network, low CPU). Cancelled by the session (no finger, never her password): the join then COMPLETED
  *[removed for publication]*
  What the cancelled prompt skipped is unverified (suspected: the on-device quiet road's re-lock under the new pair);
  the relaunch below opened quietly regardless (`custody silent 16`).
- **THE DOWNLOAD (D1 live):** the first catch-up began at once after the join (04:58:2x) — **56 data windows, 16.9 MB,
  done by 04:59:30: the whole ~110k-row feed in ~70 seconds** (her Pro this morning: ~550 windows, 11 min 36 s, on
  her server's heavier per-call cost). 56 windows × 2,000 rows = the feed: the window size is live in the app.
- **THE INTERRUPTION:** a quit at 04:59:15 was REFUSED (`User canceled (-128)`): the join's modal ("Your twelve words
  are vx308a@example.com's twelve words…", OK) held the app. The process was then KILLED (`kill -9`, 04:59:38 — a
  crash's shape, harsher than a lock or a quit; the throwaway's walk library, never a real store): the download had
  finished at 04:59:30, so **the kill landed in the SAVE** — the case under which today's code throws the whole
  download away (her Pro's save ran ~4 min 20 s).
- **THE RESUME (D2 live, the hard case):** relaunch 05:00:00 → `road: opened — library 35067e12 … device 5546f6f7`
  quietly → **six small calls at 05:00:01 (the janitor's pre-pass, the lockstep check, a challenge fetch, ONE empty pull
  from the stage's reach) and ZERO data windows** — then the save straight from the stage (CPU 100%). PENDING: the save's
  length, the proof of commit (L2's `device_cursor` at the head), the row, the Bookcase.
- **OBSERVATION O-2 (the stage's disk footprint):** with the whole feed staged, L2's store file read **79 MB** (the
  staged JSON beside the empty library) at 05:00; the stage empties with the commit, but SQLite keeps its pages as
  free pages until reused (no VACUUM runs) — PENDING the post-commit size. Her library would carry ~the same order.
- **THE SAVE FROM THE STAGE + THE PROOF OF COMMIT:** the save ran 05:00:01 → ~05:07:10 (~7 min at ~100% of one core,
  WAL to 143 MB; the cold reviewer's test runs shared the CPU), then the follow-up round's ~20 small requests. **L2's
  `device_cursor` = `last_seq` 110,424, `seen_at` 11:07:17 UTC — exactly throwaway A's head (110,424)**; the
  Bookcase shows "VX-494 scale corpus — 1200 notes · 12 ch · 1,080,072w"; the row "Synced 5:07 AM". THE ACCEPTANCE
  GATE PASSES: D1 (56 windows, ~70 s) and D2 (a crash during the save, zero re-download, the save from the stage,
  committed to head) live on real Postgres at her corpus's scale.
- **O-2 measured:** the same corpus WITHOUT a stage (the planter L1) is a **79 MB** store; L2 after the stage's commit
  is **150 MB** (+ a 150 MB WAL awaiting checkpoint) — the stage leaves ~its own size (~the data's size) as free pages.
  The app never VACUUMs (and VACUUM may renumber rowids behind the search index's external-content table — not a
  drop-in), and backups use the page-copying backup API (`AppDatabase.swift:227`), so the slack rides in that
  device's backups until growth reuses it. Correctness untouched; a fresh device's first catch-up only. HER CALL
  (bundled): accept for 0.10 + a compaction-design ticket, or hold the Air until it exists.
- Quit at 05:08 (zero instances).

## THE DEV SLOT — RESTORED WHOLE (2026-10-23 06:00–06:03, stage claim `vx-494`)

- **No re-walk after the R1 fixes, by the orchestrator's call:** the fixes change only edge handling (the stage's
  format/lockstep identity, an undecodable row's discard, the apply's moved-cursor belt) — all pinned headlessly with
  revert-proven teeth; the happy path the walk proved (D1's windows, D2's resume, the commit) is unchanged.
- **O-B2 honored:** L2 relaunched with the walk env (`ps eww`: the throwaway ref, no production ref) → Settings ▸
  Protection ▸ Sign out… → "Sign out of this Mac?" → Sign Out → "You're signed out of sync." → quit (zero instances).
- **Removed (each listed first; every one tonight's, of the two walk libraries `1eb1d88c`/`35067e12`, keys
  `7b426467`/`7736e51a`):** L2's 5 slot files; the `Variorum-dev-aside-vx494-L1` dir (L1's 5 files); the slot's
  `Backups/1eb1d88c` + `Backups/35067e12` (2 pairs each); the far folder's `~/Documents/Variorum/Backups/1eb1d88c` +
  `/35067e12` (1 pair each).
- **The 9 dev files `mv`'d back** from `Variorum-dev-aside-vx494` (same inodes, 191598614–191598620, 192555064/5;
  never written while asided); the aside dir removed.
- **The plain relaunch** — the PRE-fix walk build `DerivedData/vx494` (main's schema, so the dev store is NOT migrated
  to v1_32 ahead of main), no walk env (`ps eww` = 0) → `road: opened — library e11e5233` → **rule 21's notice ONCE**
  ("This is a different library than the one this Mac last had open") → OK → the dev library open QUIETLY, "Sync off
  (dev store)", the October-20 hold banner standing, Resume never pressed → quit, zero instances.
- **Residue (the recorded §8 class):** the walk libraries' custody/memory keychain items; the walk-era device-ID
  consequence on the dev library (VX-465's accept-as-designed). The throwaway keeps A's 110k-row planted corpus and
  vault (Standard, the throwaway passphrase) — hers to delete with the project.

## THE BEHAVIORAL REVERTS (run 2026-10-23 ~04:50 on the committed tip `3f15dc6f0`'s product files; each one file,
restored by `git checkout --`, `git diff --exit-code` clean after every one — **no revert is in flight**)

`swift test --filter ResumableCatchUpTests` under each:
- **RV1** (`pullWindowSize` default back to 200): `✘ … 5 tests … with 1 issue` — `theProductionEngineDownloadsInLargeWindows`
  ✘ (`pullCalls == 2`) only.
- **RV2** (`pullRound` ignores `.resume`): `✘ … with 2 issues` — `anInterruptedFirstCatchUpResumesWhereItStopped` ✘
  (`secondRound.first == failedAt`, `!secondRound.contains(0)`) only.
- **RV3** (the plan drops the device-id match): `✘ … with 1 issue` — the device GUARD ✘ (`secondRound.first == 0`) only.
- **RV4** (the apply's `PullStage.clear` removed): `✘ … with 2 issues` — the stall GUARD ✘ and D2's empty-stage line ✘
  (`stagedRowCount == 0`), both.
- **RV5** (`retire()` no longer cancels): `✘ … with 2 issues` — `retiringASchedulerStopsItsInFlightDownload` ✘ (`pulls == 1`,
  `cursor == 0`) only.
- **RV6 — HOLLOW, recorded not fixed** (the fetch loop's explicit `Task.checkCancellation()` removed, retire's cancel
  kept): `✔ … 5 tests … passed` — the retired round still stops, because the stage's own `database.write` honors the
  task's cancellation before it runs (and in production `URLSession` throws on a cancelled task too). The line stays as
  an explicit belt between windows; no test can tell it apart from the two cancellation points beside it, so it is not
  claimed as pinned.

**Two more runs (the closing-coverage baseline for the reviewer):** the core suite RELEASE (`swift test -c release`):
`✔ Test run with 3284 tests in 429 suites passed`; in BOTH configurations the one red is the same MCP harness timing test
(`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 18.97 s vs its 15 s bound,
both runs within 0.001 s of each other — deterministic, not load-shaped; RUN ALONE it passes on BOTH sides —
`main` `✔ 3 tests in 1 suite passed after 2.166 s`, this branch `✔ … after 2.178 s` — so the red is load-shaped (the
full suite's parallelism), the known MCP harness load-flake family; no MCP code is in this diff).

## THE EVIDENCE (2026-10-23, re-read by this session)

**The kickoff's reading was "one pull call, then a hang." The morning's unified log says otherwise: every attempt
was paging steadily through the whole corpus, and every attempt was cut off before its round could finish.**

1. **The server probe could not have seen more than one call per round — by design.** `SyncEngine.pullRound`
   (`Sources/VariorumCore/Sync/SyncEngine.swift`, the fetch loop) sends the device id on the FIRST window only
   (`windowDevice = fetchCursor == since ? deviceID : nil` — the 13j rule: only a committed cursor may be recorded).
   So `device_cursor.seen_at` stamps once per ROUND, and `last_seq` reports the cursor the round STARTED from. "One
   stamp per round, last_seq 0" means "rounds start, and none has committed" — not "one call".
2. **The calls (CFNetwork task summaries, `log show` 02:40–03:20 MDT, process `Variorum`):** 27–160 successful
   requests per minute from 02:44 to 03:15, ~1–2 MB per minute, ~22 MB over the first attempt; average request
   ~1.9 s at a round's start falling to ~0.4 s near its end — the server's per-window cost scales with the rows
   still ahead of the cursor. No failed task anywhere in the window.
3. **The app's own lines (`io.lduarte.Variorum:protection`) name every interruption:**
   - pid 34088: Touch ID unlock 02:44:13 (sync keys loaded — VX-487's fix live) → round 1 fetches from 02:44:14 →
     **02:55:16 `road: locked — the library closed behind the lobby (VX-445)` — the 10-minute Castle idle lock,
     ~50 s before the fetch reached the feed's head** (the request rate spikes to 160/min in 02:55, the end-of-feed
     shape) → the apply had no open library to write into → nothing committed.
   - 02:56:54 her Touch ID unlock → round 2 from cursor 0 (the server's 02:56:55 stamp) → 02:57:12 `this Mac locks
     after never away now` (she turned the idle lock off) → the process ended ~03:04 (her quit, ~7 min in).
   - pid 34577 03:04:39 (`custody … touchid 0` — the gate-re-arm launch; `this Mac's gate is touch_id now` 03:05:33).
   - pid 34646: unlock 03:06:19 → round 3 from cursor 0 → requests every ~1 s until **03:15:47 (a pull request sent,
     never answered in the log) and the process's last line at 03:15:48** — the app ended ~9.5 min in, roughly two
     minutes short of where round 1 reached the head. Nothing after it.
4. **The corpus (read-only, production, ref-guarded):** blocks 20,847 · variants 32,799 · commit_point 28,937 ·
   container 864 · container_block 20,841 · edge 2,364 · post_tag 877 · tag 107 · reading 40 · reading_post 741 ·
   purge_intent 1 (≈ 108k feed rows before the smaller tables); `purged_row` 7,840. At the engine's window of 200
   rows that is ~550 pull calls per from-zero round.

**H1 (the leading reading — reproduction pending):** a from-zero catch-up is ALL-OR-NOTHING. `pullRound` fetches the
whole feed to head into memory (~550 windows, ~10–12 min on her corpus) and only then opens ONE apply transaction;
the cursor commits only with it. Any interruption before that commit — the Castle idle lock (round 1), a quit (rounds
2 and 3), a sleep, a single transport error among ~550 calls — discards everything fetched, and the next round starts
again from 0. At her scale the fetch alone is longer than Castle's default 10-minute idle lock, so with the default
setting the first catch-up can never land; with the lock off it needs ~12 uninterrupted minutes of "Syncing…" with no
visible progress, which reads exactly as a hang. The throwaway rehearsal (a handful of rows) fetched in one window,
which is why the same build synced clean there.

**OPEN QUESTION Q1 (the reproduction answers it):** left alone, does the one apply transaction over ~108k rows commit,
and how long does it hold the writer? Nobody has observed it. If it does not commit, there is a second mechanism.

## HER EXPERIMENT'S RESULT — Q1 ANSWERED: THE CROSSING LANDED (2026-10-23, her real app, 0.10 build 9093)

Left alone (the idle lock Never, the app open, the Mac held awake), the first catch-up on her real corpus COMMITTED:
- **The download:** her Touch ID unlock 03:56:21 (sync keys loaded) → the empty end-of-feed window at **04:07:57**
  — **11 min 36 s**, ~33 requests/min early rising to ~180/min at the end (the per-call cost falling as the cursor
  advanced), every request 200.
- **The save (the one apply transaction):** 04:07:57 → ~04:12:15 — **~4 min 20 s at ~100% of one core**, the store's
  WAL growing steadily to 87 MiB (sampled every ~20 s: 50 → 57 → 61 → 71 → 75 → 77 → 79 → 85 → 87), RSS ~280 MB, no
  network; the Library showed "Nothing matches" and the row "Syncing…" throughout (her screenshot, 04:09) — nothing
  is visible until the one commit.
- **The proof of commit:** at 04:12:16–18 ~20 small successful requests (the push, the janitor, a follow-up round),
  then quiet at 0% CPU; the server's `device_cursor` for her Pro (`7e7609fa…`) reads **`last_seq` 229159, `seen_at`
  10:12:17 UTC** — a later round reporting the committed cursor (229159 = her tenant's head, `commit_point`'s max).
- **Nothing uploaded:** no row of her tenant on any table sits above 229159 — the fresh library had nothing left to
  push after the merge (its starter furniture met her copies). Read-only probes only; nothing written to production.

**What it settles:** there is NO second mechanism — H1 is the whole story. A from-zero catch-up of her corpus needs
~16 uninterrupted minutes (11.6 downloading + 4.3 saving), all silent, all-or-nothing — longer than Castle's default
10-minute idle lock, so with the default it could never land, and every quit restarted it from zero. The save alone
also holds the store's writer ~4 minutes (~420 rows/s): a lock or quit DURING it would cost the whole download again
under today's code. D2 below removes the re-download; the save's own speed (per-row FK introspection, the search
index's triggers, the per-row bookkeeping) is a measured target for the headless scale test, recorded as D4.

## THE FIX DESIGN (PROPOSED — built after her experiment's result; every product-visible edge marked)

Three parts, each its own pin; the apply transaction's body (straggler fixpoint, merges, repairs, the cursor) stays
BYTE-IDENTICAL, so §5–§7's semantics do not move.

- **D1 — the pull window gets its own size.** Today one `batchSize` (200) sizes both the push chunk and the pull
  window. The pull window becomes its own parameter (proposed 2,000 rows). Why it matters: the server's
  `sync_pull` re-sorts every row still ahead of the cursor on EVERY call (the morning's per-call ~1.9 s → 0.4 s
  decay is that shape), so total download time ≈ calls × average cost, and the call count is the lever the client
  holds: ~550 calls → ~55 on her corpus. Server-side ceiling to check before choosing the size: Supabase's
  statement timeout for `authenticated` (per-call cost must stay well under it; an EXPLAIN ANALYZE of the served
  query at `since = 0` for 200 vs 2,000 rows, read-only, decides). The real cure — a per-page cost proportional to
  the page (index-ordered keyset per table) — is a SERVER change, so a deploy at her word; proposed separately, not
  tied to this fix. Note for her: total cost is QUADRATIC in corpus size with today's query (calls ∝ N, each ∝ N),
  and a large enough account would hit the statement timeout on its first window whatever the page size.
- **D1's server check (2026-10-23 ~04:25, read-only, production — EXPLAIN ANALYZE of the served query's exact shape
  for her tenant at `since = 0`; timings only, no rows returned):** the `authenticated` role's statement timeout is
  **8 s**; the plan is Seq Scan on every table → to_jsonb of every eligible row (58,347 past the A5 horizon filter) →
  a full Sort → Gather Merge → Limit, so the page size barely moves the cost: **LIMIT 200 = 2,934 ms, LIMIT 2,000 =
  1,477 ms** (the second warmer). A 2,000-row window therefore costs about what a 200-row one does and cuts her
  catch-up's ~550 calls to ~55. Ceiling recorded for VX-495: the from-zero call already sits at ~1.5–3 s on her
  ~108k rows and grows with the account, so an account a few times hers would meet the 8 s timeout on its first
  window whatever the page size — the server query is the real cure (VX-495).
- **D2 — the download is resumable.** A local-only table `sync_pull_stage(table_name, row_id, server_seq,
  payload, PK(table_name,row_id))` (migration `v1_32`, its own commit; registered in `SyncSchema.localOnlyTables` and
  `LocalMachineryRecreation`; no mirror, no lockstep — never synced) plus ONE `sync_state` header key carrying the
  stage's identity: the committed cursor it extends, its fetch position, the round's corpus key id and device id.
  Each fetched window is decrypted (the seam unchanged — before any write) and upserted into the stage in its own
  small write (a row's newer version replaces an older one: keep the higher `server_seq`), the header advancing with
  it. At head, the staged rows (ordered by `server_seq`) feed the UNCHANGED apply transaction, which also clears the
  stage and the header — so a rolled-back apply keeps the stage, and a stall (the cursor held at the stall point)
  discards the stage exactly as today's round discards the rows after the stall. A round resumes from the stage only
  when its identity matches (same committed cursor, key id, device id); anything else clears it and fetches from the
  cursor. `resyncReinitialize` clears it. **The 13j device rule is kept as written:** the device id rides only a
  window whose `since` is the COMMITTED cursor, so a resumed round reports no device stamp (it never over-reports
  what is integrated; the purge horizon stays conservative — her account's horizon is already held at this device's
  committed 0 until the apply lands).
- **D3 — a stopped session never strands "Syncing…" (VX-493's mechanism, read in code):** `SyncSession.stop()`
  (`App/Variorum/Shared/SyncSession.swift:189`) cancels the status observation and retires the scheduler but leaves
  the published `status.isSyncing` as it was — a lock mid-round shows "Syncing…" until something reconfigures — and
  the retired scheduler's in-flight round keeps downloading in the background. Proposed: `stop()` clears the
  published in-flight flag; `retire()` cancels the running round, and the fetch loop checks cancellation between
  windows (with D2, a cancelled round loses nothing). VX-493 rides as a member-like rider (its own pin, `Part of
  VX-493` commits) — offered to her; VX-492 (the idle lock firing mid-catch-up) is hers to re-rule once D2 makes the
  lock cost nothing but a pause.
- **Not proposed (product-visible, hers):** a progress line on the sync row ("Syncing — 40,000 of 108,000"); the
  server query rewrite.

## HER RULINGS (verbatim-faithful, dated)

- **R-494-1 (2026-10-23 ~03:55 MDT) — the cast: Opus writes the `Sync/` fix and a fresh `opus-reviewer` runs the
  ladder** (her waiver of the standing Fable review for `Sync/`): "yeah go with opus - i think fable will almost
  certainly just hit a bunch of safeguards."
- **Her experiment (2026-10-23 ~03:55) — the real crossing, left alone:** her question, "if it's just a matter of
  waiting, should I sign back into my own account and just wait 15 minutes to see what happens?" Answered yes, on
  her REAL app at `/Applications` (never the Debug app — her account fence), idle lock confirmed Never, app left open
  and visible, the Mac held awake by this session (`caffeinate -dims -t 3600`), ~30 minutes rather than 15 (≈12 of
  downloading, then the one save, whose length nobody has seen). It answers Q1 on her exact data; the session watches
  read-only (the app's log, the server's `device_cursor` and data max). The walk app was quit first (zero
  instances), her throwaway sign-in kept; the test set-up waits. Her concern recorded: "i don't want my library to
  become the account's library?? that doesn't seem good" — the set-up's words meant the fresh EMPTY test library
  and the throwaway account; answered in session.
- **R-494-2 (2026-10-23 ~04:01) — the scope: D1–D3 tonight; the server query and the progress line after the Castle
  switch, as their own tickets:** "huh maybe we should do a faster server query. i have been annoyed by how slow sync
  is before already - maybe file a ticket for that right nwo. and we do also need a visible progress line - that
  would save me this current half hour test, so file a ticket for that too. we can fix 1-3 tonight and then i'll do
  the other two once the castle switch is fully done." Minted: **VX-495** (the changefeed query — Improvement,
  Confirmed, Performance, High; project 18a) and **VX-496** (the sync row's progress line — Improvement, Confirmed,
  Castle & sync, High; project 18a); both related to VX-494, Pre-launch left for her call. "1-3" = D1 (bigger
  pages), D2 (resumable download), D3 (the stranded "Syncing…", VX-493's mechanism).

- **R-494-3 (2026-10-23 ~04:40) — the cold review, the cast, the night:** "make sure that you run a cold review on
  your own work since you're doing this work directly. also, this is what I knwo from the rest of the run. should you
  be the orchestrator for the rest of it? does it need Fable for any points of it? I want everything to continue
  forward because I am now going to sleep." (She pasted the window's remaining steps 1–7: her Pro acceptance; the
  fix's closing mechanics through merge and the rebuilt Pro install; the Air prompt + her Air crossing; the release
  publish; the site delta; the window close-out on main; VM-8 last.) **As ruled and answered:** this session stays the
  orchestrator to the end of step 2; the cold review is a FRESH `opus-reviewer` running `notes/REVIEW_PROMPT.md`
  verbatim over the whole diff (never this session's own read — R-494-1 covers the Fable waiver, so no step needs
  Fable); the night runs step 2 to its end — the ladder, the live throwaway proof, the closing runs, the PR merge,
  and the Pro install behind a fresh A1 ONLY if every gate is green (the previous 9093 bundle kept aside for a
  rollback, since v1_32 migrates her store on first open). Steps 3–7 are hers or follow hers: their paste-ready
  prompts and checklist land in the morning handoff.

## OPEN ITEMS
- VX-492 (the idle lock fires mid-catch-up) and VX-493 (a lock mid-round strands the in-flight flag) are now
  in-mechanism: re-check both against the fix before closing either.
