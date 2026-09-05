//
//  AuthSession.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 1 built this sign-in core: the app's Supabase Auth
//  sessions over plain REST (no SDK — the hand-rolled transport doctrine),
//  persisted in the Keychain, refreshed single-flight, and vended to the
//  transports through the Step 2 `UserSessionProviding` seam.
//
//  Phase 14a, batch 1 RE-AIMS it (sitting round 0h: the suite account
//  lives on the VARIORUM project itself): the app's sign-in door is the
//  DIRECT password grant against its own project — "the 9c AuthSession
//  password grant, re-aimed". The delegated custom-provider flow (PKCE,
//  the browser hop, the authorize/exchange doors, the captured provider
//  token pair) is retired wholesale from this file. (It returned at 14d
//  for the Fragments bridge's delegated road into the Fragments project,
//  and left again with the bridge on 2026-09-04 — pre-13x batch 0b,
//  archived at tag `archive/fragments-bridge-2026-09-04`.)
//
//  Refresh failures surface and KEEP the session: a transient network error
//  must not destroy a signed-in state (the scheduler's offline posture
//  handles the failed round); only `signOut()` clears. A permanently-dead
//  refresh token therefore shows as a persistent, visible sync error until
//  the author signs in again — fail-visible, never fail-destructive.
//
//  Phase 13e, batch 9 (ladder round B, B-1) — THE LAZY LOAD, the fix the
//  KnownIssues "Windowless launch" row promised. The 14b gate morning
//  captured a live windowless launch with `sample`: the MAIN thread sat
//  inside `AppServices.init` → `AuthSession.init` →
//  `KeychainAuthStorage.load` → `SecItemCopyMatching` → `ClientSession
//  ::decrypt` → `mach_msg`, waiting on securityd while no window existed
//  yet. The persisted session is therefore read at FIRST USE now
//  (`ensureLoadedFromStore`), never during construction — and first use is
//  always inside this ACTOR, whose executor is never the main thread, so
//  the hop cannot block the UI however long securityd takes. Nothing else
//  moves: the load is still one synchronous read with no suspension point,
//  so no caller can interleave between "read the Keychain" and "adopt what
//  it held" (see `ensureLoadedFromStore`'s note on why that matters).
//

import Foundation
import Security
import VariorumCore

// MARK: - Configuration (per project; values are publishable)

nonisolated struct AuthConfiguration: Sendable {
    /// `https://<project>.supabase.co`
    var projectURL: URL
    /// The publishable API key (post-04-flip it grants nothing by itself).
    var apiKey: String

    init(projectURL: URL, apiKey: String) {
        self.projectURL = projectURL
        self.apiKey = apiKey
    }
}

// MARK: - The persisted session

nonisolated struct AuthTokens: Codable, Equatable, Sendable {
    var accessToken: String
    var refreshToken: String
    var expiresAt: Date
    /// The project's `auth.uid()` — for the Variorum session this is the
    /// `owner_id` value class.
    var userID: String
    var email: String?
}

