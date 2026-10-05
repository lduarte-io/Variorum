//
//  BookcaseRowFreezeTests.swift
//  VariorumTests
//
//  17y B2 — item (b), F-B2-5: A BOOK THAT MOVES SHELVES KEEPS A LIVE ROW.
//
//  Found by this batch's walk, PRE-EXISTING (U1's board): `ShelfView` draws
//  `ForEach(sections) { … ForEach(section.books, id: \.reading.id) { row } }`
//  inside a `LazyVStack`, and a book re-shelved between sections (by its
//  menu, or by a drop) kept a row view that never updated again until the
//  board was rebuilt — its meta ignored "details" (U1's own toggle), and the
//  order's `placing` froze with it: (b)'s grip drawn in A–Z, missing in my
//  order, the row's drop site and hairline stuck the same way. The walk's
//  captures `b2/f1` (frozen) and `f2`–`f4` (live) are the visual half.
//
//  The fix gives each row a SECTION-qualified identity
//  (`ShelfView.rowIdentity`), so a move is a new row, never a re-parented
//  one. The oracle is the DEBUG record each row writes of what it DREW
//  (`BookcaseRowOracle`, owner-keyed — the 18k C4 rule): a frozen row never
//  re-renders, so its record keeps the state it moved with.
//
//  Red-on-old, stated: the moved row's record stayed `placing == true` after
//  the order went A–Z and `details == true` after details went off — 2
//  issues, the two "the MOVED row" expectations (verified by the identity
//  line's revert — the B2 RECORD and its fix round). The unmoved row is the
//  control and passes on both trees.
//
//  ⚠ THE HIDDEN DEPENDENCY, made explicit (the B2 ladder's MINOR-1): this
//  red-on-old holds only while each row also records its FRAME
//  (`ShelfView`'s `.onGeometryChange(.global)` → `BookcaseRowOracle.
//  recordFrame`). With that recorder removed the pin goes HOLLOW — green with
//  the identity reverted — and WHY is NOT explained (recorded, never
//  claimed). So the pin REQUIRES a frame record for both rows: removing the
//  recorder turns it red, never hollow. Nothing reads the rect's value.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y (b) F-B2-5 — a book that moves shelves keeps a live row", .serialized)
struct BookcaseRowFreezeTests {
    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, turns: Int = 150, until predicate: () -> Bool
    ) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    @Test func identityIsQualifiedBySection() {
        #expect(ShelfView.rowIdentity(section: "work", book: "b1")
                != ShelfView.rowIdentity(section: "ideas", book: "b1"),
                "the same book on another shelf is another row")
        #expect(ShelfView.rowIdentity(section: "work", book: "b1")
                == ShelfView.rowIdentity(section: "work", book: "b1"))
    }

    @Test func aRowMovedBetweenShelvesStillFollowsTheOrderAndTheDetails() async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "bookcase-freeze-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let work = try ops.createShelf(name: "Work")
            let ideas = try ops.createShelf(name: "Ideas")
            let moving = try ops.createReading(name: "moving", kind: .book, shelfId: work.id)
            let staying = try ops.createReading(name: "staying", kind: .book, shelfId: ideas.id)
            let model = ShelfViewModel(session: session, defaults: defaults)
            model.orderMode = .mine
            BookcaseRowOracle.forgetAll()

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 640),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: model,
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}))
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.close()
            }

            await settle(window, hosting) {
                BookcaseRowOracle.drawn(moving.id) != nil && BookcaseRowOracle.drawn(staying.id) != nil
                    && BookcaseRowOracle.frame(moving.id) != nil
                    && BookcaseRowOracle.frame(staying.id) != nil
            }
            #expect(BookcaseRowOracle.drawn(moving.id) == .init(placing: true, details: true),
                    "both rows drew under my order with details on")
            // THE COUPLING (see the header): the frame recorder is what makes
            // this pin's red-on-old real — required, so it cannot be
            // "cleaned up" into a hollow pin.
            _ = try #require(BookcaseRowOracle.frame(moving.id),
                             "the moved row recorded its frame — the pin's red-on-old needs the recorder")
            _ = try #require(BookcaseRowOracle.frame(staying.id),
                             "the control row recorded its frame — the pin's red-on-old needs the recorder")

            // THE MOVE between sections — the act that froze U1's row.
            await model.reshelve(moving.id, to: ideas.id)
            await settle(window, hosting) { model.shelfKey(of: moving.id) == ideas.id }
            await settle(window, hosting, turns: 20) { false }

            model.orderMode = .alphabetical
            await settle(window, hosting) {
                BookcaseRowOracle.drawn(moving.id)?.placing == false
                    && BookcaseRowOracle.drawn(staying.id)?.placing == false
            }
            #expect(BookcaseRowOracle.drawn(staying.id)?.placing == false,
                    "control: the unmoved row hears the order")
            #expect(BookcaseRowOracle.drawn(moving.id)?.placing == false,
                    "the MOVED row hears the order too — no grip, no row drop in A–Z")

            model.detailsShown = false
            await settle(window, hosting) {
                BookcaseRowOracle.drawn(moving.id)?.details == false
                    && BookcaseRowOracle.drawn(staying.id)?.details == false
            }
            #expect(BookcaseRowOracle.drawn(staying.id)?.details == false, "control")
            #expect(BookcaseRowOracle.drawn(moving.id)?.details == false,
                    "the MOVED row hides its meta with details off, like every row")
        }
        #endif
    }
}
