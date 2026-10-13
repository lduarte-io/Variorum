//
//  PostureSwitch.swift
//  Variorum (shared: Mac + Mobile — the two switches' ONE brain; the Mac's
//  ceremony sheet and the phone's (2c) compose it)
//
//  pre-13x batch 2b — ENTERING AND LEAVING CASTLE + THE ROTATION RUNNER
//  (the postures design §4, decisions 6 / 7 / 10 / 11 / 31 / 32; the BATCH 2
//  brief's "2b — REFINED AT 2a's SEAM" items (1)–(5)). ONE runner type with
//  `entersCastle`: entering Castle is §4 whole; Replace All Keys (batch 3's
//  door) is steps 1–4 without the posture change — the same road, the same
//  marker, the same driver. It REPLACES the 14c `AccountRekey` brain: that
//  road TRUNCATED the mirror and re-pushed local truth; this one rotates IN
//  PLACE through `sync_reencrypt` (version-neutral — no other device's
//  offline edit is ever rejected, followers apply nothing) and never
//  truncates.
//
//  THE STEPS (§4), each advancing the per-step persisted marker
//  (`RotationMarker` in the library's local-only `sync_state`) so a crash
//  at ANY step re-runs to completion — `resume()` — on this device, and any
//  device holding M′ can finish step 3:
//    1. PULL TO HEAD (sync users): push what this device owes, pull to
//       head, refuse a non-empty outbox, refuse while the vault carries a
//       previous corpus key (decision 32 — the sentence names it), refuse
//       offline (the transport's own throw).
//    2. ROTATE THE SYNC KEYS: `CorpusRotation.begin` — M′ + C′ minted, the
//       vault rewritten ONCE under the OLD proof (M′ under P and W; C′ and
//       the OLD C under M′; the hash replaced; no Apple-held copy when
//       entering Castle; the copy KEPT under Standard's Replace All Keys —
//       decision 30); M′ / C′ / the previous key + the seq into custody
//       under the CURRENT shape.
//    3. RE-ENCRYPT THE SERVER COPY: `CorpusRotation.reencryptRemainder` —
//       every row below the rotation seq, N of M; then the completing write
//       clears the previous key + the seq together; custody drops it.
//    4. RE-KEY THIS LIBRARY: a NEW key file under the new fingerprint FIRST
//       (L′ under P, W and M′ — no Apple copy when entering Castle; the
//       Apple copy again under Standard's Replace All Keys), so a crash
//       after the swap leaves a file the key file's master copy opens;
//       then the export-and-swap (`StoreEncryptionMigration.rekey`) with
//       the pool closed and the store reopened under L′ (the bootstrap's
//       road). The old key file stays beside old snapshots.
//    5. CUSTODY: both items move through `moveCustody(to:)` — Touch ID or
//       nowhere when entering Castle (re-lock ON by derivation); re-saved
//       silent under Standard's Replace All Keys.
//    6. A FRESH SNAPSHOT PAIR under the new key BEFORE anything is offered
//       for deletion; the scheduled plaintext `.md` insurance OFF with one
//       notice (entering Castle).
//    7. THE OFFER: the runner LISTS the app's own pre-switch pairs (every
//       snapshot whose fingerprint is not the new key's); the ceremony asks;
//       `deletePreSwitchSnapshots` removes pairs only. The marker clears at
//       the end of step 6 (the offer is a choice, and "Keep Them" is a valid
//       end — a marker that held sync hostage to an OFFER would be wrong).
//  Without sync (no vault): steps 4–7 only, the ceremony's secrets landing on
//  the key file alone.
//  LEAVING CASTLE (§4's second act): A read from iCloud Keychain (minted if
//  absent); ONE vault write under the CURRENT proof adding M under A; the
//  key file's `apple` copy of L; custody gated → plain (both items); re-lock
//  off by derivation. Nothing rotated.
//
//  THE SECRETS are INPUTS (`RotationSecrets` + the typed words): the runner
//  never derives from custody what custody cannot hold — see the batch
//  record's question 1 (the Touch-ID-only arm is the architect's).
//

import CryptoKit
import Dependencies
import Foundation
import Observation
import os
import VariorumCore

/// The runner's typed refusals — the door-side sentences are the copy
/// file's; the ceremony model words these.
nonisolated enum PostureSwitchError: Error, Equatable, Sendable {
    /// The library's key is not in hand (locked) — nothing can run.
    case libraryKeyUnavailable
    /// Enrolled, but this device's sync custody holds no keys (the
    /// follow has not happened) — pick up the new keys first.
    case syncKeysUnavailable
    /// A rotation is already in progress on this device — resume it.
    /// `act`: the PENDING MARKER's act (VX-99 round 2b), so the refusal's
    /// words name what did not finish (`ProtectionCopy.ceremonyResumeTitle`);
    /// nil at the `busy` guards — another road of this runner is in flight
    /// and no marker exists to read.
    case switchInProgress(RotationMarker.Step, act: CeremonyAct? = nil)
    /// No rotation is in progress — nothing to resume.
    case nothingToResume
    /// The resume needs the passphrase (M′ or L′ must be unwrapped from a
    /// key file / the vault): the ceremony asks and calls again.
    case passphraseRequired
    /// The resume found the vault write never landed — start over.
    case restartRequired
    /// The vault refused the write typed (worded by `EncryptionSession`).
    case vaultRefused(String)
    /// The custody move refused (worded by the controller).
    case custodyRefused(String)
    /// Leaving Castle: iCloud Keychain would not hold the key.
    case appleKeyUnavailable
    /// pre-13x ladder round 1, F2 (MAJOR-3 b — decision 30's letter):
    /// Replace All Keys under Standard keeps the Apple-held copy under the
    /// SAME iCloud key, so that key must be READABLE here and be the
    /// vault's — never minted, never another Apple account's. Refused
    /// before the marker and before any write (copy §4's PROVISIONAL line).
    case appleKeyUnreachable
    /// The act does not apply to the current posture.
    case wrongPosture(Posture)
    /// The re-key road refused (worded).
    case rekeyFailed(String)
    /// pre-13x 2c: the follow needs a secret — the passphrase or the twelve
    /// words — and neither was given.
    case secretRequired
    /// pre-13x 2c: a fault injected by a test leaf (never production).
    case injectedFault(PostureSwitchRunner.FaultPoint)
    /// pre-13x 3b (ledger 44 — decision 33 at the RUNNER): the vault carries
    /// a recovery wrap and the rotation was asked to run WITHOUT the twelve
    /// words — the new keys could not be wrapped under them and the words
    /// would die silently; refused before anything is written.
    case wordsRequired
    /// VX-99 round 2 (finding 4 — decision 9: every key door is an ONLINE
    /// act for an ENROLLED library): Replace All Keys reached the runner
    /// without the enrolled library in hand (a vault, the transport, a
    /// session, sync custody). The door admits only an enrolled library,
    /// so this is the check-then-act gap (a session that lapsed during the
    /// screens; a custody read that failed) — refused before anything is
    /// written, never run as the local-only road (steps 4–7 alone would
    /// rotate nothing and the Done would claim otherwise).
    case replaceKeysNeedsSync
}

@MainActor
@Observable
final class PostureSwitchRunner {
    /// The ceremony's progress, as TEXT (batch 5's original animated
    /// indicator rides these phases).
    enum Phase: Equatable, Sendable {
        case idle
        case pullingToHead
        case rotatingKeys
        case reencrypting(done: Int, total: Int)
        case rekeyingLibrary
        case movingCustody
        case snapshotting
        case done
    }

    /// What a completed switch hands the ceremony.
    struct Outcome: Equatable, Sendable {
        var entersCastle: Bool
        /// The new library key's fingerprint (the new key file's name).
        var newKeyFingerprint: String
        /// The scheduled `.md` insurance was ON and is now OFF (the notice).
        var insuranceTurnedOff: Bool
        /// The app's own PRE-switch snapshot pairs (the `.sqlite` URLs; the
        /// pair goes with each) — the offer's subject; empty ⇒ no offer.
        /// pre-13x ladder round 1, F2 (MAJOR-2): listed ONLY when the fresh
        /// pair under the new key was WRITTEN — an offer to delete every
        /// pre-switch backup with no fresh one beside them would be an
        /// offer to delete the only backups that exist.
        var preSwitchSnapshots: [URL]
        /// pre-13x ladder round 1, F2 (MAJOR-2): what step 6's fresh
        /// snapshot did — the Done reads it (copy §2b's ordinary line claims
        /// "A fresh backup was made under it"; a FAILED snapshot renders the
        /// PROVISIONAL could-not-back-up line instead).
        var freshSnapshot: FreshSnapshot = .notKept
        /// Rows re-encrypted on the server (0 for a local-only library).
        var reencrypted: Int
        /// The final custody material (nil for a local-only library).
        var material: DeviceKeyMaterial?
        /// pre-13x 5a (ledger 61 — PROVISIONAL, the orchestrator's judgment
        /// under her mandate): the ceremony's road became the FOLLOW — another
        /// device's switch landed first (§7 step 7, M1) — so the twelve words
        /// this ceremony showed are NOT the account's; the Done says so (copy
        /// §2b), naming `otherDeviceName` from the vault's `updated_by_device`.
        var followedAnotherDevicesSwitch: Bool = false
        var otherDeviceName: String? = nil
        /// VX-99 round 2 (finding 3, S1): the vault's `updated_at` when the
        /// Done names ANOTHER device's posture act with its day — this
        /// device's own Use Castle landed, and the ACCOUNT left Castle on
        /// another device before the resume (`otherDeviceName` names it).
        var otherDeviceDay: String? = nil
    }

    /// pre-13x 2c (the 2b adjudication's item 6): the seams a scripted
    /// world can fault, to pin the resume's two arms that no other seam
    /// reaches — the vault write that never landed (`restartRequired`) and
    /// the write that landed while custody did not (the follow by the
    /// passphrase at `.reencrypt`). Production's leaf is inert.
    nonisolated enum FaultPoint: Equatable, Sendable {
        /// After the marker at `.vaultWrite` is persisted, BEFORE the vault
        /// write — the write never lands.
        case beforeVaultWrite
        /// After the vault write landed, BEFORE custody takes M′.
        case afterVaultWriteBeforeCustody
    }

    /// pre-13x ladder round 1, F2 (MAJOR-2): step 6's fresh snapshot, as the
    /// leaf reports it — WRITTEN (the pair's `.sqlite` URL), FAILED (this
    /// platform keeps backups and the run did not write one: an unwritable
    /// folder, a WAL that would not drain, any `performRun` failure), or
    /// NOT KEPT (this platform keeps no backups at all — the phone; nothing
    /// failed, nothing exists). Before F2 the leaf answered `URL?` and the
    /// runner discarded it, so a failed snapshot was indistinguishable from
    /// a platform without backups and the offer was made regardless.
    nonisolated enum FreshSnapshot: Equatable, Sendable {
        case written(URL)
        case failed
        case notKept
    }

    /// The drain's bound (the 2b adjudication's item 2 — the architect's
    /// ruling on 2b's question 2): step 1 pushes until the outbox is
    /// EMPTY, at most this many rounds, then refuses with the count. A
    /// device offline for days is not sent away for a scheduler round it
    /// could run itself; a backlog that outlasts three rounds is told so.
    nonisolated static let maxDrainRounds = 3

