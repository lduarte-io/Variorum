# VX-305 ladder round 2 — the reviewer's FINAL CALL (the cross-model flow's third step)

**Reviewer:** the round-2 fable-reviewer (same session), 2026-10-16, after reading
`notes/plans/vx-305-ladder-round-2-answer.md` in full. **Verified, not trusted:** I ran the implementer's
untracked pin myself with the NEW-1 pins and the mutation suite — `✔ Test run with 25 tests in 3 suites passed`,
the implementer's exact count — and read `LadderRound2Pins.swift` whole: its assertions are stronger than my
probe's (the replay-precondition trace, the epoch, the memory-not-overwritten check, the mirror-road log line).
Its red-on-old evidence (5 issues with the three NEW-1 files at `59d5d9289`, and the SAME 5 with only the absent
arm's `?? true` flipped to `?? false` while NEW-1's own pin stays green) is exactly the arm-specificity proof the
finding needed. The implementer's two corrections to my readings were both re-checked and both stand: the
deleteKeyFile hazard's real symptom (an unverifiable memory is rewritten by the launch's `refreshMemory` before
any promise runs — the ALWAYS block's `stale` arm fires on `memory == nil`, traced), and its real anchor
(P-U4-13 (b): the memory's mirror is not a lobby road in phase 1 — her ruled vx-306 deliverable), which I had
missed. **This is the final round: the orchestrator checks the applied fixes line-by-line against the checklist
at the end.**

**FINDER-FIXES: none.** Nothing here is `Sync/`, and the implementer's answer shows full command of every
mechanism (it built the pin, found the ruling anchor I missed, and its fix shapes are the conservative ones a
final round wants). The implementer applies everything below.

---

## Final call per finding

### 1. MINOR — the unpinned absent arm + the stale exclusion comment: **CONFIRMED. Fix as follows.**

**(a) Commit the pin as built.** `LadderRound2Pins.swift` joins the tree unchanged except its header's
"UNTRACKED" line, which becomes the standard provenance line (this round's record files named). Red-on-old is
already demonstrated twice over (the three-file revert AND the one-line arm flip, NEW-1's pin green under the
flip — recorded verbatim in the answer).

**(b) Commit the mutation twin.** The guard-off form the implementer probed (`mutationPin(off:
{ $0.libraryFileLosesToMemory = false })` around the same scenario, the harness's standard
guarded-green-AND-unguarded-fail single test, `#if DEBUG` like its siblings; the twin's bite is the scenario's
own check — slot under the remembered key at the memory's epoch — since the violation list stays `[]` by the
blindness below). This closes my finding's lesser half: the guard's bite on the new roads is now asserted, not
argued.

**(c) Rewrite `rollsBackBothHomes`/`tamperGroup`'s comment to the two honest reasons — the ruling is KEEP, not
narrow.** The implementer's three-part case is accepted: no generator road to the hazard's precondition was
constructible (every key-minting act ends with `backup`; the no-pair acts have no older same-library file to
replay; snapshots aren't catalogued), a narrowed slice ran green but is weak evidence, and — the deciding
reason — round 2 is the FINAL round: narrowing shifts every seed's stream and adds a composition to the go/no-go
soak that no later ladder round reads, while its only constructible failure is a promise-10 false positive on a
class her P-U4-13 (b) ruling already sends to phase 2. The comment's wording, to apply (adjust formatting to
taste, keep every clause):

> `.replayBothHomes` never joins a group (it carries its own stated-limit bookkeeping), and `replayLibraryFile`
> never composes with:
> — a tamper on this Mac's MEMORY home (`deleteMemoryItem`, `editSealedSetting`, `replayMemory`,
> `deleteKeyFileAndMemory`): the library file rolled back together with what it would lose to IS §3.6's stated
> limit, already modelled by `.replayBothHomes`;
> — `replayKeyFile`: the file replayed with its own key file is the whole-pair shape her P-U4-12 ruling keeps as
> a deliberate restore's road (P-U4-6's carve-out — "the deliberate whole-pair restore keeps its own road"),
> which promise 10 would otherwise read as a violation;
> — `deleteKeyFile`: where the live key file is the memory key's only road on this Mac (Always ask, no frozen
> pair), deleting it leaves the memory unverifiable and the older file wins by the two-homes rule — P-U4-13
> (b)'s ruled phase-2 class (the lobby's memory-mirror road is a vx-306 deliverable). NARROW this exclusion when
> that road lands; the absent arm itself is pinned deterministically (`LadderRound2AbsentArmPin`).

