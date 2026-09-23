# 13y LADDER — ROUND 1 (fresh `fable-reviewer`, REVIEW_PROMPT verbatim, zero framing; combined diff ff3a3f86..af5d28a5)

**Recorded repo-first 2026-09-23, BEFORE any fix session sees them (the skill's rule).**
Reviewer re-ran: AbuseGuard + KeyProofGate + MultiTenantSync + Attacker = 42/42;
AuthRLSDDL(76) + CorpusRotation(21) + SerializerCompleteness(6) = 103/103 — matching the
record. Verdict shape: **2 BLOCKER · 1 MAJOR · 3 MINOR · 1 NIT** + a clean bill covering
the phase's core (the survey premise, the DDL core, the disclosure probe, the challenge
order, the rotation successor, the quota, the horizon vehicle, grants posture, both seams,
records). Both BLOCKERs and the MAJOR converge on ONE re-ruling + one grant line; nothing
deployed needs repair.

## THE FINDINGS (verbatim-faithful; dispositions filled by the fix session + orchestrator)

**F-R1 [BLOCKER] · 12:1112–1123 + SyncScheduler.swift:230 + PurgeJanitor.swift:199/:751 —
the 10-minute re-auth on `sync_purge_execute` breaks the AUTONOMOUS purge pipeline (the
shipped 13j design).** The janitor sweeps unattended after every clean round; production
sessions live for weeks on refresh tokens; nothing on the scheduler path signs in; the
app's `verifyPassword` (AuthSession.swift:553–566) deliberately discards AND revokes the
fresh grant, so the standing session's amr never freshens. Consequence: >10 min after the
last real sign-in every horizon-eligible Delete Now family refuses
`VARIORUM_REAUTH_REQUIRED` forever — server-side physical removal (a shipped privacy
promise) silently stops, LOCAL removal (gated on the granted seq) stops with it,
`status.lastError` carries the sentence after every round, and the poison-row heal
(`healPurgeOrphan`) can't run. The suites never see it because the fake's claim DEFAULTS
FRESH (`recentPasswordAuth[userID] ?? true`) — production's steady state is modeled
nowhere. **#144(c)'s premise ("matches the doors' existing sign-in-before-acting flow
exactly") is FALSE for this door** — its main production caller is the janitor; and 13j's
decoupling (intent now, execution when the horizon passes, possibly days later) means no
interactive prompt could ever cover the execution. The challenge-verified proof already
gates the door, so the re-auth adds little. Proposed: keep 10-min on
`account_data_truncate`, REMOVE from `sync_purge_execute`; red-on-old janitor pin under a
stale claim; flip at least one janitor suite to stale-default; correct the false-premise
comments (AbuseGuardTests:134–135/:168–172, 12's re-auth bullet, memo §5, #144(c)).
→ **ORCHESTRATOR RE-RULING (below): ACCEPTED IN FULL.** Disposition: PENDING the fix
session.

**F-R2 [BLOCKER] · 12:1660–1724 (grants) with failing bodies :527–548
(`extensions.gen_random_bytes`) and :687–691 (`extensions.hmac`) — `variorum_definer` is
never granted USAGE on schema `extensions`; the challenge machinery permission-denies on
its FIRST live call after the deploy** (sync entirely refused on both refreshed devices in
her window). Zero grants naming schema `extensions` for the role anywhere in
Server/supabase; 12's two bodies are the repo's first definer-context uses of that schema
(11 used only built-in `sha256`); hosted Supabase grants `extensions` USAGE only to
postgres/anon/authenticated/service_role (Sonnet-verified against supabase/postgres
initial schema + maintainer-confirmed error class); the artifact's own PENDING-until-live
probe runs as the DEPLOYER (which holds USAGE), so the listed check would pass while the
definer road fails. Proposed: one idempotent
`grant usage on schema extensions to variorum_definer;` in section 11; extend the
grant-pin/sweep; add a `set role variorum_definer; select extensions.hmac(...); reset
role;` probe to the verification tail. Disposition: PENDING the fix session.

**F-R3 [MAJOR] · AuthSession.swift:553–566 + AbuseGuardTests:134–135/:168–172 +
FakeSyncServer.swift:632–637 — even the door that keeps its window can't be satisfied by
the current client flow:** `verifyPassword` discards and revokes the fresh grant, so a
verify-then-truncate flow would refuse once deployed. Latent only because
`truncateAccountData` has no production caller today — but the fake's default-fresh claim
and the pin comments state the false premise as fact, so the first future wiring ships
broken with green suites. The window's owed amr probe cannot save it (survives-refresh ⇒
stale for long sessions; re-dates ⇒ hollow; the sessions-table fallback equally stale).
Proposed: whatever window survives on truncate, the client flow must freshen the claim
the server reads (adopt the fresh grant's session for the one destructive call); the
fake's twin derives the claim from the SESSION used (never a settable bool defaulted
fresh); pin the flow red-on-old; correct the comments. Disposition: PENDING the fix
session.

