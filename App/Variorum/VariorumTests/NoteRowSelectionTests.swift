//
//  NoteRowSelectionTests.swift
//  VariorumTests
//
//  **P-0 — the ⌘-click multi-delete door was DEAD in the shipped build**
//  (13l, the end-of-phase ladder; the architect's adjudication promoted it
//  from the Act 7 walk's propose-only list). Her third clause from the 13j
//  close — *"allow for command clicking to select multiple items and deleting
//  all of them"* — had its act, its confirm, its receipt and its pins, and
//  ⌘-clicking a row simply opened the note.
//
//  ── WHAT THESE PINS REACH, AND WHAT THEY DO NOT ──────────────────────────
//  The defect was a routing decision inside a gesture closure, so the fix
//  made the decision reachable: `LibraryCatalogModel.clickNoteRow` answers
//  "does this click open the note?" and fills the pick. These pins drive that
//  — the real model, the real ordering, the real bulk-bar condition.
//
//  **TWO LINES REMAIN OUT OF REACH AND ARE NAMED RATHER THAN PRETENDED AT:**
//  the `.onTapGesture` that calls in, and `NoteRowClickModifiers.current`'s
//  read of `NSEvent.modifierFlags`. Nothing in this codebase can synthesize a
//  ⌘-click into a SwiftUI `List` row and read the answer reliably. They were
//  verified by driving the RUNNING app instead — the walk's own road — and
//  the ladder record carries what was observed. A pin that claimed to cover
//  them would be exactly the pins-over-dead-wiring class P-0 IS.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withCatalog<T>(
    _ body: @MainActor (LibraryCatalogModel, AppSession) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 19))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        return try await body(LibraryCatalogModel(session: session), session)
    }
}

// MARK: - The rule, on its own

@Suite("What a click on a note row means (13l P-0)")
struct NoteRowSelectionRuleTests {
    @Test func theModifiersDecide() {
        #expect(NoteRowSelection.intent(for: .none) == .open)
        #expect(NoteRowSelection.intent(for: .command_) == .toggle)
        #expect(NoteRowSelection.intent(for: .shift_) == .extendRange)
        // ⌘ wins a ⌘⇧-click: "toggle this one" cannot surprise.
        #expect(NoteRowSelection.intent(
            for: NoteRowClickModifiers(command: true, shift: true)) == .toggle)
    }

    @Test func commandClickAddsAndTakesAway() {
        let order = ["a", "b", "c"]
        var pick = NoteRowSelection.apply(
            .toggle, row: "a", to: [], anchor: nil, order: order)
        #expect(pick.selection == ["a"])
        #expect(pick.anchor == "a")

        pick = NoteRowSelection.apply(
            .toggle, row: "c", to: pick.selection, anchor: pick.anchor, order: order)
        #expect(pick.selection == ["a", "c"])

        pick = NoteRowSelection.apply(
            .toggle, row: "a", to: pick.selection, anchor: pick.anchor, order: order)
        #expect(pick.selection == ["c"], "⌘-clicking a picked row takes it out again")
    }

    @Test func shiftClickTakesTheRangeInTheListsOwnOrder() {
        let order = ["a", "b", "c", "d"]
        let anchored = NoteRowSelection.apply(
            .toggle, row: "b", to: [], anchor: nil, order: order)
        let ranged = NoteRowSelection.apply(
            .extendRange, row: "d", to: anchored.selection,
            anchor: anchored.anchor, order: order)
        #expect(ranged.selection == ["b", "c", "d"])
        #expect(ranged.anchor == "b", "the anchor holds, so the range can be re-aimed")

        // Backwards reads the same: the range is between them, not after one.
        let upward = NoteRowSelection.apply(
            .extendRange, row: "a", to: anchored.selection,
            anchor: anchored.anchor, order: order)
        #expect(upward.selection == ["a", "b"])
    }

    @Test func aShiftClickWithNoAnchorSimplyPicksThatRow() {
        let pick = NoteRowSelection.apply(
            .extendRange, row: "b", to: [], anchor: nil, order: ["a", "b", "c"])
        #expect(pick.selection == ["b"], "a door that did nothing would be worse")
        #expect(pick.anchor == "b")
    }

    /// PROVISIONAL (QUESTIONS #79) — pinned so the ruling has something to
    /// change rather than something to discover.
    @Test func aPlainClickDropsThePick() {
        let pick = NoteRowSelection.apply(
            .open, row: "c", to: ["a", "b"], anchor: "a", order: ["a", "b", "c"])
        #expect(pick.selection.isEmpty)
        #expect(pick.anchor == nil)
    }
}

