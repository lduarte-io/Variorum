//
//  ProtectionMigrationDrillTests.swift
//  VariorumTests
//
//  pre-13x batch 2a — THE MIGRATION DRILL (the brief's 2a gate): a scratch
//  keyed store DRESSED IN THE 13p-ERA SHAPE — a plain E2EE item (the 14b
//  `device-keys` blob, file-based), a legacy-scope bound store-key item, a
//  legacy ESCROW item (the RAW library key, synchronizable), a
//  `sync_state.device_id` row and the 13p dial keys — under THROWAWAY
//  scopes/services in the SIGNED test host against the REAL Keychain, the
//  §11 migration run through production's leaves shape, and the
//  before/after Keychain INVENTORY quoted as `MIGRATION-DRILL|` lines.
//
//  DISABLED BY DEFAULT (the batch-0 opt-in pattern): the escrow leg writes
//  one synchronizable throwaway item (it rides into the author's iCloud
//  Keychain for the run's duration and is deleted with the flagged delete
//  — that removal IS the leg under drill). Run deliberately:
//
//      TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1 xcodebuild test … \
//        -only-testing:VariorumTests/ProtectionMigrationDrillTests
//
//  The real scopes (`Variorum`, `Variorum-dev`) and the real legacy fixed
//  accounts are NEVER touched: the tripwire's law, and every item here is
//  under `drill-<uuid>` or a throwaway service. The custody move
//  (biometric ↔ silent) is REAL — a `.biometryCurrentSet` item written and
//  probed, never read (no prompt) — through the controller's own primitive.
//

import Dependencies
import Foundation
import LocalAuthentication
import GRDB
import Security
import Testing

@testable import Variorum
@testable import VariorumCore

nonisolated enum MigrationDrill {
    static var requested: Bool {
        ProcessInfo.processInfo.environment["VARIORUM_MIGRATION_DRILL"] == "1"
    }
    /// The 14b plain item's throwaway twin (service + fixed account).
    static let legacyE2EEService = "io.lduarte.Variorum.e2ee-keys.2a-drill"
}

@MainActor
@Suite(
    "pre-13x 2a — THE MIGRATION DRILL on a store dressed in the 13p-era shape (opt-in; DISABLED unless VARIORUM_MIGRATION_DRILL=1)",
    .enabled(
        if: MigrationDrill.requested,
        "writes real Keychain items under throwaway scopes (one synchronizable escrow item rides into iCloud Keychain and is removed) — run deliberately with TEST_RUNNER_VARIORUM_MIGRATION_DRILL=1"))
struct ProtectionMigrationDrillTests {
    nonisolated private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func describe(_ status: OSStatus) -> String {
        let words = (SecCopyErrorMessageString(status, nil) as String?) ?? "?"
        return "\(status) (\(words))"
    }

