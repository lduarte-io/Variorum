//
//  PostureSwitchTests.swift
//  VariorumTests
//
//  pre-13x batch 2b — ENTERING AND LEAVING CASTLE, the Mac half of §12's
//  pins, over the REAL runner composed on scratch leaves: a scratch KEYED
//  store (real SQLCipher, real key files beside it, the real export-and-swap
//  through a scratch binding), an EMULATED MIRROR (the fake server's push /
//  pull / reencrypt semantics + the key-proof fence, over the same emulated
//  `key_vault` the flow tests use — the vault's rotation seq claimed from the
//  mirror's one sequence, as the RPC does), the real `CorpusRotation` driver,
//  real custody material, in-memory Keychain backings. The core suite
//  (`CorpusRotationTests`, `StoreEncryptionMigrationTests`) proves the walk's
//  bytes and the file's crash matrix; THIS suite proves the composition — §4's
//  seven steps in order, the three seams' resumes, the offer over pre-switch
//  pairs only, leaving Castle, and decision 32 at the door.
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The emulated vault (the flow tests' scripted vault, with the mirror's seq)

/// The raw-JSON `key_vault` double the app suites keep, served through the
/// vault client's `load` seam; the ONE vault write road is the RPC
/// (`VaultRPCEmulation`). What this twin ADDS: a rotation that BEGINS claims
/// its seq from the mirror's sequence (the RPC's `nextval` of the rows'
/// sequence) so the walk's "below the seq" reads the rows it should.
final class EmulatedVault: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?
    private let claimRotationSeq: @Sendable () async -> Int64

    init(claimRotationSeq: @escaping @Sendable () async -> Int64) {
        self.claimRotationSeq = claimRotationSeq
    }

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return try await self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) async throws -> (Data, URLResponse) {
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        if request.url?.path.hasSuffix("/rest/v1/rpc/key_vault_update") == true {
            let (served, previousBefore, stored): (VaultRPCEmulation.Served?, String?, Data?) = lock.withLock {
                let before = row.flatMap {
                    ((try? JSONSerialization.jsonObject(with: $0)) as? [String: Any])?["corpus_previous_key_id"] as? String
                }
                let served = VaultRPCEmulation.serveUpdate(request, row: &row)
                return (served, before, row)
            }
            guard let served else { return response(404) }
            guard served.status == 200, previousBefore == nil, let current = stored,
                  var json = (try? JSONSerialization.jsonObject(with: current)) as? [String: Any],
                  json["corpus_previous_key_id"] is String
            else { return response(served.status, served.body) }
            // A rotation BEGAN in this call: its seq is the rows' sequence's next.
            let seq = await claimRotationSeq()
            json["rotation_started_seq"] = NSNumber(value: seq)
            let rewritten = try JSONSerialization.data(withJSONObject: json)
            lock.withLock { row = rewritten }
            let receipt: [String: Any] = ["revision": json["revision"] as Any, "rotation_started_seq": NSNumber(value: seq)]
            return response(200, try JSONSerialization.data(withJSONObject: receipt))
        }
        return lock.withLock {
            guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
                return response(404)
            }
            switch request.httpMethod {
            case "GET":
                guard let row else { return response(200, Data("[]".utf8)) }
                return response(200, Data("[".utf8) + row + Data("]".utf8))
            case "POST":
                if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                    return response(refusal.status, refusal.body)
                }
                guard row == nil else { return response(409, Data(#"{"code":"23505"}"#.utf8)) }
                row = request.httpBody
                return response(201)
            case "PATCH":
                return response(VaultRPCEmulation.patchRefused.status, VaultRPCEmulation.patchRefused.body)
            default:
                return response(405)
            }
        }
    }
}

// MARK: - The emulated mirror

