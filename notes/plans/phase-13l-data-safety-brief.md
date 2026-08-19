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
5. **Candidate, her ask (2026-08-19) — the passphrase sanity check.** Her
   words: "a place where people can verify that they still have their
   passcode or passphrase right without having to reset something else,
   like a sanity check." A read-only verify face (Settings → Encryption is
   the natural home): type the encryption passphrase → derive the wrap key
   (Argon2id, same params, OFF-MAIN — the derivation is deliberately slow)
   → attempt to unwrap the vault's master-key blob → say yes/no. The
   unwrap attempt IS the verification (GCM auth failure = wrong
   passphrase); NO state changes, NO re-key, NOTHING reset. The same face
   should verify the 12-word RECOVERY PHRASE by its own unwrap path — the
   forget-risk is identical (the R-6 enrollment-only cadence means neither
   secret is ever exercised day-to-day, which is exactly why people lose
   them). Thematically this phase's: the restore drill proves a backup
   restores; this proves the human still holds the key.

## Kickoff decisions (hers)

- Backup destination(s) and retention (defaults to propose: daily,
  ~14 dailies + a few weeklies). Note: the 2026-07-06 iCloud ban was
  about BUILD-ARTIFACT churn freezing the machine, not single files —
  one backup copy in iCloud Drive is a legitimate OFF-SITE candidate,
  her call.
- Whether candidates 3 and 4 are in scope.
- Where the visible evidence lives (log vs face).

## Recorded leans & facts for the kickoff (2026-08-18/19 — leans, not rulings; the sitting still decides)

From the author's backup questions (2026-08-18 conversation, folded here at
her 2026-08-19 instruction):

- **Fact:** the app has backed itself up automatically since Phase 8 — the A1
  WAL-safe snapshot (SQLite Online Backup API), checked hourly, written when
  the newest copy is >24h old, keeping 14, integrity-pinned. The copies land
  in `Backups/` beside the store — same disk, same container. **The real gap
  is the second location, not the mechanism.**
- **Lean — second-destination-first:** extend the EXISTING in-app scheduler to
  a second (off-disk / iCloud Drive) destination rather than a personal
  script or launchd job. Three grounds: the app already owns the correct
  WAL-safe primitive and the correct sandboxed path (the 14c record has a
  real wrong-container-path mishap from a hand-run backup); the store only
  changes while the app runs, so an in-app timer misses nothing launchd would
  catch; the brief already blesses one iCloud Drive copy (the 2026-07-06 ban
  was build-artifact churn, not single files). This refines scope item 1's
  "(launchd)" wording — the kickoff picks.
- **Lean — button-as-adjunct:** a "Back Up Now…" button with a destination
  picker is welcome ON TOP of the automatic job, never as the load-bearing
  mechanism — a manual button is "the job that silently stopped" wearing a
  different hat ("I forgot to press it for a month"). Freshness evidence
  stays the load-bearing face.
- **Fact (2026-08-19, hers):** she is on **Supabase Pro** now — the mirror
  side has 7-day server backups. Deliberately OUT of this phase's scope
  (local SQLite is truth; the mirror is a re-derivable peer, proven live at
  the 14c gate) — recorded so the kickoff knows the server side is covered
  and doesn't re-scope toward it. Note the mirror is ciphertext: a Supabase
  backup recovers synced STATE, never readable prose without her passphrase —
  one more reason the drill points at the local store.
- **Interim, zero-effort (until this phase runs):** point Time Machine (or
  any file-level backup she already runs) at the app container — the
  `Backups/` snapshots are single self-contained `.sqlite` files, no WAL
  sidecars, exactly the shape file-level tools copy safely.
- **Context for the kickoff:** her 2026-08-19 message asked whether she can
  return to real daily use NOW (she paused around Phase 14). The answer given
  (and worth re-affirming at the sitting): yes — this phase hardens the
  floor, it is not a precondition for use; real daily use is itself what
  Phase 12 waits for.

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
