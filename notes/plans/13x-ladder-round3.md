# 13x — Ladder round 3 (cold review, `fable-reviewer`, 2026-10-07 — the cap's last round)

**Scope:** the whole phase diff — `git diff main...HEAD` on `vx-6-13x-library-portability`
(merge-base 59087a43, HEAD f0fad352; 57 files, ~8.8k insertions) — with the post-round-2 work
as the earned material: VX-80 (the Castle-follow recovery door: `StoreOpenError.keyRejected` +
`failedOutcome`'s widened guard + 4 Mac / 2 core pins), W-1 (`StoreBinding.lock()`'s
checkpoint-truncate + the two adjudicated pin-premise updates), W-2 (`RestoreHoldBar`'s
load-bearing `.lineLimit(4)` + `ChromeMinHeightTests`), and F2 (R2-1's await-then-re-route;
R2-2's one-verb equality pin). Prior rounds' findings and dispositions
(`13x-ladder-round1.md` · `13x-ladder-round2.md` · the plan's F1/F2/VX-80/walk records) were
the anchor; each disposition was re-checked in source. Canon read whole for this round:
SyncSpec (full) · the sync post-mortem · the 13x row in FuturePhases · pre-13x
postures-design §1 · §3 · §6 · §7 · §14 (corners 13 · 28 · 33 · 37 · 44 · 45) · copy §6 ·
the phase plan whole · the VX-80 record. No "Review foci" section exists in the plan or any
13x brief (checked — rounds 1 and 2 recorded the same).

**Verification run by this reviewer (headless only — the stage was left free per the
coordinator's note; every Mac-suite claim is verified against the record's quoted outputs
plus the test files' actual assertions, which I read line-by-line for the VX-80 suite, the
door suite's flow/race pins, the W-1/W-2 pins and the registry equality pin):** the nine
brain suites (StoreBinding · KeyedStoreConvergence · LibraryClassifier · LibraryAdoption ·
LibraryRestoreHold · LibraryPlacementGuard · BackupRestoreCandidates ·
LocalMachineryRecreation · CustodyCollisionRule) **54/9 green**; the drill + keyed-store
suites (SameMacRestore · KeyLeg · ExportAndReturner · StoreEncryption/KeyedStore) **20/6
green**; the two VX-80 core pins green by name. Trailer sweep over the branch: exactly the
one recorded slip (d2ca39f9), every other commit clean. Fence: the whole diff's name set
carries ZERO `Sources/VariorumCore/Sync/` paths and zero `Migrations.swift` edits (marker 12).

---

## Findings (severity-ranked)

**[MAJOR] R3-1 · Sources/VariorumCore/Persistence/LibraryAdoption.swift:255–262 (step 5) +
LibraryClassifier.swift:287–320 (`schemaVerdict`) · A picked source carrying a non-empty
`-wal` adopts INCOMPLETE — the landing copies the main file alone, silently dropping the
source's WAL tail; the sibling (shm-less) arm refuses with a FALSE "wrong key" sentence.**
*Mechanism, traced end to end and the load-bearing premise DEMONSTRATED empirically
(scratchpad, system SQLite — the WAL mechanics SQLCipher inherits):* a library folder copied
while hot (store + `-wal` + `-shm` — the ordinary Finder copy of a running, crashed or
force-quit library; W-1 truncates the wal only on `binding.lock()` roads, never at process
death) classifies `.encryptedLibrary`/`.folderHoldingPair` (the classifier's own doc names
"a hand-copied library folder" as a served shape, LibraryClassifier.swift:37–38); nothing in
the flow examines the SOURCE's `-wal` (step 2's gate reads only the LIVE store's;
grep-confirmed no other site); `schemaVerdict`'s read-only open SUCCEEDS over the copied trio
and reads THROUGH the wal (demonstrated: a read-only connection over a hot-copied trio
returns the wal-only row and leaves the 4KB wal intact on close — read-only connections never
checkpoint), so the confirm renders normally; `execute` step 5 then runs
`fm.copyItem(at: plan.sourceStore, to: plan.landedStore)` — the main file ALONE — and the
landed, held library is missing exactly the rows the flow's own schema consult just read
(demonstrated: the main-file-only copy lacks the wal-only row). Nothing is destroyed (the
source stays whole), but the adoption reads as complete while the newest writes are absent —
on the phase's own deliverable-2 door. The SEALED roads (the hand-off product, the backup
pairs — WAL flattened by `StoreBackup.integrityCheck`) are unaffected; the exposure is
precisely the hand-copied class. *The sibling arm:* a copy WITHOUT its `-shm` fails at the
first read, which sits OUTSIDE `schemaVerdict`'s fallback (the init-scoped `do/catch` at
:292–306 wraps only the `DatabaseQueue` construction, and GRDB's init runs no reading
statement) — the verdict is `.unreadable`, which `LibraryOpenModel.settle` (:265–266) maps to
`wrongKeyRefusal`: *"That key file doesn't open this library — it belongs to another copy"* —
false on both facts (the key is right; the copy is merely hot). *Red-on-old pin (headless
core):* a keyed store written through a pool, the trio copied beside its key file while the
wal is hot (pool open, or checkpoint withheld); run the door's exact call sequence
(`classify` → `schemaVerdict(at:key:)` → `LibraryAdoption.plan/execute`); open the landed
copy under the key and `#expect` the walled row present — red on current code (row absent).
*Fix direction:* step 5 copies the source's `-wal`/`-shm` when present (the keyed open
recovers them — the most faithful to "the file you picked is only read"), or step 1 refuses a
source with a non-empty `-wal` naming the remedy; and the `.unreadable` settle arm stops
wearing the wrong-key sentence (render the unreadable refusal with its reason instead).