/// The fake server's push / pull / reencrypt over one sequence, gated by the
/// vault-key-id fence and the key proof read from the EMULATED vault (the
/// RPC's order: fence, then proof). Records every `reencrypt` batch; one
/// scripted crash seam for the mid-walk resume.
actor EmulatedMirror: SyncTransport, SyncRotationTransport {
    struct Stored: Equatable {
        var row: SyncRow
        var seq: Int64
    }

    private var rows: [String: Stored] = [:]
    private(set) var seq: Int64 = 0
    private var vault: KeyVaultClient?
    private(set) var reencryptBatches: [[SyncRow]] = []
    private var crashNextReencrypt = false
    private(set) var pushes = 0
    private(set) var pulls = 0

    func attach(vault: KeyVaultClient) { self.vault = vault }
    func setCrashNextReencrypt(_ crash: Bool) { crashNextReencrypt = crash }
    func claimSeq() -> Int64 { seq += 1; return seq }
    func stored() -> [String: Stored] { rows }

    private func gate(activeKeyID: String, keyProof: String) async throws {
        guard let vault, let fetched = try await vault.fetchVault() else {
            throw SyncError.encryptionKeysReplaced
        }
        guard fetched.format.classKey(for: .corpus)?.keyID == activeKeyID else {
            throw SyncError.encryptionKeysReplaced
        }
        guard let presented = KeyProof.hash(ofWireToken: keyProof),
              presented == fetched.format.keyProofHash
        else { throw SyncError.keyProofRefused }
    }

    func push(_ batch: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncPushOutcome] {
        try await gate(activeKeyID: activeKeyID, keyProof: keyProof)
        pushes += 1
        return batch.map { incoming in
            let key = "\(incoming.table)/\(incoming.rowID)"
            let currentVersion = rows[key]?.row.syncVersion ?? 0
            guard incoming.syncVersion == currentVersion else {
                return .rejected(current: rows[key].map { SyncPulledRow(row: $0.row, serverSeq: $0.seq) })
            }
            seq += 1
            var accepted = incoming
            accepted.syncVersion = currentVersion + 1
            rows[key] = Stored(row: accepted, seq: seq)
            return .accepted(newVersion: accepted.syncVersion, serverSeq: seq)
        }
    }

    func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: String, deviceID: String?) async throws -> [SyncPulledRow] {
        try await gate(activeKeyID: activeKeyID, keyProof: keyProof)
        pulls += 1
        return Array(rows.values
            .filter { $0.seq > since }
            .sorted { $0.seq < $1.seq }
            .prefix(limit)
            .map { SyncPulledRow(row: $0.row, serverSeq: $0.seq) })
    }

    func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }

    func reencrypt(_ incomingRows: [SyncRow], activeKeyID: String, keyProof: String) async throws -> [SyncReencryptOutcome] {
        try await gate(activeKeyID: activeKeyID, keyProof: keyProof)
        if crashNextReencrypt {
            crashNextReencrypt = false
            throw URLError(.networkConnectionLost)
        }
        reencryptBatches.append(incomingRows)
        return incomingRows.map { incoming in
            let key = "\(incoming.table)/\(incoming.rowID)"
            guard let current = rows[key] else { return .skipped(currentVersion: nil) }
            guard current.row.syncVersion == incoming.syncVersion else {
                return .skipped(currentVersion: current.row.syncVersion)
            }
            seq += 1
            rows[key] = Stored(row: incoming, seq: seq)
            return .replaced(serverSeq: seq)
        }
    }
}

private struct FixedKeyProvider: SyncKeyProviding {
    let keys: SyncEncryptionKeys
    func currentKeys() throws -> SyncEncryptionKeys { keys }
    func deviceIdentity() throws -> String { "device-fixed-2b" }
}

// MARK: - The suite

@MainActor
@Suite("pre-13x 2b — entering and leaving Castle: the runner over a scratch keyed store + an emulated mirror", .serialized)
struct PostureSwitchTests {
    enum RekeyFault { case beforeWork, afterWork }

    /// What the scripted leaves saw.
    @MainActor
    final class Calls {
        var custodyTargets: [StoreAtOpenMode] = []
        var refuseNextCustody = false
        var rekeyFault: RekeyFault?
        var rekeys = 0
        var pauses = 0
        var resumes = 0
        var reconciles = 0
        let snapshotsTaken = LockIsolated(0)
        let listedAfterSnapshot = LockIsolated<Bool?>(nil)
        let deletedPairs = LockIsolated<[URL]>([])
        let log = LockIsolated<[String]>([])
    }

    @MainActor
    final class World {
        let dir: URL
        let storeURL: URL
        let backups: URL
        let oldKey: StoreKey
        let apple: AppleKey
        let binding: StoreBinding
        let view: AppDatabase
        let keyStore: DeviceKeyStore
        let vaultEmu: EmulatedVault?
        let vaultClient: KeyVaultClient?
        let mirror: EmulatedMirror?
        let guardBacking: InMemoryStoreKeyGuardBacking
        let appleBacking: InMemoryAppleKeyBacking
        let gate: StoreLaunchGate
        let defaults: UserDefaults
        let suiteName: String
        let calls = Calls()
        let biometry: Bool
        var keyInHand: StoreKey?
        var posture: Posture
        var alwaysAsk = false
        var oldMaterial: DeviceKeyMaterial?
        var seededTitles: [String: String] = [:]
        var titlesBeforeSwitch: [String: SyncValue] = [:]
        var runner: PostureSwitchRunner!
        var words: [String] = []