    /// The injectable seams (production: `Leaves.live`; the pins: scripted).
    nonisolated struct Leaves: Sendable {
        var scope: String
        var storeURL: URL
        /// The BOUND view — survives the reopen (the ambient database).
        var database: AppDatabase
        var gate: StoreLaunchGate
        /// This device's sync custody (nil material = not enrolled).
        var keyStore: DeviceKeyStore
        var keyProvider: any SyncKeyProviding
        /// pre-13x ladder round 1, F2 (MINOR-5): the seeded books' dedupe
        /// facts (`SampleLibrarySeeder.allDedupeFacts()` in production —
        /// the SAME list `SyncSession.configure` hands the regular engine),
        /// so the ceremony's drain engine arms the dedupe's one-shot marker
        /// when a seeded book's `reading` row lands during its pull to head.
        /// Before F2 the drain built `SyncEngine(transport:keyProvider:)`
        /// bare: an empty list is inert, the occasion was never recorded,
        /// and the regular engine never saw that arrival again (the cursor
        /// had moved). Empty in the scripted worlds.
        var sampleLibraryFacts: [SampleLibraryDedupeFacts] = []
        /// 17y B-DEDUPE: the furniture fold's facts for the drain engine —
        /// the F2 (MINOR-5) parity rule, the SHARED half in production (a
        /// guide pair met during a ceremony drain folds at the regular
        /// engine's next book-touching pull — the recorded corner). Nil in
        /// the scripted worlds.
        var furnitureFacts: SeededFurnitureDedupeFacts?
        /// nil = no vault client composed (unconfigured / local-only).
        var vault: KeyVaultClient?
        var transport: (any SyncTransport & SyncRotationTransport)?
        /// Whether a signed-in session exists (the vault is reachable).
        var signedIn: @Sendable () async -> Bool
        var appleKeys: AppleKeyLeaves
        /// The library key in hand (the resident under a demanded gate,
        /// else the silent item's).
        var libraryKeyInHand: @MainActor () -> StoreKey?
        /// The posture as derived now.
        var posture: @MainActor () -> Posture
        var alwaysAsk: @MainActor () -> Bool
        var biometryAvailable: @MainActor () -> Bool
        /// The controller's both-items move (2a).
        var moveCustody: @MainActor (StoreAtOpenMode) async -> ProtectionController.ModeChangeOutcome
        /// THE RE-KEY ROAD: flush, close the pool, run `work` (the
        /// export-and-swap), reopen under whichever key opens the file,
        /// re-adopt. The bootstrap's in production; a scratch binding's in
        /// the pins.
        var rekeyLibrary: @MainActor (_ old: StoreKey, _ new: StoreKey, _ work: @escaping @Sendable () throws -> Void) async throws -> Void
        var pauseSync: @MainActor () -> Void
        /// pre-13x ladder round 1, F2 (MAJOR-1): the RESUME leaf RECONNECTS a
        /// stopped chain (production: `AppServices.resumeSync()` —
        /// `connectSyncIfAllowed`'s shape when the session is stopped, a bare
        /// trigger when the re-key's reopen already rebuilt and connected the
        /// services). The runner balances it against `pauseSync` on EVERY
        /// exit of a ceremony road — success, refusal, failure — so a refused
        /// switch can never leave sync dead for the session.
        var resumeSync: @MainActor () async -> Void
        /// The fresh snapshot pair under the CURRENT key — `.written(url)`,
        /// `.failed` (a backup platform whose run did not write), or
        /// `.notKept` (this platform keeps no backups). F2 (MAJOR-2): the
        /// runner READS the answer now.
        var takeSnapshot: @MainActor () async -> FreshSnapshot
        /// The app's own snapshot pairs whose fingerprint is NOT `keep` —
        /// every folder Variorum writes into.
        var preSwitchSnapshots: @Sendable (_ keep: String) -> [URL]
        /// Remove pairs (the snapshot and its key file), returning how many.
        var deleteSnapshotPairs: @Sendable ([URL]) -> Int
        var defaults: @Sendable () -> UserDefaults
        /// The controller's launch reconcile (the posture re-derives).
        var reconcile: @MainActor () async -> Void
        var now: @Sendable () -> Date
        var log: @Sendable (String) -> Void
        /// pre-13x 2c: the fault leaf — inert in production; a pin throws
        /// at the named point (`PostureSwitchError.injectedFault`).
        var injectFault: @Sendable (FaultPoint) throws -> Void = { _ in }
        /// pre-13x 5b (ledger 67): THIS device's own name — the same name the
        /// vault client stamps into `updated_by_device` on every write
        /// (`AppServices` hands `DeviceName.current` to the client). The
        /// resume's discriminator reads the vault's last writer against it.
        var deviceName: @Sendable () -> String = { DeviceName.current }
        /// pre-13x ladder round 1, F1 (BLOCKER-1): the walk's WAIT PAST THE
        /// A5 VISIBILITY HORIZON, run once at its first empty window
        /// (`CorpusRotation.horizonWait`). nil = the driver's PRODUCTION
        /// ROAD (Phase 13y, the R-13y-4 fork's Shape 1): fetch the SERVED
        /// horizon from the transport (`visibilityHorizonMillis()`) and
        /// sleep served + margin (`CorpusRotation.horizonWait(
        /// forServedMillis:)`) — the app no longer hardcodes 2.5 s; the
        /// pins advance the emulated mirror's clock — or nothing, to prove
        /// the server's completion guard and the runner's re-walk alone.
        var horizonWait: (@Sendable () async throws -> Void)? = nil
        /// VX-202 (gate i): the runner's clear of the bootstrap's in-flight
        /// switch flag (`AppBootstrap.endSwitch`), called once the switch's
        /// custody move has landed. Inert in the scripted worlds.
        var endSwitch: @MainActor () -> Void = {}
    }

    /// pre-13x ladder round 1, F1 (BLOCKER-1): how many times the clearing
    /// write may be REFUSED (`rotationRowsRemain` — a ciphertext row of the
    /// account still below the seq, hidden from this device's pulls) before
    /// the runner stops re-walking and refuses honestly: the marker stays at
    /// `.reencrypt`, sync stays paused, the resume re-walks. Three tries =
    /// two re-walks, each preceded by the wait past the horizon.
    nonisolated static let maxCompletionTries = 3

    private(set) var phase: Phase = .idle
    private(set) var busy = false
    /// pre-13x ladder round 1, F2 (MAJOR-1): whether THIS runner paused the
    /// sync chain and has not yet resumed it — and WHICH ROAD did (pre-13x
    /// ladder round 2, F3 — MINOR-N2). `pauseSyncForCeremony` records the
    /// road once; `resumeSyncIfPaused(by:)` clears it on a throw of THAT
    /// road only; the success roads resume where they end. Before F2 the
    /// resume rode the success roads only, and the production leaf was a
    /// bare trigger — a no-op on a stopped session — so `outboxNotEmpty`,
    /// `rotationInProgress`, `wordsRequired`, a vault refusal or a wrong
    /// follow passphrase left sync dead until relaunch. Before F3 the flag
    /// was a Bool on the INSTANCE while the balance is ROAD-scoped: a
    /// second road refused `switchInProgress` mid-ceremony (the `busy`
    /// guard — exactly the case it exists for) saw the flag road 1 had set
    /// and RECONNECTED the chain out from under road 1's drain.
    private var pausedByRoad: UUID?
    private let leaves: Leaves
    private let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")

    init(leaves: Leaves) {
        self.leaves = leaves
    }

    // MARK: - The marker's reading (the ceremony's and the bootstrap's)

    /// The pending marker, if a switch or a key replacement did not finish
    /// on this device.
    nonisolated static func pendingMarker(database: AppDatabase) async -> RotationMarker? {
        (try? await database.read { try RotationMarker.read($0) }) ?? nil
    }

    func pendingMarker() async -> RotationMarker? {
        await Self.pendingMarker(database: leaves.database)
    }

    // MARK: - The door check (decision 32: "the doors refuse before asking")

    /// What the door learns before the ceremony opens: whether this
    /// library is enrolled (a vault + a session + sync custody), whether
    /// the vault carries a previous corpus key (a rotation started
    /// elsewhere is still finishing — the door refuses with copy §4's
    /// sentence) and the vault's day for that sentence. Offline throws
    /// (the transport's own URLError) — every key door is an online act
    /// for an enrolled library (decision 9).
    struct DoorFacts: Equatable, Sendable {
        var enrolled: Bool
        var rotationInProgress: Bool
        var vaultUpdatedAt: String?
        /// pre-13x ladder round 1, F2 (MINOR-4 — decision 34): the device
        /// that last wrote the vault (`updated_by_device`), so copy §4's
        /// still-finishing sentence names it — the one sentence the column
        /// was ruled for. nil ⇒ "another device".
        var updatedByDevice: String? = nil
        var vaultHasRecoveryWrap: Bool
        /// pre-13x 3b: the vault's CURRENT corpus key id — Replace All Keys'
        /// stale-master front check compares the key file's recorded id
        /// against it (§5's row: "holding the CURRENT master").
        var vaultCorpusKeyID: String? = nil
        /// pre-13x 3b: the vault's passphrase descriptor — a refused
        /// passphrase at a key door is worded as RETIRED (copy §5) when the
        /// key file's recorded descriptor no longer matches it.
        var vaultKDF: PassphraseKDF.Descriptor? = nil
        /// pre-13x ladder round 2, F3 (MINOR-N4 — decision 32's door
        /// pattern applied to MAJOR-3 (b)): on a STANDARD ACCOUNT (the
        /// vault's word — it carries an Apple-held copy; VX-99 round 1),
        /// whether the account's iCloud key is READABLE here and IS the
        /// vault's (nil on a Castle account — no Apple-held copy is owed).
        /// Replace All Keys refuses AT THE DOOR on `false`, before any
        /// screen — before F3 the refusal fired at step 2, after the words
        /// screens, and regenerated words then opened nothing, unsaid. The
        /// runner's own step-2 check (`appleHeldCopyForStandard`) stays as
        /// the belt.
        var appleKeyReadable: Bool? = nil
        /// VX-99 round 2 (finding 2): the VAULT's word on the account's
        /// posture — whether it carries an Apple-held copy (Standard) — as
        /// the door read it; nil when not enrolled (no vault read). The
        /// Replace All Keys screen's decision-30 addendum renders on THIS,
        /// the word the door (`appleKeyReadable`) and the belt
        /// (`appleHeldCopyForStandard`) already act on.
        var vaultHasAppleHeldCopy: Bool? = nil
    }

    /// F3 (MINOR-N4): the door-time reading of what the belt enforces at
    /// step 2 — A READ (never minted), and the vault's id when it names one.
    private func appleKeyReadable(keptUnder fetched: KeyVaultClient.FetchedVault) -> Bool? {
        // VX-99 round 1 (MAJOR): the VAULT's word, never the posture read.
        // A Castle account owes no Apple copy (nil); a Standard one does.
        // The door is the twin of `appleHeldCopyForStandard`'s belt — before
        // this both gated on `leaves.posture() == .standard`, so a STALE or
        // INDETERMINATE posture (the account left/entered Castle elsewhere and
        // this device had not reconciled) decided the Apple copy, which on the
        // ceremony's enrolled road FLIPS THE ACCOUNT's posture (decision 8:
        // posture is the account's once a vault exists; decision 35: no
        // posture-driven write on a stale reading).
        guard fetched.format.masterWrappedByAppleHeld != nil else { return nil }
        guard let apple = leaves.appleKeys.read() else { return false }
        if let vaultID = fetched.format.appleKeyID, vaultID != apple.id { return false }
        return true
    }

    func checkDoor() async throws -> DoorFacts {
        let signedIn = await leaves.signedIn()
        let custody = await leaves.keyStore.offMain { $0.load() }
        guard let vault = leaves.vault, leaves.transport != nil, signedIn, custody != nil else {
            return DoorFacts(enrolled: false, rotationInProgress: false, vaultUpdatedAt: nil,
                             vaultHasRecoveryWrap: false)
        }
        guard let fetched = try await vault.fetchVault() else {
            return DoorFacts(enrolled: false, rotationInProgress: false, vaultUpdatedAt: nil,
                             vaultHasRecoveryWrap: false)
        }
        return DoorFacts(
            enrolled: true,
            rotationInProgress: fetched.format.previousCorpusKey != nil,
            vaultUpdatedAt: fetched.updatedAt,
            updatedByDevice: fetched.format.updatedByDevice,
            vaultHasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil,
            vaultCorpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
            vaultKDF: fetched.format.kdf,
            appleKeyReadable: appleKeyReadable(keptUnder: fetched),
            vaultHasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil)
    }

    // MARK: - The two switches + Replace All Keys

    /// STANDARD → CASTLE (§4 whole). `passphrase`: the ceremony's — set at
    /// the ceremony if none, else typed and verified against the VAULT's
    /// copy (the ceremony's job); `recoveryWords`: the twelve words in
    /// hand (generated + confirmed, or typed) — nil ONLY for a library
    /// whose vault should carry no recovery wrap (the ceremony decides).
    @discardableResult
    func enterCastle(passphrase: String, recoveryWords: [String]?) async throws -> Outcome {
        try await run(entersCastle: true, passphrase: passphrase, recoveryWords: recoveryWords)
    }

