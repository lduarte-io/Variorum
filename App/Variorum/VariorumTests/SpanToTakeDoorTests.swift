//
//  SpanToTakeDoorTests.swift
//  VariorumTests
//
//  **SELECTION → A TAKE ON THE SAME BLOCK** — the Write door (13u4 UNIT C2;
//  her item 9, ruled R-13u4-4). Two halves, pinned apart:
//
//  · the ONE BRAIN (`SpanToTakeGesture.plan`) over a tiling — which is what
//    decides whether the doors RENDER (P-2), so every "the door is not there"
//    claim is a pin here rather than a walk note;
//  · the DOOR through the real editor pipeline — the span leaves the surface,
//    the fan grows, the mint is unchosen, the savepoint exists, and the whole
//    thing is ONE ⌥⌘Z.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("Selection → a take (13u4 UNIT C2, R-13u4-4)")
struct SpanToTakeGesturePlanTests {

    private func index(_ slots: [Queries.RenderedBlock], tail: String? = nil) -> BlockRangeIndex {
        BlockRangeIndex(slots: slots, tail: tail)
    }

    /// "one two three" · "second block" — entry 0 is [0, 13), the separator
    /// is at 13, entry 1 starts at 14.
    private var twoBlocks: [Queries.RenderedBlock] {
        [slot("b1", text: "one two three"), slot("b2", text: "second block")]
    }

    @Test func aSelectionInsideOneBlockPlansWithItsIntraBlockSpan() {
        let plan = SpanToTakeGesture.plan(
            selection: NSRange(location: 4, length: 3), index: index(twoBlocks))
        #expect(plan?.entryIndex == 0)
        #expect(plan?.blockID == "b1")
        #expect(plan?.variantID == "v-b1")
        #expect(plan?.intraRange == NSRange(location: 4, length: 3))
    }

    /// The SECOND block's span comes back in ITS own coordinates — the
    /// document offset is not the intra offset, and the operation is handed
    /// the intra one.
    @Test func aSpanInTheSecondBlockIsReportedInThatBlocksOwnOffsets() {
        let plan = SpanToTakeGesture.plan(
            selection: NSRange(location: 21, length: 5), index: index(twoBlocks))
        #expect(plan?.entryIndex == 1)
        #expect(plan?.intraRange == NSRange(location: 7, length: 5))
    }

