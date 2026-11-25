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

## VX-348 — Run: Pre-launch bug sweep (2026-10-18; PR #173, merge 8611a7e17)
- Units: U1 (VX-357+VX-338+VX-339) · U5 (the urgent trio, joined mid-run) · U2 (VX-347) · U3 (VX-350+VX-349+VX-176) ·
  U4 (VX-351+VX-384+VX-385+VX-355) — five units, three fix legs (U2's double-file+rig, U4's three clusters, U5's
  stop-road), every fix red-first.
- Headless finals on the folded tree: core 3251/419 · third target 40/6 · MCP 383/71 (VX-353's standing flake green
  alone) · no-regress VX-180/181 30/4.
- Mac batches: U1 red 7/2 exact + fixed 78/13; U5 red 13/2 exact + fixed 242/31 (the one red live-confirmed real,
  fixed, door pin then 19/4 green); U2 red 13 behavioral + fix-leg red 5+1 + fixed 206/206; U3 red 10/4 exact +
  fixed 147/149→10/10 after the sub-pixel fix; U4 red 22/6 exact + fixed 353/363→5/5+7/7 after the test-only fix
  leg; W2-1's pin red 8-issues/fixed 18/6.
- The walk: two parts under the reversible store swap (six files aside / five in / six back, cmp-verified both
  ways), both voices, every member's face seen; one finding (W2-1) resolved honestly (no drift copy; the 1892
  stamps the seeder's own clock).
- Live rounds: VX-392's done-when (list_wings → create_book unaided), VX-357's wire strip
  (null_characters_removed: 1, the stored digest), VX-393's one-row double-share, VX-339's both banner halves,
  VX-394's clientClosed line + the serverOff gap confirmed then proven fixed on the real door.
- The ladder: ONE round, 0B/0M/3m/3n, all dispositioned repo-first; VX-338's deletion-safety argument independently
  re-derived.

## VX-306 — Castle rebuild phase 2: the open road (2026-10-18; PR #174)
- Units: U1a (the production leaves + VX-386 + the `protection_record` migration + VX-390) · U1b (the lobby on roads +
  VX-310's lobby half + the words card + the Release check + the dev store's fresh start) · U2 (the honest faces + rule 3's
  reminder + the set-passphrase sheet) · U3 (Look inside, Make this my library, the picked-folder road, the phone) · the
  words pass — four units in five implementer sessions plus two fix legs, every fix red-first.
- Headless finals: the core suite green in Debug and `-c release` (the release-floor reds pre-existing — VX-406); the
  protection suites green in both; the Release build (`-configuration Release`) green on every tree of the branch.
- Mac batches under the stage: U1a 28/6 · U1b 212/33 · U2 199/36 · U3 290/44 · the round-1 fix leg 340/54 · the
  round-2 fix leg 244/47 — each with exactly VX-310's three known witnesses; every red leg red by a one-line revert then
  restored (the round-2 legs: NIT 3 → `CopyDoorsPickRefreshTests` 2 issues; m2 → the readme's five-blocks pin + the two
  Start Here pins). Three pin faults found and fixed in the round-1 batch (the readme count, the plan parser, the
  never-run composition pin).
- The phone: 20/5 green on the iOS 26.2 iPhone 17 Pro simulator (the implementer's iOS 18 device refused the app).
- The walks (the orchestrator, the dev store, `OS_ACTIVITY_DT_MODE=YES` stderr): stages 1, 3, 5, 2, 14 a/b/c, rule 1's
  restore, rule 27's lobby and banner, Look inside, the AirDropped pair, Make this my library (dev library 86a82b4f under
  the same dev pair; A whole in Previous Libraries; the hold standing), the phone in the simulator; stage 13 not walkable.
- The ladder: round 1 (Fable, cold) 0B/0M/4m/4N — m1/m2/m4 + the NITs fixed red-on-old, m3 → VX-411; round 2 (Fable,
  cold) 0B/0M/3m/3N over the fixes — every round-1 fix confirmed; m2/m3/NIT 3 fixed red-on-old, NITs 1–2 → VX-307's plan
  §3; no round 3; the round-2 fixes line-by-line checked by the orchestrator (`notes/plans/vx-306-ladder-round-1.md`,
  `-round-2.md`).

