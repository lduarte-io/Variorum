//
//  ScrubAndOutlineTests.swift
//  VariorumTests
//
//  Phase 11, Step A5 — book-scrub (model-driven: the post list is the
//  scrubber's domain, the Phase 6 memo's ruling) and outline↔draft (the
//  mapping is `Queries.derivedBlocks`' — the CTE's, verbatim, never
//  re-derived view-side).
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

    /// The outline mapping matches the CTE exactly — pinned against a REAL
    /// lineage world (a version copy whose blocks derive from the outline's,
    /// one of them divided so depth-2 descendants appear).
    @Test func outlineMappingMatchesTheDerivedBlocksCTEExactly() async throws {
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

            let model = OutlineDraftViewModel(session: session, draftPostID: draftID)
            model.outlinePostID = outlineID
            // The observation task is asynchronous; fetch the same
            // projection deterministically for the pin.
            let expected = try await db.read { db -> [String: [String]] in
                var mapping: [String: [String]] = [:]
                for slot in try Queries.renderPost(db, containerID: outlineID) where !slot.isGap {
                    mapping[slot.blockID] = try Queries.derivedBlocks(
                        db, fromOutlineBlock: slot.blockID, inContainer: draftID)
                        .map(\.blockID)
                }
                return mapping
            }
            // Wait for the model's own observation to deliver.
            for _ in 0..<200 where model.projection.mapping.isEmpty {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(model.projection.mapping == expected,
                    "the view's mapping IS the CTE's — verbatim")

            // Shape sanity on the real world: outline block 1 became TWO
            // blocks (the divide's pieces); block 2 exactly one; the fresh
            // draft block appears in NO mapping.
            let outlineBlocks = try await db.read { db in
                try Queries.renderPost(db, containerID: outlineID).map(\.blockID)
            }
            #expect(expected[outlineBlocks[0]]?.count == 2)
            #expect(expected[outlineBlocks[1]]?.count == 1)
            let draftBlocks = try await db.read { db in
                try Queries.renderPost(db, containerID: draftID).map(\.blockID)
            }
            let mapped = Set(expected.values.flatMap { $0 })
            #expect(Set(draftBlocks).subtracting(mapped).count == 1,
                    "exactly the fresh block maps to nothing")

            // Selection drives the highlight + the tracked-scroll target
            // from the SAME mapping.
            model.selectOutlineBlock(outlineBlocks[0])
            #expect(model.highlightedDraftBlocks == Set(expected[outlineBlocks[0]] ?? []))
            #expect(model.scrollTarget == expected[outlineBlocks[0]]?.first)
            model.trackedScroll = false
            #expect(model.scrollTarget == nil, "independent scroll — no forced landing")
            model.teardown()
        }
    }
}
