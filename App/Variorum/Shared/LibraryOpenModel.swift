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

    /// R1-M5's promptless comparison: TRUE only when BOTH fingerprints
    /// are readable and DIFFER — the gated key provably cannot open the
    /// pair (custody is aligned with the live key file by the custody
    /// law; the file is its promptless proxy). Unknown on either side
    /// keeps the gated ask — the second look may still serve it.
    nonisolated static func pairIsProvablyForeign(
        pairKeyFile: URL, liveStoreURL: URL?
    ) -> Bool {
        guard let pair = try? StoreKeyEnvelope.load(at: pairKeyFile),
              let pairFingerprint = pair.keyFingerprint,
              let liveStoreURL,
              let live = try? StoreKeyEnvelope.loadCurrent(besideStore: liveStoreURL),
              let liveFingerprint = live.keyFingerprint
        else { return false }
        return pairFingerprint != liveFingerprint
    }

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
        // 13x F1 (ladder R1-M5): the fingerprints are compared PROMPTLESS
        // first — the pair's and the LIVE key file's are both on disk,
        // and the gated item can only ever serve a SAME-key copy; a
        // provably foreign pair skips the ask entirely (no spurious
        // Touch ID that then "fails" into the typed roads, on the exact
        // older-key-restore road this phase ships). Equal or UNKNOWN on
        // either side keeps the one ask.
        if guardSeam.gatedItemExists(),
           !Self.pairIsProvablyForeign(
               pairKeyFile: keyFile, liveStoreURL: bootstrap.liveStoreURL) {
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
    /// file the key does not open refuses as the wrong key, and a file
    /// unreadable for any OTHER reason says so with its reason (13x F3,
    /// ladder R3-1 constraint 3: never one sentence for both — the old
    /// single arm told a torn copy and a copy on a read-only volume that
    /// its key file "belongs to another copy").
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
        case .keyRejected:
            phase = .refused(LibraryOpenCopy.wrongKeyRefusal, detail: nil)
        case .unreadable(let reason):
            phase = .refused(LibraryOpenCopy.unreadableRefusal, detail: reason)
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
            // R1-M3: nothing has moved on this arm — the lead must not
            // point at recovery artifacts that do not exist.
            phase = .refused(
                LibraryOpenCopy.adoptionRefusedNothingMoved, detail: "no store path resolved")
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
                // 13x F1 (R1-M2): the hold rides INSIDE the adoption,
                // written before the move — a failed write refuses with
                // nothing moved; nothing ever lands un-held (the old
                // `try?` here swallowed exactly the silent catch-up
                // round 3 exists to prevent).
                try LibraryAdoption.execute(
                    plan, holding: .init(asOf: asOf, now: Date()))
                Self.landCustody(openingKey: key, scope: scope, storeURL: storeURL, gate: gate)
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
                // 13x F1 (R1-M2): the hold inside the adoption, before
                // the move (see the encrypted road's note) — the later
                // mint steps run on a landed copy that is ALREADY held.
                try LibraryAdoption.execute(
                    plan, holding: .init(asOf: asOf, now: Date()))
                try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: storeURL)
                let storeID = try StoreIdentity.establish(besideStore: storeURL, key: freshKey)
                gate.saveDials(ProtectionDials(), scope, storeID)
                // A refused save self-heals at the next launch (a
                // plaintext store's open mints into custody) — recorded,
                // not hidden; the reopen below carries the key either way.
                _ = gate.guardFor(scope).saveAuto(freshKey)
            }
        }
        do {
            if case .ready = bootstrap.state {
                try await bootstrap.adoptLibrary(reopeningWith: reopenKey, work: work)
            } else {
                // 13x F1 (ladder R1-M4): the standing lobby's Apple
                // re-probe stops BEFORE the work — `complete(key)` would
                // open the pool over the departing store mid-move.
                bootstrap.suspendLobbyForAdoption()
                // 13x F2 (ladder R2-1 — M4's residual): a probe that
                // completed BEFORE the press leaves the state at
                // `.opening` for the pool open's whole duration (routing
                // + SQLCipher open + migration), where the suspension
                // above is a no-op (no lobby stands) and the adoption's
                // wal gate reads a just-opened pool that has not written
                // yet as closed — the move-aside would relocate the
                // store out from under the in-flight open, which then
                // installs a session over the aside-moved inode (her
                // edits landing in Previous Libraries). So: AWAIT any
                // in-flight open to settle before deciding the road,
                // re-suspending each time it lands (a settle into a
                // lobby state is a FRESH instance whose probe is live).
                // A settle into ready takes the ready road, whose
                // teardown closes the pool it opened; a failure on the
                // detached road re-arms the probe (the lobby must not
                // wait dead behind the refusal).
                while bootstrap.opening != nil {
                    await bootstrap.awaitOpen()
                    bootstrap.suspendLobbyForAdoption()
                }
                if case .ready = bootstrap.state {
                    try await bootstrap.adoptLibrary(reopeningWith: reopenKey, work: work)
                } else if case .opening = bootstrap.state {
                    // `.opening` with NO open task is another ceremony's
                    // transient (adopt/re-key between their state write
                    // and their reopen) — unreachable from this sheet in
                    // practice, and REFUSED rather than raced: nothing
                    // has moved on this arm.
                    phase = .refused(
                        LibraryOpenCopy.adoptionRefusedNothingMoved,
                        detail: "the library is still opening")
                    return
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
                    if case .failure(let error) = outcome {
                        bootstrap.resumeLobbyAfterFailedAdoption()
                        throw error
                    }
                    bootstrap.reopenAfterAdoption(unlockedKey: reopenKey)
                }
            }
            phase = .done
        } catch {
            // 13x F1 (ladder R1-M3): the words are PER ARM — the catch
            // holds the typed error, and the lead's facts must be true
            // for the arm that threw (the old one lead claimed the
            // dated copy and the safety copy on arms where neither
            // exists).
            let (lead, detail) = Self.failureWording(for: error)
            phase = .refused(lead, detail: detail)
        }
    }

    /// R1-M3's map — which lead is TRUE for which failure arm:
    /// pre-move arms (nothing moved, no dated copy) · the mid-move arm
    /// (the safety copy + the aside home, named) · the landing arm and
    /// the unknown class (the old lead — its facts hold exactly there:
    /// by the landing, the dated copy and the safety copy both exist,
    /// and a post-work reopen failure is past the landing by
    /// construction).
    nonisolated static func failureWording(for error: any Error) -> (String, String?) {
        guard let adoption = error as? LibraryAdoption.AdoptionError else {
            return (LibraryOpenCopy.adoptionFailedLead, String(describing: error))
        }
        switch adoption {
        case .sourceMissing(let detail), .sourceKeyFileMissing(let detail),
             .sourceKeyFileUnreadable(let detail), .libraryLooksOpen(let detail),
             .safetyCopyFailed(let detail), .holdWriteFailed(let detail):
            return (LibraryOpenCopy.adoptionRefusedNothingMoved, detail)
        case .moveAsideFailed(let detail):
            return (LibraryOpenCopy.adoptionFailedMidMove, detail)
        case .landingFailed(let detail):
            return (LibraryOpenCopy.adoptionFailedLead, detail)
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