**F-R4 [MINOR] · 12:1743–1746 —** the verification tail's two fold-in checks cast the OLD
`key_vault_update(jsonb, int, text)` spelling section 0 drops; post-deploy the cast itself
errors, tripping the window at exactly the two lines proving the guard fold-in and M3.
UNIT B widened the signature and extended the tail but left these UNIT A-era lines. Fix:
update both casts (verification-doc class, no pin owed). Disposition: **AGREE — FIXED
(fix session).** Both verification-tail casts at 12:1743/1745 updated to the four-parameter
`key_vault_update(jsonb, int, text, text)` spelling UNIT B's signature carries (12:1372).
Verification-doc class, no pin owed.

**F-R5 [MINOR] · KeyProof.swift:16–24 —** the type-level doc teaches two retired
contracts (the NULL-hash first-proof arm, retired by 12 §5f; kp1 as "the `key_proof` BODY
parameter of every mutating RPC," superseded by the per-request bound HMAC). Two-sentence
doc correction. Disposition: **AGREE — FIXED (fix session).** `KeyProof.swift`'s type doc
corrected: the v1 wire token is now named the ENROLLMENT authorization (kp1) — SUPERSEDED as
the per-request proof by kp2's challenge-bound HMAC (pointing at `KeyProofMaterial`/
`SyncKeyProof`) — and the NULL-hash-first-proof migration-arm sentence is struck (retired by
12 §5f). Doc class, no pin owed.

**F-R6 [MINOR] · the challenge memo §7 —** the edge list omits the PRE-ENROLLMENT GAP:
between the marker-9 deploy and an account's first round, `key_proof_enroll` is authorized
by the v1 static value, so the historical-capture class this phase closes retains mutating
power (including enrolling a foreign kp2 — a lockout-from-the-mutating-plane recoverable
by delete-and-set-up-again) for exactly that gap. Inherent to any shared-secret upgrade;
the real mitigation is the window choreography (her first round runs inside the window;
new accounts have no v1 history). Record as memo §7's ninth edge + one disclosure line at
closeout. → **DONE by the orchestrator (the memo edit is the orchestrator's own record),
same commit as this file.** Disposition: RESOLVED — record-only.

**F-R7 [NIT] · KeyProofChallenge.swift:51–77 —** the signer's two recovery roads
(stale-retry, enroll-retry) don't compose; a crossing surfaces instead of running the
other road once. Bounded, self-heals next round under the §12 grammar; arguably the
"retry ONCE" letter. Record the choice at the code or compose — the fix session's call
with a trace. Disposition: **RECORD-AT-THE-CODE (fix session).** Traced: the server's
`sync_key_proof_check` (12 §5g) refuses ENROLL *before* consuming any nonce, so an
un-enrolled account always refuses ENROLL (never STALE) and an enrolled account never
refuses ENROLL — the two recovery roads are MUTUALLY EXCLUSIVE within one round by the
server's own order, and the crossing the finding describes is unreachable in practice; the
one residual (the stash going stale during the sub-ms enroll hop) self-heals next round.
A doc paragraph now records this at `KeyProofChallenge.swift`'s `SyncChallengeSigner` (the
retry-once is correct; composing would add a retry loop for an impossible case). Clarity
class, mechanism traced, no pin owed (the hallucination guard's architectural-finding path).

## THE ORCHESTRATOR'S RE-RULING (2026-09-23, under R-13y-4 — amending its OWN #144(c); the accountability stated plainly)

**F-R1 is accepted IN FULL, and its root is the orchestrator's design error:** the memo's
§5 listed both destructive RPCs for the re-auth window on the strength of the
sign-in-before-acting flow WITHOUT tracing `sync_purge_execute`'s actual production
caller — the janitor, which by 13j's own design executes intents autonomously, possibly
days after any human act. The ladder caught the architect. **The re-ruling: the 10-minute
re-auth window applies to `account_data_truncate` ONLY. `sync_purge_execute` carries NO
re-auth claim check — its walls are the challenge-verified key proof + the session + the
own-partition guard, which is what actually gates a stolen long-lived token there.**
#144(c) carries the dated amendment; memo §5 corrected the same way (dated, never
silent). F-R3's design rider, ruled with it: the truncate flow ADOPTS the fresh grant's
session for the one destructive call (that is what makes the server-readable claim
genuinely fresh — a NEW session with a NEW amr), and the fake models the session, never a
defaulted bool. The window's amr probe narrows to confirming the adopted-session shape
serves a fresh timestamp via `auth.jwt()`.
