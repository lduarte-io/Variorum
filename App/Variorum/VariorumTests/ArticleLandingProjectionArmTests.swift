//
//  ArticleLandingProjectionArmTests.swift
//  VariorumTests
//
//  13u2 UNIT E — **the ONE structural arm at `adopt`**
//  (`KnownIssuesAndTechDebt` row 51's recommended design, built inside the
//  `TakesArticleScroll` split).
//
//  WHAT IT REPLACES AS A COMPLETENESS ARGUMENT: until now, "her hand ends a
//  pending article landing" was covered BY ENUMERATION — a table of a dozen
//  gesture doors on `clearArticleLanding`'s doc, each with its own arm. That
//  table's completeness was argued three times and falsified twice (round 1
//  claimed "by construction" for the structure controller; round 2 measured
//  the note-wide split and the callout; round 3 measured the ⌘-pick's
//  selection banner). And an enumeration of GESTURES cannot, in principle,
//  cover the roads that are not gestures: a sync arrival, a structural undo
//  performed in another window, an engine repair.
//
//  The arm: a projection that arrives while a landing is pending and DIFFERS
//  from the one the landing was judged against ends it. A content change IS
//  a projection that differs, whatever produced it.
//
//  **The enumerated arms STAY.** They end a landing AT the gesture, which is
//  when her hand moved, and ~15 pins assert exactly that timing; the arm is a
//  net under them, not a replacement for them. The unit record says why in
//  full.
//
//  RED ON OLD is by BEHAVIOURAL REVERT on the committed tree (the house
//  method — `ShellLandingTests`' own): `noteProjectionArrived`'s body emptied
//  in place. Numbers in the unit record.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A projection arrival ends a pending article landing (13u2 UNIT E — row 51)")
struct ArticleLandingProjectionArmTests {
    private struct World {
        let session: AppSession
        let db: AppDatabase
        let postID: String
    }

    private func withWorld(
        _ body: @MainActor (World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 51))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the article")
            for text in ["The first block.", "The second block.", "The third block."] {
                _ = try session.operations.newBlock(in: post.id, text: text)
            }
            try await body(World(session: session, db: db, postID: post.id))
        }
    }

    private func projection(_ world: World) async throws -> Queries.TakesProjection {
        try await world.db.read { [id = world.postID] db in
            try Queries.takesProjection(db, post: id)
        }
    }

    /// **THE ARM.** A landing is pending; the note's CONTENT changes (a block
    /// minted — the shape a sync arrival, an undo in another window or an
    /// unenumerated door all produce); the landing ends.
    ///
    /// RED ON OLD (the body emptied): the landing survives the arrival, which
    /// is precisely the state the road table exists to prevent — a reveal
    /// aiming at a page whose rows have moved under it.
    @Test func aProjectionThatChangesTheContentEndsAPendingLanding() async throws {
        try await withWorld { world in
            let scroll = TakesArticleScroll()
            let first = try await projection(world)
            let row = try #require(first.slots.first?.placementID)
            scroll.noteProjectionArrived(first)
            scroll.landArticle(on: row)
            #expect(scroll.articleLanding == row, "the landing is pending")

            _ = try world.session.operations.newBlock(
                in: world.postID, text: "A fourth block, minted by someone.")
            let second = try await projection(world)
            #expect(first != second, "non-vacuity: the projection really changed")

            scroll.noteProjectionArrived(second)
            #expect(scroll.articleLanding == nil,
                    "RED ON OLD: a content change ends a pending landing, whatever made it")
        }
    }

    /// **An IDENTICAL arrival is not a content change.** The board adopts at
    /// autosave cadence and re-delivers the same projection constantly; an arm
    /// that fired on every arrival would kill every landing before its first
    /// aim.
    @Test func anIdenticalArrivalLeavesTheLandingAlone() async throws {
        try await withWorld { world in
            let scroll = TakesArticleScroll()
            let first = try await projection(world)
            let row = try #require(first.slots.first?.placementID)
            scroll.noteProjectionArrived(first)
            scroll.landArticle(on: row)

            for _ in 0..<5 { scroll.noteProjectionArrived(first) }
            #expect(scroll.articleLanding == row,
                    "the same projection, five times, and the landing still stands")
        }
    }

    /// **The FIRST arrival never ends anything** — with no judged projection
    /// in hand there is nothing to differ from, and a mount whose landing is
    /// set before its first adoption (every landing pin's order, and the app's
    /// whenever a door lands before the observation delivers) must keep it.
    @Test func theFirstArrivalNeverEndsALanding() async throws {
        try await withWorld { world in
            let scroll = TakesArticleScroll()
            let first = try await projection(world)
            let row = try #require(first.slots.first?.placementID)
            scroll.landArticle(on: row)          // landed BEFORE any projection
            scroll.noteProjectionArrived(first)
            #expect(scroll.articleLanding == row,
                    "nothing to compare against is not a reason to throw her landing away")
        }
    }

    /// **THE CHOSEN BEHAVIOUR, pinned so it is a decision and not a
    /// discovery** (row 51 asks for exactly this to be written down): `!=` on
    /// `Queries.TakesProjection` fires on ANY field, so a METADATA-only
    /// arrival — here the note's ENTRY DATE — ends a pending landing too. The safe
    /// direction, and the alternative (a field-by-field "does this move
    /// heights" predicate) is a second completeness argument of the kind this
    /// arm exists to retire. QUESTIONS #113.
    @Test func aMetadataOnlyArrivalEndsOneToo() async throws {
        try await withWorld { world in
            let scroll = TakesArticleScroll()
            let first = try await projection(world)
            let row = try #require(first.slots.first?.placementID)
            scroll.noteProjectionArrived(first)
            scroll.landArticle(on: row)

            // The note's ENTRY DATE: on the projection (its `profile` +
            // `entryDate` pair) and incapable of moving a row's height.
            try await world.session.runner.run { [id = world.postID] ops in
                try ops.setEntryDate(id, entryDate: "2026-03-04")
            }
            let second = try await projection(world)
            #expect(first != second)
            #expect(first.slots.map(\.placementID) == second.slots.map(\.placementID),
                    "non-vacuity: the ROWS are identical — only metadata moved")

            scroll.noteProjectionArrived(second)
            #expect(scroll.articleLanding == nil,
                    "chosen behaviour: a metadata-only arrival ends a landing too")
        }
    }

    /// **THE WIRING**, through the real seam rather than the brain alone: the
    /// board's own `adopt` runs the arm, and it runs BEFORE `consumeLandings`
    /// can make a landing against the projection that is arriving (or the arm
    /// would kill every landing the same adoption made).
    @Test func theBoardsAdoptRunsTheArmAndANewLandingSurvivesIt() async throws {
        try await withWorld { world in
            let model = TakesViewModel(session: world.session, postID: world.postID)
            let first = try await projection(world)
            model.adopt(first)
            let row = try #require(first.slots.first?.placementID)
            model.board.landArticle(on: row)
            #expect(model.board.articleLanding == row)

            _ = try world.session.operations.newBlock(
                in: world.postID, text: "A fourth block.")
            model.adopt(try await projection(world))
            #expect(model.board.articleLanding == nil,
                    "RED ON OLD: the seam is wired — a content arrival through `adopt` ends it")
        }
    }
}
