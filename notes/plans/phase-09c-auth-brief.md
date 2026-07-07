# Phase 9c — Auth alignment (Phase 14's auth core, pulled forward) — DESIGN BRIEF

> **This is a BRIEF, not the execution plan.** Written 2026-07-07 (mid-Phase-9, author +
> coordinator — the sync/key conversation; QUESTIONS #9 is the decision record). Per the
> front-loaded-planning rule the just-in-time plan is written at **Phase 9b's closeout** and
> MUST incorporate it (9c's closeout then authors the Phase 10 plan from its brief — the
> chain gains one link). Ratified decisions below are binding; open interpretations are the
> plan's to answer.

## Why this phase exists (the fact that forced it)

Fragments hardcodes a genuinely publishable key because real user auth + RLS stand behind
it — the key identifies the project and grants nothing. Variorum's mirror is deliberately
auth-less for the personal phase (SyncSpec §2 single-user token; the `02_sync_rpc.sql`
SECURITY NOTE: SECURITY DEFINER RPCs, no per-user check) — so **any key the app holds is a
full read/write bearer token to the journal corpus**. That is why Phase 8 shipped the
Keychain paste-in instead of hardcoding, and why the two apps cannot converge by mechanism
swap: they converge only when Variorum gains auth. The author declined to build in-between
mechanisms (the iCloud-Keychain tweak) and pulled the auth core forward instead.

## Author-ratified decisions (2026-07-07 — not reopenable)

1. **Scope = Phase 14's auth core only:** Supabase Auth sign-in in both app targets;
   `owner_id` population (backfill) + stamping on new top-level rows **through Operations**
   (S4 was designed for exactly this — nullable since schema v1); RLS + RPC rework on the
   mirror so the endpoints enforce the user (SyncSpec §12 lockstep choreography, author
   SQL-editor paste); session/token refresh in the transport (sync-engine surgery —
   Fable-only under the standing rider); **the Phase 8 paste-in retires into the sign-in
   screen** (QUESTIONS #3 superseded). After this phase the API key demotes to a genuinely
   publishable key and may be treated as non-secret.
2. **Identity goal: ONE account — the author's Fragments account IS her Variorum account.**
   Two separate accounts rejected ("I don't see the point"). The mechanism is the plan's to
   resolve (below), but the outcome is fixed: she signs in once with her Fragments identity
   and both backends recognize her.
3. **What stays at Phase 14:** multi-tenant/commercial hardening, account provisioning for
   non-author users, the server-privacy/E2EE decision (plaintext rows stay ratified
   meanwhile), the variorum-edition export. 14's brief/sketch should be reconciled when its
   plan is eventually written.
4. **Sequencing: after 9b.** The bridge is independent of the mirror's auth (it
   authenticates to Fragments' backend; its user-auth session is the contract's final
   shape, not scaffolding) and gets the author journaling in Fragments soonest. 9b's
   session machinery is expected to be reused/generalized here — build it once, coherently.

## Open interpretations the execution plan must answer

1. **The trust mechanism** — how Variorum's project honors the Fragments identity:
   - *(i) Issuer trust:* Variorum's Supabase project accepts Fragments' project as a
     third-party JWT issuer (JWKS/OIDC-style trust). Cleanest separation; **verify current
     Supabase support at plan time** (one Sonnet lookup — capabilities in this area move
     fast; do not design from memory).
   - *(ii) Shared JWT secret* across the two projects (HS256): works on any Supabase
     vintage; cost = coupled compromise blast radius (a leaked secret opens both projects)
     and coupled rotation.
   - *(iii) One merged Supabase project* hosting both apps' schemas: rejected-leaning —
     couples deployments and migration lockstep across two products and strains the
     hands-off-Fragments boundary (this repo's agents never touch Fragments; sharing a
     backend invites entanglement). Revisit only if (i) and (ii) both fail.
2. **The `owner_id` value's stability:** whatever the mechanism, `owner_id` gets keyed to a
   user id (JWT `sub`). The commercial future must remain addable (Variorum-native accounts
   at 14 for non-author users, alongside the Fragments-trusted identity) **without
   re-keying her existing rows** — pick the id namespace accordingly and record the
   reasoning.
3. **Backfill choreography:** existing rows carry NULL `owner_id` on both the mirror and
   both devices. Order the backfill + RLS enablement so no client is ever locked out of
   its own rows mid-transition (SyncSpec §12: refusal, never guessing; sync stalling is
   free, corruption is not).
4. **Signed-out/expired behavior:** sync refuses cleanly — outbox intact, cursor unmoved,
   a visible status line (the SyncScheduler already has the offline posture to reuse);
   token refresh happens in the transport seam, and a 401 mid-round must not wedge the
   drain.
5. **What the fake server models:** the correctness harness models CAS + seq, not auth —
   keep the convergence suites auth-agnostic; auth enforcement is verified by the
   env-gated integration pass against real Supabase (author-assist gate, same flow as
   Phase 5's and A5's).

## Verification sketch

Both devices sync under the new auth end-to-end; the bare publishable key alone is refused
by the mirror (verified against the real project, not the narrative); expired session →
refresh → the round completes; signed out → refusal with outbox/cursor intact; the
Fragments account signs into Variorum (the one-account goal demonstrated); existing corpus
rows all owned and readable after backfill (dump-compare before/after); paste-in fully
gone — no dead credential path left in either target.

## Risks

- **This transitions the author's LIVE daily-drive sync.** The A1 rotating backups exist
  and the SQLite files are truth — take a manual backup before the server-side cutover
  anyway. Lockstep to the letter; a half-migrated state must refuse, never guess.
- **RLS mistakes can lock her out of her own corpus** (worst case: sync stalls — data
  stays safe locally). The integration pass, not the fake server, is the proof.
- **Token refresh is new transport machinery** in Fable-only territory; any change not
  covered by a convergence or integration test is unreviewed (AppSpec §15 risk 3).
- **Do not front-run Phase 14's E2EE decision** — this phase changes who may call the
  endpoints, never what the server stores.

## Review foci (for the cold reviewer — written at brief time, no implementation exists)

1. Zero new row-writing paths; `owner_id` stamping flows through Operations only.
2. The key is truly demoted: nothing in the repo or the app treats it as a secret anymore,
   AND the mirror refuses bare-key access — verify against the deployed project.
3. Session/refresh machinery covered by tests (including 401-mid-round); the scheduler's
   offline posture reused, not duplicated.
4. The paste-in is fully retired (no dead Keychain code paths, no orphaned setup door).
5. The lockstep choreography followed and recorded step-by-step (§12's first auth-shaped
   exercise); backfill provably total (no NULL `owner_id` live rows after).
6. The one-account mechanism matches what the plan's verified-capabilities lookup found —
   flag any drift between the recorded rationale and the shipped trust configuration.
