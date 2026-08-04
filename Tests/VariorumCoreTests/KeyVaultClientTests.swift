import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 3 (L8) — the `key_vault` PostgREST client against the
/// scripted server: round-trips, the refusal arms, single-flight, and the
/// 9c auth posture (one 401 refresh-and-retry).
@Suite("Key vault client (Phase 14b, L8)")
struct KeyVaultClientTests {

    private func sampleFormat(withRecovery: Bool = false) throws
        -> (format: KeyVaultFormat, master: SymmetricKey, passphraseKey: SymmetricKey,
            recoveryKey: SymmetricKey)
    {
        let master = SymmetricKey(size: .bits256)
        let passphraseKey = SymmetricKey(size: .bits256)
        let recoveryKey = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: passphraseKey,
            recoveryKey: withRecovery ? recoveryKey : nil,
            classKeys: [
                (keyClass: .corpus, keyID: "corpus-id-1", key: SymmetricKey(size: .bits256)),
                (keyClass: .journalBridge, keyID: "journal-id-1", key: SymmetricKey(size: .bits256)),
            ],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        return (format, master, passphraseKey, recoveryKey)
    }

    @Test func fetchOnAnEmptyVaultReturnsNil() async throws {
        let world = VaultTestWorld()
        #expect(try await world.client.fetchVault() == nil)
    }

