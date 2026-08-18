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
//  refresh/adopt/forget/toggle paths run synchronous `SecItem*` custody
//  closures on the MainActor, where a securityd stall beachballs the open
//  sheet instead of making it wait.
//
//  The row also recorded the PIN SHAPE, and this file is it: an injected
//  store that records whether it was called during construction and which
//  thread each call landed on. Every pin below is red on the pre-fix code
//  for the reason its name states (the batch record carries the reverts
//  with checksums).
//
//  What is deliberately NOT pinned here: the engine's
//  `DeviceKeySyncProvider`/`DeviceBridgeKeyProvider` custody reads — they
//  already run off-main from the engine's own rounds, their seam is
//  synchronous by contract, and the batch's fence names them untouchable.
//

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

/// A real in-memory custody store (the CF-12 backing, so gate semantics are
/// the shipped ones) with every call recorded.
private func recordingKeyStore(
    _ log: KeychainCallLog, backing: InMemoryKeyBacking
) -> DeviceKeyStore {
    let inner = DeviceKeyStore.inMemory(backing: backing)
    return DeviceKeyStore(
        load: { log.note("load"); return inner.load() },
        save: { log.note("save"); return inner.save($0) },
        clear: { log.note("clear"); inner.clear() },
        biometryAvailable: { inner.biometryAvailable() },
        isBiometricGateOn: { log.note("isBiometricGateOn"); return inner.isBiometricGateOn() },
        setBiometricGate: { log.note("setBiometricGate"); return inner.setBiometricGate($0, $1) },
        unlockWithBiometrics: { await inner.unlockWithBiometrics() })
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

// MARK: - EncryptionSession: the settings-cadence hops (14b's cold-pass half)

/// The smallest `key_vault` responder that lets the real setup flow write a
/// row and the real refresh read it back — the `EncryptionFlowTests`
/// ScriptedVault's shape, kept here because that one is file-private.
private final class VaultRow: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock(); defer { lock.unlock() }
        func response(_ status: Int, _ body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status,
                httpVersion: "HTTP/1.1", headerFields: nil)!)
        }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
            return response(404)
        }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            guard row == nil else { return response(409, Data(#"{"code":"23505"}"#.utf8)) }
            row = request.httpBody
            return response(201)
        case "PATCH":
            guard row != nil, let body = request.httpBody else {
                return response(200, Data("[]".utf8))
            }
            row = body
            return response(200, Data("[".utf8) + body + Data("]".utf8))
        default:
            return response(405)
        }
    }
}

@MainActor
private func makeSession(store: DeviceKeyStore, vault: VaultRow?) -> EncryptionSession {
    let client = vault.map { vault in
        KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "token-1", userID: "user-e2ee")),
            load: vault.load)
    }
    return EncryptionSession(store: store, client: client, signedIn: { true })
}

private func keyMaterial(_ seed: UInt8) -> DeviceKeyMaterial {
    DeviceKeyMaterial(
        masterKey: Data(repeating: seed, count: 32),
        corpusKey: Data(repeating: seed &+ 1, count: 32),
        corpusKeyID: "corpus-\(seed)",
        journalBridgeKey: Data(repeating: seed &+ 2, count: 32),
        journalBridgeKeyID: "journal-\(seed)")
}

@MainActor
@Suite("Custody hops leave the main thread (13e B-1 — the settings cadence)")
struct EncryptionCustodyThreadTests {
    /// THE TOGGLE path (CF-12's device-local policy). Red pre-fix: both
    /// `SecItem*` calls ran inline on the MainActor. The pin also holds the
    /// ADJACENCY the fix promised — the read and the re-persist are still
    /// consecutive, with no other custody call between them.
    @Test func theBiometricToggleTouchesCustodyOffTheMainThread() async {
        let log = KeychainCallLog()
        let backing = InMemoryKeyBacking(
            initial: keyMaterial(3), biometryAvailable: true)
        let session = makeSession(
            store: recordingKeyStore(log, backing: backing), vault: nil)

        await session.setBiometricRequirement(true)

        #expect(session.lastError == nil)
        #expect(session.biometricRequired, "the policy landed, exactly as before")
        #expect(log.names == ["load", "setBiometricGate"],
                "the read and the re-persist stay adjacent — one hop")
        #expect(log.anyOnMainThread == false)
    }

    /// THE FORGET path (CF-11). Red pre-fix: `clear()` ran inline on the
    /// MainActor. Its outcome is unchanged — custody gone, gate off.
    @Test func theForgetDoorClearsCustodyOffTheMainThread() async {
        let log = KeychainCallLog()
        let backing = InMemoryKeyBacking(initial: keyMaterial(4))
        let store = recordingKeyStore(log, backing: backing)
        let session = makeSession(store: store, vault: nil)

        await session.forgetDeviceKeys()

        #expect(log.names.contains("clear"))
        #expect(log.anyOnMainThread == false)
        #expect(!session.biometricRequired)
        #expect(throws: SyncKeyProviderError.notEnrolled) {
            try DeviceKeySyncProvider(store: store).currentKeys()
        }
    }

    /// THE ADOPT path (every enrollment flow's landing). Red pre-fix: the
    /// custody `save()` ran inline on the MainActor at enroll cadence.
    @Test func enrollingThisDeviceSavesCustodyOffTheMainThread() async {
        let log = KeychainCallLog()
        let backing = InMemoryKeyBacking()
        let vault = VaultRow()  // held: the client keeps it weakly
        let session = makeSession(
            store: recordingKeyStore(log, backing: backing), vault: vault)

        await session.setUp(passphrase: "orchard-lantern-13")

        #expect(session.lastError == nil)
        #expect(session.state == .enrolled(hasRecoveryWrap: false))
        #expect(log.names == ["save"], "the flow's one custody write")
        #expect(log.anyOnMainThread == false)
    }

    /// THE REFRESH path (sheet-open cadence — the gate probe AND the custody
    /// read). Red pre-fix: both ran inline on the MainActor, which is the
    /// beachball the 14b cold pass named.
    @Test func refreshReadsTheGateAndCustodyOffTheMainThread() async {
        let log = KeychainCallLog()
        let backing = InMemoryKeyBacking()
        let vault = VaultRow()
        let session = makeSession(
            store: recordingKeyStore(log, backing: backing), vault: vault)
        await session.setUp(passphrase: "orchard-lantern-13")
        log.reset()

        await session.refresh()

        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "the projection is byte-unchanged — only the thread moved")
        #expect(log.names == ["isBiometricGateOn", "load"],
                "the same two reads, in the same order")
        #expect(log.anyOnMainThread == false)
    }
}
