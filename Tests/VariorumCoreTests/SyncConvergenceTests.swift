import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The phase's verification (master plan, Phase 5 row): two devices, one
/// dumb server, every scenario ending with **both outboxes empty and
/// byte-identical synced tables**. Determinism means identical inputs
/// converge whichever order batches arrive — the soak randomizes op mixes
/// AND pull window sizes to prove batch boundaries never matter.
@Suite("Two-client convergence (Phase 5, Step 7)")
struct SyncConvergenceTests {
    private func pair() throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 977, seed: 2)
        return (a, b, server)
    }

    private func assertConverged(
        _ a: SyncClient, _ b: SyncClient, _ server: FakeSyncServer, batchSize: Int = 200
    ) async throws {
        try await syncToQuiescence(a, b, server: server, batchSize: batchSize)
        #expect(try a.syncedDump() == b.syncedDump())
        #expect(try a.outboxCount() == 0)
        #expect(try b.outboxCount() == 0)
    }

    // MARK: - Scenarios

    @Test func offlineEditsOnDisjointRowsConverge() async throws {
        let (a, b, server) = try pair()
        try a.with { ops, _ in
            let post = try ops.createPost(title: "from the Mac", profile: .blog)
            _ = try ops.newBlock(in: post.id, text: "Desk thoughts.", at: .end)
        }
        try b.with { ops, _ in
            let entry = try ops.createPost(title: "from the phone", profile: .journal)
            _ = try ops.newBlock(in: entry.id, text: "Phone thoughts.", at: .end)
        }
        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt("SELECT COUNT(*) FROM container WHERE kind = 'post'") == 2)
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE working_text = 'Desk thoughts.'") != nil)
    }

    @Test func sameRowMetadataRaceConvergesServerVersionWins() async throws {
        let (a, b, server) = try pair()
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "original", profile: nil).id
        }
        try await syncToQuiescence(a, b, server: server)

        try a.with { ops, _ in try ops.renameContainer(postID, title: "A's title") }
        try b.with { ops, _ in try ops.renameContainer(postID, title: "B's title") }
        try await a.push()  // A reaches the server first: A's title is server truth…
        try await assertConverged(a, b, server)
        // …and B's later push CAS-rejected into accepting it. Deterministic,
        // worst case a lost rename — never corruption (SyncSpec §6/AppSpec §9).
        #expect(try a.db.fetchString("SELECT title FROM container WHERE id = ?", [postID]) == "A's title")
        #expect(try b.db.fetchString("SELECT title FROM container WHERE id = ?", [postID]) == "A's title")
    }

    @Test func moveMoveOnTheSameRowIsCASNotRepair() async throws {
        // The SAME placement row moved to two different posts (moveBlock
        // updates the row in place): pure metadata CAS, no I2 repair needed,
        // one home wins deterministically.
        let (a, b, server) = try pair()
        let (blockID, homeA, homeB): (String, String, String) = try a.with { ops, _ in
            let src = try ops.createPost(title: "source", profile: nil)
            let made = try ops.newBlock(in: src.id, text: "wanderer", at: .end)
            let homeA = try ops.createPost(title: "home A", profile: nil)
            let homeB = try ops.createPost(title: "home B", profile: nil)
            return (made.block.id, homeA.id, homeB.id)
        }
        try await syncToQuiescence(a, b, server: server)

        try a.with { ops, _ in try ops.moveBlock(blockID, to: homeA, at: .end) }
        try b.with { ops, _ in try ops.moveBlock(blockID, to: homeB, at: .end) }
        try await b.push()  // B's move is server truth this time
        try await assertConverged(a, b, server)
        let home = try a.db.fetchString(
            "SELECT container_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
            [blockID])
        #expect(home == homeB)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
            [blockID]) == 1, "I2 holds: one live placement")
    }

    @Test func workingTextRaceLosesNoTextOnEitherDevice() async throws {
        let (a, b, server) = try pair()
        let variantID: String = try a.with { ops, _ in
            let post = try ops.createPost(title: "p", profile: .journal)
            return try ops.newBlock(in: post.id, text: "the shared base", at: .end).variant.id
        }
        try await syncToQuiescence(a, b, server: server)

        try a.with { ops, _ in try ops.autosave(variantID, text: "rewritten on the Mac", charDelta: 8) }
        try b.with { ops, _ in try ops.autosave(variantID, text: "rewritten on the phone", charDelta: 8) }
        try await a.push()
        try await assertConverged(a, b, server)

        // S5, end to end: the row carries one text, the fan carries the
        // other, on BOTH devices — nothing clobbered, nothing interleaved.
        for client in [a, b] {
            let texts = try await client.db.read { db in
                Set(try String.fetchAll(
                    db, sql: "SELECT working_text FROM variant WHERE deleted_at IS NULL"))
            }
            #expect(texts == ["rewritten on the Mac", "rewritten on the phone"],
                    "\(client.name) lost a take")
            #expect(try client.db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL") == 1)
        }
    }

    /// The orphan race the suppressed-cascade repair exists for: B writes
    /// INTO a post that A concurrently deletes. B's block must die on every
    /// device — with the post's exact stamp, so a later `restoreContainer`
    /// brings it back like any other cascade victim.
    @Test func writingIntoAConcurrentlyDeletedPostConvergesAndStaysRestorable() async throws {
        let (a, b, server) = try pair()
        let postID: String = try a.with { ops, _ in
            try ops.createPost(title: "doomed", profile: .journal).id
        }
        try await syncToQuiescence(a, b, server: server)

        // B journals into the post and ships it; A deletes the post without
        // ever seeing B's entry.
        let newBlock: String = try b.with { ops, _ in
            try ops.newBlock(in: postID, text: "phone entry into a dying post", at: .end).block.id
        }
        try await b.push()
        try a.with { ops, _ in try ops.deleteContainer(postID) }
        try await assertConverged(a, b, server)

        let stamp = try a.db.deletedAt("container", postID)
        #expect(stamp != nil)
        for client in [a, b] {
            #expect(try client.db.deletedAt("block", newBlock) == stamp,
                    "\(client.name): the orphaned block joins the post's cascade, same stamp")
        }

        // And the pointer religion's payoff: restoring the post revives the
        // phone entry too, everywhere.
        try a.with { ops, _ in try ops.restoreContainer(postID) }
        try await assertConverged(a, b, server)
        #expect(try b.db.deletedAt("block", newBlock) == nil)
        #expect(try b.db.fetchString(
            "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL", [newBlock])
            == "phone entry into a dying post")
    }

    /// SyncSpec §7's documented convergence behavior, NOT a bug: two devices
    /// structurally dividing the same block offline converge to duplicated
    /// content — no index is violated, so no repair fires; the fan carries
    /// the losing first-half as a conflict card. Pinned so it is never a
    /// surprise.
    @Test func concurrentDivideOfTheSameBlockConvergesToDocumentedDuplication() async throws {
        let (a, b, server) = try pair()
        let (postID, blockID): (String, String) = try a.with { ops, _ in
            let post = try ops.createPost(title: "essay", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "One. Two. Three.", at: .end)
            return (post.id, made.block.id)
        }
        try await syncToQuiescence(a, b, server: server)

        try a.with { ops, _ in _ = try ops.divide(blockID, cut: 5) }   // "One." | "Two. Three."
        try b.with { ops, _ in _ = try ops.divide(blockID, cut: 10) }  // "One. Two." | "Three."
        try await a.push()
        try await assertConverged(a, b, server)

        for client in [a, b] {
            // Three live placements: the original (first half) + BOTH
            // devices' successors — the documented duplication.
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                """, [postID]) == 3, "\(client.name)")
            let slotTexts = try await client.db.read { db in
                Set(try Queries.renderPost(db, containerID: postID).compactMap(\.text))
            }
            #expect(slotTexts == ["One.", "Two. Three.", "Three."],
                    "\(client.name): the post reads with BOTH devices' second halves — duplicated, never lost")
            // The block row's first-half race resolved as S5: one first half
            // won the row, the other is a conflict card in the fan.
            let firstHalves = try await client.db.read { db in
                Set(try String.fetchAll(
                    db,
                    sql: "SELECT working_text FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                    arguments: [blockID]))
            }
            #expect(firstHalves == ["One.", "One. Two."], "\(client.name): both halves preserved")
        }
    }

    // MARK: - Randomized soak

    /// N random operations per device per round (structural ops included),
    /// then sync to quiescence with a RANDOM pull window size — asserting
    /// byte-equality and the synced-world invariants after every round.
    /// Batch boundaries must never affect the converged bytes.
    @Test(arguments: [11, 4242, 90210] as [UInt64])
    func randomizedSoakConverges(seed: UInt64) async throws {
        let (a, b, server) = try pair()
        var mixerA = SoakMixer(rng: SeededGenerator(seed: seed))
        var mixerB = SoakMixer(rng: SeededGenerator(seed: seed &* 977))
        var windowRNG = SeededGenerator(seed: seed &+ 5)

        for round in 1...3 {
            try a.with { ops, db in try mixerA.perform(ops, db, count: 18) }
            try b.with { ops, db in try mixerB.perform(ops, db, count: 18) }
            let window = Int.random(in: 1...9, using: &windowRNG)
            try await syncToQuiescence(a, b, server: server, batchSize: window, maxRounds: 16)
            #expect(try a.syncedDump() == b.syncedDump(), "diverged at round \(round) (window \(window))")
            for client in [a, b] {
                try assertSyncedWorldInvariants(client, round: round)
            }
        }
    }

    /// The invariant predicates a converged synced world must satisfy
    /// (deliberately NOT the full ops-layer sweep: sync tolerates two
    /// documented orphan classes — edges that outlive an endpoint and
    /// applications arriving under a dead tag — which read-side queries
    /// filter; everything the repairs own is asserted).
    private func assertSyncedWorldInvariants(_ client: SyncClient, round: Int) throws {
        // I2: at most one live placement per block.
        #expect(try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM (
                SELECT block_id FROM container_block WHERE deleted_at IS NULL
                GROUP BY block_id HAVING COUNT(*) > 1)
            """) == 0, "\(client.name) I2 violated at round \(round)")
        // I10: every live block keeps a live active variant.
        #expect(try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM block b
            WHERE b.deleted_at IS NULL AND NOT EXISTS (
                SELECT 1 FROM variant v
                WHERE v.block_id = b.id AND v.deleted_at IS NULL AND v.status = 'active')
            """) == 0, "\(client.name) I10 violated at round \(round)")
        // The default lifecycle: a live block's default names one of its own
        // live active variants.
        #expect(try client.db.fetchInt(
            """
            SELECT COUNT(*) FROM block b
            WHERE b.deleted_at IS NULL AND (
                b.default_variant_id IS NULL OR NOT EXISTS (
                    SELECT 1 FROM variant v
                    WHERE v.id = b.default_variant_id AND v.block_id = b.id
                      AND v.deleted_at IS NULL AND v.status = 'active'))
            """) == 0, "\(client.name) dangling default at round \(round)")
        // Position hygiene: every live ordering key stays a valid
        // fractional index.
        let allowed = Set(FractionalIndex.alphabet)
        let positions = try client.db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT position FROM container_block WHERE deleted_at IS NULL
                    UNION ALL SELECT fan_position FROM variant WHERE deleted_at IS NULL
                    UNION ALL SELECT position FROM reading_post WHERE deleted_at IS NULL
                    """)
        }
        for position in positions {
            #expect(!position.isEmpty && position.last != "0"
                && position.allSatisfy { allowed.contains($0) },
                "\(client.name) invalid position '\(position)' at round \(round)")
        }
    }
}

