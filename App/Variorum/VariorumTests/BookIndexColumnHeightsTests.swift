//
//  BookIndexColumnHeightsTests.swift
//  VariorumTests
//
//  **13u4 UNIT F3 — the book Index pane's COLD COLUMN (UNIT F1's residual,
//  pulled into the phase at her ruling R-13u4-8).**
//
//  F1 shipped the landing authority on this surface and measured what it could
//  not close: on a COLD column — the first seconds after a book is opened,
//  while the notes' text is still arriving — a deep chapter click can still
//  land short, because the column's own height oscillates under it. F1's
//  measurement, in the app: **39k → 56k → 143k → 80k → 115k points inside six
//  seconds**, and `end=gaveup` in the signpost on 2 of 5 cold first deep
//  clicks. The cause is one sentence: **a pane row is a whole NOTE standing at
//  ~40 pt until `observeBlockTOC` returns and at thousands afterwards**, and a
//  lazy container answers "how tall is a row I have not realized" with the
//  average of the ones it has.
//
//  So this file pins the two halves of the claim, at **F1's own
//  delayed-realization fixture** (8 notes × 100 blocks — the scale at which
//  F1 measured the harness column *"still CLIMBING while the landing runs"*,
//  which is why F1's own landing pins use 40 blocks and this one does not):
//
//  1. **THE MECHANISM** — the column does not grow by a large multiple while
//     it loads (`BookIndexGeometry.paneContentSpans`, the span of every height
//     the pane ever reported).
//  2. **THE OUTCOME** — a landing on a far note at that scale still arrives at
//     that note's top.
//
//  RED ON OLD, and it is behavioural-revert verified in the unit's record: on
//  the pre-fix tree the span's growth and the landing's miss are both measured
//  at this file's own first commit, before a line of the fix existed.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// **F1's delayed-realization fixture**: a book whose notes are long enough
/// that their text cannot be in hand by the time the column is asked how tall
/// it is. Eight chapters, one note each, a hundred blocks a note — F1's own
/// measured "the column is still climbing while the landing runs" scale.
@MainActor
private func withSlowIndexBook<T>(
    notes: Int = 8, blocks: Int = 100,
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
        let reading = try session.operations.createReading(name: "a slow book", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<notes {
            let post = try session.operations.createPost(title: "story \(p)")
            for b in 0..<blocks {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(b) of story \(p) — a sentence of prose to read, long "
                        + "enough that the column has a real height to discover, and another "
                        + "clause after it so the paragraph wraps more than once at any measure.")
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
@Suite("The book Index's column knows its own heights (13u4 UNIT F3)", .serialized)
struct BookIndexColumnHeightsTests {
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

    /// **PIN 1 — THE MECHANISM.** Open the book in Index and let it load. The
    /// column must not grow by a large multiple while it does.
    ///
    /// The bound is a MEASURED number, stated at the assertion with both
    /// trees' readings, not a tuned-until-green one: a column whose rows stand
    /// at length-derived estimates ends within a small factor of where it
    /// started, because the estimate IS approximately the real height; a
    /// column of 40-pt rows that become thousands cannot.
    ///
    /// RED ON OLD — the pre-fix reading is in the unit's record.
    @Test func theColumnDoesNotTrebleUnderItselfWhileTheBookLoads() async throws {
        try await withSlowIndexBook { session, db, readingID, postIDs in
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
            // Let the pane load: the first note's rows arriving is the signal
            // that the TOC reads are running, then give the column time to
            // finish moving.
            await settle(window, hosting, until: {
                BookIndexGeometry.paneAnchorTops["bip-\(postIDs[0])"] != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 90)

            let span = try #require(
                BookIndexGeometry.paneContentSpans[readingID],
                "the pane never reported a content height")
            print("[13u4 F3] column span low=\(Int(span.low)) high=\(Int(span.high)) "
                + "growth=\(String(format: "%.1f", span.growth))× reports=\(span.reports)")
            // Pre-fix the column starts at a screenful of 40-pt note rows and
            // ends at the real book; post-fix it starts at the estimate. The
            // bound sits well above the estimate's own error and well below
            // the pre-fix reading — both are in the record.
            let growth = String(format: "%.1f", span.growth)
            #expect(span.growth <= 3,
                    "the column's height stays within a small factor of itself while it loads: \(Int(span.low)) → \(Int(span.high)) pt (\(growth)×)")
            #endif
        }
    }

    /// **PIN 2 — THE OUTCOME.** The same claim UNIT F1 pinned, at the scale
    /// F1 measured as unwinnable: a landing on a far note arrives at that
    /// note's top even while the book's text is still arriving.
    ///
    /// F1's record states this directly — *"at 100 blocks the harness's column
    /// is still CLIMBING while the landing runs … and both trees fail, which
    /// is not evidence of anything"* — so this is exactly the pin F1 could not
    /// write, made writable by the heights.
    @Test func aLandingOnAFarNoteArrivesEvenWhileTheBookIsStillLoading() async throws {
        try await withSlowIndexBook { session, db, readingID, postIDs in
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
            // The arrival seed lands the first note. The landing is asked for
            // as soon as the page is real — deliberately NOT after the book
            // has settled, because a settled column is the WARM case F1 already
            // measured at 21 of 21.
            await settle(window, hosting, until: {
                BookIndexGeometry.paneAnchorTops["bip-\(postIDs[0])"] != nil
            })

            let far = postIDs[5]
            model.requestReveal(far)
            await settle(window, hosting, until: {
                abs(BookIndexGeometry.paneAnchorTops["bip-\(far)"] ?? .greatestFiniteMagnitude) <= 2
            }, maxTurns: 300)

            let reported = BookIndexGeometry.paneAnchorTops["bip-\(far)"]
            print("[13u4 F3] cold far landing top="
                + (reported.map { "\($0)" } ?? "never reported"))
            print("[13u4 F3 story] " + BookIndexGeometry.trace.suffix(30).joined(separator: " | "))
            let top = try #require(
                reported,
                "the target row never reported — the page is somewhere else entirely")
            #expect(abs(top) <= 2,
                    "the note the landing named is at the top of the page: top=\(top)")
            #endif
        }
    }
}
