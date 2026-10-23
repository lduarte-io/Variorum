# VX-494 — the large-corpus first catch-up never lands

**STATUS: OPEN 2026-10-23 — investigating (the mechanism re-read from the morning's unified log; reproduction at scale
next).** Branch `vx-494-catchup-hang`, worktree `~/dev/variorum-vx-494`, the Pro. `Sync/` work — the fix is the
orchestrator's own hands (Fable at kickoff; the session moved to Opus 5.5 at her word mid-investigation, 2026-10-23
~03:40 MDT, "fable kept hitting the safeguards" — the cast note for the ladder is in OPEN ITEMS). The charter is
`notes/handoffs/vx-494-kickoff.md`. Pin-before-fix; the ladder is a fresh cold reviewer (Sync/ — no waiver). Commits
say `Part of VX-494`; NO trailers.

## LIVE STATUS (flip per piece, same commit; unverified claims marked PENDING)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight read whole; worktree + branch; in-flight row on main; VX-494 In Progress | DONE |
| 1 | The evidence re-read (the morning's unified log + read-only server probes) — THE EVIDENCE below | DONE (this commit) |
| 2 | Reproduction at scale (headless fake-server scale test; then the throwaway live, her sign-in) | IN-PROGRESS — the stage window is OPEN (claim `vx-494`, 03:48 MDT, 240 min): throwaway user A RESET to virgin (the §8 precedent — the 21 data tables, `device_cursor`, `purged_row`, `key_vault`, the `kp:` secret; entitlement kept; verified 0/0/0, entitlement 1; ref-guarded); the dev slot's 9 top-level files ASIDE by `mv` into `Variorum-dev-aside-vx494/` beside the slot (same inodes); the walk build (`DerivedData/vx494`, the branch tip) launched with the throwaway env mapped to `VARIORUM_WALK_*`, verified in-process by `ps eww` (2 vars, the throwaway ref, no production ref) — `A4 FENCE (VX-483): LIFTED`, fresh library `1eb1d88c` CREATED in Standard (silent custody). Waiting on HER sign-in as A + the set-up. RESTORE (owed at the window's end): sign the walk session OUT (O-B2), quit, remove the walk library's files + its Backups subfolder, `mv` the 9 back, plain relaunch (rule 21's notice once) — **THE OVERNIGHT ROAD PROVEN (04:30–04:36, her present):** the test app relaunched on the throwaway (`ps eww` checked: the throwaway ref, no production ref); her sign-in as A held; Settings ▸ Protection ▸ Turn on sync = the SET-UP arm ("Your account starts in Standard, like this library"), its three fields typed by the fenced helper (`~/.variorum/bin/type-throwaway-passphrase` — the throwaway passphrase twice, then the TEST library's twelve words, minted at its first look and kept 600 beside the passphrase); the act landed (`turnOnSync — library 1eb1d88c now names account <account-uuid>, standard`); after a relaunch the round ran unattended — the server shows A's `kp:` enrollment and device `90013cc3`'s cursor row (10:35:21 UTC), the row **"Synced 4:35 AM"**. OBSERVATION (a closeout ticket, Low): right after the Standard set-up the row stayed "Sync locked" until the relaunch — no round ran on the act's own (the Castle set-up's act-side round did run at the VX-488 rehearsal) |
| 3 | The mechanism named (trace) | DONE — H1 CONFIRMED by her real crossing (HER EXPERIMENT'S RESULT): the first catch-up commits when left alone (11.6 min download + 4.3 min save); every morning failure was an interruption of an all-or-nothing round |
| 4 | Fix + red-on-old pin | IN-PROGRESS — the pins committed BEFORE any fix (`b5ff84236`; RED on the pre-fix tree: `✘ Test run with 5 tests in 1 suite failed … with 7 issues` — D2 round 2's `since` was 0; D1 `pullCalls == 2` failed on ten 200-row windows; D3 `pulls == 1` and `cursor == 0` failed — the retired round downloaded the whole feed AND COMMITTED; the two GUARDS by design). The schema `f6658017b` (v1_32 — migration/schema suites 55/9 green); D1+D2 `c1583de0b`; D3 `c33f18f09` (also `Part of VX-493`). **GREEN on the fixed tree:** `✔ Test run with 5 tests in 1 suite passed`; the core suite debug `✔ Test run with 3313 tests in 434 suites passed` (the one red outside it: `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` 18.97 s vs its 15 s bound, run beside the walk app — the known MCP load-flake family; PENDING its solo re-run); release PENDING. **D3's second half DROPPED with its reason:** `SyncSession.stop()` clearing the published flag is unreachable on screen — `SyncRowFace.face` returns the sync-off/signed-out face on `!isConfigured` BEFORE it reads `isSyncing` (`SyncStatusViews.swift:127–133`), and `isConfigured` is `scheduler != nil` (`SyncSession.swift:45`), which `stop()` nils — so a stopped session can never show "Syncing…" (and the lock road replaces the whole services object besides: `VariorumApp.swift:289–290`). VX-493's stranded-flag claim is thereby REFUTED in code; its real defect (the background download) is D3. **THE BEHAVIORAL REVERTS (named here BEFORE any runs; each on the committed tip, one file, restored by `git checkout --` + `git diff --exit-code`):** RV1 — `SyncEngine.init`'s `pullWindowSize` default back to 200 (D1 pin must go red); RV2 — `pullRound` ignores the plan's `.resume` (always fetch from the cursor) (D2 pin red); RV3 — `PullStage.plan` drops the device-id match (the device GUARD red); RV4 — the apply's `PullStage.clear` removed (the stall GUARD + D2's empty-stage line red); RV5 — `SyncScheduler.retire()` no longer cancels (D3 pin red); RV6 — `pullRound`'s `Task.checkCancellation()` removed, retire's cancel kept (D3 pin's fate recorded either way — the transport's own cancellation may carry it) |
| 5 | Ladder | NOT-STARTED |
| 6 | Closing runs, PR, merge | NOT-STARTED |
| 7 | Release build + A1 + install; her crossing retry | NOT-STARTED |

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
