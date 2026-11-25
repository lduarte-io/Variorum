//
//  BookOutlineTravelTests.swift
//  VariorumTests
//
//  VX-96 (a rider on the VX-1036 run, batch 1; the VX-92 ladder's round-1
//  finding R1-2, `notes/plans/vx-92-ladder-round1.md`) — THE REVEAL'S
//  PRE-MOUNT ARM HOLDS FOR THE LANDING'S LIFETIME.
//
//  VX-91's fix pre-mounts the row she is on her way to — focused, or the
//  pending reveal's target — so a far expanded story starts filling at the
//  click instead of landing her on a viewport of placeholders (the title
//  alone). The reveal's arm read `pendingReveal`, and the Outline's landing
//  CONSUMES the reveal before it scrolls (`BookView.landOutlineReveal` →
//  `consumeReveal`, then `landOutline`), so on a reveal-WITHOUT-focus road —
//  the mode switch's carry into Outline, the W20 ascent into an open,
//  all-expanded book — the arm lapsed at once: the target never pre-mounted
//  (or mounted for one pass and tore down), and those roads kept the shipped
//  title-over-blank beat. The fix sketch, the reviewer's: a travelling id set
//  with the reveal and cleared where the landing settles, gives up, or she
//  takes over.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-96 — the reveal's pre-mount arm holds while the Outline's landing travels", .serialized)
struct BookOutlineTravelTests {
    /// One run-loop beat (synchronous — `RunLoop.run` is unavailable from an
    /// async context; the suites' own `pump`).
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withModel<T>(
        _ body: @MainActor (AppSession, BookViewModel, _ storyID: String) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        // The operations stamp through `\.date` and place through the
        // fractional index's `\.withRandomNumberGenerator`; both are provided
        // here the BookView neighbours' way (`withLandingBook`,
        // `withMintLandingBook`) — a one-second ticking clock and a seeded
        // generator — so the host's test context never meets an
        // unimplemented dependency.
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 96))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "the adventures", kind: .book)
            let story = try session.operations.createPost(title: "a far story")
            try session.operations.addPostToReading(story.id, to: book.id)
            let model = BookViewModel(session: session, readingID: book.id)
            // A width no persisted `SurfaceSizeMemory` record can match (the
            // test host shares the dev app's real defaults — VX-97's class),
            // and her steady state: a record AT this width for the story.
            model.reportOutlineContentWidth(431)
            model.rememberSurfaceSize(story.id, CGSize(width: 431, height: 16000))
            return try await body(session, model, story.id)
        }
    }

    /// **PIN C (red on the pre-batch tree).** A reveal with NO focus — the
    /// carry's and the ascent's road. The Outline's landing takes the reveal
    /// before it scrolls; the row she is travelling to must keep its pre-mount
    /// through that, for the landing's lifetime.
    ///
    /// RED ON OLD: the consult read `pendingReveal`, which `consumeReveal`
    /// clears — the arm lapsed before the landing's first aim.
    @Test func theRevealsPreMountHoldsPastTheConsumeWhileTheLandingTravels() async throws {
        try await withModel { _, model, storyID in
            #expect(model.focusedPostID == nil, "a reveal-only road: nothing is focused")
            model.requestReveal(storyID)
            #expect(model.outlineRowPreMounts(storyID), "the reveal's target pre-mounts (VX-91's arm)")
            // What the Outline's landing does BEFORE it scrolls.
            model.consumeReveal()
            #expect(model.outlineRowPreMounts(storyID),
                    "the travelling row keeps its pre-mount while its landing travels — on the old consult it lapsed here")
        }
    }

    // MARK: - The travel's ends (the fix's model half)

    @Test func theTravelEndsWhereTheOutlineSaysItsLandingEnded() async throws {
        try await withModel { _, model, storyID in
            model.requestReveal(storyID)
            model.consumeReveal()
            #expect(model.travelingTo == storyID)
            model.travelEnded()
            #expect(model.travelingTo == nil)
            #expect(!model.outlineRowPreMounts(storyID), "landed — back to the viewport's rule")
        }
    }

    @Test func everyRoadThatAsksForARevealTravelsAndANewOneReplacesTheOld() async throws {
        try await withModel { session, model, storyID in
            let other = try session.operations.createPost(title: "another")
            model.rememberSurfaceSize(other.id, CGSize(width: 431, height: 9000))
            model.requestLanding(LandingTarget(postID: storyID, blockID: nil))
            #expect(model.travelingTo == storyID, "the block landing's road travels too")
            model.requestReveal(other.id)
            #expect(model.travelingTo == other.id, "a new reveal replaces the travel")
            #expect(!model.outlineRowPreMounts(storyID) && model.outlineRowPreMounts(other.id))
        }
    }

    // MARK: - In the live Outline (the reviewer's sketch, hosted)

    /// **PIN C's hosted twin (red on the pre-batch tree — pre-batch API only).**
    /// The VX-91 integration pin's stage, on the REVEAL-ONLY road: a far
    /// EXPANDED story beyond the near band, a width-matched memory, and a
    /// reveal with no focus. From the moment the Outline's landing has taken
    /// the request until that landing ends, the story's row keeps its
    /// pre-mount — and once the landing has ended, the arm lets go (a travel
    /// never outlives its landing).
    ///
    /// RED ON OLD: on every turn between the consume and the landing's end the
    /// consult answered false (it read the consumed request).
    @Test func aRevealOnlyLandingHoldsThePreMountUntilItEndsThenLetsGo() async throws {
        let db = try AppDatabase.inMemory()
        // The same two dependencies `withModel` provides, the same way (the
        // VX-91 pin's own harness, `withLandingBook`, provides them too).
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 96))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "the adventures", kind: .book)
            var postIDs: [String] = []
            for p in 0..<80 {
                let post = try session.operations.createPost(title: "note \(p)")
                let blocks = p == 70 ? 215 : 1
                for b in 0..<blocks {
                    _ = try session.operations.newBlock(
                        in: post.id,
                        text: "Paragraph \(b) of note \(p). We were seated at breakfast one morning, "
                            + "my wife and I, when the maid brought in a telegram from Baker Street.")
                }
                try session.operations.addPostToReading(post.id, to: book.id)
                postIDs.append(post.id)
            }
            let storyID = postIDs[70]
            let model = BookViewModel(session: session, readingID: book.id)
            await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: book.id) })
            let structure = BookStructureModel(session: session, readingID: book.id)
            structure.adopt(.init(
                reading: try await db.read { try Queries.reading($0, id: book.id) },
                sections: [], deletedSections: [], assignments: [:]))
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1200, height: 760),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(session: session, readingID: book.id, model: model, structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 760)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            @MainActor func turn() async {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            let anchor = BookOutlineRows.Row.noteAnchor(storyID)
            model.expand(storyID)
            for _ in 0..<120 where !(model.outlineContentWidth > 0 && BookOutlineGeometry.anchorTops[anchor] != nil) {
                await turn()
            }
            model.rememberSurfaceSize(storyID, CGSize(width: model.outlineContentWidth, height: 16000))
            let top = try #require(BookOutlineGeometry.anchorTops[anchor])
            #expect(top > 5200, "the story starts beyond the near band: \(Int(top))")
            for _ in 0..<10 { await turn() }

            model.requestReveal(storyID)   // the carry's / the ascent's road: NO focus
            #expect(model.focusedPostID == nil)
            @MainActor func ended() -> Bool { BookOutlineGeometry.trace.contains { $0.hasPrefix("\(anchor) DONE:") } }
            var travellingTurns = 0
            var lapsedTurns = 0
            for _ in 0..<240 where !ended() {
                await turn()
                // The landing has taken the request and is still travelling.
                if model.pendingReveal == nil, !ended() {
                    travellingTurns += 1
                    if !model.outlineRowPreMounts(storyID) { lapsedTurns += 1 }
                }
            }
            #expect(ended(), "the landing ended: \(BookOutlineGeometry.trace.suffix(6))")
            #expect(travellingTurns > 0, "the pin saw the landing travel (non-vacuity)")
            #expect(lapsedTurns == 0,
                    "the pre-mount held on every travelling turn — it lapsed on \(lapsedTurns) of \(travellingTurns)")
            for _ in 0..<3 { await turn() }
            #expect(!model.outlineRowPreMounts(storyID), "once the landing ended, the arm let go")
        }
    }
}
