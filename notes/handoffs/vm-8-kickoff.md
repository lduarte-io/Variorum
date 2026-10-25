# VM-8 — the phone's Castle catch-up (the orchestrator kickoff; written 2026-10-25 at VX-529's close)

**This file SUPERSEDES `notes/handoffs/vx-494-handoff.md` Appendix B** (written 2026-10-23, then deferred twice: behind
VX-510 at her R-494-12, and behind VX-529 at R-510-19). Appendix B's charter stands; what changed since is folded in
below — VX-510 and VX-529 both landed shared protection code the phone inherits and faces the phone owes.

**The state, in one breath:** the Macs run 0.10.2 (build 9462) against marker 14. **Her phone has not synced since the
release switch (2026-10-22)** — it runs a pre-0.10 main build, refuses marker 14 by design, and has no new-road
account faces to sign in or join with. Her accepted cost then was "a day"; it has been longer, so speed matters.

## THE PASTE-READY KICKOFF PROMPT (for her — start the session on Opus, see "The cast" below)

```
/architect-phase vm-8 — the phone's Castle catch-up: my phone hasn't synced since the release switch (the Macs run
0.10.2, marker 14) and this run gets it back online, then gives the phone the protection faces it owes. READ FIRST,
IN FULL, YOURSELF: notes/handoffs/vm-8-kickoff.md (this file — it supersedes vx-494-handoff.md Appendix B), the VM-8
ticket + every comment on it, notes/MobileSoul.md PL-47…PL-59 (PL-51 is the charter; PL-57/58/59 are the newest),
notes/CastleRules.md WHOLE, notes/SurfaceContracts.md (Doors — protection + portability), then the records this file
names. Workspace: a main-based worktree ~/dev/variorum-vm-8 (my phone runs main-built installs). GET MY PHONE SYNCING
FIRST: the shortest road to my phone pulling my library whole under my account's Castle mode (Face ID gate) is unit 1,
and it ends with the device install — the remaining faces come after, in their own unit(s). Bring me the plan's scope
split at the kickoff sitting before any build. My wording calls are MINE — bundle them, don't invent. The diff touches
custody-adjacent words and Shared/ protection code: this run holds the custody slot; cold review by a fresh Opus
reviewer (Fable's safeguards stop live Castle walks).
```

## THE CAST (her call at kickoff — the recommendation)

- **Orchestrate on Opus** (switch with `/model` before pasting). VX-529's live Castle walk was stopped twice by Fable's
  `[cyber]` safeguards and finished under an Opus orchestrator (memory `fable-safeguards`); this run's acceptance is
  a live Castle round on her real phone, the same class.
