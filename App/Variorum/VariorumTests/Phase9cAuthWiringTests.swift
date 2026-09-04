//
//  Phase9cAuthWiringTests.swift
//  VariorumTests
//
//  Phase 9c, Step 5 — sign-in state drives the sync session, the adoption
//  backfill rides the sign-in, the A4 fence holds in the sign-in era, and
//  the paste-in is provably retired (the source walk). (The bridge half —
//  the Fragments session driving the bridge engine, its cadence pins, the
//  14d liveness pin — left with the bridge, 2026-09-04, pre-13x batch 0b.)
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Auth wiring (Phase 9c, Step 5)")
struct Phase9cAuthWiringTests {
    private static let testAuthConfiguration = AuthConfiguration(
        projectURL: URL(string: "https://variorum-project.supabase.co")!,
        apiKey: "publishable")

    private static func tokens(userID: String, email: String? = nil) -> AuthTokens {
        AuthTokens(
            accessToken: "access", refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            userID: userID, email: email)
    }

    /// An HTTP hop that must never be reached (adopt/signOut paths only;
    /// signOut's best-effort logout tolerates the throw).
    private static let noNetwork: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { _ in
        throw AuthSessionError.malformedResponse("no network in this test")
    }

    /// Recording sync transport (no network — review round 1, MINOR: the
    /// original tests composed the PRODUCTION transport and fired real
    /// requests at the project URL; the factory seam + these fakes restore
    /// the repo-wide no-network discipline and make the assertions
    /// composition-truths).
    private actor RecordingSyncTransport: SyncTransport {
        private(set) var calls = 0

        func push(_ batch: [SyncRow], activeKeyID: String) async throws -> [SyncPushOutcome] {
            calls += 1
            return batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int, activeKeyID: String, deviceID: String?) async throws -> [SyncPulledRow] {
            calls += 1
            return []
        }
        /// Uncounted round plumbing (the pins count data calls).
        func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
    }

