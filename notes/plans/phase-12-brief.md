# Phase 12 — Hardening & perf validation — DESIGN BRIEF

> **This is a BRIEF, not the execution plan.** Written 2026-07-06 in the author's
> forward-planning session (Fable); the just-in-time plan is written at **Phase 11's
> closeout** and MUST incorporate it. By this phase the app has months of the author's real
> daily use behind it (journaling from Phase 8, drafting from 9–11) — the brief's central
> instruction is: **harden against the evidence, not against hypotheticals.**

## What this phase is for

Prove the load-bearing claims at real scale, on the current OS, under real sync history —
and leave the debt table clean. Deliverables cluster into five efforts:

1. **P1 at corpus scale.** Extend the Phase 4 corpus builders to "years of journals + a
   book" (thousands of posts, tens of thousands of blocks, realistic fan/commit density
   *measured from the author's real store*, not guessed). Re-run every ratio-asserted
   benchmark (render, autosave, assembly, timeline keyset, editor keystroke path, read-tier
   cost from Phase 10) — flat means flat at this scale too. Zero TK1 fallbacks through the
   full §5 matrix.
2. **Sync soak analysis.** By now two devices have months of real history. Define the audit
   concretely: (a) dump-compare both stores' synced tables after a full sync (byte-identical
   remains the bar); (b) count and eyeball conflict/`rescued` variants (are S5 rescues rare
   and sensible?); (c) repair-frequency review (repairs firing often = a race the design
   thinks is rare isn't); (d) outbox drain times at editor rate on the real corpus.
3. **Pull-to-head windowing (KnownIssues row, owned here).** The remedy is pre-sketched and
   proven outcome-neutral (windows + straggler guard): implement per-window apply with
   per-window commits, sized against the real corpus; the acceptance test is the phone
   re-syncing from scratch against the author's full store within sane memory. Assess
   *before* building whether the real corpus even demands it yet — evidence first.
4. **Tombstone GC — a decision memo, not necessarily a build.** Design: sync-aware horizon =
   the minimum acknowledged `server_seq` across registered devices; physical purge of
   tombstones (and their unreachable `commit_point` rows — no `deleted_at` there by design,
   AppSpec §14.4) strictly below the horizon. The memo must treat: the never-returning
   device (horizon stalls forever → a device-retirement policy, which is an **author call**),
   server-side vs client-side purge ordering, and interaction with backups (a backup restored
   from before the horizon reintroduces purged rows — define the rule). Phase-6-class gate:
   the author adjudicates the memo; nothing purges until she accepts it.
5. **The debt sweep + standing rituals.** Every remaining KnownIssues row: resolved here, or
   re-affirmed with a named owner and a reason (the closeout must state "zero orphaned
   entries" honestly). Within-post virtualization: assess against evidence (has any real post
   approached 100k words?), likely re-defer with the evidence recorded. Backup restore drill:
   open a rotating backup copy through the recoverable-open path and verify it renders (a
   backup that's never been restored is a hope, not a backup). Spike re-run if any macOS
   point update landed unabsorbed.

## Pre-answered decisions in force here (2026-07-06 session)

- The backup ritual (rotating cold copies) ships in Phase 8 — this phase *drills* it, and the
  GC memo must account for it.
- Transport fault-injection and engine re-entrancy tests ship in Phase 8 — this phase re-runs
  them against the then-current engine and extends them if the soak analysis exposes a gap.
- The migration-lockstep rule (SyncSpec §12) has been exercised once by Phase 11's
  canvas_layout commit — fold its lessons into the GC memo's server-change choreography.

## Open questions the execution plan must answer

1. What the soak audit's pass/fail thresholds are (e.g., zero unexplained divergences; every
   `rescued` variant traceable to a real race).
2. Whether windowed pull lands now or is re-deferred with measurements (evidence rule).
3. GC memo scope: personal-phase-only horizon (two known devices) vs the multi-tenant shape
   Phase 14 will need — recommend designing the personal shape and noting the 14 extension.
4. Which Phase 13 prerequisites (perf headroom for styling, e.g. rendering-attribute budgets)
   should be measured now so the design phase starts with numbers.

## Review foci (for the cold reviewer)

1. Benchmarks: ratio-asserted at the new scale, compared against recorded Phase 4/6/10
   numbers — flag any silent budget relaxation at full severity.
2. The soak analysis ran against real data and its findings are recorded with counts, not
   adjectives.
3. Windowed pull (if built): outcome-neutrality proven (same final state as one-transaction
   apply on the same feed), cursor advances only on commit, straggler guard preserved.
4. GC: nothing destructive shipped without the author's accepted memo; the horizon math
   handles the never-returning device explicitly.
5. KnownIssues table verified zero-orphan (every row has a live owner).
