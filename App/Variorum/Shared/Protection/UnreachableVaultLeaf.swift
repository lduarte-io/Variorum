//
//  UnreachableVaultLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE VAULT, UNREACHABLE THIS PHASE (P-VX306-K3, `notes/plans/vx-306-castle-open-road.md`
//  §7b): the server's `key_vault` still has its pre-rules shape until VX-307's SyncSpec §12 lockstep wires
//  the client, so every call throws `VaultRefusal.unreachable` — the executor's own "out of reach" (an act
//  that needed the vault rolls back; nothing was read or written). Nothing synced runs on the new road
//  this phase, and a library created here binds no account. Today's sync custody keeps running on its own
//  keys, untouched.
//

import Foundation
import CryptoKit
import VariorumCore

nonisolated final class UnreachableVaultLeaf: VaultLeaf, @unchecked Sendable {
    func fetchVault(accountID: String) async throws -> VaultSnapshot? { throw VaultRefusal.unreachable }

    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        throw VaultRefusal.unreachable
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?, device: String
    ) async throws -> VaultSnapshot {
        throw VaultRefusal.unreachable
    }
}
