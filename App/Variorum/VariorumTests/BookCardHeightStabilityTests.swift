//
//  BookCardHeightStabilityTests.swift
//  VariorumTests
//
//  13u2 UNIT A2 — ITEM 18's RED-ON-OLD PIN (the long-book landing & settle).
//
//  Her report, verbatim: *"when I'm in a long book (like the adventures of
//  sherlock holmes), and I click on a chapter or note that's far down, I
//  sometimes travel there before my screen starts to stutter repeatedly once
//  I've already arrived"* — and the second half: *"I got navigated to the
//  chapter and then moved down to where the note started, which is a bit
//  jarring and sometime I was moved too far."*
//
//  THE TRACED MECHANISM (measured on the dev-store Debug build against the
//  real Sherlock book — UNIT A's TRACE 2, re-verified at UNIT A2 on the
//  post-revert tree): the landing scrolled correctly and the target reached
//  `top=0.0`, and THEN a collapsed card above it grew from 46 pt to 103 pt as
//  its preview read returned — twelve of them in TRACE 2's run, 854 pt of
//  drift — pushing the target below the fold while the page visibly jittered,
//  and costing the landing a second, separate hop a full second later.
//
//  So the defect is NOT the landing's arithmetic and NOT TK2 geometry — it is
//  that A CARD'S HEIGHT DEPENDED ON WHEN ITS READ RETURNED. This pin states
//  exactly that and nothing else: a card's height, measured through the
//  production Outline's own geometry road, must be the same before and after
//  its preview would have arrived.
//
//  RED ON OLD (measured, the numbers in the plan's UNIT A2 RECORD): on the
//  pre-fix tree the card renders its preview only once a per-row async read
//  lands (`if !excerpt.isEmpty` over a `@State` filled from a `.task`), so
//  every card steps up the moment it does.
//
//  WHY THE SETTLE IS TURN-BASED AND NOT READ-COUNTED: the fix DELETES the
//  per-row read, so a pin that waited on a read counter would pass vacuously
//  after it. This one waits on turns of the run loop — the thing that is true
//  on both trees — and asks only whether any card moved.
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
@Suite("A book card's height does not depend on when its preview lands (13u2 UNIT A2 — item 18)", .serialized)
struct BookCardHeightStabilityTests {

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func layOut(_ window: NSWindow, _ hosting: NSView) {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 30) async {
        for _ in 0..<turns {
            layOut(window, hosting)
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The fixture: a curated book of plain collapsed cards, each with a
    /// REALISTIC note behind it (a real card previews ~three lines — the
    /// one-line fixture UNIT A replaced was what made this whole family
    /// invisible to the suite), mounted in the real `BookView` shell.
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
            let reading = try session.operations.createReading(name: "the cards", kind: .book)
            var postIDs: [String] = []
            for p in 0..<posts {
                let post = try session.operations.createPost(title: "note \(p)")
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Prose of note \(p). It was a cold morning of the early spring, and we "
                        + "sat after breakfast on either side of a cheery fire in the old room at "
                        + "Baker Street, with a thick fog rolling down between the lines of "
                        + "dun-coloured houses opposite.",
                    registeringUndo: false)
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

    /// **THE PIN.** Mount the book, lay it out ONCE synchronously — no
    /// suspension point stands between the mount and this measurement, so a
    /// preview that is fetched per row cannot have arrived — and record every
    /// row's height through the production geometry road. Then let the run
    /// loop turn and measure again. Not one card may have moved.
    @Test func aCardsHeightIsTheSameBeforeAndAfterItsPreviewArrives() async throws {
        try await withCardBook(posts: 8) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetRowHeights()
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }

            // BEFORE: the first synchronous layout.
            layOut(window, hosting)
            let before = BookOutlineGeometry.rowHeights
            #expect(!before.isEmpty, "the cards reported their geometry on the first layout")

            // AFTER: let everything that was in flight land.
            await settle(window, hosting)
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
                    "no card's height may change after its first frame — every point of change is drift under a landing that has already arrived (item 18). Moved: \(report)")
        }
    }

    /// **The INVARIANT the fix rests on, stated where it can be read without
    /// a window:** an entry is never published without its card preview in
    /// hand. `adopt` primes before it publishes, so this holds at the instant
    /// `entries` is non-empty — no layout, no settle, no waiting.
    ///
    /// (This one cannot exist on the pre-fix tree by construction — the
    /// property it reads is the fix. Its sibling above is the red-on-old pin;
    /// this is the statement of what replaced the defect.)
    @Test func everyEntrysPreviewIsInHandTheMomentTheEntriesArrive() async throws {
        try await withCardBook(posts: 6) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            #expect(model.entries.isEmpty, "the premise: nothing has arrived yet")
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            #expect(model.entries.count == 6)
            for id in postIDs {
                #expect(model.cardPreview(id).hasPrefix("Prose of note"),
                        "the entry arrived with its words: \(model.cardPreview(id))")
            }

            // And a note that LEAVES the book takes its preview with it — the
            // map is the book's entries', never a growing cache.
            let shorter = model.entries.dropLast().map { $0 }
            await model.adopt(shorter)
            #expect(model.cardPreview(postIDs[5]).isEmpty, "the departed note's preview is forgotten")
            #expect(!model.cardPreview(postIDs[0]).isEmpty, "the survivors keep theirs")
        }
    }
}
