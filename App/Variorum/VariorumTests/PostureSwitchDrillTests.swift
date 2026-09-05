//
//  PostureSwitchDrillTests.swift
//  VariorumTests
//
//  pre-13x batch 2b — THE DRILLS (the batch gate's): Standard → Castle over a
//  scratch KEYED library seeded with the SAMPLE LIBRARY (the Sherlock corpus —
//  thousands of rows pushed under the old corpus key), with a fake-server
//  sibling holding old-corpus-key rows (its pull refused by the fence until it
//  follows); Castle → Standard; a crash at each of the three seams re-run to
//  completion; the switch's wall time recorded. Unlike the pins
//  (`PostureSwitchTests` — in-memory backings, scripted custody), the drills
//  run the REAL `ProtectionController.moveCustody(to:)` over the REAL device
//  Keychain under a THROWAWAY scope (`KeychainTestTripwire`'s law: only the
//  real scopes are guarded; throwaway scopes are their own safety), the real
//  key files, the real export-and-swap through a scratch binding, the real
//  `StoreBackup` pair helpers over a scratch Backups folder, and the emulated
//  mirror + vault of the pins.
//
//  The drill runs as a NO-BIOMETRY machine (`biometryAvailable` false), so
//  Castle's gate is the passphrase — no Keychain item at all: a Touch ID
//  item's ACL read would PROMPT inside a test, which no test can answer. The
//  Touch ID target is pinned in `PostureSwitchTests`; the gated add's landing
//  in the signed host is `Phase13pKeychainFactTests`' proof.
//
//  OPT-IN — DISABLED unless VARIORUM_POSTURE_DRILL=1 (it seeds the whole
//  corpus and writes real Keychain items; run deliberately):
//      TEST_RUNNER_VARIORUM_POSTURE_DRILL=1 xcodebuild test-without-building … \
//          -only-testing:VariorumTests/PostureSwitchDrillTests
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

nonisolated enum PostureSwitchDrill {
    static var requested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_POSTURE_DRILL"] == "1"
    }
}

private struct DrillKeyProvider: SyncKeyProviding {
    let keys: SyncEncryptionKeys
    func currentKeys() throws -> SyncEncryptionKeys { keys }
    func deviceIdentity() throws -> String { "drill-sibling" }
}

@MainActor
@Suite(
    "pre-13x 2b — THE DRILLS: Standard → Castle over the sample library with a sibling, Castle → Standard, the three seams (opt-in; DISABLED unless VARIORUM_POSTURE_DRILL=1)",
    .serialized,
    .enabled(
        if: PostureSwitchDrill.requested,
        "seeds the whole sample library into a scratch keyed store and writes real Keychain items under a throwaway scope — run deliberately with TEST_RUNNER_VARIORUM_POSTURE_DRILL=1"))
struct PostureSwitchDrillTests {
    enum RekeyFault { case beforeWork, afterWork }

    @MainActor
    final class DrillWorld {
        let scope: String
        let dir: URL
        let storeURL: URL
        let backups: URL
        let suiteName: String
        let oldKey: StoreKey
        let apple: AppleKey
        let binding: StoreBinding
        let view: AppDatabase
        let session: SyncCustodySession
        let keyStore: DeviceKeyStore
        let vaultClient: KeyVaultClient
        /// Retained here: the client's `load` seam holds it weakly.
        let vaultEmu: EmulatedVault
        let mirror: EmulatedMirror
        let gate: StoreLaunchGate
        let protection: ProtectionController
        let storeID: String
        var oldMaterial: DeviceKeyMaterial!
        var words: [String] = []
        var runner: PostureSwitchRunner!
        var rekeyFault: RekeyFault?
        var rekeys = 0
        var pauses = 0
        var resumes = 0
        let log = LockIsolated<[String]>([])
        var rowsPushed = 0
        var variantCount = 0
        var sampleVariant: (id: String, text: String)?

