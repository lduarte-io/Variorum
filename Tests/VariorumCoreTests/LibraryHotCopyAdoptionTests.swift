import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13x F3 — ladder round 3's R3-1 (MAJOR), pinned headless over REAL keyed
// stores. A library folder copied while HOT — the store, its `-wal` and
// (usually) its `-shm`: the ordinary Finder copy of a running, crashed or
// force-quit library — is a served shape of the adoption door (the
// classifier's own doc names "a hand-copied library folder"). The pins
// drive the door's real call sequence over such a copy — `classify` →
// `schemaVerdict(at:key:)` → `LibraryAdoption.plan/execute` — and then
// open the LANDED library under the key the way the door's reopen does.
//
// The disposition's four constraints, each asserted:
//   (1) the SOURCE is never written — the picked folder is byte-identical,
//       file for file, after the whole sequence;
//   (2) the landed library holds every committed row the source's `-wal`
//       holds (the walled row — written after the last checkpoint, so it
//       lives in the wal alone);
//   (3) a store unreadable for any OTHER reason never wears the wrong-key
//       class, and a GENUINE key mismatch still does;
//   (4) a `-shm` is never trusted across a copy — none lands.

@Suite("13x F3 — R3-1: a hot-copied library adopts whole, and only a wrong key reads as one")
struct LibraryHotCopyAdoptionTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-f3-hot-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private static let walledID = "the-walled-row"

    private func sidecar(_ store: URL, _ suffix: String) -> URL {
        URL(fileURLWithPath: store.path + suffix)
    }

    private func size(_ url: URL) -> Int {
        (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
    }

    /// The report's shape: a keyed library, ESTABLISHED (its schema
    /// checkpointed into the main file), then one row written while the
    /// pool stays OPEN — so that row lives in the `-wal` alone — and the
    /// folder copied HOT beside its key file. `withShm` false drops the
    /// `-shm` from the copy (the sibling arm). The original pool closes
    /// only AFTER the copy (its lock-time checkpoint touches the original,
    /// never the copy).
    private func makeHotCopy(
        in dir: URL, withShm: Bool
    ) throws -> (folder: URL, store: URL, keyFile: URL, key: StoreKey) {
        let original = dir.appendingPathComponent("running/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: original, custody: .inMemory(initial: key))
        try database.writeWithoutTransaction { db in
            _ = try db.checkpoint(.truncate)
        }
        #expect(size(sidecar(original, "-wal")) == 0, "premise: the schema is checkpointed")
        try database.write { db in
            try db.execute(
                sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES (?, 'post', ?, '2027-01-01T00:00:00Z', '2027-01-01T00:00:00Z')
                    """,
                arguments: [Self.walledID, Self.walledID])
        }
        #expect(size(sidecar(original, "-wal")) > 0, "premise: the walled row sits in the wal")
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "the copy's word", kdf: fastKDF())
        let originalKeyFile = envelope.preferredURL(besideStore: original)
        try envelope.write(at: originalKeyFile)

        // THE HOT COPY — the pool is open, the wal is hot.
        let folder = dir.appendingPathComponent("hand-copied", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = folder.appendingPathComponent("variorum.sqlite")
        try FileManager.default.copyItem(at: original, to: store)
        try FileManager.default.copyItem(
            at: sidecar(original, "-wal"), to: sidecar(store, "-wal"))
        if withShm {
            #expect(FileManager.default.fileExists(atPath: sidecar(original, "-shm").path),
                    "premise: an open pool has its -shm")
            try FileManager.default.copyItem(
                at: sidecar(original, "-shm"), to: sidecar(store, "-shm"))
        }
        let keyFile = folder.appendingPathComponent(originalKeyFile.lastPathComponent)
        try FileManager.default.copyItem(at: originalKeyFile, to: keyFile)
        _ = database.asRebindable().binding.lock()
        #expect(size(sidecar(store, "-wal")) > 0, "premise: the COPY carries the hot wal")
        return (folder, store, keyFile, key)
    }

    /// Every file in a folder, by name, with its bytes — the
    /// source-never-written law's evidence (a new sidecar shows up as a
    /// new name; a rewritten one as changed bytes).
    private func contents(of folder: URL) throws -> [String: Data] {
        var out: [String: Data] = [:]
        for name in try FileManager.default.contentsOfDirectory(atPath: folder.path) {
            out[name] = try Data(contentsOf: folder.appendingPathComponent(name))
        }
        return out
    }

    /// The source-never-written assertion, file by file (so a red names
    /// the file that appeared or changed).
    private func expectUntouched(
        _ folder: URL, before: [String: Data], sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let after = try contents(of: folder)
        #expect(after.keys.sorted() == before.keys.sorted(),
                "the picked folder gained or lost a file", sourceLocation: sourceLocation)
        for (name, bytes) in before {
            #expect(after[name] == bytes, "\(name) was rewritten", sourceLocation: sourceLocation)
        }
    }

    /// The door's reopen road over the landed library (`openStore` — what
    /// `adoptLibrary(reopeningWith:)`'s opener runs), reading the walled
    /// row's title; nil = the row did not land.
    private func walledTitle(atLanded store: URL, key: StoreKey) throws -> String? {
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        defer { _ = database.asRebindable().binding.lock() }
        return try database.read { db in
            try String.fetchOne(
                db, sql: "SELECT title FROM container WHERE id = ?", arguments: [Self.walledID])
        }
    }

    /// The door's sequence from the picked FOLDER to the landing; returns
    /// the schema verdict it consulted and the landed store URL (nil when
    /// the verdict refused, as the door would).
    private func runTheDoor(
        picked folder: URL, key: StoreKey, home: URL
    ) throws -> (LibraryClassifier.SchemaVerdict, landed: URL?) {
        guard case .folderHoldingPair(let store, let keyFile) =
            LibraryClassifier.classify(at: folder)
        else {
            Issue.record("the hand-copied folder must classify as the pair")
            return (.unreadable(reason: "not classified"), nil)
        }
        let verdict = LibraryClassifier.schemaVerdict(at: store, key: key)
        switch verdict {
        case .current, .behindThisBuild:
            let plan = LibraryAdoption.plan(
                adopting: store, keyFile: keyFile, intoStoreAt: home,
                now: Date(timeIntervalSince1970: 1_800_000_000))
            try LibraryAdoption.execute(plan, holding: .init(asOf: nil, now: Date()))
            return (verdict, plan.landedStore)
        default:
            return (verdict, nil)
        }
    }

    // MARK: - (a) the hot trio — the wal tail must land

    @Test func aHotCopiedLibraryLandsWithEveryRowItsWalHolds() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let hot = try makeHotCopy(in: dir, withShm: true)
        let sourceBefore = try contents(of: hot.folder)
        let home = dir.appendingPathComponent("home/variorum.sqlite")

        let (verdict, landed) = try runTheDoor(picked: hot.folder, key: hot.key, home: home)
        #expect(verdict == .current, "the consult reads the copy whole")
        let landedStore = try #require(landed)
        // (4) no -shm crosses the copy.
        #expect(!FileManager.default.fileExists(atPath: sidecar(landedStore, "-shm").path),
                "a -shm is never trusted across a copy — none lands")
        // (2) the landing carries what the consult read.
        let title = try walledTitle(atLanded: landedStore, key: hot.key)
        #expect(title == Self.walledID,
                "the landed library holds the row the source's wal holds")
        // (1) the source was only read — every file byte-identical, none new.
        try expectUntouched(hot.folder, before: sourceBefore)
    }

    // MARK: - (b) the shm-less hot copy — the verdict is TRUE

    @Test func anShmLessHotCopyReadsTrueAndLandsWhole() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let hot = try makeHotCopy(in: dir, withShm: false)
        let sourceBefore = try contents(of: hot.folder)
        let home = dir.appendingPathComponent("home/variorum.sqlite")

        let (verdict, landed) = try runTheDoor(picked: hot.folder, key: hot.key, home: home)
        // The key IS right and the copy IS whole (main + wal): the true
        // verdict is a readable one — never the wrong-key class, never a
        // refusal.
        #expect(verdict == .current,
                "an shm-less hot copy under its own key reads current, got \(verdict)")
        if let landedStore = landed {
            #expect(!FileManager.default.fileExists(atPath: sidecar(landedStore, "-shm").path))
            let title = try walledTitle(atLanded: landedStore, key: hot.key)
            #expect(title == Self.walledID,
                    "the landed library holds the row the source's wal holds")
        }
        // No -shm materialized beside the source, nothing rewritten.
        try expectUntouched(hot.folder, before: sourceBefore)
    }
}
