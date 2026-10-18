# VX-378 — Castle, simplified: the author handoff (2026-10-17)

**For:** the author, the morning after the overnight run. **Written by:** the VX-378 orchestrator (Fable), at the
closeout. **Self-contained:** everything here points at a repo file; nothing needs this session.

## Your checklist (in order)

1. **Read the GO/NO-GO** — `notes/plans/vx-378-castle-simplified.md` §10 (the six items with their evidence; the
   verdict: GATE_VERDICT_PENDING). Your kickoff of VX-306 counts as your acceptance of it and of the bundle below (your
   word 2026-10-17: *"I'll have my kickoff of VX-306 start with merging the PR if I approve it"*).
2. **The PROVISIONAL bundle** — `notes/QUESTIONS.md` under the VX-378 heading (numbered at the merge): the ones that
   stand as built and want your eye — P-VX378-U1-1 (a missing memory item → a fresh device ID), U1-2 (leaving an
   account asks no secret), O1-1 (rule 5's wording after a Standard Replace All Keys — one sentence for the rules, yours
   to accept), U2-1 (Replace All Keys re-keys the library only), U2-3 (the join's "here they are" when the passphrase
   was typed — a face sentence), U2-4 (Make this my library's new library is local; the device's settings carry), U2-5
   (a key door's one-write window with the vault unreachable rolls back — a stated limit), U3-1 (the first passphrase
   is the reset door's Standard road), U3-2 (an Apple ID change moves every device of yours), U4-2 (CLOSED by your
   ruling — outside the promise), U4-6/U4-7 (the resumption's — RESUMPTION_PROVISIONALS_PENDING); the RULED ones carry
   your words (U2-2, U4-1, U4-3, FD-1…3).
3. **The lifecycle page** — `notes/plans/vx-266/castle-lifecycle.html` (open it; it is rendered from the fixture the
   lifecycle test asserts against; zero diffs). Stages 6, 8, 9, 14 carry your rulings of the last two days.
4. **The rules document** — `notes/CastleRules.md`: the amendments made at your word only (rules 4, 5, 11, 12, 17,
   21, 25) are listed in its status line; nothing else moved.
5. **Merge the PR** `VX-378: …` as a MERGE COMMIT (never squash) — PR_URL_PENDING. It closes VX-378, VX-305 and
   VX-345. Then `/architect-phase vx-306` — its kickoff message's STEP 0 does the rest (in-flight row, worktree and
   branch removal, the board snapshot, Linear).
6. **Not this phase's, named so you don't look for them:** no app change shipped (headless), so no `/Applications`
   refresh, no stage window, nothing mobile-visible; the server's `key_vault` change is VX-307's SyncSpec §12 lockstep
   (the mirror deploy only at your explicit go); the guide and settings copy are VX-379's and every Castle face
   phase's standing acceptance item.

## What this phase did (one paragraph)

The headless protection core under `Sources/VariorumCore/Protection/` was cut to `notes/CastleRules.md` (U1: the
migration, the legacy readers, the anchor, the stuck leave, the repair layer, the family tree, the hardware marker, the
old shared key, Re-link, the gift machinery and the route finder beyond one sentence — 41% of the source gone), the
rules' additions built (U2: words at birth, the passphrase facts, one pair per account, the vault's account side
replaced whole with the earlier-sync-keys list and the mode flag, Look inside, Make this my library, detect-and-refuse
→ at your ruling the NOTICE and the key-file OFFER, the plain device ID, rule 27's refusal), the lifecycle page proved
fixture-first by a fourteen-stage scenario and regenerated from the fixture (U3), the promises rewritten to the rules
with the floor you ruled, the census classes closed, the discovery run and the gate soak on the final tree (U4 + its
resumption). The ladder: LADDER_SUMMARY_PENDING.

## The rulings you made during the phase (each verbatim in the plan's §8)

- Both secrets at Use Castle / Use Standard (P-VX378-U2-2); *"whenever someone has their passphrase, they can easily
  regenerate the 12 words, so this isn't even particularly onerous."*
- FD-1 accepted · FD-2 → rule 25's sentence · FD-3 accepted.
- The promise shrinks to the FLOOR; rule 4 in your final words (*"of the same library makes it clear without making it
  seem like an exception"*); no earlier masters kept.
- Make this my library carries NO keys (your earlier yes superseded: *"get rid of it completely for being weird"*);
  the posture of now always; no choice at the door.
- Rule 21: the fingerprint and the wrapped copy; the NOTICE instead of the refusal (your two strings verbatim); the
  key-file OFFER naming where it found the file; P-VX378-U4-2 outside the promise.
- The standing principle: *"not wanting to have to tell users any sort of weird exception."*

## The gate (§10) — GATE_TABLE_PENDING

## Filed tickets, by priority

- **Low:** VX-380 (Parked, Test-only) — a Sync attacker test uses DEBUG-only Argon2 parameters, red under
  `-c release`; outside Protection; the VX-345 class one test over.
- Triaged at close: VX-378/VX-305/VX-345 Done at the merge; VX-306/307/308/309 re-pointed to the rules (the VX-305
  session's 2026-10-16 Linear pass + this phase's hand-forwards); VX-379 open (Wording, the standing item).

## Machinery notes (for the next orchestrator)

- The Opus implementer pool died on the session limit twice this phase; the budget-death road worked: the orchestrator
  ran the gate soak and applied the ladder's small fixes itself, product-framed; a fresh Fable reviewer per round.
- The soak scripts and logs lived in the session scratchpad (deleted at closeout per the 13x rule); the record's
  tables are the evidence.
- `swift test` with a wide `--filter` sweeps `MultiTenantSyncAttackerTests` in under `-c release` — that is VX-380,
  not a Protection red.

## MOBILE PARITY: nothing mobile-visible (headless phase).
