import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-133 (the VX-981 run, batch 2 — a rider, R-981-2; the record
// `notes/plans/fixes/vx-981-mcp-door-followups.md`, BATCH 2 RECORD): THE RECEIPT RUN'S COUNT
// STAYS TRUE. Found at the 13n-b U4 walk: the coalesced line read "u3-walk made 4 changes" where
// three of the four had been walked back — an undo never touched the run. The run is a pure
// value now (`MCPReceiptRun`, moved out of the door with its rule unchanged); her line counts the
// receipts that STAND. RED ON THE SCAFFOLD (`walked` heard nothing): the run kept every act.

private func take(_ entry: Int?, client: String = "claude-code", target: String = "n1", runKey: String? = nil)
    -> MCPWriteReceipt
{
    var receipt = MCPWriteReceipt(clientName: client, act: .take, targetID: target, targetTitle: "ch 1")
    receipt.undoEntryID = entry
    receipt.runKey = runKey
    return receipt
}

private func undo(_ entry: Int, changed: Bool = true) -> UndoStack.Walk {
    UndoStack.Walk(direction: .undo, entryID: entry, label: "claude-code's take", changed: changed)
}

private func redo(_ entry: Int, changed: Bool = true) -> UndoStack.Walk {
    UndoStack.Walk(direction: .redo, entryID: entry, label: "claude-code's take", changed: changed)
}

private let start = Date(timeIntervalSince1970: 1_782_864_000)

@Suite("VX-133 — the receipt run counts the acts that stand")
struct MCPReceiptRunTests {
    /// **RED ON THE SCAFFOLD — the ticket's own case: four acts, three undone → the line says
    /// one.** Then a redo raises it again, and the client's next act joins the run.
    @Test func fourActsThreeUndoneCountsOneAndARedoRaisesItAgain() {
        var run = MCPReceiptRun()
        for (offset, entry) in [11, 12, 13, 14].enumerated() {
            run.land(take(entry), now: start.addingTimeInterval(Double(offset)))
        }
        #expect(run.standing.count == 4)
        for entry in [14, 13, 12] { run.walked(undo(entry)) }
        #expect(run.standing.map(\.undoEntryID) == [11], "RED ON THE SCAFFOLD: \(run.standing.map(\.undoEntryID))")
        run.walked(redo(12))
        #expect(run.standing.map(\.undoEntryID) == [11, 12], "RED ON THE SCAFFOLD: a redo raises it again")
        run.land(take(15), now: start.addingTimeInterval(10))
        #expect(run.standing.map(\.undoEntryID) == [11, 12, 15], "the next act joins the run")
        #expect(run.receipts.count == 5, "the run itself keeps every act it took")
    }

    /// **RED ON THE SCAFFOLD.** A run walked back to NOTHING speaks no stale count: the client's
    /// next act on the same key inside the window joins the run and reads as that one act.
    @Test func aRunWalkedBackToNothingSpeaksNoStaleCount() {
        var run = MCPReceiptRun()
        run.land(take(21), now: start)
        run.land(take(22), now: start.addingTimeInterval(1))
        run.walked(undo(22))
        run.walked(undo(21))
        #expect(run.standing.isEmpty, "RED ON THE SCAFFOLD: nothing stands")
        run.land(take(23), now: start.addingTimeInterval(2))
        #expect(run.standing.map(\.undoEntryID) == [23], "RED ON THE SCAFFOLD: one act, never three")
    }

    /// **A quiet half lowers nothing** (VX-276 — the act's result was already gone, nothing was
    /// written: no act of the run was walked back), and a walk naming no act of the run — her
    /// own entry, another run's — changes nothing. GUARDS (green on both trees).
    @Test func aQuietHalfOrAnotherEntrysWalkChangesNothing() {
        var run = MCPReceiptRun()
        run.land(take(31), now: start)
        run.land(take(32), now: start.addingTimeInterval(1))
        run.walked(undo(32, changed: false))
        run.walked(undo(99))
        run.walked(redo(98))
        #expect(run.standing.map(\.undoEntryID) == [31, 32])
    }

    /// **VX-812's list forms:** a list call's items share one run key, each item its own entry —
    /// an undo of one item lowers the call's count by one, the key unchanged. RED ON THE SCAFFOLD.
    @Test func aListCallsItemUndoneLowersItsCountByOne() {
        var run = MCPReceiptRun()
        for (offset, (entry, note)) in [(41, "n1"), (42, "n2"), (43, "n3")].enumerated() {
            run.land(take(entry, target: note, runKey: "delete_note·call-1"), now: start.addingTimeInterval(Double(offset)))
        }
        run.walked(undo(43))
        #expect(run.standing.map(\.targetID) == ["n1", "n2"], "RED ON THE SCAFFOLD")
    }

    /// **The run's rule, unchanged (13n-b U2):** another client, another target or key, or the
    /// window passed starts a new run. A receipt with no entry token (a commit; an unpaired
    /// stamp) joins and stands. GUARDS (green on both trees).
    @Test func theRunsCoalescingRuleIsUnchanged() {
        var run = MCPReceiptRun()
        run.land(take(51), now: start)
        run.land(take(52, client: "codex"), now: start.addingTimeInterval(1))
        #expect(run.standing.map(\.undoEntryID) == [52], "another client: a new run")
        run.land(take(53, target: "n2", runKey: nil), now: start.addingTimeInterval(2))
        #expect(run.standing.count == 1 && run.receipts.count == 1, "another target: a new run")
        run.land(take(54, target: "n2"), now: start.addingTimeInterval(2 + MCPReceiptRun.window + 1))
        #expect(run.receipts.map(\.undoEntryID) == [54], "the window passed: a new run")
        run.land(take(nil, target: "n2"), now: start.addingTimeInterval(2 + MCPReceiptRun.window + 2))
        #expect(run.standing.map(\.undoEntryID) == [54, nil], "a receipt with no token joins and stands")
        #expect(MCPReceiptRun.window == 120)
    }
}
