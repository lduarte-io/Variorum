# VX-305 — Castle rebuild phase 1: cold review, ladder round 2

**Reviewer:** fable-reviewer (fresh session, zero implementation context), 2026-10-16.
**Prompt:** `notes/REVIEW_PROMPT.md` verbatim. **Diff reviewed:** `e4ee1f083..HEAD` on `vx-305-castle-core` —
round 1's six fixes plus the NEW-1/NEW-2 triage (23 files, +1,943/−47: `Protection/` sources, the scenario/test
world, three new pin files, the plan's §9 and the four round-1 record files). The whole phase diff
(`git merge-base origin/main HEAD`..HEAD) read as context. **Canon read:** the binding design
`notes/plans/vx-266-castle-backups-prelaunch.md` (§1, §3.3–3.7, §3.9, §4.1 in full), `notes/SyncSpec.md` in full,
the phase plan with all unit records, her rulings and §9's round-1 dispositions, the four round-1 record files
(report · answer · final call · fixes) and the triage record — the round's anchor. The plan carries no "Review
foci" section.

**Verification runs made by this reviewer (not trusted from the records):**
- The five new pin suites (`LadderRound1MajorPin`, `LadderRound1NewFindsPins`, `LiveKeyFileIsTheCurrentKeysTests`,
  `TakingOverStandingOldSharedTests`, `TouchIDLobbyWithNoHintTests`): `✔ Test run with 19 tests in 5 suites passed`.
- The protection set, Debug, as a superset filter over every `@Suite` type under `Protection/`:
  `✔ Test run with 461 tests in 76 suites passed` (contains the recorded 432/70; the mutation suites among them).
- A soak-shape generator slice, seed 1 × 120 sequences (`PROTECTION_SOAK=1`): green, 5,268 steps — covering the
  former first-violation sequences 37, 54 and 96 with the compound action live.
- **The mirror proof's live-place-ABSENT arm probed directly** (an untracked probe, run then deleted): Castle
  `.touchID` → Use Standard → Use Castle → `tamperSequence([.deleteKeyFile, .replayLibraryFile])` → the memory
  WINS (mode, fingerprint and live key file all the memory's; promises kept). Green — the arm works; see finding 1
  for what's missing around it.
- **Red-on-old verified mechanically against the round base** (`git show e4ee1f083:…`): the old assess gate
  `liveKeyFile == nil` and the old executor gate `liveFormat3() == nil` (the MAJOR — a stray file provably never
  fires either), the old proof requirement `live.fingerprint == to` in `rekeyOlderLibraryFile` (NEW-1), the old
  `.first` standing pick, and the old `?? false` Touch ID arm — each read from the base tree and consistent with
  the watched-red runs the records document. The orchestrator's independent revert of the NEW-1 fix (red) is on
  the record; the copy-less pin's green-on-both is BY DESIGN and honestly labeled (it records P-R1-1's refusal).
- Release: no code commit follows `ca48bbf65` (verified by diff — notes only since), so the records' exact
  `✔ 371 tests in 65 suites` release run is of the tree under review; not re-run here.
- Scope: `git diff --name-only e4ee1f083..HEAD` touches only `Sources/VariorumCore/Protection/`,
  `Tests/VariorumCoreTests/Protection/` and `notes/plans/` — zero `Sync/`, `App/`, `Server/`, `Persistence/`,
  migration or `Package.swift` lines; no new dependency.

---

## Findings

