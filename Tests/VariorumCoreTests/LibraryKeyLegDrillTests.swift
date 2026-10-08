import CryptoKit
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13x U2b, DRILL LEGS 2 + 5 — THE PER-LEG OPENS ON AN ADOPTED COPY
// (decision 11 · corner 33 · corner 44 · ledger 14's second look) and THE
// NEWER-SCHEMA REFUSAL AT THE MODEL'S CONSULT (the sync trace's item 5).
//
// Leg 2 drills every credential road an arriving pair can open under,
// headless, through the SHIPPED seams alone (`StoreKeyEnvelope`'s wrap
// roads + in-memory custody — no real Keychain, no stage): the day's
// passphrase, the twelve words, the Apple arm (an in-memory A — the
// Standard-silent leg's cryptography, nothing typed), the OLDER-KEY day
// pair after a Replace-All-Keys-shaped re-key (corner 44: each pair keeps
// its day's word; backup folders are never rewritten), and the
// same-fingerprint second look with the collision rule's three verdicts.
//
// Leg 5 drills the model's two consults call-for-call (`LibraryOpenModel
// .land` runs `LibraryClassifier.classify`; `.settle` runs
// `schemaVerdict(at:key:)` — verified against the shipped source): a copy
// a newer build wrote refuses with its EXACT unknown identifiers (the
// facts the refusal's `detail` joins), an older copy stays an OPEN road.
@Suite("13x U2b legs 2+5 — the per-leg opens + the newer-schema consult")
struct LibraryKeyLegDrillTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func scratch() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-leg2-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// A closed encrypted library with one marker row and a key file
    /// carrying the drill's wraps: the day's passphrase, the twelve words,
    /// and the in-memory Apple key.
    private func makeLibrary(
        at storeURL: URL, passphrase: String, marker: String,
        words: [String]? = nil, apple: SymmetricKey? = nil
    ) throws -> (key: StoreKey, keyFile: URL) {
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
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
        if let words { try envelope.setRecoveryWrap(key: key, words: words) }
        if let apple {
            try envelope.setAppleWrappedCopy(key: key, under: apple, appleKeyID: "drill-apple")
        }
        let keyFile = envelope.preferredURL(besideStore: storeURL)
        try envelope.write(at: keyFile)
        return (key, keyFile)
    }

    /// Read-only, as the classifier itself inspects a picked store: a
    /// read-write open writes on open, and since W-1's checkpoint-on-lock
    /// that write lands in the main file — the drill's "reads only" claim
    /// must be literally true, not true-because-the-sidecar-hid-it.
    private func readMarker(at url: URL, key: StoreKey) throws -> String? {
        var configuration = AppDatabase.configuration(key: key)
        configuration.readonly = true
        let queue = try DatabaseQueue(path: url.path, configuration: configuration)
        defer { try? queue.close() }
        return try queue.read {
            try String.fetchOne($0, sql: "SELECT title FROM container LIMIT 1")
        }
    }

    // MARK: - Leg 2 (a)–(c): the three credential arms on a hand-off pair

    @Test func theHandOffFolderOpensByEachOfItsThreeWraps() throws {
        let dir = try scratch()
        defer { try? FileManager.default.removeItem(at: dir) }
        let home = dir.appendingPathComponent("home/variorum.sqlite")
        let words = try RecoveryPhrase.generate()
        let apple = SymmetricKey(size: .bits256)
        let made = try makeLibrary(
            at: home, passphrase: "the day's word", marker: "the-travelling-library",
            words: words, apple: apple)

        // THE HAND-OFF FOLDER (QC's ruled shape): snapshot + the key
        // file's copy under its own fingerprint name, one folder.
        let folder = dir.appendingPathComponent("Variorum Library — 2026-10-07", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let travelled = folder.appendingPathComponent("variorum.sqlite")
        try FileManager.default.copyItem(at: home, to: travelled)
        let travelledKeyFile = folder.appendingPathComponent(made.keyFile.lastPathComponent)
        try FileManager.default.copyItem(at: made.keyFile, to: travelledKeyFile)

        // The door's step 1 (the model's `begin`): the folder classifies
        // as the pair — the whole-folder AirDrop opens as one thing.
        #expect(LibraryClassifier.classify(at: folder)
            == .folderHoldingPair(store: travelled, keyFile: travelledKeyFile))
        let envelope = try #require(try StoreKeyEnvelope.load(at: travelledKeyFile))

        // (a) THE DAY'S PASSPHRASE — unwraps to the SAME key; the copy
        // opens and reads; a wrong word refuses as the typo it is.
        let byPassphrase = try envelope.unwrapKey(
            passphrase: "the day's word", floor: .relaxedForTests)
        #expect(byPassphrase == made.key)
        #expect(try readMarker(at: travelled, key: byPassphrase) == "the-travelling-library")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            _ = try envelope.unwrapKey(passphrase: "not the word", floor: .relaxedForTests)
        }

        // (b) THE TWELVE WORDS — the disaster road, offline by design.
        let byWords = try envelope.unwrapKey(recoveryWords: words)
        #expect(byWords == made.key)
        #expect(try readMarker(at: travelled, key: byWords) == "the-travelling-library")
        let otherWords = try RecoveryPhrase.generate()
        #expect(throws: StoreKeyEnvelopeError.wrongRecoveryPhrase) {
            _ = try envelope.unwrapKey(recoveryWords: otherWords)
        }

        // (c) THE APPLE ARM — the Standard-silent leg's cryptography:
        // A in hand (in-memory; the real one lives in iCloud Keychain),
        // nothing typed, the pair's copy unwraps.
        let byApple = try envelope.unwrapKey(apple: apple)
        #expect(byApple == made.key)
        #expect(try readMarker(at: travelled, key: byApple) == "the-travelling-library")
        #expect(throws: StoreKeyEnvelopeError.wrongAppleKey) {
            _ = try envelope.unwrapKey(apple: SymmetricKey(size: .bits256))
        }

        // The source pair never changed under any of it (reads only).
        #expect(try Data(contentsOf: travelled) == Data(contentsOf: home))
    }

    // MARK: - Leg 2 (d)+(e): the older-key day pair + the second look

    @Test func anOlderKeySnapshotPairOpensByItsOwnDayAndTheCollisionRuleComposes() throws {
        let dir = try scratch()
        defer { try? FileManager.default.removeItem(at: dir) }
        let home = dir.appendingPathComponent("home/variorum.sqlite")
        let old = try makeLibrary(
            at: home, passphrase: "the old word", marker: "the-long-lived-library")
        let oldKey = old.key

        // The snapshot PAIR of the old key's day (row 42's shape).
        let fp8 = StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: oldKey))
        let backups = dir.appendingPathComponent("Backups", isDirectory: true)
        let snapshot = backups.appendingPathComponent(
            "variorum-backup-2026-06-01-120000-\(fp8).sqlite")
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: home, to: snapshot)
        let pairKeyFile = LibraryClassifier.pairedKeyFile(for: snapshot)
        try FileManager.default.copyItem(
            at: StoreKeyEnvelope.url(
                besideStore: home, fingerprint: StoreKeyEnvelope.fingerprint(of: oldKey)),
            to: pairKeyFile)
        let pairBytesBefore = try Data(contentsOf: pairKeyFile)
        let snapshotBytesBefore = try Data(contentsOf: snapshot)

        // REPLACE ALL KEYS, shaped: the live library re-keys L1→L2; a NEW
        // key file lands under the NEW word; the old live key file goes
        // (the follow's letter). The old envelope's storeID rides — the
        // id is stable across re-keys (§3.5).
        let newKey = StoreKey.mint()
        let oldEnvelope = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: home))
        #expect(try StoreEncryptionMigration.rekey(at: home, from: oldKey, to: newKey))
        var newEnvelope = StoreKeyEnvelope()
        newEnvelope.storeID = oldEnvelope.storeID
        try newEnvelope.setPassphraseWrap(key: newKey, passphrase: "the new word", kdf: fastKDF())
        try newEnvelope.write(at: newEnvelope.preferredURL(besideStore: home))
        try FileManager.default.removeItem(
            at: StoreKeyEnvelope.url(
                besideStore: home, fingerprint: StoreKeyEnvelope.fingerprint(of: oldKey)))

        // CORNER 44 + the never-rewritten rule: the pair's bytes are
        // byte-identical after the key event.
        #expect(try Data(contentsOf: pairKeyFile) == pairBytesBefore,
                "a backup pair is NEVER rewritten by a key event")
        #expect(try Data(contentsOf: snapshot) == snapshotBytesBefore)

        // The pair still classifies as ITSELF (its own key file, never
        // the live one) and opens by ITS day's word.
        #expect(LibraryClassifier.classify(at: snapshot)
            == .snapshotPair(store: snapshot, keyFile: pairKeyFile))
        let pairEnvelope = try #require(try StoreKeyEnvelope.load(at: pairKeyFile))
        let opener = try pairEnvelope.unwrapKey(
            passphrase: "the old word", floor: .relaxedForTests)
        #expect(opener == oldKey)
        #expect(try readMarker(at: snapshot, key: opener) == "the-long-lived-library")

        // The NEW word does not open the old day's pair; the NEW key does
        // not open the old day's snapshot.
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            _ = try pairEnvelope.unwrapKey(passphrase: "the new word", floor: .relaxedForTests)
        }
        #expect(throws: (any Error).self, "L2 opens nothing of the old day") {
            let queue = try DatabaseQueue(
                path: snapshot.path, configuration: AppDatabase.configuration(key: newKey))
            _ = try queue.read { try $0.tableExists("block") }
        }

        // …while the LIVE library is under the new key alone.
        #expect(try readMarker(at: home, key: newKey) == "the-long-lived-library")

        // THE COLLISION RULE composes the adoption's three verdicts:
        // custody holds L2, the pair opened by L1 ⇒ adopt the opener;
        // same key ⇒ aligned (ledger 14's second look); no custody ⇒ the
        // new-Mac mint (corner 33's enrollment class).
        let heldFP = StoreKeyEnvelope.fingerprint(of: newKey)
        let openerFP = StoreKeyEnvelope.fingerprint(of: opener)
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: heldFP, openingKeyFingerprint: openerFP)
            == .adoptOpeningKey)
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: heldFP, openingKeyFingerprint: heldFP)
            == .alreadyAligned)
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: nil, openingKeyFingerprint: openerFP)
            == .mintFreshCustody)

        // (e) THE SECOND LOOK on a post-re-key snapshot: its pair belongs
        // to the LIVE key, so the live custody serves it — no wrap typed.
        let newSnapshot = backups.appendingPathComponent(
            "variorum-backup-2026-10-07-090000-"
            + StoreKeyEnvelope.shortFingerprint(heldFP) + ".sqlite")
        try FileManager.default.copyItem(at: home, to: newSnapshot)
        let newPairFile = LibraryClassifier.pairedKeyFile(for: newSnapshot)
        try FileManager.default.copyItem(
            at: newEnvelope.preferredURL(besideStore: home), to: newPairFile)
        let newPair = try #require(try StoreKeyEnvelope.load(at: newPairFile))
        #expect(newPair.belongs(to: newKey),
                "ledger 14: the live custody serves a same-key snapshot")
        #expect(try readMarker(at: newSnapshot, key: newKey) == "the-long-lived-library")
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
        // The facts the model's refusal `detail` joins (LibraryOpenModel
        // .land, verified call-for-call against the shipped source).
        #expect(expected.joined(separator: " · ")
            == "v99_13x_u2b_aa_future · v99_13x_u2b_zz_future")

        // ——— The ENCRYPTED arm (the model's post-unlock consult): the
        // keyless stage honestly serves the PAIR (ciphertext hides the
        // schema by construction); the consult with the key in hand
        // refuses `.newer` with the same exact identifiers — BEFORE any
        // adoption mechanics run (the model's switch stops at `refused`).
        let home = dir.appendingPathComponent("newer-enc/variorum.sqlite")
        let made = try makeLibrary(
            at: home, passphrase: "a word", marker: "written-by-tomorrow")
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
        let unlocked = try #require(try StoreKeyEnvelope.load(at: made.keyFile))
            .unwrapKey(passphrase: "a word", floor: .relaxedForTests)
        #expect(LibraryClassifier.schemaVerdict(at: home, key: unlocked)
            == .newer(unknownMigrations: ["v99_13x_u2b_enc_future"]),
                "the post-unlock consult (LibraryOpenModel.settle's call) refuses honestly")

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
