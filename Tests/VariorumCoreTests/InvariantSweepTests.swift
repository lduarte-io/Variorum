import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 2, Step 9: seeded-random sequences over the whole non-structural op
/// set, with DB-wide invariant predicates checked along the way. Typed
/// refusals (`OperationError`) count as no-ops — the guards ARE the product.
/// Anything else escaping an operation (a SQLite constraint error above all)
/// means an invariant survived only by luck; the test fails on it.
@Suite("Randomized invariant sweep (Phase 2, Step 9)")
struct InvariantSweepTests {
    @Test(arguments: [1, 7, 42, 99, 20_260_705] as [UInt64])
    func randomOpSequencesPreserveTheInvariants(seed: UInt64) throws {
        try withOperations(seed: seed) { _, db in
            let stack = UndoStack()
            var sweep = Sweep(
                ops: Operations(undoStack: stack), db: db, stack: stack,
                rng: SeededGenerator(seed: seed &* 2654435761))

            var commitCount = 0
            for step in 0..<250 {
                try sweep.step()

                // I5 continuously: commits only ever accumulate.
                let commits = try db.fetchInt("SELECT COUNT(*) FROM commit_point") ?? 0
                #expect(commits >= commitCount, "commit count fell at step \(step)")
                commitCount = commits

                if step % 25 == 24 {
                    try assertInvariants(db, at: step)
                }
            }
            try assertInvariants(db, at: 250)
        }
    }

    // MARK: - DB-wide predicates

