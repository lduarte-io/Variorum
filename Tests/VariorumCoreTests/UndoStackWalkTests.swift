import Foundation
import Testing

@testable import VariorumCore

// VX-133 (the VX-981 run, batch 2 — the record `notes/plans/fixes/vx-981-mcp-door-followups.md`,
// BATCH 2 RECORD): the stack's half of "the receipt run's count stays true". An entry's
// registration token is READ (`newestEntryID`, `entryIDs(newerThan:)` — what one act registered),
// and every completed undo and redo is TOLD to its observers with that token and whether it
// changed anything (`UndoStack.Walk`), so the MCP door can take a walked-back act out of a
// client's count. RED ON THE SCAFFOLD (the observers registered, never told); the reads are new
// contract. Toy halves, a bare `Operations` (UndoStackQuietRuleTests' posture).

@Suite("VX-133 — UndoStack: an entry's token, and every walk told with it")
struct UndoStackWalkTests {
    private final class Toy: @unchecked Sendable {
        var undoChanges = true, redoChanges = true
    }

    private func register(_ toy: Toy, _ label: String, on stack: UndoStack, redoable: Bool = true) {
        stack.register(
            label: label,
            inverse: { _ in toy.undoChanges },
            redo: redoable ? { _ in toy.redoChanges } : nil)
    }

    /// The tokens: nil on an empty stack; each registration's token newer than everything before
    /// it; `entryIDs(newerThan:)` names exactly what registered since a read (a compound: its ONE
    /// entry, never its legs). A NEW-CONTRACT pin.
    @Test func aRegistrationsTokenIsReadAndBoundsWhatAnActRegistered() throws {
        let stack = UndoStack()
        let ops = Operations(undoStack: stack)
        #expect(stack.newestEntryID == nil && stack.entryIDs(newerThan: nil).isEmpty)
        register(Toy(), "first", on: stack)
        let first = try #require(stack.newestEntryID)
        let before = stack.newestEntryID
        register(Toy(), "second", on: stack)
        register(Toy(), "third", on: stack)
        let since = stack.entryIDs(newerThan: before)
        #expect(since.count == 2 && since.allSatisfy { $0 > first } && since == since.sorted(), "\(since)")
        #expect(stack.entryIDs(newerThan: nil).first == first, "nil reads every entry, oldest first")
        let beforeCompound = stack.newestEntryID
        try stack.withCompound(label: "both", operations: ops) {
            register(Toy(), "leg a", on: stack)
            register(Toy(), "leg b", on: stack)
        }
        #expect(stack.entryIDs(newerThan: beforeCompound) == [stack.newestEntryID].compactMap { $0 },
                "a compound registered ONE entry")
        // An undone entry leaves the undo stack; the next registration is newer than it still.
        let top = try #require(stack.newestEntryID)
        _ = try stack.undo(with: ops)
        register(Toy(), "fourth", on: stack)
        #expect(try #require(stack.newestEntryID) > top, "tokens only grow")
    }

    /// **RED ON THE SCAFFOLD.** Every completed press is told — an undo and a redo that changed
    /// something, and a QUIET undo (its entry retired, `changed: false`) — each with the entry's
    /// own token and label, to every observer; a removed observer hears nothing more; a FAILED
    /// half (its entry stays for retry) is never told.
    @Test func everyCompletedWalkIsToldWithItsEntrysToken() throws {
        let stack = UndoStack()
        let ops = Operations(undoStack: stack)
        let heard = LockedWalks(), also = LockedWalks()
        let token = stack.addWalkObserver { heard.append($0) }
        stack.addWalkObserver { also.append($0) }

        let quiet = Toy()
        register(quiet, "below", on: stack)
        let belowID = try #require(stack.newestEntryID)
        register(Toy(), "act", on: stack)
        let actID = try #require(stack.newestEntryID)

        _ = try stack.undoReporting(with: ops)
        _ = try stack.redoReporting(with: ops)
        _ = try stack.undoReporting(with: ops)
        quiet.undoChanges = false
        _ = try stack.undoReporting(with: ops)
        #expect(heard.value == [
            UndoStack.Walk(direction: .undo, entryID: actID, label: "act", changed: true),
            UndoStack.Walk(direction: .redo, entryID: actID, label: "act", changed: true),
            UndoStack.Walk(direction: .undo, entryID: actID, label: "act", changed: true),
            UndoStack.Walk(direction: .undo, entryID: belowID, label: "below", changed: false),
        ], "RED ON THE SCAFFOLD: \(heard.value)")
        #expect(also.value == heard.value, "every observer hears every walk")

        stack.removeWalkObserver(token)
        _ = try stack.redoReporting(with: ops)
        #expect(heard.value.count == 4, "a removed observer hears nothing more")
        #expect(also.value.last == UndoStack.Walk(direction: .redo, entryID: actID, label: "act", changed: true))

        // A failed half is never told: its entry stays for retry.
        stack.register(label: "fails", inverse: { _ in throw OperationError.containerNotFound(id: "x") }, redo: nil)
        let told = also.value.count
        #expect(throws: OperationError.self) { _ = try stack.undoReporting(with: ops) }
        #expect(also.value.count == told && stack.topLabel == "fails")
    }
}

/// Walks heard on whatever thread walked (the stack calls out of its lock).
private final class LockedWalks: @unchecked Sendable {
    private let lock = NSLock()
    private var walks: [UndoStack.Walk] = []
    func append(_ walk: UndoStack.Walk) { lock.withLock { walks.append(walk) } }
    var value: [UndoStack.Walk] { lock.withLock { walks } }
}
