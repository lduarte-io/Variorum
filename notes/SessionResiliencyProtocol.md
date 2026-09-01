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

---

## Addendum — the second mobile seat's notes (2026-09-01, at her invitation; from a run that met four Opus session-limit deaths, one auth outage, a harness restart and a system crash with zero commits lost)

**One CORRECTION to the recovery protocol's rule 3.** It says "No transcript found" is *always*
the case after a harness restart or a crash. Falsified tonight: batch 10's implementer was
running when the Claude Code process exited under a system crash, and its transcript SURVIVED —
the notification said so and `SendMessage` resumed it in place with its full context. **So the
resume order is always (a) `SendMessage` first, even after a restart or crash; (b) a fresh narrow
continuation only when the send actually fails with "No transcript found."** The cheaper road is
available more often than the text assumes.

**Additions, each proven once or more this run:**

1. **The orchestrator may COMMIT a dead agent's survival record on its behalf.** 4.5c-phone's
   implementer died at the session limit exactly one step short of committing the record it had
   just written (an untracked file). The orchestrator committed it pathspec-limited (`df97677`)
   BEFORE resuming, so the resume had a pushed baseline and the successor instruction was
   literally "run one command and fill in §9." Rule: after a death, an untracked record on disk is
   committed by the orchestrator first, then the agent is resumed.
2. **Announce the revert state BEFORE starting reverts.** A death mid-behavioural-revert is the
   one truly dangerous death (a half-restored production file). None occurred tonight because
   every agent happened to write "no revert is in flight" into its record before starting, and
   "reverts starting — pre-revert copies in `<dir>`" as it began. Make it a rule: **no revert
   starts until the record names it and the pre-revert copies exist.** A successor then knows
   from the record alone whether the tree is mid-revert.
3. **Unique pre-revert directories per agent, restores verified by `diff` (and `sha256`).** The
   shared session scratchpad accumulates every batch's `prerevert/` across sessions (eleven by
   the end of this run); batch 7's wave found a STALE copy of a file it was itself editing in
   another batch's dir — restoring from it blindly would have clobbered the current work. Rule:
   `<batch>-prerevert/`, never a shared name; never restore from a dir you did not create; never
   `git checkout --` on a file the batch also edits (the 6b incident).
4. **The UNIT CLOSED banner as the cutover signal.** A successor or a timed check must never
   misread a live wave as a dead one. The first mobile seat's invention — an unmistakable
   "UNIT CLOSED" section atop the unit's review file, plus the state table updated, all pushed —
   is the signal; commit recency alone is not (a wave can be live and quiet for an hour). Every
   unit close writes it; every resume reads it first.
5. **Reviewers write their findings file INCREMENTALLY, not only before the final message.** A
   reviewer died mid-read tonight and lost nothing — but a reviewer dying mid-findings with the
   file unwritten would lose every finding forever (the compressed-summary class). Same rule as
   implementer records: the file on disk is the deliverable; the final message summarizes it.
6. **The orchestrator pushes its OWN commits immediately** (adjudications, briefs, unit closes),
   not only at unit closes — "pushed commits survive" applies to the orchestrator's records too.
   Tonight adjudication commits rode the next push; a death between would have left an unpushed
   adjudication that a successor could not see from another machine.
7. **Draft the successor handoff EARLY, with PENDING slots** — during a build's wait, not at the
   cliff. The ~500k line arrives mid-unit; a handoff drafted in scratchpad with `PENDING(hash)` /
   `PENDING(count)` slots is filled in minutes at the next clean seam, and it survives the
   orchestrator's own death as a mostly-written document. Commit it at the seam.
8. **The parent usually survives.** Every session-limit death tonight was the Opus subagent pool;
   the Fable orchestrator's calls kept working through all of them. So the recovery protocol's
   actor — the orchestrator — is normally ALIVE to run it, and should act immediately (read the
   tree, commit the survivors, resume) rather than waiting for a reset. Only the harness
   restart/crash takes the parent too, and even then its transcript resumed.
