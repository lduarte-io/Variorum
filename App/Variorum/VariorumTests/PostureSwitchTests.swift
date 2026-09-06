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
    /// pre-13x 2c (the drain bound): a LOCAL write landing DURING the round
    /// — fired from inside the pull, the mid-round moment — for this many
    /// pulls (`Int.max` = a writer that never stops).
    private var onPull: (@Sendable () async throws -> Void)?
    private var pullsToFire = 0

    func attach(vault: KeyVaultClient) { self.vault = vault }
    func setCrashNextReencrypt(_ crash: Bool) { crashNextReencrypt = crash }
    func setOnPull(times: Int, _ hook: @escaping @Sendable () async throws -> Void) {
        onPull = hook
        pullsToFire = times
    }
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
        if pullsToFire > 0, let onPull {
            if pullsToFire != Int.max { pullsToFire -= 1 }
            try await onPull()
        }
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
    /// pre-13x 2c: `sharing` builds a SIBLING device — its own scratch store,
    /// key file, custody and Keychain backings, on the SAME mirror, the same
    /// vault and the same account (the old material saved into its custody,
    /// no second setup) — the §7 choreography's second device.
    private func makeWorld(
        enrolled: Bool = true, standard: Bool = true, biometry: Bool = true, sharing: World? = nil
    ) async throws -> World {
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
        if let sharing {
            vaultEmu = sharing.vaultEmu; vaultClient = sharing.vaultClient; mirror = sharing.mirror
            material = sharing.oldMaterial
            if let material { #expect(keyStore.save(material)) }
        } else if enrolled {
            let server = EmulatedMirror()
            let emu = EmulatedVault(claimRotationSeq: { await server.claimSeq() })
            let client = KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: URL(string: "https://vault.2b.invalid")!, apiKey: "publishable-test-key", deviceName: "test device"),
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

    private func leaves(for world: World, faultAt: PostureSwitchRunner.FaultPoint? = nil, keyStore: DeviceKeyStore? = nil) -> PostureSwitchRunner.Leaves {
        let calls = world.calls
        let backups = world.backups
        let suiteName = world.suiteName
        let signedIn = world.vaultClient != nil
        return PostureSwitchRunner.Leaves(
            scope: "Variorum2b",
            storeURL: world.storeURL,
            database: world.view,
            gate: world.gate,
            keyStore: keyStore ?? world.keyStore,
            keyProvider: DeviceKeySyncProvider(store: keyStore ?? world.keyStore),
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
            log: { line in calls.log.withValue { $0.append(line) } },
            injectFault: { point in
                if point == faultAt { throw PostureSwitchError.injectedFault(point) }
            })
    }

    /// A world's runner re-composed with ONE scripted fault (2c.1b).
    private func arm(_ world: World, faultAt: PostureSwitchRunner.FaultPoint?) {
        world.runner = PostureSwitchRunner(leaves: leaves(for: world, faultAt: faultAt))
    }

    /// Seed `count` extra notes locally (unpushed) — the outbox's backlog.
    private func seedBacklog(_ world: World, count: Int, tag: String) async throws {
        try await world.view.write { db in
            for index in 0..<count {
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: ["\(tag)-\(index)", "\(tag) \(index)", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
            }
        }
    }

    private func outboxCount(_ world: World) async throws -> Int {
        try await world.view.read { db in try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0 }
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

    // MARK: - pre-13x 2c.1a: THE DRAIN BOUND (the 2b adjudication's item 2)

    /// Step 1 pushes until the outbox is EMPTY — at most three rounds — then
    /// refuses with the count. ONE engine push already drains a whole quiet
    /// outbox (every chunk of every row; the "1,000 rows per push" reading
    /// in 2b's question was wrong about the engine), and every reject the
    /// merge matrix answers clears or re-pushes within that same push — so
    /// what a round cannot finish is a LOCAL WRITE LANDING DURING IT (an
    /// autosave racing the round). One such keystroke is drained by the
    /// second round; a writer that never stops meets the bound: the third
    /// round ends with the honest refusal and the count, nothing begun.
    /// RED ON OLD (2b's single push then refuse): the one-keystroke world
    /// throws `outboxNotEmpty(pending: 1)` after its one push + pull.
    @Test func stepOneDrainsTheOutboxBoundedAtThreeRounds() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let mirror = try #require(world.mirror)
        // A large quiet backlog beside it — proof that size alone never
        // needs a second round.
        try await seedBacklog(world, count: 1_250, tag: "backlog")
        // ONE keystroke lands mid-round (during the first pull).
        let view = world.view
        await mirror.setOnPull(times: 1) {
            try await view.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: ["typed-mid-round", "typed mid-round", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
            }
        }
        let pushesBefore = await mirror.pushes
        let outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        #expect(outcome.entersCastle)
        #expect(try await outboxCount(world) == 0, "drained before the vault write — the second round landed the mid-round row")
        #expect(await mirror.pushes - pushesBefore >= 2, "a second push round ran")
        let stored = await mirror.stored()
        #expect(stored.keys.filter { $0.hasPrefix("container/backlog-") }.count == 1_250, "the whole backlog reached the mirror in one push")
        #expect(stored["container/typed-mid-round"] != nil, "the mid-round row reached the mirror before the vault write")

        // THE BOUND: a writer that never stops — three rounds, then the
        // refusal names what is left; nothing began.
        let stuck = try await makeWorld()
        defer { stuck.tearDown() }
        let stuckMirror = try #require(stuck.mirror)
        let stuckView = stuck.view
        await stuckMirror.setOnPull(times: Int.max) {
            try await stuckView.write { db in
                try db.execute(
                    sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                    arguments: [UUID().uuidString, "still typing", "2026-09-05T00:00:00Z", "2026-09-05T00:00:00Z"])
            }
        }
        // (`pullToHead` reads two windows per round — the rows, then the
        // empty tail — so the writer lands two rows a round; the COUNT is
        // whatever is left, named honestly.)
        await #expect("three rounds, then the count") {
            _ = try await stuck.runner.enterCastle(passphrase: "sesame", recoveryWords: stuck.words)
        } throws: { error in
            if case SyncError.outboxNotEmpty(let pending) = error { return pending >= 1 }
            return false
        }
        #expect(try await stuck.marker() == nil, "nothing began")
        #expect(try await stuck.vault().format.previousCorpusKey == nil, "no vault write")
        #expect(StoreEncryptionMigration.opens(stuck.storeURL, key: stuck.oldKey), "nothing re-keyed")
    }

    // MARK: - pre-13x 2c.1b: THE TWO RESUME ARMS (the 2b adjudication's item 6)

    /// Through the fault leaf: (a) the vault write NEVER LANDED — the
    /// marker at `.vaultWrite`, the vault untouched — so the resume says
    /// `restartRequired`, clears the marker and re-keys nothing; (b) the
    /// write LANDED but custody did not — the resume asks for the
    /// passphrase, then picks M′ up from the vault (the follow's own arm),
    /// finishes the walk and completes the switch. RED ON OLD: (a) with the
    /// never-landed branch gone the resume "completes" a rotation that never
    /// began; (b) with the follow-by-passphrase branch gone the resume runs
    /// the walk on the OLD material and meets `staleMaster`.
    @Test func theResumeRestartsWhenTheVaultWriteNeverLandedAndFollowsByThePassphraseWhenCustodyDidNot() async throws {
        // (a) before the vault write
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            arm(world, faultAt: .beforeVaultWrite)
            let revisionBefore = try await world.vault().revision
            await #expect(throws: PostureSwitchError.injectedFault(.beforeVaultWrite)) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .vaultWrite)
            #expect(try await world.vault().revision == revisionBefore, "the write never landed")
            arm(world, faultAt: nil)
            await #expect(throws: PostureSwitchError.restartRequired) {
                _ = try await world.runner.resume(passphrase: nil)
            }
            #expect(try await world.marker() == nil, "the marker is cleared — the ceremony starts over")
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "nothing was re-keyed")
            #expect(world.calls.rekeys == 0 && world.calls.custodyTargets.isEmpty)
            #expect(world.keyStore.load()?.corpusKeyID == world.oldMaterial?.corpusKeyID, "custody untouched")
        }
        // (b) after the vault write, before custody
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            let oldMaterial = try #require(world.oldMaterial)
            arm(world, faultAt: .afterVaultWriteBeforeCustody)
            await #expect(throws: PostureSwitchError.injectedFault(.afterVaultWriteBeforeCustody)) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .vaultWrite)
            let vault = try await world.vault()
            #expect(vault.format.previousCorpusKey != nil, "the write landed: a rotation is open on the server")
            #expect(vault.format.classKey(for: .corpus)?.keyID != oldMaterial.corpusKeyID)
            #expect(world.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody still holds the OLD keys")
            arm(world, faultAt: nil)
            await #expect(throws: PostureSwitchError.passphraseRequired, "M′ is on the server only — the passphrase is asked") {
                _ = try await world.runner.resume(passphrase: nil)
            }
            let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
            try await expectCastleEndState(world, outcome)
            #expect(outcome.reencrypted >= 3, "the walk ran after the follow-by-passphrase picked M′ up")
        }
    }

    // MARK: - pre-13x 2c.1: THE FOLLOW (§7)

    /// The acting device is KILLED after the vault write with every row
    /// still under the previous key; a STANDARD sibling — opened as it did,
    /// its old-key round refused at the fence — follows by the passphrase
    /// ONCE: M′ from the vault, C′ + the previous key under M′, custody
    /// replaced, the walk FINISHED and the previous key cleared at head,
    /// its own library re-keyed (L′ under P and M′, no Apple copy, NO W
    /// copy — the words were not typed), custody behind Touch ID, the offer
    /// listed (it was Standard-shaped); then it pulls to an IDENTICAL store
    /// (every note in the clear) and its pending row pushes under C′ with
    /// CAS. A wrong word lands nothing. Then the killed acting device
    /// resumes by its passphrase and finds nothing left to re-encrypt.
    @Test func aStandardSiblingFollowsByThePassphraseFinishesTheRotationAndPullsToAnIdenticalStore() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let mirror = try #require(acting.mirror)
        let oldMaterial = try #require(acting.oldMaterial)
        try sibling.addPreSwitchPair()
        // The sibling's own three notes reach the mirror under the OLD key.
        let siblingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.push()
            _ = try await siblingEngine.pull()
        }
        // The acting device dies after the vault write.
        arm(acting, faultAt: .afterVaultWriteBeforeCustody)
        await #expect(throws: PostureSwitchError.injectedFault(.afterVaultWriteBeforeCustody)) {
            _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        }
        let open = try await acting.vault()
        #expect(open.format.previousCorpusKey != nil && open.format.rotationStartedSeq != nil, "rows still under the previous key")

        // The un-followed sibling: a pending row, a refused round, nothing lost.
        try await seedBacklog(sibling, count: 1, tag: "typed-before-following")
        await #expect(throws: SyncError.encryptionKeysReplaced, "the fence refuses the old keys first") {
            try await withDependencies { $0.database = sibling.view } operation: { _ = try await siblingEngine.pull() }
        }
        #expect(try await outboxCount(sibling) >= 1, "the edit queues in the outbox")
        // M′ lands only after P or W: a wrong word writes nothing.
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await sibling.runner.follow(passphrase: "not-the-passphrase", recoveryWords: nil)
        }
        #expect(try await sibling.marker() == nil)
        #expect(sibling.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody unchanged")
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey))

        // THE FOLLOW, by the passphrase once.
        let outcome = try await sibling.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle)
        let material = try #require(outcome.material)
        let vault = try await sibling.vault()
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil,
                "the FOLLOWER finished the rotation and cleared the previous key + the seq at head")
        #expect(material.corpusKeyID == vault.format.classKey(for: .corpus)?.keyID && material.rotation == nil)
        #expect(sibling.keyStore.load()?.corpusKeyID == material.corpusKeyID, "custody REPLACED")
        #expect(outcome.reencrypted >= 6, "the follower re-encrypted the acting device's rows and its own")
        let newFile = try sibling.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: newKey), "the sibling's library is under L′")
        #expect(!StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey))
        #expect(newFile.passphrase?.kdf == vault.format.kdf, "L′ under P with the VAULT's descriptor — the lobby derives once")
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M′")
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "no Apple copy enters Castle")
        #expect(newFile.recovery == nil, "the words were not typed — the W copy lands when they are")
        #expect(sibling.calls.custodyTargets.last == .biometric && sibling.posture == .castle)
        #expect(outcome.preSwitchSnapshots.count == 1, "the offer: it was Standard-shaped, so its old pairs open through the Apple account")
        #expect(sibling.calls.resumes >= 1, "sync resumed — the pull from the own cursor")
        #expect(try await sibling.marker() == nil)

        // The pull from the own cursor: every note in the clear, the
        // pending row pushed under C′, and the acting device reads it back.
        try await withDependencies { $0.database = sibling.view } operation: {
            _ = try await siblingEngine.pull()
            let report = try await siblingEngine.push()
            #expect(report.accepted >= 1, "the pending row pushes under C′ with CAS")
        }
        #expect(try await outboxCount(sibling) == 0)
        let titles = try await sibling.view.read { db in
            try Row.fetchAll(db, sql: "SELECT id, title FROM container").reduce(into: [String: String]()) { acc, row in
                let id: String = row["id"]; let title: String? = row["title"]; acc[id] = title
            }
        }
        for (id, title) in acting.seededTitles {
            #expect(titles[id] == title, "the follower reads the acting device's \(id) in the clear")
        }
        // The killed acting device resumes by its passphrase: nothing is
        // left below the seq — the follower finished it — and its own
        // re-key completes.
        arm(acting, faultAt: nil)
        let resumed = try await acting.runner.resume(passphrase: "sesame", recoveryWords: acting.words)
        try await expectCastleEndState(acting, resumed)
        #expect(resumed.reencrypted == 0, "the follower had already finished the walk")
        let actingEngine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: acting.keyStore))
        try await withDependencies { $0.database = acting.view } operation: { _ = try await actingEngine.pull() }
        let seen = try await acting.view.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'typed-before-following-0'")
        }
        #expect(seen == "typed-before-following 0", "the sibling's pending row reached the acting device in the clear")
    }

    /// pre-13x 2d (decision 35) — THE NO-ROTATION FOLLOW over the real
    /// runner: the account is Castle-shaped (the 2b world's vault carries no
    /// Apple-held copy — the 2c drill record's own finding) while this
    /// library is Standard-shaped (an `apple` copy in its key file, custody
    /// silent) and the keys are UNCHANGED. The passphrase, verified against
    /// the vault's copy (a wrong word writes nothing), takes the road: no
    /// new master, no marker at `.reencrypt`, no vault write, nothing
    /// re-encrypted — custody's keys stay; the library is RE-KEYED (a new
    /// L′), custody moves behind the gate, a NEW key file lands under the
    /// new fingerprint (L′ under P with the VAULT's descriptor + under M;
    /// NO `apple` copy; the vault's descriptor and corpus key id recorded),
    /// and the OLD key file leaves the live folder — A opens no page of the
    /// re-keyed library. RED ON OLD: the follow walked the rotation road
    /// against unchanged keys (a redundant custody replacement and a
    /// `.reencrypt` marker), and the old Standard-era key file stayed
    /// beside the Castle library.
    @Test func theMismatchFollowReKeysTheLibraryMovesCustodyBehindTheGateAndRemovesTheOldKeyFile() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let material = try #require(world.oldMaterial)
        let mirror = try #require(world.mirror)
        let vaultBefore = try await world.vault()
        #expect(vaultBefore.format.masterWrappedByAppleHeld == nil, "the account is Castle-shaped")
        let oldFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(oldFile.apple != nil && world.guardBacking.auto == world.oldKey, "this library is Standard-shaped")
        let oldURL = world.oldKeyFileURL
        #expect(FileManager.default.fileExists(atPath: oldURL.path))

        // The runner over a COUNTING custody store: the no-rotation road
        // never re-saves custody (the rotation road saves twice).
        let saves = LockIsolated(0)
        let store = world.keyStore
        let counting = DeviceKeyStore(
            load: { store.load() },
            save: { saves.withValue { $0 += 1 }; return store.save($0) },
            clear: { store.clear() },
            deviceID: { store.deviceID() })
        let runner = PostureSwitchRunner(leaves: leaves(for: world, keyStore: counting))

        // A wrong word writes nothing.
        await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
            _ = try await runner.follow(passphrase: "not-the-passphrase", recoveryWords: nil)
        }
        #expect(world.calls.rekeys == 0 && FileManager.default.fileExists(atPath: oldURL.path))
        #expect(try await world.marker() == nil)

        // The wrap-less legacy stub beside the library (her phone's 79 B file).
        let stubURL = StoreKeyEnvelope.legacyURL(besideStore: world.storeURL)
        try Data("{\n  \"formatVersion\" : 1,\n  \"storeID\" : \"\(oldFile.storeID)\"\n}".utf8).write(to: stubURL)

        let outcome = try await runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle && outcome.reencrypted == 0)
        #expect(saves.value == 0, "custody never re-saved — the new-master half was skipped")
        #expect(!FileManager.default.fileExists(atPath: stubURL.path), "the wrap-less legacy stub removed too (2d.4, ruling 5)")
        let held = try #require(world.keyStore.load())
        #expect(held.corpusKeyID == material.corpusKeyID && held.masterKey == material.masterKey,
                "custody's keys UNCHANGED — no rotation")
        #expect(try await world.vault().revision == vaultBefore.revision, "no vault write")
        #expect(await mirror.reencryptBatches.isEmpty, "nothing re-encrypted")
        #expect(world.calls.rekeys == 1, "the library RE-KEYED")
        #expect(world.calls.custodyTargets == [.biometric] && world.posture == .castle, "custody behind the gate")
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey), "the library is under L′")
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
        #expect(newFile.apple == nil && newFile.appleKeyID == nil, "NO Apple copy")
        #expect(newFile.passphrase?.kdf == vaultBefore.format.kdf, "L′ under P with the VAULT's descriptor")
        #expect(newFile.vaultKDF == vaultBefore.format.kdf && newFile.vaultCorpusKeyID == material.corpusKeyID,
                "the descriptor and the corpus key id recorded — no confirm owed")
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey, "L′ under M")
        #expect(!FileManager.default.fileExists(atPath: oldURL.path), "the OLD key file REMOVED from the live folder")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL)?.keyFingerprint == outcome.newKeyFingerprint,
                "locate finds exactly the new file")
        // A opens NO page of the re-keyed library: the old file's Apple copy
        // unwraps only the OLD key, which opens nothing now.
        let viaApple = try oldFile.unwrapKey(apple: world.apple.symmetricKey)
        #expect(viaApple == world.oldKey && !StoreEncryptionMigration.opens(world.storeURL, key: viaApple))
        #expect(try await world.marker() == nil && world.calls.resumes >= 1 && world.calls.reconciles >= 1)
    }

    /// pre-13x 2d.4 (the orchestrator's ruling 3): a FOLLOW killed after the
    /// re-key and before the old key files' removal — the marker at
    /// `.rekeyLibrary`, flagged as a follow — RESUMES and still retires
    /// them: the old fingerprint-named file AND the wrap-less legacy stub
    /// are gone at the end, custody behind the gate, the marker clear. The
    /// exposure's closure never depends on the process surviving. RED ON
    /// OLD: the removal ran after the road returned, and the marker's
    /// resume did not know it was a follow — the Standard-era key file
    /// stayed beside the Castle library after a crash.
    @Test func aFollowKilledAfterTheReKeyResumesAndStillRetiresTheOldKeyFiles() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let oldFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        let oldURL = world.oldKeyFileURL
        let stubURL = StoreKeyEnvelope.legacyURL(besideStore: world.storeURL)
        try Data("{\n  \"formatVersion\" : 1,\n  \"storeID\" : \"\(oldFile.storeID)\"\n}".utf8).write(to: stubURL)

        world.calls.rekeyFault = .afterWork  // the swap landed; the process dies before custody
        await #expect(throws: URLError.self) {
            _ = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        }
        let marker = try #require(try await world.marker())
        #expect(marker.step == .rekeyLibrary && marker.isFollow, "the marker knows this road is a follow")
        #expect(FileManager.default.fileExists(atPath: oldURL.path) && FileManager.default.fileExists(atPath: stubURL.path),
                "killed before the removal: both old files still there")
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "…and the library already under L′")

        let outcome = try await world.runner.resume(passphrase: nil)
        #expect(outcome.entersCastle)
        #expect(world.calls.custodyTargets == [.biometric] && world.posture == .castle)
        #expect(try await world.marker() == nil)
        #expect(!FileManager.default.fileExists(atPath: oldURL.path), "the resumed follow retired the old key file")
        #expect(!FileManager.default.fileExists(atPath: stubURL.path), "…and the wrap-less stub")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL)?.keyFingerprint == outcome.newKeyFingerprint)
        #expect(StoreKeyEnvelope.keyFileURLs(besideStore: world.storeURL).count == 1, "exactly one key file beside the library")
    }

    /// pre-13x 2d.4 (ruling 5's other half): a legacy-named format-1 key
    /// file WITH wraps is NOT a stub — it may serve legacy snapshots (§6) —
    /// and stays byte-identical through the follow while the old
    /// fingerprint-named file goes. RED ON OLD (batch C4): a removal keyed
    /// on the legacy NAME alone took it.
    @Test func aWrappedLegacyKeyFileStaysAtTheFollow() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let oldFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        var wrapped = StoreKeyEnvelope(storeID: oldFile.storeID)
        try wrapped.setPassphraseWrap(key: world.oldKey, passphrase: "an older word", kdf: fastKDF())
        wrapped.formatVersion = StoreKeyEnvelope.formatVersion1
        let legacyURL = StoreKeyEnvelope.legacyURL(besideStore: world.storeURL)
        try wrapped.write(at: legacyURL)
        let bytesBefore = try Data(contentsOf: legacyURL)

        let outcome = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle)
        #expect(!FileManager.default.fileExists(atPath: world.oldKeyFileURL.path), "the old fingerprint-named file goes")
        #expect(try Data(contentsOf: legacyURL) == bytesBefore, "a legacy file WITH wraps stays, byte-identical")
        #expect(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL)?.keyFingerprint == outcome.newKeyFingerprint,
                "…and `locate` still prefers the fingerprinted file")
    }

    /// A follow by the TWELVE WORDS alone (no passphrase typed): M′ from
    /// the vault's W copy; the new key file carries L′ under W and M′ —
    /// and NO passphrase copy until the passphrase is next typed here.
    @Test func aFollowByTheTwelveWordsLandsTheWCopyAndNoPassphraseCopy() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        await #expect(throws: PostureSwitchError.secretRequired) {
            _ = try await sibling.runner.follow(passphrase: nil, recoveryWords: nil)
        }
        let outcome = try await sibling.runner.follow(passphrase: nil, recoveryWords: acting.words)
        let newFile = try sibling.keyFile(outcome.newKeyFingerprint)
        let newKey = try newFile.unwrapKey(recoveryWords: acting.words)
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: newKey), "L′ under the typed words")
        #expect(newFile.passphrase == nil, "no passphrase copy — it lands when the passphrase is next typed here")
        #expect(try newFile.unwrapKey(master: try #require(outcome.material).masterSymmetricKey) == newKey)
        #expect(sibling.keyStore.load()?.corpusKeyID == (try await sibling.vault()).format.classKey(for: .corpus)?.keyID)
    }

    /// THE FOLLOW INTO STANDARD is silent: the account left Castle
    /// elsewhere (the vault gained an Apple-held copy under the SAME corpus
    /// key id); this Castle device adds its own iCloud copy to its key file
    /// (A from its own iCloud Keychain), moves custody gated → silent, and
    /// rotates nothing — no vault write, no marker, nothing typed.
    @Test func theFollowIntoStandardAddsTheAppleCopyAndMovesCustodySilentRotatingNothing() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let material = try #require(world.oldMaterial)
        // "Another device" left Castle: the vault gains the Apple-held copy.
        let otherDevicesApple = AppleKey.mint()
        let fetched = try await world.vault()
        try await client.updateVault(
            try fetched.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: otherDevicesApple.symmetricKey,
                appleKeyID: otherDevicesApple.id),
            expectedRevision: fetched.revision, keyProof: KeyProof.wireToken(master: material.masterSymmetricKey))
        let revisionAfterTheirWrite = try await world.vault().revision

        try await world.runner.followIntoStandard()

        let keyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(keyFile.appleKeyID == world.apple.id, "THIS device's own A, from its own iCloud Keychain")
        #expect(try keyFile.unwrapKey(apple: world.apple.symmetricKey) == world.oldKey)
        #expect(world.calls.custodyTargets == [.auto] && world.posture == .standard)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "nothing rotated")
        #expect(try await world.vault().revision == revisionAfterTheirWrite, "no vault write of its own")
        #expect(try await world.marker() == nil)
    }

    /// A CASTLE follower of Replace All Keys (run elsewhere, still
    /// finishing): it finishes the walk, re-keys, keeps its Castle gate —
    /// and lists NO offer: its old pairs never opened through the Apple
    /// account, so the offer's sentence would be false.
    @Test func aCastleFollowerOfReplaceAllKeysFinishesTheWalkAndListsNoOffer() async throws {
        let world = try await makeWorld(standard: false)
        defer { world.tearDown() }
        let client = try #require(world.vaultClient)
        let oldMaterial = try #require(world.oldMaterial)
        try world.addPreSwitchPair()
        // "Another device" replaced the keys under Castle and stopped.
        let secrets = try RotationSecrets.derive(passphrase: "sesame", recoveryWords: world.words, kdf: fastKDF())
        _ = try await CorpusRotation.begin(client: client, current: oldMaterial, secrets: secrets, appleHeldCopy: nil)
        #expect(try await world.vault().format.previousCorpusKey != nil)

        let outcome = try await world.runner.follow(passphrase: "sesame", recoveryWords: nil)
        #expect(outcome.entersCastle, "the account is Castle — the gate stays")
        #expect(outcome.preSwitchSnapshots.isEmpty, "a Castle follower is offered nothing")
        #expect(outcome.reencrypted >= 3, "the follower finished the walk")
        let vault = try await world.vault()
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil)
        #expect(world.calls.custodyTargets.last == .biometric)
        let newFile = try world.keyFile(outcome.newKeyFingerprint)
        #expect(newFile.apple == nil)
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: try newFile.unwrapKey(passphrase: "sesame")))
    }

    // MARK: - pre-13x 2c.1: THE FOLLOW's face over the real runner

    /// §7 end to end on the sibling: the controller's reconcile reads the
    /// vault (the acting device entered Castle) and owes the follow with
    /// *[device] on [day]*; *Later* leaves the un-followed state (the
    /// persistent banner, every key door's sentence, no marker, custody
    /// unchanged); the reopened notice's typed passphrase walks
    /// `runner.follow` — M′ in custody, the library re-keyed, the offer for
    /// the pre-switch pair — and the controller's follow is no longer owed.
    /// RED-ON-OLD: no verdict, no model — the sibling's only road was the
    /// 14c bare re-enroll.
    @Test func theFollowModelWalksTheNoticeToTheActAndLaterLeavesTheUnfollowedState() async throws {
        let acting = try await makeWorld()
        defer { acting.tearDown() }
        let sibling = try await makeWorld(sharing: acting)
        defer { sibling.tearDown() }
        let oldMaterial = try #require(acting.oldMaterial)
        try sibling.addPreSwitchPair()
        _ = try await acting.runner.enterCastle(passphrase: "sesame", recoveryWords: acting.words)
        let vault = try await sibling.vault()
        let newKeyID = try #require(vault.format.classKey(for: .corpus)?.keyID)
        #expect(newKeyID != oldMaterial.corpusKeyID)

        let controller = makeController(for: sibling)
        controller.switchRunner = sibling.runner
        controller.stampedOwnerID = { nil }
        controller.readVaultPosture = { [client = sibling.vaultClient] in
            guard let fetched = try? await client?.fetchVault() else { return nil }
            return VaultPostureReading(
                hasAppleHeldCopy: fetched.format.masterWrappedByAppleHeld != nil,
                appleKeyID: fetched.format.appleKeyID, passphraseKDF: fetched.format.kdf,
                hasPassphraseWrap: true, corpusKeyID: fetched.format.classKey(for: .corpus)?.keyID,
                updatedAt: fetched.updatedAt, updatedByDevice: fetched.format.updatedByDevice,
                signedInUserID: "user-2b", hasRecoveryWrap: true, format: fetched.format)
        }
        await controller.reconcile()
        let owed = try #require(controller.followNotice)
        #expect(owed.kind == .movedToCastle)
        #expect(owed.device == "test device", "decision 34: the acting device's own name rides the notice")
        #expect(controller.notice == .follow(owed))

        // Later: the un-followed state.
        controller.openFollow()
        let first = try #require(controller.activeFollow)
        first.later()
        controller.closeFollow()
        #expect(controller.notice == .followWaiting(owed), "the persistent banner")
        #expect(controller.followPending, "every key door: pick up your new keys first")
        #expect(try await sibling.marker() == nil)
        #expect(sibling.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "custody unchanged")

        // The banner's Enter…: the typed passphrase walks the follow.
        controller.openFollow()
        let model = try #require(controller.activeFollow)
        model.choosePassphrase()
        #expect(model.phase == .askPassphrase)
        await model.enter(passphrase: "not-the-passphrase")
        #expect(model.lastError == ProtectionCopy.passphraseNotTheLibrarys)
        #expect(model.phase == .askPassphrase, "a wrong word writes nothing and asks again")
        let insuranceWasOn = MarkdownInsurance.isEnabled(in: sibling.defaults)
        await model.enter(passphrase: "sesame")
        #expect(model.phase == .done(insuranceOff: insuranceWasOn, hasOffer: true),
                "Done reports the insurance flip only when the follower had it on")
        #expect(sibling.keyStore.load()?.corpusKeyID == newKeyID, "M′ in custody")
        #expect(sibling.calls.rekeys == 1, "the library re-keyed as it followed")
        #expect(try await sibling.marker() == nil)
        #expect(!controller.followPending, "the follow is no longer owed")
        #expect(controller.notice != .followWaiting(owed) && controller.notice != .follow(owed))
        model.continueFromDone()
        #expect(model.phase == .offer)
        model.keepOldBackups()
        #expect(model.phase == .closed)
    }
}
