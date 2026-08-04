import CryptoKit
import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 3 (L10) — the vault-bootstrap runner's brain against
/// the fake sync server + a temp on-disk store + the scripted vault: the
/// happy path (create-vault → reinit → drain, ciphertext on the mirror,
/// enrollable afterwards with the same passphrase), the refusal arms
/// (wrong passphrase, newer format, empty passphrase), the dry-run's
/// write-nothing guarantee, and the CLI's pure helpers.
@Suite("Vault bootstrap runner (Phase 14b, L10)", .serialized)
struct VaultBootstrapTests {

    /// One runner world: a TEMP ON-DISK store (the runner's real input is a
    /// store path) seeded with a couple of journal rows, the fake mirror,
    /// and the scripted vault — all under the deterministic dependency
    /// world. The body runs inside the bound scope, exactly where the CLI's
    /// live scope would be.
    private func withRunnerWorld(
        _ body: (VaultBootstrap, AppDatabase, FakeSyncServer, VaultTestWorld,
                 LockIsolated<[String]>) async throws -> Void
    ) async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("vault-bootstrap-tests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("store.sqlite")
        let db = try AppDatabase.openStore(at: storeURL)

        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: {
            // Seed: one journal entry with real prose.
            let ops = Operations()
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-08-04").container
            _ = try ops.newBlock(in: entry.id, text: "The overnight arrangement's words.", at: .end)

            let server = FakeSyncServer()
            let vaultWorld = VaultTestWorld()
            let logLines = LockIsolated<[String]>([])
            let bootstrap = VaultBootstrap(
                client: vaultWorld.client,
                transport: server,
                database: db,
                log: { line in logLines.withValue { $0.append(line) } })
            try await body(bootstrap, db, server, vaultWorld, logLines)
        }
    }

