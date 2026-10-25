//
//  MobilePlantedProtection.swift
//  VariorumMobileTests
//
//  VM-8 unit 1 (piece 3) — THE NEW ROAD'S PLANTED LEAVES, for the phone's own test bundle: no keychain, no network, a
//  temp slot with the real file leaves. COPIED VERBATIM from the Mac test target's support (`VariorumTests/Protection/
//  ProtectionTestSupport.swift` — the temp slot and the planted custody, memory, Apple, biometry and fast-ids leaves —
//  and `ProtectionAccountSupport.swift` — the planted vault and sync keys): the two test bundles are separate modules
//  (each `@testable`-imports its own app), so the phone's posture pins need their own copy. Keep the two in step; the
//  Mac's copy is the reference.
//

import CryptoKit
import Foundation
import Security
import Testing
import VariorumCore
@testable import VariorumMobile

/// A temp folder holding a slot (`variorum.sqlite`) and its container, removed at deinit.
nonisolated final class TempSlot {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("vx306-slot-\(UUID().uuidString)", isDirectory: true)
    let far: URL
    let places: ProtectionPlaces

    init(withFarFolder: Bool = false) {
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let container = root.appendingPathComponent("container", isDirectory: true)
        try? FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        let far = root.appendingPathComponent("far", isDirectory: true)
        self.far = far
        if withFarFolder { try? FileManager.default.createDirectory(at: far, withIntermediateDirectories: true) }
        places = ProtectionPlaces(
            slot: container.appendingPathComponent(CatalogNames.libraryFilename),
            farFolder: { withFarFolder ? ProtectionFarFolder(picked: far, scoped: false) : nil },
            scratch: root.appendingPathComponent("scratch", isDirectory: true))
    }

    deinit { try? FileManager.default.removeItem(at: root) }

    var container: URL { places.container }
    func url(_ path: String) -> URL { container.appendingPathComponent(path) }
}

/// An Apple-keys leaf that never reaches iCloud — the composition test's stand-in (the real one is the
/// opt-in `ICloudAppleKeysLeafTests`).
nonisolated final class InMemoryAppleKeysLeaf: AppleKeysLeaf, @unchecked Sendable {
    var keys: [String: AppleKeyMaterial] = [:]
    var stamps: [String: String] = [:]
    /// VX-306 U3: every write and delete, in order (Look inside's write-nothing proof reads it).
    private(set) var writes: [String] = []

    func readableAppleKeyIDs() throws -> Set<String> { Set(keys.keys) }
    func readAppleKey(id: String) throws -> AppleKeyMaterial? { keys[id] }
    func addAppleKey(_ key: AppleKeyMaterial, libraryID: String) throws {
        writes.append("add \(key.id)")
        keys[key.id] = key
        stamps[key.id] = libraryID
    }
    func deleteAppleKey(id: String) throws {
        writes.append("delete \(id)")
        keys[id] = nil
        stamps[id] = nil
    }
    func appleKeyIDs(ofLibrary libraryID: String) throws -> Set<String> {
        Set(stamps.filter { $0.value == libraryID }.map(\.key))
    }
}

/// A custody leaf over planted items that RECORDS every read by class, and can be told to fail reads or
/// the listing — the gatherer's facts are pinned from it.
nonisolated final class PlantedCustodyLeaf: CustodyLeaf, TouchIDPressHanding, @unchecked Sendable {
    var items: [CustodyItemFact: StoreKey] = [:]
    var unreadable: Set<String> = []
    var listingFails = false
    private(set) var reads: [ProtectionNames.CustodyClass] = []
    /// VX-306 U3: every write and delete, in order (Look inside's write-nothing proof reads it).
    private(set) var writes: [String] = []
    /// VX-487 (b): every press a Touch ID read that OPENED its item handed its caller, in order (the one-press pins).
    private(set) var handedPresses: [TouchIDPressContext] = []

    struct Unreadable: Error {}

    func custodyItems() throws -> [CustodyItemFact] {
        if listingFails { throw Unreadable() }
        return Array(items.keys)
    }

    func readCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws -> StoreKey? {
        reads.append(itemClass)
        if unreadable.contains(fingerprint) { throw Unreadable() }
        return items[CustodyItemFact(fingerprint: fingerprint, itemClass: itemClass)]
    }

    /// VX-487 (b): the lobby's press — read as `readCustody(.touchid)` reads (the same read recorded), handing a press
    /// when it opened its item (a planted context: no prompt, no biometry hardware).
    func readTouchIDCustody(fingerprint: String) throws -> (key: StoreKey?, press: TouchIDPressContext?) {
        guard let key = try readCustody(fingerprint: fingerprint, itemClass: .touchid) else { return (nil, nil) }
        let press = TouchIDPressContext()
        handedPresses.append(press)
        return (key, press)
    }

    func writeCustody(_ key: StoreKey, itemClass: ProtectionNames.CustodyClass, libraryID: String) throws {
        writes.append("write \(itemClass)")
        let fact = CustodyItemFact(fingerprint: KeyFingerprint.of(key), itemClass: itemClass, libraryID: libraryID)
        items.removeValue(forKey: fact)
        items[fact] = key
    }

    /// VX-307 ladder r1 (MAJOR-1): the next N deletes FAIL (nothing deleted, nothing recorded) — an act stopping at a
    /// step after its swap (the crash-window idiom on a planted road).
    var failingDeletes = 0

    struct DeleteFailed: Error {}

    func deleteCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws {
        if failingDeletes > 0 {
            failingDeletes -= 1
            throw DeleteFailed()
        }
        writes.append("delete \(itemClass)")
        items[CustodyItemFact(fingerprint: fingerprint, itemClass: itemClass)] = nil
    }
}