## VX-329 — Castle rebuild: the release switch (CLOSED 2026-10-22; one day, kickoff to closeout)
- Branch `vx-329-release-switch`, worktree `~/dev/variorum-vx-329` (Pro); the Sync/-custody slot held; no
  coordinator (her mandate — the only session, `Tools/stage` held directly). Merge: the VX-329 PR (merge commit;
  the number in the handoff).
- The cut: L0 lockstep (marker 13→14, Fable) → U1 the switch + deletion (Opus) → L1/L1b Sync/ carve (Fable) → U3
  VX-423 (Opus) → R1 seven riders (Opus) → Mac/phone fix legs (Opus) → ladder r1/r2 (Fable reviewers, Opus fix
  legs) → §8 rehearsal + pg_temp + the byte-copy finding (Fable) → U4 the pre-design face (Opus; the fork ruled
  (a)+(D) by the orchestrator) → closing runs + walk window (Fable) → ladder r3 (Fable reviewer; PASS).
- The ladder: r1 1 MAJOR (record-class) + 6 MINOR + 2 NIT, the export-pin dispute upheld for the implementer;
  r2 all r1 fixes confirmed, 1 MAJOR (five stale pins, test-side) + 2 MINOR (her word corrections) + 2 NIT;
  r3 FINAL PASS 1 MINOR + 2 NIT (orchestrator-fixed line-by-line); her fourth-round latitude offered in session
  and unused. Cold reviews all Fable (her kickoff call).
- Tickets closed at the merge: VX-329 · VX-423 · VX-461 · VX-462 · VX-463 · VX-464 · VX-468 · VX-469 · VX-473 ·
  VX-406 · VX-380 · VX-213 · VX-465 · VX-114 (VX-233 already Canceled). Born: the mint list in the §9 closeout +
  the handoff. VX-470 ruled, sized out, leads the next run.
- Evidence floors at the tip: core debug 3303/431 · release 3274/426; Mac app 5097/892 (one one-byte red, fixed,
  suite re-run 5/5); phone 808/126 exit 0; the §8 rehearsal (rule 15 across the switch, real Postgres); the walk
  window (her face + the whole set-aside live on her real store's byte copy; VX-461's three live arms).
- The deploy, installs and release 0.10 are HERS at her window (the vx307 checklist + the pg_temp belt;
  marker-14 entry HELD in SyncSpec §12 until the window closes).


## VX-439 — Run: sidebar, bar & export quick wins (CLOSED 2026-10-27; PR #194, merge b3b16f2ba)
- Cast: Fable orchestrated; two fresh Opus implementers (one per batch) + the L1/R2 fix session; a fresh Opus
  reviewer per ladder round (her kickoff word — the takes cluster moved to VX-601); her overnight protocol.
- Merge order: LAST of wave 1 — VX-502's main merged at 0a30e8b09, VX-548's at 2b33e8bb6, both re-proven (the seam
  trio and the five-file overlap suites green on the merged trees).
- Evidence floors at the tip: b1 821/152 · b2 3,057/495 · L1 1,562/267 + revA/revB/R-R2 exact reds · final 80/10
  (VX-614 the one intermittent, green alone); headless core 3,467/463 at the end; three walks + an evidence slice.
