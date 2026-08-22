# Mobile Round 2 — COLD CONSISTENCY AUDIT (2026-08-22)

Commissioned after the author said *"seems like a lot has been slipping
through the cracks."* A cold auditor swept the plan (2929 lines), the
handoff, the four investigation records, `CLAUDE.md`, `MobileSoul.md`,
13l's plan, all 32 commits, and the in-flight tree. **19 findings.**

**Its verdict, verbatim in substance:** *the plan file can be trusted for
what it records; the handoff cannot yet be trusted as a standalone
starting point.* Findings 1, 2, 5, 6, 7 and 11 must land before a
successor is started — each is a single edit, and each is otherwise a
thing that quietly does not happen.

## TIER 1 — promised work that will not happen

1. **THE HANDOFF PREDATES §43 AND STILL REPORTS THE FIVE UNREVIEWED
   BATCHES AS "DONE".** Written 00:06; §43 landed 00:34; never touched
   since. §43 ruled the map "gains a review column and no batch may be
   marked complete without it" — **that edit was never made.** An
   incoming orchestrator reads DONE and moves on. **THE ROUND'S WORST
   LIVE INCONSISTENCY.**
2. **TWO OF §8's THREE REVIEW COMMITMENTS ARE STILL PROSE-ONLY — and
   §43's own accounting missed them.** The **dedicated stability pass**
   never ran and is absent from §43's table; the **whole-round pass**
   appears in no map and no closeout obligation. *The documents written
   to fix prose-scheduling left two process steps in prose.*
3. **M9 is the SIXTH homeless row** — "assigned on arrival", in no map.
   Probably satisfied by the inventory's §4(b) sweep, but nothing says
   so, so it reads as open work nobody owns.
4. **R16's canon obligation is absent from the closeout list** — her
   standing principle ("selecting visible text and deleting should just
   work") is marked *owed to OverallModel §7 at closeout* and will
   evaporate.
5. **FIVE "held for her" items point at bundles that do not exist** and
   are missing from the handoff's open list: F2 (bookless vs a
   Quicknotes book) · the Release-side boundary check · **the gap-fence
   Mac narrowing** · the ⋯-door gap boundary · the gap-spanning-plan
   decline.
6. **The 13l manifest is missing FOUR Mac-side changes** — most
   importantly **the GAP FENCE** (a Mac behaviour narrowing, the most
   review-worthy item after the O(N²) fix), plus the caret-landing
   O(N·M) fix + doc-scoping correction, the crash trace's named
   `MarkdownActs` residual, and batch 4's in-flight Mac changes
   (`RecoveryView`, `TrayPanel`, `ShellActions`, and two NEW hoists
   `Shared/RecoveryCopy.swift`, `Shared/StructuralUndoCopy.swift`). Its
   file list and counts are also stale.
7. **THE KNOWNISSUES "SIX-BRAINS" ROW DOES NOT EXIST** — deleted at
   13e's closeout though that closeout says it was "cautioned". So the
   forked-brain debt (PR23's voice brain + the inventory's EIGHT-brain
   table) has **no owner outside this round's plan file**, which closes
   at closeout. **The blank-owner state CLAUDE.md forbids**, inherited.
8. **M12 / M14 / M16 have no landing place** — 13u's row does not
   mention M12; none is in KnownIssues; and M14's promised
   `Text`-per-paragraph measurement is now scheduled nowhere.

## TIER 2 — stale or misleading record

9. **§6's ledger was never maintained**: all ten rows still read `open`
   (M1–M5 shipped), three cite wrong batches, and **M11–M26 were never
   added at all.** The round has no single index of its own rows.
10. **R22 + M26 has NO record section** — its facts live only in a
    commit message.
11. **Six of eight dispatches have no brief in the record** — including
    **batch 4, which is IN FLIGHT**, so nobody can verify its delivery
    against what it was told to build.
12. **§9's binding baselines were never updated** (still 13j's numbers,
    five batches stale) though §17 recorded that they must be.
13. §38's mobile count (412) is contradicted by `c574acc` (413) and
    never reconciled.
14. **The handoff's fence recipe gives a FALSE POSITIVE** —
    `git diff | grep planVisibleTakeEdit` returns 5 (all in `notes/`).
    The fence itself holds: **zero Swift hits.**
15. The 23:49 install is recorded only in the handoff, not the plan.

## TIER 3 — investigation findings never answered (~20)

16. **Crash trace:** six unowned items — the E1 device experiment (the
    only thing that settles M1's arming source), the E2 CI fixture, the
    UIKit-undo-replay path, the `supportsTextReplacement: false` fence
    note, the `MarkdownActs` Mac residual, and M1's own SUSPECTED status.
17. **Stability survey:** every concurrency/lifecycle caveat behind the
    "solid" verdict landed nowhere. Two verified by the auditor:
    **`AppBootstrap.init` opens the store and runs migrations
    SYNCHRONOUSLY ON THE MAIN THREAD before first paint — a P2
    exception**; and the **`displaySlot`/`slots[i]` coupling**, safe only
    by caller accident, which **PR8 reorder-takes (batch 7) is walking
    straight into.** Also the `nonisolated(unsafe)` voice tripwire, 12
    unlatched `Task {}` doors in `MobileBlockMenu`, and two un-hoisted
    mobile-local brains.
18. **Quicknote survey:** the **`isDirty` honesty trap** (a refused flush
    keeps `isDirty` true, so the saved indicator must read the same
    source — A5-7 ruled the states, never the oracle) · `.inactive`
    still unruled · **the shelf has no keyboard avoidance and R26/R27
    just pinned a DWELLING text field into that layout** · the mint's
    unmeasured cost at corpus scale · 13u's title chip.

## TIER 4 — hygiene

19. **`VariorumMobileTests/ZZProbe2Tests.swift` is LIVE in the target** —
    untracked, self-described as temporary, 4 `@Test` functions. The
    directory is a synchronized group, so it compiles in and **will move
    the count the successor is told to verify.**

## WHAT CHECKS CLEAN (for calibration)

All hygiene claims hold (`git diff -- Sources/` is **empty**; zero
`Sync/`; zero schema). **The parity inventory is sound** — 24 rows, all
in the map, no stale citations after the PR renumbering. **All 13 code
symbols sampled exist**; the guard-3 tightening, the `@TaskLocal` seam,
the accumulation fix and the `#expect` oracles are all in the tree as
claimed. **Both hoist proofs hold structurally** (neither touches
`VariorumTests/`). **Her rulings R1–R27 are all recorded verbatim and
NONE is contradicted by the code**; R13 is guarded by a pin; the
`planVisibleTakeEdit` fence holds at 0 Swift hits. **The Mac's dead
purge door is still live** (`RecoveryView.swift:528-531`) — the parity
inventory's warning remains accurate.