/// A memory leaf over planted items (the gatherer's memory facts).
nonisolated final class PlantedMemoryLeaf: MemoryStoreLeaf, @unchecked Sendable {
    var items: [String: Sealed<DeviceMemory>] = [:]
    var unreadable: Set<String> = []
    /// VX-306 U3: every write and delete, in order (Look inside's write-nothing proof reads it).
    private(set) var writes: [String] = []

    struct Unreadable: Error {}

    func readMemory(libraryID: String) throws -> Sealed<DeviceMemory>? {
        if unreadable.contains(libraryID) { throw Unreadable() }
        return items[libraryID]
    }
    func writeMemory(_ memory: Sealed<DeviceMemory>, libraryID: String) throws {
        writes.append("write \(libraryID)")
        items[libraryID] = memory
    }
    func rememberedLibraryIDs() throws -> Set<String> { Set(items.keys) }
    func deleteMemory(libraryID: String) throws {
        writes.append("delete \(libraryID)")
        items[libraryID] = nil
    }
}

/// Biometry that is whatever the test says.
nonisolated final class FixedBiometryLeaf: BiometryLeaf, @unchecked Sendable {
    var facts: BiometryFacts
    init(_ facts: BiometryFacts) { self.facts = facts }
    func biometry() -> BiometryFacts { facts }
}

/// A fast KDF for the composition test's passphrase (the real floor is the production one; tests run
/// under `.relaxedForTests`).
nonisolated final class FastIDsLeaf: IDsLeaf, @unchecked Sendable {
    let system = SystemIDsLeaf()
    func mintID() -> String { system.mintID() }
    func mintLibraryKey() -> StoreKey { system.mintLibraryKey() }
    func mintAppleKey() -> AppleKeyMaterial { system.mintAppleKey() }
    func mintSymmetricKey() -> SymmetricKey { system.mintSymmetricKey() }
    func mintPassphraseKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13, memoryKiB: 256, iterations: 1,
            parallelism: 1, salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }
    func mintWords() -> [String] { system.mintWords() }
}

