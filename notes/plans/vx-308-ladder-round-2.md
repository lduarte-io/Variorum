# VX-308 — LADDER ROUND 2 (cold reviewer, Fable, 2026-10-19; FINAL CALLS on round 1's fixes)

**Scope:** the round-1 fix leg's diff, `git diff 3d2726551..6b4fc9262` (the five fixes, their pins, the records; the
cross-model rule — the implementer agreed with and fixed all five, zero disputes, so each call below is confirm-or-reopen).
Prompt: `notes/REVIEW_PROMPT.md` verbatim over that diff. Read whole for this round: the round-1 findings file, the plan's
§6 ROUND-1 FIX LEG record with its dispositions, the §6 U3 record's amended CORE LINE, CastleRules rules 20/21/27, the
plan's §5a hard limits, and the code itself — `Acts/KeyDoors.swift` whole, `PlanRunner.swift` whole (perform / drive /
settleAct / resume / rollBack / derive), `Executor.swift`'s writeFacts/writeMemory, `ExecutorRepairs.swift`'s
`refreshMemory`, `Assess.swift`'s memory arms, `DeviceMemory.opening`, the three section models, `ProtectionOpenFaces.swift`
(`refreshPane` + `ProtectionPaneRefresh`), `ProtectionAccountActs.swift` (`ProtectionPaneRead.read`/`wave`),
`ProtectionKeyDoorActs.swift`, `AppBootstrap.swift`'s three section roads + `paneWave`, `RoadAccountSheet.swift`'s host,
`ProtectionWords.swift`, and all five pin suites. Every mechanism re-traced by me in this session.

**My verification runs (headless, core package only — no stage, no xcodebuild test, no store touch):**
- HEAD (`6b4fc9262`+): `swift test --filter 'NewWordsResumeTests|FileLessWordsTests'` → `✔ 13 tests in 2 suites` (matches
  the record).
