# pre-13x — ORCHESTRATOR HANDOFF (the build half; the design is settled)

**State:** the design is SETTLED and written clean (`notes/plans/pre-13x-postures-design.md`); its reasoning and history
live in `notes/plans/pre-13x-design-history.md`. Batch 0 (measurements) and batch 0b (the Fragments bridge retirement)
are DONE. **Batch 1a is the next act.** Nothing in the design is provisional.

## PASTE-READY KICKOFF (for the orchestrator — a fresh Fable session)

> You are the `/architect-phase` orchestrator for Variorum's **pre-13x** phase (Postures & recovery — Standard and
> Castle). Read, in order, and nothing else first: `CLAUDE.md`; `.claude/skills/architect-phase/SKILL.md` (your role
> and the 13b constitution); `notes/SessionResiliencyProtocol.md`; `notes/plans/pre-13x-postures-design.md` WHOLE
> (§1 the decisions, §3.4 the credential audit, §4 entering and leaving Castle, §5 the doors, §12 the pins, §15 the
> batches, §18 the execution record, §19 the batch briefs); `notes/plans/pre-13x-copy.md` (every user-facing string —
> render, don't re-derive); `notes/plans/pre-13x-spike-memo.md` (batch 0's measured facts); this handoff whole. Do NOT
> read `notes/plans/pre-13x-design-history.md` or `notes/plans/pre-13x-design-review.md` to decide anything — they
> are history; open them only when a mechanism's WHY is genuinely needed, and if the design file is silent on a
> mechanism, STOP and ask the author rather than infer from history.
> Then VERIFY, never trust (git log, git status, the plan files' status banners): the bridge retirement HAS LANDED
> (`notes/plans/pre-13x-bridge-retirement.md` §6 DONE; tag `archive/fragments-bridge-2026-09-04` present); batch 0's
> Q3 (the phone leg — ledger row 2) is PENDING her sitting and does not block batch 1.
> Then run the batch loop from BATCH 1a per §19's brief: one FRESH Fable implementer per session, briefed by the
> design file's named sections only; each batch's implementer creates, runs and records its own drills in the batch
> record, the ladder's cold reviewers check them and re-run what they doubt, and you adjudicate from the records —
> never run the suites yourself (your context stays clean); every ladder reviewer walks §3.4's "at the switch"
> columns; the closing ladder's first reviewer walks *Encryption Explained* and the tutorial chapter sentence by
> sentence against the build as its spine (design §18, condition vii) — you adjudicate its verdicts, and any
> mismatch that is not plainly a defect goes to the author; commit and push every record; keep the
> `variorum-phase-9-run-state` memory current. The lockstep deploy (marker 7 → 8) is HER act in HER window, scheduled
> immediately before batch 2's migration + install — never earlier. Bring her decisions as question-tool batches;
> record rulings verbatim-faithful in the design's §1 the same turn, and move any superseded text to the history file
> — the design file stays clean and dated-free.

## STATE (verify each)
- **Design:** `notes/plans/pre-13x-postures-design.md` — clean; the sign-off conditions are §18's last block.
- **History:** `notes/plans/pre-13x-design-history.md` — every dated ruling, supersession, session record and review.
- **Copy:** `notes/plans/pre-13x-copy.md` — the batches render it verbatim; 13s re-voices later.
- **Batch 0:** DONE — the shared access group on both targets (`a37f9cd`); the DEBUG probe doors (deleted at batch 2,
  ledger 12); the memo; spine 72/10 green on that tree. Q3 PENDING her sitting.
- **Batch 0b:** DONE — `notes/plans/pre-13x-bridge-retirement.md` §6; the install refreshed at her word. Batch 1a inherits
  ONE KnownIssues row (the retired-credential sweep's sign-in occasion + the required seam).
- **Batch 1:** briefs written (§19: 1a client substrate; 1b the protocol event + the deploy checklist).
- **Her devices:** Mac = Biometric mode, escrow off (→ Castle at migration); phone = signed in, opens silently today —
  it becomes Castle at its migration (Face ID with passphrase fallback); say so to her at the batch 2 sitting. She holds
  the suite passphrase since 14b; her Mac's key file has no passphrase copy yet (§11's backfill + the one-time confirm).
- **Memory:** `variorum-phase-9-run-state` (the resume map).

## RULED AT THE KICKOFF (2026-09-05): ONE phase, drills as gates, the ladder at the end — no split. The lockstep deploy and
the Mac install refresh are PRE-AUTHORIZED via her stored PAT (`.env.supabase.local`; the `!` road if the classifier
blocks the mutating call); the passphrase confirms and the phone install need her present.

## OPEN AUTHOR ITEMS (bundle for her next sitting)
1. Q3's five values, or her word that the phone leg is skipped (the probe needs only iCloud Keychain on both devices).
2. The lockstep deploy window (after 1b, before batch 2).
3. At the batch 2 sitting: her phone's move to Castle; the one-time "confirm your passphrase to finish" on both devices.
4. ~~The sizing flag~~ — RULED: one phase.
5. At closeout: AppSpec §14's delta (incl. the bridge retirement's canon changes applied in place 2026-09-04); the 13y
   and 13x hand-forwards (design §17).

## MACHINERY LESSONS (carried in the design's environment traps; repeated here for the paste)
zsh does not word-split an unquoted `$VAR` — pass `-only-testing` flags as `"${ARGS[@]}"`; the tutorial spine is SIX
suites addressed by TYPE name (72 / 10 standing); reuse `App/Variorum/DerivedData/pre13x-b0`; her live app runs beside
every suite — never touched; poll with `grep -q`, never `tail -f | grep -m1`; Swift Testing counts skipped tests.
