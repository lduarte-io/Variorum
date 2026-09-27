//
//  OutlineLandingTeardownTests.swift
//  VariorumTests
//
//  **18l-b UNIT U4, item 1 — the book Outline's landing dies WITH the Outline
//  (the 13u2b ladder's R2-12, brought to the one adopter that never carried
//  it).** The health review's §1.3 item 4: *"the book Outline is the only
//  authority adopter without `.onDisappear { landing.end() }` (the flow and
//  Index both carry it, citing ladder R2-12)."*
//
//  **The mechanism, traced at the code.** The Outline's `LandingAuthority` is
//  `BookView`'s `@State`, not the Outline body's — so a MODE SWITCH (Outline →
//  Index, Read, the spread) removes the Outline's scroll view and its rows but
//  leaves the authority alive with its check armed. Nothing reports any more,
//  so the next look decides on the target's LAST report: at the top ⇒ `DONE:
//  settled` once the hold is over; anywhere else ⇒ corrections aimed through a
//  DEAD `ScrollViewProxy` until the watchdog files `gave up` — a landing
//  "ending" on a surface that is gone, and (in Release) a signpost line in her
//  Console for a landing she never saw finish. The flow's pin
//  (`ReadingFlowLandingTests.aFlowTornDownMidLandingLeaksNoDoneIntoTheNextFlow`)
//  is this claim for the flow, whose authority dies with the flow's own view;
//  the Outline's road to the same leak is the mode switch, so this pin takes
//  that road. Its harness is copied (not shared) so `BookOutlineLandingTests`
//  rides byte-unmodified.
//
//  RED ON OLD: the Outline's landing wrote a `DONE` after the switch.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A book of forty short cards — long enough that a reveal of the twenty-sixth
/// has to travel (`BookOutlineLandingTests.anOffScreenCollapsedNoteIsRevealedAtTheTop`'s
/// own shape).
@MainActor
private func withCardBook<T>(
    posts: Int,
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 52))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the teardown", kind: .curated)
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

@MainActor
@Suite("18l-b U4 — the Outline's landing dies with the Outline (R2-12 parity)", .serialized)
struct OutlineLandingTeardownTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        timeout: TimeInterval, until predicate: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
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

    /// **THE PIN.** Land far down the Outline, switch modes inside the
    /// landing's first second (before its one-second hold can let it finish),
    /// and wait past its whole time budget: the Outline's landing must write
    /// NO `DONE` — it ended, silently, with the Outline (`LandingAuthority.end`,
    /// silent by the authority's own rule: nothing landed and the surface is
    /// gone). RED ON OLD: `DONE: settled` after the hold, or `gave up` at the
    /// watchdog, written by a landing whose surface was already gone.
    @Test func aModeSwitchMidLandingLeavesTheOutlinesLandingNoDoneToWrite() async throws {
        try await withCardBook(posts: 40) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            #expect(structure.mode == .outline, "the premise: the book opens in Outline")
            #if DEBUG
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            #endif
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
            #if DEBUG
            await settle(window, hosting, timeout: 10) {
                BookOutlineGeometry.anchorTops[BookOutlineRows.Row.noteAnchor(postIDs[0])] != nil
            }

            // The navigator's reveal of a card far below the fold.
            model.requestReveal(postIDs[25])
            await settle(window, hosting, timeout: 5) {
                BookOutlineGeometry.trace.contains { $0.hasSuffix(" LAND") }
            }
            #expect(BookOutlineGeometry.trace.contains { $0.hasSuffix(" LAND") },
                    "the Outline's landing began: \(BookOutlineGeometry.trace.suffix(6))")

            // Her mode switch — at once, well inside the one-second hold.
            structure.mode = .index
            let doneBefore = BookOutlineGeometry.trace.filter { $0.contains(" DONE: ") }
            #expect(doneBefore.isEmpty,
                    "nothing finished before the switch: \(BookOutlineGeometry.trace.suffix(6))")

            // Past the Outline's whole time budget (4 s) and then some.
            await settle(window, hosting, timeout: BookView.landingTimeBudget + 1.5) { false }
            #expect(structure.mode == .index, "the book is still in Index")
            let doneAfter = BookOutlineGeometry.trace.filter { $0.contains(" DONE: ") }
            print("[18l-b U4 item 1] DONE lines after the switch: \(doneAfter); "
                + "story tail: \(BookOutlineGeometry.trace.suffix(12))")
            #expect(doneAfter.isEmpty, Comment(rawValue:
                "the Outline's landing ended WITH the Outline — no DONE written by a landing "
                    + "whose surface was gone: \(doneAfter)"))
            #endif
        }
    }
}
