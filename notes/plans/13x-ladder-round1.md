# 13x — Ladder round 1 (cold review, `fable-reviewer`, 2026-10-07)

**Scope:** the whole phase diff — `git diff $(git merge-base origin/main HEAD)...HEAD` on
`vx-6-13x-library-portability` (merge-base 18270b70, HEAD 738a671c). Canon read whole for this
round: SyncSpec (full), the sync post-mortem, the 13x row in FuturePhases, pre-13x
postures-design §§1–3 · 5–7 · 14 (corners 13 · 28 · 33 · 37 · 44 · 45) + ledger rows 4 · 5 ·
14 · 22 · 42 · 71, copy §6 · §8, the phase plan whole. Headless re-runs by this reviewer:
the seven new core suites (42/42) and the three drill suites (7/7) — all green. The Mac-suite
claims (5/5 + two behavioural reverts) are verified against the record's quoted outputs only
(the stage rule binds this session too). No "Review foci" section exists in the plan or a
brief beside it; nothing mandatory beyond this sweep.

---

## Findings (severity-ranked)

**[BLOCKER] · App/Variorum/Shared/LibraryOpenModel.swift:341–376 (`landCustody`) +
App/Variorum/Shared/ProtectionController.swift:621–648 (`reconcileFollow`) · A same-Mac
adoption of a Standard-era (pre-Castle) snapshot pair onto a Castle account leaves the LIVE
library permanently Apple-openable — the posture law (pre-13x decision 28; §3.4's Castle row
"library key, WRAPPED — under P, W, M only") violated in steady state, including for writing
authored AFTER the restore.**
*Mechanism, traced end to end:* a pre-Castle backup pair's key file carries L_old wrapped
under A (§3.4 Standard row; decision 11/row 42 — the pair is the live key file's copy of its
day). The adoption lands that key file beside the store whole (`LibraryAdoption` step 5).
`landCustody` then reads `gate.effectiveGate(...)`: the store id is the SAME (stable across
re-keys, §3.5), so `syncCustodyPresent` is true ⇒ `Posture.derive` returns
`.indeterminate(shape:)` (StoreProtection.swift:92–97), and the shape is `.castle` (the raw
key moved behind Touch ID at the Castle entry ⇒ `rawKeyCustody == .gatedOrNone`) ⇒ the gate is
`.biometric` ⇒ `saveGated(L_old)`. From then on NO detector ever closes the exposure: the
rotated-keys follow arm keys on `custody.corpusKeyID != vaultKeyID`
(ProtectionController.swift:621) and the ids AGREE (this device followed the rotation when it
happened); decision 35's follow-into-Castle arm keys on `shape == .silent`
(ProtectionController.swift:~644) and the shape is GATED; `reconcileAppleKey` under a
determined Castle posture only clears flags (ProtectionController.swift:1445–1458);
`retireOldKeyFiles` runs only inside a follow that is never owed. The code's own doc names the
landed state: *"a Standard-era key file (an `apple` copy) beside a Castle library is the
exposure itself"* (PostureSwitch.swift, `retireOldKeyFiles` header). *Consequence chain:*
every post-restore snapshot pair (`StoreBackup.writeSnapshotKeyFile` copies the LIVE key
file's bytes) carries the A wrap too, and backups may live in iCloud Drive (decision 24) — so
her corner-29 attacker (inside the Apple account) reads post-switch writing, which §2's Castle
table promises is exactly who Castle stops. The NEW-Mac road self-heals (the pair lands under
`.auto`/silent because the machine is not enrolled, so decision 35's silent arm fires at the
enrolled ready and the follow re-keys); only the same-Mac road — this phase's deliverable 3's
own scenario ("a copy from before a Replace All Keys **or a Castle entry**") — has the hole.
No drill covers it: leg 2(d) drills the Replace-All-Keys re-key with no Castle-account world.
*Red-on-old pin:* a scripted composition — Castle account (vault reading
`hasAppleHeldCopy == false`), same store id, custody gated and corpus-key ids current, the
live key file carrying an `apple` wrap (the landed pair) — asserting a follow is OWED (or that
no live A-openable copy survives the adoption's completion). Red on current code: no notice,
no re-key, the wrap stands.
*Fix direction (the fence: ProtectionController is custody code — sequences post-13o-merge):*
a reconcile arm that owes the follow-into-Castle whenever the posture is DETERMINED Castle and
the LIVE key file carries an `apple` copy (the no-rotation road in `runFollow` already exists
for exactly this shape), and/or the door saying it at confirm + owing the follow at Resume.

**[MAJOR] · App/Variorum/Shared/LibraryHandOff.swift (zero callers) · THE HAND-OFF ACT HAS NO
DOOR — deliverable 1 of the 13x row ("an in-app door that produces the travelling pair
somewhere a user can actually find and AirDrop; never 'dig in ~/Library'") is brain-only.**
*Evidence:* `grep -rn "LibraryHandOff" App/ Sources/` returns only the file itself and its
test suite — no menu item, no Data Safety door, no reveal-in-Finder, and the U2 strings table
carries no hand-off string. The gap is a hand-off between records: U1 row 2 built the producer
"the U2 door renders; reveal-in-Finder at completion"; U2's brief did rows 6–9 where row 6's
"two doors" are QB's two ADOPTION doors; U2b closed with "the build is complete pre-merge;
zero deferred pieces". The plan's remaining walk is scoped to "the two doors", so nothing
downstream owns it either. No pin applies (missing feature, not wrong code — evidenced by the
zero-caller grep). *Fix:* the face (File menu and/or Data Safety: produce → reveal in Finder),
its strings in the 13s table, and a Mac pin; then the AirDrop leg stays hers at the walk.

**[MINOR] · App/Variorum/Shared/SyncSession.swift:165/173 + App/Variorum/Shared/
PostureSwitch.swift:512 (`engine.pullToHead()`) · The restore-hold gates the scheduler's roads
only — the key ceremonies' direct engine drives run under a standing hold.**
*Mechanism:* `roundsHeld` is consulted in `triggerSync()`/`flush()` and every scheduler road
funnels there (verified: all `scheduler.trigger()` sites). But `PostureSwitchRunner`'s
switch/rotation roads drive the engine directly (`pullToHead` at PostureSwitch.swift:512; the
mid-rotation follow's corpus walk via the transport), so Replace All Keys or Use Castle pressed
while the hold stands runs full engine work — content catch-up and the corpus re-push —
before Resume, breaching round 3's "until it, no round runs for this store" and QD's "the kept
outbox pushes at Resume". Honest narrowing: the PLAIN follow (no rotation in flight) does NOT
run a content round — its catch-up goes through `AppServices.resumeSync → triggerSync`, which
IS gated — so the reachable breach needs a user-driven key ceremony (or a mid-flight rotation)
while held. *Red-on-old pin:* a scripted runner switch (or rotation-in-flight follow) with the
hold standing, asserting refusal/zero transport data calls — red on current code. *Fix
direction:* the un-followed-device precedent — the key doors refuse under a standing hold with
one sentence ("Resume sync first"), or the runner's leaves consult the hold.

**[MINOR] · App/Variorum/Shared/LibraryOpenModel.swift:283 and :304 · `try?
LibraryRestoreHold.set(...)` swallows a failed hold write — an adoption whose marker cannot be
written lands UN-held and catches up at the next trigger, the exact silent catch-up round 3
exists to prevent.** The conservative direction is the opposite of `LibraryRestoreHold.read`'s
own unreadable-means-held rule. *Mechanism:* any write failure beside the store at completion
(disk-full mid-adoption is the realistic arm) → no marker → `roundsHeld` false → the first
settle/became-active trigger runs the catch-up with no banner ever shown. *Pin note, honest:*
the failure seam is unseeded (static API, same folder just written), so a red-on-old pin needs
the fix to make the failure LOUD first — e.g. let the set's throw fail the adoption's
completion into the refused arm (the error path already exists), then an ordinary error-arm
pin covers it. *Fix:* drop the `try?` (both roads) and surface the failure.

**[MINOR] · App/Variorum/Shared/LibraryOpenCopy.swift:116–118 (`adoptionFailedLead`) + 
LibraryOpenModel.swift:325–328 · The one failure lead states facts that are FALSE on the
pre-move refusal arms.** "…your current library is whole in its dated copy and the safety
copy" renders for EVERY `AdoptionError`, including `sourceMissing` / `sourceKeyFileMissing` /
`sourceKeyFileUnreadable` / `libraryLooksOpen` / `safetyCopyFailed`, where NO dated copy (and
for most, no safety copy) exists — the user is pointed at recovery artifacts that are not
there. Words are 13s's, but the FACTS are binding (the copy conventions). *Pin:* a model pin
asserting a pre-move refusal's message does not claim the dated copy — red on current code.
*Fix:* word per failure class (the catch arm holds the typed error), or reserve the second
sentence for the arms where something moved.

**[MINOR] · App/Variorum/Shared/AppBootstrap.swift (`reopenAfterAdoption`) +
LibraryOpenModel.swift:311–322 (the non-ready road) · The waiting-lobby's Apple re-probe keeps
polling while the adoption flow runs over it; the probe is stopped only AFTER `work` ran.**
*Mechanism:* in `.waitingForICloudKeychain`, `StoreLobby.beginWaiting` polls the Apple road
every ~5 s and `complete(key)` opens the pool the moment A lands. The non-ready adoption road
runs `work()` (wal-check → safety copy → move-aside → land) with the lobby still live; if the
probe fires between the wal check and the move, the pool opens over the departing store — the
move relocates a pool-held file (the old pool then writes into the aside home) and
`reopenAfterAdoption`'s `beginOpening` races a `.ready` transition it did not expect. No
data-destroying outcome traced for the LANDED copy (its bytes are already placed), but two
bindings over two files is an unowned state. Timing-dependent yet deterministically pinnable
(a scripted `appleRoad` released mid-work). *Fix:* stop the standing lobby's waiting (and/or
re-check state) when the flow BEGINS, not after `work`.

**[MINOR] · App/Variorum/Shared/LibraryOpenModel.swift:169–178 (`beginUnlock`'s gated arm) ·
Picking ANY encrypted pair on a gated (Castle) Mac fires a Touch ID prompt even when the pair
is provably foreign.** `guardSeam.gatedItemExists()` ⇒ `unlockGated()` prompts before
`envelope.belongs(to:)` can be known — but the pair's `keyFingerprint` and the LIVE key file's
`keyFingerprint` are both readable WITHOUT any prompt, so a differing pair could skip the
gated ask entirely (the second look can only ever serve a same-key copy). Cost today: a
spurious biometric prompt that then "fails" into the typed roads — confusing on the exact
older-key-restore road this phase ships. *Pin:* a scripted-guard test counting `unlockGated`
calls when the fingerprints differ — red on current code. *Fix:* compare fingerprints first;
prompt only on a match (or on an unknown fingerprint).

**[NIT] · App/Variorum/Shared/SyncStatusViews.swift:466 · The manual "Sync now" door is a
silent no-op under the hold** (`triggerSync` returns on the gate with no receipt/refusal) —
§12's "a door that did nothing speaks a refusal". One quiet line ("Sync is waiting — Resume
below") honors the contract; the banner's presence mitigates but does not speak at the door.

**[NIT] · Sources/VariorumCore/Persistence/LibraryClassifier.swift:264–271 + :287–297 · The
read-write fallback opens the PICKED SOURCE writable.** `openForInspection`'s comment records
the sidecar materialization; `schemaVerdict`'s identical fallback carries no such note, and a
hot-journal source would be modified by a writable open (a near-dead path — the fallback fires
only when the read-only OPEN itself throws — but the never-rewritten doctrine deserves the
same recorded sentence there, or an immutable-style read).

**[NIT] · Sources/VariorumCore/Persistence/LibraryRestoreHold.swift:12–17 · The header's claim
"`LibraryAdoption`'s move-aside relocates the whole store-folder family, so a stale marker
never outlives the library" is inaccurate** — the marker is NOT in the move-aside's departing
set (store, sidecars, key files only; LibraryAdoption.swift:161–169). The guarantee actually
rests on the next clause alone (every adoption rewrites the marker; Resume clears it). Comment
fix, so the next reader doesn't build on the false half.

**[NIT] · the U2 RECORD (the plan file) · P-U1-1's disposition is implemented but unrecorded:**
`LibraryOpenModel.land` routes `.plaintextLibrary` (a pre-13p FULL plaintext library) down the
same plaintext road as an export — but unlike an export its four local tables SURVIVE
(`recreateIfMissing` skips present tables), so a surviving cursor and possibly a non-empty
outbox ride under a FRESH store id + fresh identity: a corner-37 returner with QD-class outbox
pushes, screened by the ledger reconcile. The behavior looks coherent, but it is a different
§14.13 story than the export's zero-push letter and is nowhere said. Record it (the plan /
QUESTIONS at the merge moment, where P-U1-1 already lands) so it is a choice, not a discovery.

---

## Clean bill (checked and found solid)

1. **The fence held absolutely:** the diff's name set carries zero `Sources/VariorumCore/Sync/`
   paths, zero custody/keychain-item code (`StoreKeyCustody`/`StoreKeyKeychain`/
   `EncryptionKeychain`/`KeychainCustody` untouched; the collision write only CALLS the shipped
   `saveAuto`/`saveGated`/`deleteAuto`/`deleteGated` doors), `Migrations.swift` untouched, zero
   migrations, marker 12.
2. **The hold chokepoint is real:** every `scheduler.trigger()` site in the codebase is inside
   `triggerSync()`/`flush()`; the settle observer, became-active hook, Sync-now door and
   `AppServices` roads all funnel through them; the gate is wired BEFORE `fresh.start()`; the
   scheduler has no timer of its own. (The one bypass class is finding 3's — the key
   ceremonies, not the scheduler.)
3. **QD end-to-end (re-run green here):** the kept outbox survives the backup, the stale-dirty
   row lands as EXACTLY ONE conflict card carrying the dead Mac's words on BOTH devices, the
   server text wins the row, the duplicate survives, the re-trashed original leaves, dumps
   byte-identical, ONE device identity (`LibrarySameMacRestoreDrillTests`).
4. **§14.13's letter (re-run green):** `LocalMachineryRecreation` covers the registry exactly
   (set-equality pin), schema-equality against a freshly migrated store per table, the
   refusal-before-recreation red living INSIDE the pin; leg 3's zero-push same-owner catch-up
   and the foreign-owner adopt-into-own-partition both green.
5. **The returner/purge fence (re-run green):** ledger reconcile before the drain, the queued
   family edit swept WITH the family, `push.purged == 0`, ledger count unchanged by the
   returner, dump equality with the fleet — and `reconcileLedger` runs before EVERY round
   (SyncScheduler:191), so the same-Mac rewound-cursor restore is screened by the same pass.
6. **Decision 11 honored at the door:** the source-gate override (`loadEnvelope` → the
   classifier's key file, `saveEnvelope` → no-op) means the vault road can never rewrite a
   picked pair; corner 44's byte-identity across a re-key re-run green (leg 2d), and the
   hand-off/adoption pins assert source byte-identity throughout.
7. **The classifier's verdict table:** 20/20 re-run green; `backupNameFingerprint` and
   `BackupRestoreCandidates.backupDate` both restate `StoreBackup.date(fromBackupURL:)`'s
   exact strictness (stamp round-trip + `-` + 8 lowercase hex), so A1-rail and drill names are
   excluded from the listing; the mismatched-pair fp8 guard refuses rather than offering a
   file that cannot open the snapshot.
8. **`landCustody` over per-store-id custody:** `StoreKeyGuard.keychain` resolves the store id
   lazily at each act (StoreKeyGuard.swift:81–94), so the post-landing writes act under the
   ADOPTED id; `alreadyAligned` short-circuits before any write; M, C and the device identity
   ride the sync-custody item untouched (the memo's letter); the Always-ask arm writes no item.
9. **`LibraryAdoption`'s order and honesty (re-run green):** source verified first, A1 safety
   copy before any move, whole-folder before/after snapshots pin that refusals change nothing,
   the pair-name normalization lands the canonical key-file name, the plaintext arm lands the
   store alone, and the one non-atomic window is recoverable from BOTH nets.
10. **VX-64:** the tool now takes the StoreUnlock road (key file + typed secret + in-memory
    custody, no Keychain), refuses a plaintext store outright, and types every refusal; the
    record's red-on-old behavioural revert is quoted in both directions (the env-gated fixture
    minter is by-design skipped here; the tool drill itself was not re-run by this review).
11. **The Mac-slot evidence** (door pins 5/5; revert A red exactly on the hold gate, revert B
    red exactly on the picker's three arms) is consistent with the test file's actual
    assertions — the pins are non-vacuous and would catch exactly the claimed reverts; not
    re-run (the stage rule binds this session).
12. **Process hygiene:** branch trailer sweep shows the ONE recorded slip only (d2ca39f9,
    already recorded in the plan's machinery notes); every later commit trailer-free; commits
    per piece, pushed per the resiliency protocol.
13. **Owned inheritances resolved in this diff:** pre-13x ledger rows 4 (the iCloud-Drive
    guard — both faces, the ONE sentence), 5 (the open door + §14.13 + the second look), 22
    (the recreation) and row 14's U4→13x half (the second look in the candidates brain). Row
    71 (the FAQ publish) is U3's and correctly still open.
14. **Nothing in the diff** tracks word-level change, copies text across entities outside the
    ruled family-copy roads, or scales with corpus size (classify ∝ the picked thing; the
    restore listing ∝ one folder's names); P-2/P-3 shapes respected by both faces (roads
    rendered only where they exist; heavy work detached off-main).
