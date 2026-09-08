import Foundation
import Testing
@testable import VariorumCore

/// 18d batch 1 (her U-10 — the sidebar's note box): the note's two time
/// facts, as one read. RED ON OLD: `Queries.noteStamps` did not exist, so the
/// box's *"edited … · saved …"* line had nothing honest to read.
@Suite("The note's stamps (18d batch 1 — the note box's facts line)")
struct NoteStampsTests {
    @Test func aFreshNoteHasAnEditedStampAndNoSavepoint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "T")
            let stamps = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            // Nothing has ever been committed here — the face says so by
            // omission rather than by inventing a date.
            #expect(stamps.savedAt == nil)
            // A note nobody has typed in still reports a day: the mint's.
            #expect(stamps.editedAt == post.createdAt)
        }
    }

    @Test func theEditedStampFollowsTheLastKeystrokeNotTheMint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "one")
            let mint = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            try ops.autosave(block.variant.id, text: "one two", charDelta: 4)
            let after = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            #expect(after.editedAt > mint.editedAt, "an autosave moves the edited stamp")
        }
    }

    /// The savepoint is the NEWEST across every live take of the note — not
    /// only the rendered one. A moment written on a take she is no longer
    /// looking at is still a moment this note has.
    @Test func theSavedStampIsTheNewestSavepointAcrossEveryTake() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let first = try ops.newBlock(in: post.id, text: "one")
            let second = try ops.newBlock(in: post.id, text: "two")
            let commitOne = try ops.commit(first.variant.id)
            let afterFirst = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            #expect(afterFirst.savedAt == commitOne.createdAt)

            // A SECOND take on the first block, committed later: the note's
            // saved stamp follows it even though the slot still renders the
            // original take.
            let take = try ops.branchVariant(first.block.id, from: first.variant.id)
            let commitTake = try ops.commit(take.id)
            let afterTake = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            #expect(afterTake.savedAt == commitTake.createdAt)
            #expect(commitTake.createdAt > commitOne.createdAt)

            // …and a commit on the OTHER block counts too.
            let commitTwo = try ops.commit(second.variant.id)
            let afterSecond = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            #expect(afterSecond.savedAt == commitTwo.createdAt)
        }
    }

    /// A tombstoned note reads nil — the read-side convention
    /// (`containerHeader`): a gone row is tolerated, never a crash.
    @Test func aDeletedNoteReadsNil() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "a")
            try ops.deleteContainer(post.id)
            let gone = try db.read { try Queries.noteStamps($0, postID: post.id) }
            #expect(gone == nil)
            #expect(try db.read { try Queries.noteStamps($0, postID: "nobody") } == nil)
        }
    }

    /// A DELETED block's savepoints leave with it — the box must not report
    /// a moment whose text is in the tray.
    @Test func aDeletedBlocksSavepointsLeaveTheNotesStamp() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let keep = try ops.newBlock(in: post.id, text: "keep")
            let keepCommit = try ops.commit(keep.variant.id)
            let doomed = try ops.newBlock(in: post.id, text: "doomed")
            _ = try ops.commit(doomed.variant.id)
            try ops.deleteBlock(doomed.block.id)
            let stamps = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            #expect(stamps.savedAt == keepCommit.createdAt,
                    "the cascade took the deleted block's take, and its moments with it")
        }
    }
}
