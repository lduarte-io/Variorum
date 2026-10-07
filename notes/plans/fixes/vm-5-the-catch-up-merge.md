# VM-5 — The catch-up merge (mobile → main) & the Mobile Round 2 close

**Ticket: VM-5 · Project: Mobile — the merge & round-2 close · Branch: `vm-5-the-catch-up-merge`**
*(Her GO 2026-10-06. The merge narrative lives in `notes/plans/vm-4-mobile-catch-up.md`'s LIVE
STATUS; this file is the ladder record + the round-2 closeout's obligations disposition.)*

## The merge, in two lines

`origin/main` (dd7cad84, marker 12) + `mobile` (68 commits, batches 5–10 + 4.5c-phone + §12.2) →
merge commit `575cf057` + fix-ups `fabaf53e`. **The whole diff vs main sits inside
`App/Variorum/VariorumMobile/**` + `notes/**`** — zero `Sync/`, zero `Shared/`, zero Mac-target,
zero schema, zero pbxproj, `planVisibleTakeEdit` zero swift hits (all grep-verified). Mac/core
behavior is main's tip BY CONSTRUCTION.

## Verification

| gate | result |
|---|---|
| core `swift test` | **2204/247 + 40/6 GREEN** (baseline-exact vs 17y's record) |
| iOS app build (Release-sim) | **GREEN** |
| iOS test bundle build | **GREEN** |
*[removed for publication]*
| Mac suite | **DISCHARGED BY CONSTRUCTION, not by a run** — the merge changes zero Mac-reaching source lines vs main's tip (the table above), so the Mac target's inputs are byte-identical to the tree 17y closed green (3896/639 + the 5 standing knowns). Recorded honestly; any reviewer may overrule and demand the run |

## The round-2 closeout obligations (the standing handoff §7 — thirteen, numbered 1–8 · 10 · 11 · 13 · 12)

| # | obligation | disposition |
|---|---|---|
| 1 | 13l's manifest | COMPLETE as of 13l's close (the 2026-08-23 amendment made post-close edits forbidden); nothing owed |
| 2 | M17/M25 → TEXTKIT2 §3 | DONE long since — §3's "iOS 26 measured findings" carries both (exclusion-path presence; input APIs bypassing the delegate) |
| 3 | the parity ledger | DONE at this merge — PL-14 flipped CLOSED (6b), PL-3 flipped DELIVERED, PL-10/11 carry mobile's delivery rows, PL-25 dedup (17u → PL-25b); commit `40de737c` |
| 4 | the forked-brains row | ABSORBED into VM-1 (the board), including the post-archive additions (batches 7 + 6b's six) — the row's content cannot orphan again |
| 5 | the master plan + MOBILE PARITY line | the in-flight VM-5 row retires at the PR; the closeout paragraph + parity line land in the PR's ledger commit (the merging session, on latest main) |
| 6 | the author handoff | `notes/handoffs/vm-5-handoff.md`, written at close |
| 7 | the merge to main at her word (R9) | THIS EFFORT — discharged by the VM-5 PR |
| 8 | M16 — settle or own | OWNED: VM-13 (the device queue, Needs Lillian) — a named owner on the board |
| 10 | QUESTIONS | DONE at this merge — mobile's #84–#94 renumbered **#189–#199** with the mapping table; main's stale next-free marker corrected (#200) and moved to the file's end; the held-for-her items live as Needs Lillian tickets (VM-4's bundle, VM-13) |
| 11 | the two standing riders | DONE — the named-coordinate-space drag rule → MobileSoul §5 truth 9 (`40de737c`); the CarryAllMerge sibling note + `MobileQuickNoteModel.charDelta` → VM-1 |
| 13 | the second Mac manifest (tripwire) | NOT TRIPPED — the merge's Mac-reaching diff is ZERO files; there is nothing for a second manifest to carry. The tripwire survives for future VM work under R8 |
| 12 | R16 → canon | DISCHARGED by 13u1 (reassigned there 2026-08-23; the cross-block law landed in AppSpec §12 with the phase) |

## The ladder (three Fable passes, strictly sequential)

| round | brief | result |
|---|---|---|
| 1 — the RESOLUTION review | `notes/REVIEW_PROMPT.md` verbatim over `dd7cad84..HEAD` with both parents in view | **CLOSED** — 0B/0M/3m/2n, all FIXED same-wave (dispositions in `vm-5-review-round-1.md`); clean bill on the load-bearing items incl. the Mac discharged-by-construction argument, examined and upheld |
| 2 — the DEDICATED STABILITY PASS | the crash class + the range/identity math on the FINAL seam; owns M27 | **CLOSED** — M27 DISSOLVED (measured); MAJOR 1 = the ticketed VM-2, now MEASURED, held out by her ruling; MAJOR 2 + 2 MINOR + 1 NIT fixed by the Opus wave (`bf6619b4..a055d92b` — red pins quoted in the record, incl. a Mac twin pin proving the latent Mac hole; the Mac consumer deliberately joined the fix). ⚠ the wave touches `Shared/EditorBrain/` + one Mac file: the MERGE stays zero-Shared; the EFFORT no longer is — verification widened (Mac editor-brain suites 268/24 + 91/14 green; the FULL Mac suite runs before the PR) |
| 3b — the FOCUSED ROUND 3 (the ladder's cap round, on the wave's diff `9a6aedaa..a055d92b`) | the new `binds()` semantics hunted adversarially (a legitimate non-"\n" tail-opening landing?); the Mac consumer extension; MINOR 4's refusal roads; the pins' reds | DISPATCHED |
| 3 — the WHOLE-ROUND PASS | the round's entire mobile-side diff (`46ffa0c`'s round start → this tree), briefed on nothing but the diff | **RAN — 0B/0M/5m/1n + 1 observation** (record `vm-5-whole-round-pass.md`). Dispositions: m1+n6 comment fixes landed (`ddc68c6e`); m2 (the `.bookless` false empty-copy) · m3 (the "unseal" drift + the VersionActs rider) · m4 (version save past a refused flush) → the final Opus wave with red pins, PROVISIONAL copy marked for 13s; m5 (the E1 instrument's retirement) → DEFERRED, owner VM-13 (kept armable until its device walk, retired at its close); the observation (copy-all-takes unbuilt) already owned at PL-10/VM-7 |

Findings + dispositions land here per round; fix waves per her cast (Opus 5.5 implements; the
orchestrator may take mechanical ones).

## THE STAGE/MERGE SCHEDULE (her ruling via 13o, 2026-10-06 late — 13o decides order; recorded verbatim-faithful)

- The current VM-5 claim covers the ladder's tail through the final full mobile suite; release at the PR; renew honestly.
- MERGE ORDER: first-ready-first governs VM-5 (13o is days from PR — no collision); report the PR-ready moment to 13o for the greenlight. Standing exception R-13o-1: 13x merges only after 13o lands; small-fix PRs (vx-75) merge when ready.
- After VM-5's release the stage queue is: 13x's short suite run (≤25 min) → vx-75's 45-min walk+pin slot (hard-blocked) → VM-10 (60–120 min, interruptible; message 13o when its worktree is ready for the start slot).
- The phone INSTALL has STANDING approval: a short cleanliness claim whenever her unlocked phone is in hand, schedule-independent, never mid-someone-else's-claim.