- RED-ON-OLD, re-verified myself: a scratch worktree at the pins-first commit `07add5577` (tests present, fix absent;
  this branch's tree untouched) → `swift test --filter NewWordsResumeTests` → `✘ Test run with 5 tests in 1 suite failed
  … with 14 issues` — the record's exact red, reproduced; the worktree removed after.
- The Mac-hosted pins (`ProtectionPaneWaveTests`, the flipped source pins, the words suites) I could not run headless;
  my evidence is my own read of each test plus the two recorded runs (the implementer's harness 272/43 and the
  orchestrator's staged delta, 166/28 with the `paneWave` red leg, `e3382f6e4`).

---

## FINAL CALLS (per round-1 finding)

### MAJOR-1 — **CLOSED.** The fix closes the traced wedge exactly, scoped as the finding allowed, nothing new broken.

Re-traced end to end: `KeyDoorProgram.resumeCannotFinish` (KeyDoors.swift:116–121) fires only for `act == .regenerateWords
&& ctx.resuming` — `ctx.resuming` is set true only by `settleAct`'s finish-from-record and `resume` constructions
(PlanRunner.swift:360, 415) and false at every press (:227), so no press path changes (M1-c pinned it load-bearing). On a
resume, missing words (`secrets.words == nil` — a plan never holds one, `derive` only converts typed secrets) or no live
key file of the current key throws `ActRollback` at the head of the `vault`/`keyFile` steps, BEFORE either writes; `drive`
catches it and runs the one existing `rollBack` (staged discarded; no file restore — no key change, `toFingerprint` nil so
no custody deletion; act cleared; plan deleted; copies resumed; PlanRunner.swift:244–248, 503–581), and the settle answers
`.rolledBack(.regenerateWords)`. The banner door un-wedges because `actInFlight` is cleared and Assess's rule-27 arm
(`noKeyFileAnywhere` requires `actInFlight == nil`, Assess.swift:251–256) raises again. The two crash classes that take
OTHER settle arms are also whole: no plan on disk (a crash before the plan write) → `toFingerprint == nil` ⇒ committed ⇒
finish-from-record with `["memory"]` = `rememberNewKey` → `writeMemory`, which needs no secret and tolerates a nil key file
(Executor.swift:334); a plan recording `keyFile` done → the resume runs `memory` alone and finishes. The pin
(`NewWordsResumeTests`, 6 tests incl. the every-write crash loop over all three shapes) is green on HEAD in my own run and
red on the pre-fix tree in my own worktree run — the red is real, not only recorded. The landed-vault-write consequence
(the account's words at unseen values until the next mint re-wraps them) is asserted honestly in the pin and is the
finding's own accepted fix shape.

*Residue I verified as recorded (F-U3-2's ticket, the closeout's note):* the post-file-write stop keeps the unseen-words
lock on the live file (the library still opens by its quiet road; the next mint re-locks it) — pinned by the loop; the
"says which" gap is Diagnostics-only and pre-existing for every act. *One residue arm the disposition does not name, for
the same ticket body (NOT a reopen — byte-identical pre-fix, so no pin could be red on old against this fix):* an everyday
SYNCED new-words act stopped after its landed vault write, on a Mac whose keychain is then wiped, opened at the lobby by
the OLD typed words, RESUMES holding those words (the guard rightly passes: words in hand, live file standing) and
finishes by re-locking the file under the OLD words while the vault stays under the unseen new ones — rule 7's pair split
silently until the next New Words heals it (the passphrase road still verifies, so the heal is always open). Narrow
(crash window + wiped keychain + words-typed open), bounded, recoverable; it is F-U3-2's general resume-verification
design question (the words road has no "must be the press's" check parallel to the passphrase's promise-9 check,
PlanRunner.swift:390–411) and belongs in that ticket's body beside the arm this fix closed.

### MINOR-1 — **CLOSED** (disposition (b), the record amended — the choice I'd have made).

The finding's two halves resolved rightly: the record's "never a guess" sentence was the overclaim, and the fix makes the
decode-skip deliberate, logged by truncated id (never key material), and stated in the doc comment; the U3 record's CORE
LINE item 7 is amended in place (plan :1461–1468). I verified the disposition's load-bearing premise myself: an
undecodable item reads as nothing remembered at the unlock (`DeviceMemory.opening` → `try? open` → nil,
DeviceMemory.swift:65–72), so `Assess.memoryFollows` is false both for this library's item (memory nil) and for another
library's (its id still enumerates in `rememberedLibraryIDs`), and the open's `refreshMemory` repair rewrites this
library's item and deletes every other library's (ExecutorRepairs.swift:164–174) before any door is reachable; every act's
begin rewrites it again (`writeFacts` → `writeMemory`). So option (a)'s refusal would protect no payload while wedging
rule 27's one recovery road — (b) is correct. The pin plants undecodable items for both this library and another, asserts
the mint proceeds, both skips said, and this library's item rewritten; red by behavioural revert (the log dropped) per the
record — the mint arm is green on both trees by design (record-honesty finding, as round 1 itself allowed).

### MINOR-2 — **CLOSED.** One read per appearance, derived one-source, landing rule race-correct.

Re-traced: `ProtectionPaneRead.wave` takes the one read (`ProtectionPaneRead.read` — one facts gather, one vault fetch)
and derives the three faces through the SAME functions each section's own bootstrap road composes
(`ProtectionCrossings.readCrossings(…, read:)` / `accountFaces(read, session:)` / `ProtectionKeyDoorRoad.faces` — I
compared the three road closures at AppBootstrap.swift:1316–1440 against the wave line by line; `ProtectionKeyDoorRoad
.read` is itself `read(…).flatMap(faces)`, so one source). `ProtectionPaneRefresh.wave` takes each model's number BEFORE
the one read and lands by each model's own pre-existing `read > landed` guard — the `beginRead`/`land` split is mechanical
(the landing guard and the crossings' owed re-read are the same lines as before, just moved into `land`), so a section's
own read started during the wave wins, as the order pin asserts. The nil arms match: `AppBootstrap.paneWave`'s not-ready
guard answers an empty wave whose nil faces are exactly what each section's own road answers in that state (the same
`newRoad`/`.ready`/session guard). Every other refresh trigger keeps its own fresh read (VX-108 — the press paths are
untouched). The flipped Mac source pins correctly assert the pane's one `.task` and the bootstrap's wave wiring. No pin of
this fix could run headless here; the staged delta's 166/28 and its red leg (the `paneWave` arm dropped → exactly the wave
test red) are recorded by the orchestrator and match the code I read.

### NIT-1 — **CLOSED.** The hole says what is true of it; the close is the host's own dismissal.

`presenter?.hostDismissed(host)` is the same road the sheet binding's set-nil takes (RoadAccountSheet.swift:365–367), so
the sign-in request's `closed` runs on this Close exactly as on a swipe-dismiss; logged once on appear; the sentence is
PROVISIONAL under the standing P-VX308-U1-1 bundle row (the U1 words section), in the no-shouting pin's list, and the
old arm's untrue sentence is pinned absent by the source pin (red-on-old by pre-fix probe, recorded).

### NIT-2 — **CLOSED**, with the deviation judged right.

Round 1 suggested carrying the double-"now" to the bundle row rather than fixing; the implementer fixed it AND carried it
(P-VX308-U2-1's standing row covers the section's words; the reword is the draft she judges there). That is the better
disposition — the cheap honest draft, PROVISIONAL, her call preserved. The new head appears in exactly one place
(`joinedReceipt`); no other consumer of the old string exists (grepped App/Sources/Tests); the widened pin asserts one
" now" per receipt across every plan × moved, and the as-drafted pin flipped deliberately with the behavioural-revert red
recorded.

---

## NEW FINDINGS IN THE FIXES

**None at any severity.** Candidates I traced and dismissed:
- The wave landing nil faces when the bootstrap is not ready — byte-parallel to each section's own road's nil in that
  state; no degradation beyond the pre-fix behavior.
- `RoadCrossingsModel.land`'s owed re-read before the landing guard — the pre-existing refresh order, merely relocated.
- The resumed-with-old-typed-words arm under MAJOR-1 — pre-existing (byte-identical before the fix: the guard only ADDS
  rollbacks; that arm passes it exactly as the pre-fix code ran it), so it is F-U3-2 ticket-body residue, not a round-3
  finding; no pin on this diff could be red-on-old for it.
- `resumeCannotFinish` touching other acts — it cannot (`act == .regenerateWords` guarded; Change/Reset resumes
  byte-unchanged, the ticket's design call as arbitrated).

## Clean bill (checked and found solid this round)

- **Scope discipline:** zero `Sync/`, `Server/`, schema, migration or dependency lines in the fix leg;
  `SyncSchema.lockstepVersion` untouched; the one core file is `Acts/KeyDoors.swift` (the §5a hard limits held).
- **Commit hygiene:** pins-first ordering real (`07add5577` before `653d236c2`); no `Co-Authored-By`/`Claude-Session`
  trailer on any commit in the range (checked); records committed per piece with LIVE STATUS.
- **The MAJOR-1 pin's teeth:** verified red on the pre-fix tree in my own run, green on HEAD in my own run; the loop test
  covers every write of the clean run in all three shapes, so the fix cannot silently regress to a single-stop pin.
- **No press-path change:** `perform` passes `resuming: false` always; the door's own mint and every key-door press are
  byte-unchanged but for the dead guard call.
- **Rule 20/27 posture:** the rollback leaves the OLD state on disk exactly (no file restore where no key changed, no
  custody deletion where `toFingerprint` is nil), the banner returns (Assess's arm re-raises once `actInFlight` clears),
  and the recovery door completes the state whole on the next press — rule 27's road is self-healing now instead of
  self-wedging.
- **The U3 record's amended CORE LINE** now states the decode-skip honestly; the ProtectionWords additions are sentence
  case, in the no-shouting pin, and PROVISIONAL under standing bundle rows (P-VX308-U1-1, P-VX308-U2-1) — no new
  unrecorded product words.

## Counts

Reopened: 0. New findings: BLOCKER 0 · MAJOR 0 · MINOR 0 · NIT 0.
One ticket-body note for F-U3-2 (the typed-old-words resume arm, above) — the closeout already owes that ticket MAJOR-1's
note; this rides it.

**THE LADDER CLOSES AT ROUND 2:** five findings, five fixes confirmed CLOSED, zero new findings.
