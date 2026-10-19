# VX-308 — LADDER ROUND 1 (cold review, Fable, 2026-10-19)

**Scope:** the phase's whole diff, `git diff daf5c6349...HEAD` on `vx-308-accounts-key-doors` (78 files; the custody core
line `Sources/VariorumCore/Protection/Executor/Acts/KeyDoors.swift`, the one `Sync/` gate `SyncEngine.swift` +
`SyncSchema.swift`, the app-shared protection faces, the tests, the rehearsal's sweep amendment). Prompt:
`notes/REVIEW_PROMPT.md` verbatim (no "Review foci" section exists in the plan — none bound). Canon read whole for this
round: CLAUDE.md + its loaded set, `notes/CastleRules.md`, `notes/SyncSpec.md`, `notes/SurfaceContracts.md` (Doors —
portability + protection), the phase plan `notes/plans/vx-308-accounts-key-doors.md` (all §6 records, arbitrations, Mac
batches). Every mechanism below traced by me in the code; verification runs: `swift test --filter
'FileLessWordsTests|AccountBindingGateTests'` → `✔ 8 tests in 2 suites` (headless, core package only — no stage, no
xcodebuild test, no store touch).

---

## Findings

### MAJOR-1 · `Sources/VariorumCore/Protection/Executor/Acts/KeyDoors.swift:70–123` (with `PlanRunner.swift:334–363, 376–445` and the U3 record's claim) · the file-less mint inherits F-U3-2's stuck-act class with a WORSE blast radius than the record states — the recovery door wedges itself, and (synced) the account's words move to values never shown

**The claim under review.** The U3 record says the file-less arm "inherits it (no worse)" of F-U3-2 (a key-door act
interrupted mid-plan cannot be finished by the next open's settle; ticketed Bug · Confirmed · Medium at the U3
arbitration). That "no worse" is falsified by trace.

**The mechanism (inputs → wrong state), traced line by line:**
1. Rule 27's first-arm state, SYNCED (either posture): the banner's door → `regenerateWords` → `perform` writes the
   act-in-flight + the sealed plan (steps `["vault","keyFile","memory"]`), then the `"vault"` step re-wraps the
   ACCOUNT's words to the freshly minted words (`VaultModel.rewrappingWords` + `updateVault`, KeyDoors.swift:61–68) —
   a network CAS write that LANDS. The minted words exist only in process memory; they are shown only after the act
   returns (`WordsLookModel`).
2. The process dies before the `"keyFile"` step (the window spans the whole vault round-trip plus the gap to the local
   write). Now: the account's twelve words are values NOBODY has ever seen; the library still has no key file; the act
   is in flight.
3. The next open (the silent item — rule 27's state): `settleAct` finds the sealed plan verified and named →
   `resume(plan, …)` (PlanRunner.swift:334–339). `typed` is nil at a quiet open. A key door has `toFingerprint == nil`,
   so `pastCommitPoint` is TRUE (Plan.swift:178–181) — the resume never rolls back, in any arm (vault reachable,
   unreachable, signed out). `drive` reaches the `"keyFile"` step with the REGISTRY's program —
   `KeyDoorProgram(act:)`, `mintsKeyFile` default FALSE (PlanRunner.swift:188) — so the mint arm is skipped and the
   step throws `noLiveKeyFile` (KeyDoors.swift:74–76). Not an `ActRollback` → the error propagates
   (`ProtectionOpenRoad.swift` catch: "the act in flight could not settle now") → **the act stays in flight forever.**
4. Every later act refuses `actInFlight` — INCLUDING the banner door's own mint (`mintFreshWords` →
   `lookRefusal(.actInFlight)` → "busy"). The one road that mends rule 27's state is wedged by its own crash, with no
   door out. Unsynced, the same wedge (crash between begin and the keyFile step — a smaller window, no network call)
   minus the account impact.

**Why this is the phase's, not only F-U3-2's:** F-U3-2 is pre-existing for Change/Reset, where the stuck act blocks a
convenience on an otherwise healthy library. This phase's new arm plants the same mechanism inside the DISASTER-RECOVERY
corner, where (a) the blocked door IS the recovery road, and (b) the synced arm's vault write has already moved the
account's words to unseen values (recoverable only by the account's passphrase through a later New Words — which the
wedge blocks). Rule 20's sentence — "The next open finishes the act or rolls it back from what is on disk, and says
which" — is violated here with materially higher stakes than the ticket's current framing.

