//
//  ScrubAndOutlineTests.swift
//  VariorumTests
//
//  Phase 11, Step A5 — book-scrub (model-driven: the post list is the
//  scrubber's domain, the Phase 6 memo's ruling) and outline↔draft (the
//  mapping is the lineage CTEs', verbatim, never re-derived view-side —
//  13b 4C: the Outline tab retired into Compare, and the mapping pin
//  migrated onto the compare board's kinship read; justification at the
//  test).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("Book-scrub & outline↔draft (Phase 11, A5)")
@MainActor
struct ScrubAndOutlineTests {
    /// The scrubber's landing is MODEL-DRIVEN and uniform over posts:
    /// page = a post, whatever its length (50 entries = 50 pages).
    @Test func scrubMappingIsUniformOverThePostListAndClamped() {
        // 50 pages: the track's halves land mid-list, the edges clamp.
        #expect(BookViewModel.scrubIndex(fraction: 0, count: 50) == 0)
        #expect(BookViewModel.scrubIndex(fraction: 1, count: 50) == 49)
        #expect(BookViewModel.scrubIndex(fraction: 0.5, count: 50) == 25)
        #expect(BookViewModel.scrubIndex(fraction: -3, count: 50) == 0, "clamped below")
        #expect(BookViewModel.scrubIndex(fraction: 7, count: 50) == 49, "clamped above")
        #expect(BookViewModel.scrubIndex(fraction: 0.5, count: 0) == nil, "empty reading")
        // Every page is REACHABLE: some fraction lands each index.
        let count = 7
        var reached = Set<Int>()
        for step in 0...100 {
            if let index = BookViewModel.scrubIndex(
                fraction: Double(step) / 100, count: count) {
                reached.insert(index)
            }
        }
        #expect(reached == Set(0..<count), "the scrubber reaches every page")
    }

    @Test func scrubTargetReadsTheAssembledListVerbatim() async throws {
        try await withWorld { session, db in
            let readingID = try await session.runner.run { ops -> String in
                let reading = try ops.createReading(name: "book", kind: .curated, maxPosts: nil)
                for i in 1...5 {
                    let post = try ops.createPost(title: "chapter \(i)", profile: .bookChapter)
                    _ = try ops.newBlock(in: post.id, text: "Chapter \(i) text.", at: .end)
                    _ = try ops.addPostToReading(post.id, to: reading.id)
                }
                return reading.id
            }
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
            #expect(model.entries.count == 5)
            #expect(model.scrubTarget(fraction: 0)?.title == "chapter 1")
            #expect(model.scrubTarget(fraction: 1)?.title == "chapter 5")
            #expect(model.scrubTarget(fraction: 0.5)?.title == "chapter 3")
        }
    }

    /// 13b 4C (justified pin migration, recorded in the batch record): the
    /// Outline TAB retired into Compare (S4-3), and OutlineDraftViewModel
    /// died with it — this pin's SEMANTIC core survives re-pinned here:
    /// the outline↔draft mapping is the lineage traversal's, VERBATIM,
    /// never re-derived view-side. The compare board reads
    /// `Queries.blockKinship` (ancestors + descendants — the same CTEs);
    /// a minted outline registers block-by-block against its draft, a
    /// divide's pieces collapse onto ONE outline point's row, and a fresh
    /// unrelated block maps to nothing (a free row, not a blank).
    /// The retired tab's tracked-scroll/highlight faces die with the
    /// surface (her ruling: outline "needs to be nothing that a compare
    /// already isn't") — they are deliberately not re-pinned.
    @Test func outlineBesideItsDraftRegistersThroughLineageInCompare() async throws {
        try await withWorld { session, db in
            let (outlineID, draftID) = try await session.runner.run { ops -> (String, String) in
                let outline = try ops.createPost(title: "the outline", profile: .blog)
                _ = try ops.newBlock(in: outline.id, text: "Point one, to expand.", at: .end)
                _ = try ops.newBlock(in: outline.id, text: "Point two, to expand.", at: .end)
                let draft = try ops.duplicateAsVersion(outline.id)
                // Divide a draft block: its pieces are DEPTH-2 descendants
                // of the outline block.
                try ops.renameContainer(draft.post.id, title: "the draft")
                _ = try ops.divide(draft.blockCopies[0].copy, cut: 10)
                // A fresh draft block derives from nothing — maps nowhere.
                _ = try ops.newBlock(in: draft.post.id, text: "Fresh in the draft.", at: .end)
                return (outline.id, draft.post.id)
            }

            // The projection reads the CTE-backed kinship verbatim — the
            // ONE read brain the observation and this pin share.
            let projection = try await db.read { db in
                try CompareViewModel.read(db, anchor: draftID, peers: [outlineID])
            }
            let expected = try await db.read { db in
                try Queries.blockKinship(db, anchor: draftID, other: outlineID)
            }
            #expect(projection.kinship[outlineID] == expected,
                    "the board's kinship IS the lineage traversal's — verbatim")

            // Registration: the divide's two pieces sit on ONE outline
            // point's row (the span); point two pairs; the fresh draft
            // block is free — never a blank row.
            let draftBlocks = try await db.read { db in
                try Queries.renderPost(db, containerID: draftID).map(\.blockID)
            }
            let outlineBlocks = try await db.read { db in
                try Queries.renderPost(db, containerID: outlineID).map(\.blockID)
            }
            let segments = CompareComposition.segments(
                anchorBlocks: outlineBlocks,
                peerBlocks: [draftBlocks],
                kinships: [try await db.read { db in
                    try Queries.blockKinship(db, anchor: outlineID, other: draftID)
                }],
                followAnchorOrder: true)
            guard case .aligned(let pointOne) = segments.first else {
                Issue.record("outline point one aligns"); return
            }
            #expect(pointOne.anchorBlockID == outlineBlocks[0])
            #expect(pointOne.peerKin == [[draftBlocks[0], draftBlocks[1]]],
                    "the divide's span shares point one's row")
            #expect(segments.contains(.aligned(.init(
                anchorBlockID: outlineBlocks[1],
                peerKin: [[draftBlocks[2]]], peerMoved: [false]))))
            #expect(segments.contains(.free(anchor: [], peers: [[draftBlocks[3]]])),
                    "the fresh block flows free — no blank row invented for it")
        }
    }
}
