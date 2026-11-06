//
//  SearchPassageBlockNameTests.swift
//  VariorumCoreTests
//
//  VX-90 (a rider of VX-819 batch 1) — her 13o idea, from the VX-83 report:
//  *"when there are many results in a block the spacing between the results
//  is weird. and maybe it should say what block they're in?"* The core half:
//  every passage carries the NAME of the block it lives on
//  (`SearchPassage.blockName`), read off the block row the composer's hits
//  already seek — no new join, so every shipped plan pin stands unchanged.
//  The face (`LibrarySearchFace.blockMark`, the Mac's) decides what a line
//  wears.
//
//  BUILD pins for a new fact (a Feature rider, not a bug row): on the
//  pre-change tree they do not compile (`blockName` did not exist).
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func question(_ text: String, savepoints: Bool = false) -> SearchQuery {
    var query = SearchQueryParser.parse(text, typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
    query.includesSavepoints = savepoints
    return query
}

private func allPassages(_ db: AppDatabase, _ query: SearchQuery) throws -> [SearchPassage] {
    try db.read { db in
        var all: [SearchPassage] = []
        var cursor: SearchComposer.Cursor?
        repeat {
            let page = try Queries.searchPassages(db, query: query, scope: SearchScope(wingID: ""), after: cursor, limit: 50)
            all += page.passages
            cursor = page.next
        } while cursor != nil
        return all
    }
}

@Suite("VX-90 — a passage knows the name of the block it lives in")
struct SearchPassageBlockNameTests {
    @Test func everyHitOnANamedBlockCarriesItsNameAndNothingElseDoes() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Harbor note")
            try ops.updateFloatingNotes(note.id, notes: "harbor floating")
            let named = try ops.newBlock(in: note.id, text: "the harbor light")
            try ops.setBlockName(named.block.id, name: "Lantern")
            try ops.setTakeLabel(named.variant.id, label: "harbor take")
            _ = try ops.addBlockComment(to: named.block.id, text: "a harbor comment")
            let selfNamed = try ops.newBlock(in: note.id, text: "plain words")
            try ops.setBlockName(selfNamed.block.id, name: "harbor name")
            let unnamed = try ops.newBlock(in: note.id, text: "harbor again")
            _ = try ops.createReading(name: "Harbor Book", kind: .book)
            let pool = try ops.createPool(title: "Heap")
            let scrap = try ops.newBlock(in: pool.id, text: "a harbor scrap")
            try ops.setBlockName(scrap.block.id, name: "Driftwood")

            let found = try allPassages(db, question("harbor "))
            func names(_ kind: SearchPassage.Kind) -> [String?] {
                found.filter { $0.kind == kind }.sorted { $0.sourceID < $1.sourceID }.map(\.blockName)
            }
            let onNamed = found.filter { $0.blockID == named.block.id }
            #expect(Set(onNamed.map(\.kind)) == [.take, .takeLabel, .comment],
                    "the take, its label and the block's comment all live on the named block")
            #expect(onNamed.allSatisfy { $0.blockName == "Lantern" }, "each carries the block's name")
            #expect(names(.blockName) == ["harbor name"], "a name hit carries its own name (the face decides)")
            #expect(found.first { $0.blockID == unnamed.block.id }?.blockName == nil, "an unnamed block: nil")
            #expect(found.first { $0.blockID == scrap.block.id }?.blockName == "Driftwood", "a scrap's block too")
            for kind in [SearchPassage.Kind.title, .noteMeta, .book] {
                #expect(!names(kind).isEmpty && names(kind).allSatisfy { $0 == nil },
                        "\(kind) lives on no block — no name")
            }

            // The answer sheet's group lines are the same passages.
            let page = try db.read { db in
                try Queries.searchGroups(db, query: question("harbor "), scope: SearchScope(wingID: ""), perGroup: 10)
            }
            let lines = try #require(page.groups.first { $0.homeID == note.id }).lines
            #expect(lines.filter { $0.blockID == named.block.id }.allSatisfy { $0.blockName == "Lantern" })
            #expect(lines.first { $0.blockID == unnamed.block.id }?.blockName == nil)
        }
    }

    /// A savepoint (the commits facet, VX-72) names its TAKE's block — the
    /// block the landing steps to.
    @Test func aCommitNamesItsTakesBlock() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Logbook")
            let made = try ops.newBlock(in: note.id, text: "the lanterns were lit")
            try ops.setBlockName(made.block.id, name: "Evening")
            let saved = try ops.commit(made.variant.id)
            try ops.autosave(made.variant.id, text: "the take moved on entirely", charDelta: 20)
            let found = try allPassages(db, question("lanterns ", savepoints: true))
            let line = try #require(found.first { $0.kind == .savepoint })
            #expect(line.sourceID == saved.id && line.blockID == made.block.id && line.blockName == "Evening")
        }
    }

    /// A renamed or cleared name is read live — the index holds no copy.
    @Test func theNameIsReadLiveNeverACopy() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Logbook")
            let made = try ops.newBlock(in: note.id, text: "the harbor at dawn")
            try ops.setBlockName(made.block.id, name: "Dawn")
            #expect(try allPassages(db, question("harbor ")).first?.blockName == "Dawn")
            try ops.setBlockName(made.block.id, name: "First light")
            #expect(try allPassages(db, question("harbor ")).first?.blockName == "First light")
            try ops.setBlockName(made.block.id, name: nil)
            #expect(try allPassages(db, question("harbor ")).first?.blockName == nil)
        }
    }
}
