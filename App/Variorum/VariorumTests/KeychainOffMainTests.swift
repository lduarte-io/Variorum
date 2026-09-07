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
        deviceID: { log.note("deviceID"); return inner.deviceID() })
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
        // pre-13x: the ONE vault write road is the RPC; PATCH is refused;
        // a create carries its proof hash (VaultRPCEmulation — the
        // core suites' linked ScriptedVaultServer's minimal twin).
        if let served = VaultRPCEmulation.serveUpdate(request, row: &row) {
            return response(served.status, served.body)
        }
        guard request.url?.path.hasSuffix("/rest/v1/key_vault") == true else {
            return response(404)
        }
        switch request.httpMethod {
        case "GET":
            guard let row else { return response(200, Data("[]".utf8)) }
            return response(200, Data("[".utf8) + row + Data("]".utf8))
        case "POST":
            if let refusal = VaultRPCEmulation.insertRefusal(request.httpBody) {
                return response(refusal.status, refusal.body)
            }
            guard row == nil else { return response(409, Data(#"{"code":"23505"}"#.utf8)) }
            row = request.httpBody
            return response(201)
        case "PATCH":
            return response(VaultRPCEmulation.patchRefused.status, VaultRPCEmulation.patchRefused.body)
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
                apiKey: "publishable-test-key", deviceName: "test device"),
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
        #expect(session.state == .enrolled(hasRecoveryWrap: true))  // pre-13x 3a: born with its wrap
        // pre-13x 1a: the CF-12 gate consult is gone with the gate — the
        // flow's ONE custody write, off-main.
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

        #expect(session.state == .enrolled(hasRecoveryWrap: true),
                "the projection is byte-unchanged — only the thread moved")
        #expect(log.names == ["load"], "the one custody read (pre-13x 1a: the gate probe is gone)")
        #expect(log.anyOnMainThread == false)
    }
}

// MARK: - ProtectionController: the custody move and the Apple arm (13p ladder R2-m2 / 17h R3-6 → pre-13x 2a)

/// A real in-memory store-key guard with every SecItem-class call recorded
/// (the row's named pin shape, applied to the 13p guard seam).
private func recordingStoreKeyGuard(
    _ log: KeychainCallLog, backing: InMemoryStoreKeyGuardBacking
) -> StoreKeyGuard {
    let inner = StoreKeyGuard.inMemory(backing: backing)
    return StoreKeyGuard(
        loadAuto: { log.note("loadAuto"); return inner.loadAuto() },
        saveAuto: { log.note("saveAuto"); return inner.saveAuto($0) },
        deleteAuto: { log.note("deleteAuto"); return inner.deleteAuto() },
        gatedItemExists: { log.note("gatedItemExists"); return inner.gatedItemExists() },
        saveGated: { log.note("saveGated"); return inner.saveGated($0) },
        deleteGated: { log.note("deleteGated"); return inner.deleteGated() },
        unlockGated: { await inner.unlockGated() },
        biometryAvailable: { inner.biometryAvailable() },
        loadLegacyEscrow: { log.note("loadLegacyEscrow"); return inner.loadLegacyEscrow($0) },
        removeLegacyEscrow: { log.note("removeLegacyEscrow"); return inner.removeLegacyEscrow($0) },
        confirmPresence: { await inner.confirmPresence($0) })
}

/// The Apple-key leaves, recorded the same way (pre-13x 2a).
private func recordingAppleKeys(
    _ log: KeychainCallLog, backing: InMemoryAppleKeyBacking
) -> AppleKeyLeaves {
    let inner = AppleKeyLeaves.inMemory(backing: backing)
    return AppleKeyLeaves(
        read: { log.note("appleRead"); return inner.read() },
        readOrMint: { log.note("appleReadOrMint"); return inner.readOrMint() })
}

/// The sync record's leaves, recorded (the custody move's twin).
private func recordingSyncLeaves(_ log: KeychainCallLog) -> E2EECustodyLeaves {
    let plain = LockIsolated<SyncCustodyRecord?>(nil)
    let gated = LockIsolated<SyncCustodyRecord?>(nil)
    return E2EECustodyLeaves(
        saveGated: { record in log.note("syncSaveGated"); gated.setValue(record); return true },
        savePlain: { record in log.note("syncSavePlain"); plain.setValue(record); return true },
        loadPlain: { log.note("syncLoadPlain"); return plain.value },
        gatedExists: { log.note("syncGatedExists"); return gated.value != nil },
        deletePlain: { log.note("syncDeletePlain"); plain.setValue(nil); return true },
        deleteGated: { log.note("syncDeleteGated"); gated.setValue(nil); return true })
}

