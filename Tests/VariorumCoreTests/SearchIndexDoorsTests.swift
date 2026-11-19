//
//  SearchIndexDoorsTests.swift
//  VariorumCoreTests
//
//  VX-79 (the VX-980 run, batch 2) — the two maintenance doors Settings ▸ Data Safety's new row presses, pinned at the
//  contract the row's words promise: CHECK WRITES NOTHING (healthy or not — it reports, it never heals), and REBUILD's
//  answer IS the state it leaves. The doors themselves were built and pinned at 13o U1 P5 (`SearchIndexCaptureTests`
//  pins idempotence and that the rebuild heals every drift class); these pins are the face's promises, on a real
//  on-disk WAL store like the app's.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-79 — the search index's doors: Check writes nothing; Rebuild's answer is the state it leaves")
struct SearchIndexDoorsTests {
    final class Folder {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx79-doors-\(UUID().uuidString)", isDirectory: true)
        init() { try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
        deinit { try? FileManager.default.removeItem(at: url) }
    }

    /// Every row of every STORED table (the index's shadow tables, `sqlite_sequence` and the outbox included), as a
    /// sorted dump — what "writes nothing" is measured against.
    static func everyStoredRow(_ database: AppDatabase) throws -> [String] {
        try database.read { db in
            let tables = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'table' AND rootpage > 0 ORDER BY name
                """)
            var lines: [String] = []
            for table in tables {
                let quoted = table.replacingOccurrences(of: "\"", with: "\"\"")
                for row in try Row.fetchAll(db, sql: "SELECT * FROM \"\(quoted)\"") {
                    lines.append("\(table)|\(row)")
                }
            }
            return lines.sorted()
        }
    }

    /// SQLite's own change counter, read from a SECOND connection: it moves when any other connection commits a
    /// change to the file — and only then.
    static func dataVersion(_ probe: DatabaseQueue) throws -> Int {
        try probe.read { try Int.fetchOne($0, sql: "PRAGMA data_version") ?? -1 }
    }

    @Test func theCheckWritesNothingWhetherTheIndexIsInStepOrNot() throws {
        let folder = Folder()
        let url = folder.url.appendingPathComponent("variorum.sqlite")
        let database = try AppDatabase.onDisk(url: url, key: nil)
        try SearchIndexRestoreRoadsTests.ops(database) { try SearchIndexRestoreRoadsTests.writeEveryKind($0) }
        let probe = try DatabaseQueue(path: url.path)
        defer { try? probe.close() }

        // In step: the check answers healthy and leaves every byte of the store where it was.
        let before = try Self.everyStoredRow(database)
        let version = try Self.dataVersion(probe)
        let healthy = try SearchIndexRestoreRoadsTests.check(database)
        #expect(healthy.isHealthy && healthy.docCount > 0)
        #expect(try Self.everyStoredRow(database) == before, "no row of any table moved")
        #expect(try Self.dataVersion(probe) == version, "no change was committed to the file at all")

        // Out of step (a doc gone, a text changed behind the index's back): the check SAYS so and heals nothing.
        try database.write { db in
            try db.execute(sql: "DELETE FROM search_doc WHERE kind = 'comment'")
            try db.execute(sql: "DROP TRIGGER search_variant_take_update")
            try db.execute(sql: "UPDATE variant SET working_text = 'changed behind its back' WHERE rowid = (SELECT min(rowid) FROM variant)")
        }
        let broken = try Self.everyStoredRow(database)
        let brokenVersion = try Self.dataVersion(probe)
        let found = try SearchIndexRestoreRoadsTests.check(database)
        #expect(!found.isHealthy && found.missing.count == 1 && !found.indexMatchesContent,
                "the check names what it found: \(found)")
        #expect(try Self.everyStoredRow(database) == broken, "the check healed nothing — it only reports")
        #expect(try Self.dataVersion(probe) == brokenVersion, "and committed nothing")
        #expect(try SearchIndexRestoreRoadsTests.check(database) == found, "asked again, the same answer")
    }

    @Test func theRebuildsAnswerIsTheStateItLeaves() throws {
        let folder = Folder()
        let url = folder.url.appendingPathComponent("variorum.sqlite")
        let database = try AppDatabase.onDisk(url: url, key: nil)
        try SearchIndexRestoreRoadsTests.ops(database) { try SearchIndexRestoreRoadsTests.writeEveryKind($0) }
        try database.write { db in
            try db.execute(sql: "DELETE FROM search_doc WHERE kind = 'title'")
            try db.execute(sql: "INSERT INTO search_doc (kind, src_id) VALUES ('take', 'no-such-take')")
        }
        let outbox = try database.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sync_outbox") ?? 0 }
        #expect(try !SearchIndexRestoreRoadsTests.check(database).isHealthy, "control: out of step")

        let rebuilt = try SearchIndexRestoreRoadsTests.ops(database) { try $0.rebuildSearchIndex() }
        #expect(rebuilt.isHealthy, "the rebuild heals from the notes")
        #expect(try SearchIndexRestoreRoadsTests.check(database) == rebuilt,
                "what the rebuild answers is exactly what a check then finds")
        #expect(try database.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sync_outbox") ?? 0 } == outbox,
                "nothing synced was written — the index is this Mac's own")
        let title = SearchIndexRestoreRoadsTests.Word.title
        let answers = try SearchIndexRestoreRoadsTests.answers(database, [title])
        #expect(answers[title] == ["title"], "the lost title is findable again")
    }
}
