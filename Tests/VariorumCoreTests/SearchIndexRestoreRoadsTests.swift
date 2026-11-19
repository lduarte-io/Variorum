//
//  SearchIndexRestoreRoadsTests.swift
//  VariorumCoreTests
//
//  VX-79 (the VX-980 run, batch 2) — THE RESTORE-ROADS TRACE's GUARD PINS. Her R-980-2 asked for a trace of
//  every restore-shaped road before any automatic check is built ("make sure what the trace reveals is in my
//  handoff with full description and options"); the run record's BATCH 2 — LIVE STATUS carries the trace for
//  her, road by road. Each pin here RUNS a road the way the app runs it — the same core functions, in the same
//  order, on real files — and then asks the index's own check (`verifySearchIndex().isHealthy`): the search
//  index the road lands is in step with the notes it lands.
//
//  GUARD pins over shipped roads (no red-on-old leg applies — nothing here changes behaviour). Their teeth: a
//  road that copied the notes but not the index, or the index from another moment than the notes, or lost a
//  capture trigger on the way, fails `verifySearchIndex()` (the integrity check's three nets plus FTS5's own
//  index-against-content check) and the doc-fact comparisons below. TESTS ONLY: every road's code is called,
//  none is edited (the run's fence — `Protection/`, `Sync/` and the bootstrap's landing acts are read and
//  driven here, never changed).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-79 — the restore roads land the search index in step with the notes (guard pins)")
struct SearchIndexRestoreRoadsTests {
    // MARK: - The world