**[MINOR] · Tests/VariorumCoreTests/Protection/Scenario/Generator.swift:285–300 (`tamperGroup`/`rollsBackBothHomes`)
with Sources/VariorumCore/Protection/Assess/Assess.swift:232–246 (`olderLibraryFileProof`, the absent arm) · the
mirror proof's live-place-ABSENT arm ships with no committed pin, and the generator can never reach it — the one
arm of NEW-1's fix with no red-on-old test in the tree · EVIDENCE (traced and probed):** `olderLibraryFileProof`'s
mirror road has two gates — the live place holds ANOTHER library's file (NEW-1's pinned case) or is ABSENT
(`live.map({ $0.libraryID != libraryID }) ?? true` — the `?? true` arm). No fixed scenario composes
`.deleteKeyFile` with `.replayLibraryFile` (checked across `Scenario/` — FixedScenariosMore.swift:19 loops
SINGLES), single `.tamper` steps can't compose (each bracketed by launches), and `tamperGroup` deliberately never
draws the pair (`rollsBackBothHomes` lists `.deleteKeyFile` in `otherHomes`, Generator.swift:297–300). So the arm
is live code no test or soak exercises. I probed it directly (Castle `.touchID`, two crossings, then the group):
it WORKS — the memory wins, promises kept — and the probe is red-on-old at `e4ee1f083`, where the proof required
the live file (`live.fingerprint == to`, old ExecutorRepairs.swift:299), so the composition left the replayed
stale record standing. Two secondary defects ride the same spot: **(a)** the exclusion's stated rationale is
wrong — the comment calls `replayLibraryFile`+`deleteKeyFile` "the stated limit's shape", but §3.6's stated limit
is the library file AND THE MEMORY ITEM together; deleting the key file rolls back neither home, and the model
itself now says the memory wins it (my probe). The honest reasons to keep each exclusion differ: `.replayKeyFile`
(the whole-pair replay) is P-U4-12's RULED restored-state shape, which promise 10 would false-positive on;
`.deleteKeyFile` has a genuine checker hazard — on an Always-ask device with no catalogued pair of the current
key, the group strands the memory's key (the deleted live file was its only wrap), the library still opens under
the OLD key through an old pair, and promise 1's "no verified memory item" arm would fire on an
adversary-destruction state. **(b)** no mutation-pin twin exercises the new roads with
`libraryFileLosesToMemory` off (the existing `aLibraryFileReplayedAloneLosesToTheMemory` pin covers the old
live-file road only; the guard's bite on the settle-first and mirror roads is asserted by nothing — regression
coverage exists via the ordinary NEW-1 pin, so this is the lesser half). **FIX:** (1) commit the absent-arm fixed
scenario (the probe's exact shape — gate `.touchID`, so the memory's key stays reachable through the custody item;
red-on-old as stated); (2) fix `rollsBackBothHomes`'s comment to the two honest reasons above — and if the
exclusion is narrowed by `.deleteKeyFile` (the implementer's own round-2 suggestion), adjudicate the
promise-1/Always-ask reading first, since the narrowed generator can reach the stranded-memory destruction state.
Neither half changes shipped behavior; both close the gap between what the fix claims and what the tree proves.

**[NIT] · Tests/VariorumCoreTests/Protection/Executor/ExecutorWorld.swift:209, 470–478 ·
`setAsideKeyFiles` is a write-only sink — the U3 harness's catalog never surfaces set-aside files · EVIDENCE:**
the dict is written by `setAsideLiveKeyFile(as:)` and read by nothing (grep: no other reference in the tests). The
scenario world's `DeviceLeaves` keeps the set-aside file in `container.files`, where the catalog parses it as
`.setAside` — the "never deleted, catalogued" half the pins assert. In the U3 harness that half is invisible: a
future executor-harness test of the wedge would silently diverge from the real semantics. Fix: fold
`setAsideKeyFiles` into the harness's catalog/facts, or comment that the U3 harness deliberately doesn't model the
catalog view.

**[NIT] · Sources/VariorumCore/Protection/Executor/PlanRunner.swift:336–339 (the no-identity restore) and
ExecutorRepairs.swift `restoreKeyFileFromMirror` · the two other live-file restores still OVERWRITE a stray file
in place where the copy repair now sets it aside · EVIDENCE:** the final call's own scoping (recorded in the
fixes record §1(b)), re-checked here: both overwritten strays are crashed acts' files whose contents are derivable
(the new key never used, the history and anchor still held by the live state), so nothing is LOST — but the
set-aside's second argument ("an adversary's artifact worth keeping visible") applies to these roads equally, and
the helper now exists (`setAsideLiveKeyFile(fingerprint:)`, ExecutorRepairs.swift:309). Fix: adopt the set-aside
at both sites (one line each), or a doc comment at each recording the asymmetry as deliberate.

