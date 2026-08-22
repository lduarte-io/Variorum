# Mobile Round 2 — THE SUCCESSOR'S FIRST ACTS

**Author instruction, 2026-08-22. Read this BEFORE the handoff's batch
map, and do these things BEFORE dispatching any build.**

Her words:

> *"ok the items found in the cold reviews should be batch 4.5. also
> leave a note for the next orchestrator that a number of items have
> been missed and before 4.5, it should start with a cold review over
> 1-4 to add to 4.5 with, and check through all notes and code changes
> for anything not yet included or that has been missed as well"*

---

## WHY SHE IS ASKING FOR THIS — read it, do not skim it

This round shipped seven batches. **Five of them were never
cold-reviewed** until the author asked, three times, whether things were
slipping. When the four owed reviews finally ran they found, in code
that had already been installed on her phone:

- **two BLOCKERs in the quick note** — one that *destroys her stored
  text* when she edits the first paragraph of a multi-paragraph capture,
  one that *wipes the box and the error message* when a save is refused;
- a **fan fence read from a deliberately frozen projection**, so a block
  with takes can be merged away mid-typing;
- the **one-row keyboard strip overflowing a 320 pt phone** by ~25 pt
  each edge;
- an **O(N²) main-thread walk still live** in the twin of the one that
  was fixed;
- **geometry pins that assert constants against themselves**, so a
  guarantee the record claims does not exist.

Separately, a cold consistency audit of the records found **19
findings**, including five work rows that were scheduled only in prose
and never built, and a KnownIssues row that does not exist.

**The lesson to carry, in one line: several diagnoses in this round were
traced by READING and never EXECUTED, and several were reported as done
when only their easy half was done.** Verify; do not inherit.

---

## ACT 1 — A FRESH COLD REVIEW OVER BATCHES 1–4 (before any build)

**Dispatch a cold reviewer over the round's whole shipped diff**
(`git diff 46ffa0c..<batch 4's tip>`), running `notes/REVIEW_PROMPT.md`
verbatim, briefed on nothing but the diff.

This is **in addition to** the per-batch reviews already run (§44, §45,
and batch 4's). Its purpose is the class those could not catch: **the
seams BETWEEN batches**, and anything a per-batch reviewer had no reason
to look at. Give it the round's known blind spots explicitly:

- a fix claimed complete whose twin survives elsewhere;
- a pin that asserts a stored value, or drives an API that bypasses the
  layer under test;
- a mechanism recorded from reading rather than running;
- copy or comments that describe superseded behaviour.

**Its findings JOIN BATCH 4.5.**

## ACT 2 — SWEEP THE NOTES AND THE CODE FOR WHAT WAS NEVER INCLUDED

Her second instruction, and it is separate from Act 1. **Read the round's
records and the shipped diff looking for things that never became work
at all.** Known starting points, all real and all currently unowned or
under-owned:

- **The stability survey's findings landed nowhere.** Her explicit ask
  was *"make sure the architecture of the app is looking solid —
  performance and stability are key."* The survey's headline verdict was
  reported to her; its contents were not actioned. Including: a **P2
  violation — `AppBootstrap.init` opens the store and runs migrations
  synchronously on the main thread before first paint**; the
  **`displaySlot`/`slots[i]` coupling that batch 7's reorder-takes work
  walks straight into**; a `nonisolated(unsafe)` tripwire; twelve
  unlatched `Task {}` doors in `MobileBlockMenu`; two un-hoisted
  mobile-local brains.
- **The crash trace has SIX unowned items**, including the **E1
  instrumented device experiment** — the only thing that settles where
  the crash's stale verdict comes from — and M1's own status, which is
  recorded as *high confidence, not proven*.
- **The quicknote survey's residues**, including the `isDirty` honesty
  trap and the fact that **the shelf has no keyboard avoidance while
  R26/R27 pin a dwelling text field into that layout**.
- **~20 investigation findings** in total, per the consistency audit's
  Tier 3.

**Anything found joins BATCH 4.5.** Anything genuinely out of scope gets
an owner named — a phase number or a project row — never a blank.

## ACT 3 — THEN BUILD BATCH 4.5

**Batch 4.5 = every finding from every cold review of batches 1–4, plus
Acts 1 and 2's additions.** Order it by consequence; the two quick-note
BLOCKERs come first.

The findings are recorded in:
- **§44** — batch 1b round 2 (1 MAJOR + 4 MINOR + 3 NIT)
- **§45** — batches 2, 3, 3b and the bar family (**2 BLOCKER**, 8 MAJOR,
  and the rest)
- **batch 4's review** — dispatched 2026-08-22; its record section is
  the next one written
- **`mobile-round-2-consistency-audit.md`** — the 19 document findings
  (most already remediated; check before re-doing)

## ACT 4 — AND FROM THEN ON, HER LOOP

**R28 binds every batch after this**: a dispatch is
**BUILD → COLD REVIEW → FIX → CONTINUE**, as one unit, with no human in
the middle and no orchestrator deciding afterwards whether to review.
The batch reaches her as a closed unit. That rule exists because the
alternative is what produced this file.