// MARK: - The soak's op mixer

/// A compact randomized op driver over the full API surface (lifecycle +
/// structural). Typed refusals are product behavior and count as no-ops;
/// anything else escaping an operation fails the soak.
private struct SoakMixer {
    var rng: SeededGenerator

    mutating func perform(_ ops: Operations, _ db: AppDatabase, count: Int) throws {
        for _ in 0..<count {
            do {
                try one(ops, db)
            } catch is OperationError {
                // refusals are the guards working
            }
        }
    }

    private mutating func one(_ ops: Operations, _ db: AppDatabase) throws {
        switch Int.random(in: 0..<16, using: &rng) {
        case 0:
            _ = try ops.createPost(
                title: word(), profile: Bool.random(using: &rng) ? .journal : nil)
        case 1:
            if Int.random(in: 0..<4, using: &rng) == 0 {
                _ = try ops.createPool(title: word())
            } else if let dead = try pick(db, "SELECT id FROM container WHERE deleted_at IS NOT NULL") {
                try ops.restoreContainer(dead)
            }
        case 2:
            if let container = try pick(db, "SELECT id FROM container WHERE deleted_at IS NULL") {
                _ = try ops.newBlock(in: container, text: sentenceText(), at: .end)
            }
        case 3:
            if let variant = try pick(db, "SELECT id FROM variant WHERE deleted_at IS NULL") {
                try ops.autosave(variant, text: sentenceText(), charDelta: Int.random(in: -20...20, using: &rng))
            }
        case 4:
            if let variant = try pick(db, "SELECT id FROM variant WHERE deleted_at IS NULL") {
                _ = try ops.commit(variant, kind: Bool.random(using: &rng) ? .manual : .auto)
            }
        case 5:
            if let row = try pickRow(db, "SELECT id, block_id FROM variant WHERE deleted_at IS NULL") {
                _ = try ops.branchVariant(row.1, from: row.0)
            }
        case 6:
            if let block = try pick(db, "SELECT id FROM block WHERE deleted_at IS NULL") {
                _ = try ops.newBlankVariant(block)
            }
        case 7:
            if let variant = try pick(db, "SELECT id FROM variant WHERE deleted_at IS NULL") {
                try Bool.random(using: &rng)
                    ? ops.deleteVariant(variant)
                    : ops.archiveVariant(variant)
            }
        case 8:
            if let block = try pick(db, "SELECT id FROM block WHERE deleted_at IS NULL") {
                try ops.deleteBlock(block)
            }
        case 9:
            if Int.random(in: 0..<3, using: &rng) == 0,
               let container = try pick(db, "SELECT id FROM container WHERE deleted_at IS NULL") {
                try ops.deleteContainer(container)
            } else if let block = try pick(db, "SELECT id FROM block WHERE deleted_at IS NOT NULL") {
                try ops.restoreBlock(block)
            }
        case 10:
            if let block = try pick(db, "SELECT id FROM block WHERE deleted_at IS NULL"),
               let container = try pick(db, "SELECT id FROM container WHERE deleted_at IS NULL") {
                try Bool.random(using: &rng)
                    ? ops.moveBlock(block, to: container, at: .end)
                    : ops.reorder(block, to: .start)
            }
        case 11:
            if let block = try pick(
                db,
                """
                SELECT b.id FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS (
                    SELECT 1 FROM container_block cb
                    WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
                """),
               let container = try pick(db, "SELECT id FROM container WHERE deleted_at IS NULL") {
                _ = try ops.placeBlock(block, in: container, at: .end)
            }
        case 12:
            switch Int.random(in: 0..<3, using: &rng) {
            case 0:
                _ = try ops.createTag(parent: nil, name: word())
            case 1:
                if let tag = try pick(db, "SELECT id FROM tag WHERE deleted_at IS NULL"),
                   let post = try pick(db, "SELECT id FROM container WHERE deleted_at IS NULL AND kind = 'post'") {
                    _ = try ops.applyTag(tag, toPost: post)
                }
            default:
                if let tag = try pick(db, "SELECT id FROM tag WHERE deleted_at IS NULL") {
                    try ops.deleteTag(tag)
                }
            }
        case 13:
            if let block = try placedBlock(db), let text = try rendered(ops, db, block) {
                _ = try ops.divide(block, cut: Int.random(in: 0...(text.utf16.count + 1), using: &rng))
            }
        case 14:
            if let container = try pick(
                db, "SELECT DISTINCT container_id FROM container_block WHERE deleted_at IS NULL") {
                let order = try db.read { db in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT block_id FROM container_block
                            WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                            """,
                        arguments: [container])
                }
                if order.count >= 2 {
                    let index = Int.random(in: 0..<(order.count - 1), using: &rng)
                    _ = try ops.merge(order[index], order[index + 1])
                }
            }
        default:
            if let block = try placedBlock(db), let text = try rendered(ops, db, block),
               text.utf16.count > 2 {
                let cut = Int.random(in: 1..<text.utf16.count, using: &rng)
                _ = try ops.extract(block, span: 0..<cut)
            }
        }
    }

    // MARK: candidates

    private mutating func pick(_ db: AppDatabase, _ sql: String) throws -> String? {
        let ids = try db.read { try String.fetchAll($0, sql: sql) }
        guard !ids.isEmpty else { return nil }
        return ids[Int.random(in: 0..<ids.count, using: &rng)]
    }

    private mutating func pickRow(_ db: AppDatabase, _ sql: String) throws -> (String, String)? {
        let rows = try db.read { try Row.fetchAll($0, sql: sql) }
        guard !rows.isEmpty else { return nil }
        let row = rows[Int.random(in: 0..<rows.count, using: &rng)]
        return (row[0] as String, row[1] as String)
    }

    private mutating func placedBlock(_ db: AppDatabase) throws -> String? {
        try pick(
            db,
            """
            SELECT b.id FROM block b
            JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
            WHERE b.deleted_at IS NULL
            """)
    }

    private func rendered(_ ops: Operations, _ db: AppDatabase, _ blockID: String) throws -> String? {
        try? db.read { try ops.renderedVariant($0, blockID: blockID).workingText }
    }

    private mutating func word() -> String {
        String("abcdefghijklmnop".shuffled(using: &rng).prefix(Int.random(in: 3...8, using: &rng)))
    }

    private mutating func sentenceText() -> String {
        (0..<Int.random(in: 1...3, using: &rng))
            .map { _ in word().capitalized + " " + word() + "." }
            .joined(separator: " ")
    }
}
