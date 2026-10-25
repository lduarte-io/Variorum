# VM-8 — ladder round 2 (cold review, Opus — re-review of round 1's fixes)

**Reviewer:** a fresh Opus cold reviewer, `notes/REVIEW_PROMPT.md` verbatim. **Charter (the orchestrator's brief):** re-review
round 1's fixes (L1) — sound, complete against their dispositions, honestly pinned — and judge L1's MINOR-1 reading. **Diff:**
`git diff 2243a26aa..HEAD` on `vm-8-protection-recovery-faces` (tip `5df6682c5`), every hunk read. **Anchor:**
`notes/plans/vm-8-ladder-round1.md` (findings, dispositions, the orchestrator's note on L1's reading) and
`notes/plans/vm-8-castle-catchup.md` (UNIT 2 — LIVE STATUS ▸ L1, P-VM8-8/-9/-10, ENVIRONMENT TRAPS).

**Scope check (first):** L1 touches no `Sources/` line (none under `Sources/VariorumCore/Sync/`), no editor seam, no custody
or keychain code, and changes no default's meaning. The twelve `Shared/` files changed are COMMENT-ONLY (every `+`/`-` line
of `git diff 2243a26aa..HEAD -- App/Variorum/Shared/` is a `//` or `///` line — checked by filter, nothing else survives).
Production changes are three phone files (`MobileProtectionDoors.swift`, `MobileProtectionScreen.swift`,
`MobileSettingsView.swift`). No re-spawn as `fable-reviewer` is owed.

**What I ran** (stage claim `vm8-r2`; the pinned simulator `<simulator-udid>`; a `git archive` copy of
the tip in my scratchpad with its own DerivedData — never the worktree, nothing committed but this file):
- `build-for-testing` of the copy: `** TEST BUILD SUCCEEDED **`.
- **L1's sixteen suites at the tip** (RUN B's set): `✔ Test run with 47 tests in 16 suites passed after 66.011 seconds.`
  — exactly the record's RUN B.
- **A scratch probe** (one extra hosted test in the copy, never committed) mounting the real `MobileProtectionScreen` over
  the same hand-made faces L1's pins use, printing what it says in four states (quoted under the MINOR-1 verdict below).
- PENDING (in flight while this file opens): a behavioral-revert spot check of MINOR-1 and NIT-2 in the copy.

## Findings (severity-ranked)

(PENDING — written as they are settled.)

## The MINOR-1 reading — VERDICT

(PENDING.)

## Clean bill

(PENDING.)
