import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's BOOK ORDER (VX-813 — the VX-809 run, batch 2; her ruling
// R-813: "order is plain book configuration; her state doors (Finished, Seal,
// Own, Private) stay hers alone. An order option on create_book and
// set_book_rule too, not only a standalone setter").
//
// Her ONE door is the book view navigator's `order ▾` → "Save as This Book's
// Order" (`BookStructureModel.saveOrder` → `setReadingSort`), drawn on a book
// AND a gathering, hidden only while the book is finished. Her op is the body
// (`writeReadingSort`, moved verbatim — a FINISHED (so also sealed) book
// refuses `lockedReading`; any field × direction; an archived book and a
// gathering take it). The wire adds only what every MCP write carries: the
// no-op guard (the order already as asked writes NOTHING — the VX-362
// posture; her op would re-write `updated_at`) and ONE client-named undo
// entry, COMPARE-AND-SET both ways (VX-184 ladder round 1 — the undo-overwrite
// class: a half writes only while the book still reads its partner's order,
// so an order she saved since through her own door — which registers no
// entry — is hers, and the entry is quiet and retires).
extension Operations {
    /// What `setBookOrderForClient` did.
    public struct MCPBookOrder: Equatable, Sendable {
        public let bookID: String
        public let order: Queries.ReadingOrder
        public let changed: Bool
    }

    /// **`set_book_order`'s act — her `setReadingSort`.** The caller's guard
    /// FIRST inside the act's transaction (AF-10 (a)); her op's own refusal
    /// next (a finished or sealed book — `lockedReading`, before the no-op
    /// test, exactly as her op orders it); then the no-op guard; then her
    /// body. ONE entry restoring the previous order while the book still
    /// reads the act's (a book finished since refuses and keeps the entry —
    /// her op's guard), the redo the act's order likewise.
    @discardableResult
    public func setBookOrderForClient(
        _ readingID: String, order: Queries.ReadingOrder, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPBookOrder {
        let previous: Queries.ReadingOrder? = try database.write { db in
            try guardian?(db)
            let reading = try liveReading(db, readingID)
            guard !reading.locked else { throw OperationError.lockedReading(id: readingID) }
            let stored = Queries.ReadingOrder(field: reading.sortField, direction: reading.sortDir)
            guard stored != order else { return nil }
            try writeReadingSort(db, readingID, field: order.field, direction: order.direction)
            return stored
        }
        guard let previous else { return MCPBookOrder(bookID: readingID, order: order, changed: false) }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreBookOrder(readingID, from: order, to: previous) },
            redo: { try $0.restoreBookOrder(readingID, from: previous, to: order) })
        return MCPBookOrder(bookID: readingID, order: order, changed: true)
    }

    /// Both halves of the order entry, COMPARE-AND-SET: `to` is written only
    /// while the book is live and still reads `from` — quiet otherwise (her
    /// own Save since is hers). Past the CAS, her op's body: a book finished
    /// since refuses `lockedReading` and the entry is kept (resolvable —
    /// reopen it, then undo).
    @discardableResult
    func restoreBookOrder(
        _ readingID: String, from: Queries.ReadingOrder, to order: Queries.ReadingOrder
    ) throws -> Bool {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  Queries.ReadingOrder(field: reading.sortField, direction: reading.sortDir) == from
            else { return false }
            try writeReadingSort(db, readingID, field: order.field, direction: order.direction)
            return true
        }
    }
}