- The history rewrite at her word: 7929147de → a3f087842 (captures zeroed from history, tree byte-identical,
  main's signed line intact).
- Born: VX-603 · VX-604 · VX-608 · VX-614 · VX-615 · VX-616 · VX-617 · VX-618 (triaged at filing). Her bundle:
  QUESTIONS #244. The release 0.10.3 at her in-session word, run after this entry.

## VX-677 — Run: editor, panes & the AI door (CLOSED 2026-10-29; PR #207, merge commit — SHA recorded at merge in memory + the ticket)

- Twelve members, five batches, the architect shape; the record `notes/plans/fixes/vx-677-editor-panes-ai-door.md`.
- The ladder: round 1 (`vx-677-ladder-round1.md`, 2 MINOR + 3 NIT; F-L2's mechanism corrected by the implementer's trace, the counter-shape confirmed with the openShow fold-in) → fixes → round 2 clean (`vx-677-ladder-round2.md`); closed at 2 of the cap 3.
- Claim C: fifteen suite rows all EXACT (C1 = VX-668's red-on-old observed — the merge gate; C11 = the 190-test #204 overlap clean); the walks all WORKS-AS-RULED (W-668-V1 ×3 all landed at START; S-572 Study re-shots on the themed window).
- Canon: MCPSpec (the offer dial · the version target · the gone-check · 3,061/3,100) + SurfaceContracts (doors · status seam · the mode-row carry family · Block History) + TEXTKIT2_NOTES §3 (the frame-constant display rule). Bundle QUESTIONS #252; MobileSoul not minted.
- Born: VX-683 · VX-686(grown) · VX-687 · VX-688 · VX-692(High, grown twice) · VX-694 · VX-702 · VX-705 · VX-706 · VX-707; VX-693 fixed in-run; VX-661 grown twice.
- Her live rulings this run: VX-624 seated · A-677-1/2/3 + B2-i ratified · VX-676's amendment + background-asks ratified · the trailer cleanup · the two-release amendment (vx-669 now, this run its own) · release.sh pre-approved. The release: 0.10.6, this run's, right after the merge.

## VX-105 — her finished readme seeds (2026-10-30, PR #209)
- Cast: Fable orchestrated (architect shape); Opus implemented (one session + resumed tails); Opus cold-reviewed (three fresh rounds, same-model — the orchestrator arbitrated; her word lifted the cap if a new MAJOR appeared; unused).
- Claims: vx-105-tests (targeted 125/12 green 102 s; full 5,739/1,000, 21 issues = 4 warn + 14 known + 3 real all one test, solo-proven green → VX-714; tree 2a42ea7de) · vx-105-walk (legs 1–4 PASS; slot md5-identical; prefs 412=412, 8 added keys deleted by name; the Oct-20 hold marker byte-identical; posture Standard/signed out/unlocked).
- Canon: SurfaceContracts seed-set line · AppSpecRecord 2026-10-30 · QUESTIONS #253/#254. MobileSoul not minted (nothing mobile-visible, R-105-2).
- Born: VX-711 (Low) · VX-712 (Medium → VX-292) · VX-713 (Low → VX-292) · VX-714 (Low) · VX-715 (Low). Closed superseded: VX-635.
- Her live rulings this run: R-105-1..10 (the record, verbatim) + S-1 accepted on the Prince precedent + the overnight release word (one folded release, notes public-only, the morning handoff bundles everything).

## VX-736 — Run: the 1.0.1 hotfix — onboarding audit & quick fixes (2026-11-02, PR #214)
- Cast: Fable orchestrated (architect shape, the overnight run at her advance release word); three fresh Opus implementers (B1 tour/Castle faces + the Castle-face walk at her word, B2 chrome trio, B3 badge + the joint walk); one fresh Fable cold review round (editor-decoration + Castle-face class) — closed at round 1, no BLOCKER/MAJOR.
- Members: VX-735 · VX-727 · VX-729 · VX-737 · VX-738 (VX-737/738 seated mid-kickoff at her word).
- Claims: vx736-orchestrator ×3 windows (B1 gates+walk ~04:10–04:50 incl. the Gate-B fixture stop and F-W3's test-first fix; B2 Gate C + three watches; B3 red run + Gate D + the joint walk 06:02–06:35). Gates 52/8 · 45/6 · 108/19 · 57/10; joint walk J0–J5 PASS both voices; dev slot restored md5-identical (211 files) after B1's fresh-slot walk.
- Canon: SurfaceContracts the-tour line + the VX-552 line + §The Library 1270 · AppSpec First-open parenthetical · AppSpecRecord 2026-11-02 · QUESTIONS #256. The CastleRules one-word touch HELD for her. MobileSoul not minted (nothing mobile-visible; the shared WordsBand change is additive).
- Born: VX-739 (Medium) · VX-740 (Medium, mechanism traced at the ladder) · VX-741 (Medium) · VX-745 (Medium, Castle & sync) · VX-742/743/744 (Low). Site: R-736-8 noindex off the four Variorum pages (stargazing-tech ac74b3a).
- Her live rulings: R-736-1..8 (the record's SITTING RECORD verbatim) + the overnight release word given twice.

## VX-781 — the lockfile rewriter (CLOSED 2026-11-05; PR #220, merge af012aa67)

- Cast: Fable orchestrated (/run-phase, single-ticket effort, her kickoff naming the nov4coordinator lane); ONE Opus implementer session (the trace, the belt, both fix passes — 11 commits, ended ~512k tokens); opus-reviewer round 1 AND a fresh opus-reviewer round 2 (scope test passed both rounds: no editor seam, custody, Sync/ or default's-meaning).
- Member: VX-781 alone (riders offered at kickoff — Tests & tooling Low/Medium candidates VX-773/744/237; her ruling: no riders).
- Ladder: round 1 — 1 MAJOR (no automatic guard on the belt → PinBeltTests, red-on-old 4 ways) + 4 MINOR + 6 NIT, all agreed, all fixed; round 2 (fresh) — no new BLOCKER/MAJOR, 1 MINOR (the static guard's used-set vs SwiftPM's measured pruning rule; road (ii): 15 exact project references) + 5 NIT, all fixed; the orchestrator's line-by-line final check. Zero disputes; two orchestrator adjudications (the MCP A/B — option A stands; the shared-manifest-cache disclosure — additive writes inside the coordinator's fence).
- Machine coordination: nov4coordinator — build cleared 21:20, MAIN FENCE 21:49–22:21 through the 1.1 release (11006, committed pins confirmed; this effort's two pin checks rode the release GO as conditions), merge GO 00:17, merge first of the post-release wave. No stage window used (headless throughout; no xcodebuild test anywhere in the effort).
- Gates: core 3,649/492 passed (incl. PinBeltTests) · StringsWorkbook 32/4 · MCP 549/100 with only VX-132's ticketed bound · app Debug build + build-for-testing green, verify-pins 16/16, built SQLCipher UUID = 4.18.0's · headless VariorumMobile generic/iOS build green. RELEASE-EXPOSURE: none (1.0/1.0.1/1.1 all committed pins, dSYM UUID proof).
- Canon: no contract line changed (nothing ruled); AppSpecRecord 2026-11-05 entry; QUESTIONS #260 (P-781-1..4; P-781-4 the governance fork). Canon-size 130,014/150,000.
- Born: VX-850 (Medium, the MCP socket A/B) · VX-851 (Low, Tools/upgrade-pin) · VX-852 (Medium, the release.sh verify-pins hook; diff shape in the record).
- Merge order: merged-in main twice (1.1 at f8d2ced67; the doc commits at 09a2ec59d); PR #220 merge commit af012aa67; ledgers c0a45265a; worktree and branch removed.

## VX-853 — verify-pins goes versions-equal (CLOSED 2026-11-05; PR #221, merge 2f68875e3)

- Cast: Fable orchestrated (the vx-781 session, same night); ONE Opus implementer (6 fix commits over three passes); opus-reviewer rounds 1 AND 2 (fresh each; same-model — orchestrator arbitrated, zero disputes).
- Member: VX-853 alone (born of her P-781-3 ruling at the VX-781 checkpoint; the survey `notes/plans/vx-781-build-ergonomics-survey.md` was the spec).
- Ladder: round 1 — 3 MINOR + 3 NIT, all agreed/fixed (own-file NOTE/DRIFT comparison; PinBeltTests location normalization under the orchestrator's declared scope ruling; duplicate-identity refusal); round 2 — no new B/M, 2 MINOR + 2 NIT, all fixed (restore advice `git checkout HEAD -- <file>`; the owed record file); orchestrator line-by-line final check.
- Machine coordination: nov4coordinator accepted at kickoff (first-ready-merges-first), trial-merged clean against 805/809/828, GO given with the PinBeltTests scope reach accepted; the NOTE/DRIFT sentence rides their wave broadcast.
- Gates: PinBeltTests 3/1 green on final code; probe matrix across three script generations (P1–P3, R1a/R1b, R4×2, R2v/G1/D1–D3, PA–PD), red-on-old everywhere a fix claimed it; headless throughout, no stage, no xcodebuild.
- Canon: none (the sitting's canon line was VX-781's P-781-4). Born: none. Merge order: one doc-only merge-in (ffb0a7857), PR #221 merge 2f68875e3.

## VX-805 — Run: the journal cluster (CLOSED 2026-11-05; PR #222, merge f1137c88b)

- Cast & shape: /architect-phase; Fable orchestrated and cold-reviewed; Opus implemented every unit (her R-805-1 — the Sync/ batch included, Fable reviewing every Sync/ line); FOUR implementer sessions (Unit A · the Unit B proposal session, retired at the ~500k seam per the 4E cutover · the Unit B build · Unit C) + two narrow in-window fixers; fresh `fable-reviewer` per ladder round. Nine members: VX-435/436/797/799/587/832 + riders VX-845/615/561 (VX-615 canceled as duplicate of VX-611).
- Her rulings: R-805-1..5 at the kickoff sitting (words verbatim in the record §3); the ⌥⌘J chord ruled in-run; the overnight directive governed everything after ~02:00 — every open call PROVISIONAL'd into `notes/handoffs/vx-805-handoff.md` (QUESTIONS #261).
- Machine coordination: nov4coordinator held the wave — the Sync/custody slot granted 00:41 and RELEASED at this close (no DDL shipped, no mirror deploy; the held 805+808 window is VX-808's alone); FOUR stage windows (Unit A ×2, Unit B, Unit C) + the merge gate, each with in-window red→fix→green cycles, every red traced before fixing (five test-side, zero code bugs at the windows); first-ready-first — this run merged FIRST; the trial merges recorded (vx-809: one conflict in Operations+WingBookMove.swift + 10 shared files, reconciles as second merger; vx-828: clean + 6 shared files).
- Gates: the convergence matrix `JournalWingConvergenceTests` (22 scenarios, two/three clients, explicit outbox + byte-identical quiescence, per-belt BEHAVIORAL-REVERT red-on-old); full core 3703/506; the merge gate on the exact merged tree c4a6e1806 — WHOLE VariorumTests 5867/1023 (one untouched-surface flake re-run-alone green) + FULL VariorumMobileTests 852/139 (the documented standing caret red VM-34/VM-38, pre-dating the branch). The ladder: round 1 NO BLOCKER/MAJOR (2 minor, 3 nits), round 2 clean — no round 3.
- Canon: AppSpec §7 (the `'daily_deleted'` sentinel; the journal one_block seed retired) · §9 (delete lands + R-805-2 + the Journal moves + ⌘J-first + `newJournalEntry` + `shiftEntryDate` + VX-845's roads) · §12 (⌥⌘J); OverallModel §7; SyncSpec §7 (the discriminator + belts + wing-aware keeper + the cross-wing mend — a new repair class); SurfaceContracts (Delete beside Archive · the ⌘K row · the New Book sheet); MCPSpec (the shared wire fences, R-805-5). canon-size 132,685/150,000. MobileSoul PL-68.
- Born: VX-857 (the book-spans-wings general class + the residual corners). Merge order: no merge-in needed (main never moved off the base); merge f1137c88b.

- **2026-11-05 · VX-809 — Umbrella: MCP door ergonomics** (PR #223, merge `fc82c88a8`): R-825's pure-function law built door-wide (the 209-arm two-store catalog; the counted class retired; the hidden-cause family); the bell-not-seat intake rule (P-809-8); move_book_to_wing/set_book_order/create_note-tags/list-forms+replace_tag; the server survives the Castle lock (walked); the sidebar AI trail; the docs tail. Ladder PASS at round 1; born VX-858/VX-859; bundle QUESTIONS #262; handoff `notes/handoffs/vx-809-handoff.md`.

- **2026-11-05 · VX-828 — Umbrella: editor & shell QoL** (PR #224, merge `8b9ced515`): Return mid-word carries the word down (VX-806, #92(b) superseded) + the list-exit retraction inside the flight (VX-655); the Trash's empty-block sweep + its message band (VX-800/636, R-828-1); the Library remembers the place and the row (VX-823, P-828-11..14 — the run's one live walk catch, fixed + seam-pinned); ⌘1–⌘9 wings, Bookcase landings, the label's ticker (VX-824/833/844); one-shot spelling (VX-798); Settings ▸ Tags follows the wing + the unused-tags sweep consuming vx-809's brain (VX-838/840). Ladder PASS round 1 (0 B/M; the one MINOR's dispute won by the implementer); gate 5983/1039 + phone 88/6. Born VX-855/VX-856; bundle QUESTIONS #263; handoff `notes/handoffs/vx-828-handoff.md`.

- **2026-11-06 · VX-878 — Umbrella: Book doors & faces** (PR #229, merge `35a98fb6a`): nine members (VX-802/804/816/829/831/858/868/874 + VX-887 seated mid-run at her word) in four batches; Fable orchestrated + cold-reviewed, Opus implemented; ladder PASS at round 1 (F1 dead-wing destinations fixed, F2 NoteRename→Core/Views, F3 record-only by the reviewer's reversed call); her in-run rulings R-878-K1..K4 (the mark's approved-client gate; the masthead threshold strict); two real window reds fixed in-window per the coordinator's gate shape; merged FIRST of the Nov 5 wave (vx-808/819/827 live beside). Born VX-889; bundle QUESTIONS #264; handoff `notes/handoffs/vx-878-handoff.md`.

- **2026-11-08 · VX-914 — Umbrella: the walkthrough followups** (PR #235, merge `cc6c8f188`): fifteen members in four batches (VX-903/905/902/904 + rider VX-401 · VX-900 · VX-901/896/897 + riders VX-45/667 · VX-911/870/898/909); Fable orchestrated and adjudicated, Opus implemented, opus-reviewer's two-round ladder (one MAJOR, closed round 2); the merge gate = the WHOLE Mac target 6231/1078 + the WHOLE phone 852/139 on the merged tree `c2f21d856` (nov7's whole-target rule, adopted mid-run after batch 3 proved stale pins live outside any changed-source list); the closing walk green with the dim pixel-measured; two Opus budget deaths, zero commits lost; born VX-927–930 + a VX-39 note; bundle QUESTIONS #269; merge order: VX-912 first (its main taken in two merge-ins), vx-914 the wave's last merger and the folded refresh's owner.

- **2026-11-09 · VX-849 — Run: the typed-over rescue and the offline unlock retry** (PR #241, merge `70f88a926`): ten members in six batches (VX-683/544/664/443/855/921/919 + riders VX-402/152/545), the sync-custody slot, overnight under her mandate; the ladder closed at round 1 (0B/0M) + a supplementary editor-seam read of the sweep fix (0B/0M); the closing sweep caught and fixed one real regression (the fabricated-empty snapshot); the wave's LAST merger — 1.4 staged (bump + notes guard-clean), never published; PROVISIONALS P-849-1…7 (QUESTIONS #274); born VX-966…969, VX-971, VX-972; her Air drill and VX-919's deploy OWED.
- **2026-11-19 · VX-981 — Umbrella: MCP door fixes & follow-ups** (PR #14, merge commit `7629cf049`): fourteen members in five batches (VX-1007 · VX-977/979/961 + riders VX-133/705 · VX-951/944 · VX-959/952/963 + rider VX-773 · VX-368 the audit, VX-370 held at her word); Fable orchestrated, Opus implemented (seven sessions: five batches, PASS 1, PASS 2 + round 2's fixes); round 1 `fable-reviewer` 0B/0M/4m/5n (F1 the size-cap test race — signature 10/10 under the instrument, fixed test-only; F2 the partial show's split; F3 the record; F4 the move's dead doors → P-981-L1-1; N1–N5 fixed), round 2 `opus-reviewer` 0/0/1m/3n (R2-F1 → one ⌥⌘O rule on every gone road, VX-1025; the orchestrator's line-by-line check), no round 3 under R-981-5; gates A 234/31 · B2 415/61 · B34 108/16 (merged tree) · FIX 143/22, every red leg run and red; headless MCP 746/139 ×3 alone; the announce soak old-red at 475 and 296, the fix 600/600 alone + 3,232 under a parallel core run; the release-configuration test build to its end twice; the closing walk GREEN in both passes (the Journal's Private faces in both voices; the live wire round); the merge gate GREEN on the merged tree `9007f4686` — the whole Mac target 6,434 tests in 1,114 suites with ONE red, VX-701's known keyboard-focus flake (`TakesFindBoardTests.escWithNoBuiltPaneForTheRingIsANamedBoundary`), green alone twice inside the claim; the 13-type phone leg 159 tests green; born VX-1012/1018/1020/1026, seated VX-1019/1025; bundle QUESTIONS #278; release the 1.5 build follows the merge — made, never published; its result is in the handoff's release section.

- **2026-11-19 · VM-78 — Run: Fixes to what's there** (PR #15, merge commit `f909d6714`): ten members in four batches (B: VM-16/43/3/84/33 · A: VM-81/83/21 · C: VM-24/17 traced, VM-19 · D: VM-17's fix, which failed its window and was backed out) plus VM-20 and VM-19 carried; EIGHT members shipped, re-landed on VM-55's message line by the merge-in, main merged in again after VX-981 (no product line changed); VM-24 and VM-17 (with VM-239 and VM-179) each to its own run after wave 1 (her rulings); Fable orchestrated (one session throughout, its context compacted once at a clean seam at her word), Opus implemented, a fresh fable-reviewer per round — round 1 0B/2M/6m/11n, round 2 0B/0M/3m/5n, round 3 0B/1M/5m/3n, round 4 0B/1M/0m/5n, round 5 0B/0M/0m/9n (the ladder closed at the cap); windows (2) 68/6, (1) 84/16 + Mac 110/17, (5) 75/10, F4 4/1, R2-N1 11/2, (3) the matrix's ten runs + M5b, the settle measurement 1/1, each after its reds; batch D's window red (the fix not proved, the decor red); six bundles lost or unreadable (batch B's red not kept; fixpass-red, r2n1-red, d-red, d-green and the gate's gate-phone unreadable), their logs kept; the re-land's window 44/4 red on exactly its six pins then 283/41 green; round 4's three guards and their window 26/5 red on exactly its four tests then 42/7 green; the simulator walk every row PASS (Study, five rows again in Terminal); the merge gate on the code that merged (`d55d22db9`'s, byte for byte) — the whole phone target 992/170 in one launch, 991 passed, the one red main's standing VM-24 caret pin (2 of 3 cases) by decision; the whole Mac target 6,435/1,114 in one quiet launch, 6,400 passed, 31 skipped, 13 known issues, the one red VX-701's known flake, green re-run alone (7/1) — main's baseline; PROVISIONALS QUESTIONS #279; born VM-239, VM-244, VM-245, VM-246, VX-1029, VX-1030 (the VoiceOver item a comment on VM-218; the Mac chip's Diverge ticket only if F8 is answered (a)); `Tools/canon-size` 143,220/150,000; the wave-1 phone install the last mobile merger's (VM-47, by the coordinator's order).

- **2026-11-19 · VM-64 — Run: Timing and the two lags** (PR #16, merge commit `982405967`): eight members in seven batches (VM-65 the timing layer and readout · VM-2 the keystroke fence · VM-66 the speed tests · VM-67 the launch scan · VM-68 the paged Library · VM-69 and VM-70 a note read once and released · VM-71 leaving saves once), all shipped; the wave's one `Sync/`-or-custody slot with no `Sync/` line written; main merged in four times (VX-980, VM-55, VX-981, VM-78); Fable orchestrated (one session, its context compacted once at her word), a fresh Opus implementer per batch and per fix pass, a fresh fable-reviewer for the midpoint review and each ladder round — midpoint 0B/0M/5m/3n, round 1 0B/0M/4m/3n, round 2 0B/1M/5m/3n (the major fixed, red on old), round 3 0B/0M/2m/3n, the last (her five-round rule, made standing in this run); the merge gate on the joined tree: the walk, the whole phone target at main's baseline with the gated speed suite skipped and then passed alone, the whole Mac target; born VM-226 · VM-227 · VM-232…VM-237 · VM-240 · VM-241 · VM-242; QUESTIONS #280; PL-79; the record `notes/plans/fixes/vm-64-timing-and-lags.md`, the handoff `notes/handoffs/vm-64-handoff.md`.

- **2026-11-20 · VM-47 — Run: Sizes and look** (PR #17, merge commit `226edf626`): eight members (VM-48/49/50/51/52/53/54 + VM-27) in five batches, then the VM-55 re-land (its tip merged in ahead of its PR, 23 files), R-47-3, two batches of the walk's fixes, the re-land of main (VX-981 + VM-78 by VM-78's round-4 map, `4866c7fb8`), W-A1 redone (main's clip back, the strips painted by the shell; the keyboard-reveal UI test) and the second re-land of main (VM-64 by its maps, four files, `3d55b51f6`); Fable orchestrated (one session, compacted at her word), Opus implemented with fresh closers at the ~530–713k context seams, fresh readers per capture set (4 + 2 + 2); a fresh fable-reviewer per round — midway 0B/1M/2m/2n (M-1 the UIKit 13 pt floor, red on old 20 issues), round 1 0B/0M/1m/4n (one NIT dismissed), round 2 0B/0M/0m/2n, round 3 0B/0M/1m/2n (the walk's questions into §5), round 4 0B/0M/0m/1n (the banner) — rounds 2–4 taken for new ground, not earned; the gate's two test-only fixes after round 4, read line by line by the orchestrator; windows: batch 1 883/145 (one real defect, one pin moved), re-run 118/12; batch 2 900/148, re-run 13/1, the path line red on old 22 issues; midway fix 75/6 + Mac 40/6, red on old 20; batch 3 916/151 + Mac 511/102, VM-54 red on old 5 issues; batch 4 117/12; batch 5 80/14 + Mac 84/15, VM-27 red on old 2 issues after its harness fix; the VM-55 tree's whole phone target 1,045/179 (VM-24's red only) + Mac 565/114; R-47-3's 65/9; the walk's fixes — part A every pin red on old (55 issues), 290/52 on the fix with one pin moved, Mac 36/9; batch 2 all twelve types red on old, 64/65 suites on the fix with one test-only rule fix, Mac 10 types; the walk 99 + 184 captures (2 timing misses), 29 findings; batch 7's targeted window phone 373/64 + Mac 161/25 (one red this run had made, fixed test-only); the re-capture 164 of 166 (5 more findings — W-E4 this run's, from the first edge fix); the post-merge window on the final tree phone 581/98, the speed suite 13/1 alone, three snapshots red as meant, the keyboard UI test red on the first fix and green on the final tree, Mac 118/21; the final-tree captures 119 of 119, no regression; the merge gate phone 1193/209 (VM-24's red + G.1, a frame-later mark ending VM-64's box-Open span: pin `07190ee14` red on old ×2, fix `bb0e2285d` test-only), the speed suite 13/1 alone, Mac 6435/1114 at main's counts (G.2, a source guard's idiom line, `e8c986cac`, green 172/33; VX-701's flake green alone), the phone legs again 1194/209 at main's baseline (G.1's pin green inside) + 13/1 — PASSED (the stage coordinator's call, provisional in her absence, hers to ratify); born VM-247/248/249; bundle QUESTIONS #281; PL-80; canon-size 143606 (headroom 6394); the wave-1 phone build is prepared from the merge commit by this run after this entry; its block is the top of the run's handoff.
- **2026-11-20 · VM-24 — an edit the phone editor was not asked about no longer snaps back (VM-243 riding: text typed after a dash is in full ink)** (PR #19, merge commit `fe1493c16`): /architect-phase, an away run overnight; Fable orchestrated and ruled the design, Opus implemented (batch A · batch B in two halves · the walk's closer · the ladder's fix pass, a fresh session each), one fresh fable-reviewer; nov18 on the stage. Two phone-only fixes, no `Shared/`, `Sources/`, `Sync/`, custody or schema line. Pins red on the old code and green on the fix in three windows; VM-243's mechanism confirmed by its pin before any fix; the standing caret red of 2026-10-25 green, unedited. The walk on a dedicated simulator device, before and after (VM-243 shown; the simulator met no unarmed edit, said plainly). Ladder (B/M/m/N): 0/0/2/1, closed after one round. The gate: the whole phone target 1,226 tests in 215 suites with no red, the speed suite's 13 alone, the Mac's 22 source-reading suites 129 tests; no whole Mac target owed; the coordinator's call, hers to confirm. Canon: TEXTKIT2_NOTES §3 ×2, MobileSoul PL-81; `Tools/canon-size` 143606 (headroom 6394). QUESTIONS #282. Born: VX-1031. Held for her: the "before" and "after" sessions on her phone.
- **2026-11-25 · VX-1036 — Inside a book: the List mode, tags on notes, the mint landing, the dial that saves, Read titles, capture tags** (PR #31, merge commit PENDING): /architect-phase, an away run overnight into the day; Fable orchestrated until her Fable limit, Opus after; four batches (opus-implementer each) + three acceptance fixes + three ladder fix passes; eleven members (VX-1039 · VX-1040 · VX-881 · VX-1080 · VX-1081 · VX-1038 · VX-1084 · VX-1078 + riders VX-96 · VX-576 · VX-1091). Ladder (opus-reviewer): R1 2 MAJOR · R2 1 MAJOR · R3 0/0 — closed at three rounds. Gates: batches 1+2 at the stage (1,639 host tests, four pins red-on-old), batches 3+4 on a snapshot (1,771 / 309), the merge gate on the resolved tree (Mac 6,652 / 1,158 · phone 1,226 / 215, 0 failed). Merged after VX-1082 (one mechanical conflict). Born: VX-1093 · VX-1095 · VX-1096 · VX-1097 · VX-1098. Release 1.6 made ready, published nowhere (her word releases it).
