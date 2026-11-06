//
//  BookDoorsEverywhereTests.swift
//  VariorumTests
//
//  VX-829 (the VX-878 run, batch 1 — her 2026-11-04 ask, two screenshots):
//  "(1) the Book Settings sheet has no Move to Wing door — add it (beside the
//  State doors; it's book configuration like the rest). (2) A book row in the
//  LIBRARY offers only Ask Siri · Open · Star · Book Settings… · Export
//  Markdown/PDF · Share with AI… · Archive · Delete Book… — 'the options that
//  are available in bookcase on a book should be available on library (within
//  reason, like the shelf options don't need to be there).'"
//
//  A ruled BUILD (no red-on-old owed): the pins fix the Book Settings wing
//  row (drawn only where another wing exists, from the book's own wing, its
//  act the Bookcase row's), the ONE book-menu table and its DERIVATION — the
//  menu beyond the Bookcase is the Bookcase row's minus shelf placement, with
//  Open leading — and the declarations both faces read. The walk captures the
//  two menus side by side at the closing window.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withDoorsWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 829))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.05) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool = { false }) async {
    for _ in 0..<20 where !condition() {
        pump()
        for _ in 0..<10 { await Task.yield() }
    }
}

/// Mounts `view` in a real window for the body of `run`.
@MainActor
private func mounted<V: View>(_ view: V, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 820),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: view)
    window.orderFrontRegardless()
    await settle()
    try await run()
}

@MainActor
@Suite("VX-829 — a book's doors everywhere", .serialized)
struct BookDoorsEverywhereTests {
    // MARK: - (1) Book Settings: the wing row

    /// The act is the Bookcase row's, with a second door on its one
    /// declaration: the sheet's State section draws it (`.surface`).
    @Test func theWingRowIsTheBookcaseActsSecondDoor() {
        #expect(CapabilityRegistry.capability(.moveBookToWing).doors.contains(.surface))
        #expect(BookSettingsSheet.surfaceCapabilities.contains(.moveBookToWing))
        #expect(CollectingCopy.wingCaption("Home", isGathering: false)
                == "In \u{201C}Home\u{201D}. Moving the book takes its notes with it.")
        #expect(CollectingCopy.wingCaption("Imports", isGathering: true)
                == "In \u{201C}Imports\u{201D}. A gathering shows the notes of the wing it\u{2019}s in.")
    }

    /// The row draws only where it can act (P-2 — `WingBookMoveDoor.drawn`):
    /// with one library, no row; with another wing, the OTHER wings from the
    /// book's own wing, Home first — on a book, a gathering and a book that
    /// lives in an additional wing alike. A mount without a wings brain draws
    /// none.
    @Test func theWingRowDrawsTheOtherWingsOnlyWhereAnotherExists() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Field Notes", kind: .book)
            let wings = WingsModel(session: session)
            await wings.load()

            let target = try #require(await BookSettingsTarget.load(session: session, readingID: book.id))
            BookSettingsProbe.drawn = [:]
            try await mounted(BookSettingsHost(target: target).environment(wings)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.wingDestinations == [], "one library — no wing row")
            }

            let imports = try ops.createWing(name: "Imports")
            let archive = try ops.createWing(name: "Archive room")
            await wings.load()
            BookSettingsProbe.drawn = [:]
            let again = try #require(await BookSettingsTarget.load(session: session, readingID: book.id))
            try await mounted(BookSettingsHost(target: again).environment(wings)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.wingDestinations == ["Imports", "Archive room"],
                        "a Home book is offered every other wing")
            }

            // A gathering in an ADDITIONAL wing: Home first, its own omitted.
            let gathering = try ops.createReading(
                name: "Starred", kind: .gathering, querySpec: try RuleGrammar.encode(.star),
                wingId: imports.id)
            let gTarget = try #require(await BookSettingsTarget.load(session: session, readingID: gathering.id))
            try await mounted(BookSettingsHost(target: gTarget).environment(wings)) {
                let drawn = try #require(BookSettingsProbe.drawn[gathering.id])
                #expect(drawn.wingDestinations == ["Home", "Archive room"],
                        "from the gathering's OWN wing, Home first")
            }

            // A harness mount with no wings brain draws no row (nil, not []).
            let bare = try #require(await BookSettingsTarget.load(session: session, readingID: book.id))
            BookSettingsProbe.drawn = [:]
            try await mounted(BookSettingsHost(target: bare)) {
                let drawn = try #require(BookSettingsProbe.drawn[book.id])
                #expect(drawn.wingDestinations == nil)
            }
            _ = archive
            _ = try await db.read { try Queries.reading($0, id: book.id) }
        }
    }

    /// The row's road IS the Bookcase row's: a pick asks through
    /// `WingsModel.bookMoveAsk` (the counting confirm's item), and the
    /// confirm's act moves the book with its notes.
    @Test func theWingRowsPickRunsTheBookcaseRowsAct() async throws {
        try await withDoorsWorld { session, db in
            let ops = session.operations
            let book = try ops.createReading(name: "Field Notes", kind: .book)
            let note = try ops.createPost(title: "a note")
            _ = try ops.addPostToReading(note.id, to: book.id)
            let imports = try ops.createWing(name: "Imports")
            let wings = WingsModel(session: session)
            await wings.load()

            let reading = try #require(try await db.read { try Queries.reading($0, id: book.id) })
            let offered = BookSettingsSheet.wingDestinations(for: reading, wings: wings)
            #expect(offered.map(\.id) == [imports.id])
            let ask = try #require(await wings.bookMoveAsk(reading: reading, to: imports.id))
            #expect(ask.readingID == book.id && ask.wingName == "Imports")
            await wings.moveBook(ask)
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.wingId == imports.id)
        }
    }
}