        init(dir: URL, storeURL: URL, backups: URL, oldKey: StoreKey, apple: AppleKey,
             binding: StoreBinding, view: AppDatabase, keyStore: DeviceKeyStore,
             vaultEmu: EmulatedVault?, vaultClient: KeyVaultClient?, mirror: EmulatedMirror?,
             guardBacking: InMemoryStoreKeyGuardBacking, appleBacking: InMemoryAppleKeyBacking,
             gate: StoreLaunchGate, defaults: UserDefaults, suiteName: String, biometry: Bool, posture: Posture) {
            self.dir = dir; self.storeURL = storeURL; self.backups = backups
            self.oldKey = oldKey; self.apple = apple; self.binding = binding; self.view = view
            self.keyStore = keyStore; self.vaultEmu = vaultEmu; self.vaultClient = vaultClient
            self.mirror = mirror; self.guardBacking = guardBacking; self.appleBacking = appleBacking
            self.gate = gate; self.defaults = defaults; self.suiteName = suiteName
            self.biometry = biometry; self.posture = posture
            self.keyInHand = oldKey
        }

        func tearDown() {
            binding.lock()
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: dir)
        }

        var oldKeyFileURL: URL {
            StoreKeyEnvelope.url(besideStore: storeURL, fingerprint: StoreKeyEnvelope.fingerprint(of: oldKey))
        }

        func keyFile(_ fingerprint: String) throws -> StoreKeyEnvelope {
            try #require(try StoreKeyEnvelope.load(at: StoreKeyEnvelope.url(besideStore: storeURL, fingerprint: fingerprint)))
        }

        func marker() async throws -> RotationMarker? {
            try await view.read { try RotationMarker.read($0) }
        }

        func vault() async throws -> KeyVaultClient.FetchedVault {
            let client = try #require(vaultClient)
            return try #require(try await client.fetchVault())
        }

