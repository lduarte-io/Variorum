import Foundation
import Testing
@testable import VariorumCore

/// Phase 7's read-layer additions: the editor's container header, the fan
/// behind the badge, per-variant commit history, and the split dates behind
/// the restoreCommit pre-split warning.
@Suite("Editor-support queries (Phase 7)")
struct EditorSupportQueryTests {
    // MARK: - containerHeader

    @Test func headerResolvesSegmentationFromTheGlobalSettingByDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "T")
            let header = try db.read { try Queries.containerHeader($0, containerID: post.id) }
            // Schema seed: ('default_segmentation', 'paragraph').
            #expect(header?.effectiveSegmentation == .paragraph)
            #expect(header?.locked == false)
            #expect(header?.archived == false)
            #expect(header?.kind == .post)
            #expect(header?.title == "T")
        }
    }

    @Test func headerPrefersTheContainerOverride() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            try ops.setSegmentationDefault(post.id, segmentation: .sentence)
            let header = try db.read { try Queries.containerHeader($0, containerID: post.id) }
            #expect(header?.effectiveSegmentation == .sentence)
        }
    }

    @Test func journalPostsSeedOneBlockSegmentation() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(profile: .journal)
            let header = try db.read { try Queries.containerHeader($0, containerID: post.id) }
            #expect(header?.effectiveSegmentation == .oneBlock)
        }
    }

    @Test func headerReflectsTheSealAndIsNilForTombstones() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "a")
            try ops.lockPost(post.id)
            let sealed = try db.read { try Queries.containerHeader($0, containerID: post.id) }
            #expect(sealed?.locked == true)

            try ops.unlockPost(post.id)
            try ops.deleteContainer(post.id)
            let gone = try db.read { try Queries.containerHeader($0, containerID: post.id) }
            #expect(gone == nil)
        }
    }

    // MARK: - blockFan

    @Test func blockFanListsLiveVariantsInFanOrderIncludingArchived() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "original")
            // A branch lands BESIDE its source (between it and the fan end).
            let branch = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            let blank = try ops.newBlankVariant(minted.block.id)
            try ops.archiveVariant(branch.id)

            let fan = try db.read { try Queries.blockFan($0, blockID: minted.block.id) }
            #expect(fan.map(\.id) == [minted.variant.id, branch.id, blank.id])
            #expect(fan.map(\.status) == [.active, .archived, .active])

            // A tombstoned take leaves the fan.
            try ops.deleteVariant(blank.id)
            let after = try db.read { try Queries.blockFan($0, blockID: minted.block.id) }
            #expect(after.map(\.id) == [minted.variant.id, branch.id])
        }
    }

    // MARK: - commitHistory

    @Test func commitHistoryIsNewestFirstScopedToTheVariant() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let minted = try ops.newBlock(in: post.id, text: "v1")
            let first = try ops.commit(minted.variant.id)
            try ops.autosave(minted.variant.id, text: "v2", charDelta: 2)
            let second = try ops.commit(minted.variant.id)
            // Another variant's commit must not appear.
            let other = try ops.newBlankVariant(minted.block.id)
            try ops.autosave(other.id, text: "x", charDelta: 1)
            _ = try ops.commit(other.id)

            let history = try db.read { try Queries.commitHistory($0, variantID: minted.variant.id) }
            #expect(history.map(\.id) == [second.id, first.id])
            #expect(history.map(\.text) == ["v2", "v1"])
        }
    }

    // MARK: - splitDates

    @Test func splitDatesSeesOnlyLiveDivideAndExtractEdgesWithTheBlockAsAncestor() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half here. Second half there.")
            // divide mints C derived_from A (origin divide): A is the ancestor.
            let cut = "First half here.".utf16.count
            _ = try ops.divide(a.block.id, cut: cut)

            let dates = try db.read { try Queries.splitDates($0, blockID: a.block.id) }
            #expect(dates.count == 1)

            // The successor block has no split edges of its own (it is the
            // descendant, not the ancestor).
            let placements = try db.read { try Queries.renderPost($0, containerID: post.id) }
            let successor = placements.map(\.blockID).first { $0 != a.block.id }
            let successorDates = try db.read { try Queries.splitDates($0, blockID: successor!) }
            #expect(successorDates.isEmpty)

            // A pool-copy edge is lineage but NOT a split: no warning from it.
            let pool = try ops.createPool()
            let scrap = try ops.newBlock(in: pool.id, text: "scrap")
            _ = try ops.poolDragCopy(scrap.block.id, to: post.id, at: .end)
            let scrapDates = try db.read { try Queries.splitDates($0, blockID: scrap.block.id) }
            #expect(scrapDates.isEmpty)
        }
    }

    /// The pre-split predicate (hoisted from the Mac's app-local
    /// CommitRules at parity C4a — one brain, both platforms): older
    /// than the NEWEST split warns; newer doesn't; no splits, no warning.
    @Test func commitPredatesSplitComparesAgainstTheNewestSplit() {
        let earlier = Date(timeIntervalSince1970: 100)
        let split = Date(timeIntervalSince1970: 200)
        let later = Date(timeIntervalSince1970: 300)
        #expect(Queries.commitPredatesSplit(commitDate: earlier, splitDates: [split]))
        #expect(!Queries.commitPredatesSplit(commitDate: later, splitDates: [split]))
        #expect(!Queries.commitPredatesSplit(commitDate: earlier, splitDates: []))
        #expect(Queries.commitPredatesSplit(
            commitDate: later, splitDates: [split, Date(timeIntervalSince1970: 400)]))
    }
}
