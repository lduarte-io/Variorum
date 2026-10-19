//
//  ProtectionAccountSupport.swift
//  VariorumTests — VX-308 U1: the account suites' planted vault and sync keys. NO NETWORK: the vault is the core's
//  `ExecutorVault` semantics restated over the app's `VaultLeaf` (the core test target's fakes are not reachable from
//  here) — the revision CAS, the key proof, the hash-and-secret-together rule, typed refusals; the sync keys are an
//  in-memory leaf with session memory. Both ride `PlantedRoad` (its `vault` / `syncKeys`), so the account road runs on
//  the planted road and also headless in the implementer's SwiftPM harness.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// The server's vault, planted (the core's `ExecutorVault`, restated): CAS on the revision and the key proof.
nonisolated final class PlantedVaultLeaf: VaultLeaf, @unchecked Sendable {
    struct Account {
        var revision: Int
        var vault: AccountVault
        var updatedAt: Date?
    }

    var accounts: [String: Account] = [:]
    var reachable = true
    var clock = Date(timeIntervalSinceReferenceDate: 790_000_000)
    /// Every call, in order — `fetch <id>`, `create <id>`, `update <id>`.
    private(set) var calls: [String] = []

    func snapshot(_ id: String) -> VaultSnapshot? {
        accounts[id].map { VaultSnapshot(accountID: id, revision: $0.revision, vault: $0.vault, updatedAt: $0.updatedAt) }
    }

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        calls.append("fetch \(accountID)")
        guard reachable else { throw VaultRefusal.unreachable }
        return snapshot(accountID)
    }

    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        calls.append("create \(accountID)")
        guard reachable else { throw VaultRefusal.unreachable }
        guard accounts[accountID] == nil else { throw VaultRefusal.vaultExists }
        var named = vault
        named.updatedByDevice = device
        clock += 60
        accounts[accountID] = Account(revision: 1, vault: named, updatedAt: clock)
        return snapshot(accountID)!
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?, device: String
    ) async throws -> VaultSnapshot {
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

    /// A vault for `accountID` made elsewhere (another device turned sync on first) under `passphrase` and `words`.
    @discardableResult
    func plant(accountID: String, passphrase: String, words: [String], mode: ProtectionMode) throws -> AccountKeys {
        let kdf = FastIDsLeaf().mintPassphraseKDF()
        let (vault, keys) = try VaultModel.creating(
            passphrase: try PassphraseKey.derive(passphrase, kdf: kdf), words: try WordsKey.derive(words), mode: mode,
            device: "Another Mac", ids: FastIDsLeaf())
        accounts[accountID] = Account(revision: 1, vault: vault, updatedAt: clock)
        return keys
    }
}

/// Sync keys in memory, with session memory (the gatherer's facts read the items).
nonisolated final class PlantedSyncKeysLeaf: SyncKeysLeaf, @unchecked Sendable {
    var items: [SyncKeysItemFact: AccountKeys] = [:]
    var session: [String: AccountKeys] = [:]

    func syncKeyItems() throws -> [SyncKeysItemFact] { Array(items.keys) }
    func readSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws -> AccountKeys? {
        items[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)]
    }
    func writeSyncKeys(_ keys: AccountKeys, accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        items[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = keys
    }
    func deleteSyncKeys(accountID: String, itemClass: ProtectionNames.CustodyClass) throws {
        items[SyncKeysItemFact(accountID: accountID, itemClass: itemClass)] = nil
    }
    func holdInSession(_ keys: AccountKeys?, accountID: String) { session[accountID] = keys }
    func sessionSyncKeys(accountID: String) -> AccountKeys? { session[accountID] }

    /// Every account any item or session memory names.
    var accountsHeld: Set<String> { Set(items.keys.map(\.accountID)).union(session.keys) }
}

/// A planted road with an account's machinery: the planted vault and sync keys, a fixed sign-in.
@MainActor
enum PlantedAccount {
    static let account = "acct-a"
    static let other = "acct-b"
    static let email = "her@example.test"
    static let signedIn = SessionFact.signedIn(accountID: account, email: email)
    static let passphrase = "correct horse battery staple"

    /// A road whose systems carry a planted vault and planted sync keys.
    static func road() -> (road: PlantedRoad, vault: PlantedVaultLeaf, keys: PlantedSyncKeysLeaf) {
        let road = PlantedRoad()
        let vault = PlantedVaultLeaf()
        let keys = PlantedSyncKeysLeaf()
        road.vault = vault
        road.syncKeys = keys
        return (road, vault, keys)
    }

    /// The pane's one read over `session` as `signIn`.
    static func read(_ session: ProtectionRoadSession, _ signIn: SessionFact) async throws -> ProtectionPaneFacts {
        try #require(await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: nil))
    }
}
