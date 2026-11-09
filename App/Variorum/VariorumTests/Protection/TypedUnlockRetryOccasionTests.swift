//
//  TypedUnlockRetryOccasionTests.swift
//  VariorumTests — VX-544 (the VX-849 run, batch 2 — D-544 (3a); her R-849-1; the record
//  `notes/plans/fixes/vx-849-typed-over-rescue.md`, BATCH 2 RECORD). THE OCCASION: the composition (both platforms — P-849-3) runs the typed
//  unlock's retry FIRST inside the one `beforeRound` closure (batch 1's hook — no second hook), gated: nothing at all
//  without a pending load (a memory read is the whole cost), then ONE `currentKeys()` try off the main actor — keys there
//  end the pending, none ⇒ the retry. A sign-out lets the pending go (her R-849-1: "dropped at lock/sign-out"). Over the
//  services with SCRIPTED roads and a counting key provider: no protection road, no keychain, no network. (The order against
//  her pending typing is `SyncBeforeRoundTests`'; the road end to end — the bootstrap's own roads — is
//  `OfflineTypedUnlockRetryRoadTests`'.)
//
//  RED ON OLD: every pin names the new seam (`typedUnlockSyncKeys`, `TypedUnlockSyncKeysRoads`) — COMPILE-red on the pre-fix
//  tree; their behavioral red is the record's named reverts (the occasion's retry call deleted; the gate's pending check
//  deleted; the keys-present clear deleted; the sign-out's let-go deleted).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A key provider that counts its reads and answers keys or refuses, as set.
private final class CountingKeyProvider: SyncKeyProviding, @unchecked Sendable {
    private let lock = NSLock()
    private var held: Bool
    private var count = 0

    init(hasKeys: Bool) { held = hasKeys }

    var reads: Int { lock.withLock { count } }

    func currentKeys() throws -> SyncEncryptionKeys {
        let hasKeys = lock.withLock { () -> Bool in
            count += 1
            return held
        }
        guard hasKeys else { throw SyncKeyProviderError.notEnrolled }
        return try AppTestKeyProvider().currentKeys()
    }

    func deviceIdentity() throws -> String { "vx544-device" }
}

/// The roads, scripted: what the occasion asked of them, in order.
@MainActor
private final class ScriptedRoads {
    var pending: Bool
    private(set) var log: [String] = []

    init(pending: Bool) { self.pending = pending }

    var roads: TypedUnlockSyncKeysRoads {
        TypedUnlockSyncKeysRoads(
            isPending: { [unowned self] in
                log.append("isPending")
                return pending
            },
            retry: { [unowned self] in
                log.append("retry")
                await Task.yield()
            },
            clear: { [unowned self] in
                log.append("clear")
                pending = false
            },
            letGo: { [unowned self] in
                log.append("letGo")
                pending = false
            })
    }
}