    /// An attributes-only probe (no data read — a gated item never prompts).
    private func exists(_ base: [String: Any]) -> Bool {
        var query = base
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        let probe = LAContextProbe.make()
        query[kSecUseAuthenticationContext as String] = probe
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    nonisolated private static func legacyE2EEQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: MigrationDrill.legacyE2EEService,
            kSecAttrAccount as String: E2EEKeychainStorage.legacyPlainAccount,
        ]
    }

    private func storeKeyQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: StoreKeyCustody.deviceKeychainService,
            kSecAttrAccount as String: account,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    @Test func aStoreDressedInThe13pShapeMigratesWholeAndTheInventoryShowsIt() async throws {
        let scope = "drill-\(UUID().uuidString.lowercased().prefix(8))"
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-2a-drill-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        let suiteName = "variorum-2a-drill-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let defaultsProvider: @Sendable () -> UserDefaults = { UserDefaults(suiteName: suiteName)! }

        // ————— THE 13p-ERA SHAPE —————
        let key = StoreKey.mint()
        // The keyed store with a `sync_state.device_id` row (13j's mint).
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        try await database.write { db in
            try db.execute(sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES ('device_id', 'drill-device-13j')")
        }
        // The key file: a passphrase wrap (the one-secret follow), no Apple copy, no master copy.
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        let storeID = envelope.storeID
        // The 13p dial keys: Auto (silent), escrow on, an idle of 15.
        defaults.set("auto", forKey: ProtectionDefaults.key("mode", scope: scope))
        defaults.set(false, forKey: ProtectionDefaults.key("escrowOff", scope: scope))
        defaults.set(15, forKey: ProtectionDefaults.key("relockIdleMinutes", scope: scope))
        defaults.set(true, forKey: SyncCustodyMigration.legacyOptInDefaultsKey)
        // The legacy-scope BOUND store-key item (`<scope>-bound`, DP) — 1a's load road migrates it.
        do {
            var attributes = storeKeyQuery(account: StoreKeyKeychain.legacyBoundAccount(scope: scope))
            attributes[kSecValueData as String] = key.data
            attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            #expect(SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess)
        }
        // The 14b PLAIN E2EE item (file-based, the bare material) under the throwaway service.
        let held = DeviceKeyMaterial(
            masterKey: Data((0..<32).map { _ in UInt8.random(in: 0...255) }),
            corpusKey: Data((0..<32).map { _ in UInt8.random(in: 0...255) }), corpusKeyID: "corpus-drill",
            journalBridgeKey: Data(repeating: 2, count: 32), journalBridgeKeyID: "bridge-drill")
        do {
            var attributes = Self.legacyE2EEQuery()
            attributes[kSecValueData as String] = try JSONEncoder().encode(held)
            #expect(SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess)
        }
        // The legacy ESCROW item: the RAW key, synchronizable, named by store id (the 13p shape).
        do {
            var attributes = StoreKeyGuardKeychain.legacyEscrowQuery(storeID: storeID)
            attributes[kSecValueData as String] = key.data
            attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let status = SecItemAdd(attributes as CFDictionary, nil)
            print("MIGRATION-DRILL| dress: escrow add \(describe(status))")
            #expect(status == errSecSuccess)
        }
        defer {
            _ = StoreKeyGuardKeychain.removeLegacyEscrow(storeID: storeID)
            _ = SecItemDelete(Self.legacyE2EEQuery() as CFDictionary)
            _ = StoreKeyCustody.deviceKeychainRemove(scope: scope, storeID: storeID)
            _ = StoreKeyGuardKeychain.deleteGated(scope: scope, storeID: storeID)
            let custody = SyncCustodyScope(scope: scope, storeID: storeID)
            _ = E2EEKeychainStorage.deleteGatedItem(scope: custody)
            _ = E2EEKeychainStorage.deletePlainItem(scope: custody)
        }
        let custody = SyncCustodyScope(scope: scope, storeID: storeID)

        func inventory(_ label: String) -> [String: Bool] {
            let items: [String: Bool] = [
                "store-key legacy bound (\(scope)-bound)": exists(storeKeyQuery(account: StoreKeyKeychain.legacyBoundAccount(scope: scope))),
                "store-key per-store bound": exists(storeKeyQuery(account: StoreKeyKeychain.boundAccount(scope: scope, storeID: storeID))),
                "store-key per-store GATED (biometric)": StoreKeyGuardKeychain.gatedItemExists(scope: scope, storeID: storeID),
                "e2ee legacy plain (device-keys, throwaway service)": exists(Self.legacyE2EEQuery()),
                "e2ee per-store bound (-sync)": E2EEKeychainStorage.load(scope: custody) != nil,
                "e2ee per-store GATED (-sync-biometric)": E2EEKeychainStorage.gatedItemExists(scope: custody),
                "legacy ESCROW (synchronizable, raw key)": StoreKeyGuardKeychain.loadLegacyEscrow(storeID: storeID) != nil,
            ]
            print("MIGRATION-DRILL| \(label) inventory:")
            for (name, present) in items.sorted(by: { $0.key < $1.key }) {
                print("MIGRATION-DRILL|   \(present ? "PRESENT" : "absent ") — \(name)")
            }
            return items
        }
        let before = inventory("BEFORE")
        #expect(before["store-key legacy bound (\(scope)-bound)"] == true)
        #expect(before["e2ee legacy plain (device-keys, throwaway service)"] == true)
        #expect(before["legacy ESCROW (synchronizable, raw key)"] == true)
        #expect(before["e2ee per-store bound (-sync)"] == false)
        let rowBefore = try await database.read { try String.fetchOne($0, sql: "SELECT value FROM sync_state WHERE key = 'device_id'") }
        print("MIGRATION-DRILL| BEFORE sync_state.device_id = \(rowBefore ?? "nil") · dial keys: mode=\(defaults.string(forKey: ProtectionDefaults.key("mode", scope: scope)) ?? "nil")")

        // ————— THE LOAD ROAD (1a): the legacy bound item migrates onto the store id —————
        let loaded = StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL).load()
        #expect(loaded == key, "the 1a road hands the key back and re-scopes the item")

        // ————— THE MIGRATION (§11), through production's leaves shape —————
        let session = SyncCustodySession()
        let backing = InMemoryStoreKeyGuardBacking()  // unused: the REAL guard below
        _ = backing
        let dialsRead: @Sendable (String, String?) -> ProtectionDials = { s, id in
            ProtectionDefaults.dials(scope: s, storeID: id, in: defaultsProvider())
        }
        let gate = StoreLaunchGate(
            dials: dialsRead,
            saveDials: { ProtectionDefaults.save($0, scope: $1, storeID: $2, in: defaultsProvider()) },
            legacyMode: { ProtectionDefaults.legacyMode(scope: $0, storeID: $1, in: defaultsProvider()) },
            retireLegacyDials: { ProtectionDefaults.retireLegacyKeys(scope: $0, storeID: $1, in: defaultsProvider()) },
            guardFor: { s in StoreKeyGuard.keychain(scope: s, storeURL: storeURL) },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: InMemoryAppleKeyBacking()) },
            loadEnvelope: { try StoreKeyEnvelope.loadCurrent(besideStore: $0) },
            saveEnvelope: { try $0.write(at: $0.preferredURL(besideStore: $1)) },
            setAsideEnvelope: { _ in },
            stamp: { _, _ in nil },
            setStamp: { _, _, _ in })
        let controller = ProtectionController(configuration: .init(
            scope: scope, storeURL: storeURL, gate: gate, isRealVariant: false,
            makeKDF: { self.fastKDF() },
            syncCustodyLeaves: { id in .live(scope: SyncCustodyScope(scope: scope, storeID: id)) },
            syncCustodySession: session))
        print("MIGRATION-DRILL| route-time gate (the legacy mode reads through): \(controller.effectiveGate.rawValue) · posture \(controller.posture.rawValue) · biometry available: \(controller.biometryAvailable)")
        #expect(controller.effectiveGate == .auto, "a silent 13p store opens silently once more")

        var leaves = ProtectionMigration.Leaves.live(
            scope: scope, storeID: storeID, storeURL: storeURL,
            database: database, gate: gate, protection: controller, defaults: defaultsProvider, session: session)
        // The 14b plain item lives under the throwaway service here (the
        // real fixed account is never touched): the two legacy leaves point
        // at it; everything else is production's.
        leaves.legacyPlainMaterial = {
            var query = Self.legacyE2EEQuery()
            query[kSecReturnData as String] = true
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            var result: AnyObject?
            guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
                  let data = result as? Data else { return nil }
            return try? JSONDecoder().decode(DeviceKeyMaterial.self, from: data)
        }
        leaves.deleteLegacyItems = {
            let status = SecItemDelete(Self.legacyE2EEQuery() as CFDictionary)
            return status == errSecSuccess || status == errSecItemNotFound
        }
        let logBox = LockIsolated<[String]>([])
        leaves.log = { line in logBox.withValue { $0.append(line) } }

        // The vault's word for the drill: CASTLE (no Apple-held copy — her devices).
        let vaultKDF = fastKDF()
        let facts = ProtectionMigration.Facts(
            scope: scope, storeID: storeID, key: key,
            effectiveGate: controller.effectiveGate,
            signedIn: true, vaultHasAppleHeldCopy: false, alwaysAsk: false,
            biometryAvailable: controller.biometryAvailable,
            vaultKDF: vaultKDF)
        let report = await ProtectionMigration.run(facts: facts, leaves: leaves)
        let log = logBox.value
        for line in log { print("MIGRATION-DRILL| \(line)") }

        // ————— AFTER —————
        let after = inventory("AFTER")
        let rowAfter = try await database.read { try String.fetchOne($0, sql: "SELECT value FROM sync_state WHERE key = 'device_id'") }
        print("MIGRATION-DRILL| AFTER sync_state.device_id = \(rowAfter ?? "nil") · legacy dial keys: \(ProtectionDefaults.hasLegacyKeys(scope: scope, storeID: storeID, in: defaults) ? "PRESENT" : "retired") · alwaysAsk=\(dialsRead(scope, storeID).alwaysAsk) idle=\(String(describing: dialsRead(scope, storeID).relockAfterIdleMinutes)) · opt-in key: \(defaults.object(forKey: SyncCustodyMigration.legacyOptInDefaultsKey) == nil ? "retired" : "PRESENT") · confirm pending: \(leaves.isConfirmPending())")
        #expect(report.syncCustody == .done)
        #expect(after["e2ee legacy plain (device-keys, throwaway service)"] == false, "the plain item deleted")
        #expect(after["legacy ESCROW (synchronizable, raw key)"] == false, "the escrow item REMOVED from iCloud Keychain (ownership-guarded)")
        #expect(after["store-key legacy bound (\(scope)-bound)"] == false, "the legacy-scope item re-scoped (1a) and released")
        #expect(rowAfter == nil, "the device_id row moved into custody")
        #expect(!ProtectionDefaults.hasLegacyKeys(scope: scope, storeID: storeID, in: defaults), "the dial keys retired")
        #expect(dialsRead(scope, storeID).relockAfterIdleMinutes == 15, "her idle choice survives")
        let expectedGate: StoreAtOpenMode = controller.biometryAvailable ? .biometric : .passphrase
        #expect(report.custodyAligned == expectedGate, "custody aligned to Castle: \(String(describing: report.custodyAligned))")
        if expectedGate == .biometric {
            #expect(after["store-key per-store GATED (biometric)"] == true, "the library key behind the gate")
            #expect(after["store-key per-store bound"] == false, "no silent item under the gate")
            #expect(after["e2ee per-store GATED (-sync-biometric)"] == true, "the sync record behind the SAME gate")
            #expect(E2EEKeychainStorage.load(scope: custody)?.material == nil, "the plain sync item is identity-only")
        }
        #expect(E2EEKeychainStorage.load(scope: custody)?.deviceID == "drill-device-13j", "the identity from sync_state rides the custody item")
        #expect(session.record?.material == held, "the migrating session is unlocked")
        let written = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
        #expect(try written.unwrapKey(master: held.masterSymmetricKey) == key, "the key file's master copy — the vault road with no visit")
        #expect(written.vaultKDF == vaultKDF && written.vaultCorpusKeyID == "corpus-drill")
        #expect(report.confirmPending)
        #expect(controller.effectiveGate == expectedGate, "the route derives Castle from here on")
        // No key material in the log.
        for line in log {
            #expect(!line.contains(key.hexEncoded) && !line.contains(held.masterKey.base64EncodedString()),
                    "key material in the log: \(line)")
        }
        // Idempotent.
        let again = await ProtectionMigration.run(facts: facts, leaves: leaves)
        #expect(again.skippedAsDone)
        database.asRebindable().binding.lock()
    }
}

/// The non-interactive `LAContext` the inventory's gated probes ride.
nonisolated enum LAContextProbe {
    static func make() -> LAContext {
        let probe = LAContext()
        probe.interactionNotAllowed = true
        return probe
    }
}