    /// REPLACE ALL KEYS (batch 3's door over this runner): §4's steps 1–4
    /// without the posture change — the vault rewritten under the same
    /// posture's wrappers (the Apple-held copy again in Standard — decision
    /// 30), every row re-encrypted, THIS library re-keyed, custody re-saved
    /// in its current shape.
    @discardableResult
    func replaceAllKeys(passphrase: String, recoveryWords: [String]?) async throws -> Outcome {
        try await run(entersCastle: false, passphrase: passphrase, recoveryWords: recoveryWords)
    }

    private func run(entersCastle: Bool, passphrase: String, recoveryWords: [String]?) async throws -> Outcome {
        try await balancingSync { road in
            try await runCeremony(road: road, entersCastle: entersCastle, passphrase: passphrase, recoveryWords: recoveryWords)
        }
    }

    // MARK: - pre-13x ladder round 1, F2 (MAJOR-1): the pause is BALANCED — per ROAD (F3, MINOR-N2)

    /// Pause the sync chain for a ceremony road — once; the road that
    /// paused is the one that resumes on a throw (a second road that meets
    /// the `busy` guard while this one holds the pause never pauses, so it
    /// never resumes either).
    private func pauseSyncForCeremony(_ road: UUID) {
        guard pausedByRoad == nil else { return }
        pausedByRoad = road
        leaves.pauseSync()
    }

    /// Resume the chain THIS road paused — a no-op when it paused nothing
    /// (a refusal before the pause; a refusal at the `busy` guard while
    /// another road holds the pause; the resume road, which never pauses).
    private func resumeSyncIfPaused(by road: UUID) async {
        guard pausedByRoad == road else { return }
        pausedByRoad = nil
        await leaves.resumeSync()
    }

    /// The success roads' resume: unconditional — the marker is gone and
    /// sync belongs back on whether this road paused it (the ceremony) or a
    /// crash did (the resume road: the chain was never paused by this
    /// process, but the reconnect is what "sync is back on" means).
    private func resumeSyncAtEnd() async {
        pausedByRoad = nil
        await leaves.resumeSync()
    }

    /// Run a road under its own token and resume the chain on EVERY throw
    /// of that road; the success roads resume where they end
    /// (`rekeyCustodyAndSnapshot`, the resume's last arm, `pickUpKeys`).
    private func balancingSync<T>(_ body: (UUID) async throws -> T) async throws -> T {
        let road = UUID()
        do {
            return try await body(road)
        } catch {
            await resumeSyncIfPaused(by: road)
            throw error
        }
    }

    private func runCeremony(road: UUID, entersCastle: Bool, passphrase: String, recoveryWords: [String]?) async throws -> Outcome {
        guard !busy else { throw PostureSwitchError.switchInProgress(.vaultWrite) }
        if let pending = await pendingMarker() {
            throw PostureSwitchError.switchInProgress(pending.step, act: CeremonyAct(resuming: pending))
        }
        guard !passphrase.isEmpty else { throw VaultEnrollmentError.emptyPassphrase }
        guard let libraryKey = leaves.libraryKeyInHand() else {
            throw PostureSwitchError.libraryKeyUnavailable
        }
        busy = true
        defer { busy = false; phase = .idle }
        let signedIn = await leaves.signedIn()
        let custody = await leaves.keyStore.offMain { $0.load() }
        let enrolled = leaves.vault != nil && leaves.transport != nil && signedIn && custody != nil
        // VX-99 round 2 (finding 4 — decision 9: every key door is an ONLINE
        // act for an ENROLLED library): the Replace All Keys DOOR admits only
        // an enrolled library (`replaceKeysNotEnrolled`), so reaching the
        // local-only road here is the check-then-act gap — a session that
        // lapsed during the screens, a custody read that failed. That road
        // rotated NOTHING for Replace All Keys (steps 4–7 alone: the master
        // and corpus keys untouched, the vault untouched, a key file without
        // the master-wrapped copy) while its Done said other devices would
        // ask for the passphrase; and under an indeterminate reading its
        // posture read could wrap L′ under A on a Castle account. Refused
        // before anything is written. Use Castle's local-only road (a
        // pre-sync library — decision 8's second sentence; §4's "Without
        // sync: steps 4–7 only") is untouched.
        guard enrolled || entersCastle else {
            leaves.log("posture switch: Replace All Keys reached the runner without the enrolled library in hand (vault, transport, session, custody) — refused before anything is written (decision 9)")
            throw PostureSwitchError.replaceKeysNeedsSync
        }
        // 17l item 5 (RUN B B3): the derive moved INTO the branches — the
        // enrolled road derives against the FETCHED vault (an unchanged
        // word reuses the vault's descriptor, so a sibling's held lobby
        // key still matches after the rotation and ledger 54's
        // no-second-entry follow holds ACROSS rotations); the local-only
        // road, with no vault to reuse, keeps the fresh salt.
        let secrets: RotationSecrets
        var material: DeviceKeyMaterial?
        var reencrypted = 0
        var recoveryWrapDigest: String?
        // VX-99: THE ONE DECISION for the new key file's Apple copy, made per
        // road below and threaded into step 4 — the key file follows the
        // VAULT's rule, never "any iCloud key readable here". Before VX-99
        // `writeNewKeyFile` read A whenever the road did not enter Castle, so
        // a Replace All Keys on a CASTLE account wrapped L′ under the iCloud
        // key a Mac still held from its Standard era (her Pro, 2026-09-07).
        // VX-99 round 2 (finding 7): the decision carries the KEY itself —
        // the one the belt verified — not a Bool that `writeNewKeyFile`
        // turned into a second read after the walk.
        var appleKeyForKeyFile: AppleKey?
        let stamp = DateFormatter.variorumISO8601.string(from: leaves.now())

        if enrolled, let vault = leaves.vault, let transport = leaves.transport {
            // ————— 1. PULL TO HEAD (the three refusals) —————
            phase = .pullingToHead
            pauseSyncForCeremony(road)
            let engine = leaves.drainEngine(transport: transport)
            // THE DRAIN (2c — the 2b adjudication's item 2): push what this
            // device owes until the outbox is EMPTY, at most `maxDrainRounds`
            // rounds (each a push then a pull to head — a pull can leave a
            // merged row enqueued for the next push), then refuse with the
            // count. One push's `maxPushIterations × batchSize` is not the
            // measure of what a device owes; three rounds is.
            var pending = 0
            for _ in 0..<Self.maxDrainRounds {
                try await withDatabase { _ = try await engine.push() }
                try await withDatabase { _ = try await engine.pullToHead() }
                pending = try await withDatabase { try await engine.outboxCount() }
                if pending == 0 { break }
            }
            guard pending == 0 else { throw SyncError.outboxNotEmpty(pending: pending) }
            guard let fetched = try await vault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            if let previous = fetched.format.previousCorpusKey {
                throw CorpusRotationError.rotationInProgress(previousKeyID: previous.keyID)
            }
            // 17l item 5: an UNCHANGED word re-wraps under the vault's
            // EXISTING descriptor (proven by the unwrap, never guessed);
            // a changed word keeps the fresh salt. Off-main as before
            // (Argon2id — tenths of a second).
            let format = fetched.format
            secrets = try await Task.detached(priority: .userInitiated) {
                try RotationSecrets.derive(
                    passphrase: passphrase, recoveryWords: recoveryWords, forRotationOf: format)
            }.value
            // pre-13x 3b (ledger 44 — decision 33 at the RUNNER): a vault
            // that carries a recovery wrap is never rewritten without the
            // twelve words in hand — `CorpusRotation.begin` would mint M′
            // with NO recovery wrap and the words would die silently.
            if fetched.format.masterWrappedByRecovery != nil, secrets.recoveryKey == nil {
                throw PostureSwitchError.wordsRequired
            }
            guard let current = await leaves.keyStore.offMain({ $0.load() }) else {
                throw PostureSwitchError.syncKeysUnavailable
            }

            // ————— 2. ROTATE THE SYNC KEYS (the marker BEFORE the write) —————
            phase = .rotatingKeys
            // F1 (ledger 69): the mint FIRST, so the marker carries the NEW
            // corpus key id before anything is written — the resume's exact
            // discriminator (own write landed ⇔ the vault's id is this one).
            // F2 (MAJOR-3 b): the Apple-held copy kept under the SAME A —
            // read, never minted; refused when unreadable or not the vault's.
            let appleHeld: AppleKey? = entersCastle
                ? nil : try appleHeldCopyForStandard(keptUnder: fetched)
            // VX-99 (enrolled road): the key file carries an Apple copy
            // exactly when the vault write carries one — Standard's Replace
            // All Keys (decision 30, §7 step 5), never a Castle account's.
            // VX-99 round 2 (finding 7): under the SAME A — the vault's copy
            // of M′ and the key file's copy of L′ are one pair; a swap of the
            // iCloud item during the walk can no longer split them.
            appleKeyForKeyFile = appleHeld
            let prepared = try CorpusRotation.prepare(
                current: current, secrets: secrets,
                appleHeldCopy: appleHeld.map { (key: $0.symmetricKey, id: $0.id) })
            try await writeMarker(RotationMarker(
                step: .vaultWrite, entersCastle: entersCastle,
                newCorpusKeyID: prepared.corpusKeyID, startedAt: stamp))
            try leaves.injectFault(.beforeVaultWrite)
            let begun: CorpusRotation.Begun
            do {
                begun = try await CorpusRotation.begin(client: vault, current: current, prepared: prepared)
            } catch let refusal as KeyVaultClientError
                where refusal == .vaultRevisionConflict || refusal == .keyProofRefused {
                // pre-13x 4b (corner 39 / ledger 40 — §7 step 7): TWO DEVICES
                // SWITCHING AT ONCE. The vault refused this device's rotation
                // because another write landed between the fetch and the
                // write: the REVISION CAS when that write was a re-wrap (a
                // passphrase change elsewhere — the hash unchanged), the
                // PROOF when it was a rotation (the other device's write
                // replaced the hash, so this device's old proof is refused
                // before the CAS is even reached — the RPC's order, absent →
                // proof → rotation → CAS). RE-READ either way: if the
                // account's corpus key moved under us — the other device
                // rotated (entered Castle, or replaced the keys) — then THE
                // RETRY IS THE FOLLOW, never a second rotation: this device
                // picks the new master up with the passphrase it already
                // typed for the ceremony, re-keys its own library and pulls;
                // the vault is not written again. If the key id did NOT move
                // (a concurrent re-wrap took the revision), the refusal
                // stands: the marker's resume road restarts the ceremony
                // (`restartRequired`), where the passphrase is re-verified
                // against the vault's now-current copy.
                guard let moved = try await vault.fetchVault(),
                      moved.format.classKey(for: .corpus)?.keyID != current.corpusKeyID
                else { throw refusal }
                leaves.log("posture switch: the vault's CAS refused — the account's keys moved on another device; this device FOLLOWS instead (no second rotation)")
                // The typed passphrase, verified against the vault's CURRENT
                // copy (a word the other device also changed refuses here —
                // the marker's resume road then asks).
                let unwrapped = try await VaultEnrollment(client: vault).enroll(passphrase: passphrase)
                try await clearMarker()
                // The ceremony's words are NOT landed: the other device's
                // rotation wrapped the vault under ITS words, which may not
                // be these; the W copy lands when the words are next typed
                // here (the follow's own rule).
                var outcome = try await runFollow(
                    fetched: moved, vault: vault, unwrapped: unwrapped, libraryKey: libraryKey,
                    keyFile: KeyFileInputs(passphrase: passphrase, kdf: moved.format.kdf, recoveryWords: nil,
                                           recoveryWrapDigest: moved.format.recoveryWrapDigest),
                    secretName: "passphrase typed for the ceremony")
                // pre-13x 5a (ledger 61): the ceremony's Done must say the
                // words it showed are not the account's — the winner's are.
                outcome.followedAnotherDevicesSwitch = true
                outcome.otherDeviceName = moved.format.updatedByDevice
                phase = .done
                return outcome
            }
            leaves.log("posture switch: the vault rewritten under the old proof — rotation seq \(begun.receipt.rotationStartedSeq ?? -1)")
            recoveryWrapDigest = begun.format.recoveryWrapDigest
            try leaves.injectFault(.afterVaultWriteBeforeCustody)
            guard await leaves.keyStore.offMain({ $0.save(begun.material) }) else {
                // The vault has moved; this device's custody could not take
                // M′ — the follow (the passphrase) picks it up at resume.
                throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
            }
            try await writeMarker(RotationMarker(
                step: .reencrypt, entersCastle: entersCastle,
                newCorpusKeyID: begun.material.corpusKeyID, startedAt: stamp))

            // ————— 3. RE-ENCRYPT THE SERVER COPY —————
            let final = try await reencryptAndComplete(vault: vault, transport: transport, material: begun.material)
            material = final.material
            reencrypted = final.reencrypted
        } else {
            secrets = try await Task.detached(priority: .userInitiated) {
                try RotationSecrets.derive(passphrase: passphrase, recoveryWords: recoveryWords)
            }.value
            // VX-99 (local-only road — no vault): since round 2's finding 4
            // only USE CASTLE reaches this road (Replace All Keys refuses
            // above), and entering Castle never carries an Apple copy.
            appleKeyForKeyFile = nil
            leaves.log("posture switch: local-only — steps 4–7 only")
        }

        // ————— 4–6: the library, custody, the snapshot —————
        let outcome = try await rekeyCustodyAndSnapshot(
            entersCastle: entersCastle, appleKey: appleKeyForKeyFile, libraryKey: libraryKey,
            keyFile: KeyFileInputs(passphrase: passphrase, kdf: secrets.kdf, recoveryWords: recoveryWords,
                                   recoveryWrapDigest: recoveryWrapDigest),
            material: material, reencrypted: reencrypted, stamp: stamp,
            listPreSwitchPairs: entersCastle)
        phase = .done
        return outcome
    }

