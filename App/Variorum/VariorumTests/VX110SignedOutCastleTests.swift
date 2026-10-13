//
//  VX110SignedOutCastleTests.swift
//  VariorumTests
//
//  VX-110 — Use Castle on a library signed OUT of the sync account it still
//  holds the keys for (RUN VX-201, unit U2; the trace: auditor A's VX-110
//  section + notes/plans/fixes/vx-191-encryption-audit.md §W/§W.1; the brief
//  and the record: notes/plans/fixes/vx-201-castle-prelaunch-fixes.md §D and
//  "U2 RECORD (VX-110)").
//
//  THE DEFECT: the runner's local road ran for that library — the vault and
//  the server stayed Standard, the account's key material stayed in custody
//  (moved behind the gate), the Done claimed the account-wide switch, and the
//  next signed-in ready's follow-into-Standard silently re-added the Apple
//  copy and moved custody silent. A SECOND silent road found here (F-U2-1):
//  with the material forgotten, the reconcile's Apple arm still landed the
//  key file's Apple copy under the account's Standard word, before any
//  consent.
//
//  THE PINS (each red on the pre-fix code by the behavioral revert the record
//  names; the bounds say so):
//   (a) the two doors stand exactly where the silent revert was reachable —
//       signed out with key MATERIAL held; never for a pre-sync library, an
//       identity-only one, or an enrolled signed-in one; the runner's belt
//       refuses the old road; Sign In… ends the ceremony writing nothing;
//   (b) This Mac Only, then signing into the OLD account, lands the join
//       consent — never the follow, never an Apple copy; the route keeps the
//       Castle gate (the identity-only record);
//   (c) a This-Mac-Only road killed mid-way: the forget already happened, the
//       resume carries it for material that came back, and the Done stays
//       honest across the crash;
//   (d) BOUND — forgetting one library's sync keys leaves another library's
//       custody whole (per-store-id items; a throwaway Keychain scope);
//   (e) BOUND — sync set up from the This-Mac-Only library births a CASTLE
//       account (her carried-forward reminder 1: the road the audit never ran);
//   (f) the This-Mac-Only screens and Done never speak the account-wide words;
//   (item 2) the rekey banners and the sync row name the pending marker's act.
//
//  Scripted Keychain backings everywhere but (d), which writes under a
//  throwaway scope the tripwire allows (the store-key family's precedent).
//

import CryptoKit
import Dependencies
import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-110 — signed out with the sync keys held, Use Castle offers two doors and never reverts silently", .serialized)
struct VX110SignedOutCastleTests {
    private let passphrase = "orchard-lantern-110"

