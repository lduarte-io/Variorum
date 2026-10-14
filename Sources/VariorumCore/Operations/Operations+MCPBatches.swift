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
        // VX-246 U2 — an entry with PARTS (the takes): the undo tombstones
        // only the takes its partner last brought back (every take, after the
        // act) and records each one's stamp; the redo revives only those,
        // each on its own stamp — so a take she put back from the tray in
        // between is never taken again by the next undo.
        let parts = LockIsolated(BatchParts(ids: ids))
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                let undone = try ops.revertAddedTakes(ids, only: parts.value.standing)
                parts.withValue { $0.undo(undone) }
                return !undone.isEmpty
            },
            redo: { ops in
                let redone = try ops.reapplyAddedTakes(ids, undoneOn: parts.value.undone)
                parts.withValue { $0.redo(redone) }
                return !redone.isEmpty
            })
        return takes
    }

    /// The batch's inverse — every take back out, ONE transaction, newest first.
    func revertAddedTakes(_ ids: [String], only: Set<String>) throws -> [String: String] {
        try database.write { db in
            var undone: [String: String] = [:]
            for id in ids.reversed() where only.contains(id) {
                if let stamp = try revertAddedTake(db, id) { undone[id] = stamp }
            }
            return undone
        }
    }

    /// The batch's redo — the very rows back, ONE transaction, in order.
    func reapplyAddedTakes(_ ids: [String], undoneOn stamps: [String: String]) throws -> Set<String> {
        try database.write { db in
            var redone: Set<String> = []
            for id in ids where stamps[id] != nil {
                if try reapplyAddedTake(db, id, undoneOn: stamps[id]) { redone.insert(id) }
            }
            return redone
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
        // VX-246 U2 — the takes batch's parts record, over comments.
        let parts = LockIsolated(BatchParts(ids: ids))
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                let undone = try ops.revertAddedComments(ids, only: parts.value.standing)
                parts.withValue { $0.undo(undone) }
                return !undone.isEmpty
            },
            redo: { ops in
                let redone = try ops.reapplyAddedComments(ids, undoneOn: parts.value.undone)
                parts.withValue { $0.redo(redone) }
                return !redone.isEmpty
            })
        return comments
    }

    func revertAddedComments(_ ids: [String], only: Set<String>) throws -> [String: String] {
        try database.write { db in
            var undone: [String: String] = [:]
            for id in ids.reversed() where only.contains(id) {
                if let stamp = try revertAddedComment(db, id) { undone[id] = stamp }
            }
            return undone
        }
    }

    func reapplyAddedComments(_ ids: [String], undoneOn stamps: [String: String]) throws -> Set<String> {
        try database.write { db in
            var redone: Set<String> = []
            for id in ids where stamps[id] != nil {
                if try reapplyAddedComment(db, id, undoneOn: stamps[id]) { redone.insert(id) }
            }
            return redone
        }
    }

    /// A batch entry's parts (VX-246 U2): which of its rows stand as the act
    /// (or the last redo) left them, and the stamp each was tombstoned on by
    /// the last undo.
    struct BatchParts: Sendable {
        /// Rows whose last half put them back — the next undo's to take.
        private(set) var standing: Set<String>
        /// Rows the last undo tombstoned, each with its stamp — the next
        /// redo's to revive.
        private(set) var undone: [String: String] = [:]

        init(ids: [String]) { standing = Set(ids) }

        mutating func undo(_ tombstoned: [String: String]) {
            undone = tombstoned
            standing = []
        }

        mutating func redo(_ revived: Set<String>) {
            standing = revived
            undone = [:]
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
