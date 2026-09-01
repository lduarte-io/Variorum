import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Pre-13u Act 0, the Fable `Sync/` half (R-pre13u-8): the sample-library
// pristine-copy dedupe. Shares the furniture-repair plumbing in
// FurnitureConvergenceRepairTests.swift (same birth defect, same trio of
// SyncSpec §7 assertions).

// MARK: - The sample-library pristine-copy dedupe (R-pre13u-8)

/// Two seeded sample libraries meeting: identified by the seeder's own
/// discover predicate (the reserved book name, injected), classified per
/// NOTE against the bundled manifest's hashes. Both pristine → deterministic
/// keeper (smaller id); exactly one edited → the EDITED copy is kept; both
/// edited → both survive. An edited copy is NEVER silently retired.
@Suite("Sample-library pristine-copy dedupe (pre-13u Act 0, R-pre13u-8)")
struct SampleLibraryDedupeRepairTests {
    static let bookName = "the adventures of sherlock holmes"
    static let tagPath = "sherlock holmes"
    /// A tiny stand-in library: the manifest's per-note rule is what is
    /// under test, not half a megabyte of Doyle. One multi-paragraph note
    /// exercises the importPost → renderedText round-trip the real
    /// manifest's hashes ride on.
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

    private func pairWithFacts() throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let (a, b, server) = try furniturePair()
        a.sampleLibraryFacts = Self.facts()
        b.sampleLibraryFacts = Self.facts()
        return (a, b, server)
    }

    /// Seeds one copy, mirroring `SampleLibrarySeeder.seed`'s exact shape:
    /// curated book (profile "book"), one section per note, membership +
    /// section assignment + the reserved tag per note.
    @discardableResult
    private func seedCopy(
        _ client: SyncClient
    ) throws -> (bookID: String, postIDs: [String: String]) {
        try client.with { ops, _ in
            let book = try ops.createReading(
                name: Self.bookName, kind: .curated, profile: "book")
            let tag = try ops.createTag(name: Self.tagPath)
            var postIDs: [String: String] = [:]
            for note in Self.notes {
                let section = try ops.createSection(in: book.id, name: note.title)
                let minted = try ops.importPost(
                    title: note.title, text: note.text, undoLabel: "Sample Library")
                _ = try ops.addPostToReading(minted.container.id, to: book.id)
                try ops.assignPostToSection(
                    minted.container.id, in: book.id, section: section.id)
                _ = try ops.applyTag(tag.id, toPost: minted.container.id)
                postIDs[note.title] = minted.container.id
            }
            return (book.id, postIDs)
        }
    }

    private func renderedText(_ client: SyncClient, postID: String) throws -> String {
        try client.db.read { db in try Queries.renderedText(db, containerID: postID) }
    }

    private func liveCopyIDs(_ client: SyncClient) throws -> [String] {
        try client.db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM reading WHERE name = ? AND deleted_at IS NULL ORDER BY id",
                arguments: [Self.bookName])
        }
    }

    private func firstVariantID(
        _ client: SyncClient, postID: String
    ) throws -> String {
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

    @Test func twoPristineCopiesConvergeToTheSmallerIDKeeper() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)

        try await a.push()
        try await b.push()
        try await b.pull()

        // On B: both copies are byte-identical to the manifest, so the
        // smaller id (A's) keeps and B's whole FAMILY retires — the book,
        // its memberships, and its posts — each write enqueued.
        #expect(try liveCopyIDs(b) == [copyA.bookID])
        #expect(try b.db.deletedAt("reading", copyB.bookID) != nil)
        #expect(try b.outboxContains("reading", copyB.bookID))
        for (_, postID) in copyB.postIDs {
            #expect(try b.db.deletedAt("container", postID) != nil,
                    "the loser's posts retire with the book (nothing lost — byte-identical)")
            #expect(try b.outboxContains("container", postID))
        }

        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID])
            // The retirement leaves no live bookless posts behind: the
            // loser's notes went with their book, not into the Pool.
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL
                  AND NOT EXISTS (SELECT 1 FROM reading_post rp
                                  WHERE rp.post_id = c.id AND rp.deleted_at IS NULL)
                """) == 0)
        }

        // Idempotence: further rounds change nothing.
        let settled = try a.syncedDump()
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == settled)
    }

    @Test func anEditedCopySurvivesAndThePristineOneRetiresWhateverTheIDs() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)

        // B (the LARGER ids) rewrites one story — the edited copy must be
        // the keeper even though smaller-id would pick A.
        let editedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let variant = try firstVariantID(b, postID: editedPost)
        try b.with { ops, _ in
            try ops.autosave(variant, text: "Rewritten in her own words.", charDelta: 20)
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the EDITED copy is kept; the pristine one is retired")
            #expect(try client.db.deletedAt("reading", copyA.bookID) != nil)
            #expect(try renderedText(client, postID: editedPost)
                .contains("Rewritten in her own words."))
        }
    }

    @Test func twoEditedCopiesBothSurvive() async throws {
        // The documented outcome (the §7 concurrent-divide class): an edited
        // copy is NEVER silently retired, so two edited copies coexist and
        // the shown-once display absorbs the shared name.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        for (client, copy) in [(a, copyA), (b, copyB)] {
            let post = copy.postIDs["About this book"]!
            let variant = try firstVariantID(client, postID: post)
            try client.with { ops, _ in
                try ops.autosave(variant, text: "My own attribution note.", charDelta: 5)
            }
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID, copyB.bookID].sorted(),
                    "both edited copies survive")
        }
    }

    @Test func anUnrenderedTakeCountsAsEngagementAndProtectsTheCopy() async throws {
        // A fanned take does not change rendered text, so the hash rule
        // alone would read the copy as pristine and silently retire her
        // take. Engagement counts as editing: the copy survives.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let fannedPost = copyB.postIDs["A Scandal in Bohemia"]!
        try b.with { ops, db in
            let (blockID, variantID) = try db.read { db in
                try Row.fetchOne(
                    db,
                    sql: """
                        SELECT v.block_id AS b, v.id AS v FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        ORDER BY cb.position, v.id LIMIT 1
                        """,
                    arguments: [fannedPost]).map { ($0["b"] as String, $0["v"] as String) }!
            }
            _ = try ops.branchVariant(blockID, from: variantID)
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the copy carrying her take survives; the untouched one retires")
        }
    }

    @Test func aNoteTheManifestDoesNotKnowMarksTheCopyEdited() async throws {
        // A note she ADDED to the book is her own writing — the copy that
        // holds it is edited and must be the survivor.
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let added: String = try b.with { ops, _ in
            let note = try ops.importPost(
                title: "My reading notes", text: "Watson is the narrator.", undoLabel: "Import")
            _ = try ops.addPostToReading(note.container.id, to: copyB.bookID)
            return note.container.id
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID])
            #expect(try client.db.deletedAt("container", added) == nil,
                    "her added note survives with its copy")
        }
        _ = copyA
    }

    /// **RED ON OLD (the ladder's F5, MAJOR):** the "a savepoint = engagement"
    /// signal counted AUTO commits, which the system mints on untouched
    /// seeded text — `closeAutoCommit` runs on every note that stops being
    /// shown, and `isDirty` reads a never-committed take as dirty — so merely
    /// READING a story on each device stamped both copies EDITED and the
    /// ruled dedupe degraded to both-survive in essentially every real store.
    /// Engagement is her hand: MANUAL savepoints only.
    @Test func anAutoSavepointFromReadingAndLeavingIsNotEngagement() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        // Each reader opens one story and leaves — the everyday occasion.
        for (client, copy) in [(a, copyA), (b, copyB)] {
            let minted = try client.with { ops, _ in
                try ops.closeAutoCommit(copy.postIDs["A Scandal in Bohemia"]!)
            }
            #expect(!minted.isEmpty, "positive activity: the leaving occasion DID mint an auto savepoint")
            #expect(minted.allSatisfy { $0.kind == .auto })
        }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyA.bookID],
                    "both copies are still pristine — ONE survives (old: both, forever)")
        }
        _ = copyB
    }

    /// …and a MANUAL savepoint is still her hand: the copy carrying it is
    /// the survivor whatever the ids.
    @Test func aManualSavepointStillProtectsTheCopy() async throws {
        let (a, b, server) = try pairWithFacts()
        let copyA = try seedCopy(a)
        let copyB = try seedCopy(b)
        let savedPost = copyB.postIDs["A Scandal in Bohemia"]!
        let variant = try firstVariantID(b, postID: savedPost)
        try b.with { ops, _ in _ = try ops.commit(variant) }

        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)

        for client in [a, b] {
            #expect(try liveCopyIDs(client) == [copyB.bookID],
                    "the copy she deliberately saved survives; the untouched one retires")
        }
        _ = copyA
    }

    @Test func noInjectedFactsMeansNoDedupe() async throws {
        // An engine nobody wired facts into cannot misidentify anything —
        // the repair is inert by default (the keyProvider pattern).
        let (a, b, server) = try furniturePair()
        _ = try seedCopy(a)
        _ = try seedCopy(b)
        try await a.push()
        try await b.push()
        try await b.pull()
        try await a.pull()
        try await assertFurnitureConverged(a, b, server)
        #expect(try liveCopyIDs(a).count == 2)
    }
}
