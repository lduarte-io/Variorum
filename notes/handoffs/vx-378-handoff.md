# VX-378 — Castle, simplified: the author handoff (2026-10-18)

**For:** the author, after the gate. **Written by:** the VX-378 orchestrator (Fable), at the closeout. **Self-contained:**
everything here points at a repo file; nothing needs this session. **The PR:** https://github.com/lduarte-io/Variorum/pull/171
(`VX-378: Castle, simplified — the headless core rebuilt to the rules (closes VX-378, VX-305, VX-345)`) — OPEN, not merged.

## Your checklist (in order)

1. **The GO/NO-GO** — `notes/plans/vx-378-castle-simplified.md` §10: the six items with their evidence and **VERDICT: GO
   (2026-10-18T10:30Z)**. Your kickoff of VX-306 counts as your acceptance of it and of the bundle (your word 2026-10-17:
   *"I'll have my kickoff of VX-306 start with merging the PR if I approve it"*).
2. **The PROVISIONAL bundle** — `notes/QUESTIONS.md` **#231**. After your morning sitting of 2026-10-18 the items that still
   stand as built and want only your eye are: P-VX378-U1-1 (a missing memory item → a fresh device ID), U1-2 (leaving an
   account asks no secret), U2-1 (Replace All Keys re-keys the library only), U2-3 (the join's "here they are" when the
   passphrase was typed), U2-4 (Make this my library's new library is local; the device's settings carry), U2-5 (a key
   door's one-write window with the vault unreachable rolls back), U3-1 (the first passphrase is the reset door's Standard
   road), U3-2 (an Apple ID change moves every device of yours), U4-4 (rule 12's catch-up on an Always-ask device), U4-5
   (rule 21's notice at its edges), U4-6 (rule 21's offer at its edges). Everything else is RULED in your words (U2-2, U4-1,
   U4-3, FD-1…3, and today's O1-1, U4-7, O2-1, O2-2) or CLOSED (U4-2).
3. **The lifecycle page** — `notes/plans/vx-266/castle-lifecycle.html` (open it; it is rendered from the fixture the
   lifecycle test asserts against; zero diffs). Stages 6, 8, 9 and 14 carry your rulings of the last two days.
4. **The rules document** — `notes/CastleRules.md`: amended at your word only — rules 4, 5, 11, 12, 17, 21, 25 — each
   listed in its status line. Today's: rule 5's quiet-road clause; rule 11's closing pointer at rule 25; rule 25's honest
   limit of the entry sweep (your wording to adjust if you like).
5. **Merge PR #171 as a MERGE COMMIT** (never squash). It closes VX-378, VX-305 and VX-345. If this session is still
   open, say "merge" and it merges and does the housekeeping (the in-flight row, the worktree and branch, the board
   snapshot, Linear, the stage log's slot note); otherwise VX-306's kickoff STEP 0 does it. Then, in a fresh session:
   `/architect-phase vx-306`. Tell that session two things the plan cannot know: the stage coordinator is oct18coordinator
   (every `xcodebuild test` and dev-store walk needs a held claim — announce before the first), and VX-390 (the
   library-ID stamp) is in its first unit beside VX-386.
6. **Not this phase's, named so you don't look for them:** no app change shipped (headless), so no `/Applications`
   refresh, no stage window, nothing mobile-visible; the server's `key_vault` change is VX-307's SyncSpec §12 lockstep
   (the mirror deploy only at your explicit go); the guide and settings copy are VX-379's.

## What this phase did (one paragraph)

The headless protection core under `Sources/VariorumCore/Protection/` was cut to `notes/CastleRules.md` (U1: the
migration, the legacy readers, the anchor, the stuck leave, the repair layer, the family tree, the hardware marker, the
old shared key, Re-link, the gift machinery and the route finder beyond one sentence — 41% of the source gone), the
rules' additions built (U2: words at birth, the passphrase facts, one pair per account, the vault's account side
replaced whole with the earlier-sync-keys list and the mode flag, Look inside, Make this my library, the plain device
ID, rule 27's refusal; at your ruling the NOTICE and the key-file OFFER instead of detect-and-refuse), the lifecycle
page proved fixture-first by a fourteen-stage scenario and regenerated from the fixture (U3), the promises rewritten to
the rules with the floor you ruled, the census classes closed, the discovery run and the gate soak on the final tree
(U4 and its resumption; the Opus pool died twice on the session limit and the orchestrator finished the gate and its
three fixes under the budget-death road). **The ladder:** four Fable rounds, 0 BLOCKER / 0 MAJOR throughout — round 1
2m/3N (fixed), round 2 0m/2N (fixed), round 3 0m/2N over the gate's two fixes, round 4 1m/1N over the checker fix; the
three test/DEBUG-only residues of rounds 3–4 deferred as VX-386 so the soaked tree stayed the final tree.

## The gate (§10) — GO

| item | evidence |
|---|---|
| 1 · the soak on the FINAL tree `66f7561e1` | discovery seeds 21–40 green (Debug); gate seeds 1–20 green in Debug (899,918 steps, mean 400 s/seed) AND `-c release` (same seeds, mean ≈ 300 s/seed); 2.7 million generated steps, zero promise violations |
| 2 · the suites | protection set Debug 388/149; release green minus VX-380's one Sync test; the full core suite 3,160/405 |
| 3 · fixed scenarios + mutation pins | green on the final tree |
| 4 · the ladder closed | four rounds, 0B/0M throughout (§9) |
| 5 · the rules checklist | 27 rows, each with its proving tests or its honest owner |
| 6 · the lifecycle page | byte-equal to its fixture (`LifecyclePageTests.theCommittedPageIsTheRenderedOne`) |

Three attempts: **attempt 1** (tree `4a4af3164`) — Debug seeds 2 and 3 red: a crashed Make this my library stranded
after a keychain wipe (fix: a pre-commit resume with the wrong secrets rolls back — P-VX378-O2-1), and a rolled-back
stretch's silent item surviving Castle entry (fix: the entry sweep reads the catalogue — P-VX378-O2-2); each traced by
replay, pinned red-on-old, read by a fresh Fable round 3. **Attempt 2** (`c84375010`) — the discovery run green; Debug
seed 8 red: a CHECKER fault (promise 1 lacked rule 10's lagging-device exemption), pinned, fixed, read by round 4.
**Attempt 3** (`66f7561e1`) — everything green. One machinery fault on the way: the soak script's release leg never
ran (zsh does not word-split an unquoted scalar), found and re-run whole from a release-only script; the Debug results
stood because the tree had not changed (§10 records it).

## The rulings you made during the phase (each verbatim in the plan's §8)

- Both secrets at Use Castle / Use Standard (P-VX378-U2-2); *"whenever someone has their passphrase, they can easily
  regenerate the 12 words, so this isn't even particularly onerous."*
- FD-1 accepted · FD-2 → rule 25's sentence · FD-3 accepted.
- The promise shrinks to the FLOOR; rule 4 in your final words (*"of the same library makes it clear without making it
  seem like an exception"*); no earlier masters kept.
- Make this my library carries NO keys (your earlier yes superseded); the posture of now always; no choice at the door.
- Rule 21: the fingerprint and the wrapped copy; the NOTICE instead of the refusal (your two strings verbatim); the
  key-file OFFER naming where it found the file; P-VX378-U4-2 outside the promise.
- The standing principle: *"not wanting to have to tell users any sort of weird exception."*
- **The morning sitting (2026-10-18):** rule 5 reworded (O1-1); roll back as built (O2-1); no notice for a same-key older
  copy (U4-7); the catalogue sweep stays with the honest limit in rule 25 and rule 11's pointer (O2-2) — your north star
  recorded: *"once you've moved into castle, no amount of the previous key file can get you into the current writing"*;
  the library-ID stamp returns as deferred work in VX-306 (VX-390, Pre-launch at your word).

## Filed tickets, by priority

- **Medium, Pre-launch:** VX-390 — stamp the library ID on keychain items so Castle entry sweeps this library's quiet
  roads by ownership (VX-306 U1, beside the production keychain leaf; the design paragraph is in the VX-306 plan).
- **Medium:** VX-386 — VX-378's three deferred ladder residues (the DEBUG-only resume catch, the synced promise-1 oracle
  arm, L1's header line); VX-306's FIRST commit.
- **Low, Parked (Test-only):** VX-380 — a Sync attacker test uses DEBUG-only Argon2 parameters, red under `-c release`;
  outside Protection.
- Triaged at close: VX-378/VX-305/VX-345 Done at the merge; VX-306/307/308/309 re-pointed to the rules (the VX-305
  session's 2026-10-16 Linear pass + this phase's hand-forwards); VX-379 open (Wording, the standing item).

## Machinery notes (for the next orchestrator)

- The Opus implementer pool died on the session limit twice this phase; the budget-death road worked: the orchestrator
  ran the gate soak and applied the ladder's and the gate's small fixes itself, product-framed; a fresh Fable reviewer
  per round. `notes/plans/vx-378-orchestrator-handoff.md` §6 carries the lessons (incl. the zsh scalar and the
  conflict-marker slip at the pre-PR merge of `main`, fixed in the next commit).
- The soak scripts and logs live in the session scratchpad (`gate-runs-5.log`, `soak3.sh`, `soak3-release.sh`); the
  plan's §10 tables are the evidence; the scripts are also in `notes/plans/vx-378-gate-soak.sh` and
  `notes/plans/vx-378-gate-soak-release.sh`. The scratchpad is deleted after the merge (the 13x rule).
- `swift test` with a wide `--filter` sweeps `MultiTenantSyncAttackerTests` in under `-c release` — that is VX-380,
  not a Protection red.

## MOBILE PARITY: nothing mobile-visible (headless phase).
