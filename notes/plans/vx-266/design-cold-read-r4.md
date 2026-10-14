# Cold read of the final design and plans — round 4 (VX-266): the record and the dispositions

**What ran.** Round 4 was one fresh Fable reviewer, run as the design owner's subagent at her word: *"do the next
review with your own fable subagent - if it stalls, opus on max instead."* It didn't stall. It read the design, the
phase-1 plan, the key maps with their generator, and the companion explainer, at commit `8f62d4a2` — after round 3,
its late extra read, and every fix both caused had been settled with the round-2 Fable reviewer (`variorum-vx-266-63`).
Its report is `design-cold-read-r4-fable.md` (`4354de44`), unedited: **0 BLOCKER · 0 MAJOR · 1 MINOR · 1 NIT.**

**The ladder is closed.** Her process: *"then you can run another opus max cold review if any more majors were found
(that would be the fifth round). stop at that point, if it's needed. if no more majors come back after the next ladder
then ok."* Round 4 found no major, so there is no round 5.

**The overnight calls, checked by a cold reader.** The calls made provisionally overnight, at her word and while she
slept, were listed in the design's §9 and handed to round 4 as ordinary design text. The reviewer traced each and found
that each holds mechanically and each is correctly left to her:
- the follower's anchor locked under the secret typed at its follow — a birth-time lock under a non-Apple secret,
  strictly additive, promise 13 untouched;
- "off in Release" read as the app's wiring — consistent with the phase-1 plan, the literal option named;
- the Touch ID re-arm question only after a press fails on an item that exists — it closes the deletion and
  rollback re-arm attacks;
- a new device identity on Always ask;
- the real-scope rehearsal left open;
- today's bugs live in Release until the switch.

That is the check her mandate wanted on the night's own judgment. Her confirm is still asked for each, in the
handoff.

**How it settled.** Both findings were traced and are real; neither is disputed. The round-2 Fable reviewer, which has
the final say at her word, adopted both dispositions as drawn and added three riders, all landed. No disagreement was
left open.

## Dispositions

| # | finding | disposition | where |
|---|---|---|---|
| MINOR | Today's finish path for an old crashed act is kept one release after the switch, but a store can skip that release and meet the migration with an old marker and nothing to finish it | **Fixed with the reviewer's option (b).** Keeping today's writing runner forever would contradict "the deciding and writing roles die at the switch", for exactly the code where lingering write-capable code is most dangerous. So the marker's **read and clearing check stay forever**, read-only: the marker lives inside the library file, and copies carrying it exist forever, the same reason the mode reader stays (the round-2 Fable reviewer's rider). The **finish runner stays one release**. Past it, step 1 **resolves an old marker from disk**. If the library still opens under its old key and the new key never landed, the act never happened; otherwise its commit happened. Either way the marker is cleared, and the migration carries on under its usual guards — the mode from the vault, else not yet confirmed, with no custody repair until it is — and its own passes do what the old act left undone. **The why, stated in the design** (the reviewer's rider): an old build's rotation still on the server carries no Apple key id, so the new engine reads it as a Castle rotation, which any device completes with no Apple copy. That composes with the three-state rule and needs nothing new. **Fixed scenario** with three shapes (the reviewer's rider): never happened; commit happened; a synced store whose old rotation still stands on the server | §3.13 step 1, §3.15, §4.1; plan §2, U1, U4; the target map's migration lede and step |
| NIT | VX-310's phase column read "2", but phase 4 owns its re-arm and didn't list it | **Fixed:** VX-310's phases are "2, 4", and phase 4's members gain "VX-310 (the re-arm)". It was a survivor of the owner's own earlier revert | §5, §6 |

## The settlement with the round-2 Fable reviewer

Its adjudication, in its words: *"ADOPT BOTH as you drew them, and the ladder is closed — 0 majors at round 4 means no
round 5, per her rule."* On the minor: *"your resolve-from-disk logic is sound end to end: the never-happened arm is
VX-235's existing proof condition verbatim; the commit-happened arm's leftover post-commit work is all subsumed by the
migration's own passes ... and the orphaned-rotation arm composes beautifully with the three-state rule."*

**How the reports were handled**, as across every round: recorded unedited; every finding traced to a mechanism before
anything changed; fixed where real; what only she can decide handed to her with its options and reasons; each change
settled between the two sessions before the next step.

**The commits:** the report `4354de44`; the fixes and this record follow.
