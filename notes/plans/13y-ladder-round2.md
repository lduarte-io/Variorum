# 13y LADDER — ROUND 2 (fresh `fable-reviewer` over the round-1 fixes + what they touched; diff af5d28a5..c7dbaf0d; anchor `13y-ladder-round1.md`)

**Recorded repo-first 2026-09-23, BEFORE the fix seat sees them.** Verdict shape:
**1 BLOCKER (NEW) · 0 MAJOR · 1 MINOR · 0 NIT.** All seven round-1 dispositions VERIFIED
sound (the F-R1 no-re-auth purge body end-to-end; the F-R2 arbitration's facts confirmed
in-repo — :72 default INHERIT, :89 membership, the executable set-role probe; F-R3's adopt
road with revoke-on-both-paths and the no-default fake; F-R4/5/6/7 each re-checked).
Reviewer re-ran 143 tests across 6 suites green, arithmetic exact. Per the ladder rules —
**a NEW round-2 BLOCKER ⇒ its fixes get ROUND 3** (a full pass focused on those fixes).

## THE FINDINGS

**R2-F1 [BLOCKER] · 12:697–701 (§5g `sync_key_proof_check`) — pgcrypto's `hmac(data, key,
type)` arguments are SWAPPED: the body passes `decode(stored_mac,'base64')` (kp2, the KEY
under the ruled contract) as DATA and the message (`presented_nonce ||
convert_to(':' || rpc_name, 'utf8')`) as KEY, computing HMAC_{msg}(kp2) where the client
(KeyProof.swift:128–132, exactly the memo §3 contract) computes HMAC_{kp2}(msg).**
HMAC(k,m) ≠ HMAC(m,k) always, so on the REAL mirror every per-request proof refuses
`VARIORUM_KEY_PROOF_REQUIRED` — the whole mutating+read plane down on both devices from
the first post-enrollment call at her window. Enrollment itself succeeds (§5f is plain
sha256), so the failure lands precisely at Step 6's acceptance evidence. **Why every
suite is green:** the fake and the app emulators compute the expected proof with the
client's OWN `KeyProofMaterial.proof` — client and fakes agree by construction and can
never see a SQL argument-order error; the ruled-order DDL pin asserts the call's presence,
position and binding STRING but not which argument is data vs key; the F-R2 set-role
probes verify only that `extensions.hmac` RESOLVES. Nothing deployed is broken (row 13
open) — this is the pre-deploy ladder doing its job. **Red-on-old (the DDL-text idiom —
server SQL cannot execute in the suite):** extend the ruled-order pin with an
ARGUMENT-ORDER arm — first argument of `extensions.hmac(` must be the message expression,
second `decode(stored_mac, 'base64')`; RED on the current body, green after the swap.
**Fix:** swap the two arguments; add the pin arm; client, fakes, memo and every other pin
stay byte-unchanged (they implement the ruled contract — the DDL alone drifted).
Disposition: **AGREE — FIXED (fix seat, round 2).** Traced myself: pgcrypto's signature is
`hmac(data bytea, key bytea, type text)` — message first, key second (the repo's own F-R2
window probe names them `('probe'::bytea, 'key'::bytea)` in that order); the client contract
(`KeyProofMaterial.proof` — `HMAC<SHA256>.authenticationCode(for: input, using: kp2)`, memo
§3's letter) computes HMAC_kp2(nonce‖':'‖rpc); the pre-fix body passed kp2 as arg1=data and
the message as arg2=key → HMAC_msg(kp2), and HMAC is asymmetric in (key, message) by
construction (the key enters the ipad/opad schedule), so the mirror would refuse every
honest per-request proof. The two arguments SWAPPED (12 §5g, with the mechanism commented
at the line + the section header amended); THE ARGUMENT-ORDER ARM added to
`theProofCheckConsumesTheNonceInTheRuledOrderAndTheMigrationArmRetires` (within the body,
`extensions.hmac(` < the message expression ≤ `decode(stored_mac, 'base64')` — the message
is the data, kp2 the key). **RED-ON-OLD VERIFIED by behavioral revert (fix committed
FIRST, the round-1 lesson applied):** with the two arguments swapped back on a dirty tree,
the arm failed exactly — `AuthRLSDDLTests.swift:2578 Expectation failed:
(hmac.lowerBound < message.lowerBound → true) && (message.upperBound <= macKey.lowerBound
→ false)` — restored via `git checkout --` (to the COMMITTED fix), green. Client/fakes/memo byte-unchanged.

**R2-F2 [MINOR] · 12:696–704 (§5g) — the `exception when others` block swallows
INFRASTRUCTURE errors as proof refusals.** Only the base64 decode can legitimately fail
there; `extensions.hmac` over valid bytea fails only for infra reasons (schema
resolution/permission — exactly F-R2's class), and the catch turns that into "pick up
your keys before syncing" — an actively misleading refusal that would have made F-R2's
class and R2-F1 itself painful to diagnose live. Architectural/diagnosability; no pin
owed (needs live Postgres to demonstrate); the trace is the justification. **Fix:**
compute `expected_hex` OUTSIDE the guarded block (scope the handler to the one decode).
Disposition: **AGREE — FIXED (fix seat, round 2).** Traced: the `when others` wrapped THREE
failable expressions, of which only `decode(key_proof, 'base64')` can fail on legitimate
client input — `decode(stored_mac, …)` fails only on stored corruption (enrollment landed
it) and `extensions.hmac` only on schema-resolution/permission infrastructure (F-R2's exact
class) — and the catch converted all three into the "pick up your keys" proof refusal.
`expected_hex` now computes OUTSIDE the handler (an infra fault RAISES as itself); the
handler scopes to the one client-failable decode, so a malformed proof still refuses as a
proof fault, never a raw decode error. The ruled-order pin's arms all hold unchanged
(verified: AuthRLSDDLTests 76/76). No pin owed (needs live Postgres — the reviewer's call,
kept); the mechanism is commented at the line.

## FIX SEAT CLOSE (2026-09-23 — round 2's fixes, for round 3's anchor)

Both findings AGREE/FIXED in ONE surgical commit (`12_phase13y_tenant_seq.sql` §5g +
`AuthRLSDDLTests`' ruled-order pin + this file). R2-F1's red-on-old verified by behavioral
revert against the COMMITTED fix (evidence quoted in its disposition). Suites at close:
**AuthRLSDDLTests 76/76 · FULL CORE 1722 tests / 180 suites — ALL PASSED** (+0 over the
round-1 close, as expected — the argument-order arm extends an existing pin). Client, fakes,
memo, and every other pin byte-unchanged; zero mirror contact.

## ROUND-2 CLEAN BILL (the reviewer's, kept for round 3's anchor)

The cross-language contract sweep (SQL bodies whose only twins are Swift): §5f's enroll
hash · the two Vault function argument orders (Sonnet-verified against Supabase docs) ·
the quota block whole · the retry-after token vs the client parser · the successor-mac
land-together rule with the revision pre-check — ALL correct; R2-F1 is the class's one
member. The retained truncate window matches its pin verbatim; `sync_challenge`'s mint
matches its pins; records honest (the F-R3 process slip, the revert evidence, #144(c)'s
amendment).
