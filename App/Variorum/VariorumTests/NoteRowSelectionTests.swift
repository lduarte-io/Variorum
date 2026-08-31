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
        // Act 10 item 10 — her click model: a plain body click SELECTS
        // (the panel follows); the title and a double-click open.
        #expect(NoteRowSelection.intent(for: .none) == .select)
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

    /// **#79's PROVISIONAL, RESOLVED by her Act 10 item 10 ruling:** a
    /// plain click REPLACES the pick with the clicked row (select + show
    /// info) — the pick still has its exit, and the panel always describes
    /// the row she last touched.
    @Test func aPlainClickReplacesThePickWithThatRow() {
        let pick = NoteRowSelection.apply(
            .select, row: "c", to: ["a", "b"], anchor: "a", order: ["a", "b", "c"])
        #expect(pick.selection == ["c"])
        #expect(pick.anchor == "c")
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

            model.clickNoteRow(ids[0], modifiers: .command_)
            #expect(model.selectedPosts == [ids[0]])

            model.clickNoteRow(ids[2], modifiers: .command_)
            #expect(model.selectedPosts == [ids[0], ids[2]])
        }
    }

    /// …and a plain body click SELECTS and feeds the info panel (Act 10
    /// item 10 — her ruled model; opening moved to the title, the
    /// double-click and the panel's own door).
    @Test func aPlainClickSelectsAndShowsTheInfoPanel() async throws {
        try await withCatalog { model, session in
            let ids = try await seed(session, ["one", "two"])
            await model.search()
            model.clickNoteRow(ids[0], modifiers: .none)
            #expect(model.selectedPosts == [ids[0]])
            #expect(model.infoHit?.id == ids[0], "the panel follows the click")
            #expect(model.infoHit?.kind == .post)
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
            model.clickNoteRow(listed[3], modifiers: .shift_)
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

    /// **R2-2 (the ladder's round 2): the pick follows the LISTING, not just
    /// the mode.** `search()` re-reads `hits` on every typed query and scope
    /// change; nothing touched `selectedPosts`, so a note picked under one
    /// query stayed picked under the next — where its row is not drawn. The
    /// bulk bar's condition is `selectedPosts.count > 1`, and the Tag/Untag
    /// menus act on `Array(selectedPosts)`, so the doors stood over notes
    /// nothing on screen highlighted and their labels disagreed with the
    /// delete button's own `selectedNotesInListOrder`.
    ///
    /// **Red on old** (behavioural revert: drop the `pruneSelectionToListing()`
    /// call after `hits = filtered(all)`) — the pick survives at 2 and the
    /// bulk bar's condition stays true over one visible row.
    @Test func aPickDoesNotSurviveIntoAListingThatDoesNotShowIt() async throws {
        try await withCatalog { model, session in
            let ids = try await seed(session, ["alpha one", "beta two"])
            await model.search()
            #expect(model.listedNoteIDs.count == 2)
            model.clickNoteRow(ids[0], modifiers: .command_)
            model.clickNoteRow(ids[1], modifiers: .command_)
            #expect(model.selectedPosts.count > 1, "the bulk bar's own condition, before")

            // She types a query that lists only one of them.
            model.query = "beta"
            await model.search()

            #expect(model.listedNoteIDs == [ids[1]], "the premise: one row is drawn")
            #expect(model.selectedPosts == [ids[1]],
                    "the pick is exactly what the list is showing")
            #expect((model.selectedPosts.count > 1) == false,
                    "so the destructive bulk bar is gone with the rows it named")
            #expect(model.selectedNotesInListOrder == [ids[1]],
                    "and the count in the label can no longer disagree with what deletes")
        }
    }

    /// The other half of R2-2, and the reason it PRUNES rather than clears:
    /// `search()` also re-runs after a bulk tag apply and after a delete, so a
    /// pick whose rows are all still listed must survive its own act.
    @Test func aPickWhoseRowsAreStillListedSurvivesTheRefresh() async throws {
        try await withCatalog { model, session in
            _ = try await seed(session, ["one", "two", "three"])
            await model.search()
            let listed = model.listedNoteIDs
            model.clickNoteRow(listed[0], modifiers: .command_)
            model.clickNoteRow(listed[1], modifiers: .command_)

            await model.search()   // what a bulk tag apply spawns

            #expect(model.selectedNotesInListOrder == [listed[0], listed[1]])
            #expect(model.selectionAnchor == listed[1], "the ⇧-range can still be aimed")
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