**[NIT] · Tests/VariorumCoreTests/Protection/Scenario/Generator.swift:62–66 with Promises.swift:784–786 ·
`truth.beforeRollback` over-records when the group's replay tamper SKIPS (and, pre-existing, when a single replay
tamper refuses) · EVIDENCE:** `step` records `beforeRollback[name]` for any group CONTAINING
`.replayLibraryFile`/`.replayKeyFile` before `apply` runs; the apply loop skips a tamper with nothing to act on.
A skipped replay leaves a stale promise-4 exemption entry that a later coincidental mode+account match would
consume once (Promises.swift:784–786 — the exemption clears on use). Same shape pre-exists for a refused single
tamper on the round base, so this is an inherited micro-leniency the group variant widens slightly. Fix (cheap):
record `beforeRollback` only after the replay actually applied, or clear it when the group applied nothing.

**[NIT, SPECULATIVE] · Tests/VariorumCoreTests/Protection/Scenario/Promises.swift:380–397 (promise 1's key-file
clause) · "owed" is not "runnable" — a repair assess owes forever but the executor forever skips would satisfy the
clause silently · EVIDENCE (mechanism not fully traced, hence SPECULATIVE):** the clause exempts any state where
`restoreKeyFileFromCopy`/`FromMirror`/`rekeyOlderLibraryFile` appears in the assessment, without checking the
repair can RUN. The executor's `rekeyOlderLibraryFile` additionally requires the memory's key directly in
`[library.key] + library.keysInHand` (ExecutorRepairs.swift:347), while assess's owe needs only the proof — if an
unlock road ever verifies the memory without putting its key in `keysInHand` (a vault-road or session-memory
reach?), the repair is owed-and-skipped every run and the clause never fires. Every concrete state I traced
self-announces through other arms (a memory that can't verify fails promise 1's "no verified memory item"
instead), and I could not build a persisting counterexample — so this is a checker-wording note, not a traced
bug, and no failing-on-old pin exists for it. If the go/no-go soak ever shows a `preconditionDoesNotVerify` loop
on `rekeyOlderLibraryFile`, this is where to look; otherwise record and move on.

---

## The five observations handed to round 2 (the triage record's §"For round 2") — adjudicated

1. **Promise 10 skips a step that changes the slot's library** — ACCEPTABLE AS RECORDED. Traced: the variants it
   would catch are caught elsewhere (a swapped-in foreign library fails promise 1's no-memory/no-record arms; the
   remembered-library lowering is now REPAIRED by NEW-1's fix and pinned). The residual — a direct promise-10 read
   of a swapped-in library against this Mac's own memory — is checker breadth for the closeout's hand-forward
   list, not this phase's gate.
2. **The landing leaves its act named in the outgoing library's memory** — ACCEPTABLE AS RECORDED. After the
   settle-first fix the stale act ends against its own key (pinned in `aLoneOlderFileOfALibrary…`); ending it at
   the swap is cleaner bookkeeping with its own crash window — correctly deferred.
3. **The generator's `rollsBackBothHomes` exclusion** — ESCALATED to finding 1 (the unpinned absent arm is the
   substantive half; the narrowing is optional and carries a checker caveat the finding states).
