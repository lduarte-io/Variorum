//
//  SearchP1Tests.swift
//  VariorumCoreTests
//
//  13o U1, P8 — P1 for the search family, as SHAPE facts (17c's standard:
//  never a timing — SQLite's own deterministic counters). The counter here is
//  PAGE REQUESTS through the pager (`SQLITE_DBSTATUS_CACHE_HIT + _MISS` on
//  the connection) — what FTS5's C code reads, which VM-step counters cannot
//  see. Two corpora of the same shape, the second 5× the first:
//
//  1. the INDEX UPDATE an autosave pays is ∝ the edit — flat across corpus
//     size (the capture triggers + FTS5's own merge work, amortized);
//  2. a QUERY's cost is ∝ its matches — a term matching the same fixed docs
//     costs the same in both corpora, and the keystroke road (a type-ahead
//     prefix with a fixed match set) is bounded the same way;
//  3. the INTEGRITY CHECK sees a source text changed behind the index's back
//     (the architect's addition at seam 2 — the bench probe, now a pin).
//
//  Numbers print as `[13o-P1]` lines; the U1 RECORD carries them.
//

import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private func pageRequests(_ db: Database, reset: Bool) -> Int {
    var hit: Int32 = 0, miss: Int32 = 0, high: Int32 = 0
    sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_HIT, &hit, &high, reset ? 1 : 0)
    sqlite3_db_status(db.sqliteConnection, SQLITE_DBSTATUS_CACHE_MISS, &miss, &high, reset ? 1 : 0)
    return Int(hit) + Int(miss)
}

