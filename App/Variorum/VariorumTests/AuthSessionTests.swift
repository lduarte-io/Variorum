//
//  AuthSessionTests.swift
//  VariorumTests
//
//  Phase 9c, Step 1 — the sign-in core, headless against a scripted auth
//  endpoint (the plan's "URLProtocol or protocol seam" — the seam). The
//  Step 0 memo's two load-bearing facts are pinned: the provider token pair
//  is captured at the ONE exchange that ever delivers it, and refreshes
//  PRESERVE it (a naive overwrite would silently destroy Step 5's bridge
//  material — Supabase never re-delivers).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("AuthSession — sign-in core (Phase 9c, Step 1; no network)")
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
        expiresAt: Date = Date(timeIntervalSince1970: 2_000_000_000),
        providerToken: String? = "frag-access", providerRefresh: String? = "frag-refresh"
    ) -> AuthTokens {
        AuthTokens(
            accessToken: access, refreshToken: refresh, expiresAt: expiresAt,
            userID: "<account-uuid>", email: "author@example.com",
            providerToken: providerToken, providerRefreshToken: providerRefresh)
    }

    // MARK: PKCE

    @Test func pkceChallengeMatchesTheRFCVector() {
        // RFC 7636 appendix B — the S256 worked example.
        #expect(PKCE.challenge(forVerifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
                == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
    }

    @Test func generatedVerifiersAreWellFormedAndDistinct() {
        let unreserved = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let a = PKCE.generateVerifier()
        let b = PKCE.generateVerifier()
        #expect(a != b)
        for verifier in [a, b] {
            #expect(verifier.count >= 43 && verifier.count <= 128)
            #expect(verifier.allSatisfy { unreserved.contains($0) })
        }
    }

    @Test func authorizeURLCarriesTheDocumentedShape() {
        let session = AuthSession(
            configuration: Self.configuration, store: .inMemory())
        let url = session.authorizeURL(verifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        #expect(url.absoluteString.hasPrefix(
            "https://variorum-project.supabase.co/auth/v1/authorize?"))
        let items = Dictionary(
            uniqueKeysWithValues: components.queryItems!.map { ($0.name, $0.value ?? "") })
        #expect(items["provider"] == "custom:fragments")
        #expect(items["redirect_to"] == "variorum://auth-callback")
        #expect(items["code_challenge"] == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
        #expect(items["code_challenge_method"] == "s256")
    }

    // MARK: The exchange — the ONE provider-pair delivery

    @Test func codeExchangeCapturesTheFullPayloadIncludingTheProviderPair() async throws {
        let endpoint = ScriptedEndpoint([(200, """
            {"access_token": "v-access", "refresh_token": "v-refresh",
             "expires_in": 3600, "token_type": "bearer",
             "provider_token": "frag-access", "provider_refresh_token": "frag-refresh",
             *[removed for publication]*
                      "email": "author@example.com"}}
            """)])
        let store = AuthTokensStore.inMemory()
        let epoch = Date(timeIntervalSince1970: 1_000_000)
        let session = AuthSession(
            configuration: Self.configuration, store: store,
            now: { epoch }, http: endpoint.loader())

        try await session.handleCallback(
            URL(string: "variorum://auth-callback?code=the-code")!,
            verifier: "the-verifier")

        // The request shape.
        let request = endpoint.requests[0]
        #expect(request.url?.absoluteString
                == "https://variorum-project.supabase.co/auth/v1/token?grant_type=pkce")
        #expect(request.value(forHTTPHeaderField: "apikey") == "publishable-key")
        let body = try JSONDecoder().decode(
            [String: String].self, from: request.httpBody ?? Data())
        #expect(body == ["auth_code": "the-code", "code_verifier": "the-verifier"])

        // The persisted session — provider pair captured (Step 0 memo:
        // never delivered again).
        let saved = try #require(store.load())
        #expect(saved.accessToken == "v-access")
        #expect(saved.refreshToken == "v-refresh")
        *[removed for publication]*
        #expect(saved.email == "author@example.com")
        #expect(saved.providerToken == "frag-access")
        #expect(saved.providerRefreshToken == "frag-refresh")
        #expect(saved.expiresAt == epoch.addingTimeInterval(3600))
        let pair = await session.providerTokenPair
        #expect(pair?.token == "frag-access")
        #expect(pair?.refresh == "frag-refresh")
    }

    @Test func aCallbackWithoutACodeRefuses() async {
        let session = AuthSession(
            configuration: Self.configuration, store: .inMemory(),
            http: ScriptedEndpoint([]).loader())
        await #expect(throws: AuthSessionError.self) {
            try await session.handleCallback(
                URL(string: "variorum://auth-callback?error=access_denied")!,
                verifier: "v")
        }
        #expect(await session.isSignedIn == false)
    }

    // MARK: Refresh

    @Test func currentSessionRefreshesProactivelyNearExpiryAndPreservesTheProviderPair() async throws {
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

        // THE PRESERVATION RULE: the refresh response carried no provider
        // tokens; the captured pair must survive verbatim.
        let saved = try #require(store.load())
        #expect(saved.accessToken == "v-access-2")
        #expect(saved.refreshToken == "v-refresh-2")
        #expect(saved.providerToken == "frag-access")
        #expect(saved.providerRefreshToken == "frag-refresh")
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
        let pair = await second.providerTokenPair
        #expect(pair?.refresh == "frag-refresh")
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
        // Local state + persistence + provider pair all gone.
        #expect(store.load() == nil)
        #expect(await session.isSignedIn == false)
        #expect(await session.providerTokenPair == nil)
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
