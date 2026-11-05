import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **THE ONE "IS A TAG STILL WORN?" BRAIN** — `Queries.tagSubtreeIsWorn`
/// (VX-825 — the VX-809 run, batch 1, A-809-9; the predicate VX-840's Settings ▸
/// Tags sweep consumes in VX-828's run). Each scope's arms: live wearers on
/// notes and blocks, the subtree (a worn child keeps the parent worn), the
/// snippet block (her surface counts it, the wire never), the Trash's
/// revivable wearers (counted only when asked — VX-840's judgment to pass),
/// and the reach filter (only the notes it admits; paged; tombstoned tags).
@Suite("VX-825 — Queries.tagSubtreeIsWorn, the shared unused-tag brain")
struct TagUsageQueriesTests {
    private func worn(_ db: AppDatabase, _ tagID: String, _ scope: Queries.TagWearerScope) throws -> Bool {
        try db.read { try Queries.tagSubtreeIsWorn($0, tagID: tagID, scope: scope) }
    }

    private static var library: Queries.TagWearerScope { .library(countingTrashRevivable: false) }
    private static var libraryWithTrash: Queries.TagWearerScope { .library(countingTrashRevivable: true) }
    private static func reach(_ admitted: Set<String>) -> Queries.TagWearerScope {
        .reach(readable: { Set($0).intersection(admitted) })
    }

    @Test func aTagNoOneWearsIsUnwornInEveryScope() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "idle")
            #expect(try !worn(db, tag.id, Self.library))
            #expect(try !worn(db, tag.id, Self.libraryWithTrash))
            #expect(try !worn(db, tag.id, Self.reach([])))
            #expect(try !worn(db, "no-such-tag", Self.library), "a missing tag is worn by nothing")
        }
    }

    @Test func aNotesTagIsWornAndTheReachFilterDecides() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "board")
            let note = try ops.createPost(title: "card")
            _ = try ops.applyTag(tag.id, toPost: note.id)
            #expect(try worn(db, tag.id, Self.library))
            #expect(try worn(db, tag.id, Self.reach([note.id])), "the client reads the wearer")
            #expect(try !worn(db, tag.id, Self.reach([])), "a wearer the client can't read never counts")
            try ops.removeTag(tag.id, fromPost: note.id)
            #expect(try !worn(db, tag.id, Self.library), "a removed application wears nothing")
        }
    }

    @Test func aBlockOfANoteWearsItThroughItsNote() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "quote")
            let note = try ops.createPost(title: "essay")
            let placed = try ops.newBlock(in: note.id, text: "A line.", registeringUndo: false)
            _ = try ops.applyTag(tag.id, toBlock: placed.block.id)
            #expect(try worn(db, tag.id, Self.library))
            #expect(try worn(db, tag.id, Self.reach([note.id])), "the block's note is read, so the block counts")
            #expect(try !worn(db, tag.id, Self.reach([])))
        }
    }

    @Test func aSnippetBlockCountsOnHerSurfaceAndNeverOnTheWire() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "scrap")
            let pool = try ops.createPool(title: "Snippets")
            let placed = try ops.newBlock(in: pool.id, text: "A scrap.", registeringUndo: false)
            _ = try ops.applyTag(tag.id, toBlock: placed.block.id)
            #expect(try worn(db, tag.id, Self.library), "her library counts every live wearer")
            #expect(try !worn(db, tag.id, Self.reach([pool.id])),
                    "a pool is no note — no client reaches a snippet, whatever the filter says")
        }
    }

    @Test func aWornChildKeepsItsParentWornAndNotTheOtherWayRound() throws {
        try withOperations { ops, db in
            let parent = try ops.createTag(name: "life")
            let child = try ops.createTag(parent: parent.id, name: "goals")
            let note = try ops.createPost(title: "plan")
            _ = try ops.applyTag(child.id, toPost: note.id)
            #expect(try worn(db, parent.id, Self.library), "deleting the parent would delete a worn child")
            #expect(try worn(db, parent.id, Self.reach([note.id])))
            let lone = try ops.createTag(parent: parent.id, name: "idle")
            #expect(try !worn(db, lone.id, Self.library), "a sibling is not the subtree")
        }
    }

    @Test func theTrashsRevivableWearersCountOnlyWhenAsked() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "draft")
            let note = try ops.createPost(title: "old")
            _ = try ops.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            _ = try ops.applyTag(tag.id, toPost: note.id)
            try ops.deleteContainer(note.id)
            #expect(try !worn(db, tag.id, Self.library), "a trashed note wears nothing live")
            #expect(try worn(db, tag.id, Self.libraryWithTrash), "its application would revive on a restore")
            #expect(try !worn(db, tag.id, Self.reach([note.id])), "the Trash is reachable by no client")
        }
    }

    @Test func anApplicationRemovedBeforeTheNoteWasTrashedNeverRevives() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "draft")
            let note = try ops.createPost(title: "old")
            _ = try ops.newBlock(in: note.id, text: "Words.", registeringUndo: false)
            _ = try ops.applyTag(tag.id, toPost: note.id)
            try ops.removeTag(tag.id, fromPost: note.id)
            try ops.deleteContainer(note.id)
            #expect(try !worn(db, tag.id, Self.libraryWithTrash), "its own stamp, not the note's: a restore leaves it")
        }
    }

    @Test func theReachWalkPagesPastUnreadableWearers() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "many")
            var notes: [String] = []
            for index in 0..<(Queries.tagWearerPage + 5) {
                let note = try ops.createPost(title: "n\(index)")
                _ = try ops.applyTag(tag.id, toPost: note.id)
                notes.append(note.id)
            }
            let last = try #require(notes.max())
            var asked = 0
            let scope = Queries.TagWearerScope.reach(readable: { ids in
                asked += 1
                return Set(ids).intersection([last])
            })
            #expect(try worn(db, tag.id, scope), "the one readable wearer is found on the second page")
            #expect(asked == 2)
        }
    }
}
