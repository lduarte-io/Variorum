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
arm fails on the current fake). Disposition: PENDING the fix seat (post-cap, adjudicated
below).

**R3-F2 [MINOR — hardening; unreachable today, no red-on-old possible; traced degradation
is the justification] · 12:725–728 + `sync_constant_time_equal`:507–521 — §5g's final
compare FAILS OPEN on a NULL `expected_hex`** (`false or not NULL` → NULL → the IF does
not fire → SUCCESS), and §5g guards only one comparand where §5f guards both — an
asymmetry inside one artifact, and R2-F2's rescoping removed the accidental fail-closed
cover the old handler gave the expected side. Unreachable through every deployed door
(every gate call passes a LITERAL rpc_name; nonce/stored_mac null-guarded above) — but a
future variable rpc_name or refactor turns it into a silent proof BYPASS rather than a
refusal. Fix: one line, §5f's own idiom (`if expected_hex is null or presented_hex is
null or not …`) + a green-by-design text arm on the ruled-order pin. Disposition: PENDING
the fix seat (post-cap, adjudicated below).

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