/// A corpus of `notes × 10` placed single-take blocks through the REAL
/// schema with the capture triggers live (the index grows incrementally, as
/// hers does). Every block says "the"; filler words vary deterministically;
/// the same 20 PROBE blocks (the first two notes) say "zanzibar" and
/// "quokkaprobe" in every corpus — so a probe's match set is fixed while the
/// corpus grows.
private func corpus(notes: Int) throws -> AppDatabase {
    let db = try AppDatabase.inMemory()
    try db.write { db in
        try db.execute(sql: "INSERT INTO _sync_applying VALUES (1)") // no outbox rows: a bench bed
        try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
        let now = "2026-10-06T00:00:00.000Z"
        let note = try db.makeStatement(sql: """
            INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)
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
        var seed: UInt64 = 7
        func word() -> String {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return "w\((seed >> 33) % 5_000)"
        }
        for n in 0..<notes {
            let noteID = String(format: "n%06d", n)
            try note.execute(arguments: [noteID, "note \(n)", now, now])
            for b in 0..<10 {
                let blockID = "\(noteID)-b\(b)"
                let probe = n < 2 ? " zanzibar quokkaprobe" : ""
                let text = "the " + (0..<40).map { _ in word() }.joined(separator: " ") + probe
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

/// Average page requests of `count` autosave-shaped edits to the probe take
/// (each its own transaction — autosave's shape).
private func editCost(_ db: AppDatabase, count: Int) throws -> Double {
    var total = 0
    for i in 0..<count {
        try db.write { db in
            _ = pageRequests(db, reset: true)
            try db.execute(sql: "UPDATE variant SET working_text = working_text || ?, updated_at = ? WHERE id = 'n000000-b0-v'",
                           arguments: [" edit\(i)", "2026-10-06T00:00:01.000Z"])
            total += pageRequests(db, reset: false)
        }
    }
    return Double(total) / Double(count)
}

/// Page requests of one `searchPassages` call.
private func queryCost(_ db: AppDatabase, _ text: String) throws -> (pages: Int, hits: Int) {
    try db.read { db in
        let query = SearchQueryParser.parse(text, locale: Locale(identifier: "en_US"))
        _ = pageRequests(db, reset: true)
        let page = try Queries.searchPassages(db, query: query, scope: SearchScope(wingID: ""), limit: 50)
        return (pageRequests(db, reset: false), page.passages.count)
    }
}

@Suite("13o — P1: the search family's cost shape", .serialized)
struct SearchP1Tests {
    @Test func theIndexUpdateIsFlatAndQueriesTrackTheirMatchesNotTheCorpus() throws {
        let small = try corpus(notes: 200)   // 2,000 blocks
        let large = try corpus(notes: 1_000) // 10,000 blocks — 5×

        // 1 — the update an autosave pays.
        let smallEdit = try editCost(small, count: 60)
        let largeEdit = try editCost(large, count: 60)
        print("[13o-P1] autosave pages/edit: 2k blocks \(smallEdit) · 10k blocks \(largeEdit)")
        #expect(largeEdit <= smallEdit * 1.5, "the index update is ∝ the edit, flat across a 5× corpus")

        // 2 — a fixed match set costs the same in both corpora (rare word,
        // two-word AND, and the keystroke road: a type-ahead prefix).
        for probe in ["zanzibar ", "zanzibar quokkaprobe ", "quokkapr"] {
            let s = try queryCost(small, probe)
            let l = try queryCost(large, probe)
            print("[13o-P1] query '\(probe)': 2k blocks \(s.pages) pages / \(s.hits) hits · 10k blocks \(l.pages) pages / \(l.hits) hits")
            #expect(s.hits == 20 && l.hits == 20, "the 20 probe takes, in both corpora")
            // Fixed matches, 5× the corpus: the residue is LOGARITHMIC — every
            // B-tree seek per match (doc, placement, container, block) and
            // FTS5's segment levels deepen by about one page as the tables
            // grow. A corpus-proportional cost would be ≥ 5×.
            #expect(Double(l.pages) <= Double(s.pages) * 2,
                    "'\(probe)': cost tracks the matches (fixed) × log, never the corpus (5×)")
        }

        // …and a term that matches EVERY block grows with its matches —
        // the cost class is the answer's size (no capped walk pretends
        // otherwise).
        let sAll = try queryCost(small, "the ")
        let lAll = try queryCost(large, "the ")
        print("[13o-P1] query 'the' (every block): 2k blocks \(sAll.pages) pages · 10k blocks \(lAll.pages) pages")
        #expect(Double(lAll.pages) > Double(sAll.pages) * 3, "∝ matches: 5× the matches, several × the pages")
    }

    // MARK: - The integrity check sees drift (the architect's seam-2 addition)

    /// RED-ON-OLD by construction: a source text changed BEHIND the index's
    /// back (the capture trigger dropped for one write) — the doc set is still
    /// whole, but FTS5's index-vs-content check (against the SOURCE rows, F1)
    /// fails; the rebuild door heals it and the new words become findable.
    @Test func theIntegrityCheckCatchesASourceChangedBehindTheIndexsBack() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Drift")
            let minted = try ops.newBlock(in: post.id, text: "the original words")
            #expect(try ops.verifySearchIndex().isHealthy, "control: healthy before")

            try db.write { db in
                try db.execute(sql: "DROP TRIGGER search_variant_take_update")
                try db.execute(sql: "UPDATE variant SET working_text = 'entirely different prose' WHERE id = ?",
                               arguments: [minted.variant.id])
            }
            let report = try ops.verifySearchIndex()
            #expect(report.missing.isEmpty && report.orphaned.isEmpty && report.factDrift.isEmpty,
                    "the doc set is still whole — only the TEXT drifted")
            #expect(!report.indexMatchesContent, "the index no longer matches the source text — detected")
            #expect(!report.isHealthy)
            #expect(try searchHits(db, "different").isEmpty, "the drifted words are not findable yet")

            #expect(try ops.rebuildSearchIndex().isHealthy, "the rebuild door heals from truth")
            #expect(try searchHits(db, "different") == ["take:\(minted.variant.id)"])
            #expect(try searchHits(db, "original").isEmpty)
        }
    }
}
