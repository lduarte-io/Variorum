import Foundation

/// The Fragments-side auth SEAM (Phase 9b, built for Phase 9c to absorb).
///
/// The bridge authenticates as the author's Fragments USER — a user-auth
/// session, never the Supabase personal access token (server tooling), and
/// deliberately NOT coupled to Phase 8's Keychain paste-in (which retires at
/// 9c). Everything above the transport asks this protocol for a live bearer
/// session per call, so 9c's real sign-in — token refresh included — slots in
/// behind the seam without touching the engine or the transport's callers.
public struct FragmentsUserSession: Equatable, Sendable {
    /// The user's access token (`Authorization: Bearer …`).
    public var accessToken: String
    /// The authenticated user id (`auth.uid()` under Fragments' RLS).
    public var userID: String

    public init(accessToken: String, userID: String) {
        self.accessToken = accessToken
        self.userID = userID
    }
}

public protocol FragmentsSessionProviding: Sendable {
    /// A currently-valid session, refreshing if the implementation can.
    /// Throwing means "not signed in / refresh failed" — the bridge treats
    /// it like offline: skip the round, keep all state, retry later.
    func currentSession() async throws -> FragmentsUserSession
}

/// The Phase 9b concrete: a fixed session injected at configuration time
/// (headless tests; the deferred real-project pass runs post-9c on the real
/// sign-in, not on this). No persistence, no Keychain, no refresh — that is
/// 9c's half of the seam.
public struct StaticFragmentsSessionProvider: FragmentsSessionProviding {
    public let session: FragmentsUserSession

    public init(session: FragmentsUserSession) {
        self.session = session
    }

    public func currentSession() async throws -> FragmentsUserSession {
        session
    }
}

public enum FragmentsSessionError: Error, Equatable, Sendable {
    case notSignedIn
}
