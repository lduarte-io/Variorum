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
            // 13g batch 5: settle on the LAST signal in the chain. The stack
            // moves inside the runner's actor hop; the status is spoken only
            // after the door's main-actor continuation resumes, so waiting on
            // `depth == 0` can exit before the report exists (the traced
            // shell-redo flake, same door, same window).
            // 18i: "Undid: …" is a receipt — read it wherever it landed.
            await settle { h.session.status.spoken?.text.contains("Undid") == true }

            #expect(try h.storeSlots().compactMap(\.text) == ["First sentence. Second one."])
            #expect(h.session.undoStack.depth == 0)
            #expect(h.session.status.spoken?.text.contains("Undid") == true)
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
            // Same rule as above: the report is the last signal, so it is
            // the one to wait on.
            await settle { h.session.status.spoken?.text.contains("Redid") == true }
            let slots = try h.storeSlots().compactMap(\.text)
            #expect(slots == ["First sentence.", "Second one."])
            #expect(h.session.undoStack.redoDepth == 0)
            #expect(h.session.status.spoken?.text.contains("Redid") == true)
        }
    }

    // MARK: - 18k C5 (17e P33): one flight at a time — the phone's rule

    /// Divides the SECOND block too, with nothing edited after — a clean
    /// entry E on top of `divideThenEdit`'s insurance-class entry E−1.
    private func divideTheSecondBlockCleanly(_ h: EditorHarness) async throws {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: 1).location + 7, length: 0))
        h.model.updateCaretContext()
        await h.model.invokeGesture(.divideAtCursor)
        await h.flush()
        #expect(h.session.undoStack.depth == 2, "E−1 (edited since) under E (clean)")
    }

    /// Bounded quiescence: long enough for a second in-flight undo to land
    /// on the unlatched door, short enough that the latched door (where
    /// nothing is left in flight) only waits it out.
    private func quiesce(_ predicate: () -> Bool) async {
        for _ in 0..<300 where !predicate() {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    /// **THE P33 pin.** The door reads the stack TWICE across two runner
    /// submissions — the A12 warning, then the undo — and used to hold no
    /// latch. Two ⌥⌘Z presses therefore queued as warn, warn, undo, undo:
    /// both warnings described E (clean, so silent), and the second press
    /// undid E−1 — the entry whose buffer she had edited since — without the
    /// confirm her A12 ruling puts in front of exactly that. The phone's
    /// door holds one flight at a time (`MobileUndoDoor.beginUndo`); this is
    /// the Mac adopting it: the second press refuses in the phone's words.
    ///
    /// RED-ON-OLD (behavioural revert R1-i4, recorded in the 18k C5 record):
    /// no refusal, both entries undone, E−1's writing set aside unasked.
    @Test func twoUndoPressesInFlightNeverUndoAnUnwarnedEntry() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let actions = ShellActions(session: h.session, shell: ShellRouter())
            try await divideThenEdit(h)
            let afterFirstDivide = try h.storeSlots().compactMap(\.text)
            try await divideTheSecondBlockCleanly(h)

            let asked = Box<[UndoStack.PendingUndoWarning]>([])
            let confirm: (UndoStack.PendingUndoWarning) -> Bool = { warning in
                asked.value.append(warning)
                return false        // anything asked is cancelled
            }
            // Two presses inside one runner round-trip — the gesture, exactly.
            actions.structuralUndo(confirm: confirm)
            actions.structuralUndo(confirm: confirm)
            #expect(h.session.status.current?.text == StructuralUndoCopy.anotherIsLanding,
                    "the second press refuses at once, in the phone's words")

            await settle { h.session.status.spoken?.text.contains("Undid") == true }
            await quiesce { h.session.undoStack.depth == 0 }

            #expect(h.session.undoStack.depth == 1,
                    "ONE press undid ONE entry — E−1 was never undone behind her back")
            #expect(try h.storeSlots().compactMap(\.text) == afterFirstDivide,
                    "the writing she did after the first divide is still on the page")
            #expect(asked.value.isEmpty, "E was clean, so nothing was asked — and nothing else ran")

            // The latch releases with the flight: the NEXT press is ordinary,
            // and it asks about E−1, because E−1 is in the insurance class.
            actions.structuralUndo(confirm: confirm)
            await settle { h.session.status.current?.text.contains("cancelled") == true }
            #expect(asked.value.map(\.label) == ["Divide"], "the next press asks about E−1")
            #expect(h.session.undoStack.depth == 1, "and her cancel changed nothing")
        }
    }

    /// **The redo door, crossing an undo's flight** — the same shape across
    /// two doors, which is why the phone's ONE latch covers both. ⇧⌥⌘Z
    /// pressed inside ⌥⌘Z's warn→act gap used to land between them: the
    /// confirm she answered was about E−1, and the undo then took the entry
    /// the redo had just re-applied. Now the redo refuses while the undo is
    /// in flight, and the undo does exactly what she was asked about.
    ///
    /// RED-ON-OLD (R1-i4): no refusal; she approved discarding E−1's writing,
    /// and E was undone instead while E−1 stayed.
    @Test func aRedoPressedInsideAnUndosFlightRefusesAndTheUndoDoesWhatItAsked() async throws {
        try await withEditor(seedBlocks: ["First sentence. Second one."]) { h in
            let actions = ShellActions(session: h.session, shell: ShellRouter())
            try await divideThenEdit(h)
            try await divideTheSecondBlockCleanly(h)
            // Undo E alone (clean — nothing asked): E−1 is on top, E is redoable.
            actions.structuralUndo(confirm: { _ in true })
            await settle {
                h.session.undoStack.redoDepth == 1
                    && h.session.status.spoken?.text.contains("Undid") == true
            }
            #expect(h.session.undoStack.depth == 1)

            let asked = Box<[UndoStack.PendingUndoWarning]>([])
            actions.structuralUndo(confirm: { warning in
                asked.value.append(warning)
                return true         // she approves discarding E−1's writing
            })
            actions.structuralRedo()
            #expect(h.session.status.current?.text == StructuralUndoCopy.anotherIsLanding,
                    "the redo refuses while the undo is in flight")

            await settle { !asked.value.isEmpty }
            await quiesce { h.session.undoStack.depth == 0 }

            #expect(asked.value.map(\.label) == ["Divide"], "she was asked about E−1")
            #expect(h.session.undoStack.depth == 0, "…and E−1 is what was undone")
            #expect(h.session.undoStack.redoDepth == 2, "both entries are redoable, in order")
            #expect(try h.storeSlots().compactMap(\.text) == ["First sentence. Second one."],
                    "the page is back to the one block she started with")
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
