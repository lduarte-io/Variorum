import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5 — the SURFACES scope by wing (the sitting record §9: "nothing
/// should cross wings … search/tag listings/Arrivals all scope by wing"; her
/// 2026-08-25 per-library Archived AND Trash). Each read takes an additive
/// `wingID` (nil = every wing, byte-identical — the phone and every existing
/// caller); the dangling-wing rule makes a deleted wing's Trash rows list in
/// Home's Trash, and a Put back re-homes them.
@Suite("13i-d U5 — the scoped reads")
struct WingScopedReadsTests {
    /// Home holds `home`; the wing holds `away`. Both have a block.
    private func twoLibraries(_ ops: Operations) throws
        -> (wing: Wing, home: Container, away: Container)
    {
        let wing = try ops.createWing(name: "Imports")
        let home = try ops.createPost(title: "home note")
        _ = try ops.newBlock(in: home.id, text: "home words", at: .end)
        let away = try ops.createPost(title: "away note", wingId: wing.id)
        _ = try ops.newBlock(in: away.id, text: "away words", at: .end)
        return (wing, home, away)
    }

    @Test func theLibraryListingIsOneWings() throws {
        try withOperations { ops, db in
            let w = try twoLibraries(ops)
            let home = try db.read { try Queries.library($0, wingID: "") }.map(\.postID)
            let away = try db.read { try Queries.library($0, wingID: w.wing.id) }.map(\.postID)
            let all = try db.read { try Queries.library($0) }.map(\.postID)
            #expect(home == [w.home.id])
            #expect(away == [w.away.id])
            #expect(Set(all) == [w.home.id, w.away.id], "nil = every wing")
        }
    }

    /// Search (the Library catalog and ⌘K): books, notes and named blocks of
    /// ONE wing; snippet hits list in every wing (P-13id-U5-4).
    @Test func searchScopesEveryArmButSnippets() throws {
        try withOperations { ops, db in
            let w = try twoLibraries(ops)
            _ = try ops.createReading(name: "Atlas home", kind: .book)
            _ = try ops.createReading(name: "Atlas away", kind: .book, wingId: w.wing.id)
            let awayBlock = try ops.newBlock(in: w.away.id, text: "x", at: .end)
            try ops.setBlockName(awayBlock.block.id, name: "atlas block")
            let pool = try ops.createPool(title: "scraps")
            _ = try ops.newBlock(in: pool.id, text: "atlas scrap", at: .end)
            let homeHits = try db.read {
                try Queries.searchCatalog($0, query: "atlas", wingID: "")
            }
            #expect(homeHits.filter { $0.kind == .book }.map(\.title) == ["Atlas home"])
            #expect(homeHits.filter { $0.kind == .block }.map(\.title) == ["atlas scrap"])
            let awayHits = try db.read {
                try Queries.searchCatalog($0, query: "atlas", wingID: w.wing.id)
            }
            #expect(awayHits.filter { $0.kind == .book }.map(\.title) == ["Atlas away"])
            #expect(Set(awayHits.filter { $0.kind == .block }.map(\.title))
                    == ["atlas block", "atlas scrap"])
            let notes = try db.read { try Queries.searchCatalog($0, query: "note", wingID: "") }
            #expect(notes.filter { $0.kind == .post }.map(\.id) == [w.home.id])
        }
    }

    /// The Pool is "every note with no book" IN THIS LIBRARY; a gathering
    /// tucks only its own wing's notes.
    @Test func thePoolIsOneWingsBooklessNotes() throws {
        try withOperations { ops, db in
            let w = try twoLibraries(ops)
            let homePool = try db.read { try Queries.notePoolListing($0, window: 10, wingID: "") }
            #expect(homePool.loose.map(\.postID) == [w.home.id])
            let awayTag = try ops.createTag(name: "topic", wingID: w.wing.id)
            try ops.applyTag(awayTag.id, toPost: w.away.id)
            _ = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(awayTag.id)),
                wingId: w.wing.id)
            let awayPool = try db.read {
                try Queries.notePoolListing($0, window: 10, wingID: w.wing.id)
            }
            #expect(awayPool.loose.isEmpty)
            #expect(awayPool.tucked.map(\.postID) == [w.away.id])
            #expect(try db.read { try Queries.notePoolListing($0, window: 10, wingID: "") }.tuckedCount
                    == 0, "the other wing's gathering tucks nothing in Home")
        }
    }

    @Test func archivedAndReadingsAndStarsAndPickersArePerWing() throws {
        try withOperations { ops, db in
            let w = try twoLibraries(ops)
            try ops.archiveContainer(w.home.id)
            try ops.archiveContainer(w.away.id)
            #expect(try db.read { try Queries.archivedPosts($0, wingID: "") }.map(\.postID)
                    == [w.home.id])
            #expect(try db.read { try Queries.archivedPosts($0, wingID: w.wing.id) }.map(\.postID)
                    == [w.away.id])
            try ops.unarchiveContainer(w.home.id)
            try ops.unarchiveContainer(w.away.id)

            let homeBook = try ops.createReading(name: "home book", kind: .book)
            let awayBook = try ops.createReading(name: "away book", kind: .book, wingId: w.wing.id)
            #expect(try db.read { try Queries.readings($0, wingID: "") }.map(\.id) == [homeBook.id])
            #expect(try db.read { try Queries.readings($0, wingID: w.wing.id) }.map(\.id)
                    == [awayBook.id])

            try ops.setStarred(.post(w.home.id), starred: true)
            try ops.setStarred(.post(w.away.id), starred: true)
            try ops.setStarred(.reading(awayBook.id), starred: true)
            #expect(try db.read { try Queries.starred($0, wingID: "") }.map(\.target.id)
                    == [w.home.id])
            #expect(try db.read { try Queries.starred($0, wingID: w.wing.id) }.map(\.target.id)
                    == [w.away.id, awayBook.id])

            let picked = try db.read {
                try Queries.notePickerNotes($0, query: "", wingID: w.wing.id)
            }
            #expect(picked.map(\.id) == [w.away.id])
        }
    }

    /// The per-wing Trash; a deleted wing's Trash rows list in HOME's Trash
    /// (the dangling rule), and a Put back RE-HOMES them.
    @Test func theTrashIsPerWingAndADeletedWingsRowsComeHome() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Brief")
            let gone = try ops.createPost(title: "gone", wingId: wing.id)
            _ = try ops.newBlock(in: gone.id, text: "words", at: .end)
            let book = try ops.createReading(name: "brief book", kind: .book, wingId: wing.id)
            try ops.deleteContainer(gone.id)
            try ops.deleteReading(book.id)
            func trashIDs(_ wingID: String) throws -> Set<String> {
                Set(try db.read {
                    try Queries.trash($0, now: harnessNow, wingID: wingID)
                }.map(\.id))
            }
            #expect(try trashIDs(wing.id) == [gone.id, book.id])
            #expect(try trashIDs("").isEmpty)
            try ops.deleteWing(wing.id)
            #expect(try trashIDs("") == [gone.id, book.id], "a dead wing's rows list in Home")
            try ops.restoreContainer(gone.id)
            try ops.restoreReading(book.id)
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [gone.id]) == "")
            #expect(try db.fetchString("SELECT wing_id FROM reading WHERE id = ?", [book.id]) == "")
            #expect(try db.read { try Queries.library($0, wingID: "") }.map(\.postID)
                    == [gone.id])
        }
    }
}