    // MARK: - pre-13x 2c: THE FOLLOW (§7 — the other devices)

    /// THE FOLLOW INTO CASTLE / AFTER REPLACE ALL KEYS (design §7): this
    /// device opened as it did; at ready the vault said the account's keys
    /// were rotated (the corpus key id ≠ custody's, the SAME owner); the
    /// user typed the passphrase or the twelve words ONCE. This road: M′
    /// from the vault's P (or W) copy — nothing is unwrapped on the server;
    /// C′ + the previous key and the seq under M′ (`materialFollowing`);
    /// custody REPLACED under the current shape; the marker at
    /// `.reencrypt` (a crash resumes exactly as the acting device's would —
    /// `resume` at `.reencrypt` IS the follow's resume); the walk finished
    /// and the previous key cleared when rows remain (any M′-holder
    /// finishes — §4 step 3); then 2b's steps 4–6: a NEW key file (L′
    /// under the typed secret and M′ — the other secret's local copy lands
    /// when next typed here; the Apple copy ONLY under a Standard account),
    /// the export-and-swap, custody behind Touch ID / Face ID or nowhere
    /// (Castle) or re-saved silent (a Standard account), the fresh pair +
    /// the insurance OFF (entering Castle); sync resumed — the pull from
    /// the own cursor: re-encrypted rows arrive seq-recorded only, pending
    /// outbox rows push under C′. NO `resyncReinitialize`, no re-stamp:
    /// same account, same rows. `entersCastle` = the account carries no
    /// Apple-held copy; the OFFER (the app's own pre-switch pairs) is
    /// listed only when this library was STANDARD-shaped before — a Castle
    /// follower's old pairs never opened through the Apple account, so the
    /// copy's sentence would be false there.
    @discardableResult
    func follow(passphrase: String?, recoveryWords: [String]?) async throws -> Outcome {
        try await balancingSync { road in
            try await followTyped(road: road, passphrase: passphrase, recoveryWords: recoveryWords)
        }
    }

    private func followTyped(road: UUID, passphrase: String?, recoveryWords: [String]?) async throws -> Outcome {
        guard !busy else { throw PostureSwitchError.switchInProgress(.vaultWrite) }
        if let pending = await pendingMarker() {
            throw PostureSwitchError.switchInProgress(pending.step, act: CeremonyAct(resuming: pending))
        }
        guard let libraryKey = leaves.libraryKeyInHand() else {
            throw PostureSwitchError.libraryKeyUnavailable
        }
        guard let vault = leaves.vault, leaves.transport != nil, await leaves.signedIn() else {
            throw PostureSwitchError.syncKeysUnavailable
        }
        let typedPassphrase = (passphrase?.isEmpty == false) ? passphrase : nil
        let typedWords = (recoveryWords?.isEmpty == false) ? recoveryWords : nil
        guard typedPassphrase != nil || typedWords != nil else {
            throw PostureSwitchError.secretRequired
        }
        busy = true
        defer { busy = false; phase = .idle }
        phase = .rotatingKeys
        pauseSyncForCeremony(road)
        // M′ from the vault by the typed secret — the enrollment's own
        // unwrap (a wrong word refuses typed; nothing is written before it
        // succeeds).
        guard let fetched = try await vault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
        let enrollment = VaultEnrollment(client: vault)
        let unwrapped: DeviceKeyMaterial
        if let typedPassphrase {
            unwrapped = try await enrollment.enroll(passphrase: typedPassphrase)
        } else {
            unwrapped = try await enrollment.enroll(recoveryWords: typedWords ?? [])
        }
        return try await runFollow(
            fetched: fetched, vault: vault, unwrapped: unwrapped, libraryKey: libraryKey,
            keyFile: KeyFileInputs(passphrase: typedPassphrase, kdf: fetched.format.kdf, recoveryWords: typedWords,
                                   recoveryWrapDigest: fetched.format.recoveryWrapDigest),
            secretName: typedPassphrase != nil ? "passphrase" : "twelve words")
    }

    /// pre-13x 4a (ledger 54; §7 step 1 — "reused for the follow, never
    /// asked twice"): THE FOLLOW FROM THE WORD JUST TYPED — the derived
    /// wrapping key the lobby held for the session, under `kdf`. The vault
    /// is fetched; its descriptor must be `kdf` (else the word was changed
    /// elsewhere too — `passphraseRequired`, the field asks) and the key
    /// must open its master copy (`passphraseRequired` otherwise); then the
    /// same road as the typed follow, the new key file's P copy = L′ under
    /// that same derived key with the vault's descriptor (the W copy lands
    /// when the words are next typed).
    @discardableResult
    func follow(derivedPassphraseKey derived: SymmetricKey, kdf: PassphraseKDF.Descriptor) async throws -> Outcome {
        try await balancingSync { road in
            try await followDerived(road: road, passphraseKey: derived, kdf: kdf)
        }
    }

    private func followDerived(road: UUID, passphraseKey derived: SymmetricKey, kdf: PassphraseKDF.Descriptor) async throws -> Outcome {
        guard !busy else { throw PostureSwitchError.switchInProgress(.vaultWrite) }
        if let pending = await pendingMarker() {
            throw PostureSwitchError.switchInProgress(pending.step, act: CeremonyAct(resuming: pending))
        }
        guard let libraryKey = leaves.libraryKeyInHand() else {
            throw PostureSwitchError.libraryKeyUnavailable
        }
        guard let vault = leaves.vault, leaves.transport != nil, await leaves.signedIn() else {
            throw PostureSwitchError.syncKeysUnavailable
        }
        busy = true
        defer { busy = false; phase = .idle }
        phase = .rotatingKeys
        pauseSyncForCeremony(road)
        guard let fetched = try await vault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
        guard fetched.format.kdf == kdf else {
            leaves.log("follow: the held key's descriptor is not the vault's — the passphrase is asked")
            throw PostureSwitchError.passphraseRequired
        }
        let master: SymmetricKey
        do {
            master = try fetched.format.unwrapMaster(withPassphraseKey: derived)
        } catch {
            leaves.log("follow: the held key does not open the vault's master copy — the passphrase is asked")
            throw PostureSwitchError.passphraseRequired
        }
        let unwrapped = try CorpusRotation.materialFollowing(fetched.format, master: master)
        return try await runFollow(
            fetched: fetched, vault: vault, unwrapped: unwrapped, libraryKey: libraryKey,
            keyFile: KeyFileInputs(passphrase: nil, passphraseKey: derived, kdf: kdf, recoveryWords: nil,
                                   recoveryWrapDigest: fetched.format.recoveryWrapDigest),
            secretName: "passphrase held from the lobby")
    }

    /// The follow's road after the master is in hand (both entries).
    private func runFollow(
        fetched: KeyVaultClient.FetchedVault, vault: KeyVaultClient, unwrapped: DeviceKeyMaterial,
        libraryKey: StoreKey, keyFile: KeyFileInputs, secretName: String
    ) async throws -> Outcome {
        // The VAULT's word (decision 8): no Apple-held copy ⇒ Castle. VX-99:
        // the new key file's Apple copy follows the same word (`appleKey:`
        // read only when `!entersCastle`, at both calls below) — the
        // account's posture, read from the vault just fetched.
        let entersCastle = fetched.format.masterWrappedByAppleHeld == nil
        let wasStandardShaped = leaves.gate.readEnvelope(leaves.storeURL).envelope?.apple != nil
        let stamp = DateFormatter.variorumISO8601.string(from: leaves.now())
        // pre-13x 2d (decision 35) — THE NO-ROTATION ROAD: the account's
        // keys are UNCHANGED (custody's corpus key id = the vault's, the
        // same master, no previous key carried) and only the POSTURE moved
        // — the window's phone: a Castle account, silent custody. The typed
        // secret was just verified against the vault's copy; the new-master
        // half (the `.reencrypt` marker, the custody replacement, the walk)
        // is skipped — custody already holds M and C — and the road goes
        // straight to 2b's steps 4–6 with the HELD material.
        let held = await leaves.keyStore.offMain { $0.load() }
        if let held, held.corpusKeyID == fetched.format.classKey(for: .corpus)?.keyID,
           held.masterKey == unwrapped.masterKey, fetched.format.previousCorpusKey == nil {
            leaves.log("follow: the keys are unchanged — the account is \(entersCastle ? "Castle" : "Standard"); the library re-keys and custody moves (no rotation)")
            let outcome = try await rekeyCustodyAndSnapshot(
                entersCastle: entersCastle, appleKey: entersCastle ? nil : leaves.appleKeys.read(), libraryKey: libraryKey,
                keyFile: keyFile,
                material: held, reencrypted: 0, stamp: stamp,
                listPreSwitchPairs: entersCastle && wasStandardShaped, follow: true)
            phase = .done
            leaves.log("follow: done — \(entersCastle ? "Castle" : "Standard"); library key \(outcome.newKeyFingerprint.prefix(8))")
            return outcome
        }
        let following = try CorpusRotation.materialFollowing(fetched.format, master: unwrapped.masterSymmetricKey)
        // The marker FIRST (a crash between here and custody resumes as
        // the follow-by-passphrase arm — the write is on the server).
        try await writeMarker(RotationMarker(step: .reencrypt, entersCastle: entersCastle, startedAt: stamp, follow: true))
        guard await leaves.keyStore.offMain({ $0.save(following) }) else {
            throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
        }
        leaves.log("follow: M′ picked up from the vault by the \(secretName) — \(following.rotation != nil ? "a rotation is still finishing" : "no rows remain")")
        guard let transport = leaves.transport else { throw PostureSwitchError.syncKeysUnavailable }
        let final = try await reencryptAndComplete(vault: vault, transport: transport, material: following)
        let outcome = try await rekeyCustodyAndSnapshot(
            entersCastle: entersCastle, appleKey: entersCastle ? nil : leaves.appleKeys.read(), libraryKey: libraryKey,
            keyFile: keyFile,
            material: final.material, reencrypted: final.reencrypted, stamp: stamp,
            listPreSwitchPairs: entersCastle && wasStandardShaped, follow: true)
        phase = .done
        leaves.log("follow: done — \(entersCastle ? "Castle" : "Standard"); library key \(outcome.newKeyFingerprint.prefix(8))")
        return outcome
    }

