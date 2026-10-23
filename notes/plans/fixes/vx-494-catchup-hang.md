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
| 2 | Reproduction at scale (headless fake-server scale test; then the throwaway live, her sign-in) | IN-PROGRESS |
| 3 | The mechanism named (trace) | PENDING — H1 below is the leading reading, not yet proven by reproduction |
| 4 | Fix + red-on-old pin | NOT-STARTED |
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

## OPEN ITEMS

- The cast note: the kickoff named Fable's own hands for `Sync/`; the session now runs on Opus 5.5 at her word. The
  ladder's reviewer type is hers to confirm at the review (the standing default is a fresh `fable-reviewer` for
  `Sync/`).
- VX-492 (the idle lock fires mid-catch-up) and VX-493 (a lock mid-round strands the in-flight flag) are now
  in-mechanism: re-check both against the fix before closing either.