        /// A pre-existing snapshot pair under the OLD key (the app's own,
        /// made before the switch) — the offer's subject.
        @discardableResult
        func addPreSwitchPair() throws -> URL {
            let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: oldKey))
            let url = backups.appendingPathComponent("variorum-backup-\(fp8)-0.sqlite")
            try Data("old snapshot bytes — never rewritten".utf8).write(to: url)
            try Data("old key file bytes".utf8).write(to: pairKeyFile(url))
            return url
        }

        nonisolated static func pairKeyFile(_ snapshot: URL) -> URL {
            snapshot.deletingPathExtension().appendingPathExtension("keys.json")
        }
        nonisolated func pairKeyFile(_ snapshot: URL) -> URL { Self.pairKeyFile(snapshot) }
    }

    nonisolated private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// The world: a scratch keyed store with three pushed notes, its key
    /// file beside it, custody + the vault when `enrolled`, the runner over
    /// scripted leaves. `standard: false` is a CASTLE world (the key file
    /// under P + M, the key gated; no Apple copy anywhere).
    private func makeWorld(enrolled: Bool = true, standard: Bool = true, biometry: Bool = true) async throws -> World {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-2b-switch-\(UUID().uuidString)", isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let oldKey = StoreKey.mint()
        let opened = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: oldKey))
        let (view, binding) = opened.asRebindable()
        let apple = AppleKey.mint()
        let appleBacking = InMemoryAppleKeyBacking(key: apple)
        let guardBacking = InMemoryStoreKeyGuardBacking(
            auto: standard ? oldKey : nil, gated: standard ? nil : oldKey,
            biometryAvailable: biometry, biometricSucceeds: true)
        let dials = ScriptedDialsBox(ProtectionDials())
        let gate = StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: guardBacking) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in })
        let suiteName = "io.lduarte.variorum.tests.2b.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let keyStore = DeviceKeyStore.inMemory()

        var vaultEmu: EmulatedVault?
        var vaultClient: KeyVaultClient?
        var mirror: EmulatedMirror?
        var material: DeviceKeyMaterial?
        if enrolled {
            let server = EmulatedMirror()
            let emu = EmulatedVault(claimRotationSeq: { await server.claimSeq() })
            let client = KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: URL(string: "https://vault.2b.invalid")!, apiKey: "publishable-test-key"),
                sessionProvider: StaticSessionProvider(
                    session: UserSession(accessToken: "token-2b", userID: "user-2b")),
                load: emu.load)
            await server.attach(vault: client)
            let minted = try await VaultEnrollment(client: client).setUp(passphrase: "sesame")
            #expect(keyStore.save(minted))
            material = minted
            vaultEmu = emu; vaultClient = client; mirror = server
        }

        // The key file beside the store (format 2, its own fingerprint name).
        var envelope = StoreKeyEnvelope(storeID: "store-2b-\(UUID().uuidString.prefix(8))")
        try envelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
        if standard {
            try envelope.appleBox(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        }
        if let material {
            try envelope.masterBox(key: oldKey, under: material.masterSymmetricKey)
        }
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let world = World(
            dir: dir, storeURL: storeURL, backups: backups, oldKey: oldKey, apple: apple,
            binding: binding, view: view, keyStore: keyStore, vaultEmu: vaultEmu,
            vaultClient: vaultClient, mirror: mirror, guardBacking: guardBacking,
            appleBacking: appleBacking, gate: gate, defaults: defaults, suiteName: suiteName, biometry: biometry,
            posture: standard ? .standard : .castle)
        world.oldMaterial = material
        world.words = try RecoveryPhrase.generate()

        // Three notes, pushed under the OLD corpus key.
        let stamp = "2026-09-05T00:00:00Z"
        for index in 0..<3 {
            let id = "note-\(index)-\(UUID().uuidString.prefix(6))"
            let title = "Castle note \(index) — \(UUID().uuidString.prefix(4))"
            world.seededTitles[id] = title
            try await view.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: [id, title, stamp, stamp])
            }
        }
        if enrolled, let mirror {
            let engine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: keyStore))
            try await withDependencies { $0.database = view } operation: {
                let report = try await engine.push()
                #expect(report.accepted >= 3, "the seed pushed")
            }
            for (key, stored) in await mirror.stored() where stored.row.table == "container" {
                world.titlesBeforeSwitch[key] = stored.row.columns["title"]
            }
        }
        world.runner = PostureSwitchRunner(leaves: leaves(for: world))
        return world
    }

    private func leaves(for world: World) -> PostureSwitchRunner.Leaves {
        let calls = world.calls
        let backups = world.backups
        let suiteName = world.suiteName
        let signedIn = world.vaultClient != nil
        return PostureSwitchRunner.Leaves(
            scope: "Variorum2b",
            storeURL: world.storeURL,
            database: world.view,
            gate: world.gate,
            keyStore: world.keyStore,
            keyProvider: DeviceKeySyncProvider(store: world.keyStore),
            vault: world.vaultClient,
            transport: world.mirror,
            signedIn: { signedIn },
            appleKeys: AppleKeyLeaves.inMemory(backing: world.appleBacking),
            libraryKeyInHand: { world.keyInHand },
            posture: { world.posture },
            alwaysAsk: { world.alwaysAsk },
            biometryAvailable: { world.biometry },
            moveCustody: { target in
                if calls.refuseNextCustody {
                    calls.refuseNextCustody = false
                    return .refused("scripted custody refusal")
                }
                calls.custodyTargets.append(target)
                world.posture = target == .auto ? .standard : .castle
                return .changed
            },
            rekeyLibrary: { old, new, work in
                if calls.rekeyFault == .beforeWork {
                    calls.rekeyFault = nil
                    throw URLError(.cancelled)
                }
                calls.rekeys += 1
                world.binding.lock()
                var failure: (any Error)?
                do { try work() } catch { failure = error }
                let opened = StoreEncryptionMigration.opens(world.storeURL, key: new) ? new : old
                try world.binding.adopt(try AppDatabase.openStore(at: world.storeURL, custody: .inMemory(initial: opened)))
                world.keyInHand = opened
                if let failure { throw failure }
                if calls.rekeyFault == .afterWork {
                    calls.rekeyFault = nil
                    throw URLError(.cancelled)
                }
            },
            pauseSync: { calls.pauses += 1 },
            resumeSync: { calls.resumes += 1 },
            takeSnapshot: {
                guard let key = world.keyInHand else { return nil }
                let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
                let n = calls.snapshotsTaken.withValue { $0 += 1; return $0 }
                let url = backups.appendingPathComponent("variorum-backup-\(fp8)-\(n).sqlite")
                try? FileManager.default.copyItem(at: world.storeURL, to: url)
                try? Data("fresh key file".utf8).write(to: World.pairKeyFile(url))
                return url
            },
            preSwitchSnapshots: { keep in
                calls.listedAfterSnapshot.setValue(calls.snapshotsTaken.value > 0)
                let entries = (try? FileManager.default.contentsOfDirectory(at: backups, includingPropertiesForKeys: nil)) ?? []
                return entries
                    .filter { $0.pathExtension == "sqlite" }
                    .filter { url in
                        let parts = url.deletingPathExtension().lastPathComponent.split(separator: "-")
                        return parts.count >= 3 && String(parts[2]) != keep
                    }
                    .sorted { $0.lastPathComponent < $1.lastPathComponent }
            },
            deleteSnapshotPairs: { urls in
                var removed = 0
                for url in urls {
                    try? FileManager.default.removeItem(at: World.pairKeyFile(url))
                    if (try? FileManager.default.removeItem(at: url)) != nil { removed += 1 }
                }
                calls.deletedPairs.withValue { $0.append(contentsOf: urls) }
                return removed
            },
            defaults: { UserDefaults(suiteName: suiteName)! },
            reconcile: { calls.reconciles += 1 },
            now: { Date(timeIntervalSince1970: 1_788_000_000) },
            log: { line in calls.log.withValue { $0.append(line) } })
    }

    /// The end state of a completed Standard → Castle switch (shared by the
    /// whole road and every resume).
    private func expectCastleEndState(_ world: World, _ outcome: PostureSwitchRunner.Outcome) async throws {
        #expect(outcome.entersCastle)
        // The library opens under the NEW key alone.
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey), "the library is under L′")
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the old L opens nothing")
        #expect(world.keyInHand == newKey, "the reopen adopted L′")
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "no Apple copy enters Castle")
        #expect(newFile.recovery != nil, "L′ under the words in hand")
        #expect(try newFile.unwrapKey(recoveryWords: world.words) == newKey)
        // A Standard-era key file + A: its L opens no page of the re-keyed library.
        let oldFile = try #require(try StoreKeyEnvelope.load(at: world.oldKeyFileURL), "the old key file stays beside old snapshots")
        let standardEraKey = try oldFile.unwrapKey(apple: world.apple.symmetricKey)
        #expect(standardEraKey == world.oldKey)
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: standardEraKey),
                "§12: a Standard-era copy of the key file + the Apple-held key opens no page")
        // Custody: Touch ID (biometry) or the passphrase; both items through the one move.
        #expect(world.calls.custodyTargets.last == (world.biometry ? .biometric : .passphrase))
        #expect(world.posture == .castle)
        // The marker is gone; the snapshot came BEFORE the offer's listing.
        #expect(try await world.marker() == nil)
        #expect(world.calls.snapshotsTaken.value >= 1)
        #expect(world.calls.listedAfterSnapshot.value == true, "the fresh pair is taken before anything is offered")
        #expect(world.calls.resumes >= 1 && world.calls.reconciles >= 1)
        if let material = outcome.material, let vaultClient = world.vaultClient {
            let vault = try await world.vault()
            #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil,
                    "the vault's previous key and seq cleared together")
            #expect(vault.format.masterWrappedByAppleHeld == nil && vault.format.appleKeyID == nil,
                    "no Apple-held copy under Castle")
            #expect(vault.format.classKey(for: .corpus)?.keyID == material.corpusKeyID)
            #expect(vault.format.keyProofHash == KeyProof.hash(master: material.masterSymmetricKey))
            #expect(material.rotation == nil, "custody carries no previous key after completion")
            #expect(world.keyStore.load()?.corpusKeyID == material.corpusKeyID)
            #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M′")
            _ = vaultClient
        }
    }

    // MARK: - §4 whole

    @Test func enteringCastleRotatesEverythingAndTheStandardEraKeysOpenNothing() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        let oldMaterial = try #require(world.oldMaterial)
        let oldPair = try world.addPreSwitchPair()
        let oldPairBytes = try Data(contentsOf: oldPair)
        MarkdownInsurance.setEnabled(true, in: world.defaults)
        let headBefore = await mirror.seq

        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        try await expectCastleEndState(world, outcome)
        let material = try #require(outcome.material)

        // Every row on the server was re-encrypted — exactly once, all of
        // them below the rotation seq, every ciphertext changed.
        let batches = await mirror.reencryptBatches
        let reencryptedIDs = Set(batches.flatMap { $0 }.map(\.rowID))
        #expect(outcome.reencrypted == batches.flatMap { $0 }.count)
        #expect(reencryptedIDs.isSuperset(of: world.seededTitles.keys), "the three notes were re-encrypted")
        let stored = await mirror.stored()
        for (key, before) in world.titlesBeforeSwitch {
            #expect(stored[key]?.row.columns["title"] != before, "\(key)'s title ciphertext changed")
            #expect((stored[key]?.seq ?? 0) > headBefore, "re-encrypted rows sit above the rotation seq")
        }
        // The OLD keys are refused at the fence (a push with something to
        // push, a pull); the NEW ones read every note.
        let oldEngine = SyncEngine(transport: mirror, keyProvider: FixedKeyProvider(keys: oldMaterial.syncKeys))
        try await world.view.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                arguments: ["late-note", "typed after the switch", "2026-09-05T01:00:00Z", "2026-09-05T01:00:00Z"])
        }
        try await withDependencies { $0.database = world.view } operation: {
            await #expect(throws: SyncError.encryptionKeysReplaced, "old-C pull refused") { _ = try await oldEngine.pull() }
            await #expect(throws: SyncError.encryptionKeysReplaced, "old-C push refused") { _ = try await oldEngine.push() }
        }
        let lateRows = await mirror.stored().keys.filter { $0.hasSuffix("/late-note") }
        #expect(lateRows.isEmpty, "nothing under the old keys reached the mirror")
        let followerURL = world.dir.appendingPathComponent("follower/variorum.sqlite")
        let follower = try AppDatabase.openStore(at: followerURL, custody: .inMemory(initial: .mint()))
        let followerEngine = SyncEngine(transport: mirror, keyProvider: FixedKeyProvider(keys: material.syncKeys))
        try await withDependencies { $0.database = follower } operation: {
            let report = try await followerEngine.pull()
            #expect(report.applied >= 3)
        }
        let titles = try await follower.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container")
                .reduce(into: [String: String]()) { acc, row in
                    let id: String = row["id"]
                    let title: String? = row["title"]
                    acc[id] = title
                }
        }
        for (id, title) in world.seededTitles {
            #expect(titles[id] == title, "a follower under the new keys reads \(id) back in the clear")
        }

        // The offer: the pre-switch pair listed, its bytes untouched, the
        // fresh pair not listed; the insurance OFF with the notice.
        #expect(outcome.preSwitchSnapshots == [oldPair])
        #expect(try Data(contentsOf: oldPair) == oldPairBytes, "no backup folder is ever rewritten")
        #expect(outcome.insuranceTurnedOff && !MarkdownInsurance.isEnabled(in: world.defaults))
        let fresh = try FileManager.default.contentsOfDirectory(at: world.backups, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sqlite" && $0 != oldPair }
        #expect(fresh.count == 1, "one fresh pair under the new key")
        #expect(world.runner.deletePreSwitchSnapshots(outcome) == 1)
        #expect(!FileManager.default.fileExists(atPath: oldPair.path))
        #expect(!FileManager.default.fileExists(atPath: world.pairKeyFile(oldPair).path), "the pair goes together")
        #expect(FileManager.default.fileExists(atPath: fresh[0].path), "the fresh pair survives the offer")
        #expect(world.calls.pauses == 1)
    }

    @Test func aLocalOnlyLibraryTakesStepsFourToSevenOnlyAndItsResumeNeedsThePassphrase() async throws {
        let world = try await makeWorld(enrolled: false, biometry: false)
        defer { world.tearDown() }
        world.calls.rekeyFault = .beforeWork
        await #expect(throws: URLError.self) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(try await world.marker()?.step == .rekeyLibrary)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "before the swap the file is under L")
        // No master copy in a local-only key file: the resume asks for the passphrase.
        await #expect(throws: PostureSwitchError.passphraseRequired) {
            _ = try await world.runner.resume(passphrase: nil)
        }
        let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
        try await expectCastleEndState(world, outcome)
        #expect(outcome.material == nil && outcome.reencrypted == 0)
        #expect(world.calls.custodyTargets.last == .passphrase, "no biometry ⇒ Always ask")
        #expect(world.calls.pauses == 0, "no sync to pause")
    }

    // MARK: - The three seams

    @Test func aCrashAtEachOfTheThreeSeamsResumesToCompletion() async throws {
        // Seam A — mid re-encryption: the marker at `.reencrypt`, custody
        // carrying the previous key, the vault mid-rotation, the file under L.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let mirror = try #require(world.mirror)
            await mirror.setCrashNextReencrypt(true)
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .reencrypt)
            #expect(world.keyStore.load()?.rotation != nil, "custody holds M′ + the previous key")
            #expect(try await world.vault().format.previousCorpusKey != nil)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
            // A second start refuses while the marker stands (decision 32 on this device).
            await #expect(throws: PostureSwitchError.switchInProgress(.reencrypt)) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            try await expectCastleEndState(world, outcome)
            let batches = await mirror.reencryptBatches
            #expect(Set(batches.flatMap { $0 }.map(\.rowID)).isSuperset(of: world.seededTitles.keys),
                    "the walk finished after the crash")
        }
        // Seam B — after the export, before the swap: the new key file
        // written, the file still under L, the marker at `.rekeyLibrary`.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.calls.rekeyFault = .beforeWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .rekeyLibrary)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
            let newFingerprint = try #require(marker.newKeyFingerprint)
            #expect(try world.keyFile(newFingerprint).master != nil, "the new key file came first")
            // The master copy under M′ opens L′ — no passphrase needed to resume.
            let outcome = try await world.runner.resume(passphrase: nil)
            try await expectCastleEndState(world, outcome)
        }
        // Seam B′ — after the swap, before the marker advanced: the file
        // already under L′; the resume must NOT swap again.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.calls.rekeyFault = .afterWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .rekeyLibrary)
            #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the swap landed")
            let rekeysBefore = world.calls.rekeys
            let outcome = try await world.runner.resume(passphrase: nil)
            try await expectCastleEndState(world, outcome)
            #expect(world.calls.rekeys == rekeysBefore, "a file already under L′ is never exported again")
        }
        // Seam C — between the swap and custody: the custody move refused
        // once; the marker at `.custody`.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.calls.refuseNextCustody = true
            await #expect(throws: PostureSwitchError.custodyRefused("scripted custody refusal")) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .custody)
            #expect(world.calls.custodyTargets.isEmpty)
            let outcome = try await world.runner.resume(passphrase: nil)
            try await expectCastleEndState(world, outcome)
            #expect(world.calls.custodyTargets == [.biometric])
        }
    }

    // MARK: - Decision 32 at the door

    @Test func aRotationStillFinishingOnAnotherDeviceRefusesAtTheDoorAndChangesNothing() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let oldMaterial = try #require(world.oldMaterial)
        // "Another device" began a rotation and has not finished.
        let secrets = try RotationSecrets.derive(passphrase: "sesame", recoveryWords: nil, kdf: fastKDF())
        let begun = try await CorpusRotation.begin(client: client, current: oldMaterial, secrets: secrets, appleHeldCopy: nil)
        let vaultBefore = try await world.vault()
        #expect(vaultBefore.format.previousCorpusKey != nil)

        // THIS device, still on the old keys: the fence refuses the round
        // first (the CF-16 sentence — follow before anything else).
        await #expect(throws: SyncError.encryptionKeysReplaced) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        // This device FOLLOWED (§14.39 — the mid-rotation material) and asks
        // for a switch of its own: decision 32 refuses at the door.
        let following = try CorpusRotation.materialFollowing(vaultBefore.format, master: begun.material.masterSymmetricKey)
        #expect(following.rotation != nil)
        #expect(world.keyStore.save(following))
        let facts = try await world.runner.checkDoor()
        #expect(facts.enrolled && facts.rotationInProgress, "the door check sees the rotation")
        #expect(facts.vaultUpdatedAt != nil, "the vault's day rides the sentence")
        await #expect(throws: CorpusRotationError.rotationInProgress(previousKeyID: oldMaterial.corpusKeyID)) {
            _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        #expect(try await world.marker() == nil, "the marker never landed")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "nothing changed")
        #expect(try await world.vault().revision == vaultBefore.revision, "no vault write")
        #expect(world.calls.custodyTargets.isEmpty)

        // The ceremony: the door refuses with copy §4's sentence BEFORE any screen asks.
        let controller = makeController(for: world)
        let model = PostureSwitchModel(mode: .enter, runner: world.runner, controller: controller, vaultTie: nil)
        await model.start()
        let expected = ProtectionCopy.rotationStillFinishing(
            device: "another device", day: EncryptionView.displayDate(facts.vaultUpdatedAt) ?? "an earlier day")
        #expect(model.phase == .failed(expected))
    }

    // MARK: - Leaving Castle

    @Test func leavingCastleAddsTheAppleHeldCopiesAndMovesCustodySilentRotatingNothing() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        let material = try #require(world.oldMaterial)
        let corpusBefore = try await world.vault().format.classKey(for: .corpus)?.keyID
        let storedBefore = await mirror.stored()

        try await world.runner.leaveCastle()

        let vault = try await world.vault()
        #expect(vault.format.appleKeyID == world.apple.id)
        #expect(try vault.format.unwrapMaster(withAppleKey: world.apple.symmetricKey).withUnsafeBytes { Data($0) } == material.masterKey,
                "M under A in the vault")
        #expect(vault.format.classKey(for: .corpus)?.keyID == corpusBefore, "nothing rotated")
        #expect(vault.format.previousCorpusKey == nil)
        let keyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(keyFile.appleKeyID == world.apple.id)
        #expect(try keyFile.unwrapKey(apple: world.apple.symmetricKey) == world.oldKey, "the key file's Apple copy of L")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the library key is unchanged")
        #expect(world.calls.custodyTargets == [.auto], "custody gated → plain, both items, through the one move")
        #expect(world.posture == .standard)
        let batchesAfter = await mirror.reencryptBatches
        let storedAfter = await mirror.stored()
        #expect(batchesAfter.isEmpty && storedAfter == storedBefore, "the mirror untouched")
        #expect(try await world.marker() == nil, "no marker for a re-wrap")
    }

    @Test func leavingCastleRefusesUnderStandard() async throws {
        let world = try await makeWorld(enrolled: false)
        defer { world.tearDown() }
        await #expect(throws: PostureSwitchError.wrongPosture(.standard)) {
            try await world.runner.leaveCastle()
        }
    }

    // MARK: - The ceremony's brain (copy §2b in order)

    private func makeController(for world: World) -> ProtectionController {
        let syncLeaves = RecordingSyncLeaves(
            plain: SyncCustodyRecord(deviceID: "device-2b", material: world.oldMaterial))
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum2b", storeURL: world.storeURL, gate: world.gate,
            isRealVariant: true,
            makeKDF: { self.fastKDF() },
            storeID: { (try? StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))?.storeID },
            syncCustodyLeaves: { _ in syncLeaves.leaves },
            syncCustodySession: SyncCustodySession()))
        controller.refreshEnvelopeFacts()
        return controller
    }

    @Test func theCeremonyWalksTheCopysOrderRefusingAWrongPassphraseAgainstTheVaultAndAWrongReEntry() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        try world.addPreSwitchPair()
        let controller = makeController(for: world)
        #expect(controller.hasPassphraseWrap, "the world's key file carries a passphrase wrap — screen 2 is skipped")
        var vaultChecks: [String] = []
        let tie = VaultTie(
            hasRecoveryWrap: false,
            verifyPassphrase: { typed in
                vaultChecks.append(typed)
                return typed == "sesame" ? .match : .mismatch("not the account's")
            },
            verifyRecoveryWords: { _ in .couldNotCheck("unused") })
        let model = PostureSwitchModel(mode: .enter, runner: world.runner, controller: controller, vaultTie: tie)

        await model.start()
        #expect(model.phase == .explain)
        model.continueFromExplain()
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("no words anywhere ⇒ fresh words are shown once: \(model.phase)")
            return
        }
        #expect(words.count == 12)
        model.acknowledgeWordsWritten()
        #expect(model.phase == .wordsConfirm(words))
        model.confirmWords(words.reversed().joined(separator: " "))
        #expect(model.lastError == ProtectionCopy.wordsMismatch, "a wrong re-entry is refused")
        #expect(model.phase == .wordsConfirm(words))
        model.confirmWords(words.joined(separator: " "))
        #expect(model.phase == .floor(needsPassphrase: true), "the passphrase was not just set ⇒ typed at the floor")

        await model.enterCastle(passphrase: "sesame", acknowledged: false)
        #expect(model.lastError == ProtectionCopy.floorCheckbox, "the floor must be read")
        await model.enterCastle(passphrase: "not-the-passphrase", acknowledged: true)
        #expect(model.lastError == ProtectionCopy.passphraseNotTheLibrarys, "checked against the VAULT's copy")
        #expect(vaultChecks == ["not-the-passphrase"])
        #expect(model.phase == .floor(needsPassphrase: true))
        #expect(try await world.marker() == nil, "nothing ran")

        await model.enterCastle(passphrase: "sesame", acknowledged: true)
        #expect(vaultChecks == ["not-the-passphrase", "sesame"])
        guard case .done(let insuranceOff, let hasOffer) = model.phase else {
            Issue.record("expected done, got \(model.phase)")
            return
        }
        #expect(!insuranceOff && hasOffer)
        #expect(!controller.switchInProgress)
        let outcome = try #require(model.outcome)
        world.words = words  // the ceremony's own words, not the world's
        try await expectCastleEndState(world, outcome)
        #expect(try world.keyFile(outcome.newKeyFingerprint).recovery != nil, "L′ under the confirmed words")
        model.continueFromDone()
        #expect(model.phase == .offer)
        model.keepOldBackups()
        #expect(model.phase == .closed)
        #expect(world.calls.deletedPairs.value.isEmpty, "Keep Them deletes nothing")
    }
}
