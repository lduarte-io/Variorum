# RUN B — the live two-device round: the morning handoff

**Written 2026-09-22 (night) at the author's instruction** — she sleeps through the run's tail;
a fresh morning session (or she alone, with this checklist) runs the live round and records it.
**This document is self-contained: a session with ONLY the repo can finish the run from it.**
Drafted with PENDING slots (the resiliency addendum-7 shape); the overnight tail fills them.

---

## YOUR CHECKLIST, LILLIAN (the short version — the rest of this file is the session's)

1. ☐ Launch **/Applications/Variorum.app** (your real store) and let it sit a minute.
2. ☐ Look at the sync row: it should read **"Synced \<time\>"** with NO warning line. (A new
   honest face exists since this run: *"Sync incomplete — some changes haven't arrived yet"* —
   you should NOT see it.)
3. ☐ Make one small edit — e.g. a quick note titled `run b live — mac`.
4. ☐ On your **phone** (your current build is fine — see THE MARKER FACT below): open Variorum,
   let it sync, confirm the Mac's note arrived; add `run b live — phone`.
5. ☐ Back on the Mac: confirm the phone's note arrived. That's convergence, both directions.
6. ☐ **OPTIONAL — your held decision:** run **Replace All Keys** (Settings ▸ Protection) on the
   Mac with the SAME passphrase, then watch the phone: it should follow with **ZERO passphrase
   prompts** — the exact annoyance you reported on 2026-09-07, cured by this run (17l item 5).
   A plain round (steps 1–5) is fully sufficient evidence if you skip this.
7. ☐ Tell the morning session what you saw (or paste screenshots) — it records the evidence and
   closes the run.

**If ANYTHING looks wrong:** nothing is destructive by design — sync refusals leave the outbox
intact and the cursor unmoved. Don't fix anything; note exactly what the sync row says (and the
Data Safety pane's "Received everything… through change #N" line) and hand it to the session.

---

## THE MARKER FACT (why your phone's CURRENT build is fine)

This run deployed NOTHING server-side — the lockstep marker stayed **8**, so every existing
build interoperates. The run's engine changes are client-side and ride whichever device has
them; a Mac(new) ⇄ phone(old) round is genuine acceptance evidence. Even the optional Replace
All Keys works with the old phone build: the 17l-item-5 fix lives on the ROTATING side (the
Mac's ceremony now keeps the vault's KDF descriptor when the passphrase is unchanged), so the
phone's shipped descriptor-equality gate passes with the key it already holds. Refreshing the
phone build is good hygiene, not a gate — the overnight tail attempts it only if the device is
connected; otherwise install it whenever convenient (Xcode ▸ your usual run-to-device road).

## STATE AT HANDOFF (filled at the overnight tail — PENDING until then)

- Ladder outcome: **PENDING** *(round 1 returned 4 MAJOR · 2 MINOR · 2 NIT · 0 BLOCKER — the
  fix pass and later rounds run overnight; this slot gets the final tally and dispositions.)*
- Finals: core **PENDING** · full Mac **PENDING** · iOS build **PENDING** · mobile **PENDING**.
- A1 backup: **PENDING** (name + verification).
- `/Applications/Variorum.app`: **PENDING** (old hash → new hash; built from commit …).
- Phone build/install: **PENDING** (installed overnight, or left to the morning with the reason).
- Git head at handoff: **PENDING**.

## FOR THE MORNING SESSION (paste-ready kickoff below)

**Your job:** verify the state slots above against the repo (never trust — `git log`, the run
plan's CLOSEOUT, the finals evidence), walk her through the checklist (or receive her report of
it), then RECORD the evidence and CLOSE the run's one open acceptance leg:

1. READ FIRST: `CLAUDE.md` + the canon it loads · `notes/plans/run-b-sync-correctness.md` WHOLE
   (the run's ONE record — ledger, batch records, adjudications, ladder, closeout) ·
   `notes/plans/pre-beta-standing-fix-runs.md` (RUN B's section) · this file.
2. The evidence to record (append to the run plan's CLOSEOUT — LIVE ROUND slot): both devices'
   sync-row states, the two test notes present on both sides, no stall/deferral warning, the
   cursor line advancing; if she ran the optional re-key — the phone's zero-prompt follow,
   stated plainly. Screenshots if she took them (gitignored dirs).
3. Flip the acceptance line in the CLOSEOUT, and the "LIVE-ROUND LEG PENDING" lines in
   `notes/plans/phase-17-standing-fixes.md`'s 17i/17d dispositions (the closeout marked them
   pending precisely so you can flip them without re-deriving anything).
4. Commit + push (pathspec-limited; NO commit trailers — her standing rule). Update the memory
   file `variorum-phase-9-run-state` (RUN B fully closed; 13y next at her word — NOT yours to
   start).
5. If the round SURFACED anything: record it verbatim in the run plan, file it as a 17/QUESTIONS
   candidate with an owner, and tell her — never fix sync code in a morning session without the
   rider's cast (Fable + a cold review).

**Paste-ready kickoff for the morning session:**

> You are closing RUN B's one open acceptance leg — the live two-device round. Read, in order:
> `CLAUDE.md` + its canon load; `notes/plans/run-b-sync-correctness.md` WHOLE;
> `notes/handoffs/run-b-live-round-handoff.md` (your instructions are its "FOR THE MORNING
> SESSION" section — follow it exactly). Verify the handoff's state slots against git before
> relying on them. The author runs the checklist on her devices; you record the evidence, flip
> the pending acceptance lines, commit + push, update memory. Sync code is FENCED (the Sync/
> rider) — anything the round surfaces is recorded and owned, never fixed by you. 13y is next at
> her word and is NOT yours to start.
