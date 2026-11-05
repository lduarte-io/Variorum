import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-813 (the VX-809 run, batch 2 — her R-813): THE BOOK ORDER's acts —
// `setBookOrderForClient` (her navigator's Save as This Book's Order through
// her `setReadingSort` body), `createBook(order:)` and `setBookRule`'s `order`
// part. Exact state transitions: the caller's guard first; her op's one
// refusal (a finished or sealed book — `lockedReading`, before the no-op test);
// the no-op guard (nothing written, no entry); ONE client-named entry whose
// halves are compare-and-set. Who may act is the server's per-call rule
// (`MCPBookOrderServerTests`). Her door's own suites run unmodified as the
// `writeReadingSort` extraction's parity proof.

private struct GuardRefused: Error, Equatable {}

@Suite("VX-813 — a book's order on the wire: the acts")
struct MCPBookOrderActsTests {
    private let client = "claude-code"

    private func withUndo<T>(_ body: (Operations, UndoStack, AppDatabase) throws -> T) throws -> T {
        try withOperations { _, db in
            let stack = UndoStack()
            return try body(Operations(undoStack: stack), stack, db)
        }
    }

    private func label(_ act: Operations.MCPWriteAct) -> String { act.undoLabel(client: client) }

    private func reading(_ db: AppDatabase, _ id: String) throws -> Reading {
        try #require(try db.read { try Reading.fetchOne($0, key: id) })
    }

    private func order(_ db: AppDatabase, _ id: String) throws -> Queries.ReadingOrder {
        let row = try reading(db, id)
        return .init(field: row.sortField, direction: row.sortDir)
    }

    private let newestFirst = Queries.ReadingOrder(field: .entryDate, direction: .desc)
    private let byRevision = Queries.ReadingOrder(field: .lastMajorRevision, direction: .desc)
    private let manual = Queries.ReadingOrder(field: .manual, direction: .asc)

    // MARK: - set_book_order's act

