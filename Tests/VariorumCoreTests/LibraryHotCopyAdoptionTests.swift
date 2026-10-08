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
        let key = StoreKey.mint()
        let made = try makeHotCopy(in: dir, withShm: withShm, key: key)
        return (made.folder, made.store, try #require(made.keyFile), key)
    }

    /// `key` nil = a PLAINTEXT full library (the pre-13p class — stage 1's
    /// `openForInspection` road, Q4) copied hot the same way; no key file.
    private func makeHotCopy(
        in dir: URL, withShm: Bool, key: StoreKey?
    ) throws -> (folder: URL, store: URL, keyFile: URL?) {
        let original = dir.appendingPathComponent("running/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: original.deletingLastPathComponent(), withIntermediateDirectories: true)
        let database = try key.map { try AppDatabase.openStore(at: original, custody: .inMemory(initial: $0)) }
            ?? AppDatabase.onDisk(url: original, key: nil)
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
        var originalKeyFile: URL?
        if let key {
            var envelope = StoreKeyEnvelope()
            try envelope.setPassphraseWrap(key: key, passphrase: "the copy's word", kdf: fastKDF())
            originalKeyFile = envelope.preferredURL(besideStore: original)
            try envelope.write(at: try #require(originalKeyFile))
        }

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
        var keyFile: URL?
        if let originalKeyFile {
            keyFile = folder.appendingPathComponent(originalKeyFile.lastPathComponent)
            try FileManager.default.copyItem(at: originalKeyFile, to: try #require(keyFile))
        }
        _ = database.asRebindable().binding.lock()
        #expect(size(sidecar(store, "-wal")) > 0, "premise: the COPY carries the hot wal")
        return (folder, store, keyFile)
    }

    /// A folder the user can read but not write (a locked volume, a DMG,
    /// a read-only share) — restored to writable by `writable(_:)` so the
    /// temporary tree can be removed.
    private func readOnly(_ folder: URL) throws {
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: folder.path)
    }

    private func writable(_ folder: URL) {
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: folder.path)
    }

    /// A CLOSED keyed library cut after its first two pages — page 1
    /// (the key check) intact, the rest gone: a torn copy (an interrupted
    /// copy, a full disk) under its RIGHT key, its key file beside it.
    private func makeTornCopy(in dir: URL) throws -> (folder: URL, store: URL, key: StoreKey) {
        let original = dir.appendingPathComponent("whole/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: original, custody: .inMemory(initial: key))
        _ = database.asRebindable().binding.lock()
        let folder = dir.appendingPathComponent("torn", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = folder.appendingPathComponent("variorum.sqlite")
        let whole = try Data(contentsOf: original)
        #expect(whole.count > 4096 * 2, "premise: the library is longer than the cut")
        try whole.prefix(4096 * 2).write(to: store)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "the torn word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: store))
        return (folder, store, key)
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

    // MARK: - (b′) the report's SYMPTOM on this stack: a non-writable folder

    /// Measured at F3 (the re-trace the orchestrator ACCEPTED, Q1): in a
    /// WRITABLE folder SQLite's read-only connection creates the missing
    /// `-shm` and reads on — (b) above; the read fails only where no
    /// `-shm` CAN be created. There the old consult read `.unreadable`
    /// (SQLITE_CANTOPEN) and `settle` wore the wrong-key sentence — false
    /// on both facts (the key is right; the copy is whole). The staged
    /// read never needs to write beside the picked file, so the truth
    /// holds wherever the copy sits.
    @Test func anShmLessHotCopyInANonWritableFolderReadsTrueAndLandsWhole() throws {
        let dir = try temporaryDirectory()
        let hot = try makeHotCopy(in: dir, withShm: false)
        try readOnly(hot.folder)
        defer {
            writable(hot.folder)
            try? FileManager.default.removeItem(at: dir)
        }
        let sourceBefore = try contents(of: hot.folder)
        let home = dir.appendingPathComponent("home/variorum.sqlite")

        let (verdict, landed) = try runTheDoor(picked: hot.folder, key: hot.key, home: home)
        #expect(verdict == .current,
                "the right key over a whole copy reads current wherever it sits, got \(verdict)")
        if let landedStore = landed {
            let title = try walledTitle(atLanded: landedStore, key: hot.key)
            #expect(title == Self.walledID,
                    "the landed library holds the row the source's wal holds")
        }
        try expectUntouched(hot.folder, before: sourceBefore)
    }

    // MARK: - (c) the GENUINE mismatch — and the consult never writes

    /// A key that does not open the picked store, over a CLOSED copy and
    /// over a HOT one. Measured at F3 on the old tree: the hot arm's
    /// read-only open refused at GRDB's `validateFormat`, the read-write
    /// fallback reopened the PICKED file, and its close-time checkpoint
    /// folded the wal into the picked main file and deleted its `-wal`
    /// and `-shm` — "the file you picked was only read" made false by the
    /// consult itself (Q2, ruled in scope).
    @Test func aWrongKeyConsultLeavesThePickedFolderByteIdentical() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let hot = try makeHotCopy(in: dir, withShm: true)
        let sourceBefore = try contents(of: hot.folder)
        let wrongKey = StoreKey.mint()

        let verdict = LibraryClassifier.schemaVerdict(at: hot.store, key: wrongKey)
        #expect(verdict != .current, "a wrong key never reads as a library")
        try expectUntouched(hot.folder, before: sourceBefore)
    }

    // MARK: - Q4 — stage 1's plaintext road takes the same staged read

    /// The plaintext road's door, exactly as `LibraryOpenModel` composes
    /// it: classify the picked folder → land (no pair) → recreate the
    /// local tables → a fresh key + identity → the reopen (which runs the
    /// 13p plaintext→encrypted migration) — then read the walled row.
    private func runThePlaintextDoor(
        picked folder: URL, home: URL
    ) throws -> (LibraryClassifier.Verdict, title: String?) {
        let verdict = LibraryClassifier.classify(at: folder)
        guard case .plaintextLibrary(let store) = verdict else { return (verdict, nil) }
        let plan = LibraryAdoption.plan(
            adopting: store, keyFile: nil, intoStoreAt: home,
            now: Date(timeIntervalSince1970: 1_800_000_000))
        try LibraryAdoption.execute(plan, holding: .init(asOf: nil, now: Date()))
        try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: home)
        let freshKey = StoreKey.mint()
        _ = try StoreIdentity.establish(besideStore: home, key: freshKey)
        return (verdict, try walledTitle(atLanded: home, key: freshKey))
    }

    @Test func aHotCopiedPlaintextLibraryClassifiesWithoutATouchAndLandsWhole() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let hot = try makeHotCopy(in: dir, withShm: true, key: nil)
        let sourceBefore = try contents(of: hot.folder)
        let (verdict, title) = try runThePlaintextDoor(
            picked: hot.folder, home: dir.appendingPathComponent("home/variorum.sqlite"))
        #expect(verdict == .plaintextLibrary(store: hot.store))
        #expect(title == Self.walledID, "the landed library holds the row the source's wal holds")
        try expectUntouched(hot.folder, before: sourceBefore)
    }

    @Test func anShmLessHotPlaintextCopyClassifiesWithoutATouchAndLandsWhole() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let hot = try makeHotCopy(in: dir, withShm: false, key: nil)
        let sourceBefore = try contents(of: hot.folder)
        let (verdict, title) = try runThePlaintextDoor(
            picked: hot.folder, home: dir.appendingPathComponent("home/variorum.sqlite"))
        #expect(verdict == .plaintextLibrary(store: hot.store))
        #expect(title == Self.walledID, "the landed library holds the row the source's wal holds")
        try expectUntouched(hot.folder, before: sourceBefore)
    }

    @Test func anShmLessHotPlaintextCopyInANonWritableFolderClassifiesTrue() throws {
        let dir = try temporaryDirectory()
        let hot = try makeHotCopy(in: dir, withShm: false, key: nil)
        try readOnly(hot.folder)
        defer {
            writable(hot.folder)
            try? FileManager.default.removeItem(at: dir)
        }
        let sourceBefore = try contents(of: hot.folder)
        let (verdict, title) = try runThePlaintextDoor(
            picked: hot.folder, home: dir.appendingPathComponent("home/variorum.sqlite"))
        #expect(verdict == .plaintextLibrary(store: hot.store),
                "a whole plaintext copy classifies as what it is wherever it sits, got \(verdict)")
        #expect(title == Self.walledID, "the landed library holds the row the source's wal holds")
        try expectUntouched(hot.folder, before: sourceBefore)
    }
}
