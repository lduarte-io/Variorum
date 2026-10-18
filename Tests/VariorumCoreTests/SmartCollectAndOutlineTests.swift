import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Taste checkpoint, Sitting 9 batch 10 — the two ops her question round
// settled: R98's collect-by-tagging (apply-and-report; descriptive
// refusals) and R99's outline mint (first sentence per block).

@Suite("Smart collect — R98 (adds by tagging, apply-and-report)")
struct SmartCollectTests {
    private func smartReading(
        _ ops: Operations, spec: Queries.SmartQuerySpec
    ) throws -> Reading {
        // 13i-c (R-13ic-4): a gathering is minted WITH its rule.
        try ops.createReading(name: "smart", kind: .gathering, querySpec: try spec.encodedJSON())
    }

    private func assembledPostIDs(
        _ db: AppDatabase, _ readingID: String
    ) throws -> [String] {
        try db.read { db in
            try Queries.assembleReading(db, readingID: readingID).map(\.postID)
        }
    }

    @Test func appliesTheFirstAnyOfTagAndReports() throws {
        try withOperations { ops, db in
            let tagA = try ops.createTag(name: "attention")
            _ = try ops.createTag(name: "stars")
            let reading = try smartReading(
                ops, spec: .init(tags: ["attention", "stars"]))
            let post = try ops.createPost(title: "loose piece")

            let result = try ops.collectPostIntoSmartReading(post.id, into: reading.id)
            #expect(result.appliedTagPaths == ["attention"],
                    "ANY-of applies the FIRST path, deterministically")
            #expect(result.alreadyMatched == false)
            let live = try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                [post.id, tagA.id])
            #expect(live == 1)
            #expect(try assembledPostIDs(db, reading.id) == [post.id],
                    "the post now assembles into the book — the add IS the tagging")
        }
    }

    /// VX-241 — R98 on an ARCHIVED gathering (the chip's picker offers one:
    /// 13i-e's explicit adds stay open). The tags apply, and the result says
    /// the gathering was archived when the act ran — it assembles EMPTY, so
    /// no receipt may claim it "shows it now".
    @Test func anArchivedGatheringStillTagsAndReportsItsArchive() throws {
        try withOperations { ops, db in
            let essays = try ops.createTag(name: "essays")
            let archived = try ops.createReading(
                name: "put away", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(essays.id)))
            try ops.archiveReading(archived.id)
            let post = try ops.createPost(title: "a piece")

            let result = try ops.collectPostIntoSmartReading(post.id, into: archived.id)
            #expect(result.appliedTagPaths == ["essays"])
            #expect(result.alreadyMatched == false)
            #expect(result.gatheringArchived, "the act knows its target is archived")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                [post.id, essays.id]) == 1, "the tag is applied all the same")
            #expect(try assembledPostIDs(db, archived.id).isEmpty,
                    "an archived gathering shows nothing — 'shows it now' would be false")

            let again = try ops.collectPostIntoSmartReading(post.id, into: archived.id)
            #expect(again.alreadyMatched && again.gatheringArchived)

            let open = try ops.createReading(
                name: "open", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(essays.id)))
            let other = try ops.createPost(title: "another")
            let live = try ops.collectPostIntoSmartReading(other.id, into: open.id)
            #expect(!live.gatheringArchived)
            #expect(try assembledPostIDs(db, open.id).contains(other.id))
        }
    }

    @Test func appliesEveryMissingTagsAllPath() throws {
        try withOperations { ops, db in
            let tagA = try ops.createTag(name: "book")
            _ = try ops.createTag(name: "sailing")
            let reading = try smartReading(
                ops, spec: .init(tagsAll: ["book", "sailing"]))
            let post = try ops.createPost(title: "chapter scrap")
            _ = try ops.applyTag(tagA.id, toPost: post.id)

            let result = try ops.collectPostIntoSmartReading(post.id, into: reading.id)
            #expect(result.appliedTagPaths == ["sailing"],
                    "only the MISSING conjunct is applied")
            #expect(try assembledPostIDs(db, reading.id) == [post.id])
        }
    }

    @Test func alreadyMatchingPostIsAReportedNoOp() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "dreams")
            let reading = try smartReading(ops, spec: .init(tags: ["dreams"]))
            let post = try ops.createPost(title: "the lighthouse again")
            _ = try ops.applyTag(tag.id, toPost: post.id)

            let before = try db.fetchInt("SELECT COUNT(*) FROM post_tag") ?? -1
            let result = try ops.collectPostIntoSmartReading(post.id, into: reading.id)
            #expect(result.alreadyMatched)
            #expect(result.appliedTagPaths.isEmpty)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM post_tag") == before,
                    "no rows written — already collected")
        }
    }

    @Test func unsatisfiableDateBoundRefusesBeforeAnyTagging() throws {
        try withOperations { ops, db in
            _ = try ops.createTag(name: "june")
            let reading = try smartReading(
                ops, spec: .init(tags: ["june"], entryDateTo: "2026-06-01"))
            let post = try ops.createPost(title: "too late")
            try ops.setEntryDate(post.id, entryDate: "2026-07-19")

            let before = try db.fetchInt("SELECT COUNT(*) FROM post_tag") ?? -1
            #expect {
                try ops.collectPostIntoSmartReading(post.id, into: reading.id)
            } throws: { error in
                guard case .smartFilterUnsatisfiable(_, let reason) =
                    (error as? OperationError) else { return false }
                return reason.contains("2026-06-01")
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM post_tag") == before,
                    "a refusal applies NOTHING — the date bound is checked first")

            // A post with NO entry date refuses too, naming the fix.
            let undated = try ops.createPost(title: "undated")
            #expect {
                try ops.collectPostIntoSmartReading(undated.id, into: reading.id)
            } throws: { error in
                guard case .smartFilterUnsatisfiable(_, let reason) =
                    (error as? OperationError) else { return false }
                return reason.contains("no entry date")
            }
        }
    }

    @Test func missingFilterTagRefusesByName() throws {
        try withOperations { ops, _ in
            // 13i-a: rules reference tag IDs (§19), so "the missing tag"
            // is one that EXISTED when the rule was written and was
            // deleted since — the tombstone still knows the path the
            // refusal names. (A path that never existed converts to the
            // dead term and refuses with the generic sentence instead.)
            let ghost = try ops.createTag(name: "ghost")
            let ghostTag = try ops.createTag(parent: ghost.id, name: "tag")
            let reading = try smartReading(ops, spec: .init(tags: ["ghost/tag"]))
            try ops.deleteTag(ghostTag.id)
            try ops.deleteTag(ghost.id)
            let post = try ops.createPost(title: "orphan")
            #expect {
                try ops.collectPostIntoSmartReading(post.id, into: reading.id)
            } throws: { error in
                guard case .smartFilterUnsatisfiable(_, let reason) =
                    (error as? OperationError) else { return false }
                return reason.contains("ghost/tag")
            }
        }
    }

    @Test func wrongKindAndLockedReadingRefuse() throws {
        try withOperations { ops, db in
            let curated = try ops.createReading(name: "hand-picked", kind: .book)
            let post = try ops.createPost(title: "p")
            #expect(throws: OperationError.wrongReadingKind(id: curated.id, expected: .gathering)) {
                try ops.collectPostIntoSmartReading(post.id, into: curated.id)
            }
            let smart = try smartReading(ops, spec: .init(tags: ["x"]))
            // 13i-d U4 ACT 0 (F-U3-1): `lockReading` refuses a gathering now,
            // so the LEGACY finished gathering this refusal guards against is
            // staged as the raw row it is (a pre-13i-d store, or another
            // device's synced row) — the fixture, not the assertion, moved.
            try db.write { db in
                try db.execute(sql: "UPDATE reading SET locked = 1 WHERE id = ?", arguments: [smart.id])
            }
            #expect(throws: OperationError.lockedReading(id: smart.id)) {
                try ops.collectPostIntoSmartReading(post.id, into: smart.id)
            }
        }
    }
}

