//
//  KeychainSyncKeysLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `SyncKeysLeaf` (`Executor/Leaves.swift`): the bound account's sync keys
//  (`AccountKeys` — the master, the current sync key and every earlier one, rule 15), one item per account
//  under `ProtectionNames.syncKeysService` / `syncKeysAccount`, in the same two shapes as custody (a silent
//  item for Standard; a `.biometryCurrentSet` item or SESSION MEMORY for Castle — rule 15's custody), the
//  value `ProtectionCoding` JSON. `holdInSession` is in memory only — gone at a relock or a crash.
//
//  Real and tested; NO ACT OF THIS PHASE CALLS IT (P-VX306-K3: the vault is unreachable, the record names
//  no account — creation binds none; sync setup is VX-308's door). Today's sync-key custody
//  (`SyncCustodyRecord`, `DeviceKeySyncProvider`, `E2EEKeychainStorage`) was deleted with today's road at VX-329 U1; this
//  leaf is the engine's one custody since.
//
//  VX-487 (b): the Touch ID unlock loads the account's Touch ID item into session memory in the SAME press — the read rides
//  the context the custody read evaluated (`readSyncKeys(accountID:riding:)`, `TouchIDPressContext.swift`); the
//  context-less Touch ID read below still mints its own (an act's press).
//

import Foundation
import LocalAuthentication
import Security
import VariorumCore

nonisolated final class KeychainSyncKeysLeaf: SyncKeysLeaf, TouchIDPressRiding, @unchecked Sendable {
    static let service = ProtectionNames.syncKeysService

    let scope: String
    /// The account ids whose Touch ID item the listing probes for by name (the listing skips an item that
    /// would need authentication — `ProtectionKeychain`). Production wires none, so the listing is BLIND to a
    /// Touch ID item with no silent sibling — why every forget and drop deletes BY NAME and never reads this
    /// listing (VX-517, the VX-510 run record's D-B8).
    private let touchIDCandidates: @Sendable () -> Set<String>
    private let lock = NSLock()
    private var session: [String: AccountKeys] = [:]

    init(scope: String, touchIDCandidates: @escaping @Sendable () -> Set<String> = { [] }) {
        self.scope = scope
        self.touchIDCandidates = touchIDCandidates
    }

    func account(_ accountID: String, _ itemClass: ProtectionNames.CustodyClass) -> String {
        ProtectionNames.syncKeysAccount(scope: scope, accountID: accountID, class: itemClass)
    }

    func syncKeyItems() throws -> [SyncKeysItemFact] {
        var items = Set(try ProtectionKeychain.list(service: Self.service, residence: .deviceOnly).compactMap { attributes in
            guard let account = ProtectionKeychain.account(of: attributes),
                  let parsed = ProtectionNames.parseSyncKeysAccount(account, scope: scope) else { return nil }
            return SyncKeysItemFact(accountID: parsed.accountID, itemClass: parsed.class)
        } as [SyncKeysItemFact])
        for accountID in touchIDCandidates().union(items.map(\.accountID)) where ProtectionNames.isUUID(accountID) {
            let fact = SyncKeysItemFact(accountID: accountID, itemClass: .touchid)
            guard !items.contains(fact) else { continue }
            if try ProtectionKeychain.exists(service: Self.service, account: account(accountID, .touchid), residence: .deviceOnly) {
                items.insert(fact)
            }
        }
        return items.sorted { ($0.accountID, $0.itemClass.rawValue) < ($1.accountID, $1.itemClass.rawValue) }
    }

    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys? {
        var context: LAContext?
        if itemClass == .touchid {
            let press = LAContext()
            press.localizedReason = KeychainCustodyLeaf.pressReason
            press.localizedFallbackTitle = ""
            context = press
        }
        do {
            return try ProtectionKeychain.readData(
                service: Self.service, account: account(accountID, itemClass), residence: .deviceOnly, context: context)
                .flatMap { try? ProtectionCoding.decoder().decode(AccountKeys.self, from: $0) }
        } catch ProtectionKeychain.KeychainError.status(let status, _)
            where itemClass == .touchid
            && (status == errSecUserCanceled || status == errSecAuthFailed || status == errSecInteractionNotAllowed) {
            return nil  // the press failed or was cancelled
        }
    }

    /// VX-487 (b) — `TouchIDPressRiding`: the account's Touch ID item read under the lobby's press, already evaluated by the
    /// custody read (one press, never two prompts). `interactionNotAllowed` makes the ride unable to show UI: an
    /// authenticated context answers without asking (SecItem.h); a read it does not cover throws
    /// `errSecInteractionNotAllowed` instead of prompting — the caller logs it and the library opens all the same.
    func readSyncKeys(accountID: String, riding press: TouchIDPressContext) throws -> AccountKeys? {
        press.context.interactionNotAllowed = true
        return try ProtectionKeychain.readData(
            service: Self.service, account: account(accountID, .touchid), residence: .deviceOnly, context: press.context)
            .flatMap { try? ProtectionCoding.decoder().decode(AccountKeys.self, from: $0) }
    }

    func writeSyncKeys(_ keys: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "syncKeys.write")
        let account = account(accountID, itemClass)
        let data = try ProtectionCoding.canonical(keys)
        switch itemClass {
        case .silent:
            try ProtectionKeychain.upsert(
                service: Self.service, account: account, residence: .deviceOnly, data: data, label: nil,
                accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
            guard try readSyncKeys(accountID: accountID, itemClass: .silent) == keys else {
                throw ProtectionKeychain.KeychainError.writeDidNotReadBack("syncKeys.write")
            }
        case .touchid:
            // An ACL'd item is never updated in place (that would prompt): the old one goes first.
            try ProtectionKeychain.delete(service: Self.service, account: account, residence: .deviceOnly)
            guard let control = ProtectionKeychain.touchIDControl() else {
                throw ProtectionKeychain.KeychainError.status(errSecParam, "syncKeys.write access control")
            }
            let status = ProtectionKeychain.addGated(
                service: Self.service, account: account, data: data, label: nil, control: control)
            guard status == errSecSuccess else { throw ProtectionKeychain.KeychainError.status(status, "syncKeys.write touchid") }
            guard try ProtectionKeychain.exists(service: Self.service, account: account, residence: .deviceOnly) else {
                throw ProtectionKeychain.KeychainError.writeDidNotReadBack("syncKeys.write touchid")
            }
        }
    }

    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "syncKeys.delete")
        try ProtectionKeychain.delete(service: Self.service, account: account(accountID, itemClass), residence: .deviceOnly)
    }

    func holdInSession(_ keys: AccountKeys?, accountID: String) {
        lock.lock()
        session[accountID] = keys
        lock.unlock()
    }

    func sessionSyncKeys(accountID: String) -> AccountKeys? {
        lock.lock()
        defer { lock.unlock() }
        return session[accountID]
    }
}
