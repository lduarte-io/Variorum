//
//  KeychainOffMainTests.swift
//  VariorumTests
//
//  Phase 13e, batch 9 (ladder round B, B-1) — the pins for the fix the
//  KnownIssues "Windowless launch" row PROMISED and this batch finally
//  built: no synchronous Keychain hop ever runs on the main thread.
//
//  The row's captured mechanism (14b gate morning, `sample <pid> 5` on a
//  live windowless launch): the MAIN thread sat inside `AppServices.init`
//  → `AuthSession.init` → `KeychainAuthStorage.load` → `SecItemCopyMatching`
//  → `ClientSession::decrypt` → `mach_msg`, waiting on securityd while no
//  window existed yet; the same wait explains the "test runner timed out
//  while preparing" cluster (the test HOST hangs at that exact point). The
//  14b cold pass added the SETTINGS-CADENCE half: `EncryptionSession`'s
//  refresh/adopt/forget/toggle paths ran synchronous `SecItem*` custody
//  closures on the MainActor (that half left with today's custody at
//  VX-329 U1, its pins with it).
//
//  The row also recorded the PIN SHAPE, and this file is it: an injected
//  store that records whether it was called during construction and which
//  thread each call landed on. Every pin below is red on the pre-fix code
//  for the reason its name states (the batch record carries the reverts
//  with checksums).
//
//  What is deliberately NOT pinned here: the engine's
//  `DeviceKeySyncProvider` custody reads (once `DeviceBridgeKeyProvider`'s
//  too, until the bridge's 2026-09-04 retirement) — they
//  already run off-main from the engine's own rounds, their seam is
//  synchronous by contract, and the batch's fence names them untouchable.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The recorders (the row's named pin shape)

/// Which custody/session-store closures ran, and on which thread.
private final class KeychainCallLog: @unchecked Sendable {
    struct Call: Sendable {
        var name: String
        var onMainThread: Bool
    }

    private let lock = NSLock()
    private var recorded: [Call] = []

    var calls: [Call] {
        lock.lock(); defer { lock.unlock() }
        return recorded
    }

    var names: [String] { calls.map(\.name) }

    /// The pins' central claim, in one place: nothing the app asked the
    /// Keychain for landed on the main thread.
    var anyOnMainThread: Bool { calls.contains { $0.onMainThread } }

    func reset() {
        lock.lock(); defer { lock.unlock() }
        recorded = []
    }

    func note(_ name: String) {
        lock.lock(); defer { lock.unlock() }
        recorded.append(Call(name: name, onMainThread: Thread.isMainThread))
    }
}

/// A real in-memory session store with every call recorded.
private func recordingAuthStore(
    _ log: KeychainCallLog, initial: AuthTokens? = nil
) -> AuthTokensStore {
    let inner = AuthTokensStore.inMemory(initial: initial)
    return AuthTokensStore(
        load: { log.note("load"); return inner.load() },
        save: { log.note("save"); inner.save($0) },
        clear: { log.note("clear"); inner.clear() })
}

private func authTokens(
    *[removed for publication]*
    access: String = "access-1", refresh: String = "refresh-1"
) -> AuthTokens {
    AuthTokens(
        accessToken: access, refreshToken: refresh,
        expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
        userID: userID, email: "author@example.com")
}

private let noNetwork: @Sendable (URLRequest) async throws -> (Data, URLResponse) = { request in
    (Data(), HTTPURLResponse(
        url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil)!)
}

private let authConfiguration = AuthConfiguration(
    projectURL: URL(string: "https://variorum-project.supabase.co")!,
    apiKey: "publishable-key")

// MARK: - AuthSession: the launch-time hop (the row's captured stack)