    /// pre-13x 2d: on EVERY follow under a Castle account the OLD key
    /// files leave the live folder — a Standard-era key file (an `apple`
    /// copy) beside a Castle library is the exposure itself, and a
    /// Castle-era one opens nothing the re-keyed file holds; the snapshot
    /// pairs keep their own; `locate` then finds exactly one file. 2d.4
    /// (the orchestrator's rulings 3 and 5): the removal runs INSIDE the
    /// marker's span (before it clears) and on the marker's RESUME road,
    /// so a follow killed after the re-key still closes the exposure; and
    /// the legacy-named WRAP-LESS stub (`variorum-keys.json` — the 13p
    /// format-1 file holding only `formatVersion` + `storeID`; it serves
    /// no snapshot and opens nothing) goes with it, while a format-1 file
    /// WITH wraps stays (it may serve legacy snapshots — §6). Not on the
    /// ceremony's own road (2b's letter: the old file stays there).
    private func retireOldKeyFiles(oldFingerprint: String?, keeping newFingerprint: String) {
        if let oldFingerprint, oldFingerprint != newFingerprint {
            let url = StoreKeyEnvelope.url(besideStore: leaves.storeURL, fingerprint: oldFingerprint)
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                    leaves.log("follow: the old key file removed from the live folder (\(oldFingerprint.prefix(8)))")
                } catch {
                    leaves.log("follow: the old key file could not be removed — \(String(describing: error))")
                }
            }
        }
        let legacy = StoreKeyEnvelope.legacyURL(besideStore: leaves.storeURL)
        guard FileManager.default.fileExists(atPath: legacy.path) else { return }
        guard let stub = try? StoreKeyEnvelope.load(at: legacy),
              stub.passphrase == nil, stub.recovery == nil, stub.apple == nil, stub.master == nil
        else {
            leaves.log("follow: a legacy-named key file with wraps stays beside the library (it may serve legacy snapshots)")
            return
        }
        do {
            try FileManager.default.removeItem(at: legacy)
            leaves.log("follow: the wrap-less legacy stub removed from the live folder")
        } catch {
            leaves.log("follow: the legacy stub could not be removed — \(String(describing: error))")
        }
    }

    /// THE ALWAYS-ASK PICKUP (decision 10's exception, 2c): an Always-ask
    /// device opened with a word since CHANGED elsewhere holds no sync keys
    /// — the new word unwraps the vault's master, the class keys (and any
    /// rotation in flight) are HELD FOR THE SESSION through the store's own
    /// save (the session-only shape keeps them in memory), and the caller
    /// re-wraps the local passphrase copy under the vault's descriptor.
    /// Nothing is re-keyed — the library key never moved. Returns the
    /// material and the vault's descriptor.
    func pickUpKeys(passphrase: String?, recoveryWords: [String]?) async throws
        -> (material: DeviceKeyMaterial, kdf: PassphraseKDF.Descriptor, recoveryWrapDigest: String?) {
        guard !busy else { throw PostureSwitchError.switchInProgress(.vaultWrite) }
        guard let vault = leaves.vault, await leaves.signedIn() else {
            throw PostureSwitchError.syncKeysUnavailable
        }
        busy = true
        defer { busy = false; phase = .idle }
        phase = .rotatingKeys
        guard let fetched = try await vault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
        let enrollment = VaultEnrollment(client: vault)
        let unwrapped: DeviceKeyMaterial
        if let passphrase, !passphrase.isEmpty {
            unwrapped = try await enrollment.enroll(passphrase: passphrase)
        } else if let recoveryWords, !recoveryWords.isEmpty {
            unwrapped = try await enrollment.enroll(recoveryWords: recoveryWords)
        } else {
            throw PostureSwitchError.secretRequired
        }
        let following = try CorpusRotation.materialFollowing(fetched.format, master: unwrapped.masterSymmetricKey)
        guard await leaves.keyStore.offMain({ $0.save(following) }) else {
            throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
        }
        await resumeSyncAtEnd()
        phase = .done
        leaves.log("follow: the new word opened the vault — sync keys held for this session")
        return (following, fetched.format.kdf, fetched.format.recoveryWrapDigest)
    }

    /// THE FOLLOW INTO STANDARD (§7 — silent): the account left Castle on
    /// another device — the vault gained an Apple-held copy under the SAME
    /// corpus key id — so this device adds its own iCloud copy to its key
    /// file (A from its own iCloud Keychain, minted if absent), moves
    /// custody gated → silent (both items), and re-lock goes off by
    /// derivation. Nothing typed, nothing rotated, no vault write (the
    /// acting device made that one), no marker.
    func followIntoStandard() async throws {
        guard !busy else { throw PostureSwitchError.switchInProgress(.custody) }
        guard let libraryKey = leaves.libraryKeyInHand() else {
            throw PostureSwitchError.libraryKeyUnavailable
        }
        busy = true
        defer { busy = false; phase = .idle }
        phase = .movingCustody
        guard let apple = leaves.appleKeys.readOrMint() else {
            throw PostureSwitchError.appleKeyUnavailable
        }
        guard var envelope = leaves.gate.readEnvelope(leaves.storeURL).envelope else {
            throw StoreKeyEnvelopeError.noPassphraseWrap
        }
        try envelope.setAppleWrappedCopy(key: libraryKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try leaves.gate.saveEnvelope(envelope, leaves.storeURL)
        switch await leaves.moveCustody(.auto) {
        case .changed: break
        case .needsPassphrase:
            throw PostureSwitchError.custodyRefused("The key file carries no passphrase wrap.")
        case .refused(let message):
            throw PostureSwitchError.custodyRefused(message)
        }
        await leaves.reconcile()
        phase = .done
        leaves.log("follow: the account is back in Standard — the Apple copy landed, custody silent")
    }

    /// What the new key file is wrapped under (2c): the typed passphrase
    /// with the descriptor the VAULT's copy uses (the lobby derives once —
    /// §3.6) and/or the twelve words in hand. At least one is present.
    nonisolated struct KeyFileInputs: Sendable {
        var passphrase: String?
        /// pre-13x 4a (ledger 54): a DERIVED key already in hand — the word
        /// typed at the lobby, derived under `kdf` (the vault's descriptor);
        /// the new key file's P copy is L′ wrapped under it. Exclusive with
        /// `passphrase`.
        var passphraseKey: SymmetricKey? = nil
        var kdf: PassphraseKDF.Descriptor
        var recoveryWords: [String]?
        /// pre-13x 4a (ledger 53): the vault's recovery-wrap digest as
        /// fetched — recorded with the descriptor and the corpus key id.
        var recoveryWrapDigest: String?
    }

    /// Steps 3's walk + completion, shared with the resume and the follow.
    /// pre-13x ladder round 1, F1 (BLOCKER-1): the walk waits past the A5
    /// visibility horizon before it decides it is done (`horizonWait`),
    /// and a clearing write the SERVER refuses (`rotationRowsRemain` — a
    /// ciphertext row of the account still below the seq that this
    /// device's pulls could not see) RE-WALKS and completes again, at most
    /// `maxCompletionTries` times; then the honest refusal
    /// (`CorpusRotationError.completionRefused`) with the marker still at
    /// `.reencrypt` — nothing lost, sync paused, the resume re-walks.
    private func reencryptAndComplete(
        vault: KeyVaultClient, transport: any SyncTransport & SyncRotationTransport,
        material: DeviceKeyMaterial
    ) async throws -> (material: DeviceKeyMaterial, reencrypted: Int) {
        phase = .reencrypting(done: 0, total: 0)
        let driver = CorpusRotation(
            transport: transport,
            progress: { [weak self] progress in
                Task { @MainActor [weak self] in
                    self?.phase = .reencrypting(done: progress.reencrypted, total: progress.total)
                }
            },
            horizonWait: leaves.horizonWait)
        var reencrypted = 0
        if material.rotation != nil {
            let report = try await driver.reencryptRemainder(material: material)
            reencrypted = report.replaced
        }
        var tries = 0
        let completed: DeviceKeyMaterial
        while true {
            tries += 1
            do {
                completed = try await CorpusRotation.complete(client: vault, material: material)
                break
            } catch KeyVaultClientError.rotationRowsRemain {
                // A row this device's pulls could not see yet is still under
                // the previous key. Never clear over it: walk again (the
                // wait past the horizon rides every walk), then complete.
                guard material.rotation != nil else { throw KeyVaultClientError.rotationRowsRemain }
                guard tries < Self.maxCompletionTries else {
                    leaves.log("posture switch: the server refused to clear the previous key \(tries) times — a row is still under it; the marker stays at .reencrypt, the resume re-walks")
                    throw CorpusRotationError.completionRefused(tries: tries)
                }
                leaves.log("posture switch: the server refused to clear the previous key (a row still below the seq) — re-walking (try \(tries + 1) of \(Self.maxCompletionTries))")
                let report = try await driver.reencryptRemainder(material: material)
                reencrypted += report.replaced
            }
        }
        guard await leaves.keyStore.offMain({ $0.save(completed) }) else {
            throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
        }
        leaves.log("posture switch: re-encrypted \(reencrypted) rows; the previous key cleared")
        return (completed, reencrypted)
    }

    /// Steps 4–6 (+ the offer's listing), shared with the resume and the
    /// follow. `listPreSwitchPairs`: whether the app's own pre-switch pairs
    /// are offered — only when this library was Standard before (their
    /// "still open through your Apple account" is true exactly then).
    /// `appleKey` (VX-99 — required, every road decides; round 2's finding
    /// 7 carries the KEY, not a Bool): the iCloud key the new key file wraps
    /// L′ under, or nil — the ceremony's enrolled road passes the A its belt
    /// verified (exactly when its vault write carried an Apple-held copy, so
    /// both copies sit under ONE A), its local-only road (Use Castle only)
    /// nil, the follow and the resume's enrolled arm the A read when the
    /// vault's word is Standard (the vault just fetched).
    /// `accountPosture` (VX-99 round 2, finding 3; round 3, MINOR-1): the
    /// ACCOUNT's posture when the caller holds the vault's word for it AND it
    /// tightens (the resume's enrolled arm passes Castle only) — custody
    /// moves to it on a road that does not enter Castle; nil = the posture
    /// read (`leaves.posture()`), every other road's and the into-Standard
    /// direction's (the ready's follow makes that move, with its notice).
    private func rekeyCustodyAndSnapshot(
        entersCastle: Bool, appleKey: AppleKey?, libraryKey: StoreKey, keyFile: KeyFileInputs,
        material: DeviceKeyMaterial?, reencrypted: Int, stamp: String,
        listPreSwitchPairs: Bool, follow: Bool = false, accountPosture: Posture? = nil
    ) async throws -> Outcome {
        // ————— 4. RE-KEY THIS LIBRARY: the NEW key file first, then the swap —————
        phase = .rekeyingLibrary
        let newKey = StoreKey.mint()
        let oldFingerprint = StoreKeyEnvelope.fingerprint(of: libraryKey)
        let newFingerprint = StoreKeyEnvelope.fingerprint(of: newKey)
        let followFlag: Bool? = follow ? true : nil
        try await writeMarker(RotationMarker(
            step: .rekeyLibrary, entersCastle: entersCastle,
            oldKeyFingerprint: oldFingerprint, newKeyFingerprint: newFingerprint,
            newCorpusKeyID: material?.corpusKeyID, startedAt: stamp, follow: followFlag))
        try await writeNewKeyFile(newKey: newKey, appleKey: appleKey, keyFile: keyFile, material: material)
        // VX-202 (belt c): again once the new key file exists — a library
        // that had none until now has its store id only from here.
        markSwitchPending(true)
        try await swapLibrary(from: libraryKey, to: newKey)
        try await writeMarker(RotationMarker(
            step: .custody, entersCastle: entersCastle,
            oldKeyFingerprint: oldFingerprint, newKeyFingerprint: newFingerprint,
            newCorpusKeyID: material?.corpusKeyID, startedAt: stamp, follow: followFlag))

        // ————— 5. CUSTODY (both items) —————
        try await moveCustodyForSwitch(entersCastle: entersCastle, accountPosture: accountPosture)
        leaves.endSwitch()  // VX-202 (gate i): custody landed
        try await writeMarker(RotationMarker(
            step: .snapshot, entersCastle: entersCastle,
            oldKeyFingerprint: oldFingerprint, newKeyFingerprint: newFingerprint,
            newCorpusKeyID: material?.corpusKeyID, startedAt: stamp, follow: followFlag))

        // ————— 6. THE FRESH SNAPSHOT PAIR + the insurance —————
        let (insuranceOff, preSwitch, snapshot) = await snapshotAndInsurance(
            entersCastle: entersCastle, newFingerprint: newFingerprint,
            listPreSwitchPairs: listPreSwitchPairs)
        // pre-13x 2d.4: a follow under a Castle account retires the old
        // key files INSIDE the marker's span — a crash here resumes at
        // `.snapshot` and does the same before clearing.
        if follow, entersCastle { retireOldKeyFiles(oldFingerprint: oldFingerprint, keeping: newFingerprint) }
        try await clearMarker()
        await resumeSyncAtEnd()
        await leaves.reconcile()
        leaves.log("posture switch: \(entersCastle ? "Castle entered" : "keys replaced") — library key \(newFingerprint.prefix(8))")
        return Outcome(
            entersCastle: entersCastle, newKeyFingerprint: newFingerprint,
            insuranceTurnedOff: insuranceOff, preSwitchSnapshots: preSwitch, freshSnapshot: snapshot,
            reencrypted: reencrypted, material: material)
    }

    /// THE NEW KEY FILE under the new fingerprint: L′ under P (the same
    /// fresh descriptor the vault's M′ wrap used — the lobby derives ONCE,
    /// §3.6), under W when the words are in hand, under M′ when enrolled;
    /// the Apple copy ONLY under Standard's Replace All Keys (and a follow
    /// under a Standard account) — `appleKey`, the caller's decision AND key
    /// (VX-99: never "the road does not enter Castle", which wrapped L′
    /// under any readable iCloud key on a Castle account; round 2's finding
    /// 7: never a second read here, which the belt's vault-id check never
    /// saw); the vault's descriptor + corpus key id recorded. The OLD key
    /// file stays.
    private func writeNewKeyFile(
        newKey: StoreKey, appleKey apple: AppleKey?, keyFile: KeyFileInputs, material: DeviceKeyMaterial?
    ) async throws {
        let storeURL = leaves.storeURL
        let gate = leaves.gate
        let storeID: String
        switch StoreIdentity.resolve(besideStore: storeURL) {
        case .known(let id): storeID = id
        case .none: storeID = UUID().uuidString.lowercased()
        case .unreadable: throw StoreKeyEnvelopeError.unreadable("the current key file cannot be read")
        }
        let kdf = keyFile.kdf
        let passphrase = keyFile.passphrase
        let passphraseKey = keyFile.passphraseKey
        let recoveryWords = keyFile.recoveryWords
        guard passphrase != nil || passphraseKey != nil || recoveryWords != nil else { throw PostureSwitchError.secretRequired }
        let envelope: StoreKeyEnvelope = try await Task.detached(priority: .userInitiated) {
            var envelope = StoreKeyEnvelope(storeID: storeID)
            if let passphraseKey {
                // pre-13x 4a (ledger 54): the derived key in hand — no second
                // derivation, no second entry; the descriptor is the vault's.
                let wrap = try StoreKeyEnvelope.makePassphraseWrap(key: newKey, passphraseKey: passphraseKey, kdf: kdf)
                try envelope.adoptPassphraseWrap(wrap, key: newKey)
            } else if let passphrase {
                let wrap = try StoreKeyEnvelope.makePassphraseWrap(key: newKey, passphrase: passphrase, kdf: kdf)
                try envelope.adoptPassphraseWrap(wrap, key: newKey)
            }
            if let recoveryWords {
                try envelope.setRecoveryWrap(key: newKey, words: recoveryWords)
            }
            if let material {
                try envelope.setMasterWrappedCopy(key: newKey, under: material.masterSymmetricKey)
                try envelope.recordVaultReconciliation(
                    kdf: kdf, corpusKeyID: material.corpusKeyID, recoveryWrapDigest: keyFile.recoveryWrapDigest)
            }
            if let apple {
                try envelope.setAppleWrappedCopy(key: newKey, under: apple.symmetricKey, appleKeyID: apple.id)
            }
            return envelope
        }.value
        try gate.saveEnvelope(envelope, storeURL)
        leaves.log("posture switch: the new key file written (\(envelope.keyFingerprint?.prefix(8) ?? "?"))")
    }

    /// The export-and-swap through the bootstrap's road (the pool closed
    /// first, the store reopened under whichever key opens it).
    private func swapLibrary(from oldKey: StoreKey, to newKey: StoreKey) async throws {
        let storeURL = leaves.storeURL
        do {
            try await leaves.rekeyLibrary(oldKey, newKey) {
                try StoreEncryptionMigration.rekey(at: storeURL, from: oldKey, to: newKey)
            }
        } catch let error as StoreEncryptionMigration.MigrationError {
            throw PostureSwitchError.rekeyFailed(error.reason)
        }
    }

    private func moveCustodyForSwitch(entersCastle: Bool, accountPosture: Posture? = nil) async throws {
        phase = .movingCustody
        let target: StoreAtOpenMode
        if entersCastle {
            let biometry = leaves.biometryAvailable()
            target = (leaves.alwaysAsk() || !biometry) ? .passphrase : .biometric
        } else {
            // VX-99 round 2 (finding 3): the account's posture when the
            // caller holds the vault's word (decision 8) — round 3, MINOR-1:
            // only a tightening one (Castle) — else the read.
            target = StoreAtOpenMode.effective(
                posture: accountPosture ?? leaves.posture(), dials: ProtectionDials(alwaysAsk: leaves.alwaysAsk()))
        }
        switch await leaves.moveCustody(target) {
        case .changed: break
        case .needsPassphrase:
            throw PostureSwitchError.custodyRefused("The new key file carries no passphrase wrap.")
        case .refused(let message):
            throw PostureSwitchError.custodyRefused(message)
        }
    }

    private func snapshotAndInsurance(
        entersCastle: Bool, newFingerprint: String, listPreSwitchPairs: Bool
    ) async -> (insuranceOff: Bool, preSwitch: [URL], snapshot: FreshSnapshot) {
        phase = .snapshotting
        // F2 (MAJOR-2): the fresh pair's fate is READ, not discarded — the
        // offer below lists the pre-switch pairs only over a WRITTEN one
        // (design §4 step 6: "BEFORE anything is offered for deletion";
        // §12: "a snapshot under the new key exists before the delete
        // offer" — exists, not merely attempted).
        let snapshot = await leaves.takeSnapshot()
        if case .failed = snapshot {
            leaves.log("posture switch: the fresh snapshot could NOT be written — no offer; the earlier backups stay untouched")
        }
        var insuranceOff = false
        if entersCastle {
            let defaults = leaves.defaults()
            if MarkdownInsurance.isEnabled(in: defaults) {
                MarkdownInsurance.setEnabled(false, in: defaults)
                insuranceOff = true
                leaves.log("posture switch: the scheduled plaintext export turned OFF")
            }
        }
        var preSwitch: [URL] = []
        if listPreSwitchPairs, case .written = snapshot {
            preSwitch = leaves.preSwitchSnapshots(StoreKeyEnvelope.shortFingerprint(newFingerprint))
        }
        return (insuranceOff, preSwitch, snapshot)
    }

    /// The Apple-held copy KEPT under Standard's Replace All Keys (decision
    /// 30) — A READ from iCloud Keychain (never adopted from the wire, and
    /// — F2, MAJOR-3 b — never MINTED here: before F2 this was `readOrMint`,
    /// so a Standard Replace All Keys with A momentarily unreadable minted a
    /// second A and wrapped M′ under it, against decision 30's own words).
    /// When the vault names an id, the key read must BE that id: a
    /// different Apple ID's device could only hand M′ to the wrong Apple
    /// account's key. Either miss refuses (`appleKeyUnreachable`).
    /// VX-99 round 1 (MAJOR): the owed-or-not test is the VAULT's word —
    /// `masterWrappedByAppleHeld != nil` (Standard) — not `leaves.posture()`.
    /// The ceremony fetches the vault at step 1 (`runCeremony`'s
    /// `vault.fetchVault()` after the drain) and this belt holds it, so
    /// decision 8 (posture is the account's once a vault exists)
    /// and decision 35 (no posture-driven write on a stale/indeterminate
    /// reading) govern: a stale CASTLE read on a genuinely Standard account
    /// must NOT drop the copy, and a stale STANDARD read on a Castle account
    /// must NOT add one. The caller still gates `entersCastle ? nil : …`, so
    /// the enter-Castle road (whose fetched vault is still the OLD Standard
    /// one) is unaffected. VX-99 round 2 (finding 7): returns the VERIFIED
    /// key itself — the caller wraps the key file's copy of L′ under it too.
    private func appleHeldCopyForStandard(
        keptUnder fetched: KeyVaultClient.FetchedVault
    ) throws -> AppleKey? {
        guard fetched.format.masterWrappedByAppleHeld != nil else { return nil }
        guard let apple = leaves.appleKeys.read() else {
            leaves.log("posture switch: Replace All Keys under Standard — the iCloud key is not readable here; refused before any write")
            throw PostureSwitchError.appleKeyUnreachable
        }
        if let vaultID = fetched.format.appleKeyID, vaultID != apple.id {
            leaves.log("posture switch: Replace All Keys under Standard — the iCloud key read here (\(apple.id.prefix(8))) is not the account's (\(vaultID.prefix(8))); refused before any write")
            throw PostureSwitchError.appleKeyUnreachable
        }
        return apple
    }

    // MARK: - §7 THE OFFER's act

    /// Delete the app's own PRE-switch pairs the outcome listed — never a
    /// post-switch one (the listing excluded the new fingerprint).
    @discardableResult
    func deletePreSwitchSnapshots(_ outcome: Outcome) -> Int {
        leaves.deleteSnapshotPairs(outcome.preSwitchSnapshots)
    }

    // MARK: - LEAVING CASTLE (§4's second act)

    /// CASTLE → STANDARD: A read (minted if absent); ONE vault write under
    /// the CURRENT proof adding M under A (enrolled); the key file's
    /// `apple` copy of L; custody gated → plain (both items); re-lock off
    /// by derivation. Nothing rotated; no marker (every step is a re-wrap
    /// or a custody move the reconcile heals).
    func leaveCastle() async throws {
        guard !busy else { throw PostureSwitchError.switchInProgress(.custody) }
        guard leaves.posture() == .castle else { throw PostureSwitchError.wrongPosture(leaves.posture()) }
        guard let libraryKey = leaves.libraryKeyInHand() else {
            throw PostureSwitchError.libraryKeyUnavailable
        }
        busy = true
        defer { busy = false; phase = .idle }
        phase = .rotatingKeys
        guard let apple = leaves.appleKeys.readOrMint() else {
            throw PostureSwitchError.appleKeyUnavailable
        }
        // The vault's Apple-held copy (enrolled only).
        if let vault = leaves.vault, await leaves.signedIn(),
           let material = await leaves.keyStore.offMain({ $0.load() }),
           let fetched = try await vault.fetchVault() {
            let updated = try fetched.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: apple.symmetricKey, appleKeyID: apple.id)
            try await vault.updateVault(
                updated, expectedRevision: fetched.revision,
                keyProof: KeyProofMaterial(master: material.masterSymmetricKey))
            leaves.log("leaving Castle: the vault gained the Apple-held copy under \(apple.id.prefix(8))")
        }
        // The key file's Apple copy.
        guard var envelope = leaves.gate.readEnvelope(leaves.storeURL).envelope else {
            throw StoreKeyEnvelopeError.noPassphraseWrap
        }
        try envelope.setAppleWrappedCopy(key: libraryKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try leaves.gate.saveEnvelope(envelope, leaves.storeURL)
        // Custody: gated → plain, both items.
        phase = .movingCustody
        switch await leaves.moveCustody(.auto) {
        case .changed: break
        case .needsPassphrase:
            throw PostureSwitchError.custodyRefused("The key file carries no passphrase wrap.")
        case .refused(let message):
            throw PostureSwitchError.custodyRefused(message)
        }
        await leaves.reconcile()
        phase = .done
        leaves.log("leaving Castle: done — custody silent, the Apple copies landed")
    }

    // MARK: - RESUME (the marker's road)

    /// Re-run a crashed switch from the failed step. `passphrase` is
    /// needed when the step's keys must be unwrapped from a key file or the
    /// vault (`passphraseRequired` says so); nil first, then again with it.
    @discardableResult
    func resume(passphrase: String?, recoveryWords: [String]? = nil) async throws -> Outcome {
        guard !busy else { throw PostureSwitchError.switchInProgress(.vaultWrite) }
        guard let marker = await pendingMarker() else { throw PostureSwitchError.nothingToResume }
        busy = true
        defer { busy = false; phase = .idle }
        let entersCastle = marker.entersCastle
        let signedIn = await leaves.signedIn()
        let enrolled = leaves.vault != nil && leaves.transport != nil && signedIn
        var material: DeviceKeyMaterial? = await leaves.keyStore.offMain { $0.load() }
        var reencrypted = 0
        let typedPassphrase = (passphrase?.isEmpty == false) ? passphrase : nil
        let typedWords = (recoveryWords?.isEmpty == false) ? recoveryWords : nil

        switch marker.step {
        case .vaultWrite, .reencrypt:
            guard enrolled, let vault = leaves.vault, let transport = leaves.transport else {
                throw PostureSwitchError.syncKeysUnavailable
            }
            guard let fetched = try await vault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            let vaultKeyID = fetched.format.classKey(for: .corpus)?.keyID
            if marker.step == .vaultWrite, fetched.format.previousCorpusKey == nil,
               vaultKeyID == material?.corpusKeyID {
                // The write never landed: nothing to resume — start over.
                try await clearMarker()
                throw PostureSwitchError.restartRequired
            }
            // pre-13x 5b (ledger 67) → F1 (ledger 69, THE EXACT DISCRIMINATOR):
            // a marker at `.vaultWrite` with the vault's corpus key id MOVED is
            // one of TWO stories — this device's own write landed (custody did
            // not — the arm below), or this device's write NEVER landed and
            // ANOTHER device's rotation did meanwhile (a ceremony killed before
            // its vault write; the other device entered Castle or replaced the
            // keys). The marker now carries the NEW corpus key id, stamped
            // BEFORE the write (`CorpusRotation.prepare`): the vault's id EQUAL
            // to it ⇒ our own write landed — the ceremony's words ARE the
            // account's, no flag; DIFFERENT ⇒ another device's rotation ⇒ THE
            // RESUME IS THE FOLLOW: the words this ceremony showed are NOT the
            // account's and are not landed, and the Done says so (copy §2b,
            // ledger 61). 5b's device-name reading (`updated_by_device` ≠ this
            // device) survives ONLY as the fallback for a marker written before
            // F1 (no id stamped) — it misread the recorded corner (our write
            // landed, a FOLLOWER finished and stamped its own name).
            // `updated_by_device` now only NAMES the sentence.
            // VX-99 round 2 (finding 3, S2 — the orchestrator's ruling, option
            // a): the STAMP decides at EVERY step that carries one, not at
            // `.vaultWrite` alone. The old premise — "a `.reencrypt` marker is
            // never this case (written only after this device's own write and
            // custody)" — fails whenever another device acts AFTER this
            // device's write: A's own Replace All Keys killed mid-walk; B
            // follows, finishes, then enters Castle (a SECOND rotation). The
            // vault's id is then B's, not the one A stamped, so the road is
            // another device's — exactly as at `.vaultWrite`. A follow's own
            // marker carries no stamp (`runFollow`), so its custody-pending
            // resume still reads as its own; the marker this arm rewrites for
            // another device's road keeps the id A minted (below), so a SECOND
            // crash still reads as another device's.
            let byAnotherDevice: Bool = {
                if let stamped = marker.newCorpusKeyID { return vaultKeyID != stamped }
                guard marker.step == .vaultWrite, vaultKeyID != material?.corpusKeyID else { return false }
                guard let writer = fetched.format.updatedByDevice else { return false }
                return writer != leaves.deviceName()
            }()
            if byAnotherDevice {
                leaves.log("posture switch: resume — the account's keys moved under a marker written before this device's own vault write (the vault's corpus key id is not the one this ceremony minted; \(fetched.format.updatedByDevice ?? "another device") rotated them); this device FOLLOWS instead (no second rotation; the ceremony's words are not landed)")
            } else if marker.step == .vaultWrite, vaultKeyID != material?.corpusKeyID {
                leaves.log("posture switch: resume — this device's own vault write landed (the vault's corpus key id is the one this ceremony minted); custody picks M′ up by the typed secret")
            }
            // VX-99 (the orchestrator's ruling, 5ce7175b — decision 8: the
            // posture is the ACCOUNT's once a vault exists; decision 35: no
            // posture-driven write on a stale reading): this arm HOLDS the
            // vault it just fetched, so the road reads the account from it,
            // exactly as `runFollow` does — never from the posture read, which
            // under an indeterminate reading is the custody SHAPE. The Apple
            // copy: present exactly when the vault carries an Apple-held copy.
            // VX-99 round 2 (finding 3 — option a, S1): the ROAD's posture is
            // the account's on EVERY story, not on another device's alone —
            // the custody target (`accountPosture`), and whether the road
            // ENTERED Castle (the insurance, the offer, the old key files'
            // retirement, the Done): another device's road and a follow's own
            // marker follow the account (`vaultSaysCastle`, `runFollow`'s
            // rule); this device's own ceremony entered Castle only if its act
            // was the switch AND the account is still Castle — A's Use Castle
            // landed, B followed and then used Standard (no rotation, the
            // stamp still A's): the account is Standard, so A's road ends
            // Standard (the Apple copy, no insurance-off, no offer, a Done
            // that names B's act; custody by the read — below). A Replace All
            // Keys never enters Castle by its own act, whatever the account's
            // posture.
            let vaultSaysCastle = fetched.format.masterWrappedByAppleHeld == nil
            let roadEntersCastle = (byAnotherDevice || marker.isFollow)
                ? vaultSaysCastle : (entersCastle && vaultSaysCastle)
            // VX-99 round 3 (MINOR-1 — the orchestrator's ruling, option (b),
            // restoring the pre-F3 custody rule for the into-STANDARD
            // direction): the account's posture overrides the posture read
            // only where it TIGHTENS (Castle). An account that left Castle
            // elsewhere leaves custody to the read — behind the gate on a
            // device still reading Castle — so the next ready's follow into
            // Standard (`ProtectionController.reconcileFollow`) moves it WITH
            // §7's one-time notice ("Your account is back in Standard — set on
            // [device] on [day]"). Round 2's F3 moved it silent here, saying
            // nothing, and the Apple copy the key file then carried (the
            // vault's word, below — unchanged) kept that arm from ever firing:
            // the device stopped asking for Touch ID and nothing said why. A
            // key file and a custody that disagree until that ready is the
            // announced road, not a gap.
            let tighteningPosture: Posture? = vaultSaysCastle ? .castle : nil
            if vaultKeyID != material?.corpusKeyID {
                // The write landed, custody did not: M′ by the passphrase
                // (or the twelve words — 2c: the follow's own resume).
                let master: SymmetricKey
                if let typedPassphrase {
                    master = try await VaultEnrollment(client: vault).enroll(passphrase: typedPassphrase).masterSymmetricKey
                } else if let typedWords {
                    master = try await VaultEnrollment(client: vault).enroll(recoveryWords: typedWords).masterSymmetricKey
                } else {
                    throw PostureSwitchError.passphraseRequired
                }
                let following = try CorpusRotation.materialFollowing(fetched.format, master: master)
                guard await leaves.keyStore.offMain({ $0.save(following) }) else {
                    throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
                }
                material = following
            } else if fetched.format.previousCorpusKey != nil, material?.rotation == nil, let held = material {
                // Custody holds M′ but not the previous key (a crash between
                // the vault write and the custody write on a PARTIAL save).
                material = try CorpusRotation.materialFollowing(fetched.format, master: held.masterSymmetricKey)
            }
            guard let held = material else { throw PostureSwitchError.syncKeysUnavailable }
            // VX-99 round 1 (MINOR): the `.reencrypt` marker carries THE
            // ROAD's facts, not `marker.advanced(to:)`'s copy of the ORIGINAL
            // marker (`entersCastle: false` for a Replace All Keys, no follow
            // flag). A SECOND crash inside the walk below leaves this marker
            // pending; without the road's facts the next resume read the
            // marker's stale `entersCastle`/`follow` and moved custody to
            // `.auto`, skipped `retireOldKeyFiles` and returned an outcome
            // that had not entered Castle (the runner's log line said "keys
            // replaced"). The Apple copy was never at risk (it reads the fresh
            // fetch). VX-99 round 2 (finding 3; the NIT to carry the vault's
            // id here NOT adopted — the record): `newCorpusKeyID` stays the
            // id THIS marker was stamped with. On another device's road that
            // is the id this device minted for a write that never landed — so
            // the second resume's stamp still differs from the vault's and the
            // road still reads as another device's (the other-device Done, the
            // words rule), round 1's recorded residual closed by the same rule.
            // And `entersCastle` is the ROAD's only where the road follows the
            // account (another device's road, a follow's marker); on this
            // device's OWN road it stays the ACT's — recomputed against the
            // fresh vault at every resume anyway — so a resume that stops
            // here to ask the passphrase does not forget it was finishing a
            // Use Castle (S1's Done; the pane's door label).
            try await writeMarker(RotationMarker(
                step: .reencrypt, entersCastle: (byAnotherDevice || marker.isFollow) ? roadEntersCastle : entersCastle,
                oldKeyFingerprint: marker.oldKeyFingerprint, newKeyFingerprint: marker.newKeyFingerprint,
                newCorpusKeyID: marker.newCorpusKeyID, startedAt: marker.startedAt,
                follow: (marker.isFollow || byAnotherDevice) ? true : nil))
            let final = try await reencryptAndComplete(vault: vault, transport: transport, material: held)
            material = final.material
            reencrypted = final.reencrypted
            guard let libraryKey = leaves.libraryKeyInHand() else { throw PostureSwitchError.libraryKeyUnavailable }
            guard typedPassphrase != nil || typedWords != nil else { throw PostureSwitchError.passphraseRequired }
            // The key file's passphrase copy under the VAULT's descriptor
            // (the lobby derives once); a resume by words alone lands the
            // W copy, the P copy landing when the passphrase is next typed.
            let wasStandardShaped = leaves.gate.readEnvelope(leaves.storeURL).envelope?.apple != nil
            var outcome = try await rekeyCustodyAndSnapshot(
                // VX-99: the vault's word (above) — the marker's
                // `entersCastle` is false for Replace All Keys in EITHER
                // posture, so it never decides the Apple copy.
                entersCastle: roadEntersCastle, appleKey: vaultSaysCastle ? nil : leaves.appleKeys.read(),
                libraryKey: libraryKey,
                // The ceremony's words are NOT landed when another device's
                // rotation is what this resume picked up (M1's rule): the
                // account's words are the other device's; the W copy lands
                // when they are next typed here.
                keyFile: KeyFileInputs(passphrase: typedPassphrase, kdf: fetched.format.kdf,
                                       recoveryWords: byAnotherDevice ? nil : typedWords,
                                       recoveryWrapDigest: fetched.format.recoveryWrapDigest),
                material: material, reencrypted: reencrypted, stamp: marker.startedAt,
                listPreSwitchPairs: roadEntersCastle && wasStandardShaped, follow: marker.isFollow || byAnotherDevice,
                accountPosture: tighteningPosture)
            // VX-99 round 3 (the MAJOR — the orchestrator's ruling, restoring
            // the pre-F3 face): the conflict-follow's flag — ledger 61's "the
            // twelve words shown here are not your account's" — is true only
            // where this ceremony's own vault write NEVER landed. This
            // device's OWN `.reencrypt` marker (`!isFollow`: the ceremony
            // writes it only after its own write landed and custody took M′,
            // and this arm's own-road rewrite keeps it so) means its words DID
            // land; another device's LATER rotation (F3's S2) may have kept
            // them — typed from the paper, decision 33 — or replaced them, and
            // the marker cannot tell which. So that road keeps every F3 fact
            // above (custody, the account's posture, the retirement, the
            // offer, the words rule) but never the flag: its Done is the
            // selector's ordinary one, with no words claim — the road it took
            // before F3. The `.vaultWrite` case and the second-crash
            // ambiguity stay as they were (VX-107's).
            let ownWriteLanded = marker.step == .reencrypt && !marker.isFollow
            if byAnotherDevice, !ownWriteLanded {
                outcome.followedAnotherDevicesSwitch = true
                outcome.otherDeviceName = fetched.format.updatedByDevice
            } else if entersCastle, !marker.isFollow, !roadEntersCastle {
                // S1: this device's own Use Castle, the account Standard now —
                // the Done names the device that left Castle and its day (on
                // the stamped road above too: B left Castle, then rotated).
                outcome.otherDeviceName = fetched.format.updatedByDevice
                outcome.otherDeviceDay = fetched.updatedAt
            }
            return outcome

        case .rekeyLibrary:
            // Which side of the swap did the crash leave the file on?
            guard let inHand = leaves.libraryKeyInHand() else { throw PostureSwitchError.libraryKeyUnavailable }
            let newFingerprint = marker.newKeyFingerprint ?? ""
            let (newKey, newEnvelope) = try newKeyFromKeyFile(
                fingerprint: newFingerprint, material: material, passphrase: typedPassphrase,
                recoveryWords: typedWords)
            let storeURL = leaves.storeURL
            let fileIsUnderNew = await Task.detached { StoreEncryptionMigration.opens(storeURL, key: newKey) }.value
            if !fileIsUnderNew {
                // Before the swap: redo the export-and-swap with the SAME L′
                // (the key file is the durable record of it).
                let oldKey = inHand
                try await swapLibrary(from: oldKey, to: newKey)
            }
            _ = newEnvelope
            try await writeMarker(marker.advanced(to: .custody))
            fallthrough

        case .custody:
            // The store is open under L′ (the reopen adopted it); custody
            // moves to the target shape.
            if marker.step == .custody || marker.step == .rekeyLibrary {
                try await moveCustodyForSwitch(entersCastle: entersCastle)
                leaves.endSwitch()  // VX-202 (gate i): custody landed
                try await writeMarker(marker.advanced(to: .snapshot))
            }
            fallthrough

        case .snapshot, .offer:
            // pre-13x ladder round 1, F2 (NIT-3): a marker at `.snapshot` /
            // `.offer` ALWAYS carries the new key's fingerprint — it is
            // written at `.rekeyLibrary` and rides every `advanced(to:)`
            // after it — so the fallback is UNREACHABLE by construction; it
            // used to mint a throwaway key for a fingerprint. Now: the key
            // in hand's fingerprint (the reopen adopted L′), else the
            // honest refusal — never a key that never existed.
            let newFingerprint: String
            if let stamped = marker.newKeyFingerprint {
                newFingerprint = stamped
            } else if let inHand = leaves.libraryKeyInHand() {
                newFingerprint = StoreKeyEnvelope.fingerprint(of: inHand)
            } else {
                throw PostureSwitchError.libraryKeyUnavailable
            }
            // The old key file (named by the marker) says whether this
            // library was Standard-shaped — the offer is honest only then.
            let oldFile = marker.oldKeyFingerprint.flatMap {
                try? StoreKeyEnvelope.load(at: StoreKeyEnvelope.url(besideStore: leaves.storeURL, fingerprint: $0))
            }
            let (insuranceOff, preSwitch, snapshot) = await snapshotAndInsurance(
                entersCastle: entersCastle, newFingerprint: newFingerprint,
                listPreSwitchPairs: entersCastle && (oldFile?.apple != nil))
            // pre-13x 2d.4 (ruling 3): a resumed FOLLOW still retires the old
            // key files — the exposure's closure never depends on the
            // process having survived.
            if marker.isFollow, entersCastle {
                retireOldKeyFiles(oldFingerprint: marker.oldKeyFingerprint, keeping: newFingerprint)
            }
            try await clearMarker()
            await resumeSyncAtEnd()
            await leaves.reconcile()
            phase = .done
            return Outcome(
                entersCastle: entersCastle, newKeyFingerprint: newFingerprint,
                insuranceTurnedOff: insuranceOff, preSwitchSnapshots: preSwitch, freshSnapshot: snapshot,
                reencrypted: reencrypted, material: material)
        }
    }

    /// L′ from the NEW key file (named by the marker's fingerprint): the
    /// master copy under M′ when enrolled, else the passphrase copy, else
    /// (2c) the twelve words' copy.
    private func newKeyFromKeyFile(
        fingerprint: String, material: DeviceKeyMaterial?, passphrase: String?,
        recoveryWords: [String]? = nil
    ) throws -> (StoreKey, StoreKeyEnvelope) {
        let url = StoreKeyEnvelope.url(besideStore: leaves.storeURL, fingerprint: fingerprint)
        guard let envelope = try StoreKeyEnvelope.load(at: url) else {
            throw PostureSwitchError.rekeyFailed("the new key file is missing beside the library")
        }
        if let material, envelope.master != nil {
            return (try envelope.unwrapKey(master: material.masterSymmetricKey), envelope)
        }
        if let passphrase, !passphrase.isEmpty, envelope.passphrase != nil {
            return (try envelope.unwrapKey(passphrase: passphrase), envelope)
        }
        if let recoveryWords, !recoveryWords.isEmpty, envelope.recovery != nil {
            return (try envelope.unwrapKey(recoveryWords: recoveryWords), envelope)
        }
        throw PostureSwitchError.passphraseRequired
    }

    // MARK: - Plumbing

    private func withDatabase<T: Sendable>(_ body: @escaping @Sendable () async throws -> T) async throws -> T {
        let database = leaves.database
        return try await withDependencies {
            $0.database = database
        } operation: {
            try await body()
        }
    }

    /// VX-202 (belt c): the store-id signal mirrors "the marker names a step
    /// before custody landed" and is never behind it — set BEFORE such a
    /// marker is written, cleared only AFTER a later marker (or the clear)
    /// is durable.
    private func writeMarker(_ marker: RotationMarker) async throws {
        let pending = Self.custodyPending(at: marker.step)
        if pending { markSwitchPending(true) }
        try await leaves.database.write { db in try RotationMarker.write(marker, db) }
        if !pending { markSwitchPending(false) }
    }

    private func clearMarker() async throws {
        try await leaves.database.write { db in try RotationMarker.clear(db) }
        markSwitchPending(false)
    }

    /// The steps a marker can name while this library's custody move is
    /// still to come.
    nonisolated private static func custodyPending(at step: RotationMarker.Step) -> Bool {
        switch step {
        case .vaultWrite, .reencrypt, .rekeyLibrary, .custody: return true
        case .snapshot, .offer: return false
        }
    }

    /// VX-202 (belt c): the per-store-id flag the PRE-OPEN route reads in
    /// the marker's place (the marker lives inside the store). No store id
    /// (no key file yet) ⇒ nothing to key it by; the runner sets it again
    /// once its new key file exists.
    private func markSwitchPending(_ pending: Bool) {
        guard case .known(let storeID) = StoreIdentity.resolve(besideStore: leaves.storeURL) else { return }
        leaves.gate.setSwitchPending(pending, leaves.scope, storeID)
    }
}


