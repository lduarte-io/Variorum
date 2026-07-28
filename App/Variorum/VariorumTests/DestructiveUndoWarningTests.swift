//
//  DestructiveUndoWarningTests.swift
//  VariorumTests
//
//  13d batch 5 — **A12, the destructive-undo warning** (author ruling, the
//  2026-07-28 sitting), at exactly her definition: the confirm fires ONLY
//  when the undo would discard text edited since the operation — the case
//  the fourth quiet auto-commit occasion insures — and every other
//  structural undo stays silent. Redo is untouched.
//
//  The core half (which undos are in the class) is pinned in
//  `UndoStackTests`; these are the DOOR's pins: it asks, it obeys the
//  answer, and a cancel leaves everything exactly as it was.
//

import AppKit
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// A main-actor box: the confirm closure runs on the main actor with the
/// test, so nothing here needs a lock.
@MainActor
private final class Box<T> {
    var value: T
    init(_ value: T) { self.value = value }
}

@MainActor
@Suite("A12 — the destructive-undo warning (13d batch 5)")
struct DestructiveUndoWarningTests {
    /// Waits for a `structuralUndo` Task to settle (bounded — the standing
    /// async-poll rule; never a sync RunLoop pump).
    private func settle(_ predicate: () -> Bool) async {
        for _ in 0..<2000 where !predicate() {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    /// Divides, then edits the first half — the insurance class.
    private func divideThenEdit(_ h: EditorHarness) async throws {
        h.textView.setSelectedRange(NSRange(location: 16, length: 0))
        h.model.updateCaretContext()
        await h.model.invokeGesture(.divideAtCursor)
        await h.flush()
        #expect(h.session.undoStack.topLabel == "Divide")
        h.type(" rewritten", at: 15)
        await h.flush()
    }

    @Test func theDoorAsksBeforeDiscardingWritingAndACancelChangesNothing() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let actions = ShellActions(session: h.session, shell: ShellRouter())
            try await divideThenEdit(h)

            let before = try h.storeSlots().compactMap(\.text)
            let asked = Box<UndoStack.PendingUndoWarning?>(nil)
            actions.structuralUndo(confirm: { warning in
                asked.value = warning
                return false        // she cancels
            })
            await settle { h.session.status.current?.text.contains("cancelled") == true }

            let warning = try #require(asked.value, "the door ASKED before discarding")
            #expect(warning.label == "Divide")
            #expect(warning.bufferCount == 1)
            // Nothing moved: not the store, not the stack, not the redo future.
            #expect(try h.storeSlots().compactMap(\.text) == before)
            #expect(h.session.undoStack.depth == 1)
            #expect(h.session.undoStack.redoDepth == 0)
            #expect(h.session.status.current?.text.contains("cancelled") == true)
        }
    }

    @Test func approvingRunsTheOrdinaryUndoWithItsInsuranceIntact() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let actions = ShellActions(session: h.session, shell: ShellRouter())
            try await divideThenEdit(h)

            actions.structuralUndo(confirm: { _ in true })
            await settle { h.session.undoStack.depth == 0 }

            #expect(try h.storeSlots().compactMap(\.text) == ["First sentence. Second one."])
            #expect(h.session.status.current?.text.contains("Undid") == true)
            // The set-aside writing is one restore away — the fourth quiet
            // auto-commit occasion, unchanged by the warning.
            let commits = try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT text FROM commit_point")
            }
            #expect(commits.contains { $0.contains("rewritten") },
                    "the insurance commit holds what the undo set aside")
        }
    }

    /// The "only" half: an undo with nothing edited since never asks — the
    /// ordinary case must not grow a dialog.
    @Test func anOrdinaryUndoIsNeverInterrupted() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let actions = ShellActions(session: h.session, shell: ShellRouter())
            h.textView.setSelectedRange(NSRange(location: 16, length: 0))
            h.model.updateCaretContext()
            await h.model.invokeGesture(.divideAtCursor)
            await h.flush()

            let asked = Box(false)
            actions.structuralUndo(confirm: { _ in
                asked.value = true
                return false
            })
            await settle { h.session.undoStack.depth == 0 }

            #expect(asked.value == false, "no edit since the divide ⇒ no question")
            let slots = try h.storeSlots().compactMap(\.text)
            #expect(slots == ["First sentence. Second one."])
        }
    }

    /// REDO is untouched by the ruling — it re-applies what the undo undid,
    /// and asking about that would be asking about her own correction.
    @Test func redoNeverAsks() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let actions = ShellActions(session: h.session, shell: ShellRouter())
            try await divideThenEdit(h)
            actions.structuralUndo(confirm: { _ in true })
            await settle { h.session.undoStack.redoDepth == 1 }

            actions.structuralRedo()
            await settle { h.session.undoStack.redoDepth == 0 }
            let slots = try h.storeSlots().compactMap(\.text)
            #expect(slots == ["First sentence.", "Second one."])
            #expect(h.session.status.current?.text.contains("Redid") == true)
        }
    }

    /// The dialog's words name what would be set aside AND where it goes —
    /// pure copy, so it is readable without a window.
    @Test func theDialogNamesWhatIsSetAsideAndWhereItLands() {
        let one = UndoStack.PendingUndoWarning(label: "Divide", bufferCount: 1)
        #expect(ShellActions.discardingUndoQuestion(one) == "Undo Divide?")
        let detail = ShellActions.discardingUndoDetail(one)
        #expect(detail.contains("One take has been edited"))
        #expect(detail.contains("set aside"))
        #expect(detail.contains("history"), "it says where the writing goes")

        let many = UndoStack.PendingUndoWarning(label: "Make Block", bufferCount: 3)
        #expect(ShellActions.discardingUndoDetail(many).contains("3 takes have been edited"))
        #expect(ShellActions.discardingUndoQuestion(many) == "Undo Make Block?")
    }
}
