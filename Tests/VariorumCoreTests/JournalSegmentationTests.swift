import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-799 (the VX-805 run, Unit A) — a journal entry segments like any
/// other note.** Her ask (2026-11-04): *"can you file something to stop making
/// the journal default to being one block?"*, and her sitting ruling the same
/// day: clear the stored override on EXISTING journal entries too (*"i don't
/// think it matters that much"*) — with no retroactive re-segmentation.
///
/// THE MECHANISM (traced, pre-fix): every journal-profile mint ran through
/// `Operations.insertPost`, which stamped `segmentation_default = 'one_block'`
/// whenever `profile == .journal` (`Operations+Container.swift`, the "journal
/// post defaults to one-block-per-entry" branch). `containerHeader`'s
/// `effectiveSegmentation` reads the per-post override first, so every
/// journal entry — ⌘J's, the phone's, an imported journal file's — typed as
/// one block regardless of the global `default_segmentation` setting.
@Suite("VX-799 — journal entries stop seeding one_block")
struct JournalSegmentationTests {
    /// RED ON OLD: the journal mint stamped `.oneBlock`; a journal entry now
    /// carries NO override and inherits the global default exactly as a blog
    /// post does — both mint roads (`createPost` and the notebook rule's
    /// `createOrOpenJournalEntry`).
    @Test func aJournalMintCarriesNoSegmentationOverride() throws {
        try withOperations { ops, db in
            let journal = try ops.createPost(profile: .journal, entryDate: "2026-07-01")
            #expect(journal.segmentationDefault == nil)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            #expect(entry.segmentationDefault == nil)
            let blog = try ops.createPost(profile: .blog)

            for id in [journal.id, entry.id] {
                let stored = try db.fetchString(
                    "SELECT segmentation_default FROM container WHERE id = ?", [id])
                #expect(stored == nil, "the row stores no override")
                let header = try db.read { try Queries.containerHeader($0, containerID: id) }
                let blogHeader = try db.read { try Queries.containerHeader($0, containerID: blog.id) }
                #expect(header?.effectiveSegmentation == .paragraph)
                #expect(header?.effectiveSegmentation == blogHeader?.effectiveSegmentation,
                        "a journal entry segments like any other note")
            }
        }
    }

    /// The clearing pass's EXACT state transition: only LIVE journal-profile
    /// posts carrying `'one_block'` change — override → NULL, `updated_at`
    /// stamped, the outbox capturing each — and every other row is
    /// byte-unchanged (every column, `updated_at` included): other profiles'
    /// one_block, a journal entry's other overrides and NULL, a pool's
    /// override, and a TOMBSTONED journal entry's. Archived and sealed live
    /// entries ARE cleared (live rows; the chip's own setter is legal under a
    /// seal). Blocks are never touched. A second run is a no-op.
    @Test func theClearingPassTouchesExactlyLiveJournalOneBlockRows() throws {
        try withOperations { ops, db in
            func journal(_ day: String, _ segmentation: Segmentation?) throws -> Container {
                let post = try ops.createPost(profile: .journal, entryDate: day)
                try ops.setSegmentationDefault(post.id, segmentation: segmentation)
                return post
            }
            // The class (pre-VX-799 mints carried this exact shape).
            let plain = try journal("2026-07-01", .oneBlock)
            _ = try ops.seedBlock(in: plain.id, text: "Dear diary.\n\nA second paragraph.")
            let archived = try journal("2026-07-02", .oneBlock)
            try ops.archiveContainer(archived.id)
            let sealed = try journal("2026-07-03", .oneBlock)
            _ = try ops.seedBlock(in: sealed.id, text: "kept")
            try ops.lockPost(sealed.id)
            // Untouched.
            let dead = try journal("2026-07-04", .oneBlock)
            try ops.deleteContainer(dead.id)
            let journalNil = try journal("2026-07-05", nil)
            let journalSentence = try journal("2026-07-06", .sentence)
            let journalParagraph = try journal("2026-07-07", .paragraph)
            let blog = try ops.createPost(profile: .blog)
            try ops.setSegmentationDefault(blog.id, segmentation: .oneBlock)
            let generic = try ops.createPost(profile: .generic)
            try ops.setSegmentationDefault(generic.id, segmentation: .oneBlock)
            let untitledProfile = try ops.createPost()
            try ops.setSegmentationDefault(untitledProfile.id, segmentation: .oneBlock)
            let pool = try ops.createPool(title: "Scraps")
            try ops.setSegmentationDefault(pool.id, segmentation: .oneBlock)

            let cleared = [plain.id, archived.id, sealed.id]
            let untouched = [dead.id, journalNil.id, journalSentence.id, journalParagraph.id,
                             blog.id, generic.id, untitledProfile.id, pool.id]
            var before: [String: [String: DatabaseValue]] = [:]
            for id in cleared + untouched {
                before[id] = try db.snapshotRow("container", id, excluding: [])
            }
            let blocksBefore = try db.read { try Row.fetchAll($0, sql: "SELECT * FROM block ORDER BY id") }
            let variantsBefore = try db.read { try Row.fetchAll($0, sql: "SELECT * FROM variant ORDER BY id") }
            try db.clearOutbox()

            #expect(try ops.clearJournalOneBlockOverrides() == 3)

            for id in cleared {
                let after = try #require(try db.snapshotRow("container", id, excluding: []))
                var expected = try #require(before[id])
                expected["segmentation_default"] = .null
                expected["updated_at"] = after["updated_at"]
                #expect(after == expected, "only the override and the stamp move")
                #expect(after["updated_at"] != before[id]?["updated_at"], "updated_at is stamped")
                #expect(try db.outboxContains("container", id))
                let header = try db.read { try Queries.containerHeader($0, containerID: id) }
                if header != nil { #expect(header?.effectiveSegmentation == .paragraph) }
            }
            for id in untouched {
                #expect(try db.snapshotRow("container", id, excluding: []) == before[id],
                        "byte-unchanged, updated_at included")
                #expect(try !db.outboxContains("container", id))
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 3,
                    "exactly the three cleared rows reach the outbox")
            // No retroactive re-segmentation: blocks and takes are untouched.
            #expect(try db.read { try Row.fetchAll($0, sql: "SELECT * FROM block ORDER BY id") } == blocksBefore)
            #expect(try db.read { try Row.fetchAll($0, sql: "SELECT * FROM variant ORDER BY id") } == variantsBefore)
            // No touch, no churn on the cleared rows.
            for id in cleared {
                #expect(before[id]?["last_touched_at"]
                        == (try db.snapshotRow("container", id, excluding: []))?["last_touched_at"])
                #expect(before[id]?["churn_accumulator"]
                        == (try db.snapshotRow("container", id, excluding: []))?["churn_accumulator"])
            }

            // Idempotent: a second run finds nothing and writes nothing.
            let settled = try db.read { try Row.fetchAll($0, sql: "SELECT * FROM container ORDER BY id") }
            try db.clearOutbox()
            #expect(try ops.clearJournalOneBlockOverrides() == 0)
            #expect(try db.read { try Row.fetchAll($0, sql: "SELECT * FROM container ORDER BY id") } == settled)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }
}