    private func assertInvariants(_ db: AppDatabase, at step: Int) throws {
        // I10 + default lifecycle: every live block has ≥1 live active
        // variant, and its default_variant_id names one of its own live
        // active variants.
        #expect(try db.fetchInt(
            """
            SELECT COUNT(*) FROM block b
            WHERE b.deleted_at IS NULL AND NOT EXISTS (
                SELECT 1 FROM variant v
                WHERE v.block_id = b.id AND v.deleted_at IS NULL AND v.status = 'active')
            """) == 0, "I10 violated at step \(step)")
        #expect(try db.fetchInt(
            """
            SELECT COUNT(*) FROM block b
            WHERE b.deleted_at IS NULL AND (
                b.default_variant_id IS NULL OR NOT EXISTS (
                    SELECT 1 FROM variant v
                    WHERE v.id = b.default_variant_id AND v.block_id = b.id
                      AND v.deleted_at IS NULL AND v.status = 'active'))
            """) == 0, "dangling default_variant_id at step \(step)")

        // I2: at most one live placement per block.
        #expect(try db.fetchInt(
            """
            SELECT COUNT(*) FROM (
                SELECT block_id FROM container_block WHERE deleted_at IS NULL
                GROUP BY block_id HAVING COUNT(*) > 1)
            """) == 0, "I2 violated at step \(step)")

        // No live row under a tombstoned parent. (Documented exceptions:
        // chosen_variant_id may dangle — the read-time fallback rule; edges
        // may outlive one endpoint after a stamp-based restore — the read
        // layer filters by live blocks.)
        for (label, sql) in [
            ("variant→block", """
                SELECT COUNT(*) FROM variant v JOIN block b ON b.id = v.block_id
                WHERE v.deleted_at IS NULL AND b.deleted_at IS NOT NULL
                """),
            ("placement→container/block", """
                SELECT COUNT(*) FROM container_block cb
                JOIN container c ON c.id = cb.container_id
                JOIN block b ON b.id = cb.block_id
                WHERE cb.deleted_at IS NULL
                  AND (c.deleted_at IS NOT NULL OR b.deleted_at IS NOT NULL)
                """),
            ("reading_post→reading/post", """
                SELECT COUNT(*) FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id
                JOIN container c ON c.id = rp.post_id
                WHERE rp.deleted_at IS NULL
                  AND (r.deleted_at IS NOT NULL OR c.deleted_at IS NOT NULL)
                """),
            ("post_tag→tag/post", """
                SELECT COUNT(*) FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id
                JOIN container c ON c.id = pt.post_id
                WHERE pt.deleted_at IS NULL
                  AND (t.deleted_at IS NOT NULL OR c.deleted_at IS NOT NULL)
                """),
            ("block_tag→tag/block", """
                SELECT COUNT(*) FROM block_tag bt
                JOIN tag t ON t.id = bt.tag_id
                JOIN block b ON b.id = bt.block_id
                WHERE bt.deleted_at IS NULL
                  AND (t.deleted_at IS NOT NULL OR b.deleted_at IS NOT NULL)
                """),
            ("reference→container", """
                SELECT COUNT(*) FROM reference rf
                JOIN container c ON c.id = rf.container_id
                WHERE rf.deleted_at IS NULL AND c.deleted_at IS NOT NULL
                """),
        ] {
            #expect(try db.fetchInt(sql) == 0, "\(label) dangling at step \(step)")
        }

        // Position hygiene: every live ordering key is a valid fractional
        // index (base-62, non-empty, no trailing minimum digit) — so every
        // (position, id) sort is stable and every gap remains bisectable.
        let allowed = Set(FractionalIndex.alphabet)
        let positions = try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT position FROM container_block WHERE deleted_at IS NULL
                    UNION ALL SELECT fan_position FROM variant WHERE deleted_at IS NULL
                    UNION ALL SELECT position FROM reading_post WHERE deleted_at IS NULL
                    UNION ALL SELECT position FROM reference WHERE deleted_at IS NULL
                    """)
        }
        for position in positions {
            #expect(!position.isEmpty && position.last != "0"
                && position.allSatisfy { allowed.contains($0) },
                "invalid position key '\(position)' at step \(step)")
        }
    }
}

// MARK: - The op sequence generator

private struct Sweep {
    let ops: Operations
    let db: AppDatabase
    let stack: UndoStack
    var rng: SeededGenerator

    mutating func step() throws {
        do {
            try performOne()
        } catch is OperationError {
            // A refusal is a correct outcome, not a failure — the sequence
            // simply moves on.
        }
    }

    private mutating func performOne() throws {
        switch Int.random(in: 0..<26, using: &rng) {
        case 0:
            _ = try ops.createPost(title: text(), profile: Bool.random(using: &rng) ? .journal : nil)
        case 1:
            if Bool.random(using: &rng) {
                _ = try ops.createPool(title: text())
            } else if let container = try random("SELECT id FROM container WHERE deleted_at IS NULL") {
                try ops.deleteContainer(container)
            }
        case 2, 3:
            if let container = try random("SELECT id FROM container WHERE deleted_at IS NULL") {
                _ = try ops.newBlock(in: container, text: text(), at: position())
            }
        case 4, 5:
            if let variant = try random("SELECT id FROM variant WHERE deleted_at IS NULL") {
                try ops.autosave(variant, text: text(), charDelta: Int.random(in: -30...30, using: &rng))
            }
        case 6:
            if let variant = try random("SELECT id FROM variant WHERE deleted_at IS NULL") {
                _ = try ops.commit(variant, kind: Bool.random(using: &rng) ? .manual : .auto)
            }
        case 7:
            if let post = try random("SELECT id FROM container WHERE deleted_at IS NULL AND kind = 'post'") {
                _ = try ops.idleAutoCommit(post)
            }
        case 8:
            let pair = try db.read { db in
                try Row.fetchOne(db, sql: "SELECT id, variant_id FROM commit_point ORDER BY RANDOM() LIMIT 1")
            }
            if let pair {
                try ops.restoreCommit(pair["variant_id"], commitID: pair["id"])
            }
        case 9:
            if let variant = try randomVariantWithBlock() {
                _ = try ops.branchVariant(variant.blockID, from: variant.id)
            }
        case 10:
            if let block = try random("SELECT id FROM block WHERE deleted_at IS NULL") {
                _ = try ops.newBlankVariant(block)
            }
        case 11:
            if let variant = try random("SELECT id FROM variant WHERE deleted_at IS NULL") {
                try Bool.random(using: &rng) ? ops.lockVariant(variant) : ops.unlockVariant(variant)
            }
        case 12:
            if let post = try random("SELECT id FROM container WHERE deleted_at IS NULL AND kind = 'post'") {
                try Bool.random(using: &rng) ? ops.lockPost(post) : ops.unlockPost(post)
            }
        case 13:
            if let variant = try random("SELECT id FROM variant WHERE deleted_at IS NULL") {
                try Bool.random(using: &rng) ? ops.archiveVariant(variant) : ops.unarchiveVariant(variant)
            }
        case 14:
            if let variant = try random("SELECT id FROM variant WHERE deleted_at IS NULL") {
                try ops.deleteVariant(variant)
            }
        case 15:
            if let block = try random("SELECT id FROM block WHERE deleted_at IS NULL") {
                try ops.deleteBlock(block)
            }
        case 16:
            if let block = try random("SELECT id FROM block WHERE deleted_at IS NOT NULL") {
                try ops.restoreBlock(block)
            }
        case 17:
            if let variant = try randomVariantWithBlock() {
                try ops.chooseVariant(variant.blockID, variantID: variant.id)
            }
        case 18:
            if let block = try random("SELECT id FROM block WHERE deleted_at IS NULL"),
               let container = try random("SELECT id FROM container WHERE deleted_at IS NULL") {
                try ops.moveBlock(block, to: container, at: position())
            }
        case 19:
            if let block = try random("SELECT id FROM block WHERE deleted_at IS NULL") {
                try ops.reorder(block, to: position())
            }
        case 20:
            // The unplaced-block path: placeBlock only applies to released
            // blocks, so candidates are live blocks with no live placement.
            if let block = try random(
                """
                SELECT b.id FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS (
                    SELECT 1 FROM container_block cb
                    WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
                """),
               let container = try random("SELECT id FROM container WHERE deleted_at IS NULL") {
                _ = try ops.placeBlock(block, in: container, at: position())
            }
        case 21:
            switch Int.random(in: 0..<3, using: &rng) {
            case 0:
                _ = try ops.createReading(
                    name: text(), kind: .curated,
                    maxPosts: Bool.random(using: &rng) ? Int.random(in: 1...4, using: &rng) : nil)
            case 1:
                if let reading = try random("SELECT id FROM reading WHERE deleted_at IS NULL"),
                   let post = try random("SELECT id FROM container WHERE deleted_at IS NULL AND kind = 'post'") {
                    _ = try ops.addPostToReading(post, to: reading)
                }
            default:
                if let membership = try db.read({ db in
                    try Row.fetchOne(
                        db,
                        sql: "SELECT reading_id, post_id FROM reading_post WHERE deleted_at IS NULL ORDER BY RANDOM() LIMIT 1")
                }) {
                    try ops.removePostFromReading(membership["post_id"], from: membership["reading_id"])
                }
            }
        case 22:
            switch Int.random(in: 0..<3, using: &rng) {
            case 0:
                let parent = try random("SELECT id FROM tag WHERE deleted_at IS NULL")
                _ = try ops.createTag(
                    parent: Bool.random(using: &rng) ? parent : nil, name: text())
            case 1:
                if let tag = try random("SELECT id FROM tag WHERE deleted_at IS NULL") {
                    try ops.renameTag(tag, newName: text())
                }
            default:
                if let tag = try random("SELECT id FROM tag WHERE deleted_at IS NULL") {
                    try ops.deleteTag(tag)
                }
            }
        case 23:
            guard let tag = try random("SELECT id FROM tag WHERE deleted_at IS NULL") else { break }
            if Bool.random(using: &rng),
               let post = try random("SELECT id FROM container WHERE deleted_at IS NULL AND kind = 'post'") {
                _ = try ops.applyTag(tag, toPost: post)
            } else if let block = try random("SELECT id FROM block WHERE deleted_at IS NULL") {
                _ = try ops.applyTag(tag, toBlock: block)
            }
        case 24:
            if Bool.random(using: &rng) {
                if let post = try random("SELECT id FROM container WHERE deleted_at IS NULL AND kind = 'post'") {
                    _ = try ops.addReference(to: post, kind: .url, url: "https://example.org/\(text())")
                }
            } else if let reference = try random("SELECT id FROM reference WHERE deleted_at IS NULL") {
                try ops.removeReference(reference)
            }
        default:
            _ = try stack.undo(with: ops)
        }
    }

    // MARK: Candidates

    private mutating func random(_ sql: String) throws -> String? {
        let ids = try db.read { db in try String.fetchAll(db, sql: sql) }
        guard !ids.isEmpty else { return nil }
        return ids[Int.random(in: 0..<ids.count, using: &rng)]
    }

    private mutating func randomVariantWithBlock() throws -> (id: String, blockID: String)? {
        let rows = try db.read { db in
            try Row.fetchAll(db, sql: "SELECT id, block_id FROM variant WHERE deleted_at IS NULL")
        }
        guard !rows.isEmpty else { return nil }
        let row = rows[Int.random(in: 0..<rows.count, using: &rng)]
        return (row["id"], row["block_id"])
    }

    private mutating func text() -> String {
        let words = (0..<Int.random(in: 1...8, using: &rng)).map { _ in
            String("abcdefghij".shuffled(using: &rng).prefix(Int.random(in: 1...6, using: &rng)))
        }
        // Occasional newlines so multi-paragraph buffers exist.
        return words.joined(separator: Int.random(in: 0..<8, using: &rng) == 0 ? "\n" : " ")
    }

    private mutating func position() -> Operations.InsertPosition {
        Bool.random(using: &rng) ? .end : .start
    }
}
