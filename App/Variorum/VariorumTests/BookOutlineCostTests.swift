//
//  BookOutlineCostTests.swift
//  VariorumTests
//
//  **Phase 13u2b UNIT 1, rider 2 (architect ruling AR-1): what the exact
//  column COSTS, measured at the observation window's own cap.**
//
//  The runs of small rows stopped being `LazyVStack`s so that no row's height
//  is ever a lazy container's average of its siblings — that is what stops a
//  landed page sliding off its target. The price is that every row in the
//  window now EXISTS: a far one as a `Color.clear` placeholder at a height
//  the manifest knows, carrying its landing anchor and one geometry report.
//  At the window cap (`BookViewModel.entryWindow` = 300 notes, plus their
//  chapter headings) that is ~400 tiny views where a lazy container built a
//  screenful.
//
//  Two claims are PINNED here, and both are P1 sentences rather than
//  stopwatches (the `ReadLayerP1Tests` discipline this file follows):
//
//  1. **A book read in CARDS never runs the lengths query.** Her own gesture
//     — open a book, click a chapter — reads nothing beyond the previews the
//     entries already carry, because a card's height has nothing to do with
//     its note's length. The estimate arm exists for EXPANDED notes only.
//  2. **Nothing rebuilds at autosave rate.** An entries re-delivery (which is
//     what every keystroke produces, through `last_touched_at`) costs no
//     lengths read and no preview read.
//
//  The TIMES this file prints are recorded in the plan's UNIT 1 RECORD with
//  the machine state beside them; they are deliberately not assertions (a
//  timing assertion in a suite that shares a machine with a build is the
//  load-flaky class this project keeps in `KnownIssuesAndTechDebt`).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The Outline's cost at the window cap (13u2b UNIT 1, rider 2)", .serialized)
@MainActor
struct BookOutlineCostTests {
    /// A book at the observation window's cap: 300 notes, each with the kind
    /// of opening paragraph a real note has, filed three to a chapter.
    private func withCappedBook<T>(
        notes: Int = BookViewModel.entryWindow,
        _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the cap", kind: .curated)
            var postIDs: [String] = []
            for p in 0..<notes {
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
            for c in 0..<(notes / 3) {
                let section = try session.operations.createSection(
                    in: reading.id, name: "chapter \(c)")
                for i in (c * 3)..<min(c * 3 + 3, notes) {
                    try session.operations.assignPostToSection(
                        postIDs[i], in: reading.id, section: section.id)
                }
            }
            return try await body(session, db, reading.id, postIDs)
        }
    }

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func turn(_ window: NSWindow, _ hosting: NSView) async {
        hosting.layoutSubtreeIfNeeded()
        window.layoutIfNeeded()
        window.displayIfNeeded()
        pump()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
    }

    @Test func aBookAtTheWindowCapMountsAndLaysOutWithoutReadingAnyLengths() async throws {
        try await withCappedBook { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
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
            BookOutlineExtentReads.byBook[readingID] = 0

            let adoptStart = Date()
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let adoptMs = Date().timeIntervalSince(adoptStart) * 1000
            #expect(model.entries.count == BookViewModel.entryWindow)

            let mountStart = Date()
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
            defer {
                window.orderOut(nil)
                window.close()
            }
            for _ in 0..<8 { await turn(window, hosting) }
            let mountMs = Date().timeIntervalSince(mountStart) * 1000

            // A settled column: how long ONE more full layout pass costs when
            // every row in the window exists.
            var layoutTotal: TimeInterval = 0
            for _ in 0..<20 {
                hosting.needsLayout = true
                let start = Date()
                hosting.layoutSubtreeIfNeeded()
                layoutTotal += Date().timeIntervalSince(start)
            }
            let layoutMs = layoutTotal / 20 * 1000

            // The manifest over the whole column — built on demand, so its
            // cost is paid at a landing and nowhere else.
            var manifestTotal: TimeInterval = 0
            var rows = 0
            for _ in 0..<20 {
                let start = Date()
                let manifest = model.outlineHeightManifest(rows: BookOutlineRows.rows(
                    grouped: structure.grouped(entries: model.entries)))
                manifestTotal += Date().timeIntervalSince(start)
                rows = manifest.rows.count
            }
            let manifestMs = manifestTotal / 20 * 1000

            print("""
                COST AT THE CAP (13u2b rider 2): notes=\(model.entries.count) rows=\(rows) \
                adopt=\(String(format: "%.1f", adoptMs))ms \
                mount+8turns=\(String(format: "%.1f", mountMs))ms \
                layoutPass=\(String(format: "%.3f", layoutMs))ms \
                manifest=\(String(format: "%.3f", manifestMs))ms \
                (\(String(format: "%.4f", manifestMs / Double(max(rows, 1))))ms/row) \
                lengthsReads=\(BookOutlineExtentReads.count(readingID))
                """)

            // **P1, PINNED:** a book read in cards reads no lengths at all.
            #expect(BookOutlineExtentReads.count(readingID) == 0,
                    "a collapsed book never runs the lengths query")
            // And the column really did build its rows (the cost above is the
            // cost of something, not of an empty view).
            #expect(rows == BookViewModel.entryWindow + BookViewModel.entryWindow / 3,
                    "every note and every chapter heading is a row: \(rows)")
        }
    }

    /// **Nothing rebuilds at autosave rate.** Every keystroke stamps the
    /// note's container, which re-delivers the whole entry list — so the
    /// question "what does typing cost the book" is really "what does a
    /// re-delivery cost", and the answer must be nothing.
    @Test func anEntriesRedeliveryCostsNoReadAtAll() async throws {
        try await withCappedBook(notes: 30) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            let entries = try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            }
            await model.adopt(entries)
            BookOutlineExtentReads.byBook[readingID] = 0
            let previewsBefore = BookCardPreviewReads.reads

            // Ten deliveries, as ten keystrokes would produce.
            for _ in 0..<10 { await model.adopt(entries) }

            #expect(BookOutlineExtentReads.count(readingID) == 0,
                    "a re-delivery never runs the lengths query")
            #expect(BookCardPreviewReads.reads == previewsBefore,
                    "a re-delivery never re-reads the previews (13u2 UNIT A2's invariant, unmoved)")
        }
    }

    /// The other half of claim 1: the lengths ARE read when a note is
    /// expanded, exactly once for the book, because that is the only row
    /// whose height depends on its note's length.
    @Test func expandingANoteReadsTheLengthsOnceForTheWholeBook() async throws {
        try await withCappedBook(notes: 30) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            BookOutlineExtentReads.byBook[readingID] = 0

            model.expand(postIDs[3])
            for _ in 0..<40 where BookOutlineExtentReads.count(readingID) == 0 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(BookOutlineExtentReads.count(readingID) == 1,
                    "the first expansion reads the book's lengths once")

            // Every further expansion is free — the cache is the book's.
            model.expand(postIDs[7])
            model.expandAll()
            for _ in 0..<20 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(BookOutlineExtentReads.count(readingID) == 1,
                    "expanding more notes re-reads nothing: \(BookOutlineExtentReads.count(readingID))")
        }
    }
}
