# Phase 13y — Per-Tenant `server_seq` + the Minimal Abuse Guard

**STATUS: plan AUTHORED 2026-08-30 at the 13p closeout (the just-in-time
rule). The phase has NOT run; it launches at her word.** Created
PRE-RELEASE at her 2026-08-26 launch-strategy ruling, the moment she
ruled sync OPEN at v1: *"I'm not going to block people from signing in
and syncing when the app is first released… It's cheap now. and it seems
like it's better to have it done."* The master-plan 13y row is the
scope's record; this plan is the buildable detail.

---

## KICKOFF MESSAGE (for the fresh session that runs this phase)

Read, in order: this file top to bottom; `CLAUDE.md` + the canon docs
per the standing preflight; **`notes/SyncSpec.md` IN FULL** (this phase
lives in its §2/§3/§5/§7/§9/§12 — the I-1 disclosure record in §12 is
the thing this phase closes); the 14c gate record in
`notes/plans/phase-14c-multi-tenant.md` (the mirror's born-multi-tenant
shape, the BYPASSRLS repair, the `variorum_definer` role);
`notes/plans/phase-13j-purge-memo.md` + SyncSpec §12's 13j entry (the
deploy-window choreography this phase repeats, and the
`device_cursor`/`purged_row`/`sync_horizon()` machinery it must review);
`Server/supabase/` DDL 01–10 (the live mirror's true shape).

**The whole phase is `Sources/VariorumCore/Sync/` + server SQL — the
standing Fable rider applies to ALL of it.** Cast decided at her
kickoff, as always. Her deploy window executes the lockstep (the 13j
precedent — her hands on the trigger); nothing deploys without her.

**Numbering facts, pinned so nothing collides:** 13p closed at marker
**7** with `Server/supabase/11_…` UNCLAIMED (its lockstep event was
dissolved by R13p-16). **This phase takes marker 7→8 and
`11_phase13y_tenant_seq.sql`.**

## WHY (one paragraph)

The mirror's `server_seq` is ONE global monotonic sequence stamped
across all tenants. Ordering-wise that is fine (each client only ever
SEES its own rows), but it leaks: any tenant can infer the AGGREGATE
write volume/timing of all others from the gaps in the seqs they
receive — the 14c I-1 accepted-and-recorded disclosure, accepted at
launch scale with the closure named as a future §12 event. With sync
OPEN at v1 (free ~3 months), stranger cursors accumulate from launch
day — after which a seq-semantics migration means resetting or
re-mapping REAL users' cursors. Now, with effectively one tenant, the
migration is nearly free. The same open-at-v1 ruling means the project
takes unmetered public writes from launch day — hence the MINIMAL abuse
guard rides along, and the Fragments agent gets an abuse-posture brief
through the standing carry channel.

## THE DESIGN CONSTRAINTS (from the row + SyncSpec — binding)

- **Client semantics UNCHANGED, and test-pinned.** The premise that
  makes this safe: a client's cursor only ever meets own-account rows,
  and §7's seq-ranked repairs compare rows WITHIN one account — so
  per-tenant sequences preserve every relative order any client ever
  observes. Step 0 VERIFIES this premise against the code before
  anything is built; if any client-side comparison crosses accounts,
  STOP and report (that would be a design surprise, not a detail).
- **Ordering authority stays `server_seq`** (§9) — per-owner now, but
  still server-stamped, still monotonic per the only scope any client
  sees. Wall clocks stay display-only.
- **Her existing seqs CARRY OVER as the initial per-tenant values — no
  cursor reset** for her devices (the row's explicit requirement).
- **ONE §12 lockstep event, HER window, the 13j choreography** (both
  her device builds refreshed in-window; the marker fences).
- **The server stays dumb.** Per-owner stamping is a trigger + counter
  table; no merge intelligence moves server-side.
- **The abuse guard is MINIMAL by design** — per-account write
  quotas/rate limits at the RPC layer with a TYPED refusal the client
  surfaces honestly (the §12 refusal grammar: outbox intact, cursor
  unmoved, a visible status). The tier's full posture is 13t's; this
  phase only ensures launch day is not an open firehose.

## STEPS (each with tests; suites run at step ends)

**Step 0 — the seq-assumption survey (read-only; the gate on
everything).** Enumerate every reader of `server_seq`/`sync_row_seq`
client-side (`Merge.swift`, `Repairs.swift`, cursor handling, the
janitor/ledger reconciliation) and every server-side consumer
(`sync_pull`'s ordering + the A5 visibility horizon, `sync_horizon()`,
`sync_purge_ledger()`, `device_cursor`, `purged_row`). Verdict each
WITHIN-ACCOUNT (safe) or CROSS-ACCOUNT (stop-and-report). Record the
table in this file. Test: none (survey); its output is the record.

**Step 1 — the mirror's per-owner stamping**
(`Server/supabase/11_phase13y_tenant_seq.sql`, deployed ONLY at her
window): a per-owner counter table + the stamping trigger swapped to
increment per `owner_id`; `sync_pull` ordering/cursor per-owner (the
RLS/owner scoping already fences visibility — the cursor semantics
join it); `sync_horizon()` and the purge ledger reviewed per Step 0's
verdicts; initialization copies each owner's current MAX(server_seq)
as their counter's floor so her existing cursors stay valid. The
in-file re-run guard per the 09/10 precedent; `sync_schema_version()`
7→8.

**Step 2 — the client.** `SyncSchema.lockstepVersion` 7→8; any Step-0
verdicted site adjusted (expected: none — the premise says client code
is already within-account); pins added: (a) a cursor never meets
another account's rows (two-user harness assertion, existing suites
extended); (b) §7's seq-ranked repairs produce identical outcomes
under per-tenant numbering (the repair suites re-run against the
per-tenant fake server); (c) the refusal grammar on the new quota
refusal (typed, outbox intact, cursor unmoved).

**Step 3 — the harness.** The fake in-process server gains per-tenant
counters (mirroring Step 1's semantics exactly); ALL convergence
suites re-run green; the DISCLOSURE-CLOSURE PROBE: tenant B writes
heavily; tenant A's pulls and seq bookkeeping are asserted to carry
ZERO information about it (no gaps, no advancing seqs A didn't cause)
— the probe is the phase's headline pin and the closeout amends
SyncSpec §12's I-1 record on its evidence.

**Step 4 — the minimal abuse guard.** Per-account write quota/rate
limit at the RPC layer (shape decided in-phase: simplest honest
mechanism — e.g. a per-owner rolling write-count check inside
`sync_push` refusing with a typed error). Client: the refusal surfaces
per the §12 grammar. Tests: the fake server enforces the same limit;
a suite proves an over-quota push refuses cleanly and recovers when
the window passes. NUMBERS are deliberately generous (launch-scale
honest-user headroom; 13t revisits).

**Step 5 — the Fragments abuse-limiting brief.** A dated carry item in
`notes/fragments-bridge-contract.md` sharing the quota/limit design so
the suite's posture is one posture (her ask, with the hands-off-repo
rule answering her "it's all stargazing" alternative — the brief is
the mechanism, never direct implementation).

**Step 6 — HER DEPLOY WINDOW (the 13j choreography):** mirror DDL
executed at her go; both her device builds refreshed in-window
(marker-8 builds; a marker-7 build visibly refuses after the deploy —
by design, keep the window tight); live verification (marker 8; a
live round green; her cursors intact — the Step 1 floor carry-over
proven on her real account).

## VERIFICATION (phase acceptance, from the row)

- Convergence + two-user suites green under per-tenant numbering.
- The disclosure-closure probe: a second tenant's write activity
  provably invisible in the first tenant's pulls and seq bookkeeping.
- Zero client-visible behavior change (the pinned premise).
- Her devices sync across the deploy with cursors intact.
- The quota refusal is typed, honest, and recoverable; normal use
  never meets it.
- SyncSpec §12's I-1 record AMENDED at closeout (the closure executed);
  the lockstep running record gains the marker 7→8 entry.

## NON-GOALS

- The tier's full rate/abuse posture, pricing, entitlement changes —
  13t's.
- Any merge-matrix or repair-semantics change — the phase's whole
  premise is that none is needed (Step 0 enforces).
- Fragments-side implementation — the brief carries; their repo is
  hands-off.