    @Test func theHappyPathCreatesUnwrapsReinitializesAndDrainsOverCiphertext() async throws {
        try await withRunnerWorld { bootstrap, db, server, vaultWorld, logLines in
            let report = try await bootstrap.run(passphrase: "orchard-lantern-13", dryRun: false)
            #expect(report.arm == .createVault)
            #expect(report.remainingOutbox == 0, "the outbox drained")
            #expect(report.pushedAccepted > 0)

            // Round 5: the runner's vault is passphrase-wrap ONLY — the
            // recovery phrase is generated in the app, in her presence.
            let vault = try await vaultWorld.client.fetchVault()
            #expect(vault != nil)
            #expect(vault?.format.masterWrappedByRecovery == nil)

            // The mirror holds CIPHERTEXT, never her words.
            let variantID = try #require(try db.fetchString("SELECT id FROM variant LIMIT 1"))
            let mirrored = await server.currentRow(table: "variant", rowID: variantID)
            guard case .text(let wire)? = mirrored?.columns["working_text"] else {
                Issue.record("the variant row must reach the mirror")
                return
            }
            #expect(PayloadCipher.isEncrypted(wire))
            #expect(wire != "The overnight arrangement's words.")

            // The MORNING's half: the app enrolls from the vault with the
            // SAME passphrase and can read what the runner pushed — the
            // keys died with the runner, the vault carries them wrapped.
            let material = try await vaultWorld.enrollment.enroll(
                passphrase: "orchard-lantern-13")
            let opened = try PayloadCipher.open(
                wire, key: material.corpusSymmetricKey,
                binding: PayloadCipher.Binding(
                    table: "variant", rowID: variantID,
                    column: "working_text", keyID: material.corpusKeyID))
            #expect(opened == "The overnight arrangement's words.")

            // The acts were logged step by step; no log line ever carries
            // the passphrase.
            #expect(logLines.value.contains { $0.contains("resyncReinitialize") })
            #expect(logLines.value.contains { $0.contains("Outbox drained") })
            #expect(!logLines.value.contains { $0.contains("orchard-lantern-13") },
                    "the passphrase never appears in any log line")
        }
    }

    @Test func anExistingVaultTakesTheUnwrapArmAndIsNeverOverwritten() async throws {
        try await withRunnerWorld { bootstrap, _, _, vaultWorld, _ in
            // The vault already exists (her overnight setup).
            let original = try await vaultWorld.enrollment.setUp(passphrase: "orchard-lantern-13")
            let rowBefore = vaultWorld.server.storedRow(userID: vaultWorld.userID)

            let report = try await bootstrap.run(passphrase: "orchard-lantern-13", dryRun: false)
            #expect(report.arm == .unwrapExisting)
            #expect(report.remainingOutbox == 0)

            // Idempotence by refusal-of-overwrite: the row is byte-identical.
            let rowAfter = vaultWorld.server.storedRow(userID: vaultWorld.userID)
            #expect(rowAfter == rowBefore, "an existing vault is unwrapped, never rewritten")
            // And the keys it used ARE the vault's (enroll-again equality).
            let again = try await vaultWorld.enrollment.enroll(passphrase: "orchard-lantern-13")
            #expect(again == original)
        }
    }

    @Test func aWrongPassphraseRefusesWithNothingWritten() async throws {
        try await withRunnerWorld { bootstrap, db, server, vaultWorld, _ in
            _ = try await vaultWorld.enrollment.setUp(passphrase: "orchard-lantern-13")
            let outboxBefore = try db.fetchInt("SELECT COUNT(*) FROM sync_outbox")
            let versionsBefore = try db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE sync_version = 0")

            await #expect(throws: VaultEnrollmentError.wrongPassphrase) {
                try await bootstrap.run(passphrase: "orchard-lantern-14", dryRun: false)
            }

            // The refusal happened BEFORE the store was touched: no reinit,
            // no enqueue, nothing on the mirror.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == outboxBefore)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE sync_version = 0") == versionsBefore)
            #expect(await server.rowCount(table: "variant") == 0)
        }
    }

    @Test func aNewerFormatVaultRefusesByVersion() async throws {
        try await withRunnerWorld { bootstrap, db, _, vaultWorld, _ in
            _ = try await vaultWorld.enrollment.setUp(passphrase: "orchard-lantern-13")
            var row = vaultWorld.server.storedRow(userID: vaultWorld.userID)!
            row.formatVersion = KeyVaultFormat.currentFormatVersion + 1
            vaultWorld.server.store(row)
            // The seeded rows' own trigger-enqueued entries — the refusal
            // must leave them exactly as they are (no reinit ran).
            let outboxBefore = try db.fetchInt("SELECT COUNT(*) FROM sync_outbox")

            await #expect(throws: KeyVaultClientError.unsupportedFormatVersion(
                KeyVaultFormat.currentFormatVersion + 1)
            ) {
                try await bootstrap.run(passphrase: "orchard-lantern-13", dryRun: false)
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == outboxBefore)
        }
    }

    @Test func dryRunPrintsThePlanAndWritesNothing() async throws {
        try await withRunnerWorld { bootstrap, db, server, vaultWorld, logLines in
            let outboxBefore = try db.fetchInt("SELECT COUNT(*) FROM sync_outbox")

            let report = try await bootstrap.run(passphrase: "orchard-lantern-13", dryRun: true)
            #expect(report.dryRun)
            #expect(report.arm == .createVault)

            #expect(vaultWorld.server.isEmpty, "dry-run creates no vault")
            #expect(await server.rowCount(table: "variant") == 0, "dry-run pushes nothing")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == outboxBefore,
                    "dry-run enqueues nothing")
            #expect(logLines.value.contains { $0.contains("DRY RUN") })
        }
    }

    @Test func anEmptyPassphraseRefusesBeforeAnything() async throws {
        try await withRunnerWorld { bootstrap, _, _, vaultWorld, _ in
            await #expect(throws: VaultEnrollmentError.emptyPassphrase) {
                try await bootstrap.run(passphrase: "", dryRun: false)
            }
            #expect(vaultWorld.server.requestCount == 0)
        }
    }

    // MARK: The CLI's pure helpers

    @Test func thePassphraseFileContractStripsExactlyOneTrailingNewline() throws {
        #expect(try VaultBootstrap.passphrase(fromFileBytes: Data("secret words\n".utf8))
            == "secret words")
        #expect(try VaultBootstrap.passphrase(fromFileBytes: Data("secret words\r\n".utf8))
            == "secret words")
        #expect(try VaultBootstrap.passphrase(fromFileBytes: Data("secret words".utf8))
            == "secret words")
        // Only ONE newline strips — inner/extra ones are the passphrase's.
        #expect(try VaultBootstrap.passphrase(fromFileBytes: Data("secret\n\n".utf8))
            == "secret\n")
        #expect(throws: VaultBootstrapError.passphraseFileEmpty) {
            _ = try VaultBootstrap.passphrase(fromFileBytes: Data())
        }
        #expect(throws: VaultBootstrapError.passphraseFileEmpty) {
            _ = try VaultBootstrap.passphrase(fromFileBytes: Data("\n".utf8))
        }
    }

    /// R1-8: the token-file door shares the passphrase file's byte
    /// contract — bytes ARE the token, ONE trailing newline stripped
    /// (`\n` or `\r\n`), empty refuses typed. The argv form is retained;
    /// the CLI requires exactly one of the two (the gate uses the file
    /// form because argv rides `ps` output).
    @Test func theAccessTokenFileContractStripsExactlyOneTrailingNewline() throws {
        #expect(try VaultBootstrap.accessToken(fromFileBytes: Data("jwt.token.here\n".utf8))
            == "jwt.token.here")
        #expect(try VaultBootstrap.accessToken(fromFileBytes: Data("jwt.token.here\r\n".utf8))
            == "jwt.token.here")
        #expect(try VaultBootstrap.accessToken(fromFileBytes: Data("jwt.token.here".utf8))
            == "jwt.token.here")
        #expect(throws: VaultBootstrapError.accessTokenFileEmpty) {
            _ = try VaultBootstrap.accessToken(fromFileBytes: Data("\n".utf8))
        }
        #expect(throws: VaultBootstrapError.accessTokenFileUnreadable) {
            _ = try VaultBootstrap.accessToken(fromFileBytes: Data([0xFF, 0xFE]))
        }
    }

    @Test func theAccessTokenSubjectExtractsAndRefusesTyped() throws {
        // {"sub":"<account-uuid>-test"} — base64url, unsigned (RLS is the real
        // authority; the tool only needs the uid to compose the session).
        let payload = Data(#"{"sub":"<account-uuid>-test"}"#.utf8)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        let token = "eyJhbGciOiJIUzI1NiJ9.\(payload).signature"
        #expect(try VaultBootstrap.subject(ofAccessToken: token) == "<account-uuid>-test")
        #expect(throws: VaultBootstrapError.malformedAccessToken) {
            _ = try VaultBootstrap.subject(ofAccessToken: "not-a-jwt")
        }
        #expect(throws: VaultBootstrapError.malformedAccessToken) {
            _ = try VaultBootstrap.subject(ofAccessToken: "a.b.c")
        }
    }
}
