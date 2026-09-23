# 13y UNIT B DESIGN MEMO — the key-proof challenge + the minimal abuse guard's numbers

**Status: RULED by the orchestrator under the architect mandate, 2026-09-22 — PROVISIONAL
per her kickoff answer R-13y-4 (PROVISIONAL-and-continue), logged at `notes/QUESTIONS.md`
#144, named at the deploy window's pre-deploy summary, ratified at the checkpoint.** A P-5
design memo: the intended behavior whole, the edges enumerated on paper, the refusal
vocabulary named. UNIT B builds TO this memo; a newfound technical constraint returns here
for a re-ruling, never a silent divergence. External facts are from the kickoff's Sonnet
lookup (two rounds, 2026-09-22; quotes and URLs in the session record — the load-bearing
ones restated inline below with their sources).

---

## 1. The problem (pre-13x CONSIDERATIONS item 1; stress pass Q1)

Today's proof is a STATIC bearer secret: `kp = HMAC-SHA256(M, "variorum.key-proof.v1")`,
byte-identical on every request, in every RPC body; the server durably stores only
`SHA-256(kp)` and compares in constant time (`sync_key_proof_check`,
`11_pre13x_postures.sql:257–310`). The stress pass verified the durable data plane holds
only the hash — so backups/WAL/replicas yield nothing — but anything operator-side that
retains request BODIES (body logging at the API edge, Postgres statement/parameter logging)
holds the value, and the value is mutating access forever: push, truncate, purge, and a
vault rewrite into a lockout. Integrity/availability, never confidentiality — but forever.

## 2. The fact base that narrows the design (verified, not assumed)

- **Asymmetric verification in-database is NOT a durable road.** pgsodium is "pending
  deprecation" and Supabase says not to build on it ("Supabase does not recommend the usage
  of pgsodium as it will be deprecated" — supabase.com/docs/guides/database/extensions/pgsodium);
  `crypto_sign_verify_detached`'s presence on the hosted build is unverified; pgcrypto has
  NO asymmetric verify ("No support for signing" — postgresql.org/docs/current/pgcrypto.html);
  plv8 is deprecated for PG17; pg_tle would mean hand-rolling curve math. Supabase's own
  steer for signature verification is Edge Functions — OUTSIDE Postgres, which would move
  the gate out of the RPCs' own transactions. Rejected: the gate must stay where the lock
  discipline lives.
