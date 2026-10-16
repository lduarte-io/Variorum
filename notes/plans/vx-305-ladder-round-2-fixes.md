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

- **1(a) · MINOR — the absent-arm pin committed as built:** **DONE** (`4d8234068`).
- **1(b) · MINOR — the mutation twin:** **DONE** (`e927333f9`) — `ScenarioMutationPins` 22/1 green; the twin red with
  its off-switch neutralized (§1(b)).
- **1(c) · MINOR — `rollsBackBothHomes`'s comment, code unchanged:** **DONE** (`601cd9251` — comment lines only).
- **2 · NIT — ExecutorWorld's set-aside doc comment:** **DONE** (`ecf437996` — comment lines only).
- **3 · NIT — the two restores' deliberate-overwrite sentences:** **DONE** (`43e48d8b1` — comment lines only, the two
  Sources files).
- **4 · NIT — `beforeRollback` cleared after a tamper step whose relaunch opened the library:** **DONE** (this commit) —
  the protection set after it `✔ Test run with 434 tests in 71 suites passed after 14.974 seconds.`; the soak-shape
  slice PENDING (§"The runs at the end").
- **5 · NIT (SPECULATIVE) — record only:** PENDING (this record's §5).
- **The runs at the end:** PENDING.
