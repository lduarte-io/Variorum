//
//  OneRefreshAuthorityTests.swift
//  VariorumTests
//
//  VX-329 U3 — VX-423: ONE REFRESH AUTHORITY PER PROCESS (the plan's §6b brief; the U3 RECORD carries the trace and
//  every red-on-old). The account's refresh token ROTATES: every refresh spends the token it presents and hands back a
//  new one, and GoTrue's reuse detection answers a spent token with `refresh_token_already_used` and revokes the whole
//  family. Two `AuthSession` actors over ONE stored session — the services' (sync, the account doors) and the protection
//  road's vault leaf's — each read the stored token once and refreshed on their own, so the second to refresh presented
//  a token the first had already spent, and sync stopped until she signed in again. The process now holds ONE
//  `AuthSession`, the bootstrap's, and hands it to both.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The composition (source)

/// THE COMPOSITION, read from the product's own sources: the process mints its session in ONE place, the bootstrap, and
/// every consumer is handed that one. Red on the pre-fix tree by construction — two mints (the services' default in
/// `AppServices.init`, the vault leaf's `FollowingSessionProvider` `make`), neither in the bootstrap.
@Suite("VX-423 — the process's one refresh authority: the composition (source)")
struct OneRefreshAuthorityCompositionTests {
    /// `App/Variorum/` — through the symlink a headless harness reads this file by, when there is one.
    static let appRoot = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum

    /// Every product source of both apps (the shared brains and faces, the Mac's, the phone's) — never a test's.
    static func productSources() -> [URL] {
        ["Shared", "Variorum", "VariorumMobile"].flatMap { folder -> [URL] in
            let root = appRoot.appendingPathComponent(folder, isDirectory: true)
            guard let walk = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else { return [] }
            return walk.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        }
    }

    /// A source's CODE — every line with its `//` comment cut off (a history comment may name what left; only code
    /// counts).
    static func code(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    static func code(_ relative: String) throws -> String {
        try code(appRoot.appendingPathComponent(relative))
    }

    /// `AuthSession(` as a construction — never `AuthSessionError(` or another name ending in it.
    static func constructions(in text: String) -> Int {
        text.ranges(of: "AuthSession(").filter { range in
            guard range.lowerBound > text.startIndex else { return true }
            let before = text[text.index(before: range.lowerBound)]
            return !(before.isLetter || before.isNumber || before == "_")
        }.count
    }

    @Test func theProductMintsItsSessionOnceInTheBootstrapAndNowhereElse() throws {
        let sources = Self.productSources()
        #expect(sources.count > 100, "the walk reads the product's sources (\(sources.count) found)")
        var mints: [String: Int] = [:]
        for url in sources {
            let count = Self.constructions(in: try Self.code(url))
            if count > 0 { mints[url.lastPathComponent, default: 0] += count }
        }
        #expect(mints == ["AppBootstrap.swift": 1],
                "ONE AuthSession per process, minted by the bootstrap — found \(mints)")
    }

    @Test func bothRootsHandTheBootstrapsAuthorityToTheServices() throws {
        for root in ["Variorum/VariorumApp.swift", "VariorumMobile/VariorumMobileApp.swift"] {
            let text = try Self.code(root)
            #expect(text.contains("AppServices("), "\(root) composes the services")
            #expect(text.contains("auth: bootstrap.auth"), "\(root) hands the services the bootstrap's one authority")
        }
    }

