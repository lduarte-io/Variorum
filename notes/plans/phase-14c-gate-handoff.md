# Phase 14c — GATE-HALF role handoff (the Round-9 session seam)

> **What this is:** the two-document cutover form (the `/architect-phase`
> skill's rule; `phase-13b-stage4-orchestrator-handoff.md` the exemplar).
> The BUILD-HALF session (batches 1–3, the ladder, the isolation round,
> the Fragments brief, the 14d draft) ends at a hard stop; a FRESH
> session runs the GATE HALF from the kickoff prompt below. The ONE
> running record remains `notes/plans/phase-14c-multi-tenant.md` — this
> file is the cutover's entry point, never a second record.
> **Fields marked [FILL-AT-STOP] are completed by the build-half
> architect in its final commit; if any remain unfilled, STOP and
> verify from the repo before trusting anything.**

## PASTE-READY KICKOFF (for the author to paste into a fresh session)

You are the GATE-HALF architect for Variorum Phase 14c (repo
~/dev/variorum, branch main), under `/architect-phase` discipline (the
skill file governs; CLAUDE.md binds). The phase's BUILD HALF is
complete: three batches, a closed review ladder, and a dedicated
isolation review, all recorded. Your half is THE GATE — the deploy,
the live probes, the domain, the signup flip, the author's validation
walks and ratifies, and the closeout ritual. Her Round-7 delegations
bind: YOU drive the deploy, the live probes, and the signup flip —
each announced before it runs — while she types her passphrase into
the runner, handles Cloudflare DNS, and does the phone-side acts and
walks. READ FIRST, in order: (1) `notes/plans/phase-14c-gate-handoff.md`
(this file) in full; (2) `notes/plans/phase-14c-multi-tenant.md` IN
FULL — the sitting rounds 1–9 are the settled rulings, the batch
records + architect adjudications are what exists, the ladder + the
isolation-round records are the review state, and the FRAMING NOTE
binds every subagent brief you write; (3)
`notes/sync-postmortem-fragments.md` before ANY
`Sources/VariorumCore/Sync/` line; (4)
`notes/plans/phase-14d-fragments-batch.md` (the draft your closeout
finalizes — its FILL-AT-GATE checklist is yours) +
`notes/fragments-bridge-contract.md`'s touchpoint #3 concrete-facts
block (its FILL-AT-GATE issuer field is yours); (5)
`notes/plans/phase-14c-smtp-runbook.md` §1 (the mailer facts + the
adjudicated ARM (a)). STANDING RAILS: the mirror is LIVE production —
every act announced before it happens, committed artifacts executed
verbatim, the A1 rail (WAL-safe UTC-named backup + full mirror export)
before ANY mirror-touching act; her Variorum-usage pause HOLDS through
14c (Round 1) — one active writer; instance checks by
`pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH,
real-store instances never killed; NO `/Applications` refresh before
the deploy lands (the lockstep-strand rule — the marker moves 5→6);
the signups toggle flips ONLY at the ruled choreography step; never
touch `~/dev/fragments` or the Fragments Supabase project. Execute the
gate in the RULED ORDER (the plan file's L13 row + "The gate" section),
then the closeout ritual in full. Bring her the RATIFY BUNDLE at the
walk. Announce each gate step to her before running it.

## The gate, step by step (the ruled order, with every recorded specific)

1. **The A1 rail:** WAL-safe backup of her real store (UTC name,
   `PRAGMA integrity_check`) + a full mirror export (the 14b pattern:
   per-table files, request-clean, row-count totals recorded).
2. **The deploy (you drive, announced):** execute
   `Server/supabase/09_phase14c_multitenant.sql` VERBATIM against the
   live mirror (the stored PAT arrangement, or her SQL-editor paste —
   her pick). It drops/recreates the 18 data tables EMPTY, installs the
   tenant-scoped RPCs + forced RLS + `entitlement` (seeding every
   existing auth user = her account), bumps the marker 5→6 LAST.
   Immediately after: her installed build visibly refuses to sync
   (marker mismatch) — designed, temporary.
3. **The repush (her passphrase moment):** the vault-bootstrap runner
   against her local truth — announce, she types the passphrase
   (confirm-twice zsh script), dry-run first, then the real drain
   (GM-3 pacing absorbs gateway kills; the FIXED drain-summary
   accounting now reports true totals). Proof: mirror row counts EXACT
   vs local; ZERO plaintext across the encrypted columns; owner column
   populated on every row.
4. **The phone re-onboards** (her act, the 14b road: fresh store,
   enroll by passphrase, pull-to-head over ciphertext).
5. **The `/Applications` refresh** at a verified zero-instance window
   (Release; AFTER the deploy — the lockstep-strand rule).
6. **The live probes (you drive, announced):** provision the second
   *[removed for publication]*
   (`generate_link` — it BYPASSES signups-off by recorded fact; that
   is the deliberate tool here). **UID-CHECK DISCIPLINE (the 14b
   near-miss): verify the minted session's uid is the NEW account —
   *[removed for publication]*
   `hosted_sync` entitlement via `entitlement_set` (the batch-1 hold:
   enforcement-from-birth would otherwise refuse at the tier gate, not
   the isolation boundary). Then: the stranger-sees-zero probe through
   BOTH RPCs (its pull serves zero of her rows; its push cannot touch
   hers); her side sees zero of its; **the BYPASSRLS empirical check**
   (the sitting's pinned caveat — confirm the hosted `postgres` role
   carries no BYPASSRLS so FORCE RLS binds the definer RPCs; a direct
   probe query, recorded); the vault-key-id fence probed live if cheap
   (a wrong key id refuses both halves).
7. **The domain (her Cloudflare hand + your announce):**
   `auth.stargazing.tech` (Round-8's ruling). FIRST run a Sonnet
   lookup for current Supabase custom-domain pricing/plan requirements
   and surface the cost to her BEFORE any purchase (14a's "no Pro
   purchase now" gets its honest revisit here — her call). Then: the
   dashboard custom-domain flow, her Cloudflare records (hand her
   exact values; mind the runbook's grey-cloud CNAME note), verify the
   `iss` claim + OAuth discovery under the new name, confirm old-URL
   behavior. RECORD the confirmed final URL into the contract file's
   FILL-AT-GATE field + the 14d plan's checklist.
8. **The signup flip (you drive — her Round-7 delegation — announced):**
   the "Allow new users to sign up" toggle ON. Preconditions all green
   first: probes passed, domain live, entitlement machinery live.
9. **Stranger-onboarding validation (her walk):** ARM (a) first —
   *[removed for publication]*
   built-in mailer delivers only to team addresses; ARM (a) is
   adjudicated, vetoable by her) — then her walk: in-app sign-UP as a
   fresh user (the door's real road: confirmation email received —
   she ratifies the template copy she sees — confirm, sign in), the
   empty-store first pull reading as NORMAL, the CF-5 stepped vault
   setup as a stranger, the PHONE's first-run FULL-SETUP walk (the
   PL-6 residual's safe live subject, at last). AFTERWARD: remove the
   address from the org team (the ARM (a) cleanup — on the 14d
   checklist too).
10. **The deletion-door live test:** the probe account deletes ITSELF
    through the in-app door (typed confirmation + its passphrase) —
    the natural purge verification; confirm zero residue (rows, vault,
    entitlement, auth user).
11. **THE RATIFY BUNDLE (her one look):** the sustained PROVISIONALs
    B1-1/2/3 · B2-1/2/3 · B3-1/2/3 (B3-3 FLAGGED — the
    no-in-app-Fragments-coverage-promise is a product-voice call) +
    the two lifecycle doors' copy redline (her pinned sentences are
    byte-anchored; the surrounding prose is drafted for her, one line
    each to change) + the ARM (a) decision (veto window) + anything
    the ladder/isolation round left "for her".
12. **The closeout ritual, in full** (CLAUDE.md's letter): results +
    final counts in the plan file · master plan table + pointer +
    closeout-log paragraph (the outgoing 14b closeout paragraph and
    the superseded pointer roll to `notes/PhaseCloseoutArchive.md`;
    AppSpec §14's outgoing 14b delta rolls to
    `notes/AppSpecDeltaArchive.md` and the new 14c delta is written
    EXACTLY as ruled, never beyond) · SyncSpec §12's running record
    gains the marker 5→6 event · the KnownIssues "Sync auth hardening"
    row RESOLVES (or re-owns any remainder) · every ledger row
    dispositioned · **the MOBILE PARITY LINE** (a row in
    `notes/MobileSoul.md`'s ledger, or the explicit "nothing
    mobile-visible" — note the account/tier/sign-up surfaces ride the
    SHARED seam; state what the phone got by construction) · the
    author handoff `notes/handoffs/phase-14c-handoff.md` (her
    checklist at top) · **the 14d micro-plan FINALIZED** (its
    FILL-AT-GATE checklist completed; the contract file's issuer field
    filled) · memory updated · commit + push · HARD STOP (14d at her
    word).

## State at cutover (VERIFY, never trust — the skill's rule)

- **Tip at handoff: `a27d114`** (the isolation-round fix record) — the
  build half's last commit; verify with `git log --oneline -1` and a
  clean `git status`.
- **Counts at handoff: core 1201/127 green · Mac 1240/219
  (TakePaneMeasureTests the ONE allowed red BY IDENTITY) · mobile
  175/26 · spine 51/7.** The last two fix commits touched no `Sources/`
  or `App/` code (SQL + tests only), so the Mac/mobile numbers stand
  by construction — re-run at your leisure, never at session start.
- **Ladder: CLOSED AT ROUND 2.** Round 1 = 1 MAJOR (R1-1, the re-key's
  crash windows) + 2 MINOR + 2 NIT; the fix session traced all of them
  independently (finding a THIRD crash window) and fixed all five with
  revert-verified pins; round 2's fresh reviewer judged every fix
  SOUND — independently revert-verifying the MAJOR's pin itself — and
  raised one NIT (R2-1, the rekey banner over the signed-out arm),
  FIXED at the architect's hand with copy pins. No new BLOCKER/MAJOR,
  so no round 3 was owed.
- **Dedicated isolation round: NO BLOCKER, NO MAJOR — "no standing
  cross-tenant road exists in what this phase ships."** Verified in
  detail: no injection surface, unforgeable owner stamp, all 18 pull
  arms owner-filtered by construction, both old RPC signatures dropped
  with no surviving door from 01–08, the purge cannot name another
  user, the E2EE boundary unweakened, ten fake-vs-Postgres divergences
  enumerated (none a hole). Findings: I-1 (MINOR) → **HER RATIFY
  BUNDLE** (the shared `server_seq` write-activity side channel — a
  disclosure-envelope call, hers); I-2…I-5 FIXED (executable proof for
  the foreign-owner refusal; 09 as ONE transaction + the committed
  post-deploy sweep; `sync_table_pk`'s revoke; the re-run guard) —
  **and that fix session EXECUTED 09 against a throwaway Postgres 16
  in Docker** (never the live mirror), which reproduced the re-run
  hazard, proved the guard, exercised the sweep, and established the
  artifact is syntactically valid end to end.
- **PROVISIONAL B1-1 is RETIRED-WITH-REASONS** (the fake's NULL-owner
  latitude was removed rather than the test weakened) — present it to
  her as retired, never as an open question.
- **12 LIVE-PROBE OBLIGATIONS** stand in the plan file (D1/D2 retired
  harness-side; #11 refined to "run the committed sweep — every row OK
  or INFO"; **#13 added: the re-run guard's live proof, whose ONLY
  safe window is immediately after the deploy and BEFORE her repush,
  while the rebuilt tables are empty — never later**).
- New artifact: `Server/supabase/maintenance/14c-post-deploy-grant-sweep.sql`
  (read-only; the gate runs it at step 2's close).
- The mirror is UNTOUCHED all phase (still marker 5, her 14b corpus
  live) — the deploy is the gate's step 2, nothing before it.
- 09 is AUTHORED-NOT-DEPLOYED; `SyncSchema.lockstepVersion` is already
  6 in code — which is WHY the refresh waits for the deploy.
- The bridge remains STRUCTURALLY PAUSED (provider wired nowhere —
  verified by inspection twice); resumption is 14d's.
- Her pause HOLDS; the phone's last state is 14b-era enrolled against
  the CURRENT mirror — it re-onboards at gate step 4.

## Machinery lessons (the build half's, so they cost you nothing)

- **Agent deaths at her API limits notify immediately and lose
  nothing** if records are repo-first — respawn with the same brief
  (batch 3's precedent: died pre-work, respawned clean).
- **SourceKit diagnostics flashing mid-batch are stale index noise**
  when a subsequent `swift build` is green — dismiss by build, never
  by patching.
- Implementer sessions WAIT SYNCHRONOUSLY on their builds/tests (the
  14a background-wait death class).
- The FRAMING NOTE binds every subagent brief — lead with the product
  frame or risk the 14b-class seat reroute.
- Suite-level `-only-testing` from `App/Variorum/`; the
  TakePaneMeasureTests tripwire is the ONE allowed Mac red BY
  IDENTITY; zsh `pipestatus`; never a custom build configuration.
- Reviews: fresh cold agent per round, REVIEW_PROMPT verbatim, zero
  framing; findings repo-first before any fix session sees them.

## Open author items (bundle, never improvise)

- The ratify bundle (step 11's list) — **now including I-1, the
  cross-tenant write-activity side channel** (both arms recorded in
  the isolation round's adjudication; extend the disclosure envelope,
  or slot a per-tenant sequence as its own §12 event — engine surgery,
  never a patch), and **B1-1 presented as RETIRED, not open**.
- **The AppSpec §7 `sync_state` comment delta** (the third key,
  `rekey_in_progress`) — flagged twice in the ladder records; it is a
  closeout edit, easy to miss.
*[removed for publication]*
  *[removed for publication]*
*[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
*[removed for publication]*
- Her pause's end-state at closeout (Round 1 held it through 14c).
- 14d's opening at her word.