- **pgcrypto `hmac(bytea, bytea, 'sha256')` is available and suitable** in a SECURITY
  DEFINER function (Supabase's own community guidance uses exactly this shape).
- **Supabase Vault holds a secret OUT of backups**: "the encryption key is never stored in
  the database alongside the encrypted data … Even if an attacker can capture a dump of
  your entire database, they will see only encrypted data, never the encryption key itself"
  (supabase.com/docs/guides/database/vault). Vault is the designated pgsodium successor
  (not deprecated with it), PG17-compatible. Caveats recorded: the root key IS retrievable
  by the project's Management API (control-plane compromise is a different attacker — §6);
  the definer-role grant pattern is community-converged rather than an official step-by-step
  (GRANT USAGE on schema vault + SELECT on `vault.decrypted_secrets`, and the REAL footgun:
  Postgres grants EXECUTE to PUBLIC on new functions — every new function gets the explicit
  REVOKE/GRANT pair, pinned by the sweep); Vault is pitched for a MODEST number of secrets
  ("good for a reasonable amount of secure data, like API keys" — the announcement post),
  which fits one small value per account at launch scale; §7 records the re-shape trigger.

## 3. THE RULED SHAPE — a server-issued single-use challenge over a Vault-held MAC secret

**The secret.** A NEW value `kp2 = HMAC-SHA256(M, "variorum.key-proof.v2")` becomes the MAC
key. Deliberately NOT the v1 value: every hypothetical captured log of the v1 era holds a
value the new protocol never accepts. kp2, like kp, reveals nothing about M.

**Server custody.** kp2 lives in Supabase Vault (`vault.create_secret`, unique name
`kp:<owner uuid>`), read ONLY inside the gate's SECURITY DEFINER verify via
`vault.decrypted_secrets` — never returned, never logged, never in an error. Backups stay
useless (the confirmed Vault property). `key_vault.key_proof_hash` becomes `SHA-256(kp2)`
after enrollment and keeps its roles: the fence-adjacent integrity record and the
constant-time compare target for enrollment.

**The challenge.** A new session-gated RPC `sync_challenge(n int)` (cap n ≤ 32) mints n
random nonces (`gen_random_bytes`), stores `(owner_id, nonce, issued_at)` in a small
`key_proof_challenge` table, deletes that owner's expired rows in the same call, and
enforces ≤ 64 live nonces per owner (oldest evicted). TTL: **5 minutes, server clock only**
(`issued_at` stamped and compared server-side — zero client-clock trust, §9 honored).

**The proof, per request.** Every gated RPC's `key_proof` parameter becomes
`base64( HMAC-SHA256(kp2, nonce || ":" || rpc_name) )` and a `challenge` parameter carries
the nonce. The verify: DELETE the nonce row atomically (`… RETURNING` — single-use by
construction), check TTL, recompute the HMAC from the Vault-held kp2, compare via the
existing 64-hex constant-time XOR loop. Binding `rpc_name` costs nothing and stops
cross-RPC splicing of a not-yet-consumed pair; the request BODY is deliberately NOT bound
(TLS carries transit integrity; log capture sees only consumed nonces; jsonb
canonicalization is a bug farm — recorded as the reason).

**The gate order is unchanged:** lock choice → the `active_key_id` fence → the proof
(now challenge-verified). The engine fetches a batch of nonces once per round
(`sync_challenge(8)`), consumes one per RPC call; the rotation walk fetches fresh batches
as it goes. An unknown/expired/reused nonce refuses typed
(`VARIORUM_KEY_PROOF_STALE_CHALLENGE`); the client fetches fresh and retries ONCE, then
surfaces the standing §12 refusal grammar (outbox intact, cursor unmoved).

**Enrollment (the migration arm — ONE road for her existing vault AND every new account).**
The gate, finding NO Vault secret for the account, refuses typed
(`VARIORUM_KEY_PROOF_ENROLL`). The client calls `key_proof_enroll(kp1, kp2, active_key_id)`:
the server verifies `SHA-256(kp1)` against the stored hash (constant-time; the existing
hash authorizes the enrollment of the successor), then `vault.create_secret(kp2)` + updates
`key_proof_hash = SHA-256(kp2)`, one transaction, FOR UPDATE on the vault row. Fires once
per account; a second call refuses (`VARIORUM_KEY_PROOF_ALREADY_ENROLLED`). New accounts:
vault creation (the session-only insert, hash set at birth per the standing trigger) then
the same enrollment on the first round. The NULL-hash first-proof arm (hers, spent) retires
with the static road.

**Rotation.** kp2 derives from M, so Replace All Keys / entering Castle mints kp2′.
`key_vault_update`'s payload gains the new kp2′ VALUE beside the new hash; the server —
under the CURRENT challenge-verified proof, FOR UPDATE — runs `vault.update_secret` and
lands hash + secret together. The follow devices recompute kp2′ from M′ locally; nothing
else changes.

**Honest residue, stated:** kp values still transit the body at ENROLLMENT (once per
account) and ROTATION (per rotation) — the shared-secret scheme's floor; only asymmetric
crypto removes it, and §2 rules that road out in-database. The transit narrows from EVERY
REQUEST to those rare events, over TLS, and the v2 mint makes historical captures worthless.

**The fake server mirrors ALL of it** — nonce mint/TTL/single-use/eviction, enrollment,
rotation, the HMAC verify — and the suites pin: a captured (nonce, proof) pair REPLAYED
refuses; an expired nonce refuses; the retry-once road recovers; enrollment is once;
rotation swaps the secret atomically; the `sync_reencrypt` tenth-arm pin re-verifies under
the challenge protocol.

## 4. THE ABUSE GUARD'S NUMBERS (Step 4 — ruled here; the mechanism table shape is the implementer's proposal against these targets)

Her constraint, verbatim (2026-09-21): *"I do need to account for onetime migrations from
existing notes app but in general I don't want it abused."*

- **The lifetime first-load pool: 500,000 accepted row-writes per account before any daily
  limit applies.** Calibration: her full-corpus repush at 14c was 7,278 rows (×69 headroom);
  a 10,000-note Apple-Notes import lands ~50–100k rows (×5–10). An honest import can never
  meet the guard.
- **The steady-state rate: 50,000 accepted row-writes per rolling 24 h per account** once
  the pool is spent. A heavy human writing day measures in low thousands of coalesced rows
  (the outbox dedupes keystrokes by design); this is ×10+ headroom.
- **Per-call batch cap:** set from the measured shipped chunk size (`batchSize` in the
  transport) × 10 — a bound on malformed clients, never a limit an honest client meets.
- **Exemptions, each with its reason:** `sync_reencrypt` is EXEMPT (a rotation rewrites the
  whole corpus by design; it is already proof- and entitlement-gated, and a quota here would
  break Replace All Keys at exactly the corpus sizes that matter); `account_data_truncate`
  RESETS the lifetime pool (delete-and-set-up-again's repush IS a first load — the adopt
  road must converge, the Step 2 pin); `sync_purge_execute` takes no quota (it removes the
  owner's own rows and is separately gated).
- **The refusal:** typed `VARIORUM_WRITE_QUOTA` with a retry-after; the client surfaces the
  §12 grammar — outbox intact, cursor unmoved, a visible honest status ("sync is paused —
  this account hit today's write limit; nothing is lost, it resumes automatically"; 13s
  re-words). Pins: an over-quota push refuses cleanly and recovers when the window passes;
  the import-burst shape passes untouched; normal-use suites never meet the guard.
- 13t revisits every number with pricing (NON-GOALS' standing line).

## 5. THE RE-AUTH DOORS (Step 4b — ruled)

- **The recent-re-auth window for the destructive RPCs (`account_data_truncate`,
  `sync_purge_execute`): 10 minutes.** The check reads `auth.jwt() -> 'amr'` (confirmed:
  per-method `timestamp` fields, reachable in SQL) for the newest `password` entry inside
  the window; absent or stale refuses typed (`VARIORUM_REAUTH_REQUIRED`). This matches the
  client flow exactly — the doors already verify the account password through a sign-in
  call immediately before acting (pre-13x §18-I), and a fresh sign-in mints a fresh session
  with a fresh `amr`. The fake's twin enforces the same logic on synthetic claims.
  **One empirical probe at the deploy window (the lookup flagged refresh-survival as
  architecturally supported, not doc-guaranteed):** decode her session's JWT before and
  after a token refresh and confirm the `amr` password timestamp is byte-identical — if it
  BUMPS on refresh, the guard is hollow and the fallback (a definer read of
  `auth.sessions.created_at` for the JWT's `session_id`) comes back here for a re-ruling
  before the window closes.
- **The auth rate limits, stated as facts (the ADDENDUM's "state the numbers"):** the token
  endpoint (password sign-in) defaults to **150 requests / 5 minutes per IP, bursts to 30,
  configurable** (supabase.com/docs/guides/auth/rate-limits). Recorded caveats, honestly:
  the limit is IP-scoped (a distributed brute-force is not capped per account) and the
  tracker holds under-enforcement reports — so these limits are a stated fact and a speed
  bump, NEVER the wall; the walls are the password itself, the proof, and the E2EE design
  (the account password alone sees nothing — §3.10's consequence). The app's refusal
  wording on a 429: "too many attempts — wait a few minutes and try again." Pin: a burst of
  wrong passwords in the fake refuses; the wording pin on the client.

## 6. THE TRADE TABLE (what each attacker class gets, before → after)

| Attacker | Before (static bearer) | After (this memo) |
|---|---|---|
| Transit/body-log capture | kp forever ⇒ mutating access forever | a consumed single-use nonce + a bound HMAC ⇒ nothing (except the rare enroll/rotation bodies — §3's stated residue) |
| Stolen Postgres backup / WAL / replica | hash only ⇒ nothing | Vault ciphertext + hash ⇒ nothing (confirmed property) |
| Live DB read (operator) | hash only ⇒ nothing NEW (can already write tables directly) | kp2 via Vault ⇒ mutating API access — but this attacker already mutates directly; net-new power ≈ none, recorded |
| Control-plane compromise (Management API root key) | nothing beyond the above | kp2 recoverable ⇒ mutating access — NEW surface, narrow, integrity-only; recorded in the disclosure envelope |
| Stolen long-lived session token | mutating destructive RPCs | destructive RPCs refuse without a ≤10-min password re-auth (§5) |

## 7. Edges, enumerated

1. **Two devices racing enrollment:** the FOR UPDATE on the vault row serializes; the loser
   re-reads, finds the secret enrolled, proceeds under challenges (its kp2 is the same —
   both derive from M).
2. **A round outliving its nonces** (a slow rotation walk, a laptop sleeping mid-round):
   the stale-challenge refusal + fetch-fresh-retry-once per call; the round never wedges.
3. **Nonce-table growth:** per-owner cap 64 + expired-row deletion at every mint; the table
   is bounded by 64 × live accounts.
4. **Vault scale (the lookup's caveat):** one ~44-byte secret per account is far inside
   "a reasonable amount"; IF accounts ever reach the volume where Supabase's own steer says
   move off `vault.secrets`, that is a §12-event re-shape owned by the accounts-at-scale
   phase (13t's orbit) — recorded here so it is a decision, not a discovery.
5. **Statement/parameter logging server-side** could capture enroll/rotation bodies exactly
   as it could capture every body today — narrowed, not eliminated; the deploy window's
   record states the project's logging posture as found.
6. **The disclosure envelope moves** (the privacy brief's list): the server now holds a
   Vault-wrapped MAC secret per account, root key with Supabase — one line added at
   closeout beside the I-1 amendment; the "hash only" sentence in §3.10 is re-based.
7. **`sync_challenge` DoS:** session-gated, capped, self-GCing; a sessionless caller gets
   nothing; a session-holder can at worst churn its own 64 rows.
8. **The A5 horizon exposure rides the same DDL** (Step 1) and is orthogonal — no
   interaction with the challenge beyond sharing the artifact.

## 8. What UNIT B proposes vs. builds

Built TO this memo: the DDL halves (challenge table, `sync_challenge`, `key_proof_enroll`,
the reworked `sync_key_proof_check`/`sync_key_gate`, the quota checks, the re-auth checks,
the Vault grants with the PUBLIC-execute revokes), the client halves (`SyncEncryption`'s v2
derivation + challenge fetch/consume, the enroll/rotation roads, the refusal surfacing),
the fake's twins, the pins named in §3–§5. PROPOSED back for adjudication before building:
the quota mechanism's table shape (against §4's targets), and anything this memo's shape
meets in the code that argues differently — repo-first, then built.