4. **Day-named hand-off folders** — ACCEPTABLE AS RECORDED. The same-day-overwrite is a fake's simplification
   (the real destination is phase 5's); promise 13 now reads sent pairs by identity, and promise 2's folder-keyed
   skip keeps a second belt through `truth.copies` (made-on metadata) — traced, no checker hole.
5. **A stale act's plan-less roll back deletes its to-key's custody items** (PlanRunner.swift:577–581: the guard
   is `to != library.fingerprint && !library.familyTree.contains(to)` — another LIBRARY's current key passes it) —
   ACCEPTABLE AS RECORDED, with the severity frame stated: reachable only through a stale landing act met by a
   replayed file or a Time Machine road; deletes at most a quiet-road item (every typed road survives; the key
   itself lives in that library's own key file); availability-only, her P-U4-1 hygiene frame. Should ride the
   closeout's hand-forward list so phase 2's lobby work sees it.

---

## Clean bill — load-bearing things specifically checked and found solid

- **The MAJOR's fix, both gates agree** (the final call's first re-check): assess owes `restoreKeyFileFromCopy`
  under exactly the executor's conditions — nothing in flight (Assess.swift:325 + `runRepairs`' standing
  in-flight skip), no format-3 file of the CURRENT key live (absent or another key's — the `?.fingerprint !=`
  reading covers nil, stray format-3 AND a legacy file, agreeing with the executor's format-3-only
  `.nothingThere` check), mirror absent or not current, a catalogued frozen format-3 copy of the current key AND
  the same library ID (assess now filters it; the executor verifies it). The executor verifies the copy BEFORE
  the set-aside move (§3.3's delete-after-replacement-verifies, satisfied — the move is not a delete and the
  replacement verified first); Apple wraps stripped, re-added only by `landAppleWrap` under this Mac's own
  unretired key (the pin asserts it).
- **The set-aside is non-destructive and catalogued:** both leaf implementations refuse an existing name
  (ExecutorWorld.swift:470, World.swift:1293); the executor walks 60 epochs for a free name
  (ExecutorRepairs.swift:309); the name shape `variorum-keys[-<fp16>].stale-<epoch>.json`
  (Names.swift:134–140) parses as role `.setAside` with its epoch as `frozenAt` (CatalogNames.swift:166–181,
  Catalog.swift:299, 320) — and `.stale-*` is the design's own catalog place (§3.7). A crash right after the move
  leaves the live place empty with the same repair owed (re-traced). A set-aside stray can never become a restore
  source for the wrong key (the copy filter keys on the CURRENT fingerprint + library ID).
- **Promise 1's key-file clause is not blind-green:** keyed on no-repair-owed with the P-R1-1 residue exempted by
  `copyExists` — exactly the ruled residue; proven to bite by the two generator-found roads committed as pins
  (`aTamperGroupReachesTheWedge`, `aLibraryFileReplayedAfterALeave`), both red on the pre-fix gates per the
  record and consistent with the old gate code I read at the base. The clause runs only with the device open and
  nothing in flight (Promises.swift:356).
- **The compound-tamper action preserves the seed-9 pre-settle:** the bracket is shared code
  (Generator.swift:28–45 — ONE pre-launch settle before a single tamper and a group alike, posture captured
  before, ONE relaunch and the `sealed(_:before:tampers:)` check after); the pool excludes `.replayBothHomes`;
  groups count as deliberate for promise 4 (Promises.swift:811); `beforeRollback` recorded for replay-bearing
  groups (the over-recording micro-case is the NIT above). The recorded decision NOT to `.crash`-wrap a group
  holds up: a group's edits are file writes, not an act's, and the kept pre-settle means a generator group can't
  land inside a crash window without dropping the seed-9 lesson — that road is held by the fixed scenarios, which
  use `apply` deliberately (LadderRound1Pins' header says why).
- **The MINOR's fix is strictly conservative:** `castleRepairs`/`standardRepairs`/`goesOnlyIf`/`relinkSubjects`
  read the guarded `live` (current key's only — Assess.swift:356–361, 604); in the stray-file state deletes
  degrade to `silentItemIsOnlyRoad` faults and no wrap is owed on another key's file — no wrong write anywhere I
  could trace. The RAW live file still feeds the memory-wins arm and the restores (the implementer's caution,
  adopted); `libraryFileLosesToMemory`'s existing pins green in my run. The new fault is suppressed mid-act
  (`midActTheNewKeysFileIsNoFault` pins it) and in the memory-wins state (that arm returns early with its
  repair — re-traced).
- **NEW-2's exemption cannot hide a real exposure:** `reachableInItsDay` (Alphabet.swift:1112–1120) guards
  `record.mode == .standard` and reads the key file's HISTORY only — never an anchor — so a Castle pair records
  nothing at the send, and a Castle-born key structurally cannot enter a Standard file's history (entering takes
  everything, leaving takes nothing — the crossings' own tests hold it). The recording is keyed by the RECEIVING
  device at the send (Alphabet.swift:518–523), so it survives the same-day folder overwrite and the snapshot
  (NEW-2's second road), and a sender's keys can never collide with a receiver-made or Castle-born fingerprint
  (fresh mints). The two pins additionally assert the full trace on both trees — nothing Castle-made reached, no
  pre-leave receiver copy reached, leave-one-out isolating the pair as the ONE road. The exemption matches §3.7's
  letter ("the sent pair is never written and keeps its own locks") and §3.1 rule 2's per-device "after that
  device follows". The classification CHECKER BUG (no model change) is correct.
- **NEW-1's fix is the ratified outcome's mechanics, each link verified:** the proof's three readings
  (Assess.swift:232–246) — the live file of the memory's key; the mirror ONLY when the live place holds no file
  of THIS library, so P-U4-12's whole-pair restore and a same-library mid-act file never qualify (re-traced
  against her ruling: a TM whole-pair rollback still takes the Re-link healing road, not this re-key); the
  anchor-only residue (a leave's new key has no history) stays the ratified P-U4-6 outcome. The executor re-key
  (ExecutorRepairs.swift:340–394) verifies everything before its first write — own-memory deviceID (seed 17's
  rule now on both sides), the history opening with the new key to exactly the file's key, the set-aside before
  the mirror write, wraps stripped — and is crash-safe at every write (set-aside → empty live place, same proof;
  mirror written → the first proof; swapped → epochs equal, the arm disarms — each traced). The settle runs it
  FIRST only when this Mac's OWN newer memory names an act (PlanRunner.swift:298–314), and a legitimate mid-act
  crash can never satisfy the guard (the memory is written AFTER the swap in every act's order, so
  memory-newer-than-record mid-act requires a replayed/rolled-back record — traced against the executor's write
  order). A failed proof falls through to the ratified residue unchanged. The stale landing act then ends against
  the library's own key (pinned, both tamper forms). The re-key still acts only on the SEALED OWN MEMORY's word —
  §3.3's no-destructive-act-on-a-Standard-record's-word guard is not weakened (the authority was and remains the
  verified memory, not the record).
- **The absent arm of that proof works** (my probe — finding 1 is about its missing PIN, not its behavior).
- **The four NITs landed as ruled:** the dead "memory" arm removed with the early return documented
  (DeviceActs.swift:17–21); P-U3-5 cited correctly (SharedKeyAndRelink.swift:69 — checked against the U3
  record's numbering); `takingOver`'s standing pick is principled and pure (the key file's own `sharedApple`
  wrap threaded from the ONE production call site, Executor.swift:281–285; matching-id first, smallest-id
  tie-break, DeviceSection.swift:420–435; order-independence pinned; the no-match residue correctly left under
  her P-U4-1/P-U4-9 frame; test call sites legitimately use the nil default); the Touch ID no-hint fallback
  fires only with BOTH hint sources gone (Assess.swift:148–157), reads her VX-310 letter honestly (a press
  self-verifies; a wrong-key item fails into the passphrase road), and no existing Touch ID test was edited
  (verified by the diff's file list; the suites green in my run).
- **Dispositions complete:** every round-1 finding carries its written disposition in §9; the final call's six
  rulings each located in code as specified (the P-U4-10 sentence at both gates; the stale-copy sentence in the
  record and the pin `aRestoredFileKeepsTheLocksOfItsDay` asserting the inherited refusal honestly; P-R1-1
  recorded with options, not gating, its probe green-on-both BY DESIGN). The triage minted no PROVISIONAL and
  owed none: NEW-2's fixes are checker/world-side; NEW-1's mechanics implement her ratified P-U4-6 (a) — checked
  against the ratification text and §3.6's sentence, no product behavior invented.
- **Counts and hygiene:** the new pins 19/5 green (run); the protection superset 461/76 green (run); a
  soak-shape slice green with groups live (run); the release tree is the release-verified commit (no code since
  `ca48bbf65` — verified); scope clean (verified by diff); no new dependency; no `fatalError`/`try!`/`as!` in the
  diff's source lines; the records' committed-unedited copies match §9's summaries where I checked them.

**Tally: 0 BLOCKER · 0 MAJOR · 1 MINOR · 4 NIT (one SPECULATIVE).** The MINOR is a test/generator-coverage gap
around NEW-1's absent arm (the arm itself verified working by this reviewer's probe) with a stale comment
rationale; nothing found touches the thirteen promises' content guarantees, the round-1 fixes all hold as ruled,
and under her five-round cap no new BLOCKER/MAJOR earns a further round on this reviewer's account.
