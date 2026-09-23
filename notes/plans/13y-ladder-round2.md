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
Disposition: PENDING the fix seat.

**R2-F2 [MINOR] · 12:696–704 (§5g) — the `exception when others` block swallows
INFRASTRUCTURE errors as proof refusals.** Only the base64 decode can legitimately fail
there; `extensions.hmac` over valid bytea fails only for infra reasons (schema
resolution/permission — exactly F-R2's class), and the catch turns that into "pick up
your keys before syncing" — an actively misleading refusal that would have made F-R2's
class and R2-F1 itself painful to diagnose live. Architectural/diagnosability; no pin
owed (needs live Postgres to demonstrate); the trace is the justification. **Fix:**
compute `expected_hex` OUTSIDE the guarded block (scope the handler to the one decode).
Disposition: PENDING the fix seat.

## ROUND-2 CLEAN BILL (the reviewer's, kept for round 3's anchor)

The cross-language contract sweep (SQL bodies whose only twins are Swift): §5f's enroll
hash · the two Vault function argument orders (Sonnet-verified against Supabase docs) ·
the quota block whole · the retry-after token vs the client parser · the successor-mac
land-together rule with the revision pre-check — ALL correct; R2-F1 is the class's one
member. The retained truncate window matches its pin verbatim; `sync_challenge`'s mint
matches its pins; records honest (the F-R3 process slip, the revert evidence, #144(c)'s
amendment).