// MARK: - The production leaves

extension PostureSwitchRunner.Leaves {
    /// The Mac's (and, at 2c, the phone's) composition: the bootstrap's
    /// re-key road, the controller's custody and posture, the services'
    /// vault/transport/backups read LIVE (the `.ready` tree — and its
    /// `AppServices` — is rebuilt across the re-key's reopen, so the
    /// closures look the current one up rather than capturing an object
    /// the reopen retires).
    @MainActor
    static func live(
        bootstrap: AppBootstrap,
        protection: ProtectionController,
        scope: String,
        storeURL: URL,
        database: AppDatabase,
        services: @escaping @MainActor () -> AppServices?
    ) -> PostureSwitchRunner.Leaves {
        let keyStore = DeviceKeyStore.keychain(scope: scope, storeURL: storeURL)
        let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")
        let containerBackups = storeURL.deletingLastPathComponent()
            .appendingPathComponent("Backups", isDirectory: true)
        let current = services()
        let transport: (any SyncTransport & SyncRotationTransport)? = current.flatMap { live in
            ProjectConfig.variorumConfigured
                ? SupabaseTransport(configuration: ProjectConfig.variorumTransport, sessionProvider: live.auth)
                : nil
        }
        let pairs: @Sendable (URL, String) -> [URL] = { folder, keep in
            ((try? StoreBackup.existingBackups(in: folder)) ?? []).filter {
                StoreBackup.shortFingerprint(fromBackupURL: $0) != keep
            }
        }
        return PostureSwitchRunner.Leaves(
            scope: scope,
            storeURL: storeURL,
            database: database,
            gate: bootstrap.gate,
            keyStore: keyStore,
            keyProvider: DeviceKeySyncProvider(store: keyStore),
            // F2 (MINOR-5): the same facts the regular engine carries.
            sampleLibraryFacts: SampleLibrarySeeder.allDedupeFacts(),
            // 17y B-DEDUPE: the furniture fold's SHARED half (the corner
            // above — the guide half is the regular engine's).
            furnitureFacts: SampleLibrarySeeder.furnitureDedupeFacts(),
            vault: current?.keyVault,
            transport: transport,
            signedIn: { [current] in
                guard let auth = current?.auth else { return false }
                return await auth.currentUserID != nil
            },
            appleKeys: .live(scope: scope),
            libraryKeyInHand: { protection.keyInHand() },
            posture: { protection.posture },
            alwaysAsk: { protection.dials.alwaysAsk },
            biometryAvailable: { protection.biometryAvailable },
            moveCustody: { target in await protection.moveCustody(to: target) },
            rekeyLibrary: { old, new, work in
                try await bootstrap.rekeyLibrary(from: old, to: new, work: work)
            },
            pauseSync: { services()?.sync.stop() },
            // F2 (MAJOR-1): RECONNECT, never a bare trigger — see
            // `AppServices.resumeSync()`. `services()` is read LIVE: after a
            // successful re-key the reopen has retired the old services
            // (nil here — the fresh ones connect in their own `start()`) or
            // already rebuilt them (a trigger).
            resumeSync: { await services()?.resumeSync() },
            takeSnapshot: {
                // F2 (MAJOR-2): three answers — no backups on this platform
                // (the phone: `AppServices.backup` is nil), a run that did
                // not write, a written pair.
                guard let backup = services()?.backup else { return .notKept }
                let record = await backup.backUpNow()
                guard record.primary.outcome == .written, let name = record.primary.file else { return .failed }
                return .written(backup.directory.appendingPathComponent(name))
            },
            preSwitchSnapshots: { keep in
                var found = pairs(containerBackups, keep)
                if let resolved = BackupDestination.resolve(in: .standard) {
                    let far = BackupDestination.backupsFolder(in: resolved.picked)
                    found += BackupDestination.withAccess(to: resolved.picked) { pairs(far, keep) }
                }
                return found
            },
            deleteSnapshotPairs: { urls in
                var removed = 0
                let resolved = BackupDestination.resolve(in: .standard)
                for url in urls {
                    let insidePicked = resolved.map { url.path.hasPrefix($0.picked.path) } ?? false
                    if insidePicked, let picked = resolved?.picked {
                        BackupDestination.withAccess(to: picked) {
                            if (try? StoreBackup.removeSnapshotPair(url)) != nil { removed += 1 }
                        }
                    } else if (try? StoreBackup.removeSnapshotPair(url)) != nil {
                        removed += 1
                    }
                }
                return removed
            },
            defaults: { .standard },
            reconcile: { await protection.reconcile() },
            now: { Date() },
            log: { logger.notice("\($0, privacy: .public)") },
            // pre-13x 5b (ledger 67): the name the vault client stamps —
            // `AppServices` hands the same `DeviceName.current` to it.
            deviceName: { DeviceName.current },
            endSwitch: { bootstrap.endSwitch() })
    }
}

extension PostureSwitchRunner.Leaves {
    /// pre-13x ladder round 1, F2 (MINOR-5): THE DRAIN's engine — the
    /// ceremony's own `SyncEngine` over the leaves' transport, key provider
    /// AND the seeded books' dedupe facts (the `SyncSession.configure`
    /// composition, mirrored here so a second engine never silently drops
    /// a repair the design says every pull carries).
    nonisolated func drainEngine(transport: any SyncTransport) -> SyncEngine {
        SyncEngine(
            transport: transport, keyProvider: keyProvider,
            sampleLibraryFacts: sampleLibraryFacts, furnitureFacts: furnitureFacts)
    }
}