@MainActor
@Suite("The persisted session loads lazily, off the main thread (13e B-1)")
struct AuthSessionLazyLoadTests {
    /// THE RED-ON-OLD PIN for the captured mechanism: the composition root
    /// (`AppServices.init`, a `@MainActor` type) constructs two AuthSessions,
    /// and pre-fix each one read the Keychain RIGHT THERE — the main thread
    /// inside `SecItemCopyMatching` before any window existed.
    @Test func constructingTheSessionTouchesNoKeychainAtAll() {
        let log = KeychainCallLog()
        _ = AuthSession(
            configuration: authConfiguration,
            store: recordingAuthStore(log, initial: authTokens()),
            http: noNetwork)
        #expect(log.calls.isEmpty,
                "construction must ask the Keychain for nothing — the row's captured stack")
    }

    /// THE RED-ON-OLD PIN for the fix's other half: the read still happens,
    /// once, at first use — and it happens on the ACTOR's executor, which is
    /// never the main thread however long securityd takes.
    @Test func theFirstTokenReadHappensOffTheMainThread() async {
        let log = KeychainCallLog()
        let session = AuthSession(
            configuration: authConfiguration,
            store: recordingAuthStore(log, initial: authTokens()),
            http: noNetwork)

        #expect(await session.isSignedIn, "the persisted session is still adopted")

        #expect(log.names == ["load"], "exactly one read, at first use")
        #expect(log.anyOnMainThread == false,
                "the Keychain read must not land on the main thread")
    }

    /// The one read serves every later question (a lazy load is not a
    /// per-read load). Passes on BOTH sides deliberately — the attribution
    /// half: the eager load was also one read.
    @Test func everyLaterReadRidesTheOneLoad() async {
        let log = KeychainCallLog()
        let session = AuthSession(
            configuration: authConfiguration,
            store: recordingAuthStore(log, initial: authTokens()),
            http: noNetwork)

        _ = await session.isSignedIn
        _ = await session.currentUserID
        _ = await session.currentEmail
        _ = try? await session.currentSession()

        #expect(log.names == ["load"])
    }

    /// THE LAZINESS BOOKKEEPING, pinned: an adopt SUPERSEDES the persisted
    /// item, so the lazy load never runs afterwards and can never overwrite
    /// the live session with the older one. (Red on the pre-fix code for the
    /// count — construction had already read.)
    @Test func adoptingSupersedesTheStoreAndTheLazyLoadNeverRuns() async {
        let log = KeychainCallLog()
        let session = AuthSession(
            configuration: authConfiguration,
            store: recordingAuthStore(log, initial: authTokens(userID: "the-old-user")),
            http: noNetwork)

        await session.adopt(authTokens(userID: "the-new-user"))
        #expect(await session.currentUserID == "the-new-user")
        _ = await session.isSignedIn

        #expect(log.names == ["save"],
                "the adopt wrote; nothing ever read the superseded item")
        #expect(log.anyOnMainThread == false)
    }

    /// The laziness must not cost the sign-out its bearer: a sign-out before
    /// anything read the store still logs the PERSISTED session out
    /// server-side. Passes on both sides deliberately (the eager load
    /// guaranteed this by accident; now a named `ensureLoadedFromStore` call
    /// guarantees it on purpose) — this is the regression guard.
    @Test func aSignOutBeforeAnyReadStillLogsThePersistedSessionOut() async {
        let log = KeychainCallLog()
        let recorder = RequestRecorder()
        let session = AuthSession(
            configuration: authConfiguration,
            store: recordingAuthStore(log, initial: authTokens(access: "the-persisted-access")),
            http: recorder.loader())

        await session.signOut()

        #expect(recorder.requests.first?.url?.path == "/auth/v1/logout")
        #expect(recorder.requests.first?.value(forHTTPHeaderField: "Authorization")
                == "Bearer the-persisted-access",
                "the bearer comes from the persisted session the lazy load fetched")
        #expect(log.names == ["load", "clear"])
        #expect(await session.isSignedIn == false)
    }
}

/// Records the requests an auth flow makes; answers 204 to everything.
private final class RequestRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var recorded: [URLRequest] = []

    var requests: [URLRequest] {
        lock.lock(); defer { lock.unlock() }
        return recorded
    }

    func loader() -> @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [self] request in self.serve(request) }
    }

    /// Synchronous on purpose: `NSLock` is unavailable from async contexts
    /// (the `ScriptedEndpoint` pattern in `AuthSessionTests`).
    private func serve(_ request: URLRequest) -> (Data, URLResponse) {
        lock.lock(); defer { lock.unlock() }
        recorded.append(request)
        return (Data(), HTTPURLResponse(
            url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil)!)
    }
}

// (VX-329 U1: the settings-cadence, custody-move and reconcile hop suites pinned today's custody — `EncryptionSession`,
// `DeviceKeyStore`, today's controller's custody moves and its Apple arm — and were deleted with it; the protection
// road's keychain work runs off the main actor through its own leaves.)
