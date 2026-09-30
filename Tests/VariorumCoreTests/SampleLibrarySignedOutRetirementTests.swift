import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// 18o U6 (QUESTIONS #146, PROVISIONAL — hers to overturn): the
// SIGNED-OUT-FIRST retirement. A device that seeded its own sample book
// while signed out meets, at its first pull after sign-in, an account that
// already holds that book DELETED. The ruling: the account's deletion wins
// over an UNTOUCHED local copy, and never over a touched one — the retired
// copy goes to this device's Trash (Put back real), an EDITED copy survives
// and syncs. The later-intent guard is SyncSpec §3's own seq rule: retire
// only when the arriving tombstone's `server_seq` outranks the live copy's
// reading row (a never-accepted local row ranks 0 — which IS the
// signed-out-first device), so a copy deliberately RESTORED after the
// deletion is never taken, on any device.

@Suite("Sample library — the signed-out-first retirement (18o U6, #146)")
struct SampleLibrarySignedOutRetirementTests {
    static let bookName = "the adventures of sherlock holmes"
    static let tagPath = "sherlock holmes"
    static let notes: [(title: String, text: String)] = [
        ("About this book", "Attribution text."),
        ("A Scandal in Bohemia", "To Sherlock Holmes she is always THE woman.\n\nSecond paragraph."),
    ]

    static func facts() -> SampleLibraryDedupeFacts {
        let hashes = Dictionary(
            uniqueKeysWithValues: notes.map { ($0.title, BridgeHash.body($0.text)) })
        return SampleLibraryDedupeFacts(
            bookName: bookName, tagPath: tagPath,
            loadNoteHashes: { hashes }, hash: BridgeHash.body(_:))
    }

