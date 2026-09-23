# 13y LADDER — ROUND 3 (the cap; fresh `fable-reviewer`, full pass focused on the round-2 fixes; diff c7dbaf0d..9b642c8f)

**Recorded repo-first 2026-09-23.** Verdict: **0 BLOCKER · 0 MAJOR · 2 MINOR · 0 NIT —
both round-2 fixes CONFIRMED CORRECT** (the hmac contract traced byte-for-byte client ↔
server, the argument-order arm verified as a genuine red-on-old witness operating on
comment-stripped SQL, the rescoped handler complete with a same-class sweep of every
remaining `exception when others` in 12 finding no residue, exactly ONE executable
`extensions.hmac(` in the whole server tree). Round-1 dispositions undisturbed; suites
re-run by the reviewer green (76/76 + 31/31). **THE LADDER CLOSES AT THE CAP.** Per the
rules, post-cap findings are RECORDED, never looped — the adjudication below fixes both
WITHOUT a fourth review round, with the reasons stated.

## THE FINDINGS

**R3-F1 [MINOR] · FakeSyncServer.swift:509–535 + KeyProofGateTests.swift:766–787 + 12
§5g/§5h comments — a refused proof check burns the nonce in the FAKE but ROLLS BACK on
the deployed mirror; the splice pin's second arm asserts deployed behavior the real
server will not exhibit** (R2-F1's fake-agrees-with-itself class, same function). On the
mirror the HMAC-mismatch RAISE aborts the RPC's transaction and the consume's DELETE
un-happens — the nonce survives any refused attempt; the fake removes it from the stash
before the TTL/HMAC checks and keeps it removed on refusal. Concrete divergence: a
spliced pair refuses on the wrong door on both sides, but then LANDS on its own door on
the real mirror while the pin asserts `keyProofChallengeStale`. Impact bounded (NO
attacker capability changes — one spend on the own door was always available; the splice
detour gains nothing; replay-after-landing refuses identically; the shipped client never
re-spends) — the defect is a PINNED FALSE CLAIM about deployed truth. Fix: transactional
semantics in the fake (consume only on whole-check success), the pin's second arm
re-worded to deployed truth, the two comments corrected. Red-on-old exists (the re-worded
arm fails on the current fake). Disposition: **AGREE — FIXED (fix seat, post-cap).** Traced:
the fake removed the nonce at `checkProof`'s stash-lookup, BEFORE the TTL and HMAC checks —
on the mirror the refusing RAISE aborts the RPC transaction and the consume's DELETE rolls
back, so the nonce survives every refused attempt and is spent exactly once, by its one
successful use. Fix: `FakeSyncServer.checkProof` consumes ONLY when the whole check succeeds
(the actor's synchronous method makes check-then-remove-on-success equivalent to
DELETE…RETURNING + rollback-on-raise; the rollback semantics commented at both refusal
sites); the splice pin renamed+re-worded to deployed truth —
`aProofBoundToOneDoorRefusesOnAnotherAndTheSpliceGainsNothing`: the refused splice rolls
back, the pair lands ONCE on its own door (the one spend it always had — the detour gains
nothing), and is spent BY that landing (replay refuses); the three "single-use by
construction" comments in 12 (top header · §5b · §5g) corrected to single-use PER SUCCESS
with refusals rolling back. **Ripple re-derived pin-by-pin against transactional truth:**
the replay pin (success still consumes — unchanged, deployed-true) · the TTL pin (the
expired nonce now SURVIVES the refusal, exactly as the real row lingers till the mint's GC;
the pin never asserted its burn — green and now more faithful) · the signer's stale-retry
pin (drives the CLIENT stash; server-side survivors are expired and can never pass — green)
· the fresh-account/together-rule pins (enroll road, no nonce-burn claims) — no other pin
assumed burn-on-refusal. **RED-ON-OLD VERIFIED by behavioral revert against the COMMITTED
fix** (evidence below in this file's FIX SEAT CLOSE). **One residual RECORDED, not built
(beyond the adjudicated scope):** on the real mirror a RAISE anywhere LATER in the same RPC
(the quota refusal, the entitlement gate, an owner-stamp RAISE) also rolls the consume back,
while the fake burns the nonce once the CHECK succeeds — unpinned (no test asserts nonce
fate after a post-proof refusal), bounded identically (nothing gained), same class; noted
for the record so a future pin on that seam starts from the truth.

**R3-F2 [MINOR — hardening; unreachable today, no red-on-old possible; traced degradation
is the justification] · 12:725–728 + `sync_constant_time_equal`:507–521 — §5g's final
compare FAILS OPEN on a NULL `expected_hex`** (`false or not NULL` → NULL → the IF does
not fire → SUCCESS), and §5g guards only one comparand where §5f guards both — an
asymmetry inside one artifact, and R2-F2's rescoping removed the accidental fail-closed
cover the old handler gave the expected side. Unreachable through every deployed door
(every gate call passes a LITERAL rpc_name; nonce/stored_mac null-guarded above) — but a
future variable rpc_name or refactor turns it into a silent proof BYPASS rather than a
refusal. Fix: one line, §5f's own idiom (`if expected_hex is null or presented_hex is
null or not …`) + a green-by-design text arm on the ruled-order pin. Disposition:
**AGREE — FIXED (fix seat, post-cap).** Traced the fail-open myself: `extensions.hmac` and
`encode` are STRICT (a NULL rpc_name → `':' || NULL` → NULL propagates to a NULL
`expected_hex` with NO error), while `sync_constant_time_equal` is NOT strict — over a NULL
comparand its accumulator goes NULL and `return acc = 0` returns NULL, so `false or not
NULL` → NULL and the IF does not fire: the check RETURNS (success) — a silent proof bypass,
not a refusal. Unreachable today (every gate call passes a LITERAL rpc_name; nonce and
stored_mac are null-guarded above) — GREEN-BY-DESIGN, said plainly: no red-on-old is
possible. Fix: the compare guards BOTH comparands in §5f's own idiom, the mechanism
commented at the line; THE FAIL-CLOSED ARM added to the ruled-order pin
(`body.contains("if expected_hex is null or presented_hex is null")`), its green-by-design
status stated in the arm's own comment.

## THE ORCHESTRATOR'S POST-CAP ADJUDICATION (2026-09-23)

**Both MINORs are FIXED NOW, without a fourth review round — the cap rule's letter and
purpose both held.** The cap forbids LOOPING (more review rounds); it does not command
shipping a knowingly-false pin claim into the finals (R3-F1 — the "pins' arithmetic is
the real wire's truth" doctrine this phase's own ladder history enforces) or deploying an
artifact carrying a known fail-open asymmetry when amending it pre-deploy costs nothing
(R3-F2 — the artifact is UNDEPLOYED; one line in §5f's own idiom). Both fixes are
surgical and fully specified by the round-3 reviewer; the orchestrator verifies them by
its own read + pin runs; the finals and the window's live evidence stand behind them. No
round 4; these dispositions close in this file.

## FIX SEAT CLOSE (2026-09-23 — the post-cap fixes; the ladder's build work ends here)

Both MINORs AGREE/FIXED in ONE surgical commit (the fake's `checkProof` + the renamed
splice pin + 12 §5g's guard and the three single-use comments + the two pin arms + this
file). **R3-F1's RED-ON-OLD verified by behavioral revert against the COMMITTED fix:** with
burn-on-refusal temporarily restored in the fake, the re-worded pin failed at its own-door
landing — `KeyProofGateTests.swift:776 Caught error: Sync couldn't complete a security
check just now…` (the stale refusal: the burned pair could not land) — restored via
checkout to the committed fix, green. R3-F2's arm is green-by-design, stated plainly (no
red-on-old possible; the traced NULL fail-open is the justification). Ripple re-derived
pin-by-pin (recorded in R3-F1's disposition); one residual recorded there (post-proof RAISEs
in the same RPC also roll back on the mirror — unpinned, bounded, noted for any future pin
on that seam). Suites at close: **AuthRLSDDLTests 76/76 · KeyProofGateTests 17/17 · FULL
CORE 1722 tests / 180 suites — ALL PASSED** (+0 over round 2's close: the splice pin
re-worded in place, both new arms extending existing pins). No app-target files touched
this round (the standing COMPILE-PENDING list unchanged: `AuthSession.swift` only, from
round 1). Zero mirror contact.