        init(scope: String, dir: URL, storeURL: URL, backups: URL, suiteName: String, oldKey: StoreKey,
             apple: AppleKey, binding: StoreBinding, view: AppDatabase, session: SyncCustodySession,
             keyStore: DeviceKeyStore, vaultClient: KeyVaultClient, vaultEmu: EmulatedVault, mirror: EmulatedMirror,
             gate: StoreLaunchGate, protection: ProtectionController, storeID: String) {
            self.scope = scope; self.dir = dir; self.storeURL = storeURL; self.backups = backups
            self.suiteName = suiteName; self.oldKey = oldKey; self.apple = apple; self.binding = binding
            self.view = view; self.session = session; self.keyStore = keyStore; self.vaultClient = vaultClient
            self.vaultEmu = vaultEmu; self.mirror = mirror; self.gate = gate; self.protection = protection; self.storeID = storeID
        }

        func note(_ line: String) {
            log.withValue { $0.append(line) }
            print("drill 2b: \(line)")
        }

        /// The throwaway scope's Keychain items, removed; the folders; the
        /// defaults domain.
        func tearDown() {
            binding.lock()
            _ = StoreKeyCustody.deviceKeychainRemove(scope: scope, storeID: storeID)
            _ = StoreKeyGuardKeychain.deleteGated(scope: scope, storeID: storeID)
            let custodyScope = SyncCustodyScope(scope: scope, storeID: storeID)
            _ = E2EEKeychainStorage.deletePlainItem(scope: custodyScope)
            _ = E2EEKeychainStorage.deleteGatedItem(scope: custodyScope)
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: dir)
        }

        func marker() async throws -> RotationMarker? {
            try await view.read { try RotationMarker.read($0) }
        }

        func vault() async throws -> KeyVaultClient.FetchedVault {
            try #require(try await vaultClient.fetchVault())
        }

