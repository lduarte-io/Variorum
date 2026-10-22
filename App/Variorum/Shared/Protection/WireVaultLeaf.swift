//
//  WireVaultLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-307 U1 — THE PRODUCTION `VaultLeaf`: the core's `AccountVaultClient` (the marker-14 `key_vault`
//  shape, `Server/supabase/17_phase_vx307_vault.sql`) behind the executor's leaf protocol. It replaces
//  `UnreachableVaultLeaf` at `ProtectionSystem`'s composition. VX-329 U1: the road is the only road, in Release too; today's
//  postures machinery over `KeyVaultClient` left the app with today's road (the core's `KeyVaultFormat` is this leaf's too).
//
//  Honest limits this phase: the mirror still speaks marker 13 (the 17 artifact deploys only in the
//  VX-329 release window — her ruling, the plan §1), so a LIVE fetch of a real account answers
//  `preLockstepRow`; and the dev store binds no account (creation binds none), so no act of this phase
//  reaches the network at all. The convergence proof runs on the fake server (`AccountVaultWireTests`,
//  the executor convergence suites).
//

import CryptoKit
import Foundation
import VariorumCore

nonisolated final class WireVaultLeaf: VaultLeaf, @unchecked Sendable {
    private let client: AccountVaultClient

    init(client: AccountVaultClient) {
        self.client = client
    }

    /// The production leaf for a store scope — nil when the project is unconfigured (the vault stays
    /// unreachable and an act that needs it rolls back, exactly as before). The auth session is the
    /// scope's own (the pre-13x corner 47 posture: a dev-store build never adopts the installed build's
    /// session). VX-308 U1 (R-3): the session FOLLOWS the current sign-in — who is signed in is read per call, and a
    /// sign-out then a sign-in to another account is served as that account (`FollowingSessionProvider`), never the
    /// session this leaf first read.
    static func live(scope: String, deviceName: String) -> WireVaultLeaf? {
        guard ProjectConfig.variorumConfigured else { return nil }
        let auth = FollowingSessionProvider(
            signedInUser: {
                KeychainAuthStorage.load(service: KeychainAuthStorage.variorumService, scope: scope)?.userID
            },
            make: { AuthSession(configuration: ProjectConfig.variorumAuth, store: .keychain(scope: scope)) })
        return WireVaultLeaf(client: AccountVaultClient(
            configuration: AccountVaultClient.Configuration(
                projectURL: ProjectConfig.variorumProjectURL,
                apiKey: ProjectConfig.variorumPublishableKey,
                deviceName: deviceName),
            sessionProvider: auth))
    }

    func fetchVault(accountID: String) async throws -> VaultSnapshot? {
        try await client.fetchVault(accountID: accountID)
    }

    func createVault(_ vault: AccountVault, accountID: String, device: String) async throws -> VaultSnapshot {
        try await client.createVault(vault, accountID: accountID, device: device)
    }

    func updateVault(
        _ vault: AccountVault, accountID: String, expectedRevision: Int, proofMaster: SymmetricKey,
        successorMaster: SymmetricKey?, device: String
    ) async throws -> VaultSnapshot {
        try await client.updateVault(
            vault, accountID: accountID, expectedRevision: expectedRevision, proofMaster: proofMaster,
            successorMaster: successorMaster, device: device)
    }
}
