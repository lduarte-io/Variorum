//
//  Fakes.swift
//  VariorumCoreTests — VX-305 U4: the scenario world's FAKES, with the real
//  semantics the measured Apple facts give them (`notes/plans/vx-266/second-
//  opinion-apple-facts.md`; design §4.1):
//    - a DEVICE KEYCHAIN where a Touch ID item (`.biometryCurrentSet`) is made
//      unreadable — never deleted — by any enrollment change (§4.1–4.5 of the
//      facts: "invalidated", the stale row stays), a closed lid, a disconnected
//      or unpaired keyboard and a lockout are transient (§5), a macOS update
//      moves the stored state hash with nothing changed (§4.7), and Keychain
//      Access reads every item's secret except a Touch ID item's, and lists,
//      edits the attributes of and deletes every item, Touch ID items included
//      (§12 — whether it can list/delete a Touch ID item is phase 3's drill; the
//      world assumes it can);
//    - an ICLOUD KEYCHAIN per Apple account with a propagation delay (nothing
//      reaches another device until a sync happens — §6(e): no bound), delete
//      propagation and no recovery (§6, §12.8), a per-device OFF SWITCH the app
//      can't see — what a device makes while it's off stays on that device and
//      syncs once it's turned on (§6(a)); a delete made while it's off reaches
//      only that device, and the cloud's copy comes back when sync does (design
//      §8's residue) — and the SAME-NAME RULE: two devices writing one name leave
//      one survivor, the newer (§6(e): "one or the other is chosen");
//    - FILE SYSTEMS with copies, Time Machine snapshots and rollback (the plan
//      file is excluded from backups) and container deletion;
//    - the VAULT with CAS and the key proof, over the model's row (VX-378 U2:
//      P and W only, the mode flag, the earlier sync keys — rules 14, 15).
//  Everything here is DUMB storage: it decides nothing about protection.
//

import CryptoKit
import Foundation

@testable import VariorumCore

// MARK: - Keychain items

/// A Keychain item's identity: its service and its account.
struct KName: Hashable, Comparable, CustomStringConvertible {
    var service: String
    var account: String

    static func < (a: KName, b: KName) -> Bool { (a.service, a.account) < (b.service, b.account) }
    var description: String { "\(service)/\(account)" }

    static func custody(_ scope: String, _ fingerprint: String, _ itemClass: ProtectionNames.CustodyClass) -> KName {
        KName(service: ProtectionNames.custodyService,
              account: ProtectionNames.custodyAccount(scope: scope, fingerprint: fingerprint, class: itemClass))
    }

    static func syncKeys(_ scope: String, _ account: String, _ itemClass: ProtectionNames.CustodyClass) -> KName {
        KName(service: ProtectionNames.syncKeysService,
              account: ProtectionNames.syncKeysAccount(scope: scope, accountID: account, class: itemClass))
    }

    static func memory(_ scope: String, _ libraryID: String) -> KName {
        KName(service: ProtectionNames.memoryService, account: ProtectionNames.memoryAccount(scope: scope, libraryID: libraryID))
    }

    static func apple(_ scope: String, _ id: String) -> KName {
        KName(service: ProtectionNames.appleKeyService, account: ProtectionNames.appleKeyAccount(scope: scope, id: id))
    }


}

/// What an item holds — typed, so a scan of the world can tell a secret from
/// a non-secret value.
enum KValue: Equatable {
    /// A raw library key (custody).
    case key(StoreKey)
    /// The account's sync keys (the master, the current and earlier sync keys).
    case syncKeys(AccountKeys)
    /// What this Mac remembers (non-secret, sealed).
    case memory(Sealed<DeviceMemory>)
    /// An Apple key `{id, key}` — the new per-id items and the old shared one.
    case apple(id: String, bytes: Data)

    var appleKey: AppleKeyMaterial? {
        if case .apple(let id, let bytes) = self { return AppleKeyMaterial(id: id, key: SymmetricKey(data: bytes)) }
        return nil
    }

    var libraryKey: StoreKey? {
        if case .key(let key) = self { return key }
        return nil
    }

    var material: AccountKeys? {
        if case .syncKeys(let material) = self { return material }
        return nil
    }
}