        var silentStoreKey: StoreKey? {
            StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL).load()
        }

        var plainSyncRecord: SyncCustodyRecord? {
            E2EEKeychainStorage.load(scope: SyncCustodyScope(scope: scope, storeID: storeID))
        }

        var oldKeyFileURL: URL {
            StoreKeyEnvelope.url(besideStore: storeURL, fingerprint: StoreKeyEnvelope.fingerprint(of: oldKey))
        }
    }

    nonisolated private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A STANDARD, ENROLLED library holding the whole sample library, pushed
    /// under the old corpus key; the real controller over the real Keychain
    /// under the throwaway scope; the runner over drill leaves.
    private func makeWorld() async throws -> DrillWorld {
        let scope = "Variorum-drill-\(UUID().uuidString.prefix(8))"
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-2b-drill-\(UUID().uuidString)", isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let suiteName = "io.lduarte.variorum.tests.2b-drill.\(UUID().uuidString)"
        let oldKey = StoreKey.mint()
        let opened = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: oldKey))
        let (view, binding) = opened.asRebindable()
        let apple = AppleKey.mint()
        let appleBacking = InMemoryAppleKeyBacking(key: apple)

        // The vault + the mirror (the pins' emulation), this device's custody.
        let mirror = EmulatedMirror()
        let emu = EmulatedVault(claimRotationSeq: { await mirror.claimSeq() })
        let vaultClient = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.2b-drill.invalid")!, apiKey: "publishable-test-key"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-2b-drill", userID: "user-2b-drill")),
            load: emu.load)
        await mirror.attach(vault: vaultClient)
        let material = try await VaultEnrollment(client: vaultClient).setUp(passphrase: "sesame")

        // The key file FIRST (the custody items are named by its store id).
        let storeID = "drill-\(UUID().uuidString.lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
        try envelope.appleBox(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try envelope.masterBox(key: oldKey, under: material.masterSymmetricKey)
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        // REAL custody under the throwaway scope: the silent store-key item,
        // the plain sync record (Standard's shapes).
        #expect(StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL).save(oldKey),
                "the silent store-key item under the throwaway scope")
        let session = SyncCustodySession()
        let keyStore = DeviceKeyStore.keychain(
            scope: scope, storeURL: storeURL, session: session,
            defaults: { UserDefaults(suiteName: suiteName)! })
        #expect(keyStore.save(material), "the plain sync record under the throwaway scope")
        #expect(keyStore.load()?.corpusKeyID == material.corpusKeyID)

        let dials = ScriptedDialsBox(ProtectionDials())
        let gate = StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { scope in StoreKeyGuard.keychain(scope: scope, storeURL: storeURL) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in })
        let protection = ProtectionController(configuration: .init(
            scope: scope, storeURL: storeURL, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) },
            syncCustodySession: session))

        let world = DrillWorld(
            scope: scope, dir: dir, storeURL: storeURL, backups: backups, suiteName: suiteName,
            oldKey: oldKey, apple: apple, binding: binding, view: view, session: session,
            keyStore: keyStore, vaultClient: vaultClient, vaultEmu: emu, mirror: mirror, gate: gate,
            protection: protection, storeID: storeID)
        world.oldMaterial = material
        world.words = try RecoveryPhrase.generate()

        // THE SAMPLE LIBRARY, seeded whole, then pushed to the last row.
        let seedClock = ContinuousClock()
        let seedTime = try await seedClock.measure {
            try await withDependencies {
                $0.database = view
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { Date() }
                $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
            } operation: { @MainActor in
                let appSession = AppSession(database: view)
                let stories = try SampleLibrarySeeder.loadStories()
                let result = try await SampleLibrarySeeder.seed(
                    session: appSession, stories: stories, existing: SampleLibrarySeeder.Existing())
                guard case .seeded = result else {
                    Issue.record("the sample library did not seed: \(result)")
                    return
                }
            }
        }
        world.variantCount = try await view.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
        }
        world.sampleVariant = try await view.read { db in
            try Row.fetchOne(db, sql: "SELECT id, working_text FROM variant WHERE length(working_text) > 200 ORDER BY id LIMIT 1")
                .map { (id: $0["id"] as String, text: $0["working_text"] as String) }
        }
        let engine = SyncEngine(transport: mirror, keyProvider: DeviceKeySyncProvider(store: keyStore))
        let pushTime = try await seedClock.measure {
            try await withDependencies { $0.database = view } operation: {
                var rounds = 0
                while try await engine.outboxCount() > 0, rounds < 200 {
                    _ = try await engine.push()
                    rounds += 1
                }
                #expect(try await engine.outboxCount() == 0, "the corpus drained to the mirror")
            }
        }
        world.rowsPushed = await mirror.stored().count
        world.note("seeded the sample library in \(seedTime) — \(world.variantCount) live takes; pushed \(world.rowsPushed) rows under the old corpus key in \(pushTime)")

        await protection.reconcile()
        #expect(protection.posture == .standard, "the drill starts in Standard: \(protection.posture)")
        #expect(protection.keyInHand() == oldKey, "the silent item holds the library key")
        world.runner = PostureSwitchRunner(leaves: leaves(for: world))
        return world
    }

    private func leaves(for world: DrillWorld) -> PostureSwitchRunner.Leaves {
        let backups = world.backups
        let suiteName = world.suiteName
        let protection = world.protection
        let pairs: @Sendable (String) -> [URL] = { keep in
            ((try? StoreBackup.existingBackups(in: backups)) ?? []).filter {
                StoreBackup.shortFingerprint(fromBackupURL: $0) != keep
            }
        }
        return PostureSwitchRunner.Leaves(
            scope: world.scope,
            storeURL: world.storeURL,
            database: world.view,
            gate: world.gate,
            keyStore: world.keyStore,
            keyProvider: DeviceKeySyncProvider(store: world.keyStore),
            vault: world.vaultClient,
            transport: world.mirror,
            signedIn: { true },
            appleKeys: world.gate.appleKeyFor(world.scope),
            libraryKeyInHand: { protection.keyInHand() },
            posture: { protection.posture },
            alwaysAsk: { protection.dials.alwaysAsk },
            biometryAvailable: { false },  // the drill's machine: no biometry ⇒ the passphrase gate (no item, no prompt)
            moveCustody: { target in await protection.moveCustody(to: target) },
            rekeyLibrary: { old, new, work in
                if world.rekeyFault == .beforeWork {
                    world.rekeyFault = nil
                    throw URLError(.cancelled)
                }
                world.rekeys += 1
                protection.dropResident()
                world.binding.lock()
                var failure: (any Error)?
                let clock = ContinuousClock()
                let elapsed = clock.measure {
                    do { try work() } catch { failure = error }
                }
                let opened = StoreEncryptionMigration.opens(world.storeURL, key: new) ? new : old
                try world.binding.adopt(try AppDatabase.openStore(at: world.storeURL, custody: .inMemory(initial: opened)))
                protection.adoptResident(opened)
                world.note("re-keyed the library file in \(elapsed) (under \(opened == new ? "L′" : "L"))")
                if let failure { throw failure }
                if world.rekeyFault == .afterWork {
                    world.rekeyFault = nil
                    throw URLError(.cancelled)
                }
            },
            pauseSync: { world.pauses += 1 },
            resumeSync: { world.resumes += 1 },
            takeSnapshot: {
                guard let key = protection.keyInHand() else { return nil }
                let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key))
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.dateFormat = "yyyy-MM-dd-HHmmss"
                let stamp = formatter.string(from: Date())
                let url = backups.appendingPathComponent("\(StoreBackup.filePrefix)\(stamp)-\(fp8).\(StoreBackup.fileExtension)")
                do {
                    try world.view.backup(to: url)
                } catch {
                    world.note("snapshot failed: \(error)")
                    return nil
                }
                StoreBackup.writeSnapshotKeyFile(for: url, from: StoreKeyEnvelope.locate(besideStore: world.storeURL))
                world.note("snapshot pair written: \(url.lastPathComponent)")
                return url
            },
            preSwitchSnapshots: { keep in pairs(keep) },
            deleteSnapshotPairs: { urls in
                var removed = 0
                for url in urls where (try? StoreBackup.removeSnapshotPair(url)) != nil { removed += 1 }
                return removed
            },
            defaults: { UserDefaults(suiteName: suiteName)! },
            reconcile: { await protection.reconcile() },
            now: { Date() },
            log: { line in
                world.log.withValue { $0.append(line) }
                print("drill 2b: \(line)")
            })
    }

    /// The end state of a completed Standard → Castle switch in the drill.
    private func expectCastleEndState(_ world: DrillWorld, _ outcome: PostureSwitchRunner.Outcome) async throws {
        #expect(outcome.entersCastle)
        let material = try #require(outcome.material)
        let newFile = try #require(try StoreKeyEnvelope.load(
            at: StoreKeyEnvelope.url(besideStore: world.storeURL, fingerprint: outcome.newKeyFingerprint)))
        let newKey = try newFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey))
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
        #expect(newFile.apple == nil && newFile.appleKeyID == nil)
        #expect(try newFile.unwrapKey(recoveryWords: world.words) == newKey)
        #expect(try newFile.unwrapKey(master: material.masterSymmetricKey) == newKey)
        // The Standard-era key file + A opens no page.
        let oldFile = try #require(try StoreKeyEnvelope.load(at: world.oldKeyFileURL))
        let standardEraKey = try oldFile.unwrapKey(apple: world.apple.symmetricKey)
        #expect(!StoreEncryptionMigration.opens(world.storeURL, key: standardEraKey))
        // The real controller: Castle; the real Keychain: no silent item, no
        // gated item, the plain sync item keeping ONLY the device identity —
        // the session holds the keys; the resident is L′.
        #expect(world.protection.posture == .castle, "posture: \(world.protection.posture)")
        #expect(world.silentStoreKey == nil, "the silent store-key item is gone")
        #expect(!StoreKeyGuardKeychain.gatedItemExists(scope: world.scope, storeID: world.storeID))
        #expect(world.plainSyncRecord?.material == nil, "the sync keys left the plain item")
        #expect(world.plainSyncRecord?.deviceID != nil, "the device identity stays in per-store custody")
        #expect(world.session.record?.material?.corpusKeyID == material.corpusKeyID, "the session holds M′ / C′")
        #expect(world.keyStore.load()?.rotation == nil)
        #expect(world.protection.keyInHand() == newKey)
        // The vault: previous key + seq cleared, no Apple-held copy, the new proof.
        let vault = try await world.vault()
        #expect(vault.format.previousCorpusKey == nil && vault.format.rotationStartedSeq == nil)
        #expect(vault.format.masterWrappedByAppleHeld == nil)
        #expect(vault.format.classKey(for: .corpus)?.keyID == material.corpusKeyID)
        #expect(try await world.marker() == nil)
        // Every row re-encrypted (across the crash, when there was one).
        let batches = await world.mirror.reencryptBatches
        #expect(batches.flatMap { $0 }.count == world.rowsPushed, "every pushed row re-encrypted: \(batches.flatMap { $0 }.count) of \(world.rowsPushed)")
    }

    // MARK: - Drill 1: Standard → Castle with a sibling, then Castle → Standard

    @Test func standardToCastleWithASiblingThenBackToStandard() async throws {
        let world = try await makeWorld()
        defer { world.tearDown() }
        let oldMaterial: DeviceKeyMaterial = world.oldMaterial
        MarkdownInsurance.setEnabled(true, in: UserDefaults(suiteName: world.suiteName)!)

        // The SIBLING: a second library on the old keys, pulled to head.
        let siblingURL = world.dir.appendingPathComponent("sibling/variorum.sqlite")
        let sibling = try AppDatabase.openStore(at: siblingURL, custody: .inMemory(initial: .mint()))
        let siblingOld = SyncEngine(transport: world.mirror, keyProvider: DrillKeyProvider(keys: oldMaterial.syncKeys))
        try await withDependencies { $0.database = sibling } operation: {
            let report = try await siblingOld.pull()
            #expect(report.applied + report.merged == world.rowsPushed,
                    "the sibling holds the whole corpus under the old key: applied \(report.applied), merged \(report.merged) (its own seeded settings)")
        }
        // A pre-switch snapshot pair (the app's own) — the offer's subject.
        let drillLeaves = leaves(for: world)
        let preSwitchPair = try #require(await drillLeaves.takeSnapshot())
        let preSwitchBytes = try Data(contentsOf: preSwitchPair)
        let preSwitchPairKeyBytes = try Data(contentsOf: StoreBackup.pairedKeyFile(for: preSwitchPair))

        // ————— STANDARD → CASTLE —————
        let clock = ContinuousClock()
        var outcome: PostureSwitchRunner.Outcome?
        let wall = try await clock.measure {
            outcome = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
        }
        let done = try #require(outcome)
        world.note("STANDARD → CASTLE in \(wall) — \(done.reencrypted) rows re-encrypted; insurance off: \(done.insuranceTurnedOff); pre-switch pairs: \(done.preSwitchSnapshots.map(\.lastPathComponent))")
        try await expectCastleEndState(world, done)
        #expect(done.reencrypted == world.rowsPushed, "one run re-encrypted every row: \(done.reencrypted)")
        #expect(done.insuranceTurnedOff && !MarkdownInsurance.isEnabled(in: UserDefaults(suiteName: world.suiteName)!))
        #expect(done.preSwitchSnapshots == [preSwitchPair], "the offer lists the pre-switch pair only")
        #expect(try Data(contentsOf: preSwitchPair) == preSwitchBytes, "no backup folder rewritten")
        #expect(try Data(contentsOf: StoreBackup.pairedKeyFile(for: preSwitchPair)) == preSwitchPairKeyBytes)
        let after = try StoreBackup.existingBackups(in: world.backups)
        #expect(after.count == 2, "the fresh pair beside the old one: \(after.map(\.lastPathComponent))")
        let fresh = try #require(after.first { $0 != preSwitchPair })
        #expect(StoreBackup.shortFingerprint(fromBackupURL: fresh) == StoreKeyEnvelope.shortFingerprint(done.newKeyFingerprint))
        #expect(FileManager.default.fileExists(atPath: StoreBackup.pairedKeyFile(for: fresh).path))

        // THE SIBLING on the old keys: refused at the fence; it FOLLOWS by the
        // passphrase (the vault's M′), then pulls; a FRESH sibling reads the
        // whole corpus back in the clear under the new keys.
        try await withDependencies { $0.database = sibling } operation: {
            await #expect(throws: SyncError.encryptionKeysReplaced, "the sibling's old-key pull is refused") {
                _ = try await siblingOld.pull()
            }
        }
        let followed = try await VaultEnrollment(client: world.vaultClient).enroll(passphrase: "sesame")
        #expect(followed.corpusKeyID == done.material?.corpusKeyID && followed.rotation == nil)
        let siblingNew = SyncEngine(transport: world.mirror, keyProvider: DrillKeyProvider(keys: followed.syncKeys))
        try await withDependencies { $0.database = sibling } operation: {
            let report = try await siblingNew.pull()
            world.note("the followed sibling pulled: applied \(report.applied), merged \(report.merged), cursor \(report.newCursor)")
        }
        let freshURL = world.dir.appendingPathComponent("fresh/variorum.sqlite")
        let freshStore = try AppDatabase.openStore(at: freshURL, custody: .inMemory(initial: .mint()))
        let freshEngine = SyncEngine(transport: world.mirror, keyProvider: DrillKeyProvider(keys: followed.syncKeys))
        try await withDependencies { $0.database = freshStore } operation: {
            let report = try await freshEngine.pull()
            #expect(report.applied + report.merged == world.rowsPushed,
                    "a fresh device under the new keys applies every row: applied \(report.applied), merged \(report.merged)")
        }
        let freshVariants = try await freshStore.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
        }
        #expect(freshVariants == world.variantCount, "every take arrived: \(freshVariants) of \(world.variantCount)")
        if let sample = world.sampleVariant {
            let text = try await freshStore.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [sample.id])
            }
            #expect(text == sample.text, "a sampled take reads back byte-for-byte under the new corpus key")
        }
        // The offer: Delete Them.
        #expect(world.runner.deletePreSwitchSnapshots(done) == 1)
        #expect(!FileManager.default.fileExists(atPath: preSwitchPair.path))
        #expect(!FileManager.default.fileExists(atPath: StoreBackup.pairedKeyFile(for: preSwitchPair).path))
        #expect(FileManager.default.fileExists(atPath: fresh.path))

        // ————— CASTLE → STANDARD —————
        let batchesBefore = await world.mirror.reencryptBatches.count
        let corpusBefore = try await world.vault().format.classKey(for: .corpus)?.keyID
        let leaveWall = try await clock.measure {
            try await world.runner.leaveCastle()
        }
        world.note("CASTLE → STANDARD in \(leaveWall)")
        let vault = try await world.vault()
        #expect(vault.format.appleKeyID == world.apple.id)
        #expect(try vault.format.unwrapMaster(withAppleKey: world.apple.symmetricKey).withUnsafeBytes { Data($0) } == followed.masterKey)
        #expect(vault.format.classKey(for: .corpus)?.keyID == corpusBefore, "nothing rotated")
        let keyFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: world.storeURL))
        #expect(keyFile.appleKeyID == world.apple.id)
        #expect(try keyFile.unwrapKey(apple: world.apple.symmetricKey) == world.protection.keyInHand())
        #expect(world.protection.posture == .standard, "posture: \(world.protection.posture)")
        #expect(world.silentStoreKey == world.protection.keyInHand(), "the silent item holds L′ again")
        #expect(world.plainSyncRecord?.material?.corpusKeyID == followed.corpusKeyID, "the plain sync record is back")
        let batchesAfter = await world.mirror.reencryptBatches.count
        #expect(batchesAfter == batchesBefore, "the mirror untouched")
        world.note("DONE — log lines: \(world.log.value.count)")
    }

    // MARK: - Drill 2: the three seams

    @Test func aCrashAtEachSeamResumesToCompletionOverTheSampleLibrary() async throws {
        let clock = ContinuousClock()
        // Seam A — mid re-encryption.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            await world.mirror.setCrashNextReencrypt(true)
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .reencrypt)
            #expect(world.keyStore.load()?.rotation != nil)
            #expect(world.silentStoreKey == world.oldKey, "the store key untouched before step 4")
            let wall = try await clock.measure {
                let outcome = try await world.runner.resume(passphrase: "sesame", recoveryWords: world.words)
                try await expectCastleEndState(world, outcome)
            }
            world.note("SEAM A (mid re-encryption) resumed to completion in \(wall)")
        }
        // Seam B — after the export, before the swap.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.rekeyFault = .beforeWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .rekeyLibrary)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey))
            let wall = try await clock.measure {
                let outcome = try await world.runner.resume(passphrase: nil)
                try await expectCastleEndState(world, outcome)
            }
            world.note("SEAM B (before the swap) resumed to completion in \(wall) — no passphrase needed (the master copy)")
        }
        // Seam C — after the swap, before custody.
        do {
            let world = try await makeWorld()
            defer { world.tearDown() }
            world.rekeyFault = .afterWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: "sesame", recoveryWords: world.words)
            }
            #expect(try await world.marker()?.step == .rekeyLibrary)
            #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the swap landed")
            #expect(world.silentStoreKey == world.oldKey, "custody not yet moved: the silent item still holds L")
            let rekeysBefore = world.rekeys
            let wall = try await clock.measure {
                let outcome = try await world.runner.resume(passphrase: nil)
                try await expectCastleEndState(world, outcome)
            }
            #expect(world.rekeys == rekeysBefore, "never exported again")
            world.note("SEAM C (after the swap, before custody) resumed to completion in \(wall)")
        }
    }
}
