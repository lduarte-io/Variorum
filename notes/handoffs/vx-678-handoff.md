# VX-678 handoff — Run: Trash, purge & resurrection

**YOUR CHECKLIST (everything that needs your eyes or hands; the rest of this file is the record):**

1. **The #250 bundle (QUESTIONS)** — the run's PROVISIONALs, all built to the most spec-defensible option and working now; rule or ratify at leisure:
   - **P-670-WF2 (the one real taste call):** the Trash names an untitled note by its DATE ("2026-10-28 note") — a deliberate 13l decision — while the Library leads with first words (VX-580), so six deleted quick notes read identically and defeat the multi-select. Options: (a) first words lead, date as the secondary fact; (b) keep the date-name (shipped today); (c) date-name stays the row's name, first words join as a quiet second line. Nothing was changed pending you.
   - **P-671-1..6 (multi-select's shapes):** Put back order (books → notes/groups → blocks → originals); an original whose family came back in the same press is not re-placed; partial results speak in the refusal slot with both facts; bulk Delete Now is one atomic intent batch; the bulk bar appears at 2+ picked; the wording (incl. "preserved original(s)" — three spellings today, the round-1 NIT) is yours to tune.
2. **Your Sherlock cleanup (the run's reason):** the deletes stick only when BOTH devices carry the fix — the Mac at this release, **the phone needs its build refreshed too** (the defense ran on whichever device received the tombstones). After both: delete the copies you don't want; they stay deleted. Any stale purge intents from your earlier Delete Now presses are safe either way — the janitor's staleness net was verified green (a revived family's pending intents complete unhonored; nothing live is ever purged).
3. **The release** (you ruled: one release after VX-678 + VX-677 + PR #204, run by the last merger): the notes carry BOTH local-only migration lines — **v1_34** (VX-648's dead-placement index) and **v1_35** (this run's sweep of the retired defense's bookkeeping markers). Notes drafted for you at the release window per the standing rules.
4. **Born tickets, grouped (all Low · Backlog):** VX-685 (MCP harness wall-clock flake under load, 2 sightings folded), VX-690 (test-host exit crash in swift-testing's encoder, related VX-661), VX-691 (the test host still exits over an in-flight dev-store sweep — VX-657's accepted residual face, cheap exit-hook fix shape), VM-33 (the phone's Trash has the same empty-flash the Mac just fixed). Plus VX-689 (the JOIN-road twin case, yours/coordinator-minted, "not a big deal").
5. **VX-633/#204** is absorbed and mid-gates (suites-a ALL GREEN with both reverts red; B1 full-target + sims and B2's reset walkthrough remain, then its ladder and merge — it rides the release at your word).

---

## What shipped (the acceptance units' outcomes; the full record is `notes/plans/fixes/vx-678-trash-purge-resurrection.md`)

- **VX-669 — the resurrection is dead.** The sample-library dedupe's defense leg is removed whole (her ruling, option B): a deliberate cross-device delete of a seeded book is never second-guessed. Pinned red-on-old in the two-client harness on her exact scenario (the settled both-edited pair; the single-delete-beside-a-live-twin arm) — on the old code the deleted copies returned alive on both devices, including the deleting one, exactly her report. The crossing race's accepted cost: a visible, recoverable Trash trip, bytes never lost (ride-the-row untouched). Migration **v1_35** (local-only) sweeps the leg's orphaned markers.
- **VX-657 — the quit race is guarded.** Purge sweeps are cancellation-aware between families; the quit door quiesces the purge road and sync chain on the proceed path only; `stop()` (lock/sign-out) cancels without refusing future sweeps. The real ⌘Q was walk-proven clean (~0.14 s, no dialog, no crash report). The test host's runner-exit face remains by construction → VX-691.
- **VX-654 + VX-653 + VX-670's roots — the quadratic class is gone.** Four lineage reads rewritten O(L) (originalsStrandedBy 23 s → 88.6 ms; strandedOriginals 27.6 s → 108.7 ms; originFamilyClocks 18.4 s → 70.3 ms at 600 seam rounds; preservedOriginals was already fixed by v1_34 — dismissed hollow with guard pins). Plus the observation fix: the open Trash no longer re-runs its fetch on the writer inside every commit (the named-region road; the phone inherits it).
- **VX-670 — her three roads, live-verified:** Trash listing 28.5 s → rows at +0.48 s in the walk; Put back 5.5 s → +0.1 s receipt; Delete Now 11.3 s → rows gone +0.64 s. The walk also caught the ~0.4 s false "The Trash is empty." flash — fixed (the empty words wait for the first value; pinned).
- **VX-671 — multi-select:** ⌘/⇧-click picks, the bulk row at 2+ with counts by kind, bulk Put back and bulk Delete Now through the existing per-row roads (no new core operation), honest partial-result refusals (a forever-gone original is never counted "put back").
- **The ladder:** two rounds, no round 3. Round 1: 1 MAJOR (a pin red for the wrong reason — corrected, the true red re-observed at 6 issues) + 3 MINOR + 1 NIT, all applied; round 2: all fixes clean, the MAJOR's red independently reproduced by the fresh reviewer. Every pending app pin ran green at the pins claim (21/3) with both revert observations red exactly as predicted.

## MOBILE PARITY
The query rewrites and the observation fix carry to the phone through shared core (its Trash gets the same speedups free); Mac-only: multi-select, the empty-flash fix (the phone's twin flash is VM-33), the quit quiesce (no ⌘Q exists there). MobileSoul row lands at the merge (PENDING: PL-6x number from latest main).

## Canon deltas (applied on the branch at the merge moment, latest main merged in first — the two-file shape; exact texts in the run record's ledger row 10 notes)
- SyncSpec §7, the sample-library dedupe bullet: the RUN B defense parenthetical → the removal (VX-669, pointer to the run record).
- QUESTIONS #143(b): the bounded-revival ruling superseded — the defense leg removed at VX-678.
- SurfaceContracts, the Trash lines: multi-select + bulk doors + the honest empty state (+ pointer).
- AppSpecRecord: the dated entry (her words, the ladder, the cast, the born tickets, the PR).
- `Tools/canon-size` at the closeout: **126,641 total (harness limit 150,000, headroom 23,359)** — no crossing.

## PENDING at the merge moment
PR #205 · merge SHA: in memory + the run ticket (post-merge) · member tickets → Done: PENDING · in-flight row retired + closeout paragraph: PENDING · #250 landed (numbering verified on latest main) · MobileSoul PL-64 landed · evidence cleanup (walk screenshots, logs, DerivedData, the dev-store copy after merge): PENDING.
