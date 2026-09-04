//
//  AuthSessionTests.swift
//  VariorumTests
//
//  Phase 9c, Step 1 — the sign-in core, headless against a scripted auth
//  endpoint (the plan's "URLProtocol or protocol seam" — the seam).
//  Phase 14a, batch 1 — updated to the DIRECT shape (round 0h): the
//  password grant against the app's own project is THE sign-in door; the
//  delegated PKCE/exchange machinery and the captured provider token pair
//  are retired (their pins retired with them — the mechanism no longer
//  exists to preserve). 14d rebuilt that machinery for the Fragments
//  bridge's delegated road; it left again with the bridge on 2026-09-04
//  (pre-13x batch 0b), its pins with it.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("AuthSession — sign-in core (Phase 9c Step 1; 14a direct; no network)")
struct AuthSessionTests {
    private static let configuration = AuthConfiguration(
        projectURL: URL(string: "https://variorum-project.supabase.co")!,
        apiKey: "publishable-key")

    /// Scripted auth endpoint: canned (status, body) per request, requests
    /// recorded; synchronous under a lock (async closure just forwards).
    private final class ScriptedEndpoint: @unchecked Sendable {
        private let lock = NSLock()
        private var script: [(status: Int, body: String)]
        private var recorded: [URLRequest] = []
        /// Artificial latency — the single-flight test overlaps two callers.
        var delay: Duration?

        init(_ script: [(status: Int, body: String)]) {
            self.script = script
        }

        var requests: [URLRequest] {
            lock.lock(); defer { lock.unlock() }
            return recorded
        }

        private func serve(_ request: URLRequest) throws -> (Data, URLResponse) {
            lock.lock(); defer { lock.unlock() }
            recorded.append(request)
            guard !script.isEmpty else {
                throw AuthSessionError.malformedResponse("script exhausted")
            }
            let step = script.removeFirst()
            return (
                Data(step.body.utf8),
                HTTPURLResponse(
                    url: request.url!, statusCode: step.status,
                    httpVersion: nil, headerFields: nil)!)
        }

        func loader() -> @Sendable (URLRequest) async throws -> (Data, URLResponse) {
            { [self] request in
                if let delay { try? await Task.sleep(for: delay) }
                return try self.serve(request)
            }
        }
    }

