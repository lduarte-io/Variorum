# VX-926 — her handoff (the test-flakes run)

**DRAFT — finalized after soak leg M3.** *(Every [M3-PENDING] slot fills at the soak's end; delete this banner then.)*

## Your checklist

- [ ] **File the Apple Feedback for the crashing test host.** The full draft (title, steps, notes) is in the run record under "The Apple Feedback draft" — copy it into Feedback Assistant by hand. The five crash-report attachments are preserved at `~/.variorum/vx661-feedback-ips/` (they age out of DiagnosticReports, so these are the only copies). It's also linked from VX-661's comments.
- [ ] **The release is NOT mine and is NOT staged by this run.** The wave merges in order (vx-913 → vx-926 → vx-915/vx-849); only the LAST merger stages the 1.4 release (build + DMG + drafted notes), and nothing publishes to stargazing.tech until your word. When you're ready, say the word to whoever staged it.
- [ ] **Read the QUESTIONS bundle** (#[M3-PENDING — number at the merge]) — the run's provisional calls, each with options and what was built. None gates anything; they're ratify-or-redirect.
- [ ] **VX-695 stayed open on purpose** — see "the honest non-close" below. Nothing for you to do unless you want to re-rule it.
- [ ] Skim the tickets-filed list at the bottom (also this session's last message).

## What this run was, in plain English

Your test suite had flaky tests — tests that fail sometimes for reasons that have nothing to do with the code they test. They kept interrupting overnight work (every red has to be chased before anyone can trust a run), and with the code about to be open-sourced, strangers running the suite would hit them too. This run traced each flake to its actual mechanism and fixed the mechanism, never just the symptom. Four stories:

**1. The MCP socket tests were starving themselves (eight tickets, all fixed).** Swift runs async code on a shared pool of worker threads — twelve on your Mac. The MCP tests start a real server and then WAIT for its answers, but the waiting itself was holding those worker threads, and the server they were waiting FOR needed one of those same threads to answer. Under a full test run, every thread ends up holding a wait and nobody can answer anybody: a circular wait, broken only when timeouts expire — which looked like "the server never answered" and failed the test. The fix moves every wait in the test harness onto its own private thread, so the pool stays free for the servers. The door itself (the real MCP server your AI clients talk to) was never slow — we measured it answering in milliseconds even under heavy load. No product code changed.

**2. The test app was crashing mid-run (the scary one — two tickets).** The test host app would sometimes die with a memory crash. We read every crash report on the Mac: it's an infinite loop INSIDE Apple's two testing frameworks — when an issue is reported while no test is running, XCTest hands it to Swift Testing, Swift Testing hands it back, forever, until the stack runs out (931 loops in every report). Our app's only trigger was its own launch code doing work during test runs — and an earlier fix (VX-604, the "inert test host") already removed that. Zero crashes since, including all [M3-PENDING: N] overnight test runs. The loop itself is Apple's bug: **the Feedback draft is written for you to file** (checklist, top).

**3. One test waited five minutes for a five-millisecond event (one ticket plus duplicates).** Swift's test runner starts EVERY test in the suite at once — about four thousand — and anything that needs a worker thread queues behind all of them, first-come-first-served. A test holding a database observation timed out waiting for a change notification that had fired long before but was stuck at the back of that queue. The fix: a small "priority lane" in the test harness that such tests opt into, so their deliveries jump the queue. Measured: a wait that took 272 seconds now takes a quarter of one.

**4. Tests were writing into your real dev app's settings (three tickets — two fixed, one honestly open).** The test host IS the dev app, so tests' per-note memories (window sizes, modes, current block) were accumulating in the real app's settings — 2,622 junk keys at one point — and later test runs would read them and fail. One new seam routes every per-note memory to a throwaway domain when the app is hosting tests, emptied each run; the real app's behavior is byte-for-byte unchanged. **VX-695 stayed open on purpose:** its proof needed the old polluted settings file to still reproduce the failure on the old code — and it no longer does, so we can't demonstrate what the seam cured. The fix family stands on other pins; VX-695 keeps its evidence on the ticket until it either reds again (unlikely now) or you close it as moot.

**The watched five (the "dissolve check"):** five other flaky tests we deliberately did NOT touch — we predicted their mechanisms and watched them across the overnight soak. [M3-PENDING: the verdicts with counts — zero reds so far across M1 and M2.]

**The one new flake of the night:** a spelling-door test redded once in M2 (the system spell checker picked the wrong "next misspelling" under a full run) and passed 5/5 alone. It's the known VX-953 family — tagged there with the new datapoint, no new ticket.

## The night's numbers (evidence, not proof — the pins in the record are the proof)

- Ladder: two rounds, 0 blockers; 1 major (a test bound that would have mis-blamed the fix) fixed and re-verified.
- The soak on the final merged tree: M1 whole-Mac 6,207/0 · c1 core-under-load 4,018/0 · c2 4,018/0 · mcp 691/0 · M2 6,222 with the one VX-953 red (green alone) · M3 [M3-PENDING].
- Crash watch across every leg: zero crash reports, zero restarts ([M3-PENDING: final]).

## Reference (ids, for when you want the trail)

Run record: `notes/plans/fixes/vx-926-test-flakes.md` (FOR A LATER READER at top; rulings R-926-1..5; adjudications A-926-1..5; the U1–U4 unit records; the ladder files alongside). Members closed: VX-850, VX-477, VX-353, VX-607, VX-685, VX-686, VX-722, VX-772 (U1) · VX-661 + VX-690 (U2, fixed-by-VX-604, soak-confirmed) · VX-625 (+ VX-723/924 dups, VX-932 rider) (U3) · VX-97, VX-666 (U4) · VX-665 (the rider, verified). VX-695 open (row-3). PR #[M3-PENDING], merged second in the wave.

## Tickets filed or tagged by this run

*(Also sent as the session's very last message.)*

- [ ] VX-941 — SQLite's global memory mutex serializes parallel test connections (possible whole-suite speed lever; measure first) — Low, filed from F-U3-1
- [ ] VX-942 — PerfBenchmark's timing-ratio pin reds under CPU oversubscription (named, not chased) — Low, filed from F-U3-3
- [ ] VX-953 — tagged: fresh sighting of the spelling arm at M2, NO external load this time (the width lens, F-U3-2); no new ticket
- [ ] [M3-PENDING: the closeout's R-926-5 pass — family-4 dispositions, VX-855's corpus note, VX-847's labels check, VX-608's soak read, the width ticket if confirmed, F-U1-2 / F-U4-1 / F-U4-3 mint-or-note calls]