    @Test func anOrderLandsThroughHerBodyWithOneEntryThatRoundTrips() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let result = try ops.setBookOrderForClient(book.id, order: newestFirst, undoLabel: label(.bookSort))
            #expect(result == .init(bookID: book.id, order: newestFirst, changed: true))
            #expect(try order(db, book.id) == newestFirst)
            #expect(stack.depth == 1 && stack.topLabel == label(.bookSort), "ONE client-named entry")
            #expect(try stack.undo(with: ops) == label(.bookSort))
            #expect(try order(db, book.id) == manual, "the undo puts the old order back")
            #expect(try stack.redo(with: ops) == label(.bookSort))
            #expect(try order(db, book.id) == newestFirst, "the redo the act's")
        }
    }

    @Test func theOrderAlreadyAsAskedWritesNothingAndRegistersNothing() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book, sortField: .entryDate, sortDir: .desc)
            let before = try db.read { try Row.fetchOne($0, sql: "SELECT * FROM reading WHERE id = ?", arguments: [book.id]) }
            let result = try ops.setBookOrderForClient(book.id, order: newestFirst, undoLabel: label(.bookSort))
            #expect(result == .init(bookID: book.id, order: newestFirst, changed: false))
            let after = try db.read { try Row.fetchOne($0, sql: "SELECT * FROM reading WHERE id = ?", arguments: [book.id]) }
            #expect(before == after, "not even updated_at moves (her op would re-write it)")
            #expect(stack.depth == 0, "nothing to undo")
        }
    }

    @Test func aFinishedOrSealedBookRefusesInHerOpsWordsEvenWhenTheOrderIsTheSame() throws {
        try withUndo { ops, stack, db in
            let finished = try ops.createReading(name: "done", kind: .book)
            try ops.lockReading(finished.id)
            let sealed = try ops.createReading(name: "sealed", kind: .book)
            _ = try ops.sealReading(sealed.id)
            for id in [finished.id, sealed.id] {
                for asked in [newestFirst, manual] {
                    #expect(throws: OperationError.lockedReading(id: id)) {
                        try ops.setBookOrderForClient(id, order: asked, undoLabel: label(.bookSort))
                    }
                }
                #expect(try order(db, id) == manual)
            }
            #expect(stack.depth == 0)
        }
    }

    @Test func aGatheringAndAnArchivedBookTakeAnOrderAsHerDoorDoes() throws {
        try withUndo { ops, stack, db in
            let tag = try ops.createTag(name: "board")
            let gathering = try ops.createReading(
                name: "board", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let archived = try ops.createReading(name: "old", kind: .book)
            try ops.archiveReading(archived.id)
            _ = try ops.setBookOrderForClient(gathering.id, order: byRevision, undoLabel: label(.gatheringSort))
            _ = try ops.setBookOrderForClient(archived.id, order: newestFirst, undoLabel: label(.bookSort))
            #expect(try order(db, gathering.id) == byRevision)
            #expect(try order(db, archived.id) == newestFirst)
            #expect(stack.depth == 2)
        }
    }

    @Test func theGuardRunsFirstAndARefusalWritesNothing() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            #expect(throws: GuardRefused()) {
                try ops.setBookOrderForClient(
                    book.id, order: newestFirst, undoLabel: label(.bookSort), guardedBy: { _ in throw GuardRefused() })
            }
            #expect(try order(db, book.id) == manual && stack.depth == 0)
        }
    }

    @Test func theUndoIsQuietOverAnOrderSheSavedSinceAndKeptOverAFinish() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            _ = try ops.setBookOrderForClient(book.id, order: newestFirst, undoLabel: label(.bookSort))
            // Her own Save since (her door registers nothing): the entry is hers to lose.
            try ops.setReadingSort(book.id, field: .createdAt, direction: .asc)
            let quiet = try #require(try stack.undoReporting(with: ops))
            #expect(!quiet.changed && stack.depth == 0 && stack.redoDepth == 0, "quiet, retired")
            #expect(try order(db, book.id) == .init(field: .createdAt, direction: .asc), "her order stands")

            _ = try ops.setBookOrderForClient(book.id, order: byRevision, undoLabel: label(.bookSort))
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) { try stack.undo(with: ops) }
            #expect(stack.depth == 1, "a finished book keeps the entry — reopen, then undo")
            try ops.unlockReading(book.id)
            #expect(try stack.undo(with: ops) == label(.bookSort))
            #expect(try order(db, book.id) == .init(field: .createdAt, direction: .asc))
        }
    }

    // MARK: - create_book's order

    @Test func aBookIsBornInItsOrderAndItsUndoTakesItWithIt() throws {
        try withUndo { ops, stack, db in
            let plain = try ops.createBook(named: "plain", inWing: "", undoLabel: label(.book))
            #expect(try order(db, plain.id) == manual, "no order: the column defaults, byte-unchanged")
            let dated = try ops.createBook(named: "dated", inWing: "", undoLabel: label(.book), order: newestFirst)
            #expect(try order(db, dated.id) == newestFirst)
            #expect(stack.depth == 2, "one entry per mint — never a second for the order")
            #expect(try stack.undo(with: ops) == label(.book))
            #expect(try reading(db, dated.id).deletedAt != nil)
        }
    }

    // MARK: - set_book_rule's order

    @Test func setBookRulesOrderRidesTheSameEntryAndItsPartsRoundTrip() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            let alone = try ops.setBookRule(book.id, .init(order: newestFirst), undoLabel: label(.bookRule))
            #expect(alone.changed && alone.orderBefore == manual && alone.orderAfter == newestFirst)
            #expect(try order(db, book.id) == newestFirst && stack.depth == 1)
            let both = try ops.setBookRule(
                book.id, .init(rule: .some(.tag("percy")), order: byRevision), undoLabel: label(.bookRule))
            #expect(both.changed && both.after.querySpec != nil && both.orderAfter == byRevision)
            #expect(stack.depth == 2, "the rule and the order: ONE entry")
            #expect(try stack.undo(with: ops) == label(.bookRule))
            #expect(try order(db, book.id) == newestFirst && reading(db, book.id).querySpec == nil,
                    "the undo takes both parts back")
            #expect(try stack.redo(with: ops) == label(.bookRule))
            #expect(try order(db, book.id) == byRevision && reading(db, book.id).querySpec != nil)
            // The order already as stored: no order write, nothing changed.
            let same = try ops.setBookRule(book.id, .init(order: byRevision), undoLabel: label(.bookRule))
            #expect(!same.changed && stack.depth == 2)
        }
    }

    @Test func setBookRuleWithAnOrderOnAFinishedBookRefusesWhole() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.lockReading(book.id)
            #expect(throws: OperationError.lockedReading(id: book.id)) {
                try ops.setBookRule(
                    book.id, .init(rule: .some(.tag("percy")), order: newestFirst), undoLabel: label(.bookRule))
            }
            #expect(try reading(db, book.id).querySpec == nil, "nothing half-lands — the rule part rolled back")
            #expect(try order(db, book.id) == manual && stack.depth == 0)
            // Without an order, her Save's posture stands: a finished book's rule lands.
            let ruled = try ops.setBookRule(book.id, .init(rule: .some(.tag("percy"))), undoLabel: label(.bookRule))
            #expect(ruled.changed)
        }
    }

    @Test func theOrderPartsUndoIsQuietOverHerSaveAndTheRulePartStillReturns() throws {
        try withUndo { ops, stack, db in
            let book = try ops.createReading(name: "drafts", kind: .book)
            _ = try ops.setBookRule(
                book.id, .init(rule: .some(.tag("percy")), order: newestFirst), undoLabel: label(.bookRule))
            try ops.setReadingSort(book.id, field: .createdAt, direction: .desc)
            #expect(try stack.undo(with: ops) == label(.bookRule))
            #expect(try reading(db, book.id).querySpec == nil, "the rule part comes back")
            #expect(try order(db, book.id) == .init(field: .createdAt, direction: .desc), "her order is hers")
        }
    }
}