    @Test func theProtectionRoadIsComposedOverTheSameAuthority() throws {
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        #expect(bootstrap.contains("RoadInputs.live(variant: variant, auth: auth"),  // VX-487 F-M1-1: + the one sync-keys leaf
                "the production road's every composed system rides the bootstrap's authority")
        let road = try Self.code("Shared/Protection/ProtectionOpenRoad.swift")
        #expect(road.contains("ProtectionSystem.live(variant: variant, session: auth"))  // VX-487 F-M1-1: + the leaf
        let system = try Self.code("Shared/Protection/ProtectionSystem.swift")
        #expect(system.contains("WireVaultLeaf.live(deviceName: deviceName, session: session)"),
                "the system's vault leaf is served by the session it is handed")
    }

    @Test func theVaultLeafNoLongerFollowsTheStoredSessionOnItsOwn() throws {
        let leftovers = try Self.productSources().filter { url in
            let named = url.lastPathComponent == "FollowingSessionProvider.swift"
            return try named || Self.code(url).contains("FollowingSessionProvider")
        }
        #expect(leftovers.isEmpty, "the leaf's own session provider is gone — \(leftovers.map(\.lastPathComponent))")
    }
}

// MARK: - The race (behavioral, no network)

/// A GoTrue that ROTATES as the real one does: every refresh SPENDS the token it is handed and issues the next
/// (`rt-1` → `rt-2` → …, each with its access token `at-N`); a token that is not the family's live one — spent, or any
/// token once the family is revoked — is REUSE: answered `400 refresh_token_already_used` and the WHOLE family revoked
/// (the server's reuse detection past its short reuse interval; the production race is an hour apart, never inside it).
/// It also serves the vault read the leaf makes (`GET rest/v1/key_vault` → `[]`, no vault yet) and the logout. Every
/// refresh token presented is recorded; `delay` holds the token hop open (the concurrent race).
final class RotatingGoTrue: @unchecked Sendable {
    let userID: String
    private let lock = NSLock()
    private var live = 1
    private var presentedTokens: [String] = []
    private var refusedTokens: [String] = []
    private var familyRevoked = false
    var delay: Duration?

    init(userID: String) { self.userID = userID }

    /// Every refresh token presented, in order.
    var presented: [String] { lock.withLock { presentedTokens } }
    /// The ones refused as reuse.
    var refused: [String] { lock.withLock { refusedTokens } }
    var revoked: Bool { lock.withLock { familyRevoked } }

    static let reuseBody = #"{"code":400,"error_code":"refresh_token_already_used","msg":"Invalid Refresh Token: Already Used"}"#

    private func refresh(_ token: String) -> (Int, String) {
        lock.withLock {
            presentedTokens.append(token)
            guard !familyRevoked, token == "rt-\(live)" else {
                refusedTokens.append(token)
                familyRevoked = true
                return (400, Self.reuseBody)
            }
            live += 1
            return (200, """
                {"access_token": "at-\(live)", "refresh_token": "rt-\(live)", "expires_in": 3600, "token_type": "bearer",
                 "user": {"id": "\(userID)", "email": "author@example.com"}}
                """)
        }
    }

    func loader() -> @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [self] request in
            let url = try #require(request.url)
            let (status, body): (Int, String)
            if url.path.hasSuffix("/auth/v1/token") {
                if let delay { try? await Task.sleep(for: delay) }
                let fields = try JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data())
                (status, body) = refresh(fields["refresh_token"] ?? "")
            } else if url.path.hasSuffix("/rest/v1/key_vault") {
                (status, body) = (200, "[]")
            } else {
                (status, body) = (204, "")
            }
            return (Data(body.utf8), HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!)
        }
    }
}

/// The pins' clock (the access token's expiry is what makes a consumer refresh).
final class PinClock: @unchecked Sendable {
    private let lock = NSLock()
    private var current = Date(timeIntervalSince1970: 1_800_000_000)
    var now: Date { lock.withLock { current } }
    func advance(_ seconds: TimeInterval) { lock.withLock { current = current.addingTimeInterval(seconds) } }
}

/// What an attempt came to — the race keeps going past a refused step, so the whole burn is seen.
func attempt<T>(_ body: () async throws -> T) async -> Result<T, any Error> {
    do { return .success(try await body()) } catch { return .failure(error) }
}

