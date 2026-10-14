import Foundation
import Testing

@testable import VariorumCore

// VX-246 U2 — the STACK's rule, pinned on the new API (state transitions; green
// by construction, written with the rule): a half that changed nothing RETIRES
// its entry and leaves the other stack as it was; a compound runs only the legs
// whose partner changed something. The behaviour pins over real entries are
// `UndoQuietPressTests` (red on the pre-fix tree). The toy halves never touch a
// store, so the stack is driven with a bare `Operations`.

@Suite("VX-246 U2 — UndoStack: a quiet half retires its entry")
struct UndoStackQuietRuleTests {
    /// A toy entry whose halves answer what the test says, counting calls.
    private final class Toy: @unchecked Sendable {
        var undoes = 0, redoes = 0
        var undoChanges = true, redoChanges = true
    }

    private func register(_ toy: Toy, _ label: String, on stack: UndoStack) {
        stack.register(
            label: label,
            inverse: { _ in toy.undoes += 1; return toy.undoChanges },
            redo: { _ in toy.redoes += 1; return toy.redoChanges })
    }

    @Test func aQuietUndoRetiresItsEntryAndLeavesTheRedoStackAsItWas() throws {
        do {
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let first = Toy(), second = Toy()
            register(first, "first", on: stack)
            register(second, "second", on: stack)
            #expect(try stack.undoReporting(with: ops) == UndoStack.Outcome(label: "second", changed: true))
            #expect(stack.redoDepth == 1)

            first.undoChanges = false
            #expect(try stack.undoReporting(with: ops) == UndoStack.Outcome(label: "first", changed: false))
            #expect(stack.depth == 0, "the quiet entry left the undo stack")
            #expect(stack.redoDepth == 1 && stack.topRedoLabel == "second",
                    "it never reached the redo stack, and the redo future stays as it was")
            #expect(try stack.redo(with: ops) == "second")
            #expect(first.redoes == 0, "a redo after a quiet undo never runs")
        }
    }

    @Test func aQuietRedoRetiresItsEntryAndLeavesTheUndoStackAsItWas() throws {
        do {
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let below = Toy(), toy = Toy()
            register(below, "below", on: stack)
            register(toy, "toy", on: stack)
            _ = try stack.undo(with: ops)
            toy.redoChanges = false
            #expect(try stack.redoReporting(with: ops) == UndoStack.Outcome(label: "toy", changed: false))
            #expect(stack.redoDepth == 0)
            #expect(stack.depth == 1 && stack.topLabel == "below", "an undo after a quiet redo never runs over it")
            _ = try stack.undo(with: ops)
            #expect(toy.undoes == 1 && below.undoes == 1)
        }
    }

    @Test func aCompoundRunsOnlyTheLegsWhosePartnerChangedSomething() throws {
        do {
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let a = Toy(), b = Toy()
            try stack.withCompound(label: "both", operations: ops) {
                register(a, "a", on: stack)
                register(b, "b", on: stack)
            }
            b.undoChanges = false
            #expect(try stack.undoReporting(with: ops) == UndoStack.Outcome(label: "both", changed: true), "leg a changed")
            #expect(try stack.redoReporting(with: ops) == UndoStack.Outcome(label: "both", changed: true))
            #expect(a.redoes == 1 && b.redoes == 0, "the quiet leg is never re-applied")
            _ = try stack.undo(with: ops)
            #expect(a.undoes == 2 && b.undoes == 1, "nor undone again")

            a.redoChanges = false
            #expect(try stack.redoReporting(with: ops) == UndoStack.Outcome(label: "both", changed: false),
                    "every leg quiet: the compound retires")
            #expect(stack.depth == 0 && stack.redoDepth == 0)
        }
    }
}
