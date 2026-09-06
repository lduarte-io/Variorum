//
//  LobbyVaultRoad.swift
//  Variorum (shared: Mac + Mobile — the lobby's ONE pre-unlock network
//  contact)
//
//  pre-13x batch 4a — THE VAULT ROAD AT THE LOBBY (the postures design
//  §3.6 / corner 17 / ledger 10). A Castle lobby's two secret roads try the
//  LOCAL copy first; on a refusal, signed in and online, the typed word is
//  tried against the ACCOUNT's vault: derive per the vault's descriptor →
//  unwrap the master → the key file's master-wrapped copy of the library
//  key → L. That is what makes a passphrase (or words) changed on ANOTHER
//  device work here at once, and what lets the twelve words open a library
//  whose local W copy never landed.
//
//  The pre-unlock contact is ONE authenticated vault READ — wrapped copies
//  only; a session without the master can fetch them and nothing else
//  (§3.10). It is composed from the SCOPED Keychain token store alone
//  (`AuthSession(store: .keychain(scope:))` — corner 47's fence: a dev
//  store's scope starts signed out and has no road) and a vault client
//  named like every other (`DeviceName.current`); no session is ever
//  minted here, and a signed-out device has no road (the local copies
//  stand). `AppServices` composes the same two pieces at `.ready`; this is
//  the lobby's, before `.ready` exists.
//

import Foundation
import VariorumCore

nonisolated struct LobbyVaultRoad: Sendable {
    /// ONE authenticated vault READ: the fetched format (its wrapped copies
    /// — never a key), nil when signed out or when the account has no
    /// vault; THROWS on a transport failure (a `URLError` is the lobby's
    /// "offline" — it knows only by trying).
    var fetch: @Sendable () async throws -> KeyVaultFormat?

    /// The production road for a store scope. nil when the project is
    /// unconfigured (no sign-in surface exists at all).
    @MainActor
    static func live(scope: String) -> LobbyVaultRoad? {
        guard ProjectConfig.variorumConfigured else { return nil }
        let auth = AuthSession(
            configuration: ProjectConfig.variorumAuth,
            store: .keychain(scope: scope))
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: ProjectConfig.variorumProjectURL,
                apiKey: ProjectConfig.variorumPublishableKey,
                deviceName: DeviceName.current),
            sessionProvider: auth)
        return LobbyVaultRoad(fetch: {
            // Signed out ⇒ no road (no network is touched).
            guard await auth.currentUserID != nil else { return nil }
            return try await client.fetchVault()?.format
        })
    }
}