/// The vault read ANSWERED (no vault yet) rather than refusing. Matched on the case — never `try? … == nil`, which
/// `try?`'s flattening makes true for a refusal too (the revert run caught exactly that).
func answeredNoVault(_ read: Result<VaultSnapshot?, any Error>) -> Bool {
    if case .success(.none) = read { return true }
    return false
}

/// ONE stored token, the process's one authority over it (what the composition root hands `AppServices` — its sync
/// transport and account doors ride exactly this), and the vault leaf AS PRODUCTION COMPOSES IT, handed that authority
/// (`WireVaultLeaf.live`, the vault endpoint scripted).
struct RaceWorld {
    *[removed for publication]*
    static let configuration = AuthConfiguration(
        projectURL: URL(string: "https://vx423-pin.invalid")!, apiKey: "pin-publishable")

    let clock = PinClock()
    let gotrue: RotatingGoTrue
    let store: AuthTokensStore
    let auth: AuthSession
    let leaf: WireVaultLeaf

    init(signedIn: Bool = true) throws {
        let clock = clock
        gotrue = RotatingGoTrue(userID: Self.user)
        store = AuthTokensStore.inMemory(initial: signedIn ? Self.tokens(user: Self.user, at: clock.now) : nil)
        auth = AuthSession(configuration: Self.configuration, store: store, now: { clock.now }, http: gotrue.loader())
        leaf = try #require(WireVaultLeaf.live(deviceName: "Pin Mac", session: auth, load: gotrue.loader()))
    }

    /// The stored session: `rt-1`, its access token good for the hour.
    static func tokens(user: String, at now: Date) -> AuthTokens {
        AuthTokens(
            accessToken: "at-1", refreshToken: "rt-1", expiresAt: now.addingTimeInterval(3600),
            userID: user, email: "author@example.com")
    }
}

@Suite("VX-423 — the process's one refresh authority: the two-refreshers race (a rotating fake, no network)")
struct OneRefreshAuthorityRaceTests {
    /// THE RED-ON-OLD PIN (the race of the U3 RECORD's step 4): the leaf reads while the access token is fresh; an hour
    /// on, the services' round refreshes `rt-1` → `rt-2`; the leaf reads again; another hour on, the services refresh
    /// again. One authority: the leaf rides the rotation, nothing is ever presented twice, the family stands. The pre-fix
    /// shape (the leaf riding its OWN second instance over the same stored session — the record's behavioral revert):
    /// the leaf refreshes its cached `rt-1`, the fake revokes the family, the leaf is refused, and the services' next
    /// refresh is refused too — sync stopped until a new sign-in.
    @Test func aRotationByTheServicesNeverLeavesTheVaultLeafASpentToken() async throws {
        let world = try RaceWorld()
        let first = await attempt { try await world.leaf.fetchVault(accountID: RaceWorld.user) }
        #expect(answeredNoVault(first), "the leaf reads with the fresh access token — \(first)")

        world.clock.advance(3700)
        let rotated = await attempt { try await world.auth.currentSession() }
        #expect((try? rotated.get())?.accessToken == "at-2", "the services' round rotates rt-1 → rt-2 — \(rotated)")

        let second = await attempt { try await world.leaf.fetchVault(accountID: RaceWorld.user) }
        #expect(answeredNoVault(second), "the leaf reads on, riding the rotation — \(second)")

        world.clock.advance(3700)
        let next = await attempt { try await world.auth.currentSession() }
        #expect((try? next.get())?.accessToken == "at-3", "the services' next refresh lands — \(next)")

        #expect(world.gotrue.presented == ["rt-1", "rt-2"], "each token presented once, in rotation order")
        #expect(world.gotrue.refused.isEmpty, "no token was presented after it was spent")
        #expect(!world.gotrue.revoked, "the account's session family stands")
    }

