# DESIGN MEMO — what wins when devices disagree (the sync reconciliation posture, in plain words)

**Provenance:** written 2026-08-31 at the pre-13u round's tail at the author's instruction, after
the final ladder's run of `Sync/` findings prompted her question. **Owner: entry 17i** in
`notes/plans/phase-17-standing-fixes.md` — her ruling: *"this is really hunting for bugs +
discrepancies + issues in the implementation of sync across devices, so I think it's fine to have
there."* This memo states the POSTURE as canon rules it (SyncSpec §§5–7, §12's 13j event;
OverallModel S2/S5), names what is UNSETTLED, and carries the probes 17i runs. Nothing here is
built or run by the pre-13u round (her word: *"I don't want to run the probe right now, I'd rather
that we just finish this phase and its ladder out now"*).

---

## ⚠️ UNSETTLED — the probes to run FIRST (17i's opening act; record each answer here)

Run as two in-memory clients against the in-process `FakeSyncServer` (`Tests/VariorumCoreTests/
Support/`), in PRODUCTION'S round shape — pull → push, pushes chunked at `batchSize` via
`FaultInjectingTransport` where a split matters — never the harness's convenience order (the
pre-13u ladder's own lesson: round-1 pins passed on sequences production never runs).

**P1 — her scenario: delete-vs-edit-plus-new-take.** Both devices hold note N (one block, one take
T1). Sync stops. Phone: `deleteContainer(N)`. Laptop: `autosave(T1, newText)` + `branchVariant`
(a new take T2). Sync resumes, laptop first (pull → push), then phone. ASSERT and RECORD: N is in
the Trash on both (tombstone wins, `deleted_at` matching); T2 exists on both, tombstoned with N's
exact stamp (rides Put back); **T1's `working_text` on the laptop after the merge — the laptop's
NEW text or the phone's OLD text?** (the §6 rescue rule is written for a take deleted while its
block lives; a whole-note tombstone is the case to settle). Then `restoreContainer(N)` on the
laptop: what comes back, and does it converge to the phone?

