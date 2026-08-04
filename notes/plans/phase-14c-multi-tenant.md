# Phase 14c — Multi-tenant hardening & the paid tier — plan draft

> **Status: DRAFT, paste-ready — authored at the 14b closeout
> (2026-08-04) per the ritual. The phase OPENS WITH ITS OWN DESIGN
> SITTING (the split's caveat, her words: "some design choices will
> have to be assessed and done in that moment"). This file becomes the
> plan file when the sitting runs; the master plan's 14c row is the
> scope's letter.**

## Kickoff message (paste-ready for the sitting session)

You are the architect for Variorum Phase 14c (repo ~/dev/variorum,
branch main), under `/architect-phase` discipline (the skill file
governs; CLAUDE.md binds; cast decided at this kickoff as always). The
phase opens with the AUTHOR-ATTENDED design sitting this file stages.
READ FIRST, in order: (1) this file in full; (2) the master plan's 14c
row — the scope ledger's letter — and the 14b closeout paragraph above
it; (3) `notes/plans/phase-14b-suite-e2ee.md`'s THE DESIGN + the CF
ledger + "HER ACCEPTANCE" sections (what the vault, seam, and flows
ARE); (4) `notes/handoffs/phase-14b-handoff.md` (standing facts, never
re-derive); (5) `notes/fragments-bridge-contract.md`'s EXECUTION MODEL
+ all three touchpoints (this phase's END executes the one-batch
handoff); (6) `notes/release-and-v1-strategy.md` §1/§4; (7)
`notes/sync-postmortem-fragments.md` before ANY
`Sources/VariorumCore/Sync/` line. STANDING: the mirror is LIVE
production (announced changes only, committed artifacts, her explicit
go, the A1 rail); the signups-off toggle is THE corpus guard and flips
ONLY as this phase's own deliberate act, after isolation; her
Variorum-usage pause status is HERS — ask, never assume. Bring the
sitting questions below as question-tool batches (≤4), record rulings
verbatim-faithful same-turn, then author the execution plan from them.

**FRAMING NOTE (binding on every subagent brief — the 14b cutover's
lesson, recorded so it cannot repeat):** this phase's subject matter is
security-shaped end to end — per-user isolation, account deletion, key
rotation, credential flows. A message discussing it WITHOUT its product
frame can trip model-routing safeguards mid-phase (it moved the 14b
orchestrator seat off Fable). Mitigation: LEAD with the frame — this is
the author's own app (Variorum), the work is its multi-tenant account
system for her own users, and the rulings are recorded in this repo.
Prefer "the user's isolation boundary", "the account's deletion story"
over bare verbs.

## Scope (the master-plan row's letter + 14b's pinned contributions)

1. **Per-user isolation** of the EIGHT non-owner mirror tables inside
   the RPC bodies (parent-join checks) — retiring the single-user
   premise; the signups-off toggle remains the SOLE interim guard until
   this lands (her 0j ruling).
2. **The `setting` table's multi-user redesign** — one shared keyspace
   today; owner scoping is a §12 lockstep schema event.
3. **The signup door OPENS** (deliberately, AFTER isolation — her
   sequencing: "nobody is going to get a login before the E2EE
   surgery… well buttoned up"); in-app account creation + stranger
   onboarding (a fresh account's first pull onto an empty store); the
   14a re-decide checkpoint (vault/account home) fires BEFORE the first
   stranger account.
4. **Per-user key-vault provisioning at signup** (14b's vault machinery
   generalized beyond her account) + rotation at scale.
5. **CF-8, the user-facing re-key door** (her ruled deferral landing
   here): reset the remote copy, new key, repush — in-app, no terminal.
   **HARD CONSTRAINT (14b cold pass C-3, mechanism traced):** the
   truncate→repush window admits a stale-device poison push (empty pull
   window → reject `current: nil` → rebase-to-0 → old-key ciphertext
   accepted → every pull wedges). **The door MUST fence stale writers
   (vault-revision- or marker-class) BEFORE the truncate.** 14b ran it
   safely only because her pause left one writer. **And the JOURNAL
   side:** a re-key strands old-key `e1:` bodies in `journal_entries`
   (bridge pulls refuse until overwritten) — the door triggers the
   bridge's staged re-push from truth as part of its act (the contract's
   touchpoint #2, point 9 carries the Fragments-side half).
*[removed for publication]*
   (entitlement on the account; P-ii verified: plain `auth.uid()`
   *[removed for publication]*
   *[removed for publication]*
7. **Tier-launch operationalia:** custom SMTP (the ~2/hr built-in cap
   was hit live at 14a) · in-app ACCOUNT DELETION (App Store 5.1.1(v);
   intersects the tombstone-GC design; **`key_vault` removal lands
   here — 14b deliberately shipped NO delete policy on it**) · rate and
   abuse limits with the tier.
8. **The custom domain fronts the issuer BEFORE the one-batch Fragments
   handoff** (the standing guardrail, 0v-refined: provider configs are
   written once against the final issuer URL; verify the `iss` claim at
   attachment).
9. **THE PHASE'S END: the ONE-BATCH Fragments handoff** — all three
   contract touchpoints in one conversation (provider swap + her uid
   link + password retirement + old-issuer shutdown · journal-class
   E2EE + the bridge's resumption over ciphertext · the entitlement
   check). The bridge's pause ends here; the contract file is the brief
   she carries.

## 14b's smaller pinned contributions (owned rows, not to lose)

- **Admin `generate_link` BYPASSES signups-off** and mints users for
  unknown addresses — the 14b near-miss, twice-relevant here: it is a
  provisioning hazard AND a possible deliberate provisioning tool.
- **GM-3's gateway burst-pacing:** stranger-scale initial pushes meet
  the same rapid-fire chunk kills the live gateway showed; joins the
  pull-to-head windowing family for the at-scale design.
- **The runner's drain-summary accumulator** reports only the last
  round's accepts (cosmetic; one-line fix if the runner is touched).
- **`key_vault.updated_at` client-write** (ladder R2-1's declined
  one-liner) — a vault-generalization candidate here.
- **The PL-6 residual:** the phone's first-run FULL-SETUP visual walk
  has no safe live subject until a stranger account exists — it rides
  this phase's onboarding acceptance by nature.

## Verification (the master-plan row's letter)

Isolation tests incl. TWO-USER convergence suites (two USERS, not just
two devices — the Phase 5 harness's second axis) and a
stranger-sees-zero-of-her-rows probe through both RPCs; existing
single-user data migrates cleanly; the E2EE acceptance carries forward
(a stranger's corpus is exactly as unreadable as hers).

## Sitting questions (accumulated; the sitting rules, adds, and orders)

1. The isolation mechanism's shape: parent-join checks inside RPC
   bodies vs RLS-native rewrites — and what the two-user harness must
   prove BEFORE the door opens.
2. The `setting` owner-scoping lockstep's design (schema + repair
   rules + the migration for her existing rows).
3. CF-8's fence mechanism (vault-revision vs marker-class) and the
   door's guard rails (composes with account deletion + the tier).
*[removed for publication]*
5. The signup door's opening choreography (isolation proven → domain
   attached → door opens → the 14a re-decide checkpoint) and what
   stranger onboarding shows a first pull on an empty store.
6. Account deletion's server-side removal story (vault + mirror rows +
   auth row; the tombstone-GC intersection).
7. The one-batch handoff's scheduling and her Fragments-side calendar.
