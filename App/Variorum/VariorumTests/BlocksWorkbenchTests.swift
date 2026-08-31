//
//  BlocksWorkbenchTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c — item 16 direction C: the Blocks workbench's
//  bulk acts over the ONE selection brain (13e's `BlockSelection`), each
//  landing the standing ops under the standing compound shapes.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("Blocks workbench (pre-13u Act 10 wave 2c)")
@MainActor
struct BlocksWorkbenchTests {
    private func seed(
        _ session: AppSession, texts: [String]
    ) async throws -> (postID: String, blockIDs: [String]) {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "workbench")
            var ids: [String] = []
            for text in texts {
                ids.append(try ops.newBlock(in: post.id, text: text).block.id)
            }
            return (post.id, ids)
        }
    }

    private func order(_ db: AppDatabase, post: String) async throws -> [String] {
        try await db.read { db in
            try Queries.renderPost(db, containerID: post).map(\.blockID)
        }
    }

    @Test func movePickedToTopKeepsRelativeOrderAndUndoesAsOneEntry() async throws {
        try await withWorld { session, db in
            let world = try await seed(session, texts: ["x", "a", "y", "b"])
            let model = BlockTOCViewModel(session: session, postID: world.postID)
            model.adopt(rows: try await db.read { [id = world.postID] in
                try Queries.blockTOC($0, post: id)
            })
            let a = world.blockIDs[1]
            let b = world.blockIDs[3]
            model.picked.toggle(a)
            model.picked.toggle(b)
            await model.movePicked(toTop: true)
            let after = try await order(db, post: world.postID)
            #expect(after == [a, b, world.blockIDs[0], world.blockIDs[2]],
                    "the picked run leads, relative order kept")
            // ONE compound entry — ⌥⌘Z restores the whole arrangement.
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in
                try undoStack.undo(with: ops)
            }
            let restored = try await order(db, post: world.postID)
            #expect(restored == world.blockIDs)
        }
    }

    @Test func deletePickedIsOneCompoundAndSpeaksTheRoadsBack() async throws {
        try await withWorld { session, db in
            let world = try await seed(session, texts: ["one", "two", "three"])
            let model = BlockTOCViewModel(session: session, postID: world.postID)
            model.adopt(rows: try await db.read { [id = world.postID] in
                try Queries.blockTOC($0, post: id)
            })
            model.picked.toggle(world.blockIDs[0])
            model.picked.toggle(world.blockIDs[2])
            await model.deletePicked()
            let after = try await order(db, post: world.postID)
            #expect(after == [world.blockIDs[1]])
            #expect(model.picked.isEmpty, "the selection dies with its blocks")
            // The ONE undo brings both back (13e E2's compound shape).
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in
                try undoStack.undo(with: ops)
            }
            let restored = try await order(db, post: world.postID)
            #expect(Set(restored) == Set(world.blockIDs))
        }
    }

    @Test func mergePickedRefusesAGappedRunByName() async throws {
        try await withWorld { session, db in
            let world = try await seed(session, texts: ["one", "two", "three"])
            let model = BlockTOCViewModel(session: session, postID: world.postID)
            model.adopt(rows: try await db.read { [id = world.postID] in
                try Queries.blockTOC($0, post: id)
            })
            model.picked.toggle(world.blockIDs[0])
            model.picked.toggle(world.blockIDs[2])  // a gap — block 2 unpicked
            await model.mergePicked()
            let after = try await order(db, post: world.postID)
            #expect(after == world.blockIDs, "nothing merged")
        }
    }

    @Test func mergePickedJoinsANeighbouringRun() async throws {
        try await withWorld { session, db in
            let world = try await seed(session, texts: ["one.", "two.", "three."])
            let model = BlockTOCViewModel(session: session, postID: world.postID)
            model.adopt(rows: try await db.read { [id = world.postID] in
                try Queries.blockTOC($0, post: id)
            })
            model.picked.toggle(world.blockIDs[0])
            model.picked.toggle(world.blockIDs[1])
            await model.mergePicked()
            let after = try await order(db, post: world.postID)
            #expect(after.count == 2, "two blocks became one, the third stands")
            let merged = try await db.read { [id = after[0]] db in
                try Queries.renderPost(db, containerID: world.postID)
                    .first { $0.blockID == id }?.text
            }
            #expect(merged == "one. two.", "the canon single-space join")
            #expect(model.picked.isEmpty)
        }
    }

    @Test func tagPickedSkipsAlreadyTaggedQuietly() async throws {
        try await withWorld { session, db in
            let world = try await seed(session, texts: ["one", "two"])
            let tagID = try await session.runner.run { ops in
                try ops.createTag(name: "voice").id
            }
            _ = try await session.runner.run { [a = world.blockIDs[0]] ops in
                try ops.applyTag(tagID, toBlock: a)
            }
            let model = BlockTOCViewModel(session: session, postID: world.postID)
            model.adopt(rows: try await db.read { [id = world.postID] in
                try Queries.blockTOC($0, post: id)
            })
            model.picked.toggle(world.blockIDs[0])
            model.picked.toggle(world.blockIDs[1])
            await model.tagPicked(tagID)
            let rows = try await db.read { [id = world.postID] in
                try Queries.blockWorkbench($0, post: id)
            }
            #expect(rows.allSatisfy { $0.tagPaths == ["voice"] },
                    "both tagged exactly once — the already-tagged row skipped, not doubled")
        }
    }

    @Test func movePickedToPoolMovesThemOutInOrder() async throws {
        try await withWorld { session, db in
            let world = try await seed(session, texts: ["keep", "go 1", "go 2"])
            let poolID = try await session.runner.run { ops in
                try ops.createPool(title: "Pool").id
            }
            let model = BlockTOCViewModel(session: session, postID: world.postID)
            model.adopt(rows: try await db.read { [id = world.postID] in
                try Queries.blockTOC($0, post: id)
            })
            model.picked.toggle(world.blockIDs[1])
            model.picked.toggle(world.blockIDs[2])
            await model.movePickedToPool(poolID, poolTitle: "Pool")
            let noteAfter = try await order(db, post: world.postID)
            #expect(noteAfter == [world.blockIDs[0]])
            let poolAfter = try await order(db, post: poolID)
            #expect(poolAfter == [world.blockIDs[1], world.blockIDs[2]],
                    "the blocks LEFT the note (I2) and kept their order")
            #expect(model.picked.isEmpty)
        }
    }
}
