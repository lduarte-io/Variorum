//
//  BookIndexLandingTests.swift
//  VariorumTests
//
//  **13u4 UNIT F1 — the book Index's LANDING (her item 10).** Her report,
//  verbatim: *"there is sometimes a weird issue where clicking on the name of
//  a chapter in a book isn't bringing you to the correct location, but instead
//  a random location in the text a fair amount under it. Only seen in index
//  mode."*
//
//  What is pinned here is the claim in its simplest form: **a landing on a row
//  far down the Index pane puts THAT row at the top of the page.** The road is
//  the pane's one landing channel — `BookViewModel.requestLanding` → the
//  index's `landOrSeed` → `select(scrollPane:)` → the pane — which is the same
//  channel the chapter click uses (a chapter target is `sec-<group id>` on it),
//  so a defect in the aim shows here whatever set the target.
//
//  The measurement is one number: the target row's top in the pane scroll's
//  own space (`BookIndexGeometry.paneAnchorTops`, visible-relative — a row at
//  the top of the page reads ≈ 0).
//
//  RED ON OLD (13u4 UNIT F1's own measurement, quoted at the assertion): with
//  a single un-watched `scrollTo` the pane lands wherever the lazy column's
//  estimate put it and never corrects — measured here, and measured in the app
//  on the real Sherlock book (11 of 20 chapter clicks landed in a DIFFERENT
//  story; one left the page blank; none corrected in six seconds).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A book long enough that the pane's geometry cannot be known from one frame:
/// eight chapters, one note each, every note a hundred short blocks (the shape
/// of the shipped sample library at a scale a test can build).
@MainActor
private func withLongIndexBook<T>(
    notes: Int = 8, blocks: Int = 40,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]
    ) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "a long book", kind: .book)
        var postIDs: [String] = []
        for p in 0..<notes {
            let post = try session.operations.createPost(title: "story \(p)")
            for b in 0..<blocks {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(b) of story \(p) — a sentence of prose to read, long "
                        + "enough that the column has a real height to discover.")
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            let chapter = try session.operations.createSection(in: reading.id, name: "chapter \(p)")
            try session.operations.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
@Suite("The book Index lands where it aimed (13u4 UNIT F1, her item 10)", .serialized)
struct BookIndexLandingTests {
    /// Within this much of the page's top, a landing arrived. The Outline's
    /// own number (`LandingPolicy.bookOutline.tolerance`), read from the
    /// policy so the two cannot drift.
    private var tolerance: CGFloat { 2 }

    private func pump(_ seconds: TimeInterval = 0.05) {
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

    private func loadedStructure(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        return structure
    }

    private func mounted(
        session: AppSession, readingID: String,
        model: BookViewModel, structure: BookStructureModel
    ) -> (NSWindow, NSHostingView<BookView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID, model: model, structure: structure))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 760)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    /// **THE PIN.** Land on a story in the MIDDLE of a long book and ask
    /// where it ended up. A landing that arrived puts that row at the top of
    /// the page.
    ///
    /// **Why the middle and not the last row, and it is a measured reason:**
    /// the last row of a column can only be at the top of the page when a
    /// whole viewport of content stands below it, and a `scrollTo` CLAMPS at
    /// the end of the scroll — the first shape of this pin asked the last
    /// story to come to the top and measured 667 pt on BOTH trees, which is
    /// the clamp and not the landing. A pin that cannot pass is not a pin.
    ///
    /// RED ON OLD: the pre-fix pane aimed once, at whatever the lazy column
    /// estimated, and never looked again.
    @Test func aLandingOnAFarNoteArrivesAtThatNotesTop() async throws {
        try await withLongIndexBook { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            #if DEBUG
            // The arrival seed lands the first note; wait for the page to be
            // real before asking it to travel.
            await settle(window, hosting, until: {
                BookIndexGeometry.paneAnchorTops["bip-\(postIDs[0])"] != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 10)

            // A NOTE reveal, never a block landing (`requestReveal` leaves
            // `pendingLanding` nil) — so the anchor the landing rests on is
            // this row itself and the claim is about one number.
            let far = postIDs[5]
            model.requestReveal(far)
            await settle(window, hosting, until: {
                abs(BookIndexGeometry.paneAnchorTops["bip-\(far)"] ?? .greatestFiniteMagnitude)
                    <= tolerance
            }, maxTurns: 250)

            let reported = BookIndexGeometry.paneAnchorTops["bip-\(far)"]
            print("[13u4 F1] far note landing top=\(reported.map { "\($0)" } ?? "never reported")")
            print("[13u4 F1 story] " + BookIndexGeometry.trace.suffix(40).joined(separator: " | "))
            let top = try #require(
                reported,
                "the target row never reported — the page is somewhere else entirely")
            #expect(abs(top) <= tolerance,
                    "the note the landing named is at the top of the page: top=\(top)")
            #endif
        }
    }

    /// **The same claim for a BLOCK inside a story** — row 38's road, the one
    /// a Read ▸ Scroll click takes into Index (`LandingTarget(postID:blockID:)`).
    /// A block deep inside a note that is itself deep in the book is the
    /// hardest address this surface has, and it must still come to the top.
    ///
    /// RED ON OLD: the un-watched aim leaves it hundreds of points away, or
    /// never realizes it at all.
    @Test func aBlockLandingDeepInTheBookArrivesAtThatBlock() async throws {
        try await withLongIndexBook { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            #if DEBUG
            await settle(window, hosting, until: {
                BookIndexGeometry.paneAnchorTops["bip-\(postIDs[0])"] != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 10)

            let far = postIDs[5]
            let rows = try await session.database.read { [far] in
                try Queries.blockTOC($0, post: far)
            }
            let target = rows[rows.count / 2]
            model.requestLanding(LandingTarget(postID: far, blockID: target.blockID))
            await settle(window, hosting, until: {
                abs(BookIndexGeometry.paneAnchorTops["bip-\(target.blockID)"]
                    ?? .greatestFiniteMagnitude) <= tolerance
            }, maxTurns: 250)

            let top = BookIndexGeometry.paneAnchorTops["bip-\(target.blockID)"]
            print("[13u4 F1] deep block landing top=\(top.map { "\($0)" } ?? "never reported")")
            print("[13u4 F1 story] " + BookIndexGeometry.trace.suffix(40).joined(separator: " | "))
            #expect(abs(top ?? .greatestFiniteMagnitude) <= tolerance,
                    "the block the landing named is at the top of the page")
            #endif
        }
    }
}
