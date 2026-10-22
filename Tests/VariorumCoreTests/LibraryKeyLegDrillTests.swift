import CryptoKit
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13x U2b, DRILL LEG 5 — THE NEWER-SCHEMA REFUSAL AT THE MODEL'S
// CONSULT (the sync trace's item 5): the classifier's two consults —
// `classify` (keyless) and `schemaVerdict(at:key:)` (post-unlock) — over a
// copy a newer build wrote refuse with its EXACT unknown identifiers (the
// facts the refusal's `detail` joins); an older copy stays an OPEN road.
//
// VX-329 U1 — THE RELEASE SWITCH: leg 2 (every credential road an arriving
// pair opened under — today's envelope's passphrase, words and Apple wraps,
// the older-key day pair, the custody collision rule's second look) was
// today's road and was deleted with it; the consults survive (the classifier
// serves the honest words), so leg 5 stands, its encrypted arm consulting
// with the key in hand rather than one unwrapped from today's key file.
@Suite("13x U2b leg 5 — the newer-schema consult")
struct LibraryKeyLegDrillTests {
    private func scratch() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-leg2-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// A closed encrypted library with one marker row and THIS design's key
    /// file beside it (the classifier names it, never reads it).
    private func makeLibrary(at storeURL: URL, marker: String) throws -> (key: StoreKey, keyFile: URL) {
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        try database.write { db in
            try db.execute(
                sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES (?, 'post', ?, '2027-01-01T00:00:00Z', '2027-01-01T00:00:00Z')
                    """,
                arguments: [marker, marker])
        }
        _ = database.asRebindable().binding.lock()
        let keyFile = storeURL.deletingLastPathComponent()
            .appendingPathComponent(ProtectionNames.keyFilename, isDirectory: false)
        try KeyFile(libraryID: UUID().uuidString.lowercased(), key: key, epoch: 1).encoded().write(to: keyFile)
        return (key, keyFile)
    }

    // MARK: - Leg 5: the newer-schema refusal at the model's consult

    @Test func aCopyFromANewerBuildRefusesAtBothConsultsWithItsExactIdentifiers() throws {
        let dir = try scratch()
        defer { try? FileManager.default.removeItem(at: dir) }

        // ——— The PLAINTEXT arm (the model's step-1 consult, keyless):
        // a real store a "newer build" wrote — two future identifiers,
        // inserted out of order to pin the sorted rendering.
        let plain = dir.appendingPathComponent("newer-plain/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: plain.deletingLastPathComponent(), withIntermediateDirectories: true)
        let plainDB = try AppDatabase.onDisk(url: plain, key: nil)
        try plainDB.write { db in
            try db.execute(
                sql: "INSERT INTO grdb_migrations (identifier) VALUES (?), (?)",
                arguments: ["v99_13x_u2b_zz_future", "v99_13x_u2b_aa_future"])
        }
        _ = plainDB.asRebindable().binding.lock()
        let expected = ["v99_13x_u2b_aa_future", "v99_13x_u2b_zz_future"]
        #expect(LibraryClassifier.classify(at: plain)
            == .newerSchema(store: plain, unknownMigrations: expected),
                "the keyless consult refuses with the EXACT identifiers, sorted")
        // The facts the refusal's `detail` joins (`PickedCopy.todaysWords`'s join; 13x's `LibraryOpenModel.land`,
        // deleted with today's road at VX-329 U1, joined them the same way).
        #expect(expected.joined(separator: " · ")
            == "v99_13x_u2b_aa_future · v99_13x_u2b_zz_future")

        // ——— The ENCRYPTED arm (the post-unlock consult): the
        // keyless stage honestly serves the PAIR (ciphertext hides the
        // schema by construction); the consult with the key in hand
        // refuses `.newer` with the same exact identifiers.
        let home = dir.appendingPathComponent("newer-enc/variorum.sqlite")
        let made = try makeLibrary(at: home, marker: "written-by-tomorrow")
        let keyed = try DatabaseQueue(
            path: home.path, configuration: AppDatabase.configuration(key: made.key))
        try keyed.write { db in
            try db.execute(
                sql: "INSERT INTO grdb_migrations (identifier) VALUES (?)",
                arguments: ["v99_13x_u2b_enc_future"])
        }
        try keyed.close()
        #expect(LibraryClassifier.classify(at: home)
            == .encryptedLibrary(store: home, keyFile: made.keyFile),
                "keyless, a ciphertext copy classifies by its PAIR — the schema is honestly unknown")
        #expect(LibraryClassifier.schemaVerdict(at: home, key: made.key)
            == .newer(unknownMigrations: ["v99_13x_u2b_enc_future"]),
                "the post-unlock consult refuses honestly")

        // ——— The OLDER copy stays an OPEN road, never a refusal: drop
        // the last applied migration and the verdict says "behind", with
        // the one unapplied identifier named.
        let older = dir.appendingPathComponent("older/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: older.deletingLastPathComponent(), withIntermediateDirectories: true)
        let olderDB = try AppDatabase.onDisk(url: older, key: nil)
        let last = try #require(AppDatabase.migrator.migrations.last)
        try olderDB.write { db in
            try db.execute(
                sql: "DELETE FROM grdb_migrations WHERE identifier = ?", arguments: [last])
        }
        _ = olderDB.asRebindable().binding.lock()
        #expect(LibraryClassifier.schemaVerdict(at: older, key: nil)
            == .behindThisBuild(unapplied: [last]),
                "an old copy is the open-and-migrate road, never a refusal")
    }
}
