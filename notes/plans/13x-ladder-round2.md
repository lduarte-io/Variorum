# 13x — Ladder round 2 (cold re-review of the F1 fixes, `fable-reviewer`, 2026-10-07)

**Scope:** the fix range `git diff ae7ada9c..HEAD` on `vx-6-13x-library-portability` (HEAD
be195310), re-reviewed per `notes/REVIEW_PROMPT.md` with round 1's findings
(`notes/plans/13x-ladder-round1.md`, their traces binding), the DISPOSITIONS table and the F1
RECORD in the phase plan as the anchor. Canon re-read for this round: SyncSpec whole (the diff
touches custody code), pre-13x-postures-design §3.4's posture-law row + §14.13's rows verbatim
at their lines, the copy conventions' facts where a fix states them. Every fix's mechanism was
re-traced in source by this reviewer (the hallucination guard): `reconcileFollow` whole,
`runFollow`'s no-rotation road + `rekeyCustodyAndSnapshot` + `retireOldKeyFiles`,
`StoreKeyEnvelope.locate/loadCurrent`, `leaveCastle` end-to-end, `PostureSwitchModel.start`,
`LibraryAdoption.execute` whole, `LibraryRestoreHold` whole, `StoreLobby`'s
waiting/suspension/probe, `LibraryOpenModel.beginUnlock/confirmAdoption/failureWording`,
`LibraryHandOff.produce` + the new model/presenters/faces, the registry's three walk-asserted
tables, `AppBootstrap.beginOpening/adoptLibrary/reopenAfterAdoption`. Headless re-runs by this
reviewer: the eight adoption/classifier/hold/recreation/drill suites (44/8 green, M2's new pin
included) and the WHOLE core suite + StringsWorkbook — **2335 tests in 269 suites PASSED +
40/6 PASSED**, matching the F1 record exactly. The Mac-slot evidence (76/4 + the five reverts)
is verified against the record's quoted outputs and the test files' actual assertions only
(the stage rule binds this session too); every quoted red is one the test code would
mechanically produce under the named revert — none is vacuous.

---

## Per-finding verdicts

**R1-BLOCKER (the same-Mac Standard-era pair onto a Castle account) — FIXED-PROPERLY.**
Re-traced end to end from source. The fourth material-in-hand arm
(ProtectionController.swift:680) fires exactly on: determined Castle
(`!reading.hasAppleHeldCopy`) ∧ ids agreed (the rotation arm at :642 returned early
otherwise) ∧ the LIVE key file carrying an `apple` wrap ∧ `!switchInProgress` — and the
silent-shape arm at :662 still precedes it, so the new-Mac/silent road keeps decision-35's
kind and its self-heal untouched. The act needs nothing new, exactly as claimed: the notice's
Enter runs the kind-agnostic follow, which takes `runFollow`'s no-rotation road
(PostureSwitch.swift:775–787 — held ids equal, same master, no previous key) into
`rekeyCustodyAndSnapshot(follow: true, entersCastle: true)`: L′ minted, the new key file
written with NO Apple copy (the Castle rule in `writeNewKeyFile`), the store swapped, and
`retireOldKeyFiles` (:1033, `follow && entersCastle`) removes the apple-carrying file — so
the re-key closes the exposure and post-follow snapshots copy the clean file. **False-fire
sweep, done arm by arm:** a crashed Castle ENTRY leaves library-key custody SILENT until step
5, so the pre-existing decision-35 arm owns that window, never the new one; a crashed
re-key on an already-Castle library has no `apple` wrap on its file; a crashed LEAVE-Castle
has `hasAppleHeldCopy == true` at every step that lands the file's copy; a legacy format-1
file with wraps can never be `locate`d over a fingerprint-named current file
(StoreKeyEnvelope.swift:482–497). The only other road into the arm's state is a hand-placed
old pair in Finder — where firing is correct and a coverage gain. Notice plumbing complete
(body / waitingBody / laterSubline per P-F1-3; the words' FACTS check out against §3.4's
Castle row, read verbatim: "library key, WRAPPED — under P, W, M only"). The pin sits beside
the decision-35 pins asserting the owed kind, gated custody as the non-detector, the
verdict-writes-nothing fact and custody untouched; REVERT A's quoted red is exactly what
removing the if-block produces.