/// The server's vault, planted (the core's `ExecutorVault`, restated): CAS on the revision and the key proof.
nonisolated final class PlantedVaultLeaf: VaultLeaf, @unchecked Sendable {
    /// VX-308 (the U2 Mac batch's one crash, traced): the pane's read and an
    /// act's read are CONCURRENT by design since U2's seam, and this fake's
    /// bare arrays corrupted under the race (`calls.append` vs a sibling
    /// call — SIGSEGV in the test host). Every method body now holds the
    /// one lock (the `NewRoadSyncKeyProvider` idiom); direct property reads
    /// in test bodies stay legal (single-threaded, after their awaits).
    private let lock = NSLock()

    struct Account {
        var revision: Int
        var vault: AccountVault
        var updatedAt: Date?
    }

    var accounts: [String: Account] = [:]
    var reachable = true
    /// VX-501 (D-B4): a fetch that answers only after this long — and IGNORES cancellation (the slow server a bound must
    /// not wait for; the worst case: a read that still answers after its caller gave up). nil: at once (every earlier suite).
    var fetchDelay: Duration?
    var clock = Date(timeIntervalSinceReferenceDate: 790_000_000)
    /// Every call, in order — `fetch <id>`, `create <id>`, `update <id>`.
    private(set) var calls: [String] = []

    func snapshot(_ id: String) -> VaultSnapshot? {
        accounts[id].map { VaultSnapshot(accountID: id, revision: $0.revision, vault: $0.vault, updatedAt: $0.updatedAt) }
    }

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        if let fetchDelay {
            await Task.detached { try? await Task.sleep(for: fetchDelay) }.value
        }
        return try lock.withLock {
            calls.append("fetch \(accountID)")
            guard reachable else { throw VaultRefusal.unreachable }
            return snapshot(accountID)
        }
    }

    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        try lock.withLock {
        calls.append("create \(accountID)")
        guard reachable else { throw VaultRefusal.unreachable }
        guard accounts[accountID] == nil else { throw VaultRefusal.vaultExists }
        var named = vault
        named.updatedByDevice = device
        clock += 60
        accounts[accountID] = Account(revision: 1, vault: named, updatedAt: clock)
        return snapshot(accountID)!
        }
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?, device: String
    ) async throws -> VaultSnapshot {
        try lock.withLock {
        calls.append("update \(accountID)")
        guard reachable else { throw VaultRefusal.unreachable }
        guard var account = accounts[accountID] else { throw VaultRefusal.vaultAbsent }
        guard account.revision == expectedRevision else { throw VaultRefusal.revisionConflict }
        guard KeyProof.verifies(master: proofMaster, storedHash: account.vault.keyProofHash) else {
            throw VaultRefusal.keyProofRefused
        }
        if vault.keyProofHash != account.vault.keyProofHash {
            guard let successorMaster, KeyProof.macHash(master: successorMaster) == vault.keyProofHash else {
                throw VaultRefusal.keyProofRefused
            }
        }
        var named = vault
        named.updatedByDevice = device
        clock += 60
        account.vault = named
        account.revision += 1
        account.updatedAt = clock
        accounts[accountID] = account
        return snapshot(accountID)!
        }
    }

    /// A vault for `accountID` made elsewhere (another device turned sync on first) under `passphrase` and `words`.
    @discardableResult
    func plant(accountID: String, passphrase: String, words: [String], mode: ProtectionMode) throws -> AccountKeys {
        let kdf = FastIDsLeaf().mintPassphraseKDF()
        let (vault, keys) = try VaultModel.creating(
            passphrase: try PassphraseKey.derive(passphrase, kdf: kdf), words: try WordsKey.derive(words), mode: mode,
            device: "Another Mac", ids: FastIDsLeaf())
        lock.withLock { accounts[accountID] = Account(revision: 1, vault: vault, updatedAt: clock) }
        return keys
    }
}

/// Sync keys in memory, with session memory (the gatherer's facts read the items).
nonisolated final class PlantedSyncKeysLeaf: SyncKeysLeaf, TouchIDPressRiding, @unchecked Sendable {
    /// The same race class as the vault fake's: locked bodies.
    private let lock = NSLock()
    var items: [SyncKeysItemFact: AccountKeys] = [:]
    var session: [String: AccountKeys] = [:]
    /// VX-487 (b): every CONTEXT-LESS Touch ID read — on the real leaf each one mints its own `LAContext`, a prompt of its
    /// own (the one-press pin asserts the unlock makes none).
    private(set) var touchIDReads = 0
    /// VX-487 (b): every read that RODE a press, the press it rode, in order.
    private(set) var ridingReads: [TouchIDPressContext] = []
    /// VX-487 (b): the next riding reads THROW (a keychain answer the press did not cover) — the never-hostage pin.
    var ridingReadFails = false

    struct RidingReadFailed: Error {}

    /// VX-517 (D-B8): the PRODUCTION leaf's listing — `KeychainSyncKeysLeaf.syncKeyItems()` with no candidates wired
    /// (production wires none) is BLIND to a Touch ID item with no silent sibling. On, this leaf lists exactly that; off
    /// (every earlier suite), every item.
    var listsLikeProduction = false

    func syncKeyItems() throws -> [SyncKeysItemFact] {
        lock.withLock {
            guard listsLikeProduction else { return Array(items.keys) }
            let silentAccounts = Set(items.keys.filter { $0.itemClass == .silent }.map(\.accountID))
            return items.keys.filter { $0.itemClass == .silent || silentAccounts.contains($0.accountID) }
        }
    }
    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys? {
        lock.withLock {
            if itemClass == .touchid { touchIDReads += 1 }
            return items[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)]
        }
    }
    func readSyncKeys(accountID: String, riding press: TouchIDPressContext) throws -> AccountKeys? {
        try lock.withLock {
            ridingReads.append(press)
            // An ended press authorizes nothing (the real context answers LAErrorInvalidContext).
            if ridingReadFails || press.isInvalidated { throw RidingReadFailed() }
            return items[SyncKeysItemFact(accountID: accountID, itemClass: .touchid)]
        }
    }
    func writeSyncKeys(_ keys: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        lock.withLock { items[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = keys }
    }
    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        lock.withLock { items[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = nil }
    }
    func holdInSession(_ keys: AccountKeys?, accountID: String) { lock.withLock { session[accountID] = keys } }
    func sessionSyncKeys(accountID: String) -> AccountKeys? { lock.withLock { session[accountID] } }

    /// Every account any item or session memory names.
    var accountsHeld: Set<String> { Set(items.keys.map(\.accountID)).union(session.keys) }
}