    private static func tokens(
        access: String = "access-1", refresh: String = "refresh-1",
        expiresAt: Date = Date(timeIntervalSince1970: 2_000_000_000)
    ) -> AuthTokens {
        AuthTokens(
            accessToken: access, refreshToken: refresh, expiresAt: expiresAt,
            *[removed for publication]*
    }

    // MARK: The password grant — THE sign-in door (Phase 14a: direct)

    @Test func passwordSignInDrivesThePasswordGrantAndPersistsTheSession() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "v-access", "refresh_token": "v-refresh",
             "expires_in": 3600, "token_type": "bearer",
             *[removed for publication]*
                      "email": "author@example.com"}}
            """)])
        let store = AuthTokensStore.inMemory()
        let epoch = Date(timeIntervalSince1970: 1_000_000)
        let session = AuthSession(
            configuration: Self.configuration, store: store,
            now: { epoch }, http: endpoint.loader())

        try await session.signInWithPassword(
            email: "author@example.com", password: "the-password")

        // The request shape.
        let request = endpoint.requests[0]
        #expect(request.url?.absoluteString
                == "https://variorum-project.supabase.co/auth/v1/token?grant_type=password")
        #expect(request.value(forHTTPHeaderField: "apikey") == "publishable-key")
        let body = try JSONDecoder().decode(
            [String: String].self, from: request.httpBody ?? Data())
        #expect(body == ["email": "author@example.com", "password": "the-password"])

        // The persisted session.
        let saved = try #require(store.load())
        #expect(saved.accessToken == "v-access")
        #expect(saved.refreshToken == "v-refresh")
        *[removed for publication]*
        #expect(saved.email == "author@example.com")
        #expect(saved.expiresAt == epoch.addingTimeInterval(3600))
        #expect(await session.isSignedIn)
    }

    @Test func aRefusedPasswordSignInSurfacesAndSignsNothingIn() async {
        let refusal = #"{"error":"invalid_grant","error_description":"Invalid login credentials"}"#
        let endpoint = ScriptedEndpoint([(400, refusal)])
        let store = AuthTokensStore.inMemory()
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        await #expect(throws: AuthSessionError.endpointFailure(
            status: 400, body: refusal)) {
            try await session.signInWithPassword(email: "author@example.com", password: "wrong")
        }
        #expect(store.load() == nil, "a refused sign-in must persist nothing")
        #expect(await session.isSignedIn == false)
    }

    @Test func aTokenResponseWithoutAUserIDRefuses() async {
        // A malformed success (no user payload) must not mint a session
        // with an empty owner identity — owner_id stamping keys on it.
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "v-access", "refresh_token": "v-refresh", "expires_in": 3600}
            """)])
        let store = AuthTokensStore.inMemory()
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        await #expect(throws: AuthSessionError.malformedResponse(
            "token response carried no user id")) {
            try await session.signInWithPassword(email: "author@example.com", password: "pw")
        }
        #expect(store.load() == nil)
        #expect(await session.isSignedIn == false)
    }

    // MARK: The sign-up door (Phase 14c batch 3, L8 — THE DESIGN 6)

    @Test func signUpWithAutoconfirmAdoptsTheSessionExactlyAsSignIn() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "s-access", "refresh_token": "s-refresh",
             "expires_in": 3600, "token_type": "bearer",
             "user": {"id": "11f2d9c4-1234-4abc-8def-000000000042",
                      "email": "stranger@example.com"}}
            """)])
        let store = AuthTokensStore.inMemory()
        let epoch = Date(timeIntervalSince1970: 2_000_000)
        let session = AuthSession(
            configuration: Self.configuration, store: store,
            now: { epoch }, http: endpoint.loader())

        let outcome = try await session.signUp(
            email: "stranger@example.com", password: "a-real-passphrase")
        #expect(outcome == .signedIn)

        // The request shape: the signup endpoint, the same seam.
        let request = endpoint.requests[0]
        #expect(request.url?.absoluteString
                == "https://variorum-project.supabase.co/auth/v1/signup")
        #expect(request.value(forHTTPHeaderField: "apikey") == "publishable-key")
        let body = try JSONDecoder().decode(
            [String: String].self, from: request.httpBody ?? Data())
        #expect(body == ["email": "stranger@example.com", "password": "a-real-passphrase"])

        // The adopted session — sign-up IS sign-in once the server says yes.
        let saved = try #require(store.load())
        #expect(saved.accessToken == "s-access")
        #expect(saved.userID == "11f2d9c4-1234-4abc-8def-000000000042")
        #expect(saved.expiresAt == epoch.addingTimeInterval(3600))
        #expect(await session.isSignedIn)
    }

    /// Email confirmations ON: the server answers with a session-less
    /// user body (the confirmation email went out). NOTHING is adopted —
    /// sign-in completes after the link.
    @Test func signUpWithConfirmationRequiredAdoptsNothing() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"id": "11f2d9c4-1234-4abc-8def-000000000042",
             "email": "stranger@example.com", "aud": "authenticated",
             "confirmation_sent_at": "2026-08-05T12:00:00Z"}
            """)])
        let store = AuthTokensStore.inMemory()
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        let outcome = try await session.signUp(
            email: "stranger@example.com", password: "a-real-passphrase")
        #expect(outcome == .confirmationRequired)
        #expect(store.load() == nil, "no session exists yet — nothing to persist")
        #expect(await session.isSignedIn == false)
    }

    /// The signups-off toggle (the corpus guard, flipped only at the
    /// gate): the server's refusal surfaces as the verbatim endpoint
    /// failure for the surface's classifier — and adopts nothing.
    @Test func aRefusedSignUpThrowsAndSignsNothingIn() async {
        let refusal = #"{"code":422,"error_code":"signup_disabled","msg":"Signups not allowed for this instance"}"#
        let endpoint = ScriptedEndpoint([(422, refusal)])
        let store = AuthTokensStore.inMemory()
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        await #expect(throws: AuthSessionError.endpointFailure(
            status: 422, body: refusal)) {
            try await session.signUp(email: "s@example.com", password: "pw-long-enough")
        }
        #expect(store.load() == nil)
        #expect(await session.isSignedIn == false)
    }

    // MARK: Refresh

    @Test func currentSessionRefreshesProactivelyNearExpiry() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "v-access-2", "refresh_token": "v-refresh-2",
             "expires_in": 3600,
             *[removed for publication]*
            """)])
        let soon = Date().addingTimeInterval(30)  // inside the 60 s margin
        let store = AuthTokensStore.inMemory(initial: Self.tokens(expiresAt: soon))
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        let userSession = try await session.currentSession()
        #expect(userSession.accessToken == "v-access-2")
        *[removed for publication]*

        // The refresh request shape.
        let request = endpoint.requests[0]
        #expect(request.url?.absoluteString
                == "https://variorum-project.supabase.co/auth/v1/token?grant_type=refresh_token")
        let body = try JSONDecoder().decode(
            [String: String].self, from: request.httpBody ?? Data())
        #expect(body == ["refresh_token": "refresh-1"])

        // The rotated pair persists.
        let saved = try #require(store.load())
        #expect(saved.accessToken == "v-access-2")
        #expect(saved.refreshToken == "v-refresh-2")
    }

    @Test func aFreshSessionIsVendedWithoutAnyRequest() async throws {
        let endpoint = ScriptedEndpoint([])
        let store = AuthTokensStore.inMemory(
            initial: Self.tokens(expiresAt: Date().addingTimeInterval(3000)))
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())
        let vended = try await session.currentSession()
        #expect(vended.accessToken == "access-1")
        #expect(endpoint.requests.isEmpty)
    }

    @Test func concurrentRefreshDemandsAreSingleFlight() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "v-access-2", "refresh_token": "v-refresh-2",
             "expires_in": 3600,
             *[removed for publication]*
            """)])
        endpoint.delay = .milliseconds(80)
        let store = AuthTokensStore.inMemory(
            initial: Self.tokens(expiresAt: Date()))  // expired
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        async let first = session.currentSession()
        async let second = session.currentSession()
        let (a, b) = try await (first, second)
        #expect(a.accessToken == "v-access-2")
        #expect(b.accessToken == "v-access-2")
        #expect(endpoint.requests.count == 1,
                "two concurrent demands must coalesce onto ONE refresh request")
    }

    @Test func refreshFailureSurfacesAndKeepsTheSession() async {
        let endpoint = ScriptedEndpoint([(400, #"{"error":"invalid_grant"}"#)])
        let store = AuthTokensStore.inMemory(initial: Self.tokens(expiresAt: Date()))
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())

        await #expect(throws: AuthSessionError.endpointFailure(
            status: 400, body: #"{"error":"invalid_grant"}"#)) {
            _ = try await session.currentSession()
        }
        // Fail-visible, never fail-destructive: the session survives (only
        // signOut clears); the next round retries.
        #expect(store.load() != nil)
        #expect(await session.isSignedIn)
    }

    @Test func refreshedSessionForcesARefreshEvenWhenFresh() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "v-access-2", "refresh_token": "v-refresh-2",
             "expires_in": 3600,
             *[removed for publication]*
            """)])
        let store = AuthTokensStore.inMemory(
            initial: Self.tokens(expiresAt: Date().addingTimeInterval(3000)))
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())
        // The 401 door (Step 2's transport calls this after a rejection).
        let refreshed = try await session.refreshedSession()
        #expect(refreshed.accessToken == "v-access-2")
        #expect(endpoint.requests.count == 1)
    }

    /// Review round 1 (MINOR) — THE RED-ON-OLD PIN: a sign-out completing
    /// while a refresh's HTTP hop is in flight must be TERMINAL. Pre-fix,
    /// the refresh continuation adopted + saved its result unconditionally
    /// after the await, resurrecting the signed-out session in memory AND
    /// the Keychain — the next launch came up signed in, the explicit
    /// sign-out silently undone.
    @Test func signOutDuringAnInFlightRefreshDoesNotResurrectTheSession() async throws {
        // Route by endpoint: the refresh hop is SLOW (in flight while the
        // sign-out runs); the sign-out's best-effort logout is immediate.
        let routed: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
            if request.url!.absoluteString.contains("grant_type=refresh_token") {
                try? await Task.sleep(for: .milliseconds(200))
                return (Data("""
                    {"access_token": "v-access-2", "refresh_token": "v-refresh-2",
                     "expires_in": 3600,
                     *[removed for publication]*
                    """.utf8),
                    HTTPURLResponse(url: request.url!, statusCode: 200,
                                    httpVersion: nil, headerFields: nil)!)
            }
            return (Data(),
                    HTTPURLResponse(url: request.url!, statusCode: 204,
                                    httpVersion: nil, headerFields: nil)!)
        }
        let store = AuthTokensStore.inMemory(initial: Self.tokens(expiresAt: Date()))
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: routed)

        let refreshing = Task { try await session.currentSession() }
        try await Task.sleep(for: .milliseconds(60))  // the refresh hop is in flight
        await session.signOut()
        #expect(store.load() == nil)

        // The in-flight refresh resolves AFTER the sign-out: it must be
        // discarded, not adopted.
        await #expect(throws: UserSessionError.notSignedIn) {
            _ = try await refreshing.value
        }
        #expect(store.load() == nil, "an explicit sign-out must be terminal")
        #expect(await session.isSignedIn == false)
    }

    // MARK: Persistence + sign-out

    @Test func persistenceRoundTripsAcrossSessionInstances() async throws {
        let store = AuthTokensStore.inMemory()
        let first = AuthSession(
            configuration: Self.configuration, store: store,
            http: ScriptedEndpoint([]).loader())
        await first.adopt(Self.tokens())
        // A brand-new instance over the same store (a fresh app launch).
        let second = AuthSession(
            configuration: Self.configuration, store: store,
            http: ScriptedEndpoint([]).loader())
        #expect(await second.isSignedIn)
        *[removed for publication]*
        #expect(await second.currentEmail == "author@example.com")
    }

    @Test func signOutClearsEverythingAndOnlySignOutDoes() async throws {
        let endpoint = ScriptedEndpoint([(204, "")])
        let store = AuthTokensStore.inMemory(initial: Self.tokens())
        let session = AuthSession(
            configuration: Self.configuration, store: store, http: endpoint.loader())
        let changes = LockIsolatedChanges()
        await session.setOnChange { changes.append($0 != nil) }

        await session.signOut()

        // Best-effort server logout attempted with the bearer.
        #expect(endpoint.requests.first?.url?.path == "/auth/v1/logout")
        #expect(endpoint.requests.first?.value(forHTTPHeaderField: "Authorization")
                == "Bearer access-1")
        // Local state + persistence all gone.
        #expect(store.load() == nil)
        #expect(await session.isSignedIn == false)
        #expect(changes.values == [false])
        await #expect(throws: VariorumCore.UserSessionError.notSignedIn) {
            _ = try await session.currentSession()
        }
    }
}

/// Tiny thread-safe change recorder.
private final class LockIsolatedChanges: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [Bool] = []
    var values: [Bool] {
        lock.lock(); defer { lock.unlock() }
        return recorded
    }
    func append(_ value: Bool) {
        lock.lock(); defer { lock.unlock() }
        recorded.append(value)
    }
}