    /// Mirrors `SampleLibrarySeeder.seed`'s shape exactly as the dedupe
    /// suite does (curated book, one chapter per note, membership +
    /// assignment + the reserved tag per note).
    @discardableResult
    private func seedCopy(
        _ client: SyncClient
    ) throws -> (bookID: String, postIDs: [String: String]) {
        try client.with { ops, db in
            let book = try ops.createReading(
                name: Self.bookName, kind: .curated, profile: "book")
            // The real seeder DISCOVERS a live reserved tag before minting
            // (a Help ▸ Restore reuses it) — mirror that, or a re-seed
            // trips `duplicateTagPath` the product never meets.
            let existingTagID = try db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
                    arguments: [Self.tagPath])
            }
            let tagID = try existingTagID ?? ops.createTag(name: Self.tagPath).id
            var postIDs: [String: String] = [:]
            for note in Self.notes {
                let section = try ops.createSection(in: book.id, name: note.title)
                let minted = try ops.importPost(
                    title: note.title, text: note.text, undoLabel: "Sample Library")
                _ = try ops.addPostToReading(minted.container.id, to: book.id)
                try ops.assignPostToSection(
                    minted.container.id, in: book.id, section: section.id)
                _ = try ops.applyTag(tagID, toPost: minted.container.id)
                postIDs[note.title] = minted.container.id
            }
            return (book.id, postIDs)
        }
    }

    private func liveCopyIDs(_ client: SyncClient) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
                arguments: [Self.bookName])
        }
    }

    private func firstVariantID(_ client: SyncClient, postID: String) throws -> String {
        try client.db.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT v.id FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                      AND v.deleted_at IS NULL
                    ORDER BY cb.position, v.id LIMIT 1
                    """,
                arguments: [postID])!
        }
    }

    /// THE SCENARIO PIN (red-on-old): the Mac deletes its copy; the phone
    /// — signed out first — seeded its own; at the phone's FIRST pull the
    /// arriving tombstone retires the untouched local copy family-complete
    /// into the Trash, every write enqueued (SyncSpec §7), and the Mac
    /// never sees the book come back. On the pre-fix tree the local copy
    /// survives and syncs up — Sherlock reappears on BOTH devices, which
    /// is #146's reported defect.
    @Test func theAccountsDeletionRetiresAnUntouchedSignedOutCopyAtFirstSync() async throws {
        let (a, b, server) = try furniturePair()
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()

        // The Mac's life before the phone exists: seed, sync, delete, sync.
        let copyA = try seedCopy(a)
        try await a.push()
        try a.with { ops, _ in try ops.deleteReading(copyA.bookID) }
        try await a.push()

        // The phone's signed-out life: its own local seed, never synced.
        let copyB = try seedCopy(b)
        #expect(try liveCopyIDs(b) == [copyB.bookID])

        // Sign-in: the first round is pull-first (the engine's own order).
        _ = try await b.pull()

        // The arriving tombstone (accepted seq) outranks the never-accepted
        // local copy (seq 0): the untouched copy retires, family-complete.
        #expect(try liveCopyIDs(b).isEmpty,
                "the account's deletion wins over an untouched local copy")
        #expect(try b.db.deletedAt("reading", copyB.bookID) != nil)
        #expect(try b.outboxContains("reading", copyB.bookID),
                "a repair write must reach the outbox (SyncSpec §7)")
        for (_, postID) in copyB.postIDs {
            #expect(try b.db.deletedAt("container", postID) != nil,
                    "the retirement is family-complete (the Trash's Put back road)")
            #expect(try b.outboxContains("container", postID))
        }

        // Convergence: the Mac never sees a live copy again.
        try await b.push()
        try await a.pull()
        #expect(try liveCopyIDs(a).isEmpty, "Sherlock does not reappear on the Mac")
        try await assertFurnitureConverged(a, b, server)

        // Idempotence: further rounds change nothing.
        let settled = try b.syncedDump()
        try await syncToQuiescence(a, b, server: server)
        #expect(try b.syncedDump() == settled)
    }

    /// THE RULING'S OTHER HALF (a guard; M-always is its teeth): an EDITED
    /// local copy is NEVER retired — her words outrank a sample book. It
    /// survives, syncs up, and both devices hold it (the accepted outcome).
    @Test func anEditedSignedOutCopyIsNeverRetired() async throws {
        let (a, b, server) = try furniturePair()
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()

        let copyA = try seedCopy(a)
        try await a.push()
        try a.with { ops, _ in try ops.deleteReading(copyA.bookID) }
        try await a.push()

        let copyB = try seedCopy(b)
        let editedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let variant = try firstVariantID(b, postID: editedPost)
        try b.with { ops, _ in
            try ops.autosave(variant, text: "Rewritten in her own words.", charDelta: 20)
        }

        _ = try await b.pull()
        #expect(try liveCopyIDs(b) == [copyB.bookID],
                "an edited copy is never silently retired")

        try await syncToQuiescence(a, b, server: server)
        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the edited copy stands on both devices — the accepted outcome")
        }
    }

    /// THE LATER-INTENT GUARD (M-noSeqGuard is its teeth): a copy the
    /// author deliberately RESTORED after the deletion carries rows the
    /// server accepted AFTER the tombstone, so a third device pulling the
    /// whole history keeps the restored copy — the old tombstone can never
    /// take it.
    @Test func aCopyRestoredAfterTheDeletionIsNeverTakenByTheOldTombstone() async throws {
        let (a, b, server) = try furniturePair()
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()

        // One device's history: seed → sync → delete → sync → RESTORE
        // (Help ▸ Restore mints a fresh family) → sync.
        let first = try seedCopy(a)
        try await a.push()
        try a.with { ops, _ in try ops.deleteReading(first.bookID) }
        try await a.push()
        let restored = try seedCopy(a)
        try await a.push()

        // The third device pulls everything from scratch: the dead first
        // copy arrives BELOW the restored one in seq order and must not
        // retire it.
        try await syncToQuiescence(a, b, server: server)
        #expect(try liveCopyIDs(b) == [restored.bookID],
                "a deliberate restore outranks the old tombstone (seq later-intent)")
        #expect(try liveCopyIDs(a) == [restored.bookID])
    }

    /// PUT BACK IS REAL (the ruling's own promise): the retired copy rows
    /// in this device's Trash; `restoreReading` revives the book with its
    /// exact-stamp chapters and memberships, a member note's own Put back
    /// revives it (the #85(e) recorded shape), and the revival pushes.
    @Test func putBackReturnsTheRetiredCopy() async throws {
        let (a, b, server) = try furniturePair()
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()

        let copyA = try seedCopy(a)
        try await a.push()
        try a.with { ops, _ in try ops.deleteReading(copyA.bookID) }
        try await a.push()

        let copyB = try seedCopy(b)
        _ = try await b.pull()
        #expect(try liveCopyIDs(b).isEmpty, "precondition: the retirement landed")

        try b.with { ops, _ in try ops.restoreReading(copyB.bookID) }
        #expect(try liveCopyIDs(b) == [copyB.bookID], "Put back returns the book")
        let member = copyB.postIDs["About this book"]!
        try b.with { ops, _ in try ops.restoreContainer(member) }
        #expect(try b.db.deletedAt("container", member) == nil,
                "a member note's own Put back revives it (#85(e)'s shape)")

        // Her deliberate restore propagates — and nothing re-retires it
        // (no new tombstone ever arrives).
        try await syncToQuiescence(a, b, server: server)
        #expect(try liveCopyIDs(a) == [copyB.bookID])
        #expect(try liveCopyIDs(b) == [copyB.bookID])
    }
}
