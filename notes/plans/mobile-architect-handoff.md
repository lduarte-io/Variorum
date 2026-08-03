# Variorum for iPhone — architect ROLE handoff (written 2026-08-03, context-safety checkpoint)

*The two-document form (the 13b exemplar): this file is the ROLE handoff
— role as amended, state-at-cutover to VERIFY-not-trust, machinery
lessons, open author items, and a paste-ready kickoff for a successor
architect session. The ONE running record is
`notes/plans/mobile-app-plan.md`; this file points, never duplicates.*

## The role

Architect/orchestrator for the standalone **Variorum for iPhone**
project under `/architect-phase` (all-Fable cast — M13). The author's
mid-sitting directive is STANDING (recorded verbatim in the plan's run
record): stage = phase discipline (full ladders, tests-with-every-step,
red-on-old, recorded counts), MORE autonomy than the Mac build
(PROVISIONAL-and-continue; bundles at stage gates; author-only calls
remain hard stops), and the look track runs in HTML mockups parallel to
Swift machinery. Work in the `~/dev/variorum-mobile` worktree, branch
`mobile`; push after commits.

## State at cutover (VERIFY each claim against the repo before relying)

- **All rulings live in `notes/plans/mobile-app-plan.md`'s run record:**
  the design sitting M1–M14 + the look sittings LK1–LK11 (the look canon
  is SETTLED for the v1 build — mockups v1+v2 under
  `Spikes/MobileMockups/` + the LK rulings; further look rounds ride
  REAL screenshots at stage gates).
- **Stage 0 CLOSED:** TK2-on-iOS spike ruled ADOPT ×6 (gate record in
  the plan; memo `notes/plans/mobile-tk2-spike-memo.md` — its seven
  Stage 1 obligations BIND). The spike is KEPT permanently as the iOS §5
  executable (her LK11 ratification).
- **Stage 1 batch 1 SHIPPED** (commits `6264049` · `7316ae9` · record
  `3b1ebc9`): the Write-true editor core — shared-brain parity move
  (`App/Variorum/Shared/EditorBrain/`), TK2-explicit view + checkpoint
  canary, identity-as-projection re-stamp, block-scoped autosave,
  crystallization, the revert-verified L9 pin, `MobileWalkTests` born.
  Counts by the implementer's own runs: mobile 38/11 · core 1034/114 ·
  Mac 1191/208 (the one recorded tripwire, by identity) · spine 51/7.
  The architect's acceptance note + the batch 2 brief follow the batch
  record in the plan file.
- **Stage 1 batch 2 SHIPPED + ACCEPTED** (commits `1a21024` · `32726b8`
  · record `42ec671`; mobile 68/15 re-confirmed by the architect's own
  run): the markdown vocabulary through one shared brain (the pure law
  was ALREADY in `VariorumCore/Domain` — what moved is surface
  arithmetic + the styling algorithm into `Shared/`), the six-act bar,
  checkbox tap, the widened-editedRange boundary bug fixed with a
  revert-verified pin. **The TRIM-LAW ADJUDICATION is recorded in the
  plan** (batch-2 acceptance section): `SegmentationRules`' Phase-2
  whitespace trim predates 13k K8 — ruled aligned (list-lead lines keep
  leading indent at segmentation; everything else unchanged); the Mac
  inherits the fix; batch 3 builds it.