**[MINOR] R3-2 · App/Variorum/Variorum/VariorumApp.swift:162–166 + :195/:202 ·
Round 3's ruled hold is gated on a VIEW-LIFECYCLE-COUPLED cache of the marker, not on the
marker — correct today only by coincidence of trigger-road placement.** *Traced degradation
(architectural; no deterministic breach completes on today's roads, and I say so):*
`SyncSession.roundsHeld` and `ProtectionController.restoreHoldStands` both read
`RestoreHoldModel.isHeld` — a projection whose ONLY refresh site is the main window
RootView's `.task`. An adoption run from the SETTINGS scene with the main window closed
(reachable: Settings is its own Scene; `bootstrap.state` stays `.ready`; the Restore rows and
the flow work there) leaves the marker standing on disk while the projection still answers
`hold == nil` — both gates then answer "not held" until a main window next renders. What
saves it TODAY: every live trigger road is either window-coupled (the became-active
`onReceive` and the Sync-now door live on the main window's tree, so the `.task` refresh
lands at attach before they can fire) or dead after the adoption's lock (the settle
observation ends at `binding.lock()` and only `configure` re-arms it — SyncSession.swift's
own "observation ended" comment). So the ruled contract — "until Resume, no round runs for
this store" — currently holds by the accident that no trigger road survives into the stale
window; any future road (18a's pause/scheduler work, a timer, a menu-bar sync door, an
engine-side trigger) silently bypasses the hold on exactly this path, and the M1 ceremony
guard goes stale the same way. *Fix (one line each):* the two gate closures read
`LibraryRestoreHold.isHeld(besideStore:)` directly (one file stat — the marker IS the fact;
the projection keeps serving the banner), or `adoptLibrary`'s completion refreshes the
projection. A pin then exists for free (gate consulted with no view alive → zero transport
calls) — today it would need the stale-window interleaving I could not force, which is why
this is MINOR-architectural rather than a pinned bug.

**[NIT] R3-3 · Linear VX-95 (the W-2 fallout sweep ticket) · Projectless Backlog.** The W-2
record's "ticketed (below)" promise IS kept — VX-95 ("P-8 scan is blind to explicit-axis
fixedSize — 158 unlimited chrome sites unverdicted") exists — but it sits in Backlog with NO
project and no Parked-with-reason state, against CLAUDE.md's "every ticket carries a project
or an explicit Parked state WITH a reason; unowned/reason-less ⇒ fix it now". A closeout
line: home it or Park it with the reason.