9. **Message running agents the checkpoint order the MOMENT she names a limit** — not at the
   next boundary. The one agent warned at "87%" reached a safe seam, wrote its survival record,
   and died one step later; without the warning it would have died mid-build with the record
   unwritten. The warning bought the record.
10. **Verify a resumed agent's first act is a commit+push.** After adopting the protocol
    mid-run, the orchestrator watches for the first checkpoint commit to appear; if none does
    within a reasonable window, the agent may have died silently again — check its state rather
    than assuming it is working.

## Clarification — the 500k line is a GUIDELINE, not a cliff (author, 2026-08-31 evening)

Her words, verbatim: *"I'd actually clarify the note to say that 500k is the guideline, but it's
not 100% absolute. If you're close to the stage ending, you should just finish it or it's more of
a cost to start a new session."* So: the ~500k figure (the orchestrator-side "plan the cutover"
bullet above, and the skill's "quality cliff" wording) is a guideline for WHERE to plan a seam,
not a trigger. **If the stage's end is near — a wave closing, a ladder mid-run, a closeout in
progress — finish it in the session that holds the context; a fresh session's re-orientation
read costs more than the remaining work.** Cut over only when the remaining work is large
enough to outweigh that read, at a clean boundary, with the handoff drafted early (addendum 7).
Applied the same evening: the pre-13u successor orchestrator, at ~560k, was ruled to finish the
round's tail (midpoint review · ladder · closeout) rather than hand off.
11. **The session scratchpad is NOT durable across a system crash — pre-revert copies must live
    where the tree lives.** Batch 10's implementer had a behavioural revert applied when the
    machine crashed; the tree survived, the scratchpad (and its `prerevert/` dir) did NOT, and
    the orchestrator's tree read — "no prerevert dir, so no revert in flight" — was therefore
    WRONG. The agent's own state check caught it and restored by hand. Two rules follow:
    (a) **commit before you revert** — a committed pre-revert state makes `git checkout --
    <file>` a SAFE restore and `git diff` an honest "what is reverted right now" (this also
    retires the batch-6b `checkout --` hazard, which only bites on UNCOMMITTED work); (b) if a
    copy is still wanted, keep it INSIDE the worktree under a gitignored, uniquely named dir,
    never in the scratchpad. And for the orchestrator: an absent prerevert dir proves nothing
    after a crash — read `git diff` against the last commit to see what is reverted.

## Addendum from the Fragments seat (carried by the author, 2026-08-31 evening — three items, all adopted)

1. **Confirm a suspected death by agent METADATA before replacing anything on a shared checkout.**
   A "died"/"completed" frame can be a display artifact while the agent is still committing.
   Before spawning a replacement: `ListAgents` (is the agent `running`?), the task status, and a
   fresh `git status`/`git log` — **a live agent gets a MESSAGE, never a twin.** (Orchestrator
   rule 1 above named the git check; this names the metadata check that comes first. Proven here
   the same evening: after the system crash, `ListAgents` showed the wave 2c closer `running` —
   its "stopped" notification was the artifact, and messaging it would have been wrong only
   because its transcript had been lost, which the send itself reported.)
2. **The replacement-agent rule (implementer side): if the worktree MOVES under your reads —
   files changing that you did not change — you are not alone. Write nothing, report, stop.**
   A predecessor may be alive and committing in the same checkout; two writers on one tree is the
   only way the checkpoint protocol can lose work. The orchestrator then resolves it (rule 1 —
   message the live one, retire the twin).
3. **A sharpening of implementer rule 4 (foreground waits) from both seats' evidence:** the
   background-wait trap is precisely about ENDING THE TURN. A subagent whose final message says
   "waiting on the suite" has ended its turn — and a subagent's end of turn IS its completion, so
   it dies with the run unfinished (two closes died this way on this seat). A MAIN session, by
   contrast, is re-invoked when a background command exits (the Fragments seat's reviewer; this
   orchestrator's `caffeinate` exit). So: **subagents wait in the foreground, always**; a main
   session may background a long run and act on the re-invoke — and should verify it is a main
   session before relying on that.