@Suite("Outline mint — R99 (first sentence per block)")
struct OutlineMintTests {
    @Test func mintsFirstSentenceBlocksWithLineageAndAnchor() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "weeks like water")
            let b1 = try ops.newBlock(
                in: post.id,
                text: "Progress is invisible from inside it. The days repeated with variations.")
            let b2 = try ops.newBlock(
                in: post.id, text: "We measured the crossing in habits formed and abandoned.")

            let result = try ops.mintOutlinePost(of: post.id)
            #expect(result.post.title == "outline of weeks like water")
            #expect(result.blockCopies.map(\.source) == [b1.block.id, b2.block.id])

            let texts = try db.read { db in
                try Queries.renderPost(db, containerID: result.post.id).map { $0.text ?? "" }
            }
            #expect(texts == [
                "Progress is invisible from inside it.",
                "We measured the crossing in habits formed and abandoned.",
            ])

            // Honest lineage: each outline block DESCENDS from its source.
            for pair in result.blockCopies {
                let edge = try db.fetchInt(
                    """
                    SELECT COUNT(*) FROM edge WHERE type = 'derived_from'
                    AND source_block_id = ? AND target_block_id = ? AND deleted_at IS NULL
                    """,
                    [pair.copy, pair.source])
                #expect(edge == 1)
            }
            // The post-level pairing anchor (the copy family's letter).
            #expect(try db.read { db in
                try Queries.versionPeerPosts(db, of: post.id)
            } == [result.post.id])
        }
    }

    @Test func emptySourceBlockSeedsEmptyNeverInventsProse() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "gaps")
            _ = try ops.newBlock(in: post.id, text: "Real text here.")
            let blank = try ops.newBlock(in: post.id, text: "spacer")
            _ = try ops.autosave(blank.variant.id, text: "", charDelta: 6)

            let result = try ops.mintOutlinePost(of: post.id)
            let texts = try db.read { db in
                try Queries.renderPost(db, containerID: result.post.id).map { $0.text ?? "" }
            }
            #expect(texts == ["Real text here.", ""],
                    "an emptied take keeps the block's line (R103) — never \"(empty block)\"")
        }
    }

    @Test func blocklessSourceRefuses() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost(title: "nothing yet")
            #expect(throws: OperationError.postHasNoBlocks(id: post.id)) {
                try ops.mintOutlinePost(of: post.id)
            }
        }
    }
}
