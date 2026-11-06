//
//  TagWearersListingTests.swift
//  VariorumCoreTests
//
//  VX-827 U2 (VX-810's source) — `Queries.notesWearingTag`: the notes wearing
//  the tag at a path, or a tag under it, on the note itself or on a block it
//  places (THE ONE wearer rule `tagSubtreeIsWorn` reads — `tagWearersSQL`),
//  the subtree exactly as the rule grammar's (`tagSubtree`), the path resolved
//  in one wing or in every wing (`liveTagIDs`); and `Queries.wornTags`, many
//  notes' own tags at once. Exact rows, then the P1 pins: the listing's work is
//  flat as the LIBRARY grows (notes, blocks, other tags and their applications)
//  and linear in the tag's own wearers; its wearer reads never scan a store
//  table.
//

import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

private final class WearerInstructionCounter: @unchecked Sendable { var value = 0 }

/// Every SQLite VM instruction the connection executes while `body` runs.
private func instructions(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> Int {
    try db.read { database in
        let counter = WearerInstructionCounter()
        let context = Unmanaged.passRetained(counter).toOpaque()
        defer { Unmanaged<WearerInstructionCounter>.fromOpaque(context).release() }
        sqlite3_progress_handler(database.sqliteConnection, 1, { pointer in
            guard let pointer else { return 0 }
            Unmanaged<WearerInstructionCounter>.fromOpaque(pointer).takeUnretainedValue().value += 1
            return 0
        }, context)
        defer { sqlite3_progress_handler(database.sqliteConnection, 0, nil, nil) }
        try body(database)
        return counter.value
    }
}

/// The joined query plan of every SELECT `body` ran.
private func capturedPlan(_ db: AppDatabase, _ body: (Database) throws -> Void) throws -> String {
    let statements: [String] = try db.read { database in
        let captured = LockIsolated<[String]>([])
        let capturing = LockIsolated(true)
        database.trace(options: .statement) { event in
            guard capturing.value, case .statement(let statement) = event else { return }
            let sql = statement.expandedSQL
            captured.withValue { $0.append(sql) }
        }
        try body(database)
        capturing.setValue(false)
        return captured.value.filter {
            let head = $0.trimmingCharacters(in: .whitespacesAndNewlines).prefix(6).uppercased()
            return head.hasPrefix("SELECT") || head.hasPrefix("WITH")
        }
    }
    return try db.read { database in
        try statements.flatMap { sql in
            try Row.fetchAll(database, sql: "EXPLAIN QUERY PLAN \(sql)")
                .map { ($0["detail"] as String?) ?? "" }
        }.joined(separator: "\n")
    }
}

private func wearers(_ db: AppDatabase, _ path: String, in wing: String?) throws -> [String] {
    try db.read { try Queries.notesWearingTag($0, path: path, wingID: wing) }
}

@Suite("VX-827 U2 — the notes wearing a tag: the one wearer rule, listed")
struct TagWearersListingTests {

    // MARK: - Exact rows

    /// A note wears a tag ITSELF or through a LIVE block it PLACES; a snippet
    /// (a pool's block), a deleted block, a dead note and a
    /// removed application wear nothing a note does.
    @Test func aNoteWearsItItselfOrThroughABlockItPlaces() throws {
        try withOperations { ops, db in
            let quote = try ops.createTag(name: "quote")
            let itself = try ops.createPost(title: "itself")
            _ = try ops.applyTag(quote.id, toPost: itself.id)
            let byBlock = try ops.createPost(title: "by its block")
            let placed = try ops.newBlock(in: byBlock.id, text: "A line.", registeringUndo: false)
            _ = try ops.applyTag(quote.id, toBlock: placed.block.id)
            let pool = try ops.createPool(title: "Snippets")
            let scrap = try ops.newBlock(in: pool.id, text: "A scrap.", registeringUndo: false)
            _ = try ops.applyTag(quote.id, toBlock: scrap.block.id)
            let deletedBlockNote = try ops.createPost(title: "its block deleted")
            let gone = try ops.newBlock(in: deletedBlockNote.id, text: "Gone.", registeringUndo: false)
            _ = try ops.applyTag(quote.id, toBlock: gone.block.id)
            try ops.deleteBlock(gone.block.id)
            let dead = try ops.createPost(title: "dead")
            _ = try ops.applyTag(quote.id, toPost: dead.id)
            try ops.deleteContainer(dead.id)
            let untagged = try ops.createPost(title: "untagged")
            _ = try ops.applyTag(quote.id, toPost: untagged.id)
            try ops.removeTag(quote.id, fromPost: untagged.id)

            #expect(try wearers(db, "quote", in: "") == [itself.id, byBlock.id].sorted())
            #expect(try wearers(db, "quote", in: nil) == [itself.id, byBlock.id].sorted())
        }
    }

    /// The subtree is the rule grammar's: a path lists its own tag's wearers
    /// and every tag's under it — never a parent's, never a mere prefix of a
    /// segment; a path no live tag holds, and a dead tag's, list nothing.
    @Test func theSubtreeMatchesAsTheRuleGrammarDoes() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let deep = try ops.createTag(parent: goals.id, name: "2024")
            let lifestyle = try ops.createTag(name: "lifestyle")
            func tagged(_ title: String, _ tag: String) throws -> String {
                let note = try ops.createPost(title: title)
                _ = try ops.applyTag(tag, toPost: note.id)
                return note.id
            }
            let onLife = try tagged("on life", life.id)
            let onGoals = try tagged("on goals", goals.id)
            let onDeep = try tagged("on 2024", deep.id)
            _ = try tagged("on lifestyle", lifestyle.id)

            #expect(try wearers(db, "life", in: "") == [onLife, onGoals, onDeep].sorted())
            #expect(try wearers(db, "life/goals", in: "") == [onGoals, onDeep].sorted())
            #expect(try wearers(db, "life/goals/2024", in: "") == [onDeep])
            #expect(try wearers(db, "lif", in: "").isEmpty, "a prefix of a segment is no subtree")
            #expect(try wearers(db, "goals", in: "").isEmpty, "a child's name alone is no path")
            #expect(try wearers(db, "nothing/here", in: "").isEmpty)
            try ops.deleteTag(goals.id)
            #expect(try wearers(db, "life/goals", in: "").isEmpty, "a dead tag's path holds nothing")
            #expect(try wearers(db, "life", in: "") == [onLife], "the dead subtree's wearers left with it")
        }
    }

    /// The path resolves in ONE wing (another wing's same-path twin is another
    /// tag) or, nil, in EVERY wing; a dead wing's tags read as Home's.
    @Test func thePathResolvesInOneWingOrInEvery() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "Studio")
            let homeIdea = try ops.createTag(name: "idea")
            let studioIdea = try ops.createTag(name: "idea", wingID: studio.id)
            let atHome = try ops.createPost(title: "at home")
            _ = try ops.applyTag(homeIdea.id, toPost: atHome.id)
            let inStudio = try ops.createPost(title: "in the studio", wingId: studio.id)
            _ = try ops.applyTag(studioIdea.id, toPost: inStudio.id)
            let attic = try ops.createWing(name: "Attic")
            let atticIdea = try ops.createTag(name: "idea", wingID: attic.id)
            let inAttic = try ops.createPost(title: "in the attic", wingId: attic.id)
            _ = try ops.applyTag(atticIdea.id, toPost: inAttic.id)

            #expect(try wearers(db, "idea", in: "") == [atHome.id])
            #expect(try wearers(db, "idea", in: studio.id) == [inStudio.id])
            #expect(try wearers(db, "idea", in: nil) == [atHome.id, inStudio.id, inAttic.id].sorted())
            #expect(try db.read { try Queries.liveTagIDs($0, path: "idea", wingID: nil) }
                    == [homeIdea.id, studioIdea.id, atticIdea.id].sorted())

            // A dead wing (a tombstone a sync could leave): its tags read as
            // Home's, as its notes list under Home.
            try db.write { try $0.execute(sql: "UPDATE wing SET deleted_at = '2026-06-30T00:00:00.000Z' WHERE id = ?",
                                          arguments: [attic.id]) }
            #expect(try wearers(db, "idea", in: "") == [atHome.id, inAttic.id].sorted())
            #expect(try wearers(db, "idea", in: studio.id) == [inStudio.id])
        }
    }

    /// `wornTags`: each note's OWN live tags by path, then id — never a block's,
    /// never a removed application or a dead tag; a note wearing none absent.
    @Test func wornTagsAreEachNotesOwnByPath() throws {
        try withOperations { ops, db in
            let zebra = try ops.createTag(name: "zebra")
            let apple = try ops.createTag(name: "apple")
            let pear = try ops.createTag(parent: apple.id, name: "pear")
            let gone = try ops.createTag(name: "gone")
            let removed = try ops.createTag(name: "removed")
            let note = try ops.createPost(title: "n")
            for tag in [zebra.id, pear.id, apple.id, gone.id, removed.id] { _ = try ops.applyTag(tag, toPost: note.id) }
            try ops.removeTag(removed.id, fromPost: note.id)
            try ops.deleteTag(gone.id)
            let block = try ops.newBlock(in: note.id, text: "x", registeringUndo: false)
            _ = try ops.applyTag(zebra.id, toBlock: block.block.id)
            let blockOnly = try ops.createPost(title: "block only")
            let placed = try ops.newBlock(in: blockOnly.id, text: "y", registeringUndo: false)
            _ = try ops.applyTag(apple.id, toBlock: placed.block.id)
            let bare = try ops.createPost(title: "bare")

            let worn = try db.read { try Queries.wornTags($0, noteIDs: [note.id, blockOnly.id, bare.id]) }
            #expect(worn[note.id] == [
                .init(id: apple.id, path: "apple"), .init(id: pear.id, path: "apple/pear"),
                .init(id: zebra.id, path: "zebra"),
            ])
            #expect(worn[blockOnly.id] == nil, "a block's tag is the block's")
            #expect(worn[bare.id] == nil)
            #expect(try db.read { try Queries.wornTags($0, noteIDs: []) }.isEmpty)
            // The single-note read the document header uses agrees.
            #expect(try db.read { try Queries.postTags($0, postID: note.id) }.map(\.path) == worn[note.id]?.map(\.path))
        }
    }

    // MARK: - P1

    /// A library of `notes` notes, each with a block, half tagged with an
    /// unrelated tag (post and block) — and `wearing` notes wearing #quote.
    private func library(_ ops: Operations, notes: Int, wearing: Int) throws {
        let other = try ops.createTag(name: "other")
        let quote = try ops.createTag(name: "quote")
        for n in 0..<notes {
            let note = try ops.createPost(title: "library \(n)")
            let block = try ops.newBlock(in: note.id, text: "Library words \(n).", registeringUndo: false)
            if n % 2 == 0 {
                _ = try ops.applyTag(other.id, toPost: note.id)
                _ = try ops.applyTag(other.id, toBlock: block.block.id)
            }
        }
        for n in 0..<wearing {
            let note = try ops.createPost(title: "wearer \(n)")
            let block = try ops.newBlock(in: note.id, text: "Quoted \(n).", registeringUndo: false)
            if n % 2 == 0 {
                _ = try ops.applyTag(quote.id, toPost: note.id)
            } else {
                _ = try ops.applyTag(quote.id, toBlock: block.block.id)
            }
        }
    }

    /// The listing must not grow with the LIBRARY: the same wearers, in a
    /// library fifteen times thicker (notes, blocks, another tag's
    /// applications), cost the same.
    @Test func theListingDoesNotGrowWithTheLibrary() throws {
        func work(notes: Int) throws -> Int {
            try withOperations { ops, db in
                try library(ops, notes: notes, wearing: 6)
                #expect(try wearers(db, "quote", in: "").count == 6)
                return try instructions(db) { _ = try Queries.notesWearingTag($0, path: "quote", wingID: "") }
            }
        }
        let thin = try work(notes: 20)
        let thick = try work(notes: 300)
        print("VX-827 U2 notesWearingTag VM instructions: library ×1 \(thin), ×15 \(thick)")
        #expect(Double(thick) < Double(thin) * 1.5,
                "library ×15: \(thin) → \(thick) VM instructions — the library must not drive the listing (P1)")
    }

    /// The listing grows with the tag's own WEARERS, linearly.
    @Test func theListingGrowsWithTheTagsWearersLinearly() throws {
        func work(wearing: Int) throws -> Int {
            try withOperations { ops, db in
                try library(ops, notes: 10, wearing: wearing)
                #expect(try wearers(db, "quote", in: "").count == wearing)
                return try instructions(db) { _ = try Queries.notesWearingTag($0, path: "quote", wingID: "") }
            }
        }
        let few = try work(wearing: 20)
        let many = try work(wearing: 60)
        print("VX-827 U2 notesWearingTag VM instructions: 20 wearers \(few), 60 wearers \(many)")
        #expect(Double(many) < Double(few) * 3.9, "wearers ×3: \(few) → \(many) — linear is ≤ ×3")
    }

    /// The plan, as the claims' mechanism: the path probe, the wearer read and
    /// the note tags SEARCH every store table by a selective index — never a
    /// SCAN, never the post kind's index (the subtree read is `tagSubtree`'s,
    /// the rule grammar's own, over the vocabulary — author-scale metadata —
    /// and the wing rows; neither is a corpus table).
    @Test func theWearerReadNeverScansAStoreTable() throws {
        try withOperations { ops, db in
            try library(ops, notes: 4, wearing: 4)
            let plan = try capturedPlan(db) { database in
                _ = try Queries.liveTagIDs(database, path: "quote", wingID: "")
                _ = try Queries.liveTagIDs(database, path: "quote", wingID: nil)
                let subtree = try Queries.liveTagIDs(database, path: "quote", wingID: "")
                _ = try Queries.notesWearingTag(database, path: "quote", wingID: "")
                _ = try Queries.notesWearingTag(database, path: "quote", wingID: nil)
                _ = subtree
                _ = try Queries.wornTags(database, noteIDs: ["a", "b"])
            }
            // The corpus tables, by every alias these reads give them (`tag` bare
            // is `tagSubtree`'s vocabulary read, deliberately not listed).
            let tables = ["pt", "bt", "b", "cb", "c", "t", "post_tag", "block_tag", "block", "container_block",
                          "container"]
            // A SEARCH by `idx_container_kind` walks every post (the kind has two
            // values) — a corpus scan wearing an index's name; it counts as one.
            let scans = plan.split(separator: "\n").map(String.init).filter { line in
                tables.contains { line == "SCAN \($0)" || line.hasPrefix("SCAN \($0) ") }
                    || line.contains("idx_container_kind")
            }
            #expect(scans.isEmpty, "store-table scans \(scans); plan was:\n\(plan)")
        }
    }
}
