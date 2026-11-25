//
//  SharedMarkDoorTests.swift
//  VariorumTests
//
//  VX-1075 (the VX-1082 run, batch B) — the mark on a note that is also in
//  another book. Her words (2026-11-24): "what is this little two boxes
//  symbol? i can't click on it … looks like the snippets symbol but all filled
//  in" · "the two boxes after a notes title makes sense for what it is, but it
//  isn't saying that on hover. … I do think that you should ticket it being
//  given its own symbol and making a click list the other books."
//
//  The trace (the run record, BATCH B): the mark was a plain, non-interactive
//  glyph inside an interaction shell on every host — the folded Outline card
//  (one Button), the Index row (a tap shell), the UNFOLDED Outline header (a
//  drag shell with no help of its own) — and a hover is answered by the
//  innermost interactive view under the pointer, so the mark's own sentence
//  was never what showed (the card's help instead; on the header, nothing).
//  The fix makes the mark its OWN control: a door whose click lists the other
//  books, carrying the sentence as its own help.
//
//  What these pins prove: the symbol is its own (never the Snippets glyph);
//  the facts name an archived other book "(archived)"; and, on the MOUNTED
//  Outline, the folded card's mark and the unfolded header's mark are each a
//  door of their own — carrying the sentence, listing the other books by id,
//  and a list row's press is the ascent (that book, at this note). What they
//  cannot prove is that macOS shows the tooltip: that is the gate walk's
//  capture. Red on the pre-fix tree: the symbol was `square.on.square`, the
//  archived set was never read, and no door was drawn.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withMarkWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1075))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// Mounts the book's OUTLINE with `expanded` unfolded (every other note a
/// folded card) and its models loaded by hand (hosted `.task` callbacks do
/// not fire under the test host), then settles until `done` holds.
@MainActor
private func mountOutline(
    _ session: AppSession, _ db: AppDatabase, readingID: String, expanded: [String],
    ownership: OwnershipFactsModel, until done: () -> Bool
) async throws {
    let model = BookViewModel(session: session, readingID: readingID)
    await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
    for id in expanded { model.expand(id) }
    let structure = BookStructureModel(session: session, readingID: readingID)
    structure.adopt(.init(
        reading: try await db.read { try Queries.reading($0, id: readingID) },
        sections: [], deletedSections: [], assignments: [:]))
    structure.mode = .outline
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    let hosting = NSHostingView(rootView: BookView(
        session: session, readingID: readingID,
        model: model, structure: structure, ownership: ownership))
    hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
    window.contentView = hosting
    window.makeKeyAndOrderFront(nil)
    for _ in 0..<60 where !done() {
        hosting.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        pump(0.03)
        await Task.yield()
    }
    #expect(model.isExpanded(expanded.first ?? "") == !expanded.isEmpty, "the fixture's unfolded note")
}

