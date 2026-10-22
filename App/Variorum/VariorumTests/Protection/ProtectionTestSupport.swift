//
//  ProtectionTestSupport.swift
//  VariorumTests — VX-306 U1a: the Mac suites' shared support for the production protection leaves.
//
//  THROWAWAY SCOPES ONLY: every keychain test plants under `vx306-<uuid>` (the tripwire refuses the real
//  scopes, `Variorum` / `Variorum-dev`, in a test process) and PURGES that scope from all four device-only
//  services in `defer` — the custody, sync-keys and memory items, by listing the scope's accounts. Nothing
//  synchronizable is written outside the opt-in Apple-key suite. Temp folders stand in for the slot.
//

import CryptoKit
import Foundation
import Security
import Testing

@testable import Variorum
import VariorumCore

nonisolated final class ThrowawayScope {
    let scope = "vx306-\(UUID().uuidString.lowercased())"

    static let deviceOnlyServices = [
        ProtectionNames.custodyService, ProtectionNames.syncKeysService, ProtectionNames.memoryService,
    ]

    /// Every device-only item of this scope deleted (the scope's own accounts only).
    func purge() {
        for service in Self.deviceOnlyServices {
            let listed = (try? ProtectionKeychain.list(service: service, residence: .deviceOnly)) ?? []
            for attributes in listed {
                guard let account = ProtectionKeychain.account(of: attributes), account.hasPrefix(scope + "-") else { continue }
                try? ProtectionKeychain.delete(service: service, account: account, residence: .deviceOnly)
            }
        }
    }

    /// The accounts this scope holds under `service` (attributes only).
    func accounts(_ service: String) -> [String] {
        ((try? ProtectionKeychain.list(service: service, residence: .deviceOnly)) ?? [])
            .compactMap(ProtectionKeychain.account(of:))
            .filter { $0.hasPrefix(scope + "-") }
            .sorted()
    }
}

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
nonisolated final class PlantedCustodyLeaf: CustodyLeaf, @unchecked Sendable {
    var items: [CustodyItemFact: StoreKey] = [:]
    var unreadable: Set<String> = []
    var listingFails = false
    private(set) var reads: [ProtectionNames.CustodyClass] = []
    /// VX-306 U3: every write and delete, in order (Look inside's write-nothing proof reads it).
    private(set) var writes: [String] = []

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

/// A sync-keys leaf holding nothing (the gatherer suite stays off the Keychain).
nonisolated final class EmptySyncKeysLeaf: SyncKeysLeaf, @unchecked Sendable {
    func syncKeyItems() throws -> [SyncKeysItemFact] { [] }
    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys? { nil }
    func writeSyncKeys(_ keys: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {}
    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {}
    func holdInSession(_ keys: AccountKeys?, accountID: String) {}
    func sessionSyncKeys(accountID: String) -> AccountKeys? { nil }
}