---

## Clean bill (checked and found solid, this round's own verification)

1. **W-1:** `StoreBinding.lock()`'s checkpoint-truncate is narrow and honest — swapped-to-
   locked first, checkpoint via `try?` (a failure degrades to the adoption gate's refusal,
   never to an unlocked store), close unchanged; the pin
   `lockLeavesNoHotWalBesideTheClosedStore` re-run green HERE with a live observation held at
   lock time. The two fallout adjudications are honest premise updates, not hollowed pins:
   the convergence pin now asserts WAL non-emptiness + ciphertext WHILE the pools are open
   (the sibling pin's shape) and the post-lock main-file scan covers the checkpointed frames;
   the key-leg drill's `readMarker` is now genuinely read-only, making its
   bytes-identical-across-the-key-event claim literally true.
2. **W-2:** `.lineLimit(4)` is commented load-bearing and pinned both ways
   (`restoreHoldBarNearZeroWidthProbeStaysBounded`: the near-zero-width probe bounded < 400 pt
   — red-on-old at 2668 — AND the sentence renders whole at a real width). The 13x-diff sweep
   verdicts check out (both sheets carry `.frame(minWidth: 460)` floors; DataSafety is a
   grouped scroll-backed Form). The main-side P-8 red is OWNED (VX-94, In Progress on
   VX-83's branch — verified in Linear) — accounted, never a 13x regression.
3. **VX-80:** the `keyRejected` classification is exactly one class — NOTADB ∧
   `presence == .encryptedOrUnknown` ∧ key-in-hand (an encrypted presence never mints) — at
   AppDatabase+Dependency.swift:121–134; `migrateIfNeeded` no-ops before it on encrypted
   presence so no wrong-key error can bypass the catch; P15 holds (the reason carries neither
   key's hex — pinned, re-run green here); the class separation from `keyUnavailable` pinned
   on both sides. `failedOutcome`'s one-guard widening serves the SAME typed-secrets lobby
   with biometry correctly off on both classes (any gated item holds exactly the key that
   failed); the unreadable-sidecar P11 doorless parity carried onto the new class; the
   demanded-gate saveAuto suppression AND the silent-shape heal both pinned (the 4-test Mac
   suite read assertion-by-assertion — non-vacuous; its red-on-old ran on the actual pre-fix
   tree, cleaner than a revert, and the record correctly notes any future revert must use the
   named pin alone since the siblings reference `keyRejected`). The downstream is the
   standing machinery untouched — zero `Sync/` lines, zero view changes.
4. **F2:** the await-then-re-route loop cannot spin (each lap awaits a real task whose
   `finish` nils `opening`; the re-suspend covers the fresh lobby each settle); ready routes
   through `adoptLibrary`'s teardown (the pool the probe opened closes); a task-less
   `.opening` refuses nothing-moved; the pin drives the exact mechanism (opener parked on a
   semaphore, probe driven to `.opening`, press mid-flight asserting phase/bytes/hold all
   unmoved) and its assertions match REVERT F's four quoted reds exactly. R2-2's equality pin
   (`theHandOffVerbReadsTheOneCopyConstant`) is the enforcement, and the registry's
   `.handOffLibrary` genuinely declares `verb: LibraryOpenCopy.handOffDoor`.
5. **The R1-BLOCKER arm, re-checked in source** (ProtectionController.swift:~680): fires on
   determined-Castle ∧ ids-agreed ∧ live-key-file-apple-wrap ∧ `!switchInProgress`; the
   silent-shape arm precedes it (decision-35's kind untouched); the notice plumbing
   (body/waitingBody/laterSubline) is factually consistent with §3.4's Castle row and
   P-F1-3's recorded reasoning. M1's guard at PostureSwitchModel.start:160–166 (the two
   rotation ceremonies only; `.resume` exempt), M3's `failureWording` map against the
   adoption's REAL arm order (holdWriteFailed correctly in the nothing-moved set), M5's
   promptless fingerprint comparison, N1/N2/N3 — all in place as dispositioned.
6. **The hold machinery end to end:** step 3½ inside `execute` (fail ⇒ `holdWriteFailed`
   with nothing moved; ordinary refusals leave no stray marker; the 4dc05ed6 folder-creation
   refinement keeps the occupied-path failure seedable); unreadable-means-held; Resume the
   only clear, marker cleared BEFORE `onResume` so the resumed round passes its own gate;
   `roundsHeld` wired before `start()`; Sync-now speaks the refusal through the status seam.
   The drills re-run green here: the same-Mac restore (QD's exactly-one-conflict-card, the
   duplicate surviving, the re-trashed original leaving, one device identity), the export's
   §14.13 zero-push letter, the foreign-owner adopt partition, the returner/purge fence
   (nothing re-pushes a purged row; the queued family edit swept), the older-key day pair
   byte-identical across the re-key with the collision rule's three verdicts, both
   newer-schema consults with exact identifiers.
7. **The fences and process:** zero `Sources/VariorumCore/Sync/` paths and zero
   `Migrations.swift` edits in the whole diff (git name-set, verified); marker 12, zero
   migrations; custody-ITEM code untouched (the collision write calls the shipped
   `saveAuto`/`saveGated`/`delete*` doors only); the trailer sweep shows exactly the one
   recorded slip (d2ca39f9); commits per piece, pushed; the VX-80/W-1 tree-sharing was
   pathspec-disciplined as recorded.
8. **The custody-collision rule + `landCustody`:** pure verdicts pinned; the write follows
   the ADOPTED store's effective gate (auto ⇒ silent + gated deleted; biometric ⇒ gated +
   silent deleted; passphrase ⇒ neither — the custody law's letter); M/C/device identity
   untouched; the guard resolves the store id lazily per act so post-landing writes act under
   the adopted id (round 1's clean-bill item re-confirmed).
9. **VX-64:** the tool refuses a plaintext store outright, unlocks by key file + typed
   passphrase + in-memory custody (no Keychain), types every refusal arm; the record's
   red-on-old revert is quoted both ways.
10. **P1/P2/P3 and the prohibitions:** classify ∝ the picked thing; the restore listing ∝
    one folder's names; produce/adopt/classify detached off-main; nothing tracks word-level
    change, copies text across entities outside the ruled family-copy roads, or scales with
    corpus size.
11. **The air-leg brief** is safety-sound (A1 first, zero-instance window, her hands only,
    the stranded fixture read-only, no stage acts on the Air).
12. **Open by design at this round** (U3's, not findings): the FAQ brief un-flag (deliverable
    4 / ledger 11), canon deltas, the 16 ratified PROVISIONALs' QUESTIONS landing at the
    merge moment, the in-flight row retirement, the handoff file, her AirDrop acceptance leg.

**Evidence stance on Mac-suite claims:** the stage rule bound this session (and the
coordinator released the stage mid-review), so the record's Mac counts (door pins 5/5 + two
reverts · F1 76/4 + five reverts · F2 106/5 + REVERT F · VX-80 4/4 + the 21:58 red) are
verified against the quoted outputs and the committed test code's actual assertions — each
quoted red is one the test code would mechanically produce under its named revert; none is
vacuous. No Mac run is owed for this round's findings (R3-1's pin is headless core). If the
orchestrator wants one belt anyway, the exact command is:
`xcodebuild -scheme Variorum -destination 'platform=macOS' test-without-building
-only-testing:VariorumTests/LibraryPortabilityDoorTests
-only-testing:VariorumTests/VX80CastleFollowRecoveryTests
-only-testing:VariorumTests/ChromeMinHeightTests` (from `App/Variorum/`, under a held stage
claim; expect the known VX-94-owned `everyBareFixedSizeStatesItsLinePolicy` red if
ChromeLineLimitTests rides along).
