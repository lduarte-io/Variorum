//
//  BookcaseCensusOverlayTests.swift
//  VariorumTests
//
//  17y B3 item (r) — THE № CENSUS PANEL BECOMES A TRUE DROPDOWN (her report
//  + capture `notes/plans/17y-screens/census-pushdown-clips.png`, the rulings
//  file's item (r): "see how the book dropdown sits above the text and cuts
//  it off weirdly? lets fix this dropdown so it's a dropdown, not a push
//  down").
//
//  The mechanism (traced in the B3 RECORD before the fix): 13i-d U1 drew the
//  panel IN FLOW — a sibling between the strip and the board's ScrollView in
//  `ShelfView`'s VStack ("in flow, right-aligned — mockup v5"). Opening it
//  inserted its whole height above the board: every row moved down, and in a
//  window whose height was already spoken for the scroll region shrank under
//  it, clipping the first row at its top edge — her capture.
//
//  The oracle is the board's own record of where each row sits
//  (`BookcaseRowOracle.frame`, `.global` — what the row reports of itself):
//  the open panel must not move a single row.
//
//  Red-on-old, stated: on the pre-fix tree the first row's top moves down by
//  the panel's height when the № opens.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y (r) — the № census panel floats over the board", .serialized)
struct BookcaseCensusOverlayTests {
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

    @Test func openingTheCensusNeverMovesABooksRow() async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "bookcase-census-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let first = try ops.createReading(name: "alpha", kind: .book)
            let second = try ops.createReading(name: "beta", kind: .book)
            let model = ShelfViewModel(session: session, defaults: defaults)
            model.censusOpen = false
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
                BookcaseRowOracle.frame(first.id) != nil && BookcaseRowOracle.frame(second.id) != nil
            }
            let closedFirst = try #require(BookcaseRowOracle.frame(first.id))
            let closedSecond = try #require(BookcaseRowOracle.frame(second.id))

            model.censusOpen = true
            await settle(window, hosting, turns: 40) { false }

            let openFirst = try #require(BookcaseRowOracle.frame(first.id))
            let openSecond = try #require(BookcaseRowOracle.frame(second.id))
            #expect(abs(openFirst.minY - closedFirst.minY) < 0.5,
                    "the first row stays where it was (closed \(closedFirst.minY), open \(openFirst.minY))")
            #expect(abs(openSecond.minY - closedSecond.minY) < 0.5,
                    "every row stays where it was — zero layout push")
            #expect(abs(openFirst.height - closedFirst.height) < 0.5, "no row half-drawn")

            model.censusOpen = false
            await settle(window, hosting, turns: 40) { false }
            let againFirst = try #require(BookcaseRowOracle.frame(first.id))
            #expect(abs(againFirst.minY - closedFirst.minY) < 0.5, "closing moves nothing either")
        }
        #endif
    }
}