**P2 — the same, but the phone's deletion was PURGED (past 30 days) before sync resumed.** The
purge horizon (13j — `sync_horizon()`, 60-day drop-out) should HOLD the purge while the laptop is
a live device: assert the phone's janitor does not purge N until the laptop has pulled the
tombstone. Then the DROP-OUT case: mark the laptop silent past 60 days, purge on the phone, return
the laptop with its dirty T1 + new T2 → its pushes meet the `purged` refusal; **what does the
returner do LOCALLY with T1/T2 — drop, keep as local-only, resurrect?** (the "say-so returner",
13j's client road — its exact handling of edited purged rows is the unsettled corner).

**P3 — edit-vs-edit on one take** (the S5 case): both devices edit T1 offline; sync → the loser is
a conflict card labeled `'conflict'` on the same block; assert no text lost on either side.

**P4 — the round-shape sweep:** re-run every existing convergence suite's core scenarios with the
production round shape + a chunk split at each registry boundary the scenario crosses; any pin
that passes only in the harness's order is a finding.

**P5 — three traced observations from the pre-13u ladder's round-2 fix session (recorded there,
not fixed — outside every finding's letter):** (a) the tag-collision repair orphan-stamps
applications arriving AFTER the duplicate tag dies instead of re-pointing them — the later-arriving
copy's stories lose the reserved tag on both devices; (b) a double-retirement race when the
classifying device's push is delayed past the other device's pass and the evidence changes between
the two; (c) the echo pull costs one extra round per two-copy meeting. Each is a probe here first. **P5(a) was RE-CALIBRATED at ladder round 3 (2026-09-01): it is the GENERAL `tag.path` repair not honoring its own §7 sentence for applications arriving after the duplicate died — pre-existing since Phase 5, MAJOR-class, promoted from probe to 17i's FIRST FIX ITEM (KnownIssues row filed); the pin is stated there.**

---

## The five rules (the posture as canon states it)

1. **Deletions win — into the Trash, never the void.** A tombstone anywhere is a tombstone
   everywhere (§6); the 13j Trash holds it 30 days with Put back; cascades carry the parent's
   exact stamp so Put back revives the family; the orphan repair (§7) makes cascades cross devices.
2. **Text edits never clobber.** The one mutable field, `working_text`, resolves a race as a NEW
   variant (S5 — a card in the fan), never an overwrite; a text edit racing its own take's
   tombstone is rescued as a conflict variant while the block lives (the "deleting an edit nobody
   chose to lose is the one forbidden outcome" ruling). Whole-note tombstones: P1.
3. **New things always arrive.** Inserts are never lost; a new row arriving under a locally-dead
   parent joins the parent's cascade with its exact stamp (rides the Trash, comes back with Put
   back).
4. **Structure converges deterministically, never by clock.** `server_seq` is the only ordering
   authority; positions are jittered fractional keys (no renumber); every live-unique index has a
   deterministic keeper repair (I2 move/move → higher seq; tag paths/edges/pairs → smaller id;
   I10 races → resurrect the highest seq); metadata (titles, locks, pointers) is server-version-
   wins CAS — a lost rename is the worst case, never corruption. This round added two furniture
   repairs (the daily-Journal keeper; the sample-library pristine-copy dedupe — §7) and the ladder
   found their harness-vs-production gaps (recorded in the pre-13u plan's ladder records).
5. **Purge only past the horizon.** A tombstone is physically removed only after every live device
   has seen the deletion (13j — S2's one bend); a device silent 60 days drops out; the purged-ids
   ledger fences returners with a typed `purged` refusal before CAS. The returner's local handling
   of its edits of purged rows: P2.

## The scenario table (plain English; ✔ = ruled and pinned · ? = a probe above)

| devices disagree on… | what happens | status |
|---|---|---|
| phone DELETES a note; laptop EDITS its text + adds a take | note → Trash on both; the new take rides the Trash stamp; the edited text of the old take: **P1** | ? |
| the same, phone's deletion PURGED before sync resumed | the horizon holds the purge while the laptop is live; past the 60-day drop-out the returner meets `purged` — local handling **P2** | ? |
| both EDIT the same take's text | conflict-as-variant: the loser becomes a `'conflict'` card, nothing lost | ✔ (Phase 5) |
| one DELETES a take, the other EDITS it (block lives) | the edit is rescued as a conflict variant, then the tombstone applies | ✔ (Phase 5) |
| both DELETE different last takes of one block (I10) | the highest-seq take resurrects, labeled `'rescued'` | ✔ |
| both MOVE the same block | the higher-seq placement wins; the other is tombstoned | ✔ |
| both RENAME the same note/book | server-version-wins CAS — one rename lost, recorded class | ✔ |
| both DIVIDE the same block offline | duplicated content (B₁C₁B₂C₂) — documented, not repaired | ✔ (documented) |
| both mint a daily Journal offline | the keeper repair (this round; the successor design is the daily-identity memo, 13y) | ✔ interim |
| both seed the sample library offline | the pristine-copy dedupe (this round; the late-registry leg residual → KnownIssues, 13y) | ✔ interim |
| a device restored from an OLD backup re-keys | the T1 recency warning (counts + dates) before the re-push — warn, not refuse | ✔ (wave 2a) |
| an account-owned device never synced cleanly | the seed gate declines (never duplicates); content arrives when sync lands | ✔ |

## The harness-realism gap (17i's structural item)

The convergence suites run the harness's convenience order (push then pull; whole outboxes in one
push). Production runs **pull → push** with **200-row chunks, each its own server transaction**,
and devices interleave. Round-1 fixes this round passed their pins in the first order and failed
in the second (ladder R2-1/R2-2). 17i makes the production shape the DEFAULT of the harness (a
`productionRound(client)` helper the suites use; chunk splits at registry boundaries as a sweep).

## Her words (verbatim, so the entry inherits her intent)

*"seeing all these sync rounds is making me wonder what happens if you had the same store, then
sync stopped working, and on two different devices you made edits (say on your phone you deleted a
note, on your laptop you kept working on it and added a take), what happens if you log back into
sync and it starts working? do we have any reconcillation posture? I'm wondering if all of these
bugs in the Sync family are a sign that we don't have that issue well worked out."* · *"what if the
phone deleted it more than 30 days ago?"* · *"I feel like there's actually more to consider and
think about there and some more testing and scenarios to consider, so I want to have a more proper
phase."*
