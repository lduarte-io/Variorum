//
//  EncryptionFlowTests.swift
//  VariorumTests
//
//  Phase 14b, batch 3 (L9) — the app-layer E2EE seam: the EncryptionSession
//  state machine over an in-memory key store + a raw-JSON scripted vault
//  (public API only — no network, no core internals, never the real
//  Keychain), the refusal wording, and the sync status face's locked-state
//  classification with its keys-first no-network pin.
//

import CryptoKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// A raw-JSON `key_vault` PostgREST responder: stores the POSTed row bytes
/// verbatim and serves them back — the client's own encoder/decoder is the
/// only wire-shape authority exercised.
private final class ScriptedVault: @unchecked Sendable {
    private let lock = NSLock()
    private var row: Data?

    var hasRow: Bool {
        lock.lock()
        defer { lock.unlock() }
        return row != nil
    }

    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock()
        defer { lock.unlock() }
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
            guard row == nil else {
                return response(409, Data(#"{"code":"23505"}"#.utf8))
            }
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
private func makeEncryptionSession(
    store: DeviceKeyStore, vault: ScriptedVault
) -> EncryptionSession {
    let client = KeyVaultClient(
        configuration: KeyVaultClient.Configuration(
            projectURL: URL(string: "https://vault.test.invalid")!,
            apiKey: "publishable-test-key"),
        sessionProvider: StaticSessionProvider(
            session: UserSession(accessToken: "token-1", userID: "user-e2ee")),
        load: vault.load)
    return EncryptionSession(store: store, client: client, signedIn: { true })
}

@MainActor
@Suite("E2EE flows — the app seam (Phase 14b, L9)")
struct EncryptionFlowTests {
    @Test func setUpEnrollsThisDeviceAndFiresTheHealingHook() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)
        var healed = 0
        session.onKeysChanged = { healed += 1 }

        await session.setUp(passphrase: "orchard-lantern-13")

        #expect(session.lastError == nil)
        #expect(session.state == .enrolled(hasRecoveryWrap: false),
                "Round 5: a fresh vault is passphrase-wrap-only — the phrase surface comes next")
        #expect(store.load() != nil, "custody landed in the (in-memory) key store")
        #expect(vault.hasRow, "the vault row was created")
        #expect(healed == 1, "landing keys triggers the sync heal exactly once")
        #expect(session.lastKDFSeconds.map { $0 > 0 } == true,
                "L12: the flow measures and surfaces its KDF derivation duration")
    }

    @Test func aWrongPassphraseSpeaksAndLandsNothing() async throws {
        let firstStore = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let first = makeEncryptionSession(store: firstStore, vault: vault)
        await first.setUp(passphrase: "orchard-lantern-13")
        #expect(first.lastError == nil)

        // A second device, same vault, wrong passphrase.
        let secondStore = DeviceKeyStore.inMemory()
        let second = makeEncryptionSession(store: secondStore, vault: vault)
        var healed = 0
        second.onKeysChanged = { healed += 1 }
        await second.enroll(passphrase: "orchard-lantern-14")

        #expect(second.lastError == "Wrong encryption passphrase.")
        #expect(secondStore.load() == nil, "a refused enrollment lands no keys")
        #expect(healed == 0)

        // The right passphrase enrolls the second device.
        await second.enroll(passphrase: "orchard-lantern-13")
        #expect(second.lastError == nil)
        #expect(secondStore.load() == firstStore.load(),
                "both devices hold the same unwrapped material")
    }

    @Test func refreshProjectsTheVaultAndCustodyStates() async throws {
        let store = DeviceKeyStore.inMemory()
        let vault = ScriptedVault()
        let session = makeEncryptionSession(store: store, vault: vault)

        await session.refresh()
        #expect(session.state == .noVault)

        await session.setUp(passphrase: "orchard-lantern-13")
        await session.refresh()
        #expect(session.state == .enrolled(hasRecoveryWrap: false))

        // A fresh device against the same vault: not enrolled.
        let other = makeEncryptionSession(store: .inMemory(), vault: vault)
        await other.refresh()
        #expect(other.state == .notEnrolled(hasRecoveryWrap: false))
    }

    @Test func signedOutStateBlocksNothingButNamesTheOrder() async throws {
        let vault = ScriptedVault()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "k"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: "t", userID: "u")),
            load: vault.load)
        let session = EncryptionSession(
            store: .inMemory(), client: client, signedIn: { false })
        await session.refresh()
        #expect(session.state == .signedOut,
                "the vault lives on the account — flows start with sign-in")
    }
}

@MainActor
@Suite("The locked sync face (Phase 14b, L9)")
struct SyncLockedFaceTests {
    private actor CountingTransport: SyncTransport {
        private(set) var calls = 0
        func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome] {
            calls += 1
            return batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow] {
            calls += 1
            return []
        }
        func schemaVersion() async throws -> Int {
            calls += 1
            return SyncSchema.lockstepVersion
        }
    }

    private struct LockedProvider: SyncKeyProviding {
        func currentKeys() throws -> SyncEncryptionKeys {
            throw SyncKeyProviderError.notEnrolled
        }
    }

    /// The classifier is EXACT: true for the engine's keys-refusal as the
    /// scheduler surfaces it, false for everything else (a substring match
    /// would swallow unrelated errors into the calm locked face).
    @Test func theClassifierMatchesExactlyTheEngineRefusal() {
        #expect(EncryptionSession.isKeysLockedError(
            String(describing: SyncError.encryptionKeysUnavailable)))
        #expect(!EncryptionSession.isKeysLockedError("Sync error: something else"))
        #expect(!EncryptionSession.isKeysLockedError(
            String(describing: SyncError.schemaLockstepMismatch(client: 5, server: 4))))
    }

    /// THE WIRING PIN (fails without L9's keyProvider plumb-through): a
    /// locked provider composed at the SESSION seam refuses the round with
    /// the classified status and ZERO transport contact — outbox posture
    /// intact, the row's locked face reachable.
    @Test func aLockedProviderRefusesVisiblyBeforeAnyTransportContact() async throws {
        let db = try AppDatabase.inMemory()
        let session = SyncSession(database: db, allowsSync: true)
        let transport = CountingTransport()
        await session.configure(transport: transport, keyProvider: LockedProvider())
        session.triggerSync()
        // Settle until the round reports.
        for _ in 0..<400 {
            if session.status.roundsCompleted > 0 { break }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
        #expect(session.status.roundsCompleted > 0)
        #expect(session.status.lastError.map(EncryptionSession.isKeysLockedError) == true,
                "the keys-refusal surfaces classified — the locked face's trigger")
        #expect(await transport.calls == 0,
                "keys are checked FIRST: a locked device refuses with zero network contact")
        session.stop()
    }
}