    /// THE RED-ON-OLD PIN, the race at its sharpest: both consumers find the access token expired AT ONCE (the services'
    /// round and a pane's vault read) — one authority single-flights them onto ONE refresh request. Pre-fix: two actors,
    /// two requests carrying `rt-1`, the second one reuse — the family revoked.
    @Test func bothConsumersPastExpiryAtOnceRefreshOnce() async throws {
        let world = try RaceWorld()
        _ = try await world.leaf.fetchVault(accountID: RaceWorld.user)
        world.clock.advance(3700)
        world.gotrue.delay = .milliseconds(80)

        async let services = attempt { try await world.auth.currentSession() }
        async let pane = attempt { try await world.leaf.fetchVault(accountID: RaceWorld.user) }
        let (round, read) = await (services, pane)

        #expect((try? round.get())?.accessToken == "at-2", "\(round)")
        #expect(answeredNoVault(read), "\(read)")
        #expect(world.gotrue.presented == ["rt-1"], "ONE refresh request for both consumers")
        #expect(world.gotrue.refused.isEmpty && !world.gotrue.revoked)
    }

    /// THE MECHANISM'S WITNESS (green on both sides by design — it is the trace, not the fix): two `AuthSession`s over
    /// ONE stored session DO burn it on this fake — so the pins above are never green for want of a fake that revokes.
    @Test func twoInstancesOverOneStoredTokenBurnTheSessionOnThisFake() async throws {
        let world = try RaceWorld()
        let clock = world.clock
        let second = AuthSession(
            configuration: RaceWorld.configuration, store: world.store, now: { clock.now }, http: world.gotrue.loader())
        _ = try await second.currentSession()  // B reads rt-1 while the access token is fresh

        world.clock.advance(3700)
        _ = try await world.auth.currentSession()  // A rotates rt-1 → rt-2 (saved to the one store)

        let stale = await attempt { try await second.currentSession() }  // B refreshes its cached rt-1
        #expect(throws: AuthSessionError.endpointFailure(status: 400, body: RotatingGoTrue.reuseBody)) { try stale.get() }
        let afterBurn = await attempt { try await world.auth.refreshedSession() }  // A's next refresh: rt-2
        #expect(throws: AuthSessionError.endpointFailure(status: 400, body: RotatingGoTrue.reuseBody)) { try afterBurn.get() }
        #expect(world.gotrue.presented == ["rt-1", "rt-1", "rt-2"])
        #expect(world.gotrue.refused == ["rt-1", "rt-2"])
        #expect(world.gotrue.revoked, "the family is revoked — sync stops until a new sign-in")
    }

    /// VX-308 R-3's claim ON THE NEW SHAPE (a regression guard, green on both sides by design; it replaces
    /// `FollowingSessionProviderTests`, deleted with its subject): handed the one authority, the leaf follows a sign-out
    /// and a sign-in to ANOTHER account — the read refuses with nobody signed in, answers as whoever is signed in now,
    /// and never as the account that signed out.
    @Test func theVaultLeafFollowsASignOutAndASignInToAnotherAccount() async throws {
        let world = try RaceWorld(signedIn: false)
        let other = "11f2d9c4-1234-4abc-8def-000000000042"
        await #expect(throws: VaultRefusal.notSignedIn) { try await world.leaf.fetchVault(accountID: RaceWorld.user) }

        await world.auth.adopt(RaceWorld.tokens(user: RaceWorld.user, at: world.clock.now))
        #expect(try await world.leaf.fetchVault(accountID: RaceWorld.user) == nil, "signed in: the leaf answers as her")

        await world.auth.signOut()
        await #expect(throws: VaultRefusal.notSignedIn) { try await world.leaf.fetchVault(accountID: RaceWorld.user) }

        await world.auth.adopt(RaceWorld.tokens(user: other, at: world.clock.now))
        #expect(try await world.leaf.fetchVault(accountID: other) == nil, "a sign-in to another account is followed")
        await #expect(throws: VaultRefusal.notSignedIn, "never as the account that signed out") {
            try await world.leaf.fetchVault(accountID: RaceWorld.user)
        }
    }
}
