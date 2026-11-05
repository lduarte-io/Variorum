import Foundation
import GRDB

// **THE WIRE'S JOURNAL FENCE** (R-805-5 — the VX-805 run's kickoff ruling,
// her words: the wire keeps a Journal refusal). VX-435 lifts the operation's
// refusal to MOVE the daily Journal across wings, and VX-436 retires the
// operation's refusal to DELETE it — for HER doors. On the MCP side her
// posture is unchanged: moving the daily Journal across wings, and deleting
// it, stay hers alone. So the refusals move from the operations to the MCP
// door, as SHARED checks every wire act that could reach the Journal calls
// inside its own transaction — never inlined into one tool, so a later tool
// (VX-809's `move_book_to_wing`) gains no capability in any merge order.
//
// Both are worded through the wire's ONE refusal chain
// (`MCPWireRefusalCopy.spoken` — the wire's own words first), and both key on
// `Queries.isTheDailyJournal` (the 'daily' marker OR the designation), read
// INSIDE the caller's transaction, never from a face's projection.
extension Operations {
    /// **The move fence** — any wire act that moves a book (or a wing's
    /// contents holding one) across wings calls this first, inside its
    /// transaction: the daily Journal refuses `dailyJournalMovesOnlyByHand`.
    /// A missing or dead reading passes (the act's own liveness check speaks
    /// for it — the fence never shadows another refusal).
    public static func refuseMovingTheDailyJournalOnTheWire(
        _ db: Database, readingID: String
    ) throws {
        guard let reading = try Reading.fetchOne(db, key: readingID),
              reading.deletedAt == nil,
              try Queries.isTheDailyJournal(db, reading)
        else { return }
        throw OperationError.dailyJournalMovesOnlyByHand(id: readingID)
    }

    /// **The delete fence** — the wire's `delete_book` act and its redo call
    /// this first, inside their transaction: the daily Journal refuses
    /// `dailyJournalCannotBeDeleted` (MCPSpec: "the daily Journal never
    /// deletes"). Same liveness posture as the move fence.
    public static func refuseDeletingTheDailyJournalOnTheWire(
        _ db: Database, readingID: String
    ) throws {
        guard let reading = try Reading.fetchOne(db, key: readingID),
              reading.deletedAt == nil,
              try Queries.isTheDailyJournal(db, reading)
        else { return }
        throw OperationError.dailyJournalCannotBeDeleted(id: readingID)
    }
}