struct KItem: Equatable {
    var value: KValue
    /// `.biometryCurrentSet` — read only through a press, with the enrollment
    /// it was made under.
    var touchID = false
    var enrollment = 0
    var synchronizable = false
    /// An attribute Keychain Access can edit (it changes nothing the app reads).
    var label: String?
    /// VX-390 — THE STAMP: the library this custody item or Apple key was made
    /// for (production: a plain queryable attribute beside the item). nil: an
    /// item that carries none (a plant — rule 25's stated limit).
    var libraryID: String?
}

// MARK: - Biometry (`LAEnvironment`)

struct BiometryFake: Equatable {
    var hardware = true
    var fingers = 1
    /// Bumped by every enrollment change (add or remove a finger).
    var generation = 1
    var lidClosed = false
    var keyboardDisconnected = false
    var lockout = false
    /// Bumped by a macOS update — the hash moves, the enrollment doesn't.
    var osEpoch = 1

    var enrolled: Bool { hardware && fingers > 0 }

    var transient: TransientUnavailability? {
        if lidClosed { return .lidClosed }
        if keyboardDisconnected { return .keyboardDisconnected }
        if lockout { return .lockout }
        return nil
    }

    var usable: Bool { enrolled && transient == nil }

    var facts: BiometryFacts { BiometryFacts(hardware: hardware, enrolled: enrolled, transient: transient) }

    /// The enrollment state hash: moves on an enrollment change AND on a
    /// macOS update (facts §4.7: "can change exceptionally between major OS
    /// versions even if the state of biometry has not changed").
    var stateHash: Data? { enrolled ? Data("\(generation)-\(osEpoch)".utf8) : nil }
}

// MARK: - The device keychain

/// One device's data-protection keychain: its local items and its replica of
/// the synchronizable ones (the same store, two labels — facts §6(a)).
final class DeviceKeychain {
    struct Replica: Equatable {
        /// nil: deleted here and queued as a tombstone for the cloud.
        var item: KItem?
        var version: Int
        /// Not yet uploaded.
        var dirty: Bool
    }

    var local: [KName: KItem] = [:]
    var synced: [KName: Replica] = [:]

    /// Every item present here (a queued tombstone is absent).
    func item(_ name: KName) -> KItem? { local[name] ?? synced[name]?.item }

    func names(service: String) -> [KName] {
        (Array(local.keys) + synced.compactMap { $0.value.item == nil ? nil : $0.key })
            .filter { $0.service == service }.sorted()
    }
}

// MARK: - iCloud Keychain, per Apple account

/// The cloud half of one Apple account's iCloud Keychain. Devices sync with it
/// only when they sync (the delay) and only while their switch is on.
final class AppleAccountFake {
    struct Entry: Equatable {
        /// nil: a tombstone — deleted, with no recovery.
        var item: KItem?
        var version: Int
    }

    let id: String
    var cloud: [KName: Entry] = [:]

    init(id: String) { self.id = id }

    /// The items any device of this Apple account could obtain (the Apple
    /// account holder's reach — facts §7).
    var liveItems: [KName: KItem] { cloud.compactMapValues(\.item) }
}

// MARK: - Files

/// A SQLCipher library file, as the world models it: the key it is under,
/// the record inside it, and a token of the writing it holds.
struct LibraryImage: Equatable {
    var libraryID: String
    var fingerprint: String
    var record: ProtectionRecord?
    /// The writing's generation (a counter standing in for the rows).
    var writing: Int
    /// The account its synced rows were stamped by.
    var rowsOwner: String?
}

enum SFile: Equatable {
    case library(LibraryImage)
    case keyFile(KeyFile)
    case plan(Sealed<ProtectionPlan>)
    /// "A library lived here".
    case marker
    /// A plaintext export carrying its library ID.
    case plaintext(libraryID: String, writing: Int)

    var library: LibraryImage? {
        if case .library(let image) = self { return image }
        return nil
    }

    var keyFile: KeyFile? {
        if case .keyFile(let document) = self { return document }
        return nil
    }

    func encodedKeyFile() -> Data? { try? keyFile?.encoded() }
}

/// A folder tree: the container's slot folder, or a far (iCloud Drive) folder
/// shared by the Macs on one Apple account. Paths are "/"-separated, relative.
final class FolderFS {
    var files: [String: SFile] = [:]