    @Test func createThenFetchRoundTripsTheFormatExactly() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        try await world.client.createVault(sample.format)
        let fetched = try await world.client.fetchVault()
        #expect(fetched?.format == sample.format)
        // A fresh row carries the CAS token at the column default (R1-2).
        #expect(fetched?.revision == 1)
        // The stored wire row carries the session's user — never a
        // caller-supplied id.
        #expect(world.server.storedRow(userID: world.userID) != nil)
    }

    @Test func createOverAnExistingVaultRefuses() async throws {
        let world = VaultTestWorld()
        try await world.client.createVault(try sampleFormat().format)
        await #expect(throws: KeyVaultClientError.vaultAlreadyExists) {
            try await world.client.createVault(try sampleFormat().format)
        }
    }

    @Test func updateReplacesTheRowAndRefusesWhenAbsent() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        // Absent → refuses; nothing invented.
        await #expect(throws: KeyVaultClientError.vaultAbsent) {
            try await world.client.updateVault(sample.format, expectedRevision: 1)
        }
        try await world.client.createVault(sample.format)
        let updated = try sample.format.addingRecoveryWrap(
            masterKey: sample.master, recoveryKey: sample.recoveryKey)
        try await world.client.updateVault(updated, expectedRevision: 1)
        let fetched = try await world.client.fetchVault()
        #expect(fetched?.format == updated)
        #expect(fetched?.format.masterWrappedByRecovery != nil)
        // The CAS token advanced with the write (R1-2).
        #expect(fetched?.revision == 2)
    }

    /// The CAS mechanics at the client seam (R1-2): an update presenting a
    /// STALE revision token matches zero rows and refuses typed — the row
    /// is byte-untouched, and the refusal's contract is refetch-and-
    /// re-derive, never blind-retry.
    @Test func aStaleRevisionUpdateRefusesTypedWithoutWriting() async throws {
        let world = VaultTestWorld()
        let sample = try sampleFormat()
        try await world.client.createVault(sample.format)
        // A concurrent writer moves the row: revision 1 → 2.
        let moved = try sample.format.addingRecoveryWrap(
            masterKey: sample.master, recoveryKey: sample.recoveryKey)
        try await world.client.updateVault(moved, expectedRevision: 1)
        let rowBefore = world.server.storedRow(userID: world.userID)

        // The stale writer still holds token 1 — refused, nothing written.
        await #expect(throws: KeyVaultClientError.vaultRevisionConflict) {
            try await world.client.updateVault(sample.format, expectedRevision: 1)
        }
        #expect(world.server.storedRow(userID: world.userID) == rowBefore,
                "a refused stale update writes nothing")
        // Refetching yields the current token; the re-derived update lands.
        let current = try #require(try await world.client.fetchVault())
        #expect(current.revision == 2)
        try await world.client.updateVault(current.format, expectedRevision: current.revision)
        #expect(try await world.client.fetchVault()?.revision == 3)
    }

    @Test func aNewerFormatVersionRefusesByVersion() async throws {
        let world = VaultTestWorld()
        var row = try KeyVaultWireRow(
            format: try sampleFormat().format, userID: world.userID)
        row.formatVersion = KeyVaultFormat.currentFormatVersion + 1
        world.server.store(row)
        await #expect(throws: KeyVaultClientError.unsupportedFormatVersion(
            KeyVaultFormat.currentFormatVersion + 1)
        ) {
            try await world.client.fetchVault()
        }
    }

    @Test func aMalformedStoredRowRefusesTyped() async throws {
        let world = VaultTestWorld()
        var row = try KeyVaultWireRow(
            format: try sampleFormat().format, userID: world.userID)
        row.masterWrappedByPassphrase = "not!!base64"
        world.server.store(row)
        do {
            _ = try await world.client.fetchVault()
            Issue.record("a non-base64 wrap must refuse")
        } catch let error as KeyVaultClientError {
            guard case .malformedRow = error else {
                Issue.record("expected malformedRow, got \(error)")
                return
            }
        }
    }

    @Test func concurrentFetchesSingleFlightOntoOneRequest() async throws {
        let world = VaultTestWorld()
        try await world.client.createVault(try sampleFormat().format)
        let baseline = world.server.getCount
        async let a = world.client.fetchVault()
        async let b = world.client.fetchVault()
        async let c = world.client.fetchVault()
        _ = try await (a, b, c)
        #expect(world.server.getCount - baseline == 1,
                "concurrent fetches must coalesce onto one request (single-flight)")
    }

    /// The 9c auth posture: a server-judged-stale token gets ONE
    /// refresh-and-retry through the provider seam.
    @Test func a401GetsOneRefreshAndRetry() async throws {
        let server = ScriptedVaultServer()
        server.requiredBearer = "fresh-token"
        final class RefreshingProvider: UserSessionProviding, @unchecked Sendable {
            func currentSession() async throws -> UserSession {
                UserSession(accessToken: "stale-token", userID: "user-vault-test")
            }
            func refreshedSession() async throws -> UserSession {
                UserSession(accessToken: "fresh-token", userID: "user-vault-test")
            }
        }
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key"),
            sessionProvider: RefreshingProvider(),
            load: server.load)
        // The GET 401s on the stale bearer, retries refreshed, succeeds.
        #expect(try await client.fetchVault() == nil)
    }

    @Test func serverFailuresSurfaceAsTypedHTTPErrors() async throws {
        let world = VaultTestWorld()
        world.server.forcedStatus = 503
        do {
            _ = try await world.client.fetchVault()
            Issue.record("a 503 must surface")
        } catch let error as KeyVaultClientError {
            guard case .httpFailure(let status, _) = error else {
                Issue.record("expected httpFailure, got \(error)")
                return
            }
            #expect(status == 503)
        }
    }

    /// The wire row refuses to encode a format missing either v1 class key
    /// — the DDL's columns ARE the class set (R-8).
    @Test func aFormatMissingAClassKeyHasNoWireForm() throws {
        let master = SymmetricKey(size: .bits256)
        let format = try KeyVaultFormat.create(
            masterKey: master,
            passphraseKey: SymmetricKey(size: .bits256),
            recoveryKey: nil,
            classKeys: [(keyClass: .corpus, keyID: "corpus-only", key: SymmetricKey(size: .bits256))],
            kdf: .v1(salt: PassphraseKDF.randomSalt()))
        #expect(throws: KeyVaultClientError.self) {
            _ = try KeyVaultWireRow(format: format, userID: "u")
        }
    }
}