**R1-MAJOR (the hand-off act had no door) — FIXED-PROPERLY.** Both faces exist over ONE flow:
File ▸ Send Library to Another Mac… (EditorCommands.swift:310–321, in `menuRendered`) and
Data Safety's "Moving to another Mac" section (DataSafetyPane `handOffSection`,
`surfaceCapabilities` extended) → `LibraryHandOffPresenter` (NSOpenPanel, Downloads default,
the Open-Library presenter's exact pattern) → `LibraryHandOffModel.begin` (produce detached
off-main — `produce` itself asserts `notOnQueue(.main)` — reveal-once at completion,
`revealAgain` on the done face, per-arm worded refusals including corner 33's no-key-file).
The registry declaration is consistent on all three exact-equality walks I checked
(`menuRendered == doored(.menuBar)` at CapabilityRegistryTests:254; the `.surface` union at
:498 via DataSafetyPane; the all-capabilities count at :82) — those suites were not in F1's
four re-run suites, but the additions satisfy them by inspection. The zero-caller red is
closed: the presenters, the menu, Settings and VariorumApp all call it now. Strings in the F1
13s table. The pin covers produce → done → the folder classifying `.folderHoldingPair` →
reveal-once → revealAgain, and the refusal arm leaving nothing in the destination.

**M1 (the ceremonies' direct engine drives under a standing hold) — FIXED-PROPERLY.**
The `restoreHoldStands` seam (nil = never held) is consulted at PostureSwitchModel.start:163
for `.enter`/`.replaceKeys` only, BEFORE `checkDoor`; `.leave` verified engine-free by my own
read (leaveCastle:1194–1235 — one vault RPC, a key-file write, a custody move; no
`pullToHead`, no outbox drain, no content round); `.resume` passes the guard (recovery,
P-R1-1's ruled exemption — and `replaceKeysDoor` routes a pending marker to `.resume`).
Wired at VariorumApp:202 off the SAME hold projection as `roundsHeld`, in the same block.
The follow door deliberately stays open under a hold, per the disposition — and I traced
that the no-rotation follow runs no content round (its catch-up funnels through
`resumeSync → triggerSync`, which the hold gates) and the rotation-follow's re-encrypt walk
rewrites server rows only (outbox kept, cursor unmoved, no local apply) — so round 3's and
QD's letters hold on every door left open. Pin + REVERT B consistent.

**M2 (`try?` swallowed a failed hold write) — FIXED-PROPERLY.** The hold rides INSIDE
`LibraryAdoption.execute` as step 3½ — after every refusal arm and the safety copy, before
the move — so a failed write refuses `holdWriteFailed` with nothing moved, an ordinary
refusal leaves no stray marker, and nothing ever lands un-held; both door roads pass
`holding:`; no `try? LibraryRestoreHold.set` survives anywhere (grep). The 4dc05ed6
refinement (create the store folder before the marker write) is sound — the landing created
that folder anyway, and an occupied marker path still fails `Data.write(.atomic)`, which is
exactly how the pin seeds the failure. The pin re-ran green here headless; red-on-old is
structural (all three of the pin's arms depend on the step-3½ block existing).

**M3 (false recovery facts on pre-move refusal arms) — FIXED-PROPERLY.** `failureWording`'s
map verified against the adoption's ACTUAL order: the six pre-move arms (holdWriteFailed now
among them) → nothing-moved, no claimed nets; `moveAsideFailed` → its two real nets (the
safety copy lands at step 3, the moved files in Previous Libraries); `landingFailed` + the
unknown class → the old lead, whose facts are true exactly there (the unknown class in
practice is the plaintext road's post-landing mint steps — past the move by construction).
The no-store-path guard arm reworded too. Pin + REVERT C (13 issues) consistent with the
test's per-arm loop.

**M4 (the waiting-lobby probe races the non-ready adoption) — FIXED for its named window;
INSUFFICIENT at one edge (one MINOR residual, the finding below).** What landed is real and
pinned: suspension BEFORE `work` on both lobby states; the in-flight probe's re-check past
its await (the race a cancel alone cannot close — REVERT D red on exactly that); the
failed-adoption re-arm back to waiting; the probe-won case re-checked. The residual: the
re-check covers `.ready` only, and a probe that completed BEFORE the press leaves the state
at `.opening` for the pool-open's duration — the edge traced as finding R2-1 below.

**M5 (spurious Touch ID on provably-foreign pairs) — FIXED-PROPERLY.**
`pairIsProvablyForeign` (LibraryOpenModel.swift:152–162) is promptless by construction (two
disk reads), returns true only when BOTH fingerprints are readable AND differ, and gates only
the gated arm; the silent arm is untouched and `envelope.belongs(to:)` still backstops the
prompt's result, so no wrong key can ever settle. Pin counts prompts through a wrapped seam;
REVERT E's two quoted failures are the test's two `prompts.value` expectations exactly.
(Noted, below the raise bar: in a crashed mid-rotation instant the live FILE can be one step
ahead of gated custody, making a genuinely same-custody pair read foreign — the cost is one
typed unlock in a state whose marker resume is pending anyway, and the property is inherent
to round 1's own ruled direction, since the gated key's fingerprint cannot be read without
the very prompt being avoided.)

**N1 (Sync-now silent under the hold) — FIXED-PROPERLY.** The door consults the same
`roundsHeld` seam the gate reads (SyncSession:54) and speaks `syncNowHeldRefusal` through
`StatusCenter.refuse` — kind refusal, which always toasts (§12's rule); the gate itself
stays the U2 pin's. UI-honesty arm, correctly unpinned beyond the existing gate pin.

**N2 (the unannotated read-write fallback) — FIXED as dispositioned.** `schemaVerdict`'s
fallback now carries `openForInspection`'s recorded sentence in kind (the sidecar
materialization named, the read-only-volume honest edge named).

**N3 (the false header claim) — FIXED.** The move-aside clause replaced with the true
guarantee (every adoption rewrites the marker — now inside `execute` per M2; Resume alone
clears); checked against the actual departing set at LibraryAdoption (store, sidecars, key
files — the marker indeed not among them).

**N4 (P-U1-1's unrecorded disposition) — RECORDED.** P-F1-1 in the plan carries round 1's
trace in substance (the surviving four local tables, the corner-37 returner with QD-class
pushes, the ledger-reconcile screen, the overturn cost); routed to QUESTIONS at the merge
per the shared-ledger rule. P-R1-1 and P-F1-2…4 recorded beside it.

---

## New findings (severity-ranked)

**[MINOR] R2-1 · App/Variorum/Shared/LibraryOpenModel.swift:347–352 (the non-ready road's
re-check) + App/Variorum/Shared/AppBootstrap.swift:229–231 (`beginOpening`'s re-entry guard)
· M4's residual: a probe that completed BEFORE the Adopt press leaves the state at
`.opening`, which the fix's re-check does not route — the detached adoption work then runs
over a store the pool is actively opening, and the fix's own comment ("If the probe already
won the race, the state is READY now") is false for exactly that instant.**
*Mechanism, traced:* the lobby's probe keeps polling between the sheet's open and the
confirm press (suspension lands only at confirm — deliberate, recorded). A probe completing
in that window calls `complete(key)` → `beginOpening` → `state = .opening` with the pool
open running detached (AppBootstrap:229–252); `.opening` lasts for the open's duration
(routing + SQLCipher open + migration check). A press landing in that window:
`suspendLobbyForAdoption()` matches neither lobby case (no-op), the re-check `if case .ready`
reads `.opening` → false → the detached `work` runs. The wal gate inside `execute` is
"looks closed", not a lock — it refuses only a `-wal` with size > 0 (LibraryAdoption:182–187),
and a just-opened pool that has not written yet leaves no such file — so the move-aside can
relocate the store out from under the opening pool. The landed copy then sits held at the
live path while `reopenAfterAdoption`'s `beginOpening` is a NO-OP (`guard opening == nil`,
AppBootstrap:230) and the IN-FLIGHT open's `finish(outcome)` installs a session over the
aside-moved old inode — her edits land in `Previous Libraries/<stamp>/`'s store while she
believes the restored copy is live. No bytes are destroyed (both stores whole, the hold
marker at the live path even keeps the old session's rounds held) — the same
unowned-two-bindings class round 1 rated MINOR, reachable now only through this one
remaining entry. *Red-on-old pin:* scripted — a `testOpener` parked on a continuation; drive
`probeAppleRoad` to completion so the state is `.opening`; call `confirmAdoption` on a
confirmed model; assert the adoption does NOT run its work while the open is in flight
(store bytes untouched / a refusal or a deferred ready-road teardown). Red on current code:
the work runs. *Fix direction:* in the non-ready branch, treat `.opening` explicitly —
`await bootstrap.awaitOpen()` after the suspension and re-route (the ready road's teardown
then closes the pool it opened), or refuse with one sentence; alternatively suspend at flow
BEGIN (round 1's own direction), which shrinks the window to nothing for the probe road.

**[NIT] R2-2 · App/Variorum/Shared/LibraryOpenCopy.swift:122 + Registry/
CapabilityRegistry.swift:2068–2077 · `handOffDoor` is dead copy and the "can never drift"
claim is enforced by nothing.** Both faces render the REGISTRY's verb (`verb(.handOffLibrary)`
in the menu; `CapabilityRegistry.capability(.handOffLibrary).verb` in Data Safety);
`LibraryOpenCopy.handOffDoor` has zero renderers and zero pins, yet the F1 13s table lists it
as a constant to re-voice — a 13s re-voicing of the constant would change nothing on screen,
the exact drift both comments claim impossible. *Fix:* one source (define the registry verb
FROM the copy constant, or drop the constant and point the 13s table at the registry entry),
or a one-line equality pin. No behavior is wrong today (the strings are equal), hence NIT.

**[NIT] R2-3 · process observation, unattributed · One unidentified flake in the core
suite.** My FIRST full-suite run ended "Some test targets reported failures:
VariorumCoreTests" (the failing test's name lost to this session's own output truncation);
two immediately-following full runs were clean — 2335/269 + 40/6, twice. Not attributable to
the fix range on this evidence (the touched suites re-ran green three times); recorded so the
next full run watches for it rather than being surprised.

---

## Clean bill (checked and found solid)

1. **The fence held in the fix range:** zero `Sources/VariorumCore/Sync/` paths, zero
   `Migrations.swift` edits, zero migrations (marker 12); the custody edits
   (ProtectionController / PostureSwitch-adjacent) were IN-SLOT per the post-merge brief; no
   trailers on any fix-range commit (grep); commits per piece, pushed per the protocol.
2. **The BLOCKER arm cannot false-fire from any crashed-ceremony window** — traced arm by
   arm above (silent custody before step 5 belongs to decision-35's arm; Castle files carry
   no apple wrap; leave-Castle's vault write precedes its file write; `locate` prefers the
   fingerprint-named current file).
3. **The follow doors left open under a hold breach nothing:** leaveCastle engine-free (own
   read); the plain follow's catch-up funnels through the gated `triggerSync`; the
   rotation-follow's walk touches server rows only — the kept outbox and the cursor wait for
   Resume on every road.
4. **The registry's three exact-equality walks** (menuRendered, the surface union, the
   all-capabilities count) are satisfied by the hand-off additions — verified by inspection
   on both sides of each equality, since those suites were outside F1's four.
5. **The hold's conservative direction is coherent end-to-end:** set inside the transaction's
   order (after the safety copy, before the move), unreadable-means-held on read, Resume the
   only clear — and a post-hold mid-move failure leaving the marker standing is the
   conservative direction, recorded in the type's doc.
6. **The F1 record is accurate against the diff:** every finding's named commit contains
   exactly its fix; the revert evidence quotes failures the committed test code would
   mechanically produce; the one mid-slot production refinement (4dc05ed6) is real and was
   committed before any revert, as the resiliency rule asks.
7. **Suite counts verified by re-run here:** 2335/269 + StringsWorkbook 40/6 (twice), and
   the eight touched/neighbouring core suites 44/8 — all green, matching the record's claims
   (+1 over baseline = M2's pin, as recorded).
8. **The copy facts bind where stated:** the mid-move lead's two nets match the real paths;
   the landing/unknown leads' facts hold exactly on their arms; the new follow notice's facts
   match §3.4's law and P-F1-3's recorded reasoning; `resumeSyncFirst` renders only where the
   hold projection exists (P-F1-2's nil-means-never-held).
9. **Nothing in the fix range** tracks word-level change, copies text across entities, or
   scales with corpus size; P-2/P-3 shapes respected (produce and adoption work detached
   off-main; nil hosts render no doors).