**(d) The vx-306 hand-forwards this finding feeds (for the closeout's list, not this round's code):**
(i) narrow `rollsBackBothHomes` by `.deleteKeyFile` when the lobby's memory-mirror road lands (P-U4-13 (b));
(ii) CHECKER BREADTH — the implementer's Castle-born-replay blindness, accepted as traced: promise 10 watches
mode, account, custody and gate style, never the key or the epoch, so an older file silently overwriting a
VERIFIED newer memory moves nothing it watches. The suggested reading for the checker's next phase: a
key/epoch-regression clause ("in Castle, no tamper ALONE moves the record's current key or epoch backward"),
with its exemptions named up front — the stated limit (`.replayBothHomes`, Time Machine), the anchor-only
residue (P-U4-6's ratified outcome), and P-U4-13 (b)'s unverifiable-memory class until phase 2's road lands.
Not built this round: a new promise clause needs its own false-positive sweep that no later round would read.

### 2. NIT — ExecutorWorld's `setAsideKeyFiles` sink: **CONFIRMED, fix by the doc comment.** The implementer's
precision is adopted (the U3 harness has no catalog VIEW at all — `catalogKeyFiles` is a test-filled lookup by
id, so folding a set-aside file in would mean inventing the id the real catalog would give it, modelling nothing
a test reads today). One doc comment on the harness's `setAsideLiveKeyFile` saying the U3 harness keeps
set-aside files out of its catalog view and the scenario world (`DeviceLeaves`) models that half. No pin — a
fake-fidelity note.

### 3. NIT — the mirror and plan-runner restores overwrite a stray file in place: **CONFIRMED, fix by the
doc-comment option.** The implementer's reason is decisive for a final round: the set-aside is a COUNTED write
and the mirror restore can run inside an act's crash window, so adopting it would shift crash-point numbering
(`afterWrites:` pins and every seed's stream) with no safety gain — both overwritten strays are crashed acts'
derivable files (traced by both of us: a never-used new key whose history and anchor the restored file already
holds, or a replayed genuine file whose keys the current history or anchor holds). One sentence at EACH site
(PlanRunner.swift's no-identity restore; `restoreKeyFileFromMirror`) recording the asymmetry as deliberate and
pointing at the copy repair's set-aside as the belt. The set-aside adoption may ride the closeout hand-forward
list as phase-2 polish if wanted; it is not owed.

### 4. NIT — `beforeRollback` over-records: **CONFIRMED, fix with the implementer's WIDER shape, which I verify
and adopt over mine.** Its cause analysis is right: every entry-recording action is itself `deliberate` on that
device, so an entry is never consumed at its own step, and the step's own relaunch is where the effect lands and
is judged — so an entry is stale after ANY tamper-borne replay whose library OPENED at that relaunch (skipped,
applied-and-lost, or applied-and-won alike; my skipped-only reading was the narrow case). The fix: clear
`beforeRollback[name]` at the end of a tamper step when the relaunch opened the library; KEEP it when it didn't
(the later open is the entry's one legitimate consumer). Test-world only; no stream shift (checker bookkeeping,
not action drawing or write counts). The go/no-go soak is the validation — if the tightening surfaces a red that
traces only to a formerly-masked stale-entry excuse, it comes back as a checker question at the gate, not a
model bug. No pin owed (checker leniency, no failing-on-old test could pin it — the honest label it carried).

### 5. NIT (SPECULATIVE) — "owed" isn't "runnable": **RESOLVED AS TRACED-CLOSED, record only.** The
implementer's trace is accepted and is the answer my SPECULATIVE label asked for: the two restores' executor
preconditions match assess's exactly; the one real divergence (`rekeyOlderLibraryFile` needs the key in
`[library.key] + keysInHand` while assess's memory may verify through the wider `reach`) cannot pass silently —
assess's early return suppresses `refreshMemory`, so the memory keeps naming the newer key and promise 1 fires
one of its two first arms; and the world's `walkLobby` already puts every silent item's key in `also`. No code
change this round; promise 1's clause stays keyed on "owed". **Hand-forward for phase 2's lobby (the closeout
list):** pass every key the lobby reads — silent items included — in `alsoInHand`, or have the re-key read its
key through the same `reach`, so the divergence class stays unreachable when the real lobby replaces the world's.

---

## The coordinator's numbered points, answered

1. **`rollsBackBothHomes`: KEEP**, comment rewritten per §1(c) verbatim; the narrowing is vx-306's, tied to the
   memory-mirror road (P-U4-13 (b)). The implementer's symptom correction is adopted — the hazard's face is a
   silent `refreshMemory` rewrite, not my predicted promise-1 line (its probe disproved mine; re-traced and
   confirmed: an unverifiable memory reads `unlocked.memory == nil`, the ALWAYS block's `stale` fires, the
   launch's repairs rewrite the memory before any promise runs).
2. **The mutation twin: COMMITTED this round** (§1(b) — deterministic, no stream shift, the harness's standard
   shape). **The key/epoch-regression promise reading: HAND-FORWARD** (§1(d)(ii)) with the exemptions named —
   a new promise clause in the final round would reach the go/no-go unvalidated by any ladder eye.
3. **NIT 3's shape: the doc-comment option** (§3) — the counted-write/crash-window reason decides it.
4. **NIT 4's shape: the implementer's wider fix** (§4) — clear on opened-at-relaunch, keep otherwise.
5. **NIT 1: the doc comment** (§2). **NIT 4/observation-5's hand-forward: reworded** — availability-only on its
   own trace (a stale landing act's roll back can delete another library's QUIET-ROAD item only; every typed
   road survives; the key lives in that library's own key file), **without the P-U4-1 citation**.
6. **The §8 reading: ACCEPTED** — P-U4-1 rules the delete that never reached its item, the opposite case; my
   citation was a wrong anchor and the closeout hand-forward line drops it (the "availability-only, not chased"
   conclusion stands on the trace alone).

## The orchestrator's line-by-line checklist (the final round has no later reviewer)

1. `LadderRound2Pins.swift` committed byte-identical but for the header's UNTRACKED line → provenance line; the
   pin green in the committed tree.
2. The mutation twin beside it (or in `MutationPins.swift`): ONE test, guarded-green AND unguarded-fail
   (`libraryFileLosesToMemory` off → the slot ends under the OLDER key and the twin's own check fails); `#if
   DEBUG` with its siblings.
3. `tamperGroup`/`rollsBackBothHomes`'s comment carries all three clauses of §1(c) — the memory-home reason, the
   P-U4-12/`replayKeyFile` reason, the P-U4-13 (b)/`deleteKeyFile` reason with the narrow-at-phase-2 sentence —
   and the CODE of `rollsBackBothHomes` is UNCHANGED (keep, not narrow).
4. One doc comment on `ExecutorWorld.setAsideLiveKeyFile` (the no-catalog-view note); no behavior change.
5. One sentence each at PlanRunner's no-identity restore and `restoreKeyFileFromMirror` (deliberate overwrite,
   the copy repair's set-aside as the belt); no behavior change, no new counted write.
6. The `beforeRollback` clear at the end of a tamper step ONLY when the relaunch opened the library (Generator's
   `step`); no source change outside the test world; the everyday generator loop and a soak-shape slice green.
7. The protection set green in Debug; the compiled subset green under `-c release` (code changed only in tests
   and comments — the release run may be the records' if no source line moved, said explicitly either way).
8. The hand-forward list for the closeout carries, worded as ruled here: the vx-306 narrowing (P-U4-13 (b)); the
   key/epoch-regression checker reading with its exemptions; phase 2's lobby `alsoInHand`/`reach` line;
   observation 1's promise-10 slot-library reading and observation 5's availability-only line (no P-U4-1 cite);
   the optional set-aside adoption at the two restores.
