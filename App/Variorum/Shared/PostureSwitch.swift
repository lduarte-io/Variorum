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
    case switchInProgress(RotationMarker.Step)
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
    /// The act does not apply to the current posture.
    case wrongPosture(Posture)
    /// The re-key road refused (worded).
    case rekeyFailed(String)
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
        var preSwitchSnapshots: [URL]
        /// Rows re-encrypted on the server (0 for a local-only library).
        var reencrypted: Int
        /// The final custody material (nil for a local-only library).
        var material: DeviceKeyMaterial?
    }

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
        var resumeSync: @MainActor () -> Void
        /// The fresh snapshot pair under the CURRENT key (nil = this
        /// platform keeps no backups).
        var takeSnapshot: @MainActor () async -> URL?
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
    }

    private(set) var phase: Phase = .idle
    private(set) var busy = false
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
        var vaultHasRecoveryWrap: Bool
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
            vaultHasRecoveryWrap: fetched.format.masterWrappedByRecovery != nil)
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
        guard !busy else { throw PostureSwitchError.switchInProgress(.vaultWrite) }
        if let pending = await pendingMarker() {
            throw PostureSwitchError.switchInProgress(pending.step)
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
        let secrets = try await Task.detached(priority: .userInitiated) {
            try RotationSecrets.derive(passphrase: passphrase, recoveryWords: recoveryWords)
        }.value
        var material: DeviceKeyMaterial?
        var reencrypted = 0
        let stamp = DateFormatter.variorumISO8601.string(from: leaves.now())

        if enrolled, let vault = leaves.vault, let transport = leaves.transport {
            // ————— 1. PULL TO HEAD (the three refusals) —————
            phase = .pullingToHead
            leaves.pauseSync()
            let engine = SyncEngine(transport: transport, keyProvider: leaves.keyProvider)
            try await withDatabase { _ = try await engine.push() }
            try await withDatabase { _ = try await engine.pullToHead() }
            let pending = try await withDatabase { try await engine.outboxCount() }
            guard pending == 0 else { throw SyncError.outboxNotEmpty(pending: pending) }
            guard let fetched = try await vault.fetchVault() else { throw KeyVaultClientError.vaultAbsent }
            if let previous = fetched.format.previousCorpusKey {
                throw CorpusRotationError.rotationInProgress(previousKeyID: previous.keyID)
            }
            guard let current = await leaves.keyStore.offMain({ $0.load() }) else {
                throw PostureSwitchError.syncKeysUnavailable
            }

            // ————— 2. ROTATE THE SYNC KEYS (the marker BEFORE the write) —————
            phase = .rotatingKeys
            try await writeMarker(RotationMarker(step: .vaultWrite, entersCastle: entersCastle, startedAt: stamp))
            let appleHeld: (key: SymmetricKey, id: String)? = entersCastle ? nil : appleHeldCopyForStandard()
            let begun = try await CorpusRotation.begin(
                client: vault, current: current, secrets: secrets, appleHeldCopy: appleHeld)
            leaves.log("posture switch: the vault rewritten under the old proof — rotation seq \(begun.receipt.rotationStartedSeq ?? -1)")
            guard await leaves.keyStore.offMain({ $0.save(begun.material) }) else {
                // The vault has moved; this device's custody could not take
                // M′ — the follow (the passphrase) picks it up at resume.
                throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
            }
            try await writeMarker(RotationMarker(step: .reencrypt, entersCastle: entersCastle, startedAt: stamp))

            // ————— 3. RE-ENCRYPT THE SERVER COPY —————
            let final = try await reencryptAndComplete(vault: vault, transport: transport, material: begun.material)
            material = final.material
            reencrypted = final.reencrypted
        } else {
            leaves.log("posture switch: local-only — steps 4–7 only")
        }

        // ————— 4–6: the library, custody, the snapshot —————
        let outcome = try await rekeyCustodyAndSnapshot(
            entersCastle: entersCastle, libraryKey: libraryKey, passphrase: passphrase,
            recoveryWords: recoveryWords, secrets: secrets, material: material,
            reencrypted: reencrypted, stamp: stamp)
        phase = .done
        return outcome
    }

    /// Steps 3's walk + completion, shared with the resume.
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
            })
        var reencrypted = 0
        if material.rotation != nil {
            let report = try await driver.reencryptRemainder(material: material)
            reencrypted = report.replaced
        }
        let completed = try await CorpusRotation.complete(client: vault, material: material)
        guard await leaves.keyStore.offMain({ $0.save(completed) }) else {
            throw PostureSwitchError.custodyRefused(ProtectionCopy.syncKeysWroteButUnreadable)
        }
        leaves.log("posture switch: re-encrypted \(reencrypted) rows; the previous key cleared")
        return (completed, reencrypted)
    }

    /// Steps 4–6 (+ the offer's listing), shared with the resume.
    private func rekeyCustodyAndSnapshot(
        entersCastle: Bool, libraryKey: StoreKey, passphrase: String, recoveryWords: [String]?,
        secrets: RotationSecrets, material: DeviceKeyMaterial?, reencrypted: Int, stamp: String
    ) async throws -> Outcome {
        // ————— 4. RE-KEY THIS LIBRARY: the NEW key file first, then the swap —————
        phase = .rekeyingLibrary
        let newKey = StoreKey.mint()
        let oldFingerprint = StoreKeyEnvelope.fingerprint(of: libraryKey)
        let newFingerprint = StoreKeyEnvelope.fingerprint(of: newKey)
        try await writeMarker(RotationMarker(
            step: .rekeyLibrary, entersCastle: entersCastle,
            oldKeyFingerprint: oldFingerprint, newKeyFingerprint: newFingerprint,
            newCorpusKeyID: material?.corpusKeyID, startedAt: stamp))
        try await writeNewKeyFile(
            newKey: newKey, entersCastle: entersCastle, passphrase: passphrase,
            recoveryWords: recoveryWords, secrets: secrets, material: material)
        try await swapLibrary(from: libraryKey, to: newKey)
        try await writeMarker(RotationMarker(
            step: .custody, entersCastle: entersCastle,
            oldKeyFingerprint: oldFingerprint, newKeyFingerprint: newFingerprint,
            newCorpusKeyID: material?.corpusKeyID, startedAt: stamp))

        // ————— 5. CUSTODY (both items) —————
        try await moveCustodyForSwitch(entersCastle: entersCastle)
        try await writeMarker(RotationMarker(
            step: .snapshot, entersCastle: entersCastle,
            oldKeyFingerprint: oldFingerprint, newKeyFingerprint: newFingerprint,
            newCorpusKeyID: material?.corpusKeyID, startedAt: stamp))

        // ————— 6. THE FRESH SNAPSHOT PAIR + the insurance —————
        let (insuranceOff, preSwitch) = await snapshotAndInsurance(
            entersCastle: entersCastle, newFingerprint: newFingerprint)
        try await clearMarker()
        leaves.resumeSync()
        await leaves.reconcile()
        leaves.log("posture switch: \(entersCastle ? "Castle entered" : "keys replaced") — library key \(newFingerprint.prefix(8))")
        return Outcome(
            entersCastle: entersCastle, newKeyFingerprint: newFingerprint,
            insuranceTurnedOff: insuranceOff, preSwitchSnapshots: preSwitch,
            reencrypted: reencrypted, material: material)
    }

    /// THE NEW KEY FILE under the new fingerprint: L′ under P (the same
    /// fresh descriptor the vault's M′ wrap used — the lobby derives ONCE,
    /// §3.6), under W when the words are in hand, under M′ when enrolled;
    /// the Apple copy ONLY under Standard's Replace All Keys; the vault's
    /// descriptor + corpus key id recorded. The OLD key file stays.
    private func writeNewKeyFile(
        newKey: StoreKey, entersCastle: Bool, passphrase: String, recoveryWords: [String]?,
        secrets: RotationSecrets, material: DeviceKeyMaterial?
    ) async throws {
        let storeURL = leaves.storeURL
        let gate = leaves.gate
        let storeID: String
        switch StoreIdentity.resolve(besideStore: storeURL) {
        case .known(let id): storeID = id
        case .none: storeID = UUID().uuidString.lowercased()
        case .unreadable: throw StoreKeyEnvelopeError.unreadable("the current key file cannot be read")
        }
        let kdf = secrets.kdf
        let apple: AppleKey? = entersCastle ? nil : leaves.appleKeys.read()
        let envelope: StoreKeyEnvelope = try await Task.detached(priority: .userInitiated) {
            var envelope = StoreKeyEnvelope(storeID: storeID)
            let wrap = try StoreKeyEnvelope.makePassphraseWrap(key: newKey, passphrase: passphrase, kdf: kdf)
            try envelope.adoptPassphraseWrap(wrap, key: newKey)
            if let recoveryWords {
                try envelope.setRecoveryWrap(key: newKey, words: recoveryWords)
            }
            if let material {
                try envelope.masterBox(key: newKey, under: material.masterSymmetricKey)
                try envelope.recordVaultReconciliation(kdf: kdf, corpusKeyID: material.corpusKeyID)
            }
            if let apple {
                try envelope.appleBox(key: newKey, under: apple.symmetricKey, appleKeyID: apple.id)
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

    private func moveCustodyForSwitch(entersCastle: Bool) async throws {
        phase = .movingCustody
        let target: StoreAtOpenMode
        if entersCastle {
            let biometry = leaves.biometryAvailable()
            target = (leaves.alwaysAsk() || !biometry) ? .passphrase : .biometric
        } else {
            target = StoreAtOpenMode.effective(
                posture: leaves.posture(), dials: ProtectionDials(alwaysAsk: leaves.alwaysAsk()))
        }
        switch await leaves.moveCustody(target) {
        case .changed: break
        case .needsPassphrase:
            throw PostureSwitchError.custodyRefused("The new key file carries no passphrase wrap.")
        case .refused(let message):
            throw PostureSwitchError.custodyRefused(message)
        }
    }

    private func snapshotAndInsurance(entersCastle: Bool, newFingerprint: String) async -> (Bool, [URL]) {
        phase = .snapshotting
        _ = await leaves.takeSnapshot()
        var insuranceOff = false
        if entersCastle {
            let defaults = leaves.defaults()
            if MarkdownInsurance.isEnabled(in: defaults) {
                MarkdownInsurance.setEnabled(false, in: defaults)
                insuranceOff = true
                leaves.log("posture switch: the scheduled plaintext export turned OFF")
            }
        }
        let preSwitch = entersCastle
            ? leaves.preSwitchSnapshots(StoreKeyEnvelope.shortFingerprint(newFingerprint))
            : []
        return (insuranceOff, preSwitch)
    }

    /// The Apple-held copy KEPT under Standard's Replace All Keys (decision
    /// 30) — A read from iCloud Keychain (never adopted from the wire).
    private func appleHeldCopyForStandard() -> (key: SymmetricKey, id: String)? {
        guard leaves.posture() == .standard, let apple = leaves.appleKeys.readOrMint() else { return nil }
        return (apple.symmetricKey, apple.id)
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
                keyProof: KeyProof.wireToken(master: material.masterSymmetricKey))
            leaves.log("leaving Castle: the vault gained the Apple-held copy under \(apple.id.prefix(8))")
        }
        // The key file's Apple copy.
        guard var envelope = leaves.gate.readEnvelope(leaves.storeURL).envelope else {
            throw StoreKeyEnvelopeError.noPassphraseWrap
        }
        try envelope.appleBox(key: libraryKey, under: apple.symmetricKey, appleKeyID: apple.id)
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
        var secrets: RotationSecrets?
        if let passphrase, !passphrase.isEmpty {
            secrets = try await Task.detached(priority: .userInitiated) {
                try RotationSecrets.derive(passphrase: passphrase, recoveryWords: recoveryWords)
            }.value
        }

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
            if vaultKeyID != material?.corpusKeyID {
                // The write landed, custody did not: M′ by the passphrase.
                guard let passphrase, !passphrase.isEmpty else {
                    throw PostureSwitchError.passphraseRequired
                }
                let master = try await VaultEnrollment(client: vault).enroll(passphrase: passphrase).masterSymmetricKey
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
            try await writeMarker(marker.advanced(to: .reencrypt))
            let final = try await reencryptAndComplete(vault: vault, transport: transport, material: held)
            material = final.material
            reencrypted = final.reencrypted
            guard let libraryKey = leaves.libraryKeyInHand() else { throw PostureSwitchError.libraryKeyUnavailable }
            guard let passphrase, let secrets else { throw PostureSwitchError.passphraseRequired }
            return try await rekeyCustodyAndSnapshot(
                entersCastle: entersCastle, libraryKey: libraryKey, passphrase: passphrase,
                recoveryWords: recoveryWords, secrets: secrets, material: material,
                reencrypted: reencrypted, stamp: marker.startedAt)

        case .rekeyLibrary:
            // Which side of the swap did the crash leave the file on?
            guard let inHand = leaves.libraryKeyInHand() else { throw PostureSwitchError.libraryKeyUnavailable }
            let newFingerprint = marker.newKeyFingerprint ?? ""
            let (newKey, newEnvelope) = try newKeyFromKeyFile(
                fingerprint: newFingerprint, material: material, passphrase: passphrase)
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
                try await writeMarker(marker.advanced(to: .snapshot))
            }
            fallthrough

        case .snapshot, .offer:
            let newFingerprint = marker.newKeyFingerprint ?? StoreKeyEnvelope.fingerprint(of: leaves.libraryKeyInHand() ?? StoreKey.mint())
            let (insuranceOff, preSwitch) = await snapshotAndInsurance(
                entersCastle: entersCastle, newFingerprint: newFingerprint)
            try await clearMarker()
            leaves.resumeSync()
            await leaves.reconcile()
            phase = .done
            return Outcome(
                entersCastle: entersCastle, newKeyFingerprint: newFingerprint,
                insuranceTurnedOff: insuranceOff, preSwitchSnapshots: preSwitch,
                reencrypted: reencrypted, material: material)
        }
    }

    /// L′ from the NEW key file (named by the marker's fingerprint): the
    /// master copy under M′ when enrolled, else the passphrase copy.
    private func newKeyFromKeyFile(
        fingerprint: String, material: DeviceKeyMaterial?, passphrase: String?
    ) throws -> (StoreKey, StoreKeyEnvelope) {
        let url = StoreKeyEnvelope.url(besideStore: leaves.storeURL, fingerprint: fingerprint)
        guard let envelope = try StoreKeyEnvelope.load(at: url) else {
            throw PostureSwitchError.rekeyFailed("the new key file is missing beside the library")
        }
        if let material, envelope.master != nil {
            return (try envelope.unwrapKey(master: material.masterSymmetricKey), envelope)
        }
        guard let passphrase, !passphrase.isEmpty else { throw PostureSwitchError.passphraseRequired }
        return (try envelope.unwrapKey(passphrase: passphrase), envelope)
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

    private func writeMarker(_ marker: RotationMarker) async throws {
        try await leaves.database.write { db in try RotationMarker.write(marker, db) }
    }

    private func clearMarker() async throws {
        try await leaves.database.write { db in try RotationMarker.clear(db) }
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
            resumeSync: { services()?.sync.triggerSync() },
            takeSnapshot: {
                guard let backup = services()?.backup else { return nil }
                let record = await backup.backUpNow()
                guard record.primary.outcome == .written, let name = record.primary.file else { return nil }
                return backup.directory.appendingPathComponent(name)
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
            log: { logger.notice("\($0, privacy: .public)") })
    }
}
