//
//  SearchGatheringScopeMeasurementTests.swift
//  VariorumCoreTests
//
//  13o U3, piece P1 — THE GATHERING-SCOPE MEASUREMENT (the brief's item 2:
//  "PROPOSE the mechanism (rule → member-id predicate vs join) with a
//  measurement line before building"). A MEASUREMENT BENCH, not a pin: gated
//  behind `VARIORUM_SEARCH_MEASURE=1` (U1's bench gate — a skipped Swift
//  Testing test still counts in "N tests"; read the skipped lines). Its
//  numbers are recorded in the 13o plan's U3 RECORD.
//
//  The two mechanisms, each measured as PAGE REQUESTS (SQLite's own
//  deterministic pager counters, the P1 suite's discipline) over two corpora
//  of one shape, the second 5× the first:
//
//  - **A — the member-id predicate:** the gathering's assembly runs FIRST
//    (`Queries.assembleReading` — the one assembly road, verbatim) and its ids
//    reach the hits walk as an uncorrelated `c.id IN (json_each(…))` set —
//    the book scope's own shape (a membership IN-list), the assembly standing
//    in for the rows.
//  - **B — the join:** the gathering's assembly CONDITIONS (the rule's SQL
//    from its one home, `ruleMatchSQL`, plus the gathering arm's ambient
//    clauses) are composed into the hits walk over the home container `c`,
//    so the rule is evaluated per examined MATCH.
//

import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private let measuring = ProcessInfo.processInfo.environment["VARIORUM_SEARCH_MEASURE"] == "1"

private func pages(_ db: Database, reset: Bool) -> Int {
    var hit: Int32 = 0, miss: Int32 = 0, high: Int32 = 0
    sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_HIT, &hit, &high, reset ? 1 : 0)
    sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_MISS, &miss, &high, reset ? 1 : 0)
    return Int(hit) + Int(miss)
}

/// `notes × 10` single-take blocks; every 10th note tagged `#dream` (the
/// gathering's rule); every block says "the"; a MID term in every 25th
/// block; the RARE probe in the first two notes' blocks (one inside the
/// gathering, one outside — n0 is tagged, n1 is not).
private func corpus(notes: Int) throws -> AppDatabase {
    let db = try AppDatabase.inMemory()
    try db.write { db in
        try db.execute(sql: "INSERT INTO _sync_applying VALUES (1)")
        try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
        let now = "2026-10-07T00:00:00.000Z"
        try db.execute(sql: """
            INSERT INTO tag (id, name, path, created_at, updated_at) VALUES ('tag-dream', 'dream', 'dream', ?, ?)
            """, arguments: [now, now])
        try db.execute(sql: """
            INSERT INTO reading (id, name, kind, query_spec, created_at, updated_at)
            VALUES ('g-dream', 'dream gathering', 'gathering', '{"tag":"tag-dream"}', ?, ?)
            """, arguments: [now, now])
        let note = try db.makeStatement(sql: """
            INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)
            """)
        let tagged = try db.makeStatement(sql: """
            INSERT INTO post_tag (id, tag_id, post_id, created_at) VALUES (?, 'tag-dream', ?, ?)
            """)
        let block = try db.makeStatement(sql: """
            INSERT INTO block (id, default_variant_id, created_at, updated_at) VALUES (?, ?, ?, ?)
            """)
        let take = try db.makeStatement(sql: """
            INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at)
            VALUES (?, ?, ?, 'a0', ?, ?)
            """)
        let place = try db.makeStatement(sql: """
            INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """)
        var seed: UInt64 = 11
        func word() -> String {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return "w\((seed >> 33) % 5_000)"
        }
        var blockCount = 0
        for n in 0..<notes {
            let noteID = String(format: "n%06d", n)
            try note.execute(arguments: [noteID, "note \(n)", now, now])
            if n % 10 == 0 { try tagged.execute(arguments: [noteID + "-t", noteID, now]) }
            for b in 0..<10 {
                let blockID = "\(noteID)-b\(b)"
                blockCount += 1
                let probe = n < 2 ? " zanzibar" : ""
                let mid = blockCount % 25 == 0 ? " midterm" : ""
                let text = "the " + (0..<40).map { _ in word() }.joined(separator: " ") + probe + mid
                try block.execute(arguments: [blockID, blockID + "-v", now, now])
                try take.execute(arguments: [blockID + "-v", blockID, text, now, now])
                try place.execute(arguments: [blockID + "-p", noteID, blockID, String(format: "a%02d", b),
                                              blockID + "-v", now, now])
            }
        }
        try db.execute(sql: "DELETE FROM _sync_applying")
    }
    return db
}