**Fix shape (F-U3-2's option (a), scoped at least to the minting act):** a resumed `regenerateWords` whose secrets are
not in hand ROLLS BACK instead of staying in flight — for the minting act the rollback is cheap and rule-20-honest: no
key changed, no file was written, the vault's landed words write stands as any landed CAS write does (the account moved;
re-minting re-wraps it again), and clearing the in-flight act un-wedges the banner door so the NEXT mint completes the
recovery whole. (The general Change/Reset arm stays the ticket's design call.)

**The red-on-old pin:** core, headless — plant the synced file-less state (`FileLessWordsTests.fileLess`'s machinery)
with a key-files leaf whose `writeLiveKeyFile` throws once (the crash between the vault write and the file write); call
`regenerateWords` (it fails mid-plan); then `settle` with no typed secrets and assert the act is ROLLED BACK
(`SettleOutcome.rolledBack`) and a second `regenerateWords` lands the fresh file. RED on this tree: the settle throws,
the act stays in flight, the second mint refuses `actInFlight`. (An unsynced twin pins the smaller window.)

**Also:** whatever the fix's fate, the F-U3-2 ticket's body should carry this arm (the recovery-door wedge + the
unseen-words consequence) — its Medium priority was set on the "no worse" premise.

### MINOR-1 · `Sources/VariorumCore/Protection/Executor/Acts/KeyDoors.swift:266–268` · `keyFileGoneEverywhere` GUESSES on an undecodable remembered payload, against the record's own rule — and the mint's memory step then overwrites that payload

The U3 record (THE CORE LINE, item 7) claims "every remembered item read AS STATED — even an unverified copy refuses
the mint" and "A throwing read refuses (never a guess)". The code: `leaves.memory.readMemory` throwing does refuse
(propagates), but the DECODE is `try? ProtectionCoding.decoder().decode(DeviceMemory.self, …)` with `else { continue }`
— a remembered payload that no longer decodes in THIS build (a newer build's format after a downgrade; a
corrupt-but-present item) is treated as holding NO mirror, and the mint proceeds. The `"memory"` step then
`rememberNewKey()`s — overwriting this library's memory item with the fresh, HISTORY-LESS mirror, destroying a payload a
newer build might have read (rule 4's carried list). Bounded degradation: rule 5's floor holds (every backup still opens
with its own day's secrets); what can be lost is rule 4's current-secrets-reach-older-keys convenience for that span.

The counter-argument the code may be built on (unstated anywhere): refusing on an undecodable item would wedge rule 27's
recovery road forever on bytes no road can read or repair. That is a real tension — but then the record's "never a
guess" sentence is wrong as written, and the guess should be deliberate and logged.

**Fix shape (either is acceptable; the choice is a disposition, not mine):** (a) an undecodable remembered payload FOR
THIS LIBRARY'S ID refuses the mint (conservative: rule 1's restore gets a later chance via a build that reads it), while
other libraries' undecodable items are skipped with a log line; **red-on-old pin:** a planted non-decoding payload under
this library's id + the file-less state → the mint refuses (today it mints — red). Or (b) keep the skip, log it
(`log("… an unreadable remembered item skipped")`), and amend the record's sentence to state the decode-skip honestly —
then this finding is record-only and needs no pin.

### MINOR-2 · `App/Variorum/Variorum/Features/Settings/ProtectionPane.swift:229–235` (+ `RoadCrossingsModel.refresh` / `RoadAccountModel.refresh` / `RoadKeyDoorsModel.refresh`) · "the pane's ONE read" is one code path but THREE concurrent network reads per pane appearance

Each pane appearance fires three `.task`s — crossings, account, key doors — and each runs its own
`ProtectionPaneRead.read` (a facts gather + a vault fetch over the wire). Three vault GETs per appearance where one
would serve all three derivations; and because the fetches are concurrent and independent, a vault that changes between
them can render transiently inconsistent sections (e.g. the crossings derived from fetch 1 say in-sync while the account
section derived from fetch 2 says a follow is owed) until the next refresh. Never a wrong ACT — every press re-reads
(VX-108) — so this is an efficiency/coherence finding, not a bug; no pin applies (architectural: the traced degradation
is 3× wire reads + a transiently split pane). The U2 Mac batch's SIGSEGV (the planted fakes under exactly this
concurrency) was the same seam showing its nature test-side. **Fix shape:** one shared read per refresh wave — the
bootstrap reads once and fans the `ProtectionPaneFacts` to the three models (their `derive`s are already pure over it);
or accept and record the 3× read as deliberate.

### NIT-1 · `App/Variorum/Variorum/Features/Protection/RoadAccountSheet.swift` (ProtectionSheetsHost, the `.signIn` case) · the services-nil fallback shows a wrong sentence

When the `.signIn` sheet is asked for with `services == nil` (a composition hole that should not occur), the body shows
`ProtectionWords.doorRefusedNeedsVault` ("Variorum couldn't reach your account just now…") — untrue of the state. A
dedicated line (or an `EmptyView` + log) would be honest. Cosmetic; unreachable in the shipped composition.

### NIT-2 · `App/Variorum/Shared/Protection/ProtectionWords.swift` (`joinedReceipt`) · "now … now" repetition in Move's same-mode receipt

`joinedReceipt(.sameMode, moved: true)` renders "This library syncs with the account signed in now. Your library uses
your account's passphrase and twelve words now." — double "now". The words are PROVISIONAL (P-VX308-U2-1, her bundle);
carry this to the bundle row rather than fixing in the ladder.

---

## Dispositions I checked and CONFIRM (no new finding)

- **F-U4-3 (F-4's reach):** the gate covers exactly the ruled pair (13x R1-M1 — a synced Use Castle / Replace All
  Keys); account acts and synced key doors that write the vault are ungated and run no sync round. Whether the hold
  should fence every vault write is undefined product behavior, correctly routed to her bundle — not a ruling for this
  ladder.
- **F-U3-1** (assess opens the key doors signed out; the press refuses honestly): ticketed, press-time re-read keeps
  her safe — confirmed as routed.
- **F-U2-1 / F-U2-8 / F-U4-6** (the words-replaced notice on every passphrase-typed join; the unreachable receipt
  fallback arms; the lock's 100 ms poll): each as arbitrated; the poll exits on cancellation, a settled non-Castle
  state, or close — bounded by the act's own life as recorded.
- **P-VX308-U4-5 (the legacy export-mark migration):** the first-consult adoption can attach the notice to a library
  that did not enter (she swapped libraries between the old build's entry and this build's first ready) and the
  not-in-Castle reconcile then clears it — notice-visibility only, exactly the recorded tradeoff; her bundle carries it.

## Clean bill (checked and found solid)

- **The `Sync/` gate (VX-314).** `refuseIfAccountMismatched` sits after the re-key check and before keys in `push()`
  (SyncEngine.swift:202) and at the head of `pullIgnoringMarker()` (:484), so `pull()` and `pullToHead()` are both
  gated; refuses only when both facts answer and disagree; nil-inert verified (today's road passes nothing —
  `VariorumApp` wires `boundAccountRead` only under `bootstrap.newRoad`; the phone passes nothing). The pins
  (`AccountBindingGateTests`) assert outbox-intact, cursor-unmoved, nothing-pushed, heal-without-surgery, and all three
  nil arms — run green here. **The janitor seam:** `reconcileLedger` runs BEFORE the gated round, but a mismatched
  sign-in cannot consume the wrong account's ledger — the key proof is derived from the LIBRARY's account keys and
  verified against the SIGNED-IN account's enrollment server-side, so the RPC refuses; the local drop never runs; the
  sweep itself runs only after a clean (gated) round. `boundAccount` reads the same truth `currentKeys` reads
  (`NewRoadSyncKeyProvider.current?.library.record?.account`); the signed-in side reads the app's live `AuthSession`
  (sign-in/out mutate its tokens in place). The status face's `isAccountMismatchError` is exact-match (re-rendered and
  compared whole), the `isKeysLockedError` rule honored.
- **One law:** `SyncSchema.lockstepVersion` = 13 unchanged; zero schema/migration lines; artifact 17 and its checklist
  stay HELD and PENDING-UNTIL-LIVE (the REHEARSED banner is additive); the sweep's marker-aware filter is correct on
  both sides (`coalesce(…,1) < 14` keeps the `sync_reencrypt` row on a fresh or marker-13 mirror; the `or` precedence
  retires it only at ≥14; the `sync_meta` key name matches `05_phase11_lockstep.sql`).
- **The custody core line (VX-447), beyond MAJOR-1/MINOR-1.** The arm is as narrow as the state: `mintsKeyFile` is set
  only by `regenerateWords` after `keyFileGoneEverywhere` read true, re-read AT THE STEP (TOCTOU honest — a file written
  back meanwhile falls through to the unchanged `noLiveKeyFile` guard); Change/Reset build the program without it and
  keep `needsLiveKeyFile`'s up-front refusal (PlanRunner.swift:207); a resume never mints (the registry's default). The
  guards: in-hand nil AND a fresh disk read nil (a stray refuses — rule 21, pinned with the stray untouched), no mirror
  of the current key in-hand or in any remembered item, no catalogued file of the current key. The mint: the CURRENT key
  (rule 6 — pinned `library.key == key`), the record's epoch, the new words' lock always, the account's verified
  passphrase + master with the vault's post-write words copy when synced (KDF pinned equal to the vault's), no Apple
  lock, no history (the state's own fact), written through the executor's one key-file write, mirrored by the memory
  step; authorization twins exact (Standard+unsynced nothing — P-VX307-U2b-1's twin; synced the vault-verified
  passphrase; Castle+unsynced refuses, and the banner's door is suppressed there — piece 6c). `FileLessWordsTests` pins
  every guard; the suite runs green here. Rule 7's together-change (the vault's words re-wrapped in the same act)
  pinned with old-words-no-longer-open.
- **VX-107.** `RoadSettledFollow.kind` reads only durable facts (the act in flight read BEFORE the settle, the record's
  mode after — `FollowProgram.finishingSteps`' own reading), never the outcome's notices or process memory; the
  double-crash pin (`vx107_aDoubleCrashedFollowStillSaysItsDone`, both kinds) walks two relaunches and asserts
  said-once; `receiptsForNextRoadOpen` carries a receipt only when the act `landedWhole`, so the Done is never said
  twice.
- **VX-113.** `accountSecretRefusal`'s changed-elsewhere arm is byte-parallel to `Follow.swift:163–166` (same
  `known != vault.kdf` condition, same device/day facts; one descriptor names one passphrase, so a change always
  differs); the join's plain `passphraseDoesNotOpen` matches the core's own join-side refusal.
- **The one presenter (VX-239/VX-243).** One sheet at a time; `sheet(for:)` answers the host alone; `replace` hands the
  floor by id; `libraryClosed()` is called at every non-ready settle (`finish`) and the crossing's own reopen settles
  ready so its confirm survives; the sign-in request's `closed` runs on both drop roads; the pane's old
  `.sheet(crossings.confirm)` binding is gone and pinned gone (`RoadCrossingSurfaceTests`).
- **VX-445.** `canLock`/`lock()` on the new road read `roadRelockPolicy` (ready + bound + a Castle record); Standard
  never locks (R13p-14 honored); the teardown order in `lockOnNewRoad` matches `reopenAround`'s first half exactly
  (onWillLock → .opening → resident/deferrals/custody-session dropped → `dropSessionMemory` → references nil'd +
  `newRoadSyncKeys.attach(nil)` → pool closed off-main) with the lobby's road composed FIRST; the lobby is
  `lobbyFacts`, never `route` (no quiet road taken — pinned with a planted stale silent item); `finish(.roadLobby)`
  drops the sheet and clears the clipboard by construction (F-U3-3 closed); the monitors run unconditionally and
  re-check at fire time, the new-road arm reading the policy (sealed `idleLockMinutes`, default 10) and today's arms
  byte-equal in effect with the hook nil; `awaitTheLockSeam` holds the one-act lock through the teardown and exits on
  every settled non-Castle/closed state; two concurrent lock requests converge (the second finds no policy after the
  first lands).
- **VX-448.** `copyConcealed` writes one line + `org.nspasteboard.ConcealedType`, no timer, nothing restored;
  `clearHeld` empties only its own copy by `changeCount` and lets go either way; the one road (`AppBootstrap.copyWords`)
  serves every new-road look; the lock's clear sits in `finish`'s non-ready arm (new road only) and the quit's in
  `applicationWillTerminate` (a no-op on today's road — nothing held); today's 60-second `copy` untouched; the pins use
  private named boards only.
- **NIT-R2-1.** The mark is per library (`variorum.calmAsks.exportOffNotice.<id>.owed`); `markCastleEntry` returns true
  only when it newly marked, so a refusal clears only the here-written mark and never a standing unanswered notice;
  reconcile/dismiss/turn-back-on all key by the open library's record id; another library's ready can no longer clear a
  notice it did not write (pinned, red by behavioural revert per the record); the legacy migration adopts before any
  read or write and removes the key once.
- **F-4.** The gate lives in the ONE read both the pane and the press take (`readCrossings`, both arms — with and
  without the pane read); `heldForRestore` touches only an OPEN, SYNCED Use Castle / Replace All Keys; Use Standard and
  a LOCAL Use Castle stay open; Resume's clear lifts it; the sentence is the shipped hold idiom, pinned as drafted, no
  shouting caps.
- **The signed-out road (VX-264 as amended).** `.signedOutRoad` renders only for Use Castle on
  `.signedOutUseThisMacOnly`; the preflight treats the face as closed; Continue runs the leave re-read at the press
  (`leaveForUseCastle` holds the one-act lock) and hands the floor in place; the born-Castle note rides the request into
  the crossing's receipt; the deliberate pin flip in `RoadCrossingFacesTests` is commented as the unit's target.
- **The account section's acts.** One act at a time; the VX-108 re-read on every press and preflight; the sign-in
  adopted under the act (R-2 — `perform` and `crossOnNewRoad`'s preflight both); re-keying acts take the ONE reopening
  seam (`reopenAround`, extracted with the crossing's exact order; the crossings' suites ride it unchanged); a refusal
  before the swap unmarks only its own rule-11 mark and leaves the library under its old key (disk-checked); past the
  swap the act is LANDED with its Done owed to the settle; the deletion hook runs only when the open library names the
  deleted account, the id read BEFORE the purge, and the signed-out screens catch a hook that could not run. The
  words-moment: shown only for a words-typed join, held behind `interactiveDismissDisabled`, the typed words living
  only in the look; receipt spoken once via `landedOnce`.
- **The key doors.** Change/Reset render only where a passphrase exists by the CORE's fact AND the live file of the key
  stands (rule 27's state leaves only New Words); Castle's Touch ID reset PRESSES the item (a read of custody compared
  to the key); every door says VX-263's line, synced the rule-7 line; the New Words door is the words section's one
  door reading `.newWords` with its refusal in place; the look asks by the core's fact (the stale-stamp trap R-U3-4
  handled, F-U3-5's residue recorded), says F-U2-3's line before minting on a synced library, and adopts the sign-in
  now (piece 6b).
- **Words.** Rule 16 ×2, rule 7 ×2 pinned byte-equal against `notes/CastleRules.md` read at test time; the turning-on
  lead against the lifecycle page; VX-263's line against the plan file; sentence case throughout, a no-shouting pin in
  the hold suite; secrets never logged (ids truncated to 8; `RoadKeyDoorRequest.description` redacted; the walk switch
  logs neither URL nor key).
- **Release unchanged by construction.** Every new behavior sits behind `newRoad`/`roadStanding`/nil hooks
  (`afterAccountDeleted`, `roadRelock`, `accountBinding`) or DEBUG (`ProjectConfig`'s walk override — Release arm reads
  no environment); `relockIfPolicySays`/`relockIfIdle` keep today's arms byte-equal in effect; the core compiles both
  configurations (rule 24 — the VX-447 arm is not `#if DEBUG`-fenced, correctly).
- **Process.** No `Co-Authored-By`/`Claude-Session` trailers in any of the branch's commits (checked across the whole
  range); one author; pins-first commits for F-4 and VX-447 with recorded red runs; the mutation/revert discipline
  recorded per piece with `cmp` restores; the walk switch is both-or-neither, https-with-host only, logged once; the
  canon deltas correctly deferred to the closeout (the two-file rule — nothing in AppSpec/SurfaceContracts touched on
  this branch).

## Counts

BLOCKER 0 · MAJOR 1 · MINOR 2 · NIT 2.
