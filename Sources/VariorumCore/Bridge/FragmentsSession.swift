import Foundation

/// The Fragments-side auth SEAM (Phase 9b, built for Phase 9c to absorb —
/// absorbed at 9c Step 2: the shape was generalized into
/// `UserSession`/`UserSessionProviding` in `Auth/UserSession.swift`, ONE
/// shape for the two backends, and these names remain as the bridge's
/// vocabulary for it).
///
/// The bridge authenticates as the author's Fragments USER — a user-auth
/// session, never the Supabase personal access token (server tooling), and
/// deliberately NOT coupled to Phase 8's Keychain paste-in (which retires at
/// 9c). Everything above the transport asks the protocol for a live bearer
/// session per call, so the real sign-in — token refresh included — slots in
/// behind the seam without touching the engine or the transport's callers.
public typealias FragmentsUserSession = UserSession

public typealias FragmentsSessionProviding = UserSessionProviding

/// The fixed-session concrete (headless tests; the deferred real-project
/// pass runs post-9c on the real sign-in, not on this).
public typealias StaticFragmentsSessionProvider = StaticSessionProvider

public typealias FragmentsSessionError = UserSessionError
