# Run finals & ladder ledger

**What this is (her ruling 2026-10-14, VX-341):** AppSpec §14 keeps the most recent ~five efforts' entries slimmed to contract and provenance; the finals and ladder tallies stripped from each entry live HERE verbatim, newest first. A rolled entry's full original text also remains in `notes/AppSpecDeltaArchive.md` (VX-246's finals live only here until its roll). Future closeouts write the slim entry in §14 and append the finals/ladder text here in the same commit.

## VX-283

the ladder CLOSED at round 2 — Fable xhigh R1 0B/0M/2m/4n (R1-1 the LIVE STATUS currency, fixed by the orchestrator; R1-2 the windows owed, run; R1-3…R1-6 applied by the implementer) → Fable xhigh R2 0B/0M/2m/2n (R2-1/R2-2 the orchestrator's, done; R2-3/R2-4 → VX-374); no final-round code fixes.

Finals: the merged-tip WHOLE Mac target 4,854 tests / 800 suites — 18 issues incl. 14 known; two reds, both standing on main (VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads`; VX-167's `DestructiveUndoWarningTests.redoNeverAsks` under wide parallelism); VX-245's line-limit lint, red on main before this run, now GREEN; 32 gated skips; no new red. Per-unit windows: U1d 434/96; U2 722/144 (VX-115 only); U3b 511/103 (one real red → U3c); U3c 513/103 green; U2d 725/144 (VX-115 only); every pin red-on-old as named (U2d's R-W in the worktree, a source read). Walks: U1, U1b, U1d, U3, U2 (D1/D2 a road limit — the main-build control), and the U2d + U3c re-walk, every row holding.

## VX-336

the ladder CLOSED at round 2 — Fable xhigh R1 0B/1M/2m/2n (R1-1, U9's window then pending, closed by its evidence; R1-2, the canon owed, landed in-branch before the merge; R1-4/R1-5 nits, no change; no code fix) → Fable xhigh R2 0B/0M/1m/3n (R2-1, a wire Compare landing's armed posture outliving a named peer that never projected, fixed red-first in PHASE B and checked line by line; R2-2 one comment clause; R2-3 one handoff line; R2-4 a nit, no change); no round 3 earned

Finals: on the tree merged with main, headless VariorumMCPTests 349/67 (1 known, VX-357) · core 2,872/333 · workbook 40/6; Mac: the merge-moment WHOLE target 4,714 tests / 777 suites — 20 issues incl. 13 known (VX-229's nine + `IndexTierMetricsTests`' four), 4,680 passed, 27 gated skips; four reds, three standing on main (VX-115; VX-245/VX-283's six non-MCP lint sites; VX-167's redoNeverAsks) and one load flake that passed alone (`TakesFindBoardTests`' Esc boundary, 7/7 with its 1 known issue re-run alone), no new red; R2-1's pin red exact on the pin-only product (11 tests · 4 failed · 4 issues) and green 11/11 on the final; the phone suites U9 ran 120/15 (2 known by design). Per window: U5 31 suites 251 (244 passed, 7 gated skips) · U6 125 suites 790 (786 passed, the 2 standing reds VX-115 and VX-167, 2 gated skips) with every red run exact · U7 21 suites 176 (173 passed, 3 gated) · U8 66 suites 432 (429 passed, 3 gated) with the old seed's red exact · U9 121 suites 771 (765 passed, 6 gated) with the Mac red (20 issues) and the phone red (5) exact and the phone green 120/15; every real-client leg proven from the wire's bytes.

## VX-246

the ladder CLOSED at round 2 — Fable R1 0B/0M/1m/3n (F-1, the field guide's lesson-2 truth stopgap, among them) → Opus max R2 0B/0M/2m/5n (R2-2 deferred to VM-16), the final fixes checked line by line

Finals, on the tree merged with main: headless VariorumMCPTests 240/51 · core 2,860/330 · workbook 40/6; Mac: the merge-moment WHOLE target 4,695 tests / 773 suites — 16 issues incl. 14 known (VX-184's five + VX-229's nine); two reds, both standing on main (VX-115; VX-245/VX-283's six non-MCP lint sites), no new red.

## VX-282

the ladder CLOSED at round 2 — Opus R1 0B/0M/6m/4n → the Fable R2 0B/0M/2m/3n, every finding dispositioned, the final round's fixes checked line by line

Finals: the merged-tip WHOLE Mac target 4,666 tests / 767 suites — 21 issues incl. 14 known (VX-184's five + VX-229's nine); reds standing on main only (VX-115; ChromeLineLimit's six sites; VX-167) plus two load-dependent Takes flakes, VX-337; the whole phone target at the exact tip 824 tests / 129 suites — the standing `nothingUserFacingNamesTheMac` only + 4 declared known issues (C-1, a phone test-posture gap, VM-19, decided by a test-only decider; the caret suite keys its own window); headless core 2,809/322 · MCP 212/41 · workbook 40/6.

## VX-281

the ladder CLOSED at the cap — Opus R1 1B/0M/5m/3n (the BLOCKER: the Timeline's reach hold sized to every loaded row, not the rows drawn — fixed red-first) → Opus R2 0B/0M/1m/4n → the end-of-run Fable R3 0B/0M/0m/2n (one fixed, checked line by line; one withdrawn hollow)

Finals: the merge-moment WHOLE Mac target 4,590 tests / 748 suites — 10 issues incl. 5 known; three reds, all standing (VX-115; VX-245/VX-283's six lint sites; VX-167's redoNeverAsks under in-process parallelism), no new red; headless VariorumMCPTests 212/41 · core 2,790/321 · workbook 40/6;

## VX-184

the OPUS ladder closed at round 2 (R1 1M/6m/5n — the MAJOR, VX-198's re-bind letting any fresh key take any bound name, confirmed by trace and RULED by her → VX-258; R2 0B/0M/5m/1n)

Finals: VariorumMCPTests 212/41 · core 2,782/319 · workbook 40/6 headless; Mac: the merge-moment WHOLE target 4,551 tests / 742 suites — 10 issues incl. 5 known; three reds, all standing on main (VX-115; VX-245's eight sites; VX-167's redoNeverAsks under in-process parallelism), no new red; the corrected consent sentences seen whole in both voices.

## VX-179

the ladder R1 0B/0M/2m/1n → five fix legs → R2 0B/0M/0m/2n CLOSED, sanity pass agreed; six stage windows + two walks, every fixed row live-proven

Finals: the Mac comment set 103/103 across 15 suites at the merged tip; core 2,704/307 · workbook 40/6.


## VX-383

the FABLE ladder CLOSED at round 1 (0B/0M/2m/3n — F-1 a bundle sentence for her, F-2 accept-as-recorded, F-3/F-4 doc lines, F-5 no change); one stage window: the 382-suite Mac batch, the faces pin red-on-old redone on a rebuilt pre-fix product, the phone suite, the orchestrator's walk W1–W9 in both voices, the real-client live round L1–L7 (L5 half-live)

Finals: core 2,895/337 · workbook 40/6 · VariorumMCPTests 362/68 (VX-353's standing flake green alone) headless; Mac: the tip batch 2,402 tests / 379 suites with only the two standing reds (VX-115, VX-167); the guide + door pins 37/4 after R-C-1; `MobileVersionsTests` 17/1 (iPhone 17 Pro, iOS 26.2).


## VX-381

Ladder: round 1 (opus) 2B/1M/2m/6n — F-1/F-2 BLOCKERs + F-3 MAJOR confirmed-fixed, F-7/F-8 riders, F-4 → VX-388, F-5 → VM-21, F-6/F-10/F-11 recorded, F-9 → VX-216; round 2 (fresh opus) CLOSED THE LADDER — all five fixes hold, 0B/0M/1m/2n (N-1 the sweep predicate + witness seed 82, built by the orchestrator, both legs verified first-hand; N-3 → VX-391).

Finals: core full `swift test` 2,927/340 (the one red = VX-353's standing load flake, 3/3 alone); Mac batches — U1 red 29/4 (the 9 new pins exactly) · U1 green 135/18 · U2 red 18/4 (the 7 new pins) · U2 green 132/17 · fix leg red 11/2 + phone red 8/1 (exactly the new pins) · fix leg green 143/18 + phone 23/3; the orchestrator's both-voices walk PASSED (the run record's walk section).

## VX-382

Ladder: round 1 (opus) 0B/0M/3m/5n — CLOSED AT ROUND 1: R1-1 hollow by measurement (the Index→Outline carry pin green both roads, kept as non-regression), R1-2 (the click-is-her-place fix) and R1-7 (the Takes cell's dead zone) confirmed-fixed red-on-old, both orchestrator-line-checked; R1-3 → VX-402 (+ the comment corrected in-run); R1-6 → VX-403; R1-4/R1-5 → VX-300's notes; R1-8 hygiene done.

Finals: Mac batches — U1a 1,590/259 · U1b 1,998/332 + the D-2 verify 308/64 · U2 649/125 · the FOLD batch on the combined tree 700/132 · the ladder guard batch 342/71 — the only non-known red in every run VX-167's standing flake (red alone with its exact signature, not attributed); red-on-old: U1a 3 families + 2 guard probes, U1b 4 families + 2 probes, U2 3 families + the VX-77 dark probe (red at "ink at 0.0", green under dark with the .aqua pinning), the ladder's 2; core `swift test` 2,897/338 (U1b); walks — THE U1 WALK both voices (W-1 found there, fixed, re-walked) and THE U2 WALK both voices, all walked rows PASS.