- **Stage 1 batch 3 SHIPPED + ACCEPTED** (commits `96a7f8b` · `a43aef4`
  · `57d7492` · `4678778` · record `3e4d27e`; mobile 76/16 re-confirmed
  by the architect's own run): the trim-law fix per the adjudication
  (core Domain, revert-verified, superseded-pin sweep EMPTY, the Mac
  inherits with zero test deltas), VoiceTokens to `Shared/Theme/`, the
  LK2 phone-local voice switch, the Write surface styled to canon (R51
  black pinned; hidden-Iowan finding). **Machinery lesson added: the
  WRONG-CORE trap** — the pbxproj package reference had escaped to
  `~/dev/variorum`; now `../..` (relative). Counts at S1 build-complete:
  core 1039/114 · mobile 76/16 · Mac 1191/208 (tripwire only) · spine
  51/7.
- **STAGE 1 CLOSED** (closeout record in the plan, 2026-08-03): the
  ladder closed at round 2 — round 1 = 0 BLOCKER / 0 MAJOR / 2 MINOR /
  3 NIT, all dispositioned + fixed at adjudication (`5608810`); round 2
  = all five HOLD, zero new findings (`1866d42`). Final counts (three
  independent sessions' own runs): core 1039/114 · mobile 76/16 · Mac
  1191/208 (tripwire only) · spine 51/7. Ledger L2/L8/L9 dispositioned.
- **The stage-gate bundle is WITH THE AUTHOR** (presented 2026-08-03;
  enumerated in the closeout record): P1–P14 · LK5's ✓-finished rider ·
  the missing-bar-acts note · the FEEL ROUND = a tethered Debug run to
  her phone (the S1 Write surface is DEBUG-doored; her real-store
  Release install stays on the Phase 8 surface until S3). Nothing in it
  gates S2's build; fold her answers into the owning batches as they
  arrive.
- **STAGE 2 BUILD COMPLETE — both batches SHIPPED + ACCEPTED** (batch 1
  `ba6b2d9`/`4f610a6` — badge + gutter, swipe-peek, ✓, peeked-take
  editing, mobile 97/18; batch 2 `005dec2`/`40256ca` — the LK4 browser,
  the four verbs, the bar's ⑂, the one-seam edit-menu door, mobile
  **123/20**, both re-confirmed by the architect's own runs). Sibling
  types held both batches; the `deleteVariant` guard-order finding
  mirrored, never changed. **THE S2 LADDER IS RUNNING — round 1
  spawned** (target `c8174ed..40256ca`; findings repo-first; same-model
  flow; eight recorded flags are the reviewer's anchor). **Round 1
  RETURNED (findings `408900e`): 1 BLOCKER (flip-back restores the
  chosen take ledger-blind — the stale-projection text-loss class) ·
  1 MAJOR (branchDisplayed copies past a dirty buffer — the 13f R1-4
  flush-first class) · 3 MINOR · 2 NIT; all ADJUDICATED (`5b7cc0e` —
  every disposition in the plan) and the FIX SESSION IS RUNNING
  (fresh session; red-on-old by behavioral revert per finding; NIT 2
  recorded-only). Round 2 re-reviews the fixes when they land; the
  BLOCKER/MAJOR being round-1 findings does NOT force round 3 — only
  a NEW BLOCKER/MAJOR in round 2 does.**
- **STAGE 2 CLOSED** (closeout in the plan, 2026-08-03): the ladder
  closed at round 2 — the fix pass landed all six adjudicated fixes
  with revert-verified pins; round 2 = all seven HOLD (red-on-old
  independently reproduced on the pre-fix tree, 6/6 discriminate), zero
  new above NIT; mobile finals **130/20**. The round-2 NIT is
  product-flavored and routed to the author as **Q-M1**
  (branch-under-refused-flush: seed-from-ledger (a) vs refuse-the-door
  (b); (a) noted spec-truer; NOTHING built until she rules).
- **THE COMPLETE STAGE GATE IS WITH THE AUTHOR:** P1–P26 · LK5's rider
  · the missing-bar-acts note · Q-M1 · the feel round (both stages'
  device items + round-2's riders: marker z-order, ~26 pt badge target,
  ⑂-drift, second-tap focus, the sheet's keyboard constraint). Nothing
  gates S3.
- **STAGE 3 BUILD COMPLETE — batch 1 SHIPPED + ACCEPTED** (`e531f6d`/`774305e`; mobile **133/18** re-confirmed by the architect — the −14/+17 arithmetic accepted, Phase 8 tests retired WITH their surface; the KnownIssues trailing-newlines row RESOLVED by replacement, L9-cited; P27–P34 to the bundle, now P1–P34; ledger L4 DONE). **THE S3 LADDER IS RUNNING — round 1 spawned** (target `2ba90d7..774305e`; flag 1 — the retired-tests mapping — weighted). Then S4 (Read flow · comments/callouts · divide/merge doors) — the LAST build stage before the author's combined gate. *(Original spawn note, superseded:)* batch 1 spawned (brief in the plan: the
  shelf home with LK5 faces · Today through the shared daily door ·
  LK7 tabs · Library/search/bookless filter · the Phase 8 capture
  views RETIRE with the KnownIssues trailing-newlines row resolving in
  the batch record · the voice switch's Settings home · the
  cold-launch walk). Batch 1 closes S3's planned scope; its ladder at
  acceptance; then S4 (Read flow + comments/callouts + divide/merge
  doors) per the stage table.
- **The stage-gate author bundle so far:** batch 1's P1–P4 + LK5's
  ✓-finished-as-state PROVISIONAL; the device feel round (live
  autocorrect/dictation, loupe-under-pan — the memo's obligation 6);
  the first Release install to her phone at a milestone (M14).

## THE v1 BUILD IS COMPLETE (2026-08-03) — the gate is with the author

All four stages closed behind two-round ladders (the plan file's stage
closeouts are the record; finals mobile 172/24 · core 1039/114 · Mac
1193/208 tripwire-only · spine 51/7). The successor's whole job until
her gate answers arrive: NOTHING builds; fold her rulings (the feel
round's findings, Q-M1, Q-M2, any P1–P44 flips) into adjudicated fix
batches with the standing discipline, then `mobile` → `main` at her
word, then the look/beauty rounds at her pace.

## Machinery lessons (earned this run — do not relearn)

- Simulator: **iPhone 17 family, most recent iOS runtime, always** (her
  LK1). The iPhone 16 sims are iOS 18.3 and resolve to NOTHING.
- The spine's 51/7 needs the SEVEN suite TYPE names — the file-name
  `-only-testing:VariorumTests/TutorialWalkTests` selects zero tests
  (batch-1 record has the list).
- `UITextView(usingTextLayoutManager:)` is a bridged ObjC FACTORY — on a
  Swift subclass it skips Swift stored-property init (SIGSEGV). Use the
  true designated `init(frame:textContainer:)` over an explicit TK2
  stack (batch-1 record, item 2).
- iOS strips custom attributes on EVERY insertion path — identity is a
  re-stamped projection, never attribute inheritance (the memo's
  headline; the DEBUG audit guards it).
- A PARALLEL 14a architect session runs in the main worktree and shares
  the memory file `variorum-phase-9-run-state` — anchor memory edits on
  your own block headers; expect concurrent modifications.
- Her interleaved rulings arrive mid-turn — record them verbatim in the
  plan SAME turn, reply point-by-point, commit + push each record.

## Paste-ready kickoff for a successor architect

> You are the architect/orchestrator for **Variorum for iPhone**,
> resuming mid-project. Read `.claude/skills/architect-phase/SKILL.md`
> IN FULL, then `CLAUDE.md`, then `notes/plans/mobile-app-plan.md` IN
> FULL (the run record's rulings M1–M14 + LK1–LK11, the constitution,
> the stage table + ledger, the environment traps, the Stage 0 gate
> record, every batch brief + batch record), then
> `notes/plans/mobile-tk2-spike-memo.md`, then
> `notes/plans/mobile-architect-handoff.md` (this file). Verify repo
> state (`git log --oneline -10`, `git status`, branch `mobile` in
> `~/dev/variorum-mobile`) and VERIFY the latest batch's claims by
> spot-check before relying on them. Then continue the ledger from its
> current state: finish Stage 1's batches, run the stage-end review
> ladder, bundle the PROVISIONALs for the author's stage gate, and keep
> the standing directive — full discipline, her rulings verbatim,
> repo-first records, push after commits.