    /// The operations over `database`, a real clock and fresh ids (a library's own writes, as the app makes them).
    static func ops<T>(_ database: AppDatabase, _ body: (Operations) throws -> T) rethrows -> T {
        try withDependencies {
            $0.database = database
            $0.uuid = .init { UUID() }
            $0.date = .init { Date() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            try body(Operations())
        }
    }

    /// A scratch folder, removed when the value goes.
    final class Folder {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx79-roads-\(UUID().uuidString)", isDirectory: true)
        init() { try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
        deinit { try? FileManager.default.removeItem(at: url) }
        func directory(_ path: String) -> URL {
            let directory = url.appendingPathComponent(path, isDirectory: true)
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            return directory
        }
        func file(_ path: String) -> URL {
            let file = url.appendingPathComponent(path)
            try? FileManager.default.createDirectory(
                at: file.deletingLastPathComponent(), withIntermediateDirectories: true)
            return file
        }
    }

    /// The words each kind carries — one distinctive word per indexed field, so a hit names its kind.
    enum Word {
        static let title = "lighthouse"
        static let take = "keeper"
        static let branch = "warden"
        static let label = "gentler"
        static let blockName = "gambit"
        static let noteMeta = "musings"
        static let comment = "tide"
        static let savepoint = "firstlight"
        static let book = "coastal"
        static let chapter = "harbour"
        static let archivedTake = "quince"
        static let archivedNote = "marmalade"
        static let trashed = "zephyr"
        static let wingNote = "studioline"
    }

    /// EVERY indexed kind (the nine: title, take, take label, block name, note meta, comment, savepoint, book,
    /// chapter) and the states a copy must carry faithfully — an archived take, an archived note in a second
    /// wing, a note in the Trash (its fields out of the index), a membership. Written through the operations,
    /// as her doors write.
    static func writeEveryKind(_ ops: Operations) throws {
        let studio = try ops.createWing(name: "studio")
        let note = try ops.createPost(title: "The \(Word.title) ledger")
        let first = try ops.newBlock(in: note.id, text: "The \(Word.take) climbs the stair at dusk.", registeringUndo: false)
        let branch = try ops.branchVariant(first.block.id, from: first.variant.id)
        try ops.autosave(branch.id, text: "The \(Word.branch) climbs the stair at dawn.", charDelta: 8)
        try ops.setTakeLabel(branch.id, label: "a \(Word.label) version")
        try ops.setBlockName(first.block.id, name: "opening \(Word.blockName)")
        try ops.updateFloatingNotes(note.id, notes: "margin \(Word.noteMeta)")
        _ = try ops.addBlockComment(to: first.block.id, text: "check the \(Word.comment) tables")
        // A savepoint whose words the take has since left (the ninth kind's own text).
        try ops.autosave(first.variant.id, text: "The \(Word.take) says \(Word.savepoint) aloud.", charDelta: 12)
        _ = try ops.commit(first.variant.id, message: "first light")
        try ops.autosave(first.variant.id, text: "The \(Word.take) climbs the stair at dusk.", charDelta: 12)
        let second = try ops.newBlock(in: note.id, text: "A second paragraph.", registeringUndo: false)
        let shelved = try ops.branchVariant(second.block.id, from: second.variant.id)
        try ops.autosave(shelved.id, text: "A shelved \(Word.archivedTake) sentence.", charDelta: 5)
        try ops.archiveVariant(shelved.id)
        let book = try ops.createReading(name: "The \(Word.book) book", kind: .book)
        let chapter = try ops.createSection(in: book.id, name: "The \(Word.chapter) chapter")
        _ = try ops.addPostToReading(note.id, to: book.id)
        try ops.assignPostToSection(note.id, in: book.id, section: chapter.id)
        let kept = try ops.createPost(title: "Put away", wingId: studio.id)
        _ = try ops.newBlock(in: kept.id, text: "Archived \(Word.archivedNote) words.", registeringUndo: false)
        try ops.archiveContainer(kept.id)
        let elsewhere = try ops.createPost(title: "In the studio", wingId: studio.id)
        _ = try ops.newBlock(in: elsewhere.id, text: "A \(Word.wingNote) in the other wing.", registeringUndo: false)
        let gone = try ops.createPost(title: "Trashed note")
        _ = try ops.newBlock(in: gone.id, text: "Deleted \(Word.trashed) words.", registeringUndo: false)
        try ops.deleteContainer(gone.id)
    }

    /// The index's doc set as FACTS — kind, source row and every own-row fact, never the local rowid — so two
    /// libraries holding the same notes can be compared doc for doc.
    static func docFacts(_ database: AppDatabase) throws -> [String] {
        try database.read { db in
            try Row.fetchAll(db, sql: """
                SELECT kind, src_id, block_id, container_id, reading_id, wing_id, variant_id, archived
                FROM search_doc ORDER BY kind, src_id
                """).map { row in
                    ["kind", "src_id", "block_id", "container_id", "reading_id", "wing_id", "variant_id", "archived"]
                        .map { String(describing: row[$0] as DatabaseValue) }.joined(separator: "|")
                }
        }
    }

    /// What the index answers, word by word (the FTS5 MATCH straight off the index — `searchHits`'s road), as
    /// KINDS: the doc kinds each word finds.
    static func answers(_ database: AppDatabase, _ words: [String]) throws -> [String: [String]] {
        var answers: [String: [String]] = [:]
        for word in words {
            answers[word] = try database.read { db in
                try String.fetchAll(db, sql: """
                    SELECT d.kind FROM search_fts JOIN search_doc d ON d.id = search_fts.rowid
                    WHERE search_fts MATCH ? ORDER BY d.kind
                    """, arguments: [word])
            }
        }
        return answers
    }

    static let everyWord = [
        Word.title, Word.take, Word.branch, Word.label, Word.blockName, Word.noteMeta, Word.comment, Word.savepoint,
        Word.book, Word.chapter, Word.archivedTake, Word.archivedNote, Word.trashed, Word.wingNote,
    ]

    /// The index's own check, over `database`.
    static func check(_ database: AppDatabase) throws -> SearchIndexIntegrity {
        try ops(database) { try $0.verifySearchIndex() }
    }

    /// A new library's record (the creation's — `ProtectionLibraryFiles.createLibrary` lands one in every library).
    static func record(for key: StoreKey) -> ProtectionRecord {
        ProtectionRecord.minting(
            libraryID: UUID().uuidString.lowercased(), mode: .standard, account: nil,
            currentFingerprint: KeyFingerprint.of(key), at: Date())
    }

    /// A library on disk, made the creation's way (`createLibrary` — the record only — then the ordinary open,
    /// every migration), its notes written through the operations.
    static func liveLibrary(at slot: URL, key: StoreKey) throws -> AppDatabase {
        try ProtectionLibraryFiles.createLibrary(at: slot, key: key, record: record(for: key), date: Date())
        let live = try AppDatabase.openStore(at: slot, custody: .inMemory(initial: key))
        try ops(live) { try writeEveryKind($0) }
        return live
    }

    /// **MAKE THIS MY LIBRARY's file road, from a copy file to the landed library** — exactly the calls the road
    /// makes (`SQLCipherLibraryLeaf.stageCopy`, `swapStaged`, then the bootstrap's open): a PRIVATE byte copy of
    /// the catalogued copy (`privateCopy` — the copy is never written), re-encrypted under the new library's key
    /// into the staged file (`exportReencrypted` — `sqlcipher_export`, row counts verified), the staged file
    /// renamed into the slot (the swap — one rename), then the ordinary open (`openStore` — every migration this
    /// build has that the copy lacks).
    static func makeMine(copy: URL, opener: StoreKey, in folder: Folder, as name: String) throws -> (AppDatabase, StoreKey) {
        let newKey = StoreKey.mint()
        let probe = try ProtectionLibraryFiles.privateCopy(of: copy, inside: folder.directory("scratch"))
        let slot = folder.file("\(name)/variorum.sqlite")
        let staged = URL(fileURLWithPath: slot.path + ".staged")
        try ProtectionLibraryFiles.exportReencrypted(from: probe, key: opener, to: staged, newKey: newKey)
        try FileManager.default.removeItem(at: probe.deletingLastPathComponent())
        #expect(rename(staged.path, slot.path) == 0, "the swap's one rename")
        return (try AppDatabase.openStore(at: slot, custody: .inMemory(initial: newKey)), newKey)
    }

    // MARK: - Road 1 (+ road 5): a backup pair, a Previous Library, a pair sent from another Mac — made mine

    /// **A BACKUP PAIR MADE MINE.** The live library's backup is SQLite's backup API under its own key
    /// (`ProtectionLibraryFiles.snapshot` — the backups leaf's `writeContainerPair`, and the Send Library pair's
    /// `writeSendPair`): one consistent page copy, so the index rides INSIDE the copy at exactly the moment its
    /// notes do. Make this my library then re-encrypts that copy (`sqlcipher_export`), swaps it in and opens it.
    /// The landed index is the copy's own, doc for doc — healthy, answering every word as the source did, and
    /// still capturing (the triggers came across): an edit after the landing is findable at once.
    @Test func aBackupPairMadeMineLandsItsIndexInStep() throws {
        let folder = Folder()
        let key = StoreKey.mint()
        let live = try Self.liveLibrary(at: folder.file("live/variorum.sqlite"), key: key)
        #expect(try Self.check(live).isHealthy, "control: the source library's index is in step")
        let sourceFacts = try Self.docFacts(live)
        let sourceAnswers = try Self.answers(live, Self.everyWord)
        #expect(sourceAnswers[Word.trashed] == [], "control: a note in the Trash is out of the index")
        #expect(sourceAnswers[Word.savepoint] == ["savepoint"], "control: the ninth kind is in")

        // The backup pair's library file (the backup scheduler's road and Send Library's alike).
        let backup = folder.file("Backups/lib/mac/variorum-backup-2026-11-19-120000-01234567.sqlite")
        try ProtectionLibraryFiles.snapshot(of: folder.file("live/variorum.sqlite"), key: key, to: backup)

        let (landed, _) = try Self.makeMine(copy: backup, opener: key, in: folder, as: "landed")
        let report = try Self.check(landed)
        #expect(report.isHealthy, "the landed index is in step: \(report)")
        #expect(try Self.docFacts(landed) == sourceFacts, "the copy's index, doc for doc")
        #expect(try Self.answers(landed, Self.everyWord) == sourceAnswers, "every word answers as it did")

        // The capture triggers came across with the copy: a write after the landing is in the index at once.
        try Self.ops(landed) { ops in
            let post = try ops.createPost(title: "Written after the restore")
            _ = try ops.newBlock(in: post.id, text: "A brandnew sentence.", registeringUndo: false)
        }
        #expect(try Self.answers(landed, ["brandnew"])["brandnew"] == ["take"])
        #expect(try Self.check(landed).isHealthy, "and still in step")
    }

    /// **SEND LIBRARY TO ANOTHER MAC → OPEN LIBRARY ON THE OTHER SIDE.** The send writes the same snapshot
    /// (`writeSendPair` → `snapshot`); the other Mac FILES the picked pair by a byte copy into its safety copies
    /// (`PickedCopy.file`), then Make this my library runs on the filed copy — so the road is snapshot → byte copy
    /// → the make-mine road. A copy that sat in a WAL-mode library's folder is one self-contained file (the
    /// snapshot turns it to rollback-journal mode), so no `-wal` is left behind to replay.
    @Test func aLibrarySentToAnotherMacAndOpenedThereLandsItsIndexInStep() throws {
        let folder = Folder()
        let key = StoreKey.mint()
        let live = try Self.liveLibrary(at: folder.file("live/variorum.sqlite"), key: key)
        let sourceFacts = try Self.docFacts(live)
        // The sending Mac's folder (the pair's library file).
        let sent = folder.file("Variorum Library — 2026-11-19/variorum.sqlite")
        try ProtectionLibraryFiles.snapshot(of: folder.file("live/variorum.sqlite"), key: key, to: sent)
        #expect(!FileManager.default.fileExists(atPath: sent.path + "-wal"), "one self-contained file travels")
        // The other Mac files it (a byte copy) — then makes it its library.
        let filed = folder.file("other-mac/Backups/safety-copies/opened-2026-11-19-120000/variorum.sqlite")
        try FileManager.default.copyItem(at: sent, to: filed)
        let (landed, _) = try Self.makeMine(copy: filed, opener: key, in: folder, as: "other-mac-slot")
        #expect(try Self.check(landed).isHealthy)
        #expect(try Self.docFacts(landed) == sourceFacts)
    }

    // MARK: - Road 3: a copy from an EARLIER build (its migrations a subset of this build's)

    /// A keyed library file migrated only UP TO `era`, its notes written by raw SQL in that era's own columns (no
    /// operation of today's build touches it — the era's writer did), then turned into a backup the way that build
    /// would (`snapshot`). Two eras: the oldest a copy on today's road can be (`v1_31`, the protection record's —
    /// the search index already there, built by its capture triggers as the rows went in), and one from before the
    /// index existed at all (`v1_21` — the mechanism beyond the reachable roads: `v1_22`'s migration builds the
    /// index from the notes at the first open).
    static func eraCopy(_ era: String, in folder: Folder, key: StoreKey) throws -> URL {
        let slot = folder.file("era-\(era)/variorum.sqlite")
        let queue = try DatabaseQueue(path: slot.path, configuration: AppDatabase.configuration(key: key))
        try AppDatabase.migrator.migrate(queue, upTo: era)
        let t = "2026-10-22T12:00:00.000Z"
        try queue.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, floating_notes, created_at, updated_at)
                VALUES ('N1', 'post', 'The \(Word.title) ledger', 'margin \(Word.noteMeta)', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: "INSERT INTO block (id, name, created_at, updated_at) VALUES ('B1', 'opening \(Word.blockName)', ?, ?)",
                           arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO variant (id, block_id, working_text, label, fan_position, created_at, updated_at)
                VALUES ('V1', 'B1', 'The \(Word.take) climbs.', NULL, 'a0', ?, ?),
                       ('V2', 'B1', 'The \(Word.branch) climbs.', 'a \(Word.label) version', 'a1', ?, ?)
                """, arguments: [t, t, t, t])
            try db.execute(sql: "UPDATE block SET default_variant_id = 'V1' WHERE id = 'B1'")
            try db.execute(sql: """
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                VALUES ('P1', 'N1', 'B1', 'a0', 'V1', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO block_comment (id, block_id, text, created_at, updated_at)
                VALUES ('C1', 'B1', 'check the \(Word.comment) tables', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO commit_point (id, variant_id, text, kind, created_at)
                VALUES ('S1', 'V1', 'The \(Word.take) says \(Word.savepoint).', 'manual', ?)
                """, arguments: [t])
            try db.execute(sql: """
                INSERT INTO reading (id, name, kind, created_at, updated_at) VALUES ('R1', 'The \(Word.book) book', 'book', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO reading_section (id, reading_id, name, position, created_at, updated_at)
                VALUES ('RS1', 'R1', 'The \(Word.chapter) chapter', 'a0', ?, ?)
                """, arguments: [t, t])
        }
        try queue.close()
        let backup = folder.file("era-\(era)-backup/variorum-backup.sqlite")
        try ProtectionLibraryFiles.snapshot(of: slot, key: key, to: backup)
        return backup
    }

    /// Each era word and the doc kinds that must answer it (the take's word is in its savepoint's text too).
    static let eraAnswers: [String: [String]] = [
        Word.title: ["title"], Word.noteMeta: ["note_meta"], Word.blockName: ["block_name"],
        Word.take: ["savepoint", "take"], Word.branch: ["take"], Word.label: ["take_label"], Word.comment: ["comment"],
        Word.savepoint: ["savepoint"], Word.book: ["book"], Word.chapter: ["chapter"],
    ]

    @Test(arguments: ["v1_31_protection_record", "v1_21_reading_archive"])
    func aCopyFromAnEarlierBuildMigratesForwardWithItsIndexInStep(era: String) throws {
        let folder = Folder()
        let key = StoreKey.mint()
        let backup = try Self.eraCopy(era, in: folder, key: key)
        let peek = try DatabaseQueue(path: backup.path, configuration: AppDatabase.configuration(key: key))
        let carriedAnIndex = try peek.read { try $0.tableExists("search_doc") }
        try peek.close()
        #expect(carriedAnIndex == (era == "v1_31_protection_record"), "the v1_31 copy carries its index; the v1_21 copy none")

        let (landed, _) = try Self.makeMine(copy: backup, opener: key, in: folder, as: "landed-\(era)")
        let applied = try landed.read { try String.fetchAll($0, sql: "SELECT identifier FROM grdb_migrations") }
        #expect(Set(applied) == Set(AppDatabase.migrator.migrations), "the ordinary open brought it to this build")
        let report = try Self.check(landed)
        #expect(report.isHealthy, "in step after the migrations: \(report)")
        #expect(try Self.answers(landed, Array(Self.eraAnswers.keys)) == Self.eraAnswers,
                "every field of the era's notes answers, each by its own kind")
    }

    // MARK: - Road 2: a plaintext export brought in at Open Library (T-8)

    /// **A PLAINTEXT EXPORT BROUGHT IN.** The export KEEPS the derived tables, so the file searches by itself —
    /// and that copied index is itself in step with the copied notes (`sqlcipher_export` copies both from one
    /// connection's one snapshot). But Open Library never ADOPTS the export's file: it READS the notes into a plan
    /// (`PlaintextExportReading.read`, on a private staged copy) and MINTS them fresh into a brand-new library
    /// through the ordinary operations (`importPlaintextExport`), so the new library's index is built by its own
    /// capture triggers, row by row, as the notes go in — the export's index is never brought across at all.
    @Test func aPlaintextExportBroughtInBuildsItsOwnIndexInStep() throws {
        let folder = Folder()
        let source = try AppDatabase.inMemory()
        try Self.ops(source) { try Self.writeEveryKind($0) }
        let export = folder.file("picked/Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: source, to: export)

        // The no-lock-in file's own index: in step with the file's own notes (read on a scratch copy — FTS5 spells
        // its check as an INSERT, and the picked file is never written).
        let scratch = folder.file("export-check/copy.sqlite")
        try FileManager.default.copyItem(at: export, to: scratch)
        let exportReport = try DatabaseQueue(path: scratch.path).write { try SearchIndex.integrity($0) }
        #expect(exportReport.isHealthy, "the export's own index is in step with its notes: \(exportReport)")

        // The bring-in: the plan, then a NEW library (the creation's road) minted from it headless.
        let plan = try PlaintextExportReading.read(exportAt: export)
        let newKey = StoreKey.mint()
        let slot = folder.file("new-library/variorum.sqlite")
        try ProtectionLibraryFiles.createLibrary(at: slot, key: newKey, record: Self.record(for: newKey), date: Date())
        let landed = try AppDatabase.onDisk(url: slot, key: newKey)
        let landing = try Self.ops(landed) { try $0.importPlaintextExport(plan) }
        #expect(landing.notes == 3 && landing.books == 1, "what the export holds landed (\(landing))")
        let report = try Self.check(landed)
        #expect(report.isHealthy, "the new library's index is in step: \(report)")
        // What the bring-in carries is findable (the mapping: titles, takes, labels, books, chapters, archived
        // writing — never comments, block names, margin notes or commits: configuration and history stay behind).
        let answers = try Self.answers(landed, Self.everyWord)
        for word in [Word.title, Word.take, Word.branch, Word.label, Word.book, Word.chapter, Word.archivedNote, Word.wingNote] {
            #expect(answers[word]?.isEmpty == false, "\(word) landed and is findable")
        }
        #expect(answers[Word.trashed] == [], "the Trash never crosses")
    }

    /// **A PLAINTEXT EXPORT FROM AN EARLIER BUILD** — the oldest export era (`v1_31`; the VX-502 record: no
    /// content-bearing export predates it), written by raw SQL in that era's columns, its writer's local-only drop
    /// applied (the era-frozen fixture's shape, `PlaintextExportImportTests`). Read and minted fresh, it lands an
    /// index in step — the export's own schema age never reaches the new library's index.
    @Test func aPlaintextExportFromAnEarlierBuildBuildsItsOwnIndexInStep() throws {
        let folder = Folder()
        let export = folder.file("era-export/export.sqlite")
        let queue = try DatabaseQueue(path: export.path)
        try AppDatabase.migrator.migrate(queue, upTo: "v1_31_protection_record")
        let t = "2026-10-22T12:00:00.000Z"
        try queue.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at) VALUES ('N1', 'post', 'The \(Word.title) ledger', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: "INSERT INTO block (id, created_at, updated_at) VALUES ('B1', ?, ?)", arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO variant (id, block_id, working_text, label, fan_position, created_at, updated_at)
                VALUES ('V1', 'B1', 'The \(Word.take) climbs.', NULL, 'a0', ?, ?),
                       ('V2', 'B1', 'The \(Word.branch) climbs.', 'a \(Word.label) version', 'a1', ?, ?)
                """, arguments: [t, t, t, t])
            try db.execute(sql: "UPDATE block SET default_variant_id = 'V1' WHERE id = 'B1'")
            try db.execute(sql: """
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                VALUES ('P1', 'N1', 'B1', 'a0', 'V1', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO reading (id, name, kind, created_at, updated_at) VALUES ('R1', 'The \(Word.book) book', 'book', ?, ?)
                """, arguments: [t, t])
            try db.execute(sql: """
                INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                VALUES ('RP1', 'R1', 'N1', 'a0', 'member', ?)
                """, arguments: [t])
            for table in PlaintextExportImportTests.oldestExportEraDroppedTables {
                try db.execute(sql: "DROP TABLE \(table)")
            }
        }
        try queue.close()

        let plan = try PlaintextExportReading.read(exportAt: export)
        let landed = try AppDatabase.inMemory()
        let landing = try Self.ops(landed) { try $0.importPlaintextExport(plan) }
        #expect(landing.notes == 1 && landing.books == 1)
        #expect(try Self.check(landed).isHealthy)
        let answers = try Self.answers(landed, [Word.title, Word.take, Word.branch, Word.label, Word.book])
        #expect(answers.values.allSatisfy { !$0.isEmpty }, "every carried word is findable: \(answers)")
    }

    // MARK: - Road 4: the first sync round into a fresh library (and the restore that resumes sync)

    /// **THE FIRST SYNC ROUND INTO A FRESH LIBRARY.** Every row arrives through remote apply
    /// (`SyncRow.apply`, UPDATE-then-INSERT under the apply flag) — no operation runs on the receiving device —
    /// and the capture triggers deliberately do NOT check the apply flag, so the arriving rows are indexed exactly
    /// as local writes are. Small windows (four rows) so the first catch-up runs window after window. The fresh
    /// device's index is in step, and holds the SAME docs as the device the notes were written on.
    @Test func theFirstSyncRoundIntoAFreshLibraryLandsItsIndexInStep() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let fresh = try SyncClient(name: "Fresh", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        try mac.with { ops, _ in try Self.writeEveryKind(ops) }
        try await syncToQuiescence(mac, fresh, server: server, batchSize: 4, maxRounds: 40)

        for client in [mac, fresh] {
            let report = try client.with { ops, _ in try ops.verifySearchIndex() }
            #expect(report.isHealthy, "\(client.name)'s index is in step: \(report)")
        }
        #expect(try Self.docFacts(fresh.db) == Self.docFacts(mac.db), "the same docs on both devices")
        #expect(try Self.answers(fresh.db, Self.everyWord) == Self.answers(mac.db, Self.everyWord))
    }

    /// One device's committed round (the restore matrix's shape).
    private func round(_ client: SyncClient) async throws {
        try await client.push()
        try await client.pull()
        try await client.pull()
    }

    /// **A RESTORE THAT RESUMES SYNC.** A backup of a synced library made mine on a synced account lands held;
    /// Resume Sync then catches it up: an edit made after the copy arrives by remote apply, an ordinary delete
    /// arrives as a tombstone (the tombstone cascade retires the note's fields), and a PERMANENT delete arrives
    /// through the purged-ids ledger (`reconcileLedger` removes the family's rows physically — the delete
    /// triggers retire their docs). Every one of those writes passes the capture triggers: the restored library
    /// lands in step, and after the catch-up holds exactly the docs the library it caught up with holds.
    @Test func aRestoreThatResumesSyncStaysInStepThroughTheCatchUp() async throws {
        let scratch = try RestoreScratch()
        defer { scratch.cleanUp() }
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server, storeURL: scratch.url("a.sqlite"))
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        let (edited, deleted, purged): (String, String, String) = try a.with { ops, db in
            try Self.writeEveryKind(ops)
            let edited = try #require(try db.fetchString(
                "SELECT id FROM variant WHERE working_text LIKE '%\(Word.branch)%' AND deleted_at IS NULL"))
            let deleted = try ops.createPost(title: "deleted after the copy")
            _ = try ops.newBlock(in: deleted.id, text: "Words that leave after the backup.", registeringUndo: false)
            let purged = try ops.createPost(title: "purged after the copy")
            _ = try ops.newBlock(in: purged.id, text: "Words deleted for good after the backup.", registeringUndo: false)
            return (edited, deleted.id, purged.id)
        }
        try await syncToQuiescence(a, b, server: server)
        let snapshot = try scratch.snapshot(a, as: "backup.sqlite")

        // After the copy: an edit, an ordinary delete, a Delete Now (the janitor purges it once both devices saw it).
        try a.with { ops, _ in
            try ops.autosave(edited, text: "The \(Word.branch) rewrote it with a cormorant.", charDelta: 20)
            try ops.deleteContainer(deleted)
            try ops.deleteContainer(purged)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: purged)])
        }
        try await syncToQuiescence(a, b, server: server)
        try await round(a)
        try await round(b)
        let swept = try await a.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: a.keyProvider).sweep()
        }
        #expect(swept.familiesPurged == 1, "control: the permanent delete really ran")

        // THE RESTORE (the copy's bytes, opened), then RESUME SYNC (the ledger pass, then rounds).
        let restored = try scratch.restore(snapshot, as: "restored", prefix: "AC", transport: server)
        #expect(try restored.with { ops, _ in try ops.verifySearchIndex() }.isHealthy, "in step as it lands")
        #expect(try Self.answers(restored.db, ["cormorant"])["cormorant"] == [], "control: the copy predates the edit")
        let dropped = try await restored.withAsync { _ in
            try await PurgeJanitor(transport: server, keyProvider: restored.keyProvider).reconcileLedger()
        }
        #expect(dropped > 0, "control: the ledger removed the purged family")
        try await round(restored)
        try await round(restored)
        try await round(a)

        let report = try restored.with { ops, _ in try ops.verifySearchIndex() }
        #expect(report.isHealthy, "in step after the catch-up: \(report)")
        #expect(try Self.answers(restored.db, ["cormorant"])["cormorant"] == ["take"], "the later edit is findable")
        #expect(try Self.answers(restored.db, ["leave", "good"]).values.allSatisfy(\.isEmpty),
                "neither deleted note's words are findable")
        #expect(try Self.docFacts(restored.db) == Self.docFacts(a.db), "the same docs as the library it caught up with")
    }
}
