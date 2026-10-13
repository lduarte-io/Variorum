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
        /// pre-13x 2c: the account's Apple key backing (iCloud Keychain's
        /// stand-in) — SHARED with the sibling device, as it would be.
        var appleBacking: InMemoryAppleKeyBacking!
        /// pre-13x 3a: the fresh-device worlds carry the APP seam — the
        /// session and auth `wireOneSecretHooks` composes at both roots.
        var encryption: EncryptionSession?
        var auth: AuthSession?

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
                projectURL: URL(string: "https://vault.2b-drill.invalid")!, apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-2b-drill", userID: "user-2b-drill")),
            load: emu.load)
        // 13y round 4: one account, one enrollment state (see
        // EmulatedVault.enrolledSecret).
        await mirror.attach(vault: vaultClient, enrollment: emu)
        let material = try await VaultEnrollment(client: vaultClient).setUp(passphrase: "sesame")
        // STANDARD's steady state (2a): the vault carries the Apple-held copy
        // of M under this account's A — the same act leaving Castle performs
        // (`settingAppleHeldCopy` + the proof-carrying update). Without it the
        // vault is 14b-shaped (P only) and no new device could open it
        // silently — which is the Standard new-device road drill 1 proves.
        let minted = try #require(try await vaultClient.fetchVault())
        try await vaultClient.updateVault(
            try minted.format.settingAppleHeldCopy(
                masterKey: material.masterSymmetricKey, appleKey: apple.symmetricKey, appleKeyID: apple.id),
            expectedRevision: minted.revision, keyProof: KeyProofMaterial(master: material.masterSymmetricKey))

        // The key file FIRST (the custody items are named by its store id).
        let storeID = "drill-\(UUID().uuidString.lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
        try envelope.setAppleWrappedCopy(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        try envelope.setMasterWrappedCopy(key: oldKey, under: material.masterSymmetricKey)
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
        world.appleBacking = appleBacking

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
                #expect(result.minted > 0, "the sample library seeded: \(result)")
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
            try await withDependencies {
                $0.database = view
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { Date() }
            } operation: {
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

    /// pre-13x 2c — THE SIBLING DEVICE (U3's "a Standard sibling device
    /// following"): a second library on the SAME account — the same vault,
    /// the same mirror, the same Apple key — pulled to head under the old
    /// keys, Standard-shaped (its own key file with P + A + M, the silent
    /// store-key item, the plain sync record with the OLD material) under
    /// its OWN throwaway scope, with its own controller and runner. It
    /// follows through the REAL `PostureSwitchRunner.follow`.
    private func makeSibling(of acting: DrillWorld) async throws -> DrillWorld {
        let scope = "\(acting.scope)-sib"
        let dir = acting.dir.appendingPathComponent("sibling", isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let suiteName = "\(acting.suiteName).sibling"
        let oldKey = StoreKey.mint()
        let opened = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: oldKey))
        let (view, binding) = opened.asRebindable()
        let material: DeviceKeyMaterial = acting.oldMaterial

        let storeID = "drill-sib-\(UUID().uuidString.lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setPassphraseWrap(key: oldKey, passphrase: "sesame", kdf: fastKDF())
        try envelope.setAppleWrappedCopy(key: oldKey, under: acting.apple.symmetricKey, appleKeyID: acting.apple.id)
        try envelope.setMasterWrappedCopy(key: oldKey, under: material.masterSymmetricKey)
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        #expect(StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL).save(oldKey))
        let session = SyncCustodySession()
        let keyStore = DeviceKeyStore.keychain(
            scope: scope, storeURL: storeURL, session: session,
            defaults: { UserDefaults(suiteName: suiteName)! })
        #expect(keyStore.save(material), "the sibling's plain sync record holds the OLD material")

        let dials = ScriptedDialsBox(ProtectionDials())
        let appleBacking: InMemoryAppleKeyBacking = acting.appleBacking
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
            makeKDF: { self.fastKDF() },
            syncCustodySession: session))
        let sibling = DrillWorld(
            scope: scope, dir: dir, storeURL: storeURL, backups: backups, suiteName: suiteName,
            oldKey: oldKey, apple: acting.apple, binding: binding, view: view, session: session,
            keyStore: keyStore, vaultClient: acting.vaultClient, vaultEmu: acting.vaultEmu, mirror: acting.mirror,
            gate: gate, protection: protection, storeID: storeID)
        sibling.oldMaterial = material
        sibling.words = acting.words
        sibling.appleBacking = appleBacking
        sibling.rowsPushed = acting.rowsPushed

        // Pulled to head under the old keys — the whole corpus.
        let engine = SyncEngine(transport: acting.mirror, keyProvider: DeviceKeySyncProvider(store: keyStore))
        let clock = ContinuousClock()
        var applied = 0, merged = 0
        let wall = try await clock.measure {
            try await withDependencies {
                $0.database = view
                $0.uuid = UUIDGenerator { UUID() }
                $0.date = DateGenerator { Date() }
            } operation: {
                let report = try await engine.pull()
                applied = report.applied; merged = report.merged
            }
        }
        #expect(applied + merged == acting.rowsPushed,
                "the sibling holds the whole corpus under the old key: applied \(applied), merged \(merged)")
        sibling.note("SIBLING (Standard, old keys) pulled to head in \(wall): applied \(applied), merged \(merged)")
        await protection.reconcile()
        #expect(protection.posture == .standard)
        sibling.runner = PostureSwitchRunner(leaves: leaves(for: sibling))
        return sibling
    }

    /// pre-13x 3a — A FRESH DEVICE on the account, composed as the ROOTS
    /// compose it: a fresh silent library (its own posture Standard — the
    /// key file carries only the Apple wrap under the account's A, the
    /// silent store-key item under its OWN throwaway scope, NO sync custody
    /// item, no passphrase), the real controller, a real `EncryptionSession`
    /// + `AuthSession` wired through the production `wireOneSecretHooks`,
    /// the runner over drill leaves, and the (c) join routed to the runner's
    /// follow exactly as `VariorumApp` routes it. Nothing reconciled yet —
    /// the drill's first `reconcile()` IS the enroll.
    private func makeFreshDevice(of acting: DrillWorld, label: String) async throws -> DrillWorld {
        let scope = "\(acting.scope)-\(label)"
        let dir = acting.dir.appendingPathComponent(label, isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let suiteName = "\(acting.suiteName).\(label)"
        let key = StoreKey.mint()
        let opened = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        let (view, binding) = opened.asRebindable()

        let storeID = "drill-\(label)-\(UUID().uuidString.lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setAppleWrappedCopy(key: key, under: acting.apple.symmetricKey, appleKeyID: acting.apple.id)
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        #expect(StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL).save(key), "the fresh device's silent item")
        let session = SyncCustodySession()
        let keyStore = DeviceKeyStore.keychain(
            scope: scope, storeURL: storeURL, session: session,
            defaults: { UserDefaults(suiteName: suiteName)! })
        #expect(keyStore.load() == nil, "a never-enrolled library holds no sync custody")

        let dials = ScriptedDialsBox(ProtectionDials())
        let appleBacking: InMemoryAppleKeyBacking = acting.appleBacking
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
            makeKDF: { self.fastKDF() },
            syncCustodySession: session))
        let fresh = DrillWorld(
            scope: scope, dir: dir, storeURL: storeURL, backups: backups, suiteName: suiteName,
            oldKey: key, apple: acting.apple, binding: binding, view: view, session: session,
            keyStore: keyStore, vaultClient: acting.vaultClient, vaultEmu: acting.vaultEmu, mirror: acting.mirror,
            gate: gate, protection: protection, storeID: storeID)
        fresh.oldMaterial = acting.oldMaterial
        fresh.words = acting.words
        fresh.appleBacking = appleBacking
        fresh.rowsPushed = acting.rowsPushed
        fresh.variantCount = acting.variantCount
        fresh.sampleVariant = acting.sampleVariant

        // The app seam, as the roots compose it.
        let auth = AuthSession(
            configuration: AuthConfiguration(
                projectURL: URL(string: "https://auth.2b-drill.invalid")!, apiKey: "publishable-test-key"),
            store: .inMemory(initial: AuthTokens(
                accessToken: "token-2b-drill", refreshToken: "refresh-2b-drill",
                expiresAt: Date(timeIntervalSinceNow: 86_400),
                userID: "user-2b-drill", email: "drill@test.invalid")),
            http: { _ in throw URLError(.notConnectedToInternet) })
        let encryption = EncryptionSession(store: keyStore, client: acting.vaultClient, signedIn: { true })
        wireOneSecretHooks(protection: protection, encryption: encryption, keyVault: acting.vaultClient, auth: auth)
        fresh.runner = PostureSwitchRunner(leaves: leaves(for: fresh))
        let runner: PostureSwitchRunner = fresh.runner
        protection.switchRunner = runner
        encryption.joinCastleAct = { passphrase, words in
            _ = try await runner.follow(passphrase: passphrase, recoveryWords: words)
        }
        encryption.joinStandardAct = { try await runner.followIntoStandard() }
        fresh.encryption = encryption
        fresh.auth = auth
        return fresh
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
                guard let key = protection.keyInHand() else { return .failed }
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
                    return .failed
                }
                StoreBackup.writeSnapshotKeyFile(for: url, from: StoreKeyEnvelope.locate(besideStore: world.storeURL))
                world.note("snapshot pair written: \(url.lastPathComponent)")
                return .written(url)
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

        // ————— U3 DRILL 1: THE STANDARD NEW-DEVICE ROAD (nothing typed) —————
        // A new device on the account under Standard: the Apple key (iCloud
        // Keychain) opens the vault's Apple-held copy of M; the class keys
        // follow; the whole corpus pulls — no passphrase, no words.
        // (The A half; the enroll half — the vault client's own Apple road
        // and the device's key file — is batch 3's.)
        let standardVault = try await world.vault()
        let appleOpened = try standardVault.format.unwrapMaster(withAppleKey: world.apple.symmetricKey)
        let newDeviceMaterial = try CorpusRotation.materialFollowing(standardVault.format, master: appleOpened)
        #expect(newDeviceMaterial.corpusKeyID == oldMaterial.corpusKeyID)
        let newDeviceURL = world.dir.appendingPathComponent("new-standard-device/variorum.sqlite")
        let newDevice = try AppDatabase.openStore(at: newDeviceURL, custody: .inMemory(initial: .mint()))
        let newDeviceEngine = SyncEngine(transport: world.mirror, keyProvider: DrillKeyProvider(keys: newDeviceMaterial.syncKeys))
        try await withDependencies {
            $0.database = newDevice
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
        } operation: {
            let report = try await newDeviceEngine.pull()
            #expect(report.applied + report.merged == world.rowsPushed,
                    "the new Standard device applies every row with nothing typed: applied \(report.applied), merged \(report.merged)")
            world.note("U3 DRILL 1 — STANDARD NEW DEVICE, nothing typed: the Apple key opened the vault's master copy; pulled applied \(report.applied), merged \(report.merged) of \(world.rowsPushed)")
        }

        // ————— U3 DRILL 1's ENROLL HALF (pre-13x 3a — the APP seam, nothing typed) —————
        // The same road through the production composition: a fresh silent
        // library under its own throwaway scope, signed in, never enrolled;
        // its first `reconcile()` reads the vault, A opens the Apple-held
        // copy, and the session's adopt lands custody (the REAL Keychain
        // item) + the key file's master copy + the vault's descriptor and
        // corpus id — no passphrase, no words, no face owed; then it pulls
        // to head under its own custody.
        let joiner = try await makeFreshDevice(of: world, label: "standard-joiner")
        defer { joiner.tearDown() }
        #expect(joiner.plainSyncRecord == nil, "a never-enrolled library: no custody item at all")
        let enrollClock = ContinuousClock()
        let enrollWall = await enrollClock.measure { await joiner.protection.reconcile() }
        #expect(joiner.protection.enrollReading == nil,
                "the Standard road ran silently — no face owed: \(String(describing: joiner.protection.enrollReading))")
        let joinerRecord = try #require(joiner.plainSyncRecord, "custody landed under the throwaway scope")
        #expect(joinerRecord.material?.corpusKeyID == oldMaterial.corpusKeyID && joinerRecord.material?.masterKey == oldMaterial.masterKey,
                "custody holds the account's keys")
        #expect(!joinerRecord.deviceID.isEmpty, "the device identity minted beside them")
        let joinerFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: joiner.storeURL))
        #expect(joinerFile.master != nil, "the key file carries the master copy")
        #expect(try joinerFile.unwrapKey(master: oldMaterial.masterSymmetricKey) == joiner.oldKey)
        #expect(joinerFile.vaultCorpusKeyID == oldMaterial.corpusKeyID && joinerFile.vaultKDF == standardVault.format.kdf,
                "the vault's descriptor + corpus id recorded on the key file")
        #expect(joinerFile.passphrase == nil, "nothing typed — no passphrase wrap was minted")
        #expect(joiner.encryption?.state == .enrolled(hasRecoveryWrap: false), "\(String(describing: joiner.encryption?.state))")
        let joinerEngine = SyncEngine(transport: world.mirror, keyProvider: DeviceKeySyncProvider(store: joiner.keyStore))
        try await withDependencies {
            $0.database = joiner.view
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
        } operation: {
            let report = try await joinerEngine.pull()
            #expect(report.applied + report.merged == world.rowsPushed,
                    "the enrolled device applies every row under its own custody: applied \(report.applied), merged \(report.merged)")
            joiner.note("U3 DRILL 1 — THE ENROLL HALF on the app seam: reconcile in \(enrollWall) — A opened the vault's copy; custody (the real item under the throwaway scope) + the key file's master copy + the vault's descriptor and corpus id LANDED, nothing typed, no face owed; pulled applied \(report.applied), merged \(report.merged) of \(world.rowsPushed)")
        }
        let joinerVariants = try await joiner.view.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
        }
        #expect(joinerVariants == world.variantCount, "every take arrived on the enrolled device: \(joinerVariants) of \(world.variantCount)")

        // ————— U3 DRILL 3's second device: THE SIBLING (Standard, old keys) —————
        let sibling = try await makeSibling(of: world)
        defer { sibling.tearDown() }
        // A pre-switch snapshot pair (the app's own) — the offer's subject.
        let drillLeaves = leaves(for: world)
        // F2 (MAJOR-2): the leaf answers the pair's fate; the drill needs the written URL.
        let preSwitchPair: URL
        if case .written(let url) = await drillLeaves.takeSnapshot() { preSwitchPair = url } else {
            Issue.record("the pre-switch snapshot pair was not written")
            return
        }
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
        // U3: AN OLD SNAPSHOT CANNOT ENROLL — the pre-switch pair's key file
        // still opens the OLD snapshot under the old M (backups are never
        // rewritten), but the old M is dead at the vault: no Apple-held copy
        // remains, the proof hash is M′'s, and the old keys meet the fence.
        let castleVault = try await world.vault()
        #expect(castleVault.format.masterWrappedByAppleHeld == nil, "no Apple-held copy under Castle")
        #expect(KeyProof.hash(master: oldMaterial.masterSymmetricKey) != castleVault.format.keyProofHash,
                "the old master fails the vault's proof — an old snapshot's keys enroll nothing")
        #expect(throws: (any Error).self, "the Apple key opens NO copy of M′") {
            _ = try castleVault.format.unwrapMaster(withAppleKey: world.apple.symmetricKey)
        }
        let oldPairKeyFile = try #require(try StoreKeyEnvelope.load(at: StoreBackup.pairedKeyFile(for: preSwitchPair)))
        #expect(try oldPairKeyFile.unwrapKey(master: oldMaterial.masterSymmetricKey) == world.oldKey,
                "the old snapshot pair still opens under the OLD M — never rewritten, never reaching the new keys")
        world.note("U3 — an old snapshot cannot enroll: the Apple road is closed, the old master fails the proof, the old pair opens only its own bytes")
        #expect(done.insuranceTurnedOff && !MarkdownInsurance.isEnabled(in: UserDefaults(suiteName: world.suiteName)!))
        #expect(done.preSwitchSnapshots == [preSwitchPair], "the offer lists the pre-switch pair only")
        #expect(try Data(contentsOf: preSwitchPair) == preSwitchBytes, "no backup folder rewritten")
        #expect(try Data(contentsOf: StoreBackup.pairedKeyFile(for: preSwitchPair)) == preSwitchPairKeyBytes)
        let after = try StoreBackup.existingBackups(in: world.backups)
        #expect(after.count == 2, "the fresh pair beside the old one: \(after.map(\.lastPathComponent))")
        let fresh = try #require(after.first { $0 != preSwitchPair })
        #expect(StoreBackup.shortFingerprint(fromBackupURL: fresh) == StoreKeyEnvelope.shortFingerprint(done.newKeyFingerprint))
        #expect(FileManager.default.fileExists(atPath: StoreBackup.pairedKeyFile(for: fresh).path))

        // ————— U3 DRILL 3 (the sibling) + DRILL 2 (the Castle road, passphrase once) —————
        // THE SIBLING on the old keys: refused at the fence; it FOLLOWS through
        // the REAL runner by the passphrase ONCE (§7: M′ from the vault, its
        // custody replaced, its library re-keyed, custody behind the gate,
        // pulled to head) — then a FRESH device (the Castle new-device road:
        // passphrase once, nothing else) reads the whole corpus under C′.
        let siblingOld = SyncEngine(transport: world.mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies {
            $0.database = sibling.view
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
        } operation: {
            await #expect(throws: SyncError.encryptionKeysReplaced, "the sibling's old-key pull is refused at the fence") {
                _ = try await siblingOld.pull()
            }
        }
        await #expect(throws: VaultEnrollmentError.wrongPassphrase, "a wrong word writes nothing on the sibling") {
            _ = try await sibling.runner.follow(passphrase: "not-the-passphrase", recoveryWords: nil)
        }
        #expect(sibling.keyStore.load()?.corpusKeyID == oldMaterial.corpusKeyID, "the sibling's custody unchanged after the refusal")
        // pre-13x 4b.3 (the 2c adjudication's item 4 — decision 6 per DEVICE):
        // the sibling's OWN scheduled plaintext insurance is ON before it
        // follows; the follow turns it OFF with the notice.
        MarkdownInsurance.setEnabled(true, in: UserDefaults(suiteName: sibling.suiteName)!)
        var followOutcome: PostureSwitchRunner.Outcome?
        let followWall = try await clock.measure {
            followOutcome = try await sibling.runner.follow(passphrase: "sesame", recoveryWords: nil)
        }
        let followedOutcome = try #require(followOutcome)
        #expect(followedOutcome.insuranceTurnedOff && !MarkdownInsurance.isEnabled(in: UserDefaults(suiteName: sibling.suiteName)!),
                "4b.3: the FOLLOWER's own insurance turned OFF as it entered Castle")
        let followed = try #require(followedOutcome.material)
        sibling.note("U3 DRILL 3 — the SIBLING FOLLOWED (passphrase once) in \(followWall): re-encrypted \(followedOutcome.reencrypted) rows (the acting device had finished the walk); rekeys \(sibling.rekeys); insurance off: \(followedOutcome.insuranceTurnedOff); offer: \(followedOutcome.preSwitchSnapshots.count) pairs")
        #expect(followedOutcome.entersCastle)
        #expect(followed.corpusKeyID == done.material?.corpusKeyID && followed.rotation == nil)
        #expect(followedOutcome.reencrypted == 0, "nothing left to re-encrypt: \(followedOutcome.reencrypted)")
        #expect(sibling.rekeys == 1, "the sibling's library re-keyed as it followed")
        #expect(sibling.protection.posture == .castle, "the sibling's posture: \(sibling.protection.posture)")
        #expect(sibling.silentStoreKey == nil, "the sibling's silent store-key item is gone")
        #expect(sibling.plainSyncRecord?.material == nil && sibling.plainSyncRecord?.deviceID != nil,
                "the sibling's sync keys left the plain item; its identity stays")
        #expect(sibling.session.record?.material?.corpusKeyID == followed.corpusKeyID, "the sibling's session holds M′ / C′")
        let siblingFile = try #require(try StoreKeyEnvelope.load(
            at: StoreKeyEnvelope.url(besideStore: sibling.storeURL, fingerprint: followedOutcome.newKeyFingerprint)))
        #expect(siblingFile.apple == nil, "the sibling's new key file carries no Apple copy")
        #expect(StoreEncryptionMigration.opens(sibling.storeURL, key: try siblingFile.unwrapKey(passphrase: "sesame")))
        #expect(!StoreEncryptionMigration.opens(sibling.storeURL, key: sibling.oldKey), "the sibling's old library key opens nothing")
        #expect(try await sibling.marker() == nil)
        let siblingNew = SyncEngine(transport: world.mirror, keyProvider: DeviceKeySyncProvider(store: sibling.keyStore))
        try await withDependencies {
            $0.database = sibling.view
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
        } operation: {
            let report = try await siblingNew.pull()
            sibling.note("the followed sibling's next pull: applied \(report.applied), merged \(report.merged), cursor \(report.newCursor)")
        }
        let siblingVariants = try await sibling.view.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
        }
        #expect(siblingVariants == world.variantCount, "the sibling kept every take through the follow: \(siblingVariants) of \(world.variantCount)")
        world.note("U3 DRILL 2 — THE CASTLE NEW-DEVICE ROAD, passphrase once: a fresh device enrolls by the passphrase and pulls the corpus under C′")
        let freshURL = world.dir.appendingPathComponent("fresh/variorum.sqlite")
        let freshStore = try AppDatabase.openStore(at: freshURL, custody: .inMemory(initial: .mint()))
        let freshEnrolled = try await VaultEnrollment(client: world.vaultClient).enroll(passphrase: "sesame")
        #expect(freshEnrolled.corpusKeyID == followed.corpusKeyID && freshEnrolled.rotation == nil)
        let freshEngine = SyncEngine(transport: world.mirror, keyProvider: DrillKeyProvider(keys: freshEnrolled.syncKeys))
        try await withDependencies {
            $0.database = freshStore
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
        } operation: {
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
        // ————— U3 DRILL 2's APP SEAM (pre-13x 3a — a fresh silent library joining CASTLE, the passphrase ONCE) —————
        // The (c) direction through the production composition: the first
        // reconcile owes the join face (no silent road under a Castle
        // account); ONE passphrase entry at the Encryption tab's door routes
        // to the runner's follow — M′ from the vault, custody landed, the
        // library re-keyed, the key file carrying the master copy + the
        // vault's descriptor and NO Apple copy, custody behind the gate —
        // then it pulls the whole corpus under C′.
        let castleJoiner = try await makeFreshDevice(of: world, label: "castle-joiner")
        defer { castleJoiner.tearDown() }
        await castleJoiner.protection.reconcile()
        #expect(castleJoiner.protection.enrollReading == EnrollFacts(accountPosture: .castle, libraryPosture: .standard, appleState: .notApplicable),
                "the (c) face owed at ready: \(String(describing: castleJoiner.protection.enrollReading))")
        #expect(castleJoiner.plainSyncRecord == nil && castleJoiner.session.record == nil, "nothing landed before the word")
        let castleEncryption = try #require(castleJoiner.encryption)
        await castleEncryption.enroll(passphrase: "not-the-passphrase")
        #expect(castleEncryption.lastError != nil && castleJoiner.plainSyncRecord == nil && castleJoiner.session.record == nil,
                "a wrong word lands nothing: \(castleEncryption.lastError ?? "no refusal")")
        let joinWall = await clock.measure { await castleEncryption.enroll(passphrase: "sesame") }
        #expect(castleEncryption.lastError == nil, "\(castleEncryption.lastError ?? "")")
        #expect(castleJoiner.rekeys == 1, "the fresh library re-keyed as it joined: \(castleJoiner.rekeys)")
        #expect(castleJoiner.protection.posture == .castle, "the joiner's posture: \(castleJoiner.protection.posture)")
        #expect(castleJoiner.silentStoreKey == nil, "the joiner's silent item is gone")
        #expect(castleJoiner.plainSyncRecord?.material == nil && castleJoiner.plainSyncRecord?.deviceID != nil,
                "the joiner's sync keys never touched the plain item; its identity sits there")
        #expect(castleJoiner.session.record?.material?.corpusKeyID == followed.corpusKeyID, "the joiner's session holds M′ / C′")
        let vaultNow = try await world.vault()
        let castleJoinerFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: castleJoiner.storeURL))
        #expect(castleJoinerFile.apple == nil && castleJoinerFile.appleKeyID == nil, "no Apple copy on a Castle key file")
        #expect(castleJoinerFile.master != nil && castleJoinerFile.vaultCorpusKeyID == followed.corpusKeyID && castleJoinerFile.vaultKDF == vaultNow.format.kdf,
                "the master copy + the vault's descriptor and corpus id landed")
        let castleJoinerKey = try castleJoinerFile.unwrapKey(passphrase: "sesame")
        #expect(StoreEncryptionMigration.opens(castleJoiner.storeURL, key: castleJoinerKey), "the re-keyed library opens under the passphrase")
        #expect(try castleJoinerFile.unwrapKey(master: followed.masterSymmetricKey) == castleJoinerKey, "…and under M′")
        #expect(!StoreEncryptionMigration.opens(castleJoiner.storeURL, key: castleJoiner.oldKey), "the fresh library's old key opens nothing")
        let castleJoinerEngine = SyncEngine(transport: world.mirror, keyProvider: DeviceKeySyncProvider(store: castleJoiner.keyStore))
        try await withDependencies {
            $0.database = castleJoiner.view
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { Date() }
        } operation: {
            let report = try await castleJoinerEngine.pull()
            #expect(report.applied + report.merged == world.rowsPushed,
                    "the joined device applies every row under C′: applied \(report.applied), merged \(report.merged)")
            castleJoiner.note("U3 DRILL 2 — THE CASTLE NEW-DEVICE ROAD on the app seam, the passphrase ONCE: joined in \(joinWall) (re-keyed \(castleJoiner.rekeys)×); the key file carries the master copy + the vault's descriptor, no Apple copy; custody behind the gate; pulled applied \(report.applied), merged \(report.merged) of \(world.rowsPushed)")
        }
        let castleJoinerVariants = try await castleJoiner.view.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
        }
        #expect(castleJoinerVariants == world.variantCount, "every take arrived on the joined device: \(castleJoinerVariants) of \(world.variantCount)")
        if let sample = world.sampleVariant {
            let text = try await castleJoiner.view.read { db in
                try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [sample.id])
            }
            #expect(text == sample.text, "a sampled take reads back byte-for-byte on the joined device")
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
        world.note("U3 DRILL 4 — CASTLE → STANDARD: the Apple-held copies are back, custody silent, nothing rotated")

        // The SIBLING follows into Standard SILENTLY (§7 — nothing typed):
        // its key file gains the Apple copy, its custody moves silent.
        let siblingFollowWall = try await clock.measure {
            try await sibling.runner.followIntoStandard()
        }
        sibling.note("the sibling followed into Standard in \(siblingFollowWall)")
        #expect(sibling.protection.posture == .standard, "the sibling's posture: \(sibling.protection.posture)")
        let siblingStandardFile = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: sibling.storeURL))
        #expect(siblingStandardFile.appleKeyID == world.apple.id)
        #expect(try siblingStandardFile.unwrapKey(apple: world.apple.symmetricKey) == sibling.protection.keyInHand())
        #expect(sibling.silentStoreKey == sibling.protection.keyInHand(), "the sibling's silent item holds its key again")
        #expect(sibling.plainSyncRecord?.material?.corpusKeyID == followed.corpusKeyID, "the sibling's plain sync record is back")
        world.note("DONE — log lines: \(world.log.value.count) (+ \(sibling.log.value.count) sibling lines)")
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