@Suite("VX-544 — the round occasion retries the typed unlock's pending load, gated (scripted roads)", .serialized)
@MainActor
struct TypedUnlockRetryOccasionTests {
    /// The world every pin runs in — `SyncBeforeRoundTests.withWorld`'s override set (the owner identity left at its
    /// signed-out default, so the sign-in world is the one these pins were written against). The services are BUILT inside
    /// the scope: `AppSession.init` snapshots `\.date` at construction, and in the real Mac test bundle an unoverridden
    /// read records an issue (the batch-2 window's leg A finding — the record's BATCH 2 AMENDMENT, WINDOW FIX).
    private static func withWorld(_ body: @MainActor (AppDatabase) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 544))
        } operation: { @MainActor in
            try await body(db)
            // A retired chain's cancelled tasks hold `db` in their task locals (`FirstRoundRoadTests.withWorld`'s reason).
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    private static func services(
        _ provider: CountingKeyProvider, in db: AppDatabase, variant: AppDatabase.StoreVariant = .dev,
        auth: AuthSession? = nil
    ) -> AppServices {
        let auth = auth ?? Self.auth()
        return AppServices(
            session: AppSession(database: db), storeVariant: variant, backupEnabled: false,
            auth: auth, makeSyncTransport: { _ in FirstRoundServer() }, makeSyncKeyProvider: { provider },
            legacyCleanup: {})
    }

    private static func auth() -> AuthSession {
        AuthSession(
            configuration: AuthConfiguration(projectURL: URL(string: "https://vx544.invalid")!, apiKey: "k"),
            store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
    }

    /// **A PENDING LOAD AND NO KEYS ⇒ THE RETRY**, inside the one occasion: the pending checked, one provider read, the retry
    /// run (and awaited) — nothing cleared.
    @Test func whileThereAreNoKeysTheOccasionRetriesThePendingLoad() async throws {
        try await Self.withWorld { db in
            let provider = CountingKeyProvider(hasKeys: false)
            let services = Self.services(provider, in: db)
            let scripted = ScriptedRoads(pending: true)
            services.typedUnlockSyncKeys = scripted.roads
            let occasion = try #require(services.sync.beforeRound, "the composition wires the occasion")
            await occasion()
            #expect(scripted.log == ["isPending", "retry"], "\(scripted.log)")
            #expect(provider.reads == 1, "ONE currentKeys() try")
            services.stop()
        }
    }

    /// **NOTHING PENDING ⇒ NOTHING AT ALL** — the cost of every other round (an unlocked session, Standard, no account) is
    /// one memory read: the provider is never read (it may touch the keychain), nothing retried.
    @Test func withNothingPendingTheOccasionReadsNoKeysAndRetriesNothing() async throws {
        try await Self.withWorld { db in
            let provider = CountingKeyProvider(hasKeys: false)
            let services = Self.services(provider, in: db)
            let scripted = ScriptedRoads(pending: false)
            services.typedUnlockSyncKeys = scripted.roads
            await services.retryTypedUnlockSyncKeysWhileLocked()
            let occasion = try #require(services.sync.beforeRound)
            await occasion()
            #expect(scripted.log == ["isPending", "isPending"], "\(scripted.log)")
            #expect(provider.reads == 0, "the provider is never read without a pending load")
        }
    }

    /// **THE KEYS ALREADY THERE** (an act or an unlock loaded them since the typed unlock): the pending is done — cleared —
    /// and nothing is retried.
    @Test func withTheKeysThereTheOccasionEndsThePendingAndRetriesNothing() async throws {
        try await Self.withWorld { db in
            let provider = CountingKeyProvider(hasKeys: true)
            let services = Self.services(provider, in: db)
            let scripted = ScriptedRoads(pending: true)
            services.typedUnlockSyncKeys = scripted.roads
            await services.retryTypedUnlockSyncKeysWhileLocked()
            #expect(scripted.log == ["isPending", "clear"], "\(scripted.log)")
            #expect(provider.reads == 1)
            await services.retryTypedUnlockSyncKeysWhileLocked()
            #expect(scripted.log == ["isPending", "clear", "isPending"], "cleared: the next occasion reads nothing")
            #expect(provider.reads == 1)
        }
    }

    /// GUARD — no roads (a test's composition, an unattached services): the occasion is inert for the load.
    @Test func noRoadsIsInert() async throws {
        try await Self.withWorld { db in
            let provider = CountingKeyProvider(hasKeys: false)
            let services = Self.services(provider, in: db)
            #expect(services.typedUnlockSyncKeys == nil)
            await services.retryTypedUnlockSyncKeysWhileLocked()
            #expect(provider.reads == 0)
        }
    }

    /// **A SIGN-OUT LETS THE PENDING GO** (her R-849-1: "dropped at lock/sign-out"): the services' sign-in observation — the
    /// one every sign-out road reaches (the Account sheet, sign out everywhere, the account's deletion) — lets go of it.
    @Test func aSignOutLetsGoOfThePendingLoad() async throws {
        try await Self.withWorld { db in
            let provider = CountingKeyProvider(hasKeys: false)
            let auth = Self.auth()
            await auth.adopt(AuthTokens(
                accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600), userID: "acct-a",
                email: nil))
            let services = Self.services(provider, in: db, auth: auth)
            let scripted = ScriptedRoads(pending: true)
            services.typedUnlockSyncKeys = scripted.roads
            await services.start()
            #expect(!scripted.log.contains("letGo"), "signed in: nothing let go")
            await services.signOutVariorum()
            await FirstRoundWorld.settle(seconds: 5) { scripted.log.contains("letGo") }
            #expect(scripted.log.contains("letGo"), "\(scripted.log)")
            #expect(!scripted.pending)
            services.stop()
        }
    }
}