    /// One composed world: in-memory store, real AppSession/AppServices,
    /// an injected auth session over an in-memory store, a recording
    /// transport through the factory seam, and — mirroring the production
    /// install in AppBootstrap — an ownerIdentity closure reading the SAME
    /// persisted-session store AuthSession writes.
    private func withWiredServices(
        storeVariant: AppDatabase.StoreVariant = .real,
        authHTTP: (@Sendable (URLRequest) async throws -> (Data, URLResponse))? = nil,
        _ body: @MainActor (AppServices, AuthSession, AppDatabase, RecordingSyncTransport) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let authStore = AuthTokensStore.inMemory()
        let auth = AuthSession(
            configuration: Self.testAuthConfiguration, store: authStore,
            http: authHTTP ?? Self.noNetwork)
        let syncTransport = RecordingSyncTransport()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
            // The AppBootstrap install, mirrored: identity = the persisted
            // Variorum session's user.
            $0.ownerIdentity = OwnerIdentity { authStore.load()?.userID }
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let services = AppServices(
                session: session, storeVariant: storeVariant,
                backupEnabled: false,
                auth: auth,
                makeSyncTransport: { _ in syncTransport },
                // Phase 14b: a working fixed key world so wiring rounds
                // reach the transport (never the real Keychain in tests).
                makeSyncKeyProvider: { AppTestKeyProvider() })
            await services.start()
            try await body(services, auth, db, syncTransport)
            services.stop()
        }
    }

    private func settle(
        until condition: @MainActor () async -> Bool
    ) async {
        for _ in 0..<400 {
            if await condition() { return }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    // MARK: The direct sign-in (Phase 14a, batch 1)

    /// The full app-layer door (round 0h: "the 9c AuthSession password
    /// grant, re-aimed"): email+password → the password grant against the
    /// Variorum project → account state, the Step 4 adoption, and the sync
    /// chain — the same downstream composition the retired delegated door
    /// drove. Pre-batch this door did not exist (the Variorum session
    /// could only be minted through the browser flow), so the old side of
    /// this pin is the retirement walk BELOW plus a compile-time absence.
    @Test func theDirectSignInComposesTheSyncChainAndRunsTheAdoption() async throws {
        let grant: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
            let url = request.url!.absoluteString
            guard url.contains("grant_type=password") else {
                throw AuthSessionError.malformedResponse("unexpected request: \(url)")
            }
            return (Data("""
                {"access_token": "direct-access", "refresh_token": "direct-refresh",
                 "expires_in": 3600,
                 "user": {"id": "owner-14a", "email": "her@example.com"}}
                """.utf8),
                HTTPURLResponse(url: request.url!, statusCode: 200,
                                httpVersion: nil, headerFields: nil)!)
        }
        try await withWiredServices(authHTTP: grant) { services, _, db, syncTransport in
            #expect(!services.sync.isConfigured, "signed out ⇒ no sync chain")
            // A pre-sign-in (unowned) row — the adoption's target.
            let postID = try await services.runnerPostID(title: "pre-sign-in")

            await services.signInWithVariorum(email: "her@example.com", password: "pw")
            await settle { services.sync.isConfigured }

            #expect(services.account.lastError == nil)
            #expect(services.account.variorum?.userID == "owner-14a")
            #expect(services.account.variorum?.email == "her@example.com")
            #expect(services.sync.isConfigured,
                    "the direct sign-in must compose the sync chain")
            #expect(try db.fetchString(
                "SELECT owner_id FROM container WHERE id = ?", [postID]) == "owner-14a",
                "the Step 4 adoption must ride the direct sign-in")
            await settle { await syncTransport.calls > 0 }
            #expect(await syncTransport.calls > 0)
        }
    }

    /// REVIEW ROUND 1, R1-1 — THE RED-ON-OLD PIN: the wrong-password
    /// refusal (the direct form's COMMON failure) must speak the R94 way —
    /// classified into "Wrong email or password." — never surface as the
    /// raw enum dump (`String(describing:)` of `endpointFailure` with the
    /// 400/`invalid_grant` body, the pre-fix face).
    @Test func aWrongPasswordRefusalSpeaksTheHumanLine() async throws {
        let refusal: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
            (Data(#"{"error":"invalid_grant","error_description":"Invalid login credentials"}"#.utf8),
             HTTPURLResponse(url: request.url!, statusCode: 400,
                             httpVersion: nil, headerFields: nil)!)
        }
        try await withWiredServices(authHTTP: refusal) { services, _, _, _ in
            await services.signInWithVariorum(email: "her@example.com", password: "wrong")
            #expect(services.account.lastError == "Wrong email or password.")
            #expect(services.account.variorum == nil, "a refused sign-in signs nothing in")
            #expect(!services.sync.isConfigured)
        }
    }

    /// ROUND 2, R2-2 — the pin's SECOND credentials dialect: modern GoTrue
    /// refuses with `error_code: "invalid_credentials"` (no `invalid_grant`
    /// anywhere in the body). The mapper covers both dialects; which one her
    /// live project speaks is verified only at the gate's live walk, so BOTH
    /// arms are pinned here. Same mapped line, same door.
    @Test func aModernDialectRefusalSpeaksTheSameHumanLine() async throws {
        let refusal: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
            (Data(#"{"code":400,"error_code":"invalid_credentials","msg":"Invalid login credentials"}"#.utf8),
             HTTPURLResponse(url: request.url!, statusCode: 400,
                             httpVersion: nil, headerFields: nil)!)
        }
        try await withWiredServices(authHTTP: refusal) { services, _, _, _ in
            await services.signInWithVariorum(email: "her@example.com", password: "wrong")
            #expect(services.account.lastError == "Wrong email or password.")
            #expect(services.account.variorum == nil, "a refused sign-in signs nothing in")
            #expect(!services.sync.isConfigured)
        }
    }

    /// R1-1's other classes: every sign-in failure surfaces as a readable
    /// human line — offline/transport names the connection, an unexpected
    /// status names the refusal — never a raw `String(describing:)` dump.
    @Test func otherSignInFailureClassesGetReadableLines() {
        let offline = ErrorPresentation.signInFailureMessage(
            URLError(.notConnectedToInternet))
        #expect(offline == "Couldn't reach the server — check your connection and try again.")

        let serverError = ErrorPresentation.signInFailureMessage(
            AuthSessionError.endpointFailure(status: 503, body: "unavailable"))
        #expect(serverError == "Sign-in failed — the server refused (HTTP 503). Try again in a moment.")
        #expect(!serverError.contains("endpointFailure"), "never the enum's own face")

        let garbled = ErrorPresentation.signInFailureMessage(
            AuthSessionError.malformedResponse("decode failed"))
        #expect(garbled == "Sign-in failed — the server's response couldn't be read. Try again in a moment.")
    }

    // MARK: Sign-in drives sync + adoption

    @Test func signInConfiguresSyncRunsTheAdoptionAndUpdatesTheAccount() async throws {
        try await withWiredServices { services, auth, db, syncTransport in
            #expect(!services.sync.isConfigured, "signed out ⇒ no sync chain")
            #expect(services.account.variorum == nil)

            // A pre-sign-in (unowned) row — the adoption's target.
            let postID = try await services.runnerPostID(title: "pre-sign-in")
            #expect(try db.fetchString(
                "SELECT owner_id FROM container WHERE id = ?", [postID]) == nil)

            await auth.adopt(Self.tokens(userID: "owner-9c", email: "her@example.com"))
            await settle { services.sync.isConfigured }

            #expect(services.sync.isConfigured, "sign-in must compose the sync chain")
            #expect(services.account.variorum?.userID == "owner-9c")
            #expect(services.account.variorum?.email == "her@example.com")
            // The Step 4 backfill ran (idempotent, before the first push).
            #expect(try db.fetchString(
                "SELECT owner_id FROM container WHERE id = ?", [postID]) == "owner-9c")
            // And a round actually ran — on the INJECTED transport (the
            // factory seam: composition proven, zero real network).
            await settle { await syncTransport.calls > 0 }
            #expect(await syncTransport.calls > 0)
        }
    }

    @Test func signOutTearsTheChainDownAndKeepsTheStore() async throws {
        try await withWiredServices { services, auth, db, _ in
            await auth.adopt(Self.tokens(userID: "owner-9c"))
            await settle { services.sync.isConfigured }
            let postID = try await services.runnerPostID(title: "kept")

            await auth.signOut()
            await settle { !services.sync.isConfigured }

            #expect(!services.sync.isConfigured, "sign-out must stop the chain")
            #expect(services.account.variorum == nil)
            // Local data is untouched — sign-out is a session event, never
            // a data event.
            #expect(try db.fetchString(
                "SELECT id FROM container WHERE id = ?", [postID]) == postID)
        }
    }

    /// THE A4 FENCE IN THE SIGN-IN ERA: debug and release builds share a
    /// Keychain, so a dev-store session may LAUNCH already signed in — and
    /// must still never compose the sync chain or run the adoption against
    /// the dev store.
    @Test func devStoreSessionsStayFencedEvenWhenSignedIn() async throws {
        try await withWiredServices(storeVariant: .dev) { services, auth, db, syncTransport in
            let postID = try await services.runnerPostID(title: "dev row")

            await auth.adopt(Self.tokens(userID: "owner-9c"))
            try await Task.sleep(for: .milliseconds(150))

            #expect(!services.sync.isConfigured,
                    "a dev-store session must never pair with the production mirror")
            #expect(try db.fetchString(
                "SELECT owner_id FROM container WHERE id = ?", [postID]) == nil,
                "the fence precedes adoption — dev rows stay untouched")
            #expect(await syncTransport.calls == 0)
        }
    }

    // MARK: The lifecycle cadence (Phase 13c, batch 1D — ledger A2; the
    // bridge half — its cadence + ordering pins — retired 2026-09-04)

    /// The production hook still routes through the ONE became-active door
    /// (the source-walk form, beside the retirement walk below). Since the
    /// bridge's retirement the door is one sync trigger; it stays the one
    /// door so a future second follower of the cadence has a home.
    /// The became-active hook runs one sync round through the sync
    /// session's one trigger. (Until the bridge's 2026-09-04 retirement a
    /// wrapper added a bridge round beside it and this pin forbade the
    /// direct call; the wrapper left with its second half — round-1
    /// MINOR-4 — and the pin now asserts the direct door.)
    @Test func theBecomeActiveHookRunsOneSyncRound() throws {
        let appFile = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum/VariorumApp.swift")
        let text = try String(contentsOf: appFile, encoding: .utf8)
        #expect(text.contains("services?.sync.triggerSync()"),
                "the became-active hook must run one sync round")
        #expect(!text.contains("triggerLifecycleRound"),
                "…through the sync session directly: the bridge-era wrapper is gone")
    }

    /// The retirement's round-1 fix (MINOR-1): the retired-credential sweep
    /// runs at every `start()`, not only at the next real sign-in — a
    /// persisted session adopted at launch never routes through
    /// `variorumSignInChanged`, so a user who never signs out again would
    /// keep the bridge's cross-project refresh token in the login keychain
    /// forever (Supabase refresh tokens never expire on their own). The
    /// sweep is injected so the pin never touches the real Keychain; it
    /// runs off-main (detached), so the pin settles on it. Red on old:
    /// `start()` never called the sweep.
    @Test func startRunsTheRetiredCredentialSweep() async throws {
        let db = try AppDatabase.inMemory()
        let authStore = AuthTokensStore.inMemory()
        let auth = AuthSession(
            configuration: Self.testAuthConfiguration, store: authStore,
            http: Self.noNetwork)
        let sweeps = SweepSpy()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.ownerIdentity = OwnerIdentity { authStore.load()?.userID }
        } operation: { @MainActor in
            let services = AppServices(
                session: AppSession(database: db), storeVariant: .real,
                backupEnabled: false,
                auth: auth,
                makeSyncTransport: { _ in RecordingSyncTransport() },
                makeSyncKeyProvider: { AppTestKeyProvider() },
                legacyCleanup: { sweeps.record() })
            await services.start()
            await settle { sweeps.count >= 1 }
            #expect(sweeps.count >= 1,
                    "start() must run the retired-credential sweep (off-main)")
            services.stop()
        }
    }

    /// A Sendable counter for the sweep pin.
    private final class SweepSpy: @unchecked Sendable {
        private let lock = NSLock()
        private var _count = 0
        var count: Int { lock.withLock { _count } }
        func record() { lock.withLock { _count += 1 } }
    }

    // MARK: The retirement walk (review focus 4 — "no dead credential
    // path"; grep-pinned like the A6 walks)

    /// PHASE 14a, BATCH 1 — THE RETIREMENT WALK (red-on-old; the walk was
    /// run against the pre-batch tree and failed on every file it names):
    /// the delegated `custom:fragments` sign-in is OUT of the app's code.
    /// The Variorum sign-in is the direct password grant against its own
    /// project (round 0h: "the 9c AuthSession password grant, re-aimed");
    /// the browser-flow machinery (SignInFlow/ASWebAuthenticationSession,
    /// PKCE, the authorize/exchange doors, the captured provider pair) is
    /// retired wholesale — it returns at the Fragments batch, rebuilt
    /// against a live provider (batch brief, rounds 0w/0x).
    /// Every Swift source under Shared/ — DEEP (review round 1, R1-3):
    /// `Shared/` carries Swift-bearing subdirectories (EditorBrain/,
    /// MarkdownFace/, Theme/), and the walks' old shallow
    /// `contentsOfDirectory` would let a reintroduction under one evade
    /// them while their messages claim the shared sources are clean.
    private static func sharedSwiftSources() -> [URL] {
        let sharedDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Shared", isDirectory: true)
        guard let walk = FileManager.default.enumerator(
            at: sharedDir, includingPropertiesForKeys: nil)
        else { return [] }
        return walk.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    /// AMENDED AT 14D, and again at THE BRIDGE'S RETIREMENT (2026-09-04,
    /// pre-13x batch 0b): the browser-flow machinery 14d rebuilt for the
    /// bridge's delegated road into the Fragments project (`SignInFlow.swift`,
    /// ASWebAuthenticationSession, PKCE, the authorize/exchange doors, the
    /// `custom:stargazing` provider entry) is OUT again, with the bridge —
    /// and the OLD direction stays retired forever: the `custom:fragments`
    /// provider (Variorum trusting Fragments' issuer), its
    /// `signInWithFragments` door, and the captured provider-token pair.
    /// Red on the pre-retirement tree: `SignInFlow.swift` existed and the
    /// shared sources named `custom:stargazing`.
    @Test func theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut() throws {
        let sources = Self.sharedSwiftSources()
        #expect(!sources.isEmpty)
        #expect(sources.contains {
                    $0.deletingLastPathComponent().lastPathComponent != "Shared" },
                "the walk must be DEEP — subdirectory sources included (R1-3)")
        #expect(!sources.contains { $0.lastPathComponent == "SignInFlow.swift" },
                "the delegated browser flow left with the bridge (2026-09-04)")

        for file in sources {
            let text = try String(contentsOf: file, encoding: .utf8)
            let name = file.lastPathComponent
            #expect(!text.contains("custom:fragments"),
                    "\(name) still references the retired provider direction")
            #expect(!text.contains("custom:stargazing"),
                    "\(name) still references the retired bridge's delegated road into the Fragments project")
            #expect(!text.contains("signInWithFragments"),
                    "\(name) still carries the retired delegated Variorum sign-in door")
            #expect(!text.contains("ASWebAuthentication"),
                    "\(name) references the retired browser-flow machinery")
            #expect(!text.contains("provider_token"),
                    "\(name) still captures the retired delegated provider pair")
        }
    }

    @Test func thePasteInIsFullyRetiredInTheSharedSources() throws {
        let sources = Self.sharedSwiftSources()
        #expect(!sources.isEmpty)
        #expect(!sources.contains { $0.lastPathComponent == "SyncCredentialsStore.swift" },
                "the paste-in store must be deleted")

        for file in sources {
            let text = try String(contentsOf: file, encoding: .utf8)
            let name = file.lastPathComponent
            #expect(!text.contains("SyncCredentialsStore"),
                    "\(name) still references the retired store")
            #expect(!text.contains("SyncSetupView") || name == "SyncStatusViews.swift"
                    || name == "AuthViews.swift",
                    "\(name) still references the retired setup form")
            // The old Keychain service string survives in EXACTLY one
            // place: the cleanup that deletes the legacy item at first
            // sign-in.
            if text.contains("io.lduarte.Variorum.sync") {
                #expect(name == "AuthSession.swift",
                        "\(name) must not read the retired Keychain keys")
                #expect(text.contains("LegacyPasteInCleanup"))
            }
            // The retired bridge's Fragments-session service string
            // (2026-09-04) survives in exactly that same one place.
            if text.contains("io.lduarte.Variorum.fragments-auth") {
                #expect(name == "AuthSession.swift",
                        "\(name) must not read the retired Fragments-session keys")
                #expect(text.contains("retiredFragmentsService"))
            }
        }
    }
}

// MARK: - Small helpers

extension AppDatabase {
    fileprivate func fetchString(
        _ sql: String, _ arguments: [(any DatabaseValueConvertible)?] = []
    ) throws -> String? {
        try read { db in
            try String.fetchOne(db, sql: sql, arguments: StatementArguments(arguments))
        }
    }
}

extension AppServices {
    /// Mints a post through the production runner path (the same door the
    /// app's operations take), returning its id.
    fileprivate func runnerPostID(title: String) async throws -> String {
        try await runnerRun { ops in try ops.createPost(title: title).id }
    }

    fileprivate func runnerRun<T: Sendable>(
        _ body: @Sendable @escaping (Operations) throws -> T
    ) async throws -> T {
        try await session.runner.run { ops in try body(ops) }
    }
}