private func fastKDF() -> PassphraseKDF.Descriptor {
    PassphraseKDF.Descriptor(
        algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
        memoryKiB: 256, iterations: 1, parallelism: 1,
        salt: PassphraseKDF.randomSalt(), outputBytes: 32)
}

/// **17h (13p-fix ladder R3-6) — the custody move makes ZERO synchronous
/// SecItem calls on the main thread.** The transition ran its whole custody
/// choreography INLINE on the MainActor, the 13e B-1 class one
/// settings-cadence door over. The work rides ONE serial off-main hop; the
/// custody semantics are byte-identical (same reads, same writes, same
/// order — the `CustodyReleaseTests` and `Phase13pControllerTests`
/// transition pins ride as that half's proof). pre-13x 2a: the move is
/// `moveCustody(to:)` / `setAlwaysAsk`, and it moves the SYNC RECORD in the
/// same hop — its leaves are recorded here too, and they arrive off-main.
///
/// RED ON OLD (behavioral revert executed at 17h): with the transition
/// inlined back onto the MainActor every recorded call lands main-thread
/// and `anyOnMainThread` goes red on all three arms.
@MainActor
@Suite("The custody move's work hops off the main thread (17h R3-6)")
struct ProtectionSetModeOffMainTests {
    @Test func everyTransitionArmsGuardSeamWorkArrivesOffMain() async throws {
        let log = KeychainCallLog()
        let key = StoreKey.mint()
        let apple = AppleKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            auto: key, biometryAvailable: true, biometricSucceeds: true)
        let recording = recordingStoreKeyGuard(log, backing: backing)
        let dialsBox = ScriptedDialsBox(ProtectionDials())
        // A STANDARD key file (the Apple copy under A) — the move's
        // authorization reads it; the posture stays Standard throughout,
        // the moves being the primitive 2b's switches call.
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
        let envelopeBox = ScriptedEnvelopeBox(envelope)
        let stamps = ScriptedStampsBox()
        let gate = StoreLaunchGate(
            dials: { _, _ in dialsBox.value },
            saveDials: { new, _, _ in dialsBox.value = new },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in recording },
            appleKeyFor: { _ in AppleKeyLeaves.inMemory(backing: InMemoryAppleKeyBacking(key: apple)) },
            loadEnvelope: { _ in envelopeBox.value },
            saveEnvelope: { new, _ in envelopeBox.value = new },
            setAsideEnvelope: { _ in envelopeBox.value = nil },
            stamp: { leaf, _ in stamps.value[leaf] },
            setStamp: { date, leaf, _ in stamps.value[leaf] = date })
        let syncLog = KeychainCallLog()
        let controller = ProtectionController(configuration: .init(
            scope: "set-mode-off-main", storeURL: nil, gate: gate,
            isRealVariant: true,
            makeKDF: { fastKDF() },
            storeID: { [storeID = envelope.storeID] in storeID },
            syncCustodyLeaves: { _ in recordingSyncLeaves(syncLog) },
            syncCustodySession: SyncCustodySession()))
        #expect(await controller.setPassphrase("sesame") == nil)
        log.reset()  // the setup's own seam reads are not this pin's subject

        // INTO BIOMETRIC: the key read, the gated landing, its read-back
        // verify, the silent item's release — all off-main; the sync twin's
        // leaves ride the same hop.
        #expect(await controller.moveCustody(to: .biometric) == .changed)
        #expect(log.names == ["loadAuto", "saveGated", "gatedItemExists", "deleteAuto"],
                "the same reads and writes, in the same order — only the thread moves")
        #expect(log.anyOnMainThread == false,
                "ZERO synchronous SecItem calls on the main thread: \(log.calls)")
        #expect(syncLog.anyOnMainThread == false, "the sync twin's leaves hop too: \(syncLog.calls)")

        // INTO PASSPHRASE (the resident key stands in — no key read): both
        // verified releases (17h R3-5), off-main.
        log.reset()
        #expect(await controller.moveCustody(to: .passphrase) == .changed)
        #expect(log.names == ["deleteGated", "deleteAuto"])
        #expect(log.anyOnMainThread == false, "\(log.calls)")

        // BACK TO AUTO: the landing, its identity verify, the gate's
        // release — off-main.
        log.reset()
        #expect(await controller.moveCustody(to: .auto) == .changed)
        #expect(log.names == ["saveAuto", "loadAuto", "deleteGated"])
        #expect(log.anyOnMainThread == false, "\(log.calls)")
    }
}