    func paths(under prefix: String) -> [String] { files.keys.filter { $0.hasPrefix(prefix) }.sorted() }

    /// The listing the catalog builds from.
    func catalogEntries(place: CatalogPlace) -> [CatalogEntry] {
        files.keys.sorted().compactMap { path in
            var parts = path.split(separator: "/").map(String.init)
            guard let name = parts.popLast() else { return nil }
            let bytes = files[path]?.encodedKeyFile()
            return CatalogEntry(place: place, folders: parts, name: name, bytes: bytes)
        }
    }

    func snapshot() -> [String: SFile] { files }
}

// MARK: - The server's vault

/// The server: one vault per Variorum account — CAS on the revision and the
/// key proof (VX-378 U2: no rotation, no walk — rule 15's earlier sync keys
/// live in the row).
final class ServerFake {
    struct Account {
        var revision: Int
        var vault: AccountVault
        var updatedAt: Date?
    }

    var accounts: [String: Account] = [:]
    var clock = Date(timeIntervalSinceReferenceDate: 790_000_000)
    /// Every vault write, in order — (account, what it read as).
    var writes: [(account: String, what: String)] = []

    func snapshot(_ id: String) -> VaultSnapshot? {
        accounts[id].map { VaultSnapshot(accountID: id, revision: $0.revision, vault: $0.vault, updatedAt: $0.updatedAt) }
    }

    static func describe(_ vault: AccountVault) -> String { vault.mode.rawValue }

    func create(_ vault: AccountVault, accountID: String) throws -> VaultSnapshot {
        guard accounts[accountID] == nil else { throw VaultRefusal.vaultExists }
        clock += 60
        accounts[accountID] = Account(revision: 1, vault: vault, updatedAt: clock)
        writes.append((accountID, "create " + Self.describe(vault)))
        return snapshot(accountID)!
    }

    func update(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?
    ) throws -> VaultSnapshot {
        guard var account = accounts[accountID] else { throw VaultRefusal.vaultAbsent }
        guard account.revision == expectedRevision else { throw VaultRefusal.revisionConflict }
        guard KeyProof.verifies(master: proofMaster, storedHash: account.vault.keyProofHash) else {
            throw VaultRefusal.keyProofRefused
        }
        // VX-307 U1 — hash and secret land together (the wire's rule).
        if vault.keyProofHash != account.vault.keyProofHash {
            guard let successorMaster, KeyProof.macHash(master: successorMaster) == vault.keyProofHash else {
                throw VaultRefusal.keyProofRefused
            }
        }
        clock += 60
        account.vault = vault
        account.revision += 1
        account.updatedAt = clock
        accounts[accountID] = account
        writes.append((accountID, Self.describe(vault)))
        return snapshot(accountID)!
    }

    /// `account_purge` — the whole account gone (a bare session can do it).
    func delete(accountID: String) { accounts[accountID] = nil }
}

/// The world's seeded randomness — every random thing the executor mints
/// comes from here, so a failing seed replays (SplitMix64).
struct SeededRandom: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) { state = seed &+ 0x9E37_79B9_7F4A_7C15 }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    mutating func bytes(_ count: Int) -> Data {
        var data = Data(capacity: count)
        while data.count < count {
            var word = next()
            withUnsafeBytes(of: &word) { data.append(contentsOf: $0) }
        }
        return data.prefix(count)
    }

    mutating func uuid() -> String {
        let b = [UInt8](bytes(16))
        var u = b
        u[6] = (u[6] & 0x0F) | 0x40
        u[8] = (u[8] & 0x3F) | 0x80
        let hex = u.map { String(format: "%02x", $0) }.joined()
        let c = Array(hex)
        return "\(String(c[0..<8]))-\(String(c[8..<12]))-\(String(c[12..<16]))-\(String(c[16..<20]))-\(String(c[20..<32]))"
    }

    mutating func int(_ range: Range<Int>) -> Int {
        guard range.count > 0 else { return range.lowerBound }
        return range.lowerBound + Int(next() % UInt64(range.count))
    }

    mutating func chance(_ percent: Int) -> Bool { int(0..<100) < percent }

    mutating func pick<T>(_ items: [T]) -> T? { items.isEmpty ? nil : items[int(0..<items.count)] }
}
