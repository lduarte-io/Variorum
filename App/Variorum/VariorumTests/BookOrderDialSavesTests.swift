//
//  BookOrderDialSavesTests.swift
//  VariorumTests
//
//  VX-1040 (the VX-1036 run, batch 1 — D-1 as drawn, R-1036-33; her R-1036-2:
//  "i do think that it should maybe automatically save as the book's order …
//  maybe save as this book's order should be a choice when you're changing the
//  manual order"). The order dial, per book kind: a pick SAVES at once on a
//  gathering and on a book whose order is not manual; on a HAND-ORDERED book it
//  stays a look with "Save as This Book's Order" and "Back to manual order"
//  both in plain sight; a FINISHED book looks and cannot save, its menu exactly
//  as before. A FEATURE, so its pins are the menu's rows as data (the dial
//  draws exactly these — `BookOrderDial.menu`), the grammar each book row
//  selects, the receipt's words, the save's state, and the one declaration.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1040 — the order dial saves where her pick is the order, and looks on a hand-ordered book")
struct BookOrderDialSavesTests {
    private typealias Dial = BookOrderDial
    private let manual = Queries.ReadingOrder(field: .manual, direction: .asc)
    private let createdDown = Queries.ReadingOrder(field: .createdAt, direction: .desc)
    private let entryUp = Queries.ReadingOrder(field: .entryDate, direction: .asc)

