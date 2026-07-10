//
//  AuthSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 1 — the sign-in core: the Variorum project's Supabase Auth
//  session over plain REST (no SDK — the hand-rolled transport doctrine),
//  persisted in the Keychain under NEW keys, refreshed single-flight, and
//  vended to the sync transport through the Step 2 `UserSessionProviding`
//  seam. The concrete sign-in door is route A's delegated PKCE code flow
//  (Step 0 memo, 2026-07-10): `custom:fragments` on the Variorum project —
//  the author signs in once with her Fragments identity and Variorum mints
//  her session.
//
//  TWO FACTS THE STEP 0 MEMO MAKES LOAD-BEARING HERE:
//   1. The token exchange is the ONLY moment `provider_token` /
//      `provider_refresh_token` (her Fragments-project user JWT + its
//      refresh token) are ever delivered — Supabase never persists or
//      re-delivers them. The exchange captures BOTH into the persisted
//      tokens. (Their consumption is Step 5's — QUESTIONS #16.)
//   2. Refresh responses do NOT carry provider tokens — a refresh must
//      PRESERVE the captured pair, never overwrite it with nil (pinned).
//
//  Refresh failures surface and KEEP the session: a transient network error
//  must not destroy a signed-in state (the scheduler's offline posture
//  handles the failed round); only `signOut()` clears. A permanently-dead
//  refresh token therefore shows as a persistent, visible sync error until
//  the author signs in again — fail-visible, never fail-destructive.
//

import CryptoKit
import Foundation
import Security
import VariorumCore

// MARK: - Configuration (the Variorum project; values are publishable)

nonisolated struct AuthConfiguration: Sendable {
    /// `https://<variorum-project>.supabase.co`
    var projectURL: URL
    /// The publishable API key (post-04-flip it grants nothing by itself).
    var apiKey: String
    /// The custom provider slug — `fragments` ⇒ `provider=custom:fragments`
    /// (Step 0: the created provider's slug).
    var providerSlug: String
    /// The app's callback. ASWebAuthenticationSession captures it without
    /// any Info.plist registration; it must be in the Variorum project's
    /// Redirect URLs allow-list (Step 6 gate item).
    var redirectURI: String

    init(
        projectURL: URL, apiKey: String,
        providerSlug: String = "fragments",
        redirectURI: String = "variorum://auth-callback"
    ) {
        self.projectURL = projectURL
        self.apiKey = apiKey
        self.providerSlug = providerSlug
        self.redirectURI = redirectURI
    }
}

// MARK: - The persisted session

nonisolated struct AuthTokens: Codable, Equatable, Sendable {
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date
    /// The Variorum project's `auth.uid()` — the `owner_id` value class.
    var userID: String
    var email: String?
    /// The Fragments-project user JWT + refresh token, captured at the
    /// sign-in exchange (the only delivery — Step 0 memo). Consumed by
    /// Step 5 per QUESTIONS #16; preserved across refreshes.
    var providerToken: String?
    var providerRefreshToken: String?
}

/// Persistence seam (tests inject in-memory; production is the Keychain
/// under keys DISTINCT from the retiring Phase 8 paste-in's).
nonisolated struct AuthTokensStore: Sendable {
    var load: @Sendable () -> AuthTokens?
    var save: @Sendable (AuthTokens) -> Void
    var clear: @Sendable () -> Void

    /// One Keychain item per session home: the Variorum session and the
    /// bridge's Fragments session (QUESTIONS #16 shape (c)) live under
    /// distinct services so neither sign-out disturbs the other.
    static func keychain(service: String = KeychainAuthStorage.variorumService) -> AuthTokensStore {
        AuthTokensStore(
            load: { KeychainAuthStorage.load(service: service) },
            save: { KeychainAuthStorage.save($0, service: service) },
            clear: { KeychainAuthStorage.clear(service: service) })
    }

    static func inMemory(initial: AuthTokens? = nil) -> AuthTokensStore {
        let box = LockedBox(initial)
        return AuthTokensStore(
            load: { box.value },
            save: { box.value = $0 },
            clear: { box.value = nil })
    }

    nonisolated private final class LockedBox: @unchecked Sendable {
        private let lock = NSLock()
        private var stored: AuthTokens?
        init(_ initial: AuthTokens?) { stored = initial }
        var value: AuthTokens? {
            get { lock.lock(); defer { lock.unlock() }; return stored }
            set { lock.lock(); defer { lock.unlock() }; stored = newValue }
        }
    }
}

