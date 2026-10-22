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
//  VX-329 U3 — VX-423: THE LEAF RIDES THE PROCESS'S ONE REFRESH AUTHORITY. It used to mint its own `AuthSession` over the
//  scope's stored session (VX-308 R-3's `FollowingSessionProvider`, made per signed-in user), beside the services' own over
//  the SAME item — two actors each refreshing the one rotating refresh token from their own cached copy, so the second to
//  refresh presented a token the first had spent (`refresh_token_already_used`; the whole family revoked, sync stopped
//  until a new sign-in). The leaf is now HANDED the session (`AppBootstrap.auth`, through the road's inputs and the
//  system), and follows a sign-out and a sign-in to another account because every sign-in and sign-out in the process
//  lands in that one actor (R-3's claim, by construction — the U3 RECORD's R-U3-2; `FollowingSessionProvider` deleted).
//

import CryptoKit
import Foundation
import VariorumCore

nonisolated final class WireVaultLeaf: VaultLeaf, @unchecked Sendable {
    private let client: AccountVaultClient

    init(client: AccountVaultClient) {
        self.client = client
    }

    /// The production leaf — nil when the project is unconfigured (the vault stays unreachable and an act that needs it
    /// rolls back, exactly as before). `session` is the one it rides: in production the process's one refresh authority
    /// (`AppBootstrap.auth` — VX-423), never a session of its own. `load` is the vault endpoint's seam for the pins that
    /// script it (the client's own `load` form); production never passes it.
    static func live(
        deviceName: String, session: any UserSessionProviding,
        load: (@Sendable (URLRequest) async throws -> (Data, URLResponse))? = nil
    ) -> WireVaultLeaf? {
        guard ProjectConfig.variorumConfigured else { return nil }
        let configuration = AccountVaultClient.Configuration(
            projectURL: ProjectConfig.variorumProjectURL,
            apiKey: ProjectConfig.variorumPublishableKey,
            deviceName: deviceName)
        let client = load.map { AccountVaultClient(configuration: configuration, sessionProvider: session, load: $0) }
            ?? AccountVaultClient(configuration: configuration, sessionProvider: session)
        return WireVaultLeaf(client: client)
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

/// VX-423 — the sign-in of a protection system composed WITHOUT the process's refresh authority (a test world's
/// `ProtectionSystem.init`): no one's. Every vault call refuses `notSignedIn` before anything is sent — exactly what the
/// leaf's own per-system session answered over a scope holding no stored session, so no world's refusal changes.
/// Production always hands the authority (`ProtectionSystem.live` requires it).
nonisolated struct NobodySignedIn: UserSessionProviding {
    func currentSession() async throws -> UserSession { throw UserSessionError.notSignedIn }
}