/// `?` placeholders inlined as SQL literals (a bench convenience — the
/// composer's `extra` conditions carry no arguments).
private func inline(_ sql: String, _ arguments: [(any DatabaseValueConvertible)?]) -> String {
    var out = ""
    var rest = arguments.makeIterator()
    for ch in sql {
        if ch == "?", let value = rest.next() {
            switch value?.databaseValue.storage {
            case .string(let s): out += "'" + s.replacingOccurrences(of: "'", with: "''") + "'"
            case .int64(let i): out += String(i)
            default: out += "NULL"
            }
        } else {
            out.append(ch)
        }
    }
    return out
}

/// One measured search: the hits walk ranked to a 50-row page (the cost the
/// page, group and counts statements all share — snippets are page-bound).
private func walk(
    _ db: Database, _ text: String, extra: [String]
) throws -> (pages: Int, rows: Int) {
    let query = SearchQueryParser.parse(text, locale: Locale(identifier: "en_US"))
    let environment = try Queries.searchEnvironment(db)
    guard let hits = try SearchComposer.hits(
        query, scope: SearchScope(wingID: ""), visibility: .living, extra: extra, environment: environment)
    else { return (0, 0) }
    let sql = "WITH hits AS (\(hits.sql)) SELECT doc_id FROM hits ORDER BY bm, doc_id LIMIT 50"
    _ = pages(db, reset: true)
    let rows = try Row.fetchAll(db, sql: sql, arguments: Queries.arguments(hits.arguments))
    return (pages(db, reset: false), rows.count)
}

@Suite("13o U3 — the gathering-scope measurement (gated)", .enabled(if: measuring), .serialized)
struct SearchGatheringScopeMeasurementTests {
    @Test func memberIDPredicateVersusTheJoin() throws {
        for notes in [1_000, 5_000] {
            let db = try corpus(notes: notes)
            try db.read { db in
                let reading = try #require(try Queries.reading(db, id: "g-dream"))
                guard case .rule(let term) = RuleGrammar.read(reading.querySpec) else {
                    Issue.record("the bench gathering's rule must read"); return
                }

                // A — the assembly first, then its ids as the walk's set.
                _ = pages(db, reset: true)
                let assembled = try Queries.assembleReading(db, readingID: reading.id)
                let assemblyPages = pages(db, reset: false)
                let json = String(decoding: try JSONEncoder().encode(assembled.map(\.postID)), as: UTF8.self)
                let memberSet = "c.id IN (SELECT value FROM json_each('\(json)'))"

                // B — the assembly's conditions composed per match.
                let match = Queries.ruleMatchSQL(term, wingID: reading.wingId, starredNoteIDs: [])
                let joined = [inline(match.conditions.joined(separator: " AND "), match.arguments)]

                print("[13o-U3-gather] \(notes * 10) blocks · \(assembled.count) assembled notes · "
                      + "assembly alone \(assemblyPages) pages")
                for probe in ["zanzibar ", "midterm ", "the "] {
                    let library = try walk(db, probe, extra: [])
                    let a = try walk(db, probe, extra: [memberSet])
                    let b = try walk(db, probe, extra: ["c.archived_at IS NULL", "c.kind = 'post'"] + joined)
                    #expect(a.rows == b.rows, "both mechanisms answer the same page")
                    print("[13o-U3-gather]   '\(probe)': library walk \(library.pages) pages · "
                          + "A (assembly + set) \(assemblyPages) + \(a.pages) = \(assemblyPages + a.pages) pages · "
                          + "B (join) \(b.pages) pages · page rows \(a.rows)")
                }
            }
        }
    }
}
