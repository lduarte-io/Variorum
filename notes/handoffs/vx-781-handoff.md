# VX-781 handoff — the lockfile rewriter (CLOSED 2026-11-05, PR #220, merge af012aa67)

## Your checklist

1. **QUESTIONS #260 is ratified except one held item.** You ruled at the checkpoint: **P-781-1** (the CLI lockfile alignment) and **P-781-2** (the 15 visible package references) both stand as built; **P-781-4** — moving an existing dependency's pinned version is **AUTHOR-ONLY** (the CLAUDE.md line landed). **P-781-3** you ruled the same sitting after the owed survey (`notes/plans/vx-781-build-ergonomics-survey.md`): **versions-equal** — built the same night as **VX-853**; the survey's optional lockfile-mode belt parked as **VX-854**. So #260 is FULLY RESOLVED; nothing left to ratify.
2. **VX-852** (Medium, Todo): wiring `Tools/verify-pins` into release.sh as the standing post-archive check — the diff shape is ready in the record; it ran manually as a GO condition at the 1.1 release. Lands by normal PR flow with your eyes whenever you want it.
3. Nothing else needs your hands. No release owed (1.1 shipped mid-run, independently, on committed pins — verified).

## What shipped (the record: `notes/plans/fixes/vx-781-lockfile-pins.md`, FOR A LATER READER at its top)

VX-770's intermittent upward rewrites of the workspace Package.resolved, traced and belted:

- **Mechanism:** without the lockfile, the manifests FLOAT — SQLCipher through the GRDB fork's `from: 4.11.0`, swift-dependencies through `from: 1.9.0` — to exactly VX-770's upgrade set. A clean committed lockfile SEEDS the resolver and wins every time on Xcode 27.1; VX-770's "failed enforcement flags" had already-upgraded input. What first wrote the upgraded file that night stays honestly unreproduced (a second writer; `xcodebuild test`/simulator destinations never sampled) — the belt makes any such write heal or fail closed.
- **Release exposure: NONE.** 1.0, 1.0.1 and 1.1 all shipped committed pins — decisive proof by dSYM UUIDs (both releases' SQLCipher dSYMs byte-identical to the 4.18.0 xcframework; no swift-issue-reporting anywhere).
- **The belt:** exact pins in Package.swift AND 15 exactVersion project references (E10, measured: Package.swift-only pins get PRUNED — the repo package is a local dependency in the workspace); `PinBeltTests` in every `swift test` (hermetic, milliseconds, red-on-old four ways); `Tools/verify-pins` (any workspace-state.json / SourcePackages / lockfile, content-detected; no-argument = the pre-build working-tree guard); `Tools/pins-belt-check [<rev>]` (the networked from-scratch proof — red ×12 pre-fix including SQLCipher 4.18.0→4.20.0, green on the belt). **No version moved in the app graph**; the CLI graph aligned to what ships (P-781-1).
- **Upgrading a pin deliberately** is now a numbered procedure in the record (both manifests + both lockfiles in one commit; the guards go red until all four agree). VX-851 proposes a helper.

## For the next sessions (wave 1 merges this in first)

- **A REUSED DerivedData needs nothing after merging the belt in:** the next build re-resolves to the committed set (existing checkouts lose to the lockfile+constraints; post-belt even a dirty lockfile heals or fails closed — E3/E8b). `Tools/verify-pins <derivedDataPath>` after the first build is optional reassurance; PinBeltTests rides every `swift test`.
- `swift build` on the core package prints 7 expected `dependency '<x>' is not used by any target` warnings — the CLI belt's accepted cost. Xcode emits none.
- After each Xcode/Swift update, run `Tools/pins-belt-check HEAD` (the belt rests on two measured toolchain behaviors; the record's open item).

## Evidence lines

- Core suite on the merged tree: **"Test run with 3649 tests in 492 suites passed"** (incl. PinBeltTests) · StringsWorkbook 32/4 · MCP 549/100 with only VX-132's ticketed bound (VX-353/VX-685 family).
- App Debug build + `build-for-testing` green, verify-pins 16/16, built SQLCipher's UUID = 4.18.0's; headless VariorumMobile generic/iOS build green, pins verified. No `xcodebuild test` (no app source changed; the round-2 reviewer independently re-ran the core suite).
- Ladder: round 1 (opus-reviewer) 1 MAJOR + 4 MINOR + 6 NIT; round 2 (fresh) no new BLOCKER/MAJOR, 1 MINOR + 5 NIT; every finding fixed, none disputed; the final round line-by-line checked by the orchestrator. Dispositions in the record's LADDER ROUND 1/2 + FIX LEG sections.

## Born tickets (triaged at mint)

- **VX-850** (Medium · Bug · Test-only · Tests & tooling · Todo) — the CLI MCP socket suites trip their 5 s bounds more often on swift-concurrency-extras 1.4.1; test timing or real pre-initialize latency? (Covers MCPPreInitializeWindowTests/MCPDiscoverProbeServerTests, previously unticketed.)
- **VX-851** (Low · Feature · Tests & tooling · Backlog) — `Tools/upgrade-pin`, one command for the deliberate upgrade.
- **VX-852** (Medium · Improvement · Confirmed · Tests & tooling · Todo) — the release.sh verify-pins hook (your checklist item 2).

## Ledger state at this close

In-flight row retired; closeout paragraph seated in the master plan (VX-770's rolled to `notes/PhaseCloseoutArchive.md`); AppSpecRecord dated entry appended; QUESTIONS #260 filed; `Tools/canon-size`: **130,014 of 150,000 (headroom 19,986)** — no crossing, no canon contract line changed (nothing was ruled). Branch `vx-781-lockfile-pins` and worktree `~/dev/variorum-vx-781` removed after the merge. Riders: offered at kickoff, you ruled **no riders**. Mobile parity: **nothing mobile-visible**.
