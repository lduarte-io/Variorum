import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's BATCH ACTS (VX-184 U3 — VX-173, the door half; the kickoff's
// U3 row). `add_takes` and `add_comments` are the SUGGEST rung's `add_take` and
// `add_comment` made one act: every item lands through the SAME row body the
// single door uses (`insertSuggestedTake`, `insertBlockComment`), all in ONE
// transaction with the caller's guard FIRST inside it, so the batch lands
// whole or not at all; ONE structural-undo entry labeled with the client
// walks the whole batch back (R-13n-6 — "undoing AI writing … in a single
// command"), its inverse and redo each ONE transaction over the exact rows.
//
// One NOTE per batch: every item's block must be live-placed in that note
// (the server decided that note — `save_lens`'s shape). The note's seal is
// checked once, before any item, so a sealed note refuses as itself; an item
// that cannot land refuses the whole batch as `MCPBatchItemRefusal`, naming
// its index (the wire says which item, in the room's words).
extension Operations {
    /// One `add_takes` item: a take for one block of the batch's note.
    public struct MCPTakeItem: Equatable, Sendable {
        public var blockID: String
        public var text: String
        public var label: String?

        public init(blockID: String, text: String, label: String? = nil) {
            self.blockID = blockID
            self.text = text
            self.label = label
        }
    }

    /// One `add_comments` item: a comment on one block of the batch's note.
    public struct MCPCommentItem: Equatable, Sendable {
        public var blockID: String
        public var text: String

        public init(blockID: String, text: String) {
            self.blockID = blockID
            self.text = text
        }
    }

    /// The batch refused at ONE item (all-or-nothing: nothing of it landed):
    /// the item's index in the call and the operations layer's own refusal.
    public struct MCPBatchItemRefusal: Error, Sendable {
        public let index: Int
        public let underlying: Error
    }

    // MARK: - SUGGEST: takes, one act

    /// **`add_takes`' act** — each item a new take at the END of its block's
    /// fan (in item order; two items on one block land in that order), labeled
    /// as given, PARENTLESS, never chosen, never the default, never locked —
    /// `addTake`'s row body, item by item, in ONE transaction: the caller's
    /// guard first, then the note (live, a post, not sealed — `lockedPost` for
    /// the whole batch), then each item's block (live and placed in THIS note,
    /// else `blockNotInContainer`, as `MCPBatchItemRefusal`). Fan growth's
    /// conventions: no touch, no churn. ONE undo entry, `undoLabel`: every take
    /// tombstoned in ONE transaction (a take she has CHOSEN since refuses the
    /// whole undo and keeps the entry — `revertAddedTake`'s guard), the redo
    /// flipping the same rows back.
    @discardableResult
    public func addTakes(
        _ items: [MCPTakeItem], inNote noteID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> [Variant] {
        let takes: [Variant] = try database.write { db in
            try guardian?(db)
            try ensureUnlocked(try livePost(db, noteID))
            return try items.enumerated().map { index, item in
                do {
                    try requireBlock(db, item.blockID, placedIn: noteID)
                    return try insertSuggestedTake(db, blockID: item.blockID, text: item.text, label: item.label)
                } catch {
                    throw MCPBatchItemRefusal(index: index, underlying: error)
                }
            }
        }
        let ids = takes.map(\.id)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertAddedTakes(ids) },
            redo: { try $0.reapplyAddedTakes(ids) })
        return takes
    }

    /// The batch's inverse — every take back out, ONE transaction, newest first.
    func revertAddedTakes(_ ids: [String]) throws {
        try database.write { db in
            for id in ids.reversed() { try revertAddedTake(db, id) }
        }
    }

    /// The batch's redo — the very rows back, ONE transaction, in order.
    func reapplyAddedTakes(_ ids: [String]) throws {
        try database.write { db in
            for id in ids { try reapplyAddedTake(db, id) }
        }
    }

    // MARK: - SUGGEST: comments, one act

    /// **`add_comments`' act** — each item `addBlockComment`'s row body (a
    /// blank text refuses, `invalidCommentText`), in ONE transaction with the
    /// same note and block checks as `addTakes`; metadata, no touch, no churn.
    /// ONE undo entry: every comment tombstoned in ONE transaction (each stays
    /// on its block's deleted-comments surface), the redo flipping them back.
    /// VX-188 (R-VX188-1): each comment is put on file as `author`'s in the
    /// same transaction (`addComment`'s record).
    @discardableResult
    public func addComments(
        _ items: [MCPCommentItem], inNote noteID: String, author client: String, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> [BlockComment] {
        let comments: [BlockComment] = try database.write { db in
            try guardian?(db)
            try ensureUnlocked(try livePost(db, noteID))
            return try items.enumerated().map { index, item in
                do {
                    try requireBlock(db, item.blockID, placedIn: noteID)
                    let comment = try insertBlockComment(db, to: item.blockID, text: item.text)
                    try recordMCPCommentAuthor(db, commentID: comment.id, client: client)
                    return comment
                } catch {
                    throw MCPBatchItemRefusal(index: index, underlying: error)
                }
            }
        }
        let ids = comments.map(\.id)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertAddedComments(ids) },
            redo: { try $0.reapplyAddedComments(ids) })
        return comments
    }

    func revertAddedComments(_ ids: [String]) throws {
        try database.write { db in
            for id in ids.reversed() { try revertAddedComment(db, id) }
        }
    }

    func reapplyAddedComments(_ ids: [String]) throws {
        try database.write { db in
            for id in ids { try reapplyAddedComment(db, id) }
        }
    }

    // MARK: - Internals

    /// A batch item's block: live, and live-placed in the batch's note.
    private func requireBlock(_ db: Database, _ blockID: String, placedIn noteID: String) throws {
        _ = try liveBlock(db, blockID)
        guard let placement = try livePlacement(db, blockID: blockID), placement.containerId == noteID else {
            throw OperationError.blockNotInContainer(blockID: blockID, containerID: noteID)
        }
    }
}
