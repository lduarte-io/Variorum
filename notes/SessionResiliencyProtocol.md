# Session Resiliency Protocol — surviving limits, crashes, and restarts without losing work

*Written 2026-08-31 at the author's instruction, from the pre-13u round's overnight run, which
survived one auth failure, three session-limit deaths, one harness restart, and one system crash
with ZERO commits lost. Her words: "please write a resiliency note for future sessions so that if
i anticipate any more crashes or issues (or i'm near a limit) the same discipline… can be reused."
This is that discipline, stated as rules. It binds every orchestrator and implementer session.*

## The one principle

**The repo is the only memory that survives.** Session transcripts die with the process; the
working tree and pushed commits do not. Every rule below is a way of moving state from the
transcript into the repo BEFORE anything can kill the transcript.

## For implementer sessions — the CHECKPOINT PROTOCOL (binding from the FIRST commit, not at 87%)

1. **Commit per coherent piece, push after every commit.** A WIP commit of a compiling state is
   legal — name it honestly (`… WIP: compiling state; faces not yet wired`). Never hold work
   uncommitted across a long build or suite run.
2. **Write the batch record's LIVE STATUS section at the START, and flip it in the same commit as
   each piece.** Per-piece lines: `DONE (hash)` · `IN-PROGRESS — exactly what remains` ·
   `NOT-STARTED — the settled design if any`. Every unverified claim is marked **PENDING**.
   The test of the record: *a fresh session with ONLY the repo can finish the batch from it.*
3. **Records before final verification** — counts and "green" claims land as PENDING and are
   flipped when the run completes; a record that waits for the suite is a record that dies with
   the suite.
4. **Synchronous foreground waits ONLY.** An agent that ends its turn awaiting a backgrounded
   suite/build dies as "completed" with the work unfinished (the background-wait trap; it killed
   two closes this round). Block on the log: `tail -n +1 -f <log> | grep -m1 '<EXIT LINE>'`,
   repeating the call past the 10-minute Bash timeout. Never `&`, never `run_in_background` for a
   run whose result you must act on.
5. **Never spawn subagents** (one agent at a time; repo reading is never delegated). An orphaned
   child's results route to the main session when its parent dies — that is a leak, not a road.
6. **On a limit warning from the orchestrator:** commit NOW (whatever compiles), write/flip the
   record NOW, push, then continue in SMALL increments — commit + record + push per piece.
7. **Machinery honesty:** every death and resume is noted in the batch record (which session died,
   what survived, what the continuation adopted).

## For the orchestrator — the RECOVERY PROTOCOL

1. **A death notification's `result` text is the agent's LAST STREAMED LINE, not its endpoint.**
   Never conclude loss from it. Check git first: `git log --oneline -6`, `git status -sb`,
   `git diff --stat`, and whether a suite is still running (`pgrep -fl "xcodebuild test"`) with
   its log. This round's "died at the start" agent had shipped four commits.
2. **Uncommitted edits SURVIVE deaths** (same working tree). The continuation ADOPTS them — reads
   the diff, finishes or commits deliberately. Never `git checkout`/stash over them.
3. **Resume order:** (a) `SendMessage` to the dead agent id — its transcript may survive a plain
   limit death (worked twice this round); (b) if "No transcript found" (always after a harness
   restart or a crash), spawn a FRESH continuation briefed ONLY from the record + `git diff`,
   never from your context. Narrow the brief to what remains ("the closer": commit the survivors,
   verify, close the record — no design latitude) so it re-orients fast and dies cheap.
4. **Relay orphaned child results** compactly to the continuation (file:line coordinates, not
   prose) — the child's work is otherwise lost to it.
5. **Kill nothing that is running under a dead agent** without checking: a still-running suite
   started by a dead session is usually worth waiting for (read its log) or re-running in the
   foreground; the author's real app is NEVER touched either way.
6. **Verify, never trust, every claim after a death** — commits, counts, records — by spot-check.

## Anticipating limits, crashes, and overnight runs

- **At a limit warning (hers or the harness's):** (1) message every running agent with the
  checkpoint order (§implementer rule 6); (2) refresh the orchestrator's memory file with a full
  resume map (what is done, in flight, next; baselines; the record's location); (3) keep the
  turn lean until the reset.
- **Keep the machine alive for overnight runs:** `caffeinate -dims` (its own process, detached),
  lid open, plugged in; zero-instance windows arranged in advance (the app quit by HER, never by a
  session); the A1 backup rail unchanged.
- **Memory is the orchestrator's transcript-proof state.** Update `variorum-phase-9-run-state`
  (or the phase's equivalent) at every significant state change — it is what a restarted session
  reads first.
- **Plan the cutover before the cliff:** at ~500k context, write the two-document handoff
  (`notes/plans/<phase>-orchestrator-handoff.md` with a PASTE-READY kickoff) at a clean seam — the
  same repo-first shape, applied to the orchestrator itself.

## What this looked like in practice (2026-08-31, so future sessions know it works)

Wave 2a died twice (auth, then the limit) — resumed once from its transcript, once from its own
record: every piece landed. Wave 2c died three times (limit, limit, then the harness restart +
system crash) — two fresh continuations and a narrow closer, each briefed from the record; the
"died at the start" session had actually shipped item 18 parts 1 and 2. Across all of it: **zero
commits lost, zero design decisions re-derived.** The cost of a death was the minutes of work
since the last commit plus one re-orientation read — which is exactly what the protocol prices it
at.
