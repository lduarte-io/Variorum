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

    /// **PIN 1 — THE MECHANISM: the column does not move under a landing.**
    ///
    /// The span is reset at the moment the landing is asked for, and that is
    /// the honest scope rather than a convenient one. A column cannot know its
    /// notes' lengths before it has read them — one bounded statement, tens of
    /// milliseconds — so the very first frames of the very first book of a
    /// session stand on a prior whatever this unit does. What the unit
    /// promises, and what the residual is actually about, is the sentence
    /// F1's trace ends on: **while a landing is in flight the column must not
    /// be discovering its own geometry.** So the pin measures exactly that
    /// window.
    ///
    /// The bound is a MEASURED number, stated at the assertion with both
    /// trees' readings, not a tuned-until-green one.
    ///
    /// RED ON OLD — the pre-fix reading is in the unit's record.
    @Test func theColumnDoesNotMoveUnderALandingWhileTheBookIsStillLoading() async throws {
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
            // The page is real (the arrival seed has landed the first note).
            await settle(window, hosting, until: {
                BookIndexGeometry.paneAnchorTops["bip-\(postIDs[0])"] != nil
            })

            // THE WINDOW UNDER TEST starts here: forget every height the
            // column reported while it was being built, and watch what it does
            // from the moment a landing is asked for.
            BookIndexGeometry.paneContentSpans = [:]
            model.requestReveal(postIDs[5])
            await settle(window, hosting, until: { false }, maxTurns: 120)

            let span = try #require(
                BookIndexGeometry.paneContentSpans[readingID],
                "the pane never reported a content height during the landing")
            print("[13u4 F3] landing-window span low=\(Int(span.low)) high=\(Int(span.high)) "
                + "growth=\(String(format: "%.1f", span.growth))× reports=\(span.reports)")
            // Pre-fix the column is still discovering itself — a row of this
            // pane is a title and a blank line until its text arrives — so it
            // grows by a large multiple WHILE the landing is running, which is
            // the residual's whole mechanism. Post-fix it is already standing
            // at length-derived heights, so what is left to move is the
            // difference between an estimate and the truth. Both readings are
            // in the record.
            let growth = String(format: "%.1f", span.growth)
            #expect(span.growth <= 2,
                    "the column holds still under a landing: \(Int(span.low)) → \(Int(span.high)) pt (\(growth)×)")
            #endif
        }
    }

    /// **PIN 3 — THE CALIBRATION: the estimate is near the truth.**
    ///
    /// The other two pins are about the column HOLDING STILL, which a
    /// consistently wrong estimate would also satisfy — a column standing at
    /// uniformly doubled heights does not move either, and every landing still
    /// arrives, because a landing addresses rows by anchor. What a wrong
    /// estimate costs is the ONE-TIME SHIFT when a far row enters the near
    /// band and trades its arithmetic for its real height (13u2b UNIT 1's
    /// rider-4 class, named there as the compensator's honest job). So this
    /// pin reads a note's DERIVED height against the height that note actually
    /// drew, and holds the model to it.
    ///
    /// The tolerance is stated as a RATIO rather than points because the
    /// estimate's error is proportional: it is a model of wrapping.
    @Test func theDerivedHeightOfANoteIsNearWhatThatNoteDraws() async throws {
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
            // The first note realizes at the arrival seed and reports its real
            // height once its text has arrived.
            let first = postIDs[0]
            await settle(window, hosting, until: {
                (BookIndexGeometry.paneNoteHeights[first] ?? 0) > 1000
            }, maxTurns: 120)

            let drawn = try #require(
                BookIndexGeometry.paneNoteHeights[first],
                "the first note never reported a height")
            // The DERIVED answer for the same note, read through the model's
            // own door with the measurement deliberately bypassed — this is
            // the arithmetic a FAR row stands on.
            let extents = try await session.database.read { [first] in
                try Queries.blockExtents($0, containerIDs: [first])
            }
            let derived = BookIndexPaneHeightModel.noteHeight(
                extents: extents, metrics: model.indexPaneHeights.metrics)
            let ratio = derived / max(drawn, 1)
            print("[13u4 F3] calibration: derived=\(Int(derived)) drawn=\(Int(drawn)) "
                + "ratio=\(String(format: "%.2f", ratio))")
            let shown = String(format: "%.2f", ratio)
            #expect(ratio > 0.8 && ratio < 1.2,
                    "a note's length-derived height is within a fifth of what it draws: derived=\(Int(derived)) drawn=\(Int(drawn)) (\(shown)×)")
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
