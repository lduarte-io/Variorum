//
//  LibraryOpenModel.swift
//  Variorum (shared — the adoption doors' ONE brain; the Mac faces render
//  it, the phone's door is a later catch-up's)
//
//  Phase 13x, U2 row 6 — THE ADOPTION FLOW behind both framed doors (QB:
//  *File ▸ Open Library…* and *Restore from Backup…* — one machinery, one
//  classifier, distinct framing). It INVENTS NO crypto and re-derives no
//  road: the picked thing is classified by the U1 brain; an encrypted
//  pair opens by the LOBBY'S OWN ROADS over the SOURCE pair (the Apple
//  road silently first — same-iCloud Standard; then the passphrase / the
//  twelve words through the shipped envelope road, the vault road riding
//  online) with the SAME-FINGERPRINT SECOND LOOK first of all (ledger 14:
//  the live custody serves a same-key copy — the silent item, or one
//  Touch ID ask); the landing is U1's `LibraryAdoption`; the custody
//  write is the collision rule's verdict through the EXISTING save doors
//  (`StoreKeyGuard.saveAuto`/`saveGated` — the memo's "no new write
//  path"); and every landing is HELD (`LibraryRestoreHold`, round 3's
//  ruling) until the one Resume press.
//
//  THE SOURCE-GATE OVERRIDE, recorded: the lobby's envelope road reads
//  the key file through `gate.loadEnvelope`, which locates the CURRENT
//  fingerprint-named file beside a store — a snapshot's own pair
//  (`…keys.json`) would be missed. The road therefore runs over a COPY of
//  the gate whose `loadEnvelope` serves the CLASSIFIER's key file and
//  whose `saveEnvelope` is a no-op — the source pair is only ever read
//  (decision 11: a pair is NEVER rewritten; the vault road's fresh-local-
//  copy write is designed best-effort, so dropping it refuses nothing).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class LibraryOpenModel {
    enum Phase: Equatable {
        case classifying
        /// A worded refusal; `detail` carries quiet facts (unknown
        /// migrations, a reader's reason).
        case refused(String, detail: String?)
        /// A picked folder holding several stores (P-U1-3): offered,
        /// never guessed.
        case choosing([URL])
        /// The secret roads over the source pair.
        case unlock
        /// Everything known; the one deliberate press remains.
        case confirm
        case adopting
        case done
    }

    private(set) var phase: Phase = .classifying
    private(set) var busy = false
    var lastError: String?
    /// pre-13x 4a's precedent: the offline note after a submit whose
    /// vault read failed — never before one.
    private(set) var showsOfflineNote = false

    // The unlock step's facts (the faces render roads that exist — P-2).
    private(set) var passphraseOffered = false
    private(set) var recoveryOffered = false

    // The confirm step's facts.
    private(set) var willStepAside = false
    private(set) var sourceInICloudDrive = false
    private(set) var isPlaintextRoad = false

    /// What the flow settled on (set entering `.confirm`).
    private enum Road {
        case encrypted(store: URL, keyFile: URL, key: StoreKey)
        case plaintext(store: URL)
    }
    private var road: Road?

    private let bootstrap: AppBootstrap
    /// The adopted copy's "as of" day for the hold banner: the backup
    /// stamp where the name carries one, else the source's modification
    /// date.
    private var sourceAsOf: Date?

    init(bootstrap: AppBootstrap) {
        self.bootstrap = bootstrap
    }

    // MARK: - Step 1: classify

    func begin(picked: URL) {
        guard !busy else { return }
        busy = true
        phase = .classifying
        lastError = nil
        Task { [weak self] in
            let verdict = await Task.detached(priority: .userInitiated) {
                LibraryClassifier.classify(at: picked)
            }.value
            await self?.land(verdict)
        }
    }

    /// The chooser's pick (a folder holding several stores).
    func choose(_ store: URL) {
        busy = false
        begin(picked: store)
    }

    private func land(_ verdict: LibraryClassifier.Verdict) async {
        defer { busy = false }
        switch verdict {
        case .encryptedLibrary(let store, let keyFile),
             .snapshotPair(let store, let keyFile),
             .folderHoldingPair(let store, let keyFile):
            await beginUnlock(store: store, keyFile: keyFile)
        case .folderHoldingStores(let stores):
            phase = .choosing(stores)
        case .plaintextExport(let store), .plaintextLibrary(let store):
            road = .plaintext(store: store)
            isPlaintextRoad = true
            enterConfirm(source: store)
        case .bareStoreWithoutKeyFile:
            phase = .refused(LibraryOpenCopy.bareStoreRefusal, detail: nil)
        case .newerSchema(_, let unknown):
            phase = .refused(
                LibraryOpenCopy.newerSchemaRefusal,
                detail: unknown.isEmpty ? nil : unknown.joined(separator: " · "))
        case .notAVariorumStore:
            phase = .refused(LibraryOpenCopy.notAVariorumStoreRefusal, detail: nil)
        case .unreadable(_, let reason):
            phase = .refused(LibraryOpenCopy.unreadableRefusal, detail: reason)
        }
    }

    // MARK: - Step 2: the silent roads, then the typed ones

    /// The gate whose envelope reads serve the SOURCE pair (see the
    /// header's recorded override).
    private func sourceGate(keyFile: URL) -> StoreLaunchGate {
        var gate = bootstrap.gate
        gate.loadEnvelope = { _ in try StoreKeyEnvelope.load(at: keyFile) }
        gate.saveEnvelope = { _, _ in }
        return gate
    }

    private var pendingSource: (store: URL, keyFile: URL)?

    private func beginUnlock(store: URL, keyFile: URL) async {
        pendingSource = (store, keyFile)
        let scope = bootstrap.storeVariant.rawValue
        let gate = sourceGate(keyFile: keyFile)
        let guardSeam = bootstrap.gate.guardFor(scope)
        let opened: StoreKey? = await Task.detached(priority: .userInitiated) {
            () -> StoreKey? in
            guard let envelope = try? StoreKeyEnvelope.load(at: keyFile) else { return nil }
            // THE SECOND LOOK (ledger 14): the live custody serves a
            // same-key copy — the silent item first, no prompt.
            if let held = guardSeam.loadAuto(), envelope.belongs(to: held) {
                return held
            }
            // The Apple road (corner 33's Standard-silent arm): A from
            // this device's iCloud Keychain, the pair's copy under it.
            return StoreLobby.openWithAppleKey(
                scope: scope, storeURL: store, gate: gate).key
        }.value
        if let opened {
            await settle(key: opened, store: store, keyFile: keyFile)
            return
        }
        // The second look's GATED arm: one Touch ID ask serves a same-key
        // copy under Castle — only offered-by-doing when the item exists.
        if guardSeam.gatedItemExists() {
            if let gatedKey = await guardSeam.unlockGated(),
               let envelope = try? StoreKeyEnvelope.load(at: keyFile),
               envelope.belongs(to: gatedKey) {
                await settle(key: gatedKey, store: store, keyFile: keyFile)
                return
            }
        }
        // The typed roads (P-2: render the ones the pair carries).
        let envelope = try? StoreKeyEnvelope.load(at: keyFile)
        passphraseOffered = StoreLobby.passphraseRoadExists(envelope)
        recoveryOffered = StoreLobby.recoveryRoadExists(envelope)
        if passphraseOffered || recoveryOffered {
            phase = .unlock
        } else {
            // A pair whose key file carries no road at all (practically
            // unreachable — `locate` found it, so it decoded).
            phase = .refused(LibraryOpenCopy.bareStoreRefusal, detail: nil)
        }
    }

    func unlock(passphrase: String) async {
        guard !passphrase.isEmpty else { return }
        await runTypedRoad(.passphrase(passphrase))
    }

    func unlock(recoveryText: String) async {
        let trimmed = recoveryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        await runTypedRoad(.recoveryText(trimmed))
    }

    private func runTypedRoad(_ secret: StoreLobby.Secret) async {
        guard !busy, case .unlock = phase, let source = pendingSource else { return }
        busy = true
        lastError = nil
        showsOfflineNote = false
        defer { busy = false }
        let road = StoreLobby.envelopeRoad(
            storeURL: source.store,
            gate: sourceGate(keyFile: source.keyFile),
            session: bootstrap.protection.syncCustodySession,
            vaultRoad: bootstrap.lobbyVaultRoad)
        switch await road(secret, { _ in }) {
        case .success(let key):
            await settle(key: key, store: source.store, keyFile: source.keyFile)
        case .failure(let refusal):
            lastError = refusal.message
            showsOfflineNote = refusal.offline
        }
    }

    /// The post-unlock consult (the sync trace's item 5): the key in
    /// hand, the copy's schema read honestly — a newer copy refuses, a
    /// file the key does not open refuses as the wrong key.
    private func settle(key: StoreKey, store: URL, keyFile: URL) async {
        let verdict = await Task.detached(priority: .userInitiated) {
            LibraryClassifier.schemaVerdict(at: store, key: key)
        }.value
        switch verdict {
        case .current, .behindThisBuild:
            road = .encrypted(store: store, keyFile: keyFile, key: key)
            isPlaintextRoad = false
            enterConfirm(source: store)
        case .newer(let unknown):
            phase = .refused(
                LibraryOpenCopy.newerSchemaRefusal,
                detail: unknown.isEmpty ? nil : unknown.joined(separator: " · "))
        case .unreadable:
            phase = .refused(LibraryOpenCopy.wrongKeyRefusal, detail: nil)
        }
    }

    // MARK: - Step 3: confirm (say what will happen, then do exactly it)

    private func enterConfirm(source: URL) {
        sourceInICloudDrive = LibraryPlacementGuard.isInsideICloudDrive(source)
        let storeURL = bootstrap.liveStoreURL
        willStepAside = storeURL.map {
            FileManager.default.fileExists(atPath: $0.path)
        } ?? false
        sourceAsOf = BackupRestoreCandidates.backupDate(source)
            ?? (try? FileManager.default.attributesOfItem(atPath: source.path)[.modificationDate]
                as? Date)
        phase = .confirm
    }

    // MARK: - Step 4: adopt (the U1 brain + the collision rule's write +
    // the hold)

    func confirmAdoption() async {
        guard !busy, case .confirm = phase, let road else { return }
        guard let storeURL = bootstrap.liveStoreURL else {
            phase = .refused(LibraryOpenCopy.adoptionFailedLead, detail: "no store path resolved")
            return
        }
        busy = true
        phase = .adopting
        defer { busy = false }
        let scope = bootstrap.storeVariant.rawValue
        let gate = bootstrap.gate
        let asOf = sourceAsOf
        let work: @Sendable () throws -> Void
        let reopenKey: StoreKey?
        switch road {
        case .encrypted(let source, let keyFile, let key):
            reopenKey = key
            work = {
                let plan = LibraryAdoption.plan(
                    adopting: source, keyFile: keyFile, intoStoreAt: storeURL, now: Date())
                try LibraryAdoption.execute(plan)
                Self.landCustody(openingKey: key, scope: scope, storeURL: storeURL, gate: gate)
                try? LibraryRestoreHold.set(besideStore: storeURL, asOf: asOf, now: Date())
            }
        case .plaintext(let source):
            // Ledger 5's road: land → recreate the four local tables
            // BEFORE any open (§14.13 + ledger 22) → fresh key + identity
            // + Auto dials + the silent item (the library-missing mint's
            // proven recipe) — the route's open then encrypts it (the
            // shipped 13p migration).
            let freshKey = StoreKey.mint()
            reopenKey = freshKey
            work = {
                let plan = LibraryAdoption.plan(
                    adopting: source, keyFile: nil, intoStoreAt: storeURL, now: Date())
                try LibraryAdoption.execute(plan)
                try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: storeURL)
                let storeID = try StoreIdentity.establish(besideStore: storeURL, key: freshKey)
                gate.saveDials(ProtectionDials(), scope, storeID)
                // A refused save self-heals at the next launch (a
                // plaintext store's open mints into custody) — recorded,
                // not hidden; the reopen below carries the key either way.
                _ = gate.guardFor(scope).saveAuto(freshKey)
                try? LibraryRestoreHold.set(besideStore: storeURL, asOf: asOf, now: Date())
            }
        }
        do {
            if case .ready = bootstrap.state {
                try await bootstrap.adoptLibrary(reopeningWith: reopenKey, work: work)
            } else {
                let outcome: Result<Void, any Error> = await Task.detached(
                    priority: .userInitiated
                ) {
                    do {
                        try work()
                        return .success(())
                    } catch {
                        return .failure(error)
                    }
                }.value
                if case .failure(let error) = outcome { throw error }
                bootstrap.reopenAfterAdoption(unlockedKey: reopenKey)
            }
            phase = .done
        } catch {
            phase = .refused(
                LibraryOpenCopy.adoptionFailedLead, detail: String(describing: error))
        }
    }

    /// THE COLLISION RULE'S WRITE (U1 row 4's memo, applied): custody
    /// adopts the key that opens the now-live file, through the EXISTING
    /// doors, in the shape the ADOPTED store's effective gate dictates —
    /// the custody law's letter (auto ⇒ the silent item, gated gone;
    /// biometric ⇒ the gated item, silent gone; passphrase ⇒ neither).
    /// A held key readable silently composes the rule's verdict exactly;
    /// a GATED held item is unreadable without a prompt BY DESIGN, so a
    /// standing gated item composes as `adoptOpeningKey` — the write is
    /// the same promptless delete-then-add either way, idempotent when
    /// the keys agree. M, C and the device identity are untouched.
    nonisolated static func landCustody(
        openingKey: StoreKey, scope: String, storeURL: URL, gate: StoreLaunchGate
    ) {
        let guardSeam = gate.guardFor(scope)
        let openingFingerprint = StoreKeyEnvelope.fingerprint(of: openingKey)
        let verdict: CustodyCollisionRule.Verdict
        if let held = guardSeam.loadAuto() {
            verdict = CustodyCollisionRule.verdict(
                custodyHeldFingerprint: StoreKeyEnvelope.fingerprint(of: held),
                openingKeyFingerprint: openingFingerprint)
        } else if guardSeam.gatedItemExists() {
            verdict = .adoptOpeningKey
        } else {
            verdict = .mintFreshCustody
        }
        guard verdict != .alreadyAligned else { return }
        // The ADOPTED library's own shape: the key file just landed, so
        // the store id and posture read from it.
        let storeID: String?
        if case .known(let id) = StoreIdentity.resolve(besideStore: storeURL) {
            storeID = id
        } else {
            storeID = nil
        }
        switch gate.effectiveGate(scope: scope, storeID: storeID, storeURL: storeURL) {
        case .auto:
            _ = guardSeam.saveAuto(openingKey)
            _ = guardSeam.deleteGated()
        case .biometric:
            _ = guardSeam.saveGated(openingKey)
            _ = guardSeam.deleteAuto()
        case .passphrase:
            _ = guardSeam.deleteAuto()
            _ = guardSeam.deleteGated()
        }
    }
}
