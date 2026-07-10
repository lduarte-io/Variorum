//
//  Phase9cAuthWiringTests.swift
//  VariorumTests
//
//  Phase 9c, Step 5 — sign-in state drives both sessions (sync + bridge),
//  the adoption backfill rides the sign-in, the A4 fence holds in the
//  sign-in era, and the paste-in is provably retired (the source walk).
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
            userID: userID, email: email,
            providerToken: "frag-token", providerRefreshToken: "frag-refresh")
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
        func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
            calls += 1
            return batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
            calls += 1
            return []
        }
    }

    private actor RecordingBridgeTransport: FragmentsBridgeTransport {
        private(set) var calls = 0
        func push(_ entries: [FragmentsEntry]) async throws -> FragmentsPushResponse {
            calls += 1
            return FragmentsPushResponse(applied: entries.count, skipped: 0)
        }
        func pull(after cursor: FragmentsPullCursor?, limit: Int) async throws -> [FragmentsEntry] {
            calls += 1
            return []
        }
        func delete(ids: [String]) async throws -> Int { 0 }
        func fetchLocalUserID() async throws -> String? {
            calls += 1
            return nil  // the fail-closed gate holds pushes; pulls still run
        }
    }

    /// One composed world: in-memory store, real AppSession/AppServices,
    /// injected auth sessions over in-memory stores, recording transports
    /// through the factory seam, and — mirroring the production install in
    /// AppBootstrap — an ownerIdentity closure reading the SAME
    /// persisted-session store AuthSession writes.
    private func withWiredServices(
        storeVariant: AppDatabase.StoreVariant = .real,
        bridgeEnabled: Bool = true,
        _ body: @MainActor (AppServices, AuthSession, AuthSession, AppDatabase, RecordingSyncTransport, RecordingBridgeTransport) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let authStore = AuthTokensStore.inMemory()
        let fragmentsStore = AuthTokensStore.inMemory()
        let auth = AuthSession(
            configuration: Self.testAuthConfiguration, store: authStore,
            http: Self.noNetwork)
        let fragmentsAuth = AuthSession(
            configuration: Self.testAuthConfiguration, store: fragmentsStore,
            http: Self.noNetwork)
        let syncTransport = RecordingSyncTransport()
        let bridgeTransport = RecordingBridgeTransport()
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
                backupEnabled: false, bridgeEnabled: bridgeEnabled,
                auth: auth, fragmentsAuth: fragmentsAuth,
                makeSyncTransport: { _ in syncTransport },
                makeBridgeTransport: { _, _ in bridgeTransport })
            await services.start()
            try await body(services, auth, fragmentsAuth, db, syncTransport, bridgeTransport)
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

    // MARK: Sign-in drives sync + adoption

    @Test func signInConfiguresSyncRunsTheAdoptionAndUpdatesTheAccount() async throws {
        try await withWiredServices { services, auth, _, db, syncTransport, _ in
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
        try await withWiredServices { services, auth, _, db, _, _ in
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
    /// must still never compose the sync chain, run the adoption against
    /// the dev store, or touch the bridge.
    @Test func devStoreSessionsStayFencedEvenWhenSignedIn() async throws {
        try await withWiredServices(storeVariant: .dev) { services, auth, fragmentsAuth, db, syncTransport, bridgeTransport in
            let postID = try await services.runnerPostID(title: "dev row")

            await auth.adopt(Self.tokens(userID: "owner-9c"))
            await fragmentsAuth.adopt(Self.tokens(userID: "frag-user"))
            try await Task.sleep(for: .milliseconds(150))

            #expect(!services.sync.isConfigured,
                    "a dev-store session must never pair with the production mirror")
            #expect(!services.bridge.isConfigured,
                    "a dev-store session must never touch the live Fragments journal")
            #expect(try db.fetchString(
                "SELECT owner_id FROM container WHERE id = ?", [postID]) == nil,
                "the fence precedes adoption — dev rows stay untouched")
            #expect(await syncTransport.calls == 0)
            #expect(await bridgeTransport.calls == 0)
        }
    }

    // MARK: The Fragments session drives the bridge (QUESTIONS #16, ratified (c))

    @Test func fragmentsSignInConfiguresTheBridgeAndDisconnectStopsIt() async throws {
        try await withWiredServices { services, _, fragmentsAuth, _, _, bridgeTransport in
            #expect(!services.bridge.isConfigured)

            await fragmentsAuth.adopt(Self.tokens(userID: "frag-user"))
            await settle { services.bridge.isConfigured }
            #expect(services.bridge.isConfigured,
                    "the Fragments session must compose the bridge engine")
            #expect(services.account.fragments?.userID == "frag-user")
            await settle { await bridgeTransport.calls > 0 }
            #expect(await bridgeTransport.calls > 0,
                    "the launch bridge round must ride the INJECTED transport")

            await fragmentsAuth.signOut()
            await settle { !services.bridge.isConfigured }
            #expect(!services.bridge.isConfigured)
            #expect(services.account.fragments == nil)
        }
    }

    @Test func theBridgeStaysDownWhereItIsNotEnabled() async throws {
        // The mobile composition (bridgeEnabled: false — Mac-only scope).
        try await withWiredServices(bridgeEnabled: false) { services, _, fragmentsAuth, _, _, bridgeTransport in
            await fragmentsAuth.adopt(Self.tokens(userID: "frag-user"))
            try await Task.sleep(for: .milliseconds(150))
            #expect(!services.bridge.isConfigured)
            #expect(await bridgeTransport.calls == 0)
        }
    }

    // MARK: The retirement walk (review focus 4 — "no dead credential
    // path"; grep-pinned like the A6 walks)

    @Test func thePasteInIsFullyRetiredInTheSharedSources() throws {
        let sharedDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Shared", isDirectory: true)
        let sources = try FileManager.default
            .contentsOfDirectory(at: sharedDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
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
