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

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-96 — the reveal's pre-mount arm holds while the Outline's landing travels", .serialized)
struct BookOutlineTravelTests {
    private func withModel<T>(
        _ body: @MainActor (AppSession, BookViewModel, _ storyID: String) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
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
}
