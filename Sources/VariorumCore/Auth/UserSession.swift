import Foundation

/// One authenticated user session, as the transports consume it (Phase 9c —
/// generalized from Phase 9b's Fragments-side seam: ONE shape, once TWO
/// backends — the Variorum mirror's transport and, until the bridge's
/// 2026-09-04 retirement, the Fragments bridge's — each asking its own provider; Phase 9c's real sign-in implements the providers
/// in the app layer, so token persistence and refresh live in exactly one
/// place and never in a transport).
public struct UserSession: Equatable, Sendable {
    /// The user's access token (`Authorization: Bearer …`).
    public var accessToken: String
    /// The authenticated user id (`auth.uid()` under the backend's RLS).
    public var userID: String

    public init(accessToken: String, userID: String) {
        self.accessToken = accessToken
        self.userID = userID
    }
}

/// The auth seam every transport hangs on: a live bearer session per call,
/// so sign-in state and token refresh live behind the provider and the
/// engines never know about either.
public protocol UserSessionProviding: Sendable {
    /// A currently-valid session, refreshing proactively if the
    /// implementation can. Throwing means "not signed in / refresh failed" —
    /// the engines treat it like offline: skip the round, keep all state
    /// (outbox intact, cursor unmoved), retry on a later trigger.
    func currentSession() async throws -> UserSession

    /// Called after the SERVER rejected the current session (an HTTP 401):
    /// the token looked valid locally but is stale or revoked — force a
    /// refresh. The transport retries exactly once with the result; a
    /// second rejection surfaces as a failed round, never a loop.
    ///
    /// The default implementation returns `currentSession()` — a provider
    /// without refresh capability (fixed tokens, tests) retries once with
    /// what it has and the rejection surfaces honestly.
    func refreshedSession() async throws -> UserSession
}

extension UserSessionProviding {
    public func refreshedSession() async throws -> UserSession {
        try await currentSession()
    }
}

/// A fixed session injected at configuration time — headless tests, and the
/// interim Phase 8 paste-in path while it awaits Step 5's retirement. No
/// persistence, no refresh.
public struct StaticSessionProvider: UserSessionProviding {
    public let session: UserSession

    public init(session: UserSession) {
        self.session = session
    }

    public func currentSession() async throws -> UserSession {
        session
    }
}

public enum UserSessionError: Error, Equatable, Sendable {
    case notSignedIn
}