    /// **The P-2 half, and the brief's own words: a cross-block selection is
    /// NOT this gesture — so the doors are absent there, not present and
    /// refusing.** That population belongs to Make Block from Selection.
    @Test func aSelectionCrossingTwoBlocksDoesNotPlan() {
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 9, length: 10), index: index(twoBlocks)) == nil)
    }

    @Test func aCaretAloneDoesNotPlan() {
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 4, length: 0), index: index(twoBlocks)) == nil)
    }

    /// A shift-selection routinely swallows the separator between two blocks.
    /// The separator belongs to no block (the `EditorDocument` doctrine), so
    /// the gesture still names exactly one block's text and the plan is that
    /// text — the same tolerance every span gesture gets.
    @Test func aSwallowedSeparatorIsShruggedOffRatherThanRefused() {
        // [4, 14) = "two three" + the separator at 13.
        let plan = SpanToTakeGesture.plan(
            selection: NSRange(location: 4, length: 10), index: index(twoBlocks))
        #expect(plan?.entryIndex == 0)
        #expect(plan?.intraRange == NSRange(location: 4, length: 9))
    }

    /// The open tail is not a block yet — there is no take for a span to
    /// leave (idle-mint makes one within seconds).
    @Test func aSelectionTouchingTheOpenTailDoesNotPlan() {
        let withTail = index([slot("b1", text: "one two")], tail: "not a block yet")
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 8, length: 5), index: withTail) == nil)
        // …and a span that only touches the BLOCK still plans beside it.
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 0, length: 3), index: withTail) != nil)
    }

    /// A gap slot has no take to move a span out of, so the door can never
    /// act there (P-2) and does not render.
    ///
    /// **Two pins, because a real gap slot renders ZERO-LENGTH** (its text is
    /// nil, so no selection can strictly intersect it): the first is the
    /// shape the projection actually produces — the gap sits between two
    /// blocks and no span ever names it — and the second drives the guard
    /// itself through a hand-built tiling, so "a slot with no take does not
    /// plan" is asserted rather than assumed unreachable.
    @Test func aGapSlotDoesNotPlan() {
        let withGap = index([
            slot("b1", text: "one two"), slot("b2", text: nil), slot("b3", text: "three"),
        ])
        // The gap's own offset (8) carries no characters — a selection over
        // it names its NEIGHBOURS or nothing at all.
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 8, length: 0), index: withGap) == nil)
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 4, length: 3), index: withGap)?.entryIndex == 0)

        let takeless = BlockRangeIndex(
            entries: [.init(blockID: "b1", variantID: nil, length: 8, editable: false)],
            tailLength: nil)
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 0, length: 4), index: takeless) == nil)
    }

    /// Selecting a block WHOLE is legal — the take it leaves is emptied, and
    /// an empty buffer is legal (the op's own pin says I10 holds).
    @Test func aWholeBlockSelectionPlans() {
        let plan = SpanToTakeGesture.plan(
            selection: NSRange(location: 0, length: 13), index: index(twoBlocks))
        #expect(plan?.intraRange == NSRange(location: 0, length: 13))
    }

    /// A selection reaching past the document is the desync class: nothing
    /// plans, nothing crashes.
    @Test func aSelectionPastTheDocumentDoesNotPlan() {
        #expect(SpanToTakeGesture.plan(
            selection: NSRange(location: 20, length: 99), index: index(twoBlocks)) == nil)
    }

    /// P1: the walk stops at the selection's own entry. An irregular tiling
    /// with the span in block 1 of 400 must answer without visiting 399
    /// entries — pinned by ASKING for a plan whose answer proves the early
    /// return did not change the verdict, at a size where an O(document)
    /// walk would be the only other explanation for a correct answer.
    @Test func theWalkStopsAtTheSelectionsOwnEntry() {
        let many = (0..<400).map { slot("b\($0)", text: "block number \($0)") }
        let plan = SpanToTakeGesture.plan(
            selection: NSRange(location: 6, length: 6), index: index(many))
        #expect(plan?.entryIndex == 0)
        #expect(plan?.intraRange == NSRange(location: 6, length: 6))
    }
}

@MainActor
@Suite("Selection → a take: the Write door (13u4 UNIT C2)")
struct SpanToTakeDoorTests {

    /// **THE ACT, through the production pipeline**: the span leaves the
    /// surface AND the store, a second take holds it, and nothing chose it.
    @Test func theSelectedSpanLeavesTheBlockAndBecomesATakeOnIt() async throws {
        try await withEditor(seedBlocks: ["one two three four"]) { harness in
            try harness.reload()
            harness.textView.setSelectedRange(NSRange(location: 3, length: 10))
            await harness.model.moveSelectionToNewTake()

            #expect(harness.documentText == "one four", "the surface agrees with the store")
            let slots = try harness.storeSlots()
            #expect(slots.count == 1)
            #expect(slots[0].text == "one four")
            #expect(slots[0].activeVariantCount == 2, "the block carries a fan now")

            let fan = try await harness.database.read { db in
                try Queries.blockFan(db, blockID: slots[0].blockID)
            }
            #expect(fan.map(\.workingText) == ["one four", " two three"])
            #expect(fan[1].id != slots[0].variantID, "and the new take is NOT the chosen one")
            #expect(fan[1].parentVariantId == fan[0].id)
            #expect(fan[1].locked == false)
        }
    }

    /// Her ruled cover for the stay case, at the door: a savepoint of the
    /// take one keystroke before the move, and a receipt that says so.
    @Test func theTakeItLeftIsSavedFirstAndTheReceiptSaysSo() async throws {
        try await withEditor(seedBlocks: ["one two three four"]) { harness in
            try harness.reload()
            harness.textView.setSelectedRange(NSRange(location: 3, length: 10))
            await harness.model.moveSelectionToNewTake()

            let slots = try harness.storeSlots()
            let variantID = try #require(slots[0].variantID)
            let saved = try await harness.database.read { db in
                try Queries.commitHistory(db, variantID: variantID)
            }
            #expect(saved.map(\.text) == ["one two three four"])
            #expect(saved[0].kind == .auto)
            let message = try #require(harness.model.statusMessage)
            #expect(message.contains("saved first"))
            #expect(message.contains("\u{2325}\u{2318}Z"))
        }
    }

