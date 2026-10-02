import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U5 — the per-item NOTE doors across wings (the sitting record §9;
/// her 2026-08-25 "cross library move … and make a copy … should also be an
/// option"; R-13ia-1's adoption rider). New ops — their pins are
/// state-transition pins (adopt vs mint, severed memberships, the frozen
/// refusal, versions riding; the copy's wing, tags, lineage and booklessness).
@Suite("13i-d U5 — move and copy a note across wings")
struct WingMoveTests {
    private func liveTagIDs(_ db: AppDatabase, post: String) throws -> Set<String> {
        Set(try db.read {
            try String.fetchAll(
                $0, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                arguments: [post])
        })
    }

    private func tag(_ db: AppDatabase, wing: String, path: String) throws -> VariorumCore.Tag? {
        try db.read {
            try VariorumCore.Tag.fetchOne(
                $0, sql: "SELECT * FROM tag WHERE wing_id = ? AND path = ? AND deleted_at IS NULL",
                arguments: [wing, path])
        }
    }

    /// R-13ia-1: `writing/draft` ADOPTS the destination's own `writing/draft`;
    /// `poems` (missing there) is MINTED; a block tag re-points the same way.
    /// The note's old applications tombstone; the source wing's tags stay.
    @Test func aMoveAdoptsSamePathTagsAndMintsTheRest() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let writing = try ops.createTag(name: "writing")
            let draft = try ops.createTag(parent: writing.id, name: "draft")
            let poems = try ops.createTag(name: "poems")
            let destWriting = try ops.createTag(name: "writing", wingID: wing.id)
            let destDraft = try ops.createTag(parent: destWriting.id, name: "draft")
            let note = try ops.createPost(title: "moving")
            let block = try ops.newBlock(in: note.id, text: "a line", at: .end)
            try ops.applyTag(draft.id, toPost: note.id)
            try ops.applyTag(poems.id, toPost: note.id)
            _ = try ops.applyTag(writing.id, toBlock: block.block.id)

            let result = try ops.moveNoteToWing(note.id, to: wing.id)
            #expect(result.adoptedTags == 2, "writing/draft and writing (the block's) adopt")
            #expect(result.mintedTags == 1, "poems is minted in the destination")
            let destPoems = try #require(try tag(db, wing: wing.id, path: "poems"))
            #expect(try liveTagIDs(db, post: note.id) == [destDraft.id, destPoems.id])
            let blockTags = try db.read {
                try String.fetchAll(
                    $0, sql: "SELECT tag_id FROM block_tag WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [block.block.id])
            }
            #expect(blockTags == [destWriting.id])
            #expect(try db.read { try Queries.effectiveWing($0, ofPost: note.id) } == wing.id)
            // The source wing's vocabulary stays (the bulk move retires it).
            #expect(try db.deletedAt("tag", draft.id) == nil)
            #expect(try db.deletedAt("tag", poems.id) == nil)
        }
    }

    /// A book never spans wings: the move SEVERS the note's source-wing
    /// memberships (members and a waiting arrival), listing the books; a
    /// MEMBER row in a FINISHED book refuses and writes nothing.
    @Test func aMoveSeversItsBooksAndAFinishedBookRefuses() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "membered")
            let a = try ops.createReading(name: "Alpha", kind: .book)
            let b = try ops.createReading(name: "Beta", kind: .book)
            _ = try ops.addPostToReading(note.id, to: a.id)
            _ = try ops.addPostToReading(note.id, to: b.id)
            let preview = try db.read { try Queries.wingMovePreview($0, postID: note.id) }
            #expect(preview.leaves == ["Alpha", "Beta"] && preview.frozenBook == nil)

            try ops.lockReading(b.id)
            #expect(try db.read { try Queries.wingMovePreview($0, postID: note.id) }.frozenBook
                    == "Beta")
            let before = try db.snapshotRow("container", note.id, excluding: [])
            #expect(throws: OperationError.lockedReading(id: b.id)) {
                try ops.moveNoteToWing(note.id, to: wing.id)
            }
            #expect(try db.snapshotRow("container", note.id, excluding: []) == before)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [note.id]) == 2, "a refusal severs nothing")

            try ops.unlockReading(b.id)
            let result = try ops.moveNoteToWing(note.id, to: wing.id)
            #expect(result.leftBooks == ["Alpha", "Beta"])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [note.id]) == 0)
        }
    }

    /// A SEALED book's member refuses with the seal's own road.
    @Test func aSealedBooksMemberRefusesTheMove() throws {
        try withOperations { ops, _ in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "sealed member")
            _ = try ops.newBlock(in: note.id, text: "words", at: .end)
            let book = try ops.createReading(name: "Edition", kind: .book)
            _ = try ops.addPostToReading(note.id, to: book.id)
            _ = try ops.sealReading(book.id)
            #expect(throws: OperationError.readingSealed(id: book.id)) {
                try ops.moveNoteToWing(note.id, to: wing.id)
            }
        }
    }

    /// The note's saved VERSIONS ride it (a thing's past goes where the thing
    /// goes); its star and archive state stay; moving back to Home works;
    /// its own wing and a dead wing refuse.
    @Test func versionsRideAndTheRefusalsHold() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let note = try ops.createPost(title: "versioned")
            _ = try ops.newBlock(in: note.id, text: "words", at: .end)
            let version = try ops.saveNoteVersion(note.id).post
            try ops.archiveContainer(note.id)
            _ = try ops.moveNoteToWing(note.id, to: wing.id)
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [version.id])
                    == wing.id)
            #expect(try db.read { try Queries.wingContents($0, wingID: wing.id) }.notes == 1)
            #expect(try db.fetchString("SELECT archived_at FROM container WHERE id = ?", [note.id])
                    != nil, "archive state rides")
            #expect(throws: OperationError.postAlreadyInWing(postID: note.id, wingID: wing.id)) {
                try ops.moveNoteToWing(note.id, to: wing.id)
            }
            _ = try ops.moveNoteToWing(note.id, to: "")
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [note.id]) == "")
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [version.id])
                    == "")
            let dead = try ops.createWing(name: "Brief")
            try ops.deleteWing(dead.id)
            #expect(throws: OperationError.wingNotFound(id: dead.id)) {
                try ops.moveNoteToWing(note.id, to: dead.id)
            }
        }
    }

    /// The copy is born IN the destination, BOOKLESS, its tags adopted there,
    /// lineage-edged to the source block for block; the source is untouched.
    @Test func aCopyIsBornInTheDestinationBooklessAndLineageEdged() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let topic = try ops.createTag(name: "topic")
            let note = try ops.createPost(title: "original")
            let b1 = try ops.newBlock(in: note.id, text: "one", at: .end)
            let b2 = try ops.newBlock(in: note.id, text: "two", at: .end)
            try ops.applyTag(topic.id, toPost: note.id)
            let book = try ops.createReading(name: "Home Book", kind: .book)
            _ = try ops.addPostToReading(note.id, to: book.id)

            let copy = try ops.copyNoteToWing(note.id, to: wing.id)
            #expect(copy.wingId == wing.id)
            #expect(copy.title == "original")
            let destTopic = try #require(try tag(db, wing: wing.id, path: "topic"))
            #expect(try liveTagIDs(db, post: copy.id) == [destTopic.id])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [copy.id]) == 0, "a copy joins no book")
            // Lineage: each copied block derives from its source.
            let origins = try db.read {
                try String.fetchAll(
                    $0,
                    sql: """
                        SELECT e.target_block_id FROM edge e
                        JOIN container_block cb ON cb.block_id = e.source_block_id
                         AND cb.container_id = ? AND cb.deleted_at IS NULL
                        WHERE e.type = 'derived_from' AND e.deleted_at IS NULL
                        ORDER BY cb.position
                        """,
                    arguments: [copy.id])
            }
            #expect(origins == [b1.block.id, b2.block.id])
            #expect(try db.read { try Queries.versionPeerPosts($0, of: copy.id) } == [note.id])
            // The source is untouched — its wing, tag and book.
            #expect(try liveTagIDs(db, post: note.id) == [topic.id])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE post_id = ? AND deleted_at IS NULL",
                [note.id]) == 1)
            #expect(try db.fetchString("SELECT wing_id FROM container WHERE id = ?", [note.id]) == "")
        }
    }

    /// An EMPTY note copies as a bare note (no blocks, no edge); the copy's
    /// own wing refuses.
    @Test func anEmptyNoteCopiesBareAndTheSameWingRefuses() throws {
        try withOperations { ops, _ in
            let wing = try ops.createWing(name: "Imports")
            let empty = try ops.createPost(title: "empty")
            let copy = try ops.copyNoteToWing(empty.id, to: wing.id)
            #expect(copy.wingId == wing.id && copy.title == "empty")
            #expect(throws: OperationError.postAlreadyInWing(postID: empty.id, wingID: "")) {
                try ops.copyNoteToWing(empty.id, to: "")
            }
        }
    }
}