    private func reading(_ kind: ReadingKind, _ field: SortField = .manual, locked: Bool = false) -> Reading {
        Reading(
            id: "r", name: "r", kind: kind, sortField: field, locked: locked,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    }

    private func labels(_ items: [Dial.MenuItem]) -> [String] {
        items.compactMap { if case .item(let label, _, _) = $0 { label } else { nil } }
    }

    private func act(_ items: [Dial.MenuItem], _ label: String) -> Dial.Act? {
        for item in items { if case .item(label, _, let act) = item { return act } }
        return nil
    }

    private func checked(_ items: [Dial.MenuItem]) -> [String] {
        items.compactMap { if case .item(let label, true, _) = $0 { label } else { nil } }
    }

    // MARK: - Which grammar each book selects

    @Test func eachBookKindSelectsItsGrammar() {
        #expect(Dial.Grammar.of(reading(.gathering)) == .pickSaves)
        #expect(Dial.Grammar.of(reading(.book, .entryDate)) == .pickSaves)
        #expect(Dial.Grammar.of(reading(.book, .manual)) == .handOrdered)
        #expect(Dial.Grammar.of(reading(.book, .manual, locked: true)) == .browse, "finished: a look only")
        #expect(Dial.Grammar.of(reading(.book, .entryDate, locked: true)) == .browse)
        #expect(Dial.Grammar.of(nil) == .browse, "a book not yet loaded: as before")
    }

    // MARK: - The menus

    @Test func aGatheringsPickSavesAndItsHandOrderReadsAsCollected() {
        let items = Dial.menu(
            grammar: .pickSaves, stored: "as collected", storedOrder: manual,
            viewOrder: nil, canSave: true, gathering: true)
        #expect(labels(items) == ["As collected", "Entry date ↑", "Entry date ↓", "Created ↑", "Created ↓",
                                  "Last touched ↓", "Major revision ↓"],
                "the mockup's frame 9a list: no look row, no Save row — the pick is the order")
        #expect(checked(items) == ["As collected"], "the gathering's own order is checked")
        #expect(act(items, "Created ↓") == .save(createdDown), "a pick saves at once")
        #expect(act(items, "As collected") == .look(nil), "its own order is no pick to save")
        #expect(!labels(items).contains(Dial.saveVerb))
    }

    @Test func aNonManualBooksPickSaves() {
        let items = Dial.menu(
            grammar: .pickSaves, stored: "Entry date ↑", storedOrder: entryUp,
            viewOrder: nil, canSave: true, gathering: false)
        #expect(labels(items).first == "Manual order", "manual is a pick like any other — it saves too")
        #expect(act(items, "Manual order") == .save(manual), "picking manual makes the book hand-ordered")
        #expect(checked(items) == ["Entry date ↑"])
        #expect(act(items, "Created ↓") == .save(createdDown))
    }

    @Test func anUnlistedStoredOrderIsNamedAtTheTop() {
        let lastTouchedUp = Queries.ReadingOrder(field: .lastTouched, direction: .asc)
        let items = Dial.menu(
            grammar: .pickSaves, stored: "Last touched ↑", storedOrder: lastTouchedUp,
            viewOrder: nil, canSave: true, gathering: false)
        #expect(labels(items).first == "This book's order (Last touched ↑)")
        #expect(checked(items) == ["This book's order (Last touched ↑)"])
    }

    @Test func aHandOrderedBooksPickIsALookWithBothDoorsInPlainSight() {
        let resting = Dial.menu(
            grammar: .handOrdered, stored: "Manual order", storedOrder: manual,
            viewOrder: nil, canSave: true, gathering: false)
        #expect(labels(resting).first == "This book's order (Manual order)")
        #expect(checked(resting) == ["This book's order (Manual order)"])
        #expect(!labels(resting).contains("Manual order"), "the hand order leads; the list offers the looks")
        #expect(act(resting, "Created ↓") == .look(createdDown), "a pick is a look — nothing written")
        #expect(!labels(resting).contains(Dial.saveVerb), "nothing to save until a look is on")

        let looking = Dial.menu(
            grammar: .handOrdered, stored: "Manual order", storedOrder: manual,
            viewOrder: createdDown, canSave: true, gathering: false)
        #expect(labels(looking) == [Dial.backToManual, "Entry date ↑", "Entry date ↓", "Created ↑",
                                    "Created ↓", "Last touched ↓", "Major revision ↓", Dial.saveVerb],
                "the mockup's frame 9b menu")
        #expect(act(looking, Dial.backToManual) == .look(nil))
        #expect(act(looking, Dial.saveVerb) == .save(createdDown))
        #expect(checked(looking) == ["Created ↓"])
    }

    @Test func aFinishedBookLooksAndCannotSaveItsMenuAsBefore() {
        let items = Dial.menu(
            grammar: .browse, stored: "Manual order", storedOrder: manual,
            viewOrder: createdDown, canSave: false, gathering: false)
        #expect(labels(items) == ["This book's order (Manual order)"] + BookOrderChoices.all.map(\.label),
                "the A31 menu exactly, with no Save row")
        #expect(act(items, "Created ↓") == .look(createdDown))
        // The browse grammar with a book that CAN save keeps its Save row (a
        // book not yet loaded — today's menu byte for byte).
        let loading = Dial.menu(
            grammar: .browse, stored: "book's order", storedOrder: nil,
            viewOrder: createdDown, canSave: true, gathering: false)
        #expect(labels(loading).last == Dial.saveVerb)
    }

    // MARK: - The receipt, the save, the declaration

    @Test func aSavedOrderSaysSoInHerWords() {
        #expect(BookOrderChoices.savedReceipt(bookName: "this week", order: createdDown, gathering: true)
                == "Saved the order for \u{201C}this week\u{201D} \u{2014} created ↓.",
                "the mockup's receipt")
        #expect(BookOrderChoices.savedReceipt(bookName: "this week", order: manual, gathering: true)
                == "Saved the order for \u{201C}this week\u{201D} \u{2014} as collected.")
        #expect(BookOrderChoices.savedReceipt(bookName: "the allotment year", order: manual, gathering: false)
                == "Saved the order for \u{201C}the allotment year\u{201D} \u{2014} manual order.")
    }

    @Test func aSaveWritesTheBooksOrderOnEveryKindThatCanSave() async throws {
        let db = try AppDatabase.inMemory()
        // The operations stamp through `\.date` (and any placement draws on
        // the fractional index's `\.withRandomNumberGenerator`); both are
        // provided the BookView neighbours' way (`withMintLandingBook`) — a
        // one-second ticking clock and a seeded generator — so the host's
        // test context never meets an unimplemented dependency.
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1040))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let tag = try session.operations.createTag(name: "week")
            let gathering = try session.operations.createReading(
                name: "this week", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let dated = try session.operations.createReading(name: "dated", kind: .book, sortField: .entryDate)
            let finished = try session.operations.createReading(name: "done", kind: .book)
            try session.operations.lockReading(finished.id)
            for id in [gathering.id, dated.id] {
                let structure = BookStructureModel(session: session, readingID: id)
                #expect(await structure.saveOrder(createdDown), "the save lands")
                let row = try #require(try await db.read { try Queries.reading($0, id: id) })
                #expect(row.sortField == .createdAt && row.sortDir == .desc)
            }
            let structure = BookStructureModel(session: session, readingID: finished.id)
            #expect(await structure.saveOrder(createdDown) == false, "a finished book refuses — and says so")
            #expect(structure.lastError != nil)
        }
    }

    @Test func theSaveIsDeclaredOnceAndRenderedByTheBook() {
        let door = CapabilityRegistry.capability(.saveBookOrder)
        #expect(door.verb == "Save as This Book's Order")
        #expect(door.doors == [.surface])
        #expect(!door.unavailableNote.isEmpty)
        #expect(CapabilityRegistry.all.filter { $0.id == .saveBookOrder }.count == 1)
        #expect(BookView.surfaceCapabilities.contains(.saveBookOrder))
    }

    /// The VX-1036 ladder's N4 (13u4 UNIT S3's rule — a door's name is its
    /// constant): the masthead's quiet button says the registry verb, cased
    /// for a face — never a second literal that a rename would leave behind.
    @Test func theMastheadsSaveButtonSaysTheRegistrysVerbInSentenceCase() {
        #expect(BookOrderDialCopy.saveDoor == "Save as this book's order", "the face's words, unchanged")
        #expect(BookOrderDialCopy.saveDoor.lowercased()
                == CapabilityRegistry.capability(.saveBookOrder).verb.lowercased(),
                "…and they are the declared verb's")
    }
}