    /// ONE gesture, ONE entry on the structural stack — never two (a mint
    /// and an edit).
    @Test func theWholeGestureIsOneStructuralUndoEntry() async throws {
        try await withEditor(seedBlocks: ["one two three four"]) { harness in
            try harness.reload()
            let before = harness.session.undoStack.depth
            harness.textView.setSelectedRange(NSRange(location: 3, length: 10))
            await harness.model.moveSelectionToNewTake()

            #expect(harness.session.undoStack.depth == before + 1)
            #expect(harness.session.undoStack.topLabel == "Move into a New Take")
        }
    }

    /// The door RENDERS only where the act can happen (P-2) — and the
    /// context menu is built fresh at open time, so the row follows the
    /// selection.
    @Test func theContextRowAppearsOnlyForASelectionInsideOneBlock() async throws {
        try await withEditor(seedBlocks: ["one two three", "second block"]) { harness in
            try harness.reload()
            let verb = CapabilityRegistry.capability(.moveSelectionToTake).verb
            @MainActor func rowShows() -> Bool {
                harness.model.contextMenuItems().contains { $0.title.contains(verb) }
            }

            harness.textView.setSelectedRange(NSRange(location: 4, length: 3))
            #expect(rowShows(), "a span inside one block")

            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            #expect(!rowShows(), "a caret alone is not this gesture")

            harness.textView.setSelectedRange(NSRange(location: 9, length: 10))
            #expect(!rowShows(), "and a cross-block span belongs to another act")
        }
    }

    /// The bar's `block ▾` row reads the same verdict (the availability fact
    /// the menu renders from), so the two doors can never disagree.
    @Test func theBarsAvailabilityFactFollowsTheSelection() async throws {
        try await withEditor(seedBlocks: ["one two three", "second block"]) { harness in
            try harness.reload()
            harness.textView.setSelectedRange(NSRange(location: 4, length: 3))
            harness.model.updateCaretContext()
            #expect(harness.model.gestureAvailability.moveToTake)

            harness.textView.setSelectedRange(NSRange(location: 9, length: 10))
            harness.model.updateCaretContext()
            #expect(!harness.model.gestureAvailability.moveToTake)
        }
    }

    /// A door that fires where the act cannot happen delivers the real
    /// refusal (P-2's other half) — and the note is untouched.
    @Test func aSealedNoteRefusesAndChangesNothing() async throws {
        try await withEditor(seedBlocks: ["one two three four"]) { harness in
            try harness.reload()
            try harness.session.operations.lockPost(harness.postID)
            try harness.reload()

            harness.textView.setSelectedRange(NSRange(location: 3, length: 10))
            await harness.model.moveSelectionToNewTake()

            #expect(harness.model.statusMessage?.contains("sealed") == true)
            let slots = try harness.storeSlots()
            #expect(slots[0].text == "one two three four")
            #expect(slots[0].activeVariantCount == 1)
        }
    }

    /// The selection can move under an OPEN menu, so the fired door still
    /// speaks — naming the road that owns the shape it found.
    @Test func aCrossBlockSpanFiredAnywaySpeaksAndNamesTheOtherRoad() async throws {
        try await withEditor(seedBlocks: ["one two three", "second block"]) { harness in
            try harness.reload()
            harness.textView.setSelectedRange(NSRange(location: 9, length: 10))
            await harness.model.moveSelectionToNewTake()

            let message = try #require(harness.model.statusMessage)
            #expect(message.contains("crosses a block boundary"))
            #expect(message.contains("\u{2318}\u{21e7}K") || message.contains("Make Block"))
            #expect(try harness.storeSlots().allSatisfy { $0.activeVariantCount == 1 })
        }
    }

    /// The registry's own row, so the declaration cannot quietly drift from
    /// what this unit built: two doors, both Write's, and NO chord (the
    /// sweep's recorded result).
    @Test func theActIsDeclaredWithItsTwoWriteDoorsAndNoChord() {
        let capability = CapabilityRegistry.capability(.moveSelectionToTake)
        #expect(capability.doors == [.contextMenu, .bottomBar])
        #expect(capability.shortcutLabel == nil)
        #expect(capability.scope == .block)
        #expect(capability.availability(
            CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(capability.availability(CapabilityContext(mode: .write)) == .unavailable,
                "attachment only — enablement never outruns the editor it calls")
        #expect(capability.availability(CapabilityContext(mode: .takes)) == .unavailable)
    }
}