@MainActor
@Suite("VX-1075 — the shared mark is its own door", .serialized)
struct SharedMarkDoorTests {
    /// Her ask, half one: its own symbol — never the sidebar's Snippets
    /// glyph (PROVISIONAL A-1082-1: `books.vertical`). The pure rule names an
    /// archived other book "(archived)", and the one switch still hides the
    /// family (the guards).
    @Test func theSharedMarkWearsItsOwnSymbolNeverSnippets() {
        let snippets = SidebarView.areas.first { $0.title == "Snippets" }?.symbol
        #expect(snippets == "square.on.square", "the fixture: the Snippets area's glyph")
        #expect(OwnershipBadgeFace.sharedSymbol != snippets, "never the Snippets glyph")
        #expect(OwnershipBadgeFace.sharedSymbol == "books.vertical", "the PROVISIONAL default (A-1082-1)")

        let facts = Queries.OwnershipFacts(
            ownedBy: nil, otherBooks: [Queries.BookRef(id: "b", name: "B"), Queries.BookRef(id: "c", name: "C")])
        #expect(OwnershipBadgeFace.badge(facts, placement: .inBook, badgesOn: true, archivedBooks: ["c"])
                == .shared([SharedBook(id: "b", name: "B"), SharedBook(id: "c", name: "C", archived: true)]))
        #expect(SharedBook(id: "c", name: "C", archived: true).shownName == "C (archived)")
        #expect(OwnershipBadgeFace.badge(facts, placement: .inBook, badgesOn: false, archivedBooks: ["c"]) == nil,
                "ownership_badges off: no mark, door or no door")
    }

    /// The facts read which of a note's OTHER books are archived, in the
    /// same read as the facts — so the mark's list and hover say "(archived)"
    /// (R-13ie-4: every membership face).
    @Test func theFactsReadWhichOtherBooksAreArchived() async throws {
        try await withMarkWorld { session, _ in
            let ops = session.operations
            let a = try ops.createReading(name: "A", kind: .book)
            let b = try ops.createReading(name: "B", kind: .book)
            let c = try ops.createReading(name: "C", kind: .book)
            let note = try ops.createPost(title: "shared")
            for book in [a, b, c] { _ = try ops.addPostToReading(note.id, to: book.id) }
            try ops.archiveReading(c.id)

            let model = OwnershipFactsModel()
            await model.load(session: session, postIDs: [note.id], inBook: a.id)
            #expect(model.archivedBooks == [c.id], "C is archived, B is not, A is the book being viewed")
            #expect(model.badge(for: note.id, placement: .inBook, badgesOn: true)
                    == .shared([SharedBook(id: b.id, name: "B"), SharedBook(id: c.id, name: "C", archived: true)]))
        }
    }

    /// **The trace's pin.** On the mounted Outline, the FOLDED card's mark
    /// and the UNFOLDED header's mark are each a door of their own (the
    /// header's shell carries no help, so before the fix its mark had no
    /// hover at all): each carries the sentence as its own help, lists the
    /// other books by id, and a list row's press opens that book at this
    /// note (the ascent — the owned-by badge's road).
    @Test func theMarkIsItsOwnDoorOnTheFoldedCardAndTheUnfoldedHeader() async throws {
        OwnershipBadgeProbe.reset()
        try await withMarkWorld { session, db in
            let ops = session.operations
            let a = try ops.createReading(name: "A", kind: .book)
            let b = try ops.createReading(name: "B", kind: .book)
            let c = try ops.createReading(name: "C", kind: .book)
            let folded = try ops.createPost(title: "folded")
            let unfolded = try ops.createPost(title: "unfolded")
            for note in [folded, unfolded] { _ = try ops.addPostToReading(note.id, to: a.id) }
            _ = try ops.addPostToReading(folded.id, to: b.id)
            _ = try ops.addPostToReading(unfolded.id, to: c.id)
            try ops.archiveReading(c.id)

            let ownership = OwnershipFactsModel()
            await ownership.load(session: session, postIDs: [folded.id, unfolded.id], inBook: a.id)
            try await mountOutline(
                session, db, readingID: a.id, expanded: [unfolded.id], ownership: ownership
            ) {
                OwnershipBadgeProbe.doors[folded.id] != nil && OwnershipBadgeProbe.doors[unfolded.id] != nil
            }
            #expect(OwnershipBadgeProbe.drawn[folded.id] != nil && OwnershipBadgeProbe.drawn[unfolded.id] != nil,
                    "the fixture: both marks drew")

            let card = try #require(OwnershipBadgeProbe.doors[folded.id], "the folded card's mark is a door")
            let header = try #require(OwnershipBadgeProbe.doors[unfolded.id],
                                      "the unfolded header's mark is a door")
            #expect(card.help == OwnershipBadgeCopy.sharedHelp(["B"]), "its own hover carries the sentence")
            #expect(header.help == OwnershipBadgeCopy.sharedHelp(["C (archived)"]),
                    "the header's mark answers its own hover — and names an archived book so")
            #expect(card.books == [SharedBook(id: b.id, name: "B")])
            #expect(header.books == [SharedBook(id: c.id, name: "C", archived: true)])

            let received = LockIsolated<[[String: String]]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumOpenBookAtPost, object: nil, queue: nil
            ) { note in
                guard let book = note.userInfo?["bookID"] as? String,
                      let post = note.userInfo?["postID"] as? String else { return }
                received.withValue { $0.append(["bookID": book, "postID": post]) }
            }
            defer { NotificationCenter.default.removeObserver(token) }
            for door in [card, header] {
                if let first = door.books.first { door.open(first) }
            }
            #expect(received.value == [
                ["bookID": b.id, "postID": folded.id],
                ["bookID": c.id, "postID": unfolded.id],
            ], "a list row opens THAT book at THIS note")
        }
        OwnershipBadgeProbe.reset()
    }
}
