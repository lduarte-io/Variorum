import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 14b, batch 2 — L6's remaining crown pieces: the TOTAL mirror-dump
/// assertion (every encrypted-classified value on the server bears `e1:`,
/// never equals its plaintext, and opens back to exactly the local words —
/// structure visible, words never), and the wipe-and-repush semantics
/// (ruling R-2): `resyncReinitialize` + a mirror truncate + a full re-push,
/// after which a FRESH device onboards by pull and converges byte-identical.
@Suite("Mirror dump & wipe-and-repush (Phase 14b, batch 2)")
struct SyncMirrorDumpAndResyncTests {
    /// A world that populates EVERY encrypted-classified column at least
    /// once (the mirror-dump walk asserts this coverage positively, so a
    /// future encrypted column cannot silently escape the assertion).
    private func buildRichWorld(_ a: SyncClient) throws {
        try a.with { ops, db in
            let post = try ops.createPost(title: "the post title", profile: .journal)
            try ops.updateFloatingNotes(post.id, notes: "floating working notes")
            let made = try ops.newBlock(in: post.id, text: "First take prose.", at: .end)
            try ops.setBlockName(made.block.id, name: "the thesis")
            try ops.setBlockPresentation(
                made.block.id, BlockPresentation(color: "blue", emoji: "💡"))
            let alt = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.setTakeLabel(alt.id, label: "the second take")
            _ = try ops.commit(made.variant.id, message: "checkpoint message")
            _ = try ops.addBlockComment(to: made.block.id, text: "a margin comment")

            // A second block, then delete it — the dump must show tombstoned
            // rows' ciphertext too (tombstones travel with their text).
            let doomed = try ops.newBlock(in: post.id, text: "Doomed prose.", at: .end)
            try ops.deleteBlock(doomed.block.id)
            // Phase 13j (v1_14): a purge intent for it — the dump and the
            // reinit walk must see the purge table too (all-plain: ids and
            // enums only, nothing to seal).
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: doomed.block.id)])

            let tag = try ops.createTag(parent: nil, name: "life")
            let child = try ops.createTag(parent: tag.id, name: "goals")
            _ = try ops.applyTag(child.id, toPost: post.id)
            _ = try ops.applyTag(tag.id, toBlock: made.block.id)

            let reading = try ops.createReading(name: "the book", kind: .curated, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            let chapter = try ops.createSection(in: reading.id, name: "I / leaving")
            try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            let spec = try Queries.SmartQuerySpec(profile: "journal").encodedJSON()
            _ = try ops.createReading(name: "collected", kind: .smart, querySpec: spec)

            let ref = try ops.addReference(
                to: post.id, kind: .url, name: "a source", url: "https://example.org/secret-path")
            try ops.updateReferenceViewState(ref.id, viewState: #"{"page":4}"#)

            let lens = try ops.createLens(post: post.id, name: "reader's cut")
            _ = try ops.setLensChoice(lens: lens.id, block: made.block.id, variant: alt.id)
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.newBlock(in: pool.id, text: "loose idea", at: .end).block
            _ = try ops.setCanvasPosition(container: pool.id, block: scrap.id, x: 12, y: 34)
            // Edges: merge two scraps (releases both to lineage, mints the
            // merged block + two derived_from edges).
            let left = try ops.newBlock(in: pool.id, text: "left half.", at: .end).block
            let right = try ops.newBlock(in: pool.id, text: "right half.", at: .end).block
            _ = try ops.merge(left.id, right.id)
        }
    }

    /// The full classification, as "table.column" — the walk must SEE every
    /// one on the mirror or the fixture (not the seam) is incomplete.
    private var everyEncryptedColumn: Set<String> {
        Set(SyncSchema.tables.flatMap { table in
            table.encryptedColumns.map { "\(table.name).\($0)" }
        })
    }

    @Test func aTotalMirrorDumpReadsAsStructureNeverWords() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        try buildRichWorld(a)
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())

        var coveredColumns: Set<String> = []
        for row in await server.allStoredRows {
            guard let table = SyncSchema.table(named: row.table) else {
                Issue.record("server stores an unregistered table \(row.table)")
                continue
            }
            for column in table.encryptedColumns {
                guard case .text(let stored) = row.columns[column] else { continue }
                coveredColumns.insert("\(table.name).\(column)")
                #expect(PayloadCipher.isEncrypted(stored),
                        "\(table.name).\(column) row \(row.rowID) is stored in the clear")
                // Never the words: the stored value differs from the local
                // plaintext…
                let local = try a.db.fetchString(
                    "SELECT \(column) FROM \(table.name) WHERE \(table.primaryKey) = ?",
                    [row.rowID])
                #expect(stored != local,
                        "\(table.name).\(column) row \(row.rowID) equals its plaintext")
                // …and opens back to exactly it (recoverable with the key —
                // structure visible, words never, nothing lost).
                #expect(try SyncTestKeys.open(
                    stored, table: row.table, rowID: row.rowID, column: column) == local,
                        "\(table.name).\(column) row \(row.rowID) does not decrypt to its local plaintext")
            }
        }
        #expect(coveredColumns == everyEncryptedColumn,
                "the mirror dump never saw: \(everyEncryptedColumn.subtracting(coveredColumns).sorted()) — the fixture must populate every encrypted column")
    }

    // MARK: - resyncReinitialize semantics (R-2's client half)

    @Test func resyncReinitializeResetsBookkeepingAndEnqueuesEveryRowIncludingTombstonesCommitsAndSettings() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        try buildRichWorld(a)
        _ = try await a.push()
        _ = try await a.pull()
        #expect(try a.outboxCount() == 0)
        #expect(try a.storedDeviceID() == nil, "pre-13x 1a: no identity in the file")
        let tombstonedBlock = try a.db.fetchString(
            "SELECT id FROM block WHERE deleted_at IS NOT NULL")!

        try await a.withAsync { _ in
            try await a.engine().resyncReinitialize()
        }

        var totalRows = 0
        for table in SyncSchema.tables {
            let count = try a.db.fetchInt("SELECT COUNT(*) FROM \(table.name)") ?? 0
            totalRows += count
            #expect(count > 0, "\(table.name) has no fixture row — the walk cannot see it")
            #expect(try a.db.fetchInt(
                "SELECT COUNT(*) FROM \(table.name) WHERE sync_version != 0") == 0,
                    "\(table.name): every row rebases to CAS base 0")
        }
        #expect(try a.outboxCount() == totalRows,
                "EVERY row of EVERY synced table re-pushes — live AND tombstoned")
        // The named corners explicitly: a tombstoned row, a commit, a
        // seeded setting.
        #expect(try a.outboxContains("block", tombstonedBlock))
        let anyCommit = try a.db.fetchString("SELECT id FROM commit_point LIMIT 1")!
        #expect(try a.outboxContains("commit_point", anyCommit))
        #expect(try a.outboxContains("setting", "default_segmentation"))
        // Bookkeeping cleared; nothing identity-shaped to keep — the
        // identity rides custody, never the file (pre-13x 1a).
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM sync_row_seq") == 0)
        #expect(try a.db.fetchString(
            "SELECT value FROM sync_state WHERE key = 'last_server_seq'") == nil)
        #expect(try a.storedDeviceID() == nil,
                "resyncReinitialize spares nothing key-shaped because nothing key-shaped is in the file")
    }

    // MARK: - The scenario: wipe the mirror, re-init, repush, fresh onboard

    @Test func wipeAndRepushReinitializesTheMirrorAndAFreshDeviceOnboardsByteIdentical() async throws {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 90, seed: 2)
        try buildRichWorld(a)
        try await syncToQuiescence(a, b, server: server)
        let seqBeforeWipe = await server.headSeq
        #expect(seqBeforeWipe > 0)

        // The gate's shape: mirror truncated (seq NOT reset), the surviving
        // device re-initializes and re-pushes its whole store through the
        // encrypting serializer.
        await server.wipe()
        try await a.withAsync { _ in
            try await a.engine().resyncReinitialize()
        }
        let repush = try await a.push()
        #expect(repush.accepted > 0)
        #expect(try a.outboxCount() == 0, "the full re-push drains clean")
        #expect(await server.headSeq > seqBeforeWipe,
                "the ordering authority stays monotonic across the wipe (SyncSpec §9)")

        // The re-pushed mirror is ciphertext (the repush went THROUGH the
        // new serializer — the R-2 point).
        let anyVariant = try a.db.fetchString("SELECT id FROM variant LIMIT 1")!
        let stored = await server.currentRow(table: "variant", rowID: anyVariant)
        if case .text(let value)? = stored?.columns["working_text"] {
            #expect(PayloadCipher.isEncrypted(value))
        } else {
            Issue.record("re-pushed variant missing on the mirror")
        }

        // A FRESH device onboards by pull-to-head (the phone's re-onboard,
        // which is also the restore drill's fresh-device half) and
        // converges byte-identical — tombstones included.
        let c = try SyncClient(name: "C", prefix: "CC", transport: server, seed: 5)
        try await syncToQuiescence(a, c, server: server)
        #expect(try a.syncedDump() == c.syncedDump(),
                "the fresh onboard converges byte-identical to the re-initialized device")
        #expect(try c.db.fetchInt("SELECT COUNT(*) FROM block WHERE deleted_at IS NOT NULL")! > 0,
                "tombstones crossed the wipe — the dead stay dead on the fresh device")

        // And the pre-wipe second device: its bookkeeping predates the
        // wipe, so IT must re-initialize too (the R-2 choreography's
        // per-client cursor/seq reset — proven here, decided at the gate).
        try await b.withAsync { _ in
            try await b.engine().resyncReinitialize()
        }
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump())
    }
}
