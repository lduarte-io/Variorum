//
//  AppleKeyCustody.swift
//  Variorum (shared: Mac + Mobile)
//
//  pre-13x batch 2a — **THE ICLOUD KEY A** (the postures design §3.1's A
//  row, §3.9, decision 3): one random 256-bit key per iCloud account,
//  minted the first time a Standard library exists on this iCloud (the
//  ceremony-free first launch included), else read; ONE iCloud-synchronizable
//  Keychain item — no access control (Apple does not sync ACL'd items),
//  `AfterFirstUnlock` (a ThisDeviceOnly class cannot sync by definition),
//  the SHARED access group (`…io.lduarte.Variorum.shared`, both targets'
//  entitlements since batch 0) named explicitly on every write, and the
//  data-protection marker on every query. **A is the only thing this design
//  ever puts in iCloud Keychain, and it is a KEY TO A WRAPPED COPY — never
//  the copy** (design law 2): the key file's `apple` box (L under A) and
//  the vault's Apple-held box (M under A) are what it opens. **A is never
//  deleted** (§14.5): after entering Castle it opens nothing current; it
//  serves other libraries and accounts on the same iCloud.
//
//  THE QUERY FAMILY — ONE builder (the spike's Q5 rule, measured on
//  macOS 26.5.2): every verb — add, read, update, delete, probe — carries
//  `kSecAttrSynchronizable = true` (the flag decides whether the item is
//  VISIBLE at all — a flagless search never matches, and a flagless
//  delete is a silent no-op), `kSecAttrAccessGroup = <shared>` (the group
//  decides WHERE a write lands — a group-less write lands in the first
//  entitled group, invisible to the phone — and which other apps see it),
//  and `kSecUseDataProtectionKeychain` (the 13p-fix partition rule).
//  `KeychainPartitionTests` asserts all three structurally.
//
//  THE ACCOUNT CARRIES THE DEV-SCOPE DISCRIMINATOR (the spike's surprise
//  4): the shared group is config-independent by design, so a Debug build
//  and the Release install on one iCloud would otherwise share one A —
//  the account is `<scope>-apple-key` (`Variorum` vs `Variorum-dev`), the
//  store-key family's own fence extended.
//
//  THE VALUE is `{id, key}` (JSON — the `SyncCustodyRecord` pattern): the
//  id is what the key file's `appleKeyID` and the vault's `apple_key_id`
//  name, so a client can tell "a different Apple ID's A" from "A not yet
//  propagated" and never adopts a key from the wire (design §12 — "the
//  client never wraps M or L under a key received from the network").
//
//  Recorded platform facts (the batch's one external lookup, 2026-09-05):
//  `SecItemAdd` of a synchronizable item SUCCEEDS with iCloud Keychain
//  off or no Apple ID — stored locally, propagating later; no public API
//  reports the iCloud Keychain toggle; propagation latency is unbounded
//  ("an arbitrary amount of time" — DTS) and there is NO notification, so
//  the waiting state polls; two devices minting concurrently converge by
//  most-recent-version-wins (the loser's key-file copy then names an id
//  iCloud no longer holds — the different-A arm, which the passphrase
//  road answers once and the reconcile heals).
//

import CryptoKit
import Foundation
import Security
import VariorumCore

/// The iCloud key: its id (what boxes are named by) and its bytes.
nonisolated struct AppleKey: Codable, Equatable, Sendable {
    var id: String
    var key: Data

    var symmetricKey: SymmetricKey { SymmetricKey(data: key) }

    static func mint() -> AppleKey {
        let bytes = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        return AppleKey(id: UUID().uuidString.lowercased(), key: bytes)
    }
}

extension AppleKey: CustomStringConvertible, CustomDebugStringConvertible {
    /// Redacted on purpose: the key must never ride into a log line.
    var description: String { "AppleKey(\(id), 256-bit, redacted)" }
    var debugDescription: String { description }
}

