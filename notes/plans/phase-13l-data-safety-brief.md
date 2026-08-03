# Phase 13l — The data-safety floor (BRIEF)

**Status: BRIEF ONLY — created 2026-08-02 at the author's request in
the post-13k conversation, her words: "when I have some more time i'll
do the data safety pass - can you make that a named phase in the 13s,
so it's easy to run later?"** It pulls the PERSONAL data-safety subset
of Phase 12 forward; Phase 12 keeps the at-scale work (corpus stress,
sync soak analysis, pull-to-head windowing, the GC memo) and
re-baselines on what remains. Cast at her kickoff, as always. This
phase is largely autonomous by nature (infrastructure, minimal taste) —
a low-attention window fits it.

## Why (her words, 2026-08-02)

> "i feel like on some level i've still been a little afraid to fully
> trust in the app / sync / start REALLY using it and feeling secure
> that my data isn't being lost. i want to know what you suggest before
> i can really start using it."

The recommendation this phase builds (Fable, same conversation): a
data-safety floor NOW — automated backups plus a rehearsed restore
drill — rather than full Phase 12 (which deliberately waits for
real-use evidence) or Phase 14 (identity/E2EE — not the trust path).
Real SYNC trust is deliberately NOT this phase's to deliver: it comes
from real two-device use, which the mobile project enables.

## Scope (the floor)

1. **Automated scheduled backups of the real store.** The A1 WAL-safe
   backup pattern — proven at every `/Applications` refresh — on a
   schedule (launchd), with retention and a per-run
   `PRAGMA integrity_check` on the copy, plus VISIBLE evidence: at
   minimum a log she can check; ideally a small face (last backup
   time, last verify result). A backup job that silently stopped weeks
   ago is the exact failure mode this exists to kill.
2. **The restore drill, rehearsed and documented.** Prove a backup
   restores END TO END once — into a scratch location, launched,
   spot-verified — and write the recipe where she can find it under
   stress (a runbook; candidates: `notes/handoffs/` or a Help face).
3. **Candidate, her call — plaintext insurance:** the 11b one-gesture
   bulk `.md` library export, automated on a schedule, so even a
   SQLite-eating disaster leaves prose.
4. **Candidate, her call — sync-status visibility:** a small
   "everything pushed / outbox empty / last pull at …" face so "did my
   writing reach the mirror" is answerable at a glance.

## Kickoff decisions (hers)

- Backup destination(s) and retention (defaults to propose: daily,
  ~14 dailies + a few weeklies). Note: the 2026-07-06 iCloud ban was
  about BUILD-ARTIFACT churn freezing the machine, not single files —
  one backup copy in iCloud Drive is a legitimate OFF-SITE candidate,
  her call.
- Whether candidates 3 and 4 are in scope.
- Where the visible evidence lives (log vs face).

## What this phase is NOT

- Not Phase 12 (at-scale hardening stays there; 12 re-baselines on
  what remains).
- Not 13j (Trash / true delete — purge design stays with the GC memo
  per that row).
- Not 14b (E2EE / server privacy).
- No schema expected; if anything firms toward one, it is a SyncSpec
  §12 lockstep event and a STOP.

## References

The A1 backup pattern (Phase 8 amendments; exercised at every
`/Applications` refresh since — most recently
`variorum-backup-2026-08-02-224558.sqlite`, integrity-ok) ·
`notes/DetailedPlanForPhases.md` Phase 12 row + the
v1-release-readiness row ("a right-sized Phase 12 — data-safety subset
as a release gate": this phase IS most of that subset, pulled forward)
*[removed for publication]*
