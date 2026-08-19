# Phase 13l — The data-safety floor (EXECUTION PLAN)

**Status: AUTHORED 2026-08-19 at the 13j closeout — HER PICK, same
sitting the 13j window closed (round 13). She launches it at her
word; cast decided at kickoff as always.** Supersedes nothing: the
2026-08-02 brief (`phase-13l-data-safety-brief.md`) remains the
scope's origin and is folded here whole; this plan adds what 13j
changed under it — **the world now contains TRUE DELETE, and the
restore story must be deletion-aware.**

## HER MANDATE (verbatim — the requirement born at the 13j close)

> "I think it would be fitting post trash and deletion for you to
> write the phsae desription for 13l - the data safety floor. we
> have to make sure that items that have been deleted when restored
> from backup are restored or not in the expected way, including
> after a true delete, in addition to the other items that phase
> has."

And the phase's founding why (2026-08-02): *"i feel like on some
level i've still been a little afraid to fully trust in the app /
sync / start REALLY using it and feeling secure that my data isn't
being lost."*

## Kickoff message (paste-ready for the orchestrator she invokes)

> You are running Variorum Phase 13l under the shape the author
> picks at kickoff (confirm the cast, never assume; the brief notes
> this phase is largely autonomous by nature — a low-attention
> window fits it). Read IN FULL first: `CLAUDE.md` + the canon it
> loads (AppSpec §14's 13j delta is the latest state), this plan
> TOP TO BOTTOM, `notes/plans/phase-13l-data-safety-brief.md` (the
> scope's origin — items 1–6, the kickoff decisions, the recorded
> leans), `notes/plans/phase-13j-purge-memo.md` + its addenda (the
> purge design this phase's drill must prove out), and the 13j
> plan's Environment traps section (binding, as every phase — the
> A1 rail, kills-by-PID-only, the real-store container path). Copy
> the P-1…P-9 constitution into this file verbatim if running
> under `/architect-phase`. Verify the baselines with your own
> runs (13j finals: core **1350/141** · Mac **1546/269 FULLY
> GREEN** · spine **63/8** · mobile **314/60**; mirror at lockstep
> marker **7**). **OPEN WITH THE KICKOFF SITTING** (short — the
> decisions below); nothing destructive-adjacent runs before the
> A1 rail, and every restore-drill act happens in SCRATCH
> locations, never against her real store.

## Scope

**The brief's six items, carried whole** (automated scheduled
backups with second-destination-first per the recorded lean ·
the rehearsed restore drill + runbook · the bulk-`.md` plaintext
insurance candidate · the sync-status face candidate · the
passphrase/recovery-phrase sanity check · the ruled-in app-level
lock with honest wording) — **plus the 13j-born seventh:**

### 7. THE DELETION-AWARE RESTORE MATRIX (her round-13 requirement)

What restoring a backup does to deleted things must be DEFINED,
ruled where taste-shaped, TESTED headless, and REHEARSED live.
The matrix, with the design facts 13j established:

| # | Scenario | Expected outcome | Status of the expectation |
|---|---|---|---|
| M1 | Tombstoned (in its Trash window) at backup time; backup restored | Comes back tombstoned, same clock, restorable from the Trash | Design fact — test pins it |
| M2 | Deleted AFTER the backup; store restored to before the deletion — SYNCED account | The old cursor re-pulls everything since, INCLUDING the deletion tombstone: the item re-enters the Trash. Convergent, no user surprise | Design fact (state-based feed) — convergence test pins it |
| M3 | Same as M2 — LOCAL-ONLY install | The deletion is undone: restore is deliberate time travel | Honest by doc (the runbook + restore face SAY it) — kickoff confirms the wording |
| M4 | **PURGED (true-deleted) after the backup; store restored to when it existed — SYNCED account** | **The restored store is exactly a RETURNER: `reconcileLedger` (pre-drain, preflighted — 13j ladder B) re-drops the purged families before anything pushes; a push naming a purged id takes the typed refusal + local drop. "Really deleted" SURVIVES backup restore — by machinery that exists, which this phase must PROVE, not build** | Design fact — the drill's centerpiece scenario + a convergence test against the fake server's ledger |
| M5 | Same as M4 — LOCAL-ONLY install (no ledger exists) | Restore resurrects the purged thing. **TASTE CALL (kickoff): accept-and-say-it (recommended — restore IS time travel, like any file backup; the restore flow's one honest sentence: "things deleted after this backup's date will return — including permanently deleted ones") vs engineering a store-external purge memory (machinery smell; against the phase's floor nature)** | HER RULING at kickoff |
| M6 | Purged content living on INSIDE old backup files until retention expires them | Honest disclosure: the purge memo's "unreachable-but-on-disk" statement EXTENDS to backup retention; the runbook says so, and retention length is named as a privacy parameter (older backups hold what you purged) | Doc deliverable — kickoff confirms the retention default with this framing in view |
| M7 | The device-cursor monotonicity under restore (same device_id, older local cursor) | The server cursor never regresses (`greatest(...)` upsert — 13j); the restored store re-pulls from its old cursor harmlessly; the horizon stays sound | Design fact — one targeted test |

**Sequencing note:** M4/M2/M7 are convergence tests on the
existing fake-server harness (it has the ledger, cursors, and the
typed refusal since 13j batch 6b) — headless first, then ONE live
rehearsal folded into the restore drill (scratch store, scratch
account NEVER hers — or the fake-server road if a scratch account
is disproportionate; the kickoff picks).

## Kickoff decisions (hers — the brief's list, plus this plan's)

1. Backup destination(s) + retention (propose: daily, 14 dailies +
   a few weeklies; second-destination-first per the lean; one
   iCloud Drive copy legitimate). Retention framed WITH M6's
   privacy angle.
2. Candidates 3 and 4 (plaintext insurance; sync-status face) in
   or out.
3. Where visible freshness evidence lives (log vs face).
4. The app lock's fallback story (passphrase-when-enrolled +
   system fallback otherwise, or one uniform story).
5. **M5's ruling** (accept-and-say-it recommended) + M3/M6 wording
   confirmations.

## Binding constraints

- ZERO schema expected; anything firming toward one is a SyncSpec
  §12 lockstep event and a STOP for her explicit go.
- Zero `Sources/VariorumCore/Sync/` lines without the standing
  rider (M4's test may need fake-server harness extensions —
  Tests/, not Sync/; if the proof demands engine changes, STOP
  and report).
- **Every drill act in SCRATCH locations** — the real store is
  touched only by the SHIPPING backup scheduler itself, behind
  the A1 rail; restore rehearsals never point at her container.
- The 13j Environment traps bind verbatim (by reference); the
  standing RPC naming rule (no parameter shadows a column it
  writes — born at 13j round 12) binds any new server-adjacent
  code, though none is expected.
- Every PROVISIONAL → `notes/QUESTIONS.md` (next free number:
  check at kickoff — 13j used through **#73**).
- The tutorial spine (63/8) stays green; if the phase ships a
  user-facing face (the lock, the sanity check, the status face),
  registry discipline (P-1) and honest copy (the J8 bar) bind as
  everywhere.

## Baselines at open (verify with your own runs)

The 13j finals: core **1350/141** · Mac **1546/269 FULLY GREEN** ·
spine **63/8** · mobile **314/60**. Mirror at lockstep marker
**7**; the purge machinery live end-to-end (both devices cursored;
the janitor's first sweeps no-op until the horizon passes her
pre-13j tombstones — expected).

## Verification

Per-batch: the standing loop (build → red-on-old pins → the spine
green by TYPE name → full suites with counts quoted; mobile when
`Sources/`/`Shared/` is touched — iPhone 16e). The phase's own
acceptance: **a backup restores end-to-end in rehearsal with the
deletion matrix's expectations holding scenario by scenario; the
runbook exists where she can find it under stress; freshness
evidence is visible without her asking; and the matrix's two
honesty sentences (M3, M6) exist in the product/runbook verbatim.**
Review shape: the author sets it at kickoff. The closeout authors
the next phase's plan at her pick, writes the MobileSoul parity
line (the lock's Face ID twin + any status-face twin are the
obvious candidates), and runs the full closeout ritual.