/// The Keychain half — same Sec* pattern as the Phase 8 store, NEW service
/// so retirement of the paste-in (Step 5) can delete the old item without
/// touching this one. `AfterFirstUnlock` for the same background-round
/// reason as Phase 8.
nonisolated enum KeychainAuthStorage {
    /// The Variorum-project session's home.
    static let variorumService = "io.lduarte.Variorum.auth"
    /// The bridge's Fragments-project session (QUESTIONS #16 shape (c)).
    static let fragmentsService = "io.lduarte.Variorum.fragments-auth"
    private static let account = "session"

    static func load(service: String) -> AuthTokens? {
        var query = baseQuery(service: service)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(AuthTokens.self, from: data)
    }

    @discardableResult
    static func save(_ tokens: AuthTokens, service: String) -> Bool {
        guard let data = try? JSONEncoder().encode(tokens) else { return false }
        var attributes = baseQuery(service: service)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: data]
            return SecItemUpdate(baseQuery(service: service) as CFDictionary, update as CFDictionary)
                == errSecSuccess
        }
        return status == errSecSuccess
    }

    @discardableResult
    static func clear(service: String) -> Bool {
        SecItemDelete(baseQuery(service: service) as CFDictionary) == errSecSuccess
    }

    private static func baseQuery(service: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

/// The Phase 8 paste-in's Keychain item (its store type was deleted at
/// Phase 9c Step 5): cleared on the first real sign-in. This is the ONE
/// remaining reference to the old service string — pinned by the
/// retirement walk in `Phase9cAuthWiringTests`.
nonisolated enum LegacyPasteInCleanup {
    static let retiredService = "io.lduarte.Variorum.sync"

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: retiredService,
            kSecAttrAccount as String: "supabase",
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - PKCE (RFC 7636, S256 — pinned against the RFC's test vector)

nonisolated enum PKCE {
    /// 32 random bytes, base64url — 43 chars of the unreserved alphabet.
    static func generateVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return base64URL(Data(bytes))
    }

    /// S256: base64url(SHA256(ascii(verifier))).
    static func challenge(forVerifier verifier: String) -> String {
        base64URL(Data(SHA256.hash(data: Data(verifier.utf8))))
    }

    private static func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - The session

nonisolated enum AuthSessionError: Error, Equatable, Sendable {
    /// The auth endpoint refused (status + body verbatim, for the status row).
    case endpointFailure(status: Int, body: String)
    case notHTTP
    case malformedResponse(String)
    /// The callback URL carried no `code` (an error or a cancelled flow).
    case callbackWithoutCode(String)
}

actor AuthSession: UserSessionProviding {
    let configuration: AuthConfiguration
    private let store: AuthTokensStore
    private let http: @Sendable (URLRequest) async throws -> (Data, URLResponse)
    private let now: @Sendable () -> Date
    /// Refresh proactively when the access token is within this margin of
    /// expiry — a round that starts with a nearly-dead token would 401 in
    /// its middle otherwise.
    private let expiryMargin: TimeInterval

    private var tokens: AuthTokens?
    /// Single-flight: concurrent refresh demands coalesce onto one request.
    private var refreshTask: Task<AuthTokens, Error>?
    /// Sign-in/out notification (Step 5 wires the UI + sync/bridge session
    /// lifecycles here). Fired on adopt and on sign-out, never on refresh.
    private var onChange: (@Sendable (AuthTokens?) -> Void)?

    init(
        configuration: AuthConfiguration,
        store: AuthTokensStore = .keychain(),
        expiryMargin: TimeInterval = 60,
        now: @escaping @Sendable () -> Date = { Date() },
        http: (@Sendable (URLRequest) async throws -> (Data, URLResponse))? = nil
    ) {
        self.configuration = configuration
        self.store = store
        self.expiryMargin = expiryMargin
        self.now = now
        let session = URLSession.shared
        self.http = http ?? { try await session.data(for: $0) }
        self.tokens = store.load()
    }

    // MARK: State

    var isSignedIn: Bool { tokens != nil }
    var currentUserID: String? { tokens?.userID }
    var currentEmail: String? { tokens?.email }
    /// The captured Fragments-project token pair (Step 5's raw material —
    /// QUESTIONS #16; nil after sign-out or if the provider sent none).
    var providerTokenPair: (token: String, refresh: String)? {
        guard let tokens, let token = tokens.providerToken,
              let refresh = tokens.providerRefreshToken else { return nil }
        return (token, refresh)
    }

    func setOnChange(_ handler: @escaping @Sendable (AuthTokens?) -> Void) {
        onChange = handler
    }

    // MARK: The sign-in door (route A: delegated PKCE code flow)

    /// The URL the sign-in UI opens (ASWebAuthenticationSession). The
    /// verifier must be kept for the exchange.
    nonisolated func authorizeURL(verifier: String) -> URL {
        var components = URLComponents(
            url: configuration.projectURL.appendingPathComponent("auth/v1/authorize"),
            resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "provider", value: "custom:\(configuration.providerSlug)"),
            URLQueryItem(name: "redirect_to", value: configuration.redirectURI),
            URLQueryItem(name: "code_challenge", value: PKCE.challenge(forVerifier: verifier)),
            URLQueryItem(name: "code_challenge_method", value: "s256"),
        ]
        return components.url!
    }

    /// Completes the flow from the captured callback URL: extracts `?code`
    /// and exchanges it. Throws `callbackWithoutCode` on an error callback.
    func handleCallback(_ url: URL, verifier: String) async throws {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let code = components?.queryItems?
            .first(where: { $0.name == "code" })?.value
        else {
            throw AuthSessionError.callbackWithoutCode(url.absoluteString)
        }
        try await exchangeCode(code, verifier: verifier)
    }

    /// `POST /auth/v1/token?grant_type=pkce` — the ONE moment the provider
    /// token pair is delivered (Step 0 memo); everything is captured and
    /// persisted here.
    func exchangeCode(_ code: String, verifier: String) async throws {
        let response = try await tokenRequest(
            grantType: "pkce",
            body: ["auth_code": code, "code_verifier": verifier])
        let adopted = AuthTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: response.expiryDate(now: now()),
            userID: response.user?.id ?? "",
            email: response.user?.email,
            providerToken: response.providerToken,
            providerRefreshToken: response.providerRefreshToken)
        guard !adopted.userID.isEmpty else {
            throw AuthSessionError.malformedResponse("token response carried no user id")
        }
        adopt(adopted)
    }

    /// The password door (`grant_type=password`) — the bridge's direct
    /// Fragments-project sign-in (QUESTIONS #16, PROVISIONAL (c)): her
    /// Fragments email+password once; only the resulting session persists,
    /// never the password. Not used for the Variorum session (route A's
    /// PKCE flow is that door).
    func signInWithPassword(email: String, password: String) async throws {
        let response = try await tokenRequest(
            grantType: "password",
            body: ["email": email, "password": password])
        let adopted = AuthTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: response.expiryDate(now: now()),
            userID: response.user?.id ?? "",
            email: response.user?.email,
            providerToken: response.providerToken,
            providerRefreshToken: response.providerRefreshToken)
        guard !adopted.userID.isEmpty else {
            throw AuthSessionError.malformedResponse("token response carried no user id")
        }
        adopt(adopted)
    }

    /// The injectable entry (tests; any future door): adopt a ready-made
    /// token set as the signed-in session.
    func adopt(_ newTokens: AuthTokens) {
        tokens = newTokens
        store.save(newTokens)
        onChange?(newTokens)
    }

    /// Best-effort server-side logout, unconditional local clear. The only
    /// path that destroys a session.
    func signOut() async {
        if let tokens {
            var request = URLRequest(
                url: configuration.projectURL.appendingPathComponent("auth/v1/logout"))
            request.httpMethod = "POST"
            request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
            _ = try? await http(request)
        }
        tokens = nil
        refreshTask?.cancel()
        refreshTask = nil
        store.clear()
        onChange?(nil)
    }

    // MARK: UserSessionProviding (the Step 2 seam)

    func currentSession() async throws -> UserSession {
        guard let current = tokens else { throw UserSessionError.notSignedIn }
        if now() >= current.expiresAt.addingTimeInterval(-expiryMargin) {
            let refreshed = try await refresh()
            return UserSession(accessToken: refreshed.accessToken, userID: refreshed.userID)
        }
        return UserSession(accessToken: current.accessToken, userID: current.userID)
    }

    func refreshedSession() async throws -> UserSession {
        let refreshed = try await refresh()
        return UserSession(accessToken: refreshed.accessToken, userID: refreshed.userID)
    }

    // MARK: Refresh (single-flight; preserves the provider pair)

    private func refresh() async throws -> AuthTokens {
        if let inFlight = refreshTask {
            return try await inFlight.value
        }
        guard let current = tokens else { throw UserSessionError.notSignedIn }
        let task = Task { [configuration, http, now] () throws -> AuthTokens in
            let response = try await Self.tokenRequest(
                configuration: configuration, http: http,
                grantType: "refresh_token",
                body: ["refresh_token": current.refreshToken])
            var next = current
            next.accessToken = response.accessToken
            next.refreshToken = response.refreshToken
            next.expiresAt = response.expiryDate(now: now())
            if let user = response.user {
                next.userID = user.id
                next.email = user.email ?? next.email
            }
            // THE PRESERVATION RULE (Step 0 memo): refresh responses never
            // carry provider tokens — the captured pair survives verbatim.
            return next
        }
        refreshTask = task
        defer { refreshTask = nil }
        let refreshed = try await task.value
        tokens = refreshed
        store.save(refreshed)
        return refreshed
    }

    // MARK: REST plumbing

    private func tokenRequest(
        grantType: String, body: [String: String]
    ) async throws -> TokenResponse {
        try await Self.tokenRequest(
            configuration: configuration, http: http, grantType: grantType, body: body)
    }

    private static func tokenRequest(
        configuration: AuthConfiguration,
        http: @Sendable (URLRequest) async throws -> (Data, URLResponse),
        grantType: String,
        body: [String: String]
    ) async throws -> TokenResponse {
        var components = URLComponents(
            url: configuration.projectURL.appendingPathComponent("auth/v1/token"),
            resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "grant_type", value: grantType)]
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await http(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthSessionError.notHTTP
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw AuthSessionError.endpointFailure(
                status: httpResponse.statusCode,
                body: String(data: data, encoding: .utf8) ?? "")
        }
        do {
            return try JSONDecoder().decode(TokenResponse.self, from: data)
        } catch {
            throw AuthSessionError.malformedResponse(String(describing: error))
        }
    }
}

/// The Supabase `/auth/v1/token` response, decoded minimally.
nonisolated private struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Double?
    let expiresAt: Double?
    let providerToken: String?
    let providerRefreshToken: String?
    let user: UserPayload?

    struct UserPayload: Decodable {
        let id: String
        let email: String?
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case providerToken = "provider_token"
        case providerRefreshToken = "provider_refresh_token"
        case user
    }

    /// `expires_at` (unix seconds) wins; else `now + expires_in`; else a
    /// conservative hour.
    func expiryDate(now: Date) -> Date {
        if let expiresAt { return Date(timeIntervalSince1970: expiresAt) }
        return now.addingTimeInterval(expiresIn ?? 3600)
    }
}
