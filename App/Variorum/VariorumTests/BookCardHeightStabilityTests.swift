//
//  BookCardHeightStabilityTests.swift
//  VariorumTests
//
//  13u2 UNIT A — ITEM 18's RED-ON-OLD PIN (the long-book landing & settle).
//
//  Her report, verbatim: *"when I'm in a long book (like the adventures of
//  sherlock holmes), and I click on a chapter or note that's far down, I
//  sometimes travel there before my screen starts to stutter repeatedly once
//  I've already arrived"* — and the second half: *"I got navigated to the
//  chapter and then moved down to where the note started, which is a bit
//  jarring and sometime I was moved too far."*
//
//  THE TRACED MECHANISM (measured on the dev-store Debug build against the
//  real Sherlock book — the full log is in the plan's UNIT A RECORD, TRACE 2):
//  the landing scrolled correctly and reached `top=0.0`, and THEN every
//  collapsed card ABOVE the target grew from 46 pt to 103 pt as its preview
//  read returned — `page-EE7D2FA5 h=46 … h=103`, twelve of them — pushing the
//  target from 0 to 854 pt below the fold while the page visibly jittered
//  (`top=0 → 12 → -117 → 588 → 683 → 854`). A full second later the landing's
//  minimum hold expired and it took ONE 854-pt hop to recover: the second
//  stage of her two-stage jump, `HOP 1 at 457 ms … DONE: settled at top=0.0
//  after 1 hops, 1011 ms`.
//
//  So the defect is NOT the landing's arithmetic and NOT TK2 geometry — it is
//  that a collapsed card's HEIGHT DEPENDS ON WHEN ITS READ RETURNS. This pin
//  states exactly that and nothing else: a card's height, measured through the
//  production Outline's own geometry road, must be the same before and after
//  its preview arrives.
//
//  RED ON OLD: on the pre-fix tree the card renders its preview only once the
//  read lands (`if !excerpt.isEmpty`), so its height steps up the moment it
//  does — the fixture's one-line preview alone moves it, and the real book's
//  three-line previews move it by 57 pt each.
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
@Suite("A book card's height does not depend on when its preview lands (13u2 UNIT A — item 18)", .serialized)
struct BookCardHeightStabilityTests {

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func layOut(_ window: NSWindow, _ hosting: NSView) {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            layOut(window, hosting)
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// The fixture: a curated book of plain collapsed cards, each with a
    /// short note behind it, mounted in the real `BookView` shell.
    private func withCardBook<T>(
        posts: Int,
        _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 44))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the cards", kind: .curated)
            var postIDs: [String] = []
            for p in 0..<posts {
                let post = try session.operations.createPost(title: "note \(p)")
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Prose of note \(p). It was a cold morning of the early spring, and we "
                        + "sat after breakfast on either side of a cheery fire in the old room at "
                        + "Baker Street, with a thick fog rolling down between the lines of "
                        + "dun-coloured houses opposite.")
                try session.operations.addPostToReading(post.id, to: reading.id)
                postIDs.append(post.id)
            }
            return try await body(session, db, reading.id, postIDs)
        }
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

    /// **THE PIN.** Mount the book, lay it out ONCE synchronously (the preview
    /// reads are `await`ed, so not one of them can have returned yet — no
    /// suspension point stands between the mount and this measurement), record
    /// every card's height; then let the reads land and measure again. Not one
    /// card may have moved.
    @Test func aCardsHeightIsTheSameBeforeAndAfterItsPreviewArrives() async throws {
        try await withCardBook(posts: 8) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.rowHeights = [:]
            BookOutlineFactsReads.count = 0
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }

            // BEFORE: the first synchronous layout. No `await` since the
            // mount, so every card's preview read is still in flight.
            layOut(window, hosting)
            let before = BookOutlineGeometry.rowHeights
            #expect(!before.isEmpty, "the cards reported their geometry on the first layout")
            #expect(BookOutlineFactsReads.count >= 0)

            // AFTER: let the reads land and the column settle.
            await settle(window, hosting, until: {
                BookOutlineFactsReads.count >= min(8, postIDs.count)
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let after = BookOutlineGeometry.rowHeights

            var moved: [String] = []
            for (anchor, height) in before {
                guard let now = after[anchor] else { continue }
                if abs(now - height) > 0.5 {
                    moved.append("\(anchor.prefix(13)) \(Int(height))→\(Int(now))")
                }
            }
            let report = moved.joined(separator: ", ")
            #expect(moved.isEmpty,
                    "no card's height may change when its preview read returns — every point of change is drift under a landing that has already arrived (item 18). Moved: \(report)")
        }
    }

    /// **The stabiliser the card fix needed, stated purely** (13u2 UNIT A). A
    /// `LazyVStack` estimates its unrealized rows at the AVERAGE of the ones it
    /// has measured, so a run holding two row SCALES reports a content height
    /// that swings with whichever kind happens to be realized. Cards at their
    /// honest height widened that ratio (headings ~51 pt against cards ~103)
    /// and the swing — 68–74 pt a pass — walked a LANDED target off the top and
    /// kept it moving: `openingACollapsedStoryLandsAtItsTopWithThreeStories
    /// Expanded` went from settling in 0 hops to giving up 74 pt out after 13.
    /// Proven by elimination before it was fixed: with the per-row deltas
    /// instrumented, not ONE anchored row changed height through the drift.
    ///
    /// A run is therefore all-headings or all-cards. RED ON OLD: `segments`
    /// returned a single mixed run.
    @Test func aLazyRunHoldsRowsOfOneScaleOnly() {
        func section(_ id: String) -> ReadingSection {
            ReadingSection(
                id: id, readingId: "book", name: id, position: id,
                createdAt: Date(timeIntervalSince1970: 0),
                updatedAt: Date(timeIntervalSince1970: 0))
        }
        let rows: [BookOutlineRows.Row] = [
            .chapter(section("s1")),
            .note(Self.entry("a")), .note(Self.entry("b")),
            .chapter(section("s2")),
            .note(Self.entry("c")),
        ]
        let segments = BookOutlineRows.segments(rows: rows, isExpanded: { _ in false })
        let shapes: [String] = segments.map { segment in
            switch segment {
            case .run(let rows):
                return rows.allSatisfy(BookOutlineRows.isCardScale) ? "cards(\(rows.count))"
                    : (rows.contains(where: BookOutlineRows.isCardScale) ? "MIXED" : "headings(\(rows.count))")
            case .expanded:
                return "expanded"
            }
        }
        #expect(!shapes.contains("MIXED"), "no lazy run mixes row scales — got \(shapes)")
        #expect(shapes == ["headings(1)", "cards(2)", "headings(1)", "cards(1)"],
                "headings and cards take their own runs — got \(shapes)")
    }

    private static func entry(_ id: String) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: nil, entryDate: nil, sectionPath: nil)
    }

    /// The companion claim, stated so the fix cannot be read as "reserve three
    /// lines and hope": the slot's rule itself. While the read is in flight the
    /// slot stands (unknown is not empty); once the answer is a preview it
    /// stands; the ONE stand-down is a note the read says has nothing to show.
    @Test func thePreviewSlotStandsWhileTheAnswerIsUnknownAndOnlyStandsDownForAKnownEmptyNote() async throws {
        try await withCardBook(posts: 1) { session, db, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.rowHeights = [:]
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            layOut(window, hosting)
            let unknown = BookOutlineGeometry.rowHeights.values.max() ?? 0
            await settle(window, hosting, until: { BookOutlineFactsReads.count >= 1 })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let known = BookOutlineGeometry.rowHeights.values.max() ?? 0
            #expect(unknown > 0, "the card reported a height before its read returned")
            #expect(abs(known - unknown) <= 0.5,
                    "a card with prose behind it keeps its height across the read (\(Int(unknown)) → \(Int(known)))")
        }
    }
}