/// Persistence seam (tests inject in-memory; production is the Keychain
/// under keys DISTINCT from the retired Phase 8 paste-in's).
nonisolated struct AuthTokensStore: Sendable {
    var load: @Sendable () -> AuthTokens?
    var save: @Sendable (AuthTokens) -> Void
    var clear: @Sendable () -> Void

    /// One Keychain item per session home (the `service` parameter; the
    /// retired bridge's Fragments-project session had its own — see
    /// `LegacyPasteInCleanup`).
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
/// so retirement of the paste-in (Step 5) could delete the old item without
/// touching this one.
///
/// **pre-13x batch 1a — DEVICE-BOUND (the postures design §1.13 / §3.1 "the
/// session … the data-protection Keychain, `ThisDeviceOnly` — a cloned Mac
/// signs in again").** The session lives in the DATA-PROTECTION keychain
/// under the `session-bound` account with `WhenUnlockedThisDeviceOnly` IN
/// FORCE (the 13p-fix R1-2 fact: `kSecAttrAccessible` is inert on macOS
/// without `kSecUseDataProtectionKeychain`), so Migration Assistant and
/// Time Machine no longer carry a signed-in session to other hardware — a
/// migrated Mac signs in again (recorded, not a bug). The 9c-era
/// file-based item under `session` migrates by the store key's own TN3137
/// road: read legacy → re-add bound → VERIFY through the production read →
/// delete legacy; idempotent, crash-tolerant (a lingering legacy copy is
/// swept at the next bound hit, once per service per process), and the
/// tokens are returned even when the move is refused. `AfterFirstUnlock`
/// gave way to `WhenUnlocked…`: a background round after reboot-then-lock
/// is a refused round (the design's own "a locked device never syncs").
nonisolated enum KeychainAuthStorage {
    /// The Variorum-project session's home.
    static let variorumService = "io.lduarte.Variorum.auth"
    /// The LEGACY account name (the 9c-era file-based item) — internal so
    /// `LegacyPasteInCleanup` names the retired Fragments item by the same
    /// constant (round-1 NIT-2: two copies of one identity string would let
    /// a drift turn the delete into a silent no-op).
    static let account = "session"
    /// The BOUND account (pre-13x 1a) — distinct from the legacy one on
    /// purpose (the store-key family's measured lesson: a plain DP item
    /// under a SHARED account is matched by a no-flag delete, so the
    /// legacy sweep would destroy the bound item it just verified).
    static let boundAccount = "session-bound"

    static func load(service: String) -> AuthTokens? {
        if let bound = read(service: service, bound: true) {
            sweepLegacyOnce(service: service)
            return bound
        }
        guard let legacy = read(service: service, bound: false) else { return nil }
        migrateLegacyItem(legacy, service: service)
        return legacy
    }

    @discardableResult
    static func save(_ tokens: AuthTokens, service: String) -> Bool {
        guard add(tokens, service: service) else { return false }
        // A fresh save supersedes any legacy copy outright.
        deleteItem(service: service, bound: false)
        return true
    }

    /// Released = gone from BOTH shapes, or never there (17h R3-5's
    /// semantics; a lingering file-based session would be exactly the copy
    /// the binding exists to end).
    @discardableResult
    static func clear(service: String) -> Bool {
        let bound = deleteItem(service: service, bound: true)
        let legacy = deleteItem(service: service, bound: false)
        return bound && legacy
    }

    // MARK: - The TN3137 road (write → VERIFY → delete old)

    private static func migrateLegacyItem(_ tokens: AuthTokens, service: String) {
        guard add(tokens, service: service) else { return }
        guard read(service: service, bound: true) == tokens else {
            deleteItem(service: service, bound: true)
            return
        }
        deleteItem(service: service, bound: false)
    }

    private static func add(_ tokens: AuthTokens, service: String) -> Bool {
        guard let data = try? JSONEncoder().encode(tokens) else { return false }
        var attributes = boundQuery(service: service)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: data]
            return SecItemUpdate(boundQuery(service: service) as CFDictionary, update as CFDictionary)
                == errSecSuccess
        }
        return status == errSecSuccess
    }

    private static func read(service: String, bound: Bool) -> AuthTokens? {
        var query = bound ? boundQuery(service: service) : legacyQuery(service: service)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(AuthTokens.self, from: data)
    }

    @discardableResult
    private static func deleteItem(service: String, bound: Bool) -> Bool {
        let status = SecItemDelete(
            (bound ? boundQuery(service: service) : legacyQuery(service: service)) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// The bound item's query — DP marker on EVERY verb (the family rule
    /// `KeychainPartitionTests` asserts structurally). Internal for that pin.
    static func boundQuery(service: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: boundAccount,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    /// The 9c-era file-based item's query (read for migration; deleted).
    private static func legacyQuery(service: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    // MARK: - The once-per-process legacy sweep

    private static let sweepLock = NSLock()
    nonisolated(unsafe) private static var sweptServices: Set<String> = []

    private static func sweepLegacyOnce(service: String) {
        sweepLock.lock()
        let alreadySwept = !sweptServices.insert(service).inserted
        sweepLock.unlock()
        guard !alreadySwept else { return }
        deleteItem(service: service, bound: false)
    }
}

/// The Phase 8 paste-in's Keychain item (its store type was deleted at
/// Phase 9c Step 5) and, since the bridge's 2026-09-04 retirement, the
/// retired Fragments-project session item: cleared on TWO occasions — every
/// REAL-STORE sign-in (the paste-in's original occasion) and every
/// REAL-STORE `AppServices.start()`, both off-main through the one private
/// `runRetiredCredentialSweep()` (the retirement's round-1 fix, MINOR-1: a
/// persisted session adopted at launch never routes through the sign-in
/// occasion, and a user who never signs out again would otherwise keep the
/// bridge's cross-project refresh token in the login keychain forever; its
/// round-3 finding 1 made the sign-in occasion gated + off-main too, at
/// pre-13x batch 1a).
/// A LOCAL clear only: the Fragments project's session is NOT revoked
/// server-side by this — Supabase refresh tokens never expire on their own,
/// they are only ever consumed or revoked — so it stays valid until she
/// signs out of Fragments globally or the Fragments agent revokes it (the
/// carry item asks; QUESTIONS #89). No Variorum client presents it. This is
/// the ONE remaining reference to either old service string — pinned by
/// the retirement walk in `Phase9cAuthWiringTests`.
nonisolated enum LegacyPasteInCleanup {
    static let retiredService = "io.lduarte.Variorum.sync"
    /// The retired bridge's Fragments-project session home (2026-09-04).
    static let retiredFragmentsService = "io.lduarte.Variorum.fragments-auth"

    static func clear() {
        // The paste-in's item carried its own account name ("supabase",
        // the Phase 8 store); the Fragments item was a `KeychainAuthStorage`
        // session, so it carries that storage's one account constant.
        for (service, account) in [
            (retiredService, "supabase"),
            (retiredFragmentsService, KeychainAuthStorage.account),
        ] {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
            ]
            SecItemDelete(query as CFDictionary)
        }
    }
}

// MARK: - The session

nonisolated enum AuthSessionError: Error, Equatable, Sendable {
    /// The auth endpoint refused (status + body verbatim, for the status row).
    case endpointFailure(status: Int, body: String)
    case notHTTP
    case malformedResponse(String)
}

/// Phase 14c batch 3 (L8): what a sign-up produced. Supabase answers the
/// signup endpoint two ways — a FULL token response when email
/// confirmations are off (the session adopts, exactly as sign-in), or a
/// session-less user body when a confirmation email went out (sign-in
/// completes after the link).
nonisolated enum SignUpOutcome: Equatable, Sendable {
    case signedIn
    case confirmationRequired
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
    /// 13e batch 9 (B-1): has the persisted session been consulted (or
    /// superseded by an adopt/sign-out)? The lazy load's whole bookkeeping.
    private var storeLoaded = false
    /// Single-flight: concurrent refresh demands coalesce onto one request.
    private var refreshTask: Task<AuthTokens, Error>?
    /// Sign-in/out notification (the app wires the UI + the sync session
    /// lifecycle here). Fired on adopt and on sign-out, never on refresh.
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
        // 13e batch 9 (B-1): the Keychain read that used to happen HERE now
        // happens at first use — see the type's header and
        // `ensureLoadedFromStore`. Construction touches no Keychain at all.
    }

    // MARK: State

    /// 13e batch 9 (B-1): the persisted session, read once, at first use.
    ///
    /// SYNCHRONOUS on purpose. The load runs on the actor's executor (never
    /// the main thread — that is the whole fix), and keeping it free of any
    /// suspension point means no `adopt`/`signOut` can interleave between
    /// the Keychain read and the adoption of what it returned: a stale
    /// persisted session can never overwrite a live one, without a single
    /// guard for it. `storeLoaded` is set FIRST so the flag reads true for
    /// anything the closure could reach, and so `adopt`/`signOut` can
    /// declare the store consulted (their own write is the newer truth —
    /// re-reading it later would only risk reviving what they replaced).
    private func ensureLoadedFromStore() {
        guard !storeLoaded else { return }
        storeLoaded = true
        tokens = store.load()
    }

    var isSignedIn: Bool {
        get async { ensureLoadedFromStore(); return tokens != nil }
    }

    var currentUserID: String? {
        get async { ensureLoadedFromStore(); return tokens?.userID }
    }

    var currentEmail: String? {
        get async { ensureLoadedFromStore(); return tokens?.email }
    }

    func setOnChange(_ handler: @escaping @Sendable (AuthTokens?) -> Void) {
        onChange = handler
    }

    // MARK: The sign-in door (Phase 14a: the direct password grant)

    /// `POST /auth/v1/token?grant_type=password` — THE sign-in door.
    /// The Variorum session signs in with the suite email+password against
    /// its own project (round 0h). Only the resulting session persists,
    /// never the password.
    func signInWithPassword(email: String, password: String) async throws {
        let response = try await tokenRequest(
            grantType: "password",
            body: ["email": email, "password": password])
        let adopted = AuthTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresAt: response.expiryDate(now: now()),
            userID: response.user?.id ?? "",
            email: response.user?.email)
        guard !adopted.userID.isEmpty else {
            throw AuthSessionError.malformedResponse("token response carried no user id")
        }
        adopt(adopted)
    }

    /// `POST /auth/v1/signup` — THE account-creation door (Phase 14c,
    /// THE DESIGN 6): the same seam and project as sign-in. While the
    /// signups toggle is OFF (the corpus guard — it flips only as the
    /// gate's deliberate act), the server refuses with the
    /// signups-disabled body and this throws `endpointFailure` for the
    /// surface to classify honestly. On success: an autoconfirm response
    /// IS a token response — adopt it (signed in, exactly as the
    /// password grant); a session-less body means the confirmation email
    /// went out and sign-in completes after the link. Only a resulting
    /// session ever persists, never the password.
    func signUp(email: String, password: String) async throws -> SignUpOutcome {
        var request = URLRequest(
            url: configuration.projectURL.appendingPathComponent("auth/v1/signup"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "apikey")
        request.httpBody = try JSONEncoder().encode(["email": email, "password": password])

        let (data, response) = try await http(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthSessionError.notHTTP
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw AuthSessionError.endpointFailure(
                status: httpResponse.statusCode,
                body: String(data: data, encoding: .utf8) ?? "")
        }
        // The autoconfirm shape decodes as the full token response
        // (access/refresh/user); anything else on a 2xx is the
        // confirmation-required user body — created, not yet signed in.
        guard let token = try? JSONDecoder().decode(TokenResponse.self, from: data),
              let user = token.user, !user.id.isEmpty
        else { return .confirmationRequired }
        adopt(AuthTokens(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
            expiresAt: token.expiryDate(now: now()),
            userID: user.id,
            email: user.email))
        return .signedIn
    }

    /// The injectable entry (tests; any future door): adopt a ready-made
    /// token set as the signed-in session.
    func adopt(_ newTokens: AuthTokens) {
        // 13e batch 9 (B-1): an adopt SUPERSEDES whatever the Keychain held,
        // so the lazy load has nothing left to do — and must never run later
        // and overwrite this with the older item.
        storeLoaded = true
        tokens = newTokens
        store.save(newTokens)
        onChange?(newTokens)
    }

    /// Best-effort server-side logout, unconditional local clear. The only
    /// path that destroys a session.
    func signOut() async {
        // 13e batch 9 (B-1): a sign-out before anything read the store must
        // still log the PERSISTED session out server-side — so consult it
        // first, exactly as the eager load used to guarantee.
        ensureLoadedFromStore()
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
        ensureLoadedFromStore()  // 13e batch 9 (B-1): first use, first read
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

    // MARK: Refresh (single-flight)

    private func refresh() async throws -> AuthTokens {
        ensureLoadedFromStore()  // 13e batch 9 (B-1): first use, first read
        if let inFlight = refreshTask {
            // Review round 2 (NIT): waiters run the same post-await
            // re-check as the leader — a sign-out landing mid-refresh must
            // not hand a signed-out caller a session. Adoption happens
            // INSIDE the shared task (below), so a waiter always observes
            // post-adoption state; returning the LIVE tokens also covers a
            // superseding sign-in (whatever is current wins).
            _ = try await inFlight.value
            guard let live = tokens else { throw UserSessionError.notSignedIn }
            return live
        }
        guard let current = tokens else { throw UserSessionError.notSignedIn }
        let task = Task { try await self.performRefresh(from: current) }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }

    /// The leader's whole refresh — HTTP hop, then the post-await adoption
    /// guards, all inside the single-flight task so every awaiter observes
    /// a settled outcome.
    ///
    /// Review round 1 (MINOR): the HTTP await releases the actor, so a
    /// sign-out (or a whole new sign-in) can interleave before the result
    /// lands. Adopting it unconditionally would RESURRECT a signed-out
    /// session — UI and sync torn down while the Keychain holds live
    /// tokens and the next launch comes up signed in, an explicit sign-out
    /// silently undone ("only signOut clears" is this type's contract, and
    /// its inverse — sign-out is terminal — must hold too).
    private func performRefresh(from current: AuthTokens) async throws -> AuthTokens {
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
        guard let live = tokens else {
            // Signed out mid-refresh: discard the result; the caller's
            // round refuses like any signed-out round.
            throw UserSessionError.notSignedIn
        }
        guard live.refreshToken == current.refreshToken else {
            // Superseded mid-refresh (a new sign-in adopted a different
            // session): the LIVE session wins; nothing is saved from the
            // stale result.
            return live
        }
        tokens = next
        store.save(next)
        return next
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
        case user
    }

    /// `expires_at` (unix seconds) wins; else `now + expires_in`; else a
    /// conservative hour.
    func expiryDate(now: Date) -> Date {
        if let expiresAt { return Date(timeIntervalSince1970: expiresAt) }
        return now.addingTimeInterval(expiresIn ?? 3600)
    }
}
