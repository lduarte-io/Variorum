# pre-13x — ORCHESTRATOR HANDOFF (drafted 2026-09-04 at the clean seam after batch 0; the design session hands the BUILD half to a fresh architect)

**Why a cutover here:** the design sitting spent ~720k of context settling the shape (three review passes, the
rewrite, the copy, batch 0); the build half ahead (batches 1a · 1b · 2 · 3 · 4 · 5, the deploy window, the
ladder, two drills, her walk) is larger than the re-orientation read. The seam is clean: batch 0 CLOSED and
verified; the bridge retirement is HERS to run next from its own kickoff; batch 1's brief is written.

## PASTE-READY KICKOFF (for the successor orchestrator — a fresh Fable session)

> You are the `/architect-phase` orchestrator for Variorum's **pre-13x** phase (Postures & recovery — the
> Standard/Castle simplification), taking over at the seam after batch 0. Read, in order, and nothing else
> first: `CLAUDE.md`; `.claude/skills/architect-phase/SKILL.md` (your role and the 13b constitution);
> `notes/SessionResiliencyProtocol.md`; `notes/plans/pre-13x-postures-design.md` WHOLE — §18 is history, §19 is
> the architect's sign-off and its conditions, §17b is the execution record (units, traps, LIVE STATUS, the
> ledger, the BATCH 0 and BATCH 1 briefs), §17c the batch records; `notes/plans/pre-13x-copy.md` (every
> user-facing string — render, don't re-derive); `notes/plans/pre-13x-design-review.md` §8 and §3 P5 (why the
> shape is what it is; do not re-derive its traces); `notes/plans/pre-13x-spike-memo.md`; this handoff whole.
> Then VERIFY, never trust (git log, git status, the plan files' status banners): (1) has the bridge retirement
> landed (`notes/plans/pre-13x-bridge-retirement.md` §6 DONE, §8 review closed, tag
> `archive/fragments-bridge-2026-09-04` present)? If not, it is HERS to run from that file's kickoff — do not
> start batch 1 over the bridge code; (2) batch 0's Q3 (the phone leg) — the memo's PENDING-HER-SITTING slot and
> ledger row 2: filled by her report, or still open (not blocking until batch 2 writes the real Apple key).
> Then run the batch loop from BATCH 1a per §17b's brief: one FRESH Fable implementer per session, briefed by
> the file's named sections only; verify each batch hands-on or by its drill before its record closes; commit
> and push every record; keep `variorum-phase-9-run-state` memory current. The lockstep deploy (marker 7 → 8)
> is HER act in HER window, scheduled immediately before batch 2's migration + install — never earlier. Bring
> her decisions as question-tool batches; record rulings verbatim-faithful in the design's §1/§16 the same turn.

## STATE AT CUTOVER (verify each; nothing here is to be trusted from prose)
- **Design:** `notes/plans/pre-13x-postures-design.md` — REWRITTEN 2026-09-03 (`bfc967b`), rulings through
  2026-09-04 in §1/§16; the architect's conditional sign-off §19 (conditions: the key-proof token in this phase's
  event — RULED YES; the descriptor-floor and never-wrap-under-a-network-key pins in batch 1; batch 0 observes A
  crossing her two devices before Standard copy is written — Q3 PENDING; Fable reviewers on every ladder round;
  the honest boundaries survive 13s).
- **Copy:** `notes/plans/pre-13x-copy.md` (`7293f95`) — hers to re-voice later; the batches render it verbatim.
- **Batch 0:** CLOSED + verified (`62beb1f`): the shared access group on both targets (`a37f9cd`); the DEBUG probe
  doors (Mac Help menu · phone Settings dev row — DELETED at batch 2 when the real Apple key lands, ledger 12);
  the memo; spine 72/10 green on the batch 0 tree. Q3 PENDING-HER-SITTING (the design session was installing
  the dev build on her iPhone 17 Pro at cutover — see PENDING slots below).
- **The bridge retirement:** PLANNED (`293b25e`), NOT RUN at cutover; hers to run; its own Fable review.
- **Batch 1:** BRIEF WRITTEN (§17b): 1a client substrate; 1b the protocol event + deploy checklist.
- **Her devices:** Mac = Biometric mode, escrow off (→ Castle at migration); phone = signed in, opens SILENTLY
  today (her words 2026-09-04: "my phone doesn't require face id") — under ruling 19 the phone becomes Castle at
  its migration (Face ID with passphrase fallback); say so to her at the batch 2 sitting. She holds the suite
  passphrase since 14b; her Mac's key file has NO passphrase box yet (§11's backfill + the one-time confirm).
- **Memory:** `variorum-phase-9-run-state` (the resume map).

## PENDING SLOTS (fill at the next seam)
- Q3 phone-leg results: Mac→phone status + time PENDING · phone→Mac PENDING · the phone's local round trip
  PENDING · the phone's own-group line PENDING. The dev build install to her phone: PENDING(hash/outcome).
- The bridge retirement's landing — FILLED 2026-09-04: tag `archive/fragments-bridge-2026-09-04` (+ branch, both on origin, at `32d3fdf`); the implementer's seven commits `4c1d443`…`d17fe45`; the ladder closed at the cap (round 1: 1 MAJOR process + 5 MINOR + 4 NIT; round 2: N1 MAJOR — the sweep reached the login keychain — fixed `65af5e4d`; round 3: 0/0/2/7, the two MINORs → KnownIssues owner pre-13x batch 1a); the `/Applications` refresh done at her word at the close (the hash in the record §8); HER ACTS: she quit the old build and is having Fragments delete its side, so the carry item's ordering is moot. **Batch 1a inherits:** the retired-credential sweep's sign-in occasion (gate + off-main + a required seam) — the KnownIssues row.

## MACHINERY LESSONS (this session's, beyond the protocol's addenda)
- zsh does not word-split an unquoted `$VAR`; pass `-only-testing` flags as `"${ARGS[@]}"` or xcodebuild exits 65
  without running a test (cost this session one silent non-run).
- `TutorialWalkTests.swift` holds SIX suites (`TutorialBookShapeTests` … `TutorialLookingActsTests`); the spine is
  all six, addressed by TYPE name, never by file name. The standing count is 72 tests / 10 suites.
- The batch 0 DerivedData is a gitignored `App/Variorum/DerivedData/pre13x-b0` inside the worktree; reuse it.
- Her live app (PID 79767 at cutover) runs beside every suite; never touched.
- A read-only Sonnet lookup for platform facts is worth its cost early (the review's §7 came from one).

## OPEN AUTHOR ITEMS (bundle for her next sitting)
1. Q3's five values (or her word that the phone leg is skipped — she said 2026-09-04 she is "not terribly
   concerned"; the probe needs only iCloud Keychain on both devices, NOT her account or posture).
2. ~~The bridge retirement run (hers) — then its review verdict.~~ DONE 2026-09-04 (see the filled slot above).
3. The lockstep deploy window (after 1b, before batch 2).
4. At the batch 2 sitting: her phone's move to Castle (Face ID at open) — a consequence of ruling 19 she has not
   explicitly seen stated; and the one-time "confirm your passphrase to finish" on both devices.
5. §16(e): the posture copy is 13s's; nothing owed now.