- Opus implements (`opus-implementer`), one acceptance unit per fresh session; a fresh **Opus** cold reviewer per
  ladder round (Appendix B's line, her word). If any line lands inside `Sources/VariorumCore/Sync/`, that line is
  Fable's (CLAUDE.md) — the expectation is none: everything below is faces + Shared/ wiring.

## THE CHARTER (verify every line in code — never trust this file)

**Unit 1 — the phone syncs again (the critical path; ends with the device install):**
- **Her pre-design face with Start fresh** (PL-51 (b), F-U4-2): the shared fact fires on the phone and the whole
  set-aside compiles for iOS, but `MobileRoadLockView` renders no Start fresh door. Her phone's library likely predates
  the design, so this face is probably the phone's first screen on the new build — exactly the Mac crossing her two
  Macs made at 0.10 (set aside whole → Start fresh → sign in → join → first catch-up). Verify which arm her phone
  actually meets before building around it.
- **The account section and the join** (PL-51 (a), the VX-308 parity comment on VM-8): sign in, "Sync this library…"
  (the join arm — her account has a vault), the words moment, the first-round sheet that stays to confirm (PL-58: the
  first-round seam and the confirm's round phase are `Shared/`; the phone renders no account section yet), the sync
  row's not-yet line already live (PL-58).
- **The Castle first round behind Face ID** (Appendix B; VX-487's sync-keys fix is shared — prove the phone's own round,
  the class the Mac fixed). VX-501's typed-unlock key load is in the shared lobby road since VX-510, so a typed unlock
  should load the sync keys on the phone too — verify.
- **The first catch-up at her scale** (PL-57): ~108k rows; the 2,000-row windows and the resumable download stage are
  inherited. **Acceptance cases:** a resumed download across an app switch (iOS suspends backgrounded apps), and **the
  save time measured and reported** — VX-497 is deferred to this run at her word, and the measured number decides its
  shape and its Pre-launch call.
- **The device install** (the devicectl road) and her phone pulling her library whole — the unit's evidence, with the
  phone suites green and a simulator walk before it.

**After unit 1 — the faces the phone owes (sized and split at the kickoff sitting, per `notes/PhaseSizingGuidance.md`):**
- **The Protection screen and the crossings** (PL-51 (a)): Use Castle / Use Standard with the Face ID gate choice; the
  key doors (change passphrase, new words, replace all keys) with their changed-elsewhere refusal faces (PL-59); the
  phone's passphrase setter with the 12-character floor and the quiet strength hint (the VX-309 parity comment).
- **The follow, all three kinds** — posture, key replacement, and VX-529's pair change (PL-59: the pair sheet lands with
  this run's account section), the durable notices' phone rendering, the check door (PL-58/59).
- **The phone's band cards:** the words card's phone band (VM-23, PL-50 (a)) and VX-538's recurring E6 card (PL-59,
  R-529-6: the why and the road, recurring until a passphrase lock lands, no don't-show-again).
- **The pocket guide:** the new-road protection chapter (the Mac's three lessons — the VX-309 parity comment) and the
  compromise-recovery page (PL-59; the Mac's is VX-379's).
- **Her wording calls, bundled, never invented:** F-PH-1 (core model sentences that name the Mac on a phone face —
  rule 21's notice, the key-file offer), F-PH-2 (her rule-12 leave sentence's phone wording). Re-read
  `MobileNoRedirectSweepTests`' exemption list at kickoff — every `why` names the face that makes it reachable.

**The OLD VM-8 scope (the 2026-10-06 plan's Phase 6 — written before the Castle rebuild):** the "How Protection Works"
explainer, the live-checklist lead, the unchosen-state indicator, the T1 verify (PL-18), the sample-library restore door
(PL-17), the PL-13 residue, note-level multi-select, the Apple re-link door (#139(f)). Reconcile each against
CastleRules: what the rebuild retired, say so; what is still owed and off the critical path becomes its own VM ticket,
offered to her — never silently dropped.

## KNOWN, NOT THIS RUN'S (don't re-trace)

- **VX-544:** after an offline typed unlock in Castle, sync stays locked for the session (nothing retries the key load
  when the network returns). Shared lobby code, pre-existing VX-501 behavior; her word "later" — it rides VX-500. A
  phone that unlocks offline will meet it; record it, don't fix it here.
- **VX-542:** the follow-owed pane repeats its pair sentence per locked door (a Mac face). If the phone's pane is built
  from the same copy, don't copy the repetition — note it on VX-542.

## RIDERS TO OFFER AT KICKOFF (the standing rule — her call each)

- **VM-15** (Pre-launch): a sibling phone that hasn't followed into Castle — and its iCloud device backup — stays
  Apple-openable. The same surface.
- **VM-16** (Pre-launch): the phone's undo door mis-speaks a quiet press (VX-276's rule, phone side) — only if the run
  has room; it's App shell, not protection.

## MACHINERY

- Ticket VM-8 (team VM); branch `vm-8-<slug>`; PR `VM-8: …` (merge commit); the record
  `notes/plans/vm-8-<slug>.md` with a LIVE STATUS from the first commit (the resiliency protocol). Add the in-flight
  row at kickoff; **it holds the custody slot** — VX-500 (the 0.10 window follow-ups) and VX-212 (Castle phase 6) wait
  for this merge.
- The stage for every simulator/device run; the phone suites pinned by device id (VX-529's lesson: two "iPhone 17"
  simulators exist across iOS 26.2 and 27.0 — a name-only destination exits 70).
- Keep the VM-8 ticket current as you go (Appendix B's line, her word) so any session can get her phone back online.
- At the closeout: MobileSoul's row; the master plan's paragraph; her handoff; the next run is **VX-500**.