/// The injectable seam (tests script it; production is iCloud Keychain).
nonisolated struct AppleKeyLeaves: Sendable {
    /// The account's A, if this device can read it — nil = absent (not
    /// yet propagated, iCloud Keychain off, no Apple ID, never minted).
    var read: @Sendable () -> AppleKey?
    /// Read, else MINT and write. nil = the Keychain refused the write
    /// (the honest "not landed" answer — never a key held in memory alone).
    var readOrMint: @Sendable () -> AppleKey?

    static func live(scope: String) -> AppleKeyLeaves {
        AppleKeyLeaves(
            read: { AppleKeyKeychain.read(scope: scope) },
            readOrMint: { AppleKeyKeychain.readOrMint(scope: scope) })
    }

    /// The scripted world: an in-memory A, with the Keychain's refusals
    /// scriptable.
    static func inMemory(backing: InMemoryAppleKeyBacking) -> AppleKeyLeaves {
        AppleKeyLeaves(
            read: { backing.key },
            readOrMint: {
                if let held = backing.key { return held }
                guard backing.writesSucceed else { return nil }
                let minted = AppleKey.mint()
                backing.key = minted
                return minted
            })
    }
}

nonisolated final class InMemoryAppleKeyBacking: @unchecked Sendable {
    private let lock = NSLock()
    private var _key: AppleKey?
    private var _writesSucceed = true
    init(key: AppleKey? = nil) { _key = key }
    var key: AppleKey? {
        get { lock.lock(); defer { lock.unlock() }; return _key }
        set { lock.lock(); defer { lock.unlock() }; _key = newValue }
    }
    var writesSucceed: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _writesSucceed }
        set { lock.lock(); defer { lock.unlock() }; _writesSucceed = newValue }
    }
}

/// The Keychain half — ONE query builder for the whole family.
nonisolated enum AppleKeyKeychain {
    static let service = "io.lduarte.Variorum.apple-key"
    /// The team prefix `$(AppIdentifierPrefix)` resolves to (the project
    /// file's; every signed entitlement dump carries it).
    static let teamPrefix = "<apple-team-id>."
    static let sharedGroupSuffix = "io.lduarte.Variorum.shared"
    /// THE SHARED ACCESS GROUP (§3.9) — the second entry of both targets'
    /// `keychain-access-groups`; `EntitlementsTests` pins the order.
    static var sharedGroup: String { teamPrefix + sharedGroupSuffix }

    /// The account: the dev-scope discriminator, so a Debug build never
    /// reads the Release install's A (pinned).
    static func account(scope: String) -> String { "\(scope)-apple-key" }

    /// THE ONE BUILDER (Q5's rule): the flag, the group and the marker on
    /// every verb. `account` is a parameter so the signed-host round trip
    /// can run under a THROWAWAY account and delete it with the flagged
    /// delete, never touching a real scope's A.
    static func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecAttrSynchronizable as String: true,
            kSecAttrAccessGroup as String: sharedGroup,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    static func read(scope: String) -> AppleKey? {
        read(account: account(scope: scope))
    }

    static func read(account: String) -> AppleKey? {
        var query = query(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(AppleKey.self, from: data)
    }

    /// Read, else mint and add. A duplicate at the add (a race with iCloud
    /// propagation landing between the read and the write) re-reads
    /// rather than overwriting — an A that arrived from another device
    /// wins over one minted here a moment ago.
    static func readOrMint(scope: String) -> AppleKey? {
        readOrMint(account: account(scope: scope))
    }

    static func readOrMint(account: String) -> AppleKey? {
        if let existing = read(account: account) { return existing }
        let minted = AppleKey.mint()
        guard let data = try? JSONEncoder().encode(minted) else { return nil }
        var attributes = query(account: account)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem { return read(account: account) }
        guard status == errSecSuccess else { return nil }
        // Verified, never assumed (the CustodyHandover discipline): the
        // item must READ BACK through the family's own query.
        return read(account: account)
    }

    /// The FLAGGED delete — the migration's and the pins' door only: A is
    /// never deleted in production (§14.5). Released = gone, or never there.
    @discardableResult
    static func delete(account: String) -> Bool {
        let status = SecItemDelete(query(account: account) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
