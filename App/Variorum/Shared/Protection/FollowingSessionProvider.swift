//
//  FollowingSessionProvider.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-308 U1 piece 3 (R-3, approved at the U1 ARBITRATION) — THE VAULT LEAF FOLLOWS THE CURRENT SIGN-IN. The new road's
//  vault leaf (`WireVaultLeaf`) is composed once per open; its session provider used to be one `AuthSession`, which reads
//  the scope's stored session ONCE (at first use) and keeps it — so after a sign-out and a sign-in to ANOTHER account
//  (the §5 row-7 walk's own sequence) the leaf kept answering as the first account (`notSignedIn` to every read) until
//  the next open. This provider asks WHO is signed in now on every call (the stored session's user — a read) and serves
//  that user through a provider made for them, made fresh whenever the signed-in user changed; with no one signed in it
//  refuses `notSignedIn` before anything composes.
//
//  Routed, not fixed (F-U1-1 — VX-423's family): a provider made here and the app's own `AuthSession` each refresh the
//  same rotating refresh token on their own.
//

import Foundation
import VariorumCore

actor FollowingSessionProvider: UserSessionProviding {
    /// Who is signed in now (the stored session's user id) — nil: no one.
    private let signedInUser: @Sendable () -> String?
    /// A provider for the user signed in now (production: an `AuthSession` over the scope's stored session).
    private let make: @Sendable () -> any UserSessionProviding
    private var current: (user: String, provider: any UserSessionProviding)?

    init(signedInUser: @escaping @Sendable () -> String?, make: @escaping @Sendable () -> any UserSessionProviding) {
        self.signedInUser = signedInUser
        self.make = make
    }

    /// The provider for whoever is signed in now — made again when the user changed.
    private func provider() throws -> any UserSessionProviding {
        guard let user = signedInUser() else {
            current = nil
            throw UserSessionError.notSignedIn
        }
        if let current, current.user == user { return current.provider }
        let fresh = make()
        current = (user, fresh)
        return fresh
    }

    func currentSession() async throws -> UserSession {
        try await provider().currentSession()
    }

    func refreshedSession() async throws -> UserSession {
        try await provider().refreshedSession()
    }
}