/// **Ladder R2-m2 — the launch/unlock road makes ZERO synchronous SecItem
/// calls on the main thread.** `ProtectionController.reconcile()` runs at
/// exactly that cadence, and its escrow arm used to make up to three
/// synchronous guard-seam round-trips INLINE on the MainActor. pre-13x 2a:
/// the arm is the APPLE ARM — the silent item's read, the A read (or mint),
/// the key file's Apple copy landed and read back — and it runs in ONE
/// detached hop, exactly as the escrow arm learned to.
///
/// RED ON OLD (behavioral revert executed at 13p): with the arm inlined
/// back onto the MainActor every recorded call lands main-thread and
/// `anyOnMainThread` goes red.
@MainActor
@Suite("The reconcile's Apple arm hops off the main thread (13p R2-m2)")
struct ProtectionReconcileOffMainTests {
    @Test func theAppleArmsGuardSeamWorkArrivesOffMainInBothPostures() async throws {
        let log = KeychainCallLog()
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(auto: key)
        let recording = recordingStoreKeyGuard(log, backing: backing)
        let appleBacking = InMemoryAppleKeyBacking()
        let dialsBox = ScriptedDialsBox(ProtectionDials())
        let envelopeBox = ScriptedEnvelopeBox(
            StoreKeyEnvelope(keyFingerprint: StoreKeyEnvelope.fingerprint(of: key)))
        let stamps = ScriptedStampsBox()
        let gate = StoreLaunchGate(
            dials: { _, _ in dialsBox.value },
            saveDials: { new, _, _ in dialsBox.value = new },
            legacyMode: { _, _ in nil },
            retireLegacyDials: { _, _ in },
            guardFor: { _ in recording },
            appleKeyFor: { _ in recordingAppleKeys(log, backing: appleBacking) },
            loadEnvelope: { _ in envelopeBox.value },
            saveEnvelope: { new, _ in envelopeBox.value = new },
            setAsideEnvelope: { _ in envelopeBox.value = nil },
            stamp: { leaf, _ in stamps.value[leaf] },
            setStamp: { date, leaf, _ in stamps.value[leaf] = date })
        let controller = ProtectionController(configuration: .init(
            scope: "reconcile-off-main", storeURL: nil, gate: gate,
            isRealVariant: true))
        log.reset()  // construction reads no guard seam; belt anyway

        // STANDARD (a key file with no secrets): the silent item's read,
        // then A read-or-minted — all off-main, and the Apple copy really
        // lands and VERIFIES (the thread moved, never the meaning).
        await controller.reconcile()
        // pre-13x ladder round 2, F3 (MINOR-N1): the arm READS first and
        // mints only after a nil read (the heal keys on a read, never a
        // mint) — one more off-main call in the sequence; the mechanism
        // this pin exists for is the next line: none of them on main.
        #expect(log.names == ["loadAuto", "appleRead", "appleReadOrMint"],
                "the key read, then A read, then read-or-minted — then the key file's copy, verified by read-back")
        #expect(log.anyOnMainThread == false,
                "ZERO synchronous SecItem calls on the main thread: \(log.calls)")
        let minted = try #require(appleBacking.key, "A was minted for the first Standard library")
        #expect(try envelopeBox.value?.unwrapKey(apple: minted.symmetricKey) == key,
                "the Apple copy landed")
        #expect(controller.appleKeyVerified == true, "and the read-back projected the verified fact")

        // CASTLE: no A touch at all (§14.5), the leg reads false.
        var castle = try #require(envelopeBox.value)
        try castle.removeAppleWrappedCopy()
        try castle.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        envelopeBox.value = castle
        log.reset()
        await controller.reconcile()
        #expect(controller.posture == .castle)
        #expect(!log.names.contains("appleReadOrMint") && !log.names.contains("appleRead"),
                "Castle never touches the iCloud key: \(log.names)")
        #expect(log.anyOnMainThread == false, "\(log.calls)")
        #expect(controller.appleKeyVerified == false)
    }
}
