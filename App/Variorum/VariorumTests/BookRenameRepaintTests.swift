//
//  BookRenameRepaintTests.swift
//  VariorumTests
//
//  VX-804 — a book renamed in Book Settings repaints the OPEN book in place.
//  The beta tester, via her (2026-11-04): "I created a Book. When I renamed it
//  via Book Settings, I couldn't get the new name to appear until I left that
//  part of the app. It does persist …" — their screenshot: the settings
//  sheet's Name field holds the new name while the page heading still reads
//  the old one and the masthead its truncation.
//
//  THE MECHANISM (traced; the VX-878 record's BATCH 2 RECORD): the write
//  lands (`BookStructureModel.rename` → `renameReading`, and the structure
//  model's held observation of the row has the new name — which is why the
//  sheet showed it), but every name face of the book view read
//  `BookViewModel.readingName`, which `start()` fetched ONCE before entering
//  its entries observation; nothing re-read it until the view remounted.
//
//  RED-ON-OLD: this pin was committed WITH the probe on the pre-fix tree
//  (the faces still reading the one-shot), where the after-rename
//  expectations fail; the fix commit turns it green. Mounted, because the
//  claim is about what the FACES DRAW (`BookNameProbe`), not about a model.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withRenameWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 804))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "Second Book", kind: .book)
        let post = try session.operations.createPost(title: "one note")
        _ = try session.operations.newBlock(in: post.id, text: "A line of prose in the book.")
        try session.operations.addPostToReading(post.id, to: reading.id)
        return try await body(session, db, reading.id)
    }
}

@MainActor
@Suite("VX-804 — a rename in Book Settings repaints the open book", .serialized)
struct BookRenameRepaintTests {
    private func pump(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// The tester's exact road: the book is open (Outline — a working book's
    /// opening mode), Book Settings' Close runs `structure.rename(to:)`, and
    /// the navigator's masthead and the Outline's page heading must draw the
    /// new name WITHOUT leaving the book.
    @Test func aRenameInBookSettingsRepaintsTheOpenBooksMastheadAndHeading() async throws {
        try await withRenameWorld { session, db, readingID in
            #if DEBUG
            BookNameProbe.reset()
            let model = BookViewModel(session: session, readingID: readingID)
            let structure = BookStructureModel(session: session, readingID: readingID)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BookView(
                session: session, readingID: readingID, model: model, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            // Hosted `.task`s don't fire under the test host: the book view's
            // two models are started by hand, exactly as its two tasks would.
            let entriesTask = Task { await model.start() }
            let structureTask = Task { await structure.start() }
            defer {
                entriesTask.cancel()
                structureTask.cancel()
            }
            @MainActor func drawn(_ face: BookNameFace) -> String? { BookNameProbe.name(readingID, face) }

            await settle(window, hosting, until: {
                drawn(.masthead) == "Second Book" && drawn(.outlineTitle) == "Second Book"
            })
            #expect(drawn(.masthead) == "Second Book", "the masthead names the open book")
            #expect(drawn(.outlineTitle) == "Second Book", "the page heading names the open book")

            // Book Settings' own road (`BookSettingsSheet.save()` → this).
            await structure.rename(to: "Renamed Book")
            #expect(structure.lastError == nil)
            // Not a lost write: the store and the structure model's held row
            // have the new name (the tester's "it does persist").
            let stored = try await db.read { try Queries.reading($0, id: readingID)?.name }
            #expect(stored == "Renamed Book")

            await settle(window, hosting, until: {
                drawn(.masthead) == "Renamed Book" && drawn(.outlineTitle) == "Renamed Book"
            })
            #expect(structure.reading?.name == "Renamed Book", "the structure model holds the renamed row")
            #expect(drawn(.masthead) == "Renamed Book",
                    "the masthead repaints in place — no navigation (red on the one-shot name)")
            #expect(drawn(.outlineTitle) == "Renamed Book",
                    "the page heading repaints in place — no navigation (red on the one-shot name)")
            #endif
        }
    }

    /// The one derivation every face reads (added WITH the fix — supporting,
    /// not the red-on-old pin): the held row's name, "book" before it lands.
    @Test func theNameEveryFaceShowsIsTheHeldRowsOwn() {
        let reading = Reading(id: "r", name: "Renamed Book", kind: .book, createdAt: Date(), updatedAt: Date())
        #expect(BookView.shownName(of: reading) == "Renamed Book")
        #expect(BookView.shownName(of: nil) == "book")
    }

    /// The class closed at its source (added WITH the fix): no face of the
    /// book view reads a name copied once, and the book model holds none.
    @Test func noFaceReadsAOneShotCopyOfTheName() throws {
        let features = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features/BookView")
        let view = try String(contentsOf: features.appendingPathComponent("BookView.swift"), encoding: .utf8)
        let model = try String(contentsOf: features.appendingPathComponent("BookViewModel.swift"), encoding: .utf8)
        #expect(!view.contains("model.readingName"))
        #expect(!view.contains("var readingName"))
        #expect(!model.contains("var readingName"))
        // The three faces read the one derivation.
        #expect(view.contains("Text(tokens.path([bookName]))"))
        #expect(view.contains("Text(tokens.chromeLabel(bookName))"))
        #expect(view.contains("readingName: bookName,"))
    }
}
