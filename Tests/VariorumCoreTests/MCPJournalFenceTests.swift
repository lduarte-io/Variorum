import Foundation
import GRDB
import Testing

@testable import VariorumCore

// R-805-5 (the VX-805 run's kickoff ruling) — THE WIRE KEEPS A JOURNAL
// REFUSAL. Her own doors move (VX-435) and delete (VX-436) the daily Journal
// like any book; the MCP side's posture is unchanged, so the two refusals
// live at the MCP door as SHARED checks (`Operations+MCPJournalFence.swift`),
// never inlined into one tool. These pin the checks themselves; the delete
// fence's wiring into `delete_book`'s act and redo is pinned beside the act
// (`MCPLibraryEditActsTests` — the "even past an allowing guard" arm), and the
// words through the one chain in the MCP target (`MCPJournalFenceWordsTests`).
// RED ON OLD: neither check existed (by construction), and by revert — a
// no-op fence turns every refusal arm below green-for-the-wrong-reason red.

@Suite("R-805-5 — the wire's shared Journal fence (move + delete)")
struct MCPJournalFenceTests {
    private func journal(_ ops: Operations) throws -> String {
        let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01")
        guard case .shelved(let id) = ops.shelveInDailyJournalBook(entry.container.id) else {
            throw FenceFixtureError.noJournal
        }
        return id
    }

    private enum FenceFixtureError: Error { case noJournal }

    /// The move fence refuses the daily Journal — by its marker or by the
    /// designation — and passes every other book, a dead one and a missing
    /// id (the act's own liveness check speaks for those). It writes nothing.
    @Test func theMoveFenceRefusesTheDailyJournalAndPassesEverythingElse() throws {
        try withOperations { ops, db in
            let daily = try journal(ops)
            let plain = try ops.createReading(name: "novel", kind: .book)
            let trait = try ops.createReading(
                name: "dreams", kind: .book, profile: Queries.journalTraitProfile)
            try db.clearOutbox()
            try db.read { db in
                #expect(throws: OperationError.dailyJournalMovesOnlyByHand(id: daily)) {
                    try Operations.refuseMovingTheDailyJournalOnTheWire(db, readingID: daily)
                }
                try Operations.refuseMovingTheDailyJournalOnTheWire(db, readingID: plain.id)
                try Operations.refuseMovingTheDailyJournalOnTheWire(db, readingID: trait.id)
                try Operations.refuseMovingTheDailyJournalOnTheWire(db, readingID: "no-such-book")
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
            // Her own door moves it (VX-435) — only the wire is fenced.
            let wing = try ops.createWing(name: "Studio")
            _ = try ops.moveReadingToWing(daily, to: wing.id)
            try db.read { db in
                #expect(throws: OperationError.dailyJournalMovesOnlyByHand(id: daily)) {
                    try Operations.refuseMovingTheDailyJournalOnTheWire(db, readingID: daily)
                }
            }
            // A deleted Journal passes (the act's liveness check answers).
            try ops.deleteReading(daily)
            try db.read { db in
                try Operations.refuseMovingTheDailyJournalOnTheWire(db, readingID: daily)
            }
        }
    }

    /// The delete fence: the same reach, the delete's own refusal.
    @Test func theDeleteFenceRefusesTheDailyJournalAndPassesEverythingElse() throws {
        try withOperations { ops, db in
            let daily = try journal(ops)
            let plain = try ops.createReading(name: "novel", kind: .book)
            try db.read { db in
                #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: daily)) {
                    try Operations.refuseDeletingTheDailyJournalOnTheWire(db, readingID: daily)
                }
                try Operations.refuseDeletingTheDailyJournalOnTheWire(db, readingID: plain.id)
                try Operations.refuseDeletingTheDailyJournalOnTheWire(db, readingID: "no-such-book")
            }
            // Moving the designation moves the fence with it.
            try ops.setDailyJournalBook(plain.id)
            try db.read { db in
                try Operations.refuseDeletingTheDailyJournalOnTheWire(db, readingID: daily)
                #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: plain.id)) {
                    try Operations.refuseDeletingTheDailyJournalOnTheWire(db, readingID: plain.id)
                }
            }
        }
    }

    /// The fenced act: `delete_book`'s body refuses THE daily Journal inside
    /// its write even past an allowing guard, writes nothing, registers no
    /// entry — while her own door deletes the same book (VX-436).
    @Test func deleteBookForClientRefusesWhereHerDoorDeletes() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let daily = try journal(ops)
            try db.clearOutbox()
            #expect(throws: OperationError.dailyJournalCannotBeDeleted(id: daily)) {
                try ops.deleteBookForClient(daily, undoLabel: "client's book deletion", guardedBy: { _ in })
            }
            #expect(try db.deletedAt("reading", daily) == nil)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0, "nothing written")
            #expect(stack.depth == 0, "no undo entry")
            try ops.deleteReading(daily)
            #expect(try db.deletedAt("reading", daily) != nil, "her door deletes it")
        }
    }
}
