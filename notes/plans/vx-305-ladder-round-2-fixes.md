# VX-305 ladder round 2 — the fixes (the Opus implementer, applying the reviewer's final call)

**Not done, first:** (1) **the go/no-go soak** (20 seeds × 1,000, both configurations) — the orchestrator's, on the
final tree; a soak-shape slice runs here instead (§"The runs at the end"). (2) **The closeout's hand-forward list** —
the final call's checklist point 8 — is the orchestrator's: it already stands in the phase plan's §9 (`e6c3420ea`), so
this record only points at it. (3) **Nothing outside the final call is built:** no key/epoch-regression promise clause
(§1(d)(ii), a hand-forward), no narrowing of `rollsBackBothHomes` (KEEP, §1(c)), no set-aside at the two other restores
(§3, a comment instead), no code for NIT 5 (record only).

The binding text is `notes/plans/vx-305-ladder-round-2-final-call.md` (all five findings CONFIRMED, FINDER-FIXES
none); the report `notes/plans/vx-305-ladder-round-2.md`; the answer `notes/plans/vx-305-ladder-round-2-answer.md`.
Scope: `Sources/VariorumCore/Protection/` (comment lines only, two files), `Tests/VariorumCoreTests/Protection/` and
this record.

## LIVE STATUS (flipped in the same commit as each piece; PENDING = unverified)

- **1(a) · MINOR — the absent-arm pin committed as built:** **DONE** (this record's first commit).
- **1(b) · MINOR — the mutation twin:** PENDING.
- **1(c) · MINOR — `rollsBackBothHomes`'s comment, code unchanged:** PENDING.
- **2 · NIT — ExecutorWorld's set-aside doc comment:** PENDING.
- **3 · NIT — the two restores' deliberate-overwrite sentences:** PENDING.
- **4 · NIT — `beforeRollback` cleared after a tamper step whose relaunch opened the library:** PENDING.
- **5 · NIT (SPECULATIVE) — record only:** PENDING (this record's §5).
- **The runs at the end:** PENDING.