    enum RekeyFault { case beforeWork, afterReopen }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func withDeps<T>(_ body: @MainActor () async throws -> T) async rethrows -> T {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_950_400))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            try await body()
        }
    }

    // MARK: - The world: her library, once synced, now signed out

    @MainActor
    final class World {
        let dir: URL
        let storeURL: URL
        let storeID: String
        let oldKey: StoreKey
        let apple: AppleKey
        let backing: InMemoryStoreKeyGuardBacking
        let appleBacking: InMemoryAppleKeyBacking
        let syncLeaves: RecordingSyncLeaves
        let syncSession: SyncCustodySession
        let keyStore: DeviceKeyStore
        let pending: ScriptedSwitchPendingBox
        let gate: StoreLaunchGate
        let defaults: UserDefaults
        let suiteName: String
        let currentKey: LockIsolated<StoreKey>
        let signedIn: LockIsolated<Bool>
        let bootstrap: AppBootstrap
        /// The OLD account: Standard (the vault carries an Apple-held copy).
        let oldVault: EmulatedVault?
        let oldClient: KeyVaultClient?
        let oldMaterial: DeviceKeyMaterial?
        let encryption: EncryptionSession
        var runner: PostureSwitchRunner!
        var rekeyFault: RekeyFault?
        var protection: ProtectionController { bootstrap.protection }

        init(dir: URL, storeURL: URL, storeID: String, oldKey: StoreKey, apple: AppleKey,
             backing: InMemoryStoreKeyGuardBacking, appleBacking: InMemoryAppleKeyBacking,
             syncLeaves: RecordingSyncLeaves, syncSession: SyncCustodySession, keyStore: DeviceKeyStore,
             pending: ScriptedSwitchPendingBox, gate: StoreLaunchGate, defaults: UserDefaults, suiteName: String,
             currentKey: LockIsolated<StoreKey>, signedIn: LockIsolated<Bool>, bootstrap: AppBootstrap,
             oldVault: EmulatedVault?, oldClient: KeyVaultClient?, oldMaterial: DeviceKeyMaterial?,
             encryption: EncryptionSession) {
            self.dir = dir; self.storeURL = storeURL; self.storeID = storeID; self.oldKey = oldKey
            self.apple = apple; self.backing = backing; self.appleBacking = appleBacking
            self.syncLeaves = syncLeaves; self.syncSession = syncSession; self.keyStore = keyStore
            self.pending = pending; self.gate = gate; self.defaults = defaults; self.suiteName = suiteName
            self.currentKey = currentKey; self.signedIn = signedIn; self.bootstrap = bootstrap
            self.oldVault = oldVault; self.oldClient = oldClient; self.oldMaterial = oldMaterial
            self.encryption = encryption
        }

        func tearDown() {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: dir)
        }

        /// The key file beside the library NOW (the newest — `locate`'s rule).
        func liveKeyFile() throws -> StoreKeyEnvelope {
            try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
        }

        func marker() async throws -> RotationMarker? {
            guard case .ready(let session) = bootstrap.state else { return nil }
            return try await session.database.read { try RotationMarker.read($0) }
        }

        var thisDeviceOnlyFlag: Bool {
            ProtectionDefaults.thisDeviceOnlySwitch(
                scope: AppDatabase.StoreVariant.dev.rawValue, storeID: storeID, in: defaults)
        }
    }

    /// The custody shapes a world starts in.
    enum Custody {
        /// Synced once: the old account's material in the silent item.
        case material
        /// Never synced: no custody record at all.
        case none
        /// After a forget: the identity alone.
        case identityOnly
    }

    /// A real keyed store at `storeURL` with one note, its pool closed.
    private func seedStore(at storeURL: URL, key: StoreKey) async throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let store = try AppDatabase.onDisk(url: storeURL, key: key)
        try await store.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                arguments: ["vx110-note", "written before Castle", "2026-10-13T00:00:00Z", "2026-10-13T00:00:00Z"])
        }
        store.asRebindable().binding.lock()
    }

    private func opener(
        storeURL: URL, candidate: LockIsolated<StoreKey>, fallback: StoreKey
    ) -> @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError> {
        {
            let key = StoreEncryptionMigration.opens(storeURL, key: candidate.value) ? candidate.value : fallback
            return Result {
                try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
            }.mapError { error in
                error as? AppDatabase.StoreOpenError
                    ?? AppDatabase.StoreOpenError(storePath: storeURL.path, reason: String(describing: error))
            }
        }
    }

    private func vaultClient(_ vault: EmulatedVault, user: String) -> KeyVaultClient {
        KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.vx110.invalid")!,
                apiKey: "publishable-test-key", deviceName: "test device"),
            sessionProvider: StaticSessionProvider(session: UserSession(accessToken: "token-\(user)", userID: user)),
            load: vault.load)
    }

    private func auth(user: String) -> AuthSession {
        AuthSession(
            configuration: AuthConfiguration(projectURL: URL(string: "https://auth.vx110.invalid")!, apiKey: "k"),
            store: .inMemory(initial: AuthTokens(
                accessToken: "token-\(user)", refreshToken: "refresh", expiresAt: Date(timeIntervalSinceNow: 86_400),
                userID: user, email: "\(user)@test.invalid")),
            http: { _ in throw URLError(.notConnectedToInternet) })
    }

    /// Her library before Use Castle: STANDARD — the key file carries a
    /// passphrase copy, the Apple copy and (once synced) the master copy with
    /// the vault's record; the raw key in the silent item; A readable; Touch
    /// ID exists. `custody` says what the per-store sync custody holds;
    /// `signedIn` whether a session exists. The runner rides the PRODUCTION
    /// re-key road (`bootstrap.rekeyLibrary`), the PRODUCTION custody move
    /// (`protection.moveCustody`) and the PRODUCTION forget
    /// (`EncryptionSession.forgetDeviceKeys`) over ONE custody the controller
    /// and the session share.
    private func makeWorld(custody: Custody = .material, signedIn: Bool = false) async throws -> World {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx110-\(UUID().uuidString)", isDirectory: true)
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let oldKey = StoreKey.mint()
        try await seedStore(at: storeURL, key: oldKey)
        let apple = AppleKey.mint()
        let appleBacking = InMemoryAppleKeyBacking(key: apple)

        // The OLD account (Standard): set up, then the Apple-held copy landed.
        var oldVault: EmulatedVault?
        var oldClient: KeyVaultClient?
        var oldMaterial: DeviceKeyMaterial?
        var vaultKDF: PassphraseKDF.Descriptor?
        if custody != .none || signedIn {
            let emu = EmulatedVault(claimRotationSeq: { 0 })
            let client = vaultClient(emu, user: "user-old")
            let minted = try await VaultEnrollment(client: client).setUp(passphrase: passphrase)
            let fetched = try #require(try await client.fetchVault())
            try await client.updateVault(
                try fetched.format.settingAppleHeldCopy(
                    masterKey: minted.masterSymmetricKey, appleKey: apple.symmetricKey, appleKeyID: apple.id),
                expectedRevision: fetched.revision,
                keyProof: KeyProofMaterial(master: minted.masterSymmetricKey))
            oldVault = emu; oldClient = client; oldMaterial = minted
            vaultKDF = fetched.format.kdf
        }

        let storeID = "vx110-\(UUID().uuidString.prefix(8).lowercased())"
        var envelope = StoreKeyEnvelope(storeID: storeID)
        try envelope.setPassphraseWrap(key: oldKey, passphrase: passphrase, kdf: fastKDF())
        try envelope.setAppleWrappedCopy(key: oldKey, under: apple.symmetricKey, appleKeyID: apple.id)
        if let oldMaterial, custody == .material {
            try envelope.setMasterWrappedCopy(key: oldKey, under: oldMaterial.masterSymmetricKey)
            try envelope.recordVaultReconciliation(
                kdf: vaultKDF, corpusKeyID: oldMaterial.corpusKeyID, recoveryWrapDigest: nil)
        }
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let backing = InMemoryStoreKeyGuardBacking(auto: oldKey, biometryAvailable: true, biometricSucceeds: true)
        let syncLeaves: RecordingSyncLeaves
        switch custody {
        case .material:
            syncLeaves = RecordingSyncLeaves(plain: SyncCustodyRecord(deviceID: "device-vx110", material: oldMaterial))
        case .none:
            syncLeaves = RecordingSyncLeaves()
        case .identityOnly:
            syncLeaves = RecordingSyncLeaves(plain: SyncCustodyRecord(deviceID: "device-vx110", material: nil))
        }
        let syncSession = SyncCustodySession()
        // ONE custody, read by the controller (its leaves) and the runner /
        // the session (this store): the shape follows the library key's.
        let keyStore = DeviceKeyStore.custody(
            leaves: { syncLeaves.leaves },
            shape: { backing.auto != nil ? .silent : .biometric },
            session: syncSession)
        let pending = ScriptedSwitchPendingBox()
        let dials = ScriptedDialsBox(ProtectionDials())
        let gate = StoreLaunchGate(
            dials: { _, id in dials.dials(for: id) },
            saveDials: { new, _, id in dials.save(new, for: id) },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in StoreKeyGuard.inMemory(backing: backing) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: appleBacking) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in },
            // Production's reading: the bound record (identity INCLUDED) or the gated probe.
            syncCustodyPresent: { _, _ in syncLeaves.plainRecord != nil || syncLeaves.gatedRecord != nil },
            switchPending: { _, id in pending.isPending(id) },
            setSwitchPending: { value, _, id in pending.set(value, for: id) })
        let currentKey = LockIsolated(oldKey)
        let bootstrap = AppBootstrap(
            testOpener: opener(storeURL: storeURL, candidate: currentKey, fallback: oldKey),
            gate: gate, testPresence: .encryptedOrUnknown, testStoreURL: storeURL,
            syncCustodyLeaves: { _ in syncLeaves.leaves }, syncCustodySession: syncSession)
        await bootstrap.awaitOpen()
        guard case .ready(let session) = bootstrap.state else {
            Issue.record("the Standard library opens silently: \(bootstrap.state)")
            throw CancellationError()
        }
        let suiteName = "io.lduarte.variorum.tests.vx110.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let signedInBox = LockIsolated(signedIn)
        let encryption = EncryptionSession(store: keyStore, client: oldClient, signedIn: { signedInBox.value })
        let world = World(
            dir: dir, storeURL: storeURL, storeID: storeID, oldKey: oldKey, apple: apple, backing: backing,
            appleBacking: appleBacking, syncLeaves: syncLeaves, syncSession: syncSession, keyStore: keyStore,
            pending: pending, gate: gate, defaults: defaults, suiteName: suiteName, currentKey: currentKey,
            signedIn: signedInBox, bootstrap: bootstrap, oldVault: oldVault, oldClient: oldClient,
            oldMaterial: oldMaterial, encryption: encryption)
        let protection = bootstrap.protection
        world.runner = PostureSwitchRunner(leaves: PostureSwitchRunner.Leaves(
            scope: AppDatabase.StoreVariant.dev.rawValue,
            storeURL: storeURL,
            database: session.database,
            gate: gate,
            keyStore: keyStore,
            keyProvider: DeviceKeySyncProvider(store: keyStore),
            vault: oldClient,
            transport: oldClient == nil ? nil : EmulatedMirror(),
            signedIn: { signedInBox.value },
            appleKeys: AppleKeyLeaves.inMemory(backing: appleBacking),
            libraryKeyInHand: { protection.keyInHand() },
            posture: { protection.posture },
            alwaysAsk: { protection.dials.alwaysAsk },
            biometryAvailable: { protection.biometryAvailable },
            moveCustody: { target in await protection.moveCustody(to: target) },
            rekeyLibrary: { [weak world] old, new, work in
                if world?.rekeyFault == .beforeWork {
                    world?.rekeyFault = nil
                    throw URLError(.cancelled)
                }
                currentKey.setValue(new)
                try await bootstrap.rekeyLibrary(from: old, to: new, work: work)
                if world?.rekeyFault == .afterReopen {
                    world?.rekeyFault = nil
                    throw URLError(.cancelled)
                }
            },
            pauseSync: {},
            resumeSync: {},
            takeSnapshot: { .notKept },
            preSwitchSnapshots: { _ in [] },
            deleteSnapshotPairs: { _ in 0 },
            defaults: { UserDefaults(suiteName: suiteName)! },
            reconcile: { await protection.reconcile() },
            now: { Date(timeIntervalSince1970: 1_782_950_400) },
            log: { _ in },
            endSwitch: { bootstrap.endSwitch() },
            forgetSyncKeys: { await encryption.forgetDeviceKeys() }))
        return world
    }

    /// The model's whole road for This Mac Only: the door, the second door,
    /// the this-device explain, the fresh words, the floor, the act.
    private func runThisMacOnlyThroughTheModel(_ world: World) async throws -> PostureSwitchModel {
        let model = PostureSwitchModel(mode: .enter, runner: world.runner, controller: world.protection, vaultTie: nil)
        await model.start()
        guard model.phase == .signedOutChoice else {
            Issue.record("the two doors first: \(model.phase)")
            throw CancellationError()
        }
        model.chooseThisDeviceOnly()
        #expect(model.phase == .explain && model.thisDeviceOnly)
        model.continueFromExplain()
        guard case .wordsShow(let words) = model.phase else {
            Issue.record("the twelve words are shown: \(model.phase)")
            throw CancellationError()
        }
        model.acknowledgeWordsWritten()
        model.confirmWords(words.joined(separator: " "))
        #expect(model.phase == .floor(needsPassphrase: true), "\(model.phase)")
        await model.enterCastle(passphrase: passphrase, acknowledged: true)
        guard case .done = model.phase else {
            Issue.record("This Mac Only finishes: \(model.phase) \(model.lastError ?? "")")
            throw CancellationError()
        }
        return model
    }

    // MARK: - (a) the doors stand exactly where the silent revert was reachable

    /// RED ON OLD (the record's R-a — the model's fork and the runner's belt
    /// reverted): the signed-out library holding its keys went straight to
    /// Screen 1, and the runner ran the old silent road (no refusal).
    @Test func theTwoDoorsStandExactlyWhereTheSilentRevertWasReachable() async throws {
        try await withDeps {
            // Signed out, the old account's material held: the two doors.
            let held = try await makeWorld(custody: .material, signedIn: false)
            defer { held.tearDown() }
            let model = PostureSwitchModel(mode: .enter, runner: held.runner, controller: held.protection, vaultTie: nil)
            await model.start()
            #expect(model.phase == .signedOutChoice, "signed out with the sync keys held: the two doors: \(model.phase)")
            // Sign In… ends the ceremony, writing nothing.
            model.chooseSignIn()
            #expect(model.phase == .signInChosen)
            #expect(try await held.marker() == nil, "no marker")
            #expect(held.syncLeaves.plainRecord?.material == held.oldMaterial, "the keys untouched")
            #expect(held.backing.auto == held.oldKey && held.backing.gated == nil, "custody untouched")
            #expect(try held.liveKeyFile().apple != nil, "the library still Standard")

            // The runner's belt: Use Castle's old road is refused, nothing written.
            await #expect(throws: PostureSwitchError.signInOrThisDeviceOnly) {
                _ = try await held.runner.enterCastle(passphrase: passphrase, recoveryWords: try RecoveryPhrase.generate())
            }
            #expect(try await held.marker() == nil && held.syncLeaves.plainRecord?.material == held.oldMaterial)
            #expect(StoreEncryptionMigration.opens(held.storeURL, key: held.oldKey), "the library under its old key")
            #expect(try held.liveKeyFile().keyFingerprint == StoreKeyEnvelope.fingerprint(of: held.oldKey),
                    "no new key file")
            #expect(PostureSwitchModel.message(for: PostureSwitchError.signInOrThisDeviceOnly)
                    == ProtectionCopy.signedOutChoiceBody)

            // A session lapsing DURING the screens (signed in at the door,
            // signed out at the act): the belt refuses and the model re-offers
            // the two doors — nothing written.
            held.signedIn.setValue(true)
            let lapsed = PostureSwitchModel(mode: .enter, runner: held.runner, controller: held.protection, vaultTie: nil)
            await lapsed.start()
            #expect(lapsed.phase == .explain, "signed in at the door: Screen 1 (\(lapsed.phase))")
            lapsed.continueFromExplain()
            guard case .wordsShow(let words) = lapsed.phase else {
                Issue.record("the words screen: \(lapsed.phase)")
                return
            }
            lapsed.acknowledgeWordsWritten()
            lapsed.confirmWords(words.joined(separator: " "))
            held.signedIn.setValue(false)
            await lapsed.enterCastle(passphrase: passphrase, acknowledged: true)
            #expect(lapsed.phase == .signedOutChoice, "the doors, re-offered: \(lapsed.phase)")
            #expect(try await held.marker() == nil && held.syncLeaves.plainRecord?.material == held.oldMaterial,
                    "nothing written")

            // Never synced: no doors (decision 8's pre-sync library keeps §4's local road).
            let fresh = try await makeWorld(custody: .none, signedIn: false)
            defer { fresh.tearDown() }
            let freshModel = PostureSwitchModel(mode: .enter, runner: fresh.runner, controller: fresh.protection, vaultTie: nil)
            await freshModel.start()
            #expect(freshModel.phase == .explain, "a pre-sync library: Screen 1 as ever: \(freshModel.phase)")

            // After a forget (the identity alone): no doors — the material is the fact.
            let forgotten = try await makeWorld(custody: .identityOnly, signedIn: false)
            defer { forgotten.tearDown() }
            let forgottenModel = PostureSwitchModel(mode: .enter, runner: forgotten.runner, controller: forgotten.protection, vaultTie: nil)
            await forgottenModel.start()
            #expect(forgottenModel.phase == .explain, "an identity-only record re-triggers nothing: \(forgottenModel.phase)")

            // Enrolled and signed in: the account-wide road (Screen 1), no doors.
            let enrolled = try await makeWorld(custody: .material, signedIn: true)
            defer { enrolled.tearDown() }
            let enrolledModel = PostureSwitchModel(mode: .enter, runner: enrolled.runner, controller: enrolled.protection, vaultTie: nil)
            await enrolledModel.start()
            #expect(enrolledModel.phase == .explain, "enrolled + signed in: the full road: \(enrolledModel.phase)")
            #expect(!enrolledModel.thisDeviceOnly)
        }
    }

    // MARK: - (b) This Mac Only, then the OLD account: the consent, never a revert

    /// THE NAMED PIN. Signed out with the old (Standard) account's keys held:
    /// This Mac Only through the model's whole road; then she signs into the
    /// OLD account and the ready reconciles over production's own wiring
    /// (`wireOneSecretHooks`, the follow-into-Standard act on the runner).
    /// RED ON OLD — R-b1 (the forget removed): the material rides behind the
    /// gate, and the reconcile's follow-into-Standard re-adds the Apple copy
    /// and moves custody silent (her Castle undone). R-b2 (the Apple arm's
    /// consent guard removed): the reconcile lands the key file's Apple copy
    /// before any consent (F-U2-1).
    @Test func thisMacOnlyThenSigningIntoTheOldAccountLandsTheConsentNeverTheFollow() async throws {
        try await withDeps {
            let world = try await makeWorld(custody: .material, signedIn: false)
            defer { world.tearDown() }
            let oldClient = try #require(world.oldClient)
            let vaultBefore = try #require(try await oldClient.fetchVault())

            let model = try await runThisMacOnlyThroughTheModel(world)
            let outcome = try #require(model.outcome)
            #expect(outcome.entersCastle && outcome.thisDeviceOnly && outcome.material == nil)
            #expect(model.doneBody == ProtectionCopy.enteredCastleThisDeviceOnlyDone(.notKept), "\(model.doneBody)")

            // The old account's keys are forgotten here; the identity stays.
            #expect(world.syncLeaves.plainRecord?.material == nil, "the material is gone from the bound item")
            #expect(world.syncLeaves.plainRecord?.deviceID == "device-vx110", "the identity stays")
            #expect(world.syncLeaves.gatedRecord == nil, "nothing rode behind the gate")
            #expect(world.syncSession.record?.material == nil)
            // The library is Castle: L′ behind Touch ID, no Apple copy.
            let newKey = try #require(world.backing.gated)
            #expect(world.backing.auto == nil && newKey != world.oldKey)
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: newKey))
            let file = try world.liveKeyFile()
            #expect(file.apple == nil && file.passphrase != nil && file.master == nil)
            // U1's machinery rode the local road: the flag spanned the custody move, then cleared.
            #expect(world.pending.writes.contains { $0.storeID == world.storeID && $0.pending })
            #expect(!world.pending.isPending(world.storeID), "the switch-pending flag cleared at the end")
            #expect(!world.bootstrap.switchInProgress, "gate i cleared once custody landed")
            #expect(!world.thisDeviceOnlyFlag, "the This-Mac-Only flag cleared with the marker")
            #expect(try await world.marker() == nil)
            // The old account is untouched — the honest Done's claim.
            let vaultAfter = try #require(try await oldClient.fetchVault())
            #expect(vaultAfter.revision == vaultBefore.revision && vaultAfter.format.masterWrappedByAppleHeld != nil,
                    "the account and its server copy are unchanged")
            // The ROUTE keeps the Castle gate: the identity-only record reads
            // enrolled, so the shape decides and the landing arm is skipped.
            #expect(world.gate.effectiveGate(scope: "Variorum-dev", storeID: world.storeID, storeURL: world.storeURL)
                    == .biometric)
            #expect(try world.liveKeyFile().apple == nil, "the route landed nothing")

            // SHE SIGNS INTO THE OLD ACCOUNT — production's wiring.
            world.signedIn.setValue(true)
            wireOneSecretHooks(protection: world.protection, encryption: world.encryption,
                               keyVault: oldClient, auth: auth(user: "user-old"))
            world.protection.followIntoStandardAct = { try await world.runner.followIntoStandard() }
            world.encryption.joinStandardAct = { try await world.runner.followIntoStandard() }
            await world.protection.reconcile()

            #expect(world.protection.enrollReading
                    == EnrollFacts(accountPosture: .standard, libraryPosture: .castle, appleState: .matched),
                    "the join consent's facts: \(String(describing: world.protection.enrollReading))")
            #expect(world.encryption.enrollFacts?()?.castleBornJoinsStandard == true, "the tab renders the consent")
            #expect(world.protection.movedToStandardNotice == nil && world.protection.followNotice == nil,
                    "no follow ran")
            #expect(try world.liveKeyFile().apple == nil, "no Apple copy landed before the consent (F-U2-1)")
            #expect(world.backing.gated == newKey && world.backing.auto == nil, "custody stayed behind the gate")
            #expect(world.syncLeaves.plainRecord?.material == nil && world.syncLeaves.gatedRecord == nil,
                    "no key material landed")
            await world.encryption.refresh()
            if case .notEnrolled = world.encryption.state {} else {
                Issue.record("the Encryption tab reads not enrolled — the consent's arm: \(world.encryption.state)")
            }

            // The lobby's typed word, held under the NEW key file's descriptor,
            // opens nothing of the old account's (the fresh salt) — no silent enroll.
            let kdf = try #require(try world.liveKeyFile().passphrase?.kdf)
            world.syncSession.holdDerivedWrappingKey(
                try PassphraseKDF.deriveKey(passphrase: passphrase, descriptor: kdf), kdf: kdf)
            await world.protection.reconcile()
            #expect(world.syncLeaves.plainRecord?.material == nil && world.syncLeaves.gatedRecord == nil
                    && world.syncSession.record?.material == nil, "the held word enrolled nothing")
            #expect(try world.liveKeyFile().apple == nil && world.backing.auto == nil)

            // Cancel keeps it so at every ready.
            world.encryption.declineStandardJoin()
            await world.protection.reconcile()
            #expect(try world.liveKeyFile().apple == nil && world.backing.gated == newKey)
        }
    }

    // MARK: - (c) a This-Mac-Only road killed mid-way

    /// Killed BEFORE the swap (the new key file written, the library still
    /// Standard-shaped under L): the forget already happened — so a
    /// signed-in relaunch's silent Standard enroll is what can re-land the
    /// old account's material here. Planted, then the resume: it FORGETS
    /// before finishing, and the Done is This Mac Only's. RED ON OLD — R-c
    /// (the resume's forget arm removed): the material survives the resume
    /// and the custody move carries it behind the gate (the silent revert's
    /// precondition, again).
    @Test func aThisMacOnlyRoadKilledBeforeItsSwapFinishesWithTheOldAccountsKeysForgotten() async throws {
        try await withDeps {
            let world = try await makeWorld(custody: .material, signedIn: false)
            defer { world.tearDown() }
            let material = try #require(world.oldMaterial)
            let words = try RecoveryPhrase.generate()
            world.rekeyFault = .beforeWork
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: passphrase, recoveryWords: words, thisDeviceOnly: true)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .rekeyLibrary && marker.entersCastle && !marker.isFollow && marker.newCorpusKeyID == nil,
                    "the local road's marker")
            #expect(world.syncLeaves.plainRecord?.material == nil, "forget-first: gone before the first marker")
            #expect(world.thisDeviceOnlyFlag, "the flag the resume reads")
            #expect(StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "killed before the swap")

            // What a signed-in relaunch's silent Standard enroll would land.
            #expect(world.syncLeaves.leaves.savePlain(SyncCustodyRecord(deviceID: "device-vx110", material: material)))
            #expect(world.keyStore.load() == material)

            let outcome = try await world.runner.resume(passphrase: passphrase, recoveryWords: words)
            #expect(outcome.entersCastle && outcome.thisDeviceOnly, "\(outcome)")
            #expect(world.syncLeaves.plainRecord?.material == nil && world.syncLeaves.gatedRecord == nil,
                    "the resume forgot the material before finishing")
            #expect(world.syncSession.record?.material == nil)
            #expect(world.backing.auto == nil && world.backing.gated != nil, "custody behind the gate")
            #expect(try world.liveKeyFile().apple == nil)
            #expect(try await world.marker() == nil && !world.thisDeviceOnlyFlag)
            #expect(ProtectionCopy.ceremonyDoneBody(act: CeremonyAct(resuming: marker), outcome: outcome)
                    == ProtectionCopy.enteredCastleThisDeviceOnlyDone(.notKept))
        }
    }

    /// Killed AFTER the swap (the reopen landed, custody not moved): nothing
    /// came back, and the resume finishes with the HONEST Done — the flag
    /// beside the dials carries This Mac Only across the crash (the marker
    /// cannot). RED ON OLD — R-c2 (the resume reads no flag): the ordinary
    /// Done ("your other devices will ask the next time they open").
    @Test func aThisMacOnlyRoadKilledAfterItsSwapResumesToTheHonestDone() async throws {
        try await withDeps {
            let world = try await makeWorld(custody: .material, signedIn: false)
            defer { world.tearDown() }
            let words = try RecoveryPhrase.generate()
            world.rekeyFault = .afterReopen
            await #expect(throws: URLError.self) {
                _ = try await world.runner.enterCastle(passphrase: passphrase, recoveryWords: words, thisDeviceOnly: true)
            }
            let marker = try #require(try await world.marker())
            #expect(marker.step == .rekeyLibrary)
            #expect(!StoreEncryptionMigration.opens(world.storeURL, key: world.oldKey), "the swap landed")
            #expect(world.bootstrap.switchInProgress, "gate i stays set — the switch is pending")
            #expect(world.syncLeaves.plainRecord?.material == nil)

            let outcome = try await world.runner.resume(passphrase: passphrase, recoveryWords: words)
            #expect(outcome.thisDeviceOnly, "the flag carried This Mac Only across the crash")
            #expect(!world.bootstrap.switchInProgress, "the resume's custody move cleared gate i")
            let done = ProtectionCopy.ceremonyDoneBody(act: CeremonyAct(resuming: marker), outcome: outcome)
            #expect(done == ProtectionCopy.enteredCastleThisDeviceOnlyDone(.notKept), "\(done)")
            #expect(!done.contains("other devices will ask"))
            #expect(!world.thisDeviceOnlyFlag)
        }
    }

    // MARK: - (d) BOUND — one library's forget never touches another's custody

    /// Her multiple-accounts worry, answered structurally (§A refinement 3):
    /// custody is per STORE ID — two libraries on one Mac (two store ids,
    /// two accounts' material), the production custody factory over the
    /// REAL Keychain under a throwaway scope; forgetting one leaves the
    /// other whole, and the forgotten one keeps its identity. A BOUND (green
    /// on both sides): nothing in this unit changed custody naming; the pin
    /// keeps the property the This-Mac-Only road leans on.
    @Test func forgettingOneLibrarysSyncKeysLeavesAnotherLibrarysCustodyWhole() throws {
        let scope = "vx110-isolation-\(UUID().uuidString.prefix(8).lowercased())"
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx110-d-\(UUID().uuidString)", isDirectory: true)
        let suiteName = "io.lduarte.variorum.tests.vx110d.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let apple = AppleKey.mint()
        func library(_ name: String) throws -> (url: URL, storeID: String) {
            let url = root.appendingPathComponent("\(name)/variorum.sqlite")
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let storeID = "\(scope)-\(name)"
            var envelope = StoreKeyEnvelope(storeID: storeID)
            let key = StoreKey.mint()
            try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
            try envelope.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
            try envelope.write(at: envelope.preferredURL(besideStore: url))
            return (url, storeID)
        }
        let a = try library("a")
        let b = try library("b")
        defer {
            for id in [a.storeID, b.storeID] {
                let items = SyncCustodyScope(scope: scope, storeID: id)
                _ = E2EEKeychainStorage.deletePlainItem(scope: items)
                _ = E2EEKeychainStorage.deleteGatedItem(scope: items)
            }
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: root)
        }
        #expect(SyncCustodyScope(scope: scope, storeID: a.storeID).boundAccount
                != SyncCustodyScope(scope: scope, storeID: b.storeID).boundAccount)
        func material(_ seed: UInt8) -> DeviceKeyMaterial {
            DeviceKeyMaterial(
                masterKey: Data(repeating: seed, count: 32), corpusKey: Data(repeating: seed &+ 1, count: 32),
                corpusKeyID: "corpus-\(seed)", journalBridgeKey: Data(repeating: seed &+ 2, count: 32),
                journalBridgeKeyID: "journal-\(seed)")
        }
        let session = SyncCustodySession()
        let storeA = DeviceKeyStore.keychain(
            scope: scope, storeURL: a.url, session: session, defaults: { UserDefaults(suiteName: suiteName)! })
        let storeB = DeviceKeyStore.keychain(
            scope: scope, storeURL: b.url, session: session, defaults: { UserDefaults(suiteName: suiteName)! })
        #expect(storeA.save(material(1)), "the first account's keys, library A")
        #expect(storeB.save(material(9)), "another account's keys, library B")
        let identityA = storeA.deviceID()
        #expect(storeA.load() == material(1) && storeB.load() == material(9))

        storeA.clear()  // the forget's one act (EncryptionSession.forgetDeviceKeys)

        #expect(storeA.load() == nil, "library A forgot its account's keys")
        #expect(storeA.deviceID() == identityA, "…and kept its identity")
        #expect(E2EEKeychainStorage.load(scope: SyncCustodyScope(scope: scope, storeID: a.storeID))?.material == nil)
        #expect(storeB.load() == material(9), "library B's custody is whole")
        #expect(E2EEKeychainStorage.load(scope: SyncCustodyScope(scope: scope, storeID: b.storeID))?.material == material(9))
    }

    // MARK: - (e) BOUND — the This-Mac-Only library's next account is born Castle

    /// Her carried-forward reminder 1: "confirm that a new account set up
    /// from a Castle library actually starts out in Castle." The road the
    /// audit flagged as never exercised, end to end: This Mac Only, then a
    /// sign-in to a NEW account with no vault, the sign-in's ready, then sync
    /// setup over production's wiring — the vault is born with NO Apple-held
    /// copy, custody lands behind the gate, the key file gains the master
    /// copy and no Apple copy, and the next ready reads Castle with nothing
    /// owed. A BOUND (green on both sides): decision 17 + corner 26 as built;
    /// no line of this unit is on this road. If it is ever red, the Done's
    /// account sentences must not lean on it (the brief's soften rule).
    @Test func syncSetUpFromTheThisMacOnlyLibraryBirthsACastleAccount() async throws {
        try await withDeps {
            let world = try await makeWorld(custody: .material, signedIn: false)
            defer { world.tearDown() }
            let words = try RecoveryPhrase.generate()
            let outcome = try await world.runner.enterCastle(passphrase: passphrase, recoveryWords: words, thisDeviceOnly: true)
            #expect(outcome.thisDeviceOnly && outcome.entersCastle)
            let castleKey = try #require(world.backing.gated)

            // A NEW account, no vault yet.
            let newVault = EmulatedVault(claimRotationSeq: { 0 })
            let newClient = vaultClient(newVault, user: "user-new")
            let encryption = EncryptionSession(store: world.keyStore, client: newClient, signedIn: { true })
            wireOneSecretHooks(protection: world.protection, encryption: encryption,
                               keyVault: newClient, auth: auth(user: "user-new"))
            await world.protection.reconcile()  // the sign-in's ready
            #expect(try world.liveKeyFile().apple == nil, "nothing lands while no vault exists")
            #expect(world.protection.libraryOwnPosture == .castle)

            let newWords = try RecoveryPhrase.generate()
            await encryption.setUp(passphrase: passphrase, recoveryWords: newWords)
            #expect(encryption.lastError == nil, "\(encryption.lastError ?? "")")
            let born = try #require(try await newClient.fetchVault())
            #expect(born.format.masterWrappedByAppleHeld == nil && born.format.appleKeyID == nil,
                    "the account is BORN CASTLE — no Apple-held copy")
            #expect(born.format.masterWrappedByRecovery != nil)
            let landed = try #require(world.syncLeaves.gatedRecord?.material, "custody landed behind the gate")
            #expect(world.syncLeaves.plainRecord?.material == nil, "never in the silent item")
            #expect(born.format.classKey(for: .corpus)?.keyID == landed.corpusKeyID)
            let file = try world.liveKeyFile()
            #expect(file.apple == nil, "the key file carries no Apple copy")
            #expect(try file.unwrapKey(master: landed.masterSymmetricKey) == castleKey, "the master copy landed")

            await world.protection.reconcile()  // the next ready
            #expect(world.protection.postureReading == .determined(.castle))
            #expect(world.protection.followNotice == nil && world.protection.movedToStandardNotice == nil)
            #expect(try world.liveKeyFile().apple == nil && world.backing.auto == nil)
        }
    }

    // MARK: - (f) the This-Mac-Only words never claim the account-wide switch

    /// RED ON OLD — R-f (the selector's This-Mac-Only arm removed): the Done
    /// said "…your other devices will ask the next time they open" over an
    /// account nothing touched.
    @Test func theThisMacOnlyScreensAndDoneNeverSpeakTheAccountWideWords() async throws {
        func outcome(_ snapshot: PostureSwitchRunner.FreshSnapshot, thisDeviceOnly: Bool) -> PostureSwitchRunner.Outcome {
            PostureSwitchRunner.Outcome(
                entersCastle: true, newKeyFingerprint: "fp", insuranceTurnedOff: false,
                preSwitchSnapshots: [], freshSnapshot: snapshot, reencrypted: 0, material: nil,
                thisDeviceOnly: thisDeviceOnly)
        }
        let fates: [PostureSwitchRunner.FreshSnapshot] = [.written(URL(fileURLWithPath: "/dev/null")), .failed, .notKept]
        for fate in fates {
            let done = ProtectionCopy.ceremonyDoneBody(act: .enterCastle, outcome: outcome(fate, thisDeviceOnly: true))
            #expect(done == ProtectionCopy.enteredCastleThisDeviceOnlyDone(fate), "\(fate): \(done)")
            #expect(!done.contains("other devices"), "never the account-wide claim: \(done)")
            #expect(done.contains("unchanged") && done.contains("delete that account if you still can"))
            #expect(!done.contains("ACCOUNT") && !done.contains("NOT"), "no capitals for emphasis")
            // The control: the account-wide Done is untouched.
            #expect(ProtectionCopy.ceremonyDoneBody(act: .enterCastle, outcome: outcome(fate, thisDeviceOnly: false))
                    == ProtectionCopy.castleDoneBody(outcome(fate, thisDeviceOnly: false)))
        }
        // The new Done keeps the ordinary Done's backup arms (F2/F3's rule).
        #expect(ProtectionCopy.enteredCastleThisDeviceOnlyDone(.written(URL(fileURLWithPath: "/dev/null")))
                .contains("A fresh backup was made under it"))
        #expect(ProtectionCopy.enteredCastleThisDeviceOnlyDone(.failed).contains("could not be made"))
        #expect(!ProtectionCopy.enteredCastleThisDeviceOnlyDone(.notKept).contains("backup"))

        // Screen 1 by the road, through the model (both faces render these).
        try await withDeps {
            let world = try await makeWorld(custody: .material, signedIn: false)
            defer { world.tearDown() }
            let model = PostureSwitchModel(mode: .enter, runner: world.runner, controller: world.protection, vaultTie: nil)
            #expect(model.explainBody == ProtectionCopy.enterCastleBody, "the account-wide road's words before a choice")
            await model.start()
            model.chooseThisDeviceOnly()
            #expect(model.explainBody == ProtectionCopy.enterCastleThisDeviceOnlyBody)
            #expect(model.explainBullets == ProtectionCopy.enterCastleThisDeviceOnlyBullets)
            let spoken = ([model.explainBody] + model.explainBullets).joined(separator: " ")
            #expect(!spoken.contains("so does your sync") && !spoken.contains("will start asking"),
                    "never the account-wide claims: \(spoken)")
            #expect(spoken.contains("Only this"), "it names the one device that changes")
        }
    }

    /// Both faces render the two doors, the ended ceremony and the explain
    /// by the road (read as code — the faces have no host here; comment
    /// lines dropped). The phone composes the SAME model.
    @Test func bothFacesRenderTheTwoDoorsAndTheExplainByTheRoad() throws {
        let appRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        func code(_ path: String) throws -> String {
            try String(contentsOf: appRoot.appending(path: path), encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
                .joined(separator: "\n")
        }
        for path in ["Variorum/Features/Settings/ProtectionPane.swift",
                     "VariorumMobile/Features/Protection/MobilePostureSheets.swift"] {
            let source = try code(path)
            for needle in ["case .signedOutChoice:", "case .signInChosen:", "model.chooseSignIn()",
                           "model.chooseThisDeviceOnly()", "ProtectionCopy.useCastleThisDeviceOnlyDoor",
                           "model.explainBody", "model.explainBullets", "AccountView(services: services, initialTab: .account)"] {
                #expect(source.contains(needle), "\(path) renders \(needle)")
            }
            #expect(!source.contains("ForEach(ProtectionCopy.enterCastleBullets"),
                    "\(path): Screen 1 reads the road's bullets, never the account-wide ones directly")
        }
        // The phone's sheet is handed the services the account surface needs.
        #expect(try code("VariorumMobile/Features/Protection/MobileProtectionSheet.swift")
            .contains("MobilePostureSwitchSheet(model: model, tokens: tokens, services: services)"))
    }

    // MARK: - (item 2) the rekey banners name the pending marker's act

    /// RED ON OLD — R-7 (the selectors answer the old constants): over a Use
    /// Castle marker the Encryption tab said "Key replacement didn't finish…"
    /// with *Finish Replacing Keys…*, and the sync row "Finish key
    /// replacement…" — the panes' act rule swept those two faces too.
    @Test func theRekeyBannersAndTheSyncRowNameThePendingMarkersAct() async throws {
        let stamp = "2026-10-13T00:00:00Z"
        let entering = CeremonyAct(resuming: RotationMarker(step: .rekeyLibrary, entersCastle: true, startedAt: stamp))
        let followingIn = CeremonyAct(resuming: RotationMarker(step: .reencrypt, entersCastle: true, startedAt: stamp, follow: true))
        let replacing = CeremonyAct(resuming: RotationMarker(step: .reencrypt, entersCastle: false, startedAt: stamp))
        #expect(entering == .enterCastle && followingIn == .follow(entersCastle: true) && replacing == .replaceKeys)

        // The Encryption tab's banner + door.
        for act in [entering, followingIn] {
            for signedIn in [true, false] {
                let prompt = EncryptionView.rekeyIncompletePrompt(for: act, signedIn: signedIn)
                #expect(prompt == ProtectionCopy.ceremonyResumeTitle(act), "\(act), signed in \(signedIn): \(prompt)")
                #expect(!prompt.lowercased().contains("key replacement"))
            }
            #expect(EncryptionView.rekeyIncompleteDoorLabel(for: act) == ProtectionCopy.finishEnteringCastleDoor)
        }
        #expect(EncryptionView.rekeyIncompletePrompt(for: replacing, signedIn: true) == EncryptionView.rekeyIncompletePrompt)
        #expect(EncryptionView.rekeyIncompletePrompt(for: replacing, signedIn: false) == EncryptionView.rekeyIncompleteSignedOutPrompt)
        #expect(EncryptionView.rekeyIncompleteDoorLabel(for: replacing) == ProtectionCopy.finishReplacingKeysDoor)
        #expect(EncryptionView.rekeyIncompletePrompt(for: nil, signedIn: true) == EncryptionView.rekeyIncompletePrompt,
                "an unknown act keeps the older words")
        #expect(EncryptionView.rekeyIncompleteDoorLabel(for: nil) == ProtectionCopy.finishReplacingKeysDoor)

        // The sync row's door + line.
        let refusal = String(describing: SyncError.accountRekeyIncomplete)
        func door(_ act: CeremonyAct?) -> String? {
            SyncRowFace.face(
                allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false,
                lastError: refusal, lastErrorIsOffline: false, rekeyAct: act).doors.first?.label
        }
        #expect(door(entering) == "Finish entering Castle…" && door(followingIn) == "Finish entering Castle…")
        #expect(door(replacing) == "Finish key replacement…" && door(nil) == "Finish key replacement…")
        #expect(SyncStatusRow.rekeyIncompleteLabel(for: entering).contains("entering Castle didn't finish"))
        #expect(SyncStatusRow.rekeyIncompleteLabel(for: replacing) == SyncStatusRow.rekeyIncompleteLabel)

        // The session projects the act from the marker read.
        let session = EncryptionSession(store: .inMemory(), client: nil, signedIn: { false })
        session.pendingCeremonyActCheck = { .enterCastle }
        #expect(await session.readPendingCeremonyAct() == .enterCastle)
    }
}