// MARK: - The routing, driven on the real model

@MainActor
@Suite("The Library's note rows route a ⌘-click to the pick (13l P-0)")
struct NoteRowRoutingTests {
    private func seed(_ session: AppSession, _ titles: [String]) async throws -> [String] {
        try await session.runner.run { ops -> [String] in
            try titles.map { try ops.createPost(title: $0, profile: .generic).id }
        }
    }

    /// **THE PIN THE DEFECT IS ABOUT.** Before the fix, every click — modified
    /// or not — reached `onOpen`, so `selectedPosts` could never fill and the
    /// bulk bar could never appear.
    ///
    /// **Red on old** (behavioural revert): make `clickNoteRow` return `true`
    /// and touch nothing, which is precisely what the shipped gesture did.
    @Test func aCommandClickPicksTheNoteInsteadOfOpeningIt() async throws {
        try await withCatalog { model, session in
            let ids = try await seed(session, ["one", "two", "three"])
            await model.search()
            #expect(Set(model.listedNoteIDs) == Set(ids))

            #expect(model.clickNoteRow(ids[0], modifiers: .command_) == false,
                    "a ⌘-click is not an opening click")
            #expect(model.selectedPosts == [ids[0]])

            #expect(model.clickNoteRow(ids[2], modifiers: .command_) == false)
            #expect(model.selectedPosts == [ids[0], ids[2]])
        }
    }

    /// …and a plain click still opens, which is the half that must not break.
    @Test func aPlainClickStillOpens() async throws {
        try await withCatalog { model, session in
            let ids = try await seed(session, ["one", "two"])
            await model.search()
            #expect(model.clickNoteRow(ids[0], modifiers: .none) == true)
            #expect(model.selectedPosts.isEmpty)
        }
    }

    /// **THE SEAM P-0 NAMES: two picked notes make the bulk doors appear.**
    /// The header renders them on `selectedPosts.count > 1` — the bulk TAG
    /// menu (unreachable since long before 13l) and "Delete N notes…" (13l
    /// Act 2's own build) — and the confirm is built from the pick in LIST
    /// order, never the Set's.
    @Test func twoPickedNotesReachTheBulkBarInListOrder() async throws {
        try await withCatalog { model, session in
            let ids = try await seed(session, ["one", "two", "three"])
            await model.search()
            let listed = model.listedNoteIDs

            model.clickNoteRow(listed[2], modifiers: .command_)
            model.clickNoteRow(listed[0], modifiers: .command_)
            #expect(model.selectedPosts.count > 1, "the bulk bar's own condition")
            #expect(model.selectedNotesInListOrder == [listed[0], listed[2]],
                    "the order she is pointing at, not the hash's")
            _ = ids
        }
    }

    /// A shift-click over the real list takes the run between the two rows.
    @Test func aShiftClickTakesTheRunBetweenTwoRows() async throws {
        try await withCatalog { model, session in
            _ = try await seed(session, ["one", "two", "three", "four"])
            await model.search()
            let listed = model.listedNoteIDs

            model.clickNoteRow(listed[0], modifiers: .command_)
            #expect(model.clickNoteRow(listed[3], modifiers: .shift_) == false)
            #expect(model.selectedNotesInListOrder == listed)
        }
    }

    /// The delete host hands the pick back what it consumed, so the bar goes
    /// away with the notes rather than counting tombstones.
    @Test func deletingThePickEmptiesIt() async throws {
        try await withCatalog { model, session in
            _ = try await seed(session, ["one", "two"])
            await model.search()
            let listed = model.listedNoteIDs
            model.clickNoteRow(listed[0], modifiers: .command_)
            model.clickNoteRow(listed[1], modifiers: .command_)

            model.deselect(model.selectedNotesInListOrder)
            #expect(model.selectedPosts.isEmpty)
            #expect(model.selectionAnchor == nil)
        }
    }

    /// The pick belongs to the LIST mode, which is the only mode that draws
    /// it. Carrying it into Notes or Timeline would leave a destructive bulk
    /// door standing over a selection nothing on screen shows.
    @Test func leavingTheListModeDropsThePick() async throws {
        try await withCatalog { model, session in
            _ = try await seed(session, ["one", "two"])
            await model.search()
            model.clickNoteRow(model.listedNoteIDs[0], modifiers: .command_)
            #expect(!model.selectedPosts.isEmpty)

            model.clearSelection()   // what the view's `.onChange(of: mode)` calls
            #expect(model.selectedPosts.isEmpty)
        }
    }
}
