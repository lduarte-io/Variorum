import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 9c, Step 4 — `owner_id` population through Operations (S4
/// collected on) + the `adoptOwnerID` backfill (brief interpretation 3).
/// Inherently red-on-old: no pre-9c code stamped or adopted anything.
@Suite("Owner identity stamping + backfill (Phase 9c, Step 4)")
struct OwnerIdentityTests {
    private static let author = "9c0ffee0-aaaa-4bbb-8ccc-000000000001"

    /// The deterministic ops world with a signed-in owner bound.
    private func withSignedInOperations<T>(
        owner: String? = author,
        _ body: (Operations, AppDatabase) throws -> T
    ) throws -> T {
        try withOperations { ops, db in
            try withDependencies {
                $0.ownerIdentity = OwnerIdentity { owner }
            } operation: {
                try body(Operations(), db)
            }
        }
    }

    // MARK: Stamping at every top-level mint

    @Test func everyTopLevelMintStampsTheSignedInOwner() throws {
        try withSignedInOperations { ops, db in
            // Containers: post (both doors) + pool.
            let post = try ops.createPost(title: "p", profile: .blog)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-10").container
            let pool = try ops.createPool(title: "scraps")
            // Blocks: newBlock, a structural mint (divide's successor), a
            // merge mint (the fan-block path), and a pool-drag copy.
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.", at: .end)
            let divide = try ops.divide(a.block.id, cut: 16)
            let merged = try ops.merge(a.block.id, divide.block.id)
            let poolBlock = try ops.newBlock(in: pool.id, text: "loose idea", at: .end)
            let copy = try ops.poolDragCopy(poolBlock.block.id, to: post.id, at: .end)
            // Reading, tag, reference.
            let reading = try ops.createReading(name: "book", kind: .curated)
            let tag = try ops.createTag(parent: nil, name: "life")
            let reference = try ops.addReference(to: post.id, kind: .url, url: "https://x.example")

            let stamped: [(String, String)] = [
                ("container", post.id), ("container", entry.id), ("container", pool.id),
                ("block", a.block.id), ("block", divide.block.id),
                ("block", merged.block.id), ("block", copy.block.id),
                ("reading", reading.id), ("tag", tag.id), ("reference", reference.id),
            ]
            for (table, id) in stamped {
                #expect(try db.fetchString(
                    "SELECT owner_id FROM \(table) WHERE id = ?", [id]) == Self.author,
                    "\(table) \(id) must carry the signed-in owner")
            }
        }
    }

    @Test func mintingWhileSignedOutLeavesRowsUnowned() throws {
        // The default identity is signed out — the legitimate pre-sign-in
        // state: rows are born unowned; the next adoption pass claims them.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "offline", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "typed signed out", at: .end)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container WHERE owner_id IS NOT NULL") == 0)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM block WHERE owner_id IS NOT NULL") == 0)
        }
    }

    // MARK: The backfill

    /// A corpus minted signed-out, with tombstoned rows in every
    /// owner-carrying table — adoption must reach ALL of it (tombstones
    /// still sync; a NULL-owner tombstone would be refused by the mirror's
    /// push guard after the flip).
    @Test func adoptOwnerIDStampsEveryNullRowIncludingTombstones() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "kept", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "kept block", at: .end)
            let doomedBlock = try ops.newBlock(in: post.id, text: "doomed", at: .end)
            try ops.deleteBlock(doomedBlock.block.id)
            let doomedPost = try ops.createPost(title: "doomed post")
            try ops.deleteContainer(doomedPost.id)
            let reading = try ops.createReading(name: "kept reading", kind: .curated)
            _ = reading
            let doomedTag = try ops.createTag(parent: nil, name: "doomed")
            try ops.deleteTag(doomedTag.id)
            let reference = try ops.addReference(to: post.id, kind: .url, url: "https://x.example")
            try ops.removeReference(reference.id)

            let report = try withDependencies {
                $0.ownerIdentity = OwnerIdentity { Self.author }
            } operation: {
                try Operations().adoptOwnerID()
            }
            #expect(report.total > 0)

            for table in ["container", "block", "reading", "tag", "reference"] {
                let unowned = try db.fetchInt(
                    "SELECT COUNT(*) FROM \(table) WHERE owner_id IS NULL") ?? -1
                #expect(unowned == 0, "\(table) still has \(unowned) unowned rows after adoption")
                let owned = try db.fetchInt(
                    "SELECT COUNT(*) FROM \(table) WHERE owner_id = ?", [Self.author]) ?? 0
                #expect(owned == report.adoptedByTable[table],
                        "\(table)'s adoption count must match the report")
                // Tombstoned rows adopted too.
                if let tombstoned = try db.fetchInt(
                    "SELECT COUNT(*) FROM \(table) WHERE deleted_at IS NOT NULL"), tombstoned > 0 {
                    #expect(try db.fetchInt("""
                        SELECT COUNT(*) FROM \(table)
                        WHERE deleted_at IS NOT NULL AND owner_id IS NULL
                        """) == 0, "\(table) tombstones must adopt")
                }
            }
            // Idempotent: a second pass adopts nothing.
            let second = try withDependencies {
                $0.ownerIdentity = OwnerIdentity { Self.author }
            } operation: {
                try Operations().adoptOwnerID()
            }
            #expect(second.total == 0)
        }
    }

    @Test func adoptionReachesTheOutboxAndDisturbsNothingElse() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "corpus", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "text", at: .end)
            // Simulate synced-and-quiet: versions bumped, outbox drained.
            try db.write { d in
                try d.execute(sql: "UPDATE container SET sync_version = 7")
                try d.execute(sql: "UPDATE block SET sync_version = 3")
            }
            try db.clearOutbox()
            let updatedAtBefore = try db.fetchString(
                "SELECT updated_at FROM container WHERE id = ?", [post.id])

            let report = try withDependencies {
                $0.ownerIdentity = OwnerIdentity { Self.author }
            } operation: {
                try Operations().adoptOwnerID()
            }
            #expect(report.adoptedByTable["container"] == 1)
            #expect(report.adoptedByTable["block"] == 1)

            // The adoption PUSHES: every adopted row re-enters the outbox
            // (ordinary UPDATEs — the triggers fire; never apply-mode).
            #expect(try db.outboxContains("container", post.id))
            #expect(try db.outboxContains("block", minted.block.id))
            // And nothing else moved: sync_version is the server's token;
            // updated_at is an EDIT stamp and adoption is not an edit.
            #expect(try db.fetchInt(
                "SELECT sync_version FROM container WHERE id = ?", [post.id]) == 7)
            #expect(try db.fetchInt(
                "SELECT sync_version FROM block WHERE id = ?", [minted.block.id]) == 3)
            #expect(try db.fetchString(
                "SELECT updated_at FROM container WHERE id = ?", [post.id]) == updatedAtBefore)
        }
    }

    @Test func adoptionNeverReassignsAnOwnedRow() throws {
        try withSignedInOperations(owner: "someone-else") { ops, db in
            let owned = try ops.createPost(title: "theirs")
            let report = try withDependencies {
                $0.ownerIdentity = OwnerIdentity { Self.author }
            } operation: {
                try Operations().adoptOwnerID()
            }
            #expect(report.adoptedByTable["container"] ?? 0 == 0)
            #expect(try db.fetchString(
                "SELECT owner_id FROM container WHERE id = ?", [owned.id]) == "someone-else")
        }
    }

    @Test func adoptionRefusesWhileSignedOut() throws {
        try withOperations { ops, _ in
            #expect(throws: OperationError.noOwnerIdentity) {
                _ = try ops.adoptOwnerID()
            }
        }
    }

    // MARK: The backfill choreography converges (brief interpretation 3;
    // REWRITTEN at Phase 14c batch 1 to the born-multi-tenant reality)

    /// The adoption choreography, end to end on the sync harness — the
    /// POST-14c shape: rows authored signed OUT are unowned locally (that
    /// state still exists), but an unowned corpus never reaches the
    /// mirror anymore — the born-multi-tenant server refuses unowned
    /// pushes on the owner-carrying tables, and a signed-out device
    /// cannot compose a round at all (the transport requires a session).
    /// So adoption PRECEDES first sync: each device signs in, adopts its
    /// own unowned rows, and only then converges — the backfill rides the
    /// ordinary outbox exactly as before, and both stores converge
    /// byte-identical, fully owned. (The original pre-9c shape — an
    /// unowned corpus converging THROUGH the mirror, adoption
    /// propagating after — is retired with the 9c-era mirror it modeled;
    /// this file's history holds it.)
    @Test func backfillPushesAndConvergesAcrossDevices() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        // Authored signed OUT on both devices: locally unowned.
        mac.ownerID = nil
        phone.ownerID = nil
        try mac.with { ops, _ in
            let post = try ops.createPost(title: "mac post", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Desk thoughts.", at: .end)
            _ = try ops.createTag(parent: nil, name: "life")
        }
        try phone.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-09").container
            _ = try ops.newBlock(in: entry.id, text: "Phone thoughts.", at: .end)
        }
        #expect(try mac.db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE owner_id IS NOT NULL") == 0)

        // Both sign in as the account and adopt their OWN unowned rows
        // BEFORE any round; the adoption rides the ordinary outbox.
        mac.ownerID = FakeSyncServer.defaultUserID
        phone.ownerID = FakeSyncServer.defaultUserID
        let macReport = try mac.with { ops, _ in try ops.adoptOwnerID() }
        let phoneReport = try phone.with { ops, _ in try ops.adoptOwnerID() }
        #expect(macReport.total > 0)
        #expect(phoneReport.total > 0)
        _ = try await syncToQuiescence(mac, phone, server: server)

        #expect(try mac.syncedDump() == phone.syncedDump(),
                "the adopted corpus must converge byte-identical")
        for db in [mac.db, phone.db] {
            for table in ["container", "block", "reading", "tag", "reference"] {
                #expect(try db.fetchInt(
                    "SELECT COUNT(*) FROM \(table) WHERE owner_id IS NULL") == 0,
                    "\(table) must be fully owned on both devices after the backfill converges")
            }
        }
        #expect(try mac.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)
    }
}
