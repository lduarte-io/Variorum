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
  flow; eight recorded flags are the reviewer's anchor).
- **After the S2 ladder closes:** the stage gate to the author (the
  bundle is now P1–P26 + LK5's rider + the missing-acts note; the feel
  round covers BOTH stages' device items — live autocorrect/dictation,
  loupe-under-pan, the sheet's keyboard constraint); then S3 (the app
  shape: shelf home + Today + Library/search + nav; the Phase 8 capture
  views retire there, which is also when the KnownIssues
  trailing-newlines row resolves) per the stage table.
- **The stage-gate author bundle so far:** batch 1's P1–P4 + LK5's
  ✓-finished-as-state PROVISIONAL; the device feel round (live
  autocorrect/dictation, loupe-under-pan — the memo's obligation 6);
  the first Release install to her phone at a milestone (M14).

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
